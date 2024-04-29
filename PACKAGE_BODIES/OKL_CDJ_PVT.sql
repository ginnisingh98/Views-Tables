--------------------------------------------------------
--  DDL for Package Body OKL_CDJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CDJ_PVT" AS
/* $Header: OKLSCDJB.pls 120.3 2006/04/20 13:43:56 ssdeshpa noship $ */

  -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_INSURANCE_ESTIMATES_TL T
    WHERE NOT EXISTS (SELECT NULL FROM OKL_COST_ADJUSTMENTS_B B WHERE B.ID =T.ID);

    UPDATE OKL_COST_ADJUSTMENTS_TL T
    SET (SHORT_DESCRIPTION,
        DESCRIPTION,
        COMMENTS) =
                     (SELECT
                      B.SHORT_DESCRIPTION,
                      B.DESCRIPTION,
                      B.COMMENTS
                      FROM
                      OKL_COST_ADJUSTMENTS_TL B
                      WHERE
                      B.ID = T.ID
                      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT
                                 SUBT.ID,
                                 SUBT.LANGUAGE
                                 FROM
                                 OKL_COST_ADJUSTMENTS_TL SUBB,
                                 OKL_COST_ADJUSTMENTS_TL SUBT
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

    INSERT INTO OKL_COST_ADJUSTMENTS_TL (
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
        FROM OKL_COST_ADJUSTMENTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_COST_ADJUSTMENTS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;


  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_cdjv_rec IN cdjv_rec_type) RETURN cdjv_rec_type IS

    l_cdjv_rec  cdjv_rec_type;

  BEGIN

    l_cdjv_rec := p_cdjv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_cdjv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute_category := NULL;
    END IF;
    IF l_cdjv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute1 := NULL;
    END IF;
    IF l_cdjv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute2 := NULL;
    END IF;
    IF l_cdjv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute3 := NULL;
    END IF;
    IF l_cdjv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute4 := NULL;
    END IF;
    IF l_cdjv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute5 := NULL;
    END IF;
    IF l_cdjv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute6 := NULL;
    END IF;
    IF l_cdjv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute7 := NULL;
    END IF;
    IF l_cdjv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute8 := NULL;
    END IF;
    IF l_cdjv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute9 := NULL;
    END IF;
    IF l_cdjv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute10 := NULL;
    END IF;
    IF l_cdjv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute11 := NULL;
    END IF;
    IF l_cdjv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute12 := NULL;
    END IF;
    IF l_cdjv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute13 := NULL;
    END IF;
    IF l_cdjv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute14 := NULL;
    END IF;
    IF l_cdjv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.attribute15 := NULL;
    END IF;
    IF l_cdjv_rec.parent_object_code = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.parent_object_code := NULL;
    END IF;
    IF l_cdjv_rec.parent_object_id = FND_API.G_MISS_NUM THEN
      l_cdjv_rec.parent_object_id := NULL;
    END IF;
    IF l_cdjv_rec.adjustment_source_type = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.adjustment_source_type := NULL;
    END IF;
    IF l_cdjv_rec.adjustment_source_id = FND_API.G_MISS_NUM THEN
      l_cdjv_rec.adjustment_source_id := NULL;
    END IF;
    IF l_cdjv_rec.basis = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.basis := NULL;
    END IF;
    IF l_cdjv_rec.value = FND_API.G_MISS_NUM THEN
      l_cdjv_rec.value := NULL;
    END IF;
    IF l_cdjv_rec.processing_type = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.processing_type := NULL;
    END IF;
    IF l_cdjv_rec.supplier_id = FND_API.G_MISS_NUM THEN
      l_cdjv_rec.supplier_id := NULL;
    END IF;
    IF l_cdjv_rec.default_subsidy_amount = FND_API.G_MISS_NUM THEN
      l_cdjv_rec.default_subsidy_amount := NULL;
    END IF;
    IF l_cdjv_rec.short_description = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.short_description := NULL;
    END IF;
    IF l_cdjv_rec.description = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.description := NULL;
    END IF;
    IF l_cdjv_rec.comments = FND_API.G_MISS_CHAR THEN
      l_cdjv_rec.comments := NULL;
    END IF;
    IF l_cdjv_rec.percent_basis_value = FND_API.G_MISS_NUM THEN
      l_cdjv_rec.percent_basis_value := NULL;
    END IF;
    --Bug # 5142940 ssdeshpa start
    --added new column stream_type_id
    IF l_cdjv_rec.stream_type_id = FND_API.G_MISS_NUM THEN
      l_cdjv_rec.stream_type_id := NULL;
    END IF;
    --Bug # 5142940 ssdeshpa end;
    RETURN l_cdjv_rec;

  END null_out_defaults;


  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN cdjv_rec_type IS

    l_cdjv_rec           cdjv_rec_type;
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
      ,adjustment_source_type
      ,adjustment_source_id
      ,basis
      ,value
      ,processing_type
      ,supplier_id
      ,default_subsidy_amount
      ,short_description
      ,description
      ,comments
      ,percent_basis_value
      --Bug # 5142940 ssdeshpa start
      ,stream_type_id
      --Bug # 5142940 ssdeshpa end;
    INTO
      l_cdjv_rec.id
      ,l_cdjv_rec.object_version_number
      ,l_cdjv_rec.attribute_category
      ,l_cdjv_rec.attribute1
      ,l_cdjv_rec.attribute2
      ,l_cdjv_rec.attribute3
      ,l_cdjv_rec.attribute4
      ,l_cdjv_rec.attribute5
      ,l_cdjv_rec.attribute6
      ,l_cdjv_rec.attribute7
      ,l_cdjv_rec.attribute8
      ,l_cdjv_rec.attribute9
      ,l_cdjv_rec.attribute10
      ,l_cdjv_rec.attribute11
      ,l_cdjv_rec.attribute12
      ,l_cdjv_rec.attribute13
      ,l_cdjv_rec.attribute14
      ,l_cdjv_rec.attribute15
      ,l_cdjv_rec.parent_object_code
      ,l_cdjv_rec.parent_object_id
      ,l_cdjv_rec.adjustment_source_type
      ,l_cdjv_rec.adjustment_source_id
      ,l_cdjv_rec.basis
      ,l_cdjv_rec.value
      ,l_cdjv_rec.processing_type
      ,l_cdjv_rec.supplier_id
      ,l_cdjv_rec.default_subsidy_amount
      ,l_cdjv_rec.short_description
      ,l_cdjv_rec.description
      ,l_cdjv_rec.comments
      ,l_cdjv_rec.percent_basis_value
      --Bug # 5142940 ssdeshpa start
      ,l_cdjv_rec.stream_type_id
      --Bug # 5142940 ssdeshpa end;
    FROM OKL_COST_ADJUSTMENTS_V
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_cdjv_rec;

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


  --------------------------------------
  -- PROCEDURE validate_adj_source_type
  --------------------------------------
  PROCEDURE validate_adj_source_type (x_return_status OUT NOCOPY VARCHAR2, p_adj_source_type IN VARCHAR2) IS
  BEGIN
    IF p_adj_source_type IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'adj_source_type',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_adj_source_type;


   --Bug # 5142940 ssdeshpa start
  --------------------------------------
  -- PROCEDURE validate_adj_stream_type_id
  --------------------------------------
  PROCEDURE validate_adj_stream_type (x_return_status OUT NOCOPY VARCHAR2, p_adj_rec IN cdjv_rec_type) IS
  BEGIN
  IF(p_adj_rec.processing_type IS NOT NULL) THEN
    IF p_adj_rec.processing_type='BILL' AND p_adj_rec.stream_type_id IS NULL  THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_STRM_TYPE_ID_REQUIRED');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF p_adj_rec.processing_type='CAPITALIZE' AND p_adj_rec.stream_type_id IS NOT NULL  THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_STRM_TYPE_ID_NOT_REQUIRED');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_adj_stream_type;
  --Bug # 5142940 ssdeshpa start
  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_cdjv_rec IN cdjv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_cdjv_rec.id);
    validate_object_version_number (l_return_status, p_cdjv_rec.object_version_number);
    validate_parent_object_code (l_return_status, p_cdjv_rec.parent_object_code);
    validate_parent_object_id (l_return_status, p_cdjv_rec.parent_object_id);
    validate_adj_source_type (l_return_status, p_cdjv_rec.adjustment_source_type);
    --Bug # 5142940 ssdeshpa start
    validate_adj_stream_type(l_return_status,p_cdjv_rec);
    --Bug # 5142940 ssdeshpa start
    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_cdjv_rec IN cdjv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    IF p_cdjv_rec.basis = 'ASSET_COST' AND ( p_cdjv_rec.percent_basis_value < 0 OR p_cdjv_rec.percent_basis_value > 100 )THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_PERCENT_BASIS_INVALID');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    RETURN G_RET_STS_SUCCESS;
  END validate_record;


  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN cdjv_rec_type, p_to IN OUT NOCOPY cdj_rec_type) IS

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
    p_to.adjustment_source_type         :=  p_from.adjustment_source_type;
    p_to.adjustment_source_id           :=  p_from.adjustment_source_id;
    p_to.basis                          :=  p_from.basis;
    p_to.value                          :=  p_from.value;
    p_to.processing_type                :=  p_from.processing_type;
    p_to.supplier_id                    :=  p_from.supplier_id;
    p_to.default_subsidy_amount         :=  p_from.default_subsidy_amount;
    p_to.percent_basis_value            :=  p_from.percent_basis_value;
    --Bug # 5142940 ssdeshpa start
    p_to.stream_type_id                 :=  p_from.stream_type_id;
    --Bug # 5142940 ssdeshpa start
  END migrate;


  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN cdjv_rec_type, p_to IN OUT NOCOPY cdjtl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
    p_to.description := p_from.description;
    p_to.comments := p_from.comments;
  END migrate;


  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_cdj_rec IN cdj_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_cost_adjustments_b (
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
      ,adjustment_source_type
      ,adjustment_source_id
      ,basis
      ,value
      ,processing_type
      ,supplier_id
      ,default_subsidy_amount
      ,percent_basis_value
      --Bug # 5142940 ssdeshpa start
      ,stream_type_id
      --Bug # 5142940 ssdeshpa start
      )
    VALUES
      (
       p_cdj_rec.id
      ,p_cdj_rec.object_version_number
      ,p_cdj_rec.attribute_category
      ,p_cdj_rec.attribute1
      ,p_cdj_rec.attribute2
      ,p_cdj_rec.attribute3
      ,p_cdj_rec.attribute4
      ,p_cdj_rec.attribute5
      ,p_cdj_rec.attribute6
      ,p_cdj_rec.attribute7
      ,p_cdj_rec.attribute8
      ,p_cdj_rec.attribute9
      ,p_cdj_rec.attribute10
      ,p_cdj_rec.attribute11
      ,p_cdj_rec.attribute12
      ,p_cdj_rec.attribute13
      ,p_cdj_rec.attribute14
      ,p_cdj_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_cdj_rec.parent_object_code
      ,p_cdj_rec.parent_object_id
      ,p_cdj_rec.adjustment_source_type
      ,p_cdj_rec.adjustment_source_id
      ,p_cdj_rec.basis
      ,p_cdj_rec.value
      ,p_cdj_rec.processing_type
      ,p_cdj_rec.supplier_id
      ,p_cdj_rec.default_subsidy_amount
      ,p_cdj_rec.percent_basis_value
      --Bug # 5142940 ssdeshpa start
      ,p_cdj_rec.stream_type_id
      --Bug # 5142940 ssdeshpa start
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
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_cdjtl_rec IN cdjtl_rec_type) IS

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

      INSERT INTO OKL_COST_ADJUSTMENTS_TL (
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
        p_cdjtl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_cdjtl_rec.short_description
       ,p_cdjtl_rec.description
       ,p_cdjtl_rec.comments);

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
    p_cdjv_rec                     IN cdjv_rec_type,
    x_cdjv_rec                     OUT NOCOPY cdjv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_cdjv_rec                     cdjv_rec_type;
    l_cdj_rec                      cdj_rec_type;
    l_cdjtl_rec                    cdjtl_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_cdjv_rec                       := null_out_defaults (p_cdjv_rec);

    SELECT okl_cdj_seq.nextval INTO l_cdjv_rec.ID FROM DUAL;

    l_cdjv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_cdjv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_cdjv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_cdjv_rec, l_cdj_rec);
    migrate (l_cdjv_rec, l_cdjtl_rec);

    insert_row (x_return_status => l_return_status, p_cdj_rec => l_cdj_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_cdjtl_rec => l_cdjtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_cdjv_rec      := l_cdjv_rec;
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
    p_cdjv_rec                     IN cdjv_rec_type,
    x_cdjv_rec                     OUT NOCOPY cdjv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_cdjv_rec                     => p_cdjv_rec,
                x_cdjv_rec                     => x_cdjv_rec);

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
    p_cdjv_tbl                     IN cdjv_tbl_type,
    x_cdjv_tbl                     OUT NOCOPY cdjv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_cdjv_tbl.COUNT > 0) THEN
      i := p_cdjv_tbl.FIRST;
      LOOP
        IF p_cdjv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_cdjv_rec                     => p_cdjv_tbl(i),
                      x_cdjv_rec                     => x_cdjv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_cdjv_tbl.LAST);
          i := p_cdjv_tbl.NEXT(i);

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
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_cdj_rec IN cdj_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_COST_ADJUSTMENTS_B
     WHERE ID = p_cdj_rec.id
       AND OBJECT_VERSION_NUMBER = p_cdj_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_COST_ADJUSTMENTS_B
     WHERE ID = p_cdj_rec.id;

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

      ELSIF lc_object_version_number <> p_cdj_rec.object_version_number THEN

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_cdj_rec IN cdj_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_cdj_rec => p_cdj_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_cost_adjustments_b
    SET
      object_version_number = p_cdj_rec.object_version_number+1
      ,attribute_category = p_cdj_rec.attribute_category
      ,attribute1 = p_cdj_rec.attribute1
      ,attribute2 = p_cdj_rec.attribute2
      ,attribute3 = p_cdj_rec.attribute3
      ,attribute4 = p_cdj_rec.attribute4
      ,attribute5 = p_cdj_rec.attribute5
      ,attribute6 = p_cdj_rec.attribute6
      ,attribute7 = p_cdj_rec.attribute7
      ,attribute8 = p_cdj_rec.attribute8
      ,attribute9 = p_cdj_rec.attribute9
      ,attribute10 = p_cdj_rec.attribute10
      ,attribute11 = p_cdj_rec.attribute11
      ,attribute12 = p_cdj_rec.attribute12
      ,attribute13 = p_cdj_rec.attribute13
      ,attribute14 = p_cdj_rec.attribute14
      ,attribute15 = p_cdj_rec.attribute15
      ,parent_object_code = p_cdj_rec.parent_object_code
      ,parent_object_id = p_cdj_rec.parent_object_id
      ,adjustment_source_type = p_cdj_rec.adjustment_source_type
      ,adjustment_source_id = p_cdj_rec.adjustment_source_id
      ,basis = p_cdj_rec.basis
      ,value = p_cdj_rec.value
      ,processing_type = p_cdj_rec.processing_type
      ,supplier_id = p_cdj_rec.supplier_id
      ,default_subsidy_amount = p_cdj_rec.default_subsidy_amount
      ,percent_basis_value = p_cdj_rec.percent_basis_value
      --Bug # 5142940 ssdeshpa start
      ,stream_type_id = p_cdj_rec.stream_type_id
      --Bug # 5142940 ssdeshpa start

    WHERE id = p_cdj_rec.id;

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_cdjtl_rec IN cdjtl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_COST_ADJUSTMENTS_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_cdjtl_rec.short_description
      ,description = p_cdjtl_rec.description
      ,comments = p_cdjtl_rec.comments
    WHERE ID = p_cdjtl_rec.id;

    UPDATE OKL_COST_ADJUSTMENTS_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_cdjtl_rec.id
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
    p_cdjv_rec                     IN cdjv_rec_type,
    x_cdjv_rec                     OUT NOCOPY cdjv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_cdjv_rec                     cdjv_rec_type;
    l_cdj_rec                      cdj_rec_type;
    l_cdjtl_rec                    cdjtl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_cdjv_rec IN  cdjv_rec_type,
                                  x_cdjv_rec OUT NOCOPY cdjv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61);
      l_return_status      VARCHAR2(1);
      l_db_cdjv_rec        cdjv_rec_type;

    BEGIN

      l_prog_name := G_PKG_NAME||'.populate_new_record';

      x_cdjv_rec    := p_cdjv_rec;
      l_db_cdjv_rec := get_rec (p_cdjv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_cdjv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute_category := l_db_cdjv_rec.attribute_category;
      END IF;
      IF x_cdjv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute1 := l_db_cdjv_rec.attribute1;
      END IF;
      IF x_cdjv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute2 := l_db_cdjv_rec.attribute2;
      END IF;
      IF x_cdjv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute3 := l_db_cdjv_rec.attribute3;
      END IF;
      IF x_cdjv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute4 := l_db_cdjv_rec.attribute4;
      END IF;
      IF x_cdjv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute5 := l_db_cdjv_rec.attribute5;
      END IF;
      IF x_cdjv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute6 := l_db_cdjv_rec.attribute6;
      END IF;
      IF x_cdjv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute7 := l_db_cdjv_rec.attribute7;
      END IF;
      IF x_cdjv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute8 := l_db_cdjv_rec.attribute8;
      END IF;
      IF x_cdjv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute9 := l_db_cdjv_rec.attribute9;
      END IF;
      IF x_cdjv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute10 := l_db_cdjv_rec.attribute10;
      END IF;
      IF x_cdjv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute11 := l_db_cdjv_rec.attribute11;
      END IF;
      IF x_cdjv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute12 := l_db_cdjv_rec.attribute12;
      END IF;
      IF x_cdjv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute13 := l_db_cdjv_rec.attribute13;
      END IF;
      IF x_cdjv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute14 := l_db_cdjv_rec.attribute14;
      END IF;
      IF x_cdjv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.attribute15 := l_db_cdjv_rec.attribute15;
      END IF;
      IF x_cdjv_rec.parent_object_code = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.parent_object_code := l_db_cdjv_rec.parent_object_code;
      END IF;
      IF x_cdjv_rec.parent_object_id = FND_API.G_MISS_NUM THEN
        x_cdjv_rec.parent_object_id := l_db_cdjv_rec.parent_object_id;
      END IF;
      IF x_cdjv_rec.adjustment_source_type = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.adjustment_source_type := l_db_cdjv_rec.adjustment_source_type;
      END IF;
      IF x_cdjv_rec.adjustment_source_id = FND_API.G_MISS_NUM THEN
        x_cdjv_rec.adjustment_source_id := l_db_cdjv_rec.adjustment_source_id;
      END IF;
      IF x_cdjv_rec.basis = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.basis := l_db_cdjv_rec.basis;
      END IF;
      IF x_cdjv_rec.value = FND_API.G_MISS_NUM THEN
        x_cdjv_rec.value := l_db_cdjv_rec.value;
      END IF;
      IF x_cdjv_rec.processing_type = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.processing_type := l_db_cdjv_rec.processing_type;
      END IF;
      IF x_cdjv_rec.supplier_id = FND_API.G_MISS_NUM THEN
        x_cdjv_rec.supplier_id := l_db_cdjv_rec.supplier_id;
      END IF;
      IF x_cdjv_rec.default_subsidy_amount = FND_API.G_MISS_NUM THEN
        x_cdjv_rec.default_subsidy_amount := l_db_cdjv_rec.default_subsidy_amount;
      END IF;
      IF x_cdjv_rec.short_description = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.short_description := l_db_cdjv_rec.short_description;
      END IF;
      IF x_cdjv_rec.description = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.description := l_db_cdjv_rec.description;
      END IF;
      IF x_cdjv_rec.comments = FND_API.G_MISS_CHAR THEN
        x_cdjv_rec.comments := l_db_cdjv_rec.comments;
      END IF;
      IF x_cdjv_rec.percent_basis_value = FND_API.G_MISS_NUM THEN
        x_cdjv_rec.percent_basis_value := l_db_cdjv_rec.percent_basis_value;
      END IF;
      --Bug # 5142940 ssdeshpa start
      IF x_cdjv_rec.stream_type_id = FND_API.G_MISS_NUM THEN
        x_cdjv_rec.stream_type_id := l_db_cdjv_rec.stream_type_id;
      END IF;
       --Bug # 5142940 ssdeshpa end;
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

    l_return_status := populate_new_record (p_cdjv_rec, l_cdjv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_cdjv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_cdjv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_cdjv_rec, l_cdj_rec);
    migrate (l_cdjv_rec, l_cdjtl_rec);

    update_row (x_return_status => l_return_status, p_cdj_rec => l_cdj_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_cdjtl_rec => l_cdjtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_cdjv_rec      := l_cdjv_rec;

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
    p_cdjv_rec                     IN cdjv_rec_type,
    x_cdjv_rec                     OUT NOCOPY cdjv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_cdjv_rec                     => p_cdjv_rec,
                x_cdjv_rec                     => x_cdjv_rec);

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
    p_cdjv_tbl                     IN cdjv_tbl_type,
    x_cdjv_tbl                     OUT NOCOPY cdjv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_cdjv_tbl := p_cdjv_tbl;

    IF (p_cdjv_tbl.COUNT > 0) THEN

      i := p_cdjv_tbl.FIRST;

      LOOP

        IF p_cdjv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_cdjv_rec                     => p_cdjv_tbl(i),
                      x_cdjv_rec                     => x_cdjv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_cdjv_tbl.LAST);
          i := p_cdjv_tbl.NEXT(i);

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

    DELETE FROM OKL_COST_ADJUSTMENTS_B WHERE id = p_id;
    DELETE FROM OKL_COST_ADJUSTMENTS_TL WHERE id = p_id;

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
    p_cdjv_rec                     IN cdjv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_cdjv_rec.id);

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
    p_cdjv_tbl                     IN cdjv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_cdjv_tbl.COUNT > 0) THEN

      i := p_cdjv_tbl.FIRST;

      LOOP

        IF p_cdjv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_cdjv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_cdjv_tbl.LAST);
          i := p_cdjv_tbl.NEXT(i);

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


END OKL_CDJ_PVT;

/
