--------------------------------------------------------
--  DDL for Package Body XLA_ANALYTICAL_HDRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ANALYTICAL_HDRS_F_PKG" AS
/* $Header: xlathach.pkb 120.5.12010000.2 2009/08/13 13:02:49 krsankar ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_analytical_hdrs                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_analytical_hdrs                       |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_analytical_hdrs_f_pkg';

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
      (p_location   => 'xla_analytical_hdrs_f_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_balancing_flag                   IN VARCHAR2
  ,x_display_order                    IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_year_end_carry_forward_code      IN VARCHAR2
  ,x_display_in_inquiries_flag        IN VARCHAR2
  ,x_criterion_value_code             IN VARCHAR2
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
FROM   xla_analytical_hdrs_b
WHERE  analytical_criterion_code        = x_analytical_criterion_code
  AND  analytical_criterion_type_code   = x_analytical_criterion_type_co
  AND  amb_context_code                 = x_amb_context_code
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


INSERT INTO xla_analytical_hdrs_b
(creation_date
,created_by
,analytical_criterion_code
,analytical_criterion_type_code
,amb_context_code
,application_id
,balancing_flag
,display_order
,enabled_flag
,year_end_carry_forward_code
,display_in_inquiries_flag
,criterion_value_code
,updated_flag
,version_num
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_analytical_criterion_code
,x_analytical_criterion_type_co
,x_amb_context_code
,x_application_id
,x_balancing_flag
,x_display_order
,x_enabled_flag
,x_year_end_carry_forward_code
,x_display_in_inquiries_flag
,x_criterion_value_code
,'Y'
,0
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

INSERT INTO xla_analytical_hdrs_tl
(analytical_criterion_code
,analytical_criterion_type_code
,amb_context_code
,name
,description
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,language
,source_lang)
SELECT
       x_analytical_criterion_code
      ,x_analytical_criterion_type_co
      ,x_amb_context_code
      ,x_name
      ,x_description
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login
      ,l.language_code
      ,USERENV('LANG')
FROM   fnd_languages l
WHERE  l.installed_flag                 IN ('I', 'B')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_analytical_hdrs_tl             t
       WHERE  t.analytical_criterion_code        = x_analytical_criterion_code
         AND  t.analytical_criterion_type_code   = x_analytical_criterion_type_co
         AND  t.amb_context_code                 = x_amb_context_code
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
  (x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_balancing_flag                   IN VARCHAR2
  ,x_display_order                    IN NUMBER
  ,x_enabled_flag                     IN VARCHAR2
  ,x_year_end_carry_forward_code      IN VARCHAR2
  ,x_display_in_inquiries_flag        IN VARCHAR2
  ,x_criterion_value_code             IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2)

IS

CURSOR c IS
SELECT analytical_criterion_code
      ,application_id
      ,balancing_flag
      ,display_order
      ,enabled_flag
      ,year_end_carry_forward_code
      ,display_in_inquiries_flag
      ,criterion_value_code
FROM   xla_analytical_hdrs_b
WHERE  analytical_criterion_code        = x_analytical_criterion_code
  AND  analytical_criterion_type_code   = x_analytical_criterion_type_co
  AND  amb_context_code                 = x_amb_context_code
FOR UPDATE OF analytical_criterion_code NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT analytical_criterion_code
      ,name
      ,description
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_analytical_hdrs_tl
WHERE  analytical_criterion_code        = X_analytical_criterion_code
  AND  analytical_criterion_type_code   = X_analytical_criterion_type_co
  AND  amb_context_code                 = X_amb_context_code
  AND  USERENV('LANG')                 IN (language     ,source_lang)
FOR UPDATE OF analytical_criterion_code NOWAIT;

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

IF ( ((recinfo.application_id                   = X_application_id)
   OR ((recinfo.application_id                   IS NULL)
  AND (x_application_id                   IS NULL)))
 AND (recinfo.balancing_flag                   = x_balancing_flag)
 AND (recinfo.display_order                    = x_display_order)
 AND (recinfo.enabled_flag                     = x_enabled_flag)
 AND ((recinfo.year_end_carry_forward_code      = X_year_end_carry_forward_code)
   OR ((recinfo.year_end_carry_forward_code      IS NULL)
  AND (x_year_end_carry_forward_code      IS NULL)))
 AND (recinfo.display_in_inquiries_flag        = x_display_in_inquiries_flag)
 AND (recinfo.criterion_value_code             = x_criterion_value_code)
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
 (x_analytical_criterion_code        IN VARCHAR2
 ,x_analytical_criterion_type_co     IN VARCHAR2
 ,x_amb_context_code                 IN VARCHAR2
 ,x_application_id                   IN NUMBER
 ,x_balancing_flag                   IN VARCHAR2
 ,x_display_order                    IN NUMBER
 ,x_enabled_flag                     IN VARCHAR2
 ,x_year_end_carry_forward_code      IN VARCHAR2
 ,x_display_in_inquiries_flag        IN VARCHAR2
 ,x_criterion_value_code             IN VARCHAR2
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

UPDATE xla_analytical_hdrs_b
   SET
       last_update_date                 = x_last_update_date
      ,application_id                   = x_application_id
      ,balancing_flag                   = x_balancing_flag
      ,display_order                    = x_display_order
      ,enabled_flag                     = x_enabled_flag
      ,year_end_carry_forward_code      = x_year_end_carry_forward_code
      ,display_in_inquiries_flag        = x_display_in_inquiries_flag
      ,criterion_value_code             = x_criterion_value_code
      ,updated_flag                     = 'Y'
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  analytical_criterion_code        = X_analytical_criterion_code
  AND  analytical_criterion_type_code   = X_analytical_criterion_type_co
  AND  amb_context_code                 = X_amb_context_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_analytical_hdrs_tl
SET
       last_update_date                 = x_last_update_date
      ,name                             = X_name
      ,description                      = X_description
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  analytical_criterion_code        = X_analytical_criterion_code
  AND  analytical_criterion_type_code   = X_analytical_criterion_type_co
  AND  amb_context_code                 = X_amb_context_code
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
  (x_analytical_criterion_code        IN VARCHAR2
  ,x_analytical_criterion_type_co     IN VARCHAR2
  ,x_amb_context_code                 IN VARCHAR2)

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

DELETE FROM xla_analytical_hdrs_tl
WHERE analytical_criterion_code        = x_analytical_criterion_code
  AND analytical_criterion_type_code   = x_analytical_criterion_type_co
  AND amb_context_code                 = x_amb_context_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_analytical_hdrs_b
WHERE analytical_criterion_code        = x_analytical_criterion_code
  AND analytical_criterion_type_code   = x_analytical_criterion_type_co
  AND amb_context_code                 = x_amb_context_code;


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


DELETE FROM xla_analytical_hdrs_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_analytical_hdrs_b              b
       WHERE  b.analytical_criterion_code        = t.analytical_criterion_code
         AND  b.analytical_criterion_type_code   = t.analytical_criterion_type_code
         AND  b.amb_context_code                 = t.amb_context_code);

UPDATE xla_analytical_hdrs_tl   t
SET   (name
      ,description)
   = (SELECT b.name
            ,b.description
      FROM   xla_analytical_hdrs_tl             b
      WHERE  b.analytical_criterion_code        = t.analytical_criterion_code
        AND  b.analytical_criterion_type_code   = t.analytical_criterion_type_code
        AND  b.amb_context_code                 = t.amb_context_code
        AND  b.language                         = t.source_lang)
WHERE (t.analytical_criterion_code
      ,t.analytical_criterion_type_code
      ,t.amb_context_code
      ,t.language)
    IN (SELECT subt.analytical_criterion_code
              ,subt.analytical_criterion_type_code
              ,subt.amb_context_code
              ,subt.language
        FROM   xla_analytical_hdrs_tl                 subb
              ,xla_analytical_hdrs_tl                 subt
        WHERE  subb.analytical_criterion_code        = subt.analytical_criterion_code
         AND  subb.analytical_criterion_type_code    = subt.analytical_criterion_type_code
         AND  subb.amb_context_code                  = subt.amb_context_code
         AND  subb.language                         = subt.source_lang
         AND (SUBB.name                             <> SUBT.name
          OR  SUBB.description                      <> SUBT.description
          OR (subb.description                      IS NULL
         AND  subt.description                      IS NOT NULL)
          OR (subb.description                      IS NOT NULL
         AND  subt.description                      IS NULL)
      ))
;

INSERT INTO xla_analytical_hdrs_tl
(analytical_criterion_code
,analytical_criterion_type_code
,amb_context_code
,name
,description
,creation_date
,created_by
,last_update_date
,last_updated_by
,last_update_login
,language
,source_lang)
SELECT   /*+ ORDERED */
       b.analytical_criterion_code
      ,b.analytical_criterion_type_code
      ,b.amb_context_code
      ,b.name
      ,b.description
      ,b.creation_date
      ,b.created_by
      ,b.last_update_date
      ,b.last_updated_by
      ,b.last_update_login
      ,l.language_code
      ,b.source_lang
FROM   xla_analytical_hdrs_tl           b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_analytical_hdrs_tl             t
       WHERE  t.analytical_criterion_code        = b.analytical_criterion_code
         AND  t.analytical_criterion_type_code   = b.analytical_criterion_type_code
         AND  t.amb_context_code                 = b.amb_context_code
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
--              Newly overloaded procedure to handle deadlock issue while
--              performing UPDATE through AP and AR ldts
--=============================================================================
PROCEDURE translate_row
  (p_amb_context_code                 IN VARCHAR2
  ,p_analytical_criterion_type_co     IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2
  ,p_application_short_name           IN VARCHAR2)
IS
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);

  v_application_id        NUMBER;
  v_app_id                NUMBER;
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.translate_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of overloaded procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

--=======================================================================================
-- To avoid deadlock error, the logic we are using is, compare the application short name
-- of analytical criterion code and criterion type code passed from ldt for ANALYTICAL HDRS
-- data with the global application short name.
--     Only if both application ids are equal, then call translate_row else do NOTHING.
-- This way when loading AR ldt, the gloabl application short name is AR and data in ldt
-- for ANALYTICAL HDRS is SQLAP and hence translate row is not called for AR ldt and
-- deadlock error shouldn't occur.
--=======================================================================================

IF xla_analytical_hdrs_f_pkg.g_appl_short_name = p_application_short_name
THEN

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'Calling procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  translate_row
          (p_amb_context_code             => p_amb_context_code
          ,p_analytical_criterion_type_co => p_analytical_criterion_type_co
          ,p_analytical_criterion_code    => p_analytical_criterion_code
          ,p_name                         => p_name
          ,p_description                  => p_description
          ,p_owner                        => p_owner
          ,p_last_update_date             => p_last_update_date
          ,p_custom_mode                  => p_custom_mode);

 END IF;

 IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of overloaded procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
 END IF;

EXCEPTION
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_analytical_hdrs_f_pkg.translate_row');

END translate_row;


--=============================================================================
--
-- Name: translate_row
-- Description: To be used by FNDLOAD to upload a translated row
--
--=============================================================================
PROCEDURE translate_row
  (p_amb_context_code                 IN VARCHAR2
  ,p_analytical_criterion_type_co     IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2
  ,p_name                             IN VARCHAR2
  ,p_description                      IN VARCHAR2
  ,p_owner                            IN VARCHAR2
  ,p_last_update_date                 IN VARCHAR2
  ,p_custom_mode                      IN VARCHAR2)
IS
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

  BEGIN
    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_analytical_hdrs_tl
     WHERE amb_context_code                = p_amb_context_code
       AND analytical_criterion_type_code  = p_analytical_criterion_type_co
       AND analytical_criterion_code       = p_analytical_criterion_code
       AND language                        = userenv('LANG');

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                               db_ludate, p_custom_mode)) then
      UPDATE xla_analytical_hdrs_tl
         SET name                            = p_name
            ,description                     = p_description
            ,last_update_date                = f_ludate
            ,last_updated_by                 = f_luby
            ,last_update_login               = 0
            ,source_lang                     = userenv('LANG')
       WHERE userenv('LANG')                 IN (language, source_lang)
         AND amb_context_code                = p_amb_context_code
         AND analytical_criterion_type_code  = p_analytical_criterion_type_co
         AND analytical_criterion_code       = p_analytical_criterion_code;

    END IF;

    EXCEPTION
     WHEN no_data_found THEN
       null;


  END;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure translate_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_analytical_hdrs_f_pkg.translate_row');

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


end xla_analytical_hdrs_f_PKG;

/
