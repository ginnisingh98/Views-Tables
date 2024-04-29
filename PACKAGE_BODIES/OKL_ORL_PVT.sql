--------------------------------------------------------
--  DDL for Package Body OKL_ORL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ORL_PVT" AS
/* $Header: OKLSORLB.pls 115.9 2002/12/18 13:01:14 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_OPT_RULES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_orl_rec                      IN orl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN orl_rec_type IS
    CURSOR okl_opt_rules_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OPT_ID,
            RGR_RGD_CODE,
            RGR_RDF_CODE,
            SRD_ID_FOR,
            LRG_LSE_ID,
            LRG_SRD_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            OVERALL_INSTRUCTIONS,
            LAST_UPDATE_LOGIN
      FROM Okl_Opt_Rules
     WHERE okl_opt_rules.id     = p_id;
    l_okl_opt_rules_pk             okl_opt_rules_pk_csr%ROWTYPE;
    l_orl_rec                      orl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_opt_rules_pk_csr (p_orl_rec.id);
    FETCH okl_opt_rules_pk_csr INTO
              l_orl_rec.ID,
              l_orl_rec.OPT_ID,
              l_orl_rec.RGR_RGD_CODE,
              l_orl_rec.RGR_RDF_CODE,
              l_orl_rec.SRD_ID_FOR,
              l_orl_rec.LRG_LSE_ID,
              l_orl_rec.LRG_SRD_ID,
              l_orl_rec.OBJECT_VERSION_NUMBER,
              l_orl_rec.CREATED_BY,
              l_orl_rec.CREATION_DATE,
              l_orl_rec.LAST_UPDATED_BY,
              l_orl_rec.LAST_UPDATE_DATE,
              l_orl_rec.OVERALL_INSTRUCTIONS,
              l_orl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_opt_rules_pk_csr%NOTFOUND;
    CLOSE okl_opt_rules_pk_csr;
    RETURN(l_orl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_orl_rec                      IN orl_rec_type
  ) RETURN orl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_orl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPT_RULES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_orlv_rec                     IN orlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN orlv_rec_type IS
    CURSOR okl_orlv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OPT_ID,
            SRD_ID_FOR,
            RGR_RGD_CODE,
            RGR_RDF_CODE,
            LRG_LSE_ID,
            LRG_SRD_ID,
            OVERALL_INSTRUCTIONS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Opt_Rules_V
     WHERE okl_opt_rules_v.id   = p_id;
    l_okl_orlv_pk                  okl_orlv_pk_csr%ROWTYPE;
    l_orlv_rec                     orlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_orlv_pk_csr (p_orlv_rec.id);
    FETCH okl_orlv_pk_csr INTO
              l_orlv_rec.ID,
              l_orlv_rec.OBJECT_VERSION_NUMBER,
              l_orlv_rec.OPT_ID,
              l_orlv_rec.SRD_ID_FOR,
              l_orlv_rec.RGR_RGD_CODE,
              l_orlv_rec.RGR_RDF_CODE,
              l_orlv_rec.LRG_LSE_ID,
              l_orlv_rec.LRG_SRD_ID,
              l_orlv_rec.OVERALL_INSTRUCTIONS,
              l_orlv_rec.CREATED_BY,
              l_orlv_rec.CREATION_DATE,
              l_orlv_rec.LAST_UPDATED_BY,
              l_orlv_rec.LAST_UPDATE_DATE,
              l_orlv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_orlv_pk_csr%NOTFOUND;
    CLOSE okl_orlv_pk_csr;
    RETURN(l_orlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_orlv_rec                     IN orlv_rec_type
  ) RETURN orlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_orlv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OPT_RULES_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_orlv_rec	IN orlv_rec_type
  ) RETURN orlv_rec_type IS
    l_orlv_rec	orlv_rec_type := p_orlv_rec;
  BEGIN
    IF (l_orlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.object_version_number := NULL;
    END IF;
    IF (l_orlv_rec.opt_id = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.opt_id := NULL;
    END IF;
    IF (l_orlv_rec.srd_id_for = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.srd_id_for := NULL;
    END IF;
    IF (l_orlv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR) THEN
      l_orlv_rec.rgr_rgd_code := NULL;
    END IF;
    IF (l_orlv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR) THEN
      l_orlv_rec.rgr_rdf_code := NULL;
    END IF;
    IF (l_orlv_rec.lrg_lse_id = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.lrg_lse_id := NULL;
    END IF;
    IF (l_orlv_rec.lrg_srd_id = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.lrg_srd_id := NULL;
    END IF;
    IF (l_orlv_rec.overall_instructions = OKC_API.G_MISS_CHAR) THEN
      l_orlv_rec.overall_instructions := NULL;
    END IF;
    IF (l_orlv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.created_by := NULL;
    END IF;
    IF (l_orlv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_orlv_rec.creation_date := NULL;
    END IF;
    IF (l_orlv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_orlv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_orlv_rec.last_update_date := NULL;
    END IF;
    IF (l_orlv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_orlv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_orlv_rec);
  END null_out_defaults;

/**********************TCHGS: Old Code******************************************
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKL_OPT_RULES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_orlv_rec IN  orlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_orlv_rec.id = OKC_API.G_MISS_NUM OR
       p_orlv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_orlv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_orlv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_orlv_rec.opt_id = OKC_API.G_MISS_NUM OR
          p_orlv_rec.opt_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'opt_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_orlv_rec.srd_id_for = OKC_API.G_MISS_NUM OR
          p_orlv_rec.srd_id_for IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'srd_id_for');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_orlv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR OR
          p_orlv_rec.rgr_rgd_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rgr_rgd_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_orlv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR OR
          p_orlv_rec.rgr_rdf_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rgr_rdf_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_orlv_rec.lrg_lse_id = OKC_API.G_MISS_NUM OR
          p_orlv_rec.lrg_lse_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lrg_lse_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_orlv_rec.lrg_srd_id = OKC_API.G_MISS_NUM OR
          p_orlv_rec.lrg_srd_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lrg_srd_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate_Record for:OKL_OPT_RULES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_orlv_rec IN orlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
**********************TCHGS: Old Code******************************************/

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
  PROCEDURE Validate_Id(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.id IS NULL) OR
       (p_orlv_rec.id = OKC_API.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_Opt_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Opt_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Opt_Id(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_optv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_options_v
       WHERE okl_options_v.id = p_id;

      l_opt_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.opt_id IS NULL) OR
       (p_orlv_rec.opt_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'opt_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_orlv_rec.OPT_ID IS NOT NULL)
      THEN
        OPEN okl_optv_pk_csr(p_orlv_rec.OPT_ID);
        FETCH okl_optv_pk_csr INTO l_opt_status;
        l_row_notfound := okl_optv_pk_csr%NOTFOUND;
        CLOSE okl_optv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OPT_ID');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;

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

  END Validate_Opt_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Srd_Id_For
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Srd_Id_For
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Srd_Id_For(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_srdv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okc_subclass_rg_defs_v
       WHERE okc_subclass_rg_defs_v.id = p_id;

      l_srd_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.srd_id_for IS NULL) OR
       (p_orlv_rec.srd_id_for = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'srd_id_for');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF (p_orlv_rec.SRD_ID_FOR IS NOT NULL)
      THEN
        OPEN okl_srdv_pk_csr(p_orlv_rec.SRD_ID_FOR);
        FETCH okl_srdv_pk_csr INTO l_srd_status;
        l_row_notfound := okl_srdv_pk_csr%NOTFOUND;
        CLOSE okl_srdv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SRD_ID_FOR');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;

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

  END Validate_Srd_Id_For;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Lrg_Lse_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Lrg_Lse_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Lrg_Lse_Id(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.lrg_lse_id IS NULL) OR
       (p_orlv_rec.lrg_lse_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'lrg_lse_id');
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

  END Validate_Lrg_Lse_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Lrg_Srd_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Lrg_Srd_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Lrg_Srd_Id(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.lrg_lse_id IS NULL) OR
       (p_orlv_rec.lrg_lse_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'lrg_srd_id');
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

  END Validate_Lrg_Srd_Id;

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
  PROCEDURE Validate_Object_Version_Number(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.object_version_number IS NULL) OR
       (p_orlv_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_Rgr_Rgd_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Rgr_Rgd_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rgr_Rgd_Code(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.rgr_rgd_code IS NULL) OR
       (p_orlv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'rgr_rgd_code');
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

  END Validate_Rgr_Rgd_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Rgr_Rdf_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Rgr_Rdf_Code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Rgr_Rdf_Code(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_orlv_rec.rgr_rdf_code IS NULL) OR
       (p_orlv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'rgr_rdf_code');
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

  END Validate_Rgr_Rdf_Code;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Foreign_Keys
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate_Foreign_Keys
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
    FUNCTION Validate_Foreign_Keys (
      p_orlv_rec IN orlv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;

      CURSOR okl_rgrv_pk_csr (p_rgd_code                 IN VARCHAR2,
                              p_rdf_code			   IN VARCHAR2) IS
      SELECT  '1'
        FROM okc_rg_def_rules_v
       WHERE okc_rg_def_rules_v.rgd_code = p_rgd_code
       AND   okc_rg_def_rules_v.rdf_code = p_rdf_code;

      CURSOR okl_lrgv_pk_csr (p_lse_id                 IN NUMBER,
                              p_srd_id			   IN NUMBER) IS
      SELECT  '1'
        FROM okc_lse_rule_groups_v
       WHERE okc_lse_rule_groups_v.lse_id = p_lse_id
       AND   okc_lse_rule_groups_v.srd_id = p_srd_id;

      l_rgr_status                   VARCHAR2(1);
      l_lrg_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

    BEGIN

      IF (p_orlv_rec.RGR_RGD_CODE IS NOT NULL AND p_orlv_rec.RGR_RDF_CODE IS NOT NULL)
      THEN
        OPEN okl_rgrv_pk_csr(p_orlv_rec.RGR_RGD_CODE, p_orlv_rec.RGR_RDF_CODE);
        FETCH okl_rgrv_pk_csr INTO l_rgr_status;
        l_row_notfound := okl_rgrv_pk_csr%NOTFOUND;
        CLOSE okl_rgrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RGR_RGD_CODE');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RGR_RDF_CODE');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
      END IF;

      IF (p_orlv_rec.LRG_LSE_ID IS NOT NULL AND p_orlv_rec.LRG_SRD_ID IS NOT NULL)
      THEN
        OPEN okl_lrgv_pk_csr(p_orlv_rec.LRG_LSE_ID, p_orlv_rec.LRG_SRD_ID);
        FETCH okl_lrgv_pk_csr INTO l_lrg_status;
        l_row_notfound := okl_lrgv_pk_csr%NOTFOUND;
        CLOSE okl_lrgv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LRG_LSE_ID');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LRG_SRD_ID');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
      END IF;

      RETURN (l_return_status);
    EXCEPTION
      WHEN G_ITEM_NOT_FOUND_ERROR THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END Validate_Foreign_Keys;

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
    p_orlv_rec IN  orlv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Id
    Validate_Id(p_orlv_rec, x_return_status);
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

    -- Validate_Opt_Id
    Validate_Opt_Id(p_orlv_rec, x_return_status);
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

    -- Validate_Rgr_Rgd_Code
    Validate_Rgr_Rgd_Code(p_orlv_rec, x_return_status);
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

    -- Validate_Rgr_Rdf_Code
    Validate_Rgr_Rdf_Code(p_orlv_rec, x_return_status);
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
    Validate_Object_Version_Number(p_orlv_rec, x_return_status);
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

    -- Validate_Srd_Id_For
    If (p_orlv_rec.srd_id_for is not null) THEN
    	Validate_Srd_Id_For(p_orlv_rec, x_return_status);
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
    END IF;

    -- Validate_Lrg_Lse_Id
    If (p_orlv_rec.lrg_lse_id is not null) THEN
    	Validate_Lrg_Lse_Id(p_orlv_rec, x_return_status);
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
    END IF;

    -- Validate_Lrg_Srd_Id
    If (p_orlv_rec.lrg_srd_id is not null) THEN
    	Validate_Lrg_Srd_Id(p_orlv_rec, x_return_status);
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
  -- PROCEDURE Validate_Unique_Orl_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Orl_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Orl_Record(p_orlv_rec      IN   orlv_rec_type
					   ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_orl_status            VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1(p_opt_id okl_opt_rules_v.opt_id%TYPE,
		p_rgr_rgd_code okl_opt_rules_v.rgr_rgd_code%TYPE,
            p_rgr_rdf_code okl_opt_rules_v.rgr_rdf_code%TYPE,
		p_srd_id_for okl_opt_rules_v.srd_id_for%TYPE) is
  SELECT '1'
  FROM okl_opt_rules_v
  WHERE  opt_id = p_opt_id
  AND    rgr_rgd_code = p_rgr_rgd_code
  AND	   rgr_rdf_code = p_rgr_rdf_code
  AND    srd_id_for = p_srd_id_for
  AND id <> nvl(p_orlv_rec.id,-9999);

  CURSOR c2(p_opt_id okl_opt_rules_v.opt_id%TYPE,
		p_rgr_rgd_code okl_opt_rules_v.rgr_rgd_code%TYPE,
            p_rgr_rdf_code okl_opt_rules_v.rgr_rdf_code%TYPE,
            p_lrg_lse_id okl_opt_rules_v.lrg_lse_id%TYPE,
		p_lrg_srd_id okl_opt_rules_v.lrg_srd_id%TYPE) is
  SELECT '1'
  FROM okl_opt_rules_v
  WHERE  opt_id = p_opt_id
  AND    rgr_rgd_code = p_rgr_rgd_code
  AND	   rgr_rdf_code = p_rgr_rdf_code
  AND    lrg_lse_id = p_lrg_lse_id
  AND    lrg_srd_id = p_lrg_srd_id
  AND id <> nvl(p_orlv_rec.id,-9999);

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_orlv_rec.srd_id_for is not null) THEN
    	OPEN c1(p_orlv_rec.opt_id,
	      p_orlv_rec.rgr_rgd_code,
 		p_orlv_rec.rgr_rdf_code,
		p_orlv_rec.srd_id_for);
    	FETCH c1 into l_orl_status;
    	l_row_found := c1%FOUND;
    	CLOSE c1;
    	IF l_row_found then
		OKC_API.set_message(G_APP_NAME,G_UNQS,G_TABLE_TOKEN, 'Okl_Opt_Rules_V'); ---CHG001
		x_return_status := OKC_API.G_RET_STS_ERROR;
     	END IF;
    ELSE
    	OPEN c2(p_orlv_rec.opt_id,
	      p_orlv_rec.rgr_rgd_code,
 		p_orlv_rec.rgr_rdf_code,
		p_orlv_rec.lrg_lse_id,
		p_orlv_rec.lrg_srd_id);
    	FETCH c2 into l_orl_status;
    	l_row_found := c2%FOUND;
    	CLOSE c2;
    	IF l_row_found then
		OKC_API.set_message(G_APP_NAME,G_UNQS,G_TABLE_TOKEN, 'Okl_Opt_Rules_V'); ---CHG001
		x_return_status := OKC_API.G_RET_STS_ERROR;
     	END IF;
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

  END Validate_Unique_Orl_Record;

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
    p_orlv_rec IN orlv_rec_type ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := Validate_Foreign_Keys(p_orlv_rec);
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

    -- Validate_Unique_Orl_Record
    Validate_Unique_Orl_Record(p_orlv_rec, x_return_status);
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
    p_from	IN orlv_rec_type,
    p_to	IN OUT NOCOPY orl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.opt_id := p_from.opt_id;
    p_to.rgr_rgd_code := p_from.rgr_rgd_code;
    p_to.rgr_rdf_code := p_from.rgr_rdf_code;
    p_to.srd_id_for := p_from.srd_id_for;
    p_to.lrg_lse_id := p_from.lrg_lse_id;
    p_to.lrg_srd_id := p_from.lrg_srd_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.overall_instructions := p_from.overall_instructions;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN orl_rec_type,
    p_to	IN OUT NOCOPY orlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.opt_id := p_from.opt_id;
    p_to.rgr_rgd_code := p_from.rgr_rgd_code;
    p_to.rgr_rdf_code := p_from.rgr_rdf_code;
    p_to.srd_id_for := p_from.srd_id_for;
    p_to.lrg_lse_id := p_from.lrg_lse_id;
    p_to.lrg_srd_id := p_from.lrg_srd_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.overall_instructions := p_from.overall_instructions;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_OPT_RULES_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_rec                     IN orlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orlv_rec                     orlv_rec_type := p_orlv_rec;
    l_orl_rec                      orl_rec_type;
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
    l_return_status := Validate_Attributes(l_orlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_orlv_rec);
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
  -- PL/SQL TBL validate_row for:ORLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_tbl                     IN orlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_orlv_tbl.COUNT > 0) THEN
      i := p_orlv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_orlv_rec                     => p_orlv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_orlv_tbl.LAST);
        i := p_orlv_tbl.NEXT(i);
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
  ----------------------------------
  -- insert_row for:OKL_OPT_RULES --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orl_rec                      IN orl_rec_type,
    x_orl_rec                      OUT NOCOPY orl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orl_rec                      orl_rec_type := p_orl_rec;
    l_def_orl_rec                  orl_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKL_OPT_RULES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_orl_rec IN  orl_rec_type,
      x_orl_rec OUT NOCOPY orl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_orl_rec := p_orl_rec;
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
      p_orl_rec,                         -- IN
      l_orl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OPT_RULES(
        id,
        opt_id,
        rgr_rgd_code,
        rgr_rdf_code,
        srd_id_for,
        lrg_lse_id,
        lrg_srd_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        overall_instructions,
        last_update_login)
      VALUES (
        l_orl_rec.id,
        l_orl_rec.opt_id,
        l_orl_rec.rgr_rgd_code,
        l_orl_rec.rgr_rdf_code,
        l_orl_rec.srd_id_for,
        l_orl_rec.lrg_lse_id,
        l_orl_rec.lrg_srd_id,
        l_orl_rec.object_version_number,
        l_orl_rec.created_by,
        l_orl_rec.creation_date,
        l_orl_rec.last_updated_by,
        l_orl_rec.last_update_date,
        l_orl_rec.overall_instructions,
        l_orl_rec.last_update_login);
    -- Set OUT values
    x_orl_rec := l_orl_rec;
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
  ------------------------------------
  -- insert_row for:OKL_OPT_RULES_V --
  ------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_rec                     IN orlv_rec_type,
    x_orlv_rec                     OUT NOCOPY orlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orlv_rec                     orlv_rec_type;
    l_def_orlv_rec                 orlv_rec_type;
    l_orl_rec                      orl_rec_type;
    lx_orl_rec                     orl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_orlv_rec	IN orlv_rec_type
    ) RETURN orlv_rec_type IS
      l_orlv_rec	orlv_rec_type := p_orlv_rec;
    BEGIN
      l_orlv_rec.CREATION_DATE := SYSDATE;
      l_orlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_orlv_rec.LAST_UPDATE_DATE := l_orlv_rec.CREATION_DATE;
      l_orlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_orlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_orlv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_OPT_RULES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_orlv_rec IN  orlv_rec_type,
      x_orlv_rec OUT NOCOPY orlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_orlv_rec := p_orlv_rec;
      x_orlv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_orlv_rec := null_out_defaults(p_orlv_rec);
    -- Set primary key value
    l_orlv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_orlv_rec,                        -- IN
      l_def_orlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_orlv_rec := fill_who_columns(l_def_orlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_orlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_orlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_orlv_rec, l_orl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_orl_rec,
      lx_orl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_orl_rec, l_def_orlv_rec);
    -- Set OUT values
    x_orlv_rec := l_def_orlv_rec;
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
  -- PL/SQL TBL insert_row for:ORLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_tbl                     IN orlv_tbl_type,
    x_orlv_tbl                     OUT NOCOPY orlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_orlv_tbl.COUNT > 0) THEN
      i := p_orlv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_orlv_rec                     => p_orlv_tbl(i),
          x_orlv_rec                     => x_orlv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_orlv_tbl.LAST);
        i := p_orlv_tbl.NEXT(i);
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
  --------------------------------
  -- lock_row for:OKL_OPT_RULES --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orl_rec                      IN orl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_orl_rec IN orl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPT_RULES
     WHERE ID = p_orl_rec.id
       AND OBJECT_VERSION_NUMBER = p_orl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_orl_rec IN orl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPT_RULES
    WHERE ID = p_orl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_OPT_RULES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_OPT_RULES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_orl_rec);
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
      OPEN lchk_csr(p_orl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_orl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_orl_rec.object_version_number THEN
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
  ----------------------------------
  -- lock_row for:OKL_OPT_RULES_V --
  ----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_rec                     IN orlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orl_rec                      orl_rec_type;
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
    migrate(p_orlv_rec, l_orl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_orl_rec
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
  -- PL/SQL TBL lock_row for:ORLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_tbl                     IN orlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_orlv_tbl.COUNT > 0) THEN
      i := p_orlv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_orlv_rec                     => p_orlv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_orlv_tbl.LAST);
        i := p_orlv_tbl.NEXT(i);
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
  ----------------------------------
  -- update_row for:OKL_OPT_RULES --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orl_rec                      IN orl_rec_type,
    x_orl_rec                      OUT NOCOPY orl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orl_rec                      orl_rec_type := p_orl_rec;
    l_def_orl_rec                  orl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_orl_rec	IN orl_rec_type,
      x_orl_rec	OUT NOCOPY orl_rec_type
    ) RETURN VARCHAR2 IS
      l_orl_rec                      orl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_orl_rec := p_orl_rec;
      -- Get current database values
      l_orl_rec := get_rec(p_orl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_orl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.id := l_orl_rec.id;
      END IF;
      IF (x_orl_rec.opt_id = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.opt_id := l_orl_rec.opt_id;
      END IF;
      IF (x_orl_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_orl_rec.rgr_rgd_code := l_orl_rec.rgr_rgd_code;
      END IF;
      IF (x_orl_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR)
      THEN
        x_orl_rec.rgr_rdf_code := l_orl_rec.rgr_rdf_code;
      END IF;
      IF (x_orl_rec.srd_id_for = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.srd_id_for := l_orl_rec.srd_id_for;
      END IF;
      IF (x_orl_rec.lrg_lse_id = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.lrg_lse_id := l_orl_rec.lrg_lse_id;
      END IF;
      IF (x_orl_rec.lrg_srd_id = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.lrg_srd_id := l_orl_rec.lrg_srd_id;
      END IF;
      IF (x_orl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.object_version_number := l_orl_rec.object_version_number;
      END IF;
      IF (x_orl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.created_by := l_orl_rec.created_by;
      END IF;
      IF (x_orl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_orl_rec.creation_date := l_orl_rec.creation_date;
      END IF;
      IF (x_orl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.last_updated_by := l_orl_rec.last_updated_by;
      END IF;
      IF (x_orl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_orl_rec.last_update_date := l_orl_rec.last_update_date;
      END IF;
      IF (x_orl_rec.overall_instructions = OKC_API.G_MISS_CHAR)
      THEN
        x_orl_rec.overall_instructions := l_orl_rec.overall_instructions;
      END IF;
      IF (x_orl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_orl_rec.last_update_login := l_orl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_OPT_RULES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_orl_rec IN  orl_rec_type,
      x_orl_rec OUT NOCOPY orl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_orl_rec := p_orl_rec;
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
      p_orl_rec,                         -- IN
      l_orl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_orl_rec, l_def_orl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_OPT_RULES
    SET OPT_ID = l_def_orl_rec.opt_id,
        RGR_RGD_CODE = l_def_orl_rec.rgr_rgd_code,
        RGR_RDF_CODE = l_def_orl_rec.rgr_rdf_code,
        SRD_ID_FOR = l_def_orl_rec.srd_id_for,
        LRG_LSE_ID = l_def_orl_rec.lrg_lse_id,
        LRG_SRD_ID = l_def_orl_rec.lrg_srd_id,
        OBJECT_VERSION_NUMBER = l_def_orl_rec.object_version_number,
        CREATED_BY = l_def_orl_rec.created_by,
        CREATION_DATE = l_def_orl_rec.creation_date,
        LAST_UPDATED_BY = l_def_orl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_orl_rec.last_update_date,
        OVERALL_INSTRUCTIONS = l_def_orl_rec.overall_instructions,
        LAST_UPDATE_LOGIN = l_def_orl_rec.last_update_login
    WHERE ID = l_def_orl_rec.id;

    x_orl_rec := l_def_orl_rec;
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
  ------------------------------------
  -- update_row for:OKL_OPT_RULES_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_rec                     IN orlv_rec_type,
    x_orlv_rec                     OUT NOCOPY orlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orlv_rec                     orlv_rec_type := p_orlv_rec;
    l_def_orlv_rec                 orlv_rec_type;
    l_orl_rec                      orl_rec_type;
    lx_orl_rec                     orl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_orlv_rec	IN orlv_rec_type
    ) RETURN orlv_rec_type IS
      l_orlv_rec	orlv_rec_type := p_orlv_rec;
    BEGIN
      l_orlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_orlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_orlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_orlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_orlv_rec	IN orlv_rec_type,
      x_orlv_rec	OUT NOCOPY orlv_rec_type
    ) RETURN VARCHAR2 IS
      l_orlv_rec                     orlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_orlv_rec := p_orlv_rec;
      -- Get current database values
      l_orlv_rec := get_rec(p_orlv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_orlv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.id := l_orlv_rec.id;
      END IF;
      IF (x_orlv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.object_version_number := l_orlv_rec.object_version_number;
      END IF;
      IF (x_orlv_rec.opt_id = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.opt_id := l_orlv_rec.opt_id;
      END IF;
      IF (x_orlv_rec.srd_id_for = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.srd_id_for := l_orlv_rec.srd_id_for;
      END IF;
      IF (x_orlv_rec.rgr_rgd_code = OKC_API.G_MISS_CHAR)
      THEN
        x_orlv_rec.rgr_rgd_code := l_orlv_rec.rgr_rgd_code;
      END IF;
      IF (x_orlv_rec.rgr_rdf_code = OKC_API.G_MISS_CHAR)
      THEN
        x_orlv_rec.rgr_rdf_code := l_orlv_rec.rgr_rdf_code;
      END IF;
      IF (x_orlv_rec.lrg_lse_id = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.lrg_lse_id := l_orlv_rec.lrg_lse_id;
      END IF;
      IF (x_orlv_rec.lrg_srd_id = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.lrg_srd_id := l_orlv_rec.lrg_srd_id;
      END IF;
      IF (x_orlv_rec.overall_instructions = OKC_API.G_MISS_CHAR)
      THEN
        x_orlv_rec.overall_instructions := l_orlv_rec.overall_instructions;
      END IF;
      IF (x_orlv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.created_by := l_orlv_rec.created_by;
      END IF;
      IF (x_orlv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_orlv_rec.creation_date := l_orlv_rec.creation_date;
      END IF;
      IF (x_orlv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.last_updated_by := l_orlv_rec.last_updated_by;
      END IF;
      IF (x_orlv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_orlv_rec.last_update_date := l_orlv_rec.last_update_date;
      END IF;
      IF (x_orlv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_orlv_rec.last_update_login := l_orlv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_OPT_RULES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_orlv_rec IN  orlv_rec_type,
      x_orlv_rec OUT NOCOPY orlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_orlv_rec := p_orlv_rec;
      x_orlv_rec.OBJECT_VERSION_NUMBER := NVL(x_orlv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_orlv_rec,                        -- IN
      l_orlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_orlv_rec, l_def_orlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_orlv_rec := fill_who_columns(l_def_orlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_orlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_orlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_orlv_rec, l_orl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_orl_rec,
      lx_orl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_orl_rec, l_def_orlv_rec);
    x_orlv_rec := l_def_orlv_rec;
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
  -- PL/SQL TBL update_row for:ORLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_tbl                     IN orlv_tbl_type,
    x_orlv_tbl                     OUT NOCOPY orlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_orlv_tbl.COUNT > 0) THEN
      i := p_orlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_orlv_rec                     => p_orlv_tbl(i),
          x_orlv_rec                     => x_orlv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_orlv_tbl.LAST);
        i := p_orlv_tbl.NEXT(i);
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
  ----------------------------------
  -- delete_row for:OKL_OPT_RULES --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orl_rec                      IN orl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orl_rec                      orl_rec_type:= p_orl_rec;
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
    DELETE FROM OKL_OPT_RULES
     WHERE ID = l_orl_rec.id;

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
  ------------------------------------
  -- delete_row for:OKL_OPT_RULES_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_rec                     IN orlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_orlv_rec                     orlv_rec_type := p_orlv_rec;
    l_orl_rec                      orl_rec_type;
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
    migrate(l_orlv_rec, l_orl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_orl_rec
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
  -- PL/SQL TBL delete_row for:ORLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_orlv_tbl                     IN orlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_orlv_tbl.COUNT > 0) THEN
      i := p_orlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_orlv_rec                     => p_orlv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_orlv_tbl.LAST);
        i := p_orlv_tbl.NEXT(i);
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
END OKL_ORL_PVT;

/
