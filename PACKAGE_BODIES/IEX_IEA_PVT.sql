--------------------------------------------------------
--  DDL for Package Body IEX_IEA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_IEA_PVT" AS
/* $Header: IEXSIEAB.pls 120.1 2004/03/17 18:01:31 jsanju ship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

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
  ) RETURN VARCHAR2 AS
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
  FUNCTION get_seq_id RETURN NUMBER AS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc AS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version AS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy AS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language AS
  BEGIN
    DELETE FROM IEX_EXT_AGNCY_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM IEX_EXT_AGNCY_B B
         WHERE B.EXTERNAL_AGENCY_ID =T.EXTERNAL_AGENCY_ID
        );

    UPDATE IEX_EXT_AGNCY_TL T SET(
        DESCRIPTION) = (SELECT
                                  B.DESCRIPTION
                                FROM IEX_EXT_AGNCY_TL B
                               WHERE B.EXTERNAL_AGENCY_ID = T.EXTERNAL_AGENCY_ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.EXTERNAL_AGENCY_ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.EXTERNAL_AGENCY_ID,
                  SUBT.LANGUAGE
                FROM IEX_EXT_AGNCY_TL SUBB, IEX_EXT_AGNCY_TL SUBT
               WHERE SUBB.EXTERNAL_AGENCY_ID = SUBT.EXTERNAL_AGENCY_ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO IEX_EXT_AGNCY_TL (
        EXTERNAL_AGENCY_ID,
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
            B.EXTERNAL_AGENCY_ID,
            B.DESCRIPTION,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM IEX_EXT_AGNCY_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM IEX_EXT_AGNCY_TL T
                     WHERE T.EXTERNAL_AGENCY_ID = B.EXTERNAL_AGENCY_ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: IEX_EXT_AGNCY_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieav_rec                     IN ieav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ieav_rec_type AS
    CURSOR iex_ext_agncy_v_pk_csr (p_external_agency_id IN NUMBER) IS
    SELECT
            EXTERNAL_AGENCY_ID,
            EXTERNAL_AGENCY_NAME,
            VENDOR_ID,
            VENDOR_SITE_ID,
            RANK,
            EFFECTIVE_START_DATE,
            EFFECTIVE_END_DATE,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
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
      FROM Iex_Ext_Agncy_V
     WHERE iex_ext_agncy_v.external_agency_id = p_external_agency_id;
    l_iex_ext_agncy_v_pk           iex_ext_agncy_v_pk_csr%ROWTYPE;
    l_ieav_rec                     ieav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_ext_agncy_v_pk_csr (p_ieav_rec.external_agency_id);
    FETCH iex_ext_agncy_v_pk_csr INTO
              l_ieav_rec.external_agency_id,
              l_ieav_rec.external_agency_name,
              l_ieav_rec.vendor_id,
              l_ieav_rec.vendor_site_id,
              l_ieav_rec.rank,
              l_ieav_rec.effective_start_date,
              l_ieav_rec.effective_end_date,
              l_ieav_rec.description,
              l_ieav_rec.language,
              l_ieav_rec.source_lang,
              l_ieav_rec.sfwt_flag,
              l_ieav_rec.object_version_number,
              l_ieav_rec.org_id,
              l_ieav_rec.attribute_category,
              l_ieav_rec.attribute1,
              l_ieav_rec.attribute2,
              l_ieav_rec.attribute3,
              l_ieav_rec.attribute4,
              l_ieav_rec.attribute5,
              l_ieav_rec.attribute6,
              l_ieav_rec.attribute7,
              l_ieav_rec.attribute8,
              l_ieav_rec.attribute9,
              l_ieav_rec.attribute10,
              l_ieav_rec.attribute11,
              l_ieav_rec.attribute12,
              l_ieav_rec.attribute13,
              l_ieav_rec.attribute14,
              l_ieav_rec.attribute15,
              l_ieav_rec.created_by,
              l_ieav_rec.creation_date,
              l_ieav_rec.last_updated_by,
              l_ieav_rec.last_update_date,
              l_ieav_rec.last_update_login;
    x_no_data_found := iex_ext_agncy_v_pk_csr%NOTFOUND;
    CLOSE iex_ext_agncy_v_pk_csr;
    RETURN(l_ieav_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieav_rec                     IN ieav_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ieav_rec_type AS
    l_ieav_rec                     ieav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ieav_rec := get_rec(p_ieav_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EXTERNAL_AGENCY_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ieav_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ieav_rec                     IN ieav_rec_type
  ) RETURN ieav_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ieav_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: IEX_EXT_AGNCY_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_iea_rec                      IN iea_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN iea_rec_type AS
    CURSOR iex_ext_agncy_pk_csr (p_external_agency_id IN NUMBER) IS
    SELECT
            EXTERNAL_AGENCY_ID,
            EXTERNAL_AGENCY_NAME,
            VENDOR_ID,
            VENDOR_SITE_ID,
            RANK,
            EFFECTIVE_START_DATE,
            EFFECTIVE_END_DATE,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
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
      FROM Iex_Ext_Agncy_B
     WHERE iex_ext_agncy_b.external_agency_id = p_external_agency_id;
    l_iex_ext_agncy_pk             iex_ext_agncy_pk_csr%ROWTYPE;
    l_iea_rec                      iea_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_ext_agncy_pk_csr (p_iea_rec.external_agency_id);
    FETCH iex_ext_agncy_pk_csr INTO
              l_iea_rec.external_agency_id,
              l_iea_rec.external_agency_name,
              l_iea_rec.vendor_id,
              l_iea_rec.vendor_site_id,
              l_iea_rec.rank,
              l_iea_rec.effective_start_date,
              l_iea_rec.effective_end_date,
              l_iea_rec.object_version_number,
              l_iea_rec.org_id,
              l_iea_rec.attribute_category,
              l_iea_rec.attribute1,
              l_iea_rec.attribute2,
              l_iea_rec.attribute3,
              l_iea_rec.attribute4,
              l_iea_rec.attribute5,
              l_iea_rec.attribute6,
              l_iea_rec.attribute7,
              l_iea_rec.attribute8,
              l_iea_rec.attribute9,
              l_iea_rec.attribute10,
              l_iea_rec.attribute11,
              l_iea_rec.attribute12,
              l_iea_rec.attribute13,
              l_iea_rec.attribute14,
              l_iea_rec.attribute15,
              l_iea_rec.created_by,
              l_iea_rec.creation_date,
              l_iea_rec.last_updated_by,
              l_iea_rec.last_update_date,
              l_iea_rec.last_update_login;
    x_no_data_found := iex_ext_agncy_pk_csr%NOTFOUND;
    CLOSE iex_ext_agncy_pk_csr;
    RETURN(l_iea_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_iea_rec                      IN iea_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN iea_rec_type AS
    l_iea_rec                      iea_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_iea_rec := get_rec(p_iea_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EXTERNAL_AGENCY_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_iea_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_iea_rec                      IN iea_rec_type
  ) RETURN iea_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_iea_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: IEX_EXT_AGNCY_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieat_rec                     IN ieat_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ieat_rec_type AS
    CURSOR iex_ext_agncy_tl_pk_csr (p_external_agency_id IN NUMBER,
                                    p_language           IN VARCHAR2) IS
    SELECT
            EXTERNAL_AGENCY_ID,
            DESCRIPTION,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Iex_Ext_Agncy_Tl
     WHERE iex_ext_agncy_tl.external_agency_id = p_external_agency_id
       AND iex_ext_agncy_tl.language = p_language;
    l_iex_ext_agncy_tl_pk          iex_ext_agncy_tl_pk_csr%ROWTYPE;
    l_ieat_rec                     ieat_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN iex_ext_agncy_tl_pk_csr (p_ieat_rec.external_agency_id,
                                  p_ieat_rec.language);
    FETCH iex_ext_agncy_tl_pk_csr INTO
              l_ieat_rec.external_agency_id,
              l_ieat_rec.description,
              l_ieat_rec.language,
              l_ieat_rec.source_lang,
              l_ieat_rec.sfwt_flag,
              l_ieat_rec.created_by,
              l_ieat_rec.creation_date,
              l_ieat_rec.last_updated_by,
              l_ieat_rec.last_update_date,
              l_ieat_rec.last_update_login;
    x_no_data_found := iex_ext_agncy_tl_pk_csr%NOTFOUND;
    CLOSE iex_ext_agncy_tl_pk_csr;
    RETURN(l_ieat_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_ieat_rec                     IN ieat_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN ieat_rec_type AS
    l_ieat_rec                     ieat_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_ieat_rec := get_rec(p_ieat_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'EXTERNAL_AGENCY_ID');
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_ieat_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_ieat_rec                     IN ieat_rec_type
  ) RETURN ieat_rec_type AS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ieat_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: IEX_EXT_AGNCY_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ieav_rec   IN ieav_rec_type
  ) RETURN ieav_rec_type AS
    l_ieav_rec                     ieav_rec_type := p_ieav_rec;
  BEGIN
    IF (l_ieav_rec.external_agency_id = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.external_agency_id := NULL;
    END IF;
    IF (l_ieav_rec.external_agency_name = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.external_agency_name := NULL;
    END IF;
    IF (l_ieav_rec.vendor_id = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.vendor_id := NULL;
    END IF;
    IF (l_ieav_rec.vendor_site_id = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.vendor_site_id := NULL;
    END IF;
    IF (l_ieav_rec.rank = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.rank := NULL;
    END IF;
    IF (l_ieav_rec.effective_start_date = OKC_API.G_MISS_DATE ) THEN
      l_ieav_rec.effective_start_date := NULL;
    END IF;
    IF (l_ieav_rec.effective_end_date = OKC_API.G_MISS_DATE ) THEN
      l_ieav_rec.effective_end_date := NULL;
    END IF;
    IF (l_ieav_rec.description = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.description := NULL;
    END IF;
    IF (l_ieav_rec.language = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.language := NULL;
    END IF;
    IF (l_ieav_rec.source_lang = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.source_lang := NULL;
    END IF;
    IF (l_ieav_rec.sfwt_flag = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ieav_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.object_version_number := NULL;
    END IF;
    IF (l_ieav_rec.org_id = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.org_id := NULL;
    END IF;
    IF (l_ieav_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute_category := NULL;
    END IF;
    IF (l_ieav_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute1 := NULL;
    END IF;
    IF (l_ieav_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute2 := NULL;
    END IF;
    IF (l_ieav_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute3 := NULL;
    END IF;
    IF (l_ieav_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute4 := NULL;
    END IF;
    IF (l_ieav_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute5 := NULL;
    END IF;
    IF (l_ieav_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute6 := NULL;
    END IF;
    IF (l_ieav_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute7 := NULL;
    END IF;
    IF (l_ieav_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute8 := NULL;
    END IF;
    IF (l_ieav_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute9 := NULL;
    END IF;
    IF (l_ieav_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute10 := NULL;
    END IF;
    IF (l_ieav_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute11 := NULL;
    END IF;
    IF (l_ieav_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute12 := NULL;
    END IF;
    IF (l_ieav_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute13 := NULL;
    END IF;
    IF (l_ieav_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute14 := NULL;
    END IF;
    IF (l_ieav_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_ieav_rec.attribute15 := NULL;
    END IF;
    IF (l_ieav_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.created_by := NULL;
    END IF;
    IF (l_ieav_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_ieav_rec.creation_date := NULL;
    END IF;
    IF (l_ieav_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.last_updated_by := NULL;
    END IF;
    IF (l_ieav_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_ieav_rec.last_update_date := NULL;
    END IF;
    IF (l_ieav_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_ieav_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ieav_rec);
  END null_out_defaults;
  -------------------------------------------------
  -- Validate_Attributes for: EXTERNAL_AGENCY_ID --
  -------------------------------------------------
  PROCEDURE validate_external_agency_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.external_agency_id = OKC_API.G_MISS_NUM OR
        p_ieav_rec.external_agency_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'external_agency_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_external_agency_id;
  ---------------------------------------------------
  -- Validate_Attributes for: EXTERNAL_AGENCY_NAME --
  ---------------------------------------------------
  PROCEDURE validate_external_agency_name(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.external_agency_name = OKC_API.G_MISS_CHAR OR
        p_ieav_rec.external_agency_name IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'external_agency_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_external_agency_name;
  ----------------------------------------
  -- Validate_Attributes for: VENDOR_ID --
  ----------------------------------------
  PROCEDURE validate_vendor_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.vendor_id = OKC_API.G_MISS_NUM OR
        p_ieav_rec.vendor_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_id;
  ---------------------------------------------
  -- Validate_Attributes for: VENDOR_SITE_ID --
  ---------------------------------------------
  PROCEDURE validate_vendor_site_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.vendor_site_id = OKC_API.G_MISS_NUM OR
        p_ieav_rec.vendor_site_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'vendor_site_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_vendor_site_id;
  -----------------------------------
  -- Validate_Attributes for: RANK --
  -----------------------------------
  PROCEDURE validate_rank(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.rank = OKC_API.G_MISS_NUM OR
        p_ieav_rec.rank IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'rank');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_rank;
  ---------------------------------------------------
  -- Validate_Attributes for: EFFECTIVE_START_DATE --
  ---------------------------------------------------
  PROCEDURE validate_effective_start_date(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.effective_start_date = OKC_API.G_MISS_DATE OR
        p_ieav_rec.effective_start_date IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'effective_start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_effective_start_date;
  ---------------------------------------
  -- Validate_Attributes for: LANGUAGE --
  ---------------------------------------
  PROCEDURE validate_language(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /*
    IF (p_ieav_rec.language = OKC_API.G_MISS_CHAR OR
        p_ieav_rec.language IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'language');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    */

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_language;
  ------------------------------------------
  -- Validate_Attributes for: SOURCE_LANG --
  ------------------------------------------
  PROCEDURE validate_source_lang(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    /*
    IF (p_ieav_rec.source_lang = OKC_API.G_MISS_CHAR OR
        p_ieav_rec.source_lang IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_lang');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    */

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_source_lang;
  ----------------------------------------
  -- Validate_Attributes for: SFWT_FLAG --
  ----------------------------------------
  PROCEDURE validate_sfwt_flag(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.sfwt_flag = OKC_API.G_MISS_CHAR OR
        p_ieav_rec.sfwt_flag IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sfwt_flag');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sfwt_flag;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF (p_ieav_rec.object_version_number = OKC_API.G_MISS_NUM OR
        p_ieav_rec.object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
  EXCEPTION
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
  ---------------------------------------------
  -- Validate_Attributes for:IEX_EXT_AGNCY_V --
  ---------------------------------------------
  FUNCTION Validate_Attributes (
    p_ieav_rec                     IN ieav_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- external_agency_id
    -- ***
    validate_external_agency_id(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- external_agency_name
    -- ***
    validate_external_agency_name(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- vendor_id
    -- ***
    validate_vendor_id(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- vendor_site_id
    -- ***
    validate_vendor_site_id(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- rank
    -- ***
    validate_rank(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- effective_start_date
    -- ***
    validate_effective_start_date(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- language
    -- ***
    validate_language(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- source_lang
    -- ***
    validate_source_lang(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- sfwt_flag
    -- ***
    validate_sfwt_flag(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(l_return_status, p_ieav_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
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
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- Validate Record for:IEX_EXT_AGNCY_V --
  -----------------------------------------
  FUNCTION Validate_Record (
    p_ieav_rec IN ieav_rec_type,
    p_db_ieav_rec IN ieav_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF(p_ieav_rec.effective_end_date IS NOT NULL AND p_ieav_rec.effective_end_date <> OKC_API.G_MISS_DATE) THEN
      IF(p_ieav_rec.effective_start_date > p_ieav_rec.effective_end_date) THEN
        OKL_API.set_message('IEX', G_INVALID_DATE_RANGE);
        l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_ieav_rec IN ieav_rec_type
  ) RETURN VARCHAR2 AS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_ieav_rec                  ieav_rec_type := get_rec(p_ieav_rec);
  BEGIN
    l_return_status := Validate_Record(p_ieav_rec => p_ieav_rec,
                                       p_db_ieav_rec => l_db_ieav_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN ieav_rec_type,
    p_to   IN OUT NOCOPY iea_rec_type
  ) AS
  BEGIN
    p_to.external_agency_id := p_from.external_agency_id;
    p_to.external_agency_name := p_from.external_agency_name;
    p_to.vendor_id := p_from.vendor_id;
    p_to.vendor_site_id := p_from.vendor_site_id;
    p_to.rank := p_from.rank;
    p_to.effective_start_date := p_from.effective_start_date;
    p_to.effective_end_date := p_from.effective_end_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
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
    p_from IN iea_rec_type,
    p_to   IN OUT NOCOPY ieav_rec_type
  ) AS
  BEGIN
    p_to.external_agency_id := p_from.external_agency_id;
    p_to.external_agency_name := p_from.external_agency_name;
    p_to.vendor_id := p_from.vendor_id;
    p_to.vendor_site_id := p_from.vendor_site_id;
    p_to.rank := p_from.rank;
    p_to.effective_start_date := p_from.effective_start_date;
    p_to.effective_end_date := p_from.effective_end_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.org_id := p_from.org_id;
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
    p_from IN ieav_rec_type,
    p_to   IN OUT NOCOPY ieat_rec_type
  ) AS
  BEGIN
    p_to.external_agency_id := p_from.external_agency_id;
    p_to.description := p_from.description;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN ieat_rec_type,
    p_to   IN OUT NOCOPY ieav_rec_type
  ) AS
  BEGIN
    p_to.external_agency_id := p_from.external_agency_id;
    p_to.description := p_from.description;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
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
  -- validate_row for:IEX_EXT_AGNCY_V --
  --------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieav_rec                     ieav_rec_type := p_ieav_rec;
    l_iea_rec                      iea_rec_type;
    l_ieat_rec                     ieat_rec_type;
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
    l_return_status := Validate_Attributes(l_ieav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ieav_rec);
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
  -- PL/SQL TBL validate_row for:IEX_EXT_AGNCY_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      i := p_ieav_tbl.FIRST;
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
            p_ieav_rec                     => p_ieav_tbl(i));
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
        EXIT WHEN (i = p_ieav_tbl.LAST);
        i := p_ieav_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:IEX_EXT_AGNCY_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ieav_tbl                     => p_ieav_tbl,
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
  ------------------------------------
  -- insert_row for:IEX_EXT_AGNCY_B --
  ------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iea_rec                      IN iea_rec_type,
    x_iea_rec                      OUT NOCOPY iea_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iea_rec                      iea_rec_type := p_iea_rec;
    l_def_iea_rec                  iea_rec_type;
    ----------------------------------------
    -- Set_Attributes for:IEX_EXT_AGNCY_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_iea_rec IN iea_rec_type,
      x_iea_rec OUT NOCOPY iea_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iea_rec := p_iea_rec;
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
      p_iea_rec,                         -- IN
      l_iea_rec);                        -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO IEX_EXT_AGNCY_B(
      external_agency_id,
      external_agency_name,
      vendor_id,
      vendor_site_id,
      rank,
      effective_start_date,
      effective_end_date,
      object_version_number,
      org_id,
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
      l_iea_rec.external_agency_id,
      l_iea_rec.external_agency_name,
      l_iea_rec.vendor_id,
      l_iea_rec.vendor_site_id,
      l_iea_rec.rank,
      l_iea_rec.effective_start_date,
      l_iea_rec.effective_end_date,
      l_iea_rec.object_version_number,
      l_iea_rec.org_id,
      l_iea_rec.attribute_category,
      l_iea_rec.attribute1,
      l_iea_rec.attribute2,
      l_iea_rec.attribute3,
      l_iea_rec.attribute4,
      l_iea_rec.attribute5,
      l_iea_rec.attribute6,
      l_iea_rec.attribute7,
      l_iea_rec.attribute8,
      l_iea_rec.attribute9,
      l_iea_rec.attribute10,
      l_iea_rec.attribute11,
      l_iea_rec.attribute12,
      l_iea_rec.attribute13,
      l_iea_rec.attribute14,
      l_iea_rec.attribute15,
      l_iea_rec.created_by,
      l_iea_rec.creation_date,
      l_iea_rec.last_updated_by,
      l_iea_rec.last_update_date,
      l_iea_rec.last_update_login);
    -- Set OUT NOCOPY values
    x_iea_rec := l_iea_rec;
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
  -- insert_row for:IEX_EXT_AGNCY_TL --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieat_rec                     IN ieat_rec_type,
    x_ieat_rec                     OUT NOCOPY ieat_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieat_rec                     ieat_rec_type := p_ieat_rec;
    l_def_ieat_rec                 ieat_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -----------------------------------------
    -- Set_Attributes for:IEX_EXT_AGNCY_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ieat_rec IN ieat_rec_type,
      x_ieat_rec OUT NOCOPY ieat_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieat_rec := p_ieat_rec;
      x_ieat_rec.LANGUAGE := USERENV('LANG');
      x_ieat_rec.SOURCE_LANG := USERENV('LANG');
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
      p_ieat_rec,                        -- IN
      l_ieat_rec);                       -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_ieat_rec.language := l_lang_rec.language_code;
      INSERT INTO IEX_EXT_AGNCY_TL(
        external_agency_id,
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
        l_ieat_rec.external_agency_id,
        l_ieat_rec.description,
        l_ieat_rec.language,
        l_ieat_rec.source_lang,
        l_ieat_rec.sfwt_flag,
        l_ieat_rec.created_by,
        l_ieat_rec.creation_date,
        l_ieat_rec.last_updated_by,
        l_ieat_rec.last_update_date,
        l_ieat_rec.last_update_login);
    END LOOP;
    -- Set OUT NOCOPY values
    x_ieat_rec := l_ieat_rec;
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
  -- insert_row for :IEX_EXT_AGNCY_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type,
    x_ieav_rec                     OUT NOCOPY ieav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieav_rec                     ieav_rec_type := p_ieav_rec;
    l_def_ieav_rec                 ieav_rec_type;
    l_iea_rec                      iea_rec_type;
    lx_iea_rec                     iea_rec_type;
    l_ieat_rec                     ieat_rec_type;
    lx_ieat_rec                    ieat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ieav_rec IN ieav_rec_type
    ) RETURN ieav_rec_type AS
      l_ieav_rec ieav_rec_type := p_ieav_rec;
    BEGIN
      l_ieav_rec.CREATION_DATE := SYSDATE;
      l_ieav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ieav_rec.LAST_UPDATE_DATE := l_ieav_rec.CREATION_DATE;
      l_ieav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ieav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ieav_rec);
    END fill_who_columns;
    ----------------------------------------
    -- Set_Attributes for:IEX_EXT_AGNCY_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_ieav_rec IN ieav_rec_type,
      x_ieav_rec OUT NOCOPY ieav_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieav_rec := p_ieav_rec;
      x_ieav_rec.OBJECT_VERSION_NUMBER := 1;
      x_ieav_rec.SFWT_FLAG := 'N';
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
    l_ieav_rec := null_out_defaults(p_ieav_rec);
    -- Set primary key value
    l_ieav_rec.EXTERNAL_AGENCY_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_ieav_rec,                        -- IN
      l_def_ieav_rec);                   -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ieav_rec := fill_who_columns(l_def_ieav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ieav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ieav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ieav_rec, l_iea_rec);
    migrate(l_def_ieav_rec, l_ieat_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_iea_rec,
      lx_iea_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_iea_rec, l_def_ieav_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieat_rec,
      lx_ieat_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ieat_rec, l_def_ieav_rec);
    -- Set OUT NOCOPY values
    x_ieav_rec := l_def_ieav_rec;
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
  -- PL/SQL TBL insert_row for:IEAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type,
    x_ieav_tbl                     OUT NOCOPY ieav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      i := p_ieav_tbl.FIRST;
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
            p_ieav_rec                     => p_ieav_tbl(i),
            x_ieav_rec                     => x_ieav_tbl(i));
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
        EXIT WHEN (i = p_ieav_tbl.LAST);
        i := p_ieav_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:IEAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type,
    x_ieav_tbl                     OUT NOCOPY ieav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ieav_tbl                     => p_ieav_tbl,
        x_ieav_tbl                     => x_ieav_tbl,
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
  ----------------------------------
  -- lock_row for:IEX_EXT_AGNCY_B --
  ----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iea_rec                      IN iea_rec_type) AS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_iea_rec IN iea_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM IEX_EXT_AGNCY_B
     WHERE EXTERNAL_AGENCY_ID = p_iea_rec.external_agency_id
       AND OBJECT_VERSION_NUMBER = p_iea_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_iea_rec IN iea_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM IEX_EXT_AGNCY_B
     WHERE EXTERNAL_AGENCY_ID = p_iea_rec.external_agency_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        IEX_EXT_AGNCY_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       IEX_EXT_AGNCY_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_iea_rec);
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
      OPEN lchk_csr(p_iea_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_iea_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_iea_rec.object_version_number THEN
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
  -----------------------------------
  -- lock_row for:IEX_EXT_AGNCY_TL --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieat_rec                     IN ieat_rec_type) AS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ieat_rec IN ieat_rec_type) IS
    SELECT *
      FROM IEX_EXT_AGNCY_TL
     WHERE EXTERNAL_AGENCY_ID = p_ieat_rec.external_agency_id
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
      OPEN lock_csr(p_ieat_rec);
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
  -----------------------------------
  -- lock_row for: IEX_EXT_AGNCY_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iea_rec                      iea_rec_type;
    l_ieat_rec                     ieat_rec_type;
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
    migrate(p_ieav_rec, l_iea_rec);
    migrate(p_ieav_rec, l_ieat_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_iea_rec
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
      l_ieat_rec
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
  -- PL/SQL TBL lock_row for:IEAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      i := p_ieav_tbl.FIRST;
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
            p_ieav_rec                     => p_ieav_tbl(i));
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
        EXIT WHEN (i = p_ieav_tbl.LAST);
        i := p_ieav_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:IEAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ieav_tbl                     => p_ieav_tbl,
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
  ------------------------------------
  -- update_row for:IEX_EXT_AGNCY_B --
  ------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iea_rec                      IN iea_rec_type,
    x_iea_rec                      OUT NOCOPY iea_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iea_rec                      iea_rec_type := p_iea_rec;
    l_def_iea_rec                  iea_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_iea_rec IN iea_rec_type,
      x_iea_rec OUT NOCOPY iea_rec_type
    ) RETURN VARCHAR2 AS
      l_iea_rec                      iea_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iea_rec := p_iea_rec;
      -- Get current database values
      l_iea_rec := get_rec(p_iea_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_iea_rec.external_agency_id = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.external_agency_id := l_iea_rec.external_agency_id;
        END IF;
        IF (x_iea_rec.external_agency_name = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.external_agency_name := l_iea_rec.external_agency_name;
        END IF;
        IF (x_iea_rec.vendor_id = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.vendor_id := l_iea_rec.vendor_id;
        END IF;
        IF (x_iea_rec.vendor_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.vendor_site_id := l_iea_rec.vendor_site_id;
        END IF;
        IF (x_iea_rec.rank = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.rank := l_iea_rec.rank;
        END IF;
        IF (x_iea_rec.effective_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_iea_rec.effective_start_date := l_iea_rec.effective_start_date;
        END IF;
        IF (x_iea_rec.effective_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_iea_rec.effective_end_date := l_iea_rec.effective_end_date;
        END IF;
        IF (x_iea_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.object_version_number := l_iea_rec.object_version_number;
        END IF;
        IF (x_iea_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.org_id := l_iea_rec.org_id;
        END IF;
        IF (x_iea_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute_category := l_iea_rec.attribute_category;
        END IF;
        IF (x_iea_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute1 := l_iea_rec.attribute1;
        END IF;
        IF (x_iea_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute2 := l_iea_rec.attribute2;
        END IF;
        IF (x_iea_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute3 := l_iea_rec.attribute3;
        END IF;
        IF (x_iea_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute4 := l_iea_rec.attribute4;
        END IF;
        IF (x_iea_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute5 := l_iea_rec.attribute5;
        END IF;
        IF (x_iea_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute6 := l_iea_rec.attribute6;
        END IF;
        IF (x_iea_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute7 := l_iea_rec.attribute7;
        END IF;
        IF (x_iea_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute8 := l_iea_rec.attribute8;
        END IF;
        IF (x_iea_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute9 := l_iea_rec.attribute9;
        END IF;
        IF (x_iea_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute10 := l_iea_rec.attribute10;
        END IF;
        IF (x_iea_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute11 := l_iea_rec.attribute11;
        END IF;
        IF (x_iea_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute12 := l_iea_rec.attribute12;
        END IF;
        IF (x_iea_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute13 := l_iea_rec.attribute13;
        END IF;
        IF (x_iea_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute14 := l_iea_rec.attribute14;
        END IF;
        IF (x_iea_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_iea_rec.attribute15 := l_iea_rec.attribute15;
        END IF;
        IF (x_iea_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.created_by := l_iea_rec.created_by;
        END IF;
        IF (x_iea_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_iea_rec.creation_date := l_iea_rec.creation_date;
        END IF;
        IF (x_iea_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.last_updated_by := l_iea_rec.last_updated_by;
        END IF;
        IF (x_iea_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_iea_rec.last_update_date := l_iea_rec.last_update_date;
        END IF;
        IF (x_iea_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_iea_rec.last_update_login := l_iea_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:IEX_EXT_AGNCY_B --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_iea_rec IN iea_rec_type,
      x_iea_rec OUT NOCOPY iea_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_iea_rec := p_iea_rec;
      x_iea_rec.OBJECT_VERSION_NUMBER := p_iea_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_iea_rec,                         -- IN
      l_iea_rec);                        -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_iea_rec, l_def_iea_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE IEX_EXT_AGNCY_B
    SET EXTERNAL_AGENCY_NAME = l_def_iea_rec.external_agency_name,
        VENDOR_ID = l_def_iea_rec.vendor_id,
        VENDOR_SITE_ID = l_def_iea_rec.vendor_site_id,
        RANK = l_def_iea_rec.rank,
        EFFECTIVE_START_DATE = l_def_iea_rec.effective_start_date,
        EFFECTIVE_END_DATE = l_def_iea_rec.effective_end_date,
        OBJECT_VERSION_NUMBER = l_def_iea_rec.object_version_number,
        ORG_ID = l_def_iea_rec.org_id,
        ATTRIBUTE_CATEGORY = l_def_iea_rec.attribute_category,
        ATTRIBUTE1 = l_def_iea_rec.attribute1,
        ATTRIBUTE2 = l_def_iea_rec.attribute2,
        ATTRIBUTE3 = l_def_iea_rec.attribute3,
        ATTRIBUTE4 = l_def_iea_rec.attribute4,
        ATTRIBUTE5 = l_def_iea_rec.attribute5,
        ATTRIBUTE6 = l_def_iea_rec.attribute6,
        ATTRIBUTE7 = l_def_iea_rec.attribute7,
        ATTRIBUTE8 = l_def_iea_rec.attribute8,
        ATTRIBUTE9 = l_def_iea_rec.attribute9,
        ATTRIBUTE10 = l_def_iea_rec.attribute10,
        ATTRIBUTE11 = l_def_iea_rec.attribute11,
        ATTRIBUTE12 = l_def_iea_rec.attribute12,
        ATTRIBUTE13 = l_def_iea_rec.attribute13,
        ATTRIBUTE14 = l_def_iea_rec.attribute14,
        ATTRIBUTE15 = l_def_iea_rec.attribute15,
        CREATED_BY = l_def_iea_rec.created_by,
        CREATION_DATE = l_def_iea_rec.creation_date,
        LAST_UPDATED_BY = l_def_iea_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_iea_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_iea_rec.last_update_login
    WHERE EXTERNAL_AGENCY_ID = l_def_iea_rec.external_agency_id;

    x_iea_rec := l_iea_rec;
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
  -- update_row for:IEX_EXT_AGNCY_TL --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieat_rec                     IN ieat_rec_type,
    x_ieat_rec                     OUT NOCOPY ieat_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieat_rec                     ieat_rec_type := p_ieat_rec;
    l_def_ieat_rec                 ieat_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ieat_rec IN ieat_rec_type,
      x_ieat_rec OUT NOCOPY ieat_rec_type
    ) RETURN VARCHAR2 AS
      l_ieat_rec                     ieat_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieat_rec := p_ieat_rec;
      -- Get current database values
      l_ieat_rec := get_rec(p_ieat_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ieat_rec.external_agency_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieat_rec.external_agency_id := l_ieat_rec.external_agency_id;
        END IF;
        IF (x_ieat_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_ieat_rec.description := l_ieat_rec.description;
        END IF;
        IF (x_ieat_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_ieat_rec.language := l_ieat_rec.language;
        END IF;
        IF (x_ieat_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_ieat_rec.source_lang := l_ieat_rec.source_lang;
        END IF;
        IF (x_ieat_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_ieat_rec.sfwt_flag := l_ieat_rec.sfwt_flag;
        END IF;
        IF (x_ieat_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieat_rec.created_by := l_ieat_rec.created_by;
        END IF;
        IF (x_ieat_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieat_rec.creation_date := l_ieat_rec.creation_date;
        END IF;
        IF (x_ieat_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieat_rec.last_updated_by := l_ieat_rec.last_updated_by;
        END IF;
        IF (x_ieat_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieat_rec.last_update_date := l_ieat_rec.last_update_date;
        END IF;
        IF (x_ieat_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ieat_rec.last_update_login := l_ieat_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:IEX_EXT_AGNCY_TL --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_ieat_rec IN ieat_rec_type,
      x_ieat_rec OUT NOCOPY ieat_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieat_rec := p_ieat_rec;
      x_ieat_rec.LANGUAGE := USERENV('LANG');
      x_ieat_rec.LANGUAGE := USERENV('LANG');
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
      p_ieat_rec,                        -- IN
      l_ieat_rec);                       -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ieat_rec, l_def_ieat_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE IEX_EXT_AGNCY_TL
    SET DESCRIPTION = l_def_ieat_rec.description,
        CREATED_BY = l_def_ieat_rec.created_by,
        CREATION_DATE = l_def_ieat_rec.creation_date,
        LAST_UPDATED_BY = l_def_ieat_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ieat_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ieat_rec.last_update_login
    WHERE EXTERNAL_AGENCY_ID = l_def_ieat_rec.external_agency_id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE IEX_EXT_AGNCY_TL
    SET SFWT_FLAG = 'Y'
    WHERE EXTERNAL_AGENCY_ID = l_def_ieat_rec.external_agency_id
      AND SOURCE_LANG <> USERENV('LANG');

    x_ieat_rec := l_ieat_rec;
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
  -- update_row for:IEX_EXT_AGNCY_V --
  ------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type,
    x_ieav_rec                     OUT NOCOPY ieav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieav_rec                     ieav_rec_type := p_ieav_rec;
    l_def_ieav_rec                 ieav_rec_type;
    l_db_ieav_rec                  ieav_rec_type;
    l_iea_rec                      iea_rec_type;
    lx_iea_rec                     iea_rec_type;
    l_ieat_rec                     ieat_rec_type;
    lx_ieat_rec                    ieat_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ieav_rec IN ieav_rec_type
    ) RETURN ieav_rec_type AS
      l_ieav_rec ieav_rec_type := p_ieav_rec;
    BEGIN
      l_ieav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ieav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ieav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ieav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ieav_rec IN ieav_rec_type,
      x_ieav_rec OUT NOCOPY ieav_rec_type
    ) RETURN VARCHAR2 AS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieav_rec := p_ieav_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_ieav_rec := get_rec(p_ieav_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_ieav_rec.external_agency_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.external_agency_id := l_db_ieav_rec.external_agency_id;
        END IF;
        IF (x_ieav_rec.external_agency_name = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.external_agency_name := l_db_ieav_rec.external_agency_name;
        END IF;
        IF (x_ieav_rec.vendor_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.vendor_id := l_db_ieav_rec.vendor_id;
        END IF;
        IF (x_ieav_rec.vendor_site_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.vendor_site_id := l_db_ieav_rec.vendor_site_id;
        END IF;
        IF (x_ieav_rec.rank = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.rank := l_db_ieav_rec.rank;
        END IF;
        IF (x_ieav_rec.effective_start_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieav_rec.effective_start_date := l_db_ieav_rec.effective_start_date;
        END IF;
        IF (x_ieav_rec.effective_end_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieav_rec.effective_end_date := l_db_ieav_rec.effective_end_date;
        END IF;
        IF (x_ieav_rec.description = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.description := l_db_ieav_rec.description;
        END IF;
        IF (x_ieav_rec.language = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.language := l_db_ieav_rec.language;
        END IF;
        IF (x_ieav_rec.source_lang = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.source_lang := l_db_ieav_rec.source_lang;
        END IF;
        IF (x_ieav_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.sfwt_flag := l_db_ieav_rec.sfwt_flag;
        END IF;
        IF (x_ieav_rec.org_id = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.org_id := l_db_ieav_rec.org_id;
        END IF;
        IF (x_ieav_rec.attribute_category = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute_category := l_db_ieav_rec.attribute_category;
        END IF;
        IF (x_ieav_rec.attribute1 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute1 := l_db_ieav_rec.attribute1;
        END IF;
        IF (x_ieav_rec.attribute2 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute2 := l_db_ieav_rec.attribute2;
        END IF;
        IF (x_ieav_rec.attribute3 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute3 := l_db_ieav_rec.attribute3;
        END IF;
        IF (x_ieav_rec.attribute4 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute4 := l_db_ieav_rec.attribute4;
        END IF;
        IF (x_ieav_rec.attribute5 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute5 := l_db_ieav_rec.attribute5;
        END IF;
        IF (x_ieav_rec.attribute6 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute6 := l_db_ieav_rec.attribute6;
        END IF;
        IF (x_ieav_rec.attribute7 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute7 := l_db_ieav_rec.attribute7;
        END IF;
        IF (x_ieav_rec.attribute8 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute8 := l_db_ieav_rec.attribute8;
        END IF;
        IF (x_ieav_rec.attribute9 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute9 := l_db_ieav_rec.attribute9;
        END IF;
        IF (x_ieav_rec.attribute10 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute10 := l_db_ieav_rec.attribute10;
        END IF;
        IF (x_ieav_rec.attribute11 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute11 := l_db_ieav_rec.attribute11;
        END IF;
        IF (x_ieav_rec.attribute12 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute12 := l_db_ieav_rec.attribute12;
        END IF;
        IF (x_ieav_rec.attribute13 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute13 := l_db_ieav_rec.attribute13;
        END IF;
        IF (x_ieav_rec.attribute14 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute14 := l_db_ieav_rec.attribute14;
        END IF;
        IF (x_ieav_rec.attribute15 = OKC_API.G_MISS_CHAR)
        THEN
          x_ieav_rec.attribute15 := l_db_ieav_rec.attribute15;
        END IF;
        IF (x_ieav_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.created_by := l_db_ieav_rec.created_by;
        END IF;
        IF (x_ieav_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieav_rec.creation_date := l_db_ieav_rec.creation_date;
        END IF;
        IF (x_ieav_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.last_updated_by := l_db_ieav_rec.last_updated_by;
        END IF;
        IF (x_ieav_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_ieav_rec.last_update_date := l_db_ieav_rec.last_update_date;
        END IF;
        IF (x_ieav_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_ieav_rec.last_update_login := l_db_ieav_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------
    -- Set_Attributes for:IEX_EXT_AGNCY_V --
    ----------------------------------------
    FUNCTION Set_Attributes (
      p_ieav_rec IN ieav_rec_type,
      x_ieav_rec OUT NOCOPY ieav_rec_type
    ) RETURN VARCHAR2 AS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ieav_rec := p_ieav_rec;
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
      p_ieav_rec,                        -- IN
      x_ieav_rec);                       -- OUT NOCOPY
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ieav_rec, l_def_ieav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ieav_rec := fill_who_columns(l_def_ieav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ieav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ieav_rec, l_db_ieav_rec);
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
      p_ieav_rec                     => p_ieav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_ieav_rec, l_iea_rec);
    migrate(l_def_ieav_rec, l_ieat_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_iea_rec,
      lx_iea_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_iea_rec, l_def_ieav_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieat_rec,
      lx_ieat_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ieat_rec, l_def_ieav_rec);
    x_ieav_rec := l_def_ieav_rec;
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
  -- PL/SQL TBL update_row for:ieav_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type,
    x_ieav_tbl                     OUT NOCOPY ieav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      i := p_ieav_tbl.FIRST;
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
            p_ieav_rec                     => p_ieav_tbl(i),
            x_ieav_rec                     => x_ieav_tbl(i));
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
        EXIT WHEN (i = p_ieav_tbl.LAST);
        i := p_ieav_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:IEAV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type,
    x_ieav_tbl                     OUT NOCOPY ieav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ieav_tbl                     => p_ieav_tbl,
        x_ieav_tbl                     => x_ieav_tbl,
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
  ------------------------------------
  -- delete_row for:IEX_EXT_AGNCY_B --
  ------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_iea_rec                      IN iea_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_iea_rec                      iea_rec_type := p_iea_rec;
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

    DELETE FROM IEX_EXT_AGNCY_B
     WHERE EXTERNAL_AGENCY_ID = p_iea_rec.external_agency_id;

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
  -- delete_row for:IEX_EXT_AGNCY_TL --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieat_rec                     IN ieat_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieat_rec                     ieat_rec_type := p_ieat_rec;
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

    DELETE FROM IEX_EXT_AGNCY_TL
     WHERE EXTERNAL_AGENCY_ID = p_ieat_rec.external_agency_id;

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
  -- delete_row for:IEX_EXT_AGNCY_V --
  ------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_rec                     IN ieav_rec_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ieav_rec                     ieav_rec_type := p_ieav_rec;
    l_ieat_rec                     ieat_rec_type;
    l_iea_rec                      iea_rec_type;
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
    migrate(l_ieav_rec, l_ieat_rec);
    migrate(l_ieav_rec, l_iea_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_ieat_rec
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
      l_iea_rec
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
  -- PL/SQL TBL delete_row for:IEX_EXT_AGNCY_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      i := p_ieav_tbl.FIRST;
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
            p_ieav_rec                     => p_ieav_tbl(i));
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
        EXIT WHEN (i = p_ieav_tbl.LAST);
        i := p_ieav_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:IEX_EXT_AGNCY_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ieav_tbl                     IN ieav_tbl_type) AS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ieav_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_ieav_tbl                     => p_ieav_tbl,
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

END IEX_IEA_PVT;

/
