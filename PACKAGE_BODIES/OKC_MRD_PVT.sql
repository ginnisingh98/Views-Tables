--------------------------------------------------------
--  DDL for Package Body OKC_MRD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_MRD_PVT" AS
/* $Header: OKCSMRDB.pls 120.0 2005/05/26 09:42:38 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_EXCEPTION_HALT_VALIDATION   exception;
  G_UNEXPECTED_ERROR CONSTANT   VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_VIEW			 CONSTANT	VARCHAR2(200) := 'OKC_MASSCHANGE_REQ_DTLS_V';
  G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';

  -- Start of comments
  --
  -- Procedure Name  : validate_oie_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_oie_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_mrdv_rec      IN    mrdv_rec_type) is
    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_oiev_csr Is
  	  select 'x'
	  from OKC_OPERATION_INSTANCES
  	  where id = p_mrdv_rec.oie_id;

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_mrdv_rec.oie_id <> OKC_API.G_MISS_NUM and
        p_mrdv_rec.oie_id IS NOT NULL)
    Then
       Open l_oiev_csr;
       Fetch l_oiev_csr Into l_dummy_var;
       Close l_oiev_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				 p_msg_name		=> g_no_parent_record,
				 p_token1		=> g_col_name_token,
				 p_token1_value		=> 'oie_id',
				 p_token2		=> g_child_table_token,
				 p_token2_value		=> G_VIEW,
				 p_token3		=> g_parent_table_token,
				 p_token3_value		=> 'OKC_OPERATION_INSTANCES');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
       End If;
    End If;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			  p_msg_name		=> g_unexpected_error,
			  p_token1		=> g_sqlcode_token,
			  p_token1_value	=> sqlcode,
			  p_token2		=> g_sqlerrm_token,
			  p_token2_value	=> sqlerrm);

	   -- notify caller of an error as UNEXPETED error
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           -- verify that cursor was closed
           if l_oiev_csr%ISOPEN then
	      close l_oiev_csr;
           end if;
  End validate_oie_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_ole_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_ole_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_mrdv_rec      IN    mrdv_rec_type) is
    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_olev_csr Is
  	  select 'x'
	  from OKC_OPERATION_LINES
  	  where id = p_mrdv_rec.ole_id;

  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
/*
-- commented to reslove bug 1790999
-- this is a nullable column
--
    -- check that data exists
    If (p_mrdv_rec.ole_id = OKC_API.G_MISS_NUM or
  	 p_mrdv_rec.ole_id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			      p_msg_name	=> g_required_value,
			      p_token1		=> g_col_name_token,
			      p_token1_value	=> 'ole_id');
	  -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

	  -- halt validation
	  raise G_EXCEPTION_HALT_VALIDATION;
    End If;
*/
    -- foreign key validation
    If (p_mrdv_rec.ole_id <> OKC_API.G_MISS_NUM and
        p_mrdv_rec.ole_id IS NOT NULL)
    Then
       Open l_olev_csr;
       Fetch l_olev_csr Into l_dummy_var;
       Close l_olev_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				 p_msg_name		=> g_no_parent_record,
				 p_token1		=> g_col_name_token,
				 p_token1_value		=> 'ole_id',
				 p_token2		=> g_child_table_token,
				 p_token2_value		=> G_VIEW,
				 p_token3		=> g_parent_table_token,
				 p_token3_value		=> 'OKC_OPERATION_LINES');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
       End If;
    End If;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
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
  End validate_ole_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_attr_name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_attr_name(x_return_status OUT NOCOPY   VARCHAR2,
                               p_mrdv_rec      IN    mrdv_rec_type) is
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If (p_mrdv_rec.attribute_name = OKC_API.G_MISS_CHAR or
	   p_mrdv_rec.attribute_name IS NULL)
    Then
          --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
                        p_msg_name      => G_REQUIRED_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value  => 'Attribute Name');
        -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;

	  -- halt validation
	  raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- enforce foreign key if data exists
    If (p_mrdv_rec.attribute_name <> OKC_API.G_MISS_CHAR and
	   p_mrdv_rec.attribute_name IS NOT NULL)
    Then
      -- Check if the value is a valid code from lookup table
      x_return_status := OKC_UTIL.check_lookup_code('OKS_MASS_CHANGE_ATTRIBUTE',
						     p_mrdv_rec.attribute_name);
      If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
	    --set error message in message stack
	    OKC_API.SET_MESSAGE(
			p_app_name	=> G_APP_NAME,
                        p_msg_name      => G_REQUIRED_VALUE,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value  => 'Attribute Name');
	    raise G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
	    raise G_EXCEPTION_HALT_VALIDATION;
      End If;
    End If;
  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
			  p_msg_name		=> g_unexpected_error,
			  p_token1		=> g_sqlcode_token,
			  p_token1_value	=> sqlcode,
			  p_token2		=> g_sqlerrm_token,
			  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_attr_name;

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
  -- FUNCTION get_rec for: OKC_MASSCHANGE_REQ_DTLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_mrd_rec                      IN mrd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN mrd_rec_type IS
    CURSOR mrd_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OIE_ID,
            OLE_ID,
            ATTRIBUTE_NAME,
            OLD_VALUE,
            NEW_VALUE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
		  LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Masschange_Req_Dtls
     WHERE okc_masschange_req_dtls.id = p_id;
    l_mrd_pk                       mrd_pk_csr%ROWTYPE;
    l_mrd_rec                      mrd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN mrd_pk_csr (p_mrd_rec.id);
    FETCH mrd_pk_csr INTO
              l_mrd_rec.ID,
              l_mrd_rec.OIE_ID,
              l_mrd_rec.OLE_ID,
              l_mrd_rec.ATTRIBUTE_NAME,
              l_mrd_rec.OLD_VALUE,
              l_mrd_rec.NEW_VALUE,
              l_mrd_rec.OBJECT_VERSION_NUMBER,
              l_mrd_rec.CREATED_BY,
              l_mrd_rec.CREATION_DATE,
		    l_mrd_rec.LAST_UPDATED_BY,
              l_mrd_rec.LAST_UPDATE_DATE,
              l_mrd_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := mrd_pk_csr%NOTFOUND;
    CLOSE mrd_pk_csr;
    RETURN(l_mrd_rec);
  END get_rec;

  FUNCTION get_rec (
    p_mrd_rec                      IN mrd_rec_type
  ) RETURN mrd_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_mrd_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_MASSCHANGE_REQ_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_mrdv_rec                     IN mrdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN mrdv_rec_type IS
    CURSOR omrv_pk_csr (p_id                 IN VARCHAR2) IS
    SELECT
            ID,
            OIE_ID,
            OLE_ID,
            ATTRIBUTE_NAME,
            OLD_VALUE,
            NEW_VALUE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
		  LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Masschange_Req_Dtls_V
     WHERE okc_masschange_req_dtls_v.id = p_id;
    l_omrv_pk                      omrv_pk_csr%ROWTYPE;
    l_mrdv_rec                     mrdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN omrv_pk_csr (p_mrdv_rec.id);
    FETCH omrv_pk_csr INTO
              l_mrdv_rec.ID,
              l_mrdv_rec.OIE_ID,
              l_mrdv_rec.OLE_ID,
              l_mrdv_rec.ATTRIBUTE_NAME,
              l_mrdv_rec.OLD_VALUE,
              l_mrdv_rec.NEW_VALUE,
              l_mrdv_rec.OBJECT_VERSION_NUMBER,
              l_mrdv_rec.CREATED_BY,
              l_mrdv_rec.CREATION_DATE,
		    l_mrdv_rec.LAST_UPDATED_BY,
              l_mrdv_rec.LAST_UPDATE_DATE,
              l_mrdv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := omrv_pk_csr%NOTFOUND;
    CLOSE omrv_pk_csr;
    RETURN(l_mrdv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_mrdv_rec                     IN mrdv_rec_type
  ) RETURN mrdv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_mrdv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_MASSCHANGE_REQ_DTLS_V --
  ---------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_mrdv_rec	IN mrdv_rec_type
  ) RETURN mrdv_rec_type IS
    l_mrdv_rec	mrdv_rec_type := p_mrdv_rec;
  BEGIN
    IF (l_mrdv_rec.oie_id = OKC_API.G_MISS_NUM) THEN
      l_mrdv_rec.oie_id := NULL;
    END IF;
    IF (l_mrdv_rec.ole_id = OKC_API.G_MISS_NUM) THEN
      l_mrdv_rec.ole_id := NULL;
    END IF;
    IF (l_mrdv_rec.attribute_name = OKC_API.G_MISS_CHAR) THEN
      l_mrdv_rec.attribute_name := NULL;
    END IF;
    IF (l_mrdv_rec.old_value = OKC_API.G_MISS_CHAR) THEN
      l_mrdv_rec.old_value := NULL;
    END IF;
    IF (l_mrdv_rec.new_value = OKC_API.G_MISS_CHAR) THEN
      l_mrdv_rec.new_value := NULL;
    END IF;
    IF (l_mrdv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_mrdv_rec.object_version_number := NULL;
    END IF;
    IF (l_mrdv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_mrdv_rec.created_by := NULL;
    END IF;
    IF (l_mrdv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_mrdv_rec.creation_date := NULL;
    END IF;
    IF (l_mrdv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_mrdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_mrdv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_mrdv_rec.last_update_date := NULL;
    END IF;
    IF (l_mrdv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_mrdv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_mrdv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKC_MASSCHANGE_REQ_DTLS_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_mrdv_rec IN  mrdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
     validate_oie_id
			(x_return_status => l_return_status,
			 p_mrdv_rec      => p_mrdv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_ole_id
			(x_return_status => l_return_status,
			 p_mrdv_rec      => p_mrdv_rec);

    -- store the highest degree of error
    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
       End If;
    End If;

    validate_attr_name
			(x_return_status => l_return_status,
			 p_mrdv_rec      => p_mrdv_rec);

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

	   -- notify caller of an UNEXPECTED error
	   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	   -- return status to caller
        RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Record for:OKC_MASSCHANGE_REQ_DTLS_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_mrdv_rec IN mrdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN mrdv_rec_type,
    p_to	IN OUT NOCOPY mrd_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.oie_id := p_from.oie_id;
    p_to.ole_id := p_from.ole_id;
    p_to.attribute_name := p_from.attribute_name;
    p_to.old_value := p_from.old_value;
    p_to.new_value := p_from.new_value;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN mrd_rec_type,
    p_to	IN OUT NOCOPY mrdv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.oie_id := p_from.oie_id;
    p_to.ole_id := p_from.ole_id;
    p_to.attribute_name := p_from.attribute_name;
    p_to.old_value := p_from.old_value;
    p_to.new_value := p_from.new_value;
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
  ------------------------------------------------
  -- validate_row for:OKC_MASSCHANGE_REQ_DTLS_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrdv_rec                     mrdv_rec_type := p_mrdv_rec;
    l_mrd_rec                      mrd_rec_type;
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
    l_return_status := Validate_Attributes(l_mrdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_mrdv_rec);
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
  -- PL/SQL TBL validate_row for:MRDV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mrdv_tbl.COUNT > 0) THEN
      i := p_mrdv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_mrdv_rec                     => p_mrdv_tbl(i));
        -- store the highest degree of error
        If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
		 l_overall_status := x_return_status;
	   End If;
        End If;

        EXIT WHEN (i = p_mrdv_tbl.LAST);
        i := p_mrdv_tbl.NEXT(i);
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
  --------------------------------------------
  -- insert_row for:OKC_MASSCHANGE_REQ_DTLS --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrd_rec                      IN mrd_rec_type,
    x_mrd_rec                      OUT NOCOPY mrd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrd_rec                      mrd_rec_type := p_mrd_rec;
    l_def_mrd_rec                  mrd_rec_type;
    ------------------------------------------------
    -- Set_Attributes for:OKC_MASSCHANGE_REQ_DTLS --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_mrd_rec IN  mrd_rec_type,
      x_mrd_rec OUT NOCOPY mrd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mrd_rec := p_mrd_rec;
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
      p_mrd_rec,                         -- IN
      l_mrd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_MASSCHANGE_REQ_DTLS(
        id,
        oie_id,
        ole_id,
        attribute_name,
        old_value,
        new_value,
        object_version_number,
        created_by,
        creation_date,
	   last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_mrd_rec.id,
        l_mrd_rec.oie_id,
        l_mrd_rec.ole_id,
        l_mrd_rec.attribute_name,
        l_mrd_rec.old_value,
        l_mrd_rec.new_value,
        l_mrd_rec.object_version_number,
        l_mrd_rec.created_by,
        l_mrd_rec.creation_date,
	   l_mrd_rec.last_updated_by,
        l_mrd_rec.last_update_date,
        l_mrd_rec.last_update_login);
    -- Set OUT values
    x_mrd_rec := l_mrd_rec;
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
  ----------------------------------------------
  -- insert_row for:OKC_MASSCHANGE_REQ_DTLS_V --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY mrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrdv_rec                     mrdv_rec_type;
    l_def_mrdv_rec                 mrdv_rec_type;
    l_mrd_rec                      mrd_rec_type;
    lx_mrd_rec                     mrd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_mrdv_rec	IN mrdv_rec_type
    ) RETURN mrdv_rec_type IS
      l_mrdv_rec	mrdv_rec_type := p_mrdv_rec;
    BEGIN
      l_mrdv_rec.CREATION_DATE := SYSDATE;
	 l_mrdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_mrdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_mrdv_rec.LAST_UPDATE_DATE := l_mrdv_rec.CREATION_DATE;
      l_mrdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_mrdv_rec);
    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKC_MASSCHANGE_REQ_DTLS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_mrdv_rec IN  mrdv_rec_type,
      x_mrdv_rec OUT NOCOPY mrdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mrdv_rec := p_mrdv_rec;
      x_mrdv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_mrdv_rec := null_out_defaults(p_mrdv_rec);
    -- Set primary key value
    l_mrdv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_mrdv_rec,                        -- IN
      l_def_mrdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_mrdv_rec := fill_who_columns(l_def_mrdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_mrdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_mrdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_mrdv_rec, l_mrd_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_mrd_rec,
      lx_mrd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_mrd_rec, l_def_mrdv_rec);
    -- Set OUT values
    x_mrdv_rec := l_def_mrdv_rec;
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
  -- PL/SQL TBL insert_row for:MRDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY mrdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mrdv_tbl.COUNT > 0) THEN
      i := p_mrdv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_mrdv_rec                     => p_mrdv_tbl(i),
          x_mrdv_rec                     => x_mrdv_tbl(i));
        -- store the highest degree of error
 	If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
		 l_overall_status := x_return_status;
	   End If;
	End If;
        EXIT WHEN (i = p_mrdv_tbl.LAST);
        i := p_mrdv_tbl.NEXT(i);
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
  ------------------------------------------
  -- lock_row for:OKC_MASSCHANGE_REQ_DTLS --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrd_rec                      IN mrd_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_mrd_rec IN mrd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_MASSCHANGE_REQ_DTLS
     WHERE ID = p_mrd_rec.id
       AND OBJECT_VERSION_NUMBER = p_mrd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_mrd_rec IN mrd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_MASSCHANGE_REQ_DTLS
    WHERE ID = p_mrd_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_MASSCHANGE_REQ_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_MASSCHANGE_REQ_DTLS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_mrd_rec);
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
      OPEN lchk_csr(p_mrd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_mrd_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_mrd_rec.object_version_number THEN
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
  --------------------------------------------
  -- lock_row for:OKC_MASSCHANGE_REQ_DTLS_V --
  --------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrd_rec                      mrd_rec_type;
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
    migrate(p_mrdv_rec, l_mrd_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_mrd_rec
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
  -- PL/SQL TBL lock_row for:MRDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mrdv_tbl.COUNT > 0) THEN
      i := p_mrdv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_mrdv_rec                     => p_mrdv_tbl(i));
        -- store the highest degree of error
        If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
	End If;
        EXIT WHEN (i = p_mrdv_tbl.LAST);
        i := p_mrdv_tbl.NEXT(i);
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
  --------------------------------------------
  -- update_row for:OKC_MASSCHANGE_REQ_DTLS --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrd_rec                      IN mrd_rec_type,
    x_mrd_rec                      OUT NOCOPY mrd_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrd_rec                      mrd_rec_type := p_mrd_rec;
    l_def_mrd_rec                  mrd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_mrd_rec	IN mrd_rec_type,
      x_mrd_rec	OUT NOCOPY mrd_rec_type
    ) RETURN VARCHAR2 IS
      l_mrd_rec                      mrd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mrd_rec := p_mrd_rec;
      -- Get current database values
      l_mrd_rec := get_rec(p_mrd_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_mrd_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_mrd_rec.id := l_mrd_rec.id;
      END IF;
      IF (x_mrd_rec.oie_id = OKC_API.G_MISS_NUM)
      THEN
        x_mrd_rec.oie_id := l_mrd_rec.oie_id;
      END IF;
      IF (x_mrd_rec.ole_id = OKC_API.G_MISS_NUM)
      THEN
        x_mrd_rec.ole_id := l_mrd_rec.ole_id;
      END IF;
      IF (x_mrd_rec.attribute_name = OKC_API.G_MISS_CHAR)
      THEN
        x_mrd_rec.attribute_name := l_mrd_rec.attribute_name;
      END IF;
      IF (x_mrd_rec.old_value = OKC_API.G_MISS_CHAR)
      THEN
        x_mrd_rec.old_value := l_mrd_rec.old_value;
      END IF;
      IF (x_mrd_rec.new_value = OKC_API.G_MISS_CHAR)
      THEN
        x_mrd_rec.new_value := l_mrd_rec.new_value;
      END IF;
      IF (x_mrd_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_mrd_rec.object_version_number := l_mrd_rec.object_version_number;
      END IF;
      IF (x_mrd_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_mrd_rec.created_by := l_mrd_rec.created_by;
      END IF;
      IF (x_mrd_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_mrd_rec.creation_date := l_mrd_rec.creation_date;
      END IF;
      IF (x_mrd_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_mrd_rec.last_updated_by := l_mrd_rec.last_updated_by;
      END IF;
      IF (x_mrd_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_mrd_rec.last_update_date := l_mrd_rec.last_update_date;
      END IF;
      IF (x_mrd_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_mrd_rec.last_update_login := l_mrd_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_MASSCHANGE_REQ_DTLS --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_mrd_rec IN  mrd_rec_type,
      x_mrd_rec OUT NOCOPY mrd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mrd_rec := p_mrd_rec;
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
      p_mrd_rec,                         -- IN
      l_mrd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_mrd_rec, l_def_mrd_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_MASSCHANGE_REQ_DTLS
    SET OIE_ID = l_def_mrd_rec.oie_id,
        OLE_ID = l_def_mrd_rec.ole_id,
        ATTRIBUTE_NAME = l_def_mrd_rec.attribute_name,
        OLD_VALUE = l_def_mrd_rec.old_value,
        NEW_VALUE = l_def_mrd_rec.new_value,
        OBJECT_VERSION_NUMBER = l_def_mrd_rec.object_version_number,
        CREATED_BY = l_def_mrd_rec.created_by,
        CREATION_DATE = l_def_mrd_rec.creation_date,
	   LAST_UPDATED_BY = l_def_mrd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_mrd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_mrd_rec.last_update_login
    WHERE ID = l_def_mrd_rec.id;

    x_mrd_rec := l_def_mrd_rec;
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
  ----------------------------------------------
  -- update_row for:OKC_MASSCHANGE_REQ_DTLS_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type,
    x_mrdv_rec                     OUT NOCOPY mrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrdv_rec                     mrdv_rec_type := p_mrdv_rec;
    l_def_mrdv_rec                 mrdv_rec_type;
    l_mrd_rec                      mrd_rec_type;
    lx_mrd_rec                     mrd_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_mrdv_rec	IN mrdv_rec_type
    ) RETURN mrdv_rec_type IS
      l_mrdv_rec	mrdv_rec_type := p_mrdv_rec;
    BEGIN
      l_mrdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_mrdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_mrdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_mrdv_rec	IN mrdv_rec_type,
      x_mrdv_rec	OUT NOCOPY mrdv_rec_type
    ) RETURN VARCHAR2 IS
      l_mrdv_rec                     mrdv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mrdv_rec := p_mrdv_rec;
      -- Get current database values
      l_mrdv_rec := get_rec(p_mrdv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_mrdv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_mrdv_rec.id := l_mrdv_rec.id;
      END IF;
      IF (x_mrdv_rec.oie_id = OKC_API.G_MISS_NUM)
      THEN
        x_mrdv_rec.oie_id := l_mrdv_rec.oie_id;
      END IF;
      IF (x_mrdv_rec.ole_id = OKC_API.G_MISS_NUM)
      THEN
        x_mrdv_rec.ole_id := l_mrdv_rec.ole_id;
      END IF;
      IF (x_mrdv_rec.attribute_name = OKC_API.G_MISS_CHAR)
      THEN
        x_mrdv_rec.attribute_name := l_mrdv_rec.attribute_name;
      END IF;
      IF (x_mrdv_rec.old_value = OKC_API.G_MISS_CHAR)
      THEN
        x_mrdv_rec.old_value := l_mrdv_rec.old_value;
      END IF;
      IF (x_mrdv_rec.new_value = OKC_API.G_MISS_CHAR)
      THEN
        x_mrdv_rec.new_value := l_mrdv_rec.new_value;
      END IF;
      IF (x_mrdv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_mrdv_rec.object_version_number := l_mrdv_rec.object_version_number;
      END IF;
      IF (x_mrdv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_mrdv_rec.created_by := l_mrdv_rec.created_by;
      END IF;
      IF (x_mrdv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_mrdv_rec.creation_date := l_mrdv_rec.creation_date;
      END IF;
      IF (x_mrdv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_mrdv_rec.last_updated_by := l_mrdv_rec.last_updated_by;
      END IF;
      IF (x_mrdv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_mrdv_rec.last_update_date := l_mrdv_rec.last_update_date;
      END IF;
      IF (x_mrdv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_mrdv_rec.last_update_login := l_mrdv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKC_MASSCHANGE_REQ_DTLS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_mrdv_rec IN  mrdv_rec_type,
      x_mrdv_rec OUT NOCOPY mrdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_mrdv_rec := p_mrdv_rec;
      x_mrdv_rec.OBJECT_VERSION_NUMBER := NVL(x_mrdv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_mrdv_rec,                        -- IN
      l_mrdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_mrdv_rec, l_def_mrdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_mrdv_rec := fill_who_columns(l_def_mrdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_mrdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_mrdv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_mrdv_rec, l_mrd_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_mrd_rec,
      lx_mrd_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_mrd_rec, l_def_mrdv_rec);
    x_mrdv_rec := l_def_mrdv_rec;
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
  -- PL/SQL TBL update_row for:MRDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type,
    x_mrdv_tbl                     OUT NOCOPY mrdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mrdv_tbl.COUNT > 0) THEN
      i := p_mrdv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_mrdv_rec                     => p_mrdv_tbl(i),
          x_mrdv_rec                     => x_mrdv_tbl(i));
        -- store the highest degree of error
        If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	    If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
		 l_overall_status := x_return_status;
	    End If;
	End If;
        EXIT WHEN (i = p_mrdv_tbl.LAST);
        i := p_mrdv_tbl.NEXT(i);
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
  --------------------------------------------
  -- delete_row for:OKC_MASSCHANGE_REQ_DTLS --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrd_rec                      IN mrd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'DTLS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrd_rec                      mrd_rec_type:= p_mrd_rec;
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
    DELETE FROM OKC_MASSCHANGE_REQ_DTLS
     WHERE ID = l_mrd_rec.id;

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
  ----------------------------------------------
  -- delete_row for:OKC_MASSCHANGE_REQ_DTLS_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_rec                     IN mrdv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_mrdv_rec                     mrdv_rec_type := p_mrdv_rec;
    l_mrd_rec                      mrd_rec_type;
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
    migrate(l_mrdv_rec, l_mrd_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_mrd_rec
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
  -- PL/SQL TBL delete_row for:MRDV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_mrdv_tbl                     IN mrdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_mrdv_tbl.COUNT > 0) THEN
      i := p_mrdv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_mrdv_rec                     => p_mrdv_tbl(i));
        -- store the highest degree of error
	If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
	       l_overall_status := x_return_status;
	   End If;
	End If;
        EXIT WHEN (i = p_mrdv_tbl.LAST);
        i := p_mrdv_tbl.NEXT(i);
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
END OKC_MRD_PVT;

/
