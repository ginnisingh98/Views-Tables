--------------------------------------------------------
--  DDL for Package Body OKL_OVT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OVT_PVT" AS
/* $Header: OKLSOVTB.pls 115.10 2003/10/15 23:26:42 sgorantl noship $ */
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
  -- FUNCTION get_rec for: OKL_OVD_RUL_TMLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ovt_rec                      IN ovt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ovt_rec_type IS
    CURSOR okl_ovd_rul_tmls_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            RUL_ID,
            SEQUENCE_NUMBER,
            OVD_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ovd_Rul_Tmls
     WHERE okl_ovd_rul_tmls.id  = p_id;
    l_okl_ovd_rul_tmls_pk          okl_ovd_rul_tmls_pk_csr%ROWTYPE;
    l_ovt_rec                      ovt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ovd_rul_tmls_pk_csr (p_ovt_rec.id);
    FETCH okl_ovd_rul_tmls_pk_csr INTO
              l_ovt_rec.ID,
              l_ovt_rec.RUL_ID,
              l_ovt_rec.SEQUENCE_NUMBER,
              l_ovt_rec.OVD_ID,
              l_ovt_rec.OBJECT_VERSION_NUMBER,
              l_ovt_rec.CREATED_BY,
              l_ovt_rec.CREATION_DATE,
              l_ovt_rec.LAST_UPDATED_BY,
              l_ovt_rec.LAST_UPDATE_DATE,
              l_ovt_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ovd_rul_tmls_pk_csr%NOTFOUND;
    CLOSE okl_ovd_rul_tmls_pk_csr;
    RETURN(l_ovt_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ovt_rec                      IN ovt_rec_type
  ) RETURN ovt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ovt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OVD_RUL_TMLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ovtv_rec                     IN ovtv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ovtv_rec_type IS
    CURSOR okl_ovtv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OVD_ID,
            RUL_ID,
            SEQUENCE_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ovd_Rul_Tmls_V
     WHERE okl_ovd_rul_tmls_v.id = p_id;
    l_okl_ovtv_pk                  okl_ovtv_pk_csr%ROWTYPE;
    l_ovtv_rec                     ovtv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ovtv_pk_csr (p_ovtv_rec.id);
    FETCH okl_ovtv_pk_csr INTO
              l_ovtv_rec.ID,
              l_ovtv_rec.OBJECT_VERSION_NUMBER,
              l_ovtv_rec.OVD_ID,
              l_ovtv_rec.RUL_ID,
              l_ovtv_rec.SEQUENCE_NUMBER,
              l_ovtv_rec.CREATED_BY,
              l_ovtv_rec.CREATION_DATE,
              l_ovtv_rec.LAST_UPDATED_BY,
              l_ovtv_rec.LAST_UPDATE_DATE,
              l_ovtv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ovtv_pk_csr%NOTFOUND;
    CLOSE okl_ovtv_pk_csr;
    RETURN(l_ovtv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ovtv_rec                     IN ovtv_rec_type
  ) RETURN ovtv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ovtv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OVD_RUL_TMLS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ovtv_rec	IN ovtv_rec_type
  ) RETURN ovtv_rec_type IS
    l_ovtv_rec	ovtv_rec_type := p_ovtv_rec;
  BEGIN
    IF (l_ovtv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ovtv_rec.object_version_number := NULL;
    END IF;
    IF (l_ovtv_rec.ovd_id = OKC_API.G_MISS_NUM) THEN
      l_ovtv_rec.ovd_id := NULL;
    END IF;
    IF (l_ovtv_rec.rul_id = OKC_API.G_MISS_NUM) THEN
      l_ovtv_rec.rul_id := NULL;
    END IF;
    IF (l_ovtv_rec.sequence_number = OKC_API.G_MISS_NUM) THEN
      l_ovtv_rec.sequence_number := NULL;
    END IF;
    IF (l_ovtv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ovtv_rec.created_by := NULL;
    END IF;
    IF (l_ovtv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ovtv_rec.creation_date := NULL;
    END IF;
    IF (l_ovtv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ovtv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ovtv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ovtv_rec.last_update_date := NULL;
    END IF;
    IF (l_ovtv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ovtv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ovtv_rec);
  END null_out_defaults;

/**********************TCHGS: Commenting Old Code ******************************

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_OVD_RUL_TMLS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ovtv_rec IN  ovtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ovtv_rec.id = OKC_API.G_MISS_NUM OR
       p_ovtv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovtv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_ovtv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovtv_rec.ovd_id = OKC_API.G_MISS_NUM OR
          p_ovtv_rec.ovd_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ovd_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovtv_rec.rul_id = OKC_API.G_MISS_NUM OR
          p_ovtv_rec.rul_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rul_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovtv_rec.sequence_number = OKC_API.G_MISS_NUM OR
          p_ovtv_rec.sequence_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sequence_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_OVD_RUL_TMLS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_ovtv_rec IN ovtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_ovtv_rec IN ovtv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_rulv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              OBJECT1_ID1,
              OBJECT2_ID1,
              OBJECT3_ID1,
              OBJECT1_ID2,
              OBJECT2_ID2,
              OBJECT3_ID2,
              JTOT_OBJECT1_CODE,
              JTOT_OBJECT2_CODE,
              JTOT_OBJECT3_CODE,
              DNZ_CHR_ID,
              RGP_ID,
              PRIORITY,
              STD_TEMPLATE_YN,
-- removed references to okc_rules_tl
              --COMMENTS,
              WARN_YN,
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
              TEXT,
              RULE_INFORMATION_CATEGORY,
              RULE_INFORMATION1,
              RULE_INFORMATION2,
              RULE_INFORMATION3,
              RULE_INFORMATION4,
              RULE_INFORMATION5,
              RULE_INFORMATION6,
              RULE_INFORMATION7,
              RULE_INFORMATION8,
              RULE_INFORMATION9,
              RULE_INFORMATION10,
              RULE_INFORMATION11,
              RULE_INFORMATION12,
              RULE_INFORMATION13,
              RULE_INFORMATION14,
              RULE_INFORMATION15
        FROM Okc_Rules_b
       WHERE okc_rules_b.id       = p_id;
      l_okc_rulv_pk                  okc_rulv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_ovtv_rec.RUL_ID IS NOT NULL)
      THEN
        OPEN okc_rulv_pk_csr(p_ovtv_rec.RUL_ID);
        FETCH okc_rulv_pk_csr INTO l_okc_rulv_pk;
        l_row_notfound := okc_rulv_pk_csr%NOTFOUND;
        CLOSE okc_rulv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RUL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_ovtv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  **********************TCHGS: Commenting Old Code ******************************/

  /************************** TCHGS: Start New Code *****************************/
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
  PROCEDURE Validate_Id(p_ovtv_rec      IN   ovtv_rec_type
  					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovtv_rec.id IS NULL) OR
       (p_ovtv_rec.id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ovd_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ovd_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Ovd_Id(p_ovtv_rec      IN   ovtv_rec_type
  					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_ovdv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_opv_rules_v
       WHERE okl_opv_rules_v.id = p_id;

      l_ovd_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovtv_rec.ovd_id IS NULL) OR
       (p_ovtv_rec.ovd_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'ovd_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_ovtv_rec.OVD_ID IS NOT NULL)
      THEN
        OPEN okl_ovdv_pk_csr(p_ovtv_rec.OVD_ID);
        FETCH okl_ovdv_pk_csr INTO l_ovd_status;
        l_row_notfound := okl_ovdv_pk_csr%NOTFOUND;
        CLOSE okl_ovdv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OVD_ID');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Ovd_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rul_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Rul_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rul_Id(p_ovtv_rec      IN   ovtv_rec_type
  					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_rulv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okc_rules_b
       WHERE okc_rules_b.id = p_id;

      l_rul_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovtv_rec.rul_id IS NULL) OR
       (p_ovtv_rec.rul_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'rul_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_ovtv_rec.RUL_ID IS NOT NULL)
      THEN
        OPEN okl_rulv_pk_csr(p_ovtv_rec.RUL_ID);
        FETCH okl_rulv_pk_csr INTO l_rul_status;
        l_row_notfound := okl_rulv_pk_csr%NOTFOUND;
        CLOSE okl_rulv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RUL_ID');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;


    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Rul_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sequence_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sequence_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sequence_Number(p_ovtv_rec      IN   ovtv_rec_type
  					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovtv_rec.sequence_number IS NULL) OR
       (p_ovtv_rec.sequence_number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'sequence_number');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Sequence_Number;

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
  PROCEDURE Validate_Object_Version_Number(p_ovtv_rec      IN   ovtv_rec_type
  					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovtv_rec.object_version_number IS NULL) OR
       (p_ovtv_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_ovtv_rec IN  ovtv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Id
    Validate_Id(p_ovtv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_ovtv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Ovd_Id
    Validate_Ovd_Id(p_ovtv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Rul_Id
    Validate_Rul_Id(p_ovtv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sequence_Number
    Validate_Sequence_Number(p_ovtv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Ovt_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Ovt_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Ovt_Record(p_ovtv_rec      IN   ovtv_rec_type
  					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_ovt_status            VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1(p_ovd_id okl_ovd_rul_tmls_v.ovd_id%TYPE,
		p_rul_id okl_ovd_rul_tmls_v.rul_id%TYPE) is
  SELECT '1'
  FROM okl_ovd_rul_tmls_v
  WHERE  ovd_id = p_ovd_id
  AND    rul_id = p_rul_id
  AND    id <> nvl(p_ovtv_rec.id,-9999);
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OPEN c1(p_ovtv_rec.ovd_id,
	      p_ovtv_rec.rul_id);
    FETCH c1 into l_ovt_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		OKC_API.set_message(G_APP_NAME,G_UNQS,G_TABLE_TOKEN, 'Okl_Ovd_Rul_Tmls_V'); ---CHG001
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Ovt_Record;

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
    p_ovtv_rec IN ovtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_Ovt_Record
    Validate_Unique_Ovt_Record(p_ovtv_rec,x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;

  /************************** TCHGS: End New Code *****************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ovtv_rec_type,
    p_to	IN OUT NOCOPY ovt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rul_id := p_from.rul_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.ovd_id := p_from.ovd_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ovt_rec_type,
    p_to	IN OUT NOCOPY ovtv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.rul_id := p_from.rul_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.ovd_id := p_from.ovd_id;
    p_to.object_version_number := p_from.object_version_number;
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
  -- validate_row for:OKL_OVD_RUL_TMLS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN ovtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovtv_rec                     ovtv_rec_type := p_ovtv_rec;
    l_ovt_rec                      ovt_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ovtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ovtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:OVTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN ovtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovtv_rec                     => p_ovtv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ovtv_tbl.LAST);
        i := p_ovtv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- insert_row for:OKL_OVD_RUL_TMLS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovt_rec                      IN ovt_rec_type,
    x_ovt_rec                      OUT NOCOPY ovt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMLS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovt_rec                      ovt_rec_type := p_ovt_rec;
    l_def_ovt_rec                  ovt_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_OVD_RUL_TMLS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ovt_rec IN  ovt_rec_type,
      x_ovt_rec OUT NOCOPY ovt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovt_rec := p_ovt_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ovt_rec,                         -- IN
      l_ovt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OVD_RUL_TMLS(
        id,
        rul_id,
        sequence_number,
        ovd_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_ovt_rec.id,
        l_ovt_rec.rul_id,
        l_ovt_rec.sequence_number,
        l_ovt_rec.ovd_id,
        l_ovt_rec.object_version_number,
        l_ovt_rec.created_by,
        l_ovt_rec.creation_date,
        l_ovt_rec.last_updated_by,
        l_ovt_rec.last_update_date,
        l_ovt_rec.last_update_login);
    -- Set OUT values
    x_ovt_rec := l_ovt_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_OVD_RUL_TMLS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN ovtv_rec_type,
    x_ovtv_rec                     OUT NOCOPY ovtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovtv_rec                     ovtv_rec_type;
    l_def_ovtv_rec                 ovtv_rec_type;
    l_ovt_rec                      ovt_rec_type;
    lx_ovt_rec                     ovt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ovtv_rec	IN ovtv_rec_type
    ) RETURN ovtv_rec_type IS
      l_ovtv_rec	ovtv_rec_type := p_ovtv_rec;
    BEGIN
      l_ovtv_rec.CREATION_DATE := SYSDATE;
      l_ovtv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ovtv_rec.LAST_UPDATE_DATE := l_ovtv_rec.CREATION_DATE;
      l_ovtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ovtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ovtv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_OVD_RUL_TMLS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_ovtv_rec IN  ovtv_rec_type,
      x_ovtv_rec OUT NOCOPY ovtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovtv_rec := p_ovtv_rec;
      x_ovtv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_ovtv_rec := null_out_defaults(p_ovtv_rec);
    -- Set primary key value
    l_ovtv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ovtv_rec,                        -- IN
      l_def_ovtv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ovtv_rec := fill_who_columns(l_def_ovtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ovtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ovtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ovtv_rec, l_ovt_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovt_rec,
      lx_ovt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ovt_rec, l_def_ovtv_rec);
    -- Set OUT values
    x_ovtv_rec := l_def_ovtv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:OVTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN ovtv_tbl_type,
    x_ovtv_tbl                     OUT NOCOPY ovtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovtv_rec                     => p_ovtv_tbl(i),
          x_ovtv_rec                     => x_ovtv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ovtv_tbl.LAST);
        i := p_ovtv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -----------------------------------
  -- lock_row for:OKL_OVD_RUL_TMLS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovt_rec                      IN ovt_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ovt_rec IN ovt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OVD_RUL_TMLS
     WHERE ID = p_ovt_rec.id
       AND OBJECT_VERSION_NUMBER = p_ovt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ovt_rec IN ovt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OVD_RUL_TMLS
    WHERE ID = p_ovt_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMLS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_OVD_RUL_TMLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_OVD_RUL_TMLS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ovt_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ovt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ovt_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ovt_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_OVD_RUL_TMLS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN ovtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovt_rec                      ovt_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_ovtv_rec, l_ovt_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:OVTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN ovtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovtv_rec                     => p_ovtv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ovtv_tbl.LAST);
        i := p_ovtv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- update_row for:OKL_OVD_RUL_TMLS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovt_rec                      IN ovt_rec_type,
    x_ovt_rec                      OUT NOCOPY ovt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMLS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovt_rec                      ovt_rec_type := p_ovt_rec;
    l_def_ovt_rec                  ovt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ovt_rec	IN ovt_rec_type,
      x_ovt_rec	OUT NOCOPY ovt_rec_type
    ) RETURN VARCHAR2 IS
      l_ovt_rec                      ovt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovt_rec := p_ovt_rec;
      -- Get current database values
      l_ovt_rec := get_rec(p_ovt_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ovt_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.id := l_ovt_rec.id;
      END IF;
      IF (x_ovt_rec.rul_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.rul_id := l_ovt_rec.rul_id;
      END IF;
      IF (x_ovt_rec.sequence_number = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.sequence_number := l_ovt_rec.sequence_number;
      END IF;
      IF (x_ovt_rec.ovd_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.ovd_id := l_ovt_rec.ovd_id;
      END IF;
      IF (x_ovt_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.object_version_number := l_ovt_rec.object_version_number;
      END IF;
      IF (x_ovt_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.created_by := l_ovt_rec.created_by;
      END IF;
      IF (x_ovt_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovt_rec.creation_date := l_ovt_rec.creation_date;
      END IF;
      IF (x_ovt_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.last_updated_by := l_ovt_rec.last_updated_by;
      END IF;
      IF (x_ovt_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovt_rec.last_update_date := l_ovt_rec.last_update_date;
      END IF;
      IF (x_ovt_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ovt_rec.last_update_login := l_ovt_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_OVD_RUL_TMLS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ovt_rec IN  ovt_rec_type,
      x_ovt_rec OUT NOCOPY ovt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovt_rec := p_ovt_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ovt_rec,                         -- IN
      l_ovt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ovt_rec, l_def_ovt_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_OVD_RUL_TMLS
    SET RUL_ID = l_def_ovt_rec.rul_id,
        SEQUENCE_NUMBER = l_def_ovt_rec.sequence_number,
        OVD_ID = l_def_ovt_rec.ovd_id,
        OBJECT_VERSION_NUMBER = l_def_ovt_rec.object_version_number,
        CREATED_BY = l_def_ovt_rec.created_by,
        CREATION_DATE = l_def_ovt_rec.creation_date,
        LAST_UPDATED_BY = l_def_ovt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ovt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ovt_rec.last_update_login
    WHERE ID = l_def_ovt_rec.id;

    x_ovt_rec := l_def_ovt_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_OVD_RUL_TMLS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN ovtv_rec_type,
    x_ovtv_rec                     OUT NOCOPY ovtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovtv_rec                     ovtv_rec_type := p_ovtv_rec;
    l_def_ovtv_rec                 ovtv_rec_type;
    l_ovt_rec                      ovt_rec_type;
    lx_ovt_rec                     ovt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ovtv_rec	IN ovtv_rec_type
    ) RETURN ovtv_rec_type IS
      l_ovtv_rec	ovtv_rec_type := p_ovtv_rec;
    BEGIN
      l_ovtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ovtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ovtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ovtv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ovtv_rec	IN ovtv_rec_type,
      x_ovtv_rec	OUT NOCOPY ovtv_rec_type
    ) RETURN VARCHAR2 IS
      l_ovtv_rec                     ovtv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovtv_rec := p_ovtv_rec;
      -- Get current database values
      l_ovtv_rec := get_rec(p_ovtv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ovtv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.id := l_ovtv_rec.id;
      END IF;
      IF (x_ovtv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.object_version_number := l_ovtv_rec.object_version_number;
      END IF;
      IF (x_ovtv_rec.ovd_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.ovd_id := l_ovtv_rec.ovd_id;
      END IF;
      IF (x_ovtv_rec.rul_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.rul_id := l_ovtv_rec.rul_id;
      END IF;
      IF (x_ovtv_rec.sequence_number = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.sequence_number := l_ovtv_rec.sequence_number;
      END IF;
      IF (x_ovtv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.created_by := l_ovtv_rec.created_by;
      END IF;
      IF (x_ovtv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovtv_rec.creation_date := l_ovtv_rec.creation_date;
      END IF;
      IF (x_ovtv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.last_updated_by := l_ovtv_rec.last_updated_by;
      END IF;
      IF (x_ovtv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovtv_rec.last_update_date := l_ovtv_rec.last_update_date;
      END IF;
      IF (x_ovtv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ovtv_rec.last_update_login := l_ovtv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_OVD_RUL_TMLS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_ovtv_rec IN  ovtv_rec_type,
      x_ovtv_rec OUT NOCOPY ovtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovtv_rec := p_ovtv_rec;
      x_ovtv_rec.OBJECT_VERSION_NUMBER := NVL(x_ovtv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ovtv_rec,                        -- IN
      l_ovtv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ovtv_rec, l_def_ovtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ovtv_rec := fill_who_columns(l_def_ovtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ovtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ovtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ovtv_rec, l_ovt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovt_rec,
      lx_ovt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ovt_rec, l_def_ovtv_rec);
    x_ovtv_rec := l_def_ovtv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:OVTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN ovtv_tbl_type,
    x_ovtv_tbl                     OUT NOCOPY ovtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovtv_rec                     => p_ovtv_tbl(i),
          x_ovtv_rec                     => x_ovtv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ovtv_tbl.LAST);
        i := p_ovtv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- delete_row for:OKL_OVD_RUL_TMLS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovt_rec                      IN ovt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMLS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovt_rec                      ovt_rec_type:= p_ovt_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_OVD_RUL_TMLS
     WHERE ID = l_ovt_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_OVD_RUL_TMLS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_rec                     IN ovtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovtv_rec                     ovtv_rec_type := p_ovtv_rec;
    l_ovt_rec                      ovt_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_ovtv_rec, l_ovt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:OVTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovtv_tbl                     IN ovtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovtv_tbl.COUNT > 0) THEN
      i := p_ovtv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovtv_rec                     => p_ovtv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_ovtv_tbl.LAST);
        i := p_ovtv_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
	  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_OVT_PVT;

/
