--------------------------------------------------------
--  DDL for Package Body OKC_CLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CLS_PVT" AS
/* $Header: OKCSCLSB.pls 120.0 2005/05/25 22:34:51 appldev noship $ */

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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKC_CLASSES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_CLASSES_B B
         WHERE B.CODE = T.CODE
        );

    UPDATE OKC_CLASSES_TL T SET (
        MEANING,
        DESCRIPTION) = (SELECT
                                  B.MEANING,
                                  B.DESCRIPTION
                                FROM OKC_CLASSES_TL B
                               WHERE B.CODE = T.CODE
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.CODE,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.CODE,
                  SUBT.LANGUAGE
                FROM OKC_CLASSES_TL SUBB, OKC_CLASSES_TL SUBT
               WHERE SUBB.CODE = SUBT.CODE
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.MEANING <> SUBT.MEANING
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKC_CLASSES_TL (
        CODE,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        MEANING,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.CODE,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.MEANING,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_CLASSES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_CLASSES_TL T
                     WHERE T.CODE = B.CODE
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CLASSES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cls_rec                      IN cls_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cls_rec_type IS
    CURSOR okc_classes_b_pk_csr (p_code               IN VARCHAR2) IS
    SELECT
            CODE,
            FFF_FUNCTION_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            APPLICATION_ID,
            ADV_SEARCH_FORM_FUNCTION_ID
      FROM Okc_Classes_B
     WHERE okc_classes_b.code   = p_code;
    l_okc_classes_b_pk             okc_classes_b_pk_csr%ROWTYPE;
    l_cls_rec                      cls_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_classes_b_pk_csr (p_cls_rec.code);
    FETCH okc_classes_b_pk_csr INTO
              l_cls_rec.CODE,
              l_cls_rec.FFF_FUNCTION_ID,
              l_cls_rec.OBJECT_VERSION_NUMBER,
              l_cls_rec.CREATED_BY,
              l_cls_rec.CREATION_DATE,
              l_cls_rec.LAST_UPDATED_BY,
              l_cls_rec.LAST_UPDATE_DATE,
              l_cls_rec.LAST_UPDATE_LOGIN,
              l_cls_rec.APPLICATION_ID,
              l_cls_rec.ADV_SEARCH_FORM_FUNCTION_ID;
    x_no_data_found := okc_classes_b_pk_csr%NOTFOUND;
    CLOSE okc_classes_b_pk_csr;
    RETURN(l_cls_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cls_rec                      IN cls_rec_type
  ) RETURN cls_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cls_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CLASSES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_classes_tl_rec           IN okc_classes_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_classes_tl_rec_type IS
    CURSOR okc_classes_tl_pk_csr (p_code               IN VARCHAR2,
                                  p_language           IN VARCHAR2) IS
    SELECT
            CODE,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            MEANING,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Classes_Tl
     WHERE okc_classes_tl.code  = p_code
       AND okc_classes_tl.language = p_language;
    l_okc_classes_tl_pk            okc_classes_tl_pk_csr%ROWTYPE;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_classes_tl_pk_csr (p_okc_classes_tl_rec.code,
                                p_okc_classes_tl_rec.language);
    FETCH okc_classes_tl_pk_csr INTO
              l_okc_classes_tl_rec.CODE,
              l_okc_classes_tl_rec.LANGUAGE,
              l_okc_classes_tl_rec.SOURCE_LANG,
              l_okc_classes_tl_rec.SFWT_FLAG,
              l_okc_classes_tl_rec.MEANING,
              l_okc_classes_tl_rec.DESCRIPTION,
              l_okc_classes_tl_rec.CREATED_BY,
              l_okc_classes_tl_rec.CREATION_DATE,
              l_okc_classes_tl_rec.LAST_UPDATED_BY,
              l_okc_classes_tl_rec.LAST_UPDATE_DATE,
              l_okc_classes_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_classes_tl_pk_csr%NOTFOUND;
    CLOSE okc_classes_tl_pk_csr;
    RETURN(l_okc_classes_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_classes_tl_rec           IN okc_classes_tl_rec_type
  ) RETURN okc_classes_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_classes_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CLASSES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_clsv_rec                     IN clsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN clsv_rec_type IS
    CURSOR okc_clsv_pk_csr (p_code               IN VARCHAR2) IS
    SELECT
            CODE,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            FFF_FUNCTION_ID,
            MEANING,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            APPLICATION_ID,
            ADV_SEARCH_FORM_FUNCTION_ID
      FROM Okc_Classes_V
     WHERE okc_classes_v.code   = p_code;
    l_okc_clsv_pk                  okc_clsv_pk_csr%ROWTYPE;
    l_clsv_rec                     clsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_clsv_pk_csr (p_clsv_rec.code);
    FETCH okc_clsv_pk_csr INTO
              l_clsv_rec.CODE,
              l_clsv_rec.OBJECT_VERSION_NUMBER,
              l_clsv_rec.SFWT_FLAG,
              l_clsv_rec.FFF_FUNCTION_ID,
              l_clsv_rec.MEANING,
              l_clsv_rec.DESCRIPTION,
              l_clsv_rec.CREATED_BY,
              l_clsv_rec.CREATION_DATE,
              l_clsv_rec.LAST_UPDATED_BY,
              l_clsv_rec.LAST_UPDATE_DATE,
              l_clsv_rec.LAST_UPDATE_LOGIN,
              l_clsv_rec.APPLICATION_ID,
              l_clsv_rec.ADV_SEARCH_FORM_FUNCTION_ID;
    x_no_data_found := okc_clsv_pk_csr%NOTFOUND;
    CLOSE okc_clsv_pk_csr;
    RETURN(l_clsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_clsv_rec                     IN clsv_rec_type
  ) RETURN clsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_clsv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CLASSES_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_clsv_rec	IN clsv_rec_type
  ) RETURN clsv_rec_type IS
    l_clsv_rec	clsv_rec_type := p_clsv_rec;
  BEGIN
    IF (l_clsv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_clsv_rec.object_version_number := NULL;
    END IF;
    IF (l_clsv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_clsv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_clsv_rec.fff_function_id = OKC_API.G_MISS_NUM) THEN
      l_clsv_rec.fff_function_id := NULL;
    END IF;
    IF (l_clsv_rec.meaning = OKC_API.G_MISS_CHAR) THEN
      l_clsv_rec.meaning := NULL;
    END IF;
    IF (l_clsv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_clsv_rec.description := NULL;
    END IF;
    IF (l_clsv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_clsv_rec.created_by := NULL;
    END IF;
    IF (l_clsv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_clsv_rec.creation_date := NULL;
    END IF;
    IF (l_clsv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_clsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_clsv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_clsv_rec.last_update_date := NULL;
    END IF;
    IF (l_clsv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_clsv_rec.last_update_login := NULL;
    END IF;
    IF (l_clsv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_clsv_rec.application_id := NULL;
    END IF;
    IF (l_clsv_rec.adv_search_form_function_id = OKC_API.G_MISS_NUM) THEN
      l_clsv_rec.adv_search_form_function_id := NULL;
    END IF;
    RETURN(l_clsv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- Validate_Attributes for:OKC_CLASSES_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_clsv_rec IN  clsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_clsv_rec.code = OKC_API.G_MISS_CHAR OR
       p_clsv_rec.code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_clsv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_clsv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_clsv_rec.meaning = OKC_API.G_MISS_CHAR OR
          p_clsv_rec.meaning IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'meaning');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate_Record for:OKC_CLASSES_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_clsv_rec IN clsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN clsv_rec_type,
    p_to	OUT NOCOPY cls_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.fff_function_id := p_from.fff_function_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.adv_search_form_function_id := p_from.adv_search_form_function_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cls_rec_type,
    p_to	IN OUT NOCOPY clsv_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.fff_function_id := p_from.fff_function_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.application_id := p_from.application_id;
    p_to.adv_search_form_function_id := p_from.adv_search_form_function_id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN clsv_rec_type,
    p_to	OUT NOCOPY okc_classes_tl_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.meaning := p_from.meaning;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_classes_tl_rec_type,
    p_to	IN OUT NOCOPY clsv_rec_type
  ) IS
  BEGIN
    p_to.code := p_from.code;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.meaning := p_from.meaning;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKC_CLASSES_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type := p_clsv_rec;
    l_cls_rec                      cls_rec_type;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_clsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_clsv_rec);
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
  -- PL/SQL TBL validate_row for:CLSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
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
  ----------------------------------
  -- insert_row for:OKC_CLASSES_B --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type,
    x_cls_rec                      OUT NOCOPY cls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type := p_cls_rec;
    l_def_cls_rec                  cls_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKC_CLASSES_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_cls_rec IN  cls_rec_type,
      x_cls_rec OUT NOCOPY cls_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cls_rec := p_cls_rec;
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
      p_cls_rec,                         -- IN
      l_cls_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CLASSES_B(
        code,
        fff_function_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        application_id,
        adv_search_form_function_id)
     VALUES (
        l_cls_rec.code,
        l_cls_rec.fff_function_id,
        l_cls_rec.object_version_number,
        l_cls_rec.created_by,
        l_cls_rec.creation_date,
        l_cls_rec.last_updated_by,
        l_cls_rec.last_update_date,
        l_cls_rec.last_update_login,
        l_cls_rec.application_id,
        l_cls_rec.adv_search_form_function_id);
    -- Set OUT values
    x_cls_rec := l_cls_rec;
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
  -----------------------------------
  -- insert_row for:OKC_CLASSES_TL --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_classes_tl_rec           IN okc_classes_tl_rec_type,
    x_okc_classes_tl_rec           OUT NOCOPY okc_classes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type := p_okc_classes_tl_rec;
    l_def_okc_classes_tl_rec       okc_classes_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------
    -- Set_Attributes for:OKC_CLASSES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_classes_tl_rec IN  okc_classes_tl_rec_type,
      x_okc_classes_tl_rec OUT NOCOPY okc_classes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_classes_tl_rec := p_okc_classes_tl_rec;
      x_okc_classes_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_classes_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_classes_tl_rec,              -- IN
      l_okc_classes_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_classes_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_CLASSES_TL(
          code,
          language,
          source_lang,
          sfwt_flag,
          meaning,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_classes_tl_rec.code,
          l_okc_classes_tl_rec.language,
          l_okc_classes_tl_rec.source_lang,
          l_okc_classes_tl_rec.sfwt_flag,
          l_okc_classes_tl_rec.meaning,
          l_okc_classes_tl_rec.description,
          l_okc_classes_tl_rec.created_by,
          l_okc_classes_tl_rec.creation_date,
          l_okc_classes_tl_rec.last_updated_by,
          l_okc_classes_tl_rec.last_update_date,
          l_okc_classes_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_classes_tl_rec := l_okc_classes_tl_rec;
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
  ----------------------------------
  -- insert_row for:OKC_CLASSES_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type,
    x_clsv_rec                     OUT NOCOPY clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type;
    l_def_clsv_rec                 clsv_rec_type;
    l_cls_rec                      cls_rec_type;
    lx_cls_rec                     cls_rec_type;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type;
    lx_okc_classes_tl_rec          okc_classes_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clsv_rec	IN clsv_rec_type
    ) RETURN clsv_rec_type IS
      l_clsv_rec	clsv_rec_type := p_clsv_rec;
    BEGIN
      l_clsv_rec.CREATION_DATE := SYSDATE;
      l_clsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_clsv_rec.LAST_UPDATE_DATE := l_clsv_rec.CREATION_DATE;
      l_clsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_clsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_clsv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKC_CLASSES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_clsv_rec IN  clsv_rec_type,
      x_clsv_rec OUT NOCOPY clsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clsv_rec := p_clsv_rec;
      x_clsv_rec.OBJECT_VERSION_NUMBER := 10000;
      x_clsv_rec.SFWT_FLAG := 'N';
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
    l_clsv_rec := null_out_defaults(p_clsv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_clsv_rec,                        -- IN
      l_def_clsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_clsv_rec := fill_who_columns(l_def_clsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_clsv_rec, l_cls_rec);
    migrate(l_def_clsv_rec, l_okc_classes_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec,
      lx_cls_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cls_rec, l_def_clsv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_classes_tl_rec,
      lx_okc_classes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_classes_tl_rec, l_def_clsv_rec);
    -- Set OUT values
    x_clsv_rec := l_def_clsv_rec;
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
  -- PL/SQL TBL insert_row for:CLSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type,
    x_clsv_tbl                     OUT NOCOPY clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i),
          x_clsv_rec                     => x_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
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
  --------------------------------
  -- lock_row for:OKC_CLASSES_B --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cls_rec IN cls_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CLASSES_B
     WHERE CODE = p_cls_rec.code
       AND OBJECT_VERSION_NUMBER = p_cls_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cls_rec IN cls_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CLASSES_B
    WHERE CODE = p_cls_rec.code;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CLASSES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CLASSES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cls_rec);
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
      OPEN lchk_csr(p_cls_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cls_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cls_rec.object_version_number THEN
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
  ---------------------------------
  -- lock_row for:OKC_CLASSES_TL --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_classes_tl_rec           IN okc_classes_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_classes_tl_rec IN okc_classes_tl_rec_type) IS
    SELECT *
      FROM OKC_CLASSES_TL
     WHERE CODE = p_okc_classes_tl_rec.code
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_okc_classes_tl_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
  --------------------------------
  -- lock_row for:OKC_CLASSES_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type;
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
    migrate(p_clsv_rec, l_cls_rec);
    migrate(p_clsv_rec, l_okc_classes_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_classes_tl_rec
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
  -- PL/SQL TBL lock_row for:CLSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
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
  ----------------------------------
  -- update_row for:OKC_CLASSES_B --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type,
    x_cls_rec                      OUT NOCOPY cls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type := p_cls_rec;
    l_def_cls_rec                  cls_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cls_rec	IN cls_rec_type,
      x_cls_rec	OUT NOCOPY cls_rec_type
    ) RETURN VARCHAR2 IS
      l_cls_rec                      cls_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cls_rec := p_cls_rec;
      -- Get current database values
      l_cls_rec := get_rec(p_cls_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cls_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_cls_rec.code := l_cls_rec.code;
      END IF;
      IF (x_cls_rec.fff_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_cls_rec.fff_function_id := l_cls_rec.fff_function_id;
      END IF;
      IF (x_cls_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cls_rec.object_version_number := l_cls_rec.object_version_number;
      END IF;
      IF (x_cls_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cls_rec.created_by := l_cls_rec.created_by;
      END IF;
      IF (x_cls_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cls_rec.creation_date := l_cls_rec.creation_date;
      END IF;
      IF (x_cls_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cls_rec.last_updated_by := l_cls_rec.last_updated_by;
      END IF;
      IF (x_cls_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cls_rec.last_update_date := l_cls_rec.last_update_date;
      END IF;
      IF (x_cls_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cls_rec.last_update_login := l_cls_rec.last_update_login;
      END IF;
      IF (x_cls_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_cls_rec.application_id := l_cls_rec.application_id;
      END IF;
      IF (x_cls_rec.adv_search_form_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_cls_rec.adv_search_form_function_id := l_cls_rec.adv_search_form_function_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_CLASSES_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_cls_rec IN  cls_rec_type,
      x_cls_rec OUT NOCOPY cls_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cls_rec := p_cls_rec;
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
      p_cls_rec,                         -- IN
      l_cls_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cls_rec, l_def_cls_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CLASSES_B
    SET FFF_FUNCTION_ID = l_def_cls_rec.fff_function_id,
        OBJECT_VERSION_NUMBER = l_def_cls_rec.object_version_number,
        CREATED_BY = l_def_cls_rec.created_by,
        CREATION_DATE = l_def_cls_rec.creation_date,
        LAST_UPDATED_BY = l_def_cls_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cls_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cls_rec.last_update_login,
        APPLICATION_ID=l_def_cls_rec.application_id,
        ADV_SEARCH_FORM_FUNCTION_ID=l_def_cls_rec.adv_search_form_function_id
    WHERE CODE = l_def_cls_rec.code;

    x_cls_rec := l_def_cls_rec;
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
  -----------------------------------
  -- update_row for:OKC_CLASSES_TL --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_classes_tl_rec           IN okc_classes_tl_rec_type,
    x_okc_classes_tl_rec           OUT NOCOPY okc_classes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type := p_okc_classes_tl_rec;
    l_def_okc_classes_tl_rec       okc_classes_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_classes_tl_rec	IN okc_classes_tl_rec_type,
      x_okc_classes_tl_rec	OUT NOCOPY okc_classes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_classes_tl_rec           okc_classes_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_classes_tl_rec := p_okc_classes_tl_rec;
      -- Get current database values
      l_okc_classes_tl_rec := get_rec(p_okc_classes_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_classes_tl_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_classes_tl_rec.code := l_okc_classes_tl_rec.code;
      END IF;
      IF (x_okc_classes_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_classes_tl_rec.language := l_okc_classes_tl_rec.language;
      END IF;
      IF (x_okc_classes_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_classes_tl_rec.source_lang := l_okc_classes_tl_rec.source_lang;
      END IF;
      IF (x_okc_classes_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_classes_tl_rec.sfwt_flag := l_okc_classes_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_classes_tl_rec.meaning = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_classes_tl_rec.meaning := l_okc_classes_tl_rec.meaning;
      END IF;
      IF (x_okc_classes_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_classes_tl_rec.description := l_okc_classes_tl_rec.description;
      END IF;
      IF (x_okc_classes_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_classes_tl_rec.created_by := l_okc_classes_tl_rec.created_by;
      END IF;
      IF (x_okc_classes_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_classes_tl_rec.creation_date := l_okc_classes_tl_rec.creation_date;
      END IF;
      IF (x_okc_classes_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_classes_tl_rec.last_updated_by := l_okc_classes_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_classes_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_classes_tl_rec.last_update_date := l_okc_classes_tl_rec.last_update_date;
      END IF;
      IF (x_okc_classes_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_classes_tl_rec.last_update_login := l_okc_classes_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_CLASSES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_classes_tl_rec IN  okc_classes_tl_rec_type,
      x_okc_classes_tl_rec OUT NOCOPY okc_classes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_classes_tl_rec := p_okc_classes_tl_rec;
      x_okc_classes_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_classes_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_classes_tl_rec,              -- IN
      l_okc_classes_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_classes_tl_rec, l_def_okc_classes_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CLASSES_TL
    SET MEANING = l_def_okc_classes_tl_rec.meaning,
        DESCRIPTION = l_def_okc_classes_tl_rec.description,
        CREATED_BY = l_def_okc_classes_tl_rec.created_by,
        CREATION_DATE = l_def_okc_classes_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_classes_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_classes_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_classes_tl_rec.last_update_login
    WHERE CODE = l_def_okc_classes_tl_rec.code
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_CLASSES_TL
    SET SFWT_FLAG = 'Y'
    WHERE CODE = l_def_okc_classes_tl_rec.code
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_classes_tl_rec := l_def_okc_classes_tl_rec;
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
  ----------------------------------
  -- update_row for:OKC_CLASSES_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type,
    x_clsv_rec                     OUT NOCOPY clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type := p_clsv_rec;
    l_def_clsv_rec                 clsv_rec_type;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type;
    lx_okc_classes_tl_rec          okc_classes_tl_rec_type;
    l_cls_rec                      cls_rec_type;
    lx_cls_rec                     cls_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clsv_rec	IN clsv_rec_type
    ) RETURN clsv_rec_type IS
      l_clsv_rec	clsv_rec_type := p_clsv_rec;
    BEGIN
      l_clsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_clsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_clsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_clsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_clsv_rec	IN clsv_rec_type,
      x_clsv_rec	OUT NOCOPY clsv_rec_type
    ) RETURN VARCHAR2 IS
      l_clsv_rec                     clsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clsv_rec := p_clsv_rec;
      -- Get current database values
      l_clsv_rec := get_rec(p_clsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_clsv_rec.code = OKC_API.G_MISS_CHAR)
      THEN
        x_clsv_rec.code := l_clsv_rec.code;
      END IF;
      IF (x_clsv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_clsv_rec.object_version_number := l_clsv_rec.object_version_number;
      END IF;
      IF (x_clsv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_clsv_rec.sfwt_flag := l_clsv_rec.sfwt_flag;
      END IF;
      IF (x_clsv_rec.fff_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_clsv_rec.fff_function_id := l_clsv_rec.fff_function_id;
      END IF;
      IF (x_clsv_rec.meaning = OKC_API.G_MISS_CHAR)
      THEN
        x_clsv_rec.meaning := l_clsv_rec.meaning;
      END IF;
      IF (x_clsv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_clsv_rec.description := l_clsv_rec.description;
      END IF;
      IF (x_clsv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_clsv_rec.created_by := l_clsv_rec.created_by;
      END IF;
      IF (x_clsv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_clsv_rec.creation_date := l_clsv_rec.creation_date;
      END IF;
      IF (x_clsv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_clsv_rec.last_updated_by := l_clsv_rec.last_updated_by;
      END IF;
      IF (x_clsv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_clsv_rec.last_update_date := l_clsv_rec.last_update_date;
      END IF;
      IF (x_clsv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_clsv_rec.last_update_login := l_clsv_rec.last_update_login;
      END IF;
      IF (x_clsv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_clsv_rec.application_id := l_clsv_rec.application_id;
      END IF;
      IF (x_clsv_rec.adv_search_form_function_id = OKC_API.G_MISS_NUM)
      THEN
        x_clsv_rec.adv_search_form_function_id := l_clsv_rec.adv_search_form_function_id;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_CLASSES_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_clsv_rec IN  clsv_rec_type,
      x_clsv_rec OUT NOCOPY clsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clsv_rec := p_clsv_rec;
      x_clsv_rec.OBJECT_VERSION_NUMBER := NVL(x_clsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_clsv_rec,                        -- IN
      l_clsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_clsv_rec, l_def_clsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_clsv_rec := fill_who_columns(l_def_clsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_clsv_rec, l_okc_classes_tl_rec);
    migrate(l_def_clsv_rec, l_cls_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_classes_tl_rec,
      lx_okc_classes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_classes_tl_rec, l_def_clsv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec,
      lx_cls_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cls_rec, l_def_clsv_rec);
    x_clsv_rec := l_def_clsv_rec;
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
  -- PL/SQL TBL update_row for:CLSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type,
    x_clsv_tbl                     OUT NOCOPY clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i),
          x_clsv_rec                     => x_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
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
  ----------------------------------
  -- delete_row for:OKC_CLASSES_B --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cls_rec                      IN cls_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cls_rec                      cls_rec_type:= p_cls_rec;
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
    DELETE FROM OKC_CLASSES_B
     WHERE CODE = l_cls_rec.code;

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
  -----------------------------------
  -- delete_row for:OKC_CLASSES_TL --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_classes_tl_rec           IN okc_classes_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type:= p_okc_classes_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ---------------------------------------
    -- Set_Attributes for:OKC_CLASSES_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okc_classes_tl_rec IN  okc_classes_tl_rec_type,
      x_okc_classes_tl_rec OUT NOCOPY okc_classes_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_classes_tl_rec := p_okc_classes_tl_rec;
      x_okc_classes_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
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
      p_okc_classes_tl_rec,              -- IN
      l_okc_classes_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_CLASSES_TL
     WHERE CODE = l_okc_classes_tl_rec.code;

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
  ----------------------------------
  -- delete_row for:OKC_CLASSES_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_rec                     IN clsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clsv_rec                     clsv_rec_type := p_clsv_rec;
    l_okc_classes_tl_rec           okc_classes_tl_rec_type;
    l_cls_rec                      cls_rec_type;
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
    migrate(l_clsv_rec, l_okc_classes_tl_rec);
    migrate(l_clsv_rec, l_cls_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_classes_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cls_rec
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
  -- PL/SQL TBL delete_row for:CLSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clsv_tbl                     IN clsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clsv_tbl.COUNT > 0) THEN
      i := p_clsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clsv_rec                     => p_clsv_tbl(i));
        EXIT WHEN (i = p_clsv_tbl.LAST);
        i := p_clsv_tbl.NEXT(i);
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
END OKC_CLS_PVT;

/
