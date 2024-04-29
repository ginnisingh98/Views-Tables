--------------------------------------------------------
--  DDL for Package Body OKC_AAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AAL_PVT" AS
/* $Header: OKCSAALB.pls 120.0 2005/05/26 09:29:15 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
  -- FUNCTION get_rec for: OKC_ACTION_ATT_LOOKUPS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aal_rec                      IN aal_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aal_rec_type IS
    CURSOR aal_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_NAME,
            COLUMN_NAME,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Action_Att_Lookups
     WHERE okc_action_att_lookups.id = p_id;
    l_aal_pk                       aal_pk_csr%ROWTYPE;
    l_aal_rec                      aal_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN aal_pk_csr (p_aal_rec.id);
    FETCH aal_pk_csr INTO
              l_aal_rec.ID,
              l_aal_rec.OBJECT_NAME,
              l_aal_rec.COLUMN_NAME,
              l_aal_rec.OBJECT_VERSION_NUMBER,
              l_aal_rec.CREATED_BY,
              l_aal_rec.CREATION_DATE,
              l_aal_rec.LAST_UPDATED_BY,
              l_aal_rec.LAST_UPDATE_DATE,
              l_aal_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := aal_pk_csr%NOTFOUND;
    CLOSE aal_pk_csr;
    RETURN(l_aal_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aal_rec                      IN aal_rec_type
  ) RETURN aal_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aal_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ACTION_ATT_LOOKUPS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_aalv_rec                     IN aalv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN aalv_rec_type IS
    CURSOR okc_aalv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OBJECT_NAME,
            COLUMN_NAME,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Action_Att_Lookups_V
     WHERE okc_action_att_lookups_v.id = p_id;
    l_okc_aalv_pk                  okc_aalv_pk_csr%ROWTYPE;
    l_aalv_rec                     aalv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_aalv_pk_csr (p_aalv_rec.id);
    FETCH okc_aalv_pk_csr INTO
              l_aalv_rec.ID,
              l_aalv_rec.OBJECT_VERSION_NUMBER,
              l_aalv_rec.OBJECT_NAME,
              l_aalv_rec.COLUMN_NAME,
              l_aalv_rec.CREATED_BY,
              l_aalv_rec.CREATION_DATE,
              l_aalv_rec.LAST_UPDATED_BY,
              l_aalv_rec.LAST_UPDATE_DATE,
              l_aalv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_aalv_pk_csr%NOTFOUND;
    CLOSE okc_aalv_pk_csr;
    RETURN(l_aalv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_aalv_rec                     IN aalv_rec_type
  ) RETURN aalv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_aalv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_ACTION_ATT_LOOKUPS_V --
  --------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_aalv_rec	IN aalv_rec_type
  ) RETURN aalv_rec_type IS
    l_aalv_rec	aalv_rec_type := p_aalv_rec;
  BEGIN
    IF (l_aalv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_aalv_rec.object_version_number := NULL;
    END IF;
    IF (l_aalv_rec.object_name = OKC_API.G_MISS_CHAR) THEN
      l_aalv_rec.object_name := NULL;
    END IF;
    IF (l_aalv_rec.column_name = OKC_API.G_MISS_CHAR) THEN
      l_aalv_rec.column_name := NULL;
    END IF;
    IF (l_aalv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_aalv_rec.created_by := NULL;
    END IF;
    IF (l_aalv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_aalv_rec.creation_date := NULL;
    END IF;
    IF (l_aalv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_aalv_rec.last_updated_by := NULL;
    END IF;
    IF (l_aalv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_aalv_rec.last_update_date := NULL;
    END IF;
    IF (l_aalv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_aalv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_aalv_rec);
  END null_out_defaults;

  /****************** BEGIN HAND WRITTEN CODE ******************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_aalv_rec      IN   aalv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aalv_rec.object_version_number IS NULL) OR
       (p_aalv_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

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

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Name(x_return_status OUT NOCOPY  VARCHAR2
                                ,p_aalv_rec      IN   aalv_rec_type)
  IS

  CURSOR l_unq_cur(p_object_name VARCHAR2) IS
	    SELECT id FROM OKC_ACTION_ATT_LOOKUPS_V
	    WHERE object_name = p_object_name;

  l_id                    NUMBER       := OKC_API.G_MISS_NUM;
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aalv_rec.object_name IS NULL) OR
       (p_aalv_rec.object_name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_name');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

      -- check uniqueness
      -- Bug 1699203 - Removed Check_Unique
	OPEN l_unq_cur(p_aalv_rec.object_name);
	FETCH l_unq_cur INTO l_id;
	CLOSE l_unq_cur;
	IF (l_id <> OKC_API.G_MISS_NUM AND l_id <> nvl(p_aalv_rec.id,0)) THEN
	   x_return_status := OKC_API.G_RET_STS_ERROR;
	   OKC_API.SET_MESSAGE(p_app_name => G_APP_NAME,
					   p_msg_name => 'OKC_DUP_OBJECT_NAME');
     END IF;

	 /*
      OKC_UTIL.CHECK_UNIQUE(p_view_name   => 'OKC_ACTION_ATT_LOOKUPS_V'
                           ,p_col_name    => 'object_name'
                           ,p_col_value   => p_aalv_rec.object_name
                           ,p_id          => p_aalv_rec.id
                           ,x_return_status => l_return_status);


      IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
        -- halt further validation of this column
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;  */


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

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

  END Validate_Object_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Column_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Column_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Column_Name(x_return_status OUT NOCOPY  VARCHAR2
                                ,p_aalv_rec      IN   aalv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_aalv_rec.column_name IS NULL) OR
       (p_aalv_rec.column_name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'column_name');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

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

  END Validate_Column_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------------
  -- Validate_Attributes for:OKC_ACTION_ATT_LOOKUPS_V --
  ------------------------------------------------------
/* commenting out nocopy generated code in favor of hand written code
  FUNCTION Validate_Attributes (
    p_aalv_rec IN  aalv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_aalv_rec.id = OKC_API.G_MISS_NUM OR
       p_aalv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aalv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_aalv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aalv_rec.object_name = OKC_API.G_MISS_CHAR OR
          p_aalv_rec.object_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_aalv_rec.column_name = OKC_API.G_MISS_CHAR OR
          p_aalv_rec.column_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'column_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_aalv_rec IN  aalv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call each column-level validation

    -- Validate_Id
    IF p_aalv_rec.id = OKC_API.G_MISS_NUM OR
       p_aalv_rec.id IS NULL
    THEN
       OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
       l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    -- Validate Object_Version_Number
    Validate_Object_Version_Number(x_return_status,p_aalv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Object_Name
    Validate_Object_Name(x_return_status,p_aalv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    -- Validate Column_Name
    Validate_Column_Name(x_return_status,p_aalv_rec);
    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);
    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Record for:OKC_ACTION_ATT_LOOKUPS_V --
  --------------------------------------------------
  FUNCTION Validate_Record (
    p_aalv_rec IN aalv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN aalv_rec_type,
    p_to	OUT NOCOPY aal_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_name := p_from.object_name;
    p_to.column_name := p_from.column_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  --OUT parameter changed to IN OUT by Rajesh
  PROCEDURE migrate (
    p_from	IN aal_rec_type,
    p_to	IN OUT NOCOPY aalv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_name := p_from.object_name;
    p_to.column_name := p_from.column_name;
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
  -----------------------------------------------
  -- validate_row for:OKC_ACTION_ATT_LOOKUPS_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aalv_rec                     aalv_rec_type := p_aalv_rec;
    l_aal_rec                      aal_rec_type;
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
    l_return_status := Validate_Attributes(l_aalv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_aalv_rec);
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
  -- PL/SQL TBL validate_row for:AALV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aalv_tbl.COUNT > 0) THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aalv_rec                     => p_aalv_tbl(i));
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  -------------------------------------------
  -- insert_row for:OKC_ACTION_ATT_LOOKUPS --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aal_rec                      IN aal_rec_type,
    x_aal_rec                      OUT NOCOPY aal_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LOOKUPS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aal_rec                      aal_rec_type := p_aal_rec;
    l_def_aal_rec                  aal_rec_type;
    -----------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_LOOKUPS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_aal_rec IN  aal_rec_type,
      x_aal_rec OUT NOCOPY aal_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aal_rec := p_aal_rec;
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
      p_aal_rec,                         -- IN
      l_aal_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_ACTION_ATT_LOOKUPS(
        id,
        object_name,
        column_name,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_aal_rec.id,
        l_aal_rec.object_name,
        l_aal_rec.column_name,
        l_aal_rec.object_version_number,
        l_aal_rec.created_by,
        l_aal_rec.creation_date,
        l_aal_rec.last_updated_by,
        l_aal_rec.last_update_date,
        l_aal_rec.last_update_login);
    -- Set OUT values
    x_aal_rec := l_aal_rec;
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
  ---------------------------------------------
  -- insert_row for:OKC_ACTION_ATT_LOOKUPS_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type,
    x_aalv_rec                     OUT NOCOPY aalv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aalv_rec                     aalv_rec_type;
    l_def_aalv_rec                 aalv_rec_type;
    l_aal_rec                      aal_rec_type;
    lx_aal_rec                     aal_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aalv_rec	IN aalv_rec_type
    ) RETURN aalv_rec_type IS
      l_aalv_rec	aalv_rec_type := p_aalv_rec;
    BEGIN
      l_aalv_rec.CREATION_DATE := SYSDATE;
      l_aalv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_aalv_rec.LAST_UPDATE_DATE := l_aalv_rec.CREATION_DATE;
      l_aalv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aalv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aalv_rec);
    END fill_who_columns;
    -------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_LOOKUPS_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_aalv_rec IN  aalv_rec_type,
      x_aalv_rec OUT NOCOPY aalv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aalv_rec := p_aalv_rec;
      x_aalv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_aalv_rec := null_out_defaults(p_aalv_rec);
    -- Set primary key value
    l_aalv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_aalv_rec,                        -- IN
      l_def_aalv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aalv_rec := fill_who_columns(l_def_aalv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aalv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aalv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aalv_rec, l_aal_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aal_rec,
      lx_aal_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aal_rec, l_def_aalv_rec);
    -- Set OUT values
    x_aalv_rec := l_def_aalv_rec;
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
  -- PL/SQL TBL insert_row for:AALV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type,
    x_aalv_tbl                     OUT NOCOPY aalv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aalv_tbl.COUNT > 0) THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aalv_rec                     => p_aalv_tbl(i),
          x_aalv_rec                     => x_aalv_tbl(i));
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- lock_row for:OKC_ACTION_ATT_LOOKUPS --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aal_rec                      IN aal_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_aal_rec IN aal_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTION_ATT_LOOKUPS
     WHERE ID = p_aal_rec.id
       AND OBJECT_VERSION_NUMBER = p_aal_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_aal_rec IN aal_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ACTION_ATT_LOOKUPS
    WHERE ID = p_aal_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LOOKUPS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_ACTION_ATT_LOOKUPS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_ACTION_ATT_LOOKUPS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_aal_rec);
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
      OPEN lchk_csr(p_aal_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_aal_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_aal_rec.object_version_number THEN
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
  -------------------------------------------
  -- lock_row for:OKC_ACTION_ATT_LOOKUPS_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aal_rec                      aal_rec_type;
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
    migrate(p_aalv_rec, l_aal_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aal_rec
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
  -- PL/SQL TBL lock_row for:AALV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aalv_tbl.COUNT > 0) THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aalv_rec                     => p_aalv_tbl(i));
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- update_row for:OKC_ACTION_ATT_LOOKUPS --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aal_rec                      IN aal_rec_type,
    x_aal_rec                      OUT NOCOPY aal_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LOOKUPS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aal_rec                      aal_rec_type := p_aal_rec;
    l_def_aal_rec                  aal_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aal_rec	IN aal_rec_type,
      x_aal_rec	OUT NOCOPY aal_rec_type
    ) RETURN VARCHAR2 IS
      l_aal_rec                      aal_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aal_rec := p_aal_rec;
      -- Get current database values
      l_aal_rec := get_rec(p_aal_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aal_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_aal_rec.id := l_aal_rec.id;
      END IF;
      IF (x_aal_rec.object_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aal_rec.object_name := l_aal_rec.object_name;
      END IF;
      IF (x_aal_rec.column_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aal_rec.column_name := l_aal_rec.column_name;
      END IF;
      IF (x_aal_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_aal_rec.object_version_number := l_aal_rec.object_version_number;
      END IF;
      IF (x_aal_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aal_rec.created_by := l_aal_rec.created_by;
      END IF;
      IF (x_aal_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aal_rec.creation_date := l_aal_rec.creation_date;
      END IF;
      IF (x_aal_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aal_rec.last_updated_by := l_aal_rec.last_updated_by;
      END IF;
      IF (x_aal_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aal_rec.last_update_date := l_aal_rec.last_update_date;
      END IF;
      IF (x_aal_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aal_rec.last_update_login := l_aal_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_LOOKUPS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_aal_rec IN  aal_rec_type,
      x_aal_rec OUT NOCOPY aal_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aal_rec := p_aal_rec;
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
      p_aal_rec,                         -- IN
      l_aal_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aal_rec, l_def_aal_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ACTION_ATT_LOOKUPS
    SET OBJECT_NAME = l_def_aal_rec.object_name,
        COLUMN_NAME = l_def_aal_rec.column_name,
        OBJECT_VERSION_NUMBER = l_def_aal_rec.object_version_number,
        CREATED_BY = l_def_aal_rec.created_by,
        CREATION_DATE = l_def_aal_rec.creation_date,
        LAST_UPDATED_BY = l_def_aal_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_aal_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_aal_rec.last_update_login
    WHERE ID = l_def_aal_rec.id;

    x_aal_rec := l_def_aal_rec;
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
  ---------------------------------------------
  -- update_row for:OKC_ACTION_ATT_LOOKUPS_V --
  ---------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type,
    x_aalv_rec                     OUT NOCOPY aalv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aalv_rec                     aalv_rec_type := p_aalv_rec;
    l_def_aalv_rec                 aalv_rec_type;
    l_aal_rec                      aal_rec_type;
    lx_aal_rec                     aal_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_aalv_rec	IN aalv_rec_type
    ) RETURN aalv_rec_type IS
      l_aalv_rec	aalv_rec_type := p_aalv_rec;
    BEGIN
      l_aalv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_aalv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_aalv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_aalv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_aalv_rec	IN aalv_rec_type,
      x_aalv_rec	OUT NOCOPY aalv_rec_type
    ) RETURN VARCHAR2 IS
      l_aalv_rec                     aalv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aalv_rec := p_aalv_rec;
      -- Get current database values
      l_aalv_rec := get_rec(p_aalv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_aalv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_aalv_rec.id := l_aalv_rec.id;
      END IF;
      IF (x_aalv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_aalv_rec.object_version_number := l_aalv_rec.object_version_number;
      END IF;
      IF (x_aalv_rec.object_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aalv_rec.object_name := l_aalv_rec.object_name;
      END IF;
      IF (x_aalv_rec.column_name = OKC_API.G_MISS_CHAR)
      THEN
        x_aalv_rec.column_name := l_aalv_rec.column_name;
      END IF;
      IF (x_aalv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_aalv_rec.created_by := l_aalv_rec.created_by;
      END IF;
      IF (x_aalv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_aalv_rec.creation_date := l_aalv_rec.creation_date;
      END IF;
      IF (x_aalv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_aalv_rec.last_updated_by := l_aalv_rec.last_updated_by;
      END IF;
      IF (x_aalv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_aalv_rec.last_update_date := l_aalv_rec.last_update_date;
      END IF;
      IF (x_aalv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_aalv_rec.last_update_login := l_aalv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKC_ACTION_ATT_LOOKUPS_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_aalv_rec IN  aalv_rec_type,
      x_aalv_rec OUT NOCOPY aalv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_aalv_rec := p_aalv_rec;
      x_aalv_rec.OBJECT_VERSION_NUMBER := NVL(x_aalv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_aalv_rec,                        -- IN
      l_aalv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_aalv_rec, l_def_aalv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_aalv_rec := fill_who_columns(l_def_aalv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_aalv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_aalv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_aalv_rec, l_aal_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aal_rec,
      lx_aal_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_aal_rec, l_def_aalv_rec);
    x_aalv_rec := l_def_aalv_rec;
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
  -- PL/SQL TBL update_row for:AALV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type,
    x_aalv_tbl                     OUT NOCOPY aalv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aalv_tbl.COUNT > 0) THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aalv_rec                     => p_aalv_tbl(i),
          x_aalv_rec                     => x_aalv_tbl(i));
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  -------------------------------------------
  -- delete_row for:OKC_ACTION_ATT_LOOKUPS --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aal_rec                      IN aal_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LOOKUPS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aal_rec                      aal_rec_type:= p_aal_rec;
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
    DELETE FROM OKC_ACTION_ATT_LOOKUPS
     WHERE ID = l_aal_rec.id;

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
  ---------------------------------------------
  -- delete_row for:OKC_ACTION_ATT_LOOKUPS_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_rec                     IN aalv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_aalv_rec                     aalv_rec_type := p_aalv_rec;
    l_aal_rec                      aal_rec_type;
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
    migrate(l_aalv_rec, l_aal_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_aal_rec
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
  -- PL/SQL TBL delete_row for:AALV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_aalv_tbl                     IN aalv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_aalv_tbl.COUNT > 0) THEN
      i := p_aalv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_aalv_rec                     => p_aalv_tbl(i));
        EXIT WHEN (i = p_aalv_tbl.LAST);
        i := p_aalv_tbl.NEXT(i);
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
  END delete_row;
END OKC_AAL_PVT;

/
