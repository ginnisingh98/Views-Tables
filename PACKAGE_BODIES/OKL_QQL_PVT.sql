--------------------------------------------------------
--  DDL for Package Body OKL_QQL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QQL_PVT" AS
/* $Header: OKLSQQLB.pls 120.1 2005/12/22 12:26:23 smadhava noship $ */

  -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_QUICK_QUOTE_LINES_TL T
    WHERE NOT EXISTS (SELECT NULL FROM OKL_QUICK_QUOTE_LINES_B B WHERE B.ID =T.ID);

    UPDATE OKL_QUICK_QUOTE_LINES_TL T
    SET (SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS) =
                     (SELECT
                      B.SHORT_DESCRIPTION,
                      B.DESCRIPTION,
                      B.COMMENTS
                      FROM
                      OKL_QUICK_QUOTE_LINES_TL B
                      WHERE
                      B.ID = T.ID
                      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT
                                 SUBT.ID,
                                 SUBT.LANGUAGE
                                 FROM
                                 OKL_QUICK_QUOTE_LINES_TL SUBB,
                                 OKL_QUICK_QUOTE_LINES_TL SUBT
                                 WHERE
                                 SUBB.ID = SUBT.ID
                                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                                      OR (SUBB.DESCRIPTION <> SUBT.DESCRIPTION)
                                      OR (SUBB.COMMENTS <> SUBT.COMMENTS)
                                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                                     )
                                );

    INSERT INTO OKL_QUICK_QUOTE_LINES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN,
            B.SHORT_DESCRIPTION,
            B.DESCRIPTION,
            B.COMMENTS
        FROM OKL_QUICK_QUOTE_LINES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_QUICK_QUOTE_LINES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;


  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_qqlv_rec IN qqlv_rec_type) RETURN qqlv_rec_type IS

    l_qqlv_rec  qqlv_rec_type;

  BEGIN

    l_qqlv_rec := p_qqlv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_qqlv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute_category := NULL;
    END IF;
    IF l_qqlv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute1 := NULL;
    END IF;
    IF l_qqlv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute2 := NULL;
    END IF;
    IF l_qqlv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute3 := NULL;
    END IF;
    IF l_qqlv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute4 := NULL;
    END IF;
    IF l_qqlv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute5 := NULL;
    END IF;
    IF l_qqlv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute6 := NULL;
    END IF;
    IF l_qqlv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute7 := NULL;
    END IF;
    IF l_qqlv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute8 := NULL;
    END IF;
    IF l_qqlv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute9 := NULL;
    END IF;
    IF l_qqlv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute10 := NULL;
    END IF;
    IF l_qqlv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute11 := NULL;
    END IF;
    IF l_qqlv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute12 := NULL;
    END IF;
    IF l_qqlv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute13 := NULL;
    END IF;
    IF l_qqlv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute14 := NULL;
    END IF;
    IF l_qqlv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.attribute15 := NULL;
    END IF;
    IF l_qqlv_rec.quick_quote_id = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.quick_quote_id := NULL;
    END IF;
    IF l_qqlv_rec.type = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.type := NULL;
    END IF;
    IF l_qqlv_rec.basis = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.basis := NULL;
    END IF;
    IF l_qqlv_rec.value = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.value := NULL;
    END IF;
    IF l_qqlv_rec.end_of_term_value_default = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.end_of_term_value_default := NULL;
    END IF;
    IF l_qqlv_rec.end_of_term_value = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.end_of_term_value := NULL;
    END IF;
    IF l_qqlv_rec.percentage_of_total_cost = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.percentage_of_total_cost := NULL;
    END IF;
    IF l_qqlv_rec.item_category_id = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.item_category_id := NULL;
    END IF;
    IF l_qqlv_rec.item_category_set_id = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.item_category_set_id := NULL;
    END IF;
    IF l_qqlv_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
      l_qqlv_rec.lease_rate_factor := NULL;
    END IF;
    IF l_qqlv_rec.short_description = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.short_description := NULL;
    END IF;
    IF l_qqlv_rec.description = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.description := NULL;
    END IF;
    IF l_qqlv_rec.comments = FND_API.G_MISS_CHAR THEN
      l_qqlv_rec.comments := NULL;
    END IF;

    RETURN l_qqlv_rec;

  END null_out_defaults;


  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN qqlv_rec_type IS

    l_qqlv_rec           qqlv_rec_type;
    l_prog_name          VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.get_rec';

    SELECT
      id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,quick_quote_id
      ,type
      ,basis
      ,value
      ,end_of_term_value_default
      ,end_of_term_value
      ,percentage_of_total_cost
      ,item_category_id
      ,item_category_set_id
      ,lease_rate_factor
      ,short_description
      ,description
      ,comments
    INTO
      l_qqlv_rec.id
      ,l_qqlv_rec.object_version_number
      ,l_qqlv_rec.attribute_category
      ,l_qqlv_rec.attribute1
      ,l_qqlv_rec.attribute2
      ,l_qqlv_rec.attribute3
      ,l_qqlv_rec.attribute4
      ,l_qqlv_rec.attribute5
      ,l_qqlv_rec.attribute6
      ,l_qqlv_rec.attribute7
      ,l_qqlv_rec.attribute8
      ,l_qqlv_rec.attribute9
      ,l_qqlv_rec.attribute10
      ,l_qqlv_rec.attribute11
      ,l_qqlv_rec.attribute12
      ,l_qqlv_rec.attribute13
      ,l_qqlv_rec.attribute14
      ,l_qqlv_rec.attribute15
      ,l_qqlv_rec.quick_quote_id
      ,l_qqlv_rec.type
      ,l_qqlv_rec.basis
      ,l_qqlv_rec.value
      ,l_qqlv_rec.end_of_term_value_default
      ,l_qqlv_rec.end_of_term_value
      ,l_qqlv_rec.percentage_of_total_cost
      ,l_qqlv_rec.item_category_id
      ,l_qqlv_rec.item_category_set_id
      ,l_qqlv_rec.lease_rate_factor
      ,l_qqlv_rec.short_description
      ,l_qqlv_rec.description
      ,l_qqlv_rec.comments
    FROM OKL_QUICK_QUOTE_LINES_V
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_qqlv_rec;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_rec;


  ------------------------
  -- PROCEDURE validate_id
  ------------------------
  PROCEDURE validate_id (x_return_status OUT NOCOPY VARCHAR2, p_id IN NUMBER) IS
  BEGIN
    IF p_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_id;


  -------------------------------------------
  -- PROCEDURE validate_object_version_number
  -------------------------------------------
  PROCEDURE validate_object_version_number (x_return_status OUT NOCOPY VARCHAR2, p_object_version_number IN NUMBER) IS
  BEGIN
    IF p_object_version_number IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'object_version_number',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_object_version_number;


  ------------------------
  -- PROCEDURE validate_quick_quote_id
  ------------------------
  PROCEDURE validate_quick_quote_id (x_return_status OUT NOCOPY VARCHAR2, p_quick_quote_id IN NUMBER) IS
  BEGIN
    IF p_quick_quote_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'quick_quote_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_quick_quote_id;


  --------------------------------------
  -- PROCEDURE validate_type
  --------------------------------------
  PROCEDURE validate_type (x_return_status OUT NOCOPY VARCHAR2, p_type IN VARCHAR2) IS
  BEGIN
    IF p_type IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'type',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_type;


  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_qqlv_rec IN qqlv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_qqlv_rec.id);
    validate_object_version_number (l_return_status, p_qqlv_rec.object_version_number);
    validate_quick_quote_id (l_return_status, p_qqlv_rec.quick_quote_id);
    validate_type (l_return_status, p_qqlv_rec.type);


    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_qqlv_rec IN qqlv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    RETURN G_RET_STS_SUCCESS;
  END validate_record;


  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN qqlv_rec_type, p_to IN OUT NOCOPY qql_rec_type) IS

  BEGIN

    p_to.id                             :=  p_from.id;
    p_to.object_version_number          :=  p_from.object_version_number;
    p_to.attribute_category             :=  p_from.attribute_category;
    p_to.attribute1                     :=  p_from.attribute1;
    p_to.attribute2                     :=  p_from.attribute2;
    p_to.attribute3                     :=  p_from.attribute3;
    p_to.attribute4                     :=  p_from.attribute4;
    p_to.attribute5                     :=  p_from.attribute5;
    p_to.attribute6                     :=  p_from.attribute6;
    p_to.attribute7                     :=  p_from.attribute7;
    p_to.attribute8                     :=  p_from.attribute8;
    p_to.attribute9                     :=  p_from.attribute9;
    p_to.attribute10                    :=  p_from.attribute10;
    p_to.attribute11                    :=  p_from.attribute11;
    p_to.attribute12                    :=  p_from.attribute12;
    p_to.attribute13                    :=  p_from.attribute13;
    p_to.attribute14                    :=  p_from.attribute14;
    p_to.attribute15                    :=  p_from.attribute15;
    p_to.quick_quote_id                 :=  p_from.quick_quote_id;
    p_to.type                           :=  p_from.type;
    p_to.basis                          :=  p_from.basis;
    p_to.value                          :=  p_from.value;
    p_to.end_of_term_value_default      :=  p_from.end_of_term_value_default;
    p_to.end_of_term_value              :=  p_from.end_of_term_value;
    p_to.percentage_of_total_cost       :=  p_from.percentage_of_total_cost;
    p_to.item_category_id               :=  p_from.item_category_id;
    p_to.item_category_set_id           :=  p_from.item_category_set_id;
    p_to.lease_rate_factor              :=  p_from.lease_rate_factor;

  END migrate;


  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN qqlv_rec_type, p_to IN OUT NOCOPY qqltl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
  END migrate;


  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_qql_rec IN qql_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_quick_quote_lines_b (
      id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,quick_quote_id
      ,type
      ,basis
      ,value
      ,end_of_term_value_default
      ,end_of_term_value
      ,percentage_of_total_cost
      ,item_category_id
      ,item_category_set_id
      ,lease_rate_factor
      )
    VALUES
      (
       p_qql_rec.id
      ,p_qql_rec.object_version_number
      ,p_qql_rec.attribute_category
      ,p_qql_rec.attribute1
      ,p_qql_rec.attribute2
      ,p_qql_rec.attribute3
      ,p_qql_rec.attribute4
      ,p_qql_rec.attribute5
      ,p_qql_rec.attribute6
      ,p_qql_rec.attribute7
      ,p_qql_rec.attribute8
      ,p_qql_rec.attribute9
      ,p_qql_rec.attribute10
      ,p_qql_rec.attribute11
      ,p_qql_rec.attribute12
      ,p_qql_rec.attribute13
      ,p_qql_rec.attribute14
      ,p_qql_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_qql_rec.quick_quote_id
      ,p_qql_rec.type
      ,p_qql_rec.basis
      ,p_qql_rec.value
      ,p_qql_rec.end_of_term_value_default
      ,p_qql_rec.end_of_term_value
      ,p_qql_rec.percentage_of_total_cost
      ,p_qql_rec.item_category_id
      ,p_qql_rec.item_category_set_id
      ,p_qql_rec.lease_rate_factor
    );

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ----------------------------
  -- PROCEDURE insert_row (TL)
  ----------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_qqltl_rec IN qqltl_rec_type) IS

    CURSOR get_languages IS
      SELECT language_code
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');

    l_sfwt_flag  VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TL)';

    FOR l_lang_rec IN get_languages LOOP

      IF l_lang_rec.language_code = USERENV('LANG') THEN
        l_sfwt_flag := 'N';
      ELSE
        l_sfwt_flag := 'Y';
      END IF;

      INSERT INTO OKL_QUICK_QUOTE_LINES_TL (
        id
       ,language
       ,source_lang
       ,sfwt_flag
       ,created_by
       ,creation_date
       ,last_updated_by
       ,last_update_date
       ,last_update_login
       ,short_description
       ,description
       ,comments)
      VALUES (
        p_qqltl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_qqltl_rec.short_description
       ,p_qqltl_rec.description
       ,p_qqltl_rec.comments);

    END LOOP;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ---------------------------
  -- PROCEDURE insert_row (V)
  ---------------------------
  PROCEDURE insert_row (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type,
    x_qqlv_rec                     OUT NOCOPY qqlv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_qqlv_rec                     qqlv_rec_type;
    l_qql_rec                      qql_rec_type;
    l_qqltl_rec                    qqltl_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_qqlv_rec                       := null_out_defaults (p_qqlv_rec);

    SELECT okl_qql_seq.nextval INTO l_qqlv_rec.ID FROM DUAL;

    l_qqlv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_qqlv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_qqlv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_qqlv_rec, l_qql_rec);
    migrate (l_qqlv_rec, l_qqltl_rec);

    insert_row (x_return_status => l_return_status, p_qql_rec => l_qql_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_qqltl_rec => l_qqltl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_qqlv_rec      := l_qqlv_rec;
    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------------------
  -- PROCEDURE insert_row (REC)
  -----------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type,
    x_qqlv_rec                     OUT NOCOPY qqlv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_qqlv_rec                     => p_qqlv_rec,
                x_qqlv_rec                     => x_qqlv_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------------------
  -- PROCEDURE insert_row (TBL)
  -----------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_tbl                     IN qqlv_tbl_type,
    x_qqlv_tbl                     OUT NOCOPY qqlv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_qqlv_tbl.COUNT > 0) THEN
      i := p_qqlv_tbl.FIRST;
      LOOP
        IF p_qqlv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_qqlv_rec                     => p_qqlv_tbl(i),
                      x_qqlv_rec                     => x_qqlv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qqlv_tbl.LAST);
          i := p_qqlv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ---------------------
  -- PROCEDURE lock_row
  ---------------------
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_qql_rec IN qql_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUICK_QUOTE_LINES_B
     WHERE ID = p_qql_rec.id
       AND OBJECT_VERSION_NUMBER = p_qql_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUICK_QUOTE_LINES_B
     WHERE ID = p_qql_rec.id;

    l_object_version_number        NUMBER;
    lc_object_version_number       NUMBER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.lock_row';

    BEGIN
      OPEN lock_csr;
      FETCH lock_csr INTO l_object_version_number;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR2,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END;

    IF l_object_version_number IS NULL THEN

      OPEN lchk_csr;
      FETCH lchk_csr INTO lc_object_version_number;
      CLOSE lchk_csr;

      IF lc_object_version_number IS NULL THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR3,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);

      ELSIF lc_object_version_number <> p_qql_rec.object_version_number THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);

      END IF;

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END lock_row;


  ---------------------------
  -- PROCEDURE update_row (B)
  ---------------------------
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_qql_rec IN qql_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_qql_rec => p_qql_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_quick_quote_lines_b
    SET
      object_version_number = p_qql_rec.object_version_number+1
      ,attribute_category = p_qql_rec.attribute_category
      ,attribute1 = p_qql_rec.attribute1
      ,attribute2 = p_qql_rec.attribute2
      ,attribute3 = p_qql_rec.attribute3
      ,attribute4 = p_qql_rec.attribute4
      ,attribute5 = p_qql_rec.attribute5
      ,attribute6 = p_qql_rec.attribute6
      ,attribute7 = p_qql_rec.attribute7
      ,attribute8 = p_qql_rec.attribute8
      ,attribute9 = p_qql_rec.attribute9
      ,attribute10 = p_qql_rec.attribute10
      ,attribute11 = p_qql_rec.attribute11
      ,attribute12 = p_qql_rec.attribute12
      ,attribute13 = p_qql_rec.attribute13
      ,attribute14 = p_qql_rec.attribute14
      ,attribute15 = p_qql_rec.attribute15
      ,quick_quote_id = p_qql_rec.quick_quote_id
      ,type = p_qql_rec.type
      ,basis = p_qql_rec.basis
      ,value = p_qql_rec.value
      ,end_of_term_value_default = p_qql_rec.end_of_term_value_default
      ,end_of_term_value = p_qql_rec.end_of_term_value
      ,percentage_of_total_cost = p_qql_rec.percentage_of_total_cost
      ,item_category_id = p_qql_rec.item_category_id
      ,item_category_set_id = p_qql_rec.item_category_set_id
      ,lease_rate_factor = p_qql_rec.lease_rate_factor
    WHERE id = p_qql_rec.id;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  ----------------------------
  -- PROCEDURE update_row (TL)
  ----------------------------
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_qqltl_rec IN qqltl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_QUICK_QUOTE_LINES_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_qqltl_rec.short_description
      ,description = p_qqltl_rec.description
      ,comments = p_qqltl_rec.comments
    WHERE ID = p_qqltl_rec.id;

    UPDATE OKL_QUICK_QUOTE_LINES_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_qqltl_rec.id
    AND SOURCE_LANG = LANGUAGE;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  ---------------------------
  -- PROCEDURE update_row (V)
  ---------------------------
  PROCEDURE update_row (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type,
    x_qqlv_rec                     OUT NOCOPY qqlv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_qqlv_rec                     qqlv_rec_type;
    l_qql_rec                      qql_rec_type;
    l_qqltl_rec                    qqltl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_qqlv_rec IN  qqlv_rec_type,
                                  x_qqlv_rec OUT NOCOPY qqlv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61);
      l_return_status      VARCHAR2(1);
      l_db_qqlv_rec        qqlv_rec_type;

    BEGIN

      l_prog_name := G_PKG_NAME||'.populate_new_record';

      x_qqlv_rec    := p_qqlv_rec;
      l_db_qqlv_rec := get_rec (p_qqlv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- smadhava - modified - G_MISS compliance - Start
      IF x_qqlv_rec.attribute_category IS NULL THEN
        x_qqlv_rec.attribute_category := l_db_qqlv_rec.attribute_category;
      ELSIF x_qqlv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute_category := null;
      END IF;

      IF x_qqlv_rec.attribute1 IS NULL THEN
        x_qqlv_rec.attribute1 := l_db_qqlv_rec.attribute1;
      ELSIF x_qqlv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute1 := null;
      END IF;

      IF x_qqlv_rec.attribute2 IS NULL THEN
        x_qqlv_rec.attribute2 := l_db_qqlv_rec.attribute2;
      ELSIF x_qqlv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute2 := null;
      END IF;

      IF x_qqlv_rec.attribute3 IS NULL THEN
        x_qqlv_rec.attribute3 := l_db_qqlv_rec.attribute3;
      ELSIF x_qqlv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute3 := null;
      END IF;

      IF x_qqlv_rec.attribute4 IS NULL THEN
        x_qqlv_rec.attribute4 := l_db_qqlv_rec.attribute4;
      ELSIF x_qqlv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute4 := null;
      END IF;

      IF x_qqlv_rec.attribute5 IS NULL THEN
        x_qqlv_rec.attribute5 := l_db_qqlv_rec.attribute5;
      ELSIF x_qqlv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute5 := null;
      END IF;

      IF x_qqlv_rec.attribute6 IS NULL THEN
        x_qqlv_rec.attribute6 := l_db_qqlv_rec.attribute6;
      ELSIF x_qqlv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute6 := null;
      END IF;

      IF x_qqlv_rec.attribute7 IS NULL THEN
        x_qqlv_rec.attribute7 := l_db_qqlv_rec.attribute7;
      ELSIF x_qqlv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute7 := null;
      END IF;

      IF x_qqlv_rec.attribute8 IS NULL THEN
        x_qqlv_rec.attribute8 := l_db_qqlv_rec.attribute8;
      ELSIF x_qqlv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute8 := null;
      END IF;

      IF x_qqlv_rec.attribute9 IS NULL THEN
        x_qqlv_rec.attribute9 := l_db_qqlv_rec.attribute9;
      ELSIF x_qqlv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute9 := null;
      END IF;

      IF x_qqlv_rec.attribute10 IS NULL THEN
        x_qqlv_rec.attribute10 := l_db_qqlv_rec.attribute10;
      ELSIF x_qqlv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute10 := null;
      END IF;

      IF x_qqlv_rec.attribute11 IS NULL THEN
        x_qqlv_rec.attribute11 := l_db_qqlv_rec.attribute11;
      ELSIF x_qqlv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute11 := null;
      END IF;

      IF x_qqlv_rec.attribute12 IS NULL THEN
        x_qqlv_rec.attribute12 := l_db_qqlv_rec.attribute12;
      ELSIF x_qqlv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute12 := null;
      END IF;

      IF x_qqlv_rec.attribute13 IS NULL THEN
        x_qqlv_rec.attribute13 := l_db_qqlv_rec.attribute13;
      ELSIF x_qqlv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute13 := null;
      END IF;

      IF x_qqlv_rec.attribute14 IS NULL THEN
        x_qqlv_rec.attribute14 := l_db_qqlv_rec.attribute14;
      ELSIF x_qqlv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute14 := null;
      END IF;

      IF x_qqlv_rec.attribute15 IS NULL THEN
        x_qqlv_rec.attribute15 := l_db_qqlv_rec.attribute15;
      ELSIF x_qqlv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.attribute15 := null;
      END IF;

      IF x_qqlv_rec.quick_quote_id IS NULL THEN
        x_qqlv_rec.quick_quote_id := l_db_qqlv_rec.quick_quote_id;
      ELSIF x_qqlv_rec.quick_quote_id = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.quick_quote_id := null;
      END IF;

      IF x_qqlv_rec.type IS NULL THEN
        x_qqlv_rec.type := l_db_qqlv_rec.type;
      ELSIF x_qqlv_rec.type = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.type := null;
      END IF;

      IF x_qqlv_rec.basis IS NULL THEN
        x_qqlv_rec.basis := l_db_qqlv_rec.basis;
      ELSIF x_qqlv_rec.basis = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.basis := null;
      END IF;

      IF x_qqlv_rec.value IS NULL THEN
        x_qqlv_rec.value := l_db_qqlv_rec.value;
      ELSIF x_qqlv_rec.value = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.value := null;
      END IF;

      IF x_qqlv_rec.end_of_term_value_default IS NULL THEN
        x_qqlv_rec.end_of_term_value_default := l_db_qqlv_rec.end_of_term_value_default;
      ELSIF x_qqlv_rec.end_of_term_value_default = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.end_of_term_value_default := null;
      END IF;

      IF x_qqlv_rec.end_of_term_value IS NULL THEN
        x_qqlv_rec.end_of_term_value := l_db_qqlv_rec.end_of_term_value;
      ELSIF x_qqlv_rec.end_of_term_value = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.end_of_term_value := null;
      END IF;

      IF x_qqlv_rec.percentage_of_total_cost IS NULL THEN
        x_qqlv_rec.percentage_of_total_cost := l_db_qqlv_rec.percentage_of_total_cost;
      ELSIF x_qqlv_rec.percentage_of_total_cost = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.percentage_of_total_cost := null;
      END IF;

      IF x_qqlv_rec.item_category_id IS NULL THEN
        x_qqlv_rec.item_category_id := l_db_qqlv_rec.item_category_id;
      ELSIF x_qqlv_rec.item_category_id = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.item_category_id := null;
      END IF;

      IF x_qqlv_rec.item_category_set_id IS NULL THEN
        x_qqlv_rec.item_category_set_id := l_db_qqlv_rec.item_category_set_id;
      ELSIF x_qqlv_rec.item_category_set_id = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.item_category_set_id := null;
      END IF;

      IF x_qqlv_rec.lease_rate_factor IS NULL THEN
        x_qqlv_rec.lease_rate_factor := l_db_qqlv_rec.lease_rate_factor;
      ELSIF x_qqlv_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
        x_qqlv_rec.lease_rate_factor := null;
      END IF;

      IF x_qqlv_rec.short_description IS NULL THEN
        x_qqlv_rec.short_description := l_db_qqlv_rec.short_description;
      ELSIF x_qqlv_rec.short_description = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.short_description := null;
      END IF;

      IF x_qqlv_rec.description IS NULL THEN
        x_qqlv_rec.description := l_db_qqlv_rec.description;
      ELSIF x_qqlv_rec.description = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.description := null;
      END IF;

      IF x_qqlv_rec.comments IS NULL THEN
        x_qqlv_rec.comments := l_db_qqlv_rec.comments;
      ELSIF x_qqlv_rec.comments = FND_API.G_MISS_CHAR THEN
        x_qqlv_rec.comments := null;
      END IF;
      -- smadhava - modified - G_MISS compliance - End

      RETURN l_return_status;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN

        x_return_status := G_RET_STS_ERROR;

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        x_return_status := G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DB_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name,
                             p_token2       => G_SQLCODE_TOKEN,
                             p_token2_value => sqlcode,
                             p_token3       => G_SQLERRM_TOKEN,
                             p_token3_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

    END populate_new_record;

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (V)';

    l_return_status := populate_new_record (p_qqlv_rec, l_qqlv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_qqlv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_qqlv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_qqlv_rec, l_qql_rec);
    migrate (l_qqlv_rec, l_qqltl_rec);

    update_row (x_return_status => l_return_status, p_qql_rec => l_qql_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_qqltl_rec => l_qqltl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_qqlv_rec      := l_qqlv_rec;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------------------
  -- PROCEDURE update_row (REC)
  -----------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type,
    x_qqlv_rec                     OUT NOCOPY qqlv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_qqlv_rec                     => p_qqlv_rec,
                x_qqlv_rec                     => x_qqlv_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --viselvar added
    x_qqlv_rec.object_version_number:=x_qqlv_rec.object_version_number+1;
    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------------------
  -- PROCEDURE update_row (TBL)
  -----------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_tbl                     IN qqlv_tbl_type,
    x_qqlv_tbl                     OUT NOCOPY qqlv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_qqlv_tbl := p_qqlv_tbl;

    IF (p_qqlv_tbl.COUNT > 0) THEN

      i := p_qqlv_tbl.FIRST;

      LOOP

        IF p_qqlv_tbl.EXISTS(i) THEN
          update_row (p_api_version     => p_api_version,
                      p_init_msg_list   => p_init_msg_list,
                      x_return_status   => l_return_status,
                      x_msg_count       => x_msg_count,
                      x_msg_data        => x_msg_data,
                      p_qqlv_rec        => p_qqlv_tbl(i),
                      x_qqlv_rec        => x_qqlv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qqlv_tbl.LAST);
          i := p_qqlv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------
  -- delete_row (V)
  -----------------
  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (V)';

    DELETE FROM OKL_QUICK_QUOTE_LINES_B WHERE id = p_id;
    DELETE FROM OKL_QUICK_QUOTE_LINES_TL WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


  -----------------------------
  -- PROCEDURE delete_row (REC)
  -----------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_rec                     IN qqlv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_qqlv_rec.id);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


  -------------------
  -- delete_row (TBL)
  -------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qqlv_tbl                     IN qqlv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_qqlv_tbl.COUNT > 0) THEN

      i := p_qqlv_tbl.FIRST;

      LOOP

        IF p_qqlv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_qqlv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qqlv_tbl.LAST);
          i := p_qqlv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


END OKL_QQL_PVT;

/
