--------------------------------------------------------
--  DDL for Package Body OKS_ACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ACT_PVT" AS
/* $Header: OKSACTYB.pls 120.1 2005/07/15 09:17:32 parkumar noship $ */
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
  -- FUNCTION get_rec for: OKS_ACTION_TIME_TYPES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OksActionTimeTypesVRecType IS
    CURSOR oks_attv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            ACTION_TYPE_CODE,
            SECURITY_GROUP_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
-- R12 Data Model Changes 4485150 Start
            ORIG_SYSTEM_ID1,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Oks_Action_Time_Types_V
     WHERE oks_action_time_types_v.id = p_id;
    l_oks_attv_pk                  oks_attv_pk_csr%ROWTYPE;
    l_oks_action_time_types_v_rec  OksActionTimeTypesVRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_attv_pk_csr (p_oks_action_time_types_v_rec.id);
    FETCH oks_attv_pk_csr INTO
              l_oks_action_time_types_v_rec.id,
              l_oks_action_time_types_v_rec.cle_id,
              l_oks_action_time_types_v_rec.dnz_chr_id,
              l_oks_action_time_types_v_rec.action_type_code,
              l_oks_action_time_types_v_rec.security_group_id,
              l_oks_action_time_types_v_rec.program_application_id,
              l_oks_action_time_types_v_rec.program_id,
              l_oks_action_time_types_v_rec.program_update_date,
              l_oks_action_time_types_v_rec.request_id,
              l_oks_action_time_types_v_rec.created_by,
              l_oks_action_time_types_v_rec.creation_date,
              l_oks_action_time_types_v_rec.last_updated_by,
              l_oks_action_time_types_v_rec.last_update_date,
              l_oks_action_time_types_v_rec.last_update_login,
              l_oks_action_time_types_v_rec.object_version_number,
-- R12 Data Model Changes 4485150 Start
              l_oks_action_time_types_v_rec.orig_system_id1,
              l_oks_action_time_types_v_rec.orig_system_reference1,
              l_oks_action_time_types_v_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
;

    x_no_data_found := oks_attv_pk_csr%NOTFOUND;
    CLOSE oks_attv_pk_csr;
    RETURN(l_oks_action_time_types_v_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN OksActionTimeTypesVRecType IS
    l_oks_action_time_types_v_rec  OksActionTimeTypesVRecType;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_v_rec := get_rec(p_oks_action_time_types_v_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oks_action_time_types_v_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType
  ) RETURN OksActionTimeTypesVRecType IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oks_action_time_types_v_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_ACTION_TIME_TYPES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_action_time_types_rec    IN oks_action_time_types_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oks_action_time_types_rec_type IS
    CURSOR oks_att_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            ACTION_TYPE_CODE,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER,
-- R12 Data Model Changes 4485150 Start
            ORIG_SYSTEM_ID1,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Oks_Action_Time_Types
     WHERE oks_action_time_types.id = p_id;
    l_oks_att_pk                   oks_att_pk_csr%ROWTYPE;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_att_pk_csr (p_oks_action_time_types_rec.id);
    FETCH oks_att_pk_csr INTO
              l_oks_action_time_types_rec.id,
              l_oks_action_time_types_rec.cle_id,
              l_oks_action_time_types_rec.dnz_chr_id,
              l_oks_action_time_types_rec.action_type_code,
              l_oks_action_time_types_rec.program_application_id,
              l_oks_action_time_types_rec.program_id,
              l_oks_action_time_types_rec.program_update_date,
              l_oks_action_time_types_rec.request_id,
              l_oks_action_time_types_rec.created_by,
              l_oks_action_time_types_rec.creation_date,
              l_oks_action_time_types_rec.last_updated_by,
              l_oks_action_time_types_rec.last_update_date,
              l_oks_action_time_types_rec.last_update_login,
              l_oks_action_time_types_rec.object_version_number,
-- R12 Data Model Changes 4485150 Start
              l_oks_action_time_types_rec.orig_system_id1,
              l_oks_action_time_types_rec.orig_system_reference1,
              l_oks_action_time_types_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
;
    x_no_data_found := oks_att_pk_csr%NOTFOUND;
    CLOSE oks_att_pk_csr;
    RETURN(l_oks_action_time_types_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_action_time_types_rec    IN oks_action_time_types_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oks_action_time_types_rec_type IS
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_rec := get_rec(p_oks_action_time_types_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oks_action_time_types_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oks_action_time_types_rec    IN oks_action_time_types_rec_type
  ) RETURN oks_action_time_types_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oks_action_time_types_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_ACTION_TIME_TYPES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_oks_action_time_types_v_rec   IN OksActionTimeTypesVRecType
  ) RETURN OksActionTimeTypesVRecType IS
    l_oks_action_time_types_v_rec  OksActionTimeTypesVRecType := p_oks_action_time_types_v_rec;
  BEGIN
    IF (l_oks_action_time_types_v_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.id := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.cle_id := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.dnz_chr_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.action_type_code = OKC_API.G_MISS_CHAR ) THEN
      l_oks_action_time_types_v_rec.action_type_code := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.security_group_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.security_group_id := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.program_application_id := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.program_id := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oks_action_time_types_v_rec.program_update_date := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.request_id := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.created_by := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_oks_action_time_types_v_rec.creation_date := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.last_updated_by := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_oks_action_time_types_v_rec.last_update_date := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.last_update_login := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.object_version_number := NULL;
    END IF;
-- R12 Data Model Changes 4485150 Start
    IF (l_oks_action_time_types_v_rec.orig_system_id1 = OKC_API.G_MISS_NUM ) THEN
      l_oks_action_time_types_v_rec.orig_system_id1 := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR ) THEN
      l_oks_action_time_types_v_rec.orig_system_reference1 := NULL;
    END IF;
    IF (l_oks_action_time_types_v_rec.orig_system_source_code = OKC_API.G_MISS_CHAR ) THEN
      l_oks_action_time_types_v_rec.orig_system_source_code := NULL;
    END IF;
-- R12 Data Model Changes 4485150 End

    RETURN(l_oks_action_time_types_v_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id = OKC_API.G_MISS_NUM OR
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
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKC_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
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
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKS_ACTION_TIME_TYPES_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType
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
    validate_id(x_return_status, p_oks_action_time_types_v_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_oks_action_time_types_v_rec.object_version_number);
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
  -------------------------------------------------
  -- Validate Record for:OKS_ACTION_TIME_TYPES_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_oks_action_time_types_v_rec IN OksActionTimeTypesVRecType,
    p_db_oks_action_tim1 IN OksActionTimeTypesVRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_oks_action_time_types_v_rec IN OksActionTimeTypesVRecType
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_oks_action_tim2           OksActionTimeTypesVRecType := get_rec(p_oks_action_time_types_v_rec);
  BEGIN
    l_return_status := Validate_Record(p_oks_action_time_types_v_rec => p_oks_action_time_types_v_rec,
                                       p_db_oks_action_tim1 => l_db_oks_action_tim2);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN OksActionTimeTypesVRecType,
    p_to   IN OUT NOCOPY oks_action_time_types_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.action_type_code := p_from.action_type_code;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
-- R12 Data Model Changes 4485150 Start
    p_to.orig_system_id1 := p_from.orig_system_id1;
    p_to.orig_system_reference1 := p_from.orig_system_reference1;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
-- R12 Data Model Changes 4485150 End
  END migrate;
  PROCEDURE migrate (
    p_from IN oks_action_time_types_rec_type,
    p_to   IN OUT NOCOPY OksActionTimeTypesVRecType
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.action_type_code := p_from.action_type_code;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
-- R12 Data Model Changes 4485150 Start
    p_to.orig_system_id1 := p_from.orig_system_id1;
    p_to.orig_system_reference1 := p_from.orig_system_reference1;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
-- R12 Data Model Changes 4485150 End
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKS_ACTION_TIME_TYPES_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_v_rec  OksActionTimeTypesVRecType := p_oks_action_time_types_v_rec;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
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
    l_return_status := Validate_Attributes(l_oks_action_time_types_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_oks_action_time_types_v_rec);
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
  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_ACTION_TIME_TYPES_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      i := p_oks_action_time_types_v_tbl.FIRST;
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
            p_oks_action_time_types_v_rec  => p_oks_action_time_types_v_tbl(i));
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
        EXIT WHEN (i = p_oks_action_time_types_v_tbl.LAST);
        i := p_oks_action_time_types_v_tbl.NEXT(i);
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

  ---------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_ACTION_TIME_TYPES_V --
  ---------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_action_time_types_v_tbl  => p_oks_action_time_types_v_tbl,
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
  ------------------------------------------
  -- insert_row for:OKS_ACTION_TIME_TYPES --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_rec    IN oks_action_time_types_rec_type,
    x_oks_action_time_types_rec    OUT NOCOPY oks_action_time_types_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type := p_oks_action_time_types_rec;
    LDefOksActionTimeTypesRec      oks_action_time_types_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKS_ACTION_TIME_TYPES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_action_time_types_rec IN oks_action_time_types_rec_type,
      x_oks_action_time_types_rec OUT NOCOPY oks_action_time_types_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_action_time_types_rec := p_oks_action_time_types_rec;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_oks_action_time_types_rec,       -- IN
      l_oks_action_time_types_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_ACTION_TIME_TYPES(
      id,
      cle_id,
      dnz_chr_id,
      action_type_code,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number,
-- R12 Data Model Changes 4485150 Start
      orig_system_id1,
      orig_system_reference1,
      orig_system_source_code
-- R12 Data Model Changes 4485150 End
)
    VALUES (
      l_oks_action_time_types_rec.id,
      l_oks_action_time_types_rec.cle_id,
      l_oks_action_time_types_rec.dnz_chr_id,
      l_oks_action_time_types_rec.action_type_code,
      l_oks_action_time_types_rec.program_application_id,
      l_oks_action_time_types_rec.program_id,
      l_oks_action_time_types_rec.program_update_date,
      l_oks_action_time_types_rec.request_id,
      l_oks_action_time_types_rec.created_by,
      l_oks_action_time_types_rec.creation_date,
      l_oks_action_time_types_rec.last_updated_by,
      l_oks_action_time_types_rec.last_update_date,
      l_oks_action_time_types_rec.last_update_login,
      l_oks_action_time_types_rec.object_version_number,
-- R12 Data Model Changes 4485150 Start
      l_oks_action_time_types_rec.orig_system_id1,
      l_oks_action_time_types_rec.orig_system_reference1,
      l_oks_action_time_types_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
);
    -- Set OUT values
    x_oks_action_time_types_rec := l_oks_action_time_types_rec;
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
  ---------------------------------------------
  -- insert_row for :OKS_ACTION_TIME_TYPES_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType,
    x_oks_action_time_types_v_rec  OUT NOCOPY OksActionTimeTypesVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_v_rec  OksActionTimeTypesVRecType := p_oks_action_time_types_v_rec;
    LDefOksActionTimeTypesVRec     OksActionTimeTypesVRecType;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
    lx_oks_action_time_types_rec   oks_action_time_types_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oks_action_time_types_v_rec IN OksActionTimeTypesVRecType
    ) RETURN OksActionTimeTypesVRecType IS
      l_oks_action_time_types_v_rec OksActionTimeTypesVRecType := p_oks_action_time_types_v_rec;
    BEGIN
      l_oks_action_time_types_v_rec.CREATION_DATE := SYSDATE;
      l_oks_action_time_types_v_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_oks_action_time_types_v_rec.LAST_UPDATE_DATE := l_oks_action_time_types_v_rec.CREATION_DATE;
      l_oks_action_time_types_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oks_action_time_types_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oks_action_time_types_v_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKS_ACTION_TIME_TYPES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_action_time_types_v_rec IN OksActionTimeTypesVRecType,
      x_oks_action_time_types_v_rec OUT NOCOPY OksActionTimeTypesVRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_action_time_types_v_rec := p_oks_action_time_types_v_rec;
      x_oks_action_time_types_v_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_oks_action_time_types_v_rec := null_out_defaults(p_oks_action_time_types_v_rec);
    -- Set primary key value
    l_oks_action_time_types_v_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_oks_action_time_types_v_rec,     -- IN
      LDefOksActionTimeTypesVRec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    LDefOksActionTimeTypesVRec := fill_who_columns(LDefOksActionTimeTypesVRec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(LDefOksActionTimeTypesVRec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(LDefOksActionTimeTypesVRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(LDefOksActionTimeTypesVRec, l_oks_action_time_types_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_action_time_types_rec,
      lx_oks_action_time_types_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oks_action_time_types_rec, LDefOksActionTimeTypesVRec);
    -- Set OUT values
    x_oks_action_time_types_v_rec := LDefOksActionTimeTypesVRec;
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
  -----------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKS_ACTION_TIME_TYPES_V_TBL --
  -----------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      i := p_oks_action_time_types_v_tbl.FIRST;
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
            p_oks_action_time_types_v_rec  => p_oks_action_time_types_v_tbl(i),
            x_oks_action_time_types_v_rec  => x_oks_action_time_types_v_tbl(i));
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
        EXIT WHEN (i = p_oks_action_time_types_v_tbl.LAST);
        i := p_oks_action_time_types_v_tbl.NEXT(i);
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

  -----------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKS_ACTION_TIME_TYPES_V_TBL --
  -----------------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_action_time_types_v_tbl  => p_oks_action_time_types_v_tbl,
        x_oks_action_time_types_v_tbl  => x_oks_action_time_types_v_tbl,
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
  ----------------------------------------
  -- lock_row for:OKS_ACTION_TIME_TYPES --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_rec    IN oks_action_time_types_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oks_action_time_types_rec IN oks_action_time_types_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_ACTION_TIME_TYPES
     WHERE ID = p_oks_action_time_types_rec.id
       AND OBJECT_VERSION_NUMBER = p_oks_action_time_types_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_oks_action_time_types_rec IN oks_action_time_types_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_ACTION_TIME_TYPES
     WHERE ID = p_oks_action_time_types_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_ACTION_TIME_TYPES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_ACTION_TIME_TYPES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_oks_action_time_types_rec);
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
      OPEN lchk_csr(p_oks_action_time_types_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oks_action_time_types_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oks_action_time_types_rec.object_version_number THEN
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
  -------------------------------------------
  -- lock_row for: OKS_ACTION_TIME_TYPES_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_oks_action_time_types_v_rec, l_oks_action_time_types_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_action_time_types_rec
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
  ---------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKS_ACTION_TIME_TYPES_V_TBL --
  ---------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      i := p_oks_action_time_types_v_tbl.FIRST;
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
            p_oks_action_time_types_v_rec  => p_oks_action_time_types_v_tbl(i));
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
        EXIT WHEN (i = p_oks_action_time_types_v_tbl.LAST);
        i := p_oks_action_time_types_v_tbl.NEXT(i);
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
  ---------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKS_ACTION_TIME_TYPES_V_TBL --
  ---------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_action_time_types_v_tbl  => p_oks_action_time_types_v_tbl,
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
  ------------------------------------------
  -- update_row for:OKS_ACTION_TIME_TYPES --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_rec    IN oks_action_time_types_rec_type,
    x_oks_action_time_types_rec    OUT NOCOPY oks_action_time_types_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type := p_oks_action_time_types_rec;
    LDefOksActionTimeTypesRec      oks_action_time_types_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oks_action_time_types_rec IN oks_action_time_types_rec_type,
      x_oks_action_time_types_rec OUT NOCOPY oks_action_time_types_rec_type
    ) RETURN VARCHAR2 IS
      l_oks_action_time_types_rec    oks_action_time_types_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_action_time_types_rec := p_oks_action_time_types_rec;
      -- Get current database values
      l_oks_action_time_types_rec := get_rec(p_oks_action_time_types_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oks_action_time_types_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.id := l_oks_action_time_types_rec.id;
        END IF;
        IF (x_oks_action_time_types_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.cle_id := l_oks_action_time_types_rec.cle_id;
        END IF;
        IF (x_oks_action_time_types_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.dnz_chr_id := l_oks_action_time_types_rec.dnz_chr_id;
        END IF;
        IF (x_oks_action_time_types_rec.action_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_action_time_types_rec.action_type_code := l_oks_action_time_types_rec.action_type_code;
        END IF;
        IF (x_oks_action_time_types_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.program_application_id := l_oks_action_time_types_rec.program_application_id;
        END IF;
        IF (x_oks_action_time_types_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.program_id := l_oks_action_time_types_rec.program_id;
        END IF;
        IF (x_oks_action_time_types_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_action_time_types_rec.program_update_date := l_oks_action_time_types_rec.program_update_date;
        END IF;
        IF (x_oks_action_time_types_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.request_id := l_oks_action_time_types_rec.request_id;
        END IF;
        IF (x_oks_action_time_types_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.created_by := l_oks_action_time_types_rec.created_by;
        END IF;
        IF (x_oks_action_time_types_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_action_time_types_rec.creation_date := l_oks_action_time_types_rec.creation_date;
        END IF;
        IF (x_oks_action_time_types_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.last_updated_by := l_oks_action_time_types_rec.last_updated_by;
        END IF;
        IF (x_oks_action_time_types_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_action_time_types_rec.last_update_date := l_oks_action_time_types_rec.last_update_date;
        END IF;
        IF (x_oks_action_time_types_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.last_update_login := l_oks_action_time_types_rec.last_update_login;
        END IF;
        IF (x_oks_action_time_types_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.object_version_number := l_oks_action_time_types_rec.object_version_number;
        END IF;
-- R12 Data Model Changes 4485150 Start
        IF (x_oks_action_time_types_rec.orig_system_id1 = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_rec.orig_system_id1 := l_oks_action_time_types_rec.orig_system_id1;
        END IF;
        IF (x_oks_action_time_types_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_action_time_types_rec.orig_system_reference1 := l_oks_action_time_types_rec.orig_system_reference1;
        END IF;
        IF (x_oks_action_time_types_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_action_time_types_rec.orig_system_source_code := l_oks_action_time_types_rec.orig_system_source_code;
        END IF;
-- R12 Data Model Changes 4485150 End
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKS_ACTION_TIME_TYPES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_action_time_types_rec IN oks_action_time_types_rec_type,
      x_oks_action_time_types_rec OUT NOCOPY oks_action_time_types_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_action_time_types_rec := p_oks_action_time_types_rec;
      x_oks_action_time_types_rec.OBJECT_VERSION_NUMBER := p_oks_action_time_types_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_oks_action_time_types_rec,       -- IN
      l_oks_action_time_types_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oks_action_time_types_rec, LDefOksActionTimeTypesRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_ACTION_TIME_TYPES
    SET CLE_ID = LDefOksActionTimeTypesRec.cle_id,
        DNZ_CHR_ID = LDefOksActionTimeTypesRec.dnz_chr_id,
        ACTION_TYPE_CODE = LDefOksActionTimeTypesRec.action_type_code,
        PROGRAM_APPLICATION_ID = LDefOksActionTimeTypesRec.program_application_id,
        PROGRAM_ID = LDefOksActionTimeTypesRec.program_id,
        PROGRAM_UPDATE_DATE = LDefOksActionTimeTypesRec.program_update_date,
        REQUEST_ID = LDefOksActionTimeTypesRec.request_id,
        CREATED_BY = LDefOksActionTimeTypesRec.created_by,
        CREATION_DATE = LDefOksActionTimeTypesRec.creation_date,
        LAST_UPDATED_BY = LDefOksActionTimeTypesRec.last_updated_by,
        LAST_UPDATE_DATE = LDefOksActionTimeTypesRec.last_update_date,
        LAST_UPDATE_LOGIN = LDefOksActionTimeTypesRec.last_update_login,
        OBJECT_VERSION_NUMBER = LDefOksActionTimeTypesRec.object_version_number,
-- R12 Data Model Changes 4485150 Start
        ORIG_SYSTEM_ID1	 = LDefOksActionTimeTypesRec.orig_system_id1,
        ORIG_SYSTEM_REFERENCE1	= LDefOksActionTimeTypesRec.orig_system_reference1,
        ORIG_SYSTEM_SOURCE_CODE	= LDefOksActionTimeTypesRec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
    WHERE ID = LDefOksActionTimeTypesRec.id;

    x_oks_action_time_types_rec := l_oks_action_time_types_rec;
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
  --------------------------------------------
  -- update_row for:OKS_ACTION_TIME_TYPES_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType,
    x_oks_action_time_types_v_rec  OUT NOCOPY OksActionTimeTypesVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_v_rec  OksActionTimeTypesVRecType := p_oks_action_time_types_v_rec;
    LDefOksActionTimeTypesVRec     OksActionTimeTypesVRecType;
    l_db_oks_action_tim2           OksActionTimeTypesVRecType;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
    lx_oks_action_time_types_rec   oks_action_time_types_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oks_action_time_types_v_rec IN OksActionTimeTypesVRecType
    ) RETURN OksActionTimeTypesVRecType IS
      l_oks_action_time_types_v_rec OksActionTimeTypesVRecType := p_oks_action_time_types_v_rec;
    BEGIN
      l_oks_action_time_types_v_rec.LAST_UPDATE_DATE := SYSDATE;
      l_oks_action_time_types_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oks_action_time_types_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oks_action_time_types_v_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oks_action_time_types_v_rec IN OksActionTimeTypesVRecType,
      x_oks_action_time_types_v_rec OUT NOCOPY OksActionTimeTypesVRecType
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_action_time_types_v_rec := p_oks_action_time_types_v_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_oks_action_tim2 := get_rec(p_oks_action_time_types_v_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oks_action_time_types_v_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.id := l_db_oks_action_tim2.id;
        END IF;
        IF (x_oks_action_time_types_v_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.cle_id := l_db_oks_action_tim2.cle_id;
        END IF;
        IF (x_oks_action_time_types_v_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.dnz_chr_id := l_db_oks_action_tim2.dnz_chr_id;
        END IF;
        IF (x_oks_action_time_types_v_rec.action_type_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_action_time_types_v_rec.action_type_code := l_db_oks_action_tim2.action_type_code;
        END IF;
        IF (x_oks_action_time_types_v_rec.security_group_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.security_group_id := l_db_oks_action_tim2.security_group_id;
        END IF;
        IF (x_oks_action_time_types_v_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.program_application_id := l_db_oks_action_tim2.program_application_id;
        END IF;
        IF (x_oks_action_time_types_v_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.program_id := l_db_oks_action_tim2.program_id;
        END IF;
        IF (x_oks_action_time_types_v_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_action_time_types_v_rec.program_update_date := l_db_oks_action_tim2.program_update_date;
        END IF;
        IF (x_oks_action_time_types_v_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.request_id := l_db_oks_action_tim2.request_id;
        END IF;
        IF (x_oks_action_time_types_v_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.created_by := l_db_oks_action_tim2.created_by;
        END IF;
        IF (x_oks_action_time_types_v_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_action_time_types_v_rec.creation_date := l_db_oks_action_tim2.creation_date;
        END IF;
        IF (x_oks_action_time_types_v_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.last_updated_by := l_db_oks_action_tim2.last_updated_by;
        END IF;
        IF (x_oks_action_time_types_v_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_action_time_types_v_rec.last_update_date := l_db_oks_action_tim2.last_update_date;
        END IF;
        IF (x_oks_action_time_types_v_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.last_update_login := l_db_oks_action_tim2.last_update_login;
        END IF;
-- R12 Data Model Changes 4485150 Start
         IF (x_oks_action_time_types_v_rec.orig_system_id1 = OKC_API.G_MISS_NUM)
        THEN
          x_oks_action_time_types_v_rec.orig_system_id1 := l_db_oks_action_tim2.orig_system_id1;
        END IF;
        IF (x_oks_action_time_types_v_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_action_time_types_v_rec.orig_system_reference1 := l_db_oks_action_tim2.orig_system_reference1;
        END IF;
        IF (x_oks_action_time_types_v_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_action_time_types_v_rec.orig_system_source_code := l_db_oks_action_tim2.orig_system_source_code;
        END IF;
-- R12 Data Model Changes 4485150 End
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKS_ACTION_TIME_TYPES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_action_time_types_v_rec IN OksActionTimeTypesVRecType,
      x_oks_action_time_types_v_rec OUT NOCOPY OksActionTimeTypesVRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_action_time_types_v_rec := p_oks_action_time_types_v_rec;
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
      p_oks_action_time_types_v_rec,     -- IN
      x_oks_action_time_types_v_rec);    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oks_action_time_types_v_rec, LDefOksActionTimeTypesVRec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    LDefOksActionTimeTypesVRec := fill_who_columns(LDefOksActionTimeTypesVRec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(LDefOksActionTimeTypesVRec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(LDefOksActionTimeTypesVRec, l_db_oks_action_tim2);
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
      p_oks_action_time_types_v_rec  => p_oks_action_time_types_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(LDefOksActionTimeTypesVRec, l_oks_action_time_types_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_action_time_types_rec,
      lx_oks_action_time_types_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oks_action_time_types_rec, LDefOksActionTimeTypesVRec);
    x_oks_action_time_types_v_rec := LDefOksActionTimeTypesVRec;
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
  -----------------------------------------------------------
  -- PL/SQL TBL update_row for:oks_action_time_types_v_tbl --
  -----------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      i := p_oks_action_time_types_v_tbl.FIRST;
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
            p_oks_action_time_types_v_rec  => p_oks_action_time_types_v_tbl(i),
            x_oks_action_time_types_v_rec  => x_oks_action_time_types_v_tbl(i));
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
        EXIT WHEN (i = p_oks_action_time_types_v_tbl.LAST);
        i := p_oks_action_time_types_v_tbl.NEXT(i);
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

  -----------------------------------------------------------
  -- PL/SQL TBL update_row for:OKS_ACTION_TIME_TYPES_V_TBL --
  -----------------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    x_oks_action_time_types_v_tbl  OUT NOCOPY OksActionTimeTypesVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_action_time_types_v_tbl  => p_oks_action_time_types_v_tbl,
        x_oks_action_time_types_v_tbl  => x_oks_action_time_types_v_tbl,
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
  ------------------------------------------
  -- delete_row for:OKS_ACTION_TIME_TYPES --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_rec    IN oks_action_time_types_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type := p_oks_action_time_types_rec;
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

    DELETE FROM OKS_ACTION_TIME_TYPES
     WHERE ID = p_oks_action_time_types_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKS_ACTION_TIME_TYPES_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_rec  IN OksActionTimeTypesVRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_action_time_types_v_rec  OksActionTimeTypesVRecType := p_oks_action_time_types_v_rec;
    l_oks_action_time_types_rec    oks_action_time_types_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_oks_action_time_types_v_rec, l_oks_action_time_types_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_action_time_types_rec
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
  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_ACTION_TIME_TYPES_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      i := p_oks_action_time_types_v_tbl.FIRST;
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
            p_oks_action_time_types_v_rec  => p_oks_action_time_types_v_tbl(i));
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
        EXIT WHEN (i = p_oks_action_time_types_v_tbl.LAST);
        i := p_oks_action_time_types_v_tbl.NEXT(i);
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

  -------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_ACTION_TIME_TYPES_V --
  -------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_action_time_types_v_tbl  IN OksActionTimeTypesVTblType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oks_action_time_types_v_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_oks_action_time_types_v_tbl  => p_oks_action_time_types_v_tbl,
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


FUNCTION Create_Version(
             p_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS
	l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
  	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

BEGIN

     IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_ACT_PVT');
       okc_debug.log('23700: Entered create_version', 2);
    END IF;

INSERT INTO OKS_ACTION_TIME_TYPES_H(
				MAJOR_VERSION,
				ID,
				CLE_ID ,
				DNZ_CHR_ID,
				ACTION_TYPE_CODE ,
				SECURITY_GROUP_ID ,
				PROGRAM_APPLICATION_ID ,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID,
				CREATED_BY ,
				CREATION_DATE ,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE ,
				LAST_UPDATE_LOGIN,
				OBJECT_VERSION_NUMBER -- ,
-- R12 Data Model Changes 4485150 Start
                              /*  ORIG_SYSTEM_ID1,
                                ORIG_SYSTEM_REFERENCE1,
                                ORIG_SYSTEM_SOURCE_CODE */
-- R12 Data Model Changes 4485150 End
)
				SELECT
				p_major_version,
				ID,
				CLE_ID ,
				DNZ_CHR_ID,
				ACTION_TYPE_CODE ,
				SECURITY_GROUP_ID ,
				PROGRAM_APPLICATION_ID ,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID,
				CREATED_BY ,
				CREATION_DATE ,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE ,
				LAST_UPDATE_LOGIN,
				OBJECT_VERSION_NUMBER --,
-- R12 Data Model Changes 4485150 Start
                              /*  ORIG_SYSTEM_ID1,
                                ORIG_SYSTEM_REFERENCE1,
                                ORIG_SYSTEM_SOURCE_CODE */
-- R12 Data Model Changes 4485150 End
				FROM OKS_ACTION_TIME_TYPES
				WHERE DNZ_CHR_ID = P_Id;

	RETURN l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('23800: Exiting create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;


  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('23900: Exiting create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE
					(p_app_name     => okc_version_pvt.G_APP_NAME,
                     p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                     p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                     p_token1_value => sqlcode,
                     p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                     p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END Create_Version;


FUNCTION restore_version(
             p_id               IN NUMBER,
             p_major_version    IN NUMBER
           ) RETURN VARCHAR2 IS

  	l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
  	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKS_ACT_PVT');
       okc_debug.log('24000: Entered restore_version', 2);
    END IF;

DELETE OKS_ACTION_TIME_TYPES
WHERE DNZ_CHR_ID = p_id;

INSERT INTO OKS_ACTION_TIME_TYPES(
				ID,
				CLE_ID ,
				DNZ_CHR_ID,
				ACTION_TYPE_CODE ,
				SECURITY_GROUP_ID ,
				PROGRAM_APPLICATION_ID ,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID,
				CREATED_BY ,
				CREATION_DATE ,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE ,
				LAST_UPDATE_LOGIN,
				OBJECT_VERSION_NUMBER --,
-- R12 Data Model Changes 4485150 Start
                            /*    ORIG_SYSTEM_ID1,
                                ORIG_SYSTEM_REFERENCE1,
                                ORIG_SYSTEM_SOURCE_CODE */
-- R12 Data Model Changes 4485150 End
)
				SELECT
				ID,
				CLE_ID ,
				DNZ_CHR_ID,
				ACTION_TYPE_CODE ,
				SECURITY_GROUP_ID ,
				PROGRAM_APPLICATION_ID ,
				PROGRAM_ID,
				PROGRAM_UPDATE_DATE,
				REQUEST_ID,
				CREATED_BY ,
				CREATION_DATE ,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE ,
				LAST_UPDATE_LOGIN,
				OBJECT_VERSION_NUMBER-- ,
-- R12 Data Model Changes 4485150 Start
                           /*     ORIG_SYSTEM_ID1,
                                ORIG_SYSTEM_REFERENCE1,
                                ORIG_SYSTEM_SOURCE_CODE */
-- R12 Data Model Changes 4485150 End
				FROM OKS_ACTION_TIME_TYPES_H
				WHERE DNZ_CHR_ID = p_id
				AND major_version = p_major_version;

		RETURN l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('24100: Exiting restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;


  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('24200: Exiting restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack

             OKC_API.SET_MESSAGE
					(p_app_name     => okc_version_pvt.G_APP_NAME,
                     p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                     p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                     p_token1_value => sqlcode,
                     p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                     p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END restore_version;



END OKS_ACT_PVT;

/
