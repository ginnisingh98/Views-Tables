--------------------------------------------------------
--  DDL for Package Body OKC_GVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_GVE_PVT" AS
/* $Header: OKCSGVEB.pls 120.0 2005/05/25 18:21:11 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/
  FUNCTION Validate_Attributes ( p_gvev_rec IN  gvev_rec_type)
		RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_CODE';
  G_VIEW			 CONSTANT	VARCHAR2(200) := 'OKC_GOVERNANCES_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_gvev_rec      IN    gvev_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKC_K_HEADERS_B
  		where ID = p_gvev_rec.chr_id;
  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If (p_gvev_rec.chr_id <> OKC_API.G_MISS_NUM and
  	   p_gvev_rec.chr_id IS NOT NULL)
    Then
      Open l_chrv_csr;
      Fetch l_chrv_csr Into l_dummy_var;
      Close l_chrv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'chr_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'OKC_K_HEADERS_V');
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

        -- verify that cursor was closed
        if l_chrv_csr%ISOPEN then
	      close l_chrv_csr;
        end if;
  End validate_chr_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_cle_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_cle_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_gvev_rec      IN    gvev_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_clev_csr Is
  		select 'x'
  		from OKC_K_LINES_B
  		where ID = p_gvev_rec.cle_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If (p_gvev_rec.cle_id <> OKC_API.G_MISS_NUM and
  	   p_gvev_rec.cle_id IS NOT NULL)
    Then
      Open l_clev_csr;
      Fetch l_clev_csr Into l_dummy_var;
      Close l_clev_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
					    p_msg_name		=> G_NO_PARENT_RECORD,
					    p_token1		=> G_COL_NAME_TOKEN,
					    p_token1_value	=> 'cle_id',
					    p_token2		=> G_CHILD_TABLE_TOKEN,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> G_PARENT_TABLE_TOKEN,
					    p_token3_value	=> 'OKC_K_LINES_V');
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

        -- verify that cursor was closed
        if l_clev_csr%ISOPEN then
	      close l_clev_csr;
        end if;
  End validate_cle_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id_referred
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_chr_id_referred(x_return_status OUT NOCOPY   VARCHAR2,
                                     p_gvev_rec      IN    gvev_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKC_K_HEADERS_B
  		where ID = p_gvev_rec.chr_id_referred;
  begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If (p_gvev_rec.chr_id_referred <> OKC_API.G_MISS_NUM and
  	   p_gvev_rec.chr_id_referred IS NOT NULL)
    Then
      Open l_chrv_csr;
      Fetch l_chrv_csr Into l_dummy_var;
      Close l_chrv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'chr_id_referred',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'OKC_K_HEADERS_V');
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

        -- verify that cursor was closed
        if l_chrv_csr%ISOPEN then
	      close l_chrv_csr;
        end if;
  End validate_chr_id_referred;

  -- Start of comments
  --
  -- Procedure Name  : validate_cle_id_referred
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_cle_id_referred(x_return_status OUT NOCOPY   VARCHAR2,
                            p_gvev_rec      IN    gvev_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_clev_csr Is
  		select 'x'
  		from OKC_K_LINES_B
  		where ID = p_gvev_rec.cle_id_referred;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If (p_gvev_rec.cle_id_referred <> OKC_API.G_MISS_NUM and
  	   p_gvev_rec.cle_id_referred IS NOT NULL)
    Then
      Open l_clev_csr;
      Fetch l_clev_csr Into l_dummy_var;
      Close l_clev_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
					    p_msg_name		=> G_NO_PARENT_RECORD,
					    p_token1		=> G_COL_NAME_TOKEN,
					    p_token1_value	=> 'cle_id_referred',
					    p_token2		=> G_CHILD_TABLE_TOKEN,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> G_PARENT_TABLE_TOKEN,
					    p_token3_value	=> 'OKC_K_LINES_V');
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

        -- verify that cursor was closed
        if l_clev_csr%ISOPEN then
	      close l_clev_csr;
        end if;
  End validate_cle_id_referred;

  -- Start of comments
  --
  -- Procedure Name  : validate_isa_agreement_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_isa_agreement_id(x_return_status OUT NOCOPY   VARCHAR2,
                                         p_gvev_rec      IN    gvev_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_isav_csr Is
  		select 'x'
  		from OKX_AGREEMENTS_V
  		where AGREEMENT_ID = p_gvev_rec.isa_agreement_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If (p_gvev_rec.isa_agreement_id <> OKC_API.G_MISS_NUM and
  	   p_gvev_rec.isa_agreement_id IS NOT NULL)
    Then
      Open l_isav_csr;
      Fetch l_isav_csr Into l_dummy_var;
      Close l_isav_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'isa_agreement_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> 'OKC_GOVERNANCES_V',
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'OKX_AGREEMENTS_V');
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

        -- verify that cursor was closed
        if l_isav_csr%ISOPEN then
	      close l_isav_csr;
        end if;
  End validate_isa_agreement_id;

  PROCEDURE validate_copied_only_yn(x_return_status OUT NOCOPY   VARCHAR2,
                            	      p_gvev_rec      IN    gvev_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_gvev_rec.copied_only_yn = OKC_API.G_MISS_CHAR or
  	   p_gvev_rec.copied_only_yn IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'copied_only_yn');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_gvev_rec.copied_only_yn) NOT IN ('Y','N')) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'copied_only_yn');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

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
  End validate_copied_only_yn;
  /***********************END HAND-CODED ********************************/
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
  -- FUNCTION get_rec for: OKC_GOVERNANCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gve_rec                      IN gve_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gve_rec_type IS
    CURSOR gve_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            DNZ_CHR_ID,
            CHR_ID,
            CLE_ID,
            CHR_ID_REFERRED,
            CLE_ID_REFERRED,
            ISA_AGREEMENT_ID,
            COPIED_ONLY_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Governances
     WHERE okc_governances.id   = p_id;
    l_gve_pk                       gve_pk_csr%ROWTYPE;
    l_gve_rec                      gve_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN gve_pk_csr (p_gve_rec.id);
    FETCH gve_pk_csr INTO
              l_gve_rec.ID,
              l_gve_rec.DNZ_CHR_ID,
              l_gve_rec.CHR_ID,
              l_gve_rec.CLE_ID,
              l_gve_rec.CHR_ID_REFERRED,
              l_gve_rec.CLE_ID_REFERRED,
              l_gve_rec.ISA_AGREEMENT_ID,
              l_gve_rec.COPIED_ONLY_YN,
              l_gve_rec.OBJECT_VERSION_NUMBER,
              l_gve_rec.CREATED_BY,
              l_gve_rec.CREATION_DATE,
              l_gve_rec.LAST_UPDATED_BY,
              l_gve_rec.LAST_UPDATE_DATE,
              l_gve_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := gve_pk_csr%NOTFOUND;
    CLOSE gve_pk_csr;
    RETURN(l_gve_rec);
  END get_rec;

  FUNCTION get_rec (
    p_gve_rec                      IN gve_rec_type
  ) RETURN gve_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gve_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_GOVERNANCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_gvev_rec                     IN gvev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN gvev_rec_type IS
    CURSOR okc_gvev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            DNZ_CHR_ID,
            ISA_AGREEMENT_ID,
            OBJECT_VERSION_NUMBER,
            CHR_ID,
            CLE_ID,
            CHR_ID_REFERRED,
            CLE_ID_REFERRED,
            COPIED_ONLY_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Governances_V
     WHERE okc_governances_v.id = p_id;
    l_okc_gvev_pk                  okc_gvev_pk_csr%ROWTYPE;
    l_gvev_rec                     gvev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_gvev_pk_csr (p_gvev_rec.id);
    FETCH okc_gvev_pk_csr INTO
              l_gvev_rec.ID,
              l_gvev_rec.DNZ_CHR_ID,
              l_gvev_rec.ISA_AGREEMENT_ID,
              l_gvev_rec.OBJECT_VERSION_NUMBER,
              l_gvev_rec.CHR_ID,
              l_gvev_rec.CLE_ID,
              l_gvev_rec.CHR_ID_REFERRED,
              l_gvev_rec.CLE_ID_REFERRED,
              l_gvev_rec.COPIED_ONLY_YN,
              l_gvev_rec.CREATED_BY,
              l_gvev_rec.CREATION_DATE,
              l_gvev_rec.LAST_UPDATED_BY,
              l_gvev_rec.LAST_UPDATE_DATE,
              l_gvev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_gvev_pk_csr%NOTFOUND;
    CLOSE okc_gvev_pk_csr;
    RETURN(l_gvev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_gvev_rec                     IN gvev_rec_type
  ) RETURN gvev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_gvev_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_GOVERNANCES_V --
  -------------------------------------------------------
  FUNCTION null_out_defaults (
    p_gvev_rec	IN gvev_rec_type
  ) RETURN gvev_rec_type IS
    l_gvev_rec	gvev_rec_type := p_gvev_rec;
  BEGIN
    IF (l_gvev_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_gvev_rec.isa_agreement_id = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.isa_agreement_id := NULL;
    END IF;
    IF (l_gvev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.object_version_number := NULL;
    END IF;
    IF (l_gvev_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.chr_id := NULL;
    END IF;
    IF (l_gvev_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.cle_id := NULL;
    END IF;
    IF (l_gvev_rec.chr_id_referred = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.chr_id_referred := NULL;
    END IF;
    IF (l_gvev_rec.cle_id_referred = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.cle_id_referred := NULL;
    END IF;
    IF (l_gvev_rec.copied_only_yn = OKC_API.G_MISS_CHAR) THEN
      l_gvev_rec.copied_only_yn := NULL;
    END IF;
    IF (l_gvev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.created_by := NULL;
    END IF;
    IF (l_gvev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_gvev_rec.creation_date := NULL;
    END IF;
    IF (l_gvev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.last_updated_by := NULL;
    END IF;
    IF (l_gvev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_gvev_rec.last_update_date := NULL;
    END IF;
    IF (l_gvev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_gvev_rec.last_update_login := NULL;
    END IF;
    RETURN(l_gvev_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKC_GOVERNANCES_V --
  -----------------------------------------------
  FUNCTION Validate_Attributes (
    p_gvev_rec IN  gvev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /************************ HAND-CODED *********************************/
    validate_chr_id
  				(x_return_status 	=> l_return_status,
  				 p_gvev_rec 		=> p_gvev_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_cle_id
  				(x_return_status 	=> l_return_status,
  				 p_gvev_rec 		=> p_gvev_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_chr_id_referred
  				(x_return_status	=> l_return_status,
  				 p_gvev_rec		=> p_gvev_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_cle_id_referred
  				(x_return_status	=> l_return_status,
  				 p_gvev_rec		=> p_gvev_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

     validate_isa_agreement_id
  				(x_return_status	=> l_return_status,
  				 p_gvev_rec		=> p_gvev_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_copied_only_yn
  				(x_return_status	=> l_return_status,
  				 p_gvev_rec		=> p_gvev_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    RETURN(x_return_status);
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	   -- return status to caller
        RETURN(x_return_status);
    /*********************** END HAND-CODED ********************************/
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Record for:OKC_GOVERNANCES_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_gvev_rec IN gvev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_null_counter       NUMBER := 0;
  BEGIN
    /************************ HAND-CODED ****************************/
    -- CHR_ID and CLE_ID are mutually exclusive
    If (p_gvev_rec.chr_id IS NULL and
	   p_gvev_rec.cle_id IS NULL) or
       (p_gvev_rec.chr_id IS NOT NULL and
	   p_gvev_rec.cle_id IS NOT NULL)
    Then
	    l_return_status := OKC_API.G_RET_STS_ERROR;
	    OKC_API.SET_MESSAGE(
			p_app_name      => g_app_name,
			p_msg_name      => g_invalid_value,
			p_token1        => g_col_name_token,
			p_token1_value  => 'chr_id',
			p_token2        => g_col_name_token,
			p_token2_value  => 'cle_id');
    End If;

    -- CHR_ID_REFERRED, CLE_ID_REFERRED and ISA_AGREEMENT_ID
    -- are mutually exclusive
    If (p_gvev_rec.chr_id_referred IS NULL) Then
	  l_null_counter := l_null_counter + 1;
    End If;
    If (p_gvev_rec.cle_id_referred IS NULL) Then
	  l_null_counter := l_null_counter + 1;
    End If;
    If (p_gvev_rec.isa_agreement_id IS NULL) Then
	  l_null_counter := l_null_counter + 1;
    End If;
    If (l_null_counter <> 2) Then
	    l_return_status := OKC_API.G_RET_STS_ERROR;
	    OKC_API.SET_MESSAGE(
			p_app_name      => g_app_name,
			p_msg_name      => g_invalid_value,
			p_token1        => g_col_name_token,
			p_token1_value  => 'chr_id_referred',
			p_token2        => g_col_name_token,
			p_token2_value  => 'cle_id_referred',
			p_token3        => g_col_name_token,
			p_token3_value  => 'isa_agreement_id');
    End If;
    /*********************** END HAND-CODED *************************/

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN gvev_rec_type,
    p_to	IN OUT NOCOPY gve_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id_referred := p_from.chr_id_referred;
    p_to.cle_id_referred := p_from.cle_id_referred;
    p_to.isa_agreement_id := p_from.isa_agreement_id;
    p_to.copied_only_yn := p_from.copied_only_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN gve_rec_type,
    p_to	IN OUT NOCOPY gvev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id_referred := p_from.chr_id_referred;
    p_to.cle_id_referred := p_from.cle_id_referred;
    p_to.isa_agreement_id := p_from.isa_agreement_id;
    p_to.copied_only_yn := p_from.copied_only_yn;
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
  ----------------------------------------
  -- validate_row for:OKC_GOVERNANCES_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gvev_rec                     gvev_rec_type := p_gvev_rec;
    l_gve_rec                      gve_rec_type;
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
    l_return_status := Validate_Attributes(l_gvev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_gvev_rec);
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
  -- PL/SQL TBL validate_row for:GVEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gvev_tbl.COUNT > 0) THEN
      i := p_gvev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gvev_rec                     => p_gvev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
        i := p_gvev_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
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
  ------------------------------------
  -- insert_row for:OKC_GOVERNANCES --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gve_rec                      IN gve_rec_type,
    x_gve_rec                      OUT NOCOPY gve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GOVERNANCES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gve_rec                      gve_rec_type := p_gve_rec;
    l_def_gve_rec                  gve_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKC_GOVERNANCES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_gve_rec IN  gve_rec_type,
      x_gve_rec OUT NOCOPY gve_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_gve_rec := p_gve_rec;
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
      p_gve_rec,                         -- IN
      l_gve_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_GOVERNANCES(
        id,
        dnz_chr_id,
        chr_id,
        cle_id,
        chr_id_referred,
        cle_id_referred,
        isa_agreement_id,
        copied_only_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_gve_rec.id,
        l_gve_rec.dnz_chr_id,
        l_gve_rec.chr_id,
        l_gve_rec.cle_id,
        l_gve_rec.chr_id_referred,
        l_gve_rec.cle_id_referred,
        l_gve_rec.isa_agreement_id,
        l_gve_rec.copied_only_yn,
        l_gve_rec.object_version_number,
        l_gve_rec.created_by,
        l_gve_rec.creation_date,
        l_gve_rec.last_updated_by,
        l_gve_rec.last_update_date,
        l_gve_rec.last_update_login);
    -- Set OUT values
    x_gve_rec := l_gve_rec;
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
  --------------------------------------
  -- insert_row for:OKC_GOVERNANCES_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gvev_rec                     gvev_rec_type;
    l_def_gvev_rec                 gvev_rec_type;
    l_gve_rec                      gve_rec_type;
    lx_gve_rec                     gve_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gvev_rec	IN gvev_rec_type
    ) RETURN gvev_rec_type IS
      l_gvev_rec	gvev_rec_type := p_gvev_rec;
    BEGIN
      l_gvev_rec.CREATION_DATE := SYSDATE;
      l_gvev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_gvev_rec.LAST_UPDATE_DATE := l_gvev_rec.CREATION_DATE;
      l_gvev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_gvev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_gvev_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKC_GOVERNANCES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_gvev_rec IN  gvev_rec_type,
      x_gvev_rec OUT NOCOPY gvev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_gvev_rec := p_gvev_rec;
      x_gvev_rec.OBJECT_VERSION_NUMBER := 1;
	 /************************ HAND-CODED *********************************/
	 x_gvev_rec.COPIED_ONLY_YN    := UPPER(x_gvev_rec.COPIED_ONLY_YN);
	 /*********************** END HAND-CODED ********************************/
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
    l_gvev_rec := null_out_defaults(p_gvev_rec);
    -- Set primary key value
    l_gvev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_gvev_rec,                        -- IN
      l_def_gvev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_gvev_rec := fill_who_columns(l_def_gvev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gvev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_gvev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gvev_rec, l_gve_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_gve_rec,
      lx_gve_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_gve_rec, l_def_gvev_rec);
    -- Set OUT values
    x_gvev_rec := l_def_gvev_rec;
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
  -- PL/SQL TBL insert_row for:GVEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY gvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gvev_tbl.COUNT > 0) THEN
      i := p_gvev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gvev_rec                     => p_gvev_tbl(i),
          x_gvev_rec                     => x_gvev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
        i := p_gvev_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
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
  ----------------------------------
  -- lock_row for:OKC_GOVERNANCES --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gve_rec                      IN gve_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_gve_rec IN gve_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_GOVERNANCES
     WHERE ID = p_gve_rec.id
       AND OBJECT_VERSION_NUMBER = p_gve_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_gve_rec IN gve_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_GOVERNANCES
    WHERE ID = p_gve_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GOVERNANCES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_GOVERNANCES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_GOVERNANCES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_gve_rec);
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
      OPEN lchk_csr(p_gve_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_gve_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_gve_rec.object_version_number THEN
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
  ------------------------------------
  -- lock_row for:OKC_GOVERNANCES_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gve_rec                      gve_rec_type;
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
    migrate(p_gvev_rec, l_gve_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_gve_rec
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
  -- PL/SQL TBL lock_row for:GVEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gvev_tbl.COUNT > 0) THEN
      i := p_gvev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gvev_rec                     => p_gvev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
        i := p_gvev_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
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
  ------------------------------------
  -- update_row for:OKC_GOVERNANCES --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gve_rec                      IN gve_rec_type,
    x_gve_rec                      OUT NOCOPY gve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GOVERNANCES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gve_rec                      gve_rec_type := p_gve_rec;
    l_def_gve_rec                  gve_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gve_rec	IN gve_rec_type,
      x_gve_rec	OUT NOCOPY gve_rec_type
    ) RETURN VARCHAR2 IS
      l_gve_rec                      gve_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_gve_rec := p_gve_rec;
      -- Get current database values
      l_gve_rec := get_rec(p_gve_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gve_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.id := l_gve_rec.id;
      END IF;
      IF (x_gve_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.dnz_chr_id := l_gve_rec.dnz_chr_id;
      END IF;
      IF (x_gve_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.chr_id := l_gve_rec.chr_id;
      END IF;
      IF (x_gve_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.cle_id := l_gve_rec.cle_id;
      END IF;
      IF (x_gve_rec.chr_id_referred = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.chr_id_referred := l_gve_rec.chr_id_referred;
      END IF;
      IF (x_gve_rec.cle_id_referred = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.cle_id_referred := l_gve_rec.cle_id_referred;
      END IF;
      IF (x_gve_rec.isa_agreement_id = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.isa_agreement_id := l_gve_rec.isa_agreement_id;
      END IF;
      IF (x_gve_rec.copied_only_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_gve_rec.copied_only_yn := l_gve_rec.copied_only_yn;
      END IF;
      IF (x_gve_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.object_version_number := l_gve_rec.object_version_number;
      END IF;
      IF (x_gve_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.created_by := l_gve_rec.created_by;
      END IF;
      IF (x_gve_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_gve_rec.creation_date := l_gve_rec.creation_date;
      END IF;
      IF (x_gve_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.last_updated_by := l_gve_rec.last_updated_by;
      END IF;
      IF (x_gve_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_gve_rec.last_update_date := l_gve_rec.last_update_date;
      END IF;
      IF (x_gve_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_gve_rec.last_update_login := l_gve_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_GOVERNANCES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_gve_rec IN  gve_rec_type,
      x_gve_rec OUT NOCOPY gve_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_gve_rec := p_gve_rec;
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
      p_gve_rec,                         -- IN
      l_gve_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_gve_rec, l_def_gve_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_GOVERNANCES
    SET DNZ_CHR_ID = l_def_gve_rec.dnz_chr_id,
        CHR_ID = l_def_gve_rec.chr_id,
        CLE_ID = l_def_gve_rec.cle_id,
        CHR_ID_REFERRED = l_def_gve_rec.chr_id_referred,
        CLE_ID_REFERRED = l_def_gve_rec.cle_id_referred,
        ISA_AGREEMENT_ID = l_def_gve_rec.isa_agreement_id,
        COPIED_ONLY_YN = l_def_gve_rec.copied_only_yn,
        OBJECT_VERSION_NUMBER = l_def_gve_rec.object_version_number,
        CREATED_BY = l_def_gve_rec.created_by,
        CREATION_DATE = l_def_gve_rec.creation_date,
        LAST_UPDATED_BY = l_def_gve_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_gve_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_gve_rec.last_update_login
    WHERE ID = l_def_gve_rec.id;

    x_gve_rec := l_def_gve_rec;
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
  --------------------------------------
  -- update_row for:OKC_GOVERNANCES_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type,
    x_gvev_rec                     OUT NOCOPY gvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gvev_rec                     gvev_rec_type := p_gvev_rec;
    l_def_gvev_rec                 gvev_rec_type;
    l_gve_rec                      gve_rec_type;
    lx_gve_rec                     gve_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_gvev_rec	IN gvev_rec_type
    ) RETURN gvev_rec_type IS
      l_gvev_rec	gvev_rec_type := p_gvev_rec;
    BEGIN
      l_gvev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_gvev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_gvev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_gvev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_gvev_rec	IN gvev_rec_type,
      x_gvev_rec	OUT NOCOPY gvev_rec_type
    ) RETURN VARCHAR2 IS
      l_gvev_rec                     gvev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_gvev_rec := p_gvev_rec;
      -- Get current database values
      l_gvev_rec := get_rec(p_gvev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_gvev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.id := l_gvev_rec.id;
      END IF;
      IF (x_gvev_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.dnz_chr_id := l_gvev_rec.dnz_chr_id;
      END IF;
      IF (x_gvev_rec.isa_agreement_id = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.isa_agreement_id := l_gvev_rec.isa_agreement_id;
      END IF;
      IF (x_gvev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.object_version_number := l_gvev_rec.object_version_number;
      END IF;
      IF (x_gvev_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.chr_id := l_gvev_rec.chr_id;
      END IF;
      IF (x_gvev_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.cle_id := l_gvev_rec.cle_id;
      END IF;
      IF (x_gvev_rec.chr_id_referred = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.chr_id_referred := l_gvev_rec.chr_id_referred;
      END IF;
      IF (x_gvev_rec.cle_id_referred = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.cle_id_referred := l_gvev_rec.cle_id_referred;
      END IF;
      IF (x_gvev_rec.copied_only_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_gvev_rec.copied_only_yn := l_gvev_rec.copied_only_yn;
      END IF;
      IF (x_gvev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.created_by := l_gvev_rec.created_by;
      END IF;
      IF (x_gvev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_gvev_rec.creation_date := l_gvev_rec.creation_date;
      END IF;
      IF (x_gvev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.last_updated_by := l_gvev_rec.last_updated_by;
      END IF;
      IF (x_gvev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_gvev_rec.last_update_date := l_gvev_rec.last_update_date;
      END IF;
      IF (x_gvev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_gvev_rec.last_update_login := l_gvev_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_GOVERNANCES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_gvev_rec IN  gvev_rec_type,
      x_gvev_rec OUT NOCOPY gvev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_gvev_rec := p_gvev_rec;
      x_gvev_rec.OBJECT_VERSION_NUMBER := NVL(x_gvev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
	 /************************ HAND-CODED *********************************/
      x_gvev_rec.COPIED_ONLY_YN    := UPPER(x_gvev_rec.COPIED_ONLY_YN);
      /*********************** END HAND-CODED ********************************/
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
      p_gvev_rec,                        -- IN
      l_gvev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_gvev_rec, l_def_gvev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_gvev_rec := fill_who_columns(l_def_gvev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_gvev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_gvev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_gvev_rec, l_gve_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_gve_rec,
      lx_gve_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_gve_rec, l_def_gvev_rec);
    x_gvev_rec := l_def_gvev_rec;
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
  -- PL/SQL TBL update_row for:GVEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type,
    x_gvev_tbl                     OUT NOCOPY gvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gvev_tbl.COUNT > 0) THEN
      i := p_gvev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gvev_rec                     => p_gvev_tbl(i),
          x_gvev_rec                     => x_gvev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
        i := p_gvev_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
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
  ------------------------------------
  -- delete_row for:OKC_GOVERNANCES --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gve_rec                      IN gve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GOVERNANCES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gve_rec                      gve_rec_type:= p_gve_rec;
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
    DELETE FROM OKC_GOVERNANCES
     WHERE ID = l_gve_rec.id;

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
  --------------------------------------
  -- delete_row for:OKC_GOVERNANCES_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_rec                     IN gvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_gvev_rec                     gvev_rec_type := p_gvev_rec;
    l_gve_rec                      gve_rec_type;
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
    migrate(l_gvev_rec, l_gve_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_gve_rec
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
  -- PL/SQL TBL delete_row for:GVEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_gvev_tbl                     IN gvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_gvev_tbl.COUNT > 0) THEN
      i := p_gvev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_gvev_rec                     => p_gvev_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_gvev_tbl.LAST);
        i := p_gvev_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_GOVERNANCES table
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_gvev_tbl gvev_tbl_type) IS
  l_tabsize NUMBER := p_gvev_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_isa_agreement_id              OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_chr_id_referred               OKC_DATATYPES.NumberTabTyp;
  in_cle_id_referred               OKC_DATATYPES.NumberTabTyp;
  in_copied_only_yn                OKC_DATATYPES.Var3TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i                                NUMBER := p_gvev_tbl.FIRST;
  j                                NUMBER := 0;

BEGIN

   --Initialize return status
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

   -- pkoganti   08/26/2000
   -- replace for loop with while loop to handle
   -- gaps in pl/sql table indexes.
   -- Example:
   --   consider a pl/sql table(A) with the following elements
   --   A(1) = 10
   --   A(2) = 20
   --   A(6) = 30
   --   A(7) = 40
   --
   -- The for loop was erroring for indexes 3,4,5, the while loop
   -- along with the NEXT operator would handle the missing indexes
   -- with out causing the API to fail.
   --
  WHILE  i IS NOT NULL
  LOOP
    j                               := j + 1;

    in_id                       (j) := p_gvev_tbl(i).id;
    in_dnz_chr_id               (j) := p_gvev_tbl(i).dnz_chr_id;
    in_isa_agreement_id         (j) := p_gvev_tbl(i).isa_agreement_id;
    in_object_version_number    (j) := p_gvev_tbl(i).object_version_number;
    in_chr_id                   (j) := p_gvev_tbl(i).chr_id;
    in_cle_id                   (j) := p_gvev_tbl(i).cle_id;
    in_chr_id_referred          (j) := p_gvev_tbl(i).chr_id_referred;
    in_cle_id_referred          (j) := p_gvev_tbl(i).cle_id_referred;
    in_copied_only_yn           (j) := p_gvev_tbl(i).copied_only_yn;
    in_created_by               (j) := p_gvev_tbl(i).created_by;
    in_creation_date            (j) := p_gvev_tbl(i).creation_date;
    in_last_updated_by          (j) := p_gvev_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_gvev_tbl(i).last_update_date;
    in_last_update_login        (j) := p_gvev_tbl(i).last_update_login;

    i                               := p_gvev_tbl.NEXT(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_GOVERNANCES
      (
        id,
        dnz_chr_id,
        chr_id,
        cle_id,
        chr_id_referred,
        cle_id_referred,
        isa_agreement_id,
        copied_only_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login
     )
     VALUES (
        in_id(i),
        in_dnz_chr_id(i),
        in_chr_id(i),
        in_cle_id(i),
        in_chr_id_referred(i),
        in_cle_id_referred(i),
        in_isa_agreement_id(i),
        in_copied_only_yn(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i)
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
INSERT INTO okc_governances_h
  (
      major_version,
      id,
      dnz_chr_id,
      chr_id,
      cle_id,
      chr_id_referred,
      cle_id_referred,
      isa_agreement_id,
      copied_only_yn,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      p_major_version,
      id,
      dnz_chr_id,
      chr_id,
      cle_id,
      chr_id_referred,
      cle_id_referred,
      isa_agreement_id,
      copied_only_yn,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_governances
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
INSERT INTO okc_governances
  (
      id,
      dnz_chr_id,
      chr_id,
      cle_id,
      chr_id_referred,
      cle_id_referred,
      isa_agreement_id,
      copied_only_yn,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      dnz_chr_id,
      chr_id,
      cle_id,
      chr_id_referred,
      cle_id_referred,
      isa_agreement_id,
      copied_only_yn,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_governances_h
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
  /************************ HAND-CODED *********************************/
  -- Add view to the PL/SQL table for column length check
  Begin
	OKC_UTIL.add_view(p_view_name		=> G_VIEW,
				   x_return_status	=> l_return_status);
     If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	   raise G_EXCEPTION_HALT_VALIDATION;
     End If;
  exception
    when G_EXCEPTION_HALT_VALIDATION then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
  /*********************** END HAND-CODED ********************************/

END OKC_GVE_PVT;

/
