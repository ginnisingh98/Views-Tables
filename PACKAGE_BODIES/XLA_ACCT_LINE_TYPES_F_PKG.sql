--------------------------------------------------------
--  DDL for Package Body XLA_ACCT_LINE_TYPES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ACCT_LINE_TYPES_F_PKG" AS
/* $Header: xlathalt.pkb 120.27.12010000.1 2008/07/29 10:09:09 appldev ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_acct_line_types                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_acct_line_types                       |
|                                                                       |
| HISTORY                                                               |
|    Generated from XLAUTB.                                             |
|                                                                       |
|    05-Apr-05  eklau   Added new column mpa_option_code to insert and  |
|                       update procedures.                              |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_acct_line_types_f_pkg';

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
      (p_location   => 'xla_acct_line_types_f_pkg.trace');
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
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_entry_type_code       IN VARCHAR2
  ,x_natural_side_code                IN VARCHAR2
  ,x_gl_transfer_mode_code            IN VARCHAR2
  ,x_switch_side_flag                 IN VARCHAR2
  ,x_gain_or_loss_flag                IN VARCHAR2
  ,x_merge_duplicate_code             IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2
  ,x_rounding_class_code              IN VARCHAR2
  ,x_business_method_code             IN VARCHAR2
  ,x_business_class_code              IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER
  ,x_mpa_option_code                  IN VARCHAR2
  ,x_encumbrance_type_id              IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_acct_line_types_b
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code
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

INSERT INTO xla_acct_line_types_b
(creation_date
,created_by
,amb_context_code
,application_id
,entity_code
,event_class_code
,accounting_line_type_code
,accounting_line_code
,transaction_coa_id
,accounting_entry_type_code
,natural_side_code
,gl_transfer_mode_code
,switch_side_flag
,gain_or_loss_flag
,merge_duplicate_code
,enabled_flag
,accounting_class_code
,rounding_class_code
,business_method_code
,business_class_code
,last_update_date
,last_updated_by
,last_update_login
,mpa_option_code
,encumbrance_type_id)
VALUES
(x_creation_date
,x_created_by
,x_amb_context_code
,x_application_id
,x_entity_code
,x_event_class_code
,x_accounting_line_type_code
,x_accounting_line_code
,x_transaction_coa_id
,x_accounting_entry_type_code
,x_natural_side_code
,x_gl_transfer_mode_code
,x_switch_side_flag
,x_gain_or_loss_flag
,x_merge_duplicate_code
,x_enabled_flag
,x_accounting_class_code
,x_rounding_class_code
,x_business_method_code
,x_business_class_code
,x_last_update_date
,x_last_updated_by
,x_last_update_login
,x_mpa_option_code
,x_encumbrance_type_id)
;

INSERT INTO xla_acct_line_types_tl
(amb_context_code
,application_id
,entity_code
,event_class_code
,accounting_line_type_code
,accounting_line_code
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
       x_amb_context_code
      ,x_application_id
      ,x_entity_code
      ,x_event_class_code
      ,x_accounting_line_type_code
      ,x_accounting_line_code
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
       FROM   xla_acct_line_types_tl             t
       WHERE  t.application_id                   = x_application_id
         AND  t.amb_context_code                 = x_amb_context_code
         AND  t.entity_code                      = x_entity_code
         AND  t.event_class_code                 = x_event_class_code
         AND  t.accounting_line_type_code        = x_accounting_line_type_code
         AND  t.accounting_line_code             = x_accounting_line_code
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
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_transaction_coa_id               IN NUMBER
  ,x_accounting_entry_type_code       IN VARCHAR2
  ,x_natural_side_code                IN VARCHAR2
  ,x_gl_transfer_mode_code            IN VARCHAR2
  ,x_switch_side_flag                 IN VARCHAR2
  ,x_gain_or_loss_flag                IN VARCHAR2
  ,x_merge_duplicate_code             IN VARCHAR2
  ,x_enabled_flag                     IN VARCHAR2
  ,x_accounting_class_code            IN VARCHAR2
  ,x_rounding_class_code              IN VARCHAR2
  ,x_business_method_code             IN VARCHAR2
  ,x_business_class_code              IN VARCHAR2
  ,x_name                             IN VARCHAR2
  ,x_description                      IN VARCHAR2
  ,x_mpa_option_code                  IN VARCHAR2
  ,x_encumbrance_type_id              IN NUMBER)

IS

CURSOR c IS
SELECT amb_context_code
      ,transaction_coa_id
      ,accounting_entry_type_code
      ,natural_side_code
      ,gl_transfer_mode_code
      ,switch_side_flag
      ,gain_or_loss_flag
      ,merge_duplicate_code
      ,enabled_flag
      ,accounting_class_code
      ,rounding_class_code
      ,business_method_code
      ,business_class_code
      ,mpa_option_code
      ,encumbrance_type_id
FROM   xla_acct_line_types_b
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code
FOR UPDATE OF application_id NOWAIT;

recinfo              c%ROWTYPE;

CURSOR c1 IS
SELECT amb_context_code
      ,name
      ,description
      ,DECODE(language     , USERENV('LANG'), 'Y', 'N') baselang
FROM   xla_acct_line_types_tl
WHERE  application_id                   = X_application_id
  AND  amb_context_code                 = X_amb_context_code
  AND  entity_code                      = X_entity_code
  AND  event_class_code                 = X_event_class_code
  AND  accounting_line_type_code        = X_accounting_line_type_code
  AND  accounting_line_code             = X_accounting_line_code
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

IF ( ((recinfo.transaction_coa_id               = X_transaction_coa_id)
   OR ((recinfo.transaction_coa_id               IS NULL)
  AND (x_transaction_coa_id               IS NULL)))
  AND ((recinfo.encumbrance_type_id               = X_encumbrance_type_id)
   OR ((recinfo.encumbrance_type_id               IS NULL)
  AND (x_encumbrance_type_id               IS NULL)))
 AND (recinfo.accounting_entry_type_code       = x_accounting_entry_type_code)
 AND (recinfo.natural_side_code                = x_natural_side_code)
 AND (recinfo.gl_transfer_mode_code            = x_gl_transfer_mode_code)
 AND ((recinfo.switch_side_flag                 = x_switch_side_flag)
   OR ((recinfo.switch_side_flag  IS NULL)
     AND (x_switch_side_flag IS NULL)))
 AND ((recinfo.gain_or_loss_flag                 = x_gain_or_loss_flag)
   OR ((recinfo.gain_or_loss_flag  IS NULL)
     AND (x_gain_or_loss_flag IS NULL)))
 AND (recinfo.merge_duplicate_code             = x_merge_duplicate_code)
 AND (recinfo.enabled_flag                     = x_enabled_flag)
 AND (recinfo.accounting_class_code            = x_accounting_class_code)
 AND (recinfo.rounding_class_code              = x_rounding_class_code)
 AND (recinfo.business_method_code              = x_business_method_code)
 AND ((recinfo.business_class_code                 = x_business_class_code)
   OR ((recinfo.business_class_code  IS NULL)
     AND (x_business_class_code IS NULL)))
 AND (recinfo.mpa_option_code                  = x_mpa_option_code)
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
 ,x_entity_code                      IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_accounting_line_type_code        IN VARCHAR2
 ,x_accounting_line_code             IN VARCHAR2
 ,x_transaction_coa_id               IN NUMBER
 ,x_accounting_entry_type_code       IN VARCHAR2
 ,x_natural_side_code                IN VARCHAR2
 ,x_gl_transfer_mode_code            IN VARCHAR2
 ,x_switch_side_flag                 IN VARCHAR2
  ,x_gain_or_loss_flag                IN VARCHAR2
 ,x_merge_duplicate_code             IN VARCHAR2
 ,x_enabled_flag                     IN VARCHAR2
 ,x_accounting_class_code            IN VARCHAR2
 ,x_rounding_class_code              IN VARCHAR2
 ,x_business_method_code             IN VARCHAR2
 ,x_business_class_code              IN VARCHAR2
 ,x_name                             IN VARCHAR2
 ,x_description                      IN VARCHAR2
 ,x_last_update_date                  IN DATE
 ,x_last_updated_by                   IN NUMBER
 ,x_last_update_login                 IN NUMBER
 ,x_mpa_option_code                   IN VARCHAR2
 ,x_encumbrance_type_id              IN NUMBER)

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

UPDATE xla_acct_line_types_b
   SET
       last_update_date                 = x_last_update_date
      ,transaction_coa_id               = x_transaction_coa_id
      ,accounting_entry_type_code       = x_accounting_entry_type_code
      ,natural_side_code                = x_natural_side_code
      ,gl_transfer_mode_code            = x_gl_transfer_mode_code
      ,switch_side_flag                 = x_switch_side_flag
      ,gain_or_loss_flag                = x_gain_or_loss_flag
      ,merge_duplicate_code             = x_merge_duplicate_code
      ,enabled_flag                     = x_enabled_flag
      ,accounting_class_code            = x_accounting_class_code
      ,rounding_class_code              = x_rounding_class_code
      ,business_method_code             = x_business_method_code
      ,business_class_code              = x_business_class_code
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,mpa_option_code                  = x_mpa_option_code
      ,encumbrance_type_id              = x_encumbrance_type_id
WHERE  application_id                   = X_application_id
  AND  amb_context_code                 = X_amb_context_code
  AND  entity_code                      = X_entity_code
  AND  event_class_code                 = X_event_class_code
  AND  accounting_line_type_code        = X_accounting_line_type_code
  AND  accounting_line_code             = X_accounting_line_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

UPDATE xla_acct_line_types_tl
SET
       last_update_date                 = x_last_update_date
      ,name                             = X_name
      ,description                      = X_description
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
      ,source_lang                      = USERENV('LANG')
WHERE  application_id                   = X_application_id
  AND  amb_context_code                 = X_amb_context_code
  AND  entity_code                      = X_entity_code
  AND  event_class_code                 = X_event_class_code
  AND  accounting_line_type_code        = X_accounting_line_type_code
  AND  accounting_line_code             = X_accounting_line_code
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
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2)

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

DELETE FROM xla_acct_line_types_tl
WHERE application_id                   = x_application_id
  AND amb_context_code                 = x_amb_context_code
  AND entity_code                      = x_entity_code
  AND event_class_code                 = x_event_class_code
  AND accounting_line_type_code        = x_accounting_line_type_code
  AND accounting_line_code             = x_accounting_line_code;


IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

DELETE FROM xla_acct_line_types_b
WHERE application_id                   = x_application_id
  AND amb_context_code                 = x_amb_context_code
  AND entity_code                      = x_entity_code
  AND event_class_code                 = x_event_class_code
  AND accounting_line_type_code        = x_accounting_line_type_code
  AND accounting_line_code             = x_accounting_line_code;


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

DELETE FROM xla_acct_line_types_tl T
WHERE  NOT EXISTS
      (SELECT NULL
       FROM   xla_acct_line_types_b              b
       WHERE  b.application_id                   = t.application_id
         AND  b.amb_context_code                 = t.amb_context_code
         AND  b.entity_code                      = t.entity_code
         AND  b.event_class_code                 = t.event_class_code
         AND  b.accounting_line_type_code        = t.accounting_line_type_code
         AND  b.accounting_line_code             = t.accounting_line_code);

UPDATE xla_acct_line_types_tl   t
SET   (name
      ,description)
   = (SELECT b.name
            ,b.description
      FROM   xla_acct_line_types_tl             b
      WHERE  b.application_id                   = t.application_id
        AND  b.amb_context_code                 = t.amb_context_code
        AND  b.entity_code                      = t.entity_code
        AND  b.event_class_code                 = t.event_class_code
        AND  b.accounting_line_type_code        = t.accounting_line_type_code
        AND  b.accounting_line_code             = t.accounting_line_code
        AND  b.language                         = t.source_lang)
WHERE (t.application_id
      ,t.amb_context_code
      ,t.entity_code
      ,t.event_class_code
      ,t.accounting_line_type_code
      ,t.accounting_line_code
      ,t.language)
    IN (SELECT subt.application_id
              ,subt.amb_context_code
              ,subt.entity_code
              ,subt.event_class_code
              ,subt.accounting_line_type_code
              ,subt.accounting_line_code
              ,subt.language
        FROM   xla_acct_line_types_tl                 subb
              ,xla_acct_line_types_tl                 subt
        WHERE  subb.application_id                   = subt.application_id
         AND  subb.amb_context_code                  = subt.amb_context_code
         AND  subb.entity_code                       = subt.entity_code
         AND  subb.event_class_code                  = subt.event_class_code
         AND  subb.accounting_line_type_code         = subt.accounting_line_type_code
         AND  subb.accounting_line_code              = subt.accounting_line_code
         AND  subb.language                         = subt.source_lang
         AND (SUBB.name                             <> SUBT.name
          OR  SUBB.description                      <> SUBT.description
          OR (subb.description                      IS NULL
         AND  subt.description                      IS NOT NULL)
          OR (subb.description                      IS NOT NULL
         AND  subt.description                      IS NULL)
      ))
;

INSERT INTO xla_acct_line_types_tl
(amb_context_code
,application_id
,entity_code
,event_class_code
,accounting_line_type_code
,accounting_line_code
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
       b.amb_context_code
      ,b.application_id
      ,b.entity_code
      ,b.event_class_code
      ,b.accounting_line_type_code
      ,b.accounting_line_code
      ,b.name
      ,b.description
      ,b.creation_date
      ,b.created_by
      ,b.last_update_date
      ,b.last_updated_by
      ,b.last_update_login
      ,l.language_code
      ,b.source_lang
FROM   xla_acct_line_types_tl           b
      ,fnd_languages                    l
WHERE  l.installed_flag                IN ('I', 'B')
  AND  b.language                       = userenv('LANG')
  AND  NOT EXISTS
      (SELECT NULL
       FROM   xla_acct_line_types_tl             t
       WHERE  t.application_id                   = b.application_id
         AND  t.amb_context_code                 = b.amb_context_code
         AND  t.entity_code                      = b.entity_code
         AND  t.event_class_code                 = b.event_class_code
         AND  t.accounting_line_type_code        = b.accounting_line_type_code
         AND  t.accounting_line_code             = b.accounting_line_code
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
  (p_application_short_name          IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2
  ,p_event_class_code                IN VARCHAR2
  ,p_accounting_line_type_code       IN VARCHAR2
  ,p_accounting_line_code            IN VARCHAR2
  ,p_name                            IN VARCHAR2
  ,p_description                     IN VARCHAR2
  ,p_owner                           IN VARCHAR2
  ,p_last_update_date                IN VARCHAR2
  ,p_custom_mode                     IN VARCHAR2)
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
      FROM xla_acct_line_types_tl
     WHERE application_id             = l_application_id
       AND amb_context_code           = p_amb_context_code
       AND event_class_code           = p_event_class_code
       AND accounting_line_type_code  = p_accounting_line_type_code
       AND accounting_line_code       = p_accounting_line_code
       AND language                   = userenv('LANG');

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                               db_ludate, p_custom_mode)) then
      UPDATE xla_acct_line_types_tl
         SET name                       = p_name
            ,description                = p_description
            ,last_update_date           = f_ludate
            ,last_updated_by            = f_luby
            ,last_update_login          = 0
            ,source_lang                = userenv('LANG')
       WHERE userenv('LANG')            IN (language, source_lang)
         AND application_id             = l_application_id
         AND amb_context_code           = p_amb_context_code
         AND event_class_code           = p_event_class_code
         AND accounting_line_type_code  = p_accounting_line_type_code
         AND accounting_line_code       = p_accounting_line_code;

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

end xla_acct_line_types_f_PKG;

/
