--------------------------------------------------------
--  DDL for Package Body OKL_KLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_KLE_PVT" AS
/* $Header: OKLSKLEB.pls 120.5.12010000.2 2009/07/17 23:29:53 sechawla ship $ */
-- --------------------------------------------------------------------------
--  Start of column level validations
-- --------------------------------------------------------------------------
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';


  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_VIEW		 CONSTANT	VARCHAR2(200) := 'OKL_K_LINES_V';

  G_EXCEPTION_HALT_VALIDATION	exception;


-- ************************ HAND CODED VALIDATION ****************************************

  -- Start of comments
  --
  -- Procedure Name  : validate_CREDIT_TENANT_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_CREDIT_TENANT_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	      p_klev_rec      IN    klev_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_klev_rec.CREDIT_TENANT_YN <> OKC_API.G_MISS_CHAR and
  	   p_klev_rec.CREDIT_TENANT_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_klev_rec.CREDIT_TENANT_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'CREDIT_TENANT_YN');
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
  End validate_CREDIT_TENANT_YN;


  -- Start of comments
  --
  -- Procedure Name  : validate_PRESCRIBED_ASSET_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_PRESCRIBED_ASSET_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	      p_klev_rec      IN    klev_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_klev_rec.PRESCRIBED_ASSET_YN <> OKC_API.G_MISS_CHAR and
  	   p_klev_rec.PRESCRIBED_ASSET_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_klev_rec.PRESCRIBED_ASSET_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'PRESCRIBED_ASSET_YN');
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
  End validate_PRESCRIBED_ASSET_YN;


  -- Start of comments
  --
  -- Procedure Name  : validate_SECURED_DEAL_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_SECURED_DEAL_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	      p_klev_rec      IN    klev_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_klev_rec.SECURED_DEAL_YN <> OKC_API.G_MISS_CHAR and
  	   p_klev_rec.SECURED_DEAL_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_klev_rec.SECURED_DEAL_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'SECURED_DEAL_YN');
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
  End validate_SECURED_DEAL_YN;

  -- Start of comments
  --
  -- Procedure Name  : validate_RE_LEASE_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_RE_LEASE_YN(x_return_status OUT NOCOPY   VARCHAR2,
                            	      p_klev_rec      IN    klev_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_klev_rec.RE_LEASE_YN <> OKC_API.G_MISS_CHAR and
  	   p_klev_rec.RE_LEASE_YN IS NOT NULL)
    Then
      -- check allowed values
      If (upper(p_klev_rec.RE_LEASE_YN) NOT IN ('Y','N')) Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_invalid_value,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'RE_LEASE_YN');
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
  End validate_RE_LEASE_YN;

-- Start of comments
--
-- Procedure Name  : validate_FEE_TYPE
-- Description     : validates precense of the FEE_TYPE for the record
-- Business Rules  :
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_FEE_TYPE(x_return_status OUT NOCOPY VARCHAR2,
			      p_klev_rec                     IN klev_rec_type
    ) is
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

--  nulls are allowed
      if (p_klev_rec.FEE_TYPE <> OKC_API.G_MISS_CHAR) OR (p_klev_rec.FEE_TYPE IS NOT  NULL) then
          -- Check if the value is a valid code from lookup table
          x_return_status := OKC_UTIL.check_lookup_code('OKL_FEE_TYPES',
                                                    p_klev_rec.FEE_TYPE);
          If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
                --set error message in message stack
                OKC_API.SET_MESSAGE(
                            p_app_name      => G_APP_NAME,
                            p_msg_name      => G_INVALID_VALUE,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'FEE_TYPE');
                raise G_EXCEPTION_HALT_VALIDATION;
          Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
                raise G_EXCEPTION_HALT_VALIDATION;
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
  end validate_FEE_TYPE;

  --Bug# 3973640 :
-- Start of comments
--
-- Procedure Name  : validate_strm_subcalss
-- Description     : validates precense of the STREAM_TYPE_SUBCLASS for the record
-- Business Rules  :
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_strm_subclass(x_return_status OUT NOCOPY VARCHAR2,
                                   p_klev_rec      IN klev_rec_type
    ) is
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

--  nulls are allowed
      if (p_klev_rec.STREAM_TYPE_SUBCLASS <> OKC_API.G_MISS_CHAR) OR (p_klev_rec.STREAM_TYPE_SUBCLASS IS NOT  NULL) then
          -- Check if the value is a valid code from lookup table
          x_return_status := OKC_UTIL.check_lookup_code('OKL_STREAM_TYPE_SUBCLASS',
                                                        p_klev_rec.STREAM_TYPE_SUBCLASS);
          If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
                --set error message in message stack
                OKC_API.SET_MESSAGE(
                            p_app_name      => G_APP_NAME,
                            p_msg_name      => G_INVALID_VALUE,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'STREAM_TYPE_SUBCLASS');
                raise G_EXCEPTION_HALT_VALIDATION;
          Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
                raise G_EXCEPTION_HALT_VALIDATION;
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
                                    p_token2     => g_sqlerrm_token,
                                    p_token2_value => sqlerrm);
        -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  end validate_strm_subclass;

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
               p_klev_rec      IN    klev_rec_type) is

    l_segment_values_rec   Okl_DFlex_Util_Pvt.DFF_Rec_type;
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(2000);
    l_appl_short_name      VARCHAR2(30) := 'OKL';
    l_desc_flex_name       VARCHAR2(30) := 'OKL_K_LINES_DF';
    l_segment_partial_name VARCHAR2(30) := 'ATTRIBUTE';
  Begin
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_segment_values_rec.attribute_category := p_klev_rec.attribute_category;
    l_segment_values_rec.attribute1 := p_klev_rec.attribute1;
    l_segment_values_rec.attribute2 := p_klev_rec.attribute2;
    l_segment_values_rec.attribute3 := p_klev_rec.attribute3;
    l_segment_values_rec.attribute4 := p_klev_rec.attribute4;
    l_segment_values_rec.attribute5 := p_klev_rec.attribute5;
    l_segment_values_rec.attribute6 := p_klev_rec.attribute6;
    l_segment_values_rec.attribute7 := p_klev_rec.attribute7;
    l_segment_values_rec.attribute8 := p_klev_rec.attribute8;
    l_segment_values_rec.attribute9 := p_klev_rec.attribute9;
    l_segment_values_rec.attribute10 := p_klev_rec.attribute10;
    l_segment_values_rec.attribute11 := p_klev_rec.attribute11;
    l_segment_values_rec.attribute12 := p_klev_rec.attribute12;
    l_segment_values_rec.attribute13 := p_klev_rec.attribute13;
    l_segment_values_rec.attribute14 := p_klev_rec.attribute14;
    l_segment_values_rec.attribute15 := p_klev_rec.attribute15;

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

-- ************************ END OF HAND CODED VALIDATION *********************************

-- Start of comments
--
-- Procedure Name  : validate_ID
-- Description     : validates precense of the ID for the record
-- Business Rules  : required field
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_ID(x_return_status OUT NOCOPY VARCHAR2,
			      p_klev_rec                     IN klev_rec_type
    ) is
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- data is required
      if (p_klev_rec.ID = OKC_API.G_MISS_NUM) OR (p_klev_rec.ID IS NULL) then
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
			      p_klev_rec                     IN klev_rec_type
    ) is
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- data is required
      if (p_klev_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) OR (p_klev_rec.OBJECT_VERSION_NUMBER IS NULL) then
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

-- Start of comments
--
-- Procedure Name  : validate_CLG_ID
-- Description     : validates precense of the CLG_ID for the record
-- Business Rules  : required field
-- Parameters      :
-- Version         :
-- End of comments
  procedure validate_CLG_ID(x_return_status OUT NOCOPY VARCHAR2,
			      p_klev_rec                     IN klev_rec_type
    ) is
    begin
-- initialize return status
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

-- data is required
      if (p_klev_rec.CLG_ID = OKC_API.G_MISS_NUM) OR (p_klev_rec.CLG_ID IS NULL) then
	  OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CLG_ID');

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
  end validate_CLG_ID;
--Bug# 3143522 : 11.5.10 Subsidies
-------------------------------------------
--validate attributes for subsidy_id
------------------------------------------
PROCEDURE validate_subsidy_id(
    x_return_status    OUT NOCOPY VARCHAR2,
    p_klev_rec         IN klev_rec_type) IS

    cursor l_sub_csr (p_subsidy_id in number) is
    select 'Y'
    from   okl_subsidies_b subb
    where  subb.id = p_subsidy_id;

    l_exists varchar2(1) default 'N';
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_klev_rec.subsidy_id = OKL_API.G_MISS_NUM OR
        p_klev_rec.subsidy_id IS NULL)
    THEN
        null; --null values are allowed
    ELSE
        --check foreign key validation
        l_exists := 'N';
        open l_sub_csr(p_subsidy_id => p_klev_rec.subsidy_id);
        fetch l_sub_csr into l_exists;
        If l_sub_csr%NOTFOUND then
            null;
        End If;
        Close l_sub_csr;
        If l_exists = 'N' then
           OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy Name');
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
end validate_subsidy_id;
  ---------------------------------------------
  -- Validate_Attributes for: OKL_K_LINES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_klev_rec                     IN klev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN


    -- call each column-level validation
    -- do not validate id because it will be set up automatically

/*
    validate_ID(x_return_status => l_return_status,
		    p_klev_rec	  => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;
*/
    validate_OBJECT_VERSION_NUMBER(x_return_status => l_return_status,
		    p_klev_rec	  => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;
/*
    validate_CLG_ID(x_return_status => l_return_status,
		    p_klev_rec	  => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;
*/

    validate_CREDIT_TENANT_YN(x_return_status => l_return_status,
		    p_klev_rec	  => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_PRESCRIBED_ASSET_YN(x_return_status => l_return_status,
		    p_klev_rec	  => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_SECURED_DEAL_YN(x_return_status => l_return_status,
		    p_klev_rec	  => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

    validate_RE_LEASE_YN(x_return_status => l_return_status,
		    p_klev_rec	  => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
	if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
	  x_return_status := l_return_status;
	end if;
    end if;

--Bug# : 11.5.9.0.3 Fee type
    validate_FEE_TYPE(x_return_status => l_return_status,
                    p_klev_rec    => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
        end if;
    end if;

-------------------------
--Bug# 3143522 : Subsidies
-------------------------
    validate_SUBSIDY_ID(x_return_status => l_return_status,
                        p_klev_rec    => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
        end if;
    end if;
-------------------------
--Bug# 3143522 : Subsidies
-------------------------

------------------------
--Bug# 3973640 : 11.5.10+
------------------------
    validate_strm_subclass(x_return_status => l_return_status,
                           p_klev_rec    => p_klev_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
        end if;
    end if;
------------------------
--Bug# 3973640 : 11.5.10+
------------------------

    --Bug# 4558486
    -- ***
    -- DFF Attributes
    -- ***
    if ( NVL(p_klev_rec.validate_dff_yn,OKL_API.G_MISS_CHAR) = 'Y') then
      validate_DFF_attributes
        (x_return_status => l_return_status,
         p_klev_rec      => p_klev_rec);

      -- store the highest degree of error
      if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
        end if;
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
  -- FUNCTION get_rec for: OKL_K_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_kle_rec                     IN kle_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN kle_rec_type IS
    CURSOR okl_k_lines_pk_csr (p_id                 IN NUMBER) IS
      SELECT
	ID,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 :11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug# 3143522: 11.5.10
--subsidy
        SUBSIDY_ID,
        --SUBSIDIZED_OEC,
        --SUBSIDIZED_CAP_AMOUNT,
        SUBSIDY_OVERRIDE_AMOUNT,
--financed fee
        PRE_TAX_YIELD,
        AFTER_TAX_YIELD,
        IMPLICIT_INTEREST_RATE,
        IMPLICIT_NON_IDC_INTEREST_RATE,
        PRE_TAX_IRR,
        AFTER_TAX_IRR,
--quote
        SUB_PRE_TAX_YIELD,
        SUB_AFTER_TAX_YIELD,
        SUB_IMPL_INTEREST_RATE,
        SUB_IMPL_NON_IDC_INT_RATE,
        SUB_PRE_TAX_IRR,
        SUB_AFTER_TAX_IRR,
--Bug# 2994971
        ITEM_INSURANCE_CATEGORY,
--Bug# 3973640: 11.5.10+
        QTE_ID,
        FUNDING_DATE,
        STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
        DATE_FUNDING_EXPECTED,
        MANUFACTURER_NAME,
        MODEL_NUMBER,
        DOWN_PAYMENT_RECEIVER_CODE,
        CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
        FEE_PURPOSE_CODE,
        TERMINATION_VALUE,
--Bug# 4631549
        EXPECTED_ASSET_COST,
        ORIG_CONTRACT_LINE_ID

      FROM OKL_K_LINES
      WHERE OKL_K_LINES.id     = p_id;
      l_okl_k_lines_pk             okl_k_lines_pk_csr%ROWTYPE;
      l_kle_rec                      kle_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_lines_pk_csr (p_kle_rec.id);
    FETCH okl_k_lines_pk_csr INTO
       l_kle_rec.ID,
        l_kle_rec.KLE_ID,
        l_kle_rec.STY_ID,
        l_kle_rec.OBJECT_VERSION_NUMBER,
        l_kle_rec.LAO_AMOUNT,
        l_kle_rec.FEE_CHARGE,
        l_kle_rec.TITLE_DATE,
        l_kle_rec.DATE_RESIDUAL_LAST_REVIEW,
        l_kle_rec.DATE_LAST_REAMORTISATION,
        l_kle_rec.TERMINATION_PURCHASE_AMOUNT,
        l_kle_rec.DATE_LAST_CLEANUP,
        l_kle_rec.REMARKETED_AMOUNT,
        l_kle_rec.DATE_REMARKETED,
        l_kle_rec.REMARKET_MARGIN,
        l_kle_rec.REPURCHASED_AMOUNT,
        l_kle_rec.DATE_REPURCHASED,
        l_kle_rec.GAIN_LOSS,
        l_kle_rec.FLOOR_AMOUNT,
        l_kle_rec.PREVIOUS_CONTRACT,
        l_kle_rec.TRACKED_RESIDUAL,
        l_kle_rec.DATE_TITLE_RECEIVED,
        l_kle_rec.ESTIMATED_OEC,
        l_kle_rec.RESIDUAL_PERCENTAGE,
        l_kle_rec.CAPITAL_REDUCTION,
        l_kle_rec.VENDOR_ADVANCE_PAID,
        l_kle_rec.TRADEIN_AMOUNT,
        l_kle_rec.DELIVERED_DATE,
        l_kle_rec.YEAR_OF_MANUFACTURE,
        l_kle_rec.INITIAL_DIRECT_COST,
        l_kle_rec.OCCUPANCY,
        l_kle_rec.DATE_LAST_INSPECTION,
        l_kle_rec.DATE_NEXT_INSPECTION_DUE,
        l_kle_rec.WEIGHTED_AVERAGE_LIFE,
        l_kle_rec.BOND_EQUIVALENT_YIELD,
        l_kle_rec.REFINANCE_AMOUNT,
        l_kle_rec.YEAR_BUILT,
        l_kle_rec.COVERAGE_RATIO,
        l_kle_rec.GROSS_SQUARE_FOOTAGE,
        l_kle_rec.NET_RENTABLE,
        l_kle_rec.DATE_LETTER_ACCEPTANCE,
        l_kle_rec.DATE_COMMITMENT_EXPIRATION,
        l_kle_rec.DATE_APPRAISAL,
        l_kle_rec.APPRAISAL_VALUE,
        l_kle_rec.RESIDUAL_VALUE,
        l_kle_rec.PERCENT,
        l_kle_rec.COVERAGE,
        l_kle_rec.LRV_AMOUNT,
        l_kle_rec.AMOUNT,
        l_kle_rec.LRS_PERCENT,
        l_kle_rec.EVERGREEN_PERCENT,
        l_kle_rec.PERCENT_STAKE,
        l_kle_rec.AMOUNT_STAKE,
        l_kle_rec.DATE_SOLD,
        l_kle_rec.STY_ID_FOR,
        l_kle_rec.ATTRIBUTE_CATEGORY,
        l_kle_rec.ATTRIBUTE1,
        l_kle_rec.ATTRIBUTE2,
        l_kle_rec.ATTRIBUTE3,
        l_kle_rec.ATTRIBUTE4,
        l_kle_rec.ATTRIBUTE5,
        l_kle_rec.ATTRIBUTE6,
        l_kle_rec.ATTRIBUTE7,
        l_kle_rec.ATTRIBUTE8,
        l_kle_rec.ATTRIBUTE9,
        l_kle_rec.ATTRIBUTE10,
        l_kle_rec.ATTRIBUTE11,
        l_kle_rec.ATTRIBUTE12,
        l_kle_rec.ATTRIBUTE13,
        l_kle_rec.ATTRIBUTE14,
        l_kle_rec.ATTRIBUTE15,
        l_kle_rec.CREATED_BY,
        l_kle_rec.CREATION_DATE,
        l_kle_rec.LAST_UPDATED_BY,
        l_kle_rec.LAST_UPDATE_DATE,
        l_kle_rec.LAST_UPDATE_LOGIN,
        l_kle_rec.NTY_CODE,
        l_kle_rec.FCG_CODE,
        l_kle_rec.PRC_CODE,
        l_kle_rec.RE_LEASE_YN,
        l_kle_rec.PRESCRIBED_ASSET_YN,
        l_kle_rec.CREDIT_TENANT_YN,
        l_kle_rec.SECURED_DEAL_YN,
        l_kle_rec.CLG_ID,
        l_kle_rec.DATE_FUNDING,
        l_kle_rec.DATE_FUNDING_REQUIRED,
        l_kle_rec.DATE_ACCEPTED,
        l_kle_rec.DATE_DELIVERY_EXPECTED,
        l_kle_rec.OEC,
        l_kle_rec.CAPITAL_AMOUNT,
        l_kle_rec.RESIDUAL_GRNTY_AMOUNT,
        l_kle_rec.RESIDUAL_CODE,
        l_kle_rec.RVI_PREMIUM,
        l_kle_rec.CREDIT_NATURE,
        l_kle_rec.CAPITALIZED_INTEREST,
        l_kle_rec.CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        l_kle_rec.DATE_PAY_INVESTOR_START,
        l_kle_rec.PAY_INVESTOR_FREQUENCY,
        l_kle_rec.PAY_INVESTOR_EVENT,
        l_kle_rec.PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        l_kle_rec.FEE_TYPE,
--Bug#3143522 : 11.5.10
--subsidy
   l_kle_rec.SUBSIDY_ID,
   --l_kle_rec.SUBSIDIZED_OEC,
   --l_kle_rec.SUBSIDIZED_CAP_AMOUNT,
   l_kle_rec.SUBSIDY_OVERRIDE_AMOUNT,
--financed fee
   l_kle_rec.PRE_TAX_YIELD,
   l_kle_rec.AFTER_TAX_YIELD,
   l_kle_rec.IMPLICIT_INTEREST_RATE,
   l_kle_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
   l_kle_rec.PRE_TAX_IRR,
   l_kle_rec.AFTER_TAX_IRR,
--quote
   l_kle_rec.SUB_PRE_TAX_YIELD,
   l_kle_rec.SUB_AFTER_TAX_YIELD,
   l_kle_rec.SUB_IMPL_INTEREST_RATE,
   l_kle_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_kle_rec.SUB_PRE_TAX_IRR,
   l_kle_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971 :
   l_kle_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640: 11.5.10+
   l_kle_rec.QTE_ID,
   l_kle_rec.FUNDING_DATE,
   l_kle_rec.STREAM_TYPE_SUBCLASS,
--Bug# 4419339 OKLH
   l_kle_rec.DATE_FUNDING_EXPECTED,
   l_kle_rec.MANUFACTURER_NAME,
   l_kle_rec.MODEL_NUMBER,
   l_kle_rec.DOWN_PAYMENT_RECEIVER_CODE,
   l_kle_rec.CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   l_kle_rec.FEE_PURPOSE_CODE,
   l_kle_rec.TERMINATION_VALUE,
--Bug# 457760
   l_kle_rec.EXPECTED_ASSET_COST,
   l_kle_rec.ORIG_CONTRACT_LINE_ID
        ;
    x_no_data_found := okl_k_lines_pk_csr%NOTFOUND;
    CLOSE okl_k_lines_pk_csr;
    RETURN(l_kle_rec);
  END get_rec;

  FUNCTION get_rec (
    p_kle_rec                     IN kle_rec_type
  ) RETURN kle_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_kle_rec, l_row_notfound));
  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_K_LINES_H
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_k_lines_h_rec                     IN okl_k_lines_h_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_k_lines_h_rec_type IS
    CURSOR okl_k_lines_h_pk_csr (p_id                 IN NUMBER) IS
      SELECT
	ID,
        MAJOR_VERSION,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug# 3143522 : 11.5.10
--subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
--financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--bug# 2994971
   ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 :11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339 OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID

      FROM OKL_K_LINES_H
      WHERE OKL_K_LINES_H.id     = p_id;
      l_okl_k_lines_h_pk             okl_k_lines_h_pk_csr%ROWTYPE;
      l_okl_k_lines_h_rec                      okl_k_lines_h_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_lines_h_pk_csr (p_okl_k_lines_h_rec.id);
    FETCH okl_k_lines_h_pk_csr INTO
       l_okl_k_lines_h_rec.ID,
        l_okl_k_lines_h_rec.MAJOR_VERSION,
        l_okl_k_lines_h_rec.KLE_ID,
        l_okl_k_lines_h_rec.STY_ID,
        l_okl_k_lines_h_rec.OBJECT_VERSION_NUMBER,
        l_okl_k_lines_h_rec.LAO_AMOUNT,
        l_okl_k_lines_h_rec.FEE_CHARGE,
        l_okl_k_lines_h_rec.TITLE_DATE,
        l_okl_k_lines_h_rec.DATE_RESIDUAL_LAST_REVIEW,
        l_okl_k_lines_h_rec.DATE_LAST_REAMORTISATION,
        l_okl_k_lines_h_rec.TERMINATION_PURCHASE_AMOUNT,
        l_okl_k_lines_h_rec.DATE_LAST_CLEANUP,
        l_okl_k_lines_h_rec.REMARKETED_AMOUNT,
        l_okl_k_lines_h_rec.DATE_REMARKETED,
        l_okl_k_lines_h_rec.REMARKET_MARGIN,
        l_okl_k_lines_h_rec.REPURCHASED_AMOUNT,
        l_okl_k_lines_h_rec.DATE_REPURCHASED,
        l_okl_k_lines_h_rec.GAIN_LOSS,
        l_okl_k_lines_h_rec.FLOOR_AMOUNT,
        l_okl_k_lines_h_rec.PREVIOUS_CONTRACT,
        l_okl_k_lines_h_rec.TRACKED_RESIDUAL,
        l_okl_k_lines_h_rec.DATE_TITLE_RECEIVED,
        l_okl_k_lines_h_rec.ESTIMATED_OEC,
        l_okl_k_lines_h_rec.RESIDUAL_PERCENTAGE,
        l_okl_k_lines_h_rec.CAPITAL_REDUCTION,
        l_okl_k_lines_h_rec.VENDOR_ADVANCE_PAID,
        l_okl_k_lines_h_rec.TRADEIN_AMOUNT,
        l_okl_k_lines_h_rec.DELIVERED_DATE,
        l_okl_k_lines_h_rec.YEAR_OF_MANUFACTURE,
        l_okl_k_lines_h_rec.INITIAL_DIRECT_COST,
        l_okl_k_lines_h_rec.OCCUPANCY,
        l_okl_k_lines_h_rec.DATE_LAST_INSPECTION,
        l_okl_k_lines_h_rec.DATE_NEXT_INSPECTION_DUE,
        l_okl_k_lines_h_rec.WEIGHTED_AVERAGE_LIFE,
        l_okl_k_lines_h_rec.BOND_EQUIVALENT_YIELD,
        l_okl_k_lines_h_rec.REFINANCE_AMOUNT,
        l_okl_k_lines_h_rec.YEAR_BUILT,
        l_okl_k_lines_h_rec.COVERAGE_RATIO,
        l_okl_k_lines_h_rec.GROSS_SQUARE_FOOTAGE,
        l_okl_k_lines_h_rec.NET_RENTABLE,
        l_okl_k_lines_h_rec.DATE_LETTER_ACCEPTANCE,
        l_okl_k_lines_h_rec.DATE_COMMITMENT_EXPIRATION,
        l_okl_k_lines_h_rec.DATE_APPRAISAL,
        l_okl_k_lines_h_rec.APPRAISAL_VALUE,
        l_okl_k_lines_h_rec.RESIDUAL_VALUE,
        l_okl_k_lines_h_rec.PERCENT,
        l_okl_k_lines_h_rec.COVERAGE,
        l_okl_k_lines_h_rec.LRV_AMOUNT,
        l_okl_k_lines_h_rec.AMOUNT,
        l_okl_k_lines_h_rec.LRS_PERCENT,
        l_okl_k_lines_h_rec.EVERGREEN_PERCENT,
        l_okl_k_lines_h_rec.PERCENT_STAKE,
        l_okl_k_lines_h_rec.AMOUNT_STAKE,
        l_okl_k_lines_h_rec.DATE_SOLD,
        l_okl_k_lines_h_rec.STY_ID_FOR,
        l_okl_k_lines_h_rec.ATTRIBUTE_CATEGORY,
        l_okl_k_lines_h_rec.ATTRIBUTE1,
        l_okl_k_lines_h_rec.ATTRIBUTE2,
        l_okl_k_lines_h_rec.ATTRIBUTE3,
        l_okl_k_lines_h_rec.ATTRIBUTE4,
        l_okl_k_lines_h_rec.ATTRIBUTE5,
        l_okl_k_lines_h_rec.ATTRIBUTE6,
        l_okl_k_lines_h_rec.ATTRIBUTE7,
        l_okl_k_lines_h_rec.ATTRIBUTE8,
        l_okl_k_lines_h_rec.ATTRIBUTE9,
        l_okl_k_lines_h_rec.ATTRIBUTE10,
        l_okl_k_lines_h_rec.ATTRIBUTE11,
        l_okl_k_lines_h_rec.ATTRIBUTE12,
        l_okl_k_lines_h_rec.ATTRIBUTE13,
        l_okl_k_lines_h_rec.ATTRIBUTE14,
        l_okl_k_lines_h_rec.ATTRIBUTE15,
        l_okl_k_lines_h_rec.CREATED_BY,
        l_okl_k_lines_h_rec.CREATION_DATE,
        l_okl_k_lines_h_rec.LAST_UPDATED_BY,
        l_okl_k_lines_h_rec.LAST_UPDATE_DATE,
        l_okl_k_lines_h_rec.LAST_UPDATE_LOGIN,
        l_okl_k_lines_h_rec.NTY_CODE,
        l_okl_k_lines_h_rec.FCG_CODE,
        l_okl_k_lines_h_rec.PRC_CODE,
        l_okl_k_lines_h_rec.RE_LEASE_YN,
        l_okl_k_lines_h_rec.PRESCRIBED_ASSET_YN,
        l_okl_k_lines_h_rec.CREDIT_TENANT_YN,
        l_okl_k_lines_h_rec.SECURED_DEAL_YN,
        l_okl_k_lines_h_rec.CLG_ID,
        l_okl_k_lines_h_rec.DATE_FUNDING,
        l_okl_k_lines_h_rec.DATE_FUNDING_REQUIRED,
        l_okl_k_lines_h_rec.DATE_ACCEPTED,
        l_okl_k_lines_h_rec.DATE_DELIVERY_EXPECTED,
        l_okl_k_lines_h_rec.OEC,
        l_okl_k_lines_h_rec.CAPITAL_AMOUNT,
        l_okl_k_lines_h_rec.RESIDUAL_GRNTY_AMOUNT,
        l_okl_k_lines_h_rec.RESIDUAL_CODE,
        l_okl_k_lines_h_rec.RVI_PREMIUM,
        l_okl_k_lines_h_rec.CREDIT_NATURE,
        l_okl_k_lines_h_rec.CAPITALIZED_INTEREST,
        l_okl_k_lines_h_rec.CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        l_okl_k_lines_h_rec.DATE_PAY_INVESTOR_START,
        l_okl_k_lines_h_rec.PAY_INVESTOR_FREQUENCY,
        l_okl_k_lines_h_rec.PAY_INVESTOR_EVENT,
        l_okl_k_lines_h_rec.PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        l_okl_k_lines_h_rec.FEE_TYPE,
--Bug# 3143522 : 11.5.10
--subsidy
   l_okl_k_lines_h_rec.SUBSIDY_ID,
   --l_okl_k_lines_h_rec.SUBSIDIZED_OEC,
   --l_okl_k_lines_h_rec.SUBSIDIZED_CAP_AMOUNT,
   l_okl_k_lines_h_rec.SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   l_okl_k_lines_h_rec.PRE_TAX_YIELD,
   l_okl_k_lines_h_rec.AFTER_TAX_YIELD,
   l_okl_k_lines_h_rec.IMPLICIT_INTEREST_RATE,
   l_okl_k_lines_h_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
   l_okl_k_lines_h_rec.PRE_TAX_IRR,
   l_okl_k_lines_h_rec.AFTER_TAX_IRR,
--quote
   l_okl_k_lines_h_rec.SUB_PRE_TAX_YIELD,
   l_okl_k_lines_h_rec.SUB_AFTER_TAX_YIELD,
   l_okl_k_lines_h_rec.SUB_IMPL_INTEREST_RATE,
   l_okl_k_lines_h_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_okl_k_lines_h_rec.SUB_PRE_TAX_IRR,
   l_okl_k_lines_h_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971
   l_okl_k_lines_h_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 11.5.10+
   l_okl_k_lines_h_rec.QTE_ID,
   l_okl_k_lines_h_rec.FUNDING_DATE,
   l_okl_k_lines_h_rec.STREAM_TYPE_SUBCLASS,
   --Bug# 4419339 OKLH
   l_okl_k_lines_h_rec.DATE_FUNDING_EXPECTED,
   l_okl_k_lines_h_rec.MANUFACTURER_NAME,
   l_okl_k_lines_h_rec.MODEL_NUMBER,
   l_okl_k_lines_h_rec.DOWN_PAYMENT_RECEIVER_CODE,
   l_okl_k_lines_h_rec.CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   l_okl_k_lines_h_rec.FEE_PURPOSE_CODE,
   l_okl_k_lines_h_rec.TERMINATION_VALUE,
--Bug# 4631549
   l_okl_k_lines_h_rec.EXPECTED_ASSET_COST,
   l_okl_k_lines_h_rec.ORIG_CONTRACT_LINE_ID
         ;
    x_no_data_found := okl_k_lines_h_pk_csr%NOTFOUND;
    CLOSE okl_k_lines_h_pk_csr;
    RETURN(l_okl_k_lines_h_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_k_lines_h_rec                     IN okl_k_lines_h_rec_type
  ) RETURN okl_k_lines_h_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_k_lines_h_rec, l_row_notfound));
  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_K_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_klev_rec                     IN klev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN klev_rec_type IS
    CURSOR okl_k_lines_v_pk_csr (p_id                 IN NUMBER) IS
      SELECT
	ID,
        OBJECT_VERSION_NUMBER,
        KLE_ID,
        STY_ID,
        PRC_CODE,
        FCG_CODE,
        NTY_CODE,
        ESTIMATED_OEC,
        LAO_AMOUNT,
        TITLE_DATE,
        FEE_CHARGE,
        LRS_PERCENT,
        INITIAL_DIRECT_COST,
        PERCENT_STAKE,
        PERCENT,
        EVERGREEN_PERCENT,
        AMOUNT_STAKE,
        OCCUPANCY,
        COVERAGE,
        RESIDUAL_PERCENTAGE,
        DATE_LAST_INSPECTION,
        DATE_SOLD,
        LRV_AMOUNT,
        CAPITAL_REDUCTION,
        DATE_NEXT_INSPECTION_DUE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        VENDOR_ADVANCE_PAID,
        WEIGHTED_AVERAGE_LIFE,
        TRADEIN_AMOUNT,
        BOND_EQUIVALENT_YIELD,
        TERMINATION_PURCHASE_AMOUNT,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        DELIVERED_DATE,
        CREDIT_TENANT_YN,
        DATE_LAST_CLEANUP,
        YEAR_OF_MANUFACTURE,
        COVERAGE_RATIO,
        REMARKETED_AMOUNT,
        GROSS_SQUARE_FOOTAGE,
        PRESCRIBED_ASSET_YN,
        DATE_REMARKETED,
        NET_RENTABLE,
        REMARKET_MARGIN,
        DATE_LETTER_ACCEPTANCE,
        REPURCHASED_AMOUNT,
        DATE_COMMITMENT_EXPIRATION,
        DATE_REPURCHASED,
        DATE_APPRAISAL,
        RESIDUAL_VALUE,
        APPRAISAL_VALUE,
        SECURED_DEAL_YN,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        RE_LEASE_YN,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        AMOUNT,
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
        STY_ID_FOR,
        CLG_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug#3143522 : 11.5.10
--subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
--financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--Bug# 2994971
   ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339 OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID


      FROM OKL_K_LINES_V
      WHERE OKL_K_LINES_V.id     = p_id;
      l_okl_k_lines_v_pk             okl_k_lines_v_pk_csr%ROWTYPE;
      l_klev_rec                      klev_rec_type;
  BEGIN

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_k_lines_v_pk_csr (p_klev_rec.id);
    FETCH okl_k_lines_v_pk_csr INTO
       l_klev_rec.ID,
        l_klev_rec.OBJECT_VERSION_NUMBER,
        l_klev_rec.KLE_ID,
        l_klev_rec.STY_ID,
        l_klev_rec.PRC_CODE,
        l_klev_rec.FCG_CODE,
        l_klev_rec.NTY_CODE,
        l_klev_rec.ESTIMATED_OEC,
        l_klev_rec.LAO_AMOUNT,
        l_klev_rec.TITLE_DATE,
        l_klev_rec.FEE_CHARGE,
        l_klev_rec.LRS_PERCENT,
        l_klev_rec.INITIAL_DIRECT_COST,
        l_klev_rec.PERCENT_STAKE,
        l_klev_rec.PERCENT,
        l_klev_rec.EVERGREEN_PERCENT,
        l_klev_rec.AMOUNT_STAKE,
        l_klev_rec.OCCUPANCY,
        l_klev_rec.COVERAGE,
        l_klev_rec.RESIDUAL_PERCENTAGE,
        l_klev_rec.DATE_LAST_INSPECTION,
        l_klev_rec.DATE_SOLD,
        l_klev_rec.LRV_AMOUNT,
        l_klev_rec.CAPITAL_REDUCTION,
        l_klev_rec.DATE_NEXT_INSPECTION_DUE,
        l_klev_rec.DATE_RESIDUAL_LAST_REVIEW,
        l_klev_rec.DATE_LAST_REAMORTISATION,
        l_klev_rec.VENDOR_ADVANCE_PAID,
        l_klev_rec.WEIGHTED_AVERAGE_LIFE,
        l_klev_rec.TRADEIN_AMOUNT,
        l_klev_rec.BOND_EQUIVALENT_YIELD,
        l_klev_rec.TERMINATION_PURCHASE_AMOUNT,
        l_klev_rec.REFINANCE_AMOUNT,
        l_klev_rec.YEAR_BUILT,
        l_klev_rec.DELIVERED_DATE,
        l_klev_rec.CREDIT_TENANT_YN,
        l_klev_rec.DATE_LAST_CLEANUP,
        l_klev_rec.YEAR_OF_MANUFACTURE,
        l_klev_rec.COVERAGE_RATIO,
        l_klev_rec.REMARKETED_AMOUNT,
        l_klev_rec.GROSS_SQUARE_FOOTAGE,
        l_klev_rec.PRESCRIBED_ASSET_YN,
        l_klev_rec.DATE_REMARKETED,
        l_klev_rec.NET_RENTABLE,
        l_klev_rec.REMARKET_MARGIN,
        l_klev_rec.DATE_LETTER_ACCEPTANCE,
        l_klev_rec.REPURCHASED_AMOUNT,
        l_klev_rec.DATE_COMMITMENT_EXPIRATION,
        l_klev_rec.DATE_REPURCHASED,
        l_klev_rec.DATE_APPRAISAL,
        l_klev_rec.RESIDUAL_VALUE,
        l_klev_rec.APPRAISAL_VALUE,
        l_klev_rec.SECURED_DEAL_YN,
        l_klev_rec.GAIN_LOSS,
        l_klev_rec.FLOOR_AMOUNT,
        l_klev_rec.RE_LEASE_YN,
        l_klev_rec.PREVIOUS_CONTRACT,
        l_klev_rec.TRACKED_RESIDUAL,
        l_klev_rec.DATE_TITLE_RECEIVED,
        l_klev_rec.AMOUNT,
        l_klev_rec.ATTRIBUTE_CATEGORY,
        l_klev_rec.ATTRIBUTE1,
        l_klev_rec.ATTRIBUTE2,
        l_klev_rec.ATTRIBUTE3,
        l_klev_rec.ATTRIBUTE4,
        l_klev_rec.ATTRIBUTE5,
        l_klev_rec.ATTRIBUTE6,
        l_klev_rec.ATTRIBUTE7,
        l_klev_rec.ATTRIBUTE8,
        l_klev_rec.ATTRIBUTE9,
        l_klev_rec.ATTRIBUTE10,
        l_klev_rec.ATTRIBUTE11,
        l_klev_rec.ATTRIBUTE12,
        l_klev_rec.ATTRIBUTE13,
        l_klev_rec.ATTRIBUTE14,
        l_klev_rec.ATTRIBUTE15,
        l_klev_rec.STY_ID_FOR,
        l_klev_rec.CLG_ID,
        l_klev_rec.CREATED_BY,
        l_klev_rec.CREATION_DATE,
        l_klev_rec.LAST_UPDATED_BY,
        l_klev_rec.LAST_UPDATE_DATE,
        l_klev_rec.LAST_UPDATE_LOGIN,
        l_klev_rec.DATE_FUNDING,
        l_klev_rec.DATE_FUNDING_REQUIRED,
        l_klev_rec.DATE_ACCEPTED,
        l_klev_rec.DATE_DELIVERY_EXPECTED,
        l_klev_rec.OEC,
        l_klev_rec.CAPITAL_AMOUNT,
        l_klev_rec.RESIDUAL_GRNTY_AMOUNT,
        l_klev_rec.RESIDUAL_CODE,
        l_klev_rec.RVI_PREMIUM,
        l_klev_rec.CREDIT_NATURE,
        l_klev_rec.CAPITALIZED_INTEREST,
        l_klev_rec.CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        l_klev_rec.DATE_PAY_INVESTOR_START,
        l_klev_rec.PAY_INVESTOR_FREQUENCY,
        l_klev_rec.PAY_INVESTOR_EVENT,
        l_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        l_klev_rec.FEE_TYPE,
--Bug# 3143522 : 11.5.10
--subsidy
   l_klev_rec.SUBSIDY_ID,
   --l_klev_rec.SUBSIDIZED_OEC,
   --l_klev_rec.SUBSIDIZED_CAP_AMOUNT,
   l_klev_rec.SUBSIDY_OVERRIDE_AMOUNT,
--financed fee
   l_klev_rec.PRE_TAX_YIELD,
   l_klev_rec.AFTER_TAX_YIELD,
   l_klev_rec.IMPLICIT_INTEREST_RATE,
   l_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
   l_klev_rec.PRE_TAX_IRR,
   l_klev_rec.AFTER_TAX_IRR,
--quote
   l_klev_rec.SUB_PRE_TAX_YIELD,
   l_klev_rec.SUB_AFTER_TAX_YIELD,
   l_klev_rec.SUB_IMPL_INTEREST_RATE,
   l_klev_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_klev_rec.SUB_PRE_TAX_IRR,
   l_klev_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971
   l_klev_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 - 11.5.10+
   l_klev_rec.QTE_ID,
   l_klev_rec.FUNDING_DATE,
   l_klev_rec.STREAM_TYPE_SUBCLASS,
--Bug# 4419339 OKLH
   l_klev_rec.DATE_FUNDING_EXPECTED,
   l_klev_rec.MANUFACTURER_NAME,
   l_klev_rec.MODEL_NUMBER,
   l_klev_rec.DOWN_PAYMENT_RECEIVER_CODE,
   l_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   l_klev_rec.FEE_PURPOSE_CODE,
   l_klev_rec.TERMINATION_VALUE,
--Bug# 4631549
   l_klev_rec.EXPECTED_ASSET_COST,
   l_klev_rec.ORIG_CONTRACT_LINE_ID
;
    x_no_data_found := okl_k_lines_v_pk_csr%NOTFOUND;
    CLOSE okl_k_lines_v_pk_csr;
    RETURN(l_klev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_klev_rec                     IN klev_rec_type
  ) RETURN klev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_klev_rec, l_row_notfound));
  END get_rec;


  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_K_LINES_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_klev_rec                     IN klev_rec_type
  ) RETURN klev_rec_type IS
    l_klev_rec	klev_rec_type := p_klev_rec;
  BEGIN

    IF (l_klev_rec.ID = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.ID := NULL;
    END IF;

    IF (l_klev_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.OBJECT_VERSION_NUMBER := NULL;
    END IF;

    IF (l_klev_rec.KLE_ID = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.KLE_ID := NULL;
    END IF;

    IF (l_klev_rec.STY_ID = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.STY_ID := NULL;
    END IF;

    IF (l_klev_rec.PRC_CODE = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.PRC_CODE := NULL;
    END IF;

    IF (l_klev_rec.FCG_CODE = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.FCG_CODE := NULL;
    END IF;

    IF (l_klev_rec.NTY_CODE = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.NTY_CODE := NULL;
    END IF;

    IF (l_klev_rec.ESTIMATED_OEC = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.ESTIMATED_OEC := NULL;
    END IF;

    IF (l_klev_rec.LAO_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.LAO_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.TITLE_DATE = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.TITLE_DATE := NULL;
    END IF;

    IF (l_klev_rec.FEE_CHARGE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.FEE_CHARGE := NULL;
    END IF;

    IF (l_klev_rec.LRS_PERCENT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.LRS_PERCENT := NULL;
    END IF;

    IF (l_klev_rec.INITIAL_DIRECT_COST = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.INITIAL_DIRECT_COST := NULL;
    END IF;

    IF (l_klev_rec.PERCENT_STAKE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.PERCENT_STAKE := NULL;
    END IF;

    IF (l_klev_rec.PERCENT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.PERCENT := NULL;
    END IF;

    IF (l_klev_rec.EVERGREEN_PERCENT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.EVERGREEN_PERCENT := NULL;
    END IF;

    IF (l_klev_rec.AMOUNT_STAKE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.AMOUNT_STAKE := NULL;
    END IF;

    IF (l_klev_rec.OCCUPANCY = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.OCCUPANCY := NULL;
    END IF;

    IF (l_klev_rec.COVERAGE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.COVERAGE := NULL;
    END IF;

    IF (l_klev_rec.RESIDUAL_PERCENTAGE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.RESIDUAL_PERCENTAGE := NULL;
    END IF;

    IF (l_klev_rec.DATE_LAST_INSPECTION = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_LAST_INSPECTION := NULL;
    END IF;

    IF (l_klev_rec.DATE_SOLD = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_SOLD := NULL;
    END IF;

    IF (l_klev_rec.LRV_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.LRV_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.CAPITAL_REDUCTION = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.CAPITAL_REDUCTION := NULL;
    END IF;

    IF (l_klev_rec.DATE_NEXT_INSPECTION_DUE = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_NEXT_INSPECTION_DUE := NULL;
    END IF;

    IF (l_klev_rec.DATE_RESIDUAL_LAST_REVIEW = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_RESIDUAL_LAST_REVIEW := NULL;
    END IF;

    IF (l_klev_rec.DATE_LAST_REAMORTISATION = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_LAST_REAMORTISATION := NULL;
    END IF;

    IF (l_klev_rec.VENDOR_ADVANCE_PAID = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.VENDOR_ADVANCE_PAID := NULL;
    END IF;

    IF (l_klev_rec.WEIGHTED_AVERAGE_LIFE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.WEIGHTED_AVERAGE_LIFE := NULL;
    END IF;

    IF (l_klev_rec.TRADEIN_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.TRADEIN_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.BOND_EQUIVALENT_YIELD = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.BOND_EQUIVALENT_YIELD := NULL;
    END IF;

    IF (l_klev_rec.TERMINATION_PURCHASE_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.TERMINATION_PURCHASE_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.REFINANCE_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.REFINANCE_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.YEAR_BUILT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.YEAR_BUILT := NULL;
    END IF;

    IF (l_klev_rec.DELIVERED_DATE = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DELIVERED_DATE := NULL;
    END IF;

    IF (l_klev_rec.CREDIT_TENANT_YN = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.CREDIT_TENANT_YN := NULL;
    END IF;

    IF (l_klev_rec.DATE_LAST_CLEANUP = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_LAST_CLEANUP := NULL;
    END IF;

    IF (l_klev_rec.YEAR_OF_MANUFACTURE = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.YEAR_OF_MANUFACTURE := NULL;
    END IF;

    IF (l_klev_rec.COVERAGE_RATIO = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.COVERAGE_RATIO := NULL;
    END IF;

    IF (l_klev_rec.REMARKETED_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.REMARKETED_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.GROSS_SQUARE_FOOTAGE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.GROSS_SQUARE_FOOTAGE := NULL;
    END IF;

    IF (l_klev_rec.PRESCRIBED_ASSET_YN = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.PRESCRIBED_ASSET_YN := NULL;
    END IF;

    IF (l_klev_rec.DATE_REMARKETED = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_REMARKETED := NULL;
    END IF;

    IF (l_klev_rec.NET_RENTABLE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.NET_RENTABLE := NULL;
    END IF;

    IF (l_klev_rec.REMARKET_MARGIN = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.REMARKET_MARGIN := NULL;
    END IF;

    IF (l_klev_rec.DATE_LETTER_ACCEPTANCE = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_LETTER_ACCEPTANCE := NULL;
    END IF;

    IF (l_klev_rec.REPURCHASED_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.REPURCHASED_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.DATE_COMMITMENT_EXPIRATION = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_COMMITMENT_EXPIRATION := NULL;
    END IF;

    IF (l_klev_rec.DATE_REPURCHASED = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_REPURCHASED := NULL;
    END IF;

    IF (l_klev_rec.DATE_APPRAISAL = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_APPRAISAL := NULL;
    END IF;

    IF (l_klev_rec.RESIDUAL_VALUE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.RESIDUAL_VALUE := NULL;
    END IF;

    IF (l_klev_rec.APPRAISAL_VALUE = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.APPRAISAL_VALUE := NULL;
    END IF;

    IF (l_klev_rec.SECURED_DEAL_YN = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.SECURED_DEAL_YN := NULL;
    END IF;

    IF (l_klev_rec.GAIN_LOSS = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.GAIN_LOSS := NULL;
    END IF;

    IF (l_klev_rec.FLOOR_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.FLOOR_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.RE_LEASE_YN = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.RE_LEASE_YN := NULL;
    END IF;

    IF (l_klev_rec.PREVIOUS_CONTRACT = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.PREVIOUS_CONTRACT := NULL;
    END IF;

    IF (l_klev_rec.TRACKED_RESIDUAL = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.TRACKED_RESIDUAL := NULL;
    END IF;

    IF (l_klev_rec.DATE_TITLE_RECEIVED = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_TITLE_RECEIVED := NULL;
    END IF;

    IF (l_klev_rec.AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE_CATEGORY = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE1 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE2 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE3 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE4 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE5 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE6 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE7 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE8 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE9 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE10 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE11 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE12 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE13 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE14 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF (l_klev_rec.ATTRIBUTE15 = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.ATTRIBUTE15 := NULL;
    END IF;

    IF (l_klev_rec.STY_ID_FOR = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.STY_ID_FOR := NULL;
    END IF;

    IF (l_klev_rec.CLG_ID = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.CLG_ID := NULL;
    END IF;

    IF (l_klev_rec.CREATED_BY = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.CREATED_BY := NULL;
    END IF;

    IF (l_klev_rec.CREATION_DATE = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.CREATION_DATE := NULL;
    END IF;

    IF (l_klev_rec.LAST_UPDATED_BY = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF (l_klev_rec.LAST_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    IF (l_klev_rec.LAST_UPDATE_LOGIN = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF (l_klev_rec.DATE_FUNDING = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_FUNDING := NULL;
    END IF;

    IF (l_klev_rec.DATE_FUNDING_REQUIRED = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_FUNDING_REQUIRED := NULL;
    END IF;

    IF (l_klev_rec.DATE_ACCEPTED = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_ACCEPTED := NULL;
    END IF;

    IF (l_klev_rec.DATE_DELIVERY_EXPECTED = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_DELIVERY_EXPECTED := NULL;
    END IF;

    IF (l_klev_rec.OEC = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.OEC := NULL;
    END IF;

    IF (l_klev_rec.CAPITAL_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.CAPITAL_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.RESIDUAL_GRNTY_AMOUNT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.RESIDUAL_GRNTY_AMOUNT := NULL;
    END IF;

    IF (l_klev_rec.RESIDUAL_CODE = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.RESIDUAL_CODE := NULL;
    END IF;

    IF (l_klev_rec.RVI_PREMIUM = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.RVI_PREMIUM := NULL;
    END IF;

    IF (l_klev_rec.CREDIT_NATURE = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.CREDIT_NATURE := NULL;
    END IF;

    IF (l_klev_rec.CAPITALIZED_INTEREST = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.CAPITALIZED_INTEREST := NULL;
    END IF;

    IF (l_klev_rec.CAPITAL_REDUCTION_PERCENT = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.CAPITAL_REDUCTION_PERCENT := NULL;
    END IF;

    IF (l_klev_rec.DATE_PAY_INVESTOR_START = OKC_API.G_MISS_DATE) THEN
      l_klev_rec.DATE_PAY_INVESTOR_START := NULL;
    END IF;

    IF (l_klev_rec.PAY_INVESTOR_FREQUENCY = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.PAY_INVESTOR_FREQUENCY := NULL;
    END IF;

    IF (l_klev_rec.PAY_INVESTOR_EVENT = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.PAY_INVESTOR_EVENT := NULL;
    END IF;

    IF (l_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS   = OKC_API.G_MISS_NUM) THEN
      l_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS   := NULL;
    END IF;

    IF (l_klev_rec.FEE_TYPE   = OKC_API.G_MISS_CHAR) THEN
      l_klev_rec.FEE_TYPE   := NULL;
    END IF;
--Bug# 3143522: 11.5.10
--subsidy
   IF (l_klev_rec.SUBSIDY_ID = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUBSIDY_ID := NULL;
   END IF;
   --IF (l_klev_rec.SUBSIDIZED_OEC = OKL_API.G_MISS_NUM) THEN
       --l_klev_rec.SUBSIDIZED_OEC := NULL;
   --END IF;
   --IF (l_klev_rec.SUBSIDIZED_CAP_AMOUNT = OKL_API.G_MISS_NUM) THEN
       --l_klev_rec.SUBSIDIZED_CAP_AMOUNT := NULL;
   --END IF;
   IF (l_klev_rec.SUBSIDY_OVERRIDE_AMOUNT = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUBSIDY_OVERRIDE_AMOUNT := NULL;
   END IF;
   --financed fee
   IF (l_klev_rec.PRE_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.PRE_TAX_YIELD := NULL;
   END IF;
   IF (l_klev_rec.AFTER_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.AFTER_TAX_YIELD := NULL;
   END IF;
   IF (l_klev_rec.IMPLICIT_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.IMPLICIT_INTEREST_RATE := NULL;
   END IF;
   IF (l_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE := NULL;
   END IF;
   IF (l_klev_rec.PRE_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.PRE_TAX_IRR := NULL;
   END IF;
   IF (l_klev_rec.AFTER_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.AFTER_TAX_IRR := NULL;
   END IF;
--quote
   IF (l_klev_rec.SUB_PRE_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUB_PRE_TAX_YIELD := NULL;
   END IF;
   IF (l_klev_rec.SUB_AFTER_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUB_AFTER_TAX_YIELD := NULL;
   END IF;
   IF (l_klev_rec.SUB_IMPL_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUB_IMPL_INTEREST_RATE := NULL;
   END IF;
   IF (l_klev_rec.SUB_IMPL_NON_IDC_INT_RATE = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUB_IMPL_NON_IDC_INT_RATE := NULL;
   END IF;
   IF (l_klev_rec.SUB_PRE_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUB_PRE_TAX_IRR := NULL;
   END IF;
   IF (l_klev_rec.SUB_AFTER_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.SUB_AFTER_TAX_IRR := NULL;
   END IF;
--Bug# 2994971 :
   IF (l_klev_rec.ITEM_INSURANCE_CATEGORY = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.ITEM_INSURANCE_CATEGORY := NULL;
   END IF;
--Bug# 3973640 11.5.10+
   IF (l_klev_rec.QTE_ID = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.QTE_ID := NULL;
   END IF;
   IF (l_klev_rec.FUNDING_DATE = OKL_API.G_MISS_DATE) THEN
       l_klev_rec.FUNDING_DATE := NULL;
   END IF;
   IF (l_klev_rec.STREAM_TYPE_SUBCLASS = OKL_API.G_MISS_CHAR) THEN
       l_klev_rec.STREAM_TYPE_SUBCLASS := NULL;
   END IF;

--Bug# 4419339 OKLH
   IF (l_klev_rec.DATE_FUNDING_EXPECTED = OKL_API.G_MISS_DATE) THEN
       l_klev_rec.DATE_FUNDING_EXPECTED := NULL;
   END IF;

   IF (l_klev_rec.MANUFACTURER_NAME = OKL_API.G_MISS_CHAR) THEN
       l_klev_rec.MANUFACTURER_NAME := NULL;
   END IF;

   IF (l_klev_rec.MODEL_NUMBER = OKL_API.G_MISS_CHAR) THEN
       l_klev_rec.MODEL_NUMBER := NULL;
   END IF;

   IF (l_klev_rec.DOWN_PAYMENT_RECEIVER_CODE = OKL_API.G_MISS_CHAR) THEN
       l_klev_rec.DOWN_PAYMENT_RECEIVER_CODE := NULL;
   END IF;

   IF (l_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN = OKL_API.G_MISS_CHAR) THEN
       l_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN := NULL;
   END IF;
--Bug#4373029
   IF (l_klev_rec.FEE_PURPOSE_CODE = OKL_API.G_MISS_CHAR) THEN
       l_klev_rec.FEE_PURPOSE_CODE := NULL;
   END IF;

   IF (l_klev_rec.TERMINATION_VALUE = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.TERMINATION_VALUE := NULL;
   END IF;

   --Bug# 4631549
   IF (l_klev_rec.EXPECTED_ASSET_COST = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.EXPECTED_ASSET_COST := NULL;
   END IF;

   IF (l_klev_rec.ORIG_CONTRACT_LINE_ID = OKL_API.G_MISS_NUM) THEN
       l_klev_rec.ORIG_CONTRACT_LINE_ID := NULL;
   END IF;

   RETURN(l_klev_rec);
  END null_out_defaults;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------


  -----------------------------------------
  -- Validate_Record for: OKL_K_LINES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_klev_rec                     IN klev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------

  PROCEDURE migrate (
    p_from	IN klev_rec_type,
    p_to	IN OUT NOCOPY kle_rec_type
  ) IS
  BEGIN

      p_to.ID := p_from.ID;

      p_to.KLE_ID := p_from.KLE_ID;

      p_to.STY_ID := p_from.STY_ID;

      p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;

      p_to.LAO_AMOUNT := p_from.LAO_AMOUNT;

      p_to.FEE_CHARGE := p_from.FEE_CHARGE;

      p_to.TITLE_DATE := p_from.TITLE_DATE;

      p_to.DATE_RESIDUAL_LAST_REVIEW := p_from.DATE_RESIDUAL_LAST_REVIEW;

      p_to.DATE_LAST_REAMORTISATION := p_from.DATE_LAST_REAMORTISATION;

      p_to.TERMINATION_PURCHASE_AMOUNT := p_from.TERMINATION_PURCHASE_AMOUNT;

      p_to.DATE_LAST_CLEANUP := p_from.DATE_LAST_CLEANUP;

      p_to.REMARKETED_AMOUNT := p_from.REMARKETED_AMOUNT;

      p_to.DATE_REMARKETED := p_from.DATE_REMARKETED;

      p_to.REMARKET_MARGIN := p_from.REMARKET_MARGIN;

      p_to.REPURCHASED_AMOUNT := p_from.REPURCHASED_AMOUNT;

      p_to.DATE_REPURCHASED := p_from.DATE_REPURCHASED;

      p_to.GAIN_LOSS := p_from.GAIN_LOSS;

      p_to.FLOOR_AMOUNT := p_from.FLOOR_AMOUNT;

      p_to.PREVIOUS_CONTRACT := p_from.PREVIOUS_CONTRACT;

      p_to.TRACKED_RESIDUAL := p_from.TRACKED_RESIDUAL;

      p_to.DATE_TITLE_RECEIVED := p_from.DATE_TITLE_RECEIVED;

      p_to.ESTIMATED_OEC := p_from.ESTIMATED_OEC;

      p_to.RESIDUAL_PERCENTAGE := p_from.RESIDUAL_PERCENTAGE;

      p_to.CAPITAL_REDUCTION := p_from.CAPITAL_REDUCTION;

      p_to.VENDOR_ADVANCE_PAID := p_from.VENDOR_ADVANCE_PAID;

      p_to.TRADEIN_AMOUNT := p_from.TRADEIN_AMOUNT;

      p_to.DELIVERED_DATE := p_from.DELIVERED_DATE;

      p_to.YEAR_OF_MANUFACTURE := p_from.YEAR_OF_MANUFACTURE;

      p_to.INITIAL_DIRECT_COST := p_from.INITIAL_DIRECT_COST;

      p_to.OCCUPANCY := p_from.OCCUPANCY;

      p_to.DATE_LAST_INSPECTION := p_from.DATE_LAST_INSPECTION;

      p_to.DATE_NEXT_INSPECTION_DUE := p_from.DATE_NEXT_INSPECTION_DUE;

      p_to.WEIGHTED_AVERAGE_LIFE := p_from.WEIGHTED_AVERAGE_LIFE;

      p_to.BOND_EQUIVALENT_YIELD := p_from.BOND_EQUIVALENT_YIELD;

      p_to.REFINANCE_AMOUNT := p_from.REFINANCE_AMOUNT;

      p_to.YEAR_BUILT := p_from.YEAR_BUILT;

      p_to.COVERAGE_RATIO := p_from.COVERAGE_RATIO;

      p_to.GROSS_SQUARE_FOOTAGE := p_from.GROSS_SQUARE_FOOTAGE;

      p_to.NET_RENTABLE := p_from.NET_RENTABLE;

      p_to.DATE_LETTER_ACCEPTANCE := p_from.DATE_LETTER_ACCEPTANCE;

      p_to.DATE_COMMITMENT_EXPIRATION := p_from.DATE_COMMITMENT_EXPIRATION;

      p_to.DATE_APPRAISAL := p_from.DATE_APPRAISAL;

      p_to.APPRAISAL_VALUE := p_from.APPRAISAL_VALUE;

      p_to.RESIDUAL_VALUE := p_from.RESIDUAL_VALUE;

      p_to.PERCENT := p_from.PERCENT;

      p_to.COVERAGE := p_from.COVERAGE;

      p_to.LRV_AMOUNT := p_from.LRV_AMOUNT;

      p_to.AMOUNT := p_from.AMOUNT;

      p_to.LRS_PERCENT := p_from.LRS_PERCENT;

      p_to.EVERGREEN_PERCENT := p_from.EVERGREEN_PERCENT;

      p_to.PERCENT_STAKE := p_from.PERCENT_STAKE;

      p_to.AMOUNT_STAKE := p_from.AMOUNT_STAKE;

      p_to.DATE_SOLD := p_from.DATE_SOLD;

      p_to.STY_ID_FOR := p_from.STY_ID_FOR;

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

      p_to.NTY_CODE := p_from.NTY_CODE;

      p_to.FCG_CODE := p_from.FCG_CODE;

      p_to.PRC_CODE := p_from.PRC_CODE;

      p_to.RE_LEASE_YN := p_from.RE_LEASE_YN;

      p_to.PRESCRIBED_ASSET_YN := p_from.PRESCRIBED_ASSET_YN;

      p_to.CREDIT_TENANT_YN := p_from.CREDIT_TENANT_YN;

      p_to.SECURED_DEAL_YN := p_from.SECURED_DEAL_YN;

      p_to.CLG_ID := p_from.CLG_ID;

      p_to.DATE_FUNDING := p_from.DATE_FUNDING;

      p_to.DATE_FUNDING_REQUIRED := p_from.DATE_FUNDING_REQUIRED;

      p_to.DATE_ACCEPTED := p_from.DATE_ACCEPTED;

      p_to.DATE_DELIVERY_EXPECTED := p_from.DATE_DELIVERY_EXPECTED;

      p_to.OEC := p_from.OEC;

      p_to.CAPITAL_AMOUNT := p_from.CAPITAL_AMOUNT;

      p_to.RESIDUAL_GRNTY_AMOUNT := p_from.RESIDUAL_GRNTY_AMOUNT;

      p_to.RESIDUAL_CODE := p_from.RESIDUAL_CODE;

      p_to.RVI_PREMIUM := p_from.RVI_PREMIUM;

      p_to.CREDIT_NATURE := p_from.CREDIT_NATURE;

      p_to.CAPITALIZED_INTEREST := p_from.CAPITALIZED_INTEREST;

      p_to.CAPITAL_REDUCTION_PERCENT := p_from.CAPITAL_REDUCTION_PERCENT;

      p_to.DATE_PAY_INVESTOR_START := p_from.DATE_PAY_INVESTOR_START;

      p_to.PAY_INVESTOR_FREQUENCY := p_from.PAY_INVESTOR_FREQUENCY;

      p_to.PAY_INVESTOR_EVENT := p_from.PAY_INVESTOR_EVENT;

      p_to.PAY_INVESTOR_REMITTANCE_DAYS := p_from.PAY_INVESTOR_REMITTANCE_DAYS;
      p_to.FEE_TYPE := p_from.FEE_TYPE;
--Bug# 3143522: 11.5.10
--subsidy
   p_to.SUBSIDY_ID := p_from.SUBSIDY_ID;
   --p_to.SUBSIDIZED_OEC := p_from.SUBSIDIZED_OEC;
   --p_to.SUBSIDIZED_CAP_AMOUNT := p_from.SUBSIDIZED_CAP_AMOUNT;
   p_to.SUBSIDY_OVERRIDE_AMOUNT := p_from.SUBSIDY_OVERRIDE_AMOUNT;
   --financed fee
   p_to.PRE_TAX_YIELD := p_from.PRE_TAX_YIELD;
   p_to.AFTER_TAX_YIELD := p_from.AFTER_TAX_YIELD;
   p_to.IMPLICIT_INTEREST_RATE := p_from.IMPLICIT_INTEREST_RATE;
   p_to.IMPLICIT_NON_IDC_INTEREST_RATE := p_from.IMPLICIT_NON_IDC_INTEREST_RATE;
   p_to.PRE_TAX_IRR := p_from.PRE_TAX_IRR;
   p_to.AFTER_TAX_IRR := p_from.AFTER_TAX_IRR;
--quote
   p_to.SUB_PRE_TAX_YIELD := p_from.SUB_PRE_TAX_YIELD;
   p_to.SUB_AFTER_TAX_YIELD := p_from.SUB_AFTER_TAX_YIELD;
   p_to.SUB_IMPL_INTEREST_RATE := p_from.SUB_IMPL_INTEREST_RATE;
   p_to.SUB_IMPL_NON_IDC_INT_RATE := p_from.SUB_IMPL_NON_IDC_INT_RATE;
   p_to.SUB_PRE_TAX_IRR := p_from.SUB_PRE_TAX_IRR;
   p_to.SUB_AFTER_TAX_IRR := p_from.SUB_AFTER_TAX_IRR;
--Bug# 2994971
   p_to.ITEM_INSURANCE_CATEGORY := p_from.ITEM_INSURANCE_CATEGORY;
--Bug# 3973640 11.5.10+
   p_to.QTE_ID := p_from.QTE_ID;
   p_to.FUNDING_DATE := p_from.FUNDING_DATE;
   p_to.STREAM_TYPE_SUBCLASS := p_from.STREAM_TYPE_SUBCLASS;

--Bug# 4419339  OKLH
   p_to.DATE_FUNDING_EXPECTED := p_from.DATE_FUNDING_EXPECTED;
   p_to.MANUFACTURER_NAME := p_from.MANUFACTURER_NAME;
   p_to.MODEL_NUMBER := p_from.MODEL_NUMBER;
   p_to.DOWN_PAYMENT_RECEIVER_CODE := p_from.DOWN_PAYMENT_RECEIVER_CODE;
   p_to.CAPITALIZE_DOWN_PAYMENT_YN := p_from.CAPITALIZE_DOWN_PAYMENT_YN;
--Bug#4373029
   p_to.FEE_PURPOSE_CODE := p_from.FEE_PURPOSE_CODE;
   p_to.TERMINATION_VALUE := p_from.TERMINATION_VALUE;
--Bug# 4631549
   p_to.EXPECTED_ASSET_COST := p_from.EXPECTED_ASSET_COST;
   p_to.ORIG_CONTRACT_LINE_ID := p_from.ORIG_CONTRACT_LINE_ID;

  END migrate;

  PROCEDURE migrate (
    p_from	IN kle_rec_type,
    p_to	IN OUT NOCOPY klev_rec_type
  ) IS
  BEGIN

      p_to.ID := p_from.ID;

      p_to.KLE_ID := p_from.KLE_ID;

      p_to.STY_ID := p_from.STY_ID;

      p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;

      p_to.LAO_AMOUNT := p_from.LAO_AMOUNT;

      p_to.FEE_CHARGE := p_from.FEE_CHARGE;

      p_to.TITLE_DATE := p_from.TITLE_DATE;

      p_to.DATE_RESIDUAL_LAST_REVIEW := p_from.DATE_RESIDUAL_LAST_REVIEW;

      p_to.DATE_LAST_REAMORTISATION := p_from.DATE_LAST_REAMORTISATION;

      p_to.TERMINATION_PURCHASE_AMOUNT := p_from.TERMINATION_PURCHASE_AMOUNT;

      p_to.DATE_LAST_CLEANUP := p_from.DATE_LAST_CLEANUP;

      p_to.REMARKETED_AMOUNT := p_from.REMARKETED_AMOUNT;

      p_to.DATE_REMARKETED := p_from.DATE_REMARKETED;

      p_to.REMARKET_MARGIN := p_from.REMARKET_MARGIN;

      p_to.REPURCHASED_AMOUNT := p_from.REPURCHASED_AMOUNT;

      p_to.DATE_REPURCHASED := p_from.DATE_REPURCHASED;

      p_to.GAIN_LOSS := p_from.GAIN_LOSS;

      p_to.FLOOR_AMOUNT := p_from.FLOOR_AMOUNT;

      p_to.PREVIOUS_CONTRACT := p_from.PREVIOUS_CONTRACT;

      p_to.TRACKED_RESIDUAL := p_from.TRACKED_RESIDUAL;

      p_to.DATE_TITLE_RECEIVED := p_from.DATE_TITLE_RECEIVED;

      p_to.ESTIMATED_OEC := p_from.ESTIMATED_OEC;

      p_to.RESIDUAL_PERCENTAGE := p_from.RESIDUAL_PERCENTAGE;

      p_to.CAPITAL_REDUCTION := p_from.CAPITAL_REDUCTION;

      p_to.VENDOR_ADVANCE_PAID := p_from.VENDOR_ADVANCE_PAID;

      p_to.TRADEIN_AMOUNT := p_from.TRADEIN_AMOUNT;

      p_to.DELIVERED_DATE := p_from.DELIVERED_DATE;

      p_to.YEAR_OF_MANUFACTURE := p_from.YEAR_OF_MANUFACTURE;

      p_to.INITIAL_DIRECT_COST := p_from.INITIAL_DIRECT_COST;

      p_to.OCCUPANCY := p_from.OCCUPANCY;

      p_to.DATE_LAST_INSPECTION := p_from.DATE_LAST_INSPECTION;

      p_to.DATE_NEXT_INSPECTION_DUE := p_from.DATE_NEXT_INSPECTION_DUE;

      p_to.WEIGHTED_AVERAGE_LIFE := p_from.WEIGHTED_AVERAGE_LIFE;

      p_to.BOND_EQUIVALENT_YIELD := p_from.BOND_EQUIVALENT_YIELD;

      p_to.REFINANCE_AMOUNT := p_from.REFINANCE_AMOUNT;

      p_to.YEAR_BUILT := p_from.YEAR_BUILT;

      p_to.COVERAGE_RATIO := p_from.COVERAGE_RATIO;

      p_to.GROSS_SQUARE_FOOTAGE := p_from.GROSS_SQUARE_FOOTAGE;

      p_to.NET_RENTABLE := p_from.NET_RENTABLE;

      p_to.DATE_LETTER_ACCEPTANCE := p_from.DATE_LETTER_ACCEPTANCE;

      p_to.DATE_COMMITMENT_EXPIRATION := p_from.DATE_COMMITMENT_EXPIRATION;

      p_to.DATE_APPRAISAL := p_from.DATE_APPRAISAL;

      p_to.APPRAISAL_VALUE := p_from.APPRAISAL_VALUE;

      p_to.RESIDUAL_VALUE := p_from.RESIDUAL_VALUE;

      p_to.PERCENT := p_from.PERCENT;

      p_to.COVERAGE := p_from.COVERAGE;

      p_to.LRV_AMOUNT := p_from.LRV_AMOUNT;

      p_to.AMOUNT := p_from.AMOUNT;

      p_to.LRS_PERCENT := p_from.LRS_PERCENT;

      p_to.EVERGREEN_PERCENT := p_from.EVERGREEN_PERCENT;

      p_to.PERCENT_STAKE := p_from.PERCENT_STAKE;

      p_to.AMOUNT_STAKE := p_from.AMOUNT_STAKE;

      p_to.DATE_SOLD := p_from.DATE_SOLD;

      p_to.STY_ID_FOR := p_from.STY_ID_FOR;

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

      p_to.NTY_CODE := p_from.NTY_CODE;

      p_to.FCG_CODE := p_from.FCG_CODE;

      p_to.PRC_CODE := p_from.PRC_CODE;

      p_to.RE_LEASE_YN := p_from.RE_LEASE_YN;

      p_to.PRESCRIBED_ASSET_YN := p_from.PRESCRIBED_ASSET_YN;

      p_to.CREDIT_TENANT_YN := p_from.CREDIT_TENANT_YN;

      p_to.SECURED_DEAL_YN := p_from.SECURED_DEAL_YN;

      p_to.CLG_ID := p_from.CLG_ID;

      p_to.DATE_FUNDING := p_from.DATE_FUNDING;

      p_to.DATE_FUNDING_REQUIRED := p_from.DATE_FUNDING_REQUIRED;

      p_to.DATE_ACCEPTED := p_from.DATE_ACCEPTED;

      p_to.DATE_DELIVERY_EXPECTED := p_from.DATE_DELIVERY_EXPECTED;

      p_to.OEC := p_from.OEC;

      p_to.CAPITAL_AMOUNT := p_from.CAPITAL_AMOUNT;

      p_to.RESIDUAL_GRNTY_AMOUNT := p_from.RESIDUAL_GRNTY_AMOUNT;

      p_to.RESIDUAL_CODE := p_from.RESIDUAL_CODE;

      p_to.RVI_PREMIUM := p_from.RVI_PREMIUM;

      p_to.CREDIT_NATURE := p_from.CREDIT_NATURE;

      p_to.CAPITALIZED_INTEREST := p_from.CAPITALIZED_INTEREST;

      p_to.CAPITAL_REDUCTION_PERCENT := p_from.CAPITAL_REDUCTION_PERCENT;

      p_to.DATE_PAY_INVESTOR_START := p_from.DATE_PAY_INVESTOR_START;

      p_to.PAY_INVESTOR_FREQUENCY := p_from.PAY_INVESTOR_FREQUENCY;

      p_to.PAY_INVESTOR_EVENT := p_from.PAY_INVESTOR_EVENT;

      p_to.PAY_INVESTOR_REMITTANCE_DAYS := p_from.PAY_INVESTOR_REMITTANCE_DAYS;
      p_to.FEE_TYPE := p_from.FEE_TYPE;
--Bug# 3143522: 11.5.10
--subsidy
   p_to.SUBSIDY_ID := p_from.SUBSIDY_ID;
   --p_to.SUBSIDIZED_OEC := p_from.SUBSIDIZED_OEC;
   --p_to.SUBSIDIZED_CAP_AMOUNT := p_from.SUBSIDIZED_CAP_AMOUNT;
   p_to.SUBSIDY_OVERRIDE_AMOUNT := p_from.SUBSIDY_OVERRIDE_AMOUNT;
   --financed fee
   p_to.PRE_TAX_YIELD := p_from.PRE_TAX_YIELD;
   p_to.AFTER_TAX_YIELD := p_from.AFTER_TAX_YIELD;
   p_to.IMPLICIT_INTEREST_RATE := p_from.IMPLICIT_INTEREST_RATE;
   p_to.IMPLICIT_NON_IDC_INTEREST_RATE := p_from.IMPLICIT_NON_IDC_INTEREST_RATE;
   p_to.PRE_TAX_IRR := p_from.PRE_TAX_IRR;
   p_to.AFTER_TAX_IRR := p_from.AFTER_TAX_IRR;
--quote
   p_to.SUB_PRE_TAX_YIELD := p_from.SUB_PRE_TAX_YIELD;
   p_to.SUB_AFTER_TAX_YIELD := p_from.SUB_AFTER_TAX_YIELD;
   p_to.SUB_IMPL_INTEREST_RATE := p_from.SUB_IMPL_INTEREST_RATE;
   p_to.SUB_IMPL_NON_IDC_INT_RATE := p_from.SUB_IMPL_NON_IDC_INT_RATE;
   p_to.SUB_PRE_TAX_IRR := p_from.SUB_PRE_TAX_IRR;
   p_to.SUB_AFTER_TAX_IRR := p_from.SUB_AFTER_TAX_IRR;
--Bug# 2994971 :
   p_to.ITEM_INSURANCE_CATEGORY := p_from.ITEM_INSURANCE_CATEGORY;
--bug# 3973640: 11.5.10+
   p_to.QTE_ID := p_from.QTE_ID;
   p_to.FUNDING_DATE := p_from.FUNDING_DATE;
   p_to.STREAM_TYPE_SUBCLASS := p_from.STREAM_TYPE_SUBCLASS;
--Bug# 4419339  OKLH
   p_to.DATE_FUNDING_EXPECTED := p_from.DATE_FUNDING_EXPECTED;
   p_to.MANUFACTURER_NAME := p_from.MANUFACTURER_NAME;
   p_to.MODEL_NUMBER := p_from.MODEL_NUMBER;
   p_to.DOWN_PAYMENT_RECEIVER_CODE := p_from.DOWN_PAYMENT_RECEIVER_CODE;
   p_to.CAPITALIZE_DOWN_PAYMENT_YN := p_from.CAPITALIZE_DOWN_PAYMENT_YN;
--Bug#4373029
   p_to.FEE_PURPOSE_CODE := p_from.FEE_PURPOSE_CODE;
   p_to.TERMINATION_VALUE := p_from.TERMINATION_VALUE;
--Bug# 4631549
   p_to.EXPECTED_ASSET_COST := p_from.EXPECTED_ASSET_COST;
   p_to.ORIG_CONTRACT_LINE_ID := p_from.ORIG_CONTRACT_LINE_ID;

  END migrate;

  PROCEDURE migrate (
    p_from	IN kle_rec_type,
    p_to	IN OUT NOCOPY okl_k_lines_h_rec_type
  ) IS
  BEGIN

      p_to.ID := p_from.ID;

      p_to.KLE_ID := p_from.KLE_ID;

      p_to.STY_ID := p_from.STY_ID;

      p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;

      p_to.LAO_AMOUNT := p_from.LAO_AMOUNT;

      p_to.FEE_CHARGE := p_from.FEE_CHARGE;

      p_to.TITLE_DATE := p_from.TITLE_DATE;

      p_to.DATE_RESIDUAL_LAST_REVIEW := p_from.DATE_RESIDUAL_LAST_REVIEW;

      p_to.DATE_LAST_REAMORTISATION := p_from.DATE_LAST_REAMORTISATION;

      p_to.TERMINATION_PURCHASE_AMOUNT := p_from.TERMINATION_PURCHASE_AMOUNT;

      p_to.DATE_LAST_CLEANUP := p_from.DATE_LAST_CLEANUP;

      p_to.REMARKETED_AMOUNT := p_from.REMARKETED_AMOUNT;

      p_to.DATE_REMARKETED := p_from.DATE_REMARKETED;

      p_to.REMARKET_MARGIN := p_from.REMARKET_MARGIN;

      p_to.REPURCHASED_AMOUNT := p_from.REPURCHASED_AMOUNT;

      p_to.DATE_REPURCHASED := p_from.DATE_REPURCHASED;

      p_to.GAIN_LOSS := p_from.GAIN_LOSS;

      p_to.FLOOR_AMOUNT := p_from.FLOOR_AMOUNT;

      p_to.PREVIOUS_CONTRACT := p_from.PREVIOUS_CONTRACT;

      p_to.TRACKED_RESIDUAL := p_from.TRACKED_RESIDUAL;

      p_to.DATE_TITLE_RECEIVED := p_from.DATE_TITLE_RECEIVED;

      p_to.ESTIMATED_OEC := p_from.ESTIMATED_OEC;

      p_to.RESIDUAL_PERCENTAGE := p_from.RESIDUAL_PERCENTAGE;

      p_to.CAPITAL_REDUCTION := p_from.CAPITAL_REDUCTION;

      p_to.VENDOR_ADVANCE_PAID := p_from.VENDOR_ADVANCE_PAID;

      p_to.TRADEIN_AMOUNT := p_from.TRADEIN_AMOUNT;

      p_to.DELIVERED_DATE := p_from.DELIVERED_DATE;

      p_to.YEAR_OF_MANUFACTURE := p_from.YEAR_OF_MANUFACTURE;

      p_to.INITIAL_DIRECT_COST := p_from.INITIAL_DIRECT_COST;

      p_to.OCCUPANCY := p_from.OCCUPANCY;

      p_to.DATE_LAST_INSPECTION := p_from.DATE_LAST_INSPECTION;

      p_to.DATE_NEXT_INSPECTION_DUE := p_from.DATE_NEXT_INSPECTION_DUE;

      p_to.WEIGHTED_AVERAGE_LIFE := p_from.WEIGHTED_AVERAGE_LIFE;

      p_to.BOND_EQUIVALENT_YIELD := p_from.BOND_EQUIVALENT_YIELD;

      p_to.REFINANCE_AMOUNT := p_from.REFINANCE_AMOUNT;

      p_to.YEAR_BUILT := p_from.YEAR_BUILT;

      p_to.COVERAGE_RATIO := p_from.COVERAGE_RATIO;

      p_to.GROSS_SQUARE_FOOTAGE := p_from.GROSS_SQUARE_FOOTAGE;

      p_to.NET_RENTABLE := p_from.NET_RENTABLE;

      p_to.DATE_LETTER_ACCEPTANCE := p_from.DATE_LETTER_ACCEPTANCE;

      p_to.DATE_COMMITMENT_EXPIRATION := p_from.DATE_COMMITMENT_EXPIRATION;

      p_to.DATE_APPRAISAL := p_from.DATE_APPRAISAL;

      p_to.APPRAISAL_VALUE := p_from.APPRAISAL_VALUE;

      p_to.RESIDUAL_VALUE := p_from.RESIDUAL_VALUE;

      p_to.PERCENT := p_from.PERCENT;

      p_to.COVERAGE := p_from.COVERAGE;

      p_to.LRV_AMOUNT := p_from.LRV_AMOUNT;

      p_to.AMOUNT := p_from.AMOUNT;

      p_to.LRS_PERCENT := p_from.LRS_PERCENT;

      p_to.EVERGREEN_PERCENT := p_from.EVERGREEN_PERCENT;

      p_to.PERCENT_STAKE := p_from.PERCENT_STAKE;

      p_to.AMOUNT_STAKE := p_from.AMOUNT_STAKE;

      p_to.DATE_SOLD := p_from.DATE_SOLD;

      p_to.STY_ID_FOR := p_from.STY_ID_FOR;

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

      p_to.NTY_CODE := p_from.NTY_CODE;

      p_to.FCG_CODE := p_from.FCG_CODE;

      p_to.PRC_CODE := p_from.PRC_CODE;

      p_to.RE_LEASE_YN := p_from.RE_LEASE_YN;

      p_to.PRESCRIBED_ASSET_YN := p_from.PRESCRIBED_ASSET_YN;

      p_to.CREDIT_TENANT_YN := p_from.CREDIT_TENANT_YN;

      p_to.SECURED_DEAL_YN := p_from.SECURED_DEAL_YN;

      p_to.CLG_ID := p_from.CLG_ID;

      p_to.DATE_FUNDING := p_from.DATE_FUNDING;

      p_to.DATE_FUNDING_REQUIRED := p_from.DATE_FUNDING_REQUIRED;

      p_to.DATE_ACCEPTED := p_from.DATE_ACCEPTED;

      p_to.DATE_DELIVERY_EXPECTED := p_from.DATE_DELIVERY_EXPECTED;

      p_to.OEC := p_from.OEC;

      p_to.CAPITAL_AMOUNT := p_from.CAPITAL_AMOUNT;

      p_to.RESIDUAL_GRNTY_AMOUNT := p_from.RESIDUAL_GRNTY_AMOUNT;

      p_to.RESIDUAL_CODE := p_from.RESIDUAL_CODE;

      p_to.RVI_PREMIUM := p_from.RVI_PREMIUM;

      p_to.CREDIT_NATURE := p_from.CREDIT_NATURE;

      p_to.CAPITALIZED_INTEREST := p_from.CAPITALIZED_INTEREST;

      p_to.DATE_PAY_INVESTOR_START := p_from.DATE_PAY_INVESTOR_START;

      p_to.PAY_INVESTOR_FREQUENCY := p_from.PAY_INVESTOR_FREQUENCY;

      p_to.PAY_INVESTOR_EVENT := p_from.PAY_INVESTOR_EVENT;

      p_to.PAY_INVESTOR_REMITTANCE_DAYS := p_from.PAY_INVESTOR_REMITTANCE_DAYS;

      p_to.FEE_TYPE := p_from.FEE_TYPE;
--Bug# 3143522: 11.5.10
--subsidy
   p_to.SUBSIDY_ID := p_from.SUBSIDY_ID;
   --p_to.SUBSIDIZED_OEC := p_from.SUBSIDIZED_OEC;
   --p_to.SUBSIDIZED_CAP_AMOUNT := p_from.SUBSIDIZED_CAP_AMOUNT;
   p_to.SUBSIDY_OVERRIDE_AMOUNT := p_from.SUBSIDY_OVERRIDE_AMOUNT;
   --financed fee
   p_to.PRE_TAX_YIELD := p_from.PRE_TAX_YIELD;
   p_to.AFTER_TAX_YIELD := p_from.AFTER_TAX_YIELD;
   p_to.IMPLICIT_INTEREST_RATE := p_from.IMPLICIT_INTEREST_RATE;
   p_to.IMPLICIT_NON_IDC_INTEREST_RATE := p_from.IMPLICIT_NON_IDC_INTEREST_RATE;
   p_to.PRE_TAX_IRR := p_from.PRE_TAX_IRR;
   p_to.AFTER_TAX_IRR := p_from.AFTER_TAX_IRR;
--quote
   p_to.SUB_PRE_TAX_YIELD := p_from.SUB_PRE_TAX_YIELD;
   p_to.SUB_AFTER_TAX_YIELD := p_from.SUB_AFTER_TAX_YIELD;
   p_to.SUB_IMPL_INTEREST_RATE := p_from.SUB_IMPL_INTEREST_RATE;
   p_to.SUB_IMPL_NON_IDC_INT_RATE := p_from.SUB_IMPL_NON_IDC_INT_RATE;
   p_to.SUB_PRE_TAX_IRR := p_from.SUB_PRE_TAX_IRR;
   p_to.SUB_AFTER_TAX_IRR := p_from.SUB_AFTER_TAX_IRR;
--Bug# 2994971
   p_to.ITEM_INSURANCE_CATEGORY := p_from.ITEM_INSURANCE_CATEGORY;
--Bug# 3973640 :11.5.10+
   p_to.QTE_ID := p_from.QTE_ID;
   p_to.FUNDING_DATE := p_from.FUNDING_DATE;
   p_to.STREAM_TYPE_SUBCLASS := p_from.STREAM_TYPE_SUBCLASS;
--Bug# 4419339  OKLH
   p_to.DATE_FUNDING_EXPECTED := p_from.DATE_FUNDING_EXPECTED;
   p_to.MANUFACTURER_NAME := p_from.MANUFACTURER_NAME;
   p_to.MODEL_NUMBER := p_from.MODEL_NUMBER;
   p_to.DOWN_PAYMENT_RECEIVER_CODE := p_from.DOWN_PAYMENT_RECEIVER_CODE;
   p_to.CAPITALIZE_DOWN_PAYMENT_YN := p_from.CAPITALIZE_DOWN_PAYMENT_YN;
--Bug#4373029
   p_to.FEE_PURPOSE_CODE := p_from.FEE_PURPOSE_CODE;
   p_to.TERMINATION_VALUE := p_from.TERMINATION_VALUE;
--Bug# 4631549
   p_to.EXPECTED_ASSET_COST := p_from.EXPECTED_ASSET_COST;
   p_to.ORIG_CONTRACT_LINE_ID := p_from.ORIG_CONTRACT_LINE_ID;

  END migrate;



  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------

  --------------------------------------
  -- validate_row for: OKL_K_LINES_V --
  --------------------------------------

  PROCEDURE validate_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_rec                     IN klev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klev_rec                     klev_rec_type := p_klev_rec;
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
    l_return_status := Validate_Attributes(l_klev_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_return_status := Validate_Record(l_klev_rec);

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
  -- PL/SQL TBL validate_row for: OKL_K_LINES_V --
  ------------------------------------------

  PROCEDURE validate_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_tbl                     IN klev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klev_tbl.COUNT > 0) THEN
      i := p_klev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_klev_rec                     => p_klev_tbl(i));
        EXIT WHEN (i = p_klev_tbl.LAST);
        i := p_klev_tbl.NEXT(i);
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
  -- insert_row for: OKL_K_LINES_H --
  ------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_k_lines_h_rec                     IN okl_k_lines_h_rec_type,
    x_okl_k_lines_h_rec                     OUT NOCOPY okl_k_lines_h_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_k_lines_h_rec          okl_k_lines_h_rec_type := p_okl_k_lines_h_rec;
    l_def_okl_k_lines_h_rec      okl_k_lines_h_rec_type;
    ----------------------------------------
    -- Set_Attributes for: OKL_K_LINES_H --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_okl_k_lines_h_rec IN  okl_k_lines_h_rec_type,
      x_okl_k_lines_h_rec OUT NOCOPY okl_k_lines_h_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_k_lines_h_rec := p_okl_k_lines_h_rec;
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
      p_okl_k_lines_h_rec,             -- IN
      l_okl_k_lines_h_rec);            -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_K_LINES_H(
	ID,
        MAJOR_VERSION,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug# 3143522 : 11.5.10
   --subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--Bug# 2994971
   ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 :11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID

        )
      VALUES (
       l_okl_k_lines_h_rec.ID,
        l_okl_k_lines_h_rec.MAJOR_VERSION,
        l_okl_k_lines_h_rec.KLE_ID,
        l_okl_k_lines_h_rec.STY_ID,
        l_okl_k_lines_h_rec.OBJECT_VERSION_NUMBER,
        l_okl_k_lines_h_rec.LAO_AMOUNT,
        l_okl_k_lines_h_rec.FEE_CHARGE,
        l_okl_k_lines_h_rec.TITLE_DATE,
        l_okl_k_lines_h_rec.DATE_RESIDUAL_LAST_REVIEW,
        l_okl_k_lines_h_rec.DATE_LAST_REAMORTISATION,
        l_okl_k_lines_h_rec.TERMINATION_PURCHASE_AMOUNT,
        l_okl_k_lines_h_rec.DATE_LAST_CLEANUP,
        l_okl_k_lines_h_rec.REMARKETED_AMOUNT,
        l_okl_k_lines_h_rec.DATE_REMARKETED,
        l_okl_k_lines_h_rec.REMARKET_MARGIN,
        l_okl_k_lines_h_rec.REPURCHASED_AMOUNT,
        l_okl_k_lines_h_rec.DATE_REPURCHASED,
        l_okl_k_lines_h_rec.GAIN_LOSS,
        l_okl_k_lines_h_rec.FLOOR_AMOUNT,
        l_okl_k_lines_h_rec.PREVIOUS_CONTRACT,
        l_okl_k_lines_h_rec.TRACKED_RESIDUAL,
        l_okl_k_lines_h_rec.DATE_TITLE_RECEIVED,
        l_okl_k_lines_h_rec.ESTIMATED_OEC,
        l_okl_k_lines_h_rec.RESIDUAL_PERCENTAGE,
        l_okl_k_lines_h_rec.CAPITAL_REDUCTION,
        l_okl_k_lines_h_rec.VENDOR_ADVANCE_PAID,
        l_okl_k_lines_h_rec.TRADEIN_AMOUNT,
        l_okl_k_lines_h_rec.DELIVERED_DATE,
        l_okl_k_lines_h_rec.YEAR_OF_MANUFACTURE,
        l_okl_k_lines_h_rec.INITIAL_DIRECT_COST,
        l_okl_k_lines_h_rec.OCCUPANCY,
        l_okl_k_lines_h_rec.DATE_LAST_INSPECTION,
        l_okl_k_lines_h_rec.DATE_NEXT_INSPECTION_DUE,
        l_okl_k_lines_h_rec.WEIGHTED_AVERAGE_LIFE,
        l_okl_k_lines_h_rec.BOND_EQUIVALENT_YIELD,
        l_okl_k_lines_h_rec.REFINANCE_AMOUNT,
        l_okl_k_lines_h_rec.YEAR_BUILT,
        l_okl_k_lines_h_rec.COVERAGE_RATIO,
        l_okl_k_lines_h_rec.GROSS_SQUARE_FOOTAGE,
        l_okl_k_lines_h_rec.NET_RENTABLE,
        l_okl_k_lines_h_rec.DATE_LETTER_ACCEPTANCE,
        l_okl_k_lines_h_rec.DATE_COMMITMENT_EXPIRATION,
        l_okl_k_lines_h_rec.DATE_APPRAISAL,
        l_okl_k_lines_h_rec.APPRAISAL_VALUE,
        l_okl_k_lines_h_rec.RESIDUAL_VALUE,
        l_okl_k_lines_h_rec.PERCENT,
        l_okl_k_lines_h_rec.COVERAGE,
        l_okl_k_lines_h_rec.LRV_AMOUNT,
        l_okl_k_lines_h_rec.AMOUNT,
        l_okl_k_lines_h_rec.LRS_PERCENT,
        l_okl_k_lines_h_rec.EVERGREEN_PERCENT,
        l_okl_k_lines_h_rec.PERCENT_STAKE,
        l_okl_k_lines_h_rec.AMOUNT_STAKE,
        l_okl_k_lines_h_rec.DATE_SOLD,
        l_okl_k_lines_h_rec.STY_ID_FOR,
        l_okl_k_lines_h_rec.ATTRIBUTE_CATEGORY,
        l_okl_k_lines_h_rec.ATTRIBUTE1,
        l_okl_k_lines_h_rec.ATTRIBUTE2,
        l_okl_k_lines_h_rec.ATTRIBUTE3,
        l_okl_k_lines_h_rec.ATTRIBUTE4,
        l_okl_k_lines_h_rec.ATTRIBUTE5,
        l_okl_k_lines_h_rec.ATTRIBUTE6,
        l_okl_k_lines_h_rec.ATTRIBUTE7,
        l_okl_k_lines_h_rec.ATTRIBUTE8,
        l_okl_k_lines_h_rec.ATTRIBUTE9,
        l_okl_k_lines_h_rec.ATTRIBUTE10,
        l_okl_k_lines_h_rec.ATTRIBUTE11,
        l_okl_k_lines_h_rec.ATTRIBUTE12,
        l_okl_k_lines_h_rec.ATTRIBUTE13,
        l_okl_k_lines_h_rec.ATTRIBUTE14,
        l_okl_k_lines_h_rec.ATTRIBUTE15,
        l_okl_k_lines_h_rec.CREATED_BY,
        l_okl_k_lines_h_rec.CREATION_DATE,
        l_okl_k_lines_h_rec.LAST_UPDATED_BY,
        l_okl_k_lines_h_rec.LAST_UPDATE_DATE,
        l_okl_k_lines_h_rec.LAST_UPDATE_LOGIN,
        l_okl_k_lines_h_rec.NTY_CODE,
        l_okl_k_lines_h_rec.FCG_CODE,
        l_okl_k_lines_h_rec.PRC_CODE,
        l_okl_k_lines_h_rec.RE_LEASE_YN,
        l_okl_k_lines_h_rec.PRESCRIBED_ASSET_YN,
        l_okl_k_lines_h_rec.CREDIT_TENANT_YN,
        l_okl_k_lines_h_rec.SECURED_DEAL_YN,
        l_okl_k_lines_h_rec.CLG_ID,
        l_okl_k_lines_h_rec.DATE_FUNDING,
        l_okl_k_lines_h_rec.DATE_FUNDING_REQUIRED,
        l_okl_k_lines_h_rec.DATE_ACCEPTED,
        l_okl_k_lines_h_rec.DATE_DELIVERY_EXPECTED,
        l_okl_k_lines_h_rec.OEC,
        l_okl_k_lines_h_rec.CAPITAL_AMOUNT,
        l_okl_k_lines_h_rec.RESIDUAL_GRNTY_AMOUNT,
        l_okl_k_lines_h_rec.RESIDUAL_CODE,
        l_okl_k_lines_h_rec.RVI_PREMIUM,
        l_okl_k_lines_h_rec.CREDIT_NATURE,
        l_okl_k_lines_h_rec.CAPITALIZED_INTEREST,
        l_okl_k_lines_h_rec.CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        l_okl_k_lines_h_rec.DATE_PAY_INVESTOR_START,
        l_okl_k_lines_h_rec.PAY_INVESTOR_FREQUENCY,
        l_okl_k_lines_h_rec.PAY_INVESTOR_EVENT,
        l_okl_k_lines_h_rec.PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        l_okl_k_lines_h_rec.FEE_TYPE,
--Bug# 3143522: 11.5.10
   --subsidy
   l_okl_k_lines_h_rec.SUBSIDY_ID,
   --l_okl_k_lines_h_rec.SUBSIDIZED_OEC,
   --l_okl_k_lines_h_rec.SUBSIDIZED_CAP_AMOUNT,
   l_okl_k_lines_h_rec.SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   l_okl_k_lines_h_rec.PRE_TAX_YIELD,
   l_okl_k_lines_h_rec.AFTER_TAX_YIELD,
   l_okl_k_lines_h_rec.IMPLICIT_INTEREST_RATE,
   l_okl_k_lines_h_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
   l_okl_k_lines_h_rec.PRE_TAX_IRR,
   l_okl_k_lines_h_rec.AFTER_TAX_IRR,
--quote
   l_okl_k_lines_h_rec.SUB_PRE_TAX_YIELD,
   l_okl_k_lines_h_rec.SUB_AFTER_TAX_YIELD,
   l_okl_k_lines_h_rec.SUB_IMPL_INTEREST_RATE,
   l_okl_k_lines_h_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_okl_k_lines_h_rec.SUB_PRE_TAX_IRR,
   l_okl_k_lines_h_rec.SUB_AFTER_TAX_IRR,
--Bug#2994971
   l_okl_k_lines_h_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640: 11.5.10+
   l_okl_k_lines_h_rec.QTE_ID,
   l_okl_k_lines_h_rec.FUNDING_DATE,
   l_okl_k_lines_h_rec.STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   l_okl_k_lines_h_rec.DATE_FUNDING_EXPECTED,
   l_okl_k_lines_h_rec.MANUFACTURER_NAME,
   l_okl_k_lines_h_rec.MODEL_NUMBER,
   l_okl_k_lines_h_rec.DOWN_PAYMENT_RECEIVER_CODE,
   l_okl_k_lines_h_rec.CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   l_okl_k_lines_h_rec.FEE_PURPOSE_CODE,
   l_okl_k_lines_h_rec.TERMINATION_VALUE,
--Bug# 4631549
   l_okl_k_lines_h_rec.EXPECTED_ASSET_COST,
   l_okl_k_lines_h_rec.ORIG_CONTRACT_LINE_ID

        );
    -- Set OUT values
    x_okl_k_lines_h_rec := l_okl_k_lines_h_rec;
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
  -- insert_row for: OKL_K_LINES --
  ------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kle_rec                     IN kle_rec_type,
    x_kle_rec                     OUT NOCOPY kle_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kle_rec          kle_rec_type := p_kle_rec;
    l_def_kle_rec      kle_rec_type;
    ----------------------------------------
    -- Set_Attributes for: OKL_K_LINES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_kle_rec IN  kle_rec_type,
      x_kle_rec OUT NOCOPY kle_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_kle_rec := p_kle_rec;
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
      p_kle_rec,             -- IN
      l_kle_rec);            -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_K_LINES(
	ID,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
-- Bug# 3143522 : 11.5.10
   --subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--Bug# 2994971
   ITEM_INSURANCE_CATEGORY,
-- Bug# 3973640 :11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID
        )
      VALUES (
       l_kle_rec.ID,
        l_kle_rec.KLE_ID,
        l_kle_rec.STY_ID,
        l_kle_rec.OBJECT_VERSION_NUMBER,
        l_kle_rec.LAO_AMOUNT,
        l_kle_rec.FEE_CHARGE,
        l_kle_rec.TITLE_DATE,
        l_kle_rec.DATE_RESIDUAL_LAST_REVIEW,
        l_kle_rec.DATE_LAST_REAMORTISATION,
        l_kle_rec.TERMINATION_PURCHASE_AMOUNT,
        l_kle_rec.DATE_LAST_CLEANUP,
        l_kle_rec.REMARKETED_AMOUNT,
        l_kle_rec.DATE_REMARKETED,
        l_kle_rec.REMARKET_MARGIN,
        l_kle_rec.REPURCHASED_AMOUNT,
        l_kle_rec.DATE_REPURCHASED,
        l_kle_rec.GAIN_LOSS,
        l_kle_rec.FLOOR_AMOUNT,
        l_kle_rec.PREVIOUS_CONTRACT,
        l_kle_rec.TRACKED_RESIDUAL,
        l_kle_rec.DATE_TITLE_RECEIVED,
        l_kle_rec.ESTIMATED_OEC,
        l_kle_rec.RESIDUAL_PERCENTAGE,
        l_kle_rec.CAPITAL_REDUCTION,
        l_kle_rec.VENDOR_ADVANCE_PAID,
        l_kle_rec.TRADEIN_AMOUNT,
        l_kle_rec.DELIVERED_DATE,
        l_kle_rec.YEAR_OF_MANUFACTURE,
        l_kle_rec.INITIAL_DIRECT_COST,
        l_kle_rec.OCCUPANCY,
        l_kle_rec.DATE_LAST_INSPECTION,
        l_kle_rec.DATE_NEXT_INSPECTION_DUE,
        l_kle_rec.WEIGHTED_AVERAGE_LIFE,
        l_kle_rec.BOND_EQUIVALENT_YIELD,
        l_kle_rec.REFINANCE_AMOUNT,
        l_kle_rec.YEAR_BUILT,
        l_kle_rec.COVERAGE_RATIO,
        l_kle_rec.GROSS_SQUARE_FOOTAGE,
        l_kle_rec.NET_RENTABLE,
        l_kle_rec.DATE_LETTER_ACCEPTANCE,
        l_kle_rec.DATE_COMMITMENT_EXPIRATION,
        l_kle_rec.DATE_APPRAISAL,
        l_kle_rec.APPRAISAL_VALUE,
        l_kle_rec.RESIDUAL_VALUE,
        l_kle_rec.PERCENT,
        l_kle_rec.COVERAGE,
        l_kle_rec.LRV_AMOUNT,
        l_kle_rec.AMOUNT,
        l_kle_rec.LRS_PERCENT,
        l_kle_rec.EVERGREEN_PERCENT,
        l_kle_rec.PERCENT_STAKE,
        l_kle_rec.AMOUNT_STAKE,
        l_kle_rec.DATE_SOLD,
        l_kle_rec.STY_ID_FOR,
        l_kle_rec.ATTRIBUTE_CATEGORY,
        l_kle_rec.ATTRIBUTE1,
        l_kle_rec.ATTRIBUTE2,
        l_kle_rec.ATTRIBUTE3,
        l_kle_rec.ATTRIBUTE4,
        l_kle_rec.ATTRIBUTE5,
        l_kle_rec.ATTRIBUTE6,
        l_kle_rec.ATTRIBUTE7,
        l_kle_rec.ATTRIBUTE8,
        l_kle_rec.ATTRIBUTE9,
        l_kle_rec.ATTRIBUTE10,
        l_kle_rec.ATTRIBUTE11,
        l_kle_rec.ATTRIBUTE12,
        l_kle_rec.ATTRIBUTE13,
        l_kle_rec.ATTRIBUTE14,
        l_kle_rec.ATTRIBUTE15,
        l_kle_rec.CREATED_BY,
        l_kle_rec.CREATION_DATE,
        l_kle_rec.LAST_UPDATED_BY,
        l_kle_rec.LAST_UPDATE_DATE,
        l_kle_rec.LAST_UPDATE_LOGIN,
        l_kle_rec.NTY_CODE,
        l_kle_rec.FCG_CODE,
        l_kle_rec.PRC_CODE,
        l_kle_rec.RE_LEASE_YN,
        l_kle_rec.PRESCRIBED_ASSET_YN,
        l_kle_rec.CREDIT_TENANT_YN,
        l_kle_rec.SECURED_DEAL_YN,
        l_kle_rec.CLG_ID,
        l_kle_rec.DATE_FUNDING,
        l_kle_rec.DATE_FUNDING_REQUIRED,
        l_kle_rec.DATE_ACCEPTED,
        l_kle_rec.DATE_DELIVERY_EXPECTED,
        l_kle_rec.OEC,
        l_kle_rec.CAPITAL_AMOUNT,
        l_kle_rec.RESIDUAL_GRNTY_AMOUNT,
        l_kle_rec.RESIDUAL_CODE,
        l_kle_rec.RVI_PREMIUM,
        l_kle_rec.CREDIT_NATURE,
        l_kle_rec.CAPITALIZED_INTEREST,
        l_kle_rec.CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        l_kle_rec.DATE_PAY_INVESTOR_START,
        l_kle_rec.PAY_INVESTOR_FREQUENCY,
        l_kle_rec.PAY_INVESTOR_EVENT,
        l_kle_rec.PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        l_kle_rec.FEE_TYPE,
--Bug# 3143522: 11.5.10
   --subsidy
   l_kle_rec.SUBSIDY_ID,
   --l_kle_rec.SUBSIDIZED_OEC,
   --l_kle_rec.SUBSIDIZED_CAP_AMOUNT,
   l_kle_rec.SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   l_kle_rec.PRE_TAX_YIELD,
   l_kle_rec.AFTER_TAX_YIELD,
   l_kle_rec.IMPLICIT_INTEREST_RATE,
   l_kle_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
   l_kle_rec.PRE_TAX_IRR,
   l_kle_rec.AFTER_TAX_IRR,
--quotes
   l_kle_rec.SUB_PRE_TAX_YIELD,
   l_kle_rec.SUB_AFTER_TAX_YIELD,
   l_kle_rec.SUB_IMPL_INTEREST_RATE,
   l_kle_rec.SUB_IMPL_NON_IDC_INT_RATE,
   l_kle_rec.SUB_PRE_TAX_IRR,
   l_kle_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971
   l_kle_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 :11.5.10+
   l_kle_rec.QTE_ID,
   l_kle_rec.FUNDING_DATE,
   l_kle_rec.STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   l_kle_rec.DATE_FUNDING_EXPECTED,
   l_kle_rec.MANUFACTURER_NAME,
   l_kle_rec.MODEL_NUMBER,
   l_kle_rec.DOWN_PAYMENT_RECEIVER_CODE,
   l_kle_rec.CAPITALIZE_DOWN_PAYMENT_YN,
--Bug# 4373029
   l_kle_rec.FEE_PURPOSE_CODE,
   l_kle_rec.TERMINATION_VALUE,
--Bug# 4631549
   l_kle_rec.EXPECTED_ASSET_COST,
   l_kle_rec.ORIG_CONTRACT_LINE_ID
        );
    -- Set OUT values
    x_kle_rec := l_kle_rec;
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
  -- insert_row for: OKL_K_LINES_V --
  ------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_rec                     IN klev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klev_rec                     klev_rec_type;
    l_def_klev_rec                 klev_rec_type;
    l_kle_rec                      kle_rec_type;
    lx_kle_rec                     kle_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_klev_rec	IN klev_rec_type
    ) RETURN klev_rec_type IS
      l_klev_rec	klev_rec_type := p_klev_rec;
    BEGIN
      l_klev_rec.CREATION_DATE := SYSDATE;
      l_klev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_klev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_klev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_klev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_klev_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for: OKL_K_LINES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_klev_rec IN  klev_rec_type,
      x_klev_rec OUT NOCOPY klev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klev_rec := p_klev_rec;
      x_klev_rec.OBJECT_VERSION_NUMBER := 1;
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

    l_klev_rec := null_out_defaults(p_klev_rec);

    -- Set primary key value
    -- modified by Miroslav Samoilenko
    if ( l_klev_rec.ID is null) then
      l_klev_rec.ID := get_seq_id;
    end if;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_klev_rec,                        -- IN
      l_def_klev_rec);                   -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_klev_rec := fill_who_columns(l_def_klev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_klev_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_klev_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_klev_rec, l_kle_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_kle_rec,
      lx_kle_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_kle_rec, l_def_klev_rec);
    -- Set OUT values
    x_klev_rec := l_def_klev_rec;
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
  -- PL/SQL TBL insert_row for: OKL_K_LINES_V --
  ----------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_tbl                     IN klev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klev_tbl.COUNT > 0) THEN
      i := p_klev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_klev_rec                     => p_klev_tbl(i),
          x_klev_rec                     => x_klev_tbl(i));
        EXIT WHEN (i = p_klev_tbl.LAST);
        i := p_klev_tbl.NEXT(i);
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
  -- lock_row for: OKL_K_LINES --
  --------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kle_rec                     IN kle_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_kle_rec IN kle_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_K_LINES
     WHERE ID = p_kle_rec.id
       AND OBJECT_VERSION_NUMBER = p_kle_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_kle_rec IN kle_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_K_LINES
    WHERE ID = p_kle_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_K_LINES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_K_LINES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_kle_rec);
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
      OPEN lchk_csr(p_kle_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_kle_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_kle_rec.object_version_number THEN
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
  -- lock_row for: OKL_K_LINES_V --
  ----------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_rec                     IN klev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kle_rec                      kle_rec_type;
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
    migrate(p_klev_rec, l_kle_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_kle_rec
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
  -- PL/SQL TBL lock_row for: OKL_K_LINES_V --
  --------------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_tbl                     IN klev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klev_tbl.COUNT > 0) THEN
      i := p_klev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_klev_rec                     => p_klev_tbl(i));
        EXIT WHEN (i = p_klev_tbl.LAST);
        i := p_klev_tbl.NEXT(i);
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
  -- update_row for: OKL_K_LINES --
  ----------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kle_rec                     IN kle_rec_type,
    x_kle_rec                     OUT NOCOPY kle_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kle_rec                      kle_rec_type := p_kle_rec;
    l_def_kle_rec                  kle_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_okl_k_lines_h_rec okl_k_lines_h_rec_type;
    lx_okl_k_lines_h_rec okl_k_lines_h_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_kle_rec	IN kle_rec_type,
      x_kle_rec	OUT NOCOPY kle_rec_type
    ) RETURN VARCHAR2 IS
      l_kle_rec                      kle_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_kle_rec := p_kle_rec;
      -- Get current database values
      l_kle_rec := get_rec(p_kle_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database
      migrate(l_kle_rec, l_okl_k_lines_h_rec);

      IF (x_kle_rec.ID = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.ID := l_kle_rec.ID;
      END IF;

      IF (x_kle_rec.KLE_ID = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.KLE_ID := l_kle_rec.KLE_ID;
      END IF;

      IF (x_kle_rec.STY_ID = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.STY_ID := l_kle_rec.STY_ID;
      END IF;

      IF (x_kle_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.OBJECT_VERSION_NUMBER := l_kle_rec.OBJECT_VERSION_NUMBER;
      END IF;

      IF (x_kle_rec.LAO_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.LAO_AMOUNT := l_kle_rec.LAO_AMOUNT;
      END IF;

      IF (x_kle_rec.FEE_CHARGE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.FEE_CHARGE := l_kle_rec.FEE_CHARGE;
      END IF;

      IF (x_kle_rec.TITLE_DATE = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.TITLE_DATE := l_kle_rec.TITLE_DATE;
      END IF;

      IF (x_kle_rec.DATE_RESIDUAL_LAST_REVIEW = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_RESIDUAL_LAST_REVIEW := l_kle_rec.DATE_RESIDUAL_LAST_REVIEW;
      END IF;

      IF (x_kle_rec.DATE_LAST_REAMORTISATION = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_LAST_REAMORTISATION := l_kle_rec.DATE_LAST_REAMORTISATION;
      END IF;

      IF (x_kle_rec.TERMINATION_PURCHASE_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.TERMINATION_PURCHASE_AMOUNT := l_kle_rec.TERMINATION_PURCHASE_AMOUNT;
      END IF;

      IF (x_kle_rec.DATE_LAST_CLEANUP = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_LAST_CLEANUP := l_kle_rec.DATE_LAST_CLEANUP;
      END IF;

      IF (x_kle_rec.REMARKETED_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.REMARKETED_AMOUNT := l_kle_rec.REMARKETED_AMOUNT;
      END IF;

      IF (x_kle_rec.DATE_REMARKETED = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_REMARKETED := l_kle_rec.DATE_REMARKETED;
      END IF;

      IF (x_kle_rec.REMARKET_MARGIN = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.REMARKET_MARGIN := l_kle_rec.REMARKET_MARGIN;
      END IF;

      IF (x_kle_rec.REPURCHASED_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.REPURCHASED_AMOUNT := l_kle_rec.REPURCHASED_AMOUNT;
      END IF;

      IF (x_kle_rec.DATE_REPURCHASED = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_REPURCHASED := l_kle_rec.DATE_REPURCHASED;
      END IF;

      IF (x_kle_rec.GAIN_LOSS = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.GAIN_LOSS := l_kle_rec.GAIN_LOSS;
      END IF;

      IF (x_kle_rec.FLOOR_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.FLOOR_AMOUNT := l_kle_rec.FLOOR_AMOUNT;
      END IF;

      IF (x_kle_rec.PREVIOUS_CONTRACT = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.PREVIOUS_CONTRACT := l_kle_rec.PREVIOUS_CONTRACT;
      END IF;

      IF (x_kle_rec.TRACKED_RESIDUAL = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.TRACKED_RESIDUAL := l_kle_rec.TRACKED_RESIDUAL;
      END IF;

      IF (x_kle_rec.DATE_TITLE_RECEIVED = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_TITLE_RECEIVED := l_kle_rec.DATE_TITLE_RECEIVED;
      END IF;

      IF (x_kle_rec.ESTIMATED_OEC = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.ESTIMATED_OEC := l_kle_rec.ESTIMATED_OEC;
      END IF;

      IF (x_kle_rec.RESIDUAL_PERCENTAGE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.RESIDUAL_PERCENTAGE := l_kle_rec.RESIDUAL_PERCENTAGE;
      END IF;

      IF (x_kle_rec.CAPITAL_REDUCTION = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.CAPITAL_REDUCTION := l_kle_rec.CAPITAL_REDUCTION;
      END IF;

      IF (x_kle_rec.VENDOR_ADVANCE_PAID = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.VENDOR_ADVANCE_PAID := l_kle_rec.VENDOR_ADVANCE_PAID;
      END IF;

      IF (x_kle_rec.TRADEIN_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.TRADEIN_AMOUNT := l_kle_rec.TRADEIN_AMOUNT;
      END IF;

      IF (x_kle_rec.DELIVERED_DATE = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DELIVERED_DATE := l_kle_rec.DELIVERED_DATE;
      END IF;

      IF (x_kle_rec.YEAR_OF_MANUFACTURE = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.YEAR_OF_MANUFACTURE := l_kle_rec.YEAR_OF_MANUFACTURE;
      END IF;

      IF (x_kle_rec.INITIAL_DIRECT_COST = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.INITIAL_DIRECT_COST := l_kle_rec.INITIAL_DIRECT_COST;
      END IF;

      IF (x_kle_rec.OCCUPANCY = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.OCCUPANCY := l_kle_rec.OCCUPANCY;
      END IF;

      IF (x_kle_rec.DATE_LAST_INSPECTION = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_LAST_INSPECTION := l_kle_rec.DATE_LAST_INSPECTION;
      END IF;

      IF (x_kle_rec.DATE_NEXT_INSPECTION_DUE = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_NEXT_INSPECTION_DUE := l_kle_rec.DATE_NEXT_INSPECTION_DUE;
      END IF;

      IF (x_kle_rec.WEIGHTED_AVERAGE_LIFE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.WEIGHTED_AVERAGE_LIFE := l_kle_rec.WEIGHTED_AVERAGE_LIFE;
      END IF;

      IF (x_kle_rec.BOND_EQUIVALENT_YIELD = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.BOND_EQUIVALENT_YIELD := l_kle_rec.BOND_EQUIVALENT_YIELD;
      END IF;

      IF (x_kle_rec.REFINANCE_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.REFINANCE_AMOUNT := l_kle_rec.REFINANCE_AMOUNT;
      END IF;

      IF (x_kle_rec.YEAR_BUILT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.YEAR_BUILT := l_kle_rec.YEAR_BUILT;
      END IF;

      IF (x_kle_rec.COVERAGE_RATIO = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.COVERAGE_RATIO := l_kle_rec.COVERAGE_RATIO;
      END IF;

      IF (x_kle_rec.GROSS_SQUARE_FOOTAGE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.GROSS_SQUARE_FOOTAGE := l_kle_rec.GROSS_SQUARE_FOOTAGE;
      END IF;

      IF (x_kle_rec.NET_RENTABLE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.NET_RENTABLE := l_kle_rec.NET_RENTABLE;
      END IF;

      IF (x_kle_rec.DATE_LETTER_ACCEPTANCE = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_LETTER_ACCEPTANCE := l_kle_rec.DATE_LETTER_ACCEPTANCE;
      END IF;

      IF (x_kle_rec.DATE_COMMITMENT_EXPIRATION = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_COMMITMENT_EXPIRATION := l_kle_rec.DATE_COMMITMENT_EXPIRATION;
      END IF;

      IF (x_kle_rec.DATE_APPRAISAL = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_APPRAISAL := l_kle_rec.DATE_APPRAISAL;
      END IF;

      IF (x_kle_rec.APPRAISAL_VALUE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.APPRAISAL_VALUE := l_kle_rec.APPRAISAL_VALUE;
      END IF;

      IF (x_kle_rec.RESIDUAL_VALUE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.RESIDUAL_VALUE := l_kle_rec.RESIDUAL_VALUE;
      END IF;

      IF (x_kle_rec.PERCENT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.PERCENT := l_kle_rec.PERCENT;
      END IF;

      IF (x_kle_rec.COVERAGE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.COVERAGE := l_kle_rec.COVERAGE;
      END IF;

      IF (x_kle_rec.LRV_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.LRV_AMOUNT := l_kle_rec.LRV_AMOUNT;
      END IF;

      IF (x_kle_rec.AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.AMOUNT := l_kle_rec.AMOUNT;
      END IF;

      IF (x_kle_rec.LRS_PERCENT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.LRS_PERCENT := l_kle_rec.LRS_PERCENT;
      END IF;

      IF (x_kle_rec.EVERGREEN_PERCENT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.EVERGREEN_PERCENT := l_kle_rec.EVERGREEN_PERCENT;
      END IF;

      IF (x_kle_rec.PERCENT_STAKE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.PERCENT_STAKE := l_kle_rec.PERCENT_STAKE;
      END IF;

      IF (x_kle_rec.AMOUNT_STAKE = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.AMOUNT_STAKE := l_kle_rec.AMOUNT_STAKE;
      END IF;

      IF (x_kle_rec.DATE_SOLD = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_SOLD := l_kle_rec.DATE_SOLD;
      END IF;

      IF (x_kle_rec.STY_ID_FOR = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.STY_ID_FOR := l_kle_rec.STY_ID_FOR;
      END IF;

      IF (x_kle_rec.ATTRIBUTE_CATEGORY = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE_CATEGORY := l_kle_rec.ATTRIBUTE_CATEGORY;
      END IF;

      IF (x_kle_rec.ATTRIBUTE1 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE1 := l_kle_rec.ATTRIBUTE1;
      END IF;

      IF (x_kle_rec.ATTRIBUTE2 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE2 := l_kle_rec.ATTRIBUTE2;
      END IF;

      IF (x_kle_rec.ATTRIBUTE3 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE3 := l_kle_rec.ATTRIBUTE3;
      END IF;

      IF (x_kle_rec.ATTRIBUTE4 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE4 := l_kle_rec.ATTRIBUTE4;
      END IF;

      IF (x_kle_rec.ATTRIBUTE5 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE5 := l_kle_rec.ATTRIBUTE5;
      END IF;

      IF (x_kle_rec.ATTRIBUTE6 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE6 := l_kle_rec.ATTRIBUTE6;
      END IF;

      IF (x_kle_rec.ATTRIBUTE7 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE7 := l_kle_rec.ATTRIBUTE7;
      END IF;

      IF (x_kle_rec.ATTRIBUTE8 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE8 := l_kle_rec.ATTRIBUTE8;
      END IF;

      IF (x_kle_rec.ATTRIBUTE9 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE9 := l_kle_rec.ATTRIBUTE9;
      END IF;

      IF (x_kle_rec.ATTRIBUTE10 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE10 := l_kle_rec.ATTRIBUTE10;
      END IF;

      IF (x_kle_rec.ATTRIBUTE11 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE11 := l_kle_rec.ATTRIBUTE11;
      END IF;

      IF (x_kle_rec.ATTRIBUTE12 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE12 := l_kle_rec.ATTRIBUTE12;
      END IF;

      IF (x_kle_rec.ATTRIBUTE13 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE13 := l_kle_rec.ATTRIBUTE13;
      END IF;

      IF (x_kle_rec.ATTRIBUTE14 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE14 := l_kle_rec.ATTRIBUTE14;
      END IF;

      IF (x_kle_rec.ATTRIBUTE15 = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.ATTRIBUTE15 := l_kle_rec.ATTRIBUTE15;
      END IF;

      IF (x_kle_rec.CREATED_BY = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.CREATED_BY := l_kle_rec.CREATED_BY;
      END IF;

      IF (x_kle_rec.CREATION_DATE = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.CREATION_DATE := l_kle_rec.CREATION_DATE;
      END IF;

      IF (x_kle_rec.LAST_UPDATED_BY = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.LAST_UPDATED_BY := l_kle_rec.LAST_UPDATED_BY;
      END IF;

      IF (x_kle_rec.LAST_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.LAST_UPDATE_DATE := l_kle_rec.LAST_UPDATE_DATE;
      END IF;

      IF (x_kle_rec.LAST_UPDATE_LOGIN = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.LAST_UPDATE_LOGIN := l_kle_rec.LAST_UPDATE_LOGIN;
      END IF;

      IF (x_kle_rec.NTY_CODE = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.NTY_CODE := l_kle_rec.NTY_CODE;
      END IF;

      IF (x_kle_rec.FCG_CODE = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.FCG_CODE := l_kle_rec.FCG_CODE;
      END IF;

      IF (x_kle_rec.PRC_CODE = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.PRC_CODE := l_kle_rec.PRC_CODE;
      END IF;

      IF (x_kle_rec.RE_LEASE_YN = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.RE_LEASE_YN := l_kle_rec.RE_LEASE_YN;
      END IF;

      IF (x_kle_rec.PRESCRIBED_ASSET_YN = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.PRESCRIBED_ASSET_YN := l_kle_rec.PRESCRIBED_ASSET_YN;
      END IF;

      IF (x_kle_rec.CREDIT_TENANT_YN = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.CREDIT_TENANT_YN := l_kle_rec.CREDIT_TENANT_YN;
      END IF;

      IF (x_kle_rec.SECURED_DEAL_YN = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.SECURED_DEAL_YN := l_kle_rec.SECURED_DEAL_YN;
      END IF;

      IF (x_kle_rec.CLG_ID = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.CLG_ID := l_kle_rec.CLG_ID;
      END IF;

      IF (x_kle_rec.DATE_FUNDING = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_FUNDING := l_kle_rec.DATE_FUNDING;
      END IF;

      IF (x_kle_rec.DATE_FUNDING_REQUIRED = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_FUNDING_REQUIRED := l_kle_rec.DATE_FUNDING_REQUIRED;
      END IF;

      IF (x_kle_rec.DATE_ACCEPTED = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_ACCEPTED := l_kle_rec.DATE_ACCEPTED;
      END IF;

      IF (x_kle_rec.DATE_DELIVERY_EXPECTED = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_DELIVERY_EXPECTED := l_kle_rec.DATE_DELIVERY_EXPECTED;
      END IF;

      IF (x_kle_rec.OEC = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.OEC := l_kle_rec.OEC;
      END IF;

      IF (x_kle_rec.CAPITAL_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.CAPITAL_AMOUNT := l_kle_rec.CAPITAL_AMOUNT;
      END IF;

      IF (x_kle_rec.RESIDUAL_GRNTY_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.RESIDUAL_GRNTY_AMOUNT := l_kle_rec.RESIDUAL_GRNTY_AMOUNT;
      END IF;

      IF (x_kle_rec.RESIDUAL_CODE = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.RESIDUAL_CODE := l_kle_rec.RESIDUAL_CODE;
      END IF;

      IF (x_kle_rec.RVI_PREMIUM = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.RVI_PREMIUM := l_kle_rec.RVI_PREMIUM;
      END IF;

      IF (x_kle_rec.CREDIT_NATURE = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.CREDIT_NATURE := l_kle_rec.CREDIT_NATURE;
      END IF;

      IF (x_kle_rec.CAPITALIZED_INTEREST = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.CAPITALIZED_INTEREST := l_kle_rec.CAPITALIZED_INTEREST;
      END IF;

      IF (x_kle_rec.CAPITAL_REDUCTION_PERCENT = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.CAPITAL_REDUCTION_PERCENT := l_kle_rec.CAPITAL_REDUCTION_PERCENT;
      END IF;

      IF (x_kle_rec.DATE_PAY_INVESTOR_START = OKC_API.G_MISS_DATE) THEN
      x_kle_rec.DATE_PAY_INVESTOR_START := l_kle_rec.DATE_PAY_INVESTOR_START;
      END IF;

      IF (x_kle_rec.PAY_INVESTOR_FREQUENCY = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.PAY_INVESTOR_FREQUENCY := l_kle_rec.PAY_INVESTOR_FREQUENCY;
      END IF;

      IF (x_kle_rec.PAY_INVESTOR_EVENT = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.PAY_INVESTOR_EVENT := l_kle_rec.PAY_INVESTOR_EVENT;
      END IF;

      IF (x_kle_rec.PAY_INVESTOR_REMITTANCE_DAYS = OKC_API.G_MISS_NUM) THEN
      x_kle_rec.PAY_INVESTOR_REMITTANCE_DAYS := l_kle_rec.PAY_INVESTOR_REMITTANCE_DAYS;
      END IF;

      IF (x_kle_rec.FEE_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_kle_rec.FEE_TYPE := l_kle_rec.FEE_TYPE;
      END IF;

--Bug# 3143522: 11.5.10
--subsidy
   IF (x_kle_rec.SUBSIDY_ID = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUBSIDY_ID := l_kle_rec.SUBSIDY_ID;
   END IF;
   --IF (x_kle_rec.SUBSIDIZED_OEC = OKL_API.G_MISS_NUM) THEN
       --x_kle_rec.SUBSIDIZED_OEC := l_kle_rec.SUBSIDIZED_OEC;
   --END IF;
   --IF (x_kle_rec.SUBSIDIZED_CAP_AMOUNT = OKL_API.G_MISS_NUM) THEN
       --x_kle_rec.SUBSIDIZED_CAP_AMOUNT := l_kle_rec.SUBSIDIZED_CAP_AMOUNT;
   --END IF;
   IF (x_kle_rec.SUBSIDY_OVERRIDE_AMOUNT = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUBSIDY_OVERRIDE_AMOUNT := l_kle_rec.SUBSIDY_OVERRIDE_AMOUNT;
   END IF;
   --financed fee
   IF (x_kle_rec.PRE_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.PRE_TAX_YIELD := l_kle_rec.PRE_TAX_YIELD;
   END IF;
   IF (x_kle_rec.AFTER_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.AFTER_TAX_YIELD := l_kle_rec.AFTER_TAX_YIELD;
   END IF;
   IF (x_kle_rec.IMPLICIT_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.IMPLICIT_INTEREST_RATE := l_kle_rec.IMPLICIT_INTEREST_RATE;
   END IF;
   IF (x_kle_rec.IMPLICIT_NON_IDC_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.IMPLICIT_NON_IDC_INTEREST_RATE := l_kle_rec.IMPLICIT_NON_IDC_INTEREST_RATE;
   END IF;
   IF (x_kle_rec.PRE_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.PRE_TAX_IRR := l_kle_rec.PRE_TAX_IRR;
   END IF;
   IF (x_kle_rec.AFTER_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.AFTER_TAX_IRR := l_kle_rec.AFTER_TAX_IRR;
   END IF;
--quote
   IF (x_kle_rec.SUB_PRE_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUB_PRE_TAX_YIELD := l_kle_rec.SUB_PRE_TAX_YIELD;
   END IF;
   IF (x_kle_rec.SUB_AFTER_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUB_AFTER_TAX_YIELD := l_kle_rec.SUB_AFTER_TAX_YIELD;
   END IF;
   IF (x_kle_rec.SUB_IMPL_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUB_IMPL_INTEREST_RATE := l_kle_rec.SUB_IMPL_INTEREST_RATE;
   END IF;
   IF (x_kle_rec.SUB_IMPL_NON_IDC_INT_RATE = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUB_IMPL_NON_IDC_INT_RATE := l_kle_rec.SUB_IMPL_NON_IDC_INT_RATE;
   END IF;
   IF (x_kle_rec.SUB_PRE_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUB_PRE_TAX_IRR := l_kle_rec.SUB_PRE_TAX_IRR;
   END IF;
   IF (x_kle_rec.SUB_AFTER_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.SUB_AFTER_TAX_IRR := l_kle_rec.SUB_AFTER_TAX_IRR;
   END IF;
--Bug# 2994971
   IF (x_kle_rec.ITEM_INSURANCE_CATEGORY = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.ITEM_INSURANCE_CATEGORY := l_kle_rec.ITEM_INSURANCE_CATEGORY;
   END IF;
--Bug# 3973640 :11.5.10+
   IF (x_kle_rec.QTE_ID = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.QTE_ID := l_kle_rec.QTE_ID;
   END IF;
   IF (x_kle_rec.FUNDING_DATE = OKL_API.G_MISS_DATE) THEN
       x_kle_rec.FUNDING_DATE := l_kle_rec.FUNDING_DATE;
   END IF;
   IF (x_kle_rec.STREAM_TYPE_SUBCLASS = OKL_API.G_MISS_CHAR) THEN
       x_kle_rec.STREAM_TYPE_SUBCLASS := l_kle_rec.STREAM_TYPE_SUBCLASS;
   END IF;

--Bug# 4419339  OKLH
   IF (x_kle_rec.DATE_FUNDING_EXPECTED = OKL_API.G_MISS_DATE) THEN
       x_kle_rec.DATE_FUNDING_EXPECTED := l_kle_rec.DATE_FUNDING_EXPECTED;
   END IF;

   IF (x_kle_rec.MANUFACTURER_NAME = OKL_API.G_MISS_CHAR) THEN
       x_kle_rec.MANUFACTURER_NAME := l_kle_rec.MANUFACTURER_NAME;
   END IF;

   IF (x_kle_rec.MODEL_NUMBER = OKL_API.G_MISS_CHAR) THEN
       x_kle_rec.MODEL_NUMBER := l_kle_rec.MODEL_NUMBER;
   END IF;

   IF (x_kle_rec.DOWN_PAYMENT_RECEIVER_CODE = OKL_API.G_MISS_CHAR) THEN
       x_kle_rec.DOWN_PAYMENT_RECEIVER_CODE := l_kle_rec.DOWN_PAYMENT_RECEIVER_CODE;
   END IF;

   IF (x_kle_rec.CAPITALIZE_DOWN_PAYMENT_YN = OKL_API.G_MISS_CHAR) THEN
       x_kle_rec.CAPITALIZE_DOWN_PAYMENT_YN := l_kle_rec.CAPITALIZE_DOWN_PAYMENT_YN;
   END IF;

   IF (x_kle_rec.FEE_PURPOSE_CODE = OKL_API.G_MISS_CHAR) THEN
       x_kle_rec.FEE_PURPOSE_CODE := l_kle_rec.FEE_PURPOSE_CODE;
   END IF;

   IF (x_kle_rec.TERMINATION_VALUE = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.TERMINATION_VALUE := l_kle_rec.TERMINATION_VALUE;
   END IF;

   --Bug# 4631549
   IF (x_kle_rec.EXPECTED_ASSET_COST = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.EXPECTED_ASSET_COST := l_kle_rec.EXPECTED_ASSET_COST;
   END IF;

   IF (x_kle_rec.ORIG_CONTRACT_LINE_ID = OKL_API.G_MISS_NUM) THEN
       x_kle_rec.ORIG_CONTRACT_LINE_ID := l_kle_rec.ORIG_CONTRACT_LINE_ID;
   END IF;



      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for: OKL_K_LINES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_kle_rec IN  kle_rec_type,
      x_kle_rec OUT NOCOPY kle_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_kle_rec := p_kle_rec;
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
      p_kle_rec,                         -- IN
      l_kle_rec);                        -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_kle_rec, l_def_kle_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_K_LINES
    SET
    ID = l_def_kle_rec.ID,
        KLE_ID = l_def_kle_rec.KLE_ID,
        STY_ID = l_def_kle_rec.STY_ID,
        OBJECT_VERSION_NUMBER = l_def_kle_rec.OBJECT_VERSION_NUMBER,
        LAO_AMOUNT = l_def_kle_rec.LAO_AMOUNT,
        FEE_CHARGE = l_def_kle_rec.FEE_CHARGE,
        TITLE_DATE = l_def_kle_rec.TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW = l_def_kle_rec.DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION = l_def_kle_rec.DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT = l_def_kle_rec.TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP = l_def_kle_rec.DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT = l_def_kle_rec.REMARKETED_AMOUNT,
        DATE_REMARKETED = l_def_kle_rec.DATE_REMARKETED,
        REMARKET_MARGIN = l_def_kle_rec.REMARKET_MARGIN,
        REPURCHASED_AMOUNT = l_def_kle_rec.REPURCHASED_AMOUNT,
        DATE_REPURCHASED = l_def_kle_rec.DATE_REPURCHASED,
        GAIN_LOSS = l_def_kle_rec.GAIN_LOSS,
        FLOOR_AMOUNT = l_def_kle_rec.FLOOR_AMOUNT,
        PREVIOUS_CONTRACT = l_def_kle_rec.PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL = l_def_kle_rec.TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED = l_def_kle_rec.DATE_TITLE_RECEIVED,
        ESTIMATED_OEC = l_def_kle_rec.ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE = l_def_kle_rec.RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION = l_def_kle_rec.CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID = l_def_kle_rec.VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT = l_def_kle_rec.TRADEIN_AMOUNT,
        DELIVERED_DATE = l_def_kle_rec.DELIVERED_DATE,
        YEAR_OF_MANUFACTURE = l_def_kle_rec.YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST = l_def_kle_rec.INITIAL_DIRECT_COST,
        OCCUPANCY = l_def_kle_rec.OCCUPANCY,
        DATE_LAST_INSPECTION = l_def_kle_rec.DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE = l_def_kle_rec.DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE = l_def_kle_rec.WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD = l_def_kle_rec.BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT = l_def_kle_rec.REFINANCE_AMOUNT,
        YEAR_BUILT = l_def_kle_rec.YEAR_BUILT,
        COVERAGE_RATIO = l_def_kle_rec.COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE = l_def_kle_rec.GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE = l_def_kle_rec.NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE = l_def_kle_rec.DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION = l_def_kle_rec.DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL = l_def_kle_rec.DATE_APPRAISAL,
        APPRAISAL_VALUE = l_def_kle_rec.APPRAISAL_VALUE,
        RESIDUAL_VALUE = l_def_kle_rec.RESIDUAL_VALUE,
        PERCENT = l_def_kle_rec.PERCENT,
        COVERAGE = l_def_kle_rec.COVERAGE,
        LRV_AMOUNT = l_def_kle_rec.LRV_AMOUNT,
        AMOUNT = l_def_kle_rec.AMOUNT,
        LRS_PERCENT = l_def_kle_rec.LRS_PERCENT,
        EVERGREEN_PERCENT = l_def_kle_rec.EVERGREEN_PERCENT,
        PERCENT_STAKE = l_def_kle_rec.PERCENT_STAKE,
        AMOUNT_STAKE = l_def_kle_rec.AMOUNT_STAKE,
        DATE_SOLD = l_def_kle_rec.DATE_SOLD,
        STY_ID_FOR = l_def_kle_rec.STY_ID_FOR,
        ATTRIBUTE_CATEGORY = l_def_kle_rec.ATTRIBUTE_CATEGORY,
        ATTRIBUTE1 = l_def_kle_rec.ATTRIBUTE1,
        ATTRIBUTE2 = l_def_kle_rec.ATTRIBUTE2,
        ATTRIBUTE3 = l_def_kle_rec.ATTRIBUTE3,
        ATTRIBUTE4 = l_def_kle_rec.ATTRIBUTE4,
        ATTRIBUTE5 = l_def_kle_rec.ATTRIBUTE5,
        ATTRIBUTE6 = l_def_kle_rec.ATTRIBUTE6,
        ATTRIBUTE7 = l_def_kle_rec.ATTRIBUTE7,
        ATTRIBUTE8 = l_def_kle_rec.ATTRIBUTE8,
        ATTRIBUTE9 = l_def_kle_rec.ATTRIBUTE9,
        ATTRIBUTE10 = l_def_kle_rec.ATTRIBUTE10,
        ATTRIBUTE11 = l_def_kle_rec.ATTRIBUTE11,
        ATTRIBUTE12 = l_def_kle_rec.ATTRIBUTE12,
        ATTRIBUTE13 = l_def_kle_rec.ATTRIBUTE13,
        ATTRIBUTE14 = l_def_kle_rec.ATTRIBUTE14,
        ATTRIBUTE15 = l_def_kle_rec.ATTRIBUTE15,
        CREATED_BY = l_def_kle_rec.CREATED_BY,
        CREATION_DATE = l_def_kle_rec.CREATION_DATE,
        LAST_UPDATED_BY = l_def_kle_rec.LAST_UPDATED_BY,
        LAST_UPDATE_DATE = l_def_kle_rec.LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN = l_def_kle_rec.LAST_UPDATE_LOGIN,
        NTY_CODE = l_def_kle_rec.NTY_CODE,
        FCG_CODE = l_def_kle_rec.FCG_CODE,
        PRC_CODE = l_def_kle_rec.PRC_CODE,
        RE_LEASE_YN = l_def_kle_rec.RE_LEASE_YN,
        PRESCRIBED_ASSET_YN = l_def_kle_rec.PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN = l_def_kle_rec.CREDIT_TENANT_YN,
        SECURED_DEAL_YN = l_def_kle_rec.SECURED_DEAL_YN,
        CLG_ID = l_def_kle_rec.CLG_ID,
        DATE_FUNDING = l_def_kle_rec.DATE_FUNDING,
        DATE_FUNDING_REQUIRED = l_def_kle_rec.DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED = l_def_kle_rec.DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED = l_def_kle_rec.DATE_DELIVERY_EXPECTED,
        OEC = l_def_kle_rec.OEC,
        CAPITAL_AMOUNT = l_def_kle_rec.CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT = l_def_kle_rec.RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE = l_def_kle_rec.RESIDUAL_CODE,
        RVI_PREMIUM = l_def_kle_rec.RVI_PREMIUM,
        CREDIT_NATURE = l_def_kle_rec.CREDIT_NATURE,
        CAPITALIZED_INTEREST = l_def_kle_rec.CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT = l_def_kle_rec.CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START      = l_def_kle_rec.DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY       = l_def_kle_rec.PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT           = l_def_kle_rec.PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS = l_def_kle_rec.PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE                     = l_def_kle_rec.FEE_TYPE,
--Bug# 3143522 : 11.5.10
   --subsidy
   SUBSIDY_ID = l_def_kle_rec.SUBSIDY_ID,
   --SUBSIDIZED_OEC = l_def_kle_rec.SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT = l_def_kle_rec.SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT = l_def_kle_rec.SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   PRE_TAX_YIELD = l_def_kle_rec.PRE_TAX_YIELD,
   AFTER_TAX_YIELD = l_def_kle_rec.AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE = l_def_kle_rec.IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE = l_def_kle_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR = l_def_kle_rec.PRE_TAX_IRR,
   AFTER_TAX_IRR = l_def_kle_rec.AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD = l_def_kle_rec.SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD = l_def_kle_rec.SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE = l_def_kle_rec.SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE = l_def_kle_rec.SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR = l_def_kle_rec.SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR = l_def_kle_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971
   ITEM_INSURANCE_CATEGORY = l_def_kle_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 :11.5.10+
   QTE_ID = l_def_kle_rec.QTE_ID,
   FUNDING_DATE = l_def_kle_rec.FUNDING_DATE,
   STREAM_TYPE_SUBCLASS = l_def_kle_rec.STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   DATE_FUNDING_EXPECTED = l_def_kle_rec.DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME = l_def_kle_rec.MANUFACTURER_NAME,
   MODEL_NUMBER = l_def_kle_rec.MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE = l_def_kle_rec.DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN = l_def_kle_rec.CAPITALIZE_DOWN_PAYMENT_YN,
   FEE_PURPOSE_CODE = l_def_kle_rec.FEE_PURPOSE_CODE,
   TERMINATION_VALUE = l_def_kle_rec.TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST = l_def_kle_rec.EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID = l_def_kle_rec.ORIG_CONTRACT_LINE_ID

    WHERE ID = l_def_kle_rec.id;

    -- Insert into History table
/*
    insert_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_k_lines_h_rec,
      lx_okl_k_lines_h_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

*/
    x_kle_rec := l_def_kle_rec;
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
  -- update_row for: OKL_K_LINES_V --
  ------------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_rec                     IN klev_rec_type,
    x_klev_rec                     OUT NOCOPY klev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klev_rec                     klev_rec_type := p_klev_rec;
    l_def_klev_rec                 klev_rec_type;
    l_kle_rec kle_rec_type;
    lx_kle_rec kle_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_klev_rec	IN klev_rec_type
    ) RETURN klev_rec_type IS
      l_klev_rec	klev_rec_type := p_klev_rec;
    BEGIN
      l_klev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_klev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_klev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_klev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_klev_rec	IN klev_rec_type,
      x_klev_rec	OUT NOCOPY klev_rec_type
    ) RETURN VARCHAR2 IS
      l_klev_rec                      klev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klev_rec := p_klev_rec;
      -- Get current database values
      l_klev_rec := get_rec(p_klev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;


      IF (x_klev_rec.ID = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.ID := l_klev_rec.ID;
      END IF;

      IF (x_klev_rec.OBJECT_VERSION_NUMBER = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.OBJECT_VERSION_NUMBER := l_klev_rec.OBJECT_VERSION_NUMBER;
      END IF;

      IF (x_klev_rec.KLE_ID = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.KLE_ID := l_klev_rec.KLE_ID;
      END IF;

      IF (x_klev_rec.STY_ID = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.STY_ID := l_klev_rec.STY_ID;
      END IF;

      IF (x_klev_rec.PRC_CODE = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.PRC_CODE := l_klev_rec.PRC_CODE;
      END IF;

      IF (x_klev_rec.FCG_CODE = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.FCG_CODE := l_klev_rec.FCG_CODE;
      END IF;

      IF (x_klev_rec.NTY_CODE = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.NTY_CODE := l_klev_rec.NTY_CODE;
      END IF;

      IF (x_klev_rec.ESTIMATED_OEC = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.ESTIMATED_OEC := l_klev_rec.ESTIMATED_OEC;
      END IF;

      IF (x_klev_rec.LAO_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.LAO_AMOUNT := l_klev_rec.LAO_AMOUNT;
      END IF;

      IF (x_klev_rec.TITLE_DATE = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.TITLE_DATE := l_klev_rec.TITLE_DATE;
      END IF;

      IF (x_klev_rec.FEE_CHARGE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.FEE_CHARGE := l_klev_rec.FEE_CHARGE;
      END IF;

      IF (x_klev_rec.LRS_PERCENT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.LRS_PERCENT := l_klev_rec.LRS_PERCENT;
      END IF;

      IF (x_klev_rec.INITIAL_DIRECT_COST = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.INITIAL_DIRECT_COST := l_klev_rec.INITIAL_DIRECT_COST;
      END IF;

      IF (x_klev_rec.PERCENT_STAKE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.PERCENT_STAKE := l_klev_rec.PERCENT_STAKE;
      END IF;

      IF (x_klev_rec.PERCENT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.PERCENT := l_klev_rec.PERCENT;
      END IF;

      IF (x_klev_rec.EVERGREEN_PERCENT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.EVERGREEN_PERCENT := l_klev_rec.EVERGREEN_PERCENT;
      END IF;

      IF (x_klev_rec.AMOUNT_STAKE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.AMOUNT_STAKE := l_klev_rec.AMOUNT_STAKE;
      END IF;

      IF (x_klev_rec.OCCUPANCY = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.OCCUPANCY := l_klev_rec.OCCUPANCY;
      END IF;

      IF (x_klev_rec.COVERAGE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.COVERAGE := l_klev_rec.COVERAGE;
      END IF;

      IF (x_klev_rec.RESIDUAL_PERCENTAGE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.RESIDUAL_PERCENTAGE := l_klev_rec.RESIDUAL_PERCENTAGE;
      END IF;

      IF (x_klev_rec.DATE_LAST_INSPECTION = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_LAST_INSPECTION := l_klev_rec.DATE_LAST_INSPECTION;
      END IF;

      IF (x_klev_rec.DATE_SOLD = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_SOLD := l_klev_rec.DATE_SOLD;
      END IF;

      IF (x_klev_rec.LRV_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.LRV_AMOUNT := l_klev_rec.LRV_AMOUNT;
      END IF;

      IF (x_klev_rec.CAPITAL_REDUCTION = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.CAPITAL_REDUCTION := l_klev_rec.CAPITAL_REDUCTION;
      END IF;

      IF (x_klev_rec.DATE_NEXT_INSPECTION_DUE = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_NEXT_INSPECTION_DUE := l_klev_rec.DATE_NEXT_INSPECTION_DUE;
      END IF;

      IF (x_klev_rec.DATE_RESIDUAL_LAST_REVIEW = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_RESIDUAL_LAST_REVIEW := l_klev_rec.DATE_RESIDUAL_LAST_REVIEW;
      END IF;

      IF (x_klev_rec.DATE_LAST_REAMORTISATION = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_LAST_REAMORTISATION := l_klev_rec.DATE_LAST_REAMORTISATION;
      END IF;

      IF (x_klev_rec.VENDOR_ADVANCE_PAID = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.VENDOR_ADVANCE_PAID := l_klev_rec.VENDOR_ADVANCE_PAID;
      END IF;

      IF (x_klev_rec.WEIGHTED_AVERAGE_LIFE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.WEIGHTED_AVERAGE_LIFE := l_klev_rec.WEIGHTED_AVERAGE_LIFE;
      END IF;

      IF (x_klev_rec.TRADEIN_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.TRADEIN_AMOUNT := l_klev_rec.TRADEIN_AMOUNT;
      END IF;

      IF (x_klev_rec.BOND_EQUIVALENT_YIELD = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.BOND_EQUIVALENT_YIELD := l_klev_rec.BOND_EQUIVALENT_YIELD;
      END IF;

      IF (x_klev_rec.TERMINATION_PURCHASE_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.TERMINATION_PURCHASE_AMOUNT := l_klev_rec.TERMINATION_PURCHASE_AMOUNT;
      END IF;

      IF (x_klev_rec.REFINANCE_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.REFINANCE_AMOUNT := l_klev_rec.REFINANCE_AMOUNT;
      END IF;

      IF (x_klev_rec.YEAR_BUILT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.YEAR_BUILT := l_klev_rec.YEAR_BUILT;
      END IF;

      IF (x_klev_rec.DELIVERED_DATE = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DELIVERED_DATE := l_klev_rec.DELIVERED_DATE;
      END IF;

      IF (x_klev_rec.CREDIT_TENANT_YN = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.CREDIT_TENANT_YN := l_klev_rec.CREDIT_TENANT_YN;
      END IF;

      IF (x_klev_rec.DATE_LAST_CLEANUP = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_LAST_CLEANUP := l_klev_rec.DATE_LAST_CLEANUP;
      END IF;

      IF (x_klev_rec.YEAR_OF_MANUFACTURE = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.YEAR_OF_MANUFACTURE := l_klev_rec.YEAR_OF_MANUFACTURE;
      END IF;

      IF (x_klev_rec.COVERAGE_RATIO = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.COVERAGE_RATIO := l_klev_rec.COVERAGE_RATIO;
      END IF;

      IF (x_klev_rec.REMARKETED_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.REMARKETED_AMOUNT := l_klev_rec.REMARKETED_AMOUNT;
      END IF;

      IF (x_klev_rec.GROSS_SQUARE_FOOTAGE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.GROSS_SQUARE_FOOTAGE := l_klev_rec.GROSS_SQUARE_FOOTAGE;
      END IF;

      IF (x_klev_rec.PRESCRIBED_ASSET_YN = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.PRESCRIBED_ASSET_YN := l_klev_rec.PRESCRIBED_ASSET_YN;
      END IF;

      IF (x_klev_rec.DATE_REMARKETED = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_REMARKETED := l_klev_rec.DATE_REMARKETED;
      END IF;

      IF (x_klev_rec.NET_RENTABLE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.NET_RENTABLE := l_klev_rec.NET_RENTABLE;
      END IF;

      IF (x_klev_rec.REMARKET_MARGIN = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.REMARKET_MARGIN := l_klev_rec.REMARKET_MARGIN;
      END IF;

      IF (x_klev_rec.DATE_LETTER_ACCEPTANCE = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_LETTER_ACCEPTANCE := l_klev_rec.DATE_LETTER_ACCEPTANCE;
      END IF;

      IF (x_klev_rec.REPURCHASED_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.REPURCHASED_AMOUNT := l_klev_rec.REPURCHASED_AMOUNT;
      END IF;

      IF (x_klev_rec.DATE_COMMITMENT_EXPIRATION = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_COMMITMENT_EXPIRATION := l_klev_rec.DATE_COMMITMENT_EXPIRATION;
      END IF;

      IF (x_klev_rec.DATE_REPURCHASED = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_REPURCHASED := l_klev_rec.DATE_REPURCHASED;
      END IF;

      IF (x_klev_rec.DATE_APPRAISAL = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_APPRAISAL := l_klev_rec.DATE_APPRAISAL;
      END IF;

      IF (x_klev_rec.RESIDUAL_VALUE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.RESIDUAL_VALUE := l_klev_rec.RESIDUAL_VALUE;
      END IF;

      IF (x_klev_rec.APPRAISAL_VALUE = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.APPRAISAL_VALUE := l_klev_rec.APPRAISAL_VALUE;
      END IF;

      IF (x_klev_rec.SECURED_DEAL_YN = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.SECURED_DEAL_YN := l_klev_rec.SECURED_DEAL_YN;
      END IF;

      IF (x_klev_rec.GAIN_LOSS = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.GAIN_LOSS := l_klev_rec.GAIN_LOSS;
      END IF;

      IF (x_klev_rec.FLOOR_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.FLOOR_AMOUNT := l_klev_rec.FLOOR_AMOUNT;
      END IF;

      IF (x_klev_rec.RE_LEASE_YN = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.RE_LEASE_YN := l_klev_rec.RE_LEASE_YN;
      END IF;

      IF (x_klev_rec.PREVIOUS_CONTRACT = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.PREVIOUS_CONTRACT := l_klev_rec.PREVIOUS_CONTRACT;
      END IF;

      IF (x_klev_rec.TRACKED_RESIDUAL = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.TRACKED_RESIDUAL := l_klev_rec.TRACKED_RESIDUAL;
      END IF;

      IF (x_klev_rec.DATE_TITLE_RECEIVED = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_TITLE_RECEIVED := l_klev_rec.DATE_TITLE_RECEIVED;
      END IF;

      IF (x_klev_rec.AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.AMOUNT := l_klev_rec.AMOUNT;
      END IF;

      IF (x_klev_rec.ATTRIBUTE_CATEGORY = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE_CATEGORY := l_klev_rec.ATTRIBUTE_CATEGORY;
      END IF;

      IF (x_klev_rec.ATTRIBUTE1 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE1 := l_klev_rec.ATTRIBUTE1;
      END IF;

      IF (x_klev_rec.ATTRIBUTE2 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE2 := l_klev_rec.ATTRIBUTE2;
      END IF;

      IF (x_klev_rec.ATTRIBUTE3 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE3 := l_klev_rec.ATTRIBUTE3;
      END IF;

      IF (x_klev_rec.ATTRIBUTE4 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE4 := l_klev_rec.ATTRIBUTE4;
      END IF;

      IF (x_klev_rec.ATTRIBUTE5 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE5 := l_klev_rec.ATTRIBUTE5;
      END IF;

      IF (x_klev_rec.ATTRIBUTE6 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE6 := l_klev_rec.ATTRIBUTE6;
      END IF;

      IF (x_klev_rec.ATTRIBUTE7 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE7 := l_klev_rec.ATTRIBUTE7;
      END IF;

      IF (x_klev_rec.ATTRIBUTE8 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE8 := l_klev_rec.ATTRIBUTE8;
      END IF;

      IF (x_klev_rec.ATTRIBUTE9 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE9 := l_klev_rec.ATTRIBUTE9;
      END IF;

      IF (x_klev_rec.ATTRIBUTE10 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE10 := l_klev_rec.ATTRIBUTE10;
      END IF;

      IF (x_klev_rec.ATTRIBUTE11 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE11 := l_klev_rec.ATTRIBUTE11;
      END IF;

      IF (x_klev_rec.ATTRIBUTE12 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE12 := l_klev_rec.ATTRIBUTE12;
      END IF;

      IF (x_klev_rec.ATTRIBUTE13 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE13 := l_klev_rec.ATTRIBUTE13;
      END IF;

      IF (x_klev_rec.ATTRIBUTE14 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE14 := l_klev_rec.ATTRIBUTE14;
      END IF;

      IF (x_klev_rec.ATTRIBUTE15 = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.ATTRIBUTE15 := l_klev_rec.ATTRIBUTE15;
      END IF;

      IF (x_klev_rec.STY_ID_FOR = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.STY_ID_FOR := l_klev_rec.STY_ID_FOR;
      END IF;

      IF (x_klev_rec.CLG_ID = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.CLG_ID := l_klev_rec.CLG_ID;
      END IF;

      IF (x_klev_rec.CREATED_BY = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.CREATED_BY := l_klev_rec.CREATED_BY;
      END IF;

      IF (x_klev_rec.CREATION_DATE = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.CREATION_DATE := l_klev_rec.CREATION_DATE;
      END IF;

      IF (x_klev_rec.LAST_UPDATED_BY = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.LAST_UPDATED_BY := l_klev_rec.LAST_UPDATED_BY;
      END IF;

      IF (x_klev_rec.LAST_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.LAST_UPDATE_DATE := l_klev_rec.LAST_UPDATE_DATE;
      END IF;

      IF (x_klev_rec.LAST_UPDATE_LOGIN = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.LAST_UPDATE_LOGIN := l_klev_rec.LAST_UPDATE_LOGIN;
      END IF;

      IF (x_klev_rec.DATE_FUNDING = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_FUNDING := l_klev_rec.DATE_FUNDING;
      END IF;

      IF (x_klev_rec.DATE_FUNDING_REQUIRED = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_FUNDING_REQUIRED := l_klev_rec.DATE_FUNDING_REQUIRED;
      END IF;

      IF (x_klev_rec.DATE_ACCEPTED = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_ACCEPTED := l_klev_rec.DATE_ACCEPTED;
      END IF;

      IF (x_klev_rec.DATE_DELIVERY_EXPECTED = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_DELIVERY_EXPECTED := l_klev_rec.DATE_DELIVERY_EXPECTED;
      END IF;

      IF (x_klev_rec.OEC = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.OEC := l_klev_rec.OEC;
      END IF;

      IF (x_klev_rec.CAPITAL_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.CAPITAL_AMOUNT := l_klev_rec.CAPITAL_AMOUNT;
      END IF;

      IF (x_klev_rec.RESIDUAL_GRNTY_AMOUNT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.RESIDUAL_GRNTY_AMOUNT := l_klev_rec.RESIDUAL_GRNTY_AMOUNT;
      END IF;

      IF (x_klev_rec.RESIDUAL_CODE = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.RESIDUAL_CODE := l_klev_rec.RESIDUAL_CODE;
      END IF;

      IF (x_klev_rec.RVI_PREMIUM = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.RVI_PREMIUM := l_klev_rec.RVI_PREMIUM;
      END IF;

      IF (x_klev_rec.CREDIT_NATURE = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.CREDIT_NATURE := l_klev_rec.CREDIT_NATURE;
      END IF;

      IF (x_klev_rec.CAPITALIZED_INTEREST = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.CAPITALIZED_INTEREST := l_klev_rec.CAPITALIZED_INTEREST;
      END IF;

      IF (x_klev_rec.CAPITAL_REDUCTION_PERCENT = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.CAPITAL_REDUCTION_PERCENT := l_klev_rec.CAPITAL_REDUCTION_PERCENT;
      END IF;

      IF (x_klev_rec.DATE_PAY_INVESTOR_START = OKC_API.G_MISS_DATE) THEN
      x_klev_rec.DATE_PAY_INVESTOR_START := l_klev_rec.DATE_PAY_INVESTOR_START;
      END IF;

      IF (x_klev_rec.PAY_INVESTOR_FREQUENCY = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.PAY_INVESTOR_FREQUENCY := l_klev_rec.PAY_INVESTOR_FREQUENCY;
      END IF;

      IF (x_klev_rec.PAY_INVESTOR_EVENT = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.PAY_INVESTOR_EVENT := l_klev_rec.PAY_INVESTOR_EVENT;
      END IF;

      IF (x_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS = OKC_API.G_MISS_NUM) THEN
      x_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS := l_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS;
      END IF;
      IF (x_klev_rec.FEE_TYPE = OKC_API.G_MISS_CHAR) THEN
      x_klev_rec.FEE_TYPE := l_klev_rec.FEE_TYPE;
      END IF;
--Bug# 3143522: 11.5.10
--subsidy
   IF (x_klev_rec.SUBSIDY_ID = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUBSIDY_ID := l_klev_rec.SUBSIDY_ID;
   END IF;
   --IF (x_klev_rec.SUBSIDIZED_OEC = OKL_API.G_MISS_NUM) THEN
       --x_klev_rec.SUBSIDIZED_OEC := l_klev_rec.SUBSIDIZED_OEC;
   --END IF;
   --IF (x_klev_rec.SUBSIDIZED_CAP_AMOUNT = OKL_API.G_MISS_NUM) THEN
       --x_klev_rec.SUBSIDIZED_CAP_AMOUNT := l_klev_rec.SUBSIDIZED_CAP_AMOUNT;
   --END IF;
   IF (x_klev_rec.SUBSIDY_OVERRIDE_AMOUNT = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUBSIDY_OVERRIDE_AMOUNT := l_klev_rec.SUBSIDY_OVERRIDE_AMOUNT;
   END IF;
   --financed fee
   IF (x_klev_rec.PRE_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.PRE_TAX_YIELD := l_klev_rec.PRE_TAX_YIELD;
   END IF;
   IF (x_klev_rec.AFTER_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.AFTER_TAX_YIELD := l_klev_rec.AFTER_TAX_YIELD;
   END IF;
   IF (x_klev_rec.IMPLICIT_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.IMPLICIT_INTEREST_RATE := l_klev_rec.IMPLICIT_INTEREST_RATE;
   END IF;
   IF (x_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE := l_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE;
   END IF;
   IF (x_klev_rec.PRE_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.PRE_TAX_IRR := l_klev_rec.PRE_TAX_IRR;
   END IF;
   IF (x_klev_rec.AFTER_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.AFTER_TAX_IRR := l_klev_rec.AFTER_TAX_IRR;
   END IF;
--quote
   IF (x_klev_rec.SUB_PRE_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUB_PRE_TAX_YIELD := l_klev_rec.SUB_PRE_TAX_YIELD;
   END IF;
   IF (x_klev_rec.SUB_AFTER_TAX_YIELD = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUB_AFTER_TAX_YIELD := l_klev_rec.SUB_AFTER_TAX_YIELD;
   END IF;
   IF (x_klev_rec.SUB_IMPL_INTEREST_RATE = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUB_IMPL_INTEREST_RATE := l_klev_rec.SUB_IMPL_INTEREST_RATE;
   END IF;
   IF (x_klev_rec.SUB_IMPL_NON_IDC_INT_RATE = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUB_IMPL_NON_IDC_INT_RATE := l_klev_rec.SUB_IMPL_NON_IDC_INT_RATE;
   END IF;
   IF (x_klev_rec.SUB_PRE_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUB_PRE_TAX_IRR := l_klev_rec.SUB_PRE_TAX_IRR;
   END IF;
   IF (x_klev_rec.SUB_AFTER_TAX_IRR = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.SUB_AFTER_TAX_IRR := l_klev_rec.SUB_AFTER_TAX_IRR;
   END IF;
--Bug# 2994971
   IF (x_klev_rec.ITEM_INSURANCE_CATEGORY = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.ITEM_INSURANCE_CATEGORY := l_klev_rec.ITEM_INSURANCE_CATEGORY;
   END IF;
--Bug# 3973640 :11.5.10+
   IF (x_klev_rec.QTE_ID = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.QTE_ID := l_klev_rec.QTE_ID;
   END IF;
   IF (x_klev_rec.FUNDING_DATE = OKL_API.G_MISS_DATE) THEN
       x_klev_rec.FUNDING_DATE := l_klev_rec.FUNDING_DATE;
   END IF;
   IF (x_klev_rec.STREAM_TYPE_SUBCLASS = OKL_API.G_MISS_CHAR) THEN
       x_klev_rec.STREAM_TYPE_SUBCLASS := l_klev_rec.STREAM_TYPE_SUBCLASS;
   END IF;

--Bug# 4419339  OKLH
   IF (x_klev_rec.DATE_FUNDING_EXPECTED = OKL_API.G_MISS_DATE) THEN
       x_klev_rec.DATE_FUNDING_EXPECTED := l_klev_rec.DATE_FUNDING_EXPECTED;
   END IF;

   IF (x_klev_rec.MANUFACTURER_NAME = OKL_API.G_MISS_CHAR) THEN
       x_klev_rec.MANUFACTURER_NAME := l_klev_rec.MANUFACTURER_NAME;
   END IF;

   IF (x_klev_rec.MODEL_NUMBER = OKL_API.G_MISS_CHAR) THEN
       x_klev_rec.MODEL_NUMBER := l_klev_rec.MODEL_NUMBER;
   END IF;

   IF (x_klev_rec.DOWN_PAYMENT_RECEIVER_CODE = OKL_API.G_MISS_CHAR) THEN
       x_klev_rec.DOWN_PAYMENT_RECEIVER_CODE := l_klev_rec.DOWN_PAYMENT_RECEIVER_CODE;
   END IF;

   IF (x_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN = OKL_API.G_MISS_CHAR) THEN
       x_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN := l_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN;
   END IF;

   IF (x_klev_rec.FEE_PURPOSE_CODE = OKL_API.G_MISS_CHAR) THEN
       x_klev_rec.FEE_PURPOSE_CODE := l_klev_rec.FEE_PURPOSE_CODE;
   END IF;

   IF (x_klev_rec.TERMINATION_VALUE = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.TERMINATION_VALUE := l_klev_rec.TERMINATION_VALUE;
   END IF;

   --Bug# 4631549
   IF (x_klev_rec.EXPECTED_ASSET_COST = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.EXPECTED_ASSET_COST := l_klev_rec.EXPECTED_ASSET_COST;
   END IF;

   IF (x_klev_rec.ORIG_CONTRACT_LINE_ID = OKL_API.G_MISS_NUM) THEN
       x_klev_rec.ORIG_CONTRACT_LINE_ID := l_klev_rec.ORIG_CONTRACT_LINE_ID;
   END IF;


   RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:  OKL_K_LINES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_klev_rec IN  klev_rec_type,
      x_klev_rec OUT NOCOPY klev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_klev_rec := p_klev_rec;
      x_klev_rec.OBJECT_VERSION_NUMBER := NVL(x_klev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_klev_rec,                        -- IN
      l_klev_rec);                       -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_klev_rec, l_def_klev_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_klev_rec := fill_who_columns(l_def_klev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_klev_rec);
    --- If any errors happen abort API

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_klev_rec);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_klev_rec, l_kle_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_kle_rec,
      lx_kle_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_kle_rec, l_def_klev_rec);
    x_klev_rec := l_def_klev_rec;
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
  -- PL/SQL TBL update_row for: OKL_K_LINES_V --
  ----------------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_tbl                     IN klev_tbl_type,
    x_klev_tbl                     OUT NOCOPY klev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klev_tbl.COUNT > 0) THEN
      i := p_klev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_klev_rec                     => p_klev_tbl(i),
          x_klev_rec                     => x_klev_tbl(i));
        EXIT WHEN (i = p_klev_tbl.LAST);
        i := p_klev_tbl.NEXT(i);
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
  -- delete_row for: OKL_K_LINES --
  ----------------------------------

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_kle_rec                     IN kle_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_kle_rec                      kle_rec_type:= p_kle_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    l_okl_k_lines_h_rec okl_k_lines_h_rec_type;
    lx_okl_k_lines_h_rec okl_k_lines_h_rec_type;
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

/*
    -- Insert into History table
    l_kle_rec := get_rec(l_kle_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    migrate(l_kle_rec, l_okl_k_lines_h_rec);
    insert_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_k_lines_h_rec,
      lx_okl_k_lines_h_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
    DELETE FROM OKL_K_LINES
     WHERE ID = l_kle_rec.id;

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
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_rec                     IN klev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'rec_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_klev_rec                     klev_rec_type := p_klev_rec;
    l_kle_rec kle_rec_type;
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
    migrate(l_klev_rec, l_kle_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      l_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_kle_rec
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
  -- PL/SQL TBL delete_row for: OKL_K_LINES_V --
  ----------------------------------------

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_klev_tbl                     IN klev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_klev_tbl.COUNT > 0) THEN
      i := p_klev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_klev_rec                     => p_klev_tbl(i));
        EXIT WHEN (i = p_klev_tbl.LAST);
        i := p_klev_tbl.NEXT(i);
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
    p_chr_id IN NUMBER,
    p_major_version IN NUMBER) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO OKL_K_LINES_H
  (
      major_version,
	ID,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--Bug# 2994971
   ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 :11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID

)
  SELECT
      p_major_version,
	ID,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--Bug# 2994971
   ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 : 11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID

  FROM OKL_K_LINES
  WHERE id in (select id from okc_k_lines_b where dnz_chr_id = p_chr_id);

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
    p_chr_id IN NUMBER,
    p_major_version IN NUMBER) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN
INSERT INTO OKL_K_LINES
  (
	ID,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug#3143522 : 11.5.10
   --subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--Bug# 2994971
   ITEM_INSURANCE_CATEGORY,
--Bug# 3973640:11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339  OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
--Bug#4373029
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST ,
   ORIG_CONTRACT_LINE_ID

)
  SELECT
	ID,
        KLE_ID,
        STY_ID,
        OBJECT_VERSION_NUMBER,
        LAO_AMOUNT,
        FEE_CHARGE,
        TITLE_DATE,
        DATE_RESIDUAL_LAST_REVIEW,
        DATE_LAST_REAMORTISATION,
        TERMINATION_PURCHASE_AMOUNT,
        DATE_LAST_CLEANUP,
        REMARKETED_AMOUNT,
        DATE_REMARKETED,
        REMARKET_MARGIN,
        REPURCHASED_AMOUNT,
        DATE_REPURCHASED,
        GAIN_LOSS,
        FLOOR_AMOUNT,
        PREVIOUS_CONTRACT,
        TRACKED_RESIDUAL,
        DATE_TITLE_RECEIVED,
        ESTIMATED_OEC,
        RESIDUAL_PERCENTAGE,
        CAPITAL_REDUCTION,
        VENDOR_ADVANCE_PAID,
        TRADEIN_AMOUNT,
        DELIVERED_DATE,
        YEAR_OF_MANUFACTURE,
        INITIAL_DIRECT_COST,
        OCCUPANCY,
        DATE_LAST_INSPECTION,
        DATE_NEXT_INSPECTION_DUE,
        WEIGHTED_AVERAGE_LIFE,
        BOND_EQUIVALENT_YIELD,
        REFINANCE_AMOUNT,
        YEAR_BUILT,
        COVERAGE_RATIO,
        GROSS_SQUARE_FOOTAGE,
        NET_RENTABLE,
        DATE_LETTER_ACCEPTANCE,
        DATE_COMMITMENT_EXPIRATION,
        DATE_APPRAISAL,
        APPRAISAL_VALUE,
        RESIDUAL_VALUE,
        PERCENT,
        COVERAGE,
        LRV_AMOUNT,
        AMOUNT,
        LRS_PERCENT,
        EVERGREEN_PERCENT,
        PERCENT_STAKE,
        AMOUNT_STAKE,
        DATE_SOLD,
        STY_ID_FOR,
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
        NTY_CODE,
        FCG_CODE,
        PRC_CODE,
        RE_LEASE_YN,
        PRESCRIBED_ASSET_YN,
        CREDIT_TENANT_YN,
        SECURED_DEAL_YN,
        CLG_ID,
        DATE_FUNDING,
        DATE_FUNDING_REQUIRED,
        DATE_ACCEPTED,
        DATE_DELIVERY_EXPECTED,
        OEC,
        CAPITAL_AMOUNT,
        RESIDUAL_GRNTY_AMOUNT,
        RESIDUAL_CODE,
        RVI_PREMIUM,
        CREDIT_NATURE,
        CAPITALIZED_INTEREST,
        CAPITAL_REDUCTION_PERCENT,
--Bug# 2697681 11.5.9
        DATE_PAY_INVESTOR_START,
        PAY_INVESTOR_FREQUENCY,
        PAY_INVESTOR_EVENT,
        PAY_INVESTOR_REMITTANCE_DAYS,
--financed fees
        FEE_TYPE,
--Bug#3143522 11.5.10
   --subsidy
   SUBSIDY_ID,
   --SUBSIDIZED_OEC,
   --SUBSIDIZED_CAP_AMOUNT,
   SUBSIDY_OVERRIDE_AMOUNT,
   --financed fee
   PRE_TAX_YIELD,
   AFTER_TAX_YIELD,
   IMPLICIT_INTEREST_RATE,
   IMPLICIT_NON_IDC_INTEREST_RATE,
   PRE_TAX_IRR,
   AFTER_TAX_IRR,
--quote
   SUB_PRE_TAX_YIELD,
   SUB_AFTER_TAX_YIELD,
   SUB_IMPL_INTEREST_RATE,
   SUB_IMPL_NON_IDC_INT_RATE,
   SUB_PRE_TAX_IRR,
   SUB_AFTER_TAX_IRR,
--Bug#2994971
   ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 :11.5.10+
   QTE_ID,
   FUNDING_DATE,
   STREAM_TYPE_SUBCLASS,
--Bug# 4419339 :OKLH
   DATE_FUNDING_EXPECTED,
   MANUFACTURER_NAME,
   MODEL_NUMBER,
   DOWN_PAYMENT_RECEIVER_CODE,
   CAPITALIZE_DOWN_PAYMENT_YN,
--Bug# 4373029 : OKLH Sales Tax
   FEE_PURPOSE_CODE,
   TERMINATION_VALUE,
--Bug# 4631549
   EXPECTED_ASSET_COST,
   ORIG_CONTRACT_LINE_ID

  FROM OKL_K_LINES_H
  WHERE id in (select id from okc_k_lines_b where dnz_chr_id = p_chr_id) and major_version = p_major_version;


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


END OKL_KLE_PVT;

/
