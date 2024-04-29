--------------------------------------------------------
--  DDL for Package Body OKL_AGC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AGC_PVT" AS
/* $Header: OKLSAGCB.pls 120.3 2006/07/13 12:50:57 adagur noship $ */
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
  -- FUNCTION get_rec for: OKL_ACC_GROUP_CCID
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_agc_rec                      IN agc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN agc_rec_type IS
    CURSOR OKL_ACC_GROUP_CCID_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CODE_COMBINATION_ID,
            OBJECT_VERSION_NUMBER,
            SET_OF_BOOKS_ID,
            ACC_GROUP_CODE,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_ACC_GROUP_CCID
     WHERE OKL_ACC_GROUP_CCID.id  = p_id;
    l_OKL_ACC_GROUP_CCID_pk          okl_acc_group_ccid_pk_csr%ROWTYPE;
    l_agc_rec                      agc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKL_ACC_GROUP_CCID_pk_csr (p_agc_rec.id);
    FETCH OKL_ACC_GROUP_CCID_pk_csr INTO
              l_agc_rec.ID,
              l_agc_rec.CODE_COMBINATION_ID,
              l_agc_rec.OBJECT_VERSION_NUMBER,
              l_agc_rec.SET_OF_BOOKS_ID,
              l_agc_rec.ACC_GROUP_CODE,
              l_agc_rec.ORG_ID,
              l_agc_rec.CREATED_BY,
              l_agc_rec.CREATION_DATE,
              l_agc_rec.LAST_UPDATED_BY,
              l_agc_rec.LAST_UPDATE_DATE,
              l_agc_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := OKL_ACC_GROUP_CCID_pk_csr%NOTFOUND;
    CLOSE OKL_ACC_GROUP_CCID_pk_csr;
    RETURN(l_agc_rec);
  END get_rec;

  FUNCTION get_rec (
    p_agc_rec                      IN agc_rec_type
  ) RETURN agc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_agc_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_ACC_GROUP_CCID_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_agcv_rec                     IN agcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN agcv_rec_type IS
    CURSOR okl_agcv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ACC_GROUP_CODE,
            CODE_COMBINATION_ID,
            SET_OF_BOOKS_ID,
            ORG_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_ACC_GROUP_CCID
     WHERE OKL_ACC_GROUP_CCID.id = p_id;
    l_okl_agcv_pk                  okl_agcv_pk_csr%ROWTYPE;
    l_agcv_rec                     agcv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_agcv_pk_csr (p_agcv_rec.id);
    FETCH okl_agcv_pk_csr INTO
              l_agcv_rec.ID,
              l_agcv_rec.OBJECT_VERSION_NUMBER,
              l_agcv_rec.ACC_GROUP_CODE,
              l_agcv_rec.CODE_COMBINATION_ID,
              l_agcv_rec.SET_OF_BOOKS_ID,
              l_agcv_rec.ORG_ID,
              l_agcv_rec.CREATED_BY,
              l_agcv_rec.CREATION_DATE,
              l_agcv_rec.LAST_UPDATED_BY,
              l_agcv_rec.LAST_UPDATE_DATE,
              l_agcv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_agcv_pk_csr%NOTFOUND;
    CLOSE okl_agcv_pk_csr;
    RETURN(l_agcv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_agcv_rec                     IN agcv_rec_type
  ) RETURN agcv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_agcv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_ACC_GROUP_CCID_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_agcv_rec	IN agcv_rec_type
  ) RETURN agcv_rec_type IS
    l_agcv_rec	agcv_rec_type := p_agcv_rec;
  BEGIN
    IF (l_agcv_rec.object_version_number = Okc_Api.G_MISS_NUM) THEN
      l_agcv_rec.object_version_number := NULL;
    END IF;
    IF (l_agcv_rec.acc_group_code = Okc_Api.G_MISS_CHAR) THEN
      l_agcv_rec.acc_group_code := NULL;
    END IF;
    IF (l_agcv_rec.code_combination_id = Okc_Api.G_MISS_NUM) THEN
      l_agcv_rec.code_combination_id := NULL;
    END IF;
    IF (l_agcv_rec.set_of_books_id = Okc_Api.G_MISS_NUM) THEN
      l_agcv_rec.set_of_books_id := NULL;
    END IF;
    IF (l_agcv_rec.org_id = Okc_Api.G_MISS_NUM) THEN
      l_agcv_rec.org_id := NULL;
    END IF;
    IF (l_agcv_rec.created_by = Okc_Api.G_MISS_NUM) THEN
      l_agcv_rec.created_by := NULL;
    END IF;
    IF (l_agcv_rec.creation_date = Okc_Api.G_MISS_DATE) THEN
      l_agcv_rec.creation_date := NULL;
    END IF;
    IF (l_agcv_rec.last_updated_by = Okc_Api.G_MISS_NUM) THEN
      l_agcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_agcv_rec.last_update_date = Okc_Api.G_MISS_DATE) THEN
      l_agcv_rec.last_update_date := NULL;
    END IF;
    IF (l_agcv_rec.last_update_login = Okc_Api.G_MISS_NUM) THEN
      l_agcv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_agcv_rec);
  END null_out_defaults;

  ------------------------------------------------
  -- Validate_Attributes for:OKL_ACC_GROUP_CCID_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_agcv_rec IN  agcv_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    l_enddate_status	VARCHAR2(1);

  BEGIN
    IF p_agcv_rec.id = Okc_Api.G_MISS_NUM OR
       p_agcv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF p_agcv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
          p_agcv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

    IF p_agcv_rec.code_combination_id = Okc_Api.G_MISS_NUM OR
          p_agcv_rec.code_combination_id IS NULL
    THEN
      Okc_Api.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'code_combination_id');
      l_return_status := Okc_Api.G_RET_STS_ERROR;

    END IF;

    RETURN(l_return_status);

    EXCEPTION
    WHEN    G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
    RETURN (l_return_status);
    WHEN OTHERS THEN
      Okc_Api.set_message(G_APP_NAME,G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
	RETURN(l_return_status);


  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_ACC_GROUP_CCID_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_agcv_rec IN  agcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status   VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

    BEGIN
    NULL;
    RETURN (l_return_status);
    END Validate_Record;



  ---------------------------------------------------------------------------


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN agcv_rec_type,
    p_to	OUT NOCOPY agc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.acc_group_code := p_from.acc_group_code;
    p_to.org_id := p_from.org_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN agc_rec_type,
    p_to	OUT NOCOPY agcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.set_of_books_id := p_from.set_of_books_id;
    p_to.acc_group_code := p_from.acc_group_code;
    p_to.org_id := p_from.org_id;
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
  -- validate_row for:OKL_ACC_GROUP_CCID_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agcv_rec                     agcv_rec_type := p_agcv_rec;
    l_agc_rec                      agc_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_agcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_agcv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:AGCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agcv_rec                     => p_agcv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_ACC_GROUP_CCID --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agc_rec                      IN agc_rec_type,
    x_agc_rec                      OUT NOCOPY agc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agc_rec                      agc_rec_type := p_agc_rec;
    l_def_agc_rec                  agc_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_ACC_GROUP_CCID --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_agc_rec IN  agc_rec_type,
      x_agc_rec OUT NOCOPY agc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agc_rec := p_agc_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_agc_rec,                         -- IN
      l_agc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_ACC_GROUP_CCID(
        id,
        code_combination_id,
        object_version_number,
        set_of_books_id,
        acc_group_code,
        org_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_agc_rec.id,
        l_agc_rec.code_combination_id,
        l_agc_rec.object_version_number,
        l_agc_rec.set_of_books_id,
        l_agc_rec.acc_group_code,
        l_agc_rec.org_id,
        l_agc_rec.created_by,
        l_agc_rec.creation_date,
        l_agc_rec.last_updated_by,
        l_agc_rec.last_update_date,
        l_agc_rec.last_update_login);
    -- Set OUT values
    x_agc_rec := l_agc_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_ACC_GROUP_CCID_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type,
    x_agcv_rec                     OUT NOCOPY agcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agcv_rec                     agcv_rec_type;
    l_def_agcv_rec                 agcv_rec_type;
    l_agc_rec                      agc_rec_type;
    lx_agc_rec                     agc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_agcv_rec	IN agcv_rec_type
    ) RETURN agcv_rec_type IS
      l_agcv_rec	agcv_rec_type := p_agcv_rec;
    BEGIN
      l_agcv_rec.CREATION_DATE := SYSDATE;
      l_agcv_rec.CREATED_BY := Fnd_Global.USER_ID;
      l_agcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_agcv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_agcv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_agcv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_ACC_GROUP_CCID_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_agcv_rec IN  agcv_rec_type,
      x_agcv_rec OUT NOCOPY agcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agcv_rec := p_agcv_rec;
      x_agcv_rec.OBJECT_VERSION_NUMBER := 1;
      x_agcv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
      x_agcv_rec.SET_OF_BOOKS_ID := OKL_ACCOUNTING_UTIL.get_set_of_books_id;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_agcv_rec := null_out_defaults(p_agcv_rec);
    -- Set primary key value
    l_agcv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_agcv_rec,                        -- IN
      l_def_agcv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_agcv_rec := fill_who_columns(l_def_agcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_agcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_agcv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_agcv_rec, l_agc_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agc_rec,
      lx_agc_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_agc_rec, l_def_agcv_rec);
    -- Set OUT values
    x_agcv_rec := l_def_agcv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:AGCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type,
    x_agcv_tbl                     OUT NOCOPY agcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agcv_rec                     => p_agcv_tbl(i),
          x_agcv_rec                     => x_agcv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;

  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_ACC_GROUP_CCID --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agc_rec                      IN agc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_agc_rec IN agc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACC_GROUP_CCID
     WHERE ID = p_agc_rec.id
       AND OBJECT_VERSION_NUMBER = p_agc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_agc_rec IN agc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_ACC_GROUP_CCID
    WHERE ID = p_agc_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_ACC_GROUP_CCID.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_ACC_GROUP_CCID.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_agc_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okc_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_agc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_agc_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_agc_rec.object_version_number THEN
      Okc_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okc_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_ACC_GROUP_CCID_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agc_rec                      agc_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_agcv_rec, l_agc_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agc_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:AGCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agcv_rec                     => p_agcv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
      END LOOP;
    END IF;
        x_return_status := l_overall_status;

  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_ACC_GROUP_CCID --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agc_rec                      IN agc_rec_type,
    x_agc_rec                      OUT NOCOPY agc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agc_rec                      agc_rec_type := p_agc_rec;
    l_def_agc_rec                  agc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_agc_rec	IN agc_rec_type,
      x_agc_rec	OUT NOCOPY agc_rec_type
    ) RETURN VARCHAR2 IS
      l_agc_rec                      agc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agc_rec := p_agc_rec;
      -- Get current database values
      l_agc_rec := get_rec(p_agc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_agc_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.id := l_agc_rec.id;
      END IF;
      IF (x_agc_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.code_combination_id := l_agc_rec.code_combination_id;
      END IF;
      IF (x_agc_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.object_version_number := l_agc_rec.object_version_number;
      END IF;
      IF (x_agc_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.set_of_books_id := l_agc_rec.set_of_books_id;
      END IF;
      IF (x_agc_rec.acc_group_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agc_rec.acc_group_code := l_agc_rec.acc_group_code;
      END IF;
      IF (x_agc_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.org_id := l_agc_rec.org_id;
      END IF;
      IF (x_agc_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.created_by := l_agc_rec.created_by;
      END IF;
      IF (x_agc_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agc_rec.creation_date := l_agc_rec.creation_date;
      END IF;
      IF (x_agc_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.last_updated_by := l_agc_rec.last_updated_by;
      END IF;
      IF (x_agc_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agc_rec.last_update_date := l_agc_rec.last_update_date;
      END IF;
      IF (x_agc_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_agc_rec.last_update_login := l_agc_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_ACC_GROUP_CCID --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_agc_rec IN  agc_rec_type,
      x_agc_rec OUT NOCOPY agc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agc_rec := p_agc_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_agc_rec,                         -- IN
      l_agc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_agc_rec, l_def_agc_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_ACC_GROUP_CCID
    SET CODE_COMBINATION_ID = l_def_agc_rec.code_combination_id,
        OBJECT_VERSION_NUMBER = l_def_agc_rec.object_version_number,
        SET_OF_BOOKS_ID = l_def_agc_rec.set_of_books_id,
        ACC_GROUP_CODE = l_def_agc_rec.acc_group_code,
        ORG_ID = l_def_agc_rec.org_id,
        CREATED_BY = l_def_agc_rec.created_by,
        CREATION_DATE = l_def_agc_rec.creation_date,
        LAST_UPDATED_BY = l_def_agc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_agc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_agc_rec.last_update_login
    WHERE ID = l_def_agc_rec.id;

    x_agc_rec := l_def_agc_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_ACC_GROUP_CCID_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type,
    x_agcv_rec                     OUT NOCOPY agcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agcv_rec                     agcv_rec_type := p_agcv_rec;
    l_def_agcv_rec                 agcv_rec_type;
    l_agc_rec                      agc_rec_type;
    lx_agc_rec                     agc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_agcv_rec	IN agcv_rec_type
    ) RETURN agcv_rec_type IS
      l_agcv_rec	agcv_rec_type := p_agcv_rec;
    BEGIN
      l_agcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_agcv_rec.LAST_UPDATED_BY := Fnd_Global.USER_ID;
      l_agcv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_agcv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_agcv_rec	IN agcv_rec_type,
      x_agcv_rec	OUT NOCOPY agcv_rec_type
    ) RETURN VARCHAR2 IS
      l_agcv_rec                     agcv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agcv_rec := p_agcv_rec;
      -- Get current database values
      l_agcv_rec := get_rec(p_agcv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_agcv_rec.id = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.id := l_agcv_rec.id;
      END IF;
      IF (x_agcv_rec.object_version_number = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.object_version_number := l_agcv_rec.object_version_number;
      END IF;
      IF (x_agcv_rec.acc_group_code = Okc_Api.G_MISS_CHAR)
      THEN
        x_agcv_rec.acc_group_code := l_agcv_rec.acc_group_code;
      END IF;
      IF (x_agcv_rec.code_combination_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.code_combination_id := l_agcv_rec.code_combination_id;
      END IF;
      IF (x_agcv_rec.set_of_books_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.set_of_books_id := l_agcv_rec.set_of_books_id;
      END IF;
      IF (x_agcv_rec.org_id = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.org_id := l_agcv_rec.org_id;
      END IF;
      IF (x_agcv_rec.created_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.created_by := l_agcv_rec.created_by;
      END IF;
      IF (x_agcv_rec.creation_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agcv_rec.creation_date := l_agcv_rec.creation_date;
      END IF;
      IF (x_agcv_rec.last_updated_by = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.last_updated_by := l_agcv_rec.last_updated_by;
      END IF;
      IF (x_agcv_rec.last_update_date = Okc_Api.G_MISS_DATE)
      THEN
        x_agcv_rec.last_update_date := l_agcv_rec.last_update_date;
      END IF;
      IF (x_agcv_rec.last_update_login = Okc_Api.G_MISS_NUM)
      THEN
        x_agcv_rec.last_update_login := l_agcv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_ACC_GROUP_CCID_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_agcv_rec IN  agcv_rec_type,
      x_agcv_rec OUT NOCOPY agcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    BEGIN
      x_agcv_rec := p_agcv_rec;
      x_agcv_rec.OBJECT_VERSION_NUMBER := NVL(x_agcv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_agcv_rec,                        -- IN
      l_agcv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_agcv_rec, l_def_agcv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_def_agcv_rec := fill_who_columns(l_def_agcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_agcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_agcv_rec);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_agcv_rec, l_agc_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agc_rec,
      lx_agc_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_agc_rec, l_def_agcv_rec);
    x_agcv_rec := l_def_agcv_rec;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:AGCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type,
    x_agcv_tbl                     OUT NOCOPY agcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agcv_rec                     => p_agcv_tbl(i),
          x_agcv_rec                     => x_agcv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;

        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
      END LOOP;
    END IF;

    x_return_status := l_overall_status;

  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_ACC_GROUP_CCID --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agc_rec                      IN agc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SETS_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agc_rec                      agc_rec_type:= p_agc_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_ACC_GROUP_CCID
     WHERE ID = l_agc_rec.id;

    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_ACC_GROUP_CCID_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_rec                     IN agcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_agcv_rec                     agcv_rec_type := p_agcv_rec;
    l_agc_rec                      agc_rec_type;
  BEGIN
    l_return_status := Okc_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_agcv_rec, l_agc_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_agc_rec
    );
    IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
      RAISE Okc_Api.G_EXCEPTION_ERROR;
    END IF;
    Okc_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:AGCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okc_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_agcv_tbl                     IN agcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    Okc_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_agcv_tbl.COUNT > 0) THEN
      i := p_agcv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okc_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_agcv_rec                     => p_agcv_tbl(i));

          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
            IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                l_overall_status := x_return_status;
            END IF;
          END IF;

        EXIT WHEN (i = p_agcv_tbl.LAST);
        i := p_agcv_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_overall_status;
  EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_AGC_PVT;

/
