--------------------------------------------------------
--  DDL for Package Body OKL_KHR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_KHR_PVT" AS
/* $Header: OKLSKHRB.pls 120.4 2006/11/10 06:20:06 dpsingh noship $ */
-- --------------------------------------------------------------------------
--  Start of column level validations
-- --------------------------------------------------------------------------
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';


  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_VIEW		 CONSTANT	VARCHAR2(200) := 'OKL_K_HEADERS_V';

  G_EXCEPTION_HALT_VALIDATION	exception;


-- ********************* HAND CODED VALIDATION ********************************

-- Start of comments
--
-- Procedure Name  : validate_khr_id
-- Description     : validates precense of the khr_id for the record
-- Business Rules  : required field
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_khr_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_khrv_rec IN  khrv_rec_type) is
  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKC_K_HEADERS_B
  		where ID = p_khrv_rec.khr_id;
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- enforce foreign key, if data exists
      if (p_khrv_rec.khr_id <> OKC_API.G_MISS_NUM) AND (p_khrv_rec.khr_id IS NOT NULL) then
        Open l_chrv_csr;
        Fetch l_chrv_csr Into l_dummy_var;
        Close l_chrv_csr;

      -- if l_dummy_var still set to default, data was not found
        If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
					    p_msg_name	=> g_no_parent_record,
					    p_token1	=> g_col_name_token,
					    p_token1_value=> 'khr_id',
					    p_token2	=> g_child_table_token,
					    p_token2_value=> G_VIEW,
					    p_token3	=> g_parent_table_token,
					    p_token3_value=> 'OKL_K_HEADERS_V');
	    -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
        End If;
      end if;
    exception
	when G_EXCEPTION_HALT_VALIDATION then
	-- no processing necessary; validation can continue with the next column
	  null;

	when OTHERS then
	-- store SQL error message on message stack for caller
	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1   => g_sqlcode_token,
				    p_token1_value => sqlcode,
				    p_token2	 => g_sqlerrm_token,
				    p_token2_value => sqlerrm);
	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  end validate_khr_id;


-- Start of comments
--
-- Procedure Name  : validate_pdt_id
-- Description     : validates precense of the pdt_id for the record
-- Business Rules  : required field
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_pdt_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_khrv_rec IN  khrv_rec_type) is
  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKL_PRODUCTS
  		where ID = p_khrv_rec.pdt_id;
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- enforce foreign key, if data exists
      if (p_khrv_rec.pdt_id <> OKC_API.G_MISS_NUM) AND (p_khrv_rec.pdt_id IS NOT NULL) then
        Open l_chrv_csr;
        Fetch l_chrv_csr Into l_dummy_var;
        Close l_chrv_csr;

      -- if l_dummy_var still set to default, data was not found
        If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
					    p_msg_name	=> g_no_parent_record,
					    p_token1	=> g_col_name_token,
					    p_token1_value=> 'pdt_id',
					    p_token2	=> g_child_table_token,
					    p_token2_value=> G_VIEW,
					    p_token3	=> g_parent_table_token,
					    p_token3_value=> 'OKL_K_HEADERS_V');
	    -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
        End If;
      end if;
    exception
	when G_EXCEPTION_HALT_VALIDATION then
	-- no processing necessary; validation can continue with the next column
	  null;

	when OTHERS then
	-- store SQL error message on message stack for caller
	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1   => g_sqlcode_token,
				    p_token1_value => sqlcode,
				    p_token2	 => g_sqlerrm_token,
				    p_token2_value => sqlerrm);
	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  end validate_pdt_id;


-- Added by dpsingh
---------------------------------------------------------------------------
  -- PROCEDURE Validate_LE_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_LE_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_LE_Id(p_khrv_rec IN  khrv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
   l_exists                       NUMBER(1);
   item_not_found_error    EXCEPTION;

  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_khrv_rec.legal_entity_id IS NOT NULL) AND
       (p_khrv_rec.legal_entity_id <> Okl_Api.G_MISS_NUM) THEN
           l_exists  := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_khrv_rec.legal_entity_id) ;
           IF (l_exists<>1) THEN
              Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
              RAISE item_not_found_error;
           END IF;
      END IF;

  EXCEPTION
    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_LE_Id;

  -- Start of comments
  --
  -- Procedure Name  : validate_AMD_CODE
  -- Description     :
  -- Business Rules  : lookup OKL_ACCEPTANCE_METHOD
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_AMD_CODE(x_return_status OUT NOCOPY   VARCHAR2,
                              p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key if data exists
    If (p_khrv_rec.AMD_CODE <> OKC_API.G_MISS_CHAR and
	   p_khrv_rec.AMD_CODE IS NOT NULL)
    Then
      -- Check if the value is a valid code from lookup table
      x_return_status := OKC_UTIL.check_lookup_code('OKL_ACCEPTANCE_METHOD',
						    p_khrv_rec.AMD_CODE);
      If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
	    --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1		=> G_COL_NAME_TOKEN,
			p_token1_value => 'ACCEPTANCE_METHOD');
	    raise G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
	    raise G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_AMD_CODE;


  -- Start of comments
  --
  -- Procedure Name  : validate_GENERATE_ACCRUAL_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_GENERATE_ACCRUAL_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.GENERATE_ACCRUAL_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.GENERATE_ACCRUAL_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.GENERATE_ACCRUAL_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'GENERATE_ACCRUAL_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_GENERATE_ACCRUAL_YN;


  -- Start of comments
  --
  -- Procedure Name  : validate_GENERATE_ACCRUAL_OVERRIDE_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_ACCRUAL_OVERRIDE_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'GENERATE_ACCRUAL_OVERRIDE_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_ACCRUAL_OVERRIDE_YN;

  -- Start of comments
  --
  -- Procedure Name  : validate_CREDIT_ACT_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_CREDIT_ACT_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.CREDIT_ACT_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.CREDIT_ACT_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.CREDIT_ACT_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'CREDIT_ACT_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_CREDIT_ACT_YN;

  -- Start of comments
  --
  -- Procedure Name  : validate_CONVERTED_ACCOUNT_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_CONVERTED_ACCOUNT_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.CONVERTED_ACCOUNT_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.CONVERTED_ACCOUNT_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.CONVERTED_ACCOUNT_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'CONVERTED_ACCOUNT_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_CONVERTED_ACCOUNT_YN;

  -- Start of comments
  --
  -- Procedure Name  : validate_SYNDICATABLE_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_SYNDICATABLE_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.SYNDICATABLE_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.SYNDICATABLE_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.SYNDICATABLE_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'SYNDICATABLE_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_SYNDICATABLE_YN;

  -- Start of comments
  --
  -- Procedure Name  : validate_SALESTYPE_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_SALESTYPE_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.SALESTYPE_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.SALESTYPE_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.SALESTYPE_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'SALESTYPE_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_SALESTYPE_YN;

  -- Start of comments
  --
  -- Procedure Name  : validate_deal_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_DEAL_TYPE(x_return_status OUT NOCOPY   VARCHAR2,
                               p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key if data exists
    If (p_khrv_rec.deal_type <> OKC_API.G_MISS_CHAR and
	   p_khrv_rec.deal_type IS NOT NULL)
    Then
      -- Check if the value is a valid code from lookup table
      x_return_status := OKC_UTIL.check_lookup_code('OKL_BOOK_CLASS', p_khrv_rec.deal_type);
      If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
	    --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value => 'DEAL_TYPE');
	    raise G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
	    raise G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_DEAL_TYPE;
-- Start of comments
  --
  -- Procedure Name  : validate_PREFUND_ELIGIBLE_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_PREFUND_ELIGIBLE_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.PREFUNDING_ELIGIBLE_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.PREFUNDING_ELIGIBLE_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.PREFUNDING_ELIGIBLE_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'PREFUNDING_ELIGIBLE_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_PREFUND_ELIGIBLE_YN;

-- Start of comments
  --
  -- Procedure Name  : validate_REVOLVING_CREDIT_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_REVOLVING_CREDIT_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.REVOLVING_CREDIT_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.REVOLVING_CREDIT_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.REVOLVING_CREDIT_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'REVOLVING_CREDIT_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_REVOLVING_CREDIT_YN;

--Bug# 2697681 schema changes  11.5.9
-- Start of comments
  --
  -- Procedure Name  : validate_CURRENCY_CONV_TYPE
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_CURRENCY_CONV_TYPE(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is

  --cursor to chk currency type fk
  cursor curr_conv_type_csr (p_curr_cotyp in varchar2) is
  select '!'
  from   gl_daily_conversion_types
  where  conversion_type = p_curr_cotyp;

  l_valid_convert_type varchar2(1) default '?';
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.CURRENCY_CONVERSION_TYPE <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.CURRENCY_CONVERSION_TYPE IS NOT NULL)
    Then
      -- check allowed values
      l_valid_convert_type := '?';
      open curr_conv_type_csr(p_curr_cotyp => p_khrv_rec.CURRENCY_CONVERSION_TYPE);
      Fetch  curr_conv_type_csr into l_valid_convert_type;
      If curr_conv_type_csr%NOTFOUND then
          Null;
      End If;
      Close curr_conv_type_csr;

      If (l_valid_convert_type = '?')  Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'CURRENCY_CONVERSION_TYPE');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_CURRENCY_CONV_TYPE;

  -- Start of comments
  --
  -- Procedure Name  : validate_MULTI_GAAP_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_MULTI_GAAP_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.MULTI_GAAP_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.MULTI_GAAP_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.MULTI_GAAP_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'MULTI_GAAP_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_MULTI_GAAP_YN;

  -- Start of comments
  --
  -- Procedure Name  : validate_ASSIGNABLE_YN
  -- Description     :
  -- Business Rules  : Y/N field
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_ASSIGNABLE_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_khrv_rec.ASSIGNABLE_YN <> OKC_API.G_MISS_CHAR and
  	   p_khrv_rec.ASSIGNABLE_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_khrv_rec.ASSIGNABLE_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				p_msg_name		=> g_invalid_value,
				p_token1		=> g_col_name_token,
				p_token1_value	=> 'ASSIGNABLE_YN');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_ASSIGNABLE_YN;

-- Start of comments
--
-- Procedure Name  : validate_crs_id
-- Description     : validates presence of the crs_id for the record
-- Business Rules  : required field
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_crs_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_khrv_rec IN  khrv_rec_type) is
  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKL_VP_CHANGE_REQUESTS
  		where ID = p_khrv_rec.crs_id;
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- enforce foreign key, if data exists
      if (p_khrv_rec.crs_id <> OKC_API.G_MISS_NUM) AND (p_khrv_rec.crs_id IS NOT NULL) then
        Open l_chrv_csr;
        Fetch l_chrv_csr Into l_dummy_var;
        Close l_chrv_csr;

      -- if l_dummy_var still set to default, data was not found
        If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			        p_msg_name	=> g_no_parent_record,
				p_token1	=> g_col_name_token,
				p_token1_value  => 'crs_id',
				p_token2	=> g_child_table_token,
				p_token2_value  => G_VIEW,
				p_token3	=> g_parent_table_token,
				p_token3_value  => 'OKL_K_HEADERS_V');
	    -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
        End If;
      end if;
    exception
	when G_EXCEPTION_HALT_VALIDATION then
	-- no processing necessary; validation can continue with the next column
	  null;

	when OTHERS then
	-- store SQL error message on message stack for caller
	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
			      p_msg_name     => G_UNEXPECTED_ERROR,
			      p_token1       => g_sqlcode_token,
			      p_token1_value => sqlcode,
			      p_token2	     => g_sqlerrm_token,
			      p_token2_value => sqlerrm);
	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  end validate_crs_id;


  -- Start of comments
  --
  -- Procedure Name  : validate_template_type_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_TEMPLATE_TYPE_CODE(x_return_status OUT NOCOPY   VARCHAR2,
                                        p_khrv_rec      IN    khrv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key if data exists
    If (p_khrv_rec.template_type_code <> OKC_API.G_MISS_CHAR and
	   p_khrv_rec.template_type_code IS NOT NULL)
    Then
      -- Check if the value is a valid code from lookup table
      x_return_status := OKC_UTIL.check_lookup_code('OKL_TEMPLATE_TYPE', p_khrv_rec.template_type_code);
      If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
	    --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value  => 'TEMPLATE_TYPE_CODE');
	    raise G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
	    raise G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
			      p_msg_name      => g_unexpected_error,
			      p_token1	      => g_sqlcode_token,
			      p_token1_value  => sqlcode,
			      p_token2	      => g_sqlerrm_token,
			      p_token2_value  => sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_TEMPLATE_TYPE_CODE;

  --Bug# 4558486: start
  -- Start of comments
  --
  -- Procedure Name  : validate_DFF_attributes
  -- Description     :
  -- Business Rules  : DFF validation
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_DFF_attributes
              (x_return_status OUT NOCOPY   VARCHAR2,
               p_khrv_rec      IN    khrv_rec_type) is

    l_segment_values_rec   Okl_DFlex_Util_Pvt.DFF_Rec_type;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_appl_short_name      VARCHAR2(30) := 'OKL';
    l_desc_flex_name       VARCHAR2(30) := 'OKL_K_HEADERS_DF';
    l_segment_partial_name VARCHAR2(30) := 'ATTRIBUTE';
  Begin
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_segment_values_rec.attribute_category := p_khrv_rec.attribute_category;
    l_segment_values_rec.attribute1 := p_khrv_rec.attribute1;
    l_segment_values_rec.attribute2 := p_khrv_rec.attribute2;
    l_segment_values_rec.attribute3 := p_khrv_rec.attribute3;
    l_segment_values_rec.attribute4 := p_khrv_rec.attribute4;
    l_segment_values_rec.attribute5 := p_khrv_rec.attribute5;
    l_segment_values_rec.attribute6 := p_khrv_rec.attribute6;
    l_segment_values_rec.attribute7 := p_khrv_rec.attribute7;
    l_segment_values_rec.attribute8 := p_khrv_rec.attribute8;
    l_segment_values_rec.attribute9 := p_khrv_rec.attribute9;
    l_segment_values_rec.attribute10 := p_khrv_rec.attribute10;
    l_segment_values_rec.attribute11 := p_khrv_rec.attribute11;
    l_segment_values_rec.attribute12 := p_khrv_rec.attribute12;
    l_segment_values_rec.attribute13 := p_khrv_rec.attribute13;
    l_segment_values_rec.attribute14 := p_khrv_rec.attribute14;
    l_segment_values_rec.attribute15 := p_khrv_rec.attribute15;

    okl_dflex_util_pvt.validate_desc_flex
      (p_api_version          => 1.0
      ,p_init_msg_list        => OKL_API.G_FALSE
      ,x_return_status        => x_return_status
      ,x_msg_count            => l_msg_count
      ,x_msg_data             => l_msg_data
      ,p_appl_short_name      => l_appl_short_name
      ,p_descflex_name        => l_desc_flex_name
      ,p_segment_partial_name => l_segment_partial_name
      ,p_segment_values_rec   => l_segment_values_rec);

     -- check return status
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;

    when OTHERS then
       -- store SQL error message on message stack
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1	      => g_sqlcode_token,
                           p_token1_value	=> sqlcode,
                           p_token2	      => g_sqlerrm_token,
                           p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  End validate_DFF_attributes;
  --Bug# 4558486: end

-- ********************* END OF HAND CODED VALIDATION ********************************

-- Start of comments
--
-- Procedure Name  : validate_ID
-- Description     : validates precense of the ID for the record
-- Business Rules  : required field
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_ID(x_return_status OUT NOCOPY VARCHAR2,
			      p_khrv_rec                     IN khrv_rec_type
    ) is
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- data is required
      if (p_khrv_rec.ID = OKC_API.G_MISS_NUM) OR (p_khrv_rec.ID IS NULL) then
	  OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ID');

	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_ERROR;

	-- halt further validation of this column
	  raise G_EXCEPTION_HALT_VALIDATION;
	end if;
    exception
	when G_EXCEPTION_HALT_VALIDATION then
	-- no processing necessary; validation can continue with the next column
	  null;

	when OTHERS then
	-- store SQL error message on message stack for caller
	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1   => g_sqlcode_token,
				    p_token1_value => sqlcode,
				    p_token2	 => g_sqlerrm_token,
				    p_token2_value => sqlerrm);
	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  end validate_ID;

-- Start of comments
--
-- Procedure Name  : validate_OBJECT_VERSION_NUMBER
-- Description     : validates precense of the OBJECT_VERSION_NUMBER for the record
-- Business Rules  : required field
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_OBJECT_VERSION_NUMBER(x_return_status OUT NOCOPY VARCHAR2,
			      p_khrv_rec                     IN khrv_rec_type
    ) is
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- data is required
      if (p_khrv_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) OR (p_khrv_rec.OBJECT_VERSION_NUMBER IS NULL) then
	  OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'OBJECT_VERSION_NUMBER');

	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_ERROR;

	-- halt further validation of this column
	  raise G_EXCEPTION_HALT_VALIDATION;
	end if;
    exception
	when G_EXCEPTION_HALT_VALIDATION then
	-- no processing necessary; validation can continue with the next column
	  null;

	when OTHERS then
	-- store SQL error message on message stack for caller
	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1   => g_sqlcode_token,
				    p_token1_value => sqlcode,
				    p_token2	 => g_sqlerrm_token,
				    p_token2_value => sqlerrm);
	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  end validate_OBJECT_VERSION_NUMBER;

  ---------------------------------------------
  -- Validate_Attributes for: OKL_K_HEADERS_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_khrv_rec                     IN khrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN


    -- call each column-level validation
    -- do not validate id because it will be set up automatically

/*
    validate_ID(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;
*/
    validate_OBJECT_VERSION_NUMBER(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_KHR_ID(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_PDT_ID(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_AMD_CODE(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_GENERATE_ACCRUAL_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_ACCRUAL_OVERRIDE_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_CREDIT_ACT_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_CONVERTED_ACCOUNT_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_SYNDICATABLE_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_SALESTYPE_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;


    validate_DEAL_TYPE(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_PREFUND_ELIGIBLE_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

   validate_revolving_credit_YN(x_return_status => l_return_status,
		    p_khrv_rec	  => p_khrv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    --Bug# 4558486
    -- ***
    -- DFF Attributes
    -- ***
    if ( NVL(p_khrv_rec.validate_dff_yn,OKL_API.G_MISS_CHAR) = 'Y') then
      validate_DFF_attributes
        (x_return_status => l_return_status,
         p_khrv_rec      => p_khrv_rec);

      -- store the highest degree of error
      if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	  if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	    x_return_status := l_return_status;
	  end if;
      end if;
    end if;

--Added by dpsingh

-- Validate_LE_Id
    Validate_LE_Id(p_khrv_rec  => p_khrv_rec,
                           x_return_status  => l_return_status);
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    -- return status to caller
    return x_return_status;
    exception
	when OTHERS then
	-- store SQL error message on message stack for caller
	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1   => g_sqlcode_token,
				    p_token1_value => sqlcode,
				    p_token2	 => g_sqlerrm_token,
				    p_token2_value => sqlerrm);
	-- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	-- return status to caller
	  return x_return_status;
  END Validate_Attributes;

-- --------------------------------------------------------------------------
--  End of column level validations
-- --------------------------------------------------------------------------

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
  -- FUNCTION get_rec for: OKL_K_HEADERS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_khr_rec                     IN khr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN khr_rec_type IS
    CURSOR okl_k_headers_pk_csr (p_id                 IN NUMBER) IS
      SELECT
	ID,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED ,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID
 FROM OKL_K_HEADERS
      WHERE OKL_K_HEADERS.id     = p_id;

      l_khr_rec                      khr_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_headers_pk_csr (p_khr_rec.id);
    FETCH okl_k_headers_pk_csr INTO
       l_khr_rec.ID,
        l_khr_rec.ISG_ID,
        l_khr_rec.KHR_ID,
        l_khr_rec.PDT_ID,
        l_khr_rec.OBJECT_VERSION_NUMBER,
        l_khr_rec.DATE_FIRST_ACTIVITY,
        l_khr_rec.SYNDICATABLE_YN,
        l_khr_rec.SALESTYPE_YN,
        l_khr_rec.DATE_REFINANCED,
        l_khr_rec.DATE_CONVERSION_EFFECTIVE,
        l_khr_rec.DATE_DEAL_TRANSFERRED,
        l_khr_rec.TERM_DURATION,
        l_khr_rec.DATETIME_PROPOSAL_EFFECTIVE,
        l_khr_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        l_khr_rec.DATE_PROPOSAL_ACCEPTED,
        l_khr_rec.ATTRIBUTE_CATEGORY,
        l_khr_rec.ATTRIBUTE1,
        l_khr_rec.ATTRIBUTE2,
        l_khr_rec.ATTRIBUTE3,
        l_khr_rec.ATTRIBUTE4,
        l_khr_rec.ATTRIBUTE5,
        l_khr_rec.ATTRIBUTE6,
        l_khr_rec.ATTRIBUTE7,
        l_khr_rec.ATTRIBUTE8,
        l_khr_rec.ATTRIBUTE9,
        l_khr_rec.ATTRIBUTE10,
        l_khr_rec.ATTRIBUTE11,
        l_khr_rec.ATTRIBUTE12,
        l_khr_rec.ATTRIBUTE13,
        l_khr_rec.ATTRIBUTE14,
        l_khr_rec.ATTRIBUTE15,
        l_khr_rec.CREATED_BY,
        l_khr_rec.CREATION_DATE,
        l_khr_rec.LAST_UPDATED_BY,
        l_khr_rec.LAST_UPDATE_DATE,
        l_khr_rec.LAST_UPDATE_LOGIN,
        l_khr_rec.AMD_CODE,
        l_khr_rec.GENERATE_ACCRUAL_YN,
        l_khr_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        l_khr_rec.CREDIT_ACT_YN,
        l_khr_rec.CONVERTED_ACCOUNT_YN,
        l_khr_rec.PRE_TAX_YIELD,
        l_khr_rec.AFTER_TAX_YIELD,
        l_khr_rec.IMPLICIT_INTEREST_RATE,
        l_khr_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        l_khr_rec.TARGET_PRE_TAX_YIELD,
        l_khr_rec.TARGET_AFTER_TAX_YIELD,
        l_khr_rec.TARGET_IMPLICIT_INTEREST_RATE,
        l_khr_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        l_khr_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        l_khr_rec.DEAL_TYPE,
        l_khr_rec.PRE_TAX_IRR,
        l_khr_rec.AFTER_TAX_IRR,
        l_khr_rec.EXPECTED_DELIVERY_DATE,
        l_khr_rec.ACCEPTED_DATE,
        l_khr_rec.PREFUNDING_ELIGIBLE_YN,
        l_khr_rec.REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        l_khr_rec.CURRENCY_CONVERSION_TYPE,
        l_khr_rec.CURRENCY_CONVERSION_RATE,
        l_khr_rec.CURRENCY_CONVERSION_DATE,
        l_khr_rec.MULTI_GAAP_YN,
        l_khr_rec.RECOURSE_CODE,
        l_khr_rec.LESSOR_SERV_ORG_CODE,
        l_khr_rec.ASSIGNABLE_YN,
        l_khr_rec.SECURITIZED_CODE,
        l_khr_rec.SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   l_khr_rec.SUB_PRE_TAX_YIELD,
   l_khr_rec.SUB_AFTER_TAX_YIELD,
   l_khr_rec.SUB_IMPL_INTEREST_RATE,
   l_khr_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_khr_rec.SUB_PRE_TAX_IRR,
   l_khr_rec.SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+
   l_khr_rec.TOT_CL_TRANSFER_AMT,
   l_khr_rec.TOT_CL_NET_TRANSFER_AMT,
   l_khr_rec.TOT_CL_LIMIT,
   l_khr_rec.TOT_CL_FUNDING_AMT,
   l_khr_rec.CRS_ID,
   l_khr_rec.TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   l_khr_rec.DATE_FUNDING_EXPECTED ,
   l_khr_rec.DATE_TRADEIN,
   l_khr_rec.TRADEIN_AMOUNT,
   l_khr_rec.TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
    l_khr_rec.LEGAL_ENTITY_ID     ;
    x_no_data_found := okl_k_headers_pk_csr%NOTFOUND;
    CLOSE okl_k_headers_pk_csr;
    RETURN(l_khr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_khr_rec                     IN khr_rec_type
  ) RETURN khr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_khr_rec, l_row_notfound));
  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_K_HEADERS_H
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_k_headers_h_rec                     IN okl_k_headers_h_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_k_headers_h_rec_type IS
    CURSOR okl_k_headers_h_pk_csr (p_id                 IN NUMBER) IS
      SELECT
	ID,
        MAJOR_VERSION,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED ,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
--Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID
      FROM OKL_K_HEADERS_H
      WHERE OKL_K_HEADERS_H.id     = p_id;
       l_okl_k_headers_h_rec                      okl_k_headers_h_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_headers_h_pk_csr (p_okl_k_headers_h_rec.id);
    FETCH okl_k_headers_h_pk_csr INTO
       l_okl_k_headers_h_rec.ID,
        l_okl_k_headers_h_rec.MAJOR_VERSION,
        l_okl_k_headers_h_rec.ISG_ID,
        l_okl_k_headers_h_rec.KHR_ID,
        l_okl_k_headers_h_rec.PDT_ID,
        l_okl_k_headers_h_rec.OBJECT_VERSION_NUMBER,
        l_okl_k_headers_h_rec.DATE_FIRST_ACTIVITY,
        l_okl_k_headers_h_rec.SYNDICATABLE_YN,
        l_okl_k_headers_h_rec.SALESTYPE_YN,
        l_okl_k_headers_h_rec.DATE_REFINANCED,
        l_okl_k_headers_h_rec.DATE_CONVERSION_EFFECTIVE,
        l_okl_k_headers_h_rec.DATE_DEAL_TRANSFERRED,
        l_okl_k_headers_h_rec.TERM_DURATION,
        l_okl_k_headers_h_rec.DATETIME_PROPOSAL_EFFECTIVE,
        l_okl_k_headers_h_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        l_okl_k_headers_h_rec.DATE_PROPOSAL_ACCEPTED,
        l_okl_k_headers_h_rec.ATTRIBUTE_CATEGORY,
        l_okl_k_headers_h_rec.ATTRIBUTE1,
        l_okl_k_headers_h_rec.ATTRIBUTE2,
        l_okl_k_headers_h_rec.ATTRIBUTE3,
        l_okl_k_headers_h_rec.ATTRIBUTE4,
        l_okl_k_headers_h_rec.ATTRIBUTE5,
        l_okl_k_headers_h_rec.ATTRIBUTE6,
        l_okl_k_headers_h_rec.ATTRIBUTE7,
        l_okl_k_headers_h_rec.ATTRIBUTE8,
        l_okl_k_headers_h_rec.ATTRIBUTE9,
        l_okl_k_headers_h_rec.ATTRIBUTE10,
        l_okl_k_headers_h_rec.ATTRIBUTE11,
        l_okl_k_headers_h_rec.ATTRIBUTE12,
        l_okl_k_headers_h_rec.ATTRIBUTE13,
        l_okl_k_headers_h_rec.ATTRIBUTE14,
        l_okl_k_headers_h_rec.ATTRIBUTE15,
        l_okl_k_headers_h_rec.CREATED_BY,
        l_okl_k_headers_h_rec.CREATION_DATE,
        l_okl_k_headers_h_rec.LAST_UPDATED_BY,
        l_okl_k_headers_h_rec.LAST_UPDATE_DATE,
        l_okl_k_headers_h_rec.LAST_UPDATE_LOGIN,
        l_okl_k_headers_h_rec.AMD_CODE,
        l_okl_k_headers_h_rec.GENERATE_ACCRUAL_YN,
        l_okl_k_headers_h_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        l_okl_k_headers_h_rec.CREDIT_ACT_YN,
        l_okl_k_headers_h_rec.CONVERTED_ACCOUNT_YN,
        l_okl_k_headers_h_rec.PRE_TAX_YIELD,
        l_okl_k_headers_h_rec.AFTER_TAX_YIELD,
        l_okl_k_headers_h_rec.IMPLICIT_INTEREST_RATE,
        l_okl_k_headers_h_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        l_okl_k_headers_h_rec.TARGET_PRE_TAX_YIELD,
        l_okl_k_headers_h_rec.TARGET_AFTER_TAX_YIELD,
        l_okl_k_headers_h_rec.TARGET_IMPLICIT_INTEREST_RATE,
        l_okl_k_headers_h_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        l_okl_k_headers_h_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        l_okl_k_headers_h_rec.DEAL_TYPE,
        l_okl_k_headers_h_rec.PRE_TAX_IRR,
        l_okl_k_headers_h_rec.AFTER_TAX_IRR,
        l_okl_k_headers_h_rec.EXPECTED_DELIVERY_DATE,
        l_okl_k_headers_h_rec.ACCEPTED_DATE,
        l_okl_k_headers_h_rec.PREFUNDING_ELIGIBLE_YN,
        l_okl_k_headers_h_rec.REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        l_okl_k_headers_h_rec.CURRENCY_CONVERSION_TYPE,
        l_okl_k_headers_h_rec.CURRENCY_CONVERSION_RATE,
        l_okl_k_headers_h_rec.CURRENCY_CONVERSION_DATE,
        l_okl_k_headers_h_rec.MULTI_GAAP_YN,
        l_okl_k_headers_h_rec.RECOURSE_CODE,
        l_okl_k_headers_h_rec.LESSOR_SERV_ORG_CODE,
        l_okl_k_headers_h_rec.ASSIGNABLE_YN,
        l_okl_k_headers_h_rec.SECURITIZED_CODE,
        l_okl_k_headers_h_rec.SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   l_okl_k_headers_h_rec.SUB_PRE_TAX_YIELD,
   l_okl_k_headers_h_rec.SUB_AFTER_TAX_YIELD,
   l_okl_k_headers_h_rec.SUB_IMPL_INTEREST_RATE,
   l_okl_k_headers_h_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_okl_k_headers_h_rec.SUB_PRE_TAX_IRR,
   l_okl_k_headers_h_rec.SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+
   l_okl_k_headers_h_rec.TOT_CL_TRANSFER_AMT,
   l_okl_k_headers_h_rec.TOT_CL_NET_TRANSFER_AMT,
   l_okl_k_headers_h_rec.TOT_CL_LIMIT,
   l_okl_k_headers_h_rec.TOT_CL_FUNDING_AMT,
   l_okl_k_headers_h_rec.CRS_ID,
   l_okl_k_headers_h_rec.TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   l_okl_k_headers_h_rec.DATE_FUNDING_EXPECTED ,
   l_okl_k_headers_h_rec.DATE_TRADEIN,
   l_okl_k_headers_h_rec.TRADEIN_AMOUNT,
   l_okl_k_headers_h_rec.TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   l_okl_k_headers_h_rec.LEGAL_ENTITY_ID
        ;
    x_no_data_found := okl_k_headers_h_pk_csr%NOTFOUND;
    CLOSE okl_k_headers_h_pk_csr;
    RETURN(l_okl_k_headers_h_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_k_headers_h_rec                     IN okl_k_headers_h_rec_type
  ) RETURN okl_k_headers_h_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_k_headers_h_rec, l_row_notfound));
  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_K_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_khrv_rec                     IN khrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN khrv_rec_type IS
    CURSOR okl_k_headers_v_pk_csr (p_id                 IN NUMBER) IS
      SELECT
	ID,
        OBJECT_VERSION_NUMBER,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        AMD_CODE,
        DATE_FIRST_ACTIVITY,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        DATE_REFINANCED,
        CREDIT_ACT_YN,
        TERM_DURATION,
        CONVERTED_ACCOUNT_YN,
        DATE_CONVERSION_EFFECTIVE,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_DEAL_TRANSFERRED,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 11.5.10+ schema
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED ,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID
      FROM OKL_K_HEADERS_V
      WHERE OKL_K_HEADERS_V.id     = p_id;

      l_khrv_rec                      khrv_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_headers_v_pk_csr (p_khrv_rec.id);
    FETCH okl_k_headers_v_pk_csr INTO
       l_khrv_rec.ID,
        l_khrv_rec.OBJECT_VERSION_NUMBER,
        l_khrv_rec.ISG_ID,
        l_khrv_rec.KHR_ID,
        l_khrv_rec.PDT_ID,
        l_khrv_rec.AMD_CODE,
        l_khrv_rec.DATE_FIRST_ACTIVITY,
        l_khrv_rec.GENERATE_ACCRUAL_YN,
        l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        l_khrv_rec.DATE_REFINANCED,
        l_khrv_rec.CREDIT_ACT_YN,
        l_khrv_rec.TERM_DURATION,
        l_khrv_rec.CONVERTED_ACCOUNT_YN,
        l_khrv_rec.DATE_CONVERSION_EFFECTIVE,
        l_khrv_rec.SYNDICATABLE_YN,
        l_khrv_rec.SALESTYPE_YN,
        l_khrv_rec.DATE_DEAL_TRANSFERRED,
        l_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE,
        l_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        l_khrv_rec.DATE_PROPOSAL_ACCEPTED,
        l_khrv_rec.ATTRIBUTE_CATEGORY,
        l_khrv_rec.ATTRIBUTE1,
        l_khrv_rec.ATTRIBUTE2,
        l_khrv_rec.ATTRIBUTE3,
        l_khrv_rec.ATTRIBUTE4,
        l_khrv_rec.ATTRIBUTE5,
        l_khrv_rec.ATTRIBUTE6,
        l_khrv_rec.ATTRIBUTE7,
        l_khrv_rec.ATTRIBUTE8,
        l_khrv_rec.ATTRIBUTE9,
        l_khrv_rec.ATTRIBUTE10,
        l_khrv_rec.ATTRIBUTE11,
        l_khrv_rec.ATTRIBUTE12,
        l_khrv_rec.ATTRIBUTE13,
        l_khrv_rec.ATTRIBUTE14,
        l_khrv_rec.ATTRIBUTE15,
        l_khrv_rec.CREATED_BY,
        l_khrv_rec.CREATION_DATE,
        l_khrv_rec.LAST_UPDATED_BY,
        l_khrv_rec.LAST_UPDATE_DATE,
        l_khrv_rec.LAST_UPDATE_LOGIN,
        l_khrv_rec.PRE_TAX_YIELD,
        l_khrv_rec.AFTER_TAX_YIELD,
        l_khrv_rec.IMPLICIT_INTEREST_RATE,
        l_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        l_khrv_rec.TARGET_PRE_TAX_YIELD,
        l_khrv_rec.TARGET_AFTER_TAX_YIELD,
        l_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE,
        l_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        l_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        l_khrv_rec.DEAL_TYPE,
        l_khrv_rec.PRE_TAX_IRR,
        l_khrv_rec.AFTER_TAX_IRR,
        l_khrv_rec.EXPECTED_DELIVERY_DATE,
        l_khrv_rec.ACCEPTED_DATE,
        l_khrv_rec.PREFUNDING_ELIGIBLE_YN,
        l_khrv_rec.REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        l_khrv_rec.CURRENCY_CONVERSION_TYPE,
        l_khrv_rec.CURRENCY_CONVERSION_RATE,
        l_khrv_rec.CURRENCY_CONVERSION_DATE,
        l_khrv_rec.MULTI_GAAP_YN,
        l_khrv_rec.RECOURSE_CODE,
        l_khrv_rec.LESSOR_SERV_ORG_CODE,
        l_khrv_rec.ASSIGNABLE_YN,
        l_khrv_rec.SECURITIZED_CODE,
        l_khrv_rec.SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   l_khrv_rec.SUB_PRE_TAX_YIELD,
   l_khrv_rec.SUB_AFTER_TAX_YIELD,
   l_khrv_rec.SUB_IMPL_INTEREST_RATE,
   l_khrv_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_khrv_rec.SUB_PRE_TAX_IRR,
   l_khrv_rec.SUB_AFTER_TAX_IRR,
   --Bug# 3973640 11.5.10+ schema
   l_khrv_rec.TOT_CL_TRANSFER_AMT,
   l_khrv_rec.TOT_CL_NET_TRANSFER_AMT,
   l_khrv_rec.TOT_CL_LIMIT,
   l_khrv_rec.TOT_CL_FUNDING_AMT,
   l_khrv_rec.CRS_ID,
   l_khrv_rec.TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   l_khrv_rec.DATE_FUNDING_EXPECTED ,
   l_khrv_rec.DATE_TRADEIN,
   l_khrv_rec.TRADEIN_AMOUNT,
   l_khrv_rec.TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   l_khrv_rec.LEGAL_ENTITY_ID ;
    x_no_data_found := okl_k_headers_v_pk_csr%NOTFOUND;
    CLOSE okl_k_headers_v_pk_csr;
    RETURN(l_khrv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_khrv_rec                     IN khrv_rec_type
  ) RETURN khrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_khrv_rec, l_row_notfound));
  END get_rec;


  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_K_HEADERS_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_khrv_rec                     IN khrv_rec_type
  ) RETURN khrv_rec_type IS
    l_khrv_rec	khrv_rec_type := p_khrv_rec;
  BEGIN

    IF (l_khrv_rec.ID = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.ID := NULL;
    END IF;

    IF (l_khrv_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.OBJECT_VERSION_NUMBER := NULL;
    END IF;

    IF (l_khrv_rec.ISG_ID = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.ISG_ID := NULL;
    END IF;

    IF (l_khrv_rec.KHR_ID = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.KHR_ID := NULL;
    END IF;

    IF (l_khrv_rec.PDT_ID = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.PDT_ID := NULL;
    END IF;

    IF (l_khrv_rec.AMD_CODE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.AMD_CODE := NULL;
    END IF;

    IF (l_khrv_rec.DATE_FIRST_ACTIVITY = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_FIRST_ACTIVITY := NULL;
    END IF;

    IF (l_khrv_rec.GENERATE_ACCRUAL_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.GENERATE_ACCRUAL_YN := NULL;
    END IF;

    IF (l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN := NULL;
    END IF;

    IF (l_khrv_rec.DATE_REFINANCED = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_REFINANCED := NULL;
    END IF;

    IF (l_khrv_rec.CREDIT_ACT_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.CREDIT_ACT_YN := NULL;
    END IF;

    IF (l_khrv_rec.TERM_DURATION = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TERM_DURATION := NULL;
    END IF;

    IF (l_khrv_rec.CONVERTED_ACCOUNT_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.CONVERTED_ACCOUNT_YN := NULL;
    END IF;

    IF (l_khrv_rec.DATE_CONVERSION_EFFECTIVE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_CONVERSION_EFFECTIVE := NULL;
    END IF;

    IF (l_khrv_rec.SYNDICATABLE_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.SYNDICATABLE_YN := NULL;
    END IF;

    IF (l_khrv_rec.SALESTYPE_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.SALESTYPE_YN := NULL;
    END IF;

    IF (l_khrv_rec.DATE_DEAL_TRANSFERRED = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_DEAL_TRANSFERRED := NULL;
    END IF;

    IF (l_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE := NULL;
    END IF;

    IF (l_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE := NULL;
    END IF;

    IF (l_khrv_rec.DATE_PROPOSAL_ACCEPTED = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_PROPOSAL_ACCEPTED := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE_CATEGORY = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE1 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE2 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE3 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE4 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE5 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE6 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE7 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE8 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE9 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE10 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE11 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE12 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE13 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE14 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF (l_khrv_rec.ATTRIBUTE15 = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ATTRIBUTE15 := NULL;
    END IF;

    IF (l_khrv_rec.CREATED_BY = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.CREATED_BY := NULL;
    END IF;

    IF (l_khrv_rec.CREATION_DATE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.CREATION_DATE := NULL;
    END IF;

    IF (l_khrv_rec.LAST_UPDATED_BY = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF (l_khrv_rec.LAST_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    IF (l_khrv_rec.LAST_UPDATE_LOGIN = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF (l_khrv_rec.PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.PRE_TAX_YIELD := NULL;
    END IF;

    IF (l_khrv_rec.AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.AFTER_TAX_YIELD := NULL;
    END IF;

    IF (l_khrv_rec.IMPLICIT_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.IMPLICIT_INTEREST_RATE := NULL;
    END IF;

    IF (l_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE := NULL;
    END IF;

    IF (l_khrv_rec.TARGET_PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TARGET_PRE_TAX_YIELD := NULL;
    END IF;

    IF (l_khrv_rec.TARGET_AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TARGET_AFTER_TAX_YIELD := NULL;
    END IF;

    IF (l_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE := NULL;
    END IF;

    IF (l_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE := NULL;
    END IF;

    IF (l_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL := NULL;
    END IF;

    IF (l_khrv_rec.DEAL_TYPE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.DEAL_TYPE := NULL;
    END IF;

    IF (l_khrv_rec.PRE_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.PRE_TAX_IRR := NULL;
    END IF;

    IF (l_khrv_rec.AFTER_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.AFTER_TAX_IRR := NULL;
    END IF;

    IF (l_khrv_rec.EXPECTED_DELIVERY_DATE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.EXPECTED_DELIVERY_DATE := NULL;
    END IF;

    IF (l_khrv_rec.ACCEPTED_DATE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.ACCEPTED_DATE := NULL;
    END IF;

    IF (l_khrv_rec.PREFUNDING_ELIGIBLE_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.PREFUNDING_ELIGIBLE_YN := NULL;
    END IF;

    IF (l_khrv_rec.REVOLVING_CREDIT_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.REVOLVING_CREDIT_YN := NULL;
    END IF;

--Bug# 2697681 schema changes  11.5.9
    IF (l_khrv_rec.CURRENCY_CONVERSION_TYPE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.CURRENCY_CONVERSION_TYPE := NULL;
    END IF;

    IF (l_khrv_rec.CURRENCY_CONVERSION_RATE = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.CURRENCY_CONVERSION_RATE := NULL;
    END IF;

    IF (l_khrv_rec.CURRENCY_CONVERSION_DATE = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.CURRENCY_CONVERSION_DATE := NULL;
    END IF;

    IF (l_khrv_rec.MULTI_GAAP_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.MULTI_GAAP_YN := NULL;
    END IF;

    IF (l_khrv_rec.RECOURSE_CODE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.RECOURSE_CODE := NULL;
    END IF;

    IF (l_khrv_rec.LESSOR_SERV_ORG_CODE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.LESSOR_SERV_ORG_CODE := NULL;
    END IF;

    IF (l_khrv_rec.ASSIGNABLE_YN = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.ASSIGNABLE_YN := NULL;
    END IF;

    IF (l_khrv_rec.SECURITIZED_CODE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.SECURITIZED_CODE := NULL;
    END IF;

    IF (l_khrv_rec.SECURITIZATION_TYPE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.SECURITIZATION_TYPE := NULL;
    END IF;
--Bug#3143522 : 11.5.10
    --subsidy
    IF (l_khrv_rec.SUB_PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.SUB_PRE_TAX_YIELD := NULL;
    END IF;
    IF (l_khrv_rec.SUB_AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.SUB_AFTER_TAX_YIELD := NULL;
    END IF;
    IF (l_khrv_rec.SUB_IMPL_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.SUB_IMPL_INTEREST_RATE := NULL;
    END IF;
    IF (l_khrv_rec.SUB_IMPL_NON_IDC_INT_RATE = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.SUB_IMPL_NON_IDC_INT_RATE := NULL;
    END IF;
    IF (l_khrv_rec.SUB_PRE_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.SUB_PRE_TAX_IRR := NULL;
    END IF;
    IF (l_khrv_rec.SUB_AFTER_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.SUB_AFTER_TAX_IRR := NULL;
    END IF;
    --Bug# 3973640 : 11.5.10+ schema changes
    IF (l_khrv_rec.TOT_CL_TRANSFER_AMT = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TOT_CL_TRANSFER_AMT := NULL;
    END IF;
    IF (l_khrv_rec.TOT_CL_NET_TRANSFER_AMT = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TOT_CL_NET_TRANSFER_AMT := NULL;
    END IF;
    IF (l_khrv_rec.TOT_CL_LIMIT = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TOT_CL_LIMIT := NULL;
    END IF;
    IF (l_khrv_rec.TOT_CL_FUNDING_AMT = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TOT_CL_FUNDING_AMT := NULL;
    END IF;
    IF (l_khrv_rec.CRS_ID = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.CRS_ID := NULL;
    END IF;
    IF (l_khrv_rec.TEMPLATE_TYPE_CODE = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.TEMPLATE_TYPE_CODE := NULL;
    END IF;
--Bug# 4419339 OKLH Schema Sales Quote
    IF (l_khrv_rec.DATE_FUNDING_EXPECTED = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_FUNDING_EXPECTED := NULL;
    END IF;

    IF (l_khrv_rec.DATE_TRADEIN = OKC_API.G_MISS_DATE) THEN
      l_khrv_rec.DATE_TRADEIN := NULL;
    END IF;

    IF (l_khrv_rec.TRADEIN_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_khrv_rec.TRADEIN_AMOUNT := NULL;
    END IF;

    IF (l_khrv_rec.TRADEIN_DESCRIPTION = OKC_API.G_MISS_CHAR) THEN
      l_khrv_rec.TRADEIN_DESCRIPTION := NULL;
    END IF;

--Added by dpsingh for LE uptake
    IF (l_khrv_rec.LEGAL_ENTITY_ID = OKL_API.G_MISS_NUM) THEN
      l_khrv_rec.LEGAL_ENTITY_ID := NULL;
    END IF;

    RETURN(l_khrv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------


  -----------------------------------------
  -- Validate_Record for: OKL_K_HEADERS_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_khrv_rec                     IN khrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN khrv_rec_type,
    p_to	IN OUT NOCOPY khr_rec_type
  ) IS
  BEGIN

      p_to.ID := p_from.ID;

      p_to.ISG_ID := p_from.ISG_ID;

      p_to.KHR_ID := p_from.KHR_ID;

      p_to.PDT_ID := p_from.PDT_ID;

      p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;

      p_to.DATE_FIRST_ACTIVITY := p_from.DATE_FIRST_ACTIVITY;

      p_to.SYNDICATABLE_YN := p_from.SYNDICATABLE_YN;

      p_to.SALESTYPE_YN := p_from.SALESTYPE_YN;

      p_to.DATE_REFINANCED := p_from.DATE_REFINANCED;

      p_to.DATE_CONVERSION_EFFECTIVE := p_from.DATE_CONVERSION_EFFECTIVE;

      p_to.DATE_DEAL_TRANSFERRED := p_from.DATE_DEAL_TRANSFERRED;

      p_to.TERM_DURATION := p_from.TERM_DURATION;

      p_to.DATETIME_PROPOSAL_EFFECTIVE := p_from.DATETIME_PROPOSAL_EFFECTIVE;

      p_to.DATETIME_PROPOSAL_INEFFECTIVE := p_from.DATETIME_PROPOSAL_INEFFECTIVE;

      p_to.DATE_PROPOSAL_ACCEPTED := p_from.DATE_PROPOSAL_ACCEPTED;

      p_to.ATTRIBUTE_CATEGORY := p_from.ATTRIBUTE_CATEGORY;

      p_to.ATTRIBUTE1 := p_from.ATTRIBUTE1;

      p_to.ATTRIBUTE2 := p_from.ATTRIBUTE2;

      p_to.ATTRIBUTE3 := p_from.ATTRIBUTE3;

      p_to.ATTRIBUTE4 := p_from.ATTRIBUTE4;

      p_to.ATTRIBUTE5 := p_from.ATTRIBUTE5;

      p_to.ATTRIBUTE6 := p_from.ATTRIBUTE6;

      p_to.ATTRIBUTE7 := p_from.ATTRIBUTE7;

      p_to.ATTRIBUTE8 := p_from.ATTRIBUTE8;

      p_to.ATTRIBUTE9 := p_from.ATTRIBUTE9;

      p_to.ATTRIBUTE10 := p_from.ATTRIBUTE10;

      p_to.ATTRIBUTE11 := p_from.ATTRIBUTE11;

      p_to.ATTRIBUTE12 := p_from.ATTRIBUTE12;

      p_to.ATTRIBUTE13 := p_from.ATTRIBUTE13;

      p_to.ATTRIBUTE14 := p_from.ATTRIBUTE14;

      p_to.ATTRIBUTE15 := p_from.ATTRIBUTE15;

      p_to.CREATED_BY := p_from.CREATED_BY;

      p_to.CREATION_DATE := p_from.CREATION_DATE;

      p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;

      p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;

      p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;

      p_to.AMD_CODE := p_from.AMD_CODE;

      p_to.GENERATE_ACCRUAL_YN := p_from.GENERATE_ACCRUAL_YN;

      p_to.GENERATE_ACCRUAL_OVERRIDE_YN := p_from.GENERATE_ACCRUAL_OVERRIDE_YN;

      p_to.CREDIT_ACT_YN := p_from.CREDIT_ACT_YN;

      p_to.CONVERTED_ACCOUNT_YN := p_from.CONVERTED_ACCOUNT_YN;

      p_to.PRE_TAX_YIELD := p_from.PRE_TAX_YIELD;

      p_to.AFTER_TAX_YIELD := p_from.AFTER_TAX_YIELD;

      p_to.IMPLICIT_INTEREST_RATE := p_from.IMPLICIT_INTEREST_RATE;

      p_to.IMPLICIT_NON_IDC_INTEREST_RATE := p_from.IMPLICIT_NON_IDC_INTEREST_RATE;

      p_to.TARGET_PRE_TAX_YIELD := p_from.TARGET_PRE_TAX_YIELD;

      p_to.TARGET_AFTER_TAX_YIELD := p_from.TARGET_AFTER_TAX_YIELD;

      p_to.TARGET_IMPLICIT_INTEREST_RATE := p_from.TARGET_IMPLICIT_INTEREST_RATE;

      p_to.TARGET_IMPLICIT_NONIDC_INTRATE := p_from.TARGET_IMPLICIT_NONIDC_INTRATE;

      p_to.DATE_LAST_INTERIM_INTEREST_CAL := p_from.DATE_LAST_INTERIM_INTEREST_CAL;

      p_to.DEAL_TYPE := p_from.DEAL_TYPE;

      p_to.PRE_TAX_IRR := p_from.PRE_TAX_IRR;

      p_to.AFTER_TAX_IRR := p_from.AFTER_TAX_IRR;

      p_to.EXPECTED_DELIVERY_DATE := p_from.EXPECTED_DELIVERY_DATE;

      p_to.ACCEPTED_DATE := p_from.ACCEPTED_DATE;

      p_to.PREFUNDING_ELIGIBLE_YN := p_from.PREFUNDING_ELIGIBLE_YN;

      p_to.REVOLVING_CREDIT_YN := p_from.REVOLVING_CREDIT_YN;

--Bug# 2697681 schema changes  11.5.9
      p_to.CURRENCY_CONVERSION_TYPE  := p_from.CURRENCY_CONVERSION_TYPE;
      p_to.CURRENCY_CONVERSION_RATE  := p_from.CURRENCY_CONVERSION_RATE;
      p_to.CURRENCY_CONVERSION_DATE  := p_from.CURRENCY_CONVERSION_DATE;
      p_to.MULTI_GAAP_YN             := p_from.MULTI_GAAP_YN;
      p_to.RECOURSE_CODE             := p_from.RECOURSE_CODE;
      p_to.LESSOR_SERV_ORG_CODE      := p_from.LESSOR_SERV_ORG_CODE;
      p_to.ASSIGNABLE_YN             := p_from.ASSIGNABLE_YN;
      p_to.SECURITIZED_CODE          := p_from.SECURITIZED_CODE;
      p_to.SECURITIZATION_TYPE       := p_from.SECURITIZATION_TYPE;
--Bug#3143522 : 11.5.10
   --subsidy
   p_to.SUB_PRE_TAX_YIELD := p_from.SUB_PRE_TAX_YIELD;
   p_to.SUB_AFTER_TAX_YIELD := p_from.SUB_AFTER_TAX_YIELD;
   p_to.SUB_IMPL_INTEREST_RATE := p_from.SUB_IMPL_INTEREST_RATE;
   p_to.SUB_IMPL_NON_IDC_INT_RATE := p_from.SUB_IMPL_NON_IDC_INT_RATE;
   p_to.SUB_PRE_TAX_IRR := p_from.SUB_PRE_TAX_IRR;
   p_to.SUB_AFTER_TAX_IRR := p_from.SUB_AFTER_TAX_IRR;
   --Bug# 3973640 : 11.5.10+ schema changes
   p_to.TOT_CL_TRANSFER_AMT     := p_from.TOT_CL_TRANSFER_AMT;
   p_to.TOT_CL_NET_TRANSFER_AMT := p_from.TOT_CL_NET_TRANSFER_AMT;
   p_to.TOT_CL_LIMIT            := p_from.TOT_CL_LIMIT;
   p_to.TOT_CL_FUNDING_AMT      := p_from.TOT_CL_FUNDING_AMT;
   p_to.CRS_ID                  := p_from.CRS_ID;
   p_to.TEMPLATE_TYPE_CODE      := p_from.TEMPLATE_TYPE_CODE;
--Bug# 4419339 OKLH Schema Sales Quote
   p_to.DATE_FUNDING_EXPECTED     := p_from.DATE_FUNDING_EXPECTED;
   p_to.DATE_TRADEIN 		  := p_from.DATE_TRADEIN;
   p_to.TRADEIN_AMOUNT            := p_from.TRADEIN_AMOUNT;
   p_to.TRADEIN_DESCRIPTION       := p_from.TRADEIN_DESCRIPTION;
   --Added by dpsingh for LE uptake
   p_to.LEGAL_ENTITY_ID       := p_from.LEGAL_ENTITY_ID;


  END migrate;

  PROCEDURE migrate (
    p_from	IN khr_rec_type,
    p_to	IN OUT NOCOPY khrv_rec_type
  ) IS
  BEGIN

      p_to.ID := p_from.ID;

      p_to.ISG_ID := p_from.ISG_ID;

      p_to.KHR_ID := p_from.KHR_ID;

      p_to.PDT_ID := p_from.PDT_ID;

      p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;

      p_to.DATE_FIRST_ACTIVITY := p_from.DATE_FIRST_ACTIVITY;

      p_to.SYNDICATABLE_YN := p_from.SYNDICATABLE_YN;

      p_to.SALESTYPE_YN := p_from.SALESTYPE_YN;

      p_to.DATE_REFINANCED := p_from.DATE_REFINANCED;

      p_to.DATE_CONVERSION_EFFECTIVE := p_from.DATE_CONVERSION_EFFECTIVE;

      p_to.DATE_DEAL_TRANSFERRED := p_from.DATE_DEAL_TRANSFERRED;

      p_to.TERM_DURATION := p_from.TERM_DURATION;

      p_to.DATETIME_PROPOSAL_EFFECTIVE := p_from.DATETIME_PROPOSAL_EFFECTIVE;

      p_to.DATETIME_PROPOSAL_INEFFECTIVE := p_from.DATETIME_PROPOSAL_INEFFECTIVE;

      p_to.DATE_PROPOSAL_ACCEPTED := p_from.DATE_PROPOSAL_ACCEPTED;

      p_to.ATTRIBUTE_CATEGORY := p_from.ATTRIBUTE_CATEGORY;

      p_to.ATTRIBUTE1 := p_from.ATTRIBUTE1;

      p_to.ATTRIBUTE2 := p_from.ATTRIBUTE2;

      p_to.ATTRIBUTE3 := p_from.ATTRIBUTE3;

      p_to.ATTRIBUTE4 := p_from.ATTRIBUTE4;

      p_to.ATTRIBUTE5 := p_from.ATTRIBUTE5;

      p_to.ATTRIBUTE6 := p_from.ATTRIBUTE6;

      p_to.ATTRIBUTE7 := p_from.ATTRIBUTE7;

      p_to.ATTRIBUTE8 := p_from.ATTRIBUTE8;

      p_to.ATTRIBUTE9 := p_from.ATTRIBUTE9;

      p_to.ATTRIBUTE10 := p_from.ATTRIBUTE10;

      p_to.ATTRIBUTE11 := p_from.ATTRIBUTE11;

      p_to.ATTRIBUTE12 := p_from.ATTRIBUTE12;

      p_to.ATTRIBUTE13 := p_from.ATTRIBUTE13;

      p_to.ATTRIBUTE14 := p_from.ATTRIBUTE14;

      p_to.ATTRIBUTE15 := p_from.ATTRIBUTE15;

      p_to.CREATED_BY := p_from.CREATED_BY;

      p_to.CREATION_DATE := p_from.CREATION_DATE;

      p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;

      p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;

      p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;

      p_to.AMD_CODE := p_from.AMD_CODE;

      p_to.GENERATE_ACCRUAL_YN := p_from.GENERATE_ACCRUAL_YN;

      p_to.GENERATE_ACCRUAL_OVERRIDE_YN := p_from.GENERATE_ACCRUAL_OVERRIDE_YN;

      p_to.CREDIT_ACT_YN := p_from.CREDIT_ACT_YN;

      p_to.CONVERTED_ACCOUNT_YN := p_from.CONVERTED_ACCOUNT_YN;

      p_to.PRE_TAX_YIELD := p_from.PRE_TAX_YIELD;

      p_to.AFTER_TAX_YIELD := p_from.AFTER_TAX_YIELD;

      p_to.IMPLICIT_INTEREST_RATE := p_from.IMPLICIT_INTEREST_RATE;

      p_to.IMPLICIT_NON_IDC_INTEREST_RATE := p_from.IMPLICIT_NON_IDC_INTEREST_RATE;

      p_to.TARGET_PRE_TAX_YIELD := p_from.TARGET_PRE_TAX_YIELD;

      p_to.TARGET_AFTER_TAX_YIELD := p_from.TARGET_AFTER_TAX_YIELD;

      p_to.TARGET_IMPLICIT_INTEREST_RATE := p_from.TARGET_IMPLICIT_INTEREST_RATE;

      p_to.TARGET_IMPLICIT_NONIDC_INTRATE := p_from.TARGET_IMPLICIT_NONIDC_INTRATE;

      p_to.DATE_LAST_INTERIM_INTEREST_CAL := p_from.DATE_LAST_INTERIM_INTEREST_CAL;

      p_to.DEAL_TYPE := p_from.DEAL_TYPE;

      p_to.PRE_TAX_IRR := p_from.PRE_TAX_IRR;

      p_to.AFTER_TAX_IRR := p_from.AFTER_TAX_IRR;

      p_to.EXPECTED_DELIVERY_DATE := p_from.EXPECTED_DELIVERY_DATE;

      p_to.ACCEPTED_DATE := p_from.ACCEPTED_DATE;

      p_to.PREFUNDING_ELIGIBLE_YN := p_from.PREFUNDING_ELIGIBLE_YN;

      p_to.REVOLVING_CREDIT_YN := p_from.REVOLVING_CREDIT_YN;

--Bug# 2697681 schema changes  11.5.9
      p_to.CURRENCY_CONVERSION_TYPE  := p_from.CURRENCY_CONVERSION_TYPE;
      p_to.CURRENCY_CONVERSION_RATE  := p_from.CURRENCY_CONVERSION_RATE;
      p_to.CURRENCY_CONVERSION_DATE  := p_from.CURRENCY_CONVERSION_DATE;
      p_to.MULTI_GAAP_YN             := p_from.MULTI_GAAP_YN;
      p_to.RECOURSE_CODE             := p_from.RECOURSE_CODE;
      p_to.LESSOR_SERV_ORG_CODE      := p_from.LESSOR_SERV_ORG_CODE;
      p_to.ASSIGNABLE_YN             := p_from.ASSIGNABLE_YN;
      p_to.SECURITIZED_CODE          := p_from.SECURITIZED_CODE;
      p_to.SECURITIZATION_TYPE       := p_from.SECURITIZATION_TYPE;
--Bug# 3143522: 11.5.10
   --subsidy
   p_to.SUB_PRE_TAX_YIELD := p_from.SUB_PRE_TAX_YIELD;
   p_to.SUB_AFTER_TAX_YIELD := p_from.SUB_AFTER_TAX_YIELD;
   p_to.SUB_IMPL_INTEREST_RATE := p_from.SUB_IMPL_INTEREST_RATE;
   p_to.SUB_IMPL_NON_IDC_INT_RATE := p_from.SUB_IMPL_NON_IDC_INT_RATE;
   p_to.SUB_PRE_TAX_IRR := p_from.SUB_PRE_TAX_IRR;
   p_to.SUB_AFTER_TAX_IRR := p_from.SUB_AFTER_TAX_IRR;
  --Bug# 3973640 : 11.5.10+ schema changes
   p_to.TOT_CL_TRANSFER_AMT     := p_from.TOT_CL_TRANSFER_AMT;
   p_to.TOT_CL_NET_TRANSFER_AMT := p_from.TOT_CL_NET_TRANSFER_AMT;
   p_to.TOT_CL_LIMIT            := p_from.TOT_CL_LIMIT;
   p_to.TOT_CL_FUNDING_AMT      := p_from.TOT_CL_FUNDING_AMT;
   p_to.CRS_ID                  := p_from.CRS_ID;
   p_to.TEMPLATE_TYPE_CODE      := p_from.TEMPLATE_TYPE_CODE;
--Bug# 4419339 OKLH Schema Sales Quote
   p_to.DATE_FUNDING_EXPECTED     := p_from.DATE_FUNDING_EXPECTED;
   p_to.DATE_TRADEIN 		  := p_from.DATE_TRADEIN;
   p_to.TRADEIN_AMOUNT            := p_from.TRADEIN_AMOUNT;
   p_to.TRADEIN_DESCRIPTION       := p_from.TRADEIN_DESCRIPTION;
   --Added by dpsingh for LE uptake
   p_to.LEGAL_ENTITY_ID       := p_from.LEGAL_ENTITY_ID;
  END migrate;

  PROCEDURE migrate (
    p_from	IN khr_rec_type,
    p_to	IN OUT NOCOPY okl_k_headers_h_rec_type
  ) IS
  BEGIN

      p_to.ID := p_from.ID;

      p_to.ISG_ID := p_from.ISG_ID;

      p_to.KHR_ID := p_from.KHR_ID;

      p_to.PDT_ID := p_from.PDT_ID;

      p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;

      p_to.DATE_FIRST_ACTIVITY := p_from.DATE_FIRST_ACTIVITY;

      p_to.SYNDICATABLE_YN := p_from.SYNDICATABLE_YN;

      p_to.SALESTYPE_YN := p_from.SALESTYPE_YN;

      p_to.DATE_REFINANCED := p_from.DATE_REFINANCED;

      p_to.DATE_CONVERSION_EFFECTIVE := p_from.DATE_CONVERSION_EFFECTIVE;

      p_to.DATE_DEAL_TRANSFERRED := p_from.DATE_DEAL_TRANSFERRED;

      p_to.TERM_DURATION := p_from.TERM_DURATION;

      p_to.DATETIME_PROPOSAL_EFFECTIVE := p_from.DATETIME_PROPOSAL_EFFECTIVE;

      p_to.DATETIME_PROPOSAL_INEFFECTIVE := p_from.DATETIME_PROPOSAL_INEFFECTIVE;

      p_to.DATE_PROPOSAL_ACCEPTED := p_from.DATE_PROPOSAL_ACCEPTED;

      p_to.ATTRIBUTE_CATEGORY := p_from.ATTRIBUTE_CATEGORY;

      p_to.ATTRIBUTE1 := p_from.ATTRIBUTE1;

      p_to.ATTRIBUTE2 := p_from.ATTRIBUTE2;

      p_to.ATTRIBUTE3 := p_from.ATTRIBUTE3;

      p_to.ATTRIBUTE4 := p_from.ATTRIBUTE4;

      p_to.ATTRIBUTE5 := p_from.ATTRIBUTE5;

      p_to.ATTRIBUTE6 := p_from.ATTRIBUTE6;

      p_to.ATTRIBUTE7 := p_from.ATTRIBUTE7;

      p_to.ATTRIBUTE8 := p_from.ATTRIBUTE8;

      p_to.ATTRIBUTE9 := p_from.ATTRIBUTE9;

      p_to.ATTRIBUTE10 := p_from.ATTRIBUTE10;

      p_to.ATTRIBUTE11 := p_from.ATTRIBUTE11;

      p_to.ATTRIBUTE12 := p_from.ATTRIBUTE12;

      p_to.ATTRIBUTE13 := p_from.ATTRIBUTE13;

      p_to.ATTRIBUTE14 := p_from.ATTRIBUTE14;

      p_to.ATTRIBUTE15 := p_from.ATTRIBUTE15;

      p_to.CREATED_BY := p_from.CREATED_BY;

      p_to.CREATION_DATE := p_from.CREATION_DATE;

      p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;

      p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;

      p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;

      p_to.AMD_CODE := p_from.AMD_CODE;

      p_to.GENERATE_ACCRUAL_YN := p_from.GENERATE_ACCRUAL_YN;

      p_to.GENERATE_ACCRUAL_OVERRIDE_YN := p_from.GENERATE_ACCRUAL_OVERRIDE_YN;

      p_to.CREDIT_ACT_YN := p_from.CREDIT_ACT_YN;

      p_to.CONVERTED_ACCOUNT_YN := p_from.CONVERTED_ACCOUNT_YN;

      p_to.PRE_TAX_YIELD := p_from.PRE_TAX_YIELD;

      p_to.AFTER_TAX_YIELD := p_from.AFTER_TAX_YIELD;

      p_to.IMPLICIT_INTEREST_RATE := p_from.IMPLICIT_INTEREST_RATE;

      p_to.IMPLICIT_NON_IDC_INTEREST_RATE := p_from.IMPLICIT_NON_IDC_INTEREST_RATE;

      p_to.TARGET_PRE_TAX_YIELD := p_from.TARGET_PRE_TAX_YIELD;

      p_to.TARGET_AFTER_TAX_YIELD := p_from.TARGET_AFTER_TAX_YIELD;

      p_to.TARGET_IMPLICIT_INTEREST_RATE := p_from.TARGET_IMPLICIT_INTEREST_RATE;

      p_to.TARGET_IMPLICIT_NONIDC_INTRATE := p_from.TARGET_IMPLICIT_NONIDC_INTRATE;

      p_to.DATE_LAST_INTERIM_INTEREST_CAL := p_from.DATE_LAST_INTERIM_INTEREST_CAL;

      p_to.DEAL_TYPE := p_from.DEAL_TYPE;

      p_to.PRE_TAX_IRR := p_from.PRE_TAX_IRR;

      p_to.AFTER_TAX_IRR := p_from.AFTER_TAX_IRR;

      p_to.EXPECTED_DELIVERY_DATE := p_from.EXPECTED_DELIVERY_DATE;

      p_to.ACCEPTED_DATE := p_from.ACCEPTED_DATE;

      p_to.PREFUNDING_ELIGIBLE_YN := p_from.PREFUNDING_ELIGIBLE_YN;

      p_to.REVOLVING_CREDIT_YN := p_from.REVOLVING_CREDIT_YN;

--Bug# 2697681 schema changes  11.5.9
      p_to.CURRENCY_CONVERSION_TYPE  := p_from.CURRENCY_CONVERSION_TYPE;
      p_to.CURRENCY_CONVERSION_RATE  := p_from.CURRENCY_CONVERSION_RATE;
      p_to.CURRENCY_CONVERSION_DATE  := p_from.CURRENCY_CONVERSION_DATE;
      p_to.MULTI_GAAP_YN             := p_from.MULTI_GAAP_YN;
      p_to.RECOURSE_CODE             := p_from.RECOURSE_CODE;
      p_to.LESSOR_SERV_ORG_CODE      := p_from.LESSOR_SERV_ORG_CODE;
      p_to.ASSIGNABLE_YN             := p_from.ASSIGNABLE_YN;
      p_to.SECURITIZED_CODE          := p_from.SECURITIZED_CODE;
      p_to.SECURITIZATION_TYPE       := p_from.SECURITIZATION_TYPE;
--Bug#3143522 : 11.5.10
   --subsidy
   p_to.SUB_PRE_TAX_YIELD := p_from.SUB_PRE_TAX_YIELD;
   p_to.SUB_AFTER_TAX_YIELD := p_from.SUB_AFTER_TAX_YIELD;
   p_to.SUB_IMPL_INTEREST_RATE := p_from.SUB_IMPL_INTEREST_RATE;
   p_to.SUB_IMPL_NON_IDC_INT_RATE := p_from.SUB_IMPL_NON_IDC_INT_RATE;
   p_to.SUB_PRE_TAX_IRR := p_from.SUB_PRE_TAX_IRR;
   p_to.SUB_AFTER_TAX_IRR := p_from.SUB_AFTER_TAX_IRR;
  --Bug# 3973640 : 11.5.10+ schema changes
   p_to.TOT_CL_TRANSFER_AMT     := p_from.TOT_CL_TRANSFER_AMT;
   p_to.TOT_CL_NET_TRANSFER_AMT := p_from.TOT_CL_NET_TRANSFER_AMT;
   p_to.TOT_CL_LIMIT            := p_from.TOT_CL_LIMIT;
   p_to.TOT_CL_FUNDING_AMT      := p_from.TOT_CL_FUNDING_AMT;
   p_to.CRS_ID                  := p_from.CRS_ID;
   p_to.TEMPLATE_TYPE_CODE      := p_from.TEMPLATE_TYPE_CODE;
--Bug# 4419339 OKLH Schema Sales Quote
   p_to.DATE_FUNDING_EXPECTED     := p_from.DATE_FUNDING_EXPECTED;
   p_to.DATE_TRADEIN 		  := p_from.DATE_TRADEIN;
   p_to.TRADEIN_AMOUNT            := p_from.TRADEIN_AMOUNT;
   p_to.TRADEIN_DESCRIPTION       := p_from.TRADEIN_DESCRIPTION;
   --Added by dpsingh for LE uptake
   p_to.LEGAL_ENTITY_ID       := p_from.LEGAL_ENTITY_ID;
  END migrate;



  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------

  --------------------------------------
  -- validate_row for: OKL_K_HEADERS_V --
  --------------------------------------

  PROCEDURE validate_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_rec                     IN khrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec                     khrv_rec_type := p_khrv_rec;
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
    l_return_status := Validate_Attributes(l_khrv_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_return_status := Validate_Record(l_khrv_rec);

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
  -- PL/SQL TBL validate_row for: OKL_K_HEADERS_V --
  ------------------------------------------

  PROCEDURE validate_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_tbl                     IN khrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_khrv_tbl.COUNT > 0) THEN
      i := p_khrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_khrv_rec                     => p_khrv_tbl(i));
        EXIT WHEN (i = p_khrv_tbl.LAST);
        i := p_khrv_tbl.NEXT(i);
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


  ------------------------------------
  -- insert_row for: OKL_K_HEADERS_H --
  ------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_k_headers_h_rec                     IN okl_k_headers_h_rec_type,
    x_okl_k_headers_h_rec                     OUT NOCOPY okl_k_headers_h_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_k_headers_h_rec          okl_k_headers_h_rec_type := p_okl_k_headers_h_rec;
    l_def_okl_k_headers_h_rec      okl_k_headers_h_rec_type;
    ----------------------------------------
    -- Set_Attributes for: OKL_K_HEADERS_H --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_k_headers_h_rec IN  okl_k_headers_h_rec_type,
      x_okl_k_headers_h_rec OUT NOCOPY okl_k_headers_h_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_k_headers_h_rec := p_okl_k_headers_h_rec;
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
      p_okl_k_headers_h_rec,             -- IN
      l_okl_k_headers_h_rec);            -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_K_HEADERS_H(
	ID,
        MAJOR_VERSION,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+ schema
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
    --Added by dpsingh for LE uptake
    LEGAL_ENTITY_ID
        )
      VALUES (
       l_okl_k_headers_h_rec.ID,
        l_okl_k_headers_h_rec.MAJOR_VERSION,
        l_okl_k_headers_h_rec.ISG_ID,
        l_okl_k_headers_h_rec.KHR_ID,
        l_okl_k_headers_h_rec.PDT_ID,
        l_okl_k_headers_h_rec.OBJECT_VERSION_NUMBER,
        l_okl_k_headers_h_rec.DATE_FIRST_ACTIVITY,
        l_okl_k_headers_h_rec.SYNDICATABLE_YN,
        l_okl_k_headers_h_rec.SALESTYPE_YN,
        l_okl_k_headers_h_rec.DATE_REFINANCED,
        l_okl_k_headers_h_rec.DATE_CONVERSION_EFFECTIVE,
        l_okl_k_headers_h_rec.DATE_DEAL_TRANSFERRED,
        l_okl_k_headers_h_rec.TERM_DURATION,
        l_okl_k_headers_h_rec.DATETIME_PROPOSAL_EFFECTIVE,
        l_okl_k_headers_h_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        l_okl_k_headers_h_rec.DATE_PROPOSAL_ACCEPTED,
        l_okl_k_headers_h_rec.ATTRIBUTE_CATEGORY,
        l_okl_k_headers_h_rec.ATTRIBUTE1,
        l_okl_k_headers_h_rec.ATTRIBUTE2,
        l_okl_k_headers_h_rec.ATTRIBUTE3,
        l_okl_k_headers_h_rec.ATTRIBUTE4,
        l_okl_k_headers_h_rec.ATTRIBUTE5,
        l_okl_k_headers_h_rec.ATTRIBUTE6,
        l_okl_k_headers_h_rec.ATTRIBUTE7,
        l_okl_k_headers_h_rec.ATTRIBUTE8,
        l_okl_k_headers_h_rec.ATTRIBUTE9,
        l_okl_k_headers_h_rec.ATTRIBUTE10,
        l_okl_k_headers_h_rec.ATTRIBUTE11,
        l_okl_k_headers_h_rec.ATTRIBUTE12,
        l_okl_k_headers_h_rec.ATTRIBUTE13,
        l_okl_k_headers_h_rec.ATTRIBUTE14,
        l_okl_k_headers_h_rec.ATTRIBUTE15,
        l_okl_k_headers_h_rec.CREATED_BY,
        l_okl_k_headers_h_rec.CREATION_DATE,
        l_okl_k_headers_h_rec.LAST_UPDATED_BY,
        l_okl_k_headers_h_rec.LAST_UPDATE_DATE,
        l_okl_k_headers_h_rec.LAST_UPDATE_LOGIN,
        l_okl_k_headers_h_rec.AMD_CODE,
        l_okl_k_headers_h_rec.GENERATE_ACCRUAL_YN,
        l_okl_k_headers_h_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        l_okl_k_headers_h_rec.CREDIT_ACT_YN,
        l_okl_k_headers_h_rec.CONVERTED_ACCOUNT_YN,
        l_okl_k_headers_h_rec.PRE_TAX_YIELD,
        l_okl_k_headers_h_rec.AFTER_TAX_YIELD,
        l_okl_k_headers_h_rec.IMPLICIT_INTEREST_RATE,
        l_okl_k_headers_h_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        l_okl_k_headers_h_rec.TARGET_PRE_TAX_YIELD,
        l_okl_k_headers_h_rec.TARGET_AFTER_TAX_YIELD,
        l_okl_k_headers_h_rec.TARGET_IMPLICIT_INTEREST_RATE,
        l_okl_k_headers_h_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        l_okl_k_headers_h_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        l_okl_k_headers_h_rec.DEAL_TYPE,
        l_okl_k_headers_h_rec.PRE_TAX_IRR,
        l_okl_k_headers_h_rec.AFTER_TAX_IRR,
        l_okl_k_headers_h_rec.EXPECTED_DELIVERY_DATE,
        l_okl_k_headers_h_rec.ACCEPTED_DATE,
        l_okl_k_headers_h_rec.PREFUNDING_ELIGIBLE_YN,
        l_okl_k_headers_h_rec.REVOLVING_CREDIT_YN,
        --Bug# 2697681 schema changes  11.5.9
        l_okl_k_headers_h_rec.CURRENCY_CONVERSION_TYPE,
        l_okl_k_headers_h_rec.CURRENCY_CONVERSION_RATE,
        l_okl_k_headers_h_rec.CURRENCY_CONVERSION_DATE,
        l_okl_k_headers_h_rec.MULTI_GAAP_YN,
        l_okl_k_headers_h_rec.RECOURSE_CODE,
        l_okl_k_headers_h_rec.LESSOR_SERV_ORG_CODE,
        l_okl_k_headers_h_rec.ASSIGNABLE_YN,
        l_okl_k_headers_h_rec.SECURITIZED_CODE,
        l_okl_k_headers_h_rec.SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   l_okl_k_headers_h_rec.SUB_PRE_TAX_YIELD,
   l_okl_k_headers_h_rec.SUB_AFTER_TAX_YIELD,
   l_okl_k_headers_h_rec.SUB_IMPL_INTEREST_RATE,
   l_okl_k_headers_h_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_okl_k_headers_h_rec.SUB_PRE_TAX_IRR,
   l_okl_k_headers_h_rec.SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+ schema
   l_okl_k_headers_h_rec.TOT_CL_TRANSFER_AMT,
   l_okl_k_headers_h_rec.TOT_CL_NET_TRANSFER_AMT,
   l_okl_k_headers_h_rec.TOT_CL_LIMIT,
   l_okl_k_headers_h_rec.TOT_CL_FUNDING_AMT,
   l_okl_k_headers_h_rec.CRS_ID,
   l_okl_k_headers_h_rec.TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   l_okl_k_headers_h_rec.DATE_FUNDING_EXPECTED,
   l_okl_k_headers_h_rec.DATE_TRADEIN,
   l_okl_k_headers_h_rec.TRADEIN_AMOUNT,
   l_okl_k_headers_h_rec.TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   l_okl_k_headers_h_rec.LEGAL_ENTITY_ID);
    -- Set OUT values
    x_okl_k_headers_h_rec := l_okl_k_headers_h_rec;
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
  -- insert_row for: OKL_K_HEADERS --
  ------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_rec                     IN khr_rec_type,
    x_khr_rec                     OUT NOCOPY khr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec          khr_rec_type := p_khr_rec;
    l_def_khr_rec      khr_rec_type;
    ----------------------------------------
    -- Set_Attributes for: OKL_K_HEADERS --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_khr_rec IN  khr_rec_type,
      x_khr_rec OUT NOCOPY khr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_khr_rec := p_khr_rec;
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
      p_khr_rec,             -- IN
      l_khr_rec);            -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_K_HEADERS(
	ID,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
  --Bug# 3973640 : 11.5.10+ schema
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
  -- Schema Change for Vendor Enhancements
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID
        )
      VALUES (
       l_khr_rec.ID,
        l_khr_rec.ISG_ID,
        l_khr_rec.KHR_ID,
        l_khr_rec.PDT_ID,
        l_khr_rec.OBJECT_VERSION_NUMBER,
        l_khr_rec.DATE_FIRST_ACTIVITY,
        l_khr_rec.SYNDICATABLE_YN,
        l_khr_rec.SALESTYPE_YN,
        l_khr_rec.DATE_REFINANCED,
        l_khr_rec.DATE_CONVERSION_EFFECTIVE,
        l_khr_rec.DATE_DEAL_TRANSFERRED,
        l_khr_rec.TERM_DURATION,
        l_khr_rec.DATETIME_PROPOSAL_EFFECTIVE,
        l_khr_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        l_khr_rec.DATE_PROPOSAL_ACCEPTED,
        l_khr_rec.ATTRIBUTE_CATEGORY,
        l_khr_rec.ATTRIBUTE1,
        l_khr_rec.ATTRIBUTE2,
        l_khr_rec.ATTRIBUTE3,
        l_khr_rec.ATTRIBUTE4,
        l_khr_rec.ATTRIBUTE5,
        l_khr_rec.ATTRIBUTE6,
        l_khr_rec.ATTRIBUTE7,
        l_khr_rec.ATTRIBUTE8,
        l_khr_rec.ATTRIBUTE9,
        l_khr_rec.ATTRIBUTE10,
        l_khr_rec.ATTRIBUTE11,
        l_khr_rec.ATTRIBUTE12,
        l_khr_rec.ATTRIBUTE13,
        l_khr_rec.ATTRIBUTE14,
        l_khr_rec.ATTRIBUTE15,
        l_khr_rec.CREATED_BY,
        l_khr_rec.CREATION_DATE,
        l_khr_rec.LAST_UPDATED_BY,
        l_khr_rec.LAST_UPDATE_DATE,
        l_khr_rec.LAST_UPDATE_LOGIN,
        l_khr_rec.AMD_CODE,
        l_khr_rec.GENERATE_ACCRUAL_YN,
        l_khr_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        l_khr_rec.CREDIT_ACT_YN,
        l_khr_rec.CONVERTED_ACCOUNT_YN,
        l_khr_rec.PRE_TAX_YIELD,
        l_khr_rec.AFTER_TAX_YIELD,
        l_khr_rec.IMPLICIT_INTEREST_RATE,
        l_khr_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        l_khr_rec.TARGET_PRE_TAX_YIELD,
        l_khr_rec.TARGET_AFTER_TAX_YIELD,
        l_khr_rec.TARGET_IMPLICIT_INTEREST_RATE,
        l_khr_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        l_khr_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        l_khr_rec.DEAL_TYPE,
        l_khr_rec.PRE_TAX_IRR,
        l_khr_rec.AFTER_TAX_IRR,
        l_khr_rec.EXPECTED_DELIVERY_DATE,
        l_khr_rec.ACCEPTED_DATE,
        l_khr_rec.PREFUNDING_ELIGIBLE_YN,
        l_khr_rec.REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        l_khr_rec.CURRENCY_CONVERSION_TYPE,
        l_khr_rec.CURRENCY_CONVERSION_RATE,
        l_khr_rec.CURRENCY_CONVERSION_DATE,
        l_khr_rec.MULTI_GAAP_YN,
        l_khr_rec.RECOURSE_CODE,
        l_khr_rec.LESSOR_SERV_ORG_CODE,
        l_khr_rec.ASSIGNABLE_YN,
        l_khr_rec.SECURITIZED_CODE,
        l_khr_rec.SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   l_khr_rec.SUB_PRE_TAX_YIELD,
   l_khr_rec.SUB_AFTER_TAX_YIELD,
   l_khr_rec.SUB_IMPL_INTEREST_RATE,
   l_khr_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_khr_rec.SUB_PRE_TAX_IRR,
   l_khr_rec.SUB_AFTER_TAX_IRR,
  --Bug# 3973640 : 11.5.10+ schema
   l_khr_rec.TOT_CL_TRANSFER_AMT,
   l_khr_rec.TOT_CL_NET_TRANSFER_AMT,
   l_khr_rec.TOT_CL_LIMIT,
   l_khr_rec.TOT_CL_FUNDING_AMT,
  -- Schema Change for Vendor Enhancements
   l_khr_rec.CRS_ID,
   l_khr_rec.TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   l_khr_rec.DATE_FUNDING_EXPECTED,
   l_khr_rec.DATE_TRADEIN,
   l_khr_rec.TRADEIN_AMOUNT,
   l_khr_rec.TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   l_khr_rec.LEGAL_ENTITY_ID);
    -- Set OUT values
    x_khr_rec := l_khr_rec;
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
  -- insert_row for: OKL_K_HEADERS_V --
  ------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_rec                     IN khrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec                     khrv_rec_type;
    l_def_khrv_rec                 khrv_rec_type;
    l_khr_rec                      khr_rec_type;
    lx_khr_rec                     khr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_khrv_rec	IN khrv_rec_type
    ) RETURN khrv_rec_type IS
      l_khrv_rec	khrv_rec_type := p_khrv_rec;
    BEGIN
      l_khrv_rec.CREATION_DATE := SYSDATE;
      l_khrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_khrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_khrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_khrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_khrv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for: OKL_K_HEADERS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_khrv_rec IN  khrv_rec_type,
      x_khrv_rec OUT NOCOPY khrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_khrv_rec := p_khrv_rec;
      x_khrv_rec.OBJECT_VERSION_NUMBER := 1;
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

    l_khrv_rec := null_out_defaults(p_khrv_rec);

    -- Set primary key value
    -- modified by Miroslav Samoilenko
    if ( l_khrv_rec.ID is null) then
      l_khrv_rec.ID := get_seq_id;
    end if;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_khrv_rec,                        -- IN
      l_def_khrv_rec);                   -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_khrv_rec := fill_who_columns(l_def_khrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_khrv_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_khrv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_khrv_rec, l_khr_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_khr_rec,
      lx_khr_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_khr_rec, l_def_khrv_rec);
    -- Set OUT values
    x_khrv_rec := l_def_khrv_rec;
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
  -- PL/SQL TBL insert_row for: OKL_K_HEADERS_V --
  ----------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_tbl                     IN khrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_khrv_tbl.COUNT > 0) THEN
      i := p_khrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_khrv_rec                     => p_khrv_tbl(i),
          x_khrv_rec                     => x_khrv_tbl(i));
        EXIT WHEN (i = p_khrv_tbl.LAST);
        i := p_khrv_tbl.NEXT(i);
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

  --------------------------------
  -- lock_row for: OKL_K_HEADERS --
  --------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_rec                     IN khr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_khr_rec IN khr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_K_HEADERS
     WHERE ID = p_khr_rec.id
       AND OBJECT_VERSION_NUMBER = p_khr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_khr_rec IN khr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_K_HEADERS
    WHERE ID = p_khr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_K_HEADERS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_K_HEADERS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_khr_rec);
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
      OPEN lchk_csr(p_khr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_khr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_khr_rec.object_version_number THEN
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
  -- lock_row for: OKL_K_HEADERS_V --
  ----------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_rec                     IN khrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec                      khr_rec_type;
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
    migrate(p_khrv_rec, l_khr_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_khr_rec
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
  -- PL/SQL TBL lock_row for: OKL_K_HEADERS_V --
  --------------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_tbl                     IN khrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_khrv_tbl.COUNT > 0) THEN
      i := p_khrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_khrv_rec                     => p_khrv_tbl(i));
        EXIT WHEN (i = p_khrv_tbl.LAST);
        i := p_khrv_tbl.NEXT(i);
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

  ----------------------------------
  -- update_row for: OKL_K_HEADERS --
  ----------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_rec                     IN khr_rec_type,
    x_khr_rec                     OUT NOCOPY khr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec                      khr_rec_type := p_khr_rec;
    l_def_khr_rec                  khr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_okl_k_headers_h_rec okl_k_headers_h_rec_type;
    lx_okl_k_headers_h_rec okl_k_headers_h_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_khr_rec	IN khr_rec_type,
      x_khr_rec	OUT NOCOPY khr_rec_type
    ) RETURN VARCHAR2 IS
      l_khr_rec                      khr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_khr_rec := p_khr_rec;
      -- Get current database values
      l_khr_rec := get_rec(p_khr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database
      migrate(l_khr_rec, l_okl_k_headers_h_rec);

      IF (x_khr_rec.ID = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.ID := l_khr_rec.ID;
      END IF;

      IF (x_khr_rec.ISG_ID = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.ISG_ID := l_khr_rec.ISG_ID;
      END IF;

      IF (x_khr_rec.KHR_ID = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.KHR_ID := l_khr_rec.KHR_ID;
      END IF;

      IF (x_khr_rec.PDT_ID = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.PDT_ID := l_khr_rec.PDT_ID;
      END IF;

      IF (x_khr_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.OBJECT_VERSION_NUMBER := l_khr_rec.OBJECT_VERSION_NUMBER;
      END IF;

      IF (x_khr_rec.DATE_FIRST_ACTIVITY = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_FIRST_ACTIVITY := l_khr_rec.DATE_FIRST_ACTIVITY;
      END IF;

      IF (x_khr_rec.SYNDICATABLE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.SYNDICATABLE_YN := l_khr_rec.SYNDICATABLE_YN;
      END IF;

      IF (x_khr_rec.SALESTYPE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.SALESTYPE_YN := l_khr_rec.SALESTYPE_YN;
      END IF;

      IF (x_khr_rec.DATE_REFINANCED = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_REFINANCED := l_khr_rec.DATE_REFINANCED;
      END IF;

      IF (x_khr_rec.DATE_CONVERSION_EFFECTIVE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_CONVERSION_EFFECTIVE := l_khr_rec.DATE_CONVERSION_EFFECTIVE;
      END IF;

      IF (x_khr_rec.DATE_DEAL_TRANSFERRED = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_DEAL_TRANSFERRED := l_khr_rec.DATE_DEAL_TRANSFERRED;
      END IF;

      IF (x_khr_rec.TERM_DURATION = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TERM_DURATION := l_khr_rec.TERM_DURATION;
      END IF;

      IF (x_khr_rec.DATETIME_PROPOSAL_EFFECTIVE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATETIME_PROPOSAL_EFFECTIVE := l_khr_rec.DATETIME_PROPOSAL_EFFECTIVE;
      END IF;

      IF (x_khr_rec.DATETIME_PROPOSAL_INEFFECTIVE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATETIME_PROPOSAL_INEFFECTIVE := l_khr_rec.DATETIME_PROPOSAL_INEFFECTIVE;
      END IF;

      IF (x_khr_rec.DATE_PROPOSAL_ACCEPTED = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_PROPOSAL_ACCEPTED := l_khr_rec.DATE_PROPOSAL_ACCEPTED;
      END IF;

      IF (x_khr_rec.ATTRIBUTE_CATEGORY = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE_CATEGORY := l_khr_rec.ATTRIBUTE_CATEGORY;
      END IF;

      IF (x_khr_rec.ATTRIBUTE1 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE1 := l_khr_rec.ATTRIBUTE1;
      END IF;

      IF (x_khr_rec.ATTRIBUTE2 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE2 := l_khr_rec.ATTRIBUTE2;
      END IF;

      IF (x_khr_rec.ATTRIBUTE3 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE3 := l_khr_rec.ATTRIBUTE3;
      END IF;

      IF (x_khr_rec.ATTRIBUTE4 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE4 := l_khr_rec.ATTRIBUTE4;
      END IF;

      IF (x_khr_rec.ATTRIBUTE5 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE5 := l_khr_rec.ATTRIBUTE5;
      END IF;

      IF (x_khr_rec.ATTRIBUTE6 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE6 := l_khr_rec.ATTRIBUTE6;
      END IF;

      IF (x_khr_rec.ATTRIBUTE7 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE7 := l_khr_rec.ATTRIBUTE7;
      END IF;

      IF (x_khr_rec.ATTRIBUTE8 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE8 := l_khr_rec.ATTRIBUTE8;
      END IF;

      IF (x_khr_rec.ATTRIBUTE9 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE9 := l_khr_rec.ATTRIBUTE9;
      END IF;

      IF (x_khr_rec.ATTRIBUTE10 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE10 := l_khr_rec.ATTRIBUTE10;
      END IF;

      IF (x_khr_rec.ATTRIBUTE11 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE11 := l_khr_rec.ATTRIBUTE11;
      END IF;

      IF (x_khr_rec.ATTRIBUTE12 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE12 := l_khr_rec.ATTRIBUTE12;
      END IF;

      IF (x_khr_rec.ATTRIBUTE13 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE13 := l_khr_rec.ATTRIBUTE13;
      END IF;

      IF (x_khr_rec.ATTRIBUTE14 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE14 := l_khr_rec.ATTRIBUTE14;
      END IF;

      IF (x_khr_rec.ATTRIBUTE15 = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ATTRIBUTE15 := l_khr_rec.ATTRIBUTE15;
      END IF;

      IF (x_khr_rec.CREATED_BY = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.CREATED_BY := l_khr_rec.CREATED_BY;
      END IF;

      IF (x_khr_rec.CREATION_DATE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.CREATION_DATE := l_khr_rec.CREATION_DATE;
      END IF;

      IF (x_khr_rec.LAST_UPDATED_BY = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.LAST_UPDATED_BY := l_khr_rec.LAST_UPDATED_BY;
      END IF;

      IF (x_khr_rec.LAST_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.LAST_UPDATE_DATE := l_khr_rec.LAST_UPDATE_DATE;
      END IF;

      IF (x_khr_rec.LAST_UPDATE_LOGIN = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.LAST_UPDATE_LOGIN := l_khr_rec.LAST_UPDATE_LOGIN;
      END IF;

      IF (x_khr_rec.AMD_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.AMD_CODE := l_khr_rec.AMD_CODE;
      END IF;

      IF (x_khr_rec.GENERATE_ACCRUAL_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.GENERATE_ACCRUAL_YN := l_khr_rec.GENERATE_ACCRUAL_YN;
      END IF;

      IF (x_khr_rec.GENERATE_ACCRUAL_OVERRIDE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.GENERATE_ACCRUAL_OVERRIDE_YN := l_khr_rec.GENERATE_ACCRUAL_OVERRIDE_YN;
      END IF;

      IF (x_khr_rec.CREDIT_ACT_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.CREDIT_ACT_YN := l_khr_rec.CREDIT_ACT_YN;
      END IF;

      IF (x_khr_rec.CONVERTED_ACCOUNT_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.CONVERTED_ACCOUNT_YN := l_khr_rec.CONVERTED_ACCOUNT_YN;
      END IF;

      IF (x_khr_rec.PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.PRE_TAX_YIELD := l_khr_rec.PRE_TAX_YIELD;
      END IF;

      IF (x_khr_rec.AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.AFTER_TAX_YIELD := l_khr_rec.AFTER_TAX_YIELD;
      END IF;

      IF (x_khr_rec.IMPLICIT_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.IMPLICIT_INTEREST_RATE := l_khr_rec.IMPLICIT_INTEREST_RATE;
      END IF;

      IF (x_khr_rec.IMPLICIT_NON_IDC_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.IMPLICIT_NON_IDC_INTEREST_RATE := l_khr_rec.IMPLICIT_NON_IDC_INTEREST_RATE;
      END IF;

      IF (x_khr_rec.TARGET_PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TARGET_PRE_TAX_YIELD := l_khr_rec.TARGET_PRE_TAX_YIELD;
      END IF;

      IF (x_khr_rec.TARGET_AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TARGET_AFTER_TAX_YIELD := l_khr_rec.TARGET_AFTER_TAX_YIELD;
      END IF;

      IF (x_khr_rec.TARGET_IMPLICIT_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TARGET_IMPLICIT_INTEREST_RATE := l_khr_rec.TARGET_IMPLICIT_INTEREST_RATE;
      END IF;

      IF (x_khr_rec.TARGET_IMPLICIT_NONIDC_INTRATE = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TARGET_IMPLICIT_NONIDC_INTRATE := l_khr_rec.TARGET_IMPLICIT_NONIDC_INTRATE;
      END IF;

      IF (x_khr_rec.DATE_LAST_INTERIM_INTEREST_CAL = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_LAST_INTERIM_INTEREST_CAL := l_khr_rec.DATE_LAST_INTERIM_INTEREST_CAL;
      END IF;

      IF (x_khr_rec.DEAL_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.DEAL_TYPE := l_khr_rec.DEAL_TYPE;
      END IF;

      IF (x_khr_rec.PRE_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.PRE_TAX_IRR := l_khr_rec.PRE_TAX_IRR;
      END IF;

      IF (x_khr_rec.AFTER_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.AFTER_TAX_IRR := l_khr_rec.AFTER_TAX_IRR;
      END IF;

      IF (x_khr_rec.EXPECTED_DELIVERY_DATE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.EXPECTED_DELIVERY_DATE := l_khr_rec.EXPECTED_DELIVERY_DATE;
      END IF;

      IF (x_khr_rec.ACCEPTED_DATE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.ACCEPTED_DATE := l_khr_rec.ACCEPTED_DATE;
      END IF;

      IF (x_khr_rec.PREFUNDING_ELIGIBLE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.PREFUNDING_ELIGIBLE_YN := l_khr_rec.PREFUNDING_ELIGIBLE_YN;
      END IF;

      IF (x_khr_rec.REVOLVING_CREDIT_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.REVOLVING_CREDIT_YN := l_khr_rec.REVOLVING_CREDIT_YN;
      END IF;
--Bug# 2697681 schema changes  11.5.9
      IF (x_khr_rec.CURRENCY_CONVERSION_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.CURRENCY_CONVERSION_TYPE := l_khr_rec.CURRENCY_CONVERSION_TYPE;
      END IF;

      IF (x_khr_rec.CURRENCY_CONVERSION_RATE = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.CURRENCY_CONVERSION_RATE := l_khr_rec.CURRENCY_CONVERSION_RATE;
      END IF;

      IF (x_khr_rec.CURRENCY_CONVERSION_DATE = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.CURRENCY_CONVERSION_DATE := l_khr_rec.CURRENCY_CONVERSION_DATE;
      END IF;

      IF (x_khr_rec.MULTI_GAAP_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.MULTI_GAAP_YN := l_khr_rec.MULTI_GAAP_YN;
      END IF;

      IF (x_khr_rec.RECOURSE_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.RECOURSE_CODE := l_khr_rec.RECOURSE_CODE;
      END IF;

      IF (x_khr_rec.LESSOR_SERV_ORG_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.LESSOR_SERV_ORG_CODE := l_khr_rec.LESSOR_SERV_ORG_CODE;
      END IF;

      IF (x_khr_rec.ASSIGNABLE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.ASSIGNABLE_YN := l_khr_rec.ASSIGNABLE_YN;
      END IF;

      IF (x_khr_rec.SECURITIZED_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.SECURITIZED_CODE := l_khr_rec.SECURITIZED_CODE;
      END IF;

      IF (x_khr_rec.SECURITIZATION_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.SECURITIZATION_TYPE := l_khr_rec.SECURITIZATION_TYPE;
      END IF;
--Bug# 3143522: 11.5.10
    --subsidy
    IF (x_khr_rec.SUB_PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.SUB_PRE_TAX_YIELD := l_khr_rec.SUB_PRE_TAX_YIELD;
    END IF;
    IF (x_khr_rec.SUB_AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.SUB_AFTER_TAX_YIELD := l_khr_rec.SUB_AFTER_TAX_YIELD;
    END IF;
    IF (x_khr_rec.SUB_IMPL_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.SUB_IMPL_INTEREST_RATE := l_khr_rec.SUB_IMPL_INTEREST_RATE;
    END IF;
    IF (x_khr_rec.SUB_IMPL_NON_IDC_INT_RATE = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.SUB_IMPL_NON_IDC_INT_RATE := l_khr_rec.SUB_IMPL_NON_IDC_INT_RATE;
    END IF;
    IF (x_khr_rec.SUB_PRE_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.SUB_PRE_TAX_IRR := l_khr_rec.SUB_PRE_TAX_IRR;
    END IF;
    IF (x_khr_rec.SUB_AFTER_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.SUB_AFTER_TAX_IRR := l_khr_rec.SUB_AFTER_TAX_IRR;
    END IF;
    --Bug# 3973640 : 11.5.10+ schema
    IF (x_khr_rec.TOT_CL_TRANSFER_AMT = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TOT_CL_TRANSFER_AMT := l_khr_rec.TOT_CL_TRANSFER_AMT;
    END IF;
    IF (x_khr_rec.TOT_CL_NET_TRANSFER_AMT = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TOT_CL_NET_TRANSFER_AMT := l_khr_rec.TOT_CL_NET_TRANSFER_AMT;
    END IF;
    IF (x_khr_rec.TOT_CL_LIMIT = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TOT_CL_LIMIT := l_khr_rec.TOT_CL_LIMIT;
    END IF;
    IF (x_khr_rec.TOT_CL_FUNDING_AMT = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TOT_CL_FUNDING_AMT := l_khr_rec.TOT_CL_FUNDING_AMT;
    END IF;
    IF (x_khr_rec.CRS_ID = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.CRS_ID := l_khr_rec.CRS_ID;
    END IF;
    IF (x_khr_rec.TEMPLATE_TYPE_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.TEMPLATE_TYPE_CODE := l_khr_rec.TEMPLATE_TYPE_CODE;
    END IF;
--Bug# 4419339 OKLH Schema Sales Quote
    IF (x_khr_rec.DATE_FUNDING_EXPECTED = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_FUNDING_EXPECTED := l_khr_rec.DATE_FUNDING_EXPECTED;
    END IF;
    IF (x_khr_rec.DATE_TRADEIN = OKC_API.G_MISS_DATE) THEN
      x_khr_rec.DATE_TRADEIN := l_khr_rec.DATE_TRADEIN;
    END IF;
    IF (x_khr_rec.TRADEIN_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_khr_rec.TRADEIN_AMOUNT := l_khr_rec.TRADEIN_AMOUNT;
    END IF;
    IF (x_khr_rec.TRADEIN_DESCRIPTION = OKC_API.G_MISS_CHAR) THEN
      x_khr_rec.TRADEIN_DESCRIPTION := l_khr_rec.TRADEIN_DESCRIPTION;
    END IF;
     --Added by dpsingh for LE uptake
     IF (x_khr_rec.LEGAL_ENTITY_ID = OKL_API.G_MISS_NUM) THEN
      x_khr_rec.LEGAL_ENTITY_ID := l_khr_rec.LEGAL_ENTITY_ID;
    END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for: OKL_K_HEADERS --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_khr_rec IN  khr_rec_type,
      x_khr_rec OUT NOCOPY khr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_khr_rec := p_khr_rec;
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
      p_khr_rec,                         -- IN
      l_khr_rec);                        -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_khr_rec, l_def_khr_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_K_HEADERS
    SET
    ID = l_def_khr_rec.ID,
        ISG_ID = l_def_khr_rec.ISG_ID,
        KHR_ID = l_def_khr_rec.KHR_ID,
        PDT_ID = l_def_khr_rec.PDT_ID,
        OBJECT_VERSION_NUMBER = l_def_khr_rec.OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY = l_def_khr_rec.DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN = l_def_khr_rec.SYNDICATABLE_YN,
        SALESTYPE_YN = l_def_khr_rec.SALESTYPE_YN,
        DATE_REFINANCED = l_def_khr_rec.DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE = l_def_khr_rec.DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED = l_def_khr_rec.DATE_DEAL_TRANSFERRED,
        TERM_DURATION = l_def_khr_rec.TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE = l_def_khr_rec.DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE = l_def_khr_rec.DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED = l_def_khr_rec.DATE_PROPOSAL_ACCEPTED,
        ATTRIBUTE_CATEGORY = l_def_khr_rec.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1 = l_def_khr_rec.ATTRIBUTE1,
        ATTRIBUTE2 = l_def_khr_rec.ATTRIBUTE2,
        ATTRIBUTE3 = l_def_khr_rec.ATTRIBUTE3,
        ATTRIBUTE4 = l_def_khr_rec.ATTRIBUTE4,
        ATTRIBUTE5 = l_def_khr_rec.ATTRIBUTE5,
        ATTRIBUTE6 = l_def_khr_rec.ATTRIBUTE6,
        ATTRIBUTE7 = l_def_khr_rec.ATTRIBUTE7,
        ATTRIBUTE8 = l_def_khr_rec.ATTRIBUTE8,
        ATTRIBUTE9 = l_def_khr_rec.ATTRIBUTE9,
        ATTRIBUTE10 = l_def_khr_rec.ATTRIBUTE10,
        ATTRIBUTE11 = l_def_khr_rec.ATTRIBUTE11,
        ATTRIBUTE12 = l_def_khr_rec.ATTRIBUTE12,
        ATTRIBUTE13 = l_def_khr_rec.ATTRIBUTE13,
        ATTRIBUTE14 = l_def_khr_rec.ATTRIBUTE14,
        ATTRIBUTE15 = l_def_khr_rec.ATTRIBUTE15,
        CREATED_BY = l_def_khr_rec.CREATED_BY,
        CREATION_DATE = l_def_khr_rec.CREATION_DATE,
        LAST_UPDATED_BY = l_def_khr_rec.LAST_UPDATED_BY,
        LAST_UPDATE_DATE = l_def_khr_rec.LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = l_def_khr_rec.LAST_UPDATE_LOGIN,
        AMD_CODE = l_def_khr_rec.AMD_CODE,
        GENERATE_ACCRUAL_YN = l_def_khr_rec.GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN = l_def_khr_rec.GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN = l_def_khr_rec.CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN = l_def_khr_rec.CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD = l_def_khr_rec.PRE_TAX_YIELD,
        AFTER_TAX_YIELD = l_def_khr_rec.AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE = l_def_khr_rec.IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE = l_def_khr_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD = l_def_khr_rec.TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD = l_def_khr_rec.TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE = l_def_khr_rec.TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE = l_def_khr_rec.TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL = l_def_khr_rec.DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE = l_def_khr_rec.DEAL_TYPE,
        PRE_TAX_IRR = l_def_khr_rec.PRE_TAX_IRR,
        AFTER_TAX_IRR = l_def_khr_rec.AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE = l_def_khr_rec.EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE = l_def_khr_rec.ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN = l_def_khr_rec.PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN = l_def_khr_rec.REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE   = l_def_khr_rec.CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE   = l_def_khr_rec.CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE   = l_def_khr_rec.CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN              = l_def_khr_rec.MULTI_GAAP_YN,
        RECOURSE_CODE              = l_def_khr_rec.RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE       = l_def_khr_rec.LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN              = l_def_khr_rec.ASSIGNABLE_YN,
        SECURITIZED_CODE           = l_def_khr_rec.SECURITIZED_CODE,
        SECURITIZATION_TYPE        = l_def_khr_rec.SECURITIZATION_TYPE,
--Bug# 3143522 : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD                          = l_def_khr_rec.SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD                        = l_def_khr_rec.SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE                     = l_def_khr_rec.SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE                  = l_def_khr_rec.SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR                            = l_def_khr_rec.SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR                          = l_def_khr_rec.SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+ schema
   TOT_CL_TRANSFER_AMT                        = l_def_khr_rec.TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT                    = l_def_khr_rec.TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT                               = l_def_khr_rec.TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT                         = l_def_khr_rec.TOT_CL_FUNDING_AMT,
   CRS_ID                                     = l_def_khr_rec.CRS_ID,
   TEMPLATE_TYPE_CODE                         = l_def_khr_rec.TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED                      = l_def_khr_rec.DATE_FUNDING_EXPECTED,
   DATE_TRADEIN                               = l_def_khr_rec.DATE_TRADEIN,
   TRADEIN_AMOUNT                             = l_def_khr_rec.TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION                        = l_def_khr_rec.TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID                        = l_def_khr_rec.LEGAL_ENTITY_ID
    WHERE ID = l_def_khr_rec.id;

    -- Insert into History table
/*
    insert_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_k_headers_h_rec,
      lx_okl_k_headers_h_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

*/
    x_khr_rec := l_def_khr_rec;
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
  -- update_row for: OKL_K_HEADERS_V --
  ------------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_rec                     IN khrv_rec_type,
    x_khrv_rec                     OUT NOCOPY khrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec                     khrv_rec_type := p_khrv_rec;
    l_def_khrv_rec                 khrv_rec_type;
    l_khr_rec khr_rec_type;
    lx_khr_rec khr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_khrv_rec	IN khrv_rec_type
    ) RETURN khrv_rec_type IS
      l_khrv_rec	khrv_rec_type := p_khrv_rec;
    BEGIN
      l_khrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_khrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_khrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_khrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_khrv_rec	IN khrv_rec_type,
      x_khrv_rec	OUT NOCOPY khrv_rec_type
    ) RETURN VARCHAR2 IS
      l_khrv_rec                      khrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_khrv_rec := p_khrv_rec;
      -- Get current database values
      l_khrv_rec := get_rec(p_khrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;


      IF (x_khrv_rec.ID = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.ID := l_khrv_rec.ID;
      END IF;

      IF (x_khrv_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.OBJECT_VERSION_NUMBER := l_khrv_rec.OBJECT_VERSION_NUMBER;
      END IF;

      IF (x_khrv_rec.ISG_ID = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.ISG_ID := l_khrv_rec.ISG_ID;
      END IF;

      IF (x_khrv_rec.KHR_ID = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.KHR_ID := l_khrv_rec.KHR_ID;
      END IF;

      IF (x_khrv_rec.PDT_ID = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.PDT_ID := l_khrv_rec.PDT_ID;
      END IF;

      IF (x_khrv_rec.AMD_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.AMD_CODE := l_khrv_rec.AMD_CODE;
      END IF;

      IF (x_khrv_rec.DATE_FIRST_ACTIVITY = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_FIRST_ACTIVITY := l_khrv_rec.DATE_FIRST_ACTIVITY;
      END IF;

      IF (x_khrv_rec.GENERATE_ACCRUAL_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.GENERATE_ACCRUAL_YN := l_khrv_rec.GENERATE_ACCRUAL_YN;
      END IF;

      IF (x_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN := l_khrv_rec.GENERATE_ACCRUAL_OVERRIDE_YN;
      END IF;

      IF (x_khrv_rec.DATE_REFINANCED = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_REFINANCED := l_khrv_rec.DATE_REFINANCED;
      END IF;

      IF (x_khrv_rec.CREDIT_ACT_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.CREDIT_ACT_YN := l_khrv_rec.CREDIT_ACT_YN;
      END IF;

      IF (x_khrv_rec.TERM_DURATION = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TERM_DURATION := l_khrv_rec.TERM_DURATION;
      END IF;

      IF (x_khrv_rec.CONVERTED_ACCOUNT_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.CONVERTED_ACCOUNT_YN := l_khrv_rec.CONVERTED_ACCOUNT_YN;
      END IF;

      IF (x_khrv_rec.DATE_CONVERSION_EFFECTIVE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_CONVERSION_EFFECTIVE := l_khrv_rec.DATE_CONVERSION_EFFECTIVE;
      END IF;

      IF (x_khrv_rec.SYNDICATABLE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.SYNDICATABLE_YN := l_khrv_rec.SYNDICATABLE_YN;
      END IF;

      IF (x_khrv_rec.SALESTYPE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.SALESTYPE_YN := l_khrv_rec.SALESTYPE_YN;
      END IF;

      IF (x_khrv_rec.DATE_DEAL_TRANSFERRED = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_DEAL_TRANSFERRED := l_khrv_rec.DATE_DEAL_TRANSFERRED;
      END IF;

      IF (x_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE := l_khrv_rec.DATETIME_PROPOSAL_EFFECTIVE;
      END IF;

      IF (x_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE := l_khrv_rec.DATETIME_PROPOSAL_INEFFECTIVE;
      END IF;

      IF (x_khrv_rec.DATE_PROPOSAL_ACCEPTED = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_PROPOSAL_ACCEPTED := l_khrv_rec.DATE_PROPOSAL_ACCEPTED;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE_CATEGORY = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE_CATEGORY := l_khrv_rec.ATTRIBUTE_CATEGORY;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE1 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE1 := l_khrv_rec.ATTRIBUTE1;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE2 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE2 := l_khrv_rec.ATTRIBUTE2;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE3 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE3 := l_khrv_rec.ATTRIBUTE3;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE4 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE4 := l_khrv_rec.ATTRIBUTE4;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE5 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE5 := l_khrv_rec.ATTRIBUTE5;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE6 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE6 := l_khrv_rec.ATTRIBUTE6;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE7 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE7 := l_khrv_rec.ATTRIBUTE7;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE8 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE8 := l_khrv_rec.ATTRIBUTE8;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE9 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE9 := l_khrv_rec.ATTRIBUTE9;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE10 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE10 := l_khrv_rec.ATTRIBUTE10;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE11 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE11 := l_khrv_rec.ATTRIBUTE11;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE12 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE12 := l_khrv_rec.ATTRIBUTE12;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE13 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE13 := l_khrv_rec.ATTRIBUTE13;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE14 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE14 := l_khrv_rec.ATTRIBUTE14;
      END IF;

      IF (x_khrv_rec.ATTRIBUTE15 = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ATTRIBUTE15 := l_khrv_rec.ATTRIBUTE15;
      END IF;

      IF (x_khrv_rec.CREATED_BY = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.CREATED_BY := l_khrv_rec.CREATED_BY;
      END IF;

      IF (x_khrv_rec.CREATION_DATE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.CREATION_DATE := l_khrv_rec.CREATION_DATE;
      END IF;

      IF (x_khrv_rec.LAST_UPDATED_BY = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.LAST_UPDATED_BY := l_khrv_rec.LAST_UPDATED_BY;
      END IF;

      IF (x_khrv_rec.LAST_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.LAST_UPDATE_DATE := l_khrv_rec.LAST_UPDATE_DATE;
      END IF;

      IF (x_khrv_rec.LAST_UPDATE_LOGIN = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.LAST_UPDATE_LOGIN := l_khrv_rec.LAST_UPDATE_LOGIN;
      END IF;

      IF (x_khrv_rec.PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.PRE_TAX_YIELD := l_khrv_rec.PRE_TAX_YIELD;
      END IF;

      IF (x_khrv_rec.AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.AFTER_TAX_YIELD := l_khrv_rec.AFTER_TAX_YIELD;
      END IF;

      IF (x_khrv_rec.IMPLICIT_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.IMPLICIT_INTEREST_RATE := l_khrv_rec.IMPLICIT_INTEREST_RATE;
      END IF;

      IF (x_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE := l_khrv_rec.IMPLICIT_NON_IDC_INTEREST_RATE;
      END IF;

      IF (x_khrv_rec.TARGET_PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TARGET_PRE_TAX_YIELD := l_khrv_rec.TARGET_PRE_TAX_YIELD;
      END IF;

      IF (x_khrv_rec.TARGET_AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TARGET_AFTER_TAX_YIELD := l_khrv_rec.TARGET_AFTER_TAX_YIELD;
      END IF;

      IF (x_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE := l_khrv_rec.TARGET_IMPLICIT_INTEREST_RATE;
      END IF;

      IF (x_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE := l_khrv_rec.TARGET_IMPLICIT_NONIDC_INTRATE;
      END IF;

      IF (x_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL := l_khrv_rec.DATE_LAST_INTERIM_INTEREST_CAL;
      END IF;

      IF (x_khrv_rec.DEAL_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.DEAL_TYPE := l_khrv_rec.DEAL_TYPE;
      END IF;

      IF (x_khrv_rec.PRE_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.PRE_TAX_IRR := l_khrv_rec.PRE_TAX_IRR;
      END IF;

      IF (x_khrv_rec.AFTER_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.AFTER_TAX_IRR := l_khrv_rec.AFTER_TAX_IRR;
      END IF;

      IF (x_khrv_rec.EXPECTED_DELIVERY_DATE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.EXPECTED_DELIVERY_DATE := l_khrv_rec.EXPECTED_DELIVERY_DATE;
      END IF;

      IF (x_khrv_rec.ACCEPTED_DATE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.ACCEPTED_DATE := l_khrv_rec.ACCEPTED_DATE;
      END IF;

      IF (x_khrv_rec.PREFUNDING_ELIGIBLE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.PREFUNDING_ELIGIBLE_YN := l_khrv_rec.PREFUNDING_ELIGIBLE_YN;
      END IF;

      IF (x_khrv_rec.REVOLVING_CREDIT_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.REVOLVING_CREDIT_YN := l_khrv_rec.REVOLVING_CREDIT_YN;
      END IF;

--Bug# 2697681 schema changes  11.5.9
      IF (x_khrv_rec.CURRENCY_CONVERSION_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.CURRENCY_CONVERSION_TYPE := l_khrv_rec.CURRENCY_CONVERSION_TYPE;
      END IF;

      IF (x_khrv_rec.CURRENCY_CONVERSION_RATE = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.CURRENCY_CONVERSION_RATE := l_khrv_rec.CURRENCY_CONVERSION_RATE;
      END IF;

      IF (x_khrv_rec.CURRENCY_CONVERSION_DATE = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.CURRENCY_CONVERSION_DATE := l_khrv_rec.CURRENCY_CONVERSION_DATE;
      END IF;

      IF (x_khrv_rec.MULTI_GAAP_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.MULTI_GAAP_YN := l_khrv_rec.MULTI_GAAP_YN;
      END IF;

      IF (x_khrv_rec.RECOURSE_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.RECOURSE_CODE := l_khrv_rec.RECOURSE_CODE;
      END IF;

      IF (x_khrv_rec.LESSOR_SERV_ORG_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.LESSOR_SERV_ORG_CODE := l_khrv_rec.LESSOR_SERV_ORG_CODE;
      END IF;

      IF (x_khrv_rec.ASSIGNABLE_YN = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.ASSIGNABLE_YN := l_khrv_rec.ASSIGNABLE_YN;
      END IF;

      IF (x_khrv_rec.SECURITIZED_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.SECURITIZED_CODE := l_khrv_rec.SECURITIZED_CODE;
      END IF;

      IF (x_khrv_rec.SECURITIZATION_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.SECURITIZATION_TYPE := l_khrv_rec.SECURITIZATION_TYPE;
      END IF;

--Bug# 3143522 : 11.5.10
    --subsidy
    IF (x_khrv_rec.SUB_PRE_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.SUB_PRE_TAX_YIELD := l_khrv_rec.SUB_PRE_TAX_YIELD;
    END IF;
    IF (x_khrv_rec.SUB_AFTER_TAX_YIELD = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.SUB_AFTER_TAX_YIELD := l_khrv_rec.SUB_AFTER_TAX_YIELD;
    END IF;
    IF (x_khrv_rec.SUB_IMPL_INTEREST_RATE = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.SUB_IMPL_INTEREST_RATE := l_khrv_rec.SUB_IMPL_INTEREST_RATE;
    END IF;
    IF (x_khrv_rec.SUB_IMPL_NON_IDC_INT_RATE = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.SUB_IMPL_NON_IDC_INT_RATE := l_khrv_rec.SUB_IMPL_NON_IDC_INT_RATE;
    END IF;
    IF (x_khrv_rec.SUB_PRE_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.SUB_PRE_TAX_IRR := l_khrv_rec.SUB_PRE_TAX_IRR;
    END IF;
    IF (x_khrv_rec.SUB_AFTER_TAX_IRR = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.SUB_AFTER_TAX_IRR := l_khrv_rec.SUB_AFTER_TAX_IRR;
    END IF;
    --Bug# 3973640 : 11.5.10+ schema changes
    IF (x_khrv_rec.TOT_CL_TRANSFER_AMT = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TOT_CL_TRANSFER_AMT := l_khrv_rec.TOT_CL_TRANSFER_AMT;
    END IF;
    IF (x_khrv_rec.TOT_CL_NET_TRANSFER_AMT = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TOT_CL_NET_TRANSFER_AMT := l_khrv_rec.TOT_CL_NET_TRANSFER_AMT;
    END IF;
    IF (x_khrv_rec.TOT_CL_LIMIT = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TOT_CL_LIMIT := l_khrv_rec.TOT_CL_LIMIT;
    END IF;
    IF (x_khrv_rec.TOT_CL_FUNDING_AMT = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TOT_CL_FUNDING_AMT := l_khrv_rec.TOT_CL_FUNDING_AMT;
    END IF;
    IF (x_khrv_rec.CRS_ID = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.CRS_ID := l_khrv_rec.CRS_ID;
    END IF;
    IF (x_khrv_rec.TEMPLATE_TYPE_CODE = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.TEMPLATE_TYPE_CODE := l_khrv_rec.TEMPLATE_TYPE_CODE;
    END IF;
--Bug# 4419339 OKLH Schema Sales Quote
    IF (x_khrv_rec.DATE_FUNDING_EXPECTED = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_FUNDING_EXPECTED := l_khrv_rec.DATE_FUNDING_EXPECTED;
    END IF;
    IF (x_khrv_rec.DATE_TRADEIN = OKC_API.G_MISS_DATE) THEN
      x_khrv_rec.DATE_TRADEIN := l_khrv_rec.DATE_TRADEIN;
    END IF;
    IF (x_khrv_rec.TRADEIN_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_khrv_rec.TRADEIN_AMOUNT := l_khrv_rec.TRADEIN_AMOUNT;
    END IF;
    IF (x_khrv_rec.TRADEIN_DESCRIPTION = OKC_API.G_MISS_CHAR) THEN
      x_khrv_rec.TRADEIN_DESCRIPTION := l_khrv_rec.TRADEIN_DESCRIPTION;
    END IF;
    --Added by dpsingh for LE uptake
    IF (x_khrv_rec.LEGAL_ENTITY_ID = OKL_API.G_MISS_NUM) THEN
      x_khrv_rec.LEGAL_ENTITY_ID := l_khrv_rec.LEGAL_ENTITY_ID;
    END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:  OKL_K_HEADERS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_khrv_rec IN  khrv_rec_type,
      x_khrv_rec OUT NOCOPY khrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_khrv_rec := p_khrv_rec;
      x_khrv_rec.OBJECT_VERSION_NUMBER := NVL(x_khrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_khrv_rec,                        -- IN
      l_khrv_rec);                       -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_khrv_rec, l_def_khrv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_khrv_rec := fill_who_columns(l_def_khrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_khrv_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_khrv_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_khrv_rec, l_khr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_khr_rec,
      lx_khr_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_khr_rec, l_def_khrv_rec);
    x_khrv_rec := l_def_khrv_rec;
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
  -- PL/SQL TBL update_row for: OKL_K_HEADERS_V --
  ----------------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_tbl                     IN khrv_tbl_type,
    x_khrv_tbl                     OUT NOCOPY khrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_khrv_tbl.COUNT > 0) THEN
      i := p_khrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_khrv_rec                     => p_khrv_tbl(i),
          x_khrv_rec                     => x_khrv_tbl(i));
        EXIT WHEN (i = p_khrv_tbl.LAST);
        i := p_khrv_tbl.NEXT(i);
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

  ----------------------------------
  -- delete_row for: OKL_K_HEADERS --
  ----------------------------------

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khr_rec                     IN khr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khr_rec                      khr_rec_type:= p_khr_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    l_okl_k_headers_h_rec okl_k_headers_h_rec_type;
    lx_okl_k_headers_h_rec okl_k_headers_h_rec_type;
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
--Bug # 2522268
/*-------removed as we do not do implicit versioning on delete------------------
    -- Insert into History table
    l_khr_rec := get_rec(l_khr_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    migrate(l_khr_rec, l_okl_k_headers_h_rec);
    insert_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_k_headers_h_rec,
      lx_okl_k_headers_h_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
-------removed as we do not do implicit versioning on delete-----------------*/
--Bug # 2522268
    DELETE FROM OKL_K_HEADERS
     WHERE ID = l_khr_rec.id;

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

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_rec                     IN khrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_khrv_rec                     khrv_rec_type := p_khrv_rec;
    l_khr_rec khr_rec_type;
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
    migrate(l_khrv_rec, l_khr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_khr_rec
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
  -- PL/SQL TBL delete_row for: OKL_K_HEADERS_V --
  ----------------------------------------

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_khrv_tbl                     IN khrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_khrv_tbl.COUNT > 0) THEN
      i := p_khrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_khrv_rec                     => p_khrv_tbl(i));
        EXIT WHEN (i = p_khrv_tbl.LAST);
        i := p_khrv_tbl.NEXT(i);
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


  ---------------------------------------------------------------------------
  -- PROCEDURE versioning
  ---------------------------------------------------------------------------

  FUNCTION create_version(
    p_khr_id IN NUMBER,
    p_major_version IN NUMBER) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO OKL_K_HEADERS_H
  (
      major_version,
	ID,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug# 3143522 :11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+ schema
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT   ,
   CRS_ID,
   TEMPLATE_TYPE_CODE ,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID
   )
  SELECT
      p_major_version,
	ID,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+ schema
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
   --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID
  FROM OKL_K_HEADERS
  WHERE id = p_khr_id;

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

  FUNCTION restore_version(
    p_khr_id IN NUMBER,
    p_major_version IN NUMBER) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO OKL_K_HEADERS
  (
	ID,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug# 3143522 :11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+ schema
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
    --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID)
  SELECT
	ID,
        ISG_ID,
        KHR_ID,
        PDT_ID,
        OBJECT_VERSION_NUMBER,
        DATE_FIRST_ACTIVITY,
        SYNDICATABLE_YN,
        SALESTYPE_YN,
        DATE_REFINANCED,
        DATE_CONVERSION_EFFECTIVE,
        DATE_DEAL_TRANSFERRED,
        TERM_DURATION,
        DATETIME_PROPOSAL_EFFECTIVE,
        DATETIME_PROPOSAL_INEFFECTIVE,
        DATE_PROPOSAL_ACCEPTED,
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
        AMD_CODE,
        GENERATE_ACCRUAL_YN,
        GENERATE_ACCRUAL_OVERRIDE_YN,
        CREDIT_ACT_YN,
        CONVERTED_ACCOUNT_YN,
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        TARGET_PRE_TAX_YIELD,
        TARGET_AFTER_TAX_YIELD,
        TARGET_IMPLICIT_INTEREST_RATE,
        TARGET_IMPLICIT_NONIDC_INTRATE,
        DATE_LAST_INTERIM_INTEREST_CAL,
        DEAL_TYPE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
        EXPECTED_DELIVERY_DATE,
        ACCEPTED_DATE,
        PREFUNDING_ELIGIBLE_YN,
        REVOLVING_CREDIT_YN,
--Bug# 2697681 schema changes  11.5.9
        CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE,
        CURRENCY_CONVERSION_DATE,
        MULTI_GAAP_YN,
        RECOURSE_CODE,
        LESSOR_SERV_ORG_CODE,
        ASSIGNABLE_YN,
        SECURITIZED_CODE,
        SECURITIZATION_TYPE,
--Bug# 3143522  : 11.5.10
   --subsidy
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
   --Bug# 3973640 : 11.5.10+ schema
   TOT_CL_TRANSFER_AMT,
   TOT_CL_NET_TRANSFER_AMT,
   TOT_CL_LIMIT,
   TOT_CL_FUNDING_AMT,
   CRS_ID,
   TEMPLATE_TYPE_CODE,
--Bug# 4419339 OKLH Schema Sales Quote
   DATE_FUNDING_EXPECTED,
   DATE_TRADEIN,
   TRADEIN_AMOUNT,
   TRADEIN_DESCRIPTION,
 --Added by dpsingh for LE uptake
   LEGAL_ENTITY_ID
  FROM OKL_K_HEADERS_H
  WHERE id = p_khr_id and major_version = p_major_version;

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


END OKL_KHR_PVT;

/
