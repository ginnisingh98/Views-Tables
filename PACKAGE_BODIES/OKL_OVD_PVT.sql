--------------------------------------------------------
--  DDL for Package Body OKL_OVD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OVD_PVT" AS
/* $Header: OKLSOVDB.pls 115.10 2002/12/18 13:01:31 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_OPV_RULES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ovd_rec                      IN ovd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ovd_rec_type IS
    CURSOR okl_opv_rules_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CONTEXT_INTENT,
            ORL_ID,
            OVE_ID,
            COPY_OR_ENTER_FLAG,
            OBJECT_VERSION_NUMBER,
            CONTEXT_INV_ORG,
            CONTEXT_ORG,
            CONTEXT_ASSET_BOOK,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            INDIVIDUAL_INSTRUCTIONS,
            LAST_UPDATE_LOGIN
      FROM Okl_Opv_Rules
     WHERE okl_opv_rules.id     = p_id;
    l_okl_opv_rules_pk             okl_opv_rules_pk_csr%ROWTYPE;
    l_ovd_rec                      ovd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_opv_rules_pk_csr (p_ovd_rec.id);
    FETCH okl_opv_rules_pk_csr INTO
              l_ovd_rec.ID,
              l_ovd_rec.CONTEXT_INTENT,
              l_ovd_rec.ORL_ID,
              l_ovd_rec.OVE_ID,
              l_ovd_rec.COPY_OR_ENTER_FLAG,
              l_ovd_rec.OBJECT_VERSION_NUMBER,
              l_ovd_rec.CONTEXT_INV_ORG,
              l_ovd_rec.CONTEXT_ORG,
              l_ovd_rec.CONTEXT_ASSET_BOOK,
              l_ovd_rec.CREATED_BY,
              l_ovd_rec.CREATION_DATE,
              l_ovd_rec.LAST_UPDATED_BY,
              l_ovd_rec.LAST_UPDATE_DATE,
              l_ovd_rec.INDIVIDUAL_INSTRUCTIONS,
              l_ovd_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_opv_rules_pk_csr%NOTFOUND;
    CLOSE okl_opv_rules_pk_csr;
    RETURN(l_ovd_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ovd_rec                      IN ovd_rec_type
  ) RETURN ovd_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ovd_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_OPV_RULES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ovdv_rec                     IN ovdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ovdv_rec_type IS
    CURSOR okl_ovdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CONTEXT_INTENT,
            OBJECT_VERSION_NUMBER,
            ORL_ID,
            OVE_ID,
            INDIVIDUAL_INSTRUCTIONS,
            COPY_OR_ENTER_FLAG,
            CONTEXT_ORG,
            CONTEXT_INV_ORG,
            CONTEXT_ASSET_BOOK,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Opv_Rules_V
     WHERE okl_opv_rules_v.id   = p_id;
    l_okl_ovdv_pk                  okl_ovdv_pk_csr%ROWTYPE;
    l_ovdv_rec                     ovdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ovdv_pk_csr (p_ovdv_rec.id);
    FETCH okl_ovdv_pk_csr INTO
              l_ovdv_rec.ID,
              l_ovdv_rec.CONTEXT_INTENT,
              l_ovdv_rec.OBJECT_VERSION_NUMBER,
              l_ovdv_rec.ORL_ID,
              l_ovdv_rec.OVE_ID,
              l_ovdv_rec.INDIVIDUAL_INSTRUCTIONS,
              l_ovdv_rec.COPY_OR_ENTER_FLAG,
              l_ovdv_rec.CONTEXT_ORG,
              l_ovdv_rec.CONTEXT_INV_ORG,
              l_ovdv_rec.CONTEXT_ASSET_BOOK,
              l_ovdv_rec.CREATED_BY,
              l_ovdv_rec.CREATION_DATE,
              l_ovdv_rec.LAST_UPDATED_BY,
              l_ovdv_rec.LAST_UPDATE_DATE,
              l_ovdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ovdv_pk_csr%NOTFOUND;
    CLOSE okl_ovdv_pk_csr;
    RETURN(l_ovdv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ovdv_rec                     IN ovdv_rec_type
  ) RETURN ovdv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ovdv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_OPV_RULES_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_ovdv_rec	IN ovdv_rec_type
  ) RETURN ovdv_rec_type IS
    l_ovdv_rec	ovdv_rec_type := p_ovdv_rec;
  BEGIN
    IF (l_ovdv_rec.context_intent = OKC_API.G_MISS_CHAR) THEN
      l_ovdv_rec.context_intent := NULL;
    END IF;
    IF (l_ovdv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.object_version_number := NULL;
    END IF;
    IF (l_ovdv_rec.orl_id = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.orl_id := NULL;
    END IF;
    IF (l_ovdv_rec.ove_id = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.ove_id := NULL;
    END IF;
    IF (l_ovdv_rec.individual_instructions = OKC_API.G_MISS_CHAR) THEN
      l_ovdv_rec.individual_instructions := NULL;
    END IF;
    IF (l_ovdv_rec.copy_or_enter_flag = OKC_API.G_MISS_CHAR) THEN
      l_ovdv_rec.copy_or_enter_flag := NULL;
    END IF;
    IF (l_ovdv_rec.context_org = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.context_org := NULL;
    END IF;
    IF (l_ovdv_rec.context_inv_org = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.context_inv_org := NULL;
    END IF;
    IF (l_ovdv_rec.context_asset_book = OKC_API.G_MISS_CHAR) THEN
      l_ovdv_rec.context_asset_book := NULL;
    END IF;
    IF (l_ovdv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.created_by := NULL;
    END IF;
    IF (l_ovdv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ovdv_rec.creation_date := NULL;
    END IF;
    IF (l_ovdv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ovdv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ovdv_rec.last_update_date := NULL;
    END IF;
    IF (l_ovdv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ovdv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ovdv_rec);
  END null_out_defaults;
/**********************RPOONUGA001: Commenting Old Code ******************************
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKL_OPV_RULES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_ovdv_rec IN  ovdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ovdv_rec.id = OKC_API.G_MISS_NUM OR
       p_ovdv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovdv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_ovdv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovdv_rec.orl_id = OKC_API.G_MISS_NUM OR
          p_ovdv_rec.orl_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'orl_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovdv_rec.ove_id = OKC_API.G_MISS_NUM OR
          p_ovdv_rec.ove_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ove_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ovdv_rec.copy_or_enter_flag = OKC_API.G_MISS_CHAR OR
          p_ovdv_rec.copy_or_enter_flag IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'copy_or_enter_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate_Record for:OKL_OPV_RULES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_ovdv_rec IN ovdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  **********************RPOONUGA001: Commenting Old Code ******************************/

  /************************** RPOONUGA001: Start New Code *****************************/
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
  PROCEDURE Validate_Id(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovdv_rec.id IS NULL) OR
       (p_ovdv_rec.id = OKC_API.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_Orl_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Orl_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Orl_Id(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_orlv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_opt_rules_v
       WHERE okl_opt_rules_v.id = p_id;

      l_orl_status                   VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovdv_rec.orl_id IS NULL) OR
       (p_ovdv_rec.orl_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'orl_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_ovdv_rec.ORL_ID IS NOT NULL)
      THEN
        OPEN okl_orlv_pk_csr(p_ovdv_rec.ORL_ID);
        FETCH okl_orlv_pk_csr INTO l_orl_status;
        l_row_notfound := okl_orlv_pk_csr%NOTFOUND;
        CLOSE okl_orlv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ORL_ID');
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

  END Validate_Orl_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ove_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ove_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Ove_Id(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_ovev_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_opt_values_v
       WHERE okl_opt_values_v.id = p_id;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
      l_ove_status                   VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovdv_rec.ove_id IS NULL) OR
       (p_ovdv_rec.ove_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'ove_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_ovdv_rec.OVE_ID IS NOT NULL)
      THEN
        OPEN okl_ovev_pk_csr(p_ovdv_rec.OVE_ID);
        FETCH okl_ovev_pk_csr INTO l_ove_status;
        l_row_notfound := okl_ovev_pk_csr%NOTFOUND;
        CLOSE okl_ovev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OVE_ID');
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

  END Validate_Ove_Id;

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
  PROCEDURE Validate_Object_Version_Number(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_ovdv_rec.object_version_number IS NULL) OR
       (p_ovdv_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_Copy_Or_Enter_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Copy_Or_Enter_Flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Copy_Or_Enter_Flag(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    l_return_status := OKL_ACCOUNTING_UTIL.validate_lookup_code(G_LOOKUP_TYPE,p_ovdv_rec.copy_or_enter_flag);

      IF l_return_status = OKC_API.G_FALSE THEN
         l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;



    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'copy_or_enter_flag');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Copy_Or_Enter_Flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Context_Intent
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Context_Intent
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Context_Intent(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    l_return_status := OKL_ACCOUNTING_UTIL.validate_lookup_code(G_INTENT_TYPE,p_ovdv_rec.context_intent);
     IF l_return_status = OKC_API.G_FALSE THEN
         l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;


    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'context_intent');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
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

  END Validate_Context_Intent;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Context_Org
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Context_Org
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Context_Org(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_okx_orgv_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
      FROM okx_organization_defs_v ood
      WHERE ood.organization_id = p_id
      AND ood.organization_type = 'OPERATING_UNIT'
      AND ood.information_type = 'Operating Unit Information'
      AND ood.b_status = 'Y';

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
      l_okx_status                   VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_ovdv_rec.context_org IS NOT NULL AND
        p_ovdv_rec.context_org <> OKL_API.G_MISS_NUM)
      THEN
        OPEN okl_okx_orgv_csr(p_ovdv_rec.context_org);
        FETCH okl_okx_orgv_csr INTO l_okx_status;
        l_row_notfound := okl_okx_orgv_csr%NOTFOUND;
        CLOSE okl_okx_orgv_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Context_Org');
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

  END Validate_Context_Org;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Context_Inv_Org
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Context_Inv_Org
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Context_Inv_Org(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_okx_iorgv_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
      FROM okx_organization_defs_v ood
      WHERE ood.organization_id = p_id
      AND ood.organization_type = 'INV'
      AND ood.information_type = 'Accounting Information'
      AND ood.b_status = 'Y'
      AND ood.organization_code IS NOT NULL;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
      l_okx_status                   VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_ovdv_rec.context_inv_org IS NOT NULL AND
        p_ovdv_rec.context_inv_org <> OKL_API.G_MISS_NUM)
      THEN
        OPEN okl_okx_iorgv_csr(p_ovdv_rec.context_inv_org);
        FETCH okl_okx_iorgv_csr INTO l_okx_status;
        l_row_notfound := okl_okx_iorgv_csr%NOTFOUND;
        CLOSE okl_okx_iorgv_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'context_inv_org');
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

  END Validate_Context_Inv_Org;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Context_Asset_Book
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Context_Asset_Book
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Context_Asset_Book(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS
      CURSOR okl_okx_abv_csr (p_name                 IN VARCHAR2) IS
      SELECT  '1'
      FROM okx_asst_bk_controls_v oab
      WHERE oab.name = p_name
      AND oab.book_class = 'CORPORATE';

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
      l_okx_status                   VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_ovdv_rec.context_asset_book IS NOT NULL AND
        p_ovdv_rec.context_asset_book <> OKL_API.G_MISS_CHAR)
      THEN
        OPEN okl_okx_abv_csr(p_ovdv_rec.context_asset_book);
        FETCH okl_okx_abv_csr INTO l_okx_status;
        l_row_notfound := okl_okx_abv_csr%NOTFOUND;
        CLOSE okl_okx_abv_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'context_asset_book');
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

  END Validate_Context_Asset_Book;

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
    p_ovdv_rec IN  ovdv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Id
    Validate_Id(p_ovdv_rec,x_return_status);
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
    Validate_Object_Version_Number(p_ovdv_rec,x_return_status);
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

    -- Validate_Orl_Id
    Validate_Orl_Id(p_ovdv_rec,x_return_status);
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

    -- Validate_Ove_Id
    Validate_Ove_Id(p_ovdv_rec,x_return_status);
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

    -- Validate_Copy_Or_Enter_Flag
    Validate_Copy_Or_Enter_Flag(p_ovdv_rec,x_return_status);
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

    -- Validate_Context_Intent
    Validate_Context_Intent(p_ovdv_rec,x_return_status);
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

    -- Validate_Context_Org
    Validate_Context_Org(p_ovdv_rec,x_return_status);
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

    -- Validate_Context_Inv_Org
    Validate_Context_Inv_Org(p_ovdv_rec,x_return_status);
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

    -- Validate_Context_Asset_Book
    Validate_Context_Asset_Book(p_ovdv_rec,x_return_status);
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
  -- PROCEDURE Validate_Unique_Ovd_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Ovd_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Ovd_Record(p_ovdv_rec      IN   ovdv_rec_type
  									 ,x_return_status OUT NOCOPY  VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_ovd_status            VARCHAR2(1);
  l_context_org           NUMBER;
  l_context_inv_org       NUMBER;
  l_context_asset_book    VARCHAR2(100) := NULL;
  l_row_found             Boolean := False;
  CURSOR c1(p_orl_id okl_opv_rules_v.orl_id%TYPE,
		    p_ove_id okl_opv_rules_v.ove_id%TYPE,
            p_context_intent okl_opv_rules_v.context_intent%TYPE,
            p_context_org okl_opv_rules_v.context_org%TYPE,
            p_context_inv_org okl_opv_rules_v.context_inv_org%TYPE,
            p_context_asset_book okl_opv_rules_v.context_asset_book%TYPE) is
  SELECT '1'
  FROM okl_opv_rules_v
  WHERE  orl_id = p_orl_id
  AND    ove_id = p_ove_id
  AND    context_intent = p_context_intent
  AND    (context_org IS NULL OR context_org = p_context_org)
  AND    (context_inv_org IS NULL OR context_inv_org = p_context_inv_org)
  AND    (context_asset_book IS NULL OR context_asset_book = p_context_asset_book)
  AND    id <> nvl(p_ovdv_rec.id,-9999);

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_ovdv_rec.context_org = OKL_API.G_MISS_NUM THEN
       l_context_org  := NULL;
    ELSE
       l_context_org := p_ovdv_rec.context_org;
    END IF;
    IF p_ovdv_rec.context_inv_org = OKL_API.G_MISS_NUM THEN
       l_context_inv_org  := NULL;
    ELSE
       l_context_inv_org := p_ovdv_rec.context_inv_org;
    END IF;
    IF p_ovdv_rec.context_asset_book = OKL_API.G_MISS_CHAR THEN
       l_context_asset_book  := NULL;
    ELSE
       l_context_asset_book := p_ovdv_rec.context_asset_book;
    END IF;
    OPEN c1(p_ovdv_rec.orl_id,
	        p_ovdv_rec.ove_id,
            p_ovdv_rec.context_intent,
            l_context_org,
            l_context_inv_org,
            l_context_asset_book);
    FETCH c1 into l_ovd_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		OKC_API.set_message(G_APP_NAME,G_UNQS, G_TABLE_TOKEN, 'Okl_Opv_Rules_V');
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

  END Validate_Unique_Ovd_Record;
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
    p_ovdv_rec IN ovdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_Ovd_Record
    Validate_Unique_Ovd_Record(p_ovdv_rec,x_return_status);
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

/************************************** RPOONUGA001: End New Code *************************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  -- RPOONUGA001: Add IN to p_to parameter of migrate procedure
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ovdv_rec_type,
    p_to	IN OUT NOCOPY ovd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.context_intent := p_from.context_intent;
    p_to.orl_id := p_from.orl_id;
    p_to.ove_id := p_from.ove_id;
    p_to.copy_or_enter_flag := p_from.copy_or_enter_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.context_inv_org := p_from.context_inv_org;
    p_to.context_org := p_from.context_org;
    p_to.context_asset_book := p_from.context_asset_book;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.individual_instructions := p_from.individual_instructions;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ovd_rec_type,
    p_to	IN OUT NOCOPY ovdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.context_intent := p_from.context_intent;
    p_to.orl_id := p_from.orl_id;
    p_to.ove_id := p_from.ove_id;
    p_to.copy_or_enter_flag := p_from.copy_or_enter_flag;
    p_to.object_version_number := p_from.object_version_number;
    p_to.context_inv_org := p_from.context_inv_org;
    p_to.context_org := p_from.context_org;
    p_to.context_asset_book := p_from.context_asset_book;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.individual_instructions := p_from.individual_instructions;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_OPV_RULES_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovdv_rec                     ovdv_rec_type := p_ovdv_rec;
    l_ovd_rec                      ovd_rec_type;
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
    l_return_status := Validate_Attributes(l_ovdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ovdv_rec);
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
  -- PL/SQL TBL validate_row for:OVDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovdv_tbl.COUNT > 0) THEN
      i := p_ovdv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovdv_rec                     => p_ovdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_ovdv_tbl.LAST);
        i := p_ovdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- insert_row for:OKL_OPV_RULES --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_rec                      IN ovd_rec_type,
    x_ovd_rec                      OUT NOCOPY ovd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovd_rec                      ovd_rec_type := p_ovd_rec;
    l_def_ovd_rec                  ovd_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKL_OPV_RULES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_ovd_rec IN  ovd_rec_type,
      x_ovd_rec OUT NOCOPY ovd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovd_rec := p_ovd_rec;
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
      p_ovd_rec,                         -- IN
      l_ovd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_OPV_RULES(
        id,
        context_intent,
        orl_id,
        ove_id,
        copy_or_enter_flag,
        object_version_number,
        context_inv_org,
        context_org,
        context_asset_book,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        individual_instructions,
        last_update_login)
      VALUES (
        l_ovd_rec.id,
        l_ovd_rec.context_intent,
        l_ovd_rec.orl_id,
        l_ovd_rec.ove_id,
        l_ovd_rec.copy_or_enter_flag,
        l_ovd_rec.object_version_number,
        l_ovd_rec.context_inv_org,
        l_ovd_rec.context_org,
        l_ovd_rec.context_asset_book,
        l_ovd_rec.created_by,
        l_ovd_rec.creation_date,
        l_ovd_rec.last_updated_by,
        l_ovd_rec.last_update_date,
        l_ovd_rec.individual_instructions,
        l_ovd_rec.last_update_login);
    -- Set OUT values
    x_ovd_rec := l_ovd_rec;
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
  -- insert_row for:OKL_OPV_RULES_V --
  ------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type,
    x_ovdv_rec                     OUT NOCOPY ovdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovdv_rec                     ovdv_rec_type;
    l_def_ovdv_rec                 ovdv_rec_type;
    l_ovd_rec                      ovd_rec_type;
    lx_ovd_rec                     ovd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ovdv_rec	IN ovdv_rec_type
    ) RETURN ovdv_rec_type IS
      l_ovdv_rec	ovdv_rec_type := p_ovdv_rec;
    BEGIN
      l_ovdv_rec.CREATION_DATE := SYSDATE;
      l_ovdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ovdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ovdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ovdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ovdv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_OPV_RULES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_ovdv_rec IN  ovdv_rec_type,
      x_ovdv_rec OUT NOCOPY ovdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovdv_rec := p_ovdv_rec;
      x_ovdv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_ovdv_rec := null_out_defaults(p_ovdv_rec);
    -- Set primary key value
    l_ovdv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ovdv_rec,                        -- IN
      l_def_ovdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ovdv_rec := fill_who_columns(l_def_ovdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ovdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ovdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ovdv_rec, l_ovd_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovd_rec,
      lx_ovd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ovd_rec, l_def_ovdv_rec);
    -- Set OUT values
    x_ovdv_rec := l_def_ovdv_rec;
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
  -- PL/SQL TBL insert_row for:OVDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type,
    x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovdv_tbl.COUNT > 0) THEN
      i := p_ovdv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovdv_rec                     => p_ovdv_tbl(i),
          x_ovdv_rec                     => x_ovdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_ovdv_tbl.LAST);
        i := p_ovdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- lock_row for:OKL_OPV_RULES --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_rec                      IN ovd_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ovd_rec IN ovd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPV_RULES
     WHERE ID = p_ovd_rec.id
       AND OBJECT_VERSION_NUMBER = p_ovd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ovd_rec IN ovd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_OPV_RULES
    WHERE ID = p_ovd_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_OPV_RULES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_OPV_RULES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ovd_rec);
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
      OPEN lchk_csr(p_ovd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ovd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ovd_rec.object_version_number THEN
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
  -- lock_row for:OKL_OPV_RULES_V --
  ----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovd_rec                      ovd_rec_type;
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
    migrate(p_ovdv_rec, l_ovd_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovd_rec
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
  -- PL/SQL TBL lock_row for:OVDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovdv_tbl.COUNT > 0) THEN
      i := p_ovdv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovdv_rec                     => p_ovdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_ovdv_tbl.LAST);
        i := p_ovdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- update_row for:OKL_OPV_RULES --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_rec                      IN ovd_rec_type,
    x_ovd_rec                      OUT NOCOPY ovd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovd_rec                      ovd_rec_type := p_ovd_rec;
    l_def_ovd_rec                  ovd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ovd_rec	IN ovd_rec_type,
      x_ovd_rec	OUT NOCOPY ovd_rec_type
    ) RETURN VARCHAR2 IS
      l_ovd_rec                      ovd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovd_rec := p_ovd_rec;
      -- Get current database values
      l_ovd_rec := get_rec(p_ovd_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ovd_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.id := l_ovd_rec.id;
      END IF;
      IF (x_ovd_rec.context_intent = OKC_API.G_MISS_CHAR)
      THEN
        x_ovd_rec.context_intent := l_ovd_rec.context_intent;
      END IF;
      IF (x_ovd_rec.orl_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.orl_id := l_ovd_rec.orl_id;
      END IF;
      IF (x_ovd_rec.ove_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.ove_id := l_ovd_rec.ove_id;
      END IF;
      IF (x_ovd_rec.copy_or_enter_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_ovd_rec.copy_or_enter_flag := l_ovd_rec.copy_or_enter_flag;
      END IF;
      IF (x_ovd_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.object_version_number := l_ovd_rec.object_version_number;
      END IF;
      IF (x_ovd_rec.context_inv_org = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.context_inv_org := l_ovd_rec.context_inv_org;
      END IF;
      IF (x_ovd_rec.context_org = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.context_org := l_ovd_rec.context_org;
      END IF;
      IF (x_ovd_rec.context_asset_book = OKC_API.G_MISS_CHAR)
      THEN
        x_ovd_rec.context_asset_book := l_ovd_rec.context_asset_book;
      END IF;
      IF (x_ovd_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.created_by := l_ovd_rec.created_by;
      END IF;
      IF (x_ovd_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovd_rec.creation_date := l_ovd_rec.creation_date;
      END IF;
      IF (x_ovd_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.last_updated_by := l_ovd_rec.last_updated_by;
      END IF;
      IF (x_ovd_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovd_rec.last_update_date := l_ovd_rec.last_update_date;
      END IF;
      IF (x_ovd_rec.individual_instructions = OKC_API.G_MISS_CHAR)
      THEN
        x_ovd_rec.individual_instructions := l_ovd_rec.individual_instructions;
      END IF;
      IF (x_ovd_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ovd_rec.last_update_login := l_ovd_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_OPV_RULES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_ovd_rec IN  ovd_rec_type,
      x_ovd_rec OUT NOCOPY ovd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovd_rec := p_ovd_rec;
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
      p_ovd_rec,                         -- IN
      l_ovd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ovd_rec, l_def_ovd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_OPV_RULES
    SET CONTEXT_INTENT = l_def_ovd_rec.context_intent,
        ORL_ID = l_def_ovd_rec.orl_id,
        OVE_ID = l_def_ovd_rec.ove_id,
        COPY_OR_ENTER_FLAG = l_def_ovd_rec.copy_or_enter_flag,
        OBJECT_VERSION_NUMBER = l_def_ovd_rec.object_version_number,
        CONTEXT_INV_ORG = l_def_ovd_rec.context_inv_org,
        CONTEXT_ORG = l_def_ovd_rec.context_org,
        CONTEXT_ASSET_BOOK = l_def_ovd_rec.context_asset_book,
        CREATED_BY = l_def_ovd_rec.created_by,
        CREATION_DATE = l_def_ovd_rec.creation_date,
        LAST_UPDATED_BY = l_def_ovd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ovd_rec.last_update_date,
        INDIVIDUAL_INSTRUCTIONS = l_def_ovd_rec.individual_instructions,
        LAST_UPDATE_LOGIN = l_def_ovd_rec.last_update_login
    WHERE ID = l_def_ovd_rec.id;

    x_ovd_rec := l_def_ovd_rec;
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
  -- update_row for:OKL_OPV_RULES_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type,
    x_ovdv_rec                     OUT NOCOPY ovdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovdv_rec                     ovdv_rec_type := p_ovdv_rec;
    l_def_ovdv_rec                 ovdv_rec_type;
    l_ovd_rec                      ovd_rec_type;
    lx_ovd_rec                     ovd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ovdv_rec	IN ovdv_rec_type
    ) RETURN ovdv_rec_type IS
      l_ovdv_rec	ovdv_rec_type := p_ovdv_rec;
    BEGIN
      l_ovdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ovdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ovdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ovdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ovdv_rec	IN ovdv_rec_type,
      x_ovdv_rec	OUT NOCOPY ovdv_rec_type
    ) RETURN VARCHAR2 IS
      l_ovdv_rec                     ovdv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovdv_rec := p_ovdv_rec;
      -- Get current database values
      l_ovdv_rec := get_rec(p_ovdv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ovdv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.id := l_ovdv_rec.id;
      END IF;
      IF (x_ovdv_rec.context_intent = OKC_API.G_MISS_CHAR)
      THEN
        x_ovdv_rec.context_intent := l_ovdv_rec.context_intent;
      END IF;
      IF (x_ovdv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.object_version_number := l_ovdv_rec.object_version_number;
      END IF;
      IF (x_ovdv_rec.orl_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.orl_id := l_ovdv_rec.orl_id;
      END IF;
      IF (x_ovdv_rec.ove_id = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.ove_id := l_ovdv_rec.ove_id;
      END IF;
      IF (x_ovdv_rec.individual_instructions = OKC_API.G_MISS_CHAR)
      THEN
        x_ovdv_rec.individual_instructions := l_ovdv_rec.individual_instructions;
      END IF;
      IF (x_ovdv_rec.copy_or_enter_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_ovdv_rec.copy_or_enter_flag := l_ovdv_rec.copy_or_enter_flag;
      END IF;
      IF (x_ovdv_rec.context_org = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.context_org := l_ovdv_rec.context_org;
      END IF;
      IF (x_ovdv_rec.context_inv_org = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.context_inv_org := l_ovdv_rec.context_inv_org;
      END IF;
      IF (x_ovdv_rec.context_asset_book = OKC_API.G_MISS_CHAR)
      THEN
        x_ovdv_rec.context_asset_book := l_ovdv_rec.context_asset_book;
      END IF;
      IF (x_ovdv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.created_by := l_ovdv_rec.created_by;
      END IF;
      IF (x_ovdv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovdv_rec.creation_date := l_ovdv_rec.creation_date;
      END IF;
      IF (x_ovdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.last_updated_by := l_ovdv_rec.last_updated_by;
      END IF;
      IF (x_ovdv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ovdv_rec.last_update_date := l_ovdv_rec.last_update_date;
      END IF;
      IF (x_ovdv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ovdv_rec.last_update_login := l_ovdv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_OPV_RULES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_ovdv_rec IN  ovdv_rec_type,
      x_ovdv_rec OUT NOCOPY ovdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ovdv_rec := p_ovdv_rec;
      x_ovdv_rec.OBJECT_VERSION_NUMBER := NVL(x_ovdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_ovdv_rec,                        -- IN
      l_ovdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ovdv_rec, l_def_ovdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ovdv_rec := fill_who_columns(l_def_ovdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ovdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ovdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ovdv_rec, l_ovd_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovd_rec,
      lx_ovd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ovd_rec, l_def_ovdv_rec);
    x_ovdv_rec := l_def_ovdv_rec;
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
  -- PL/SQL TBL update_row for:OVDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type,
    x_ovdv_tbl                     OUT NOCOPY ovdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovdv_tbl.COUNT > 0) THEN
      i := p_ovdv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovdv_rec                     => p_ovdv_tbl(i),
          x_ovdv_rec                     => x_ovdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_ovdv_tbl.LAST);
        i := p_ovdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
  -- delete_row for:OKL_OPV_RULES --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovd_rec                      IN ovd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RULES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovd_rec                      ovd_rec_type:= p_ovd_rec;
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
    DELETE FROM OKL_OPV_RULES
     WHERE ID = l_ovd_rec.id;

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
  -- delete_row for:OKL_OPV_RULES_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_rec                     IN ovdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ovdv_rec                     ovdv_rec_type := p_ovdv_rec;
    l_ovd_rec                      ovd_rec_type;
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
    migrate(l_ovdv_rec, l_ovd_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ovd_rec
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
  -- PL/SQL TBL delete_row for:OVDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ovdv_tbl                     IN ovdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ovdv_tbl.COUNT > 0) THEN
      i := p_ovdv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ovdv_rec                     => p_ovdv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_ovdv_tbl.LAST);
        i := p_ovdv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
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
END OKL_OVD_PVT;

/
