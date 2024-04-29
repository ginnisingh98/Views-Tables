--------------------------------------------------------
--  DDL for Package Body OKL_IPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IPY_PVT" AS
/* $Header: OKLSIPYB.pls 120.12 2007/10/10 11:19:41 zrehman noship $ */
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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_INS_POLICIES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_INS_POLICIES_ALL_B  B
         WHERE B.ID =T.ID
        );
    UPDATE OKL_INS_POLICIES_TL T SET(
        DESCRIPTION,
        ENDORSEMENT,
        COMMENTS,
        CANCELLATION_COMMENT) = (SELECT
                                  B.DESCRIPTION,
                                  B.ENDORSEMENT,
                                  B.COMMENTS,
                                  B.CANCELLATION_COMMENT
                                FROM OKL_INS_POLICIES_TL B
                               WHERE B.ID = T.ID
                               AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID, T.LANGUAGE)
          IN (SELECT
                  SUBT.ID
                  ,SUBT.LANGUAGE
                FROM OKL_INS_POLICIES_TL SUBB, OKL_INS_POLICIES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
               AND SUBB.LANGUAGE = SUBT.LANGUAGE
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.ENDORSEMENT <> SUBT.ENDORSEMENT
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR SUBB.CANCELLATION_COMMENT <> SUBT.CANCELLATION_COMMENT
                      OR (SUBB.LANGUAGE IS NOT NULL AND SUBT.LANGUAGE IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.ENDORSEMENT IS NULL AND SUBT.ENDORSEMENT IS NOT NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.CANCELLATION_COMMENT IS NULL AND SUBT.CANCELLATION_COMMENT IS NOT NULL)
              ));
    INSERT INTO OKL_INS_POLICIES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        ENDORSEMENT,
        COMMENTS,
        CANCELLATION_COMMENT,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.DESCRIPTION,
            B.ENDORSEMENT,
            B.COMMENTS,
            B.CANCELLATION_COMMENT,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_INS_POLICIES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_INS_POLICIES_TL T
                     WHERE T.ID = B.ID
                     AND  T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

 ---------------------------------------------------------------------------
 -- PROCEDURE Validate_Duplicates
 ---------------------------------------------------------------------------
      PROCEDURE validate_thirdparty_duplicates(
        p_ipyv_rec          IN ipyv_rec_type,
        x_return_status 	OUT NOCOPY VARCHAR2) IS
        l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        l_dummy_var VARCHAR2(1) := '?';
        CURSOR l_ipyv_csr IS
        SELECT 'x'
        FROM   okl_ins_policies_v
        WHERE  ipy_type = 'THIRD_PARTY_POLICY'
        AND    ipy_type = p_ipyv_rec.ipy_type
        AND    policy_number = p_ipyv_rec.policy_number
        AND    ID <> p_ipyv_rec.id
        AND    ISU_ID = p_ipyv_rec.isu_id;
      BEGIN
    	OPEN l_ipyv_csr;
    	FETCH l_ipyv_csr INTO l_dummy_var;
    	CLOSE l_ipyv_csr;
    -- if l_dummy_var is still set to default, data was not found
       IF (l_dummy_var = 'x') THEN
          OKC_API.set_message(p_app_name 	    => G_APP_NAME,
  	                    p_msg_name      => 'OKL_UNIQUE'
  			    );
          l_return_status := Okc_Api.G_RET_STS_ERROR;
       END IF;
        x_return_status := l_return_status;
      EXCEPTION
         WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
          Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
          -- notify caller of an UNEXPECTED error
          x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    END validate_thirdparty_duplicates;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_POLICIES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ipyv_rec                     IN ipyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ipyv_rec_type IS
    CURSOR okl_ipyv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            IPY_TYPE,
            DESCRIPTION,
            ENDORSEMENT,
            SFWT_FLAG,
            CANCELLATION_COMMENT,
            COMMENTS,
            NAME_OF_INSURED,
            POLICY_NUMBER,
            CALCULATED_PREMIUM,
            PREMIUM,
            COVERED_AMOUNT,
            DEDUCTIBLE,
            ADJUSTMENT,
            PAYMENT_FREQUENCY,
            CRX_CODE,
            IPF_CODE,
            ISS_CODE,
            IPE_CODE,
            DATE_TO,
            DATE_FROM,
            DATE_QUOTED,
            DATE_PROOF_PROVIDED,
            DATE_PROOF_REQUIRED,
            CANCELLATION_DATE,
            DATE_QUOTE_EXPIRY,
            ACTIVATION_DATE,
            QUOTE_YN,
            ON_FILE_YN,
            PRIVATE_LABEL_YN,
            AGENT_YN,
            LESSOR_INSURED_YN,
            LESSOR_PAYEE_YN,
            KHR_ID,
            KLE_ID,
            IPT_ID,
            IPY_ID,
            INT_ID,
            ISU_ID,
            INSURANCE_FACTOR,
            FACTOR_CODE,
            FACTOR_VALUE,
            AGENCY_NUMBER,
            AGENCY_SITE_ID,
            SALES_REP_ID,
            AGENT_SITE_ID,
            ADJUSTED_BY_ID,
            TERRITORY_CODE,
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
            PROGRAM_ID,
            ORG_ID,
            PROGRAM_UPDATE_DATE,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
            LEASE_APPLICATION_ID,
            LEGAL_ENTITY_ID
      FROM Okl_Ins_Policies_V
     WHERE okl_ins_policies_v.id = p_id;
    l_okl_ipyv_pk                  okl_ipyv_pk_csr%ROWTYPE;
    l_ipyv_rec                     ipyv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ipyv_pk_csr (p_ipyv_rec.id);
    FETCH okl_ipyv_pk_csr INTO
              l_ipyv_rec.id,
              l_ipyv_rec.ipy_type,
              l_ipyv_rec.description,
              l_ipyv_rec.endorsement,
              l_ipyv_rec.sfwt_flag,
              l_ipyv_rec.cancellation_comment,
              l_ipyv_rec.comments,
              l_ipyv_rec.name_of_insured,
              l_ipyv_rec.policy_number,
              l_ipyv_rec.calculated_premium,
              l_ipyv_rec.premium,
              l_ipyv_rec.covered_amount,
              l_ipyv_rec.deductible,
              l_ipyv_rec.adjustment,
              l_ipyv_rec.payment_frequency,
              l_ipyv_rec.crx_code,
              l_ipyv_rec.ipf_code,
              l_ipyv_rec.iss_code,
              l_ipyv_rec.ipe_code,
              l_ipyv_rec.date_to,
              l_ipyv_rec.date_from,
              l_ipyv_rec.date_quoted,
              l_ipyv_rec.date_proof_provided,
              l_ipyv_rec.date_proof_required,
              l_ipyv_rec.cancellation_date,
              l_ipyv_rec.date_quote_expiry,
              l_ipyv_rec.activation_date,
              l_ipyv_rec.quote_yn,
              l_ipyv_rec.on_file_yn,
              l_ipyv_rec.private_label_yn,
              l_ipyv_rec.agent_yn,
              l_ipyv_rec.lessor_insured_yn,
              l_ipyv_rec.lessor_payee_yn,
              l_ipyv_rec.khr_id,
              l_ipyv_rec.kle_id,
              l_ipyv_rec.ipt_id,
              l_ipyv_rec.ipy_id,
              l_ipyv_rec.int_id,
              l_ipyv_rec.isu_id,
              l_ipyv_rec.insurance_factor,
              l_ipyv_rec.factor_code,
              l_ipyv_rec.factor_value,
              l_ipyv_rec.agency_number,
              l_ipyv_rec.agency_site_id,
              l_ipyv_rec.sales_rep_id,
              l_ipyv_rec.agent_site_id,
              l_ipyv_rec.adjusted_by_id,
              l_ipyv_rec.territory_code,
              l_ipyv_rec.attribute_category,
              l_ipyv_rec.attribute1,
              l_ipyv_rec.attribute2,
              l_ipyv_rec.attribute3,
              l_ipyv_rec.attribute4,
              l_ipyv_rec.attribute5,
              l_ipyv_rec.attribute6,
              l_ipyv_rec.attribute7,
              l_ipyv_rec.attribute8,
              l_ipyv_rec.attribute9,
              l_ipyv_rec.attribute10,
              l_ipyv_rec.attribute11,
              l_ipyv_rec.attribute12,
              l_ipyv_rec.attribute13,
              l_ipyv_rec.attribute14,
              l_ipyv_rec.attribute15,
              l_ipyv_rec.program_id,
              l_ipyv_rec.org_id,
              l_ipyv_rec.program_update_date,
              l_ipyv_rec.program_application_id,
              l_ipyv_rec.request_id,
              l_ipyv_rec.object_version_number,
              l_ipyv_rec.created_by,
              l_ipyv_rec.creation_date,
              l_ipyv_rec.last_updated_by,
              l_ipyv_rec.last_update_date,
              l_ipyv_rec.last_update_login,
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
              l_ipyv_rec.lease_application_id,
              l_ipyv_rec.legal_entity_id;
    x_no_data_found := okl_ipyv_pk_csr%NOTFOUND;
    CLOSE okl_ipyv_pk_csr;
    RETURN(l_ipyv_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ipyv_rec                     IN ipyv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ipyv_rec_type IS
    l_ipyv_rec                     ipyv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ipyv_rec := get_rec(p_ipyv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ipyv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ipyv_rec                     IN ipyv_rec_type
  ) RETURN ipyv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ipyv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_POLICIES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ipy_rec                      IN ipy_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ipy_rec_type IS
    CURSOR ipy_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            IPY_TYPE,
            NAME_OF_INSURED,
            POLICY_NUMBER,
            INSURANCE_FACTOR,
            FACTOR_CODE,
            CALCULATED_PREMIUM,
            PREMIUM,
            COVERED_AMOUNT,
            DEDUCTIBLE,
            ADJUSTMENT,
            PAYMENT_FREQUENCY,
            CRX_CODE,
            IPF_CODE,
            ISS_CODE,
            IPE_CODE,
            DATE_TO,
            DATE_FROM,
            DATE_QUOTED,
            DATE_PROOF_PROVIDED,
            DATE_PROOF_REQUIRED,
            CANCELLATION_DATE,
            DATE_QUOTE_EXPIRY,
            ACTIVATION_DATE,
            QUOTE_YN,
            ON_FILE_YN,
            PRIVATE_LABEL_YN,
            AGENT_YN,
            LESSOR_INSURED_YN,
            LESSOR_PAYEE_YN,
            KHR_ID,
            KLE_ID,
            IPT_ID,
            IPY_ID,
            INT_ID,
            ISU_ID,
            FACTOR_VALUE,
            AGENCY_NUMBER,
            AGENCY_SITE_ID,
            SALES_REP_ID,
            AGENT_SITE_ID,
            ADJUSTED_BY_ID,
            TERRITORY_CODE,
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
            PROGRAM_ID,
            ORG_ID,
            PROGRAM_UPDATE_DATE,
            PROGRAM_APPLICATION_ID,
            REQUEST_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
            LEASE_APPLICATION_ID,
            LEGAL_ENTITY_ID
      FROM Okl_Ins_Policies_B
     WHERE okl_ins_policies_b.id = p_id;
    l_ipy_pk                       ipy_pk_csr%ROWTYPE;
    l_ipy_rec                      ipy_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ipy_pk_csr (p_ipy_rec.id);
    FETCH ipy_pk_csr INTO
              l_ipy_rec.id,
              l_ipy_rec.ipy_type,
              l_ipy_rec.name_of_insured,
              l_ipy_rec.policy_number,
              l_ipy_rec.insurance_factor,
              l_ipy_rec.factor_code,
              l_ipy_rec.calculated_premium,
              l_ipy_rec.premium,
              l_ipy_rec.covered_amount,
              l_ipy_rec.deductible,
              l_ipy_rec.adjustment,
              l_ipy_rec.payment_frequency,
              l_ipy_rec.crx_code,
              l_ipy_rec.ipf_code,
              l_ipy_rec.iss_code,
              l_ipy_rec.ipe_code,
              l_ipy_rec.date_to,
              l_ipy_rec.date_from,
              l_ipy_rec.date_quoted,
              l_ipy_rec.date_proof_provided,
              l_ipy_rec.date_proof_required,
              l_ipy_rec.cancellation_date,
              l_ipy_rec.date_quote_expiry,
              l_ipy_rec.activation_date,
              l_ipy_rec.quote_yn,
              l_ipy_rec.on_file_yn,
              l_ipy_rec.private_label_yn,
              l_ipy_rec.agent_yn,
              l_ipy_rec.lessor_insured_yn,
              l_ipy_rec.lessor_payee_yn,
              l_ipy_rec.khr_id,
              l_ipy_rec.kle_id,
              l_ipy_rec.ipt_id,
              l_ipy_rec.ipy_id,
              l_ipy_rec.int_id,
              l_ipy_rec.isu_id,
              l_ipy_rec.factor_value,
              l_ipy_rec.agency_number,
              l_ipy_rec.agency_site_id,
              l_ipy_rec.sales_rep_id,
              l_ipy_rec.agent_site_id,
              l_ipy_rec.adjusted_by_id,
              l_ipy_rec.territory_code,
              l_ipy_rec.attribute_category,
              l_ipy_rec.attribute1,
              l_ipy_rec.attribute2,
              l_ipy_rec.attribute3,
              l_ipy_rec.attribute4,
              l_ipy_rec.attribute5,
              l_ipy_rec.attribute6,
              l_ipy_rec.attribute7,
              l_ipy_rec.attribute8,
              l_ipy_rec.attribute9,
              l_ipy_rec.attribute10,
              l_ipy_rec.attribute11,
              l_ipy_rec.attribute12,
              l_ipy_rec.attribute13,
              l_ipy_rec.attribute14,
              l_ipy_rec.attribute15,
              l_ipy_rec.program_id,
              l_ipy_rec.org_id,
              l_ipy_rec.program_update_date,
              l_ipy_rec.program_application_id,
              l_ipy_rec.request_id,
              l_ipy_rec.object_version_number,
              l_ipy_rec.created_by,
              l_ipy_rec.creation_date,
              l_ipy_rec.last_updated_by,
              l_ipy_rec.last_update_date,
              l_ipy_rec.last_update_login,
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
              l_ipy_rec.lease_application_id,
              l_ipy_rec.legal_entity_id;
    x_no_data_found := ipy_pk_csr%NOTFOUND;
    CLOSE ipy_pk_csr;
    RETURN(l_ipy_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ipy_rec                      IN ipy_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ipy_rec_type IS
    l_ipy_rec                      ipy_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ipy_rec := get_rec(p_ipy_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ipy_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ipy_rec                      IN ipy_rec_type
  ) RETURN ipy_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ipy_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_POLICIES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_ins_policies_tl_rec      IN okl_ins_policies_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_ins_policies_tl_rec_type IS
    CURSOR ipy_tl_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            ENDORSEMENT,
            COMMENTS,
            CANCELLATION_COMMENT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ins_Policies_Tl
     WHERE okl_ins_policies_tl.id = p_id;
    l_ipy_tl_pk                    ipy_tl_pk_csr%ROWTYPE;
    l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ipy_tl_pk_csr (p_okl_ins_policies_tl_rec.id);
    FETCH ipy_tl_pk_csr INTO
              l_okl_ins_policies_tl_rec.id,
              l_okl_ins_policies_tl_rec.language,
              l_okl_ins_policies_tl_rec.source_lang,
              l_okl_ins_policies_tl_rec.sfwt_flag,
              l_okl_ins_policies_tl_rec.description,
              l_okl_ins_policies_tl_rec.endorsement,
              l_okl_ins_policies_tl_rec.comments,
              l_okl_ins_policies_tl_rec.cancellation_comment,
              l_okl_ins_policies_tl_rec.created_by,
              l_okl_ins_policies_tl_rec.creation_date,
              l_okl_ins_policies_tl_rec.last_updated_by,
              l_okl_ins_policies_tl_rec.last_update_date,
              l_okl_ins_policies_tl_rec.last_update_login;
    x_no_data_found := ipy_tl_pk_csr%NOTFOUND;
    CLOSE ipy_tl_pk_csr;
    RETURN(l_okl_ins_policies_tl_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_ins_policies_tl_rec      IN okl_ins_policies_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_ins_policies_tl_rec_type IS
    l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okl_ins_policies_tl_rec := get_rec(p_okl_ins_policies_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_ins_policies_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_ins_policies_tl_rec      IN okl_ins_policies_tl_rec_type
  ) RETURN okl_ins_policies_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_ins_policies_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INS_POLICIES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ipyv_rec   IN ipyv_rec_type
  ) RETURN ipyv_rec_type IS
    l_ipyv_rec                     ipyv_rec_type := p_ipyv_rec;
  BEGIN
    IF (l_ipyv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.id := NULL;
    END IF;
    IF (l_ipyv_rec.ipy_type = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.ipy_type := NULL;
    END IF;
    IF (l_ipyv_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.description := NULL;
    END IF;
    IF (l_ipyv_rec.endorsement = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.endorsement := NULL;
    END IF;
    IF (l_ipyv_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ipyv_rec.cancellation_comment = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.cancellation_comment := NULL;
    END IF;
    IF (l_ipyv_rec.comments = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.comments := NULL;
    END IF;
    IF (l_ipyv_rec.name_of_insured = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.name_of_insured := NULL;
    END IF;
    IF (l_ipyv_rec.policy_number = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.policy_number := NULL;
    END IF;
    IF (l_ipyv_rec.calculated_premium = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.calculated_premium := NULL;
    END IF;
    IF (l_ipyv_rec.premium = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.premium := NULL;
    END IF;
    IF (l_ipyv_rec.covered_amount = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.covered_amount := NULL;
    END IF;
    IF (l_ipyv_rec.deductible = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.deductible := NULL;
    END IF;
    IF (l_ipyv_rec.adjustment = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.adjustment := NULL;
    END IF;
    IF (l_ipyv_rec.payment_frequency = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.payment_frequency := NULL;
    END IF;
    IF (l_ipyv_rec.crx_code = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.crx_code := NULL;
    END IF;
    IF (l_ipyv_rec.ipf_code = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.ipf_code := NULL;
    END IF;
    IF (l_ipyv_rec.iss_code = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.iss_code := NULL;
    END IF;
    IF (l_ipyv_rec.ipe_code = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.ipe_code := NULL;
    END IF;
    IF (l_ipyv_rec.date_to = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.date_to := NULL;
    END IF;
    IF (l_ipyv_rec.date_from = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.date_from := NULL;
    END IF;
    IF (l_ipyv_rec.date_quoted = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.date_quoted := NULL;
    END IF;
    IF (l_ipyv_rec.date_proof_provided = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.date_proof_provided := NULL;
    END IF;
    IF (l_ipyv_rec.date_proof_required = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.date_proof_required := NULL;
    END IF;
    IF (l_ipyv_rec.cancellation_date = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.cancellation_date := NULL;
    END IF;
    IF (l_ipyv_rec.date_quote_expiry = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.date_quote_expiry := NULL;
    END IF;
    IF (l_ipyv_rec.activation_date = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.activation_date := NULL;
    END IF;
    IF (l_ipyv_rec.quote_yn = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.quote_yn := NULL;
    END IF;
    IF (l_ipyv_rec.on_file_yn = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.on_file_yn := NULL;
    END IF;
    IF (l_ipyv_rec.private_label_yn = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.private_label_yn := NULL;
    END IF;
    IF (l_ipyv_rec.agent_yn = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.agent_yn := NULL;
    END IF;
    IF (l_ipyv_rec.lessor_insured_yn = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.lessor_insured_yn := NULL;
    END IF;
    IF (l_ipyv_rec.lessor_payee_yn = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.lessor_payee_yn := NULL;
    END IF;
    IF (l_ipyv_rec.khr_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.khr_id := NULL;
    END IF;
    IF (l_ipyv_rec.kle_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.kle_id := NULL;
    END IF;
    IF (l_ipyv_rec.ipt_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.ipt_id := NULL;
    END IF;
    IF (l_ipyv_rec.ipy_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.ipy_id := NULL;
    END IF;
    IF (l_ipyv_rec.int_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.int_id := NULL;
    END IF;
    IF (l_ipyv_rec.isu_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.isu_id := NULL;
    END IF;
    IF (l_ipyv_rec.insurance_factor = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.insurance_factor := NULL;
    END IF;
    IF (l_ipyv_rec.factor_code = OKC_API.G_MISS_CHAR) THEN
              l_ipyv_rec.factor_code := NULL;
    END IF;
    IF (l_ipyv_rec.factor_value = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.factor_value := NULL;
    END IF;
    IF (l_ipyv_rec.agency_number = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.agency_number := NULL;
    END IF;
    IF (l_ipyv_rec.agency_site_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.agency_site_id := NULL;
    END IF;
    IF (l_ipyv_rec.sales_rep_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.sales_rep_id := NULL;
    END IF;
    IF (l_ipyv_rec.agent_site_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.agent_site_id := NULL;
    END IF;
    IF (l_ipyv_rec.adjusted_by_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.adjusted_by_id := NULL;
    END IF;
    IF (l_ipyv_rec.territory_code = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.territory_code := NULL;
    END IF;
    IF (l_ipyv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute_category := NULL;
    END IF;
    IF (l_ipyv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute1 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute2 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute3 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute4 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute5 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute6 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute7 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute8 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute9 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute10 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute11 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute12 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute13 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute14 := NULL;
    END IF;
    IF (l_ipyv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_ipyv_rec.attribute15 := NULL;
    END IF;
    IF (l_ipyv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.object_version_number := NULL;
    END IF;
    IF (l_ipyv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.created_by := NULL;
    END IF;
    IF (l_ipyv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.creation_date := NULL;
    END IF;
    IF (l_ipyv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ipyv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_ipyv_rec.last_update_date := NULL;
    END IF;
    IF (l_ipyv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.last_update_login := NULL;
    END IF;
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
    IF (l_ipyv_rec.lease_application_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.lease_application_id := NULL;
    END IF;
    IF (l_ipyv_rec.legal_entity_id = OKC_API.G_MISS_NUM ) THEN
      l_ipyv_rec.legal_entity_id := NULL;
    END IF;
    RETURN(l_ipyv_rec);
    RETURN(l_ipyv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------
    -- Validate_Attributes for: ID --
  ---------------------------------------------
    PROCEDURE validate_id (p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2 ) IS
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
  		-- initialize return status
  		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
  		-- data is required
  		IF ( ( p_ipyv_rec.id IS NULL)  OR  (p_ipyv_rec.id = OKC_API.G_MISS_NUM)) THEN
  			OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'ID');
  			-- notify caller of an error
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
        EXCEPTION
             WHEN OTHERS THEN
                 -- store SQL error message on message stack for caller
                 OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
        		-- notify caller of an UNEXPECTED error
        		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
     END   validate_id ;
    -- End validate_id
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_legal_entity_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_legal_entity_id (p_ipyv_rec IN ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
   l_exists                NUMBER(1);
   le_not_found_error      EXCEPTION;
   BEGIN
	x_return_status := Okl_Api.G_RET_STS_SUCCESS;
	IF (p_ipyv_rec.legal_entity_id IS NOT NULL) THEN
		l_exists := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_ipyv_rec.legal_entity_id);
	   IF(l_exists <> 1) THEN
              Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
              RAISE le_not_found_error;
           END IF;
	END IF;
   EXCEPTION
        WHEN le_not_found_error THEN
              x_return_status := OKC_API.G_RET_STS_ERROR;
        WHEN OTHERS THEN
              -- store SQL error message on message stack for caller
              OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              -- notify caller of an UNEXPECTED error
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_legal_entity_id;
  ---------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ---------------------------------------------
    PROCEDURE validate_object_version_number ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
    	-- initialize return status
    	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
    	-- data is required
    	IF ( ( p_ipyv_rec.object_version_number IS NULL)  OR  (p_ipyv_rec.object_version_number = OKC_API.G_MISS_NUM)) THEN
    		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Object Version Number');
    		-- notify caller of an error
    		x_return_status := OKC_API.G_RET_STS_ERROR;
    	END IF;
      EXCEPTION
      	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
          	-- notify caller of an UNEXPECTED error
          	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END   validate_object_version_number ;
    -- End validate_object_version_number
  ---------------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ---------------------------------------------
    PROCEDURE validate_sfwt_flag ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
       l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
       BEGIN
       	-- initialize return status
        	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        	-- data is required
        	IF ( ( p_ipyv_rec.sfwt_flag IS NULL)  OR  (p_ipyv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)) THEN
        		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Sfwt Flag');
        		-- notify caller of an error
        		x_return_status := OKC_API.G_RET_STS_ERROR;
        	END IF;
        EXCEPTION
        	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              	-- notify caller of an UNEXPECTED error
              	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END   validate_sfwt_flag ;
    -- End validate_sfwt_flag
  ---------------------------------------------
  -- Validate_Attributes for: TERRITORY_CODE --
  ---------------------------------------------
  PROCEDURE validate_territory_code( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
          l_dummy_var                    VARCHAR2(1) :='?';
          l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
         -- select the ID  of the parent  record from the parent table
          CURSOR  l_terr_csr IS
	  	     SELECT 'x'
	  	     FROM FND_TERRITORIES_VL
	     WHERE territory_code = p_ipyv_rec.territory_code;
           BEGIN
             --data is required
            IF (p_ipyv_rec.territory_code = OKC_API.G_MISS_CHAR) THEN
	          	OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Territory Code');
      	  -- Notify caller of  an error
               l_return_status := Okc_Api.G_RET_STS_ERROR;
               x_return_status := l_return_status;
      	END IF;
             -- enforce foreign key
     			OPEN  l_terr_csr ;
	          	FETCH l_terr_csr INTO l_dummy_var ;
	          	CLOSE l_terr_csr ;
	        -- if l_dummy_var is still set to default ,data was not found
               IF (l_dummy_var ='?') THEN
                 OKC_API.set_message(G_APP_NAME,G_NO_PARENT_RECORD,G_COL_NAME_TOKEN,'Territory Code',g_child_table_token,'OKL_INS_POLICIES_V',g_parent_table_token,'FND_TERRITORIES_VL');
             --notify caller of an error
             x_return_status := OKC_API.G_RET_STS_ERROR;
             END IF;
             EXCEPTION
                 WHEN OTHERS THEN
                  -- store SQL error  message on message stack for caller
                  Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                  -- Notify the caller of an unexpected error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  -- Verify  that cursor was closed
                  IF l_terr_csr%ISOPEN THEN
		    CLOSE l_terr_csr;
  	          END IF;
      END validate_territory_code;
  ---------------------------------------------
  -- Validate_Attributes for: IPF_CODE --
  ---------------------------------------------
   PROCEDURE validate_ipf_code ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var		VARCHAR2(1) := '?' ;
    l_system_date         DATE  := SYSDATE ;
    CURSOR  l_ipf_csr IS
     SELECT 'x'
     FROM FND_LOOKUPS
     WHERE LOOKUP_code = p_ipyv_rec.ipf_code
         AND LOOKUP_TYPE = G_FND_LOOKUP_PAYMENT_FREQ
         AND  l_system_date BETWEEN NVL(start_date_active,l_system_date)
         AND NVL(end_date_active,l_system_date);
         BEGIN
         	-- initialize return status
          x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
          -- data is required
          IF (p_ipyv_rec.ipf_code = OKC_API.G_MISS_CHAR) THEN
          	OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Payment Frequency');
          	-- notify caller of an error
          	x_return_status := OKC_API.G_RET_STS_ERROR;
          ELSE
          	-- enforce foreign key
          	OPEN  l_ipf_csr ;
          	FETCH l_ipf_csr INTO l_dummy_var ;
          	CLOSE l_ipf_csr ;
          	-- still set to default means data was not found
          	IF ( l_dummy_var = '?' ) THEN
          		OKC_API.set_message(g_app_name,
          				G_NO_PARENT_RECORD,
          		  	    	g_col_name_token,
          		  	    	'Payment Frequency',
          		  	    	g_child_table_token ,
          		  	    	'OKL_INS_POLICIES_V' ,
          		  	    	g_parent_table_token ,
          		  	    	'FND_LOOKUPS');
  		  	x_return_status := OKC_API.G_RET_STS_ERROR;
          	END IF;
          END IF;
        EXCEPTION
        	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                	-- notify caller of an UNEXPECTED error
                	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                -- verify that cursor was closed
  	            IF l_ipf_csr%ISOPEN THEN
  	      	      CLOSE l_ipf_csr;
  	            END IF;
     END   validate_ipf_code ;
     -- End validate_ipf_code
   	---------------------------------------------
        -- Validate_Attributes for: AGENT_SITE_ID --
  	---------------------------------------------
     PROCEDURE validate_agent_site_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_dummy_var		VARCHAR2(1) := '?' ;
        --foriegn check for agent site id
      	CURSOR  l_agnt_csr IS
      	SELECT 'x'
      	FROM OKL_INS_PARTYSITES_V
      	WHERE site_id = p_ipyv_rec.agent_site_id ;
      BEGIN
      	-- initialize return status
          x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
          IF ( p_ipyv_rec.agent_site_id = OKC_API.G_MISS_NUM) THEN
  			OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Agent Address');
  			-- notify caller of an error
  			x_return_status := OKC_API.G_RET_STS_ERROR;
         ELSE
 -- smoduga added as part of LLA calling create third party
          IF ( p_ipyv_rec.agent_site_id  IS NOT NULL) THEN
 --
          	-- enforce foreign key
  	        OPEN  l_agnt_csr ;
  		    FETCH l_agnt_csr INTO l_dummy_var ;
  		CLOSE l_agnt_csr ;
  		-- still set to default means data was not found
  		IF ( l_dummy_var = '?' ) THEN
  			OKC_API.set_message(g_app_name,
  						g_no_parent_record,
  						g_col_name_token,
  						'Agent Address',
  						g_child_table_token ,
  						'OKL_INS_POLICIES_V' ,
  						g_parent_table_token ,
  						'OKL_INS_PARTYSITES_V');
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
          END IF;
        END IF;
      EXCEPTION
      	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                	-- notify caller of an UNEXPECTED error
                	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                	-- verify that cursor was closed
  		  IF l_agnt_csr%ISOPEN THEN
  		 	CLOSE l_agnt_csr;
  		  END IF;
   END validate_agent_site_id ;
   ---------------------------------------------
   -- Validate_Attributes for: AGENCY_SITE_ID --
   ---------------------------------------------
      PROCEDURE validate_agency_site_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
        l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_dummy_var		VARCHAR2(1) := '?' ;
        --	"WARNING : Cannot implement until OKX View OKX_xxxxxx_V defined"
           CURSOR  l_agncy_csr IS
               SELECT 'x'
               FROM OKL_INS_PARTYSITES_V
               WHERE SITE_ID = p_ipyv_rec.agency_site_id
               AND PARTY_ID = p_ipyv_rec.isu_id;
        BEGIN
        	-- initialize return status
             x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
             -- data is required
             IF ( ( p_ipyv_rec.agency_site_id IS NULL)  OR  (p_ipyv_rec.agency_site_id = OKC_API.G_MISS_NUM)) THEN
             	OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Agency Address');
             	-- notify caller of an error
             	x_return_status := OKC_API.G_RET_STS_ERROR;
             ELSE
             	-- enforce foreign key
     		--	  "WARNING : Cannot implement until OKX View OKX_xxxxxx_V defined"
             		  OPEN   l_agncy_csr ;
             		     FETCH l_agncy_csr INTO l_dummy_var ;
             		  CLOSE l_agncy_csr ;
             	-- still set to default means data was not found
             	IF ( l_dummy_var = '?' ) THEN
             		OKC_API.set_message(g_app_name,
             				g_no_parent_record,
             				g_col_name_token,
             		  	    	'Agency Address',
             		  	    	g_child_table_token ,
             		  	    	'OKL_INS_POLICIES_V' ,
             		  	    	g_parent_table_token ,
             		  	    	'OKL_INS_PARTYSITES_V');
     			x_return_status := OKC_API.G_RET_STS_ERROR;
             	END IF;
             END IF;
         EXCEPTION
         	WHEN OTHERS THEN
             	-- store SQL error message on message stack for caller
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                   	-- notify caller of an UNEXPECTED error
                   	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                   	-- verify that cursor was closed
     		 IF l_agncy_csr%ISOPEN THEN
     			CLOSE l_agncy_csr;
     		 END IF;
     END   validate_agency_site_id ;
    -- End validate_agency_site_id
   ---------------------------------------------
   -- Validate_Attributes for: INT_ID --
   ---------------------------------------------
        PROCEDURE validate_int_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
         l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
         l_dummy_var		VARCHAR2(1) := '?' ;
         	CURSOR  l_int_csr IS
         	SELECT 'x' --Bug:3825159
         	FROM  HZ_PARTIES PRT
        	WHERE PRT.CATEGORY_CODE = 'INSURANCE_AGENT'
                AND PRT.party_id = p_ipyv_rec.int_id ;
         BEGIN
         	-- initialize return status
                x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
             IF ( p_ipyv_rec.int_id = OKC_API.G_MISS_NUM) THEN
          	OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Insurance Agent');
          	-- notify caller of an error
          	x_return_status := OKC_API.G_RET_STS_ERROR;
          ELSE
 -- smoduga added as part of LLA calling create third party
             IF ( p_ipyv_rec.int_id IS NOT NULL ) THEN
 --
             	-- enforce foreign key
     	        OPEN  l_int_csr ;
     		    FETCH l_int_csr INTO l_dummy_var ;
     		    CLOSE l_int_csr ;
     		-- still set to default means data was not found
     		IF ( l_dummy_var = '?' ) THEN
     			OKC_API.set_message(g_app_name,
     						g_no_parent_record,
     						g_col_name_token,
     						'Insurance Agent',
     						g_child_table_token ,
     						'OKL_INS_POLICIES_V' ,
     						g_parent_table_token ,
     						'HZ_PARTIES'); --Bug:3825159
     			x_return_status := OKC_API.G_RET_STS_ERROR;
     		END IF;
              END IF;
          END IF;
         EXCEPTION
         	WHEN OTHERS THEN
             	-- store SQL error message on message stack for caller
                     OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                   	-- notify caller of an UNEXPECTED error
                   	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                   	-- verify that cursor was closed
     		  IF l_int_csr%ISOPEN THEN
     		 	CLOSE l_int_csr;
     		  END IF;
      END validate_int_id ;
   -- End validate_int_id
   ---------------------------------------------
   -- Validate_Attributes for: ISU_ID --
   ---------------------------------------------
   PROCEDURE validate_isu_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
     l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var		VARCHAR2(1) := '?' ;
     --	"WARNING : Cannot implement until OKX View OKX_xxxxxx_V defined"
        CURSOR  l_isu_csr IS
            SELECT 'x' --Bug:3825159
            FROM HZ_PARTIES PRT
            WHERE PRT.CATEGORY_CODE = 'INSURER'
            AND   PRT.PARTY_ID = p_ipyv_rec.isu_id	;
        CURSOR  l_isu_csr1 IS
            SELECT 'x'
            FROM OKX_INS_PROVIDER_V
            WHERE PARTY_ID = p_ipyv_rec.isu_id	;
     BEGIN
     	-- initialize return status
          x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
          -- data is required
          IF ( ( p_ipyv_rec.isu_id IS NULL)  OR  (p_ipyv_rec.isu_id = OKC_API.G_MISS_NUM)) THEN
          	OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Insurance Provider');
          	-- notify caller of an error
          	x_return_status := OKC_API.G_RET_STS_ERROR;
          ELSE
          	-- enforce foreign key
  		--	  "WARNING : Cannot implement until OKX View OKX_xxxxxx_V defined"
          		  OPEN   l_isu_csr ;
          		     FETCH l_isu_csr INTO l_dummy_var ;
          		     IF  l_isu_csr%NOTFOUND THEN
          		       OPEN   l_isu_csr1 ;
			         FETCH l_isu_csr1 INTO l_dummy_var ;
          		       CLOSE l_isu_csr1 ;
          		     END IF;
          		  CLOSE l_isu_csr ;
          	-- still set to default means data was not found
          	IF ( l_dummy_var = '?' ) THEN
          		OKC_API.set_message(g_app_name,
          				g_no_parent_record,
          				g_col_name_token,
          		  	    	'Insurance Provider',
          		  	    	g_child_table_token ,
          		  	    	'OKL_INS_POLICIES_V' ,
          		  	    	g_parent_table_token ,
          		  	    	'HZ_PARTIES'); --Bug:3825159
  			x_return_status := OKC_API.G_RET_STS_ERROR;
          	END IF;
          END IF;
      EXCEPTION
      	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                	-- notify caller of an UNEXPECTED error
                	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                	-- verify that cursor was closed
  		 IF l_isu_csr%ISOPEN THEN
  			CLOSE l_isu_csr;
  		 END IF;
                	-- verify that cursor was closed
  		 IF l_isu_csr1%ISOPEN THEN
  			CLOSE l_isu_csr1;
  		 END IF;
  END   validate_isu_id ;
     -- End validate_isu_code
  ---------------------------------------------
  -- Validate_Attributes for: IPT_ID --
  ---------------------------------------------
  PROCEDURE validate_ipt_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
     l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var		VARCHAR2(1) := '?' ;
     CURSOR  l_ipt_csr IS
      SELECT 'x'
      FROM OKL_INS_PRODUCTS_V
      WHERE ID = p_ipyv_rec.ipt_id	;
      BEGIN
      	-- initialize return status
          x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
          -- data is required
          IF ( ( p_ipyv_rec.ipt_id IS NULL)  OR  (p_ipyv_rec.ipt_id = OKC_API.G_MISS_NUM)) THEN
          	OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Insurance Product');
            	-- notify caller of an error
            	x_return_status := OKC_API.G_RET_STS_ERROR;
          ELSE
          	-- enforce foreign key
            	OPEN   l_ipt_csr ;
            	FETCH l_ipt_csr INTO l_dummy_var ;
            	CLOSE l_ipt_csr ;
            	-- still set to default means data was not found
            	IF ( l_dummy_var = '?' ) THEN
            		OKC_API.set_message(g_app_name,
  						g_no_parent_record,
  						g_col_name_token,
  						'Insurance Product',
  						g_child_table_token ,
  						'OKL_INS_POLICIES_V' ,
  						g_parent_table_token ,
  						'OKL_INS_PRODUCTS_V');
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
  	END IF;
      EXCEPTION
      	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  -- notify caller of an UNEXPECTED error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  -- verify that cursor was closed
  		IF l_ipt_csr%ISOPEN THEN
  			CLOSE l_ipt_csr;
  		END IF;
    END   validate_ipt_id ;
    -- End validate_ipt_code
    ---------------------------------------------
    -- Validate_Attributes for: IPY_ID --
    ---------------------------------------------
    PROCEDURE validate_ipy_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_dummy_var		VARCHAR2(1) := '?' ;
      CURSOR  l_ipy_csr IS
        SELECT 'x'
        FROM OKL_INS_POLICIES_V
        WHERE id = p_ipyv_rec.ipy_id ;
        BEGIN
            -- initialize return status
            x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
            IF ( ( p_ipyv_rec.ipy_id IS NOT NULL)  OR  (p_ipyv_rec.ipy_id <> OKC_API.G_MISS_NUM)) THEN
            	-- enforce foreign key
    		OPEN   l_ipy_csr ;
    		FETCH l_ipy_csr INTO l_dummy_var ;
    		CLOSE l_ipy_csr ;
    		-- still set to default means data was not found
    		IF ( l_dummy_var = '?' ) THEN
    			OKC_API.set_message(g_app_name,
    						g_no_parent_record,
    						g_col_name_token,
    						'Policy Number',
    						g_child_table_token ,
    						'OKL_INS_POLICIES_V' ,
    						g_parent_table_token ,
    						'OKL_INS_POLICIES_V');
    			x_return_status := OKC_API.G_RET_STS_ERROR;
    		END IF;
            END IF;
        EXCEPTION
        	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  -- notify caller of an UNEXPECTED error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  -- verify that cursor was closed
  		IF l_ipy_csr%ISOPEN THEN
  			CLOSE l_ipy_csr;
  		END IF;
    END validate_ipy_id ;
    -- End validate_ipy_id
    ---------------------------------------------
    -- Validate_Attributes for: IPE_CODE --
    ---------------------------------------------
    PROCEDURE validate_ipe_code ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
     l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var		VARCHAR2(1) := '?' ;
     l_system_date         DATE  := SYSDATE   ;
     CURSOR  l_ipe_csr IS
      SELECT 'x'
      FROM FND_LOOKUPS
      WHERE LOOKUP_CODE = p_ipyv_rec.ipe_code
  	AND LOOKUP_TYPE = G_FND_LOOKUP_INS_POLICY_TYPE
  	AND l_system_date BETWEEN NVL(start_date_active,l_system_date)
  	AND NVL(end_date_active,l_system_date);
      BEGIN
      	-- initialize return status
          x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
         -- data is required
         IF ( ( p_ipyv_rec.ipe_code IS NULL)  OR  (p_ipyv_rec.ipe_code = OKC_API.G_MISS_CHAR)) THEN
         		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Policy Type');
                  -- notify caller of an error
                  x_return_status := OKC_API.G_RET_STS_ERROR;
         ELSE
         		-- enforce foreign key
          	OPEN   l_ipe_csr ;
                  FETCH l_ipe_csr INTO l_dummy_var ;
                  CLOSE l_ipe_csr ;
                  -- still set to default means data was not found
                  IF ( l_dummy_var = '?' ) THEN
                  	OKC_API.set_message(g_app_name,
                  				g_no_parent_record,
                  		 		g_col_name_token,
                  		  	    	'Policy Type',
                  		  	    	g_child_table_token ,
                  		  	    	'OKL_INS_POLICIES_V' ,
                  		  	    	g_parent_table_token ,
                  		  	    	'FND_LOOKUPS');
          		x_return_status := OKC_API.G_RET_STS_ERROR;
                  END IF;
          END IF;
       EXCEPTION
       	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  -- notify caller of an UNEXPECTED error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  -- verify that cursor was closed
  		IF l_ipe_csr%ISOPEN THEN
  			CLOSE l_ipe_csr;
  		END IF;
    END   validate_ipe_code ;
    -- End validate_ipe_code
    ---------------------------------------------
    -- Validate_Attributes for: CRX_CODE --
    ---------------------------------------------
    PROCEDURE validate_crx_code ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
    	l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          l_dummy_var		VARCHAR2(1) := '?' ;
      	l_system_date         DATE  := SYSDATE   ;
      	CURSOR  l_crx_csr IS
      	 SELECT 'x'
      	 FROM FND_LOOKUPS
      	 WHERE LOOKUP_CODE = p_ipyv_rec.crx_code
  	 AND  LOOKUP_TYPE = G_FND_LOOKUP_INS_CANCEL_REASON
  	 AND l_system_date BETWEEN NVL(start_date_active,l_system_date)
  	 AND NVL(end_date_active,l_system_date);
      BEGIN
      	-- initialize return status
      	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
      	IF ( ( p_ipyv_rec.crx_code IS NOT NULL)  OR  (p_ipyv_rec.crx_code <> OKC_API.G_MISS_CHAR)) THEN
      		-- enforce foreign key
      		OPEN   l_crx_csr ;
      		FETCH l_crx_csr INTO l_dummy_var ;
      		CLOSE l_crx_csr ;
      		-- still set to default means data was not found
      		IF ( l_dummy_var = '?' ) THEN
      			OKC_API.set_message(g_app_name,
      				g_no_parent_record,
      				g_col_name_token,
      				'Cancellation Reason',
      							g_child_table_token ,
      							'OKL_INS_POLICIES_V' ,
      							g_parent_table_token ,
      							'FND_LOOKUPS');
      			x_return_status := OKC_API.G_RET_STS_ERROR;
      		END IF;
             END IF;
        EXCEPTION
        	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  -- notify caller of an UNEXPECTED error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  -- verify that cursor was closed
  		IF l_crx_csr%ISOPEN THEN
  			CLOSE l_crx_csr;
  		END IF;
    END   validate_crx_code;
    -- End validate_crx_code
    ---------------------------------------------
    -- Validate_Attributes for: ISS_CODE --
    ---------------------------------------------
    PROCEDURE validate_iss_code ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var		VARCHAR2(1) := '?' ;
    l_system_date         DATE  := SYSDATE   ;
    CURSOR  l_iss_csr IS
     SELECT 'x'
     FROM FND_LOOKUPS
     WHERE LOOKUP_code = p_ipyv_rec.iss_code
  	AND LOOKUP_TYPE = G_FND_LOOKUP_INS_STATUS
          AND  l_system_date BETWEEN NVL(start_date_active,l_system_date)
  	AND NVL(end_date_active,l_system_date);
     BEGIN
     	-- initialize return status
          x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
          -- data is required
          IF ( ( p_ipyv_rec.iss_code IS NULL)  OR  (p_ipyv_rec.iss_code = OKC_API.G_MISS_CHAR)) THEN
          	OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Status');
                  -- notify caller of an error
                  x_return_status := OKC_API.G_RET_STS_ERROR;
          ELSE
          	-- enforce foreign key
                  OPEN   l_iss_csr ;
                  FETCH l_iss_csr INTO l_dummy_var ;
                  CLOSE l_iss_csr ;
                  -- still set to default means data was not found
                  IF ( l_dummy_var = '?' ) THEN
                  	OKC_API.set_message(g_app_name,
                  			  	g_no_parent_record,
                  		  	    	g_col_name_token,
                  		  	    	'Status',
                  		  	    	g_child_table_token ,
                  		  	    	'OKL_INS_POLICIES_V' ,
                  		  	    	g_parent_table_token ,
                  		  	    	'FND_LOOKUPS');
          		x_return_status := OKC_API.G_RET_STS_ERROR;
                  END IF;
           END IF;
       EXCEPTION
       	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  -- notify caller of an UNEXPECTED error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
                  -- verify that cursor was closed
  		IF l_iss_csr%ISOPEN THEN
  			CLOSE l_iss_csr;
  		END IF;
    END   validate_iss_code ;
    -- End validate_iss_code
    ---------------------------------------------
    -- Validate_Attributes for: KLE_ID --
    ---------------------------------------------
    PROCEDURE validate_kle_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_dummy_var		VARCHAR2(1) := '?' ;
      CURSOR  l_kle_csr IS
       SELECT 'x'
       FROM  OKL_K_LINES_V
       WHERE id = p_ipyv_rec.kle_id	;
       BEGIN
  	-- initialize return status
  	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
  	IF (p_ipyv_rec.kle_id = OKC_API.G_MISS_NUM) THEN
  	       OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',
  	       G_COL_NAME_TOKEN,'Contract Line ID');
  	        -- notify caller of an error
	       x_return_status := OKC_API.G_RET_STS_ERROR;
          ELSE
  		-- enforce foreign key
  		OPEN   l_kle_csr ;
  		FETCH l_kle_csr INTO l_dummy_var ;
  		CLOSE l_kle_csr ;
  		-- still set to default means data was not found
  		IF ( l_dummy_var = '?' ) THEN
  			OKC_API.set_message(g_app_name,
  						g_no_parent_record,
  						g_col_name_token,
  						'Contract Line ID',
  						g_child_table_token ,
  						'OKL_INS_POLICIES_V' ,
  						g_parent_table_token ,
  						'OKL_K_LINES_V');
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
  	END IF;
       EXCEPTION
  	WHEN OTHERS THEN
  		-- store SQL error message on message stack for caller
  		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
  		-- notify caller of an UNEXPECTED error
  		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  		-- verify that cursor was closed
  		IF l_kle_csr%ISOPEN THEN
  			CLOSE l_kle_csr;
  		END IF;
   END validate_kle_id ;
   -- End validate_kle_id
      ---------------------------------------------
      -- Validate_Attributes for: KHR_ID --
      ---------------------------------------------
      PROCEDURE validate_khr_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
        l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_dummy_var		VARCHAR2(1) := '?' ;
        CURSOR  l_khr_csr IS
         SELECT 'x'
         FROM  OKL_K_HEADERS_V
         WHERE id = p_ipyv_rec.khr_id	;
         BEGIN
    	-- initialize return status
    	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        IF ( ( p_ipyv_rec.khr_id IS NULL)  OR  (p_ipyv_rec.khr_id = OKC_API.G_MISS_NUM)) THEN
        		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Contract Id');
        		-- notify caller of an error
        		x_return_status := OKC_API.G_RET_STS_ERROR;
        ELSE
    	--IF ( ( p_ipyv_rec.khr_id IS NOT NULL)  OR  (p_ipyv_rec.khr_id <> OKC_API.G_MISS_NUM)) THEN
    		-- enforce foreign key
    		OPEN   l_khr_csr ;
    		FETCH l_khr_csr INTO l_dummy_var ;
    		CLOSE l_khr_csr ;
    		-- still set to default means data was not found
    		IF ( l_dummy_var = '?' ) THEN
    			OKC_API.set_message(g_app_name,
    						g_no_parent_record,
    						g_col_name_token,
    						'Contract Id',
    						g_child_table_token ,
    						'OKL_INS_POLICIES_V' ,
    						g_parent_table_token ,
    						'OKL_K_HEADERS_V');
    			x_return_status := OKC_API.G_RET_STS_ERROR;
    		END IF;
    	END IF;
         EXCEPTION
    	WHEN OTHERS THEN
    		-- store SQL error message on message stack for caller
    		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    		-- verify that cursor was closed
    		IF l_khr_csr%ISOPEN THEN
    			CLOSE l_khr_csr;
    		END IF;
     END validate_khr_id ;
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
      ---------------------------------------------
      -- Validate_Attributes for: LEASE_APPLICATION_ID --
      ---------------------------------------------
      PROCEDURE validate_lease_application_id ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
        l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_dummy_var		VARCHAR2(1) := '?' ;
        CURSOR  l_lease_application_csr IS
         SELECT 'x'
         FROM  OKL_LEASE_APPLICATIONS_V
         WHERE id = p_ipyv_rec.lease_application_id	;
         BEGIN
    	-- initialize return status
    	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        IF (p_ipyv_rec.lease_application_id = OKC_API.G_MISS_NUM) THEN
        		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'lease application Id');
        		-- notify caller of an error
        		x_return_status := OKC_API.G_RET_STS_ERROR;
        ELSE
    		-- enforce foreign key
    		OPEN   l_lease_application_csr ;
    		FETCH l_lease_application_csr INTO l_dummy_var ;
    		CLOSE l_lease_application_csr ;
    		-- still set to default means data was not found
    		IF ( l_dummy_var = '?' ) THEN
    			OKC_API.set_message(g_app_name,
    						g_no_parent_record,
    						g_col_name_token,
    						'Contract Id',
    						g_child_table_token ,
    						'OKL_INS_POLICIES_V' ,
    						g_parent_table_token ,
    						'OKL_LEASE_APPLICATIONS_V');
    			x_return_status := OKC_API.G_RET_STS_ERROR;
    		END IF;
    	END IF;
         EXCEPTION
    	WHEN OTHERS THEN
    		-- store SQL error message on message stack for caller
    		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
    		-- notify caller of an UNEXPECTED error
    		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    		-- verify that cursor was closed
    		IF l_lease_application_csr%ISOPEN THEN
    			CLOSE l_lease_application_csr;
    		END IF;
     END validate_lease_application_id ;
   -- End validate_lease_applications_id
   ---------------------------------------------
   -- Validate_Attributes for: IPY_TYPE --
   ---------------------------------------------
   PROCEDURE validate_ipy_type ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy_var		VARCHAR2(1) := '?' ;
    l_system_date         DATE  := SYSDATE   ;
    CURSOR  l_ipy_csr IS
     SELECT 'x'
     FROM FND_LOOKUPS
     WHERE LOOKUP_code = p_ipyv_rec.ipy_type
  	AND LOOKUP_TYPE = G_FND_LOOKUP_POLICY_TYPE;
    BEGIN
  	-- initialize return status
  	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
  	-- data is required
  	IF ( ( p_ipyv_rec.ipy_type IS NULL)  OR  (p_ipyv_rec.ipy_type = OKC_API.G_MISS_CHAR)) THEN
                 -- halt validation as it is a optional field
                  --RAISE G_EXCEPTION_STOP_VALIDATION;
  		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Policy Type');
  		-- notify caller of an error
  		x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
  	--ELSE
  		-- enforce foreign key
  		OPEN   l_ipy_csr ;
  		FETCH l_ipy_csr INTO l_dummy_var ;
  		CLOSE l_ipy_csr ;
  	-- still set to default means data was not found
  		IF ( l_dummy_var = '?' ) THEN
                  -- halt validation as it has no parent record
                  RAISE G_EXCEPTION_HALT_VALIDATION;
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
  	--END IF;
      EXCEPTION
        --WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is not optional
         --OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Policy Type');
        WHEN G_EXCEPTION_HALT_VALIDATION then
       -- We are here b'cause we have no parent record
       -- store SQL error message on message stack
             OKC_API.set_message(g_app_name,
  				 g_no_parent_record,
  				 g_col_name_token,
  				 'Policy Type',
  				 g_child_table_token ,
  				 'OKL_INS_POLICIES_V' ,
  				 g_parent_table_token ,
  				 'FND_LOOKUPS');
  	WHEN OTHERS THEN
  		-- store SQL error message on message stack for caller
  		OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
  		-- notify caller of an UNEXPECTED error
  		--x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  		-- verify that cursor was closed
  		IF l_ipy_csr%ISOPEN THEN
  			CLOSE l_ipy_csr;
  		END IF;
                -- notify caller of an error as UNEXPETED error
                x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END   validate_ipy_type ;
   -- End validate_ipy_type
    ---------------------------------------------
    -- Validate_Attributes for: POLICY_NUMBER --
    ---------------------------------------------
    PROCEDURE validate_policy_number ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
     l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     BEGIN
     	-- initialize return status
        	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
          -- data is required
        	IF ( ( p_ipyv_rec.policy_number IS NULL)  OR  (p_ipyv_rec.policy_number = OKC_API.G_MISS_CHAR)) THEN
        		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',
        		G_COL_NAME_TOKEN,'Policy Number');
        		-- notify caller of an error
        		x_return_status := OKC_API.G_RET_STS_ERROR;
        	END IF;
       EXCEPTION
          WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              	-- notify caller of an UNEXPECTED error
              	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END   validate_policy_number ;
    -- End validate_policy_number
    -- Start of Comments
        --
        -- Procedure Name : validate_endorsement
        -- Description    : It validates for null value for endorsement
        -- Business Rules :
        -- Parameter      :
        -- Version        : 1.0
        -- End of comments
        PROCEDURE validate_endorsement ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
         l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
         BEGIN
         	-- initialize return status
            	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
              -- data is required
            	IF ( ( p_ipyv_rec.endorsement IS NULL)  OR  (p_ipyv_rec.endorsement = OKC_API.G_MISS_CHAR)) THEN
            		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Endorsement');
            		-- notify caller of an error
            		x_return_status := OKC_API.G_RET_STS_ERROR;
            	END IF;
           EXCEPTION
              WHEN OTHERS THEN
              	-- store SQL error message on message stack for caller
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  	-- notify caller of an UNEXPECTED error
                  	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END   validate_endorsement ;
        -- End validate_endorsement
    ---------------------------------------------
    -- Validate_Attributes for: PREMIUM --
    ---------------------------------------------
  PROCEDURE validate_premium ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
   l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
         	-- initialize return status
            	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
              -- data is required
            	IF ( ( p_ipyv_rec.premium IS NULL)  OR  (p_ipyv_rec.premium = OKC_API.G_MISS_NUM)) THEN
            		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Premium');
            		-- notify caller of an error
            		x_return_status := OKC_API.G_RET_STS_ERROR;
            	END IF;
           EXCEPTION
              WHEN OTHERS THEN
              	-- store SQL error message on message stack for caller
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  	-- notify caller of an UNEXPECTED error
                  	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END   validate_premium ;
        -- End validate_premium
        PROCEDURE validate_name_of_insured ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
         l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
         BEGIN
         	-- initialize return status
            	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
              -- data is required
            	IF ( ( p_ipyv_rec.name_of_insured IS NULL)  OR  (p_ipyv_rec.name_of_insured = OKC_API.G_MISS_CHAR)) THEN
            		OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Name of Insured');
            		-- notify caller of an error
            		x_return_status := OKC_API.G_RET_STS_ERROR;
            	END IF;
           EXCEPTION
              WHEN OTHERS THEN
              	-- store SQL error message on message stack for caller
                      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
                  	-- notify caller of an UNEXPECTED error
                  	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END   validate_name_of_insured ;
        -- End validate_name_of_insured
  ---------------------------------------------
  -- Validate_Attributes for: QUOTE_YN --
  ---------------------------------------------
   PROCEDURE validate_quote_yn ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
   l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
    	-- initialize return status
        	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        --	x_return_status  := OKL_UTIL.check_domain_yn(p_ipyv_rec.quote_yn);
        	-- data is required
        	IF ( ( p_ipyv_rec.quote_yn IS NOT NULL)  OR  (p_ipyv_rec.quote_yn = OKC_API.G_MISS_CHAR)) THEN
  		IF UPPER(p_ipyv_rec.quote_yn) NOT IN ('Y','N') THEN
  			x_return_status:=OKC_API.G_RET_STS_ERROR;
  		     --set error message in message stack
  			OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
  					p_msg_name     =>  G_INVALID_VALUE,
  					p_token1       => G_COL_NAME_TOKEN,
  					p_token1_value => 'Quote Flag');
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
        	END IF;
     EXCEPTION
     	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              	-- notify caller of an UNEXPECTED error
              	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END   validate_quote_yn ;
    -- End validate_quote_yn
  ---------------------------------------------
  -- Validate_Attributes for: QUOTE_N --
  ---------------------------------------------
   PROCEDURE validate_quote_n ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
   l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
    	-- initialize return status
        	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        --	x_return_status  := OKL_UTIL.check_domain_yn(p_ipyv_rec.quote_yn);
        	-- data is required
        	IF (p_ipyv_rec.quote_yn = OKC_API.G_MISS_CHAR)THEN
  		IF UPPER(p_ipyv_rec.quote_yn) NOT IN ('NO') THEN
  			x_return_status:=OKC_API.G_RET_STS_ERROR;
  		     --set error message in message stack
  			OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
  					p_msg_name     =>  G_INVALID_VALUE,
  					p_token1       => G_COL_NAME_TOKEN,
  					p_token1_value => 'Quote Flag');
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
        	END IF;
     EXCEPTION
     	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              	-- notify caller of an UNEXPECTED error
              	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END   validate_quote_n ;
    -- End validate_quote_yn
  ---------------------------------------------
  -- Validate_Attributes for: ON_FILE_YN --
  ---------------------------------------------
   PROCEDURE validate_on_file_yn ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
   l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
    	-- initialize return status
        	x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        	--x_return_status  := OKL_UTIL.check_domain_yn(p_ipyv_rec.on_file_yn);
        	-- data is required
  		IF UPPER(p_ipyv_rec.private_label_yn) NOT IN ('Y','N') THEN
  			x_return_status:=OKC_API.G_RET_STS_ERROR;
  		     --set error message in message stack
  			OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
  					p_msg_name     =>  G_INVALID_VALUE,
  					p_token1       => G_COL_NAME_TOKEN,
  					p_token1_value => 'private_label_yn');
  			x_return_status := OKC_API.G_RET_STS_ERROR;
  		END IF;
     EXCEPTION
     	WHEN OTHERS THEN
          	-- store SQL error message on message stack for caller
                  OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              	-- notify caller of an UNEXPECTED error
              	x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END   validate_on_file_yn ;
    -- End validate_on_file_yn
	---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_covered_amount
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_covered_amount(p_ipyv_rec IN ipyv_rec_type,x_return_status OUT NOCOPY VARCHAR2 ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_ipyv_rec.covered_amount = Okc_Api.G_MISS_NUM OR
          p_ipyv_rec.covered_amount IS NULL
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => 'OKL_REQUIRED_VALUE',
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Covered Amount');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_ipyv_rec.covered_amount);
		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
		   	                                  p_msg_name           => 'OKL_POSITIVE_NUMBER',
		   	                                  p_token1             => G_COL_NAME_TOKEN,
		   	                                  p_token1_value       => 'Covered Amount'
		   	                                  );
			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_covered_amount;
  	---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_deductible
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_deductible(p_ipyv_rec IN ipyv_rec_type,x_return_status OUT NOCOPY VARCHAR2 ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
       --data is required
       IF p_ipyv_rec.deductible = Okc_Api.G_MISS_NUM
       THEN
         Okc_Api.set_message(p_app_name       => G_APP_NAME,
                             p_msg_name       => 'OKL_REQUIRED_VALUE',
                             p_token1         => G_COL_NAME_TOKEN,
                             p_token1_value   => 'Deductible');
         -- Notify caller of  an error
         x_return_status := Okc_Api.G_RET_STS_ERROR;
       ELSE
	x_return_status  := Okl_Util.check_domain_amount(p_ipyv_rec.deductible);
		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
	    	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
		   	                                  p_msg_name           => 'OKL_POSITIVE_NUMBER',
		   	                                  p_token1             => G_COL_NAME_TOKEN,
		   	                                  p_token1_value       => 'Deductible'
		   	                                  );
			ELSIF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	        		RAISE G_EXCEPTION_HALT_VALIDATION;
     	        END IF;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            -- store SQL error  message on message stack for caller
	    Okc_Api.set_message(p_app_name => G_APP_NAME,
				    p_msg_name => G_UNEXPECTED_ERROR,
				    p_token1 => G_SQLCODE_TOKEN,
				    p_token1_value => SQLCODE,
				    p_token2 => G_SQLERRM_TOKEN,
				    p_token2_value => SQLERRM
			);
            -- Notify the caller of an unexpected error
            x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_deductible;

 ---------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name	: validate_adjustment
-- Description		:
-- Business Rules	:
-- Parameters		:
-- Version		: 1.0
-- End of Comments
---------------------------------------------------------------------------
   PROCEDURE  validate_adjustment(p_ipyv_rec IN ipyv_rec_type,x_return_status OUT NOCOPY VARCHAR2 ) IS
     BEGIN
       --initialize the  return status
       x_return_status := Okc_Api.G_RET_STS_SUCCESS;
  END validate_adjustment;

  	-- Start of Comments
          --
          -- Procedure Name : validate_private_label_yn
          -- Description    : It validates for null value for private_label_yn
          -- Business Rules :
          -- Parameter      :
          -- Version        : 1.0
          -- End of comments
          PROCEDURE validate_private_label_yn ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
            l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
              BEGIN
        		-- initialize return status
        		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        		--x_return_status  := OKL_UTIL.check_domain_yn(p_ipyv_rec.private_label_yn );
        		-- data is required
        		IF ( ( p_ipyv_rec.private_label_yn IS NULL)  OR  (p_ipyv_rec.private_label_yn = OKC_API.G_MISS_CHAR)) THEN
        			OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,
        			'Private Label Flag');
        			-- notify caller of an error
        			x_return_status := OKC_API.G_RET_STS_ERROR;
        		ELSE
  			IF UPPER(p_ipyv_rec.private_label_yn) NOT IN ('Y','N') THEN
  				x_return_status:=OKC_API.G_RET_STS_ERROR;
  			     --set error message in message stack
  				OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
  						p_msg_name     =>  G_INVALID_VALUE,
  						p_token1       => G_COL_NAME_TOKEN,
  						p_token1_value => 'Private Label Flag');
  				x_return_status := OKC_API.G_RET_STS_ERROR;
  			END IF;
        		 END IF;
              EXCEPTION
              	   WHEN OTHERS THEN
                       -- store SQL error message on message stack for caller
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              		-- notify caller of an UNEXPECTED error
              		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           END   validate_private_label_yn ;
      -- End validate_private_label_yn
  -- Start of Comments
          --
          -- Procedure Name : validate_lessor_insured_yn
          -- Description    : It validates for null value for polcicy id
          -- Business Rules :
          -- Parameter      :
          -- Version        : 1.0
          -- End of comments
          PROCEDURE validate_lessor_insured_yn ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
            l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
              BEGIN
        		-- initialize return status
        		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        		-- data is required
        		IF ( p_ipyv_rec.lessor_insured_yn = OKC_API.G_MISS_CHAR) THEN
        			OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,
        			'Lessor Insured Flag');
        			-- notify caller of an error
        			x_return_status := OKC_API.G_RET_STS_ERROR;
        		ELSE
        			IF UPPER(p_ipyv_rec.lessor_insured_yn) NOT IN ('Y','N') THEN
  				x_return_status:=OKC_API.G_RET_STS_ERROR;
  			     --set error message in message stack
  				OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
  						p_msg_name     =>  G_INVALID_VALUE,
  						p_token1       => G_COL_NAME_TOKEN,
  						p_token1_value => 'Lessor Insured Flag');
  				x_return_status := OKC_API.G_RET_STS_ERROR;
  			        END IF;
        		END IF;
              EXCEPTION
              	   WHEN OTHERS THEN
                       -- store SQL error message on message stack for caller
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              		-- notify caller of an UNEXPECTED error
              		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           END   validate_lessor_insured_yn ;
      -- End validate_lessor_insured_yn
  	-- Start of Comments
          --
          -- Procedure Name : validate_lessor_payee_yn
          -- Description    : It validates for null value for lessor_payee_yn
          -- Business Rules :
          -- Parameter      :
          -- Version        : 1.0
          -- End of comments
          PROCEDURE validate_lessor_payee_yn ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
            l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
              BEGIN
        		-- initialize return status
        		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        		-- data is required
        		IF ( p_ipyv_rec.lessor_payee_yn = OKC_API.G_MISS_CHAR) THEN
        			OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,
        			'Lessor Payee Flag');
        			-- notify caller of an error
        			x_return_status := OKC_API.G_RET_STS_ERROR;
        		ELSE
  			IF UPPER(p_ipyv_rec.lessor_payee_yn) NOT IN ('Y','N') THEN
  				x_return_status:=OKC_API.G_RET_STS_ERROR;
  			     --set error message in message stack
  				OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
  						p_msg_name     =>  G_INVALID_VALUE,
  						p_token1       => G_COL_NAME_TOKEN,
  						p_token1_value => 'Lessor Payee Flag');
  				x_return_status := OKC_API.G_RET_STS_ERROR;
  			END IF;
        		END IF;
              EXCEPTION
              	   WHEN OTHERS THEN
                       -- store SQL error message on message stack for caller
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              		-- notify caller of an UNEXPECTED error
              		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           END   validate_lessor_payee_yn ;
      -- End validate_lessor_payee_yn
  	-- Start of Comments
          --
          -- Procedure Name : validate_agent_yn
          -- Description    : It validates for null value for agent_yn
          -- Business Rules :
          -- Parameter      :
          -- Version        : 1.0
          -- End of comments
          PROCEDURE validate_agent_yn ( p_ipyv_rec IN  ipyv_rec_type, x_return_status OUT NOCOPY VARCHAR2) IS
            l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
              BEGIN
        		-- initialize return status
        		x_return_status	 := OKC_API.G_RET_STS_SUCCESS;
        		--x_return_status  := OKL_UTIL.check_domain_yn(p_ipyv_rec.agent_yn );
        		-- data is required
        		IF ( p_ipyv_rec.agent_yn = OKC_API.G_MISS_CHAR) THEN
        			OKC_API.set_message(G_APP_NAME, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,
        			'Agent Flag');
        			-- notify caller of an error
        			x_return_status := OKC_API.G_RET_STS_ERROR;
        		ELSE
        			IF UPPER(p_ipyv_rec.agent_yn) NOT IN('Y','N') THEN
  				x_return_status:=OKC_API.G_RET_STS_ERROR;
  			     --set error message in message stack
  			    	OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
  			                        p_msg_name     =>  G_INVALID_VALUE,
  			                        p_token1       => G_COL_NAME_TOKEN,
  			                        p_token1_value => 'Agent Flag');
  				x_return_status := OKC_API.G_RET_STS_ERROR;
    			END IF;
        		END IF;
              EXCEPTION
              	   WHEN OTHERS THEN
                       -- store SQL error message on message stack for caller
                       OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE, G_SQLERRM_TOKEN, SQLERRM);
              		-- notify caller of an UNEXPECTED error
              		x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           END   validate_agent_yn ;
      -- End validate_agent_yn
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_date_from
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_date_from(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
       l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         --data is required
         IF (p_ipyv_rec.date_from = OKC_API.G_MISS_DATE) OR (p_ipyv_rec.date_from IS NULL)
         THEN
         	  OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Date Effective From');
           --Notify caller of  an error
   	 l_return_status := Okc_Api.G_RET_STS_ERROR;
          END IF;
  	 x_return_status := l_return_status;
         EXCEPTION
            WHEN OTHERS THEN
              --store SQL error  message on message stack for caller
              Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
              --Notify the caller of an unexpected error
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_date_from;
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_date_to
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_date_to(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
       l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         --data is required
         IF (p_ipyv_rec.date_to = OKC_API.G_MISS_DATE) OR (p_ipyv_rec.date_to IS NULL)
         THEN
         	  OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Date Effective To');
           --Notify caller of  an error
   	 l_return_status := Okc_Api.G_RET_STS_ERROR;
          END IF;
  	 x_return_status := l_return_status;
         EXCEPTION
            WHEN OTHERS THEN
              --store SQL error  message on message stack for caller
              Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
              --Notify the caller of an unexpected error
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_date_to;
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_date_proof_required
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_date_proof_required(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
       l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         --data is required
         IF (p_ipyv_rec.date_proof_required = OKC_API.G_MISS_DATE) THEN
         	  OKC_API.set_message(G_APP_NAME,'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,
         	  'Date Proof Required');
           --Notify caller of  an error
   	 l_return_status := Okc_Api.G_RET_STS_ERROR;
          END IF;
  	 x_return_status := l_return_status;
         EXCEPTION
            WHEN OTHERS THEN
              --store SQL error  message on message stack for caller
              Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
              --Notify the caller of an unexpected error
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_date_proof_required;
	---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name	: validate_date_proof_provided
  -- Description		:
  -- Business Rules	:
  -- Parameters		:
  -- Version		: 1.0
  -- End of Comments
  ---------------------------------------------------------------------------
     PROCEDURE  validate_date_proof_provided(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
       l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
       BEGIN
         --data is required
         IF p_ipyv_rec.date_proof_provided = OKC_API.G_MISS_DATE
         THEN
         	  OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Proof Provided Date');
           --Notify caller of  an error
   	 l_return_status := Okc_Api.G_RET_STS_ERROR;
          END IF;
  	 x_return_status := l_return_status;
         EXCEPTION
            WHEN OTHERS THEN
              --store SQL error  message on message stack for caller
              Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
              --Notify the caller of an unexpected error
              x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_date_proof_provided;
      ---------------------------------------------------------------------------
      -- Start of comments
      --
      -- Procedure Name	: validate_created_by
      -- Description		:
      -- Business Rules	:
      -- Parameters		:
      -- Version		: 1.0
      -- End of Comments
      ---------------------------------------------------------------------------
         PROCEDURE  validate_created_by(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
           l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
           BEGIN
             --data is required
             IF p_ipyv_rec.created_by = OKC_API.G_MISS_NUM OR  p_ipyv_rec.created_by IS NULL
             THEN
                --OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
               OKC_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_REQUIRED_VALUE,
                                   p_token1       => G_COL_NAME_TOKEN,
                                   p_token1_value => 'created_by');
               --Notify caller of  an error
      	 l_return_status := Okc_Api.G_RET_STS_ERROR;
              END IF;
      	 x_return_status := l_return_status;
             EXCEPTION
                WHEN OTHERS THEN
                  --store SQL error  message on message stack for caller
                  Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                  --Notify the caller of an unexpected error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END validate_created_by;
      ---------------------------------------------------------------------------
      -- Start of comments
      --
      -- Procedure Name	: validate_creation_date
      -- Description		:
      -- Business Rules	:
      -- Parameters		:
      -- Version		: 1.0
      -- End of Comments
      ---------------------------------------------------------------------------
         PROCEDURE  validate_creation_date(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
           l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
           BEGIN
             --data is required
             IF p_ipyv_rec.creation_date = OKC_API.G_MISS_DATE OR p_ipyv_rec.creation_date IS NULL
             THEN
             	  OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
               --Notify caller of  an error
       	 l_return_status := Okc_Api.G_RET_STS_ERROR;
              END IF;
      	 x_return_status := l_return_status;
             EXCEPTION
                WHEN OTHERS THEN
                  --store SQL error  message on message stack for caller
                  Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                  --Notify the caller of an unexpected error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END validate_creation_date;
      ---------------------------------------------------------------------------
      -- Start of comments
      --
      -- Procedure Name	: validate_ipt_last_updated_by
      -- Description		:
      -- Business Rules	:
      -- Parameters		:
      -- Version		: 1.0
      -- End of Comments
      ---------------------------------------------------------------------------
         PROCEDURE  validate_last_updated_by(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
           l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
          BEGIN
             --data is required
             IF p_ipyv_rec.last_updated_by = OKC_API.G_MISS_NUM OR p_ipyv_rec.last_updated_by IS NULL
             THEN
               OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_updated_by');
               --Notify caller of  an error
                l_return_status := Okc_Api.G_RET_STS_ERROR;
      	END IF;
      	 x_return_status := l_return_status;
            EXCEPTION
                WHEN OTHERS THEN
                  --store SQL error  message on message stack for caller
                  Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                  --Notify the caller of an unexpected error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        END validate_last_updated_by;
      ---------------------------------------------------------------------------
      -- Start of comments
      --
      -- Procedure Name	: validate_ipt_last_update_date
      -- Description		:
      -- Business Rules	:
      -- Parameters		:
      -- Version		: 1.0
      -- End of Comments
      ---------------------------------------------------------------------------
         PROCEDURE  validate_last_update_date(x_return_status OUT NOCOPY VARCHAR2,p_ipyv_rec IN ipyv_rec_type ) IS
           l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
           BEGIN
             --data is required
             IF p_ipyv_rec.last_update_date = OKC_API.G_MISS_DATE OR p_ipyv_rec.last_update_date IS NULL
             THEN
               OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
               --Notify caller of  an error
                l_return_status := Okc_Api.G_RET_STS_ERROR;
      	END IF;
      	 x_return_status := l_return_status;
            EXCEPTION
                WHEN OTHERS THEN
                  --store SQL error  message on message stack for caller
                  Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
                  --Notify the caller of an unexpected error
                  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_last_update_date;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_INS_POLICIES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ipyv_rec                     IN ipyv_rec_type
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
     		Validate_id(p_ipyv_rec, l_return_status);
     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- legal_entity_id
    -- ***
     		Validate_legal_entity_id(p_ipyv_rec, l_return_status);
     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- ipy_type
    -- ***
     		VALIDATE_ipy_type(p_ipyv_rec, l_return_status);
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
		     	 x_return_status := l_return_status;
		     		    RAISE G_EXCEPTION_HALT_VALIDATION;
		     ELSE
		     	  x_return_status := l_return_status;   -- record that there was an error
		     END IF;
     		END IF;
    -- ***
    -- sfwt_flag
    -- ***
     		VALIDATE_sfwt_flag(p_ipyv_rec, l_return_status);
     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- object_version_number
    -- ***
     		VALIDATE_object_version_number(p_ipyv_rec, l_return_status);
     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- created_by
    -- ***
		validate_created_by(x_return_status => l_return_status,
		                                p_ipyv_rec      => p_ipyv_rec);
		-- store the highest degree of error
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		       IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		          x_return_status :=l_return_status;
		          RAISE G_EXCEPTION_HALT_VALIDATION;
		       ELSE
		          x_return_status := l_return_status; -- Record that there was an error
		       END IF;
		   END IF;
    -- ***
    -- creation_date
    -- ***
		validate_creation_date(x_return_status => l_return_status,
		                       p_ipyv_rec      => p_ipyv_rec);
		-- store the highest degree of error
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		          IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		             x_return_status :=l_return_status;
		             RAISE G_EXCEPTION_HALT_VALIDATION;
		          ELSE
		            x_return_status := l_return_status; -- Record that there was an error
		          END IF;
		        END IF;
    -- ***
    -- last_updated_by
    -- ***
		        validate_last_updated_by(x_return_status => l_return_status,
		                                     p_ipyv_rec      => p_ipyv_rec);
		        -- store the highest degree of error
		        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		          IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		             x_return_status :=l_return_status;
		             RAISE G_EXCEPTION_HALT_VALIDATION;
		          ELSE
		            x_return_status := l_return_status; -- Record that there was an error
		          END IF;
		        END IF;
    -- ***
    -- last_update_date
    -- ***
		        validate_last_update_date(x_return_status => l_return_status,
		                                      p_ipyv_rec      => p_ipyv_rec);
		        -- store the highest degree of error
		        IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		          IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		             x_return_status :=l_return_status;
		             RAISE G_EXCEPTION_HALT_VALIDATION;
		          ELSE
		            x_return_status := l_return_status; -- Record that there was an error
		          END IF;
        	        END IF;
    -- ***
    -- date_from
    -- ***
			 validate_date_from(x_return_status => l_return_status,
			                    p_ipyv_rec      => p_ipyv_rec);
			-- store the highest degree of error
			  IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			      IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
			               x_return_status :=l_return_status;
			               RAISE G_EXCEPTION_HALT_VALIDATION;
			          	   ELSE
			               x_return_status := l_return_status; -- Record that there was an error
			          	   END IF;
			        	END IF;
    -- ***
    -- date_to
    -- ***
			validate_date_to(x_return_status => l_return_status,
			                 p_ipyv_rec      => p_ipyv_rec);
			-- store the highest degree of error
			IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			      IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
			         x_return_status :=l_return_status;
			      	 RAISE G_EXCEPTION_HALT_VALIDATION;
			      ELSE
			         x_return_status := l_return_status; -- Record that there was an error
			      END IF;
        		END IF;
    -- ***
    -- isu_id
    -- ***
        		VALIDATE_isu_id(p_ipyv_rec, l_return_status);
			     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
			     		    x_return_status := l_return_status;
			     		    RAISE G_EXCEPTION_HALT_VALIDATION;
			     		  ELSE
			     		    x_return_status := l_return_status;   -- record that there was an error
			     		  END IF;
     			END IF;
    -- ***
    -- lessor_insured_yn
    -- ***
        validate_lessor_insured_yn(p_ipyv_rec , l_return_status );
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- lessor_payee_yn
    -- ***
        validate_lessor_payee_yn(p_ipyv_rec , l_return_status );
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    ----------------------------------------- ***---------------------------------
    ------------------ Additional validations for Third Party Policy -------------
    ----------------------------------------- *** --------------------------------
     	   IF(p_ipyv_rec.IPY_TYPE = 'THIRD_PARTY_POLICY') THEN
    -- ***
    -- agency_site_id
    -- ***
     		VALIDATE_agency_site_id(p_ipyv_rec, l_return_status);
				    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
				     	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
				     		x_return_status := l_return_status;
				     		RAISE G_EXCEPTION_HALT_VALIDATION;
				     	ELSE
				     		x_return_status := l_return_status;   -- record that there was an error
				     	END IF;
     		END IF;
    -- ***
    -- date_proof_required
    -- ***
		validate_date_proof_required(x_return_status => l_return_status,
		                             p_ipyv_rec      => p_ipyv_rec);
		-- store the highest degree of error
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		       IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		            x_return_status :=l_return_status;
		            RAISE G_EXCEPTION_HALT_VALIDATION;
		        ELSE
		          x_return_status := l_return_status; -- Record that there was an error
		        END IF;
		    END IF;
    -- ***
    -- date_proof_provided
    -- ***
		validate_date_proof_provided(x_return_status => l_return_status,
		                             p_ipyv_rec      => p_ipyv_rec);
		-- store the highest degree of error
		   IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		        IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		             x_return_status :=l_return_status;
		             RAISE G_EXCEPTION_HALT_VALIDATION;
		        ELSE
		             x_return_status := l_return_status; -- Record that there was an error
		        END IF;
       		   END IF;
    -- ***
    -- covered_amount
    -- ***
     		VALIDATE_covered_amount(p_ipyv_rec, l_return_status);
		     IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		     	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
		     		x_return_status := l_return_status;
		     		RAISE G_EXCEPTION_HALT_VALIDATION;
		     	ELSE
		     		 x_return_status := l_return_status;   -- record that there was an error
		     	END IF;
		      END IF;
    -- ***
    -- policy_number
    -- ***
		VALIDATE_policy_number(p_ipyv_rec, l_return_status);
     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- quote_n
    -- ***
        validate_quote_n(p_ipyv_rec , l_return_status );
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
 -- smoduga added as part of LLA calling create third party
    -- ***
    -- int_id
    -- ***
     		VALIDATE_int_id(p_ipyv_rec, l_return_status);
     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- agent_site_id
    -- ***
     		VALIDATE_agent_site_id(p_ipyv_rec, l_return_status);
		    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
		     	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
		     		x_return_status := l_return_status;
		     		RAISE G_EXCEPTION_HALT_VALIDATION;
		     	ELSE
		     		x_return_status := l_return_status;   -- record that there was an error
		     	END IF;
     		END IF;
    -- ***
    -- on_file_yn
    -- ***
        validate_on_file_yn(p_ipyv_rec , l_return_status );
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
    IF ( ( p_ipyv_rec.khr_id IS NOT NULL)  OR  (p_ipyv_rec.khr_id <> OKC_API.G_MISS_NUM))THEN
    -- ***
    -- khr_id
    -- ***
			validate_khr_id(x_return_status => l_return_status,
			                 p_ipyv_rec      => p_ipyv_rec);
			-- store the highest degree of error
			IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			      IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
			         x_return_status :=l_return_status;
			      	 RAISE G_EXCEPTION_HALT_VALIDATION;
			      ELSE
			         x_return_status := l_return_status; -- Record that there was an error
			      END IF;
            END IF;
     ELSIF ( ((p_ipyv_rec.lease_application_id is not null)OR (p_ipyv_rec.lease_application_id <> OKC_API.G_MISS_NUM ))
              and ((p_ipyv_rec.khr_id is null)OR (p_ipyv_rec.khr_id = OKC_API.G_MISS_NUM))) then
    -- ***
    -- lease_application_id
    -- ***
        validate_lease_application_id(p_ipyv_rec , l_return_status );
            IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
     END IF;
    End if;
 ----------------------------------------- *** ------------------------------------------------
 --------------------------------- End of THIRD PARTY validation ------------------------------
 ----------------------------------------- *** ------------------------------------------------

         IF(p_ipyv_rec.ipy_type <> 'THIRD_PARTY_POLICY') THEN
    -- ***
    -- ipt_id
    -- ***
	       VALIDATE_ipt_id(p_ipyv_rec, l_return_status);
	      		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	      		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
	      		    x_return_status := l_return_status;
	      		    RAISE G_EXCEPTION_HALT_VALIDATION;
	      		  ELSE
	      		    x_return_status := l_return_status;   -- record that there was an error
	      		  END IF;
     		END IF;
    -- ***
    -- premium
    -- ***
	       VALIDATE_premium(p_ipyv_rec, l_return_status);
	      		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	      		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
	      		    x_return_status := l_return_status;
	      		    RAISE G_EXCEPTION_HALT_VALIDATION;
	      		  ELSE
	      		    x_return_status := l_return_status;   -- record that there was an error
	      		  END IF;
     		END IF;
    -- ***
    -- adjustment
    -- ***
	       VALIDATE_adjustment(p_ipyv_rec, l_return_status);
	      		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
	      		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
	      		    x_return_status := l_return_status;
	      		    RAISE G_EXCEPTION_HALT_VALIDATION;
	      		  ELSE
	      		    x_return_status := l_return_status;   -- record that there was an error
	      		  END IF;
     		END IF;
    -- ***
    -- ipf_code
    -- ***
		VALIDATE_ipf_code(p_ipyv_rec, l_return_status);
			IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
				IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
				 x_return_status := l_return_status;
				 RAISE G_EXCEPTION_HALT_VALIDATION;
				ELSE
				 x_return_status := l_return_status;   -- record that there was an error
				END IF;
		     	END IF;
    -- ***
    -- iss_code
    -- ***
     		VALIDATE_iss_code(p_ipyv_rec, l_return_status);
     		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
     		  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
     		    x_return_status := l_return_status;
     		    RAISE G_EXCEPTION_HALT_VALIDATION;
     		  ELSE
     		    x_return_status := l_return_status;   -- record that there was an error
     		  END IF;
     		END IF;
    -- ***
    -- khr_id
    -- ***
			validate_khr_id(x_return_status => l_return_status,
			                 p_ipyv_rec      => p_ipyv_rec);
			-- store the highest degree of error
			IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			      IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
			         x_return_status :=l_return_status;
			      	 RAISE G_EXCEPTION_HALT_VALIDATION;
			      ELSE
			         x_return_status := l_return_status; -- Record that there was an error
			      END IF;
        		END IF;
    -- ***
    -- territory_code
    -- ***
     		VALIDATE_territory_code(p_ipyv_rec , l_return_status);
		   -- store the highest degree of error
		 IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
			IF(l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
			 x_return_status :=l_return_status;
			 RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
			 x_return_status := l_return_status; -- Record that there was an error
			END IF;
        	 END IF;
            END IF;
    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
 ---------------------------------------------------------------------------
 -- PROCEDURE Validate_contract_header
 ---------------------------------------------------------------------------
    PROCEDURE validate_contract_header(
      p_ipyv_rec          IN ipyv_rec_type,
      x_return_status 	OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
      l_dummy_var VARCHAR2(1) := '?';
  CURSOR l_ipyv_csr IS
  SELECT 'x'
  FROM   okl_ins_policies_v
  WHERE  khr_id = p_ipyv_rec.khr_id
        AND ID <> p_ipyv_rec.ID
        AND IPY_TYPE ='THIRD_PARTY_POLICY';
    BEGIN
  	OPEN l_ipyv_csr;
  	FETCH l_ipyv_csr INTO l_dummy_var;
  	CLOSE l_ipyv_csr;
  -- if l_dummy_var is still set to default, data was not found
     IF (l_dummy_var = 'x') THEN
        OKC_API.set_message(p_app_name 	    => G_APP_NAME,
	  	            p_msg_name      => 'OKL_UNIQUE'
  			    );
        l_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;
      x_return_status := l_return_status;
    EXCEPTION
       WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_contract_header;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate Record for:OKL_INS_POLICIES_V --
  --------------------------------------------
        ------------------------------------
        -- FUNCTION validate_foreign_keys --
        ------------------------------------
        FUNCTION validate_foreign_keys (
          p_ipyv_rec IN ipyv_rec_type,
          p_db_ipyv_rec IN ipyv_rec_type
        ) RETURN VARCHAR2 IS
          --item_not_found_error           EXCEPTION;
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
        null;
          --l_return_status := validate_foreign_keys(p_ipyv_rec, p_db_ipyv_rec);
          RETURN (l_return_status);
    END Validate_foreign_keys;
         FUNCTION Validate_Record (
        p_ipyv_rec IN ipyv_rec_type,
        p_db_ipyv_rec IN ipyv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        ------------------------------------
        -- FUNCTION validate_foreign_keys --
        ------------------------------------
      BEGIN
         l_return_status := validate_foreign_keys(p_ipyv_rec, p_db_ipyv_rec);
         RETURN (l_return_status);
      END Validate_Record;
    FUNCTION Validate_Record (
      p_ipyv_rec IN ipyv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_db_ipyv_rec                  ipyv_rec_type := get_rec(p_ipyv_rec);
    BEGIN
         --Validate Duplicate records
         validate_thirdparty_duplicates(p_ipyv_rec,l_return_status);
            IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
              OKC_API.set_message(p_app_name 	    => G_APP_NAME,
  	                         p_msg_name           => 'OKL_UNIQUE'
  				);
               IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	         x_return_status :=l_return_status;
	         RAISE G_EXCEPTION_HALT_VALIDATION;
	       ELSE
	         	x_return_status := l_return_status;   -- record that there was an error
  	       END IF;
            END IF;
	   --Validate whether start date is less than the end date
         IF (l_return_status = Okc_Api.G_RET_STS_SUCCESS) THEN
               l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date => p_ipyv_rec.date_from
                                                                  ,p_to_date => p_ipyv_rec.date_to );
            IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                Okc_Api.set_message(
                                    p_app_name     => g_app_name,
			                        p_msg_name     => 'OKL_GREATER_THAN',
			                        p_token1       => 'COL_NAME1',
			                        p_token1_value => 'End Date',
			                        p_token2       => 'COL_NAME2',
			                        p_token2_value => 'Start Date'
			                        );
            IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status :=l_return_status;
            RAISE G_EXCEPTION_HALT_VALIDATION;
            ELSE
            x_return_status := l_return_status;   -- record that there was an error
            END IF;
            END IF;
         END IF;
      RETURN (l_return_status);
    END Validate_Record;
    ---------------------------------------------------------------------------
    -- PROCEDURE Migrate
    ---------------------------------------------------------------------------
    PROCEDURE migrate (
      p_from IN ipyv_rec_type,
      p_to   IN OUT NOCOPY ipy_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.ipy_type := p_from.ipy_type;
      p_to.name_of_insured := p_from.name_of_insured;
      p_to.policy_number := p_from.policy_number;
      p_to.insurance_factor := p_from.insurance_factor;
      p_to.factor_code := p_from.factor_code;
      p_to.calculated_premium := p_from.calculated_premium;
      p_to.premium := p_from.premium;
      p_to.covered_amount := p_from.covered_amount;
      p_to.deductible := p_from.deductible;
      p_to.adjustment := p_from.adjustment;
      p_to.payment_frequency := p_from.payment_frequency;
      p_to.crx_code := p_from.crx_code;
      p_to.ipf_code := p_from.ipf_code;
      p_to.iss_code := p_from.iss_code;
      p_to.ipe_code := p_from.ipe_code;
      p_to.date_to := p_from.date_to;
      p_to.date_from := p_from.date_from;
      p_to.date_quoted := p_from.date_quoted;
      p_to.date_proof_provided := p_from.date_proof_provided;
      p_to.date_proof_required := p_from.date_proof_required;
      p_to.cancellation_date := p_from.cancellation_date;
      p_to.date_quote_expiry := p_from.date_quote_expiry;
      p_to.activation_date := p_from.activation_date;
      p_to.quote_yn := p_from.quote_yn;
      p_to.on_file_yn := p_from.on_file_yn;
      p_to.private_label_yn := p_from.private_label_yn;
      p_to.agent_yn := p_from.agent_yn;
      p_to.lessor_insured_yn := p_from.lessor_insured_yn;
      p_to.lessor_payee_yn := p_from.lessor_payee_yn;
      p_to.khr_id := p_from.khr_id;
      p_to.kle_id := p_from.kle_id;
      p_to.ipt_id := p_from.ipt_id;
      p_to.ipy_id := p_from.ipy_id;
      p_to.int_id := p_from.int_id;
      p_to.isu_id := p_from.isu_id;
      p_to.factor_value := p_from.factor_value;
      p_to.agency_number := p_from.agency_number;
      p_to.agency_site_id := p_from.agency_site_id;
      p_to.sales_rep_id := p_from.sales_rep_id;
      p_to.agent_site_id := p_from.agent_site_id;
      p_to.adjusted_by_id := p_from.adjusted_by_id;
      p_to.territory_code := p_from.territory_code;
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
      p_to.program_id := p_from.program_id;
      p_to.org_id := p_from.org_id;
      p_to.program_update_date := p_from.program_update_date;
      p_to.program_application_id := p_from.program_application_id;
      p_to.request_id := p_from.request_id;
      p_to.object_version_number := p_from.object_version_number;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
      p_to.lease_application_id := p_from.lease_application_id;
      p_to.legal_entity_id := p_from.legal_entity_id;
    END migrate;
    PROCEDURE migrate (
      p_from IN ipy_rec_type,
      p_to   IN OUT NOCOPY ipyv_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.ipy_type := p_from.ipy_type;
      p_to.name_of_insured := p_from.name_of_insured;
      p_to.policy_number := p_from.policy_number;
      p_to.calculated_premium := p_from.calculated_premium;
      p_to.premium := p_from.premium;
      p_to.covered_amount := p_from.covered_amount;
      p_to.deductible := p_from.deductible;
      p_to.adjustment := p_from.adjustment;
      p_to.payment_frequency := p_from.payment_frequency;
      p_to.crx_code := p_from.crx_code;
      p_to.ipf_code := p_from.ipf_code;
      p_to.iss_code := p_from.iss_code;
      p_to.ipe_code := p_from.ipe_code;
      p_to.date_to := p_from.date_to;
      p_to.date_from := p_from.date_from;
      p_to.date_quoted := p_from.date_quoted;
      p_to.date_proof_provided := p_from.date_proof_provided;
      p_to.date_proof_required := p_from.date_proof_required;
      p_to.cancellation_date := p_from.cancellation_date;
      p_to.date_quote_expiry := p_from.date_quote_expiry;
      p_to.activation_date := p_from.activation_date;
      p_to.quote_yn := p_from.quote_yn;
      p_to.on_file_yn := p_from.on_file_yn;
      p_to.private_label_yn := p_from.private_label_yn;
      p_to.agent_yn := p_from.agent_yn;
      p_to.lessor_insured_yn := p_from.lessor_insured_yn;
      p_to.lessor_payee_yn := p_from.lessor_payee_yn;
      p_to.khr_id := p_from.khr_id;
      p_to.kle_id := p_from.kle_id;
      p_to.ipt_id := p_from.ipt_id;
      p_to.ipy_id := p_from.ipy_id;
      p_to.int_id := p_from.int_id;
      p_to.isu_id := p_from.isu_id;
      p_to.insurance_factor := p_from.insurance_factor;
      p_to.factor_code := p_from.factor_code;
      p_to.factor_value := p_from.factor_value;
      p_to.agency_number := p_from.agency_number;
      p_to.agency_site_id := p_from.agency_site_id;
      p_to.sales_rep_id := p_from.sales_rep_id;
      p_to.agent_site_id := p_from.agent_site_id;
      p_to.adjusted_by_id := p_from.adjusted_by_id;
      p_to.territory_code := p_from.territory_code;
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
      p_to.program_id := p_from.program_id;
      p_to.org_id := p_from.org_id;
      p_to.program_update_date := p_from.program_update_date;
      p_to.program_application_id := p_from.program_application_id;
      p_to.request_id := p_from.request_id;
      p_to.object_version_number := p_from.object_version_number;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
      p_to.lease_application_id := p_from.lease_application_id;
      p_to.legal_entity_id := p_from.legal_entity_id;
    END migrate;
    PROCEDURE migrate (
      p_from IN ipyv_rec_type,
      p_to   IN OUT NOCOPY okl_ins_policies_tl_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.sfwt_flag := p_from.sfwt_flag;
      p_to.description := p_from.description;
      p_to.endorsement := p_from.endorsement;
      p_to.comments := p_from.comments;
      p_to.cancellation_comment := p_from.cancellation_comment;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    PROCEDURE migrate (
      p_from IN okl_ins_policies_tl_rec_type,
      p_to   IN OUT NOCOPY ipyv_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.description := p_from.description;
      p_to.endorsement := p_from.endorsement;
      p_to.sfwt_flag := p_from.sfwt_flag;
      p_to.cancellation_comment := p_from.cancellation_comment;
      p_to.comments := p_from.comments;
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
    -- validate_row for:OKL_INS_POLICIES_V --
    -----------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_rec                     IN ipyv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipyv_rec                     ipyv_rec_type := p_ipyv_rec;
      l_ipy_rec                      ipy_rec_type;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
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
      l_return_status := Validate_Attributes(l_ipyv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_ipyv_rec);
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
    -- PL/SQL TBL validate_row for:OKL_INS_POLICIES_V --
    ----------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
        LOOP
          DECLARE
            l_error_rec         OKL_API.ERROR_REC_TYPE;
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
              p_ipyv_rec                     => p_ipyv_tbl(i));
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
          EXIT WHEN (i = p_ipyv_tbl.LAST);
          i := p_ipyv_tbl.NEXT(i);
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
    -- PL/SQL TBL validate_row for:OKL_INS_POLICIES_V --
    ----------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ipyv_tbl                     => p_ipyv_tbl,
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
    ---------------------------------------
    -- insert_row for:OKL_INS_POLICIES_B --
    ---------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipy_rec                      IN ipy_rec_type,
      x_ipy_rec                      OUT NOCOPY ipy_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipy_rec                      ipy_rec_type := p_ipy_rec;
      l_def_ipy_rec                  ipy_rec_type;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_POLICIES_B --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_ipy_rec IN ipy_rec_type,
        x_ipy_rec OUT NOCOPY ipy_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	l_org_id NUMBER;
      BEGIN
        x_ipy_rec := p_ipy_rec;
        SELECT NVL(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_ipy_rec.request_id),
	                               NVL(DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_ipy_rec.program_application_id),
	                               NVL(DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_ipy_rec.program_id),
	                               DECODE(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_ipy_rec.program_update_date,SYSDATE),
				       MO_GLOBAL.GET_CURRENT_ORG_ID()
	                               INTO x_ipy_rec.request_id,
	                                    x_ipy_rec.program_application_id,
	                                    x_ipy_rec.program_id,
	                                    x_ipy_rec.program_update_date,
                                            l_org_id -- Change by zrehman for Bug#6363652 9-Oct-2007
                                       FROM dual;
        IF (x_ipy_rec.org_id IS NULL OR x_ipy_rec.org_id = OKC_API.G_MISS_NUM) THEN
	  x_ipy_rec.org_id := l_org_id;
	END IF;

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
        p_ipy_rec,                         -- IN
        l_ipy_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      INSERT INTO OKL_INS_POLICIES_B(
        id,
        ipy_type,
        name_of_insured,
        policy_number,
        insurance_factor,
        factor_code,
        calculated_premium,
        premium,
        covered_amount,
        deductible,
        adjustment,
        payment_frequency,
        crx_code,
        ipf_code,
        iss_code,
        ipe_code,
        date_to,
        date_from,
        date_quoted,
        date_proof_provided,
        date_proof_required,
        cancellation_date,
        date_quote_expiry,
        activation_date,
        quote_yn,
        on_file_yn,
        private_label_yn,
        agent_yn,
        lessor_insured_yn,
        lessor_payee_yn,
        khr_id,
        kle_id,
        ipt_id,
        ipy_id,
        int_id,
        isu_id,
        factor_value,
        agency_number,
        agency_site_id,
        sales_rep_id,
        agent_site_id,
        adjusted_by_id,
        territory_code,
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
        program_id,
        org_id,
        program_update_date,
        program_application_id,
        request_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
        lease_application_id,
        legal_entity_id)
      VALUES (
        l_ipy_rec.id,
        l_ipy_rec.ipy_type,
        l_ipy_rec.name_of_insured,
        l_ipy_rec.policy_number,
        l_ipy_rec.insurance_factor,
        l_ipy_rec.factor_code,
        l_ipy_rec.calculated_premium,
        l_ipy_rec.premium,
        l_ipy_rec.covered_amount,
        l_ipy_rec.deductible,
        l_ipy_rec.adjustment,
        l_ipy_rec.payment_frequency,
        l_ipy_rec.crx_code,
        l_ipy_rec.ipf_code,
        l_ipy_rec.iss_code,
        l_ipy_rec.ipe_code,
        l_ipy_rec.date_to,
        l_ipy_rec.date_from,
        l_ipy_rec.date_quoted,
        l_ipy_rec.date_proof_provided,
        l_ipy_rec.date_proof_required,
        l_ipy_rec.cancellation_date,
        l_ipy_rec.date_quote_expiry,
        l_ipy_rec.activation_date,
        l_ipy_rec.quote_yn,
        l_ipy_rec.on_file_yn,
        l_ipy_rec.private_label_yn,
        l_ipy_rec.agent_yn,
        l_ipy_rec.lessor_insured_yn,
        l_ipy_rec.lessor_payee_yn,
        l_ipy_rec.khr_id,
        l_ipy_rec.kle_id,
        l_ipy_rec.ipt_id,
        l_ipy_rec.ipy_id,
        l_ipy_rec.int_id,
        l_ipy_rec.isu_id,
        l_ipy_rec.factor_value,
        l_ipy_rec.agency_number,
        l_ipy_rec.agency_site_id,
        l_ipy_rec.sales_rep_id,
        l_ipy_rec.agent_site_id,
        l_ipy_rec.adjusted_by_id,
        l_ipy_rec.territory_code,
        l_ipy_rec.attribute_category,
        l_ipy_rec.attribute1,
        l_ipy_rec.attribute2,
        l_ipy_rec.attribute3,
        l_ipy_rec.attribute4,
        l_ipy_rec.attribute5,
        l_ipy_rec.attribute6,
        l_ipy_rec.attribute7,
        l_ipy_rec.attribute8,
        l_ipy_rec.attribute9,
        l_ipy_rec.attribute10,
        l_ipy_rec.attribute11,
        l_ipy_rec.attribute12,
        l_ipy_rec.attribute13,
        l_ipy_rec.attribute14,
        l_ipy_rec.attribute15,
        l_ipy_rec.program_id,
        l_ipy_rec.org_id,
        l_ipy_rec.program_update_date,
        l_ipy_rec.program_application_id,
        l_ipy_rec.request_id,
        l_ipy_rec.object_version_number,
        l_ipy_rec.created_by,
        l_ipy_rec.creation_date,
        l_ipy_rec.last_updated_by,
        l_ipy_rec.last_update_date,
        l_ipy_rec.last_update_login,
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
        l_ipy_rec.lease_application_id,
        l_ipy_rec.legal_entity_id);
      -- Set OUT values
      x_ipy_rec := l_ipy_rec;
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
    -- insert_row for:OKL_INS_POLICIES_TL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_policies_tl_rec      IN okl_ins_policies_tl_rec_type,
      x_okl_ins_policies_tl_rec      OUT NOCOPY okl_ins_policies_tl_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type := p_okl_ins_policies_tl_rec;
      l_def_okl_ins_policies_tl_rec  okl_ins_policies_tl_rec_type;
      CURSOR get_languages IS
        SELECT *
          FROM FND_LANGUAGES
         WHERE INSTALLED_FLAG IN ('I', 'B');
      --------------------------------------------
      -- Set_Attributes for:OKL_INS_POLICIES_TL --
      --------------------------------------------
      FUNCTION Set_Attributes (
        p_okl_ins_policies_tl_rec IN okl_ins_policies_tl_rec_type,
        x_okl_ins_policies_tl_rec OUT NOCOPY okl_ins_policies_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_policies_tl_rec := p_okl_ins_policies_tl_rec;
        x_okl_ins_policies_tl_rec.LANGUAGE := USERENV('LANG');
        x_okl_ins_policies_tl_rec.SOURCE_LANG := USERENV('LANG');
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
        p_okl_ins_policies_tl_rec,         -- IN
        l_okl_ins_policies_tl_rec);        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      FOR l_lang_rec IN get_languages LOOP
        l_okl_ins_policies_tl_rec.language := l_lang_rec.language_code;
        INSERT INTO OKL_INS_POLICIES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          description,
          endorsement,
          comments,
          cancellation_comment,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_ins_policies_tl_rec.id,
          l_okl_ins_policies_tl_rec.language,
          l_okl_ins_policies_tl_rec.source_lang,
          l_okl_ins_policies_tl_rec.sfwt_flag,
          l_okl_ins_policies_tl_rec.description,
          l_okl_ins_policies_tl_rec.endorsement,
          l_okl_ins_policies_tl_rec.comments,
          l_okl_ins_policies_tl_rec.cancellation_comment,
          l_okl_ins_policies_tl_rec.created_by,
          l_okl_ins_policies_tl_rec.creation_date,
          l_okl_ins_policies_tl_rec.last_updated_by,
          l_okl_ins_policies_tl_rec.last_update_date,
          l_okl_ins_policies_tl_rec.last_update_login);
      END LOOP;
      -- Set OUT values
      x_okl_ins_policies_tl_rec := l_okl_ins_policies_tl_rec;
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
    -- insert_row for :OKL_INS_POLICIES_V --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_rec                     IN ipyv_rec_type,
      x_ipyv_rec                     OUT NOCOPY ipyv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipyv_rec                     ipyv_rec_type := p_ipyv_rec;
      l_def_ipyv_rec                 ipyv_rec_type;
      l_ipy_rec                      ipy_rec_type;
      lx_ipy_rec                     ipy_rec_type;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
      lx_okl_ins_policies_tl_rec     okl_ins_policies_tl_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_ipyv_rec IN ipyv_rec_type
      ) RETURN ipyv_rec_type IS
        l_ipyv_rec ipyv_rec_type := p_ipyv_rec;
      BEGIN
        l_ipyv_rec.CREATION_DATE := SYSDATE;
        l_ipyv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
        l_ipyv_rec.LAST_UPDATE_DATE := l_ipyv_rec.CREATION_DATE;
        l_ipyv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_ipyv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_ipyv_rec);
      END fill_who_columns;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_POLICIES_V --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_ipyv_rec IN ipyv_rec_type,
        x_ipyv_rec OUT NOCOPY ipyv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	l_org_id NUMBER;
      BEGIN
        x_ipyv_rec := p_ipyv_rec;
        x_ipyv_rec.OBJECT_VERSION_NUMBER := 1;
        x_ipyv_rec.SFWT_FLAG := 'N';
        SELECT DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
	                        DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
	                        DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
	                        DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
	                        MO_GLOBAL.GET_CURRENT_ORG_ID()
	INTO x_ipyv_rec.request_id,
	     x_ipyv_rec.program_application_id,
	     x_ipyv_rec.program_id,
	     x_ipyv_rec.program_update_date,
             l_org_id  ---- Change by zrehman for Bug#6363652 9-Oct-2007
	FROM dual;
        IF(x_ipyv_rec.org_id IS NULL OR x_ipyv_rec.org_id = OKC_API.G_MISS_NUM) THEN
	  x_ipyv_rec.org_id := l_org_id;
	END IF;
        RETURN(l_return_status);
      END Set_Attributes;

      -------------------------------------------
      -- Set_adjustedby_Id for:OKL_INS_POLICIES_V --
      --added as a fix for bug 2513901
      -------------------------------------------
       FUNCTION set_adjustedby_id(
      p_ipyv_rec IN ipyv_rec_type
      )RETURN ipyv_rec_type IS
      l_ipyv_rec_type ipyv_rec_type:=p_ipyv_rec;
      Begin
        IF (l_ipyv_rec_type.adjustment IS NOT NULL) THEN
        l_ipyv_rec_type.adjusted_by_id := FND_GLOBAL.USER_ID;
        END IF;
        return (l_ipyv_rec_type);
      End set_adjustedby_id;

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
      l_ipyv_rec := null_out_defaults(p_ipyv_rec);
      -- Set primary key value
      l_ipyv_rec.ID := get_seq_id;
      -- Setting item attributes
      l_return_Status := Set_Attributes(
        l_ipyv_rec,                        -- IN
        l_def_ipyv_rec);                   -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_ipyv_rec := fill_who_columns(l_def_ipyv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_ipyv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --Added for bug 2513901
      -- Setting adjusted by ID
      l_def_ipyv_rec := set_adjustedby_id(l_def_ipyv_rec);
      l_return_status := Validate_Record(l_def_ipyv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_ipyv_rec, l_ipy_rec);
      migrate(l_def_ipyv_rec, l_okl_ins_policies_tl_rec);
      -----------------------------------------------
      -- Call the INSERT_ROW for each child record --
      -----------------------------------------------
      insert_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_ipy_rec,
        lx_ipy_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_ipy_rec, l_def_ipyv_rec);
      insert_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_policies_tl_rec,
        lx_okl_ins_policies_tl_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_okl_ins_policies_tl_rec, l_def_ipyv_rec);
      -- Set OUT values
      x_ipyv_rec := l_def_ipyv_rec;
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
    -- PL/SQL TBL insert_row for:IPYV_TBL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type,
      x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
        LOOP
          DECLARE
            l_error_rec         OKL_API.ERROR_REC_TYPE;
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
              p_ipyv_rec                     => p_ipyv_tbl(i),
              x_ipyv_rec                     => x_ipyv_tbl(i));
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
          EXIT WHEN (i = p_ipyv_tbl.LAST);
          i := p_ipyv_tbl.NEXT(i);
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
    -- PL/SQL TBL insert_row for:IPYV_TBL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type,
      x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ipyv_tbl                     => p_ipyv_tbl,
          x_ipyv_tbl                     => x_ipyv_tbl,
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
    -------------------------------------
    -- lock_row for:OKL_INS_POLICIES_B --
    -------------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipy_rec                      IN ipy_rec_type) IS
      E_Resource_Busy                EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_ipy_rec IN ipy_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_INS_POLICIES_B
       WHERE ID = p_ipy_rec.id
         AND OBJECT_VERSION_NUMBER = p_ipy_rec.object_version_number
      FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;
      CURSOR lchk_csr (p_ipy_rec IN ipy_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_INS_POLICIES_B
       WHERE ID = p_ipy_rec.id;
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_object_version_number        OKL_INS_POLICIES_B.OBJECT_VERSION_NUMBER%TYPE;
      lc_object_version_number       OKL_INS_POLICIES_B.OBJECT_VERSION_NUMBER%TYPE;
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
        OPEN lock_csr(p_ipy_rec);
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
        OPEN lchk_csr(p_ipy_rec);
        FETCH lchk_csr INTO lc_object_version_number;
        lc_row_notfound := lchk_csr%NOTFOUND;
        CLOSE lchk_csr;
      END IF;
      IF (lc_row_notfound) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number > p_ipy_rec.object_version_number THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number <> p_ipy_rec.object_version_number THEN
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
    -- lock_row for:OKL_INS_POLICIES_TL --
    --------------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_policies_tl_rec      IN okl_ins_policies_tl_rec_type) IS
      E_Resource_Busy                EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_okl_ins_policies_tl_rec IN okl_ins_policies_tl_rec_type) IS
      SELECT *
        FROM OKL_INS_POLICIES_TL
       WHERE ID = p_okl_ins_policies_tl_rec.id
      FOR UPDATE NOWAIT;
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
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
        OPEN lock_csr(p_okl_ins_policies_tl_rec);
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
    -- lock_row for: OKL_INS_POLICIES_V --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_rec                     IN ipyv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipy_rec                      ipy_rec_type;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
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
      migrate(p_ipyv_rec, l_ipy_rec);
      migrate(p_ipyv_rec, l_okl_ins_policies_tl_rec);
      ---------------------------------------------
      -- Call the LOCK_ROW for each child record --
      ---------------------------------------------
      lock_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_ipy_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      lock_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_policies_tl_rec
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
    -- PL/SQL TBL lock_row for:IPYV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
        LOOP
          DECLARE
            l_error_rec         OKL_API.ERROR_REC_TYPE;
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
              p_ipyv_rec                     => p_ipyv_tbl(i));
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
          EXIT WHEN (i = p_ipyv_tbl.LAST);
          i := p_ipyv_tbl.NEXT(i);
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
    -- PL/SQL TBL lock_row for:IPYV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        lock_row(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ipyv_tbl                     => p_ipyv_tbl,
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
    ---------------------------------------
    -- update_row for:OKL_INS_POLICIES_B --
    ---------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipy_rec                      IN ipy_rec_type,
      x_ipy_rec                      OUT NOCOPY ipy_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipy_rec                      ipy_rec_type := p_ipy_rec;
      l_def_ipy_rec                  ipy_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_ipy_rec IN ipy_rec_type,
        x_ipy_rec OUT NOCOPY ipy_rec_type
      ) RETURN VARCHAR2 IS
        l_ipy_rec                      ipy_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_ipy_rec := p_ipy_rec;
        -- Get current database values
        l_ipy_rec := get_rec(p_ipy_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          IF (x_ipy_rec.id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.id := l_ipy_rec.id;
          END IF;
          IF (x_ipy_rec.ipy_type = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.ipy_type := l_ipy_rec.ipy_type;
          END IF;
          IF (x_ipy_rec.name_of_insured = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.name_of_insured := l_ipy_rec.name_of_insured;
          END IF;
          IF (x_ipy_rec.policy_number = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.policy_number := l_ipy_rec.policy_number;
          END IF;
          IF (x_ipy_rec.insurance_factor = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.insurance_factor := l_ipy_rec.insurance_factor;
          END IF;
          IF (x_ipy_rec.factor_code = OKC_API.G_MISS_CHAR)
	  THEN
	    x_ipy_rec.factor_code := l_ipy_rec.factor_code;
          END IF;
          IF (x_ipy_rec.calculated_premium = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.calculated_premium := l_ipy_rec.calculated_premium;
          END IF;
          IF (x_ipy_rec.premium = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.premium := l_ipy_rec.premium;
          END IF;
          IF (x_ipy_rec.covered_amount = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.covered_amount := l_ipy_rec.covered_amount;
          END IF;
          IF (x_ipy_rec.deductible = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.deductible := l_ipy_rec.deductible;
          END IF;
          IF (x_ipy_rec.adjustment = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.adjustment := l_ipy_rec.adjustment;
          END IF;
          IF (x_ipy_rec.payment_frequency = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.payment_frequency := l_ipy_rec.payment_frequency;
          END IF;
          IF (x_ipy_rec.crx_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.crx_code := l_ipy_rec.crx_code;
          END IF;
          IF (x_ipy_rec.ipf_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.ipf_code := l_ipy_rec.ipf_code;
          END IF;
          IF (x_ipy_rec.iss_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.iss_code := l_ipy_rec.iss_code;
          END IF;
          IF (x_ipy_rec.ipe_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.ipe_code := l_ipy_rec.ipe_code;
          END IF;
          IF (x_ipy_rec.date_to = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.date_to := l_ipy_rec.date_to;
          END IF;
          IF (x_ipy_rec.date_from = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.date_from := l_ipy_rec.date_from;
          END IF;
          IF (x_ipy_rec.date_quoted = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.date_quoted := l_ipy_rec.date_quoted;
          END IF;
          IF (x_ipy_rec.date_proof_provided = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.date_proof_provided := l_ipy_rec.date_proof_provided;
          END IF;
          IF (x_ipy_rec.date_proof_required = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.date_proof_required := l_ipy_rec.date_proof_required;
          END IF;
          IF (x_ipy_rec.cancellation_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.cancellation_date := l_ipy_rec.cancellation_date;
          END IF;
          IF (x_ipy_rec.date_quote_expiry = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.date_quote_expiry := l_ipy_rec.date_quote_expiry;
          END IF;
          IF (x_ipy_rec.activation_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.activation_date := l_ipy_rec.activation_date;
          END IF;
          IF (x_ipy_rec.quote_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.quote_yn := l_ipy_rec.quote_yn;
          END IF;
          IF (x_ipy_rec.on_file_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.on_file_yn := l_ipy_rec.on_file_yn;
          END IF;
          IF (x_ipy_rec.private_label_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.private_label_yn := l_ipy_rec.private_label_yn;
          END IF;
          IF (x_ipy_rec.agent_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.agent_yn := l_ipy_rec.agent_yn;
          END IF;
          IF (x_ipy_rec.lessor_insured_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.lessor_insured_yn := l_ipy_rec.lessor_insured_yn;
          END IF;
          IF (x_ipy_rec.lessor_payee_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.lessor_payee_yn := l_ipy_rec.lessor_payee_yn;
          END IF;
          IF (x_ipy_rec.khr_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.khr_id := l_ipy_rec.khr_id;
          END IF;
          IF (x_ipy_rec.kle_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.kle_id := l_ipy_rec.kle_id;
          END IF;
          IF (x_ipy_rec.ipt_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.ipt_id := l_ipy_rec.ipt_id;
          END IF;
          IF (x_ipy_rec.ipy_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.ipy_id := l_ipy_rec.ipy_id;
          END IF;
          IF (x_ipy_rec.int_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.int_id := l_ipy_rec.int_id;
          END IF;
          IF (x_ipy_rec.isu_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.isu_id := l_ipy_rec.isu_id;
          END IF;
          IF (x_ipy_rec.factor_value = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.factor_value := l_ipy_rec.factor_value;
          END IF;
          IF (x_ipy_rec.agency_number = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.agency_number := l_ipy_rec.agency_number;
          END IF;
          IF (x_ipy_rec.agency_site_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.agency_site_id := l_ipy_rec.agency_site_id;
          END IF;
          IF (x_ipy_rec.sales_rep_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.sales_rep_id := l_ipy_rec.sales_rep_id;
          END IF;
          IF (x_ipy_rec.agent_site_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.agent_site_id := l_ipy_rec.agent_site_id;
          END IF;
          IF (x_ipy_rec.adjusted_by_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.adjusted_by_id := l_ipy_rec.adjusted_by_id;
          END IF;
          IF (x_ipy_rec.territory_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.territory_code := l_ipy_rec.territory_code;
          END IF;
          IF (x_ipy_rec.attribute_category = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute_category := l_ipy_rec.attribute_category;
          END IF;
          IF (x_ipy_rec.attribute1 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute1 := l_ipy_rec.attribute1;
          END IF;
          IF (x_ipy_rec.attribute2 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute2 := l_ipy_rec.attribute2;
          END IF;
          IF (x_ipy_rec.attribute3 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute3 := l_ipy_rec.attribute3;
          END IF;
          IF (x_ipy_rec.attribute4 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute4 := l_ipy_rec.attribute4;
          END IF;
          IF (x_ipy_rec.attribute5 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute5 := l_ipy_rec.attribute5;
          END IF;
          IF (x_ipy_rec.attribute6 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute6 := l_ipy_rec.attribute6;
          END IF;
          IF (x_ipy_rec.attribute7 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute7 := l_ipy_rec.attribute7;
          END IF;
          IF (x_ipy_rec.attribute8 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute8 := l_ipy_rec.attribute8;
          END IF;
          IF (x_ipy_rec.attribute9 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute9 := l_ipy_rec.attribute9;
          END IF;
          IF (x_ipy_rec.attribute10 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute10 := l_ipy_rec.attribute10;
          END IF;
          IF (x_ipy_rec.attribute11 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute11 := l_ipy_rec.attribute11;
          END IF;
          IF (x_ipy_rec.attribute12 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute12 := l_ipy_rec.attribute12;
          END IF;
          IF (x_ipy_rec.attribute13 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute13 := l_ipy_rec.attribute13;
          END IF;
          IF (x_ipy_rec.attribute14 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute14 := l_ipy_rec.attribute14;
          END IF;
          IF (x_ipy_rec.attribute15 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipy_rec.attribute15 := l_ipy_rec.attribute15;
          END IF;
          IF (x_ipy_rec.program_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.program_id := l_ipy_rec.program_id;
          END IF;
          IF (x_ipy_rec.org_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.org_id := l_ipy_rec.org_id;
          END IF;
          IF (x_ipy_rec.program_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.program_update_date := l_ipy_rec.program_update_date;
          END IF;
          IF (x_ipy_rec.program_application_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.program_application_id := l_ipy_rec.program_application_id;
          END IF;
          IF (x_ipy_rec.request_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.request_id := l_ipy_rec.request_id;
          END IF;
          IF (x_ipy_rec.object_version_number = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.object_version_number := l_ipy_rec.object_version_number;
          END IF;
          IF (x_ipy_rec.created_by = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.created_by := l_ipy_rec.created_by;
          END IF;
          IF (x_ipy_rec.creation_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.creation_date := l_ipy_rec.creation_date;
          END IF;
          IF (x_ipy_rec.last_updated_by = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.last_updated_by := l_ipy_rec.last_updated_by;
          END IF;
          IF (x_ipy_rec.last_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipy_rec.last_update_date := l_ipy_rec.last_update_date;
          END IF;
          IF (x_ipy_rec.last_update_login = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.last_update_login := l_ipy_rec.last_update_login;
          END IF;
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
          IF (x_ipy_rec.lease_application_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.lease_application_id := l_ipy_rec.lease_application_id;
          END IF;
          IF (x_ipy_rec.legal_entity_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipy_rec.legal_entity_id := l_ipy_rec.legal_entity_id;
          END IF;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_POLICIES_B --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_ipy_rec IN ipy_rec_type,
        x_ipy_rec OUT NOCOPY ipy_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_ipy_rec := p_ipy_rec;
        x_ipy_rec.OBJECT_VERSION_NUMBER := p_ipy_rec.OBJECT_VERSION_NUMBER + 1;
        SELECT NVL(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_ipy_rec.request_id),
	                         NVL(DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_ipy_rec.program_application_id),
	                         NVL(DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_ipy_rec.program_id),
	                         DECODE(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_ipy_rec.program_update_date,SYSDATE),
	                         MO_GLOBAL.GET_CURRENT_ORG_ID() INTO x_ipy_rec.request_id,
	                                                                             x_ipy_rec.program_application_id,
	                                                                             x_ipy_rec.program_id,
	                                                                             x_ipy_rec.program_update_date,
                                                                             x_ipy_rec.org_id FROM dual;
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
        p_ipy_rec,                         -- IN
        l_ipy_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_ipy_rec, l_def_ipy_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      UPDATE OKL_INS_POLICIES_B
      SET IPY_TYPE = l_def_ipy_rec.ipy_type,
          NAME_OF_INSURED = l_def_ipy_rec.name_of_insured,
          POLICY_NUMBER = l_def_ipy_rec.policy_number,
          INSURANCE_FACTOR = l_def_ipy_rec.insurance_factor,
          FACTOR_CODE = l_def_ipy_rec.factor_code,
          CALCULATED_PREMIUM = l_def_ipy_rec.calculated_premium,
          PREMIUM = l_def_ipy_rec.premium,
          COVERED_AMOUNT = l_def_ipy_rec.covered_amount,
          DEDUCTIBLE = l_def_ipy_rec.deductible,
          ADJUSTMENT = l_def_ipy_rec.adjustment,
          PAYMENT_FREQUENCY = l_def_ipy_rec.payment_frequency,
          CRX_CODE = l_def_ipy_rec.crx_code,
          IPF_CODE = l_def_ipy_rec.ipf_code,
          ISS_CODE = l_def_ipy_rec.iss_code,
          IPE_CODE = l_def_ipy_rec.ipe_code,
          DATE_TO = l_def_ipy_rec.date_to,
          DATE_FROM = l_def_ipy_rec.date_from,
          DATE_QUOTED = l_def_ipy_rec.date_quoted,
          DATE_PROOF_PROVIDED = l_def_ipy_rec.date_proof_provided,
          DATE_PROOF_REQUIRED = l_def_ipy_rec.date_proof_required,
          CANCELLATION_DATE = l_def_ipy_rec.cancellation_date,
          DATE_QUOTE_EXPIRY = l_def_ipy_rec.date_quote_expiry,
          ACTIVATION_DATE = l_def_ipy_rec.activation_date,
          QUOTE_YN = l_def_ipy_rec.quote_yn,
          ON_FILE_YN = l_def_ipy_rec.on_file_yn,
          PRIVATE_LABEL_YN = l_def_ipy_rec.private_label_yn,
          AGENT_YN = l_def_ipy_rec.agent_yn,
          LESSOR_INSURED_YN = l_def_ipy_rec.lessor_insured_yn,
          LESSOR_PAYEE_YN = l_def_ipy_rec.lessor_payee_yn,
          KHR_ID = l_def_ipy_rec.khr_id,
          KLE_ID = l_def_ipy_rec.kle_id,
          IPT_ID = l_def_ipy_rec.ipt_id,
          IPY_ID = l_def_ipy_rec.ipy_id,
          INT_ID = l_def_ipy_rec.int_id,
          ISU_ID = l_def_ipy_rec.isu_id,
          FACTOR_VALUE = l_def_ipy_rec.factor_value,
          AGENCY_NUMBER = l_def_ipy_rec.agency_number,
          AGENCY_SITE_ID = l_def_ipy_rec.agency_site_id,
          SALES_REP_ID = l_def_ipy_rec.sales_rep_id,
          AGENT_SITE_ID = l_def_ipy_rec.agent_site_id,
          ADJUSTED_BY_ID = l_def_ipy_rec.adjusted_by_id,
          TERRITORY_CODE = l_def_ipy_rec.territory_code,
          ATTRIBUTE_CATEGORY = l_def_ipy_rec.attribute_category,
          ATTRIBUTE1 = l_def_ipy_rec.attribute1,
          ATTRIBUTE2 = l_def_ipy_rec.attribute2,
          ATTRIBUTE3 = l_def_ipy_rec.attribute3,
          ATTRIBUTE4 = l_def_ipy_rec.attribute4,
          ATTRIBUTE5 = l_def_ipy_rec.attribute5,
          ATTRIBUTE6 = l_def_ipy_rec.attribute6,
          ATTRIBUTE7 = l_def_ipy_rec.attribute7,
          ATTRIBUTE8 = l_def_ipy_rec.attribute8,
          ATTRIBUTE9 = l_def_ipy_rec.attribute9,
          ATTRIBUTE10 = l_def_ipy_rec.attribute10,
          ATTRIBUTE11 = l_def_ipy_rec.attribute11,
          ATTRIBUTE12 = l_def_ipy_rec.attribute12,
          ATTRIBUTE13 = l_def_ipy_rec.attribute13,
          ATTRIBUTE14 = l_def_ipy_rec.attribute14,
          ATTRIBUTE15 = l_def_ipy_rec.attribute15,
          PROGRAM_ID = l_def_ipy_rec.program_id,
          ORG_ID = l_def_ipy_rec.org_id,
          PROGRAM_UPDATE_DATE = l_def_ipy_rec.program_update_date,
          PROGRAM_APPLICATION_ID = l_def_ipy_rec.program_application_id,
          REQUEST_ID = l_def_ipy_rec.request_id,
          OBJECT_VERSION_NUMBER = l_def_ipy_rec.object_version_number,
          CREATED_BY = l_def_ipy_rec.created_by,
          CREATION_DATE = l_def_ipy_rec.creation_date,
          LAST_UPDATED_BY = l_def_ipy_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_ipy_rec.last_update_date,
          LAST_UPDATE_LOGIN = l_def_ipy_rec.last_update_login,
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
          LEASE_APPLICATION_ID = l_def_ipy_rec.lease_application_id,
          LEGAL_ENTITY_ID = l_def_ipy_rec.legal_entity_id
      WHERE ID = l_def_ipy_rec.id;
      x_ipy_rec := l_ipy_rec;
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
    -- update_row for:OKL_INS_POLICIES_TL --
    ----------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_policies_tl_rec      IN okl_ins_policies_tl_rec_type,
      x_okl_ins_policies_tl_rec      OUT NOCOPY okl_ins_policies_tl_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type := p_okl_ins_policies_tl_rec;
      l_def_okl_ins_policies_tl_rec  okl_ins_policies_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_okl_ins_policies_tl_rec IN okl_ins_policies_tl_rec_type,
        x_okl_ins_policies_tl_rec OUT NOCOPY okl_ins_policies_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_policies_tl_rec := p_okl_ins_policies_tl_rec;
        -- Get current database values
        l_okl_ins_policies_tl_rec := get_rec(p_okl_ins_policies_tl_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          IF (x_okl_ins_policies_tl_rec.id = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_policies_tl_rec.id := l_okl_ins_policies_tl_rec.id;
          END IF;
          IF (x_okl_ins_policies_tl_rec.language = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_policies_tl_rec.language := l_okl_ins_policies_tl_rec.language;
          END IF;
          IF (x_okl_ins_policies_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_policies_tl_rec.source_lang := l_okl_ins_policies_tl_rec.source_lang;
          END IF;
          IF (x_okl_ins_policies_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_policies_tl_rec.sfwt_flag := l_okl_ins_policies_tl_rec.sfwt_flag;
          END IF;
          IF (x_okl_ins_policies_tl_rec.description = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_policies_tl_rec.description := l_okl_ins_policies_tl_rec.description;
          END IF;
          IF (x_okl_ins_policies_tl_rec.endorsement = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_policies_tl_rec.endorsement := l_okl_ins_policies_tl_rec.endorsement;
          END IF;
          IF (x_okl_ins_policies_tl_rec.comments = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_policies_tl_rec.comments := l_okl_ins_policies_tl_rec.comments;
          END IF;
          IF (x_okl_ins_policies_tl_rec.cancellation_comment = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_policies_tl_rec.cancellation_comment := l_okl_ins_policies_tl_rec.cancellation_comment;
          END IF;
          IF (x_okl_ins_policies_tl_rec.created_by = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_policies_tl_rec.created_by := l_okl_ins_policies_tl_rec.created_by;
          END IF;
          IF (x_okl_ins_policies_tl_rec.creation_date = OKC_API.G_MISS_DATE)
          THEN
            x_okl_ins_policies_tl_rec.creation_date := l_okl_ins_policies_tl_rec.creation_date;
          END IF;
          IF (x_okl_ins_policies_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_policies_tl_rec.last_updated_by := l_okl_ins_policies_tl_rec.last_updated_by;
          END IF;
          IF (x_okl_ins_policies_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_okl_ins_policies_tl_rec.last_update_date := l_okl_ins_policies_tl_rec.last_update_date;
          END IF;
          IF (x_okl_ins_policies_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_policies_tl_rec.last_update_login := l_okl_ins_policies_tl_rec.last_update_login;
          END IF;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      --------------------------------------------
      -- Set_Attributes for:OKL_INS_POLICIES_TL --
      --------------------------------------------
      FUNCTION Set_Attributes (
        p_okl_ins_policies_tl_rec IN okl_ins_policies_tl_rec_type,
        x_okl_ins_policies_tl_rec OUT NOCOPY okl_ins_policies_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_policies_tl_rec := p_okl_ins_policies_tl_rec;
        x_okl_ins_policies_tl_rec.LANGUAGE := USERENV('LANG');
        x_okl_ins_policies_tl_rec.LANGUAGE := USERENV('LANG');
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
        p_okl_ins_policies_tl_rec,         -- IN
        l_okl_ins_policies_tl_rec);        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_okl_ins_policies_tl_rec, l_def_okl_ins_policies_tl_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      UPDATE OKL_INS_POLICIES_TL
      SET DESCRIPTION = l_def_okl_ins_policies_tl_rec.description,
          SOURCE_LANG = l_def_okl_ins_policies_tl_rec.source_lang, --Added for bug 3637102
          ENDORSEMENT = l_def_okl_ins_policies_tl_rec.endorsement,
          COMMENTS = l_def_okl_ins_policies_tl_rec.comments,
          CANCELLATION_COMMENT = l_def_okl_ins_policies_tl_rec.cancellation_comment,
          CREATED_BY = l_def_okl_ins_policies_tl_rec.created_by,
          CREATION_DATE = l_def_okl_ins_policies_tl_rec.creation_date,
          LAST_UPDATED_BY = l_def_okl_ins_policies_tl_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_okl_ins_policies_tl_rec.last_update_date,
          LAST_UPDATE_LOGIN = l_def_okl_ins_policies_tl_rec.last_update_login
      WHERE ID = l_def_okl_ins_policies_tl_rec.id
        AND  USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Added LANGUAGE for fixing 3637102

      UPDATE OKL_INS_POLICIES_TL
      SET SFWT_FLAG = 'Y'
      WHERE ID = l_def_okl_ins_policies_tl_rec.id
        AND SOURCE_LANG <> USERENV('LANG');
      x_okl_ins_policies_tl_rec := l_okl_ins_policies_tl_rec;
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
    -- update_row for:OKL_INS_POLICIES_V --
    ---------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_rec                     IN ipyv_rec_type,
      x_ipyv_rec                     OUT NOCOPY ipyv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipyv_rec                     ipyv_rec_type := p_ipyv_rec;
      l_def_ipyv_rec                 ipyv_rec_type;
      l_db_ipyv_rec                  ipyv_rec_type;
      l_ipy_rec                      ipy_rec_type;
      lx_ipy_rec                     ipy_rec_type;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
      lx_okl_ins_policies_tl_rec     okl_ins_policies_tl_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_ipyv_rec IN ipyv_rec_type
      ) RETURN ipyv_rec_type IS
        l_ipyv_rec ipyv_rec_type := p_ipyv_rec;
      BEGIN
        l_ipyv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_ipyv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_ipyv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_ipyv_rec);
      END fill_who_columns;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_ipyv_rec IN ipyv_rec_type,
        x_ipyv_rec OUT NOCOPY ipyv_rec_type
      ) RETURN VARCHAR2 IS
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_ipyv_rec := p_ipyv_rec;
        -- Get current database values
        -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
        --       so it may be verified through LOCK_ROW.
        l_db_ipyv_rec := get_rec(p_ipyv_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          IF (x_ipyv_rec.id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.id := l_db_ipyv_rec.id;
          END IF;
          IF (x_ipyv_rec.ipy_type = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.ipy_type := l_db_ipyv_rec.ipy_type;
          END IF;
          IF (x_ipyv_rec.description = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.description := l_db_ipyv_rec.description;
          END IF;
          IF (x_ipyv_rec.endorsement = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.endorsement := l_db_ipyv_rec.endorsement;
          END IF;
          IF (x_ipyv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.sfwt_flag := l_db_ipyv_rec.sfwt_flag;
          END IF;
          IF (x_ipyv_rec.cancellation_comment = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.cancellation_comment := l_db_ipyv_rec.cancellation_comment;
          END IF;
          IF (x_ipyv_rec.comments = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.comments := l_db_ipyv_rec.comments;
          END IF;
          IF (x_ipyv_rec.name_of_insured = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.name_of_insured := l_db_ipyv_rec.name_of_insured;
          END IF;
          IF (x_ipyv_rec.policy_number = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.policy_number := l_db_ipyv_rec.policy_number;
          END IF;
          IF (x_ipyv_rec.calculated_premium = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.calculated_premium := l_db_ipyv_rec.calculated_premium;
          END IF;
          IF (x_ipyv_rec.premium = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.premium := l_db_ipyv_rec.premium;
          END IF;
          IF (x_ipyv_rec.covered_amount = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.covered_amount := l_db_ipyv_rec.covered_amount;
          END IF;
          IF (x_ipyv_rec.deductible = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.deductible := l_db_ipyv_rec.deductible;
          END IF;
          IF (x_ipyv_rec.adjustment = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.adjustment := l_db_ipyv_rec.adjustment;
          END IF;
          IF (x_ipyv_rec.payment_frequency = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.payment_frequency := l_db_ipyv_rec.payment_frequency;
          END IF;
          IF (x_ipyv_rec.crx_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.crx_code := l_db_ipyv_rec.crx_code;
          END IF;
          IF (x_ipyv_rec.ipf_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.ipf_code := l_db_ipyv_rec.ipf_code;
          END IF;
          IF (x_ipyv_rec.iss_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.iss_code := l_db_ipyv_rec.iss_code;
          END IF;
          IF (x_ipyv_rec.ipe_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.ipe_code := l_db_ipyv_rec.ipe_code;
          END IF;
          IF (x_ipyv_rec.date_to = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.date_to := l_db_ipyv_rec.date_to;
          END IF;
          IF (x_ipyv_rec.date_from = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.date_from := l_db_ipyv_rec.date_from;
          END IF;
          IF (x_ipyv_rec.date_quoted = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.date_quoted := l_db_ipyv_rec.date_quoted;
          END IF;
          IF (x_ipyv_rec.date_proof_provided = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.date_proof_provided := l_db_ipyv_rec.date_proof_provided;
          END IF;
          IF (x_ipyv_rec.date_proof_required = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.date_proof_required := l_db_ipyv_rec.date_proof_required;
          END IF;
          IF (x_ipyv_rec.cancellation_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.cancellation_date := l_db_ipyv_rec.cancellation_date;
          END IF;
          IF (x_ipyv_rec.date_quote_expiry = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.date_quote_expiry := l_db_ipyv_rec.date_quote_expiry;
          END IF;
          IF (x_ipyv_rec.activation_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.activation_date := l_db_ipyv_rec.activation_date;
          END IF;
          IF (x_ipyv_rec.quote_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.quote_yn := l_db_ipyv_rec.quote_yn;
          END IF;
          IF (x_ipyv_rec.on_file_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.on_file_yn := l_db_ipyv_rec.on_file_yn;
          END IF;
          IF (x_ipyv_rec.private_label_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.private_label_yn := l_db_ipyv_rec.private_label_yn;
          END IF;
          IF (x_ipyv_rec.agent_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.agent_yn := l_db_ipyv_rec.agent_yn;
          END IF;
          IF (x_ipyv_rec.lessor_insured_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.lessor_insured_yn := l_db_ipyv_rec.lessor_insured_yn;
          END IF;
          IF (x_ipyv_rec.lessor_payee_yn = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.lessor_payee_yn := l_db_ipyv_rec.lessor_payee_yn;
          END IF;
          IF (x_ipyv_rec.khr_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.khr_id := l_db_ipyv_rec.khr_id;
          END IF;
          IF (x_ipyv_rec.kle_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.kle_id := l_db_ipyv_rec.kle_id;
          END IF;
          IF (x_ipyv_rec.ipt_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.ipt_id := l_db_ipyv_rec.ipt_id;
          END IF;
          IF (x_ipyv_rec.ipy_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.ipy_id := l_db_ipyv_rec.ipy_id;
          END IF;
          IF (x_ipyv_rec.int_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.int_id := l_db_ipyv_rec.int_id;
          END IF;
          IF (x_ipyv_rec.isu_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.isu_id := l_db_ipyv_rec.isu_id;
          END IF;
          IF (x_ipyv_rec.insurance_factor = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.insurance_factor := l_db_ipyv_rec.insurance_factor;
          END IF;
          IF (x_ipyv_rec.factor_code = OKC_API.G_MISS_CHAR)
	  THEN
	    x_ipyv_rec.factor_code := l_db_ipyv_rec.factor_code;
          END IF;
          IF (x_ipyv_rec.factor_value = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.factor_value := l_db_ipyv_rec.factor_value;
          END IF;
          IF (x_ipyv_rec.agency_number = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.agency_number := l_db_ipyv_rec.agency_number;
          END IF;
          IF (x_ipyv_rec.agency_site_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.agency_site_id := l_db_ipyv_rec.agency_site_id;
          END IF;
          IF (x_ipyv_rec.sales_rep_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.sales_rep_id := l_db_ipyv_rec.sales_rep_id;
          END IF;
          IF (x_ipyv_rec.agent_site_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.agent_site_id := l_db_ipyv_rec.agent_site_id;
          END IF;
          IF (x_ipyv_rec.adjusted_by_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.adjusted_by_id := l_db_ipyv_rec.adjusted_by_id;
          END IF;
          IF (x_ipyv_rec.territory_code = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.territory_code := l_db_ipyv_rec.territory_code;
          END IF;
          IF (x_ipyv_rec.attribute_category = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute_category := l_db_ipyv_rec.attribute_category;
          END IF;
          IF (x_ipyv_rec.attribute1 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute1 := l_db_ipyv_rec.attribute1;
          END IF;
          IF (x_ipyv_rec.attribute2 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute2 := l_db_ipyv_rec.attribute2;
          END IF;
          IF (x_ipyv_rec.attribute3 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute3 := l_db_ipyv_rec.attribute3;
          END IF;
          IF (x_ipyv_rec.attribute4 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute4 := l_db_ipyv_rec.attribute4;
          END IF;
          IF (x_ipyv_rec.attribute5 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute5 := l_db_ipyv_rec.attribute5;
          END IF;
          IF (x_ipyv_rec.attribute6 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute6 := l_db_ipyv_rec.attribute6;
          END IF;
          IF (x_ipyv_rec.attribute7 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute7 := l_db_ipyv_rec.attribute7;
          END IF;
          IF (x_ipyv_rec.attribute8 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute8 := l_db_ipyv_rec.attribute8;
          END IF;
          IF (x_ipyv_rec.attribute9 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute9 := l_db_ipyv_rec.attribute9;
          END IF;
          IF (x_ipyv_rec.attribute10 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute10 := l_db_ipyv_rec.attribute10;
          END IF;
          IF (x_ipyv_rec.attribute11 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute11 := l_db_ipyv_rec.attribute11;
          END IF;
          IF (x_ipyv_rec.attribute12 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute12 := l_db_ipyv_rec.attribute12;
          END IF;
          IF (x_ipyv_rec.attribute13 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute13 := l_db_ipyv_rec.attribute13;
          END IF;
          IF (x_ipyv_rec.attribute14 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute14 := l_db_ipyv_rec.attribute14;
          END IF;
          IF (x_ipyv_rec.attribute15 = OKC_API.G_MISS_CHAR)
          THEN
            x_ipyv_rec.attribute15 := l_db_ipyv_rec.attribute15;
          END IF;
          IF (x_ipyv_rec.program_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.program_id := l_db_ipyv_rec.program_id;
          END IF;
          IF (x_ipyv_rec.org_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.org_id := l_db_ipyv_rec.org_id;
          END IF;
          IF (x_ipyv_rec.program_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.program_update_date := l_db_ipyv_rec.program_update_date;
          END IF;
          IF (x_ipyv_rec.program_application_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.program_application_id := l_db_ipyv_rec.program_application_id;
          END IF;
          IF (x_ipyv_rec.request_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.request_id := l_db_ipyv_rec.request_id;
          END IF;
          IF (x_ipyv_rec.created_by = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.created_by := l_db_ipyv_rec.created_by;
          END IF;
          IF (x_ipyv_rec.creation_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.creation_date := l_db_ipyv_rec.creation_date;
          END IF;
          IF (x_ipyv_rec.last_updated_by = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.last_updated_by := l_db_ipyv_rec.last_updated_by;
          END IF;
          IF (x_ipyv_rec.last_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_ipyv_rec.last_update_date := l_db_ipyv_rec.last_update_date;
          END IF;
          IF (x_ipyv_rec.last_update_login = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.last_update_login := l_db_ipyv_rec.last_update_login;
          END IF;
-- Bug: 4567777 PAGARG new column for Lease Application Functionality impact
          IF (x_ipyv_rec.lease_application_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.lease_application_id := l_db_ipyv_rec.lease_application_id;
          END IF;
          IF (x_ipyv_rec.legal_entity_id = OKC_API.G_MISS_NUM)
          THEN
            x_ipyv_rec.legal_entity_id := l_db_ipyv_rec.legal_entity_id;
          END IF;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      -------------------------------------------
      -- Set_Attributes for:OKL_INS_POLICIES_V --
      -------------------------------------------
      FUNCTION Set_Attributes (
        p_ipyv_rec IN ipyv_rec_type,
        x_ipyv_rec OUT NOCOPY ipyv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_ipyv_rec := p_ipyv_rec;
        SELECT NVL(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_ipyv_rec.request_id),
	                         NVL(DECODE(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_ipyv_rec.program_application_id),
	                         NVL(DECODE(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_ipyv_rec.program_id),
	                         DECODE(DECODE(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_ipyv_rec.program_update_date,SYSDATE),
	                        MO_GLOBAL.GET_CURRENT_ORG_ID() INTO x_ipyv_rec.request_id,
	                                                                            x_ipyv_rec.program_application_id,
	                                                                            x_ipyv_rec.program_id,
	                                                                            x_ipyv_rec.program_update_date,
	                                                                            x_ipyv_rec.org_id FROM dual;

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
        p_ipyv_rec,                        -- IN
        x_ipyv_rec);                       -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_ipyv_rec, l_def_ipyv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_ipyv_rec := fill_who_columns(l_def_ipyv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_ipyv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      --l_return_status := Validate_Record(l_def_ipyv_rec, l_db_ipyv_rec);
      l_return_status := Validate_Record(l_def_ipyv_rec);
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
        p_ipyv_rec                     => p_ipyv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_ipyv_rec, l_ipy_rec);
      migrate(l_def_ipyv_rec, l_okl_ins_policies_tl_rec);
      -----------------------------------------------
      -- Call the UPDATE_ROW for each child record --
      -----------------------------------------------
      update_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_ipy_rec,
        lx_ipy_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_ipy_rec, l_def_ipyv_rec);
      update_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_policies_tl_rec,
        lx_okl_ins_policies_tl_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_okl_ins_policies_tl_rec, l_def_ipyv_rec);
      x_ipyv_rec := l_def_ipyv_rec;
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
    -- PL/SQL TBL update_row for:ipyv_tbl --
    ----------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type,
      x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
        LOOP
          DECLARE
            l_error_rec         OKL_API.ERROR_REC_TYPE;
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
              p_ipyv_rec                     => p_ipyv_tbl(i),
              x_ipyv_rec                     => x_ipyv_tbl(i));
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
          EXIT WHEN (i = p_ipyv_tbl.LAST);
          i := p_ipyv_tbl.NEXT(i);
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
    -- PL/SQL TBL update_row for:IPYV_TBL --
    ----------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type,
      x_ipyv_tbl                     OUT NOCOPY ipyv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ipyv_tbl                     => p_ipyv_tbl,
          x_ipyv_tbl                     => x_ipyv_tbl,
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
    ---------------------------------------
    -- delete_row for:OKL_INS_POLICIES_B --
    ---------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipy_rec                      IN ipy_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipy_rec                      ipy_rec_type := p_ipy_rec;
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
      DELETE FROM OKL_INS_POLICIES_B
       WHERE ID = p_ipy_rec.id;
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
    ----------------------------------------
    -- delete_row for:OKL_INS_POLICIES_TL --
    ----------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_policies_tl_rec      IN okl_ins_policies_tl_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type := p_okl_ins_policies_tl_rec;
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
      DELETE FROM OKL_INS_POLICIES_TL
       WHERE ID = p_okl_ins_policies_tl_rec.id;
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
    -- delete_row for:OKL_INS_POLICIES_V --
    ---------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_rec                     IN ipyv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_ipyv_rec                     ipyv_rec_type := p_ipyv_rec;
      l_okl_ins_policies_tl_rec      okl_ins_policies_tl_rec_type;
      l_ipy_rec                      ipy_rec_type;
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
      migrate(l_ipyv_rec, l_okl_ins_policies_tl_rec);
      migrate(l_ipyv_rec, l_ipy_rec);
      -----------------------------------------------
      -- Call the DELETE_ROW for each child record --
      -----------------------------------------------
      delete_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_policies_tl_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      delete_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_ipy_rec
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
    -- PL/SQL TBL delete_row for:OKL_INS_POLICIES_V --
    --------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        i := p_ipyv_tbl.FIRST;
        LOOP
          DECLARE
            l_error_rec         OKL_API.ERROR_REC_TYPE;
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
              p_ipyv_rec                     => p_ipyv_tbl(i));
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
          EXIT WHEN (i = p_ipyv_tbl.LAST);
          i := p_ipyv_tbl.NEXT(i);
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
    -- PL/SQL TBL delete_row for:OKL_INS_POLICIES_V --
    --------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_ipyv_tbl                     IN ipyv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_ipyv_tbl.COUNT > 0) THEN
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ipyv_tbl                     => p_ipyv_tbl,
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
  END OKL_IPY_PVT;

/
