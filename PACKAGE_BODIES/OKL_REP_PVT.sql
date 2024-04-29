--------------------------------------------------------
--  DDL for Package Body OKL_REP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REP_PVT" AS
/* $Header: OKLSREPB.pls 120.7 2007/12/31 11:04:24 dcshanmu noship $ */
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
    CURSOR c_pk_csr IS SELECT okl_reports_b_s.NEXTVAL FROM DUAL;
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
    DELETE FROM OKL_REPORTS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_REPORTS_B B
         WHERE B.REPORT_ID =T.REPORT_ID
        );

    UPDATE OKL_REPORTS_TL T SET(
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKL_REPORTS_TL B
                               WHERE B.REPORT_ID = T.REPORT_ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE ( T.REPORT_ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.REPORT_ID,
                  SUBT.LANGUAGE
                FROM OKL_REPORTS_TL SUBB, OKL_REPORTS_TL SUBT
               WHERE SUBB.REPORT_ID = SUBT.REPORT_ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
              ));

    INSERT INTO OKL_REPORTS_TL (
        REPORT_ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.REPORT_ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.NAME,
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_REPORTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_REPORTS_TL T
                     WHERE T.REPORT_ID = B.REPORT_ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );
  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_REPORTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_repv_rec                     IN repv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN repv_rec_type IS
    CURSOR okl_reports_v_pk_csr(p_report_id	okl_reports_b.report_id%type) IS
    SELECT
            REPORT_ID,
            NAME,
            CHART_OF_ACCOUNTS_ID,
            BOOK_CLASSIFICATION_CODE,
            LEDGER_ID,
            REPORT_CATEGORY_CODE,
            REPORT_TYPE_CODE,
            ACTIVITY_CODE,
            STATUS_CODE,
            DESCRIPTION,
            EFFECTIVE_FROM_DATE,
            EFFECTIVE_TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG
      FROM Okl_Reports_V
     WHERE     report_id	=	p_report_id;
     l_okl_reports_v_pk             okl_reports_v_pk_csr%ROWTYPE;
     l_repv_rec                     repv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_reports_v_pk_csr(p_repv_rec.report_id);
    FETCH okl_reports_v_pk_csr INTO
              l_repv_rec.report_id,
              l_repv_rec.name,
              l_repv_rec.chart_of_accounts_id,
              l_repv_rec.book_classification_code,
              l_repv_rec.ledger_id,
              l_repv_rec.report_category_code,
              l_repv_rec.report_type_code,
              l_repv_rec.activity_code,
              l_repv_rec.status_code,
              l_repv_rec.description,
              l_repv_rec.effective_from_date,
              l_repv_rec.effective_to_date,
              l_repv_rec.created_by,
              l_repv_rec.creation_date,
              l_repv_rec.last_updated_by,
              l_repv_rec.last_update_date,
              l_repv_rec.last_update_login,
              l_repv_rec.language,
              l_repv_rec.source_lang,
              l_repv_rec.sfwt_flag;
    x_no_data_found := okl_reports_v_pk_csr%NOTFOUND;
    CLOSE okl_reports_v_pk_csr;
    RETURN(l_repv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_repv_rec                     IN repv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN repv_rec_type IS
    l_repv_rec                     repv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_repv_rec := get_rec(p_repv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_repv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_repv_rec                     IN repv_rec_type
  ) RETURN repv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_repv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_REPORTS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rep_rec                      IN rep_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rep_rec_type IS
    CURSOR okl_reports_b_pk_csr (p_report_id IN NUMBER) IS
    SELECT
            REPORT_ID,
            NAME,
            CHART_OF_ACCOUNTS_ID,
            BOOK_CLASSIFICATION_CODE,
            LEDGER_ID,
            REPORT_CATEGORY_CODE,
            REPORT_TYPE_CODE,
            EFFECTIVE_FROM_DATE,
            ACTIVITY_CODE,
            STATUS_CODE,
            EFFECTIVE_TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Reports_B
     WHERE okl_reports_b.report_id = p_report_id;
    l_okl_reports_b_pk             okl_reports_b_pk_csr%ROWTYPE;
    l_rep_rec                      rep_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_reports_b_pk_csr (p_rep_rec.report_id);
    FETCH okl_reports_b_pk_csr INTO
              l_rep_rec.report_id,
              l_rep_rec.name,
              l_rep_rec.chart_of_accounts_id,
              l_rep_rec.book_classification_code,
              l_rep_rec.ledger_id,
              l_rep_rec.report_category_code,
              l_rep_rec.report_type_code,
              l_rep_rec.effective_from_date,
              l_rep_rec.activity_code,
              l_rep_rec.status_code,
              l_rep_rec.effective_to_date,
              l_rep_rec.created_by,
              l_rep_rec.creation_date,
              l_rep_rec.last_updated_by,
              l_rep_rec.last_update_date,
              l_rep_rec.last_update_login;
    x_no_data_found := okl_reports_b_pk_csr%NOTFOUND;
    CLOSE okl_reports_b_pk_csr;
    RETURN(l_rep_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_rep_rec                      IN rep_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN rep_rec_type IS
    l_rep_rec                      rep_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_rep_rec := get_rec(p_rep_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'REPORT_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_rep_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_rep_rec                      IN rep_rec_type
  ) RETURN rep_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rep_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_REPORTS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_reports_tl_rec           IN okl_reports_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_reports_tl_rec_type IS
    CURSOR okl_reports_tl_pk_csr (p_report_id IN NUMBER,
                                  p_language  IN VARCHAR2) IS
    SELECT
            REPORT_ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Reports_Tl
     WHERE okl_reports_tl.report_id = p_report_id
       AND okl_reports_tl.language = p_language;
    l_okl_reports_tl_pk            okl_reports_tl_pk_csr%ROWTYPE;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_reports_tl_pk_csr (p_okl_reports_tl_rec.report_id,
                                p_okl_reports_tl_rec.language);
    FETCH okl_reports_tl_pk_csr INTO
              l_okl_reports_tl_rec.report_id,
              l_okl_reports_tl_rec.language,
              l_okl_reports_tl_rec.source_lang,
              l_okl_reports_tl_rec.sfwt_flag,
              l_okl_reports_tl_rec.name,
              l_okl_reports_tl_rec.description,
              l_okl_reports_tl_rec.created_by,
              l_okl_reports_tl_rec.creation_date,
              l_okl_reports_tl_rec.last_updated_by,
              l_okl_reports_tl_rec.last_update_date,
              l_okl_reports_tl_rec.last_update_login;
    x_no_data_found := okl_reports_tl_pk_csr%NOTFOUND;
    CLOSE okl_reports_tl_pk_csr;
    RETURN(l_okl_reports_tl_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_reports_tl_rec           IN okl_reports_tl_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okl_reports_tl_rec_type IS
    l_okl_reports_tl_rec           okl_reports_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_okl_reports_tl_rec := get_rec(p_okl_reports_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'REPORT_ID');
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okl_reports_tl_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okl_reports_tl_rec           IN okl_reports_tl_rec_type
  ) RETURN okl_reports_tl_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_reports_tl_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_REPORTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_repv_rec   IN repv_rec_type
  ) RETURN repv_rec_type IS
    l_repv_rec                     repv_rec_type := p_repv_rec;
  BEGIN
    IF (l_repv_rec.report_id = OKL_API.G_MISS_NUM ) THEN
      l_repv_rec.report_id := NULL;
    END IF;
    IF (l_repv_rec.name = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.name := NULL;
    END IF;
    IF (l_repv_rec.chart_of_accounts_id = OKL_API.G_MISS_NUM ) THEN
      l_repv_rec.chart_of_accounts_id := NULL;
    END IF;
    IF (l_repv_rec.book_classification_code = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.book_classification_code := NULL;
    END IF;
    IF (l_repv_rec.ledger_id = OKL_API.G_MISS_NUM ) THEN
      l_repv_rec.ledger_id := NULL;
    END IF;
    IF (l_repv_rec.report_category_code = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.report_category_code := NULL;
    END IF;
    IF (l_repv_rec.report_type_code = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.report_type_code := NULL;
    END IF;
    IF (l_repv_rec.activity_code = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.activity_code := NULL;
    END IF;
    IF (l_repv_rec.status_code = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.status_code := NULL;
    END IF;
    IF (l_repv_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.description := NULL;
    END IF;
    IF (l_repv_rec.effective_from_date = OKL_API.G_MISS_DATE ) THEN
      l_repv_rec.effective_from_date := NULL;
    END IF;
    IF (l_repv_rec.effective_to_date = OKL_API.G_MISS_DATE ) THEN
      l_repv_rec.effective_to_date := NULL;
    END IF;
    IF (l_repv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_repv_rec.created_by := NULL;
    END IF;
    IF (l_repv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_repv_rec.creation_date := NULL;
    END IF;
    IF (l_repv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_repv_rec.last_updated_by := NULL;
    END IF;
    IF (l_repv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_repv_rec.last_update_date := NULL;
    END IF;
    IF (l_repv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_repv_rec.last_update_login := NULL;
    END IF;
    IF (l_repv_rec.language = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.language := NULL;
    END IF;
    IF (l_repv_rec.source_lang = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.source_lang := NULL;
    END IF;
    IF (l_repv_rec.sfwt_flag = OKL_API.G_MISS_CHAR ) THEN
      l_repv_rec.sfwt_flag := NULL;
    END IF;
    RETURN(l_repv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- Validate Record for:OKL_REPORTS_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_repv_rec IN repv_rec_type,
    p_db_repv_rec IN repv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_repv_rec IN repv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_repv_rec                  repv_rec_type := get_rec(p_repv_rec);
  BEGIN
    l_return_status := Validate_Record(p_repv_rec => p_repv_rec,
                                       p_db_repv_rec => l_db_repv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN repv_rec_type,
    p_to   IN OUT NOCOPY rep_rec_type
  ) IS
  BEGIN
    p_to.report_id := p_from.report_id;
    p_to.name := p_from.name;
    p_to.chart_of_accounts_id := p_from.chart_of_accounts_id;
    p_to.book_classification_code := p_from.book_classification_code;
    p_to.ledger_id := p_from.ledger_id;
    p_to.report_category_code := p_from.report_category_code;
    p_to.report_type_code := p_from.report_type_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.activity_code := p_from.activity_code;
    p_to.status_code := p_from.status_code;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN rep_rec_type,
    p_to   IN OUT NOCOPY repv_rec_type
  ) IS
  BEGIN
    p_to.report_id := p_from.report_id;
    p_to.name := p_from.name;
    p_to.chart_of_accounts_id := p_from.chart_of_accounts_id;
    p_to.book_classification_code := p_from.book_classification_code;
    p_to.ledger_id := p_from.ledger_id;
    p_to.report_category_code := p_from.report_category_code;
    p_to.report_type_code := p_from.report_type_code;
    p_to.activity_code := p_from.activity_code;
    p_to.status_code := p_from.status_code;
    p_to.effective_from_date := p_from.effective_from_date;
    p_to.effective_to_date := p_from.effective_to_date;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN repv_rec_type,
    p_to   IN OUT NOCOPY okl_reports_tl_rec_type
  ) IS
  BEGIN
    p_to.report_id := p_from.report_id;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN okl_reports_tl_rec_type,
    p_to   IN OUT NOCOPY repv_rec_type
  ) IS
  BEGIN
    p_to.report_id := p_from.report_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.language := p_from.language;
    p_to.source_lang := p_from.source_lang;
    p_to.sfwt_flag := p_from.sfwt_flag;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_attributes
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_attributes for:OKL_REPORTS_V --
  ------------------------------------
  FUNCTION validate_attributes(
    p_repv_rec	IN repv_rec_type
  ) RETURN VARCHAR2 IS

	l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	l_test_value	 NUMBER := 0;

    -- cursor to validate chart of accounts id
	CURSOR c_is_valid_coa_id(p_coa_id	 OKL_REPORTS_B.CHART_OF_ACCOUNTS_ID%TYPE) IS
	   SELECT 1
	   FROM FND_ID_FLEX_STRUCTURES
	   WHERE ID_FLEX_NUM = p_coa_id;

    -- cursor to validate ledger id
	CURSOR c_is_valid_ledger_id(p_ledger_id	OKL_REPORTS_B.LEDGER_ID%TYPE) IS
	   SELECT 1
	   FROM GL_LEDGERS
	   WHERE LEDGER_ID = p_ledger_id;

    -- cursor to validate uniqueness of name, book classification, chart of accounts id and ledger_id
	CURSOR c_is_combination_exists(
		p_report_name OKL_REPORTS_B.NAME%TYPE
		,p_coa_id	OKL_REPORTS_B.CHART_OF_ACCOUNTS_ID%TYPE
		,p_bcc_value	OKL_REPORTS_B.BOOK_CLASSIFICATION_CODE%TYPE
		,p_ledger_id	OKL_REPORTS_B.LEDGER_ID%TYPE
		,p_report_id	OKL_REPORTS_B.REPORT_ID%TYPE) IS
		SELECT 1
		FROM OKL_REPORTS_B
		WHERE NAME = p_report_name
		AND CHART_OF_ACCOUNTS_ID = p_coa_id
		AND BOOK_CLASSIFICATION_CODE = p_bcc_value
		AND LEDGER_ID = p_ledger_id
		AND REPORT_ID <> p_report_id;

    -- cursor to validate report category code
	CURSOR c_is_valid_rpt_categ_code(p_rpt_categ_code	OKL_REPORTS_B.REPORT_CATEGORY_CODE%TYPE) IS
	   SELECT 1
	   FROM FND_LOOKUPS
	   WHERE LOOKUP_TYPE = 'OKL_REPORT_CATEGORIES'
	   AND LOOKUP_CODE = p_rpt_categ_code;

    -- cursor to validate report type code
	CURSOR c_is_valid_rpt_type_code(p_rpt_type_code	OKL_REPORTS_B.REPORT_TYPE_CODE%TYPE) IS
	   SELECT 1
	   FROM FND_LOOKUPS
	   WHERE LOOKUP_TYPE = 'OKL_REPORT_TYPES'
	   AND LOOKUP_CODE = p_rpt_type_code;

    -- cursor to validate report status code
	CURSOR c_is_valid_rpt_status_code(p_rpt_status_code	OKL_REPORTS_B.STATUS_CODE%TYPE) IS
	   SELECT 1
	   FROM FND_LOOKUPS
	   WHERE LOOKUP_TYPE = 'OKL_RECON_REPORT_STATUSES'
	   AND LOOKUP_CODE = p_rpt_status_code;

  BEGIN

    -- validate chart of accounts id
    OPEN c_is_valid_coa_id(p_repv_rec.chart_of_accounts_id);

	FETCH c_is_valid_coa_id INTO l_test_value;

	IF (c_is_valid_coa_id%NOTFOUND) THEN
		OKL_API.set_message(p_app_name      => G_APP_NAME,
				  p_msg_name      => G_COL_ERROR,
				  p_token1        => G_COL_NAME_TOKEN,
				  p_token1_value  => 'chart_of_accounts_id',
				  p_token2        => G_PKG_NAME_TOKEN,
				  p_token2_value  => G_PKG_NAME);
		CLOSE c_is_valid_coa_id;
		RAISE OKL_API.G_EXCEPTION_ERROR;

	END IF;

    CLOSE c_is_valid_coa_id;

    -- validate ledger id
    IF (p_repv_rec.ledger_id IS NOT NULL OR p_repv_rec.ledger_id <> OKL_API.G_MISS_NUM) THEN
	    OPEN c_is_valid_ledger_id(p_repv_rec.ledger_id);

		FETCH c_is_valid_ledger_id INTO l_test_value;

		IF (c_is_valid_ledger_id%NOTFOUND) THEN
			OKL_API.set_message(p_app_name      => G_APP_NAME,
					  p_msg_name      => G_COL_ERROR,
					  p_token1        => G_COL_NAME_TOKEN,
					  p_token1_value  => 'ledger_id',
					  p_token2        => G_PKG_NAME_TOKEN,
					  p_token2_value  => G_PKG_NAME);
			CLOSE c_is_valid_ledger_id;
			RAISE OKL_API.G_EXCEPTION_ERROR;

		END IF;

	    CLOSE c_is_valid_ledger_id;
    END IF;

    -- validate uniqueness of name, book classification, chart of accounts id and ledger_id
    OPEN c_is_combination_exists(
		p_repv_rec.name
		,p_repv_rec.chart_of_accounts_id
		,p_repv_rec.book_classification_code
		,p_repv_rec.ledger_id
		,p_repv_rec.report_id);

	FETCH c_is_combination_exists INTO l_test_value;

	IF (c_is_combination_exists%FOUND) THEN
		OKL_API.set_message(p_app_name      => G_APP_NAME,
				  p_msg_name      => 'OKL_REP_COMB_EXISTS_MSG');
		CLOSE c_is_combination_exists;
		RAISE OKL_API.G_EXCEPTION_ERROR;
   	END IF;

    CLOSE c_is_combination_exists;

    -- validate report category code
    IF (p_repv_rec.report_category_code <> 'RECON') THEN
	    OPEN c_is_valid_rpt_categ_code(p_repv_rec.report_category_code);

		FETCH c_is_valid_rpt_categ_code INTO l_test_value;

		IF (c_is_valid_rpt_categ_code%NOTFOUND) THEN
			OKL_API.set_message(p_app_name      => G_APP_NAME,
					  p_msg_name      => G_COL_ERROR,
					  p_token1        => G_COL_NAME_TOKEN,
					  p_token1_value  => 'report_category_code',
					  p_token2        => G_PKG_NAME_TOKEN,
					  p_token2_value  => G_PKG_NAME);
			CLOSE c_is_valid_rpt_categ_code;
			RAISE OKL_API.G_EXCEPTION_ERROR;

		END IF;

	    CLOSE c_is_valid_rpt_categ_code;
    END IF;

    -- validate report type code
    OPEN c_is_valid_rpt_type_code(p_repv_rec.report_type_code);

	FETCH c_is_valid_rpt_type_code INTO l_test_value;

	IF (c_is_valid_rpt_type_code%NOTFOUND) THEN
		OKL_API.set_message(p_app_name      => G_APP_NAME,
				  p_msg_name      => G_COL_ERROR,
				  p_token1        => G_COL_NAME_TOKEN,
				  p_token1_value  => 'report_type_code',
				  p_token2        => G_PKG_NAME_TOKEN,
				  p_token2_value  => G_PKG_NAME);
		CLOSE c_is_valid_rpt_type_code;
		RAISE OKL_API.G_EXCEPTION_ERROR;
   	END IF;

    CLOSE c_is_valid_rpt_type_code;

    -- validate status code
    OPEN c_is_valid_rpt_status_code(p_repv_rec.status_code);

	FETCH c_is_valid_rpt_status_code INTO l_test_value;

	IF (c_is_valid_rpt_status_code%NOTFOUND) THEN
		OKL_API.set_message(p_app_name      => G_APP_NAME,
				  p_msg_name      => G_COL_ERROR,
				  p_token1        => G_COL_NAME_TOKEN,
				  p_token1_value  => 'status_code',
				  p_token2        => G_PKG_NAME_TOKEN,
				  p_token2_value  => G_PKG_NAME);
		CLOSE c_is_valid_rpt_status_code;
		RAISE OKL_API.G_EXCEPTION_ERROR;
   	END IF;

    CLOSE c_is_valid_rpt_status_code;

    RETURN l_return_status;

  END validate_attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKL_REPORTS_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_repv_rec                     repv_rec_type := p_repv_rec;
    l_rep_rec                      rep_rec_type;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_repv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_repv_rec);
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
  -----------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_REPORTS_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      i := p_repv_tbl.FIRST;
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
            p_repv_rec                     => p_repv_tbl(i));
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
        EXIT WHEN (i = p_repv_tbl.LAST);
        i := p_repv_tbl.NEXT(i);
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

  -----------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_REPORTS_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_repv_tbl                     => p_repv_tbl,
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
  ----------------------------------
  -- insert_row for:OKL_REPORTS_B --
  ----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_rec                      IN rep_rec_type,
    x_rep_rec                      OUT NOCOPY rep_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rep_rec                      rep_rec_type := p_rep_rec;
    l_def_rep_rec                  rep_rec_type;
    --------------------------------------
    -- Set_Attributes for:OKL_REPORTS_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_rep_rec IN rep_rec_type,
      x_rep_rec OUT NOCOPY rep_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rep_rec := p_rep_rec;
      x_rep_rec.report_id	:=	get_seq_id();
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
      l_rep_rec,                         -- IN
      l_def_rep_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_REPORTS_B(
      report_id,
      name,
      chart_of_accounts_id,
      book_classification_code,
      ledger_id,
      report_category_code,
      report_type_code,
      effective_from_date,
      activity_code,
      status_code,
      effective_to_date,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login)
    VALUES (
      l_def_rep_rec.report_id,
      l_def_rep_rec.name,
      l_def_rep_rec.chart_of_accounts_id,
      l_def_rep_rec.book_classification_code,
      l_def_rep_rec.ledger_id,
      l_def_rep_rec.report_category_code,
      l_def_rep_rec.report_type_code,
      l_def_rep_rec.effective_from_date,
      l_def_rep_rec.activity_code,
      l_def_rep_rec.status_code,
      l_def_rep_rec.effective_to_date,
      l_def_rep_rec.created_by,
      l_def_rep_rec.creation_date,
      l_def_rep_rec.last_updated_by,
      l_def_rep_rec.last_update_date,
      l_def_rep_rec.last_update_login);
    -- Set OUT values
    x_rep_rec := l_def_rep_rec;
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
  -----------------------------------
  -- insert_row for:OKL_REPORTS_TL --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_reports_tl_rec           IN okl_reports_tl_rec_type,
    x_okl_reports_tl_rec           OUT NOCOPY okl_reports_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type := p_okl_reports_tl_rec;
    l_def_okl_reports_tl_rec       okl_reports_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ---------------------------------------
    -- Set_Attributes for:OKL_REPORTS_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okl_reports_tl_rec IN okl_reports_tl_rec_type,
      x_okl_reports_tl_rec OUT NOCOPY okl_reports_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_reports_tl_rec := p_okl_reports_tl_rec;
      x_okl_reports_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_reports_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_reports_tl_rec,              -- IN
      l_okl_reports_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_reports_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_REPORTS_TL(
        report_id,
        language,
        source_lang,
        sfwt_flag,
        name,
        description,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okl_reports_tl_rec.report_id,
        l_okl_reports_tl_rec.language,
        l_okl_reports_tl_rec.source_lang,
        l_okl_reports_tl_rec.sfwt_flag,
        l_okl_reports_tl_rec.name,
        l_okl_reports_tl_rec.description,
        l_okl_reports_tl_rec.created_by,
        l_okl_reports_tl_rec.creation_date,
        l_okl_reports_tl_rec.last_updated_by,
        l_okl_reports_tl_rec.last_update_date,
        l_okl_reports_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_reports_tl_rec := l_okl_reports_tl_rec;
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
  -----------------------------------
  -- insert_row for :OKL_REPORTS_B --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type,
    x_repv_rec                     OUT NOCOPY repv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_repv_rec                     repv_rec_type := p_repv_rec;
    l_def_repv_rec                 repv_rec_type;
    l_rep_rec                      rep_rec_type;
    lx_rep_rec                     rep_rec_type;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type;
    lx_okl_reports_tl_rec          okl_reports_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_repv_rec IN repv_rec_type
    ) RETURN repv_rec_type IS
      l_repv_rec repv_rec_type := p_repv_rec;
    BEGIN
      l_repv_rec.CREATION_DATE := SYSDATE;
      l_repv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_repv_rec.LAST_UPDATE_DATE := l_repv_rec.CREATION_DATE;
      l_repv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_repv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_repv_rec);
    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKL_REPORTS_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_repv_rec IN repv_rec_type,
      x_repv_rec OUT NOCOPY repv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_repv_rec := p_repv_rec;
      x_repv_rec.SFWT_FLAG := 'N';
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

    l_repv_rec := null_out_defaults(p_repv_rec);

    -- Set primary key value
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_repv_rec,                        -- IN
      l_def_repv_rec);                   -- OUT
    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_repv_rec := fill_who_columns(l_def_repv_rec);

    --- Validate all non-missing attributes (Item Level Validation)
    IF (l_def_repv_rec.report_category_code IS NULL OR l_def_repv_rec.report_category_code = OKL_API.G_MISS_NUM) THEN
	l_def_repv_rec.report_category_code := 'RECON';
    END IF;

    l_return_status := Validate_Attributes(l_def_repv_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_repv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_repv_rec, l_rep_rec);

    migrate(l_def_repv_rec, l_okl_reports_tl_rec);

    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rep_rec,
      lx_rep_rec
    );


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_rep_rec, l_def_repv_rec);


    l_okl_reports_tl_rec.report_id	:=	l_def_repv_rec.report_id;

    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_reports_tl_rec,
      lx_okl_reports_tl_rec
    );


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_okl_reports_tl_rec, l_def_repv_rec);

    -- Set OUT values
    x_repv_rec := l_def_repv_rec;
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
  -- PL/SQL TBL insert_row for:REPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      i := p_repv_tbl.FIRST;
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
            p_repv_rec                     => p_repv_tbl(i),
            x_repv_rec                     => x_repv_tbl(i));
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
        EXIT WHEN (i = p_repv_tbl.LAST);
        i := p_repv_tbl.NEXT(i);
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
  -- PL/SQL TBL insert_row for:REPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_repv_tbl                     => p_repv_tbl,
        x_repv_tbl                     => x_repv_tbl,
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
  --------------------------------
  -- lock_row for:OKL_REPORTS_B --
  --------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_rec                      IN rep_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rep_rec IN rep_rec_type) IS
    SELECT *
      FROM OKL_REPORTS_B
     WHERE REPORT_ID = p_rep_rec.report_id
    FOR UPDATE NOWAIT;

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
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
      OPEN lock_csr(p_rep_rec);
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
    ELSE
      IF (l_lock_var.report_id <> p_rep_rec.report_id) THEN
        OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
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
  ---------------------------------
  -- lock_row for:OKL_REPORTS_TL --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_reports_tl_rec           IN okl_reports_tl_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_reports_tl_rec IN okl_reports_tl_rec_type) IS
    SELECT *
      FROM OKL_REPORTS_TL
     WHERE REPORT_ID = p_okl_reports_tl_rec.report_id
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
      OPEN lock_csr(p_okl_reports_tl_rec);
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
  ---------------------------------
  -- lock_row for: OKL_REPORTS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rep_rec                      rep_rec_type;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type;
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
    migrate(p_repv_rec, l_rep_rec);
    migrate(p_repv_rec, l_okl_reports_tl_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rep_rec
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
      l_okl_reports_tl_rec
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
  -- PL/SQL TBL lock_row for:REPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      i := p_repv_tbl.FIRST;
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
            p_repv_rec                     => p_repv_tbl(i));
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
        EXIT WHEN (i = p_repv_tbl.LAST);
        i := p_repv_tbl.NEXT(i);
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
  -- PL/SQL TBL lock_row for:REPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_repv_tbl                     => p_repv_tbl,
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
  ----------------------------------
  -- update_row for:OKL_REPORTS_B --
  ----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_rec                      IN rep_rec_type,
    x_rep_rec                      OUT NOCOPY rep_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rep_rec                      rep_rec_type := p_rep_rec;
    l_def_rep_rec                  rep_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rep_rec IN rep_rec_type,
      x_rep_rec OUT NOCOPY rep_rec_type
    ) RETURN VARCHAR2 IS
      l_rep_rec                      rep_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rep_rec := p_rep_rec;
      -- Get current database values
      l_rep_rec := get_rec(p_rep_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_rep_rec.report_id IS NULL OR x_rep_rec.report_id = OKL_API.G_MISS_NUM THEN
          x_rep_rec.report_id := l_rep_rec.report_id;
        END IF;
        IF x_rep_rec.name = OKL_API.G_MISS_CHAR THEN
          x_rep_rec.name := l_rep_rec.name;
        END IF;
        IF x_rep_rec.chart_of_accounts_id IS NULL OR x_rep_rec.chart_of_accounts_id = OKL_API.G_MISS_NUM THEN
          x_rep_rec.chart_of_accounts_id := l_rep_rec.chart_of_accounts_id;
        END IF;
        IF x_rep_rec.book_classification_code = OKL_API.G_MISS_CHAR THEN
          x_rep_rec.book_classification_code := l_rep_rec.book_classification_code;
        END IF;
        IF x_rep_rec.ledger_id = OKL_API.G_MISS_NUM THEN
          x_rep_rec.ledger_id := l_rep_rec.ledger_id;
        END IF;
        IF x_rep_rec.report_category_code IS NULL OR x_rep_rec.report_category_code = OKL_API.G_MISS_CHAR THEN
          x_rep_rec.report_category_code := l_rep_rec.report_category_code;
        END IF;
        IF x_rep_rec.report_type_code IS NULL OR x_rep_rec.report_type_code = OKL_API.G_MISS_CHAR THEN
          x_rep_rec.report_type_code := l_rep_rec.report_type_code;
        END IF;
        IF x_rep_rec.effective_from_date = OKL_API.G_MISS_DATE THEN
          x_rep_rec.effective_from_date := l_rep_rec.effective_from_date;
        END IF;
        IF x_rep_rec.activity_code = OKL_API.G_MISS_CHAR THEN
          x_rep_rec.activity_code := l_rep_rec.activity_code;
        END IF;
        IF x_rep_rec.status_code = OKL_API.G_MISS_CHAR THEN
          x_rep_rec.status_code := l_rep_rec.status_code;
        END IF;
        IF x_rep_rec.effective_to_date = OKL_API.G_MISS_DATE THEN
          x_rep_rec.effective_to_date := l_rep_rec.effective_to_date;
        END IF;
        IF x_rep_rec.created_by IS NULL OR x_rep_rec.created_by = OKL_API.G_MISS_NUM THEN
          x_rep_rec.created_by := l_rep_rec.created_by;
        END IF;
        IF x_rep_rec.creation_date IS NULL OR x_rep_rec.creation_date = OKL_API.G_MISS_DATE THEN
          x_rep_rec.creation_date := l_rep_rec.creation_date;
        END IF;
        IF x_rep_rec.last_updated_by IS NULL OR x_rep_rec.last_updated_by = OKL_API.G_MISS_NUM THEN
          x_rep_rec.last_updated_by := l_rep_rec.last_updated_by;
        END IF;
        IF x_rep_rec.last_update_date IS NULL OR x_rep_rec.last_update_date = OKL_API.G_MISS_DATE THEN
          x_rep_rec.last_update_date := l_rep_rec.last_update_date;
        END IF;
        IF x_rep_rec.last_update_login = OKL_API.G_MISS_NUM THEN
          x_rep_rec.last_update_login := l_rep_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_REPORTS_B --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_rep_rec IN rep_rec_type,
      x_rep_rec OUT NOCOPY rep_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rep_rec := p_rep_rec;
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
      p_rep_rec,                         -- IN
      l_rep_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rep_rec, l_def_rep_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_REPORTS_B
    SET NAME = l_def_rep_rec.name,
        CHART_OF_ACCOUNTS_ID = l_def_rep_rec.chart_of_accounts_id,
        BOOK_CLASSIFICATION_CODE = l_def_rep_rec.book_classification_code,
        LEDGER_ID = l_def_rep_rec.ledger_id,
        REPORT_CATEGORY_CODE = l_def_rep_rec.report_category_code,
        REPORT_TYPE_CODE = l_def_rep_rec.report_type_code,
        EFFECTIVE_FROM_DATE = l_def_rep_rec.effective_from_date,
        ACTIVITY_CODE = l_def_rep_rec.activity_code,
        STATUS_CODE = l_def_rep_rec.status_code,
        EFFECTIVE_TO_DATE = l_def_rep_rec.effective_to_date,
        CREATED_BY = l_def_rep_rec.created_by,
        CREATION_DATE = l_def_rep_rec.creation_date,
        LAST_UPDATED_BY = l_def_rep_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rep_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rep_rec.last_update_login
    WHERE REPORT_ID = l_def_rep_rec.report_id;

    x_rep_rec := l_rep_rec;
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
  -----------------------------------
  -- update_row for:OKL_REPORTS_TL --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_reports_tl_rec           IN okl_reports_tl_rec_type,
    x_okl_reports_tl_rec           OUT NOCOPY okl_reports_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type := p_okl_reports_tl_rec;
    l_def_okl_reports_tl_rec       okl_reports_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_reports_tl_rec IN okl_reports_tl_rec_type,
      x_okl_reports_tl_rec OUT NOCOPY okl_reports_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_reports_tl_rec           okl_reports_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_reports_tl_rec := p_okl_reports_tl_rec;
      -- Get current database values
      l_okl_reports_tl_rec := get_rec(p_okl_reports_tl_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_okl_reports_tl_rec.report_id IS NULL OR x_okl_reports_tl_rec.report_id = OKL_API.G_MISS_NUM THEN
          x_okl_reports_tl_rec.report_id := l_okl_reports_tl_rec.report_id;
        END IF;
        IF x_okl_reports_tl_rec.language IS NULL OR x_okl_reports_tl_rec.language = OKL_API.G_MISS_CHAR THEN
          x_okl_reports_tl_rec.language := l_okl_reports_tl_rec.language;
        END IF;
        IF x_okl_reports_tl_rec.source_lang IS NULL OR x_okl_reports_tl_rec.source_lang = OKL_API.G_MISS_CHAR THEN
          x_okl_reports_tl_rec.source_lang := l_okl_reports_tl_rec.source_lang;
        END IF;
        IF x_okl_reports_tl_rec.sfwt_flag IS NULL OR x_okl_reports_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR THEN
          x_okl_reports_tl_rec.sfwt_flag := l_okl_reports_tl_rec.sfwt_flag;
        END IF;
        IF x_okl_reports_tl_rec.name = OKL_API.G_MISS_CHAR THEN
          x_okl_reports_tl_rec.name := l_okl_reports_tl_rec.name;
        END IF;
        IF x_okl_reports_tl_rec.description = OKL_API.G_MISS_CHAR THEN
          x_okl_reports_tl_rec.description := l_okl_reports_tl_rec.description;
        END IF;
        IF x_okl_reports_tl_rec.created_by IS NULL OR x_okl_reports_tl_rec.created_by = OKL_API.G_MISS_NUM THEN
          x_okl_reports_tl_rec.created_by := l_okl_reports_tl_rec.created_by;
        END IF;
        IF x_okl_reports_tl_rec.creation_date IS NULL OR x_okl_reports_tl_rec.creation_date = OKL_API.G_MISS_DATE THEN
          x_okl_reports_tl_rec.creation_date := l_okl_reports_tl_rec.creation_date;
        END IF;
        IF x_okl_reports_tl_rec.last_updated_by IS NULL OR x_okl_reports_tl_rec.last_updated_by = OKL_API.G_MISS_NUM THEN
          x_okl_reports_tl_rec.last_updated_by := l_okl_reports_tl_rec.last_updated_by;
        END IF;
        IF x_okl_reports_tl_rec.last_update_date IS NULL OR x_okl_reports_tl_rec.last_update_date = OKL_API.G_MISS_DATE THEN
          x_okl_reports_tl_rec.last_update_date := l_okl_reports_tl_rec.last_update_date;
        END IF;
        IF x_okl_reports_tl_rec.last_update_login = OKL_API.G_MISS_NUM THEN
          x_okl_reports_tl_rec.last_update_login := l_okl_reports_tl_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_REPORTS_TL --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_okl_reports_tl_rec IN okl_reports_tl_rec_type,
      x_okl_reports_tl_rec OUT NOCOPY okl_reports_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_reports_tl_rec := p_okl_reports_tl_rec;
      x_okl_reports_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_reports_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_reports_tl_rec,              -- IN
      l_okl_reports_tl_rec);             -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_reports_tl_rec, l_def_okl_reports_tl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_REPORTS_TL
    SET NAME = l_def_okl_reports_tl_rec.name,
        DESCRIPTION = l_def_okl_reports_tl_rec.description,
        CREATED_BY = l_def_okl_reports_tl_rec.created_by,
        CREATION_DATE = l_def_okl_reports_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okl_reports_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okl_reports_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okl_reports_tl_rec.last_update_login
    WHERE REPORT_ID = l_def_okl_reports_tl_rec.report_id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE OKL_REPORTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE REPORT_ID = l_def_okl_reports_tl_rec.report_id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_reports_tl_rec := l_okl_reports_tl_rec;
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
  ----------------------------------
  -- update_row for:OKL_REPORTS_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type,
    x_repv_rec                     OUT NOCOPY repv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_repv_rec                     repv_rec_type := p_repv_rec;
    l_def_repv_rec                 repv_rec_type;
    l_db_repv_rec                  repv_rec_type;
    l_rep_rec                      rep_rec_type;
    lx_rep_rec                     rep_rec_type;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type;
    lx_okl_reports_tl_rec          okl_reports_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_repv_rec IN repv_rec_type
    ) RETURN repv_rec_type IS
      l_repv_rec repv_rec_type := p_repv_rec;
    BEGIN
      l_repv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_repv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_repv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_repv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_repv_rec IN repv_rec_type,
      x_repv_rec OUT NOCOPY repv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_repv_rec := p_repv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_repv_rec := get_rec(p_repv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF x_repv_rec.report_id IS NULL OR x_repv_rec.report_id = OKL_API.G_MISS_NUM THEN
          x_repv_rec.report_id := l_db_repv_rec.report_id;
        END IF;
        IF x_repv_rec.name = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.name := l_db_repv_rec.name;
        END IF;
        IF x_repv_rec.chart_of_accounts_id IS NULL OR x_repv_rec.chart_of_accounts_id = OKL_API.G_MISS_NUM THEN
          x_repv_rec.chart_of_accounts_id := l_db_repv_rec.chart_of_accounts_id;
        END IF;
        IF x_repv_rec.book_classification_code = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.book_classification_code := l_db_repv_rec.book_classification_code;
        END IF;
        IF x_repv_rec.ledger_id = OKL_API.G_MISS_NUM THEN
          x_repv_rec.ledger_id := l_db_repv_rec.ledger_id;
        END IF;
        IF x_repv_rec.report_category_code IS NULL OR x_repv_rec.report_category_code = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.report_category_code := l_db_repv_rec.report_category_code;
        END IF;
        IF x_repv_rec.report_type_code IS NULL OR x_repv_rec.report_type_code = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.report_type_code := l_db_repv_rec.report_type_code;
        END IF;
        IF x_repv_rec.activity_code = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.activity_code := l_db_repv_rec.activity_code;
        END IF;
        IF x_repv_rec.status_code = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.status_code := l_db_repv_rec.status_code;
        END IF;
        IF x_repv_rec.description = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.description := l_db_repv_rec.description;
        END IF;
        IF x_repv_rec.effective_from_date = OKL_API.G_MISS_DATE THEN
          x_repv_rec.effective_from_date := l_db_repv_rec.effective_from_date;
        END IF;
        IF x_repv_rec.effective_to_date = OKL_API.G_MISS_DATE THEN
          x_repv_rec.effective_to_date := l_db_repv_rec.effective_to_date;
        END IF;
        IF x_repv_rec.created_by IS NULL OR x_repv_rec.created_by = OKL_API.G_MISS_NUM THEN
          x_repv_rec.created_by := l_db_repv_rec.created_by;
        END IF;
        IF x_repv_rec.creation_date IS NULL OR x_repv_rec.creation_date = OKL_API.G_MISS_DATE THEN
          x_repv_rec.creation_date := l_db_repv_rec.creation_date;
        END IF;
        IF x_repv_rec.last_updated_by IS NULL OR x_repv_rec.last_updated_by = OKL_API.G_MISS_NUM THEN
          x_repv_rec.last_updated_by := l_db_repv_rec.last_updated_by;
        END IF;
        IF x_repv_rec.last_update_date IS NULL OR x_repv_rec.last_update_date = OKL_API.G_MISS_DATE THEN
          x_repv_rec.last_update_date := l_db_repv_rec.last_update_date;
        END IF;
        IF x_repv_rec.last_update_login = OKL_API.G_MISS_NUM THEN
          x_repv_rec.last_update_login := l_db_repv_rec.last_update_login;
        END IF;
        IF x_repv_rec.language IS NULL OR x_repv_rec.language = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.language := l_db_repv_rec.language;
        END IF;
        IF x_repv_rec.source_lang IS NULL OR x_repv_rec.source_lang = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.source_lang := l_db_repv_rec.source_lang;
        END IF;
        IF x_repv_rec.sfwt_flag IS NULL OR x_repv_rec.sfwt_flag = OKL_API.G_MISS_CHAR THEN
          x_repv_rec.sfwt_flag := l_db_repv_rec.sfwt_flag;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKL_REPORTS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_repv_rec IN repv_rec_type,
      x_repv_rec OUT NOCOPY repv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_repv_rec := p_repv_rec;
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
      p_repv_rec,                        -- IN
      x_repv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_repv_rec, l_def_repv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_repv_rec := null_out_defaults(l_def_repv_rec);
    l_def_repv_rec := fill_who_columns(l_def_repv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_repv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_repv_rec, l_db_repv_rec);
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
      p_repv_rec                     => p_repv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_repv_rec, l_rep_rec);
    migrate(l_def_repv_rec, l_okl_reports_tl_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rep_rec,
      lx_rep_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rep_rec, l_def_repv_rec);
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_reports_tl_rec,
      lx_okl_reports_tl_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_reports_tl_rec, l_def_repv_rec);
    x_repv_rec := l_def_repv_rec;
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
  -- PL/SQL TBL update_row for:repv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      i := p_repv_tbl.FIRST;
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
            p_repv_rec                     => p_repv_tbl(i),
            x_repv_rec                     => x_repv_tbl(i));
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
        EXIT WHEN (i = p_repv_tbl.LAST);
        i := p_repv_tbl.NEXT(i);
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
  -- PL/SQL TBL update_row for:REPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    x_repv_tbl                     OUT NOCOPY repv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_repv_tbl                     => p_repv_tbl,
        x_repv_tbl                     => x_repv_tbl,
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
  ----------------------------------
  -- delete_row for:OKL_REPORTS_B --
  ----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rep_rec                      IN rep_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_rep_rec                      rep_rec_type := p_rep_rec;
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

    DELETE FROM OKL_REPORTS_B
     WHERE REPORT_ID = p_rep_rec.report_id;

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
  -----------------------------------
  -- delete_row for:OKL_REPORTS_TL --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_reports_tl_rec           IN okl_reports_tl_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type := p_okl_reports_tl_rec;
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

    DELETE FROM OKL_REPORTS_TL
     WHERE REPORT_ID = p_okl_reports_tl_rec.report_id;

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
  ----------------------------------
  -- delete_row for:OKL_REPORTS_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_rec                     IN repv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_repv_rec                     repv_rec_type := p_repv_rec;
    l_okl_reports_tl_rec           okl_reports_tl_rec_type;
    l_rep_rec                      rep_rec_type;
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
    migrate(l_repv_rec, l_okl_reports_tl_rec);
    migrate(l_repv_rec, l_rep_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_reports_tl_rec
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
      l_rep_rec
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
  ---------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_REPORTS_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      i := p_repv_tbl.FIRST;
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
            p_repv_rec                     => p_repv_tbl(i));
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
        EXIT WHEN (i = p_repv_tbl.LAST);
        i := p_repv_tbl.NEXT(i);
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

  ---------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_REPORTS_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_repv_tbl                     IN repv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_repv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_repv_tbl                     => p_repv_tbl,
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

END OKL_REP_PVT;

/
