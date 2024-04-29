--------------------------------------------------------
--  DDL for Package Body OKL_SGT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SGT_PVT" AS
/* $Header: OKLSSGTB.pls 120.2 2005/10/30 03:47:09 appldev noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  g_mapped_value_token VARCHAR2(100);
  g_mapped_key_token VARCHAR2(100);

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
  -- FUNCTION get_rec for: OKL_SGN_TRANSLATIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sgnv_rec                     IN sgnv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sgnv_rec_type IS
    CURSOR sgnv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            JTOT_OBJECT1_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            SGN_CODE,
            VALUE,
            OBJECT_VERSION_NUMBER,
            DEFAULT_VALUE,
            ACTIVE_YN,
            START_DATE,
            END_DATE,
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
      FROM Okl_Sgn_Translations_V
     WHERE okl_sgn_translations_v.id = p_id;
    l_sgnv_pk                      sgnv_pk_csr%ROWTYPE;
    l_sgnv_rec                     sgnv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sgnv_pk_csr (p_sgnv_rec.id);
    FETCH sgnv_pk_csr INTO
              l_sgnv_rec.id,
              l_sgnv_rec.jtot_object1_code,
              l_sgnv_rec.object1_id1,
              l_sgnv_rec.object1_id2,
              l_sgnv_rec.sgn_code,
              l_sgnv_rec.value,
              l_sgnv_rec.object_version_number,
              l_sgnv_rec.default_value,
              l_sgnv_rec.active_yn,
              l_sgnv_rec.start_date,
              l_sgnv_rec.end_date,
              l_sgnv_rec.attribute1,
              l_sgnv_rec.attribute2,
              l_sgnv_rec.attribute3,
              l_sgnv_rec.attribute4,
              l_sgnv_rec.attribute5,
              l_sgnv_rec.attribute6,
              l_sgnv_rec.attribute7,
              l_sgnv_rec.attribute8,
              l_sgnv_rec.attribute9,
              l_sgnv_rec.attribute10,
              l_sgnv_rec.attribute11,
              l_sgnv_rec.attribute12,
              l_sgnv_rec.attribute13,
              l_sgnv_rec.attribute14,
              l_sgnv_rec.attribute15,
              l_sgnv_rec.created_by,
              l_sgnv_rec.creation_date,
              l_sgnv_rec.last_updated_by,
              l_sgnv_rec.last_update_date,
              l_sgnv_rec.last_update_login;
    x_no_data_found := sgnv_pk_csr%NOTFOUND;
    CLOSE sgnv_pk_csr;
    RETURN(l_sgnv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sgnv_rec                     IN sgnv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sgnv_rec_type IS
    l_sgnv_rec                     sgnv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_sgnv_rec := get_rec(p_sgnv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_sgnv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sgnv_rec                     IN sgnv_rec_type
  ) RETURN sgnv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sgnv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SGN_TRANSLATIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sgt_rec                      IN sgt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sgt_rec_type IS
    CURSOR sgt_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            JTOT_OBJECT1_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            SGN_CODE,
            VALUE,
            OBJECT_VERSION_NUMBER,
            DEFAULT_VALUE,
            ACTIVE_YN,
            START_DATE,
            END_DATE,
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
      FROM Okl_Sgn_Translations
     WHERE okl_sgn_translations.id = p_id;
    l_sgt_pk                       sgt_pk_csr%ROWTYPE;
    l_sgt_rec                      sgt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sgt_pk_csr (p_sgt_rec.id);
    FETCH sgt_pk_csr INTO
              l_sgt_rec.id,
              l_sgt_rec.jtot_object1_code,
              l_sgt_rec.object1_id1,
              l_sgt_rec.object1_id2,
              l_sgt_rec.sgn_code,
              l_sgt_rec.value,
              l_sgt_rec.object_version_number,
              l_sgt_rec.default_value,
              l_sgt_rec.active_yn,
              l_sgt_rec.start_date,
              l_sgt_rec.end_date,
              l_sgt_rec.attribute1,
              l_sgt_rec.attribute2,
              l_sgt_rec.attribute3,
              l_sgt_rec.attribute4,
              l_sgt_rec.attribute5,
              l_sgt_rec.attribute6,
              l_sgt_rec.attribute7,
              l_sgt_rec.attribute8,
              l_sgt_rec.attribute9,
              l_sgt_rec.attribute10,
              l_sgt_rec.attribute11,
              l_sgt_rec.attribute12,
              l_sgt_rec.attribute13,
              l_sgt_rec.attribute14,
              l_sgt_rec.attribute15,
              l_sgt_rec.created_by,
              l_sgt_rec.creation_date,
              l_sgt_rec.last_updated_by,
              l_sgt_rec.last_update_date,
              l_sgt_rec.last_update_login;
    x_no_data_found := sgt_pk_csr%NOTFOUND;
    CLOSE sgt_pk_csr;
    RETURN(l_sgt_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_sgt_rec                      IN sgt_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN sgt_rec_type IS
    l_sgt_rec                      sgt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_sgt_rec := get_rec(p_sgt_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_sgt_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_sgt_rec                      IN sgt_rec_type
  ) RETURN sgt_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sgt_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SGN_TRANSLATIONS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sgnv_rec   IN sgnv_rec_type
  ) RETURN sgnv_rec_type IS
    l_sgnv_rec                     sgnv_rec_type := p_sgnv_rec;
  BEGIN
    IF (l_sgnv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_sgnv_rec.id := NULL;
    END IF;
    IF (l_sgnv_rec.jtot_object1_code = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.jtot_object1_code := NULL;
    END IF;
    IF (l_sgnv_rec.object1_id1 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.object1_id1 := NULL;
    END IF;
    IF (l_sgnv_rec.object1_id2 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.object1_id2 := NULL;
    END IF;
    IF (l_sgnv_rec.sgn_code = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.sgn_code := NULL;
    END IF;
    IF (l_sgnv_rec.value = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.value := NULL;
    END IF;
    IF (l_sgnv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_sgnv_rec.object_version_number := NULL;
    END IF;
    IF (l_sgnv_rec.default_value = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.default_value := NULL;
    END IF;
    IF (l_sgnv_rec.active_yn = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.active_yn := NULL;
    END IF;
    IF (l_sgnv_rec.start_date = OKL_API.G_MISS_DATE ) THEN
      l_sgnv_rec.start_date := NULL;
    END IF;
    IF (l_sgnv_rec.end_date = OKL_API.G_MISS_DATE ) THEN
      l_sgnv_rec.end_date := NULL;
    END IF;
    IF (l_sgnv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute1 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute2 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute3 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute4 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute5 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute6 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute7 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute8 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute9 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute10 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute11 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute12 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute13 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute14 := NULL;
    END IF;
    IF (l_sgnv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_sgnv_rec.attribute15 := NULL;
    END IF;
    IF (l_sgnv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_sgnv_rec.created_by := NULL;
    END IF;
    IF (l_sgnv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_sgnv_rec.creation_date := NULL;
    END IF;
    IF (l_sgnv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_sgnv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sgnv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_sgnv_rec.last_update_date := NULL;
    END IF;
    IF (l_sgnv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_sgnv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sgnv_rec);
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
  ------------------------------------------------
  -- Validate_Attributes for: JTOT_OBJECT1_CODE --
  ------------------------------------------------
  PROCEDURE validate_jtot_object1_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_jtot_object1_code            IN VARCHAR2) IS

    l_dummy                 VARCHAR2(1) := '?';
    l_row_not_found         BOOLEAN := FALSE;

    -- Cursor For OKL_SIF_RETS - Foreign Key Constraint
    CURSOR jtot_object_csr (p_jtot_obj_code IN VARCHAR2) IS
    SELECT '1'
    FROM jtf_objects_b
    WHERE object_code = p_jtot_obj_code;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_jtot_object1_code = OKL_API.G_MISS_CHAR OR
        p_jtot_object1_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'jtot_object1_code');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

	OPEN jtot_object_csr (p_jtot_object1_code);
    FETCH jtot_object_csr INTO l_dummy;
    l_row_not_found := jtot_object_csr%NOTFOUND;
    CLOSE jtot_object_csr ;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'jtot_object1_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
  END validate_jtot_object1_code;
  ------------------------------------------
  -- Validate_Attributes for: OBJECT1_ID1 --
  ------------------------------------------
  PROCEDURE validate_object1_id1(
    x_return_status                OUT NOCOPY VARCHAR2,
	p_jtot_object1_code            IN VARCHAR2,
    p_object1_id1                  IN VARCHAR2) IS

	CURSOR jtot_object_csr (p_jtot_obj_code IN VARCHAR2) IS
    SELECT select_id
    FROM jtf_objects_b
    WHERE object_code = p_jtot_obj_code;

	CURSOR stream_type_csr (p_stream_type_id IN NUMBER) IS
    SELECT stream_type_class
    FROM okl_strm_type_b
    WHERE id = p_stream_type_id;

    l_row_not_found BOOLEAN := FALSE;
	l_select_id VARCHAR2(200);
	l_id VARCHAR2(200);
	l_cursor INTEGER;
	l_rows INTEGER;
	l_stream_type NUMBER;
	l_stream_type_class VARCHAR2(50);

	FUNCTION is_number(p_string IN VARCHAR2) RETURN BOOLEAN IS
	  l_number NUMBER;
	BEGIN
	  l_number := TO_NUMBER(p_string);
	  RETURN TRUE;
	EXCEPTION
	  WHEN OTHERS THEN
	    RETURN FALSE;
	END;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_object1_id1 = OKL_API.G_MISS_CHAR OR
        p_object1_id1 IS NULL)
    THEN
      OKL_API.SET_MESSAGE(p_app_name        => 'OKL',
                          p_msg_name        => 'OKL_LP_REQUIRED_VALUE',
                          p_token1          => 'COLUMN_PROMPT',
                          p_token1_value    => g_mapped_key_token);
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object1_id1');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
   IF p_jtot_object1_code = 'OKL_STRMTYP' THEN
     l_stream_type := to_number(p_object1_id1);
	 OPEN stream_type_csr (l_stream_type);
	 FETCH stream_type_csr INTO l_stream_type_class;
	 l_row_not_found := stream_type_csr%NOTFOUND;
     IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'object1_id1');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	 ELSE
	   IF l_stream_type_class <> 'SUBSIDY' THEN
       Okl_Api.SET_MESSAGE(p_app_name  =>  G_APP_NAME,
                    p_msg_name  =>  'OKL_ASSOC_STREAM_TYPE');
         x_return_status := OKC_API.G_RET_STS_ERROR;
	   ELSE
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
	   END IF;
	 END IF;
   ELSE
	OPEN jtot_object_csr (p_jtot_object1_code);
    FETCH jtot_object_csr INTO l_select_id;
    l_row_not_found := jtot_object_csr%NOTFOUND;
    CLOSE jtot_object_csr ;
    IF l_row_not_found THEN
      Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'jtot_object1_code');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSE
	  l_cursor := DBMS_SQL.OPEN_CURSOR;
	  IF (is_number(l_select_id)) THEN
  	    DBMS_SQL.PARSE(l_cursor, 'select '|| l_select_id ||' from '|| p_jtot_object1_code || ' where ' || l_select_id || ' = ' || to_number(p_object1_id1), DBMS_SQL.V7);
	  ELSE
 	    DBMS_SQL.PARSE(l_cursor, 'select '|| l_select_id ||' from '|| p_jtot_object1_code || ' where ' || l_select_id || ' = ''' || p_object1_id1 || '''', DBMS_SQL.V7);
      END IF;
	  DBMS_SQL.DEFINE_COLUMN_CHAR(l_cursor, 1, l_id, 200);
	  l_rows := DBMS_SQL.EXECUTE(l_cursor);
	  IF DBMS_SQL.FETCH_ROWS(l_cursor) = 0 then
	    Okc_Api.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'object1_id1');
        x_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
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
  END validate_object1_id1;
  ------------------------------------------
  -- Validate_Attributes for: OBJECT1_ID2 --
  ------------------------------------------
  PROCEDURE validate_object1_id2(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object1_id2                  IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
	/*
    IF (p_object1_id2 = OKL_API.G_MISS_CHAR OR
        p_object1_id2 IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object1_id2');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
	*/
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
  END validate_object1_id2;
  ---------------------------------------
  -- Validate_Attributes for: SGN_CODE --
  ---------------------------------------
  PROCEDURE validate_sgn_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sgn_code                     IN VARCHAR2) IS
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_sgn_code = OKL_API.G_MISS_CHAR OR
        p_sgn_code IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sgn_code');
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
  END validate_sgn_code;
  ------------------------------------
  -- Validate_Attributes for: VALUE --
  ------------------------------------
  PROCEDURE validate_value(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_value                        IN VARCHAR2) IS
	l_token1_value VARCHAR2(100);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_value = OKL_API.G_MISS_CHAR OR
        p_value IS NULL)
    THEN
      OKL_API.SET_MESSAGE(p_app_name        => 'OKL',
                          p_msg_name        => 'OKL_LP_REQUIRED_VALUE',
                          p_token1          => 'COLUMN_PROMPT',
                          p_token1_value    => g_mapped_value_token);
      --OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'value');
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
  END validate_value;
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
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKL_SGN_TRANSLATIONS_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sgnv_rec                     IN sgnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
	-- Set the global token    --
	-----------------------------
	IF (p_sgnv_rec.jtot_object1_code = 'FA_BOOK_CONTROLS') THEN
	  g_mapped_value_token := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                    p_attribute_code => 'OKL_DEPRECIATION');
	  g_mapped_key_token := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                  p_attribute_code => 'OKL_TAX_BOOK');
    ELSIF (p_sgnv_rec.jtot_object1_code = 'OKL_STRMTYP') THEN
	  g_mapped_value_token := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                    p_attribute_code => 'OKL_ASSOC_STREAM_TYPE');
	  g_mapped_key_token := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                  p_attribute_code => 'OKL_STREAM_TYPE');
	ELSE
	  g_mapped_value_token := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                    p_attribute_code => 'OKL_PRICING_ENGINE_VALUE');
	  g_mapped_key_token := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                  p_attribute_code => 'OKL_ORACLE_VALUE');
	END IF;
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***

    validate_id(x_return_status, p_sgnv_rec.id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- jtot_object1_code
    -- ***
    validate_jtot_object1_code(x_return_status, p_sgnv_rec.jtot_object1_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object1_id1
    -- ***
    validate_object1_id1(x_return_status, p_sgnv_rec.jtot_object1_code, p_sgnv_rec.object1_id1);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- ***
    -- object1_id2
    -- ***
    validate_object1_id2(x_return_status, p_sgnv_rec.object1_id2);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- ***
    -- sgn_code
    -- ***
    validate_sgn_code(x_return_status, p_sgnv_rec.sgn_code);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- ***
    -- value
    -- ***
    validate_value(x_return_status, p_sgnv_rec.value);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_sgnv_rec.object_version_number);
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
  -- Validate Record for:OKL_SGN_TRANSLATIONS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_sgnv_rec IN sgnv_rec_type,
    p_db_sgnv_rec IN sgnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_sgnv_rec IN sgnv_rec_type,
      p_db_sgnv_rec IN sgnv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR sgt_flv_fk_csr (p_lookup_type IN VARCHAR2) IS
      SELECT 'x'
        FROM Fnd_Lookup_Values
       WHERE fnd_lookup_values.lookup_type = p_lookup_type;
      l_sgt_flv_fk                   sgt_flv_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;

	  l_strmgen_lookup_type VARCHAR2(30) := 'OKL_STREAM_GENERATOR';

    BEGIN
      IF ((p_sgnv_rec.SGN_CODE IS NOT NULL)
       AND
          (p_sgnv_rec.SGN_CODE <> p_db_sgnv_rec.SGN_CODE))
      THEN
        OPEN sgt_flv_fk_csr (l_strmgen_lookup_type);
        FETCH sgt_flv_fk_csr INTO l_sgt_flv_fk;
        l_row_notfound := sgt_flv_fk_csr%NOTFOUND;
        CLOSE sgt_flv_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SGN_CODE');
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
    l_return_status := validate_foreign_keys(p_sgnv_rec, p_db_sgnv_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_sgnv_rec IN sgnv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_sgnv_rec                  sgnv_rec_type := get_rec(p_sgnv_rec);
  BEGIN
    l_return_status := Validate_Record(p_sgnv_rec => p_sgnv_rec,
                                       p_db_sgnv_rec => l_db_sgnv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN sgnv_rec_type,
    p_to   IN OUT NOCOPY sgt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.sgn_code := p_from.sgn_code;
    p_to.value := p_from.value;
    p_to.object_version_number := p_from.object_version_number;
    p_to.default_value := p_from.default_value;
    p_to.active_yn := p_from.active_yn;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
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
    p_from IN sgt_rec_type,
    p_to   IN OUT NOCOPY sgnv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.sgn_code := p_from.sgn_code;
    p_to.value := p_from.value;
    p_to.object_version_number := p_from.object_version_number;
    p_to.default_value := p_from.default_value;
    p_to.active_yn := p_from.active_yn;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
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
  -- validate_row for:OKL_SGN_TRANSLATIONS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN sgnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgnv_rec                     sgnv_rec_type := p_sgnv_rec;
    l_sgt_rec                      sgt_rec_type;
    l_sgt_rec                      sgt_rec_type;
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
    l_return_status := Validate_Attributes(l_sgnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sgnv_rec);
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
  -- PL/SQL TBL validate_row for:OKL_SGN_TRANSLATIONS_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;
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
            p_sgnv_rec                     => p_sgnv_tbl(i));
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
        EXIT WHEN (i = p_sgnv_tbl.LAST);
        i := p_sgnv_tbl.NEXT(i);
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
  -- PL/SQL TBL validate_row for:OKL_SGN_TRANSLATIONS_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sgnv_tbl                     => p_sgnv_tbl,
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
  -- insert_row for:OKL_SGN_TRANSLATIONS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgt_rec                      IN sgt_rec_type,
    x_sgt_rec                      OUT NOCOPY sgt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgt_rec                      sgt_rec_type := p_sgt_rec;
    l_def_sgt_rec                  sgt_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SGN_TRANSLATIONS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_sgt_rec IN sgt_rec_type,
      x_sgt_rec OUT NOCOPY sgt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sgt_rec := p_sgt_rec;
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
      p_sgt_rec,                         -- IN
      l_sgt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SGN_TRANSLATIONS(
      id,
      jtot_object1_code,
      object1_id1,
      object1_id2,
      sgn_code,
      value,
      object_version_number,
      default_value,
      active_yn,
      start_date,
      end_date,
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
      l_sgt_rec.id,
      l_sgt_rec.jtot_object1_code,
      l_sgt_rec.object1_id1,
      l_sgt_rec.object1_id2,
      l_sgt_rec.sgn_code,
      l_sgt_rec.value,
      l_sgt_rec.object_version_number,
      l_sgt_rec.default_value,
      l_sgt_rec.active_yn,
      l_sgt_rec.start_date,
      l_sgt_rec.end_date,
      l_sgt_rec.attribute1,
      l_sgt_rec.attribute2,
      l_sgt_rec.attribute3,
      l_sgt_rec.attribute4,
      l_sgt_rec.attribute5,
      l_sgt_rec.attribute6,
      l_sgt_rec.attribute7,
      l_sgt_rec.attribute8,
      l_sgt_rec.attribute9,
      l_sgt_rec.attribute10,
      l_sgt_rec.attribute11,
      l_sgt_rec.attribute12,
      l_sgt_rec.attribute13,
      l_sgt_rec.attribute14,
      l_sgt_rec.attribute15,
      l_sgt_rec.created_by,
      l_sgt_rec.creation_date,
      l_sgt_rec.last_updated_by,
      l_sgt_rec.last_update_date,
      l_sgt_rec.last_update_login);
    -- Set OUT values
    x_sgt_rec := l_sgt_rec;
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
  -- insert_row for :OKL_SGN_TRANSLATIONS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgnv_rec                     sgnv_rec_type := p_sgnv_rec;
    l_def_sgnv_rec                 sgnv_rec_type;
    l_sgt_rec                      sgt_rec_type;
    lx_sgt_rec                     sgt_rec_type;

    CURSOR object1_id1_csr (p_jtot_object1_code IN VARCHAR2,
	                        p_sgn_code          IN VARCHAR2,
							p_object1_id1       IN VARCHAR2) IS
    SELECT '1'
    FROM okl_sgn_translations_v
    WHERE jtot_object1_code = p_jtot_object1_code
	      AND sgn_code = p_sgn_code
		  AND object1_id1 = p_object1_id1;
/*
    CURSOR fa_book_controls_csr (p_jtot_object1_code IN VARCHAR2,
	                             p_sgn_code          IN VARCHAR2,
							     p_object1_id1       IN VARCHAR2,
							     p_value             IN VARCHAR2) IS
    SELECT '1'
    FROM okl_sgn_translations_v
    WHERE jtot_object1_code = p_jtot_object1_code
	      AND sgn_code = p_sgn_code
		  AND object1_id1 = p_object1_id1
		  AND value = p_value;
*/
    CURSOR fa_book_controls_csr (p_jtot_object1_code IN VARCHAR2,
	                             p_sgn_code          IN VARCHAR2,
							     p_object1_id1       IN VARCHAR2) IS
    SELECT '1'
    FROM okl_sgn_translations_v
    WHERE jtot_object1_code = p_jtot_object1_code
	      AND sgn_code = p_sgn_code
		  AND object1_id1 = p_object1_id1;

	l_dummy VARCHAR2(5);
	l_uv_name VARCHAR2(50);
	l_sql_stmnt VARCHAR2(500);
	l_row_found BOOLEAN := FALSE;
	l_token1_value VARCHAR2(100);
	l_token2_value VARCHAR2(100);
	l_token3_value VARCHAR2(100);
	l_token4_value VARCHAR2(100);
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sgnv_rec IN sgnv_rec_type
    ) RETURN sgnv_rec_type IS
      l_sgnv_rec sgnv_rec_type := p_sgnv_rec;
    BEGIN
      l_sgnv_rec.CREATION_DATE := SYSDATE;
      l_sgnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sgnv_rec.LAST_UPDATE_DATE := l_sgnv_rec.CREATION_DATE;
      l_sgnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sgnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sgnv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKL_SGN_TRANSLATIONS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sgnv_rec IN sgnv_rec_type,
      x_sgnv_rec OUT NOCOPY sgnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sgnv_rec := p_sgnv_rec;
      x_sgnv_rec.OBJECT_VERSION_NUMBER := 1;
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

	IF (p_sgnv_rec.jtot_object1_code = 'FA_BOOK_CONTROLS') THEN
	  --OPEN fa_book_controls_csr (p_sgnv_rec.jtot_object1_code, p_sgnv_rec.sgn_code, p_sgnv_rec.object1_id1, p_sgnv_rec.value);
	  OPEN fa_book_controls_csr (p_sgnv_rec.jtot_object1_code, p_sgnv_rec.sgn_code, p_sgnv_rec.object1_id1);
      FETCH fa_book_controls_csr INTO l_dummy;
      l_row_found := fa_book_controls_csr%FOUND;
      CLOSE fa_book_controls_csr;
	ELSE
	  OPEN object1_id1_csr (p_sgnv_rec.jtot_object1_code, p_sgnv_rec.sgn_code, p_sgnv_rec.object1_id1);
      FETCH object1_id1_csr INTO l_dummy;
      l_row_found := object1_id1_csr%FOUND;
      CLOSE object1_id1_csr;
	END IF;
    IF (l_row_found) THEN
   	  IF (p_sgnv_rec.jtot_object1_code = 'FA_BOOK_CONTROLS') THEN
        l_token3_value := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                p_attribute_code => 'OKL_TAX_BOOK');
        l_token4_value := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                p_attribute_code => 'OKL_DEPRECIATION');

        OKL_API.SET_MESSAGE(p_app_name        => 'OKL',
                            p_msg_name        => 'OKL_UNIQUE_BOOK_MAP_MSG',
                            p_token1          => 'TAX_BOOK',
                            p_token1_value    => p_sgnv_rec.object1_id1,
                            p_token2          => 'DEPRECIATION',
                            p_token2_value    => p_sgnv_rec.value,
                            p_token3          => 'TAX_BOOK_PROMPT',
                            p_token3_value    => l_token3_value,
							p_token4          => 'DEPRECIATION_PROMPT',
							p_token4_value    => l_token4_value);
	  ELSE
		IF (p_sgnv_rec.jtot_object1_code = 'FA_METHODS') THEN
		  l_uv_name := 'OKL_ST_DEPM_TRANSLATIONS_UV';
		ELSIF (p_sgnv_rec.jtot_object1_code = 'FA_CONVENTION_TYPES') THEN
		  l_uv_name := 'OKL_ST_PRORATE_TRANSLATIONS_UV';
		END IF;
        l_sql_stmnt := 'SELECT NAME FROM ' || l_uv_name || ' WHERE jtot_object1_code = '''||p_sgnv_rec.jtot_object1_code||''' AND sgn_code = '''||p_sgnv_rec.sgn_code||''' AND object1_id1 = '''||p_sgnv_rec.object1_id1||'''';
		EXECUTE IMMEDIATE l_sql_stmnt INTO l_token1_value;

        l_token2_value := Okl_Accounting_Util.Get_Message_Token(p_region_code    => 'OKL_LP_CODE_CONV_CRUPD',
                                                                p_attribute_code => 'OKL_ORACLE_VALUE');
        OKL_API.SET_MESSAGE(p_app_name        => 'OKL',
                            p_msg_name        => 'OKL_UNIQUE_CONVERSION_MSG',
                            p_token1          => 'ORACLE_VALUE',
                            p_token1_value    => l_token1_value,
                            p_token2          => 'ORACLEVALUE_PROMPT',  -- Bug Number: 3992148
                            p_token2_value    => l_token2_value);
	  END IF;
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_sgnv_rec := null_out_defaults(p_sgnv_rec);
    -- Set primary key value
    l_sgnv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_sgnv_rec,                        -- IN
      l_def_sgnv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sgnv_rec := fill_who_columns(l_def_sgnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sgnv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sgnv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sgnv_rec, l_sgt_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sgt_rec,
      lx_sgt_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sgt_rec, l_def_sgnv_rec);
    -- Set OUT values
    x_sgnv_rec := l_def_sgnv_rec;
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
  -- PL/SQL TBL insert_row for:SGNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;
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
            p_sgnv_rec                     => p_sgnv_tbl(i),
            x_sgnv_rec                     => x_sgnv_tbl(i));
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
        EXIT WHEN (i = p_sgnv_tbl.LAST);
        i := p_sgnv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:SGNV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sgnv_tbl                     => p_sgnv_tbl,
        x_sgnv_tbl                     => x_sgnv_tbl,
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
  -- lock_row for:OKL_SGN_TRANSLATIONS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgt_rec                      IN sgt_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sgt_rec IN sgt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SGN_TRANSLATIONS
     WHERE ID = p_sgt_rec.id
       AND OBJECT_VERSION_NUMBER = p_sgt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_sgt_rec IN sgt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SGN_TRANSLATIONS
     WHERE ID = p_sgt_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_SGN_TRANSLATIONS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_SGN_TRANSLATIONS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sgt_rec);
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
      OPEN lchk_csr(p_sgt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sgt_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sgt_rec.object_version_number THEN
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
  -- lock_row for: OKL_SGN_TRANSLATIONS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN sgnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgt_rec                      sgt_rec_type;
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
    migrate(p_sgnv_rec, l_sgt_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sgt_rec
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
  -- PL/SQL TBL lock_row for:SGNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;
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
            p_sgnv_rec                     => p_sgnv_tbl(i));
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
        EXIT WHEN (i = p_sgnv_tbl.LAST);
        i := p_sgnv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:SGNV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sgnv_tbl                     => p_sgnv_tbl,
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
  -- update_row for:OKL_SGN_TRANSLATIONS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgt_rec                      IN sgt_rec_type,
    x_sgt_rec                      OUT NOCOPY sgt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgt_rec                      sgt_rec_type := p_sgt_rec;
    l_def_sgt_rec                  sgt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sgt_rec IN sgt_rec_type,
      x_sgt_rec OUT NOCOPY sgt_rec_type
    ) RETURN VARCHAR2 IS
      l_sgt_rec                      sgt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sgt_rec := p_sgt_rec;
      -- Get current database values
      l_sgt_rec := get_rec(p_sgt_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_sgt_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_sgt_rec.id := l_sgt_rec.id;
        END IF;
        IF (x_sgt_rec.jtot_object1_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.jtot_object1_code := l_sgt_rec.jtot_object1_code;
        END IF;
        IF (x_sgt_rec.object1_id1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.object1_id1 := l_sgt_rec.object1_id1;
        END IF;
        IF (x_sgt_rec.object1_id2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.object1_id2 := l_sgt_rec.object1_id2;
        END IF;
        IF (x_sgt_rec.sgn_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.sgn_code := l_sgt_rec.sgn_code;
        END IF;
        IF (x_sgt_rec.value = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.value := l_sgt_rec.value;
        END IF;
        IF (x_sgt_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_sgt_rec.object_version_number := l_sgt_rec.object_version_number;
        END IF;
        IF (x_sgt_rec.default_value = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.default_value := l_sgt_rec.default_value;
        END IF;
        IF (x_sgt_rec.active_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.active_yn := l_sgt_rec.active_yn;
        END IF;
        IF (x_sgt_rec.start_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgt_rec.start_date := l_sgt_rec.start_date;
        END IF;
        IF (x_sgt_rec.end_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgt_rec.end_date := l_sgt_rec.end_date;
        END IF;
        IF (x_sgt_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute1 := l_sgt_rec.attribute1;
        END IF;
        IF (x_sgt_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute2 := l_sgt_rec.attribute2;
        END IF;
        IF (x_sgt_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute3 := l_sgt_rec.attribute3;
        END IF;
        IF (x_sgt_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute4 := l_sgt_rec.attribute4;
        END IF;
        IF (x_sgt_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute5 := l_sgt_rec.attribute5;
        END IF;
        IF (x_sgt_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute6 := l_sgt_rec.attribute6;
        END IF;
        IF (x_sgt_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute7 := l_sgt_rec.attribute7;
        END IF;
        IF (x_sgt_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute8 := l_sgt_rec.attribute8;
        END IF;
        IF (x_sgt_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute9 := l_sgt_rec.attribute9;
        END IF;
        IF (x_sgt_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute10 := l_sgt_rec.attribute10;
        END IF;
        IF (x_sgt_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute11 := l_sgt_rec.attribute11;
        END IF;
        IF (x_sgt_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute12 := l_sgt_rec.attribute12;
        END IF;
        IF (x_sgt_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute13 := l_sgt_rec.attribute13;
        END IF;
        IF (x_sgt_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute14 := l_sgt_rec.attribute14;
        END IF;
        IF (x_sgt_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgt_rec.attribute15 := l_sgt_rec.attribute15;
        END IF;
        IF (x_sgt_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_sgt_rec.created_by := l_sgt_rec.created_by;
        END IF;
        IF (x_sgt_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgt_rec.creation_date := l_sgt_rec.creation_date;
        END IF;
        IF (x_sgt_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_sgt_rec.last_updated_by := l_sgt_rec.last_updated_by;
        END IF;
        IF (x_sgt_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgt_rec.last_update_date := l_sgt_rec.last_update_date;
        END IF;
        IF (x_sgt_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_sgt_rec.last_update_login := l_sgt_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_SGN_TRANSLATIONS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_sgt_rec IN sgt_rec_type,
      x_sgt_rec OUT NOCOPY sgt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sgt_rec := p_sgt_rec;
      x_sgt_rec.OBJECT_VERSION_NUMBER := p_sgt_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_sgt_rec,                         -- IN
      l_sgt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sgt_rec, l_def_sgt_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE OKL_SGN_TRANSLATIONS
    SET JTOT_OBJECT1_CODE = l_def_sgt_rec.jtot_object1_code,
        OBJECT1_ID1 = l_def_sgt_rec.object1_id1,
        OBJECT1_ID2 = l_def_sgt_rec.object1_id2,
        SGN_CODE = l_def_sgt_rec.sgn_code,
        VALUE = l_def_sgt_rec.value,
        OBJECT_VERSION_NUMBER = l_def_sgt_rec.object_version_number,
        DEFAULT_VALUE = l_def_sgt_rec.default_value,
        ACTIVE_YN = l_def_sgt_rec.active_yn,
        START_DATE = l_def_sgt_rec.start_date,
        END_DATE = l_def_sgt_rec.end_date,
        ATTRIBUTE1 = l_def_sgt_rec.attribute1,
        ATTRIBUTE2 = l_def_sgt_rec.attribute2,
        ATTRIBUTE3 = l_def_sgt_rec.attribute3,
        ATTRIBUTE4 = l_def_sgt_rec.attribute4,
        ATTRIBUTE5 = l_def_sgt_rec.attribute5,
        ATTRIBUTE6 = l_def_sgt_rec.attribute6,
        ATTRIBUTE7 = l_def_sgt_rec.attribute7,
        ATTRIBUTE8 = l_def_sgt_rec.attribute8,
        ATTRIBUTE9 = l_def_sgt_rec.attribute9,
        ATTRIBUTE10 = l_def_sgt_rec.attribute10,
        ATTRIBUTE11 = l_def_sgt_rec.attribute11,
        ATTRIBUTE12 = l_def_sgt_rec.attribute12,
        ATTRIBUTE13 = l_def_sgt_rec.attribute13,
        ATTRIBUTE14 = l_def_sgt_rec.attribute14,
        ATTRIBUTE15 = l_def_sgt_rec.attribute15,
        CREATED_BY = l_def_sgt_rec.created_by,
        CREATION_DATE = l_def_sgt_rec.creation_date,
        LAST_UPDATED_BY = l_def_sgt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sgt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sgt_rec.last_update_login
    WHERE ID = l_def_sgt_rec.id;

    x_sgt_rec := l_sgt_rec;
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
  -- update_row for:OKL_SGN_TRANSLATIONS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN sgnv_rec_type,
    x_sgnv_rec                     OUT NOCOPY sgnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgnv_rec                     sgnv_rec_type := p_sgnv_rec;
    l_def_sgnv_rec                 sgnv_rec_type;
    l_db_sgnv_rec                  sgnv_rec_type;
    l_sgt_rec                      sgt_rec_type;
    lx_sgt_rec                     sgt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sgnv_rec IN sgnv_rec_type
    ) RETURN sgnv_rec_type IS
      l_sgnv_rec sgnv_rec_type := p_sgnv_rec;
    BEGIN
      l_sgnv_rec.CREATION_DATE := SYSDATE;
      l_sgnv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sgnv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sgnv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sgnv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sgnv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sgnv_rec IN sgnv_rec_type,
      x_sgnv_rec OUT NOCOPY sgnv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sgnv_rec := p_sgnv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_sgnv_rec := get_rec(p_sgnv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_sgnv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_sgnv_rec.id := l_db_sgnv_rec.id;
        END IF;
        IF (x_sgnv_rec.jtot_object1_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.jtot_object1_code := l_db_sgnv_rec.jtot_object1_code;
        END IF;
        IF (x_sgnv_rec.object1_id1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.object1_id1 := l_db_sgnv_rec.object1_id1;
        END IF;
        IF (x_sgnv_rec.object1_id2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.object1_id2 := l_db_sgnv_rec.object1_id2;
        END IF;
        IF (x_sgnv_rec.sgn_code = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.sgn_code := l_db_sgnv_rec.sgn_code;
        END IF;
        IF (x_sgnv_rec.value = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.value := l_db_sgnv_rec.value;
        END IF;
        IF (x_sgnv_rec.default_value = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.default_value := l_db_sgnv_rec.default_value;
        END IF;
        IF (x_sgnv_rec.active_yn = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.active_yn := l_db_sgnv_rec.active_yn;
        END IF;
        IF (x_sgnv_rec.start_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgnv_rec.start_date := l_db_sgnv_rec.start_date;
        END IF;
        IF (x_sgnv_rec.end_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgnv_rec.end_date := l_db_sgnv_rec.end_date;
        END IF;
        IF (x_sgnv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute1 := l_db_sgnv_rec.attribute1;
        END IF;
        IF (x_sgnv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute2 := l_db_sgnv_rec.attribute2;
        END IF;
        IF (x_sgnv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute3 := l_db_sgnv_rec.attribute3;
        END IF;
        IF (x_sgnv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute4 := l_db_sgnv_rec.attribute4;
        END IF;
        IF (x_sgnv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute5 := l_db_sgnv_rec.attribute5;
        END IF;
        IF (x_sgnv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute6 := l_db_sgnv_rec.attribute6;
        END IF;
        IF (x_sgnv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute7 := l_db_sgnv_rec.attribute7;
        END IF;
        IF (x_sgnv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute8 := l_db_sgnv_rec.attribute8;
        END IF;
        IF (x_sgnv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute9 := l_db_sgnv_rec.attribute9;
        END IF;
        IF (x_sgnv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute10 := l_db_sgnv_rec.attribute10;
        END IF;
        IF (x_sgnv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute11 := l_db_sgnv_rec.attribute11;
        END IF;
        IF (x_sgnv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute12 := l_db_sgnv_rec.attribute12;
        END IF;
        IF (x_sgnv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute13 := l_db_sgnv_rec.attribute13;
        END IF;
        IF (x_sgnv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute14 := l_db_sgnv_rec.attribute14;
        END IF;
        IF (x_sgnv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_sgnv_rec.attribute15 := l_db_sgnv_rec.attribute15;
        END IF;
        IF (x_sgnv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_sgnv_rec.created_by := l_db_sgnv_rec.created_by;
        END IF;
        IF (x_sgnv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgnv_rec.creation_date := l_db_sgnv_rec.creation_date;
        END IF;
        IF (x_sgnv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_sgnv_rec.last_updated_by := l_db_sgnv_rec.last_updated_by;
        END IF;
        IF (x_sgnv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_sgnv_rec.last_update_date := l_db_sgnv_rec.last_update_date;
        END IF;
        IF (x_sgnv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_sgnv_rec.last_update_login := l_db_sgnv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKL_SGN_TRANSLATIONS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sgnv_rec IN sgnv_rec_type,
      x_sgnv_rec OUT NOCOPY sgnv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sgnv_rec := p_sgnv_rec;
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
      p_sgnv_rec,                        -- IN
      x_sgnv_rec);                       -- OUT
    --- If any errors happen abort API



    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sgnv_rec, l_def_sgnv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sgnv_rec := fill_who_columns(l_def_sgnv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sgnv_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sgnv_rec, l_db_sgnv_rec);

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
      p_sgnv_rec                     => p_sgnv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_sgnv_rec, l_sgt_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sgt_rec,
      lx_sgt_rec
    );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sgt_rec, l_def_sgnv_rec);
    x_sgnv_rec := l_def_sgnv_rec;
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
  -- PL/SQL TBL update_row for:sgnv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;
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
            p_sgnv_rec                     => p_sgnv_tbl(i),
            x_sgnv_rec                     => x_sgnv_tbl(i));
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
        EXIT WHEN (i = p_sgnv_tbl.LAST);
        i := p_sgnv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:SGNV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type,
    x_sgnv_tbl                     OUT NOCOPY sgnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sgnv_tbl                     => p_sgnv_tbl,
        x_sgnv_tbl                     => x_sgnv_tbl,
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
  -- delete_row for:OKL_SGN_TRANSLATIONS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgt_rec                      IN sgt_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgt_rec                      sgt_rec_type := p_sgt_rec;
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

    DELETE FROM OKL_SGN_TRANSLATIONS
     WHERE ID = p_sgt_rec.id;

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
  -- delete_row for:OKL_SGN_TRANSLATIONS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_rec                     IN sgnv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_sgnv_rec                     sgnv_rec_type := p_sgnv_rec;
    l_sgt_rec                      sgt_rec_type;
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
    migrate(l_sgnv_rec, l_sgt_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_sgt_rec
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
  -- PL/SQL TBL delete_row for:OKL_SGN_TRANSLATIONS_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      i := p_sgnv_tbl.FIRST;
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
            p_sgnv_rec                     => p_sgnv_tbl(i));
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
        EXIT WHEN (i = p_sgnv_tbl.LAST);
        i := p_sgnv_tbl.NEXT(i);
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
  -- PL/SQL TBL delete_row for:OKL_SGN_TRANSLATIONS_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sgnv_tbl                     IN sgnv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sgnv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_sgnv_tbl                     => p_sgnv_tbl,
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

END OKL_SGT_PVT;

/
