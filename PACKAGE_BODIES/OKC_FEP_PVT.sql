--------------------------------------------------------
--  DDL for Package Body OKC_FEP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_FEP_PVT" AS
/* $Header: OKCSFEPB.pls 120.0 2005/05/25 22:42:08 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
  -- FUNCTION get_rec for: OKC_FUNCTION_EXPR_PARAMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fep_rec                      IN fep_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fep_rec_type IS
    CURSOR okc_function_expr_pa1_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CNL_ID,
            PDP_ID,
            AAE_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            VALUE,
            APPLICATION_ID,
            SEEDED_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Function_Expr_Params
     WHERE okc_function_expr_params.id = p_id;
    l_okc_function_expr_params_pk  okc_function_expr_pa1_csr%ROWTYPE;
    l_fep_rec                      fep_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_function_expr_pa1_csr (p_fep_rec.id);
    FETCH okc_function_expr_pa1_csr INTO
              l_fep_rec.ID,
              l_fep_rec.CNL_ID,
              l_fep_rec.PDP_ID,
              l_fep_rec.AAE_ID,
              l_fep_rec.DNZ_CHR_ID,
              l_fep_rec.OBJECT_VERSION_NUMBER,
              l_fep_rec.VALUE,
              l_fep_rec.APPLICATION_ID,
              l_fep_rec.SEEDED_FLAG,
              l_fep_rec.CREATED_BY,
              l_fep_rec.CREATION_DATE,
              l_fep_rec.LAST_UPDATED_BY,
              l_fep_rec.LAST_UPDATE_DATE,
              l_fep_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_function_expr_pa1_csr%NOTFOUND;
    CLOSE okc_function_expr_pa1_csr;
    RETURN(l_fep_rec);
  END get_rec;

  FUNCTION get_rec (
    p_fep_rec                      IN fep_rec_type
  ) RETURN fep_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fep_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_FUNCTION_EXPR_PARAMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fepv_rec                     IN fepv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fepv_rec_type IS
    CURSOR okc_fepv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CNL_ID,
            PDP_ID,
            AAE_ID,
            DNZ_CHR_ID,
            VALUE,
            APPLICATION_ID,
            SEEDED_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Function_Expr_Params_V
     WHERE okc_function_expr_params_v.id = p_id;
    l_okc_fepv_pk                  okc_fepv_pk_csr%ROWTYPE;
    l_fepv_rec                     fepv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_fepv_pk_csr (p_fepv_rec.id);
    FETCH okc_fepv_pk_csr INTO
              l_fepv_rec.ID,
              l_fepv_rec.OBJECT_VERSION_NUMBER,
              l_fepv_rec.CNL_ID,
              l_fepv_rec.PDP_ID,
              l_fepv_rec.AAE_ID,
              l_fepv_rec.DNZ_CHR_ID,
              l_fepv_rec.VALUE,
              l_fepv_rec.APPLICATION_ID,
              l_fepv_rec.SEEDED_FLAG,
              l_fepv_rec.CREATED_BY,
              l_fepv_rec.CREATION_DATE,
              l_fepv_rec.LAST_UPDATED_BY,
              l_fepv_rec.LAST_UPDATE_DATE,
              l_fepv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_fepv_pk_csr%NOTFOUND;
    CLOSE okc_fepv_pk_csr;
    RETURN(l_fepv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_fepv_rec                     IN fepv_rec_type
  ) RETURN fepv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fepv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_FUNCTION_EXPR_PARAMS_V --
  ----------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_fepv_rec	IN fepv_rec_type
  ) RETURN fepv_rec_type IS
    l_fepv_rec	fepv_rec_type := p_fepv_rec;
  BEGIN
    IF (l_fepv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.object_version_number := NULL;
    END IF;
    IF (l_fepv_rec.cnl_id = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.cnl_id := NULL;
    END IF;
    IF (l_fepv_rec.pdp_id = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.pdp_id := NULL;
    END IF;
    IF (l_fepv_rec.aae_id = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.aae_id := NULL;
    END IF;
    IF (l_fepv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_fepv_rec.value = OKC_API.G_MISS_CHAR) THEN
      l_fepv_rec.value := NULL;
    END IF;
    IF (l_fepv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.application_id := NULL;
    END IF;
    IF (l_fepv_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_fepv_rec.seeded_flag := NULL;
    END IF;
    IF (l_fepv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.created_by := NULL;
    END IF;
    IF (l_fepv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_fepv_rec.creation_date := NULL;
    END IF;
    IF (l_fepv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.last_updated_by := NULL;
    END IF;
    IF (l_fepv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_fepv_rec.last_update_date := NULL;
    END IF;
    IF (l_fepv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_fepv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_fepv_rec);
  END null_out_defaults;

  /*** Commented out nocopy generated code in favor of hand written code ***********
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------------
  -- Validate_Attributes for:OKC_FUNCTION_EXPR_PARAMS_V --
  --------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_fepv_rec IN  fepv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_fepv_rec.id = OKC_API.G_MISS_NUM OR
       p_fepv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fepv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_fepv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fepv_rec.cnl_id = OKC_API.G_MISS_NUM OR
          p_fepv_rec.cnl_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cnl_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_fepv_rec.pdp_id = OKC_API.G_MISS_NUM OR
          p_fepv_rec.pdp_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdp_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Record for:OKC_FUNCTION_EXPR_PARAMS_V --
  ----------------------------------------------------
  FUNCTION Validate_Record (
    p_fepv_rec IN fepv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_fepv_rec IN fepv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_cnlv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              CNH_ID,
              PDF_ID,
              AAE_ID,
              LEFT_CTR_MASTER_ID,
              RIGHT_CTR_MASTER_ID,
              LEFT_COUNTER_ID,
              RIGHT_COUNTER_ID,
              DNZ_CHR_ID,
              SORTSEQ,
              CNL_TYPE,
              DESCRIPTION,
              LEFT_PARENTHESIS,
              RELATIONAL_OPERATOR,
              RIGHT_PARENTHESIS,
              LOGICAL_OPERATOR,
              TOLERANCE,
              START_AT,
              RIGHT_OPERAND,
              APPLICATION_ID,
              SEEDED_FLAG,
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
        FROM Okc_Condition_Lines_V
       WHERE okc_condition_lines_v.id = p_id;
      l_okc_cnlv_pk                  okc_cnlv_pk_csr%ROWTYPE;
      CURSOR okc_aaev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              AAL_ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              ACN_ID,
              ELEMENT_NAME,
              NAME,
              DESCRIPTION,
              DATA_TYPE,
              LIST_YN,
              VISIBLE_YN,
              DATE_OF_INTEREST_YN,
              FORMAT_MASK,
              MINIMUM_VALUE,
              MAXIMUM_VALUE,
              APPLICATION_ID,
              SEEDED_FLAG,
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
        FROM Okc_Action_Attributes_V
       WHERE okc_action_attributes_v.id = p_id;
      l_okc_aaev_pk                  okc_aaev_pk_csr%ROWTYPE;
      CURSOR okc_pdfv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              DESCRIPTION,
              SHORT_DESCRIPTION,
              COMMENTS,
              USAGE,
              NAME,
              WF_NAME,
              WF_PROCESS_NAME,
              PROCEDURE_NAME,
              PACKAGE_NAME,
              PDF_TYPE,
              APPLICATION_ID,
              SEEDED_FLAG,
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
              BEGIN_DATE,
              END_DATE,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okc_Process_Defs_V
       WHERE okc_process_defs_v.id = p_id;
      l_okc_pdfv_pk                  okc_pdfv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_fepv_rec.CNL_ID IS NOT NULL)
      THEN
        OPEN okc_cnlv_pk_csr(p_fepv_rec.CNL_ID);
        FETCH okc_cnlv_pk_csr INTO l_okc_cnlv_pk;
        l_row_notfound := okc_cnlv_pk_csr%NOTFOUND;
        CLOSE okc_cnlv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CNL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_fepv_rec.AAE_ID IS NOT NULL)
      THEN
        OPEN okc_aaev_pk_csr(p_fepv_rec.AAE_ID);
        FETCH okc_aaev_pk_csr INTO l_okc_aaev_pk;
        l_row_notfound := okc_aaev_pk_csr%NOTFOUND;
        CLOSE okc_aaev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_fepv_rec.PDP_ID IS NOT NULL)
      THEN
        OPEN okc_pdfv_pk_csr(p_fepv_rec.PDP_ID);
        FETCH okc_pdfv_pk_csr INTO l_okc_pdfv_pk;
        l_row_notfound := okc_pdfv_pk_csr%NOTFOUND;
        CLOSE okc_pdfv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDP_ID');
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
    l_return_status := validate_foreign_keys (p_fepv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ****** End Generated code ************************************************/

  /***** Begin Hand Written Code *******************************************/

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
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_fepv_rec      IN   fepv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_fepv_rec.object_version_number IS NULL) OR
       (p_fepv_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
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
  -- PROCEDURE Validate_Seeded_Flag
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Seeded_Flag
  -- Description     : Checks if column SEEDED_FLAG is 'Y' or 'N' only
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE validate_seeded_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
    	p_fepv_rec              IN fepv_rec_type) IS
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_fepv_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_fepv_rec.seeded_flag <> UPPER(p_fepv_rec.seeded_flag) THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_uppercase_required,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_seeded_flag;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Application_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Application_Id
  -- Description     : Checks if application_id exists in fnd_application
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
   PROCEDURE validate_application_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
    	p_fepv_rec              IN fepv_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_fepv_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_fepv_rec.application_id);
	FETCH application_id_cur INTO l_dummy;
	CLOSE application_id_cur ;
	IF l_dummy = '?' THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'application_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;
     END IF;
    EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_unexpected_error,
                        	    p_token1       => g_sqlcode_token,
                        	    p_token1_value => sqlcode,
                        	    p_token2       => g_sqlerrm_token,
                        	    p_token2_value => sqlerrm);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_application_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Cnl_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Cnl_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cnl_Id(x_return_status OUT NOCOPY  VARCHAR2
                           ,p_fepv_rec      IN   fepv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_fepv_rec.cnl_id IS NULL) OR
       (p_fepv_rec.cnl_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'cnl_id');
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

  END Validate_Cnl_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pdp_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Pdp_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pdp_Id(x_return_status OUT NOCOPY  VARCHAR2
                           ,p_fepv_rec      IN   fepv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_fepv_rec.pdp_id IS NULL) OR
       (p_fepv_rec.pdp_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'pdp_id');
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

  END Validate_Pdp_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Value(x_return_status OUT NOCOPY  VARCHAR2
                          ,p_fepv_rec      IN   fepv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_temp                  NUMBER       ;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- check that value should not contain the special characters
      l_temp := INSTR(p_fepv_rec.value,'<');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'>');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'?');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'[');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,']');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'/');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'#');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'.');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'=');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'!');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,',');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,'(');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      l_temp := INSTR(p_fepv_rec.value,')');
      IF l_temp <> 0 THEN
       OKC_API.SET_MESSAGE(p_app_name      => g_app_name
                          ,p_msg_name      => g_invalid_value
                          ,p_token1        => g_col_name_token
                          ,p_token1_value  => 'value');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
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

  END Validate_Value;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Fep_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Fep_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Fep_Record(x_return_status OUT NOCOPY     VARCHAR2
                                      ,p_fepv_rec      IN      fepv_rec_type) IS


  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  --l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1(p_cnl_id okc_function_expr_params_v.cnl_id%TYPE,
		  p_pdp_id okc_function_expr_params_v.pdp_id%TYPE) is
  SELECT 1
  FROM okc_function_expr_params
  WHERE  cnl_id = p_cnl_id
  AND    pdp_id = p_pdp_id
  AND    id <> nvl(p_fepv_rec.id,-99999);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;


  /*Bug 1636056:The following code commented out nocopy since it was not using bind
	    variables and parsing was taking place.Replaced with explicit cursor
	    as above

    -- initialize columns of unique concatenated key

    l_unq_tbl(1).p_col_name   := 'cnl_id';
    l_unq_tbl(1).p_col_val    := p_fepv_rec.cnl_id;
    l_unq_tbl(2).p_col_name   := 'pdp_id';
    l_unq_tbl(2).p_col_val    := p_fepv_rec.pdp_id;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

      -- call check_comp_unique utility
      OKC_UTIL.CHECK_COMP_UNIQUE(p_view_name   => 'OKC_FUNCTION_EXPR_PARAMS_V'
                           ,p_col_tbl          => l_unq_tbl
                           ,p_id               => p_fepv_rec.id
                           ,x_return_status    => l_return_status);


      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
	 */
    OPEN c1(p_fepv_rec.cnl_id,
		  p_fepv_rec.pdp_id);
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		--OKC_API.set_message(G_APP_NAME,G_UNQS,G_COL_NAME_TOKEN1,'cnl_id',G_COL_NAME_TOKEN2,'pdp_id');
		OKC_API.set_message(G_APP_NAME,G_UNQS);
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

  END Validate_Unique_Fep_Record;

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
    FUNCTION validate_foreign_keys (
      p_fepv_rec IN fepv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_cnlv_pk_csr (p_id                 IN NUMBER) IS
      SELECT '1'
        FROM Okc_Condition_Lines_V
       WHERE okc_condition_lines_v.id = p_id;

      l_dummy_var                   VARCHAR2(1);

      CURSOR okc_aaev_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Action_Attributes_V
       WHERE okc_action_attributes_v.id = p_id;

      l_dummy                       VARCHAR2(1);

      CURSOR okc_pdpv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM Okc_Process_Def_Parameters_V
       WHERE okc_process_def_parameters_v.id = p_id;

      l_dummy1                      VARCHAR2(1);

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_fepv_rec.CNL_ID IS NOT NULL)
      THEN
        OPEN okc_cnlv_pk_csr(p_fepv_rec.CNL_ID);
        FETCH okc_cnlv_pk_csr INTO l_dummy_var;
        l_row_notfound := okc_cnlv_pk_csr%NOTFOUND;
        CLOSE okc_cnlv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CNL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_fepv_rec.AAE_ID IS NOT NULL)
      THEN
        OPEN okc_aaev_pk_csr(p_fepv_rec.AAE_ID);
        FETCH okc_aaev_pk_csr INTO l_dummy;
        l_row_notfound := okc_aaev_pk_csr%NOTFOUND;
        CLOSE okc_aaev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_fepv_rec.PDP_ID IS NOT NULL)
      THEN
        OPEN okc_pdpv_pk_csr(p_fepv_rec.PDP_ID);
        FETCH okc_pdpv_pk_csr INTO l_dummy;
        l_row_notfound := okc_pdpv_pk_csr%NOTFOUND;
        CLOSE okc_pdpv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDP_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;

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
    p_fepv_rec IN  fepv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call each column-level validation

    -- Validate_Id
    IF p_fepv_rec.id = OKC_API.G_MISS_NUM OR
	  p_fepv_rec.id IS NULL
    THEN
	  OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
	  l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- Validate Object_Version_Number
    Validate_Object_Version_Number(x_return_status,p_fepv_rec);
    -- store the highest degree of error
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

    -- Validate Seeded_Flag
    Validate_Seeded_Flag(x_return_status,p_fepv_rec);
    -- store the highest degree of error
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

    -- Validate Application_Id
    Validate_Application_Id(x_return_status,p_fepv_rec);
    -- store the highest degree of error
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

    -- Validate Cnl_Id
    Validate_Cnl_Id(x_return_status,p_fepv_rec);
    -- store the highest degree of error
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

    -- Validate Pdp_Id
    Validate_Pdp_Id(x_return_status,p_fepv_rec);
    -- store the highest degree of error
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

    -- Validate_Foreign_Keys;
    l_return_status := Validate_Foreign_Keys(p_fepv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       -- need to leave
       x_return_status := l_return_status;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
       -- record that there was an error
       x_return_status := l_return_status;
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


  FUNCTION Validate_Record (
    p_fepv_rec IN fepv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate Unique_Fep_Record
    Validate_Unique_Fep_Record(x_return_status,p_fepv_rec);
    -- store the highest degree of error
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

    RETURN (l_return_status);
  END Validate_Record;

  /************************ END HAND-CODED CODE ****************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN fepv_rec_type,
    p_to	OUT NOCOPY fep_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cnl_id := p_from.cnl_id;
    p_to.pdp_id := p_from.pdp_id;
    p_to.aae_id := p_from.aae_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.value := p_from.value;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN fep_rec_type,
    p_to	IN OUT NOCOPY fepv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cnl_id := p_from.cnl_id;
    p_to.pdp_id := p_from.pdp_id;
    p_to.aae_id := p_from.aae_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.value := p_from.value;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- validate_row for:OKC_FUNCTION_EXPR_PARAMS_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fepv_rec                     fepv_rec_type := p_fepv_rec;
    l_fep_rec                      fep_rec_type;
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
    l_return_status := Validate_Attributes(l_fepv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_fepv_rec);
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
  -- PL/SQL TBL validate_row for:FEPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fepv_tbl.COUNT > 0) THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fepv_rec                     => p_fepv_tbl(i));
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
      END LOOP;
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
  ---------------------------------------------
  -- insert_row for:OKC_FUNCTION_EXPR_PARAMS --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fep_rec                      IN fep_rec_type,
    x_fep_rec                      OUT NOCOPY fep_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARAMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fep_rec                      fep_rec_type := p_fep_rec;
    l_def_fep_rec                  fep_rec_type;
    -------------------------------------------------
    -- Set_Attributes for:OKC_FUNCTION_EXPR_PARAMS --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_fep_rec IN  fep_rec_type,
      x_fep_rec OUT NOCOPY fep_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fep_rec := p_fep_rec;
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
      p_fep_rec,                         -- IN
      l_fep_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_FUNCTION_EXPR_PARAMS(
        id,
        cnl_id,
        pdp_id,
        aae_id,
        dnz_chr_id,
        object_version_number,
        value,
        application_id,
        seeded_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_fep_rec.id,
        l_fep_rec.cnl_id,
        l_fep_rec.pdp_id,
        l_fep_rec.aae_id,
        l_fep_rec.dnz_chr_id,
        l_fep_rec.object_version_number,
        l_fep_rec.value,
        l_fep_rec.application_id,
        l_fep_rec.seeded_flag,
        l_fep_rec.created_by,
        l_fep_rec.creation_date,
        l_fep_rec.last_updated_by,
        l_fep_rec.last_update_date,
        l_fep_rec.last_update_login);
    -- Set OUT values
    x_fep_rec := l_fep_rec;
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
  -----------------------------------------------
  -- insert_row for:OKC_FUNCTION_EXPR_PARAMS_V --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type,
    x_fepv_rec                     OUT NOCOPY fepv_rec_type) IS

    l_id                  NUMBER ;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fepv_rec                     fepv_rec_type;
    l_def_fepv_rec                 fepv_rec_type;
    l_fep_rec                      fep_rec_type;
    lx_fep_rec                     fep_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fepv_rec	IN fepv_rec_type
    ) RETURN fepv_rec_type IS
      l_fepv_rec	fepv_rec_type := p_fepv_rec;
    BEGIN
      l_fepv_rec.CREATION_DATE := SYSDATE;
      l_fepv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_fepv_rec.LAST_UPDATE_DATE := l_fepv_rec.CREATION_DATE;
      l_fepv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fepv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fepv_rec);
    END fill_who_columns;
    ---------------------------------------------------
    -- Set_Attributes for:OKC_FUNCTION_EXPR_PARAMS_V --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_fepv_rec IN  fepv_rec_type,
      x_fepv_rec OUT NOCOPY fepv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fepv_rec := p_fepv_rec;
      x_fepv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_fepv_rec := null_out_defaults(p_fepv_rec);
    -- Set primary key value
    -- If function expression parameters is created by seed then use sequence generated id
    IF l_fepv_rec.CREATED_BY = 1 THEN
	  SELECT OKC_FUNCTION_EXPR_PARAMS_S1.nextval INTO l_id FROM dual;
	  l_fepv_rec.ID := l_id;
	  l_fepv_rec.seeded_flag := 'Y';
    ELSE
	  l_fepv_rec.ID := get_seq_id;
	  l_fepv_rec.seeded_flag := 'N';
    END IF;
    --l_fepv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_fepv_rec,                        -- IN
      l_def_fepv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fepv_rec := fill_who_columns(l_def_fepv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fepv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fepv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   /********* ADDED TO CHECK THE UNIQUENESS ***************************
    -- Validate Unique_Fep_Record
    Validate_Unique_Fep_Record(x_return_status,p_fepv_rec);
    -- store the highest degree of error
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

   ******** ADDED TO CHECK THE UNIQUENESS ****************************/
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_fepv_rec, l_fep_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fep_rec,
      lx_fep_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fep_rec, l_def_fepv_rec);
    -- Set OUT values
    x_fepv_rec := l_def_fepv_rec;
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
  -- PL/SQL TBL insert_row for:FEPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type,
    x_fepv_tbl                     OUT NOCOPY fepv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fepv_tbl.COUNT > 0) THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fepv_rec                     => p_fepv_tbl(i),
          x_fepv_rec                     => x_fepv_tbl(i));
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------------
  -- lock_row for:OKC_FUNCTION_EXPR_PARAMS --
  -------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fep_rec                      IN fep_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_fep_rec IN fep_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_FUNCTION_EXPR_PARAMS
     WHERE ID = p_fep_rec.id
       AND OBJECT_VERSION_NUMBER = p_fep_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_fep_rec IN fep_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_FUNCTION_EXPR_PARAMS
    WHERE ID = p_fep_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARAMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_FUNCTION_EXPR_PARAMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_FUNCTION_EXPR_PARAMS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_fep_rec);
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
      OPEN lchk_csr(p_fep_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_fep_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_fep_rec.object_version_number THEN
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
  ---------------------------------------------
  -- lock_row for:OKC_FUNCTION_EXPR_PARAMS_V --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fep_rec                      fep_rec_type;
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
    migrate(p_fepv_rec, l_fep_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fep_rec
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
  -- PL/SQL TBL lock_row for:FEPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fepv_tbl.COUNT > 0) THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fepv_rec                     => p_fepv_tbl(i));
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
      END LOOP;
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
  ---------------------------------------------
  -- update_row for:OKC_FUNCTION_EXPR_PARAMS --
  ---------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fep_rec                      IN fep_rec_type,
    x_fep_rec                      OUT NOCOPY fep_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARAMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fep_rec                      fep_rec_type := p_fep_rec;
    l_def_fep_rec                  fep_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fep_rec	IN fep_rec_type,
      x_fep_rec	OUT NOCOPY fep_rec_type
    ) RETURN VARCHAR2 IS
      l_fep_rec                      fep_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fep_rec := p_fep_rec;
      -- Get current database values
      l_fep_rec := get_rec(p_fep_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_fep_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.id := l_fep_rec.id;
      END IF;
      IF (x_fep_rec.cnl_id = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.cnl_id := l_fep_rec.cnl_id;
      END IF;
      IF (x_fep_rec.pdp_id = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.pdp_id := l_fep_rec.pdp_id;
      END IF;
      IF (x_fep_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.aae_id := l_fep_rec.aae_id;
      END IF;
      IF (x_fep_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.dnz_chr_id := l_fep_rec.dnz_chr_id;
      END IF;
      IF (x_fep_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.object_version_number := l_fep_rec.object_version_number;
      END IF;
      IF (x_fep_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_fep_rec.value := l_fep_rec.value;
      END IF;
      IF (x_fep_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.application_id := l_fep_rec.application_id;
      END IF;
      IF (x_fep_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_fep_rec.seeded_flag := l_fep_rec.seeded_flag;
      END IF;
      IF (x_fep_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.created_by := l_fep_rec.created_by;
      END IF;
      IF (x_fep_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_fep_rec.creation_date := l_fep_rec.creation_date;
      END IF;
      IF (x_fep_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.last_updated_by := l_fep_rec.last_updated_by;
      END IF;
      IF (x_fep_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_fep_rec.last_update_date := l_fep_rec.last_update_date;
      END IF;
      IF (x_fep_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_fep_rec.last_update_login := l_fep_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKC_FUNCTION_EXPR_PARAMS --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_fep_rec IN  fep_rec_type,
      x_fep_rec OUT NOCOPY fep_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fep_rec := p_fep_rec;
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
      p_fep_rec,                         -- IN
      l_fep_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fep_rec, l_def_fep_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_FUNCTION_EXPR_PARAMS
    SET CNL_ID = l_def_fep_rec.cnl_id,
        PDP_ID = l_def_fep_rec.pdp_id,
        AAE_ID = l_def_fep_rec.aae_id,
        DNZ_CHR_ID = l_def_fep_rec.dnz_chr_id,
        OBJECT_VERSION_NUMBER = l_def_fep_rec.object_version_number,
        VALUE = l_def_fep_rec.value,
        APPLICATION_ID = l_def_fep_rec.application_id,
        SEEDED_FLAG = l_def_fep_rec.seeded_flag,
        CREATED_BY = l_def_fep_rec.created_by,
        CREATION_DATE = l_def_fep_rec.creation_date,
        LAST_UPDATED_BY = l_def_fep_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_fep_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_fep_rec.last_update_login
    WHERE ID = l_def_fep_rec.id;

    x_fep_rec := l_def_fep_rec;
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
  -----------------------------------------------
  -- update_row for:OKC_FUNCTION_EXPR_PARAMS_V --
  -----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type,
    x_fepv_rec                     OUT NOCOPY fepv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fepv_rec                     fepv_rec_type := p_fepv_rec;
    l_def_fepv_rec                 fepv_rec_type;
    l_fep_rec                      fep_rec_type;
    lx_fep_rec                     fep_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fepv_rec	IN fepv_rec_type
    ) RETURN fepv_rec_type IS
      l_fepv_rec	fepv_rec_type := p_fepv_rec;
    BEGIN
      l_fepv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_fepv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fepv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fepv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fepv_rec	IN fepv_rec_type,
      x_fepv_rec	OUT NOCOPY fepv_rec_type
    ) RETURN VARCHAR2 IS
      l_fepv_rec                     fepv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fepv_rec := p_fepv_rec;
      -- Get current database values
      l_fepv_rec := get_rec(p_fepv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_fepv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.id := l_fepv_rec.id;
      END IF;
      IF (x_fepv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.object_version_number := l_fepv_rec.object_version_number;
      END IF;
      IF (x_fepv_rec.cnl_id = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.cnl_id := l_fepv_rec.cnl_id;
      END IF;
      IF (x_fepv_rec.pdp_id = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.pdp_id := l_fepv_rec.pdp_id;
      END IF;
      IF (x_fepv_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.aae_id := l_fepv_rec.aae_id;
      END IF;
      IF (x_fepv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.dnz_chr_id := l_fepv_rec.dnz_chr_id;
      END IF;
      IF (x_fepv_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_fepv_rec.value := l_fepv_rec.value;
      END IF;
      IF (x_fepv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.application_id := l_fepv_rec.application_id;
      END IF;
      IF (x_fepv_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_fepv_rec.seeded_flag := l_fepv_rec.seeded_flag;
      END IF;
      IF (x_fepv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.created_by := l_fepv_rec.created_by;
      END IF;
      IF (x_fepv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_fepv_rec.creation_date := l_fepv_rec.creation_date;
      END IF;
      IF (x_fepv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.last_updated_by := l_fepv_rec.last_updated_by;
      END IF;
      IF (x_fepv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_fepv_rec.last_update_date := l_fepv_rec.last_update_date;
      END IF;
      IF (x_fepv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_fepv_rec.last_update_login := l_fepv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------------
    -- Set_Attributes for:OKC_FUNCTION_EXPR_PARAMS_V --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_fepv_rec IN  fepv_rec_type,
      x_fepv_rec OUT NOCOPY fepv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fepv_rec := p_fepv_rec;
      x_fepv_rec.OBJECT_VERSION_NUMBER := NVL(x_fepv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    --  Seed data should not be updated unless user is DATAMERGE
    IF  l_fepv_rec.last_updated_by <> 1 THEN
    IF  l_fepv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_fepv_rec,                        -- IN
      l_fepv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fepv_rec, l_def_fepv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fepv_rec := fill_who_columns(l_def_fepv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fepv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fepv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_fepv_rec, l_fep_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fep_rec,
      lx_fep_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fep_rec, l_def_fepv_rec);
    x_fepv_rec := l_def_fepv_rec;
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
  -- PL/SQL TBL update_row for:FEPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type,
    x_fepv_tbl                     OUT NOCOPY fepv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fepv_tbl.COUNT > 0) THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fepv_rec                     => p_fepv_tbl(i),
          x_fepv_rec                     => x_fepv_tbl(i));
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
      END LOOP;
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
  ---------------------------------------------
  -- delete_row for:OKC_FUNCTION_EXPR_PARAMS --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fep_rec                      IN fep_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARAMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fep_rec                      fep_rec_type:= p_fep_rec;
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
    DELETE FROM OKC_FUNCTION_EXPR_PARAMS
     WHERE ID = l_fep_rec.id;

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
  -----------------------------------------------
  -- delete_row for:OKC_FUNCTION_EXPR_PARAMS_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_rec                     IN fepv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_fepv_rec                     fepv_rec_type := p_fepv_rec;
    l_fep_rec                      fep_rec_type;
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
    --  Seed data should not be deleted unless user is DATAMERGE
    IF  l_fepv_rec.last_updated_by <> 1 THEN
    IF  l_fepv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_fepv_rec, l_fep_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_fep_rec
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
  -- PL/SQL TBL delete_row for:FEPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fepv_tbl                     IN fepv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fepv_tbl.COUNT > 0) THEN
      i := p_fepv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_fepv_rec                     => p_fepv_tbl(i));
        EXIT WHEN (i = p_fepv_tbl.LAST);
        i := p_fepv_tbl.NEXT(i);
      END LOOP;
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

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_function_expr_params_h
  (
      major_version,
      id,
      cnl_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      value,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      APPLICATION_ID,
      SEEDED_FLAG
)
  SELECT
      p_major_version,
      id,
      cnl_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      value,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      APPLICATION_ID,
      SEEDED_FLAG
  FROM okc_function_expr_params
WHERE dnz_chr_id = p_chr_id;

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_function_expr_params
  (
      id,
      cnl_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      value,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      APPLICATION_ID,
      SEEDED_FLAG
)
  SELECT
      id,
      cnl_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      value,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      APPLICATION_ID,
      SEEDED_FLAG
  FROM okc_function_expr_params_h
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

RETURN l_return_status;
  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN
       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;
END restore_version;
END OKC_FEP_PVT;

/
