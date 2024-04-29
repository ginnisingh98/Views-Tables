--------------------------------------------------------
--  DDL for Package Body OKC_UBL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_UBL_PVT" AS
/* $Header: OKCSUBLB.pls 120.0 2005/05/25 18:05:15 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_USER_BINS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ubn_rec                      IN ubn_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ubn_rec_type IS
    l_ubn_rec                      ubn_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    RETURN(l_ubn_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ubn_rec                      IN ubn_rec_type
  ) RETURN ubn_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ubn_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_USER_BINS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ubnv_rec                     IN ubnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ubnv_rec_type IS
    l_ubnv_rec                     ubnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    RETURN(l_ubnv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ubnv_rec                     IN ubnv_rec_type
  ) RETURN ubnv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ubnv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_USER_BINS_V --
  -----------------------------------------------------
  FUNCTION null_out_defaults (
    p_ubnv_rec	IN ubnv_rec_type
  ) RETURN ubnv_rec_type IS
    l_ubnv_rec	ubnv_rec_type := p_ubnv_rec;
  BEGIN
    IF (l_ubnv_rec.contract_id = OKC_API.G_MISS_NUM) THEN
      l_ubnv_rec.contract_id := NULL;
    END IF;
    IF (l_ubnv_rec.contract_number = OKC_API.G_MISS_CHAR) THEN
      l_ubnv_rec.contract_number := NULL;
    END IF;
    IF (l_ubnv_rec.bin_type = OKC_API.G_MISS_CHAR) THEN
      l_ubnv_rec.bin_type := NULL;
    END IF;
    IF (l_ubnv_rec.contract_type = OKC_API.G_MISS_CHAR) THEN
      l_ubnv_rec.contract_type := NULL;
    END IF;
    IF (l_ubnv_rec.program_name = OKC_API.G_MISS_CHAR) THEN
      l_ubnv_rec.program_name := NULL;
    END IF;
    IF (l_ubnv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ubnv_rec.created_by := NULL;
    END IF;
    IF (l_ubnv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ubnv_rec.creation_date := NULL;
    END IF;
    IF (l_ubnv_rec.contract_number_modifier = OKC_API.G_MISS_CHAR) THEN
      l_ubnv_rec.contract_number_modifier := NULL;
    END IF;
    IF (l_ubnv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_ubnv_rec.short_description := NULL;
    END IF;
    RETURN(l_ubnv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKC_USER_BINS_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_ubnv_rec IN  ubnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ubnv_rec.contract_id = OKC_API.G_MISS_NUM OR
       p_ubnv_rec.contract_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ubnv_rec.contract_number = OKC_API.G_MISS_CHAR OR
          p_ubnv_rec.contract_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ubnv_rec.bin_type = OKC_API.G_MISS_CHAR OR
          p_ubnv_rec.bin_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'bin_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ubnv_rec.contract_type = OKC_API.G_MISS_CHAR OR
          p_ubnv_rec.contract_type IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'contract_type');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_ubnv_rec.program_name = OKC_API.G_MISS_CHAR OR
          p_ubnv_rec.program_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'program_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate_Record for:OKC_USER_BINS_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_ubnv_rec IN ubnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ubnv_rec_type,
    p_to	IN OUT NOCOPY ubn_rec_type
  ) IS
  BEGIN
    p_to.contract_id := p_from.contract_id;
    p_to.contract_number := p_from.contract_number;
    p_to.bin_type := p_from.bin_type;
    p_to.contract_type := p_from.contract_type;
    p_to.program_name := p_from.program_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.contract_number_modifier := p_from.contract_number_modifier;
    p_to.short_description := p_from.short_description;
    p_to.id := p_from.id;
  END migrate;
  PROCEDURE migrate (
    p_from	IN ubn_rec_type,
    p_to	IN OUT NOCOPY ubnv_rec_type
  ) IS
  BEGIN
    p_to.contract_id := p_from.contract_id;
    p_to.contract_number := p_from.contract_number;
    p_to.bin_type := p_from.bin_type;
    p_to.contract_type := p_from.contract_type;
    p_to.program_name := p_from.program_name;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.contract_number_modifier := p_from.contract_number_modifier;
    p_to.short_description := p_from.short_description;
    p_to.id := p_from.id;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKC_USER_BINS_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  --  l_ubnv_rec                     ubnv_rec_type := p_ubnv_rec;
  --  l_ubn_rec                      ubn_rec_type;
  BEGIN
    null;
 /*   l_return_status := OKC_API.START_ACTIVITY(l_api_name,
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
    l_return_status := Validate_Attributes(l_ubnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ubnv_rec);
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
*/
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:UBNV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ubnv_tbl.COUNT > 0) THEN
      i := p_ubnv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ubnv_rec                     => p_ubnv_tbl(i));
        EXIT WHEN (i = p_ubnv_tbl.LAST);
        i := p_ubnv_tbl.NEXT(i);
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
  -- insert_row for:OKC_USER_BINS --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubn_rec                      IN ubn_rec_type,
    x_ubn_rec                      OUT NOCOPY ubn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BINS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ubn_rec                      ubn_rec_type := p_ubn_rec;
    l_def_ubn_rec                  ubn_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKC_USER_BINS --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_ubn_rec IN  ubn_rec_type,
      x_ubn_rec OUT NOCOPY ubn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ubn_rec := p_ubn_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN


/*    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
--- Setting item attributes

    l_return_status := Set_Attributes(
      p_ubn_rec,                         -- IN
      l_ubn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    l_ubn_rec.id := get_seq_id;

    INSERT INTO OKC_USER_BINS(
        contract_id,
        contract_number,
        bin_type,
        contract_type,
        program_name,
        created_by,
        creation_date,
        contract_number_modifier,
        short_description,
	   id)
      VALUES (
        l_ubn_rec.contract_id,
        l_ubn_rec.contract_number,
        l_ubn_rec.bin_type,
        l_ubn_rec.contract_type,
        l_ubn_rec.program_name,
        l_ubn_rec.created_by,
        l_ubn_rec.creation_date,
        l_ubn_rec.contract_number_modifier,
        l_ubn_rec.short_description,
	   l_ubn_rec.id);

    -- Set OUT values
    x_ubn_rec := l_ubn_rec;
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
  ------------------------------------
  -- insert_row for:OKC_USER_BINS_V --
  ------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type,
    x_ubnv_rec                     OUT NOCOPY ubnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ubnv_rec                     ubnv_rec_type;
    l_def_ubnv_rec                 ubnv_rec_type;
    l_ubn_rec                      ubn_rec_type;
    lx_ubn_rec                     ubn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ubnv_rec	IN ubnv_rec_type
    ) RETURN ubnv_rec_type IS
      l_ubnv_rec	ubnv_rec_type := p_ubnv_rec;
    BEGIN

	l_ubnv_rec.CREATION_DATE := SYSDATE;
      l_ubnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      RETURN(l_ubnv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKC_USER_BINS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_ubnv_rec IN  ubnv_rec_type,
      x_ubnv_rec OUT NOCOPY ubnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
	 x_ubnv_rec := p_ubnv_rec;
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

    l_ubnv_rec := null_out_defaults(p_ubnv_rec);
    --- Setting item attributes

    l_return_status := Set_Attributes(
      l_ubnv_rec,                        -- IN
      l_def_ubnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_ubnv_rec := fill_who_columns(l_def_ubnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)

    l_return_status := Validate_Attributes(l_def_ubnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_ubnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------

     migrate(l_def_ubnv_rec, l_ubn_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------

    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ubn_rec,
      lx_ubn_rec
    );

 IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- migrate(lx_ubn_rec, l_def_ubn_rec);
    -- Set OUT values
    x_ubnv_rec := l_def_ubnv_rec;
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
  -- PL/SQL TBL insert_row for:UBNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type,
    x_ubnv_tbl                     OUT NOCOPY ubnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ubnv_tbl.COUNT > 0) THEN
      i := p_ubnv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ubnv_rec                     => p_ubnv_tbl(i),
          x_ubnv_rec                     => x_ubnv_tbl(i));
        EXIT WHEN (i = p_ubnv_tbl.LAST);
        i := p_ubnv_tbl.NEXT(i);
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
  -- lock_row for:OKC_USER_BINS --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubn_rec                      IN ubn_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ubn_rec IN ubn_rec_type) IS
    SELECT *
      FROM OKC_USER_BINS
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BINS_lock_row';
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
      OPEN lock_csr(p_ubn_rec);
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
    ELSE
      IF (l_lock_var.CONTRACT_ID <> p_ubn_rec.contract_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CONTRACT_NUMBER <> p_ubn_rec.contract_number) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.BIN_TYPE <> p_ubn_rec.bin_type) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CONTRACT_TYPE <> p_ubn_rec.contract_type) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PROGRAM_NAME <> p_ubn_rec.program_name) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CREATED_BY <> p_ubn_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CREATION_DATE <> p_ubn_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CONTRACT_NUMBER_MODIFIER <> p_ubn_rec.contract_number_modifier) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.SHORT_DESCRIPTION <> p_ubn_rec.short_description) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
  ----------------------------------
  -- lock_row for:OKC_USER_BINS_V --
  ----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ubn_rec                      ubn_rec_type;
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
  --  migrate(p_ubnv_rec, l_ubn_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ubn_rec
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
  -- PL/SQL TBL lock_row for:UBNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ubnv_tbl.COUNT > 0) THEN
      i := p_ubnv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ubnv_rec                     => p_ubnv_tbl(i));
        EXIT WHEN (i = p_ubnv_tbl.LAST);
        i := p_ubnv_tbl.NEXT(i);
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
  -- update_row for:OKC_USER_BINS --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubn_rec                      IN ubn_rec_type,
    x_ubn_rec                      OUT NOCOPY ubn_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BINS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ubn_rec                      ubn_rec_type := p_ubn_rec;
    l_def_ubn_rec                  ubn_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ubn_rec	IN ubn_rec_type,
      x_ubn_rec	OUT NOCOPY ubn_rec_type
    ) RETURN VARCHAR2 IS
      l_ubn_rec                      ubn_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ubn_rec := p_ubn_rec;
      -- Get current database values
      l_ubn_rec := get_rec(p_ubn_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ubn_rec.contract_id = OKC_API.G_MISS_NUM)
      THEN
        x_ubn_rec.contract_id := l_ubn_rec.contract_id;
      END IF;
      IF (x_ubn_rec.contract_number = OKC_API.G_MISS_CHAR)
      THEN
        x_ubn_rec.contract_number := l_ubn_rec.contract_number;
      END IF;
      IF (x_ubn_rec.bin_type = OKC_API.G_MISS_CHAR)
      THEN
        x_ubn_rec.bin_type := l_ubn_rec.bin_type;
      END IF;
      IF (x_ubn_rec.contract_type = OKC_API.G_MISS_CHAR)
      THEN
        x_ubn_rec.contract_type := l_ubn_rec.contract_type;
      END IF;
      IF (x_ubn_rec.program_name = OKC_API.G_MISS_CHAR)
      THEN
        x_ubn_rec.program_name := l_ubn_rec.program_name;
      END IF;
      IF (x_ubn_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ubn_rec.created_by := l_ubn_rec.created_by;
      END IF;
      IF (x_ubn_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ubn_rec.creation_date := l_ubn_rec.creation_date;
      END IF;
      IF (x_ubn_rec.contract_number_modifier = OKC_API.G_MISS_CHAR)
      THEN
        x_ubn_rec.contract_number_modifier := l_ubn_rec.contract_number_modifier;
      END IF;
      IF (x_ubn_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_ubn_rec.short_description := l_ubn_rec.short_description;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_USER_BINS --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_ubn_rec IN  ubn_rec_type,
      x_ubn_rec OUT NOCOPY ubn_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ubn_rec := p_ubn_rec;
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
      p_ubn_rec,                         -- IN
      l_ubn_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ubn_rec, l_def_ubn_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_USER_BINS
    SET CONTRACT_ID = l_def_ubn_rec.contract_id,
        CONTRACT_NUMBER = l_def_ubn_rec.contract_number,
        BIN_TYPE = l_def_ubn_rec.bin_type,
        CONTRACT_TYPE = l_def_ubn_rec.contract_type,
        PROGRAM_NAME = l_def_ubn_rec.program_name,
        CREATED_BY = l_def_ubn_rec.created_by,
        CREATION_DATE = l_def_ubn_rec.creation_date,
        CONTRACT_NUMBER_MODIFIER = l_def_ubn_rec.contract_number_modifier,
        SHORT_DESCRIPTION = l_def_ubn_rec.short_description
    WHERE id = l_def_ubn_rec.id;

    x_ubn_rec := l_def_ubn_rec;
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
  ------------------------------------
  -- update_row for:OKC_USER_BINS_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type,
    x_ubnv_rec                     OUT NOCOPY ubnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ubnv_rec                     ubnv_rec_type := p_ubnv_rec;
    l_def_ubnv_rec                 ubnv_rec_type;
    l_ubn_rec                      ubn_rec_type;
    lx_ubn_rec                     ubn_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ubnv_rec	IN ubnv_rec_type
    ) RETURN ubnv_rec_type IS
      l_ubnv_rec	ubnv_rec_type := p_ubnv_rec;
    BEGIN
      RETURN(l_ubnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ubnv_rec	IN ubnv_rec_type,
      x_ubnv_rec	OUT NOCOPY ubnv_rec_type
    ) RETURN VARCHAR2 IS
      l_ubnv_rec                     ubnv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ubnv_rec := p_ubnv_rec;
      -- Get current database values
      l_ubnv_rec := get_rec(p_ubnv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ubnv_rec.contract_id = OKC_API.G_MISS_NUM)
      THEN
        x_ubnv_rec.contract_id := l_ubnv_rec.contract_id;
      END IF;
      IF (x_ubnv_rec.contract_number = OKC_API.G_MISS_CHAR)
      THEN
        x_ubnv_rec.contract_number := l_ubnv_rec.contract_number;
      END IF;
      IF (x_ubnv_rec.bin_type = OKC_API.G_MISS_CHAR)
      THEN
        x_ubnv_rec.bin_type := l_ubnv_rec.bin_type;
      END IF;
      IF (x_ubnv_rec.contract_type = OKC_API.G_MISS_CHAR)
      THEN
        x_ubnv_rec.contract_type := l_ubnv_rec.contract_type;
      END IF;
      IF (x_ubnv_rec.program_name = OKC_API.G_MISS_CHAR)
      THEN
        x_ubnv_rec.program_name := l_ubnv_rec.program_name;
      END IF;
      IF (x_ubnv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ubnv_rec.created_by := l_ubnv_rec.created_by;
      END IF;
      IF (x_ubnv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ubnv_rec.creation_date := l_ubnv_rec.creation_date;
      END IF;
      IF (x_ubnv_rec.contract_number_modifier = OKC_API.G_MISS_CHAR)
      THEN
        x_ubnv_rec.contract_number_modifier := l_ubnv_rec.contract_number_modifier;
      END IF;
      IF (x_ubnv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_ubnv_rec.short_description := l_ubnv_rec.short_description;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKC_USER_BINS_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_ubnv_rec IN  ubnv_rec_type,
      x_ubnv_rec OUT NOCOPY ubnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ubnv_rec := p_ubnv_rec;
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
      p_ubnv_rec,                        -- IN
      l_ubnv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ubnv_rec, l_def_ubnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ubnv_rec := fill_who_columns(l_def_ubnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ubnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ubnv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    -- migrate(l_def_ubnv_rec, l_ubn_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ubn_rec,
      lx_ubn_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- migrate(lx_ubn_rec, l_def_ubnv_rec);
    x_ubnv_rec := l_def_ubnv_rec;
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
  -- PL/SQL TBL update_row for:UBNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type,
    x_ubnv_tbl                     OUT NOCOPY ubnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ubnv_tbl.COUNT > 0) THEN
      i := p_ubnv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ubnv_rec                     => p_ubnv_tbl(i),
          x_ubnv_rec                     => x_ubnv_tbl(i));
        EXIT WHEN (i = p_ubnv_tbl.LAST);
        i := p_ubnv_tbl.NEXT(i);
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
  -- delete_row for:OKC_USER_BINS --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubn_rec                      IN ubn_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'BINS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ubn_rec                      ubn_rec_type:= p_ubn_rec;
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
    DELETE FROM OKC_USER_BINS
     WHERE id = l_ubn_rec.id;
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
  ------------------------------------
  -- delete_row for:OKC_USER_BINS_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_rec                     IN ubnv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ubnv_rec                     ubnv_rec_type := p_ubnv_rec;
    l_ubn_rec                      ubn_rec_type;
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
    migrate(l_ubnv_rec, l_ubn_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ubn_rec
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
  -- PL/SQL TBL delete_row for:UBNV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ubnv_tbl                     IN ubnv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ubnv_tbl.COUNT > 0) THEN
      i := p_ubnv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ubnv_rec                     => p_ubnv_tbl(i));
        EXIT WHEN (i = p_ubnv_tbl.LAST);
        i := p_ubnv_tbl.NEXT(i);
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
END OKC_UBL_PVT;

/
