--------------------------------------------------------
--  DDL for Package Body OKL_CLM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CLM_PVT" AS
/* $Header: OKLSCLMB.pls 120.5.12010000.2 2008/09/03 23:15:09 rmunjulu ship $ */
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
    --Smoduga added for inventory org fix 3348924
    -- FUNCTION get_inv_org_id
    ---------------------------------------------------------------------------
    FUNCTION get_inv_org_id(policy_id IN NUMBER) RETURN NUMBER IS
    cursor c_inv_org(p_id number) is
          select org_id
          from okl_ins_policies_b
          where id = p_id;
    l_inv_org_id NUMBER;
    BEGIN
       open c_inv_org(policy_id);
          fetch c_inv_org into l_inv_org_id;
         close c_inv_org;
      RETURN(l_inv_org_id);
    END get_inv_org_id;
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
      DELETE FROM OKL_INS_CLAIMS_TL T
       WHERE NOT EXISTS (
          SELECT NULL
            FROM OKL_INS_CLAIMS_ALL_B  B        --fixed bug 3321017 by kmotepal
           WHERE B.ID =T.ID
          );
      UPDATE OKL_INS_CLAIMS_TL T SET(
          DESCRIPTION,
          POLICE_REPORT,
          COMMENTS) = (SELECT
                                    B.DESCRIPTION,
                                    B.POLICE_REPORT,
                                    B.COMMENTS
                                  FROM OKL_INS_CLAIMS_TL B
                                 WHERE B.ID = T.ID
                                   AND B.LANGUAGE = T.SOURCE_LANG)
        WHERE ( T.ID,
                T.LANGUAGE)
            IN (SELECT
                    SUBT.ID,
                    SUBT.LANGUAGE
                  FROM OKL_INS_CLAIMS_TL SUBB, OKL_INS_CLAIMS_TL SUBT
                 WHERE SUBB.ID = SUBT.ID
                   AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                   AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                        OR SUBB.POLICE_REPORT <> SUBT.POLICE_REPORT
                        OR SUBB.COMMENTS <> SUBT.COMMENTS
                        OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                        OR (SUBB.POLICE_REPORT IS NULL AND SUBT.POLICE_REPORT IS NOT NULL)
                        OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                ));
      INSERT INTO OKL_INS_CLAIMS_TL (
          ID,
          LANGUAGE,
          DESCRIPTION,
          POLICE_REPORT,
          COMMENTS,
          SOURCE_LANG,
          SFWT_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
        SELECT
              B.ID,
              L.LANGUAGE_CODE,
              B.DESCRIPTION,
              B.POLICE_REPORT,
              B.COMMENTS,
              B.SOURCE_LANG,
              B.SFWT_FLAG,
              B.CREATED_BY,
              B.CREATION_DATE,
              B.LAST_UPDATED_BY,
              B.LAST_UPDATE_DATE,
              B.LAST_UPDATE_LOGIN
          FROM OKL_INS_CLAIMS_TL B, FND_LANGUAGES L
         WHERE L.INSTALLED_FLAG IN ('I', 'B')
           AND B.LANGUAGE = USERENV('LANG')
           AND NOT EXISTS (
                      SELECT NULL
                        FROM OKL_INS_CLAIMS_TL T
                       WHERE T.ID = B.ID
                         AND T.LANGUAGE = L.LANGUAGE_CODE
                      );
    END add_language;
    ---------------------------------------------------------------------------
    -- FUNCTION get_rec for: OKL_INS_CLAIMS_V
    ---------------------------------------------------------------------------
    FUNCTION get_rec (
      p_clmv_rec                     IN clmv_rec_type,
      x_no_data_found                OUT NOCOPY BOOLEAN
    ) RETURN clmv_rec_type IS
      CURSOR okl_clmv_pk_csr (p_id IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              IPY_ID,
              LTP_CODE,
              CSU_CODE,
              CLAIM_NUMBER,
              CLAIM_DATE,
              LOSS_DATE,
              DESCRIPTION,
              POLICE_CONTACT,
              POLICE_REPORT,
              AMOUNT,
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
              HOLD_DATE,
              ORG_ID,
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
              PROGRAM_ID,
              PROGRAM_UPDATE_DATE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okl_Ins_Claims_V
       WHERE okl_ins_claims_v.id  = p_id;
      l_okl_clmv_pk                  okl_clmv_pk_csr%ROWTYPE;
      l_clmv_rec                     clmv_rec_type;
    BEGIN
      x_no_data_found := TRUE;
      -- Get current database values
      OPEN okl_clmv_pk_csr (p_clmv_rec.id);
      FETCH okl_clmv_pk_csr INTO
                l_clmv_rec.id,
                l_clmv_rec.object_version_number,
                l_clmv_rec.sfwt_flag,
                l_clmv_rec.ipy_id,
                l_clmv_rec.ltp_code,
                l_clmv_rec.csu_code,
                l_clmv_rec.claim_number,
                l_clmv_rec.claim_date,
                l_clmv_rec.loss_date,
                l_clmv_rec.description,
                l_clmv_rec.police_contact,
                l_clmv_rec.police_report,
                l_clmv_rec.amount,
                l_clmv_rec.attribute_category,
                l_clmv_rec.attribute1,
                l_clmv_rec.attribute2,
                l_clmv_rec.attribute3,
                l_clmv_rec.attribute4,
                l_clmv_rec.attribute5,
                l_clmv_rec.attribute6,
                l_clmv_rec.attribute7,
                l_clmv_rec.attribute8,
                l_clmv_rec.attribute9,
                l_clmv_rec.attribute10,
                l_clmv_rec.attribute11,
                l_clmv_rec.attribute12,
                l_clmv_rec.attribute13,
                l_clmv_rec.attribute14,
                l_clmv_rec.attribute15,
                l_clmv_rec.hold_date,
                l_clmv_rec.org_id,
                l_clmv_rec.request_id,
                l_clmv_rec.program_application_id,
                l_clmv_rec.program_id,
                l_clmv_rec.program_update_date,
                l_clmv_rec.created_by,
                l_clmv_rec.creation_date,
                l_clmv_rec.last_updated_by,
                l_clmv_rec.last_update_date,
                l_clmv_rec.last_update_login;
      x_no_data_found := okl_clmv_pk_csr%NOTFOUND;
      CLOSE okl_clmv_pk_csr;
      RETURN(l_clmv_rec);
    END get_rec;
    ------------------------------------------------------------------
    -- This version of get_rec sets error messages if no data found --
    ------------------------------------------------------------------
    FUNCTION get_rec (
      p_clmv_rec                     IN clmv_rec_type,
      x_return_status                OUT NOCOPY VARCHAR2
    ) RETURN clmv_rec_type IS
      l_clmv_rec                     clmv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      l_clmv_rec := get_rec(p_clmv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      RETURN(l_clmv_rec);
    END get_rec;
    -----------------------------------------------------------
    -- So we don't have to pass an "l_row_notfound" variable --
    -----------------------------------------------------------
    FUNCTION get_rec (
      p_clmv_rec                     IN clmv_rec_type
    ) RETURN clmv_rec_type IS
      l_row_not_found                BOOLEAN := TRUE;
    BEGIN
      RETURN(get_rec(p_clmv_rec, l_row_not_found));
    END get_rec;
    ---------------------------------------------------------------------------
    -- FUNCTION get_rec for: OKL_INS_CLAIMS_B
    ---------------------------------------------------------------------------
    FUNCTION get_rec (
      p_clm_rec                      IN clm_rec_type,
      x_no_data_found                OUT NOCOPY BOOLEAN
    ) RETURN clm_rec_type IS
      CURSOR clm_pk_csr (p_id IN NUMBER) IS
      SELECT
              ID,
              CLAIM_NUMBER,
              CSU_CODE,
              IPY_ID,
              LTP_CODE,
              PROGRAM_UPDATE_DATE,
              CLAIM_DATE,
              PROGRAM_ID,
              LOSS_DATE,
              POLICE_CONTACT,
              AMOUNT,
              OBJECT_VERSION_NUMBER,
              REQUEST_ID,
              PROGRAM_APPLICATION_ID,
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
              HOLD_DATE,
              ORG_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okl_Ins_Claims_B
       WHERE okl_ins_claims_b.id  = p_id;
      l_clm_pk                       clm_pk_csr%ROWTYPE;
      l_clm_rec                      clm_rec_type;
    BEGIN
      x_no_data_found := TRUE;
      -- Get current database values
      OPEN clm_pk_csr (p_clm_rec.id);
      FETCH clm_pk_csr INTO
                l_clm_rec.id,
                l_clm_rec.claim_number,
                l_clm_rec.csu_code,
                l_clm_rec.ipy_id,
                l_clm_rec.ltp_code,
                l_clm_rec.program_update_date,
                l_clm_rec.claim_date,
                l_clm_rec.program_id,
                l_clm_rec.loss_date,
                l_clm_rec.police_contact,
                l_clm_rec.amount,
                l_clm_rec.object_version_number,
                l_clm_rec.request_id,
                l_clm_rec.program_application_id,
                l_clm_rec.attribute_category,
                l_clm_rec.attribute1,
                l_clm_rec.attribute2,
                l_clm_rec.attribute3,
                l_clm_rec.attribute4,
                l_clm_rec.attribute5,
                l_clm_rec.attribute6,
                l_clm_rec.attribute7,
                l_clm_rec.attribute8,
                l_clm_rec.attribute9,
                l_clm_rec.attribute10,
                l_clm_rec.attribute11,
                l_clm_rec.attribute12,
                l_clm_rec.attribute13,
                l_clm_rec.attribute14,
                l_clm_rec.attribute15,
                l_clm_rec.hold_date,
                l_clm_rec.org_id,
                l_clm_rec.created_by,
                l_clm_rec.creation_date,
                l_clm_rec.last_updated_by,
                l_clm_rec.last_update_date,
                l_clm_rec.last_update_login;
      x_no_data_found := clm_pk_csr%NOTFOUND;
      CLOSE clm_pk_csr;
      RETURN(l_clm_rec);
    END get_rec;
    ------------------------------------------------------------------
    -- This version of get_rec sets error messages if no data found --
    ------------------------------------------------------------------
    FUNCTION get_rec (
      p_clm_rec                      IN clm_rec_type,
      x_return_status                OUT NOCOPY VARCHAR2
    ) RETURN clm_rec_type IS
      l_clm_rec                      clm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      l_clm_rec := get_rec(p_clm_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      RETURN(l_clm_rec);
    END get_rec;
    -----------------------------------------------------------
    -- So we don't have to pass an "l_row_notfound" variable --
    -----------------------------------------------------------
    FUNCTION get_rec (
      p_clm_rec                      IN clm_rec_type
    ) RETURN clm_rec_type IS
      l_row_not_found                BOOLEAN := TRUE;
    BEGIN
      RETURN(get_rec(p_clm_rec, l_row_not_found));
    END get_rec;
    ---------------------------------------------------------------------------
    -- FUNCTION get_rec for: OKL_INS_CLAIMS_TL
    ---------------------------------------------------------------------------
    FUNCTION get_rec (
      p_okl_ins_claims_tl_rec        IN okl_ins_claims_tl_rec_type,
      x_no_data_found                OUT NOCOPY BOOLEAN
    ) RETURN okl_ins_claims_tl_rec_type IS
      CURSOR clmt_pk_csr (p_id       IN NUMBER,
                          p_language IN VARCHAR2) IS
      SELECT
              ID,
              LANGUAGE,
              DESCRIPTION,
              POLICE_REPORT,
              COMMENTS,
              SOURCE_LANG,
              SFWT_FLAG,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okl_Ins_Claims_Tl
       WHERE okl_ins_claims_tl.id = p_id
         AND okl_ins_claims_tl.language = p_language;
      l_clmt_pk                      clmt_pk_csr%ROWTYPE;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
    BEGIN
      x_no_data_found := TRUE;
      -- Get current database values
      OPEN clmt_pk_csr (p_okl_ins_claims_tl_rec.id,
                        p_okl_ins_claims_tl_rec.language);
      FETCH clmt_pk_csr INTO
                l_okl_ins_claims_tl_rec.id,
                l_okl_ins_claims_tl_rec.language,
                l_okl_ins_claims_tl_rec.description,
                l_okl_ins_claims_tl_rec.police_report,
                l_okl_ins_claims_tl_rec.comments,
                l_okl_ins_claims_tl_rec.source_lang,
                l_okl_ins_claims_tl_rec.sfwt_flag,
                l_okl_ins_claims_tl_rec.created_by,
                l_okl_ins_claims_tl_rec.creation_date,
                l_okl_ins_claims_tl_rec.last_updated_by,
                l_okl_ins_claims_tl_rec.last_update_date,
                l_okl_ins_claims_tl_rec.last_update_login;
      x_no_data_found := clmt_pk_csr%NOTFOUND;
      CLOSE clmt_pk_csr;
      RETURN(l_okl_ins_claims_tl_rec);
    END get_rec;
    ------------------------------------------------------------------
    -- This version of get_rec sets error messages if no data found --
    ------------------------------------------------------------------
    FUNCTION get_rec (
      p_okl_ins_claims_tl_rec        IN okl_ins_claims_tl_rec_type,
      x_return_status                OUT NOCOPY VARCHAR2
    ) RETURN okl_ins_claims_tl_rec_type IS
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_claims_tl_rec := get_rec(p_okl_ins_claims_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
        OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
      RETURN(l_okl_ins_claims_tl_rec);
    END get_rec;
    -----------------------------------------------------------
    -- So we don't have to pass an "l_row_notfound" variable --
    -----------------------------------------------------------
    FUNCTION get_rec (
      p_okl_ins_claims_tl_rec        IN okl_ins_claims_tl_rec_type
    ) RETURN okl_ins_claims_tl_rec_type IS
      l_row_not_found                BOOLEAN := TRUE;
    BEGIN
      RETURN(get_rec(p_okl_ins_claims_tl_rec, l_row_not_found));
    END get_rec;
    ---------------------------------------------------------------------------
    -- FUNCTION null_out_defaults for: OKL_INS_CLAIMS_V
    ---------------------------------------------------------------------------
    FUNCTION null_out_defaults (
      p_clmv_rec   IN clmv_rec_type
    ) RETURN clmv_rec_type IS
      l_clmv_rec                     clmv_rec_type := p_clmv_rec;
    BEGIN
      IF (l_clmv_rec.id = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.id := NULL;
      END IF;
      IF (l_clmv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.object_version_number := NULL;
      END IF;
      IF (l_clmv_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.sfwt_flag := NULL;
      END IF;
      IF (l_clmv_rec.ipy_id = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.ipy_id := NULL;
      END IF;
      IF (l_clmv_rec.ltp_code = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.ltp_code := NULL;
      END IF;
      IF (l_clmv_rec.csu_code = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.csu_code := NULL;
      END IF;
      IF (l_clmv_rec.claim_number = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.claim_number := NULL;
      END IF;
      IF (l_clmv_rec.claim_date = OKC_API.G_MISS_DATE ) THEN
        l_clmv_rec.claim_date := NULL;
      END IF;
      IF (l_clmv_rec.loss_date = OKC_API.G_MISS_DATE ) THEN
        l_clmv_rec.loss_date := NULL;
      END IF;
      IF (l_clmv_rec.description = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.description := NULL;
      END IF;
      IF (l_clmv_rec.police_contact = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.police_contact := NULL;
      END IF;
      IF (l_clmv_rec.police_report = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.police_report := NULL;
      END IF;
      IF (l_clmv_rec.amount = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.amount := NULL;
      END IF;
      IF (l_clmv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute_category := NULL;
      END IF;
      IF (l_clmv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute1 := NULL;
      END IF;
      IF (l_clmv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute2 := NULL;
      END IF;
      IF (l_clmv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute3 := NULL;
      END IF;
      IF (l_clmv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute4 := NULL;
      END IF;
      IF (l_clmv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute5 := NULL;
      END IF;
      IF (l_clmv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute6 := NULL;
      END IF;
      IF (l_clmv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute7 := NULL;
      END IF;
      IF (l_clmv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute8 := NULL;
      END IF;
      IF (l_clmv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute9 := NULL;
      END IF;
      IF (l_clmv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute10 := NULL;
      END IF;
      IF (l_clmv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute11 := NULL;
      END IF;
      IF (l_clmv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute12 := NULL;
      END IF;
      IF (l_clmv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute13 := NULL;
      END IF;
      IF (l_clmv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute14 := NULL;
      END IF;
      IF (l_clmv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
        l_clmv_rec.attribute15 := NULL;
      END IF;
      IF (l_clmv_rec.hold_date = OKC_API.G_MISS_DATE ) THEN
        l_clmv_rec.hold_date := NULL;
      END IF;
      IF (l_clmv_rec.org_id = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.org_id := NULL;
      END IF;
      IF (l_clmv_rec.request_id = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.request_id := NULL;
      END IF;
      IF (l_clmv_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.program_application_id := NULL;
      END IF;
      IF (l_clmv_rec.program_id = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.program_id := NULL;
      END IF;
      IF (l_clmv_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
        l_clmv_rec.program_update_date := NULL;
      END IF;
      IF (l_clmv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.created_by := NULL;
      END IF;
      IF (l_clmv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
        l_clmv_rec.creation_date := NULL;
      END IF;
      IF (l_clmv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.last_updated_by := NULL;
      END IF;
      IF (l_clmv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
        l_clmv_rec.last_update_date := NULL;
      END IF;
      IF (l_clmv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
        l_clmv_rec.last_update_login := NULL;
      END IF;
      RETURN(l_clmv_rec);
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
    -------------------------------------------
    -- Validate_Attributes for: CLAIM_NUMBER --
    -------------------------------------------
    PROCEDURE validate_claim_number(
      x_return_status                OUT NOCOPY VARCHAR2,
      p_claim_number                 IN VARCHAR2) IS
    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
      IF (p_claim_number = OKC_API.G_MISS_CHAR OR
          p_claim_number IS NULL)
      THEN
        OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Claim Number');
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
    END validate_claim_number;
    ----------------------------------------------------
    -- Validate_Attributes for: IPY_ID              --
    ----------------------------------------------------
      PROCEDURE validate_ipy_id(
      x_return_status   	OUT NOCOPY VARCHAR2,
      p_ipy_id       	IN NUMBER) IS
      l_dummy_var                    VARCHAR2(1) := '?';
      l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
      CURSOR okl_ipy_csr  IS
        SELECT 'x'
        FROM OKL_INS_POLICIES_V
        WHERE id = p_ipy_id;
     Begin
        IF ((p_ipy_id IS NOT NULL) AND (p_ipy_id = OKC_API.G_MISS_NUM))  THEN
  		-- enforce foreign key
             OPEN okl_ipy_csr;
  	   FETCH okl_ipy_csr INTO l_dummy_var;
             CLOSE okl_ipy_csr;
           -- if l_dummy_var is still set to default ,data was not found
           IF (l_dummy_var ='?') THEN
             OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                                 p_msg_name           => G_NO_PARENT_RECORD,
                                 p_token1             => G_COL_NAME_TOKEN,
                                 p_token1_value       => 'Policy ID',
                                 p_token2             => g_parent_table_token,
                                 p_token2_value       => 'OKL_INS_POLICIES_V',
                                 p_token3             => g_child_table_token,
                                 p_token3_value       => 'OKL_INS_CLAIMS_B');
            -- notify caller of an error
            l_return_status := OKC_API.G_RET_STS_ERROR;
            x_return_status := l_return_status;
          END IF;
        END IF;
      EXCEPTION
             WHEN OTHERS THEN
             -- store SQL error  message on message stack for caller
             Okc_Api.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
             -- Notify the caller of an unexpected error
               x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             -- Verify  that cursor was closed
                IF okl_ipy_csr%ISOPEN THEN
                      CLOSE okl_ipy_csr;
                END IF;
     END validate_ipy_id;
     ----------------------------------------------------
       -- Validate_Attributes for: csu_code              --
       ----------------------------------------------------
        PROCEDURE  validate_csu_code(x_return_status OUT NOCOPY VARCHAR2,p_clmv_rec IN clmv_rec_type ) IS
            l_dummy_var                    VARCHAR2(1) :='?';
             BEGIN
               --initialize the  return status
               x_return_status := Okc_Api.G_RET_STS_SUCCESS;
               --data is required
               IF p_clmv_rec.csu_code = Okc_Api.G_MISS_CHAR OR
                  p_clmv_rec.csu_code IS NULL
               THEN
                 Okc_Api.set_message(p_app_name       => G_APP_NAME,
                                     p_msg_name       => G_REQUIRED_VALUE,
                                     p_token1         => G_COL_NAME_TOKEN,
                                     p_token1_value   => 'Claim Status');
                 --Notify caller of  an error
                 x_return_status := Okc_Api.G_RET_STS_ERROR;
                ELSE
             	   x_return_status  := Okl_Util.check_lookup_code('OKL_CLAIM_STATUS',p_clmv_rec.csu_code);
            		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
            	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
        	   	                                  p_msg_name           => G_NO_PARENT_RECORD,
        	   	                                  p_token1             => G_COL_NAME_TOKEN,
        	   	                                  p_token1_value       => 'Claim Status',
        	   	                                  p_token2             => g_parent_table_token,
        	   	                                  p_token2_value       => 'FND_LOOKUPS',
                                                          p_token3             => g_child_table_token,
                                                          p_token3_value       => 'OKL_INS_CLAIMS_B');--Added child table token for fixing 3745151
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
    END validate_csu_code;
       ----------------------------------------------------
      -- Validate_Attributes for: ltp_code              --
       ----------------------------------------------------
          PROCEDURE  validate_ltp_code(x_return_status OUT NOCOPY VARCHAR2,p_clmv_rec IN clmv_rec_type ) IS
              l_dummy_var                    VARCHAR2(1) :='?';
               BEGIN
                 --initialize the  return status
                 x_return_status := Okc_Api.G_RET_STS_SUCCESS;

                 --smoduga modified for bug 2395753 and 2522390
                 IF p_clmv_rec.ltp_code = Okc_Api.G_MISS_CHAR --OR
                    --p_clmv_rec.ltp_code IS NULL
                 THEN
                   Okc_Api.set_message(p_app_name       => G_APP_NAME,
                                       p_msg_name       => G_REQUIRED_VALUE,
                                       p_token1         => G_COL_NAME_TOKEN,
                                       p_token1_value   => 'Claim Loss Type');
                   --Notify caller of  an error
                   x_return_status := Okc_Api.G_RET_STS_ERROR;
                  ELSIF  p_clmv_rec.ltp_code IS NOT NULL THEN
               	   x_return_status  := Okl_Util.check_lookup_code('OKL_LOSS_TYPE',p_clmv_rec.ltp_code);
              		IF (x_return_status = Okc_Api.G_RET_STS_ERROR) THEN
              	   		Okc_Api.set_message(p_app_name 	    => G_APP_NAME,
          	   	                                  p_msg_name           => G_NO_PARENT_RECORD,
          	   	                                  p_token1             => G_COL_NAME_TOKEN,
          	   	                                  p_token1_value       => 'Claim Loss Type',
          	   	                                  p_token2             => g_parent_table_token,
          	   	                                  p_token2_value       => 'FND_LOOKUPS',
                                                          p_token3             => g_child_table_token,
                                                          p_token3_value       => 'OKL_INS_CLAIMS_B'); -- Added child table token for 3745151.
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
    END validate_ltp_code;
     ----------------------------------------------------
     -- Validate_Attributes for: claim date            --
     ----------------------------------------------------
       PROCEDURE  validate_claim_date(x_return_status OUT NOCOPY VARCHAR2,p_clmv_rec IN clmv_rec_type ) IS
         BEGIN
           --initialize the  return status
           x_return_status := Okc_Api.G_RET_STS_SUCCESS;

           --smoduga modified for bug 2395753 and 2522390
           IF p_clmv_rec.claim_date = Okc_Api.G_MISS_DATE --OR
              --p_clmv_rec.claim_date IS NULL
           THEN
             Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_REQUIRED_VALUE,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Claim Date');
             --Notify caller of  an error
             x_return_status := Okc_Api.G_RET_STS_ERROR;
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
      END validate_claim_date;
     ----------------------------------------------------
     -- Validate_Attributes for: Loss date            --
     ----------------------------------------------------
       PROCEDURE  validate_loss_date(x_return_status OUT NOCOPY VARCHAR2,p_clmv_rec IN clmv_rec_type ) IS
         BEGIN
           --initialize the  return status
           x_return_status := Okc_Api.G_RET_STS_SUCCESS;

           --smoduga modified for bug 2395753 and 2522390
           IF p_clmv_rec.loss_date = Okc_Api.G_MISS_DATE --OR
              --p_clmv_rec.loss_date IS NULL
           THEN
             Okc_Api.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_REQUIRED_VALUE,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Accident Date');
             --Notify caller of  an error
             x_return_status := Okc_Api.G_RET_STS_ERROR;
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
      END validate_loss_date;
      ----------------------------------------------------
      -- Validate_Attributes for: amount       --
      ----------------------------------------------------
              PROCEDURE  validate_amount(x_return_status OUT NOCOPY VARCHAR2,p_clmv_rec IN clmv_rec_type ) IS
                  l_dummy_var                    VARCHAR2(1) :='?';
                   BEGIN
                     --initialize the  return status
      	              x_return_status := Okc_Api.G_RET_STS_SUCCESS;

                      --smoduga modified for bug 2395753 and 2522390
      	              IF p_clmv_rec.amount = Okc_Api.G_MISS_NUM --OR
      	                 --p_clmv_rec.amount IS NULL
      	              THEN
      	                Okc_Api.set_message(p_app_name       => G_APP_NAME,
      	                                    p_msg_name       => G_REQUIRED_VALUE,
      	                                    p_token1         => G_COL_NAME_TOKEN,
      	                                    p_token1_value   => 'AMOUNT');
      	                -- Notify caller of  an error
      	                x_return_status := Okc_Api.G_RET_STS_ERROR;
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
      END validate_amount;
      ----------------------------------------------------
          -- Validate_Attributes for: police_contact      --
          ----------------------------------------------------
                  PROCEDURE  validate_police_contact(x_return_status OUT NOCOPY VARCHAR2,p_clmv_rec IN clmv_rec_type ) IS
                      l_dummy_var                    VARCHAR2(1) :='?';
                       BEGIN
                         --initialize the  return status
          	              x_return_status := Okc_Api.G_RET_STS_SUCCESS;

                               --smoduga modified for bug 2395753 and 2522390
          	              IF p_clmv_rec.police_contact = Okc_Api.G_MISS_CHAR --OR
          	                 --p_clmv_rec.police_contact IS NULL
          	              THEN
          	                Okc_Api.set_message(p_app_name       => G_APP_NAME,
          	                                    p_msg_name       => G_REQUIRED_VALUE,
          	                                    p_token1         => G_COL_NAME_TOKEN,
          	                                    p_token1_value   => 'POLICE CONTACT');
          	                -- Notify caller of  an error
          	                x_return_status := Okc_Api.G_RET_STS_ERROR;
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
      END validate_police_contact;
      ----------------------------------------------------
      -- Validate_Attributes for: police_Report      --
      ----------------------------------------------------
      PROCEDURE  validate_police_report(x_return_status OUT NOCOPY VARCHAR2,p_clmv_rec IN clmv_rec_type ) IS
       l_dummy_var                    VARCHAR2(1) :='?';
       BEGIN
         --initialize the  return status
          x_return_status := Okc_Api.G_RET_STS_SUCCESS;

            --smoduga modified for bug 2395753 and 2522390
           IF p_clmv_rec.police_report = Okc_Api.G_MISS_CHAR --OR
           --p_clmv_rec.police_report IS NULL
           THEN
           Okc_Api.set_message(p_app_name       => G_APP_NAME,
              	             p_msg_name       => G_REQUIRED_VALUE,
              	             p_token1         => G_COL_NAME_TOKEN,
              	             p_token1_value   => 'POLICE REPORT');
           -- Notify caller of  an error
              x_return_status := Okc_Api.G_RET_STS_ERROR;
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
          END validate_police_report;


    ---------------------------------------------------------------------------
    -- FUNCTION Validate_Attributes
    ---------------------------------------------------------------------------
    ----------------------------------------------
    -- Validate_Attributes for:OKL_INS_CLAIMS_V --
    ----------------------------------------------
    FUNCTION Validate_Attributes (
      p_clmv_rec                     IN clmv_rec_type
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
      validate_id(x_return_status, p_clmv_rec.id);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- object_version_number
      -- ***
      validate_object_version_number(x_return_status, p_clmv_rec.object_version_number);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- sfwt_flag
      -- ***
      validate_sfwt_flag(x_return_status, p_clmv_rec.sfwt_flag);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- claim_number
      -- ***
      validate_claim_number(x_return_status, p_clmv_rec.claim_number);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- ipy_id
      -- ***
      validate_ipy_id(x_return_status, p_clmv_rec.ipy_id);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- amount
      -- ***
      validate_amount(x_return_status, p_clmv_rec);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- claim_date
      -- ***
      validate_claim_date(x_return_status, p_clmv_rec);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- csu_code
      -- ***
      validate_csu_code(x_return_status, p_clmv_rec);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- ltp_code
      -- ***
      validate_ltp_code(x_return_status, p_clmv_rec);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- loss_date
      -- ***
      validate_loss_date(x_return_status, p_clmv_rec);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- police_contact
      -- ***
      validate_police_contact(x_return_status, p_clmv_rec);
      IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      -- ***
      -- police_report
      -- ***
      validate_police_report(x_return_status, p_clmv_rec);
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
      FUNCTION validate_foreign_keys (
          p_clmv_rec IN clmv_rec_type,
          p_db_clmv_rec IN clmv_rec_type
        ) RETURN VARCHAR2 IS
          item_not_found_error           EXCEPTION;
          /*
          CURSOR okl_clmv_inav_fk_csr (      SELECT 'x'
            FROM Okl_Ins_Assets_V
           WHERE       l_okl_clmv_inav_fk
           okl_clmv_inav_fk_csr%ROWTYPE;
          CURSOR okl_clmv_ltpv_fk_csr (p_lookup_code IN VARCHAR2) IS
          SELECT 'x'
            FROM Fnd_Common_Lookups
           WHERE fnd_common_lookups.lookup_code = p_lookup_code;
           */
          -- l_okl_clmv_ltpv_fk             okl_clmv_ltpv_fk_csr%ROWTYPE;
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          l_row_notfound                 BOOLEAN := TRUE;
        BEGIN
           NULL;
           RETURN (l_return_status);
           /*
          IF (       AND
                    THEN
            OPEN okl_clmv_inav_fk_csr (        FETCH okl_clmv_inav_fk_csr INTO l_okl_clmv_inav_fk;
            l_row_notfound := okl_clmv_inav_fk_csr%NOTFOUND;
            CLOSE okl_clmv_inav_fk_csr;
            IF (l_row_notfound) THEN
              RAISE item_not_found_error;
            END IF;
          END IF;
          IF ((p_clmv_rec.LTP_CODE IS NOT NULL)
           AND
              (p_clmv_rec.LTP_CODE <> p_db_clmv_rec.LTP_CODE))
          THEN
            OPEN okl_clmv_ltpv_fk_csr (p_clmv_rec.LTP_CODE);
            FETCH okl_clmv_ltpv_fk_csr INTO l_okl_clmv_ltpv_fk;
            l_row_notfound := okl_clmv_ltpv_fk_csr%NOTFOUND;
            CLOSE okl_clmv_ltpv_fk_csr;
            IF (l_row_notfound) THEN
              OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LTP_CODE');
              RAISE item_not_found_error;
            END IF;
          END IF;
          IF ((p_clmv_rec.CSU_CODE IS NOT NULL)
           AND
              (p_clmv_rec.CSU_CODE <> p_db_clmv_rec.CSU_CODE))
          THEN
            OPEN okl_clmv_csuv_fk_csr (p_clmv_rec.CSU_CODE);
            FETCH okl_clmv_csuv_fk_csr INTO l_okl_clmv_csuv_fk;
            l_row_notfound := okl_clmv_csuv_fk_csr%NOTFOUND;
            CLOSE okl_clmv_csuv_fk_csr;
            IF (l_row_notfound) THEN
              OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CSU_CODE');
              RAISE item_not_found_error;
            END IF;
          END IF;
          RETURN (l_return_status);
        EXCEPTION
          WHEN item_not_found_error THEN
            l_return_status := OKC_API.G_RET_STS_ERROR;
            RETURN (l_return_status);
            */
        END validate_foreign_keys;

    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Duplicates
    ---------------------------------------------------------------------------
      PROCEDURE validate_duplicates(
      p_clmv_rec          IN clmv_rec_type,
      x_return_status 	OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
      l_dummy_var VARCHAR2(1) := '?';
       CURSOR l_clmv_csr IS
        SELECT 'x'
        FROM   okl_ins_claims_v
        WHERE  ipy_id = p_clmv_rec.ipy_id
        AND    claim_number = p_clmv_rec.claim_number
        AND    ID <> p_clmv_rec.id;
      BEGIN
    	OPEN l_clmv_csr;
    	FETCH l_clmv_csr INTO l_dummy_var;
    	CLOSE l_clmv_csr;
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
    END validate_duplicates;

    ------------------------------------------
    -- Validate Record for:OKL_INS_CLAIMS_V --
    ------------------------------------------
    FUNCTION Validate_Record (
      p_clmv_rec IN clmv_rec_type,
      p_db_clmv_rec IN clmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      ------------------------------------
      -- FUNCTION validate_foreign_keys --
      ------------------------------------
    BEGIN
       --Validate Duplicate records
         validate_duplicates(p_clmv_rec,l_return_status);
            IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
               OKC_API.set_message(p_app_name 	    => G_APP_NAME,
  	                           p_msg_name       => 'OKL_UNIQUE'
  			           );
               l_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;

       l_return_status := validate_foreign_keys(p_clmv_rec, p_db_clmv_rec);
       RETURN (l_return_status);
    END Validate_Record;

    FUNCTION Validate_Record (
      p_clmv_rec IN clmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_db_clmv_rec                  clmv_rec_type := get_rec(p_clmv_rec);
    BEGIN
      l_return_status := Validate_Record(p_clmv_rec => p_clmv_rec,
                                         p_db_clmv_rec => l_db_clmv_rec);
      --Validate Duplicate records
         validate_duplicates(p_clmv_rec,l_return_status);
            IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
               OKC_API.set_message(p_app_name 	    => G_APP_NAME,
  	                               p_msg_name       => 'OKL_UNIQUE'
  				                   );
               l_return_status := Okc_Api.G_RET_STS_ERROR;
            END IF;

      RETURN (l_return_status);
    END Validate_Record;
    ---------------------------------------------------------------------------
    -- PROCEDURE Migrate
    ---------------------------------------------------------------------------
    PROCEDURE migrate (
      p_from IN clmv_rec_type,
      p_to   IN OUT NOCOPY clm_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.claim_number := p_from.claim_number;
      p_to.csu_code := p_from.csu_code;
      p_to.ipy_id := p_from.ipy_id;
      p_to.ltp_code := p_from.ltp_code;
      p_to.program_update_date := p_from.program_update_date;
      p_to.claim_date := p_from.claim_date;
      p_to.program_id := p_from.program_id;
      p_to.loss_date := p_from.loss_date;
      p_to.police_contact := p_from.police_contact;
      p_to.amount := p_from.amount;
      p_to.object_version_number := p_from.object_version_number;
      p_to.request_id := p_from.request_id;
      p_to.program_application_id := p_from.program_application_id;
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
      p_to.hold_date := p_from.hold_date;
      p_to.org_id := p_from.org_id;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    PROCEDURE migrate (
      p_from IN clm_rec_type,
      p_to   IN OUT NOCOPY clmv_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.object_version_number := p_from.object_version_number;
      p_to.ipy_id := p_from.ipy_id;
      p_to.ltp_code := p_from.ltp_code;
      p_to.csu_code := p_from.csu_code;
      p_to.claim_number := p_from.claim_number;
      p_to.claim_date := p_from.claim_date;
      p_to.loss_date := p_from.loss_date;
      p_to.police_contact := p_from.police_contact;
      p_to.amount := p_from.amount;
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
      p_to.hold_date := p_from.hold_date;
      p_to.org_id := p_from.org_id;
      p_to.request_id := p_from.request_id;
      p_to.program_application_id := p_from.program_application_id;
      p_to.program_id := p_from.program_id;
      p_to.program_update_date := p_from.program_update_date;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    PROCEDURE migrate (
      p_from IN clmv_rec_type,
      p_to   IN OUT NOCOPY okl_ins_claims_tl_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.description := p_from.description;
      p_to.police_report := p_from.police_report;
      p_to.sfwt_flag := p_from.sfwt_flag;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    PROCEDURE migrate (
      p_from IN okl_ins_claims_tl_rec_type,
      p_to   IN OUT NOCOPY clmv_rec_type
    ) IS
    BEGIN
      p_to.id := p_from.id;
      p_to.sfwt_flag := p_from.sfwt_flag;
      p_to.description := p_from.description;
      p_to.police_report := p_from.police_report;
      p_to.created_by := p_from.created_by;
      p_to.creation_date := p_from.creation_date;
      p_to.last_updated_by := p_from.last_updated_by;
      p_to.last_update_date := p_from.last_update_date;
      p_to.last_update_login := p_from.last_update_login;
    END migrate;
    ---------------------------------------------------------------------------
    -- PROCEDURE validate_row
    ---------------------------------------------------------------------------
    ---------------------------------------
    -- validate_row for:OKL_INS_CLAIMS_V --
    ---------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clmv_rec                     clmv_rec_type := p_clmv_rec;
      l_clm_rec                      clm_rec_type;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
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
      l_return_status := Validate_Attributes(l_clmv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_clmv_rec);
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
    --------------------------------------------------
    -- PL/SQL TBL validate_row for:OKL_INS_CLAIMS_V --
    --------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        i := p_clmv_tbl.FIRST;
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
              p_clmv_rec                     => p_clmv_tbl(i));
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
          EXIT WHEN (i = p_clmv_tbl.LAST);
          i := p_clmv_tbl.NEXT(i);
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
    --------------------------------------------------
    -- PL/SQL TBL validate_row for:OKL_INS_CLAIMS_V --
    --------------------------------------------------
    PROCEDURE validate_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clmv_tbl                     => p_clmv_tbl,
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
    -- insert_row for:OKL_INS_CLAIMS_B --
    -------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clm_rec                      IN clm_rec_type,
      x_clm_rec                      OUT NOCOPY clm_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clm_rec                      clm_rec_type := p_clm_rec;
      l_def_clm_rec                  clm_rec_type;
      -----------------------------------------
      -- Set_Attributes for:OKL_INS_CLAIMS_B --
      -----------------------------------------
      FUNCTION Set_Attributes (
        p_clm_rec IN clm_rec_type,
        x_clm_rec OUT NOCOPY clm_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_clm_rec := p_clm_rec;
    --Smoduga added for inventory org fix 3348924
        x_clm_rec.org_id := get_inv_org_id(p_clm_rec.ipy_id);
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
        p_clm_rec,                         -- IN
        l_clm_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      INSERT INTO OKL_INS_CLAIMS_B(
        id,
        claim_number,
        csu_code,
        ipy_id,
        ltp_code,
        program_update_date,
        claim_date,
        program_id,
        loss_date,
        police_contact,
        amount,
        object_version_number,
        request_id,
        program_application_id,
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
        hold_date,
        org_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_clm_rec.id,
        l_clm_rec.claim_number,
        l_clm_rec.csu_code,
        l_clm_rec.ipy_id,
        l_clm_rec.ltp_code,
        l_clm_rec.program_update_date,
        l_clm_rec.claim_date,
        l_clm_rec.program_id,
        l_clm_rec.loss_date,
        l_clm_rec.police_contact,
        l_clm_rec.amount,
        l_clm_rec.object_version_number,
        l_clm_rec.request_id,
        l_clm_rec.program_application_id,
        l_clm_rec.attribute_category,
        l_clm_rec.attribute1,
        l_clm_rec.attribute2,
        l_clm_rec.attribute3,
        l_clm_rec.attribute4,
        l_clm_rec.attribute5,
        l_clm_rec.attribute6,
        l_clm_rec.attribute7,
        l_clm_rec.attribute8,
        l_clm_rec.attribute9,
        l_clm_rec.attribute10,
        l_clm_rec.attribute11,
        l_clm_rec.attribute12,
        l_clm_rec.attribute13,
        l_clm_rec.attribute14,
        l_clm_rec.attribute15,
        l_clm_rec.hold_date,
        l_clm_rec.org_id,
        l_clm_rec.created_by,
        l_clm_rec.creation_date,
        l_clm_rec.last_updated_by,
        l_clm_rec.last_update_date,
        l_clm_rec.last_update_login);
      -- Set OUT values
      x_clm_rec := l_clm_rec;
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
    --------------------------------------
    -- insert_row for:OKL_INS_CLAIMS_TL --
    --------------------------------------
    PROCEDURE insert_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_claims_tl_rec        IN okl_ins_claims_tl_rec_type,
      x_okl_ins_claims_tl_rec        OUT NOCOPY okl_ins_claims_tl_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type := p_okl_ins_claims_tl_rec;
      l_def_okl_ins_claims_tl_rec    okl_ins_claims_tl_rec_type;
      CURSOR get_languages IS
        SELECT *
          FROM FND_LANGUAGES
         WHERE INSTALLED_FLAG IN ('I', 'B');
      ------------------------------------------
      -- Set_Attributes for:OKL_INS_CLAIMS_TL --
      ------------------------------------------
      FUNCTION Set_Attributes (
        p_okl_ins_claims_tl_rec IN okl_ins_claims_tl_rec_type,
        x_okl_ins_claims_tl_rec OUT NOCOPY okl_ins_claims_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_claims_tl_rec := p_okl_ins_claims_tl_rec;
        x_okl_ins_claims_tl_rec.LANGUAGE := USERENV('LANG');
        x_okl_ins_claims_tl_rec.SOURCE_LANG := USERENV('LANG');
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
        p_okl_ins_claims_tl_rec,           -- IN
        l_okl_ins_claims_tl_rec);          -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      FOR l_lang_rec IN get_languages LOOP
        l_okl_ins_claims_tl_rec.language := l_lang_rec.language_code;
        INSERT INTO OKL_INS_CLAIMS_TL(
          id,
          language,
          description,
          police_report,
          comments,
          source_lang,
          sfwt_flag,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_ins_claims_tl_rec.id,
          l_okl_ins_claims_tl_rec.language,
          l_okl_ins_claims_tl_rec.description,
          l_okl_ins_claims_tl_rec.police_report,
          l_okl_ins_claims_tl_rec.comments,
          l_okl_ins_claims_tl_rec.source_lang,
          l_okl_ins_claims_tl_rec.sfwt_flag,
          l_okl_ins_claims_tl_rec.created_by,
          l_okl_ins_claims_tl_rec.creation_date,
          l_okl_ins_claims_tl_rec.last_updated_by,
          l_okl_ins_claims_tl_rec.last_update_date,
          l_okl_ins_claims_tl_rec.last_update_login);
      END LOOP;
      -- Set OUT values
      x_okl_ins_claims_tl_rec := l_okl_ins_claims_tl_rec;
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
    --------------------------------------
    -- insert_row for :OKL_INS_CLAIMS_V --
    --------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type,
      x_clmv_rec                     OUT NOCOPY clmv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clmv_rec                     clmv_rec_type := p_clmv_rec;
      l_def_clmv_rec                 clmv_rec_type;
      l_clm_rec                      clm_rec_type;
      lx_clm_rec                     clm_rec_type;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
      lx_okl_ins_claims_tl_rec       okl_ins_claims_tl_rec_type;

      -- SMODUGA added for claim number generation . Bug 3234773
      l_policy_number               VARCHAR2(20);
      l_ipy_type                    VARCHAR2(30);
      l_claim_like                  VARCHAR2(30);
      l_policy_string_len           NUMBER;
      l_seq                         NUMBER ;

      -- Get next highest number for claim sequence for given policy
     --Bug 3941692
      CURSOR c_claim_seq(c_ipy_id NUMBER,c_ipy_type varchar2,c_claim_like VARCHAR2) is
      SELECT nvl(max(to_number(substrb(clmb.claim_number,instr(clmb.claim_number,'-')+1,
             length(clmb.claim_number)))) + 1,-1) SEQUENCE_NUMBER
      FROM   okl_ins_claims_b clmb,okl_ins_policies_b ipyb
      WHERE  clmb.ipy_id = ipyb.id
            and clmb.claim_number like c_claim_like
            and ipyb.ipy_type = c_ipy_type
            and ipyb.id = c_ipy_id;
      ------------------------------------------
      -- get policy number ---------------------
      -------------------------------------------
      FUNCTION get_policy_number (
         p_clmv_rec IN clmv_rec_type,
         x_policy_number OUT NOCOPY VARCHAR2,
         x_ipy_type OUT NOCOPY VARCHAR2
        ) RETURN VARCHAR2 IS
          l_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
          lx_policy_number     VARCHAR2(20);
          lx_ipy_type          VARCHAR2(30);
          l_row_notfound       BOOLEAN := FALSE;
          cursor policy_number(p_ipy_id NUMBER) IS
           SELECT policy_number ,ipy_type, authoring_org_id -- bug 7335139
            FROM OKL_INS_POLICIES_all_b ins, okc_k_headers_all_b chr -- bug 7335139
           WHERE ins.ID = p_ipy_id
           and ins.khr_id = chr.id; -- bug 7335139

           l_id number; -- bug 7335139
        BEGIN
           open policy_number(p_clmv_rec.ipy_id);
             fetch policy_number into lx_policy_number,lx_ipy_type, l_id; -- bug 7335139
           l_row_notfound := policy_number%NOTFOUND;
           close policy_number;

           -- bug 7335139 if the org_id context is not set then set it
           if mo_global.get_current_org_id is null then
             MO_GLOBAL.set_policy_context('S',l_id);
           end if;
            IF (l_row_notfound) THEN
              OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,' Policy Number ');
              l_return_status := OKC_API.G_RET_STS_ERROR;
              RETURN(l_return_status);
            ELSE
             x_policy_number := lx_policy_number;
             x_ipy_type := lx_ipy_type;
             RETURN(l_return_status);
            END IF;
     END get_policy_number;
      ------------------------------------------
      -- claim number generator
      --  Check if claim number generated already
      -- exists.If existing call claim number generator
      -- check again for existing claim numbers
      -- till a new claim number is generated.
      -------------------------------------------
      Function check_duplicate(p_claim_number IN varchar2,
                               p_seq IN NUMBER,
                               p_policy_number IN varchar2)
      RETURN VARCHAR2 IS
      l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_claim_number      VARCHAR2(30);  --change for claimnumber generation old 15
      l_dummy_var         VARCHAR2(1) :='?';

        --check if this claim number alreadu exists
        cursor c_claim_exist(c_claim_number VARCHAR2) IS
         select 'x'
         from okl_Ins_claims_b
         where claim_number = c_claim_number;
            ------------------------------------------
            -- claim number generator
            -- Called in case claim number already exists
            -- and new claim number is generated and
            -- checked if it exists.
            -------------------------------------------
            FUNCTION claim_number_generator(p_policy_number IN VARCHAR2,
                                            p_seq IN NUMBER)
                                             RETURN VARCHAR2 IS
                l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
                l_seq NUMBER;
                lx_claim_number VARCHAR2(30); --change for claimnumber generation old 15
                l_policy_number VARCHAR2(256);
                l_row_notfound      BOOLEAN := FALSE;
                lx_dummy_var    VARCHAR2(1):='?';
            BEGIN
                l_seq := p_seq+1;
                lx_claim_number := p_policy_number || ' - '||l_seq;
                open c_claim_exist(lx_claim_number);
                  fetch c_claim_exist into lx_dummy_var;
                  l_row_notfound := c_claim_exist%NOTFOUND;
                close c_claim_exist;
                IF (lx_dummy_var = 'x') THEN
                 l_policy_number := p_policy_number;
                 lx_claim_number := claim_number_generator(l_policy_number,
                                                           l_seq);
                ELSE
                    return(lx_claim_number);
                END IF;
            END claim_number_generator;
      BEGIN
         open c_claim_exist(p_claim_number);
          fetch c_claim_exist into l_dummy_var;
         close c_claim_exist;
        -- if l_dummy_var is still set to default, data was not found
         IF (l_dummy_var = 'x') THEN
           l_claim_number := claim_number_generator(p_policy_number,
                                                     p_seq);
           return(l_claim_number);
         ELSE
           l_claim_number := p_claim_number;
           return(l_claim_number);
         END IF;
      END check_duplicate;

      --  END SMODUGA added for claim number generation. Bug 3234773


      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_clmv_rec IN clmv_rec_type
      ) RETURN clmv_rec_type IS
        l_clmv_rec clmv_rec_type := p_clmv_rec;
      BEGIN
        l_clmv_rec.CREATION_DATE := SYSDATE;
        l_clmv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
        l_clmv_rec.LAST_UPDATE_DATE := l_clmv_rec.CREATION_DATE;
        l_clmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_clmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_clmv_rec);
      END fill_who_columns;
      -----------------------------------------
      -- Set_Attributes for:OKL_INS_CLAIMS_V --
      -----------------------------------------
      FUNCTION Set_Attributes (
        p_clmv_rec IN clmv_rec_type,
        x_clmv_rec OUT NOCOPY clmv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_clmv_rec := p_clmv_rec;
        x_clmv_rec.OBJECT_VERSION_NUMBER := 1;
        x_clmv_rec.SFWT_FLAG := 'N';
    --Smoduga added for inventory org fix 3348924
        x_clmv_rec.ORG_ID := get_inv_org_id(p_clmv_rec.ipy_id);
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
      l_clmv_rec := null_out_defaults(p_clmv_rec);
      -- Set primary key value
      l_clmv_rec.ID := get_seq_id;
      -- Setting item attributes
      l_return_Status := Set_Attributes(
        l_clmv_rec,                        -- IN
        l_def_clmv_rec);                   -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_clmv_rec := fill_who_columns(l_def_clmv_rec);

     --  SMODUGA added for claim number generation. Bug 3234773
      l_return_status := get_policy_number(l_def_clmv_rec ,
                                           l_policy_number,
                                           l_ipy_type);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_policy_string_len := length(l_policy_number);
      l_claim_like := l_policy_number || ' - %';
       -- get sequence number
        open c_claim_seq(l_def_clmv_rec.ipy_id,l_ipy_type,l_claim_like); --Bug 3941692
         fetch c_claim_seq into l_seq;
        close c_claim_seq;
        IF (l_seq < 1) THEN
              l_seq := 1;
              l_def_clmv_rec.CLAIM_NUMBER := l_policy_number ||' - '|| TO_CHAR(l_seq) ;
        ELSE
              l_def_clmv_rec.CLAIM_NUMBER := l_policy_number ||' - '|| TO_CHAR(l_seq) ;
              --check for existing claims with same claim number.
              l_def_clmv_rec.claim_number := check_duplicate(l_def_clmv_rec.claim_number,
                                                             l_seq,
                                                             l_policy_number);
        END IF;
--  END SMODUGA added for claim number generation. Bug 3234773


      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_clmv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_def_clmv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_clmv_rec, l_clm_rec);
      migrate(l_def_clmv_rec, l_okl_ins_claims_tl_rec);
      -----------------------------------------------
      -- Call the INSERT_ROW for each child record --
      -----------------------------------------------
      insert_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_clm_rec,
        lx_clm_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_clm_rec, l_def_clmv_rec);
      insert_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_claims_tl_rec,
        lx_okl_ins_claims_tl_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_okl_ins_claims_tl_rec, l_def_clmv_rec);
      -- Set OUT values
      x_clmv_rec := l_def_clmv_rec;
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
    -- PL/SQL TBL insert_row for:CLMV_TBL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        i := p_clmv_tbl.FIRST;
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
              p_clmv_rec                     => p_clmv_tbl(i),
              x_clmv_rec                     => x_clmv_tbl(i));
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
          EXIT WHEN (i = p_clmv_tbl.LAST);
          i := p_clmv_tbl.NEXT(i);
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
    -- PL/SQL TBL insert_row for:CLMV_TBL --
    ----------------------------------------
    PROCEDURE insert_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clmv_tbl                     => p_clmv_tbl,
          x_clmv_tbl                     => x_clmv_tbl,
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
    -- lock_row for:OKL_INS_CLAIMS_B --
    -----------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clm_rec                      IN clm_rec_type) IS
      E_Resource_Busy                EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_clm_rec IN clm_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_INS_CLAIMS_B
       WHERE ID = p_clm_rec.id
         AND OBJECT_VERSION_NUMBER = p_clm_rec.object_version_number
      FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;
      CURSOR lchk_csr (p_clm_rec IN clm_rec_type) IS
      SELECT OBJECT_VERSION_NUMBER
        FROM OKL_INS_CLAIMS_B
       WHERE ID = p_clm_rec.id;
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_object_version_number        OKL_INS_CLAIMS_B.OBJECT_VERSION_NUMBER%TYPE;
      lc_object_version_number       OKL_INS_CLAIMS_B.OBJECT_VERSION_NUMBER%TYPE;
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
        OPEN lock_csr(p_clm_rec);
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
        OPEN lchk_csr(p_clm_rec);
        FETCH lchk_csr INTO lc_object_version_number;
        lc_row_notfound := lchk_csr%NOTFOUND;
        CLOSE lchk_csr;
      END IF;
      IF (lc_row_notfound) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number > p_clm_rec.object_version_number THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSIF lc_object_version_number <> p_clm_rec.object_version_number THEN
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
    ------------------------------------
    -- lock_row for:OKL_INS_CLAIMS_TL --
    ------------------------------------
    PROCEDURE lock_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_claims_tl_rec        IN okl_ins_claims_tl_rec_type) IS
      E_Resource_Busy                EXCEPTION;
      PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
      CURSOR lock_csr (p_okl_ins_claims_tl_rec IN okl_ins_claims_tl_rec_type) IS
      SELECT *
        FROM OKL_INS_CLAIMS_TL
       WHERE ID = p_okl_ins_claims_tl_rec.id
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
        OPEN lock_csr(p_okl_ins_claims_tl_rec);
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
    ------------------------------------
    -- lock_row for: OKL_INS_CLAIMS_V --
    ------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clm_rec                      clm_rec_type;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
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
      migrate(p_clmv_rec, l_clm_rec);
      migrate(p_clmv_rec, l_okl_ins_claims_tl_rec);
      ---------------------------------------------
      -- Call the LOCK_ROW for each child record --
      ---------------------------------------------
      lock_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_clm_rec
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
        l_okl_ins_claims_tl_rec
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
    -- PL/SQL TBL lock_row for:CLMV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        i := p_clmv_tbl.FIRST;
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
              p_clmv_rec                     => p_clmv_tbl(i));
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
          EXIT WHEN (i = p_clmv_tbl.LAST);
          i := p_clmv_tbl.NEXT(i);
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
    -- PL/SQL TBL lock_row for:CLMV_TBL --
    --------------------------------------
    PROCEDURE lock_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has recrods in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        lock_row(
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clmv_tbl                     => p_clmv_tbl,
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
    -- update_row for:OKL_INS_CLAIMS_B --
    -------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clm_rec                      IN clm_rec_type,
      x_clm_rec                      OUT NOCOPY clm_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clm_rec                      clm_rec_type := p_clm_rec;
      l_def_clm_rec                  clm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_clm_rec IN clm_rec_type,
        x_clm_rec OUT NOCOPY clm_rec_type
      ) RETURN VARCHAR2 IS
        l_clm_rec                      clm_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_clm_rec := p_clm_rec;
        -- Get current database values
        l_clm_rec := get_rec(p_clm_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          IF (x_clm_rec.id = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.id := l_clm_rec.id;
          END IF;
          IF (x_clm_rec.claim_number = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.claim_number := l_clm_rec.claim_number;
          END IF;
          IF (x_clm_rec.csu_code = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.csu_code := l_clm_rec.csu_code;
          END IF;
          IF (x_clm_rec.ipy_id = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.ipy_id := l_clm_rec.ipy_id;
          END IF;
          IF (x_clm_rec.ltp_code = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.ltp_code := l_clm_rec.ltp_code;
          END IF;
          IF (x_clm_rec.program_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_clm_rec.program_update_date := l_clm_rec.program_update_date;
          END IF;
          IF (x_clm_rec.claim_date = OKC_API.G_MISS_DATE)
          THEN
            x_clm_rec.claim_date := l_clm_rec.claim_date;
          END IF;
          IF (x_clm_rec.program_id = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.program_id := l_clm_rec.program_id;
          END IF;
          IF (x_clm_rec.loss_date = OKC_API.G_MISS_DATE)
          THEN
            x_clm_rec.loss_date := l_clm_rec.loss_date;
          END IF;
          IF (x_clm_rec.police_contact = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.police_contact := l_clm_rec.police_contact;
          END IF;
          IF (x_clm_rec.amount = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.amount := l_clm_rec.amount;
          END IF;
          IF (x_clm_rec.object_version_number = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.object_version_number := l_clm_rec.object_version_number;
          END IF;
          IF (x_clm_rec.request_id = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.request_id := l_clm_rec.request_id;
          END IF;
          IF (x_clm_rec.program_application_id = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.program_application_id := l_clm_rec.program_application_id;
          END IF;
          IF (x_clm_rec.attribute_category = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute_category := l_clm_rec.attribute_category;
          END IF;
          IF (x_clm_rec.attribute1 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute1 := l_clm_rec.attribute1;
          END IF;
          IF (x_clm_rec.attribute2 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute2 := l_clm_rec.attribute2;
          END IF;
          IF (x_clm_rec.attribute3 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute3 := l_clm_rec.attribute3;
          END IF;
          IF (x_clm_rec.attribute4 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute4 := l_clm_rec.attribute4;
          END IF;
          IF (x_clm_rec.attribute5 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute5 := l_clm_rec.attribute5;
          END IF;
          IF (x_clm_rec.attribute6 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute6 := l_clm_rec.attribute6;
          END IF;
          IF (x_clm_rec.attribute7 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute7 := l_clm_rec.attribute7;
          END IF;
          IF (x_clm_rec.attribute8 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute8 := l_clm_rec.attribute8;
          END IF;
          IF (x_clm_rec.attribute9 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute9 := l_clm_rec.attribute9;
          END IF;
          IF (x_clm_rec.attribute10 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute10 := l_clm_rec.attribute10;
          END IF;
          IF (x_clm_rec.attribute11 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute11 := l_clm_rec.attribute11;
          END IF;
          IF (x_clm_rec.attribute12 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute12 := l_clm_rec.attribute12;
          END IF;
          IF (x_clm_rec.attribute13 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute13 := l_clm_rec.attribute13;
          END IF;
          IF (x_clm_rec.attribute14 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute14 := l_clm_rec.attribute14;
          END IF;
          IF (x_clm_rec.attribute15 = OKC_API.G_MISS_CHAR)
          THEN
            x_clm_rec.attribute15 := l_clm_rec.attribute15;
          END IF;
          IF (x_clm_rec.hold_date = OKC_API.G_MISS_DATE)
          THEN
            x_clm_rec.hold_date := l_clm_rec.hold_date;
          END IF;
          IF (x_clm_rec.org_id = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.org_id := l_clm_rec.org_id;
          END IF;
          IF (x_clm_rec.created_by = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.created_by := l_clm_rec.created_by;
          END IF;
          IF (x_clm_rec.creation_date = OKC_API.G_MISS_DATE)
          THEN
            x_clm_rec.creation_date := l_clm_rec.creation_date;
          END IF;
          IF (x_clm_rec.last_updated_by = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.last_updated_by := l_clm_rec.last_updated_by;
          END IF;
          IF (x_clm_rec.last_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_clm_rec.last_update_date := l_clm_rec.last_update_date;
          END IF;
          IF (x_clm_rec.last_update_login = OKC_API.G_MISS_NUM)
          THEN
            x_clm_rec.last_update_login := l_clm_rec.last_update_login;
          END IF;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      -----------------------------------------
      -- Set_Attributes for:OKL_INS_CLAIMS_B --
      -----------------------------------------
      FUNCTION Set_Attributes (
        p_clm_rec IN clm_rec_type,
        x_clm_rec OUT NOCOPY clm_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_clm_rec := p_clm_rec;
    --Smoduga added for inventory org fix 3348924
        x_clm_rec.org_id := get_inv_org_id(p_clm_rec.ipy_id);
        x_clm_rec.OBJECT_VERSION_NUMBER := p_clm_rec.OBJECT_VERSION_NUMBER + 1;
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
        p_clm_rec,                         -- IN
        l_clm_rec);                        -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_clm_rec, l_def_clm_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      UPDATE OKL_INS_CLAIMS_B
      SET CLAIM_NUMBER = l_def_clm_rec.claim_number,
          CSU_CODE = l_def_clm_rec.csu_code,
          IPY_ID = l_def_clm_rec.ipy_id,
          LTP_CODE = l_def_clm_rec.ltp_code,
          PROGRAM_UPDATE_DATE = l_def_clm_rec.program_update_date,
          CLAIM_DATE = l_def_clm_rec.claim_date,
          PROGRAM_ID = l_def_clm_rec.program_id,
          LOSS_DATE = l_def_clm_rec.loss_date,
          POLICE_CONTACT = l_def_clm_rec.police_contact,
          AMOUNT = l_def_clm_rec.amount,
          OBJECT_VERSION_NUMBER = l_def_clm_rec.object_version_number,
          REQUEST_ID = l_def_clm_rec.request_id,
          PROGRAM_APPLICATION_ID = l_def_clm_rec.program_application_id,
          ATTRIBUTE_CATEGORY = l_def_clm_rec.attribute_category,
          ATTRIBUTE1 = l_def_clm_rec.attribute1,
          ATTRIBUTE2 = l_def_clm_rec.attribute2,
          ATTRIBUTE3 = l_def_clm_rec.attribute3,
          ATTRIBUTE4 = l_def_clm_rec.attribute4,
          ATTRIBUTE5 = l_def_clm_rec.attribute5,
          ATTRIBUTE6 = l_def_clm_rec.attribute6,
          ATTRIBUTE7 = l_def_clm_rec.attribute7,
          ATTRIBUTE8 = l_def_clm_rec.attribute8,
          ATTRIBUTE9 = l_def_clm_rec.attribute9,
          ATTRIBUTE10 = l_def_clm_rec.attribute10,
          ATTRIBUTE11 = l_def_clm_rec.attribute11,
          ATTRIBUTE12 = l_def_clm_rec.attribute12,
          ATTRIBUTE13 = l_def_clm_rec.attribute13,
          ATTRIBUTE14 = l_def_clm_rec.attribute14,
          ATTRIBUTE15 = l_def_clm_rec.attribute15,
          HOLD_DATE = l_def_clm_rec.hold_date,
          ORG_ID = l_def_clm_rec.org_id,
          CREATED_BY = l_def_clm_rec.created_by,
          CREATION_DATE = l_def_clm_rec.creation_date,
          LAST_UPDATED_BY = l_def_clm_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_clm_rec.last_update_date,
          LAST_UPDATE_LOGIN = l_def_clm_rec.last_update_login
      WHERE ID = l_def_clm_rec.id;
      x_clm_rec := l_clm_rec;
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
    --------------------------------------
    -- update_row for:OKL_INS_CLAIMS_TL --
    --------------------------------------
    PROCEDURE update_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_claims_tl_rec        IN okl_ins_claims_tl_rec_type,
      x_okl_ins_claims_tl_rec        OUT NOCOPY okl_ins_claims_tl_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type := p_okl_ins_claims_tl_rec;
      l_def_okl_ins_claims_tl_rec    okl_ins_claims_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_okl_ins_claims_tl_rec IN okl_ins_claims_tl_rec_type,
        x_okl_ins_claims_tl_rec OUT NOCOPY okl_ins_claims_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_claims_tl_rec := p_okl_ins_claims_tl_rec;
        -- Get current database values
        l_okl_ins_claims_tl_rec := get_rec(p_okl_ins_claims_tl_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          IF (x_okl_ins_claims_tl_rec.id = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_claims_tl_rec.id := l_okl_ins_claims_tl_rec.id;
          END IF;
          IF (x_okl_ins_claims_tl_rec.language = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_claims_tl_rec.language := l_okl_ins_claims_tl_rec.language;
          END IF;
          IF (x_okl_ins_claims_tl_rec.description = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_claims_tl_rec.description := l_okl_ins_claims_tl_rec.description;
          END IF;
          IF (x_okl_ins_claims_tl_rec.police_report = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_claims_tl_rec.police_report := l_okl_ins_claims_tl_rec.police_report;
          END IF;
          IF (x_okl_ins_claims_tl_rec.comments = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_claims_tl_rec.comments := l_okl_ins_claims_tl_rec.comments;
          END IF;
          IF (x_okl_ins_claims_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_claims_tl_rec.source_lang := l_okl_ins_claims_tl_rec.source_lang;
          END IF;
          IF (x_okl_ins_claims_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
          THEN
            x_okl_ins_claims_tl_rec.sfwt_flag := l_okl_ins_claims_tl_rec.sfwt_flag;
          END IF;
          IF (x_okl_ins_claims_tl_rec.created_by = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_claims_tl_rec.created_by := l_okl_ins_claims_tl_rec.created_by;
          END IF;
          IF (x_okl_ins_claims_tl_rec.creation_date = OKC_API.G_MISS_DATE)
          THEN
            x_okl_ins_claims_tl_rec.creation_date := l_okl_ins_claims_tl_rec.creation_date;
          END IF;
          IF (x_okl_ins_claims_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_claims_tl_rec.last_updated_by := l_okl_ins_claims_tl_rec.last_updated_by;
          END IF;
          IF (x_okl_ins_claims_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_okl_ins_claims_tl_rec.last_update_date := l_okl_ins_claims_tl_rec.last_update_date;
          END IF;
          IF (x_okl_ins_claims_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
          THEN
            x_okl_ins_claims_tl_rec.last_update_login := l_okl_ins_claims_tl_rec.last_update_login;
          END IF;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      ------------------------------------------
      -- Set_Attributes for:OKL_INS_CLAIMS_TL --
      ------------------------------------------
      FUNCTION Set_Attributes (
        p_okl_ins_claims_tl_rec IN okl_ins_claims_tl_rec_type,
        x_okl_ins_claims_tl_rec OUT NOCOPY okl_ins_claims_tl_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_okl_ins_claims_tl_rec := p_okl_ins_claims_tl_rec;
        x_okl_ins_claims_tl_rec.LANGUAGE := USERENV('LANG');
        x_okl_ins_claims_tl_rec.LANGUAGE := USERENV('LANG');
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
        p_okl_ins_claims_tl_rec,           -- IN
        l_okl_ins_claims_tl_rec);          -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_okl_ins_claims_tl_rec, l_def_okl_ins_claims_tl_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      UPDATE OKL_INS_CLAIMS_TL
      SET DESCRIPTION = l_def_okl_ins_claims_tl_rec.description,
          SOURCE_LANG = l_def_okl_ins_claims_tl_rec.source_lang, --Smoduga added for bug 3637102
          POLICE_REPORT = l_def_okl_ins_claims_tl_rec.police_report,
          COMMENTS = l_def_okl_ins_claims_tl_rec.comments,
          CREATED_BY = l_def_okl_ins_claims_tl_rec.created_by,
          CREATION_DATE = l_def_okl_ins_claims_tl_rec.creation_date,
          LAST_UPDATED_BY = l_def_okl_ins_claims_tl_rec.last_updated_by,
          LAST_UPDATE_DATE = l_def_okl_ins_claims_tl_rec.last_update_date,
          LAST_UPDATE_LOGIN = l_def_okl_ins_claims_tl_rec.last_update_login
      WHERE ID = l_def_okl_ins_claims_tl_rec.id
        AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE); --Fix for 3637102 added
                                                        -- LANGUAGE
      UPDATE OKL_INS_CLAIMS_TL
      SET SFWT_FLAG = 'Y'
      WHERE ID = l_def_okl_ins_claims_tl_rec.id
        AND SOURCE_LANG <> USERENV('LANG');
      x_okl_ins_claims_tl_rec := l_okl_ins_claims_tl_rec;
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
    -------------------------------------
    -- update_row for:OKL_INS_CLAIMS_V --
    -------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type,
      x_clmv_rec                     OUT NOCOPY clmv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clmv_rec                     clmv_rec_type := p_clmv_rec;
      l_def_clmv_rec                 clmv_rec_type;
      l_db_clmv_rec                  clmv_rec_type;
      l_clm_rec                      clm_rec_type;
      lx_clm_rec                     clm_rec_type;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
      lx_okl_ins_claims_tl_rec       okl_ins_claims_tl_rec_type;
      -------------------------------
      -- FUNCTION fill_who_columns --
      -------------------------------
      FUNCTION fill_who_columns (
        p_clmv_rec IN clmv_rec_type
      ) RETURN clmv_rec_type IS
        l_clmv_rec clmv_rec_type := p_clmv_rec;
      BEGIN
        l_clmv_rec.LAST_UPDATE_DATE := SYSDATE;
        l_clmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        l_clmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
        RETURN(l_clmv_rec);
      END fill_who_columns;
      ----------------------------------
      -- FUNCTION populate_new_record --
      ----------------------------------
      FUNCTION populate_new_record (
        p_clmv_rec IN clmv_rec_type,
        x_clmv_rec OUT NOCOPY clmv_rec_type
      ) RETURN VARCHAR2 IS
        l_row_notfound                 BOOLEAN := TRUE;
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_clmv_rec := p_clmv_rec;
        -- Get current database values
        -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
        --       so it may be verified through LOCK_ROW.
        l_db_clmv_rec := get_rec(p_clmv_rec, l_return_status);
        IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
          IF (x_clmv_rec.id = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.id := l_db_clmv_rec.id;
          END IF;
          IF (x_clmv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.sfwt_flag := l_db_clmv_rec.sfwt_flag;
          END IF;
          IF (x_clmv_rec.ipy_id = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.ipy_id := l_db_clmv_rec.ipy_id;
          END IF;
          IF (x_clmv_rec.ltp_code = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.ltp_code := l_db_clmv_rec.ltp_code;
          END IF;
          IF (x_clmv_rec.csu_code = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.csu_code := l_db_clmv_rec.csu_code;
          END IF;
          IF (x_clmv_rec.claim_number = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.claim_number := l_db_clmv_rec.claim_number;
          END IF;
          IF (x_clmv_rec.claim_date = OKC_API.G_MISS_DATE)
          THEN
            x_clmv_rec.claim_date := l_db_clmv_rec.claim_date;
          END IF;
          IF (x_clmv_rec.loss_date = OKC_API.G_MISS_DATE)
          THEN
            x_clmv_rec.loss_date := l_db_clmv_rec.loss_date;
          END IF;
          IF (x_clmv_rec.description = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.description := l_db_clmv_rec.description;
          END IF;
          IF (x_clmv_rec.police_contact = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.police_contact := l_db_clmv_rec.police_contact;
          END IF;
          IF (x_clmv_rec.police_report = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.police_report := l_db_clmv_rec.police_report;
          END IF;
          IF (x_clmv_rec.amount = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.amount := l_db_clmv_rec.amount;
          END IF;
          IF (x_clmv_rec.attribute_category = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute_category := l_db_clmv_rec.attribute_category;
          END IF;
          IF (x_clmv_rec.attribute1 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute1 := l_db_clmv_rec.attribute1;
          END IF;
          IF (x_clmv_rec.attribute2 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute2 := l_db_clmv_rec.attribute2;
          END IF;
          IF (x_clmv_rec.attribute3 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute3 := l_db_clmv_rec.attribute3;
          END IF;
          IF (x_clmv_rec.attribute4 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute4 := l_db_clmv_rec.attribute4;
          END IF;
          IF (x_clmv_rec.attribute5 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute5 := l_db_clmv_rec.attribute5;
          END IF;
          IF (x_clmv_rec.attribute6 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute6 := l_db_clmv_rec.attribute6;
          END IF;
          IF (x_clmv_rec.attribute7 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute7 := l_db_clmv_rec.attribute7;
          END IF;
          IF (x_clmv_rec.attribute8 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute8 := l_db_clmv_rec.attribute8;
          END IF;
          IF (x_clmv_rec.attribute9 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute9 := l_db_clmv_rec.attribute9;
          END IF;
          IF (x_clmv_rec.attribute10 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute10 := l_db_clmv_rec.attribute10;
          END IF;
          IF (x_clmv_rec.attribute11 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute11 := l_db_clmv_rec.attribute11;
          END IF;
          IF (x_clmv_rec.attribute12 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute12 := l_db_clmv_rec.attribute12;
          END IF;
          IF (x_clmv_rec.attribute13 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute13 := l_db_clmv_rec.attribute13;
          END IF;
          IF (x_clmv_rec.attribute14 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute14 := l_db_clmv_rec.attribute14;
          END IF;
          IF (x_clmv_rec.attribute15 = OKC_API.G_MISS_CHAR)
          THEN
            x_clmv_rec.attribute15 := l_db_clmv_rec.attribute15;
          END IF;
          IF (x_clmv_rec.hold_date = OKC_API.G_MISS_DATE)
          THEN
            x_clmv_rec.hold_date := l_db_clmv_rec.hold_date;
          END IF;
          IF (x_clmv_rec.org_id = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.org_id := l_db_clmv_rec.org_id;
          END IF;
          IF (x_clmv_rec.request_id = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.request_id := l_db_clmv_rec.request_id;
          END IF;
          IF (x_clmv_rec.program_application_id = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.program_application_id := l_db_clmv_rec.program_application_id;
          END IF;
          IF (x_clmv_rec.program_id = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.program_id := l_db_clmv_rec.program_id;
          END IF;
          IF (x_clmv_rec.program_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_clmv_rec.program_update_date := l_db_clmv_rec.program_update_date;
          END IF;
          IF (x_clmv_rec.created_by = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.created_by := l_db_clmv_rec.created_by;
          END IF;
          IF (x_clmv_rec.creation_date = OKC_API.G_MISS_DATE)
          THEN
            x_clmv_rec.creation_date := l_db_clmv_rec.creation_date;
          END IF;
          IF (x_clmv_rec.last_updated_by = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.last_updated_by := l_db_clmv_rec.last_updated_by;
          END IF;
          IF (x_clmv_rec.last_update_date = OKC_API.G_MISS_DATE)
          THEN
            x_clmv_rec.last_update_date := l_db_clmv_rec.last_update_date;
          END IF;
          IF (x_clmv_rec.last_update_login = OKC_API.G_MISS_NUM)
          THEN
            x_clmv_rec.last_update_login := l_db_clmv_rec.last_update_login;
          END IF;
        END IF;
        RETURN(l_return_status);
      END populate_new_record;
      -----------------------------------------
      -- Set_Attributes for:OKL_INS_CLAIMS_V --
      -----------------------------------------
      FUNCTION Set_Attributes (
        p_clmv_rec IN clmv_rec_type,
        x_clmv_rec OUT NOCOPY clmv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      BEGIN
        x_clmv_rec := p_clmv_rec;
    --Smoduga added for inventory org fix 3348924
        x_clmv_rec.org_id := get_inv_org_id(p_clmv_rec.ipy_id);
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
        p_clmv_rec,                        -- IN
        x_clmv_rec);                       -- OUT
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := populate_new_record(l_clmv_rec, l_def_clmv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_def_clmv_rec := fill_who_columns(l_def_clmv_rec);
      --- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_def_clmv_rec);
      --- If any errors happen abort API
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      l_return_status := Validate_Record(l_def_clmv_rec, l_db_clmv_rec);
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
        p_clmv_rec                     => p_clmv_rec);
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      -----------------------------------------
      -- Move VIEW record to "Child" records --
      -----------------------------------------
      migrate(l_def_clmv_rec, l_clm_rec);
      migrate(l_def_clmv_rec, l_okl_ins_claims_tl_rec);
      -----------------------------------------------
      -- Call the UPDATE_ROW for each child record --
      -----------------------------------------------
      update_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_clm_rec,
        lx_clm_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_clm_rec, l_def_clmv_rec);
      update_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_claims_tl_rec,
        lx_okl_ins_claims_tl_rec
      );
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      migrate(lx_okl_ins_claims_tl_rec, l_def_clmv_rec);
      x_clmv_rec := l_def_clmv_rec;
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
    -- PL/SQL TBL update_row for:clmv_tbl --
    ----------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        i := p_clmv_tbl.FIRST;
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
              p_clmv_rec                     => p_clmv_tbl(i),
              x_clmv_rec                     => x_clmv_tbl(i));
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
          EXIT WHEN (i = p_clmv_tbl.LAST);
          i := p_clmv_tbl.NEXT(i);
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
    -- PL/SQL TBL update_row for:CLMV_TBL --
    ----------------------------------------
    PROCEDURE update_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      x_clmv_tbl                     OUT NOCOPY clmv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clmv_tbl                     => p_clmv_tbl,
          x_clmv_tbl                     => x_clmv_tbl,
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
    -- delete_row for:OKL_INS_CLAIMS_B --
    -------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clm_rec                      IN clm_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clm_rec                      clm_rec_type := p_clm_rec;
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
      DELETE FROM OKL_INS_CLAIMS_B
       WHERE ID = p_clm_rec.id;
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
    --------------------------------------
    -- delete_row for:OKL_INS_CLAIMS_TL --
    --------------------------------------
    PROCEDURE delete_row(
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_okl_ins_claims_tl_rec        IN okl_ins_claims_tl_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type := p_okl_ins_claims_tl_rec;
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
      DELETE FROM OKL_INS_CLAIMS_TL
       WHERE ID = p_okl_ins_claims_tl_rec.id;
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
    -------------------------------------
    -- delete_row for:OKL_INS_CLAIMS_V --
    -------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_rec                     IN clmv_rec_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_clmv_rec                     clmv_rec_type := p_clmv_rec;
      l_okl_ins_claims_tl_rec        okl_ins_claims_tl_rec_type;
      l_clm_rec                      clm_rec_type;
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
      migrate(l_clmv_rec, l_okl_ins_claims_tl_rec);
      migrate(l_clmv_rec, l_clm_rec);
      -----------------------------------------------
      -- Call the DELETE_ROW for each child record --
      -----------------------------------------------
      delete_row(
        p_init_msg_list,
        l_return_status,
        x_msg_count,
        x_msg_data,
        l_okl_ins_claims_tl_rec
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
        l_clm_rec
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
    ------------------------------------------------
    -- PL/SQL TBL delete_row for:OKL_INS_CLAIMS_V --
    ------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type,
      px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
      i                              NUMBER := 0;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        i := p_clmv_tbl.FIRST;
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
              p_clmv_rec                     => p_clmv_tbl(i));
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
          EXIT WHEN (i = p_clmv_tbl.LAST);
          i := p_clmv_tbl.NEXT(i);
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
    ------------------------------------------------
    -- PL/SQL TBL delete_row for:OKL_INS_CLAIMS_V --
    ------------------------------------------------
    PROCEDURE delete_row(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 ,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_clmv_tbl                     IN clmv_tbl_type) IS
      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
    BEGIN
      OKC_API.init_msg_list(p_init_msg_list);
      -- Make sure PL/SQL table has records in it before passing
      IF (p_clmv_tbl.COUNT > 0) THEN
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_clmv_tbl                     => p_clmv_tbl,
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
  END OKL_CLM_PVT;

/
