--------------------------------------------------------
--  DDL for Package Body OKS_SUBSCR_HDR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_SUBSCR_HDR_PVT" AS
/* $Header: OKSSBHRB.pls 120.2 2005/08/03 05:43:21 parkumar noship $ */
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
    DELETE FROM OKS_SUBSCR_HEADER_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKS_SUBSCR_HEADER_B B
         WHERE B.ID =T.ID
        );

    UPDATE OKS_SUBSCR_HEADER_TL T SET(
        NAME,
        DESCRIPTION,
        COMMENTS) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION,
                                  B.COMMENTS
                                FROM OKS_SUBSCR_HEADER_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKS_SUBSCR_HEADER_TL SUBB, OKS_SUBSCR_HEADER_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
              ));

    INSERT INTO OKS_SUBSCR_HEADER_TL (
        ID,
        NAME,
        DESCRIPTION,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            B.NAME,
            B.DESCRIPTION,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKS_SUBSCR_HEADER_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKS_SUBSCR_HEADER_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_SUBSCR_HEADER_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_schv_rec                     IN schv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN schv_rec_type IS
    CURSOR oks_sch_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            NAME,
            DESCRIPTION,
            CLE_ID,
            DNZ_CHR_ID,
            INSTANCE_ID,
            SFWT_FLAG,
            SUBSCRIPTION_TYPE,
            ITEM_TYPE,
            MEDIA_TYPE,
            STATUS,
            FREQUENCY,
            FULFILLMENT_CHANNEL,
            OFFSET,
            COMMENTS,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_Subscr_Header_V
     WHERE oks_subscr_header_v.id = p_id;
    l_oks_sch_pk                   oks_sch_pk_csr%ROWTYPE;
    l_schv_rec                     schv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_sch_pk_csr (p_schv_rec.id);
    FETCH oks_sch_pk_csr INTO
              l_schv_rec.id,
              l_schv_rec.name,
              l_schv_rec.description,
              l_schv_rec.cle_id,
              l_schv_rec.dnz_chr_id,
              l_schv_rec.instance_id,
              l_schv_rec.sfwt_flag,
              l_schv_rec.subscription_type,
              l_schv_rec.item_type,
              l_schv_rec.media_type,
              l_schv_rec.status,
              l_schv_rec.frequency,
              l_schv_rec.fulfillment_channel,
              l_schv_rec.offset,
              l_schv_rec.comments,
              l_schv_rec.upg_orig_system_ref,
              l_schv_rec.upg_orig_system_ref_id,
              l_schv_rec.object_version_number,
              l_schv_rec.created_by,
              l_schv_rec.creation_date,
              l_schv_rec.last_updated_by,
              l_schv_rec.last_update_date,
              l_schv_rec.last_update_login;
    x_no_data_found := oks_sch_pk_csr%NOTFOUND;
    CLOSE oks_sch_pk_csr;
    RETURN(l_schv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_schv_rec                     IN schv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN schv_rec_type IS
    l_schv_rec                     schv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_schv_rec := get_rec(p_schv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_schv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_schv_rec                     IN schv_rec_type
  ) RETURN schv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_schv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_SUBSCR_HEADER_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sbh_rec                      IN sbh_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sbh_rec_type IS
    CURSOR oks_subscr_header_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            INSTANCE_ID,
            SUBSCRIPTION_TYPE,
            ITEM_TYPE,
            MEDIA_TYPE,
            STATUS,
            FREQUENCY,
            FULFILLMENT_CHANNEL,
            OFFSET,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
-- R12 Data Model Changes 4485150 Start
            ORIG_SYSTEM_ID1,
            ORIG_SYSTEM_REFERENCE1,
            ORIG_SYSTEM_SOURCE_CODE
-- R12 Data Model Changes 4485150 End
      FROM Oks_Subscr_Header_B
     WHERE oks_subscr_header_b.id = p_id;
    l_oks_subscr_header_b_pk       oks_subscr_header_b_pk_csr%ROWTYPE;
    l_sbh_rec                      sbh_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_subscr_header_b_pk_csr (p_sbh_rec.id);
    FETCH oks_subscr_header_b_pk_csr INTO
              l_sbh_rec.id,
              l_sbh_rec.cle_id,
              l_sbh_rec.dnz_chr_id,
              l_sbh_rec.instance_id,
              l_sbh_rec.subscription_type,
              l_sbh_rec.item_type,
              l_sbh_rec.media_type,
              l_sbh_rec.status,
              l_sbh_rec.frequency,
              l_sbh_rec.fulfillment_channel,
              l_sbh_rec.offset,
              l_sbh_rec.upg_orig_system_ref,
              l_sbh_rec.upg_orig_system_ref_id,
              l_sbh_rec.object_version_number,
              l_sbh_rec.created_by,
              l_sbh_rec.creation_date,
              l_sbh_rec.last_updated_by,
              l_sbh_rec.last_update_date,
              l_sbh_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
              l_sbh_rec.orig_system_id1,
              l_sbh_rec.orig_system_reference1,
              l_sbh_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
;
    x_no_data_found := oks_subscr_header_b_pk_csr%NOTFOUND;
    CLOSE oks_subscr_header_b_pk_csr;
    RETURN(l_sbh_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sbh_rec                      IN sbh_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sbh_rec_type IS
    l_sbh_rec                      sbh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_sbh_rec := get_rec(p_sbh_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_sbh_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sbh_rec                      IN sbh_rec_type
  ) RETURN sbh_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sbh_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_SUBSCR_HEADER_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_subscr_header_tl_rec     IN oks_subscr_header_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oks_subscr_header_tl_rec_type IS
    CURSOR oks_subscr_header_tl_pk_csr (p_id       IN NUMBER,
                                        p_language IN VARCHAR2) IS
    SELECT
            ID,
            NAME,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_Subscr_Header_Tl
     WHERE oks_subscr_header_tl.id = p_id
       AND oks_subscr_header_tl.language = p_language;
    l_oks_subscr_header_tl_pk      oks_subscr_header_tl_pk_csr%ROWTYPE;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_subscr_header_tl_pk_csr (p_oks_subscr_header_tl_rec.id,
                                      p_oks_subscr_header_tl_rec.language);
    FETCH oks_subscr_header_tl_pk_csr INTO
              l_oks_subscr_header_tl_rec.id,
              l_oks_subscr_header_tl_rec.name,
              l_oks_subscr_header_tl_rec.description,
              l_oks_subscr_header_tl_rec.language,
              l_oks_subscr_header_tl_rec.source_lang,
              l_oks_subscr_header_tl_rec.sfwt_flag,
              l_oks_subscr_header_tl_rec.comments,
              l_oks_subscr_header_tl_rec.created_by,
              l_oks_subscr_header_tl_rec.creation_date,
              l_oks_subscr_header_tl_rec.last_updated_by,
              l_oks_subscr_header_tl_rec.last_update_date,
              l_oks_subscr_header_tl_rec.last_update_login;
    x_no_data_found := oks_subscr_header_tl_pk_csr%NOTFOUND;
    CLOSE oks_subscr_header_tl_pk_csr;
    RETURN(l_oks_subscr_header_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_oks_subscr_header_tl_rec     IN oks_subscr_header_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN oks_subscr_header_tl_rec_type IS
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_oks_subscr_header_tl_rec := get_rec(p_oks_subscr_header_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_oks_subscr_header_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_oks_subscr_header_tl_rec     IN oks_subscr_header_tl_rec_type
  ) RETURN oks_subscr_header_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_oks_subscr_header_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_SUBSCR_HEADER_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_schv_rec   IN schv_rec_type
  ) RETURN schv_rec_type IS
    l_schv_rec                     schv_rec_type := p_schv_rec;
  BEGIN
    IF (l_schv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.id := NULL;
    END IF;
    IF (l_schv_rec.name = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.name := NULL;
    END IF;
    IF (l_schv_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.description := NULL;
    END IF;
    IF (l_schv_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.cle_id := NULL;
    END IF;
    IF (l_schv_rec.dnz_chr_id = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_schv_rec.instance_id = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.instance_id := NULL;
    END IF;
    IF (l_schv_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_schv_rec.subscription_type = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.subscription_type := NULL;
    END IF;
    IF (l_schv_rec.item_type = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.item_type := NULL;
    END IF;
    IF (l_schv_rec.media_type = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.media_type := NULL;
    END IF;
    IF (l_schv_rec.status = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.status := NULL;
    END IF;
    IF (l_schv_rec.frequency = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.frequency := NULL;
    END IF;
    IF (l_schv_rec.fulfillment_channel = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.fulfillment_channel := NULL;
    END IF;
    IF (l_schv_rec.offset = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.offset := NULL;
    END IF;
    IF (l_schv_rec.comments = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.comments := NULL;
    END IF;
    IF (l_schv_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR ) THEN
      l_schv_rec.upg_orig_system_ref := NULL;
    END IF;
    IF (l_schv_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.upg_orig_system_ref_id := NULL;
    END IF;
    IF (l_schv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.object_version_number := NULL;
    END IF;
    IF (l_schv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.created_by := NULL;
    END IF;
    IF (l_schv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_schv_rec.creation_date := NULL;
    END IF;
    IF (l_schv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.last_updated_by := NULL;
    END IF;
    IF (l_schv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_schv_rec.last_update_date := NULL;
    END IF;
    IF (l_schv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_schv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_schv_rec);
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
  -----------------------------------
  -- Validate_Attributes for: NAME --
  -----------------------------------
  PROCEDURE validate_name(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_name                         IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_name = OKC_API.G_MISS_CHAR OR
        p_name IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'name');
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
  END validate_name;
  -----------------------------------------
  -- Validate_Attributes for: DNZ_CHR_ID --
  -----------------------------------------
  PROCEDURE validate_dnz_chr_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_dnz_chr_id                   IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_dnz_chr_id = OKC_API.G_MISS_NUM OR
        p_dnz_chr_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'dnz_chr_id');
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
  END validate_dnz_chr_id;
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
  ------------------------------------------------
  -- Validate_Attributes for: SUBSCRIPTION_TYPE --
  ------------------------------------------------
  PROCEDURE validate_subscription_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_subscription_type            IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_subscription_type = OKC_API.G_MISS_CHAR OR
        p_subscription_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'subscription_type');
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
  END validate_subscription_type;
  ----------------------------------------
  -- Validate_Attributes for: FREQUENCY --
  ----------------------------------------
  PROCEDURE validate_frequency(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_frequency                    IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_frequency = OKC_API.G_MISS_CHAR OR
        p_frequency IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'frequency');
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
  END validate_frequency;
  --------------------------------------------------
  -- Validate_Attributes for: FULFILLMENT_CHANNEL --
  --------------------------------------------------
  PROCEDURE validate_fulfillment_channel(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_fulfillment_channel          IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_fulfillment_channel = OKC_API.G_MISS_CHAR OR
        p_fulfillment_channel IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'fulfillment_channel');
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
  END validate_fulfillment_channel;
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
  -------------------------------------------------
  -- Validate_Attributes for:OKS_SUBSCR_HEADER_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_schv_rec                     IN schv_rec_type
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
    validate_id(x_return_status, p_schv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- name
    -- ***
    validate_name(x_return_status, p_schv_rec.name);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- dnz_chr_id
    -- ***
    validate_dnz_chr_id(x_return_status, p_schv_rec.dnz_chr_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(x_return_status, p_schv_rec.sfwt_flag);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- subscription_type
    -- ***
    validate_subscription_type(x_return_status, p_schv_rec.subscription_type);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- frequency
    -- ***
    validate_frequency(x_return_status, p_schv_rec.frequency);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- fulfillment_channel
    -- ***
    validate_fulfillment_channel(x_return_status, p_schv_rec.fulfillment_channel);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_schv_rec.object_version_number);
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
  ---------------------------------------------
  -- Validate Record for:OKS_SUBSCR_HEADER_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_schv_rec IN schv_rec_type,
    p_db_schv_rec IN schv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_schv_rec IN schv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_schv_rec                  schv_rec_type := get_rec(p_schv_rec);
  BEGIN
    l_return_status := Validate_Record(p_schv_rec => p_schv_rec,
                                       p_db_schv_rec => l_db_schv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN schv_rec_type,
    p_to   IN OUT NOCOPY sbh_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.instance_id := p_from.instance_id;
    p_to.subscription_type := p_from.subscription_type;
    p_to.item_type := p_from.item_type;
    p_to.media_type := p_from.media_type;
    p_to.status := p_from.status;
    p_to.frequency := p_from.frequency;
    p_to.fulfillment_channel := p_from.fulfillment_channel;
    p_to.offset := p_from.offset;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN sbh_rec_type,
    p_to   IN OUT NOCOPY schv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.instance_id := p_from.instance_id;
    p_to.subscription_type := p_from.subscription_type;
    p_to.item_type := p_from.item_type;
    p_to.media_type := p_from.media_type;
    p_to.status := p_from.status;
    p_to.frequency := p_from.frequency;
    p_to.fulfillment_channel := p_from.fulfillment_channel;
    p_to.offset := p_from.offset;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN schv_rec_type,
    p_to   IN OUT NOCOPY oks_subscr_header_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN oks_subscr_header_tl_rec_type,
    p_to   IN OUT NOCOPY schv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.sfwt_flag := p_from.sfwt_flag;
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
  ------------------------------------------
  -- validate_row for:OKS_SUBSCR_HEADER_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_schv_rec                     schv_rec_type := p_schv_rec;
    l_sbh_rec                      sbh_rec_type;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_schv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_schv_rec);
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
  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_SUBSCR_HEADER_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      i := p_schv_tbl.FIRST;
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
            p_schv_rec                     => p_schv_tbl(i));
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
        EXIT WHEN (i = p_schv_tbl.LAST);
        i := p_schv_tbl.NEXT(i);
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

  -----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_SUBSCR_HEADER_V --
  -----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_schv_tbl                     => p_schv_tbl,
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
  -- insert_row for:OKS_SUBSCR_HEADER_B --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sbh_rec                      IN sbh_rec_type,
    x_sbh_rec                      OUT NOCOPY sbh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sbh_rec                      sbh_rec_type := p_sbh_rec;
    l_def_sbh_rec                  sbh_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKS_SUBSCR_HEADER_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sbh_rec IN sbh_rec_type,
      x_sbh_rec OUT NOCOPY sbh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sbh_rec := p_sbh_rec;
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
      p_sbh_rec,                         -- IN
      l_sbh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_SUBSCR_HEADER_B(
      id,
      cle_id,
      dnz_chr_id,
      instance_id,
      subscription_type,
      item_type,
      media_type,
      status,
      frequency,
      fulfillment_channel,
      offset,
      upg_orig_system_ref,
      upg_orig_system_ref_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
-- R12 Data Model Changes 4485150 Start
      orig_system_id1,
      orig_system_reference1,
      orig_system_source_code
-- R12 Data Model Changes 4485150 End
)
    VALUES (
      l_sbh_rec.id,
      l_sbh_rec.cle_id,
      l_sbh_rec.dnz_chr_id,
      l_sbh_rec.instance_id,
      l_sbh_rec.subscription_type,
      l_sbh_rec.item_type,
      l_sbh_rec.media_type,
      l_sbh_rec.status,
      l_sbh_rec.frequency,
      l_sbh_rec.fulfillment_channel,
      l_sbh_rec.offset,
      l_sbh_rec.upg_orig_system_ref,
      l_sbh_rec.upg_orig_system_ref_id,
      l_sbh_rec.object_version_number,
      l_sbh_rec.created_by,
      l_sbh_rec.creation_date,
      l_sbh_rec.last_updated_by,
      l_sbh_rec.last_update_date,
      l_sbh_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
      l_sbh_rec.orig_system_id1,
      l_sbh_rec.orig_system_reference1,
      l_sbh_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
);
    -- Set OUT values
    x_sbh_rec := l_sbh_rec;
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
  -----------------------------------------
  -- insert_row for:OKS_SUBSCR_HEADER_TL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_subscr_header_tl_rec     IN oks_subscr_header_tl_rec_type,
    x_oks_subscr_header_tl_rec     OUT NOCOPY oks_subscr_header_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type := p_oks_subscr_header_tl_rec;
    l_def_oks_subscr_header_tl_rec oks_subscr_header_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------
    -- Set_Attributes for:OKS_SUBSCR_HEADER_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_subscr_header_tl_rec IN oks_subscr_header_tl_rec_type,
      x_oks_subscr_header_tl_rec OUT NOCOPY oks_subscr_header_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_subscr_header_tl_rec := p_oks_subscr_header_tl_rec;
      x_oks_subscr_header_tl_rec.LANGUAGE := USERENV('LANG');
      x_oks_subscr_header_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_oks_subscr_header_tl_rec,        -- IN
      l_oks_subscr_header_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_oks_subscr_header_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKS_SUBSCR_HEADER_TL(
        id,
        name,
        description,
        language,
        source_lang,
        sfwt_flag,
        comments,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_oks_subscr_header_tl_rec.id,
        l_oks_subscr_header_tl_rec.name,
        l_oks_subscr_header_tl_rec.description,
        l_oks_subscr_header_tl_rec.language,
        l_oks_subscr_header_tl_rec.source_lang,
        l_oks_subscr_header_tl_rec.sfwt_flag,
        l_oks_subscr_header_tl_rec.comments,
        l_oks_subscr_header_tl_rec.created_by,
        l_oks_subscr_header_tl_rec.creation_date,
        l_oks_subscr_header_tl_rec.last_updated_by,
        l_oks_subscr_header_tl_rec.last_update_date,
        l_oks_subscr_header_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_oks_subscr_header_tl_rec := l_oks_subscr_header_tl_rec;
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
  -----------------------------------------
  -- insert_row for :OKS_SUBSCR_HEADER_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type,
    x_schv_rec                     OUT NOCOPY schv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_schv_rec                     schv_rec_type := p_schv_rec;
    l_def_schv_rec                 schv_rec_type;
    l_sbh_rec                      sbh_rec_type;
    lx_sbh_rec                     sbh_rec_type;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
    lx_oks_subscr_header_tl_rec    oks_subscr_header_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_schv_rec IN schv_rec_type
    ) RETURN schv_rec_type IS
      l_schv_rec schv_rec_type := p_schv_rec;
    BEGIN
      l_schv_rec.CREATION_DATE := SYSDATE;
      l_schv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_schv_rec.LAST_UPDATE_DATE := l_schv_rec.CREATION_DATE;
      l_schv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_schv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_schv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKS_SUBSCR_HEADER_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_schv_rec IN schv_rec_type,
      x_schv_rec OUT NOCOPY schv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_schv_rec := p_schv_rec;
      x_schv_rec.OBJECT_VERSION_NUMBER := 1;
      x_schv_rec.SFWT_FLAG := 'N';
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
    l_schv_rec := null_out_defaults(p_schv_rec);
    -- Set primary key value
    l_schv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_schv_rec,                        -- IN
      l_def_schv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_schv_rec := fill_who_columns(l_def_schv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_schv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_schv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_schv_rec, l_sbh_rec);
    migrate(l_def_schv_rec, l_oks_subscr_header_tl_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sbh_rec,
      lx_sbh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sbh_rec, l_def_schv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_subscr_header_tl_rec,
      lx_oks_subscr_header_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oks_subscr_header_tl_rec, l_def_schv_rec);
    -- Set OUT values
    x_schv_rec := l_def_schv_rec;
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
  -- PL/SQL TBL insert_row for:SCHV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      i := p_schv_tbl.FIRST;
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
            p_schv_rec                     => p_schv_tbl(i),
            x_schv_rec                     => x_schv_tbl(i));
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
        EXIT WHEN (i = p_schv_tbl.LAST);
        i := p_schv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:SCHV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_schv_tbl                     => p_schv_tbl,
        x_schv_tbl                     => x_schv_tbl,
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
  -- lock_row for:OKS_SUBSCR_HEADER_B --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sbh_rec                      IN sbh_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sbh_rec IN sbh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_SUBSCR_HEADER_B
     WHERE ID = p_sbh_rec.id
       AND OBJECT_VERSION_NUMBER = p_sbh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_sbh_rec IN sbh_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_SUBSCR_HEADER_B
     WHERE ID = p_sbh_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_SUBSCR_HEADER_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_SUBSCR_HEADER_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sbh_rec);
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
      OPEN lchk_csr(p_sbh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sbh_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sbh_rec.object_version_number THEN
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
  ---------------------------------------
  -- lock_row for:OKS_SUBSCR_HEADER_TL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_subscr_header_tl_rec     IN oks_subscr_header_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oks_subscr_header_tl_rec IN oks_subscr_header_tl_rec_type) IS
    SELECT *
      FROM OKS_SUBSCR_HEADER_TL
     WHERE ID = p_oks_subscr_header_tl_rec.id
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
      OPEN lock_csr(p_oks_subscr_header_tl_rec);
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
  ---------------------------------------
  -- lock_row for: OKS_SUBSCR_HEADER_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sbh_rec                      sbh_rec_type;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
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
    migrate(p_schv_rec, l_sbh_rec);
    migrate(p_schv_rec, l_oks_subscr_header_tl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sbh_rec
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
      l_oks_subscr_header_tl_rec
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
  -- PL/SQL TBL lock_row for:SCHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      i := p_schv_tbl.FIRST;
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
            p_schv_rec                     => p_schv_tbl(i));
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
        EXIT WHEN (i = p_schv_tbl.LAST);
        i := p_schv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:SCHV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_schv_tbl                     => p_schv_tbl,
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
  -- update_row for:OKS_SUBSCR_HEADER_B --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sbh_rec                      IN sbh_rec_type,
    x_sbh_rec                      OUT NOCOPY sbh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sbh_rec                      sbh_rec_type := p_sbh_rec;
    l_def_sbh_rec                  sbh_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sbh_rec IN sbh_rec_type,
      x_sbh_rec OUT NOCOPY sbh_rec_type
    ) RETURN VARCHAR2 IS
      l_sbh_rec                      sbh_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sbh_rec := p_sbh_rec;
      -- Get current database values
      l_sbh_rec := get_rec(p_sbh_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_sbh_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.id := l_sbh_rec.id;
        END IF;
        IF (x_sbh_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.cle_id := l_sbh_rec.cle_id;
        END IF;
        IF (x_sbh_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.dnz_chr_id := l_sbh_rec.dnz_chr_id;
        END IF;
        IF (x_sbh_rec.instance_id = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.instance_id := l_sbh_rec.instance_id;
        END IF;
        IF (x_sbh_rec.subscription_type = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.subscription_type := l_sbh_rec.subscription_type;
        END IF;
        IF (x_sbh_rec.item_type = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.item_type := l_sbh_rec.item_type;
        END IF;
        IF (x_sbh_rec.media_type = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.media_type := l_sbh_rec.media_type;
        END IF;
        IF (x_sbh_rec.status = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.status := l_sbh_rec.status;
        END IF;
        IF (x_sbh_rec.frequency = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.frequency := l_sbh_rec.frequency;
        END IF;
        IF (x_sbh_rec.fulfillment_channel = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.fulfillment_channel := l_sbh_rec.fulfillment_channel;
        END IF;
        IF (x_sbh_rec.offset = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.offset := l_sbh_rec.offset;
        END IF;
        IF (x_sbh_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.upg_orig_system_ref := l_sbh_rec.upg_orig_system_ref;
        END IF;
        IF (x_sbh_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.upg_orig_system_ref_id := l_sbh_rec.upg_orig_system_ref_id;
        END IF;
        IF (x_sbh_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.object_version_number := l_sbh_rec.object_version_number;
        END IF;
        IF (x_sbh_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.created_by := l_sbh_rec.created_by;
        END IF;
        IF (x_sbh_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_sbh_rec.creation_date := l_sbh_rec.creation_date;
        END IF;
        IF (x_sbh_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.last_updated_by := l_sbh_rec.last_updated_by;
        END IF;
        IF (x_sbh_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_sbh_rec.last_update_date := l_sbh_rec.last_update_date;
        END IF;
        IF (x_sbh_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.last_update_login := l_sbh_rec.last_update_login;
        END IF;

       /*** R12 Data Model Changes Start 27072005***/

        IF (x_sbh_rec.orig_system_id1 = OKC_API.G_MISS_NUM)
        THEN
          x_sbh_rec.orig_system_id1 := l_sbh_rec.orig_system_id1;
        END IF;
        IF (x_sbh_rec.orig_system_reference1 = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.orig_system_reference1 := l_sbh_rec.orig_system_reference1;
        END IF;
        IF (x_sbh_rec.orig_system_source_code = OKC_API.G_MISS_CHAR)
        THEN
          x_sbh_rec.orig_system_source_code := l_sbh_rec.orig_system_source_code;
        END IF;

       /*** R12 Data Model Changes End  27072005 ***/

      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKS_SUBSCR_HEADER_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_sbh_rec IN sbh_rec_type,
      x_sbh_rec OUT NOCOPY sbh_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sbh_rec := p_sbh_rec;
      x_sbh_rec.OBJECT_VERSION_NUMBER := p_sbh_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_sbh_rec,                         -- IN
      l_sbh_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sbh_rec, l_def_sbh_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_SUBSCR_HEADER_B
    SET CLE_ID = l_def_sbh_rec.cle_id,
        DNZ_CHR_ID = l_def_sbh_rec.dnz_chr_id,
        INSTANCE_ID = l_def_sbh_rec.instance_id,
        SUBSCRIPTION_TYPE = l_def_sbh_rec.subscription_type,
        ITEM_TYPE = l_def_sbh_rec.item_type,
        MEDIA_TYPE = l_def_sbh_rec.media_type,
        STATUS = l_def_sbh_rec.status,
        FREQUENCY = l_def_sbh_rec.frequency,
        FULFILLMENT_CHANNEL = l_def_sbh_rec.fulfillment_channel,
        OFFSET = l_def_sbh_rec.offset,
        UPG_ORIG_SYSTEM_REF = l_def_sbh_rec.upg_orig_system_ref,
        UPG_ORIG_SYSTEM_REF_ID = l_def_sbh_rec.upg_orig_system_ref_id,
        OBJECT_VERSION_NUMBER = l_def_sbh_rec.object_version_number,
        CREATED_BY = l_def_sbh_rec.created_by,
        CREATION_DATE = l_def_sbh_rec.creation_date,
        LAST_UPDATED_BY = l_def_sbh_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sbh_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sbh_rec.last_update_login,
-- R12 Data Model Changes 4485150 Start
        ORIG_SYSTEM_ID1	= l_def_sbh_rec.orig_system_id1,
        ORIG_SYSTEM_REFERENCE1	= l_def_sbh_rec.orig_system_reference1,
        ORIG_SYSTEM_SOURCE_CODE	= l_def_sbh_rec.orig_system_source_code
-- R12 Data Model Changes 4485150 End
    WHERE ID = l_def_sbh_rec.id;

    x_sbh_rec := l_sbh_rec;
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
  -----------------------------------------
  -- update_row for:OKS_SUBSCR_HEADER_TL --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_subscr_header_tl_rec     IN oks_subscr_header_tl_rec_type,
    x_oks_subscr_header_tl_rec     OUT NOCOPY oks_subscr_header_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type := p_oks_subscr_header_tl_rec;
    l_def_oks_subscr_header_tl_rec oks_subscr_header_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oks_subscr_header_tl_rec IN oks_subscr_header_tl_rec_type,
      x_oks_subscr_header_tl_rec OUT NOCOPY oks_subscr_header_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_subscr_header_tl_rec := p_oks_subscr_header_tl_rec;
      -- Get current database values
      l_oks_subscr_header_tl_rec := get_rec(p_oks_subscr_header_tl_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_oks_subscr_header_tl_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_oks_subscr_header_tl_rec.id := l_oks_subscr_header_tl_rec.id;
        END IF;
        IF (x_oks_subscr_header_tl_rec.name = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_subscr_header_tl_rec.name := l_oks_subscr_header_tl_rec.name;
        END IF;
        IF (x_oks_subscr_header_tl_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_subscr_header_tl_rec.description := l_oks_subscr_header_tl_rec.description;
        END IF;
        IF (x_oks_subscr_header_tl_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_subscr_header_tl_rec.language := l_oks_subscr_header_tl_rec.language;
        END IF;
        IF (x_oks_subscr_header_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_subscr_header_tl_rec.source_lang := l_oks_subscr_header_tl_rec.source_lang;
        END IF;
        IF (x_oks_subscr_header_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_subscr_header_tl_rec.sfwt_flag := l_oks_subscr_header_tl_rec.sfwt_flag;
        END IF;
        IF (x_oks_subscr_header_tl_rec.comments = OKC_API.G_MISS_CHAR)
        THEN
          x_oks_subscr_header_tl_rec.comments := l_oks_subscr_header_tl_rec.comments;
        END IF;
        IF (x_oks_subscr_header_tl_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_subscr_header_tl_rec.created_by := l_oks_subscr_header_tl_rec.created_by;
        END IF;
        IF (x_oks_subscr_header_tl_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_subscr_header_tl_rec.creation_date := l_oks_subscr_header_tl_rec.creation_date;
        END IF;
        IF (x_oks_subscr_header_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_oks_subscr_header_tl_rec.last_updated_by := l_oks_subscr_header_tl_rec.last_updated_by;
        END IF;
        IF (x_oks_subscr_header_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_oks_subscr_header_tl_rec.last_update_date := l_oks_subscr_header_tl_rec.last_update_date;
        END IF;
        IF (x_oks_subscr_header_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_oks_subscr_header_tl_rec.last_update_login := l_oks_subscr_header_tl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKS_SUBSCR_HEADER_TL --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_oks_subscr_header_tl_rec IN oks_subscr_header_tl_rec_type,
      x_oks_subscr_header_tl_rec OUT NOCOPY oks_subscr_header_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_oks_subscr_header_tl_rec := p_oks_subscr_header_tl_rec;
      x_oks_subscr_header_tl_rec.LANGUAGE := USERENV('LANG');
      x_oks_subscr_header_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_oks_subscr_header_tl_rec,        -- IN
      l_oks_subscr_header_tl_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oks_subscr_header_tl_rec, l_def_oks_subscr_header_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_SUBSCR_HEADER_TL
    SET NAME = l_def_oks_subscr_header_tl_rec.name,
        DESCRIPTION = l_def_oks_subscr_header_tl_rec.description,
        COMMENTS = l_def_oks_subscr_header_tl_rec.comments,
        CREATED_BY = l_def_oks_subscr_header_tl_rec.created_by,
        CREATION_DATE = l_def_oks_subscr_header_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_oks_subscr_header_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_oks_subscr_header_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_oks_subscr_header_tl_rec.last_update_login
    WHERE ID = l_def_oks_subscr_header_tl_rec.id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKS_SUBSCR_HEADER_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_oks_subscr_header_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_oks_subscr_header_tl_rec := l_oks_subscr_header_tl_rec;
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
  -- update_row for:OKS_SUBSCR_HEADER_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type,
    x_schv_rec                     OUT NOCOPY schv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_schv_rec                     schv_rec_type := p_schv_rec;
    l_def_schv_rec                 schv_rec_type;
    l_db_schv_rec                  schv_rec_type;
    l_sbh_rec                      sbh_rec_type;
    lx_sbh_rec                     sbh_rec_type;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
    lx_oks_subscr_header_tl_rec    oks_subscr_header_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_schv_rec IN schv_rec_type
    ) RETURN schv_rec_type IS
      l_schv_rec schv_rec_type := p_schv_rec;
    BEGIN
      l_schv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_schv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_schv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_schv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_schv_rec IN schv_rec_type,
      x_schv_rec OUT NOCOPY schv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_schv_rec := p_schv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_schv_rec := get_rec(p_schv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_schv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.id := l_db_schv_rec.id;
        END IF;
        IF (x_schv_rec.name = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.name := l_db_schv_rec.name;
        END IF;
        IF (x_schv_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.description := l_db_schv_rec.description;
        END IF;
        IF (x_schv_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.cle_id := l_db_schv_rec.cle_id;
        END IF;
        IF (x_schv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.dnz_chr_id := l_db_schv_rec.dnz_chr_id;
        END IF;
        IF (x_schv_rec.instance_id = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.instance_id := l_db_schv_rec.instance_id;
        END IF;
        IF (x_schv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.sfwt_flag := l_db_schv_rec.sfwt_flag;
        END IF;
        IF (x_schv_rec.subscription_type = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.subscription_type := l_db_schv_rec.subscription_type;
        END IF;
        IF (x_schv_rec.item_type = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.item_type := l_db_schv_rec.item_type;
        END IF;
        IF (x_schv_rec.media_type = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.media_type := l_db_schv_rec.media_type;
        END IF;
        IF (x_schv_rec.status = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.status := l_db_schv_rec.status;
        END IF;
        IF (x_schv_rec.frequency = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.frequency := l_db_schv_rec.frequency;
        END IF;
        IF (x_schv_rec.fulfillment_channel = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.fulfillment_channel := l_db_schv_rec.fulfillment_channel;
        END IF;
        IF (x_schv_rec.offset = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.offset := l_db_schv_rec.offset;
        END IF;
        IF (x_schv_rec.comments = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.comments := l_db_schv_rec.comments;
        END IF;
        IF (x_schv_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR)
        THEN
          x_schv_rec.upg_orig_system_ref := l_db_schv_rec.upg_orig_system_ref;
        END IF;
        IF (x_schv_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.upg_orig_system_ref_id := l_db_schv_rec.upg_orig_system_ref_id;
        END IF;
        IF (x_schv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.created_by := l_db_schv_rec.created_by;
        END IF;
        IF (x_schv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_schv_rec.creation_date := l_db_schv_rec.creation_date;
        END IF;
        IF (x_schv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.last_updated_by := l_db_schv_rec.last_updated_by;
        END IF;
        IF (x_schv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_schv_rec.last_update_date := l_db_schv_rec.last_update_date;
        END IF;
        IF (x_schv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_schv_rec.last_update_login := l_db_schv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKS_SUBSCR_HEADER_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_schv_rec IN schv_rec_type,
      x_schv_rec OUT NOCOPY schv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_schv_rec := p_schv_rec;
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
      p_schv_rec,                        -- IN
      x_schv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_schv_rec, l_def_schv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_schv_rec := fill_who_columns(l_def_schv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_schv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_schv_rec, l_db_schv_rec);
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
      p_schv_rec                     => p_schv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_schv_rec, l_sbh_rec);
    migrate(l_def_schv_rec, l_oks_subscr_header_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sbh_rec,
      lx_sbh_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sbh_rec, l_def_schv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_subscr_header_tl_rec,
      lx_oks_subscr_header_tl_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oks_subscr_header_tl_rec, l_def_schv_rec);
    x_schv_rec := l_def_schv_rec;
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
  -- PL/SQL TBL update_row for:schv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      i := p_schv_tbl.FIRST;
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
            p_schv_rec                     => p_schv_tbl(i),
            x_schv_rec                     => x_schv_tbl(i));
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
        EXIT WHEN (i = p_schv_tbl.LAST);
        i := p_schv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:SCHV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    x_schv_tbl                     OUT NOCOPY schv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_schv_tbl                     => p_schv_tbl,
        x_schv_tbl                     => x_schv_tbl,
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
  -- delete_row for:OKS_SUBSCR_HEADER_B --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sbh_rec                      IN sbh_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sbh_rec                      sbh_rec_type := p_sbh_rec;
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

    DELETE FROM OKS_SUBSCR_HEADER_B
     WHERE ID = p_sbh_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKS_SUBSCR_HEADER_TL --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oks_subscr_header_tl_rec     IN oks_subscr_header_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type := p_oks_subscr_header_tl_rec;
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

    DELETE FROM OKS_SUBSCR_HEADER_TL
     WHERE ID = p_oks_subscr_header_tl_rec.id;

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
  -- delete_row for:OKS_SUBSCR_HEADER_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_rec                     IN schv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_schv_rec                     schv_rec_type := p_schv_rec;
    l_oks_subscr_header_tl_rec     oks_subscr_header_tl_rec_type;
    l_sbh_rec                      sbh_rec_type;
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
    migrate(l_schv_rec, l_oks_subscr_header_tl_rec);
    migrate(l_schv_rec, l_sbh_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_oks_subscr_header_tl_rec
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
      l_sbh_rec
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
  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_SUBSCR_HEADER_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      i := p_schv_tbl.FIRST;
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
            p_schv_rec                     => p_schv_tbl(i));
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
        EXIT WHEN (i = p_schv_tbl.LAST);
        i := p_schv_tbl.NEXT(i);
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

  ---------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_SUBSCR_HEADER_V --
  ---------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_schv_tbl                     IN schv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_schv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_schv_tbl                     => p_schv_tbl,
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

END OKS_SUBSCR_HDR_PVT;

/
