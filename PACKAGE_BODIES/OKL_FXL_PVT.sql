--------------------------------------------------------
--  DDL for Package Body OKL_FXL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FXL_PVT" AS
/* $Header: OKLSFXLB.pls 120.3 2007/12/21 12:50:54 rajnisku noship $ */
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
    l_pk_value NUMBER;
    CURSOR c_pk_csr IS SELECT okl_ext_fa_line_sources_s.NEXTVAL FROM DUAL;
  BEGIN
  /* Fetch the pk value from the sequence */
    OPEN c_pk_csr;
    FETCH c_pk_csr INTO l_pk_value;
    CLOSE c_pk_csr;
    RETURN l_pk_value;
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
    DELETE FROM OKL_EXT_FA_LINE_SOURCES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_EXT_FA_LINE_SOURCES_B B
         WHERE B.LINE_EXTENSION_ID =T.LINE_EXTENSION_ID
        );

    UPDATE OKL_EXT_FA_LINE_SOURCES_TL T SET(
        INVENTORY_ORG_NAME,
        TRANS_LINE_DESCRIPTION) = (SELECT
                                  B.INVENTORY_ORG_NAME,
                                  B.TRANS_LINE_DESCRIPTION
                                FROM OKL_EXT_FA_LINE_SOURCES_TL B
                               WHERE B.LINE_EXTENSION_ID = T.LINE_EXTENSION_ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.LINE_EXTENSION_ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.LINE_EXTENSION_ID,
                  SUBT.LANGUAGE
                FROM OKL_EXT_FA_LINE_SOURCES_TL SUBB, OKL_EXT_FA_LINE_SOURCES_TL SUBT
               WHERE SUBB.LINE_EXTENSION_ID = SUBT.LINE_EXTENSION_ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.INVENTORY_ORG_NAME <> SUBT.INVENTORY_ORG_NAME
                      OR SUBB.TRANS_LINE_DESCRIPTION <> SUBT.TRANS_LINE_DESCRIPTION
                      OR (SUBB.INVENTORY_ORG_NAME IS NULL AND SUBT.INVENTORY_ORG_NAME IS NOT NULL)
                      OR (SUBB.TRANS_LINE_DESCRIPTION IS NULL AND SUBT.TRANS_LINE_DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_EXT_FA_LINE_SOURCES_TL (
        LINE_EXTENSION_ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        INVENTORY_ORG_NAME,
        TRANS_LINE_DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.LINE_EXTENSION_ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.INVENTORY_ORG_NAME,
            B.TRANS_LINE_DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_EXT_FA_LINE_SOURCES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_EXT_FA_LINE_SOURCES_TL T
                     WHERE T.LINE_EXTENSION_ID = B.LINE_EXTENSION_ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_FA_LINE_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fxlv_rec                     IN fxlv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fxlv_rec_type IS
    CURSOR okl_ext_fa_line_sou7 (p_line_extension_id IN NUMBER) IS
    SELECT
            LINE_EXTENSION_ID,
            HEADER_EXTENSION_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            FA_TRANSACTION_ID,
            ASSET_ID,
            KLE_ID,
            ASSET_NUMBER,
            CONTRACT_LINE_NUMBER,
            ASSET_BOOK_TYPE_NAME,
            ASSET_VENDOR_NAME,
            INSTALLED_SITE_ID,
            LINE_ATTRIBUTE_CATEGORY,
            LINE_ATTRIBUTE1,
            LINE_ATTRIBUTE2,
            LINE_ATTRIBUTE3,
            LINE_ATTRIBUTE4,
            LINE_ATTRIBUTE5,
            LINE_ATTRIBUTE6,
            LINE_ATTRIBUTE7,
            LINE_ATTRIBUTE8,
            LINE_ATTRIBUTE9,
            LINE_ATTRIBUTE10,
            LINE_ATTRIBUTE11,
            LINE_ATTRIBUTE12,
            LINE_ATTRIBUTE13,
            LINE_ATTRIBUTE14,
            LINE_ATTRIBUTE15,
            LANGUAGE,
            INVENTORY_ORG_NAME,
            TRANS_LINE_DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            INVENTORY_ORG_CODE
            ,ASSET_BOOK_TYPE_CODE
            ,PERIOD_COUNTER
	    ,ASSET_VENDOR_ID
      FROM Okl_Ext_Fa_Line_Sources_V
     WHERE okl_ext_fa_line_sources_v.line_extension_id = p_line_extension_id;
    l_okl_ext_fa_line_sources_v_pk okl_ext_fa_line_sou7%ROWTYPE;
    l_fxlv_rec                     fxlv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_fa_line_sou7 (p_fxlv_rec.line_extension_id);
    FETCH okl_ext_fa_line_sou7 INTO
              l_fxlv_rec.line_extension_id,
              l_fxlv_rec.header_extension_id,
              l_fxlv_rec.source_id,
              l_fxlv_rec.source_table,
              l_fxlv_rec.object_version_number,
              l_fxlv_rec.fa_transaction_id,
              l_fxlv_rec.asset_id,
              l_fxlv_rec.kle_id,
              l_fxlv_rec.asset_number,
              l_fxlv_rec.contract_line_number,
              l_fxlv_rec.asset_book_type_name,
              l_fxlv_rec.asset_vendor_name,
              l_fxlv_rec.installed_site_id,
              l_fxlv_rec.line_attribute_category,
              l_fxlv_rec.line_attribute1,
              l_fxlv_rec.line_attribute2,
              l_fxlv_rec.line_attribute3,
              l_fxlv_rec.line_attribute4,
              l_fxlv_rec.line_attribute5,
              l_fxlv_rec.line_attribute6,
              l_fxlv_rec.line_attribute7,
              l_fxlv_rec.line_attribute8,
              l_fxlv_rec.line_attribute9,
              l_fxlv_rec.line_attribute10,
              l_fxlv_rec.line_attribute11,
              l_fxlv_rec.line_attribute12,
              l_fxlv_rec.line_attribute13,
              l_fxlv_rec.line_attribute14,
              l_fxlv_rec.line_attribute15,
              l_fxlv_rec.language,
              l_fxlv_rec.inventory_org_name,
              l_fxlv_rec.trans_line_description,
              l_fxlv_rec.created_by,
              l_fxlv_rec.creation_date,
              l_fxlv_rec.last_updated_by,
              l_fxlv_rec.last_update_date,
              l_fxlv_rec.last_update_login,
              l_fxlv_rec.inventory_org_code
              ,l_fxlv_rec.asset_book_type_code
              ,l_fxlv_rec.period_counter
	      ,l_fxlv_rec.asset_vendor_id;
    x_no_data_found := okl_ext_fa_line_sou7%NOTFOUND;
    CLOSE okl_ext_fa_line_sou7;
    RETURN(l_fxlv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_fxlv_rec                     IN fxlv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN fxlv_rec_type IS
    l_fxlv_rec                     fxlv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_fxlv_rec := get_rec(p_fxlv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LINE_EXTENSION_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_fxlv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_fxlv_rec                     IN fxlv_rec_type
  ) RETURN fxlv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fxlv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_FA_LINE_SOURCES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fxl_rec                      IN fxl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fxl_rec_type IS
    CURSOR okl_ext_fa_line_sou8 (p_line_extension_id IN NUMBER) IS
    SELECT
            LINE_EXTENSION_ID,
            HEADER_EXTENSION_ID,
            SOURCE_ID,
            SOURCE_TABLE,
            OBJECT_VERSION_NUMBER,
            FA_TRANSACTION_ID,
            ASSET_ID,
            KLE_ID,
            ASSET_NUMBER,
            CONTRACT_LINE_NUMBER,
            ASSET_BOOK_TYPE_NAME,
            ASSET_VENDOR_NAME,
            INSTALLED_SITE_ID,
            LINE_ATTRIBUTE_CATEGORY,
            LINE_ATTRIBUTE1,
            LINE_ATTRIBUTE2,
            LINE_ATTRIBUTE3,
            LINE_ATTRIBUTE4,
            LINE_ATTRIBUTE5,
            LINE_ATTRIBUTE6,
            LINE_ATTRIBUTE7,
            LINE_ATTRIBUTE8,
            LINE_ATTRIBUTE9,
            LINE_ATTRIBUTE10,
            LINE_ATTRIBUTE11,
            LINE_ATTRIBUTE12,
            LINE_ATTRIBUTE13,
            LINE_ATTRIBUTE14,
            LINE_ATTRIBUTE15,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            INVENTORY_ORG_CODE,
            ASSET_BOOK_TYPE_CODE,
            PERIOD_COUNTER,
	    ASSET_VENDOR_ID
      FROM Okl_Ext_Fa_Line_Sources_B
     WHERE okl_ext_fa_line_sources_b.line_extension_id = p_line_extension_id;
    l_okl_ext_fa_line_sources_b_pk okl_ext_fa_line_sou8%ROWTYPE;
    l_fxl_rec                      fxl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_fa_line_sou8 (p_fxl_rec.line_extension_id);
    FETCH okl_ext_fa_line_sou8 INTO
              l_fxl_rec.line_extension_id,
              l_fxl_rec.header_extension_id,
              l_fxl_rec.source_id,
              l_fxl_rec.source_table,
              l_fxl_rec.object_version_number,
              l_fxl_rec.fa_transaction_id,
              l_fxl_rec.asset_id,
              l_fxl_rec.kle_id,
              l_fxl_rec.asset_number,
              l_fxl_rec.contract_line_number,
              l_fxl_rec.asset_book_type_name,
              l_fxl_rec.asset_vendor_name,
              l_fxl_rec.installed_site_id,
              l_fxl_rec.line_attribute_category,
              l_fxl_rec.line_attribute1,
              l_fxl_rec.line_attribute2,
              l_fxl_rec.line_attribute3,
              l_fxl_rec.line_attribute4,
              l_fxl_rec.line_attribute5,
              l_fxl_rec.line_attribute6,
              l_fxl_rec.line_attribute7,
              l_fxl_rec.line_attribute8,
              l_fxl_rec.line_attribute9,
              l_fxl_rec.line_attribute10,
              l_fxl_rec.line_attribute11,
              l_fxl_rec.line_attribute12,
              l_fxl_rec.line_attribute13,
              l_fxl_rec.line_attribute14,
              l_fxl_rec.line_attribute15,
              l_fxl_rec.created_by,
              l_fxl_rec.creation_date,
              l_fxl_rec.last_updated_by,
              l_fxl_rec.last_update_date,
              l_fxl_rec.last_update_login,
              l_fxl_rec.inventory_org_code,
              l_fxl_rec.asset_book_type_code,
              l_fxl_rec.period_counter,
	      l_fxl_rec.asset_vendor_id;
    x_no_data_found := okl_ext_fa_line_sou8%NOTFOUND;
    CLOSE okl_ext_fa_line_sou8;
    RETURN(l_fxl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_fxl_rec                      IN fxl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN fxl_rec_type IS
    l_fxl_rec                      fxl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_fxl_rec := get_rec(p_fxl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LINE_EXTENSION_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_fxl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_fxl_rec                      IN fxl_rec_type
  ) RETURN fxl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fxl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_EXT_FA_LINE_SOURCES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_fxll_rec                     IN fxll_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN fxll_rec_type IS
    CURSOR okl_ext_fa_line_sou9 (p_line_extension_id IN NUMBER,
                                 p_language          IN VARCHAR2) IS
    SELECT
            LINE_EXTENSION_ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            INVENTORY_ORG_NAME,
            TRANS_LINE_DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ext_Fa_Line_Sources_Tl
     WHERE okl_ext_fa_line_sources_tl.line_extension_id = p_line_extension_id
       AND okl_ext_fa_line_sources_tl.language = p_language;
    l_okl_ext_fa_line_s10          okl_ext_fa_line_sou9%ROWTYPE;
    l_fxll_rec                     fxll_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ext_fa_line_sou9 (p_fxll_rec.line_extension_id,
                               p_fxll_rec.language);
    FETCH okl_ext_fa_line_sou9 INTO
              l_fxll_rec.line_extension_id,
              l_fxll_rec.language,
              l_fxll_rec.source_lang,
              l_fxll_rec.sfwt_flag,
              l_fxll_rec.inventory_org_name,
              l_fxll_rec.trans_line_description,
              l_fxll_rec.created_by,
              l_fxll_rec.creation_date,
              l_fxll_rec.last_updated_by,
              l_fxll_rec.last_update_date,
              l_fxll_rec.last_update_login;
    x_no_data_found := okl_ext_fa_line_sou9%NOTFOUND;
    CLOSE okl_ext_fa_line_sou9;
    RETURN(l_fxll_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_fxll_rec                     IN fxll_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN fxll_rec_type IS
    l_fxll_rec                     fxll_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_fxll_rec := get_rec(p_fxll_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LINE_EXTENSION_ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_fxll_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_fxll_rec                     IN fxll_rec_type
  ) RETURN fxll_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_fxll_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_EXT_FA_LINE_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_fxlv_rec   IN fxlv_rec_type
  ) RETURN fxlv_rec_type IS
    l_fxlv_rec                     fxlv_rec_type := p_fxlv_rec;
  BEGIN
    IF (l_fxlv_rec.line_extension_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.line_extension_id := NULL;
    END IF;
    IF (l_fxlv_rec.header_extension_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.header_extension_id := NULL;
    END IF;
    IF (l_fxlv_rec.source_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.source_id := NULL;
    END IF;
    IF (l_fxlv_rec.source_table = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.source_table := NULL;
    END IF;
    IF (l_fxlv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.object_version_number := NULL;
    END IF;
    IF (l_fxlv_rec.fa_transaction_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.fa_transaction_id := NULL;
    END IF;
    IF (l_fxlv_rec.asset_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.asset_id := NULL;
    END IF;
    IF (l_fxlv_rec.kle_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.kle_id := NULL;
    END IF;
    IF (l_fxlv_rec.asset_number = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.asset_number := NULL;
    END IF;
    IF (l_fxlv_rec.contract_line_number = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.contract_line_number := NULL;
    END IF;
    IF (l_fxlv_rec.asset_book_type_name = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.asset_book_type_name := NULL;
    END IF;
    IF (l_fxlv_rec.asset_vendor_name = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.asset_vendor_name := NULL;
    END IF;
    IF (l_fxlv_rec.installed_site_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.installed_site_id := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute_category := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute1 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute2 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute3 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute4 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute5 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute6 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute7 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute8 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute9 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute10 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute11 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute12 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute13 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute14 := NULL;
    END IF;
    IF (l_fxlv_rec.line_attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.line_attribute15 := NULL;
    END IF;
    IF (l_fxlv_rec.language = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.language := NULL;
    END IF;
    IF (l_fxlv_rec.inventory_org_name = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.inventory_org_name := NULL;
    END IF;
    IF (l_fxlv_rec.trans_line_description = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.trans_line_description := NULL;
    END IF;
    IF (l_fxlv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.created_by := NULL;
    END IF;
    IF (l_fxlv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_fxlv_rec.creation_date := NULL;
    END IF;
    IF (l_fxlv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.last_updated_by := NULL;
    END IF;
    IF (l_fxlv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_fxlv_rec.last_update_date := NULL;
    END IF;
    IF (l_fxlv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.last_update_login := NULL;
    END IF;
    IF (l_fxlv_rec.inventory_org_code = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.inventory_org_code := NULL;
    END IF;
    IF (l_fxlv_rec.asset_book_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_fxlv_rec.asset_book_type_code := NULL;
    END IF;
    IF (l_fxlv_rec.period_counter = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.period_counter := NULL;
    END IF;
      IF (l_fxlv_rec.asset_vendor_id = OKL_API.G_MISS_NUM ) THEN
      l_fxlv_rec.asset_vendor_id := NULL;
    END IF;

    RETURN(l_fxlv_rec);
  END null_out_defaults;
  ------------------------------------------------
  -- Validate_Attributes for: LINE_EXTENSION_ID --
  ------------------------------------------------
  PROCEDURE validate_line_extension_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_line_extension_id            IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_line_extension_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'line_extension_id');
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
  END validate_line_extension_id;
  --------------------------------------------------
  -- Validate_Attributes for: HEADER_EXTENSION_ID --
  --------------------------------------------------
  PROCEDURE validate_header_extension_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_header_extension_id          IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_header_extension_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'header_extension_id');
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
  END validate_header_extension_id;
  ----------------------------------------
  -- Validate_Attributes for: SOURCE_ID --
  ----------------------------------------
  PROCEDURE validate_source_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_id                    IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_source_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_id');
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
  END validate_source_id;
  -------------------------------------------
  -- Validate_Attributes for: SOURCE_TABLE --
  -------------------------------------------
  PROCEDURE validate_source_table(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_source_table                 IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_source_table IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'source_table');
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
  END validate_source_table;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number IS NULL) THEN
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
  ------------------------------------------------
  -- Validate_Attributes for: FA_TRANSACTION_ID --
  ------------------------------------------------
  PROCEDURE validate_fa_transaction_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_fa_transaction_id            IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_fa_transaction_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'fa_transaction_id');
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
  END validate_fa_transaction_id;
  ---------------------------------------
  -- Validate_Attributes for: ASSET_ID --
  ---------------------------------------
  PROCEDURE validate_asset_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_asset_id                     IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_asset_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'asset_id');
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
  END validate_asset_id;
  -------------------------------------
  -- Validate_Attributes for: KLE_ID --
  -------------------------------------
  PROCEDURE validate_kle_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_kle_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_kle_id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'kle_id');
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
  END validate_kle_id;
  ---------------------------------------
  -- Validate_Attributes for: LANGUAGE --
  ---------------------------------------
  PROCEDURE validate_language(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_language                     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_language IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'language');
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
  END validate_language;
       ----------------------------------------------------
  -- Validate_Attributes for: asset_vendor_id  --
  ----------------------------------------------------
  PROCEDURE validate_supplier(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_asset_vendor_id       IN NUMBER) IS
   l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_asset_vendor_id              VARCHAR2(1);
  l_row_not_found             BOOLEAN := FALSE;
  CURSOR c1(p_asset_vendor_id NUMBER) IS
  SELECT '1'
  FROM ap_suppliers
  WHERE  vendor_id =  p_asset_vendor_id   ;
  BEGIN
 IF ( p_asset_vendor_id IS NOT NULL) THEN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OPEN c1(p_asset_vendor_id );
    FETCH c1 INTO l_asset_vendor_id;
    l_row_not_found := c1%NOTFOUND;
    CLOSE c1;
    IF l_row_not_found THEN
		OKC_API.set_message('OKL',G_INVALID_VALUE , G_COL_NAME_TOKEN, 'asset_vendor_id');
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,

                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_supplier;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKL_EXT_FA_LINE_SOURCES_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_fxlv_rec                     IN fxlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- line_extension_id
    -- ***
    validate_line_extension_id(x_return_status, p_fxlv_rec.line_extension_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- header_extension_id
    -- ***
    validate_header_extension_id(x_return_status, p_fxlv_rec.header_extension_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_id
    -- ***
    validate_source_id(x_return_status, p_fxlv_rec.source_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- source_table
    -- ***
    validate_source_table(x_return_status, p_fxlv_rec.source_table);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_fxlv_rec.object_version_number);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- fa_transaction_id
    -- ***
    validate_fa_transaction_id(x_return_status, p_fxlv_rec.fa_transaction_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- asset_id
    -- ***
    validate_asset_id(x_return_status, p_fxlv_rec.asset_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- kle_id
    -- ***
    validate_kle_id(x_return_status, p_fxlv_rec.kle_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- language
    -- ***
    validate_language(x_return_status, p_fxlv_rec.language);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
       -- ***
    -- asset_vendor_id
    -- ***
    validate_supplier(x_return_status, p_fxlv_rec.asset_vendor_id);
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
  -- Validate Record for:OKL_EXT_FA_LINE_SOURCES_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_fxlv_rec IN fxlv_rec_type,
    p_db_fxlv_rec IN fxlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_fxlv_rec IN fxlv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_fxlv_rec                  fxlv_rec_type := get_rec(p_fxlv_rec);
  BEGIN
    l_return_status := Validate_Record(p_fxlv_rec => p_fxlv_rec,
                                       p_db_fxlv_rec => l_db_fxlv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN fxlv_rec_type,
    p_to   IN OUT NOCOPY fxl_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.header_extension_id := p_from.header_extension_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.fa_transaction_id := p_from.fa_transaction_id;
    p_to.asset_id := p_from.asset_id;
    p_to.kle_id := p_from.kle_id;
    p_to.asset_number := p_from.asset_number;
    p_to.contract_line_number := p_from.contract_line_number;
    p_to.asset_book_type_name := p_from.asset_book_type_name;
    p_to.asset_vendor_name := p_from.asset_vendor_name;
    p_to.installed_site_id := p_from.installed_site_id;
    p_to.line_attribute_category := p_from.line_attribute_category;
    p_to.line_attribute1 := p_from.line_attribute1;
    p_to.line_attribute2 := p_from.line_attribute2;
    p_to.line_attribute3 := p_from.line_attribute3;
    p_to.line_attribute4 := p_from.line_attribute4;
    p_to.line_attribute5 := p_from.line_attribute5;
    p_to.line_attribute6 := p_from.line_attribute6;
    p_to.line_attribute7 := p_from.line_attribute7;
    p_to.line_attribute8 := p_from.line_attribute8;
    p_to.line_attribute9 := p_from.line_attribute9;
    p_to.line_attribute10 := p_from.line_attribute10;
    p_to.line_attribute11 := p_from.line_attribute11;
    p_to.line_attribute12 := p_from.line_attribute12;
    p_to.line_attribute13 := p_from.line_attribute13;
    p_to.line_attribute14 := p_from.line_attribute14;
    p_to.line_attribute15 := p_from.line_attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.inventory_org_code := p_from.inventory_org_code;
    p_to.asset_book_type_code := p_from.asset_book_type_code;
    p_to.period_counter := p_from.period_counter;
    p_to.asset_vendor_id := p_from.asset_vendor_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN fxl_rec_type,
    p_to   IN OUT NOCOPY fxlv_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.header_extension_id := p_from.header_extension_id;
    p_to.source_id := p_from.source_id;
    p_to.source_table := p_from.source_table;
    p_to.object_version_number := p_from.object_version_number;
    p_to.fa_transaction_id := p_from.fa_transaction_id;
    p_to.asset_id := p_from.asset_id;
    p_to.kle_id := p_from.kle_id;
    p_to.asset_number := p_from.asset_number;
    p_to.contract_line_number := p_from.contract_line_number;
    p_to.asset_book_type_name := p_from.asset_book_type_name;
    p_to.asset_vendor_name := p_from.asset_vendor_name;
    p_to.installed_site_id := p_from.installed_site_id;
    p_to.line_attribute_category := p_from.line_attribute_category;
    p_to.line_attribute1 := p_from.line_attribute1;
    p_to.line_attribute2 := p_from.line_attribute2;
    p_to.line_attribute3 := p_from.line_attribute3;
    p_to.line_attribute4 := p_from.line_attribute4;
    p_to.line_attribute5 := p_from.line_attribute5;
    p_to.line_attribute6 := p_from.line_attribute6;
    p_to.line_attribute7 := p_from.line_attribute7;
    p_to.line_attribute8 := p_from.line_attribute8;
    p_to.line_attribute9 := p_from.line_attribute9;
    p_to.line_attribute10 := p_from.line_attribute10;
    p_to.line_attribute11 := p_from.line_attribute11;
    p_to.line_attribute12 := p_from.line_attribute12;
    p_to.line_attribute13 := p_from.line_attribute13;
    p_to.line_attribute14 := p_from.line_attribute14;
    p_to.line_attribute15 := p_from.line_attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.inventory_org_code := p_from.inventory_org_code;
    p_to.asset_book_type_code := p_from.asset_book_type_code;
    p_to.period_counter := p_from.period_counter;
    p_to.asset_vendor_id := p_from.asset_vendor_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN fxlv_rec_type,
    p_to   IN OUT NOCOPY fxll_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.language := p_from.language;
    p_to.inventory_org_name := p_from.inventory_org_name;
    p_to.trans_line_description := p_from.trans_line_description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN fxll_rec_type,
    p_to   IN OUT NOCOPY fxlv_rec_type
  ) IS
  BEGIN
    p_to.line_extension_id := p_from.line_extension_id;
    p_to.language := p_from.language;
    p_to.inventory_org_name := p_from.inventory_org_name;
    p_to.trans_line_description := p_from.trans_line_description;
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
  -- validate_row for:OKL_EXT_FA_LINE_SOURCES_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxlv_rec                     fxlv_rec_type := p_fxlv_rec;
    l_fxl_rec                      fxl_rec_type;
    l_fxll_rec                     fxll_rec_type;
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
    l_return_status := Validate_Attributes(l_fxlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_fxlv_rec);
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
  -- PL/SQL TBL validate_row for:OKL_EXT_FA_LINE_SOURCES_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      i := p_fxlv_tbl.FIRST;
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
            p_fxlv_rec                     => p_fxlv_tbl(i));
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
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKL_EXT_FA_LINE_SOURCES_V --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fxlv_tbl                     => p_fxlv_tbl,
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
  -- insert_row for:OKL_EXT_FA_LINE_SOURCES_B --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxl_rec                      IN fxl_rec_type,
    x_fxl_rec                      OUT NOCOPY fxl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxl_rec                      fxl_rec_type := p_fxl_rec;
    l_def_fxl_rec                  fxl_rec_type;
    --------------------------------------------------
    -- Set_Attributes for:OKL_EXT_FA_LINE_SOURCES_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_fxl_rec IN fxl_rec_type,
      x_fxl_rec OUT NOCOPY fxl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxl_rec := p_fxl_rec;
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
      l_fxl_rec,                         -- IN
      l_def_fxl_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_EXT_FA_LINE_SOURCES_B(
      line_extension_id,
      header_extension_id,
      source_id,
      source_table,
      object_version_number,
      fa_transaction_id,
      asset_id,
      kle_id,
      asset_number,
      contract_line_number,
      asset_book_type_name,
      asset_vendor_name,
      installed_site_id,
      line_attribute_category,
      line_attribute1,
      line_attribute2,
      line_attribute3,
      line_attribute4,
      line_attribute5,
      line_attribute6,
      line_attribute7,
      line_attribute8,
      line_attribute9,
      line_attribute10,
      line_attribute11,
      line_attribute12,
      line_attribute13,
      line_attribute14,
      line_attribute15,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      inventory_org_code
      ,asset_book_type_code
      ,period_counter
      ,asset_vendor_id)
    VALUES (
      l_def_fxl_rec.line_extension_id,
      l_def_fxl_rec.header_extension_id,
      l_def_fxl_rec.source_id,
      l_def_fxl_rec.source_table,
      l_def_fxl_rec.object_version_number,
      l_def_fxl_rec.fa_transaction_id,
      l_def_fxl_rec.asset_id,
      l_def_fxl_rec.kle_id,
      l_def_fxl_rec.asset_number,
      l_def_fxl_rec.contract_line_number,
      l_def_fxl_rec.asset_book_type_name,
      l_def_fxl_rec.asset_vendor_name,
      l_def_fxl_rec.installed_site_id,
      l_def_fxl_rec.line_attribute_category,
      l_def_fxl_rec.line_attribute1,
      l_def_fxl_rec.line_attribute2,
      l_def_fxl_rec.line_attribute3,
      l_def_fxl_rec.line_attribute4,
      l_def_fxl_rec.line_attribute5,
      l_def_fxl_rec.line_attribute6,
      l_def_fxl_rec.line_attribute7,
      l_def_fxl_rec.line_attribute8,
      l_def_fxl_rec.line_attribute9,
      l_def_fxl_rec.line_attribute10,
      l_def_fxl_rec.line_attribute11,
      l_def_fxl_rec.line_attribute12,
      l_def_fxl_rec.line_attribute13,
      l_def_fxl_rec.line_attribute14,
      l_def_fxl_rec.line_attribute15,
      l_def_fxl_rec.created_by,
      l_def_fxl_rec.creation_date,
      l_def_fxl_rec.last_updated_by,
      l_def_fxl_rec.last_update_date,
      l_def_fxl_rec.last_update_login,
      l_def_fxl_rec.inventory_org_code
      ,l_def_fxl_rec.asset_book_type_code
      ,l_def_fxl_rec.period_counter
       ,l_def_fxl_rec.asset_vendor_id);
    -- Set OUT values
    x_fxl_rec := l_def_fxl_rec;
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
  -- insert_row for:OKL_EXT_FA_LINE_SOURCES_TL --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxll_rec                     IN fxll_rec_type,
    x_fxll_rec                     OUT NOCOPY fxll_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxll_rec                     fxll_rec_type := p_fxll_rec;
    l_def_fxll_rec                 fxll_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------------------
    -- Set_Attributes for:OKL_EXT_FA_LINE_SOURCES_TL --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_fxll_rec IN fxll_rec_type,
      x_fxll_rec OUT NOCOPY fxll_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxll_rec := p_fxll_rec;
      x_fxLl_rec.SFWT_FLAG := 'N';
      x_fxll_rec.SOURCE_LANG := USERENV('LANG');
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
      p_fxll_rec,                        -- IN
      l_fxll_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_EXT_FA_LINE_SOURCES_TL(
      line_extension_id,
      language,
      source_lang,
      sfwt_flag,
      inventory_org_name,
      trans_line_description,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_fxll_rec.line_extension_id,
      l_fxll_rec.language,
      l_fxll_rec.source_lang,
      l_fxll_rec.sfwt_flag,
      l_fxll_rec.inventory_org_name,
      l_fxll_rec.trans_line_description,
      l_fxll_rec.created_by,
      l_fxll_rec.creation_date,
      l_fxll_rec.last_updated_by,
      l_fxll_rec.last_update_date,
      l_fxll_rec.last_update_login);
    -- Set OUT values
    x_fxll_rec := l_fxll_rec;
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
  -- insert_row for :OKL_EXT_FA_LINE_SOURCES_B --
  -----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type,
    x_fxlv_rec                     OUT NOCOPY fxlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxlv_rec                     fxlv_rec_type := p_fxlv_rec;
    l_def_fxlv_rec                 fxlv_rec_type;
    l_fxl_rec                      fxl_rec_type;
    lx_fxl_rec                     fxl_rec_type;
    l_fxll_rec                     fxll_rec_type;
    lx_fxll_rec                    fxll_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fxlv_rec IN fxlv_rec_type
    ) RETURN fxlv_rec_type IS
      l_fxlv_rec fxlv_rec_type := p_fxlv_rec;
    BEGIN
      l_fxlv_rec.CREATION_DATE := SYSDATE;
      l_fxlv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_fxlv_rec.LAST_UPDATE_DATE := l_fxlv_rec.CREATION_DATE;
      l_fxlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fxlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fxlv_rec);
    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKL_EXT_FA_LINE_SOURCES_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_fxlv_rec IN fxlv_rec_type,
      x_fxlv_rec OUT NOCOPY fxlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxlv_rec := p_fxlv_rec;
      x_fxlv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_fxlv_rec := null_out_defaults(p_fxlv_rec);
    -- Set primary key value
    l_fxlv_rec.LINE_EXTENSION_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_fxlv_rec,                        -- IN
      l_def_fxlv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fxlv_rec := fill_who_columns(l_def_fxlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fxlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fxlv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_fxlv_rec, l_fxl_rec);
    migrate(l_def_fxlv_rec, l_fxll_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fxl_rec,
      lx_fxl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fxl_rec, l_def_fxlv_rec);
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fxll_rec,
      lx_fxll_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fxll_rec, l_def_fxlv_rec);
    -- Set OUT values
    x_fxlv_rec := l_def_fxlv_rec;
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
  -- PL/SQL TBL insert_row for:FXLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      i := p_fxlv_tbl.FIRST;
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
            p_fxlv_rec                     => p_fxlv_tbl(i),
            x_fxlv_rec                     => x_fxlv_tbl(i));
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
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:FXLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fxlv_tbl                     => p_fxlv_tbl,
        x_fxlv_tbl                     => x_fxlv_tbl,
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
  -- lock_row for:OKL_EXT_FA_LINE_SOURCES_B --
  --------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxl_rec                      IN fxl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_fxl_rec IN fxl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_FA_LINE_SOURCES_B
     WHERE LINE_EXTENSION_ID = p_fxl_rec.line_extension_id
       AND OBJECT_VERSION_NUMBER = p_fxl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_fxl_rec IN fxl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_EXT_FA_LINE_SOURCES_B
     WHERE LINE_EXTENSION_ID = p_fxl_rec.line_extension_id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_EXT_FA_LINE_SOURCES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_EXT_FA_LINE_SOURCES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_fxl_rec);
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
      OPEN lchk_csr(p_fxl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_fxl_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_fxl_rec.object_version_number THEN
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
  -- lock_row for:OKL_EXT_FA_LINE_SOURCES_TL --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxll_rec                     IN fxll_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_fxll_rec IN fxll_rec_type) IS
    SELECT *
      FROM OKL_EXT_FA_LINE_SOURCES_TL
     WHERE LINE_EXTENSION_ID = p_fxll_rec.line_extension_id
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
      OPEN lock_csr(p_fxll_rec);
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
  -- lock_row for: OKL_EXT_FA_LINE_SOURCES_V --
  ---------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxl_rec                      fxl_rec_type;
    l_fxll_rec                     fxll_rec_type;
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
    migrate(p_fxlv_rec, l_fxl_rec);
    migrate(p_fxlv_rec, l_fxll_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fxl_rec
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
      l_fxll_rec
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
  -- PL/SQL TBL lock_row for:FXLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      i := p_fxlv_tbl.FIRST;
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
            p_fxlv_rec                     => p_fxlv_tbl(i));
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
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:FXLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fxlv_tbl                     => p_fxlv_tbl,
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
  -- update_row for:OKL_EXT_FA_LINE_SOURCES_B --
  ----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxl_rec                      IN fxl_rec_type,
    x_fxl_rec                      OUT NOCOPY fxl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxl_rec                      fxl_rec_type := p_fxl_rec;
    l_def_fxl_rec                  fxl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fxl_rec IN fxl_rec_type,
      x_fxl_rec OUT NOCOPY fxl_rec_type
    ) RETURN VARCHAR2 IS
      l_fxl_rec                      fxl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxl_rec := p_fxl_rec;
      -- Get current database values
      l_fxl_rec := get_rec(p_fxl_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_fxl_rec.line_extension_id IS NULL THEN
          x_fxl_rec.line_extension_id := l_fxl_rec.line_extension_id;
        END IF;
        IF x_fxl_rec.header_extension_id IS NULL THEN
          x_fxl_rec.header_extension_id := l_fxl_rec.header_extension_id;
        END IF;
        IF x_fxl_rec.source_id IS NULL THEN
          x_fxl_rec.source_id := l_fxl_rec.source_id;
        END IF;
        IF x_fxl_rec.source_table IS NULL THEN
          x_fxl_rec.source_table := l_fxl_rec.source_table;
        END IF;
        IF x_fxl_rec.object_version_number IS NULL THEN
          x_fxl_rec.object_version_number := l_fxl_rec.object_version_number;
        END IF;
        IF x_fxl_rec.fa_transaction_id IS NULL THEN
          x_fxl_rec.fa_transaction_id := l_fxl_rec.fa_transaction_id;
        END IF;
        IF x_fxl_rec.asset_id IS NULL THEN
          x_fxl_rec.asset_id := l_fxl_rec.asset_id;
        END IF;
        IF x_fxl_rec.kle_id IS NULL THEN
          x_fxl_rec.kle_id := l_fxl_rec.kle_id;
        END IF;
        IF x_fxl_rec.asset_number IS NULL THEN
          x_fxl_rec.asset_number := l_fxl_rec.asset_number;
        END IF;
        IF x_fxl_rec.contract_line_number IS NULL THEN
          x_fxl_rec.contract_line_number := l_fxl_rec.contract_line_number;
        END IF;
        IF x_fxl_rec.asset_book_type_name IS NULL THEN
          x_fxl_rec.asset_book_type_name := l_fxl_rec.asset_book_type_name;
        END IF;
        IF x_fxl_rec.asset_vendor_name IS NULL THEN
          x_fxl_rec.asset_vendor_name := l_fxl_rec.asset_vendor_name;
        END IF;
        IF x_fxl_rec.installed_site_id IS NULL THEN
          x_fxl_rec.installed_site_id := l_fxl_rec.installed_site_id;
        END IF;
        IF x_fxl_rec.line_attribute_category IS NULL THEN
          x_fxl_rec.line_attribute_category := l_fxl_rec.line_attribute_category;
        END IF;
        IF x_fxl_rec.line_attribute1 IS NULL THEN
          x_fxl_rec.line_attribute1 := l_fxl_rec.line_attribute1;
        END IF;
        IF x_fxl_rec.line_attribute2 IS NULL THEN
          x_fxl_rec.line_attribute2 := l_fxl_rec.line_attribute2;
        END IF;
        IF x_fxl_rec.line_attribute3 IS NULL THEN
          x_fxl_rec.line_attribute3 := l_fxl_rec.line_attribute3;
        END IF;
        IF x_fxl_rec.line_attribute4 IS NULL THEN
          x_fxl_rec.line_attribute4 := l_fxl_rec.line_attribute4;
        END IF;
        IF x_fxl_rec.line_attribute5 IS NULL THEN
          x_fxl_rec.line_attribute5 := l_fxl_rec.line_attribute5;
        END IF;
        IF x_fxl_rec.line_attribute6 IS NULL THEN
          x_fxl_rec.line_attribute6 := l_fxl_rec.line_attribute6;
        END IF;
        IF x_fxl_rec.line_attribute7 IS NULL THEN
          x_fxl_rec.line_attribute7 := l_fxl_rec.line_attribute7;
        END IF;
        IF x_fxl_rec.line_attribute8 IS NULL THEN
          x_fxl_rec.line_attribute8 := l_fxl_rec.line_attribute8;
        END IF;
        IF x_fxl_rec.line_attribute9 IS NULL THEN
          x_fxl_rec.line_attribute9 := l_fxl_rec.line_attribute9;
        END IF;
        IF x_fxl_rec.line_attribute10 IS NULL THEN
          x_fxl_rec.line_attribute10 := l_fxl_rec.line_attribute10;
        END IF;
        IF x_fxl_rec.line_attribute11 IS NULL THEN
          x_fxl_rec.line_attribute11 := l_fxl_rec.line_attribute11;
        END IF;
        IF x_fxl_rec.line_attribute12 IS NULL THEN
          x_fxl_rec.line_attribute12 := l_fxl_rec.line_attribute12;
        END IF;
        IF x_fxl_rec.line_attribute13 IS NULL THEN
          x_fxl_rec.line_attribute13 := l_fxl_rec.line_attribute13;
        END IF;
        IF x_fxl_rec.line_attribute14 IS NULL THEN
          x_fxl_rec.line_attribute14 := l_fxl_rec.line_attribute14;
        END IF;
        IF x_fxl_rec.line_attribute15 IS NULL THEN
          x_fxl_rec.line_attribute15 := l_fxl_rec.line_attribute15;
        END IF;
        IF x_fxl_rec.created_by IS NULL THEN
          x_fxl_rec.created_by := l_fxl_rec.created_by;
        END IF;
        IF x_fxl_rec.creation_date IS NULL THEN
          x_fxl_rec.creation_date := l_fxl_rec.creation_date;
        END IF;
        IF x_fxl_rec.last_updated_by IS NULL THEN
          x_fxl_rec.last_updated_by := l_fxl_rec.last_updated_by;
        END IF;
        IF x_fxl_rec.last_update_date IS NULL THEN
          x_fxl_rec.last_update_date := l_fxl_rec.last_update_date;
        END IF;
        IF x_fxl_rec.last_update_login IS NULL THEN
          x_fxl_rec.last_update_login := l_fxl_rec.last_update_login;
        END IF;
        IF x_fxl_rec.inventory_org_code IS NULL THEN
          x_fxl_rec.inventory_org_code := l_fxl_rec.inventory_org_code;
        END IF;
        IF x_fxl_rec.asset_book_type_code IS NULL THEN
          x_fxl_rec.asset_book_type_code := l_fxl_rec.asset_book_type_code;
        END IF;
        IF x_fxl_rec.period_Counter IS NULL THEN
          x_fxl_rec.period_Counter := l_fxl_rec.period_Counter;
        END IF;
	 IF x_fxl_rec.asset_vendor_id IS NULL THEN
          x_fxl_rec.asset_vendor_id := l_fxl_rec.asset_vendor_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_EXT_FA_LINE_SOURCES_B --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_fxl_rec IN fxl_rec_type,
      x_fxl_rec OUT NOCOPY fxl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxl_rec := p_fxl_rec;
      x_fxl_rec.OBJECT_VERSION_NUMBER := p_fxl_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_fxl_rec,                         -- IN
      l_fxl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fxl_rec, l_def_fxl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_EXT_FA_LINE_SOURCES_B
    SET HEADER_EXTENSION_ID = l_def_fxl_rec.header_extension_id,
        SOURCE_ID = l_def_fxl_rec.source_id,
        SOURCE_TABLE = l_def_fxl_rec.source_table,
        OBJECT_VERSION_NUMBER = l_def_fxl_rec.object_version_number,
        FA_TRANSACTION_ID = l_def_fxl_rec.fa_transaction_id,
        ASSET_ID = l_def_fxl_rec.asset_id,
        KLE_ID = l_def_fxl_rec.kle_id,
        ASSET_NUMBER = l_def_fxl_rec.asset_number,
        CONTRACT_LINE_NUMBER = l_def_fxl_rec.contract_line_number,
        ASSET_BOOK_TYPE_NAME = l_def_fxl_rec.asset_book_type_name,
        ASSET_VENDOR_NAME = l_def_fxl_rec.asset_vendor_name,
        INSTALLED_SITE_ID = l_def_fxl_rec.installed_site_id,
        LINE_ATTRIBUTE_CATEGORY = l_def_fxl_rec.line_attribute_category,
        LINE_ATTRIBUTE1 = l_def_fxl_rec.line_attribute1,
        LINE_ATTRIBUTE2 = l_def_fxl_rec.line_attribute2,
        LINE_ATTRIBUTE3 = l_def_fxl_rec.line_attribute3,
        LINE_ATTRIBUTE4 = l_def_fxl_rec.line_attribute4,
        LINE_ATTRIBUTE5 = l_def_fxl_rec.line_attribute5,
        LINE_ATTRIBUTE6 = l_def_fxl_rec.line_attribute6,
        LINE_ATTRIBUTE7 = l_def_fxl_rec.line_attribute7,
        LINE_ATTRIBUTE8 = l_def_fxl_rec.line_attribute8,
        LINE_ATTRIBUTE9 = l_def_fxl_rec.line_attribute9,
        LINE_ATTRIBUTE10 = l_def_fxl_rec.line_attribute10,
        LINE_ATTRIBUTE11 = l_def_fxl_rec.line_attribute11,
        LINE_ATTRIBUTE12 = l_def_fxl_rec.line_attribute12,
        LINE_ATTRIBUTE13 = l_def_fxl_rec.line_attribute13,
        LINE_ATTRIBUTE14 = l_def_fxl_rec.line_attribute14,
        LINE_ATTRIBUTE15 = l_def_fxl_rec.line_attribute15,
        CREATED_BY = l_def_fxl_rec.created_by,
        CREATION_DATE = l_def_fxl_rec.creation_date,
        LAST_UPDATED_BY = l_def_fxl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_fxl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_fxl_rec.last_update_login,
        INVENTORY_ORG_CODE = l_def_fxl_rec.inventory_org_code,
        ASSET_BOOK_TYPE_CODE = l_def_fxl_rec.asset_book_type_code,
        PERIOD_COUNTER = l_def_fxl_rec.period_counter,
	ASSET_VENDOR_ID = l_def_fxl_rec.asset_vendor_id
    WHERE LINE_EXTENSION_ID = l_def_fxl_rec.line_extension_id;

    x_fxl_rec := l_fxl_rec;
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
  -- update_row for:OKL_EXT_FA_LINE_SOURCES_TL --
  -----------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxll_rec                     IN fxll_rec_type,
    x_fxll_rec                     OUT NOCOPY fxll_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxll_rec                     fxll_rec_type := p_fxll_rec;
    l_def_fxll_rec                 fxll_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fxll_rec IN fxll_rec_type,
      x_fxll_rec OUT NOCOPY fxll_rec_type
    ) RETURN VARCHAR2 IS
      l_fxll_rec                     fxll_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxll_rec := p_fxll_rec;
      -- Get current database values
      l_fxll_rec := get_rec(p_fxll_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_fxll_rec.line_extension_id IS NULL THEN
          x_fxll_rec.line_extension_id := l_fxll_rec.line_extension_id;
        END IF;
        IF x_fxll_rec.language IS NULL THEN
          x_fxll_rec.language := l_fxll_rec.language;
        END IF;
        IF x_fxll_rec.source_lang IS NULL THEN
          x_fxll_rec.source_lang := l_fxll_rec.source_lang;
        END IF;
        IF x_fxll_rec.sfwt_flag IS NULL THEN
          x_fxll_rec.sfwt_flag := l_fxll_rec.sfwt_flag;
        END IF;
        IF x_fxll_rec.inventory_org_name IS NULL THEN
          x_fxll_rec.inventory_org_name := l_fxll_rec.inventory_org_name;
        END IF;
        IF x_fxll_rec.trans_line_description IS NULL THEN
          x_fxll_rec.trans_line_description := l_fxll_rec.trans_line_description;
        END IF;
        IF x_fxll_rec.created_by IS NULL THEN
          x_fxll_rec.created_by := l_fxll_rec.created_by;
        END IF;
        IF x_fxll_rec.creation_date IS NULL THEN
          x_fxll_rec.creation_date := l_fxll_rec.creation_date;
        END IF;
        IF x_fxll_rec.last_updated_by IS NULL THEN
          x_fxll_rec.last_updated_by := l_fxll_rec.last_updated_by;
        END IF;
        IF x_fxll_rec.last_update_date IS NULL THEN
          x_fxll_rec.last_update_date := l_fxll_rec.last_update_date;
        END IF;
        IF x_fxll_rec.last_update_login IS NULL THEN
          x_fxll_rec.last_update_login := l_fxll_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_EXT_FA_LINE_SOURCES_TL --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_fxll_rec IN fxll_rec_type,
      x_fxll_rec OUT NOCOPY fxll_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxll_rec := p_fxll_rec;
      x_fxll_rec.LANGUAGE := USERENV('LANG');
      x_fxll_rec.LANGUAGE := USERENV('LANG');
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
      p_fxll_rec,                        -- IN
      l_fxll_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fxll_rec, l_def_fxll_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_EXT_FA_LINE_SOURCES_TL
    SET INVENTORY_ORG_NAME = l_def_fxll_rec.inventory_org_name,
        TRANS_LINE_DESCRIPTION = l_def_fxll_rec.trans_line_description,
        CREATED_BY = l_def_fxll_rec.created_by,
        CREATION_DATE = l_def_fxll_rec.creation_date,
        LAST_UPDATED_BY = l_def_fxll_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_fxll_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_fxll_rec.last_update_login
    WHERE LINE_EXTENSION_ID = l_def_fxll_rec.line_extension_id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_EXT_FA_LINE_SOURCES_TL
    SET SFWT_FLAG = 'Y'
    WHERE LINE_EXTENSION_ID = l_def_fxll_rec.line_extension_id
      AND SOURCE_LANG <> USERENV('LANG');

    x_fxll_rec := l_fxll_rec;
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
  -- update_row for:OKL_EXT_FA_LINE_SOURCES_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type,
    x_fxlv_rec                     OUT NOCOPY fxlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxlv_rec                     fxlv_rec_type := p_fxlv_rec;
    l_def_fxlv_rec                 fxlv_rec_type;
    l_db_fxlv_rec                  fxlv_rec_type;
    l_fxl_rec                      fxl_rec_type;
    lx_fxl_rec                     fxl_rec_type;
    l_fxll_rec                     fxll_rec_type;
    lx_fxll_rec                    fxll_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fxlv_rec IN fxlv_rec_type
    ) RETURN fxlv_rec_type IS
      l_fxlv_rec fxlv_rec_type := p_fxlv_rec;
    BEGIN
      l_fxlv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_fxlv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fxlv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fxlv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_fxlv_rec IN fxlv_rec_type,
      x_fxlv_rec OUT NOCOPY fxlv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxlv_rec := p_fxlv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_fxlv_rec := get_rec(p_fxlv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_fxlv_rec.line_extension_id IS NULL THEN
          x_fxlv_rec.line_extension_id := l_db_fxlv_rec.line_extension_id;
        END IF;
        IF x_fxlv_rec.header_extension_id IS NULL THEN
          x_fxlv_rec.header_extension_id := l_db_fxlv_rec.header_extension_id;
        END IF;
        IF x_fxlv_rec.source_id IS NULL THEN
          x_fxlv_rec.source_id := l_db_fxlv_rec.source_id;
        END IF;
        IF x_fxlv_rec.source_table IS NULL THEN
          x_fxlv_rec.source_table := l_db_fxlv_rec.source_table;
        END IF;
        IF x_fxlv_rec.fa_transaction_id IS NULL THEN
          x_fxlv_rec.fa_transaction_id := l_db_fxlv_rec.fa_transaction_id;
        END IF;
        IF x_fxlv_rec.asset_id IS NULL THEN
          x_fxlv_rec.asset_id := l_db_fxlv_rec.asset_id;
        END IF;
        IF x_fxlv_rec.kle_id IS NULL THEN
          x_fxlv_rec.kle_id := l_db_fxlv_rec.kle_id;
        END IF;
        IF x_fxlv_rec.asset_number IS NULL THEN
          x_fxlv_rec.asset_number := l_db_fxlv_rec.asset_number;
        END IF;
        IF x_fxlv_rec.contract_line_number IS NULL THEN
          x_fxlv_rec.contract_line_number := l_db_fxlv_rec.contract_line_number;
        END IF;
        IF x_fxlv_rec.asset_book_type_name IS NULL THEN
          x_fxlv_rec.asset_book_type_name := l_db_fxlv_rec.asset_book_type_name;
        END IF;
        IF x_fxlv_rec.asset_vendor_name IS NULL THEN
          x_fxlv_rec.asset_vendor_name := l_db_fxlv_rec.asset_vendor_name;
        END IF;
        IF x_fxlv_rec.installed_site_id IS NULL THEN
          x_fxlv_rec.installed_site_id := l_db_fxlv_rec.installed_site_id;
        END IF;
        IF x_fxlv_rec.line_attribute_category IS NULL THEN
          x_fxlv_rec.line_attribute_category := l_db_fxlv_rec.line_attribute_category;
        END IF;
        IF x_fxlv_rec.line_attribute1 IS NULL THEN
          x_fxlv_rec.line_attribute1 := l_db_fxlv_rec.line_attribute1;
        END IF;
        IF x_fxlv_rec.line_attribute2 IS NULL THEN
          x_fxlv_rec.line_attribute2 := l_db_fxlv_rec.line_attribute2;
        END IF;
        IF x_fxlv_rec.line_attribute3 IS NULL THEN
          x_fxlv_rec.line_attribute3 := l_db_fxlv_rec.line_attribute3;
        END IF;
        IF x_fxlv_rec.line_attribute4 IS NULL THEN
          x_fxlv_rec.line_attribute4 := l_db_fxlv_rec.line_attribute4;
        END IF;
        IF x_fxlv_rec.line_attribute5 IS NULL THEN
          x_fxlv_rec.line_attribute5 := l_db_fxlv_rec.line_attribute5;
        END IF;
        IF x_fxlv_rec.line_attribute6 IS NULL THEN
          x_fxlv_rec.line_attribute6 := l_db_fxlv_rec.line_attribute6;
        END IF;
        IF x_fxlv_rec.line_attribute7 IS NULL THEN
          x_fxlv_rec.line_attribute7 := l_db_fxlv_rec.line_attribute7;
        END IF;
        IF x_fxlv_rec.line_attribute8 IS NULL THEN
          x_fxlv_rec.line_attribute8 := l_db_fxlv_rec.line_attribute8;
        END IF;
        IF x_fxlv_rec.line_attribute9 IS NULL THEN
          x_fxlv_rec.line_attribute9 := l_db_fxlv_rec.line_attribute9;
        END IF;
        IF x_fxlv_rec.line_attribute10 IS NULL THEN
          x_fxlv_rec.line_attribute10 := l_db_fxlv_rec.line_attribute10;
        END IF;
        IF x_fxlv_rec.line_attribute11 IS NULL THEN
          x_fxlv_rec.line_attribute11 := l_db_fxlv_rec.line_attribute11;
        END IF;
        IF x_fxlv_rec.line_attribute12 IS NULL THEN
          x_fxlv_rec.line_attribute12 := l_db_fxlv_rec.line_attribute12;
        END IF;
        IF x_fxlv_rec.line_attribute13 IS NULL THEN
          x_fxlv_rec.line_attribute13 := l_db_fxlv_rec.line_attribute13;
        END IF;
        IF x_fxlv_rec.line_attribute14 IS NULL THEN
          x_fxlv_rec.line_attribute14 := l_db_fxlv_rec.line_attribute14;
        END IF;
        IF x_fxlv_rec.line_attribute15 IS NULL THEN
          x_fxlv_rec.line_attribute15 := l_db_fxlv_rec.line_attribute15;
        END IF;
        IF x_fxlv_rec.language IS NULL THEN
          x_fxlv_rec.language := l_db_fxlv_rec.language;
        END IF;
        IF x_fxlv_rec.inventory_org_name IS NULL THEN
          x_fxlv_rec.inventory_org_name := l_db_fxlv_rec.inventory_org_name;
        END IF;
        IF x_fxlv_rec.trans_line_description IS NULL THEN
          x_fxlv_rec.trans_line_description := l_db_fxlv_rec.trans_line_description;
        END IF;
        IF x_fxlv_rec.created_by IS NULL THEN
          x_fxlv_rec.created_by := l_db_fxlv_rec.created_by;
        END IF;
        IF x_fxlv_rec.creation_date IS NULL THEN
          x_fxlv_rec.creation_date := l_db_fxlv_rec.creation_date;
        END IF;
        IF x_fxlv_rec.last_updated_by IS NULL THEN
          x_fxlv_rec.last_updated_by := l_db_fxlv_rec.last_updated_by;
        END IF;
        IF x_fxlv_rec.last_update_date IS NULL THEN
          x_fxlv_rec.last_update_date := l_db_fxlv_rec.last_update_date;
        END IF;
        IF x_fxlv_rec.last_update_login IS NULL THEN
          x_fxlv_rec.last_update_login := l_db_fxlv_rec.last_update_login;
        END IF;
        IF x_fxlv_rec.inventory_org_code IS NULL THEN
          x_fxlv_rec.inventory_org_code := l_db_fxlv_rec.inventory_org_code;
        END IF;
        IF x_fxlv_rec.asset_book_type_code IS NULL THEN
          x_fxlv_rec.asset_book_type_code := l_db_fxlv_rec.asset_book_type_code;
        END IF;
        IF x_fxlv_rec.period_counter IS NULL THEN
          x_fxlv_rec.period_counter := l_db_fxlv_rec.period_counter;
        END IF;
	 IF x_fxlv_rec.asset_vendor_id IS NULL THEN
          x_fxlv_rec.asset_vendor_id := l_db_fxlv_rec.asset_vendor_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKL_EXT_FA_LINE_SOURCES_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_fxlv_rec IN fxlv_rec_type,
      x_fxlv_rec OUT NOCOPY fxlv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxlv_rec := p_fxlv_rec;
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
      p_fxlv_rec,                        -- IN
      x_fxlv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_fxlv_rec, l_def_fxlv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fxlv_rec := null_out_defaults(l_def_fxlv_rec);
    l_def_fxlv_rec := fill_who_columns(l_def_fxlv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_fxlv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_fxlv_rec, l_db_fxlv_rec);
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
      p_fxlv_rec                     => p_fxlv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_fxlv_rec, l_fxl_rec);
    migrate(l_def_fxlv_rec, l_fxll_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fxl_rec,
      lx_fxl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fxl_rec, l_def_fxlv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fxll_rec,
      lx_fxll_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_fxll_rec, l_def_fxlv_rec);
    x_fxlv_rec := l_def_fxlv_rec;
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
  -- PL/SQL TBL update_row for:fxlv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      i := p_fxlv_tbl.FIRST;
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
            p_fxlv_rec                     => p_fxlv_tbl(i),
            x_fxlv_rec                     => x_fxlv_tbl(i));
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
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:FXLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    x_fxlv_tbl                     OUT NOCOPY fxlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fxlv_tbl                     => p_fxlv_tbl,
        x_fxlv_tbl                     => x_fxlv_tbl,
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
  -- delete_row for:OKL_EXT_FA_LINE_SOURCES_B --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxl_rec                      IN fxl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxl_rec                      fxl_rec_type := p_fxl_rec;
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

    DELETE FROM OKL_EXT_FA_LINE_SOURCES_B
     WHERE LINE_EXTENSION_ID = p_fxl_rec.line_extension_id;

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
  -- delete_row for:OKL_EXT_FA_LINE_SOURCES_TL --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxll_rec                     IN fxll_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxll_rec                     fxll_rec_type := p_fxll_rec;
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

    DELETE FROM OKL_EXT_FA_LINE_SOURCES_TL
     WHERE LINE_EXTENSION_ID = p_fxll_rec.line_extension_id;

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
  -- delete_row for:OKL_EXT_FA_LINE_SOURCES_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_rec                     IN fxlv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_fxlv_rec                     fxlv_rec_type := p_fxlv_rec;
    l_fxll_rec                     fxll_rec_type;
    l_fxl_rec                      fxl_rec_type;
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
    migrate(l_fxlv_rec, l_fxll_rec);
    migrate(l_fxlv_rec, l_fxl_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fxll_rec
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
      l_fxl_rec
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
  -- PL/SQL TBL delete_row for:OKL_EXT_FA_LINE_SOURCES_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      i := p_fxlv_tbl.FIRST;
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
            p_fxlv_rec                     => p_fxlv_tbl(i));
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
        EXIT WHEN (i = p_fxlv_tbl.LAST);
        i := p_fxlv_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKL_EXT_FA_LINE_SOURCES_V --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxlv_tbl                     IN fxlv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_fxlv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_fxlv_tbl                     => p_fxlv_tbl,
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

  -- Added : Bug# 6268782 : PRASJAIN
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_fxl_rec                      IN fxl_rec_type,
    p_fxll_tbl                     IN fxll_tbl_type,
    x_fxl_rec                      OUT NOCOPY fxl_rec_type,
    x_fxll_tbl                     OUT NOCOPY fxll_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_fxl_rec                      fxl_rec_type := p_fxl_rec;
    l_def_fxl_rec                  fxl_rec_type;
    lx_fxl_rec                     fxl_rec_type;

    l_fxll_tbl                     okl_fxl_pvt.fxll_tbl_type := p_fxll_tbl;
    lx_fxll_tbl                    okl_fxl_pvt.fxll_tbl_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_fxl_rec IN fxl_rec_type
    ) RETURN fxl_rec_type IS
      l_fxl_rec fxl_rec_type := p_fxl_rec;
    BEGIN
      l_fxl_rec.CREATION_DATE := SYSDATE;
      l_fxl_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_fxl_rec.LAST_UPDATE_DATE := l_fxl_rec.CREATION_DATE;
      l_fxl_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fxl_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_fxl_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_TXL_EXTENSION_B --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_fxl_rec IN fxl_rec_type,
      x_fxl_rec OUT NOCOPY fxl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_fxl_rec := p_fxl_rec;
      x_fxl_rec.OBJECT_VERSION_NUMBER := 1;
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
    -- Set primary key value
    l_fxl_rec.LINE_EXTENSION_ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_fxl_rec,                        -- IN
      l_def_fxl_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_fxl_rec  := fill_who_columns(l_def_fxl_rec);
    l_fxl_rec  := l_def_fxl_rec;
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_fxl_rec,
      lx_fxl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR idx IN p_fxll_tbl.FIRST .. p_fxll_tbl.LAST
    LOOP
      l_fxll_tbl(idx).line_extension_id := lx_fxl_rec.line_extension_id;
      l_fxll_tbl(idx).CREATION_DATE := SYSDATE;
      l_fxll_tbl(idx).CREATED_BY := FND_GLOBAL.USER_ID;
      l_fxll_tbl(idx).LAST_UPDATE_DATE := l_fxll_tbl(idx).CREATION_DATE;
      l_fxll_tbl(idx).LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_fxll_tbl(idx).LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
     insert_row(
       p_init_msg_list,
       l_return_status,
       x_msg_count,
       x_msg_data,
       l_fxll_tbl(idx),
       lx_fxll_tbl(idx)
     );
    END LOOP;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Set OUT values
    x_fxl_rec       := lx_fxl_rec;
    x_fxll_tbl      := lx_fxll_tbl;
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
END OKL_FXL_PVT;

/
