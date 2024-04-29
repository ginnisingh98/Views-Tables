--------------------------------------------------------
--  DDL for Package Body XLA_SUBLEDGERS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SUBLEDGERS_F_PKG" AS
/* $Header: xlatbapp.pkb 120.29.12010000.2 2009/12/28 09:23:33 vkasina ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_subledgers                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|    Forms PL/SQL Wrapper for xla_subledgers                            |
|                                                                       |
| HISTORY                                                               |
|    6/11/2002 W Chan   Created.                                        |
|   10/09/2003 W Chan   Fix bug 3175882 - call security API on update   |
|   10/09/2003 W Chan   Fix bug 3175319 - create table partition when   |
|                       register application                            |
|                                                                       |
+======================================================================*/

-------------------------------------------------------------------------------
-- declaring private constants
-------------------------------------------------------------------------------
C_MANUAL	CONSTANT VARCHAR2(10)    := 'MANUAL';
C_TPM       CONSTANT VARCHAR2(30)    := 'THIRD_PARTY_MERGE';


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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_subledgers_f_pkg';

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
      (p_location   => 'xla_subledgers_f_pkg.trace');
END trace;

--=============================================================================
--
--
--
--
--          *********** private procedures and functions **********
--
--
--
--
--=============================================================================

--=============================================================================
--
-- Name: get_schema
-- Description: Retrieve the schema name for XLA
--
-- Return: If schema is found, the schema name is returned.  Else, null is
--         returned.
--
--=============================================================================
FUNCTION get_schema
RETURN VARCHAR2
IS
  l_status       VARCHAR2(30);
  l_industry     VARCHAR2(30);
  l_schema       VARCHAR2(30);
  l_retcode      BOOLEAN;

  l_log_module   VARCHAR2(240);
BEGIN
  IF g_log_enabled THEN
    l_log_module := C_DEFAULT_MODULE||'.get_schema';
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'BEGIN of function get_schema',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  IF (NOT FND_INSTALLATION.get_app_info
                       (application_short_name   => 'XLA'
                       ,status                   => l_status
                       ,industry                 => l_industry
                       ,oracle_schema            => l_schema)) THEN
     l_schema := NULL;
  END IF;

  IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
    trace(p_msg    => 'END of function get_schema',
          p_module => l_log_module,
          p_level  => C_LEVEL_PROCEDURE);
  END IF;

  RETURN l_schema;
EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  RAISE;

WHEN OTHERS                                   THEN
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_subledgers_f_pkg.get_schema');

END get_schema;

/*======================================================================+
|                                                                       |
| NAME: update_one_partition                                            |
| Description: The procedure updates the partition to one partitioined  |
|              table.                                                   |
|                                                                       |
+======================================================================*/

PROCEDURE update_one_partition
(p_app_id            IN INTEGER
,p_app_short_name    IN VARCHAR2
,p_schema            IN VARCHAR2
,p_table             IN VARCHAR2
,p_action            IN VARCHAR2)
IS
  --partition_exists EXCEPTION;
  --PRAGMA EXCEPTION_INIT(partition_exists,-14312);

  l_log_module        VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.update_one_partition';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure update_one_partition',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
     trace(p_msg    => 'p_table = '||p_table,
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   BEGIN
     IF (p_action = 'ADD') THEN
       EXECUTE IMMEDIATE
         'ALTER TABLE '||p_schema||' '||p_table||' ADD PARTITION '||p_app_short_name||
         ' VALUES ('||p_app_id||' )';
      ELSE
       EXECUTE IMMEDIATE
         'ALTER TABLE '||p_schema||' '||p_table||' DROP PARTITION '||p_app_short_name;
      END IF;

      EXCEPTION
         WHEN OTHERS THEN
           NULL;
   END;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure update_one_partition',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
END;


/*======================================================================+
|                                                                       |
| NAME: update_partitions                                               |
| Description: The procedure updates the partition to all partitioined  |
|              tables.                                                  |
|                                                                       |
+======================================================================*/

PROCEDURE update_partitions
  ( p_app_id            IN INTEGER
   ,p_action            IN VARCHAR2
   ) IS

  CURSOR c IS
  SELECT application_short_name
  FROM   fnd_application
  WHERE  application_id = p_app_id;

  l_schema            VARCHAR2(30);
  l_app_short_name    VARCHAR2(30);
  l_log_module        VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.update_partitions';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure update_partitions',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
     trace(p_msg    => 'p_app_id = '||p_app_id,
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
     trace(p_msg    => 'p_action = '||p_action,
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   OPEN c;
   FETCH c INTO l_app_short_name;
   if (c%NOTFOUND) then
     CLOSE c;
     RAISE NO_DATA_FOUND;
   end if;
   CLOSE c;

   l_schema := get_schema;
   IF (l_schema IS  NULL) THEN
     l_schema := '';
   ELSE
     l_schema := l_schema || '.';
   END IF;

   -- Add partition
   update_one_partition
          (p_app_id            => p_app_id
          ,p_app_short_name    => l_app_short_name
          ,p_schema            => l_schema
          ,p_table             => 'XLA_TRANSACTION_ENTITIES'
          ,p_action            => p_action);

   update_one_partition
          (p_app_id            => p_app_id
          ,p_app_short_name    => l_app_short_name
          ,p_schema            => l_schema
          ,p_table             => 'XLA_EVENTS'
          ,p_action            => p_action);

   update_one_partition
          (p_app_id            => p_app_id
          ,p_app_short_name    => l_app_short_name
          ,p_schema            => l_schema
          ,p_table             => 'XLA_AE_HEADERS'
          ,p_action            => p_action);

   update_one_partition
          (p_app_id            => p_app_id
          ,p_app_short_name    => l_app_short_name
          ,p_schema            => l_schema
          ,p_table             => 'XLA_AE_LINES'
          ,p_action            => p_action);

   update_one_partition
          (p_app_id            => p_app_id
          ,p_app_short_name    => l_app_short_name
          ,p_schema            => l_schema
          ,p_table             => 'XLA_DISTRIBUTION_LINKS'
          ,p_action            => p_action);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure update_partitions',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
END;

/*======================================================================+
|                                                                       |
| NAME: insert_tpm                                                      |
| Description: The procedure inserts special event information for      |
|              third party merge.                                       |
|                                                                       |
+======================================================================*/

PROCEDURE insert_tpm
  (p_application_id                     IN NUMBER
  ,p_creation_date                    	IN DATE
  ,p_created_by                       	IN NUMBER
  ,p_last_update_date                 	IN DATE
  ,p_last_updated_by                  	IN NUMBER
  ,p_last_update_login                	IN NUMBER)IS

   l_row_id             VARCHAR2(80);
   l_log_module         VARCHAR2(240);
BEGIN

   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.update_one_partition';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure update_one_partition',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
     trace(p_msg    => 'p_application_id = '||p_application_id,
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

   --
   -- Create Third Party Merge event entity
   --
   xla_entity_types_f_pkg.insert_row(
      x_rowid                            => l_row_id
     ,x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_enabled_flag                     => 'Y'
     ,x_enable_gapless_events_flag       => 'N'
     ,x_name                             => 'Third Party Merge'
     ,x_description                      => 'Special event entity created for third party merge entry'
     ,x_creation_date                    => p_creation_date
     ,x_created_by                       => p_created_by
     ,x_last_update_date                 => p_last_update_date
     ,x_last_updated_by                  => p_last_updated_by
     ,x_last_update_login                => p_last_update_login);

   --
   -- Create Third Party Merge entity id mapping
   --
   INSERT INTO xla_entity_id_mappings
     (application_id
     ,entity_code
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login)
   VALUES
     (p_application_id
     ,C_TPM
     ,p_creation_date
     ,p_created_by
     ,p_last_update_date
     ,p_last_updated_by
     ,p_last_update_login);

   --
   -- Create Third Party Merge event class
   --
   xla_event_classes_f_pkg.insert_row(
      x_rowid                            => l_row_id
     ,x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM
     ,x_enabled_flag                     => 'Y'
     ,x_name                             => 'Third Party Merge'
     ,x_description                      => 'Special event class created for third party merge entry'
     ,x_creation_date                    => p_creation_date
     ,x_created_by                       => p_created_by
     ,x_last_update_date                 => p_last_update_date
     ,x_last_updated_by                  => p_last_updated_by
     ,x_last_update_login                => p_last_update_login);

   --
   -- Create Full Merge event type
   --
   xla_event_types_f_pkg.insert_row(
      x_rowid                            => l_row_id
     ,x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM
     ,x_event_type_code                  => 'FULL_MERGE'
     ,x_accounting_flag                  => 'Y'
     ,x_tax_flag                         => 'N'
     ,x_enabled_flag                     => 'Y'
     ,x_name                             => 'Full Merge'
     ,x_description                      => 'Special event type created for third party merge entry'
     ,x_creation_date                    => p_creation_date
     ,x_created_by                       => p_created_by
     ,x_last_update_date                 => p_last_update_date
     ,x_last_updated_by                  => p_last_updated_by
     ,x_last_update_login                => p_last_update_login);

   --
   -- Create Partial Merge event type
   --
   xla_event_types_f_pkg.insert_row(
      x_rowid                            => l_row_id
     ,x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM
     ,x_event_type_code                  => 'PARTIAL_MERGE'
     ,x_accounting_flag                  => 'Y'
     ,x_tax_flag                         => 'N'
     ,x_enabled_flag                     => 'Y'
     ,x_name                             => 'Partial Merge'
     ,x_description                      => 'Special event type created for third party merge entry'
     ,x_creation_date                    => p_creation_date
     ,x_created_by                       => p_created_by
     ,x_last_update_date                 => p_last_update_date
     ,x_last_updated_by                  => p_last_updated_by
     ,x_last_update_login                => p_last_update_login);

   --
   -- Create special event class group for manual
   --
   xla_event_class_grps_f_pkg.insert_row(
      x_rowid                            => l_row_id
     ,x_application_id                   => p_application_id
     ,x_event_class_group_code           => C_TPM
     ,x_enabled_flag                     => 'Y'
     ,x_name                             => 'Third Party Merge'
     ,x_description                      => 'Special event class group created for third party merge entry'
     ,x_creation_date                    => p_creation_date
     ,x_created_by                       => p_created_by
     ,x_last_update_date                 => p_last_update_date
     ,x_last_updated_by                  => p_last_updated_by
     ,x_last_update_login                => p_last_update_login);

   --
   -- Create special event class attrs for manual
   --
   xla_event_class_attrs_f_pkg.insert_row(
      x_rowid                            => l_row_id
     ,x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM
     ,x_event_class_group_code           => C_TPM
     ,x_je_category_name                 => 'Other'
     ,x_reporting_view_name              => null
     ,x_allow_actuals_flag               => 'Y'
     ,x_allow_budgets_flag               => 'N'
     ,x_allow_encumbrance_flag           => 'N'
     ,x_calculate_acctd_amts_flag        => 'N'
     ,x_calculate_g_l_amts_flag          => 'N'
     ,x_creation_date                    => p_creation_date
     ,x_created_by                       => p_created_by
     ,x_last_update_date                 => p_last_update_date
     ,x_last_updated_by                  => p_last_updated_by
     ,x_last_update_login                => p_last_update_login);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure insert_tpm',
           p_module => l_log_module,
           p_level  => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
END insert_tpm;

/*======================================================================+
|                                                                       |
| NAME: insert_tpm                                                      |
| Description: The procedure deletes special event information for      |
|              third party merge.                                       |
|                                                                       |
+======================================================================*/
PROCEDURE delete_tpm
  (p_application_id   IN NUMBER)
IS

BEGIN

   xla_event_class_grps_f_pkg.delete_row
     (x_application_id                   => p_application_id
     ,x_event_class_group_code           => C_TPM);

   xla_event_class_attrs_f_pkg.delete_row
     (x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM);

   xla_event_types_f_pkg.delete_row
     (x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM
     ,x_event_type_code                  => 'FULL_MERGE');

   xla_event_types_f_pkg.delete_row
     (x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM
     ,x_event_type_code                  => 'PARTIAL_MERGE');

   DELETE FROM xla_entity_id_mappings
   WHERE  application_id = p_application_id
   AND    entity_code    = C_TPM
   ;

   xla_event_classes_f_pkg.delete_row
     (x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM
     ,x_event_class_code                 => C_TPM);

   xla_entity_types_f_pkg.delete_row
     (x_application_id                   => p_application_id
     ,x_entity_code                      => C_TPM);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
END delete_tpm;

--=============================================================================
--
--
--
--
--          *********** public procedures and functions **********
--
--
--
--
--=============================================================================

/*======================================================================+
|                                                                       |
|  Procedure insert_row                                                 |
|                                                                       |
+======================================================================*/
PROCEDURE insert_row
  (x_rowid                            	IN OUT NOCOPY VARCHAR2
  ,x_application_id                     IN NUMBER
  ,x_application_type_code		IN VARCHAR2
  ,x_je_source_name                     IN VARCHAR2
  ,x_valuation_method_flag              IN VARCHAR2
  ,x_drilldown_procedure_name           IN VARCHAR2
  ,x_security_function_name             IN VARCHAR2
  ,x_control_account_type_code          IN VARCHAR2
  ,x_alc_enabled_flag                   IN VARCHAR2
  ,x_creation_date                    	IN DATE
  ,x_created_by                       	IN NUMBER
  ,x_last_update_date                 	IN DATE
  ,x_last_updated_by                  	IN NUMBER
  ,x_last_update_login                	IN NUMBER)

IS

CURSOR c IS
SELECT rowid
FROM   xla_subledgers
WHERE  application_id                 = x_application_id;

CURSOR c1 IS
SELECT rowid
FROM   xla_entity_id_mappings
WHERE  application_id                 = x_application_id 	AND
       entity_code		      = C_MANUAL;

CURSOR c2 IS
SELECT application_short_name
FROM   fnd_application
WHERE  application_id		      = x_application_id;

l_event_entity_row_id		VARCHAR2(240);
l_event_class_row_id		VARCHAR2(240);
l_event_type_row_id		VARCHAR2(240);
l_event_class_attr_row_id	VARCHAR2(240);
l_event_class_grps_row_id	VARCHAR2(240);
l_app_short_name		VARCHAR2(30);
l_schema                        VARCHAR2(30);
l_rowid                         VARCHAR2(80);

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

OPEN c2;
FETCH c2 INTO l_app_short_name;
if (c2%NOTFOUND) then
  CLOSE c2;
  RAISE NO_DATA_FOUND;
end if;
CLOSE c2;

INSERT INTO xla_subledgers
(creation_date
,created_by
,application_id
,application_type_code
,je_source_name
,valuation_method_flag
,drilldown_procedure_name
,security_function_name
,control_account_type_code
,alc_enabled_flag
,last_update_date
,last_updated_by
,last_update_login)
VALUES
(x_creation_date
,x_created_by
,x_application_id
,x_application_type_code
,x_je_source_name
,x_valuation_method_flag
,x_drilldown_procedure_name
,x_security_function_name
,x_control_account_type_code
,x_alc_enabled_flag
,x_last_update_date
,x_last_updated_by
,x_last_update_login);

OPEN c;
FETCH c INTO x_rowid;

IF (c%NOTFOUND) THEN
   CLOSE c;
   RAISE NO_DATA_FOUND;
END IF;
CLOSE c;

--
-- Initiate the Transaction Security mechanism for the subledger application
--
xla_security_pkg.set_subledger_security(
   p_application_id		=> x_application_id
  ,p_security_function_name	=> x_security_function_name);

--
-- Create special event entity for manual entries
--
xla_entity_types_f_pkg.insert_row(
   x_rowid                            => l_event_entity_row_id
  ,x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL
  ,x_enabled_flag                     => 'Y'
  ,x_enable_gapless_events_flag       => 'N'
  ,x_name                             => 'Manual'
  ,x_description                      => 'Special event entity created for manual entry'
  ,x_creation_date                    => x_creation_date
  ,x_created_by                       => x_created_by
  ,x_last_update_date                 => x_last_update_date
  ,x_last_updated_by                  => x_last_updated_by
  ,x_last_update_login                => x_last_update_login);

--
-- Create special entity id mapping for manual entries
--
INSERT INTO xla_entity_id_mappings
      (application_id
      ,entity_code
      ,creation_date
      ,created_by
      ,last_update_date
      ,last_updated_by
      ,last_update_login)
   VALUES
      (x_application_id
      ,C_MANUAL
      ,x_creation_date
      ,x_created_by
      ,x_last_update_date
      ,x_last_updated_by
      ,x_last_update_login);

OPEN c1;
FETCH c1 INTO l_rowid;

IF (c1%NOTFOUND) THEN
   CLOSE c1;
   RAISE NO_DATA_FOUND;
END IF;
CLOSE c1;

--
-- Create special event class for manual entries
--
xla_event_classes_f_pkg.insert_row(
   x_rowid                            => l_event_class_row_id
  ,x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL
  ,x_event_class_code                 => C_MANUAL
  ,x_enabled_flag                     => 'Y'
  ,x_name                             => 'Manual'
  ,x_description                      => 'Special event class created for manual entry'
  ,x_creation_date                    => x_creation_date
  ,x_created_by                       => x_created_by
  ,x_last_update_date                 => x_last_update_date
  ,x_last_updated_by                  => x_last_updated_by
  ,x_last_update_login                => x_last_update_login);

--
-- Create special event type for manual entries
--
xla_event_types_f_pkg.insert_row(
   x_rowid                            => l_event_type_row_id
  ,x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL
  ,x_event_class_code                 => C_MANUAL
  ,x_event_type_code		      => C_MANUAL
  ,x_accounting_flag                  => 'Y'
  ,x_tax_flag                         => 'Y'
  ,x_enabled_flag                     => 'Y'
  ,x_name                             => 'Manual'
  ,x_description                      => 'Special event type created for manual entry'
  ,x_creation_date                    => x_creation_date
  ,x_created_by                       => x_created_by
  ,x_last_update_date                 => x_last_update_date
  ,x_last_updated_by                  => x_last_updated_by
  ,x_last_update_login                => x_last_update_login);

--
-- Create special event class group for manual
--
xla_event_class_grps_f_pkg.insert_row(
   x_rowid			      => l_event_class_grps_row_id
  ,x_application_id                   => x_application_id
  ,x_event_class_group_code	      => C_MANUAL
  ,x_enabled_flag		      => 'Y'
  ,x_name			      => 'Manual'
  ,x_description		      => 'Special event class group created for manual entry'
  ,x_creation_date                    => x_creation_date
  ,x_created_by                       => x_created_by
  ,x_last_update_date                 => x_last_update_date
  ,x_last_updated_by                  => x_last_updated_by
  ,x_last_update_login                => x_last_update_login);

--
-- Create special event class attrs for manual
--
xla_event_class_attrs_f_pkg.insert_row(
   x_rowid			      => l_event_class_attr_row_id
  ,x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL
  ,x_event_class_code                 => C_MANUAL
  ,x_event_class_group_code	      => C_MANUAL
  ,x_je_category_name		      => 'Other'
  ,x_reporting_view_name	      => null
  ,x_allow_actuals_flag		      => 'Y'
  ,x_allow_budgets_flag		      => 'Y'
  ,x_allow_encumbrance_flag	      => 'Y'
  ,x_calculate_acctd_amts_flag        => 'N'
  ,x_calculate_g_l_amts_flag          => 'N'
  ,x_creation_date                    => x_creation_date
  ,x_created_by                       => x_created_by
  ,x_last_update_date                 => x_last_update_date
  ,x_last_updated_by                  => x_last_updated_by
  ,x_last_update_login                => x_last_update_login);


--
--  Create Third Party Merge Special Events
--
insert_tpm(
   p_application_id               => x_application_id
  ,p_creation_date                => x_creation_date
  ,p_created_by                   => x_created_by
  ,p_last_update_date             => x_last_update_date
  ,p_last_updated_by              => x_last_updated_by
  ,p_last_update_login            => x_last_update_login);

-- Add a new partition
update_partitions(p_app_id         => x_application_id
                 ,p_action         => 'ADD');

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure insert_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  if (c%ISOPEN) then
    close c;
  end if;
  if (c1%ISOPEN) then
    close c1;
  end if;
  if (c2%ISOPEN) then
    close c2;
  end if;
  RAISE;
WHEN OTHERS                                   THEN
  ROLLBACK;
  if (c%ISOPEN) then
    close c;
  end if;
  if (c1%ISOPEN) then
    close c1;
  end if;
  if (c2%ISOPEN) then
    close c2;
  end if;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_subledgers_f_pkg.insert_row');

END insert_row;

/*======================================================================+
|                                                                       |
|  Procedure lock_row                                                   |
|                                                                       |
+======================================================================*/
PROCEDURE lock_row
  (x_application_id                   	IN NUMBER
  ,x_application_type_code		IN VARCHAR2
  ,x_je_source_name                     IN VARCHAR2
  ,x_valuation_method_flag              IN VARCHAR2
  ,x_drilldown_procedure_name           IN VARCHAR2
  ,x_security_function_name             IN VARCHAR2
  ,x_control_account_type_code          IN VARCHAR2
  ,x_alc_enabled_flag                   IN VARCHAR2)

IS

CURSOR c IS
SELECT application_id
      ,application_type_code
      ,je_source_name
      ,valuation_method_flag
      ,drilldown_procedure_name
      ,security_function_name
      ,control_account_type_code
      ,alc_enabled_flag
FROM   xla_subledgers
WHERE  application_id                 = x_application_id
FOR UPDATE OF application_id NOWAIT;

recinfo              c%ROWTYPE;

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

IF ( (recinfo.application_id                  	= x_application_id)
 AND (recinfo.application_type_code             = x_application_type_code)
 AND (recinfo.je_source_name                 	= x_je_source_name)
 AND (recinfo.valuation_method_flag         	= x_valuation_method_flag)
 AND ((recinfo.drilldown_procedure_name   	= x_drilldown_procedure_name) OR
      (recinfo.drilldown_procedure_name IS NULL AND x_drilldown_procedure_name IS NULL))
 AND ((recinfo.security_function_name   	= x_security_function_name) OR
      (recinfo.security_function_name IS NULL AND x_security_function_name IS NULL))
 AND ((recinfo.control_account_type_code   	= x_control_account_type_code) OR
      (recinfo.control_account_type_code IS NULL AND x_control_account_type_code IS NULL))
 AND (recinfo.alc_enabled_flag                  = x_alc_enabled_flag)
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
  (x_application_id                   	IN NUMBER
  ,x_application_type_code              IN VARCHAR2 DEFAULT NULL
  ,x_je_source_name                     IN VARCHAR2
  ,x_valuation_method_flag              IN VARCHAR2
  ,x_drilldown_procedure_name           IN VARCHAR2
  ,x_security_function_name             IN VARCHAR2
  ,x_control_account_type_code          IN VARCHAR2
  ,x_alc_enabled_flag                   IN VARCHAR2
  ,x_last_update_date                 	IN DATE
  ,x_last_updated_by                  	IN NUMBER
  ,x_last_update_login                	IN NUMBER)

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

UPDATE xla_subledgers
   SET
       last_update_date                 = x_last_update_date
      ,application_type_code            = nvl(x_application_type_code,application_type_code)
      ,je_source_name          		= x_je_source_name
      ,valuation_method_flag    	= x_valuation_method_flag
      ,drilldown_procedure_name    	= x_drilldown_procedure_name
      ,security_function_name    	= x_security_function_name
      ,control_account_type_code	= x_control_account_type_code
      ,alc_enabled_flag			= x_alc_enabled_flag
      ,last_updated_by            	= x_last_updated_by
      ,last_update_login    		= x_last_update_login
WHERE  application_id     		= x_application_id
;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

--
-- Update the Transaction Security mechanism for the subledger application
--
xla_security_pkg.set_subledger_security(
   p_application_id		=> x_application_id
  ,p_security_function_name	=> x_security_function_name);

-- Add a new partition if not already exsits
update_partitions(p_app_id         => x_application_id
                 ,p_action         => 'ADD');

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
 (x_application_id                   IN NUMBER)
IS
CURSOR c2 IS
SELECT application_short_name
FROM   fnd_application
WHERE  application_id		      = x_application_id;

l_schema           VARCHAR2(30);
l_app_short_name   VARCHAR2(30);
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

OPEN c2;
FETCH c2 INTO l_app_short_name;
if (c2%NOTFOUND) then
  CLOSE c2;
  RAISE NO_DATA_FOUND;
end if;
CLOSE c2;

--
-- Remove the Transaction Security mechanism for the subledger application
--
xla_security_pkg.set_subledger_security(
   p_application_id		=> x_application_id
  ,p_security_function_name	=> null);

xla_event_class_grps_f_pkg.delete_row
  (x_application_id                   => x_application_id
  ,x_event_class_group_code           => C_MANUAL);

xla_event_class_attrs_f_pkg.delete_row
  (x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL
  ,x_event_class_code                 => C_MANUAL);

xla_event_types_f_pkg.delete_row
  (x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL
  ,x_event_class_code                 => C_MANUAL
  ,x_event_type_code                  => C_MANUAL);

DELETE FROM xla_entity_id_mappings
WHERE	application_id 		= x_application_id
AND	entity_code		= C_MANUAL
;

xla_event_classes_f_pkg.delete_row
  (x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL
  ,x_event_class_code                 => C_MANUAL);

xla_entity_types_f_pkg.delete_row
  (x_application_id                   => x_application_id
  ,x_entity_code                      => C_MANUAL);

delete_tpm
  (p_application_id => x_application_id);

DELETE FROM xla_subledgers
WHERE  application_id                 = x_application_id;

IF (SQL%NOTFOUND) THEN
   RAISE NO_DATA_FOUND;
END IF;

-- Drop partitions
update_partitions(p_app_id         => x_application_id
                 ,p_action         => 'DROP');

IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
  trace(p_msg    => 'END of procedure delete_row',
        p_module => l_log_module,
        p_level  => C_LEVEL_PROCEDURE);
END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
  ROLLBACK;
  RAISE;

WHEN OTHERS                                   THEN
  ROLLBACK;
  xla_exceptions_pkg.raise_message
      (p_location => 'xla_subledgers_f_pkg.delete_row');
END delete_row;

/*======================================================================+
|                                                                       |
| Name: load_row                                                        |
| Description: To be used by FNDLOAD to upload a row to the table       |
|                                                                       |
+======================================================================*/
PROCEDURE load_row
(p_application_short_name                   IN VARCHAR2
,p_je_source_name                           IN VARCHAR2
,p_valuation_method_flag                    IN VARCHAR2
,p_drilldown_procedure_name                 IN VARCHAR2
,p_security_function_name                   IN VARCHAR2
,p_application_type_code                    IN VARCHAR2
,p_alc_enabled_flag                         IN VARCHAR2
,p_control_account_type_code                IN VARCHAR2
,p_owner                                    IN VARCHAR2
,p_last_update_date                         IN VARCHAR2)
IS
  CURSOR c_app_id IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name          = p_application_short_name;

  CURSOR c_journal_source IS
  SELECT je_source_name
  FROM   gl_je_sources
  WHERE  je_source_key = p_je_source_name;

  l_application_id        INTEGER;
  l_je_source_name        VARCHAR2(30);
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

  OPEN c_app_id;
  FETCH c_app_id INTO l_application_id;
  CLOSE c_app_id;

  OPEN c_journal_source;
  FETCH c_journal_source INTO l_je_source_name;
  CLOSE c_journal_source;

  BEGIN

    SELECT last_updated_by, last_update_date
      INTO db_luby, db_ludate
      FROM xla_subledgers
     WHERE application_id       = l_application_id;

    IF (fnd_load_util.upload_test(f_luby, f_ludate, db_luby, db_ludate, null)) then
      xla_subledgers_f_pkg.update_row
          (x_application_id                => l_application_id
          ,x_application_type_code         => p_application_type_code
          ,x_je_source_name                => l_je_source_name
          ,x_valuation_method_flag         => p_valuation_method_flag
          ,x_drilldown_procedure_name      => p_drilldown_procedure_name
          ,x_security_function_name        => p_security_function_name
          ,x_control_account_type_code     => p_control_account_type_code
          ,x_alc_enabled_flag              => p_alc_enabled_flag
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      xla_subledgers_f_pkg.insert_row
          (x_rowid                         => l_rowid
          ,x_application_id                => l_application_id
          ,x_application_type_code         => p_application_type_code
          ,x_je_source_name                => l_je_source_name
          ,x_valuation_method_flag         => p_valuation_method_flag
          ,x_drilldown_procedure_name      => p_drilldown_procedure_name
          ,x_security_function_name        => p_security_function_name
          ,x_control_account_type_code     => p_control_account_type_code
          ,x_alc_enabled_flag              => p_alc_enabled_flag
          ,x_creation_date                 => f_ludate
          ,x_created_by                    => f_luby
          ,x_last_update_date              => f_ludate
          ,x_last_updated_by               => f_luby
          ,x_last_update_login             => 0);

  END;

  -- Fix bug 5416476
  UPDATE xla_product_rules_b
     SET compile_status_code = 'N'
   WHERE application_id = l_application_id;

  UPDATE xla_prod_acct_headers
     SET validation_status_code = 'N'
   WHERE application_id = l_application_id;

  UPDATE xla_line_definitions_b
     SET validation_status_code = 'N'
   WHERE application_id = l_application_id;

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
      (p_location   => 'xla_subledgers_f_pkg.load_row');

END load_row;

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


END xla_subledgers_f_pkg;

/
