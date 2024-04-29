--------------------------------------------------------
--  DDL for Package Body OKC_LSQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_LSQ_PVT" AS
/* $Header: OKCSLSQB.pls 120.0 2005/05/25 23:05:07 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/
  -- Start of comments
  --
  -- Procedure Name  : validate_line_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_line_code(x_return_status OUT NOCOPY   VARCHAR2,
                               p_lsqv_rec      IN    lsqv_rec_type) is

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that line_code has some valid value
    If (p_lsqv_rec.line_code = OKC_API.G_MISS_CHAR or
  	   p_lsqv_rec.line_code IS NULL) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'line_code');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;
    -- Foreign Key check done in Validate_Record
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

  End validate_line_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_doc_sequence_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_doc_sequence_id(x_return_status OUT NOCOPY   VARCHAR2,
                                     p_lsqv_rec      IN    lsqv_rec_type) is

    /* cursor c (p_line_code okc_k_seq_lines.line_code%TYPE) is
    select 'x'
      from okc_k_seq_header
     where line_code = p_line_code;
      This cursor will be replaced by the fnd_document */
    l_dummy Varchar2(1);
    l_row_notfound Boolean := False;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that doc_sequence_id has some valid value
    If (p_lsqv_rec.doc_sequence_id = OKC_API.G_MISS_NUM or
  	   p_lsqv_rec.doc_sequence_id IS NULL) Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'doc_sequence_id');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    /* Open c(p_lsqv_rec.line_code);
    Fetch c Into l_dummy;
    l_row_notfound := c%NotFound;
    Close c;
    If l_row_notfound Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_invalid_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'doc_sequence_id');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If; */

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

  End validate_doc_sequence_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_cls_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_cls_code(x_return_status OUT NOCOPY   VARCHAR2,
                               p_lsqv_rec      IN    lsqv_rec_type) is

    -- Cursor to make sure it is a valid class
    cursor c (p_cls_code okc_k_seq_lines.cls_code%TYPE) is
    select 'x'
      from okc_classes_b
     where code = p_cls_code;

    l_dummy Varchar2(1);
    l_row_notfound Boolean := False;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- If no class has been chosen, return immediately
    If (p_lsqv_rec.cls_code = OKC_API.G_MISS_CHAR or
  	   p_lsqv_rec.cls_code IS NULL) Then
      Return;
    End If;

    -- Make sure it is a valid class
    Open c(p_lsqv_rec.cls_code);
    Fetch c Into l_dummy;
    l_row_notfound := c%NotFound;
    Close c;
    If l_row_notfound Then
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_invalid_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'cls_code');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_cls_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_scs_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_scs_code(x_return_status OUT NOCOPY   VARCHAR2,
                               p_lsqv_rec      IN    lsqv_rec_type) is

    -- Cursor to make sure the category is a valid one
    cursor c (p_scs_code okc_k_seq_lines.scs_code%TYPE) is
    select 'x'
      from okc_subclasses_b
     where code = p_scs_code;

    l_dummy Varchar2(1);
    l_row_notfound Boolean := False;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- If no category chosen, return immediately
    If (p_lsqv_rec.scs_code = OKC_API.G_MISS_CHAR or
  	   p_lsqv_rec.scs_code IS NULL) Then
      Return;
    End If;

    -- Check that it is a valid category
    Open c(p_lsqv_rec.scs_code);
    Fetch c Into l_dummy;
    l_row_notfound := c%NotFound;
    Close c;
    If l_row_notfound Then
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_invalid_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'scs_code');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_scs_code;

  PROCEDURE validate_id(x_return_status OUT NOCOPY   VARCHAR2,
                        p_lsqv_rec      IN    lsqv_rec_type) is

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that id is not null
    If (p_lsqv_rec.id = OKC_API.G_MISS_NUM or
  	   p_lsqv_rec.id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_required_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'id');

	  -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_manual_override_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_manual_override_yn(x_return_status OUT NOCOPY   VARCHAR2,
                                        p_lsqv_rec      IN    lsqv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that manual_override_yn is not null
    If (p_lsqv_rec.manual_override_yn = OKC_API.G_MISS_CHAR or
  	   p_lsqv_rec.manual_override_yn IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_required_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'manual_override_yn');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_lsqv_rec.manual_override_yn) NOT IN ('Y','N')) Then
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_invalid_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'manual_override_yn');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);
	   -- set error flag as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_manual_override_yn;

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
  -- FUNCTION get_rec for: OKC_K_SEQ_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lsq_rec                      IN lsq_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lsq_rec_type IS
    CURSOR lsq_pk_csr (p_id IN OKC_K_SEQ_LINES.ID%TYPE) IS
    SELECT ID,
           LINE_CODE,
           DOC_SEQUENCE_ID,
           BUSINESS_GROUP_ID,
           OPERATING_UNIT_ID,
           CLS_CODE,
           SCS_CODE,
           CONTRACT_NUMBER_PREFIX,
           CONTRACT_NUMBER_SUFFIX,
           NUMBER_FORMAT_LENGTH,
           START_SEQ_NO,
           END_SEQ_NO,
           MANUAL_OVERRIDE_YN,
           OBJECT_VERSION_NUMBER,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
      FROM OKC_K_SEQ_LINES
     WHERE OKC_K_SEQ_LINES.ID = p_id;
    l_lsq_pk                       lsq_pk_csr%ROWTYPE;
    l_lsq_rec                      lsq_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN lsq_pk_csr (p_lsq_rec.id);
    FETCH lsq_pk_csr INTO
              l_lsq_rec.ID,
              l_lsq_rec.LINE_CODE,
              l_lsq_rec.DOC_SEQUENCE_ID,
              l_lsq_rec.BUSINESS_GROUP_ID,
              l_lsq_rec.OPERATING_UNIT_ID,
              l_lsq_rec.CLS_CODE,
              l_lsq_rec.SCS_CODE,
              l_lsq_rec.CONTRACT_NUMBER_PREFIX,
              l_lsq_rec.CONTRACT_NUMBER_SUFFIX,
              l_lsq_rec.NUMBER_FORMAT_LENGTH,
              l_lsq_rec.START_SEQ_NO,
              l_lsq_rec.END_SEQ_NO,
              l_lsq_rec.MANUAL_OVERRIDE_YN,
              l_lsq_rec.OBJECT_VERSION_NUMBER,
              l_lsq_rec.CREATED_BY,
              l_lsq_rec.CREATION_DATE,
              l_lsq_rec.LAST_UPDATED_BY,
              l_lsq_rec.LAST_UPDATE_DATE,
              l_lsq_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := lsq_pk_csr%NOTFOUND;
    CLOSE lsq_pk_csr;
    RETURN(l_lsq_rec);
  END get_rec;

  FUNCTION get_rec (
    p_lsq_rec                      IN lsq_rec_type
  ) RETURN lsq_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lsq_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_SEQ_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lsqv_rec                     IN lsqv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lsqv_rec_type IS
    CURSOR okc_lsqv_pk_csr (p_id IN OKC_K_SEQ_LINES_V.ID%TYPE) IS
    SELECT
            ID,
            LINE_CODE,
            DOC_SEQUENCE_ID,
            BUSINESS_GROUP_ID,
            OPERATING_UNIT_ID,
            CLS_CODE,
            SCS_CODE,
            CONTRACT_NUMBER_PREFIX,
            CONTRACT_NUMBER_SUFFIX,
            NUMBER_FORMAT_LENGTH,
            START_SEQ_NO,
            END_SEQ_NO,
            MANUAL_OVERRIDE_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKC_K_SEQ_LINES_V
     WHERE OKC_K_SEQ_LINES_V.ID  = p_id;
    l_okc_lsqv_pk                  okc_lsqv_pk_csr%ROWTYPE;
    l_lsqv_rec                     lsqv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_lsqv_pk_csr (p_lsqv_rec.id);
    FETCH okc_lsqv_pk_csr INTO
              l_lsqv_rec.ID,
              l_lsqv_rec.LINE_CODE,
              l_lsqv_rec.DOC_SEQUENCE_ID,
              l_lsqv_rec.BUSINESS_GROUP_ID,
              l_lsqv_rec.OPERATING_UNIT_ID,
              l_lsqv_rec.CLS_CODE,
              l_lsqv_rec.SCS_CODE,
              l_lsqv_rec.CONTRACT_NUMBER_PREFIX,
              l_lsqv_rec.CONTRACT_NUMBER_SUFFIX,
              l_lsqv_rec.NUMBER_FORMAT_LENGTH,
              l_lsqv_rec.START_SEQ_NO,
              l_lsqv_rec.END_SEQ_NO,
              l_lsqv_rec.MANUAL_OVERRIDE_YN,
              l_lsqv_rec.OBJECT_VERSION_NUMBER,
              l_lsqv_rec.CREATED_BY,
              l_lsqv_rec.CREATION_DATE,
              l_lsqv_rec.LAST_UPDATED_BY,
              l_lsqv_rec.LAST_UPDATE_DATE,
              l_lsqv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_lsqv_pk_csr%NOTFOUND;
    CLOSE okc_lsqv_pk_csr;
    RETURN(l_lsqv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_lsqv_rec                     IN lsqv_rec_type
  ) RETURN lsqv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lsqv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_SEQ_LINES_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_lsqv_rec	IN lsqv_rec_type
  ) RETURN lsqv_rec_type IS
    l_lsqv_rec	lsqv_rec_type := p_lsqv_rec;
  BEGIN
    IF (l_lsqv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.id := NULL;
    END IF;
    IF (l_lsqv_rec.doc_sequence_id = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.doc_sequence_id := NULL;
    END IF;
    IF (l_lsqv_rec.business_group_id = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.business_group_id := NULL;
    END IF;
    IF (l_lsqv_rec.operating_unit_id = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.operating_unit_id := NULL;
    END IF;
    IF (l_lsqv_rec.number_format_length = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.number_format_length := NULL;
    END IF;
    IF (l_lsqv_rec.start_seq_no = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.start_seq_no := NULL;
    END IF;
    IF (l_lsqv_rec.end_seq_no = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.end_seq_no := NULL;
    END IF;
    IF (l_lsqv_rec.line_code = OKC_API.G_MISS_CHAR) THEN
      l_lsqv_rec.line_code := NULL;
    END IF;
    IF (l_lsqv_rec.cls_code = OKC_API.G_MISS_CHAR) THEN
      l_lsqv_rec.cls_code := NULL;
    END IF;
    IF (l_lsqv_rec.scs_code = OKC_API.G_MISS_CHAR) THEN
      l_lsqv_rec.scs_code := NULL;
    END IF;
    IF (l_lsqv_rec.contract_number_prefix = OKC_API.G_MISS_CHAR) THEN
      l_lsqv_rec.contract_number_prefix := NULL;
    END IF;
    IF (l_lsqv_rec.contract_number_suffix = OKC_API.G_MISS_CHAR) THEN
      l_lsqv_rec.contract_number_suffix := NULL;
    END IF;
    IF (l_lsqv_rec.manual_override_yn = OKC_API.G_MISS_CHAR) THEN
      l_lsqv_rec.manual_override_yn := NULL;
    END IF;
    IF (l_lsqv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.object_version_number := NULL;
    END IF;
    IF (l_lsqv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.created_by := NULL;
    END IF;
    IF (l_lsqv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_lsqv_rec.creation_date := NULL;
    END IF;
    IF (l_lsqv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.last_updated_by := NULL;
    END IF;
    IF (l_lsqv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_lsqv_rec.last_update_date := NULL;
    END IF;
    IF (l_lsqv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_lsqv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_lsqv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKC_K_SEQ_LINES_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_lsqv_rec IN  lsqv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  /************************ HAND-CODED *********************************/
    validate_line_code (x_return_status	=> l_return_status,
		        p_lsqv_rec	=> p_lsqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_id (x_return_status	=> l_return_status,
		 p_lsqv_rec		=> p_lsqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_doc_sequence_id(x_return_status	=> l_return_status,
			     p_lsqv_rec		=> p_lsqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_cls_code(x_return_status	=> l_return_status,
		      p_lsqv_rec	=> p_lsqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_scs_code (x_return_status	=> l_return_status,
		       p_lsqv_rec	=> p_lsqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_manual_override_yn
			(x_return_status	=> l_return_status,
			 p_lsqv_rec		=> p_lsqv_rec);

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
  ------------------------------------------
  -- Validate_Record for:OKC_K_SEQ_LINES_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_lsqv_rec IN lsqv_rec_type
  ) RETURN VARCHAR2 IS

    -- Cursor to get all the header information
    CURSOR cur_ksq (p_line_code OKC_K_SEQ_HEADER.LINE_CODE%TYPE) is
    SELECT SITE_YN,
           BG_OU_NONE,
           CLS_SCS_NONE,
           USER_FUNCTION_YN,
           PDF_ID
      FROM OKC_K_SEQ_HEADER
     WHERE LINE_CODE = p_line_code;

    -- Cursor to make sure there is only 1 detail for site
    CURSOR cur_lsq is
    SELECT count(*)
      FROM OKC_K_SEQ_LINES
     WHERE id <> p_lsqv_rec.id
       AND line_code = 'SITE';

    -- Depending on what has been selected in the header,
    -- one of the following cursors will be used to check for data integrity.
    -- The valid 8 combinations are :
    -- BG+CLS/ BG+SCS/ BG/ OU+CLS/ OU+SCS/ OU/ CLS/ SCS
    -- The following cursors are one each for the above combinations, to
    -- make sure that there is no duplicate combination already existing
    -- in the database.

    CURSOR c1(p_business_group_id OKC_K_SEQ_LINES.BUSINESS_GROUP_ID%TYPE,
              p_cls_code OKC_K_SEQ_LINES.CLS_CODE%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE business_group_id = p_business_group_id
       AND cls_code = p_cls_code
       AND id <> p_lsqv_rec.id;

    CURSOR c2(p_business_group_id OKC_K_SEQ_LINES.BUSINESS_GROUP_ID%TYPE,
              p_scs_code OKC_K_SEQ_LINES.SCS_CODE%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE business_group_id = p_business_group_id
       AND scs_code = p_scs_code
       AND id <> p_lsqv_rec.id;

    CURSOR c3(p_business_group_id OKC_K_SEQ_LINES.BUSINESS_GROUP_ID%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE business_group_id = p_business_group_id
       AND cls_code is null
       AND scs_code is null
       AND id <> p_lsqv_rec.id;

    CURSOR c4(p_operating_unit_id OKC_K_SEQ_LINES.OPERATING_UNIT_ID%TYPE,
              p_cls_code OKC_K_SEQ_LINES.CLS_CODE%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE operating_unit_id = p_operating_unit_id
       AND cls_code = p_cls_code
       AND id <> p_lsqv_rec.id;

    CURSOR c5(p_operating_unit_id OKC_K_SEQ_LINES.OPERATING_UNIT_ID%TYPE,
              p_scs_code OKC_K_SEQ_LINES.SCS_CODE%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE operating_unit_id = p_operating_unit_id
       AND scs_code = p_scs_code
       AND id <> p_lsqv_rec.id;

    CURSOR c6(p_operating_unit_id OKC_K_SEQ_LINES.OPERATING_UNIT_ID%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE operating_unit_id = p_operating_unit_id
       AND cls_code is null
       AND scs_code is null
       AND id <> p_lsqv_rec.id;

    CURSOR c7(p_cls_code OKC_K_SEQ_LINES.CLS_CODE%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE cls_code = p_cls_code
       AND business_group_id is null
       AND operating_unit_id is null
       AND id <> p_lsqv_rec.id;

    CURSOR c8(p_scs_code OKC_K_SEQ_LINES.SCS_CODE%TYPE) IS
    SELECT 'x'
      FROM OKC_K_SEQ_LINES
     WHERE scs_code = p_scs_code
       AND business_group_id is null
       AND operating_unit_id is null
       AND id <> p_lsqv_rec.id;

    l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_row_found       BOOLEAN     := TRUE;
    l_row_notfound    BOOLEAN     := FALSE;
    l_dummy           VARCHAR2(1);
    l_dummy_num       NUMBER;
    l_ksq_rec         cur_ksq%ROWTYPE;

  BEGIN
    -- First get all the header information
    Open cur_ksq(p_lsqv_rec.line_code);
    Fetch cur_ksq Into l_ksq_rec;
    l_row_found := cur_ksq%NOTFOUND;
    Close cur_ksq;
    If l_row_notfound Then
	 -- Display the error message if there is no header information
	 OKC_API.set_message(G_APP_NAME, G_NO_PARENT_RECORD);
	 l_return_status := OKC_API.G_RET_STS_ERROR;
  	 RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    If l_ksq_rec.site_yn = 'Y' Then
      -- With site_yn, no other combination can be selected
      If (p_lsqv_rec.business_group_id <> OKC_API.G_MISS_NUM And
          p_lsqv_rec.business_group_id Is Not Null) Or
         (p_lsqv_rec.operating_unit_id <> OKC_API.G_MISS_NUM And
          p_lsqv_rec.operating_unit_id Is Not Null) Or
         (p_lsqv_rec.cls_code <> OKC_API.G_MISS_CHAR And
          p_lsqv_rec.cls_code Is Not Null) Or
         (p_lsqv_rec.scs_code <> OKC_API.G_MISS_CHAR And
          p_lsqv_rec.scs_code Is Not Null) Then
        -- Display the error message
        OKC_API.set_message(G_APP_NAME,
                            'OKC_SITE_EXCLUSIVE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      End If;
      -- Make sure there is only 1 detail for site
      Open cur_lsq;
      Fetch cur_lsq Into l_dummy_num;
      Close cur_lsq;
      If l_dummy_num > 0 Then
        -- Display the error message
        OKC_API.set_message(G_APP_NAME,
                            'OKC_SITE_ONE_SEQ_ALLOWED');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;

    -- In case of User Defined Function, No detail is allowed
    If l_ksq_rec.user_function_yn = 'Y' Then
	 -- Display the error message
	 OKC_API.set_message(G_APP_NAME,
                          'OKC_FUNCTION_NO_SEQ');
	 l_return_status := OKC_API.G_RET_STS_ERROR;
  	 RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Make sure business group and operating unit are mutually selected.
    -- Both cannot be selected at the same time
    If (p_lsqv_rec.business_group_id <> OKC_API.G_MISS_NUM And
        p_lsqv_rec.business_group_id Is Not Null) And
       (p_lsqv_rec.operating_unit_id <> OKC_API.G_MISS_NUM And
        p_lsqv_rec.operating_unit_id Is Not Null) Then
	 -- Display the error message
	 OKC_API.set_message(G_APP_NAME,
                          'OKC_BG_OU_EXCLUSIVE');
	 l_return_status := OKC_API.G_RET_STS_ERROR;
  	 RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Same goes for class and category. Both cannot be selected
    -- at the same time.
    If (p_lsqv_rec.cls_code <> OKC_API.G_MISS_CHAR And
        p_lsqv_rec.cls_code Is Not Null) And
       (p_lsqv_rec.scs_code <> OKC_API.G_MISS_CHAR And
        p_lsqv_rec.scs_code Is Not Null) Then
	 -- Display the error message
	 OKC_API.set_message(G_APP_NAME,
                          'OKC_CLS_SCS_EXCLUSIVE');
	 l_return_status := OKC_API.G_RET_STS_ERROR;
  	 RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- If Business Group has been selected
    If (p_lsqv_rec.business_group_id <> OKC_API.G_MISS_NUM And
        p_lsqv_rec.business_group_id Is Not Null) Then
      -- Class has been selected
      If (p_lsqv_rec.cls_code <> OKC_API.G_MISS_CHAR And
          p_lsqv_rec.cls_code Is Not Null) Then
        Open c1(p_lsqv_rec.business_group_id, p_lsqv_rec.cls_code);
        Fetch c1 Into l_dummy;
        l_row_found := c1%Found;
        Close c1;
      -- Category has been selected
      Elsif (p_lsqv_rec.scs_code <> OKC_API.G_MISS_CHAR And
             p_lsqv_rec.scs_code Is Not Null) Then
        Open c2(p_lsqv_rec.business_group_id, p_lsqv_rec.scs_code);
        Fetch c2 Into l_dummy;
        l_row_found := c2%Found;
        Close c2;
      Else
        -- Neither Class nor Category has been selected
        Open c3(p_lsqv_rec.business_group_id);
        Fetch c3 Into l_dummy;
        l_row_found := c3%Found;
        Close c3;
      End If;
    -- If Operating Unit has been selected
    ElsIf (p_lsqv_rec.operating_unit_id <> OKC_API.G_MISS_NUM And
           p_lsqv_rec.operating_unit_id Is Not Null) Then
       -- Class has been selected
      If (p_lsqv_rec.cls_code <> OKC_API.G_MISS_CHAR And
          p_lsqv_rec.cls_code Is Not Null) Then
        Open c4(p_lsqv_rec.operating_unit_id, p_lsqv_rec.cls_code);
        Fetch c4 Into l_dummy;
        l_row_found := c4%Found;
        Close c4;
      -- Category has been selected
      Elsif (p_lsqv_rec.scs_code <> OKC_API.G_MISS_CHAR And
             p_lsqv_rec.scs_code Is Not Null) Then
        Open c5(p_lsqv_rec.operating_unit_id, p_lsqv_rec.scs_code);
        Fetch c5 Into l_dummy;
        l_row_found := c5%Found;
        Close c5;
      -- Neither Class not Category has been selected
      Else
        Open c6(p_lsqv_rec.operating_unit_id);
        Fetch c6 Into l_dummy;
        l_row_found := c6%Found;
        Close c6;
      End If;
    -- Only Class selected
    Elsif (p_lsqv_rec.cls_code <> OKC_API.G_MISS_CHAR And
           p_lsqv_rec.cls_code Is Not Null) Then
      Open c7(p_lsqv_rec.cls_code);
      Fetch c7 Into l_dummy;
      l_row_found := c7%Found;
      Close c7;
    -- Only Category selected
    Elsif (p_lsqv_rec.scs_code <> OKC_API.G_MISS_CHAR And
           p_lsqv_rec.scs_code Is Not Null) Then
      Open c8(p_lsqv_rec.scs_code);
      Fetch c8 Into l_dummy;
      l_row_found := c8%Found;
      Close c8;
    End If;

    -- If row already exists for the given combination and fora different ID,
    -- it is unique key violation.
    IF (l_row_found) THEN
	 -- Display the error message
	 OKC_API.set_message(G_APP_NAME,
                          'OKC_DUP_K_SEQ_LINE_KEY');
	 l_return_status := OKC_API.G_RET_STS_ERROR;
  	 RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Make sure start sequence is not greater than end sequence.
    If (p_lsqv_rec.start_seq_no <> OKC_API.G_MISS_NUM And
        p_lsqv_rec.start_seq_no Is Not Null) And
       (p_lsqv_rec.end_seq_no <> OKC_API.G_MISS_NUM And
        p_lsqv_rec.end_seq_no Is Not Null) Then
      If p_lsqv_rec.start_seq_no > p_lsqv_rec.end_seq_no Then
	   -- Display the error message
	   OKC_API.set_message(G_APP_NAME,
                            'OKC_START_SEQ_MORE_THAN_END');
	   l_return_status := OKC_API.G_RET_STS_ERROR;
  	   RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    /*********************** END HAND-CODED *************************/

    RETURN (l_return_status);
  EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
          -- no processing necessary; validation can continue with next column
          RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN lsqv_rec_type,
    p_to	IN OUT NOCOPY lsq_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.line_code := p_from.line_code;
    p_to.doc_sequence_id := p_from.doc_sequence_id;
    p_to.business_group_id := p_from.business_group_id;
    p_to.operating_unit_id := p_from.operating_unit_id;
    p_to.cls_code := p_from.cls_code;
    p_to.scs_code := p_from.scs_code;
    p_to.contract_number_prefix := p_from.contract_number_prefix;
    p_to.contract_number_suffix := p_from.contract_number_suffix;
    p_to.number_format_length := p_from.number_format_length;
    p_to.start_seq_no := p_from.start_seq_no;
    p_to.end_seq_no := p_from.end_seq_no;
    p_to.manual_override_yn := p_from.manual_override_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN lsq_rec_type,
    p_to	IN OUT NOCOPY lsqv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.line_code := p_from.line_code;
    p_to.doc_sequence_id := p_from.doc_sequence_id;
    p_to.business_group_id := p_from.business_group_id;
    p_to.operating_unit_id := p_from.operating_unit_id;
    p_to.cls_code := p_from.cls_code;
    p_to.scs_code := p_from.scs_code;
    p_to.contract_number_prefix := p_from.contract_number_prefix;
    p_to.contract_number_suffix := p_from.contract_number_suffix;
    p_to.number_format_length := p_from.number_format_length;
    p_to.start_seq_no := p_from.start_seq_no;
    p_to.end_seq_no := p_from.end_seq_no;
    p_to.manual_override_yn := p_from.manual_override_yn;
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
  -- validate_row for:OKC_K_SEQ_LINES_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsqv_rec                     lsqv_rec_type := p_lsqv_rec;
    l_lsq_rec                      lsq_rec_type;
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
    l_return_status := Validate_Attributes(l_lsqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_lsqv_rec);
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
  -- PL/SQL TBL validate_row for:lsqV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsqv_tbl.COUNT > 0) THEN
      i := p_lsqv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsqv_rec                     => p_lsqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_lsqv_tbl.LAST);
        i := p_lsqv_tbl.NEXT(i);
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
  -----------------------------------
  -- insert_row for:OKC_K_SEQ_LINES --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsq_rec                      IN lsq_rec_type,
    x_lsq_rec                      OUT NOCOPY lsq_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'L_SEQ_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsq_rec                      lsq_rec_type := p_lsq_rec;
    l_def_lsq_rec                  lsq_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_LINES --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_lsq_rec IN  lsq_rec_type,
      x_lsq_rec OUT NOCOPY lsq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsq_rec := p_lsq_rec;
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
      p_lsq_rec,                         -- IN
      l_lsq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_SEQ_LINES(
        id,
        line_code,
        doc_sequence_id,
        business_group_id,
        operating_unit_id,
        cls_code,
        scs_code,
        contract_number_prefix,
        contract_number_suffix,
        number_format_length,
        start_seq_no,
        end_seq_no,
        manual_override_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_lsq_rec.id,
        l_lsq_rec.line_code,
        l_lsq_rec.doc_sequence_id,
        l_lsq_rec.business_group_id,
        l_lsq_rec.operating_unit_id,
        l_lsq_rec.cls_code,
        l_lsq_rec.scs_code,
        l_lsq_rec.contract_number_prefix,
        l_lsq_rec.contract_number_suffix,
        l_lsq_rec.number_format_length,
        l_lsq_rec.start_seq_no,
        l_lsq_rec.end_seq_no,
        l_lsq_rec.manual_override_yn,
        l_lsq_rec.object_version_number,
        l_lsq_rec.created_by,
        l_lsq_rec.creation_date,
        l_lsq_rec.last_updated_by,
        l_lsq_rec.last_update_date,
        l_lsq_rec.last_update_login);
    -- Set OUT values
    x_lsq_rec := l_lsq_rec;
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
  -------------------------------------
  -- insert_row for:OKC_K_SEQ_LINES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsqv_rec                     lsqv_rec_type;
    l_def_lsqv_rec                 lsqv_rec_type;
    l_lsq_rec                      lsq_rec_type;
    lx_lsq_rec                     lsq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lsqv_rec	IN lsqv_rec_type
    ) RETURN lsqv_rec_type IS
      l_lsqv_rec	lsqv_rec_type := p_lsqv_rec;
    BEGIN
      l_lsqv_rec.CREATION_DATE := SYSDATE;
      l_lsqv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_lsqv_rec.LAST_UPDATE_DATE := l_lsqv_rec.CREATION_DATE;
      l_lsqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_lsqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_lsqv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_LINES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_lsqv_rec IN  lsqv_rec_type,
      x_lsqv_rec OUT NOCOPY lsqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsqv_rec := p_lsqv_rec;
      x_lsqv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_lsqv_rec := null_out_defaults(p_lsqv_rec);
    -- Set primary key value
    l_lsqv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_lsqv_rec,                        -- IN
      l_def_lsqv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_lsqv_rec := fill_who_columns(l_def_lsqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lsqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_lsqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_lsqv_rec, l_lsq_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lsq_rec,
      lx_lsq_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lsq_rec, l_def_lsqv_rec);
    -- Set OUT values
    x_lsqv_rec := l_def_lsqv_rec;

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
  -- PL/SQL TBL insert_row for:lsqV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsqv_tbl.COUNT > 0) THEN
      i := p_lsqv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsqv_rec                     => p_lsqv_tbl(i),
          x_lsqv_rec                     => x_lsqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_lsqv_tbl.LAST);
        i := p_lsqv_tbl.NEXT(i);
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
  ---------------------------------
  -- lock_row for:OKC_K_SEQ_LINES --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsq_rec                      IN lsq_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_lsq_rec IN lsq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_SEQ_LINES
     WHERE ID = p_lsq_rec.id
       AND OBJECT_VERSION_NUMBER = p_lsq_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_lsq_rec IN lsq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_SEQ_LINES
    WHERE ID = p_lsq_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'L_SEQ_lock_row';
    l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_SEQ_LINES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_SEQ_LINES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_lsq_rec);
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
      OPEN lchk_csr(p_lsq_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_lsq_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_lsq_rec.object_version_number THEN
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
  -----------------------------------
  -- lock_row for:OKC_K_SEQ_LINES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsq_rec                      lsq_rec_type;
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
    migrate(p_lsqv_rec, l_lsq_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lsq_rec
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
  -- PL/SQL TBL lock_row for:lsqV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsqv_tbl.COUNT > 0) THEN
      i := p_lsqv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsqv_rec                     => p_lsqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_lsqv_tbl.LAST);
        i := p_lsqv_tbl.NEXT(i);
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
  -----------------------------------
  -- update_row for:OKC_K_SEQ_LINES --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsq_rec                      IN lsq_rec_type,
    x_lsq_rec                      OUT NOCOPY lsq_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'L_SEQ_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsq_rec                      lsq_rec_type := p_lsq_rec;
    l_def_lsq_rec                  lsq_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lsq_rec	IN lsq_rec_type,
      x_lsq_rec	OUT NOCOPY lsq_rec_type
    ) RETURN VARCHAR2 IS
      l_lsq_rec                      lsq_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsq_rec := p_lsq_rec;
      -- Get current database values
      l_lsq_rec := get_rec(p_lsq_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_lsq_rec.doc_sequence_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.doc_sequence_id := l_lsq_rec.doc_sequence_id;
      END IF;
      IF (x_lsq_rec.business_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.business_group_id := l_lsq_rec.business_group_id;
      END IF;
      IF (x_lsq_rec.operating_unit_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.operating_unit_id := l_lsq_rec.operating_unit_id;
      END IF;
      IF (x_lsq_rec.number_format_length = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.number_format_length := l_lsq_rec.number_format_length;
      END IF;
      IF (x_lsq_rec.start_seq_no = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.start_seq_no := l_lsq_rec.start_seq_no;
      END IF;
      IF (x_lsq_rec.end_seq_no = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.end_seq_no := l_lsq_rec.end_seq_no;
      END IF;
      IF (x_lsq_rec.line_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lsq_rec.line_code := l_lsq_rec.line_code;
      END IF;
      IF (x_lsq_rec.cls_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lsq_rec.cls_code := l_lsq_rec.cls_code;
      END IF;
      IF (x_lsq_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lsq_rec.scs_code := l_lsq_rec.scs_code;
      END IF;
      IF (x_lsq_rec.contract_number_prefix = OKC_API.G_MISS_CHAR)
      THEN
        x_lsq_rec.contract_number_prefix := l_lsq_rec.contract_number_prefix;
      END IF;
      IF (x_lsq_rec.contract_number_suffix = OKC_API.G_MISS_CHAR)
      THEN
        x_lsq_rec.contract_number_suffix := l_lsq_rec.contract_number_suffix;
      END IF;
      IF (x_lsq_rec.manual_override_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lsq_rec.manual_override_yn := l_lsq_rec.manual_override_yn;
      END IF;
      IF (x_lsq_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.object_version_number := l_lsq_rec.object_version_number;
      END IF;
      IF (x_lsq_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.created_by := l_lsq_rec.created_by;
      END IF;
      IF (x_lsq_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_lsq_rec.creation_date := l_lsq_rec.creation_date;
      END IF;
      IF (x_lsq_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.last_updated_by := l_lsq_rec.last_updated_by;
      END IF;
      IF (x_lsq_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_lsq_rec.last_update_date := l_lsq_rec.last_update_date;
      END IF;
      IF (x_lsq_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_lsq_rec.last_update_login := l_lsq_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_LINES --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_lsq_rec IN  lsq_rec_type,
      x_lsq_rec OUT NOCOPY lsq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsq_rec := p_lsq_rec;
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
      p_lsq_rec,                         -- IN
      l_lsq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lsq_rec, l_def_lsq_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKC_K_SEQ_LINES
    SET LINE_CODE = l_def_lsq_rec.line_code,
        DOC_SEQUENCE_ID = l_def_lsq_rec.doc_sequence_id,
        BUSINESS_GROUP_ID = l_def_lsq_rec.business_group_id,
        OPERATING_UNIT_ID = l_def_lsq_rec.operating_unit_id,
        CLS_CODE = l_def_lsq_rec.cls_code,
        SCS_CODE = l_def_lsq_rec.scs_code,
        CONTRACT_NUMBER_PREFIX = l_def_lsq_rec.contract_number_prefix,
        CONTRACT_NUMBER_SUFFIX = l_def_lsq_rec.contract_number_suffix,
        NUMBER_FORMAT_LENGTH = l_def_lsq_rec.number_format_length,
        START_SEQ_NO = l_def_lsq_rec.start_seq_no,
        END_SEQ_NO = l_def_lsq_rec.end_seq_no,
        MANUAL_OVERRIDE_YN = l_def_lsq_rec.manual_override_yn,
        OBJECT_VERSION_NUMBER = l_def_lsq_rec.object_version_number,
        CREATED_BY = l_def_lsq_rec.created_by,
        CREATION_DATE = l_def_lsq_rec.creation_date,
        LAST_UPDATED_BY = l_def_lsq_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_lsq_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_lsq_rec.last_update_login
    WHERE ID = l_def_lsq_rec.id;

    x_lsq_rec := l_def_lsq_rec;
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
  -------------------------------------
  -- update_row for:OKC_K_SEQ_LINES_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type,
    x_lsqv_rec                     OUT NOCOPY lsqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsqv_rec                     lsqv_rec_type := p_lsqv_rec;
    l_def_lsqv_rec                 lsqv_rec_type;
    l_lsq_rec                      lsq_rec_type;
    lx_lsq_rec                     lsq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lsqv_rec	IN lsqv_rec_type
    ) RETURN lsqv_rec_type IS
      l_lsqv_rec	lsqv_rec_type := p_lsqv_rec;
    BEGIN
      l_lsqv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_lsqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_lsqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_lsqv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lsqv_rec	IN lsqv_rec_type,
      x_lsqv_rec	OUT NOCOPY lsqv_rec_type
    ) RETURN VARCHAR2 IS
      l_lsqv_rec                     lsqv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsqv_rec := p_lsqv_rec;
      -- Get current database values
      l_lsqv_rec := get_rec(p_lsqv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_lsqv_rec.doc_sequence_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.doc_sequence_id := l_lsqv_rec.doc_sequence_id;
      END IF;
      IF (x_lsqv_rec.business_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.business_group_id := l_lsqv_rec.business_group_id;
      END IF;
      IF (x_lsqv_rec.operating_unit_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.operating_unit_id := l_lsqv_rec.operating_unit_id;
      END IF;
      IF (x_lsqv_rec.number_format_length = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.number_format_length := l_lsqv_rec.number_format_length;
      END IF;
      IF (x_lsqv_rec.start_seq_no = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.start_seq_no := l_lsqv_rec.start_seq_no;
      END IF;
      IF (x_lsqv_rec.end_seq_no = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.end_seq_no := l_lsqv_rec.end_seq_no;
      END IF;
      IF (x_lsqv_rec.line_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lsqv_rec.line_code := l_lsqv_rec.line_code;
      END IF;
      IF (x_lsqv_rec.cls_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lsqv_rec.cls_code := l_lsqv_rec.cls_code;
      END IF;
      IF (x_lsqv_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lsqv_rec.scs_code := l_lsqv_rec.scs_code;
      END IF;
      IF (x_lsqv_rec.contract_number_prefix = OKC_API.G_MISS_CHAR)
      THEN
        x_lsqv_rec.contract_number_prefix := l_lsqv_rec.contract_number_prefix;
      END IF;
      IF (x_lsqv_rec.contract_number_suffix = OKC_API.G_MISS_CHAR)
      THEN
        x_lsqv_rec.contract_number_suffix := l_lsqv_rec.contract_number_suffix;
      END IF;
      IF (x_lsqv_rec.manual_override_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lsqv_rec.manual_override_yn := l_lsqv_rec.manual_override_yn;
      END IF;
      IF (x_lsqv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.object_version_number := l_lsqv_rec.object_version_number;
      END IF;
      IF (x_lsqv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.created_by := l_lsqv_rec.created_by;
      END IF;
      IF (x_lsqv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_lsqv_rec.creation_date := l_lsqv_rec.creation_date;
      END IF;
      IF (x_lsqv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.last_updated_by := l_lsqv_rec.last_updated_by;
      END IF;
      IF (x_lsqv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_lsqv_rec.last_update_date := l_lsqv_rec.last_update_date;
      END IF;
      IF (x_lsqv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_lsqv_rec.last_update_login := l_lsqv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_LINES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_lsqv_rec IN  lsqv_rec_type,
      x_lsqv_rec OUT NOCOPY lsqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsqv_rec := p_lsqv_rec;
      x_lsqv_rec.OBJECT_VERSION_NUMBER := NVL(x_lsqv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_lsqv_rec,                        -- IN
      l_lsqv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lsqv_rec, l_def_lsqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_lsqv_rec := fill_who_columns(l_def_lsqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lsqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_lsqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_lsqv_rec, l_lsq_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lsq_rec,
      lx_lsq_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lsq_rec, l_def_lsqv_rec);
    x_lsqv_rec := l_def_lsqv_rec;
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
  -- PL/SQL TBL update_row for:lsqV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type,
    x_lsqv_tbl                     OUT NOCOPY lsqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsqv_tbl.COUNT > 0) THEN
      i := p_lsqv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsqv_rec                     => p_lsqv_tbl(i),
          x_lsqv_rec                     => x_lsqv_tbl(i));
        EXIT WHEN (i = p_lsqv_tbl.LAST);
        i := p_lsqv_tbl.NEXT(i);
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
  -----------------------------------
  -- delete_row for:OKC_K_SEQ_LINES --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsq_rec                      IN lsq_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'L_SEQ_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsq_rec                      lsq_rec_type:= p_lsq_rec;
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
    DELETE FROM OKC_K_SEQ_LINES
     WHERE ID = l_lsq_rec.id;

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
  -------------------------------------
  -- delete_row for:OKC_K_SEQ_LINES_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_rec                     IN lsqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsqv_rec                     lsqv_rec_type := p_lsqv_rec;
    l_lsq_rec                      lsq_rec_type;
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
    migrate(l_lsqv_rec, l_lsq_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lsq_rec
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
  -- PL/SQL TBL delete_row for:lsqV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsqv_tbl                     IN lsqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsqv_tbl.COUNT > 0) THEN
      i := p_lsqv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsqv_rec                     => p_lsqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_lsqv_tbl.LAST);
        i := p_lsqv_tbl.NEXT(i);
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
--
END OKC_LSQ_PVT;

/
