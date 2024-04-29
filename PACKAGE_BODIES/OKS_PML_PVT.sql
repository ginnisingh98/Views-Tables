--------------------------------------------------------
--  DDL for Package Body OKS_PML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_PML_PVT" AS
/* $Header: OKSSPMLB.pls 120.1 2005/07/15 09:25:35 parkumar noship $ */

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
  -- FUNCTION get_rec for: OKS_PM_STREAM_LEVELS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pmlv_rec                     IN pmlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pmlv_rec_type IS
    CURSOR oks_pmlv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            ACTIVITY_LINE_ID,
            SEQUENCE_NUMBER,
            NUMBER_OF_OCCURENCES,
            START_DATE,
            END_DATE,
            FREQUENCY,
            FREQUENCY_UOM,
            OFFSET_DURATION,
            OFFSET_UOM,
            AUTOSCHEDULE_YN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            OBJECT_VERSION_NUMBER,
            SECURITY_GROUP_ID,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- R12 Data Model Changes 4485150 Start
            ORIG_SYSTEM_ID1	,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Oks_Pm_Stream_Levels_V
     WHERE oks_pm_stream_levels_v.id = p_id;
    l_oks_pmlv_pk                  oks_pmlv_pk_csr%ROWTYPE;
    l_pmlv_rec                     pmlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_pmlv_pk_csr (p_pmlv_rec.id);
    FETCH oks_pmlv_pk_csr INTO
              l_pmlv_rec.id,
              l_pmlv_rec.cle_id,
              l_pmlv_rec.dnz_chr_id,
              l_pmlv_rec.activity_line_id,
              l_pmlv_rec.sequence_number,
              l_pmlv_rec.number_of_occurences,
              l_pmlv_rec.start_date,
              l_pmlv_rec.end_date,
              l_pmlv_rec.frequency,
              l_pmlv_rec.frequency_uom,
              l_pmlv_rec.offset_duration,
              l_pmlv_rec.offset_uom,
              l_pmlv_rec.autoschedule_yn,
              l_pmlv_rec.program_application_id,
              l_pmlv_rec.program_id,
              l_pmlv_rec.program_update_date,
              l_pmlv_rec.object_version_number,
              l_pmlv_rec.security_group_id,
              l_pmlv_rec.request_id,
              l_pmlv_rec.created_by,
              l_pmlv_rec.creation_date,
              l_pmlv_rec.last_updated_by,
              l_pmlv_rec.last_update_date,
              l_pmlv_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
              l_pmlv_rec.orig_system_id1,
              l_pmlv_rec.orig_system_reference1,
              l_pmlv_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
;
    x_no_data_found := oks_pmlv_pk_csr%NOTFOUND;
    CLOSE oks_pmlv_pk_csr;
    RETURN(l_pmlv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pmlv_rec                     IN pmlv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pmlv_rec_type IS
    l_pmlv_rec                     pmlv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_pmlv_rec := get_rec(p_pmlv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pmlv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pmlv_rec                     IN pmlv_rec_type
  ) RETURN pmlv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pmlv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_PM_STREAM_LEVELS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pml_rec                      IN pml_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pml_rec_type IS
    CURSOR oks_pm_stream_levels_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            ACTIVITY_LINE_ID,
            SEQUENCE_NUMBER,
            NUMBER_OF_OCCURENCES,
            START_DATE,
            END_DATE,
            FREQUENCY,
            FREQUENCY_UOM,
            OFFSET_DURATION,
            OFFSET_UOM,
            AUTOSCHEDULE_YN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            OBJECT_VERSION_NUMBER,
            REQUEST_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- R12 Data Model Changes 4485150 Start
            ORIG_SYSTEM_ID1	,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Oks_Pm_Stream_Levels
     WHERE oks_pm_stream_levels.id = p_id;
    l_oks_pm_stream_levels_pk      oks_pm_stream_levels_pk_csr%ROWTYPE;
    l_pml_rec                      pml_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_pm_stream_levels_pk_csr (p_pml_rec.id);
    FETCH oks_pm_stream_levels_pk_csr INTO
              l_pml_rec.id,
              l_pml_rec.cle_id,
              l_pml_rec.dnz_chr_id,
              l_pml_rec.activity_line_id,
              l_pml_rec.sequence_number,
              l_pml_rec.number_of_occurences,
              l_pml_rec.start_date,
              l_pml_rec.end_date,
              l_pml_rec.frequency,
              l_pml_rec.frequency_uom,
              l_pml_rec.offset_duration,
              l_pml_rec.offset_uom,
              l_pml_rec.autoschedule_yn,
              l_pml_rec.program_application_id,
              l_pml_rec.program_id,
              l_pml_rec.program_update_date,
              l_pml_rec.object_version_number,
              l_pml_rec.request_id,
              l_pml_rec.created_by,
              l_pml_rec.creation_date,
              l_pml_rec.last_updated_by,
              l_pml_rec.last_update_date,
              l_pml_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
              l_pml_rec.orig_system_id1,
              l_pml_rec.orig_system_reference1,
              l_pml_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
;
    x_no_data_found := oks_pm_stream_levels_pk_csr%NOTFOUND;
    CLOSE oks_pm_stream_levels_pk_csr;
    RETURN(l_pml_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pml_rec                      IN pml_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pml_rec_type IS
    l_pml_rec                      pml_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_pml_rec := get_rec(p_pml_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pml_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pml_rec                      IN pml_rec_type
  ) RETURN pml_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pml_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_PM_STREAM_LEVELS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pmlv_rec   IN pmlv_rec_type
  ) RETURN pmlv_rec_type IS
    l_pmlv_rec                     pmlv_rec_type := p_pmlv_rec;
  BEGIN
    IF (l_pmlv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.id := NULL;
    END IF;
    IF (l_pmlv_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.cle_id := NULL;
    END IF;
    IF (l_pmlv_rec.dnz_chr_id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_pmlv_rec.activity_line_id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.activity_line_id := NULL;
    END IF;
    IF (l_pmlv_rec.sequence_number = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.sequence_number := NULL;
    END IF;
    IF (l_pmlv_rec.number_of_occurences = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.number_of_occurences := NULL;
    END IF;
    IF (l_pmlv_rec.start_date = OKC_API.G_MISS_DATE ) THEN
      l_pmlv_rec.start_date := NULL;
    END IF;
    IF (l_pmlv_rec.end_date = OKC_API.G_MISS_DATE ) THEN
      l_pmlv_rec.end_date := NULL;
    END IF;
    IF (l_pmlv_rec.frequency = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.frequency := NULL;
    END IF;
    IF (l_pmlv_rec.frequency_uom = OKC_API.G_MISS_CHAR ) THEN
      l_pmlv_rec.frequency_uom := NULL;
    END IF;
    IF (l_pmlv_rec.offset_duration = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.offset_duration := NULL;
    END IF;
    IF (l_pmlv_rec.offset_uom = OKC_API.G_MISS_CHAR ) THEN
      l_pmlv_rec.offset_uom := NULL;
    END IF;
    IF (l_pmlv_rec.autoschedule_yn = OKC_API.G_MISS_CHAR ) THEN
      l_pmlv_rec.autoschedule_yn := NULL;
    END IF;
    IF (l_pmlv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.program_application_id := NULL;
    END IF;
    IF (l_pmlv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.program_id := NULL;
    END IF;
    IF (l_pmlv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_pmlv_rec.program_update_date := NULL;
    END IF;
    IF (l_pmlv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.object_version_number := NULL;
    END IF;
    IF (l_pmlv_rec.security_group_id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.security_group_id := NULL;
    END IF;
    IF (l_pmlv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.request_id := NULL;
    END IF;
    IF (l_pmlv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.created_by := NULL;
    END IF;
    IF (l_pmlv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_pmlv_rec.creation_date := NULL;
    END IF;
    IF (l_pmlv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pmlv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_pmlv_rec.last_update_date := NULL;
    END IF;
    IF (l_pmlv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.last_update_login := NULL;
    END IF;
-- R12 Data Model Changes 4485150 Start
    IF (l_pmlv_rec.orig_system_id1 = OKC_API.G_MISS_NUM ) THEN
      l_pmlv_rec.orig_system_id1 := NULL;
    END IF;
    IF (l_pmlv_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR ) THEN
      l_pmlv_rec.orig_system_reference1 := NULL;
    END IF;
    IF (l_pmlv_rec.orig_system_source_code = OKC_API.G_MISS_CHAR ) THEN
      l_pmlv_rec.orig_system_source_code := NULL;
    END IF;
-- R12 Data Model Changes 4485150 End
    RETURN(l_pmlv_rec);
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
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKS_PM_STREAM_LEVELS_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pmlv_rec                     IN pmlv_rec_type
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
    validate_id(x_return_status, p_pmlv_rec.id);
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
  ------------------------------------------------
  -- Validate Record for:OKS_PM_STREAM_LEVELS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_pmlv_rec IN pmlv_rec_type,
    p_db_pmlv_rec IN pmlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_pmlv_rec IN pmlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_pmlv_rec                  pmlv_rec_type := get_rec(p_pmlv_rec);
  BEGIN
    l_return_status := Validate_Record(p_pmlv_rec => p_pmlv_rec,
                                       p_db_pmlv_rec => l_db_pmlv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN pmlv_rec_type,
    p_to   IN OUT NOCOPY pml_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.activity_line_id := p_from.activity_line_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.number_of_occurences := p_from.number_of_occurences;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.frequency := p_from.frequency;
    p_to.frequency_uom := p_from.frequency_uom;
    p_to.offset_duration := p_from.offset_duration;
    p_to.offset_uom := p_from.offset_uom;
    p_to.autoschedule_yn := p_from.autoschedule_yn;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- R12 Data Model Changes 4485150 Start
    p_to.orig_system_id1 := p_from.orig_system_id1;
    p_to.orig_system_reference1 := p_from.orig_system_reference1;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
-- R12 Data Model Changes 4485150 End
  END migrate;
  PROCEDURE migrate (
    p_from IN pml_rec_type,
    p_to   IN OUT NOCOPY pmlv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.activity_line_id := p_from.activity_line_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.number_of_occurences := p_from.number_of_occurences;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.frequency := p_from.frequency;
    p_to.frequency_uom := p_from.frequency_uom;
    p_to.offset_duration := p_from.offset_duration;
    p_to.offset_uom := p_from.offset_uom;
    p_to.autoschedule_yn := p_from.autoschedule_yn;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.request_id := p_from.request_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
-- R12 Data Model Changes 4485150 Start
    p_to.orig_system_id1 := p_from.orig_system_id1;
    p_to.orig_system_reference1 := p_from.orig_system_reference1;
    p_to.orig_system_source_code := p_from.orig_system_source_code;
-- R12 Data Model Changes 4485150 End
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKS_PM_STREAM_LEVELS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmlv_rec                     pmlv_rec_type := p_pmlv_rec;
    l_pml_rec                      pml_rec_type;
    l_pml_rec                      pml_rec_type;
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
    l_return_status := Validate_Attributes(l_pmlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pmlv_rec);
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
  --------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_PM_STREAM_LEVELS_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      i := p_pmlv_tbl.FIRST;
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
            p_pmlv_rec                     => p_pmlv_tbl(i));
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
        EXIT WHEN (i = p_pmlv_tbl.LAST);
        i := p_pmlv_tbl.NEXT(i);
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

  --------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_PM_STREAM_LEVELS_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pmlv_tbl                     => p_pmlv_tbl,
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
  -----------------------------------------
  -- insert_row for:OKS_PM_STREAM_LEVELS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pml_rec                      IN pml_rec_type,
    x_pml_rec                      OUT NOCOPY pml_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pml_rec                      pml_rec_type := p_pml_rec;
    l_def_pml_rec                  pml_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKS_PM_STREAM_LEVELS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_pml_rec IN pml_rec_type,
      x_pml_rec OUT NOCOPY pml_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pml_rec := p_pml_rec;
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
      p_pml_rec,                         -- IN
      l_pml_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_PM_STREAM_LEVELS(
      id,
      cle_id,
      dnz_chr_id,
      activity_line_id,
      sequence_number,
      number_of_occurences,
      start_date,
      end_date,
      frequency,
      frequency_uom,
      offset_duration,
      offset_uom,
      autoschedule_yn,
      program_application_id,
      program_id,
      program_update_date,
      object_version_number,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
-- R12 Data Model Changes 4485150 Start
      orig_system_id1,
      orig_system_reference1,
      orig_system_source_code
-- R12 Data Model Changes 4485150 End
)
    VALUES (
      l_pml_rec.id,
      l_pml_rec.cle_id,
      l_pml_rec.dnz_chr_id,
      l_pml_rec.activity_line_id,
      l_pml_rec.sequence_number,
      l_pml_rec.number_of_occurences,
      l_pml_rec.start_date,
      l_pml_rec.end_date,
      l_pml_rec.frequency,
      l_pml_rec.frequency_uom,
      l_pml_rec.offset_duration,
      l_pml_rec.offset_uom,
      l_pml_rec.autoschedule_yn,
      l_pml_rec.program_application_id,
      l_pml_rec.program_id,
      l_pml_rec.program_update_date,
      l_pml_rec.object_version_number,
      l_pml_rec.request_id,
      l_pml_rec.created_by,
      l_pml_rec.creation_date,
      l_pml_rec.last_updated_by,
      l_pml_rec.last_update_date,
      l_pml_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
      l_pml_rec.orig_system_id1,
      l_pml_rec.orig_system_reference1,
      l_pml_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
);
    -- Set OUT values
    x_pml_rec := l_pml_rec;
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
  --------------------------------------------
  -- insert_row for :OKS_PM_STREAM_LEVELS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type,
    x_pmlv_rec                     OUT NOCOPY pmlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmlv_rec                     pmlv_rec_type := p_pmlv_rec;
    l_def_pmlv_rec                 pmlv_rec_type;
    l_pml_rec                      pml_rec_type;
    lx_pml_rec                     pml_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pmlv_rec IN pmlv_rec_type
    ) RETURN pmlv_rec_type IS
      l_pmlv_rec pmlv_rec_type := p_pmlv_rec;
    BEGIN
      l_pmlv_rec.CREATION_DATE := SYSDATE;
      l_pmlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pmlv_rec.LAST_UPDATE_DATE := l_pmlv_rec.CREATION_DATE;
      l_pmlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pmlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pmlv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKS_PM_STREAM_LEVELS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_pmlv_rec IN pmlv_rec_type,
      x_pmlv_rec OUT NOCOPY pmlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmlv_rec := p_pmlv_rec;
      x_pmlv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_pmlv_rec := null_out_defaults(p_pmlv_rec);
    -- Set primary key value
    l_pmlv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_pmlv_rec,                        -- IN
      l_def_pmlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pmlv_rec := fill_who_columns(l_def_pmlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pmlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pmlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pmlv_rec, l_pml_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pml_rec,
      lx_pml_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pml_rec, l_def_pmlv_rec);
    -- Set OUT values
    x_pmlv_rec := l_def_pmlv_rec;
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
  -- PL/SQL TBL insert_row for:PMLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      i := p_pmlv_tbl.FIRST;
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
            p_pmlv_rec                     => p_pmlv_tbl(i),
            x_pmlv_rec                     => x_pmlv_tbl(i));
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
        EXIT WHEN (i = p_pmlv_tbl.LAST);
        i := p_pmlv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:PMLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY pmlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pmlv_tbl                     => p_pmlv_tbl,
        x_pmlv_tbl                     => x_pmlv_tbl,
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
  ---------------------------------------
  -- lock_row for:OKS_PM_STREAM_LEVELS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pml_rec                      IN pml_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pml_rec IN pml_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_PM_STREAM_LEVELS
     WHERE ID = p_pml_rec.id
       AND OBJECT_VERSION_NUMBER = p_pml_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_pml_rec IN pml_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_PM_STREAM_LEVELS
     WHERE ID = p_pml_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_PM_STREAM_LEVELS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_PM_STREAM_LEVELS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pml_rec);
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
      OPEN lchk_csr(p_pml_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pml_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pml_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for: OKS_PM_STREAM_LEVELS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pml_rec                      pml_rec_type;
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
    migrate(p_pmlv_rec, l_pml_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pml_rec
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
  -- PL/SQL TBL lock_row for:PMLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      i := p_pmlv_tbl.FIRST;
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
            p_pmlv_rec                     => p_pmlv_tbl(i));
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
        EXIT WHEN (i = p_pmlv_tbl.LAST);
        i := p_pmlv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:PMLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pmlv_tbl                     => p_pmlv_tbl,
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
  -----------------------------------------
  -- update_row for:OKS_PM_STREAM_LEVELS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pml_rec                      IN pml_rec_type,
    x_pml_rec                      OUT NOCOPY pml_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pml_rec                      pml_rec_type := p_pml_rec;
    l_def_pml_rec                  pml_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pml_rec IN pml_rec_type,
      x_pml_rec OUT NOCOPY pml_rec_type
    ) RETURN VARCHAR2 IS
      l_pml_rec                      pml_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pml_rec := p_pml_rec;
      -- Get current database values
      l_pml_rec := get_rec(p_pml_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_pml_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.id := l_pml_rec.id;
        END IF;
        IF (x_pml_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.cle_id := l_pml_rec.cle_id;
        END IF;
        IF (x_pml_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.dnz_chr_id := l_pml_rec.dnz_chr_id;
        END IF;
        IF (x_pml_rec.activity_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.activity_line_id := l_pml_rec.activity_line_id;
        END IF;
        IF (x_pml_rec.sequence_number = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.sequence_number := l_pml_rec.sequence_number;
        END IF;
        IF (x_pml_rec.number_of_occurences = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.number_of_occurences := l_pml_rec.number_of_occurences;
        END IF;
        IF (x_pml_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_pml_rec.start_date := l_pml_rec.start_date;
        END IF;
        IF (x_pml_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_pml_rec.end_date := l_pml_rec.end_date;
        END IF;
        IF (x_pml_rec.frequency = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.frequency := l_pml_rec.frequency;
        END IF;
        IF (x_pml_rec.frequency_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_pml_rec.frequency_uom := l_pml_rec.frequency_uom;
        END IF;
        IF (x_pml_rec.offset_duration = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.offset_duration := l_pml_rec.offset_duration;
        END IF;
        IF (x_pml_rec.offset_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_pml_rec.offset_uom := l_pml_rec.offset_uom;
        END IF;
        IF (x_pml_rec.autoschedule_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_pml_rec.autoschedule_yn := l_pml_rec.autoschedule_yn;
        END IF;
        IF (x_pml_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.program_application_id := l_pml_rec.program_application_id;
        END IF;
        IF (x_pml_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.program_id := l_pml_rec.program_id;
        END IF;
        IF (x_pml_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_pml_rec.program_update_date := l_pml_rec.program_update_date;
        END IF;
        IF (x_pml_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.object_version_number := l_pml_rec.object_version_number;
        END IF;
        IF (x_pml_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.request_id := l_pml_rec.request_id;
        END IF;
        IF (x_pml_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.created_by := l_pml_rec.created_by;
        END IF;
        IF (x_pml_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_pml_rec.creation_date := l_pml_rec.creation_date;
        END IF;
        IF (x_pml_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.last_updated_by := l_pml_rec.last_updated_by;
        END IF;
        IF (x_pml_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_pml_rec.last_update_date := l_pml_rec.last_update_date;
        END IF;
        IF (x_pml_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.last_update_login := l_pml_rec.last_update_login;
        END IF;
-- R12 Data Model Changes 4485150 Start
        IF (x_pml_rec.orig_system_id1 = OKC_API.G_MISS_NUM)
        THEN
          x_pml_rec.orig_system_id1 := l_pml_rec.orig_system_id1;
        END IF;
        IF (x_pml_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
        THEN
          x_pml_rec.orig_system_reference1 := l_pml_rec.orig_system_reference1;
        END IF;
        IF (x_pml_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
        THEN
          x_pml_rec.orig_system_source_code := l_pml_rec.orig_system_source_code;
        END IF;
-- R12 Data Model Changes 4485150 End
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKS_PM_STREAM_LEVELS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_pml_rec IN pml_rec_type,
      x_pml_rec OUT NOCOPY pml_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pml_rec := p_pml_rec;
      x_pml_rec.OBJECT_VERSION_NUMBER := p_pml_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_pml_rec,                         -- IN
      l_pml_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pml_rec, l_def_pml_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_PM_STREAM_LEVELS
    SET CLE_ID = l_def_pml_rec.cle_id,
        DNZ_CHR_ID = l_def_pml_rec.dnz_chr_id,
        ACTIVITY_LINE_ID = l_def_pml_rec.activity_line_id,
        SEQUENCE_NUMBER = l_def_pml_rec.sequence_number,
        NUMBER_OF_OCCURENCES = l_def_pml_rec.number_of_occurences,
        START_DATE = l_def_pml_rec.start_date,
        END_DATE = l_def_pml_rec.end_date,
        FREQUENCY = l_def_pml_rec.frequency,
        FREQUENCY_UOM = l_def_pml_rec.frequency_uom,
        OFFSET_DURATION = l_def_pml_rec.offset_duration,
        OFFSET_UOM = l_def_pml_rec.offset_uom,
        AUTOSCHEDULE_YN = l_def_pml_rec.autoschedule_yn,
        PROGRAM_APPLICATION_ID = l_def_pml_rec.program_application_id,
        PROGRAM_ID = l_def_pml_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_pml_rec.program_update_date,
        OBJECT_VERSION_NUMBER = l_def_pml_rec.object_version_number,
        REQUEST_ID = l_def_pml_rec.request_id,
        CREATED_BY = l_def_pml_rec.created_by,
        CREATION_DATE = l_def_pml_rec.creation_date,
        LAST_UPDATED_BY = l_def_pml_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pml_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pml_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
        ORIG_SYSTEM_ID1	 = l_def_pml_rec.orig_system_id1,
        ORIG_SYSTEM_REFERENCE1	= l_def_pml_rec.orig_system_reference1,
        ORIG_SYSTEM_SOURCE_CODE	= l_def_pml_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
    WHERE ID = l_def_pml_rec.id;

    x_pml_rec := l_pml_rec;
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
  -------------------------------------------
  -- update_row for:OKS_PM_STREAM_LEVELS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type,
    x_pmlv_rec                     OUT NOCOPY pmlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmlv_rec                     pmlv_rec_type := p_pmlv_rec;
    l_def_pmlv_rec                 pmlv_rec_type;
    l_db_pmlv_rec                  pmlv_rec_type;
    l_pml_rec                      pml_rec_type;
    lx_pml_rec                     pml_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pmlv_rec IN pmlv_rec_type
    ) RETURN pmlv_rec_type IS
      l_pmlv_rec pmlv_rec_type := p_pmlv_rec;
    BEGIN
      l_pmlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pmlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pmlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pmlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pmlv_rec IN pmlv_rec_type,
      x_pmlv_rec OUT NOCOPY pmlv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmlv_rec := p_pmlv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_pmlv_rec := get_rec(p_pmlv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_pmlv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.id := l_db_pmlv_rec.id;
        END IF;
        IF (x_pmlv_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.cle_id := l_db_pmlv_rec.cle_id;
        END IF;
        IF (x_pmlv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.dnz_chr_id := l_db_pmlv_rec.dnz_chr_id;
        END IF;
        IF (x_pmlv_rec.activity_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.activity_line_id := l_db_pmlv_rec.activity_line_id;
        END IF;
        IF (x_pmlv_rec.sequence_number = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.sequence_number := l_db_pmlv_rec.sequence_number;
        END IF;
        IF (x_pmlv_rec.number_of_occurences = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.number_of_occurences := l_db_pmlv_rec.number_of_occurences;
        END IF;
        IF (x_pmlv_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_pmlv_rec.start_date := l_db_pmlv_rec.start_date;
        END IF;
        IF (x_pmlv_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_pmlv_rec.end_date := l_db_pmlv_rec.end_date;
        END IF;
        IF (x_pmlv_rec.frequency = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.frequency := l_db_pmlv_rec.frequency;
        END IF;
        IF (x_pmlv_rec.frequency_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_pmlv_rec.frequency_uom := l_db_pmlv_rec.frequency_uom;
        END IF;
        IF (x_pmlv_rec.offset_duration = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.offset_duration := l_db_pmlv_rec.offset_duration;
        END IF;
        IF (x_pmlv_rec.offset_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_pmlv_rec.offset_uom := l_db_pmlv_rec.offset_uom;
        END IF;
        IF (x_pmlv_rec.autoschedule_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_pmlv_rec.autoschedule_yn := l_db_pmlv_rec.autoschedule_yn;
        END IF;
        IF (x_pmlv_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.program_application_id := l_db_pmlv_rec.program_application_id;
        END IF;
        IF (x_pmlv_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.program_id := l_db_pmlv_rec.program_id;
        END IF;
        IF (x_pmlv_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_pmlv_rec.program_update_date := l_db_pmlv_rec.program_update_date;
        END IF;
        IF (x_pmlv_rec.security_group_id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.security_group_id := l_db_pmlv_rec.security_group_id;
        END IF;
        IF (x_pmlv_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.request_id := l_db_pmlv_rec.request_id;
        END IF;
        IF (x_pmlv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.created_by := l_db_pmlv_rec.created_by;
        END IF;
        IF (x_pmlv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_pmlv_rec.creation_date := l_db_pmlv_rec.creation_date;
        END IF;
        IF (x_pmlv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.last_updated_by := l_db_pmlv_rec.last_updated_by;
        END IF;
        IF (x_pmlv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_pmlv_rec.last_update_date := l_db_pmlv_rec.last_update_date;
        END IF;
        IF (x_pmlv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.last_update_login := l_db_pmlv_rec.last_update_login;
        END IF;
-- R12 Data Model Changes 4485150 Start
        IF (x_pmlv_rec.orig_system_id1 = OKC_API.G_MISS_NUM)
        THEN
          x_pmlv_rec.orig_system_id1 := l_db_pmlv_rec.orig_system_id1;
        END IF;
        IF (x_pmlv_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
        THEN
          x_pmlv_rec.orig_system_reference1 := l_db_pmlv_rec.orig_system_reference1;
        END IF;
        IF (x_pmlv_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
        THEN
          x_pmlv_rec.orig_system_source_code := l_db_pmlv_rec.orig_system_source_code;
        END IF;
-- R12 Data Model Changes 4485150 End

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKS_PM_STREAM_LEVELS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_pmlv_rec IN pmlv_rec_type,
      x_pmlv_rec OUT NOCOPY pmlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pmlv_rec := p_pmlv_rec;
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
      p_pmlv_rec,                        -- IN
      x_pmlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pmlv_rec, l_def_pmlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pmlv_rec := fill_who_columns(l_def_pmlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pmlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pmlv_rec, l_db_pmlv_rec);
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
      p_pmlv_rec                     => p_pmlv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pmlv_rec, l_pml_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pml_rec,
      lx_pml_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pml_rec, l_def_pmlv_rec);
    x_pmlv_rec := l_def_pmlv_rec;
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
  -- PL/SQL TBL update_row for:pmlv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY  pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      i := p_pmlv_tbl.FIRST;
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
            p_pmlv_rec                     => p_pmlv_tbl(i),
            x_pmlv_rec                     => x_pmlv_tbl(i));
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
        EXIT WHEN (i = p_pmlv_tbl.LAST);
        i := p_pmlv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:PMLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    x_pmlv_tbl                     OUT NOCOPY pmlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pmlv_tbl                     => p_pmlv_tbl,
        x_pmlv_tbl                     => x_pmlv_tbl,
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
  -----------------------------------------
  -- delete_row for:OKS_PM_STREAM_LEVELS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pml_rec                      IN pml_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pml_rec                      pml_rec_type := p_pml_rec;
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

    DELETE FROM OKS_PM_STREAM_LEVELS
     WHERE ID = p_pml_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKS_PM_STREAM_LEVELS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_rec                     IN pmlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pmlv_rec                     pmlv_rec_type := p_pmlv_rec;
    l_pml_rec                      pml_rec_type;
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
    migrate(l_pmlv_rec, l_pml_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pml_rec
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
  ------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_PM_STREAM_LEVELS_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      i := p_pmlv_tbl.FIRST;
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
            p_pmlv_rec                     => p_pmlv_tbl(i));
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
        EXIT WHEN (i = p_pmlv_tbl.LAST);
        i := p_pmlv_tbl.NEXT(i);
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

  ------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_PM_STREAM_LEVELS_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pmlv_tbl                     IN pmlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pmlv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pmlv_tbl                     => p_pmlv_tbl,
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
                p_major_version  IN NUMBER) RETURN VARCHAR2 IS

			l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN


    INSERT INTO OKS_PM_STREAM_LEVELS_H(
      id,
      cle_id,
      dnz_chr_id,
      activity_line_id,
      sequence_number,
      number_of_occurences,
      start_date,
      end_date,
      frequency,
      frequency_uom,
      offset_duration,
      offset_uom,
      autoschedule_yn,
      program_application_id,
      program_id,
      program_update_date,
      object_version_number,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      MAJOR_VERSION
)
      SELECT
      id,
      cle_id,
      dnz_chr_id,
      activity_line_id,
      sequence_number,
      number_of_occurences,
      start_date,
      end_date,
      frequency,
      frequency_uom,
      offset_duration,
      offset_uom,
      autoschedule_yn,
      program_application_id,
      program_id,
      program_update_date,
      object_version_number,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
  	   p_major_version
  	  FROM OKS_PM_STREAM_LEVELS
  	  WHERE DNZ_CHR_ID = P_Id;

	RETURN l_return_status;


EXCEPTION


WHEN OTHERS THEN


      OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                          p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                          p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);

        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        return l_return_status;
END Create_Version;

FUNCTION Restore_Version(
                p_id         IN NUMBER,
                p_major_version  IN NUMBER) RETURN VARCHAR2 IS

    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

DELETE FROM OKS_PM_STREAM_LEVELS
WHERE DNZ_CHR_ID = p_id;

    INSERT INTO OKS_PM_STREAM_LEVELS(
      id,
      cle_id,
      dnz_chr_id,
      activity_line_id,
      sequence_number,
      number_of_occurences,
      start_date,
      end_date,
      frequency,
      frequency_uom,
      offset_duration,
      offset_uom,
      autoschedule_yn,
      program_application_id,
      program_id,
      program_update_date,
      object_version_number,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
)
      SELECT
      id,
      cle_id,
      dnz_chr_id,
      activity_line_id,
      sequence_number,
      number_of_occurences,
      start_date,
      end_date,
      frequency,
      frequency_uom,
      offset_duration,
      offset_uom,
      autoschedule_yn,
      program_application_id,
      program_id,
      program_update_date,
      object_version_number,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login
  	  FROM OKS_PM_STREAM_LEVELS_H
  	  WHERE DNZ_CHR_ID = P_Id
      AND major_version=p_major_version;

				RETURN l_return_status;


EXCEPTION

	WHEN OTHERS THEN

	OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
						p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
						p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
						p_token1_value => sqlcode,
						p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
						p_token2_value => sqlerrm);

        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    return l_return_status;

END Restore_Version;

END OKS_PML_PVT;

/
