--------------------------------------------------------
--  DDL for Package Body XLA_LINE_DEFN_ADR_ASSGNS_F_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_LINE_DEFN_ADR_ASSGNS_F_PVT" AS
/* $Header: xlathlad.pkb 120.8 2005/06/14 00:54:30 wychan ship $ */

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_line_defn_adr_assgns_f_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
           (p_msg                        IN VARCHAR2
           ,p_level                      IN NUMBER
           ,p_module                     IN VARCHAR2)
  IS
     l_log_module  VARCHAR2(255);
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
      (p_location   => 'xla_line_defn_adr_assgns_f_pvt.trace');
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
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_inherit_adr_flag                 IN VARCHAR2
  ,x_segment_rule_appl_id             IN NUMBER
  ,x_segment_rule_type_code           IN VARCHAR2
  ,x_segment_rule_code                IN VARCHAR2
  ,x_side_code                        IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_line_defn_adr_assgns
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  line_definition_owner_code       = x_line_definition_owner_code
  AND  line_definition_code             = x_line_definition_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code
  AND  flexfield_segment_code           = x_flexfield_segment_code
  AND  side_code                        = x_side_code
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

INSERT INTO xla_line_defn_adr_assgns
(creation_date
,created_by
,application_id
,amb_context_code
,event_class_code
,event_type_code
,line_definition_owner_code
,line_definition_code
,accounting_line_type_code
,accounting_line_code
,flexfield_segment_code
,inherit_adr_flag
,adr_version_num
,segment_rule_appl_id
,segment_rule_type_code
,segment_rule_code
,side_code
,object_version_number
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_amb_context_code
,x_event_class_code
,x_event_type_code
,x_line_definition_owner_code
,x_line_definition_code
,x_accounting_line_type_code
,x_accounting_line_code
,x_flexfield_segment_code
,x_inherit_adr_flag
,0
,x_segment_rule_appl_id
,x_segment_rule_type_code
,x_segment_rule_code
,x_side_code
,1
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
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_inherit_adr_flag                 IN VARCHAR2
  ,x_segment_rule_appl_id             IN NUMBER
  ,x_segment_rule_type_code           IN VARCHAR2
  ,x_segment_rule_code                IN VARCHAR2
  ,x_side_code                        IN VARCHAR2)

IS

CURSOR c IS
SELECT inherit_adr_flag
      ,segment_rule_appl_id
      ,segment_rule_type_code
      ,segment_rule_code
      , side_code
FROM   xla_line_defn_adr_assgns
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  line_definition_owner_code       = x_line_definition_owner_code
  AND  line_definition_code             = x_line_definition_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code
  AND  flexfield_segment_code           = x_flexfield_segment_code
  AND  side_code                        = x_side_code
FOR UPDATE OF application_id NOWAIT;

recinfo c%ROWTYPE;

l_log_module         VARCHAR2(240);
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

IF ( (recinfo.inherit_adr_flag     = x_inherit_adr_flag)
 AND ((recinfo.segment_rule_appl_id     = x_segment_rule_appl_id)
   OR ((recinfo.segment_rule_appl_id    IS NULL)
   AND (x_segment_rule_appl_id          IS NULL)))
 AND ((recinfo.segment_rule_type_code     = x_segment_rule_type_code)
   OR ((recinfo.segment_rule_type_code    IS NULL)
   AND (x_segment_rule_type_code          IS NULL)))
 AND ((recinfo.segment_rule_code     = x_segment_rule_code)
   OR ((recinfo.segment_rule_code    IS NULL)
   AND (x_segment_rule_code          IS NULL)))
   AND (recinfo.side_code     = x_side_code)
                   ) THEN
   NULL;
ELSE
   fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
   app_exception.raise_exception;
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure lock_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

END lock_row;

/*======================================================================+
|                                                                       |
|  Procedure update_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE update_row
 (x_application_id                   IN NUMBER
 ,x_amb_context_code                 IN VARCHAR2
 ,x_event_class_code                 IN VARCHAR2
 ,x_event_type_code                  IN VARCHAR2
 ,x_line_definition_owner_code       IN VARCHAR2
 ,x_line_definition_code             IN VARCHAR2
 ,x_accounting_line_type_code        IN VARCHAR2
 ,x_accounting_line_code             IN VARCHAR2
 ,x_flexfield_segment_code           IN VARCHAR2
 ,x_inherit_adr_flag                 IN VARCHAR2
 ,x_segment_rule_appl_id             IN NUMBER
 ,x_segment_rule_type_code           IN VARCHAR2
 ,x_segment_rule_code                IN VARCHAR2
 ,x_side_code                        IN VARCHAR2
 ,x_last_update_date                 IN DATE
 ,x_last_updated_by                  IN NUMBER
 ,x_last_update_login                IN NUMBER)
IS

l_log_module  VARCHAR2(240);
BEGIN

IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.update_row';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'BEGIN of procedure update_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

UPDATE xla_line_defn_adr_assgns
   SET
       last_update_date                 = x_last_update_date
      ,inherit_adr_flag                 = x_inherit_adr_flag
      ,segment_rule_appl_id             = x_segment_rule_appl_id
      ,segment_rule_type_code           = x_segment_rule_type_code
      ,segment_rule_code                = x_segment_rule_code
      ,object_version_number            = object_version_number+1
      ,last_updated_by                  = x_last_updated_by
      ,last_update_login                = x_last_update_login
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  line_definition_owner_code       = x_line_definition_owner_code
  AND  line_definition_code             = x_line_definition_code
  AND  accounting_line_type_code        = x_accounting_line_type_code
  AND  accounting_line_code             = x_accounting_line_code
  AND  flexfield_segment_code           = x_flexfield_segment_code
  AND  side_code                        = x_side_code;

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
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_accounting_line_type_code        IN VARCHAR2
  ,x_accounting_line_code             IN VARCHAR2
  ,x_flexfield_segment_code           IN VARCHAR2
  ,x_side_code                        IN VARCHAR2)

IS

l_log_module       VARCHAR2(240);
BEGIN

IF g_log_enabled THEN
  l_log_module := C_DEFAULT_MODULE||'.delete_row';
END IF;

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'BEGIN of procedure delete_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

DELETE FROM xla_line_defn_adr_assgns
WHERE application_id                   = x_application_id
  AND amb_context_code                 = x_amb_context_code
  AND event_class_code                 = x_event_class_code
  AND event_type_code                  = x_event_type_code
  AND line_definition_owner_code       = x_line_definition_owner_code
  AND line_definition_code             = x_line_definition_code
  AND accounting_line_type_code        = x_accounting_line_type_code
  AND accounting_line_code             = x_accounting_line_code
  AND flexfield_segment_code           = x_flexfield_segment_code
  AND side_code                        = x_side_code;

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

END xla_line_defn_adr_assgns_f_pvt;

/
