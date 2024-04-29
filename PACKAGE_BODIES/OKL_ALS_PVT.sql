--------------------------------------------------------
--  DDL for Package Body OKL_ALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ALS_PVT" AS
/* $Header: OKLSALSB.pls 120.4 2007/02/27 07:03:13 dpsingh noship $ */

  G_EXCEPTION_HALT_VALIDATION EXCEPTION;
  G_ITEM_NOT_FOUND_ERROR	EXCEPTION;


---------------------------------------------------------------------------
-- PROCEDURE Validate_Unique_ALS_Record
---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_ALS_Record(x_return_status OUT NOCOPY     VARCHAR2
                                      ,p_ALSv_rec      IN      ALSv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := okl_api.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_ALSv_status           VARCHAR2(1);
  l_start_date            DATE;
  l_end_date              DATE;
  l_dummy                 VARCHAR2(1);
  l_row_found             BOOLEAN := TRUE;

    CURSOR l_unique_csr
    IS
    SELECT '1'
    FROM OKL_AG_SOURCE_MAPS
    WHERE ae_line_type    = p_alsv_rec.ae_line_type
    AND   source = p_alsv_rec.source
    AND   ID <> p_alsv_rec.id;

    BEGIN
      OPEN l_unique_csr ;
      FETCH l_unique_csr INTO l_dummy ;
         l_row_found := l_unique_csr%FOUND;
        CLOSE l_unique_csr;

     IF (l_row_found) THEN
        okl_api.set_message('OKL',G_OKL_ENTITY_NOT_UNIQUE, 'ENTITY_NAME', 'Account Generator Source');
        l_return_status := okl_api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
     x_return_status := l_return_status;

    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
         x_return_status := l_return_status;
    WHEN OTHERS THEN
      okl_api.set_message(G_APP_NAME,G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      x_return_status := okl_api.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_ALS_Record;


  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
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
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AG_SOURCE_MAPS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ALS_rec                      IN ALS_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ALS_rec_type IS
    CURSOR OKL_AG_SOURCE_MAPS_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            AE_LINE_TYPE,
            SOURCE,
            PRIMARY_KEY_COLUMN,
            SELECT_COLUMN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_AG_SOURCE_MAPS
     WHERE OKL_AG_SOURCE_MAPS.id  = p_id;
    l_OKL_AG_SOURCE_MAPS_pk          OKL_AG_SOURCE_MAPS_pk_csr%ROWTYPE;
    l_ALS_rec                      ALS_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKL_AG_SOURCE_MAPS_pk_csr (p_ALS_rec.id);
    FETCH OKL_AG_SOURCE_MAPS_pk_csr INTO
              l_ALS_rec.ID,
              l_ALS_rec.OBJECT_VERSION_NUMBER,
              l_ALS_rec.ORG_ID,
              l_ALS_rec.AE_LINE_TYPE,
              l_ALS_rec.SOURCE,
              l_ALS_rec.PRIMARY_KEY_COLUMN,
              l_ALS_rec.SELECT_COLUMN,
              l_ALS_rec.CREATED_BY,
              l_ALS_rec.CREATION_DATE,
              l_ALS_rec.LAST_UPDATED_BY,
              l_ALS_rec.LAST_UPDATE_DATE,
              l_ALS_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := OKL_AG_SOURCE_MAPS_pk_csr%NOTFOUND;
    CLOSE OKL_AG_SOURCE_MAPS_pk_csr;
    RETURN(l_ALS_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ALS_rec                      IN ALS_rec_type
  ) RETURN ALS_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ALS_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_AG_SOURCE_MAPS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ALSv_rec                     IN ALSv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ALSv_rec_type IS
    CURSOR okl_ALSv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            AE_LINE_TYPE,
            SOURCE,
            PRIMARY_KEY_COLUMN,
            SELECT_COLUMN,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_AG_SOURCE_MAPS
     WHERE OKL_AG_SOURCE_MAPS.id = p_id;
    l_okl_ALSv_pk                  okl_ALSv_pk_csr%ROWTYPE;
    l_ALSv_rec                     ALSv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ALSv_pk_csr (p_ALSv_rec.id);
    FETCH okl_ALSv_pk_csr INTO
              l_ALSv_rec.ID,
              l_ALSv_rec.OBJECT_VERSION_NUMBER,
              l_ALSv_rec.AE_LINE_TYPE,
              l_ALSv_rec.SOURCE,
              l_ALSv_rec.PRIMARY_KEY_COLUMN,
              l_ALSv_rec.SELECT_COLUMN,
              l_ALSv_rec.ORG_ID,
              l_ALSv_rec.CREATED_BY,
              l_ALSv_rec.CREATION_DATE,
              l_ALSv_rec.LAST_UPDATED_BY,
              l_ALSv_rec.LAST_UPDATE_DATE,
              l_ALSv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ALSv_pk_csr%NOTFOUND;
    CLOSE okl_ALSv_pk_csr;
    RETURN(l_ALSv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ALSv_rec                     IN ALSv_rec_type
  ) RETURN ALSv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ALSv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_AG_SOURCE_MAPS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ALSv_rec	IN ALSv_rec_type
  ) RETURN ALSv_rec_type IS
    l_ALSv_rec	ALSv_rec_type := p_ALSv_rec;
  BEGIN
    IF (l_ALSv_rec.object_version_number = okl_api.G_MISS_NUM) THEN
      l_ALSv_rec.object_version_number := NULL;
    END IF;
    IF (l_ALSv_rec.AE_LINE_TYPE = okl_api.G_MISS_CHAR) THEN
      l_ALSv_rec.AE_LINE_TYPE := NULL;
    END IF;
    IF (l_ALSv_rec.SOURCE = okl_api.G_MISS_CHAR) THEN
      l_ALSv_rec.SOURCE := NULL;
    END IF;
    IF (l_ALSv_rec.PRIMARY_KEY_COLUMN = okl_api.G_MISS_CHAR) THEN
      l_ALSv_rec.PRIMARY_KEY_COLUMN := NULL;
    END IF;
    IF (l_ALSv_rec.SELECT_COLUMN = okl_api.G_MISS_CHAR) THEN
      l_ALSv_rec.SELECT_COLUMN := NULL;
    END IF;
    IF (l_ALSv_rec.org_id = okl_api.G_MISS_NUM) THEN
      l_ALSv_rec.org_id := NULL;
    END IF;
    IF (l_ALSv_rec.created_by = okl_api.G_MISS_NUM) THEN
      l_ALSv_rec.created_by := NULL;
    END IF;
    IF (l_ALSv_rec.creation_date = okl_api.G_MISS_DATE) THEN
      l_ALSv_rec.creation_date := NULL;
    END IF;
    IF (l_ALSv_rec.last_updated_by = okl_api.G_MISS_NUM) THEN
      l_ALSv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ALSv_rec.last_update_date = okl_api.G_MISS_DATE) THEN
      l_ALSv_rec.last_update_date := NULL;
    END IF;
    IF (l_ALSv_rec.last_update_login = okl_api.G_MISS_NUM) THEN
      l_ALSv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ALSv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_AG_SOURCE_MAPS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ALSv_rec IN  ALSv_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;

  BEGIN
      IF p_alsv_rec.ae_line_type = okl_api.G_MISS_CHAR OR
       p_alsv_rec.ae_line_type IS NULL OR
       p_alsv_rec.ae_line_type = 'NONE' THEN
        okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Account Type');
        l_return_status := okl_api.G_RET_STS_ERROR;
        RETURN(l_return_status);
      END IF;

      IF p_alsv_rec.source = okl_api.G_MISS_CHAR OR
       p_alsv_rec.source IS NULL OR
       p_alsv_rec.source = 'NONE' THEN
        okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Source Table');
        l_return_status := okl_api.G_RET_STS_ERROR;
        RETURN(l_return_status);
      END IF;

      IF p_alsv_rec.select_column = okl_api.G_MISS_CHAR OR
       p_alsv_rec.select_column IS NULL OR
       p_alsv_rec.select_column = 'NONE' THEN
        okl_api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Select Column');
        l_return_status := okl_api.G_RET_STS_ERROR;
        RETURN(l_return_status);
      END IF;
      x_return_status := l_return_status;

    RETURN(x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        okl_api.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => SQLCODE,
                            p_token2       => g_sqlerrm_token,
                            p_token2_value => SQLERRM);

        --notify caller of an UNEXPECTED error
        x_return_status  := okl_api.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;
END;

  --END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_AG_SOURCE_MAPS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_ALSv_rec IN ALSv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_Tcn_Record
    Validate_Unique_ALS_Record(x_return_status, p_ALSv_rec);
    IF (x_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
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
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       okl_api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN ALSv_rec_type,
    p_to IN OUT NOCOPY ALS_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.AE_LINE_TYPE := p_from.AE_LINE_TYPE;
    p_to.SOURCE := p_from.SOURCE;
    p_to.PRIMARY_KEY_COLUMN := p_from.PRIMARY_KEY_COLUMN;
    p_to.SELECT_COLUMN := p_from.SELECT_COLUMN;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN ALS_rec_type,
    p_to OUT NOCOPY ALSv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.AE_LINE_TYPE := p_from.AE_LINE_TYPE;
    p_to.SOURCE := p_from.SOURCE;
    p_to.PRIMARY_KEY_COLUMN := p_from.PRIMARY_KEY_COLUMN;
    p_to.SELECT_COLUMN := p_from.SELECT_COLUMN;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_AG_SOURCE_MAPS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_rec                     IN ALSv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALSv_rec                     ALSv_rec_type := p_ALSv_rec;
    l_ALS_rec                      ALS_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_ALSv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ALSv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:ALSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_tbl                     IN ALSv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ALSv_tbl.COUNT > 0) THEN
      i := p_ALSv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ALSv_rec                     => p_ALSv_tbl(i));
   IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
      IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
   l_overall_status := x_return_status;
     END IF;
  END IF;
        EXIT WHEN (i = p_ALSv_tbl.LAST);
        i := p_ALSv_tbl.NEXT(i);
      END LOOP;
  x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- insert_row for:OKL_AG_SOURCE_MAPS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALS_rec                      IN ALS_rec_type,
    x_ALS_rec                      OUT NOCOPY ALS_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALS_rec                      ALS_rec_type := p_ALS_rec;
    l_def_ALS_rec                  ALS_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_AG_SOURCE_MAPS --
    -----------------------------------------

    FUNCTION Set_Attributes (
      p_ALS_rec IN  ALS_rec_type,
      x_ALS_rec OUT NOCOPY ALS_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ALS_rec := p_ALS_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

--- Setting item attributes
    l_return_status := Set_Attributes(
      p_ALS_rec,                         -- IN
      l_ALS_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

 -- Defaulting the 	PRIMARY_KEY_COLUMN Added by Saran

    l_als_rec.primary_key_column := 'DEFAULT';


    INSERT INTO OKL_AG_SOURCE_MAPS(
        id,
        object_version_number,
        org_id,
        AE_LINE_TYPE,
        SOURCE,
        PRIMARY_KEY_COLUMN,
        SELECT_COLUMN,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_ALS_rec.id,
        l_ALS_rec.object_version_number,
        l_ALS_rec.org_id,
        l_ALS_rec.AE_LINE_TYPE,
        l_ALS_rec.SOURCE,
        l_ALS_rec.PRIMARY_KEY_COLUMN,
        l_ALS_rec.SELECT_COLUMN,
        l_ALS_rec.created_by,
        l_ALS_rec.creation_date,
        l_ALS_rec.last_updated_by,
        l_ALS_rec.last_update_date,
        l_ALS_rec.last_update_login);
    -- Set OUT values
    x_ALS_rec := l_ALS_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_AG_SOURCE_MAPS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_rec                     IN ALSv_rec_type,
    x_ALSv_rec                     OUT NOCOPY ALSv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALSv_rec                     ALSv_rec_type;
    l_def_ALSv_rec                 ALSv_rec_type;
    l_ALS_rec                      ALS_rec_type;
    lx_ALS_rec                     ALS_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ALSv_rec	IN ALSv_rec_type
    ) RETURN ALSv_rec_type IS
      l_ALSv_rec	ALSv_rec_type := p_ALSv_rec;
    BEGIN
      l_ALSv_rec.CREATION_DATE := SYSDATE;
      l_ALSv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ALSv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ALSv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ALSv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ALSv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_AG_SOURCE_MAPS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_ALSv_rec IN  ALSv_rec_type,
      x_ALSv_rec OUT NOCOPY ALSv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ALSv_rec := p_ALSv_rec;
      x_ALSv_rec.OBJECT_VERSION_NUMBER := 1;
      x_ALSv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_ALSv_rec := null_out_defaults(p_ALSv_rec);
    -- Set primary key value
    l_ALSv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ALSv_rec,                        -- IN
      l_def_ALSv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_ALSv_rec := fill_who_columns(l_def_ALSv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ALSv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ALSv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ALSv_rec, l_ALS_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ALS_rec,
      lx_ALS_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ALS_rec, l_def_ALSv_rec);
    -- Set OUT values
    x_ALSv_rec := l_def_ALSv_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:ALSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_tbl                     IN ALSv_tbl_type,
    x_ALSv_tbl                     OUT NOCOPY ALSv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ALSv_tbl.COUNT > 0) THEN
      i := p_ALSv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ALSv_rec                     => p_ALSv_tbl(i),
          x_ALSv_rec                     => x_ALSv_tbl(i));
   IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
     IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
       l_overall_status := x_return_status;
     END IF;
  END IF;
        EXIT WHEN (i = p_ALSv_tbl.LAST);
        i := p_ALSv_tbl.NEXT(i);
      END LOOP;
    x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -----------------------------------
  -- lock_row for:OKL_AG_SOURCE_MAPS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALS_rec                      IN ALS_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ALS_rec IN ALS_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AG_SOURCE_MAPS
     WHERE ID = p_ALS_rec.id
       AND OBJECT_VERSION_NUMBER = p_ALS_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ALS_rec IN ALS_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_AG_SOURCE_MAPS
    WHERE ID = p_ALS_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_AG_SOURCE_MAPS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_AG_SOURCE_MAPS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ALS_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        okl_api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ALS_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ALS_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ALS_rec.object_version_number THEN
      okl_api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      okl_api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_AG_SOURCE_MAPS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_rec                     IN ALSv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALS_rec                      ALS_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_ALSv_rec, l_ALS_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ALS_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:ALSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_tbl                     IN ALSv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ALSv_tbl.COUNT > 0) THEN
      i := p_ALSv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ALSv_rec                     => p_ALSv_tbl(i));
     IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
       IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
         l_overall_status := x_return_status;
       END IF;
  END IF;
        EXIT WHEN (i = p_ALSv_tbl.LAST);
        i := p_ALSv_tbl.NEXT(i);
      END LOOP;
x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- update_row for:OKL_AG_SOURCE_MAPS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALS_rec                      IN ALS_rec_type,
    x_ALS_rec                      OUT NOCOPY ALS_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALS_rec                      ALS_rec_type := p_ALS_rec;
    l_def_ALS_rec                  ALS_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ALS_rec	IN ALS_rec_type,
      x_ALS_rec	OUT NOCOPY ALS_rec_type
    ) RETURN VARCHAR2 IS
      l_ALS_rec                      ALS_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ALS_rec := p_ALS_rec;
      -- Get current database values
      l_ALS_rec := get_rec(p_ALS_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ALS_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_ALS_rec.id := l_ALS_rec.id;
      END IF;
      IF (x_ALS_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_ALS_rec.object_version_number := l_ALS_rec.object_version_number;
      END IF;
      IF (x_ALS_rec.org_id = okl_api.G_MISS_NUM)
      THEN
        x_ALS_rec.org_id := l_ALS_rec.org_id;
      END IF;
      IF (x_ALS_rec.AE_LINE_TYPE = okl_api.G_MISS_CHAR)
      THEN
        x_ALS_rec.AE_LINE_TYPE := l_ALS_rec.AE_LINE_TYPE;
      END IF;
      IF (x_ALS_rec.SOURCE = okl_api.G_MISS_CHAR)
      THEN
        x_ALS_rec.SOURCE := l_ALS_rec.SOURCE;
      END IF;
      IF (x_ALS_rec.PRIMARY_KEY_COLUMN = okl_api.G_MISS_CHAR)
      THEN
        x_ALS_rec.PRIMARY_KEY_COLUMN := l_ALS_rec.PRIMARY_KEY_COLUMN;
      END IF;
      IF (x_ALS_rec.SELECT_COLUMN = okl_api.G_MISS_CHAR)
      THEN
        x_ALS_rec.SELECT_COLUMN := l_ALS_rec.SELECT_COLUMN;
      END IF;
      IF (x_ALS_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_ALS_rec.created_by := l_ALS_rec.created_by;
      END IF;
      IF (x_ALS_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_ALS_rec.creation_date := l_ALS_rec.creation_date;
      END IF;
      IF (x_ALS_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_ALS_rec.last_updated_by := l_ALS_rec.last_updated_by;
      END IF;
      IF (x_ALS_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_ALS_rec.last_update_date := l_ALS_rec.last_update_date;
      END IF;
      IF (x_ALS_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_ALS_rec.last_update_login := l_ALS_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_AG_SOURCE_MAPS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ALS_rec IN  ALS_rec_type,
      x_ALS_rec OUT NOCOPY ALS_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ALS_rec := p_ALS_rec;
      x_ALS_rec.OBJECT_VERSION_NUMBER := NVL(x_ALS_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ALS_rec,                         -- IN
      l_ALS_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ALS_rec, l_def_ALS_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_AG_SOURCE_MAPS
    SET OBJECT_VERSION_NUMBER = l_def_ALS_rec.object_version_number,
        ORG_ID = l_def_ALS_rec.org_id,
        AE_LINE_TYPE = l_def_ALS_rec.AE_LINE_TYPE,
        SOURCE = l_def_ALS_rec.SOURCE,
        PRIMARY_KEY_COLUMN = l_def_ALS_rec.PRIMARY_KEY_COLUMN,
        SELECT_COLUMN = l_def_ALS_rec.SELECT_COLUMN,
        CREATED_BY = l_def_ALS_rec.created_by,
        CREATION_DATE = l_def_ALS_rec.creation_date,
        LAST_UPDATED_BY = l_def_ALS_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ALS_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ALS_rec.last_update_login
    WHERE ID = l_def_ALS_rec.id;

    x_ALS_rec := l_def_ALS_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_AG_SOURCE_MAPS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_rec                     IN ALSv_rec_type,
    x_ALSv_rec                     OUT NOCOPY ALSv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALSv_rec                     ALSv_rec_type := p_ALSv_rec;
    l_def_ALSv_rec                 ALSv_rec_type;
    l_ALS_rec                      ALS_rec_type;
    lx_ALS_rec                     ALS_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ALSv_rec	IN ALSv_rec_type
    ) RETURN ALSv_rec_type IS
      l_ALSv_rec	ALSv_rec_type := p_ALSv_rec;
    BEGIN
      l_ALSv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ALSv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ALSv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ALSv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ALSv_rec	IN ALSv_rec_type,
      x_ALSv_rec	OUT NOCOPY ALSv_rec_type
    ) RETURN VARCHAR2 IS
      l_ALSv_rec                     ALSv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ALSv_rec := p_ALSv_rec;
      -- Get current database values
      l_ALSv_rec := get_rec(p_ALSv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := okl_api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ALSv_rec.id = okl_api.G_MISS_NUM)
      THEN
        x_ALSv_rec.id := l_ALSv_rec.id;
      END IF;
      IF (x_ALSv_rec.object_version_number = okl_api.G_MISS_NUM)
      THEN
        x_ALSv_rec.object_version_number := l_ALSv_rec.object_version_number;
      END IF;
      IF (x_ALSv_rec.AE_LINE_TYPE = okl_api.G_MISS_CHAR)
      THEN
        x_ALSv_rec.AE_LINE_TYPE := l_ALSv_rec.AE_LINE_TYPE;
      END IF;
      IF (x_ALSv_rec.SOURCE = okl_api.G_MISS_CHAR)
      THEN
        x_ALSv_rec.SOURCE := l_ALSv_rec.SOURCE;
      END IF;
      IF (x_ALSv_rec.PRIMARY_KEY_COLUMN = okl_api.G_MISS_CHAR)
      THEN
        x_ALSv_rec.PRIMARY_KEY_COLUMN := l_ALSv_rec.PRIMARY_KEY_COLUMN;
      END IF;
      IF (x_ALSv_rec.SELECT_COLUMN = okl_api.G_MISS_CHAR)
      THEN
        x_ALSv_rec.SELECT_COLUMN := l_ALSv_rec.SELECT_COLUMN;
      END IF;
      IF (x_ALSv_rec.org_id = okl_api.G_MISS_NUM)
      THEN
        x_ALSv_rec.org_id := l_ALSv_rec.org_id;
      END IF;
      IF (x_ALSv_rec.created_by = okl_api.G_MISS_NUM)
      THEN
        x_ALSv_rec.created_by := l_ALSv_rec.created_by;
      END IF;
      IF (x_ALSv_rec.creation_date = okl_api.G_MISS_DATE)
      THEN
        x_ALSv_rec.creation_date := l_ALSv_rec.creation_date;
      END IF;
      IF (x_ALSv_rec.last_updated_by = okl_api.G_MISS_NUM)
      THEN
        x_ALSv_rec.last_updated_by := l_ALSv_rec.last_updated_by;
      END IF;
      IF (x_ALSv_rec.last_update_date = okl_api.G_MISS_DATE)
      THEN
        x_ALSv_rec.last_update_date := l_ALSv_rec.last_update_date;
      END IF;
      IF (x_ALSv_rec.last_update_login = okl_api.G_MISS_NUM)
      THEN
        x_ALSv_rec.last_update_login := l_ALSv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_AG_SOURCE_MAPS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_ALSv_rec IN  ALSv_rec_type,
      x_ALSv_rec OUT NOCOPY ALSv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    BEGIN
      x_ALSv_rec := p_ALSv_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_ALSv_rec,                        -- IN
      l_ALSv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ALSv_rec, l_def_ALSv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_def_ALSv_rec := fill_who_columns(l_def_ALSv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ALSv_rec);
    --- If any errors happen abort API
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ALSv_rec);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ALSv_rec, l_ALS_rec);

     -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_ALSv_rec                      => l_ALSv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ALS_rec,
      lx_ALS_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ALS_rec, l_def_ALSv_rec);
    x_ALSv_rec := l_def_ALSv_rec;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      x_return_status :=OKL_API.G_RET_STS_ERROR;
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:ALSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_tbl                     IN ALSv_tbl_type,
    x_ALSv_tbl                     OUT NOCOPY ALSv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ALSv_tbl.COUNT > 0) THEN
      i := p_ALSv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ALSv_rec                     => p_ALSv_tbl(i),
          x_ALSv_rec                     => x_ALSv_tbl(i));
	  IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_ALSv_tbl.LAST);
        i := p_ALSv_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- delete_row for:OKL_AG_SOURCE_MAPS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALS_rec                      IN ALS_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TEMPLATES_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALS_rec                      ALS_rec_type:= p_ALS_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_AG_SOURCE_MAPS
     WHERE ID = l_ALS_rec.id;

    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_AG_SOURCE_MAPS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_rec                     IN ALSv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_ALSv_rec                     ALSv_rec_type := p_ALSv_rec;
    l_ALS_rec                      ALS_rec_type;
  BEGIN
    l_return_status := okl_api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_ALSv_rec, l_ALS_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ALS_rec
    );
    IF (x_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:ALSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT okl_api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ALSv_tbl                     IN ALSv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    l_overall_status		     VARCHAR2(1) := okl_api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    okl_api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ALSv_tbl.COUNT > 0) THEN
      i := p_ALSv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => okl_api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ALSv_rec                     => p_ALSv_tbl(i));
	  IF x_return_status <> okl_api.G_RET_STS_SUCCESS THEN
	     IF l_overall_status <> okl_api.G_RET_STS_UNEXP_ERROR THEN
		  l_overall_status := x_return_status;
	     END IF;
	  END IF;
        EXIT WHEN (i = p_ALSv_tbl.LAST);
        i := p_ALSv_tbl.NEXT(i);
      END LOOP;
	x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN okl_api.G_EXCEPTION_ERROR THEN
      x_return_status := okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN okl_api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'okl_api.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=okl_api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_ALS_PVT;

/
