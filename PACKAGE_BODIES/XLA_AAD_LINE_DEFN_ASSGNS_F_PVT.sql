--------------------------------------------------------
--  DDL for Package Body XLA_AAD_LINE_DEFN_ASSGNS_F_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_AAD_LINE_DEFN_ASSGNS_F_PVT" AS
/* $Header: xlathald.pkb 120.2 2005/05/04 06:46:13 ksvenkat ship $ */

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_aad_line_defn_assgns_f_pvt';

g_log_level           NUMBER;
g_log_enabled         BOOLEAN;

PROCEDURE trace
  (p_msg                        IN VARCHAR2
  ,p_module                     IN VARCHAR2
  ,p_level                      IN NUMBER) IS

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
      (p_location   => 'xla_aad_line_defn_assgns_f_pvt.trace');
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
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2
  ,x_creation_date                    IN DATE
  ,x_created_by                       IN NUMBER
  ,x_last_update_date                 IN DATE
  ,x_last_updated_by                  IN NUMBER
  ,x_last_update_login                IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_aad_line_defn_assgns
WHERE  application_id                   = x_application_id
  AND  amb_context_code                 = x_amb_context_code
  AND  product_rule_type_code           = x_product_rule_type_code
  AND  product_rule_code                = x_product_rule_code
  AND  event_class_code                 = x_event_class_code
  AND  event_type_code                  = x_event_type_code
  AND  line_definition_owner_code       = x_line_definition_owner_code
  AND  line_definition_code             = x_line_definition_code
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

INSERT INTO xla_aad_line_defn_assgns
(creation_date
,created_by
,application_id
,amb_context_code
,product_rule_type_code
,product_rule_code
,event_class_code
,event_type_code
,line_definition_owner_code
,line_definition_code
,object_version_number
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_amb_context_code
,x_product_rule_type_code
,x_product_rule_code
,x_event_class_code
,x_event_type_code
,x_line_definition_owner_code
,x_line_definition_code
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
|  Procedure delete_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE delete_row
  (x_application_id                   IN NUMBER
  ,x_amb_context_code                 IN VARCHAR2
  ,x_product_rule_type_code           IN VARCHAR2
  ,x_product_rule_code                IN VARCHAR2
  ,x_event_class_code                 IN VARCHAR2
  ,x_event_type_code                  IN VARCHAR2
  ,x_line_definition_owner_code       IN VARCHAR2
  ,x_line_definition_code             IN VARCHAR2)

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

DELETE FROM xla_aad_line_defn_assgns
WHERE application_id                   = x_application_id
  AND amb_context_code                 = x_amb_context_code
  AND product_rule_type_code           = x_product_rule_type_code
  AND product_rule_code                = x_product_rule_code
  AND event_class_code                 = x_event_class_code
  AND event_type_code                  = x_event_type_code
  AND line_definition_owner_code       = x_line_definition_owner_code
  AND line_definition_code             = x_line_definition_code;

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

END xla_aad_line_defn_assgns_f_pvt;

/
