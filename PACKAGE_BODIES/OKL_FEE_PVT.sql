--------------------------------------------------------
--  DDL for Package Body OKL_FEE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FEE_PVT" AS
/* $Header: OKLSFEEB.pls 120.2 2007/08/08 21:11:59 rravikir noship $ */

  -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_FEES_TL T
    WHERE NOT EXISTS (SELECT NULL FROM OKL_FEES_B B WHERE B.ID =T.ID);

    UPDATE OKL_FEES_TL T
    SET (SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS) =
                     (SELECT
                      B.SHORT_DESCRIPTION,
                      B.DESCRIPTION,
                      B.COMMENTS
                      FROM
                      OKL_FEES_TL B
                      WHERE
                      B.ID = T.ID
                      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT
                                 SUBT.ID,
                                 SUBT.LANGUAGE
                                 FROM
                                 OKL_FEES_TL SUBB,
                                 OKL_FEES_TL SUBT
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

    INSERT INTO OKL_FEES_TL (
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
        FROM OKL_FEES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_FEES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;


  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_feev_rec IN feev_rec_type) RETURN feev_rec_type IS

    l_feev_rec  feev_rec_type;

  BEGIN

    l_feev_rec := p_feev_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_feev_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute_category := NULL;
    END IF;
    IF l_feev_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute1 := NULL;
    END IF;
    IF l_feev_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute2 := NULL;
    END IF;
    IF l_feev_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute3 := NULL;
    END IF;
    IF l_feev_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute4 := NULL;
    END IF;
    IF l_feev_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute5 := NULL;
    END IF;
    IF l_feev_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute6 := NULL;
    END IF;
    IF l_feev_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute7 := NULL;
    END IF;
    IF l_feev_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute8 := NULL;
    END IF;
    IF l_feev_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute9 := NULL;
    END IF;
    IF l_feev_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute10 := NULL;
    END IF;
    IF l_feev_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute11 := NULL;
    END IF;
    IF l_feev_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute12 := NULL;
    END IF;
    IF l_feev_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute13 := NULL;
    END IF;
    IF l_feev_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute14 := NULL;
    END IF;
    IF l_feev_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_feev_rec.attribute15 := NULL;
    END IF;
    IF l_feev_rec.parent_object_code = FND_API.G_MISS_CHAR THEN
      l_feev_rec.parent_object_code := NULL;
    END IF;
    IF l_feev_rec.parent_object_id = FND_API.G_MISS_NUM THEN
      l_feev_rec.parent_object_id := NULL;
    END IF;
    IF l_feev_rec.stream_type_id = FND_API.G_MISS_NUM THEN
      l_feev_rec.stream_type_id := NULL;
    END IF;
    IF l_feev_rec.fee_type = FND_API.G_MISS_CHAR THEN
      l_feev_rec.fee_type := NULL;
    END IF;
    IF l_feev_rec.structured_pricing = FND_API.G_MISS_CHAR THEN
      l_feev_rec.structured_pricing := NULL;
    END IF;
    IF l_feev_rec.rate_template_id = FND_API.G_MISS_NUM THEN
      l_feev_rec.rate_template_id := NULL;
    END IF;
    IF l_feev_rec.rate_card_id = FND_API.G_MISS_NUM THEN
      l_feev_rec.rate_card_id := NULL;
    END IF;
    IF l_feev_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
      l_feev_rec.lease_rate_factor := NULL;
    END IF;
    IF l_feev_rec.target_arrears = FND_API.G_MISS_CHAR THEN
      l_feev_rec.target_arrears := NULL;
    END IF;
    IF l_feev_rec.effective_from = FND_API.G_MISS_DATE THEN
      l_feev_rec.effective_from := NULL;
    END IF;
    IF l_feev_rec.effective_to = FND_API.G_MISS_DATE THEN
      l_feev_rec.effective_to := NULL;
    END IF;
    IF l_feev_rec.supplier_id = FND_API.G_MISS_NUM THEN
      l_feev_rec.supplier_id := NULL;
    END IF;
    IF l_feev_rec.rollover_quote_id = FND_API.G_MISS_NUM THEN
      l_feev_rec.rollover_quote_id := NULL;
    END IF;
    IF l_feev_rec.initial_direct_cost = FND_API.G_MISS_NUM THEN
      l_feev_rec.initial_direct_cost := NULL;
    END IF;
    IF l_feev_rec.fee_amount = FND_API.G_MISS_NUM THEN
      l_feev_rec.fee_amount := NULL;
    END IF;
    IF l_feev_rec.target_amount = FND_API.G_MISS_NUM THEN
       l_feev_rec.target_amount := NULL;
    END IF;
    IF l_feev_rec.target_frequency = FND_API.G_MISS_CHAR THEN
       l_feev_rec.target_frequency := NULL;
    END IF;
    IF l_feev_rec.short_description = FND_API.G_MISS_CHAR THEN
      l_feev_rec.short_description := NULL;
    END IF;
    IF l_feev_rec.description = FND_API.G_MISS_CHAR THEN
      l_feev_rec.description := NULL;
    END IF;
    IF l_feev_rec.comments = FND_API.G_MISS_CHAR THEN
      l_feev_rec.comments := NULL;
    END IF;
    IF l_feev_rec.payment_type_id = FND_API.G_MISS_NUM THEN
      l_feev_rec.payment_type_id := NULL;
    END IF;
    IF l_feev_rec.fee_purpose_code = FND_API.G_MISS_CHAR THEN
      l_feev_rec.fee_purpose_code := NULL;
    END IF;
    RETURN l_feev_rec;

  END null_out_defaults;


  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN feev_rec_type IS

    l_feev_rec           feev_rec_type;
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
      ,parent_object_code
      ,parent_object_id
      ,stream_type_id
      ,fee_type
      ,structured_pricing
      ,rate_template_id
      ,rate_card_id
      ,lease_rate_factor
      ,target_arrears
      ,effective_from
      ,effective_to
      ,supplier_id
      ,rollover_quote_id
      ,initial_direct_cost
      ,fee_amount
      ,target_amount
      ,target_frequency
      ,short_description
      ,description
      ,comments
      ,payment_type_id
      ,fee_purpose_code
    INTO
      l_feev_rec.id
      ,l_feev_rec.object_version_number
      ,l_feev_rec.attribute_category
      ,l_feev_rec.attribute1
      ,l_feev_rec.attribute2
      ,l_feev_rec.attribute3
      ,l_feev_rec.attribute4
      ,l_feev_rec.attribute5
      ,l_feev_rec.attribute6
      ,l_feev_rec.attribute7
      ,l_feev_rec.attribute8
      ,l_feev_rec.attribute9
      ,l_feev_rec.attribute10
      ,l_feev_rec.attribute11
      ,l_feev_rec.attribute12
      ,l_feev_rec.attribute13
      ,l_feev_rec.attribute14
      ,l_feev_rec.attribute15
      ,l_feev_rec.parent_object_code
      ,l_feev_rec.parent_object_id
      ,l_feev_rec.stream_type_id
      ,l_feev_rec.fee_type
      ,l_feev_rec.structured_pricing
      ,l_feev_rec.rate_template_id
      ,l_feev_rec.rate_card_id
      ,l_feev_rec.lease_rate_factor
      ,l_feev_rec.target_arrears
      ,l_feev_rec.effective_from
      ,l_feev_rec.effective_to
      ,l_feev_rec.supplier_id
      ,l_feev_rec.rollover_quote_id
      ,l_feev_rec.initial_direct_cost
      ,l_feev_rec.fee_amount
      ,l_feev_rec.target_amount
      ,l_feev_rec.target_frequency
      ,l_feev_rec.short_description
      ,l_feev_rec.description
      ,l_feev_rec.comments
      ,l_feev_rec.payment_type_id
      ,l_feev_rec.fee_purpose_code
    FROM OKL_FEES_V
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_feev_rec;

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


  -----------------------------------------
  -- PROCEDURE validate_parent_object_code
  -----------------------------------------
  PROCEDURE validate_parent_object_code (x_return_status OUT NOCOPY VARCHAR2, p_parent_object_code IN VARCHAR2) IS
  BEGIN
    IF p_parent_object_code IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'parent_object_code',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_parent_object_code;


  -----------------------------------------
  -- PROCEDURE validate_parent_object_id
  -----------------------------------------
  PROCEDURE validate_parent_object_id (x_return_status OUT NOCOPY VARCHAR2, p_parent_object_id IN NUMBER) IS
  BEGIN
    IF p_parent_object_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'parent_object_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_parent_object_id;


  -----------------------------------------
  -- PROCEDURE validate_stream_type_id
  -----------------------------------------
  PROCEDURE validate_stream_type_id (x_return_status OUT NOCOPY VARCHAR2, p_stream_type_id IN NUMBER) IS
  BEGIN
    IF p_stream_type_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'stream_type_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_stream_type_id;


  -----------------------------------------
  -- PROCEDURE validate_fee_type
  -----------------------------------------
  PROCEDURE validate_fee_type (x_return_status OUT NOCOPY VARCHAR2, p_fee_type IN VARCHAR2) IS
  BEGIN
    IF p_fee_type IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'fee_type',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_fee_type;


  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_feev_rec IN feev_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_feev_rec.id);
    validate_object_version_number (l_return_status, p_feev_rec.object_version_number);
    validate_parent_object_code (l_return_status, p_feev_rec.parent_object_code);
    validate_parent_object_id (l_return_status, p_feev_rec.parent_object_id);
    validate_stream_type_id (l_return_status, p_feev_rec.stream_type_id);
    validate_fee_type (l_return_status, p_feev_rec.fee_type);

    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_feev_rec IN feev_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    RETURN G_RET_STS_SUCCESS;
  END validate_record;


  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN feev_rec_type, p_to IN OUT NOCOPY fee_rec_type) IS

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
    p_to.parent_object_code             :=  p_from.parent_object_code;
    p_to.parent_object_id               :=  p_from.parent_object_id;
    p_to.stream_type_id                 :=  p_from.stream_type_id;
    p_to.fee_type                       :=  p_from.fee_type;
    p_to.structured_pricing             :=  p_from.structured_pricing;
    p_to.rate_template_id               :=  p_from.rate_template_id;
    p_to.rate_card_id                   :=  p_from.rate_card_id;
    p_to.lease_rate_factor              :=  p_from.lease_rate_factor;
    p_to.target_arrears                 :=  p_from.target_arrears;
    p_to.effective_from                 :=  p_from.effective_from;
    p_to.effective_to                   :=  p_from.effective_to;
    p_to.supplier_id                    :=  p_from.supplier_id;
    p_to.rollover_quote_id              :=  p_from.rollover_quote_id;
    p_to.initial_direct_cost            :=  p_from.initial_direct_cost;
    p_to.fee_amount                     :=  p_from.fee_amount;
    p_to.target_amount                  :=  p_from.target_amount;
    p_to.target_frequency               :=  p_from.target_frequency;
    p_to.payment_type_id                :=  p_from.payment_type_id;
    p_to.fee_purpose_code               :=  p_from.fee_purpose_code;
  END migrate;


  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN feev_rec_type, p_to IN OUT NOCOPY feetl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
  END migrate;


  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_fee_rec IN fee_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_fees_b (
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
      ,parent_object_code
      ,parent_object_id
      ,stream_type_id
      ,fee_type
      ,structured_pricing
      ,rate_template_id
      ,rate_card_id
      ,lease_rate_factor
      ,target_arrears
      ,effective_from
      ,effective_to
      ,supplier_id
      ,rollover_quote_id
      ,initial_direct_cost
      ,fee_amount
      ,target_amount
      ,target_frequency
      ,payment_type_id
      ,fee_purpose_code
      )
    VALUES
      (
       p_fee_rec.id
      ,p_fee_rec.object_version_number
      ,p_fee_rec.attribute_category
      ,p_fee_rec.attribute1
      ,p_fee_rec.attribute2
      ,p_fee_rec.attribute3
      ,p_fee_rec.attribute4
      ,p_fee_rec.attribute5
      ,p_fee_rec.attribute6
      ,p_fee_rec.attribute7
      ,p_fee_rec.attribute8
      ,p_fee_rec.attribute9
      ,p_fee_rec.attribute10
      ,p_fee_rec.attribute11
      ,p_fee_rec.attribute12
      ,p_fee_rec.attribute13
      ,p_fee_rec.attribute14
      ,p_fee_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_fee_rec.parent_object_code
      ,p_fee_rec.parent_object_id
      ,p_fee_rec.stream_type_id
      ,p_fee_rec.fee_type
      ,p_fee_rec.structured_pricing
      ,p_fee_rec.rate_template_id
      ,p_fee_rec.rate_card_id
      ,p_fee_rec.lease_rate_factor
      ,p_fee_rec.target_arrears
      ,p_fee_rec.effective_from
      ,p_fee_rec.effective_to
      ,p_fee_rec.supplier_id
      ,p_fee_rec.rollover_quote_id
      ,p_fee_rec.initial_direct_cost
      ,p_fee_rec.fee_amount
      ,p_fee_rec.target_amount
      ,p_fee_rec.target_frequency
      ,p_fee_rec.payment_type_id
      ,p_fee_rec.fee_purpose_code
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
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_feetl_rec IN feetl_rec_type) IS

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

      INSERT INTO OKL_FEES_TL (
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
        p_feetl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_feetl_rec.short_description
       ,p_feetl_rec.description
       ,p_feetl_rec.comments);

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
    p_feev_rec                     IN feev_rec_type,
    x_feev_rec                     OUT NOCOPY feev_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_feev_rec                     feev_rec_type;
    l_fee_rec                      fee_rec_type;
    l_feetl_rec                    feetl_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_feev_rec                       := null_out_defaults (p_feev_rec);

    SELECT okl_fee_seq.nextval INTO l_feev_rec.ID FROM DUAL;

    l_feev_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_feev_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_feev_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_feev_rec, l_fee_rec);
    migrate (l_feev_rec, l_feetl_rec);

    insert_row (x_return_status => l_return_status, p_fee_rec => l_fee_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_feetl_rec => l_feetl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_feev_rec      := l_feev_rec;
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
    p_feev_rec                     IN feev_rec_type,
    x_feev_rec                     OUT NOCOPY feev_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_feev_rec                     => p_feev_rec,
                x_feev_rec                     => x_feev_rec);

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
    p_feev_tbl                     IN feev_tbl_type,
    x_feev_tbl                     OUT NOCOPY feev_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_feev_tbl.COUNT > 0) THEN
      i := p_feev_tbl.FIRST;
      LOOP
        IF p_feev_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_feev_rec                     => p_feev_tbl(i),
                      x_feev_rec                     => x_feev_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_feev_tbl.LAST);
          i := p_feev_tbl.NEXT(i);

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
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_fee_rec IN fee_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FEES_B
     WHERE ID = p_fee_rec.id
       AND OBJECT_VERSION_NUMBER = p_fee_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FEES_B
     WHERE ID = p_fee_rec.id;

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

      ELSIF lc_object_version_number <> p_fee_rec.object_version_number THEN

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_fee_rec IN fee_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_fee_rec => p_fee_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_fees_b
    SET
      object_version_number = p_fee_rec.object_version_number+1
      ,attribute_category = p_fee_rec.attribute_category
      ,attribute1 = p_fee_rec.attribute1
      ,attribute2 = p_fee_rec.attribute2
      ,attribute3 = p_fee_rec.attribute3
      ,attribute4 = p_fee_rec.attribute4
      ,attribute5 = p_fee_rec.attribute5
      ,attribute6 = p_fee_rec.attribute6
      ,attribute7 = p_fee_rec.attribute7
      ,attribute8 = p_fee_rec.attribute8
      ,attribute9 = p_fee_rec.attribute9
      ,attribute10 = p_fee_rec.attribute10
      ,attribute11 = p_fee_rec.attribute11
      ,attribute12 = p_fee_rec.attribute12
      ,attribute13 = p_fee_rec.attribute13
      ,attribute14 = p_fee_rec.attribute14
      ,attribute15 = p_fee_rec.attribute15
      ,parent_object_code = p_fee_rec.parent_object_code
      ,parent_object_id = p_fee_rec.parent_object_id
      ,stream_type_id = p_fee_rec.stream_type_id
      ,fee_type = p_fee_rec.fee_type
      ,structured_pricing = p_fee_rec.structured_pricing
      ,rate_template_id = p_fee_rec.rate_template_id
      ,rate_card_id = p_fee_rec.rate_card_id
      ,lease_rate_factor = p_fee_rec.lease_rate_factor
      ,target_arrears = p_fee_rec.target_arrears
      ,effective_from = p_fee_rec.effective_from
      ,effective_to = p_fee_rec.effective_to
      ,supplier_id = p_fee_rec.supplier_id
      ,rollover_quote_id = p_fee_rec.rollover_quote_id
      ,initial_direct_cost = p_fee_rec.initial_direct_cost
      ,fee_amount = p_fee_rec.fee_amount
      ,target_amount = p_fee_rec.target_amount
      ,target_frequency = p_fee_rec.target_frequency
      ,payment_type_id = p_fee_rec.payment_type_id
      ,fee_purpose_code = p_fee_rec.fee_purpose_code
    WHERE id = p_fee_rec.id;

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_feetl_rec IN feetl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_FEES_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_feetl_rec.short_description
      ,description = p_feetl_rec.description
      ,comments = p_feetl_rec.comments
    WHERE ID = p_feetl_rec.id;

    UPDATE OKL_FEES_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_feetl_rec.id
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
    p_feev_rec                     IN feev_rec_type,
    x_feev_rec                     OUT NOCOPY feev_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_feev_rec                     feev_rec_type;
    l_fee_rec                      fee_rec_type;
    l_feetl_rec                    feetl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_feev_rec IN  feev_rec_type,
                                  x_feev_rec OUT NOCOPY feev_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61)          := G_PKG_NAME||'.populate_new_record';
      l_return_status      VARCHAR2(1);
      l_db_feev_rec        feev_rec_type;

    BEGIN

      x_feev_rec    := p_feev_rec;
      l_db_feev_rec := get_rec (p_feev_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_feev_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute_category := l_db_feev_rec.attribute_category;
      END IF;
      IF x_feev_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute1 := l_db_feev_rec.attribute1;
      END IF;
      IF x_feev_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute2 := l_db_feev_rec.attribute2;
      END IF;
      IF x_feev_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute3 := l_db_feev_rec.attribute3;
      END IF;
      IF x_feev_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute4 := l_db_feev_rec.attribute4;
      END IF;
      IF x_feev_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute5 := l_db_feev_rec.attribute5;
      END IF;
      IF x_feev_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute6 := l_db_feev_rec.attribute6;
      END IF;
      IF x_feev_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute7 := l_db_feev_rec.attribute7;
      END IF;
      IF x_feev_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute8 := l_db_feev_rec.attribute8;
      END IF;
      IF x_feev_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute9 := l_db_feev_rec.attribute9;
      END IF;
      IF x_feev_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute10 := l_db_feev_rec.attribute10;
      END IF;
      IF x_feev_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute11 := l_db_feev_rec.attribute11;
      END IF;
      IF x_feev_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute12 := l_db_feev_rec.attribute12;
      END IF;
      IF x_feev_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute13 := l_db_feev_rec.attribute13;
      END IF;
      IF x_feev_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute14 := l_db_feev_rec.attribute14;
      END IF;
      IF x_feev_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        x_feev_rec.attribute15 := l_db_feev_rec.attribute15;
      END IF;
      IF x_feev_rec.parent_object_code = FND_API.G_MISS_CHAR THEN
        x_feev_rec.parent_object_code := l_db_feev_rec.parent_object_code;
      END IF;
      IF x_feev_rec.parent_object_id = FND_API.G_MISS_NUM THEN
        x_feev_rec.parent_object_id := l_db_feev_rec.parent_object_id;
      END IF;
      IF x_feev_rec.stream_type_id = FND_API.G_MISS_NUM THEN
        x_feev_rec.stream_type_id := l_db_feev_rec.stream_type_id;
      END IF;
      IF x_feev_rec.fee_type = FND_API.G_MISS_CHAR THEN
        x_feev_rec.fee_type := l_db_feev_rec.fee_type;
      END IF;
      IF x_feev_rec.structured_pricing = FND_API.G_MISS_CHAR THEN
        x_feev_rec.structured_pricing := l_db_feev_rec.structured_pricing;
      END IF;
      IF x_feev_rec.rate_template_id = FND_API.G_MISS_NUM THEN
        x_feev_rec.rate_template_id := l_db_feev_rec.rate_template_id;
      END IF;
      IF x_feev_rec.rate_card_id = FND_API.G_MISS_NUM THEN
        x_feev_rec.rate_card_id := l_db_feev_rec.rate_card_id;
      END IF;
      IF x_feev_rec.lease_rate_factor = FND_API.G_MISS_NUM THEN
        x_feev_rec.lease_rate_factor := l_db_feev_rec.lease_rate_factor;
      END IF;
      IF x_feev_rec.target_arrears = FND_API.G_MISS_CHAR THEN
        x_feev_rec.target_arrears := l_db_feev_rec.target_arrears;
      END IF;
      IF x_feev_rec.effective_from = FND_API.G_MISS_DATE THEN
        x_feev_rec.effective_from := l_db_feev_rec.effective_from;
      END IF;
      IF x_feev_rec.effective_to = FND_API.G_MISS_DATE THEN
        x_feev_rec.effective_to := l_db_feev_rec.effective_to;
      END IF;
      IF x_feev_rec.supplier_id = FND_API.G_MISS_NUM THEN
        x_feev_rec.supplier_id := l_db_feev_rec.supplier_id;
      END IF;
      IF x_feev_rec.rollover_quote_id = FND_API.G_MISS_NUM THEN
        x_feev_rec.rollover_quote_id := l_db_feev_rec.rollover_quote_id;
      END IF;
      IF x_feev_rec.initial_direct_cost = FND_API.G_MISS_NUM THEN
        x_feev_rec.initial_direct_cost := l_db_feev_rec.initial_direct_cost;
      END IF;
      IF x_feev_rec.fee_amount = FND_API.G_MISS_NUM THEN
        x_feev_rec.fee_amount := l_db_feev_rec.fee_amount;
      END IF;
      IF x_feev_rec.target_amount = FND_API.G_MISS_NUM THEN
        x_feev_rec.target_amount := l_db_feev_rec.target_amount;
      END IF;
      IF x_feev_rec.target_frequency = FND_API.G_MISS_CHAR THEN
        x_feev_rec.target_frequency := l_db_feev_rec.target_frequency;
      END IF;
      IF x_feev_rec.short_description = FND_API.G_MISS_CHAR THEN
        x_feev_rec.short_description := l_db_feev_rec.short_description;
      END IF;
      IF x_feev_rec.description = FND_API.G_MISS_CHAR THEN
        x_feev_rec.description := l_db_feev_rec.description;
      END IF;
      IF x_feev_rec.comments = FND_API.G_MISS_CHAR THEN
        x_feev_rec.comments := l_db_feev_rec.comments;
      END IF;
      IF x_feev_rec.payment_type_id = FND_API.G_MISS_NUM THEN
        x_feev_rec.payment_type_id := l_db_feev_rec.payment_type_id;
      END IF;
      IF x_feev_rec.fee_purpose_code = FND_API.G_MISS_CHAR THEN
        x_feev_rec.fee_purpose_code := l_db_feev_rec.fee_purpose_code;
      END IF;

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

    l_return_status := populate_new_record (p_feev_rec, l_feev_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_feev_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_feev_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_feev_rec, l_fee_rec);
    migrate (l_feev_rec, l_feetl_rec);

    update_row (x_return_status => l_return_status, p_fee_rec => l_fee_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_feetl_rec => l_feetl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_feev_rec      := l_feev_rec;

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
    p_feev_rec                     IN feev_rec_type,
    x_feev_rec                     OUT NOCOPY feev_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_feev_rec                     => p_feev_rec,
                x_feev_rec                     => x_feev_rec);

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
    p_feev_tbl                     IN feev_tbl_type,
    x_feev_tbl                     OUT NOCOPY feev_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_feev_tbl := p_feev_tbl;

    IF (p_feev_tbl.COUNT > 0) THEN

      i := p_feev_tbl.FIRST;

      LOOP

        IF p_feev_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_feev_rec                     => p_feev_tbl(i),
                      x_feev_rec                     => x_feev_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_feev_tbl.LAST);
          i := p_feev_tbl.NEXT(i);

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

    DELETE FROM OKL_FEES_B WHERE id = p_id;
    DELETE FROM OKL_FEES_TL WHERE id = p_id;

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
    p_feev_rec                     IN feev_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_feev_rec.id);

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
    p_feev_tbl                     IN feev_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_feev_tbl.COUNT > 0) THEN

      i := p_feev_tbl.FIRST;

      LOOP

        IF p_feev_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_feev_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_feev_tbl.LAST);
          i := p_feev_tbl.NEXT(i);

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


END OKL_FEE_PVT;

/
