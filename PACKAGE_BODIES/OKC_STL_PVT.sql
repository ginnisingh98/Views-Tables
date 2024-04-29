--------------------------------------------------------
--  DDL for Package Body OKC_STL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_STL_PVT" AS
/* $Header: OKCSSTLB.pls 120.0 2005/05/25 19:20:33 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_SUBCLASS_TOP_LINE
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_stl_rec                      IN stl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN stl_rec_type IS
    CURSOR stl_pk_csr (p_lse_id             IN NUMBER,
                       p_scs_code           IN VARCHAR2) IS
    SELECT
            LSE_ID,
            SCS_CODE,
            OBJECT_VERSION_NUMBER,
            START_DATE,
            END_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ACCESS_LEVEL
      FROM Okc_Subclass_Top_Line
     WHERE okc_subclass_top_line.lse_id = p_lse_id
       AND okc_subclass_top_line.scs_code = p_scs_code;
    l_stl_pk                       stl_pk_csr%ROWTYPE;
    l_stl_rec                      stl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN stl_pk_csr (p_stl_rec.lse_id,
                     p_stl_rec.scs_code);
    FETCH stl_pk_csr INTO
              l_stl_rec.LSE_ID,
              l_stl_rec.SCS_CODE,
              l_stl_rec.OBJECT_VERSION_NUMBER,
              l_stl_rec.START_DATE,
              l_stl_rec.END_DATE,
              l_stl_rec.CREATED_BY,
              l_stl_rec.CREATION_DATE,
              l_stl_rec.LAST_UPDATED_BY,
              l_stl_rec.LAST_UPDATE_DATE,
              l_stl_rec.LAST_UPDATE_LOGIN,
              l_stl_rec.ACCESS_LEVEL;
    x_no_data_found := stl_pk_csr%NOTFOUND;
    CLOSE stl_pk_csr;
    RETURN(l_stl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_stl_rec                      IN stl_rec_type
  ) RETURN stl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_stl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_SUBCLASS_TOP_LINE_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_stlv_rec                     IN stlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN stlv_rec_type IS
    CURSOR okc_stlv_pk_csr (p_lse_id             IN NUMBER,
                            p_scs_code           IN VARCHAR2) IS
    SELECT
            LSE_ID,
            SCS_CODE,
            START_DATE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ACCESS_LEVEL
      FROM Okc_Subclass_Top_Line_V
     WHERE okc_subclass_top_line_v.lse_id = p_lse_id
       AND okc_subclass_top_line_v.scs_code = p_scs_code;
    l_okc_stlv_pk                  okc_stlv_pk_csr%ROWTYPE;
    l_stlv_rec                     stlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_stlv_pk_csr (p_stlv_rec.lse_id,
                          p_stlv_rec.scs_code);
    FETCH okc_stlv_pk_csr INTO
              l_stlv_rec.LSE_ID,
              l_stlv_rec.SCS_CODE,
              l_stlv_rec.START_DATE,
              l_stlv_rec.END_DATE,
              l_stlv_rec.OBJECT_VERSION_NUMBER,
              l_stlv_rec.CREATED_BY,
              l_stlv_rec.CREATION_DATE,
              l_stlv_rec.LAST_UPDATED_BY,
              l_stlv_rec.LAST_UPDATE_DATE,
              l_stlv_rec.LAST_UPDATE_LOGIN,
              l_stlv_rec.ACCESS_LEVEL;
    x_no_data_found := okc_stlv_pk_csr%NOTFOUND;
    CLOSE okc_stlv_pk_csr;
    RETURN(l_stlv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_stlv_rec                     IN stlv_rec_type
  ) RETURN stlv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_stlv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_SUBCLASS_TOP_LINE_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_stlv_rec	IN stlv_rec_type
  ) RETURN stlv_rec_type IS
    l_stlv_rec	stlv_rec_type := p_stlv_rec;
  BEGIN
    IF (l_stlv_rec.lse_id = OKC_API.G_MISS_NUM) THEN
      l_stlv_rec.lse_id := NULL;
    END IF;
    IF (l_stlv_rec.scs_code = OKC_API.G_MISS_CHAR) THEN
      l_stlv_rec.scs_code := NULL;
    END IF;
    IF (l_stlv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_stlv_rec.start_date := NULL;
    END IF;
    IF (l_stlv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_stlv_rec.end_date := NULL;
    END IF;
    IF (l_stlv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_stlv_rec.object_version_number := NULL;
    END IF;
    IF (l_stlv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_stlv_rec.created_by := NULL;
    END IF;
    IF (l_stlv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_stlv_rec.creation_date := NULL;
    END IF;
    IF (l_stlv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_stlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_stlv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_stlv_rec.last_update_date := NULL;
    END IF;
    IF (l_stlv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_stlv_rec.last_update_login := NULL;
    END IF;
    IF (l_stlv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_stlv_rec.access_level := NULL;
    END IF;
    RETURN(l_stlv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_lse_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_lse_id(
    p_stlv_rec          IN stlv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_stlv_rec.lse_id = OKC_API.G_MISS_NUM OR
       p_stlv_rec.lse_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lse_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_lse_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
    p_stlv_rec          IN stlv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_stlv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_stlv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_scs_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_scs_code(
    p_stlv_rec          IN stlv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_stlv_rec.scs_code = OKC_API.G_MISS_CHAR OR
       p_stlv_rec.scs_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'scs_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_scs_code;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_start_date
  ---------------------------------------------------------------------------
  PROCEDURE validate_start_date(
    p_stlv_rec          IN stlv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_stlv_rec.start_date = OKC_API.G_MISS_DATE OR
       p_stlv_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_start_date;
  --------------------------------------------------------------------------
  -- PROCEDURE validate_access_level
  ---------------------------------------------------------------------------
  PROCEDURE validate_access_level(
    p_stlv_rec          IN stlv_rec_type,
    x_return_status  OUT NOCOPY  VARCHAR2) IS
  BEGIN
    x_return_status :=OKC_API.G_RET_STS_SUCCESS;

    IF (p_stlv_rec.access_level = OKC_API.G_MISS_CHAR OR
        p_stlv_rec.access_level IS NULL)
    THEN
       raise G_EXCEPTION_HALT_VALIDATION;
     END IF;
     IF upper(p_stlv_rec.access_level) not in ('S','E','U') Then
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                                 p_msg_name     => g_invalid_value,
                                 p_token1       => g_col_name_token,
                                 p_token1_value => 'Access Level');
          x_return_status :=OKC_API.G_RET_STS_ERROR;
      End If;
   EXCEPTION
    when  G_EXCEPTION_HALT_VALIDATION then
         null;
    when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => g_unexpected_error,
                                 p_token1       => g_sqlcode_token,
                                 p_token1_value => sqlcode,
                                 p_token2       => g_sqlerrm_token,
                                 p_token2_value => sqlerrm );
         x_return_status :=OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_access_level;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_SUBCLASS_TOP_LINE_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_stlv_rec IN  stlv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    VALIDATE_lse_id(p_stlv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_object_version_number(p_stlv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_scs_code(p_stlv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_start_date(p_stlv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    VALIDATE_access_level(p_stlv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    RETURN(x_return_status);
 EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      return(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);
  ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Ends(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_SUBCLASS_TOP_LINE_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_stlv_rec IN stlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_stlv_rec IN stlv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_scsv_pk_csr (p_code               IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Subclasses_V
       WHERE okc_subclasses_v.code = p_code;
      CURSOR okc_lsev_pk_csr (p_id                 IN NUMBER) IS
      SELECT 'x'
        FROM Okc_Line_Styles_V
       WHERE okc_line_styles_v.id = p_id;
      l_dummy                        VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_stlv_rec.SCS_CODE IS NOT NULL)
      THEN
        OPEN okc_scsv_pk_csr(p_stlv_rec.SCS_CODE);
        FETCH okc_scsv_pk_csr INTO l_dummy;
        l_row_notfound := okc_scsv_pk_csr%NOTFOUND;
        CLOSE okc_scsv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SCS_CODE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_stlv_rec.LSE_ID IS NOT NULL)
      THEN
        OPEN okc_lsev_pk_csr(p_stlv_rec.LSE_ID);
        FETCH okc_lsev_pk_csr INTO l_dummy;
        l_row_notfound := okc_lsev_pk_csr%NOTFOUND;
        CLOSE okc_lsev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LSE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    IF p_stlv_rec.start_date IS NOT NULL AND
       p_stlv_rec.end_date IS NOT NULL THEN
      IF p_stlv_rec.end_date < p_stlv_rec.start_date THEN
        OKC_API.set_message(G_APP_NAME, 'OKC_INVALID_END_DATE');
        l_return_status := OKC_API.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    l_return_status := validate_foreign_keys (p_stlv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN stlv_rec_type,
    p_to	OUT NOCOPY stl_rec_type
  ) IS
  BEGIN
    p_to.lse_id := p_from.lse_id;
    p_to.scs_code := p_from.scs_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN stl_rec_type,
    p_to	OUT NOCOPY stlv_rec_type
  ) IS
  BEGIN
    p_to.lse_id := p_from.lse_id;
    p_to.scs_code := p_from.scs_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.access_level := p_from.access_level;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKC_SUBCLASS_TOP_LINE_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stlv_rec                     stlv_rec_type := p_stlv_rec;
    l_stl_rec                      stl_rec_type;
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
    l_return_status := Validate_Attributes(l_stlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_stlv_rec);
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
  -- PL/SQL TBL validate_row for:STLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN stlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stlv_tbl.COUNT > 0) THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stlv_rec                     => p_stlv_tbl(i));
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKC_SUBCLASS_TOP_LINE --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stl_rec                      IN stl_rec_type,
    x_stl_rec                      OUT NOCOPY stl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINE_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stl_rec                      stl_rec_type := p_stl_rec;
    l_def_stl_rec                  stl_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_TOP_LINE --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_stl_rec IN  stl_rec_type,
      x_stl_rec OUT NOCOPY stl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stl_rec := p_stl_rec;
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
      p_stl_rec,                         -- IN
      l_stl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_SUBCLASS_TOP_LINE(
        lse_id,
        scs_code,
        object_version_number,
        start_date,
        end_date,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        access_level)
      VALUES (
        l_stl_rec.lse_id,
        l_stl_rec.scs_code,
        l_stl_rec.object_version_number,
        l_stl_rec.start_date,
        l_stl_rec.end_date,
        l_stl_rec.created_by,
        l_stl_rec.creation_date,
        l_stl_rec.last_updated_by,
        l_stl_rec.last_update_date,
        l_stl_rec.last_update_login,
        l_stl_rec.access_level);
    -- Set OUT values
    x_stl_rec := l_stl_rec;
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
  --------------------------------------------
  -- insert_row for:OKC_SUBCLASS_TOP_LINE_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stlv_rec                     stlv_rec_type;
    l_def_stlv_rec                 stlv_rec_type;
    l_stl_rec                      stl_rec_type;
    lx_stl_rec                     stl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_stlv_rec	IN stlv_rec_type
    ) RETURN stlv_rec_type IS
      l_stlv_rec	stlv_rec_type := p_stlv_rec;
    BEGIN
      l_stlv_rec.CREATION_DATE := SYSDATE;
      l_stlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_stlv_rec.LAST_UPDATE_DATE := l_stlv_rec.CREATION_DATE;
      l_stlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_stlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_stlv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_TOP_LINE_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_stlv_rec IN  stlv_rec_type,
      x_stlv_rec OUT NOCOPY stlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stlv_rec := p_stlv_rec;
      x_stlv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
    ------------------------------------------------------
    -- Validate_Unique_Keys for:OKC_SUBCLASS_TOP_LINE_V --
    ------------------------------------------------------
    FUNCTION validate_unique_keys (
      p_stlv_rec IN  stlv_rec_type
    ) RETURN VARCHAR2 IS
      unique_key_error          EXCEPTION;
      CURSOR c1 (p_scs_code IN okc_subclass_top_line_v.scs_code%TYPE,
                 p_lse_id   IN okc_subclass_top_line_v.lse_id%TYPE) IS
      SELECT 'x'
        FROM Okc_Subclass_Top_Line_V
       WHERE scs_code = p_scs_code
         AND lse_id = p_lse_id;
      l_dummy                VARCHAR2(1);
      l_return_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found            BOOLEAN := FALSE;
    BEGIN
      IF (p_stlv_rec.SCS_CODE IS NOT NULL AND
          p_stlv_rec.LSE_ID IS NOT NULL) THEN
        OPEN c1(p_stlv_rec.SCS_CODE,
                p_stlv_rec.LSE_ID);
        FETCH c1 INTO l_dummy;
        l_row_found := c1%FOUND;
        CLOSE c1;
        IF (l_row_found) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'SCS_CODE');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'LSE_ID');
          RAISE unique_key_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN unique_key_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_unique_keys;
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
    l_stlv_rec := null_out_defaults(p_stlv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_stlv_rec,                        -- IN
      l_def_stlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_stlv_rec := fill_who_columns(l_def_stlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_stlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_stlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Unique_Keys(l_def_stlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_stlv_rec, l_stl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stl_rec,
      lx_stl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_stl_rec, l_def_stlv_rec);
    -- Set OUT values
    x_stlv_rec := l_def_stlv_rec;
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
  -- PL/SQL TBL insert_row for:STLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stlv_tbl.COUNT > 0) THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stlv_rec                     => p_stlv_tbl(i),
          x_stlv_rec                     => x_stlv_tbl(i));
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKC_SUBCLASS_TOP_LINE --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stl_rec                      IN stl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_stl_rec IN stl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SUBCLASS_TOP_LINE
     WHERE LSE_ID = p_stl_rec.lse_id
       AND SCS_CODE = p_stl_rec.scs_code
       AND OBJECT_VERSION_NUMBER = p_stl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_stl_rec IN stl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_SUBCLASS_TOP_LINE
    WHERE LSE_ID = p_stl_rec.lse_id
       AND SCS_CODE = p_stl_rec.scs_code;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINE_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_SUBCLASS_TOP_LINE.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_SUBCLASS_TOP_LINE.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_stl_rec);
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
      OPEN lchk_csr(p_stl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_stl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_stl_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for:OKC_SUBCLASS_TOP_LINE_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stl_rec                      stl_rec_type;
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
    migrate(p_stlv_rec, l_stl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stl_rec
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
  -- PL/SQL TBL lock_row for:STLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN stlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stlv_tbl.COUNT > 0) THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stlv_rec                     => p_stlv_tbl(i));
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKC_SUBCLASS_TOP_LINE --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stl_rec                      IN stl_rec_type,
    x_stl_rec                      OUT NOCOPY stl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINE_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stl_rec                      stl_rec_type := p_stl_rec;
    l_def_stl_rec                  stl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_stl_rec	IN stl_rec_type,
      x_stl_rec	OUT NOCOPY stl_rec_type
    ) RETURN VARCHAR2 IS
      l_stl_rec                      stl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stl_rec := p_stl_rec;
      -- Get current database values
      l_stl_rec := get_rec(p_stl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_stl_rec.lse_id = OKC_API.G_MISS_NUM)
      THEN
        x_stl_rec.lse_id := l_stl_rec.lse_id;
      END IF;
      IF (x_stl_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_stl_rec.scs_code := l_stl_rec.scs_code;
      END IF;
      IF (x_stl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_stl_rec.object_version_number := l_stl_rec.object_version_number;
      END IF;
      IF (x_stl_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_stl_rec.start_date := l_stl_rec.start_date;
      END IF;
      IF (x_stl_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_stl_rec.end_date := l_stl_rec.end_date;
      END IF;
      IF (x_stl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_stl_rec.created_by := l_stl_rec.created_by;
      END IF;
      IF (x_stl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_stl_rec.creation_date := l_stl_rec.creation_date;
      END IF;
      IF (x_stl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_stl_rec.last_updated_by := l_stl_rec.last_updated_by;
      END IF;
      IF (x_stl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_stl_rec.last_update_date := l_stl_rec.last_update_date;
      END IF;
      IF (x_stl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_stl_rec.last_update_login := l_stl_rec.last_update_login;
      END IF;
      IF (x_stl_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_stl_rec.access_level := l_stl_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_TOP_LINE --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_stl_rec IN  stl_rec_type,
      x_stl_rec OUT NOCOPY stl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stl_rec := p_stl_rec;
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
      p_stl_rec,                         -- IN
      l_stl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_stl_rec, l_def_stl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_SUBCLASS_TOP_LINE
    SET OBJECT_VERSION_NUMBER = l_def_stl_rec.object_version_number,
        START_DATE = l_def_stl_rec.start_date,
        END_DATE = l_def_stl_rec.end_date,
        CREATED_BY = l_def_stl_rec.created_by,
        CREATION_DATE = l_def_stl_rec.creation_date,
        LAST_UPDATED_BY = l_def_stl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_stl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_stl_rec.last_update_login,
        ACCESS_LEVEL = l_def_stl_rec.access_level
    WHERE LSE_ID = l_def_stl_rec.lse_id
      AND SCS_CODE = l_def_stl_rec.scs_code;

    x_stl_rec := l_def_stl_rec;
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
  --------------------------------------------
  -- update_row for:OKC_SUBCLASS_TOP_LINE_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type,
    x_stlv_rec                     OUT NOCOPY stlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stlv_rec                     stlv_rec_type := p_stlv_rec;
    l_def_stlv_rec                 stlv_rec_type;
    l_stl_rec                      stl_rec_type;
    lx_stl_rec                     stl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_stlv_rec	IN stlv_rec_type
    ) RETURN stlv_rec_type IS
      l_stlv_rec	stlv_rec_type := p_stlv_rec;
    BEGIN
      l_stlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_stlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_stlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_stlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_stlv_rec	IN stlv_rec_type,
      x_stlv_rec	OUT NOCOPY stlv_rec_type
    ) RETURN VARCHAR2 IS
      l_stlv_rec                     stlv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stlv_rec := p_stlv_rec;
      -- Get current database values
      l_stlv_rec := get_rec(p_stlv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_stlv_rec.lse_id = OKC_API.G_MISS_NUM)
      THEN
        x_stlv_rec.lse_id := l_stlv_rec.lse_id;
      END IF;
      IF (x_stlv_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_stlv_rec.scs_code := l_stlv_rec.scs_code;
      END IF;
      IF (x_stlv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_stlv_rec.start_date := l_stlv_rec.start_date;
      END IF;
      IF (x_stlv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_stlv_rec.end_date := l_stlv_rec.end_date;
      END IF;
      IF (x_stlv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_stlv_rec.object_version_number := l_stlv_rec.object_version_number;
      END IF;
      IF (x_stlv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_stlv_rec.created_by := l_stlv_rec.created_by;
      END IF;
      IF (x_stlv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_stlv_rec.creation_date := l_stlv_rec.creation_date;
      END IF;
      IF (x_stlv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_stlv_rec.last_updated_by := l_stlv_rec.last_updated_by;
      END IF;
      IF (x_stlv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_stlv_rec.last_update_date := l_stlv_rec.last_update_date;
      END IF;
      IF (x_stlv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_stlv_rec.last_update_login := l_stlv_rec.last_update_login;
      END IF;
      IF (x_stlv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_stlv_rec.access_level := l_stlv_rec.access_level;
      --RETURN(l_return_status);
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_SUBCLASS_TOP_LINE_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_stlv_rec IN  stlv_rec_type,
      x_stlv_rec OUT NOCOPY stlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_stlv_rec := p_stlv_rec;
      x_stlv_rec.OBJECT_VERSION_NUMBER := NVL(x_stlv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_stlv_rec,                        -- IN
      l_stlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_stlv_rec, l_def_stlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_stlv_rec := fill_who_columns(l_def_stlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_stlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_stlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_stlv_rec, l_stl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stl_rec,
      lx_stl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_stl_rec, l_def_stlv_rec);
    x_stlv_rec := l_def_stlv_rec;
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
  -- PL/SQL TBL update_row for:STLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN stlv_tbl_type,
    x_stlv_tbl                     OUT NOCOPY stlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stlv_tbl.COUNT > 0) THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stlv_rec                     => p_stlv_tbl(i),
          x_stlv_rec                     => x_stlv_tbl(i));
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKC_SUBCLASS_TOP_LINE --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stl_rec                      IN stl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINE_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stl_rec                      stl_rec_type:= p_stl_rec;
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
    DELETE FROM OKC_SUBCLASS_TOP_LINE
     WHERE LSE_ID = l_stl_rec.lse_id AND
SCS_CODE = l_stl_rec.scs_code;

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
  --------------------------------------------
  -- delete_row for:OKC_SUBCLASS_TOP_LINE_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_rec                     IN stlv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_stlv_rec                     stlv_rec_type := p_stlv_rec;
    l_stl_rec                      stl_rec_type;
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
    migrate(l_stlv_rec, l_stl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_stl_rec
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
  -- PL/SQL TBL delete_row for:STLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_stlv_tbl                     IN stlv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_stlv_tbl.COUNT > 0) THEN
      i := p_stlv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_stlv_rec                     => p_stlv_tbl(i));
        EXIT WHEN (i = p_stlv_tbl.LAST);
        i := p_stlv_tbl.NEXT(i);
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
END OKC_STL_PVT;

/
