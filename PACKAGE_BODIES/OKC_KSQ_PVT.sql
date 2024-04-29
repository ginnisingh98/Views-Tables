--------------------------------------------------------
--  DDL for Package Body OKC_KSQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_KSQ_PVT" AS
/* $Header: OKCSKSQB.pls 120.2 2006/08/24 09:39:12 npalepu noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  Type seq_header Is Record (
    line_code          okc_k_seq_header.line_code%TYPE,
    site_yn            okc_k_seq_header.site_yn%TYPE,
    bg_ou_none         okc_k_seq_header.bg_ou_none%TYPE,
    cls_scs_none       okc_k_seq_header.cls_scs_none%TYPE,
    user_function_yn   okc_k_seq_header.user_function_yn%TYPE,
    pdf_id             okc_k_seq_header.pdf_id%TYPE,
    manual_override_yn okc_k_seq_header.manual_override_yn%TYPE);

  g_seq_header    seq_header;

  Type doc_sequence_id_tbl Is Table Of
       okc_k_seq_lines.doc_sequence_id%TYPE Index By Binary_Integer;
  Type business_group_id_tbl Is Table Of
       okc_k_seq_lines.business_group_id%TYPE Index By Binary_Integer;
  Type operating_unit_id_tbl Is Table Of
       okc_k_seq_lines.operating_unit_id%TYPE Index By Binary_Integer;
  Type cls_code_tbl Is Table Of
       okc_k_seq_lines.cls_code%TYPE Index By Binary_Integer;
  Type scs_code_tbl Is Table Of
       okc_k_seq_lines.scs_code%TYPE Index By Binary_Integer;
  Type manual_override_yn_tbl Is Table Of
       okc_k_seq_lines.manual_override_yn%TYPE Index By Binary_Integer;
  Type contract_number_prefix_tbl Is Table Of
       okc_k_seq_lines.contract_number_prefix%TYPE Index By Binary_Integer;
  Type contract_number_suffix_tbl Is Table Of
       okc_k_seq_lines.contract_number_suffix%TYPE Index By Binary_Integer;
  Type number_format_length_tbl Is Table Of
       okc_k_seq_lines.number_format_length%TYPE Index By Binary_Integer;
  Type start_seq_no_tbl Is Table Of
       okc_k_seq_lines.start_seq_no%TYPE Index By Binary_Integer;
  Type end_seq_no_tbl Is Table Of
       okc_k_seq_lines.end_seq_no%TYPE Index By Binary_Integer;

  g_doc_sequence_id_tbl        doc_sequence_id_tbl;
  g_business_group_id_tbl      business_group_id_tbl;
  g_operating_unit_id_tbl      operating_unit_id_tbl;
  g_cls_code_tbl               cls_code_tbl;
  g_scs_code_tbl               scs_code_tbl;
  g_manual_override_yn_tbl     manual_override_yn_tbl;
  g_contract_number_prefix_tbl contract_number_prefix_tbl;
  g_contract_number_suffix_tbl contract_number_suffix_tbl;
  g_number_format_length_tbl   number_format_length_tbl;
  g_start_seq_no_tbl           start_seq_no_tbl;
  g_end_seq_no_tbl             end_seq_no_tbl;

  g_index             Number;
  g_seq_status        Varchar2(30);
  g_session_id        Varchar2(255) := OKC_API.G_MISS_CHAR;
  g_business_group_id Number        := OKC_API.G_MISS_NUM;
  g_operating_unit_id Number        := OKC_API.G_MISS_NUM;
  g_scs_code          Varchar2(30)  := OKC_API.G_MISS_CHAR;
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
                               p_ksqv_rec      IN    ksqv_rec_type) is

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that line_code has some valid value
    If (p_ksqv_rec.line_code = OKC_API.G_MISS_CHAR or
  	   p_ksqv_rec.line_code IS NULL) Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_required_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'line_code');
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

  End validate_line_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_site_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_site_yn(x_return_status OUT NOCOPY   VARCHAR2,
                             p_ksqv_rec      IN    ksqv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that site_yn has some valid value
    If (p_ksqv_rec.site_yn = OKC_API.G_MISS_CHAR or
  	   p_ksqv_rec.site_yn IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_required_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'site_yn');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_ksqv_rec.site_yn) NOT IN ('Y','N')) Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_invalid_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'site_yn');
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
  End validate_site_yn;

  -- Start of comments
  --
  -- Procedure Name  : validate_bg_ou_none
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_bg_ou_none(x_return_status OUT NOCOPY   VARCHAR2,
                                p_ksqv_rec      IN    ksqv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that bg_ou_none has some valid value
    If (p_ksqv_rec.bg_ou_none = OKC_API.G_MISS_CHAR or
  	   p_ksqv_rec.bg_ou_none IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_required_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'bg_ou_none');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (p_ksqv_rec.bg_ou_none NOT IN ('BUG', 'OPU', 'NON')) Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_invalid_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'bg_ou_none');
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
  End validate_bg_ou_none;

  -- Start of comments
  --
  -- Procedure Name  : validate_cls_scs_none
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_cls_scs_none(x_return_status OUT NOCOPY   VARCHAR2,
                                  p_ksqv_rec      IN    ksqv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that cls_scs_none has valid value
    If (p_ksqv_rec.cls_scs_none = OKC_API.G_MISS_CHAR or
  	   p_ksqv_rec.cls_scs_none IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_required_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'cls_scs_none');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_ksqv_rec.cls_scs_none) NOT IN ('CLS', 'SCS', 'NON')) Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_invalid_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'cls_scs_none');
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
  End validate_cls_scs_none;

  -- Start of comments
  --
  -- Procedure Name  : validate_user_function_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_user_function_yn(x_return_status OUT NOCOPY   VARCHAR2,
                                      p_ksqv_rec      IN    ksqv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that user_function_yn has valid value
    If (p_ksqv_rec.user_function_yn = OKC_API.G_MISS_CHAR or
  	   p_ksqv_rec.user_function_yn IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_required_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'user_function_yn');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_ksqv_rec.user_function_yn) NOT IN ('Y','N')) Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_invalid_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'user_function_yn');
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
  End validate_user_function_yn;

  PROCEDURE validate_pdf_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_ksqv_rec      IN    ksqv_rec_type) is

  l_dummy_var   VARCHAR2(1);
  l_row_notfound Boolean := False;
  -- Cursor to make sure it is a valid process def
  Cursor l_pdfv_csr Is
  select 'x'
    from OKC_PROCESS_DEFS_B
   where ID = p_ksqv_rec.pdf_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    If (p_ksqv_rec.user_function_yn = 'Y') Then
      Null;
      -- If no pdf, report it as an error
      /* If (p_ksqv_rec.pdf_id = OKC_API.G_MISS_NUM or
          p_ksqv_rec.pdf_id IS NULL) Then
  	OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                            p_msg_name => g_required_value,
                            p_token1 => g_col_name_token,
                            p_token1_value => 'pdf_id');
        -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt validation
	raise G_EXCEPTION_HALT_VALIDATION;
      End If; */
    End If;

    -- Check that it is a valid Process Definition
    If (p_ksqv_rec.pdf_id IS Not Null) And
       (p_ksqv_rec.pdf_id <> OKC_API.G_MISS_NUM) Then
      Open l_pdfv_csr;
      Fetch l_pdfv_csr Into l_dummy_var;
      l_row_notfound := l_pdfv_csr%NOTFOUND;
      Close l_pdfv_csr;

      If l_row_notfound Then
        OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
                            p_msg_name		=> g_no_parent_record,
                            p_token1		=> g_col_name_token,
                            p_token1_value	=> 'pdf_id',
                            p_token2		=> g_child_table_token,
                            p_token2_value	=> 'OKC_K_SEQ_HEADER_V',
                            p_token3		=> g_parent_table_token,
                            p_token3_value	=> 'OKC_PROCESS_DEFS_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
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

  End validate_pdf_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_manual_override_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  procedure validate_manual_override_yn(x_return_status OUT NOCOPY   VARCHAR2,
                                        p_ksqv_rec      IN    ksqv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that manual_override_yn has valid value
    If (p_ksqv_rec.manual_override_yn = OKC_API.G_MISS_CHAR or
  	   p_ksqv_rec.manual_override_yn IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_required_value,
                              p_token1 => g_col_name_token,
                              p_token1_value => 'manual_override_yn');
	   -- set error flag
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- check allowed values
    If (upper(p_ksqv_rec.manual_override_yn) NOT IN ('Y','N')) Then
  	  OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                              p_msg_name => g_invalid_value,
                              p_token1 => g_col_name_token,
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
  /* FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id; */

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
  -- FUNCTION get_rec for: OKC_K_SEQ_HEADER
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ksq_rec                      IN ksq_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ksq_rec_type IS
    CURSOR ksq_pk_csr (p_line_code IN OKC_K_SEQ_HEADER.LINE_CODE%TYPE) IS
    SELECT  LINE_CODE,
            SITE_YN,
            BG_OU_NONE,
            CLS_SCS_NONE,
            USER_FUNCTION_YN,
            PDF_ID,
            MANUAL_OVERRIDE_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKC_K_SEQ_HEADER
     WHERE OKC_K_SEQ_HEADER.LINE_CODE = p_line_code;
    l_ksq_pk                       ksq_pk_csr%ROWTYPE;
    l_ksq_rec                      ksq_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ksq_pk_csr (p_ksq_rec.line_code);
    FETCH ksq_pk_csr INTO
              l_ksq_rec.LINE_CODE,
              l_ksq_rec.SITE_YN,
              l_ksq_rec.BG_OU_NONE,
              l_ksq_rec.CLS_SCS_NONE,
              l_ksq_rec.USER_FUNCTION_YN,
              l_ksq_rec.PDF_ID,
              l_ksq_rec.MANUAL_OVERRIDE_YN,
              l_ksq_rec.OBJECT_VERSION_NUMBER,
              l_ksq_rec.CREATED_BY,
              l_ksq_rec.CREATION_DATE,
              l_ksq_rec.LAST_UPDATED_BY,
              l_ksq_rec.LAST_UPDATE_DATE,
              l_ksq_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := ksq_pk_csr%NOTFOUND;
    CLOSE ksq_pk_csr;
    RETURN(l_ksq_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ksq_rec                      IN ksq_rec_type
  ) RETURN ksq_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ksq_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_SEQ_HEADER_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ksqv_rec                     IN ksqv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ksqv_rec_type IS
    CURSOR okc_ksqv_pk_csr (p_line_code IN OKC_K_SEQ_HEADER_V.LINE_CODE%TYPE) IS
    SELECT
            LINE_CODE,
            SITE_YN,
            BG_OU_NONE,
            CLS_SCS_NONE,
            USER_FUNCTION_YN,
            PDF_ID,
            MANUAL_OVERRIDE_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKC_K_SEQ_HEADER_V
     WHERE OKC_K_SEQ_HEADER_V.LINE_CODE  = p_line_code;
    l_okc_ksqv_pk                  okc_ksqv_pk_csr%ROWTYPE;
    l_ksqv_rec                     ksqv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_ksqv_pk_csr (p_ksqv_rec.line_code);
    FETCH okc_ksqv_pk_csr INTO
              l_ksqv_rec.LINE_CODE,
              l_ksqv_rec.SITE_YN,
              l_ksqv_rec.BG_OU_NONE,
              l_ksqv_rec.CLS_SCS_NONE,
              l_ksqv_rec.USER_FUNCTION_YN,
              l_ksqv_rec.PDF_ID,
              l_ksqv_rec.MANUAL_OVERRIDE_YN,
              l_ksqv_rec.OBJECT_VERSION_NUMBER,
              l_ksqv_rec.CREATED_BY,
              l_ksqv_rec.CREATION_DATE,
              l_ksqv_rec.LAST_UPDATED_BY,
              l_ksqv_rec.LAST_UPDATE_DATE,
              l_ksqv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_ksqv_pk_csr%NOTFOUND;
    CLOSE okc_ksqv_pk_csr;
    RETURN(l_ksqv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ksqv_rec                     IN ksqv_rec_type
  ) RETURN ksqv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ksqv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_SEQ_HEADER_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ksqv_rec	IN ksqv_rec_type
  ) RETURN ksqv_rec_type IS
    l_ksqv_rec	ksqv_rec_type := p_ksqv_rec;
  BEGIN
    IF (l_ksqv_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_ksqv_rec.pdf_id := NULL;
    END IF;
    IF (l_ksqv_rec.site_yn = OKC_API.G_MISS_CHAR) THEN
      l_ksqv_rec.site_yn := NULL;
    END IF;
    IF (l_ksqv_rec.bg_ou_none = OKC_API.G_MISS_CHAR) THEN
      l_ksqv_rec.bg_ou_none := NULL;
    END IF;
    IF (l_ksqv_rec.cls_scs_none = OKC_API.G_MISS_CHAR) THEN
      l_ksqv_rec.cls_scs_none := NULL;
    END IF;
    IF (l_ksqv_rec.user_function_yn = OKC_API.G_MISS_CHAR) THEN
      l_ksqv_rec.user_function_yn := NULL;
    END IF;
    IF (l_ksqv_rec.manual_override_yn = OKC_API.G_MISS_CHAR) THEN
      l_ksqv_rec.manual_override_yn := NULL;
    END IF;
    IF (l_ksqv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ksqv_rec.object_version_number := NULL;
    END IF;
    IF (l_ksqv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ksqv_rec.created_by := NULL;
    END IF;
    IF (l_ksqv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ksqv_rec.creation_date := NULL;
    END IF;
    IF (l_ksqv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ksqv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ksqv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ksqv_rec.last_update_date := NULL;
    END IF;
    IF (l_ksqv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ksqv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ksqv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKC_K_SEQ_HEADER_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_ksqv_rec IN  ksqv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  /************************ HAND-CODED *********************************/
    validate_line_code
			(x_return_status	=> l_return_status,
			 p_ksqv_rec		=> p_ksqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_pdf_id
			(x_return_status	=> l_return_status,
			 p_ksqv_rec		=> p_ksqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_site_yn
			(x_return_status	=> l_return_status,
			 p_ksqv_rec		=> p_ksqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_bg_ou_none
			(x_return_status	=> l_return_status,
			 p_ksqv_rec		=> p_ksqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_cls_scs_none
			(x_return_status	=> l_return_status,
			 p_ksqv_rec		=> p_ksqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_user_function_yn
			(x_return_status	=> l_return_status,
			 p_ksqv_rec		=> p_ksqv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_manual_override_yn
			(x_return_status	=> l_return_status,
			 p_ksqv_rec		=> p_ksqv_rec);

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
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
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
  -- Validate_Record for:OKC_K_SEQ_HEADER_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_ksqv_rec IN ksqv_rec_type
  ) RETURN VARCHAR2 IS

  -- Cursor to make sure that there is only 1 header per installation
  CURSOR cur_ksq_1 IS
  SELECT count(*)
    FROM   OKC_K_SEQ_HEADER;
  -- WHERE  line_code = p_ksqv_rec.line_code;

  l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  -- l_row_found       BOOLEAN     := FALSE;
  l_dummy           Number;

  BEGIN
    OPEN  cur_ksq_1;
    FETCH cur_ksq_1 INTO l_dummy;
    -- l_row_found := cur_ksq_1%FOUND;
    CLOSE cur_ksq_1;

    -- If more than 1 setup, stack the error message
    IF (l_dummy > 1) THEN
      -- Display the error message
      OKC_API.set_message(G_APP_NAME,
                          'OKC_K_SEQ_SINGLE_HEADER');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- If there is no selection in the header, set the error message
    If p_ksqv_rec.site_yn = 'N' And            -- No site selected
       p_ksqv_rec.user_function_yn = 'N' And   -- Not a  User Defined Function
       p_ksqv_rec.bg_ou_none = 'NON' And       -- No Business Group/OU selected
       p_ksqv_rec.cls_scs_none = 'NON' Then    -- No Class/Category selected
      -- Display the error message
      OKC_API.set_message(G_APP_NAME,
                          'OKC_NO_K_SEQ_SELECTED');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    If p_ksqv_rec.site_yn = 'Y' Then
      -- If site has been selected then no other combination can be selected
      If p_ksqv_rec.bg_ou_none In ('BUG', 'OPU') Or
         p_ksqv_rec.cls_scs_none In ('CLS', 'SCS') Or
         p_ksqv_rec.user_function_yn = 'Y' Then
        -- Display the error message
        OKC_API.set_message(G_APP_NAME,
                            'OKC_SITE_EXCLUSIVE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    If p_ksqv_rec.user_function_yn = 'Y' Then
      -- If user defined function has been selected then
      -- no other combination can be selected
      If p_ksqv_rec.bg_ou_none In ('BUG', 'OPU') Or
         p_ksqv_rec.cls_scs_none In ('CLS', 'SCS') Then
        -- Display the error message
        OKC_API.set_message(G_APP_NAME,
                            'OKC_USER_FUNCTION_EXCLUSIVE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- For user defined function, function name must be supplied
      -- Not necessary. We will make it mandatory in the UI itself.
      /* If p_ksqv_rec.pdf_id = OKC_API.G_MISS_NUM Or
         p_ksqv_rec.pdf_id Is Null Then
        -- Display the error message
        OKC_API.set_message(G_APP_NAME,
                            'OKC_FUNCTION_NAME_UNSELECTED');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF; */
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
    p_from	IN ksqv_rec_type,
    p_to	IN OUT NOCOPY ksq_rec_type
  ) IS
  BEGIN
    p_to.line_code := p_from.line_code;
    p_to.site_yn := p_from.site_yn;
    p_to.bg_ou_none := p_from.bg_ou_none;
    p_to.cls_scs_none := p_from.cls_scs_none;
    p_to.user_function_yn := p_from.user_function_yn;
    p_to.pdf_id := p_from.pdf_id;
    p_to.manual_override_yn := p_from.manual_override_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ksq_rec_type,
    p_to	IN OUT NOCOPY ksqv_rec_type
  ) IS
  BEGIN
    p_to.line_code := p_from.line_code;
    p_to.site_yn := p_from.site_yn;
    p_to.bg_ou_none := p_from.bg_ou_none;
    p_to.cls_scs_none := p_from.cls_scs_none;
    p_to.user_function_yn := p_from.user_function_yn;
    p_to.pdf_id := p_from.pdf_id;
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
  -- validate_row for:OKC_K_SEQ_HEADER_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksqv_rec                     ksqv_rec_type := p_ksqv_rec;
    l_ksq_rec                      ksq_rec_type;
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
    l_return_status := Validate_Attributes(l_ksqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ksqv_rec);
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
  -- PL/SQL TBL validate_row for:ksqV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ksqv_tbl.COUNT > 0) THEN
      i := p_ksqv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ksqv_rec                     => p_ksqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_ksqv_tbl.LAST);
        i := p_ksqv_tbl.NEXT(i);
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
  -- insert_row for:OKC_K_SEQ_HEADER --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksq_rec                      IN ksq_rec_type,
    x_ksq_rec                      OUT NOCOPY ksq_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'K_SEQ_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksq_rec                      ksq_rec_type := p_ksq_rec;
    l_def_ksq_rec                  ksq_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_HEADER --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ksq_rec IN  ksq_rec_type,
      x_ksq_rec OUT NOCOPY ksq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ksq_rec := p_ksq_rec;
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
      p_ksq_rec,                         -- IN
      l_ksq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_SEQ_HEADER(
        line_code,
        site_yn,
        bg_ou_none,
        cls_scs_none,
        user_function_yn,
        pdf_id,
        manual_override_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_ksq_rec.line_code,
        l_ksq_rec.site_yn,
        l_ksq_rec.bg_ou_none,
        l_ksq_rec.cls_scs_none,
        l_ksq_rec.user_function_yn,
        l_ksq_rec.pdf_id,
        l_ksq_rec.manual_override_yn,
        l_ksq_rec.object_version_number,
        l_ksq_rec.created_by,
        l_ksq_rec.creation_date,
        l_ksq_rec.last_updated_by,
        l_ksq_rec.last_update_date,
        l_ksq_rec.last_update_login);
    -- Set OUT values
    x_ksq_rec := l_ksq_rec;
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
  -- insert_row for:OKC_K_SEQ_HEADER_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksqv_rec                     ksqv_rec_type;
    l_def_ksqv_rec                 ksqv_rec_type;
    l_ksq_rec                      ksq_rec_type;
    lx_ksq_rec                     ksq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ksqv_rec	IN ksqv_rec_type
    ) RETURN ksqv_rec_type IS
      l_ksqv_rec	ksqv_rec_type := p_ksqv_rec;
    BEGIN
      l_ksqv_rec.CREATION_DATE := SYSDATE;
      l_ksqv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ksqv_rec.LAST_UPDATE_DATE := l_ksqv_rec.CREATION_DATE;
      l_ksqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ksqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ksqv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_HEADER_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ksqv_rec IN  ksqv_rec_type,
      x_ksqv_rec OUT NOCOPY ksqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ksqv_rec := p_ksqv_rec;
      x_ksqv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_ksqv_rec := null_out_defaults(p_ksqv_rec);
    -- Set primary key value
    -- l_ksqv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ksqv_rec,                        -- IN
      l_def_ksqv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ksqv_rec := fill_who_columns(l_def_ksqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ksqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ksqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ksqv_rec, l_ksq_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ksq_rec,
      lx_ksq_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ksq_rec, l_def_ksqv_rec);
    -- Set OUT values
    x_ksqv_rec := l_def_ksqv_rec;
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
  -- PL/SQL TBL insert_row for:KSQV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ksqv_tbl.COUNT > 0) THEN
      i := p_ksqv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ksqv_rec                     => p_ksqv_tbl(i),
          x_ksqv_rec                     => x_ksqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_ksqv_tbl.LAST);
        i := p_ksqv_tbl.NEXT(i);
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
  -- lock_row for:OKC_K_SEQ_HEADER --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksq_rec                      IN ksq_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ksq_rec IN ksq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_SEQ_HEADER
     WHERE LINE_CODE = p_ksq_rec.line_code
       AND OBJECT_VERSION_NUMBER = p_ksq_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ksq_rec IN ksq_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_SEQ_HEADER
    WHERE LINE_CODE = p_ksq_rec.line_code;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                    CONSTANT VARCHAR2(30) := 'K_SEQ_lock_row';
    l_return_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_SEQ_HEADER.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_SEQ_HEADER.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ksq_rec);
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
      OPEN lchk_csr(p_ksq_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ksq_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ksq_rec.object_version_number THEN
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
  -- lock_row for:OKC_K_SEQ_HEADER_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksq_rec                      ksq_rec_type;
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
    migrate(p_ksqv_rec, l_ksq_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ksq_rec
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
  -- PL/SQL TBL lock_row for:ksqV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ksqv_tbl.COUNT > 0) THEN
      i := p_ksqv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ksqv_rec                     => p_ksqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_ksqv_tbl.LAST);
        i := p_ksqv_tbl.NEXT(i);
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
  -- update_row for:OKC_K_SEQ_HEADER --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksq_rec                      IN ksq_rec_type,
    x_ksq_rec                      OUT NOCOPY ksq_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'K_SEQ_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksq_rec                      ksq_rec_type := p_ksq_rec;
    l_def_ksq_rec                  ksq_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ksq_rec	IN ksq_rec_type,
      x_ksq_rec	OUT NOCOPY ksq_rec_type
    ) RETURN VARCHAR2 IS
      l_ksq_rec                      ksq_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ksq_rec := p_ksq_rec;
      -- Get current database values
      l_ksq_rec := get_rec(p_ksq_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ksq_rec.line_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ksq_rec.line_code := l_ksq_rec.line_code;
      END IF;
      IF (x_ksq_rec.site_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ksq_rec.site_yn := l_ksq_rec.site_yn;
      END IF;
      IF (x_ksq_rec.bg_ou_none = OKC_API.G_MISS_CHAR)
      THEN
        x_ksq_rec.bg_ou_none := l_ksq_rec.bg_ou_none;
      END IF;
      IF (x_ksq_rec.cls_scs_none = OKC_API.G_MISS_CHAR)
      THEN
        x_ksq_rec.cls_scs_none := l_ksq_rec.cls_scs_none;
      END IF;
      IF (x_ksq_rec.user_function_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ksq_rec.user_function_yn := l_ksq_rec.user_function_yn;
      END IF;
      IF (x_ksq_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_ksq_rec.pdf_id := l_ksq_rec.pdf_id;
      END IF;
      IF (x_ksq_rec.manual_override_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ksq_rec.manual_override_yn := l_ksq_rec.manual_override_yn;
      END IF;
      IF (x_ksq_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ksq_rec.object_version_number := l_ksq_rec.object_version_number;
      END IF;
      IF (x_ksq_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ksq_rec.created_by := l_ksq_rec.created_by;
      END IF;
      IF (x_ksq_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ksq_rec.creation_date := l_ksq_rec.creation_date;
      END IF;
      IF (x_ksq_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ksq_rec.last_updated_by := l_ksq_rec.last_updated_by;
      END IF;
      IF (x_ksq_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ksq_rec.last_update_date := l_ksq_rec.last_update_date;
      END IF;
      IF (x_ksq_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ksq_rec.last_update_login := l_ksq_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_HEADER --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ksq_rec IN  ksq_rec_type,
      x_ksq_rec OUT NOCOPY ksq_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ksq_rec := p_ksq_rec;
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
      p_ksq_rec,                         -- IN
      l_ksq_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ksq_rec, l_def_ksq_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKC_K_SEQ_HEADER
    SET SITE_YN = l_def_ksq_rec.site_yn,
        BG_OU_NONE = l_def_ksq_rec.bg_ou_none,
        CLS_SCS_NONE = l_def_ksq_rec.cls_scs_none,
        USER_FUNCTION_YN = l_def_ksq_rec.user_function_yn,
        PDF_ID = l_def_ksq_rec.pdf_id,
        MANUAL_OVERRIDE_YN = l_def_ksq_rec.manual_override_yn,
        OBJECT_VERSION_NUMBER = l_def_ksq_rec.object_version_number,
        CREATED_BY = l_def_ksq_rec.created_by,
        CREATION_DATE = l_def_ksq_rec.creation_date,
        LAST_UPDATED_BY = l_def_ksq_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ksq_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ksq_rec.last_update_login
    WHERE LINE_CODE = l_def_ksq_rec.line_code;

    x_ksq_rec := l_def_ksq_rec;
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
  -- update_row for:OKC_K_SEQ_HEADER_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type,
    x_ksqv_rec                     OUT NOCOPY ksqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksqv_rec                     ksqv_rec_type := p_ksqv_rec;
    l_def_ksqv_rec                 ksqv_rec_type;
    l_ksq_rec                      ksq_rec_type;
    lx_ksq_rec                     ksq_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ksqv_rec	IN ksqv_rec_type
    ) RETURN ksqv_rec_type IS
      l_ksqv_rec	ksqv_rec_type := p_ksqv_rec;
    BEGIN
      l_ksqv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ksqv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ksqv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ksqv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ksqv_rec	IN ksqv_rec_type,
      x_ksqv_rec	OUT NOCOPY ksqv_rec_type
    ) RETURN VARCHAR2 IS
      l_ksqv_rec                     ksqv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ksqv_rec := p_ksqv_rec;
      -- Get current database values
      l_ksqv_rec := get_rec(p_ksqv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ksqv_rec.line_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ksqv_rec.line_code := l_ksqv_rec.line_code;
      END IF;
      IF (x_ksqv_rec.site_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ksqv_rec.site_yn := l_ksqv_rec.site_yn;
      END IF;
      IF (x_ksqv_rec.bg_ou_none = OKC_API.G_MISS_CHAR)
      THEN
        x_ksqv_rec.bg_ou_none := l_ksqv_rec.bg_ou_none;
      END IF;
      IF (x_ksqv_rec.cls_scs_none = OKC_API.G_MISS_CHAR)
      THEN
        x_ksqv_rec.cls_scs_none := l_ksqv_rec.cls_scs_none;
      END IF;
      IF (x_ksqv_rec.user_function_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ksqv_rec.user_function_yn := l_ksqv_rec.user_function_yn;
      END IF;
      IF (x_ksqv_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_ksqv_rec.pdf_id := l_ksqv_rec.pdf_id;
      END IF;
      IF (x_ksqv_rec.manual_override_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_ksqv_rec.manual_override_yn := l_ksqv_rec.manual_override_yn;
      END IF;
      IF (x_ksqv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ksqv_rec.object_version_number := l_ksqv_rec.object_version_number;
      END IF;
      IF (x_ksqv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ksqv_rec.created_by := l_ksqv_rec.created_by;
      END IF;
      IF (x_ksqv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ksqv_rec.creation_date := l_ksqv_rec.creation_date;
      END IF;
      IF (x_ksqv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ksqv_rec.last_updated_by := l_ksqv_rec.last_updated_by;
      END IF;
      IF (x_ksqv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ksqv_rec.last_update_date := l_ksqv_rec.last_update_date;
      END IF;
      IF (x_ksqv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ksqv_rec.last_update_login := l_ksqv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_K_SEQ_HEADER_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ksqv_rec IN  ksqv_rec_type,
      x_ksqv_rec OUT NOCOPY ksqv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ksqv_rec := p_ksqv_rec;
      x_ksqv_rec.OBJECT_VERSION_NUMBER := NVL(x_ksqv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_ksqv_rec,                        -- IN
      l_ksqv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ksqv_rec, l_def_ksqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ksqv_rec := fill_who_columns(l_def_ksqv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ksqv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ksqv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ksqv_rec, l_ksq_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ksq_rec,
      lx_ksq_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ksq_rec, l_def_ksqv_rec);
    x_ksqv_rec := l_def_ksqv_rec;
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
  -- PL/SQL TBL update_row for:ksqV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type,
    x_ksqv_tbl                     OUT NOCOPY ksqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ksqv_tbl.COUNT > 0) THEN
      i := p_ksqv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ksqv_rec                     => p_ksqv_tbl(i),
          x_ksqv_rec                     => x_ksqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_ksqv_tbl.LAST);
        i := p_ksqv_tbl.NEXT(i);
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
  -----------------------------------
  -- delete_row for:OKC_K_SEQ_HEADER --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksq_rec                      IN ksq_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'K_SEQ_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksq_rec                      ksq_rec_type:= p_ksq_rec;
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
    DELETE FROM OKC_K_SEQ_HEADER
     WHERE LINE_CODE = l_ksq_rec.line_code;

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
  -- delete_row for:OKC_K_SEQ_HEADER_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_rec                     IN ksqv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ksqv_rec                     ksqv_rec_type := p_ksqv_rec;
    l_ksq_rec                      ksq_rec_type;
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
    migrate(l_ksqv_rec, l_ksq_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ksq_rec
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
  -- PL/SQL TBL delete_row for:ksqV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ksqv_tbl                     IN ksqv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ksqv_tbl.COUNT > 0) THEN
      i := p_ksqv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ksqv_rec                     => p_ksqv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_ksqv_tbl.LAST);
        i := p_ksqv_tbl.NEXT(i);
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

  PROCEDURE Is_K_Autogenerated(
    p_scs_code Varchar2,
    x_return_status OUT NOCOPY Varchar2) IS
    -- Cursor to get the sequence header information
    cursor csr_k is
    select line_code,
           site_yn,
           bg_ou_none,
           cls_scs_none,
           user_function_yn,
           pdf_id,
           manual_override_yn
      from okc_k_seq_header;

    -- Cursor to get the sequence line details
    cursor csr_l(p_line_code okc_k_seq_header.line_code%TYPE) is
    select doc_sequence_id,
           business_group_id,
           operating_unit_id,
           cls_code,
           scs_code,
           manual_override_yn,
           contract_number_prefix,
           contract_number_suffix,
           number_format_length,
           start_seq_no,
           end_seq_no
      from okc_k_seq_lines
     where line_code = p_line_code;

    cursor csr_cls is
    select cls_code
      from okc_subclasses_b
     where code = p_scs_code;

    -- l_bug Number(15) := Sys_Context('OKC_CONTEXT', 'BUSINESS_GROUP_ID');
    -- l_opu Number(15) := Sys_Context('OKC_CONTEXT', 'ORG_ID');
    --npalepu modified on 22-Aug-2006 for bug # 5470760
    /* l_bug Number := Sys_Context('OKC_CONTEXT', 'BUSINESS_GROUP_ID');
    l_opu Number := Sys_Context('OKC_CONTEXT', 'ORG_ID'); */
    l_bug Number ;
    l_opu Number ;

    CURSOR BUSINESS_GROUP_CSR(V_ORG_ID NUMBER) IS
    SELECT BUSINESS_GROUP_ID
    FROM HR_ALL_ORGANIZATION_UNITS
    WHERE ORGANIZATION_ID = V_ORG_ID;
    --end npalepu

    l_cls_code okc_subclasses_b.cls_code%TYPE;
    l_row_notfound Boolean;

    Function cls_scs_found (i number) Return Boolean is
      l_found Boolean := False;
      --
      -- Return value of True means either a match has been found or
      -- there is no sequence defined at the class/category level
      --
    Begin
      IF (l_debug = 'Y') THEN
         Okc_Debug.Set_Indentation('Is_K_Autogenerted');
         Okc_Debug.Log('1600: Entering cls_scs_found', 2);
      END IF;
      If g_seq_header.cls_scs_none = 'NON' Then
        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('1700: Not set at Class/category level');
        END IF;
        l_found := True;
      Elsif g_seq_header.cls_scs_none = 'CLS' Then
        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('1800: Set at Class level');
        END IF;
        If g_cls_code_tbl(i) = l_cls_code Then
          l_found := True;
        End If;
      Elsif g_seq_header.cls_scs_none = 'SCS' Then
        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('1900: Set at Category level');
        END IF;
        If g_scs_code_tbl(i) = p_scs_code Then
          l_found := True;
        End If;
      End If;
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2000: Exiting cls_scs_found', 2);
         Okc_Debug.Reset_Indentation;
      END IF;
      Return l_found;
    End;
  Begin
    IF (l_debug = 'Y') THEN
       Okc_Debug.Set_Indentation('Is_K_Autogenerted');
       Okc_Debug.Log('100: Is_K_Autogenerted', 2);
    END IF;
    x_return_status := okc_api.g_false;

    --NPALEPU ADDED ON 22-AUG-2006 FOR BUG # 5470760
    l_opu := MO_GLOBAL.GET_CURRENT_ORG_ID ;

    IF l_opu IS NOT NULL THEN
        OPEN BUSINESS_GROUP_CSR(l_opu);
        FETCH BUSINESS_GROUP_CSR INTO l_bug;
        CLOSE BUSINESS_GROUP_CSR;
    END IF;
    --END NPALEPU

    -- Initialize the globals
    g_session_id := Sys_Context('USERENV', 'SESSIONID');
    g_business_group_id := l_bug;
    g_operating_unit_id := l_opu;
    g_scs_code := p_scs_code;

    open csr_k;
    fetch csr_k into g_seq_header;
    l_row_notfound := csr_k%NotFound;
    Close csr_k;

    If l_row_notfound then
      -- If there is no header, there is no setup. So
      -- return immediately after setting the global status.
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('200: No Header Found');
      END IF;
      g_seq_status := G_NO_SETUP_FOUND;
      Raise g_exception_halt_validation;
    End If;

    If g_seq_header.user_function_yn = 'Y' Then
      -- In case of user defined function, there would not be any
      -- line details. Just make sure that pdf has been properly
      -- set in this case.
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('300: Sequence set for User Function');
      END IF;
      g_seq_status := G_SETUP_FOUND;
      If g_seq_header.pdf_id Is Null Then
        g_seq_status := G_NO_PDF_FOUND;
        Raise g_exception_halt_validation;
      End If;
      If g_seq_header.manual_override_yn = 'Y' Then
        -- If manual override flag is Yes, that means users can
        -- overwrite the contract number in the authoring form,
        -- So return false.
        Raise g_exception_halt_validation;
      End If;
      x_return_status := okc_api.g_true;
      Raise g_exception_halt_validation;
    End If;

    -- Get the sequence line details
    Open csr_l(g_seq_header.line_code);
    Fetch csr_l Bulk Collect
     Into g_doc_sequence_id_tbl,
          g_business_group_id_tbl,
          g_operating_unit_id_tbl,
          g_cls_code_tbl,
          g_scs_code_tbl,
          g_manual_override_yn_tbl,
          g_contract_number_prefix_tbl,
          g_contract_number_suffix_tbl,
          g_number_format_length_tbl,
          g_start_seq_no_tbl,
          g_end_seq_no_tbl;
    Close csr_l;

    If g_doc_sequence_id_tbl.count = 0 Then
      -- If there is no line details, no sequence can be ganarated.
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('400: No details found');
      END IF;
      g_seq_status := G_NO_SETUP_FOUND;
      Raise g_exception_halt_validation;
    End If;

    -- Get the class code for the categroy.
    Open csr_cls;
    Fetch csr_cls
     Into l_cls_code;
    Close csr_cls;

    g_index := 0;
    If g_seq_header.site_yn = 'Y' Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('500: Sequence set at Site level');
      END IF;
      g_index := g_doc_sequence_id_tbl.First;
    Elsif g_seq_header.bg_ou_none = 'BUG' Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('600: Sequence set at Business Group level');
      END IF;
      For i in g_business_group_id_tbl.First..g_business_group_id_tbl.Last
      Loop
        If g_business_group_id_tbl(i) = l_bug Then
          If Cls_Scs_Found(i) Then
            g_index := i;
            Exit;
          End If;
        End If;
      End Loop;
    Elsif g_seq_header.bg_ou_none = 'OPU' Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('700: Sequence set at Operating Unit level');
      END IF;
      For i in g_operating_unit_id_tbl.First..g_operating_unit_id_tbl.Last
      Loop
        If g_operating_unit_id_tbl(i) = l_opu Then
          If Cls_Scs_Found(i) Then
            g_index := i;
            Exit;
          End If;
        End If;
      End Loop;
    Elsif g_seq_header.cls_scs_none = 'CLS' Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('800: Sequence set at Class level');
      END IF;
      For i in g_cls_code_tbl.First..g_cls_code_tbl.Last
      Loop
        If g_cls_code_tbl(i) = l_cls_code Then
          g_index := i;
          Exit;
        End If;
      End Loop;
    Elsif g_seq_header.cls_scs_none = 'SCS' Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('900: Sequence set at Category level');
      END IF;
      For i in g_scs_code_tbl.First..g_scs_code_tbl.Last
      Loop
        If g_scs_code_tbl(i) = p_scs_code Then
          g_index := i;
          Exit;
        End If;
      End Loop;
    End If;

    If g_index = 0 Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1000: No matching details found');
      END IF;
      g_seq_status := G_NO_SETUP_FOUND;
      Raise g_exception_halt_validation;
    End If;

    g_seq_status := G_SETUP_FOUND;

    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1100: Matching details found');
    END IF;
    If g_manual_override_yn_tbl(g_index) = 'Y' Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1200: Manual Override is Yes');
      END IF;
      Raise g_exception_halt_validation;
    End If;

    x_return_status := okc_api.g_true;
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('1300: Exiting Is_K_Autogenerated', 2);
       Okc_Debug.Reset_Indentation;
    END IF;
  Exception
    When g_exception_halt_validation Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1400: Exiting Is_K_Autogenerated', 2);
         Okc_Debug.Reset_Indentation;
      END IF;
    When Others Then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      -- set error flag as UNEXPETED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('1500: Exiting Is_K_Autogenerated', 2);
         Okc_Debug.Reset_Indentation;
      END IF;
  End Is_K_Autogenerated;

  PROCEDURE Get_K_Number(
    p_scs_code                     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    x_contract_number              OUT NOCOPY VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2) IS

    l_seq Number;
    l_seq_len Number;
    l_doc_sequence_id Number;
    l_contract_number okc_k_headers_b.contract_number%TYPE;
    l_dummy Varchar2(1);
    l_row_found Boolean := False;
    l_row_notfound Boolean := False;
    l_return_status Varchar2(30);
    l_plsql_block Varchar2(32000);
    l_seq_profile Varchar2(1);

    cursor c1 (p_doc_sequence_id fnd_document_sequences.doc_Sequence_id%TYPE) is
    select application_id,
           category_code,
           set_of_books_id,
           method_code
      from fnd_doc_sequence_assignments
     where doc_sequence_id = p_doc_sequence_id;

    c1_rec c1%RowType;

    cursor pdf_cur(p_id okc_process_defs_b.id%TYPE) is
    select name,
           package_name,
           procedure_name
      from okc_process_defs_v
     where id = p_id;
    pdf_rec pdf_cur%RowType;

    cursor pdf_param_cur(p_id okc_process_def_parameters_v.pdf_id%TYPE) is
    select name,
           data_type,
           replace(default_value, '''', '''''') parm_value
      from okc_process_def_parameters_v
     where pdf_id = p_id;

     --NPALEPU ADDED ON 22-AUG-2006 FOR BUG # 5470760
     l_bug Number ;
     l_opu Number ;

     CURSOR BUSINESS_GROUP_CSR(V_ORG_ID NUMBER) IS
     SELECT BUSINESS_GROUP_ID
     FROM HR_ALL_ORGANIZATION_UNITS
     WHERE ORGANIZATION_ID = V_ORG_ID;
     --END NPALEPU

    Function Contract_Is_Unique(p_contract_number IN
                                okc_k_headers_b.contract_number%TYPE)
      Return Boolean Is

      cursor c2 is
      select 'x'
        --npalepu modified on 24-AUG-2006 for bug # 5487532
        /* from okc_k_headers_b */
        from okc_k_headers_all_b
        --end npalepu
       where contract_number = p_contract_number
         and contract_number_modifier is null;

      cursor c3 is
      select 'x'
        --npalepu modified on 24-AUG-2006 for bug # 5487532
        /* from okc_k_headers_b */
        from okc_k_headers_all_b
        --end npalepu
       where contract_number = p_contract_number
         and contract_number_modifier = p_contract_number_modifier;

      l_ret Boolean;
      l_dummy Varchar2(1);
    Begin
    IF (l_debug = 'Y') THEN
       Okc_Debug.Set_Indentation('Contract_Is_Unique');
       Okc_Debug.Log('100: Entering Contract_Is_Unique', 2);
       Okc_Debug.Log('125: Contract Number: '|| p_contract_number, 2);
       Okc_Debug.Log('150: Modifier       : '|| p_contract_number_modifier, 2);
    END IF;
      If p_contract_number_modifier Is Null OR
	    p_contract_number_modifier = OKC_API.G_MISS_CHAR
	 Then
        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('200: cursor opened is c2', 2);
        END IF;
        Open c2;
        Fetch c2 Into l_dummy;
        l_ret := c2%NotFound;
        Close c2;
      Else
        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('300: cursor opened is c3', 2);
        END IF;
        Open c3;
        Fetch c3 Into l_dummy;
        l_ret := c3%NotFound;
        Close c3;
      End If;
	 If (l_ret) Then
	    IF (l_debug = 'Y') THEN
   	    Okc_Debug.Log('400: Contract not exists');
	    END IF;
      Else
	    IF (l_debug = 'Y') THEN
   	    Okc_Debug.Log('500: Contract exists');
	    END IF;
	 End If;
      IF (l_debug = 'Y') THEN
         Okc_Debug.ReSet_Indentation;
      END IF;
      Return (l_ret);

    End;
  Begin
    IF (l_debug = 'Y') THEN
       Okc_Debug.Set_Indentation('Get_K_Number');
       Okc_Debug.Log('2100: Entering Get_K_Number', 2);
    END IF;
    x_return_status := okc_api.g_ret_sts_success;
    -- First of check the sequence profile option. If it is
    -- not 'Always Used' then we need to loop to retrieve the
    -- contract number from DB sequence until a non-existing
    -- combination is found.
    -- Bug 2351723: allowed "Partially Used"
    --

    --
    -- Bug 2316874, 2310409, 2169921
    -- When contract is created from other applications,
    --      auto generation cannot be based on the login profile set up
    -- 1. If contract creates from a concurrent program,
    --       always generate contract numnber, irrespective of profile option
    --       set up. In this case, the following code will set the profile
    --	   option as Always Used
    -- 2. If contract is created online from other applications,
    --       Any product integrating with OKC should set this profile option
    --       in that product level and handle cases.

    If (fnd_global.conc_request_id > 0) Then
	  fnd_profile.put('UNIQUE:SEQ_NUMBERS','A');
    End If;

    l_seq_profile := Fnd_Profile.Value('UNIQUE:SEQ_NUMBERS');
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2105: Sequence Profile : ' || l_seq_profile);
    END IF;
    If Nvl(l_seq_profile, 'N') NOT IN ('A','P') Then
      Loop
        select okc_k_headers_s1.nextval
          into l_contract_number
          from dual;
        IF (l_debug = 'Y') THEN
           Okc_Debug.Log('2106: Contract Number : ' || l_contract_number);
        END IF;
        Exit When Contract_Is_Unique(l_contract_number);
      End Loop;
      x_contract_number := l_contract_number;
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2107: before Raise g_exception_halt_validation ');
    END IF;
      Raise g_exception_halt_validation;
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2108: after Raise g_exception_halt_validation ');
    END IF;
    End If;
    --
    -- It is quite likely that this procedure will be called in the
    -- same session as is_k_autogenerated. If not call that first
    -- that will build up all the globals etc.
    --

    --NPALEPU ADDED ON 22-AUG-2006 FOR BUG # 5470760
    l_opu := MO_GLOBAL.GET_CURRENT_ORG_ID ;

    IF l_opu IS NOT NULL THEN
        OPEN BUSINESS_GROUP_CSR(l_opu);
        FETCH BUSINESS_GROUP_CSR INTO l_bug;
        CLOSE BUSINESS_GROUP_CSR;
    END IF;
    --END NPALEPU

    If (g_session_id <> Sys_Context('USERENV', 'SESSIONID')) Or
       --npalepu modified for bug # 5470760 on 22-AUG-2006
       /*(g_business_group_id <> Sys_Context('OKC_CONTEXT', 'BUSINESS_GROUP_ID')) Or
       (g_operating_unit_id <> Sys_Context('OKC_CONTEXT', 'ORG_ID')) Or */
       (g_business_group_id <> l_bug) Or
       (g_operating_unit_id <> l_opu) Or
       --end npalepu
       (g_scs_code <> p_scs_code) Then
      Is_K_Autogenerated(p_scs_code,
                         l_return_status);
      --
      -- Return if there is any error
      --
      If l_return_status Not In (Okc_Api.g_true, Okc_Api.g_false) Then
        x_return_status := okc_api.g_ret_sts_error;
        Raise g_exception_halt_validation;
      End If;
    End If;

    --
    -- Return also in case setup cannot be found
    --
    If g_seq_status <> G_SETUP_FOUND Then
      If g_seq_status = G_NO_SETUP_FOUND Then
        Okc_Api.Set_Message('OKC', 'OKC_SEQ_NO_SETUP_FOUND');
      Elsif g_seq_status = G_NO_PDF_FOUND Then
        Okc_Api.Set_Message('OKC', 'OKC_SEQ_NO_PDF_FOUND');
      End If;
      x_return_status := okc_api.g_ret_sts_error;
      Raise g_exception_halt_validation;
    End If;

    If g_seq_header.user_function_yn = 'Y' Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2110: User Defined Function');
      END IF;
      --
      -- Get the process defs details
      --
      Open pdf_cur(g_seq_header.pdf_id);
      Fetch pdf_cur Into pdf_rec;
      l_row_notfound := pdf_cur%NotFound;
      Close pdf_cur;
      If l_row_notfound Then
        --
        -- If process defs could not be found, return with error
        --
        Okc_Api.Set_Message('OKC', 'OKC_SEQ_INVALID_PDF_FOUND');
        x_return_status := okc_api.g_ret_sts_error;
        Raise g_exception_halt_validation;
      End If;
      --
      -- Start building up the plsql block here
      --
      l_plsql_block := 'BEGIN ' ||
                       pdf_rec.package_name || '.' ||
                       pdf_rec.procedure_name || '( ' ||
                       'x_contract_number => :1' ||
                       ',x_return_status   => :2 ';
      --
      -- Collect all the parameters and add them to the block
      --
      For pdf_param_rec In pdf_param_cur(g_seq_header.pdf_id)
      Loop
        l_plsql_block := l_plsql_block ||
                         ',' || pdf_param_rec.name || ' => ' ||
                         '''' || pdf_param_rec.parm_value || '''';
      End Loop;
      l_plsql_block := l_plsql_block || ' ); END;';
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2120: Pl/Sql Block : ' || l_plsql_block);
      END IF;
      --
      -- Finally execute this block dynamically
      --
      Execute Immediate l_plsql_block
        Using IN OUT l_contract_number,
              IN OUT l_return_status;
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2130: l_contract_number : ' || l_contract_number);
         Okc_Debug.Log('2140: l_return_status : ' || l_return_status);
      END IF;
      If l_return_status <> Okc_Api.g_ret_sts_success Then
        x_return_status := l_return_status;
        Raise g_exception_halt_validation;
      End If;
      --
      -- Make sure that the contract number returned along with
      -- the modifier is still unique. If not return with error.
      -- We cannot do a loop here because we do not know what
      -- is inside the function. Probably it might return the same
      -- value again and then we will be in an infinite loop.
      --
      If Not Contract_Is_Unique(l_contract_number) Then
        --
        -- Means the combination already exists
        --
        OKC_API.SET_MESSAGE(
               p_app_name     => g_app_name,
               p_msg_name     => 'OKC_CONTRACT_EXISTS',
               p_token1       => 'VALUE1',
               p_token1_value => l_contract_number,
               p_token2       => 'VALUE2',
               p_token2_value => nvl(p_contract_number_modifier,' '));
        x_return_status := okc_api.g_ret_sts_error;
      Else
        --
        -- It is a unique combination. Set the contract number
        -- and return with success.
        --
        x_contract_number := l_contract_number;
      End If;
      Raise g_exception_halt_validation;
    End If;

    --
    -- Proceed in the usual way if it is not user function.
    -- Get the fnd sequence details that will be used to
    -- retrieve the sequence.
    --
    Open c1(g_doc_sequence_id_tbl(g_index));
    Fetch c1 Into c1_rec;
    Close c1;
    Loop
      l_return_status := Fnd_Seqnum.Get_Seq_Val(
                             c1_rec.application_id,
                             c1_rec.category_code,
                             c1_rec.set_of_books_id,
                             c1_rec.method_code,
                             sysdate,
                             l_seq,
                             l_doc_sequence_id);

      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2200: l_return_status ' || l_return_status);
      END IF;
      If To_Number(l_return_status) <> FND_SEQNUM.SEQSUCC Then
        x_return_status := okc_api.g_ret_sts_error;
        Raise g_exception_halt_validation;
      End If;
      --
      -- The sequence number just generated should not exceed
      -- the user limit
      --
      If g_end_seq_no_tbl(g_index) Is Not Null Then
        If l_seq > g_end_seq_no_tbl(g_index) Then
          Okc_Api.Set_Message('OKC', 'OKC_SEQ_EXCEED_MAX');
          x_return_status := okc_api.g_ret_sts_error;
          Raise g_exception_halt_validation;
        End If;
      End If;
      --
      -- Format the sequence with prefix, suffix and padding
      --
      l_seq_len := Length(l_seq);
      l_seq_len := Greatest(l_seq_len,
                            Nvl(g_number_format_length_tbl(g_index),
                                l_seq_len));
      l_contract_number := g_contract_number_prefix_tbl(g_index) ||
                           Lpad(l_seq, l_seq_len, '0') ||
                           g_contract_number_suffix_tbl(g_index);
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2300: l_contract_Number ' || l_contract_Number);
      END IF;
      --
      -- Make sure this contract number and the modifier
      -- still constitute a unique key, otherwise continue
      -- with the next number
      --
      Exit When Contract_Is_Unique(l_contract_number);
    End Loop;
    x_contract_number := l_contract_number;
    IF (l_debug = 'Y') THEN
       Okc_Debug.Log('2400: Final contract_Number ' || l_contract_Number);
       Okc_Debug.Log('2500: Exiting Get_K_Number', 2);
       Okc_Debug.Reset_Indentation;
    END IF;
  Exception
    When G_EXCEPTION_HALT_VALIDATION Then
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2600: Exiting Get_K_Number', 2);
         Okc_Debug.Log('2601:  G_EXCEPTION_HALT_VALIDATION occured',2);
         Okc_Debug.Reset_Indentation;
      END IF;
    When OTHERS then
	-- store SQL error message on message stack
  	OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                          p_msg_name => g_unexpected_error,
                          p_token1 => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2 => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      -- set error flag as UNEXPETED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         Okc_Debug.Log('2700: Exiting Get_K_Number', 2);
         Okc_Debug.Reset_Indentation;
      END IF;

  END Get_K_Number;

END OKC_KSQ_PVT;

/
