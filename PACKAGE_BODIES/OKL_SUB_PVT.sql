--------------------------------------------------------
--  DDL for Package Body OKL_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUB_PVT" AS
/* $Header: OKLSSUBB.pls 120.18 2007/09/28 11:42:07 ssdeshpa noship $ */
  ------------------------------------------------------------------------------
  --global message constants : for custom validations
  ------------------------------------------------------------------------------
  G_SUBSIDY_INVALID_DATES      CONSTANT VARCHAR2(200) := 'OKL_INVALID_END_DATE';
  G_INVALID_RECEIPT_METHOD     CONSTANT VARCHAR2(200) := 'OKL_SUB_INVALID_RECEIPT_METHOD';
  G_INVALID_RECOURSE_FLAG      CONSTANT VARCHAR2(200) := 'OKL_SUB_INVALID_RECOURSE_FLAG';
--cklee:start
  G_NOT_UNIQUE                 CONSTANT VARCHAR2(30) := 'OKL_LLA_NOT_UNIQUE';
--cklee:end
  -- sjalasut start
  G_SUBSIDY_POOL_STATUS CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LLA_SUB_POOL_ACTIVE';
  G_SUBSIDY_POOL_EFFECTIVE_DATES CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LLA_SUB_DATES_NO_OVERLAP';
--cklee 09/12/2005  G_SUBSIDY_ATTACH_ASSET_EXIST CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LL_SUB_ATTACH_ASSET';
  G_SUBSIDY_ATTACH_ASSET_EXIST CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LLA_SUB_ATTACH_ASSET';
  -- sjalasut end

--cklee:start 07/22/05
  G_SUBSIDY_POOL_ASSOC_STATUS CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LLA_SUB_POOL_ASSOC_STATUS';
  G_SUBSIDY_POOL_DISSOC_STATUS CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LLA_SUB_POOL_DISSOC_STATUS';
  G_SUBSIDY_POOL_ASSOC_EXP_POOL CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LLA_SUB_POOL_ASSC_EXP_POOL';
  G_SUBSIDY_POOL_DISOC_EXP_POOL CONSTANT fnd_new_messages.message_name%TYPE := 'OKL_LLA_SUB_POOL_DISC_EXP_POOL';
--cklee:end 07/22/05

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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_SUBSIDIES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_SUBSIDIES_ALL_B  B
         WHERE B.ID =T.ID
        );

    UPDATE OKL_SUBSIDIES_TL T SET(
        SHORT_DESCRIPTION,
        DESCRIPTION) = (SELECT
                                  B.SHORT_DESCRIPTION,
                                  B.DESCRIPTION
                                FROM OKL_SUBSIDIES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_SUBSIDIES_TL SUBB, OKL_SUBSIDIES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_SUBSIDIES_TL (
        ID,
        SHORT_DESCRIPTION,
        DESCRIPTION,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            B.SHORT_DESCRIPTION,
            B.DESCRIPTION,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_SUBSIDIES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_SUBSIDIES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SUBSIDIES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_subv_rec                     IN subv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN subv_rec_type IS
    CURSOR okl_subsidies_v_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            ORG_ID,
            NAME,
            SHORT_DESCRIPTION,
            DESCRIPTION,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            EXPIRE_AFTER_DAYS,
            CURRENCY_CODE,
            EXCLUSIVE_YN,
            APPLICABLE_TO_RELEASE_YN,
            SUBSIDY_CALC_BASIS,
            AMOUNT,
            PERCENT,
            FORMULA_ID,
            rate_points,
            MAXIMUM_TERM,
            VENDOR_ID,
            ACCOUNTING_METHOD_CODE,
            RECOURSE_YN,
            TERMINATION_REFUND_BASIS,
            REFUND_FORMULA_ID,
            STREAM_TYPE_ID,
            RECEIPT_METHOD_CODE,
            CUSTOMER_VISIBLE_YN,
            MAXIMUM_FINANCED_AMOUNT,
            MAXIMUM_SUBSIDY_AMOUNT,
			--Start code changes for Subsidy by fmiao on 10/25/2004--
			TRANSFER_BASIS_CODE,
			--End code changes for Subsidy by fmiao on 10/25/2004--
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
            -- sjalasut added new column for subsidy pools enhancement. start
            SUBSIDY_POOL_ID
            -- sjalasut added new column for subsidy pools enhancement. end
      FROM Okl_Subsidies_V
     WHERE okl_subsidies_v.id   = p_id;
    l_okl_subsidies_v_pk           okl_subsidies_v_pk_csr%ROWTYPE;
    l_subv_rec                     subv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_subsidies_v_pk_csr (p_subv_rec.id);
    FETCH okl_subsidies_v_pk_csr INTO
              l_subv_rec.id,
              l_subv_rec.object_version_number,
              l_subv_rec.sfwt_flag,
              l_subv_rec.org_id,
              l_subv_rec.name,
              l_subv_rec.short_description,
              l_subv_rec.description,
              l_subv_rec.effective_from_date,
              l_subv_rec.effective_to_date,
              l_subv_rec.expire_after_days,
              l_subv_rec.currency_code,
              l_subv_rec.exclusive_yn,
              l_subv_rec.applicable_to_release_yn,
              l_subv_rec.subsidy_calc_basis,
              l_subv_rec.amount,
              l_subv_rec.percent,
              l_subv_rec.formula_id,
              l_subv_rec.rate_points,
              l_subv_rec.maximum_term,
              l_subv_rec.vendor_id,
              l_subv_rec.accounting_method_code,
              l_subv_rec.recourse_yn,
              l_subv_rec.termination_refund_basis,
              l_subv_rec.refund_formula_id,
              l_subv_rec.stream_type_id,
              l_subv_rec.receipt_method_code,
              l_subv_rec.customer_visible_yn,
              l_subv_rec.maximum_financed_amount,
              l_subv_rec.maximum_subsidy_amount,
			  --Start code changes for Subsidy by fmiao on 10/25/2004--
			  l_subv_rec.transfer_basis_code,
			  --End code changes for Subsidy by fmiao on 10/25/2004--
              l_subv_rec.attribute_category,
              l_subv_rec.attribute1,
              l_subv_rec.attribute2,
              l_subv_rec.attribute3,
              l_subv_rec.attribute4,
              l_subv_rec.attribute5,
              l_subv_rec.attribute6,
              l_subv_rec.attribute7,
              l_subv_rec.attribute8,
              l_subv_rec.attribute9,
              l_subv_rec.attribute10,
              l_subv_rec.attribute11,
              l_subv_rec.attribute12,
              l_subv_rec.attribute13,
              l_subv_rec.attribute14,
              l_subv_rec.attribute15,
              l_subv_rec.created_by,
              l_subv_rec.creation_date,
              l_subv_rec.last_updated_by,
              l_subv_rec.last_update_date,
              l_subv_rec.last_update_login,
              -- sjalasut added new column for subsidy pools enhancement. start
              l_subv_rec.subsidy_pool_id;
              -- sjalasut added new column for subsidy pools enhancement. end
    x_no_data_found := okl_subsidies_v_pk_csr%NOTFOUND;
    CLOSE okl_subsidies_v_pk_csr;
    RETURN(l_subv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_subv_rec                     IN subv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN subv_rec_type IS
    l_subv_rec                     subv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_subv_rec := get_rec(p_subv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_subv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_subv_rec                     IN subv_rec_type
  ) RETURN subv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_subv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SUBSIDIES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_subt_rec                     IN subt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN subt_rec_type IS
    CURSOR okl_subsidies_tl_pk_csr (p_id       IN NUMBER,
                                    p_language IN VARCHAR2) IS
    SELECT
            ID,
            SHORT_DESCRIPTION,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Subsidies_Tl
     WHERE okl_subsidies_tl.id  = p_id
       AND okl_subsidies_tl.language = p_language;
    l_okl_subsidies_tl_pk          okl_subsidies_tl_pk_csr%ROWTYPE;
    l_subt_rec                     subt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_subsidies_tl_pk_csr (p_subt_rec.id,
                                  p_subt_rec.language);
    FETCH okl_subsidies_tl_pk_csr INTO
              l_subt_rec.id,
              l_subt_rec.short_description,
              l_subt_rec.description,
              l_subt_rec.language,
              l_subt_rec.source_lang,
              l_subt_rec.sfwt_flag,
              l_subt_rec.created_by,
              l_subt_rec.creation_date,
              l_subt_rec.last_updated_by,
              l_subt_rec.last_update_date,
              l_subt_rec.last_update_login;
    x_no_data_found := okl_subsidies_tl_pk_csr%NOTFOUND;
    CLOSE okl_subsidies_tl_pk_csr;
    RETURN(l_subt_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_subt_rec                     IN subt_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN subt_rec_type IS
    l_subt_rec                     subt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_subt_rec := get_rec(p_subt_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_subt_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_subt_rec                     IN subt_rec_type
  ) RETURN subt_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_subt_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SUBSIDIES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_subb_rec                     IN subb_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN subb_rec_type IS
    CURSOR okl_subsidies_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            NAME,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            EXPIRE_AFTER_DAYS,
            CURRENCY_CODE,
            EXCLUSIVE_YN,
            APPLICABLE_TO_RELEASE_YN,
            SUBSIDY_CALC_BASIS,
            AMOUNT,
            PERCENT,
            FORMULA_ID,
            rate_points,
            MAXIMUM_TERM,
            VENDOR_ID,
            ACCOUNTING_METHOD_CODE,
            RECOURSE_YN,
            TERMINATION_REFUND_BASIS,
            REFUND_FORMULA_ID,
            STREAM_TYPE_ID,
            RECEIPT_METHOD_CODE,
            CUSTOMER_VISIBLE_YN,
            MAXIMUM_FINANCED_AMOUNT,
            MAXIMUM_SUBSIDY_AMOUNT,
			--Start code changes for Subsidy by fmiao on 10/25/2004--
			TRANSFER_BASIS_CODE,
			--End code changes for Subsidy by fmiao on 10/25/2004--
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
            -- sjalasut added new column for subsidy pools enhancement. start
            SUBSIDY_POOL_ID
            -- sjalasut added new column for subsidy pools enhancement. end
      FROM Okl_Subsidies_B
     WHERE okl_subsidies_b.id   = p_id;
    l_okl_subsidies_b_pk           okl_subsidies_b_pk_csr%ROWTYPE;
    l_subb_rec                     subb_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_subsidies_b_pk_csr (p_subb_rec.id);
    FETCH okl_subsidies_b_pk_csr INTO
              l_subb_rec.id,
              l_subb_rec.object_version_number,
              l_subb_rec.org_id,
              l_subb_rec.name,
              l_subb_rec.effective_from_date,
              l_subb_rec.effective_to_date,
              l_subb_rec.expire_after_days,
              l_subb_rec.currency_code,
              l_subb_rec.exclusive_yn,
              l_subb_rec.applicable_to_release_yn,
              l_subb_rec.subsidy_calc_basis,
              l_subb_rec.amount,
              l_subb_rec.percent,
              l_subb_rec.formula_id,
              l_subb_rec.rate_points,
              l_subb_rec.maximum_term,
              l_subb_rec.vendor_id,
              l_subb_rec.accounting_method_code,
              l_subb_rec.recourse_yn,
              l_subb_rec.termination_refund_basis,
              l_subb_rec.refund_formula_id,
              l_subb_rec.stream_type_id,
              l_subb_rec.receipt_method_code,
              l_subb_rec.customer_visible_yn,
              l_subb_rec.maximum_financed_amount,
              l_subb_rec.maximum_subsidy_amount,
			  --Start code changes for Subsidy by fmiao on 10/25/2004--
			  l_subb_rec.transfer_basis_code,
			  --End code changes for Subsidy by fmiao on 10/25/2004--
              l_subb_rec.attribute_category,
              l_subb_rec.attribute1,
              l_subb_rec.attribute2,
              l_subb_rec.attribute3,
              l_subb_rec.attribute4,
              l_subb_rec.attribute5,
              l_subb_rec.attribute6,
              l_subb_rec.attribute7,
              l_subb_rec.attribute8,
              l_subb_rec.attribute9,
              l_subb_rec.attribute10,
              l_subb_rec.attribute11,
              l_subb_rec.attribute12,
              l_subb_rec.attribute13,
              l_subb_rec.attribute14,
              l_subb_rec.attribute15,
              l_subb_rec.created_by,
              l_subb_rec.creation_date,
              l_subb_rec.last_updated_by,
              l_subb_rec.last_update_date,
              l_subb_rec.last_update_login,
              -- sjalasut added new column for subsidy pools enhancement. start
              l_subb_rec.subsidy_pool_id;
              -- sjalasut added new column for subsidy pools enhancement. end
    x_no_data_found := okl_subsidies_b_pk_csr%NOTFOUND;
    CLOSE okl_subsidies_b_pk_csr;
    RETURN(l_subb_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_subb_rec                     IN subb_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN subb_rec_type IS
    l_subb_rec                     subb_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_subb_rec := get_rec(p_subb_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_subb_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_subb_rec                     IN subb_rec_type
  ) RETURN subb_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_subb_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SUBSIDIES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_subv_rec   IN subv_rec_type
  ) RETURN subv_rec_type IS
    l_subv_rec                     subv_rec_type := p_subv_rec;
  BEGIN
    IF (l_subv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.id := NULL;
    END IF;
    IF (l_subv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.object_version_number := NULL;
    END IF;
    IF (l_subv_rec.sfwt_flag = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_subv_rec.org_id = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.org_id := NULL;
    END IF;
    IF (l_subv_rec.name = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.name := NULL;
    END IF;
    IF (l_subv_rec.short_description = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.short_description := NULL;
    END IF;
    IF (l_subv_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.description := NULL;
    END IF;
    IF (l_subv_rec.effective_from_date = OKL_API.G_MISS_DATE ) THEN
      l_subv_rec.effective_from_date := NULL;
    END IF;
    IF (l_subv_rec.effective_to_date = OKL_API.G_MISS_DATE ) THEN
      l_subv_rec.effective_to_date := NULL;
    END IF;
    IF (l_subv_rec.expire_after_days = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.expire_after_days := NULL;
    END IF;
    IF (l_subv_rec.currency_code = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.currency_code := NULL;
    END IF;
    IF (l_subv_rec.exclusive_yn = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.exclusive_yn := NULL;
    END IF;
    IF (l_subv_rec.applicable_to_release_yn = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.applicable_to_release_yn := NULL;
    END IF;
    IF (l_subv_rec.subsidy_calc_basis = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.subsidy_calc_basis := NULL;
    END IF;
    IF (l_subv_rec.amount = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.amount := NULL;
    END IF;
    IF (l_subv_rec.percent = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.percent := NULL;
    END IF;
    IF (l_subv_rec.formula_id = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.formula_id := NULL;
    END IF;
    IF (l_subv_rec.rate_points = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.rate_points := NULL;
    END IF;
    IF (l_subv_rec.maximum_term = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.maximum_term := NULL;
    END IF;
    IF (l_subv_rec.vendor_id = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.vendor_id := NULL;
    END IF;
    IF (l_subv_rec.accounting_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.accounting_method_code := NULL;
    END IF;
    IF (l_subv_rec.recourse_yn = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.recourse_yn := NULL;
    END IF;
    IF (l_subv_rec.termination_refund_basis = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.termination_refund_basis := NULL;
    END IF;
    IF (l_subv_rec.refund_formula_id = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.refund_formula_id := NULL;
    END IF;
    IF (l_subv_rec.stream_type_id = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.stream_type_id := NULL;
    END IF;
    IF (l_subv_rec.receipt_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.receipt_method_code := NULL;
    END IF;
    IF (l_subv_rec.customer_visible_yn = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.customer_visible_yn := NULL;
    END IF;
    IF (l_subv_rec.maximum_financed_amount = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.maximum_financed_amount := NULL;
    END IF;
    IF (l_subv_rec.maximum_subsidy_amount = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.maximum_subsidy_amount := NULL;
    END IF;
	--Start code changes for Subsidy by fmiao on 10/25/2004--
    IF (l_subv_rec.transfer_basis_code = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.transfer_basis_code := NULL;
    END IF;
	--End code changes for Subsidy by fmiao on 10/25/2004--
    IF (l_subv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute_category := NULL;
    END IF;
    IF (l_subv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute1 := NULL;
    END IF;
    IF (l_subv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute2 := NULL;
    END IF;
    IF (l_subv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute3 := NULL;
    END IF;
    IF (l_subv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute4 := NULL;
    END IF;
    IF (l_subv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute5 := NULL;
    END IF;
    IF (l_subv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute6 := NULL;
    END IF;
    IF (l_subv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute7 := NULL;
    END IF;
    IF (l_subv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute8 := NULL;
    END IF;
    IF (l_subv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute9 := NULL;
    END IF;
    IF (l_subv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute10 := NULL;
    END IF;
    IF (l_subv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute11 := NULL;
    END IF;
    IF (l_subv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute12 := NULL;
    END IF;
    IF (l_subv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute13 := NULL;
    END IF;
    IF (l_subv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute14 := NULL;
    END IF;
    IF (l_subv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_subv_rec.attribute15 := NULL;
    END IF;
    IF (l_subv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.created_by := NULL;
    END IF;
    IF (l_subv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_subv_rec.creation_date := NULL;
    END IF;
    IF (l_subv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.last_updated_by := NULL;
    END IF;
    IF (l_subv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_subv_rec.last_update_date := NULL;
    END IF;
    IF (l_subv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.last_update_login := NULL;
    END IF;
    -- sjalasut added new column for subsidy pools enhancement. start
    IF (l_subv_rec.subsidy_pool_id = OKL_API.G_MISS_NUM ) THEN
      l_subv_rec.subsidy_pool_id := NULL;
    END IF;
    -- sjalasut added new column for subsidy pools enhancement. end
    RETURN(l_subv_rec);
  END null_out_defaults;
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
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sfwt_flag                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_sfwt_flag = OKL_API.G_MISS_CHAR OR
        p_sfwt_flag IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
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
  END validate_sfwt_flag;
  -------------------------------------
  -- Validate_Attributes for: ORG_ID --
  -------------------------------------
  PROCEDURE validate_org_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_org_id                       IN NUMBER) IS

      CURSOR hou_csr (p_org_id in number) IS
      SELECT 'Y'
      FROM  hr_operating_units hou
      WHERE hou.organization_id = p_org_id
      And   sysdate between nvl(hou.date_from,sysdate) and nvl(hou.date_to,sysdate);

      l_exists varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_org_id = OKL_API.G_MISS_NUM OR
        p_org_id IS NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'org_id');
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Operating Unit');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF (p_org_id <> OKL_API.G_MISS_NUM AND
           p_org_id IS NOT NULL)
    THEN
      l_exists := 'N';
      Open hou_csr (p_org_id => p_org_id);
      Fetch hou_csr into l_exists;
      If hou_csr%NOTFOUND then
          Null;
      End If;
      Close hou_csr;
      IF l_exists = 'N' then
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Operating Unit');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  END validate_org_id;
  -----------------------------------
  -- Validate_Attributes for: NAME --
  -----------------------------------
  PROCEDURE validate_name(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_name                         IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_name = OKL_API.G_MISS_CHAR OR
        p_name IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Subsidy Name');
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
  END validate_name;

--cklee: start
  -----------------------------------
  -- Validate_Attributes for: NAME --
  -----------------------------------
  PROCEDURE validate_name_uniqueness(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_name                         IN VARCHAR2,
    p_id                           IN NUMBER) IS

cursor c_record_exists is
select 1
from okl_subsidies_b sub
where sub.id = p_id
-- abindal start bug# 4873705 --
and sub.org_id = mo_global.get_current_org_id();
-- abindal end bug# 4873705 --

cursor c_unique_insert is
select 1
from okl_subsidies_b sub
where sub.name = p_name
-- abindal start bug# 4873705 --
and sub.org_id = mo_global.get_current_org_id();
-- abindal end bug# 4873705 --

cursor c_unique_update is
select 1
from okl_subsidies_b sub
where sub.id <> p_id
and sub.name = p_name
-- abindal start bug# 4873705 --
and sub.org_id = mo_global.get_current_org_id();
-- abindal end bug# 4873705 --

l_dup_row_found boolean;
l_row_found boolean;
l_dummy number;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- 1. If it's a new ID but has not insert into DB yet
    -- 2. If it's a g_miss_num (update mode must have ID)
    open c_record_exists;
    fetch c_record_exists into l_dummy;
    l_row_found := c_record_exists%found;
    close c_record_exists;

    -- update mode
    IF l_row_found THEN
      open c_unique_update;
      fetch c_unique_update into l_dummy;
      l_dup_row_found := c_unique_update%found;
      close c_unique_update;

    ELSE -- insert mode
      open c_unique_insert;
      fetch c_unique_insert into l_dummy;
      l_dup_row_found := c_unique_insert%found;
      close c_unique_insert;
    END IF;

    IF l_dup_row_found THEN
      OKL_API.set_message(G_APP_NAME, G_NOT_UNIQUE, G_COL_NAME_TOKEN, 'Subsidy Name');
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
  END validate_name_uniqueness;
--cklee: end

  --------------------------------------------------
  -- Validate_Attributes for: EFFECTIVE_FROM_DATE --
  --------------------------------------------------
  PROCEDURE validate_effective_from_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_effective_from_date          IN DATE) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_effective_from_date = OKL_API.G_MISS_DATE OR
        p_effective_from_date IS NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'effective_from_date');
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Effective From');
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
  END validate_effective_from_date;
--------------------------------------------
--Start of Hand Coded Attribute Validations
---------------------------------------------

  --------------------------------------------------
  -- Validate_Attributes for: EXPIRE_AFTER_DAYS --
  --------------------------------------------------
  PROCEDURE validate_expire_after_days(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_expire_after_days          IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_expire_after_days = OKL_API.G_MISS_NUM OR
        p_expire_after_days IS NULL)
    THEN
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'effective_from_date');
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Expire After Days');
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
  END validate_expire_after_days;

  -------------------------------------------------
  -- Validate_Attributes for: SUBSIDY_CALC_BASIS --
  -------------------------------------------------
  PROCEDURE validate_subsidy_calc_basis(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_subsidy_calc_basis           IN VARCHAR2) IS

    CURSOR flk_csr (p_lookup_type IN varchar2,p_lookup_code IN VARCHAR2) IS
      SELECT 'Y'
      FROM  Fnd_Lookups flk
      WHERE flk.lookup_code = p_lookup_code
      And   flk.lookup_type = p_lookup_type
      And   flk.enabled_flag = 'Y'
      And   sysdate between nvl(flk.start_date_active,sysdate) and nvl(flk.end_date_active,sysdate);
      l_exists          varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_subsidy_calc_basis = OKL_API.G_MISS_CHAR OR
        p_subsidy_calc_basis IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Subsidy Calculation Basis');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_subsidy_calc_basis <> OKL_API.G_MISS_CHAR AND
           p_subsidy_calc_basis IS NOT NULL)
    THEN
      l_exists := 'N';
      Open flk_csr (p_lookup_type => 'OKL_SUBCALC_BASIS',p_lookup_code => p_subsidy_calc_basis);
      Fetch flk_csr into l_exists;
      If flk_csr%NOTFOUND then
          Null;
      End If;
      Close flk_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SUBSIDY_CALC_BASIS');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy Calculation Basis');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      IF flk_csr%ISOPEN then
          close flk_csr;
      END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_subsidy_calc_basis;

  -------------------------------------------------
  -- Validate_Attributes for: SUBSIDY_POOL_ID --
  -------------------------------------------------
  PROCEDURE validate_subsidy_pool_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_subsidy_pool_id           IN NUMBER) IS

    CURSOR c_get_pool_type_csr IS
     SELECT pool_type_code
       FROM okl_subsidy_pools_b
      WHERE id = p_subsidy_pool_id;
    lv_pool_type okl_subsidy_pools_b.pool_type_code%TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF(p_subsidy_pool_id IS NOT NULL)THEN
      OPEN c_get_pool_type_csr; FETCH c_get_pool_type_csr INTO lv_pool_type;
      CLOSE c_get_pool_type_csr;
      IF(lv_pool_type <> 'BUDGET')THEN
        OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy Pool');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  END validate_subsidy_pool_id;


  -----------------------------------------
  -- Validate_Attributes for: FORMULA_ID --
  -----------------------------------------
  PROCEDURE validate_formula_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_formula_id                   IN NUMBER) IS

    CURSOR fmlb_csr (p_formula_id IN number) IS
      SELECT 'Y'
      FROM  OKL_FORMULAE_B fmlb
      WHERE fmlb.id  = p_formula_id
      And   sysdate between nvl(fmlb.start_date,sysdate) and nvl(fmlb.end_date,sysdate);
      l_exists          varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_formula_id <> OKL_API.G_MISS_NUM AND
        p_formula_id IS NOT NULL)
    THEN
      l_exists := 'N';
      Open fmlb_csr (p_formula_id => p_formula_id);
      Fetch fmlb_csr into l_exists;
      If fmlb_csr%NOTFOUND then
          Null;
      End If;
      Close fmlb_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'FORMULA_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Subsidy Calculation Formula');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
  END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If fmlb_csr%ISOPEN then
         close fmlb_csr;
      End If;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_formula_id;
  -----------------------------------------------------
  -- Validate_Attributes for: ACCOUNTING_METHOD_CODE --
  -----------------------------------------------------
  PROCEDURE validate_accounting1(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_accounting_method_code       IN VARCHAR2) IS

    CURSOR flk_csr (p_lookup_type IN varchar2,p_lookup_code IN VARCHAR2) IS
      SELECT 'Y'
      FROM  Fnd_Lookups flk
      WHERE flk.lookup_code = p_lookup_code
      And   flk.lookup_type = p_lookup_type
      And   flk.enabled_flag = 'Y'
      And   sysdate between nvl(flk.start_date_active,sysdate) and nvl(flk.end_date_active,sysdate);
      l_exists          varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_accounting_method_code = OKL_API.G_MISS_CHAR OR
        p_accounting_method_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Accounting Method');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_accounting_method_code <> OKL_API.G_MISS_CHAR AND
           p_accounting_method_code IS NOT NULL)
    THEN
      l_exists := 'N';
      Open flk_csr (p_lookup_type => 'OKL_SUBACCT_METHOD',p_lookup_code => p_accounting_method_code);
      Fetch flk_csr into l_exists;
      If flk_csr%NOTFOUND then
          Null;
      End If;
      Close flk_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACCOUNTING_METHOD_CODE');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Accounting Method');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      IF flk_csr%ISOPEN then
          close flk_csr;
      END IF;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_accounting1;
  -------------------------------------------------------
  -- Validate_Attributes for: TERMINATION_REFUND_BASIS --
  -------------------------------------------------------
  PROCEDURE validate_terminatio3(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_termination_refund_basis     IN VARCHAR2) IS
      CURSOR flk_csr (p_lookup_type IN varchar2,p_lookup_code IN VARCHAR2) IS
      SELECT 'Y'
      FROM  Fnd_Lookups flk
      WHERE flk.lookup_code = p_lookup_code
      And   flk.lookup_type = p_lookup_type
      And   flk.enabled_flag = 'Y'
      And   sysdate between nvl(flk.start_date_active,sysdate) and nvl(flk.end_date_active,sysdate);
      l_exists          varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_termination_refund_basis = OKL_API.G_MISS_CHAR OR
        p_termination_refund_basis IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Refund Basis');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF (p_termination_refund_basis <> OKL_API.G_MISS_CHAR AND
           p_termination_refund_basis IS NOT NULL)
    THEN
      l_exists := 'N';
      Open flk_csr (p_lookup_type => 'OKL_SUBRFND_BASIS',p_lookup_code => p_termination_refund_basis);
      Fetch flk_csr into l_exists;
      If flk_csr%NOTFOUND then
          Null;
      End If;
      Close flk_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TERMINATION_REFUND_BASIS');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Refund Basis');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      IF flk_csr%ISOPEN then
          close flk_csr;
      END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_terminatio3;
  ------------------------------------------------
  -- Validate_Attributes for: REFUND_FORMULA_ID --
  ------------------------------------------------
  PROCEDURE validate_refund_formula_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_refund_formula_id            IN NUMBER) IS

    CURSOR fmlb_csr (p_formula_id IN number) IS
      SELECT 'Y'
      FROM  OKL_FORMULAE_B fmlb
      WHERE fmlb.id  = p_formula_id
      And   sysdate between nvl(fmlb.start_date,sysdate) and nvl(fmlb.end_date,sysdate);
      l_exists          varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_refund_formula_id <> OKL_API.G_MISS_NUM AND
        p_refund_formula_id IS NOT NULL)
    THEN
      l_exists := 'N';
      Open fmlb_csr (p_formula_id => p_refund_formula_id);
      Fetch fmlb_csr into l_exists;
      If fmlb_csr%NOTFOUND then
          Null;
      End If;
      Close fmlb_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REFUND_FORMULA_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Refund Formula');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If fmlb_csr%ISOPEN then
         close fmlb_csr;
      End If;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_refund_formula_id;
  ---------------------------------------------
  -- Validate_Attributes for: STREAM_TYPE_ID --
  ---------------------------------------------
  PROCEDURE validate_stream_type_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_stream_type_id               IN NUMBER) IS
    -- sjalasut, changed the cursor to exclude stream type class
    -- and included stream type purpose as part of bug 3985580.
    CURSOR styb_csr (p_stream_type_id IN number) IS
      SELECT 'Y'
      FROM  OKL_STRM_TYPE_B styb,
            FND_LOOKUPS lkup
      WHERE styb.id  = p_stream_type_id
      AND sysdate between nvl(styb.start_date,sysdate) and nvl(styb.end_date,sysdate)
      AND lkup.lookup_code = styb.STREAM_TYPE_PURPOSE
      AND lkup.lookup_type = 'OKL_STREAM_TYPE_PURPOSE';
      --And   styb.stream_type_class = 'SUBSIDY';
      l_exists          varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_stream_type_id = OKL_API.G_MISS_NUM OR
        p_stream_type_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Stream Type');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF (p_stream_type_id <> OKL_API.G_MISS_NUM AND
           p_stream_type_id IS NOT NULL)
    THEN
      l_exists := 'N';
      Open styb_csr (p_stream_type_id => p_stream_type_id);
      Fetch styb_csr into l_exists;
      If styb_csr%NOTFOUND then
          Null;
      End If;
      Close styb_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'STREAM_TYPE_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Stream Type');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
    If styb_csr%ISOPEN then
         close styb_csr;
      End If;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_stream_type_id;
  --------------------------------------------------
  -- Validate_Attributes for: RECEIPT_METHOD_CODE --
  --------------------------------------------------
  PROCEDURE validate_receipt_method_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_receipt_method_code          IN VARCHAR2) IS
     CURSOR flk_csr (p_lookup_type IN varchar2,p_lookup_code IN VARCHAR2) IS
      SELECT 'Y'
      FROM  Fnd_Lookups flk
      WHERE flk.lookup_code = p_lookup_code
      And   flk.lookup_type = p_lookup_type
      And   flk.enabled_flag = 'Y'
      And   sysdate between nvl(flk.start_date_active,sysdate) and nvl(flk.end_date_active,sysdate);
      l_exists          varchar2(1) default 'N';
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_receipt_method_code = OKL_API.G_MISS_CHAR OR
        p_receipt_method_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Net on Funding');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF (p_receipt_method_code <> OKL_API.G_MISS_CHAR AND
           p_receipt_method_code IS NOT NULL)
    THEN
      l_exists := 'N';
      Open flk_csr (p_lookup_type => 'OKL_SUBRCPT_METHOD',p_lookup_code => p_receipt_method_code);
      Fetch flk_csr into l_exists;
      If flk_csr%NOTFOUND then
          Null;
      End If;
      Close flk_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RECEIPT_METHOD_CODE');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Net on Funding');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      IF flk_csr%ISOPEN then
          close flk_csr;
      END IF;
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_receipt_method_code;

  --------------------------------------------------
  -- Validate_Attributes for: EXCLUSIVE_YN --
  --------------------------------------------------
  PROCEDURE validate_exclusive_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_exclusive_yn          IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_exclusive_yn = OKL_API.G_MISS_CHAR OR
        p_exclusive_yn IS NULL)
    THEN

      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Exclusive');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF (p_exclusive_yn <> OKL_API.G_MISS_CHAR AND
           p_exclusive_yn IS NOT NULL)
    THEN
      If p_exclusive_yn not in ('Y','N') then
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Exclusive');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  END validate_exclusive_yn;

  --------------------------------------------------
  -- Validate_Attributes for: APPLICABLE_TO_RELEASE_YN --
  --------------------------------------------------
  PROCEDURE validate_release_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_applicable_to_release_yn     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_applicable_to_release_yn = OKL_API.G_MISS_CHAR OR
        p_applicable_to_release_yn IS NULL)
    THEN

        OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Available on Release');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_applicable_to_release_yn <> OKL_API.G_MISS_CHAR AND
           p_applicable_to_release_yn IS NOT NULL)
    THEN
      If p_applicable_to_release_yn not in ('Y','N') then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'APPLICABLE_TO_RELEASE_YN');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'vailable on Release');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  END validate_release_yn;

  --------------------------------------------------
  -- Validate_Attributes for: RECOURSE_YN --
  --------------------------------------------------
  PROCEDURE validate_recourse_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_recourse_yn     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_recourse_yn = OKL_API.G_MISS_CHAR OR
        p_recourse_yn IS NULL)
    THEN

        OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Recourse');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_recourse_yn <> OKL_API.G_MISS_CHAR AND
        p_recourse_yn IS NOT NULL)
    THEN
      If p_recourse_yn not in ('Y','N') then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RECOURSE_YN');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Recourse');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  END validate_recourse_yn;

  --------------------------------------------------
  -- Validate_Attributes for: CUSTOMER_VISIBLE_YN --
  --------------------------------------------------
  PROCEDURE validate_customer_visible_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_customer_visible_yn     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_customer_visible_yn = OKL_API.G_MISS_CHAR OR
        p_customer_visible_yn IS NULL)
    THEN

        OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Visible to Customer');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_customer_visible_yn <> OKL_API.G_MISS_CHAR AND
        p_customer_visible_yn IS NOT NULL)
    THEN
      If p_customer_visible_yn not in ('Y','N') then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CUSTOMER_VISIBLE_YN');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Visible to Customer');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  END validate_customer_visible_yn;

  ------------------------------------------------
  -- Validate_Attributes for: VENDOR_ID --
  ------------------------------------------------
  PROCEDURE validate_vendor_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_vendor_id            IN NUMBER) IS

    CURSOR pov_csr (p_vendor_id IN number) IS
      SELECT 'Y'
      FROM  PO_VENDORS pov
      WHERE pov.vendor_id  = p_vendor_id;

      l_exists          varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_vendor_id <> OKL_API.G_MISS_NUM AND
        p_vendor_id IS NOT NULL)
    THEN
      l_exists := 'N';
      Open pov_csr (p_vendor_id => p_vendor_id);
      Fetch pov_csr into l_exists;
      If pov_csr%NOTFOUND then
          Null;
      End If;
      Close pov_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REFUND_FORMULA_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Vendor');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If pov_csr%ISOPEN then
         close pov_csr;
      End If;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_id;
  -----------------------------------------------
  -- Validate_Attributes for: currency_code --
  ------------------------------------------------
  PROCEDURE validate_currency_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_currency_code                IN  VARCHAR2) IS

    CURSOR curr_csr (p_currency_code IN varchar2) IS
      SELECT 'Y'
      FROM    fnd_currencies curr
      WHERE   curr.currency_code = p_currency_code
      AND     SYSDATE BETWEEN NVL(curr.START_DATE_ACTIVE,SYSDATE) AND NVL(curr.END_DATE_ACTIVE,SYSDATE)
      AND     NVL(curr.CURRENCY_FLAG,'N') = 'Y'
      AND     NVL(curr.ENABLED_FLAG,'N') = 'Y';

      l_exists          varchar2(1) default 'N';

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_currency_code is NULL) OR (p_currency_code = OKL_API.G_MISS_CHAR) Then
        OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Currency');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (p_currency_code <> OKL_API.G_MISS_CHAR AND
           p_currency_code IS NOT NULL)
    THEN
      l_exists := 'N';
      Open curr_csr (p_currency_code => p_currency_code);
      Fetch curr_csr into l_exists;
      If curr_csr%NOTFOUND then
          Null;
      End If;
      Close curr_csr;
      IF l_exists = 'N' then
          --OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REFUND_FORMULA_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Currency');
          x_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      If curr_csr%ISOPEN then
         close curr_csr;
      End If;

      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_currency_code;
--------------------------------------------
--End of Hand Coded Attribute Validations
---------------------------------------------
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Attributes for:OKL_SUBSIDIES_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_subv_rec                     IN subv_rec_type
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
    validate_id(x_return_status, p_subv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_subv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(x_return_status, p_subv_rec.sfwt_flag);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- org_id
    -- ***
    validate_org_id(x_return_status, p_subv_rec.org_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- name
    -- ***
    validate_name(x_return_status, p_subv_rec.name);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

--cklee: start
    -- ***
    -- name
    -- ***
    validate_name_uniqueness(x_return_status, p_subv_rec.name, p_subv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--cklee: end

    -- ***
    -- effective_from_date
    -- ***
    validate_effective_from_date(x_return_status, p_subv_rec.effective_from_date);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- expire_after_days
    -- ***
    validate_expire_after_days(x_return_status, p_subv_rec.expire_after_days);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- subsidy_calc_basis
    -- ***
    validate_subsidy_calc_basis(x_return_status, p_subv_rec.subsidy_calc_basis);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- subsidy_pool_id
    -- ***
    validate_subsidy_pool_id(x_return_status, p_subv_rec.subsidy_pool_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- ***
    -- formula_id
    -- ***
    validate_formula_id(x_return_status, p_subv_rec.formula_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- accounting_method_code
    -- ***
    validate_accounting1(x_return_status, p_subv_rec.accounting_method_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- termination_refund_basis
    -- ***
    validate_terminatio3(x_return_status, p_subv_rec.termination_refund_basis);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- refund_formula_id
    -- ***
    validate_refund_formula_id(x_return_status, p_subv_rec.refund_formula_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- stream_type_id
    -- ***
    validate_stream_type_id(x_return_status, p_subv_rec.stream_type_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- receipt_method_code
    -- ***
    validate_receipt_method_code(x_return_status, p_subv_rec.receipt_method_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- exclusive_yn
    -- ***
    validate_exclusive_yn(x_return_status, p_subv_rec.exclusive_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- applicable_to_release_yn
    -- ***
    validate_release_yn(x_return_status, p_subv_rec.applicable_to_release_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- recourse_yn
    -- ***
    validate_recourse_yn(x_return_status, p_subv_rec.recourse_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- customer_visible_yn
    -- ***
    validate_recourse_yn(x_return_status, p_subv_rec.customer_visible_yn);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

       -- ***
    -- vendor_id
    -- ***
    validate_vendor_id(x_return_status, p_subv_rec.vendor_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- currency_code
    -- ***
    validate_currency_code(x_return_status, p_subv_rec.currency_code);
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
-----------------------------------
--Hand coded validate record proc
-----------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate Record for:OKL_SUBSIDIES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_subv_rec IN subv_rec_type,
    p_db_subv_rec IN subv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys and other relations --
    ------------------------------------
    FUNCTION validate_ref_integrity (
      p_subv_rec IN subv_rec_type,
      p_db_subv_rec IN subv_rec_type
    ) RETURN VARCHAR2 IS
      violated_ref_integrity           EXCEPTION;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

      -- sjalasut, added cursors for subsidy pools enhancement. START
      CURSOR c_get_pool_sts_csr
-- START: cklee 07/28/05
      (p_subsidy_pool_id okl_subsidy_pools_b.id%TYPE)
-- END: cklee 07/28/05
       IS
       SELECT SUBP.decision_status_code,
-- start: cklee 07/22/2005
              FLK7.MEANING
         FROM okl_subsidy_pools_b SUBP,
              FND_LOOKUPS FLK7
        WHERE FLK7.LOOKUP_TYPE = 'OKL_SUBSIDY_POOL_STATUS'
        AND FLK7.LOOKUP_CODE = SUBP.DECISION_STATUS_CODE
-- end: cklee 07/22/2005
--        AND SUBP.id = p_subv_rec.subsidy_pool_id;
-- START: cklee 07/28/05
        AND SUBP.id = p_subsidy_pool_id;
-- END: cklee 07/28/05
      lv_pool_sts okl_subsidy_pools_b.decision_status_code%TYPE;
      lv_pool_sts_meaning fnd_lookups.MEANING%TYPE;

      CURSOR c_get_pool_dates_csr
-- START: cklee 07/28/05
      (p_subsidy_pool_id okl_subsidy_pools_b.id%TYPE)
-- END: cklee 07/28/05
       IS
       SELECT effective_from_date, effective_to_date
-- start: cklee 07/22/2005
              ,SUBSIDY_POOL_NAME
-- end: cklee 07/22/2005
         FROM okl_subsidy_pools_b
--        WHERE id = p_subv_rec.subsidy_pool_id;
-- START: cklee 07/28/05
        WHERE id = p_subsidy_pool_id;
-- END: cklee 07/28/05
      lv_pool_effective_from okl_subsidy_pools_b.effective_from_date%TYPE;
      lv_pool_effective_to okl_subsidy_pools_b.effective_to_date%TYPE;
-- start: cklee 07/22/2005
      lv_pool_name okl_subsidy_pools_b.subsidy_pool_name%TYPE;
-- end: cklee 07/22/2005

      CURSOR c_chk_asset_subsidy_csr IS
      SELECT 1
        FROM okl_k_lines klines
       WHERE klines.subsidy_id = p_subv_rec.id;
       lv_asset_count NUMBER;
      -- sjalasut, added cursors for subsidy pools enhancement. END

      -- 07/21/05 cklee, added cursors for subsidy pools enhancement. START
--un-comment until 08/26/05
      -- check if it associate with a Sales Q/Lease App
      CURSOR c_chk_asset_sub_sq_la_csr IS
      SELECT 1
        FROM OKL_COST_ADJUSTMENTS_B
       WHERE ADJUSTMENT_SOURCE_TYPE = 'SUBSIDY' AND
       ADJUSTMENT_SOURCE_ID = p_subv_rec.id;
--
      -- 07/21/05 cklee, added cursors for subsidy pools enhancement. END

    BEGIN

      l_return_status           := OKL_API.G_RET_STS_SUCCESS;
      --------------------------------------------------------------------------
      --1. Effective from date can not be greater than effective to date
      --------------------------------------------------------------------------
      IF (p_subv_rec.EFFECTIVE_FROM_DATE <> p_db_subv_rec.EFFECTIVE_FROM_DATE) OR
         (p_subv_rec.EFFECTIVE_TO_DATE is not null and
          p_subv_rec.EFFECTIVE_TO_DATE <>  p_db_subv_rec.EFFECTIVE_TO_DATE)
      THEN
          IF p_subv_rec.EFFECTIVE_FROM_DATE > nvl(p_subv_rec.EFFECTIVE_TO_DATE,p_subv_rec.EFFECTIVE_FROM_DATE) then
             OKL_API.set_message(G_APP_NAME, G_SUBSIDY_INVALID_DATES);
             RAISE violated_ref_integrity;
          END IF;
      END IF;

      --------------------------------------------------------------------------
      --2. Subsidy calculation basis
      --------------------------------------------------------------------------
      IF p_subv_rec.subsidy_calc_basis = 'FIXED' then
          If p_subv_rec.Amount is null then
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Subsidy Amount');
             RAISE violated_ref_integrity;
           End If;

      ELSIF p_subv_rec.subsidy_calc_basis = 'FORMULA' then
          If p_subv_rec.Formula_id is null then
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Subsidy Calculation Formula');
             RAISE violated_ref_integrity;
           End If;

      ELSIF p_subv_rec.subsidy_calc_basis = 'RATE' then
          If p_subv_rec.Rate_Points is null then
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Rate Points');
             RAISE violated_ref_integrity;
           End If;

       ELSIF p_subv_rec.subsidy_calc_basis = 'ASSETCOST' then
          If p_subv_rec.Percent is null then
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Percent');
             RAISE violated_ref_integrity;
           End If;
       END IF;

      --Bug# 3353781 :
      --------------------------------------------------------------------------
      --3. Net on Funding Vs (Receipt method code)
      --------------------------------------------------------------------------
      /*-------------Bug Fix# 3353781------------------------------------------
      --If p_subv_rec.receipt_method_code = 'FUND' Then
          --If p_subv_rec.accounting_method_code <> 'NET' Then
              --OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  --p_msg_name     => G_INVALID_RECEIPT_METHOD
                                  --);
               --RAISE violated_ref_integrity;
           --End If;
       --End If;
      -------------------Bug Fix# 3353781---------------------------------------*/
--START:|           12-Sep-2005  cklee   Fixed bug#4928690                           |
/*commented out the below code for bug 4636697
      If p_subv_rec.accounting_method_code = 'NET' Then
          If p_subv_rec.receipt_method_code <> 'FUND' Then
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_INVALID_RECEIPT_METHOD
                                  );
               RAISE violated_ref_integrity;
           End If;
       End If;
*/
--END:|           12-Sep-2005  cklee   Fixed bug#4928690                           |

      --------------------------------------------------------------------------
      --4. Recourse YN Vs(Receipt method code)
      --------------------------------------------------------------------------
      If p_subv_rec.recourse_yn = 'Y' Then
          If p_subv_rec.accounting_method_code = 'NET' Then
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_INVALID_RECOURSE_FLAG
                                  );
               RAISE violated_ref_integrity;
           End If;
       End If;


      --------------------------------------------------------------------------
      --5. Refund Formula (Termination_Refund_basis)
      --------------------------------------------------------------------------
      If p_subv_rec.termination_refund_basis = 'FORMULA' Then
-- cklee 12-12-2003 fixed bug#3313766, added p_subv_rec.recourse_yn = 'Y'
          If p_subv_rec.recourse_yn = 'Y' AND p_subv_rec.refund_formula_id is NULL Then
             OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Refund Formula');
             RAISE violated_ref_integrity;
          End If;
      End If;

      /*
       * sjalasut: jan 24, 05 added code to validate subsidy pool modification and also
       * date ranges of subsidy and subsidy pool
       */
      --------------------------------------------------------------------------
      --6. Subsidy Pool (subsidy_pool_id)
      --------------------------------------------------------------------------
      IF(p_subv_rec.subsidy_pool_id IS NULL AND p_db_subv_rec.subsidy_pool_id IS NOT NULL)THEN
      -- this is the case of dissociating a subsidy pool from the subsidy while the pool is not active.
      -- check if the earlier pool is not active, raise exception if the pool is active
      -- this is an extra cautionary check, in the ui, the subsidy pool field becomes readonly once active.
        OPEN c_get_pool_sts_csr
-- START: cklee 07/28/05
             (p_db_subv_rec.subsidy_pool_id);
-- END: cklee 07/28/05
        FETCH c_get_pool_sts_csr INTO lv_pool_sts, lv_pool_sts_meaning;
        CLOSE c_get_pool_sts_csr;
        IF(lv_pool_sts = 'ACTIVE')THEN
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_POOL_STATUS,'SUBSIDY',p_subv_rec.name);
          RAISE violated_ref_integrity;
        END IF;
      END IF;
      IF(p_subv_rec.subsidy_pool_id IS NOT NULL AND p_db_subv_rec.subsidy_pool_id IS NOT NULL AND
         p_subv_rec.subsidy_pool_id <> OKL_API.G_MISS_NUM AND p_subv_rec.subsidy_pool_id <> p_db_subv_rec.subsidy_pool_id)THEN
         -- case when the subsidy pool id is being modified to another value from the LOV in the UI.
         -- check to see if this subsidy is attached to a valid asset. if attached, raise an error
        lv_asset_count := 0;
        OPEN c_chk_asset_subsidy_csr; FETCH c_chk_asset_subsidy_csr INTO lv_asset_count;
        CLOSE c_chk_asset_subsidy_csr;
        IF(lv_asset_count = 1)THEN
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_ATTACH_ASSET_EXIST,'SUBSIDY',p_subv_rec.name);
          RAISE violated_ref_integrity;
        END IF;
      END IF;
      IF((p_subv_rec.subsidy_pool_id IS NOT NULL AND p_subv_rec.subsidy_pool_id <> NVL(p_db_subv_rec.subsidy_pool_id,-1))
          OR (p_subv_rec.EFFECTIVE_FROM_DATE <> p_db_subv_rec.EFFECTIVE_FROM_DATE) OR (NVL(p_subv_rec.EFFECTIVE_TO_DATE, SYSDATE) <> NVL(p_db_subv_rec.EFFECTIVE_TO_DATE, SYSDATE)))THEN
        -- this is the case when the subsidy pool is being modified to a new value or the effective dates on subsidy have been changed
        -- validate the date range. subsidy dates and pool dates must overlap
        OPEN c_get_pool_dates_csr
-- START: cklee 07/28/05
             (p_subv_rec.subsidy_pool_id);
-- END: cklee 07/28/05
        FETCH c_get_pool_dates_csr INTO lv_pool_effective_from, lv_pool_effective_to
-- start: cklee 07/22/05
        ,lv_pool_name;
-- end: cklee 07/22/05
        CLOSE c_get_pool_dates_csr;
        -- if either the pool effective from date is not between subsidy dates or subsidy effective from date is not between pool effective dates
        -- raise error
        IF((nvl(lv_pool_effective_to,OKL_ACCOUNTING_UTIL.g_final_date) < trunc(p_subv_rec.effective_from_date))OR
           (nvl(p_subv_rec.EFFECTIVE_TO_DATE,OKL_ACCOUNTING_UTIL.g_final_date) < lv_pool_effective_From)
          )THEN
--cklee 09/12/2005          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_POOL_EFFECTIVE_DATES);
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_POOL_EFFECTIVE_DATES,'SUBSIDY',p_subv_rec.name);

          RAISE violated_ref_integrity;
        END IF;
      END IF;
      /*
       * sjalasut: jan 24, 05 added code to validate subsidy pool modification and also
       * date ranges of subsidy and subsidy pool
       */
/*
**
cklee : 07/21/2005
1)	If pool status is New, then user allows to add/remove to/from pool
2)	If pool status is Active and pool is not expired, then user allows to add to pool.
3)	If subisdy is not associate with pool and doesn't have existing association
    with contract, Sales Quote, or Lease App, then user allows to choose subsidy from Subsidy LOV.
4)	Subsidy dates is overlap with pool dates
**
*/
      /*
       * START: cklee: July 22, 05 added code to validate subsidy pool modification
       */
      -------------------------------------------------------
      -------------------------------------------------------
      -- create/update a subsidy -- associate/dissociate to/from a pool
      -------------------------------------------------------
      -------------------------------------------------------
      -------------------------------------------------------
      -- dissociating a subsidy from a pool
      -------------------------------------------------------
      IF(p_subv_rec.subsidy_pool_id IS NULL AND p_db_subv_rec.subsidy_pool_id IS NOT NULL)THEN

        -------------------------------------------------------
        -- If the status is invalid when dissociating a subsidy from a pool
        -------------------------------------------------------
        OPEN c_get_pool_sts_csr
-- START: cklee 07/28/05
             (p_db_subv_rec.subsidy_pool_id);
-- END: cklee 07/28/05
        FETCH c_get_pool_sts_csr INTO lv_pool_sts, lv_pool_sts_meaning;
        CLOSE c_get_pool_sts_csr;
        IF(lv_pool_sts IN ('PENDING', 'REJECTED', 'EXPIRED', 'ACTIVE'))THEN
          -- You are not allowed to dissociate a subsidy from a pool if the pool status is STATUS.
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_POOL_DISSOC_STATUS, 'STATUS',lv_pool_sts_meaning);
          RAISE violated_ref_integrity;
        END IF;

        -------------------------------------------------------
        -- If the pool is expired when dissociating a subsidy to a pool
        -------------------------------------------------------
        OPEN c_get_pool_dates_csr
-- START: cklee 07/28/05
             (p_db_subv_rec.subsidy_pool_id);
-- END: cklee 07/28/05
        FETCH c_get_pool_dates_csr INTO lv_pool_effective_from, lv_pool_effective_to
-- start: cklee 07/22/05
        ,lv_pool_name;
-- end: cklee 07/22/05
        CLOSE c_get_pool_dates_csr;
        IF trunc(nvl(lv_pool_effective_to, sysdate)) < trunc(sysdate) THEN
          -- You are not allowed to dissociate a subsidy from a pool if the pool expired.
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_POOL_DISOC_EXP_POOL, 'POOL',lv_pool_name);
          RAISE violated_ref_integrity;
        END IF;
      END IF;

      -------------------------------------------------------
      -- associating a subsidy to a pool
      -------------------------------------------------------
      IF(p_subv_rec.subsidy_pool_id IS NOT NULL AND p_db_subv_rec.subsidy_pool_id IS NULL)THEN

        -------------------------------------------------------
        -- If the status is invalid when associating a subsidy to a pool
        -------------------------------------------------------
        OPEN c_get_pool_sts_csr
-- START: cklee 07/28/05
             (p_subv_rec.subsidy_pool_id);
-- END: cklee 07/28/05
        FETCH c_get_pool_sts_csr INTO lv_pool_sts, lv_pool_sts_meaning;
        CLOSE c_get_pool_sts_csr;
        IF(lv_pool_sts IN ('PENDING', 'REJECTED', 'EXPIRED'))THEN
        -- You are not allowed to associate a subsidy to a pool if the pool status is STATUS.
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_POOL_ASSOC_STATUS, 'STATUS',lv_pool_sts_meaning);
          RAISE violated_ref_integrity;
        END IF;

        -------------------------------------------------------
        -- If the pool is expired when associating a subsidy to a pool
        -------------------------------------------------------
        OPEN c_get_pool_dates_csr
-- START: cklee 07/28/05
             (p_subv_rec.subsidy_pool_id);
-- END: cklee 07/28/05
        FETCH c_get_pool_dates_csr INTO lv_pool_effective_from, lv_pool_effective_to
-- start: cklee 07/22/05
        ,lv_pool_name;
-- end: cklee 07/22/05
        CLOSE c_get_pool_dates_csr;
        IF trunc(nvl(lv_pool_effective_to, sysdate)) < trunc(sysdate) THEN
          -- You are not allowed to associate a subsidy to a pool if the pool expired.
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_POOL_ASSOC_EXP_POOL, 'POOL',lv_pool_name);
          RAISE violated_ref_integrity;
        END IF;

        -------------------------------------------------------
        -- If there is any existing asset association when associating a subsidy to a pool -- Lease Contract
        -------------------------------------------------------
        lv_asset_count := 0;
        OPEN c_chk_asset_subsidy_csr; FETCH c_chk_asset_subsidy_csr INTO lv_asset_count;
        CLOSE c_chk_asset_subsidy_csr;
        IF(lv_asset_count = 1)THEN
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_ATTACH_ASSET_EXIST,'SUBSIDY',p_subv_rec.name);
          RAISE violated_ref_integrity;
        END IF;
--un-comment until 08/26/05
        -------------------------------------------------------
        -- If there is any existing asset association when associating a subsidy to a pool -- Sales Q/Lease App
        -------------------------------------------------------
        lv_asset_count := 0;
        OPEN c_chk_asset_sub_sq_la_csr; FETCH c_chk_asset_sub_sq_la_csr INTO lv_asset_count;
        CLOSE c_chk_asset_sub_sq_la_csr;
        IF(lv_asset_count = 1)THEN
          OKL_API.set_message(G_APP_NAME,G_SUBSIDY_ATTACH_ASSET_EXIST,'SUBSIDY',p_subv_rec.name);
          RAISE violated_ref_integrity;
        END IF;
--
      END IF;

      /*
       * END: cklee: July 22, 05 added code to validate subsidy pool modification
       */

      RETURN (l_return_status);
    EXCEPTION
      WHEN violated_ref_integrity THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_ref_integrity;
  BEGIN
    l_return_status := validate_ref_integrity(p_subv_rec, p_db_subv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  FUNCTION Validate_Record (
    p_subv_rec IN subv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_subv_rec                  subv_rec_type := get_rec(p_subv_rec);
  BEGIN
    l_return_status := Validate_Record(p_subv_rec => p_subv_rec,
                                       p_db_subv_rec => l_db_subv_rec);
    RETURN (l_return_status);
  END Validate_Record;
-------------------------------------------------
--***End of Handcoded validate record
-------------------------------------------------
/******************Commented generated validate record***
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate Record for:OKL_SUBSIDIES_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_subv_rec IN subv_rec_type,
    p_db_subv_rec IN subv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_subv_rec IN subv_rec_type,
      p_db_subv_rec IN subv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okl_subsidies_v_fk1_csr (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
        FROM Fnd_Lookup_Values
       WHERE fnd_lookup_values.lookup_code = p_lookup_code;
      l_okl_subsidies_v_fk1          okl_subsidies_v_fk1_csr%ROWTYPE;

      CURSOR okl_subsidies_v_fk2_csr (p_id     IN NUMBER,
                                      p_org_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Formulae_B
       WHERE okl_formulae_b.id    = p_id
         AND okl_formulae_b.org_id = p_org_id;
      l_okl_subsidies_v_fk2          okl_subsidies_v_fk2_csr%ROWTYPE;

      CURSOR okl_subsidies_v_fk6_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Strm_Type_B
       WHERE okl_strm_type_b.id   = p_id;
      l_okl_subsidies_v_fk6          okl_subsidies_v_fk6_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_subv_rec.SUBSIDY_CALC_BASIS IS NOT NULL)
       AND
          (p_subv_rec.SUBSIDY_CALC_BASIS <> p_db_subv_rec.SUBSIDY_CALC_BASIS))
      THEN
        OPEN okl_subsidies_v_fk1_csr (p_subv_rec.SUBSIDY_CALC_BASIS);
        FETCH okl_subsidies_v_fk1_csr INTO l_okl_subsidies_v_fk1;
        l_row_notfound := okl_subsidies_v_fk1_csr%NOTFOUND;
        CLOSE okl_subsidies_v_fk1_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SUBSIDY_CALC_BASIS');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (((p_subv_rec.FORMULA_ID IS NOT NULL) AND
           (p_subv_rec.ORG_ID IS NOT NULL))
       AND
          ((p_subv_rec.FORMULA_ID <> p_db_subv_rec.FORMULA_ID) OR
           (p_subv_rec.ORG_ID <> p_db_subv_rec.ORG_ID)))
      THEN
        OPEN okl_subsidies_v_fk2_csr (p_subv_rec.FORMULA_ID,
                                      p_subv_rec.ORG_ID);
        FETCH okl_subsidies_v_fk2_csr INTO l_okl_subsidies_v_fk2;
        l_row_notfound := okl_subsidies_v_fk2_csr%NOTFOUND;
        CLOSE okl_subsidies_v_fk2_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'FORMULA_ID');
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ORG_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_subv_rec.STREAM_TYPE_ID IS NOT NULL)
       AND
          (p_subv_rec.STREAM_TYPE_ID <> p_db_subv_rec.STREAM_TYPE_ID))
      THEN
        OPEN okl_subsidies_v_fk6_csr (p_subv_rec.STREAM_TYPE_ID);
        FETCH okl_subsidies_v_fk6_csr INTO l_okl_subsidies_v_fk6;
        l_row_notfound := okl_subsidies_v_fk6_csr%NOTFOUND;
        CLOSE okl_subsidies_v_fk6_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'STREAM_TYPE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_subv_rec, p_db_subv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_subv_rec IN subv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_subv_rec                  subv_rec_type := get_rec(p_subv_rec);
  BEGIN
    l_return_status := Validate_Record(p_subv_rec => p_subv_rec,
                                       p_db_subv_rec => l_db_subv_rec);
    RETURN (l_return_status);
  END Validate_Record;
****************End of Commented generated validate record***/
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN subv_rec_type,
    p_to   IN OUT NOCOPY subt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN subt_rec_type,
    p_to   IN OUT NOCOPY subv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN subv_rec_type,
    p_to   IN OUT NOCOPY subb_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.name := p_from.name;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.expire_after_days := p_from.expire_after_days;
    p_to.currency_code := p_from.currency_code;
    p_to.exclusive_yn := p_from.exclusive_yn;
    p_to.applicable_to_release_yn := p_from.applicable_to_release_yn;
    p_to.subsidy_calc_basis := p_from.subsidy_calc_basis;
    p_to.amount := p_from.amount;
    p_to.percent := p_from.percent;
    p_to.formula_id := p_from.formula_id;
    p_to.rate_points := p_from.rate_points;
    p_to.maximum_term := p_from.maximum_term;
    p_to.vendor_id := p_from.vendor_id;
    p_to.accounting_method_code := p_from.accounting_method_code;
    p_to.recourse_yn := p_from.recourse_yn;
    p_to.termination_refund_basis := p_from.termination_refund_basis;
    p_to.refund_formula_id := p_from.refund_formula_id;
    p_to.stream_type_id := p_from.stream_type_id;
    p_to.receipt_method_code := p_from.receipt_method_code;
    p_to.customer_visible_yn := p_from.customer_visible_yn;
    p_to.maximum_financed_amount := p_from.maximum_financed_amount;
    p_to.maximum_subsidy_amount := p_from.maximum_subsidy_amount;
	--Start code changes for Subsidy by fmiao on 10/25/2004--
    p_to.transfer_basis_code := p_from.transfer_basis_code;
	--End code changes for Subsidy by fmiao on 10/25/2004--
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
    -- sjalasut added new column for subsidy pools enhancement. start
    p_to.subsidy_pool_id := p_from.subsidy_pool_id;
    -- sjalasut added new column for subsidy pools enhancement. end
  END migrate;
  PROCEDURE migrate (
    p_from IN subb_rec_type,
    p_to   IN OUT NOCOPY subv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
    p_to.name := p_from.name;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.expire_after_days := p_from.expire_after_days;
    p_to.currency_code := p_from.currency_code;
    p_to.exclusive_yn := p_from.exclusive_yn;
    p_to.applicable_to_release_yn := p_from.applicable_to_release_yn;
    p_to.subsidy_calc_basis := p_from.subsidy_calc_basis;
    p_to.amount := p_from.amount;
    p_to.percent := p_from.percent;
    p_to.formula_id := p_from.formula_id;
    p_to.rate_points := p_from.rate_points;
    p_to.maximum_term := p_from.maximum_term;
    p_to.vendor_id := p_from.vendor_id;
    p_to.accounting_method_code := p_from.accounting_method_code;
    p_to.recourse_yn := p_from.recourse_yn;
    p_to.termination_refund_basis := p_from.termination_refund_basis;
    p_to.refund_formula_id := p_from.refund_formula_id;
    p_to.stream_type_id := p_from.stream_type_id;
    p_to.receipt_method_code := p_from.receipt_method_code;
    p_to.customer_visible_yn := p_from.customer_visible_yn;
    p_to.maximum_financed_amount := p_from.maximum_financed_amount;
    p_to.maximum_subsidy_amount := p_from.maximum_subsidy_amount;
	--Start code changes for Subsidy by fmiao on 10/25/2004--
    p_to.transfer_basis_code := p_from.transfer_basis_code;
	--End code changes for Subsidy by fmiao on 10/25/2004--
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
    -- sjalasut added new column for subsidy pools enhancement. start
    p_to.subsidy_pool_id := p_from.subsidy_pool_id;
    -- sjalasut added new column for subsidy pools enhancement. end
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- validate_row for:OKL_SUBSIDIES_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subv_rec                     subv_rec_type := p_subv_rec;
    l_subb_rec                     subb_rec_type;
    l_subt_rec                     subt_rec_type;
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
    l_return_status := Validate_Attributes(l_subv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_subv_rec);
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
  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_SUBSIDIES_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      i := p_subv_tbl.FIRST;
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
            p_subv_rec                     => p_subv_tbl(i));
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
        EXIT WHEN (i = p_subv_tbl.LAST);
        i := p_subv_tbl.NEXT(i);
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

  -------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_SUBSIDIES_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_subv_tbl                     => p_subv_tbl,
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
  ------------------------------------
  -- insert_row for:OKL_SUBSIDIES_B --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subb_rec                     IN subb_rec_type,
    x_subb_rec                     OUT NOCOPY subb_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subb_rec                     subb_rec_type := p_subb_rec;
    l_def_subb_rec                 subb_rec_type;
    ----------------------------------------
    -- Set_Attributes for:OKL_SUBSIDIES_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_subb_rec IN subb_rec_type,
      x_subb_rec OUT NOCOPY subb_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subb_rec := p_subb_rec;
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
      p_subb_rec,                        -- IN
      l_subb_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SUBSIDIES_B(
      id,
      object_version_number,
      org_id,
      name,
      effective_from_date,
      effective_to_date,
      expire_after_days,
      currency_code,
      exclusive_yn,
      applicable_to_release_yn,
      subsidy_calc_basis,
      amount,
      percent,
      formula_id,
      rate_points,
      maximum_term,
      vendor_id,
      accounting_method_code,
      recourse_yn,
      termination_refund_basis,
      refund_formula_id,
      stream_type_id,
      receipt_method_code,
      customer_visible_yn,
      maximum_financed_amount,
      maximum_subsidy_amount,
	  --Start code changes for Subsidy by fmiao on 10/25/2004--
	  transfer_basis_code,
	  --End code changes for Subsidy by fmiao on 10/25/2004--
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
      -- sjalasut added new column for subsidy pools enhancement. start
      subsidy_pool_id
      -- sjalasut added new column for subsidy pools enhancement. end
      )
    VALUES (
      l_subb_rec.id,
      l_subb_rec.object_version_number,
      l_subb_rec.org_id,
      l_subb_rec.name,
      l_subb_rec.effective_from_date,
      l_subb_rec.effective_to_date,
      l_subb_rec.expire_after_days,
      l_subb_rec.currency_code,
      l_subb_rec.exclusive_yn,
      l_subb_rec.applicable_to_release_yn,
      l_subb_rec.subsidy_calc_basis,
      l_subb_rec.amount,
      l_subb_rec.percent,
      l_subb_rec.formula_id,
      l_subb_rec.rate_points,
      l_subb_rec.maximum_term,
      l_subb_rec.vendor_id,
      l_subb_rec.accounting_method_code,
      l_subb_rec.recourse_yn,
      l_subb_rec.termination_refund_basis,
      l_subb_rec.refund_formula_id,
      l_subb_rec.stream_type_id,
      l_subb_rec.receipt_method_code,
      l_subb_rec.customer_visible_yn,
      l_subb_rec.maximum_financed_amount,
      l_subb_rec.maximum_subsidy_amount,
	  --Start code changes for Subsidy by fmiao on 10/25/2004--
	  l_subb_rec.transfer_basis_code,
	  --End code changes for Subsidy by fmiao on 10/25/2004--
      l_subb_rec.attribute_category,
      l_subb_rec.attribute1,
      l_subb_rec.attribute2,
      l_subb_rec.attribute3,
      l_subb_rec.attribute4,
      l_subb_rec.attribute5,
      l_subb_rec.attribute6,
      l_subb_rec.attribute7,
      l_subb_rec.attribute8,
      l_subb_rec.attribute9,
      l_subb_rec.attribute10,
      l_subb_rec.attribute11,
      l_subb_rec.attribute12,
      l_subb_rec.attribute13,
      l_subb_rec.attribute14,
      l_subb_rec.attribute15,
      l_subb_rec.created_by,
      l_subb_rec.creation_date,
      l_subb_rec.last_updated_by,
      l_subb_rec.last_update_date,
      l_subb_rec.last_update_login,
      -- sjalasut added new column for subsidy pools enhancement. start
      l_subb_rec.subsidy_pool_id
      -- sjalasut added new column for subsidy pools enhancement. end
      );
    -- Set OUT values
    x_subb_rec := l_subb_rec;
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
  -------------------------------------
  -- insert_row for:OKL_SUBSIDIES_TL --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subt_rec                     IN subt_rec_type,
    x_subt_rec                     OUT NOCOPY subt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subt_rec                     subt_rec_type := p_subt_rec;
    l_def_subt_rec                 subt_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:OKL_SUBSIDIES_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_subt_rec IN subt_rec_type,
      x_subt_rec OUT NOCOPY subt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subt_rec := p_subt_rec;
      x_subt_rec.LANGUAGE := USERENV('LANG');
      x_subt_rec.SOURCE_LANG := USERENV('LANG');
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
      p_subt_rec,                        -- IN
      l_subt_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_subt_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_SUBSIDIES_TL(
        id,
        short_description,
        description,
        language,
        source_lang,
        sfwt_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_subt_rec.id,
        l_subt_rec.short_description,
        l_subt_rec.description,
        l_subt_rec.language,
        l_subt_rec.source_lang,
        l_subt_rec.sfwt_flag,
        l_subt_rec.created_by,
        l_subt_rec.creation_date,
        l_subt_rec.last_updated_by,
        l_subt_rec.last_update_date,
        l_subt_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_subt_rec := l_subt_rec;
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
  -------------------------------------
  -- insert_row for :OKL_SUBSIDIES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type,
    x_subv_rec                     OUT NOCOPY subv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subv_rec                     subv_rec_type := p_subv_rec;
    l_def_subv_rec                 subv_rec_type;
    l_subb_rec                     subb_rec_type;
    lx_subb_rec                    subb_rec_type;
    l_subt_rec                     subt_rec_type;
    lx_subt_rec                    subt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_subv_rec IN subv_rec_type
    ) RETURN subv_rec_type IS
      l_subv_rec subv_rec_type := p_subv_rec;
    BEGIN
      l_subv_rec.CREATION_DATE := SYSDATE;
      l_subv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_subv_rec.LAST_UPDATE_DATE := l_subv_rec.CREATION_DATE;
      l_subv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_subv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_subv_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:OKL_SUBSIDIES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_subv_rec IN subv_rec_type,
      x_subv_rec OUT NOCOPY subv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subv_rec := p_subv_rec;
      x_subv_rec.OBJECT_VERSION_NUMBER := 1;
      x_subv_rec.SFWT_FLAG := 'N';
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
    l_subv_rec := null_out_defaults(p_subv_rec);
    -- Set primary key value
    l_subv_rec.ID := get_seq_id;
    --Set the Org_ID
    l_subv_rec.org_id :=  MO_GLOBAL.GET_CURRENT_ORG_ID();
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_subv_rec,                        -- IN
      l_def_subv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_subv_rec := fill_who_columns(l_def_subv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_subv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_subv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_subv_rec, l_subb_rec);
    migrate(l_def_subv_rec, l_subt_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_subb_rec,
      lx_subb_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_subb_rec, l_def_subv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_subt_rec,
      lx_subt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_subt_rec, l_def_subv_rec);
    -- Set OUT values
    x_subv_rec := l_def_subv_rec;
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
  -- PL/SQL TBL insert_row for:SUBV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY  subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      i := p_subv_tbl.FIRST;
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
            p_subv_rec                     => p_subv_tbl(i),
            x_subv_rec                     => x_subv_tbl(i));
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
        EXIT WHEN (i = p_subv_tbl.LAST);
        i := p_subv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:SUBV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_subv_tbl                     => p_subv_tbl,
        x_subv_tbl                     => x_subv_tbl,
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
  ----------------------------------
  -- lock_row for:OKL_SUBSIDIES_B --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subb_rec                     IN subb_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_subb_rec IN subb_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SUBSIDIES_B
     WHERE ID = p_subb_rec.id
       AND OBJECT_VERSION_NUMBER = p_subb_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_subb_rec IN subb_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SUBSIDIES_B
     WHERE ID = p_subb_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_SUBSIDIES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_SUBSIDIES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_subb_rec);
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
      OPEN lchk_csr(p_subb_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_subb_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_subb_rec.object_version_number THEN
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
  -----------------------------------
  -- lock_row for:OKL_SUBSIDIES_TL --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subt_rec                     IN subt_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_subt_rec IN subt_rec_type) IS
    SELECT *
      FROM OKL_SUBSIDIES_TL
     WHERE ID = p_subt_rec.id
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
      OPEN lock_csr(p_subt_rec);
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
  -----------------------------------
  -- lock_row for: OKL_SUBSIDIES_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subt_rec                     subt_rec_type;
    l_subb_rec                     subb_rec_type;
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
    migrate(p_subv_rec, l_subt_rec);
    migrate(p_subv_rec, l_subb_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_subt_rec
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
      l_subb_rec
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
  -- PL/SQL TBL lock_row for:SUBV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      i := p_subv_tbl.FIRST;
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
            p_subv_rec                     => p_subv_tbl(i));
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
        EXIT WHEN (i = p_subv_tbl.LAST);
        i := p_subv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:SUBV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_subv_tbl                     => p_subv_tbl,
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
  ------------------------------------
  -- update_row for:OKL_SUBSIDIES_B --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subb_rec                     IN subb_rec_type,
    x_subb_rec                     OUT NOCOPY subb_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subb_rec                     subb_rec_type := p_subb_rec;
    l_def_subb_rec                 subb_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_subb_rec IN subb_rec_type,
      x_subb_rec OUT NOCOPY subb_rec_type
    ) RETURN VARCHAR2 IS
      l_subb_rec                     subb_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subb_rec := p_subb_rec;
      -- Get current database values
      l_subb_rec := get_rec(p_subb_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_subb_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.id := l_subb_rec.id;
        END IF;
        IF (x_subb_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.object_version_number := l_subb_rec.object_version_number;
        END IF;
        IF (x_subb_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.org_id := l_subb_rec.org_id;
        END IF;
        IF (x_subb_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.name := l_subb_rec.name;
        END IF;
        IF (x_subb_rec.effective_from_date = OKL_API.G_MISS_DATE)
        THEN
          x_subb_rec.effective_from_date := l_subb_rec.effective_from_date;
        END IF;
        IF (x_subb_rec.effective_to_date = OKL_API.G_MISS_DATE)
        THEN
          x_subb_rec.effective_to_date := l_subb_rec.effective_to_date;
        END IF;
        IF (x_subb_rec.expire_after_days = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.expire_after_days := l_subb_rec.expire_after_days;
        END IF;
        IF (x_subb_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.currency_code := l_subb_rec.currency_code;
        END IF;
        IF (x_subb_rec.exclusive_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.exclusive_yn := l_subb_rec.exclusive_yn;
        END IF;
        IF (x_subb_rec.applicable_to_release_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.applicable_to_release_yn := l_subb_rec.applicable_to_release_yn;
        END IF;
        IF (x_subb_rec.subsidy_calc_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.subsidy_calc_basis := l_subb_rec.subsidy_calc_basis;
        END IF;
        IF (x_subb_rec.amount = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.amount := l_subb_rec.amount;
        END IF;
        IF (x_subb_rec.percent = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.percent := l_subb_rec.percent;
        END IF;
        IF (x_subb_rec.formula_id = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.formula_id := l_subb_rec.formula_id;
        END IF;
        IF (x_subb_rec.rate_points = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.rate_points := l_subb_rec.rate_points;
        END IF;
        IF (x_subb_rec.maximum_term = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.maximum_term := l_subb_rec.maximum_term;
        END IF;
        IF (x_subb_rec.vendor_id = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.vendor_id := l_subb_rec.vendor_id;
        END IF;
        IF (x_subb_rec.accounting_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.accounting_method_code := l_subb_rec.accounting_method_code;
        END IF;
        IF (x_subb_rec.recourse_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.recourse_yn := l_subb_rec.recourse_yn;
        END IF;
        IF (x_subb_rec.termination_refund_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.termination_refund_basis := l_subb_rec.termination_refund_basis;
        END IF;
        IF (x_subb_rec.refund_formula_id = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.refund_formula_id := l_subb_rec.refund_formula_id;
        END IF;
        IF (x_subb_rec.stream_type_id = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.stream_type_id := l_subb_rec.stream_type_id;
        END IF;
        IF (x_subb_rec.receipt_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.receipt_method_code := l_subb_rec.receipt_method_code;
        END IF;
        IF (x_subb_rec.customer_visible_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.customer_visible_yn := l_subb_rec.customer_visible_yn;
        END IF;
        IF (x_subb_rec.maximum_financed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.maximum_financed_amount:= l_subb_rec.maximum_financed_amount;
        END IF;
        IF (x_subb_rec.maximum_subsidy_amount = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.maximum_subsidy_amount:= l_subb_rec.maximum_subsidy_amount;
        END IF;
		--Start code changes for Subsidy by fmiao on 10/25/2004--
        IF (x_subb_rec.transfer_basis_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.transfer_basis_code := l_subb_rec.transfer_basis_code;
        END IF;
		--End code changes for Subsidy by fmiao on 10/25/2004--
        IF (x_subb_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute_category := l_subb_rec.attribute_category;
        END IF;
        IF (x_subb_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute1 := l_subb_rec.attribute1;
        END IF;
        IF (x_subb_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute2 := l_subb_rec.attribute2;
        END IF;
        IF (x_subb_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute3 := l_subb_rec.attribute3;
        END IF;
        IF (x_subb_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute4 := l_subb_rec.attribute4;
        END IF;
        IF (x_subb_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute5 := l_subb_rec.attribute5;
        END IF;
        IF (x_subb_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute6 := l_subb_rec.attribute6;
        END IF;
        IF (x_subb_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute7 := l_subb_rec.attribute7;
        END IF;
        IF (x_subb_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute8 := l_subb_rec.attribute8;
        END IF;
        IF (x_subb_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute9 := l_subb_rec.attribute9;
        END IF;
        IF (x_subb_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute10 := l_subb_rec.attribute10;
        END IF;
        IF (x_subb_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute11 := l_subb_rec.attribute11;
        END IF;
        IF (x_subb_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute12 := l_subb_rec.attribute12;
        END IF;
        IF (x_subb_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute13 := l_subb_rec.attribute13;
        END IF;
        IF (x_subb_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute14 := l_subb_rec.attribute14;
        END IF;
        IF (x_subb_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_subb_rec.attribute15 := l_subb_rec.attribute15;
        END IF;
        IF (x_subb_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.created_by := l_subb_rec.created_by;
        END IF;
        IF (x_subb_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_subb_rec.creation_date := l_subb_rec.creation_date;
        END IF;
        IF (x_subb_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.last_updated_by := l_subb_rec.last_updated_by;
        END IF;
        IF (x_subb_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_subb_rec.last_update_date := l_subb_rec.last_update_date;
        END IF;
        IF (x_subb_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.last_update_login := l_subb_rec.last_update_login;
        END IF;
        -- sjalasut added new column for subsidy pools enhancement. start
        IF (x_subb_rec.subsidy_pool_id = OKL_API.G_MISS_NUM)
        THEN
          x_subb_rec.subsidy_pool_id := l_subb_rec.subsidy_pool_id;
        END IF;
        -- sjalasut added new column for subsidy pools enhancement. end
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_SUBSIDIES_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_subb_rec IN subb_rec_type,
      x_subb_rec OUT NOCOPY subb_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subb_rec := p_subb_rec;
      x_subb_rec.OBJECT_VERSION_NUMBER := p_subb_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_subb_rec,                        -- IN
      l_subb_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_subb_rec, l_def_subb_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_SUBSIDIES_B
    SET OBJECT_VERSION_NUMBER = l_def_subb_rec.object_version_number,
        ORG_ID = l_def_subb_rec.org_id,
        NAME = l_def_subb_rec.name,
        EFFECTIVE_FROM_DATE = l_def_subb_rec.effective_from_date,
        EFFECTIVE_TO_DATE = l_def_subb_rec.effective_to_date,
        EXPIRE_AFTER_DAYS = l_def_subb_rec.expire_after_days,
        CURRENCY_CODE = l_def_subb_rec.currency_code,
        EXCLUSIVE_YN = l_def_subb_rec.exclusive_yn,
        APPLICABLE_TO_RELEASE_YN = l_def_subb_rec.applicable_to_release_yn,
        SUBSIDY_CALC_BASIS = l_def_subb_rec.subsidy_calc_basis,
        AMOUNT = l_def_subb_rec.amount,
        PERCENT = l_def_subb_rec.percent,
        FORMULA_ID = l_def_subb_rec.formula_id,
        rate_points = l_def_subb_rec.rate_points,
        MAXIMUM_TERM = l_def_subb_rec.maximum_term,
        VENDOR_ID = l_def_subb_rec.vendor_id,
        ACCOUNTING_METHOD_CODE = l_def_subb_rec.accounting_method_code,
        RECOURSE_YN = l_def_subb_rec.recourse_yn,
        TERMINATION_REFUND_BASIS = l_def_subb_rec.termination_refund_basis,
        REFUND_FORMULA_ID = l_def_subb_rec.refund_formula_id,
        STREAM_TYPE_ID = l_def_subb_rec.stream_type_id,
        RECEIPT_METHOD_CODE = l_def_subb_rec.receipt_method_code,
        CUSTOMER_VISIBLE_YN = l_def_subb_rec.customer_visible_yn,
        MAXIMUM_FINANCED_AMOUNT = l_def_subb_rec.maximum_financed_amount,
        MAXIMUM_SUBSIDY_AMOUNT = l_def_subb_rec.maximum_subsidy_amount,
		--Start code changes for Subsidy by fmiao on 10/25/2004--
		TRANSFER_BASIS_CODE = l_def_subb_rec.transfer_basis_code,
		--End code changes for Subsidy by fmiao on 10/25/2004--
        ATTRIBUTE_CATEGORY = l_def_subb_rec.attribute_category,
        ATTRIBUTE1 = l_def_subb_rec.attribute1,
        ATTRIBUTE2 = l_def_subb_rec.attribute2,
        ATTRIBUTE3 = l_def_subb_rec.attribute3,
        ATTRIBUTE4 = l_def_subb_rec.attribute4,
        ATTRIBUTE5 = l_def_subb_rec.attribute5,
        ATTRIBUTE6 = l_def_subb_rec.attribute6,
        ATTRIBUTE7 = l_def_subb_rec.attribute7,
        ATTRIBUTE8 = l_def_subb_rec.attribute8,
        ATTRIBUTE9 = l_def_subb_rec.attribute9,
        ATTRIBUTE10 = l_def_subb_rec.attribute10,
        ATTRIBUTE11 = l_def_subb_rec.attribute11,
        ATTRIBUTE12 = l_def_subb_rec.attribute12,
        ATTRIBUTE13 = l_def_subb_rec.attribute13,
        ATTRIBUTE14 = l_def_subb_rec.attribute14,
        ATTRIBUTE15 = l_def_subb_rec.attribute15,
        CREATED_BY = l_def_subb_rec.created_by,
        CREATION_DATE = l_def_subb_rec.creation_date,
        LAST_UPDATED_BY = l_def_subb_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_subb_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_subb_rec.last_update_login,
        SUBSIDY_POOL_ID = l_def_subb_rec.subsidy_pool_id
    WHERE ID = l_def_subb_rec.id;

    x_subb_rec := l_subb_rec;
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
  -------------------------------------
  -- update_row for:OKL_SUBSIDIES_TL --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subt_rec                     IN subt_rec_type,
    x_subt_rec                     OUT NOCOPY subt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subt_rec                     subt_rec_type := p_subt_rec;
    l_def_subt_rec                 subt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_subt_rec IN subt_rec_type,
      x_subt_rec OUT NOCOPY subt_rec_type
    ) RETURN VARCHAR2 IS
      l_subt_rec                     subt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subt_rec := p_subt_rec;
      -- Get current database values
      l_subt_rec := get_rec(p_subt_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_subt_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_subt_rec.id := l_subt_rec.id;
        END IF;
        IF (x_subt_rec.short_description = OKL_API.G_MISS_CHAR)
        THEN
          x_subt_rec.short_description := l_subt_rec.short_description;
        END IF;
        IF (x_subt_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_subt_rec.description := l_subt_rec.description;
        END IF;
        IF (x_subt_rec.language = OKL_API.G_MISS_CHAR)
        THEN
          x_subt_rec.language := l_subt_rec.language;
        END IF;
        IF (x_subt_rec.source_lang = OKL_API.G_MISS_CHAR)
        THEN
          x_subt_rec.source_lang := l_subt_rec.source_lang;
        END IF;
        IF (x_subt_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_subt_rec.sfwt_flag := l_subt_rec.sfwt_flag;
        END IF;
        IF (x_subt_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_subt_rec.created_by := l_subt_rec.created_by;
        END IF;
        IF (x_subt_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_subt_rec.creation_date := l_subt_rec.creation_date;
        END IF;
        IF (x_subt_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_subt_rec.last_updated_by := l_subt_rec.last_updated_by;
        END IF;
        IF (x_subt_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_subt_rec.last_update_date := l_subt_rec.last_update_date;
        END IF;
        IF (x_subt_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_subt_rec.last_update_login := l_subt_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_SUBSIDIES_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_subt_rec IN subt_rec_type,
      x_subt_rec OUT NOCOPY subt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subt_rec := p_subt_rec;
      x_subt_rec.LANGUAGE := USERENV('LANG');
      x_subt_rec.LANGUAGE := USERENV('LANG');
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
      p_subt_rec,                        -- IN
      l_subt_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_subt_rec, l_def_subt_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_SUBSIDIES_TL
    SET SHORT_DESCRIPTION = l_def_subt_rec.short_description,
        DESCRIPTION = l_def_subt_rec.description,
        --Bug# 3641933 :
        SOURCE_LANG = l_def_subt_rec.source_lang,
        CREATED_BY = l_def_subt_rec.created_by,
        CREATION_DATE = l_def_subt_rec.creation_date,
        LAST_UPDATED_BY = l_def_subt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_subt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_subt_rec.last_update_login
    WHERE ID = l_def_subt_rec.id
      --Bug# 3641933 :
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_SUBSIDIES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_subt_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_subt_rec := l_subt_rec;
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
  ------------------------------------
  -- update_row for:OKL_SUBSIDIES_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type,
    x_subv_rec                     OUT NOCOPY subv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subv_rec                     subv_rec_type := p_subv_rec;
    l_def_subv_rec                 subv_rec_type;
    l_db_subv_rec                  subv_rec_type;
    l_subb_rec                     subb_rec_type;
    lx_subb_rec                    subb_rec_type;
    l_subt_rec                     subt_rec_type;
    lx_subt_rec                    subt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_subv_rec IN subv_rec_type
    ) RETURN subv_rec_type IS
      l_subv_rec subv_rec_type := p_subv_rec;
    BEGIN
      l_subv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_subv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_subv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_subv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_subv_rec IN subv_rec_type,
      x_subv_rec OUT NOCOPY subv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subv_rec := p_subv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_subv_rec := get_rec(p_subv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_subv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.id := l_db_subv_rec.id;
        END IF;
        IF (x_subv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.sfwt_flag := l_db_subv_rec.sfwt_flag;
        END IF;
        IF (x_subv_rec.org_id = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.org_id := l_db_subv_rec.org_id;
        END IF;
        IF (x_subv_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.name := l_db_subv_rec.name;
        END IF;
        IF (x_subv_rec.short_description = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.short_description := l_db_subv_rec.short_description;
        END IF;
        IF (x_subv_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.description := l_db_subv_rec.description;
        END IF;
        IF (x_subv_rec.effective_from_date = OKL_API.G_MISS_DATE)
        THEN
          x_subv_rec.effective_from_date := l_db_subv_rec.effective_from_date;
        END IF;
        IF (x_subv_rec.effective_to_date = OKL_API.G_MISS_DATE)
        THEN
          x_subv_rec.effective_to_date := l_db_subv_rec.effective_to_date;
        END IF;
        IF (x_subv_rec.expire_after_days = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.expire_after_days := l_db_subv_rec.expire_after_days;
        END IF;
        IF (x_subv_rec.currency_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.currency_code := l_db_subv_rec.currency_code;
        END IF;
        IF (x_subv_rec.exclusive_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.exclusive_yn := l_db_subv_rec.exclusive_yn;
        END IF;
        IF (x_subv_rec.applicable_to_release_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.applicable_to_release_yn := l_db_subv_rec.applicable_to_release_yn;
        END IF;
        IF (x_subv_rec.subsidy_calc_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.subsidy_calc_basis := l_db_subv_rec.subsidy_calc_basis;
        END IF;
        IF (x_subv_rec.amount = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.amount := l_db_subv_rec.amount;
        END IF;
        IF (x_subv_rec.percent = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.percent := l_db_subv_rec.percent;
        END IF;
        IF (x_subv_rec.formula_id = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.formula_id := l_db_subv_rec.formula_id;
        END IF;
        IF (x_subv_rec.rate_points = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.rate_points := l_db_subv_rec.rate_points;
        END IF;
        IF (x_subv_rec.maximum_term = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.maximum_term := l_db_subv_rec.maximum_term;
        END IF;
        IF (x_subv_rec.vendor_id = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.vendor_id := l_db_subv_rec.vendor_id;
        END IF;
        IF (x_subv_rec.accounting_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.accounting_method_code := l_db_subv_rec.accounting_method_code;
        END IF;
        IF (x_subv_rec.recourse_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.recourse_yn := l_db_subv_rec.recourse_yn;
        END IF;
        IF (x_subv_rec.termination_refund_basis = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.termination_refund_basis := l_db_subv_rec.termination_refund_basis;
        END IF;
        IF (x_subv_rec.refund_formula_id = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.refund_formula_id := l_db_subv_rec.refund_formula_id;
        END IF;
        IF (x_subv_rec.stream_type_id = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.stream_type_id := l_db_subv_rec.stream_type_id;
        END IF;
        IF (x_subv_rec.receipt_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.receipt_method_code := l_db_subv_rec.receipt_method_code;
        END IF;
        IF (x_subv_rec.customer_visible_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.customer_visible_yn := l_db_subv_rec.customer_visible_yn;
        END IF;
        IF (x_subv_rec.maximum_financed_amount = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.maximum_financed_amount := l_db_subv_rec.maximum_financed_amount;
        END IF;
        IF (x_subv_rec.maximum_subsidy_amount = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.maximum_subsidy_amount := l_db_subv_rec.maximum_subsidy_amount;
        END IF;
		--Start code changes for Subsidy by fmiao on 10/25/2004--
        IF (x_subv_rec.transfer_basis_code = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.transfer_basis_code := l_db_subv_rec.transfer_basis_code;
        END IF;
		--End code changes for Subsidy by fmiao on 10/25/2004--
        IF (x_subv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute_category := l_db_subv_rec.attribute_category;
        END IF;
        IF (x_subv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute1 := l_db_subv_rec.attribute1;
        END IF;
        IF (x_subv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute2 := l_db_subv_rec.attribute2;
        END IF;
        IF (x_subv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute3 := l_db_subv_rec.attribute3;
        END IF;
        IF (x_subv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute4 := l_db_subv_rec.attribute4;
        END IF;
        IF (x_subv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute5 := l_db_subv_rec.attribute5;
        END IF;
        IF (x_subv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute6 := l_db_subv_rec.attribute6;
        END IF;
        IF (x_subv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute7 := l_db_subv_rec.attribute7;
        END IF;
        IF (x_subv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute8 := l_db_subv_rec.attribute8;
        END IF;
        IF (x_subv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute9 := l_db_subv_rec.attribute9;
        END IF;
        IF (x_subv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute10 := l_db_subv_rec.attribute10;
        END IF;
        IF (x_subv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute11 := l_db_subv_rec.attribute11;
        END IF;
        IF (x_subv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute12 := l_db_subv_rec.attribute12;
        END IF;
        IF (x_subv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute13 := l_db_subv_rec.attribute13;
        END IF;
        IF (x_subv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute14 := l_db_subv_rec.attribute14;
        END IF;
        IF (x_subv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_subv_rec.attribute15 := l_db_subv_rec.attribute15;
        END IF;
        IF (x_subv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.created_by := l_db_subv_rec.created_by;
        END IF;
        IF (x_subv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_subv_rec.creation_date := l_db_subv_rec.creation_date;
        END IF;
        IF (x_subv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.last_updated_by := l_db_subv_rec.last_updated_by;
        END IF;
        IF (x_subv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_subv_rec.last_update_date := l_db_subv_rec.last_update_date;
        END IF;
        IF (x_subv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.last_update_login := l_db_subv_rec.last_update_login;
        END IF;
        -- sjalasut added new column for subsidy pools enhancement. start
        IF (x_subv_rec.subsidy_pool_id = OKL_API.G_MISS_NUM)
        THEN
          x_subv_rec.subsidy_pool_id := l_db_subv_rec.subsidy_pool_id;
        END IF;
        -- sjalasut added new column for subsidy pools enhancement. end
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:OKL_SUBSIDIES_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_subv_rec IN subv_rec_type,
      x_subv_rec OUT NOCOPY subv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_subv_rec := p_subv_rec;
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
      p_subv_rec,                        -- IN
      x_subv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_subv_rec, l_def_subv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_subv_rec := fill_who_columns(l_def_subv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_subv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_subv_rec, l_db_subv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
/****Commented**********
    --avsingh
    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_subv_rec                     => p_subv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
***********************/

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_subv_rec, l_subb_rec);
    migrate(l_def_subv_rec, l_subt_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_subb_rec,
      lx_subb_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_subb_rec, l_def_subv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_subt_rec,
      lx_subt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_subt_rec, l_def_subv_rec);
    x_subv_rec := l_def_subv_rec;
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
  -- PL/SQL TBL update_row for:subv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY  subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      i := p_subv_tbl.FIRST;
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
            p_subv_rec                     => p_subv_tbl(i),
            x_subv_rec                     => x_subv_tbl(i));
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
        EXIT WHEN (i = p_subv_tbl.LAST);
        i := p_subv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:SUBV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    x_subv_tbl                     OUT NOCOPY subv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_subv_tbl                     => p_subv_tbl,
        x_subv_tbl                     => x_subv_tbl,
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
  ------------------------------------
  -- delete_row for:OKL_SUBSIDIES_B --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subb_rec                     IN subb_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subb_rec                     subb_rec_type := p_subb_rec;
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

    DELETE FROM OKL_SUBSIDIES_B
     WHERE ID = p_subb_rec.id;

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
  -------------------------------------
  -- delete_row for:OKL_SUBSIDIES_TL --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subt_rec                     IN subt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subt_rec                     subt_rec_type := p_subt_rec;
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

    DELETE FROM OKL_SUBSIDIES_TL
     WHERE ID = p_subt_rec.id;

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
  ------------------------------------
  -- delete_row for:OKL_SUBSIDIES_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_rec                     IN subv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_subv_rec                     subv_rec_type := p_subv_rec;
    l_subt_rec                     subt_rec_type;
    l_subb_rec                     subb_rec_type;
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
    migrate(l_subv_rec, l_subt_rec);
    migrate(l_subv_rec, l_subb_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_subt_rec
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
      l_subb_rec
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
  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_SUBSIDIES_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      i := p_subv_tbl.FIRST;
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
            p_subv_rec                     => p_subv_tbl(i));
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
        EXIT WHEN (i = p_subv_tbl.LAST);
        i := p_subv_tbl.NEXT(i);
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

  -----------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_SUBSIDIES_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_subv_tbl                     IN subv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_subv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_subv_tbl                     => p_subv_tbl,
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

END OKL_SUB_PVT;

/
