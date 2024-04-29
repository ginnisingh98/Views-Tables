--------------------------------------------------------
--  DDL for Package Body XLA_DESCRIPT_DETAILS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_DESCRIPT_DETAILS_F_PKG" AS
/* $Header: xlathded.pkb 120.18.12010000.1 2008/07/29 10:09:17 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_descript_details                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_descript_details                      |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_descript_details_f_pkg';

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
      (p_location   => 'xla_descript_details_f_pkg.trace');
END trace;



/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_description_detail_id            IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_display_description_flag         IN VARCHAR2
  ,x_description_prio_id              IN NUMBER
  ,x_user_sequence                    IN NUMBER
  ,x_value_type_code                  IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_literal                          IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_descript_details_b
WHERE  description_detail_id            = x_description_detail_id
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


INSERT INTO xla_descript_details_b
(creation_date
,created_by
,amb_context_code
,flexfield_segment_code
,display_description_flag
,description_detail_id
,description_prio_id
,user_sequence
,value_type_code
,source_application_id
,source_type_code
,source_code
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_amb_context_code
,x_flexfield_segment_code
,x_display_description_flag
,x_description_detail_id
,x_description_prio_id
,x_user_sequence
,x_value_type_code
,x_source_application_id
,x_source_type_code
,x_source_code
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

INSERT INTO xla_descript_details_tl
(description_detail_id
,literal
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,amb_context_code
,language
,source_lang)
SELECT
       x_description_detail_id
      ,x_literal
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,x_amb_context_code
      ,l.language_code
      ,USERENV('LANG')
FROM   fnd_languages l
WHERE  l.installed_flag                 IN ('I', 'B')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_descript_details_tl            t
       WHERE  t.description_detail_id            = x_description_detail_id
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
  (x_description_detail_id            IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_display_description_flag         IN VARCHAR2
  ,x_description_prio_id              IN NUMBER
  ,x_user_sequence                    IN NUMBER
  ,x_value_type_code                  IN VARCHAR2
  ,x_source_application_id            IN NUMBER
  ,x_source_type_code                 IN VARCHAR2
  ,x_source_code                      IN VARCHAR2
  ,x_literal                          IN VARCHAR2)

IS

CURSOR c IS
SELECT last_update_login
      ,amb_context_code
      ,flexfield_segment_code
      ,display_description_flag
      ,description_prio_id
      ,user_sequence
      ,value_type_code
      ,source_application_id
      ,source_type_code
      ,source_code
FROM   xla_descript_details_b
WHERE  description_detail_id            = x_description_detail_id
FOR UPDATE OF description_detail_id NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT description_detail_id
      ,literal
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_descript_details_tl
WHERE  description_detail_id            = X_description_detail_id
  AND  USERENV('LANG')                 IN (language     ,source_lang)
FOR UPDATE OF description_detail_id NOWAIT;

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

IF ( (recinfo.amb_context_code                 = x_amb_context_code)
 AND ((recinfo.flexfield_segment_code           = X_flexfield_segment_code)
   OR ((recinfo.flexfield_segment_code           IS NULL)
  AND (x_flexfield_segment_code           IS NULL)))
 AND ((recinfo.display_description_flag         = X_display_description_flag)
   OR ((recinfo.display_description_flag         IS NULL)
  AND (x_display_description_flag         IS NULL)))
 AND (recinfo.description_prio_id              = x_description_prio_id)
 AND (recinfo.user_sequence                    = x_user_sequence)
 AND ((recinfo.value_type_code                  = X_value_type_code)
   OR ((recinfo.value_type_code                  IS NULL)
  AND (x_value_type_code                  IS NULL)))
 AND ((recinfo.source_application_id            = X_source_application_id)
   OR ((recinfo.source_application_id            IS NULL)
  AND (x_source_application_id            IS NULL)))
 AND ((recinfo.source_type_code                 = X_source_type_code)
   OR ((recinfo.source_type_code                 IS NULL)
  AND (x_source_type_code                 IS NULL)))
 AND ((recinfo.source_code                      = X_source_code)
   OR ((recinfo.source_code                      IS NULL)
  AND (x_source_code                      IS NULL)))
                   ) THEN
   NULL;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

FOR tlinfo IN c1 LOOP
   IF (tlinfo.baselang = 'Y') THEN
      IF (    ((tlinfo.literal = X_literal)
               OR ((tlinfo.literal                          is null)
                AND (X_literal                          is null)))
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
 (x_description_detail_id            IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_flexfield_segment_code           IN VARCHAR2
 ,x_display_description_flag         IN VARCHAR2
 ,x_description_prio_id              IN NUMBER
 ,x_user_sequence                    IN NUMBER
 ,x_value_type_code                  IN VARCHAR2
 ,x_source_application_id            IN NUMBER
 ,x_source_type_code                 IN VARCHAR2
 ,x_source_code                      IN VARCHAR2
 ,x_literal                          IN VARCHAR2
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

UPDATE xla_descript_details_b
   SET
       last_update_date                 = x_last_update_date
      ,amb_context_code                 = x_amb_context_code
      ,flexfield_segment_code           = x_flexfield_segment_code
      ,display_description_flag         = x_display_description_flag
      ,description_prio_id              = x_description_prio_id
      ,user_sequence                    = x_user_sequence
      ,value_type_code                  = x_value_type_code
      ,source_application_id            = x_source_application_id
      ,source_type_code                 = x_source_type_code
      ,source_code                      = x_source_code
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  description_detail_id            = X_description_detail_id;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_descript_details_tl
SET
       last_update_date                 = x_last_update_date
      ,literal                          = X_literal
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  description_detail_id            = X_description_detail_id
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
  (x_description_detail_id            IN NUMBER)

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

DELETE FROM xla_descript_details_tl
WHERE description_detail_id            = x_description_detail_id;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_descript_details_b
WHERE description_detail_id            = x_description_detail_id;


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

DELETE FROM xla_descript_details_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_descript_details_b             b
       WHERE  b.description_detail_id            = t.description_detail_id);

UPDATE xla_descript_details_tl   t
SET   (literal)
   = (SELECT b.literal
      FROM   xla_descript_details_tl            b
      WHERE  b.description_detail_id            = t.description_detail_id
        AND  b.language                         = t.source_lang)
WHERE (t.description_detail_id
      ,t.language)
    IN (SELECT subt.description_detail_id
              ,subt.language
        FROM   xla_descript_details_tl                subb
              ,xla_descript_details_tl                subt
        WHERE  subb.description_detail_id            = subt.description_detail_id
         AND  subb.language                         = subt.source_lang
         AND (SUBB.literal                          <> SUBT.literal
          OR (subb.literal                          IS NULL
         AND  subt.literal                          IS NOT NULL)
          OR (subb.literal                          IS NOT NULL
         AND  subt.literal                          IS NULL)
      ))
;

INSERT INTO xla_descript_details_tl
(description_detail_id
,literal
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,amb_context_code
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.description_detail_id
      ,b.literal
      ,b.creation_date
      ,b.created_by
      ,b.last_update_date
      ,b.last_updated_by
      ,b.last_update_login
      ,b.amb_context_code
      ,l.language_code
      ,b.source_lang
FROM   xla_descript_details_tl          b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_descript_details_tl            t
       WHERE  t.description_detail_id            = b.description_detail_id
         AND  t.language                         = l.language_code);

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure add_language',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

END add_language;

/*======================================================================+
 * |                                                                       |
 * |  Procedure translate_row                                              |
 * |                                                                       |
 * +======================================================================*/
PROCEDURE translate_row
  (p_application_short_name      IN VARCHAR2
  ,p_amb_context_code            IN VARCHAR2
  ,p_description_type_code       IN VARCHAR2
  ,p_description_code            IN VARCHAR2
  ,p_priority_num                IN VARCHAR2
  ,p_user_sequence               IN VARCHAR2
  ,p_literal                     IN VARCHAR2
  ,p_owner                       IN VARCHAR2
  ,p_last_update_date            IN VARCHAR2
  ,p_custom_mode                 IN VARCHAR2)
IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_application_short_name;

  l_application_id        INTEGER;
  l_description_prio_id   INTEGER;
  l_description_detail_id INTEGER;

  CURSOR c_prio IS
  SELECT description_prio_id
    FROM xla_desc_priorities
   WHERE application_id        = l_application_id
     AND amb_context_code      = p_amb_context_code
     AND description_type_code = p_description_type_code
     AND description_code      = p_description_code
     AND user_sequence         = p_priority_num;

  CURSOR c_dtl IS
  SELECT description_detail_id
    FROM xla_descript_details_b
   WHERE amb_context_code    = p_amb_context_code
     AND description_prio_id = l_description_prio_id
     AND user_sequence       = p_user_sequence;

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

  OPEN c_prio;
  FETCH c_prio INTO l_description_prio_id;
  CLOSE c_prio;

  OPEN c_dtl;
  FETCH c_dtl INTO l_description_detail_id;
  CLOSE c_dtl;

  BEGIN
    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_descript_details_tl
     WHERE amb_context_code       = p_amb_context_code
       AND description_detail_id  = l_description_detail_id
       AND language               = userenv('LANG');

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                               db_ludate, p_custom_mode)) then
      UPDATE xla_descript_details_tl
         SET literal                = p_literal
            ,last_update_date       = f_ludate
            ,last_updated_by        = f_luby
            ,last_update_login      = 0
            ,source_lang            = userenv('LANG')
       WHERE userenv('LANG')        IN (language, source_lang)
         AND amb_context_code       = p_amb_context_code
         AND description_detail_id  = l_description_detail_id;

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


end xla_descript_details_f_PKG;

/
