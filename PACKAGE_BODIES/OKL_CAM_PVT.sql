--------------------------------------------------------
--  DDL for Package Body OKL_CAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CAM_PVT" AS
/* $Header: OKLSCAMB.pls 120.2 2006/07/11 10:11:53 dkagrawa noship $ */
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
  -- FUNCTION get_rec for: OKL_CURE_AMOUNTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_camv_rec                     IN camv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN camv_rec_type IS
    CURSOR OKL_cure_amounts_pk_csr (p_cure_amount_id IN NUMBER) IS
    SELECT
            CURE_AMOUNT_ID,
            CHR_ID,
            CURE_TYPE,
            CURE_AMOUNT,
            REPURCHASE_AMOUNT,
            EFFECTIVE_DATE,
            TIMES_CURED,
            PAYMENTS_REMAINING,
            ELIGIBLE_CURE_AMOUNT,
            OUTSTANDING_AMOUNT,
            PAST_DUE_AMOUNT,
            CURES_IN_POSSESSION,
            STATUS,
            OBJECT_VERSION_NUMBER,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            NEGOTIATED_AMOUNT,
            RECEIVED_AMOUNT,
            DELINQUENT_AMOUNT,
            SHORT_FUND_AMOUNT,
            CRT_ID,
            SHOW_ON_REQUEST,
            SELECTED_ON_REQUEST,
            QTE_ID,
            PROCESS
      FROM OKL_CURE_AMOUNTS
     WHERE OKL_CURE_AMOUNTS.cure_amount_id = p_cure_amount_id;
    l_OKL_cure_amounts_pk          OKL_cure_amounts_pk_csr%ROWTYPE;
    l_camv_rec                     camv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKL_cure_amounts_pk_csr (p_camv_rec.cure_amount_id);
    FETCH OKL_cure_amounts_pk_csr INTO
              l_camv_rec.cure_amount_id,
              l_camv_rec.chr_id,
              l_camv_rec.cure_type,
              l_camv_rec.cure_amount,
              l_camv_rec.repurchase_amount,
              l_camv_rec.effective_date,
              l_camv_rec.times_cured,
              l_camv_rec.payments_remaining,
              l_camv_rec.eligible_cure_amount,
              l_camv_rec.outstanding_amount,
              l_camv_rec.past_due_amount,
              l_camv_rec.cures_in_possession,
              l_camv_rec.status,
              l_camv_rec.object_version_number,
              l_camv_rec.org_id,
              l_camv_rec.request_id,
              l_camv_rec.program_application_id,
              l_camv_rec.program_id,
              l_camv_rec.program_update_date,
              l_camv_rec.attribute_category,
              l_camv_rec.attribute1,
              l_camv_rec.attribute2,
              l_camv_rec.attribute3,
              l_camv_rec.attribute4,
              l_camv_rec.attribute5,
              l_camv_rec.attribute6,
              l_camv_rec.attribute7,
              l_camv_rec.attribute8,
              l_camv_rec.attribute9,
              l_camv_rec.attribute10,
              l_camv_rec.attribute11,
              l_camv_rec.attribute12,
              l_camv_rec.attribute13,
              l_camv_rec.attribute14,
              l_camv_rec.attribute15,
              l_camv_rec.created_by,
              l_camv_rec.creation_date,
              l_camv_rec.last_updated_by,
              l_camv_rec.last_update_date,
              l_camv_rec.last_update_login,
              l_camv_rec.NEGOTIATED_AMOUNT,
              l_camv_rec.RECEIVED_AMOUNT,
              l_camv_rec.DELINQUENT_AMOUNT,
              l_camv_rec.SHORT_FUND_AMOUNT,
              l_camv_rec.CRT_ID,
              l_camv_rec.SHOW_ON_REQUEST,
              l_camv_rec.SELECTED_ON_REQUEST,
              l_camv_rec.QTE_ID,
              l_camv_rec.PROCESS;

    x_no_data_found := OKL_cure_amounts_pk_csr%NOTFOUND;
    CLOSE OKL_cure_amounts_pk_csr;
    RETURN(l_camv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_camv_rec                     IN camv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN camv_rec_type IS
    l_camv_rec                     camv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_camv_rec := get_rec(p_camv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CURE_AMOUNT_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_camv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_camv_rec                     IN camv_rec_type
  ) RETURN camv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_camv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CURE_AMOUNTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cam_rec                      IN cam_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cam_rec_type IS
    CURSOR OKL_cure_amount_pk_csr (p_cure_amount_id IN NUMBER) IS
    SELECT
            CURE_AMOUNT_ID,
            CHR_ID,
            CURE_TYPE,
            CURE_AMOUNT,
            REPURCHASE_AMOUNT,
            EFFECTIVE_DATE,
            TIMES_CURED,
            PAYMENTS_REMAINING,
            ELIGIBLE_CURE_AMOUNT,
            OUTSTANDING_AMOUNT,
            PAST_DUE_AMOUNT,
            CURES_IN_POSSESSION,
            STATUS,
            OBJECT_VERSION_NUMBER,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            NEGOTIATED_AMOUNT,
            RECEIVED_AMOUNT,
            DELINQUENT_AMOUNT,
            SHORT_FUND_AMOUNT,
            CRT_ID,
            SHOW_ON_REQUEST,
            SELECTED_ON_REQUEST,
            QTE_ID,
            PROCESS
      FROM OKL_Cure_Amounts
     WHERE OKL_cure_amounts.cure_amount_id = p_cure_amount_id;
    l_OKL_cure_amount_pk           OKL_cure_amount_pk_csr%ROWTYPE;
    l_cam_rec                      cam_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN OKL_cure_amount_pk_csr (p_cam_rec.cure_amount_id);
    FETCH OKL_cure_amount_pk_csr INTO
              l_cam_rec.cure_amount_id,
              l_cam_rec.chr_id,
              l_cam_rec.cure_type,
              l_cam_rec.cure_amount,
              l_cam_rec.repurchase_amount,
              l_cam_rec.effective_date,
              l_cam_rec.times_cured,
              l_cam_rec.payments_remaining,
              l_cam_rec.eligible_cure_amount,
              l_cam_rec.outstanding_amount,
              l_cam_rec.past_due_amount,
              l_cam_rec.cures_in_possession,
              l_cam_rec.status,
              l_cam_rec.object_version_number,
              l_cam_rec.org_id,
              l_cam_rec.request_id,
              l_cam_rec.program_application_id,
              l_cam_rec.program_id,
              l_cam_rec.program_update_date,
              l_cam_rec.attribute_category,
              l_cam_rec.attribute1,
              l_cam_rec.attribute2,
              l_cam_rec.attribute3,
              l_cam_rec.attribute4,
              l_cam_rec.attribute5,
              l_cam_rec.attribute6,
              l_cam_rec.attribute7,
              l_cam_rec.attribute8,
              l_cam_rec.attribute9,
              l_cam_rec.attribute10,
              l_cam_rec.attribute11,
              l_cam_rec.attribute12,
              l_cam_rec.attribute13,
              l_cam_rec.attribute14,
              l_cam_rec.attribute15,
              l_cam_rec.created_by,
              l_cam_rec.creation_date,
              l_cam_rec.last_updated_by,
              l_cam_rec.last_update_date,
              l_cam_rec.last_update_login,
              l_cam_rec.NEGOTIATED_AMOUNT,
              l_cam_rec.RECEIVED_AMOUNT,
              l_cam_rec.DELINQUENT_AMOUNT,
              l_cam_rec.SHORT_FUND_AMOUNT,
              l_cam_rec.CRT_ID,
              l_cam_rec.SHOW_ON_REQUEST,
              l_cam_rec.SELECTED_ON_REQUEST,
              l_cam_rec.QTE_ID,
              l_cam_rec.PROCESS;
    x_no_data_found := OKL_cure_amount_pk_csr%NOTFOUND;
    CLOSE OKL_cure_amount_pk_csr;
    RETURN(l_cam_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cam_rec                      IN cam_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cam_rec_type IS
    l_cam_rec                      cam_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_cam_rec := get_rec(p_cam_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CURE_AMOUNT_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cam_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cam_rec                      IN cam_rec_type
  ) RETURN cam_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cam_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CURE_AMOUNTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_camv_rec   IN camv_rec_type
  ) RETURN camv_rec_type IS
    l_camv_rec                     camv_rec_type := p_camv_rec;
  BEGIN
    IF (l_camv_rec.cure_amount_id = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.cure_amount_id := NULL;
    END IF;
    IF (l_camv_rec.chr_id = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.chr_id := NULL;
    END IF;
    IF (l_camv_rec.cure_type = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.cure_type := NULL;
    END IF;
    IF (l_camv_rec.cure_amount = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.cure_amount := NULL;
    END IF;
    IF (l_camv_rec.repurchase_amount = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.repurchase_amount := NULL;
    END IF;
    IF (l_camv_rec.effective_date = OKL_API.G_MISS_DATE ) THEN
      l_camv_rec.effective_date := NULL;
    END IF;
    IF (l_camv_rec.times_cured = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.times_cured := NULL;
    END IF;
    IF (l_camv_rec.payments_remaining = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.payments_remaining := NULL;
    END IF;
    IF (l_camv_rec.eligible_cure_amount = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.eligible_cure_amount := NULL;
    END IF;
    IF (l_camv_rec.outstanding_amount = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.outstanding_amount := NULL;
    END IF;
    IF (l_camv_rec.past_due_amount = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.past_due_amount := NULL;
    END IF;
    IF (l_camv_rec.cures_in_possession = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.cures_in_possession := NULL;
    END IF;
    IF (l_camv_rec.status = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.status := NULL;
    END IF;
    IF (l_camv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.object_version_number := NULL;
    END IF;
    IF (l_camv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.org_id := NULL;
    END IF;
    IF (l_camv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.request_id := NULL;
    END IF;
    IF (l_camv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.program_application_id := NULL;
    END IF;
    IF (l_camv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.program_id := NULL;
    END IF;
    IF (l_camv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_camv_rec.program_update_date := NULL;
    END IF;
    IF (l_camv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute_category := NULL;
    END IF;
    IF (l_camv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute1 := NULL;
    END IF;
    IF (l_camv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute2 := NULL;
    END IF;
    IF (l_camv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute3 := NULL;
    END IF;
    IF (l_camv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute4 := NULL;
    END IF;
    IF (l_camv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute5 := NULL;
    END IF;
    IF (l_camv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute6 := NULL;
    END IF;
    IF (l_camv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute7 := NULL;
    END IF;
    IF (l_camv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute8 := NULL;
    END IF;
    IF (l_camv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute9 := NULL;
    END IF;
    IF (l_camv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute10 := NULL;
    END IF;
    IF (l_camv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute11 := NULL;
    END IF;
    IF (l_camv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute12 := NULL;
    END IF;
    IF (l_camv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute13 := NULL;
    END IF;
    IF (l_camv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute14 := NULL;
    END IF;
    IF (l_camv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.attribute15 := NULL;
    END IF;
    IF (l_camv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.created_by := NULL;
    END IF;
    IF (l_camv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_camv_rec.creation_date := NULL;
    END IF;
    IF (l_camv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.last_updated_by := NULL;
    END IF;
    IF (l_camv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_camv_rec.last_update_date := NULL;
    END IF;
    IF (l_camv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.last_update_login := NULL;
    END IF;
    IF (l_camv_rec.NEGOTIATED_AMOUNT = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.NEGOTIATED_AMOUNT := NULL;
    END IF;
    IF (l_camv_rec.RECEIVED_AMOUNT = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.RECEIVED_AMOUNT := NULL;
    END IF;
    IF (l_camv_rec.DELINQUENT_AMOUNT = OKL_API.G_MISS_NUM ) THEN
       l_camv_rec.DELINQUENT_AMOUNT := NULL;
    END IF;
    IF (l_camv_rec.SHORT_FUND_AMOUNT = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.SHORT_FUND_AMOUNT := NULL;
    END IF;
    IF (l_camv_rec.CRT_ID = OKL_API.G_MISS_NUM ) THEN
      l_camv_rec.CRT_ID := NULL;
    END IF;
    IF (l_camv_rec.SHOW_ON_REQUEST = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.SHOW_ON_REQUEST := NULL;
    END IF;
    IF (l_camv_rec.SELECTED_ON_REQUEST = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.SELECTED_ON_REQUEST := NULL;
    END IF;

    IF (l_camv_rec.QTE_ID = OKL_API.G_MISS_NUM ) THEN
       l_camv_rec.QTE_ID := NULL;
    END IF;

    IF (l_camv_rec.PROCESS = OKL_API.G_MISS_CHAR ) THEN
      l_camv_rec.PROCESS := NULL;
    END IF;

    RETURN(l_camv_rec);
  END null_out_defaults;
  ---------------------------------------------
  -- Validate_Attributes for: CURE_AMOUNT_ID --
  ---------------------------------------------
  PROCEDURE validate_cure_amount_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_camv_rec               IN camv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_camv_rec.cure_amount_id = OKL_API.G_MISS_NUM OR
        p_camv_rec.cure_amount_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cure_amount_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_cure_amount_id;
  ---------------------------------------------
  -- Validate_Attributes for: CHR_ID --
  ---------------------------------------------
  PROCEDURE validate_chr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_camv_rec               IN camv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_camv_rec.chr_id = OKL_API.G_MISS_NUM OR
        p_camv_rec.chr_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'chr_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_chr_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_camv_rec               IN camv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_camv_rec.object_version_number = OKL_API.G_MISS_NUM OR
        p_camv_rec.object_version_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ---------------------------------------------
  -- Validate_Attributes for: EFFECTIVE_DATE --
  ---------------------------------------------
  PROCEDURE validate_effective_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_camv_rec               IN camv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_camv_rec.effective_date = OKL_API.G_MISS_DATE OR
        p_camv_rec.effective_date IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'effective_date');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_effective_date;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_CURE_AMOUNTS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_camv_rec                     IN camv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- cure_amount_id
    -- ***
    validate_cure_amount_id(l_return_status,p_camv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- chr_id
    -- ***
    validate_chr_id(l_return_status, p_camv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(l_return_status, p_camv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- effective_date
    -- ***
    validate_effective_date(l_return_status, p_camv_rec);
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
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
  --------------------------------------------
  -- Validate Record for:OKL_CURE_AMOUNTS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_camv_rec IN camv_rec_type,
    p_db_camv_rec IN camv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_camv_rec IN camv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_camv_rec                  camv_rec_type := get_rec(p_camv_rec);
  BEGIN
    l_return_status := Validate_Record(p_camv_rec => p_camv_rec,
                                       p_db_camv_rec => l_db_camv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN camv_rec_type,
    p_to   IN OUT NOCOPY cam_rec_type
  ) IS
  BEGIN
    p_to.cure_amount_id := p_from.cure_amount_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cure_type := p_from.cure_type;
    p_to.cure_amount := p_from.cure_amount;
    p_to.repurchase_amount := p_from.repurchase_amount;
    p_to.effective_date := p_from.effective_date;
    p_to.times_cured := p_from.times_cured;
    p_to.payments_remaining := p_from.payments_remaining;
    p_to.eligible_cure_amount := p_from.eligible_cure_amount;
    p_to.outstanding_amount := p_from.outstanding_amount;
    p_to.past_due_amount := p_from.past_due_amount;
    p_to.cures_in_possession := p_from.cures_in_possession;
    p_to.status := p_from.status;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.NEGOTIATED_AMOUNT := p_from.NEGOTIATED_AMOUNT;
    p_to.RECEIVED_AMOUNT := p_from.RECEIVED_AMOUNT;
    p_to.DELINQUENT_AMOUNT :=p_from.DELINQUENT_AMOUNT;
    p_to.SHORT_FUND_AMOUNT := p_from.SHORT_FUND_AMOUNT;
    p_to.CRT_ID := p_from.CRT_ID;
    p_to.SHOW_ON_REQUEST := p_from.SHOW_ON_REQUEST;
    p_to.SELECTED_ON_REQUEST := p_from.SELECTED_ON_REQUEST;
    p_to.QTE_ID :=p_from.QTE_ID;
    p_to.PROCESS :=p_from.PROCESS;
  END migrate;
  PROCEDURE migrate (
    p_from IN cam_rec_type,
    p_to   IN OUT NOCOPY camv_rec_type
  ) IS
  BEGIN
    p_to.cure_amount_id := p_from.cure_amount_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cure_type := p_from.cure_type;
    p_to.cure_amount := p_from.cure_amount;
    p_to.repurchase_amount := p_from.repurchase_amount;
    p_to.effective_date := p_from.effective_date;
    p_to.times_cured := p_from.times_cured;
    p_to.payments_remaining := p_from.payments_remaining;
    p_to.eligible_cure_amount := p_from.eligible_cure_amount;
    p_to.outstanding_amount := p_from.outstanding_amount;
    p_to.past_due_amount := p_from.past_due_amount;
    p_to.cures_in_possession := p_from.cures_in_possession;
    p_to.status := p_from.status;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.NEGOTIATED_AMOUNT := p_from.NEGOTIATED_AMOUNT;
    p_to.RECEIVED_AMOUNT := p_from.RECEIVED_AMOUNT;
    p_to.DELINQUENT_AMOUNT := p_from.DELINQUENT_AMOUNT;
    p_to.SHORT_FUND_AMOUNT := p_from.SHORT_FUND_AMOUNT;
    p_to.CRT_ID := p_from.CRT_ID;
    p_to.SHOW_ON_REQUEST := p_from.SHOW_ON_REQUEST;
    p_to.SELECTED_ON_REQUEST := p_from.SELECTED_ON_REQUEST;
    p_to.QTE_ID := p_from.QTE_ID;
    p_to.PROCESS := p_from.PROCESS;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_CURE_AMOUNTS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_camv_rec                     camv_rec_type := p_camv_rec;
    l_cam_rec                      cam_rec_type;
    l_cam_rec                      cam_rec_type;
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
    l_return_status := Validate_Attributes(l_camv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_camv_rec);
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
  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CURE_AMOUNTS_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      i := p_camv_tbl.FIRST;
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
            p_camv_rec                     => p_camv_tbl(i));
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
        EXIT WHEN (i = p_camv_tbl.LAST);
        i := p_camv_tbl.NEXT(i);
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

  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CURE_AMOUNTS_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_camv_tbl                     => p_camv_tbl,
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
  -------------------------------------
  -- insert_row for:OKL_CURE_AMOUNTS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cam_rec                      IN cam_rec_type,
    x_cam_rec                      OUT NOCOPY cam_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cam_rec                      cam_rec_type := p_cam_rec;
    l_def_cam_rec                  cam_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_CURE_AMOUNTS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cam_rec IN cam_rec_type,
      x_cam_rec OUT NOCOPY cam_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cam_rec := p_cam_rec;
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
      p_cam_rec,                         -- IN
      l_cam_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CURE_AMOUNTS(
      cure_amount_id,
      chr_id,
      cure_type,
      cure_amount,
      repurchase_amount,
      effective_date,
      times_cured,
      payments_remaining,
      eligible_cure_amount,
      outstanding_amount,
      past_due_amount,
      cures_in_possession,
      status,
      object_version_number,
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
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      NEGOTIATED_AMOUNT,
      RECEIVED_AMOUNT,
      DELINQUENT_AMOUNT,
      SHORT_FUND_AMOUNT,
      CRT_ID,
      SHOW_ON_REQUEST,
      SELECTED_ON_REQUEST,
      QTE_ID,
      PROCESS)
    VALUES (
      l_cam_rec.cure_amount_id,
      l_cam_rec.chr_id,
      l_cam_rec.cure_type,
      l_cam_rec.cure_amount,
      l_cam_rec.repurchase_amount,
      l_cam_rec.effective_date,
      l_cam_rec.times_cured,
      l_cam_rec.payments_remaining,
      l_cam_rec.eligible_cure_amount,
      l_cam_rec.outstanding_amount,
      l_cam_rec.past_due_amount,
      l_cam_rec.cures_in_possession,
      l_cam_rec.status,
      l_cam_rec.object_version_number,
      l_cam_rec.org_id,
      l_cam_rec.request_id,
      l_cam_rec.program_application_id,
      l_cam_rec.program_id,
      l_cam_rec.program_update_date,
      l_cam_rec.attribute_category,
      l_cam_rec.attribute1,
      l_cam_rec.attribute2,
      l_cam_rec.attribute3,
      l_cam_rec.attribute4,
      l_cam_rec.attribute5,
      l_cam_rec.attribute6,
      l_cam_rec.attribute7,
      l_cam_rec.attribute8,
      l_cam_rec.attribute9,
      l_cam_rec.attribute10,
      l_cam_rec.attribute11,
      l_cam_rec.attribute12,
      l_cam_rec.attribute13,
      l_cam_rec.attribute14,
      l_cam_rec.attribute15,
      l_cam_rec.created_by,
      l_cam_rec.creation_date,
      l_cam_rec.last_updated_by,
      l_cam_rec.last_update_date,
      l_cam_rec.last_update_login,
      l_cam_rec.NEGOTIATED_AMOUNT,
      l_cam_rec.RECEIVED_AMOUNT,
      l_cam_rec.DELINQUENT_AMOUNT,
      l_cam_rec.SHORT_FUND_AMOUNT,
      l_cam_rec.CRT_ID,
      l_cam_rec.SHOW_ON_REQUEST,
      l_cam_rec.SELECTED_ON_REQUEST,
      l_cam_rec.qte_id,
      l_cam_rec.process);
    -- Set OUT values
    x_cam_rec := l_cam_rec;
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
  -- insert_row for :OKL_CURE_AMOUNTS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type,
    x_camv_rec                     OUT NOCOPY camv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_camv_rec                     camv_rec_type := p_camv_rec;
    l_def_camv_rec                 camv_rec_type;
    l_cam_rec                      cam_rec_type;
    lx_cam_rec                     cam_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_camv_rec IN camv_rec_type
    ) RETURN camv_rec_type IS
      l_camv_rec camv_rec_type := p_camv_rec;
    BEGIN
      l_camv_rec.CREATION_DATE := SYSDATE;
      l_camv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_camv_rec.LAST_UPDATE_DATE := l_camv_rec.CREATION_DATE;
      l_camv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_camv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_camv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_CURE_AMOUNTS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_camv_rec IN camv_rec_type,
      x_camv_rec OUT NOCOPY camv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_camv_rec := p_camv_rec;
      x_camv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_camv_rec := null_out_defaults(p_camv_rec);
    -- Set primary key value
    l_camv_rec.CURE_AMOUNT_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_camv_rec,                        -- IN
      l_def_camv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_camv_rec := fill_who_columns(l_def_camv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_camv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_camv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_camv_rec, l_cam_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cam_rec,
      lx_cam_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cam_rec, l_def_camv_rec);
    -- Set OUT values
    x_camv_rec := l_def_camv_rec;
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
  -- PL/SQL TBL insert_row for:CAMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      i := p_camv_tbl.FIRST;
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
            p_camv_rec                     => p_camv_tbl(i),
            x_camv_rec                     => x_camv_tbl(i));
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
        EXIT WHEN (i = p_camv_tbl.LAST);
        i := p_camv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:CAMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_camv_tbl                     => p_camv_tbl,
        x_camv_tbl                     => x_camv_tbl,
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
  -----------------------------------
  -- lock_row for:OKL_CURE_AMOUNTS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cam_rec                      IN cam_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cam_rec IN cam_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CURE_AMOUNTS
     WHERE CURE_AMOUNT_ID = p_cam_rec.cure_amount_id
       AND OBJECT_VERSION_NUMBER = p_cam_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_cam_rec IN cam_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CURE_AMOUNTS
     WHERE CURE_AMOUNT_ID = p_cam_rec.cure_amount_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CURE_AMOUNTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CURE_AMOUNTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cam_rec);
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
      OPEN lchk_csr(p_cam_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cam_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cam_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for: OKL_CURE_AMOUNTS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cam_rec                      cam_rec_type;
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
    migrate(p_camv_rec, l_cam_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cam_rec
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
  -- PL/SQL TBL lock_row for:CAMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      i := p_camv_tbl.FIRST;
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
            p_camv_rec                     => p_camv_tbl(i));
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
        EXIT WHEN (i = p_camv_tbl.LAST);
        i := p_camv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:CAMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_camv_tbl                     => p_camv_tbl,
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
  -------------------------------------
  -- update_row for:OKL_CURE_AMOUNTS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cam_rec                      IN cam_rec_type,
    x_cam_rec                      OUT NOCOPY cam_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cam_rec                      cam_rec_type := p_cam_rec;
    l_def_cam_rec                  cam_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cam_rec IN cam_rec_type,
      x_cam_rec OUT NOCOPY cam_rec_type
    ) RETURN VARCHAR2 IS
      l_cam_rec                      cam_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cam_rec := p_cam_rec;
      -- Get current database values
      l_cam_rec := get_rec(p_cam_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_cam_rec.cure_amount_id = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.cure_amount_id := l_cam_rec.cure_amount_id;
        END IF;
        IF (x_cam_rec.chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.chr_id := l_cam_rec.chr_id;
        END IF;
        IF (x_cam_rec.cure_type = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.cure_type := l_cam_rec.cure_type;
        END IF;
        IF (x_cam_rec.cure_amount = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.cure_amount := l_cam_rec.cure_amount;
        END IF;
        IF (x_cam_rec.repurchase_amount = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.repurchase_amount := l_cam_rec.repurchase_amount;
        END IF;
        IF (x_cam_rec.effective_date = OKL_API.G_MISS_DATE)
        THEN
          x_cam_rec.effective_date := l_cam_rec.effective_date;
        END IF;
        IF (x_cam_rec.times_cured = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.times_cured := l_cam_rec.times_cured;
        END IF;
        IF (x_cam_rec.payments_remaining = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.payments_remaining := l_cam_rec.payments_remaining;
        END IF;
        IF (x_cam_rec.eligible_cure_amount = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.eligible_cure_amount := l_cam_rec.eligible_cure_amount;
        END IF;
        IF (x_cam_rec.outstanding_amount = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.outstanding_amount := l_cam_rec.outstanding_amount;
        END IF;
        IF (x_cam_rec.past_due_amount = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.past_due_amount := l_cam_rec.past_due_amount;
        END IF;
        IF (x_cam_rec.cures_in_possession = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.cures_in_possession := l_cam_rec.cures_in_possession;
        END IF;
        IF (x_cam_rec.status = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.status := l_cam_rec.status;
        END IF;
        IF (x_cam_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.object_version_number := l_cam_rec.object_version_number;
        END IF;
        IF (x_cam_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.org_id := l_cam_rec.org_id;
        END IF;
        IF (x_cam_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.request_id := l_cam_rec.request_id;
        END IF;
        IF (x_cam_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.program_application_id := l_cam_rec.program_application_id;
        END IF;
        IF (x_cam_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.program_id := l_cam_rec.program_id;
        END IF;
        IF (x_cam_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_cam_rec.program_update_date := l_cam_rec.program_update_date;
        END IF;
        IF (x_cam_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute_category := l_cam_rec.attribute_category;
        END IF;
        IF (x_cam_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute1 := l_cam_rec.attribute1;
        END IF;
        IF (x_cam_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute2 := l_cam_rec.attribute2;
        END IF;
        IF (x_cam_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute3 := l_cam_rec.attribute3;
        END IF;
        IF (x_cam_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute4 := l_cam_rec.attribute4;
        END IF;
        IF (x_cam_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute5 := l_cam_rec.attribute5;
        END IF;
        IF (x_cam_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute6 := l_cam_rec.attribute6;
        END IF;
        IF (x_cam_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute7 := l_cam_rec.attribute7;
        END IF;
        IF (x_cam_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute8 := l_cam_rec.attribute8;
        END IF;
        IF (x_cam_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute9 := l_cam_rec.attribute9;
        END IF;
        IF (x_cam_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute10 := l_cam_rec.attribute10;
        END IF;
        IF (x_cam_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute11 := l_cam_rec.attribute11;
        END IF;
        IF (x_cam_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute12 := l_cam_rec.attribute12;
        END IF;
        IF (x_cam_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute13 := l_cam_rec.attribute13;
        END IF;
        IF (x_cam_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute14 := l_cam_rec.attribute14;
        END IF;
        IF (x_cam_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.attribute15 := l_cam_rec.attribute15;
        END IF;
        IF (x_cam_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.created_by := l_cam_rec.created_by;
        END IF;
        IF (x_cam_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_cam_rec.creation_date := l_cam_rec.creation_date;
        END IF;
        IF (x_cam_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.last_updated_by := l_cam_rec.last_updated_by;
        END IF;
        IF (x_cam_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_cam_rec.last_update_date := l_cam_rec.last_update_date;
        END IF;
        IF (x_cam_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.last_update_login := l_cam_rec.last_update_login;
        END IF;
        IF (x_cam_rec.NEGOTIATED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.NEGOTIATED_AMOUNT := l_cam_rec.NEGOTIATED_AMOUNT;
        END IF;
        IF (x_cam_rec.RECEIVED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.RECEIVED_AMOUNT := l_cam_rec.RECEIVED_AMOUNT;
        END IF;
        IF (x_cam_rec.DELINQUENT_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.DELINQUENT_AMOUNT := l_cam_rec.DELINQUENT_AMOUNT;
        END IF;
        IF (x_cam_rec.SHORT_FUND_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.SHORT_FUND_AMOUNT := l_cam_rec.SHORT_FUND_AMOUNT;
        END IF;
        IF (x_cam_rec.CRT_ID = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.CRT_ID := l_cam_rec.CRT_ID;
        END IF;
        IF (x_cam_rec.SHOW_ON_REQUEST = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.SHOW_ON_REQUEST := l_cam_rec.SHOW_ON_REQUEST;
        END IF;
        IF (x_cam_rec.SELECTED_ON_REQUEST = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.SELECTED_ON_REQUEST := l_cam_rec.SELECTED_ON_REQUEST;
        END IF;

        IF (x_cam_rec.QTE_ID = OKL_API.G_MISS_NUM)
        THEN
          x_cam_rec.QTE_ID := l_cam_rec.QTE_ID;
        END IF;

        IF (x_cam_rec.PROCESS = OKL_API.G_MISS_CHAR)
        THEN
          x_cam_rec.PROCESS := l_cam_rec.PROCESS;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_CURE_AMOUNTS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_cam_rec IN cam_rec_type,
      x_cam_rec OUT NOCOPY cam_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cam_rec := p_cam_rec;
      x_cam_rec.OBJECT_VERSION_NUMBER := p_cam_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_cam_rec,                         -- IN
      l_cam_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cam_rec, l_def_cam_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CURE_AMOUNTS
    SET CHR_ID = l_def_cam_rec.chr_id,
        CURE_TYPE = l_def_cam_rec.cure_type,
        CURE_AMOUNT = l_def_cam_rec.cure_amount,
        REPURCHASE_AMOUNT = l_def_cam_rec.repurchase_amount,
        EFFECTIVE_DATE = l_def_cam_rec.effective_date,
        TIMES_CURED = l_def_cam_rec.times_cured,
        PAYMENTS_REMAINING = l_def_cam_rec.payments_remaining,
        ELIGIBLE_CURE_AMOUNT = l_def_cam_rec.eligible_cure_amount,
        OUTSTANDING_AMOUNT = l_def_cam_rec.outstanding_amount,
        PAST_DUE_AMOUNT = l_def_cam_rec.past_due_amount,
        CURES_IN_POSSESSION = l_def_cam_rec.cures_in_possession,
        STATUS = l_def_cam_rec.status,
        OBJECT_VERSION_NUMBER = l_def_cam_rec.object_version_number,
        ORG_ID = l_def_cam_rec.org_id,
        REQUEST_ID = l_def_cam_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_cam_rec.program_application_id,
        PROGRAM_ID = l_def_cam_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_cam_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_cam_rec.attribute_category,
        ATTRIBUTE1 = l_def_cam_rec.attribute1,
        ATTRIBUTE2 = l_def_cam_rec.attribute2,
        ATTRIBUTE3 = l_def_cam_rec.attribute3,
        ATTRIBUTE4 = l_def_cam_rec.attribute4,
        ATTRIBUTE5 = l_def_cam_rec.attribute5,
        ATTRIBUTE6 = l_def_cam_rec.attribute6,
        ATTRIBUTE7 = l_def_cam_rec.attribute7,
        ATTRIBUTE8 = l_def_cam_rec.attribute8,
        ATTRIBUTE9 = l_def_cam_rec.attribute9,
        ATTRIBUTE10 = l_def_cam_rec.attribute10,
        ATTRIBUTE11 = l_def_cam_rec.attribute11,
        ATTRIBUTE12 = l_def_cam_rec.attribute12,
        ATTRIBUTE13 = l_def_cam_rec.attribute13,
        ATTRIBUTE14 = l_def_cam_rec.attribute14,
        ATTRIBUTE15 = l_def_cam_rec.attribute15,
        CREATED_BY = l_def_cam_rec.created_by,
        CREATION_DATE = l_def_cam_rec.creation_date,
        LAST_UPDATED_BY = l_def_cam_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cam_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cam_rec.last_update_login,
        NEGOTIATED_AMOUNT = l_def_cam_rec.NEGOTIATED_AMOUNT,
        RECEIVED_AMOUNT = l_def_cam_rec.RECEIVED_AMOUNT,
        DELINQUENT_AMOUNT = l_def_cam_rec.DELINQUENT_AMOUNT,
        SHORT_FUND_AMOUNT = l_def_cam_rec.SHORT_FUND_AMOUNT,
        CRT_ID = l_def_cam_rec.CRT_ID,
        SHOW_ON_REQUEST = l_def_cam_rec.SHOW_ON_REQUEST,
        SELECTED_ON_REQUEST = l_def_cam_rec.SELECTED_ON_REQUEST,
        QTE_ID = l_def_cam_rec.QTE_ID,
        PROCESS = l_def_cam_rec.PROCESS
    WHERE CURE_AMOUNT_ID = l_def_cam_rec.cure_amount_id;

    x_cam_rec := l_cam_rec;
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
  -- update_row for:OKL_CURE_AMOUNTS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type,
    x_camv_rec                     OUT NOCOPY camv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_camv_rec                     camv_rec_type := p_camv_rec;
    l_def_camv_rec                 camv_rec_type;
    l_db_camv_rec                  camv_rec_type;
    l_cam_rec                      cam_rec_type;
    lx_cam_rec                     cam_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_camv_rec IN camv_rec_type
    ) RETURN camv_rec_type IS
      l_camv_rec camv_rec_type := p_camv_rec;
    BEGIN
      l_camv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_camv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_camv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_camv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_camv_rec IN camv_rec_type,
      x_camv_rec OUT NOCOPY camv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_camv_rec := p_camv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_camv_rec := get_rec(p_camv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_camv_rec.cure_amount_id = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.cure_amount_id := l_db_camv_rec.cure_amount_id;
        END IF;
        IF (x_camv_rec.chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.chr_id := l_db_camv_rec.chr_id;
        END IF;
        IF (x_camv_rec.cure_type = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.cure_type := l_db_camv_rec.cure_type;
        END IF;
        IF (x_camv_rec.cure_amount = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.cure_amount := l_db_camv_rec.cure_amount;
        END IF;
        IF (x_camv_rec.repurchase_amount = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.repurchase_amount := l_db_camv_rec.repurchase_amount;
        END IF;
        IF (x_camv_rec.effective_date = OKL_API.G_MISS_DATE)
        THEN
          x_camv_rec.effective_date := l_db_camv_rec.effective_date;
        END IF;
        IF (x_camv_rec.times_cured = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.times_cured := l_db_camv_rec.times_cured;
        END IF;
        IF (x_camv_rec.payments_remaining = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.payments_remaining := l_db_camv_rec.payments_remaining;
        END IF;
        IF (x_camv_rec.eligible_cure_amount = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.eligible_cure_amount := l_db_camv_rec.eligible_cure_amount;
        END IF;
        IF (x_camv_rec.outstanding_amount = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.outstanding_amount := l_db_camv_rec.outstanding_amount;
        END IF;
        IF (x_camv_rec.past_due_amount = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.past_due_amount := l_db_camv_rec.past_due_amount;
        END IF;
        IF (x_camv_rec.cures_in_possession = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.cures_in_possession := l_db_camv_rec.cures_in_possession;
        END IF;
        IF (x_camv_rec.status = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.status := l_db_camv_rec.status;
        END IF;
        IF (x_camv_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.org_id := l_db_camv_rec.org_id;
        END IF;
        IF (x_camv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.request_id := l_db_camv_rec.request_id;
        END IF;
        IF (x_camv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.program_application_id := l_db_camv_rec.program_application_id;
        END IF;
        IF (x_camv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.program_id := l_db_camv_rec.program_id;
        END IF;
        IF (x_camv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_camv_rec.program_update_date := l_db_camv_rec.program_update_date;
        END IF;
        IF (x_camv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute_category := l_db_camv_rec.attribute_category;
        END IF;
        IF (x_camv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute1 := l_db_camv_rec.attribute1;
        END IF;
        IF (x_camv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute2 := l_db_camv_rec.attribute2;
        END IF;
        IF (x_camv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute3 := l_db_camv_rec.attribute3;
        END IF;
        IF (x_camv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute4 := l_db_camv_rec.attribute4;
        END IF;
        IF (x_camv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute5 := l_db_camv_rec.attribute5;
        END IF;
        IF (x_camv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute6 := l_db_camv_rec.attribute6;
        END IF;
        IF (x_camv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute7 := l_db_camv_rec.attribute7;
        END IF;
        IF (x_camv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute8 := l_db_camv_rec.attribute8;
        END IF;
        IF (x_camv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute9 := l_db_camv_rec.attribute9;
        END IF;
        IF (x_camv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute10 := l_db_camv_rec.attribute10;
        END IF;
        IF (x_camv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute11 := l_db_camv_rec.attribute11;
        END IF;
        IF (x_camv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute12 := l_db_camv_rec.attribute12;
        END IF;
        IF (x_camv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute13 := l_db_camv_rec.attribute13;
        END IF;
        IF (x_camv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute14 := l_db_camv_rec.attribute14;
        END IF;
        IF (x_camv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.attribute15 := l_db_camv_rec.attribute15;
        END IF;
        IF (x_camv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.created_by := l_db_camv_rec.created_by;
        END IF;
        IF (x_camv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_camv_rec.creation_date := l_db_camv_rec.creation_date;
        END IF;
        IF (x_camv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.last_updated_by := l_db_camv_rec.last_updated_by;
        END IF;
        IF (x_camv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_camv_rec.last_update_date := l_db_camv_rec.last_update_date;
        END IF;
        IF (x_camv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.last_update_login := l_db_camv_rec.last_update_login;
        END IF;
        IF (x_camv_rec.NEGOTIATED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.NEGOTIATED_AMOUNT := l_db_camv_rec.NEGOTIATED_AMOUNT;
        END IF;
        IF (x_camv_rec.RECEIVED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.RECEIVED_AMOUNT := l_db_camv_rec.RECEIVED_AMOUNT;
        END IF;
        IF (x_camv_rec.DELINQUENT_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.DELINQUENT_AMOUNT := l_db_camv_rec.DELINQUENT_AMOUNT;
        END IF;

        IF (x_camv_rec.SHORT_FUND_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.SHORT_FUND_AMOUNT := l_db_camv_rec.SHORT_FUND_AMOUNT;
        END IF;
        IF (x_camv_rec.CRT_ID = OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.CRT_ID := l_db_camv_rec.CRT_ID;
        END IF;
        IF (x_camv_rec.SHOW_ON_REQUEST = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.SHOW_ON_REQUEST := l_db_camv_rec.SHOW_ON_REQUEST;
        END IF;
        IF (x_camv_rec.SELECTED_ON_REQUEST = OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.SELECTED_ON_REQUEST := l_db_camv_rec.SELECTED_ON_REQUEST;
        END IF;

        IF (x_camv_rec.QTE_ID= OKL_API.G_MISS_NUM)
        THEN
          x_camv_rec.QTE_ID:= l_db_camv_rec.QTE_ID;
        END IF;

        IF (x_camv_rec.PROCESS= OKL_API.G_MISS_CHAR)
        THEN
          x_camv_rec.PROCESS := l_db_camv_rec.PROCESS;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_CURE_AMOUNTS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_camv_rec IN camv_rec_type,
      x_camv_rec OUT NOCOPY camv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_camv_rec := p_camv_rec;
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
      p_camv_rec,                        -- IN
      x_camv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_camv_rec, l_def_camv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_camv_rec := fill_who_columns(l_def_camv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_camv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_camv_rec, l_db_camv_rec);
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
      p_camv_rec                     => p_camv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_camv_rec, l_cam_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cam_rec,
      lx_cam_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cam_rec, l_def_camv_rec);
    x_camv_rec := l_def_camv_rec;
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
  -- PL/SQL TBL update_row for:camv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      i := p_camv_tbl.FIRST;
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
            p_camv_rec                     => p_camv_tbl(i),
            x_camv_rec                     => x_camv_tbl(i));
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
        EXIT WHEN (i = p_camv_tbl.LAST);
        i := p_camv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:CAMV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    x_camv_tbl                     OUT NOCOPY camv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_camv_tbl                     => p_camv_tbl,
        x_camv_tbl                     => x_camv_tbl,
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
  -------------------------------------
  -- delete_row for:OKL_CURE_AMOUNTS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cam_rec                      IN cam_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_cam_rec                      cam_rec_type := p_cam_rec;
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

    DELETE FROM OKL_CURE_AMOUNTS
     WHERE CURE_AMOUNT_ID = p_cam_rec.cure_amount_id;

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
  ---------------------------------------
  -- delete_row for:OKL_CURE_AMOUNTS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_rec                     IN camv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_camv_rec                     camv_rec_type := p_camv_rec;
    l_cam_rec                      cam_rec_type;
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
    migrate(l_camv_rec, l_cam_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cam_rec
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
  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CURE_AMOUNTS_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      i := p_camv_tbl.FIRST;
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
            p_camv_rec                     => p_camv_tbl(i));
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
        EXIT WHEN (i = p_camv_tbl.LAST);
        i := p_camv_tbl.NEXT(i);
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

  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CURE_AMOUNTS_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_camv_tbl                     IN camv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_camv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_camv_tbl                     => p_camv_tbl,
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

END OKL_CAM_PVT;

/
