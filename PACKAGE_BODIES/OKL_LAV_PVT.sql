--------------------------------------------------------
--  DDL for Package Body OKL_LAV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LAV_PVT" AS
  /* $Header: OKLSLAVB.pls 120.2 2005/10/19 11:54:00 varangan noship $ */

  -------------------------
  -- PROCEDURE add_language
  -------------------------
  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_LEASEAPP_TEMPL_VERSIONS_TL T
    WHERE NOT EXISTS (SELECT NULL FROM OKL_LEASEAPP_TEMPL_VERSIONS_B B WHERE B.ID =T.ID);

    UPDATE OKL_LEASEAPP_TEMPL_VERSIONS_TL T
    SET (SHORT_DESCRIPTION) =
                     (SELECT
                      B.SHORT_DESCRIPTION
                      FROM
                      OKL_LEASEAPP_TEMPL_VERSIONS_TL B
                      WHERE
                      B.ID = T.ID
                      AND B.LANGUAGE = T.SOURCE_LANG)
    WHERE (T.ID, T.LANGUAGE) IN (SELECT
                                 SUBT.ID,
                                 SUBT.LANGUAGE
                                 FROM
                                 OKL_LEASEAPP_TEMPL_VERSIONS_TL SUBB,
                                 OKL_LEASEAPP_TEMPL_VERSIONS_TL SUBT
                                 WHERE
                                 SUBB.ID = SUBT.ID
                                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                                 AND (SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION)
                                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                                );

    INSERT INTO OKL_LEASEAPP_TEMPL_VERSIONS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        SHORT_DESCRIPTION)
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
            B.SHORT_DESCRIPTION
        FROM OKL_LEASEAPP_TEMPL_VERSIONS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS (
                    SELECT NULL
                      FROM OKL_LEASEAPP_TEMPL_VERSIONS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_lavv_rec IN lavv_rec_type) RETURN lavv_rec_type IS

    l_lavv_rec  lavv_rec_type;

  BEGIN

    l_lavv_rec := p_lavv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_lavv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute_category := NULL;
    END IF;
    IF l_lavv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute1 := NULL;
    END IF;
    IF l_lavv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute2 := NULL;
    END IF;
    IF l_lavv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute3 := NULL;
    END IF;
    IF l_lavv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute4 := NULL;
    END IF;
    IF l_lavv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute5 := NULL;
    END IF;
    IF l_lavv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute6 := NULL;
    END IF;
    IF l_lavv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute7 := NULL;
    END IF;
    IF l_lavv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute8 := NULL;
    END IF;
    IF l_lavv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute9 := NULL;
    END IF;
    IF l_lavv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute10 := NULL;
    END IF;
    IF l_lavv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute11 := NULL;
    END IF;
    IF l_lavv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute12 := NULL;
    END IF;
    IF l_lavv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute13 := NULL;
    END IF;
    IF l_lavv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute14 := NULL;
    END IF;
    IF l_lavv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.attribute15 := NULL;
    END IF;
    IF l_lavv_rec.leaseapp_template_id = FND_API.G_MISS_NUM THEN
      l_lavv_rec.leaseapp_template_id := NULL;
    END IF;
    IF l_lavv_rec.version_status = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.version_status := NULL;
    END IF;
    IF l_lavv_rec.version_number = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.version_number := NULL;
    END IF;
    IF l_lavv_rec.valid_from = FND_API.G_MISS_DATE THEN
      l_lavv_rec.valid_from := NULL;
    END IF;
    IF l_lavv_rec.valid_to = FND_API.G_MISS_DATE THEN
      l_lavv_rec.valid_to := NULL;
    END IF;
    IF l_lavv_rec.checklist_id = FND_API.G_MISS_NUM THEN
      l_lavv_rec.checklist_id := NULL;
    END IF;
    IF l_lavv_rec.contract_template_id = FND_API.G_MISS_NUM THEN
      l_lavv_rec.contract_template_id := NULL;
    END IF;
    IF l_lavv_rec.short_description = FND_API.G_MISS_CHAR THEN
      l_lavv_rec.short_description := NULL;
    END IF;

    RETURN l_lavv_rec;

  END null_out_defaults;

  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN lavv_rec_type IS

    l_lavv_rec           lavv_rec_type;
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
      ,leaseapp_template_id
      ,version_status
      ,version_number
      ,valid_from
      ,valid_to
      ,checklist_id
      ,contract_template_id
      ,short_description
    INTO
      l_lavv_rec.id
      ,l_lavv_rec.object_version_number
      ,l_lavv_rec.attribute_category
      ,l_lavv_rec.attribute1
      ,l_lavv_rec.attribute2
      ,l_lavv_rec.attribute3
      ,l_lavv_rec.attribute4
      ,l_lavv_rec.attribute5
      ,l_lavv_rec.attribute6
      ,l_lavv_rec.attribute7
      ,l_lavv_rec.attribute8
      ,l_lavv_rec.attribute9
      ,l_lavv_rec.attribute10
      ,l_lavv_rec.attribute11
      ,l_lavv_rec.attribute12
      ,l_lavv_rec.attribute13
      ,l_lavv_rec.attribute14
      ,l_lavv_rec.attribute15
      ,l_lavv_rec.leaseapp_template_id
      ,l_lavv_rec.version_status
      ,l_lavv_rec.version_number
      ,l_lavv_rec.valid_from
      ,l_lavv_rec.valid_to
      ,l_lavv_rec.checklist_id
      ,l_lavv_rec.contract_template_id
      ,l_lavv_rec.short_description
    FROM okl_leaseapp_templ_versions_v
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_lavv_rec;

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
    IF (p_id = OKL_API.G_MISS_NUM OR
	    p_id IS NULL)
	THEN
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
    IF (p_object_version_number = OKL_API.G_MISS_NUM OR
	    p_object_version_number IS NULL)
	THEN
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

  --------------------------------------
  -- PROCEDURE validate_leaseapp_template_id
  --------------------------------------
  PROCEDURE validate_leaseapp_template_id (x_return_status OUT NOCOPY VARCHAR2, p_leaseapp_template_id IN NUMBER) IS
  BEGIN
    IF (p_leaseapp_template_id = OKL_API.G_MISS_NUM OR
	    p_leaseapp_template_id IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'leaseapp_template_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_leaseapp_template_id;

  --------------------------------------
  -- PROCEDURE validate_version_status
  --------------------------------------
  PROCEDURE validate_version_status (x_return_status OUT NOCOPY VARCHAR2, p_version_status IN VARCHAR2) IS
  BEGIN
    IF (p_version_status = OKL_API.G_MISS_CHAR OR
	    p_version_status IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'version_status',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_version_status;

  --------------------------------------
  -- PROCEDURE validate_version_number
  --------------------------------------
  PROCEDURE validate_version_number (x_return_status OUT NOCOPY VARCHAR2, p_version_number IN VARCHAR2) IS
  BEGIN
    IF (p_version_number = OKL_API.G_MISS_CHAR OR
	    p_version_number IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'version_number',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_version_number;

  --------------------------------
  -- PROCEDURE validate_valid_from
  --------------------------------
  PROCEDURE validate_valid_from (x_return_status OUT NOCOPY VARCHAR2, p_valid_from IN DATE) IS
  BEGIN
    IF (p_valid_from = OKL_API.G_MISS_DATE OR
	    p_valid_from IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'valid_from',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_valid_from;

  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_lavv_rec IN lavv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_lavv_rec.id);
    validate_object_version_number (l_return_status, p_lavv_rec.object_version_number);
    validate_leaseapp_template_id (l_return_status, p_lavv_rec.leaseapp_template_id);
    validate_version_status (l_return_status, p_lavv_rec.version_status);
    validate_version_number (l_return_status, p_lavv_rec.version_number);
    validate_valid_from (l_return_status, p_lavv_rec.valid_from);

    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_lavv_rec IN lavv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    -- start date cannot be after end date
    IF (p_lavv_rec.VALID_FROM IS NOT NULL AND p_lavv_rec.VALID_TO IS NOT NULL) THEN

    --Begin -varangan- updated the condition to > & message to OKL_INVALID_VALID_TO for bug#4684557
     IF (trunc(p_lavv_rec.VALID_FROM) > trunc(p_lavv_rec.VALID_TO)) THEN

      -- notify caller of an error as UNEXPETED error
        l_return_status := OKC_API.G_RET_STS_ERROR;

        OKL_API.SET_MESSAGE(p_app_name  => g_app_name,
                               p_msg_name  =>  'OKL_INVALID_VALID_TO');
   --End -varangan- updated the condition to > & message to OKL_INVALID_VALID_TO for bug#4684557

        -- notify caller of an error
        l_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
    END IF;
    RETURN l_return_status;
  END validate_record;

  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN lavv_rec_type, p_to IN OUT NOCOPY lav_rec_type) IS

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
    p_to.leaseapp_template_id           :=  p_from.leaseapp_template_id;
    p_to.version_status                 :=  p_from.version_status;
    p_to.version_number                 :=  p_from.version_number;
    p_to.valid_from                     :=  p_from.valid_from;
    p_to.valid_to                       :=  p_from.valid_to;
    p_to.checklist_id                   :=  p_from.checklist_id;
    p_to.contract_template_id           :=  p_from.contract_template_id;

  END migrate;

  -----------------------------
  -- PROCEDURE migrate (V -> TL)
  -----------------------------
  PROCEDURE migrate (p_from IN lavv_rec_type, p_to IN OUT NOCOPY lavtl_rec_type) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.short_description := p_from.short_description;
  END migrate;

  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_lav_rec IN lav_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_leaseapp_templ_versions_b (
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
      ,leaseapp_template_id
      ,version_status
      ,version_number
      ,valid_from
      ,valid_to
      ,checklist_id
      ,contract_template_id
      )
    VALUES
      (
       p_lav_rec.id
      ,p_lav_rec.object_version_number
      ,p_lav_rec.attribute_category
      ,p_lav_rec.attribute1
      ,p_lav_rec.attribute2
      ,p_lav_rec.attribute3
      ,p_lav_rec.attribute4
      ,p_lav_rec.attribute5
      ,p_lav_rec.attribute6
      ,p_lav_rec.attribute7
      ,p_lav_rec.attribute8
      ,p_lav_rec.attribute9
      ,p_lav_rec.attribute10
      ,p_lav_rec.attribute11
      ,p_lav_rec.attribute12
      ,p_lav_rec.attribute13
      ,p_lav_rec.attribute14
      ,p_lav_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_lav_rec.leaseapp_template_id
      ,p_lav_rec.version_status
      ,p_lav_rec.version_number
      ,p_lav_rec.valid_from
      ,p_lav_rec.valid_to
      ,p_lav_rec.checklist_id
      ,p_lav_rec.contract_template_id
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
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_lavtl_rec IN lavtl_rec_type) IS

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

      INSERT INTO OKL_LEASEAPP_TEMPL_VERSIONS_TL (
        id
       ,language
       ,source_lang
       ,sfwt_flag
       ,created_by
       ,creation_date
       ,last_updated_by
       ,last_update_date
       ,last_update_login
       ,short_description)
      VALUES (
        p_lavtl_rec.id
       ,l_lang_rec.language_code
       ,USERENV('LANG')
       ,l_sfwt_flag
       ,G_USER_ID
       ,SYSDATE
       ,G_USER_ID
       ,SYSDATE
       ,G_LOGIN_ID
       ,p_lavtl_rec.short_description);

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
    p_lavv_rec                     IN lavv_rec_type,
    x_lavv_rec                     OUT NOCOPY lavv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_lavv_rec                     lavv_rec_type;
    l_lav_rec                      lav_rec_type;
    l_lavtl_rec                    lavtl_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_lavv_rec                       := null_out_defaults (p_lavv_rec);

    SELECT okl_lav_seq.nextval INTO l_lavv_rec.ID FROM DUAL;

    l_lavv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_lavv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_lavv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lavv_rec, l_lav_rec);
    migrate (l_lavv_rec, l_lavtl_rec);

    insert_row (x_return_status => l_return_status, p_lav_rec => l_lav_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    insert_row (x_return_status => l_return_status, p_lavtl_rec => l_lavtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_lavv_rec      := l_lavv_rec;
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
    p_lavv_rec                     IN lavv_rec_type,
    x_lavv_rec                     OUT NOCOPY lavv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_lavv_rec                     => p_lavv_rec,
                x_lavv_rec                     => x_lavv_rec);

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
    p_lavv_tbl                     IN lavv_tbl_type,
    x_lavv_tbl                     OUT NOCOPY lavv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lavv_tbl.COUNT > 0) THEN
      i := p_lavv_tbl.FIRST;
      LOOP
        IF p_lavv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_lavv_rec                     => p_lavv_tbl(i),
                      x_lavv_rec                     => x_lavv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lavv_tbl.LAST);
          i := p_lavv_tbl.NEXT(i);

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
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_lav_rec IN lav_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASEAPP_TEMPL_VERSIONS_B
     WHERE ID = p_lav_rec.id
       AND OBJECT_VERSION_NUMBER = p_lav_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASEAPP_TEMPL_VERSIONS_B
     WHERE ID = p_lav_rec.id;

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

      ELSIF lc_object_version_number <> p_lav_rec.object_version_number THEN

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_lav_rec IN lav_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_lav_rec => p_lav_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_leaseapp_templ_versions_b
    SET
      object_version_number = p_lav_rec.object_version_number+1
      ,attribute_category = p_lav_rec.attribute_category
      ,attribute1 = p_lav_rec.attribute1
      ,attribute2 = p_lav_rec.attribute2
      ,attribute3 = p_lav_rec.attribute3
      ,attribute4 = p_lav_rec.attribute4
      ,attribute5 = p_lav_rec.attribute5
      ,attribute6 = p_lav_rec.attribute6
      ,attribute7 = p_lav_rec.attribute7
      ,attribute8 = p_lav_rec.attribute8
      ,attribute9 = p_lav_rec.attribute9
      ,attribute10 = p_lav_rec.attribute10
      ,attribute11 = p_lav_rec.attribute11
      ,attribute12 = p_lav_rec.attribute12
      ,attribute13 = p_lav_rec.attribute13
      ,attribute14 = p_lav_rec.attribute14
      ,attribute15 = p_lav_rec.attribute15
      ,leaseapp_template_id = p_lav_rec.leaseapp_template_id
      ,version_status = p_lav_rec.version_status
      ,version_number = p_lav_rec.version_number
      ,valid_from = p_lav_rec.valid_from
      ,valid_to = p_lav_rec.valid_to
      ,checklist_id = p_lav_rec.checklist_id
      ,contract_template_id = p_lav_rec.contract_template_id
    WHERE id = p_lav_rec.id;

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_lavtl_rec IN lavtl_rec_type) IS

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TL)';

    UPDATE OKL_LEASEAPP_TEMPL_VERSIONS_TL
    SET
      source_lang = USERENV('LANG')
      ,sfwt_flag = 'Y'
      ,last_updated_by = G_USER_ID
      ,last_update_date = SYSDATE
      ,last_update_login = G_LOGIN_ID
      ,short_description = p_lavtl_rec.short_description
    WHERE ID = p_lavtl_rec.id;

    UPDATE OKL_LEASEAPP_TEMPL_VERSIONS_TL
    SET SFWT_FLAG = 'N'
    WHERE ID = p_lavtl_rec.id
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
    p_lavv_rec                     IN lavv_rec_type,
    x_lavv_rec                     OUT NOCOPY lavv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_lavv_rec                     lavv_rec_type;
    l_lav_rec                      lav_rec_type;
    l_lavtl_rec                    lavtl_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_lavv_rec IN  lavv_rec_type,
                                  x_lavv_rec OUT NOCOPY lavv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61)          := G_PKG_NAME||'.populate_new_record';
      l_return_status      VARCHAR2(1);
      l_db_lavv_rec        lavv_rec_type;

    BEGIN

      x_lavv_rec    := p_lavv_rec;
      l_db_lavv_rec := get_rec (p_lavv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_lavv_rec.attribute_category IS NULL THEN
        x_lavv_rec.attribute_category := l_db_lavv_rec.attribute_category;
      END IF;
      IF x_lavv_rec.attribute1 IS NULL THEN
        x_lavv_rec.attribute1 := l_db_lavv_rec.attribute1;
      END IF;
      IF x_lavv_rec.attribute2 IS NULL THEN
        x_lavv_rec.attribute2 := l_db_lavv_rec.attribute2;
      END IF;
      IF x_lavv_rec.attribute3 IS NULL THEN
        x_lavv_rec.attribute3 := l_db_lavv_rec.attribute3;
      END IF;
      IF x_lavv_rec.attribute4 IS NULL THEN
        x_lavv_rec.attribute4 := l_db_lavv_rec.attribute4;
      END IF;
      IF x_lavv_rec.attribute5 IS NULL THEN
        x_lavv_rec.attribute5 := l_db_lavv_rec.attribute5;
      END IF;
      IF x_lavv_rec.attribute6 IS NULL THEN
        x_lavv_rec.attribute6 := l_db_lavv_rec.attribute6;
      END IF;
      IF x_lavv_rec.attribute7 IS NULL THEN
        x_lavv_rec.attribute7 := l_db_lavv_rec.attribute7;
      END IF;
      IF x_lavv_rec.attribute8 IS NULL THEN
        x_lavv_rec.attribute8 := l_db_lavv_rec.attribute8;
      END IF;
      IF x_lavv_rec.attribute9 IS NULL THEN
        x_lavv_rec.attribute9 := l_db_lavv_rec.attribute9;
      END IF;
      IF x_lavv_rec.attribute10 IS NULL THEN
        x_lavv_rec.attribute10 := l_db_lavv_rec.attribute10;
      END IF;
      IF x_lavv_rec.attribute11 IS NULL THEN
        x_lavv_rec.attribute11 := l_db_lavv_rec.attribute11;
      END IF;
      IF x_lavv_rec.attribute12 IS NULL THEN
        x_lavv_rec.attribute12 := l_db_lavv_rec.attribute12;
      END IF;
      IF x_lavv_rec.attribute13 IS NULL THEN
        x_lavv_rec.attribute13 := l_db_lavv_rec.attribute13;
      END IF;
      IF x_lavv_rec.attribute14 IS NULL THEN
        x_lavv_rec.attribute14 := l_db_lavv_rec.attribute14;
      END IF;
      IF x_lavv_rec.attribute15 IS NULL THEN
        x_lavv_rec.attribute15 := l_db_lavv_rec.attribute15;
      END IF;
      IF x_lavv_rec.leaseapp_template_id IS NULL THEN
        x_lavv_rec.leaseapp_template_id := l_db_lavv_rec.leaseapp_template_id;
      END IF;
      IF x_lavv_rec.version_status IS NULL THEN
        x_lavv_rec.version_status := l_db_lavv_rec.version_status;
      END IF;
      IF x_lavv_rec.version_number IS NULL THEN
        x_lavv_rec.version_number := l_db_lavv_rec.version_number;
      END IF;
      IF x_lavv_rec.valid_from IS NULL THEN
        x_lavv_rec.valid_from := l_db_lavv_rec.valid_from;
      END IF;
      IF x_lavv_rec.valid_to IS NULL THEN
        x_lavv_rec.valid_to := l_db_lavv_rec.valid_to;
      END IF;
      IF x_lavv_rec.checklist_id IS NULL THEN
        x_lavv_rec.checklist_id := l_db_lavv_rec.checklist_id;
      END IF;
      IF x_lavv_rec.contract_template_id IS NULL THEN
        x_lavv_rec.contract_template_id := l_db_lavv_rec.contract_template_id;
      END IF;
      IF x_lavv_rec.short_description IS NULL THEN
        x_lavv_rec.short_description := l_db_lavv_rec.short_description;
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

    l_return_status := populate_new_record (p_lavv_rec, l_lavv_rec);
    l_lavv_rec      := null_out_defaults(l_lavv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_lavv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_lavv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_lavv_rec, l_lav_rec);
    migrate (l_lavv_rec, l_lavtl_rec);

    update_row (x_return_status => l_return_status, p_lav_rec => l_lav_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    update_row (x_return_status => l_return_status, p_lavtl_rec => l_lavtl_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_lavv_rec      := l_lavv_rec;

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
    p_lavv_rec                     IN lavv_rec_type,
    x_lavv_rec                     OUT NOCOPY lavv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_lavv_rec                     => p_lavv_rec,
                x_lavv_rec                     => x_lavv_rec);

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
    p_lavv_tbl                     IN lavv_tbl_type,
    x_lavv_tbl                     OUT NOCOPY lavv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_lavv_tbl := p_lavv_tbl;

    IF (p_lavv_tbl.COUNT > 0) THEN

      i := p_lavv_tbl.FIRST;

      LOOP

        IF p_lavv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_lavv_rec                     => p_lavv_tbl(i),
                      x_lavv_rec                     => x_lavv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lavv_tbl.LAST);
          i := p_lavv_tbl.NEXT(i);

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

    DELETE FROM OKL_LEASEAPP_TEMPL_VERSIONS_B WHERE id = p_id;
    DELETE FROM OKL_LEASEAPP_TEMPL_VERSIONS_TL WHERE id = p_id;

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
    p_lavv_rec                     IN lavv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_lavv_rec.id);

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
    p_lavv_tbl                     IN lavv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_lavv_tbl.COUNT > 0) THEN

      i := p_lavv_tbl.FIRST;

      LOOP

        IF p_lavv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_lavv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_lavv_tbl.LAST);
          i := p_lavv_tbl.NEXT(i);

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

END OKL_LAV_PVT;

/
