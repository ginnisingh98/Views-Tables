--------------------------------------------------------
--  DDL for Package Body OKC_OAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OAT_PVT" AS
/* $Header: OKCSOATB.pls 120.0.12010000.2 2008/10/24 08:04:08 ssreekum ship $ */

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
  -- FUNCTION get_rec for: OKC_OUTCOME_ARGUMENTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oat_rec                      IN oat_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oat_rec_type IS
    CURSOR okc_outcome_arguments_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OCE_ID,
            PDP_ID,
            AAE_ID,
            DNZ_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            VALUE,
            LAST_UPDATE_LOGIN,
            APPLICATION_ID,
            SEEDED_FLAG
      FROM Okc_Outcome_Arguments
     WHERE okc_outcome_arguments.id = p_id;
    l_okc_outcome_arguments_pk     okc_outcome_arguments_pk_csr%ROWTYPE;
    l_oat_rec                      oat_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_outcome_arguments_pk_csr (p_oat_rec.id);
    FETCH okc_outcome_arguments_pk_csr INTO
              l_oat_rec.ID,
              l_oat_rec.OCE_ID,
              l_oat_rec.PDP_ID,
              l_oat_rec.AAE_ID,
              l_oat_rec.DNZ_CHR_ID,
              l_oat_rec.OBJECT_VERSION_NUMBER,
              l_oat_rec.CREATED_BY,
              l_oat_rec.CREATION_DATE,
              l_oat_rec.LAST_UPDATED_BY,
              l_oat_rec.LAST_UPDATE_DATE,
              l_oat_rec.VALUE,
              l_oat_rec.LAST_UPDATE_LOGIN,
              l_oat_rec.APPLICATION_ID,
              l_oat_rec.SEEDED_FLAG;
    x_no_data_found := okc_outcome_arguments_pk_csr%NOTFOUND;
    CLOSE okc_outcome_arguments_pk_csr;
    RETURN(l_oat_rec);
  END get_rec;

  FUNCTION get_rec (
    p_oat_rec                      IN oat_rec_type
  ) RETURN oat_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oat_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_OUTCOME_ARGUMENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oatv_rec                     IN oatv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oatv_rec_type IS
    CURSOR okc_oatv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PDP_ID,
            OCE_ID,
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
      FROM Okc_Outcome_Arguments_V
     WHERE okc_outcome_arguments_v.id = p_id;
    l_okc_oatv_pk                  okc_oatv_pk_csr%ROWTYPE;
    l_oatv_rec                     oatv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_oatv_pk_csr (p_oatv_rec.id);
    FETCH okc_oatv_pk_csr INTO
              l_oatv_rec.ID,
              l_oatv_rec.PDP_ID,
              l_oatv_rec.OCE_ID,
              l_oatv_rec.AAE_ID,
              l_oatv_rec.DNZ_CHR_ID,
              l_oatv_rec.OBJECT_VERSION_NUMBER,
              l_oatv_rec.VALUE,
              l_oatv_rec.APPLICATION_ID,
              l_oatv_rec.SEEDED_FLAG,
              l_oatv_rec.CREATED_BY,
              l_oatv_rec.CREATION_DATE,
              l_oatv_rec.LAST_UPDATED_BY,
              l_oatv_rec.LAST_UPDATE_DATE,
              l_oatv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_oatv_pk_csr%NOTFOUND;
    CLOSE okc_oatv_pk_csr;
    RETURN(l_oatv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_oatv_rec                     IN oatv_rec_type
  ) RETURN oatv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oatv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_OUTCOME_ARGUMENTS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_oatv_rec	IN oatv_rec_type
  ) RETURN oatv_rec_type IS
    l_oatv_rec	oatv_rec_type := p_oatv_rec;
  BEGIN
    IF (l_oatv_rec.pdp_id = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.pdp_id := NULL;
    END IF;
    IF (l_oatv_rec.oce_id = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.oce_id := NULL;
    END IF;
    IF (l_oatv_rec.aae_id = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.aae_id := NULL;
    END IF;
    IF (l_oatv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_oatv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.object_version_number := NULL;
    END IF;
    IF (l_oatv_rec.value = OKC_API.G_MISS_CHAR) THEN
      l_oatv_rec.value := NULL;
    END IF;
    IF (l_oatv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.application_id := NULL;
    END IF;
    IF (l_oatv_rec.seeded_flag = OKC_API.G_MISS_CHAR) THEN
      l_oatv_rec.seeded_flag := NULL;
    END IF;
    IF (l_oatv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.created_by := NULL;
    END IF;
    IF (l_oatv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_oatv_rec.creation_date := NULL;
    END IF;
    IF (l_oatv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.last_updated_by := NULL;
    END IF;
    IF (l_oatv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_oatv_rec.last_update_date := NULL;
    END IF;
    IF (l_oatv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_oatv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_oatv_rec);
  END null_out_defaults;

  /******* Commented out nocopy generated code in favor of hand written code *******
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_OUTCOME_ARGUMENTS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_oatv_rec IN  oatv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_oatv_rec.id = OKC_API.G_MISS_NUM OR
       p_oatv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_oatv_rec.pdp_id = OKC_API.G_MISS_NUM OR
          p_oatv_rec.pdp_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdp_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_oatv_rec.oce_id = OKC_API.G_MISS_NUM OR
          p_oatv_rec.oce_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'oce_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_oatv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_oatv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_OUTCOME_ARGUMENTS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_oatv_rec IN oatv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_oatv_rec IN oatv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_ocev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              PDF_ID,
              CNH_ID,
              DNZ_CHR_ID,
              ENABLED_YN,
              COMMENTS,
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
        FROM Okc_Outcomes_V
       WHERE okc_outcomes_v.id    = p_id;
      l_okc_ocev_pk                  okc_ocev_pk_csr%ROWTYPE;
      CURSOR okc_pdpv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              PDF_ID,
              NAME,
              DATA_TYPE,
              DEFAULT_VALUE,
              REQUIRED_YN,
              DESCRIPTION,
              APPLICATION_ID,
              SEEDED_FLAG,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okc_Process_Def_Parameters_V
       WHERE okc_process_def_parameters_v.id = p_id;
      l_okc_pdpv_pk                  okc_pdpv_pk_csr%ROWTYPE;
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
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_oatv_rec.OCE_ID IS NOT NULL)
      THEN
        OPEN okc_ocev_pk_csr(p_oatv_rec.OCE_ID);
        FETCH okc_ocev_pk_csr INTO l_okc_ocev_pk;
        l_row_notfound := okc_ocev_pk_csr%NOTFOUND;
        CLOSE okc_ocev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OCE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_oatv_rec.PDP_ID IS NOT NULL)
      THEN
        OPEN okc_pdpv_pk_csr(p_oatv_rec.PDP_ID);
        FETCH okc_pdpv_pk_csr INTO l_okc_pdpv_pk;
        l_row_notfound := okc_pdpv_pk_csr%NOTFOUND;
        CLOSE okc_pdpv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PDP_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_oatv_rec.AAE_ID IS NOT NULL)
      THEN
        OPEN okc_aaev_pk_csr(p_oatv_rec.AAE_ID);
        FETCH okc_aaev_pk_csr INTO l_okc_aaev_pk;
        l_row_notfound := okc_aaev_pk_csr%NOTFOUND;
        CLOSE okc_aaev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AAE_ID');
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
    l_return_status := validate_foreign_keys (p_oatv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  /******* End Commented out nocopy generated code in favor of hand written code **/

  /********* Begin Hand Written Code ***************************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_OUTCOME_ARGUMENTS_V --
  -----------------------------------------------------
  -- Start of comments
  -- Procedure Name  : validate_object_version_number
  -- Description     : Check if object_version_number is null
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_object_version_number(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_oatv_rec              IN oatv_rec_type) IS

   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if object version number is null
	IF p_oatv_rec.object_version_number = OKC_API.G_MISS_NUM OR
		p_oatv_rec.object_version_number IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'object_version_number');
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

    END validate_object_version_number;

   -- Start of comments
   -- Procedure Name  : validate_seeded_flag
   -- Description     : Checks if column SEEDED_FLAG is 'Y' or 'N' only
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_seeded_flag(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_oatv_rec              IN oatv_rec_type) IS
		l_y VARCHAR2(1) := 'Y';
		l_n VARCHAR2(1) := 'N';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;
	-- Check if seeded_flag is Y or N
	IF UPPER(p_oatv_rec.seeded_flag) NOT IN ('Y', 'N') THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'seeded_flag');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	--Check if the data is in upper case
	IF p_oatv_rec.seeded_flag <> UPPER(p_oatv_rec.seeded_flag) THEN
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

   -- Start of comments
   -- Procedure Name  : validate_application_id
   -- Description     : Checks if application_id exists in fnd_application
   -- Version         : 1.0
   -- End of comments

   PROCEDURE validate_application_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
       	p_oatv_rec              IN oatv_rec_type) IS
	Cursor application_id_cur(p_application_id IN NUMBER) IS
	select '1'
	from fnd_application
	where application_id = p_application_id;
	l_dummy		VARCHAR2(1) := '?';
    BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_oatv_rec.application_id IS NOT NULL THEN
	--Check if application id exists in the fnd_application or not
	OPEN application_id_cur(p_oatv_rec.application_id);
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

  -- Start of comments
  -- Procedure Name  : validate_pdp_id
  -- Description     : Check if pdp_id is not null and enforce foreign key
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_pdp_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_oatv_rec              IN oatv_rec_type) IS

      CURSOR okc_pdpv_pk_csr IS
      SELECT '1'
      FROM Okc_process_def_parameters_v, okc_process_defs_v
      WHERE okc_process_def_parameters_v.id = p_oatv_rec.pdp_id
      and okc_process_def_parameters_v.pdf_id = okc_process_defs_v.id;

      l_dummy     VARCHAR2(1) := '?';
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF p_oatv_rec.pdp_id = OKC_API.G_MISS_NUM OR p_oatv_rec.pdp_id IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'pdp_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Enforce foreign key
        OPEN okc_pdpv_pk_csr;
        FETCH okc_pdpv_pk_csr INTO l_dummy;
	CLOSE okc_pdpv_pk_csr;

	-- If l_dummy is still set to default, data was not found
        IF (l_dummy = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_no_parent_record,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'pdp_id',
                        	    p_token2       => g_child_table_token,
                        	    p_token2_value => 'OKC_PROCESS_DEF_PARAMETERS_V',
                        	    p_token3       => g_parent_table_token,
                        	    p_token3_value => 'OKC_OUTCOMES_V');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
  EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		-- verify that cursor was closed
		if okc_pdpv_pk_csr %ISOPEN then
      			close okc_pdpv_pk_csr ;
    		end if;

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
    END validate_pdp_id;

  -- Start of comments
  -- Procedure Name  : validate_oce_id
  -- Description     : Check if oce_id is null
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_oce_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_oatv_rec              IN oatv_rec_type) IS

      CURSOR okc_ocev_pk_csr IS
      SELECT '1'
      FROM Okc_outcomes_v
      WHERE okc_outcomes_v.id = p_oatv_rec.oce_id;

      l_dummy     VARCHAR2(1) := '?';
   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if oce_id is null
	IF p_oatv_rec.oce_id = OKC_API.G_MISS_NUM OR p_oatv_rec.oce_id IS NULL THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_required_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'oce_id');
          	x_return_status := OKC_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;

	-- Enforce foreign key
        OPEN okc_ocev_pk_csr;
        FETCH okc_ocev_pk_csr INTO l_dummy;
	CLOSE okc_ocev_pk_csr;

	-- If l_dummy is still set to default, data was not found
        IF (l_dummy = '?') THEN
                OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_no_parent_record,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'oce_id',
                        	    p_token2       => g_child_table_token,
                        	    p_token2_value => 'OKC_OUTCOME_ARGUMENTS_V',
                        	    p_token3       => g_parent_table_token,
                        	    p_token3_value => 'OKC_OUTCOMES_V');
		x_return_status := OKC_API.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
  EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		-- verify that cursor was closed
		if okc_ocev_pk_csr %ISOPEN then
      			close okc_ocev_pk_csr ;
    		end if;

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
    END validate_oce_id;

  -- Start of comments
  -- Procedure Name  : validate_aae_id
  -- Description     : Check if aae_id is valid
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

     PROCEDURE validate_aae_id(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_oatv_rec              IN oatv_rec_type) IS

      CURSOR okc_aaev_pk_csr IS
      SELECT '1'
      FROM Okc_action_attributes_v
      WHERE okc_action_attributes_v.id = p_oatv_rec.aae_id;

      l_dummy     VARCHAR2(1) := '?';
  Begin
	IF p_oatv_rec.value IS  NULL THEN
		-- Enforce foreign key
        	OPEN okc_aaev_pk_csr;
        	FETCH okc_aaev_pk_csr INTO l_dummy;
		CLOSE okc_aaev_pk_csr;

		-- If l_dummy is still set to default, data was not found
        	IF (l_dummy = '?') THEN
                	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_no_parent_record,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'aae_id',
                        	    p_token2       => g_child_table_token,
                        	    p_token2_value => 'OKC_OUTCOME_ARGUMENTS_V',
                        	    p_token3       => g_parent_table_token,
                        	    p_token3_value => 'OKC_ACTION_ATTRIBUTES_V');
			x_return_status := OKC_API.G_RET_STS_ERROR;
			RAISE G_EXCEPTION_HALT_VALIDATION;
        	END IF;
	END IF;
  EXCEPTION
		when G_EXCEPTION_HALT_VALIDATION then
    		-- no processing necessary;  validation can continue
    		-- with the next column
    		null;

		-- verify that cursor was closed
		if okc_aaev_pk_csr %ISOPEN then
      			close okc_aaev_pk_csr ;
    		end if;

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
    END validate_aae_id;

    FUNCTION Validate_Attributes (
    p_oatv_rec IN  oatv_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
	validate_object_version_number(x_return_status => l_return_status
		                      ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_seeded_flag(x_return_status => l_return_status
		                      ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_application_id(x_return_status => l_return_status
		                      ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

    	validate_pdp_id(x_return_status => l_return_status
		       ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_oce_id(x_return_status => l_return_status
		       ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_aae_id(x_return_status => l_return_status
		       ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
      RETURN(l_return_status);
  EXCEPTION
		When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;
		RETURN(l_return_status);

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
 	        RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_OUTCOME_ARGUMENTS_V --
  -------------------------------------------------
 -- Start of comments
  -- Procedure Name  : validate_aaeid_value
  -- Description     : Check if one of this aae_id or value has value
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_aaeid_value(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_oatv_rec              IN oatv_rec_type) IS

   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if aae_id or value has value
	IF p_oatv_rec.aae_id is not null and p_oatv_rec.value is not null then
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_arc_violated,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'aae_id',
				    p_token2       => g_col_name_token,
				    p_token2_value => 'value');
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
    END validate_aaeid_value;

  -- Start of comments
  -- Procedure Name  : validate_aaeid_datatype
  -- Description     : Check if aae_id is of the right datatype
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_aaeid_datatype(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_oatv_rec              IN oatv_rec_type) IS

	cursor pdp_cur(p_pdp_id IN NUMBER) is
	select data_type
	from okc_process_def_parameters_v
	where id = p_pdp_id;

	cursor aae_cur(p_aae_id IN NUMBER) is
	select data_type
	from okc_action_attributes_v
	where id = p_aae_id;

	v_aae_data_type		VARCHAr2(90);
	v_pdp_data_type		VARCHAR2(90);

   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if aae_id is of the right datatype
	IF p_oatv_rec.aae_id is not null and p_oatv_rec.pdp_id is not null then
		OPEN pdp_cur(p_oatv_rec.pdp_id);
		FETCH pdp_cur into v_pdp_data_type;
		CLOSE pdp_cur;

		OPEN aae_cur(p_oatv_rec.aae_id);
		FETCH aae_cur into v_aae_data_type;
		CLOSE aae_cur;

		IF v_pdp_data_type <> v_aae_data_type THEN
		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'aae_id',
				    p_token2       => g_col_name_token,
				    p_token2_value => 'pdp_id');
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
    END validate_aaeid_datatype;

    -- Start of comments
    -- Procedure Name  : validate if the value is of the proper datatype(C, N, D)
    -- Description     : Check if value is of the right datatype
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments

    FUNCTION val_num(p_stg_in IN VARCHAR2)
  	RETURN BOOLEAN IS
  		l_val NUMBER;
  	BEGIN
  		l_val := TO_NUMBER(p_stg_in);
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
  		    RETURN FALSE;
  	END val_num;

	FUNCTION val_date(p_stg_in IN VARCHAR2)
  	RETURN BOOLEAN IS
  		l_val DATE;
  	BEGIN
  		l_val := TO_DATE(p_stg_in,'YYYY/MM/DD');
  		RETURN TRUE;
  	EXCEPTION
  		WHEN OTHERS THEN
  		    RETURN FALSE;
  	END val_date;

  -- Start of comments
  -- Procedure Name  : validate_value_datatype
  -- Description     : Check if value is of the right datatype
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

   PROCEDURE validate_value_datatype(
    	x_return_status 	OUT NOCOPY VARCHAR2,
        p_oatv_rec              IN oatv_rec_type) IS

	cursor pdp_cur(p_pdp_id IN NUMBER) is
	select data_type
	from okc_process_def_parameters_v
	where id = p_pdp_id;

	l_pdp_data_type		VARCHAR2(90);
	l_func_datatype		BOOLEAN;

   BEGIN
	-- initialize return status
  	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- Check if value is of the right datatype
	IF p_oatv_rec.value is not null and p_oatv_rec.pdp_id is not null then
		OPEN pdp_cur(p_oatv_rec.pdp_id);
		FETCH pdp_cur into l_pdp_data_type;
		CLOSE pdp_cur;

		IF l_pdp_data_type = 'N' THEN
			l_func_datatype := val_num(p_oatv_rec.value);
			IF l_func_datatype = FALSE THEN
				OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'value',
				    p_token2       => g_col_name_token,
				    p_token2_value => 'pdp_id');
          			x_return_status := OKC_API.G_RET_STS_ERROR;
				raise G_EXCEPTION_HALT_VALIDATION;
			END IF;
		END IF;

		IF l_pdp_data_type = 'C' THEN
			l_func_datatype := val_num(p_oatv_rec.value);
			IF l_func_datatype = TRUE THEN
				OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'value',
				    p_token2       => g_col_name_token,
				    p_token2_value => 'pdp_id');
          			x_return_status := OKC_API.G_RET_STS_ERROR;
				raise G_EXCEPTION_HALT_VALIDATION;
			END IF;
		END IF;

		IF l_pdp_data_type = 'D' THEN
			l_func_datatype := val_date(p_oatv_rec.value);
			IF l_func_datatype = FALSE THEN
				OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        	    p_msg_name     => g_invalid_value,
                        	    p_token1       => g_col_name_token,
                        	    p_token1_value => 'value',
				    p_token2       => g_col_name_token,
				    p_token2_value => 'pdp_id');
          			x_return_status := OKC_API.G_RET_STS_ERROR;
				raise G_EXCEPTION_HALT_VALIDATION;
			END IF;
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
    END validate_value_datatype;

  FUNCTION Validate_Record (
    p_oatv_rec IN oatv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
        validate_aaeid_value(x_return_status => l_return_status
		             ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_aaeid_datatype(x_return_status => l_return_status
		             ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;

	validate_value_datatype(x_return_status => l_return_status
		             ,p_oatv_rec      => p_oatv_rec);
	-- store the highest degree of error
  	IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      		IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        		l_return_status := x_return_status;
        		RAISE G_EXCEPTION_HALT_VALIDATION;
	      	ELSE
        		l_return_status := x_return_status;   -- record that there was an error
      		END IF;
	END IF;
    RETURN (l_return_status);
  EXCEPTION
   	When G_EXCEPTION_HALT_VALIDATION then
    		--just come out with return status
    		null;
		RETURN(l_return_status);

		 when OTHERS then
    		-- store SQL error message on message stack for caller
    		OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

    		-- notify caller of an UNEXPECTED error
    		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
		RETURN(l_return_status);
  END Validate_Record;


  /********* End   Hand Written Code ***************************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN oatv_rec_type,
    p_to	OUT NOCOPY oat_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.oce_id := p_from.oce_id;
    p_to.pdp_id := p_from.pdp_id;
    p_to.aae_id := p_from.aae_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.value := p_from.value;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
  END migrate;
  PROCEDURE migrate (
    p_from	IN oat_rec_type,
    p_to	IN OUT NOCOPY oatv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.oce_id := p_from.oce_id;
    p_to.pdp_id := p_from.pdp_id;
    p_to.aae_id := p_from.aae_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.value := p_from.value;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.seeded_flag := p_from.seeded_flag;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKC_OUTCOME_ARGUMENTS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oatv_rec                     oatv_rec_type := p_oatv_rec;
    l_oat_rec                      oat_rec_type;
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
    l_return_status := Validate_Attributes(l_oatv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_oatv_rec);
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
  -- PL/SQL TBL validate_row for:OATV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oatv_tbl.COUNT > 0) THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oatv_rec                     => p_oatv_tbl(i));
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKC_OUTCOME_ARGUMENTS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oat_rec                      IN oat_rec_type,
    x_oat_rec                      OUT NOCOPY oat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ARGUMENTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oat_rec                      oat_rec_type := p_oat_rec;
    l_def_oat_rec                  oat_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_OUTCOME_ARGUMENTS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_oat_rec IN  oat_rec_type,
      x_oat_rec OUT NOCOPY oat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oat_rec := p_oat_rec;
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
      p_oat_rec,                         -- IN
      l_oat_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_OUTCOME_ARGUMENTS(
        id,
        oce_id,
        pdp_id,
        aae_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        value,
        last_update_login,
        application_id,
        seeded_flag)
      VALUES (
        l_oat_rec.id,
        l_oat_rec.oce_id,
        l_oat_rec.pdp_id,
        l_oat_rec.aae_id,
        l_oat_rec.dnz_chr_id,
        l_oat_rec.object_version_number,
        l_oat_rec.created_by,
        l_oat_rec.creation_date,
        l_oat_rec.last_updated_by,
        l_oat_rec.last_update_date,
        l_oat_rec.value,
        l_oat_rec.last_update_login,
        l_oat_rec.application_id,
        l_oat_rec.seeded_flag);
    -- Set OUT values
    x_oat_rec := l_oat_rec;
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
  --------------------------------------------
  -- insert_row for:OKC_OUTCOME_ARGUMENTS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type,
    x_oatv_rec                     OUT NOCOPY oatv_rec_type) IS

    l_id                           NUMBER ;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oatv_rec                     oatv_rec_type;
    l_def_oatv_rec                 oatv_rec_type;
    l_oat_rec                      oat_rec_type;
    lx_oat_rec                     oat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oatv_rec	IN oatv_rec_type
    ) RETURN oatv_rec_type IS
      l_oatv_rec	oatv_rec_type := p_oatv_rec;
    BEGIN
      l_oatv_rec.CREATION_DATE := SYSDATE;
      l_oatv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_oatv_rec.LAST_UPDATE_DATE := l_oatv_rec.CREATION_DATE;
      l_oatv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oatv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oatv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_OUTCOME_ARGUMENTS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_oatv_rec IN  oatv_rec_type,
      x_oatv_rec OUT NOCOPY oatv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oatv_rec := p_oatv_rec;
      x_oatv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_oatv_rec := null_out_defaults(p_oatv_rec);
    -- Set primary key value
    -- If outcome argument is created by seed then use sequence generated id
    IF l_oatv_rec.CREATED_BY = 1 THEN
	  SELECT OKC_OUTCOME_ARGUMENTS_S1.nextval INTO l_id FROM dual;
       l_oatv_rec.ID := l_id;
       l_oatv_rec.seeded_flag := 'Y';
    ELSE
       l_oatv_rec.ID := get_seq_id;
       l_oatv_rec.seeded_flag := 'N';
    END IF;

    --l_oatv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_oatv_rec,                        -- IN
      l_def_oatv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oatv_rec := fill_who_columns(l_def_oatv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oatv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oatv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_oatv_rec, l_oat_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oat_rec,
      lx_oat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oat_rec, l_def_oatv_rec);
    -- Set OUT values
    x_oatv_rec := l_def_oatv_rec;
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
  -- PL/SQL TBL insert_row for:OATV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type,
    x_oatv_tbl                     OUT NOCOPY oatv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oatv_tbl.COUNT > 0) THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oatv_rec                     => p_oatv_tbl(i),
          x_oatv_rec                     => x_oatv_tbl(i));
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKC_OUTCOME_ARGUMENTS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oat_rec                      IN oat_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oat_rec IN oat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OUTCOME_ARGUMENTS
     WHERE ID = p_oat_rec.id
       AND OBJECT_VERSION_NUMBER = p_oat_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_oat_rec IN oat_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OUTCOME_ARGUMENTS
    WHERE ID = p_oat_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ARGUMENTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_OUTCOME_ARGUMENTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_OUTCOME_ARGUMENTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_oat_rec);
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
      OPEN lchk_csr(p_oat_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oat_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oat_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for:OKC_OUTCOME_ARGUMENTS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oat_rec                      oat_rec_type;
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
    migrate(p_oatv_rec, l_oat_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oat_rec
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
  -- PL/SQL TBL lock_row for:OATV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oatv_tbl.COUNT > 0) THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oatv_rec                     => p_oatv_tbl(i));
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKC_OUTCOME_ARGUMENTS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oat_rec                      IN oat_rec_type,
    x_oat_rec                      OUT NOCOPY oat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ARGUMENTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oat_rec                      oat_rec_type := p_oat_rec;
    l_def_oat_rec                  oat_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oat_rec	IN oat_rec_type,
      x_oat_rec	OUT NOCOPY oat_rec_type
    ) RETURN VARCHAR2 IS
      l_oat_rec                      oat_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oat_rec := p_oat_rec;
      -- Get current database values
      l_oat_rec := get_rec(p_oat_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_oat_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.id := l_oat_rec.id;
      END IF;
      IF (x_oat_rec.oce_id = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.oce_id := l_oat_rec.oce_id;
      END IF;
      IF (x_oat_rec.pdp_id = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.pdp_id := l_oat_rec.pdp_id;
      END IF;
      IF (x_oat_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.aae_id := l_oat_rec.aae_id;
      END IF;
      IF (x_oat_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.dnz_chr_id := l_oat_rec.dnz_chr_id;
      END IF;
      IF (x_oat_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.object_version_number := l_oat_rec.object_version_number;
      END IF;
      IF (x_oat_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.created_by := l_oat_rec.created_by;
      END IF;
      IF (x_oat_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_oat_rec.creation_date := l_oat_rec.creation_date;
      END IF;
      IF (x_oat_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.last_updated_by := l_oat_rec.last_updated_by;
      END IF;
      IF (x_oat_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_oat_rec.last_update_date := l_oat_rec.last_update_date;
      END IF;
      IF (x_oat_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_oat_rec.value := l_oat_rec.value;
      END IF;
      IF (x_oat_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.last_update_login := l_oat_rec.last_update_login;
      END IF;
      IF (x_oat_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_oat_rec.application_id := l_oat_rec.application_id;
      END IF;
      IF (x_oat_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_oat_rec.seeded_flag := l_oat_rec.seeded_flag;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_OUTCOME_ARGUMENTS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_oat_rec IN  oat_rec_type,
      x_oat_rec OUT NOCOPY oat_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oat_rec := p_oat_rec;
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
      p_oat_rec,                         -- IN
      l_oat_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oat_rec, l_def_oat_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_OUTCOME_ARGUMENTS
    SET OCE_ID = l_def_oat_rec.oce_id,
        PDP_ID = l_def_oat_rec.pdp_id,
        AAE_ID = l_def_oat_rec.aae_id,
        DNZ_CHR_ID = l_def_oat_rec.dnz_chr_id,
        OBJECT_VERSION_NUMBER = l_def_oat_rec.object_version_number,
        CREATED_BY = l_def_oat_rec.created_by,
        CREATION_DATE = l_def_oat_rec.creation_date,
        LAST_UPDATED_BY = l_def_oat_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_oat_rec.last_update_date,
        VALUE = l_def_oat_rec.value,
        LAST_UPDATE_LOGIN = l_def_oat_rec.last_update_login,
        APPLICATION_ID = l_def_oat_rec.application_id,
        SEEDED_FLAG = l_def_oat_rec.seeded_flag
    WHERE ID = l_def_oat_rec.id;

    x_oat_rec := l_def_oat_rec;
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
  --------------------------------------------
  -- update_row for:OKC_OUTCOME_ARGUMENTS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type,
    x_oatv_rec                     OUT NOCOPY oatv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oatv_rec                     oatv_rec_type := p_oatv_rec;
    l_def_oatv_rec                 oatv_rec_type;
    l_oat_rec                      oat_rec_type;
    lx_oat_rec                     oat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oatv_rec	IN oatv_rec_type
    ) RETURN oatv_rec_type IS
      l_oatv_rec	oatv_rec_type := p_oatv_rec;
    BEGIN
      l_oatv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_oatv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oatv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oatv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oatv_rec	IN oatv_rec_type,
      x_oatv_rec	OUT NOCOPY oatv_rec_type
    ) RETURN VARCHAR2 IS
      l_oatv_rec                     oatv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oatv_rec := p_oatv_rec;
      -- Get current database values
      l_oatv_rec := get_rec(p_oatv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_oatv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.id := l_oatv_rec.id;
      END IF;
      IF (x_oatv_rec.pdp_id = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.pdp_id := l_oatv_rec.pdp_id;
      END IF;
      IF (x_oatv_rec.oce_id = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.oce_id := l_oatv_rec.oce_id;
      END IF;
      IF (x_oatv_rec.aae_id = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.aae_id := l_oatv_rec.aae_id;
      END IF;
      IF (x_oatv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.dnz_chr_id := l_oatv_rec.dnz_chr_id;
      END IF;
      IF (x_oatv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.object_version_number := l_oatv_rec.object_version_number;
      END IF;
      IF (x_oatv_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_oatv_rec.value := l_oatv_rec.value;
      END IF;
      IF (x_oatv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.application_id := l_oatv_rec.application_id;
      END IF;
      IF (x_oatv_rec.seeded_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_oatv_rec.seeded_flag := l_oatv_rec.seeded_flag;
      END IF;
      IF (x_oatv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.created_by := l_oatv_rec.created_by;
      END IF;
      IF (x_oatv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_oatv_rec.creation_date := l_oatv_rec.creation_date;
      END IF;
      IF (x_oatv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.last_updated_by := l_oatv_rec.last_updated_by;
      END IF;
      IF (x_oatv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_oatv_rec.last_update_date := l_oatv_rec.last_update_date;
      END IF;
      IF (x_oatv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_oatv_rec.last_update_login := l_oatv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_OUTCOME_ARGUMENTS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_oatv_rec IN  oatv_rec_type,
      x_oatv_rec OUT NOCOPY oatv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oatv_rec := p_oatv_rec;
      x_oatv_rec.OBJECT_VERSION_NUMBER := NVL(x_oatv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    IF  l_oatv_rec.last_updated_by <> 1 THEN
    IF  l_oatv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_oatv_rec,                        -- IN
      l_oatv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oatv_rec, l_def_oatv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oatv_rec := fill_who_columns(l_def_oatv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oatv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oatv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_oatv_rec, l_oat_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oat_rec,
      lx_oat_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oat_rec, l_def_oatv_rec);
    x_oatv_rec := l_def_oatv_rec;
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
  -- PL/SQL TBL update_row for:OATV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type,
    x_oatv_tbl                     OUT NOCOPY oatv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oatv_tbl.COUNT > 0) THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oatv_rec                     => p_oatv_tbl(i),
          x_oatv_rec                     => x_oatv_tbl(i));
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKC_OUTCOME_ARGUMENTS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oat_rec                      IN oat_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ARGUMENTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oat_rec                      oat_rec_type:= p_oat_rec;
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
    DELETE FROM OKC_OUTCOME_ARGUMENTS
     WHERE ID = l_oat_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKC_OUTCOME_ARGUMENTS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_rec                     IN oatv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oatv_rec                     oatv_rec_type := p_oatv_rec;
    l_oat_rec                      oat_rec_type;
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
    IF  l_oatv_rec.last_updated_by <> 1 THEN
    IF  l_oatv_rec.seeded_flag = 'Y' THEN
	   OKC_API.set_message(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_NOT_DELETE_SEEDED');
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_oatv_rec, l_oat_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oat_rec
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
  -- PL/SQL TBL delete_row for:OATV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oatv_tbl                     IN oatv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oatv_tbl.COUNT > 0) THEN
      i := p_oatv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oatv_rec                     => p_oatv_tbl(i));
        EXIT WHEN (i = p_oatv_tbl.LAST);
        i := p_oatv_tbl.NEXT(i);
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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_OUTCOME_ARGUMENTS _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_oatv_tbl oatv_tbl_type) IS
  l_tabsize NUMBER := p_oatv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_pdp_id                        OKC_DATATYPES.NumberTabTyp;
  in_oce_id                        OKC_DATATYPES.NumberTabTyp;
  in_aae_id                        OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_value                         OKC_DATATYPES.Var1995TabTyp;
  in_application_id                OKC_DATATYPES.NumberTabTyp;
  in_seeded_flag                   OKC_DATATYPES.Var3TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  j                                NUMBER := 0;
  i                                NUMBER := p_oatv_tbl.FIRST;
BEGIN

   --Initialize return status
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
  while i is not null
  LOOP
    j := j + 1;
    in_id                       (j) := p_oatv_tbl(i).id;
    in_pdp_id                   (j) := p_oatv_tbl(i).pdp_id;
    in_oce_id                   (j) := p_oatv_tbl(i).oce_id;
    in_aae_id                   (j) := p_oatv_tbl(i).aae_id;
    in_dnz_chr_id               (j) := p_oatv_tbl(i).dnz_chr_id;
    in_object_version_number    (j) := p_oatv_tbl(i).object_version_number;
    in_value                    (j) := p_oatv_tbl(i).value;
    in_application_id           (j) := p_oatv_tbl(i).application_id;
    in_seeded_flag              (j) := p_oatv_tbl(i).seeded_flag;
    in_created_by               (j) := p_oatv_tbl(i).created_by;
    in_creation_date            (j) := p_oatv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_oatv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_oatv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_oatv_tbl(i).last_update_login;
    i := p_oatv_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_OUTCOME_ARGUMENTS
      (
        id,
        oce_id,
        pdp_id,
        aae_id,
        dnz_chr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        value,
        last_update_login,
        application_id,
        seeded_flag
     )
     VALUES (
        in_id(i),
        in_oce_id(i),
        in_pdp_id(i),
        in_aae_id(i),
        in_dnz_chr_id(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_value(i),
        in_last_update_login(i),
        in_application_id(i),
        in_seeded_flag(i)
     );
EXCEPTION
  WHEN OTHERS THEN
     -- store SQL error message on message stack
     OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
     -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

--    RAISE;
END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO okc_outcome_arguments_h
  (
      major_version,
      id,
      oce_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      value,
      last_update_login,
    application_id,
    seeded_flag
)
  SELECT
      p_major_version,
      id,
      oce_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      value,
      last_update_login,
    application_id,
    seeded_flag
  FROM okc_outcome_arguments
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
INSERT INTO okc_outcome_arguments
  (
      id,
      oce_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      value,
      last_update_login,
    application_id,
    seeded_flag
)
  SELECT
      id,
      oce_id,
      pdp_id,
      aae_id,
      dnz_chr_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      value,
      last_update_login,
    application_id,
    seeded_flag
  FROM okc_outcome_arguments_h
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
--
END OKC_OAT_PVT;

/
