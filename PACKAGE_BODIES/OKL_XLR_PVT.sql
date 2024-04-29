--------------------------------------------------------
--  DDL for Package Body OKL_XLR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XLR_PVT" AS
/* $Header: OKLSXLRB.pls 115.3 2002/03/14 17:30:12 pkm ship        $ */
/*
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
  -- FUNCTION get_rec for: OKL_XTL_FUND_RQNS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xlr_rec                      IN xlr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xlr_rec_type IS
    CURSOR xlrq_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            IRN_ID,
            IMR_ID,
            XHR_ID_DETAILS,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            QUANTITY,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            LAST_UPDATE_LOGIN
      FROM Okl_Xtl_Fund_Rqns_B
     WHERE okl_xtl_fund_rqns_b.id = p_id;
    l_xlrq_pk                      xlrq_pk_csr%ROWTYPE;
    l_xlr_rec                      xlr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN xlrq_pk_csr (p_xlr_rec.id);
    FETCH xlrq_pk_csr INTO
              l_xlr_rec.ID,
              l_xlr_rec.IRN_ID,
              l_xlr_rec.IMR_ID,
              l_xlr_rec.XHR_ID_DETAILS,
              l_xlr_rec.OBJECT_VERSION_NUMBER,
              l_xlr_rec.CREATED_BY,
              l_xlr_rec.CREATION_DATE,
              l_xlr_rec.LAST_UPDATED_BY,
              l_xlr_rec.LAST_UPDATE_DATE,
              l_xlr_rec.QUANTITY,
              l_xlr_rec.ORG_ID,
              l_xlr_rec.REQUEST_ID,
              l_xlr_rec.PROGRAM_APPLICATION_ID,
              l_xlr_rec.PROGRAM_ID,
              l_xlr_rec.PROGRAM_UPDATE_DATE,
              l_xlr_rec.ATTRIBUTE_CATEGORY,
              l_xlr_rec.ATTRIBUTE1,
              l_xlr_rec.ATTRIBUTE2,
              l_xlr_rec.ATTRIBUTE3,
              l_xlr_rec.ATTRIBUTE4,
              l_xlr_rec.ATTRIBUTE5,
              l_xlr_rec.ATTRIBUTE6,
              l_xlr_rec.ATTRIBUTE7,
              l_xlr_rec.ATTRIBUTE8,
              l_xlr_rec.ATTRIBUTE9,
              l_xlr_rec.ATTRIBUTE10,
              l_xlr_rec.ATTRIBUTE11,
              l_xlr_rec.ATTRIBUTE12,
              l_xlr_rec.ATTRIBUTE13,
              l_xlr_rec.ATTRIBUTE14,
              l_xlr_rec.ATTRIBUTE15,
              l_xlr_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := xlrq_pk_csr%NOTFOUND;
    CLOSE xlrq_pk_csr;
    RETURN(l_xlr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xlr_rec                      IN xlr_rec_type
  ) RETURN xlr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xlr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_XTL_FUND_RQNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xlrv_rec                     IN xlrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xlrv_rec_type IS
    CURSOR okl_xlrv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            IRN_ID,
            IMR_ID,
            XHR_ID_DETAILS,
            QUANTITY,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            ORG_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Xtl_Fund_Rqns_V
     WHERE okl_xtl_fund_rqns_v.id = p_id;
    l_okl_xlrv_pk                  okl_xlrv_pk_csr%ROWTYPE;
    l_xlrv_rec                     xlrv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xlrv_pk_csr (p_xlrv_rec.id);
    FETCH okl_xlrv_pk_csr INTO
              l_xlrv_rec.ID,
              l_xlrv_rec.OBJECT_VERSION_NUMBER,
              l_xlrv_rec.IRN_ID,
              l_xlrv_rec.IMR_ID,
              l_xlrv_rec.XHR_ID_DETAILS,
              l_xlrv_rec.QUANTITY,
              l_xlrv_rec.ATTRIBUTE_CATEGORY,
              l_xlrv_rec.ATTRIBUTE1,
              l_xlrv_rec.ATTRIBUTE2,
              l_xlrv_rec.ATTRIBUTE3,
              l_xlrv_rec.ATTRIBUTE4,
              l_xlrv_rec.ATTRIBUTE5,
              l_xlrv_rec.ATTRIBUTE6,
              l_xlrv_rec.ATTRIBUTE7,
              l_xlrv_rec.ATTRIBUTE8,
              l_xlrv_rec.ATTRIBUTE9,
              l_xlrv_rec.ATTRIBUTE10,
              l_xlrv_rec.ATTRIBUTE11,
              l_xlrv_rec.ATTRIBUTE12,
              l_xlrv_rec.ATTRIBUTE13,
              l_xlrv_rec.ATTRIBUTE14,
              l_xlrv_rec.ATTRIBUTE15,
              l_xlrv_rec.ORG_ID,
              l_xlrv_rec.REQUEST_ID,
              l_xlrv_rec.PROGRAM_APPLICATION_ID,
              l_xlrv_rec.PROGRAM_ID,
              l_xlrv_rec.PROGRAM_UPDATE_DATE,
              l_xlrv_rec.CREATED_BY,
              l_xlrv_rec.CREATION_DATE,
              l_xlrv_rec.LAST_UPDATED_BY,
              l_xlrv_rec.LAST_UPDATE_DATE,
              l_xlrv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_xlrv_pk_csr%NOTFOUND;
    CLOSE okl_xlrv_pk_csr;
    RETURN(l_xlrv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_xlrv_rec                     IN xlrv_rec_type
  ) RETURN xlrv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xlrv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_XTL_FUND_RQNS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_xlrv_rec	IN xlrv_rec_type
  ) RETURN xlrv_rec_type IS
    l_xlrv_rec	xlrv_rec_type := p_xlrv_rec;
  BEGIN
    IF (l_xlrv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.object_version_number := NULL;
    END IF;
    IF (l_xlrv_rec.irn_id = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.irn_id := NULL;
    END IF;
    IF (l_xlrv_rec.imr_id = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.imr_id := NULL;
    END IF;
    IF (l_xlrv_rec.xhr_id_details = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.xhr_id_details := NULL;
    END IF;
    IF (l_xlrv_rec.quantity = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.quantity := NULL;
    END IF;
    IF (l_xlrv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute_category := NULL;
    END IF;
    IF (l_xlrv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute1 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute2 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute3 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute4 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute5 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute6 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute7 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute8 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute9 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute10 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute11 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute12 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute13 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute14 := NULL;
    END IF;
    IF (l_xlrv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_xlrv_rec.attribute15 := NULL;
    END IF;
    IF (l_xlrv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.org_id := NULL;
    END IF;
    IF (l_xlrv_rec.request_id = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.request_id := NULL;
    END IF;
    IF (l_xlrv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.program_application_id := NULL;
    END IF;
    IF (l_xlrv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.program_id := NULL;
    END IF;
    IF (l_xlrv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_xlrv_rec.program_update_date := NULL;
    END IF;
    IF (l_xlrv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.created_by := NULL;
    END IF;
    IF (l_xlrv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_xlrv_rec.creation_date := NULL;
    END IF;
    IF (l_xlrv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_xlrv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_xlrv_rec.last_update_date := NULL;
    END IF;
    IF (l_xlrv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_xlrv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_xlrv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_XTL_FUND_RQNS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_xlrv_rec IN  xlrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_xlrv_rec.id = OKC_API.G_MISS_NUM OR
       p_xlrv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_xlrv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_xlrv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_xlrv_rec.xhr_id_details = OKC_API.G_MISS_NUM OR
          p_xlrv_rec.xhr_id_details IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'xhr_id_details');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_XTL_FUND_RQNS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_xlrv_rec IN xlrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN xlrv_rec_type,
    p_to	OUT NOCOPY xlr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.irn_id := p_from.irn_id;
    p_to.imr_id := p_from.imr_id;
    p_to.xhr_id_details := p_from.xhr_id_details;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.quantity := p_from.quantity;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN xlr_rec_type,
    p_to	OUT NOCOPY xlrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.irn_id := p_from.irn_id;
    p_to.imr_id := p_from.imr_id;
    p_to.xhr_id_details := p_from.xhr_id_details;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.quantity := p_from.quantity;
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_XTL_FUND_RQNS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_rec                     IN xlrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlrv_rec                     xlrv_rec_type := p_xlrv_rec;
    l_xlr_rec                      xlr_rec_type;
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
    l_return_status := Validate_Attributes(l_xlrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_xlrv_rec);
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
  -- PL/SQL TBL validate_row for:XLRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_tbl                     IN xlrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlrv_tbl.COUNT > 0) THEN
      i := p_xlrv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlrv_rec                     => p_xlrv_tbl(i));
        EXIT WHEN (i = p_xlrv_tbl.LAST);
        i := p_xlrv_tbl.NEXT(i);
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
  ----------------------------------------
  -- insert_row for:OKL_XTL_FUND_RQNS_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlr_rec                      IN xlr_rec_type,
    x_xlr_rec                      OUT NOCOPY xlr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlr_rec                      xlr_rec_type := p_xlr_rec;
    l_def_xlr_rec                  xlr_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_FUND_RQNS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xlr_rec IN  xlr_rec_type,
      x_xlr_rec OUT NOCOPY xlr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlr_rec := p_xlr_rec;
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
      p_xlr_rec,                         -- IN
      l_xlr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_XTL_FUND_RQNS_B(
        id,
        irn_id,
        imr_id,
        xhr_id_details,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        quantity,
        org_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        last_update_login)
      VALUES (
        l_xlr_rec.id,
        l_xlr_rec.irn_id,
        l_xlr_rec.imr_id,
        l_xlr_rec.xhr_id_details,
        l_xlr_rec.object_version_number,
        l_xlr_rec.created_by,
        l_xlr_rec.creation_date,
        l_xlr_rec.last_updated_by,
        l_xlr_rec.last_update_date,
        l_xlr_rec.quantity,
        l_xlr_rec.org_id,
        l_xlr_rec.request_id,
        l_xlr_rec.program_application_id,
        l_xlr_rec.program_id,
        l_xlr_rec.program_update_date,
        l_xlr_rec.attribute_category,
        l_xlr_rec.attribute1,
        l_xlr_rec.attribute2,
        l_xlr_rec.attribute3,
        l_xlr_rec.attribute4,
        l_xlr_rec.attribute5,
        l_xlr_rec.attribute6,
        l_xlr_rec.attribute7,
        l_xlr_rec.attribute8,
        l_xlr_rec.attribute9,
        l_xlr_rec.attribute10,
        l_xlr_rec.attribute11,
        l_xlr_rec.attribute12,
        l_xlr_rec.attribute13,
        l_xlr_rec.attribute14,
        l_xlr_rec.attribute15,
        l_xlr_rec.last_update_login);
    -- Set OUT values
    x_xlr_rec := l_xlr_rec;
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
  -- insert_row for:OKL_XTL_FUND_RQNS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_rec                     IN xlrv_rec_type,
    x_xlrv_rec                     OUT NOCOPY xlrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlrv_rec                     xlrv_rec_type;
    l_def_xlrv_rec                 xlrv_rec_type;
    l_xlr_rec                      xlr_rec_type;
    lx_xlr_rec                     xlr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xlrv_rec	IN xlrv_rec_type
    ) RETURN xlrv_rec_type IS
      l_xlrv_rec	xlrv_rec_type := p_xlrv_rec;
    BEGIN
      l_xlrv_rec.CREATION_DATE := SYSDATE;
      l_xlrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_xlrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_xlrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_xlrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_xlrv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_FUND_RQNS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xlrv_rec IN  xlrv_rec_type,
      x_xlrv_rec OUT NOCOPY xlrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlrv_rec := p_xlrv_rec;
      x_xlrv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_xlrv_rec := null_out_defaults(p_xlrv_rec);
    -- Set primary key value
    l_xlrv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_xlrv_rec,                        -- IN
      l_def_xlrv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_xlrv_rec := fill_who_columns(l_def_xlrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xlrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xlrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xlrv_rec, l_xlr_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xlr_rec,
      lx_xlr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xlr_rec, l_def_xlrv_rec);
    -- Set OUT values
    x_xlrv_rec := l_def_xlrv_rec;
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
  -- PL/SQL TBL insert_row for:XLRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_tbl                     IN xlrv_tbl_type,
    x_xlrv_tbl                     OUT NOCOPY xlrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlrv_tbl.COUNT > 0) THEN
      i := p_xlrv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlrv_rec                     => p_xlrv_tbl(i),
          x_xlrv_rec                     => x_xlrv_tbl(i));
        EXIT WHEN (i = p_xlrv_tbl.LAST);
        i := p_xlrv_tbl.NEXT(i);
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
  --------------------------------------
  -- lock_row for:OKL_XTL_FUND_RQNS_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlr_rec                      IN xlr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_xlr_rec IN xlr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XTL_FUND_RQNS_B
     WHERE ID = p_xlr_rec.id
       AND OBJECT_VERSION_NUMBER = p_xlr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_xlr_rec IN xlr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XTL_FUND_RQNS_B
    WHERE ID = p_xlr_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_XTL_FUND_RQNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_XTL_FUND_RQNS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_xlr_rec);
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
      OPEN lchk_csr(p_xlr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_xlr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number != p_xlr_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for:OKL_XTL_FUND_RQNS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_rec                     IN xlrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlr_rec                      xlr_rec_type;
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
    migrate(p_xlrv_rec, l_xlr_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xlr_rec
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
  -- PL/SQL TBL lock_row for:XLRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_tbl                     IN xlrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlrv_tbl.COUNT > 0) THEN
      i := p_xlrv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlrv_rec                     => p_xlrv_tbl(i));
        EXIT WHEN (i = p_xlrv_tbl.LAST);
        i := p_xlrv_tbl.NEXT(i);
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
  ----------------------------------------
  -- update_row for:OKL_XTL_FUND_RQNS_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlr_rec                      IN xlr_rec_type,
    x_xlr_rec                      OUT NOCOPY xlr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlr_rec                      xlr_rec_type := p_xlr_rec;
    l_def_xlr_rec                  xlr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xlr_rec	IN xlr_rec_type,
      x_xlr_rec	OUT NOCOPY xlr_rec_type
    ) RETURN VARCHAR2 IS
      l_xlr_rec                      xlr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlr_rec := p_xlr_rec;
      -- Get current database values
      l_xlr_rec := get_rec(p_xlr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xlr_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.id := l_xlr_rec.id;
      END IF;
      IF (x_xlr_rec.irn_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.irn_id := l_xlr_rec.irn_id;
      END IF;
      IF (x_xlr_rec.imr_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.imr_id := l_xlr_rec.imr_id;
      END IF;
      IF (x_xlr_rec.xhr_id_details = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.xhr_id_details := l_xlr_rec.xhr_id_details;
      END IF;
      IF (x_xlr_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.object_version_number := l_xlr_rec.object_version_number;
      END IF;
      IF (x_xlr_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.created_by := l_xlr_rec.created_by;
      END IF;
      IF (x_xlr_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_xlr_rec.creation_date := l_xlr_rec.creation_date;
      END IF;
      IF (x_xlr_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.last_updated_by := l_xlr_rec.last_updated_by;
      END IF;
      IF (x_xlr_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_xlr_rec.last_update_date := l_xlr_rec.last_update_date;
      END IF;
      IF (x_xlr_rec.quantity = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.quantity := l_xlr_rec.quantity;
      END IF;
      IF (x_xlr_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.org_id := l_xlr_rec.org_id;
      END IF;
      IF (x_xlr_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.request_id := l_xlr_rec.request_id;
      END IF;
      IF (x_xlr_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.program_application_id := l_xlr_rec.program_application_id;
      END IF;
      IF (x_xlr_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.program_id := l_xlr_rec.program_id;
      END IF;
      IF (x_xlr_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_xlr_rec.program_update_date := l_xlr_rec.program_update_date;
      END IF;
      IF (x_xlr_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute_category := l_xlr_rec.attribute_category;
      END IF;
      IF (x_xlr_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute1 := l_xlr_rec.attribute1;
      END IF;
      IF (x_xlr_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute2 := l_xlr_rec.attribute2;
      END IF;
      IF (x_xlr_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute3 := l_xlr_rec.attribute3;
      END IF;
      IF (x_xlr_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute4 := l_xlr_rec.attribute4;
      END IF;
      IF (x_xlr_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute5 := l_xlr_rec.attribute5;
      END IF;
      IF (x_xlr_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute6 := l_xlr_rec.attribute6;
      END IF;
      IF (x_xlr_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute7 := l_xlr_rec.attribute7;
      END IF;
      IF (x_xlr_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute8 := l_xlr_rec.attribute8;
      END IF;
      IF (x_xlr_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute9 := l_xlr_rec.attribute9;
      END IF;
      IF (x_xlr_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute10 := l_xlr_rec.attribute10;
      END IF;
      IF (x_xlr_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute11 := l_xlr_rec.attribute11;
      END IF;
      IF (x_xlr_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute12 := l_xlr_rec.attribute12;
      END IF;
      IF (x_xlr_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute13 := l_xlr_rec.attribute13;
      END IF;
      IF (x_xlr_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute14 := l_xlr_rec.attribute14;
      END IF;
      IF (x_xlr_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlr_rec.attribute15 := l_xlr_rec.attribute15;
      END IF;
      IF (x_xlr_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_xlr_rec.last_update_login := l_xlr_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_FUND_RQNS_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xlr_rec IN  xlr_rec_type,
      x_xlr_rec OUT NOCOPY xlr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlr_rec := p_xlr_rec;
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
      p_xlr_rec,                         -- IN
      l_xlr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xlr_rec, l_def_xlr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_XTL_FUND_RQNS_B
    SET IRN_ID = l_def_xlr_rec.irn_id,
        IMR_ID = l_def_xlr_rec.imr_id,
        XHR_ID_DETAILS = l_def_xlr_rec.xhr_id_details,
        OBJECT_VERSION_NUMBER = l_def_xlr_rec.object_version_number,
        CREATED_BY = l_def_xlr_rec.created_by,
        CREATION_DATE = l_def_xlr_rec.creation_date,
        LAST_UPDATED_BY = l_def_xlr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_xlr_rec.last_update_date,
        QUANTITY = l_def_xlr_rec.quantity,
        ORG_ID = l_def_xlr_rec.org_id,
        REQUEST_ID = l_def_xlr_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_xlr_rec.program_application_id,
        PROGRAM_ID = l_def_xlr_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_xlr_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_xlr_rec.attribute_category,
        ATTRIBUTE1 = l_def_xlr_rec.attribute1,
        ATTRIBUTE2 = l_def_xlr_rec.attribute2,
        ATTRIBUTE3 = l_def_xlr_rec.attribute3,
        ATTRIBUTE4 = l_def_xlr_rec.attribute4,
        ATTRIBUTE5 = l_def_xlr_rec.attribute5,
        ATTRIBUTE6 = l_def_xlr_rec.attribute6,
        ATTRIBUTE7 = l_def_xlr_rec.attribute7,
        ATTRIBUTE8 = l_def_xlr_rec.attribute8,
        ATTRIBUTE9 = l_def_xlr_rec.attribute9,
        ATTRIBUTE10 = l_def_xlr_rec.attribute10,
        ATTRIBUTE11 = l_def_xlr_rec.attribute11,
        ATTRIBUTE12 = l_def_xlr_rec.attribute12,
        ATTRIBUTE13 = l_def_xlr_rec.attribute13,
        ATTRIBUTE14 = l_def_xlr_rec.attribute14,
        ATTRIBUTE15 = l_def_xlr_rec.attribute15,
        LAST_UPDATE_LOGIN = l_def_xlr_rec.last_update_login
    WHERE ID = l_def_xlr_rec.id;

    x_xlr_rec := l_def_xlr_rec;
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
  -- update_row for:OKL_XTL_FUND_RQNS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_rec                     IN xlrv_rec_type,
    x_xlrv_rec                     OUT NOCOPY xlrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlrv_rec                     xlrv_rec_type := p_xlrv_rec;
    l_def_xlrv_rec                 xlrv_rec_type;
    l_xlr_rec                      xlr_rec_type;
    lx_xlr_rec                     xlr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xlrv_rec	IN xlrv_rec_type
    ) RETURN xlrv_rec_type IS
      l_xlrv_rec	xlrv_rec_type := p_xlrv_rec;
    BEGIN
      l_xlrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_xlrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_xlrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_xlrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xlrv_rec	IN xlrv_rec_type,
      x_xlrv_rec	OUT NOCOPY xlrv_rec_type
    ) RETURN VARCHAR2 IS
      l_xlrv_rec                     xlrv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlrv_rec := p_xlrv_rec;
      -- Get current database values
      l_xlrv_rec := get_rec(p_xlrv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_xlrv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.id := l_xlrv_rec.id;
      END IF;
      IF (x_xlrv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.object_version_number := l_xlrv_rec.object_version_number;
      END IF;
      IF (x_xlrv_rec.irn_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.irn_id := l_xlrv_rec.irn_id;
      END IF;
      IF (x_xlrv_rec.imr_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.imr_id := l_xlrv_rec.imr_id;
      END IF;
      IF (x_xlrv_rec.xhr_id_details = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.xhr_id_details := l_xlrv_rec.xhr_id_details;
      END IF;
      IF (x_xlrv_rec.quantity = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.quantity := l_xlrv_rec.quantity;
      END IF;
      IF (x_xlrv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute_category := l_xlrv_rec.attribute_category;
      END IF;
      IF (x_xlrv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute1 := l_xlrv_rec.attribute1;
      END IF;
      IF (x_xlrv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute2 := l_xlrv_rec.attribute2;
      END IF;
      IF (x_xlrv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute3 := l_xlrv_rec.attribute3;
      END IF;
      IF (x_xlrv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute4 := l_xlrv_rec.attribute4;
      END IF;
      IF (x_xlrv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute5 := l_xlrv_rec.attribute5;
      END IF;
      IF (x_xlrv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute6 := l_xlrv_rec.attribute6;
      END IF;
      IF (x_xlrv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute7 := l_xlrv_rec.attribute7;
      END IF;
      IF (x_xlrv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute8 := l_xlrv_rec.attribute8;
      END IF;
      IF (x_xlrv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute9 := l_xlrv_rec.attribute9;
      END IF;
      IF (x_xlrv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute10 := l_xlrv_rec.attribute10;
      END IF;
      IF (x_xlrv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute11 := l_xlrv_rec.attribute11;
      END IF;
      IF (x_xlrv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute12 := l_xlrv_rec.attribute12;
      END IF;
      IF (x_xlrv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute13 := l_xlrv_rec.attribute13;
      END IF;
      IF (x_xlrv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute14 := l_xlrv_rec.attribute14;
      END IF;
      IF (x_xlrv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_xlrv_rec.attribute15 := l_xlrv_rec.attribute15;
      END IF;
      IF (x_xlrv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.org_id := l_xlrv_rec.org_id;
      END IF;
      IF (x_xlrv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.request_id := l_xlrv_rec.request_id;
      END IF;
      IF (x_xlrv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.program_application_id := l_xlrv_rec.program_application_id;
      END IF;
      IF (x_xlrv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.program_id := l_xlrv_rec.program_id;
      END IF;
      IF (x_xlrv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_xlrv_rec.program_update_date := l_xlrv_rec.program_update_date;
      END IF;
      IF (x_xlrv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.created_by := l_xlrv_rec.created_by;
      END IF;
      IF (x_xlrv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_xlrv_rec.creation_date := l_xlrv_rec.creation_date;
      END IF;
      IF (x_xlrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.last_updated_by := l_xlrv_rec.last_updated_by;
      END IF;
      IF (x_xlrv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_xlrv_rec.last_update_date := l_xlrv_rec.last_update_date;
      END IF;
      IF (x_xlrv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_xlrv_rec.last_update_login := l_xlrv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_XTL_FUND_RQNS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_xlrv_rec IN  xlrv_rec_type,
      x_xlrv_rec OUT NOCOPY xlrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xlrv_rec := p_xlrv_rec;
      x_xlrv_rec.OBJECT_VERSION_NUMBER := NVL(x_xlrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_xlrv_rec,                        -- IN
      l_xlrv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xlrv_rec, l_def_xlrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_xlrv_rec := fill_who_columns(l_def_xlrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xlrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xlrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_xlrv_rec, l_xlr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xlr_rec,
      lx_xlr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xlr_rec, l_def_xlrv_rec);
    x_xlrv_rec := l_def_xlrv_rec;
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
  -- PL/SQL TBL update_row for:XLRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_tbl                     IN xlrv_tbl_type,
    x_xlrv_tbl                     OUT NOCOPY xlrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlrv_tbl.COUNT > 0) THEN
      i := p_xlrv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlrv_rec                     => p_xlrv_tbl(i),
          x_xlrv_rec                     => x_xlrv_tbl(i));
        EXIT WHEN (i = p_xlrv_tbl.LAST);
        i := p_xlrv_tbl.NEXT(i);
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
  ----------------------------------------
  -- delete_row for:OKL_XTL_FUND_RQNS_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlr_rec                      IN xlr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlr_rec                      xlr_rec_type:= p_xlr_rec;
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
    DELETE FROM OKL_XTL_FUND_RQNS_B
     WHERE ID = l_xlr_rec.id;

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
  -- delete_row for:OKL_XTL_FUND_RQNS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_rec                     IN xlrv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_xlrv_rec                     xlrv_rec_type := p_xlrv_rec;
    l_xlr_rec                      xlr_rec_type;
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
    migrate(l_xlrv_rec, l_xlr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_xlr_rec
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
  -- PL/SQL TBL delete_row for:XLRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xlrv_tbl                     IN xlrv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xlrv_tbl.COUNT > 0) THEN
      i := p_xlrv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_xlrv_rec                     => p_xlrv_tbl(i));
        EXIT WHEN (i = p_xlrv_tbl.LAST);
        i := p_xlrv_tbl.NEXT(i);
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
*/
END OKL_XLR_PVT;

/
