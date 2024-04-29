--------------------------------------------------------
--  DDL for Package Body XLA_SOURCES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SOURCES_F_PKG" AS
/* $Header: xlathsou.pkb 120.25.12010000.1 2008/07/29 10:10:26 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_sources                                                        |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_sources                               |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
+======================================================================*/
-- Constants

C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;
C_LEVEL_LOG_DISABLED  CONSTANT NUMBER := 99;
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_sources_f_pkg';
-- Global variables for debugging
g_log_level     PLS_INTEGER  :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_log_enabled   BOOLEAN :=  fnd_log.test
                               (log_level  => g_log_level
                               ,module     => C_DEFAULT_MODULE);


PROCEDURE trace (p_msg          IN VARCHAR2
                ,p_level        IN NUMBER
                ,p_module       IN VARCHAR2) IS
BEGIN

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
         (p_location   => 'xla_sources_f_pkg.trace');
END trace;

/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_source_code                      IN VARCHAR2
  ,x_source_type_code                 IN VARCHAR2
  ,x_plsql_function_name              IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_sum_flag                         IN VARCHAR2
  ,x_visible_flag                     IN VARCHAR2
  ,x_translated_flag                  IN VARCHAR2
  ,x_lookup_type                      IN VARCHAR2
  ,x_view_application_id              IN NUMBER
  ,x_datatype_code                    IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_key_flexfield_flag               IN VARCHAR2
  ,x_segment_code                     IN VARCHAR2
  ,x_flexfield_application_id         IN NUMBER
  ,x_id_flex_code                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_source_column_name               IN VARCHAR2
  ,x_source_table_name                IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_sources_b
WHERE  application_id                   = x_application_id
  AND  source_code                      = x_source_code
  AND  source_type_code                 = x_source_type_code
;

BEGIN
xla_utility_pkg.trace('> xla_sources_f_pkg.insert_row'                    ,20);

INSERT INTO xla_sources_b
(creation_date
,created_by
,plsql_function_name
,source_type_code
,application_id
,flex_value_set_id
,sum_flag
,visible_flag
,translated_flag
,lookup_type
,view_application_id
,datatype_code
,source_code
,enabled_flag
,key_flexfield_flag
,segment_code
,flexfield_application_id
,id_flex_code
,source_table_name
,source_column_name
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_plsql_function_name
,x_source_type_code
,x_application_id
,x_flex_value_set_id
,x_sum_flag
,x_visible_flag
,x_translated_flag
,x_lookup_type
,x_view_application_id
,x_datatype_code
,x_source_code
,x_enabled_flag
,x_key_flexfield_flag
,x_segment_code
,x_flexfield_application_id
,x_id_flex_code
,x_source_table_name
,x_source_column_name
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

INSERT INTO xla_sources_tl
(name
,description
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,application_id
,source_type_code
,source_code
,language
,source_lang)
SELECT
       x_name
      ,x_description
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,x_application_id
      ,x_source_type_code
      ,x_source_code
      ,l.language_code
      ,USERENV('LANG')
FROM   fnd_languages l
WHERE  l.installed_flag                 IN ('I', 'B')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_sources_tl                     t
       WHERE  t.application_id                   = x_application_id
         AND  t.source_code                      = x_source_code
         AND  t.source_type_code                 = x_source_type_code
         AND  t.language                         = l.language_code);

OPEN c;
FETCH c INTO x_rowid;

IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
END IF;
CLOSE c;

xla_utility_pkg.trace('< xla_sources_f_pkg.insert_row'                    ,20);

EXCEPTION
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_f_pkg.insert_row');

END insert_row;

/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE lock_row
  (x_application_id                   IN NUMBER
  ,x_source_code                      IN VARCHAR2
  ,x_source_type_code                 IN VARCHAR2
  ,x_plsql_function_name              IN VARCHAR2
  ,x_flex_value_set_id                IN NUMBER
  ,x_sum_flag                         IN VARCHAR2
  ,x_visible_flag                     IN VARCHAR2
  ,x_translated_flag                  IN VARCHAR2
  ,x_lookup_type                      IN VARCHAR2
  ,x_view_application_id              IN NUMBER
  ,x_datatype_code                    IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_key_flexfield_flag               IN VARCHAR2
  ,x_segment_code                     IN VARCHAR2
  ,x_flexfield_application_id         IN NUMBER
  ,x_id_flex_code                     IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2)

IS

  l_log_module             VARCHAR2(240);
CURSOR c IS
SELECT plsql_function_name
      ,flex_value_set_id
      ,sum_flag
      ,visible_flag
      ,translated_flag
      ,lookup_type
      ,view_application_id
      ,datatype_code
      ,enabled_flag
      ,key_flexfield_flag
      ,segment_code
      ,flexfield_application_id
      ,id_flex_code
FROM   xla_sources_b
WHERE  application_id                   = x_application_id
  AND  source_code                      = x_source_code
  AND  source_type_code                 = x_source_type_code
FOR UPDATE OF application_id NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT language
      ,name
      ,description
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_sources_tl
WHERE  application_id                   = X_application_id
  AND  source_code                      = X_source_code
  AND  source_type_code                 = X_source_type_code
  AND  USERENV('LANG')                 IN (language     ,source_lang)
FOR UPDATE OF application_id NOWAIT;

BEGIN

   IF g_log_enabled THEN
      l_log_module := C_DEFAULT_MODULE||'.lock_row';
   END IF;
   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
      trace('lock_row.Begin',C_LEVEL_PROCEDURE,l_log_module);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace('------------------------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);
     trace('x_application_id            =  ' || x_application_id               ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_source_code               =  ' || x_source_code                  ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_source_type_code          =  ' || x_source_type_code             ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_plsql_function_name       =  ' || x_plsql_function_name          ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_flex_value_set_id         =  ' || x_flex_value_set_id            ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_sum_flag                  =  ' || x_sum_flag                     ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_visible_flag              =  ' || x_visible_flag                 ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_translated_flag           =  ' || x_translated_flag              ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_lookup_type               =  ' || x_lookup_type                  ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_view_application_id       =  ' || x_view_application_id          ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_datatype_code             =  ' || x_datatype_code                ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_enabled_flag              =  ' || x_enabled_flag                 ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_key_flexfield_flag        =  ' || x_key_flexfield_flag           ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_segment_code              =  ' || x_segment_code                 ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_flexfield_application_id  =  ' || x_flexfield_application_id     ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_id_flex_code              =  ' || x_id_flex_code                 ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_name                      =  ' || x_name                         ,C_LEVEL_STATEMENT,l_log_module);
     trace('x_description               =  ' || x_description                  ,C_LEVEL_STATEMENT,l_log_module);
     trace('------------------------------------------------------------------',C_LEVEL_STATEMENT,l_log_module);
   END IF;

OPEN c;
FETCH c INTO recinfo;

IF (c%NOTFOUND) THEN
   CLOSE c;
   fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
   app_exception.raise_exception;
END IF;
CLOSE c;

IF ( ((recinfo.plsql_function_name              = X_plsql_function_name)
   OR ((recinfo.plsql_function_name              IS NULL)
  AND (x_plsql_function_name              IS NULL)))
 AND ((recinfo.flex_value_set_id                = X_flex_value_set_id)
   OR ((recinfo.flex_value_set_id                IS NULL)
  AND (x_flex_value_set_id                IS NULL)))
 AND (recinfo.sum_flag                         = x_sum_flag)
 AND (recinfo.visible_flag                     = x_visible_flag)
 AND ((recinfo.translated_flag                  = X_translated_flag)
   OR ((recinfo.translated_flag                  IS NULL)
  AND (x_translated_flag                  IS NULL)))
 AND ((recinfo.lookup_type                      = X_lookup_type)
   OR ((recinfo.lookup_type                      IS NULL)
  AND (x_lookup_type                      IS NULL)))
 AND ((recinfo.view_application_id              = X_view_application_id)
   OR ((recinfo.view_application_id              IS NULL)
  AND (x_view_application_id              IS NULL)))
 AND (recinfo.datatype_code                    = x_datatype_code)
 AND (recinfo.enabled_flag                     = x_enabled_flag)
  AND (recinfo.key_flexfield_flag                     = x_key_flexfield_flag)
  AND ((recinfo.segment_code                = X_segment_code)
   OR ((recinfo.segment_code                IS NULL)
  AND (x_segment_code                IS NULL)))
  AND ((recinfo.flexfield_application_id                = X_flexfield_application_id)
   OR ((recinfo.flexfield_application_id                IS NULL)
  AND (x_flexfield_application_id                IS NULL)))
  AND ((recinfo.id_flex_code                = X_id_flex_code)
   OR ((recinfo.id_flex_code                IS NULL)
  AND (x_id_flex_code                IS NULL)))
                   ) THEN

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('lock_row successful.',C_LEVEL_STATEMENT,l_log_module);
   END IF;
ELSE
   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('lock_row failed. ',C_LEVEL_STATEMENT,l_log_module);
   END IF;
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
      trace('Before Loop tlinfo',C_LEVEL_STATEMENT,l_log_module);
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
            IF (C_LEVEL_STATEMENT >= g_log_level) THEN
               trace('tlinfo failed',C_LEVEL_STATEMENT,l_log_module);
               trace('tlinfo.name        = ' || tlinfo.name,C_LEVEL_STATEMENT,l_log_module);
               trace('X_name             = ' || X_name,C_LEVEL_STATEMENT,l_log_module);
               trace('tlinfo.description = ' || tlinfo.description ,C_LEVEL_STATEMENT,l_log_module);
               trace('X_description      = ' || X_description ,C_LEVEL_STATEMENT,l_log_module);
            END IF;

            IF tlinfo.name <> X_name THEN
                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                   trace('Name is different ',C_LEVEL_STATEMENT,l_log_module);
                END IF;
            END IF;
            IF tlinfo.description <> X_description THEN
                IF (C_LEVEL_STATEMENT >= g_log_level) THEN
                   trace('description is different ',C_LEVEL_STATEMENT,l_log_module);
                END IF;
            END IF;

            fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
            app_exception.raise_exception;
         END IF;
      END IF;
   END LOOP;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace('lock_row.End',C_LEVEL_PROCEDURE,l_Log_module);
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
 ,x_source_code                      IN VARCHAR2
 ,x_source_type_code                 IN VARCHAR2
 ,x_plsql_function_name              IN VARCHAR2
 ,x_flex_value_set_id                IN NUMBER
 ,x_sum_flag                         IN VARCHAR2
 ,x_visible_flag                     IN VARCHAR2
 ,x_translated_flag                  IN VARCHAR2
 ,x_lookup_type                      IN VARCHAR2
 ,x_view_application_id              IN NUMBER
 ,x_datatype_code                    IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
  ,x_key_flexfield_flag               IN VARCHAR2
  ,x_segment_code                     IN VARCHAR2
  ,x_flexfield_application_id         IN NUMBER
  ,x_id_flex_code                     IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_source_column_name               IN VARCHAR2
 ,x_source_table_name                IN VARCHAR2
 ,x_last_update_date                  IN DATE
 ,x_last_updated_by                   IN NUMBER
 ,x_last_update_login                 IN NUMBER)

IS

BEGIN
xla_utility_pkg.trace('> xla_sources_f_pkg.update_row'                    ,20);
UPDATE xla_sources_b
   SET
       last_update_date                 = x_last_update_date
      ,plsql_function_name              = x_plsql_function_name
      ,flex_value_set_id                = x_flex_value_set_id
      ,sum_flag                         = x_sum_flag
      ,visible_flag                     = x_visible_flag
      ,translated_flag                  = x_translated_flag
      ,lookup_type                      = x_lookup_type
      ,view_application_id              = x_view_application_id
      ,datatype_code                    = x_datatype_code
      ,enabled_flag                     = x_enabled_flag
      ,key_flexfield_flag               = x_key_flexfield_flag
      ,segment_code                     = x_segment_code
      ,flexfield_application_id         = x_flexfield_application_id
      ,id_flex_code                     = x_id_flex_code
      ,source_column_name               = x_source_column_name
      ,source_table_name                = x_source_table_name
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = X_application_id
  AND  source_code                      = X_source_code
  AND  source_type_code                 = X_source_type_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_sources_tl
SET
       last_update_date                 = x_last_update_date
      ,name                             = X_name
      ,description                      = X_description
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  application_id                   = X_application_id
  AND  source_code                      = X_source_code
  AND  source_type_code                 = X_source_type_code
  AND  USERENV('LANG')                 IN (language, source_lang);

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

xla_utility_pkg.trace('< xla_sources_f_pkg.update_row'                    ,20);
END update_row;

/*======================================================================+
|                                                                       |
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_source_code                      IN VARCHAR2
  ,x_source_type_code                 IN VARCHAR2)

IS

BEGIN
xla_utility_pkg.trace('> xla_sources_f_pkg.delete_row'                    ,20);
DELETE FROM xla_sources_tl
WHERE application_id                   = x_application_id
  AND source_code                      = x_source_code
  AND source_type_code                 = x_source_type_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_sources_b
WHERE application_id                   = x_application_id
  AND source_code                      = x_source_code
  AND source_type_code                 = x_source_type_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;


xla_utility_pkg.trace('< xla_sources_f_pkg.delete_row'                    ,20);
END delete_row;

/*======================================================================+
|                                                                       |
|  Procedure add_language                                               |
|                                                                       |
+======================================================================*/
PROCEDURE add_language

IS

BEGIN
xla_utility_pkg.trace('> xla_sources_f_pkg.add_language'                  ,20);

DELETE FROM xla_sources_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_sources_b                      b
       WHERE  b.application_id                   = t.application_id
         AND  b.source_code                      = t.source_code
         AND  b.source_type_code                 = t.source_type_code);

UPDATE xla_sources_tl   t
SET   (name
      ,description)
   = (SELECT b.name
            ,b.description
      FROM   xla_sources_tl                     b
      WHERE  b.application_id                   = t.application_id
        AND  b.source_code                      = t.source_code
        AND  b.source_type_code                 = t.source_type_code
        AND  b.language                         = t.source_lang)
WHERE (t.application_id
      ,t.source_code
      ,t.source_type_code
      ,t.language)
    IN (SELECT subt.application_id
              ,subt.source_code
              ,subt.source_type_code
              ,subt.language
        FROM   xla_sources_tl                         subb
              ,xla_sources_tl                         subt
        WHERE  subb.application_id                   = subt.application_id
         AND  subb.source_code                       = subt.source_code
         AND  subb.source_type_code                  = subt.source_type_code
         AND  subb.language                         = subt.source_lang
         AND (SUBB.name                             <> SUBT.name
          OR  SUBB.description                      <> SUBT.description
          OR (subb.description                      IS NULL
         AND  subt.description                      IS NOT NULL)
          OR (subb.description                      IS NOT NULL
         AND  subt.description                      IS NULL)
      ))
;

INSERT INTO xla_sources_tl
(name
,description
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,application_id
,source_type_code
,source_code
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.name
      ,b.description
      ,b.creation_date
      ,b.created_by
      ,b.last_update_date
      ,b.last_updated_by
      ,b.last_update_login
      ,b.application_id
      ,b.source_type_code
      ,b.source_code
      ,l.language_code
      ,b.source_lang
FROM   xla_sources_tl                   b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_sources_tl                     t
       WHERE  t.application_id                   = b.application_id
         AND  t.source_code                      = b.source_code
         AND  t.source_type_code                 = b.source_type_code
         AND  t.language                         = l.language_code);

xla_utility_pkg.trace('< xla_sources_f_pkg.add_language'                  ,20);
END add_language;

/*======================================================================+
|                                                                       |
|  Procedure load_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE load_row
  (p_appl_short_name                  IN VARCHAR2
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_datatype_code                    IN VARCHAR2
  ,p_plsql_function_name              IN VARCHAR2
  ,p_flex_value_set_name              IN VARCHAR2
  ,p_sum_flag                         IN VARCHAR2
  ,p_visible_flag                     IN VARCHAR2
  ,p_translated_flag                  IN VARCHAR2
  ,p_enabled_flag                     IN VARCHAR2
  ,p_view_appl_short_name             IN VARCHAR2
  ,p_lookup_type                      IN VARCHAR2
  ,p_key_flexfield_flag               IN VARCHAR2
  ,p_segment_code                     IN VARCHAR2
  ,p_flex_appl_short_name             IN VARCHAR2
  ,p_id_flex_code                     IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_source_column_name               IN VARCHAR2
  ,p_source_table_name                IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2)
IS

  l_view_application_id   number(38);
  l_flex_application_id   number(38);
  l_application_id        number(38);
  l_flex_value_set_id     number(38);
  l_rowid                ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  number(38);  -- entity owner in file
  f_ludate                date;        -- entity update date in file
  db_luby                 number(38);  -- entity owner in db
  db_ludate               date;        -- entity update date in db

  CURSOR c_appl
  IS
  SELECT application_id
    FROM fnd_application
   WHERE application_short_name = p_appl_short_name;

  CURSOR c_view_appl
  IS
  SELECT application_id
    FROM fnd_application
   WHERE application_short_name = p_view_appl_short_name;

  CURSOR c_flex
  IS
  SELECT flex_value_set_id
    FROM fnd_flex_value_sets
   WHERE flex_value_set_name = p_flex_value_set_name;

  CURSOR c_flex_appl
  IS
  SELECT application_id
    FROM fnd_application
   WHERE application_short_name = p_flex_appl_short_name;

BEGIN

   OPEN c_appl;
   FETCH c_appl
    INTO l_application_id;
   CLOSE c_appl;

   OPEN c_view_appl;
   FETCH c_view_appl
    INTO l_view_application_id;
   CLOSE c_view_appl;

   OPEN c_flex;
   FETCH c_flex
    INTO l_flex_value_set_id;
   CLOSE c_flex;

   OPEN c_flex_appl;
   FETCH c_flex_appl
    INTO l_flex_application_id;
   CLOSE c_flex_appl;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  BEGIN

     SELECT last_updated_by, last_update_date
       INTO db_luby, db_ludate
       FROM xla_sources_vl
      WHERE application_id   = l_application_id
        AND source_code      = p_source_code
        AND source_type_code = p_source_type_code;

     IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, null)) then
        xla_sources_f_pkg.update_row
          (x_application_id           => l_application_id
          ,x_source_code              => p_source_code
          ,x_source_type_code         => p_source_type_code
          ,x_plsql_function_name      => p_plsql_function_name
          ,x_flex_value_set_id        => l_flex_value_set_id
          ,x_sum_flag                 => p_sum_flag
          ,x_visible_flag             => p_visible_flag
          ,x_translated_flag          => p_translated_flag
          ,x_lookup_type              => p_lookup_type
          ,x_view_application_id      => l_view_application_id
          ,x_datatype_code            => p_datatype_code
          ,x_enabled_flag             => p_enabled_flag
          ,x_key_flexfield_flag       => p_key_flexfield_flag
          ,x_segment_code             => p_segment_code
          ,x_flexfield_application_id => l_flex_application_id
          ,x_id_flex_code             => p_id_flex_code
          ,x_name                     => p_name
          ,x_description              => p_description
          ,x_source_column_name       => p_source_column_name
          ,x_source_table_name        => p_source_table_name
          ,x_last_update_date         => f_ludate
          ,x_last_updated_by          => f_luby
          ,x_last_update_login        => 0);

     END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
       xla_sources_f_pkg.insert_row
         (x_rowid                => l_rowid
         ,x_application_id       => l_application_id
         ,x_source_code          => p_source_code
         ,x_source_type_code     => p_source_type_code
         ,x_plsql_function_name  => p_plsql_function_name
         ,x_flex_value_set_id    => l_flex_value_set_id
         ,x_sum_flag             => p_sum_flag
         ,x_visible_flag         => p_visible_flag
         ,x_translated_flag      => p_translated_flag
         ,x_lookup_type          => p_lookup_type
         ,x_view_application_id  => l_view_application_id
         ,x_datatype_code        => p_datatype_code
         ,x_enabled_flag         => p_enabled_flag
         ,x_key_flexfield_flag   => p_key_flexfield_flag
         ,x_segment_code         => p_segment_code
         ,x_flexfield_application_id => l_flex_application_id
         ,x_id_flex_code         => p_id_flex_code
         ,x_name                 => p_name
         ,x_description          => p_description
         ,x_source_column_name   => p_source_column_name
         ,x_source_table_name    => p_source_table_name
         ,x_creation_date        => f_ludate
         ,x_created_by           => f_luby
         ,x_last_update_date     => f_ludate
         ,x_last_updated_by      => f_luby
         ,x_last_update_login    => 0);

  END;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_sources_f_pkg.load_row');

END load_row;

/*======================================================================+
|                                                                       |
|  Procedure translate_row                                              |
|                                                                       |
+======================================================================*/
PROCEDURE translate_row
  (p_appl_short_name                  IN VARCHAR2
  ,p_source_code                      IN VARCHAR2
  ,p_source_type_code                 IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2)
IS

  l_view_application_id   number(38);
  l_application_id        number(38);
  l_row_id                ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  number(38);  -- entity owner in file
  f_ludate                date;        -- entity update date in file
  db_luby                 number(38);  -- entity owner in db
  db_ludate               date;        -- entity update date in db

  CURSOR c_appl
  IS
  SELECT application_id
    FROM fnd_application
   WHERE application_short_name = p_appl_short_name;

BEGIN

   OPEN c_appl;
   FETCH c_appl
    INTO l_application_id;
   CLOSE c_appl;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  BEGIN
     SELECT last_updated_by, last_update_date
       INTO db_luby, db_ludate
       FROM xla_sources_tl
      WHERE application_id   = l_application_id
        AND source_code      = p_source_code
        AND source_type_code = p_source_type_code
        AND language         = userenv('LANG');

     IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, p_custom_mode)) then
        UPDATE xla_sources_tl
           SET name              = p_name
              ,description       = p_description
              ,last_update_date  = f_ludate
              ,last_updated_by   = f_luby
              ,last_update_login = 0
              ,source_lang       = userenv('LANG')
         WHERE userenv('LANG')   IN (language, source_lang)
           AND application_id    = l_application_id
           AND source_code       = p_source_code
           AND source_type_code  = p_source_type_code;

     END IF;


  END;



END translate_row;
BEGIN
--   l_log_module     := C_DEFAULT_MODULE;
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;
end xla_sources_f_PKG;

/
