--------------------------------------------------------
--  DDL for Package Body OKL_FPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FPR_PVT" AS
/* $Header: OKLSFPRB.pls 120.5 2007/01/09 08:42:28 abhsaxen noship $ */

  --Added by kthiruva for Pricing Enhancements
  G_INCORRECT_FUNC_TYPE CONSTANT VARCHAR2(200) := 'OKL_FUNC_PARM_INCORRECT_FUNC';
  --End of Changes for Pricing Enhancements
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
    DELETE FROM OKL_FNCTN_PRMTRS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_FNCTN_PRMTRS_B B     --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

    UPDATE OKL_FNCTN_PRMTRS_TL T SET (
        VALUE,
        INSTRUCTIONS) = (SELECT
                                  B.VALUE,
                                  B.INSTRUCTIONS
                                FROM OKL_FNCTN_PRMTRS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_FNCTN_PRMTRS_TL SUBB, OKL_FNCTN_PRMTRS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.VALUE <> SUBT.VALUE
                      OR SUBB.INSTRUCTIONS <> SUBT.INSTRUCTIONS
                      OR (SUBB.VALUE IS NULL AND SUBT.VALUE IS NOT NULL)
                      OR (SUBB.VALUE IS NOT NULL AND SUBT.VALUE IS NULL)
                      OR (SUBB.INSTRUCTIONS IS NULL AND SUBT.INSTRUCTIONS IS NOT NULL)
                      OR (SUBB.INSTRUCTIONS IS NOT NULL AND SUBT.INSTRUCTIONS IS NULL)
              ));

    INSERT INTO OKL_FNCTN_PRMTRS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        VALUE,
        INSTRUCTIONS,
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
            B.VALUE,
            B.INSTRUCTIONS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_FNCTN_PRMTRS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_FNCTN_PRMTRS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FNCTN_PRMTRS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fpr_rec                      IN fpr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fpr_rec_type IS
    CURSOR okl_fnctn_prmtrs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            DSF_ID,
            PMR_ID,
            FPR_TYPE,
            OBJECT_VERSION_NUMBER,
            SEQUENCE_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Fnctn_Prmtrs_B
     WHERE okl_fnctn_prmtrs_b.id = p_id;
    l_okl_fnctn_prmtrs_b_pk        okl_fnctn_prmtrs_b_pk_csr%ROWTYPE;
    l_fpr_rec                      fpr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_fnctn_prmtrs_b_pk_csr (p_fpr_rec.id);
    FETCH okl_fnctn_prmtrs_b_pk_csr INTO
              l_fpr_rec.ID,
              l_fpr_rec.DSF_ID,
              l_fpr_rec.PMR_ID,
              l_fpr_rec.FPR_TYPE,
              l_fpr_rec.OBJECT_VERSION_NUMBER,
              l_fpr_rec.SEQUENCE_NUMBER,
              l_fpr_rec.CREATED_BY,
              l_fpr_rec.CREATION_DATE,
              l_fpr_rec.LAST_UPDATED_BY,
              l_fpr_rec.LAST_UPDATE_DATE,
              l_fpr_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_fnctn_prmtrs_b_pk_csr%NOTFOUND;
    CLOSE okl_fnctn_prmtrs_b_pk_csr;
    RETURN(l_fpr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_fpr_rec                      IN fpr_rec_type
  ) RETURN fpr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fpr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FNCTN_PRMTRS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_fnctn_prmtrs_tl_rec      IN okl_fnctn_prmtrs_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_fnctn_prmtrs_tl_rec_type IS
    CURSOR okl_fnctn_prmtrs_tl_pk_csr (p_id                 IN NUMBER,
                                       p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            VALUE,
            INSTRUCTIONS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Fnctn_Prmtrs_Tl
     WHERE okl_fnctn_prmtrs_tl.id = p_id
       AND okl_fnctn_prmtrs_tl.LANGUAGE = p_language;
    l_okl_fnctn_prmtrs_tl_pk       okl_fnctn_prmtrs_tl_pk_csr%ROWTYPE;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_fnctn_prmtrs_tl_pk_csr (p_okl_fnctn_prmtrs_tl_rec.id,
                                     p_okl_fnctn_prmtrs_tl_rec.LANGUAGE);
    FETCH okl_fnctn_prmtrs_tl_pk_csr INTO
              l_okl_fnctn_prmtrs_tl_rec.ID,
              l_okl_fnctn_prmtrs_tl_rec.LANGUAGE,
              l_okl_fnctn_prmtrs_tl_rec.SOURCE_LANG,
              l_okl_fnctn_prmtrs_tl_rec.SFWT_FLAG,
              l_okl_fnctn_prmtrs_tl_rec.VALUE,
              l_okl_fnctn_prmtrs_tl_rec.INSTRUCTIONS,
              l_okl_fnctn_prmtrs_tl_rec.CREATED_BY,
              l_okl_fnctn_prmtrs_tl_rec.CREATION_DATE,
              l_okl_fnctn_prmtrs_tl_rec.LAST_UPDATED_BY,
              l_okl_fnctn_prmtrs_tl_rec.LAST_UPDATE_DATE,
              l_okl_fnctn_prmtrs_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_fnctn_prmtrs_tl_pk_csr%NOTFOUND;
    CLOSE okl_fnctn_prmtrs_tl_pk_csr;
    RETURN(l_okl_fnctn_prmtrs_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_fnctn_prmtrs_tl_rec      IN okl_fnctn_prmtrs_tl_rec_type
  ) RETURN okl_fnctn_prmtrs_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_fnctn_prmtrs_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_FNCTN_PRMTRS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fprv_rec                     IN fprv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fprv_rec_type IS
    CURSOR okl_fprv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            DSF_ID,
            PMR_ID,
            SEQUENCE_NUMBER,
            VALUE,
            INSTRUCTIONS,
            FPR_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Fnctn_Prmtrs_V
     WHERE okl_fnctn_prmtrs_v.id = p_id;
    l_okl_fprv_pk                  okl_fprv_pk_csr%ROWTYPE;
    l_fprv_rec                     fprv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_fprv_pk_csr (p_fprv_rec.id);
    FETCH okl_fprv_pk_csr INTO
              l_fprv_rec.ID,
              l_fprv_rec.OBJECT_VERSION_NUMBER,
              l_fprv_rec.SFWT_FLAG,
              l_fprv_rec.DSF_ID,
              l_fprv_rec.PMR_ID,
              l_fprv_rec.SEQUENCE_NUMBER,
              l_fprv_rec.VALUE,
              l_fprv_rec.INSTRUCTIONS,
              l_fprv_rec.FPR_TYPE,
              l_fprv_rec.CREATED_BY,
              l_fprv_rec.CREATION_DATE,
              l_fprv_rec.LAST_UPDATED_BY,
              l_fprv_rec.LAST_UPDATE_DATE,
              l_fprv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_fprv_pk_csr%NOTFOUND;
    CLOSE okl_fprv_pk_csr;
    RETURN(l_fprv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_fprv_rec                     IN fprv_rec_type
  ) RETURN fprv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fprv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_FNCTN_PRMTRS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_fprv_rec	IN fprv_rec_type
  ) RETURN fprv_rec_type IS
    l_fprv_rec	fprv_rec_type := p_fprv_rec;
  BEGIN
    IF (l_fprv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_fprv_rec.object_version_number := NULL;
    END IF;
    IF (l_fprv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR) THEN
      l_fprv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_fprv_rec.dsf_id = Okc_Api.G_MISS_NUM) THEN
      l_fprv_rec.dsf_id := NULL;
    END IF;
    IF (l_fprv_rec.pmr_id = Okc_Api.G_MISS_NUM) THEN
      l_fprv_rec.pmr_id := NULL;
    END IF;
    IF (l_fprv_rec.sequence_number = Okc_Api.G_MISS_NUM) THEN
      l_fprv_rec.sequence_number := NULL;
    END IF;
    IF (l_fprv_rec.value = Okc_Api.G_MISS_CHAR) THEN
      l_fprv_rec.value := NULL;
    END IF;
    IF (l_fprv_rec.instructions = Okc_Api.G_MISS_CHAR) THEN
      l_fprv_rec.instructions := NULL;
    END IF;
    IF (l_fprv_rec.fpr_type = Okc_Api.G_MISS_CHAR) THEN
      l_fprv_rec.fpr_type := NULL;
    END IF;
    IF (l_fprv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_fprv_rec.created_by := NULL;
    END IF;
    IF (l_fprv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_fprv_rec.creation_date := NULL;
    END IF;
    IF (l_fprv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_fprv_rec.last_updated_by := NULL;
    END IF;
    IF (l_fprv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_fprv_rec.last_update_date := NULL;
    END IF;
    IF (l_fprv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_fprv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_fprv_rec);
  END null_out_defaults;

  -- START change : mvasudev , 05/02/2001
  /*
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_FNCTN_PRMTRS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_fprv_rec IN  fprv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_fprv_rec.id = OKC_API.G_MISS_NUM OR
       p_fprv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fprv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_fprv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fprv_rec.dsf_id = OKC_API.G_MISS_NUM OR
          p_fprv_rec.dsf_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dsf_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fprv_rec.pmr_id = OKC_API.G_MISS_NUM OR
          p_fprv_rec.pmr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pmr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fprv_rec.fpr_type = OKC_API.G_MISS_CHAR OR
          p_fprv_rec.fpr_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fpr_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_FNCTN_PRMTRS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_fprv_rec IN fprv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  */

  /**
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id(
    p_fprv_rec      IN   fprv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_fprv_rec.id = Okc_Api.G_MISS_NUM OR
      p_fprv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_UNEXPECTED_ERROR
                       ,p_token1       => G_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(
    p_fprv_rec      IN   fprv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_fprv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_fprv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Dsf_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Dsf_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Dsf_Id(
    p_fprv_rec      IN   fprv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_FPR_DSF_FK;
  CURSOR okl_dsfv_pk_csr (p_id IN OKL_FNCTN_PRMTRS_V.dsf_id%TYPE) IS
  SELECT '1'
    FROM OKL_DATA_SRC_FNCTNS_V
   WHERE OKL_DATA_SRC_FNCTNS_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_fprv_rec.dsf_id = Okc_Api.G_MISS_NUM OR
       p_fprv_rec.dsf_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dsf_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_Dsfv_pk_csr(p_fprv_rec.dsf_id);
    FETCH okl_dsfv_pk_csr INTO l_dummy;
    l_row_not_found := okl_dsfv_pk_csr%NOTFOUND;
    CLOSE okl_dsfv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_KEY);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_dsfv_pk_csr%ISOPEN THEN
        CLOSE okl_dsfv_pk_csr;
      END IF;

  END Validate_Dsf_Id;

 --Added by kthiruva on 08-Jun-2005 for Pricing Enhancements
   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Func_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Func_Code
  -- Description     : This procedure checks if the Fucntion Code is valid.
  --                   Only if the function code of a function is 'PLSQL'
  --                   can function parameters be defined for it.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Func_Code(
    p_fprv_rec      IN   fprv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_FPR_DSF_FK;
  CURSOR okl_dsfv_pk_csr (p_id IN OKL_FNCTN_PRMTRS_V.dsf_id%TYPE) IS
  SELECT '1'
    FROM OKL_DATA_SRC_FNCTNS_V
   WHERE OKL_DATA_SRC_FNCTNS_V.id = p_id
   AND OKL_DATA_SRC_FNCTNS_V.FNCTN_CODE = 'PLSQL';

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    OPEN okl_Dsfv_pk_csr(p_fprv_rec.dsf_id);
    FETCH okl_dsfv_pk_csr INTO l_dummy;
    l_row_not_found := okl_dsfv_pk_csr%NOTFOUND;
    CLOSE okl_dsfv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INCORRECT_FUNC_TYPE);
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_dsfv_pk_csr%ISOPEN THEN
        CLOSE okl_dsfv_pk_csr;
      END IF;

  END Validate_Func_Code;

 -- Bug 4421600 - End of Changes for Pricing Enhancements

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sfwt_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sfwt_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sfwt_Flag(p_fprv_rec      IN   fprv_rec_type,
								x_return_status OUT NOCOPY  VARCHAR2)
  IS

  -- l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  l_return_status         VARCHAR2(1)  := OKL_API.G_TRUE;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check from domain values using the generic
      -- l_return_status := Okl_Util.check_domain_yn(p_fprv_rec.sfwt_flag);
      l_return_status := OKL_ACCOUNTING_UTIL.validate_lookup_code('YES_NO',p_fprv_rec.sfwt_flag,0,0);

      -- IF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      IF (l_return_status = OKL_API.G_FALSE) THEN
	          Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                             p_msg_name         => g_invalid_value,
                             p_token1           => g_col_name_token,
                             p_token1_value     => 'sfwt_flag');
                  x_return_status := Okc_Api.G_RET_STS_ERROR;
      END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM );

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Sfwt_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pmr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Pmr_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pmr_Id(
    p_fprv_rec      IN   fprv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_FPR_PMR_FK;
  CURSOR okl_pmrv_pk_csr (p_id IN OKL_FNCTN_PRMTRS_V.pmr_id%TYPE) IS
  SELECT '1'
    FROM OKL_PARAMETERS_V
   WHERE OKL_PARAMETERS_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	-- RPOONUGA001: Modified the if condition to check the validility
	-- in the case of valid pmr_id passed
    IF p_fprv_rec.pmr_id <> Okc_Api.G_MISS_NUM AND
       p_fprv_rec.pmr_id IS NOT NULL
    THEN
    	OPEN okl_pmrv_pk_csr(p_fprv_rec.pmr_id);
    	FETCH okl_pmrv_pk_csr INTO l_dummy;
    	l_row_not_found := okl_pmrv_pk_csr%NOTFOUND;
    	CLOSE okl_pmrv_pk_csr;

    	IF l_row_not_found THEN
      	   Okc_Api.set_message(G_APP_NAME,G_INVALID_KEY);
      	   x_return_status := Okc_Api.G_RET_STS_ERROR;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_pmrv_pk_csr%ISOPEN THEN
        CLOSE okl_pmrv_pk_csr;
      END IF;

  END Validate_Pmr_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Fpr_Type
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Fpr_Type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 2.0
  -- Modifications	 : This procedure is modified to check the values with
  -- 				   fnd_common_lookups and also cross validate the values
  --				   in pmr_id and value attributes(RPOONUGA001)
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Fpr_Type(
    p_fprv_rec      IN   fprv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  l_dummy                 VARCHAR2(1) := '?';
  -- l_row_not_found             Boolean := False;
  l_row_found             VARCHAR2(1) := OKL_API.G_TRUE;

  -- Cursor For OKL_FMA_FYP_FK - Foreign Key Constraint
/*
  CURSOR okl_fprv_fk_csr (p_code IN OKL_FNCTN_PRMTRS_V.fpr_type%TYPE) IS
  SELECT '1'
    FROM fnd_common_lookups
   WHERE fnd_common_lookups.lookup_code = p_code
   AND   fnd_common_lookups.lookup_type = 'OKL_FUNCTION_PMR_TYPE';
*/

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF p_fprv_rec.fpr_type = Okc_Api.G_MISS_CHAR OR
       p_fprv_rec.fpr_type IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'fpr_type');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/*
    OPEN okl_fprv_fk_csr(p_fprv_rec.fpr_type);
    FETCH okl_fprv_fk_csr INTO l_dummy;
    l_row_not_found := okl_fprv_fk_csr%NOTFOUND;
    CLOSE okl_fprv_fk_csr;
*/

    l_row_found := OKL_ACCOUNTING_UTIL.validate_lookup_code('OKL_FUNCTION_PMR_TYPE',p_fprv_rec.fpr_type);
    -- IF l_row_not_found then
    IF (l_row_found = OKL_API.G_FALSE) then
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'fpr_type');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

	IF p_fprv_rec.fpr_type = G_STATIC_TYPE AND (p_fprv_rec.value = OKL_API.G_MISS_CHAR OR
	   						  				  	  p_fprv_rec.value IS NULL)
    THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_MISS_DATA,
						   p_token1			=> G_COL_NAME_TOKEN,
						   p_token1_value	=> 'VALUE');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	IF p_fprv_rec.fpr_type = G_CONTEXT_TYPE AND (p_fprv_rec.pmr_id = OKL_API.G_MISS_NUM OR
	   						  				  	 p_fprv_rec.pmr_id IS NULL)
    THEN
	   OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
						   p_msg_name		=> G_MISS_DATA,
						   p_token1			=> G_COL_NAME_TOKEN,
						   p_token1_value	=> 'PMR_ID');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Fpr_Type;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_fprv_rec IN  fprv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sfwt_Flag
    Validate_Sfwt_Flag(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Dsf_id
    Validate_Dsf_id(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Added by kthiruva on 08-Jun-2005 for Pricing Enhancements
    -- Bug 4421600 - Start of Changes
    -- Validate_Func_Code
    Validate_Func_Code(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
    --Bug 4421600 - End of Changes for Pricing Enhancements

	-- RPOONUGA001: Moved the code above validate_pmr_id
    -- Validate_Fpr_Type
    Validate_Fpr_Type(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Pmr_Id
    Validate_Pmr_Id(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;
  RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Fpr_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Fpr_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Fpr_Record(p_fprv_rec      IN      fprv_rec_type
                                       ,x_return_status OUT NOCOPY     VARCHAR2)
  IS

  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;

  -- Cursor for FOD Unique Key
  CURSOR okl_fpr_uk_csr(p_rec fprv_rec_type) IS
  SELECT '1'
  FROM OKL_FNCTN_PRMTRS_V
  WHERE  dsf_id =  p_rec.dsf_id
    AND  pmr_id =  p_rec.pmr_id
    AND  id     <> NVL(p_rec.id,-9999);

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    OPEN okl_fpr_uk_csr(p_fprv_rec);
    FETCH okl_fpr_uk_csr INTO l_dummy;
    l_row_found := okl_fpr_uk_csr%FOUND;
    CLOSE okl_fpr_uk_csr;
    IF l_row_found THEN
	Okc_Api.set_message(G_APP_NAME,G_UNQS, G_TABLE_TOKEN, 'Okl_Fnctn_Prmtrs_V');
	x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Fpr_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_fprv_rec IN fprv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_Fpr_Record
    Validate_Unique_Fpr_Record(p_fprv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN fprv_rec_type,
	-- START change : mvasudev, 05/15/2001
	-- Changing OUT Parameter to IN OUT
    -- p_to	OUT NOCOPY fpr_rec_type
    p_to	IN OUT NOCOPY fpr_rec_type
	-- END change : mvasudev
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.dsf_id := p_from.dsf_id;
    p_to.pmr_id := p_from.pmr_id;
    p_to.fpr_type := p_from.fpr_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN fpr_rec_type,
	-- START change : mvasudev, 05/15/2001
	-- Changing OUT Parameter to IN OUT
    --p_to	OUT NOCOPY fprv_rec_type
    p_to	IN OUT NOCOPY fprv_rec_type
	-- END change : mvasudev
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.dsf_id := p_from.dsf_id;
    p_to.pmr_id := p_from.pmr_id;
    p_to.fpr_type := p_from.fpr_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sequence_number := p_from.sequence_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN fprv_rec_type,
    p_to	OUT NOCOPY okl_fnctn_prmtrs_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.value := p_from.value;
    p_to.instructions := p_from.instructions;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_fnctn_prmtrs_tl_rec_type,
    p_to	OUT NOCOPY fprv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.value := p_from.value;
    p_to.instructions := p_from.instructions;
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
  -- validate_row for:OKL_FNCTN_PRMTRS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fprv_rec                     fprv_rec_type := p_fprv_rec;
    l_fpr_rec                      fpr_rec_type;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_fprv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_fprv_rec);
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
  -- PL/SQL TBL validate_row for:FPRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fprv_tbl.COUNT > 0) THEN
      i := p_fprv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fprv_rec                     => p_fprv_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_fprv_tbl.LAST);
        i := p_fprv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  ---------------------------------------
  -- insert_row for:OKL_FNCTN_PRMTRS_B --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fpr_rec                      IN fpr_rec_type,
    x_fpr_rec                      OUT NOCOPY fpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fpr_rec                      fpr_rec_type := p_fpr_rec;
    l_def_fpr_rec                  fpr_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_FNCTN_PRMTRS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_fpr_rec IN  fpr_rec_type,
      x_fpr_rec OUT NOCOPY fpr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_fpr_rec := p_fpr_rec;
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
      p_fpr_rec,                         -- IN
      l_fpr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_FNCTN_PRMTRS_B(
        id,
        dsf_id,
        pmr_id,
        fpr_type,
        object_version_number,
        sequence_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_fpr_rec.id,
        l_fpr_rec.dsf_id,
        l_fpr_rec.pmr_id,
        l_fpr_rec.fpr_type,
        l_fpr_rec.object_version_number,
        l_fpr_rec.sequence_number,
        l_fpr_rec.created_by,
        l_fpr_rec.creation_date,
        l_fpr_rec.last_updated_by,
        l_fpr_rec.last_update_date,
        l_fpr_rec.last_update_login);
    -- Set OUT values
    x_fpr_rec := l_fpr_rec;
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
  -- insert_row for:OKL_FNCTN_PRMTRS_TL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_fnctn_prmtrs_tl_rec      IN okl_fnctn_prmtrs_tl_rec_type,
    x_okl_fnctn_prmtrs_tl_rec      OUT NOCOPY okl_fnctn_prmtrs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type := p_okl_fnctn_prmtrs_tl_rec;
    ldefoklfnctnprmtrstlrec        okl_fnctn_prmtrs_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    --------------------------------------------
    -- Set_Attributes for:OKL_FNCTN_PRMTRS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_fnctn_prmtrs_tl_rec IN  okl_fnctn_prmtrs_tl_rec_type,
      x_okl_fnctn_prmtrs_tl_rec OUT NOCOPY okl_fnctn_prmtrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_fnctn_prmtrs_tl_rec := p_okl_fnctn_prmtrs_tl_rec;
      x_okl_fnctn_prmtrs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_fnctn_prmtrs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_fnctn_prmtrs_tl_rec,         -- IN
      l_okl_fnctn_prmtrs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_fnctn_prmtrs_tl_rec.LANGUAGE := l_lang_rec.language_code;
      INSERT INTO OKL_FNCTN_PRMTRS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          value,
          instructions,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_fnctn_prmtrs_tl_rec.id,
          l_okl_fnctn_prmtrs_tl_rec.LANGUAGE,
          l_okl_fnctn_prmtrs_tl_rec.source_lang,
          l_okl_fnctn_prmtrs_tl_rec.sfwt_flag,
          l_okl_fnctn_prmtrs_tl_rec.value,
          l_okl_fnctn_prmtrs_tl_rec.instructions,
          l_okl_fnctn_prmtrs_tl_rec.created_by,
          l_okl_fnctn_prmtrs_tl_rec.creation_date,
          l_okl_fnctn_prmtrs_tl_rec.last_updated_by,
          l_okl_fnctn_prmtrs_tl_rec.last_update_date,
          l_okl_fnctn_prmtrs_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_fnctn_prmtrs_tl_rec := l_okl_fnctn_prmtrs_tl_rec;
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
  ---------------------------------------
  -- insert_row for:OKL_FNCTN_PRMTRS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fprv_rec                     fprv_rec_type;
    l_def_fprv_rec                 fprv_rec_type;
    l_fpr_rec                      fpr_rec_type;
    lx_fpr_rec                     fpr_rec_type;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type;
    lx_okl_fnctn_prmtrs_tl_rec     okl_fnctn_prmtrs_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fprv_rec	IN fprv_rec_type
    ) RETURN fprv_rec_type IS
      l_fprv_rec	fprv_rec_type := p_fprv_rec;
    BEGIN
      l_fprv_rec.CREATION_DATE := SYSDATE;
      l_fprv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_fprv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_fprv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_fprv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_fprv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_FNCTN_PRMTRS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_fprv_rec IN  fprv_rec_type,
      x_fprv_rec OUT NOCOPY fprv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_fprv_rec := p_fprv_rec;
      x_fprv_rec.OBJECT_VERSION_NUMBER := 1;
      x_fprv_rec.SFWT_FLAG := 'N';
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
    l_fprv_rec := null_out_defaults(p_fprv_rec);
    -- Set primary key value
    l_fprv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_fprv_rec,                        -- IN
      l_def_fprv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_fprv_rec := fill_who_columns(l_def_fprv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fprv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fprv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_fprv_rec, l_fpr_rec);
    migrate(l_def_fprv_rec, l_okl_fnctn_prmtrs_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fpr_rec,
      lx_fpr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fpr_rec, l_def_fprv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_fnctn_prmtrs_tl_rec,
      lx_okl_fnctn_prmtrs_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_fnctn_prmtrs_tl_rec, l_def_fprv_rec);
    -- Set OUT values
    x_fprv_rec := l_def_fprv_rec;
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
  -- PL/SQL TBL insert_row for:FPRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fprv_tbl.COUNT > 0) THEN
      i := p_fprv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fprv_rec                     => p_fprv_tbl(i),
          x_fprv_rec                     => x_fprv_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
		-- END change : mvasudev
        EXIT WHEN (i = p_fprv_tbl.LAST);
        i := p_fprv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  -------------------------------------
  -- lock_row for:OKL_FNCTN_PRMTRS_B --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fpr_rec                      IN fpr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_fpr_rec IN fpr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FNCTN_PRMTRS_B
     WHERE ID = p_fpr_rec.id
       AND OBJECT_VERSION_NUMBER = p_fpr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_fpr_rec IN fpr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FNCTN_PRMTRS_B
    WHERE ID = p_fpr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_FNCTN_PRMTRS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_FNCTN_PRMTRS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_fpr_rec);
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
      OPEN lchk_csr(p_fpr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_fpr_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_fpr_rec.object_version_number THEN
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
  -- lock_row for:OKL_FNCTN_PRMTRS_TL --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_fnctn_prmtrs_tl_rec      IN okl_fnctn_prmtrs_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_fnctn_prmtrs_tl_rec IN okl_fnctn_prmtrs_tl_rec_type) IS
    SELECT *
      FROM OKL_FNCTN_PRMTRS_TL
     WHERE ID = p_okl_fnctn_prmtrs_tl_rec.id
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
      OPEN lock_csr(p_okl_fnctn_prmtrs_tl_rec);
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
  -------------------------------------
  -- lock_row for:OKL_FNCTN_PRMTRS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fpr_rec                      fpr_rec_type;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type;
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
    migrate(p_fprv_rec, l_fpr_rec);
    migrate(p_fprv_rec, l_okl_fnctn_prmtrs_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fpr_rec
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
      l_okl_fnctn_prmtrs_tl_rec
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
  -- PL/SQL TBL lock_row for:FPRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fprv_tbl.COUNT > 0) THEN
      i := p_fprv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fprv_rec                     => p_fprv_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
		-- END change : mvasudev
        EXIT WHEN (i = p_fprv_tbl.LAST);
        i := p_fprv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  ---------------------------------------
  -- update_row for:OKL_FNCTN_PRMTRS_B --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fpr_rec                      IN fpr_rec_type,
    x_fpr_rec                      OUT NOCOPY fpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fpr_rec                      fpr_rec_type := p_fpr_rec;
    l_def_fpr_rec                  fpr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fpr_rec	IN fpr_rec_type,
      x_fpr_rec	OUT NOCOPY fpr_rec_type
    ) RETURN VARCHAR2 IS
      l_fpr_rec                      fpr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_fpr_rec := p_fpr_rec;
      -- Get current database values
      l_fpr_rec := get_rec(p_fpr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_fpr_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.id := l_fpr_rec.id;
      END IF;
      IF (x_fpr_rec.dsf_id = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.dsf_id := l_fpr_rec.dsf_id;
      END IF;
      IF (x_fpr_rec.pmr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.pmr_id := l_fpr_rec.pmr_id;
      END IF;
      IF (x_fpr_rec.fpr_type = Okc_Api.G_MISS_CHAR)
      THEN
        x_fpr_rec.fpr_type := l_fpr_rec.fpr_type;
      END IF;
      IF (x_fpr_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.object_version_number := l_fpr_rec.object_version_number;
      END IF;
      IF (x_fpr_rec.sequence_number = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.sequence_number := l_fpr_rec.sequence_number;
      END IF;
      IF (x_fpr_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.created_by := l_fpr_rec.created_by;
      END IF;
      IF (x_fpr_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_fpr_rec.creation_date := l_fpr_rec.creation_date;
      END IF;
      IF (x_fpr_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.last_updated_by := l_fpr_rec.last_updated_by;
      END IF;
      IF (x_fpr_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_fpr_rec.last_update_date := l_fpr_rec.last_update_date;
      END IF;
      IF (x_fpr_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_fpr_rec.last_update_login := l_fpr_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_FNCTN_PRMTRS_B --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_fpr_rec IN  fpr_rec_type,
      x_fpr_rec OUT NOCOPY fpr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_fpr_rec := p_fpr_rec;
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
      p_fpr_rec,                         -- IN
      l_fpr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fpr_rec, l_def_fpr_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_FNCTN_PRMTRS_B
    SET DSF_ID = l_def_fpr_rec.dsf_id,
        PMR_ID = l_def_fpr_rec.pmr_id,
        FPR_TYPE = l_def_fpr_rec.fpr_type,
        OBJECT_VERSION_NUMBER = l_def_fpr_rec.object_version_number,
        SEQUENCE_NUMBER = l_def_fpr_rec.sequence_number,
        CREATED_BY = l_def_fpr_rec.created_by,
        CREATION_DATE = l_def_fpr_rec.creation_date,
        LAST_UPDATED_BY = l_def_fpr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_fpr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_fpr_rec.last_update_login
    WHERE ID = l_def_fpr_rec.id;

    x_fpr_rec := l_def_fpr_rec;
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
  -- update_row for:OKL_FNCTN_PRMTRS_TL --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_fnctn_prmtrs_tl_rec      IN okl_fnctn_prmtrs_tl_rec_type,
    x_okl_fnctn_prmtrs_tl_rec      OUT NOCOPY okl_fnctn_prmtrs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type := p_okl_fnctn_prmtrs_tl_rec;
    ldefoklfnctnprmtrstlrec        okl_fnctn_prmtrs_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_fnctn_prmtrs_tl_rec	IN okl_fnctn_prmtrs_tl_rec_type,
      x_okl_fnctn_prmtrs_tl_rec	OUT NOCOPY okl_fnctn_prmtrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_fnctn_prmtrs_tl_rec := p_okl_fnctn_prmtrs_tl_rec;
      -- Get current database values
      l_okl_fnctn_prmtrs_tl_rec := get_rec(p_okl_fnctn_prmtrs_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.id := l_okl_fnctn_prmtrs_tl_rec.id;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.LANGUAGE = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.LANGUAGE := l_okl_fnctn_prmtrs_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.source_lang = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.source_lang := l_okl_fnctn_prmtrs_tl_rec.source_lang;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.sfwt_flag := l_okl_fnctn_prmtrs_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.value = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.value := l_okl_fnctn_prmtrs_tl_rec.value;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.instructions = Okc_Api.G_MISS_CHAR)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.instructions := l_okl_fnctn_prmtrs_tl_rec.instructions;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.created_by := l_okl_fnctn_prmtrs_tl_rec.created_by;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.creation_date := l_okl_fnctn_prmtrs_tl_rec.creation_date;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.last_updated_by := l_okl_fnctn_prmtrs_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.last_update_date := l_okl_fnctn_prmtrs_tl_rec.last_update_date;
      END IF;
      IF (x_okl_fnctn_prmtrs_tl_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_okl_fnctn_prmtrs_tl_rec.last_update_login := l_okl_fnctn_prmtrs_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_FNCTN_PRMTRS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_fnctn_prmtrs_tl_rec IN  okl_fnctn_prmtrs_tl_rec_type,
      x_okl_fnctn_prmtrs_tl_rec OUT NOCOPY okl_fnctn_prmtrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_fnctn_prmtrs_tl_rec := p_okl_fnctn_prmtrs_tl_rec;
      x_okl_fnctn_prmtrs_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_fnctn_prmtrs_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_fnctn_prmtrs_tl_rec,         -- IN
      l_okl_fnctn_prmtrs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_fnctn_prmtrs_tl_rec, ldefoklfnctnprmtrstlrec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_FNCTN_PRMTRS_TL
    SET VALUE = ldefoklfnctnprmtrstlrec.value,
        INSTRUCTIONS = ldefoklfnctnprmtrstlrec.instructions,
        CREATED_BY = ldefoklfnctnprmtrstlrec.created_by,
        SOURCE_LANG = ldefoklfnctnprmtrstlrec.source_lang,
        CREATION_DATE = ldefoklfnctnprmtrstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklfnctnprmtrstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklfnctnprmtrstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklfnctnprmtrstlrec.last_update_login
    WHERE ID = ldefoklfnctnprmtrstlrec.id
      AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_FNCTN_PRMTRS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklfnctnprmtrstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_fnctn_prmtrs_tl_rec := ldefoklfnctnprmtrstlrec;
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
  ---------------------------------------
  -- update_row for:OKL_FNCTN_PRMTRS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type,
    x_fprv_rec                     OUT NOCOPY fprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fprv_rec                     fprv_rec_type := p_fprv_rec;
    l_def_fprv_rec                 fprv_rec_type;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type;
    lx_okl_fnctn_prmtrs_tl_rec     okl_fnctn_prmtrs_tl_rec_type;
    l_fpr_rec                      fpr_rec_type;
    lx_fpr_rec                     fpr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fprv_rec	IN fprv_rec_type
    ) RETURN fprv_rec_type IS
      l_fprv_rec	fprv_rec_type := p_fprv_rec;
    BEGIN
      l_fprv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_fprv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_fprv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_fprv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fprv_rec	IN fprv_rec_type,
      x_fprv_rec	OUT NOCOPY fprv_rec_type
    ) RETURN VARCHAR2 IS
      l_fprv_rec                     fprv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_fprv_rec := p_fprv_rec;
      -- Get current database values
      l_fprv_rec := get_rec(p_fprv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_fprv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.id := l_fprv_rec.id;
      END IF;
      IF (x_fprv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.object_version_number := l_fprv_rec.object_version_number;
      END IF;
      IF (x_fprv_rec.sfwt_flag = Okc_Api.G_MISS_CHAR)
      THEN
        x_fprv_rec.sfwt_flag := l_fprv_rec.sfwt_flag;
      END IF;
      IF (x_fprv_rec.dsf_id = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.dsf_id := l_fprv_rec.dsf_id;
      END IF;
      IF (x_fprv_rec.pmr_id = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.pmr_id := l_fprv_rec.pmr_id;
      END IF;
      IF (x_fprv_rec.sequence_number = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.sequence_number := l_fprv_rec.sequence_number;
      END IF;
      IF (x_fprv_rec.value = Okc_Api.G_MISS_CHAR)
      THEN
        x_fprv_rec.value := l_fprv_rec.value;
      END IF;
      IF (x_fprv_rec.instructions = Okc_Api.G_MISS_CHAR)
      THEN
        x_fprv_rec.instructions := l_fprv_rec.instructions;
      END IF;
      IF (x_fprv_rec.fpr_type = Okc_Api.G_MISS_CHAR)
      THEN
        x_fprv_rec.fpr_type := l_fprv_rec.fpr_type;
      END IF;
      IF (x_fprv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.created_by := l_fprv_rec.created_by;
      END IF;
      IF (x_fprv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_fprv_rec.creation_date := l_fprv_rec.creation_date;
      END IF;
      IF (x_fprv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.last_updated_by := l_fprv_rec.last_updated_by;
      END IF;
      IF (x_fprv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_fprv_rec.last_update_date := l_fprv_rec.last_update_date;
      END IF;
      IF (x_fprv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_fprv_rec.last_update_login := l_fprv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_FNCTN_PRMTRS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_fprv_rec IN  fprv_rec_type,
      x_fprv_rec OUT NOCOPY fprv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_fprv_rec := p_fprv_rec;
      x_fprv_rec.OBJECT_VERSION_NUMBER := NVL(x_fprv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_fprv_rec,                        -- IN
      l_fprv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fprv_rec, l_def_fprv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_fprv_rec := fill_who_columns(l_def_fprv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fprv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fprv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_fprv_rec, l_okl_fnctn_prmtrs_tl_rec);
    migrate(l_def_fprv_rec, l_fpr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_fnctn_prmtrs_tl_rec,
      lx_okl_fnctn_prmtrs_tl_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_fnctn_prmtrs_tl_rec, l_def_fprv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fpr_rec,
      lx_fpr_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fpr_rec, l_def_fprv_rec);
    x_fprv_rec := l_def_fprv_rec;
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
  -- PL/SQL TBL update_row for:FPRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type,
    x_fprv_tbl                     OUT NOCOPY fprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fprv_tbl.COUNT > 0) THEN
      i := p_fprv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fprv_rec                     => p_fprv_tbl(i),
          x_fprv_rec                     => x_fprv_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_fprv_tbl.LAST);
        i := p_fprv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  ---------------------------------------
  -- delete_row for:OKL_FNCTN_PRMTRS_B --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fpr_rec                      IN fpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fpr_rec                      fpr_rec_type:= p_fpr_rec;
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
    DELETE FROM OKL_FNCTN_PRMTRS_B
     WHERE ID = l_fpr_rec.id;

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
  -- delete_row for:OKL_FNCTN_PRMTRS_TL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_fnctn_prmtrs_tl_rec      IN okl_fnctn_prmtrs_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type:= p_okl_fnctn_prmtrs_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    --------------------------------------------
    -- Set_Attributes for:OKL_FNCTN_PRMTRS_TL --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_fnctn_prmtrs_tl_rec IN  okl_fnctn_prmtrs_tl_rec_type,
      x_okl_fnctn_prmtrs_tl_rec OUT NOCOPY okl_fnctn_prmtrs_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_fnctn_prmtrs_tl_rec := p_okl_fnctn_prmtrs_tl_rec;
      x_okl_fnctn_prmtrs_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_fnctn_prmtrs_tl_rec,         -- IN
      l_okl_fnctn_prmtrs_tl_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_FNCTN_PRMTRS_TL
     WHERE ID = l_okl_fnctn_prmtrs_tl_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_FNCTN_PRMTRS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_rec                     IN fprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_fprv_rec                     fprv_rec_type := p_fprv_rec;
    l_okl_fnctn_prmtrs_tl_rec      okl_fnctn_prmtrs_tl_rec_type;
    l_fpr_rec                      fpr_rec_type;
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
    migrate(l_fprv_rec, l_okl_fnctn_prmtrs_tl_rec);
    migrate(l_fprv_rec, l_fpr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_fnctn_prmtrs_tl_rec
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
      l_fpr_rec
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
  -- PL/SQL TBL delete_row for:FPRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fprv_tbl                     IN fprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 05/15/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fprv_tbl.COUNT > 0) THEN
      i := p_fprv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fprv_rec                     => p_fprv_tbl(i));
    	-- START change : mvasudev, 05/15/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_fprv_tbl.LAST);
        i := p_fprv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 05/15/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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


 -------------------------------------------------------------------------------
  -- Procedure TRANSLATE_ROW
 -------------------------------------------------------------------------------

  PROCEDURE TRANSLATE_ROW(p_fprv_rec IN fprv_rec_type,
                          p_owner IN VARCHAR2,
                          p_last_update_date IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2) IS
   f_luby    NUMBER;  -- entity owner in file
   f_ludate  DATE;    -- entity update date in file
   db_luby     NUMBER;  -- entity owner in db
   db_ludate   DATE;    -- entity update date in db

   BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

     SELECT  LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO  db_luby, db_ludate
      FROM OKL_FNCTN_PRMTRS_TL
      where ID = to_number(p_fprv_rec.id)
      and USERENV('LANG') =language;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then

    	UPDATE OKL_FNCTN_PRMTRS_TL
    	SET	VALUE             = p_fprv_rec.value,
	    	INSTRUCTIONS      = p_fprv_rec.instructions,
        	LAST_UPDATE_DATE  = f_ludate,
        	LAST_UPDATED_BY   = f_luby,
        	LAST_UPDATE_LOGIN = 0,
        	SOURCE_LANG       = USERENV('LANG')
   	 WHERE ID = to_number(p_fprv_rec.id)
      	AND USERENV('LANG') IN (language,source_lang);
    END IF;
  END TRANSLATE_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_ROW(p_fprv_rec IN fprv_rec_type,
                     p_owner    IN VARCHAR2,
                     p_last_update_date IN VARCHAR2,
                     x_return_status OUT NOCOPY VARCHAR2) IS
    id        NUMBER;
    f_luby    NUMBER;  -- entity owner in file
    f_ludate  DATE;    -- entity update date in file
    db_luby   NUMBER;  -- entity owner in db
    db_ludate DATE;    -- entity update date in db
  BEGIN
    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(p_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

    BEGIN
      SELECT ID , LAST_UPDATED_BY, LAST_UPDATE_DATE
      INTO id, db_luby, db_ludate
      FROM OKL_FNCTN_PRMTRS_B
      where ID = p_fprv_rec.id;

      IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
         --Update _b
         UPDATE OKL_FNCTN_PRMTRS_B
         SET FPR_TYPE 		   = p_fprv_rec.fpr_type,
	        OBJECT_VERSION_NUMBER = TO_NUMBER(p_fprv_rec.object_version_number),
	        SEQUENCE_NUMBER	   = TO_NUMBER(p_fprv_rec.sequence_number),
            LAST_UPDATE_DATE      = f_ludate,
            LAST_UPDATED_BY       = f_luby,
            LAST_UPDATE_LOGIN     = 0
         WHERE ID = to_number(p_fprv_rec.id);
         --Update _TL

         UPDATE OKL_FNCTN_PRMTRS_TL
         SET VALUE             = p_fprv_rec.value,
	         INSTRUCTIONS      = p_fprv_rec.instructions,
             LAST_UPDATE_DATE  = f_ludate,
             LAST_UPDATED_BY   = f_luby,
             LAST_UPDATE_LOGIN = 0,
             SOURCE_LANG       = USERENV('LANG')
         WHERE ID = to_number(p_fprv_rec.id)
           AND USERENV('LANG') IN (language,source_lang);

         IF(sql%notfound) THEN
           INSERT INTO OKL_FNCTN_PRMTRS_TL
           (
           	ID,
           	LANGUAGE,
           	SOURCE_LANG,
           	SFWT_FLAG,
           	VALUE,
           	INSTRUCTIONS,
           	CREATED_BY,
           	CREATION_DATE,
           	LAST_UPDATED_BY,
           	LAST_UPDATE_DATE,
           	LAST_UPDATE_LOGIN
           	)
           	SELECT
              TO_NUMBER(p_fprv_rec.id),
              L.LANGUAGE_CODE,
              userenv('LANG'),
              decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
              p_fprv_rec.value,
              p_fprv_rec.instructions,
              f_luby,
              f_ludate,
              f_luby,
              f_ludate,
              0
            FROM FND_LANGUAGES L
             WHERE L.INSTALLED_FLAG IN ('I','B')
              AND NOT EXISTS
                     (SELECT NULL
                      FROM   OKL_FNCTN_PRMTRS_TL TL
                	  WHERE  TL.ID = TO_NUMBER(p_fprv_rec.id)
                      AND    TL.LANGUAGE = L.LANGUAGE_CODE);
         END IF;
      END IF;
    END;
    EXCEPTION
     when no_data_found then
       INSERT INTO OKL_FNCTN_PRMTRS_B
    	(
    	ID,
    	DSF_ID,
    	PMR_ID,
    	FPR_TYPE,
    	OBJECT_VERSION_NUMBER,
    	SEQUENCE_NUMBER,
    	CREATED_BY,
    	CREATION_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN
    	)
       VALUES(
    	TO_NUMBER(p_fprv_rec.id),
    	TO_NUMBER(p_fprv_rec.dsf_id),
    	TO_NUMBER(p_fprv_rec.pmr_id),
    	p_fprv_rec.fpr_type,
    	TO_NUMBER(p_fprv_rec.object_version_number),
    	TO_NUMBER(p_fprv_rec.sequence_number),
    	f_luby,
    	f_ludate,
    	f_luby,
    	f_ludate,
    	0);

      INSERT INTO OKL_FNCTN_PRMTRS_TL
	  (
    	ID,
    	LANGUAGE,
    	SOURCE_LANG,
    	SFWT_FLAG,
    	VALUE,
    	INSTRUCTIONS,
    	CREATED_BY,
    	CREATION_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATE_LOGIN
       )
      SELECT
       TO_NUMBER(p_fprv_rec.id),
       L.LANGUAGE_CODE,
       userenv('LANG'),
       decode(L.LANGUAGE_CODE,userenv('LANG'),'N','Y'),
       p_fprv_rec.value,
       p_fprv_rec.instructions,
       f_luby,
       f_ludate,
       f_luby,
       f_ludate,
       0
      FROM FND_LANGUAGES L
      WHERE L.INSTALLED_FLAG IN ('I','B')
       	AND NOT EXISTS
              (SELECT NULL
               FROM   OKL_FNCTN_PRMTRS_TL TL
         	   WHERE  TL.ID = TO_NUMBER(p_fprv_rec.id)
               AND    TL.LANGUAGE = L.LANGUAGE_CODE);
   END LOAD_ROW;

 -------------------------------------------------------------------------------
  -- Procedure LOAD_SEED_ROW
 -------------------------------------------------------------------------------

  PROCEDURE LOAD_SEED_ROW(
    p_upload_mode               IN VARCHAR2,
    p_fnctn_prmtr_id            IN VARCHAR2,
    p_dsf_id                    IN VARCHAR2,
    p_pmr_id                    IN VARCHAR2,
    p_fpr_type                  IN VARCHAR2,
    p_object_version_number     IN VARCHAR2,
    p_sequence_number           IN VARCHAR2,
    p_value                     IN VARCHAR2,
    p_instructions              IN VARCHAR2,
    p_owner                     IN VARCHAR2,
    p_last_update_date          IN VARCHAR2)IS

    l_api_version   CONSTANT number := 1;
    l_api_name      CONSTANT varchar2(30) := 'LOAD_SEED_ROW';
    l_return_status          varchar2(1) := okl_api.g_ret_sts_success;
    l_msg_count              number;
    l_msg_data               varchar2(4000);
    l_init_msg_list          VARCHAR2(1):= 'T';
    l_fprv_rec               fprv_rec_type;
  BEGIN
  --Prepare Record Structure for Insert/Update
    l_fprv_rec.id                      := p_fnctn_prmtr_id;
    l_fprv_rec.object_version_number   := p_object_version_number;
    l_fprv_rec.dsf_id                  := p_dsf_id;
    l_fprv_rec.pmr_id                  := p_pmr_id;
    l_fprv_rec.sequence_number         := p_sequence_number;
    l_fprv_rec.value                   := p_value;
    l_fprv_rec.instructions            := p_instructions;
    l_fprv_rec.fpr_type                := p_fpr_type;

   IF(p_upload_mode = 'NLS') then
	 OKL_FPR_PVT.TRANSLATE_ROW(p_fprv_rec => l_fprv_rec,
                               p_owner => p_owner,
                               p_last_update_date => p_last_update_date,
                               x_return_status => l_return_status);

   ELSE
	 OKL_FPR_PVT.LOAD_ROW(p_fprv_rec => l_fprv_rec,
                          p_owner => p_owner,
                          p_last_update_date => p_last_update_date,
                          x_return_status => l_return_status);

   END IF;
 END LOAD_SEED_ROW;

END Okl_Fpr_Pvt;

/
