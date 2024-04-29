--------------------------------------------------------
--  DDL for Package Body OKL_AJL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AJL_PVT" AS
/* $Header: OKLSAJLB.pls 120.3 2007/08/10 12:00:58 dpsingh ship $ */

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
    G_VIEW              CONSTANT   VARCHAR2(30)  := 'OKL_TXL_ADJSTS_LNS_V';
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
    DELETE FROM OKL_TXL_ADJSTS_LNS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_TXL_ADJSTS_LNS_ALL_B B      --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_TXL_ADJSTS_LNS_TL T SET (
        CREATED_BY,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN) = (SELECT
                                  B.CREATED_BY,
                                  B.LAST_UPDATED_BY,
                                  B.LAST_UPDATE_LOGIN
                                FROM OKL_TXL_ADJSTS_LNS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_TXL_ADJSTS_LNS_TL SUBB, OKL_TXL_ADJSTS_LNS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.CREATED_BY <> SUBT.CREATED_BY
                      OR SUBB.LAST_UPDATED_BY <> SUBT.LAST_UPDATED_BY
                      OR SUBB.LAST_UPDATE_LOGIN <> SUBT.LAST_UPDATE_LOGIN
                      OR (SUBB.LAST_UPDATE_LOGIN IS NULL AND SUBT.LAST_UPDATE_LOGIN IS NOT NULL)
                      OR (SUBB.LAST_UPDATE_LOGIN IS NOT NULL AND SUBT.LAST_UPDATE_LOGIN IS NULL)
              ));

    INSERT INTO OKL_TXL_ADJSTS_LNS_TL (
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
        FROM OKL_TXL_ADJSTS_LNS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_TXL_ADJSTS_LNS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ADJSTS_LNS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ajl_rec                      IN ajl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ajl_rec_type IS
    CURSOR okl_txl_adjsts_lns_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ADJ_ID,
            TIL_ID,
            TLD_ID,
            PSL_ID,
            CODE_COMBINATION_ID,
            OBJECT_VERSION_NUMBER,
            AMOUNT,
            CHECK_APPROVAL_LIMIT_YN,
            RECEIVABLES_ADJUSTMENT_ID,
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
            KHR_ID,
            KLE_ID,
            STY_ID
      FROM Okl_Txl_Adjsts_Lns_B
     WHERE okl_txl_adjsts_lns_b.id = p_id;
    l_okl_txl_adjsts_lns_pk        okl_txl_adjsts_lns_pk_csr%ROWTYPE;
    l_ajl_rec                      ajl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_adjsts_lns_pk_csr (p_ajl_rec.id);
    FETCH okl_txl_adjsts_lns_pk_csr INTO
              l_ajl_rec.ID,
              l_ajl_rec.ADJ_ID,
              l_ajl_rec.TIL_ID,
              l_ajl_rec.TLD_ID,
              l_ajl_rec.PSL_ID,
              l_ajl_rec.CODE_COMBINATION_ID,
              l_ajl_rec.OBJECT_VERSION_NUMBER,
              l_ajl_rec.AMOUNT,
              l_ajl_rec.CHECK_APPROVAL_LIMIT_YN,
              l_ajl_rec.RECEIVABLES_ADJUSTMENT_ID,
              l_ajl_rec.REQUEST_ID,
              l_ajl_rec.PROGRAM_APPLICATION_ID,
              l_ajl_rec.PROGRAM_ID,
              l_ajl_rec.PROGRAM_UPDATE_DATE,
              l_ajl_rec.ORG_ID,
              l_ajl_rec.ATTRIBUTE_CATEGORY,
              l_ajl_rec.ATTRIBUTE1,
              l_ajl_rec.ATTRIBUTE2,
              l_ajl_rec.ATTRIBUTE3,
              l_ajl_rec.ATTRIBUTE4,
              l_ajl_rec.ATTRIBUTE5,
              l_ajl_rec.ATTRIBUTE6,
              l_ajl_rec.ATTRIBUTE7,
              l_ajl_rec.ATTRIBUTE8,
              l_ajl_rec.ATTRIBUTE9,
              l_ajl_rec.ATTRIBUTE10,
              l_ajl_rec.ATTRIBUTE11,
              l_ajl_rec.ATTRIBUTE12,
              l_ajl_rec.ATTRIBUTE13,
              l_ajl_rec.ATTRIBUTE14,
              l_ajl_rec.ATTRIBUTE15,
              l_ajl_rec.CREATED_BY,
              l_ajl_rec.CREATION_DATE,
              l_ajl_rec.LAST_UPDATED_BY,
              l_ajl_rec.LAST_UPDATE_DATE,
              l_ajl_rec.LAST_UPDATE_LOGIN,
              l_ajl_rec.KHR_ID,
              l_ajl_rec.KLE_ID,
              l_ajl_rec.STY_ID;
    x_no_data_found := okl_txl_adjsts_lns_pk_csr%NOTFOUND;
    CLOSE okl_txl_adjsts_lns_pk_csr;
    RETURN(l_ajl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ajl_rec                      IN ajl_rec_type
  ) RETURN ajl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ajl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ADJSTS_LNS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_txl_adjsts_lns_tl_rec    IN okl_txl_adjsts_lns_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_txl_adjsts_lns_tl_rec_type IS
    CURSOR okl_txl_adjsts_lns_tl_pk_csr (p_id                 IN NUMBER,
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
      FROM Okl_Txl_Adjsts_Lns_Tl
     WHERE okl_txl_adjsts_lns_tl.id = p_id
       AND okl_txl_adjsts_lns_tl.language = p_language;
    l_okl_txl_adjsts_lns_tl_pk     okl_txl_adjsts_lns_tl_pk_csr%ROWTYPE;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_txl_adjsts_lns_tl_pk_csr (p_okl_txl_adjsts_lns_tl_rec.id,
                                       p_okl_txl_adjsts_lns_tl_rec.language);
    FETCH okl_txl_adjsts_lns_tl_pk_csr INTO
              l_okl_txl_adjsts_lns_tl_rec.ID,
              l_okl_txl_adjsts_lns_tl_rec.LANGUAGE,
              l_okl_txl_adjsts_lns_tl_rec.SOURCE_LANG,
              l_okl_txl_adjsts_lns_tl_rec.SFWT_FLAG,
              l_okl_txl_adjsts_lns_tl_rec.CREATED_BY,
              l_okl_txl_adjsts_lns_tl_rec.CREATION_DATE,
              l_okl_txl_adjsts_lns_tl_rec.LAST_UPDATED_BY,
              l_okl_txl_adjsts_lns_tl_rec.LAST_UPDATE_DATE,
              l_okl_txl_adjsts_lns_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_txl_adjsts_lns_tl_pk_csr%NOTFOUND;
    CLOSE okl_txl_adjsts_lns_tl_pk_csr;
    RETURN(l_okl_txl_adjsts_lns_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_txl_adjsts_lns_tl_rec    IN okl_txl_adjsts_lns_tl_rec_type
  ) RETURN okl_txl_adjsts_lns_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_txl_adjsts_lns_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TXL_ADJSTS_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ajlv_rec                     IN ajlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ajlv_rec_type IS
    CURSOR okl_ajlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ADJ_ID,
            TIL_ID,
            TLD_ID,
            CODE_COMBINATION_ID,
            PSL_ID,
            AMOUNT,
            CHECK_APPROVAL_LIMIT_YN,
            RECEIVABLES_ADJUSTMENT_ID,
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
            KHR_ID,
            KLE_ID,
            STY_ID
      FROM Okl_Txl_Adjsts_Lns_V
     WHERE okl_txl_adjsts_lns_v.id = p_id;
    l_okl_ajlv_pk                  okl_ajlv_pk_csr%ROWTYPE;
    l_ajlv_rec                     ajlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ajlv_pk_csr (p_ajlv_rec.id);
    FETCH okl_ajlv_pk_csr INTO
              l_ajlv_rec.ID,
              l_ajlv_rec.OBJECT_VERSION_NUMBER,
              l_ajlv_rec.SFWT_FLAG,
              l_ajlv_rec.ADJ_ID,
              l_ajlv_rec.TIL_ID,
              l_ajlv_rec.TLD_ID,
              l_ajlv_rec.CODE_COMBINATION_ID,
              l_ajlv_rec.PSL_ID,
              l_ajlv_rec.AMOUNT,
              l_ajlv_rec.CHECK_APPROVAL_LIMIT_YN,
              l_ajlv_rec.RECEIVABLES_ADJUSTMENT_ID,
              l_ajlv_rec.ATTRIBUTE_CATEGORY,
              l_ajlv_rec.ATTRIBUTE1,
              l_ajlv_rec.ATTRIBUTE2,
              l_ajlv_rec.ATTRIBUTE3,
              l_ajlv_rec.ATTRIBUTE4,
              l_ajlv_rec.ATTRIBUTE5,
              l_ajlv_rec.ATTRIBUTE6,
              l_ajlv_rec.ATTRIBUTE7,
              l_ajlv_rec.ATTRIBUTE8,
              l_ajlv_rec.ATTRIBUTE9,
              l_ajlv_rec.ATTRIBUTE10,
              l_ajlv_rec.ATTRIBUTE11,
              l_ajlv_rec.ATTRIBUTE12,
              l_ajlv_rec.ATTRIBUTE13,
              l_ajlv_rec.ATTRIBUTE14,
              l_ajlv_rec.ATTRIBUTE15,
              l_ajlv_rec.REQUEST_ID,
              l_ajlv_rec.PROGRAM_APPLICATION_ID,
              l_ajlv_rec.PROGRAM_ID,
              l_ajlv_rec.PROGRAM_UPDATE_DATE,
              l_ajlv_rec.ORG_ID,
              l_ajlv_rec.CREATED_BY,
              l_ajlv_rec.CREATION_DATE,
              l_ajlv_rec.LAST_UPDATED_BY,
              l_ajlv_rec.LAST_UPDATE_DATE,
              l_ajlv_rec.LAST_UPDATE_LOGIN,
              l_ajlv_rec.KHR_ID,
              l_ajlv_rec.KLE_ID,
              l_ajlv_rec.STY_ID;
    x_no_data_found := okl_ajlv_pk_csr%NOTFOUND;
    CLOSE okl_ajlv_pk_csr;
    RETURN(l_ajlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ajlv_rec                     IN ajlv_rec_type
  ) RETURN ajlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ajlv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TXL_ADJSTS_LNS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ajlv_rec	IN ajlv_rec_type
  ) RETURN ajlv_rec_type IS
    l_ajlv_rec	ajlv_rec_type := p_ajlv_rec;
  BEGIN
    IF (l_ajlv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.object_version_number := NULL;
    END IF;
    IF (l_ajlv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ajlv_rec.adj_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.adj_id := NULL;
    END IF;
     IF (l_ajlv_rec.khr_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.khr_id := NULL;
    END IF;
     IF (l_ajlv_rec.kle_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.kle_id := NULL;
    END IF;
     IF (l_ajlv_rec.sty_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.sty_id := NULL;
    END IF;
    IF (l_ajlv_rec.til_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.til_id := NULL;
    END IF;
    IF (l_ajlv_rec.tld_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.tld_id := NULL;
    END IF;
    IF (l_ajlv_rec.code_combination_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.code_combination_id := NULL;
    END IF;
    IF (l_ajlv_rec.psl_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.psl_id := NULL;
    END IF;
    IF (l_ajlv_rec.amount = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.amount := NULL;
    END IF;
    IF (l_ajlv_rec.check_approval_limit_yn = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.check_approval_limit_yn := NULL;
    END IF;
    IF (l_ajlv_rec.receivables_adjustment_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.receivables_adjustment_id := NULL;
    END IF;
    IF (l_ajlv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute_category := NULL;
    END IF;
    IF (l_ajlv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute1 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute2 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute3 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute4 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute5 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute6 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute7 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute8 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute9 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute10 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute11 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute12 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute13 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute14 := NULL;
    END IF;
    IF (l_ajlv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_ajlv_rec.attribute15 := NULL;
    END IF;
    IF (l_ajlv_rec.request_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.request_id := NULL;
    END IF;
    IF (l_ajlv_rec.program_application_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.program_application_id := NULL;
    END IF;
    IF (l_ajlv_rec.program_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.program_id := NULL;
    END IF;
    IF (l_ajlv_rec.program_update_date = OKL_API.G_MISS_DATE) THEN
      l_ajlv_rec.program_update_date := NULL;
    END IF;
    IF (l_ajlv_rec.org_id = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.org_id := NULL;
    END IF;
    IF (l_ajlv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.created_by := NULL;
    END IF;
    IF (l_ajlv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_ajlv_rec.creation_date := NULL;
    END IF;
    IF (l_ajlv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ajlv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_ajlv_rec.last_update_date := NULL;
    END IF;
    IF (l_ajlv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_ajlv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ajlv_rec);
  END null_out_defaults;

 --Bug 6316320 dpsingh start
 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Khr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Khr_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Khr_Id (p_ajlv_rec  IN  ajlv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := Okl_Api.G_RET_STS_SUCCESS;
  l_dummy                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tcnv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_K_Headers
  WHERE id = p_id;


  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
     IF (p_ajlv_rec.khr_id IS NULL) OR
       (p_ajlv_rec.khr_id = OkL_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'KHR_ID');
       x_return_status     := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_ajlv_rec.khr_id IS NOT NULL) AND
       (p_ajlv_rec.khr_id <> Okl_Api.G_MISS_NUM) THEN

        OPEN okl_tcnv_fk_csr(p_ajlv_rec.KHR_ID);
        FETCH okl_tcnv_fk_csr INTO l_dummy;
        l_row_notfound := okl_tcnv_fk_csr%NOTFOUND;
        CLOSE okl_tcnv_fk_csr;
        IF (l_row_notfound) THEN
          Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KHR_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Khr_Id;

---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sty_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Sty_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sty_Id (p_ajlv_rec IN  ajlv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tclv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM Okl_Strm_Type_b
  WHERE id = p_id;


  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- check for data before processing
     IF (p_ajlv_rec.sty_id IS NULL) OR
       (p_ajlv_rec.sty_id = OkL_Api.G_MISS_NUM) THEN
       Okl_Api.SET_MESSAGE(p_app_name       => g_app_name
                           ,p_msg_name      => g_required_value
                           ,p_token1        => g_col_name_token
                           ,p_token1_value  => 'STY_ID');
       x_return_status     := Okl_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_ajlv_rec.sty_id IS NOT NULL) AND
       (p_ajlv_rec.sty_id <> OKL_API.G_MISS_NUM) THEN
        OPEN okl_tclv_fk_csr(p_ajlv_rec.STY_ID);
        FETCH okl_tclv_fk_csr INTO l_dummy_var;
        l_row_notfound := okl_tclv_fk_csr%NOTFOUND;
        CLOSE okl_tclv_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME,
                              G_INVALID_VALUE,
                              G_COL_NAME_TOKEN,
                              'STY_ID');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Sty_Id;

---------------------------------------------------------------------------
  -- PROCEDURE Validate_Kle_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_Kle_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Kle_Id (p_ajlv_rec  IN  ajlv_rec_type
                         ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_return_status                   VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;
  l_dummy_var                       VARCHAR2(1);
  l_row_notfound                    BOOLEAN := TRUE;
  item_not_found_error              EXCEPTION;

  CURSOR okl_tclv_fk_csr (p_id IN NUMBER) IS
  SELECT  '1'
  FROM okl_k_lines
  WHERE id = p_id;


  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ajlv_rec.kle_id IS NOT NULL) AND
       (p_ajlv_rec.kle_id <> OKL_API.G_MISS_NUM) THEN
        OPEN okl_tclv_fk_csr(p_ajlv_rec.kle_id);
        FETCH okl_tclv_fk_csr INTO l_dummy_var;
        l_row_notfound := okl_tclv_fk_csr%NOTFOUND;
        CLOSE okl_tclv_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN,'kle_id');
          RAISE item_not_found_error;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN item_not_found_error THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => sqlcode
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => sqlerrm);

       -- notify caller of an UNEXPECTED error
       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Kle_Id;
--Bug 6316320 dpsingh end
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_ajlv_rec		  IN  ajlv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_ajlv_rec.id = OKL_API.G_MISS_NUM
    OR p_ajlv_rec.id IS NULL
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
    p_ajlv_rec		  IN  ajlv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_ajlv_rec.object_version_number = OKL_API.G_MISS_NUM
    OR p_ajlv_rec.object_version_number IS NULL
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
  -- PROCEDURE Validate_Org_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Org_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_ajlv_rec		  IN  ajlv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- check value
    IF  p_ajlv_rec.org_id <> OKL_API.G_MISS_NUM
    AND p_ajlv_rec.org_id IS NOT NULL
    THEN
      x_return_status := okl_util.check_org_id (p_ajlv_rec.org_id);
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
  -- PROCEDURE Validate_Adj_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Adj_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_ajlv_rec	    IN  ajlv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_adjv_csr IS
		  SELECT 'x'
		  FROM   okl_trx_ar_adjsts_v
		  WHERE  id = p_ajlv_rec.adj_id;

  BEGIN

    -- initialize return status
    x_return_status	:= OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF p_ajlv_rec.adj_id = OKL_API.G_MISS_NUM
    OR p_ajlv_rec.adj_id IS NULL
    THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name		 => G_APP_NAME,
      	p_msg_name		 => G_REQUIRED_VALUE,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'adj_id');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      -- halt furhter validation of the column
      raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

    -- enforce foreign key
    OPEN l_adjv_csr;
      FETCH l_adjv_csr INTO l_dummy_var;
    CLOSE l_adjv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name     => G_APP_NAME,
      	p_msg_name     => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'adj_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_TXL_ADJSTS_LNS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'OKL_TRX_AR_ADJSTS_V');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;

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
      IF l_adjv_csr%ISOPEN THEN
         CLOSE l_adjv_csr;
      END IF;

  END Validate_Adj_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Til_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Til_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_ajlv_rec	    IN  ajlv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_tilv_csr IS
		  SELECT 'x'
		  FROM   okl_txl_ar_inv_lns_v
		  WHERE  id = p_ajlv_rec.til_id;

  BEGIN

    IF p_ajlv_rec.til_id IS NOT NULL THEN

    -- enforce foreign key
    OPEN l_tilv_csr;
      FETCH l_tilv_csr INTO l_dummy_var;
    CLOSE l_tilv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name     => G_APP_NAME,
      	p_msg_name     => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'til_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_TXL_ADJSTS_LNS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'OKL_TXL_AR_INV_LNS_V');

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
      IF l_tilv_csr%ISOPEN THEN
         CLOSE l_tilv_csr;
      END IF;

  END Validate_Til_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Tld_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Tld_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_ajlv_rec	    IN  ajlv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_tldv_csr IS
		  SELECT 'x'
		  FROM   okl_txd_ar_ln_dtls_v
		  WHERE  id = p_ajlv_rec.tld_id;

  BEGIN

    IF p_ajlv_rec.tld_id IS NOT NULL THEN

    -- enforce foreign key
    OPEN l_tldv_csr;
      FETCH l_tldv_csr INTO l_dummy_var;
    CLOSE l_tldv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name     => G_APP_NAME,
      	p_msg_name     => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'tld_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_TXL_ADJSTS_LNS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'OKL_TXD_AR_LN_DTLS_V');

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
      IF l_tldv_csr%ISOPEN THEN
         CLOSE l_tldv_csr;
      END IF;

  END Validate_Tld_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Code_Combination_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Code_Combination_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_ajlv_rec	    IN  ajlv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_cciv_csr IS
		  SELECT 'x'
		  FROM   gl_code_combinations
		  WHERE  code_combination_id = p_ajlv_rec.code_combination_id;

  BEGIN

    IF p_ajlv_rec.code_combination_id IS NOT NULL THEN

    -- enforce foreign key
    OPEN l_cciv_csr;
      FETCH l_cciv_csr INTO l_dummy_var;
    CLOSE l_cciv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name     => G_APP_NAME,
      	p_msg_name     => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'code_combination_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_TXL_ADJSTS_LNS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'GL_CODE_COMBINATIONS');

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
      IF l_cciv_csr%ISOPEN THEN
         CLOSE l_cciv_csr;
      END IF;

  END Validate_Code_Combination_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Psl_Id
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Psl_Id (
    x_return_status OUT NOCOPY VARCHAR2,
    p_ajlv_rec	    IN  ajlv_rec_type) IS

    l_dummy_var             VARCHAR2(1) := '?';

    CURSOR l_pslv_csr IS
		  SELECT 'x'
		  FROM   ar_payment_schedules_all
		  WHERE  payment_schedule_id = p_ajlv_rec.psl_id;

  BEGIN

    -- enforce foreign key
    OPEN l_pslv_csr;
      FETCH l_pslv_csr INTO l_dummy_var;
    CLOSE l_pslv_csr;

    -- if dummy value is still set to default, data was not found
    IF (l_dummy_var = '?') THEN

      -- display error message
      OKL_API.set_message(
      	p_app_name     => G_APP_NAME,
      	p_msg_name     => G_NO_PARENT_RECORD,
      	p_token1       => G_COL_NAME_TOKEN,
      	p_token1_value => 'psl_id',
      	p_token2       => G_CHILD_TABLE_TOKEN,
      	p_token2_value => 'OKL_TXL_ADJSTS_LNS_V',
      	p_token3       => G_PARENT_TABLE_TOKEN,
      	p_token3_value => 'AR_PAYMENT_SCHEDULES_ALL');

      -- notify caller of en error
      x_return_status := OKL_API.G_RET_STS_ERROR;

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
      IF l_pslv_csr%ISOPEN THEN
         CLOSE l_pslv_csr;
      END IF;

  END Validate_Psl_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  -- Post-Generation Change
  -- By RDRAGUIL on 24-MAY-2001
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_TXL_ADJSTS_LNS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ajlv_rec IN  ajlv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- call each column-level validation
--Bug 6316320 dpsingh start
Validate_Khr_Id(
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    Validate_Sty_Id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    Validate_Kle_Id(
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;
    --Bug 6316320 dpsingh end

    validate_id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_object_version_number (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_org_id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_adj_id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_til_id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_tld_id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;


    validate_code_combination_id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
       END IF;
    END IF;

    validate_psl_id (
      x_return_status => l_return_status,
      p_ajlv_rec      => p_ajlv_rec);

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
  ----------------------------------------------
  -- Validate_Record for:OKL_TXL_ADJSTS_LNS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_ajlv_rec IN ajlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ajlv_rec_type,
    p_to	IN OUT NOCOPY ajl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.adj_id := p_from.adj_id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sty_id := p_from.sty_id;
    p_to.til_id := p_from.til_id;
    p_to.tld_id := p_from.tld_id;
    p_to.psl_id := p_from.psl_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.check_approval_limit_yn := p_from.check_approval_limit_yn;
    p_to.receivables_adjustment_id := p_from.receivables_adjustment_id;
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
    p_from	IN ajl_rec_type,
    p_to	IN OUT NOCOPY ajlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.adj_id := p_from.adj_id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.sty_id := p_from.sty_id;
    p_to.til_id := p_from.til_id;
    p_to.tld_id := p_from.tld_id;
    p_to.psl_id := p_from.psl_id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.amount := p_from.amount;
    p_to.check_approval_limit_yn := p_from.check_approval_limit_yn;
    p_to.receivables_adjustment_id := p_from.receivables_adjustment_id;
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
    p_from	IN ajlv_rec_type,
    p_to	IN OUT NOCOPY okl_txl_adjsts_lns_tl_rec_type
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
    p_from	IN okl_txl_adjsts_lns_tl_rec_type,
    p_to	IN OUT NOCOPY ajlv_rec_type
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
  -- validate_row for:OKL_TXL_ADJSTS_LNS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajlv_rec                     ajlv_rec_type := p_ajlv_rec;
    l_ajl_rec                      ajl_rec_type;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_ajlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ajlv_rec);
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
  -- PL/SQL TBL validate_row for:AJLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type) IS

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
    IF (p_ajlv_tbl.COUNT > 0) THEN
      i := p_ajlv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ajlv_rec                     => p_ajlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_ajlv_tbl.LAST);
        i := p_ajlv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for:OKL_TXL_ADJSTS_LNS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajl_rec                      IN ajl_rec_type,
    x_ajl_rec                      OUT NOCOPY ajl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajl_rec                      ajl_rec_type := p_ajl_rec;
    l_def_ajl_rec                  ajl_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_ADJSTS_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ajl_rec IN  ajl_rec_type,
      x_ajl_rec OUT NOCOPY ajl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ajl_rec := p_ajl_rec;
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
      p_ajl_rec,                         -- IN
      l_ajl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TXL_ADJSTS_LNS_B(
        id,
        adj_id,
        til_id,
        tld_id,
        psl_id,
        code_combination_id,
        object_version_number,
        amount,
        check_approval_limit_yn,
        receivables_adjustment_id,
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
        khr_id,
        kle_id,
        sty_id)
      VALUES (
        l_ajl_rec.id,
        l_ajl_rec.adj_id,
        l_ajl_rec.til_id,
        l_ajl_rec.tld_id,
        l_ajl_rec.psl_id,
        l_ajl_rec.code_combination_id,
        l_ajl_rec.object_version_number,
        l_ajl_rec.amount,
        l_ajl_rec.check_approval_limit_yn,
        l_ajl_rec.receivables_adjustment_id,
        l_ajl_rec.request_id,
        l_ajl_rec.program_application_id,
        l_ajl_rec.program_id,
        l_ajl_rec.program_update_date,
        l_ajl_rec.org_id,
        l_ajl_rec.attribute_category,
        l_ajl_rec.attribute1,
        l_ajl_rec.attribute2,
        l_ajl_rec.attribute3,
        l_ajl_rec.attribute4,
        l_ajl_rec.attribute5,
        l_ajl_rec.attribute6,
        l_ajl_rec.attribute7,
        l_ajl_rec.attribute8,
        l_ajl_rec.attribute9,
        l_ajl_rec.attribute10,
        l_ajl_rec.attribute11,
        l_ajl_rec.attribute12,
        l_ajl_rec.attribute13,
        l_ajl_rec.attribute14,
        l_ajl_rec.attribute15,
        l_ajl_rec.created_by,
        l_ajl_rec.creation_date,
        l_ajl_rec.last_updated_by,
        l_ajl_rec.last_update_date,
        l_ajl_rec.last_update_login,
        l_ajl_rec.khr_id,
        l_ajl_rec.kle_id,
        l_ajl_rec.sty_id);
    -- Set OUT values
    x_ajl_rec := l_ajl_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_TXL_ADJSTS_LNS_TL --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_adjsts_lns_tl_rec    IN okl_txl_adjsts_lns_tl_rec_type,
    x_okl_txl_adjsts_lns_tl_rec    OUT NOCOPY okl_txl_adjsts_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type := p_okl_txl_adjsts_lns_tl_rec;
    ldefokltxladjstslnstlrec       okl_txl_adjsts_lns_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_ADJSTS_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_adjsts_lns_tl_rec IN  okl_txl_adjsts_lns_tl_rec_type,
      x_okl_txl_adjsts_lns_tl_rec OUT NOCOPY okl_txl_adjsts_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_adjsts_lns_tl_rec := p_okl_txl_adjsts_lns_tl_rec;
      x_okl_txl_adjsts_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_adjsts_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_adjsts_lns_tl_rec,       -- IN
      l_okl_txl_adjsts_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_txl_adjsts_lns_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_TXL_ADJSTS_LNS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_txl_adjsts_lns_tl_rec.id,
          l_okl_txl_adjsts_lns_tl_rec.language,
          l_okl_txl_adjsts_lns_tl_rec.source_lang,
          l_okl_txl_adjsts_lns_tl_rec.sfwt_flag,
          l_okl_txl_adjsts_lns_tl_rec.created_by,
          l_okl_txl_adjsts_lns_tl_rec.creation_date,
          l_okl_txl_adjsts_lns_tl_rec.last_updated_by,
          l_okl_txl_adjsts_lns_tl_rec.last_update_date,
          l_okl_txl_adjsts_lns_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_txl_adjsts_lns_tl_rec := l_okl_txl_adjsts_lns_tl_rec;
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
  -- insert_row for:OKL_TXL_ADJSTS_LNS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type,
    x_ajlv_rec                     OUT NOCOPY ajlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajlv_rec                     ajlv_rec_type;
    l_def_ajlv_rec                 ajlv_rec_type;
    l_ajl_rec                      ajl_rec_type;
    lx_ajl_rec                     ajl_rec_type;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type;
    lx_okl_txl_adjsts_lns_tl_rec   okl_txl_adjsts_lns_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ajlv_rec	IN ajlv_rec_type
    ) RETURN ajlv_rec_type IS
      l_ajlv_rec	ajlv_rec_type := p_ajlv_rec;
    BEGIN
      l_ajlv_rec.CREATION_DATE := SYSDATE;
      l_ajlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ajlv_rec.LAST_UPDATE_DATE := l_ajlv_rec.CREATION_DATE;
      l_ajlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ajlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ajlv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_ADJSTS_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ajlv_rec IN  ajlv_rec_type,
      x_ajlv_rec OUT NOCOPY ajlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ajlv_rec := p_ajlv_rec;
      x_ajlv_rec.OBJECT_VERSION_NUMBER := 1;
      -- Begin Post-Generation Change
      SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
        DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
        DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
      INTO
        x_ajlv_rec.request_id,
        x_ajlv_rec.program_application_id,
        x_ajlv_rec.program_id,
        x_ajlv_rec.program_update_date
      FROM   dual;
      -- End Post-Generation Change
      x_ajlv_rec.SFWT_FLAG := 'N';
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
    l_ajlv_rec := null_out_defaults(p_ajlv_rec);
    -- Set primary key value
    l_ajlv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ajlv_rec,                        -- IN
      l_def_ajlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ajlv_rec := fill_who_columns(l_def_ajlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ajlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ajlv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ajlv_rec, l_ajl_rec);
    migrate(l_def_ajlv_rec, l_okl_txl_adjsts_lns_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ajl_rec,
      lx_ajl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ajl_rec, l_def_ajlv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_adjsts_lns_tl_rec,
      lx_okl_txl_adjsts_lns_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_adjsts_lns_tl_rec, l_def_ajlv_rec);
    -- Set OUT values
    x_ajlv_rec := l_def_ajlv_rec;
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
  -- PL/SQL TBL insert_row for:AJLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type,
    x_ajlv_tbl                     OUT NOCOPY ajlv_tbl_type) IS

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
    IF (p_ajlv_tbl.COUNT > 0) THEN
      i := p_ajlv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ajlv_rec                     => p_ajlv_tbl(i),
          x_ajlv_rec                     => x_ajlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
         EXIT WHEN (i = p_ajlv_tbl.LAST);
        i := p_ajlv_tbl.NEXT(i);
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
  ---------------------------------------
  -- lock_row for:OKL_TXL_ADJSTS_LNS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajl_rec                      IN ajl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ajl_rec IN ajl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_ADJSTS_LNS_B
     WHERE ID = p_ajl_rec.id
       AND OBJECT_VERSION_NUMBER = p_ajl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ajl_rec IN ajl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TXL_ADJSTS_LNS_B
    WHERE ID = p_ajl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TXL_ADJSTS_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TXL_ADJSTS_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ajl_rec);
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
      OPEN lchk_csr(p_ajl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ajl_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ajl_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKL_TXL_ADJSTS_LNS_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_adjsts_lns_tl_rec    IN okl_txl_adjsts_lns_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_txl_adjsts_lns_tl_rec IN okl_txl_adjsts_lns_tl_rec_type) IS
    SELECT *
      FROM OKL_TXL_ADJSTS_LNS_TL
     WHERE ID = p_okl_txl_adjsts_lns_tl_rec.id
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
      OPEN lock_csr(p_okl_txl_adjsts_lns_tl_rec);
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
  ---------------------------------------
  -- lock_row for:OKL_TXL_ADJSTS_LNS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajl_rec                      ajl_rec_type;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type;
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
    migrate(p_ajlv_rec, l_ajl_rec);
    migrate(p_ajlv_rec, l_okl_txl_adjsts_lns_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ajl_rec
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
      l_okl_txl_adjsts_lns_tl_rec
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
  -- PL/SQL TBL lock_row for:AJLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type) IS

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
    IF (p_ajlv_tbl.COUNT > 0) THEN
      i := p_ajlv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ajlv_rec                     => p_ajlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_ajlv_tbl.LAST);
        i := p_ajlv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for:OKL_TXL_ADJSTS_LNS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajl_rec                      IN ajl_rec_type,
    x_ajl_rec                      OUT NOCOPY ajl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajl_rec                      ajl_rec_type := p_ajl_rec;
    l_def_ajl_rec                  ajl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ajl_rec	IN ajl_rec_type,
      x_ajl_rec	OUT NOCOPY ajl_rec_type
    ) RETURN VARCHAR2 IS
      l_ajl_rec                      ajl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ajl_rec := p_ajl_rec;
      -- Get current database values
      l_ajl_rec := get_rec(p_ajl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ajl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.id := l_ajl_rec.id;
      END IF;
      IF (x_ajl_rec.adj_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.adj_id := l_ajl_rec.adj_id;
      END IF;
       IF (x_ajl_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.khr_id := l_ajl_rec.khr_id;
      END IF;
       IF (x_ajl_rec.kle_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.kle_id := l_ajl_rec.kle_id;
      END IF;
       IF (x_ajl_rec.sty_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.sty_id := l_ajl_rec.sty_id;
      END IF;
      IF (x_ajl_rec.til_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.til_id := l_ajl_rec.til_id;
      END IF;
      IF (x_ajl_rec.tld_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.tld_id := l_ajl_rec.tld_id;
      END IF;
      IF (x_ajl_rec.psl_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.psl_id := l_ajl_rec.psl_id;
      END IF;
      IF (x_ajl_rec.code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.code_combination_id := l_ajl_rec.code_combination_id;
      END IF;
      IF (x_ajl_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.object_version_number := l_ajl_rec.object_version_number;
      END IF;
      IF (x_ajl_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.amount := l_ajl_rec.amount;
      END IF;
      IF (x_ajl_rec.check_approval_limit_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.check_approval_limit_yn := l_ajl_rec.check_approval_limit_yn;
      END IF;
      IF (x_ajl_rec.receivables_adjustment_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.receivables_adjustment_id := l_ajl_rec.receivables_adjustment_id;
      END IF;
      IF (x_ajl_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.request_id := l_ajl_rec.request_id;
      END IF;
      IF (x_ajl_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.program_application_id := l_ajl_rec.program_application_id;
      END IF;
      IF (x_ajl_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.program_id := l_ajl_rec.program_id;
      END IF;
      IF (x_ajl_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_ajl_rec.program_update_date := l_ajl_rec.program_update_date;
      END IF;
      IF (x_ajl_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.org_id := l_ajl_rec.org_id;
      END IF;
      IF (x_ajl_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute_category := l_ajl_rec.attribute_category;
      END IF;
      IF (x_ajl_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute1 := l_ajl_rec.attribute1;
      END IF;
      IF (x_ajl_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute2 := l_ajl_rec.attribute2;
      END IF;
      IF (x_ajl_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute3 := l_ajl_rec.attribute3;
      END IF;
      IF (x_ajl_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute4 := l_ajl_rec.attribute4;
      END IF;
      IF (x_ajl_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute5 := l_ajl_rec.attribute5;
      END IF;
      IF (x_ajl_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute6 := l_ajl_rec.attribute6;
      END IF;
      IF (x_ajl_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute7 := l_ajl_rec.attribute7;
      END IF;
      IF (x_ajl_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute8 := l_ajl_rec.attribute8;
      END IF;
      IF (x_ajl_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute9 := l_ajl_rec.attribute9;
      END IF;
      IF (x_ajl_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute10 := l_ajl_rec.attribute10;
      END IF;
      IF (x_ajl_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute11 := l_ajl_rec.attribute11;
      END IF;
      IF (x_ajl_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute12 := l_ajl_rec.attribute12;
      END IF;
      IF (x_ajl_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute13 := l_ajl_rec.attribute13;
      END IF;
      IF (x_ajl_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute14 := l_ajl_rec.attribute14;
      END IF;
      IF (x_ajl_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajl_rec.attribute15 := l_ajl_rec.attribute15;
      END IF;
      IF (x_ajl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.created_by := l_ajl_rec.created_by;
      END IF;
      IF (x_ajl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_ajl_rec.creation_date := l_ajl_rec.creation_date;
      END IF;
      IF (x_ajl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.last_updated_by := l_ajl_rec.last_updated_by;
      END IF;
      IF (x_ajl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_ajl_rec.last_update_date := l_ajl_rec.last_update_date;
      END IF;
      IF (x_ajl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_ajl_rec.last_update_login := l_ajl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_ADJSTS_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ajl_rec IN  ajl_rec_type,
      x_ajl_rec OUT NOCOPY ajl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ajl_rec := p_ajl_rec;
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
      p_ajl_rec,                         -- IN
      l_ajl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ajl_rec, l_def_ajl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_ADJSTS_LNS_B
    SET ADJ_ID = l_def_ajl_rec.adj_id,
        TIL_ID = l_def_ajl_rec.til_id,
        TLD_ID = l_def_ajl_rec.tld_id,
        PSL_ID = l_def_ajl_rec.psl_id,
        CODE_COMBINATION_ID = l_def_ajl_rec.code_combination_id,
        OBJECT_VERSION_NUMBER = l_def_ajl_rec.object_version_number,
        AMOUNT = l_def_ajl_rec.amount,
        CHECK_APPROVAL_LIMIT_YN = l_def_ajl_rec.check_approval_limit_yn,
        RECEIVABLES_ADJUSTMENT_ID = l_def_ajl_rec.receivables_adjustment_id,
        REQUEST_ID = l_def_ajl_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_ajl_rec.program_application_id,
        PROGRAM_ID = l_def_ajl_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_ajl_rec.program_update_date,
        ORG_ID = l_def_ajl_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_ajl_rec.attribute_category,
        ATTRIBUTE1 = l_def_ajl_rec.attribute1,
        ATTRIBUTE2 = l_def_ajl_rec.attribute2,
        ATTRIBUTE3 = l_def_ajl_rec.attribute3,
        ATTRIBUTE4 = l_def_ajl_rec.attribute4,
        ATTRIBUTE5 = l_def_ajl_rec.attribute5,
        ATTRIBUTE6 = l_def_ajl_rec.attribute6,
        ATTRIBUTE7 = l_def_ajl_rec.attribute7,
        ATTRIBUTE8 = l_def_ajl_rec.attribute8,
        ATTRIBUTE9 = l_def_ajl_rec.attribute9,
        ATTRIBUTE10 = l_def_ajl_rec.attribute10,
        ATTRIBUTE11 = l_def_ajl_rec.attribute11,
        ATTRIBUTE12 = l_def_ajl_rec.attribute12,
        ATTRIBUTE13 = l_def_ajl_rec.attribute13,
        ATTRIBUTE14 = l_def_ajl_rec.attribute14,
        ATTRIBUTE15 = l_def_ajl_rec.attribute15,
        CREATED_BY = l_def_ajl_rec.created_by,
        CREATION_DATE = l_def_ajl_rec.creation_date,
        LAST_UPDATED_BY = l_def_ajl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ajl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ajl_rec.last_update_login,
        KHR_ID = l_def_ajl_rec.khr_id,
        KLE_ID = l_def_ajl_rec.kle_id,
        STY_ID = l_def_ajl_rec.sty_id
    WHERE ID = l_def_ajl_rec.id;

    x_ajl_rec := l_def_ajl_rec;
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
  ------------------------------------------
  -- update_row for:OKL_TXL_ADJSTS_LNS_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_adjsts_lns_tl_rec    IN okl_txl_adjsts_lns_tl_rec_type,
    x_okl_txl_adjsts_lns_tl_rec    OUT NOCOPY okl_txl_adjsts_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type := p_okl_txl_adjsts_lns_tl_rec;
    ldefokltxladjstslnstlrec       okl_txl_adjsts_lns_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_txl_adjsts_lns_tl_rec	IN okl_txl_adjsts_lns_tl_rec_type,
      x_okl_txl_adjsts_lns_tl_rec	OUT NOCOPY okl_txl_adjsts_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_adjsts_lns_tl_rec := p_okl_txl_adjsts_lns_tl_rec;
      -- Get current database values
      l_okl_txl_adjsts_lns_tl_rec := get_rec(p_okl_txl_adjsts_lns_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.id := l_okl_txl_adjsts_lns_tl_rec.id;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.language = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.language := l_okl_txl_adjsts_lns_tl_rec.language;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.source_lang := l_okl_txl_adjsts_lns_tl_rec.source_lang;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.sfwt_flag := l_okl_txl_adjsts_lns_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.created_by := l_okl_txl_adjsts_lns_tl_rec.created_by;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.creation_date := l_okl_txl_adjsts_lns_tl_rec.creation_date;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.last_updated_by := l_okl_txl_adjsts_lns_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.last_update_date := l_okl_txl_adjsts_lns_tl_rec.last_update_date;
      END IF;
      IF (x_okl_txl_adjsts_lns_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_txl_adjsts_lns_tl_rec.last_update_login := l_okl_txl_adjsts_lns_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_ADJSTS_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_adjsts_lns_tl_rec IN  okl_txl_adjsts_lns_tl_rec_type,
      x_okl_txl_adjsts_lns_tl_rec OUT NOCOPY okl_txl_adjsts_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_adjsts_lns_tl_rec := p_okl_txl_adjsts_lns_tl_rec;
      x_okl_txl_adjsts_lns_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_txl_adjsts_lns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_txl_adjsts_lns_tl_rec,       -- IN
      l_okl_txl_adjsts_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_txl_adjsts_lns_tl_rec, ldefokltxladjstslnstlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TXL_ADJSTS_LNS_TL
    SET CREATED_BY = ldefokltxladjstslnstlrec.created_by,
        CREATION_DATE = ldefokltxladjstslnstlrec.creation_date,
        LAST_UPDATED_BY = ldefokltxladjstslnstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokltxladjstslnstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokltxladjstslnstlrec.last_update_login
    WHERE ID = ldefokltxladjstslnstlrec.id
      --AND SOURCE_LANG = USERENV('LANG');
    AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

    UPDATE  OKL_TXL_ADJSTS_LNS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokltxladjstslnstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_txl_adjsts_lns_tl_rec := ldefokltxladjstslnstlrec;
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
  -- update_row for:OKL_TXL_ADJSTS_LNS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type,
    x_ajlv_rec                     OUT NOCOPY ajlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajlv_rec                     ajlv_rec_type := p_ajlv_rec;
    l_def_ajlv_rec                 ajlv_rec_type;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type;
    lx_okl_txl_adjsts_lns_tl_rec   okl_txl_adjsts_lns_tl_rec_type;
    l_ajl_rec                      ajl_rec_type;
    lx_ajl_rec                     ajl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ajlv_rec	IN ajlv_rec_type
    ) RETURN ajlv_rec_type IS
      l_ajlv_rec	ajlv_rec_type := p_ajlv_rec;
    BEGIN
      l_ajlv_rec.CREATION_DATE := SYSDATE;
      l_ajlv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_ajlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ajlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ajlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ajlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ajlv_rec	IN ajlv_rec_type,
      x_ajlv_rec	OUT NOCOPY ajlv_rec_type
    ) RETURN VARCHAR2 IS
      l_ajlv_rec                     ajlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ajlv_rec := p_ajlv_rec;
      -- Get current database values
      l_ajlv_rec := get_rec(p_ajlv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ajlv_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.id := l_ajlv_rec.id;
      END IF;
      IF (x_ajlv_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.object_version_number := l_ajlv_rec.object_version_number;
      END IF;
      IF (x_ajlv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.sfwt_flag := l_ajlv_rec.sfwt_flag;
      END IF;
      IF (x_ajlv_rec.adj_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.adj_id := l_ajlv_rec.adj_id;
      END IF;
       IF (x_ajlv_rec.khr_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.khr_id := l_ajlv_rec.khr_id;
      END IF;
       IF (x_ajlv_rec.kle_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.kle_id := l_ajlv_rec.kle_id;
      END IF;
       IF (x_ajlv_rec.sty_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.sty_id := l_ajlv_rec.sty_id;
      END IF;
      IF (x_ajlv_rec.til_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.til_id := l_ajlv_rec.til_id;
      END IF;
      IF (x_ajlv_rec.tld_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.tld_id := l_ajlv_rec.tld_id;
      END IF;
      IF (x_ajlv_rec.code_combination_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.code_combination_id := l_ajlv_rec.code_combination_id;
      END IF;
      IF (x_ajlv_rec.psl_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.psl_id := l_ajlv_rec.psl_id;
      END IF;
      IF (x_ajlv_rec.amount = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.amount := l_ajlv_rec.amount;
      END IF;
      IF (x_ajlv_rec.check_approval_limit_yn = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.check_approval_limit_yn := l_ajlv_rec.check_approval_limit_yn;
      END IF;
      IF (x_ajlv_rec.receivables_adjustment_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.receivables_adjustment_id := l_ajlv_rec.receivables_adjustment_id;
      END IF;
      IF (x_ajlv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute_category := l_ajlv_rec.attribute_category;
      END IF;
      IF (x_ajlv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute1 := l_ajlv_rec.attribute1;
      END IF;
      IF (x_ajlv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute2 := l_ajlv_rec.attribute2;
      END IF;
      IF (x_ajlv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute3 := l_ajlv_rec.attribute3;
      END IF;
      IF (x_ajlv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute4 := l_ajlv_rec.attribute4;
      END IF;
      IF (x_ajlv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute5 := l_ajlv_rec.attribute5;
      END IF;
      IF (x_ajlv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute6 := l_ajlv_rec.attribute6;
      END IF;
      IF (x_ajlv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute7 := l_ajlv_rec.attribute7;
      END IF;
      IF (x_ajlv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute8 := l_ajlv_rec.attribute8;
      END IF;
      IF (x_ajlv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute9 := l_ajlv_rec.attribute9;
      END IF;
      IF (x_ajlv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute10 := l_ajlv_rec.attribute10;
      END IF;
      IF (x_ajlv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute11 := l_ajlv_rec.attribute11;
      END IF;
      IF (x_ajlv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute12 := l_ajlv_rec.attribute12;
      END IF;
      IF (x_ajlv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute13 := l_ajlv_rec.attribute13;
      END IF;
      IF (x_ajlv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute14 := l_ajlv_rec.attribute14;
      END IF;
      IF (x_ajlv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_ajlv_rec.attribute15 := l_ajlv_rec.attribute15;
      END IF;
      IF (x_ajlv_rec.request_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.request_id := l_ajlv_rec.request_id;
      END IF;
      IF (x_ajlv_rec.program_application_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.program_application_id := l_ajlv_rec.program_application_id;
      END IF;
      IF (x_ajlv_rec.program_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.program_id := l_ajlv_rec.program_id;
      END IF;
      IF (x_ajlv_rec.program_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_ajlv_rec.program_update_date := l_ajlv_rec.program_update_date;
      END IF;
      IF (x_ajlv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.org_id := l_ajlv_rec.org_id;
      END IF;
      IF (x_ajlv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.created_by := l_ajlv_rec.created_by;
      END IF;
      IF (x_ajlv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_ajlv_rec.creation_date := l_ajlv_rec.creation_date;
      END IF;
      IF (x_ajlv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.last_updated_by := l_ajlv_rec.last_updated_by;
      END IF;
      IF (x_ajlv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_ajlv_rec.last_update_date := l_ajlv_rec.last_update_date;
      END IF;
      IF (x_ajlv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_ajlv_rec.last_update_login := l_ajlv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_TXL_ADJSTS_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ajlv_rec IN  ajlv_rec_type,
      x_ajlv_rec OUT NOCOPY ajlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ajlv_rec := p_ajlv_rec;
      x_ajlv_rec.OBJECT_VERSION_NUMBER := NVL(x_ajlv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      -- Begin Post-Generation Change
      SELECT
        NVL(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
            x_ajlv_rec.request_id),
        NVL(DECODE(Fnd_Global.PROG_APPL_ID,   -1,NULL,Fnd_Global.PROG_APPL_ID),
            x_ajlv_rec.program_application_id),
        NVL(DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
            x_ajlv_rec.program_id),
        DECODE(DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE),
            NULL,x_ajlv_rec.program_update_date,SYSDATE)
      INTO
        x_ajlv_rec.request_id,
        x_ajlv_rec.program_application_id,
        x_ajlv_rec.program_id,
        x_ajlv_rec.program_update_date
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
      p_ajlv_rec,                        -- IN
      l_ajlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ajlv_rec, l_def_ajlv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ajlv_rec := fill_who_columns(l_def_ajlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ajlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ajlv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ajlv_rec, l_okl_txl_adjsts_lns_tl_rec);
    migrate(l_def_ajlv_rec, l_ajl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_adjsts_lns_tl_rec,
      lx_okl_txl_adjsts_lns_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_txl_adjsts_lns_tl_rec, l_def_ajlv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ajl_rec,
      lx_ajl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ajl_rec, l_def_ajlv_rec);
    x_ajlv_rec := l_def_ajlv_rec;
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
  -- PL/SQL TBL update_row for:AJLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type,
    x_ajlv_tbl                     OUT NOCOPY ajlv_tbl_type) IS

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
    IF (p_ajlv_tbl.COUNT > 0) THEN
      i := p_ajlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ajlv_rec                     => p_ajlv_tbl(i),
          x_ajlv_rec                     => x_ajlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_ajlv_tbl.LAST);
        i := p_ajlv_tbl.NEXT(i);
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
  -----------------------------------------
  -- delete_row for:OKL_TXL_ADJSTS_LNS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajl_rec                      IN ajl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajl_rec                      ajl_rec_type:= p_ajl_rec;
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
    DELETE FROM OKL_TXL_ADJSTS_LNS_B
     WHERE ID = l_ajl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKL_TXL_ADJSTS_LNS_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_txl_adjsts_lns_tl_rec    IN okl_txl_adjsts_lns_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type:= p_okl_txl_adjsts_lns_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------------
    -- Set_Attributes for:OKL_TXL_ADJSTS_LNS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_txl_adjsts_lns_tl_rec IN  okl_txl_adjsts_lns_tl_rec_type,
      x_okl_txl_adjsts_lns_tl_rec OUT NOCOPY okl_txl_adjsts_lns_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_txl_adjsts_lns_tl_rec := p_okl_txl_adjsts_lns_tl_rec;
      x_okl_txl_adjsts_lns_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_txl_adjsts_lns_tl_rec,       -- IN
      l_okl_txl_adjsts_lns_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TXL_ADJSTS_LNS_TL
     WHERE ID = l_okl_txl_adjsts_lns_tl_rec.id;

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
  -- delete_row for:OKL_TXL_ADJSTS_LNS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_rec                     IN ajlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ajlv_rec                     ajlv_rec_type := p_ajlv_rec;
    l_okl_txl_adjsts_lns_tl_rec    okl_txl_adjsts_lns_tl_rec_type;
    l_ajl_rec                      ajl_rec_type;
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
    migrate(l_ajlv_rec, l_okl_txl_adjsts_lns_tl_rec);
    migrate(l_ajlv_rec, l_ajl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_txl_adjsts_lns_tl_rec
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
      l_ajl_rec
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
  -- PL/SQL TBL delete_row for:AJLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ajlv_tbl                     IN ajlv_tbl_type) IS

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
    IF (p_ajlv_tbl.COUNT > 0) THEN
      i := p_ajlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ajlv_rec                     => p_ajlv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_ajlv_tbl.LAST);
        i := p_ajlv_tbl.NEXT(i);
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
END OKL_AJL_PVT;

/
