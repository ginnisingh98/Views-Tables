--------------------------------------------------------
--  DDL for Package Body OKC_COP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_COP_PVT" AS
/* $Header: OKCSCOPB.pls 120.0 2005/05/26 09:53:59 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/

  FUNCTION Validate_Attributes ( p_copv_rec IN  copv_rec_type) RETURN VARCHAR2;
  --G_CHILD_RECORD_EXISTS CONSTANT   VARCHAR2(200) := 'OKC_CANNOT_DELETE_MASTER';
  --G_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_VIEW             CONSTANT VARCHAR2(200) := 'OKC_CLASS_OPERATIONS_V';
  G_EXCEPTION_HALT_VALIDATION exception;
  --l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_opn_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_opn_code(x_return_status OUT NOCOPY   VARCHAR2,
                              p_copv_rec      IN    copv_rec_type) is
	 l_dummy_var   VARCHAR2(1) := '?';
      CURSOR l_opnv_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
        FROM okc_operations_b
       WHERE code = p_code;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_copv_rec.opn_code = OKC_API.G_MISS_CHAR or
	   p_copv_rec.opn_code IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Operation Code');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Check foreign key
    Open l_opnv_csr(p_copv_rec.opn_code);
    Fetch l_opnv_csr into l_dummy_var;
    Close l_opnv_csr;

    -- if l_dummy_var still set to default, data was not found
    If (l_dummy_var = '?') Then
    	  OKC_API.SET_MESSAGE(
				    p_app_name      => g_app_name,
				    p_msg_name      => g_no_parent_record,
				    p_token1        => g_col_name_token,
				    p_token1_value  => 'Operation Code',
				    p_token2        => g_child_table_token,
				    p_token2_value  => G_VIEW,
				    p_token3        => g_parent_table_token,
				    p_token3_value  => 'OKC_OPERATIONS_V');
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
  End validate_opn_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_cls_code
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_cls_code(x_return_status OUT NOCOPY   VARCHAR2,
                              p_copv_rec      IN    copv_rec_type) is
	 l_dummy_var   VARCHAR2(1) := '?';
      CURSOR l_clsv_csr (p_code IN VARCHAR2) IS
      SELECT 'x'
        FROM okc_classes_b
       WHERE code = p_code;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_copv_rec.cls_code = OKC_API.G_MISS_CHAR or
	   p_copv_rec.cls_code IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Class Code');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Check foreign key
    Open l_clsv_csr(p_copv_rec.cls_code);
    Fetch l_clsv_csr into l_dummy_var;
    Close l_clsv_csr;

    -- if l_dummy_var still set to default, data was not found
    If (l_dummy_var = '?') Then
    	  OKC_API.SET_MESSAGE(
				    p_app_name      => g_app_name,
				    p_msg_name      => g_no_parent_record,
				    p_token1        => g_col_name_token,
				    p_token1_value  => 'Class Code',
				    p_token2        => g_child_table_token,
				    p_token2_value  => G_VIEW,
				    p_token3        => g_parent_table_token,
				    p_token3_value  => 'OKC_CLASSES_V');
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
  End validate_cls_code;

  -- Start of comments
  --
  -- Procedure Name  : validate_search_function_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_search_function_id(x_return_status OUT NOCOPY   VARCHAR2,
                         		     p_copv_rec      IN    copv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_fndv_csr Is
  	  select 'x'
	  from FND_FORM_FUNCTIONS
  	  where function_id = p_copv_rec.search_function_id;

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (search_function_id is optional)
    If (p_copv_rec.search_function_id <> OKC_API.G_MISS_NUM and
  	   p_copv_rec.search_function_id IS NOT NULL)
    Then
       Open l_fndv_csr;
       Fetch l_fndv_csr Into l_dummy_var;
       Close l_fndv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Search Function Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'FND_FORM_FUNCTIONS');
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
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;

  End validate_search_function_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_detail_function_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_detail_function_id(x_return_status OUT NOCOPY   VARCHAR2,
                         		     p_copv_rec      IN    copv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_fndv_csr Is
  	  select 'x'
	  from FND_FORM_FUNCTIONS
  	  where function_id = p_copv_rec.detail_function_id;

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (detail_function_id is optional)
    If (p_copv_rec.detail_function_id <> OKC_API.G_MISS_NUM and
  	   p_copv_rec.detail_function_id IS NOT NULL)
    Then
       Open l_fndv_csr;
       Fetch l_fndv_csr Into l_dummy_var;
       Close l_fndv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Detail Function Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'FND_FORM_FUNCTIONS');
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
        if l_fndv_csr%ISOPEN then
	      close l_fndv_csr;
        end if;

  End validate_detail_function_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_pdf_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_pdf_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_copv_rec      IN    copv_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_pdfv_csr Is
  	  select 'x'
	  from OKC_PROCESS_DEFS_B
  	  where id = p_copv_rec.pdf_id;

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (pdf_id is optional)
    If (p_copv_rec.pdf_id <> OKC_API.G_MISS_NUM and
  	   p_copv_rec.pdf_id IS NOT NULL)
    Then
       Open l_pdfv_csr;
       Fetch l_pdfv_csr Into l_dummy_var;
       Close l_pdfv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Detail Function Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'pdf_FORM_FUNCTIONS');
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
        if l_pdfv_csr%ISOPEN then
	      close l_pdfv_csr;
        end if;

  End validate_pdf_id;


  -- added DEC 10, 2001
  -- Start of comments
  --
  -- Procedure Name  : validate_grid_datasource_name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_grid_datasource_name(x_return_status OUT NOCOPY   VARCHAR2,
                               p_copv_rec      IN    copv_rec_type) is

	 l_dummy_var   VARCHAR2(1) := '?';
      CURSOR l_grid_csr IS
      SELECT 'x'
        FROM jtf_grid_datasources_b
       WHERE grid_datasource_name = p_copv_rec.grid_datasource_name;
  Begin

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (grid_datasource_name is optional)
    If (p_copv_rec.grid_datasource_name <> OKC_API.G_MISS_CHAR and
  	p_copv_rec.grid_datasource_name IS NOT NULL)
    Then
       Open  l_grid_csr;
       Fetch l_grid_csr Into l_dummy_var;
       Close l_grid_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				        p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Grid Data Source Name',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'JTF_GRID_DATASOURCES_VL');
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
  End validate_grid_datasource_name;

/*********************** END HAND-CODED ********************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS

    --
    -- For non seeded (customer) data, ID should be 50000 or above
    --
    Cursor c Is
    SELECT OKC_CLASS_OPERATIONS_S1.nextval
    FROM dual;

    --
    -- For seeded  data, ID should be greater than or equal to 11000 and less than 50000
    --
    Cursor cop_csr Is
    SELECT
	 nvl(max(id), 11000) + 1
    FROM
	okc_class_operations_v
    WHERE
	ID >= 11000 AND id < 50000;

    l_seq NUMBER;
  BEGIN
    if fnd_global.user_id = 1 then
	  open cop_csr;
	  fetch cop_csr into l_seq;
	  close cop_csr;
    else
       open c;
       fetch c into l_seq;
       close c;
    end if;

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
  -- FUNCTION get_rec for: OKC_CLASS_OPERATIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cop_rec                      IN cop_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cop_rec_type IS
    CURSOR OKC_COP_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OPN_CODE,
            CLS_CODE,
            SEARCH_FUNCTION_ID,
            DETAIL_FUNCTION_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PDF_ID,
            grid_datasource_name,
            QA_PDF_ID                            -- Bug# 2171059
      FROM Okc_Class_Operations
     WHERE okc_class_operations.id = p_id;
    l_OKC_COP_pk                   OKC_COP_pk_csr%ROWTYPE;
    l_cop_rec                      cop_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKC_COP_pk_csr (p_cop_rec.id);
    FETCH OKC_COP_pk_csr INTO
              l_cop_rec.ID,
              l_cop_rec.OPN_CODE,
              l_cop_rec.CLS_CODE,
              l_cop_rec.SEARCH_FUNCTION_ID,
              l_cop_rec.DETAIL_FUNCTION_ID,
              l_cop_rec.OBJECT_VERSION_NUMBER,
              l_cop_rec.CREATED_BY,
              l_cop_rec.CREATION_DATE,
              l_cop_rec.LAST_UPDATED_BY,
              l_cop_rec.LAST_UPDATE_DATE,
              l_cop_rec.LAST_UPDATE_LOGIN,
              l_cop_rec.PDF_ID,
              l_cop_rec.grid_datasource_name,
              l_cop_rec.QA_PDF_ID;                -- Bug# 2171059
    x_no_data_found := OKC_COP_pk_csr%NOTFOUND;
    CLOSE OKC_COP_pk_csr;
    RETURN(l_cop_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cop_rec                      IN cop_rec_type
  ) RETURN cop_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cop_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CLASS_OPERATIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_copv_rec                      IN copv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN copv_rec_type IS
    CURSOR OKC_COPv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OPN_CODE,
            CLS_CODE,
            SEARCH_FUNCTION_ID,
            DETAIL_FUNCTION_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PDF_ID,
            grid_datasource_name,
            QA_PDF_ID                              -- Bug# 2171059
      FROM Okc_Class_Operations_V
     WHERE okc_class_operations_v.id = p_id;
    l_OKC_COPv_pk                   OKC_COPv_pk_csr%ROWTYPE;
    l_copv_rec                      copv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKC_COPv_pk_csr (p_copv_rec.id);
    FETCH OKC_COPv_pk_csr INTO
              l_copv_rec.ID,
              l_copv_rec.OPN_CODE,
              l_copv_rec.CLS_CODE,
              l_copv_rec.SEARCH_FUNCTION_ID,
              l_copv_rec.DETAIL_FUNCTION_ID,
              l_copv_rec.OBJECT_VERSION_NUMBER,
              l_copv_rec.CREATED_BY,
              l_copv_rec.CREATION_DATE,
              l_copv_rec.LAST_UPDATED_BY,
              l_copv_rec.LAST_UPDATE_DATE,
              l_copv_rec.LAST_UPDATE_LOGIN,
              l_copv_rec.PDF_ID,
              l_copv_rec.grid_datasource_name,
              l_copv_rec.QA_PDF_ID;                -- Bug# 2171059
    x_no_data_found := OKC_COPv_pk_csr%NOTFOUND;
    CLOSE OKC_COPv_pk_csr;
    RETURN(l_copv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_copv_rec                      IN copv_rec_type
  ) RETURN copv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_copv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CLASS_OPERATIONS_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_copv_rec	IN copv_rec_type
  ) RETURN copv_rec_type IS
    l_copv_rec	copv_rec_type := p_copv_rec;
  BEGIN
    IF (l_copv_rec.opn_code = OKC_API.G_MISS_CHAR) THEN
      l_copv_rec.opn_code := NULL;
    END IF;
    IF (l_copv_rec.cls_code = OKC_API.G_MISS_CHAR) THEN
      l_copv_rec.cls_code := NULL;
    END IF;
    IF (l_copv_rec.search_function_id = OKC_API.G_MISS_NUM) THEN
      l_copv_rec.search_function_id := NULL;
    END IF;
    IF (l_copv_rec.detail_function_id = OKC_API.G_MISS_NUM) THEN
      l_copv_rec.detail_function_id := NULL;
    END IF;
    IF (l_copv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_copv_rec.object_version_number := NULL;
    END IF;
    IF (l_copv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_copv_rec.created_by := NULL;
    END IF;
    IF (l_copv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_copv_rec.creation_date := NULL;
    END IF;
    IF (l_copv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_copv_rec.last_updated_by := NULL;
    END IF;
    IF (l_copv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_copv_rec.last_update_date := NULL;
    END IF;
    IF (l_copv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_copv_rec.last_update_login := NULL;
    END IF;
    IF (l_copv_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_copv_rec.pdf_id := NULL;
    END IF;
    IF (l_copv_rec.grid_datasource_name = OKC_API.G_MISS_CHAR) THEN
      l_copv_rec.grid_datasource_name := NULL;
    END IF;
    IF (l_copv_rec.qa_pdf_id = OKC_API.G_MISS_NUM) THEN     -- Bug# 2171059
      l_copv_rec.qa_pdf_id := NULL;
    END IF;
    RETURN(l_copv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKC_CLASS_OPERATIONS_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_copv_rec IN  copv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /************************ HAND-CODED *********************************/

	  validate_opn_code(x_return_status => l_return_status,
					p_copv_rec      => p_copv_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_cls_code(x_return_status => l_return_status,
					p_copv_rec      => p_copv_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_search_function_id(x_return_status => l_return_status,
							p_copv_rec      => p_copv_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_detail_function_id(x_return_status => l_return_status,
							p_copv_rec      => p_copv_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_pdf_id(x_return_status => l_return_status,
					p_copv_rec    => p_copv_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

    -- added DEC 10, 2001
    validate_grid_datasource_name(x_return_status => l_return_status,
                       p_copv_rec      => p_copv_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

    RETURN(x_return_status);
  EXCEPTION
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
  ------------------------------------------------
  -- Validate_Record for:OKC_CLASS_OPERATIONS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_copv_rec IN copv_rec_type
  ) RETURN VARCHAR2 IS
    Cursor l_cop_csr Is
		 SELECT 'x'
		 FROM okc_class_operations
		 WHERE cls_code = p_copv_rec.cls_code
		 AND   opn_code = p_copv_rec.opn_code;

    l_dummy            VARCHAR2(1);
    l_return_status    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Check for uniqueness for OPN_CODE + CLS_CODE
    open l_cop_csr;
    fetch l_cop_csr into l_dummy;
    If (l_cop_csr%FOUND) Then
  	   OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				        p_msg_name		=> 'OKC_CLS_OPN_CODES_NOT_UNIQUE');
	   l_return_status := OKC_API.G_RET_STS_ERROR;
    End If;
    close l_cop_csr;

    RETURN (l_return_status);
  EXCEPTION
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
       -- store SQL error message on message stack
       OKC_API.SET_MESSAGE(p_app_name        => g_app_name,
                           p_msg_name        => g_unexpected_error,
                           p_token1          => g_sqlcode_token,
                           p_token1_value    => sqlcode,
                           p_token2          => g_sqlerrm_token,
                           p_token2_value    => sqlerrm);
        -- notify caller of an error as UNEXPETED error
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	   RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN copv_rec_type,
    p_to	IN OUT NOCOPY cop_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.opn_code := p_from.opn_code;
    p_to.cls_code := p_from.cls_code;
    p_to.search_function_id := p_from.search_function_id;
    p_to.detail_function_id := p_from.detail_function_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.pdf_id := p_from.pdf_id;
    p_to.grid_datasource_name := p_from.grid_datasource_name;
    p_to.qa_pdf_id := p_from.qa_pdf_id;                   -- Bug# 2171059
  END migrate;
  PROCEDURE migrate (
    p_from	IN cop_rec_type,
    p_to	IN OUT NOCOPY copv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.opn_code := p_from.opn_code;
    p_to.cls_code := p_from.cls_code;
    p_to.search_function_id := p_from.search_function_id;
    p_to.detail_function_id := p_from.detail_function_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.pdf_id := p_from.pdf_id;
    p_to.grid_datasource_name := p_from.grid_datasource_name;
    p_to.qa_pdf_id := p_from.qa_pdf_id;                   -- Bug# 2171059
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKC_CLASS_OPERATIONS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                      IN copv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_copv_rec                      copv_rec_type := p_copv_rec;
    l_cop_rec                      cop_rec_type;
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
    l_return_status := Validate_Attributes(l_copv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_copv_rec);
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
  -----------------------------------------
  -- PL/SQL TBL validate_row for:copv_tbl --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                      IN copv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_copv_tbl.COUNT > 0) THEN
      i := p_copv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_copv_rec                      => p_copv_tbl(i));
        EXIT WHEN (i = p_copv_tbl.LAST);
        i := p_copv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for:OKC_CLASS_OPERATIONS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cop_rec                      IN cop_rec_type,
    x_cop_rec                      OUT NOCOPY cop_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPERATIONS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cop_rec                      cop_rec_type := p_cop_rec;
    l_def_cop_rec                  cop_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_CLASS_OPERATIONS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cop_rec IN  cop_rec_type,
      x_cop_rec OUT NOCOPY cop_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cop_rec := p_cop_rec;
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
      p_cop_rec,                         -- IN
      l_cop_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CLASS_OPERATIONS(
        id,
        opn_code,
        cls_code,
        search_function_id,
        detail_function_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        pdf_id,
        grid_datasource_name,
        qa_pdf_id )                         -- Bug# 2171059
      VALUES (
        l_cop_rec.id,
        l_cop_rec.opn_code,
        l_cop_rec.cls_code,
        l_cop_rec.search_function_id,
        l_cop_rec.detail_function_id,
        l_cop_rec.object_version_number,
        l_cop_rec.created_by,
        l_cop_rec.creation_date,
        l_cop_rec.last_updated_by,
        l_cop_rec.last_update_date,
        l_cop_rec.last_update_login,
        l_cop_rec.pdf_id,
        l_cop_rec.grid_datasource_name,
        l_cop_rec.qa_pdf_id );              -- Bug# 2171059
    -- Set OUT values
    x_cop_rec := l_cop_rec;
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
  -------------------------------------------
  -- insert_row for:OKC_CLASS_OPERATIONS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                      IN copv_rec_type,
    x_copv_rec                      OUT NOCOPY copv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_copv_rec                      copv_rec_type;
    l_def_copv_rec                  copv_rec_type;
    l_cop_rec                      cop_rec_type;
    lx_cop_rec                     cop_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_copv_rec	IN copv_rec_type
    ) RETURN copv_rec_type IS
      l_copv_rec	copv_rec_type := p_copv_rec;
    BEGIN
      l_copv_rec.CREATION_DATE := SYSDATE;
      l_copv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_copv_rec.LAST_UPDATE_DATE := l_copv_rec.CREATION_DATE;
      l_copv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_copv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_copv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_CLASS_OPERATIONS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_copv_rec IN  copv_rec_type,
      x_copv_rec OUT NOCOPY copv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_copv_rec := p_copv_rec;
      x_copv_rec.OBJECT_VERSION_NUMBER := 10000;
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
    l_copv_rec := null_out_defaults(p_copv_rec);
    -- Set primary key value
    l_copv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_copv_rec,                         -- IN
      l_def_copv_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_copv_rec := fill_who_columns(l_def_copv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_copv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_copv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_copv_rec, l_cop_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cop_rec,
      lx_cop_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cop_rec, l_def_copv_rec);
    -- Set OUT values
    x_copv_rec := l_def_copv_rec;
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
  ---------------------------------------
  -- PL/SQL TBL insert_row for:copv_tbl --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                      IN copv_tbl_type,
    x_copv_tbl                      OUT NOCOPY copv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_copv_tbl.COUNT > 0) THEN
      i := p_copv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_copv_rec                      => p_copv_tbl(i),
          x_copv_rec                      => x_copv_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_copv_tbl.LAST);
        i := p_copv_tbl.NEXT(i);
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
  ---------------------------------------
  -- lock_row for:OKC_CLASS_OPERATIONS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cop_rec                      IN cop_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cop_rec IN cop_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CLASS_OPERATIONS
     WHERE ID = p_cop_rec.id
       AND OBJECT_VERSION_NUMBER = p_cop_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cop_rec IN cop_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CLASS_OPERATIONS
    WHERE ID = p_cop_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPERATIONS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CLASS_OPERATIONS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CLASS_OPERATIONS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cop_rec);
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
      OPEN lchk_csr(p_cop_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cop_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cop_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKC_CLASS_OPERATIONS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                      IN copv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cop_rec                      cop_rec_type;
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
    migrate(p_copv_rec, l_cop_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cop_rec
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
  -------------------------------------
  -- PL/SQL TBL lock_row for:copv_tbl --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                      IN copv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_copv_tbl.COUNT > 0) THEN
      i := p_copv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_copv_rec                      => p_copv_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_copv_tbl.LAST);
        i := p_copv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for:OKC_CLASS_OPERATIONS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cop_rec                      IN cop_rec_type,
    x_cop_rec                      OUT NOCOPY cop_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPERATIONS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cop_rec                      cop_rec_type := p_cop_rec;
    l_def_cop_rec                  cop_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cop_rec	IN cop_rec_type,
      x_cop_rec	OUT NOCOPY cop_rec_type
    ) RETURN VARCHAR2 IS
      l_cop_rec                      cop_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cop_rec := p_cop_rec;
      -- Get current database values
      l_cop_rec := get_rec(p_cop_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cop_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.id := l_cop_rec.id;
      END IF;
      IF (x_cop_rec.opn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cop_rec.opn_code := l_cop_rec.opn_code;
      END IF;
      IF (x_cop_rec.cls_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cop_rec.cls_code := l_cop_rec.cls_code;
      END IF;
      IF (x_cop_rec.search_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.search_function_id := l_cop_rec.search_function_id;
      END IF;
      IF (x_cop_rec.detail_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.detail_function_id := l_cop_rec.detail_function_id;
      END IF;
      IF (x_cop_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.object_version_number := l_cop_rec.object_version_number;
      END IF;
      IF (x_cop_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.created_by := l_cop_rec.created_by;
      END IF;
      IF (x_cop_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cop_rec.creation_date := l_cop_rec.creation_date;
      END IF;
      IF (x_cop_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.last_updated_by := l_cop_rec.last_updated_by;
      END IF;
      IF (x_cop_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cop_rec.last_update_date := l_cop_rec.last_update_date;
      END IF;
      IF (x_cop_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.last_update_login := l_cop_rec.last_update_login;
      END IF;
      IF (x_cop_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_cop_rec.pdf_id := l_cop_rec.pdf_id;
      END IF;
      IF (x_cop_rec.grid_datasource_name = OKC_API.G_MISS_CHAR)
      THEN
        x_cop_rec.grid_datasource_name := l_cop_rec.grid_datasource_name;
      END IF;
      IF (x_cop_rec.qa_pdf_id = OKC_API.G_MISS_NUM)  -- Bug# 2171059
      THEN
        x_cop_rec.qa_pdf_id := l_cop_rec.qa_pdf_id;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_CLASS_OPERATIONS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cop_rec IN  cop_rec_type,
      x_cop_rec OUT NOCOPY cop_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cop_rec := p_cop_rec;
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
      p_cop_rec,                         -- IN
      l_cop_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cop_rec, l_def_cop_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CLASS_OPERATIONS
    SET OPN_CODE = l_def_cop_rec.opn_code,
        CLS_CODE = l_def_cop_rec.cls_code,
        SEARCH_FUNCTION_ID = l_def_cop_rec.search_function_id,
        DETAIL_FUNCTION_ID = l_def_cop_rec.detail_function_id,
        OBJECT_VERSION_NUMBER = l_def_cop_rec.object_version_number,
        CREATED_BY = l_def_cop_rec.created_by,
        CREATION_DATE = l_def_cop_rec.creation_date,
        LAST_UPDATED_BY = l_def_cop_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cop_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cop_rec.last_update_login,
        PDF_ID = l_def_cop_rec.pdf_id,
        grid_datasource_name = l_def_cop_rec.grid_datasource_name,
        QA_PDF_ID = l_def_cop_rec.qa_pdf_id            -- Bug# 2171059
    WHERE ID = l_def_cop_rec.id;

    x_cop_rec := l_def_cop_rec;
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
  -------------------------------------------
  -- update_row for:OKC_CLASS_OPERATIONS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                      IN copv_rec_type,
    x_copv_rec                      OUT NOCOPY copv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_copv_rec                      copv_rec_type := p_copv_rec;
    l_def_copv_rec                  copv_rec_type;
    l_cop_rec                      cop_rec_type;
    lx_cop_rec                     cop_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_copv_rec	IN copv_rec_type
    ) RETURN copv_rec_type IS
      l_copv_rec	copv_rec_type := p_copv_rec;
    BEGIN
      l_copv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_copv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_copv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_copv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_copv_rec	IN copv_rec_type,
      x_copv_rec	OUT NOCOPY copv_rec_type
    ) RETURN VARCHAR2 IS
      l_copv_rec                      copv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_copv_rec := p_copv_rec;
      -- Get current database values
      l_copv_rec := get_rec(p_copv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_copv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.id := l_copv_rec.id;
      END IF;
      IF (x_copv_rec.opn_code = OKC_API.G_MISS_CHAR)
      THEN
        x_copv_rec.opn_code := l_copv_rec.opn_code;
      END IF;
      IF (x_copv_rec.cls_code = OKC_API.G_MISS_CHAR)
      THEN
        x_copv_rec.cls_code := l_copv_rec.cls_code;
      END IF;
      IF (x_copv_rec.search_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.search_function_id := l_copv_rec.search_function_id;
      END IF;
      IF (x_copv_rec.detail_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.detail_function_id := l_copv_rec.detail_function_id;
      END IF;
      IF (x_copv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.object_version_number := l_copv_rec.object_version_number;
      END IF;
      IF (x_copv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.created_by := l_copv_rec.created_by;
      END IF;
      IF (x_copv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_copv_rec.creation_date := l_copv_rec.creation_date;
      END IF;
      IF (x_copv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.last_updated_by := l_copv_rec.last_updated_by;
      END IF;
      IF (x_copv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_copv_rec.last_update_date := l_copv_rec.last_update_date;
      END IF;
      IF (x_copv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.last_update_login := l_copv_rec.last_update_login;
      END IF;
      IF (x_copv_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_copv_rec.pdf_id := l_copv_rec.pdf_id;
      END IF;
      IF (x_copv_rec.grid_datasource_name = OKC_API.G_MISS_CHAR)
      THEN
        x_copv_rec.grid_datasource_name := l_copv_rec.grid_datasource_name;
      END IF;
      IF (x_copv_rec.qa_pdf_id = OKC_API.G_MISS_NUM)      -- Bug# 2171059
      THEN
        x_copv_rec.qa_pdf_id := l_copv_rec.qa_pdf_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_CLASS_OPERATIONS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_copv_rec IN  copv_rec_type,
      x_copv_rec OUT NOCOPY copv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_copv_rec := p_copv_rec;
      x_copv_rec.OBJECT_VERSION_NUMBER := NVL(x_copv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_copv_rec,                         -- IN
      l_copv_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_copv_rec, l_def_copv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_copv_rec := fill_who_columns(l_def_copv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_copv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

----- Commented out because Validate_record checks that the cls_code and opn_code being entered
----- is unique however a record must exist for it to be updated
    /*l_return_status := Validate_Record(l_def_copv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
   */
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_copv_rec, l_cop_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cop_rec,
      lx_cop_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cop_rec, l_def_copv_rec);
    x_copv_rec := l_def_copv_rec;
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
  ---------------------------------------
  -- PL/SQL TBL update_row for:copv_tbl --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                      IN copv_tbl_type,
    x_copv_tbl                      OUT NOCOPY copv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_copv_tbl.COUNT > 0) THEN
      i := p_copv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_copv_rec                      => p_copv_tbl(i),
          x_copv_rec                      => x_copv_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_copv_tbl.LAST);
        i := p_copv_tbl.NEXT(i);
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
  -----------------------------------------
  -- delete_row for:OKC_CLASS_OPERATIONS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cop_rec                      IN cop_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'OPERATIONS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cop_rec                      cop_rec_type:= p_cop_rec;
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
    DELETE FROM OKC_CLASS_OPERATIONS
     WHERE ID = l_cop_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKC_CLASS_OPERATIONS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_rec                      IN copv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_copv_rec                      copv_rec_type := p_copv_rec;
    l_cop_rec                      cop_rec_type;
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
    migrate(l_copv_rec, l_cop_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cop_rec
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
  ---------------------------------------
  -- PL/SQL TBL delete_row for:copv_tbl --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_copv_tbl                      IN copv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_copv_tbl.COUNT > 0) THEN
      i := p_copv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_copv_rec                      => p_copv_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_copv_tbl.LAST);
        i := p_copv_tbl.NEXT(i);
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
END OKC_COP_PVT;

/
