--------------------------------------------------------
--  DDL for Package Body XLA_PRODUCT_RULES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_PRODUCT_RULES_F_PKG" AS
/* $Header: xlathpdr.pkb 120.19.12010000.1 2008/07/29 10:10:17 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_product_rules                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_product_rules                         |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_product_rules_f_pkg';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS
BEGIN
  ----------------------------------------------------------------------------
  -- Following is for FND log.
  ----------------------------------------------------------------------------
  IF (p_msg IS NULL AND p_level >= g_log_level) THEN
    fnd_log.message(p_level, p_module);
  ELSIF p_level >= g_log_level THEN
    fnd_log.string(p_level, p_module, p_msg);
  END IF;

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_product_rules_f_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_request_id                       IN NUMBER
  ,x_product_rule_version             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_product_rule_hash_id             IN NUMBER
  ,x_compile_status_code              IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_product_rules_b
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
;

l_log_module                    VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.insert_row';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'BEGIN of procedure insert_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

INSERT INTO xla_product_rules_b
(creation_date
,created_by
,enabled_flag
,request_id
,product_rule_version
,application_id
,product_rule_type_code
,product_rule_code
,transaction_coa_id
,accounting_coa_id
,product_rule_hash_id
,amb_context_code
,compile_status_code
,updated_flag
,version_num
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_enabled_flag
,x_request_id
,x_product_rule_version
,x_application_id
,x_product_rule_type_code
,x_product_rule_code
,x_transaction_coa_id
,x_accounting_coa_id
,x_product_rule_hash_id
,x_amb_context_code
,x_compile_status_code
,'Y'
,0
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

INSERT INTO xla_product_rules_tl
(amb_context_code
,last_update_login
,creation_date
,created_by
,last_update_date
,last_updated_by
,application_id
,product_rule_type_code
,product_rule_code
,name
,description
,language
,source_lang)
SELECT
       x_amb_context_code
      ,x_last_update_login
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_application_id
      ,x_product_rule_type_code
      ,x_product_rule_code
      ,x_name
      ,x_description
      ,l.language_code
      ,USERENV('LANG')
FROM   fnd_languages l
WHERE  l.installed_flag                 IN ('I', 'B')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_product_rules_tl               t
       WHERE  t.application_id                   = x_application_id
         AND  t.amb_context_code                 = x_amb_context_code
         AND  t.product_rule_type_code           = x_product_rule_type_code
         AND  t.product_rule_code                = x_product_rule_code
         AND  t.language                         = l.language_code);

OPEN c;
FETCH c INTO x_rowid;

IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
END IF;
CLOSE c;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure insert_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

END insert_row;

/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_request_id                       IN NUMBER
  ,x_product_rule_version             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_coa_id                IN NUMBER
  ,x_product_rule_hash_id             IN NUMBER
  ,x_compile_status_code              IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2)

IS

CURSOR c IS
SELECT enabled_flag
      ,request_id
      ,product_rule_version
      ,transaction_coa_id
      ,accounting_coa_id
      ,product_rule_hash_id
      ,compile_status_code
FROM   xla_product_rules_b
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
FOR UPDATE OF application_id NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT amb_context_code
      ,name
      ,description
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_product_rules_tl
WHERE  application_id                   = X_application_id
  AND  amb_context_code                 = X_amb_context_code
  AND  product_rule_type_code           = X_product_rule_type_code
  AND  product_rule_code                = X_product_rule_code
  AND  USERENV('LANG')                 IN (language     ,source_lang)
FOR UPDATE OF application_id NOWAIT;

l_log_module                    VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.lock_row';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'BEGIN of procedure lock_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;


OPEN c;
FETCH c INTO recinfo;

IF (c%NOTFOUND) THEN
   CLOSE c;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   app_exception.raise_exception;
END IF;
CLOSE c;

IF ( (recinfo.enabled_flag                     = x_enabled_flag)
 AND ((recinfo.request_id                       = X_request_id)
   OR ((recinfo.request_id                       IS NULL)
  AND (x_request_id                       IS NULL)))
 AND ((recinfo.product_rule_version             = X_product_rule_version)
   OR ((recinfo.product_rule_version             IS NULL)
  AND (x_product_rule_version             IS NULL)))
 AND ((recinfo.transaction_coa_id               = X_transaction_coa_id)
   OR ((recinfo.transaction_coa_id               IS NULL)
  AND (x_transaction_coa_id               IS NULL)))
 AND ((recinfo.accounting_coa_id                = X_accounting_coa_id)
   OR ((recinfo.accounting_coa_id                IS NULL)
  AND (x_accounting_coa_id                IS NULL)))
 AND ((recinfo.product_rule_hash_id             = X_product_rule_hash_id)
   OR ((recinfo.product_rule_hash_id             IS NULL)
  AND (x_product_rule_hash_id             IS NULL)))
 AND ((recinfo.compile_status_code              = X_compile_status_code)
   OR ((recinfo.compile_status_code              IS NULL)
  AND (x_compile_status_code              IS NULL)))
                   ) THEN
   NULL;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

FOR tlinfo IN c1 LOOP
   IF (tlinfo.baselang = 'Y') THEN
      IF (    (tlinfo.name = X_name)
          AND ((tlinfo.description = X_description)
               OR ((tlinfo.description                      is null)
                AND (X_description                      is null)))
      ) THEN
        NULL;
      ELSE
         fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
         app_exception.raise_exception;
      END IF;
   END IF;
END LOOP;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure lock_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

RETURN;

END lock_row;

/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_product_rule_type_code           IN VARCHAR2
 ,x_product_rule_code                IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_request_id                       IN NUMBER
 ,x_product_rule_version             IN VARCHAR2
 ,x_transaction_coa_id               IN NUMBER
 ,x_accounting_coa_id                IN NUMBER
 ,x_product_rule_hash_id             IN NUMBER
 ,x_compile_status_code              IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                  IN DATE
 ,x_last_updated_by                   IN NUMBER
 ,x_last_update_login                 IN NUMBER)

IS

l_log_module                    VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.update_row';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'BEGIN of procedure update_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

UPDATE xla_product_rules_b
   SET
       last_update_date                 = x_last_update_date
      ,enabled_flag                     = x_enabled_flag
      ,request_id                       = x_request_id
      ,product_rule_version             = x_product_rule_version
      ,transaction_coa_id               = x_transaction_coa_id
      ,accounting_coa_id                = x_accounting_coa_id
      ,product_rule_hash_id             = x_product_rule_hash_id
      ,compile_status_code              = x_compile_status_code
      ,updated_flag                     = 'Y'
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = X_application_id
  AND  amb_context_code                 = X_amb_context_code
  AND  product_rule_type_code           = X_product_rule_type_code
  AND  product_rule_code                = X_product_rule_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_product_rules_tl
SET
       last_update_date                 = x_last_update_date
      ,name                             = X_name
      ,description                      = X_description
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  application_id                   = X_application_id
  AND  amb_context_code                 = X_amb_context_code
  AND  product_rule_type_code           = X_product_rule_type_code
  AND  product_rule_code                = X_product_rule_code
  AND  USERENV('LANG')                 IN (language, source_lang);

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure update_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

END update_row;

/*======================================================================+
|                                                                       |
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2)

IS

l_log_module                    VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.delete_row';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'BEGIN of procedure delete_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

DELETE FROM xla_product_rules_tl
WHERE application_id                   = x_application_id
  AND amb_context_code                 = x_amb_context_code
  AND product_rule_type_code           = x_product_rule_type_code
  AND product_rule_code                = x_product_rule_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_product_rules_b
WHERE application_id                   = x_application_id
  AND amb_context_code                 = x_amb_context_code
  AND product_rule_type_code           = x_product_rule_type_code
  AND product_rule_code                = x_product_rule_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;


IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure delete_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

END delete_row;

/*======================================================================+
|                                                                       |
|  Procedure add_language                                               |
|                                                                       |
+======================================================================*/
PROCEDURE add_language

IS

l_log_module                    VARCHAR2(240);
BEGIN
IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.add_language';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'BEGIN of procedure add_language',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;


DELETE FROM xla_product_rules_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_product_rules_b                b
       WHERE  b.application_id                   = t.application_id
         AND  b.amb_context_code                 = t.amb_context_code
         AND  b.product_rule_type_code           = t.product_rule_type_code
         AND  b.product_rule_code                = t.product_rule_code);

UPDATE xla_product_rules_tl   t
SET   (name
      ,description)
   = (SELECT b.name
            ,b.description
      FROM   xla_product_rules_tl               b
      WHERE  b.application_id                   = t.application_id
        AND  b.amb_context_code                 = t.amb_context_code
        AND  b.product_rule_type_code           = t.product_rule_type_code
        AND  b.product_rule_code                = t.product_rule_code
        AND  b.language                         = t.source_lang)
WHERE (t.application_id
      ,t.amb_context_code
      ,t.product_rule_type_code
      ,t.product_rule_code
      ,t.language)
    IN (SELECT subt.application_id
              ,subt.amb_context_code
              ,subt.product_rule_type_code
              ,subt.product_rule_code
              ,subt.language
        FROM   xla_product_rules_tl                   subb
              ,xla_product_rules_tl                   subt
        WHERE  subb.application_id                   = subt.application_id
         AND  subb.amb_context_code                  = subt.amb_context_code
         AND  subb.product_rule_type_code            = subt.product_rule_type_code
         AND  subb.product_rule_code                 = subt.product_rule_code
         AND  subb.language                         = subt.source_lang
         AND (SUBB.name                             <> SUBT.name
          OR  SUBB.description                      <> SUBT.description
          OR (subb.description                      IS NULL
         AND  subt.description                      IS NOT NULL)
          OR (subb.description                      IS NOT NULL
         AND  subt.description                      IS NULL)
      ))
;

INSERT INTO xla_product_rules_tl
(amb_context_code
,last_update_login
,creation_date
,created_by
,last_update_date
,last_updated_by
,application_id
,product_rule_type_code
,product_rule_code
,name
,description
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.amb_context_code
      ,b.last_update_login
      ,b.creation_date
      ,b.created_by
      ,b.last_update_date
      ,b.last_updated_by
      ,b.application_id
      ,b.product_rule_type_code
      ,b.product_rule_code
      ,b.name
      ,b.description
      ,l.language_code
      ,b.source_lang
FROM   xla_product_rules_tl             b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_product_rules_tl               t
       WHERE  t.application_id                   = b.application_id
         AND  t.amb_context_code                 = b.amb_context_code
         AND  t.product_rule_type_code           = b.product_rule_type_code
         AND  t.product_rule_code                = b.product_rule_code
         AND  t.language                         = l.language_code);

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure add_language',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

END add_language;

--=============================================================================
--
-- Name: translate_row
-- Description: To be used by FNDLOAD to upload a translated row
--
--=============================================================================
PROCEDURE translate_row
  (p_application_short_name       IN VARCHAR2
  ,p_amb_context_code             IN VARCHAR2
  ,p_product_rule_type_code       IN VARCHAR2
  ,p_product_rule_code            IN VARCHAR2
  ,p_name                         IN VARCHAR2
  ,p_description                  IN VARCHAR2
  ,p_owner                        IN VARCHAR2
  ,p_last_update_date             IN VARCHAR2
  ,p_custom_mode                  IN VARCHAR2)
IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
WHERE  application_short_name          = p_application_short_name;

  l_application_id        INTEGER;
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.translate_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  OPEN c_app_id;
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  BEGIN
    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_product_rules_tl
     WHERE application_id          = l_application_id
       AND amb_context_code        = p_amb_context_code
       AND product_rule_type_code  = p_product_rule_type_code
       AND product_rule_code       = p_product_rule_code
       AND language                = userenv('LANG');

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                               db_ludate, p_custom_mode)) then
      UPDATE xla_product_rules_tl
         SET name                    = p_name
            ,description             = p_description
            ,last_update_date        = f_ludate
            ,last_updated_by         = f_luby
            ,last_update_login       = 0
            ,source_lang             = userenv('LANG')
       WHERE userenv('LANG')         IN (language, source_lang)
         AND application_id          = l_application_id
         AND amb_context_code        = p_amb_context_code
         AND product_rule_type_code  = p_product_rule_type_code
         AND product_rule_code       = p_product_rule_code;

    END IF;



  END;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;


END translate_row;

--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN
   g_log_level          := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled        := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


end xla_product_rules_f_PKG;

/
