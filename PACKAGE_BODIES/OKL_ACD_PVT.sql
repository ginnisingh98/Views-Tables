--------------------------------------------------------
--  DDL for Package Body OKL_ACD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACD_PVT" AS
/* $Header: OKLSACDB.pls 120.3 2006/07/13 12:48:24 adagur noship $ */
----------------------------------------
  -- Developer Generated Code here --
  -- Developer : Guru Kadarkaraisamy --
  -- Date : April 15 2001 --
  -- Reason : Added code so that the validation functionality is accomplished --
  ----------------------------------------

G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) :='OKC_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) :='OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_VALIDATION exception;

  -- Start of comments
  --
  -- Procedure Name  : validate_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_id(
	x_return_status out nocopy VARCHAR2,
	p_acdv_rec		in	acdv_rec_type) is

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acdv_rec.id is null) or (p_acdv_rec.id = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  exception
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

  end validate_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_object_version_number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_object_version_number(
	x_return_status out nocopy VARCHAR2,
	p_acdv_rec		in	acdv_rec_type) is

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acdv_rec.object_version_number is null) or (p_acdv_rec.object_version_number = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'object_version_number');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

  exception
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

  end validate_object_version_number;

  -- Start of comments
  --
  -- Procedure Name  : validate_cdn_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_cdn_code(
	x_return_status out nocopy VARCHAR2,
	p_acdv_rec		in	acdv_rec_type) is
	l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin
         -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acdv_rec.cdn_code is null) or (p_acdv_rec.cdn_code = OKC_API.G_MISS_CHAR) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'cdn_code');


      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

     l_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_ASSET_CONDITION'
						,p_lookup_code 	=>	p_acdv_rec.cdn_code);

     IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                      	    p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'cdn_code');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  exception
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

  end validate_cdn_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_iln_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_iln_id(
	x_return_status out nocopy VARCHAR2,
	p_acdv_rec		in	acdv_rec_type) is

	l_dummy_var	VARCHAR2(1) := '?';
-- select the ID of the parent record from the parent table
/*   CURSOR l_ilnv_csr IS
   select 'x' from OKX_LOCATION_V
   where ID = p_acdv_rec.iln_id; */

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acdv_rec.iln_id is null) or (p_acdv_rec.iln_id = OKC_API.G_MISS_NUM) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'iln_id');


      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

 -- enforce foreign key
/*    OPEN  l_ilnv_csr;
      FETCH l_ilnv_csr INTO l_dummy_var;
    CLOSE l_ilnv_csr;

    -- if l_dummy_var is still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			          p_msg_name		=> G_NO_PARENT_RECORD,
      			          p_token1		    => G_COL_NAME_TOKEN,
      			          p_token1_value	=> 'iln_id',
      			          p_token2		    => G_CHILD_TABLE_TOKEN,
                          p_token2_value	=> 'OKL_ASSET_CNDTNS_V',
      			          p_token3		    => G_PARENT_TABLE_TOKEN,
      			          p_token3_value	=> 'OKX_LOCATION_V');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF; */

  exception
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

  -- verify that cursor was closed
/*    IF l_ilnv_csr%ISOPEN THEN
      CLOSE l_ilnv_csr;
    END IF; */

  end validate_iln_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_isp_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_isp_id(
	x_return_status out nocopy VARCHAR2,
	p_acdv_rec		in	acdv_rec_type) is
	l_dummy_var	VARCHAR2(1) := '?';
-- select the ID of the parent record from the parent table

/*    CURSOR l_ispv_csr IS
       select 'x' from OKX_INSPECTORS_V
       where ID = p_acdv_rec.isp_id; */

  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_acdv_rec.isp_id is null) or (p_acdv_rec.isp_id = OKC_API.G_MISS_NUM) then

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_INSPECTOR'));

/*
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'isp_id');
*/

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      raise G_EXCEPTION_HALT_VALIDATION;
    end if;

 -- enforce foreign key
/*    OPEN  l_ispv_csr;
      FETCH l_ispv_csr INTO l_dummy_var;
    CLOSE l_ispv_csr;

    -- if l_dummy_var is still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			          p_msg_name		=> G_NO_PARENT_RECORD,
      			          p_token1		    => G_COL_NAME_TOKEN,
      			          p_token1_value	=> 'isp_id',
      			          p_token2		    => G_CHILD_TABLE_TOKEN,
                          p_token2_value	=> 'OKL_ASSET_CNDTNS_V',
      			          p_token3		    => G_PARENT_TABLE_TOKEN,
      			          p_token3_value	=> 'OKX_INSPECTORS_V');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF; */

  exception
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

 /*-- verify that cursor was closed
    IF l_ispv_csr%ISOPEN THEN
      CLOSE l_ispv_csr;
    END IF; */

end validate_isp_id;

PROCEDURE validate_org_id(
 x_return_status OUT NOCOPY VARCHAR2,
 p_acdv_rec  IN acdv_rec_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF ((p_acdv_rec.org_id IS NULL) OR (p_acdv_rec.org_id = OKC_API.G_MISS_NUM)) THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- check org id validity using the generic function okl_util.check_org_id()
    l_return_status := OKL_UTIL.check_org_id (p_acdv_rec.org_id);

    IF ( l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'org_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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

  END validate_org_id;

--  Foreign Key Validation

-- Start of comments
  --
  -- Procedure Name  : validate_clm_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_clm_id(
   	    x_return_status OUT NOCOPY VARCHAR2,
		p_acdv_rec IN acdv_rec_type
) IS
CURSOR l_clm_csr IS
select 'x' from OKL_INS_CLAIMS_B
where ID = p_acdv_rec.clm_id;
l_dummy_var	VARCHAR2(1) := '?';

begin
-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF ((p_acdv_rec.clm_id IS NOT NULL) AND (p_acdv_rec.clm_id <> OKC_API.G_MISS_NUM)) THEN
      OPEN  l_clm_csr;
      FETCH l_clm_csr INTO l_dummy_var;
      CLOSE l_clm_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'clm_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_CNDTNS',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_INS_CLAIMS_B');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
	END IF;

    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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

	  -- verify that cursor was closed
      IF l_clm_csr%ISOPEN THEN
        CLOSE l_clm_csr;
      END IF;
end validate_clm_id;


-- Start of comments
  --
  -- Procedure Name  : validate_kle_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

procedure validate_kle_id(
         x_return_status OUT NOCOPY VARCHAR2,
		p_acdv_rec IN acdv_rec_type
) IS
CURSOR l_kle_csr IS
select 'x' from OKL_K_LINES_V
where ID = p_acdv_rec.kle_id;

l_dummy_var	VARCHAR2(1) := '?';

begin
-- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    IF ((p_acdv_rec.kle_id IS NOT NULL) AND (p_acdv_rec.kle_id <> OKC_API.G_MISS_NUM)) THEN
      OPEN  l_kle_csr;
      FETCH l_kle_csr INTO l_dummy_var;
      CLOSE l_kle_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'kle_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_ASSET_CNDTNS',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_K_LINES_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
	END IF;

    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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

	  -- verify that cursor was closed
      IF l_kle_csr%ISOPEN THEN
        CLOSE l_kle_csr;
      END IF;
end validate_kle_id;

-- Start of comments
--
-- Procedure Name  : is_unique
-- Description     : Do not create a new record if any record exists with the same kle_id
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
PROCEDURE is_unique(
	p_acdv_rec		in	acdv_rec_type,
	x_return_status out nocopy VARCHAR2) is

    -- Cursor to check whether conditon is_unique for a given finacial asset line.
    -- Bug 2524727 Need to check for free form because insurance claims create multiple
    -- conditions for the same fixed asset line
    CURSOR okl_acdv_csr (p_id IN NUMBER, p_kle_id IN NUMBER) IS
    SELECT ACD.ID
    FROM   OKL_ASSET_CNDTNS ACD
          ,OKC_K_LINES_B CLE
          ,OKC_LINE_STYLES_B LSE
    WHERE  ACD.KLE_ID = p_kle_id
       AND ACD.KLE_ID = CLE.ID
       AND CLE.LSE_ID = LSE.ID
       AND LSE.LTY_CODE = 'FREE_FORM1'
       AND ACD.ID <> nvl (p_id, -99999);

--    Old Cursor before bug 2524727
--    SELECT id
--    FROM   OKL_ASSET_CNDTNS_V
--    WHERE  kle_id = p_kle_id
--      AND  id <> nvl (p_id, -99999);

    l_id            NUMBER;
BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- Check if value passed for id
    IF (p_acdv_rec.kle_id IS NOT NULL) AND (p_acdv_rec.kle_id <> OKC_API.G_MISS_NUM) THEN
      OPEN okl_acdv_csr(p_acdv_rec.id, p_acdv_rec.kle_id);
      FETCH okl_acdv_csr INTO l_id;
      -- If id already exists then update mode
      IF okl_acdv_csr%FOUND THEN
        -- Asset Return already exists for this asset with status STATUS so cannot create a new asset return now.
  	        OKL_API.SET_MESSAGE( p_app_name		=> 'OKL'
				    	  	    ,p_msg_name		=> 'OKL_AM_ASSET_CNDTN_EXISTS');
    	    -- notify caller of an error
	        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      CLOSE okl_acdv_csr;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      IF okl_acdv_csr%ISOPEN THEN
         CLOSE okl_acdv_csr;
      END IF;
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

END is_unique;

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
  -- FUNCTION get_rec for: OKL_ASSET_CNDTNS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_acd_rec                      IN acd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN acd_rec_type IS
    CURSOR acd_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            DATE_REPORT,
            CDN_CODE,
            CLM_ID,
            ISP_ID,
            ILN_ID,
            KLE_ID,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
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
      FROM Okl_Asset_Cndtns
     WHERE okl_asset_cndtns.id  = p_id;
    l_acd_pk                       acd_pk_csr%ROWTYPE;
    l_acd_rec                      acd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN acd_pk_csr (p_acd_rec.id);
    FETCH acd_pk_csr INTO
              l_acd_rec.ID,
              l_acd_rec.DATE_REPORT,
              l_acd_rec.CDN_CODE,
              l_acd_rec.CLM_ID,
              l_acd_rec.ISP_ID,
              l_acd_rec.ILN_ID,
              l_acd_rec.KLE_ID,
              l_acd_rec.OBJECT_VERSION_NUMBER,
              l_acd_rec.ORG_ID,
              l_acd_rec.REQUEST_ID,
              l_acd_rec.PROGRAM_APPLICATION_ID,
              l_acd_rec.PROGRAM_ID,
              l_acd_rec.PROGRAM_UPDATE_DATE,
              l_acd_rec.ATTRIBUTE_CATEGORY,
              l_acd_rec.ATTRIBUTE1,
              l_acd_rec.ATTRIBUTE2,
              l_acd_rec.ATTRIBUTE3,
              l_acd_rec.ATTRIBUTE4,
              l_acd_rec.ATTRIBUTE5,
              l_acd_rec.ATTRIBUTE6,
              l_acd_rec.ATTRIBUTE7,
              l_acd_rec.ATTRIBUTE8,
              l_acd_rec.ATTRIBUTE9,
              l_acd_rec.ATTRIBUTE10,
              l_acd_rec.ATTRIBUTE11,
              l_acd_rec.ATTRIBUTE12,
              l_acd_rec.ATTRIBUTE13,
              l_acd_rec.ATTRIBUTE14,
              l_acd_rec.ATTRIBUTE15,
              l_acd_rec.CREATED_BY,
              l_acd_rec.CREATION_DATE,
              l_acd_rec.LAST_UPDATED_BY,
              l_acd_rec.LAST_UPDATE_DATE,
              l_acd_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := acd_pk_csr%NOTFOUND;
    CLOSE acd_pk_csr;
    RETURN(l_acd_rec);
  END get_rec;

  FUNCTION get_rec (
    p_acd_rec                      IN acd_rec_type
  ) RETURN acd_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_acd_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ASSET_CNDTNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_acdv_rec                     IN acdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN acdv_rec_type IS
    CURSOR okl_acdv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CDN_CODE,
            ILN_ID,
            ISP_ID,
            CLM_ID,
            KLE_ID,
            DATE_REPORT,
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
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_ASSET_CNDTNS
     WHERE OKL_ASSET_CNDTNS.id = p_id;
    l_okl_acdv_pk                  okl_acdv_pk_csr%ROWTYPE;
    l_acdv_rec                     acdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_acdv_pk_csr (p_acdv_rec.id);
    FETCH okl_acdv_pk_csr INTO
              l_acdv_rec.ID,
              l_acdv_rec.OBJECT_VERSION_NUMBER,
              l_acdv_rec.CDN_CODE,
              l_acdv_rec.ILN_ID,
              l_acdv_rec.ISP_ID,
              l_acdv_rec.CLM_ID,
              l_acdv_rec.KLE_ID,
              l_acdv_rec.DATE_REPORT,
              l_acdv_rec.ATTRIBUTE_CATEGORY,
              l_acdv_rec.ATTRIBUTE1,
              l_acdv_rec.ATTRIBUTE2,
              l_acdv_rec.ATTRIBUTE3,
              l_acdv_rec.ATTRIBUTE4,
              l_acdv_rec.ATTRIBUTE5,
              l_acdv_rec.ATTRIBUTE6,
              l_acdv_rec.ATTRIBUTE7,
              l_acdv_rec.ATTRIBUTE8,
              l_acdv_rec.ATTRIBUTE9,
              l_acdv_rec.ATTRIBUTE10,
              l_acdv_rec.ATTRIBUTE11,
              l_acdv_rec.ATTRIBUTE12,
              l_acdv_rec.ATTRIBUTE13,
              l_acdv_rec.ATTRIBUTE14,
              l_acdv_rec.ATTRIBUTE15,
              l_acdv_rec.ORG_ID,
              l_acdv_rec.REQUEST_ID,
              l_acdv_rec.PROGRAM_APPLICATION_ID,
              l_acdv_rec.PROGRAM_ID,
              l_acdv_rec.PROGRAM_UPDATE_DATE,
              l_acdv_rec.CREATED_BY,
              l_acdv_rec.CREATION_DATE,
              l_acdv_rec.LAST_UPDATED_BY,
              l_acdv_rec.LAST_UPDATE_DATE,
              l_acdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_acdv_pk_csr%NOTFOUND;
    CLOSE okl_acdv_pk_csr;
    RETURN(l_acdv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_acdv_rec                     IN acdv_rec_type
  ) RETURN acdv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_acdv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ASSET_CNDTNS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_acdv_rec	IN acdv_rec_type
  ) RETURN acdv_rec_type IS
    l_acdv_rec	acdv_rec_type := p_acdv_rec;
  BEGIN
    IF (l_acdv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.object_version_number := NULL;
    END IF;
    IF (l_acdv_rec.cdn_code = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.cdn_code := NULL;
    END IF;
    IF (l_acdv_rec.iln_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.iln_id := NULL;
    END IF;
    IF (l_acdv_rec.isp_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.isp_id := NULL;
    END IF;
    IF (l_acdv_rec.clm_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.clm_id := NULL;
    END IF;
    IF (l_acdv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.kle_id := NULL;
    END IF;
    IF (l_acdv_rec.date_report = OKC_API.G_MISS_DATE) THEN
      l_acdv_rec.date_report := NULL;
    END IF;
    IF (l_acdv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute_category := NULL;
    END IF;
    IF (l_acdv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute1 := NULL;
    END IF;
    IF (l_acdv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute2 := NULL;
    END IF;
    IF (l_acdv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute3 := NULL;
    END IF;
    IF (l_acdv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute4 := NULL;
    END IF;
    IF (l_acdv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute5 := NULL;
    END IF;
    IF (l_acdv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute6 := NULL;
    END IF;
    IF (l_acdv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute7 := NULL;
    END IF;
    IF (l_acdv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute8 := NULL;
    END IF;
    IF (l_acdv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute9 := NULL;
    END IF;
    IF (l_acdv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute10 := NULL;
    END IF;
    IF (l_acdv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute11 := NULL;
    END IF;
    IF (l_acdv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute12 := NULL;
    END IF;
    IF (l_acdv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute13 := NULL;
    END IF;
    IF (l_acdv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute14 := NULL;
    END IF;
    IF (l_acdv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_acdv_rec.attribute15 := NULL;
    END IF;
    IF (l_acdv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.org_id := NULL;
    END IF;
        -- Begin Post-Generation Change
/*
    IF (l_acdv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.request_id := NULL;
    END IF;
    IF (l_acdv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.program_application_id := NULL;
    END IF;
    IF (l_acdv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.program_id := NULL;
    END IF;
    IF (l_acdv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_acdv_rec.program_update_date := NULL;
    END IF;
*/
       -- End Post-Generation Change
    IF (l_acdv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.created_by := NULL;
    END IF;
    IF (l_acdv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_acdv_rec.creation_date := NULL;
    END IF;
    IF (l_acdv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_acdv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_acdv_rec.last_update_date := NULL;
    END IF;
    IF (l_acdv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_acdv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_acdv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------


  ------------------------------------------------
  -- Validate_Attributes for:OKL_ASSET_CNDTNS_V --
  ------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     :  Modified by : Guru Kadarkaraisamy
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  FUNCTION Validate_Attributes (
    p_acdv_rec IN  acdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  begin
    -- call each column-level validation
    validate_id(x_return_status => l_return_status,
                p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

     validate_object_version_number(x_return_status => l_return_status,
                 				   p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

    validate_cdn_code(x_return_status => l_return_status,
                 	   p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;


    validate_iln_id(x_return_status => l_return_status,
                 	p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

	validate_isp_id(x_return_status => l_return_status,
                    p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

   validate_org_id(x_return_status => l_return_status,
               	     p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
        x_return_status := l_return_status;
      end if;
    end if;

	-- call foreign key validation for 'clm_id'
    validate_clm_id(x_return_status => l_return_status,
                 	  p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

	-- call foreign key validation for 'clm_id'
    validate_kle_id(x_return_status => l_return_status,
                 	  p_acdv_rec      => p_acdv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    return (x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_ASSET_CNDTNS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_acdv_rec IN acdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- check uniqueness
    is_unique(p_acdv_rec,l_return_status);

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN acdv_rec_type,
    p_to	IN OUT NOCOPY acd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.date_report := p_from.date_report;
    p_to.cdn_code := p_from.cdn_code;
    p_to.clm_id := p_from.clm_id;
    p_to.isp_id := p_from.isp_id;
    p_to.iln_id := p_from.iln_id;
    p_to.kle_id := p_from.kle_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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
    p_from	IN acd_rec_type,
    p_to	IN OUT NOCOPY acdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.date_report := p_from.date_report;
    p_to.cdn_code := p_from.cdn_code;
    p_to.clm_id := p_from.clm_id;
    p_to.isp_id := p_from.isp_id;
    p_to.iln_id := p_from.iln_id;
    p_to.kle_id := p_from.kle_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
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

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_ASSET_CNDTNS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_rec                     IN acdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acdv_rec                     acdv_rec_type := p_acdv_rec;
    l_acd_rec                      acd_rec_type;
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
    l_return_status := Validate_Attributes(l_acdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_acdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- PL/SQL TBL validate_row for:ACDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_tbl                     IN acdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
     -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acdv_tbl.COUNT > 0) THEN
      i := p_acdv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acdv_rec                     => p_acdv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acdv_tbl.LAST);
        i := p_acdv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- insert_row for:OKL_ASSET_CNDTNS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acd_rec                      IN acd_rec_type,
    x_acd_rec                      OUT NOCOPY acd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CNDTNS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acd_rec                      acd_rec_type := p_acd_rec;
    l_def_acd_rec                  acd_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTNS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_acd_rec IN  acd_rec_type,
      x_acd_rec OUT NOCOPY acd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acd_rec := p_acd_rec;
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
      p_acd_rec,                         -- IN
      l_acd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ASSET_CNDTNS(
        id,
        date_report,
        cdn_code,
        clm_id,
        isp_id,
        iln_id,
        kle_id,
        object_version_number,
        org_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
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
        last_update_login)
      VALUES (
        l_acd_rec.id,
        l_acd_rec.date_report,
        l_acd_rec.cdn_code,
        l_acd_rec.clm_id,
        l_acd_rec.isp_id,
        l_acd_rec.iln_id,
        l_acd_rec.kle_id,
        l_acd_rec.object_version_number,
        l_acd_rec.org_id,
      /*  l_acd_rec.request_id,
        l_acd_rec.program_application_id,
        l_acd_rec.program_id,
        l_acd_rec.program_update_date,*/
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        l_acd_rec.attribute_category,
        l_acd_rec.attribute1,
        l_acd_rec.attribute2,
        l_acd_rec.attribute3,
        l_acd_rec.attribute4,
        l_acd_rec.attribute5,
        l_acd_rec.attribute6,
        l_acd_rec.attribute7,
        l_acd_rec.attribute8,
        l_acd_rec.attribute9,
        l_acd_rec.attribute10,
        l_acd_rec.attribute11,
        l_acd_rec.attribute12,
        l_acd_rec.attribute13,
        l_acd_rec.attribute14,
        l_acd_rec.attribute15,
        l_acd_rec.created_by,
        l_acd_rec.creation_date,
        l_acd_rec.last_updated_by,
        l_acd_rec.last_update_date,
        l_acd_rec.last_update_login);
    -- Set OUT values
    x_acd_rec := l_acd_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- insert_row for:OKL_ASSET_CNDTNS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_rec                     IN acdv_rec_type,
    x_acdv_rec                     OUT NOCOPY acdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acdv_rec                     acdv_rec_type;
    l_def_acdv_rec                 acdv_rec_type;
    l_acd_rec                      acd_rec_type;
    lx_acd_rec                     acd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_acdv_rec	IN acdv_rec_type
    ) RETURN acdv_rec_type IS
      l_acdv_rec	acdv_rec_type := p_acdv_rec;
    BEGIN
      l_acdv_rec.CREATION_DATE := SYSDATE;
      l_acdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_acdv_rec.LAST_UPDATE_DATE := l_acdv_rec.CREATION_DATE;
      l_acdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_acdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_acdv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTNS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_acdv_rec IN  acdv_rec_type,
      x_acdv_rec OUT NOCOPY acdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acdv_rec := p_acdv_rec;
      x_acdv_rec.OBJECT_VERSION_NUMBER := 1;
      -- Default the ORG ID if a value is not passed
      IF p_acdv_rec.org_id IS NULL
      OR p_acdv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_acdv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;
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
    l_acdv_rec := null_out_defaults(p_acdv_rec);
    -- Set primary key value
    l_acdv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_acdv_rec,                        -- IN
      l_def_acdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_acdv_rec := fill_who_columns(l_def_acdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_acdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_acdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_acdv_rec, l_acd_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acd_rec,
      lx_acd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_acd_rec, l_def_acdv_rec);
    -- Set OUT values
    x_acdv_rec := l_def_acdv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- PL/SQL TBL insert_row for:ACDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_tbl                     IN acdv_tbl_type,
    x_acdv_tbl                     OUT NOCOPY acdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acdv_tbl.COUNT > 0) THEN
      i := p_acdv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acdv_rec                     => p_acdv_tbl(i),
          x_acdv_rec                     => x_acdv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acdv_tbl.LAST);
        i := p_acdv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- lock_row for:OKL_ASSET_CNDTNS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acd_rec                      IN acd_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_acd_rec IN acd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ASSET_CNDTNS
     WHERE ID = p_acd_rec.id
       AND OBJECT_VERSION_NUMBER = p_acd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_acd_rec IN acd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ASSET_CNDTNS
    WHERE ID = p_acd_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CNDTNS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ASSET_CNDTNS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ASSET_CNDTNS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_acd_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_acd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_acd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_acd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- lock_row for:OKL_ASSET_CNDTNS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_rec                     IN acdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acd_rec                      acd_rec_type;
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
    migrate(p_acdv_rec, l_acd_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- PL/SQL TBL lock_row for:ACDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_tbl                     IN acdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acdv_tbl.COUNT > 0) THEN
      i := p_acdv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acdv_rec                     => p_acdv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acdv_tbl.LAST);
        i := p_acdv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- update_row for:OKL_ASSET_CNDTNS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acd_rec                      IN acd_rec_type,
    x_acd_rec                      OUT NOCOPY acd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CNDTNS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acd_rec                      acd_rec_type := p_acd_rec;
    l_def_acd_rec                  acd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_acd_rec	IN acd_rec_type,
      x_acd_rec	OUT NOCOPY acd_rec_type
    ) RETURN VARCHAR2 IS
      l_acd_rec                      acd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acd_rec := p_acd_rec;
      -- Get current database values
      l_acd_rec := get_rec(p_acd_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_acd_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.id := l_acd_rec.id;
      END IF;
      IF (x_acd_rec.date_report = OKC_API.G_MISS_DATE)
      THEN
        x_acd_rec.date_report := l_acd_rec.date_report;
      END IF;
      IF (x_acd_rec.cdn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.cdn_code := l_acd_rec.cdn_code;
      END IF;
      IF (x_acd_rec.clm_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.clm_id := l_acd_rec.clm_id;
      END IF;
      IF (x_acd_rec.isp_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.isp_id := l_acd_rec.isp_id;
      END IF;
      IF (x_acd_rec.iln_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.iln_id := l_acd_rec.iln_id;
      END IF;
      IF (x_acd_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.kle_id := l_acd_rec.kle_id;
      END IF;
      IF (x_acd_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.object_version_number := l_acd_rec.object_version_number;
      END IF;
      IF (x_acd_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.org_id := l_acd_rec.org_id;
      END IF;
      IF (x_acd_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.request_id := l_acd_rec.request_id;
      END IF;
      IF (x_acd_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.program_application_id := l_acd_rec.program_application_id;
      END IF;
      IF (x_acd_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.program_id := l_acd_rec.program_id;
      END IF;
      IF (x_acd_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acd_rec.program_update_date := l_acd_rec.program_update_date;
      END IF;
      IF (x_acd_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute_category := l_acd_rec.attribute_category;
      END IF;
      IF (x_acd_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute1 := l_acd_rec.attribute1;
      END IF;
      IF (x_acd_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute2 := l_acd_rec.attribute2;
      END IF;
      IF (x_acd_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute3 := l_acd_rec.attribute3;
      END IF;
      IF (x_acd_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute4 := l_acd_rec.attribute4;
      END IF;
      IF (x_acd_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute5 := l_acd_rec.attribute5;
      END IF;
      IF (x_acd_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute6 := l_acd_rec.attribute6;
      END IF;
      IF (x_acd_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute7 := l_acd_rec.attribute7;
      END IF;
      IF (x_acd_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute8 := l_acd_rec.attribute8;
      END IF;
      IF (x_acd_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute9 := l_acd_rec.attribute9;
      END IF;
      IF (x_acd_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute10 := l_acd_rec.attribute10;
      END IF;
      IF (x_acd_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute11 := l_acd_rec.attribute11;
      END IF;
      IF (x_acd_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute12 := l_acd_rec.attribute12;
      END IF;
      IF (x_acd_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute13 := l_acd_rec.attribute13;
      END IF;
      IF (x_acd_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute14 := l_acd_rec.attribute14;
      END IF;
      IF (x_acd_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_acd_rec.attribute15 := l_acd_rec.attribute15;
      END IF;
      IF (x_acd_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.created_by := l_acd_rec.created_by;
      END IF;
      IF (x_acd_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_acd_rec.creation_date := l_acd_rec.creation_date;
      END IF;
      IF (x_acd_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.last_updated_by := l_acd_rec.last_updated_by;
      END IF;
      IF (x_acd_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acd_rec.last_update_date := l_acd_rec.last_update_date;
      END IF;
      IF (x_acd_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_acd_rec.last_update_login := l_acd_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTNS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_acd_rec IN  acd_rec_type,
      x_acd_rec OUT NOCOPY acd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acd_rec := p_acd_rec;
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
      p_acd_rec,                         -- IN
      l_acd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_acd_rec, l_def_acd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ASSET_CNDTNS
    SET DATE_REPORT = l_def_acd_rec.date_report,
        CDN_CODE = l_def_acd_rec.cdn_code,
        CLM_ID = l_def_acd_rec.clm_id,
        ISP_ID = l_def_acd_rec.isp_id,
        ILN_ID = l_def_acd_rec.iln_id,
        KLE_ID = l_def_acd_rec.kle_id,
        OBJECT_VERSION_NUMBER = l_def_acd_rec.object_version_number,
        ORG_ID = l_def_acd_rec.org_id,
       /* REQUEST_ID = l_def_acd_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_acd_rec.program_application_id,
        PROGRAM_ID = l_def_acd_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_acd_rec.program_update_date,*/
        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_acd_rec.request_id),
        PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_acd_rec.program_application_id),
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_acd_rec.program_id),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_acd_rec.program_update_date,SYSDATE),
        ATTRIBUTE_CATEGORY = l_def_acd_rec.attribute_category,
        ATTRIBUTE1 = l_def_acd_rec.attribute1,
        ATTRIBUTE2 = l_def_acd_rec.attribute2,
        ATTRIBUTE3 = l_def_acd_rec.attribute3,
        ATTRIBUTE4 = l_def_acd_rec.attribute4,
        ATTRIBUTE5 = l_def_acd_rec.attribute5,
        ATTRIBUTE6 = l_def_acd_rec.attribute6,
        ATTRIBUTE7 = l_def_acd_rec.attribute7,
        ATTRIBUTE8 = l_def_acd_rec.attribute8,
        ATTRIBUTE9 = l_def_acd_rec.attribute9,
        ATTRIBUTE10 = l_def_acd_rec.attribute10,
        ATTRIBUTE11 = l_def_acd_rec.attribute11,
        ATTRIBUTE12 = l_def_acd_rec.attribute12,
        ATTRIBUTE13 = l_def_acd_rec.attribute13,
        ATTRIBUTE14 = l_def_acd_rec.attribute14,
        ATTRIBUTE15 = l_def_acd_rec.attribute15,
        CREATED_BY = l_def_acd_rec.created_by,
        CREATION_DATE = l_def_acd_rec.creation_date,
        LAST_UPDATED_BY = l_def_acd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_acd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_acd_rec.last_update_login
    WHERE ID = l_def_acd_rec.id;

    x_acd_rec := l_def_acd_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- update_row for:OKL_ASSET_CNDTNS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_rec                     IN acdv_rec_type,
    x_acdv_rec                     OUT NOCOPY acdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acdv_rec                     acdv_rec_type := p_acdv_rec;
    l_def_acdv_rec                 acdv_rec_type;
    l_acd_rec                      acd_rec_type;
    lx_acd_rec                     acd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_acdv_rec	IN acdv_rec_type
    ) RETURN acdv_rec_type IS
      l_acdv_rec	acdv_rec_type := p_acdv_rec;
    BEGIN
      l_acdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_acdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_acdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_acdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_acdv_rec	IN acdv_rec_type,
      x_acdv_rec	OUT NOCOPY acdv_rec_type
    ) RETURN VARCHAR2 IS
      l_acdv_rec                     acdv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acdv_rec := p_acdv_rec;
      -- Get current database values
      l_acdv_rec := get_rec(p_acdv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_acdv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.id := l_acdv_rec.id;
      END IF;
      IF (x_acdv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.object_version_number := l_acdv_rec.object_version_number;
      END IF;
      IF (x_acdv_rec.cdn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.cdn_code := l_acdv_rec.cdn_code;
      END IF;
      IF (x_acdv_rec.iln_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.iln_id := l_acdv_rec.iln_id;
      END IF;
      IF (x_acdv_rec.isp_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.isp_id := l_acdv_rec.isp_id;
      END IF;
      IF (x_acdv_rec.clm_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.clm_id := l_acdv_rec.clm_id;
      END IF;
      IF (x_acdv_rec.kle_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.kle_id := l_acdv_rec.kle_id;
      END IF;
      IF (x_acdv_rec.date_report = OKC_API.G_MISS_DATE)
      THEN
        x_acdv_rec.date_report := l_acdv_rec.date_report;
      END IF;
      IF (x_acdv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute_category := l_acdv_rec.attribute_category;
      END IF;
      IF (x_acdv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute1 := l_acdv_rec.attribute1;
      END IF;
      IF (x_acdv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute2 := l_acdv_rec.attribute2;
      END IF;
      IF (x_acdv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute3 := l_acdv_rec.attribute3;
      END IF;
      IF (x_acdv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute4 := l_acdv_rec.attribute4;
      END IF;
      IF (x_acdv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute5 := l_acdv_rec.attribute5;
      END IF;
      IF (x_acdv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute6 := l_acdv_rec.attribute6;
      END IF;
      IF (x_acdv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute7 := l_acdv_rec.attribute7;
      END IF;
      IF (x_acdv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute8 := l_acdv_rec.attribute8;
      END IF;
      IF (x_acdv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute9 := l_acdv_rec.attribute9;
      END IF;
      IF (x_acdv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute10 := l_acdv_rec.attribute10;
      END IF;
      IF (x_acdv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute11 := l_acdv_rec.attribute11;
      END IF;
      IF (x_acdv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute12 := l_acdv_rec.attribute12;
      END IF;
      IF (x_acdv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute13 := l_acdv_rec.attribute13;
      END IF;
      IF (x_acdv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute14 := l_acdv_rec.attribute14;
      END IF;
      IF (x_acdv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_acdv_rec.attribute15 := l_acdv_rec.attribute15;
      END IF;
      IF (x_acdv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.org_id := l_acdv_rec.org_id;
      END IF;
      IF (x_acdv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.request_id := l_acdv_rec.request_id;
      END IF;
      IF (x_acdv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.program_application_id := l_acdv_rec.program_application_id;
      END IF;
      IF (x_acdv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.program_id := l_acdv_rec.program_id;
      END IF;
      IF (x_acdv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acdv_rec.program_update_date := l_acdv_rec.program_update_date;
      END IF;
      IF (x_acdv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.created_by := l_acdv_rec.created_by;
      END IF;
      IF (x_acdv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_acdv_rec.creation_date := l_acdv_rec.creation_date;
      END IF;
      IF (x_acdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.last_updated_by := l_acdv_rec.last_updated_by;
      END IF;
      IF (x_acdv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_acdv_rec.last_update_date := l_acdv_rec.last_update_date;
      END IF;
      IF (x_acdv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_acdv_rec.last_update_login := l_acdv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_ASSET_CNDTNS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_acdv_rec IN  acdv_rec_type,
      x_acdv_rec OUT NOCOPY acdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_acdv_rec := p_acdv_rec;
      x_acdv_rec.OBJECT_VERSION_NUMBER := NVL(x_acdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_acdv_rec,                        -- IN
      l_acdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_acdv_rec, l_def_acdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_acdv_rec := fill_who_columns(l_def_acdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_acdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_acdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_acdv_rec, l_acd_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acd_rec,
      lx_acd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_acd_rec, l_def_acdv_rec);
    x_acdv_rec := l_def_acdv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- PL/SQL TBL update_row for:ACDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_tbl                     IN acdv_tbl_type,
    x_acdv_tbl                     OUT NOCOPY acdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acdv_tbl.COUNT > 0) THEN
      i := p_acdv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acdv_rec                     => p_acdv_tbl(i),
          x_acdv_rec                     => x_acdv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acdv_tbl.LAST);
        i := p_acdv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- delete_row for:OKL_ASSET_CNDTNS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acd_rec                      IN acd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CNDTNS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acd_rec                      acd_rec_type:= p_acd_rec;
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
    DELETE FROM OKL_ASSET_CNDTNS
     WHERE ID = l_acd_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- delete_row for:OKL_ASSET_CNDTNS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_rec                     IN acdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_acdv_rec                     acdv_rec_type := p_acdv_rec;
    l_acd_rec                      acd_rec_type;
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
    migrate(l_acdv_rec, l_acd_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_acd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
  -- PL/SQL TBL delete_row for:ACDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_acdv_tbl                     IN acdv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_acdv_tbl.COUNT > 0) THEN
      i := p_acdv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_acdv_rec                     => p_acdv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_acdv_tbl.LAST);
        i := p_acdv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

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
END OKL_ACD_PVT;

/
