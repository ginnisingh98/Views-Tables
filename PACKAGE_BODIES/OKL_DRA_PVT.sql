--------------------------------------------------------
--  DDL for Package Body OKL_DRA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DRA_PVT" AS
/* $Header: OKLSDRAB.pls 120.3 2007/05/03 18:22:29 cklee noship $ */
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------

  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY  OKL_API.ERROR_REC_TYPE,
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

--start:|           May 3, 2007 cklee -- fixed sequence issue                        |                                                                 |
--    CURSOR c_pk_csr IS SELECT okl_disb_rules_all_b_s.NEXTVAL FROM DUAL;
    CURSOR c_pk_csr IS SELECT okl_disb_rules_s.NEXTVAL FROM DUAL;
--end:|           May 3, 2007 cklee -- fixed sequence issue                        |                                                                 |

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

    DELETE FROM OKL_DISB_RULES_TL T

     WHERE NOT EXISTS (

        SELECT NULL

          FROM OKL_DISB_RULES_B B

         WHERE B.DISB_RULE_ID =T.DISB_RULE_ID

        );



    UPDATE OKL_DISB_RULES_TL T SET(

        DESCRIPTION) = (SELECT

                                  B.DESCRIPTION

                                FROM OKL_DISB_RULES_TL B

                               WHERE B.DISB_RULE_ID = T.DISB_RULE_ID

                                 AND B.LANGUAGE = T.SOURCE_LANG)

      WHERE ( T.DISB_RULE_ID,

              T.LANGUAGE)

          IN (SELECT

                  SUBT.DISB_RULE_ID,

                  SUBT.LANGUAGE

                FROM OKL_DISB_RULES_TL SUBB, OKL_DISB_RULES_TL SUBT

               WHERE SUBB.DISB_RULE_ID = SUBT.DISB_RULE_ID

                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG

                 AND (SUBB.DESCRIPTION <> SUBT.DESCRIPTION

                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)

              ));



    INSERT INTO OKL_DISB_RULES_TL (

        DISB_RULE_ID,

        LANGUAGE,

        SOURCE_LANG,

        SFWT_FLAG,

        DESCRIPTION,

        CREATED_BY,

        CREATION_DATE,

        LAST_UPDATED_BY,

        LAST_UPDATE_DATE,

        LAST_UPDATE_LOGIN)

      SELECT

            B.DISB_RULE_ID,

            L.LANGUAGE_CODE,

            B.SOURCE_LANG,

            B.SFWT_FLAG,

            B.DESCRIPTION,

            B.CREATED_BY,

            B.CREATION_DATE,

            B.LAST_UPDATED_BY,

            B.LAST_UPDATE_DATE,

            B.LAST_UPDATE_LOGIN

        FROM OKL_DISB_RULES_TL B, FND_LANGUAGES L

       WHERE L.INSTALLED_FLAG IN ('I', 'B')

         AND B.LANGUAGE = USERENV('LANG')

         AND NOT EXISTS (

                    SELECT NULL

                      FROM OKL_DISB_RULES_TL T

                     WHERE T.DISB_RULE_ID = B.DISB_RULE_ID

                       AND T.LANGUAGE = L.LANGUAGE_CODE

                    );

  END add_language;



  ---------------------------------------------------------------------------

  -- FUNCTION get_rec for: OKL_DISB_RULES_V

  ---------------------------------------------------------------------------

  FUNCTION get_rec (

    p_drav_rec                     IN drav_rec_type,

    x_no_data_found                OUT NOCOPY BOOLEAN

  ) RETURN drav_rec_type IS

    CURSOR okl_drav_pk_csr (p_disb_rule_id IN NUMBER) IS

    SELECT
            DISB_RULE_ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            RULE_NAME,
            ORG_ID,
            START_DATE,
            END_DATE,
            FEE_OPTION,
            FEE_BASIS,
            FEE_AMOUNT,
            FEE_PERCENT,
            CONSOLIDATE_BY_DUE_DATE,
            FREQUENCY,
            DAY_OF_MONTH,
            SCHEDULED_MONTH,
            CONSOLIDATE_STRM_TYPE,
            DESCRIPTION,
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
      FROM Okl_Disb_Rules_V
     WHERE okl_disb_rules_v.disb_rule_id = p_disb_rule_id;

    l_okl_drav_pk                  okl_drav_pk_csr%ROWTYPE;
    l_drav_rec                     drav_rec_type;

  BEGIN

    x_no_data_found := TRUE;

    -- Get current database values

    OPEN okl_drav_pk_csr (p_drav_rec.disb_rule_id);

    FETCH okl_drav_pk_csr INTO

              l_drav_rec.disb_rule_id,

              l_drav_rec.object_version_number,

              l_drav_rec.sfwt_flag,

              l_drav_rec.rule_name,

              l_drav_rec.org_id,

              l_drav_rec.start_date,

              l_drav_rec.end_date,

              l_drav_rec.fee_option,

              l_drav_rec.fee_basis,

              l_drav_rec.fee_amount,

              l_drav_rec.fee_percent,

              l_drav_rec.consolidate_by_due_date,

              l_drav_rec.frequency,

              l_drav_rec.day_of_month,

              l_drav_rec.scheduled_month,

              l_drav_rec.consolidate_strm_type,

              l_drav_rec.description,

              l_drav_rec.attribute_category,

              l_drav_rec.attribute1,

              l_drav_rec.attribute2,

              l_drav_rec.attribute3,

              l_drav_rec.attribute4,

              l_drav_rec.attribute5,

              l_drav_rec.attribute6,

              l_drav_rec.attribute7,

              l_drav_rec.attribute8,

              l_drav_rec.attribute9,

              l_drav_rec.attribute10,

              l_drav_rec.attribute11,

              l_drav_rec.attribute12,

              l_drav_rec.attribute13,

              l_drav_rec.attribute14,

              l_drav_rec.attribute15,

              l_drav_rec.created_by,

              l_drav_rec.creation_date,

              l_drav_rec.last_updated_by,

              l_drav_rec.last_update_date,

              l_drav_rec.last_update_login;

    x_no_data_found := okl_drav_pk_csr%NOTFOUND;

    CLOSE okl_drav_pk_csr;

    RETURN(l_drav_rec);

  END get_rec;



  ------------------------------------------------------------------

  -- This version of get_rec sets error messages if no data found --

  ------------------------------------------------------------------

  FUNCTION get_rec (

    p_drav_rec                     IN drav_rec_type,

    x_return_status                OUT NOCOPY VARCHAR2

  ) RETURN drav_rec_type IS

    l_drav_rec                     drav_rec_type;

    l_row_notfound                 BOOLEAN := TRUE;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_drav_rec := get_rec(p_drav_rec, l_row_notfound);

    IF (l_row_notfound) THEN

      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'DISB_RULE_ID');

      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    RETURN(l_drav_rec);

  END get_rec;

  -----------------------------------------------------------

  -- So we don't have to pass an "l_row_notfound" variable --

  -----------------------------------------------------------

  FUNCTION get_rec (

    p_drav_rec                     IN drav_rec_type

  ) RETURN drav_rec_type IS

    l_row_not_found                BOOLEAN := TRUE;

  BEGIN

    RETURN(get_rec(p_drav_rec, l_row_not_found));

  END get_rec;

  ---------------------------------------------------------------------------

  -- FUNCTION get_rec for: OKL_DISB_RULES_TL

  ---------------------------------------------------------------------------

  FUNCTION get_rec (

    p_okl_disb_rules_tl_rec        IN okl_disb_rules_tl_rec_type,

    x_no_data_found                OUT NOCOPY BOOLEAN

  ) RETURN okl_disb_rules_tl_rec_type IS

    CURSOR okl_drt_pk_csr (p_disb_rule_id IN NUMBER,

                           p_language     IN VARCHAR2) IS

    SELECT

            DISB_RULE_ID,

            LANGUAGE,

            SOURCE_LANG,

            SFWT_FLAG,

            DESCRIPTION,

            CREATED_BY,

            CREATION_DATE,

            LAST_UPDATED_BY,

            LAST_UPDATE_DATE,

            LAST_UPDATE_LOGIN

      FROM Okl_Disb_Rules_Tl

     WHERE okl_disb_rules_tl.disb_rule_id = p_disb_rule_id

       AND okl_disb_rules_tl.language = p_language;

    l_okl_drt_pk                   okl_drt_pk_csr%ROWTYPE;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;

  BEGIN

    x_no_data_found := TRUE;

    -- Get current database values

    OPEN okl_drt_pk_csr (p_okl_disb_rules_tl_rec.disb_rule_id,

                         p_okl_disb_rules_tl_rec.language);

    FETCH okl_drt_pk_csr INTO

              l_okl_disb_rules_tl_rec.disb_rule_id,

              l_okl_disb_rules_tl_rec.language,

              l_okl_disb_rules_tl_rec.source_lang,

              l_okl_disb_rules_tl_rec.sfwt_flag,

              l_okl_disb_rules_tl_rec.description,

              l_okl_disb_rules_tl_rec.created_by,

              l_okl_disb_rules_tl_rec.creation_date,

              l_okl_disb_rules_tl_rec.last_updated_by,

              l_okl_disb_rules_tl_rec.last_update_date,

              l_okl_disb_rules_tl_rec.last_update_login;

    x_no_data_found := okl_drt_pk_csr%NOTFOUND;

    CLOSE okl_drt_pk_csr;

    RETURN(l_okl_disb_rules_tl_rec);

  END get_rec;



  ------------------------------------------------------------------

  -- This version of get_rec sets error messages if no data found --

  ------------------------------------------------------------------

  FUNCTION get_rec (

    p_okl_disb_rules_tl_rec        IN okl_disb_rules_tl_rec_type,

    x_return_status                OUT NOCOPY VARCHAR2

  ) RETURN okl_disb_rules_tl_rec_type IS

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;

    l_row_notfound                 BOOLEAN := TRUE;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_okl_disb_rules_tl_rec := get_rec(p_okl_disb_rules_tl_rec, l_row_notfound);

    IF (l_row_notfound) THEN

      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'DISB_RULE_ID');

      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'LANGUAGE');

      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    RETURN(l_okl_disb_rules_tl_rec);

  END get_rec;

  -----------------------------------------------------------

  -- So we don't have to pass an "l_row_notfound" variable --

  -----------------------------------------------------------

  FUNCTION get_rec (

    p_okl_disb_rules_tl_rec        IN okl_disb_rules_tl_rec_type

  ) RETURN okl_disb_rules_tl_rec_type IS

    l_row_not_found                BOOLEAN := TRUE;

  BEGIN

    RETURN(get_rec(p_okl_disb_rules_tl_rec, l_row_not_found));

  END get_rec;

  ---------------------------------------------------------------------------

  -- FUNCTION get_rec for: OKL_DISB_RULES_B

  ---------------------------------------------------------------------------

  FUNCTION get_rec (

    p_dra_rec                      IN dra_rec_type,

    x_no_data_found                OUT NOCOPY BOOLEAN

  ) RETURN dra_rec_type IS

    CURSOR okl_dra_pk_csr (p_disb_rule_id IN NUMBER) IS

    SELECT

            DISB_RULE_ID,

            OBJECT_VERSION_NUMBER,

            RULE_NAME,

            ORG_ID,

            START_DATE,

            END_DATE,

            FEE_OPTION,

            FEE_BASIS,

            FEE_AMOUNT,

            FEE_PERCENT,

            CONSOLIDATE_BY_DUE_DATE,

            FREQUENCY,

            DAY_OF_MONTH,

            SCHEDULED_MONTH,

            CONSOLIDATE_STRM_TYPE,

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

      FROM Okl_Disb_Rules_B

     WHERE okl_disb_rules_b.disb_rule_id = p_disb_rule_id;

    l_okl_dra_pk                   okl_dra_pk_csr%ROWTYPE;

    l_dra_rec                      dra_rec_type;

  BEGIN

    x_no_data_found := TRUE;

    -- Get current database values

    OPEN okl_dra_pk_csr (p_dra_rec.disb_rule_id);

    FETCH okl_dra_pk_csr INTO

              l_dra_rec.disb_rule_id,

              l_dra_rec.object_version_number,

              l_dra_rec.rule_name,

              l_dra_rec.org_id,

              l_dra_rec.start_date,

              l_dra_rec.end_date,

              l_dra_rec.fee_option,

              l_dra_rec.fee_basis,

              l_dra_rec.fee_amount,

              l_dra_rec.fee_percent,

              l_dra_rec.consolidate_by_due_date,

              l_dra_rec.frequency,

              l_dra_rec.day_of_month,

              l_dra_rec.scheduled_month,

              l_dra_rec.consolidate_strm_type,

              l_dra_rec.attribute_category,

              l_dra_rec.attribute1,

              l_dra_rec.attribute2,

              l_dra_rec.attribute3,

              l_dra_rec.attribute4,

              l_dra_rec.attribute5,

              l_dra_rec.attribute6,

              l_dra_rec.attribute7,

              l_dra_rec.attribute8,

              l_dra_rec.attribute9,

              l_dra_rec.attribute10,

              l_dra_rec.attribute11,

              l_dra_rec.attribute12,

              l_dra_rec.attribute13,

              l_dra_rec.attribute14,

              l_dra_rec.attribute15,

              l_dra_rec.created_by,

              l_dra_rec.creation_date,

              l_dra_rec.last_updated_by,

              l_dra_rec.last_update_date,

              l_dra_rec.last_update_login;

    x_no_data_found := okl_dra_pk_csr%NOTFOUND;

    CLOSE okl_dra_pk_csr;

    RETURN(l_dra_rec);

  END get_rec;



  ------------------------------------------------------------------

  -- This version of get_rec sets error messages if no data found --

  ------------------------------------------------------------------

  FUNCTION get_rec (

    p_dra_rec                      IN dra_rec_type,

    x_return_status                OUT NOCOPY VARCHAR2

  ) RETURN dra_rec_type IS

    l_dra_rec                      dra_rec_type;

    l_row_notfound                 BOOLEAN := TRUE;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_dra_rec := get_rec(p_dra_rec, l_row_notfound);

    IF (l_row_notfound) THEN

      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'DISB_RULE_ID');

      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    RETURN(l_dra_rec);

  END get_rec;

  -----------------------------------------------------------

  -- So we don't have to pass an "l_row_notfound" variable --

  -----------------------------------------------------------

  FUNCTION get_rec (

    p_dra_rec                      IN dra_rec_type

  ) RETURN dra_rec_type IS

    l_row_not_found                BOOLEAN := TRUE;

  BEGIN

    RETURN(get_rec(p_dra_rec, l_row_not_found));

  END get_rec;

  ---------------------------------------------------------------------------

  -- FUNCTION null_out_defaults for: OKL_DISB_RULES_V

  ---------------------------------------------------------------------------

  FUNCTION null_out_defaults (

    p_drav_rec   IN drav_rec_type

  ) RETURN drav_rec_type IS

    l_drav_rec                     drav_rec_type := p_drav_rec;

  BEGIN

    IF (l_drav_rec.disb_rule_id = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.disb_rule_id := NULL;

    END IF;

    IF (l_drav_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.object_version_number := NULL;

    END IF;

    IF (l_drav_rec.sfwt_flag = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.sfwt_flag := NULL;

    END IF;

    IF (l_drav_rec.rule_name = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.rule_name := NULL;

    END IF;

    IF (l_drav_rec.org_id = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.org_id := NULL;

    END IF;

    IF (l_drav_rec.start_date = OKL_API.G_MISS_DATE ) THEN

      l_drav_rec.start_date := NULL;

    END IF;

    IF (l_drav_rec.end_date = OKL_API.G_MISS_DATE ) THEN

      l_drav_rec.end_date := NULL;

    END IF;

    IF (l_drav_rec.fee_option = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.fee_option := NULL;

    END IF;

    IF (l_drav_rec.fee_basis = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.fee_basis := NULL;

    END IF;

    IF (l_drav_rec.fee_amount = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.fee_amount := NULL;

    END IF;

    IF (l_drav_rec.fee_percent = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.fee_percent := NULL;

    END IF;

    IF (l_drav_rec.consolidate_by_due_date = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.consolidate_by_due_date := NULL;

    END IF;

    IF (l_drav_rec.frequency = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.frequency := NULL;

    END IF;

    IF (l_drav_rec.day_of_month = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.day_of_month := NULL;

    END IF;

    IF (l_drav_rec.scheduled_month = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.scheduled_month := NULL;

    END IF;

    IF (l_drav_rec.consolidate_strm_type = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.consolidate_strm_type := NULL;

    END IF;

    IF (l_drav_rec.description = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.description := NULL;

    END IF;

    IF (l_drav_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute_category := NULL;

    END IF;

    IF (l_drav_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute1 := NULL;

    END IF;

    IF (l_drav_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute2 := NULL;

    END IF;

    IF (l_drav_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute3 := NULL;

    END IF;

    IF (l_drav_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute4 := NULL;

    END IF;

    IF (l_drav_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute5 := NULL;

    END IF;

    IF (l_drav_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute6 := NULL;

    END IF;

    IF (l_drav_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute7 := NULL;

    END IF;

    IF (l_drav_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute8 := NULL;

    END IF;

    IF (l_drav_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute9 := NULL;

    END IF;

    IF (l_drav_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute10 := NULL;

    END IF;

    IF (l_drav_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute11 := NULL;

    END IF;

    IF (l_drav_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute12 := NULL;

    END IF;

    IF (l_drav_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute13 := NULL;

    END IF;

    IF (l_drav_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute14 := NULL;

    END IF;

    IF (l_drav_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN

      l_drav_rec.attribute15 := NULL;

    END IF;

    IF (l_drav_rec.created_by = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.created_by := NULL;

    END IF;

    IF (l_drav_rec.creation_date = OKL_API.G_MISS_DATE ) THEN

      l_drav_rec.creation_date := NULL;

    END IF;

    IF (l_drav_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.last_updated_by := NULL;

    END IF;

    IF (l_drav_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN

      l_drav_rec.last_update_date := NULL;

    END IF;

    IF (l_drav_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN

      l_drav_rec.last_update_login := NULL;

    END IF;

    RETURN(l_drav_rec);

  END null_out_defaults;

  -------------------------------------------

  -- Validate_Attributes for: DISB_RULE_ID --

  -------------------------------------------

  PROCEDURE validate_disb_rule_id(

    x_return_status                OUT NOCOPY VARCHAR2,

    p_disb_rule_id                 IN NUMBER) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_disb_rule_id IS NULL) THEN

      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'disb_rule_id');

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

  END validate_disb_rule_id;

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

  ----------------------------------------

  -- Validate_Attributes for: SFWT_FLAG --

  ----------------------------------------

  PROCEDURE validate_sfwt_flag(

    x_return_status                OUT NOCOPY VARCHAR2,

    p_sfwt_flag                    IN VARCHAR2) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_sfwt_flag IS NULL) THEN

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

  ----------------------------------------

  -- Validate_Attributes for: RULE_NAME --

  ----------------------------------------

  PROCEDURE validate_rule_name(

    x_return_status                OUT NOCOPY VARCHAR2,

    p_rule_name                    IN VARCHAR2) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_rule_name IS NULL) THEN

      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'rule_name');

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

  END validate_rule_name;

  -------------------------------------

  -- Validate_Attributes for: ORG_ID --

  -------------------------------------

  PROCEDURE validate_org_id(

    x_return_status                OUT NOCOPY VARCHAR2,

    p_org_id                       IN NUMBER) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_org_id IS NULL) THEN

      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'org_id');

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

  END validate_org_id;

  -----------------------------------------

  -- Validate_Attributes for: START_DATE --

  -----------------------------------------

  PROCEDURE validate_start_date(

    x_return_status                OUT NOCOPY VARCHAR2,

    p_start_date                   IN DATE) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_start_date IS NULL) THEN

      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'start_date');

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

  END validate_start_date;

  ---------------------------------------------------------------------------

  -- FUNCTION Validate_Attributes

  ---------------------------------------------------------------------------

  ----------------------------------------------

  -- Validate_Attributes for:OKL_DISB_RULES_V --

  ----------------------------------------------

  FUNCTION Validate_Attributes (

    p_drav_rec                     IN drav_rec_type

  ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -----------------------------

    -- Column Level Validation --

    -----------------------------

    -- ***

    -- disb_rule_id

    -- ***

    validate_disb_rule_id(x_return_status, p_drav_rec.disb_rule_id);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

      l_return_status := x_return_status;

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;



    -- ***

    -- object_version_number

    -- ***

    validate_object_version_number(x_return_status, p_drav_rec.object_version_number);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

      l_return_status := x_return_status;

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;



    -- ***

    -- sfwt_flag

    -- ***

   /* validate_sfwt_flag(x_return_status, p_drav_rec.sfwt_flag);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

      l_return_status := x_return_status;

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;*/



    -- ***

    -- rule_name

    -- ***

    validate_rule_name(x_return_status, p_drav_rec.rule_name);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

      l_return_status := x_return_status;

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;



    -- ***

    -- org_id

    -- ***

    validate_org_id(x_return_status, p_drav_rec.org_id);

    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN

      l_return_status := x_return_status;

      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;



    -- ***

    -- start_date

    -- ***

    validate_start_date(x_return_status, p_drav_rec.start_date);

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

  ------------------------------------------

  -- Validate Record for:OKL_DISB_RULES_V --

  ------------------------------------------

  FUNCTION Validate_Record (

    p_drav_rec IN drav_rec_type,

    p_db_drav_rec IN drav_rec_type

  ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    RETURN (l_return_status);

  END Validate_Record;

  FUNCTION Validate_Record (

    p_drav_rec IN drav_rec_type

  ) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_db_drav_rec                  drav_rec_type := get_rec(p_drav_rec);

  BEGIN

    l_return_status := Validate_Record(p_drav_rec => p_drav_rec,

                                       p_db_drav_rec => l_db_drav_rec);

    RETURN (l_return_status);

  END Validate_Record;



  ---------------------------------------------------------------------------

  -- PROCEDURE Migrate

  ---------------------------------------------------------------------------

  PROCEDURE migrate (

    p_from IN drav_rec_type,

    p_to   IN OUT NOCOPY okl_disb_rules_tl_rec_type

  ) IS

  BEGIN

    p_to.disb_rule_id := p_from.disb_rule_id;

    p_to.sfwt_flag := p_from.sfwt_flag;

    p_to.description := p_from.description;

    p_to.created_by := p_from.created_by;

    p_to.creation_date := p_from.creation_date;

    p_to.last_updated_by := p_from.last_updated_by;

    p_to.last_update_date := p_from.last_update_date;

    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  PROCEDURE migrate (

    p_from IN okl_disb_rules_tl_rec_type,

    p_to   IN OUT NOCOPY drav_rec_type

  ) IS

  BEGIN

    p_to.disb_rule_id := p_from.disb_rule_id;

    p_to.sfwt_flag := p_from.sfwt_flag;

    p_to.description := p_from.description;

    p_to.created_by := p_from.created_by;

    p_to.creation_date := p_from.creation_date;

    p_to.last_updated_by := p_from.last_updated_by;

    p_to.last_update_date := p_from.last_update_date;

    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  PROCEDURE migrate (

    p_from IN drav_rec_type,

    p_to   IN OUT NOCOPY dra_rec_type

  ) IS

  BEGIN

    p_to.disb_rule_id := p_from.disb_rule_id;

    --g_debug_proc('Migrate  disb_rule_id' || p_to.disb_rule_id);

    p_to.object_version_number := p_from.object_version_number;

    p_to.rule_name := p_from.rule_name;

    p_to.org_id := p_from.org_id;

    p_to.start_date := p_from.start_date;

    p_to.end_date := p_from.end_date;

    p_to.fee_option := p_from.fee_option;

    p_to.fee_basis := p_from.fee_basis;

    p_to.fee_amount := p_from.fee_amount;

    p_to.fee_percent := p_from.fee_percent;

    p_to.consolidate_by_due_date := p_from.consolidate_by_due_date;

    p_to.frequency := p_from.frequency;

    p_to.day_of_month := p_from.day_of_month;

    p_to.scheduled_month := p_from.scheduled_month;

    ----g_debug_proc('Migrate  p_from' || p_to.scheduled_month);
    ----g_debug_proc('Migrate  p_to' || p_to.scheduled_month);


    p_to.consolidate_strm_type := p_from.consolidate_strm_type;

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

    p_from IN dra_rec_type,

    p_to   IN OUT NOCOPY drav_rec_type

  ) IS

  BEGIN

    p_to.disb_rule_id := p_from.disb_rule_id;

    p_to.object_version_number := p_from.object_version_number;

    p_to.rule_name := p_from.rule_name;

    p_to.org_id := p_from.org_id;

    p_to.start_date := p_from.start_date;

    p_to.end_date := p_from.end_date;

    p_to.fee_option := p_from.fee_option;

    p_to.fee_basis := p_from.fee_basis;

    p_to.fee_amount := p_from.fee_amount;

    p_to.fee_percent := p_from.fee_percent;

    p_to.consolidate_by_due_date := p_from.consolidate_by_due_date;

    p_to.frequency := p_from.frequency;

    p_to.day_of_month := p_from.day_of_month;

    p_to.scheduled_month := p_from.scheduled_month;

    p_to.consolidate_strm_type := p_from.consolidate_strm_type;

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

  ---------------------------------------

  -- validate_row for:OKL_DISB_RULES_V --

  ---------------------------------------

  PROCEDURE validate_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_rec                     IN drav_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_drav_rec                     drav_rec_type := p_drav_rec;

    l_dra_rec                      dra_rec_type;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;

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

    l_return_status := Validate_Attributes(l_drav_rec);

    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_return_status := Validate_Record(l_drav_rec);

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

  --------------------------------------------------

  -- PL/SQL TBL validate_row for:OKL_DISB_RULES_V --

  --------------------------------------------------

  PROCEDURE validate_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type,

    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';

    i                              NUMBER := 0;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      i := p_drav_tbl.FIRST;

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

            p_drav_rec                     => p_drav_tbl(i));

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

        EXIT WHEN (i = p_drav_tbl.LAST);

        i := p_drav_tbl.NEXT(i);

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



  --------------------------------------------------

  -- PL/SQL TBL validate_row for:OKL_DISB_RULES_V --

  --------------------------------------------------

  PROCEDURE validate_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      validate_row (

        p_api_version                  => p_api_version,

        p_init_msg_list                => OKL_API.G_FALSE,

        x_return_status                => x_return_status,

        x_msg_count                    => x_msg_count,

        x_msg_data                     => x_msg_data,

        p_drav_tbl                     => p_drav_tbl,

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

  -------------------------------------

  -- insert_row for:OKL_DISB_RULES_B --

  -------------------------------------

  PROCEDURE insert_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dra_rec                      IN dra_rec_type,
    x_dra_rec                      OUT NOCOPY dra_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dra_rec                      dra_rec_type := p_dra_rec;
    l_def_dra_rec                  dra_rec_type;

    -----------------------------------------

    -- Set_Attributes for:OKL_DISB_RULES_B --

    -----------------------------------------

    FUNCTION Set_Attributes (
      p_dra_rec IN dra_rec_type,
      x_dra_rec OUT NOCOPY dra_rec_type

    ) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN
      x_dra_rec := p_dra_rec;
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
      l_dra_rec,                         -- IN
      l_def_dra_rec);                    -- OUT

    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_DISB_RULES_B(
      disb_rule_id,
      object_version_number,
      rule_name,
      org_id,

      start_date,

      end_date,

      fee_option,

      fee_basis,

      fee_amount,

      fee_percent,

      consolidate_by_due_date,

      frequency,

      day_of_month,

      scheduled_month,

      consolidate_strm_type,

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

      l_def_dra_rec.disb_rule_id,

      l_def_dra_rec.object_version_number,

      l_def_dra_rec.rule_name,

      l_def_dra_rec.org_id,

      l_def_dra_rec.start_date,

      l_def_dra_rec.end_date,

      l_def_dra_rec.fee_option,

      l_def_dra_rec.fee_basis,

      l_def_dra_rec.fee_amount,

      l_def_dra_rec.fee_percent,

      l_def_dra_rec.consolidate_by_due_date,

      l_def_dra_rec.frequency,

      l_def_dra_rec.day_of_month,

      l_def_dra_rec.scheduled_month,

      l_def_dra_rec.consolidate_strm_type,

      l_def_dra_rec.attribute_category,

      l_def_dra_rec.attribute1,

      l_def_dra_rec.attribute2,

      l_def_dra_rec.attribute3,

      l_def_dra_rec.attribute4,

      l_def_dra_rec.attribute5,

      l_def_dra_rec.attribute6,

      l_def_dra_rec.attribute7,

      l_def_dra_rec.attribute8,

      l_def_dra_rec.attribute9,

      l_def_dra_rec.attribute10,

      l_def_dra_rec.attribute11,

      l_def_dra_rec.attribute12,

      l_def_dra_rec.attribute13,

      l_def_dra_rec.attribute14,

      l_def_dra_rec.attribute15,

      l_def_dra_rec.created_by,

      l_def_dra_rec.creation_date,

      l_def_dra_rec.last_updated_by,

      l_def_dra_rec.last_update_date,

      l_def_dra_rec.last_update_login);

    -- Set OUT values

    x_dra_rec := l_dra_rec;

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

  --------------------------------------

  -- insert_row for:OKL_DISB_RULES_TL --

  --------------------------------------

  PROCEDURE insert_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_okl_disb_rules_tl_rec        IN okl_disb_rules_tl_rec_type,

    x_okl_disb_rules_tl_rec        OUT NOCOPY okl_disb_rules_tl_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type := p_okl_disb_rules_tl_rec;

    l_def_okl_disb_rules_tl_rec    okl_disb_rules_tl_rec_type;

    CURSOR get_languages IS

      SELECT *

        FROM FND_LANGUAGES

       WHERE INSTALLED_FLAG IN ('I', 'B');

    ------------------------------------------

    -- Set_Attributes for:OKL_DISB_RULES_TL --

    ------------------------------------------

    FUNCTION Set_Attributes (

      p_okl_disb_rules_tl_rec IN okl_disb_rules_tl_rec_type,

      x_okl_disb_rules_tl_rec OUT NOCOPY okl_disb_rules_tl_rec_type

    ) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_okl_disb_rules_tl_rec := p_okl_disb_rules_tl_rec;

      x_okl_disb_rules_tl_rec.LANGUAGE := USERENV('LANG');

      x_okl_disb_rules_tl_rec.SOURCE_LANG := USERENV('LANG');

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

      p_okl_disb_rules_tl_rec,           -- IN

      l_okl_disb_rules_tl_rec);          -- OUT

    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    FOR l_lang_rec IN get_languages LOOP

      l_okl_disb_rules_tl_rec.language := l_lang_rec.language_code;

      INSERT INTO OKL_DISB_RULES_TL(

        disb_rule_id,

        language,

        source_lang,

        sfwt_flag,

        description,

        created_by,

        creation_date,

        last_updated_by,

        last_update_date,

        last_update_login)

      VALUES (

        l_okl_disb_rules_tl_rec.disb_rule_id,

        l_okl_disb_rules_tl_rec.language,

        l_okl_disb_rules_tl_rec.source_lang,

        l_okl_disb_rules_tl_rec.sfwt_flag,

        l_okl_disb_rules_tl_rec.description,

        l_okl_disb_rules_tl_rec.created_by,

        l_okl_disb_rules_tl_rec.creation_date,

        l_okl_disb_rules_tl_rec.last_updated_by,

        l_okl_disb_rules_tl_rec.last_update_date,

        l_okl_disb_rules_tl_rec.last_update_login);

    END LOOP;

    -- Set OUT values

    x_okl_disb_rules_tl_rec := l_okl_disb_rules_tl_rec;

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

  --------------------------------------

  -- insert_row for :OKL_DISB_RULES_B --

  --------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_rec                     IN drav_rec_type,

    x_drav_rec                     OUT NOCOPY drav_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_drav_rec                     drav_rec_type := p_drav_rec;

    l_def_drav_rec                 drav_rec_type;

    l_dra_rec                      dra_rec_type;

    lx_dra_rec                     dra_rec_type;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;

    lx_okl_disb_rules_tl_rec       okl_disb_rules_tl_rec_type;

    -------------------------------

    -- FUNCTION fill_who_columns --

    -------------------------------

    FUNCTION fill_who_columns (

      p_drav_rec IN drav_rec_type

    ) RETURN drav_rec_type IS

      l_drav_rec drav_rec_type := p_drav_rec;

    BEGIN

      l_drav_rec.CREATION_DATE := SYSDATE;

      l_drav_rec.CREATED_BY := FND_GLOBAL.USER_ID;

      l_drav_rec.LAST_UPDATE_DATE := l_drav_rec.CREATION_DATE;

      l_drav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;

      l_drav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_drav_rec);

    END fill_who_columns;

    -----------------------------------------

    -- Set_Attributes for:OKL_DISB_RULES_B --

    -----------------------------------------

    FUNCTION Set_Attributes (

      p_drav_rec IN drav_rec_type,

      x_drav_rec OUT NOCOPY drav_rec_type

    ) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_drav_rec := p_drav_rec;

      x_drav_rec.OBJECT_VERSION_NUMBER := 1;

      x_drav_rec.SFWT_FLAG := 'N';

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

    l_drav_rec := null_out_defaults(p_drav_rec);

    -- Set primary key value

    l_drav_rec.DISB_RULE_ID := get_seq_id;

    -- Setting item attributes

    l_return_Status := Set_Attributes(

      l_drav_rec,                        -- IN

      l_def_drav_rec);                   -- OUT

    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_def_drav_rec := fill_who_columns(l_def_drav_rec);

    --- Validate all non-missing attributes (Item Level Validation)

    l_return_status := Validate_Attributes(l_def_drav_rec);

    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_return_status := Validate_Record(l_def_drav_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    -----------------------------------------

    -- Move VIEW record to "Child" records --

    -----------------------------------------

    migrate(l_def_drav_rec, l_dra_rec);

    migrate(l_def_drav_rec, l_okl_disb_rules_tl_rec);

    --g_debug_proc('DRA INSERT  l_def_drav_rec' || l_def_drav_rec.disb_rule_id);
    --g_debug_proc('DRA INSERT  l_dra_rec' || l_dra_rec.disb_rule_id);
    --g_debug_proc('DRA INSERT  l_okl_disb_rules_tl_rec' || l_okl_disb_rules_tl_rec.disb_rule_id);


    -----------------------------------------------

    -- Call the INSERT_ROW for each child record --

    -----------------------------------------------

    insert_row(

      p_init_msg_list,

      l_return_status,

      x_msg_count,

      x_msg_data,

      l_dra_rec,

      lx_dra_rec

    );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    migrate(lx_dra_rec, l_def_drav_rec);

    insert_row(

      p_init_msg_list,

      l_return_status,

      x_msg_count,

      x_msg_data,

      l_okl_disb_rules_tl_rec,

      lx_okl_disb_rules_tl_rec

    );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    migrate(lx_okl_disb_rules_tl_rec, l_def_drav_rec);

    -- Set OUT values

    x_drav_rec := l_def_drav_rec;

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

  -- PL/SQL TBL insert_row for:DRAV_TBL --

  ----------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type,

    x_drav_tbl                     OUT NOCOPY drav_tbl_type,

    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';

    i                              NUMBER := 0;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      i := p_drav_tbl.FIRST;

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

            p_drav_rec                     => p_drav_tbl(i),

            x_drav_rec                     => x_drav_tbl(i));

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

        EXIT WHEN (i = p_drav_tbl.LAST);

        i := p_drav_tbl.NEXT(i);

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

  -- PL/SQL TBL insert_row for:DRAV_TBL --

  ----------------------------------------

  PROCEDURE insert_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type,

    x_drav_tbl                     OUT NOCOPY drav_tbl_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      insert_row (

        p_api_version                  => p_api_version,

        p_init_msg_list                => OKL_API.G_FALSE,

        x_return_status                => x_return_status,

        x_msg_count                    => x_msg_count,

        x_msg_data                     => x_msg_data,

        p_drav_tbl                     => p_drav_tbl,

        x_drav_tbl                     => x_drav_tbl,

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

  -----------------------------------

  -- lock_row for:OKL_DISB_RULES_B --

  -----------------------------------

  PROCEDURE lock_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_dra_rec                      IN dra_rec_type) IS



    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (p_dra_rec IN dra_rec_type) IS

    SELECT OBJECT_VERSION_NUMBER

      FROM OKL_DISB_RULES_B

     WHERE DISB_RULE_ID = p_dra_rec.disb_rule_id

       AND OBJECT_VERSION_NUMBER = p_dra_rec.object_version_number

    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;



    CURSOR lchk_csr (p_dra_rec IN dra_rec_type) IS

    SELECT OBJECT_VERSION_NUMBER

      FROM OKL_DISB_RULES_B

     WHERE DISB_RULE_ID = p_dra_rec.disb_rule_id;

    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_object_version_number        OKL_DISB_RULES_B.OBJECT_VERSION_NUMBER%TYPE;

    lc_object_version_number       OKL_DISB_RULES_B.OBJECT_VERSION_NUMBER%TYPE;

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

      OPEN lock_csr(p_dra_rec);

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

      OPEN lchk_csr(p_dra_rec);

      FETCH lchk_csr INTO lc_object_version_number;

      lc_row_notfound := lchk_csr%NOTFOUND;

      CLOSE lchk_csr;

    END IF;

    IF (lc_row_notfound) THEN

      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);

      RAISE OKL_API.G_EXCEPTION_ERROR;

    ELSIF lc_object_version_number > p_dra_rec.object_version_number THEN

      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);

      RAISE OKL_API.G_EXCEPTION_ERROR;

    ELSIF lc_object_version_number <> p_dra_rec.object_version_number THEN

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

  ------------------------------------

  -- lock_row for:OKL_DISB_RULES_TL --

  ------------------------------------

  PROCEDURE lock_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_okl_disb_rules_tl_rec        IN okl_disb_rules_tl_rec_type) IS



    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (p_okl_disb_rules_tl_rec IN okl_disb_rules_tl_rec_type) IS

    SELECT *

      FROM OKL_DISB_RULES_TL

     WHERE DISB_RULE_ID = p_okl_disb_rules_tl_rec.disb_rule_id

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

      OPEN lock_csr(p_okl_disb_rules_tl_rec);

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

  ------------------------------------

  -- lock_row for: OKL_DISB_RULES_V --

  ------------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_rec                     IN drav_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;

    l_dra_rec                      dra_rec_type;

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

    migrate(p_drav_rec, l_okl_disb_rules_tl_rec);

    migrate(p_drav_rec, l_dra_rec);

    ---------------------------------------------

    -- Call the LOCK_ROW for each child record --

    ---------------------------------------------

    lock_row(

      p_init_msg_list,

      l_return_status,

      x_msg_count,

      x_msg_data,

      l_okl_disb_rules_tl_rec

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

      l_dra_rec

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

  -- PL/SQL TBL lock_row for:DRAV_TBL --

  --------------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type,

    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';

    i                              NUMBER := 0;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has recrods in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      i := p_drav_tbl.FIRST;

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

            p_drav_rec                     => p_drav_tbl(i));

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

        EXIT WHEN (i = p_drav_tbl.LAST);

        i := p_drav_tbl.NEXT(i);

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

  -- PL/SQL TBL lock_row for:DRAV_TBL --

  --------------------------------------

  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has recrods in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      lock_row(

        p_api_version                  => p_api_version,

        p_init_msg_list                => OKL_API.G_FALSE,

        x_return_status                => x_return_status,

        x_msg_count                    => x_msg_count,

        x_msg_data                     => x_msg_data,

        p_drav_tbl                     => p_drav_tbl,

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

  -------------------------------------

  -- update_row for:OKL_DISB_RULES_B --

  -------------------------------------

  PROCEDURE update_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dra_rec                      IN dra_rec_type,
    x_dra_rec                      OUT NOCOPY dra_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dra_rec                      dra_rec_type := p_dra_rec;
    l_def_dra_rec                  dra_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;

    ----------------------------------

    -- FUNCTION populate_new_record --

    ----------------------------------

    FUNCTION populate_new_record (

      p_dra_rec IN dra_rec_type,

      x_dra_rec OUT NOCOPY dra_rec_type

    ) RETURN VARCHAR2 IS

      l_dra_rec                      dra_rec_type;

      l_row_notfound                 BOOLEAN := TRUE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_dra_rec := p_dra_rec;

      -- Get current database values

      l_dra_rec := get_rec(p_dra_rec, l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        IF x_dra_rec.disb_rule_id IS NULL THEN

          x_dra_rec.disb_rule_id := l_dra_rec.disb_rule_id;

        END IF;

        IF x_dra_rec.object_version_number IS NULL THEN

          x_dra_rec.object_version_number := l_dra_rec.object_version_number;

        END IF;

        IF x_dra_rec.rule_name IS NULL THEN

          x_dra_rec.rule_name := l_dra_rec.rule_name;

        END IF;

        IF x_dra_rec.org_id IS NULL THEN

          x_dra_rec.org_id := l_dra_rec.org_id;

        END IF;

        IF x_dra_rec.start_date IS NULL THEN

          x_dra_rec.start_date := l_dra_rec.start_date;

        END IF;

        IF x_dra_rec.end_date IS NULL THEN

          x_dra_rec.end_date := l_dra_rec.end_date;

        END IF;

        IF x_dra_rec.fee_option IS NULL THEN

          x_dra_rec.fee_option := l_dra_rec.fee_option;

        END IF;

        IF x_dra_rec.fee_basis IS NULL THEN

          x_dra_rec.fee_basis := l_dra_rec.fee_basis;

        END IF;

        IF x_dra_rec.fee_amount IS NULL THEN

          x_dra_rec.fee_amount := l_dra_rec.fee_amount;

        END IF;

        IF x_dra_rec.fee_percent IS NULL THEN

          x_dra_rec.fee_percent := l_dra_rec.fee_percent;

        END IF;

        IF x_dra_rec.consolidate_by_due_date IS NULL THEN

          x_dra_rec.consolidate_by_due_date := l_dra_rec.consolidate_by_due_date;

        END IF;

        IF x_dra_rec.frequency IS NULL THEN

          x_dra_rec.frequency := l_dra_rec.frequency;

        END IF;

        IF x_dra_rec.day_of_month IS NULL THEN

          x_dra_rec.day_of_month := l_dra_rec.day_of_month;

        END IF;

        IF x_dra_rec.scheduled_month IS NULL THEN

          x_dra_rec.scheduled_month := l_dra_rec.scheduled_month;

        END IF;

        IF x_dra_rec.consolidate_strm_type IS NULL THEN

          x_dra_rec.consolidate_strm_type := l_dra_rec.consolidate_strm_type;

        END IF;

        IF x_dra_rec.attribute_category IS NULL THEN

          x_dra_rec.attribute_category := l_dra_rec.attribute_category;

        END IF;

        IF x_dra_rec.attribute1 IS NULL THEN

          x_dra_rec.attribute1 := l_dra_rec.attribute1;

        END IF;

        IF x_dra_rec.attribute2 IS NULL THEN

          x_dra_rec.attribute2 := l_dra_rec.attribute2;

        END IF;

        IF x_dra_rec.attribute3 IS NULL THEN

          x_dra_rec.attribute3 := l_dra_rec.attribute3;

        END IF;

        IF x_dra_rec.attribute4 IS NULL THEN

          x_dra_rec.attribute4 := l_dra_rec.attribute4;

        END IF;

        IF x_dra_rec.attribute5 IS NULL THEN

          x_dra_rec.attribute5 := l_dra_rec.attribute5;

        END IF;

        IF x_dra_rec.attribute6 IS NULL THEN

          x_dra_rec.attribute6 := l_dra_rec.attribute6;

        END IF;

        IF x_dra_rec.attribute7 IS NULL THEN

          x_dra_rec.attribute7 := l_dra_rec.attribute7;

        END IF;

        IF x_dra_rec.attribute8 IS NULL THEN

          x_dra_rec.attribute8 := l_dra_rec.attribute8;

        END IF;

        IF x_dra_rec.attribute9 IS NULL THEN

          x_dra_rec.attribute9 := l_dra_rec.attribute9;

        END IF;

        IF x_dra_rec.attribute10 IS NULL THEN

          x_dra_rec.attribute10 := l_dra_rec.attribute10;

        END IF;

        IF x_dra_rec.attribute11 IS NULL THEN

          x_dra_rec.attribute11 := l_dra_rec.attribute11;

        END IF;

        IF x_dra_rec.attribute12 IS NULL THEN

          x_dra_rec.attribute12 := l_dra_rec.attribute12;

        END IF;

        IF x_dra_rec.attribute13 IS NULL THEN

          x_dra_rec.attribute13 := l_dra_rec.attribute13;

        END IF;

        IF x_dra_rec.attribute14 IS NULL THEN

          x_dra_rec.attribute14 := l_dra_rec.attribute14;

        END IF;

        IF x_dra_rec.attribute15 IS NULL THEN

          x_dra_rec.attribute15 := l_dra_rec.attribute15;

        END IF;

        IF x_dra_rec.created_by IS NULL THEN

          x_dra_rec.created_by := l_dra_rec.created_by;

        END IF;

        IF x_dra_rec.creation_date IS NULL THEN

          x_dra_rec.creation_date := l_dra_rec.creation_date;

        END IF;

        IF x_dra_rec.last_updated_by IS NULL THEN

          x_dra_rec.last_updated_by := l_dra_rec.last_updated_by;

        END IF;

        IF x_dra_rec.last_update_date IS NULL THEN

          x_dra_rec.last_update_date := l_dra_rec.last_update_date;

        END IF;

        IF x_dra_rec.last_update_login IS NULL THEN

          x_dra_rec.last_update_login := l_dra_rec.last_update_login;

        END IF;

      END IF;

      RETURN(l_return_status);

    END populate_new_record;

    -----------------------------------------

    -- Set_Attributes for:OKL_DISB_RULES_B --

    -----------------------------------------

    FUNCTION Set_Attributes (

      p_dra_rec IN dra_rec_type,

      x_dra_rec OUT NOCOPY dra_rec_type

    ) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_dra_rec := p_dra_rec;

      x_dra_rec.OBJECT_VERSION_NUMBER := p_dra_rec.OBJECT_VERSION_NUMBER + 1;

      RETURN(l_return_status);

    END Set_Attributes;

  BEGIN

  --g_debug_proc('In DRA  l_def_dra_rec.day_of_month  ' || p_dra_rec.day_of_month);
    --g_debug_proc('In DRA l_def_dra_rec.scheduled_month ' || p_dra_rec.scheduled_month);

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

      p_dra_rec,                         -- IN

      l_dra_rec);                        -- OUT

    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_return_status := populate_new_record(l_dra_rec, l_def_dra_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    --g_debug_proc('In DRA  l_def_dra_rec.day_of_month  ' || l_def_dra_rec.day_of_month);
    --g_debug_proc('In DRA l_def_dra_rec.scheduled_month ' || l_def_dra_rec.scheduled_month);

    UPDATE OKL_DISB_RULES_B

    SET OBJECT_VERSION_NUMBER = l_def_dra_rec.object_version_number,

        RULE_NAME = l_def_dra_rec.rule_name,

        ORG_ID = l_def_dra_rec.org_id,

        START_DATE = l_def_dra_rec.start_date,

        END_DATE = l_def_dra_rec.end_date,

        FEE_OPTION = l_def_dra_rec.fee_option,

        FEE_BASIS = l_def_dra_rec.fee_basis,

        FEE_AMOUNT = l_def_dra_rec.fee_amount,

        FEE_PERCENT = l_def_dra_rec.fee_percent,

        CONSOLIDATE_BY_DUE_DATE = l_def_dra_rec.consolidate_by_due_date,

        FREQUENCY = l_def_dra_rec.frequency,

        DAY_OF_MONTH = l_def_dra_rec.day_of_month,

        SCHEDULED_MONTH = l_def_dra_rec.scheduled_month,

        CONSOLIDATE_STRM_TYPE = l_def_dra_rec.consolidate_strm_type,

        ATTRIBUTE_CATEGORY = l_def_dra_rec.attribute_category,

        ATTRIBUTE1 = l_def_dra_rec.attribute1,

        ATTRIBUTE2 = l_def_dra_rec.attribute2,

        ATTRIBUTE3 = l_def_dra_rec.attribute3,

        ATTRIBUTE4 = l_def_dra_rec.attribute4,

        ATTRIBUTE5 = l_def_dra_rec.attribute5,

        ATTRIBUTE6 = l_def_dra_rec.attribute6,

        ATTRIBUTE7 = l_def_dra_rec.attribute7,

        ATTRIBUTE8 = l_def_dra_rec.attribute8,

        ATTRIBUTE9 = l_def_dra_rec.attribute9,

        ATTRIBUTE10 = l_def_dra_rec.attribute10,

        ATTRIBUTE11 = l_def_dra_rec.attribute11,

        ATTRIBUTE12 = l_def_dra_rec.attribute12,

        ATTRIBUTE13 = l_def_dra_rec.attribute13,

        ATTRIBUTE14 = l_def_dra_rec.attribute14,

        ATTRIBUTE15 = l_def_dra_rec.attribute15,

        CREATED_BY = l_def_dra_rec.created_by,

        CREATION_DATE = l_def_dra_rec.creation_date,

        LAST_UPDATED_BY = l_def_dra_rec.last_updated_by,

        LAST_UPDATE_DATE = l_def_dra_rec.last_update_date,

        LAST_UPDATE_LOGIN = l_def_dra_rec.last_update_login

    WHERE DISB_RULE_ID = l_def_dra_rec.disb_rule_id;



    x_dra_rec := l_dra_rec;

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

  --------------------------------------

  -- update_row for:OKL_DISB_RULES_TL --

  --------------------------------------

  PROCEDURE update_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_okl_disb_rules_tl_rec        IN okl_disb_rules_tl_rec_type,

    x_okl_disb_rules_tl_rec        OUT NOCOPY okl_disb_rules_tl_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type := p_okl_disb_rules_tl_rec;

    l_def_okl_disb_rules_tl_rec    okl_disb_rules_tl_rec_type;

    l_row_notfound                 BOOLEAN := TRUE;

    ----------------------------------

    -- FUNCTION populate_new_record --

    ----------------------------------

    FUNCTION populate_new_record (

      p_okl_disb_rules_tl_rec IN okl_disb_rules_tl_rec_type,

      x_okl_disb_rules_tl_rec OUT NOCOPY okl_disb_rules_tl_rec_type

    ) RETURN VARCHAR2 IS

      l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;

      l_row_notfound                 BOOLEAN := TRUE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_okl_disb_rules_tl_rec := p_okl_disb_rules_tl_rec;

      -- Get current database values

      l_okl_disb_rules_tl_rec := get_rec(p_okl_disb_rules_tl_rec, l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        IF x_okl_disb_rules_tl_rec.disb_rule_id IS NULL THEN

          x_okl_disb_rules_tl_rec.disb_rule_id := l_okl_disb_rules_tl_rec.disb_rule_id;

        END IF;

        IF x_okl_disb_rules_tl_rec.language IS NULL THEN

          x_okl_disb_rules_tl_rec.language := l_okl_disb_rules_tl_rec.language;

        END IF;

        IF x_okl_disb_rules_tl_rec.source_lang IS NULL THEN

          x_okl_disb_rules_tl_rec.source_lang := l_okl_disb_rules_tl_rec.source_lang;

        END IF;

        IF x_okl_disb_rules_tl_rec.sfwt_flag IS NULL THEN

          x_okl_disb_rules_tl_rec.sfwt_flag := l_okl_disb_rules_tl_rec.sfwt_flag;

        END IF;

        IF x_okl_disb_rules_tl_rec.description IS NULL THEN

          x_okl_disb_rules_tl_rec.description := l_okl_disb_rules_tl_rec.description;

        END IF;

        IF x_okl_disb_rules_tl_rec.created_by IS NULL THEN

          x_okl_disb_rules_tl_rec.created_by := l_okl_disb_rules_tl_rec.created_by;

        END IF;

        IF x_okl_disb_rules_tl_rec.creation_date IS NULL THEN

          x_okl_disb_rules_tl_rec.creation_date := l_okl_disb_rules_tl_rec.creation_date;

        END IF;

        IF x_okl_disb_rules_tl_rec.last_updated_by IS NULL THEN

          x_okl_disb_rules_tl_rec.last_updated_by := l_okl_disb_rules_tl_rec.last_updated_by;

        END IF;

        IF x_okl_disb_rules_tl_rec.last_update_date IS NULL THEN

          x_okl_disb_rules_tl_rec.last_update_date := l_okl_disb_rules_tl_rec.last_update_date;

        END IF;

        IF x_okl_disb_rules_tl_rec.last_update_login IS NULL THEN

          x_okl_disb_rules_tl_rec.last_update_login := l_okl_disb_rules_tl_rec.last_update_login;

        END IF;

      END IF;

      RETURN(l_return_status);

    END populate_new_record;

    ------------------------------------------

    -- Set_Attributes for:OKL_DISB_RULES_TL --

    ------------------------------------------

    FUNCTION Set_Attributes (

      p_okl_disb_rules_tl_rec IN okl_disb_rules_tl_rec_type,

      x_okl_disb_rules_tl_rec OUT NOCOPY okl_disb_rules_tl_rec_type

    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_disb_rules_tl_rec := p_okl_disb_rules_tl_rec;
      x_okl_disb_rules_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_disb_rules_tl_rec.LANGUAGE := USERENV('LANG');
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

      p_okl_disb_rules_tl_rec,           -- IN

      l_okl_disb_rules_tl_rec);          -- OUT

    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_return_status := populate_new_record(l_okl_disb_rules_tl_rec, l_def_okl_disb_rules_tl_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    UPDATE OKL_DISB_RULES_TL

    SET DESCRIPTION = l_def_okl_disb_rules_tl_rec.description,

        CREATED_BY = l_def_okl_disb_rules_tl_rec.created_by,

        CREATION_DATE = l_def_okl_disb_rules_tl_rec.creation_date,

        LAST_UPDATED_BY = l_def_okl_disb_rules_tl_rec.last_updated_by,

        LAST_UPDATE_DATE = l_def_okl_disb_rules_tl_rec.last_update_date,

        LAST_UPDATE_LOGIN = l_def_okl_disb_rules_tl_rec.last_update_login

    WHERE DISB_RULE_ID = l_def_okl_disb_rules_tl_rec.disb_rule_id

      AND SOURCE_LANG = USERENV('LANG');



    UPDATE OKL_DISB_RULES_TL

    SET SFWT_FLAG = 'Y'

    WHERE DISB_RULE_ID = l_def_okl_disb_rules_tl_rec.disb_rule_id

      AND SOURCE_LANG <> USERENV('LANG');



    x_okl_disb_rules_tl_rec := l_okl_disb_rules_tl_rec;

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

  -- update_row for:OKL_DISB_RULES_V --

  -------------------------------------

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_drav_rec                     IN drav_rec_type,
    x_drav_rec                     OUT NOCOPY drav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_drav_rec                     drav_rec_type := p_drav_rec;
    l_def_drav_rec                 drav_rec_type;
    l_db_drav_rec                  drav_rec_type;
    l_dra_rec                      dra_rec_type;
    lx_dra_rec                     dra_rec_type;
    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;
    lx_okl_disb_rules_tl_rec       okl_disb_rules_tl_rec_type;

    -------------------------------

    -- FUNCTION fill_who_columns --

    -------------------------------

    FUNCTION fill_who_columns (

      p_drav_rec IN drav_rec_type

    ) RETURN drav_rec_type IS

      l_drav_rec drav_rec_type := p_drav_rec;

    BEGIN

      l_drav_rec.LAST_UPDATE_DATE := SYSDATE;

      l_drav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;

      l_drav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_drav_rec);

    END fill_who_columns;

    ----------------------------------

    -- FUNCTION populate_new_record --

    ----------------------------------

    FUNCTION populate_new_record (

      p_drav_rec IN drav_rec_type,

      x_drav_rec OUT NOCOPY drav_rec_type

    ) RETURN VARCHAR2 IS

      l_row_notfound                 BOOLEAN := TRUE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_drav_rec := p_drav_rec;

      -- Get current database values

      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it

      --       so it may be verified through LOCK_ROW.

      l_db_drav_rec := get_rec(p_drav_rec, l_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN

        IF x_drav_rec.disb_rule_id IS NULL THEN

          x_drav_rec.disb_rule_id := l_db_drav_rec.disb_rule_id;

        END IF;

        IF x_drav_rec.sfwt_flag IS NULL THEN

          x_drav_rec.sfwt_flag := l_db_drav_rec.sfwt_flag;

        END IF;

        IF x_drav_rec.rule_name IS NULL THEN

          x_drav_rec.rule_name := l_db_drav_rec.rule_name;

        END IF;

        IF x_drav_rec.org_id IS NULL THEN

          x_drav_rec.org_id := l_db_drav_rec.org_id;

        END IF;

        IF x_drav_rec.start_date IS NULL THEN

          x_drav_rec.start_date := l_db_drav_rec.start_date;

        END IF;

        IF x_drav_rec.end_date IS NULL THEN

          x_drav_rec.end_date := l_db_drav_rec.end_date;

        END IF;

        IF x_drav_rec.fee_option IS NULL THEN

          x_drav_rec.fee_option := l_db_drav_rec.fee_option;

        END IF;

        IF x_drav_rec.fee_basis IS NULL THEN

          x_drav_rec.fee_basis := l_db_drav_rec.fee_basis;

        END IF;

        IF x_drav_rec.fee_amount IS NULL THEN

          x_drav_rec.fee_amount := l_db_drav_rec.fee_amount;

        END IF;

        IF x_drav_rec.fee_percent IS NULL THEN

          x_drav_rec.fee_percent := l_db_drav_rec.fee_percent;

        END IF;

        IF x_drav_rec.consolidate_by_due_date IS NULL THEN

          x_drav_rec.consolidate_by_due_date := l_db_drav_rec.consolidate_by_due_date;

        END IF;

        IF x_drav_rec.frequency IS NULL THEN

          x_drav_rec.frequency := l_db_drav_rec.frequency;

        END IF;

        IF x_drav_rec.day_of_month IS NULL THEN

          x_drav_rec.day_of_month := l_db_drav_rec.day_of_month;

        END IF;

        IF x_drav_rec.scheduled_month IS NULL THEN

          x_drav_rec.scheduled_month := l_db_drav_rec.scheduled_month;

        END IF;

        IF x_drav_rec.consolidate_strm_type IS NULL THEN

          x_drav_rec.consolidate_strm_type := l_db_drav_rec.consolidate_strm_type;

        END IF;

        IF x_drav_rec.description IS NULL THEN

          x_drav_rec.description := l_db_drav_rec.description;

        END IF;

        IF x_drav_rec.attribute_category IS NULL THEN

          x_drav_rec.attribute_category := l_db_drav_rec.attribute_category;

        END IF;

        IF x_drav_rec.attribute1 IS NULL THEN

          x_drav_rec.attribute1 := l_db_drav_rec.attribute1;

        END IF;

        IF x_drav_rec.attribute2 IS NULL THEN

          x_drav_rec.attribute2 := l_db_drav_rec.attribute2;

        END IF;

        IF x_drav_rec.attribute3 IS NULL THEN

          x_drav_rec.attribute3 := l_db_drav_rec.attribute3;

        END IF;

        IF x_drav_rec.attribute4 IS NULL THEN

          x_drav_rec.attribute4 := l_db_drav_rec.attribute4;

        END IF;

        IF x_drav_rec.attribute5 IS NULL THEN

          x_drav_rec.attribute5 := l_db_drav_rec.attribute5;

        END IF;

        IF x_drav_rec.attribute6 IS NULL THEN

          x_drav_rec.attribute6 := l_db_drav_rec.attribute6;

        END IF;

        IF x_drav_rec.attribute7 IS NULL THEN

          x_drav_rec.attribute7 := l_db_drav_rec.attribute7;

        END IF;

        IF x_drav_rec.attribute8 IS NULL THEN

          x_drav_rec.attribute8 := l_db_drav_rec.attribute8;

        END IF;

        IF x_drav_rec.attribute9 IS NULL THEN

          x_drav_rec.attribute9 := l_db_drav_rec.attribute9;

        END IF;

        IF x_drav_rec.attribute10 IS NULL THEN

          x_drav_rec.attribute10 := l_db_drav_rec.attribute10;

        END IF;

        IF x_drav_rec.attribute11 IS NULL THEN

          x_drav_rec.attribute11 := l_db_drav_rec.attribute11;

        END IF;

        IF x_drav_rec.attribute12 IS NULL THEN

          x_drav_rec.attribute12 := l_db_drav_rec.attribute12;

        END IF;

        IF x_drav_rec.attribute13 IS NULL THEN

          x_drav_rec.attribute13 := l_db_drav_rec.attribute13;

        END IF;

        IF x_drav_rec.attribute14 IS NULL THEN

          x_drav_rec.attribute14 := l_db_drav_rec.attribute14;

        END IF;

        IF x_drav_rec.attribute15 IS NULL THEN

          x_drav_rec.attribute15 := l_db_drav_rec.attribute15;

        END IF;

        IF x_drav_rec.created_by IS NULL THEN

          x_drav_rec.created_by := l_db_drav_rec.created_by;

        END IF;

        IF x_drav_rec.creation_date IS NULL THEN

          x_drav_rec.creation_date := l_db_drav_rec.creation_date;

        END IF;

        IF x_drav_rec.last_updated_by IS NULL THEN

          x_drav_rec.last_updated_by := l_db_drav_rec.last_updated_by;

        END IF;

        IF x_drav_rec.last_update_date IS NULL THEN

          x_drav_rec.last_update_date := l_db_drav_rec.last_update_date;

        END IF;

        IF x_drav_rec.last_update_login IS NULL THEN

          x_drav_rec.last_update_login := l_db_drav_rec.last_update_login;

        END IF;

      END IF;

      RETURN(l_return_status);

    END populate_new_record;

    -----------------------------------------

    -- Set_Attributes for:OKL_DISB_RULES_V --

    -----------------------------------------

    FUNCTION Set_Attributes (

      p_drav_rec IN drav_rec_type,

      x_drav_rec OUT NOCOPY drav_rec_type

    ) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_drav_rec := p_drav_rec;

      RETURN(l_return_status);

    END Set_Attributes;

  BEGIN
    --g_debug_proc('In TAPI DRA  '  || p_drav_rec.scheduled_month);

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
      p_drav_rec,                        -- IN
      l_drav_rec);                       -- OUT

 ----g_debug_proc('SEt Attri');

  --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_drav_rec, l_def_drav_rec);

----g_debug_proc('Populate Record');

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_drav_rec := null_out_defaults(l_def_drav_rec);
--g_debug_proc('null defects  '   || l_def_drav_rec.scheduled_month);

    l_def_drav_rec := fill_who_columns(l_def_drav_rec);

--g_debug_proc('fill columns  ' || l_def_drav_rec.scheduled_month);
    --- Validate all non-missing attributes (Item Level Validation)

    l_return_status := Validate_Attributes(l_def_drav_rec);

--g_debug_proc('validate attri  ' || l_return_status);
    --- If any errors happen abort API

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    l_return_status := Validate_Record(l_def_drav_rec, l_db_drav_rec);
    --g_debug_proc('validate rec  '   || l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


   --g_debug_proc('Tapi update LOCK DRA');
    -- Lock the Record

    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_drav_rec                     => l_db_drav_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    -----------------------------------------

    -- Move VIEW record to "Child" records --

    -----------------------------------------
    --g_debug_proc('Tapi Before Migrate');
    migrate(l_def_drav_rec, l_dra_rec);
    migrate(l_def_drav_rec, l_okl_disb_rules_tl_rec);

    -----------------------------------------------

    -- Call the UPDATE_ROW for each child record --

    -----------------------------------------------
   --g_debug_proc('Tapi UpdateDRA  ' || l_db_drav_rec.object_version_number || l_dra_rec.object_version_number );
   --g_debug_proc('Tapi UpdateDRA  ' || l_def_drav_rec.scheduled_month);
   --g_debug_proc('Tapi UpdateDRA  ' || l_dra_rec.scheduled_month);

    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_dra_rec,
      lx_dra_rec
    );

    --g_debug_proc('Tapi UpdateDRA ' || l_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    migrate(lx_dra_rec, l_def_drav_rec);

    update_row(

      p_init_msg_list,

      l_return_status,

      x_msg_count,

      x_msg_data,

      l_okl_disb_rules_tl_rec,

      lx_okl_disb_rules_tl_rec

    );

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    migrate(lx_okl_disb_rules_tl_rec, l_def_drav_rec);

    x_drav_rec := l_def_drav_rec;

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

  -- PL/SQL TBL update_row for:drav_tbl --

  ----------------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type,

    x_drav_tbl                     OUT NOCOPY drav_tbl_type,

    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';

    i                              NUMBER := 0;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      i := p_drav_tbl.FIRST;

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

            p_drav_rec                     => p_drav_tbl(i),

            x_drav_rec                     => x_drav_tbl(i));

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

        EXIT WHEN (i = p_drav_tbl.LAST);

        i := p_drav_tbl.NEXT(i);

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

  -- PL/SQL TBL update_row for:DRAV_TBL --

  ----------------------------------------

  PROCEDURE update_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type,

    x_drav_tbl                     OUT NOCOPY drav_tbl_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      update_row (

        p_api_version                  => p_api_version,

        p_init_msg_list                => OKL_API.G_FALSE,

        x_return_status                => x_return_status,

        x_msg_count                    => x_msg_count,

        x_msg_data                     => x_msg_data,

        p_drav_tbl                     => p_drav_tbl,

        x_drav_tbl                     => x_drav_tbl,

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

  -------------------------------------

  -- delete_row for:OKL_DISB_RULES_B --

  -------------------------------------

  PROCEDURE delete_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_dra_rec                      IN dra_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_dra_rec                      dra_rec_type := p_dra_rec;

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



    DELETE FROM OKL_DISB_RULES_B

     WHERE DISB_RULE_ID = p_dra_rec.disb_rule_id;



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

  --------------------------------------

  -- delete_row for:OKL_DISB_RULES_TL --

  --------------------------------------

  PROCEDURE delete_row(

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_okl_disb_rules_tl_rec        IN okl_disb_rules_tl_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type := p_okl_disb_rules_tl_rec;

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



    DELETE FROM OKL_DISB_RULES_TL

     WHERE DISB_RULE_ID = p_okl_disb_rules_tl_rec.disb_rule_id;



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

  -- delete_row for:OKL_DISB_RULES_V --

  -------------------------------------

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_rec                     IN drav_rec_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_drav_rec                     drav_rec_type := p_drav_rec;

    l_okl_disb_rules_tl_rec        okl_disb_rules_tl_rec_type;

    l_dra_rec                      dra_rec_type;

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

    migrate(l_drav_rec, l_okl_disb_rules_tl_rec);

    migrate(l_drav_rec, l_dra_rec);

    -----------------------------------------------

    -- Call the DELETE_ROW for each child record --

    -----------------------------------------------

    delete_row(

      p_init_msg_list,

      l_return_status,

      x_msg_count,

      x_msg_data,

      l_okl_disb_rules_tl_rec

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

      l_dra_rec

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

  ------------------------------------------------

  -- PL/SQL TBL delete_row for:OKL_DISB_RULES_V --

  ------------------------------------------------

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type,

    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';

    i                              NUMBER := 0;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      i := p_drav_tbl.FIRST;

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

            p_drav_rec                     => p_drav_tbl(i));

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

        EXIT WHEN (i = p_drav_tbl.LAST);

        i := p_drav_tbl.NEXT(i);

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



  ------------------------------------------------

  -- PL/SQL TBL delete_row for:OKL_DISB_RULES_V --

  ------------------------------------------------

  PROCEDURE delete_row(

    p_api_version                  IN NUMBER,

    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,

    x_msg_count                    OUT NOCOPY NUMBER,

    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_drav_tbl                     IN drav_tbl_type) IS



    l_api_version                  CONSTANT NUMBER := 1;

    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing

    IF (p_drav_tbl.COUNT > 0) THEN

      delete_row (

        p_api_version                  => p_api_version,

        p_init_msg_list                => OKL_API.G_FALSE,

        x_return_status                => x_return_status,

        x_msg_count                    => x_msg_count,

        x_msg_data                     => x_msg_data,

        p_drav_tbl                     => p_drav_tbl,

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

END OKL_DRA_PVT;

/
