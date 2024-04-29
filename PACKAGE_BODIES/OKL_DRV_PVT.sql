--------------------------------------------------------
--  DDL for Package Body OKL_DRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DRV_PVT" AS
/* $Header: OKLSDRVB.pls 120.4 2007/08/14 14:36:45 gkhuntet noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
    l_pk_value NUMBER;
    CURSOR c_pk_csr IS SELECT okl_disb_rule_vendor_sites_s.NEXTVAL FROM DUAL;
  BEGIN
  /* Fetch the pk value from the sequence */
    OPEN c_pk_csr;
    FETCH c_pk_csr INTO l_pk_value;
    CLOSE c_pk_csr;
    RETURN l_pk_value;
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
  -- FUNCTION get_rec for: OKL_DISB_RULE_VENDOR_SITES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_drv_rec                      IN drv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN drv_rec_type IS
    CURSOR okl_drv_pk_csr (p_disb_rule_vendor_site_id IN NUMBER) IS
    SELECT
            DISB_RULE_VENDOR_SITE_ID,
            OBJECT_VERSION_NUMBER,
            DISB_RULE_ID,
            VENDOR_ID,
            VENDOR_SITE_ID,
            START_DATE,
            END_DATE,
            INVOICE_SEQ_START,
            INVOICE_SEQ_END,
            NEXT_INV_SEQ,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Disb_Rule_Vendor_Sites
     WHERE okl_disb_rule_vendor_sites.disb_rule_vendor_site_id = p_disb_rule_vendor_site_id;
    l_okl_drv_pk                   okl_drv_pk_csr%ROWTYPE;
    l_drv_rec                      drv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_drv_pk_csr (p_drv_rec.disb_rule_vendor_site_id);
    FETCH okl_drv_pk_csr INTO
              l_drv_rec.disb_rule_vendor_site_id,
              l_drv_rec.object_version_number,
              l_drv_rec.disb_rule_id,
              l_drv_rec.vendor_id,
              l_drv_rec.vendor_site_id,
              l_drv_rec.start_date,
              l_drv_rec.end_date,
              l_drv_rec.invoice_seq_start,
              l_drv_rec.invoice_seq_end,
              l_drv_rec.next_inv_seq,
              l_drv_rec.attribute_category,
              l_drv_rec.attribute1,
              l_drv_rec.attribute2,
              l_drv_rec.attribute3,
              l_drv_rec.attribute4,
              l_drv_rec.attribute5,
              l_drv_rec.attribute6,
              l_drv_rec.attribute7,
              l_drv_rec.attribute8,
              l_drv_rec.attribute9,
              l_drv_rec.attribute10,
              l_drv_rec.attribute11,
              l_drv_rec.attribute12,
              l_drv_rec.attribute13,
              l_drv_rec.attribute14,
              l_drv_rec.attribute15,
              l_drv_rec.created_by,
              l_drv_rec.creation_date,
              l_drv_rec.last_updated_by,
              l_drv_rec.last_update_date,
              l_drv_rec.last_update_login;
    x_no_data_found := okl_drv_pk_csr%NOTFOUND;
    CLOSE okl_drv_pk_csr;
    RETURN(l_drv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_drv_rec                      IN drv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN drv_rec_type IS
    l_drv_rec                      drv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec := get_rec(p_drv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'DISB_RULE_VENDOR_SITE_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_drv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_drv_rec                      IN drv_rec_type
  ) RETURN drv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_drv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_DISB_RULE_VENDOR_SITES
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_drv_rec   IN drv_rec_type
  ) RETURN drv_rec_type IS
    l_drv_rec                      drv_rec_type := p_drv_rec;
  BEGIN
    IF (l_drv_rec.disb_rule_vendor_site_id = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.disb_rule_vendor_site_id := NULL;
    END IF;
    IF (l_drv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.object_version_number := NULL;
    END IF;
    IF (l_drv_rec.disb_rule_id = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.disb_rule_id := NULL;
    END IF;
    IF (l_drv_rec.vendor_id = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.vendor_id := NULL;
    END IF;
    IF (l_drv_rec.vendor_site_id = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.vendor_site_id := NULL;
    END IF;
    IF (l_drv_rec.start_date = OKL_API.G_MISS_DATE ) THEN
      l_drv_rec.start_date := NULL;
    END IF;
    IF (l_drv_rec.end_date = OKL_API.G_MISS_DATE ) THEN
      l_drv_rec.end_date := NULL;
    END IF;
    IF (l_drv_rec.invoice_seq_start = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.invoice_seq_start := NULL;
    END IF;
    IF (l_drv_rec.invoice_seq_end = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.invoice_seq_end := NULL;
    END IF;
    IF (l_drv_rec.next_inv_seq = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.next_inv_seq := NULL;
    END IF;
    IF (l_drv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute_category := NULL;
    END IF;
    IF (l_drv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute1 := NULL;
    END IF;
    IF (l_drv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute2 := NULL;
    END IF;
    IF (l_drv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute3 := NULL;
    END IF;
    IF (l_drv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute4 := NULL;
    END IF;
    IF (l_drv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute5 := NULL;
    END IF;
    IF (l_drv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute6 := NULL;
    END IF;
    IF (l_drv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute7 := NULL;
    END IF;
    IF (l_drv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute8 := NULL;
    END IF;
    IF (l_drv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute9 := NULL;
    END IF;
    IF (l_drv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute10 := NULL;
    END IF;
    IF (l_drv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute11 := NULL;
    END IF;
    IF (l_drv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute12 := NULL;
    END IF;
    IF (l_drv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute13 := NULL;
    END IF;
    IF (l_drv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute14 := NULL;
    END IF;
    IF (l_drv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_drv_rec.attribute15 := NULL;
    END IF;
    IF (l_drv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.created_by := NULL;
    END IF;
    IF (l_drv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_drv_rec.creation_date := NULL;
    END IF;
    IF (l_drv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.last_updated_by := NULL;
    END IF;
    IF (l_drv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_drv_rec.last_update_date := NULL;
    END IF;
    IF (l_drv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_drv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_drv_rec);
  END null_out_defaults;
  -------------------------------------------------------
  -- Validate_Attributes for: DISB_RULE_VENDOR_SITE_ID --
  -------------------------------------------------------
  PROCEDURE validate_disb_rule_1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_disb_rule_vendor_site_id     IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_disb_rule_vendor_site_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'disb_rule_vendor_site_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_disb_rule_1;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  -------------------------------------------
  -- Validate_Attributes for: DISB_RULE_ID --
  -------------------------------------------
  PROCEDURE validate_disb_rule_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_disb_rule_id                 IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_disb_rule_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'disb_rule_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_disb_rule_id;
  ----------------------------------------
  -- Validate_Attributes for: VENDOR_ID --
  ----------------------------------------
  PROCEDURE validate_vendor_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vendor_id                    IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_vendor_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_id;
  ---------------------------------------------
  -- Validate_Attributes for: VENDOR_SITE_ID --
  ---------------------------------------------
  PROCEDURE validate_vendor_site_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vendor_site_id               IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_vendor_site_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_site_id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_site_id;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------------
  -- Validate_Attributes for:OKL_DISB_RULE_VENDOR_SITES --
  --------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_drv_rec                      IN drv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- disb_rule_vendor_site_id
    -- ***
    validate_disb_rule_1(x_return_status, p_drv_rec.disb_rule_vendor_site_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_drv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- disb_rule_id
    -- ***
    validate_disb_rule_id(x_return_status, p_drv_rec.disb_rule_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- vendor_id
    -- ***
    validate_vendor_id(x_return_status, p_drv_rec.vendor_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- vendor_site_id
    -- ***
    validate_vendor_site_id(x_return_status, p_drv_rec.vendor_site_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate Record for:OKL_DISB_RULE_VENDOR_SITES --
  ----------------------------------------------------
  FUNCTION Validate_Record (
    p_drv_rec IN drv_rec_type,
    p_db_drv_rec IN drv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_drv_rec IN drv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_drv_rec                   drv_rec_type := get_rec(p_drv_rec);
  BEGIN
    l_return_status := Validate_Record(p_drv_rec => p_drv_rec,
                                       p_db_drv_rec => l_db_drv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- validate_row for:OKL_DISB_RULE_VENDOR_SITES --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec                      drv_rec_type := p_drv_rec;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_drv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_drv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_DISB_RULE_VENDOR_SITES --
  ------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      i := p_drv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_drv_rec                      => p_drv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_drv_tbl.LAST);
        i := p_drv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_DISB_RULE_VENDOR_SITES --
  ------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_drv_tbl                      => p_drv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -----------------------------------------------
  -- insert_row for:OKL_DISB_RULE_VENDOR_SITES --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type,
    x_drv_rec                      OUT NOCOPY drv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec                      drv_rec_type := p_drv_rec;
    l_def_drv_rec                  drv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_drv_rec IN drv_rec_type
    ) RETURN drv_rec_type IS
      l_drv_rec drv_rec_type := p_drv_rec;
    BEGIN
      l_drv_rec.CREATION_DATE := SYSDATE;
      l_drv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_drv_rec.LAST_UPDATE_DATE := l_drv_rec.CREATION_DATE;
      l_drv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_drv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_drv_rec);
    END fill_who_columns;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_DISB_RULE_VENDOR_SITES --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_drv_rec IN drv_rec_type,
      x_drv_rec OUT NOCOPY drv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_drv_rec := p_drv_rec;
      x_drv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_drv_rec := null_out_defaults(p_drv_rec);
    -- Set primary key value
    l_drv_rec.DISB_RULE_VENDOR_SITE_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_drv_rec,                         -- IN
      l_def_drv_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_drv_rec := fill_who_columns(l_def_drv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_drv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_drv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --DBMS_OUTPUT.put_line('Before insert in DRV PVT');
    --DBMS_OUTPUT.put_line('l_drv_rec.created_by'  || l_def_drv_rec.created_by);


    INSERT INTO OKL_DISB_RULE_VENDOR_SITES(
      disb_rule_vendor_site_id,
      object_version_number,
      disb_rule_id,
      vendor_id,
      vendor_site_id,
      start_date,
      end_date,
      invoice_seq_start,
      invoice_seq_end,
      next_inv_seq,
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
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_def_drv_rec.disb_rule_vendor_site_id,
      l_def_drv_rec.object_version_number,
      l_def_drv_rec.disb_rule_id,
      l_def_drv_rec.vendor_id,
      l_def_drv_rec.vendor_site_id,
      l_def_drv_rec.start_date,
      l_def_drv_rec.end_date,
      l_def_drv_rec.invoice_seq_start,
      l_def_drv_rec.invoice_seq_end,
      l_def_drv_rec.next_inv_seq,
      l_def_drv_rec.attribute_category,
      l_def_drv_rec.attribute1,
      l_def_drv_rec.attribute2,
      l_def_drv_rec.attribute3,
      l_def_drv_rec.attribute4,
      l_def_drv_rec.attribute5,
      l_def_drv_rec.attribute6,
      l_def_drv_rec.attribute7,
      l_def_drv_rec.attribute8,
      l_def_drv_rec.attribute9,
      l_def_drv_rec.attribute10,
      l_def_drv_rec.attribute11,
      l_def_drv_rec.attribute12,
      l_def_drv_rec.attribute13,
      l_def_drv_rec.attribute14,
      l_def_drv_rec.attribute15,
      l_def_drv_rec.created_by,
      l_def_drv_rec.creation_date,
      l_def_drv_rec.last_updated_by,
      l_def_drv_rec.last_update_date,
      l_def_drv_rec.last_update_login);
    -- Set OUT values
    x_drv_rec := l_drv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:DRV_TBL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      i := p_drv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_drv_rec                      => p_drv_tbl(i),
            x_drv_rec                      => x_drv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_drv_tbl.LAST);
        i := p_drv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:DRV_TBL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_drv_tbl                      => p_drv_tbl,
        x_drv_tbl                      => x_drv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------------
  -- lock_row for:OKL_DISB_RULE_VENDOR_SITES --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_drv_rec IN drv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_DISB_RULE_VENDOR_SITES
     WHERE DISB_RULE_VENDOR_SITE_ID = p_drv_rec.disb_rule_vendor_site_id
       AND OBJECT_VERSION_NUMBER = p_drv_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_drv_rec IN drv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_DISB_RULE_VENDOR_SITES
     WHERE DISB_RULE_VENDOR_SITE_ID = p_drv_rec.disb_rule_vendor_site_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_DISB_RULE_VENDOR_SITES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_DISB_RULE_VENDOR_SITES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    --debug_proc('Lock  disb_rule_vendor_site_id' || p_drv_rec.disb_rule_vendor_site_id);
   -- debug_proc('Lock object_version_number' || p_drv_rec.object_version_number);

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_drv_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_drv_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_drv_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_drv_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------------------
  -- lock_row for: OKL_DISB_RULE_VENDOR_SITES --
  ----------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec                      drv_rec_type:=p_drv_rec;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_drv_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:DRV_TBL --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      i := p_drv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_drv_rec                      => p_drv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_drv_tbl.LAST);
        i := p_drv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:DRV_TBL --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_drv_tbl                      => p_drv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -----------------------------------------------
  -- update_row for:OKL_DISB_RULE_VENDOR_SITES --
  -----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type,
    x_drv_rec                      OUT NOCOPY drv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec                      drv_rec_type := p_drv_rec;
    l_def_drv_rec                  drv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_drv_rec IN drv_rec_type,
      x_drv_rec OUT NOCOPY drv_rec_type
    ) RETURN VARCHAR2 IS
      l_drv_rec                      drv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_drv_rec := p_drv_rec;
      -- Get current database values
        --g_debug_proc('IN main update');
      l_drv_rec := get_rec(p_drv_rec, l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_drv_rec.disb_rule_vendor_site_id IS NULL THEN
          x_drv_rec.disb_rule_vendor_site_id := l_drv_rec.disb_rule_vendor_site_id;
        END IF;
        IF x_drv_rec.object_version_number IS NULL THEN
          x_drv_rec.object_version_number := l_drv_rec.object_version_number;
        END IF;
        IF x_drv_rec.disb_rule_id IS NULL THEN
          x_drv_rec.disb_rule_id := l_drv_rec.disb_rule_id;
        END IF;
        IF x_drv_rec.vendor_id IS NULL THEN
          x_drv_rec.vendor_id := l_drv_rec.vendor_id;
        END IF;
        IF x_drv_rec.vendor_site_id IS NULL THEN
          x_drv_rec.vendor_site_id := l_drv_rec.vendor_site_id;
        END IF;
      	--Code commented by gkhuntet.

	IF x_drv_rec.start_date IS NULL THEN
          x_drv_rec.start_date := l_drv_rec.start_date;
        END IF;
        IF x_drv_rec.end_date IS NULL THEN
          x_drv_rec.end_date := l_drv_rec.end_date;
        END IF;
        IF x_drv_rec.invoice_seq_start IS NULL THEN
          x_drv_rec.invoice_seq_start := l_drv_rec.invoice_seq_start;
        END IF;
        IF x_drv_rec.invoice_seq_end IS NULL THEN
          x_drv_rec.invoice_seq_end := l_drv_rec.invoice_seq_end;
        END IF;

        IF x_drv_rec.next_inv_seq IS NULL THEN
          x_drv_rec.next_inv_seq := l_drv_rec.next_inv_seq;
        END IF;
        IF x_drv_rec.attribute_category IS NULL THEN
          x_drv_rec.attribute_category := l_drv_rec.attribute_category;
        END IF;
        IF x_drv_rec.attribute1 IS NULL THEN
          x_drv_rec.attribute1 := l_drv_rec.attribute1;
        END IF;
        IF x_drv_rec.attribute2 IS NULL THEN
          x_drv_rec.attribute2 := l_drv_rec.attribute2;
        END IF;
        IF x_drv_rec.attribute3 IS NULL THEN
          x_drv_rec.attribute3 := l_drv_rec.attribute3;
        END IF;
        IF x_drv_rec.attribute4 IS NULL THEN
          x_drv_rec.attribute4 := l_drv_rec.attribute4;
        END IF;
        IF x_drv_rec.attribute5 IS NULL THEN
          x_drv_rec.attribute5 := l_drv_rec.attribute5;
        END IF;
        IF x_drv_rec.attribute6 IS NULL THEN
          x_drv_rec.attribute6 := l_drv_rec.attribute6;
        END IF;
        IF x_drv_rec.attribute7 IS NULL THEN
          x_drv_rec.attribute7 := l_drv_rec.attribute7;
        END IF;
        IF x_drv_rec.attribute8 IS NULL THEN
          x_drv_rec.attribute8 := l_drv_rec.attribute8;
        END IF;
        IF x_drv_rec.attribute9 IS NULL THEN
          x_drv_rec.attribute9 := l_drv_rec.attribute9;
        END IF;
        IF x_drv_rec.attribute10 IS NULL THEN
          x_drv_rec.attribute10 := l_drv_rec.attribute10;
        END IF;
        IF x_drv_rec.attribute11 IS NULL THEN
          x_drv_rec.attribute11 := l_drv_rec.attribute11;
        END IF;
        IF x_drv_rec.attribute12 IS NULL THEN
          x_drv_rec.attribute12 := l_drv_rec.attribute12;
        END IF;
        IF x_drv_rec.attribute13 IS NULL THEN
          x_drv_rec.attribute13 := l_drv_rec.attribute13;
        END IF;
        IF x_drv_rec.attribute14 IS NULL THEN
          x_drv_rec.attribute14 := l_drv_rec.attribute14;
        END IF;
        IF x_drv_rec.attribute15 IS NULL THEN
          x_drv_rec.attribute15 := l_drv_rec.attribute15;
        END IF;
        IF x_drv_rec.created_by IS NULL THEN
          x_drv_rec.created_by := l_drv_rec.created_by;
        END IF;
        IF x_drv_rec.creation_date IS NULL THEN
          x_drv_rec.creation_date := l_drv_rec.creation_date;
        END IF;
        IF x_drv_rec.last_updated_by IS NULL THEN
          x_drv_rec.last_updated_by := l_drv_rec.last_updated_by;
        END IF;
        IF x_drv_rec.last_update_date IS NULL THEN
          x_drv_rec.last_update_date := l_drv_rec.last_update_date;
        END IF;
        IF x_drv_rec.last_update_login IS NULL THEN
          x_drv_rec.last_update_login := l_drv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_DISB_RULE_VENDOR_SITES --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_drv_rec IN drv_rec_type,
      x_drv_rec OUT NOCOPY drv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_drv_rec := p_drv_rec;
      x_drv_rec.OBJECT_VERSION_NUMBER := p_drv_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--g_debug_proc('Params ' || p_drv_rec.START_DATE || ' , ' || p_drv_rec.invoice_seq_start || ' , ' || p_drv_rec.disb_rule_vendor_site_id);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_drv_rec,                         -- IN
      l_drv_rec);                        -- OUT
    --- If any errors happen abort API
    --g_debug_proc('OBJECT_VERSION_NUMBER ' || l_drv_rec.OBJECT_VERSION_NUMBER);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_drv_rec, l_def_drv_rec);
    --g_debug_proc('OBJECT_VERSION_NUMBER ' || l_def_drv_rec.OBJECT_VERSION_NUMBER);

    --g_debug_proc('Params ' || l_def_drv_rec.START_DATE || ' , ' || l_def_drv_rec.invoice_seq_start || ' , ' || l_def_drv_rec.disb_rule_vendor_site_id);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
     --g_debug_proc('update query ');



    UPDATE OKL_DISB_RULE_VENDOR_SITES
    SET OBJECT_VERSION_NUMBER = l_def_drv_rec.object_version_number,
        DISB_RULE_ID = l_def_drv_rec.disb_rule_id,
        VENDOR_ID = l_def_drv_rec.vendor_id,
        VENDOR_SITE_ID = l_def_drv_rec.vendor_site_id,
        START_DATE = l_def_drv_rec.start_date,
        END_DATE = l_def_drv_rec.end_date,
        INVOICE_SEQ_START = l_def_drv_rec.invoice_seq_start,
        INVOICE_SEQ_END = l_def_drv_rec.invoice_seq_end,
        NEXT_INV_SEQ = l_def_drv_rec.next_inv_seq,
        ATTRIBUTE_CATEGORY = l_def_drv_rec.attribute_category,
        ATTRIBUTE1 = l_def_drv_rec.attribute1,
        ATTRIBUTE2 = l_def_drv_rec.attribute2,
        ATTRIBUTE3 = l_def_drv_rec.attribute3,
        ATTRIBUTE4 = l_def_drv_rec.attribute4,
        ATTRIBUTE5 = l_def_drv_rec.attribute5,
        ATTRIBUTE6 = l_def_drv_rec.attribute6,
        ATTRIBUTE7 = l_def_drv_rec.attribute7,
        ATTRIBUTE8 = l_def_drv_rec.attribute8,
        ATTRIBUTE9 = l_def_drv_rec.attribute9,
        ATTRIBUTE10 = l_def_drv_rec.attribute10,
        ATTRIBUTE11 = l_def_drv_rec.attribute11,
        ATTRIBUTE12 = l_def_drv_rec.attribute12,
        ATTRIBUTE13 = l_def_drv_rec.attribute13,
        ATTRIBUTE14 = l_def_drv_rec.attribute14,
        ATTRIBUTE15 = l_def_drv_rec.attribute15,
        CREATED_BY = l_def_drv_rec.created_by,
        CREATION_DATE = l_def_drv_rec.creation_date,
        LAST_UPDATED_BY = l_def_drv_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_drv_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_drv_rec.last_update_login
    WHERE DISB_RULE_VENDOR_SITE_ID = l_def_drv_rec.disb_rule_vendor_site_id;

    x_drv_rec := l_drv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------------
  -- update_row for:OKL_DISB_RULE_VENDOR_SITES --
  -----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type,
    x_drv_rec                      OUT NOCOPY drv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec                      drv_rec_type := p_drv_rec;
    l_def_drv_rec                  drv_rec_type;
    l_db_drv_rec                   drv_rec_type;
    lx_drv_rec                     drv_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_drv_rec IN drv_rec_type
    ) RETURN drv_rec_type IS
      l_drv_rec drv_rec_type := p_drv_rec;
    BEGIN
      l_drv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_drv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_drv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_drv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_drv_rec IN drv_rec_type,
      x_drv_rec OUT NOCOPY drv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_drv_rec := p_drv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_drv_rec := get_rec(p_drv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_drv_rec.disb_rule_vendor_site_id IS NULL THEN
          x_drv_rec.disb_rule_vendor_site_id := l_db_drv_rec.disb_rule_vendor_site_id;
        END IF;
        IF x_drv_rec.disb_rule_id IS NULL THEN
          x_drv_rec.disb_rule_id := l_db_drv_rec.disb_rule_id;
        END IF;
        IF x_drv_rec.vendor_id IS NULL THEN
          x_drv_rec.vendor_id := l_db_drv_rec.vendor_id;
        END IF;
        IF x_drv_rec.vendor_site_id IS NULL THEN
          x_drv_rec.vendor_site_id := l_db_drv_rec.vendor_site_id;
        END IF;
      --Code commented by gkhuntet.

        IF x_drv_rec.start_date IS NULL THEN
          x_drv_rec.start_date := l_db_drv_rec.start_date;
        END IF;
        IF x_drv_rec.end_date IS NULL THEN
          x_drv_rec.end_date := l_db_drv_rec.end_date;
        END IF;
        IF x_drv_rec.invoice_seq_start IS NULL THEN
          x_drv_rec.invoice_seq_start := l_db_drv_rec.invoice_seq_start;
        END IF;
        IF x_drv_rec.invoice_seq_end IS NULL THEN
          x_drv_rec.invoice_seq_end := l_db_drv_rec.invoice_seq_end;
        END IF;

        IF x_drv_rec.next_inv_seq IS NULL THEN
          x_drv_rec.next_inv_seq := l_db_drv_rec.next_inv_seq;
        END IF;
        IF x_drv_rec.attribute_category IS NULL THEN
          x_drv_rec.attribute_category := l_db_drv_rec.attribute_category;
        END IF;
         IF x_drv_rec.object_version_number IS NULL  or x_drv_rec.object_version_number = Okl_Api.G_MISS_NUM  THEN
          x_drv_rec.object_version_number := l_db_drv_rec.object_version_number;
        END IF;
        IF x_drv_rec.attribute1 IS NULL THEN
          x_drv_rec.attribute1 := l_db_drv_rec.attribute1;
        END IF;
        IF x_drv_rec.attribute2 IS NULL THEN
          x_drv_rec.attribute2 := l_db_drv_rec.attribute2;
        END IF;
        IF x_drv_rec.attribute3 IS NULL THEN
          x_drv_rec.attribute3 := l_db_drv_rec.attribute3;
        END IF;
        IF x_drv_rec.attribute4 IS NULL THEN
          x_drv_rec.attribute4 := l_db_drv_rec.attribute4;
        END IF;
        IF x_drv_rec.attribute5 IS NULL THEN
          x_drv_rec.attribute5 := l_db_drv_rec.attribute5;
        END IF;
        IF x_drv_rec.attribute6 IS NULL THEN
          x_drv_rec.attribute6 := l_db_drv_rec.attribute6;
        END IF;
        IF x_drv_rec.attribute7 IS NULL THEN
          x_drv_rec.attribute7 := l_db_drv_rec.attribute7;
        END IF;
        IF x_drv_rec.attribute8 IS NULL THEN
          x_drv_rec.attribute8 := l_db_drv_rec.attribute8;
        END IF;
        IF x_drv_rec.attribute9 IS NULL THEN
          x_drv_rec.attribute9 := l_db_drv_rec.attribute9;
        END IF;
        IF x_drv_rec.attribute10 IS NULL THEN
          x_drv_rec.attribute10 := l_db_drv_rec.attribute10;
        END IF;
        IF x_drv_rec.attribute11 IS NULL THEN
          x_drv_rec.attribute11 := l_db_drv_rec.attribute11;
        END IF;
        IF x_drv_rec.attribute12 IS NULL THEN
          x_drv_rec.attribute12 := l_db_drv_rec.attribute12;
        END IF;
        IF x_drv_rec.attribute13 IS NULL THEN
          x_drv_rec.attribute13 := l_db_drv_rec.attribute13;
        END IF;
        IF x_drv_rec.attribute14 IS NULL THEN
          x_drv_rec.attribute14 := l_db_drv_rec.attribute14;
        END IF;
        IF x_drv_rec.attribute15 IS NULL THEN
          x_drv_rec.attribute15 := l_db_drv_rec.attribute15;
        END IF;
        IF x_drv_rec.created_by IS NULL THEN
          x_drv_rec.created_by := l_db_drv_rec.created_by;
        END IF;
        IF x_drv_rec.creation_date IS NULL THEN
          x_drv_rec.creation_date := l_db_drv_rec.creation_date;
        END IF;
        IF x_drv_rec.last_updated_by IS NULL THEN
          x_drv_rec.last_updated_by := l_db_drv_rec.last_updated_by;
        END IF;
        IF x_drv_rec.last_update_date IS NULL THEN
          x_drv_rec.last_update_date := l_db_drv_rec.last_update_date;
        END IF;
        IF x_drv_rec.last_update_login IS NULL THEN
          x_drv_rec.last_update_login := l_db_drv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_DISB_RULE_VENDOR_SITES --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_drv_rec IN drv_rec_type,
      x_drv_rec OUT NOCOPY drv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_drv_rec := p_drv_rec;
      --x_drv_rec.OBJECT_VERSION_NUMBER := p_drv_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    /*l_return_status := Set_Attributes(
      p_drv_rec,                         -- IN
      x_drv_rec);    */                    -- OUT

  l_return_status := Set_Attributes(
      p_drv_rec,                         -- IN
      l_drv_rec);                        -- OUT

      --g_debug_proc('Version Number ' ||  l_drv_rec.OBJECT_VERSION_NUMBER);

      --g_debug_proc('Params1 ' || l_drv_rec.START_DATE || ' , ' || l_drv_rec.invoice_seq_start || ' , ' || l_drv_rec.disb_rule_vendor_site_id);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_drv_rec, l_def_drv_rec);
    --debug_proc('Version Number ' ||  l_def_drv_rec.OBJECT_VERSION_NUMBER);
    --g_debug_proc('Params2 ' || l_def_drv_rec.START_DATE || ' , ' || l_def_drv_rec.invoice_seq_start || ' , ' || l_def_drv_rec.disb_rule_vendor_site_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   /* l_return_status := populate_new_record(p_drv_rec, l_drv_rec);

    --debug_proc('Version Number ' ||  l_drv_rec.OBJECT_VERSION_NUMBER);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Set_Attributes(
      l_drv_rec,                         -- IN
      l_def_drv_rec);                        -- OUT

      --debug_proc('Version Number ' ||  l_def_drv_rec.OBJECT_VERSION_NUMBER);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;*/










    l_def_drv_rec := null_out_defaults(l_def_drv_rec);
    --debug_proc('Version Number null_out_defaults' ||  l_def_drv_rec.OBJECT_VERSION_NUMBER);

    --g_debug_proc('Params3 ' || l_def_drv_rec.START_DATE || ' , ' || l_def_drv_rec.invoice_seq_start || ' , ' || l_def_drv_rec.disb_rule_vendor_site_id);

    l_def_drv_rec := fill_who_columns(l_def_drv_rec);

    --g_debug_proc('Params4 ' || l_def_drv_rec.START_DATE || ' , ' || l_def_drv_rec.invoice_seq_start || ' , ' || l_def_drv_rec.disb_rule_vendor_site_id);

     --debug_proc('Version Number fill_who_columns' ||  l_def_drv_rec.OBJECT_VERSION_NUMBER);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_drv_rec);

   --g_debug_proc('Params5 ' || l_def_drv_rec.START_DATE || ' , ' || l_def_drv_rec.invoice_seq_start || ' , ' || l_def_drv_rec.disb_rule_vendor_site_id);
    --- If any errors happen abort API
       --debug_proc('Version Number Validate_Attributes' ||  l_def_drv_rec.OBJECT_VERSION_NUMBER);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_drv_rec, l_db_drv_rec);
    --g_debug_proc('Params6 ' || l_def_drv_rec.START_DATE || ' , ' || l_def_drv_rec.invoice_seq_start || ' , ' || l_def_drv_rec.disb_rule_vendor_site_id);

    -- debug_proc('Version Number Validate_Record' ||  l_db_drv_rec.OBJECT_VERSION_NUMBER);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--  debug_proc('Version Number ' ||  l_db_drv_rec.OBJECT_VERSION_NUMBER);

  --g_debug_proc('Lock ROw');
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_drv_rec                      => l_def_drv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--g_debug_proc('befor update');
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_def_drv_rec,
      lx_drv_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_drv_rec := l_def_drv_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:drv_tbl --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      i := p_drv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_drv_rec                      => p_drv_tbl(i),
            x_drv_rec                      => x_drv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_drv_tbl.LAST);
        i := p_drv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:DRV_TBL --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    x_drv_tbl                      OUT NOCOPY drv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_drv_tbl                      => p_drv_tbl,
        x_drv_tbl                      => x_drv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -----------------------------------------------
  -- delete_row for:OKL_DISB_RULE_VENDOR_SITES --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec                      drv_rec_type := p_drv_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_DISB_RULE_VENDOR_SITES
     WHERE DISB_RULE_VENDOR_SITE_ID = p_drv_rec.disb_rule_vendor_site_id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------
  -- delete_row for:OKL_DISB_RULE_VENDOR_SITES --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_rec                      IN drv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drv_rec                      drv_rec_type := p_drv_rec;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_drv_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_DISB_RULE_VENDOR_SITES --
  ----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      i := p_drv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_drv_rec                      => p_drv_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_drv_tbl.LAST);
        i := p_drv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_DISB_RULE_VENDOR_SITES --
  ----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drv_tbl                      IN drv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_drv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_drv_tbl                      => p_drv_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_DRV_PVT;

/
