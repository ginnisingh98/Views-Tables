--------------------------------------------------------
--  DDL for Package Body OKC_CAC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CAC_PVT" AS
/* $Header: OKCSCACB.pls 120.0 2005/05/25 23:07:06 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/
  FUNCTION Validate_Attributes ( p_cacv_rec IN  cacv_rec_type)
		RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_VIEW			 CONSTANT	VARCHAR2(200) := 'OKC_K_ACCESSES_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_group_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_group_id(x_return_status OUT NOCOPY   VARCHAR2,
                            	p_cacv_rec      IN    cacv_rec_type) is
     l_dummy_var   VARCHAR2(1) := '?';
     Cursor l_jtfv_csr Is
  		select 'x'
  		from JTF_RS_GROUPS_B
  		where GROUP_ID = p_cacv_rec.group_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('100: Entered validate_group_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- Check JTF_RS_GROUPS_B for valid group id
    If (p_cacv_rec.group_id <> OKC_API.G_MISS_NUM and
  	   p_cacv_rec.group_id IS NOT NULL)
    Then
       -- enforce foreign key
       Open l_jtfv_csr;
       Fetch l_jtfv_csr Into l_dummy_var;
       Close l_jtfv_csr;

       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name		=> g_no_parent_record,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Group Id',
					  p_token2		=> g_child_table_token,
					  p_token2_value	=> G_VIEW,
					  p_token3		=> g_parent_table_token,
					  p_token3_value	=> 'JTF_RS_GROUPS_B');

	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
       End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('200: Leaving validate_group_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('300: Leaving validate_group_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_group_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_cacv_rec      IN    cacv_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKC_K_HEADERS_B
  		where ID = p_cacv_rec.chr_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('400: Entered validate_chr_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_cacv_rec.chr_id = OKC_API.G_MISS_NUM or
  	   p_cacv_rec.chr_id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'chr_id');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- enforce foreign key
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

  IF (l_debug = 'Y') THEN
     okc_debug.log('500: Leaving validate_chr_id', 2);
     okc_debug.Reset_Indentation;
  END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Exiting validate_chr_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_chrv_csr%ISOPEN then
	      close l_chrv_csr;
        end if;

  End validate_chr_id;

  PROCEDURE validate_resource_id(x_return_status OUT NOCOPY   VARCHAR2,
                                 p_cacv_rec      IN    cacv_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_jtfv_csr Is
  		select 'x'
  		from JTF_RS_RESOURCE_EXTNS
  		where RESOURCE_ID = p_cacv_rec.resource_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('800: Entered validate_resource_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- verify foreign key, if data exists
    If (p_cacv_rec.resource_id <> OKC_API.G_MISS_NUM and
  	   p_cacv_rec.resource_id IS NOT NULL)
    Then
      Open l_jtfv_csr;
      Fetch l_jtfv_csr Into l_dummy_var;
      Close l_jtfv_csr;
      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'Resource Id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'JTF_RS_RESOURCE_EXTNS');
	    -- set error flag
         x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('850: Leaving validate_resource_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('900: Exiting validate_resource_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_jtfv_csr%ISOPEN then
	      close l_jtfv_csr;
        end if;

  End validate_resource_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_access_level
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_access_level(x_return_status OUT NOCOPY   VARCHAR2,
                            	    p_cacv_rec      IN    cacv_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('1000: Entered validate_access_level', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_cacv_rec.access_level = OKC_API.G_MISS_CHAR or
  	   p_cacv_rec.access_level IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'access_level');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_cacv_rec.access_level) NOT IN ('U','R')) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'access_level');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

   IF (l_debug = 'Y') THEN
      okc_debug.log('1100: Leaving validate_access_level', 2);
      okc_debug.Reset_Indentation;
   END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting validate_access_level:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1300: Exiting validate_access_level:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_access_level;

  /*********************** END HAND-CODED ********************************/
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
  -- FUNCTION get_rec for: OKC_K_ACCESSES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cac_rec                      IN cac_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cac_rec_type IS
    CURSOR cac_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CHR_ID,
            GROUP_ID,
            RESOURCE_ID,
            ACCESS_LEVEL,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Accesses
     WHERE okc_k_accesses.id    = p_id;
    l_cac_pk                       cac_pk_csr%ROWTYPE;
    l_cac_rec                      cac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('1500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cac_pk_csr (p_cac_rec.id);
    FETCH cac_pk_csr INTO
              l_cac_rec.ID,
              l_cac_rec.CHR_ID,
              l_cac_rec.GROUP_ID,
              l_cac_rec.RESOURCE_ID,
              l_cac_rec.ACCESS_LEVEL,
              l_cac_rec.OBJECT_VERSION_NUMBER,
              l_cac_rec.CREATED_BY,
              l_cac_rec.CREATION_DATE,
              l_cac_rec.LAST_UPDATED_BY,
              l_cac_rec.LAST_UPDATE_DATE,
              l_cac_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cac_pk_csr%NOTFOUND;
    CLOSE cac_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Leaving  get_rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_cac_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cac_rec                      IN cac_rec_type
  ) RETURN cac_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_cac_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ACCESSES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cacv_rec                     IN cacv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cacv_rec_type IS
    CURSOR okc_cacv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            GROUP_ID,
            CHR_ID,
            RESOURCE_ID,
            ACCESS_LEVEL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Accesses_V
     WHERE okc_k_accesses_v.id  = p_id;
    l_okc_cacv_pk                  okc_cacv_pk_csr%ROWTYPE;
    l_cacv_rec                     cacv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('1700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cacv_pk_csr (p_cacv_rec.id);
    FETCH okc_cacv_pk_csr INTO
              l_cacv_rec.ID,
              l_cacv_rec.OBJECT_VERSION_NUMBER,
              l_cacv_rec.GROUP_ID,
              l_cacv_rec.CHR_ID,
              l_cacv_rec.RESOURCE_ID,
              l_cacv_rec.ACCESS_LEVEL,
              l_cacv_rec.CREATED_BY,
              l_cacv_rec.CREATION_DATE,
              l_cacv_rec.LAST_UPDATED_BY,
              l_cacv_rec.LAST_UPDATE_DATE,
              l_cacv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cacv_pk_csr%NOTFOUND;
    CLOSE okc_cacv_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Leaving  get_rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_cacv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cacv_rec                     IN cacv_rec_type
  ) RETURN cacv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_cacv_rec, l_row_notfound));

  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_ACCESSES_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cacv_rec	IN cacv_rec_type
  ) RETURN cacv_rec_type IS
    l_cacv_rec	cacv_rec_type := p_cacv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('1900: Entered null_out_defaults', 2);
    END IF;

    IF (l_cacv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cacv_rec.object_version_number := NULL;
    END IF;
    IF (l_cacv_rec.group_id = OKC_API.G_MISS_NUM) THEN
      l_cacv_rec.group_id := NULL;
    END IF;
    IF (l_cacv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_cacv_rec.chr_id := NULL;
    END IF;
    IF (l_cacv_rec.resource_id = OKC_API.G_MISS_NUM) THEN
      l_cacv_rec.resource_id := NULL;
    END IF;
    IF (l_cacv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_cacv_rec.access_level := NULL;
    END IF;
    IF (l_cacv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cacv_rec.created_by := NULL;
    END IF;
    IF (l_cacv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cacv_rec.creation_date := NULL;
    END IF;
    IF (l_cacv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cacv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cacv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cacv_rec.last_update_date := NULL;
    END IF;
    IF (l_cacv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cacv_rec.last_update_login := NULL;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Leaving  null_out_defaults ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_cacv_rec);

  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKC_K_ACCESSES_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_cacv_rec IN  cacv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('2100: Entered Validate_Attributes', 2);
    END IF;

  /************************ HAND-CODED *********************************/
    validate_group_id
			(x_return_status	=> l_return_status,
			 p_cacv_rec		=> p_cacv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

--dbms_output.put_line('2 Status : ' || l_return_status);
    validate_chr_id
			(x_return_status	=> l_return_status,
			 p_cacv_rec		=> p_cacv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

--dbms_output.put_line('3 Status : ' || l_return_status);
    validate_resource_id
			(x_return_status	=> l_return_status,
			 p_cacv_rec		=> p_cacv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

--dbms_output.put_line('4 Status : ' || l_return_status);
    validate_access_level
			(x_return_status	=> l_return_status,
			 p_cacv_rec		=> p_cacv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

--dbms_output.put_line('5 Status : ' || l_return_status);
    RETURN(x_return_status);

    IF (l_debug = 'Y') THEN
       okc_debug.log('2150: Leaving Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting Validate_Attributes:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ------------------------------------------
  -- Validate_Record for:OKC_K_ACCESSES_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_cacv_rec IN cacv_rec_type
  ) RETURN VARCHAR2 IS

    -- ------------------------------------------------------
    -- To check for any matching row, for unique combination.
    -- The cursor includes id check filter to handle updates
    -- for case K2 should not overwrite already existing K1
    -- Two cursors with and without null condition on columns.
    -- ------------------------------------------------------
       CURSOR cur_cac_1 IS
	  SELECT 'x'
	  FROM   okc_k_accesses
	  WHERE  chr_id       = p_cacv_rec.CHR_ID
       AND    resource_id  = p_cacv_rec.RESOURCE_ID
       AND    group_id    IS NULL
	  AND    id          <> NVL(p_cacv_rec.ID,-9999);

       CURSOR cur_cac_2 IS
	  SELECT 'x'
	  FROM   okc_k_accesses
	  WHERE  chr_id       = p_cacv_rec.CHR_ID
       AND    resource_id IS NULL
       AND    group_id     = p_cacv_rec.GROUP_ID
	  AND    id          <> NVL(p_cacv_rec.ID,-9999);

  l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_row_found       BOOLEAN     := FALSE;
  l_dummy           VARCHAR2(1);

----Bug-2314758
CURSOR group_name IS
 SELECT name
 FROM OKC_RESOURCE_GROUPS_V
 WHERE group_id = p_cacv_rec.GROUP_ID;

CURSOR user_name IS
SELECT name
FROM OKC_RESOURCE_USERS_V
WHERE ID  = p_cacv_rec.RESOURCE_ID;

l_user_group_name OKC_RESOURCE_GROUPS_V.NAME%TYPE;

l_token1_value    VARCHAR2(25);
----Bug-2314758

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('2400: Entered Validate_Record', 2);
    END IF;

    /************************ HAND-CODED ****************************/
    -- ------------------------------------------------
    -- RESOURCE_ID and GROUP_ID are mutually exclusive
    -- ------------------------------------------------
    IF (      p_cacv_rec.RESOURCE_ID IS NULL
	     AND p_cacv_rec.GROUP_ID IS NULL)
        OR
       (      p_cacv_rec.RESOURCE_ID IS NOT NULL
		AND p_cacv_rec.GROUP_ID IS NOT NULL)
    THEN
	    l_return_status := OKC_API.G_RET_STS_ERROR;
	    OKC_API.SET_MESSAGE(
			p_app_name      => g_app_name,
			p_msg_name      => g_invalid_value,
			p_token1        => g_col_name_token,
			p_token1_value  => 'RESOURCE_ID',
			p_token2        => g_col_name_token,
			p_token2_value  => 'GROUP_ID');

	    -- Set the return status as error
  	    raise G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ---------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call replaced with
    -- the explicit cursors above, for identical function to
    -- check uniqueness for composite key CHR_ID + RESOURCE_ID + GROUP_ID.
    -- RESOURCE_ID and GROUP_ID are mutually exclusive
    -- ---------------------------------------------------------------------
    IF (     p_cacv_rec.RESOURCE_ID IS NOT NULL
         AND p_cacv_rec.RESOURCE_ID <> OKC_API.G_MISS_NUM )
    THEN
	   OPEN  cur_cac_1;
	   FETCH cur_cac_1 INTO l_dummy;
	   l_row_found := cur_cac_1%FOUND;
	   CLOSE cur_cac_1;
    ELSIF (     p_cacv_rec.GROUP_ID IS NOT NULL
            AND p_cacv_rec.GROUP_ID <> OKC_API.G_MISS_NUM )
    THEN
	   OPEN  cur_cac_2;
	   FETCH cur_cac_2 INTO l_dummy;
	   l_row_found := cur_cac_2%FOUND;
	   CLOSE cur_cac_2;
    END IF;

    IF (l_row_found)  THEN
        IF p_cacv_rec.GROUP_ID IS NOT NULL THEN
     	      OPEN  group_name;
	      FETCH group_name INTO l_user_group_name;
	      CLOSE group_name;
        ELSIF p_cacv_rec.RESOURCE_ID IS NOT NULL THEN
           OPEN  user_name;
	      FETCH user_name INTO l_user_group_name;
	      CLOSE user_name;
        END IF;

        OKC_API.SET_MESSAGE(p_app_name        => g_app_name,
                            p_msg_name        => 'OKC_DUP_K_ACCESS_COMP_KEY',
                            p_token1          => 'TOKEN1',
                            p_token1_value    => l_user_group_name );

	    l_return_status := OKC_API.G_RET_STS_ERROR;
  	    RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    /*********************** END HAND-CODED *************************/

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Leaving Validate_Record', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN (l_return_status);

  EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting Validate_Record:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

          -- no processing necessary; validation can continue with next column
          RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cacv_rec_type,
    p_to	IN OUT NOCOPY cac_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.group_id := p_from.group_id;
    p_to.resource_id := p_from.resource_id;
    p_to.access_level := p_from.access_level;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;
  PROCEDURE migrate (
    p_from	IN cac_rec_type,
    p_to	IN OUT NOCOPY cacv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.group_id := p_from.group_id;
    p_to.resource_id := p_from.resource_id;
    p_to.access_level := p_from.access_level;
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
  ---------------------------------------
  -- validate_row for:OKC_K_ACCESSES_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cacv_rec                     cacv_rec_type := p_cacv_rec;
    l_cac_rec                      cac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('2700: Entered validate_row', 2);
    END IF;

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
    l_return_status := Validate_Attributes(l_cacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('2750: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2800: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:CACV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('3200: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cacv_tbl.COUNT > 0) THEN
      i := p_cacv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cacv_rec                     => p_cacv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cacv_tbl.LAST);
        i := p_cacv_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3250: leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('3500: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- insert_row for:OKC_K_ACCESSES --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cac_rec                      IN cac_rec_type,
    x_cac_rec                      OUT NOCOPY cac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ACCESSES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cac_rec                      cac_rec_type := p_cac_rec;
    l_def_cac_rec                  cac_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_ACCESSES --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_cac_rec IN  cac_rec_type,
      x_cac_rec OUT NOCOPY cac_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cac_rec := p_cac_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('3800: Entered insert_row', 2);
    END IF;

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
      p_cac_rec,                         -- IN
      l_cac_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_ACCESSES(
        id,
        chr_id,
        group_id,
        resource_id,
        access_level,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_cac_rec.id,
        l_cac_rec.chr_id,
        l_cac_rec.group_id,
        l_cac_rec.resource_id,
        l_cac_rec.access_level,
        l_cac_rec.object_version_number,
        l_cac_rec.created_by,
        l_cac_rec.creation_date,
        l_cac_rec.last_updated_by,
        l_cac_rec.last_update_date,
        l_cac_rec.last_update_login);
    -- Set OUT values
    x_cac_rec := l_cac_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('3900: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4100: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4200: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- insert_row for:OKC_K_ACCESSES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY cacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cacv_rec                     cacv_rec_type;
    l_def_cacv_rec                 cacv_rec_type;
    l_cac_rec                      cac_rec_type;
    lx_cac_rec                     cac_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cacv_rec	IN cacv_rec_type
    ) RETURN cacv_rec_type IS
      l_cacv_rec	cacv_rec_type := p_cacv_rec;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('4400: Entered fill_who_columns', 2);
    END IF;

      l_cacv_rec.CREATION_DATE := SYSDATE;
      l_cacv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cacv_rec.LAST_UPDATE_DATE := l_cacv_rec.CREATION_DATE;
      l_cacv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cacv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4500: Leaving fill_who_columns', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_cacv_rec);

    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_ACCESSES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cacv_rec IN  cacv_rec_type,
      x_cacv_rec OUT NOCOPY cacv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('4600: Entered Set_Attributes', 2);
    END IF;

      x_cacv_rec := p_cacv_rec;
	 /************************ HAND-CODED *********************************/
	 x_cacv_rec.ACCESS_LEVEL      := UPPER(x_cacv_rec.ACCESS_LEVEL);
	 /*********************** END HAND-CODED ********************************/
      x_cacv_rec.OBJECT_VERSION_NUMBER := 1;

 IF (l_debug = 'Y') THEN
    okc_debug.log('4700: Leaving Set_Attributes', 2);
    okc_debug.Reset_Indentation;
 END IF;

      RETURN(l_return_status);
    END Set_Attributes;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('4800: Entered insert_row', 2);
    END IF;

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
    l_cacv_rec := null_out_defaults(p_cacv_rec);
    -- Set primary key value
    l_cacv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cacv_rec,                        -- IN
      l_def_cacv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cacv_rec := fill_who_columns(l_def_cacv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cacv_rec, l_cac_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cac_rec,
      lx_cac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cac_rec, l_def_cacv_rec);
    -- Set OUT values
    x_cacv_rec := l_def_cacv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('4850: Leaving insert_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5100: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:CACV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY cacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('5300: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cacv_tbl.COUNT > 0) THEN
      i := p_cacv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cacv_rec                     => p_cacv_tbl(i),
          x_cacv_rec                     => x_cacv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cacv_tbl.LAST);
        i := p_cacv_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.log('5350: Leaving insert_row', 2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5400: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5500: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5600: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------
  -- lock_row for:OKC_K_ACCESSES --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cac_rec                      IN cac_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cac_rec IN cac_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_ACCESSES
     WHERE ID = p_cac_rec.id
       AND OBJECT_VERSION_NUMBER = p_cac_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cac_rec IN cac_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_ACCESSES
    WHERE ID = p_cac_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ACCESSES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_ACCESSES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_ACCESSES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('5800: Entered lock_row', 2);
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('5810: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_cac_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5820: Leaving LOCK_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5830: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cac_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cac_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cac_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6200: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6300: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- lock_row for:OKC_K_ACCESSES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cac_rec                      cac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('6500: Entered lock_row', 2);
    END IF;

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
    migrate(p_cacv_rec, l_cac_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6550: Leaving lock_row ', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6700: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:CACV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('7000: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cacv_tbl.COUNT > 0) THEN
      i := p_cacv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cacv_rec                     => p_cacv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cacv_tbl.LAST);
        i := p_cacv_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

   IF (l_debug = 'Y') THEN
      okc_debug.log('7050: Leaving lock_row', 2);
      okc_debug.Reset_Indentation;
   END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7200: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7300: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- update_row for:OKC_K_ACCESSES --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cac_rec                      IN cac_rec_type,
    x_cac_rec                      OUT NOCOPY cac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ACCESSES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cac_rec                      cac_rec_type := p_cac_rec;
    l_def_cac_rec                  cac_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cac_rec	IN cac_rec_type,
      x_cac_rec	OUT NOCOPY cac_rec_type
    ) RETURN VARCHAR2 IS
      l_cac_rec                      cac_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('7500: Entered populate_new_record', 2);
    END IF;

      x_cac_rec := p_cac_rec;
      -- Get current database values
      l_cac_rec := get_rec(p_cac_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cac_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.id := l_cac_rec.id;
      END IF;
      IF (x_cac_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.chr_id := l_cac_rec.chr_id;
      END IF;
      IF (x_cac_rec.group_id = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.group_id := l_cac_rec.group_id;
      END IF;
      IF (x_cac_rec.resource_id = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.resource_id := l_cac_rec.resource_id;
      END IF;
      IF (x_cac_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_cac_rec.access_level := l_cac_rec.access_level;
      END IF;
      IF (x_cac_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.object_version_number := l_cac_rec.object_version_number;
      END IF;
      IF (x_cac_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.created_by := l_cac_rec.created_by;
      END IF;
      IF (x_cac_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cac_rec.creation_date := l_cac_rec.creation_date;
      END IF;
      IF (x_cac_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.last_updated_by := l_cac_rec.last_updated_by;
      END IF;
      IF (x_cac_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cac_rec.last_update_date := l_cac_rec.last_update_date;
      END IF;
      IF (x_cac_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cac_rec.last_update_login := l_cac_rec.last_update_login;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('7600: Leaving lock_row', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_ACCESSES --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_cac_rec IN  cac_rec_type,
      x_cac_rec OUT NOCOPY cac_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cac_rec := p_cac_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('7700: Entered update_row', 2);
    END IF;

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
      p_cac_rec,                         -- IN
      l_cac_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cac_rec, l_def_cac_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_ACCESSES
    SET CHR_ID = l_def_cac_rec.chr_id,
        GROUP_ID = l_def_cac_rec.group_id,
        RESOURCE_ID = l_def_cac_rec.resource_id,
        ACCESS_LEVEL = l_def_cac_rec.access_level,
        OBJECT_VERSION_NUMBER = l_def_cac_rec.object_version_number,
        CREATED_BY = l_def_cac_rec.created_by,
        CREATION_DATE = l_def_cac_rec.creation_date,
        LAST_UPDATED_BY = l_def_cac_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cac_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cac_rec.last_update_login
    WHERE ID = l_def_cac_rec.id;

    x_cac_rec := l_def_cac_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('7750: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7900: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8000: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- update_row for:OKC_K_ACCESSES_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type,
    x_cacv_rec                     OUT NOCOPY cacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cacv_rec                     cacv_rec_type := p_cacv_rec;
    l_def_cacv_rec                 cacv_rec_type;
    l_cac_rec                      cac_rec_type;
    lx_cac_rec                     cac_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cacv_rec	IN cacv_rec_type
    ) RETURN cacv_rec_type IS
      l_cacv_rec	cacv_rec_type := p_cacv_rec;
    BEGIN

      l_cacv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cacv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cacv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cacv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cacv_rec	IN cacv_rec_type,
      x_cacv_rec	OUT NOCOPY cacv_rec_type
    ) RETURN VARCHAR2 IS
      l_cacv_rec                     cacv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('8200: Entered populate_new_record', 2);
    END IF;

      x_cacv_rec := p_cacv_rec;
      -- Get current database values
      l_cacv_rec := get_rec(p_cacv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cacv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.id := l_cacv_rec.id;
      END IF;
      IF (x_cacv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.object_version_number := l_cacv_rec.object_version_number;
      END IF;
      IF (x_cacv_rec.group_id = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.group_id := l_cacv_rec.group_id;
      END IF;
      IF (x_cacv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.chr_id := l_cacv_rec.chr_id;
      END IF;
      IF (x_cacv_rec.resource_id = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.resource_id := l_cacv_rec.resource_id;
      END IF;
      IF (x_cacv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_cacv_rec.access_level := l_cacv_rec.access_level;
      END IF;
      IF (x_cacv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.created_by := l_cacv_rec.created_by;
      END IF;
      IF (x_cacv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cacv_rec.creation_date := l_cacv_rec.creation_date;
      END IF;
      IF (x_cacv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.last_updated_by := l_cacv_rec.last_updated_by;
      END IF;
      IF (x_cacv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cacv_rec.last_update_date := l_cacv_rec.last_update_date;
      END IF;
      IF (x_cacv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cacv_rec.last_update_login := l_cacv_rec.last_update_login;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('8300: Exiting populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_ACCESSES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cacv_rec IN  cacv_rec_type,
      x_cacv_rec OUT NOCOPY cacv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cacv_rec := p_cacv_rec;
      x_cacv_rec.OBJECT_VERSION_NUMBER := NVL(x_cacv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
	 /************************ HAND-CODED *********************************/
	 x_cacv_rec.ACCESS_LEVEL      := UPPER(x_cacv_rec.ACCESS_LEVEL);
	 /*********************** END HAND-CODED ********************************/
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('8400: Entered update_row', 2);
    END IF;

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
      p_cacv_rec,                        -- IN
      l_cacv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cacv_rec, l_def_cacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cacv_rec := fill_who_columns(l_def_cacv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cacv_rec, l_cac_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cac_rec,
      lx_cac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cac_rec, l_def_cacv_rec);
    x_cacv_rec := l_def_cacv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8450: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8500: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8700: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:CACV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type,
    x_cacv_tbl                     OUT NOCOPY cacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('8900: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cacv_tbl.COUNT > 0) THEN
      i := p_cacv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cacv_rec                     => p_cacv_tbl(i),
          x_cacv_rec                     => x_cacv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cacv_tbl.LAST);
        i := p_cacv_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8950: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9000: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9200: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- delete_row for:OKC_K_ACCESSES --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cac_rec                      IN cac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ACCESSES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cac_rec                      cac_rec_type:= p_cac_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('9400: Entered delete_row', 2);
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_K_ACCESSES
     WHERE ID = l_cac_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('9450: Leaving delete_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9500: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9700: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------------
  -- delete_row for:OKC_K_ACCESSES_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_rec                     IN cacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cacv_rec                     cacv_rec_type := p_cacv_rec;
    l_cac_rec                      cac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('9900: Entered delete_row', 2);
    END IF;

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
    migrate(l_cacv_rec, l_cac_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9950: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10000: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10100: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10200: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:CACV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cacv_tbl                     IN cacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('10400: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cacv_tbl.COUNT > 0) THEN
      i := p_cacv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cacv_rec                     => p_cacv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cacv_tbl.LAST);
        i := p_cacv_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('10450: Leaving delete_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10500: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10600: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10700: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('10900: Entered create_version', 2);
    END IF;

INSERT INTO okc_k_accesses_h
  (
      major_version,
      id,
      chr_id,
      group_id,
      resource_id,
      access_level,
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
      chr_id,
      group_id,
      resource_id,
      access_level,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_k_accesses
WHERE chr_id = p_chr_id;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10000: Leaving create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Exiting create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CAC_PVT');
       okc_debug.log('11300: Entered restore_version', 2);
    END IF;

INSERT INTO okc_k_accesses
(
      id,
      chr_id,
      group_id,
      resource_id,
      access_level,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
  SELECT
      id,
      chr_id,
      group_id,
      resource_id,
      access_level,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  FROM okc_k_accesses_h
WHERE chr_id = p_chr_id
  AND major_version = p_major_version;

IF (l_debug = 'Y') THEN
   okc_debug.log('11400: Leaving restore_version', 2);
   okc_debug.Reset_Indentation;
END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11500: Exiting restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

END OKC_CAC_PVT;

/
