--------------------------------------------------------
--  DDL for Package Body OKL_XMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XMP_PVT" AS
/* $Header: OKLSXMPB.pls 120.2 2007/01/11 14:02:18 udhenuko noship $ */
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
  -- FUNCTION get_rec for: OKL_XMLP_PARAMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_xmp_rec                      IN xmp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN xmp_rec_type IS
    CURSOR okl_xmp_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            BATCH_ID,
            PARAM_NAME,
            OBJECT_VERSION_NUMBER,
            PARAM_TYPE_CODE,
            PARAM_VALUE,
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
      FROM Okl_Xmlp_Params
     WHERE okl_xmlp_params.id   = p_id;
    l_okl_xmp_pk                   okl_xmp_pk_csr%ROWTYPE;
    l_xmp_rec                      xmp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_xmp_pk_csr (p_xmp_rec.id);
    FETCH okl_xmp_pk_csr INTO
              l_xmp_rec.id,
              l_xmp_rec.batch_id,
              l_xmp_rec.param_name,
              l_xmp_rec.object_version_number,
              l_xmp_rec.param_type_code,
              l_xmp_rec.param_value,
              l_xmp_rec.attribute_category,
              l_xmp_rec.attribute1,
              l_xmp_rec.attribute2,
              l_xmp_rec.attribute3,
              l_xmp_rec.attribute4,
              l_xmp_rec.attribute5,
              l_xmp_rec.attribute6,
              l_xmp_rec.attribute7,
              l_xmp_rec.attribute8,
              l_xmp_rec.attribute9,
              l_xmp_rec.attribute10,
              l_xmp_rec.attribute11,
              l_xmp_rec.attribute12,
              l_xmp_rec.attribute13,
              l_xmp_rec.attribute14,
              l_xmp_rec.attribute15,
              l_xmp_rec.created_by,
              l_xmp_rec.creation_date,
              l_xmp_rec.last_updated_by,
              l_xmp_rec.last_update_date,
              l_xmp_rec.last_update_login;
    x_no_data_found := okl_xmp_pk_csr%NOTFOUND;
    CLOSE okl_xmp_pk_csr;
    RETURN(l_xmp_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_xmp_rec                      IN xmp_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN xmp_rec_type IS
    l_xmp_rec                      xmp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_xmp_rec := get_rec(p_xmp_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_xmp_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_xmp_rec                      IN xmp_rec_type
  ) RETURN xmp_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_xmp_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_XMLP_PARAMS
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_xmp_rec   IN xmp_rec_type
  ) RETURN xmp_rec_type IS
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;
  BEGIN
    /*IF (l_xmp_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_xmp_rec.id := NULL;
    END IF;
    IF (l_xmp_rec.batch_id = OKL_API.G_MISS_NUM ) THEN
      l_xmp_rec.batch_id := NULL;
    END IF;*/
    IF (l_xmp_rec.param_name = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.param_name := NULL;
    END IF;
    IF (l_xmp_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_xmp_rec.object_version_number := NULL;
    END IF;
    IF (l_xmp_rec.param_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.param_type_code := NULL;
    END IF;
    IF (l_xmp_rec.param_value = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.param_value := NULL;
    END IF;
    IF (l_xmp_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute_category := NULL;
    END IF;
    IF (l_xmp_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute1 := NULL;
    END IF;
    IF (l_xmp_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute2 := NULL;
    END IF;
    IF (l_xmp_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute3 := NULL;
    END IF;
    IF (l_xmp_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute4 := NULL;
    END IF;
    IF (l_xmp_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute5 := NULL;
    END IF;
    IF (l_xmp_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute6 := NULL;
    END IF;
    IF (l_xmp_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute7 := NULL;
    END IF;
    IF (l_xmp_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute8 := NULL;
    END IF;
    IF (l_xmp_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute9 := NULL;
    END IF;
    IF (l_xmp_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute10 := NULL;
    END IF;
    IF (l_xmp_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute11 := NULL;
    END IF;
    IF (l_xmp_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute12 := NULL;
    END IF;
    IF (l_xmp_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute13 := NULL;
    END IF;
    IF (l_xmp_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute14 := NULL;
    END IF;
    IF (l_xmp_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.attribute15 := NULL;
    END IF;
    /*IF (l_xmp_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_xmp_rec.created_by := NULL;
    END IF;
    IF (l_xmp_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_xmp_rec.creation_date := NULL;
    END IF;
    IF (l_xmp_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_xmp_rec.last_updated_by := NULL;
    END IF;
    IF (l_xmp_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_xmp_rec.last_update_date := NULL;
    END IF;
    IF (l_xmp_rec.last_update_login = OKL_API.G_MISS_CHAR ) THEN
      l_xmp_rec.last_update_login := NULL;
    END IF;*/
    RETURN(l_xmp_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_id = OKL_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
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
  END validate_id;
  ---------------------------------------
  -- Validate_Attributes for: BATCH_ID --
  ---------------------------------------
  PROCEDURE validate_batch_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_batch_id                     IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_batch_id = OKL_API.G_MISS_NUM OR
        p_batch_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'batch_id');
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
  END validate_batch_id;

  ---------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ---------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number                     IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKL_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
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

  ---------------------------------------
  -- Validate_Attributes for: PARAM_TYPE_CODE --
  ---------------------------------------
  PROCEDURE validate_param_type_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_param_type_code                     IN VARCHAR2) IS

  l_value                    NUMBER ;
  l_row_found	             BOOLEAN ;

  CURSOR c_check_param_type(l_param_type_code IN OKL_XMLP_PARAMS.Param_type_code%TYPE) IS
  SELECT 1
  FROM FND_LOOKUPS
  WHERE LOOKUP_TYPE = 'OKL_ECC_DATA_TYPE'
  AND LOOKUP_CODE = l_param_type_code;

  BEGIN


    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN c_check_param_type(p_param_type_code);
    FETCH c_check_param_type INTO l_value;
    l_row_found := c_check_param_type%FOUND;
    CLOSE c_check_param_type;
    IF NOT l_row_found THEN
      OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'param_type_code');
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
  END validate_param_type_code;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKL_XMLP_PARAMS --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_xmp_rec                      IN xmp_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_xmp_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- batch_id
    -- ***
    validate_batch_id(x_return_status, p_xmp_rec.batch_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_xmp_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- param_type_code
    -- ***
    validate_param_type_code(x_return_status, p_xmp_rec.param_type_code);
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
  -----------------------------------------
  -- Validate Record for:OKL_XMLP_PARAMS --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_xmp_rec IN xmp_rec_type,
    p_db_xmp_rec IN xmp_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_xmp_rec IN xmp_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_xmp_rec                   xmp_rec_type := get_rec(p_xmp_rec);
  BEGIN
    l_return_status := Validate_Record(p_xmp_rec => p_xmp_rec,
                                       p_db_xmp_rec => l_db_xmp_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN xmp_rec_type,
    p_to   IN OUT NOCOPY xmp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.batch_id := p_from.batch_id;
    p_to.param_name := p_from.param_name;
    p_to.object_version_number := p_from.object_version_number;
    p_to.param_type_code := p_from.param_type_code;
    p_to.param_value := p_from.param_value;
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
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_XMLP_PARAMS --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row (rec)';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_prog_name                    VARCHAR2(61);
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;

  BEGIN
    l_prog_name := G_PKG_NAME||'.validate_row (rec)';
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
    l_return_status := Validate_Attributes(l_xmp_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_xmp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END validate_row;
  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_XMLP_PARAMS --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_prog_name                    VARCHAR2(61);
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row (tbl)';
    i                              NUMBER := 0;
  BEGIN
    l_prog_name := G_PKG_NAME||'.validate_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      i := p_xmp_tbl.FIRST;
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
            p_xmp_rec                      => p_xmp_tbl(i));
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
        EXIT WHEN (i = p_xmp_tbl.LAST);
        i := p_xmp_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END validate_row;

  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_XMLP_PARAMS --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type) IS

    l_prog_name                    VARCHAR2(61);
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_row (tbl)';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    l_prog_name := G_PKG_NAME||'.validate_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xmp_tbl                      => p_xmp_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- insert_row for:OKL_XMLP_PARAMS --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type,
    x_xmp_rec                      OUT NOCOPY xmp_rec_type) IS

    l_prog_name                    VARCHAR2(61);
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row (rec)';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;
    l_def_xmp_rec                  xmp_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKL_XMLP_PARAMS --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_xmp_rec IN xmp_rec_type,
      x_xmp_rec OUT NOCOPY xmp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xmp_rec := p_xmp_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_prog_name := G_PKG_NAME||'.insert_row (Rec)';
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_xmp_rec,                         -- IN
      l_xmp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_XMLP_PARAMS(
      id,
      batch_id,
      param_name,
      object_version_number,
      param_type_code,
      param_value,
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
      l_xmp_rec.id,
      l_xmp_rec.batch_id,
      l_xmp_rec.param_name,
      l_xmp_rec.object_version_number,
      l_xmp_rec.param_type_code,
      l_xmp_rec.param_value,
      l_xmp_rec.attribute_category,
      l_xmp_rec.attribute1,
      l_xmp_rec.attribute2,
      l_xmp_rec.attribute3,
      l_xmp_rec.attribute4,
      l_xmp_rec.attribute5,
      l_xmp_rec.attribute6,
      l_xmp_rec.attribute7,
      l_xmp_rec.attribute8,
      l_xmp_rec.attribute9,
      l_xmp_rec.attribute10,
      l_xmp_rec.attribute11,
      l_xmp_rec.attribute12,
      l_xmp_rec.attribute13,
      l_xmp_rec.attribute14,
      l_xmp_rec.attribute15,
      G_USER_ID,
      SYSDATE,
      G_USER_ID,
      SYSDATE,
      G_LOGIN_ID);
    -- Set OUT values
    x_xmp_rec := l_xmp_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END insert_row;

  -----------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_XMLP_PARAMS_TBL --
  -----------------------------------------------------
  PROCEDURE insert_row(
    p_api_version      IN NUMBER,
    p_init_msg_list    IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_xmp_rec          IN xmp_rec_type,
    x_xmp_rec          OUT NOCOPY xmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row (REC)';
    l_prog_name                    VARCHAR2(61);
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_prog_name := G_PKG_NAME||'.insert_row (REC)';
    OKL_API.init_msg_list(p_init_msg_list);

    -- Generate the id
    SELECT okl_xmp_seq.nextval INTO l_xmp_rec.id FROM DUAL;

    IF l_xmp_rec.batch_id IS NULL THEN
    -- Generate the batch id
    SELECT okl_xmp_batch_seq.nextval INTO l_xmp_rec.batch_id FROM DUAL;
    END IF;

    l_xmp_rec.object_version_number := 1;
    l_xmp_rec := null_out_defaults(l_xmp_rec);

    validate_row (
            p_api_version      => p_api_version,
            p_init_msg_list    => OKL_API.G_FALSE,
            x_return_status    => l_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data,
            p_xmp_rec          => l_xmp_rec);
    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (
            p_init_msg_list   => OKL_API.G_FALSE,
            x_return_status   => l_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_xmp_rec         => l_xmp_rec,
            x_xmp_rec         => x_xmp_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END insert_row;

  -----------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_XMLP_PARAMS_TBL --
  -----------------------------------------------------
  PROCEDURE insert_row(
    p_api_version      IN NUMBER,
    p_init_msg_list    IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_xmp_tbl          IN xmp_tbl_type,
    x_xmp_tbl          OUT NOCOPY xmp_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_prog_name                    VARCHAR2(61);
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row (TBL)';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_batch_id                     NUMBER := 0;
    l_xmp_rec                      xmp_rec_type;
  BEGIN
    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Generate the batch id
    SELECT okl_xmp_batch_seq.nextval INTO l_batch_id FROM DUAL;

    -- Make sure PL/SQL table has records in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      i := p_xmp_tbl.FIRST;
      LOOP
        l_xmp_rec := p_xmp_tbl(i);
        l_xmp_rec.batch_id := l_batch_id;
	l_xmp_rec.object_version_number := 1;
        insert_row (
	    p_api_version     => p_api_version,
            p_init_msg_list   => OKL_API.G_FALSE,
            x_return_status   => l_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_xmp_rec         => l_xmp_rec,
            x_xmp_rec         => x_xmp_tbl(i));

	  IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        EXIT WHEN (i = p_xmp_tbl.LAST);
        i := p_xmp_tbl.NEXT(i);
      END LOOP;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------
  -- lock_row for:OKL_XMLP_PARAMS --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_xmp_rec IN xmp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XMLP_PARAMS
     WHERE ID = p_xmp_rec.id
       AND OBJECT_VERSION_NUMBER = p_xmp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_xmp_rec IN xmp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_XMLP_PARAMS
     WHERE ID = p_xmp_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row (rec)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_XMLP_PARAMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_XMLP_PARAMS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_prog_name := G_PKG_NAME||'.lock_row (rec)';
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
      OPEN lock_csr(p_xmp_rec);
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
      OPEN lchk_csr(p_xmp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_xmp_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_xmp_rec.object_version_number THEN
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

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END lock_row;
  -----------------------------------
  -- lock_row for: OKL_XMLP_PARAMS --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row (rec)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xmp_rec                      xmp_rec_type;
  BEGIN
    l_prog_name := G_PKG_NAME||'.lock_row (rec)';
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
    migrate(p_xmp_rec, l_xmp_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_xmp_rec
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

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END lock_row;
  -------------------------------------
  -- PL/SQL TBL lock_row for:XMP_TBL --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row (tbl)';
    l_prog_name                    VARCHAR2(61);
    i                              NUMBER := 0;
  BEGIN
    l_prog_name := G_PKG_NAME||'.lock_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      i := p_xmp_tbl.FIRST;
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
            p_xmp_rec                      => p_xmp_tbl(i));
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
        EXIT WHEN (i = p_xmp_tbl.LAST);
        i := p_xmp_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END lock_row;
  -------------------------------------
  -- PL/SQL TBL lock_row for:XMP_TBL --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row (tbl)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    l_prog_name := G_PKG_NAME||'.lock_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xmp_tbl                      => p_xmp_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- update_row for:OKL_XMLP_PARAMS --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type,
    x_xmp_rec                      OUT NOCOPY xmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row (rec)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;
    l_def_xmp_rec                  xmp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xmp_rec IN xmp_rec_type,
      x_xmp_rec OUT NOCOPY xmp_rec_type
    ) RETURN VARCHAR2 IS
      l_xmp_rec                      xmp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xmp_rec := p_xmp_rec;
      -- Get current database values
      l_xmp_rec := get_rec(p_xmp_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_xmp_rec.id IS NULL)
        THEN
          x_xmp_rec.id := l_xmp_rec.id;
        END IF;
        IF (x_xmp_rec.batch_id IS NULL)
        THEN
          x_xmp_rec.batch_id := l_xmp_rec.batch_id;
        END IF;
	IF x_xmp_rec.object_version_number IS NULL THEN
          x_xmp_rec.object_version_number := l_xmp_rec.object_version_number;
        END IF;
	IF (x_xmp_rec.param_name IS NULL)
        THEN
          x_xmp_rec.param_name := l_xmp_rec.param_name;
        END IF;
        IF (x_xmp_rec.param_value IS NULL)
        THEN
          x_xmp_rec.param_value := l_xmp_rec.param_value;
        END IF;
        IF (x_xmp_rec.param_type_code IS NULL)
        THEN
          x_xmp_rec.param_type_code := l_xmp_rec.param_type_code;
        END IF;
        IF (x_xmp_rec.attribute_category IS NULL)
        THEN
          x_xmp_rec.attribute_category := l_xmp_rec.attribute_category;
        END IF;
        IF (x_xmp_rec.attribute1 IS NULL)
        THEN
          x_xmp_rec.attribute1 := l_xmp_rec.attribute1;
        END IF;
        IF (x_xmp_rec.attribute2 IS NULL)
        THEN
          x_xmp_rec.attribute2 := l_xmp_rec.attribute2;
        END IF;
        IF (x_xmp_rec.attribute3 IS NULL)
        THEN
          x_xmp_rec.attribute3 := l_xmp_rec.attribute3;
        END IF;
        IF (x_xmp_rec.attribute4 IS NULL)
        THEN
          x_xmp_rec.attribute4 := l_xmp_rec.attribute4;
        END IF;
        IF (x_xmp_rec.attribute5 IS NULL)
        THEN
          x_xmp_rec.attribute5 := l_xmp_rec.attribute5;
        END IF;
        IF (x_xmp_rec.attribute6 IS NULL)
        THEN
          x_xmp_rec.attribute6 := l_xmp_rec.attribute6;
        END IF;
        IF (x_xmp_rec.attribute7 IS NULL)
        THEN
          x_xmp_rec.attribute7 := l_xmp_rec.attribute7;
        END IF;
        IF (x_xmp_rec.attribute8 IS NULL)
        THEN
          x_xmp_rec.attribute8 := l_xmp_rec.attribute8;
        END IF;
        IF (x_xmp_rec.attribute9 IS NULL)
        THEN
          x_xmp_rec.attribute9 := l_xmp_rec.attribute9;
        END IF;
        IF (x_xmp_rec.attribute10 IS NULL)
        THEN
          x_xmp_rec.attribute10 := l_xmp_rec.attribute10;
        END IF;
        IF (x_xmp_rec.attribute11 IS NULL)
        THEN
          x_xmp_rec.attribute11 := l_xmp_rec.attribute11;
        END IF;
        IF (x_xmp_rec.attribute12 IS NULL)
        THEN
          x_xmp_rec.attribute12 := l_xmp_rec.attribute12;
        END IF;
        IF (x_xmp_rec.attribute13 IS NULL)
        THEN
          x_xmp_rec.attribute13 := l_xmp_rec.attribute13;
        END IF;
        IF (x_xmp_rec.attribute14 IS NULL)
        THEN
          x_xmp_rec.attribute14 := l_xmp_rec.attribute14;
        END IF;
        IF (x_xmp_rec.attribute15 IS NULL)
        THEN
          x_xmp_rec.attribute15 := l_xmp_rec.attribute15;
        END IF;
        IF (x_xmp_rec.created_by IS NULL)
        THEN
          x_xmp_rec.created_by := l_xmp_rec.created_by;
        END IF;
        IF (x_xmp_rec.creation_date IS NULL)
        THEN
          x_xmp_rec.creation_date := l_xmp_rec.creation_date;
        END IF;
        IF (x_xmp_rec.last_updated_by IS NULL)
        THEN
          x_xmp_rec.last_updated_by := l_xmp_rec.last_updated_by;
        END IF;
        IF (x_xmp_rec.last_update_date IS NULL)
        THEN
          x_xmp_rec.last_update_date := l_xmp_rec.last_update_date;
        END IF;
        IF (x_xmp_rec.last_update_login IS NULL)
        THEN
          x_xmp_rec.last_update_login := l_xmp_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_XMLP_PARAMS --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_xmp_rec IN xmp_rec_type,
      x_xmp_rec OUT NOCOPY xmp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xmp_rec := p_xmp_rec;
      x_xmp_rec.OBJECT_VERSION_NUMBER := p_xmp_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_prog_name := G_PKG_NAME||'.update_row (rec)';
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_xmp_rec,                         -- IN
      l_xmp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xmp_rec, l_def_xmp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE OKL_XMLP_PARAMS
    SET BATCH_ID = l_def_xmp_rec.batch_id,
        PARAM_NAME = l_def_xmp_rec.param_name,
        OBJECT_VERSION_NUMBER = l_def_xmp_rec.object_version_number,
        PARAM_TYPE_CODE = l_def_xmp_rec.param_type_code,
        PARAM_VALUE = l_def_xmp_rec.param_value,
        ATTRIBUTE_CATEGORY = l_def_xmp_rec.attribute_category,
        ATTRIBUTE1 = l_def_xmp_rec.attribute1,
        ATTRIBUTE2 = l_def_xmp_rec.attribute2,
        ATTRIBUTE3 = l_def_xmp_rec.attribute3,
        ATTRIBUTE4 = l_def_xmp_rec.attribute4,
        ATTRIBUTE5 = l_def_xmp_rec.attribute5,
        ATTRIBUTE6 = l_def_xmp_rec.attribute6,
        ATTRIBUTE7 = l_def_xmp_rec.attribute7,
        ATTRIBUTE8 = l_def_xmp_rec.attribute8,
        ATTRIBUTE9 = l_def_xmp_rec.attribute9,
        ATTRIBUTE10 = l_def_xmp_rec.attribute10,
        ATTRIBUTE11 = l_def_xmp_rec.attribute11,
        ATTRIBUTE12 = l_def_xmp_rec.attribute12,
        ATTRIBUTE13 = l_def_xmp_rec.attribute13,
        ATTRIBUTE14 = l_def_xmp_rec.attribute14,
        ATTRIBUTE15 = l_def_xmp_rec.attribute15,
        CREATED_BY = l_def_xmp_rec.created_by,
        CREATION_DATE = l_def_xmp_rec.creation_date,
        LAST_UPDATED_BY = l_def_xmp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_xmp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_xmp_rec.last_update_login
    WHERE ID = l_def_xmp_rec.id;

    x_xmp_rec := l_xmp_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END update_row;
  ------------------------------------
  -- update_row for:OKL_XMLP_PARAMS --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type,
    x_xmp_rec                      OUT NOCOPY xmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row (rec)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;
    l_def_xmp_rec                  xmp_rec_type;
    l_db_xmp_rec                   xmp_rec_type;
    lx_xmp_rec                     xmp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_xmp_rec IN xmp_rec_type
    ) RETURN xmp_rec_type IS
      l_xmp_rec xmp_rec_type := p_xmp_rec;
    BEGIN
      l_xmp_rec.LAST_UPDATE_DATE := SYSDATE;
      l_xmp_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_xmp_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_xmp_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_xmp_rec IN xmp_rec_type,
      x_xmp_rec OUT NOCOPY xmp_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xmp_rec := p_xmp_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_xmp_rec := get_rec(p_xmp_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_xmp_rec.id IS NULL)
        THEN
          x_xmp_rec.id := l_xmp_rec.id;
        END IF;
        IF (x_xmp_rec.batch_id IS NULL)
        THEN
          x_xmp_rec.batch_id := l_xmp_rec.batch_id;
        END IF;
	IF x_xmp_rec.object_version_number IS NULL THEN
          x_xmp_rec.object_version_number := l_xmp_rec.object_version_number;
        END IF;
	IF (x_xmp_rec.param_name IS NULL)
        THEN
          x_xmp_rec.param_name := l_xmp_rec.param_name;
        END IF;
        IF (x_xmp_rec.param_value IS NULL)
        THEN
          x_xmp_rec.param_value := l_xmp_rec.param_value;
        END IF;
        IF (x_xmp_rec.param_type_code IS NULL)
        THEN
          x_xmp_rec.param_type_code := l_xmp_rec.param_type_code;
        END IF;
        IF (x_xmp_rec.attribute_category IS NULL)
        THEN
          x_xmp_rec.attribute_category := l_xmp_rec.attribute_category;
        END IF;
        IF (x_xmp_rec.attribute1 IS NULL)
        THEN
          x_xmp_rec.attribute1 := l_xmp_rec.attribute1;
        END IF;
        IF (x_xmp_rec.attribute2 IS NULL)
        THEN
          x_xmp_rec.attribute2 := l_xmp_rec.attribute2;
        END IF;
        IF (x_xmp_rec.attribute3 IS NULL)
        THEN
          x_xmp_rec.attribute3 := l_xmp_rec.attribute3;
        END IF;
        IF (x_xmp_rec.attribute4 IS NULL)
        THEN
          x_xmp_rec.attribute4 := l_xmp_rec.attribute4;
        END IF;
        IF (x_xmp_rec.attribute5 IS NULL)
        THEN
          x_xmp_rec.attribute5 := l_xmp_rec.attribute5;
        END IF;
        IF (x_xmp_rec.attribute6 IS NULL)
        THEN
          x_xmp_rec.attribute6 := l_xmp_rec.attribute6;
        END IF;
        IF (x_xmp_rec.attribute7 IS NULL)
        THEN
          x_xmp_rec.attribute7 := l_xmp_rec.attribute7;
        END IF;
        IF (x_xmp_rec.attribute8 IS NULL)
        THEN
          x_xmp_rec.attribute8 := l_xmp_rec.attribute8;
        END IF;
        IF (x_xmp_rec.attribute9 IS NULL)
        THEN
          x_xmp_rec.attribute9 := l_xmp_rec.attribute9;
        END IF;
        IF (x_xmp_rec.attribute10 IS NULL)
        THEN
          x_xmp_rec.attribute10 := l_xmp_rec.attribute10;
        END IF;
        IF (x_xmp_rec.attribute11 IS NULL)
        THEN
          x_xmp_rec.attribute11 := l_xmp_rec.attribute11;
        END IF;
        IF (x_xmp_rec.attribute12 IS NULL)
        THEN
          x_xmp_rec.attribute12 := l_xmp_rec.attribute12;
        END IF;
        IF (x_xmp_rec.attribute13 IS NULL)
        THEN
          x_xmp_rec.attribute13 := l_xmp_rec.attribute13;
        END IF;
        IF (x_xmp_rec.attribute14 IS NULL)
        THEN
          x_xmp_rec.attribute14 := l_xmp_rec.attribute14;
        END IF;
        IF (x_xmp_rec.attribute15 IS NULL)
        THEN
          x_xmp_rec.attribute15 := l_xmp_rec.attribute15;
        END IF;
        IF (x_xmp_rec.created_by IS NULL)
        THEN
          x_xmp_rec.created_by := l_xmp_rec.created_by;
        END IF;
        IF (x_xmp_rec.creation_date IS NULL)
        THEN
          x_xmp_rec.creation_date := l_xmp_rec.creation_date;
        END IF;
        IF (x_xmp_rec.last_updated_by IS NULL)
        THEN
          x_xmp_rec.last_updated_by := l_xmp_rec.last_updated_by;
        END IF;
        IF (x_xmp_rec.last_update_date IS NULL)
        THEN
          x_xmp_rec.last_update_date := l_xmp_rec.last_update_date;
        END IF;
        IF (x_xmp_rec.last_update_login IS NULL)
        THEN
          x_xmp_rec.last_update_login := l_xmp_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_XMLP_PARAMS --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_xmp_rec IN xmp_rec_type,
      x_xmp_rec OUT NOCOPY xmp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_xmp_rec := p_xmp_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_prog_name := G_PKG_NAME||'.update_row (rec)';
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
    l_return_status := Set_Attributes(
      p_xmp_rec,                         -- IN
      x_xmp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_xmp_rec, l_def_xmp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_xmp_rec := fill_who_columns(l_def_xmp_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_xmp_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_xmp_rec, l_db_xmp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_xmp_rec                      => p_xmp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_xmp_rec, l_xmp_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_xmp_rec,
      lx_xmp_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_xmp_rec, l_def_xmp_rec);
    x_xmp_rec := l_def_xmp_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END update_row;
  ---------------------------------------
  -- PL/SQL TBL update_row for:xmp_tbl --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    x_xmp_tbl                      OUT NOCOPY xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row (tbl)';
    l_prog_name                    VARCHAR2(61);
    i                              NUMBER := 0;
  BEGIN
    l_prog_name := G_PKG_NAME||'.update_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      i := p_xmp_tbl.FIRST;
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
            p_xmp_rec                      => p_xmp_tbl(i),
            x_xmp_rec                      => x_xmp_tbl(i));
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
        EXIT WHEN (i = p_xmp_tbl.LAST);
        i := p_xmp_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END update_row;

  ---------------------------------------
  -- PL/SQL TBL update_row for:XMP_TBL --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    x_xmp_tbl                      OUT NOCOPY xmp_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row (tbl)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    i                              NUMBER := 0;
  BEGIN
    l_prog_name := G_PKG_NAME||'.update_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      i := p_xmp_tbl.FIRST;
      LOOP
        update_row (
            p_api_version     => p_api_version,
            p_init_msg_list   => OKL_API.G_FALSE,
            x_return_status   => l_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            p_xmp_rec         => p_xmp_tbl(i),
            x_xmp_rec         => x_xmp_tbl(i));

	  IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        EXIT WHEN (i = p_xmp_tbl.LAST);
        i := p_xmp_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- delete_row for:OKL_XMLP_PARAMS --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row (rec)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_prog_name := G_PKG_NAME||'.delete_row (rec)';
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_XMLP_PARAMS
     WHERE ID = p_xmp_rec.id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END delete_row;
  ------------------------------------
  -- delete_row for:OKL_XMLP_PARAMS --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_rec                      IN xmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row (rec)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_xmp_rec                      xmp_rec_type := p_xmp_rec;

  BEGIN
    l_prog_name := G_PKG_NAME||'.delete_row (rec)';
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
    migrate(l_xmp_rec, l_xmp_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_xmp_rec
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

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END delete_row;
  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_XMLP_PARAMS --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row (tbl)';
    l_prog_name                    VARCHAR2(61);
    i                              NUMBER := 0;
  BEGIN
    l_prog_name := G_PKG_NAME||'.delete_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      i := p_xmp_tbl.FIRST;
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
            p_xmp_rec                      => p_xmp_tbl(i));
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
        EXIT WHEN (i = p_xmp_tbl.LAST);
        i := p_xmp_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END delete_row;

  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_XMLP_PARAMS --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_xmp_tbl                      IN xmp_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row (tbl)';
    l_prog_name                    VARCHAR2(61);
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    l_prog_name := G_PKG_NAME||'.delete_row (tbl)';
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_xmp_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xmp_tbl                      => p_xmp_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;
  END delete_row;

END OKL_XMP_PVT;

/
