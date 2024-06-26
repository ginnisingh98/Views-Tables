--------------------------------------------------------
--  DDL for Package Body OKL_SUC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUC_PVT" AS
/* $Header: OKLSSUCB.pls 115.3 2004/03/18 07:12:39 avsingh noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY  OKL_API.ERROR_TBL_TYPE) IS

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
  -- FUNCTION get_rec for: OKL_SUBSIDY_CRITERIA_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sucv_rec                     IN sucv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sucv_rec_type IS
    CURSOR okl_subsidy_criteria_v_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SUBSIDY_ID,
            DISPLAY_SEQUENCE,
            INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            CREDIT_CLASSIFICATION_CODE,
            SALES_TERRITORY_CODE,
            PRODUCT_ID,
            INDUSTRY_CODE_TYPE,
            INDUSTRY_CODE,
            --Bug# 3313802
            --MAXIMUM_SUBSIDY_AMOUNT,
            MAXIMUM_FINANCED_AMOUNT,
            --Bug# 3508166
            SALES_TERRITORY_ID,
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
      FROM Okl_Subsidy_Criteria_V
     WHERE okl_subsidy_criteria_v.id = p_id;
    l_okl_subsidy_criteria_v_pk    okl_subsidy_criteria_v_pk_csr%ROWTYPE;
    l_sucv_rec                     sucv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_subsidy_criteria_v_pk_csr (p_sucv_rec.id);
    FETCH okl_subsidy_criteria_v_pk_csr INTO
              l_sucv_rec.id,
              l_sucv_rec.object_version_number,
              l_sucv_rec.subsidy_id,
              l_sucv_rec.display_sequence,
              l_sucv_rec.inventory_item_id,
              l_sucv_rec.organization_id,
              l_sucv_rec.credit_classification_code,
              l_sucv_rec.sales_territory_code,
              l_sucv_rec.product_id,
              l_sucv_rec.industry_code_type,
              l_sucv_rec.industry_code,
              --Bug# 3313802
              --l_sucv_rec.maximum_subsidy_amount,
              l_sucv_rec.maximum_financed_amount,
              --Bug# 3508166
              l_sucv_rec.sales_territory_id,
              l_sucv_rec.attribute_category,
              l_sucv_rec.attribute1,
              l_sucv_rec.attribute2,
              l_sucv_rec.attribute3,
              l_sucv_rec.attribute4,
              l_sucv_rec.attribute5,
              l_sucv_rec.attribute6,
              l_sucv_rec.attribute7,
              l_sucv_rec.attribute8,
              l_sucv_rec.attribute9,
              l_sucv_rec.attribute10,
              l_sucv_rec.attribute11,
              l_sucv_rec.attribute12,
              l_sucv_rec.attribute13,
              l_sucv_rec.attribute14,
              l_sucv_rec.attribute15,
              l_sucv_rec.created_by,
              l_sucv_rec.creation_date,
              l_sucv_rec.last_updated_by,
              l_sucv_rec.last_update_date,
              l_sucv_rec.last_update_login;
    x_no_data_found := okl_subsidy_criteria_v_pk_csr%NOTFOUND;
    CLOSE okl_subsidy_criteria_v_pk_csr;
    RETURN(l_sucv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sucv_rec                     IN sucv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sucv_rec_type IS
    l_sucv_rec                     sucv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_sucv_rec := get_rec(p_sucv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_sucv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sucv_rec                     IN sucv_rec_type
  ) RETURN sucv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sucv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SUBSIDY_CRITERIA
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_suc_rec                      IN suc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN suc_rec_type IS
    CURSOR okl_subsidy_criteria_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SUBSIDY_ID,
            DISPLAY_SEQUENCE,
            INVENTORY_ITEM_ID,
            ORGANIZATION_ID,
            CREDIT_CLASSIFICATION_CODE,
            SALES_TERRITORY_CODE,
            PRODUCT_ID,
            INDUSTRY_CODE_TYPE,
            INDUSTRY_CODE,
            --Bug# 3313802
            --MAXIMUM_SUBSIDY_AMOUNT,
            MAXIMUM_FINANCED_AMOUNT,
            --Bug# 3508166
            SALES_TERRITORY_ID,
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
      FROM Okl_Subsidy_Criteria
     WHERE okl_subsidy_criteria.id = p_id;
    l_okl_subsidy_criteria_pk      okl_subsidy_criteria_pk_csr%ROWTYPE;
    l_suc_rec                      suc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_subsidy_criteria_pk_csr (p_suc_rec.id);
    FETCH okl_subsidy_criteria_pk_csr INTO
              l_suc_rec.id,
              l_suc_rec.object_version_number,
              l_suc_rec.subsidy_id,
              l_suc_rec.display_sequence,
              l_suc_rec.inventory_item_id,
              l_suc_rec.organization_id,
              l_suc_rec.credit_classification_code,
              l_suc_rec.sales_territory_code,
              l_suc_rec.product_id,
              l_suc_rec.industry_code_type,
              l_suc_rec.industry_code,
              --Bug# 3313802
              --l_suc_rec.maximum_subsidy_amount,
              l_suc_rec.maximum_financed_amount,
              --Bug# 3508166
              l_suc_rec.sales_territory_id,
              l_suc_rec.attribute_category,
              l_suc_rec.attribute1,
              l_suc_rec.attribute2,
              l_suc_rec.attribute3,
              l_suc_rec.attribute4,
              l_suc_rec.attribute5,
              l_suc_rec.attribute6,
              l_suc_rec.attribute7,
              l_suc_rec.attribute8,
              l_suc_rec.attribute9,
              l_suc_rec.attribute10,
              l_suc_rec.attribute11,
              l_suc_rec.attribute12,
              l_suc_rec.attribute13,
              l_suc_rec.attribute14,
              l_suc_rec.attribute15,
              l_suc_rec.created_by,
              l_suc_rec.creation_date,
              l_suc_rec.last_updated_by,
              l_suc_rec.last_update_date,
              l_suc_rec.last_update_login;
    x_no_data_found := okl_subsidy_criteria_pk_csr%NOTFOUND;
    CLOSE okl_subsidy_criteria_pk_csr;
    RETURN(l_suc_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_suc_rec                      IN suc_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN suc_rec_type IS
    l_suc_rec                      suc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_suc_rec := get_rec(p_suc_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_suc_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_suc_rec                      IN suc_rec_type
  ) RETURN suc_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_suc_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SUBSIDY_CRITERIA_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sucv_rec   IN sucv_rec_type
  ) RETURN sucv_rec_type IS
    l_sucv_rec                     sucv_rec_type := p_sucv_rec;
  BEGIN
    IF (l_sucv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.id := NULL;
    END IF;
    IF (l_sucv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.object_version_number := NULL;
    END IF;
    IF (l_sucv_rec.subsidy_id = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.subsidy_id := NULL;
    END IF;
    IF (l_sucv_rec.display_sequence = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.display_sequence := NULL;
    END IF;
    IF (l_sucv_rec.inventory_item_id = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.inventory_item_id := NULL;
    END IF;
    IF (l_sucv_rec.organization_id = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.organization_id := NULL;
    END IF;
    IF (l_sucv_rec.credit_classification_code = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.credit_classification_code := NULL;
    END IF;
    IF (l_sucv_rec.sales_territory_code = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.sales_territory_code := NULL;
    END IF;
    IF (l_sucv_rec.product_id = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.product_id := NULL;
    END IF;
    IF (l_sucv_rec.industry_code_type = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.industry_code_type := NULL;
    END IF;
    IF (l_sucv_rec.industry_code = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.industry_code := NULL;
    END IF;
    --Bug# 3313802
    --IF (l_sucv_rec.maximum_subsidy_amount = OKL_API.G_MISS_NUM ) THEN
      --l_sucv_rec.maximum_subsidy_amount := NULL;
    --END IF;
    IF (l_sucv_rec.maximum_financed_amount = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.maximum_financed_amount := NULL;
    END IF;
    --Bug# 3508166
    IF (l_sucv_rec.sales_territory_id = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.sales_territory_id := NULL;
    END IF;
    IF (l_sucv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute_category := NULL;
    END IF;
    IF (l_sucv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute1 := NULL;
    END IF;
    IF (l_sucv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute2 := NULL;
    END IF;
    IF (l_sucv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute3 := NULL;
    END IF;
    IF (l_sucv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute4 := NULL;
    END IF;
    IF (l_sucv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute5 := NULL;
    END IF;
    IF (l_sucv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute6 := NULL;
    END IF;
    IF (l_sucv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute7 := NULL;
    END IF;
    IF (l_sucv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute8 := NULL;
    END IF;
    IF (l_sucv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute9 := NULL;
    END IF;
    IF (l_sucv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute10 := NULL;
    END IF;
    IF (l_sucv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute11 := NULL;
    END IF;
    IF (l_sucv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute12 := NULL;
    END IF;
    IF (l_sucv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute13 := NULL;
    END IF;
    IF (l_sucv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute14 := NULL;
    END IF;
    IF (l_sucv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_sucv_rec.attribute15 := NULL;
    END IF;
    IF (l_sucv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.created_by := NULL;
    END IF;
    IF (l_sucv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_sucv_rec.creation_date := NULL;
    END IF;
    IF (l_sucv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sucv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_sucv_rec.last_update_date := NULL;
    END IF;
    IF (l_sucv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_sucv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sucv_rec);
  END null_out_defaults;

  ---****HANDCODED FUNCTION TO GET DISPLAY SEQUENCE
  ---------------------------------------------------------------------------
  -- FUNCTION get_display_sequence (handcoded) :avsingh
  ---------------------------------------------------------------------------
  FUNCTION get_display_sequence (p_sucv_rec IN sucv_rec_type) RETURN NUMBER IS
  --cursor to get display sequence
  cursor l_dispseq_csr(p_subsidy_id in number) is
  select nvl(max(display_sequence),0)+5
  from   okl_subsidy_criteria
  where  subsidy_id = p_subsidy_id;

  l_display_sequence number default null;

  BEGIN
      open l_dispseq_csr(p_subsidy_id => p_sucv_rec.subsidy_id);
      fetch l_dispseq_csr into l_display_sequence;
      If l_dispseq_csr%NOTFOUND then
          null;
      End If;
      close l_dispseq_csr;

      RETURN(l_display_sequence);
      Exception
      When Others then
          RETURN(l_display_sequence);
  END get_display_sequence;
  ---****END OF HANDCODED FUNCTION TO GET DISPLAY SEQUENCE

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
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
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

  -----------------------------------------
  -- Validate_Attributes for: SUBSIDY_ID --
  -----------------------------------------
  PROCEDURE validate_subsidy_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_subsidy_id                   IN NUMBER) IS
    Cursor subb_csr(p_subsidy_id in number) is
    Select 'Y'
    from   okl_subsidies_b subb
    where  id = p_subsidy_id;

    l_exists varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_subsidy_id = OKL_API.G_MISS_NUM OR
        p_subsidy_id IS NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'subsidy_id');
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Subsidy');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
      --handcoded foreign key validation
    ELSE -- if not null and g_miss_num
      l_exists := 'N';
      Open subb_csr(p_subsidy_id => p_subsidy_id);
      Fetch subb_csr into l_exists;
      If subb_csr%NOTFOUND then
          Null;
      End If;
      Close subb_csr;
      If l_exists = 'N' Then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SUBSIDY_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If subb_csr%ISOPEN then
          close subb_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_subsidy_id;
----------------------------------
--Start of Hand coded validations
---------------------------------
  --Bug# 3508166 :
  -----------------------------------------
  -- Validate_Attributes for: SALES_TERRITORY_CODE --
  -----------------------------------------
  PROCEDURE validate_sales_territory(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_sales_territory_id  IN NUMBER) IS
    --p_sales_territory_code  IN VARCHAR2) IS
    --Bug# 3508166 :
    Cursor terr_csr(p_sales_territory_id in number) is
    Select 'Y'
    From   ra_territories RAT
    where  RAT.territory_id = p_sales_territory_id
    and    RAT.enabled_flag = 'Y'
    and    nvl(RAT.status,'I') = 'A'
    and    sysdate between nvl(RAT.start_date_active,sysdate) and nvl(RAT.end_date_active,sysdate);

    --Cursor terr_csr(p_sales_territory_code in varchar2) is
    --Select 'Y'
    --from   fnd_territories terr
    --where  territory_code = p_sales_territory_code;

    l_exists varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_sales_territory_ID <> OKL_API.G_MISS_NUM AND
    --IF (p_sales_territory_code <> OKL_API.G_MISS_CHAR AND
        p_sales_territory_id IS NOT NULL)
        --p_sales_territory_code IS NOT NULL)
    THEN
      l_exists := 'N';
      Open terr_csr(p_sales_territory_id => p_sales_territory_id);
      --Open terr_csr(p_sales_territory_code => p_sales_territory_code);
      Fetch terr_csr into l_exists;
      If terr_csr%NOTFOUND then
          Null;
      End If;
      Close terr_csr;
      If l_exists = 'N' Then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SALES_TERRITORY_CODE');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Sales Territory');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If terr_csr%ISOPEN then
          close terr_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_sales_territory;

  -----------------------------------------
  -- Validate_Attributes for: PRODUCT_ID --
  -----------------------------------------
  PROCEDURE validate_product_id(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_product_id  IN NUMBER) IS
    Cursor pdt_csr(p_product_id in number) is
    Select 'Y'
    from   okl_product_parameters_v pdt
    where  id = p_product_id
    and sysdate between nvl(pdt.from_date,sysdate) and nvl(pdt.to_date,sysdate);

    l_exists varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_product_id <> OKL_API.G_MISS_NUM AND
        p_product_id IS NOT NULL)
    THEN
      l_exists := 'N';
      Open pdt_csr(p_product_id => p_product_id);
      Fetch pdt_csr into l_exists;
      If pdt_csr%NOTFOUND then
          Null;
      End If;
      Close pdt_csr;
      If l_exists = 'N' Then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PRODUCT_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Product');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If pdt_csr%ISOPEN then
          close pdt_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_product_id;
  -------------------------------------------------------
  -- Validate_Attributes for: CREDIT_CLASSIFICATION_CODE--
  ----------------------------------------------------------
  PROCEDURE validate_credit_class(
    x_return_status               OUT NOCOPY VARCHAR2,
    p_credit_classification_code  IN VARCHAR2) IS
    Cursor crdt_class_csr(p_credit_classification_code in varchar2) is
    Select 'Y'
    From   ar_lookups arlk
    where  arlk.lookup_type = 'AR_CMGT_TRADE_RATINGS'
    and    arlk.lookup_code = p_credit_classification_code
    and    nvl(arlk.enabled_flag,'N') = 'Y'
    and    sysdate between nvl(arlk.start_date_active,sysdate)
                   and nvl(arlk.end_date_active,sysdate);
    l_exists varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_credit_classification_code <> OKL_API.G_MISS_CHAR AND
        p_credit_classification_code IS NOT NULL)
    THEN
      l_exists := 'N';
      Open crdt_class_csr(p_credit_classification_code => p_credit_classification_code);
      Fetch crdt_class_csr into l_exists;
      If crdt_class_csr%NOTFOUND then
          Null;
      End If;
      Close crdt_class_csr;
      If l_exists = 'N' Then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CREDIT_CLASSIFICATION_CODE');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Customer Credit Class');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If crdt_class_csr%ISOPEN then
          close crdt_class_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_credit_class;
  ---------------------------------------------------------------
  -- Validate_Attributes for: INDUSTRY_TYPE_CODE
  ---------------------------------------------------------------
  PROCEDURE validate_industry_code_type(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_industry_code_type    IN  VARCHAR2) IS

    Cursor sic_type_csr(p_industry_code_type in varchar2) is
    Select 'Y'
    From   ar_lookups arlk
    where  arlk.lookup_type = 'SIC_CODE_TYPE'
    and    arlk.lookup_code = p_industry_code_type
    and    nvl(arlk.enabled_flag,'N') = 'Y'
    and    sysdate between nvl(arlk.start_date_active,sysdate)
                   and nvl(arlk.end_date_active,sysdate);

    l_exists varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_industry_code_type <> OKL_API.G_MISS_CHAR AND
        p_industry_code_type IS NOT NULL)
    THEN
      l_exists := 'N';
      Open sic_type_csr(p_industry_code_type => p_industry_code_type);
      Fetch sic_type_csr into l_exists;
      If sic_type_csr%NOTFOUND then
          Null;
      End If;
      Close sic_type_csr;
      If l_exists = 'N' Then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'INDUSTRY_CODE_TYPE');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Industry Code Type');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If sic_type_csr%ISOPEN then
          close sic_type_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_industry_code_type;

  ---------------------------------------------------------------
  -- Validate_Attributes for: ORGANIZATION_ID
  ---------------------------------------------------------------
  PROCEDURE validate_organization_id(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_organization_id       IN  VARCHAR2) IS

    Cursor org_csr(p_organization_id in number) is
    Select 'Y'
    From   mtl_parameters mp
    where  mp.organization_id = p_organization_id;

    l_exists varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_organization_id <> OKL_API.G_MISS_NUM AND
        p_organization_id IS NOT NULL)
    THEN
      l_exists := 'N';
      Open org_csr(p_organization_id => p_organization_id);
      Fetch org_csr into l_exists;
      If org_csr%NOTFOUND then
          Null;
      End If;
      Close org_csr;
      If l_exists = 'N' Then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ORGANIZATION_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Inventory Organization');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If org_csr%ISOPEN then
          close org_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_organization_id;

--------------------------------------------------------------
--End of handcoded validations
--------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKL_SUBSIDY_CRITERIA_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sucv_rec                     IN sucv_rec_type
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
    validate_id(x_return_status, p_sucv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_sucv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- ***
    -- subsidy_id
    -- ***
    validate_subsidy_id(x_return_status, p_sucv_rec.subsidy_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- SALES_TERRITORY_CODE
    -- ***
    --Bug# 3508166 :
    validate_sales_territory(x_return_status, p_sucv_rec.sales_territory_id);
    --validate_sales_territory(x_return_status, p_sucv_rec.sales_territory_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    --  PRODUCT_ID
    -- ***
    validate_product_id(x_return_status, p_sucv_rec.product_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    --  CREDIT_CLASSIFICATION_CODE
    -- ***
    validate_credit_class(x_return_status, p_sucv_rec.credit_classification_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    --  INDUSTRY_CODE_TYPE
    -- ***
    validate_industry_code_type(x_return_status, p_sucv_rec.industry_code_type);
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
  ------------------------------------------------
  -- Validate Record for:OKL_SUBSIDY_CRITERIA_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_sucv_rec IN sucv_rec_type,
    p_db_sucv_rec IN sucv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ---------------------------------------------
    ---***Handcoded function to validate record
    ---------------------------------------------
    -- FUNCTION validate_foreign_keys and other functional constrains --
    ---------------------------------------------
    FUNCTION validate_ref_integrity (
      p_sucv_rec IN sucv_rec_type,
      p_db_sucv_rec IN sucv_rec_type
    ) RETURN VARCHAR2 IS
      violated_ref_integrity           EXCEPTION;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

      --cursor to validate foreign key for inventory item id
      cursor l_invitm_csr (p_inventory_item_id in number,
                           p_organization_id in number) is
      Select 'Y'
      from   mtl_system_items_b mtlb
      where  inventory_item_id  =  p_inventory_item_id
      and    organization_id    =  p_organization_id;

      --cursor to validate foreign key for Industry code
      cursor l_sic_code_csr (p_industry_code_type in varchar2,
                             p_industry_code      in varchar2) is
      select 'Y'
      from   ar_lookups
      where  lookup_type = p_industry_code_type
      and    lookup_code = p_industry_code
      and    nvl(enabled_flag,'N') = 'Y'
      and    sysdate between nvl(start_date_active,sysdate)
             and nvl(end_date_active,sysdate);



      l_exists varchar2(1) default 'N';

    BEGIN
       l_return_status           := OKL_API.G_RET_STS_SUCCESS;
       ----------------------------------------------------------------
       --1. inventory item should be specified only if org is specified
       --   and both should satisfy the referential integrity critera
       ----------------------------------------------------------------
       If p_sucv_rec.inventory_item_id is not null and
          p_sucv_rec.organization_id is null then
           OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Inventory Organization');
             RAISE violated_ref_integrity;
       Elsif p_sucv_rec.inventory_item_id is not null and
             p_sucv_rec.organization_id is not null then
           --do foreign key  validation
           l_exists := 'N';
           Open l_invitm_csr (p_inventory_item_id => p_sucv_rec.inventory_item_id,
                              p_organization_id   => p_sucv_rec.organization_id);
           Fetch l_invitm_csr into l_exists;
           If l_invitm_csr%NOTFOUND then
               Null;
           End If;
           Close l_invitm_csr;
           IF l_exists = 'N' then
              --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'INVENTORY_ITEM_ID');
              OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Item');
              RAISE violated_ref_integrity;
           END IF;
       End If;
       -------------------------------------------------------------------------
       --2. SIC code should be specified only if SIC code type is specified
       --   Foreign key validation on SIC Code
       -------------------------------------------------------------------------
       If p_sucv_rec.industry_code is not null and
          p_sucv_rec.industry_code_type is null then
           OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Industry Code Type');
             RAISE violated_ref_integrity;
       Elsif p_sucv_rec.industry_code is not null and
             p_sucv_rec.industry_code_type is not null then
           --do foreign key  validation
           l_exists := 'N';
           Open l_sic_code_csr (p_industry_code_type => p_sucv_rec.industry_code_type,
                                p_industry_code      => p_sucv_rec.industry_code);
           Fetch l_sic_code_csr into l_exists;
           If l_sic_code_csr%NOTFOUND then
               Null;
           End If;
           Close l_sic_code_csr;
           IF l_exists = 'N' then
              --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'INVENTORY_ITEM_ID');
              OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Industry Code');
              RAISE violated_ref_integrity;
           END IF;
       End If;

       /*---bug#3313802---------------------------------------------------------
       -------------------------------------------------------------------------
       --3. Maximum subsidy should be specified if particular inventory item is
       --   specified
       -------------------------------------------------------------------------
       --If p_sucv_rec.maximum_subsidy_amount is not null and
          --p_sucv_rec.inventory_item_id is null then
           --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Item');
             --RAISE violated_ref_integrity;
       --End If;

       -------------------------------------------------------------------------
       --4. Maximum financed amount should be specified if particular inventory item
       --   is specified
       -------------------------------------------------------------------------
       --If p_sucv_rec.maximum_financed_amount is not null and
          --p_sucv_rec.inventory_item_id is null then
           --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Item');
             --RAISE violated_ref_integrity;
       --End If;
       ---------------------------Bug# 3313802---------------------------------*/

      RETURN (l_return_status);
    EXCEPTION
      WHEN violated_ref_integrity THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_ref_integrity;
    ----------------------------------------------------
    ---***End of Handcoded function to validate record
    -----------------------------------------------------

  BEGIN
    l_return_status := validate_ref_integrity(p_sucv_rec, p_db_sucv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_sucv_rec IN sucv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_sucv_rec                  sucv_rec_type := get_rec(p_sucv_rec);
  BEGIN
    l_return_status := Validate_Record(p_sucv_rec => p_sucv_rec,
                                       p_db_sucv_rec => l_db_sucv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN sucv_rec_type,
    p_to   IN OUT NOCOPY suc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.subsidy_id := p_from.subsidy_id;
    p_to.display_sequence := p_from.display_sequence;
    p_to.inventory_item_id := p_from.inventory_item_id;
    p_to.organization_id := p_from.organization_id;
    p_to.credit_classification_code := p_from.credit_classification_code;
    p_to.sales_territory_code := p_from.sales_territory_code;
    p_to.product_id := p_from.product_id;
    p_to.industry_code_type := p_from.industry_code_type;
    p_to.industry_code := p_from.industry_code;
    --Bug# 3313802
    --p_to.maximum_subsidy_amount := p_from.maximum_subsidy_amount;
    p_to.maximum_financed_amount := p_from.maximum_financed_amount;
    --Bug# 3508166
    p_to.sales_territory_id := p_from.sales_territory_id;
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
    p_from IN suc_rec_type,
    p_to   IN OUT NOCOPY sucv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.subsidy_id := p_from.subsidy_id;
    p_to.display_sequence := p_from.display_sequence;
    p_to.inventory_item_id := p_from.inventory_item_id;
    p_to.organization_id := p_from.organization_id;
    p_to.credit_classification_code := p_from.credit_classification_code;
    p_to.sales_territory_code := p_from.sales_territory_code;
    p_to.product_id := p_from.product_id;
    p_to.industry_code_type := p_from.industry_code_type;
    p_to.industry_code := p_from.industry_code;
    --Bug# 3313802
    --p_to.maximum_subsidy_amount := p_from.maximum_subsidy_amount;
    p_to.maximum_financed_amount := p_from.maximum_financed_amount;
    --Bug# 3508166
    p_to.sales_territory_id := p_from.sales_territory_id;
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
  ---------------------------------------------
  -- validate_row for:OKL_SUBSIDY_CRITERIA_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN sucv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sucv_rec                     sucv_rec_type := p_sucv_rec;
    l_suc_rec                      suc_rec_type;
    l_suc_rec                      suc_rec_type;
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
    l_return_status := Validate_Attributes(l_sucv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sucv_rec);
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
  --------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_SUBSIDY_CRITERIA_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      i := p_sucv_tbl.FIRST;
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
            p_sucv_rec                     => p_sucv_tbl(i));
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
        EXIT WHEN (i = p_sucv_tbl.LAST);
        i := p_sucv_tbl.NEXT(i);
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

  --------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_SUBSIDY_CRITERIA_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sucv_tbl                     => p_sucv_tbl,
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
  -- insert_row for:OKL_SUBSIDY_CRITERIA --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_suc_rec                      IN suc_rec_type,
    x_suc_rec                      OUT NOCOPY suc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_suc_rec                      suc_rec_type := p_suc_rec;
    l_def_suc_rec                  suc_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SUBSIDY_CRITERIA --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_suc_rec IN suc_rec_type,
      x_suc_rec OUT NOCOPY suc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_suc_rec := p_suc_rec;
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
      p_suc_rec,                         -- IN
      l_suc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SUBSIDY_CRITERIA(
      id,
      object_version_number,
      subsidy_id,
      display_sequence,
      inventory_item_id,
      organization_id,
      credit_classification_code,
      sales_territory_code,
      product_id,
      industry_code_type,
      industry_code,
      --Bug# 3313802
      --maximum_subsidy_amount,
      maximum_financed_amount,
      --Bug# 3508166
      sales_territory_id,
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
      l_suc_rec.id,
      l_suc_rec.object_version_number,
      l_suc_rec.subsidy_id,
      l_suc_rec.display_sequence,
      l_suc_rec.inventory_item_id,
      l_suc_rec.organization_id,
      l_suc_rec.credit_classification_code,
      l_suc_rec.sales_territory_code,
      l_suc_rec.product_id,
      l_suc_rec.industry_code_type,
      l_suc_rec.industry_code,
      --Bug# 3313802
      --l_suc_rec.maximum_subsidy_amount,
      l_suc_rec.maximum_financed_amount,
      --Bug# 3508166
      l_suc_rec.sales_territory_id,
      l_suc_rec.attribute_category,
      l_suc_rec.attribute1,
      l_suc_rec.attribute2,
      l_suc_rec.attribute3,
      l_suc_rec.attribute4,
      l_suc_rec.attribute5,
      l_suc_rec.attribute6,
      l_suc_rec.attribute7,
      l_suc_rec.attribute8,
      l_suc_rec.attribute9,
      l_suc_rec.attribute10,
      l_suc_rec.attribute11,
      l_suc_rec.attribute12,
      l_suc_rec.attribute13,
      l_suc_rec.attribute14,
      l_suc_rec.attribute15,
      l_suc_rec.created_by,
      l_suc_rec.creation_date,
      l_suc_rec.last_updated_by,
      l_suc_rec.last_update_date,
      l_suc_rec.last_update_login);
    -- Set OUT values
    x_suc_rec := l_suc_rec;
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
  --------------------------------------------
  -- insert_row for :OKL_SUBSIDY_CRITERIA_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN sucv_rec_type,
    x_sucv_rec                     OUT NOCOPY sucv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sucv_rec                     sucv_rec_type := p_sucv_rec;
    l_def_sucv_rec                 sucv_rec_type;
    l_suc_rec                      suc_rec_type;
    lx_suc_rec                     suc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sucv_rec IN sucv_rec_type
    ) RETURN sucv_rec_type IS
      l_sucv_rec sucv_rec_type := p_sucv_rec;
    BEGIN
      l_sucv_rec.CREATION_DATE := SYSDATE;
      l_sucv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sucv_rec.LAST_UPDATE_DATE := l_sucv_rec.CREATION_DATE;
      l_sucv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sucv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sucv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKL_SUBSIDY_CRITERIA_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sucv_rec IN sucv_rec_type,
      x_sucv_rec OUT NOCOPY sucv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sucv_rec := p_sucv_rec;
      x_sucv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_sucv_rec := null_out_defaults(p_sucv_rec);
    -- Set primary key value
    l_sucv_rec.ID := get_seq_id;

    --avsingh : custome code added to set display sequence
    If l_sucv_rec.display_sequence is NULL then
        l_sucv_rec.display_sequence := get_display_sequence(p_sucv_rec);
    End If;
    --avsingh : end of custom code to set display sequence

    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_sucv_rec,                        -- IN
      l_def_sucv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sucv_rec := fill_who_columns(l_def_sucv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sucv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sucv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sucv_rec, l_suc_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_suc_rec,
      lx_suc_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_suc_rec, l_def_sucv_rec);
    -- Set OUT values
    x_sucv_rec := l_def_sucv_rec;
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
  -- PL/SQL TBL insert_row for:SUCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type,
    x_sucv_tbl                     OUT NOCOPY  sucv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      i := p_sucv_tbl.FIRST;
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
            p_sucv_rec                     => p_sucv_tbl(i),
            x_sucv_rec                     => x_sucv_tbl(i));
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
        EXIT WHEN (i = p_sucv_tbl.LAST);
        i := p_sucv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:SUCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type,
    x_sucv_tbl                     OUT NOCOPY sucv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sucv_tbl                     => p_sucv_tbl,
        x_sucv_tbl                     => x_sucv_tbl,
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
  -- lock_row for:OKL_SUBSIDY_CRITERIA --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_suc_rec                      IN suc_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_suc_rec IN suc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SUBSIDY_CRITERIA
     WHERE ID = p_suc_rec.id
     AND OBJECT_VERSION_NUMBER = p_suc_rec.object_version_number
     FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

   CURSOR lchk_csr (p_suc_rec IN suc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SUBSIDY_CRITERIA
     WHERE ID = p_suc_rec.id;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_SUBSIDY_CRITERIA.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_SUBSIDY_CRITERIA.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_suc_rec);
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
      OPEN lchk_csr(p_suc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_suc_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_suc_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for: OKL_SUBSIDY_CRITERIA_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN sucv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_suc_rec                      suc_rec_type;
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
    migrate(p_sucv_rec, l_suc_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_suc_rec
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
  -- PL/SQL TBL lock_row for:SUCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      i := p_sucv_tbl.FIRST;
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
            p_sucv_rec                     => p_sucv_tbl(i));
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
        EXIT WHEN (i = p_sucv_tbl.LAST);
        i := p_sucv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:SUCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sucv_tbl                     => p_sucv_tbl,
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
  -- update_row for:OKL_SUBSIDY_CRITERIA --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_suc_rec                      IN suc_rec_type,
    x_suc_rec                      OUT NOCOPY suc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_suc_rec                      suc_rec_type := p_suc_rec;
    l_def_suc_rec                  suc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_suc_rec IN suc_rec_type,
      x_suc_rec OUT NOCOPY suc_rec_type
    ) RETURN VARCHAR2 IS
      l_suc_rec                      suc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_suc_rec := p_suc_rec;
      -- Get current database values
      l_suc_rec := get_rec(p_suc_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_suc_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.id := l_suc_rec.id;
        END IF;
        IF (x_suc_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.object_version_number := l_suc_rec.object_version_number;
        END IF;
        IF (x_suc_rec.subsidy_id = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.subsidy_id := l_suc_rec.subsidy_id;
        END IF;
        IF (x_suc_rec.display_sequence = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.display_sequence := l_suc_rec.display_sequence;
        END IF;
        IF (x_suc_rec.inventory_item_id = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.inventory_item_id := l_suc_rec.inventory_item_id;
        END IF;
        IF (x_suc_rec.organization_id = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.organization_id := l_suc_rec.organization_id;
        END IF;
        IF (x_suc_rec.credit_classification_code = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.credit_classification_code := l_suc_rec.credit_classification_code;
        END IF;
        IF (x_suc_rec.sales_territory_code = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.sales_territory_code := l_suc_rec.sales_territory_code;
        END IF;
        IF (x_suc_rec.product_id = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.product_id := l_suc_rec.product_id;
        END IF;
        IF (x_suc_rec.industry_code_type = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.industry_code_type := l_suc_rec.industry_code_type;
        END IF;
        IF (x_suc_rec.industry_code = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.industry_code := l_suc_rec.industry_code;
        END IF;
        --Bug# 3313802:
        --IF (x_suc_rec.maximum_subsidy_amount = OKL_API.G_MISS_NUM)
        --THEN
          --x_suc_rec.maximum_subsidy_amount := l_suc_rec.maximum_subsidy_amount;
        --END IF;
        IF (x_suc_rec.maximum_financed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.maximum_financed_amount := l_suc_rec.maximum_financed_amount;
        END IF;
        --bug# 3508166
        IF (x_suc_rec.sales_territory_id = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.sales_territory_id := l_suc_rec.sales_territory_id;
        END IF;
        IF (x_suc_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute_category := l_suc_rec.attribute_category;
        END IF;
        IF (x_suc_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute1 := l_suc_rec.attribute1;
        END IF;
        IF (x_suc_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute2 := l_suc_rec.attribute2;
        END IF;
        IF (x_suc_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute3 := l_suc_rec.attribute3;
        END IF;
        IF (x_suc_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute4 := l_suc_rec.attribute4;
        END IF;
        IF (x_suc_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute5 := l_suc_rec.attribute5;
        END IF;
        IF (x_suc_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute6 := l_suc_rec.attribute6;
        END IF;
        IF (x_suc_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute7 := l_suc_rec.attribute7;
        END IF;
        IF (x_suc_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute8 := l_suc_rec.attribute8;
        END IF;
        IF (x_suc_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute9 := l_suc_rec.attribute9;
        END IF;
        IF (x_suc_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute10 := l_suc_rec.attribute10;
        END IF;
        IF (x_suc_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute11 := l_suc_rec.attribute11;
        END IF;
        IF (x_suc_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute12 := l_suc_rec.attribute12;
        END IF;
        IF (x_suc_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute13 := l_suc_rec.attribute13;
        END IF;
        IF (x_suc_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute14 := l_suc_rec.attribute14;
        END IF;
        IF (x_suc_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_suc_rec.attribute15 := l_suc_rec.attribute15;
        END IF;
        IF (x_suc_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.created_by := l_suc_rec.created_by;
        END IF;
        IF (x_suc_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_suc_rec.creation_date := l_suc_rec.creation_date;
        END IF;
        IF (x_suc_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.last_updated_by := l_suc_rec.last_updated_by;
        END IF;
        IF (x_suc_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_suc_rec.last_update_date := l_suc_rec.last_update_date;
        END IF;
        IF (x_suc_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_suc_rec.last_update_login := l_suc_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SUBSIDY_CRITERIA --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_suc_rec IN suc_rec_type,
      x_suc_rec OUT NOCOPY suc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_suc_rec := p_suc_rec;
      x_suc_rec.OBJECT_VERSION_NUMBER := p_suc_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_suc_rec,                         -- IN
      l_suc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_suc_rec, l_def_suc_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_SUBSIDY_CRITERIA
    SET OBJECT_VERSION_NUMBER = l_def_suc_rec.OBJECT_VERSION_NUMBER,
        SUBSIDY_ID = l_def_suc_rec.subsidy_id,
        DISPLAY_SEQUENCE = l_def_suc_rec.display_sequence,
        INVENTORY_ITEM_ID = l_def_suc_rec.inventory_item_id,
        ORGANIZATION_ID = l_def_suc_rec.organization_id,
        CREDIT_CLASSIFICATION_CODE = l_def_suc_rec.credit_classification_code,
        SALES_TERRITORY_CODE = l_def_suc_rec.sales_territory_code,
        PRODUCT_ID = l_def_suc_rec.product_id,
        INDUSTRY_CODE_TYPE = l_def_suc_rec.industry_code_type,
        INDUSTRY_CODE = l_def_suc_rec.industry_code,
        --Bug# 3313802:
        --MAXIMUM_SUBSIDY_AMOUNT = l_def_suc_rec.maximum_subsidy_amount,
        MAXIMUM_FINANCED_AMOUNT = l_def_suc_rec.maximum_financed_amount,
        --Bug# 3508166
        SALES_TERRITORY_ID = l_def_suc_rec.sales_territory_id,
        ATTRIBUTE_CATEGORY = l_def_suc_rec.attribute_category,
        ATTRIBUTE1 = l_def_suc_rec.attribute1,
        ATTRIBUTE2 = l_def_suc_rec.attribute2,
        ATTRIBUTE3 = l_def_suc_rec.attribute3,
        ATTRIBUTE4 = l_def_suc_rec.attribute4,
        ATTRIBUTE5 = l_def_suc_rec.attribute5,
        ATTRIBUTE6 = l_def_suc_rec.attribute6,
        ATTRIBUTE7 = l_def_suc_rec.attribute7,
        ATTRIBUTE8 = l_def_suc_rec.attribute8,
        ATTRIBUTE9 = l_def_suc_rec.attribute9,
        ATTRIBUTE10 = l_def_suc_rec.attribute10,
        ATTRIBUTE11 = l_def_suc_rec.attribute11,
        ATTRIBUTE12 = l_def_suc_rec.attribute12,
        ATTRIBUTE13 = l_def_suc_rec.attribute13,
        ATTRIBUTE14 = l_def_suc_rec.attribute14,
        ATTRIBUTE15 = l_def_suc_rec.attribute15,
        CREATED_BY = l_def_suc_rec.created_by,
        CREATION_DATE = l_def_suc_rec.creation_date,
        LAST_UPDATED_BY = l_def_suc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_suc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_suc_rec.last_update_login
    WHERE ID = l_def_suc_rec.id;

    x_suc_rec := l_suc_rec;
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
  -------------------------------------------
  -- update_row for:OKL_SUBSIDY_CRITERIA_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN sucv_rec_type,
    x_sucv_rec                     OUT NOCOPY sucv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sucv_rec                     sucv_rec_type := p_sucv_rec;
    l_def_sucv_rec                 sucv_rec_type;
    l_db_sucv_rec                  sucv_rec_type;
    l_suc_rec                      suc_rec_type;
    lx_suc_rec                     suc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sucv_rec IN sucv_rec_type
    ) RETURN sucv_rec_type IS
      l_sucv_rec sucv_rec_type := p_sucv_rec;
    BEGIN
      l_sucv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sucv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sucv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sucv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sucv_rec IN sucv_rec_type,
      x_sucv_rec OUT NOCOPY sucv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sucv_rec := p_sucv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_sucv_rec := get_rec(p_sucv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_sucv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.id := l_db_sucv_rec.id;
        END IF;
        IF (x_sucv_rec.subsidy_id = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.subsidy_id := l_db_sucv_rec.subsidy_id;
        END IF;
        IF (x_sucv_rec.display_sequence = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.display_sequence := l_db_sucv_rec.display_sequence;
        END IF;
        IF (x_sucv_rec.inventory_item_id = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.inventory_item_id := l_db_sucv_rec.inventory_item_id;
        END IF;
        IF (x_sucv_rec.organization_id = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.organization_id := l_db_sucv_rec.organization_id;
        END IF;
        IF (x_sucv_rec.credit_classification_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.credit_classification_code := l_db_sucv_rec.credit_classification_code;
        END IF;
        IF (x_sucv_rec.sales_territory_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.sales_territory_code := l_db_sucv_rec.sales_territory_code;
        END IF;
        IF (x_sucv_rec.product_id = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.product_id := l_db_sucv_rec.product_id;
        END IF;
        IF (x_sucv_rec.industry_code_type = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.industry_code_type := l_db_sucv_rec.industry_code_type;
        END IF;
        IF (x_sucv_rec.industry_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.industry_code := l_db_sucv_rec.industry_code;
        END IF;
        --Bug# 3313802 :
        --IF (x_sucv_rec.maximum_subsidy_amount = OKL_API.G_MISS_NUM)
        --THEN
          --x_sucv_rec.maximum_subsidy_amount := l_db_sucv_rec.maximum_subsidy_amount;
        --END IF;
        IF (x_sucv_rec.maximum_financed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.maximum_financed_amount := l_db_sucv_rec.maximum_financed_amount;
        END IF;
        --Bug# 3508166
        IF (x_sucv_rec.sales_territory_id = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.sales_territory_id := l_db_sucv_rec.sales_territory_id;
        END IF;
        IF (x_sucv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute_category := l_db_sucv_rec.attribute_category;
        END IF;
        IF (x_sucv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute1 := l_db_sucv_rec.attribute1;
        END IF;
        IF (x_sucv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute2 := l_db_sucv_rec.attribute2;
        END IF;
        IF (x_sucv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute3 := l_db_sucv_rec.attribute3;
        END IF;
        IF (x_sucv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute4 := l_db_sucv_rec.attribute4;
        END IF;
        IF (x_sucv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute5 := l_db_sucv_rec.attribute5;
        END IF;
        IF (x_sucv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute6 := l_db_sucv_rec.attribute6;
        END IF;
        IF (x_sucv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute7 := l_db_sucv_rec.attribute7;
        END IF;
        IF (x_sucv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute8 := l_db_sucv_rec.attribute8;
        END IF;
        IF (x_sucv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute9 := l_db_sucv_rec.attribute9;
        END IF;
        IF (x_sucv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute10 := l_db_sucv_rec.attribute10;
        END IF;
        IF (x_sucv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute11 := l_db_sucv_rec.attribute11;
        END IF;
        IF (x_sucv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute12 := l_db_sucv_rec.attribute12;
        END IF;
        IF (x_sucv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute13 := l_db_sucv_rec.attribute13;
        END IF;
        IF (x_sucv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute14 := l_db_sucv_rec.attribute14;
        END IF;
        IF (x_sucv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_sucv_rec.attribute15 := l_db_sucv_rec.attribute15;
        END IF;
        IF (x_sucv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.created_by := l_db_sucv_rec.created_by;
        END IF;
        IF (x_sucv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_sucv_rec.creation_date := l_db_sucv_rec.creation_date;
        END IF;
        IF (x_sucv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.last_updated_by := l_db_sucv_rec.last_updated_by;
        END IF;
        IF (x_sucv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_sucv_rec.last_update_date := l_db_sucv_rec.last_update_date;
        END IF;
        IF (x_sucv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_sucv_rec.last_update_login := l_db_sucv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_SUBSIDY_CRITERIA_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sucv_rec IN sucv_rec_type,
      x_sucv_rec OUT NOCOPY sucv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sucv_rec := p_sucv_rec;
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
      p_sucv_rec,                        -- IN
      x_sucv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sucv_rec, l_def_sucv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sucv_rec := fill_who_columns(l_def_sucv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sucv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sucv_rec, l_db_sucv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
/***************Hand Commented*********
--avsingh
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_sucv_rec                     => p_sucv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
******************************/
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sucv_rec, l_suc_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_suc_rec,
      lx_suc_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_suc_rec, l_def_sucv_rec);
    x_sucv_rec := l_def_sucv_rec;
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
  -- PL/SQL TBL update_row for:sucv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type,
    x_sucv_tbl                     OUT NOCOPY sucv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      i := p_sucv_tbl.FIRST;
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
            p_sucv_rec                     => p_sucv_tbl(i),
            x_sucv_rec                     => x_sucv_tbl(i));
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
        EXIT WHEN (i = p_sucv_tbl.LAST);
        i := p_sucv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:SUCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type,
    x_sucv_tbl                     OUT NOCOPY sucv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sucv_tbl                     => p_sucv_tbl,
        x_sucv_tbl                     => x_sucv_tbl,
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
  -- delete_row for:OKL_SUBSIDY_CRITERIA --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_suc_rec                      IN suc_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_suc_rec                      suc_rec_type := p_suc_rec;
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

    DELETE FROM OKL_SUBSIDY_CRITERIA
     WHERE ID = p_suc_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKL_SUBSIDY_CRITERIA_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_rec                     IN sucv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sucv_rec                     sucv_rec_type := p_sucv_rec;
    l_suc_rec                      suc_rec_type;
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
    migrate(l_sucv_rec, l_suc_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_suc_rec
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
  ------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_SUBSIDY_CRITERIA_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      i := p_sucv_tbl.FIRST;
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
            p_sucv_rec                     => p_sucv_tbl(i));
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
        EXIT WHEN (i = p_sucv_tbl.LAST);
        i := p_sucv_tbl.NEXT(i);
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

  ------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_SUBSIDY_CRITERIA_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sucv_tbl                     IN sucv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sucv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sucv_tbl                     => p_sucv_tbl,
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

END OKL_SUC_PVT;

/
