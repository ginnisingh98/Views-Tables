--------------------------------------------------------
--  DDL for Package Body POR_IFT_ADMIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POR_IFT_ADMIN_PKG" AS
/* $Header: PORIFTAB.pls 115.9 2003/08/25 17:26:17 liwang ship $ */

PROCEDURE insert_template(p_name            IN  VARCHAR2,
                          p_org_id          IN  NUMBER,
                          p_attach_cat_id   IN  NUMBER,
                          p_user_id         IN  NUMBER,
                          p_login_id        IN  NUMBER,
                          p_template_code   IN OUT NOCOPY VARCHAR2,
                          p_row_id          OUT NOCOPY VARCHAR2) IS
  l_progress    VARCHAR2(10) := '000';
  l_template_code VARCHAR2(30) := NULL;
  l_count_obj NUMBER;
BEGIN

  l_progress := '001';
  INSERT INTO POR_TEMPLATES_ALL_B (
    TEMPLATE_CODE,
    ORG_ID,
    ATTACHMENT_CATEGORY_ID,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN)
  VALUES (
    'IFT_'||to_char(por_templates_s.NEXTVAL),
    p_org_id,
    p_attach_cat_id,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate,
    p_login_id)
  RETURNING TEMPLATE_CODE INTO l_template_code;


  l_progress := '003';
  INSERT INTO POR_TEMPLATES_ALL_TL(
    TEMPLATE_CODE,
    SOURCE_LANG,
    LANGUAGE,
    TEMPLATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN)
  SELECT
    l_template_code,
    userenv('LANG'),
    FL.language_code,
    p_name,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate,
    p_login_id
  FROM FND_LANGUAGES FL
  WHERE FL.INSTALLED_FLAG IN ('B','I');

  p_template_code := l_template_code;

  l_progress := '006';
  SELECT row_id
  INTO   p_row_id
  FROM   por_templates_v
  WHERE  template_code = l_template_code;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.insert_template', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END insert_template;


PROCEDURE lock_template(p_row_id        IN VARCHAR2,
                        p_template_code IN VARCHAR2,
                        p_name          IN VARCHAR2,
                        p_user_id       IN NUMBER,
                        p_login_id      IN NUMBER) IS
  CURSOR c_rec(p_row_id VARCHAR2) IS
    SELECT *
    FROM   por_templates_all_b
    WHERE  rowid = p_row_id
    FOR UPDATE NOWAIT;

  CURSOR c_tl_rec(p_template_code VARCHAR2) IS
    SELECT
      TEMPLATE_NAME,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from POR_TEMPLATES_ALL_TL
    where TEMPLATE_CODE=p_template_code
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update nowait;
  l_rec      c_rec%ROWTYPE;
  l_progress VARCHAR2(10) := '000';
BEGIN

  l_progress := '001';
  OPEN c_rec(p_row_id);

  l_progress := '002';
  FETCH c_rec INTO l_rec;

  IF (c_rec%NOTFOUND) THEN
    l_progress := '003';
    CLOSE c_rec;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c_rec;

  -- Note the use of NULL statements to handle possible
  -- null values in the IF conditions.
  l_progress := '004';
  IF (l_rec.template_code = p_template_code) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  l_progress := '005';
  for tlinfo in c_tl_rec(p_template_code) loop
    if (tlinfo.BASELANG = 'Y') then
      if(tlinfo.template_name = p_name)
      then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
EXCEPTION
  WHEN app_exception.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.lock_template', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END lock_template;

PROCEDURE update_template(p_row_id        IN VARCHAR2,
                          p_template_code IN VARCHAR2,
                          p_name          IN VARCHAR2,
                          p_org_id        IN  NUMBER,
                          p_attach_cat_id IN NUMBER,
                          p_user_id       IN NUMBER,
                          p_login_id      IN NUMBER) IS
  l_progress        VARCHAR2(10) := '000';
BEGIN

  l_progress := '001';
  UPDATE POR_TEMPLATES_ALL_B
  SET
    ORG_ID = p_org_id,
		ATTACHMENT_CATEGORY_ID = p_attach_cat_id,
		LAST_UPDATED_BY = p_user_id,
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATE_LOGIN = p_login_id
  WHERE 	ROWID = p_row_id;

  l_progress := '002';
  UPDATE POR_TEMPLATES_ALL_TL
  SET
		TEMPLATE_NAME = p_name,
		LAST_UPDATED_BY = p_user_id,
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATE_LOGIN = p_login_id,
    SOURCE_LANG = USERENV('LANG')
  WHERE 	TEMPLATE_CODE = p_template_code
  AND 		USERENV('LANG') in (LANGUAGE, SOURCE_LANG);

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.update_template', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END update_template;


PROCEDURE delete_template(p_row_id   IN VARCHAR2) IS
  l_progress        VARCHAR2(10) := '000';
  l_template_code VARCHAR2(30);
BEGIN

  l_progress := '001';
  SELECT template_code
  INTO   l_template_code
  FROM   por_templates_v
  WHERE  row_id = p_row_id;

  l_progress := '002';
  DELETE FROM POR_TEMPLATE_ATTRIBUTES_TL
  WHERE ATTRIBUTE_CODE IN
    (
      SELECT ATTRIBUTE_CODE
      FROM POR_TEMPLATE_ATTRIBUTES_B
      WHERE TEMPLATE_CODE = l_template_code
    );

  l_progress := '003';
  DELETE FROM POR_TEMPLATE_ATTRIBUTES_B
  WHERE TEMPLATE_CODE = l_template_code;

  l_progress := '004';
  DELETE FROM POR_TEMPLATES_ALL_B
  WHERE TEMPLATE_CODE = l_template_code;

  l_progress := '005';
  DELETE FROM POR_TEMPLATES_ALL_TL
  WHERE TEMPLATE_CODE = l_template_code;

  l_progress := '006';
  DELETE FROM POR_TEMPLATE_ASSOC
  WHERE region_code = l_template_code;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.delete_template', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END delete_template;


PROCEDURE insert_template_attribute(p_template_code     IN  VARCHAR2,
                                    p_display_sequence  IN  NUMBER,
                                    p_attribute_name    IN  VARCHAR2,
                                    p_description       IN  VARCHAR2,
                                    p_default_value     IN  VARCHAR2,
                                    p_flex_value_set_id IN  NUMBER,
                                    p_required_flag     IN  VARCHAR2,
                                    p_node_display_flag IN  VARCHAR2,
                                    p_user_id           IN  NUMBER,
                                    p_login_id          IN  NUMBER,
                                    p_attribute_code    IN OUT NOCOPY VARCHAR2,
                                    p_row_id            OUT NOCOPY VARCHAR2) IS
  l_progress       VARCHAR2(10) := '000';
  l_attribute_code VARCHAR2(30) := NULL;
BEGIN

  l_progress := '002';
  INSERT INTO POR_TEMPLATE_ATTRIBUTES_B (
    TEMPLATE_CODE,
    ATTRIBUTE_CODE,
    SEQUENCE,
    FLEX_VALUE_SET_ID,
    REQUIRED_FLAG,
    NODE_DISPLAY_FLAG,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN)
  VALUES (
    p_template_code,
    'IFT_'||to_char(por_template_attributes_s.NEXTVAL),
    p_display_sequence,
    p_flex_value_set_id,
    p_required_flag,
    p_node_display_flag,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate,
    p_login_id)
  RETURNING ATTRIBUTE_CODE into l_attribute_code;

  l_progress := '003';
  INSERT INTO POR_TEMPLATE_ATTRIBUTES_TL(
    ATTRIBUTE_CODE,
    SOURCE_LANG,
    LANGUAGE,
    ATTRIBUTE_NAME,
    DESCRIPTION,
    DEFAULT_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN)
  SELECT
    l_attribute_code,
    userenv('LANG'),
    FL.language_code,
    p_attribute_name,
    p_description,
    p_default_value,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate,
    p_login_id
  FROM FND_LANGUAGES FL
  WHERE INSTALLED_FLAG IN ('B','I');

  p_attribute_code := l_attribute_code;

  l_progress := '008';
  SELECT row_id
  INTO   p_row_id
  FROM   por_template_attributes_v
  WHERE  template_code = p_template_code
  AND    attribute_code = l_attribute_code;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.insert_template_attribute', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END insert_template_attribute;


PROCEDURE lock_template_attribute(p_row_id            IN VARCHAR2,
                                  p_template_code     IN VARCHAR2,
                                  p_attribute_code    IN VARCHAR2,
                                  p_display_sequence  IN NUMBER,
                                  p_attribute_name    IN VARCHAR2,
                                  p_description       IN VARCHAR2,
                                  p_default_value     IN VARCHAR2,
                                  p_flex_value_set_id IN  NUMBER,
                                  p_required_flag     IN VARCHAR2,
                                  p_node_display_flag IN VARCHAR2,
                                  p_user_id           IN NUMBER,
                                  p_login_id          IN NUMBER) IS
  CURSOR c_rec(p_row_id VARCHAR2) IS
    SELECT *
    FROM   por_template_attributes_b
    WHERE  rowid = p_row_id
    FOR UPDATE NOWAIT;

  CURSOR c_tl_rec(p_attribute_code VARCHAR2) IS
    SELECT
      ATTRIBUTE_NAME,
      DESCRIPTION,
      DEFAULT_VALUE,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from POR_TEMPLATE_ATTRIBUTES_TL
    where ATTRIBUTE_CODE=p_attribute_code
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update nowait;

  l_rec      c_rec%ROWTYPE;
  l_progress VARCHAR2(10) := '000';
BEGIN


  l_progress := '001';
  OPEN c_rec(p_row_id);

  l_progress := '002';
  FETCH c_rec INTO l_rec;

  IF (c_rec%NOTFOUND) THEN
    l_progress := '003';
    CLOSE c_rec;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c_rec;

  -- Note the use of NULL statements to handle possible
  -- null values in the IF conditions.
  l_progress := '004';
  IF (l_rec.template_code = p_template_code) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  l_progress := '005';
  IF (l_rec.sequence = p_display_sequence) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  l_progress := '006';
  IF (l_rec.attribute_code = p_attribute_code) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

  l_progress := '007';
  IF (l_rec.flex_value_set_id = p_flex_value_set_id) OR
     (l_rec.flex_value_set_id IS NULL AND p_flex_value_set_id IS NULL) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED4');
    app_exception.raise_exception;
  END IF;

  l_progress := '011';
  IF (l_rec.required_flag = p_required_flag) OR
     (l_rec.required_flag IS NULL AND p_required_flag IS NULL) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED8');
    app_exception.raise_exception;
  END IF;

  l_progress := '012';
  IF (l_rec.node_display_flag = p_node_display_flag) OR
     (l_rec.node_display_flag IS NULL AND p_node_display_flag IS NULL) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED9');
    app_exception.raise_exception;
  END IF;

  for tlinfo in c_tl_rec(p_attribute_code) loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.attribute_name = p_attribute_name)
          AND ((tlinfo.DESCRIPTION = p_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (p_DESCRIPTION is null)))
          AND ((tlinfo.default_value = p_default_value)
               OR ((tlinfo.default_value is null) AND (p_default_value is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
EXCEPTION
  WHEN app_exception.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.lock_template_attribute', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END lock_template_attribute;


PROCEDURE update_template_attribute(p_row_id            IN VARCHAR2,
                                    p_template_code     IN VARCHAR2,
                                    p_attribute_code    IN VARCHAR2,
                                    p_display_sequence  IN NUMBER,
                                    p_attribute_name    IN VARCHAR2,
                                    p_description       IN VARCHAR2,
                                    p_default_value     IN VARCHAR2,
                                    p_flex_value_set_id IN  NUMBER,
                                    p_required_flag     IN VARCHAR2,
                                    p_node_display_flag IN VARCHAR2,
                                    p_user_id           IN NUMBER,
                                    p_login_id          IN NUMBER) IS
  l_progress           VARCHAR2(10) := '000';
BEGIN
  l_progress := '001';
  UPDATE POR_TEMPLATE_ATTRIBUTES_B
  SET
    SEQUENCE = p_display_sequence,
    FLEX_VALUE_SET_ID = p_flex_value_set_id,
    REQUIRED_FLAG = p_required_flag,
    NODE_DISPLAY_FLAG = p_node_display_flag,
    LAST_UPDATED_BY = p_user_id,
    LAST_UPDATE_DATE = sysdate,
    LAST_UPDATE_LOGIN = p_login_id
  WHERE ROWID = p_row_id;

  l_progress := '003';
  UPDATE POR_TEMPLATE_ATTRIBUTES_TL
  SET
    ATTRIBUTE_NAME = p_attribute_name,
    DESCRIPTION = p_description,
    DEFAULT_VALUE = p_default_value,
		LAST_UPDATED_BY = p_user_id,
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATE_LOGIN = p_login_id,
    SOURCE_LANG = USERENV('LANG')
  WHERE 	ATTRIBUTE_CODE = p_attribute_code
  AND 		USERENV('LANG') in (LANGUAGE, SOURCE_LANG);

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.update_template_attribute', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END update_template_attribute;

PROCEDURE delete_template_attribute(p_row_id   IN VARCHAR2) IS
  l_progress           VARCHAR2(10) := '000';
  l_attribute_code_old VARCHAR2(30);
BEGIN

  l_progress := '001';
  SELECT attribute_code
  INTO   l_attribute_code_old
  FROM   por_template_attributes_v
  WHERE  row_id = p_row_id;

  l_progress := '002';
  DELETE FROM por_template_attributes_b
  WHERE rowid = p_row_id;

  l_progress := '003';
  DELETE FROM por_template_attributes_tl
  WHERE attribute_code = l_attribute_code_old;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.delete_template_attribute', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END delete_template_attribute;

PROCEDURE insert_template_assoc(p_region_code           IN  VARCHAR2,
                                p_item_or_category_flag IN  VARCHAR2,
                                p_item_or_category_id   IN  NUMBER,
                                p_user_id               IN  NUMBER,
                                p_login_id              IN  NUMBER,
                                p_template_assoc_id     OUT NOCOPY NUMBER,
                                p_row_id                OUT NOCOPY VARCHAR2) IS
  l_progress          VARCHAR2(10) := '000';
  l_template_assoc_id NUMBER;
BEGIN

  l_progress := '001';
  SELECT por_template_assoc_s.NEXTVAL
  INTO   l_template_assoc_id
  FROM   SYS.DUAL;

  l_progress := '002';
  INSERT INTO por_template_assoc (
    template_assoc_id,
    region_code,
    item_or_category_flag,
    item_or_category_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login)
  VALUES (
    l_template_assoc_id,
    p_region_code,
    p_item_or_category_flag,
    p_item_or_category_id,
    p_user_id,
    SYSDATE,
    p_user_id,
    SYSDATE,
    p_login_id);

  p_template_assoc_id := l_template_assoc_id;

  l_progress := '003';
  SELECT row_id
  INTO   p_row_id
  FROM   por_template_assoc_v
  WHERE  template_assoc_id = l_template_assoc_id;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.insert_template_assoc', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END insert_template_assoc;

PROCEDURE lock_template_assoc(p_row_id                IN VARCHAR2,
                              p_template_assoc_id     IN NUMBER,
                              p_region_code           IN VARCHAR2,
                              p_item_or_category_flag IN VARCHAR2,
                              p_item_or_category_id   IN NUMBER,
                              p_user_id               IN NUMBER,
                              p_login_id              IN NUMBER) IS
  CURSOR c_rec(p_row_id VARCHAR2) IS
    SELECT *
    FROM   por_template_assoc
    WHERE  rowid = p_row_id
    FOR UPDATE NOWAIT;
  l_rec      c_rec%ROWTYPE;
  l_progress VARCHAR2(10) := '000';
BEGIN

  IF (p_row_id IS NULL) THEN
    RETURN;
  END IF;

  l_progress := '001';
  OPEN c_rec(p_row_id);

  l_progress := '002';
  FETCH c_rec INTO l_rec;

  IF (c_rec%NOTFOUND) THEN
    l_progress := '003';
    CLOSE c_rec;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c_rec;

  -- Note the use of NULL statements to handle possible
  -- null values in the IF conditions.
  l_progress := '004';
  IF (l_rec.region_code = p_region_code) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  l_progress := '005';
  IF (l_rec.item_or_category_flag = p_item_or_category_flag) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;
  l_progress := '006';
  IF (l_rec.item_or_category_id = p_item_or_category_id) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  END IF;

EXCEPTION
  WHEN app_exception.application_exception THEN
    RAISE;
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.lock_template_assoc', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END lock_template_assoc;

PROCEDURE update_template_assoc(p_row_id                IN VARCHAR2,
                                p_template_assoc_id     IN NUMBER,
                                p_region_code           IN VARCHAR2,
                                p_item_or_category_flag IN VARCHAR2,
                                p_item_or_category_id   IN NUMBER,
                                p_user_id               IN NUMBER,
                                p_login_id              IN NUMBER) IS
  l_progress VARCHAR2(10) := '000';
BEGIN

  l_progress := '001';
  UPDATE por_template_assoc
  SET    template_assoc_id = p_template_assoc_id,
         region_code = p_region_code,
         item_or_category_flag = p_item_or_category_flag,
         item_or_category_id = p_item_or_category_id,
         last_updated_by  = p_user_id,
         last_update_date  = SYSDATE,
         last_update_login  = p_login_id
  WHERE  rowid = p_row_id;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.update_template_assoc', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END update_template_assoc;


PROCEDURE delete_template_assoc(p_row_id IN VARCHAR2) IS
  l_progress VARCHAR2(10) := '000';
BEGIN

  l_progress := '001';
  DELETE FROM por_template_assoc
  WHERE  rowid = p_row_id;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.delete_template_assoc', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END delete_template_assoc;

PROCEDURE delete_all_template_assoc(p_region_code IN VARCHAR2) IS
  l_progress VARCHAR2(10) := '000';
BEGIN

  l_progress := '001';
  DELETE FROM por_template_assoc
  WHERE  region_code = p_region_code;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('por_ift_admin_pkg.delete_all_template_assoc', l_progress, SQLCODE);
    RAISE app_exception.application_exception;
END delete_all_template_assoc;

PROCEDURE add_language IS
BEGIN
  INSERT INTO POR_TEMPLATES_ALL_TL(
    TEMPLATE_CODE,
    SOURCE_LANG,
    LANGUAGE,
    TEMPLATE_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN)
  SELECT
    B.TEMPLATE_CODE,
    B.SOURCE_LANG,
    L.LANGUAGE_CODE,
    B.TEMPLATE_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN
  FROM 	POR_TEMPLATES_ALL_TL B,  FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B')
  AND 	B.LANGUAGE = USERENV('LANG')
  AND 	NOT EXISTS
    (SELECT NULL
    FROM 		POR_TEMPLATES_ALL_TL T
    WHERE 	T.TEMPLATE_CODE = B.TEMPLATE_CODE
    AND 		T.LANGUAGE = L.LANGUAGE_CODE);

  INSERT INTO POR_TEMPLATE_ATTRIBUTES_TL(
    ATTRIBUTE_CODE,
    SOURCE_LANG,
    LANGUAGE,
    ATTRIBUTE_NAME,
    DESCRIPTION,
    DEFAULT_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN)
  SELECT
    B.ATTRIBUTE_CODE,
    B.SOURCE_LANG,
    L.LANGUAGE_CODE,
    B.ATTRIBUTE_NAME,
    B.DESCRIPTION,
    B.DEFAULT_VALUE,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN
  FROM 	POR_TEMPLATE_ATTRIBUTES_TL B,  FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B')
  AND 	B.LANGUAGE = userenv('LANG')
  AND 	NOT EXISTS
    (SELECT 	NULL
    FROM 		POR_TEMPLATE_ATTRIBUTES_TL T
    WHERE 	T.ATTRIBUTE_CODE = B.ATTRIBUTE_CODE
    AND 		T.LANGUAGE = L.LANGUAGE_CODE);

END add_language;

END por_ift_admin_pkg;

/
