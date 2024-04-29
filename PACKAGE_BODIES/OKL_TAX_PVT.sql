--------------------------------------------------------
--  DDL for Package Body OKL_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAX_PVT" AS
/* $Header: OKLSTAXB.pls 120.4 2006/09/21 12:44:54 ssdeshpa noship $ */

-- Handcoded this
  G_TAX_LINE_TYPE            CONSTANT VARCHAR2(200)  := 'OKL_TAX_LINE_TYPE';
  G_NO_MATCHING_RECORD       CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
-- end Handcoding


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
  -- FUNCTION get_rec for: OKL_TAX_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OKL_TAX_LINES_rec_type IS
    CURSOR okl_taxv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            KLE_ID,
            ASSET_ID,
            ASSET_NUMBER,
            TAX_LINE_TYPE,
            SEL_ID,
            TAX_DUE_DATE,
            TAX_TYPE,
            TAX_RATE_CODE_ID,
            TAX_RATE_CODE,
            TAXABLE_AMOUNT,
            TAX_EXEMPTION_ID,
            MANUALLY_ENTERED_FLAG,
            OVERRIDDEN_FLAG,
            CALCULATED_TAX_AMOUNT,
            TAX_RATE,
            TAX_AMOUNT,
            SALES_TAX_ID,
            SOURCE_TRX_ID,
            ORG_ID,
            HISTORY_YN,
            ACTUAL_YN,
            SOURCE_NAME,
            TRQ_ID,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
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
            LAST_UPDATE_LOGIN
      FROM OKL_TAX_LINES
     WHERE OKL_TAX_LINES.id   = p_id;
    l_okl_taxv_pk                  okl_taxv_pk_csr%ROWTYPE;
    l_OKL_TAX_LINES_rec          OKL_TAX_LINES_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_taxv_pk_csr (p_OKL_TAX_LINES_rec.id);
    FETCH okl_taxv_pk_csr INTO
              l_OKL_TAX_LINES_rec.id,
              l_OKL_TAX_LINES_rec.khr_id,
              l_OKL_TAX_LINES_rec.kle_id,
              l_OKL_TAX_LINES_rec.asset_id,
              l_OKL_TAX_LINES_rec.asset_number,
              l_OKL_TAX_LINES_rec.tax_line_type,
              l_OKL_TAX_LINES_rec.sel_id,
              l_OKL_TAX_LINES_rec.tax_due_date,
              l_OKL_TAX_LINES_rec.tax_type,
              l_OKL_TAX_LINES_rec.tax_rate_code_id,
              l_OKL_TAX_LINES_rec.tax_rate_code,
              l_OKL_TAX_LINES_rec.taxable_amount,
              l_OKL_TAX_LINES_rec.tax_exemption_id,
              l_OKL_TAX_LINES_rec.manually_entered_flag,
              l_OKL_TAX_LINES_rec.overridden_flag,
              l_OKL_TAX_LINES_rec.calculated_tax_amount,
              l_OKL_TAX_LINES_rec.tax_rate,
              l_OKL_TAX_LINES_rec.tax_amount,
              l_OKL_TAX_LINES_rec.sales_tax_id,
              l_OKL_TAX_LINES_rec.source_trx_id,
              l_OKL_TAX_LINES_rec.org_id,
              l_OKL_TAX_LINES_rec.history_yn,
              l_OKL_TAX_LINES_rec.actual_yn,
              l_OKL_TAX_LINES_rec.source_name,
              l_OKL_TAX_LINES_rec.trq_id,
              l_OKL_TAX_LINES_rec.program_id,
              l_OKL_TAX_LINES_rec.request_id,
              l_OKL_TAX_LINES_rec.program_application_id,
              l_OKL_TAX_LINES_rec.program_update_date,
              l_OKL_TAX_LINES_rec.attribute_category,
              l_OKL_TAX_LINES_rec.attribute1,
              l_OKL_TAX_LINES_rec.attribute2,
              l_OKL_TAX_LINES_rec.attribute3,
              l_OKL_TAX_LINES_rec.attribute4,
              l_OKL_TAX_LINES_rec.attribute5,
              l_OKL_TAX_LINES_rec.attribute6,
              l_OKL_TAX_LINES_rec.attribute7,
              l_OKL_TAX_LINES_rec.attribute8,
              l_OKL_TAX_LINES_rec.attribute9,
              l_OKL_TAX_LINES_rec.attribute10,
              l_OKL_TAX_LINES_rec.attribute11,
              l_OKL_TAX_LINES_rec.attribute12,
              l_OKL_TAX_LINES_rec.attribute13,
              l_OKL_TAX_LINES_rec.attribute14,
              l_OKL_TAX_LINES_rec.attribute15,
              l_OKL_TAX_LINES_rec.created_by,
              l_OKL_TAX_LINES_rec.creation_date,
              l_OKL_TAX_LINES_rec.last_updated_by,
              l_OKL_TAX_LINES_rec.last_update_date,
              l_OKL_TAX_LINES_rec.last_update_login;
    x_no_data_found := okl_taxv_pk_csr%NOTFOUND;
    CLOSE okl_taxv_pk_csr;
    RETURN(l_OKL_TAX_LINES_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN OKL_TAX_LINES_rec_type IS
    l_OKL_TAX_LINES_rec          OKL_TAX_LINES_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_OKL_TAX_LINES_rec := get_rec(p_OKL_TAX_LINES_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_OKL_TAX_LINES_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type
  ) RETURN OKL_TAX_LINES_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_OKL_TAX_LINES_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TAX_LINES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tax_rec                      IN tax_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tax_rec_type IS
    CURSOR okl_tax_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            KHR_ID,
            KLE_ID,
            ASSET_ID,
            ASSET_NUMBER,
            TAX_LINE_TYPE,
            SEL_ID,
            TAX_DUE_DATE,
            TAX_TYPE,
            TAX_RATE_CODE_ID,
            TAX_RATE_CODE,
            TAXABLE_AMOUNT,
            TAX_EXEMPTION_ID,
            MANUALLY_ENTERED_FLAG,
            OVERRIDDEN_FLAG,
            CALCULATED_TAX_AMOUNT,
            TAX_RATE,
            TAX_AMOUNT,
            SALES_TAX_ID,
            SOURCE_TRX_ID,
            ORG_ID,
            HISTORY_YN,
            ACTUAL_YN,
            SOURCE_NAME,
            TRQ_ID,
            PROGRAM_ID,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Tax_Lines
     WHERE okl_tax_lines.id     = p_id;
    l_okl_tax_pk                   okl_tax_pk_csr%ROWTYPE;
    l_tax_rec                      tax_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tax_pk_csr (p_tax_rec.id);
    FETCH okl_tax_pk_csr INTO
              l_tax_rec.id,
              l_tax_rec.khr_id,
              l_tax_rec.kle_id,
              l_tax_rec.asset_id,
              l_tax_rec.asset_number,
              l_tax_rec.tax_line_type,
              l_tax_rec.sel_id,
              l_tax_rec.tax_due_date,
              l_tax_rec.tax_type,
              l_tax_rec.tax_rate_code_id,
              l_tax_rec.tax_rate_code,
              l_tax_rec.taxable_amount,
              l_tax_rec.tax_exemption_id,
              l_tax_rec.manually_entered_flag,
              l_tax_rec.overridden_flag,
              l_tax_rec.calculated_tax_amount,
              l_tax_rec.tax_rate,
              l_tax_rec.tax_amount,
              l_tax_rec.sales_tax_id,
              l_tax_rec.source_trx_id,
              l_tax_rec.org_id,
              l_tax_rec.history_yn,
              l_tax_rec.actual_yn,
              l_tax_rec.source_name,
              l_tax_rec.trq_id,
              l_tax_rec.program_id,
              l_tax_rec.request_id,
              l_tax_rec.program_application_id,
              l_tax_rec.program_update_date,
              l_tax_rec.attribute_category,
              l_tax_rec.attribute1,
              l_tax_rec.attribute2,
              l_tax_rec.attribute3,
              l_tax_rec.attribute4,
              l_tax_rec.attribute5,
              l_tax_rec.attribute6,
              l_tax_rec.attribute7,
              l_tax_rec.attribute8,
              l_tax_rec.attribute9,
              l_tax_rec.attribute10,
              l_tax_rec.attribute11,
              l_tax_rec.attribute12,
              l_tax_rec.attribute13,
              l_tax_rec.attribute14,
              l_tax_rec.attribute15,
              l_tax_rec.created_by,
              l_tax_rec.creation_date,
              l_tax_rec.last_updated_by,
              l_tax_rec.last_update_date,
              l_tax_rec.last_update_login;
    x_no_data_found := okl_tax_pk_csr%NOTFOUND;
    CLOSE okl_tax_pk_csr;
    RETURN(l_tax_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_tax_rec                      IN tax_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN tax_rec_type IS
    l_tax_rec                      tax_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_tax_rec := get_rec(p_tax_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_tax_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_tax_rec                      IN tax_rec_type
  ) RETURN tax_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tax_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TAX_LINES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_OKL_TAX_LINES_rec   IN OKL_TAX_LINES_rec_type
  ) RETURN OKL_TAX_LINES_rec_type IS
    l_OKL_TAX_LINES_rec          OKL_TAX_LINES_rec_type := p_OKL_TAX_LINES_rec;
  BEGIN
    IF (l_OKL_TAX_LINES_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.khr_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.kle_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.kle_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.asset_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.asset_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.asset_number = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.asset_number := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_line_type = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.tax_line_type := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.sel_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.sel_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_due_date = OKC_API.G_MISS_DATE ) THEN
      l_OKL_TAX_LINES_rec.tax_due_date := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_type = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.tax_type := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_rate_code_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.tax_rate_code_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_rate_code = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.tax_rate_code := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.taxable_amount = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.taxable_amount := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_exemption_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.tax_exemption_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.manually_entered_flag = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.manually_entered_flag := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.overridden_flag = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.overridden_flag := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.calculated_tax_amount = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.calculated_tax_amount := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_rate = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.tax_rate := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.tax_amount = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.tax_amount := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.sales_tax_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.sales_tax_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.source_trx_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.source_trx_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.org_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.history_yn = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.history_yn := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.actual_yn = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.actual_yn := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.source_name = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.source_name := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.trq_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.trq_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.program_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.request_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.program_application_id := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_OKL_TAX_LINES_rec.program_update_date := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute_category := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute1 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute2 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute3 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute4 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute5 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute6 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute7 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute8 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute9 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute10 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute11 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute12 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute13 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute14 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_OKL_TAX_LINES_rec.attribute15 := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.created_by := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_OKL_TAX_LINES_rec.creation_date := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.last_updated_by := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_OKL_TAX_LINES_rec.last_update_date := NULL;
    END IF;
    IF (l_OKL_TAX_LINES_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_OKL_TAX_LINES_rec.last_update_login := NULL;
    END IF;
    RETURN(l_OKL_TAX_LINES_rec);
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
  -------------------------------------
  -- Validate_Attributes for: KHR_ID --
  -------------------------------------
  PROCEDURE validate_khr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_khr_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_khr_id = OKC_API.G_MISS_NUM OR
        p_khr_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'khr_id');
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
  END validate_khr_id;
  --------------------------------------------
  -- Validate_Attributes for: TAX_LINE_TYPE --
  --------------------------------------------
  PROCEDURE validate_tax_line_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tax_line_type                IN VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tax_line_type = OKC_API.G_MISS_CHAR OR
        p_tax_line_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tax_line_type');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    --Hand coded this.
    -- Enforce Foreign Key
    l_return_status := OKL_UTIL.check_lookup_code(G_TAX_LINE_TYPE,
                                                  p_tax_line_type);
    IF l_return_status <> x_return_status THEN
       -- Notify Error
      OKL_API.set_message(G_APP_NAME, G_NO_MATCHING_RECORD, G_COL_NAME_TOKEN, 'tax_line_type');
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
  END validate_tax_line_type;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKL_TAX_LINES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type
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
    validate_id(x_return_status, p_OKL_TAX_LINES_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- khr_id
    -- ***
    validate_khr_id(x_return_status, p_OKL_TAX_LINES_rec.khr_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- tax_line_type
    -- ***
    validate_tax_line_type(x_return_status, p_OKL_TAX_LINES_rec.tax_line_type);
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
  -----------------------------------------
  -- Validate Record for:OKL_TAX_LINES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type,
    p_db_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type,
      p_db_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      --Fixed Bug#5484903
      CURSOR okl_taxv_fnd_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
        FROM Fnd_Lookups
       WHERE fnd_lookups.lookup_type='OKL_TAX_LINE_TYPE'
       AND fnd_lookups.lookup_code = p_lookup_code;
      l_okl_taxv_fnd_fk              okl_taxv_fnd_fk_csr%ROWTYPE;

      CURSOR okl_taxv_trqv_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM OKL_TRX_REQUESTS
       WHERE  OKL_TRX_REQUESTS.id = p_id;
       l_okl_taxv_trqv_fk             okl_taxv_trqv_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
        IF ((p_OKL_TAX_LINES_rec.TAX_LINE_TYPE IS NOT NULL)
          AND
          (p_OKL_TAX_LINES_rec.TAX_LINE_TYPE <> p_db_OKL_TAX_LINES_rec.TAX_LINE_TYPE))
        THEN
        OPEN okl_taxv_trqv_fk_csr (p_OKL_TAX_LINES_rec.TRQ_ID);
        FETCH okl_taxv_trqv_fk_csr INTO l_okl_taxv_trqv_fk;
        l_row_notfound := okl_taxv_trqv_fk_csr%NOTFOUND;
        CLOSE okl_taxv_trqv_fk_csr;
        IF (l_row_notfound) THEN
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_OKL_TAX_LINES_rec.TAX_LINE_TYPE IS NOT NULL)
       AND
          (p_OKL_TAX_LINES_rec.TAX_LINE_TYPE <> p_db_OKL_TAX_LINES_rec.TAX_LINE_TYPE))
      THEN
        OPEN okl_taxv_fnd_fk_csr (p_OKL_TAX_LINES_rec.TAX_LINE_TYPE);
        FETCH okl_taxv_fnd_fk_csr INTO l_okl_taxv_fnd_fk;
        l_row_notfound := okl_taxv_fnd_fk_csr%NOTFOUND;
        CLOSE okl_taxv_fnd_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TAX_LINE_TYPE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_OKL_TAX_LINES_rec, p_db_OKL_TAX_LINES_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_OKL_TAX_LINES_rec       OKL_TAX_LINES_rec_type := get_rec(p_OKL_TAX_LINES_rec);
  BEGIN
    l_return_status := Validate_Record(p_OKL_TAX_LINES_rec => p_OKL_TAX_LINES_rec,
                                       p_db_OKL_TAX_LINES_rec => l_db_OKL_TAX_LINES_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN OKL_TAX_LINES_rec_type,
    p_to   IN OUT NOCOPY tax_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.tax_line_type := p_from.tax_line_type;
    p_to.sel_id := p_from.sel_id;
    p_to.tax_due_date := p_from.tax_due_date;
    p_to.tax_type := p_from.tax_type;
    p_to.tax_rate_code_id := p_from.tax_rate_code_id;
    p_to.tax_rate_code := p_from.tax_rate_code;
    p_to.taxable_amount := p_from.taxable_amount;
    p_to.tax_exemption_id := p_from.tax_exemption_id;
    p_to.manually_entered_flag := p_from.manually_entered_flag;
    p_to.overridden_flag := p_from.overridden_flag;
    p_to.calculated_tax_amount := p_from.calculated_tax_amount;
    p_to.tax_rate := p_from.tax_rate;
    p_to.tax_amount := p_from.tax_amount;
    p_to.sales_tax_id := p_from.sales_tax_id;
    p_to.source_trx_id := p_from.source_trx_id;
    p_to.org_id := p_from.org_id;
    p_to.history_yn := p_from.history_yn;
    p_to.actual_yn := p_from.actual_yn;
    p_to.source_name := p_from.source_name;
    p_to.trq_id := p_from.trq_id;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
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
  END migrate;
  PROCEDURE migrate (
    p_from IN tax_rec_type,
    p_to   IN OUT NOCOPY OKL_TAX_LINES_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.khr_id := p_from.khr_id;
    p_to.kle_id := p_from.kle_id;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.tax_line_type := p_from.tax_line_type;
    p_to.sel_id := p_from.sel_id;
    p_to.tax_due_date := p_from.tax_due_date;
    p_to.tax_type := p_from.tax_type;
    p_to.tax_rate_code_id := p_from.tax_rate_code_id;
    p_to.tax_rate_code := p_from.tax_rate_code;
    p_to.taxable_amount := p_from.taxable_amount;
    p_to.tax_exemption_id := p_from.tax_exemption_id;
    p_to.manually_entered_flag := p_from.manually_entered_flag;
    p_to.overridden_flag := p_from.overridden_flag;
    p_to.calculated_tax_amount := p_from.calculated_tax_amount;
    p_to.tax_rate := p_from.tax_rate;
    p_to.tax_amount := p_from.tax_amount;
    p_to.sales_tax_id := p_from.sales_tax_id;
    p_to.source_trx_id := p_from.source_trx_id;
    p_to.org_id := p_from.org_id;
    p_to.history_yn := p_from.history_yn;
    p_to.actual_yn := p_from.actual_yn;
    p_to.source_name := p_from.source_name;
    p_to.trq_id := p_from.trq_id;
    p_to.program_id := p_from.program_id;
    p_to.request_id := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
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
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_TAX_LINES_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OKL_TAX_LINES_rec          OKL_TAX_LINES_rec_type := p_OKL_TAX_LINES_rec;
    l_tax_rec                      tax_rec_type;
    l_tax_rec                      tax_rec_type;
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
    l_return_status := Validate_Attributes(l_OKL_TAX_LINES_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_OKL_TAX_LINES_rec);
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
  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TAX_LINES_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      i := p_OKL_TAX_LINES_tbl.FIRST;
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
            p_OKL_TAX_LINES_rec          => p_OKL_TAX_LINES_tbl(i));
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
        EXIT WHEN (i = p_OKL_TAX_LINES_tbl.LAST);
        i := p_OKL_TAX_LINES_tbl.NEXT(i);
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

  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TAX_LINES_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_OKL_TAX_LINES_tbl          => p_OKL_TAX_LINES_tbl,
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
  ----------------------------------
  -- insert_row for:OKL_TAX_LINES --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tax_rec                      IN tax_rec_type,
    x_tax_rec                      OUT NOCOPY tax_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tax_rec                      tax_rec_type := p_tax_rec;
    l_def_tax_rec                  tax_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKL_TAX_LINES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_tax_rec IN tax_rec_type,
      x_tax_rec OUT NOCOPY tax_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tax_rec := p_tax_rec;
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
      p_tax_rec,                         -- IN
      l_tax_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TAX_LINES(
      id,
      khr_id,
      kle_id,
      asset_id,
      asset_number,
      tax_line_type,
      sel_id,
      tax_due_date,
      tax_type,
      tax_rate_code_id,
      tax_rate_code,
      taxable_amount,
      tax_exemption_id,
      manually_entered_flag,
      overridden_flag,
      calculated_tax_amount,
      tax_rate,
      tax_amount,
      sales_tax_id,
      source_trx_id,
      org_id,
      history_yn,
      actual_yn,
      source_name,
      trq_id,
      program_id,
      request_id,
      program_application_id,
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
      last_update_login)
    VALUES (
      l_tax_rec.id,
      l_tax_rec.khr_id,
      l_tax_rec.kle_id,
      l_tax_rec.asset_id,
      l_tax_rec.asset_number,
      l_tax_rec.tax_line_type,
      l_tax_rec.sel_id,
      l_tax_rec.tax_due_date,
      l_tax_rec.tax_type,
      l_tax_rec.tax_rate_code_id,
      l_tax_rec.tax_rate_code,
      l_tax_rec.taxable_amount,
      l_tax_rec.tax_exemption_id,
      l_tax_rec.manually_entered_flag,
      l_tax_rec.overridden_flag,
      l_tax_rec.calculated_tax_amount,
      l_tax_rec.tax_rate,
      l_tax_rec.tax_amount,
      l_tax_rec.sales_tax_id,
      l_tax_rec.source_trx_id,
      l_tax_rec.org_id,
      l_tax_rec.history_yn,
      l_tax_rec.actual_yn,
      l_tax_rec.source_name,
      l_tax_rec.trq_id,
      l_tax_rec.program_id,
      l_tax_rec.request_id,
      l_tax_rec.program_application_id,
      l_tax_rec.program_update_date,
      l_tax_rec.attribute_category,
      l_tax_rec.attribute1,
      l_tax_rec.attribute2,
      l_tax_rec.attribute3,
      l_tax_rec.attribute4,
      l_tax_rec.attribute5,
      l_tax_rec.attribute6,
      l_tax_rec.attribute7,
      l_tax_rec.attribute8,
      l_tax_rec.attribute9,
      l_tax_rec.attribute10,
      l_tax_rec.attribute11,
      l_tax_rec.attribute12,
      l_tax_rec.attribute13,
      l_tax_rec.attribute14,
      l_tax_rec.attribute15,
      l_tax_rec.created_by,
      l_tax_rec.creation_date,
      l_tax_rec.last_updated_by,
      l_tax_rec.last_update_date,
      l_tax_rec.last_update_login);
    -- Set OUT values
    x_tax_rec := l_tax_rec;
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
  -------------------------------------
  -- insert_row for :OKL_TAX_LINES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type,
    x_OKL_TAX_LINES_rec          OUT NOCOPY OKL_TAX_LINES_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OKL_TAX_LINES_rec          OKL_TAX_LINES_rec_type := p_OKL_TAX_LINES_rec;
    l_def_OKL_TAX_LINES_rec      OKL_TAX_LINES_rec_type;
    l_tax_rec                      tax_rec_type;
    lx_tax_rec                     tax_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type
    ) RETURN OKL_TAX_LINES_rec_type IS
      l_OKL_TAX_LINES_rec OKL_TAX_LINES_rec_type := p_OKL_TAX_LINES_rec;
    BEGIN
      l_OKL_TAX_LINES_rec.CREATION_DATE := SYSDATE;
      l_OKL_TAX_LINES_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_OKL_TAX_LINES_rec.LAST_UPDATE_DATE := l_OKL_TAX_LINES_rec.CREATION_DATE;
      l_OKL_TAX_LINES_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_OKL_TAX_LINES_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_OKL_TAX_LINES_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_TAX_LINES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type,
      x_OKL_TAX_LINES_rec OUT NOCOPY OKL_TAX_LINES_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_OKL_TAX_LINES_rec := p_OKL_TAX_LINES_rec;
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
    l_OKL_TAX_LINES_rec := null_out_defaults(p_OKL_TAX_LINES_rec);
    -- Set primary key value
    l_OKL_TAX_LINES_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_OKL_TAX_LINES_rec,             -- IN
      l_def_OKL_TAX_LINES_rec);        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_OKL_TAX_LINES_rec := fill_who_columns(l_def_OKL_TAX_LINES_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_OKL_TAX_LINES_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_OKL_TAX_LINES_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_OKL_TAX_LINES_rec, l_tax_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tax_rec,
      lx_tax_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tax_rec, l_def_OKL_TAX_LINES_rec);
    -- Set OUT values
    x_OKL_TAX_LINES_rec := l_def_OKL_TAX_LINES_rec;
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
  ---------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_TAX_LINES_V_TBL --
  ---------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      i := p_OKL_TAX_LINES_tbl.FIRST;
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
            p_OKL_TAX_LINES_rec          => p_OKL_TAX_LINES_tbl(i),
            x_OKL_TAX_LINES_rec          => x_OKL_TAX_LINES_tbl(i));
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
        EXIT WHEN (i = p_OKL_TAX_LINES_tbl.LAST);
        i := p_OKL_TAX_LINES_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL insert_row for:OKL_TAX_LINES_V_TBL --
  ---------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_OKL_TAX_LINES_tbl          => p_OKL_TAX_LINES_tbl,
        x_OKL_TAX_LINES_tbl          => x_OKL_TAX_LINES_tbl,
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
  --------------------------------
  -- lock_row for:OKL_TAX_LINES --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tax_rec                      IN tax_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tax_rec IN tax_rec_type) IS
    SELECT *
      FROM OKL_TAX_LINES
     WHERE ID = p_tax_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_tax_rec);
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
      IF (l_lock_var.id <> p_tax_rec.id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.khr_id <> p_tax_rec.khr_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.kle_id <> p_tax_rec.kle_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_id <> p_tax_rec.asset_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.asset_number <> p_tax_rec.asset_number) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_line_type <> p_tax_rec.tax_line_type) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.sel_id <> p_tax_rec.sel_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_due_date <> p_tax_rec.tax_due_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_type <> p_tax_rec.tax_type) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_rate_code_id <> p_tax_rec.tax_rate_code_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_rate_code <> p_tax_rec.tax_rate_code) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.taxable_amount <> p_tax_rec.taxable_amount) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_exemption_id <> p_tax_rec.tax_exemption_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.manually_entered_flag <> p_tax_rec.manually_entered_flag) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.overridden_flag <> p_tax_rec.overridden_flag) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.calculated_tax_amount <> p_tax_rec.calculated_tax_amount) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_rate <> p_tax_rec.tax_rate) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.tax_amount <> p_tax_rec.tax_amount) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.sales_tax_id <> p_tax_rec.sales_tax_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.source_trx_id <> p_tax_rec.source_trx_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.org_id <> p_tax_rec.org_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.history_yn <> p_tax_rec.history_yn) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.actual_yn <> p_tax_rec.actual_yn) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.source_name <> p_tax_rec.source_name) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.trq_id <> p_tax_rec.trq_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.program_id <> p_tax_rec.program_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.request_id <> p_tax_rec.request_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.program_application_id <> p_tax_rec.program_application_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.program_update_date <> p_tax_rec.program_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute_category <> p_tax_rec.attribute_category) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute1 <> p_tax_rec.attribute1) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute2 <> p_tax_rec.attribute2) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute3 <> p_tax_rec.attribute3) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute4 <> p_tax_rec.attribute4) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute5 <> p_tax_rec.attribute5) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute6 <> p_tax_rec.attribute6) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute7 <> p_tax_rec.attribute7) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute8 <> p_tax_rec.attribute8) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute9 <> p_tax_rec.attribute9) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute10 <> p_tax_rec.attribute10) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute11 <> p_tax_rec.attribute11) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute12 <> p_tax_rec.attribute12) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute13 <> p_tax_rec.attribute13) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute14 <> p_tax_rec.attribute14) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.attribute15 <> p_tax_rec.attribute15) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.created_by <> p_tax_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.creation_date <> p_tax_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_updated_by <> p_tax_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_date <> p_tax_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.last_update_login <> p_tax_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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
  -----------------------------------
  -- lock_row for: OKL_TAX_LINES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tax_rec                      tax_rec_type;
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
    migrate(p_OKL_TAX_LINES_rec, l_tax_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tax_rec
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
  -------------------------------------------------
  -- PL/SQL TBL lock_row for:OKL_TAX_LINES_V_TBL --
  -------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      i := p_OKL_TAX_LINES_tbl.FIRST;
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
            p_OKL_TAX_LINES_rec          => p_OKL_TAX_LINES_tbl(i));
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
        EXIT WHEN (i = p_OKL_TAX_LINES_tbl.LAST);
        i := p_OKL_TAX_LINES_tbl.NEXT(i);
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
  -------------------------------------------------
  -- PL/SQL TBL lock_row for:OKL_TAX_LINES_V_TBL --
  -------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_OKL_TAX_LINES_tbl          => p_OKL_TAX_LINES_tbl,
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
  ----------------------------------
  -- update_row for:OKL_TAX_LINES --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tax_rec                      IN tax_rec_type,
    x_tax_rec                      OUT NOCOPY tax_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tax_rec                      tax_rec_type := p_tax_rec;
    l_def_tax_rec                  tax_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tax_rec IN tax_rec_type,
      x_tax_rec OUT NOCOPY tax_rec_type
    ) RETURN VARCHAR2 IS
      l_tax_rec                      tax_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tax_rec := p_tax_rec;
      -- Get current database values
      l_tax_rec := get_rec(p_tax_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_tax_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.id := l_tax_rec.id;
        END IF;
        IF (x_tax_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.khr_id := l_tax_rec.khr_id;
        END IF;
        IF (x_tax_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.kle_id := l_tax_rec.kle_id;
        END IF;
        IF (x_tax_rec.asset_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.asset_id := l_tax_rec.asset_id;
        END IF;
        IF (x_tax_rec.asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.asset_number := l_tax_rec.asset_number;
        END IF;
        IF (x_tax_rec.tax_line_type = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.tax_line_type := l_tax_rec.tax_line_type;
        END IF;
        IF (x_tax_rec.sel_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.sel_id := l_tax_rec.sel_id;
        END IF;
        IF (x_tax_rec.tax_due_date = OKC_API.G_MISS_DATE)
        THEN
          x_tax_rec.tax_due_date := l_tax_rec.tax_due_date;
        END IF;
        IF (x_tax_rec.tax_type = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.tax_type := l_tax_rec.tax_type;
        END IF;
        IF (x_tax_rec.tax_rate_code_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.tax_rate_code_id := l_tax_rec.tax_rate_code_id;
        END IF;
        IF (x_tax_rec.tax_rate_code = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.tax_rate_code := l_tax_rec.tax_rate_code;
        END IF;
        IF (x_tax_rec.taxable_amount = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.taxable_amount := l_tax_rec.taxable_amount;
        END IF;
        IF (x_tax_rec.tax_exemption_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.tax_exemption_id := l_tax_rec.tax_exemption_id;
        END IF;
        IF (x_tax_rec.manually_entered_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.manually_entered_flag := l_tax_rec.manually_entered_flag;
        END IF;
        IF (x_tax_rec.overridden_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.overridden_flag := l_tax_rec.overridden_flag;
        END IF;
        IF (x_tax_rec.calculated_tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.calculated_tax_amount := l_tax_rec.calculated_tax_amount;
        END IF;
        IF (x_tax_rec.tax_rate = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.tax_rate := l_tax_rec.tax_rate;
        END IF;
        IF (x_tax_rec.tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.tax_amount := l_tax_rec.tax_amount;
        END IF;
        IF (x_tax_rec.sales_tax_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.sales_tax_id := l_tax_rec.sales_tax_id;
        END IF;
        IF (x_tax_rec.source_trx_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.source_trx_id := l_tax_rec.source_trx_id;
        END IF;
        IF (x_tax_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.org_id := l_tax_rec.org_id;
        END IF;
        IF (x_tax_rec.history_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.history_yn := l_tax_rec.history_yn;
        END IF;
        IF (x_tax_rec.actual_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.actual_yn := l_tax_rec.actual_yn;
        END IF;
        IF (x_tax_rec.source_name = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.source_name := l_tax_rec.source_name;
        END IF;
        IF (x_tax_rec.trq_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.trq_id := l_tax_rec.trq_id;
        END IF;
        IF (x_tax_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.program_id := l_tax_rec.program_id;
        END IF;
        IF (x_tax_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.request_id := l_tax_rec.request_id;
        END IF;
        IF (x_tax_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.program_application_id := l_tax_rec.program_application_id;
        END IF;
        IF (x_tax_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_tax_rec.program_update_date := l_tax_rec.program_update_date;
        END IF;
        IF (x_tax_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute_category := l_tax_rec.attribute_category;
        END IF;
        IF (x_tax_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute1 := l_tax_rec.attribute1;
        END IF;
        IF (x_tax_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute2 := l_tax_rec.attribute2;
        END IF;
        IF (x_tax_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute3 := l_tax_rec.attribute3;
        END IF;
        IF (x_tax_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute4 := l_tax_rec.attribute4;
        END IF;
        IF (x_tax_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute5 := l_tax_rec.attribute5;
        END IF;
        IF (x_tax_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute6 := l_tax_rec.attribute6;
        END IF;
        IF (x_tax_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute7 := l_tax_rec.attribute7;
        END IF;
        IF (x_tax_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute8 := l_tax_rec.attribute8;
        END IF;
        IF (x_tax_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute9 := l_tax_rec.attribute9;
        END IF;
        IF (x_tax_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute10 := l_tax_rec.attribute10;
        END IF;
        IF (x_tax_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute11 := l_tax_rec.attribute11;
        END IF;
        IF (x_tax_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute12 := l_tax_rec.attribute12;
        END IF;
        IF (x_tax_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute13 := l_tax_rec.attribute13;
        END IF;
        IF (x_tax_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute14 := l_tax_rec.attribute14;
        END IF;
        IF (x_tax_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_tax_rec.attribute15 := l_tax_rec.attribute15;
        END IF;
        IF (x_tax_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.created_by := l_tax_rec.created_by;
        END IF;
        IF (x_tax_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_tax_rec.creation_date := l_tax_rec.creation_date;
        END IF;
        IF (x_tax_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.last_updated_by := l_tax_rec.last_updated_by;
        END IF;
        IF (x_tax_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_tax_rec.last_update_date := l_tax_rec.last_update_date;
        END IF;
        IF (x_tax_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_tax_rec.last_update_login := l_tax_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_TAX_LINES --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_tax_rec IN tax_rec_type,
      x_tax_rec OUT NOCOPY tax_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tax_rec := p_tax_rec;
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
      p_tax_rec,                         -- IN
      l_tax_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tax_rec, l_def_tax_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TAX_LINES
    SET KHR_ID = l_def_tax_rec.khr_id,
        KLE_ID = l_def_tax_rec.kle_id,
        ASSET_ID = l_def_tax_rec.asset_id,
        ASSET_NUMBER = l_def_tax_rec.asset_number,
        TAX_LINE_TYPE = l_def_tax_rec.tax_line_type,
        SEL_ID = l_def_tax_rec.sel_id,
        TAX_DUE_DATE = l_def_tax_rec.tax_due_date,
        TAX_TYPE = l_def_tax_rec.tax_type,
        TAX_RATE_CODE_ID = l_def_tax_rec.tax_rate_code_id,
        TAX_RATE_CODE = l_def_tax_rec.tax_rate_code,
        TAXABLE_AMOUNT = l_def_tax_rec.taxable_amount,
        TAX_EXEMPTION_ID = l_def_tax_rec.tax_exemption_id,
        MANUALLY_ENTERED_FLAG = l_def_tax_rec.manually_entered_flag,
        OVERRIDDEN_FLAG = l_def_tax_rec.overridden_flag,
        CALCULATED_TAX_AMOUNT = l_def_tax_rec.calculated_tax_amount,
        TAX_RATE = l_def_tax_rec.tax_rate,
        TAX_AMOUNT = l_def_tax_rec.tax_amount,
        SALES_TAX_ID = l_def_tax_rec.sales_tax_id,
        SOURCE_TRX_ID = l_def_tax_rec.source_trx_id,
        ORG_ID = l_def_tax_rec.org_id,
        HISTORY_YN = l_def_tax_rec.history_yn,
        ACTUAL_YN = l_def_tax_rec.actual_yn,
        SOURCE_NAME = l_def_tax_rec.source_name,
        TRQ_ID = l_def_tax_rec.trq_id,
        PROGRAM_ID = l_def_tax_rec.program_id,
        REQUEST_ID = l_def_tax_rec.request_id,
        PROGRAM_APPLICATION_ID = l_def_tax_rec.program_application_id,
        PROGRAM_UPDATE_DATE = l_def_tax_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_tax_rec.attribute_category,
        ATTRIBUTE1 = l_def_tax_rec.attribute1,
        ATTRIBUTE2 = l_def_tax_rec.attribute2,
        ATTRIBUTE3 = l_def_tax_rec.attribute3,
        ATTRIBUTE4 = l_def_tax_rec.attribute4,
        ATTRIBUTE5 = l_def_tax_rec.attribute5,
        ATTRIBUTE6 = l_def_tax_rec.attribute6,
        ATTRIBUTE7 = l_def_tax_rec.attribute7,
        ATTRIBUTE8 = l_def_tax_rec.attribute8,
        ATTRIBUTE9 = l_def_tax_rec.attribute9,
        ATTRIBUTE10 = l_def_tax_rec.attribute10,
        ATTRIBUTE11 = l_def_tax_rec.attribute11,
        ATTRIBUTE12 = l_def_tax_rec.attribute12,
        ATTRIBUTE13 = l_def_tax_rec.attribute13,
        ATTRIBUTE14 = l_def_tax_rec.attribute14,
        ATTRIBUTE15 = l_def_tax_rec.attribute15,
        CREATED_BY = l_def_tax_rec.created_by,
        CREATION_DATE = l_def_tax_rec.creation_date,
        LAST_UPDATED_BY = l_def_tax_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tax_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tax_rec.last_update_login
    WHERE ID = l_def_tax_rec.id;

    x_tax_rec := l_tax_rec;
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
  ------------------------------------
  -- update_row for:OKL_TAX_LINES_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type,
    x_OKL_TAX_LINES_rec          OUT NOCOPY OKL_TAX_LINES_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OKL_TAX_LINES_rec          OKL_TAX_LINES_rec_type := p_OKL_TAX_LINES_rec;
    l_def_OKL_TAX_LINES_rec      OKL_TAX_LINES_rec_type;
    l_db_OKL_TAX_LINES_rec       OKL_TAX_LINES_rec_type;
    l_tax_rec                      tax_rec_type;
    lx_tax_rec                     tax_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type
    ) RETURN OKL_TAX_LINES_rec_type IS
      l_OKL_TAX_LINES_rec OKL_TAX_LINES_rec_type := p_OKL_TAX_LINES_rec;
    BEGIN
      l_OKL_TAX_LINES_rec.LAST_UPDATE_DATE := SYSDATE;
      l_OKL_TAX_LINES_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_OKL_TAX_LINES_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_OKL_TAX_LINES_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type,
      x_OKL_TAX_LINES_rec OUT NOCOPY OKL_TAX_LINES_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_OKL_TAX_LINES_rec := p_OKL_TAX_LINES_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_OKL_TAX_LINES_rec := get_rec(p_OKL_TAX_LINES_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_OKL_TAX_LINES_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.id := l_db_OKL_TAX_LINES_rec.id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.khr_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.khr_id := l_db_OKL_TAX_LINES_rec.khr_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.kle_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.kle_id := l_db_OKL_TAX_LINES_rec.kle_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.asset_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.asset_id := l_db_OKL_TAX_LINES_rec.asset_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.asset_number = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.asset_number := l_db_OKL_TAX_LINES_rec.asset_number;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_line_type = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.tax_line_type := l_db_OKL_TAX_LINES_rec.tax_line_type;
        END IF;
        IF (x_OKL_TAX_LINES_rec.sel_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.sel_id := l_db_OKL_TAX_LINES_rec.sel_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_due_date = OKC_API.G_MISS_DATE)
        THEN
          x_OKL_TAX_LINES_rec.tax_due_date := l_db_OKL_TAX_LINES_rec.tax_due_date;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_type = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.tax_type := l_db_OKL_TAX_LINES_rec.tax_type;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_rate_code_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.tax_rate_code_id := l_db_OKL_TAX_LINES_rec.tax_rate_code_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_rate_code = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.tax_rate_code := l_db_OKL_TAX_LINES_rec.tax_rate_code;
        END IF;
        IF (x_OKL_TAX_LINES_rec.taxable_amount = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.taxable_amount := l_db_OKL_TAX_LINES_rec.taxable_amount;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_exemption_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.tax_exemption_id := l_db_OKL_TAX_LINES_rec.tax_exemption_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.manually_entered_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.manually_entered_flag := l_db_OKL_TAX_LINES_rec.manually_entered_flag;
        END IF;
        IF (x_OKL_TAX_LINES_rec.overridden_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.overridden_flag := l_db_OKL_TAX_LINES_rec.overridden_flag;
        END IF;
        IF (x_OKL_TAX_LINES_rec.calculated_tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.calculated_tax_amount := l_db_OKL_TAX_LINES_rec.calculated_tax_amount;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_rate = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.tax_rate := l_db_OKL_TAX_LINES_rec.tax_rate;
        END IF;
        IF (x_OKL_TAX_LINES_rec.tax_amount = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.tax_amount := l_db_OKL_TAX_LINES_rec.tax_amount;
        END IF;
        IF (x_OKL_TAX_LINES_rec.sales_tax_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.sales_tax_id := l_db_OKL_TAX_LINES_rec.sales_tax_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.source_trx_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.source_trx_id := l_db_OKL_TAX_LINES_rec.source_trx_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.org_id := l_db_OKL_TAX_LINES_rec.org_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.history_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.history_yn := l_db_OKL_TAX_LINES_rec.history_yn;
        END IF;
        IF (x_OKL_TAX_LINES_rec.actual_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.actual_yn := l_db_OKL_TAX_LINES_rec.actual_yn;
        END IF;
        IF (x_OKL_TAX_LINES_rec.source_name = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.source_name := l_db_OKL_TAX_LINES_rec.source_name;
        END IF;
        IF (x_OKL_TAX_LINES_rec.trq_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.trq_id := l_db_OKL_TAX_LINES_rec.trq_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.program_id := l_db_OKL_TAX_LINES_rec.program_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.request_id := l_db_OKL_TAX_LINES_rec.request_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.program_application_id := l_db_OKL_TAX_LINES_rec.program_application_id;
        END IF;
        IF (x_OKL_TAX_LINES_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_OKL_TAX_LINES_rec.program_update_date := l_db_OKL_TAX_LINES_rec.program_update_date;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute_category := l_db_OKL_TAX_LINES_rec.attribute_category;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute1 := l_db_OKL_TAX_LINES_rec.attribute1;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute2 := l_db_OKL_TAX_LINES_rec.attribute2;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute3 := l_db_OKL_TAX_LINES_rec.attribute3;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute4 := l_db_OKL_TAX_LINES_rec.attribute4;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute5 := l_db_OKL_TAX_LINES_rec.attribute5;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute6 := l_db_OKL_TAX_LINES_rec.attribute6;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute7 := l_db_OKL_TAX_LINES_rec.attribute7;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute8 := l_db_OKL_TAX_LINES_rec.attribute8;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute9 := l_db_OKL_TAX_LINES_rec.attribute9;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute10 := l_db_OKL_TAX_LINES_rec.attribute10;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute11 := l_db_OKL_TAX_LINES_rec.attribute11;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute12 := l_db_OKL_TAX_LINES_rec.attribute12;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute13 := l_db_OKL_TAX_LINES_rec.attribute13;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute14 := l_db_OKL_TAX_LINES_rec.attribute14;
        END IF;
        IF (x_OKL_TAX_LINES_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_OKL_TAX_LINES_rec.attribute15 := l_db_OKL_TAX_LINES_rec.attribute15;
        END IF;
        IF (x_OKL_TAX_LINES_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.created_by := l_db_OKL_TAX_LINES_rec.created_by;
        END IF;
        IF (x_OKL_TAX_LINES_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_OKL_TAX_LINES_rec.creation_date := l_db_OKL_TAX_LINES_rec.creation_date;
        END IF;
        IF (x_OKL_TAX_LINES_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.last_updated_by := l_db_OKL_TAX_LINES_rec.last_updated_by;
        END IF;
        IF (x_OKL_TAX_LINES_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_OKL_TAX_LINES_rec.last_update_date := l_db_OKL_TAX_LINES_rec.last_update_date;
        END IF;
        IF (x_OKL_TAX_LINES_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_OKL_TAX_LINES_rec.last_update_login := l_db_OKL_TAX_LINES_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_TAX_LINES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_OKL_TAX_LINES_rec IN OKL_TAX_LINES_rec_type,
      x_OKL_TAX_LINES_rec OUT NOCOPY OKL_TAX_LINES_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_OKL_TAX_LINES_rec := p_OKL_TAX_LINES_rec;
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
      p_OKL_TAX_LINES_rec,             -- IN
      x_OKL_TAX_LINES_rec);            -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_OKL_TAX_LINES_rec, l_def_OKL_TAX_LINES_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_OKL_TAX_LINES_rec := fill_who_columns(l_def_OKL_TAX_LINES_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_OKL_TAX_LINES_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_OKL_TAX_LINES_rec, l_db_OKL_TAX_LINES_rec);
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
      p_OKL_TAX_LINES_rec          => p_OKL_TAX_LINES_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_OKL_TAX_LINES_rec, l_tax_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tax_rec,
      lx_tax_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tax_rec, l_def_OKL_TAX_LINES_rec);
    x_OKL_TAX_LINES_rec := l_def_OKL_TAX_LINES_rec;
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
  ---------------------------------------------------
  -- PL/SQL TBL update_row for:okl_tax_lines_v_tbl --
  ---------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      i := p_OKL_TAX_LINES_tbl.FIRST;
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
            p_OKL_TAX_LINES_rec          => p_OKL_TAX_LINES_tbl(i),
            x_OKL_TAX_LINES_rec          => x_OKL_TAX_LINES_tbl(i));
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
        EXIT WHEN (i = p_OKL_TAX_LINES_tbl.LAST);
        i := p_OKL_TAX_LINES_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL update_row for:OKL_TAX_LINES_V_TBL --
  ---------------------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    x_OKL_TAX_LINES_tbl          OUT NOCOPY OKL_TAX_LINES_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_OKL_TAX_LINES_tbl          => p_OKL_TAX_LINES_tbl,
        x_OKL_TAX_LINES_tbl          => x_OKL_TAX_LINES_tbl,
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
  ----------------------------------
  -- delete_row for:OKL_TAX_LINES --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tax_rec                      IN tax_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tax_rec                      tax_rec_type := p_tax_rec;
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

    DELETE FROM OKL_TAX_LINES
     WHERE ID = p_tax_rec.id;

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
  ------------------------------------
  -- delete_row for:OKL_TAX_LINES_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_rec          IN OKL_TAX_LINES_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_OKL_TAX_LINES_rec          OKL_TAX_LINES_rec_type := p_OKL_TAX_LINES_rec;
    l_tax_rec                      tax_rec_type;
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
    migrate(l_OKL_TAX_LINES_rec, l_tax_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_tax_rec
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
  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TAX_LINES_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      i := p_OKL_TAX_LINES_tbl.FIRST;
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
            p_OKL_TAX_LINES_rec          => p_OKL_TAX_LINES_tbl(i));
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
        EXIT WHEN (i = p_OKL_TAX_LINES_tbl.LAST);
        i := p_OKL_TAX_LINES_tbl.NEXT(i);
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

  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TAX_LINES_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_OKL_TAX_LINES_tbl          IN OKL_TAX_LINES_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_OKL_TAX_LINES_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_OKL_TAX_LINES_tbl          => p_OKL_TAX_LINES_tbl,
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

END OKL_TAX_PVT;

/
