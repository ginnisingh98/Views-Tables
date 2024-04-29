--------------------------------------------------------
--  DDL for Package Body OKS_PBR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_PBR_PVT" AS
/* $Header: OKSSPBRB.pls 120.0 2005/05/25 18:33:26 appldev noship $ */
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
  -- FUNCTION get_rec for: OKS_PRICE_BREAKS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pbrv_rec                     IN pbrv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pbrv_rec_type IS
    CURSOR oks_pbrv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            BSL_ID,
            BCL_ID,
            CLE_ID,
            CHR_ID,
            LINE_DETAIL_INDEX,
            LINE_INDEX,
            PRICING_CONTEXT,
            PRICING_METHOD,
            QUANTITY_FROM,
            QUANTITY_TO,
            QUANTITY,
            BREAK_UOM,
            PRORATE,
            UNIT_PRICE,
            AMOUNT,
            PRICE_LIST_ID,
            VALIDATED_FLAG,
            STATUS_CODE,
            STATUS_TEXT,
            LOCK_FLAG,
            LOCKED_PRICE_LIST_ID,
            LOCKED_PRICE_LIST_LINE_ID,
            PRICE_LIST_LINE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_Price_Breaks_V
     WHERE oks_price_breaks_v.id = p_id;
    l_oks_pbrv_pk                  oks_pbrv_pk_csr%ROWTYPE;
    l_pbrv_rec                     pbrv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_pbrv_pk_csr (p_pbrv_rec.id);
    FETCH oks_pbrv_pk_csr INTO
              l_pbrv_rec.id,
              l_pbrv_rec.bsl_id,
              l_pbrv_rec.bcl_id,
              l_pbrv_rec.cle_id,
              l_pbrv_rec.chr_id,
              l_pbrv_rec.line_detail_index,
              l_pbrv_rec.line_index,
              l_pbrv_rec.pricing_context,
              l_pbrv_rec.pricing_method,
              l_pbrv_rec.quantity_from,
              l_pbrv_rec.quantity_to,
              l_pbrv_rec.quantity,
              l_pbrv_rec.break_uom,
              l_pbrv_rec.prorate,
              l_pbrv_rec.unit_price,
              l_pbrv_rec.amount,
              l_pbrv_rec.price_list_id,
              l_pbrv_rec.validated_flag,
              l_pbrv_rec.status_code,
              l_pbrv_rec.status_text,
              l_pbrv_rec.lock_flag,
              l_pbrv_rec.locked_price_list_id,
              l_pbrv_rec.locked_price_list_line_id,
              l_pbrv_rec.price_list_line_id,
              l_pbrv_rec.object_version_number,
              l_pbrv_rec.created_by,
              l_pbrv_rec.creation_date,
              l_pbrv_rec.last_updated_by,
              l_pbrv_rec.last_update_date,
              l_pbrv_rec.last_update_login;
    x_no_data_found := oks_pbrv_pk_csr%NOTFOUND;
    CLOSE oks_pbrv_pk_csr;
    RETURN(l_pbrv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pbrv_rec                     IN pbrv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pbrv_rec_type IS
    l_pbrv_rec                     pbrv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_pbrv_rec := get_rec(p_pbrv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pbrv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pbrv_rec                     IN pbrv_rec_type
  ) RETURN pbrv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pbrv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_PRICE_BREAKS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pbr_rec                      IN pbr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pbr_rec_type IS
    CURSOR oks_price_breaks_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            BSL_ID,
            BCL_ID,
            CLE_ID,
            CHR_ID,
            LINE_DETAIL_INDEX,
            LINE_INDEX,
            PRICING_CONTEXT,
            PRICING_METHOD,
            QUANTITY_FROM,
            QUANTITY_TO,
            QUANTITY,
            BREAK_UOM,
            PRORATE,
            UNIT_PRICE,
            AMOUNT,
            PRICE_LIST_ID,
            VALIDATED_FLAG,
            STATUS_CODE,
            STATUS_TEXT,
            LOCK_FLAG,
            LOCKED_PRICE_LIST_ID,
            LOCKED_PRICE_LIST_LINE_ID,
            PRICE_LIST_LINE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_Price_Breaks
     WHERE oks_price_breaks.id  = p_id;
    l_oks_price_breaks_pk          oks_price_breaks_pk_csr%ROWTYPE;
    l_pbr_rec                      pbr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_price_breaks_pk_csr (p_pbr_rec.id);
    FETCH oks_price_breaks_pk_csr INTO
              l_pbr_rec.id,
              l_pbr_rec.bsl_id,
              l_pbr_rec.bcl_id,
              l_pbr_rec.cle_id,
              l_pbr_rec.chr_id,
              l_pbr_rec.line_detail_index,
              l_pbr_rec.line_index,
              l_pbr_rec.pricing_context,
              l_pbr_rec.pricing_method,
              l_pbr_rec.quantity_from,
              l_pbr_rec.quantity_to,
              l_pbr_rec.quantity,
              l_pbr_rec.break_uom,
              l_pbr_rec.prorate,
              l_pbr_rec.unit_price,
              l_pbr_rec.amount,
              l_pbr_rec.price_list_id,
              l_pbr_rec.validated_flag,
              l_pbr_rec.status_code,
              l_pbr_rec.status_text,
              l_pbr_rec.lock_flag,
              l_pbr_rec.locked_price_list_id,
              l_pbr_rec.locked_price_list_line_id,
              l_pbr_rec.price_list_line_id,
              l_pbr_rec.object_version_number,
              l_pbr_rec.created_by,
              l_pbr_rec.creation_date,
              l_pbr_rec.last_updated_by,
              l_pbr_rec.last_update_date,
              l_pbr_rec.last_update_login;
    x_no_data_found := oks_price_breaks_pk_csr%NOTFOUND;
    CLOSE oks_price_breaks_pk_csr;
    RETURN(l_pbr_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_pbr_rec                      IN pbr_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN pbr_rec_type IS
    l_pbr_rec                      pbr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_pbr_rec := get_rec(p_pbr_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_pbr_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_pbr_rec                      IN pbr_rec_type
  ) RETURN pbr_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pbr_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_PRICE_BREAKS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pbrv_rec   IN pbrv_rec_type
  ) RETURN pbrv_rec_type IS
    l_pbrv_rec                     pbrv_rec_type := p_pbrv_rec;
  BEGIN
    IF (l_pbrv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.id := NULL;
    END IF;
    IF (l_pbrv_rec.bsl_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.bsl_id := NULL;
    END IF;
    IF (l_pbrv_rec.bcl_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.bcl_id := NULL;
    END IF;
    IF (l_pbrv_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.cle_id := NULL;
    END IF;
    IF (l_pbrv_rec.chr_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.chr_id := NULL;
    END IF;
    IF (l_pbrv_rec.line_detail_index = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.line_detail_index := NULL;
    END IF;
    IF (l_pbrv_rec.line_index = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.line_index := NULL;
    END IF;
    IF (l_pbrv_rec.pricing_context = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.pricing_context := NULL;
    END IF;
    IF (l_pbrv_rec.pricing_method = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.pricing_method := NULL;
    END IF;
    IF (l_pbrv_rec.quantity_from = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.quantity_from := NULL;
    END IF;
    IF (l_pbrv_rec.quantity_to = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.quantity_to := NULL;
    END IF;
    IF (l_pbrv_rec.quantity = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.quantity := NULL;
    END IF;
    IF (l_pbrv_rec.break_uom = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.break_uom := NULL;
    END IF;
    IF (l_pbrv_rec.prorate = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.prorate := NULL;
    END IF;
    IF (l_pbrv_rec.unit_price = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.unit_price := NULL;
    END IF;
    IF (l_pbrv_rec.amount = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.amount := NULL;
    END IF;
    IF (l_pbrv_rec.price_list_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.price_list_id := NULL;
    END IF;
    IF (l_pbrv_rec.validated_flag = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.validated_flag := NULL;
    END IF;
    IF (l_pbrv_rec.status_code = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.status_code := NULL;
    END IF;
    IF (l_pbrv_rec.status_text = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.status_text := NULL;
    END IF;
    IF (l_pbrv_rec.lock_flag = OKC_API.G_MISS_CHAR ) THEN
      l_pbrv_rec.lock_flag := NULL;
    END IF;
    IF (l_pbrv_rec.locked_price_list_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.locked_price_list_id := NULL;
    END IF;
    IF (l_pbrv_rec.locked_price_list_line_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.locked_price_list_line_id := NULL;
    END IF;
    IF (l_pbrv_rec.price_list_line_id = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.price_list_line_id := NULL;
    END IF;
    IF (l_pbrv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.object_version_number := NULL;
    END IF;
    IF (l_pbrv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.created_by := NULL;
    END IF;
    IF (l_pbrv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_pbrv_rec.creation_date := NULL;
    END IF;
    IF (l_pbrv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pbrv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_pbrv_rec.last_update_date := NULL;
    END IF;
    IF (l_pbrv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_pbrv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_pbrv_rec);
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
  ------------------------------------------------
  -- Validate_Attributes for:OKS_PRICE_BREAKS_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pbrv_rec                     IN pbrv_rec_type
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
    validate_id(x_return_status, p_pbrv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_pbrv_rec.object_version_number);
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
  --------------------------------------------
  -- Validate Record for:OKS_PRICE_BREAKS_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_pbrv_rec IN pbrv_rec_type,
    p_db_pbrv_rec IN pbrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_pbrv_rec IN pbrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_pbrv_rec                  pbrv_rec_type := get_rec(p_pbrv_rec);
  BEGIN
    l_return_status := Validate_Record(p_pbrv_rec => p_pbrv_rec,
                                       p_db_pbrv_rec => l_db_pbrv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN pbrv_rec_type,
    p_to   IN OUT NOCOPY pbr_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.line_detail_index := p_from.line_detail_index;
    p_to.line_index := p_from.line_index;
    p_to.pricing_context := p_from.pricing_context;
    p_to.pricing_method := p_from.pricing_method;
    p_to.quantity_from := p_from.quantity_from;
    p_to.quantity_to := p_from.quantity_to;
    p_to.quantity := p_from.quantity;
    p_to.break_uom := p_from.break_uom;
    p_to.prorate := p_from.prorate;
    p_to.unit_price := p_from.unit_price;
    p_to.amount := p_from.amount;
    p_to.price_list_id := p_from.price_list_id;
    p_to.validated_flag := p_from.validated_flag;
    p_to.status_code := p_from.status_code;
    p_to.status_text := p_from.status_text;
    p_to.lock_flag := p_from.lock_flag;
    p_to.locked_price_list_id := p_from.locked_price_list_id;
    p_to.locked_price_list_line_id := p_from.locked_price_list_line_id;
    p_to.price_list_line_id := p_from.price_list_line_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN pbr_rec_type,
    p_to   IN OUT NOCOPY pbrv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.bsl_id := p_from.bsl_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.line_detail_index := p_from.line_detail_index;
    p_to.line_index := p_from.line_index;
    p_to.pricing_context := p_from.pricing_context;
    p_to.pricing_method := p_from.pricing_method;
    p_to.quantity_from := p_from.quantity_from;
    p_to.quantity_to := p_from.quantity_to;
    p_to.quantity := p_from.quantity;
    p_to.break_uom := p_from.break_uom;
    p_to.prorate := p_from.prorate;
    p_to.unit_price := p_from.unit_price;
    p_to.amount := p_from.amount;
    p_to.price_list_id := p_from.price_list_id;
    p_to.validated_flag := p_from.validated_flag;
    p_to.status_code := p_from.status_code;
    p_to.status_text := p_from.status_text;
    p_to.lock_flag := p_from.lock_flag;
    p_to.locked_price_list_id := p_from.locked_price_list_id;
    p_to.locked_price_list_line_id := p_from.locked_price_list_line_id;
    p_to.price_list_line_id := p_from.price_list_line_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKS_PRICE_BREAKS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbrv_rec                     pbrv_rec_type := p_pbrv_rec;
    l_pbr_rec                      pbr_rec_type;
    l_pbr_rec                      pbr_rec_type;
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
    l_return_status := Validate_Attributes(l_pbrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pbrv_rec);
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
  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_PRICE_BREAKS_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      i := p_pbrv_tbl.FIRST;
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
            p_pbrv_rec                     => p_pbrv_tbl(i));
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
        EXIT WHEN (i = p_pbrv_tbl.LAST);
        i := p_pbrv_tbl.NEXT(i);
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

  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_PRICE_BREAKS_V --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pbrv_tbl                     => p_pbrv_tbl,
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
  -------------------------------------
  -- insert_row for:OKS_PRICE_BREAKS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbr_rec                      IN pbr_rec_type,
    x_pbr_rec                      OUT NOCOPY pbr_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbr_rec                      pbr_rec_type := p_pbr_rec;
    l_def_pbr_rec                  pbr_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKS_PRICE_BREAKS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pbr_rec IN pbr_rec_type,
      x_pbr_rec OUT NOCOPY pbr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pbr_rec := p_pbr_rec;
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
      p_pbr_rec,                         -- IN
      l_pbr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_PRICE_BREAKS(
      id,
      bsl_id,
      bcl_id,
      cle_id,
      chr_id,
      line_detail_index,
      line_index,
      pricing_context,
      pricing_method,
      quantity_from,
      quantity_to,
      quantity,
      break_uom,
      prorate,
      unit_price,
      amount,
      price_list_id,
      validated_flag,
      status_code,
      status_text,
      lock_flag,
      locked_price_list_id,
      locked_price_list_line_id,
      price_list_line_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_pbr_rec.id,
      l_pbr_rec.bsl_id,
      l_pbr_rec.bcl_id,
      l_pbr_rec.cle_id,
      l_pbr_rec.chr_id,
      l_pbr_rec.line_detail_index,
      l_pbr_rec.line_index,
      l_pbr_rec.pricing_context,
      l_pbr_rec.pricing_method,
      l_pbr_rec.quantity_from,
      l_pbr_rec.quantity_to,
      l_pbr_rec.quantity,
      l_pbr_rec.break_uom,
      l_pbr_rec.prorate,
      l_pbr_rec.unit_price,
      l_pbr_rec.amount,
      l_pbr_rec.price_list_id,
      l_pbr_rec.validated_flag,
      l_pbr_rec.status_code,
      l_pbr_rec.status_text,
      l_pbr_rec.lock_flag,
      l_pbr_rec.locked_price_list_id,
      l_pbr_rec.locked_price_list_line_id,
      l_pbr_rec.price_list_line_id,
      l_pbr_rec.object_version_number,
      l_pbr_rec.created_by,
      l_pbr_rec.creation_date,
      l_pbr_rec.last_updated_by,
      l_pbr_rec.last_update_date,
      l_pbr_rec.last_update_login);
    -- Set OUT values
    x_pbr_rec := l_pbr_rec;
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
  -- insert_row for :OKS_PRICE_BREAKS_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type,
    x_pbrv_rec                     OUT NOCOPY pbrv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbrv_rec                     pbrv_rec_type := p_pbrv_rec;
    l_def_pbrv_rec                 pbrv_rec_type;
    l_pbr_rec                      pbr_rec_type;
    lx_pbr_rec                     pbr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pbrv_rec IN pbrv_rec_type
    ) RETURN pbrv_rec_type IS
      l_pbrv_rec pbrv_rec_type := p_pbrv_rec;
    BEGIN
      l_pbrv_rec.CREATION_DATE := SYSDATE;
      l_pbrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pbrv_rec.LAST_UPDATE_DATE := l_pbrv_rec.CREATION_DATE;
      l_pbrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pbrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pbrv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKS_PRICE_BREAKS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_pbrv_rec IN pbrv_rec_type,
      x_pbrv_rec OUT NOCOPY pbrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pbrv_rec := p_pbrv_rec;
      x_pbrv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_pbrv_rec := null_out_defaults(p_pbrv_rec);
    -- Set primary key value
    l_pbrv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_pbrv_rec,                        -- IN
      l_def_pbrv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pbrv_rec := fill_who_columns(l_def_pbrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pbrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pbrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pbrv_rec, l_pbr_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pbr_rec,
      lx_pbr_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pbr_rec, l_def_pbrv_rec);
    -- Set OUT values
    x_pbrv_rec := l_def_pbrv_rec;
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
  -- PL/SQL TBL insert_row for:PBRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      i := p_pbrv_tbl.FIRST;
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
            p_pbrv_rec                     => p_pbrv_tbl(i),
            x_pbrv_rec                     => x_pbrv_tbl(i));
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
        EXIT WHEN (i = p_pbrv_tbl.LAST);
        i := p_pbrv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:PBRV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pbrv_tbl                     => p_pbrv_tbl,
        x_pbrv_tbl                     => x_pbrv_tbl,
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
  -----------------------------------
  -- lock_row for:OKS_PRICE_BREAKS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbr_rec                      IN pbr_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pbr_rec IN pbr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_PRICE_BREAKS
     WHERE ID = p_pbr_rec.id
       AND OBJECT_VERSION_NUMBER = p_pbr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_pbr_rec IN pbr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_PRICE_BREAKS
     WHERE ID = p_pbr_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_PRICE_BREAKS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_PRICE_BREAKS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pbr_rec);
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
      OPEN lchk_csr(p_pbr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pbr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pbr_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for: OKS_PRICE_BREAKS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbr_rec                      pbr_rec_type;
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
    migrate(p_pbrv_rec, l_pbr_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pbr_rec
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
  -- PL/SQL TBL lock_row for:PBRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      i := p_pbrv_tbl.FIRST;
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
            p_pbrv_rec                     => p_pbrv_tbl(i));
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
        EXIT WHEN (i = p_pbrv_tbl.LAST);
        i := p_pbrv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:PBRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pbrv_tbl                     => p_pbrv_tbl,
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
  -------------------------------------
  -- update_row for:OKS_PRICE_BREAKS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbr_rec                      IN pbr_rec_type,
    x_pbr_rec                      OUT NOCOPY pbr_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbr_rec                      pbr_rec_type := p_pbr_rec;
    l_def_pbr_rec                  pbr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pbr_rec IN pbr_rec_type,
      x_pbr_rec OUT NOCOPY pbr_rec_type
    ) RETURN VARCHAR2 IS
      l_pbr_rec                      pbr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pbr_rec := p_pbr_rec;
      -- Get current database values
      l_pbr_rec := get_rec(p_pbr_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_pbr_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.id := l_pbr_rec.id;
        END IF;
        IF (x_pbr_rec.bsl_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.bsl_id := l_pbr_rec.bsl_id;
        END IF;
        IF (x_pbr_rec.bcl_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.bcl_id := l_pbr_rec.bcl_id;
        END IF;
        IF (x_pbr_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.cle_id := l_pbr_rec.cle_id;
        END IF;
        IF (x_pbr_rec.chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.chr_id := l_pbr_rec.chr_id;
        END IF;
        IF (x_pbr_rec.line_detail_index = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.line_detail_index := l_pbr_rec.line_detail_index;
        END IF;
        IF (x_pbr_rec.line_index = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.line_index := l_pbr_rec.line_index;
        END IF;
        IF (x_pbr_rec.pricing_context = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.pricing_context := l_pbr_rec.pricing_context;
        END IF;
        IF (x_pbr_rec.pricing_method = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.pricing_method := l_pbr_rec.pricing_method;
        END IF;
        IF (x_pbr_rec.quantity_from = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.quantity_from := l_pbr_rec.quantity_from;
        END IF;
        IF (x_pbr_rec.quantity_to = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.quantity_to := l_pbr_rec.quantity_to;
        END IF;
        IF (x_pbr_rec.quantity = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.quantity := l_pbr_rec.quantity;
        END IF;
        IF (x_pbr_rec.break_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.break_uom := l_pbr_rec.break_uom;
        END IF;
        IF (x_pbr_rec.prorate = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.prorate := l_pbr_rec.prorate;
        END IF;
        IF (x_pbr_rec.unit_price = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.unit_price := l_pbr_rec.unit_price;
        END IF;
        IF (x_pbr_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.amount := l_pbr_rec.amount;
        END IF;
        IF (x_pbr_rec.price_list_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.price_list_id := l_pbr_rec.price_list_id;
        END IF;
        IF (x_pbr_rec.validated_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.validated_flag := l_pbr_rec.validated_flag;
        END IF;
        IF (x_pbr_rec.status_code = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.status_code := l_pbr_rec.status_code;
        END IF;
        IF (x_pbr_rec.status_text = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.status_text := l_pbr_rec.status_text;
        END IF;
        IF (x_pbr_rec.lock_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_pbr_rec.lock_flag := l_pbr_rec.lock_flag;
        END IF;
        IF (x_pbr_rec.locked_price_list_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.locked_price_list_id := l_pbr_rec.locked_price_list_id;
        END IF;
        IF (x_pbr_rec.locked_price_list_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.locked_price_list_line_id := l_pbr_rec.locked_price_list_line_id;
        END IF;
        IF (x_pbr_rec.price_list_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.price_list_line_id := l_pbr_rec.price_list_line_id;
        END IF;
        IF (x_pbr_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.object_version_number := l_pbr_rec.object_version_number;
        END IF;
        IF (x_pbr_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.created_by := l_pbr_rec.created_by;
        END IF;
        IF (x_pbr_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_pbr_rec.creation_date := l_pbr_rec.creation_date;
        END IF;
        IF (x_pbr_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.last_updated_by := l_pbr_rec.last_updated_by;
        END IF;
        IF (x_pbr_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_pbr_rec.last_update_date := l_pbr_rec.last_update_date;
        END IF;
        IF (x_pbr_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_pbr_rec.last_update_login := l_pbr_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKS_PRICE_BREAKS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pbr_rec IN pbr_rec_type,
      x_pbr_rec OUT NOCOPY pbr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pbr_rec := p_pbr_rec;
      x_pbr_rec.OBJECT_VERSION_NUMBER := p_pbr_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_pbr_rec,                         -- IN
      l_pbr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pbr_rec, l_def_pbr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_PRICE_BREAKS
    SET BSL_ID = l_def_pbr_rec.bsl_id,
        BCL_ID = l_def_pbr_rec.bcl_id,
        CLE_ID = l_def_pbr_rec.cle_id,
        CHR_ID = l_def_pbr_rec.chr_id,
        LINE_DETAIL_INDEX = l_def_pbr_rec.line_detail_index,
        LINE_INDEX = l_def_pbr_rec.line_index,
        PRICING_CONTEXT = l_def_pbr_rec.pricing_context,
        PRICING_METHOD = l_def_pbr_rec.pricing_method,
        QUANTITY_FROM = l_def_pbr_rec.quantity_from,
        QUANTITY_TO = l_def_pbr_rec.quantity_to,
        QUANTITY = l_def_pbr_rec.quantity,
        BREAK_UOM = l_def_pbr_rec.break_uom,
        PRORATE = l_def_pbr_rec.prorate,
        UNIT_PRICE = l_def_pbr_rec.unit_price,
        AMOUNT = l_def_pbr_rec.amount,
        PRICE_LIST_ID = l_def_pbr_rec.price_list_id,
        VALIDATED_FLAG = l_def_pbr_rec.validated_flag,
        STATUS_CODE = l_def_pbr_rec.status_code,
        STATUS_TEXT = l_def_pbr_rec.status_text,
        LOCK_FLAG = l_def_pbr_rec.lock_flag,
        LOCKED_PRICE_LIST_ID = l_def_pbr_rec.locked_price_list_id,
        LOCKED_PRICE_LIST_LINE_ID = l_def_pbr_rec.locked_price_list_line_id,
        PRICE_LIST_LINE_ID = l_def_pbr_rec.price_list_line_id,
        OBJECT_VERSION_NUMBER = l_def_pbr_rec.object_version_number,
        CREATED_BY = l_def_pbr_rec.created_by,
        CREATION_DATE = l_def_pbr_rec.creation_date,
        LAST_UPDATED_BY = l_def_pbr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pbr_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pbr_rec.last_update_login
    WHERE ID = l_def_pbr_rec.id;

    x_pbr_rec := l_pbr_rec;
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
  ---------------------------------------
  -- update_row for:OKS_PRICE_BREAKS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type,
    x_pbrv_rec                     OUT NOCOPY pbrv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbrv_rec                     pbrv_rec_type := p_pbrv_rec;
    l_def_pbrv_rec                 pbrv_rec_type;
    l_db_pbrv_rec                  pbrv_rec_type;
    l_pbr_rec                      pbr_rec_type;
    lx_pbr_rec                     pbr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pbrv_rec IN pbrv_rec_type
    ) RETURN pbrv_rec_type IS
      l_pbrv_rec pbrv_rec_type := p_pbrv_rec;
    BEGIN
      l_pbrv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pbrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pbrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pbrv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pbrv_rec IN pbrv_rec_type,
      x_pbrv_rec OUT NOCOPY pbrv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pbrv_rec := p_pbrv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_pbrv_rec := get_rec(p_pbrv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_pbrv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.id := l_db_pbrv_rec.id;
        END IF;
        IF (x_pbrv_rec.bsl_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.bsl_id := l_db_pbrv_rec.bsl_id;
        END IF;
        IF (x_pbrv_rec.bcl_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.bcl_id := l_db_pbrv_rec.bcl_id;
        END IF;
        IF (x_pbrv_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.cle_id := l_db_pbrv_rec.cle_id;
        END IF;
        IF (x_pbrv_rec.chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.chr_id := l_db_pbrv_rec.chr_id;
        END IF;
        IF (x_pbrv_rec.line_detail_index = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.line_detail_index := l_db_pbrv_rec.line_detail_index;
        END IF;
        IF (x_pbrv_rec.line_index = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.line_index := l_db_pbrv_rec.line_index;
        END IF;
        IF (x_pbrv_rec.pricing_context = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.pricing_context := l_db_pbrv_rec.pricing_context;
        END IF;
        IF (x_pbrv_rec.pricing_method = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.pricing_method := l_db_pbrv_rec.pricing_method;
        END IF;
        IF (x_pbrv_rec.quantity_from = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.quantity_from := l_db_pbrv_rec.quantity_from;
        END IF;
        IF (x_pbrv_rec.quantity_to = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.quantity_to := l_db_pbrv_rec.quantity_to;
        END IF;
        IF (x_pbrv_rec.quantity = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.quantity := l_db_pbrv_rec.quantity;
        END IF;
        IF (x_pbrv_rec.break_uom = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.break_uom := l_db_pbrv_rec.break_uom;
        END IF;
        IF (x_pbrv_rec.prorate = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.prorate := l_db_pbrv_rec.prorate;
        END IF;
        IF (x_pbrv_rec.unit_price = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.unit_price := l_db_pbrv_rec.unit_price;
        END IF;
        IF (x_pbrv_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.amount := l_db_pbrv_rec.amount;
        END IF;
        IF (x_pbrv_rec.price_list_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.price_list_id := l_db_pbrv_rec.price_list_id;
        END IF;
        IF (x_pbrv_rec.validated_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.validated_flag := l_db_pbrv_rec.validated_flag;
        END IF;
        IF (x_pbrv_rec.status_code = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.status_code := l_db_pbrv_rec.status_code;
        END IF;
        IF (x_pbrv_rec.status_text = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.status_text := l_db_pbrv_rec.status_text;
        END IF;
        IF (x_pbrv_rec.lock_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_pbrv_rec.lock_flag := l_db_pbrv_rec.lock_flag;
        END IF;
        IF (x_pbrv_rec.locked_price_list_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.locked_price_list_id := l_db_pbrv_rec.locked_price_list_id;
        END IF;
        IF (x_pbrv_rec.locked_price_list_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.locked_price_list_line_id := l_db_pbrv_rec.locked_price_list_line_id;
        END IF;
        IF (x_pbrv_rec.price_list_line_id = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.price_list_line_id := l_db_pbrv_rec.price_list_line_id;
        END IF;
        IF (x_pbrv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.created_by := l_db_pbrv_rec.created_by;
        END IF;
        IF (x_pbrv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_pbrv_rec.creation_date := l_db_pbrv_rec.creation_date;
        END IF;
        IF (x_pbrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.last_updated_by := l_db_pbrv_rec.last_updated_by;
        END IF;
        IF (x_pbrv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_pbrv_rec.last_update_date := l_db_pbrv_rec.last_update_date;
        END IF;
        IF (x_pbrv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_pbrv_rec.last_update_login := l_db_pbrv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKS_PRICE_BREAKS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_pbrv_rec IN pbrv_rec_type,
      x_pbrv_rec OUT NOCOPY pbrv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pbrv_rec := p_pbrv_rec;
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
      p_pbrv_rec,                        -- IN
      x_pbrv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pbrv_rec, l_def_pbrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pbrv_rec := fill_who_columns(l_def_pbrv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pbrv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pbrv_rec, l_db_pbrv_rec);
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
      p_pbrv_rec                     => p_pbrv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_pbrv_rec, l_pbr_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pbr_rec,
      lx_pbr_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pbr_rec, l_def_pbrv_rec);
    x_pbrv_rec := l_def_pbrv_rec;
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
  -- PL/SQL TBL update_row for:pbrv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      i := p_pbrv_tbl.FIRST;
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
            p_pbrv_rec                     => p_pbrv_tbl(i),
            x_pbrv_rec                     => x_pbrv_tbl(i));
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
        EXIT WHEN (i = p_pbrv_tbl.LAST);
        i := p_pbrv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:PBRV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    x_pbrv_tbl                     OUT NOCOPY pbrv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pbrv_tbl                     => p_pbrv_tbl,
        x_pbrv_tbl                     => x_pbrv_tbl,
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
  -------------------------------------
  -- delete_row for:OKS_PRICE_BREAKS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbr_rec                      IN pbr_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbr_rec                      pbr_rec_type := p_pbr_rec;
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

    DELETE FROM OKS_PRICE_BREAKS
     WHERE ID = p_pbr_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKS_PRICE_BREAKS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_rec                     IN pbrv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pbrv_rec                     pbrv_rec_type := p_pbrv_rec;
    l_pbr_rec                      pbr_rec_type;
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
    migrate(l_pbrv_rec, l_pbr_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_pbr_rec
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
  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_PRICE_BREAKS_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      i := p_pbrv_tbl.FIRST;
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
            p_pbrv_rec                     => p_pbrv_tbl(i));
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
        EXIT WHEN (i = p_pbrv_tbl.LAST);
        i := p_pbrv_tbl.NEXT(i);
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

  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_PRICE_BREAKS_V --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pbrv_tbl                     IN pbrv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pbrv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_pbrv_tbl                     => p_pbrv_tbl,
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

END OKS_PBR_PVT;

/
