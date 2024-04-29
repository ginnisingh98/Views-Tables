--------------------------------------------------------
--  DDL for Package Body OKS_BPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BPE_PVT" AS
/* $Header: OKSSBPEB.pls 120.1 2005/10/05 03:27:29 mchoudha noship $ */
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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKS_BILLING_PROFILES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKS_BILLING_PROFILES_B B
         WHERE B.ID =T.ID
        );

    UPDATE OKS_BILLING_PROFILES_TL T SET(
        DESCRIPTION,
        INSTRUCTIONS,
        MESSAGE) = (SELECT
                                  B.DESCRIPTION,
                                  B.INSTRUCTIONS,
                                  B.MESSAGE
                                FROM OKS_BILLING_PROFILES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKS_BILLING_PROFILES_TL SUBB, OKS_BILLING_PROFILES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.INSTRUCTIONS <> SUBT.INSTRUCTIONS
                      OR SUBB.MESSAGE <> SUBT.MESSAGE
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
                      OR (SUBB.INSTRUCTIONS IS NULL AND SUBT.INSTRUCTIONS IS NOT NULL)
                      OR (SUBB.MESSAGE IS NULL AND SUBT.MESSAGE IS NOT NULL)
              ));

    INSERT INTO OKS_BILLING_PROFILES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        DESCRIPTION,
        INSTRUCTIONS,
        MESSAGE,
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
            B.INSTRUCTIONS,
            B.MESSAGE,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKS_BILLING_PROFILES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKS_BILLING_PROFILES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BILLING_PROFILES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bpev_rec                     IN bpev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bpev_rec_type IS
    CURSOR okc_bpev_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            MDA_CODE,
            OWNED_PARTY_ID1,
            OWNED_PARTY_ID2,
            DEPENDENT_CUST_ACCT_ID1,
            DEPENDENT_CUST_ACCT_ID2,
            BILL_TO_ADDRESS_ID1,
            BILL_TO_ADDRESS_ID2,
            UOM_CODE_FREQUENCY,
            TCE_CODE_FREQUENCY,
            UOM_CODE_SEC_OFFSET,
            TCE_CODE_SEC_OFFSET,
            UOM_CODE_PRI_OFFSET,
            TCE_CODE_PRI_OFFSET,
            PROFILE_NUMBER,
            SUMMARISED_YN,
            REG_INVOICE_PRI_OFFSET,
            REG_INVOICE_SEC_OFFSET,
            FIRST_BILLTO_DATE,
            FIRST_INVOICE_DATE,
            MESSAGE,
            DESCRIPTION,
            INSTRUCTIONS,
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
            INVOICE_OBJECT1_ID1,
            INVOICE_OBJECT1_ID2,
            INVOICE_JTOT_OBJECT1_CODE,
            ACCOUNT_OBJECT1_ID1,
            ACCOUNT_OBJECT1_ID2,
            ACCOUNT_JTOT_OBJECT1_CODE,
            BILLING_LEVEL,
            BILLING_TYPE,
            INTERVAL,
            INTERFACE_OFFSET,
            INVOICE_OFFSET
      FROM Oks_Billing_Profiles_V
     WHERE oks_billing_profiles_v.id = p_id;
    l_okc_bpev_pk                  okc_bpev_pk_csr%ROWTYPE;
    l_bpev_rec                     bpev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_bpev_pk_csr (p_bpev_rec.id);
    FETCH okc_bpev_pk_csr INTO
              l_bpev_rec.id,
              l_bpev_rec.object_version_number,
              l_bpev_rec.sfwt_flag,
              l_bpev_rec.mda_code,
              l_bpev_rec.owned_party_id1,
              l_bpev_rec.owned_party_id2,
              l_bpev_rec.dependent_cust_acct_id1,
              l_bpev_rec.dependent_cust_acct_id2,
              l_bpev_rec.bill_to_address_id1,
              l_bpev_rec.bill_to_address_id2,
              l_bpev_rec.uom_code_frequency,
              l_bpev_rec.tce_code_frequency,
              l_bpev_rec.uom_code_sec_offset,
              l_bpev_rec.tce_code_sec_offset,
              l_bpev_rec.uom_code_pri_offset,
              l_bpev_rec.tce_code_pri_offset,
              l_bpev_rec.profile_number,
              l_bpev_rec.summarised_yn,
              l_bpev_rec.reg_invoice_pri_offset,
              l_bpev_rec.reg_invoice_sec_offset,
              l_bpev_rec.first_billto_date,
              l_bpev_rec.first_invoice_date,
              l_bpev_rec.message,
              l_bpev_rec.description,
              l_bpev_rec.instructions,
              l_bpev_rec.attribute_category,
              l_bpev_rec.attribute1,
              l_bpev_rec.attribute2,
              l_bpev_rec.attribute3,
              l_bpev_rec.attribute4,
              l_bpev_rec.attribute5,
              l_bpev_rec.attribute6,
              l_bpev_rec.attribute7,
              l_bpev_rec.attribute8,
              l_bpev_rec.attribute9,
              l_bpev_rec.attribute10,
              l_bpev_rec.attribute11,
              l_bpev_rec.attribute12,
              l_bpev_rec.attribute13,
              l_bpev_rec.attribute14,
              l_bpev_rec.attribute15,
              l_bpev_rec.created_by,
              l_bpev_rec.creation_date,
              l_bpev_rec.last_updated_by,
              l_bpev_rec.last_update_date,
              l_bpev_rec.last_update_login,
              l_bpev_rec.invoice_object1_id1,
              l_bpev_rec.invoice_object1_id2,
              l_bpev_rec.invoice_jtot_object1_code,
              l_bpev_rec.account_object1_id1,
              l_bpev_rec.account_object1_id2,
              l_bpev_rec.account_jtot_object1_code,
              l_bpev_rec.billing_level,
              l_bpev_rec.billing_type,
              l_bpev_rec.interval,
              l_bpev_rec.interface_offset,
              l_bpev_rec.invoice_offset;
    x_no_data_found := okc_bpev_pk_csr%NOTFOUND;
    CLOSE okc_bpev_pk_csr;
    RETURN(l_bpev_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_bpev_rec                     IN bpev_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN bpev_rec_type IS
    l_bpev_rec                     bpev_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec := get_rec(p_bpev_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_bpev_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_bpev_rec                     IN bpev_rec_type
  ) RETURN bpev_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bpev_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BILLING_PROFILES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bpe_rec                      IN bpe_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bpe_rec_type IS
    CURSOR oks_billing_profiles_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            MDA_CODE,
            OWNED_PARTY_ID1,
            OWNED_PARTY_ID2,
            DEPENDENT_CUST_ACCT_ID1,
            DEPENDENT_CUST_ACCT_ID2,
            BILL_TO_ADDRESS_ID1,
            BILL_TO_ADDRESS_ID2,
            UOM_CODE_FREQUENCY,
            TCE_CODE_FREQUENCY,
            UOM_CODE_SEC_OFFSET,
            TCE_CODE_SEC_OFFSET,
            UOM_CODE_PRI_OFFSET,
            TCE_CODE_PRI_OFFSET,
            PROFILE_NUMBER,
            SUMMARISED_YN,
            REG_INVOICE_PRI_OFFSET,
            REG_INVOICE_SEC_OFFSET,
            FIRST_BILLTO_DATE,
            FIRST_INVOICE_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
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
            INVOICE_OBJECT1_ID1,
            INVOICE_OBJECT1_ID2,
            INVOICE_JTOT_OBJECT1_CODE,
            ACCOUNT_OBJECT1_ID1,
            ACCOUNT_OBJECT1_ID2,
            ACCOUNT_JTOT_OBJECT1_CODE,
            BILLING_LEVEL,
            BILLING_TYPE,
            INTERVAL,
            INTERFACE_OFFSET,
            INVOICE_OFFSET
      FROM Oks_Billing_Profiles_B
     WHERE oks_billing_profiles_b.id = p_id;
    l_oks_billing_profiles_b_pk    oks_billing_profiles_b_pk_csr%ROWTYPE;
    l_bpe_rec                      bpe_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_billing_profiles_b_pk_csr (p_bpe_rec.id);
    FETCH oks_billing_profiles_b_pk_csr INTO
              l_bpe_rec.id,
              l_bpe_rec.mda_code,
              l_bpe_rec.owned_party_id1,
              l_bpe_rec.owned_party_id2,
              l_bpe_rec.dependent_cust_acct_id1,
              l_bpe_rec.dependent_cust_acct_id2,
              l_bpe_rec.bill_to_address_id1,
              l_bpe_rec.bill_to_address_id2,
              l_bpe_rec.uom_code_frequency,
              l_bpe_rec.tce_code_frequency,
              l_bpe_rec.uom_code_sec_offset,
              l_bpe_rec.tce_code_sec_offset,
              l_bpe_rec.uom_code_pri_offset,
              l_bpe_rec.tce_code_pri_offset,
              l_bpe_rec.profile_number,
              l_bpe_rec.summarised_yn,
              l_bpe_rec.reg_invoice_pri_offset,
              l_bpe_rec.reg_invoice_sec_offset,
              l_bpe_rec.first_billto_date,
              l_bpe_rec.first_invoice_date,
              l_bpe_rec.object_version_number,
              l_bpe_rec.created_by,
              l_bpe_rec.creation_date,
              l_bpe_rec.last_updated_by,
              l_bpe_rec.last_update_date,
              l_bpe_rec.last_update_login,
              l_bpe_rec.attribute_category,
              l_bpe_rec.attribute1,
              l_bpe_rec.attribute2,
              l_bpe_rec.attribute3,
              l_bpe_rec.attribute4,
              l_bpe_rec.attribute5,
              l_bpe_rec.attribute6,
              l_bpe_rec.attribute7,
              l_bpe_rec.attribute8,
              l_bpe_rec.attribute9,
              l_bpe_rec.attribute10,
              l_bpe_rec.attribute11,
              l_bpe_rec.attribute12,
              l_bpe_rec.attribute13,
              l_bpe_rec.attribute14,
              l_bpe_rec.attribute15,
              l_bpe_rec.invoice_object1_id1,
              l_bpe_rec.invoice_object1_id2,
              l_bpe_rec.invoice_jtot_object1_code,
              l_bpe_rec.account_object1_id1,
              l_bpe_rec.account_object1_id2,
              l_bpe_rec.account_jtot_object1_code,
              l_bpe_rec.billing_level,
              l_bpe_rec.billing_type,
              l_bpe_rec.interval,
              l_bpe_rec.interface_offset,
              l_bpe_rec.invoice_offset;
    x_no_data_found := oks_billing_profiles_b_pk_csr%NOTFOUND;
    CLOSE oks_billing_profiles_b_pk_csr;
    RETURN(l_bpe_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_bpe_rec                      IN bpe_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN bpe_rec_type IS
    l_bpe_rec                      bpe_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_bpe_rec := get_rec(p_bpe_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_bpe_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_bpe_rec                      IN bpe_rec_type
  ) RETURN bpe_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bpe_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_BILLING_PROFILES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_bpt_rec                      IN bpt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN bpt_rec_type IS
    CURSOR oks_billing_profiles_tl_pk_csr (p_id       IN NUMBER,
                                           p_language IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            DESCRIPTION,
            INSTRUCTIONS,
            MESSAGE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_Billing_Profiles_Tl
     WHERE oks_billing_profiles_tl.id = p_id
       AND oks_billing_profiles_tl.language = p_language;
    l_oks_billing_profiles_tl_pk   oks_billing_profiles_tl_pk_csr%ROWTYPE;
    l_bpt_rec                      bpt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_billing_profiles_tl_pk_csr (p_bpt_rec.id,
                                         p_bpt_rec.language);
    FETCH oks_billing_profiles_tl_pk_csr INTO
              l_bpt_rec.id,
              l_bpt_rec.language,
              l_bpt_rec.source_lang,
              l_bpt_rec.sfwt_flag,
              l_bpt_rec.description,
              l_bpt_rec.instructions,
              l_bpt_rec.message,
              l_bpt_rec.created_by,
              l_bpt_rec.creation_date,
              l_bpt_rec.last_updated_by,
              l_bpt_rec.last_update_date,
              l_bpt_rec.last_update_login;
    x_no_data_found := oks_billing_profiles_tl_pk_csr%NOTFOUND;
    CLOSE oks_billing_profiles_tl_pk_csr;
    RETURN(l_bpt_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_bpt_rec                      IN bpt_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN bpt_rec_type IS
    l_bpt_rec                      bpt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_bpt_rec := get_rec(p_bpt_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_bpt_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_bpt_rec                      IN bpt_rec_type
  ) RETURN bpt_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_bpt_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_BILLING_PROFILES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_bpev_rec   IN bpev_rec_type
  ) RETURN bpev_rec_type IS
    l_bpev_rec                     bpev_rec_type := p_bpev_rec;
  BEGIN
    IF (l_bpev_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.id := NULL;
    END IF;
    IF (l_bpev_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.object_version_number := NULL;
    END IF;
    IF (l_bpev_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.sfwt_flag := NULL;
    END IF;
    IF (l_bpev_rec.mda_code = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.mda_code := NULL;
    END IF;
    IF (l_bpev_rec.owned_party_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.owned_party_id1 := NULL;
    END IF;
    IF (l_bpev_rec.owned_party_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.owned_party_id2 := NULL;
    END IF;
    IF (l_bpev_rec.dependent_cust_acct_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.dependent_cust_acct_id1 := NULL;
    END IF;
    IF (l_bpev_rec.dependent_cust_acct_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.dependent_cust_acct_id2 := NULL;
    END IF;
    IF (l_bpev_rec.bill_to_address_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.bill_to_address_id1 := NULL;
    END IF;
    IF (l_bpev_rec.bill_to_address_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.bill_to_address_id2 := NULL;
    END IF;
    IF (l_bpev_rec.uom_code_frequency = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.uom_code_frequency := NULL;
    END IF;
    IF (l_bpev_rec.tce_code_frequency = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.tce_code_frequency := NULL;
    END IF;
    IF (l_bpev_rec.uom_code_sec_offset = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.uom_code_sec_offset := NULL;
    END IF;
    IF (l_bpev_rec.tce_code_sec_offset = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.tce_code_sec_offset := NULL;
    END IF;
    IF (l_bpev_rec.uom_code_pri_offset = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.uom_code_pri_offset := NULL;
    END IF;
    IF (l_bpev_rec.tce_code_pri_offset = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.tce_code_pri_offset := NULL;
    END IF;
    IF (l_bpev_rec.profile_number = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.profile_number := NULL;
    END IF;
    IF (l_bpev_rec.summarised_yn = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.summarised_yn := NULL;
    END IF;
    IF (l_bpev_rec.reg_invoice_pri_offset = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.reg_invoice_pri_offset := NULL;
    END IF;
    IF (l_bpev_rec.reg_invoice_sec_offset = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.reg_invoice_sec_offset := NULL;
    END IF;
    IF (l_bpev_rec.first_billto_date = OKC_API.G_MISS_DATE ) THEN
      l_bpev_rec.first_billto_date := NULL;
    END IF;
    IF (l_bpev_rec.first_invoice_date = OKC_API.G_MISS_DATE ) THEN
      l_bpev_rec.first_invoice_date := NULL;
    END IF;
    IF (l_bpev_rec.message = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.message := NULL;
    END IF;
    IF (l_bpev_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.description := NULL;
    END IF;
    IF (l_bpev_rec.instructions = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.instructions := NULL;
    END IF;
    IF (l_bpev_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute_category := NULL;
    END IF;
    IF (l_bpev_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute1 := NULL;
    END IF;
    IF (l_bpev_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute2 := NULL;
    END IF;
    IF (l_bpev_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute3 := NULL;
    END IF;
    IF (l_bpev_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute4 := NULL;
    END IF;
    IF (l_bpev_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute5 := NULL;
    END IF;
    IF (l_bpev_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute6 := NULL;
    END IF;
    IF (l_bpev_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute7 := NULL;
    END IF;
    IF (l_bpev_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute8 := NULL;
    END IF;
    IF (l_bpev_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute9 := NULL;
    END IF;
    IF (l_bpev_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute10 := NULL;
    END IF;
    IF (l_bpev_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute11 := NULL;
    END IF;
    IF (l_bpev_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute12 := NULL;
    END IF;
    IF (l_bpev_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute13 := NULL;
    END IF;
    IF (l_bpev_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute14 := NULL;
    END IF;
    IF (l_bpev_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.attribute15 := NULL;
    END IF;
    IF (l_bpev_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.created_by := NULL;
    END IF;
    IF (l_bpev_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_bpev_rec.creation_date := NULL;
    END IF;
    IF (l_bpev_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.last_updated_by := NULL;
    END IF;
    IF (l_bpev_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_bpev_rec.last_update_date := NULL;
    END IF;
    IF (l_bpev_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.last_update_login := NULL;
    END IF;
    IF (l_bpev_rec.invoice_object1_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.invoice_object1_id1 := NULL;
    END IF;
    IF (l_bpev_rec.invoice_object1_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.invoice_object1_id2 := NULL;
    END IF;
    IF (l_bpev_rec.invoice_jtot_object1_code = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.invoice_jtot_object1_code := NULL;
    END IF;
    IF (l_bpev_rec.account_object1_id1 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.account_object1_id1 := NULL;
    END IF;
    IF (l_bpev_rec.account_object1_id2 = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.account_object1_id2 := NULL;
    END IF;
    IF (l_bpev_rec.account_jtot_object1_code = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.account_jtot_object1_code := NULL;
    END IF;
    IF (l_bpev_rec.billing_level = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.billing_level := NULL;
    END IF;
    IF (l_bpev_rec.billing_type = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.billing_type := NULL;
    END IF;
    IF (l_bpev_rec.interval = OKC_API.G_MISS_CHAR ) THEN
      l_bpev_rec.interval := NULL;
    END IF;
    IF (l_bpev_rec.interface_offset = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.interface_offset := NULL;
    END IF;
    IF (l_bpev_rec.invoice_offset = OKC_API.G_MISS_NUM ) THEN
      l_bpev_rec.invoice_offset := NULL;
    END IF;
    RETURN(l_bpev_rec);
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
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sfwt_flag                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_sfwt_flag = OKC_API.G_MISS_CHAR OR
        p_sfwt_flag IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
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
  END validate_sfwt_flag;
  ---------------------------------------
  -- Validate_Attributes for: MDA_CODE --
  ---------------------------------------
  PROCEDURE validate_mda_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_mda_code                     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_mda_code = OKC_API.G_MISS_CHAR OR
        p_mda_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'mda_code');
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
  END validate_mda_code;
  --------------------------------------------------
  -- Validate_Attributes for: TCE_CODE_PRI_OFFSET --
  --------------------------------------------------
  PROCEDURE validate_tce_code_pri_offset(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_tce_code_pri_offset          IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_tce_code_pri_offset = OKC_API.G_MISS_CHAR OR
        p_tce_code_pri_offset IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'tce_code_pri_offset');
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
  END validate_tce_code_pri_offset;
  ---------------------------------------------
  -- Validate_Attributes for: PROFILE_NUMBER --
  ---------------------------------------------
  PROCEDURE validate_profile_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_profile_number               IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_profile_number = OKC_API.G_MISS_CHAR OR
        p_profile_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'profile_number');
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
  END validate_profile_number;
  --------------------------------------------
  -- Validate_Attributes for: SUMMARISED_YN --
  --------------------------------------------
  PROCEDURE validate_summarised_yn(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_summarised_yn                IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_summarised_yn = OKC_API.G_MISS_CHAR OR
        p_summarised_yn IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'summarised_yn');
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
  END validate_summarised_yn;
  ------------------------------------------
  -- Validate_Attributes for: DESCRIPTION --
  ------------------------------------------
  PROCEDURE validate_description(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_description                  IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_description = OKC_API.G_MISS_CHAR OR
        p_description IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'description');
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
  END validate_description;

     ---------------------------------
  -- Validate_Attributes for: billing_type -- Added for auto renewal
  ---------------------------------
  PROCEDURE validate_billing_type(
    x_return_status             OUT NOCOPY VARCHAR2,
    p_bill_type                 IN VARCHAR2) IS


    CURSOR get_bill_type IS
    select lookup_code bill_type
    from fnd_lookups
    where lookup_type = 'OKS_BILLING_TYPE';

    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;


    IF (p_bill_type  <> OKC_API.G_MISS_CHAR AND
        p_bill_type IS NOT NULL)
    THEN
        l_return_status := 'U';
        For bill_type_rec in get_bill_type Loop
            IF (bill_type_rec.bill_type = p_bill_type) Then
                  l_return_status := OKC_API.G_RET_STS_SUCCESS;
                  Exit;
            End If;
        End Loop;
        If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,
                                G_COL_NAME_TOKEN, 'BILLING_TYPE');
            x_return_status := OKC_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
    End If;

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
 END validate_billing_type;


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKS_BILLING_PROFILES_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_bpev_rec                     IN bpev_rec_type
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
    validate_id(x_return_status, p_bpev_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_bpev_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(x_return_status, p_bpev_rec.sfwt_flag);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- mda_code
    -- ***
    /*
    validate_mda_code(x_return_status, p_bpev_rec.mda_code);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- tce_code_pri_offset
    -- ***
    validate_tce_code_pri_offset(x_return_status, p_bpev_rec.tce_code_pri_offset);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
   */
    -- ***
    -- profile_number
    -- ***
    validate_profile_number(x_return_status, p_bpev_rec.profile_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- summarised_yn
    -- ***
    validate_summarised_yn(x_return_status, p_bpev_rec.summarised_yn);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- description
    -- ***
    validate_description(x_return_status, p_bpev_rec.description);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- billing_type
    -- ***
    validate_billing_type(x_return_status, p_bpev_rec.billing_type);
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
  -- Validate Record for:OKS_BILLING_PROFILES_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_bpev_rec IN bpev_rec_type,
    p_db_bpev_rec IN bpev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_bpev_rec IN bpev_rec_type,
      p_db_bpev_rec IN bpev_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okx_customer_account_v_pk_csr (p_id1 IN NUMBER,
                                            p_id2 IN VARCHAR2) IS
      SELECT 'x'
        FROM Okx_Customer_Accounts_V
       WHERE okx_customer_accounts_v.id1 = p_id1
         AND okx_customer_accounts_v.id2 = p_id2;
      l_okx_customer_account_v_pk    okx_customer_account_v_pk_csr%ROWTYPE;

      CURSOR okc_tcuv_pk_csr (p_tce_code IN VARCHAR2,
                              p_uom_code IN VARCHAR2) IS
      SELECT 'x'
        FROM Okc_Time_Code_Units_V
       WHERE okc_time_code_units_v.tce_code = p_tce_code
         AND okc_time_code_units_v.uom_code = p_uom_code;
      l_okc_tcuv_pk                  okc_tcuv_pk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (((p_bpev_rec.TCE_CODE_FREQUENCY IS NOT NULL) AND
           (p_bpev_rec.UOM_CODE_FREQUENCY IS NOT NULL))
       AND
          ((p_bpev_rec.TCE_CODE_FREQUENCY <> p_db_bpev_rec.TCE_CODE_FREQUENCY) OR
           (p_bpev_rec.UOM_CODE_FREQUENCY <> p_db_bpev_rec.UOM_CODE_FREQUENCY)))
      THEN
        OPEN okc_tcuv_pk_csr (p_bpev_rec.TCE_CODE_FREQUENCY,
                              p_bpev_rec.UOM_CODE_FREQUENCY);
        FETCH okc_tcuv_pk_csr INTO l_okc_tcuv_pk;
        l_row_notfound := okc_tcuv_pk_csr%NOTFOUND;
        CLOSE okc_tcuv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'TCE_CODE_FREQUENCY');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'UOM_CODE_FREQUENCY');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (((p_bpev_rec.DEPENDENT_CUST_ACCT_ID1 IS NOT NULL) AND
           (p_bpev_rec.DEPENDENT_CUST_ACCT_ID2 IS NOT NULL))
       AND
          ((p_bpev_rec.DEPENDENT_CUST_ACCT_ID1 <> p_db_bpev_rec.DEPENDENT_CUST_ACCT_ID1) OR
           (p_bpev_rec.DEPENDENT_CUST_ACCT_ID2 <> p_db_bpev_rec.DEPENDENT_CUST_ACCT_ID2)))
      THEN
        OPEN okx_customer_account_v_pk_csr (p_bpev_rec.DEPENDENT_CUST_ACCT_ID1,
                                            p_bpev_rec.DEPENDENT_CUST_ACCT_ID2);
        FETCH okx_customer_account_v_pk_csr INTO l_okx_customer_account_v_pk;
        l_row_notfound := okx_customer_account_v_pk_csr%NOTFOUND;
        CLOSE okx_customer_account_v_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DEPENDENT_CUST_ACCT_ID1');
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DEPENDENT_CUST_ACCT_ID2');
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
    l_return_status := validate_foreign_keys(p_bpev_rec, p_db_bpev_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_bpev_rec IN bpev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_bpev_rec                  bpev_rec_type := get_rec(p_bpev_rec);
  BEGIN
    l_return_status := Validate_Record(p_bpev_rec => p_bpev_rec,
                                       p_db_bpev_rec => l_db_bpev_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN bpev_rec_type,
    p_to   IN OUT NOCOPY bpe_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.mda_code := p_from.mda_code;
    p_to.owned_party_id1 := p_from.owned_party_id1;
    p_to.owned_party_id2 := p_from.owned_party_id2;
    p_to.dependent_cust_acct_id1 := p_from.dependent_cust_acct_id1;
    p_to.dependent_cust_acct_id2 := p_from.dependent_cust_acct_id2;
    p_to.bill_to_address_id1 := p_from.bill_to_address_id1;
    p_to.bill_to_address_id2 := p_from.bill_to_address_id2;
    p_to.uom_code_frequency := p_from.uom_code_frequency;
    p_to.tce_code_frequency := p_from.tce_code_frequency;
    p_to.uom_code_sec_offset := p_from.uom_code_sec_offset;
    p_to.tce_code_sec_offset := p_from.tce_code_sec_offset;
    p_to.uom_code_pri_offset := p_from.uom_code_pri_offset;
    p_to.tce_code_pri_offset := p_from.tce_code_pri_offset;
    p_to.profile_number := p_from.profile_number;
    p_to.summarised_yn := p_from.summarised_yn;
    p_to.reg_invoice_pri_offset := p_from.reg_invoice_pri_offset;
    p_to.reg_invoice_sec_offset := p_from.reg_invoice_sec_offset;
    p_to.first_billto_date := p_from.first_billto_date;
    p_to.first_invoice_date := p_from.first_invoice_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
    p_to.invoice_object1_id1 := p_from.invoice_object1_id1;
    p_to.invoice_object1_id2 := p_from.invoice_object1_id2;
    p_to.invoice_jtot_object1_code := p_from.invoice_jtot_object1_code;
    p_to.account_object1_id1 := p_from.account_object1_id1;
    p_to.account_object1_id2 := p_from.account_object1_id2;
    p_to.account_jtot_object1_code := p_from.account_jtot_object1_code;
    p_to.billing_level := p_from.billing_level;
    p_to.billing_type := p_from.billing_type;
    p_to.interval := p_from.interval;
    p_to.interface_offset := p_from.interface_offset;
    p_to.invoice_offset := p_from.invoice_offset;
  END migrate;
  PROCEDURE migrate (
    p_from IN bpe_rec_type,
    p_to   IN OUT NOCOPY bpev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.mda_code := p_from.mda_code;
    p_to.owned_party_id1 := p_from.owned_party_id1;
    p_to.owned_party_id2 := p_from.owned_party_id2;
    p_to.dependent_cust_acct_id1 := p_from.dependent_cust_acct_id1;
    p_to.dependent_cust_acct_id2 := p_from.dependent_cust_acct_id2;
    p_to.bill_to_address_id1 := p_from.bill_to_address_id1;
    p_to.bill_to_address_id2 := p_from.bill_to_address_id2;
    p_to.uom_code_frequency := p_from.uom_code_frequency;
    p_to.tce_code_frequency := p_from.tce_code_frequency;
    p_to.uom_code_sec_offset := p_from.uom_code_sec_offset;
    p_to.tce_code_sec_offset := p_from.tce_code_sec_offset;
    p_to.uom_code_pri_offset := p_from.uom_code_pri_offset;
    p_to.tce_code_pri_offset := p_from.tce_code_pri_offset;
    p_to.profile_number := p_from.profile_number;
    p_to.summarised_yn := p_from.summarised_yn;
    p_to.reg_invoice_pri_offset := p_from.reg_invoice_pri_offset;
    p_to.reg_invoice_sec_offset := p_from.reg_invoice_sec_offset;
    p_to.first_billto_date := p_from.first_billto_date;
    p_to.first_invoice_date := p_from.first_invoice_date;
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
    p_to.invoice_object1_id1 := p_from.invoice_object1_id1;
    p_to.invoice_object1_id2 := p_from.invoice_object1_id2;
    p_to.invoice_jtot_object1_code := p_from.invoice_jtot_object1_code;
    p_to.account_object1_id1 := p_from.account_object1_id1;
    p_to.account_object1_id2 := p_from.account_object1_id2;
    p_to.account_jtot_object1_code := p_from.account_jtot_object1_code;
    p_to.billing_level := p_from.billing_level;
    p_to.billing_type := p_from.billing_type;
    p_to.interval := p_from.interval;
    p_to.interface_offset := p_from.interface_offset;
    p_to.invoice_offset := p_from.invoice_offset;
  END migrate;
  PROCEDURE migrate (
    p_from IN bpev_rec_type,
    p_to   IN OUT NOCOPY bpt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.description := p_from.description;
    p_to.instructions := p_from.instructions;
    p_to.message := p_from.message;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN bpt_rec_type,
    p_to   IN OUT NOCOPY bpev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.message := p_from.message;
    p_to.description := p_from.description;
    p_to.instructions := p_from.instructions;
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
  -- validate_row for:OKS_BILLING_PROFILES_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec                     bpev_rec_type := p_bpev_rec;
    l_bpe_rec                      bpe_rec_type;
    l_bpt_rec                      bpt_rec_type;
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
    l_return_status := Validate_Attributes(l_bpev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_bpev_rec);
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
  -- PL/SQL TBL validate_row for:OKS_BILLING_PROFILES_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      i := p_bpev_tbl.FIRST;
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
            p_bpev_rec                     => p_bpev_tbl(i));
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
        EXIT WHEN (i = p_bpev_tbl.LAST);
        i := p_bpev_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKS_BILLING_PROFILES_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_bpev_tbl                     => p_bpev_tbl,
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
  -------------------------------------------
  -- insert_row for:OKS_BILLING_PROFILES_B --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpe_rec                      IN bpe_rec_type,
    x_bpe_rec                      OUT NOCOPY bpe_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpe_rec                      bpe_rec_type := p_bpe_rec;
    l_def_bpe_rec                  bpe_rec_type;
    -----------------------------------------------
    -- Set_Attributes for:OKS_BILLING_PROFILES_B --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_bpe_rec IN bpe_rec_type,
      x_bpe_rec OUT NOCOPY bpe_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpe_rec := p_bpe_rec;
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
      p_bpe_rec,                         -- IN
      l_bpe_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_BILLING_PROFILES_B(
      id,
      mda_code,
      owned_party_id1,
      owned_party_id2,
      dependent_cust_acct_id1,
      dependent_cust_acct_id2,
      bill_to_address_id1,
      bill_to_address_id2,
      uom_code_frequency,
      tce_code_frequency,
      uom_code_sec_offset,
      tce_code_sec_offset,
      uom_code_pri_offset,
      tce_code_pri_offset,
      profile_number,
      summarised_yn,
      reg_invoice_pri_offset,
      reg_invoice_sec_offset,
      first_billto_date,
      first_invoice_date,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
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
      invoice_object1_id1,
      invoice_object1_id2,
      invoice_jtot_object1_code,
      account_object1_id1,
      account_object1_id2,
      account_jtot_object1_code,
      billing_level,
      billing_type,
      interval,
      interface_offset,
      invoice_offset)
    VALUES (
      l_bpe_rec.id,
      l_bpe_rec.mda_code,
      l_bpe_rec.owned_party_id1,
      l_bpe_rec.owned_party_id2,
      l_bpe_rec.dependent_cust_acct_id1,
      l_bpe_rec.dependent_cust_acct_id2,
      l_bpe_rec.bill_to_address_id1,
      l_bpe_rec.bill_to_address_id2,
      l_bpe_rec.uom_code_frequency,
      l_bpe_rec.tce_code_frequency,
      l_bpe_rec.uom_code_sec_offset,
      l_bpe_rec.tce_code_sec_offset,
      l_bpe_rec.uom_code_pri_offset,
      l_bpe_rec.tce_code_pri_offset,
      l_bpe_rec.profile_number,
      l_bpe_rec.summarised_yn,
      l_bpe_rec.reg_invoice_pri_offset,
      l_bpe_rec.reg_invoice_sec_offset,
      l_bpe_rec.first_billto_date,
      l_bpe_rec.first_invoice_date,
      l_bpe_rec.object_version_number,
      l_bpe_rec.created_by,
      l_bpe_rec.creation_date,
      l_bpe_rec.last_updated_by,
      l_bpe_rec.last_update_date,
      l_bpe_rec.last_update_login,
      l_bpe_rec.attribute_category,
      l_bpe_rec.attribute1,
      l_bpe_rec.attribute2,
      l_bpe_rec.attribute3,
      l_bpe_rec.attribute4,
      l_bpe_rec.attribute5,
      l_bpe_rec.attribute6,
      l_bpe_rec.attribute7,
      l_bpe_rec.attribute8,
      l_bpe_rec.attribute9,
      l_bpe_rec.attribute10,
      l_bpe_rec.attribute11,
      l_bpe_rec.attribute12,
      l_bpe_rec.attribute13,
      l_bpe_rec.attribute14,
      l_bpe_rec.attribute15,
      l_bpe_rec.invoice_object1_id1,
      l_bpe_rec.invoice_object1_id2,
      l_bpe_rec.invoice_jtot_object1_code,
      l_bpe_rec.account_object1_id1,
      l_bpe_rec.account_object1_id2,
      l_bpe_rec.account_jtot_object1_code,
      l_bpe_rec.billing_level,
      l_bpe_rec.billing_type,
      l_bpe_rec.interval,
      l_bpe_rec.interface_offset,
      l_bpe_rec.invoice_offset);
    -- Set OUT values
    x_bpe_rec := l_bpe_rec;
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
  -- insert_row for:OKS_BILLING_PROFILES_TL --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpt_rec                      IN bpt_rec_type,
    x_bpt_rec                      OUT NOCOPY bpt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpt_rec                      bpt_rec_type := p_bpt_rec;
    l_def_bpt_rec                  bpt_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ------------------------------------------------
    -- Set_Attributes for:OKS_BILLING_PROFILES_TL --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_bpt_rec IN bpt_rec_type,
      x_bpt_rec OUT NOCOPY bpt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpt_rec := p_bpt_rec;
      x_bpt_rec.LANGUAGE := USERENV('LANG');
      x_bpt_rec.SOURCE_LANG := USERENV('LANG');
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
      p_bpt_rec,                         -- IN
      l_bpt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_bpt_rec.language := l_lang_rec.language_code;
      INSERT INTO OKS_BILLING_PROFILES_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        description,
        instructions,
        message,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_bpt_rec.id,
        l_bpt_rec.language,
        l_bpt_rec.source_lang,
        l_bpt_rec.sfwt_flag,
        l_bpt_rec.description,
        l_bpt_rec.instructions,
        l_bpt_rec.message,
        l_bpt_rec.created_by,
        l_bpt_rec.creation_date,
        l_bpt_rec.last_updated_by,
        l_bpt_rec.last_update_date,
        l_bpt_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_bpt_rec := l_bpt_rec;
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
  -- insert_row for :OKS_BILLING_PROFILES_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec                     bpev_rec_type := p_bpev_rec;
    l_def_bpev_rec                 bpev_rec_type;
    l_bpe_rec                      bpe_rec_type;
    lx_bpe_rec                     bpe_rec_type;
    l_bpt_rec                      bpt_rec_type;
    lx_bpt_rec                     bpt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bpev_rec IN bpev_rec_type
    ) RETURN bpev_rec_type IS
      l_bpev_rec bpev_rec_type := p_bpev_rec;
    BEGIN
      l_bpev_rec.CREATION_DATE := SYSDATE;
      l_bpev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_bpev_rec.LAST_UPDATE_DATE := l_bpev_rec.CREATION_DATE;
      l_bpev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bpev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bpev_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKS_BILLING_PROFILES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_bpev_rec IN bpev_rec_type,
      x_bpev_rec OUT NOCOPY bpev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpev_rec := p_bpev_rec;
      x_bpev_rec.OBJECT_VERSION_NUMBER := 1;
      x_bpev_rec.SFWT_FLAG := 'N';
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
    l_bpev_rec := null_out_defaults(p_bpev_rec);
    -- Set primary key value
    l_bpev_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_bpev_rec,                        -- IN
      l_def_bpev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bpev_rec := fill_who_columns(l_def_bpev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bpev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bpev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_bpev_rec, l_bpe_rec);
    migrate(l_def_bpev_rec, l_bpt_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_bpe_rec,
      lx_bpe_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bpe_rec, l_def_bpev_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_bpt_rec,
      lx_bpt_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bpt_rec, l_def_bpev_rec);
    -- Set OUT values
    x_bpev_rec := l_def_bpev_rec;
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
  -- PL/SQL TBL insert_row for:BPEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      i := p_bpev_tbl.FIRST;
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
            p_bpev_rec                     => p_bpev_tbl(i),
            x_bpev_rec                     => x_bpev_tbl(i));
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
        EXIT WHEN (i = p_bpev_tbl.LAST);
        i := p_bpev_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:BPEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_bpev_tbl                     => p_bpev_tbl,
        x_bpev_tbl                     => x_bpev_tbl,
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
  -----------------------------------------
  -- lock_row for:OKS_BILLING_PROFILES_B --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpe_rec                      IN bpe_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_bpe_rec IN bpe_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILLING_PROFILES_B
     WHERE ID = p_bpe_rec.id
       AND OBJECT_VERSION_NUMBER = p_bpe_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_bpe_rec IN bpe_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_BILLING_PROFILES_B
     WHERE ID = p_bpe_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_BILLING_PROFILES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_BILLING_PROFILES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_bpe_rec);
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
      OPEN lchk_csr(p_bpe_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_bpe_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_bpe_rec.object_version_number THEN
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
  -- lock_row for:OKS_BILLING_PROFILES_TL --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpt_rec                      IN bpt_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_bpt_rec IN bpt_rec_type) IS
    SELECT *
      FROM OKS_BILLING_PROFILES_TL
     WHERE ID = p_bpt_rec.id
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
      OPEN lock_csr(p_bpt_rec);
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
  ------------------------------------------
  -- lock_row for: OKS_BILLING_PROFILES_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpe_rec                      bpe_rec_type;
    l_bpt_rec                      bpt_rec_type;
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
    migrate(p_bpev_rec, l_bpe_rec);
    migrate(p_bpev_rec, l_bpt_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_bpe_rec
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
      l_bpt_rec
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
  -- PL/SQL TBL lock_row for:BPEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      i := p_bpev_tbl.FIRST;
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
            p_bpev_rec                     => p_bpev_tbl(i));
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
        EXIT WHEN (i = p_bpev_tbl.LAST);
        i := p_bpev_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:BPEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_bpev_tbl                     => p_bpev_tbl,
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
  -------------------------------------------
  -- update_row for:OKS_BILLING_PROFILES_B --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpe_rec                      IN bpe_rec_type,
    x_bpe_rec                      OUT NOCOPY bpe_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpe_rec                      bpe_rec_type := p_bpe_rec;
    l_def_bpe_rec                  bpe_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bpe_rec IN bpe_rec_type,
      x_bpe_rec OUT NOCOPY bpe_rec_type
    ) RETURN VARCHAR2 IS
      l_bpe_rec                      bpe_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpe_rec := p_bpe_rec;
      -- Get current database values
      l_bpe_rec := get_rec(p_bpe_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_bpe_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.id := l_bpe_rec.id;
        END IF;
        IF (x_bpe_rec.mda_code = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.mda_code := l_bpe_rec.mda_code;
        END IF;
        IF (x_bpe_rec.owned_party_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.owned_party_id1 := l_bpe_rec.owned_party_id1;
        END IF;
        IF (x_bpe_rec.owned_party_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.owned_party_id2 := l_bpe_rec.owned_party_id2;
        END IF;
        IF (x_bpe_rec.dependent_cust_acct_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.dependent_cust_acct_id1 := l_bpe_rec.dependent_cust_acct_id1;
        END IF;
        IF (x_bpe_rec.dependent_cust_acct_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.dependent_cust_acct_id2 := l_bpe_rec.dependent_cust_acct_id2;
        END IF;
        IF (x_bpe_rec.bill_to_address_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.bill_to_address_id1 := l_bpe_rec.bill_to_address_id1;
        END IF;
        IF (x_bpe_rec.bill_to_address_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.bill_to_address_id2 := l_bpe_rec.bill_to_address_id2;
        END IF;
        IF (x_bpe_rec.uom_code_frequency = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.uom_code_frequency := l_bpe_rec.uom_code_frequency;
        END IF;
        IF (x_bpe_rec.tce_code_frequency = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.tce_code_frequency := l_bpe_rec.tce_code_frequency;
        END IF;
        IF (x_bpe_rec.uom_code_sec_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.uom_code_sec_offset := l_bpe_rec.uom_code_sec_offset;
        END IF;
        IF (x_bpe_rec.tce_code_sec_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.tce_code_sec_offset := l_bpe_rec.tce_code_sec_offset;
        END IF;
        IF (x_bpe_rec.uom_code_pri_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.uom_code_pri_offset := l_bpe_rec.uom_code_pri_offset;
        END IF;
        IF (x_bpe_rec.tce_code_pri_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.tce_code_pri_offset := l_bpe_rec.tce_code_pri_offset;
        END IF;
        IF (x_bpe_rec.profile_number = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.profile_number := l_bpe_rec.profile_number;
        END IF;
        IF (x_bpe_rec.summarised_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.summarised_yn := l_bpe_rec.summarised_yn;
        END IF;
        IF (x_bpe_rec.reg_invoice_pri_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.reg_invoice_pri_offset := l_bpe_rec.reg_invoice_pri_offset;
        END IF;
        IF (x_bpe_rec.reg_invoice_sec_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.reg_invoice_sec_offset := l_bpe_rec.reg_invoice_sec_offset;
        END IF;
        IF (x_bpe_rec.first_billto_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpe_rec.first_billto_date := l_bpe_rec.first_billto_date;
        END IF;
        IF (x_bpe_rec.first_invoice_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpe_rec.first_invoice_date := l_bpe_rec.first_invoice_date;
        END IF;
        IF (x_bpe_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.object_version_number := l_bpe_rec.object_version_number;
        END IF;
        IF (x_bpe_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.created_by := l_bpe_rec.created_by;
        END IF;
        IF (x_bpe_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpe_rec.creation_date := l_bpe_rec.creation_date;
        END IF;
        IF (x_bpe_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.last_updated_by := l_bpe_rec.last_updated_by;
        END IF;
        IF (x_bpe_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpe_rec.last_update_date := l_bpe_rec.last_update_date;
        END IF;
        IF (x_bpe_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.last_update_login := l_bpe_rec.last_update_login;
        END IF;
        IF (x_bpe_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute_category := l_bpe_rec.attribute_category;
        END IF;
        IF (x_bpe_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute1 := l_bpe_rec.attribute1;
        END IF;
        IF (x_bpe_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute2 := l_bpe_rec.attribute2;
        END IF;
        IF (x_bpe_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute3 := l_bpe_rec.attribute3;
        END IF;
        IF (x_bpe_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute4 := l_bpe_rec.attribute4;
        END IF;
        IF (x_bpe_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute5 := l_bpe_rec.attribute5;
        END IF;
        IF (x_bpe_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute6 := l_bpe_rec.attribute6;
        END IF;
        IF (x_bpe_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute7 := l_bpe_rec.attribute7;
        END IF;
        IF (x_bpe_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute8 := l_bpe_rec.attribute8;
        END IF;
        IF (x_bpe_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute9 := l_bpe_rec.attribute9;
        END IF;
        IF (x_bpe_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute10 := l_bpe_rec.attribute10;
        END IF;
        IF (x_bpe_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute11 := l_bpe_rec.attribute11;
        END IF;
        IF (x_bpe_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute12 := l_bpe_rec.attribute12;
        END IF;
        IF (x_bpe_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute13 := l_bpe_rec.attribute13;
        END IF;
        IF (x_bpe_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute14 := l_bpe_rec.attribute14;
        END IF;
        IF (x_bpe_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.attribute15 := l_bpe_rec.attribute15;
        END IF;
        IF (x_bpe_rec.invoice_object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.invoice_object1_id1 := l_bpe_rec.invoice_object1_id1;
        END IF;
        IF (x_bpe_rec.invoice_object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.invoice_object1_id2 := l_bpe_rec.invoice_object1_id2;
        END IF;
        IF (x_bpe_rec.invoice_jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.invoice_jtot_object1_code := l_bpe_rec.invoice_jtot_object1_code;
        END IF;
        IF (x_bpe_rec.account_object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.account_object1_id1 := l_bpe_rec.account_object1_id1;
        END IF;
        IF (x_bpe_rec.account_object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.account_object1_id2 := l_bpe_rec.account_object1_id2;
        END IF;
        IF (x_bpe_rec.account_jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.account_jtot_object1_code := l_bpe_rec.account_jtot_object1_code;
        END IF;
        IF (x_bpe_rec.billing_level = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.billing_level := l_bpe_rec.billing_level;
        END IF;
        IF (x_bpe_rec.billing_type = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.billing_type := l_bpe_rec.billing_type;
        END IF;
        IF (x_bpe_rec.interval = OKC_API.G_MISS_CHAR)
        THEN
          x_bpe_rec.interval := l_bpe_rec.interval;
        END IF;
        IF (x_bpe_rec.interface_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.interface_offset := l_bpe_rec.interface_offset;
        END IF;
        IF (x_bpe_rec.invoice_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpe_rec.invoice_offset := l_bpe_rec.invoice_offset;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKS_BILLING_PROFILES_B --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_bpe_rec IN bpe_rec_type,
      x_bpe_rec OUT NOCOPY bpe_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpe_rec := p_bpe_rec;
      x_bpe_rec.OBJECT_VERSION_NUMBER := p_bpe_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_bpe_rec,                         -- IN
      l_bpe_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bpe_rec, l_def_bpe_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_BILLING_PROFILES_B
    SET MDA_CODE = l_def_bpe_rec.mda_code,
        OWNED_PARTY_ID1 = l_def_bpe_rec.owned_party_id1,
        OWNED_PARTY_ID2 = l_def_bpe_rec.owned_party_id2,
        DEPENDENT_CUST_ACCT_ID1 = l_def_bpe_rec.dependent_cust_acct_id1,
        DEPENDENT_CUST_ACCT_ID2 = l_def_bpe_rec.dependent_cust_acct_id2,
        BILL_TO_ADDRESS_ID1 = l_def_bpe_rec.bill_to_address_id1,
        BILL_TO_ADDRESS_ID2 = l_def_bpe_rec.bill_to_address_id2,
        UOM_CODE_FREQUENCY = l_def_bpe_rec.uom_code_frequency,
        TCE_CODE_FREQUENCY = l_def_bpe_rec.tce_code_frequency,
        UOM_CODE_SEC_OFFSET = l_def_bpe_rec.uom_code_sec_offset,
        TCE_CODE_SEC_OFFSET = l_def_bpe_rec.tce_code_sec_offset,
        UOM_CODE_PRI_OFFSET = l_def_bpe_rec.uom_code_pri_offset,
        TCE_CODE_PRI_OFFSET = l_def_bpe_rec.tce_code_pri_offset,
        PROFILE_NUMBER = l_def_bpe_rec.profile_number,
        SUMMARISED_YN = l_def_bpe_rec.summarised_yn,
        REG_INVOICE_PRI_OFFSET = l_def_bpe_rec.reg_invoice_pri_offset,
        REG_INVOICE_SEC_OFFSET = l_def_bpe_rec.reg_invoice_sec_offset,
        FIRST_BILLTO_DATE = l_def_bpe_rec.first_billto_date,
        FIRST_INVOICE_DATE = l_def_bpe_rec.first_invoice_date,
        OBJECT_VERSION_NUMBER = l_def_bpe_rec.object_version_number,
        CREATED_BY = l_def_bpe_rec.created_by,
        CREATION_DATE = l_def_bpe_rec.creation_date,
        LAST_UPDATED_BY = l_def_bpe_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_bpe_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_bpe_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_bpe_rec.attribute_category,
        ATTRIBUTE1 = l_def_bpe_rec.attribute1,
        ATTRIBUTE2 = l_def_bpe_rec.attribute2,
        ATTRIBUTE3 = l_def_bpe_rec.attribute3,
        ATTRIBUTE4 = l_def_bpe_rec.attribute4,
        ATTRIBUTE5 = l_def_bpe_rec.attribute5,
        ATTRIBUTE6 = l_def_bpe_rec.attribute6,
        ATTRIBUTE7 = l_def_bpe_rec.attribute7,
        ATTRIBUTE8 = l_def_bpe_rec.attribute8,
        ATTRIBUTE9 = l_def_bpe_rec.attribute9,
        ATTRIBUTE10 = l_def_bpe_rec.attribute10,
        ATTRIBUTE11 = l_def_bpe_rec.attribute11,
        ATTRIBUTE12 = l_def_bpe_rec.attribute12,
        ATTRIBUTE13 = l_def_bpe_rec.attribute13,
        ATTRIBUTE14 = l_def_bpe_rec.attribute14,
        ATTRIBUTE15 = l_def_bpe_rec.attribute15,
        INVOICE_OBJECT1_ID1 = l_def_bpe_rec.invoice_object1_id1,
        INVOICE_OBJECT1_ID2 = l_def_bpe_rec.invoice_object1_id2,
        INVOICE_JTOT_OBJECT1_CODE = l_def_bpe_rec.invoice_jtot_object1_code,
        ACCOUNT_OBJECT1_ID1 = l_def_bpe_rec.account_object1_id1,
        ACCOUNT_OBJECT1_ID2 = l_def_bpe_rec.account_object1_id2,
        ACCOUNT_JTOT_OBJECT1_CODE = l_def_bpe_rec.account_jtot_object1_code,
        BILLING_LEVEL = l_def_bpe_rec.billing_level,
        BILLING_TYPE = l_def_bpe_rec.billing_type,
        INTERVAL = l_def_bpe_rec.interval,
        INTERFACE_OFFSET = l_def_bpe_rec.interface_offset,
        INVOICE_OFFSET = l_def_bpe_rec.invoice_offset
    WHERE ID = l_def_bpe_rec.id;

    x_bpe_rec := l_bpe_rec;
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
  --------------------------------------------
  -- update_row for:OKS_BILLING_PROFILES_TL --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpt_rec                      IN bpt_rec_type,
    x_bpt_rec                      OUT NOCOPY bpt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpt_rec                      bpt_rec_type := p_bpt_rec;
    l_def_bpt_rec                  bpt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bpt_rec IN bpt_rec_type,
      x_bpt_rec OUT NOCOPY bpt_rec_type
    ) RETURN VARCHAR2 IS
      l_bpt_rec                      bpt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpt_rec := p_bpt_rec;
      -- Get current database values
      l_bpt_rec := get_rec(p_bpt_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_bpt_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_bpt_rec.id := l_bpt_rec.id;
        END IF;
        IF (x_bpt_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_bpt_rec.language := l_bpt_rec.language;
        END IF;
        IF (x_bpt_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_bpt_rec.source_lang := l_bpt_rec.source_lang;
        END IF;
        IF (x_bpt_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_bpt_rec.sfwt_flag := l_bpt_rec.sfwt_flag;
        END IF;
        IF (x_bpt_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_bpt_rec.description := l_bpt_rec.description;
        END IF;
        IF (x_bpt_rec.instructions = OKC_API.G_MISS_CHAR)
        THEN
          x_bpt_rec.instructions := l_bpt_rec.instructions;
        END IF;
        IF (x_bpt_rec.message = OKC_API.G_MISS_CHAR)
        THEN
          x_bpt_rec.message := l_bpt_rec.message;
        END IF;
        IF (x_bpt_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_bpt_rec.created_by := l_bpt_rec.created_by;
        END IF;
        IF (x_bpt_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpt_rec.creation_date := l_bpt_rec.creation_date;
        END IF;
        IF (x_bpt_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_bpt_rec.last_updated_by := l_bpt_rec.last_updated_by;
        END IF;
        IF (x_bpt_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpt_rec.last_update_date := l_bpt_rec.last_update_date;
        END IF;
        IF (x_bpt_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_bpt_rec.last_update_login := l_bpt_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKS_BILLING_PROFILES_TL --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_bpt_rec IN bpt_rec_type,
      x_bpt_rec OUT NOCOPY bpt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpt_rec := p_bpt_rec;
      x_bpt_rec.LANGUAGE := USERENV('LANG');
      x_bpt_rec.LANGUAGE := USERENV('LANG');
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
      p_bpt_rec,                         -- IN
      l_bpt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bpt_rec, l_def_bpt_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_BILLING_PROFILES_TL
    SET DESCRIPTION = l_def_bpt_rec.description,
        INSTRUCTIONS = l_def_bpt_rec.instructions,
        MESSAGE = l_def_bpt_rec.message,
        CREATED_BY = l_def_bpt_rec.created_by,
        CREATION_DATE = l_def_bpt_rec.creation_date,
        LAST_UPDATED_BY = l_def_bpt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_bpt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_bpt_rec.last_update_login
    WHERE ID = l_def_bpt_rec.id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKS_BILLING_PROFILES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_bpt_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_bpt_rec := l_bpt_rec;
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
  -- update_row for:OKS_BILLING_PROFILES_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type,
    x_bpev_rec                     OUT NOCOPY bpev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec                     bpev_rec_type := p_bpev_rec;
    l_def_bpev_rec                 bpev_rec_type;
    l_db_bpev_rec                  bpev_rec_type;
    l_bpe_rec                      bpe_rec_type;
    lx_bpe_rec                     bpe_rec_type;
    l_bpt_rec                      bpt_rec_type;
    lx_bpt_rec                     bpt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_bpev_rec IN bpev_rec_type
    ) RETURN bpev_rec_type IS
      l_bpev_rec bpev_rec_type := p_bpev_rec;
    BEGIN
      l_bpev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_bpev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_bpev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_bpev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_bpev_rec IN bpev_rec_type,
      x_bpev_rec OUT NOCOPY bpev_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpev_rec := p_bpev_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_bpev_rec := get_rec(p_bpev_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_bpev_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.id := l_db_bpev_rec.id;
        END IF;
        IF (x_bpev_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.sfwt_flag := l_db_bpev_rec.sfwt_flag;
        END IF;
        IF (x_bpev_rec.mda_code = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.mda_code := l_db_bpev_rec.mda_code;
        END IF;
        IF (x_bpev_rec.owned_party_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.owned_party_id1 := l_db_bpev_rec.owned_party_id1;
        END IF;
        IF (x_bpev_rec.owned_party_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.owned_party_id2 := l_db_bpev_rec.owned_party_id2;
        END IF;
        IF (x_bpev_rec.dependent_cust_acct_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.dependent_cust_acct_id1 := l_db_bpev_rec.dependent_cust_acct_id1;
        END IF;
        IF (x_bpev_rec.dependent_cust_acct_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.dependent_cust_acct_id2 := l_db_bpev_rec.dependent_cust_acct_id2;
        END IF;
        IF (x_bpev_rec.bill_to_address_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.bill_to_address_id1 := l_db_bpev_rec.bill_to_address_id1;
        END IF;
        IF (x_bpev_rec.bill_to_address_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.bill_to_address_id2 := l_db_bpev_rec.bill_to_address_id2;
        END IF;
        IF (x_bpev_rec.uom_code_frequency = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.uom_code_frequency := l_db_bpev_rec.uom_code_frequency;
        END IF;
        IF (x_bpev_rec.tce_code_frequency = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.tce_code_frequency := l_db_bpev_rec.tce_code_frequency;
        END IF;
        IF (x_bpev_rec.uom_code_sec_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.uom_code_sec_offset := l_db_bpev_rec.uom_code_sec_offset;
        END IF;
        IF (x_bpev_rec.tce_code_sec_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.tce_code_sec_offset := l_db_bpev_rec.tce_code_sec_offset;
        END IF;
        IF (x_bpev_rec.uom_code_pri_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.uom_code_pri_offset := l_db_bpev_rec.uom_code_pri_offset;
        END IF;
        IF (x_bpev_rec.tce_code_pri_offset = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.tce_code_pri_offset := l_db_bpev_rec.tce_code_pri_offset;
        END IF;
        IF (x_bpev_rec.profile_number = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.profile_number := l_db_bpev_rec.profile_number;
        END IF;
        IF (x_bpev_rec.summarised_yn = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.summarised_yn := l_db_bpev_rec.summarised_yn;
        END IF;
        IF (x_bpev_rec.reg_invoice_pri_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.reg_invoice_pri_offset := l_db_bpev_rec.reg_invoice_pri_offset;
        END IF;
        IF (x_bpev_rec.reg_invoice_sec_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.reg_invoice_sec_offset := l_db_bpev_rec.reg_invoice_sec_offset;
        END IF;
        IF (x_bpev_rec.first_billto_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpev_rec.first_billto_date := l_db_bpev_rec.first_billto_date;
        END IF;
        IF (x_bpev_rec.first_invoice_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpev_rec.first_invoice_date := l_db_bpev_rec.first_invoice_date;
        END IF;
        IF (x_bpev_rec.message = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.message := l_db_bpev_rec.message;
        END IF;
        IF (x_bpev_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.description := l_db_bpev_rec.description;
        END IF;
        IF (x_bpev_rec.instructions = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.instructions := l_db_bpev_rec.instructions;
        END IF;
        IF (x_bpev_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute_category := l_db_bpev_rec.attribute_category;
        END IF;
        IF (x_bpev_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute1 := l_db_bpev_rec.attribute1;
        END IF;
        IF (x_bpev_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute2 := l_db_bpev_rec.attribute2;
        END IF;
        IF (x_bpev_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute3 := l_db_bpev_rec.attribute3;
        END IF;
        IF (x_bpev_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute4 := l_db_bpev_rec.attribute4;
        END IF;
        IF (x_bpev_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute5 := l_db_bpev_rec.attribute5;
        END IF;
        IF (x_bpev_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute6 := l_db_bpev_rec.attribute6;
        END IF;
        IF (x_bpev_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute7 := l_db_bpev_rec.attribute7;
        END IF;
        IF (x_bpev_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute8 := l_db_bpev_rec.attribute8;
        END IF;
        IF (x_bpev_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute9 := l_db_bpev_rec.attribute9;
        END IF;
        IF (x_bpev_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute10 := l_db_bpev_rec.attribute10;
        END IF;
        IF (x_bpev_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute11 := l_db_bpev_rec.attribute11;
        END IF;
        IF (x_bpev_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute12 := l_db_bpev_rec.attribute12;
        END IF;
        IF (x_bpev_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute13 := l_db_bpev_rec.attribute13;
        END IF;
        IF (x_bpev_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute14 := l_db_bpev_rec.attribute14;
        END IF;
        IF (x_bpev_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.attribute15 := l_db_bpev_rec.attribute15;
        END IF;
        IF (x_bpev_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.created_by := l_db_bpev_rec.created_by;
        END IF;
        IF (x_bpev_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpev_rec.creation_date := l_db_bpev_rec.creation_date;
        END IF;
        IF (x_bpev_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.last_updated_by := l_db_bpev_rec.last_updated_by;
        END IF;
        IF (x_bpev_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_bpev_rec.last_update_date := l_db_bpev_rec.last_update_date;
        END IF;
        IF (x_bpev_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.last_update_login := l_db_bpev_rec.last_update_login;
        END IF;
        IF (x_bpev_rec.invoice_object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.invoice_object1_id1 := l_db_bpev_rec.invoice_object1_id1;
        END IF;
        IF (x_bpev_rec.invoice_object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.invoice_object1_id2 := l_db_bpev_rec.invoice_object1_id2;
        END IF;
        IF (x_bpev_rec.invoice_jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.invoice_jtot_object1_code := l_db_bpev_rec.invoice_jtot_object1_code;
        END IF;
        IF (x_bpev_rec.account_object1_id1 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.account_object1_id1 := l_db_bpev_rec.account_object1_id1;
        END IF;
        IF (x_bpev_rec.account_object1_id2 = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.account_object1_id2 := l_db_bpev_rec.account_object1_id2;
        END IF;
        IF (x_bpev_rec.account_jtot_object1_code = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.account_jtot_object1_code := l_db_bpev_rec.account_jtot_object1_code;
        END IF;
        IF (x_bpev_rec.billing_level = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.billing_level := l_db_bpev_rec.billing_level;
        END IF;
        IF (x_bpev_rec.billing_type = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.billing_type := l_db_bpev_rec.billing_type;
        END IF;
        IF (x_bpev_rec.interval = OKC_API.G_MISS_CHAR)
        THEN
          x_bpev_rec.interval := l_db_bpev_rec.interval;
        END IF;
        IF (x_bpev_rec.interface_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.interface_offset := l_db_bpev_rec.interface_offset;
        END IF;
        IF (x_bpev_rec.invoice_offset = OKC_API.G_MISS_NUM)
        THEN
          x_bpev_rec.invoice_offset := l_db_bpev_rec.invoice_offset;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKS_BILLING_PROFILES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_bpev_rec IN bpev_rec_type,
      x_bpev_rec OUT NOCOPY bpev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_bpev_rec := p_bpev_rec;
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
      p_bpev_rec,                        -- IN
      x_bpev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_bpev_rec, l_def_bpev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_bpev_rec := fill_who_columns(l_def_bpev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_bpev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_bpev_rec, l_db_bpev_rec);
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
      p_bpev_rec                     => p_bpev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_bpev_rec, l_bpe_rec);
    migrate(l_def_bpev_rec, l_bpt_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_bpe_rec,
      lx_bpe_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bpe_rec, l_def_bpev_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_bpt_rec,
      lx_bpt_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_bpt_rec, l_def_bpev_rec);
    x_bpev_rec := l_def_bpev_rec;
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
  -- PL/SQL TBL update_row for:bpev_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      i := p_bpev_tbl.FIRST;
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
            p_bpev_rec                     => p_bpev_tbl(i),
            x_bpev_rec                     => x_bpev_tbl(i));
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
        EXIT WHEN (i = p_bpev_tbl.LAST);
        i := p_bpev_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:BPEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    x_bpev_tbl                     OUT NOCOPY bpev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_bpev_tbl                     => p_bpev_tbl,
        x_bpev_tbl                     => x_bpev_tbl,
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
  -------------------------------------------
  -- delete_row for:OKS_BILLING_PROFILES_B --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpe_rec                      IN bpe_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpe_rec                      bpe_rec_type := p_bpe_rec;
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

    DELETE FROM OKS_BILLING_PROFILES_B
     WHERE ID = p_bpe_rec.id;

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
  --------------------------------------------
  -- delete_row for:OKS_BILLING_PROFILES_TL --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpt_rec                      IN bpt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpt_rec                      bpt_rec_type := p_bpt_rec;
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

    DELETE FROM OKS_BILLING_PROFILES_TL
     WHERE ID = p_bpt_rec.id;

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
  -- delete_row for:OKS_BILLING_PROFILES_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_rec                     IN bpev_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_bpev_rec                     bpev_rec_type := p_bpev_rec;
    l_bpt_rec                      bpt_rec_type;
    l_bpe_rec                      bpe_rec_type;
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
    migrate(l_bpev_rec, l_bpt_rec);
    migrate(l_bpev_rec, l_bpe_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_bpt_rec
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
      l_bpe_rec
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
  -- PL/SQL TBL delete_row for:OKS_BILLING_PROFILES_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      i := p_bpev_tbl.FIRST;
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
            p_bpev_rec                     => p_bpev_tbl(i));
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
        EXIT WHEN (i = p_bpev_tbl.LAST);
        i := p_bpev_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKS_BILLING_PROFILES_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_bpev_tbl                     IN bpev_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_bpev_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_bpev_tbl                     => p_bpev_tbl,
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

END OKS_BPE_PVT;

/
