--------------------------------------------------------
--  DDL for Package Body OKL_CHD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CHD_PVT" AS
/* $Header: OKLSCHDB.pls 115.9 2004/05/20 23:44:28 pdevaraj noship $ */
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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_CURE_REFUND_HEADERS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_CURE_REFUND_HEADERS_B B
         WHERE B.CURE_REFUND_HEADER_ID =T.CURE_REFUND_HEADER_ID
        );

    UPDATE OKL_CURE_REFUND_HEADERS_TL T SET(
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM OKL_CURE_REFUND_HEADERS_TL B
                               WHERE B.CURE_REFUND_HEADER_ID = T.CURE_REFUND_HEADER_ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.CURE_REFUND_HEADER_ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.CURE_REFUND_HEADER_ID,
                  SUBT.LANGUAGE
                FROM OKL_CURE_REFUND_HEADERS_TL SUBB, OKL_CURE_REFUND_HEADERS_TL SUBT
               WHERE SUBB.CURE_REFUND_HEADER_ID = SUBT.CURE_REFUND_HEADER_ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_CURE_REFUND_HEADERS_TL (
        CURE_REFUND_HEADER_ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.CURE_REFUND_HEADER_ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_CURE_REFUND_HEADERS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_CURE_REFUND_HEADERS_TL T
                     WHERE T.CURE_REFUND_HEADER_ID = B.CURE_REFUND_HEADER_ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CURE_REFUND_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_chdv_rec                     IN chdv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN chdv_rec_type IS
    CURSOR okl_cure_refund_headers_pk_csr (p_cure_refund_header_id IN NUMBER) IS
    SELECT
            CURE_REFUND_HEADER_ID,
            REFUND_HEADER_NUMBER,
            REFUND_TYPE,
            REFUND_DUE_DATE,
            CURRENCY_CODE,
            TOTAL_REFUND_DUE,
            DISBURSEMENT_AMOUNT,
            RECEIVED_AMOUNT,
            OFFSET_AMOUNT,
            NEGOTIATED_AMOUNT,
            VENDOR_SITE_ID,
            REFUND_STATUS,
            PAYMENT_METHOD,
            PAYMENT_TERM_ID,
            SFWT_FLAG,
            DESCRIPTION,
            OBJECT_VERSION_NUMBER,
            VENDOR_CURE_DUE,
            VENDOR_SITE_CURE_DUE,
            CHR_ID,
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
      FROM Okl_Cure_Refund_Headers_V
     WHERE okl_cure_refund_headers_v.cure_refund_header_id = p_cure_refund_header_id;
    l_okl_cure_refund_headers_pk   okl_cure_refund_headers_pk_csr%ROWTYPE;
    l_chdv_rec                     chdv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cure_refund_headers_pk_csr (p_chdv_rec.cure_refund_header_id);
    FETCH okl_cure_refund_headers_pk_csr INTO
              l_chdv_rec.cure_refund_header_id,
              l_chdv_rec.refund_header_number,
              l_chdv_rec.refund_type,
              l_chdv_rec.refund_due_date,
              l_chdv_rec.currency_code,
              l_chdv_rec.total_refund_due,
              l_chdv_rec.disbursement_amount,
              l_chdv_rec.RECEIVED_AMOUNT,
              l_chdv_rec.OFFSET_AMOUNT,
              l_chdv_rec.NEGOTIATED_AMOUNT,
              l_chdv_rec.vendor_site_id,
              l_chdv_rec.refund_status,
              l_chdv_rec.payment_method,
              l_chdv_rec.payment_term_id,
              l_chdv_rec.sfwt_flag,
              l_chdv_rec.description,
              l_chdv_rec.object_version_number,
              l_chdv_rec.vendor_cure_due,
              l_chdv_rec.vendor_site_cure_due,
              l_chdv_rec.chr_id,
              l_chdv_rec.program_id,
              l_chdv_rec.request_id,
              l_chdv_rec.program_application_id,
              l_chdv_rec.program_update_date,
              l_chdv_rec.attribute_category,
              l_chdv_rec.attribute1,
              l_chdv_rec.attribute2,
              l_chdv_rec.attribute3,
              l_chdv_rec.attribute4,
              l_chdv_rec.attribute5,
              l_chdv_rec.attribute6,
              l_chdv_rec.attribute7,
              l_chdv_rec.attribute8,
              l_chdv_rec.attribute9,
              l_chdv_rec.attribute10,
              l_chdv_rec.attribute11,
              l_chdv_rec.attribute12,
              l_chdv_rec.attribute13,
              l_chdv_rec.attribute14,
              l_chdv_rec.attribute15,
              l_chdv_rec.created_by,
              l_chdv_rec.creation_date,
              l_chdv_rec.last_updated_by,
              l_chdv_rec.last_update_date,
              l_chdv_rec.last_update_login;
    x_no_data_found := okl_cure_refund_headers_pk_csr%NOTFOUND;
    CLOSE okl_cure_refund_headers_pk_csr;
    RETURN(l_chdv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_chdv_rec                     IN chdv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN chdv_rec_type IS
    l_chdv_rec                     chdv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_chdv_rec := get_rec(p_chdv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CURE_REFUND_HEADER_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_chdv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_chdv_rec                     IN chdv_rec_type
  ) RETURN chdv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_chdv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CURE_REFUND_HEADERS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_chd_rec                      IN chd_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN chd_rec_type IS
    CURSOR okl_cure_refund_hea179 (p_cure_refund_header_id IN NUMBER) IS
    SELECT
            CURE_REFUND_HEADER_ID,
            REFUND_HEADER_NUMBER,
            REFUND_TYPE,
            REFUND_DUE_DATE,
            CURRENCY_CODE,
            TOTAL_REFUND_DUE,
            DISBURSEMENT_AMOUNT,
            RECEIVED_AMOUNT,
            OFFSET_AMOUNT,
            NEGOTIATED_AMOUNT,
            VENDOR_SITE_ID,
            REFUND_STATUS,
            PAYMENT_METHOD,
            PAYMENT_TERM_ID,
            OBJECT_VERSION_NUMBER,
            VENDOR_CURE_DUE,
            VENDOR_SITE_CURE_DUE,
            CHR_ID,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
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
            LAST_UPDATE_LOGIN
      FROM Okl_Cure_Refund_Headers_B
     WHERE okl_cure_refund_headers_b.cure_refund_header_id = p_cure_refund_header_id;
    l_okl_cure_refund_headers_b_pk okl_cure_refund_hea179%ROWTYPE;
    l_chd_rec                      chd_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cure_refund_hea179 (p_chd_rec.cure_refund_header_id);
    FETCH okl_cure_refund_hea179 INTO
              l_chd_rec.cure_refund_header_id,
              l_chd_rec.refund_header_number,
              l_chd_rec.refund_type,
              l_chd_rec.refund_due_date,
              l_chd_rec.currency_code,
              l_chd_rec.total_refund_due,
              l_chd_rec.disbursement_amount,
              l_chd_rec.RECEIVED_AMOUNT,
              l_chd_rec.OFFSET_AMOUNT,
              l_chd_rec.NEGOTIATED_AMOUNT,
              l_chd_rec.vendor_site_id,
              l_chd_rec.refund_status,
              l_chd_rec.payment_method,
              l_chd_rec.payment_term_id,
              l_chd_rec.object_version_number,
              l_chd_rec.vendor_cure_due,
              l_chd_rec.vendor_site_cure_due,
              l_chd_rec.chr_id,
              l_chd_rec.program_application_id,
              l_chd_rec.request_id,
              l_chd_rec.program_id,
              l_chd_rec.program_update_date,
              l_chd_rec.attribute_category,
              l_chd_rec.attribute1,
              l_chd_rec.attribute2,
              l_chd_rec.attribute3,
              l_chd_rec.attribute4,
              l_chd_rec.attribute5,
              l_chd_rec.attribute6,
              l_chd_rec.attribute7,
              l_chd_rec.attribute8,
              l_chd_rec.attribute9,
              l_chd_rec.attribute10,
              l_chd_rec.attribute11,
              l_chd_rec.attribute12,
              l_chd_rec.attribute13,
              l_chd_rec.attribute14,
              l_chd_rec.attribute15,
              l_chd_rec.created_by,
              l_chd_rec.creation_date,
              l_chd_rec.last_updated_by,
              l_chd_rec.last_update_date,
              l_chd_rec.last_update_login;
    x_no_data_found := okl_cure_refund_hea179%NOTFOUND;
    CLOSE okl_cure_refund_hea179;
    RETURN(l_chd_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_chd_rec                      IN chd_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN chd_rec_type IS
    l_chd_rec                      chd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_chd_rec := get_rec(p_chd_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CURE_REFUND_HEADER_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_chd_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_chd_rec                      IN chd_rec_type
  ) RETURN chd_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_chd_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CURE_REFUND_HEADERS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cure_refund_h182         IN OklCureRefundHeadersTlRecType,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN OklCureRefundHeadersTlRecType IS
    CURSOR okl_cure_refund_hea180 (p_cure_refund_header_id IN NUMBER,
                                   p_language              IN VARCHAR2) IS
    SELECT
            CURE_REFUND_HEADER_ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Cure_Refund_Headers_Tl
     WHERE okl_cure_refund_headers_tl.cure_refund_header_id = p_cure_refund_header_id
       AND okl_cure_refund_headers_tl.language = p_language;
    l_okl_cure_refund_h181         okl_cure_refund_hea180%ROWTYPE;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cure_refund_hea180 (p_okl_cure_refund_h182.cure_refund_header_id,
                                 p_okl_cure_refund_h182.language);
    FETCH okl_cure_refund_hea180 INTO
              l_okl_cure_refund_h183.cure_refund_header_id,
              l_okl_cure_refund_h183.language,
              l_okl_cure_refund_h183.source_lang,
              l_okl_cure_refund_h183.sfwt_flag,
              l_okl_cure_refund_h183.description,
              l_okl_cure_refund_h183.created_by,
              l_okl_cure_refund_h183.creation_date,
              l_okl_cure_refund_h183.last_updated_by,
              l_okl_cure_refund_h183.last_update_date,
              l_okl_cure_refund_h183.last_update_login;
    x_no_data_found := okl_cure_refund_hea180%NOTFOUND;
    CLOSE okl_cure_refund_hea180;
    RETURN(l_okl_cure_refund_h183);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cure_refund_h182         IN OklCureRefundHeadersTlRecType,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN OklCureRefundHeadersTlRecType IS
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cure_refund_h183 := get_rec(p_okl_cure_refund_h182, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CURE_REFUND_HEADER_ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_cure_refund_h183);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_cure_refund_h182         IN OklCureRefundHeadersTlRecType
  ) RETURN OklCureRefundHeadersTlRecType IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_cure_refund_h182, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CURE_REFUND_HEADERS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_chdv_rec   IN chdv_rec_type
  ) RETURN chdv_rec_type IS
    l_chdv_rec                     chdv_rec_type := p_chdv_rec;
  BEGIN
    IF (l_chdv_rec.cure_refund_header_id = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.cure_refund_header_id := NULL;
    END IF;
    IF (l_chdv_rec.refund_header_number = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.refund_header_number := NULL;
    END IF;
    IF (l_chdv_rec.refund_type = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.refund_type := NULL;
    END IF;
    IF (l_chdv_rec.refund_due_date = OKL_API.G_MISS_DATE ) THEN
      l_chdv_rec.refund_due_date := NULL;
    END IF;
    IF (l_chdv_rec.currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.currency_code := NULL;
    END IF;
    IF (l_chdv_rec.total_refund_due = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.total_refund_due := NULL;
    END IF;
    IF (l_chdv_rec.disbursement_amount = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.disbursement_amount := NULL;
    END IF;
    IF (l_chdv_rec.RECEIVED_AMOUNT = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.RECEIVED_AMOUNT := NULL;
    END IF;
    IF (l_chdv_rec.OFFSET_AMOUNT = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.OFFSET_AMOUNT := NULL;
    END IF;
    IF (l_chdv_rec.NEGOTIATED_AMOUNT = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.NEGOTIATED_AMOUNT := NULL;
    END IF;
    IF (l_chdv_rec.vendor_site_id = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.vendor_site_id := NULL;
    END IF;
    IF (l_chdv_rec.refund_status = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.refund_status := NULL;
    END IF;
    IF (l_chdv_rec.payment_method = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.payment_method := NULL;
    END IF;
    IF (l_chdv_rec.payment_term_id = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.payment_term_id := NULL;
    END IF;
    IF (l_chdv_rec.sfwt_flag = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_chdv_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.description := NULL;
    END IF;
    IF (l_chdv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.object_version_number := NULL;
    END IF;
    IF (l_chdv_rec.vendor_cure_due = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.vendor_cure_due := NULL;
    END IF;
    IF (l_chdv_rec.vendor_site_cure_due = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.vendor_site_cure_due := NULL;
    END IF;
    IF (l_chdv_rec.chr_id = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.chr_id := NULL;
    END IF;
    IF (l_chdv_rec.program_id = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.program_id := NULL;
    END IF;
    IF (l_chdv_rec.request_id = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.request_id := NULL;
    END IF;
    IF (l_chdv_rec.program_application_id = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.program_application_id := NULL;
    END IF;
    IF (l_chdv_rec.program_update_date = OKL_API.G_MISS_DATE ) THEN
      l_chdv_rec.program_update_date := NULL;
    END IF;
    IF (l_chdv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute_category := NULL;
    END IF;
    IF (l_chdv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute1 := NULL;
    END IF;
    IF (l_chdv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute2 := NULL;
    END IF;
    IF (l_chdv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute3 := NULL;
    END IF;
    IF (l_chdv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute4 := NULL;
    END IF;
    IF (l_chdv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute5 := NULL;
    END IF;
    IF (l_chdv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute6 := NULL;
    END IF;
    IF (l_chdv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute7 := NULL;
    END IF;
    IF (l_chdv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute8 := NULL;
    END IF;
    IF (l_chdv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute9 := NULL;
    END IF;
    IF (l_chdv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute10 := NULL;
    END IF;
    IF (l_chdv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute11 := NULL;
    END IF;
    IF (l_chdv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute12 := NULL;
    END IF;
    IF (l_chdv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute13 := NULL;
    END IF;
    IF (l_chdv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute14 := NULL;
    END IF;
    IF (l_chdv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_chdv_rec.attribute15 := NULL;
    END IF;
    IF (l_chdv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.created_by := NULL;
    END IF;
    IF (l_chdv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_chdv_rec.creation_date := NULL;
    END IF;
    IF (l_chdv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.last_updated_by := NULL;
    END IF;
    IF (l_chdv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_chdv_rec.last_update_date := NULL;
    END IF;
    IF (l_chdv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_chdv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_chdv_rec);
  END null_out_defaults;
  ----------------------------------------------------
  -- Validate_Attributes for: CURE_REFUND_HEADER_ID --
  ----------------------------------------------------
  PROCEDURE validate_cure_refund_header_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.cure_refund_header_id = OKL_API.G_MISS_NUM OR
        p_chdv_rec.cure_refund_header_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cure_refund_header_id');
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
  END validate_cure_refund_header_id;
  ---------------------------------------------------
  -- Validate_Attributes for: REFUND_HEADER_NUMBER --
  ---------------------------------------------------
  PROCEDURE validate_refund_header_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.refund_header_number = OKL_API.G_MISS_CHAR OR
        p_chdv_rec.refund_header_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'refund_header_number');
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
  END validate_refund_header_number;
  ------------------------------------------
  -- Validate_Attributes for: REFUND_TYPE --
  ------------------------------------------
  PROCEDURE validate_refund_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.refund_type = OKL_API.G_MISS_CHAR OR
        p_chdv_rec.refund_type IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'refund_type');
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
  END validate_refund_type;
  --------------------------------------------
  -- Validate_Attributes for: CURRENCY_CODE --
  --------------------------------------------
  PROCEDURE validate_currency_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.currency_code = OKL_API.G_MISS_CHAR OR
        p_chdv_rec.currency_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'currency_code');
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
  END validate_currency_code;
  -----------------------------------------------
  -- Validate_Attributes for: TOTAL_REFUND_DUE --
  -----------------------------------------------
  PROCEDURE validate_total_refund_due(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.total_refund_due = OKL_API.G_MISS_NUM OR
        p_chdv_rec.total_refund_due IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'total_refund_due');
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
  END validate_total_refund_due;
  --------------------------------------------------
  -- Validate_Attributes for: DISBURSEMENT_AMOUNT --
  --------------------------------------------------
  PROCEDURE validate_disbursement_amount(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.disbursement_amount = OKL_API.G_MISS_NUM OR
        p_chdv_rec.disbursement_amount IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'disbursement_amount');
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
  END validate_disbursement_amount;
  ---------------------------------------------
  -- Validate_Attributes for: VENDOR_SITE_ID --
  ---------------------------------------------
  PROCEDURE validate_vendor_site_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.vendor_site_id = OKL_API.G_MISS_NUM OR
        p_chdv_rec.vendor_site_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_site_id');
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
  END validate_vendor_site_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_chdv_rec.object_version_number = OKL_API.G_MISS_NUM OR
        p_chdv_rec.object_version_number IS NULL)
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
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKL_CURE_REFUND_HEADERS_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_chdv_rec                     IN chdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- cure_refund_header_id
    -- ***
    validate_cure_refund_header_id(x_return_status, p_chdv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- refund_header_number
    -- ***
    validate_refund_header_number(x_return_status, p_chdv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- refund_type
    -- ***
   /* validate_refund_type(x_return_status, p_chdv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
 */

    -- ***
    -- currency_code
    -- ***
    validate_currency_code(x_return_status, p_chdv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- total_refund_due
    -- ***
/*    validate_total_refund_due(x_return_status, p_chdv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
    -- ***
    -- disbursement_amount
    -- ***
/*    validate_disbursement_amount(x_return_status, p_chdv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
    -- ***
    -- vendor_site_id
    -- ***
    validate_vendor_site_id(x_return_status, p_chdv_rec);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_chdv_rec);
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
  ---------------------------------------------------
  -- Validate Record for:OKL_CURE_REFUND_HEADERS_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_chdv_rec IN chdv_rec_type,
    p_db_chdv_rec IN chdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_chdv_rec IN chdv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_chdv_rec                  chdv_rec_type := get_rec(p_chdv_rec);
  BEGIN
    l_return_status := Validate_Record(p_chdv_rec => p_chdv_rec,
                                       p_db_chdv_rec => l_db_chdv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN chdv_rec_type,
    p_to   IN OUT NOCOPY chd_rec_type
  ) IS
  BEGIN
    p_to.cure_refund_header_id := p_from.cure_refund_header_id;
    p_to.refund_header_number := p_from.refund_header_number;
    p_to.refund_type := p_from.refund_type;
    p_to.refund_due_date := p_from.refund_due_date;
    p_to.currency_code := p_from.currency_code;
    p_to.total_refund_due := p_from.total_refund_due;
    p_to.disbursement_amount := p_from.disbursement_amount;
    p_to.RECEIVED_AMOUNT := p_from.RECEIVED_AMOUNT;
    p_to.OFFSET_AMOUNT := p_from.OFFSET_AMOUNT;
    p_to.NEGOTIATED_AMOUNT := p_from.NEGOTIATED_AMOUNT;
    p_to.vendor_site_id := p_from.vendor_site_id;
    p_to.refund_status := p_from.refund_status;
    p_to.payment_method := p_from.payment_method;
    p_to.payment_term_id := p_from.payment_term_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.vendor_cure_due := p_from.vendor_cure_due;
    p_to.vendor_site_cure_due := p_from.vendor_site_cure_due;
    p_to.chr_id := p_from.chr_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.request_id := p_from.request_id;
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
  END migrate;
  PROCEDURE migrate (
    p_from IN chd_rec_type,
    p_to   IN OUT NOCOPY chdv_rec_type
  ) IS
  BEGIN
    p_to.cure_refund_header_id := p_from.cure_refund_header_id;
    p_to.refund_header_number := p_from.refund_header_number;
    p_to.refund_type := p_from.refund_type;
    p_to.refund_due_date := p_from.refund_due_date;
    p_to.currency_code := p_from.currency_code;
    p_to.total_refund_due := p_from.total_refund_due;
    p_to.disbursement_amount := p_from.disbursement_amount;
    p_to.RECEIVED_AMOUNT := p_from.RECEIVED_AMOUNT;
    p_to.OFFSET_AMOUNT := p_from.OFFSET_AMOUNT;
    p_to.NEGOTIATED_AMOUNT := p_from.NEGOTIATED_AMOUNT;
    p_to.vendor_site_id := p_from.vendor_site_id;
    p_to.refund_status := p_from.refund_status;
    p_to.payment_method := p_from.payment_method;
    p_to.payment_term_id := p_from.payment_term_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.vendor_cure_due := p_from.vendor_cure_due;
    p_to.vendor_site_cure_due := p_from.vendor_site_cure_due;
    p_to.chr_id := p_from.chr_id;
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
    p_from IN chdv_rec_type,
    p_to   IN OUT NOCOPY OklCureRefundHeadersTlRecType
  ) IS
  BEGIN
    p_to.cure_refund_header_id := p_from.cure_refund_header_id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN OklCureRefundHeadersTlRecType,
    p_to   IN OUT NOCOPY chdv_rec_type
  ) IS
  BEGIN
    p_to.cure_refund_header_id := p_from.cure_refund_header_id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- validate_row for:OKL_CURE_REFUND_HEADERS_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chdv_rec                     chdv_rec_type := p_chdv_rec;
    l_chd_rec                      chd_rec_type;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
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
    l_return_status := Validate_Attributes(l_chdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_chdv_rec);
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
  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CURE_REFUND_HEADERS_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      i := p_chdv_tbl.FIRST;
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
            p_chdv_rec                     => p_chdv_tbl(i));
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
        EXIT WHEN (i = p_chdv_tbl.LAST);
        i := p_chdv_tbl.NEXT(i);
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

  -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CURE_REFUND_HEADERS_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_chdv_tbl                     => p_chdv_tbl,
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
  ----------------------------------------------
  -- insert_row for:OKL_CURE_REFUND_HEADERS_B --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chd_rec                      IN chd_rec_type,
    x_chd_rec                      OUT NOCOPY chd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chd_rec                      chd_rec_type := p_chd_rec;
    l_def_chd_rec                  chd_rec_type;
    --------------------------------------------------
    -- Set_Attributes for:OKL_CURE_REFUND_HEADERS_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_chd_rec IN chd_rec_type,
      x_chd_rec OUT NOCOPY chd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_chd_rec := p_chd_rec;
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
      p_chd_rec,                         -- IN
      l_chd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CURE_REFUND_HEADERS_B(
      cure_refund_header_id,
      refund_header_number,
      refund_type,
      refund_due_date,
      currency_code,
      total_refund_due,
      disbursement_amount,
      RECEIVED_AMOUNT,
      OFFSET_AMOUNT,
      NEGOTIATED_AMOUNT,
      vendor_site_id,
      refund_status,
      payment_method,
      payment_term_id,
      object_version_number,
      vendor_cure_due,
      vendor_site_cure_due,
      chr_id,
      program_application_id,
      request_id,
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
      last_update_login)
    VALUES (
      l_chd_rec.cure_refund_header_id,
      l_chd_rec.refund_header_number,
      l_chd_rec.refund_type,
      l_chd_rec.refund_due_date,
      l_chd_rec.currency_code,
      l_chd_rec.total_refund_due,
      l_chd_rec.disbursement_amount,
      l_chd_rec.RECEIVED_AMOUNT,
      l_chd_rec.OFFSET_AMOUNT,
      l_chd_rec.NEGOTIATED_AMOUNT,
      l_chd_rec.vendor_site_id,
      l_chd_rec.refund_status,
      l_chd_rec.payment_method,
      l_chd_rec.payment_term_id,
      l_chd_rec.object_version_number,
      l_chd_rec.vendor_cure_due,
      l_chd_rec.vendor_site_cure_due,
      l_chd_rec.chr_id,
      l_chd_rec.program_application_id,
      l_chd_rec.request_id,
      l_chd_rec.program_id,
      l_chd_rec.program_update_date,
      l_chd_rec.attribute_category,
      l_chd_rec.attribute1,
      l_chd_rec.attribute2,
      l_chd_rec.attribute3,
      l_chd_rec.attribute4,
      l_chd_rec.attribute5,
      l_chd_rec.attribute6,
      l_chd_rec.attribute7,
      l_chd_rec.attribute8,
      l_chd_rec.attribute9,
      l_chd_rec.attribute10,
      l_chd_rec.attribute11,
      l_chd_rec.attribute12,
      l_chd_rec.attribute13,
      l_chd_rec.attribute14,
      l_chd_rec.attribute15,
      l_chd_rec.created_by,
      l_chd_rec.creation_date,
      l_chd_rec.last_updated_by,
      l_chd_rec.last_update_date,
      l_chd_rec.last_update_login);
    -- Set OUT values
    x_chd_rec := l_chd_rec;
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
  -----------------------------------------------
  -- insert_row for:OKL_CURE_REFUND_HEADERS_TL --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cure_refund_h182         IN OklCureRefundHeadersTlRecType,
    XOklCureRefundHeadersTlRec     OUT NOCOPY OklCureRefundHeadersTlRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType := p_okl_cure_refund_h182;
    LDefOklCureRefundHeadersTlRec  OklCureRefundHeadersTlRecType;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------------
    -- Set_Attributes for:OKL_CURE_REFUND_HEADERS_TL --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cure_refund_h182 IN OklCureRefundHeadersTlRecType,
      XOklCureRefundHeadersTlRec OUT NOCOPY OklCureRefundHeadersTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      XOklCureRefundHeadersTlRec := p_okl_cure_refund_h182;
      XOklCureRefundHeadersTlRec.LANGUAGE := USERENV('LANG');
      XOklCureRefundHeadersTlRec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_cure_refund_h182,            -- IN
      l_okl_cure_refund_h183);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_cure_refund_h183.language := l_lang_rec.language_code;
      INSERT INTO OKL_CURE_REFUND_HEADERS_TL(
        cure_refund_header_id,
        language,
        source_lang,
        sfwt_flag,
        description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okl_cure_refund_h183.cure_refund_header_id,
        l_okl_cure_refund_h183.language,
        l_okl_cure_refund_h183.source_lang,
        l_okl_cure_refund_h183.sfwt_flag,
        l_okl_cure_refund_h183.description,
        l_okl_cure_refund_h183.created_by,
        l_okl_cure_refund_h183.creation_date,
        l_okl_cure_refund_h183.last_updated_by,
        l_okl_cure_refund_h183.last_update_date,
        l_okl_cure_refund_h183.last_update_login);
    END LOOP;
    -- Set OUT values
    XOklCureRefundHeadersTlRec := l_okl_cure_refund_h183;
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
  -----------------------------------------------
  -- insert_row for :OKL_CURE_REFUND_HEADERS_V --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type,
    x_chdv_rec                     OUT NOCOPY chdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chdv_rec                     chdv_rec_type := p_chdv_rec;
    l_def_chdv_rec                 chdv_rec_type;
    l_chd_rec                      chd_rec_type;
    lx_chd_rec                     chd_rec_type;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
    LxOklCureRefundHeadersTlRec    OklCureRefundHeadersTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_chdv_rec IN chdv_rec_type
    ) RETURN chdv_rec_type IS
      l_chdv_rec chdv_rec_type := p_chdv_rec;
    BEGIN
      l_chdv_rec.CREATION_DATE := SYSDATE;
      l_chdv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_chdv_rec.LAST_UPDATE_DATE := l_chdv_rec.CREATION_DATE;
      l_chdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_chdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_chdv_rec);
    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKL_CURE_REFUND_HEADERS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_chdv_rec IN chdv_rec_type,
      x_chdv_rec OUT NOCOPY chdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_chdv_rec := p_chdv_rec;
      x_chdv_rec.OBJECT_VERSION_NUMBER := 1;
      x_chdv_rec.SFWT_FLAG := 'N';
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
    l_chdv_rec := null_out_defaults(p_chdv_rec);
    -- Set primary key value
    l_chdv_rec.CURE_REFUND_HEADER_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_chdv_rec,                        -- IN
      l_def_chdv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_chdv_rec := fill_who_columns(l_def_chdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_chdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_chdv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_chdv_rec, l_chd_rec);
    migrate(l_def_chdv_rec, l_okl_cure_refund_h183);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_chd_rec,
      lx_chd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_chd_rec, l_def_chdv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cure_refund_h183,
      LxOklCureRefundHeadersTlRec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOklCureRefundHeadersTlRec, l_def_chdv_rec);
    -- Set OUT values
    x_chdv_rec := l_def_chdv_rec;
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
  -- PL/SQL TBL insert_row for:CHDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      i := p_chdv_tbl.FIRST;
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
            p_chdv_rec                     => p_chdv_tbl(i),
            x_chdv_rec                     => x_chdv_tbl(i));
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
        EXIT WHEN (i = p_chdv_tbl.LAST);
        i := p_chdv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:CHDV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_chdv_tbl                     => p_chdv_tbl,
        x_chdv_tbl                     => x_chdv_tbl,
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
  --------------------------------------------
  -- lock_row for:OKL_CURE_REFUND_HEADERS_B --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chd_rec                      IN chd_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_chd_rec IN chd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CURE_REFUND_HEADERS_B
     WHERE CURE_REFUND_HEADER_ID = p_chd_rec.cure_refund_header_id
       AND OBJECT_VERSION_NUMBER = p_chd_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_chd_rec IN chd_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CURE_REFUND_HEADERS_B
     WHERE CURE_REFUND_HEADER_ID = p_chd_rec.cure_refund_header_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CURE_REFUND_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CURE_REFUND_HEADERS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_chd_rec);
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
      OPEN lchk_csr(p_chd_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_chd_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_chd_rec.object_version_number THEN
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
  ---------------------------------------------
  -- lock_row for:OKL_CURE_REFUND_HEADERS_TL --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cure_refund_h182         IN OklCureRefundHeadersTlRecType) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_cure_refund_h182 IN OklCureRefundHeadersTlRecType) IS
    SELECT *
      FROM OKL_CURE_REFUND_HEADERS_TL
     WHERE CURE_REFUND_HEADER_ID = p_okl_cure_refund_h182.cure_refund_header_id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                     lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_okl_cure_refund_h182);
      FETCH lock_csr INTO l_lock_var;
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
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
  ---------------------------------------------
  -- lock_row for: OKL_CURE_REFUND_HEADERS_V --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chd_rec                      chd_rec_type;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
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
    migrate(p_chdv_rec, l_chd_rec);
    migrate(p_chdv_rec, l_okl_cure_refund_h183);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_chd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cure_refund_h183
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
  -- PL/SQL TBL lock_row for:CHDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      i := p_chdv_tbl.FIRST;
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
            p_chdv_rec                     => p_chdv_tbl(i));
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
        EXIT WHEN (i = p_chdv_tbl.LAST);
        i := p_chdv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:CHDV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_chdv_tbl                     => p_chdv_tbl,
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
  ----------------------------------------------
  -- update_row for:OKL_CURE_REFUND_HEADERS_B --
  ----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chd_rec                      IN chd_rec_type,
    x_chd_rec                      OUT NOCOPY chd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chd_rec                      chd_rec_type := p_chd_rec;
    l_def_chd_rec                  chd_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_chd_rec IN chd_rec_type,
      x_chd_rec OUT NOCOPY chd_rec_type
    ) RETURN VARCHAR2 IS
      l_chd_rec                      chd_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_chd_rec := p_chd_rec;
      -- Get current database values
      l_chd_rec := get_rec(p_chd_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_chd_rec.cure_refund_header_id = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.cure_refund_header_id := l_chd_rec.cure_refund_header_id;
        END IF;
        IF (x_chd_rec.refund_header_number = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.refund_header_number := l_chd_rec.refund_header_number;
        END IF;
        IF (x_chd_rec.refund_type = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.refund_type := l_chd_rec.refund_type;
        END IF;
        IF (x_chd_rec.refund_due_date = OKL_API.G_MISS_DATE)
        THEN
          x_chd_rec.refund_due_date := l_chd_rec.refund_due_date;
        END IF;
        IF (x_chd_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.currency_code := l_chd_rec.currency_code;
        END IF;
        IF (x_chd_rec.total_refund_due = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.total_refund_due := l_chd_rec.total_refund_due;
        END IF;
        IF (x_chd_rec.disbursement_amount = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.disbursement_amount := l_chd_rec.disbursement_amount;
        END IF;
        IF (x_chd_rec.RECEIVED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.RECEIVED_AMOUNT := l_chd_rec.RECEIVED_AMOUNT;
        END IF;
        IF (x_chd_rec.OFFSET_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.OFFSET_AMOUNT := l_chd_rec.OFFSET_AMOUNT;
        END IF;
        IF (x_chd_rec.NEGOTIATED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.NEGOTIATED_AMOUNT := l_chd_rec.NEGOTIATED_AMOUNT;
        END IF;
        IF (x_chd_rec.vendor_site_id = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.vendor_site_id := l_chd_rec.vendor_site_id;
        END IF;
        IF (x_chd_rec.refund_status = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.refund_status := l_chd_rec.refund_status;
        END IF;
        IF (x_chd_rec.payment_method = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.payment_method := l_chd_rec.payment_method;
        END IF;
        IF (x_chd_rec.payment_term_id = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.payment_term_id := l_chd_rec.payment_term_id;
        END IF;
        IF (x_chd_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.object_version_number := l_chd_rec.object_version_number;
        END IF;
        IF (x_chd_rec.vendor_cure_due = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.vendor_cure_due := l_chd_rec.vendor_cure_due;
        END IF;
        IF (x_chd_rec.vendor_site_cure_due = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.vendor_site_cure_due := l_chd_rec.vendor_site_cure_due;
        END IF;
        IF (x_chd_rec.chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.chr_id := l_chd_rec.chr_id;
        END IF;
        IF (x_chd_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.program_application_id := l_chd_rec.program_application_id;
        END IF;
        IF (x_chd_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.request_id := l_chd_rec.request_id;
        END IF;
        IF (x_chd_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.program_id := l_chd_rec.program_id;
        END IF;
        IF (x_chd_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_chd_rec.program_update_date := l_chd_rec.program_update_date;
        END IF;
        IF (x_chd_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute_category := l_chd_rec.attribute_category;
        END IF;
        IF (x_chd_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute1 := l_chd_rec.attribute1;
        END IF;
        IF (x_chd_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute2 := l_chd_rec.attribute2;
        END IF;
        IF (x_chd_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute3 := l_chd_rec.attribute3;
        END IF;
        IF (x_chd_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute4 := l_chd_rec.attribute4;
        END IF;
        IF (x_chd_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute5 := l_chd_rec.attribute5;
        END IF;
        IF (x_chd_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute6 := l_chd_rec.attribute6;
        END IF;
        IF (x_chd_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute7 := l_chd_rec.attribute7;
        END IF;
        IF (x_chd_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute8 := l_chd_rec.attribute8;
        END IF;
        IF (x_chd_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute9 := l_chd_rec.attribute9;
        END IF;
        IF (x_chd_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute10 := l_chd_rec.attribute10;
        END IF;
        IF (x_chd_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute11 := l_chd_rec.attribute11;
        END IF;
        IF (x_chd_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute12 := l_chd_rec.attribute12;
        END IF;
        IF (x_chd_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute13 := l_chd_rec.attribute13;
        END IF;
        IF (x_chd_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute14 := l_chd_rec.attribute14;
        END IF;
        IF (x_chd_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_chd_rec.attribute15 := l_chd_rec.attribute15;
        END IF;
        IF (x_chd_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.created_by := l_chd_rec.created_by;
        END IF;
        IF (x_chd_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_chd_rec.creation_date := l_chd_rec.creation_date;
        END IF;
        IF (x_chd_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.last_updated_by := l_chd_rec.last_updated_by;
        END IF;
        IF (x_chd_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_chd_rec.last_update_date := l_chd_rec.last_update_date;
        END IF;
        IF (x_chd_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_chd_rec.last_update_login := l_chd_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_CURE_REFUND_HEADERS_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_chd_rec IN chd_rec_type,
      x_chd_rec OUT NOCOPY chd_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_chd_rec := p_chd_rec;
      x_chd_rec.OBJECT_VERSION_NUMBER := p_chd_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_chd_rec,                         -- IN
      l_chd_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_chd_rec, l_def_chd_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CURE_REFUND_HEADERS_B
    SET REFUND_HEADER_NUMBER = l_def_chd_rec.refund_header_number,
        REFUND_TYPE = l_def_chd_rec.refund_type,
        REFUND_DUE_DATE = l_def_chd_rec.refund_due_date,
        CURRENCY_CODE = l_def_chd_rec.currency_code,
        TOTAL_REFUND_DUE = l_def_chd_rec.total_refund_due,
        DISBURSEMENT_AMOUNT = l_def_chd_rec.disbursement_amount,
        RECEIVED_AMOUNT = l_def_chd_rec.RECEIVED_AMOUNT,
        OFFSET_AMOUNT = l_def_chd_rec.OFFSET_AMOUNT,
        NEGOTIATED_AMOUNT = l_def_chd_rec.NEGOTIATED_AMOUNT,
        VENDOR_SITE_ID = l_def_chd_rec.vendor_site_id,
        REFUND_STATUS = l_def_chd_rec.refund_status,
        PAYMENT_METHOD = l_def_chd_rec.payment_method,
        PAYMENT_TERM_ID = l_def_chd_rec.payment_term_id,
        OBJECT_VERSION_NUMBER = l_def_chd_rec.object_version_number,
        VENDOR_CURE_DUE = l_def_chd_rec.vendor_cure_due,
        VENDOR_SITE_CURE_DUE = l_def_chd_rec.vendor_site_cure_due,
        CHR_ID = l_def_chd_rec.chr_id,
        PROGRAM_APPLICATION_ID = l_def_chd_rec.program_application_id,
        REQUEST_ID = l_def_chd_rec.request_id,
        PROGRAM_ID = l_def_chd_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_chd_rec.program_update_date,
        ATTRIBUTE_CATEGORY = l_def_chd_rec.attribute_category,
        ATTRIBUTE1 = l_def_chd_rec.attribute1,
        ATTRIBUTE2 = l_def_chd_rec.attribute2,
        ATTRIBUTE3 = l_def_chd_rec.attribute3,
        ATTRIBUTE4 = l_def_chd_rec.attribute4,
        ATTRIBUTE5 = l_def_chd_rec.attribute5,
        ATTRIBUTE6 = l_def_chd_rec.attribute6,
        ATTRIBUTE7 = l_def_chd_rec.attribute7,
        ATTRIBUTE8 = l_def_chd_rec.attribute8,
        ATTRIBUTE9 = l_def_chd_rec.attribute9,
        ATTRIBUTE10 = l_def_chd_rec.attribute10,
        ATTRIBUTE11 = l_def_chd_rec.attribute11,
        ATTRIBUTE12 = l_def_chd_rec.attribute12,
        ATTRIBUTE13 = l_def_chd_rec.attribute13,
        ATTRIBUTE14 = l_def_chd_rec.attribute14,
        ATTRIBUTE15 = l_def_chd_rec.attribute15,
        CREATED_BY = l_def_chd_rec.created_by,
        CREATION_DATE = l_def_chd_rec.creation_date,
        LAST_UPDATED_BY = l_def_chd_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_chd_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_chd_rec.last_update_login
    WHERE CURE_REFUND_HEADER_ID = l_def_chd_rec.cure_refund_header_id;

    x_chd_rec := l_chd_rec;
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
  -- update_row for:OKL_CURE_REFUND_HEADERS_TL --
  -----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cure_refund_h182         IN OklCureRefundHeadersTlRecType,
    XOklCureRefundHeadersTlRec     OUT NOCOPY OklCureRefundHeadersTlRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType := p_okl_cure_refund_h182;
    LDefOklCureRefundHeadersTlRec  OklCureRefundHeadersTlRecType;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_cure_refund_h182 IN OklCureRefundHeadersTlRecType,
      XOklCureRefundHeadersTlRec OUT NOCOPY OklCureRefundHeadersTlRecType
    ) RETURN VARCHAR2 IS
      l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      XOklCureRefundHeadersTlRec := p_okl_cure_refund_h182;
      -- Get current database values
      l_okl_cure_refund_h183 := get_rec(p_okl_cure_refund_h182, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (XOklCureRefundHeadersTlRec.cure_refund_header_id = OKL_API.G_MISS_NUM)
        THEN
          XOklCureRefundHeadersTlRec.cure_refund_header_id := l_okl_cure_refund_h183.cure_refund_header_id;
        END IF;
        IF (XOklCureRefundHeadersTlRec.language = OKL_API.G_MISS_CHAR)
        THEN
          XOklCureRefundHeadersTlRec.language := l_okl_cure_refund_h183.language;
        END IF;
        IF (XOklCureRefundHeadersTlRec.source_lang = OKL_API.G_MISS_CHAR)
        THEN
          XOklCureRefundHeadersTlRec.source_lang := l_okl_cure_refund_h183.source_lang;
        END IF;
        IF (XOklCureRefundHeadersTlRec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          XOklCureRefundHeadersTlRec.sfwt_flag := l_okl_cure_refund_h183.sfwt_flag;
        END IF;
        IF (XOklCureRefundHeadersTlRec.description = OKL_API.G_MISS_CHAR)
        THEN
          XOklCureRefundHeadersTlRec.description := l_okl_cure_refund_h183.description;
        END IF;
        IF (XOklCureRefundHeadersTlRec.created_by = OKL_API.G_MISS_NUM)
        THEN
          XOklCureRefundHeadersTlRec.created_by := l_okl_cure_refund_h183.created_by;
        END IF;
        IF (XOklCureRefundHeadersTlRec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          XOklCureRefundHeadersTlRec.creation_date := l_okl_cure_refund_h183.creation_date;
        END IF;
        IF (XOklCureRefundHeadersTlRec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          XOklCureRefundHeadersTlRec.last_updated_by := l_okl_cure_refund_h183.last_updated_by;
        END IF;
        IF (XOklCureRefundHeadersTlRec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          XOklCureRefundHeadersTlRec.last_update_date := l_okl_cure_refund_h183.last_update_date;
        END IF;
        IF (XOklCureRefundHeadersTlRec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          XOklCureRefundHeadersTlRec.last_update_login := l_okl_cure_refund_h183.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_CURE_REFUND_HEADERS_TL --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_cure_refund_h182 IN OklCureRefundHeadersTlRecType,
      XOklCureRefundHeadersTlRec OUT NOCOPY OklCureRefundHeadersTlRecType
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      XOklCureRefundHeadersTlRec := p_okl_cure_refund_h182;
      XOklCureRefundHeadersTlRec.LANGUAGE := USERENV('LANG');
      XOklCureRefundHeadersTlRec.LANGUAGE := USERENV('LANG');
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
      p_okl_cure_refund_h182,            -- IN
      l_okl_cure_refund_h183);           -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_cure_refund_h183, LDefOklCureRefundHeadersTlRec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CURE_REFUND_HEADERS_TL
    SET DESCRIPTION = LDefOklCureRefundHeadersTlRec.description,
        CREATED_BY = LDefOklCureRefundHeadersTlRec.created_by,
        CREATION_DATE = LDefOklCureRefundHeadersTlRec.creation_date,
        LAST_UPDATED_BY = LDefOklCureRefundHeadersTlRec.last_updated_by,
        LAST_UPDATE_DATE = LDefOklCureRefundHeadersTlRec.last_update_date,
        LAST_UPDATE_LOGIN = LDefOklCureRefundHeadersTlRec.last_update_login,
-- introduced for bug 3631702
        SOURCE_LANG = LDefOklCureRefundHeadersTlRec.SOURCE_LANG
    WHERE CURE_REFUND_HEADER_ID = LDefOklCureRefundHeadersTlRec.cure_refund_header_id
      AND USERENV('LANG') IN (SOURCE_LANG, LANGUAGE);
--      AND SOURCE_LANG = USERENV('LANG'); commented out for bug 3631702

    UPDATE OKL_CURE_REFUND_HEADERS_TL
    SET SFWT_FLAG = 'Y'
    WHERE CURE_REFUND_HEADER_ID = LDefOklCureRefundHeadersTlRec.cure_refund_header_id
      AND SOURCE_LANG <> USERENV('LANG');

    XOklCureRefundHeadersTlRec := l_okl_cure_refund_h183;
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
  ----------------------------------------------
  -- update_row for:OKL_CURE_REFUND_HEADERS_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type,
    x_chdv_rec                     OUT NOCOPY chdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chdv_rec                     chdv_rec_type := p_chdv_rec;
    l_def_chdv_rec                 chdv_rec_type;
    l_db_chdv_rec                  chdv_rec_type;
    l_chd_rec                      chd_rec_type;
    lx_chd_rec                     chd_rec_type;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
    LxOklCureRefundHeadersTlRec    OklCureRefundHeadersTlRecType;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_chdv_rec IN chdv_rec_type
    ) RETURN chdv_rec_type IS
      l_chdv_rec chdv_rec_type := p_chdv_rec;
    BEGIN
      l_chdv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_chdv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_chdv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_chdv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_chdv_rec IN chdv_rec_type,
      x_chdv_rec OUT NOCOPY chdv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_chdv_rec := p_chdv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_chdv_rec := get_rec(p_chdv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_chdv_rec.cure_refund_header_id = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.cure_refund_header_id := l_db_chdv_rec.cure_refund_header_id;
        END IF;
        IF (x_chdv_rec.refund_header_number = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.refund_header_number := l_db_chdv_rec.refund_header_number;
        END IF;
        IF (x_chdv_rec.refund_type = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.refund_type := l_db_chdv_rec.refund_type;
        END IF;
        IF (x_chdv_rec.refund_due_date = OKL_API.G_MISS_DATE)
        THEN
          x_chdv_rec.refund_due_date := l_db_chdv_rec.refund_due_date;
        END IF;
        IF (x_chdv_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.currency_code := l_db_chdv_rec.currency_code;
        END IF;
        IF (x_chdv_rec.total_refund_due = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.total_refund_due := l_db_chdv_rec.total_refund_due;
        END IF;
        IF (x_chdv_rec.disbursement_amount = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.disbursement_amount := l_db_chdv_rec.disbursement_amount;
        END IF;
        IF (x_chdv_rec.RECEIVED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.RECEIVED_AMOUNT := l_db_chdv_rec.RECEIVED_AMOUNT;
        END IF;
        IF (x_chdv_rec.OFFSET_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.OFFSET_AMOUNT := l_db_chdv_rec.OFFSET_AMOUNT;
        END IF;
        IF (x_chdv_rec.NEGOTIATED_AMOUNT = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.NEGOTIATED_AMOUNT := l_db_chdv_rec.NEGOTIATED_AMOUNT;
        END IF;
        IF (x_chdv_rec.vendor_site_id = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.vendor_site_id := l_db_chdv_rec.vendor_site_id;
        END IF;
        IF (x_chdv_rec.refund_status = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.refund_status := l_db_chdv_rec.refund_status;
        END IF;
        IF (x_chdv_rec.payment_method = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.payment_method := l_db_chdv_rec.payment_method;
        END IF;
        IF (x_chdv_rec.payment_term_id = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.payment_term_id := l_db_chdv_rec.payment_term_id;
        END IF;
        IF (x_chdv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.sfwt_flag := l_db_chdv_rec.sfwt_flag;
        END IF;
        IF (x_chdv_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.description := l_db_chdv_rec.description;
        END IF;
        IF (x_chdv_rec.vendor_cure_due = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.vendor_cure_due := l_db_chdv_rec.vendor_cure_due;
        END IF;
        IF (x_chdv_rec.vendor_site_cure_due = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.vendor_site_cure_due := l_db_chdv_rec.vendor_site_cure_due;
        END IF;
        IF (x_chdv_rec.chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.chr_id := l_db_chdv_rec.chr_id;
        END IF;
        IF (x_chdv_rec.program_id = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.program_id := l_db_chdv_rec.program_id;
        END IF;
        IF (x_chdv_rec.request_id = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.request_id := l_db_chdv_rec.request_id;
        END IF;
        IF (x_chdv_rec.program_application_id = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.program_application_id := l_db_chdv_rec.program_application_id;
        END IF;
        IF (x_chdv_rec.program_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_chdv_rec.program_update_date := l_db_chdv_rec.program_update_date;
        END IF;
        IF (x_chdv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute_category := l_db_chdv_rec.attribute_category;
        END IF;
        IF (x_chdv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute1 := l_db_chdv_rec.attribute1;
        END IF;
        IF (x_chdv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute2 := l_db_chdv_rec.attribute2;
        END IF;
        IF (x_chdv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute3 := l_db_chdv_rec.attribute3;
        END IF;
        IF (x_chdv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute4 := l_db_chdv_rec.attribute4;
        END IF;
        IF (x_chdv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute5 := l_db_chdv_rec.attribute5;
        END IF;
        IF (x_chdv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute6 := l_db_chdv_rec.attribute6;
        END IF;
        IF (x_chdv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute7 := l_db_chdv_rec.attribute7;
        END IF;
        IF (x_chdv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute8 := l_db_chdv_rec.attribute8;
        END IF;
        IF (x_chdv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute9 := l_db_chdv_rec.attribute9;
        END IF;
        IF (x_chdv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute10 := l_db_chdv_rec.attribute10;
        END IF;
        IF (x_chdv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute11 := l_db_chdv_rec.attribute11;
        END IF;
        IF (x_chdv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute12 := l_db_chdv_rec.attribute12;
        END IF;
        IF (x_chdv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute13 := l_db_chdv_rec.attribute13;
        END IF;
        IF (x_chdv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute14 := l_db_chdv_rec.attribute14;
        END IF;
        IF (x_chdv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_chdv_rec.attribute15 := l_db_chdv_rec.attribute15;
        END IF;
        IF (x_chdv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.created_by := l_db_chdv_rec.created_by;
        END IF;
        IF (x_chdv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_chdv_rec.creation_date := l_db_chdv_rec.creation_date;
        END IF;
        IF (x_chdv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.last_updated_by := l_db_chdv_rec.last_updated_by;
        END IF;
        IF (x_chdv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_chdv_rec.last_update_date := l_db_chdv_rec.last_update_date;
        END IF;
        IF (x_chdv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_chdv_rec.last_update_login := l_db_chdv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_CURE_REFUND_HEADERS_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_chdv_rec IN chdv_rec_type,
      x_chdv_rec OUT NOCOPY chdv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_chdv_rec := p_chdv_rec;
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
      p_chdv_rec,                        -- IN
      x_chdv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_chdv_rec, l_def_chdv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_chdv_rec := fill_who_columns(l_def_chdv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_chdv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_chdv_rec, l_db_chdv_rec);
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
      p_chdv_rec                     => p_chdv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_chdv_rec, l_chd_rec);
    migrate(l_def_chdv_rec, l_okl_cure_refund_h183);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_chd_rec,
      lx_chd_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_chd_rec, l_def_chdv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cure_refund_h183,
      LxOklCureRefundHeadersTlRec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(LxOklCureRefundHeadersTlRec, l_def_chdv_rec);
    x_chdv_rec := l_def_chdv_rec;
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
  -- PL/SQL TBL update_row for:chdv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      i := p_chdv_tbl.FIRST;
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
            p_chdv_rec                     => p_chdv_tbl(i),
            x_chdv_rec                     => x_chdv_tbl(i));
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
        EXIT WHEN (i = p_chdv_tbl.LAST);
        i := p_chdv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:CHDV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    x_chdv_tbl                     OUT NOCOPY chdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_chdv_tbl                     => p_chdv_tbl,
        x_chdv_tbl                     => x_chdv_tbl,
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
  ----------------------------------------------
  -- delete_row for:OKL_CURE_REFUND_HEADERS_B --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chd_rec                      IN chd_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chd_rec                      chd_rec_type := p_chd_rec;
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

    DELETE FROM OKL_CURE_REFUND_HEADERS_B
     WHERE CURE_REFUND_HEADER_ID = p_chd_rec.cure_refund_header_id;

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
  -- delete_row for:OKL_CURE_REFUND_HEADERS_TL --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_cure_refund_h182         IN OklCureRefundHeadersTlRecType) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType := p_okl_cure_refund_h182;
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

    DELETE FROM OKL_CURE_REFUND_HEADERS_TL
     WHERE CURE_REFUND_HEADER_ID = p_okl_cure_refund_h182.cure_refund_header_id;

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
  ----------------------------------------------
  -- delete_row for:OKL_CURE_REFUND_HEADERS_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_rec                     IN chdv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_chdv_rec                     chdv_rec_type := p_chdv_rec;
    l_okl_cure_refund_h183         OklCureRefundHeadersTlRecType;
    l_chd_rec                      chd_rec_type;
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
    migrate(l_chdv_rec, l_okl_cure_refund_h183);
    migrate(l_chdv_rec, l_chd_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_cure_refund_h183
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_chd_rec
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
  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CURE_REFUND_HEADERS_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      i := p_chdv_tbl.FIRST;
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
            p_chdv_rec                     => p_chdv_tbl(i));
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
        EXIT WHEN (i = p_chdv_tbl.LAST);
        i := p_chdv_tbl.NEXT(i);
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

  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CURE_REFUND_HEADERS_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chdv_tbl                     IN chdv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_chdv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_chdv_tbl                     => p_chdv_tbl,
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

END OKL_CHD_PVT;

/
