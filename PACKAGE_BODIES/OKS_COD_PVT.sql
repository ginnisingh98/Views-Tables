--------------------------------------------------------
--  DDL for Package Body OKS_COD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COD_PVT" AS
/* $Header: OKSRCODB.pls 120.2 2006/05/26 23:10:03 jvarghes noship $ */
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
  -- FUNCTION get_rec for: OKS_K_ORDER_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_codv_rec                     IN codv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN codv_rec_type IS
    CURSOR oks_kodv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            COD_ID,
            APPLY_ALL_YN,
            LINE_RENEWAL_TYPE,
            RENEWAL_TYPE,
            PO_REQUIRED_YN,
            RENEWAL_PRICING_TYPE,
            MARKUP_PERCENT,
            LINK_ORDER_HEADER_ID,
            END_DATE,
            COD_TYPE,
            ORDER_LINE_ID1,
            ORDER_LINE_ID2,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LINK_ORD_LINE_ID1,
            LINK_ORD_LINE_ID2,
            LINK_CHR_ID,
            LINK_CLE_ID,
            PRICE_LIST_ID1,
            PRICE_LIST_ID2,
            CHR_ID,
            CLE_ID,
            CONTACT_ID,
            SITE_ID,
            EMAIL_ID,
            PHONE_ID,
            FAX_ID,
            BILLING_PROFILE_ID,
            RENEWAL_APPROVAL_FLAG
      FROM Oks_K_Order_Details_V
     WHERE oks_k_order_details_v.id = p_id;
    l_oks_kodv_pk                  oks_kodv_pk_csr%ROWTYPE;
    l_codv_rec                     codv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_kodv_pk_csr (p_codv_rec.id);
    FETCH oks_kodv_pk_csr INTO
              l_codv_rec.id,
              l_codv_rec.cod_id,
              l_codv_rec.apply_all_yn,
              l_codv_rec.line_renewal_type,
              l_codv_rec.renewal_type,
              l_codv_rec.po_required_yn,
              l_codv_rec.renewal_pricing_type,
              l_codv_rec.markup_percent,
              l_codv_rec.link_order_header_id,
              l_codv_rec.end_date,
              l_codv_rec.cod_type,
              l_codv_rec.order_line_id1,
              l_codv_rec.order_line_id2,
              l_codv_rec.object_version_number,
              l_codv_rec.created_by,
              l_codv_rec.creation_date,
              l_codv_rec.last_updated_by,
              l_codv_rec.last_update_date,
              l_codv_rec.link_ord_line_id1,
              l_codv_rec.link_ord_line_id2,
              l_codv_rec.link_chr_id,
              l_codv_rec.link_cle_id,
              l_codv_rec.price_list_id1,
              l_codv_rec.price_list_id2,
              l_codv_rec.chr_id,
              l_codv_rec.cle_id,
              l_codv_rec.contact_id,
              l_codv_rec.site_id,
              l_codv_rec.email_id,
              l_codv_rec.phone_id,
              l_codv_rec.fax_id,
              l_codv_rec.billing_profile_id,
              l_codv_rec.RENEWAL_APPROVAL_FLAG;
    x_no_data_found := oks_kodv_pk_csr%NOTFOUND;
    CLOSE oks_kodv_pk_csr;
    RETURN(l_codv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_codv_rec                     IN codv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN codv_rec_type IS
    l_codv_rec                     codv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_codv_rec := get_rec(p_codv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_codv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_codv_rec                     IN codv_rec_type
  ) RETURN codv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_codv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_ORDER_DETAILS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cod_rec                      IN cod_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cod_rec_type IS
    CURSOR oks_k_order_details_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            COD_TYPE,
            LINK_ORDER_HEADER_ID,
            ORDER_LINE_ID1,
            ORDER_LINE_ID2,
            APPLY_ALL_YN,
            RENEWAL_TYPE,
            LINE_RENEWAL_TYPE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PO_REQUIRED_YN,
            RENEWAL_PRICING_TYPE,
            MARKUP_PERCENT,
            PRICE_LIST_ID1,
            PRICE_LIST_ID2,
            LINK_ORD_LINE_ID1,
            LINK_ORD_LINE_ID2,
            LINK_CHR_ID,
            LINK_CLE_ID,
            CHR_ID,
            CLE_ID,
            COD_ID,
            CONTACT_ID,
            SITE_ID,
            EMAIL_ID,
            PHONE_ID,
            FAX_ID,
            BILLING_PROFILE_ID,
            RENEWAL_APPROVAL_FLAG
      FROM Oks_K_Order_Details
     WHERE oks_k_order_details.id = p_id;
    l_oks_k_order_details_pk       oks_k_order_details_pk_csr%ROWTYPE;
    l_cod_rec                      cod_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_k_order_details_pk_csr (p_cod_rec.id);
    FETCH oks_k_order_details_pk_csr INTO
              l_cod_rec.id,
              l_cod_rec.cod_type,
              l_cod_rec.link_order_header_id,
              l_cod_rec.order_line_id1,
              l_cod_rec.order_line_id2,
              l_cod_rec.apply_all_yn,
              l_cod_rec.renewal_type,
              l_cod_rec.line_renewal_type,
              l_cod_rec.end_date,
              l_cod_rec.object_version_number,
              l_cod_rec.created_by,
              l_cod_rec.creation_date,
              l_cod_rec.last_updated_by,
              l_cod_rec.last_update_date,
              l_cod_rec.po_required_yn,
              l_cod_rec.renewal_pricing_type,
              l_cod_rec.markup_percent,
              l_cod_rec.price_list_id1,
              l_cod_rec.price_list_id2,
              l_cod_rec.link_ord_line_id1,
              l_cod_rec.link_ord_line_id2,
              l_cod_rec.link_chr_id,
              l_cod_rec.link_cle_id,
              l_cod_rec.chr_id,
              l_cod_rec.cle_id,
              l_cod_rec.cod_id,
              l_cod_rec.contact_id,
              l_cod_rec.site_id,
              l_cod_rec.email_id,
              l_cod_rec.phone_id,
              l_cod_rec.fax_id,
              l_cod_rec.billing_profile_id,
              l_cod_rec.RENEWAL_APPROVAL_FLAG;
    x_no_data_found := oks_k_order_details_pk_csr%NOTFOUND;
    CLOSE oks_k_order_details_pk_csr;
    RETURN(l_cod_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_cod_rec                      IN cod_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN cod_rec_type IS
    l_cod_rec                      cod_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_cod_rec := get_rec(p_cod_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_cod_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_cod_rec                      IN cod_rec_type
  ) RETURN cod_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cod_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_K_ORDER_DETAILS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_codv_rec   IN codv_rec_type
  ) RETURN codv_rec_type IS
    l_codv_rec                     codv_rec_type := p_codv_rec;
  BEGIN
    IF (l_codv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.id := NULL;
    END IF;
    IF (l_codv_rec.cod_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.cod_id := NULL;
    END IF;
    IF (l_codv_rec.apply_all_yn = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.apply_all_yn := NULL;
    END IF;
    IF (l_codv_rec.line_renewal_type = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.line_renewal_type := NULL;
    END IF;
    IF (l_codv_rec.renewal_type = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.renewal_type := NULL;
    END IF;
    IF (l_codv_rec.po_required_yn = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.po_required_yn := NULL;
    END IF;
    IF (l_codv_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.renewal_pricing_type := NULL;
    END IF;
    IF (l_codv_rec.markup_percent = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.markup_percent := NULL;
    END IF;
    IF (l_codv_rec.link_order_header_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.link_order_header_id := NULL;
    END IF;
    IF (l_codv_rec.end_date = OKC_API.G_MISS_DATE ) THEN
      l_codv_rec.end_date := NULL;
    END IF;
    IF (l_codv_rec.cod_type = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.cod_type := NULL;
    END IF;
    IF (l_codv_rec.order_line_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.order_line_id1 := NULL;
    END IF;
    IF (l_codv_rec.order_line_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.order_line_id2 := NULL;
    END IF;
    IF (l_codv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.object_version_number := NULL;
    END IF;
    IF (l_codv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.created_by := NULL;
    END IF;
    IF (l_codv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_codv_rec.creation_date := NULL;
    END IF;
    IF (l_codv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.last_updated_by := NULL;
    END IF;
    IF (l_codv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_codv_rec.last_update_date := NULL;
    END IF;
    IF (l_codv_rec.link_ord_line_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.link_ord_line_id1 := NULL;
    END IF;
    IF (l_codv_rec.link_ord_line_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.link_ord_line_id2 := NULL;
    END IF;
    IF (l_codv_rec.link_chr_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.link_chr_id := NULL;
    END IF;
    IF (l_codv_rec.link_cle_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.link_cle_id := NULL;
    END IF;
    IF (l_codv_rec.price_list_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.price_list_id1 := NULL;
    END IF;
    IF (l_codv_rec.price_list_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.price_list_id2 := NULL;
    END IF;
    IF (l_codv_rec.chr_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.chr_id := NULL;
    END IF;
    IF (l_codv_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.cle_id := NULL;
    END IF;
    IF (l_codv_rec.contact_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.contact_id := NULL;
    END IF;
    IF (l_codv_rec.site_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.site_id := NULL;
    END IF;
    IF (l_codv_rec.email_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.email_id := NULL;
    END IF;
    IF (l_codv_rec.phone_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.phone_id := NULL;
    END IF;
    IF (l_codv_rec.fax_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.fax_id := NULL;
    END IF;
    IF (l_codv_rec.billing_profile_id = OKC_API.G_MISS_NUM ) THEN
      l_codv_rec.billing_profile_id := NULL;
    END IF;
    IF (l_codv_rec.RENEWAL_APPROVAL_FLAG = OKC_API.G_MISS_CHAR ) THEN
      l_codv_rec.RENEWAL_APPROVAL_FLAG := NULL;
    END IF;

    RETURN(l_codv_rec);
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
  -------------------------------------------
  -- Validate_Attributes for: APPLY_ALL_YN --
  -------------------------------------------
  PROCEDURE validate_apply_all_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_apply_all_yn                 IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_apply_all_yn = OKC_API.G_MISS_CHAR OR
        p_apply_all_yn IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'apply_all_yn');
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
  END validate_apply_all_yn;
  ------------------------------------------------
  -- Validate_Attributes for: LINE_RENEWAL_TYPE --
  ------------------------------------------------
  PROCEDURE validate_line_renewal_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_line_renewal_type            IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_line_renewal_type = OKC_API.G_MISS_CHAR OR
        p_line_renewal_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'line_renewal_type');
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
  END validate_line_renewal_type;
  ---------------------------------------
  -- Validate_Attributes for: COD_TYPE --
  ---------------------------------------
  PROCEDURE validate_cod_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cod_type                     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cod_type = OKC_API.G_MISS_CHAR OR
        p_cod_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cod_type');
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
  END validate_cod_type;
  ---------------------------------------------
  -- Validate_Attributes for: ORDER_LINE_ID1 --
  ---------------------------------------------
  PROCEDURE validate_order_line_id1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_order_line_id1               IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_order_line_id1 = OKC_API.G_MISS_CHAR OR
        p_order_line_id1 IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'order_line_id1');
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
  END validate_order_line_id1;
  ---------------------------------------------
  -- Validate_Attributes for: ORDER_LINE_ID2 --
  ---------------------------------------------
  PROCEDURE validate_order_line_id2(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_order_line_id2               IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_order_line_id2 = OKC_API.G_MISS_CHAR OR
        p_order_line_id2 IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'order_line_id2');
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
  END validate_order_line_id2;
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
  ---------------------------------------------------
  -- Validate_Attributes for:OKS_K_ORDER_DETAILS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_codv_rec                     IN codv_rec_type
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
    validate_id(x_return_status, p_codv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- apply_all_yn
    -- ***
    validate_apply_all_yn(x_return_status, p_codv_rec.apply_all_yn);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- line_renewal_type
    -- ***
    validate_line_renewal_type(x_return_status, p_codv_rec.line_renewal_type);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- cod_type
    -- ***
    validate_cod_type(x_return_status, p_codv_rec.cod_type);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- order_line_id1
    -- ***
    validate_order_line_id1(x_return_status, p_codv_rec.order_line_id1);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- order_line_id2
    -- ***
    validate_order_line_id2(x_return_status, p_codv_rec.order_line_id2);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_codv_rec.object_version_number);
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
  -----------------------------------------------
  -- Validate Record for:OKS_K_ORDER_DETAILS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_codv_rec IN codv_rec_type,
    p_db_codv_rec IN codv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_codv_rec IN codv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_codv_rec                  codv_rec_type := get_rec(p_codv_rec);
  BEGIN
    l_return_status := Validate_Record(p_codv_rec => p_codv_rec,
                                       p_db_codv_rec => l_db_codv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN codv_rec_type,
    p_to   IN OUT NOCOPY cod_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cod_type := p_from.cod_type;
    p_to.link_order_header_id := p_from.link_order_header_id;
    p_to.order_line_id1 := p_from.order_line_id1;
    p_to.order_line_id2 := p_from.order_line_id2;
    p_to.apply_all_yn := p_from.apply_all_yn;
    p_to.renewal_type := p_from.renewal_type;
    p_to.line_renewal_type := p_from.line_renewal_type;
    p_to.end_date := p_from.end_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.po_required_yn := p_from.po_required_yn;
    p_to.renewal_pricing_type := p_from.renewal_pricing_type;
    p_to.markup_percent := p_from.markup_percent;
    p_to.price_list_id1 := p_from.price_list_id1;
    p_to.price_list_id2 := p_from.price_list_id2;
    p_to.link_ord_line_id1 := p_from.link_ord_line_id1;
    p_to.link_ord_line_id2 := p_from.link_ord_line_id2;
    p_to.link_chr_id := p_from.link_chr_id;
    p_to.link_cle_id := p_from.link_cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.cod_id := p_from.cod_id;
    p_to.contact_id := p_from.contact_id;
    p_to.site_id := p_from.site_id;
    p_to.email_id := p_from.email_id;
    p_to.phone_id := p_from.phone_id;
    p_to.fax_id := p_from.fax_id;
    p_to.billing_profile_id := p_from.billing_profile_id;
    p_to.RENEWAL_APPROVAL_FLAG := p_from.RENEWAL_APPROVAL_FLAG;
  END migrate;
  PROCEDURE migrate (
    p_from IN cod_rec_type,
    p_to   IN OUT NOCOPY codv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cod_id := p_from.cod_id;
    p_to.apply_all_yn := p_from.apply_all_yn;
    p_to.line_renewal_type := p_from.line_renewal_type;
    p_to.renewal_type := p_from.renewal_type;
    p_to.po_required_yn := p_from.po_required_yn;
    p_to.renewal_pricing_type := p_from.renewal_pricing_type;
    p_to.markup_percent := p_from.markup_percent;
    p_to.link_order_header_id := p_from.link_order_header_id;
    p_to.end_date := p_from.end_date;
    p_to.cod_type := p_from.cod_type;
    p_to.order_line_id1 := p_from.order_line_id1;
    p_to.order_line_id2 := p_from.order_line_id2;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.link_ord_line_id1 := p_from.link_ord_line_id1;
    p_to.link_ord_line_id2 := p_from.link_ord_line_id2;
    p_to.link_chr_id := p_from.link_chr_id;
    p_to.link_cle_id := p_from.link_cle_id;
    p_to.price_list_id1 := p_from.price_list_id1;
    p_to.price_list_id2 := p_from.price_list_id2;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.contact_id := p_from.contact_id;
    p_to.site_id := p_from.site_id;
    p_to.email_id := p_from.email_id;
    p_to.phone_id := p_from.phone_id;
    p_to.fax_id := p_from.fax_id;
    p_to.billing_profile_id := p_from.billing_profile_id;
    p_to.RENEWAL_APPROVAL_FLAG := p_from.RENEWAL_APPROVAL_FLAG;

  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKS_K_ORDER_DETAILS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_codv_rec                     codv_rec_type := p_codv_rec;
    l_cod_rec                      cod_rec_type;
    l_cod_rec                      cod_rec_type;
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
    l_return_status := Validate_Attributes(l_codv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_codv_rec);
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
  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_K_ORDER_DETAILS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      i := p_codv_tbl.FIRST;
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
            p_codv_rec                     => p_codv_tbl(i));
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
        EXIT WHEN (i = p_codv_tbl.LAST);
        i := p_codv_tbl.NEXT(i);
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

  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_K_ORDER_DETAILS_V --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_codv_tbl                     => p_codv_tbl,
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
  ----------------------------------------
  -- insert_row for:OKS_K_ORDER_DETAILS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cod_rec                      IN cod_rec_type,
    x_cod_rec                      OUT NOCOPY cod_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cod_rec                      cod_rec_type := p_cod_rec;
    l_def_cod_rec                  cod_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_DETAILS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cod_rec IN cod_rec_type,
      x_cod_rec OUT NOCOPY cod_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cod_rec := p_cod_rec;
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
      p_cod_rec,                         -- IN
      l_cod_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_K_ORDER_DETAILS(
      id,
      cod_type,
      link_order_header_id,
      order_line_id1,
      order_line_id2,
      apply_all_yn,
      renewal_type,
      line_renewal_type,
      end_date,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      po_required_yn,
      renewal_pricing_type,
      markup_percent,
      price_list_id1,
      price_list_id2,
      link_ord_line_id1,
      link_ord_line_id2,
      link_chr_id,
      link_cle_id,
      chr_id,
      cle_id,
      cod_id,
      contact_id,
      site_id,
      email_id,
      phone_id,
      fax_id,
      billing_profile_id,
      RENEWAL_APPROVAL_FLAG)
    VALUES (
      l_cod_rec.id,
      l_cod_rec.cod_type,
      l_cod_rec.link_order_header_id,
      l_cod_rec.order_line_id1,
      l_cod_rec.order_line_id2,
      l_cod_rec.apply_all_yn,
      l_cod_rec.renewal_type,
      l_cod_rec.line_renewal_type,
      l_cod_rec.end_date,
      l_cod_rec.object_version_number,
      l_cod_rec.created_by,
      l_cod_rec.creation_date,
      l_cod_rec.last_updated_by,
      l_cod_rec.last_update_date,
      l_cod_rec.po_required_yn,
      l_cod_rec.renewal_pricing_type,
      l_cod_rec.markup_percent,
      l_cod_rec.price_list_id1,
      l_cod_rec.price_list_id2,
      l_cod_rec.link_ord_line_id1,
      l_cod_rec.link_ord_line_id2,
      l_cod_rec.link_chr_id,
      l_cod_rec.link_cle_id,
      l_cod_rec.chr_id,
      l_cod_rec.cle_id,
      l_cod_rec.cod_id,
      l_cod_rec.contact_id,
      l_cod_rec.site_id,
      l_cod_rec.email_id,
      l_cod_rec.phone_id,
      l_cod_rec.fax_id,
      l_cod_rec.billing_profile_id,
      l_cod_rec.RENEWAL_APPROVAL_FLAG);
    -- Set OUT values
    x_cod_rec := l_cod_rec;
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
  -------------------------------------------
  -- insert_row for :OKS_K_ORDER_DETAILS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type,
    x_codv_rec                     OUT NOCOPY codv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_codv_rec                     codv_rec_type := p_codv_rec;
    l_def_codv_rec                 codv_rec_type;
    l_cod_rec                      cod_rec_type;
    lx_cod_rec                     cod_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_codv_rec IN codv_rec_type
    ) RETURN codv_rec_type IS
      l_codv_rec codv_rec_type := p_codv_rec;
    BEGIN
      l_codv_rec.CREATION_DATE := SYSDATE;
      l_codv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_codv_rec.LAST_UPDATE_DATE := l_codv_rec.CREATION_DATE;
      l_codv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      --l_codv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_codv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_DETAILS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_codv_rec IN codv_rec_type,
      x_codv_rec OUT NOCOPY codv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_codv_rec := p_codv_rec;
      x_codv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_codv_rec := null_out_defaults(p_codv_rec);
    -- Set primary key value
    l_codv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_codv_rec,                        -- IN
      l_def_codv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_codv_rec := fill_who_columns(l_def_codv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_codv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_codv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_codv_rec, l_cod_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cod_rec,
      lx_cod_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cod_rec, l_def_codv_rec);
    -- Set OUT values
    x_codv_rec := l_def_codv_rec;
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
  -- PL/SQL TBL insert_row for:CODV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      i := p_codv_tbl.FIRST;
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
            p_codv_rec                     => p_codv_tbl(i),
            x_codv_rec                     => x_codv_tbl(i));
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
        EXIT WHEN (i = p_codv_tbl.LAST);
        i := p_codv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:CODV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_codv_tbl                     => p_codv_tbl,
        x_codv_tbl                     => x_codv_tbl,
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
  --------------------------------------
  -- lock_row for:OKS_K_ORDER_DETAILS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cod_rec                      IN cod_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cod_rec IN cod_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_ORDER_DETAILS
     WHERE ID = p_cod_rec.id
       AND OBJECT_VERSION_NUMBER = p_cod_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_cod_rec IN cod_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_ORDER_DETAILS
     WHERE ID = p_cod_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_K_ORDER_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_K_ORDER_DETAILS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cod_rec);
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
      OPEN lchk_csr(p_cod_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cod_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cod_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for: OKS_K_ORDER_DETAILS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cod_rec                      cod_rec_type;
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
    migrate(p_codv_rec, l_cod_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cod_rec
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
  -- PL/SQL TBL lock_row for:CODV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      i := p_codv_tbl.FIRST;
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
            p_codv_rec                     => p_codv_tbl(i));
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
        EXIT WHEN (i = p_codv_tbl.LAST);
        i := p_codv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:CODV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_codv_tbl                     => p_codv_tbl,
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
  ----------------------------------------
  -- update_row for:OKS_K_ORDER_DETAILS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cod_rec                      IN cod_rec_type,
    x_cod_rec                      OUT NOCOPY cod_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cod_rec                      cod_rec_type := p_cod_rec;
    l_def_cod_rec                  cod_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cod_rec IN cod_rec_type,
      x_cod_rec OUT NOCOPY cod_rec_type
    ) RETURN VARCHAR2 IS
      l_cod_rec                      cod_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cod_rec := p_cod_rec;
      -- Get current database values
      l_cod_rec := get_rec(p_cod_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_cod_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.id := l_cod_rec.id;
        END IF;
        IF (x_cod_rec.cod_type = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.cod_type := l_cod_rec.cod_type;
        END IF;
        IF (x_cod_rec.link_order_header_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.link_order_header_id := l_cod_rec.link_order_header_id;
        END IF;
        IF (x_cod_rec.order_line_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.order_line_id1 := l_cod_rec.order_line_id1;
        END IF;
        IF (x_cod_rec.order_line_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.order_line_id2 := l_cod_rec.order_line_id2;
        END IF;
        IF (x_cod_rec.apply_all_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.apply_all_yn := l_cod_rec.apply_all_yn;
        END IF;
        IF (x_cod_rec.renewal_type = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.renewal_type := l_cod_rec.renewal_type;
        END IF;
        IF (x_cod_rec.line_renewal_type = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.line_renewal_type := l_cod_rec.line_renewal_type;
        END IF;
        IF (x_cod_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_cod_rec.end_date := l_cod_rec.end_date;
        END IF;
        IF (x_cod_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.object_version_number := l_cod_rec.object_version_number;
        END IF;
        IF (x_cod_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.created_by := l_cod_rec.created_by;
        END IF;
        IF (x_cod_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_cod_rec.creation_date := l_cod_rec.creation_date;
        END IF;
        IF (x_cod_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.last_updated_by := l_cod_rec.last_updated_by;
        END IF;
        IF (x_cod_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_cod_rec.last_update_date := l_cod_rec.last_update_date;
        END IF;
        IF (x_cod_rec.po_required_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.po_required_yn := l_cod_rec.po_required_yn;
        END IF;
        IF (x_cod_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.renewal_pricing_type := l_cod_rec.renewal_pricing_type;
        END IF;
        IF (x_cod_rec.markup_percent = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.markup_percent := l_cod_rec.markup_percent;
        END IF;
        IF (x_cod_rec.price_list_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.price_list_id1 := l_cod_rec.price_list_id1;
        END IF;
        IF (x_cod_rec.price_list_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.price_list_id2 := l_cod_rec.price_list_id2;
        END IF;
        IF (x_cod_rec.link_ord_line_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.link_ord_line_id1 := l_cod_rec.link_ord_line_id1;
        END IF;
        IF (x_cod_rec.link_ord_line_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.link_ord_line_id2 := l_cod_rec.link_ord_line_id2;
        END IF;
        IF (x_cod_rec.link_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.link_chr_id := l_cod_rec.link_chr_id;
        END IF;
        IF (x_cod_rec.link_cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.link_cle_id := l_cod_rec.link_cle_id;
        END IF;
        IF (x_cod_rec.chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.chr_id := l_cod_rec.chr_id;
        END IF;
        IF (x_cod_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.cle_id := l_cod_rec.cle_id;
        END IF;
        IF (x_cod_rec.cod_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.cod_id := l_cod_rec.cod_id;
        END IF;
        IF (x_cod_rec.contact_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.contact_id := l_cod_rec.contact_id;
        END IF;
        IF (x_cod_rec.site_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.site_id := l_cod_rec.site_id;
        END IF;
        IF (x_cod_rec.email_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.email_id := l_cod_rec.email_id;
        END IF;
        IF (x_cod_rec.phone_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.phone_id := l_cod_rec.phone_id;
        END IF;
        IF (x_cod_rec.fax_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.fax_id := l_cod_rec.fax_id;
        END IF;
        IF (x_cod_rec.billing_profile_id = OKC_API.G_MISS_NUM)
        THEN
          x_cod_rec.billing_profile_id := l_cod_rec.billing_profile_id;
        END IF;
        IF (x_cod_rec.RENEWAL_APPROVAL_FLAG = OKC_API.G_MISS_CHAR)
        THEN
          x_cod_rec.RENEWAL_APPROVAL_FLAG := l_cod_rec.RENEWAL_APPROVAL_FLAG;
        END IF;

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_DETAILS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cod_rec IN cod_rec_type,
      x_cod_rec OUT NOCOPY cod_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cod_rec := p_cod_rec;
      x_cod_rec.OBJECT_VERSION_NUMBER := p_cod_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_cod_rec,                         -- IN
      l_cod_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cod_rec, l_def_cod_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_K_ORDER_DETAILS
    SET COD_TYPE = l_def_cod_rec.cod_type,
        LINK_ORDER_HEADER_ID = l_def_cod_rec.link_order_header_id,
        ORDER_LINE_ID1 = l_def_cod_rec.order_line_id1,
        ORDER_LINE_ID2 = l_def_cod_rec.order_line_id2,
        APPLY_ALL_YN = l_def_cod_rec.apply_all_yn,
        RENEWAL_TYPE = l_def_cod_rec.renewal_type,
        LINE_RENEWAL_TYPE = l_def_cod_rec.line_renewal_type,
        END_DATE = l_def_cod_rec.end_date,
        OBJECT_VERSION_NUMBER = l_def_cod_rec.object_version_number,
        CREATED_BY = l_def_cod_rec.created_by,
        CREATION_DATE = l_def_cod_rec.creation_date,
        LAST_UPDATED_BY = l_def_cod_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cod_rec.last_update_date,
        PO_REQUIRED_YN = l_def_cod_rec.po_required_yn,
        RENEWAL_PRICING_TYPE = l_def_cod_rec.renewal_pricing_type,
        MARKUP_PERCENT = l_def_cod_rec.markup_percent,
        PRICE_LIST_ID1 = l_def_cod_rec.price_list_id1,
        PRICE_LIST_ID2 = l_def_cod_rec.price_list_id2,
        LINK_ORD_LINE_ID1 = l_def_cod_rec.link_ord_line_id1,
        LINK_ORD_LINE_ID2 = l_def_cod_rec.link_ord_line_id2,
        LINK_CHR_ID = l_def_cod_rec.link_chr_id,
        LINK_CLE_ID = l_def_cod_rec.link_cle_id,
        CHR_ID = l_def_cod_rec.chr_id,
        CLE_ID = l_def_cod_rec.cle_id,
        COD_ID = l_def_cod_rec.cod_id,
        CONTACT_ID = l_def_cod_rec.contact_id,
        SITE_ID = l_def_cod_rec.site_id,
        EMAIL_ID = l_def_cod_rec.email_id,
        PHONE_ID = l_def_cod_rec.phone_id,
        FAX_ID = l_def_cod_rec.fax_id,
        BILLING_PROFILE_ID = l_def_cod_rec.billing_profile_id,
        RENEWAL_APPROVAL_FLAG = l_def_cod_rec.RENEWAL_APPROVAL_FLAG
    WHERE ID = l_def_cod_rec.id;

    x_cod_rec := l_cod_rec;
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
  ------------------------------------------
  -- update_row for:OKS_K_ORDER_DETAILS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type,
    x_codv_rec                     OUT NOCOPY codv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_codv_rec                     codv_rec_type := p_codv_rec;
    l_def_codv_rec                 codv_rec_type;
    l_db_codv_rec                  codv_rec_type;
    l_cod_rec                      cod_rec_type;
    lx_cod_rec                     cod_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_codv_rec IN codv_rec_type
    ) RETURN codv_rec_type IS
      l_codv_rec codv_rec_type := p_codv_rec;
    BEGIN
      l_codv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_codv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      --l_codv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_codv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_codv_rec IN codv_rec_type,
      x_codv_rec OUT NOCOPY codv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_codv_rec := p_codv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_codv_rec := get_rec(p_codv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_codv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.id := l_db_codv_rec.id;
        END IF;
        IF (x_codv_rec.cod_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.cod_id := l_db_codv_rec.cod_id;
        END IF;
        IF (x_codv_rec.apply_all_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.apply_all_yn := l_db_codv_rec.apply_all_yn;
        END IF;
        IF (x_codv_rec.line_renewal_type = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.line_renewal_type := l_db_codv_rec.line_renewal_type;
        END IF;
        IF (x_codv_rec.renewal_type = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.renewal_type := l_db_codv_rec.renewal_type;
        END IF;
        IF (x_codv_rec.po_required_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.po_required_yn := l_db_codv_rec.po_required_yn;
        END IF;
        IF (x_codv_rec.renewal_pricing_type = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.renewal_pricing_type := l_db_codv_rec.renewal_pricing_type;
        END IF;
        IF (x_codv_rec.markup_percent = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.markup_percent := l_db_codv_rec.markup_percent;
        END IF;
        IF (x_codv_rec.link_order_header_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.link_order_header_id := l_db_codv_rec.link_order_header_id;
        END IF;
        IF (x_codv_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_codv_rec.end_date := l_db_codv_rec.end_date;
        END IF;
        IF (x_codv_rec.cod_type = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.cod_type := l_db_codv_rec.cod_type;
        END IF;
        IF (x_codv_rec.order_line_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.order_line_id1 := l_db_codv_rec.order_line_id1;
        END IF;
        IF (x_codv_rec.order_line_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.order_line_id2 := l_db_codv_rec.order_line_id2;
        END IF;
        IF (x_codv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.created_by := l_db_codv_rec.created_by;
        END IF;
        IF (x_codv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_codv_rec.creation_date := l_db_codv_rec.creation_date;
        END IF;
        IF (x_codv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.last_updated_by := l_db_codv_rec.last_updated_by;
        END IF;
        IF (x_codv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_codv_rec.last_update_date := l_db_codv_rec.last_update_date;
        END IF;
        IF (x_codv_rec.link_ord_line_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.link_ord_line_id1 := l_db_codv_rec.link_ord_line_id1;
        END IF;
        IF (x_codv_rec.link_ord_line_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.link_ord_line_id2 := l_db_codv_rec.link_ord_line_id2;
        END IF;
        IF (x_codv_rec.link_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.link_chr_id := l_db_codv_rec.link_chr_id;
        END IF;
        IF (x_codv_rec.link_cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.link_cle_id := l_db_codv_rec.link_cle_id;
        END IF;
        IF (x_codv_rec.price_list_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.price_list_id1 := l_db_codv_rec.price_list_id1;
        END IF;
        IF (x_codv_rec.price_list_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.price_list_id2 := l_db_codv_rec.price_list_id2;
        END IF;
        IF (x_codv_rec.chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.chr_id := l_db_codv_rec.chr_id;
        END IF;
        IF (x_codv_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.cle_id := l_db_codv_rec.cle_id;
        END IF;
        IF (x_codv_rec.contact_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.contact_id := l_db_codv_rec.contact_id;
        END IF;
        IF (x_codv_rec.site_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.site_id := l_db_codv_rec.site_id;
        END IF;
        IF (x_codv_rec.email_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.email_id := l_db_codv_rec.email_id;
        END IF;
        IF (x_codv_rec.phone_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.phone_id := l_db_codv_rec.phone_id;
        END IF;
        IF (x_codv_rec.fax_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.fax_id := l_db_codv_rec.fax_id;
        END IF;
        IF (x_codv_rec.billing_profile_id = OKC_API.G_MISS_NUM)
        THEN
          x_codv_rec.billing_profile_id := l_db_codv_rec.billing_profile_id;
        END IF;

        IF (x_codv_rec.RENEWAL_APPROVAL_FLAG = OKC_API.G_MISS_CHAR)
        THEN
          x_codv_rec.RENEWAL_APPROVAL_FLAG := l_db_codv_rec.RENEWAL_APPROVAL_FLAG;
        END IF;

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_DETAILS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_codv_rec IN codv_rec_type,
      x_codv_rec OUT NOCOPY codv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_codv_rec := p_codv_rec;
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
      p_codv_rec,                        -- IN
      x_codv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_codv_rec, l_def_codv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_codv_rec := fill_who_columns(l_def_codv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_codv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_codv_rec, l_db_codv_rec);
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
      p_codv_rec                     => p_codv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_codv_rec, l_cod_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cod_rec,
      lx_cod_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cod_rec, l_def_codv_rec);
    x_codv_rec := l_def_codv_rec;
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
  -- PL/SQL TBL update_row for:codv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      i := p_codv_tbl.FIRST;
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
            p_codv_rec                     => p_codv_tbl(i),
            x_codv_rec                     => x_codv_tbl(i));
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
        EXIT WHEN (i = p_codv_tbl.LAST);
        i := p_codv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:CODV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    x_codv_tbl                     OUT NOCOPY codv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_codv_tbl                     => p_codv_tbl,
        x_codv_tbl                     => x_codv_tbl,
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
  ----------------------------------------
  -- delete_row for:OKS_K_ORDER_DETAILS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cod_rec                      IN cod_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cod_rec                      cod_rec_type := p_cod_rec;
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

    DELETE FROM OKS_K_ORDER_DETAILS
     WHERE ID = p_cod_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKS_K_ORDER_DETAILS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_rec                     IN codv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_codv_rec                     codv_rec_type := p_codv_rec;
    l_cod_rec                      cod_rec_type;
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
    migrate(l_codv_rec, l_cod_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_cod_rec
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
  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_K_ORDER_DETAILS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      i := p_codv_tbl.FIRST;
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
            p_codv_rec                     => p_codv_tbl(i));
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
        EXIT WHEN (i = p_codv_tbl.LAST);
        i := p_codv_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_K_ORDER_DETAILS_V --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_codv_tbl                     IN codv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_codv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_codv_tbl                     => p_codv_tbl,
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

END OKS_COD_PVT;

/
