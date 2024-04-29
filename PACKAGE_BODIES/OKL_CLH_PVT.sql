--------------------------------------------------------
--  DDL for Package Body OKL_CLH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CLH_PVT" AS
/* $Header: OKLSCLHB.pls 120.4 2006/07/07 10:45:40 adagur noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
 G_CHECKLIST_TYPE_LOOKUP_TYPE CONSTANT VARCHAR2(30) := 'OKL_CHECKLIST_TYPE';

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
  -- FUNCTION get_rec for: OKL_CHECKLISTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_clhv_rec                     IN clhv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN clhv_rec_type IS
    CURSOR okl_clhv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CHECKLIST_NUMBER,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            CHECKLIST_TYPE,
            START_DATE,
            END_DATE,
            STATUS_CODE,
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
            LAST_UPDATE_LOGIN,
-- start: Apr 25, 2005 cklee: Modification for okl.h
            CHECKLIST_PURPOSE_CODE,
            DECISION_DATE,
            CHECKLIST_OBJ_ID,
            CHECKLIST_OBJ_TYPE_CODE,
            CKL_ID
-- end: Apr 25, 2005 cklee: Modification for okl.h
      FROM OKL_CHECKLISTS
     WHERE OKL_CHECKLISTS.id  = p_id;
    l_okl_clhv_pk                  okl_clhv_pk_csr%ROWTYPE;
    l_clhv_rec                     clhv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_clhv_pk_csr (p_clhv_rec.id);
    FETCH okl_clhv_pk_csr INTO
              l_clhv_rec.id,
              l_clhv_rec.object_version_number,
              l_clhv_rec.checklist_number,
              l_clhv_rec.description,
              l_clhv_rec.short_description,
              l_clhv_rec.checklist_type,
              l_clhv_rec.start_date,
              l_clhv_rec.end_date,
              l_clhv_rec.status_code,
              l_clhv_rec.attribute_category,
              l_clhv_rec.attribute1,
              l_clhv_rec.attribute2,
              l_clhv_rec.attribute3,
              l_clhv_rec.attribute4,
              l_clhv_rec.attribute5,
              l_clhv_rec.attribute6,
              l_clhv_rec.attribute7,
              l_clhv_rec.attribute8,
              l_clhv_rec.attribute9,
              l_clhv_rec.attribute10,
              l_clhv_rec.attribute11,
              l_clhv_rec.attribute12,
              l_clhv_rec.attribute13,
              l_clhv_rec.attribute14,
              l_clhv_rec.attribute15,
              l_clhv_rec.org_id,
              l_clhv_rec.request_id,
              l_clhv_rec.program_application_id,
              l_clhv_rec.program_id,
              l_clhv_rec.program_update_date,
              l_clhv_rec.created_by,
              l_clhv_rec.creation_date,
              l_clhv_rec.last_updated_by,
              l_clhv_rec.last_update_date,
              l_clhv_rec.last_update_login,
-- start: Apr 25, 2005 cklee: Modification for okl.h
              l_clhv_rec.CHECKLIST_PURPOSE_CODE,
              l_clhv_rec.DECISION_DATE,
              l_clhv_rec.CHECKLIST_OBJ_ID,
              l_clhv_rec.CHECKLIST_OBJ_TYPE_CODE,
              l_clhv_rec.CKL_ID
-- end: Apr 25, 2005 cklee: Modification for okl.h
              ;
    x_no_data_found := okl_clhv_pk_csr%NOTFOUND;
    CLOSE okl_clhv_pk_csr;
    RETURN(l_clhv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_clhv_rec                     IN clhv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN clhv_rec_type IS
    l_clhv_rec                     clhv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_clhv_rec := get_rec(p_clhv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_clhv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_clhv_rec                     IN clhv_rec_type
  ) RETURN clhv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_clhv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CHECKLISTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_clh_rec                      IN clh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN clh_rec_type IS
    CURSOR okl_checklists_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CHECKLIST_NUMBER,
            DESCRIPTION,
            SHORT_DESCRIPTION,
            CHECKLIST_TYPE,
            START_DATE,
            END_DATE,
            STATUS_CODE,
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
            LAST_UPDATE_LOGIN,
-- start: Apr 25, 2005 cklee: Modification for okl.h
            CHECKLIST_PURPOSE_CODE,
            DECISION_DATE,
            CHECKLIST_OBJ_ID,
            CHECKLIST_OBJ_TYPE_CODE,
            CKL_ID
-- end: Apr 25, 2005 cklee: Modification for okl.h
      FROM Okl_Checklists
     WHERE okl_checklists.id    = p_id;
    l_okl_checklists_pk            okl_checklists_pk_csr%ROWTYPE;
    l_clh_rec                      clh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_checklists_pk_csr (p_clh_rec.id);
    FETCH okl_checklists_pk_csr INTO
              l_clh_rec.id,
              l_clh_rec.object_version_number,
              l_clh_rec.checklist_number,
              l_clh_rec.description,
              l_clh_rec.short_description,
              l_clh_rec.checklist_type,
              l_clh_rec.start_date,
              l_clh_rec.end_date,
              l_clh_rec.status_code,
              l_clh_rec.attribute_category,
              l_clh_rec.attribute1,
              l_clh_rec.attribute2,
              l_clh_rec.attribute3,
              l_clh_rec.attribute4,
              l_clh_rec.attribute5,
              l_clh_rec.attribute6,
              l_clh_rec.attribute7,
              l_clh_rec.attribute8,
              l_clh_rec.attribute9,
              l_clh_rec.attribute10,
              l_clh_rec.attribute11,
              l_clh_rec.attribute12,
              l_clh_rec.attribute13,
              l_clh_rec.attribute14,
              l_clh_rec.attribute15,
              l_clh_rec.org_id,
              l_clh_rec.request_id,
              l_clh_rec.program_application_id,
              l_clh_rec.program_id,
              l_clh_rec.program_update_date,
              l_clh_rec.created_by,
              l_clh_rec.creation_date,
              l_clh_rec.last_updated_by,
              l_clh_rec.last_update_date,
              l_clh_rec.last_update_login,
-- start: Apr 25, 2005 cklee: Modification for okl.h
              l_clh_rec.CHECKLIST_PURPOSE_CODE,
              l_clh_rec.DECISION_DATE,
              l_clh_rec.CHECKLIST_OBJ_ID,
              l_clh_rec.CHECKLIST_OBJ_TYPE_CODE,
              l_clh_rec.CKL_ID
-- end: Apr 25, 2005 cklee: Modification for okl.h
              ;
    x_no_data_found := okl_checklists_pk_csr%NOTFOUND;
    CLOSE okl_checklists_pk_csr;
    RETURN(l_clh_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_clh_rec                      IN clh_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN clh_rec_type IS
    l_clh_rec                      clh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_clh_rec := get_rec(p_clh_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_clh_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_clh_rec                      IN clh_rec_type
  ) RETURN clh_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_clh_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CHECKLISTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_clhv_rec   IN clhv_rec_type
  ) RETURN clhv_rec_type IS
    l_clhv_rec                     clhv_rec_type := p_clhv_rec;
  BEGIN
    IF (l_clhv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.id := NULL;
    END IF;
    IF (l_clhv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.object_version_number := NULL;
    END IF;
    IF (l_clhv_rec.checklist_number = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.checklist_number := NULL;
    END IF;
    IF (l_clhv_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.description := NULL;
    END IF;
    IF (l_clhv_rec.short_description = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.short_description := NULL;
    END IF;
    IF (l_clhv_rec.checklist_type = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.checklist_type := NULL;
    END IF;
    IF (l_clhv_rec.start_date = OKC_API.G_MISS_DATE ) THEN
      l_clhv_rec.start_date := NULL;
    END IF;
    IF (l_clhv_rec.end_date = OKC_API.G_MISS_DATE ) THEN
      l_clhv_rec.end_date := NULL;
    END IF;
    IF (l_clhv_rec.status_code = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.status_code := NULL;
    END IF;
    IF (l_clhv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute_category := NULL;
    END IF;
    IF (l_clhv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute1 := NULL;
    END IF;
    IF (l_clhv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute2 := NULL;
    END IF;
    IF (l_clhv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute3 := NULL;
    END IF;
    IF (l_clhv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute4 := NULL;
    END IF;
    IF (l_clhv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute5 := NULL;
    END IF;
    IF (l_clhv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute6 := NULL;
    END IF;
    IF (l_clhv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute7 := NULL;
    END IF;
    IF (l_clhv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute8 := NULL;
    END IF;
    IF (l_clhv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute9 := NULL;
    END IF;
    IF (l_clhv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute10 := NULL;
    END IF;
    IF (l_clhv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute11 := NULL;
    END IF;
    IF (l_clhv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute12 := NULL;
    END IF;
    IF (l_clhv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute13 := NULL;
    END IF;
    IF (l_clhv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute14 := NULL;
    END IF;
    IF (l_clhv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.attribute15 := NULL;
    END IF;
    IF (l_clhv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.org_id := NULL;
    END IF;
    IF (l_clhv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.request_id := NULL;
    END IF;
    IF (l_clhv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.program_application_id := NULL;
    END IF;
    IF (l_clhv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.program_id := NULL;
    END IF;
    IF (l_clhv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_clhv_rec.program_update_date := NULL;
    END IF;
    IF (l_clhv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.created_by := NULL;
    END IF;
    IF (l_clhv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_clhv_rec.creation_date := NULL;
    END IF;
    IF (l_clhv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.last_updated_by := NULL;
    END IF;
    IF (l_clhv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_clhv_rec.last_update_date := NULL;
    END IF;
    IF (l_clhv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.last_update_login := NULL;
    END IF;

-- start: Apr 25, 2005 cklee: Modification for okl.h
    IF (l_clhv_rec.CHECKLIST_PURPOSE_CODE = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.CHECKLIST_PURPOSE_CODE := NULL;
    END IF;
    IF (l_clhv_rec.DECISION_DATE = OKC_API.G_MISS_DATE ) THEN
      l_clhv_rec.DECISION_DATE := NULL;
    END IF;
    IF (l_clhv_rec.CHECKLIST_OBJ_ID = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.CHECKLIST_OBJ_ID := NULL;
    END IF;
    IF (l_clhv_rec.CHECKLIST_OBJ_TYPE_CODE = OKC_API.G_MISS_CHAR ) THEN
      l_clhv_rec.CHECKLIST_OBJ_TYPE_CODE := NULL;
    END IF;
    IF (l_clhv_rec.CKL_ID = OKC_API.G_MISS_NUM ) THEN
      l_clhv_rec.CKL_ID := NULL;
    END IF;
-- end: Apr 25, 2005 cklee: Modification for okl.h

    RETURN(l_clhv_rec);
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
  ---------------------------------
  -- Validate_Attributes for: CHECKLIST_NUMBER --
  ---------------------------------
  PROCEDURE validate_clh_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_clh_number                   IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_clh_number = OKC_API.G_MISS_CHAR OR
        p_clh_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Checklist Number');
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
  END validate_clh_number;

  ---------------------------------
  -- Validate_Attributes for: CHECKLIST_TYPE --
  ---------------------------------
  PROCEDURE validate_clh_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_clh_type                     IN VARCHAR2) IS

    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_type (p_checklist_type VARCHAR2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = G_CHECKLIST_TYPE_LOOKUP_TYPE
     AND lok.lookup_code = p_checklist_type
    ;

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_clh_type = OKC_API.G_MISS_CHAR OR
        p_clh_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Checklist Type');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN c_type(p_clh_type);
    FETCH c_type INTO l_dummy;
    l_row_not_found := c_type%NOTFOUND;
    CLOSE c_type;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Type');

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
  END validate_clh_type;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_CHECKLISTS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_clhv_rec                     IN clhv_rec_type
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
    validate_id(x_return_status, p_clhv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- ***
    -- checklist_number
    -- ***
    validate_clh_number(x_return_status, p_clhv_rec.checklist_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- checklist_type
    -- ***
    validate_clh_type(x_return_status, p_clhv_rec.checklist_type);
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
  ------------------------------------------
  -- Validate Record for:OKL_CHECKLISTS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_clhv_rec IN clhv_rec_type,
    p_db_clhv_rec IN clhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_clhv_rec IN clhv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_clhv_rec                  clhv_rec_type := get_rec(p_clhv_rec);
  BEGIN
    l_return_status := Validate_Record(p_clhv_rec => p_clhv_rec,
                                       p_db_clhv_rec => l_db_clhv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN clhv_rec_type,
    p_to   IN OUT NOCOPY clh_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.checklist_number := p_from.checklist_number;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.checklist_type := p_from.checklist_type;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.status_code := p_from.status_code;
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
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- start: Apr 25, 2005 cklee: Modification for okl.h
    p_to.CHECKLIST_PURPOSE_CODE := p_from.CHECKLIST_PURPOSE_CODE;
    p_to.DECISION_DATE := p_from.DECISION_DATE;
    p_to.CHECKLIST_OBJ_ID := p_from.CHECKLIST_OBJ_ID;
    p_to.CHECKLIST_OBJ_TYPE_CODE := p_from.CHECKLIST_OBJ_TYPE_CODE;
    p_to.CKL_ID := p_from.CKL_ID;
-- end: Apr 25, 2005 cklee: Modification for okl.h

  END migrate;
  PROCEDURE migrate (
    p_from IN clh_rec_type,
    p_to   IN OUT NOCOPY clhv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.checklist_number := p_from.checklist_number;
    p_to.description := p_from.description;
    p_to.short_description := p_from.short_description;
    p_to.checklist_type := p_from.checklist_type;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.status_code := p_from.status_code;
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
    p_to.org_id := p_from.org_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- start: Apr 25, 2005 cklee: Modification for okl.h
    p_to.CHECKLIST_PURPOSE_CODE := p_from.CHECKLIST_PURPOSE_CODE;
    p_to.DECISION_DATE := p_from.DECISION_DATE;
    p_to.CHECKLIST_OBJ_ID := p_from.CHECKLIST_OBJ_ID;
    p_to.CHECKLIST_OBJ_TYPE_CODE := p_from.CHECKLIST_OBJ_TYPE_CODE;
    p_to.CKL_ID := p_from.CKL_ID;
-- end: Apr 25, 2005 cklee: Modification for okl.h
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_CHECKLISTS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_rec                     IN clhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clhv_rec                     clhv_rec_type := p_clhv_rec;
    l_clh_rec                      clh_rec_type;
    l_clh_rec                      clh_rec_type;
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
    l_return_status := Validate_Attributes(l_clhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_clhv_rec);
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
  --------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CHECKLISTS_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      i := p_clhv_tbl.FIRST;
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
            p_clhv_rec                     => p_clhv_tbl(i));
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
        EXIT WHEN (i = p_clhv_tbl.LAST);
        i := p_clhv_tbl.NEXT(i);
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

  --------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CHECKLISTS_V --
  --------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_clhv_tbl                     => p_clhv_tbl,
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
  -----------------------------------
  -- insert_row for:OKL_CHECKLISTS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clh_rec                      IN clh_rec_type,
    x_clh_rec                      OUT NOCOPY clh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clh_rec                      clh_rec_type := p_clh_rec;
    l_def_clh_rec                  clh_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_CHECKLISTS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_clh_rec IN clh_rec_type,
      x_clh_rec OUT NOCOPY clh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clh_rec := p_clh_rec;
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
      p_clh_rec,                         -- IN
      l_clh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CHECKLISTS(
      id,
      object_version_number,
      checklist_number,
      description,
      short_description,
      checklist_type,
      start_date,
      end_date,
      status_code,
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
      org_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
-- start: Apr 25, 2005 cklee: Modification for okl.h
      CHECKLIST_PURPOSE_CODE,
      DECISION_DATE,
      CHECKLIST_OBJ_ID,
      CHECKLIST_OBJ_TYPE_CODE,
      CKL_ID
-- end: Apr 25, 2005 cklee: Modification for okl.h
      )

    VALUES (
      l_clh_rec.id,
      l_clh_rec.object_version_number,
      l_clh_rec.checklist_number,
      l_clh_rec.description,
      l_clh_rec.short_description,
      l_clh_rec.checklist_type,
      l_clh_rec.start_date,
      l_clh_rec.end_date,
      l_clh_rec.status_code,
      l_clh_rec.attribute_category,
      l_clh_rec.attribute1,
      l_clh_rec.attribute2,
      l_clh_rec.attribute3,
      l_clh_rec.attribute4,
      l_clh_rec.attribute5,
      l_clh_rec.attribute6,
      l_clh_rec.attribute7,
      l_clh_rec.attribute8,
      l_clh_rec.attribute9,
      l_clh_rec.attribute10,
      l_clh_rec.attribute11,
      l_clh_rec.attribute12,
      l_clh_rec.attribute13,
      l_clh_rec.attribute14,
      l_clh_rec.attribute15,
      l_clh_rec.org_id,
      l_clh_rec.request_id,
      l_clh_rec.program_application_id,
      l_clh_rec.program_id,
      l_clh_rec.program_update_date,
      l_clh_rec.created_by,
      l_clh_rec.creation_date,
      l_clh_rec.last_updated_by,
      l_clh_rec.last_update_date,
      l_clh_rec.last_update_login,
-- start: Apr 25, 2005 cklee: Modification for okl.h
      l_clh_rec.CHECKLIST_PURPOSE_CODE,
      l_clh_rec.DECISION_DATE,
      l_clh_rec.CHECKLIST_OBJ_ID,
      l_clh_rec.CHECKLIST_OBJ_TYPE_CODE,
      l_clh_rec.CKL_ID
-- end: Apr 25, 2005 cklee: Modification for okl.h
      );
    -- Set OUT values
    x_clh_rec := l_clh_rec;
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
  --------------------------------------
  -- insert_row for :OKL_CHECKLISTS_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_rec                     IN clhv_rec_type,
    x_clhv_rec                     OUT NOCOPY clhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_clhv_rec                     clhv_rec_type := p_clhv_rec;

    l_def_clhv_rec                 clhv_rec_type;
    l_clh_rec                      clh_rec_type;
    lx_clh_rec                     clh_rec_type;


    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clhv_rec IN clhv_rec_type
    ) RETURN clhv_rec_type IS
      l_clhv_rec clhv_rec_type := p_clhv_rec;
    BEGIN
      l_clhv_rec.CREATION_DATE := SYSDATE;
      l_clhv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_clhv_rec.LAST_UPDATE_DATE := l_clhv_rec.CREATION_DATE;
      l_clhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_clhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_clhv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_CHECKLISTS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_clhv_rec IN clhv_rec_type,
      x_clhv_rec OUT NOCOPY clhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clhv_rec := p_clhv_rec;
      x_clhv_rec.OBJECT_VERSION_NUMBER := 1;

      -- concurrent program columns
      SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL,Fnd_Global.CONC_REQUEST_ID),
             DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL,Fnd_Global.PROG_APPL_ID),
             DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL,Fnd_Global.CONC_PROGRAM_ID),
             DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      INTO   x_clhv_rec.REQUEST_ID
            ,x_clhv_rec.PROGRAM_APPLICATION_ID
            ,x_clhv_rec.PROGRAM_ID
            ,x_clhv_rec.PROGRAM_UPDATE_DATE
      FROM DUAL;
      x_clhv_rec.org_id := mo_global.get_current_org_id();

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
    l_clhv_rec := null_out_defaults(p_clhv_rec);
    -- Set primary key value
    l_clhv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_clhv_rec,                        -- IN
      l_def_clhv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_clhv_rec := fill_who_columns(l_def_clhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clhv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_clhv_rec, l_clh_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------

    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_clh_rec,
      lx_clh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_clh_rec, l_def_clhv_rec);

    -- Set OUT values
    x_clhv_rec := l_def_clhv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL insert_row for:clhv_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type,
    x_clhv_tbl                     OUT NOCOPY clhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      i := p_clhv_tbl.FIRST;
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
            p_clhv_rec                     => p_clhv_tbl(i),
            x_clhv_rec                     => x_clhv_tbl(i));
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
        EXIT WHEN (i = p_clhv_tbl.LAST);
        i := p_clhv_tbl.NEXT(i);
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

  ----------------------------------------
  -- PL/SQL TBL insert_row for:clhv_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type,
    x_clhv_tbl                     OUT NOCOPY clhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_clhv_tbl                     => p_clhv_tbl,
        x_clhv_tbl                     => x_clhv_tbl,
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
  ---------------------------------
  -- lock_row for:OKL_CHECKLISTS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clh_rec                      IN clh_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_clh_rec IN clh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CHECKLISTS
     WHERE ID = p_clh_rec.id
       AND OBJECT_VERSION_NUMBER = p_clh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_clh_rec IN clh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CHECKLISTS
     WHERE ID = p_clh_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CHECKLISTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CHECKLISTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_clh_rec);
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
      OPEN lchk_csr(p_clh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_clh_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_clh_rec.object_version_number THEN
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
  ------------------------------------
  -- lock_row for: OKL_CHECKLISTS_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_rec                     IN clhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clh_rec                      clh_rec_type;
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
    migrate(p_clhv_rec, l_clh_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_clh_rec
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
  --------------------------------------
  -- PL/SQL TBL lock_row for:clhv_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      i := p_clhv_tbl.FIRST;
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
            p_clhv_rec                     => p_clhv_tbl(i));
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
        EXIT WHEN (i = p_clhv_tbl.LAST);
        i := p_clhv_tbl.NEXT(i);
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
  --------------------------------------
  -- PL/SQL TBL lock_row for:clhv_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_clhv_tbl                     => p_clhv_tbl,
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
  -----------------------------------
  -- update_row for:OKL_CHECKLISTS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clh_rec                      IN clh_rec_type,
    x_clh_rec                      OUT NOCOPY clh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clh_rec                      clh_rec_type := p_clh_rec;
    l_def_clh_rec                  clh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_clh_rec IN clh_rec_type,
      x_clh_rec OUT NOCOPY clh_rec_type
    ) RETURN VARCHAR2 IS
      l_clh_rec                      clh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clh_rec := p_clh_rec;
      -- Get current database values
      l_clh_rec := get_rec(p_clh_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_clh_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.id := l_clh_rec.id;
        END IF;
        IF (x_clh_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.object_version_number := l_clh_rec.object_version_number;
        END IF;
        IF (x_clh_rec.checklist_number = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.checklist_number := l_clh_rec.checklist_number;
        END IF;
        IF (x_clh_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.description := l_clh_rec.description;
        END IF;
        IF (x_clh_rec.short_description = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.short_description := l_clh_rec.short_description;
        END IF;
        IF (x_clh_rec.checklist_type = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.checklist_type := l_clh_rec.checklist_type;
        END IF;
        IF (x_clh_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_clh_rec.start_date := l_clh_rec.start_date;
        END IF;
        IF (x_clh_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_clh_rec.end_date := l_clh_rec.end_date;
        END IF;
        IF (x_clh_rec.status_code = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.status_code := l_clh_rec.status_code;
        END IF;
        IF (x_clh_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute_category := l_clh_rec.attribute_category;
        END IF;
        IF (x_clh_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute1 := l_clh_rec.attribute1;
        END IF;
        IF (x_clh_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute2 := l_clh_rec.attribute2;
        END IF;
        IF (x_clh_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute3 := l_clh_rec.attribute3;
        END IF;
        IF (x_clh_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute4 := l_clh_rec.attribute4;
        END IF;
        IF (x_clh_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute5 := l_clh_rec.attribute5;
        END IF;
        IF (x_clh_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute6 := l_clh_rec.attribute6;
        END IF;
        IF (x_clh_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute7 := l_clh_rec.attribute7;
        END IF;
        IF (x_clh_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute8 := l_clh_rec.attribute8;
        END IF;
        IF (x_clh_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute9 := l_clh_rec.attribute9;
        END IF;
        IF (x_clh_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute10 := l_clh_rec.attribute10;
        END IF;
        IF (x_clh_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute11 := l_clh_rec.attribute11;
        END IF;
        IF (x_clh_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute12 := l_clh_rec.attribute12;
        END IF;
        IF (x_clh_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute13 := l_clh_rec.attribute13;
        END IF;
        IF (x_clh_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute14 := l_clh_rec.attribute14;
        END IF;
        IF (x_clh_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_clh_rec.attribute15 := l_clh_rec.attribute15;
        END IF;
        IF (x_clh_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.org_id := l_clh_rec.org_id;
        END IF;
        IF (x_clh_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.request_id := l_clh_rec.request_id;
        END IF;
        IF (x_clh_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.program_application_id := l_clh_rec.program_application_id;
        END IF;
        IF (x_clh_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.program_id := l_clh_rec.program_id;
        END IF;
        IF (x_clh_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_clh_rec.program_update_date := l_clh_rec.program_update_date;
        END IF;
        IF (x_clh_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.created_by := l_clh_rec.created_by;
        END IF;
        IF (x_clh_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_clh_rec.creation_date := l_clh_rec.creation_date;
        END IF;
        IF (x_clh_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.last_updated_by := l_clh_rec.last_updated_by;
        END IF;
        IF (x_clh_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_clh_rec.last_update_date := l_clh_rec.last_update_date;
        END IF;
        IF (x_clh_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_clh_rec.last_update_login := l_clh_rec.last_update_login;
        END IF;

-- start: Apr 25, 2005 cklee: Modification for okl.h
        IF (x_clh_rec.CHECKLIST_PURPOSE_CODE = OKC_API.G_MISS_CHAR ) THEN
          x_clh_rec.CHECKLIST_PURPOSE_CODE := l_clh_rec.CHECKLIST_PURPOSE_CODE;
        END IF;
        IF (x_clh_rec.DECISION_DATE = OKC_API.G_MISS_DATE ) THEN
          x_clh_rec.DECISION_DATE := l_clh_rec.DECISION_DATE;
        END IF;
        IF (x_clh_rec.CHECKLIST_OBJ_ID = OKC_API.G_MISS_NUM ) THEN
          x_clh_rec.CHECKLIST_OBJ_ID := l_clh_rec.CHECKLIST_OBJ_ID;
        END IF;
        IF (x_clh_rec.CHECKLIST_OBJ_TYPE_CODE = OKC_API.G_MISS_CHAR ) THEN
          x_clh_rec.CHECKLIST_OBJ_TYPE_CODE := l_clh_rec.CHECKLIST_OBJ_TYPE_CODE;
        END IF;
        IF (x_clh_rec.CKL_ID = OKC_API.G_MISS_NUM ) THEN
          x_clh_rec.CKL_ID := l_clh_rec.CKL_ID;
        END IF;
-- end: Apr 25, 2005 cklee: Modification for okl.h

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_CHECKLISTS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_clh_rec IN clh_rec_type,
      x_clh_rec OUT NOCOPY clh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clh_rec := p_clh_rec;
      x_clh_rec.OBJECT_VERSION_NUMBER := p_clh_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_clh_rec,                         -- IN
      l_clh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_clh_rec, l_def_clh_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CHECKLISTS
    SET OBJECT_VERSION_NUMBER = l_def_clh_rec.object_version_number,
        CHECKLIST_NUMBER = l_def_clh_rec.checklist_number,
        DESCRIPTION = l_def_clh_rec.description,
        SHORT_DESCRIPTION = l_def_clh_rec.short_description,
        CHECKLIST_TYPE = l_def_clh_rec.checklist_type,
        START_DATE = l_def_clh_rec.start_date,
        END_DATE = l_def_clh_rec.end_date,
        STATUS_CODE = l_def_clh_rec.status_code,
        ATTRIBUTE_CATEGORY = l_def_clh_rec.attribute_category,
        ATTRIBUTE1 = l_def_clh_rec.attribute1,
        ATTRIBUTE2 = l_def_clh_rec.attribute2,
        ATTRIBUTE3 = l_def_clh_rec.attribute3,
        ATTRIBUTE4 = l_def_clh_rec.attribute4,
        ATTRIBUTE5 = l_def_clh_rec.attribute5,
        ATTRIBUTE6 = l_def_clh_rec.attribute6,
        ATTRIBUTE7 = l_def_clh_rec.attribute7,
        ATTRIBUTE8 = l_def_clh_rec.attribute8,
        ATTRIBUTE9 = l_def_clh_rec.attribute9,
        ATTRIBUTE10 = l_def_clh_rec.attribute10,
        ATTRIBUTE11 = l_def_clh_rec.attribute11,
        ATTRIBUTE12 = l_def_clh_rec.attribute12,
        ATTRIBUTE13 = l_def_clh_rec.attribute13,
        ATTRIBUTE14 = l_def_clh_rec.attribute14,
        ATTRIBUTE15 = l_def_clh_rec.attribute15,
        ORG_ID = l_def_clh_rec.org_id,
        REQUEST_ID = l_def_clh_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_clh_rec.program_application_id,
        PROGRAM_ID = l_def_clh_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_clh_rec.program_update_date,
        CREATED_BY = l_def_clh_rec.created_by,
        CREATION_DATE = l_def_clh_rec.creation_date,
        LAST_UPDATED_BY = l_def_clh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_clh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_clh_rec.last_update_login,
-- start: Apr 25, 2005 cklee: Modification for okl.h
        CHECKLIST_PURPOSE_CODE = l_def_clh_rec.CHECKLIST_PURPOSE_CODE,
        DECISION_DATE = l_def_clh_rec.DECISION_DATE,
        CHECKLIST_OBJ_ID = l_def_clh_rec.CHECKLIST_OBJ_ID,
        CHECKLIST_OBJ_TYPE_CODE = l_def_clh_rec.CHECKLIST_OBJ_TYPE_CODE,
        CKL_ID = l_def_clh_rec.CKL_ID
-- end: Apr 25, 2005 cklee: Modification for okl.h

    WHERE ID = l_def_clh_rec.id;

    x_clh_rec := l_clh_rec;
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
  -------------------------------------
  -- update_row for:OKL_CHECKLISTS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_rec                     IN clhv_rec_type,
    x_clhv_rec                     OUT NOCOPY clhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clhv_rec                     clhv_rec_type := p_clhv_rec;
    l_def_clhv_rec                 clhv_rec_type;
    l_db_clhv_rec                  clhv_rec_type;
    l_clh_rec                      clh_rec_type;
    lx_clh_rec                     clh_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_clhv_rec IN clhv_rec_type
    ) RETURN clhv_rec_type IS
      l_clhv_rec clhv_rec_type := p_clhv_rec;
    BEGIN
      l_clhv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_clhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_clhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_clhv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_clhv_rec IN clhv_rec_type,
      x_clhv_rec OUT NOCOPY clhv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clhv_rec := p_clhv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_clhv_rec := get_rec(p_clhv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_clhv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.id := l_db_clhv_rec.id;
        END IF;
        IF (x_clhv_rec.checklist_number = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.checklist_number := l_db_clhv_rec.checklist_number;
        END IF;
        IF (x_clhv_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.description := l_db_clhv_rec.description;
        END IF;
        IF (x_clhv_rec.short_description = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.short_description := l_db_clhv_rec.short_description;
        END IF;
        IF (x_clhv_rec.checklist_type = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.checklist_type := l_db_clhv_rec.checklist_type;
        END IF;
        IF (x_clhv_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_clhv_rec.start_date := l_db_clhv_rec.start_date;
        END IF;
        IF (x_clhv_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_clhv_rec.end_date := l_db_clhv_rec.end_date;
        END IF;
        IF (x_clhv_rec.status_code = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.status_code := l_db_clhv_rec.status_code;
        END IF;
        IF (x_clhv_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute_category := l_db_clhv_rec.attribute_category;
        END IF;
        IF (x_clhv_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute1 := l_db_clhv_rec.attribute1;
        END IF;
        IF (x_clhv_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute2 := l_db_clhv_rec.attribute2;
        END IF;
        IF (x_clhv_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute3 := l_db_clhv_rec.attribute3;
        END IF;
        IF (x_clhv_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute4 := l_db_clhv_rec.attribute4;
        END IF;
        IF (x_clhv_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute5 := l_db_clhv_rec.attribute5;
        END IF;
        IF (x_clhv_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute6 := l_db_clhv_rec.attribute6;
        END IF;
        IF (x_clhv_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute7 := l_db_clhv_rec.attribute7;
        END IF;
        IF (x_clhv_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute8 := l_db_clhv_rec.attribute8;
        END IF;
        IF (x_clhv_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute9 := l_db_clhv_rec.attribute9;
        END IF;
        IF (x_clhv_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute10 := l_db_clhv_rec.attribute10;
        END IF;
        IF (x_clhv_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute11 := l_db_clhv_rec.attribute11;
        END IF;
        IF (x_clhv_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute12 := l_db_clhv_rec.attribute12;
        END IF;
        IF (x_clhv_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute13 := l_db_clhv_rec.attribute13;
        END IF;
        IF (x_clhv_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute14 := l_db_clhv_rec.attribute14;
        END IF;
        IF (x_clhv_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_clhv_rec.attribute15 := l_db_clhv_rec.attribute15;
        END IF;
        IF (x_clhv_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.org_id := l_db_clhv_rec.org_id;
        END IF;
        IF (x_clhv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.request_id := l_db_clhv_rec.request_id;
        END IF;
        IF (x_clhv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.program_application_id := l_db_clhv_rec.program_application_id;
        END IF;
        IF (x_clhv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.program_id := l_db_clhv_rec.program_id;
        END IF;
        IF (x_clhv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_clhv_rec.program_update_date := l_db_clhv_rec.program_update_date;
        END IF;
        IF (x_clhv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.created_by := l_db_clhv_rec.created_by;
        END IF;
        IF (x_clhv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_clhv_rec.creation_date := l_db_clhv_rec.creation_date;
        END IF;
        IF (x_clhv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.last_updated_by := l_db_clhv_rec.last_updated_by;
        END IF;
        IF (x_clhv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_clhv_rec.last_update_date := l_db_clhv_rec.last_update_date;
        END IF;
        IF (x_clhv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_clhv_rec.last_update_login := l_db_clhv_rec.last_update_login;
        END IF;

-- start: Apr 25, 2005 cklee: Modification for okl.h
        IF (x_clhv_rec.CHECKLIST_PURPOSE_CODE = OKC_API.G_MISS_CHAR ) THEN
          x_clhv_rec.CHECKLIST_PURPOSE_CODE := l_db_clhv_rec.CHECKLIST_PURPOSE_CODE;
        END IF;
        IF (x_clhv_rec.DECISION_DATE = OKC_API.G_MISS_DATE ) THEN
          x_clhv_rec.DECISION_DATE := l_db_clhv_rec.DECISION_DATE;
        END IF;
        IF (x_clhv_rec.CHECKLIST_OBJ_ID = OKC_API.G_MISS_NUM ) THEN
          x_clhv_rec.CHECKLIST_OBJ_ID := l_db_clhv_rec.CHECKLIST_OBJ_ID;
        END IF;
        IF (x_clhv_rec.CHECKLIST_OBJ_TYPE_CODE = OKC_API.G_MISS_CHAR ) THEN
          x_clhv_rec.CHECKLIST_OBJ_TYPE_CODE := l_db_clhv_rec.CHECKLIST_OBJ_TYPE_CODE;
        END IF;
        IF (x_clhv_rec.CKL_ID = OKC_API.G_MISS_NUM ) THEN
          x_clhv_rec.CKL_ID := l_db_clhv_rec.CKL_ID;
        END IF;
-- end: Apr 25, 2005 cklee: Modification for okl.h

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_CHECKLISTS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_clhv_rec IN clhv_rec_type,
      x_clhv_rec OUT NOCOPY clhv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_clhv_rec := p_clhv_rec;
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
      p_clhv_rec,                        -- IN
      x_clhv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_clhv_rec, l_def_clhv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_clhv_rec := fill_who_columns(l_def_clhv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_clhv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_clhv_rec, l_db_clhv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

/***
    -- cklee COMMENTED
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_clhv_rec                     => p_clhv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
***/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_clhv_rec, l_clh_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_clh_rec,
      lx_clh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_clh_rec, l_def_clhv_rec);
    x_clhv_rec := l_def_clhv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL update_row for:clhv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type,
    x_clhv_tbl                     OUT NOCOPY clhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      i := p_clhv_tbl.FIRST;
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
            p_clhv_rec                     => p_clhv_tbl(i),
            x_clhv_rec                     => x_clhv_tbl(i));
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
        EXIT WHEN (i = p_clhv_tbl.LAST);
        i := p_clhv_tbl.NEXT(i);
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

  ----------------------------------------
  -- PL/SQL TBL update_row for:clhv_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type,
    x_clhv_tbl                     OUT NOCOPY clhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_clhv_tbl                     => p_clhv_tbl,
        x_clhv_tbl                     => x_clhv_tbl,
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
  -----------------------------------
  -- delete_row for:OKL_CHECKLISTS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clh_rec                      IN clh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clh_rec                      clh_rec_type := p_clh_rec;
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

    DELETE FROM OKL_CHECKLISTS
     WHERE ID = p_clh_rec.id;

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
  -------------------------------------
  -- delete_row for:OKL_CHECKLISTS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_rec                     IN clhv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_clhv_rec                     clhv_rec_type := p_clhv_rec;
    l_clh_rec                      clh_rec_type;
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
    migrate(l_clhv_rec, l_clh_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_clh_rec
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
  ------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CHECKLISTS_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      i := p_clhv_tbl.FIRST;
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
            p_clhv_rec                     => p_clhv_tbl(i));
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
        EXIT WHEN (i = p_clhv_tbl.LAST);
        i := p_clhv_tbl.NEXT(i);
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

  ------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CHECKLISTS_V --
  ------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_clhv_tbl                     IN clhv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clhv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_clhv_tbl                     => p_clhv_tbl,
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

END OKL_CLH_PVT;

/
