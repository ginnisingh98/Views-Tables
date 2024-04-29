--------------------------------------------------------
--  DDL for Package Body OKL_CLL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CLL_PVT" AS
/* $Header: OKLSCLLB.pls 120.1.12010000.2 2009/06/02 10:53:16 racheruv ship $ */
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
  -- in a OKC_API.ERROR_TBL_TYPE, and returns it.
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
  -- FUNCTION get_rec for: OKL_CNTR_LVLNG_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cllv_rec                     IN cllv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cllv_rec_type IS
    CURSOR okl_cllv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KLE_ID,
            CLG_ID,
            OBJECT_VERSION_NUMBER,
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
      FROM Okl_Cntr_Lvlng_Lns_V
     WHERE okl_cntr_lvlng_lns_v.id = p_id;
    l_okl_cllv_pk                  okl_cllv_pk_csr%ROWTYPE;
    l_cllv_rec                     cllv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cllv_pk_csr (p_cllv_rec.id);
    FETCH okl_cllv_pk_csr INTO
              l_cllv_rec.id,
              l_cllv_rec.kle_id,
              l_cllv_rec.clg_id,
              l_cllv_rec.object_version_number,
              l_cllv_rec.attribute_category,
              l_cllv_rec.attribute1,
              l_cllv_rec.attribute2,
              l_cllv_rec.attribute3,
              l_cllv_rec.attribute4,
              l_cllv_rec.attribute5,
              l_cllv_rec.attribute6,
              l_cllv_rec.attribute7,
              l_cllv_rec.attribute8,
              l_cllv_rec.attribute9,
              l_cllv_rec.attribute10,
              l_cllv_rec.attribute11,
              l_cllv_rec.attribute12,
              l_cllv_rec.attribute13,
              l_cllv_rec.attribute14,
              l_cllv_rec.attribute15,
              l_cllv_rec.created_by,
              l_cllv_rec.creation_date,
              l_cllv_rec.last_updated_by,
              l_cllv_rec.last_update_date,
              l_cllv_rec.last_update_login;
    x_no_data_found := okl_cllv_pk_csr%NOTFOUND;
    CLOSE okl_cllv_pk_csr;
    RETURN(l_cllv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cllv_rec                     IN cllv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cllv_rec_type IS
    l_cllv_rec                     cllv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_cllv_rec := get_rec(p_cllv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cllv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cllv_rec                     IN cllv_rec_type
  ) RETURN cllv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cllv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNTR_LVLNG_LNS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cntr_lvlng_lns_b_rec     IN okl_cntr_lvlng_lns_b_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_cntr_lvlng_lns_b_rec_type IS
    CURSOR okl_cntr_lvlng_lns_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KLE_ID,
            CLG_ID,
            OBJECT_VERSION_NUMBER,
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
      FROM Okl_Cntr_Lvlng_Lns_B
     WHERE okl_cntr_lvlng_lns_b.id = p_id;
    l_okl_cntr_lvlng_lns_b_pk      okl_cntr_lvlng_lns_b_pk_csr%ROWTYPE;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cntr_lvlng_lns_b_pk_csr (p_okl_cntr_lvlng_lns_b_rec.id);
    FETCH okl_cntr_lvlng_lns_b_pk_csr INTO
              l_okl_cntr_lvlng_lns_b_rec.id,
              l_okl_cntr_lvlng_lns_b_rec.kle_id,
              l_okl_cntr_lvlng_lns_b_rec.clg_id,
              l_okl_cntr_lvlng_lns_b_rec.object_version_number,
              l_okl_cntr_lvlng_lns_b_rec.attribute_category,
              l_okl_cntr_lvlng_lns_b_rec.attribute1,
              l_okl_cntr_lvlng_lns_b_rec.attribute2,
              l_okl_cntr_lvlng_lns_b_rec.attribute3,
              l_okl_cntr_lvlng_lns_b_rec.attribute4,
              l_okl_cntr_lvlng_lns_b_rec.attribute5,
              l_okl_cntr_lvlng_lns_b_rec.attribute6,
              l_okl_cntr_lvlng_lns_b_rec.attribute7,
              l_okl_cntr_lvlng_lns_b_rec.attribute8,
              l_okl_cntr_lvlng_lns_b_rec.attribute9,
              l_okl_cntr_lvlng_lns_b_rec.attribute10,
              l_okl_cntr_lvlng_lns_b_rec.attribute11,
              l_okl_cntr_lvlng_lns_b_rec.attribute12,
              l_okl_cntr_lvlng_lns_b_rec.attribute13,
              l_okl_cntr_lvlng_lns_b_rec.attribute14,
              l_okl_cntr_lvlng_lns_b_rec.attribute15,
              l_okl_cntr_lvlng_lns_b_rec.created_by,
              l_okl_cntr_lvlng_lns_b_rec.creation_date,
              l_okl_cntr_lvlng_lns_b_rec.last_updated_by,
              l_okl_cntr_lvlng_lns_b_rec.last_update_date,
              l_okl_cntr_lvlng_lns_b_rec.last_update_login;
    x_no_data_found := okl_cntr_lvlng_lns_b_pk_csr%NOTFOUND;
    CLOSE okl_cntr_lvlng_lns_b_pk_csr;
    RETURN(l_okl_cntr_lvlng_lns_b_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cntr_lvlng_lns_b_rec     IN okl_cntr_lvlng_lns_b_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_cntr_lvlng_lns_b_rec_type IS
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_lns_b_rec := get_rec(p_okl_cntr_lvlng_lns_b_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_cntr_lvlng_lns_b_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cntr_lvlng_lns_b_rec     IN okl_cntr_lvlng_lns_b_rec_type
  ) RETURN okl_cntr_lvlng_lns_b_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_cntr_lvlng_lns_b_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CNTR_LVLNG_LNS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cllv_rec   IN cllv_rec_type
  ) RETURN cllv_rec_type IS
    l_cllv_rec                     cllv_rec_type := p_cllv_rec;
  BEGIN
    IF (l_cllv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_cllv_rec.id := NULL;
    END IF;
    IF (l_cllv_rec.kle_id = OKL_API.G_MISS_NUM ) THEN
      l_cllv_rec.kle_id := NULL;
    END IF;
    IF (l_cllv_rec.clg_id = OKL_API.G_MISS_NUM ) THEN
      l_cllv_rec.clg_id := NULL;
    END IF;
    IF (l_cllv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_cllv_rec.object_version_number := NULL;
    END IF;
    IF (l_cllv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute_category := NULL;
    END IF;
    IF (l_cllv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute1 := NULL;
    END IF;
    IF (l_cllv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute2 := NULL;
    END IF;
    IF (l_cllv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute3 := NULL;
    END IF;
    IF (l_cllv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute4 := NULL;
    END IF;
    IF (l_cllv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute5 := NULL;
    END IF;
    IF (l_cllv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute6 := NULL;
    END IF;
    IF (l_cllv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute7 := NULL;
    END IF;
    IF (l_cllv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute8 := NULL;
    END IF;
    IF (l_cllv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute9 := NULL;
    END IF;
    IF (l_cllv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute10 := NULL;
    END IF;
    IF (l_cllv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute11 := NULL;
    END IF;
    IF (l_cllv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute12 := NULL;
    END IF;
    IF (l_cllv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute13 := NULL;
    END IF;
    IF (l_cllv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute14 := NULL;
    END IF;
    IF (l_cllv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_cllv_rec.attribute15 := NULL;
    END IF;
    IF (l_cllv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_cllv_rec.created_by := NULL;
    END IF;
    IF (l_cllv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_cllv_rec.creation_date := NULL;
    END IF;
    IF (l_cllv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_cllv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cllv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_cllv_rec.last_update_date := NULL;
    END IF;
    IF (l_cllv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_cllv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cllv_rec);
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
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Counter');
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
  -------------------------------------
  -- Validate_Attributes for: KLE_ID --
  -------------------------------------
  PROCEDURE validate_kle_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_kle_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_kle_id = OKL_API.G_MISS_NUM OR
        p_kle_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Counter');
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
  END validate_kle_id;
  -------------------------------------
  -- Validate_Attributes for: CLG_ID --
  -------------------------------------
  PROCEDURE validate_clg_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_clg_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_clg_id = OKL_API.G_MISS_NUM OR
        p_clg_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'clg_id');
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
  END validate_clg_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
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
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_CNTR_LVLNG_LNS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cllv_rec                     IN cllv_rec_type
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
    validate_id(x_return_status, p_cllv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           l_return_status := x_return_status;
       END IF;
    END IF;

    -- ***
    -- kle_id
    -- ***
    validate_kle_id(x_return_status, p_cllv_rec.kle_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           l_return_status := x_return_status;
       END IF;
    END IF;

    -- ***
    -- clg_id
    -- ***
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           l_return_status := x_return_status;
       END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_cllv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           l_return_status := x_return_status;
       END IF;
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
  ----------------------------------------------
  -- Validate Record for:OKL_CNTR_LVLNG_LNS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_cllv_rec IN cllv_rec_type,
    p_db_cllv_rec IN cllv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     -- nikshah Modified for bug 6982494 start
     CURSOR c_counter_csr(cp_clg_id IN NUMBER,cp_counter IN NUMBER,cp_cll_id IN NUMBER) IS
       SELECT 'Y'
       FROM OKL_CNTR_LVLNG_LNS_B
       WHERE clg_id = cp_clg_id
       AND kle_id = cp_counter
       AND  ID <> cp_cll_id;

       CURSOR c_cntr_csr (p_id IN NUMBER) IS
       SELECT effective_date_from,effective_date_to
         FROM Okl_Cntr_Lvlng_Grps_B
        WHERE okl_cntr_lvlng_grps_b.id = p_id;

       CURSOR c_conscounter_csr(cp_clg_id IN NUMBER,cp_counter IN NUMBER) IS
       SELECT b.effective_date_from,b.effective_date_to,b.id,b.name
       FROM OKL_CNTR_LVLNG_LNS_B a,
            Okl_Cntr_Lvlng_Grps_v b
       WHERE a.clg_id = b.id
       AND b.id <> cp_clg_id
       AND a.kle_id = cp_counter;
       l_exists VARCHAR2(3) := 'N';
       l_error  VARCHAR2(3) := 'N';
       l_from_date DATE;
       l_to_date DATE;
       counter_invalud_exception EXCEPTION;
       -- nikshah Modified for bug 6982494 end
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_cllv_rec IN cllv_rec_type,
      p_db_cllv_rec IN cllv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okl_cllv_clg_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Cntr_Lvlng_Grps_B
       WHERE okl_cntr_lvlng_grps_b.id = p_id;
      l_okl_cllv_clg_fk              okl_cllv_clg_fk_csr%ROWTYPE;

      CURSOR okl_cllv_kle_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_K_Lines
       WHERE okl_k_lines.id       = p_id;
      l_okl_cllv_kle_fk              okl_cllv_kle_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
/*      IF ((p_cllv_rec.KLE_ID IS NOT NULL)
       AND
          (p_cllv_rec.KLE_ID <> p_db_cllv_rec.KLE_ID))
      THEN
        OPEN okl_cllv_kle_fk_csr (p_cllv_rec.KLE_ID);
        FETCH okl_cllv_kle_fk_csr INTO l_okl_cllv_kle_fk;
        l_row_notfound := okl_cllv_kle_fk_csr%NOTFOUND;
        CLOSE okl_cllv_kle_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'KLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
*/      IF ((p_cllv_rec.CLG_ID IS NOT NULL)
       AND
          (p_cllv_rec.CLG_ID <> p_db_cllv_rec.CLG_ID))
      THEN
        OPEN okl_cllv_clg_fk_csr (p_cllv_rec.CLG_ID);
        FETCH okl_cllv_clg_fk_csr INTO l_okl_cllv_clg_fk;
        l_row_notfound := okl_cllv_clg_fk_csr%NOTFOUND;
        CLOSE okl_cllv_clg_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLG_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_cllv_rec, p_db_cllv_rec);
     -- nikshah Modified for bug 6982494 start
     OPEN c_counter_csr(p_cllv_rec.CLG_ID,p_cllv_rec.kle_id,p_cllv_rec.id);
       FETCH c_counter_csr INTO l_exists;
       CLOSE c_counter_csr;
       IF l_exists ='Y' THEN
         OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS','COUNTER_NAME',p_cllv_rec.kle_id);
         RAISE counter_invalud_exception;
       END IF;
       OPEN c_cntr_csr(p_cllv_rec.CLG_ID);
       FETCH c_cntr_csr INTO l_from_date,l_to_date;
       CLOSE c_cntr_csr;
       l_error := 'N';
       FOR l_rec IN c_conscounter_csr(p_cllv_rec.CLG_ID,p_cllv_rec.kle_id) LOOP
         IF l_from_date IS NULL  AND l_to_date IS NULL THEN
            IF l_rec.effective_date_from IS NULL AND l_rec.effective_date_to IS NULL THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS1','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NULL THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS2','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS  NULL AND l_rec.effective_date_to IS NOT NULL  THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS3','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NOT NULL  THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS4','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           END IF;
         ELSIF l_from_date IS NOT NULL AND l_to_date IS null THEN
           IF l_rec.effective_date_from IS NULL AND l_rec.effective_date_to IS NULL THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS1','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NULL THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS2','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS  NULL AND l_rec.effective_date_to IS NOT NULL AND l_rec.effective_date_to >= l_from_date THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS3','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NOT NULL AND (l_rec.effective_date_to >= l_from_date OR l_rec.effective_date_from >= l_from_date) THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS4','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           END IF;
         ELSIF l_from_date IS  NULL AND l_to_date IS NOT null THEN
           IF l_rec.effective_date_from IS NULL AND l_rec.effective_date_to IS NULL THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS1','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NULL AND l_rec.effective_date_from <= l_to_date THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS2','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS  NULL AND l_rec.effective_date_to IS NOT NULL  THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS3','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NOT NULL AND (l_rec.effective_date_to <= l_to_date OR l_rec.effective_date_from <= l_to_date) THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS4','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           END IF;
         ELSIF l_from_date IS NOT NULL AND l_to_date IS NOT null THEN
           IF l_rec.effective_date_from IS NULL AND l_rec.effective_date_to IS NULL THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS1','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NULL AND l_rec.effective_date_from <= l_to_date THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS2','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS  NULL AND l_rec.effective_date_to IS NOT NULL AND l_rec.effective_date_to >= l_from_date THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS3','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           ELSIF l_rec.effective_date_from IS NOT NULL AND l_rec.effective_date_to IS NOT NULL AND ((l_from_date BETWEEN l_rec.effective_date_from AND  l_rec.effective_date_to ) OR (l_rec.effective_date_from BETWEEN l_from_date AND l_to_date )) THEN
             OKL_API.set_message('OKL', 'OKL_CNTR_EXISTS4','COUNTER_NAME',p_cllv_rec.kle_id,'CONS_CNTR',l_rec.name,'EFF_FROM', l_rec.effective_date_from,'EFF_TO', l_rec.effective_date_to);
             l_error := 'Y';
           END IF;
         END IF;
       END LOOP;
       IF l_error = 'Y' THEN
         RAISE counter_invalud_exception;
       END IF;
       -- nikshah Modified for bug 6982494 end
       RETURN (l_return_status);
    EXCEPTION
       WHEN counter_invalud_exception THEN
         l_return_status := OKL_API.G_RET_STS_ERROR;
         RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_cllv_rec IN cllv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_cllv_rec                  cllv_rec_type := get_rec(p_cllv_rec);
  BEGIN
    l_return_status := Validate_Record(p_cllv_rec => p_cllv_rec,
                                       p_db_cllv_rec => l_db_cllv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN cllv_rec_type,
    p_to   IN OUT NOCOPY okl_cntr_lvlng_lns_b_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.kle_id := p_from.kle_id;
    p_to.clg_id := p_from.clg_id;
    p_to.object_version_number := p_from.object_version_number;
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
  PROCEDURE migrate (
    p_from IN okl_cntr_lvlng_lns_b_rec_type,
    p_to   IN OUT NOCOPY cllv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.kle_id := p_from.kle_id;
    p_to.clg_id := p_from.clg_id;
    p_to.object_version_number := p_from.object_version_number;
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
  -------------------------------------------
  -- validate_row for:OKL_CNTR_LVLNG_LNS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_rec                     IN cllv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cllv_rec                     cllv_rec_type := p_cllv_rec;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
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
    l_return_status := Validate_Attributes(l_cllv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cllv_rec);
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
  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CNTR_LVLNG_LNS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      i := p_cllv_tbl.FIRST;
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
            p_cllv_rec                     => p_cllv_tbl(i));
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
        EXIT WHEN (i = p_cllv_tbl.LAST);
        i := p_cllv_tbl.NEXT(i);
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

  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CNTR_LVLNG_LNS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cllv_tbl                     => p_cllv_tbl,
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
  -----------------------------------------
  -- insert_row for:OKL_CNTR_LVLNG_LNS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_lns_b_rec     IN okl_cntr_lvlng_lns_b_rec_type,
    x_okl_cntr_lvlng_lns_b_rec     OUT NOCOPY okl_cntr_lvlng_lns_b_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type := p_okl_cntr_lvlng_lns_b_rec;
    l_def_okl_cntr_lvlng_lns_b_rec okl_cntr_lvlng_lns_b_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cntr_lvlng_lns_b_rec IN okl_cntr_lvlng_lns_b_rec_type,
      x_okl_cntr_lvlng_lns_b_rec OUT NOCOPY okl_cntr_lvlng_lns_b_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cntr_lvlng_lns_b_rec := p_okl_cntr_lvlng_lns_b_rec;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_okl_cntr_lvlng_lns_b_rec,        -- IN
      l_okl_cntr_lvlng_lns_b_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CNTR_LVLNG_LNS_B(
      id,
      kle_id,
      clg_id,
      object_version_number,
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
      l_okl_cntr_lvlng_lns_b_rec.id,
      l_okl_cntr_lvlng_lns_b_rec.kle_id,
      l_okl_cntr_lvlng_lns_b_rec.clg_id,
      l_okl_cntr_lvlng_lns_b_rec.object_version_number,
      l_okl_cntr_lvlng_lns_b_rec.attribute_category,
      l_okl_cntr_lvlng_lns_b_rec.attribute1,
      l_okl_cntr_lvlng_lns_b_rec.attribute2,
      l_okl_cntr_lvlng_lns_b_rec.attribute3,
      l_okl_cntr_lvlng_lns_b_rec.attribute4,
      l_okl_cntr_lvlng_lns_b_rec.attribute5,
      l_okl_cntr_lvlng_lns_b_rec.attribute6,
      l_okl_cntr_lvlng_lns_b_rec.attribute7,
      l_okl_cntr_lvlng_lns_b_rec.attribute8,
      l_okl_cntr_lvlng_lns_b_rec.attribute9,
      l_okl_cntr_lvlng_lns_b_rec.attribute10,
      l_okl_cntr_lvlng_lns_b_rec.attribute11,
      l_okl_cntr_lvlng_lns_b_rec.attribute12,
      l_okl_cntr_lvlng_lns_b_rec.attribute13,
      l_okl_cntr_lvlng_lns_b_rec.attribute14,
      l_okl_cntr_lvlng_lns_b_rec.attribute15,
      l_okl_cntr_lvlng_lns_b_rec.created_by,
      l_okl_cntr_lvlng_lns_b_rec.creation_date,
      l_okl_cntr_lvlng_lns_b_rec.last_updated_by,
      l_okl_cntr_lvlng_lns_b_rec.last_update_date,
      l_okl_cntr_lvlng_lns_b_rec.last_update_login);
    -- Set OUT values
    x_okl_cntr_lvlng_lns_b_rec := l_okl_cntr_lvlng_lns_b_rec;
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
  ------------------------------------------
  -- insert_row for :OKL_CNTR_LVLNG_LNS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_rec                     IN cllv_rec_type,
    x_cllv_rec                     OUT NOCOPY cllv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cllv_rec                     cllv_rec_type := p_cllv_rec;
    l_def_cllv_rec                 cllv_rec_type;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
    lx_okl_cntr_lvlng_lns_b_rec    okl_cntr_lvlng_lns_b_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cllv_rec IN cllv_rec_type
    ) RETURN cllv_rec_type IS
      l_cllv_rec cllv_rec_type := p_cllv_rec;
    BEGIN
      l_cllv_rec.CREATION_DATE := SYSDATE;
      l_cllv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cllv_rec.LAST_UPDATE_DATE := l_cllv_rec.CREATION_DATE;
      l_cllv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cllv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cllv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cllv_rec IN cllv_rec_type,
      x_cllv_rec OUT NOCOPY cllv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cllv_rec := p_cllv_rec;
      x_cllv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cllv_rec := null_out_defaults(p_cllv_rec);
    -- Set primary key value
    l_cllv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_cllv_rec,                        -- IN
      l_def_cllv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cllv_rec := fill_who_columns(l_def_cllv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cllv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cllv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_cllv_rec, l_okl_cntr_lvlng_lns_b_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_lns_b_rec,
      lx_okl_cntr_lvlng_lns_b_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_cntr_lvlng_lns_b_rec, l_def_cllv_rec);
    -- Set OUT values
    x_cllv_rec := l_def_cllv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL insert_row for:CLLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type,
    x_cllv_tbl                     OUT NOCOPY cllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      i := p_cllv_tbl.FIRST;
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
            p_cllv_rec                     => p_cllv_tbl(i),
            x_cllv_rec                     => x_cllv_tbl(i));
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
        EXIT WHEN (i = p_cllv_tbl.LAST);
        i := p_cllv_tbl.NEXT(i);
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

  ----------------------------------------
  -- PL/SQL TBL insert_row for:CLLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type,
    x_cllv_tbl                     OUT NOCOPY cllv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cllv_tbl                     => p_cllv_tbl,
        x_cllv_tbl                     => x_cllv_tbl,
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
  ---------------------------------------
  -- lock_row for:OKL_CNTR_LVLNG_LNS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_lns_b_rec     IN okl_cntr_lvlng_lns_b_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_cntr_lvlng_lns_b_rec IN okl_cntr_lvlng_lns_b_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNTR_LVLNG_LNS_B
     WHERE ID = p_okl_cntr_lvlng_lns_b_rec.id
       AND OBJECT_VERSION_NUMBER = p_okl_cntr_lvlng_lns_b_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_okl_cntr_lvlng_lns_b_rec IN okl_cntr_lvlng_lns_b_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNTR_LVLNG_LNS_B
     WHERE ID = p_okl_cntr_lvlng_lns_b_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CNTR_LVLNG_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CNTR_LVLNG_LNS_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
    BEGIN
      OPEN lock_csr(p_okl_cntr_lvlng_lns_b_rec);
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
      OPEN lchk_csr(p_okl_cntr_lvlng_lns_b_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_okl_cntr_lvlng_lns_b_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_okl_cntr_lvlng_lns_b_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for: OKL_CNTR_LVLNG_LNS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_rec                     IN cllv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
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
    migrate(p_cllv_rec, l_okl_cntr_lvlng_lns_b_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_lns_b_rec
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
  --------------------------------------
  -- PL/SQL TBL lock_row for:CLLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      i := p_cllv_tbl.FIRST;
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
            p_cllv_rec                     => p_cllv_tbl(i));
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
        EXIT WHEN (i = p_cllv_tbl.LAST);
        i := p_cllv_tbl.NEXT(i);
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
  --------------------------------------
  -- PL/SQL TBL lock_row for:CLLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cllv_tbl                     => p_cllv_tbl,
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
  -----------------------------------------
  -- update_row for:OKL_CNTR_LVLNG_LNS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_lns_b_rec     IN okl_cntr_lvlng_lns_b_rec_type,
    x_okl_cntr_lvlng_lns_b_rec     OUT NOCOPY okl_cntr_lvlng_lns_b_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type := p_okl_cntr_lvlng_lns_b_rec;
    l_def_okl_cntr_lvlng_lns_b_rec okl_cntr_lvlng_lns_b_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_cntr_lvlng_lns_b_rec IN okl_cntr_lvlng_lns_b_rec_type,
      x_okl_cntr_lvlng_lns_b_rec OUT NOCOPY okl_cntr_lvlng_lns_b_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cntr_lvlng_lns_b_rec := p_okl_cntr_lvlng_lns_b_rec;
      -- Get current database values
      l_okl_cntr_lvlng_lns_b_rec := get_rec(p_okl_cntr_lvlng_lns_b_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_okl_cntr_lvlng_lns_b_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.id := l_okl_cntr_lvlng_lns_b_rec.id;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.kle_id := l_okl_cntr_lvlng_lns_b_rec.kle_id;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.clg_id = OKL_API.G_MISS_NUM)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.clg_id := l_okl_cntr_lvlng_lns_b_rec.clg_id;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.object_version_number := l_okl_cntr_lvlng_lns_b_rec.object_version_number;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute_category := l_okl_cntr_lvlng_lns_b_rec.attribute_category;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute1 := l_okl_cntr_lvlng_lns_b_rec.attribute1;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute2 := l_okl_cntr_lvlng_lns_b_rec.attribute2;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute3 := l_okl_cntr_lvlng_lns_b_rec.attribute3;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute4 := l_okl_cntr_lvlng_lns_b_rec.attribute4;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute5 := l_okl_cntr_lvlng_lns_b_rec.attribute5;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute6 := l_okl_cntr_lvlng_lns_b_rec.attribute6;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute7 := l_okl_cntr_lvlng_lns_b_rec.attribute7;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute8 := l_okl_cntr_lvlng_lns_b_rec.attribute8;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute9 := l_okl_cntr_lvlng_lns_b_rec.attribute9;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute10 := l_okl_cntr_lvlng_lns_b_rec.attribute10;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute11 := l_okl_cntr_lvlng_lns_b_rec.attribute11;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute12 := l_okl_cntr_lvlng_lns_b_rec.attribute12;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute13 := l_okl_cntr_lvlng_lns_b_rec.attribute13;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute14 := l_okl_cntr_lvlng_lns_b_rec.attribute14;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.attribute15 := l_okl_cntr_lvlng_lns_b_rec.attribute15;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.created_by := l_okl_cntr_lvlng_lns_b_rec.created_by;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.creation_date := l_okl_cntr_lvlng_lns_b_rec.creation_date;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.last_updated_by := l_okl_cntr_lvlng_lns_b_rec.last_updated_by;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.last_update_date := l_okl_cntr_lvlng_lns_b_rec.last_update_date;
        END IF;
        IF (x_okl_cntr_lvlng_lns_b_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_okl_cntr_lvlng_lns_b_rec.last_update_login := l_okl_cntr_lvlng_lns_b_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_LNS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cntr_lvlng_lns_b_rec IN okl_cntr_lvlng_lns_b_rec_type,
      x_okl_cntr_lvlng_lns_b_rec OUT NOCOPY okl_cntr_lvlng_lns_b_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_cntr_lvlng_lns_b_rec := p_okl_cntr_lvlng_lns_b_rec;
      x_okl_cntr_lvlng_lns_b_rec.OBJECT_VERSION_NUMBER := p_okl_cntr_lvlng_lns_b_rec.OBJECT_VERSION_NUMBER + 1;
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
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_cntr_lvlng_lns_b_rec,        -- IN
      l_okl_cntr_lvlng_lns_b_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_cntr_lvlng_lns_b_rec, l_def_okl_cntr_lvlng_lns_b_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CNTR_LVLNG_LNS_B
    SET KLE_ID = l_def_okl_cntr_lvlng_lns_b_rec.kle_id,
        CLG_ID = l_def_okl_cntr_lvlng_lns_b_rec.clg_id,
        OBJECT_VERSION_NUMBER = l_def_okl_cntr_lvlng_lns_b_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_okl_cntr_lvlng_lns_b_rec.attribute_category,
        ATTRIBUTE1 = l_def_okl_cntr_lvlng_lns_b_rec.attribute1,
        ATTRIBUTE2 = l_def_okl_cntr_lvlng_lns_b_rec.attribute2,
        ATTRIBUTE3 = l_def_okl_cntr_lvlng_lns_b_rec.attribute3,
        ATTRIBUTE4 = l_def_okl_cntr_lvlng_lns_b_rec.attribute4,
        ATTRIBUTE5 = l_def_okl_cntr_lvlng_lns_b_rec.attribute5,
        ATTRIBUTE6 = l_def_okl_cntr_lvlng_lns_b_rec.attribute6,
        ATTRIBUTE7 = l_def_okl_cntr_lvlng_lns_b_rec.attribute7,
        ATTRIBUTE8 = l_def_okl_cntr_lvlng_lns_b_rec.attribute8,
        ATTRIBUTE9 = l_def_okl_cntr_lvlng_lns_b_rec.attribute9,
        ATTRIBUTE10 = l_def_okl_cntr_lvlng_lns_b_rec.attribute10,
        ATTRIBUTE11 = l_def_okl_cntr_lvlng_lns_b_rec.attribute11,
        ATTRIBUTE12 = l_def_okl_cntr_lvlng_lns_b_rec.attribute12,
        ATTRIBUTE13 = l_def_okl_cntr_lvlng_lns_b_rec.attribute13,
        ATTRIBUTE14 = l_def_okl_cntr_lvlng_lns_b_rec.attribute14,
        ATTRIBUTE15 = l_def_okl_cntr_lvlng_lns_b_rec.attribute15,
        CREATED_BY = l_def_okl_cntr_lvlng_lns_b_rec.created_by,
        CREATION_DATE = l_def_okl_cntr_lvlng_lns_b_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_cntr_lvlng_lns_b_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_cntr_lvlng_lns_b_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_cntr_lvlng_lns_b_rec.last_update_login
    WHERE ID = l_def_okl_cntr_lvlng_lns_b_rec.id;

    x_okl_cntr_lvlng_lns_b_rec := l_okl_cntr_lvlng_lns_b_rec;
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
  -----------------------------------------
  -- update_row for:OKL_CNTR_LVLNG_LNS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_rec                     IN cllv_rec_type,
    x_cllv_rec                     OUT NOCOPY cllv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cllv_rec                     cllv_rec_type := p_cllv_rec;
    l_def_cllv_rec                 cllv_rec_type;
    l_db_cllv_rec                  cllv_rec_type;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
    lx_okl_cntr_lvlng_lns_b_rec    okl_cntr_lvlng_lns_b_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cllv_rec IN cllv_rec_type
    ) RETURN cllv_rec_type IS
      l_cllv_rec cllv_rec_type := p_cllv_rec;
    BEGIN
      l_cllv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cllv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cllv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cllv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cllv_rec IN cllv_rec_type,
      x_cllv_rec OUT NOCOPY cllv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cllv_rec := p_cllv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_cllv_rec := get_rec(p_cllv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_cllv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_cllv_rec.id := l_db_cllv_rec.id;
        END IF;
-- Hand Coded
        IF (x_cllv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_cllv_rec.object_version_number := l_db_cllv_rec.object_version_number;
        END IF;
-- End hand Coded
        IF (x_cllv_rec.kle_id = OKL_API.G_MISS_NUM)
        THEN
          x_cllv_rec.kle_id := l_db_cllv_rec.kle_id;
        END IF;
        IF (x_cllv_rec.clg_id = OKL_API.G_MISS_NUM)
        THEN
          x_cllv_rec.clg_id := l_db_cllv_rec.clg_id;
        END IF;
        IF (x_cllv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute_category := l_db_cllv_rec.attribute_category;
        END IF;
        IF (x_cllv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute1 := l_db_cllv_rec.attribute1;
        END IF;
        IF (x_cllv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute2 := l_db_cllv_rec.attribute2;
        END IF;
        IF (x_cllv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute3 := l_db_cllv_rec.attribute3;
        END IF;
        IF (x_cllv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute4 := l_db_cllv_rec.attribute4;
        END IF;
        IF (x_cllv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute5 := l_db_cllv_rec.attribute5;
        END IF;
        IF (x_cllv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute6 := l_db_cllv_rec.attribute6;
        END IF;
        IF (x_cllv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute7 := l_db_cllv_rec.attribute7;
        END IF;
        IF (x_cllv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute8 := l_db_cllv_rec.attribute8;
        END IF;
        IF (x_cllv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute9 := l_db_cllv_rec.attribute9;
        END IF;
        IF (x_cllv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute10 := l_db_cllv_rec.attribute10;
        END IF;
        IF (x_cllv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute11 := l_db_cllv_rec.attribute11;
        END IF;
        IF (x_cllv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute12 := l_db_cllv_rec.attribute12;
        END IF;
        IF (x_cllv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute13 := l_db_cllv_rec.attribute13;
        END IF;
        IF (x_cllv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute14 := l_db_cllv_rec.attribute14;
        END IF;
        IF (x_cllv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_cllv_rec.attribute15 := l_db_cllv_rec.attribute15;
        END IF;
        IF (x_cllv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_cllv_rec.created_by := l_db_cllv_rec.created_by;
        END IF;
        IF (x_cllv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_cllv_rec.creation_date := l_db_cllv_rec.creation_date;
        END IF;
        IF (x_cllv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_cllv_rec.last_updated_by := l_db_cllv_rec.last_updated_by;
        END IF;
        IF (x_cllv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_cllv_rec.last_update_date := l_db_cllv_rec.last_update_date;
        END IF;
        IF (x_cllv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_cllv_rec.last_update_login := l_db_cllv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_CNTR_LVLNG_LNS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cllv_rec IN cllv_rec_type,
      x_cllv_rec OUT NOCOPY cllv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cllv_rec := p_cllv_rec;
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
    l_return_status := Set_Attributes(
      p_cllv_rec,                        -- IN
      x_cllv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cllv_rec, l_def_cllv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cllv_rec := fill_who_columns(l_def_cllv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cllv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cllv_rec, l_db_cllv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
/*    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_cllv_rec                     => p_cllv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_cllv_rec, l_okl_cntr_lvlng_lns_b_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_lns_b_rec,
      lx_okl_cntr_lvlng_lns_b_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_cntr_lvlng_lns_b_rec, l_def_cllv_rec);
    x_cllv_rec := l_def_cllv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL update_row for:cllv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type,
    x_cllv_tbl                     OUT NOCOPY cllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      i := p_cllv_tbl.FIRST;
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
            p_cllv_rec                     => p_cllv_tbl(i),
            x_cllv_rec                     => x_cllv_tbl(i));
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
        EXIT WHEN (i = p_cllv_tbl.LAST);
        i := p_cllv_tbl.NEXT(i);
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

  ----------------------------------------
  -- PL/SQL TBL update_row for:CLLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type,
    x_cllv_tbl                     OUT NOCOPY cllv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cllv_tbl                     => p_cllv_tbl,
        x_cllv_tbl                     => x_cllv_tbl,
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
  -----------------------------------------
  -- delete_row for:OKL_CNTR_LVLNG_LNS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cntr_lvlng_lns_b_rec     IN okl_cntr_lvlng_lns_b_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type := p_okl_cntr_lvlng_lns_b_rec;
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

    DELETE FROM OKL_CNTR_LVLNG_LNS_B
     WHERE ID = p_okl_cntr_lvlng_lns_b_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKL_CNTR_LVLNG_LNS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_rec                     IN cllv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cllv_rec                     cllv_rec_type := p_cllv_rec;
    l_okl_cntr_lvlng_lns_b_rec     okl_cntr_lvlng_lns_b_rec_type;
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
    migrate(l_cllv_rec, l_okl_cntr_lvlng_lns_b_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cntr_lvlng_lns_b_rec
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
  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CNTR_LVLNG_LNS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      i := p_cllv_tbl.FIRST;
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
            p_cllv_rec                     => p_cllv_tbl(i));
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
        EXIT WHEN (i = p_cllv_tbl.LAST);
        i := p_cllv_tbl.NEXT(i);
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

  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CNTR_LVLNG_LNS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cllv_tbl                     IN cllv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cllv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_cllv_tbl                     => p_cllv_tbl,
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

END OKL_CLL_PVT;

/
