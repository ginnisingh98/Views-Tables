--------------------------------------------------------
--  DDL for Package Body OKL_AGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AGN_PVT" AS
/* $Header: OKLSAGNB.pls 120.4 2007/02/06 11:32:18 gkhuntet noship $ */
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
  -- FUNCTION get_rec for: OKL_ACCRUAL_GNRTNS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_agn_rec                      IN agn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN agn_rec_type IS
    CURSOR okl_accrual_gnrtns_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            LINE_NUMBER,
            VERSION,
            ARO_CODE,
            ARLO_CODE,
            ACRO_CODE,
            RIGHT_OPERAND_LITERAL,
            OBJECT_VERSION_NUMBER,
            LEFT_PARENTHESES,
            RIGHT_PARENTHESES,
            FROM_DATE,
            TO_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Accrual_Gnrtns
     WHERE okl_accrual_gnrtns.id = p_id;
    l_okl_accrual_gnrtns_pk        okl_accrual_gnrtns_pk_csr%ROWTYPE;
    l_agn_rec                      agn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_accrual_gnrtns_pk_csr (p_agn_rec.id);
    FETCH okl_accrual_gnrtns_pk_csr INTO
              l_agn_rec.ID,
              l_agn_rec.LINE_NUMBER,
              l_agn_rec.VERSION,
              l_agn_rec.ARO_CODE,
              l_agn_rec.ARLO_CODE,
              l_agn_rec.ACRO_CODE,
              l_agn_rec.RIGHT_OPERAND_LITERAL,
              l_agn_rec.OBJECT_VERSION_NUMBER,
              l_agn_rec.LEFT_PARENTHESES,
              l_agn_rec.RIGHT_PARENTHESES,
              l_agn_rec.FROM_DATE,
              l_agn_rec.TO_DATE,
              l_agn_rec.ORG_ID,
              l_agn_rec.CREATED_BY,
              l_agn_rec.CREATION_DATE,
              l_agn_rec.LAST_UPDATED_BY,
              l_agn_rec.LAST_UPDATE_DATE,
              l_agn_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_accrual_gnrtns_pk_csr%NOTFOUND;
    CLOSE okl_accrual_gnrtns_pk_csr;
    RETURN(l_agn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_agn_rec                      IN agn_rec_type
  ) RETURN agn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_agn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ACCRUAL_GNRTNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_agnv_rec                     IN agnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN agnv_rec_type IS
    CURSOR okl_agnv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ARO_CODE,
            ARLO_CODE,
            ACRO_CODE,
            LINE_NUMBER,
            VERSION,
            LEFT_PARENTHESES,
            RIGHT_OPERAND_LITERAL,
            RIGHT_PARENTHESES,
            FROM_DATE,
            TO_DATE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_ACCRUAL_GNRTNS
     WHERE OKL_ACCRUAL_GNRTNS.id = p_id;
    l_okl_agnv_pk                  okl_agnv_pk_csr%ROWTYPE;
    l_agnv_rec                     agnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_agnv_pk_csr (p_agnv_rec.id);
    FETCH okl_agnv_pk_csr INTO
              l_agnv_rec.ID,
              l_agnv_rec.OBJECT_VERSION_NUMBER,
              l_agnv_rec.ARO_CODE,
              l_agnv_rec.ARLO_CODE,
              l_agnv_rec.ACRO_CODE,
              l_agnv_rec.LINE_NUMBER,
              l_agnv_rec.VERSION,
              l_agnv_rec.LEFT_PARENTHESES,
              l_agnv_rec.RIGHT_OPERAND_LITERAL,
              l_agnv_rec.RIGHT_PARENTHESES,
              l_agnv_rec.FROM_DATE,
              l_agnv_rec.TO_DATE,
              l_agnv_rec.ORG_ID,
              l_agnv_rec.CREATED_BY,
              l_agnv_rec.CREATION_DATE,
              l_agnv_rec.LAST_UPDATED_BY,
              l_agnv_rec.LAST_UPDATE_DATE,
              l_agnv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_agnv_pk_csr%NOTFOUND;
    CLOSE okl_agnv_pk_csr;
    RETURN(l_agnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_agnv_rec                     IN agnv_rec_type
  ) RETURN agnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_agnv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ACCRUAL_GNRTNS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_agnv_rec	IN agnv_rec_type
  ) RETURN agnv_rec_type IS
    l_agnv_rec	agnv_rec_type := p_agnv_rec;
  BEGIN
    IF (l_agnv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_agnv_rec.object_version_number := NULL;
    END IF;
    IF (l_agnv_rec.aro_code = Okc_Api.G_MISS_CHAR) THEN
      l_agnv_rec.aro_code := NULL;
    END IF;
    IF (l_agnv_rec.arlo_code = Okc_Api.G_MISS_CHAR) THEN
      l_agnv_rec.arlo_code := NULL;
    END IF;
    IF (l_agnv_rec.acro_code = Okc_Api.G_MISS_CHAR) THEN
      l_agnv_rec.acro_code := NULL;
    END IF;
    IF (l_agnv_rec.line_number = Okc_Api.G_MISS_NUM) THEN
      l_agnv_rec.line_number := NULL;
    END IF;
    IF (l_agnv_rec.version = Okc_Api.G_MISS_CHAR) THEN
      l_agnv_rec.version := NULL;
    END IF;
    IF (l_agnv_rec.left_parentheses = Okc_Api.G_MISS_CHAR) THEN
      l_agnv_rec.left_parentheses := NULL;
    END IF;
    IF (l_agnv_rec.right_operand_literal = Okc_Api.G_MISS_CHAR) THEN
      l_agnv_rec.right_operand_literal := NULL;
    END IF;
    IF (l_agnv_rec.right_parentheses = Okc_Api.G_MISS_CHAR) THEN
      l_agnv_rec.right_parentheses := NULL;
    END IF;
    IF (l_agnv_rec.from_date = Okc_Api.G_MISS_DATE) THEN
      l_agnv_rec.from_date := NULL;
    END IF;
    IF (l_agnv_rec.TO_DATE = Okc_Api.G_MISS_DATE) THEN
      l_agnv_rec.TO_DATE := NULL;
    END IF;
    IF (l_agnv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_agnv_rec.org_id := NULL;
    END IF;
    IF (l_agnv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_agnv_rec.created_by := NULL;
    END IF;
    IF (l_agnv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_agnv_rec.creation_date := NULL;
    END IF;
    IF (l_agnv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_agnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_agnv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_agnv_rec.last_update_date := NULL;
    END IF;
    IF (l_agnv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_agnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_agnv_rec);
  END null_out_defaults;

  /**** Commenting out nocopy generated code in favour of hand written code ********
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_ACCRUAL_GNRTNS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_agnv_rec IN  agnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_agnv_rec.id = OKC_API.G_MISS_NUM OR
       p_agnv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_agnv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_agnv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_agnv_rec.aro_code = OKC_API.G_MISS_CHAR OR
          p_agnv_rec.aro_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'aro_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_agnv_rec.arlo_code = OKC_API.G_MISS_CHAR OR
          p_agnv_rec.arlo_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'arlo_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_agnv_rec.acro_code = OKC_API.G_MISS_CHAR OR
          p_agnv_rec.acro_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'acro_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_agnv_rec.line_number = OKC_API.G_MISS_NUM OR
          p_agnv_rec.line_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'line_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_agnv_rec.version = OKC_API.G_MISS_CHAR OR
          p_agnv_rec.version IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_agnv_rec.right_operand_literal = OKC_API.G_MISS_CHAR OR
          p_agnv_rec.right_operand_literal IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'right_operand_literal');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_ACCRUAL_GNRTNS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_agnv_rec IN agnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  **************** End Commenting generated code ***************************/

  /*************************** Hand Coded **********************************/

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
  PROCEDURE Validate_Id (x_return_status OUT NOCOPY  VARCHAR2
						,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_agnv_rec.id IS NULL) OR
       (p_agnv_rec.id = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
										  ,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_agnv_rec.object_version_number IS NULL) OR
       (p_agnv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Aro_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Aro_Code
  -- Description     : Checks if code exists in FND_COMMON_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Aro_Code(
     	 x_return_status  OUT NOCOPY VARCHAR2
	,p_agnv_rec         IN agnv_rec_type   )
   IS

	l_dummy		VARCHAR2(1) := okl_api.g_true;

   BEGIN
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_agnv_rec.aro_code IS NULL) OR
       (p_agnv_rec.aro_code = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'aro_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

	  l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE (
					p_lookup_type => 'OKL_ACCRUAL_RULE_OPERAND',
					p_lookup_code => p_agnv_rec.aro_code);

	  IF (l_dummy = okl_api.g_false) THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'aro_code');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
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
    END Validate_Aro_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Arlo_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Arlo_Code
  -- Description     : Checks if code exists in FND_COMMON_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Arlo_Code(
     	x_return_status  OUT NOCOPY  VARCHAR2
	   ,p_agnv_rec          IN agnv_rec_type )
   IS

	l_dummy		VARCHAR2(1);

    BEGIN
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

      IF (p_agnv_rec.arlo_code IS NOT NULL) AND (p_agnv_rec.arlo_code <> OKC_API.G_MISS_CHAR) THEN
	--Check if arlo code exists in the FND_COMMON_LOOKUPS or not
	  l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE (
			p_lookup_type => 'OKL_ACCRUAL_RULE_LOGICAL_OP',
			p_lookup_code => p_agnv_rec.arlo_code);

	  IF (l_dummy = okl_api.g_false) THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'arlo_code');

          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;

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
    END Validate_Arlo_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Acro_Code
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Acro_Code
  -- Description     : Checks if code exists in FND_COMMON_LOOKUPS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Acro_Code(
     	x_return_status  OUT NOCOPY VARCHAR2
	   ,p_agnv_rec          IN agnv_rec_type
	    ) IS

	l_dummy		VARCHAR2(1);

    BEGIN
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_agnv_rec.acro_code IS NULL) OR
       (p_agnv_rec.acro_code = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'acro_code');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	--Check if acro code exists in the FND_COMMON_LOOKUPS or not
	  l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE (
				p_lookup_type => 'OKL_ACCRUAL_RULE_OPERATOR',
				p_lookup_code => p_agnv_rec.acro_code);

	  IF (l_dummy = okl_api.g_false) THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'acro_code');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
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
    END Validate_Acro_Code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Right_Operand_Literal
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Right_Operand_Literal
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Right_Operand_Literal(x_return_status OUT NOCOPY  VARCHAR2
										  ,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_agnv_rec.right_operand_literal IS NULL) OR
       (p_agnv_rec.right_operand_literal = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'right_operand_literal');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_Right_Operand_Literal;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Line_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Line_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Line_Number(x_return_status OUT NOCOPY  VARCHAR2
								,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_agnv_rec.line_number IS NULL) OR
       (p_agnv_rec.line_number = Okc_Api.G_MISS_NUM) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'line_number');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_Line_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Version
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Version
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Version(x_return_status OUT NOCOPY  VARCHAR2
							,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_agnv_rec.version IS NULL) OR
       (p_agnv_rec.version = Okc_Api.G_MISS_CHAR) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'version');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_Version;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Left_Parentheses
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Left_Parentheses
  -- Description     : Checks if Left Parentheses is '('
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Left_Parentheses(x_return_status  OUT NOCOPY  VARCHAR2
									  ,p_agnv_rec    IN agnv_rec_type )
   IS
   l_dummy	VARCHAR2(1);

   BEGIN
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	IF (p_agnv_rec.left_parentheses IS NOT NULL) AND
           (p_agnv_rec.left_parentheses <> OKC_API.G_MISS_CHAR)  THEN
	--Check if left parentheses exists in the FND_COMMON_LOOKUPS or not
	  l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE (
					p_lookup_type => 'OKL_PARENTHESIS',
					p_lookup_code => p_agnv_rec.left_parentheses);

	  IF l_dummy = okl_api.g_false THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'left_parentheses');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
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
    END Validate_Left_Parentheses;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Right_Parentheses
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Right_Parentheses
  -- Description     : Checks if Right Parentheses is ')'
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

   PROCEDURE Validate_Right_Parentheses(x_return_status OUT NOCOPY  VARCHAR2
									   ,p_agnv_rec    IN agnv_rec_type )
   IS
   l_dummy VARCHAR2(1);

   BEGIN
	-- initialize return status
  	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	IF (p_agnv_rec.right_parentheses IS NOT NULL) AND
           (p_agnv_rec.right_parentheses <> OKC_API.G_MISS_CHAR) THEN
	--Check if right parentheses exists in the FND_COMMON_LOOKUPS or not
	  l_dummy := OKL_ACCOUNTING_UTIL.VALIDATE_LOOKUP_CODE (
					p_lookup_type => 'OKL_PARENTHESIS',
					p_lookup_code => p_agnv_rec.right_parentheses);

	  IF l_dummy = okl_api.g_false THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'right_parentheses');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
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
    END Validate_Right_Parentheses;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_From_Date(x_return_status OUT NOCOPY  VARCHAR2
							  ,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
    IF (p_agnv_rec.from_date IS NULL) OR
       (p_agnv_rec.from_date = Okc_Api.G_MISS_DATE) THEN
       Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'from_date');
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_From_Date;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_To_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_To_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_To_Date(x_return_status OUT NOCOPY  VARCHAR2
							,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	IF (p_agnv_rec.to_date IS NOT NULL) AND
           (p_agnv_rec.to_date <> OKC_API.G_MISS_DATE) THEN
	    IF p_agnv_rec.to_date < p_agnv_rec.from_date THEN
		Okc_Api.SET_MESSAGE(p_app_name     => g_app_name,
                        	p_msg_name     => g_invalid_value,
                        	p_token1       => g_col_name_token,
                        	p_token1_value => 'to_date');
          	x_return_status := Okc_Api.G_RET_STS_ERROR;
		RAISE G_EXCEPTION_HALT_VALIDATION;
	  END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_To_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Agn_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Agn_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Unique_Agn_Record(x_return_status OUT NOCOPY  VARCHAR2
									  ,p_agnv_rec      IN   agnv_rec_type )
  IS

  l_dummy                 VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;

    --bug 2510192. Added org id as part of unique key constraint
	-- to make the functionality org aware.
    CURSOR unique_agn_csr(p_line_number OKL_ACCRUAL_GNRTNS.line_number%TYPE
		  			     ,p_version OKL_ACCRUAL_GNRTNS.version%TYPE
						 ,p_org_id OKL_ACCRUAL_GNRTNS.org_id%TYPE
						 ,p_id OKL_ACCRUAL_GNRTNS.id%TYPE) IS
    SELECT 1
    FROM OKL_ACCRUAL_GNRTNS
    WHERE  line_number = p_line_number
    AND    version = p_version
    AND    nvl(org_id,-99) = nvl(p_org_id,-99)
	AND	   id <> p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    OPEN unique_agn_csr(p_agnv_rec.line_number,
		  p_agnv_rec.version, p_agnv_rec.org_id, p_agnv_rec.id);
    FETCH unique_agn_csr INTO l_dummy;
    l_row_found := unique_agn_csr%FOUND;
    CLOSE unique_agn_csr;
    IF l_row_found THEN
		Okc_Api.set_message(G_APP_NAME,G_UNQS);
		x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
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

  END Validate_Unique_Agn_Record;


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
    p_agnv_rec IN  agnv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

     -- call each column-level validation

    -- Validate_Id
    Validate_Id(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Line_Number
    Validate_Line_Number(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Version
       Validate_Version(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Aro_Code
       Validate_Aro_Code(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Arlo_Code
       Validate_Arlo_Code(x_return_status, p_agnv_rec );
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

    -- Validate_Acro_Code
       Validate_Acro_Code(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Right_Operand_Literal
       Validate_Right_Operand_Literal(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Left_Parentheses
       Validate_Left_Parentheses(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_Right_Parentheses
       Validate_Right_Parentheses(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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

    -- Validate_From_Date
       Validate_From_Date(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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


    -- Validate_To_Date
       Validate_To_Date(x_return_status, p_agnv_rec );
    -- store the highest degree of error
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
       -- just come out with return status
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
  -- FUNCTION Validate_Record
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
    p_agnv_rec IN agnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN

    -- Validate_Unique_Agn_Record
      Validate_Unique_Agn_Record(x_return_status, p_agnv_rec );
      -- store the highest degree of error
      IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
        IF (x_return_status <> Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
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
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN (l_return_status);

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

  END Validate_Record;

/************************ END HAND CODING **********************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN agnv_rec_type,
    p_to	IN OUT NOCOPY agn_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.line_number := p_from.line_number;
    p_to.version := p_from.version;
    p_to.aro_code := p_from.aro_code;
    p_to.arlo_code := p_from.arlo_code;
    p_to.acro_code := p_from.acro_code;
    p_to.right_operand_literal := p_from.right_operand_literal;
    p_to.object_version_number := p_from.object_version_number;
    p_to.left_parentheses := p_from.left_parentheses;
    p_to.right_parentheses := p_from.right_parentheses;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN agn_rec_type,
    p_to	IN OUT NOCOPY agnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.line_number := p_from.line_number;
    p_to.version := p_from.version;
    p_to.aro_code := p_from.aro_code;
    p_to.arlo_code := p_from.arlo_code;
    p_to.acro_code := p_from.acro_code;
    p_to.right_operand_literal := p_from.right_operand_literal;
    p_to.object_version_number := p_from.object_version_number;
    p_to.left_parentheses := p_from.left_parentheses;
    p_to.right_parentheses := p_from.right_parentheses;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
    p_to.org_id := p_from.org_id;
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
  -- validate_row for:OKL_ACCRUAL_GNRTNS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agnv_rec                     agnv_rec_type := p_agnv_rec;
    l_agn_rec                      agn_rec_type;
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
    l_return_status := Validate_Attributes(l_agnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_agnv_rec);
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
  -- PL/SQL TBL validate_row for:AGNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agnv_tbl.COUNT > 0) THEN
      i := p_agnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agnv_rec                     => p_agnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_agnv_tbl.LAST);
        i := p_agnv_tbl.NEXT(i);
      END LOOP;
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
  -- insert_row for:OKL_ACCRUAL_GNRTNS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agn_rec                      IN agn_rec_type,
    x_agn_rec                      OUT NOCOPY agn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GNRTNS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agn_rec                      agn_rec_type := p_agn_rec;
    l_def_agn_rec                  agn_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_ACCRUAL_GNRTNS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_agn_rec IN  agn_rec_type,
      x_agn_rec OUT NOCOPY agn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agn_rec := p_agn_rec;
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
      p_agn_rec,                         -- IN
      l_agn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ACCRUAL_GNRTNS(
        id,
        line_number,
        version,
        aro_code,
        arlo_code,
        acro_code,
        right_operand_literal,
        object_version_number,
        left_parentheses,
        right_parentheses,
        from_date,
        TO_DATE,
        org_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_agn_rec.id,
        l_agn_rec.line_number,
        l_agn_rec.version,
        l_agn_rec.aro_code,
        l_agn_rec.arlo_code,
        l_agn_rec.acro_code,
        l_agn_rec.right_operand_literal,
        l_agn_rec.object_version_number,
        l_agn_rec.left_parentheses,
        l_agn_rec.right_parentheses,
        l_agn_rec.from_date,
        l_agn_rec.TO_DATE,
        l_agn_rec.org_id,
        l_agn_rec.created_by,
        l_agn_rec.creation_date,
        l_agn_rec.last_updated_by,
        l_agn_rec.last_update_date,
        l_agn_rec.last_update_login);
    -- Set OUT values
    x_agn_rec := l_agn_rec;
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
  -----------------------------------------
  -- insert_row for:OKL_ACCRUAL_GNRTNS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agnv_rec                     agnv_rec_type;
    l_def_agnv_rec                 agnv_rec_type;
    l_agn_rec                      agn_rec_type;
    lx_agn_rec                     agn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_agnv_rec	IN agnv_rec_type
    ) RETURN agnv_rec_type IS
      l_agnv_rec	agnv_rec_type := p_agnv_rec;
    BEGIN
      l_agnv_rec.CREATION_DATE := SYSDATE;
      l_agnv_rec.CREATED_BY := Fnd_Global.User_Id;
      l_agnv_rec.LAST_UPDATE_DATE := l_agnv_rec.CREATION_DATE;
      l_agnv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_agnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_agnv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ACCRUAL_GNRTNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_agnv_rec IN  agnv_rec_type,
      x_agnv_rec OUT NOCOPY agnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agnv_rec := p_agnv_rec;
      x_agnv_rec.OBJECT_VERSION_NUMBER := 1;

/*  Change Made by GKHUNTET  for OA Migration Setup Accural Rule */
  --    x_agnv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();

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
    l_agnv_rec := null_out_defaults(p_agnv_rec);
    -- Set primary key value
    l_agnv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_agnv_rec,                        -- IN
      l_def_agnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_agnv_rec := fill_who_columns(l_def_agnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_agnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_agnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_agnv_rec, l_agn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agn_rec,
      lx_agn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_agn_rec, l_def_agnv_rec);
    -- Set OUT values
    x_agnv_rec := l_def_agnv_rec;
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
  -- PL/SQL TBL insert_row for:AGNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agnv_tbl.COUNT > 0) THEN
      i := p_agnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agnv_rec                     => p_agnv_tbl(i),
          x_agnv_rec                     => x_agnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */

        EXIT WHEN (i = p_agnv_tbl.LAST);
        i := p_agnv_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_status;

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
  -- lock_row for:OKL_ACCRUAL_GNRTNS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agn_rec                      IN agn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_agn_rec IN agn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACCRUAL_GNRTNS
     WHERE ID = p_agn_rec.id
       AND OBJECT_VERSION_NUMBER = p_agn_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_agn_rec IN agn_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACCRUAL_GNRTNS
    WHERE ID = p_agn_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GNRTNS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ACCRUAL_GNRTNS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ACCRUAL_GNRTNS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_agn_rec);
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
      OPEN lchk_csr(p_agn_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_agn_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_agn_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKL_ACCRUAL_GNRTNS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agn_rec                      agn_rec_type;
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
    migrate(p_agnv_rec, l_agn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agn_rec
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
  -- PL/SQL TBL lock_row for:AGNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
	l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agnv_tbl.COUNT > 0) THEN
      i := p_agnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agnv_rec                     => p_agnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_agnv_tbl.LAST);
        i := p_agnv_tbl.NEXT(i);
      END LOOP;
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
  -- update_row for:OKL_ACCRUAL_GNRTNS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agn_rec                      IN agn_rec_type,
    x_agn_rec                      OUT NOCOPY agn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GNRTNS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agn_rec                      agn_rec_type := p_agn_rec;
    l_def_agn_rec                  agn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_agn_rec	IN agn_rec_type,
      x_agn_rec	OUT NOCOPY agn_rec_type
    ) RETURN VARCHAR2 IS
      l_agn_rec                      agn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agn_rec := p_agn_rec;
      -- Get current database values
      l_agn_rec := get_rec(p_agn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_agn_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_agn_rec.id := l_agn_rec.id;
      END IF;
      IF (x_agn_rec.line_number = Okc_Api.G_MISS_NUM)
      THEN
        x_agn_rec.line_number := l_agn_rec.line_number;
      END IF;
      IF (x_agn_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_agn_rec.version := l_agn_rec.version;
      END IF;
      IF (x_agn_rec.aro_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agn_rec.aro_code := l_agn_rec.aro_code;
      END IF;
      IF (x_agn_rec.arlo_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agn_rec.arlo_code := l_agn_rec.arlo_code;
      END IF;
      IF (x_agn_rec.acro_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agn_rec.acro_code := l_agn_rec.acro_code;
      END IF;
      IF (x_agn_rec.right_operand_literal = Okc_Api.G_MISS_CHAR)
      THEN
        x_agn_rec.right_operand_literal := l_agn_rec.right_operand_literal;
      END IF;
      IF (x_agn_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_agn_rec.object_version_number := l_agn_rec.object_version_number;
      END IF;
      IF (x_agn_rec.left_parentheses = Okc_Api.G_MISS_CHAR)
      THEN
        x_agn_rec.left_parentheses := l_agn_rec.left_parentheses;
      END IF;
      IF (x_agn_rec.right_parentheses = Okc_Api.G_MISS_CHAR)
      THEN
        x_agn_rec.right_parentheses := l_agn_rec.right_parentheses;
      END IF;
      IF (x_agn_rec.from_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agn_rec.from_date := l_agn_rec.from_date;
      END IF;
      IF (x_agn_rec.TO_DATE = Okc_Api.G_MISS_DATE)
      THEN
        x_agn_rec.TO_DATE := l_agn_rec.TO_DATE;
      END IF;
      IF (x_agn_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agn_rec.org_id := l_agn_rec.org_id;
      END IF;
      IF (x_agn_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agn_rec.created_by := l_agn_rec.created_by;
      END IF;
      IF (x_agn_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agn_rec.creation_date := l_agn_rec.creation_date;
      END IF;
      IF (x_agn_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agn_rec.last_updated_by := l_agn_rec.last_updated_by;
      END IF;
      IF (x_agn_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agn_rec.last_update_date := l_agn_rec.last_update_date;
      END IF;
      IF (x_agn_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_agn_rec.last_update_login := l_agn_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_ACCRUAL_GNRTNS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_agn_rec IN  agn_rec_type,
      x_agn_rec OUT NOCOPY agn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agn_rec := p_agn_rec;
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
      p_agn_rec,                         -- IN
      l_agn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_agn_rec, l_def_agn_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ACCRUAL_GNRTNS
    SET LINE_NUMBER = l_def_agn_rec.line_number,
        VERSION = l_def_agn_rec.version,
        ARO_CODE = l_def_agn_rec.aro_code,
        ARLO_CODE = l_def_agn_rec.arlo_code,
        ACRO_CODE = l_def_agn_rec.acro_code,
        RIGHT_OPERAND_LITERAL = l_def_agn_rec.right_operand_literal,
        OBJECT_VERSION_NUMBER = l_def_agn_rec.object_version_number,
        LEFT_PARENTHESES = l_def_agn_rec.left_parentheses,
        RIGHT_PARENTHESES = l_def_agn_rec.right_parentheses,
        FROM_DATE = l_def_agn_rec.from_date,
        TO_DATE = l_def_agn_rec.TO_DATE,
        ORG_ID = l_def_agn_rec.org_id,
        CREATED_BY = l_def_agn_rec.created_by,
        CREATION_DATE = l_def_agn_rec.creation_date,
        LAST_UPDATED_BY = l_def_agn_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_agn_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_agn_rec.last_update_login
    WHERE ID = l_def_agn_rec.id;

    x_agn_rec := l_def_agn_rec;
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
  -----------------------------------------
  -- update_row for:OKL_ACCRUAL_GNRTNS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type,
    x_agnv_rec                     OUT NOCOPY agnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agnv_rec                     agnv_rec_type := p_agnv_rec;
    l_def_agnv_rec                 agnv_rec_type;
    l_agn_rec                      agn_rec_type;
    lx_agn_rec                     agn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_agnv_rec	IN agnv_rec_type
    ) RETURN agnv_rec_type IS
      l_agnv_rec	agnv_rec_type := p_agnv_rec;
    BEGIN
      l_agnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_agnv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_agnv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_agnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_agnv_rec	IN agnv_rec_type,
      x_agnv_rec	OUT NOCOPY agnv_rec_type
    ) RETURN VARCHAR2 IS
      l_agnv_rec                     agnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agnv_rec := p_agnv_rec;
      -- Get current database values
      l_agnv_rec := get_rec(p_agnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_agnv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_agnv_rec.id := l_agnv_rec.id;
      END IF;
      IF (x_agnv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_agnv_rec.object_version_number := l_agnv_rec.object_version_number;
      END IF;
      IF (x_agnv_rec.aro_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agnv_rec.aro_code := l_agnv_rec.aro_code;
      END IF;
      IF (x_agnv_rec.arlo_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agnv_rec.arlo_code := l_agnv_rec.arlo_code;
      END IF;
      IF (x_agnv_rec.acro_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agnv_rec.acro_code := l_agnv_rec.acro_code;
      END IF;
      IF (x_agnv_rec.line_number = Okc_Api.G_MISS_NUM)
      THEN
        x_agnv_rec.line_number := l_agnv_rec.line_number;
      END IF;
      IF (x_agnv_rec.version = Okc_Api.G_MISS_CHAR)
      THEN
        x_agnv_rec.version := l_agnv_rec.version;
      END IF;
      IF (x_agnv_rec.left_parentheses = Okc_Api.G_MISS_CHAR)
      THEN
        x_agnv_rec.left_parentheses := l_agnv_rec.left_parentheses;
      END IF;
      IF (x_agnv_rec.right_operand_literal = Okc_Api.G_MISS_CHAR)
      THEN
        x_agnv_rec.right_operand_literal := l_agnv_rec.right_operand_literal;
      END IF;
      IF (x_agnv_rec.right_parentheses = Okc_Api.G_MISS_CHAR)
      THEN
        x_agnv_rec.right_parentheses := l_agnv_rec.right_parentheses;
      END IF;
      IF (x_agnv_rec.from_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agnv_rec.from_date := l_agnv_rec.from_date;
      END IF;
      IF (x_agnv_rec.TO_DATE = Okc_Api.G_MISS_DATE)
      THEN
        x_agnv_rec.TO_DATE := l_agnv_rec.TO_DATE;
      END IF;
      IF (x_agnv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agnv_rec.org_id := l_agnv_rec.org_id;
      END IF;
      IF (x_agnv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agnv_rec.created_by := l_agnv_rec.created_by;
      END IF;
      IF (x_agnv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agnv_rec.creation_date := l_agnv_rec.creation_date;
      END IF;
      IF (x_agnv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agnv_rec.last_updated_by := l_agnv_rec.last_updated_by;
      END IF;
      IF (x_agnv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agnv_rec.last_update_date := l_agnv_rec.last_update_date;
      END IF;
      IF (x_agnv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_agnv_rec.last_update_login := l_agnv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_ACCRUAL_GNRTNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_agnv_rec IN  agnv_rec_type,
      x_agnv_rec OUT NOCOPY agnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agnv_rec := p_agnv_rec;
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
      p_agnv_rec,                        -- IN
      l_agnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_agnv_rec, l_def_agnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_agnv_rec := fill_who_columns(l_def_agnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_agnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_agnv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_agnv_rec, l_agn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agn_rec,
      lx_agn_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_agn_rec, l_def_agnv_rec);
    x_agnv_rec := l_def_agnv_rec;
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
  -- PL/SQL TBL update_row for:AGNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type,
    x_agnv_tbl                     OUT NOCOPY agnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agnv_tbl.COUNT > 0) THEN
      i := p_agnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agnv_rec                     => p_agnv_tbl(i),
          x_agnv_rec                     => x_agnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_agnv_tbl.LAST);
        i := p_agnv_tbl.NEXT(i);
      END LOOP;
    END IF;
       x_return_status := l_overall_status;

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
  -- delete_row for:OKL_ACCRUAL_GNRTNS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agn_rec                      IN agn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GNRTNS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agn_rec                      agn_rec_type:= p_agn_rec;
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
    DELETE FROM OKL_ACCRUAL_GNRTNS
     WHERE ID = l_agn_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKL_ACCRUAL_GNRTNS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_rec                     IN agnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agnv_rec                     agnv_rec_type := p_agnv_rec;
    l_agn_rec                      agn_rec_type;
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
    migrate(l_agnv_rec, l_agn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agn_rec
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
  -- PL/SQL TBL delete_row for:AGNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agnv_tbl                     IN agnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agnv_tbl.COUNT > 0) THEN
      i := p_agnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agnv_rec                     => p_agnv_tbl(i));
/* Begin Post Generation Change */
     -- store the highest degree of error
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
      END IF;
	END IF;
/* End Post Generation Change */
        EXIT WHEN (i = p_agnv_tbl.LAST);
        i := p_agnv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_Status;
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
END Okl_Agn_Pvt;

/
