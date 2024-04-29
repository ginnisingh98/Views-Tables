--------------------------------------------------------
--  DDL for Package Body XLA_EVENT_CLASS_ATTRS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVENT_CLASS_ATTRS_F_PKG" AS
/* $Header: xlatbeca.pkb 120.13 2006/02/16 03:28:23 wychan ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_class_attrs_f_pkg                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_classes_attr                          |
|                                                                       |
| HISTORY                                                               |
|    05/22/01     Dimple Shah    Created                                |
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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_event_class_attrs_f_pkg';

g_debug_flag          VARCHAR2(1) :=
NVL(fnd_profile.value('XLA_DEBUG_TRACE'),'N');

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
      (p_location   => 'xla_event_class_attrs_f_pkg.trace');
END trace;



/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_class_group_code           IN VARCHAR2
  ,x_je_category_name                 IN VARCHAR2
  ,x_reporting_view_name              IN VARCHAR2
  ,x_allow_actuals_flag               IN VARCHAR2
  ,x_allow_budgets_flag               IN VARCHAR2
  ,x_allow_encumbrance_flag           IN VARCHAR2
  ,x_calculate_acctd_amts_flag        IN VARCHAR2
  ,x_calculate_g_l_amts_flag          IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_event_class_attrs
WHERE  application_id                   = x_application_id
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
;

  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.insert_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure insert_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

INSERT INTO xla_event_class_attrs
(creation_date
,created_by
,application_id
,entity_code
,event_class_code
,event_class_group_code
,je_category_name
,reporting_view_name
,allow_actuals_flag
,allow_budgets_flag
,allow_encumbrance_flag
,calculate_acctd_amts_flag
,calculate_g_l_amts_flag
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_entity_code
,x_event_class_code
,x_event_class_group_code
,x_je_category_name
,x_reporting_view_name
,x_allow_actuals_flag
,x_allow_budgets_flag
,x_allow_encumbrance_flag
,x_calculate_acctd_amts_flag
,x_calculate_g_l_amts_flag
,x_last_update_date
,x_last_updated_by
,x_last_update_login)
;

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
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_class_group_code           IN VARCHAR2
  ,x_je_category_name                 IN VARCHAR2
  ,x_reporting_view_name              IN VARCHAR2
  ,x_allow_actuals_flag               IN VARCHAR2
  ,x_allow_budgets_flag               IN VARCHAR2
  ,x_allow_encumbrance_flag           IN VARCHAR2
  ,x_calculate_acctd_amts_flag        IN VARCHAR2
  ,x_calculate_g_l_amts_flag          IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,entity_code
      ,event_class_code
      ,event_class_group_code
      ,je_category_name
      ,reporting_view_name
      ,allow_actuals_flag
      ,allow_budgets_flag
      ,allow_encumbrance_flag
      ,calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag
FROM   xla_event_class_attrs
WHERE  application_id                   = x_application_id
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code
FOR UPDATE OF application_id NOWAIT;

recinfo              c%ROWTYPE;

  l_log_module            VARCHAR2(240);
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

IF ( (recinfo.application_id                    = x_application_id)
 AND (recinfo.entity_code                       = x_entity_code)
 AND (recinfo.event_class_code                  = x_event_class_code)
 AND (recinfo.event_class_group_code            = x_event_class_group_code)
 AND (recinfo.je_category_name                  = x_je_category_name)
 AND (recinfo.allow_actuals_flag                = x_allow_actuals_flag)
 AND (recinfo.allow_budgets_flag                = x_allow_budgets_flag)
 AND (recinfo.allow_encumbrance_flag            = x_allow_encumbrance_flag)
 AND (recinfo.calculate_acctd_amts_flag         = x_calculate_acctd_amts_flag)
 AND (recinfo.calculate_g_l_amts_flag           = x_calculate_g_l_amts_flag)
 AND ((recinfo.reporting_view_name              = X_reporting_view_name)
   OR ((recinfo.reporting_view_name              IS NULL)
  AND (x_reporting_view_name              IS NULL)))
                   ) THEN
   null;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

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
  (x_rowid                            IN OUT NOCOPY VARCHAR2
  ,x_application_id                   IN NUMBER
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_class_group_code           IN VARCHAR2
  ,x_je_category_name                 IN VARCHAR2
  ,x_reporting_view_name              IN VARCHAR2
  ,x_allow_actuals_flag               IN VARCHAR2
  ,x_allow_budgets_flag               IN VARCHAR2
  ,x_allow_encumbrance_flag           IN VARCHAR2
  ,x_calculate_acctd_amts_flag        IN VARCHAR2
  ,x_calculate_g_l_amts_flag          IN VARCHAR2
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)
IS

  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.update_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure update_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

UPDATE xla_event_class_attrs
   SET
       last_update_date                 = x_last_update_date
      ,event_class_group_code           = x_event_class_group_code
      ,je_category_name                 = x_je_category_name
      ,reporting_view_name              = x_reporting_view_name
      ,allow_actuals_flag               = x_allow_actuals_flag
      ,allow_budgets_flag               = x_allow_budgets_flag
      ,allow_encumbrance_flag           = x_allow_encumbrance_flag
      ,calculate_acctd_amts_flag        = x_calculate_acctd_amts_flag
      ,calculate_g_l_amts_flag          = x_calculate_g_l_amts_flag
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = X_application_id
  AND  entity_code                      = x_entity_code
  AND  event_class_code                 = x_event_class_code;

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
  ,x_entity_code                      IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2)

IS

  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.delete_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure delete_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

DELETE FROM xla_event_class_attrs
WHERE application_id                   = x_application_id
  AND entity_code                      = x_entity_code
  AND event_class_code                 = x_event_class_code;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure delete_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

END delete_row;

--=============================================================================
--
-- Name: load_row
-- Description: To be used by FNDLOAD to upload a row to the table
--
--=============================================================================
PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_event_class_code                   IN VARCHAR2
,p_event_class_group_code             IN VARCHAR2
,p_je_category_key                    IN VARCHAR2
,p_reporting_view_name                IN VARCHAR2
,p_allow_actuals_flag                 IN VARCHAR2
,p_allow_budgets_flag                 IN VARCHAR2
,p_allow_encumbrance_flag             IN VARCHAR2
,p_calculate_acctd_amts_flag          IN VARCHAR2
,p_calculate_g_l_amts_flag            IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2)
IS
  CURSOR c_app_id(p_app_short_name VARCHAR2) IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_app_short_name;

  CURSOR c_je_category(p_je_category_key VARCHAR2) IS
  SELECT je_category_name
  FROM   gl_je_categories
  WHERE  je_category_key          = p_je_category_key;

  l_application_id        INTEGER;
  l_je_category_name      VARCHAR2(30);
  l_rowid                 ROWID;
  l_exist                 VARCHAR2(1);
  f_luby                  NUMBER;      -- entity owner in file
  f_ludate                DATE;        -- entity update date in file
  db_luby                 NUMBER;      -- entity owner in db
  db_ludate               DATE;        -- entity update date in db
  l_log_module            VARCHAR2(240);
BEGIN

  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.load_row';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of procedure load_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(p_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  OPEN c_app_id(p_application_short_name);
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  OPEN c_je_category(p_je_category_key);
  FETCH c_je_category INTO l_je_category_name;
  CLOSE c_je_category;

  BEGIN

    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_event_class_attrs
     WHERE application_id       = l_application_id
       AND entity_code          = p_entity_code
       AND event_class_code     = p_event_class_code;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, NULL)) THEN

      xla_event_class_attrs_f_pkg.update_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_event_class_code              => p_event_class_code
          ,x_event_class_group_code        => p_event_class_group_code
          ,x_je_category_name              => l_je_category_name
          ,x_reporting_view_name           => p_reporting_view_name
          ,x_allow_actuals_flag            => p_allow_actuals_flag
          ,x_allow_budgets_flag            => p_allow_budgets_flag
          ,x_allow_encumbrance_flag        => p_allow_encumbrance_flag
          ,x_calculate_acctd_amts_flag     => p_calculate_acctd_amts_flag
          ,x_calculate_g_l_amts_flag       => p_calculate_g_l_amts_flag
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_event_class_attrs_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_entity_code                   => p_entity_code
          ,x_event_class_code              => p_event_class_code
          ,x_event_class_group_code        => p_event_class_group_code
          ,x_je_category_name              => l_je_category_name
          ,x_reporting_view_name           => p_reporting_view_name
          ,x_allow_actuals_flag            => p_allow_actuals_flag
          ,x_allow_budgets_flag            => p_allow_budgets_flag
          ,x_allow_encumbrance_flag        => p_allow_encumbrance_flag
          ,x_calculate_acctd_amts_flag     => p_calculate_acctd_amts_flag
          ,x_calculate_g_l_amts_flag       => p_calculate_g_l_amts_flag
          ,x_creation_date                 => f_ludate
          ,x_created_by                    => f_luby
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

      xla_acct_setup_pkg.perform_event_class_setup
          (p_application_id                => l_application_id
          ,p_event_class_code              => p_event_class_code);

  END;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of procedure load_row',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_event_class_attrs_f_pkg.load_row');

END load_row;

--=============================================================================
--
-- Name: load_row
-- Description: This overload API is created for backward compatiability.
--              It can eb removed as soon as 9/2/2005 freeze is completed.
--
--=============================================================================
/*
PROCEDURE load_row
(p_application_short_name             IN VARCHAR2
,p_entity_code                        IN VARCHAR2
,p_event_class_code                   IN VARCHAR2
,p_event_class_group_code             IN VARCHAR2
,p_je_category_name                   IN VARCHAR2
,p_reporting_view_name                IN VARCHAR2
,p_allow_actuals_flag                 IN VARCHAR2
,p_allow_budgets_flag                 IN VARCHAR2
,p_allow_encumbrance_flag             IN VARCHAR2
,p_calculate_acctd_amts_flag          IN VARCHAR2
,p_calculate_g_l_amts_flag            IN VARCHAR2
,p_owner                              IN VARCHAR2
,p_last_update_date                   IN VARCHAR2)
IS
BEGIN
  xla_event_class_attrs_f_pkg.load_row
     (p_application_short_name             => p_application_short_name
     ,p_entity_code                        => p_entity_code
     ,p_event_class_code                   => p_event_class_code
     ,p_event_class_group_code             => p_event_class_group_code
     ,p_je_category_key                    => p_je_category_name
     ,p_reporting_view_name                => p_reporting_view_name
     ,p_allow_actuals_flag                 => p_allow_actuals_flag
     ,p_allow_budgets_flag                 => p_allow_budgets_flag
     ,p_allow_encumbrance_flag             => p_allow_encumbrance_flag
     ,p_calculate_acctd_amts_flag          => p_calculate_acctd_amts_flag
     ,p_calculate_g_l_amts_flag            => p_calculate_g_l_amts_flag
     ,p_owner                              => p_owner
     ,p_last_update_date                   => p_last_update_date);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      null;
   WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_event_class_attrs_f_pkg.load_row');

END load_row;
*/

--=============================================================================
--
-- Following code is executed when the package body is referenced for the first
-- time
--
--=============================================================================
BEGIN
   g_log_level      := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_log_enabled    := fnd_log.test
                          (log_level  => g_log_level
                          ,module     => C_DEFAULT_MODULE);

   IF NOT g_log_enabled  THEN
      g_log_level := C_LEVEL_LOG_DISABLED;
   END IF;


end xla_event_class_attrs_f_pkg;

/
