--------------------------------------------------------
--  DDL for Package Body OKC_CVM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CVM_PVT" AS
/* $Header: OKCSCVMB.pls 120.2 2006/05/24 23:06:54 tweichen noship $ */

  l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  --bugfix 5243626
  g_defer_min_vers_upd VARCHAR2(1) := FND_API.G_FALSE;


  /************************ HAND-CODED *********************************/
  FUNCTION Validate_Attributes ( p_cvmv_rec IN  cvmv_rec_type)
		RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_EXCEPTION_HALT_VALIDATION	exception;
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_NO_VERSOIN_RECORD CONSTANT VARCHAR2(200) := 'OKC_NO_VERSOIN_RECORD';
  G_NULL_CHR_ID	 CONSTANT VARCHAR2(200) := 'OKC_NULL_CHR_ID';

  -- Global transaction id
  -- g_trans_id   VARCHAR2(100) := 'XXX';
  /************************ HAND-CODED ENDS ****************************/

  -- Validate Coulumn procedures

  -- Start of comments
  --
  -- Procedure Name  : validate_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_cvmv_rec      IN    cvmv_rec_type) is

  l_dummy_var   VARCHAR2(1) := '?';
  Cursor l_chrv_csr Is
  		select 'x'
  		from OKC_K_HEADERS_ALL_B -- Modified by Jvorugan for Bug:4645341 okc_k_headers_b
  		where ID = p_cvmv_rec.chr_id;
  Begin
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_cvmv_rec.chr_id = OKC_API.G_MISS_NUM or
  	   p_cvmv_rec.chr_id IS NULL)
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
					  p_token2_value	=> 'OKC_K_HEADERS_V',
					  p_token3		=> g_parent_table_token,
					  p_token3_value	=> 'OKC_K_HEADERS_V');

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
        if l_chrv_csr%ISOPEN then
	      close l_chrv_csr;
        end if;

  End validate_chr_id;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_VERS_NUMBERS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cvm_rec                      IN cvm_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cvm_rec_type IS
    CURSOR cvm_pk_csr (p_chr_id             IN NUMBER) IS
    SELECT
            CHR_ID,
            MAJOR_VERSION,
            MINOR_VERSION,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Vers_Numbers
     WHERE okc_k_vers_numbers.chr_id = p_chr_id;
    l_cvm_pk                       cvm_pk_csr%ROWTYPE;
    l_cvm_rec                      cvm_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cvm_pk_csr (p_cvm_rec.chr_id);
    FETCH cvm_pk_csr INTO
              l_cvm_rec.CHR_ID,
              l_cvm_rec.MAJOR_VERSION,
              l_cvm_rec.MINOR_VERSION,
              l_cvm_rec.OBJECT_VERSION_NUMBER,
              l_cvm_rec.CREATED_BY,
              l_cvm_rec.CREATION_DATE,
              l_cvm_rec.LAST_UPDATED_BY,
              l_cvm_rec.LAST_UPDATE_DATE,
              l_cvm_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cvm_pk_csr%NOTFOUND;
    CLOSE cvm_pk_csr;
    RETURN(l_cvm_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cvm_rec                      IN cvm_rec_type
  ) RETURN cvm_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cvm_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_VERS_NUMBERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cvmv_rec                     IN cvmv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cvmv_rec_type IS
    CURSOR okc_cvmv_pk_csr (p_chr_id             IN NUMBER) IS
    SELECT
            CHR_ID,
            OBJECT_VERSION_NUMBER,
            MAJOR_VERSION,
            MINOR_VERSION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Vers_Numbers_V
     WHERE okc_k_vers_numbers_v.chr_id = p_chr_id;
    l_okc_cvmv_pk                  okc_cvmv_pk_csr%ROWTYPE;
    l_cvmv_rec                     cvmv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cvmv_pk_csr (p_cvmv_rec.chr_id);
    FETCH okc_cvmv_pk_csr INTO
              l_cvmv_rec.CHR_ID,
              l_cvmv_rec.OBJECT_VERSION_NUMBER,
              l_cvmv_rec.MAJOR_VERSION,
              l_cvmv_rec.MINOR_VERSION,
              l_cvmv_rec.CREATED_BY,
              l_cvmv_rec.CREATION_DATE,
              l_cvmv_rec.LAST_UPDATED_BY,
              l_cvmv_rec.LAST_UPDATE_DATE,
              l_cvmv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cvmv_pk_csr%NOTFOUND;
    CLOSE okc_cvmv_pk_csr;
    RETURN(l_cvmv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cvmv_rec                     IN cvmv_rec_type
  ) RETURN cvmv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cvmv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_VERS_NUMBERS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cvmv_rec	IN cvmv_rec_type
  ) RETURN cvmv_rec_type IS
    l_cvmv_rec	cvmv_rec_type := p_cvmv_rec;
  BEGIN
    IF (l_cvmv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_cvmv_rec.chr_id := NULL;
    END IF;
    IF (l_cvmv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cvmv_rec.object_version_number := NULL;
    END IF;
    IF (l_cvmv_rec.major_version = OKC_API.G_MISS_NUM) THEN
      l_cvmv_rec.major_version := NULL;
    END IF;
    IF (l_cvmv_rec.minor_version = OKC_API.G_MISS_NUM) THEN
      l_cvmv_rec.minor_version := NULL;
    END IF;
    IF (l_cvmv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cvmv_rec.created_by := NULL;
    END IF;
    IF (l_cvmv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cvmv_rec.creation_date := NULL;
    END IF;
    IF (l_cvmv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cvmv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cvmv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cvmv_rec.last_update_date := NULL;
    END IF;
    IF (l_cvmv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cvmv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cvmv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKC_K_VERS_NUMBERS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cvmv_rec IN  cvmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    validate_chr_id (x_return_status    => l_return_status,
				 p_cvmv_rec         => p_cvmv_rec);
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKC_K_VERS_NUMBERS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_cvmv_rec IN cvmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cvmv_rec_type,
    p_to	OUT NOCOPY cvm_rec_type
  ) IS
  BEGIN
    p_to.chr_id := p_from.chr_id;
    p_to.major_version := p_from.major_version;
    p_to.minor_version := p_from.minor_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cvm_rec_type,
    p_to	OUT NOCOPY cvmv_rec_type
  ) IS
  BEGIN
    p_to.chr_id := p_from.chr_id;
    p_to.major_version := p_from.major_version;
    p_to.minor_version := p_from.minor_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cvm_rec_type,
    p_to	OUT NOCOPY okc_k_vers_numbers_h_rec_type
  ) IS
  BEGIN
    p_to.chr_id := p_from.chr_id;
    p_to.major_version := p_from.major_version;
    p_to.minor_version := p_from.minor_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- insert_row for:OKC_K_VERS_NUMBERS_H --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_k_vers_numbers_h_rec     IN okc_k_vers_numbers_h_rec_type,
    x_okc_k_vers_numbers_h_rec     OUT NOCOPY okc_k_vers_numbers_h_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'H_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_k_vers_numbers_h_rec     okc_k_vers_numbers_h_rec_type := p_okc_k_vers_numbers_h_rec;
    ldefokckversnumbershrec        okc_k_vers_numbers_h_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_VERS_NUMBERS_H --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_k_vers_numbers_h_rec IN  okc_k_vers_numbers_h_rec_type,
      x_okc_k_vers_numbers_h_rec OUT NOCOPY okc_k_vers_numbers_h_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_k_vers_numbers_h_rec := p_okc_k_vers_numbers_h_rec;
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
      p_okc_k_vers_numbers_h_rec,        -- IN
      l_okc_k_vers_numbers_h_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_VERS_NUMBERS_H(
        chr_id,
        major_version,
        minor_version,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okc_k_vers_numbers_h_rec.chr_id,
        l_okc_k_vers_numbers_h_rec.major_version,
        l_okc_k_vers_numbers_h_rec.minor_version,
        l_okc_k_vers_numbers_h_rec.object_version_number,
        l_okc_k_vers_numbers_h_rec.created_by,
        l_okc_k_vers_numbers_h_rec.creation_date,
        l_okc_k_vers_numbers_h_rec.last_updated_by,
        l_okc_k_vers_numbers_h_rec.last_update_date,
        l_okc_k_vers_numbers_h_rec.last_update_login);
    -- Set OUT values
    x_okc_k_vers_numbers_h_rec := l_okc_k_vers_numbers_h_rec;
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
      --
      -- If another user is updating the contract, this will cause
      -- unique constrained violation on this table (SQLCODE = -1)
      --
      If SQLCODE = -1 Then
         x_return_status := OKC_API.G_RET_STS_ERROR;
         OKC_API.set_message(G_APP_NAME,'OKC_OP_FAILED');
      Else
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
      End If;
  END insert_row;
  ---------------------------------------
  -- insert_row for:OKC_K_VERS_NUMBERS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvm_rec                      IN cvm_rec_type,
    x_cvm_rec                      OUT NOCOPY cvm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'NUMBERS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvm_rec                      cvm_rec_type := p_cvm_rec;
    l_def_cvm_rec                  cvm_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKC_K_VERS_NUMBERS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_cvm_rec IN  cvm_rec_type,
      x_cvm_rec OUT NOCOPY cvm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvm_rec := p_cvm_rec;
      x_cvm_rec.MAJOR_VERSION := 0;
      x_cvm_rec.MINOR_VERSION := 0;
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
      p_cvm_rec,                         -- IN
      l_cvm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_VERS_NUMBERS(
        chr_id,
        major_version,
        minor_version,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_cvm_rec.chr_id,
        l_cvm_rec.major_version,
        l_cvm_rec.minor_version,
        l_cvm_rec.object_version_number,
        l_cvm_rec.created_by,
        l_cvm_rec.creation_date,
        l_cvm_rec.last_updated_by,
        l_cvm_rec.last_update_date,
        l_cvm_rec.last_update_login);
    -- Set OUT values
    x_cvm_rec := l_cvm_rec;
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
  -----------------------------------------
  -- insert_row for:OKC_K_VERS_NUMBERS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvmv_rec                     cvmv_rec_type;
    l_def_cvmv_rec                 cvmv_rec_type;
    l_cvm_rec                      cvm_rec_type;
    lx_cvm_rec                     cvm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cvmv_rec	IN cvmv_rec_type
    ) RETURN cvmv_rec_type IS
      l_cvmv_rec	cvmv_rec_type := p_cvmv_rec;
    BEGIN
      l_cvmv_rec.CREATION_DATE := SYSDATE;
      l_cvmv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cvmv_rec.LAST_UPDATE_DATE := l_cvmv_rec.CREATION_DATE;
      l_cvmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cvmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cvmv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_VERS_NUMBERS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cvmv_rec IN  cvmv_rec_type,
      x_cvmv_rec OUT NOCOPY cvmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvmv_rec := p_cvmv_rec;
      x_cvmv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cvmv_rec := null_out_defaults(p_cvmv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cvmv_rec,                        -- IN
      l_def_cvmv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cvmv_rec := fill_who_columns(l_def_cvmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    ---l_return_status := Validate_Attributes(l_def_cvmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cvmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cvmv_rec, l_cvm_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cvm_rec,
      lx_cvm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cvm_rec, l_def_cvmv_rec);
    -- Set OUT values
    x_cvmv_rec := l_def_cvmv_rec;
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

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- lock_row for:OKC_K_VERS_NUMBERS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvm_rec                      IN cvm_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cvm_rec IN cvm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_VERS_NUMBERS
     WHERE CHR_ID = p_cvm_rec.chr_id
       AND OBJECT_VERSION_NUMBER IN (p_cvm_rec.object_version_number,
							  OKC_API.G_MISS_NUM)
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cvm_rec IN cvm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_VERS_NUMBERS
    WHERE CHR_ID = p_cvm_rec.chr_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'NUMBERS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_VERS_NUMBERS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_VERS_NUMBERS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cvm_rec);
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
      OPEN lchk_csr(p_cvm_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cvm_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cvm_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKC_K_VERS_NUMBERS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvm_rec                      cvm_rec_type;
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
    migrate(p_cvmv_rec, l_cvm_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cvm_rec
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
  -- PL/SQL TBL lock_row for:CVMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_tbl                     IN cvmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cvmv_tbl.COUNT > 0) THEN
      i := p_cvmv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cvmv_rec                     => p_cvmv_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_cvmv_tbl.LAST);
        i := p_cvmv_tbl.NEXT(i);
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
  ---------------------------------------
  -- update_row for:OKC_K_VERS_NUMBERS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvm_rec                      IN cvm_rec_type,
    x_cvm_rec                      OUT NOCOPY cvm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'NUMBERS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvm_rec                      cvm_rec_type := p_cvm_rec;
    l_def_cvm_rec                  cvm_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_okc_k_vers_numbers_h_rec     okc_k_vers_numbers_h_rec_type;
    lx_okc_k_vers_numbers_h_rec    okc_k_vers_numbers_h_rec_type;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cvm_rec	IN cvm_rec_type,
      x_cvm_rec	OUT NOCOPY cvm_rec_type
    ) RETURN VARCHAR2 IS
      l_cvm_rec                      cvm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvm_rec := p_cvm_rec;
      -- Get current database values
      l_cvm_rec := get_rec(p_cvm_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      -- Move the "old" record to the history record:
      -- (1) to get the "old" version
      -- (2) to avoid 2 hits to the database
      migrate(l_cvm_rec, l_okc_k_vers_numbers_h_rec);
      IF (x_cvm_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cvm_rec.chr_id := l_cvm_rec.chr_id;
      END IF;
      IF (x_cvm_rec.major_version = OKC_API.G_MISS_NUM)
      THEN
        x_cvm_rec.major_version := l_cvm_rec.major_version;
      END IF;
      IF (x_cvm_rec.minor_version = OKC_API.G_MISS_NUM)
      THEN
        x_cvm_rec.minor_version := l_cvm_rec.minor_version;
      END IF;
      IF (x_cvm_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cvm_rec.object_version_number := l_cvm_rec.object_version_number;
      END IF;
      IF (x_cvm_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cvm_rec.created_by := l_cvm_rec.created_by;
      END IF;
      IF (x_cvm_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cvm_rec.creation_date := l_cvm_rec.creation_date;
      END IF;
      IF (x_cvm_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cvm_rec.last_updated_by := l_cvm_rec.last_updated_by;
      END IF;
      IF (x_cvm_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cvm_rec.last_update_date := l_cvm_rec.last_update_date;
      END IF;
      IF (x_cvm_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cvm_rec.last_update_login := l_cvm_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_K_VERS_NUMBERS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_cvm_rec IN  cvm_rec_type,
      x_cvm_rec OUT NOCOPY cvm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvm_rec := p_cvm_rec;
      x_cvm_rec.MINOR_VERSION := NVL(x_cvm_rec.MINOR_VERSION, -1) + 1;
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
    /*
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cvm_rec,                         -- IN
      l_cvm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    */
    l_return_status := populate_new_record(p_cvm_rec, l_cvm_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cvm_rec,                         -- IN
      l_def_cvm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKC_K_VERS_NUMBERS
    SET MAJOR_VERSION = l_def_cvm_rec.major_version,
        MINOR_VERSION = l_def_cvm_rec.minor_version,
        OBJECT_VERSION_NUMBER = l_def_cvm_rec.object_version_number,
        CREATED_BY = l_def_cvm_rec.created_by,
        CREATION_DATE = l_def_cvm_rec.creation_date,
        LAST_UPDATED_BY = l_def_cvm_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cvm_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cvm_rec.last_update_login
    WHERE CHR_ID = l_def_cvm_rec.chr_id;

    -- Insert into History table
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_vers_numbers_h_rec,
      lx_okc_k_vers_numbers_h_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_cvm_rec := l_def_cvm_rec;
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
  -----------------------------------------
  -- update_row for:OKC_K_VERS_NUMBERS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvmv_rec                     cvmv_rec_type := p_cvmv_rec;
    l_def_cvmv_rec                 cvmv_rec_type;
    l_cvm_rec                      cvm_rec_type;
    lx_cvm_rec                     cvm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cvmv_rec	IN cvmv_rec_type
    ) RETURN cvmv_rec_type IS
      l_cvmv_rec	cvmv_rec_type := p_cvmv_rec;
    BEGIN
      l_cvmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cvmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cvmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cvmv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cvmv_rec	IN cvmv_rec_type,
      x_cvmv_rec	OUT NOCOPY cvmv_rec_type
    ) RETURN VARCHAR2 IS
      l_cvmv_rec                     cvmv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvmv_rec := p_cvmv_rec;
      -- Get current database values
      l_cvmv_rec := get_rec(p_cvmv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cvmv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cvmv_rec.chr_id := l_cvmv_rec.chr_id;
      END IF;
      IF (x_cvmv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cvmv_rec.object_version_number := l_cvmv_rec.object_version_number;
      END IF;
      IF (x_cvmv_rec.major_version = OKC_API.G_MISS_NUM)
      THEN
        x_cvmv_rec.major_version := l_cvmv_rec.major_version;
      END IF;
      IF (x_cvmv_rec.minor_version = OKC_API.G_MISS_NUM)
      THEN
        x_cvmv_rec.minor_version := l_cvmv_rec.minor_version;
      END IF;
      IF (x_cvmv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cvmv_rec.created_by := l_cvmv_rec.created_by;
      END IF;
      IF (x_cvmv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cvmv_rec.creation_date := l_cvmv_rec.creation_date;
      END IF;
      IF (x_cvmv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cvmv_rec.last_updated_by := l_cvmv_rec.last_updated_by;
      END IF;
      IF (x_cvmv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cvmv_rec.last_update_date := l_cvmv_rec.last_update_date;
      END IF;
      IF (x_cvmv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cvmv_rec.last_update_login := l_cvmv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_VERS_NUMBERS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cvmv_rec IN  cvmv_rec_type,
      x_cvmv_rec OUT NOCOPY cvmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cvmv_rec := p_cvmv_rec;
      x_cvmv_rec.OBJECT_VERSION_NUMBER := NVL(x_cvmv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    /*
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_cvmv_rec,                        -- IN
      l_cvmv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    */
    l_return_status := populate_new_record(p_cvmv_rec, l_cvmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cvmv_rec,                        -- IN
      l_def_cvmv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_cvmv_rec := fill_who_columns(l_def_cvmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cvmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cvmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cvmv_rec, l_cvm_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cvm_rec,
      lx_cvm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cvm_rec, l_def_cvmv_rec);
    x_cvmv_rec := l_def_cvmv_rec;
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

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- delete_row for:OKC_K_VERS_NUMBERS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvm_rec                      IN cvm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'NUMBERS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvm_rec                      cvm_rec_type:= p_cvm_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    l_okc_k_vers_numbers_h_rec     okc_k_vers_numbers_h_rec_type;
    lx_okc_k_vers_numbers_h_rec    okc_k_vers_numbers_h_rec_type;
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
    -- Insert into History table
    l_cvm_rec := get_rec(l_cvm_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    migrate(l_cvm_rec, l_okc_k_vers_numbers_h_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_k_vers_numbers_h_rec,
      lx_okc_k_vers_numbers_h_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_K_VERS_NUMBERS
     WHERE CHR_ID = l_cvm_rec.chr_id;

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
  -----------------------------------------
  -- delete_row for:OKC_K_VERS_NUMBERS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cvmv_rec                     cvmv_rec_type := p_cvmv_rec;
    l_cvm_rec                      cvm_rec_type;
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
    migrate(l_cvmv_rec, l_cvm_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cvm_rec
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

  PROCEDURE create_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type) IS
  BEGIN
    OKC_CVM_PVT.insert_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_cvmv_rec,
    		x_cvmv_rec);

  END create_contract_version;


  PROCEDURE update_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type) IS

	v_trans_id VARCHAR2(100);
	l_cvmv_rec OKC_CVM_PVT.cvmv_rec_type;
  BEGIN
        IF (l_debug = 'Y') THEN
             okc_debug.Set_Indentation('OKC_CVM_PVT');
   	     okc_debug.log('1000: Entered update_contract_version, g_defer_min_vers_upd='||g_defer_min_vers_upd, 2);
        END IF;

	x_return_status := OKC_API.G_RET_STS_SUCCESS;

        --bug 5218723, if minor version update is deferred, donot update
        IF (g_defer_min_vers_upd = FND_API.G_TRUE) THEN
           return;
        END IF;

	-- get id of local transaction
	v_trans_id := dbms_transaction.local_transaction_id(TRUE);

	-- v_trans_id will be null if no transaction.  In that case, do nothing
	--
	-- If v_trans_id = g_trans_id, then this routine has been called before
	-- from this transaction.  In that case, do nothing
	--
	-- All other cases, set g_trans_id to the current transaction id and
	-- update the contract version number

	IF v_trans_id IS NOT NULL AND v_trans_id <> g_trans_id THEN
	   -- save current transaction id
	   g_trans_id := v_trans_id;
	   l_cvmv_rec := p_cvmv_rec;
	   l_cvmv_rec.major_version := OKC_API.G_MISS_NUM;
	   -- Major version update is not allowed

	   -- update contract version number
	   OKC_CVM_PVT.update_row(
    			p_api_version,
    			p_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			l_cvmv_rec,
    			x_cvmv_rec);
	END IF;
  EXCEPTION
	WHEN OTHERS THEN
		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  	     OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
					     p_msg_name	=> g_unexpected_error,
					     p_token1		=> g_sqlcode_token,
					     p_token1_value	=> sqlcode,
					     p_token2		=> g_sqlerrm_token,
					     p_token2_value	=> sqlerrm);
  END update_contract_version;

  PROCEDURE version_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type,
    x_cvmv_rec                     OUT NOCOPY cvmv_rec_type) IS

	l_cvmv_rec OKC_CVM_PVT.cvmv_rec_type;
	l_major_version NUMBER;
	l_not_found BOOLEAN := FALSE;

	Cursor l_cvmv_csr(p_chr_id NUMBER) Is
		SELECT major_version
		FROM OKC_K_VERS_NUMBERS_V
		WHERE chr_id = p_chr_id;
  BEGIN

    l_cvmv_rec := p_cvmv_rec;
    open l_cvmv_csr(l_cvmv_rec.chr_id);
    fetch l_cvmv_csr into l_major_version;
    l_not_found := l_cvmv_csr%NOTFOUND;
    close l_cvmv_csr;
    If (l_not_found) Then
  	  OKC_API.SET_MESSAGE(
		    p_app_name		=> g_app_name,
		    p_msg_name		=> 'G_NO_VERSOIN_RECORD');
	    -- notify caller of an error
         x_return_status := OKC_API.G_RET_STS_ERROR;
    Else
       --
	  -- Increment major_version and set minor_version to -1.
	  -- -1 increments in simple API to zero
	  --
	  l_cvmv_rec.major_version := l_major_version + 1;
	  l_cvmv_rec.minor_version := -1;

       OKC_CVM_PVT.update_row(
    			p_api_version,
    			p_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			l_cvmv_rec,
    			x_cvmv_rec);
    End If;

  EXCEPTION
	WHEN OTHERS THEN
	  NULL;

  END version_contract_version;

  PROCEDURE delete_contract_version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cvmv_rec                     IN cvmv_rec_type) IS
  BEGIN

    OKC_CVM_PVT.delete_row(
    		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_cvmv_rec);

  END delete_contract_version;

  PROCEDURE clear_g_transaction_id IS    --added for bug 3658108
  BEGIN

     g_trans_id:='XXX';

  END clear_g_transaction_id;


  PROCEDURE defer_minor_version_update
  (
   p_defer IN VARCHAR2 DEFAULT FND_API.G_FALSE
  )
  IS
  BEGIN

        IF (l_debug = 'Y') THEN
            okc_debug.Set_Indentation('OKC_CVM_PVT');
            okc_debug.log('8000: Entered defer_minor_version_update, p_defer='||p_defer||' ,g_defer_min_vers_upd='||g_defer_min_vers_upd, 2);
        END IF;

        IF (FND_API.G_TRUE = p_defer) THEN
            g_defer_min_vers_upd := FND_API.G_TRUE;
        ELSE
            g_defer_min_vers_upd := FND_API.G_FALSE;
        END IF;

        IF (l_debug = 'Y') THEN
            okc_debug.log('8100: Leaving defer_minor_version_update,  ,g_defer_min_vers_upd='||g_defer_min_vers_upd, 2);
            okc_debug.Reset_Indentation;
        END IF;

  END defer_minor_version_update;

  FUNCTION Update_Minor_Version(p_chr_id IN NUMBER) RETURN VARCHAR2 Is
	l_api_version                 NUMBER := 1;
	l_init_msg_list               VARCHAR2(1) := 'F';
	x_return_status               VARCHAR2(1);
	x_msg_count                   NUMBER;
	x_msg_data                    VARCHAR2(2000);
	x_out_rec                     OKC_CVM_PVT.cvmv_rec_type;
	l_cvmv_rec                    OKC_CVM_PVT.cvmv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.Set_Indentation('OKC_CVM_PVT');
        okc_debug.log('9000: Entered Update_Minor_Version(p_chr_id), p_chr_id='||p_chr_id, 2);
    END IF;

	-- initialize return status
	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	-- assign/populate contract header id
	l_cvmv_rec.chr_id := p_chr_id;

	OKC_CVM_PVT.update_contract_version(
		p_api_version    => l_api_version,
		p_init_msg_list  => l_init_msg_list,
		x_return_status  => x_return_status,
		x_msg_count      => x_msg_count,
		x_msg_data       => x_msg_data,
		p_cvmv_rec       => l_cvmv_rec,
		x_cvmv_rec       => x_out_rec);

    IF (l_debug = 'Y') THEN
        okc_debug.log('9100: Leaving Update_Minor_Version(p_chr_id), x_return_status='||x_return_status, 2);
        okc_debug.Reset_Indentation;
    END IF;

	return (x_return_status);
  EXCEPTION
    when OTHERS then
	   -- notify caller of an error
	   x_return_status := OKC_API.G_RET_STS_ERROR;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);

        IF (l_debug = 'Y') THEN
            okc_debug.log('9200: Leaving Update_Minor_Version(p_chr_id):other_error: x_return_status='||x_return_status, 2);
            okc_debug.Reset_Indentation;
        END IF;

	    return (x_return_status);

  END Update_Minor_Version;


END OKC_CVM_PVT;

/
