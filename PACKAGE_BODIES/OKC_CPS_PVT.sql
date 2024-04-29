--------------------------------------------------------
--  DDL for Package Body OKC_CPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CPS_PVT" AS
/* $Header: OKCSCPSB.pls 120.0 2005/05/25 19:42:48 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/
  FUNCTION Validate_Attributes ( p_cpsv_rec IN  cpsv_rec_type)
		RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_MESSAGE';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'ERROR_CODE';
  G_VIEW			 CONSTANT	VARCHAR2(200) := 'OKC_K_PROCESSES_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_pdf_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_pdf_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_cpsv_rec      IN    cpsv_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_pdfv_csr Is
  		select 'x'
  		from OKC_PROCESS_DEFS_B
  		where ID = p_cpsv_rec.pdf_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_cpsv_rec.pdf_id = OKC_API.G_MISS_NUM or
  	   p_cpsv_rec.pdf_id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'pdf_id/Workflow Name');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- enforce foreign key
    Open l_pdfv_csr;
    Fetch l_pdfv_csr Into l_dummy_var;
    Close l_pdfv_csr;

    -- if l_dummy_var still set to default, data was not found
    If (l_dummy_var = '?') Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_no_parent_record,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'pdf_id',
					  p_token2		=> g_child_table_token,
					  p_token2_value	=> G_VIEW,
					  p_token3		=> g_parent_table_token,
					  p_token3_value	=> 'OKC_PROCESS_DEFS_V');
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
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_pdfv_csr%ISOPEN then
	      close l_pdfv_csr;
        end if;

  End validate_pdf_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_cpsv_rec      IN    cpsv_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKC_K_HEADERS_B
  		where ID = p_cpsv_rec.chr_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- check that data exists
    If (p_cpsv_rec.chr_id <> OKC_API.G_MISS_NUM and
  	   p_cpsv_rec.chr_id IS NOT NULL)
    Then
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
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_chrv_csr%ISOPEN then
	      close l_chrv_csr;
        end if;

  End validate_chr_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_user_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_user_id(x_return_status OUT NOCOPY   VARCHAR2,
                             p_cpsv_rec      IN    cpsv_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_usrv_csr Is
  		select 'x'
  		from FND_USER_VIEW
  		where USER_ID = p_cpsv_rec.user_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_cpsv_rec.user_id <> OKC_API.G_MISS_NUM and
  	   p_cpsv_rec.user_id IS NOT NULL)
    Then
      -- enforce foreign key
      Open l_usrv_csr;
      Fetch l_usrv_csr Into l_dummy_var;
      Close l_usrv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'user_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'FND_USER_VIEW');
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
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_usrv_csr%ISOPEN then
	      close l_usrv_csr;
        end if;

  End validate_user_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_crt_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_crt_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_cpsv_rec      IN    cpsv_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_cpsv_csr Is
  		select 'x'
  		from OKC_CHANGE_REQUESTS_B
  		where ID = p_cpsv_rec.crt_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_cpsv_rec.crt_id <> OKC_API.G_MISS_NUM and
  	   p_cpsv_rec.crt_id IS NOT NULL)
    Then
      -- enforce foreign key
      Open l_cpsv_csr;
      Fetch l_cpsv_csr Into l_dummy_var;
      Close l_cpsv_csr;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = '?') Then
  	    OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					    p_msg_name		=> g_no_parent_record,
					    p_token1		=> g_col_name_token,
					    p_token1_value	=> 'crt_id',
					    p_token2		=> g_child_table_token,
					    p_token2_value	=> G_VIEW,
					    p_token3		=> g_parent_table_token,
					    p_token3_value	=> 'OKC_CHANGE_REQUESTS_V');
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
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_cpsv_csr%ISOPEN then
	      close l_cpsv_csr;
        end if;

  End validate_crt_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_process_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_process_id(x_return_status OUT NOCOPY VARCHAR2,
                             	  p_cpsv_rec      IN cpsv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- call column length utility
    If (p_cpsv_rec.process_id is not null and
	   p_cpsv_rec.process_id <> OKC_API.G_MISS_CHAR)
    Then
	  If (length(p_cpsv_rec.process_id) > 240) Then
	      OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
						 p_msg_name      =>  G_LEN_CHK,
						 p_token1        =>  G_COL_NAME_TOKEN,
						 p_token1_value  =>  'Process Id',
						 p_token2        =>  'COL_LEN',
						 p_token2_value  =>  '240');

	      x_return_status := OKC_API.G_RET_STS_ERROR;
	  End If;

       -- if length is not within allowed limits, set error flag
       If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
          raise G_EXCEPTION_HALT_VALIDATION;
       End If;
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
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_process_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_in_process_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_in_process_yn(x_return_status OUT NOCOPY   VARCHAR2,
                            	     p_cpsv_rec IN cpsv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_cpsv_rec.in_process_yn <> OKC_API.G_MISS_CHAR and
  	   p_cpsv_rec.in_process_yn IS NOT NULL)
    Then
       If (upper(p_cpsv_rec.in_process_yn) NOT IN ('Y','N','E')) Then
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
					     p_msg_name	=> g_invalid_value,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'in_process_yn');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

	     -- halt validation
	     raise G_EXCEPTION_HALT_VALIDATION;
	   end if;
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
  End validate_in_process_yn;

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
  -- FUNCTION get_rec for: OKC_K_PROCESSES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cps_rec                      IN cps_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cps_rec_type IS
    CURSOR cps_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PDF_ID,
            CHR_ID,
            USER_ID,
            CRT_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PROCESS_ID,
            IN_PROCESS_YN,
            LAST_UPDATE_LOGIN,
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
            ATTRIBUTE15
      FROM Okc_K_Processes
     WHERE okc_k_processes.id   = p_id;
    l_cps_pk                       cps_pk_csr%ROWTYPE;
    l_cps_rec                      cps_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cps_pk_csr (p_cps_rec.id);
    FETCH cps_pk_csr INTO
              l_cps_rec.ID,
              l_cps_rec.PDF_ID,
              l_cps_rec.CHR_ID,
              l_cps_rec.USER_ID,
              l_cps_rec.CRT_ID,
              l_cps_rec.OBJECT_VERSION_NUMBER,
              l_cps_rec.CREATED_BY,
              l_cps_rec.CREATION_DATE,
              l_cps_rec.LAST_UPDATED_BY,
              l_cps_rec.LAST_UPDATE_DATE,
              l_cps_rec.PROCESS_ID,
              l_cps_rec.IN_PROCESS_YN,
              l_cps_rec.LAST_UPDATE_LOGIN,
              l_cps_rec.ATTRIBUTE_CATEGORY,
              l_cps_rec.ATTRIBUTE1,
              l_cps_rec.ATTRIBUTE2,
              l_cps_rec.ATTRIBUTE3,
              l_cps_rec.ATTRIBUTE4,
              l_cps_rec.ATTRIBUTE5,
              l_cps_rec.ATTRIBUTE6,
              l_cps_rec.ATTRIBUTE7,
              l_cps_rec.ATTRIBUTE8,
              l_cps_rec.ATTRIBUTE9,
              l_cps_rec.ATTRIBUTE10,
              l_cps_rec.ATTRIBUTE11,
              l_cps_rec.ATTRIBUTE12,
              l_cps_rec.ATTRIBUTE13,
              l_cps_rec.ATTRIBUTE14,
              l_cps_rec.ATTRIBUTE15;
    x_no_data_found := cps_pk_csr%NOTFOUND;
    CLOSE cps_pk_csr;
    RETURN(l_cps_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cps_rec                      IN cps_rec_type
  ) RETURN cps_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cps_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_PROCESSES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cpsv_rec                     IN cpsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cpsv_rec_type IS
    CURSOR okc_cpsv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PDF_ID,
            CHR_ID,
            USER_ID,
            CRT_ID,
            PROCESS_ID,
            IN_PROCESS_YN,
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
      FROM Okc_K_Processes_V
     WHERE okc_k_processes_v.id = p_id;
    l_okc_cpsv_pk                  okc_cpsv_pk_csr%ROWTYPE;
    l_cpsv_rec                     cpsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cpsv_pk_csr (p_cpsv_rec.id);
    FETCH okc_cpsv_pk_csr INTO
              l_cpsv_rec.ID,
              l_cpsv_rec.OBJECT_VERSION_NUMBER,
              l_cpsv_rec.PDF_ID,
              l_cpsv_rec.CHR_ID,
              l_cpsv_rec.USER_ID,
              l_cpsv_rec.CRT_ID,
              l_cpsv_rec.PROCESS_ID,
              l_cpsv_rec.IN_PROCESS_YN,
              l_cpsv_rec.ATTRIBUTE_CATEGORY,
              l_cpsv_rec.ATTRIBUTE1,
              l_cpsv_rec.ATTRIBUTE2,
              l_cpsv_rec.ATTRIBUTE3,
              l_cpsv_rec.ATTRIBUTE4,
              l_cpsv_rec.ATTRIBUTE5,
              l_cpsv_rec.ATTRIBUTE6,
              l_cpsv_rec.ATTRIBUTE7,
              l_cpsv_rec.ATTRIBUTE8,
              l_cpsv_rec.ATTRIBUTE9,
              l_cpsv_rec.ATTRIBUTE10,
              l_cpsv_rec.ATTRIBUTE11,
              l_cpsv_rec.ATTRIBUTE12,
              l_cpsv_rec.ATTRIBUTE13,
              l_cpsv_rec.ATTRIBUTE14,
              l_cpsv_rec.ATTRIBUTE15,
              l_cpsv_rec.CREATED_BY,
              l_cpsv_rec.CREATION_DATE,
              l_cpsv_rec.LAST_UPDATED_BY,
              l_cpsv_rec.LAST_UPDATE_DATE,
              l_cpsv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cpsv_pk_csr%NOTFOUND;
    CLOSE okc_cpsv_pk_csr;
    RETURN(l_cpsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cpsv_rec                     IN cpsv_rec_type
  ) RETURN cpsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cpsv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_PROCESSES_V --
  -------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cpsv_rec	IN cpsv_rec_type
  ) RETURN cpsv_rec_type IS
    l_cpsv_rec	cpsv_rec_type := p_cpsv_rec;
  BEGIN
    IF (l_cpsv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.object_version_number := NULL;
    END IF;
    IF (l_cpsv_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.pdf_id := NULL;
    END IF;
    IF (l_cpsv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.chr_id := NULL;
    END IF;
    IF (l_cpsv_rec.user_id = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.user_id := NULL;
    END IF;
    IF (l_cpsv_rec.crt_id = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.crt_id := NULL;
    END IF;
    IF (l_cpsv_rec.process_id = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.process_id := NULL;
    END IF;
    IF (l_cpsv_rec.in_process_yn = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.in_process_yn := NULL;
    END IF;
    IF (l_cpsv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute_category := NULL;
    END IF;
    IF (l_cpsv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute1 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute2 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute3 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute4 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute5 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute6 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute7 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute8 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute9 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute10 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute11 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute12 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute13 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute14 := NULL;
    END IF;
    IF (l_cpsv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_cpsv_rec.attribute15 := NULL;
    END IF;
    IF (l_cpsv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.created_by := NULL;
    END IF;
    IF (l_cpsv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cpsv_rec.creation_date := NULL;
    END IF;
    IF (l_cpsv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cpsv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cpsv_rec.last_update_date := NULL;
    END IF;
    IF (l_cpsv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cpsv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cpsv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKC_K_PROCESSES_V --
  -----------------------------------------------
  FUNCTION Validate_Attributes (
    p_cpsv_rec IN  cpsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /************************ HAND-CODED *********************************/
    validate_pdf_id
				(x_return_status 	=> l_return_status,
				 p_cpsv_rec 		=> p_cpsv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
--dbms_output.put_line('2 Return Status : ' || l_return_status);

    validate_chr_id
				(x_return_status 	=> l_return_status,
				 p_cpsv_rec 		=> p_cpsv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
--dbms_output.put_line('3 Return Status : ' || l_return_status);

    validate_user_id
				(x_return_status 	=> l_return_status,
				 p_cpsv_rec 		=> p_cpsv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
--dbms_output.put_line('3.a Return Status : ' || l_return_status);

    validate_crt_id (x_return_status 	=> l_return_status,
				 p_cpsv_rec 		=> p_cpsv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
--dbms_output.put_line('3.b Return Status : ' || l_return_status);

    validate_process_id
				(x_return_status 	=> l_return_status,
				 p_cpsv_rec 		=> p_cpsv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
--dbms_output.put_line('3.d Return Status : ' || l_return_status);

    validate_in_process_yn
				(x_return_status 	=> l_return_status,
				 p_cpsv_rec 		=> p_cpsv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;
--dbms_output.put_line('3.e Return Status : ' || l_return_status);

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
  -- Validate_Record for:OKC_K_PROCESSES_V --
  -------------------------------------------
  FUNCTION Validate_Record (
    p_cpsv_rec IN cpsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
 -- l_unq_tbl   OKC_UTIL.unq_tbl_type;

    Cursor l_cps_csr Is
		select count(1)
		from okc_k_processes cps, okc_process_defs_b pdfb
		where cps.pdf_id = pdfb.id
		and cps.chr_id = p_cpsv_rec.chr_id
		and pdfb.usage='APPROVE' and pdfb.pdf_type='WPS'
		and cps.id <> p_cpsv_rec.id;
    l_count	 NUMBER;

    -- ------------------------------------------------------
    -- For the combination chr_id not null and crt_id is null
    -- The cursor includes id check filter to handle updates
    -- for case K2 should not overwrite already existing K1
    -- ------------------------------------------------------
    CURSOR cur_pdf_1 IS
		SELECT 'x'
		FROM   okc_k_processes cps
		WHERE  chr_id = p_cpsv_rec.CHR_ID
		AND    crt_id IS NULL
		AND    pdf_id = p_cpsv_rec.PDF_ID
		AND    id <> NVL(p_cpsv_rec.ID,-9999);

    -- ------------------------------------------------------
    -- For the combination chr_id null and crt_id is not null
    -- The cursor includes id check filter to handle updates
    -- for case K2 should not overwrite already existing K1
    -- ------------------------------------------------------
    CURSOR cur_pdf_2 IS
		SELECT 'x'
		FROM   okc_k_processes cps
		WHERE  chr_id IS NULL
		AND    crt_id = p_cpsv_rec.CRT_ID
		AND    pdf_id = p_cpsv_rec.PDF_ID
		AND    id <> NVL(p_cpsv_rec.ID,-9999);

    l_row_found   BOOLEAN := False;
    l_dummy       VARCHAR2(1);
  BEGIN
    -- ------------------------------------------------------
    -- Bug# 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call earlier was not using
    -- the bind variables and parses everytime, replaced with
    -- the explicit cursors above, for identical function.
    -- ------------------------------------------------------
       IF (     p_cpsv_rec.CHR_ID IS NOT NULL
		  AND p_cpsv_rec.CHR_ID <> OKC_API.G_MISS_NUM )
       THEN
		  OPEN  cur_pdf_1;
		  FETCH cur_pdf_1 INTO l_dummy;
		  l_row_found := cur_pdf_1%FOUND;
		  CLOSE cur_pdf_1;
       ELSIF (     p_cpsv_rec.CRT_ID IS NOT NULL
		     AND p_cpsv_rec.CRT_ID <> OKC_API.G_MISS_NUM )
       THEN
		  OPEN  cur_pdf_2;
		  FETCH cur_pdf_2 INTO l_dummy;
		  l_row_found := cur_pdf_2%FOUND;
		  CLOSE cur_pdf_2;
       END IF;

       IF (l_row_found)
	  THEN
		 -- Display the newly defined error message
	      OKC_API.set_message(G_APP_NAME,
			                'OKC_DUPLICATE_PROCESS');
               l_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;

       -- if contract number not unique, raise exception
       If l_return_status <> OKC_API.G_RET_STS_SUCCESS
	  Then
  	     raise G_EXCEPTION_HALT_VALIDATION;
       End If;


      -- Do not allow mulitple APPROVAL processes for one contract
	 If (p_cpsv_rec.chr_id is not null) Then
         open l_cps_csr;
	    fetch l_cps_csr into l_count;
	    close l_cps_csr;

	    If (l_count > 0) Then
  	        OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
					        p_msg_name	=> 'OKC_MULTIPLE_PROCESSES');

	        -- notify caller of an error
             l_return_status := OKC_API.G_RET_STS_ERROR;
             RAISE OKC_API.G_EXCEPTION_ERROR;
	    End If;
	 End If;

    RETURN (l_return_status);
  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cpsv_rec_type,
    p_to	IN OUT NOCOPY cps_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.chr_id := p_from.chr_id;
    p_to.user_id := p_from.user_id;
    p_to.crt_id := p_from.crt_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.process_id := p_from.process_id;
    p_to.in_process_yn := p_from.in_process_yn;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN cps_rec_type,
    p_to	IN OUT NOCOPY cpsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.pdf_id := p_from.pdf_id;
    p_to.chr_id := p_from.chr_id;
    p_to.user_id := p_from.user_id;
    p_to.crt_id := p_from.crt_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.process_id := p_from.process_id;
    p_to.in_process_yn := p_from.in_process_yn;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- validate_row for:OKC_K_PROCESSES_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpsv_rec                     cpsv_rec_type := p_cpsv_rec;
    l_cps_rec                      cps_rec_type;
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
    l_return_status := Validate_Attributes(l_cpsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cpsv_rec);
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
  -- PL/SQL TBL validate_row for:CPSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cpsv_tbl.COUNT > 0) THEN
      i := p_cpsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cpsv_rec                     => p_cpsv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cpsv_tbl.LAST);
        i := p_cpsv_tbl.NEXT(i);
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
  -- insert_row for:OKC_K_PROCESSES --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cps_rec                      IN cps_rec_type,
    x_cps_rec                      OUT NOCOPY cps_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cps_rec                      cps_rec_type := p_cps_rec;
    l_def_cps_rec                  cps_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_PROCESSES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cps_rec IN  cps_rec_type,
      x_cps_rec OUT NOCOPY cps_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cps_rec := p_cps_rec;
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
      p_cps_rec,                         -- IN
      l_cps_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_PROCESSES(
        id,
        pdf_id,
        chr_id,
        user_id,
        crt_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        process_id,
        in_process_yn,
        last_update_login,
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
        attribute15)
      VALUES (
        l_cps_rec.id,
        l_cps_rec.pdf_id,
        l_cps_rec.chr_id,
        l_cps_rec.user_id,
        l_cps_rec.crt_id,
        l_cps_rec.object_version_number,
        l_cps_rec.created_by,
        l_cps_rec.creation_date,
        l_cps_rec.last_updated_by,
        l_cps_rec.last_update_date,
        l_cps_rec.process_id,
        l_cps_rec.in_process_yn,
        l_cps_rec.last_update_login,
        l_cps_rec.attribute_category,
        l_cps_rec.attribute1,
        l_cps_rec.attribute2,
        l_cps_rec.attribute3,
        l_cps_rec.attribute4,
        l_cps_rec.attribute5,
        l_cps_rec.attribute6,
        l_cps_rec.attribute7,
        l_cps_rec.attribute8,
        l_cps_rec.attribute9,
        l_cps_rec.attribute10,
        l_cps_rec.attribute11,
        l_cps_rec.attribute12,
        l_cps_rec.attribute13,
        l_cps_rec.attribute14,
        l_cps_rec.attribute15);
    -- Set OUT values
    x_cps_rec := l_cps_rec;
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
  -- insert_row for:OKC_K_PROCESSES_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY cpsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpsv_rec                     cpsv_rec_type;
    l_def_cpsv_rec                 cpsv_rec_type;
    l_cps_rec                      cps_rec_type;
    lx_cps_rec                     cps_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cpsv_rec	IN cpsv_rec_type
    ) RETURN cpsv_rec_type IS
      l_cpsv_rec	cpsv_rec_type := p_cpsv_rec;
    BEGIN
      l_cpsv_rec.CREATION_DATE := SYSDATE;
      l_cpsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cpsv_rec.LAST_UPDATE_DATE := l_cpsv_rec.CREATION_DATE;
      l_cpsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cpsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cpsv_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKC_K_PROCESSES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cpsv_rec IN  cpsv_rec_type,
      x_cpsv_rec OUT NOCOPY cpsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cpsv_rec := p_cpsv_rec;
      x_cpsv_rec.OBJECT_VERSION_NUMBER := 1;
	 /************************ HAND-CODED *********************************/
	 x_cpsv_rec.IN_PROCESS_YN := UPPER(x_cpsv_rec.IN_PROCESS_YN);
	 /*********************** END HAND-CODED ******************************/
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

    l_cpsv_rec := null_out_defaults(p_cpsv_rec);
    -- Set primary key value
    l_cpsv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cpsv_rec,                        -- IN
      l_def_cpsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cpsv_rec := fill_who_columns(l_def_cpsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cpsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cpsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cpsv_rec, l_cps_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cps_rec,
      lx_cps_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cps_rec, l_def_cpsv_rec);
    -- Set OUT values
    x_cpsv_rec := l_def_cpsv_rec;
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
  -- PL/SQL TBL insert_row for:CPSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY cpsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cpsv_tbl.COUNT > 0) THEN
      i := p_cpsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cpsv_rec                     => p_cpsv_tbl(i),
          x_cpsv_rec                     => x_cpsv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cpsv_tbl.LAST);
        i := p_cpsv_tbl.NEXT(i);
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
  -- lock_row for:OKC_K_PROCESSES --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cps_rec                      IN cps_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cps_rec IN cps_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_PROCESSES
     WHERE ID = p_cps_rec.id
       AND OBJECT_VERSION_NUMBER in (p_cps_rec.object_version_number,
							  OKC_API.G_MISS_NUM)
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cps_rec IN cps_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_PROCESSES
    WHERE ID = p_cps_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_PROCESSES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_PROCESSES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cps_rec);
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
      OPEN lchk_csr(p_cps_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cps_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cps_rec.object_version_number THEN
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
  -- lock_row for:OKC_K_PROCESSES_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cps_rec                      cps_rec_type;
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
    migrate(p_cpsv_rec, l_cps_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cps_rec
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
  -- PL/SQL TBL lock_row for:CPSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cpsv_tbl.COUNT > 0) THEN
      i := p_cpsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cpsv_rec                     => p_cpsv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cpsv_tbl.LAST);
        i := p_cpsv_tbl.NEXT(i);
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
  -- update_row for:OKC_K_PROCESSES --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cps_rec                      IN cps_rec_type,
    x_cps_rec                      OUT NOCOPY cps_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cps_rec                      cps_rec_type := p_cps_rec;
    l_def_cps_rec                  cps_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cps_rec	IN cps_rec_type,
      x_cps_rec	OUT NOCOPY cps_rec_type
    ) RETURN VARCHAR2 IS
      l_cps_rec                      cps_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cps_rec := p_cps_rec;
      -- Get current database values
      l_cps_rec := get_rec(p_cps_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cps_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.id := l_cps_rec.id;
      END IF;
      IF (x_cps_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.pdf_id := l_cps_rec.pdf_id;
      END IF;
      IF (x_cps_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.chr_id := l_cps_rec.chr_id;
      END IF;
      IF (x_cps_rec.user_id = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.user_id := l_cps_rec.user_id;
      END IF;
      IF (x_cps_rec.crt_id = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.crt_id := l_cps_rec.crt_id;
      END IF;
      IF (x_cps_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.object_version_number := l_cps_rec.object_version_number;
      END IF;
      IF (x_cps_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.created_by := l_cps_rec.created_by;
      END IF;
      IF (x_cps_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cps_rec.creation_date := l_cps_rec.creation_date;
      END IF;
      IF (x_cps_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.last_updated_by := l_cps_rec.last_updated_by;
      END IF;
      IF (x_cps_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cps_rec.last_update_date := l_cps_rec.last_update_date;
      END IF;
      IF (x_cps_rec.process_id = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.process_id := l_cps_rec.process_id;
      END IF;
      IF (x_cps_rec.in_process_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.in_process_yn := l_cps_rec.in_process_yn;
      END IF;
      IF (x_cps_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cps_rec.last_update_login := l_cps_rec.last_update_login;
      END IF;
      IF (x_cps_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute_category := l_cps_rec.attribute_category;
      END IF;
      IF (x_cps_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute1 := l_cps_rec.attribute1;
      END IF;
      IF (x_cps_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute2 := l_cps_rec.attribute2;
      END IF;
      IF (x_cps_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute3 := l_cps_rec.attribute3;
      END IF;
      IF (x_cps_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute4 := l_cps_rec.attribute4;
      END IF;
      IF (x_cps_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute5 := l_cps_rec.attribute5;
      END IF;
      IF (x_cps_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute6 := l_cps_rec.attribute6;
      END IF;
      IF (x_cps_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute7 := l_cps_rec.attribute7;
      END IF;
      IF (x_cps_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute8 := l_cps_rec.attribute8;
      END IF;
      IF (x_cps_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute9 := l_cps_rec.attribute9;
      END IF;
      IF (x_cps_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute10 := l_cps_rec.attribute10;
      END IF;
      IF (x_cps_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute11 := l_cps_rec.attribute11;
      END IF;
      IF (x_cps_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute12 := l_cps_rec.attribute12;
      END IF;
      IF (x_cps_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute13 := l_cps_rec.attribute13;
      END IF;
      IF (x_cps_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute14 := l_cps_rec.attribute14;
      END IF;
      IF (x_cps_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cps_rec.attribute15 := l_cps_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_K_PROCESSES --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_cps_rec IN  cps_rec_type,
      x_cps_rec OUT NOCOPY cps_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cps_rec := p_cps_rec;
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
      p_cps_rec,                         -- IN
      l_cps_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cps_rec, l_def_cps_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_PROCESSES
    SET PDF_ID = l_def_cps_rec.pdf_id,
        CHR_ID = l_def_cps_rec.chr_id,
        USER_ID = l_def_cps_rec.user_id,
        CRT_ID = l_def_cps_rec.crt_id,
        OBJECT_VERSION_NUMBER = l_def_cps_rec.object_version_number,
        CREATED_BY = l_def_cps_rec.created_by,
        CREATION_DATE = l_def_cps_rec.creation_date,
        LAST_UPDATED_BY = l_def_cps_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cps_rec.last_update_date,
        PROCESS_ID = l_def_cps_rec.process_id,
        IN_PROCESS_YN = l_def_cps_rec.in_process_yn,
        LAST_UPDATE_LOGIN = l_def_cps_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_cps_rec.attribute_category,
        ATTRIBUTE1 = l_def_cps_rec.attribute1,
        ATTRIBUTE2 = l_def_cps_rec.attribute2,
        ATTRIBUTE3 = l_def_cps_rec.attribute3,
        ATTRIBUTE4 = l_def_cps_rec.attribute4,
        ATTRIBUTE5 = l_def_cps_rec.attribute5,
        ATTRIBUTE6 = l_def_cps_rec.attribute6,
        ATTRIBUTE7 = l_def_cps_rec.attribute7,
        ATTRIBUTE8 = l_def_cps_rec.attribute8,
        ATTRIBUTE9 = l_def_cps_rec.attribute9,
        ATTRIBUTE10 = l_def_cps_rec.attribute10,
        ATTRIBUTE11 = l_def_cps_rec.attribute11,
        ATTRIBUTE12 = l_def_cps_rec.attribute12,
        ATTRIBUTE13 = l_def_cps_rec.attribute13,
        ATTRIBUTE14 = l_def_cps_rec.attribute14,
        ATTRIBUTE15 = l_def_cps_rec.attribute15
    WHERE ID = l_def_cps_rec.id;

    x_cps_rec := l_def_cps_rec;
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
  -- update_row for:OKC_K_PROCESSES_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type,
    x_cpsv_rec                     OUT NOCOPY cpsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpsv_rec                     cpsv_rec_type := p_cpsv_rec;
    l_def_cpsv_rec                 cpsv_rec_type;
    l_cps_rec                      cps_rec_type;
    lx_cps_rec                     cps_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cpsv_rec	IN cpsv_rec_type
    ) RETURN cpsv_rec_type IS
      l_cpsv_rec	cpsv_rec_type := p_cpsv_rec;
    BEGIN
      l_cpsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cpsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cpsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cpsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cpsv_rec	IN cpsv_rec_type,
      x_cpsv_rec	OUT NOCOPY cpsv_rec_type
    ) RETURN VARCHAR2 IS
      l_cpsv_rec                     cpsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cpsv_rec := p_cpsv_rec;
      -- Get current database values
      l_cpsv_rec := get_rec(p_cpsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cpsv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.id := l_cpsv_rec.id;
      END IF;
      IF (x_cpsv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.object_version_number := l_cpsv_rec.object_version_number;
      END IF;
      IF (x_cpsv_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.pdf_id := l_cpsv_rec.pdf_id;
      END IF;
      IF (x_cpsv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.chr_id := l_cpsv_rec.chr_id;
      END IF;
      IF (x_cpsv_rec.user_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.user_id := l_cpsv_rec.user_id;
      END IF;
      IF (x_cpsv_rec.crt_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.crt_id := l_cpsv_rec.crt_id;
      END IF;
      IF (x_cpsv_rec.process_id = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.process_id := l_cpsv_rec.process_id;
      END IF;
      IF (x_cpsv_rec.in_process_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.in_process_yn := l_cpsv_rec.in_process_yn;
      END IF;
      IF (x_cpsv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute_category := l_cpsv_rec.attribute_category;
      END IF;
      IF (x_cpsv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute1 := l_cpsv_rec.attribute1;
      END IF;
      IF (x_cpsv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute2 := l_cpsv_rec.attribute2;
      END IF;
      IF (x_cpsv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute3 := l_cpsv_rec.attribute3;
      END IF;
      IF (x_cpsv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute4 := l_cpsv_rec.attribute4;
      END IF;
      IF (x_cpsv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute5 := l_cpsv_rec.attribute5;
      END IF;
      IF (x_cpsv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute6 := l_cpsv_rec.attribute6;
      END IF;
      IF (x_cpsv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute7 := l_cpsv_rec.attribute7;
      END IF;
      IF (x_cpsv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute8 := l_cpsv_rec.attribute8;
      END IF;
      IF (x_cpsv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute9 := l_cpsv_rec.attribute9;
      END IF;
      IF (x_cpsv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute10 := l_cpsv_rec.attribute10;
      END IF;
      IF (x_cpsv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute11 := l_cpsv_rec.attribute11;
      END IF;
      IF (x_cpsv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute12 := l_cpsv_rec.attribute12;
      END IF;
      IF (x_cpsv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute13 := l_cpsv_rec.attribute13;
      END IF;
      IF (x_cpsv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute14 := l_cpsv_rec.attribute14;
      END IF;
      IF (x_cpsv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_cpsv_rec.attribute15 := l_cpsv_rec.attribute15;
      END IF;
      IF (x_cpsv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.created_by := l_cpsv_rec.created_by;
      END IF;
      IF (x_cpsv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cpsv_rec.creation_date := l_cpsv_rec.creation_date;
      END IF;
      IF (x_cpsv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.last_updated_by := l_cpsv_rec.last_updated_by;
      END IF;
      IF (x_cpsv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cpsv_rec.last_update_date := l_cpsv_rec.last_update_date;
      END IF;
      IF (x_cpsv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cpsv_rec.last_update_login := l_cpsv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_K_PROCESSES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_cpsv_rec IN  cpsv_rec_type,
      x_cpsv_rec OUT NOCOPY cpsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cpsv_rec := p_cpsv_rec;
      x_cpsv_rec.OBJECT_VERSION_NUMBER := NVL(x_cpsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
	 /************************ HAND-CODED *********************************/
	 x_cpsv_rec.IN_PROCESS_YN := UPPER(x_cpsv_rec.IN_PROCESS_YN);
	 /********************* END HAND-CODED ********************************/
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
      p_cpsv_rec,                        -- IN
      l_cpsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cpsv_rec, l_def_cpsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cpsv_rec := fill_who_columns(l_def_cpsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cpsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cpsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cpsv_rec, l_cps_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cps_rec,
      lx_cps_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cps_rec, l_def_cpsv_rec);
    x_cpsv_rec := l_def_cpsv_rec;
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
  -- PL/SQL TBL update_row for:CPSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type,
    x_cpsv_tbl                     OUT NOCOPY cpsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cpsv_tbl.COUNT > 0) THEN
      i := p_cpsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cpsv_rec                     => p_cpsv_tbl(i),
          x_cpsv_rec                     => x_cpsv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cpsv_tbl.LAST);
        i := p_cpsv_tbl.NEXT(i);
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
  -- delete_row for:OKC_K_PROCESSES --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cps_rec                      IN cps_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cps_rec                      cps_rec_type:= p_cps_rec;
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
    DELETE FROM OKC_K_PROCESSES
     WHERE ID = l_cps_rec.id;

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
  -- delete_row for:OKC_K_PROCESSES_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_rec                     IN cpsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpsv_rec                     cpsv_rec_type := p_cpsv_rec;
    l_cps_rec                      cps_rec_type;
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
    migrate(l_cpsv_rec, l_cps_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cps_rec
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
  -- PL/SQL TBL delete_row for:CPSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpsv_tbl                     IN cpsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cpsv_tbl.COUNT > 0) THEN
      i := p_cpsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cpsv_rec                     => p_cpsv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cpsv_tbl.LAST);
        i := p_cpsv_tbl.NEXT(i);
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
-- Procedure for mass insert in OKC_K_PROCESSES table
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_cpsv_tbl cpsv_tbl_type) IS
  l_tabsize NUMBER := p_cpsv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_pdf_id                        OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_user_id                       OKC_DATATYPES.NumberTabTyp;
  in_crt_id                        OKC_DATATYPES.NumberTabTyp;
  in_process_id                    OKC_DATATYPES.Var240TabTyp;
  in_in_process_yn                 OKC_DATATYPES.Var3TabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  i                                NUMBER := p_cpsv_tbl.FIRST;
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

  WHILE i IS NOT NULL
  LOOP
    j                               := j + 1;

    in_id                       (j) := p_cpsv_tbl(i).id;
    in_object_version_number    (j) := p_cpsv_tbl(i).object_version_number;
    in_pdf_id                   (j) := p_cpsv_tbl(i).pdf_id;
    in_chr_id                   (j) := p_cpsv_tbl(i).chr_id;
    in_user_id                  (j) := p_cpsv_tbl(i).user_id;
    in_crt_id                   (j) := p_cpsv_tbl(i).crt_id;
    in_process_id               (j) := p_cpsv_tbl(i).process_id;
    in_in_process_yn            (j) := p_cpsv_tbl(i).in_process_yn;
    in_attribute_category       (j) := p_cpsv_tbl(i).attribute_category;
    in_attribute1               (j) := p_cpsv_tbl(i).attribute1;
    in_attribute2               (j) := p_cpsv_tbl(i).attribute2;
    in_attribute3               (j) := p_cpsv_tbl(i).attribute3;
    in_attribute4               (j) := p_cpsv_tbl(i).attribute4;
    in_attribute5               (j) := p_cpsv_tbl(i).attribute5;
    in_attribute6               (j) := p_cpsv_tbl(i).attribute6;
    in_attribute7               (j) := p_cpsv_tbl(i).attribute7;
    in_attribute8               (j) := p_cpsv_tbl(i).attribute8;
    in_attribute9               (j) := p_cpsv_tbl(i).attribute9;
    in_attribute10              (j) := p_cpsv_tbl(i).attribute10;
    in_attribute11              (j) := p_cpsv_tbl(i).attribute11;
    in_attribute12              (j) := p_cpsv_tbl(i).attribute12;
    in_attribute13              (j) := p_cpsv_tbl(i).attribute13;
    in_attribute14              (j) := p_cpsv_tbl(i).attribute14;
    in_attribute15              (j) := p_cpsv_tbl(i).attribute15;
    in_created_by               (j) := p_cpsv_tbl(i).created_by;
    in_creation_date            (j) := p_cpsv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_cpsv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_cpsv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_cpsv_tbl(i).last_update_login;

    i                               := p_cpsv_tbl.NEXT(i);

  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_K_PROCESSES
      (
        id,
        pdf_id,
        chr_id,
        user_id,
        crt_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        process_id,
        in_process_yn,
        last_update_login,
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
        attribute15
     )
     VALUES (
        in_id(i),
        in_pdf_id(i),
        in_chr_id(i),
        in_user_id(i),
        in_crt_id(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_process_id(i),
        in_in_process_yn(i),
        in_last_update_login(i),
        in_attribute_category(i),
        in_attribute1(i),
        in_attribute2(i),
        in_attribute3(i),
        in_attribute4(i),
        in_attribute5(i),
        in_attribute6(i),
        in_attribute7(i),
        in_attribute8(i),
        in_attribute9(i),
        in_attribute10(i),
        in_attribute11(i),
        in_attribute12(i),
        in_attribute13(i),
        in_attribute14(i),
        in_attribute15(i)
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
INSERT INTO okc_k_processes_h
  (
      major_version,
      id,
      pdf_id,
      chr_id,
      user_id,
      crt_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      process_id,
      in_process_yn,
      last_update_login,
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
      attribute15
)
  SELECT
      p_major_version,
      id,
      pdf_id,
      chr_id,
      user_id,
      crt_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      process_id,
      in_process_yn,
      last_update_login,
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
      attribute15
  FROM okc_k_processes
 WHERE chr_id = p_chr_id;

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
INSERT INTO okc_k_processes
  (
      id,
      pdf_id,
      chr_id,
      user_id,
      crt_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      process_id,
      in_process_yn,
      last_update_login,
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
      attribute15
)
  SELECT
      id,
      pdf_id,
      chr_id,
      user_id,
      crt_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      process_id,
      in_process_yn,
      last_update_login,
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
      attribute15
  FROM okc_k_processes_h
 WHERE chr_id = p_chr_id
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


END OKC_CPS_PVT;

/
