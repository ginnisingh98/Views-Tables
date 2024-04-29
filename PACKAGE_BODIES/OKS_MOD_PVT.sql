--------------------------------------------------------
--  DDL for Package Body OKS_MOD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_MOD_PVT" AS
/* $Header: OKSRMODB.pls 120.0 2005/05/25 18:11:48 appldev noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

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
    p_error_tbl                    IN OKC_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
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
  -- FUNCTION get_rec for: OKS_MSCHG_OPERATIONS_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OksMschgOperationsDtlsVRecType IS
    CURSOR oks_modv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            MRD_ID,
            OIE_ID,
            OLE_ID,
            MSCHG_TYPE,
            ATTRIBUTE_LEVEL,
            QA_CHECK_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            SECURITY_GROUP_ID,
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
            ATTRIBUTE15
      FROM Oks_Mschg_Operations_Dtls_V
     WHERE oks_mschg_operations_dtls_v.id = p_id;
    l_oks_modv_pk                  oks_modv_pk_csr%ROWTYPE;
    l_OksMschgOperationsDtlsVRec   OksMschgOperationsDtlsVRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_modv_pk_csr (p_OksMschgOperationsDtlsVRec.id);
    FETCH oks_modv_pk_csr INTO
              l_OksMschgOperationsDtlsVRec.id,
              l_OksMschgOperationsDtlsVRec.mrd_id,
              l_OksMschgOperationsDtlsVRec.oie_id,
              l_OksMschgOperationsDtlsVRec.ole_id,
              l_OksMschgOperationsDtlsVRec.mschg_type,
              l_OksMschgOperationsDtlsVRec.attribute_level,
              l_OksMschgOperationsDtlsVRec.qa_check_yn,
              l_OksMschgOperationsDtlsVRec.object_version_number,
              l_OksMschgOperationsDtlsVRec.created_by,
              l_OksMschgOperationsDtlsVRec.creation_date,
              l_OksMschgOperationsDtlsVRec.last_updated_by,
              l_OksMschgOperationsDtlsVRec.last_update_date,
              l_OksMschgOperationsDtlsVRec.last_update_login,
              l_OksMschgOperationsDtlsVRec.security_group_id,
              l_OksMschgOperationsDtlsVRec.attribute1,
              l_OksMschgOperationsDtlsVRec.attribute2,
              l_OksMschgOperationsDtlsVRec.attribute3,
              l_OksMschgOperationsDtlsVRec.attribute4,
              l_OksMschgOperationsDtlsVRec.attribute5,
              l_OksMschgOperationsDtlsVRec.attribute6,
              l_OksMschgOperationsDtlsVRec.attribute7,
              l_OksMschgOperationsDtlsVRec.attribute8,
              l_OksMschgOperationsDtlsVRec.attribute9,
              l_OksMschgOperationsDtlsVRec.attribute10,
              l_OksMschgOperationsDtlsVRec.attribute11,
              l_OksMschgOperationsDtlsVRec.attribute12,
              l_OksMschgOperationsDtlsVRec.attribute13,
              l_OksMschgOperationsDtlsVRec.attribute14,
              l_OksMschgOperationsDtlsVRec.attribute15;
    x_no_data_found := oks_modv_pk_csr%NOTFOUND;
    CLOSE oks_modv_pk_csr;
    RETURN(l_OksMschgOperationsDtlsVRec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN OksMschgOperationsDtlsVRecType IS
    l_OksMschgOperationsDtlsVRec   OksMschgOperationsDtlsVRecType;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_OksMschgOperationsDtlsVRec := get_rec(p_OksMschgOperationsDtlsVRec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_OksMschgOperationsDtlsVRec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType
  ) RETURN OksMschgOperationsDtlsVRecType IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_OksMschgOperationsDtlsVRec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_MSCHG_OPERATIONS_DTLS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_mschg_operati2           IN OksMschgOperationsDtlsRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OksMschgOperationsDtlsRecType IS
    CURSOR oks_mschg_operation1 (p_id IN NUMBER) IS
    SELECT
            ID,
            MRD_ID,
            OIE_ID,
            OLE_ID,
            MSCHG_TYPE,
            ATTRIBUTE_LEVEL,
            QA_CHECK_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
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
            ATTRIBUTE15
      FROM Oks_Mschg_Operations_Dtls
     WHERE oks_mschg_operations_dtls.id = p_id;
    l_oks_mschg_operations_dtls_pk oks_mschg_operation1%ROWTYPE;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_mschg_operation1 (p_oks_mschg_operati2.id);
    FETCH oks_mschg_operation1 INTO
              l_oks_mschg_operati3.id,
              l_oks_mschg_operati3.mrd_id,
              l_oks_mschg_operati3.oie_id,
              l_oks_mschg_operati3.ole_id,
              l_oks_mschg_operati3.mschg_type,
              l_oks_mschg_operati3.attribute_level,
              l_oks_mschg_operati3.qa_check_yn,
              l_oks_mschg_operati3.object_version_number,
              l_oks_mschg_operati3.created_by,
              l_oks_mschg_operati3.creation_date,
              l_oks_mschg_operati3.last_updated_by,
              l_oks_mschg_operati3.last_update_date,
              l_oks_mschg_operati3.last_update_login,
              l_oks_mschg_operati3.attribute1,
              l_oks_mschg_operati3.attribute2,
              l_oks_mschg_operati3.attribute3,
              l_oks_mschg_operati3.attribute4,
              l_oks_mschg_operati3.attribute5,
              l_oks_mschg_operati3.attribute6,
              l_oks_mschg_operati3.attribute7,
              l_oks_mschg_operati3.attribute8,
              l_oks_mschg_operati3.attribute9,
              l_oks_mschg_operati3.attribute10,
              l_oks_mschg_operati3.attribute11,
              l_oks_mschg_operati3.attribute12,
              l_oks_mschg_operati3.attribute13,
              l_oks_mschg_operati3.attribute14,
              l_oks_mschg_operati3.attribute15;
    x_no_data_found := oks_mschg_operation1%NOTFOUND;
    CLOSE oks_mschg_operation1;
    RETURN(l_oks_mschg_operati3);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_mschg_operati2           IN OksMschgOperationsDtlsRecType,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN OksMschgOperationsDtlsRecType IS
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oks_mschg_operati3 := get_rec(p_oks_mschg_operati2, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oks_mschg_operati3);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oks_mschg_operati2           IN OksMschgOperationsDtlsRecType
  ) RETURN OksMschgOperationsDtlsRecType IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oks_mschg_operati2, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_MSCHG_OPERATIONS_DTLS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType
  ) RETURN OksMschgOperationsDtlsVRecType IS
    l_OksMschgOperationsDtlsVRec   OksMschgOperationsDtlsVRecType := p_OksMschgOperationsDtlsVRec;
  BEGIN
    IF (l_OksMschgOperationsDtlsVRec.id IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.id := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.mrd_id IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.mrd_id := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.oie_id IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.oie_id := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.ole_id IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.ole_id := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.mschg_type IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.mschg_type := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute_level IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute_level := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.qa_check_yn IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.qa_check_yn := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.object_version_number IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.object_version_number := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.created_by IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.created_by := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.creation_date IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.creation_date := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.last_updated_by IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.last_updated_by := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.last_update_date IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.last_update_date := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.last_update_login IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.last_update_login := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.security_group_id IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.security_group_id := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute1 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute1 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute2 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute2 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute3 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute3 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute4 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute4 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute5 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute5 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute6 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute6 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute7 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute7 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute8 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute8 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute9 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute9 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute10 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute10 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute11 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute11 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute12 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute12 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute13 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute13 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute14 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute14 := NULL;
    END IF;
    IF (l_OksMschgOperationsDtlsVRec.attribute15 IS NULL ) THEN
      l_OksMschgOperationsDtlsVRec.attribute15 := NULL;
    END IF;
    RETURN(l_OksMschgOperationsDtlsVRec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id IS NULL OR
        p_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------------
  -- Validate_Attributes for:OKS_MSCHG_OPERATIONS_DTLS_V --
  ---------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_OksMschgOperationsDtlsVRec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate Record for:OKS_MSCHG_OPERATIONS_DTLS_V --
  -----------------------------------------------------
  FUNCTION Validate_Record (
    p_OksMschgOperationsDtlsVRec IN OksMschgOperationsDtlsVRecType,
    p_db_OksMschgOperat41 IN OksMschgOperationsDtlsVRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_OksMschgOperationsDtlsVRec IN OksMschgOperationsDtlsVRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_OksMschgOperat42          OksMschgOperationsDtlsVRecType := get_rec(p_OksMschgOperationsDtlsVRec);
  BEGIN
    l_return_status := Validate_Record(p_OksMschgOperationsDtlsVRec => p_OksMschgOperationsDtlsVRec,
                                       p_db_OksMschgOperat41 => l_db_OksMschgOperat42);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN OksMschgOperationsDtlsVRecType,
    p_to   IN OUT NOCOPY OksMschgOperationsDtlsRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.mrd_id := p_from.mrd_id;
    p_to.oie_id := p_from.oie_id;
    p_to.ole_id := p_from.ole_id;
    p_to.mschg_type := p_from.mschg_type;
    p_to.attribute_level := p_from.attribute_level;
    p_to.qa_check_yn := p_from.qa_check_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;
  PROCEDURE migrate (
    p_from IN OksMschgOperationsDtlsRecType,
    p_to   IN OUT NOCOPY OksMschgOperationsDtlsVRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.mrd_id := p_from.mrd_id;
    p_to.oie_id := p_from.oie_id;
    p_to.ole_id := p_from.ole_id;
    p_to.mschg_type := p_from.mschg_type;
    p_to.attribute_level := p_from.attribute_level;
    p_to.qa_check_yn := p_from.qa_check_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- validate_row for:OKS_MSCHG_OPERATIONS_DTLS_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OksMschgOperationsDtlsVRec   OksMschgOperationsDtlsVRecType := p_OksMschgOperationsDtlsVRec;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_OksMschgOperationsDtlsVRec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_OksMschgOperationsDtlsVRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_MSCHG_OPERATIONS_DTLS_V --
  -------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      i := POksMschgOperationsDtlsVTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_OksMschgOperationsDtlsVRec   => POksMschgOperationsDtlsVTbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = POksMschgOperationsDtlsVTbl.LAST);
        i := POksMschgOperationsDtlsVTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  -------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_MSCHG_OPERATIONS_DTLS_V --
  -------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        POksMschgOperationsDtlsVTbl    => POksMschgOperationsDtlsVTbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------------
  -- insert_row for:OKS_MSCHG_OPERATIONS_DTLS --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_mschg_operati2           IN OksMschgOperationsDtlsRecType,
    XOksMschgOperationsDtlsRec     OUT NOCOPY OksMschgOperationsDtlsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType := p_oks_mschg_operati2;
    LDefOksMschgOperationsDtlsRec  OksMschgOperationsDtlsRecType;
    --------------------------------------------------
    -- Set_Attributes for:OKS_MSCHG_OPERATIONS_DTLS --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_mschg_operati2 IN OksMschgOperationsDtlsRecType,
      XOksMschgOperationsDtlsRec OUT NOCOPY OksMschgOperationsDtlsRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      XOksMschgOperationsDtlsRec := p_oks_mschg_operati2;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_oks_mschg_operati2,              -- IN
      l_oks_mschg_operati3);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_MSCHG_OPERATIONS_DTLS(
      id,
      mrd_id,
      oie_id,
      ole_id,
      mschg_type,
      attribute_level,
      qa_check_yn,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
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
      attribute15)
    VALUES (
      l_oks_mschg_operati3.id,
      l_oks_mschg_operati3.mrd_id,
      l_oks_mschg_operati3.oie_id,
      l_oks_mschg_operati3.ole_id,
      l_oks_mschg_operati3.mschg_type,
      l_oks_mschg_operati3.attribute_level,
      l_oks_mschg_operati3.qa_check_yn,
      l_oks_mschg_operati3.object_version_number,
      l_oks_mschg_operati3.created_by,
      l_oks_mschg_operati3.creation_date,
      l_oks_mschg_operati3.last_updated_by,
      l_oks_mschg_operati3.last_update_date,
      l_oks_mschg_operati3.last_update_login,
      l_oks_mschg_operati3.attribute1,
      l_oks_mschg_operati3.attribute2,
      l_oks_mschg_operati3.attribute3,
      l_oks_mschg_operati3.attribute4,
      l_oks_mschg_operati3.attribute5,
      l_oks_mschg_operati3.attribute6,
      l_oks_mschg_operati3.attribute7,
      l_oks_mschg_operati3.attribute8,
      l_oks_mschg_operati3.attribute9,
      l_oks_mschg_operati3.attribute10,
      l_oks_mschg_operati3.attribute11,
      l_oks_mschg_operati3.attribute12,
      l_oks_mschg_operati3.attribute13,
      l_oks_mschg_operati3.attribute14,
      l_oks_mschg_operati3.attribute15);
    -- Set OUT values
    XOksMschgOperationsDtlsRec := l_oks_mschg_operati3;
    x_return_status := l_return_status;
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



      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN


      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -------------------------------------------------
  -- insert_row for :OKS_MSCHG_OPERATIONS_DTLS_V --
  -------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType,
    XOksMschgOperationsDtlsVRec    OUT NOCOPY OksMschgOperationsDtlsVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OksMschgOperationsDtlsVRec   OksMschgOperationsDtlsVRecType := p_OksMschgOperationsDtlsVRec;
    LDefOksMschgOperationsDtlsVRec OksMschgOperationsDtlsVRecType;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
    LxOksMschgOperationsDtlsRec    OksMschgOperationsDtlsRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_OksMschgOperationsDtlsVRec IN OksMschgOperationsDtlsVRecType
    ) RETURN OksMschgOperationsDtlsVRecType IS
      l_OksMschgOperationsDtlsVRec OksMschgOperationsDtlsVRecType := p_OksMschgOperationsDtlsVRec;
    BEGIN
      l_OksMschgOperationsDtlsVRec.CREATION_DATE := SYSDATE;
      l_OksMschgOperationsDtlsVRec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_OksMschgOperationsDtlsVRec.LAST_UPDATE_DATE := l_OksMschgOperationsDtlsVRec.CREATION_DATE;
      l_OksMschgOperationsDtlsVRec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_OksMschgOperationsDtlsVRec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_OksMschgOperationsDtlsVRec);
    END fill_who_columns;
    ----------------------------------------------------
    -- Set_Attributes for:OKS_MSCHG_OPERATIONS_DTLS_V --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_OksMschgOperationsDtlsVRec IN OksMschgOperationsDtlsVRecType,
      XOksMschgOperationsDtlsVRec OUT NOCOPY OksMschgOperationsDtlsVRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      XOksMschgOperationsDtlsVRec := p_OksMschgOperationsDtlsVRec;
      XOksMschgOperationsDtlsVRec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_OksMschgOperationsDtlsVRec := null_out_defaults(p_OksMschgOperationsDtlsVRec);
    -- Set primary key value
    l_OksMschgOperationsDtlsVRec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_OksMschgOperationsDtlsVRec,      -- IN
      LDefOksMschgOperationsDtlsVRec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    LDefOksMschgOperationsDtlsVRec := fill_who_columns(LDefOksMschgOperationsDtlsVRec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(LDefOksMschgOperationsDtlsVRec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(LDefOksMschgOperationsDtlsVRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(LDefOksMschgOperationsDtlsVRec, l_oks_mschg_operati3);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_mschg_operati3,
      LxOksMschgOperationsDtlsRec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOksMschgOperationsDtlsRec, LDefOksMschgOperationsDtlsVRec);
    -- Set OUT values
    XOksMschgOperationsDtlsVRec := LDefOksMschgOperationsDtlsVRec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKSMSCHGOPERATIONSDTLSVTBL --
  ----------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      i := POksMschgOperationsDtlsVTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_OksMschgOperationsDtlsVRec   => POksMschgOperationsDtlsVTbl(i),
            XOksMschgOperationsDtlsVRec    => XOksMschgOperationsDtlsVTbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = POksMschgOperationsDtlsVTbl.LAST);
        i := POksMschgOperationsDtlsVTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ----------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKSMSCHGOPERATIONSDTLSVTBL --
  ----------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        POksMschgOperationsDtlsVTbl    => POksMschgOperationsDtlsVTbl,
        XOksMschgOperationsDtlsVTbl    => XOksMschgOperationsDtlsVTbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  --------------------------------------------
  -- lock_row for:OKS_MSCHG_OPERATIONS_DTLS --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_mschg_operati2           IN OksMschgOperationsDtlsRecType) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oks_mschg_operati2 IN OksMschgOperationsDtlsRecType) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_MSCHG_OPERATIONS_DTLS
     WHERE ID = p_oks_mschg_operati2.id
       AND OBJECT_VERSION_NUMBER = p_oks_mschg_operati2.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_oks_mschg_operati2 IN OksMschgOperationsDtlsRecType) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_MSCHG_OPERATIONS_DTLS
     WHERE ID = p_oks_mschg_operati2.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_MSCHG_OPERATIONS_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_MSCHG_OPERATIONS_DTLS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_oks_mschg_operati2);
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
      OPEN lchk_csr(p_oks_mschg_operati2);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oks_mschg_operati2.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oks_mschg_operati2.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------------------
  -- lock_row for: OKS_MSCHG_OPERATIONS_DTLS_V --
  -----------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_OksMschgOperationsDtlsVRec, l_oks_mschg_operati3);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_mschg_operati3
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKSMSCHGOPERATIONSDTLSVTBL --
  --------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      i := POksMschgOperationsDtlsVTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_OksMschgOperationsDtlsVRec   => POksMschgOperationsDtlsVTbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = POksMschgOperationsDtlsVTbl.LAST);
        i := POksMschgOperationsDtlsVTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKSMSCHGOPERATIONSDTLSVTBL --
  --------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        POksMschgOperationsDtlsVTbl    => POksMschgOperationsDtlsVTbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------------
  -- update_row for:OKS_MSCHG_OPERATIONS_DTLS --
  ----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_mschg_operati2           IN OksMschgOperationsDtlsRecType,
    XOksMschgOperationsDtlsRec     OUT NOCOPY OksMschgOperationsDtlsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType := p_oks_mschg_operati2;
    LDefOksMschgOperationsDtlsRec  OksMschgOperationsDtlsRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oks_mschg_operati2 IN OksMschgOperationsDtlsRecType,
      XOksMschgOperationsDtlsRec OUT NOCOPY OksMschgOperationsDtlsRecType
    ) RETURN VARCHAR2 IS
      l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      XOksMschgOperationsDtlsRec := p_oks_mschg_operati2;
      -- Get current database values
      l_oks_mschg_operati3 := get_rec(p_oks_mschg_operati2, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (XOksMschgOperationsDtlsRec.id IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.id := l_oks_mschg_operati3.id;
        END IF;
        IF (XOksMschgOperationsDtlsRec.mrd_id IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.mrd_id := l_oks_mschg_operati3.mrd_id;
        END IF;
        IF (XOksMschgOperationsDtlsRec.oie_id IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.oie_id := l_oks_mschg_operati3.oie_id;
        END IF;
        IF (XOksMschgOperationsDtlsRec.ole_id IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.ole_id := l_oks_mschg_operati3.ole_id;
        END IF;
        IF (XOksMschgOperationsDtlsRec.mschg_type IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.mschg_type := l_oks_mschg_operati3.mschg_type;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute_level IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute_level := l_oks_mschg_operati3.attribute_level;
        END IF;
        IF (XOksMschgOperationsDtlsRec.qa_check_yn IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.qa_check_yn := l_oks_mschg_operati3.qa_check_yn;
        END IF;
        IF (XOksMschgOperationsDtlsRec.object_version_number IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.object_version_number := l_oks_mschg_operati3.object_version_number;
        END IF;
        IF (XOksMschgOperationsDtlsRec.created_by IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.created_by := l_oks_mschg_operati3.created_by;
        END IF;
        IF (XOksMschgOperationsDtlsRec.creation_date IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.creation_date := l_oks_mschg_operati3.creation_date;
        END IF;
        IF (XOksMschgOperationsDtlsRec.last_updated_by IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.last_updated_by := l_oks_mschg_operati3.last_updated_by;
        END IF;
        IF (XOksMschgOperationsDtlsRec.last_update_date IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.last_update_date := l_oks_mschg_operati3.last_update_date;
        END IF;
        IF (XOksMschgOperationsDtlsRec.last_update_login IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.last_update_login := l_oks_mschg_operati3.last_update_login;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute1 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute1 := l_oks_mschg_operati3.attribute1;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute2 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute2 := l_oks_mschg_operati3.attribute2;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute3 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute3 := l_oks_mschg_operati3.attribute3;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute4 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute4 := l_oks_mschg_operati3.attribute4;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute5 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute5 := l_oks_mschg_operati3.attribute5;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute6 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute6 := l_oks_mschg_operati3.attribute6;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute7 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute7 := l_oks_mschg_operati3.attribute7;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute8 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute8 := l_oks_mschg_operati3.attribute8;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute9 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute9 := l_oks_mschg_operati3.attribute9;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute10 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute10 := l_oks_mschg_operati3.attribute10;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute11 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute11 := l_oks_mschg_operati3.attribute11;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute12 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute12 := l_oks_mschg_operati3.attribute12;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute13 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute13 := l_oks_mschg_operati3.attribute13;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute14 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute14 := l_oks_mschg_operati3.attribute14;
        END IF;
        IF (XOksMschgOperationsDtlsRec.attribute15 IS NULL)
        THEN
          XOksMschgOperationsDtlsRec.attribute15 := l_oks_mschg_operati3.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKS_MSCHG_OPERATIONS_DTLS --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_mschg_operati2 IN OksMschgOperationsDtlsRecType,
      XOksMschgOperationsDtlsRec OUT NOCOPY OksMschgOperationsDtlsRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      XOksMschgOperationsDtlsRec := p_oks_mschg_operati2;
      XOksMschgOperationsDtlsRec.OBJECT_VERSION_NUMBER := p_oks_mschg_operati2.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_oks_mschg_operati2,              -- IN
      l_oks_mschg_operati3);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oks_mschg_operati3, LDefOksMschgOperationsDtlsRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_MSCHG_OPERATIONS_DTLS
    SET MRD_ID = LDefOksMschgOperationsDtlsRec.mrd_id,
        OIE_ID = LDefOksMschgOperationsDtlsRec.oie_id,
        OLE_ID = LDefOksMschgOperationsDtlsRec.ole_id,
        MSCHG_TYPE = LDefOksMschgOperationsDtlsRec.mschg_type,
        ATTRIBUTE_LEVEL = LDefOksMschgOperationsDtlsRec.attribute_level,
        QA_CHECK_YN = LDefOksMschgOperationsDtlsRec.qa_check_yn,
        OBJECT_VERSION_NUMBER = LDefOksMschgOperationsDtlsRec.object_version_number,
        CREATED_BY = LDefOksMschgOperationsDtlsRec.created_by,
        CREATION_DATE = LDefOksMschgOperationsDtlsRec.creation_date,
        LAST_UPDATED_BY = LDefOksMschgOperationsDtlsRec.last_updated_by,
        LAST_UPDATE_DATE = LDefOksMschgOperationsDtlsRec.last_update_date,
        LAST_UPDATE_LOGIN = LDefOksMschgOperationsDtlsRec.last_update_login,
        ATTRIBUTE1 = LDefOksMschgOperationsDtlsRec.attribute1,
        ATTRIBUTE2 = LDefOksMschgOperationsDtlsRec.attribute2,
        ATTRIBUTE3 = LDefOksMschgOperationsDtlsRec.attribute3,
        ATTRIBUTE4 = LDefOksMschgOperationsDtlsRec.attribute4,
        ATTRIBUTE5 = LDefOksMschgOperationsDtlsRec.attribute5,
        ATTRIBUTE6 = LDefOksMschgOperationsDtlsRec.attribute6,
        ATTRIBUTE7 = LDefOksMschgOperationsDtlsRec.attribute7,
        ATTRIBUTE8 = LDefOksMschgOperationsDtlsRec.attribute8,
        ATTRIBUTE9 = LDefOksMschgOperationsDtlsRec.attribute9,
        ATTRIBUTE10 = LDefOksMschgOperationsDtlsRec.attribute10,
        ATTRIBUTE11 = LDefOksMschgOperationsDtlsRec.attribute11,
        ATTRIBUTE12 = LDefOksMschgOperationsDtlsRec.attribute12,
        ATTRIBUTE13 = LDefOksMschgOperationsDtlsRec.attribute13,
        ATTRIBUTE14 = LDefOksMschgOperationsDtlsRec.attribute14,
        ATTRIBUTE15 = LDefOksMschgOperationsDtlsRec.attribute15
    WHERE ID = LDefOksMschgOperationsDtlsRec.id;

    XOksMschgOperationsDtlsRec := l_oks_mschg_operati3;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------------------
  -- update_row for:OKS_MSCHG_OPERATIONS_DTLS_V --
  ------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType,
    XOksMschgOperationsDtlsVRec    OUT NOCOPY OksMschgOperationsDtlsVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OksMschgOperationsDtlsVRec   OksMschgOperationsDtlsVRecType := p_OksMschgOperationsDtlsVRec;
    LDefOksMschgOperationsDtlsVRec OksMschgOperationsDtlsVRecType;
    l_db_OksMschgOperat42          OksMschgOperationsDtlsVRecType;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
    LxOksMschgOperationsDtlsRec    OksMschgOperationsDtlsRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_OksMschgOperationsDtlsVRec IN OksMschgOperationsDtlsVRecType
    ) RETURN OksMschgOperationsDtlsVRecType IS
      l_OksMschgOperationsDtlsVRec OksMschgOperationsDtlsVRecType := p_OksMschgOperationsDtlsVRec;
    BEGIN
      l_OksMschgOperationsDtlsVRec.LAST_UPDATE_DATE := SYSDATE;
      l_OksMschgOperationsDtlsVRec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_OksMschgOperationsDtlsVRec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_OksMschgOperationsDtlsVRec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_OksMschgOperationsDtlsVRec IN OksMschgOperationsDtlsVRecType,
      XOksMschgOperationsDtlsVRec OUT NOCOPY OksMschgOperationsDtlsVRecType
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      XOksMschgOperationsDtlsVRec := p_OksMschgOperationsDtlsVRec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_OksMschgOperat42 := get_rec(p_OksMschgOperationsDtlsVRec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (XOksMschgOperationsDtlsVRec.id IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.id := l_db_OksMschgOperat42.id;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.mrd_id IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.mrd_id := l_db_OksMschgOperat42.mrd_id;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.oie_id IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.oie_id := l_db_OksMschgOperat42.oie_id;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.ole_id IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.ole_id := l_db_OksMschgOperat42.ole_id;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.mschg_type IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.mschg_type := l_db_OksMschgOperat42.mschg_type;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute_level IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute_level := l_db_OksMschgOperat42.attribute_level;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.qa_check_yn IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.qa_check_yn := l_db_OksMschgOperat42.qa_check_yn;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.created_by IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.created_by := l_db_OksMschgOperat42.created_by;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.creation_date IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.creation_date := l_db_OksMschgOperat42.creation_date;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.last_updated_by IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.last_updated_by := l_db_OksMschgOperat42.last_updated_by;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.last_update_date IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.last_update_date := l_db_OksMschgOperat42.last_update_date;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.last_update_login IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.last_update_login := l_db_OksMschgOperat42.last_update_login;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.security_group_id IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.security_group_id := l_db_OksMschgOperat42.security_group_id;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute1 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute1 := l_db_OksMschgOperat42.attribute1;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute2 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute2 := l_db_OksMschgOperat42.attribute2;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute3 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute3 := l_db_OksMschgOperat42.attribute3;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute4 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute4 := l_db_OksMschgOperat42.attribute4;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute5 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute5 := l_db_OksMschgOperat42.attribute5;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute6 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute6 := l_db_OksMschgOperat42.attribute6;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute7 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute7 := l_db_OksMschgOperat42.attribute7;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute8 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute8 := l_db_OksMschgOperat42.attribute8;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute9 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute9 := l_db_OksMschgOperat42.attribute9;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute10 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute10 := l_db_OksMschgOperat42.attribute10;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute11 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute11 := l_db_OksMschgOperat42.attribute11;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute12 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute12 := l_db_OksMschgOperat42.attribute12;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute13 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute13 := l_db_OksMschgOperat42.attribute13;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute14 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute14 := l_db_OksMschgOperat42.attribute14;
        END IF;
        IF (XOksMschgOperationsDtlsVRec.attribute15 IS NULL)
        THEN
          XOksMschgOperationsDtlsVRec.attribute15 := l_db_OksMschgOperat42.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------------
    -- Set_Attributes for:OKS_MSCHG_OPERATIONS_DTLS_V --
    ----------------------------------------------------
    FUNCTION Set_Attributes (
      p_OksMschgOperationsDtlsVRec IN OksMschgOperationsDtlsVRecType,
      XOksMschgOperationsDtlsVRec OUT NOCOPY OksMschgOperationsDtlsVRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      XOksMschgOperationsDtlsVRec := p_OksMschgOperationsDtlsVRec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_OksMschgOperationsDtlsVRec,      -- IN
      XOksMschgOperationsDtlsVRec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_OksMschgOperationsDtlsVRec, LDefOksMschgOperationsDtlsVRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    LDefOksMschgOperationsDtlsVRec := fill_who_columns(LDefOksMschgOperationsDtlsVRec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(LDefOksMschgOperationsDtlsVRec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(LDefOksMschgOperationsDtlsVRec, l_db_OksMschgOperat42);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_OksMschgOperationsDtlsVRec   => p_OksMschgOperationsDtlsVRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(LDefOksMschgOperationsDtlsVRec, l_oks_mschg_operati3);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_mschg_operati3,
      LxOksMschgOperationsDtlsRec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOksMschgOperationsDtlsRec, LDefOksMschgOperationsDtlsVRec);
    XOksMschgOperationsDtlsVRec := LDefOksMschgOperationsDtlsVRec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------------------------
  -- PL/SQL TBL update_row for:OksMschgOperationsDtlsVTbl --
  ----------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      i := POksMschgOperationsDtlsVTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_OksMschgOperationsDtlsVRec   => POksMschgOperationsDtlsVTbl(i),
            XOksMschgOperationsDtlsVRec    => XOksMschgOperationsDtlsVTbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = POksMschgOperationsDtlsVTbl.LAST);
        i := POksMschgOperationsDtlsVTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ----------------------------------------------------------
  -- PL/SQL TBL update_row for:OKSMSCHGOPERATIONSDTLSVTBL --
  ----------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    XOksMschgOperationsDtlsVTbl    OUT NOCOPY OksMschgOperationsDtlsVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        POksMschgOperationsDtlsVTbl    => POksMschgOperationsDtlsVTbl,
        XOksMschgOperationsDtlsVTbl    => XOksMschgOperationsDtlsVTbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ----------------------------------------------
  -- delete_row for:OKS_MSCHG_OPERATIONS_DTLS --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_mschg_operati2           IN OksMschgOperationsDtlsRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType := p_oks_mschg_operati2;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKS_MSCHG_OPERATIONS_DTLS
     WHERE ID = p_oks_mschg_operati2.id;

    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------------
  -- delete_row for:OKS_MSCHG_OPERATIONS_DTLS_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OksMschgOperationsDtlsVRec   IN OksMschgOperationsDtlsVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OksMschgOperationsDtlsVRec   OksMschgOperationsDtlsVRecType := p_OksMschgOperationsDtlsVRec;
    l_oks_mschg_operati3           OksMschgOperationsDtlsRecType;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_OksMschgOperationsDtlsVRec, l_oks_mschg_operati3);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_mschg_operati3
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_MSCHG_OPERATIONS_DTLS_V --
  -----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      i := POksMschgOperationsDtlsVTbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_OksMschgOperationsDtlsVRec   => POksMschgOperationsDtlsVTbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = POksMschgOperationsDtlsVTbl.LAST);
        i := POksMschgOperationsDtlsVTbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  -----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_MSCHG_OPERATIONS_DTLS_V --
  -----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    POksMschgOperationsDtlsVTbl    IN OksMschgOperationsDtlsVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (POksMschgOperationsDtlsVTbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        POksMschgOperationsDtlsVTbl    => POksMschgOperationsDtlsVTbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKS_MOD_PVT;


/
