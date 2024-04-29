--------------------------------------------------------
--  DDL for Package Body OKC_OLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OLE_PVT" AS
/* $Header: OKCSOLEB.pls 120.0 2005/05/25 19:19:39 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/

  FUNCTION Validate_Attributes ( p_olev_rec IN  olev_rec_type) RETURN VARCHAR2;
  --G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_VIEW             CONSTANT VARCHAR2(200) := 'OKC_OPERATION_INSTANCES_V';
  G_EXCEPTION_HALT_VALIDATION exception;
  --l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_select_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_select_yn(x_return_status OUT NOCOPY   VARCHAR2,
                         	 p_olev_rec      IN    olev_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('100: Entered validate_select_yn', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    /*
    -- check that data exists
    If (p_olev_rec.select_yn = OKC_API.G_MISS_CHAR or
  	   p_olev_rec.select_yn IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Select Flag');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;
    */

    -- check allowed values
    If (p_olev_rec.select_yn <> OKC_API.G_MISS_CHAR and
  	   p_olev_rec.select_yn IS NOT NULL)
    Then
        If (p_olev_rec.select_yn NOT IN ('Y','N')) Then
  	      OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					      p_msg_name		=> g_invalid_value,
					      p_token1		     => g_col_name_token,
					      p_token1_value	=> 'Select Flag');
	       -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        End If;
    End If;

 IF (l_debug = 'Y') THEN
    okc_debug.log('200: Leaving validate_select_yn', 2);
    okc_debug.Reset_Indentation;
 END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('300: Exiting validate_select_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('400: Exiting validate_select_yn:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_select_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_active_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_active_yn(x_return_status OUT NOCOPY   VARCHAR2,
                            	  p_olev_rec      IN    olev_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('500: Entered validate_active_yn', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

   /*
    -- check that data exists
    If (p_olev_rec.active_yn = OKC_API.G_MISS_CHAR or
  	   p_olev_rec.active_yn IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Active Flag');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;
   */

    -- check allowed values
    If (p_olev_rec.active_yn <> OKC_API.G_MISS_CHAR and
  	   p_olev_rec.active_yn IS NOT NULL)
    Then
        If (p_olev_rec.active_yn NOT IN ('Y','N')) Then
  	      OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					      p_msg_name		=> g_invalid_value,
					      p_token1		     => g_col_name_token,
					      p_token1_value	=> 'Active Flag');
	       -- notify caller of an error
            x_return_status := OKC_API.G_RET_STS_ERROR;
        End If;
    End If;

 IF (l_debug = 'Y') THEN
    okc_debug.log('600: Leaving validate_active_yn ', 2);
    okc_debug.Reset_Indentation;
 END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_active_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Exiting validate_active_yn:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_active_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_process_flag
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_process_flag(x_return_status OUT NOCOPY   VARCHAR2,
              	                   p_olev_rec IN olev_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('900: Entered validate_process_flag', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for allowed values
    -- (A)vailable, (P)rocessed, (E)rror
    If (p_olev_rec.process_flag <> OKC_API.G_MISS_CHAR and
  	   p_olev_rec.process_flag IS NOT NULL)
    Then
       If (p_olev_rec.process_flag NOT IN ('P','A','E')) Then
             -- Check if the value is a valid code from lookup table
             x_return_status := OKC_UTIL.check_lookup_code(
                                                'OKS_MASSCHANGE_STATUS',
                                              p_olev_rec.process_flag);
             If (x_return_status = OKC_API.G_RET_STS_ERROR) Then

  	        OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
					     p_msg_name	=> g_invalid_value,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Process Flag');

	        -- halt validation
	        raise G_EXCEPTION_HALT_VALIDATION;
            Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
                raise G_EXCEPTION_HALT_VALIDATION;
            End If;
       End If;
    End If;

IF (l_debug = 'Y') THEN
   okc_debug.log('1000: Leaving validate_process_flag', 2);
   okc_debug.Reset_Indentation;
END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Exiting validate_process_flag:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting validate_process_flag:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_process_flag;

  -- Start of comments
  --
  -- Procedure Name  : validate_oie_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_oie_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_olev_rec      IN    olev_rec_type) is
	 l_dummy_var   VARCHAR2(1) := '?';
      CURSOR l_oiev_csr (p_oie_id IN NUMBER) IS
      SELECT 'x'
        FROM okc_operation_instances
       WHERE id = p_oie_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('1300: Entered validate_oie_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_olev_rec.oie_id = OKC_API.G_MISS_NUM or
	   p_olev_rec.oie_id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Operation Instance Id');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Check foreign key
    Open l_oiev_csr(p_olev_rec.oie_id);
    Fetch l_oiev_csr into l_dummy_var;
    Close l_oiev_csr;

    -- if l_dummy_var still set to default, data was not found
    If (l_dummy_var = '?') Then
    	  OKC_API.SET_MESSAGE(
				    p_app_name      => g_app_name,
				    p_msg_name      => g_no_parent_record,
				    p_token1        => g_col_name_token,
				    p_token1_value  => 'Operation Instance Id',
				    p_token2        => g_child_table_token,
				    p_token2_value  => G_VIEW,
				    p_token3        => g_parent_table_token,
				    p_token3_value  => 'OKC_OPERATION_INSTANCES_V');
	  -- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

 IF (l_debug = 'Y') THEN
    okc_debug.log('1400: Leaving validate_oie_id', 2);
    okc_debug.Reset_Indentation;
 END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_oie_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Exiting validate_oie_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_oie_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_parent_ole_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_parent_ole_id(x_return_status OUT NOCOPY   VARCHAR2,
                                    p_olev_rec      IN    olev_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_olev_csr Is
  	  select 'x'
	  from OKC_OPERATION_LINES
  	  where id = p_olev_rec.parent_ole_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('1700: Entered validate_parent_ole_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (parent_ole_id is optional)
    If (p_olev_rec.parent_ole_id <> OKC_API.G_MISS_NUM and
  	   p_olev_rec.parent_ole_id IS NOT NULL)
    Then
       Open l_olev_csr;
       Fetch l_olev_csr Into l_dummy_var;
       Close l_olev_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Operation Line Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_OPERATION_LINES_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

IF (l_debug = 'Y') THEN
   okc_debug.log('1800: Leaving validate_parent_ole_id', 2);
   okc_debug.Reset_Indentation;
END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting validate_parent_ole_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
        if l_olev_csr%ISOPEN then
	      close l_olev_csr;
        end if;

  End validate_parent_ole_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_subject_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_subject_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                                    p_olev_rec      IN    olev_rec_type) is
	 l_dummy_var   VARCHAR2(1) := '?';
      CURSOR l_chrv_csr (p_subject_chr_id IN NUMBER) IS
      SELECT 'x'
        FROM okc_k_headers_b
       WHERE id = p_subject_chr_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('2000: Entered validate_subject_chr_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_olev_rec.subject_chr_id = OKC_API.G_MISS_NUM or
	   p_olev_rec.subject_chr_id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Contract Header Id');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Check foreign key
    Open l_chrv_csr(p_olev_rec.subject_chr_id);
    Fetch l_chrv_csr into l_dummy_var;
    Close l_chrv_csr;

    -- if l_dummy_var still set to default, data was not found
    If (l_dummy_var = '?') Then
    	  OKC_API.SET_MESSAGE(
				    p_app_name      => g_app_name,
				    p_msg_name      => g_no_parent_record,
				    p_token1        => g_col_name_token,
				    p_token1_value  => 'Contract Header Id',
				    p_token2        => g_child_table_token,
				    p_token2_value  => G_VIEW,
				    p_token3        => g_parent_table_token,
				    p_token3_value  => 'OKC_K_HEADERS_V');
	  -- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Leaving validate_subject_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting validate_subject_chr_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Exiting validate_subject_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_subject_chr_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_object_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_object_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                                   p_olev_rec      IN    olev_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_chrv_csr Is
  	  select 'x'
	  from OKC_K_HEADERS_B
  	  where id = p_olev_rec.object_chr_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('2400: Entered validate_object_chr_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (object_chr_id is optional)
    If (p_olev_rec.object_chr_id <> OKC_API.G_MISS_NUM and
  	   p_olev_rec.object_chr_id IS NOT NULL)
    Then
       Open l_chrv_csr;
       Fetch l_chrv_csr Into l_dummy_var;
       Close l_chrv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Object Contract Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_K_HEADERS_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Leaving validate_object_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting validate_object_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

  End validate_object_chr_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_object_cle_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_object_cle_id(x_return_status OUT NOCOPY   VARCHAR2,
                                   p_olev_rec      IN    olev_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_clev_csr Is
  	  select 'x'
	  from OKC_K_LINES_B
  	  where id = p_olev_rec.object_cle_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('2700: Entered validate_object_cle_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (object_cle_id is optional)
    If (p_olev_rec.object_cle_id <> OKC_API.G_MISS_NUM and
  	   p_olev_rec.object_cle_id IS NOT NULL)
    Then
       Open l_clev_csr;
       Fetch l_clev_csr Into l_dummy_var;
       Close l_clev_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Object Line Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_K_LINES_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2800: Leaving validate_object_cle_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Exiting validate_object_cle_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

  End validate_object_cle_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_subject_cle_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_subject_cle_id(x_return_status OUT NOCOPY   VARCHAR2,
                                    p_olev_rec      IN    olev_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_clev_csr Is
  	  select 'x'
	  from OKC_K_LINES_B
  	  where id = p_olev_rec.subject_cle_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('3000: Entered validate_subject_cle_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (subject_cle_id is optional)
    If (p_olev_rec.subject_cle_id <> OKC_API.G_MISS_NUM and
  	   p_olev_rec.subject_cle_id IS NOT NULL)
    Then
       Open l_clev_csr;
       Fetch l_clev_csr Into l_dummy_var;
       Close l_clev_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Subject Line Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_K_LINES_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Leaving validate_subject_cle_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3200: Exiting validate_subject_cle_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

  End validate_subject_cle_id;

  PROCEDURE validate_message_code(x_return_status OUT NOCOPY   VARCHAR2,
                                  p_olev_rec      IN    olev_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('3300: Entered validate_message_code', 2);
    END IF;

    -- initialize return message
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key
    If (p_olev_rec.message_code <> OKC_API.G_MISS_CHAR and
	   p_olev_rec.message_code IS NOT NULL)
    Then
      -- Check if the value is a valid code from lookup table
      x_return_status := OKC_UTIL.check_lookup_code(
						'OKC_OPR_LINE_MESSAGE_CODE',
					      p_olev_rec.message_code);
      If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
	    --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_INVALID_VALUE,
			p_token1		=> G_COL_NAME_TOKEN,
			p_token1_value => 'Message Code');
	    raise G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
	    raise G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Leaving validate_message_code', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3500: Exiting validate_message_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_message_code;

  /*********************** END HAND-CODED ********************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
    Cursor c Is
    SELECT OKC_OPERATION_LINES_S1.nextval
    FROM dual;

    l_seq NUMBER;
  BEGIN

    open c;
    fetch c into l_seq;
    close c;
    RETURN (l_seq);

    --RETURN(okc_p_util.raw_to_number(sys_guid()));

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
  -- FUNCTION get_rec for: OKC_OPERATION_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ole_rec                      IN ole_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ole_rec_type IS
    CURSOR okc_operation_lines_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SELECT_YN,
            PROCESS_FLAG,
		  ACTIVE_YN,
            OIE_ID,
		  PARENT_OLE_ID,
            SUBJECT_CHR_ID,
            OBJECT_CHR_ID,
            SUBJECT_CLE_ID,
            OBJECT_CLE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            MESSAGE_CODE
      FROM Okc_Operation_Lines
     WHERE okc_operation_lines.id = p_id;
    l_okc_operation_lines_pk       okc_operation_lines_pk_csr%ROWTYPE;
    l_ole_rec                      ole_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('4000: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_operation_lines_pk_csr (p_ole_rec.id);
    FETCH okc_operation_lines_pk_csr INTO
              l_ole_rec.ID,
              l_ole_rec.SELECT_YN,
              l_ole_rec.PROCESS_FLAG,
              l_ole_rec.ACTIVE_YN,
              l_ole_rec.OIE_ID,
		    l_ole_rec.PARENT_OLE_ID,
              l_ole_rec.SUBJECT_CHR_ID,
              l_ole_rec.OBJECT_CHR_ID,
              l_ole_rec.SUBJECT_CLE_ID,
              l_ole_rec.OBJECT_CLE_ID,
              l_ole_rec.OBJECT_VERSION_NUMBER,
              l_ole_rec.CREATED_BY,
              l_ole_rec.CREATION_DATE,
              l_ole_rec.LAST_UPDATED_BY,
              l_ole_rec.LAST_UPDATE_DATE,
              l_ole_rec.LAST_UPDATE_LOGIN,
              l_ole_rec.REQUEST_ID,
              l_ole_rec.PROGRAM_APPLICATION_ID,
              l_ole_rec.PROGRAM_ID,
              l_ole_rec.PROGRAM_UPDATE_DATE,
              l_ole_rec.MESSAGE_CODE;
    x_no_data_found := okc_operation_lines_pk_csr%NOTFOUND;
    CLOSE okc_operation_lines_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('4050: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_ole_rec);

  END get_rec;

  FUNCTION get_rec (
    p_ole_rec                      IN ole_rec_type
  ) RETURN ole_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_ole_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_OPERATION_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_olev_rec                      IN olev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN olev_rec_type IS
    CURSOR okc_operation_lines_v_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SELECT_YN,
            PROCESS_FLAG,
		  ACTIVE_YN,
            OIE_ID,
		  PARENT_OLE_ID,
            SUBJECT_CHR_ID,
            OBJECT_CHR_ID,
            SUBJECT_CLE_ID,
            OBJECT_CLE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            MESSAGE_CODE
      FROM Okc_Operation_Lines_V
     WHERE okc_operation_lines_v.id = p_id;
    l_okc_operation_lines_v_pk     okc_operation_lines_v_pk_csr%ROWTYPE;
    l_olev_rec                      olev_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('4200: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_operation_lines_v_pk_csr (p_olev_rec.id);
    FETCH okc_operation_lines_v_pk_csr INTO
              l_olev_rec.ID,
              l_olev_rec.SELECT_YN,
              l_olev_rec.PROCESS_FLAG,
              l_olev_rec.ACTIVE_YN,
              l_olev_rec.OIE_ID,
		    l_olev_rec.PARENT_OLE_ID,
              l_olev_rec.SUBJECT_CHR_ID,
              l_olev_rec.OBJECT_CHR_ID,
              l_olev_rec.SUBJECT_CLE_ID,
              l_olev_rec.OBJECT_CLE_ID,
              l_olev_rec.OBJECT_VERSION_NUMBER,
              l_olev_rec.CREATED_BY,
              l_olev_rec.CREATION_DATE,
              l_olev_rec.LAST_UPDATED_BY,
              l_olev_rec.LAST_UPDATE_DATE,
              l_olev_rec.LAST_UPDATE_LOGIN,
              l_olev_rec.REQUEST_ID,
              l_olev_rec.PROGRAM_APPLICATION_ID,
              l_olev_rec.PROGRAM_ID,
              l_olev_rec.PROGRAM_UPDATE_DATE,
              l_olev_rec.MESSAGE_CODE;
    x_no_data_found := okc_operation_lines_v_pk_csr%NOTFOUND;
    CLOSE okc_operation_lines_v_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('4250: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_olev_rec);

  END get_rec;

  FUNCTION get_rec (
    p_olev_rec                      IN olev_rec_type
  ) RETURN olev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_olev_rec, l_row_notfound));

  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_OPERATION_LINES_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_olev_rec	IN olev_rec_type
  ) RETURN olev_rec_type IS
    l_olev_rec	olev_rec_type := p_olev_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('4400: Entered null_out_defaults', 2);
    END IF;

    IF (l_olev_rec.select_yn = OKC_API.G_MISS_CHAR) THEN
      l_olev_rec.select_yn := NULL;
    END IF;
    IF (l_olev_rec.process_flag = OKC_API.G_MISS_CHAR) THEN
      l_olev_rec.process_flag := NULL;
    END IF;
    IF (l_olev_rec.active_yn = OKC_API.G_MISS_CHAR) THEN
      l_olev_rec.active_yn := NULL;
    END IF;
    IF (l_olev_rec.oie_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.oie_id := NULL;
    END IF;
    IF (l_olev_rec.parent_ole_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.parent_ole_id := NULL;
    END IF;
    IF (l_olev_rec.subject_chr_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.subject_chr_id := NULL;
    END IF;
    IF (l_olev_rec.object_chr_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.object_chr_id := NULL;
    END IF;
    IF (l_olev_rec.subject_cle_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.subject_cle_id := NULL;
    END IF;
    IF (l_olev_rec.object_cle_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.object_cle_id := NULL;
    END IF;
    IF (l_olev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.object_version_number := NULL;
    END IF;
    IF (l_olev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.created_by := NULL;
    END IF;
    IF (l_olev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_olev_rec.creation_date := NULL;
    END IF;
    IF (l_olev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.last_updated_by := NULL;
    END IF;
    IF (l_olev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_olev_rec.last_update_date := NULL;
    END IF;
    IF (l_olev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.last_update_login := NULL;
    END IF;
    IF (l_olev_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.request_id := NULL;
    END IF;
    IF (l_olev_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.program_application_id := NULL;
    END IF;
    IF (l_olev_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_olev_rec.program_id := NULL;
    END IF;
    IF (l_olev_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_olev_rec.program_update_date := NULL;
    END IF;
    IF (l_olev_rec.message_code = OKC_API.G_MISS_CHAR) THEN
      l_olev_rec.message_code := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('4450: Leaving  null_out_defaults ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_olev_rec);
 END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKC_OPERATION_LINES_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_olev_rec IN  olev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('4500: Entered Validate_Attributes', 2);
    END IF;


	  validate_select_yn(x_return_status => l_return_status,
					 p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_active_yn(x_return_status => l_return_status,
					 p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_process_flag(x_return_status => l_return_status,
					    p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_oie_id(x_return_status => l_return_status,
				   p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_parent_ole_id(x_return_status => l_return_status,
				          p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_subject_chr_id(x_return_status => l_return_status,
					      p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_object_chr_id(x_return_status => l_return_status,
					     p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_subject_cle_id(x_return_status => l_return_status,
					      p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_object_cle_id(x_return_status => l_return_status,
					     p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_message_code(x_return_status => l_return_status,
					    p_olev_rec      => p_olev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

IF (l_debug = 'Y') THEN
   okc_debug.log('4550: Leaving  Validate_Attributes  ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(x_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKC_OPERATION_LINES_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_olev_rec IN olev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN olev_rec_type,
    p_to	IN OUT NOCOPY ole_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.select_yn := p_from.select_yn;
    p_to.process_flag := p_from.process_flag;
    p_to.active_yn := p_from.active_yn;
    p_to.oie_id := p_from.oie_id;
    p_to.parent_ole_id := p_from.parent_ole_id;
    p_to.subject_chr_id := p_from.subject_chr_id;
    p_to.object_chr_id := p_from.object_chr_id;
    p_to.subject_cle_id := p_from.subject_cle_id;
    p_to.object_cle_id := p_from.object_cle_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.message_code := p_from.message_code;

  END migrate;

  PROCEDURE migrate (
    p_from	IN ole_rec_type,
    p_to	IN OUT NOCOPY olev_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.select_yn := p_from.select_yn;
    p_to.process_flag := p_from.process_flag;
    p_to.active_yn := p_from.active_yn;
    p_to.oie_id := p_from.oie_id;
    p_to.parent_ole_id := p_from.parent_ole_id;
    p_to.subject_chr_id := p_from.subject_chr_id;
    p_to.object_chr_id := p_from.object_chr_id;
    p_to.subject_cle_id := p_from.subject_cle_id;
    p_to.object_cle_id := p_from.object_cle_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.message_code := p_from.message_code;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKC_OPERATION_LINES_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_olev_rec                      olev_rec_type := p_olev_rec;
    l_ole_rec                      ole_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('4900: Entered validate_row', 2);
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
    l_return_status := Validate_Attributes(l_olev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_olev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('5000: Leaving validate_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5100: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5200: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5300: Exiting validate_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- PL/SQL TBL validate_row for:olev_TBL --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('5400: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_olev_tbl.COUNT > 0) THEN
      i := p_olev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_olev_rec                      => p_olev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_olev_tbl.LAST);
        i := p_olev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5600: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5700: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5800: Exiting validate_row:OTHERS Exception', 2);
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
    IF (l_debug = 'Y') THEN
       okc_debug.log('5650: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- insert_row for:OKC_OPERATION_LINES --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ole_rec                      IN ole_rec_type,
    x_ole_rec                      OUT NOCOPY ole_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ole_rec                      ole_rec_type := p_ole_rec;
    l_def_ole_rec                  ole_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_LINES --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ole_rec IN  ole_rec_type,
      x_ole_rec OUT NOCOPY ole_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_ole_rec := p_ole_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('6000: Entered insert_row', 2);
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
      p_ole_rec,                         -- IN
      l_ole_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_OPERATION_LINES(
        id,
        select_yn,
        process_flag,
        active_yn,
        oie_id,
	   parent_ole_id,
        subject_chr_id,
        object_chr_id,
        subject_cle_id,
        object_cle_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        message_code)
      VALUES (
        l_ole_rec.id,
        l_ole_rec.select_yn,
        l_ole_rec.process_flag,
        l_ole_rec.active_yn,
        l_ole_rec.oie_id,
	   l_ole_rec.parent_ole_id,
        l_ole_rec.subject_chr_id,
        l_ole_rec.object_chr_id,
        l_ole_rec.subject_cle_id,
        l_ole_rec.object_cle_id,
        l_ole_rec.object_version_number,
        l_ole_rec.created_by,
        l_ole_rec.creation_date,
        l_ole_rec.last_updated_by,
        l_ole_rec.last_update_date,
        l_ole_rec.last_update_login,
	   decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
	   decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
	   decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
	   decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        l_ole_rec.message_code);
    -- Set OUT values
    x_ole_rec := l_ole_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6200: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6300: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6400: Exiting insert_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- insert_row for:OKC_OPERATION_LINES_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type,
    x_olev_rec                      OUT NOCOPY olev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_olev_rec                      olev_rec_type;
    l_def_olev_rec                  olev_rec_type;
    l_ole_rec                      ole_rec_type;
    lx_ole_rec                     ole_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_olev_rec	IN olev_rec_type
    ) RETURN olev_rec_type IS
      l_olev_rec	olev_rec_type := p_olev_rec;
    BEGIN

      l_olev_rec.CREATION_DATE := SYSDATE;
      l_olev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_olev_rec.LAST_UPDATE_DATE := l_olev_rec.CREATION_DATE;
      l_olev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_olev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_olev_rec);

    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_olev_rec IN  olev_rec_type,
      x_olev_rec OUT NOCOPY olev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_olev_rec := p_olev_rec;
      x_olev_rec.OBJECT_VERSION_NUMBER := 1;
      x_olev_rec.SELECT_YN := upper(x_olev_rec.SELECT_YN);
      x_olev_rec.PROCESS_FLAG := upper(x_olev_rec.PROCESS_FLAG);
      x_olev_rec.ACTIVE_YN := upper(x_olev_rec.ACTIVE_YN);
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('6700: Entered insert_row', 2);
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
    l_olev_rec := null_out_defaults(p_olev_rec);
    -- Set primary key value
    l_olev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_olev_rec,                         -- IN
      l_def_olev_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_olev_rec := fill_who_columns(l_def_olev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_olev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_olev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_olev_rec, l_ole_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ole_rec,
      lx_ole_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ole_rec, l_def_olev_rec);
    -- Set OUT values
    x_olev_rec := l_def_olev_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('6800: Leaving insert_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7100: Exiting insert_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- PL/SQL TBL insert_row for:olev_TBL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type,
    x_olev_tbl                      OUT NOCOPY olev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('7200: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_olev_tbl.COUNT > 0) THEN
      i := p_olev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_olev_rec                      => p_olev_tbl(i),
          x_olev_rec                      => x_olev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_olev_tbl.LAST);
        i := p_olev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('7300: Leaving insert_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7400: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7500: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7600: Exiting insert_row:OTHERS Exception', 2);
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
  --------------------------------------
  -- lock_row for:OKC_OPERATION_LINES --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ole_rec                      IN ole_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ole_rec IN ole_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OPERATION_LINES
     WHERE ID = p_ole_rec.id
       AND OBJECT_VERSION_NUMBER = p_ole_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ole_rec IN ole_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OPERATION_LINES
    WHERE ID = p_ole_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_OPERATION_LINES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_OPERATION_LINES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('7700: Entered lock_row', 2);
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

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('7800: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_ole_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

 IF (l_debug = 'Y') THEN
    okc_debug.log('7900: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8000: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ole_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ole_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ole_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('8100: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8300: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8400: Exiting lock_row:OTHERS Exception', 2);
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
  ----------------------------------------
  -- lock_row for:OKC_OPERATION_LINES_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ole_rec                      ole_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('8500: Entered lock_row', 2);
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
    migrate(p_olev_rec, l_ole_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ole_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8700: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8800: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8900: Exiting lock_row:OTHERS Exception', 2);
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
  -------------------------------------
  -- PL/SQL TBL lock_row for:olev_TBL --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('9000: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_olev_tbl.COUNT > 0) THEN
      i := p_olev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_olev_rec                      => p_olev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_olev_tbl.LAST);
        i := p_olev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9200: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9300: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9400: Exiting lock_row:OTHERS Exception', 2);
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
  ----------------------------------------
  -- update_row for:OKC_OPERATION_LINES --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ole_rec                      IN ole_rec_type,
    x_ole_rec                      OUT NOCOPY ole_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ole_rec                      ole_rec_type := p_ole_rec;
    l_def_ole_rec                  ole_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ole_rec	IN ole_rec_type,
      x_ole_rec	OUT NOCOPY ole_rec_type
    ) RETURN VARCHAR2 IS
      l_ole_rec                      ole_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('9500: Entered populate_new_record', 2);
    END IF;

      x_ole_rec := p_ole_rec;
      -- Get current database values
      l_ole_rec := get_rec(p_ole_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ole_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.id := l_ole_rec.id;
      END IF;
      IF (x_ole_rec.select_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ole_rec.select_yn := l_ole_rec.select_yn;
      END IF;
      IF (x_ole_rec.process_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_ole_rec.process_flag := l_ole_rec.process_flag;
      END IF;
      IF (x_ole_rec.active_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ole_rec.active_yn := l_ole_rec.active_yn;
      END IF;
      IF (x_ole_rec.oie_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.oie_id := l_ole_rec.oie_id;
      END IF;
      IF (x_ole_rec.parent_ole_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.parent_ole_id := l_ole_rec.parent_ole_id;
      END IF;
      IF (x_ole_rec.subject_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.subject_chr_id := l_ole_rec.subject_chr_id;
      END IF;
      IF (x_ole_rec.object_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.object_chr_id := l_ole_rec.object_chr_id;
      END IF;
      IF (x_ole_rec.subject_cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.subject_cle_id := l_ole_rec.subject_cle_id;
      END IF;
      IF (x_ole_rec.object_cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.object_cle_id := l_ole_rec.object_cle_id;
      END IF;
      IF (x_ole_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.object_version_number := l_ole_rec.object_version_number;
      END IF;
      IF (x_ole_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.created_by := l_ole_rec.created_by;
      END IF;
      IF (x_ole_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ole_rec.creation_date := l_ole_rec.creation_date;
      END IF;
      IF (x_ole_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.last_updated_by := l_ole_rec.last_updated_by;
      END IF;
      IF (x_ole_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ole_rec.last_update_date := l_ole_rec.last_update_date;
      END IF;
      IF (x_ole_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.last_update_login := l_ole_rec.last_update_login;
      END IF;
      IF (x_ole_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.request_id := l_ole_rec.request_id;
      END IF;
      IF (x_ole_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.program_application_id := l_ole_rec.program_application_id;
      END IF;
      IF (x_ole_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_ole_rec.program_id := l_ole_rec.program_id;
      END IF;
      IF (x_ole_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ole_rec.program_update_date := l_ole_rec.program_update_date;
      END IF;
      IF (x_ole_rec.message_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ole_rec.message_code := l_ole_rec.message_code;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('9600: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_LINES --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_ole_rec IN  ole_rec_type,
      x_ole_rec OUT NOCOPY ole_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_ole_rec := p_ole_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('9700: Entered update_row', 2);
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
      p_ole_rec,                         -- IN
      l_ole_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ole_rec, l_def_ole_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_OPERATION_LINES
    SET SELECT_YN = l_def_ole_rec.select_yn,
        PROCESS_FLAG = l_def_ole_rec.process_flag,
        ACTIVE_YN = l_def_ole_rec.active_yn,
        OIE_ID = l_def_ole_rec.oie_id,
        PARENT_OLE_ID = l_def_ole_rec.parent_ole_id,
        SUBJECT_CHR_ID = l_def_ole_rec.subject_chr_id,
        OBJECT_CHR_ID = l_def_ole_rec.object_chr_id,
        SUBJECT_CLE_ID = l_def_ole_rec.subject_cle_id,
        OBJECT_CLE_ID = l_def_ole_rec.object_cle_id,
        OBJECT_VERSION_NUMBER = l_def_ole_rec.object_version_number,
        CREATED_BY = l_def_ole_rec.created_by,
        CREATION_DATE = l_def_ole_rec.creation_date,
        LAST_UPDATED_BY = l_def_ole_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ole_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ole_rec.last_update_login,
        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_ole_rec.request_id),
        PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_ole_rec.program_application_id),
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_ole_rec.program_id),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_ole_rec.program_update_date,SYSDATE),
        MESSAGE_CODE = l_def_ole_rec.message_code
    WHERE ID = l_def_ole_rec.id;

    x_ole_rec := l_def_ole_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9800: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9900: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10000: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10100: Exiting update_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- update_row for:OKC_OPERATION_LINES_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type,
    x_olev_rec                      OUT NOCOPY olev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_olev_rec                      olev_rec_type := p_olev_rec;
    l_def_olev_rec                  olev_rec_type;
    l_ole_rec                      ole_rec_type;
    lx_ole_rec                     ole_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_olev_rec	IN olev_rec_type
    ) RETURN olev_rec_type IS
      l_olev_rec	olev_rec_type := p_olev_rec;
    BEGIN

      l_olev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_olev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_olev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_olev_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_olev_rec	IN olev_rec_type,
      x_olev_rec	OUT NOCOPY olev_rec_type
    ) RETURN VARCHAR2 IS
      l_olev_rec                      olev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('10300: Entered populate_new_record', 2);
    END IF;

      x_olev_rec := p_olev_rec;
      -- Get current database values
      l_olev_rec := get_rec(p_olev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_olev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.id := l_olev_rec.id;
      END IF;
      IF (x_olev_rec.select_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_olev_rec.select_yn := l_olev_rec.select_yn;
      END IF;
      IF (x_olev_rec.process_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_olev_rec.process_flag := l_olev_rec.process_flag;
      END IF;
      IF (x_olev_rec.active_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_olev_rec.active_yn := l_olev_rec.active_yn;
      END IF;
      IF (x_olev_rec.oie_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.oie_id := l_olev_rec.oie_id;
      END IF;
      IF (x_olev_rec.parent_ole_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.parent_ole_id := l_olev_rec.parent_ole_id;
      END IF;
      IF (x_olev_rec.subject_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.subject_chr_id := l_olev_rec.subject_chr_id;
      END IF;
      IF (x_olev_rec.object_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.object_chr_id := l_olev_rec.object_chr_id;
      END IF;
      IF (x_olev_rec.subject_cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.subject_cle_id := l_olev_rec.subject_cle_id;
      END IF;
      IF (x_olev_rec.object_cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.object_cle_id := l_olev_rec.object_cle_id;
      END IF;
      IF (x_olev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.object_version_number := l_olev_rec.object_version_number;
      END IF;
      IF (x_olev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.created_by := l_olev_rec.created_by;
      END IF;
      IF (x_olev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_olev_rec.creation_date := l_olev_rec.creation_date;
      END IF;
      IF (x_olev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.last_updated_by := l_olev_rec.last_updated_by;
      END IF;
      IF (x_olev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_olev_rec.last_update_date := l_olev_rec.last_update_date;
      END IF;
      IF (x_olev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.last_update_login := l_olev_rec.last_update_login;
      END IF;
      IF (x_olev_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.request_id := l_olev_rec.request_id;
      END IF;
      IF (x_olev_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.program_application_id := l_olev_rec.program_application_id;
      END IF;
      IF (x_olev_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_olev_rec.program_id := l_olev_rec.program_id;
      END IF;
      IF (x_olev_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_olev_rec.program_update_date := l_olev_rec.program_update_date;
      END IF;
      IF (x_olev_rec.message_code = OKC_API.G_MISS_CHAR)
      THEN
        x_olev_rec.message_code := l_olev_rec.message_code;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('10400: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_LINES_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_olev_rec IN  olev_rec_type,
      x_olev_rec OUT NOCOPY olev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_olev_rec := p_olev_rec;
      x_olev_rec.OBJECT_VERSION_NUMBER := NVL(x_olev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      x_olev_rec.SELECT_YN := upper(x_olev_rec.SELECT_YN);
      x_olev_rec.PROCESS_FLAG := upper(x_olev_rec.PROCESS_FLAG);
      x_olev_rec.ACTIVE_YN := upper(x_olev_rec.ACTIVE_YN);
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('10500: Entered update_row', 2);
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
      p_olev_rec,                         -- IN
      l_olev_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_olev_rec, l_def_olev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_olev_rec := fill_who_columns(l_def_olev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_olev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_olev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_olev_rec, l_ole_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ole_rec,
      lx_ole_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ole_rec, l_def_olev_rec);
    x_olev_rec := l_def_olev_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('10600: Leaving update_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10700: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10800: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10900: Exiting update_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- PL/SQL TBL update_row for:olev_TBL --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type,
    x_olev_tbl                      OUT NOCOPY olev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('11000: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_olev_tbl.COUNT > 0) THEN
      i := p_olev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_olev_rec                      => p_olev_tbl(i),
          x_olev_rec                      => x_olev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_olev_tbl.LAST);
        i := p_olev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11200: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('11300: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('11400: Exiting update_row:OTHERS Exception', 2);
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
  ----------------------------------------
  -- delete_row for:OKC_OPERATION_LINES --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ole_rec                      IN ole_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ole_rec                      ole_rec_type:= p_ole_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('11500: Entered delete_row', 2);
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
    DELETE FROM OKC_OPERATION_LINES
     WHERE ID = l_ole_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11600: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11700: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('11800: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('11900: Exiting delete_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- delete_row for:OKC_OPERATION_LINES_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_rec                      IN olev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_olev_rec                      olev_rec_type := p_olev_rec;
    l_ole_rec                      ole_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('12000: Entered delete_row', 2);
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
    migrate(l_olev_rec, l_ole_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ole_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('12100: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12200: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('12300: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('12400: Exiting delete_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- PL/SQL TBL delete_row for:olev_TBL --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_olev_tbl                      IN olev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OLE_PVT');
       okc_debug.log('12500: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_olev_tbl.COUNT > 0) THEN
      i := p_olev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_olev_rec                      => p_olev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_olev_tbl.LAST);
        i := p_olev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('12600: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12700: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('12800: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('12900: Exiting delete_row:OTHERS Exception', 2);
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

END OKC_OLE_PVT;

/
