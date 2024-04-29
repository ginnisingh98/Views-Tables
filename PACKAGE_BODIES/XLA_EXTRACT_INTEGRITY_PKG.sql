--------------------------------------------------------
--  DDL for Package Body XLA_EXTRACT_INTEGRITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EXTRACT_INTEGRITY_PKG" AS
/* $Header: xlaamext.pkb 120.44.12010000.2 2009/02/02 11:32:51 vkasina ship $ */
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_extract_integrity_pkg                                              |
|                                                                            |
| DESCRIPTION                                                                |
|     This is the body of the package that checks the extract integrity      |
|     for an event class and creates sources and source assignments for the  |
|     event class if required                                                |
|                                                                            |
| HISTORY                                                                    |
|     12/16/2003      Dimple Shah    Created                                 |
|     06/08/2005      S. Singhania   Bug 4420371. This reversed the changes  |
|                                      done to fix 3851636                   |
|                                                                            |
+===========================================================================*/

--=============================================================================
--           ****************  declaraions  ********************
--=============================================================================
-------------------------------------------------------------------------------
-- declaring private package variables
-------------------------------------------------------------------------------

g_creation_date                   DATE;
g_last_update_date                DATE;
g_created_by                      INTEGER;
g_last_update_login               INTEGER;
g_last_updated_by                 INTEGER;

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
C_REF_OBJECT_FLAG_N                 CONSTANT VARCHAR2(1) := 'N';
C_REF_OBJECT_FLAG_Y                 CONSTANT VARCHAR2(1) := 'Y';

-------------------------------------------------------------------------------
-- declaring private package arrays
-------------------------------------------------------------------------------
TYPE t_array_codes         IS TABLE OF VARCHAR2(30)   INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)    INDEX BY BINARY_INTEGER;
TYPE t_array_vl2000        IS table OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE t_array_id            IS TABLE OF NUMBER(15)     INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------
FUNCTION Chk_primary_keys_exist
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_amb_context_code            IN  VARCHAR2 DEFAULT NULL
          ,p_product_rule_type_code      IN  VARCHAR2 DEFAULT NULL
          ,p_product_rule_code           IN  VARCHAR2 DEFAULT NULL)
RETURN BOOLEAN;

FUNCTION Validate_accounting_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
RETURN BOOLEAN;

FUNCTION Create_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
RETURN BOOLEAN;

PROCEDURE Assign_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2);

--=============================================================================
--               *********** Local Trace Routine **********
--=============================================================================
C_LEVEL_STATEMENT     CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
C_LEVEL_PROCEDURE     CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
C_LEVEL_EVENT         CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
C_LEVEL_EXCEPTION     CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
C_LEVEL_ERROR         CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
C_LEVEL_UNEXPECTED    CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_extract_integrity_pkg';

g_trace_label   VARCHAR2(240);
g_log_level     NUMBER;
g_log_enabled   BOOLEAN;

PROCEDURE trace
       (p_msg                        IN VARCHAR2
       ,p_level                      IN NUMBER) IS

   l_module         VARCHAR2(240);
BEGIN

IF (g_log_level is NULL) THEN
    g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
END IF;

IF (g_log_level is NULL) THEN
    g_log_enabled :=  fnd_log.test
                               (log_level  => g_log_level
                               ,module     => C_DEFAULT_MODULE);
END IF;

   l_module := C_DEFAULT_MODULE||'.'||g_trace_label;

   IF (p_msg IS NULL AND p_level >= g_log_level) THEN
     fnd_log.message(p_level, l_module);
   ELSIF p_level >= g_log_level THEN
     fnd_log.string(p_level, l_module, p_msg);
   END IF;
EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS THEN
      xla_exceptions_pkg.raise_message
         (p_location   => 'xla_extract_integrity_pkg.trace');
END trace;

--=============================================================================
--          *********** public procedures and functions **********
--=============================================================================
--=============================================================================
--
-- Following are the public routines:
--
--    1.    Check_extract_integrity
--    2.    Validate_extract_objects
--    3.    Validate_sources
--    4.    Validate_sources_with_extract
--    5.    set_extract_object_owner
--
--=============================================================================

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Check_extract_integrity                                               |
|                                                                       |
| This routine is called by the Create and Assign Sources program       |
| to do all validations for an event class                              |
|                                                                       |
+======================================================================*/
FUNCTION Check_extract_integrity
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_processing_mode             IN  VARCHAR2)
RETURN BOOLEAN
IS

   l_application_id   NUMBER(15);
   l_entity_code      VARCHAR2(30);
   l_event_class_code VARCHAR2(30);
   l_return           BOOLEAN      := TRUE;

BEGIN

   l_application_id    := p_application_id;
   l_entity_code       := p_entity_code;
   l_event_class_code  := p_event_class_code;

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

   g_trace_label :='Check_extract_integrity';
   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_processing_mode = ' ||p_processing_mode
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   -- Set environment settings
   xla_environment_pkg.refresh;

   -- Delete the error table for the event class
   DELETE
     FROM xla_amb_setup_errors
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND product_rule_code IS NULL;

   -- Initialize the error package
   Xla_amb_setup_err_pkg.initialize;

   -- Get the extract object owner and store in GT table.
   xla_extract_integrity_pkg.set_extract_object_owner
    (p_application_id        => l_application_id
    ,p_entity_code           => l_entity_code
    ,p_event_class_code      => l_event_class_code
);

   -- Validate extract objects
   IF NOT Xla_extract_integrity_pkg.validate_extract_objects
           (p_application_id        => l_application_id
           ,p_entity_code           => l_entity_code
           ,p_event_class_code      => l_event_class_code) THEN

      l_return := FALSE;
   END IF;

   -- Validate primary keys
   IF NOT Chk_primary_keys_exist
           (p_application_id        => l_application_id
           ,p_entity_code           => l_entity_code
           ,p_event_class_code      => l_event_class_code) THEN
      l_return := FALSE;
   END IF;

   IF p_processing_mode = 'CREATE' THEN

      -- Create sources
      IF NOT Create_sources
              (p_application_id        => l_application_id
              ,p_entity_code           => l_entity_code
              ,p_event_class_code      => l_event_class_code) THEN
         l_return := FALSE;
      END IF;

      -- Assign sources
      Assign_sources
        (p_application_id        => l_application_id
        ,p_entity_code           => l_entity_code
        ,p_event_class_code      => l_event_class_code);

   ELSIF p_processing_mode = 'VALIDATE' THEN

      -- Validate sources with the extract objects
      IF NOT Xla_extract_integrity_pkg.Validate_sources
           (p_application_id        => l_application_id
           ,p_entity_code           => l_entity_code
           ,p_event_class_code      => l_event_class_code) THEN
          l_return := FALSE;
      END IF;

      -- Validate accounting sources
      IF NOT Validate_accounting_sources
           (p_application_id        => l_application_id
           ,p_entity_code           => l_entity_code
           ,p_event_class_code      => l_event_class_code) THEN
          l_return := FALSE;
      END IF;
   END IF;

   -- Insert errors into the error table from the plsql array
   Xla_amb_setup_err_pkg.insert_errors;
   COMMIT;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.check_extract_integrity');
END Check_extract_integrity;  -- end of function

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Validate_extract_objects                                              |
|                                                                       |
| This routine is called to validate the extract objects                |
|                                                                       |
+======================================================================*/
FUNCTION Validate_extract_objects
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_amb_context_code            IN  VARCHAR2
          ,p_product_rule_type_code      IN  VARCHAR2
          ,p_product_rule_code           IN  VARCHAR2)
RETURN BOOLEAN
IS
   -- Variable Declaration
   l_application_id         NUMBER(15);
   l_entity_code            VARCHAR2(30);
   l_event_class_code       VARCHAR2(30);
   l_amb_context_code       VARCHAR2(30);
   l_product_rule_code      VARCHAR2(30);
   l_product_rule_type_code VARCHAR2(1);
   l_return                 BOOLEAN            := TRUE;
   l_exist                  VARCHAR2(1)        := NULL;

   -- Cursor Declaration

   -- Check if extract objects are assigned to an event class

   CURSOR c_ec_obj_exist
   IS
   SELECT 'x'
     FROM xla_extract_objects e
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

   -- Get all event classes for which extract objects are not assigned

   CURSOR c_aad_obj_exist
   IS
   SELECT h.entity_code, h.event_class_code
     FROM xla_prod_acct_headers h
    WHERE h.application_id           = p_application_id
      AND h.amb_context_code         = p_amb_context_code
      AND h.product_rule_type_code   = p_product_rule_type_code
      AND h.product_rule_code        = p_product_rule_code
      AND h.accounting_required_flag = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_extract_objects e
                       WHERE e.application_id           = h.application_id
                         AND e.entity_code              = h.entity_code
                         AND e.event_class_code         = h.event_class_code);

   l_aad_obj_exist       c_aad_obj_exist%rowtype;

   -- Get all extract objects for the event class that are not defined in the
   -- database

   CURSOR c_ec_objects
   IS
   SELECT object_name
         ,object_type_code
         ,C_REF_OBJECT_FLAG_N   ref_object_flag
     FROM xla_extract_objects e
    WHERE application_id      = p_application_id
      AND entity_code         = p_entity_code
      AND event_class_code    = p_event_class_code
      AND not exists (SELECT 'x'
                        FROM xla_extract_objects_gt o
                       WHERE o.object_name = e.object_name)
   --
   -- Get all reference objects for the event class that are not defined in the
   -- database
    UNION ALL
   SELECT r.reference_object_name
         ,e.object_type_code
         ,C_REF_OBJECT_FLAG_Y   ref_object_flag
     FROM xla_reference_objects r
         ,xla_extract_objects   e
    WHERE r.application_id    = p_application_id
      AND r.entity_code       = p_entity_code
      AND r.event_class_code  = p_event_class_code
      AND e.application_id    = r.application_id
      AND e.entity_code       = r.entity_code
      AND e.event_class_code  = r.event_class_code
      AND e.object_name       = r.object_name
      AND not exists (SELECT 'x'
                        FROM xla_reference_objects_gt o
                       WHERE o.reference_object_name = r.reference_object_name);


   l_ec_objects       c_ec_objects%rowtype;

   -- Get all event classes for the AAD whose extract objects are not
   -- defined in the database

   CURSOR c_aad_objects
   IS
   SELECT e.entity_code
         ,e.event_class_code
         ,e.object_name
         ,e.object_type_code
         ,C_REF_OBJECT_FLAG_N          ref_object_flag
     FROM xla_extract_objects e, xla_prod_acct_headers h
    WHERE h.application_id           = p_application_id
      AND h.amb_context_code         = p_amb_context_code
      AND h.product_rule_type_code   = p_product_rule_type_code
      AND h.product_rule_code        = p_product_rule_code
      AND h.accounting_required_flag = 'Y'
      AND e.application_id           = h.application_id
      AND e.entity_code              = h.entity_code
      AND e.event_class_code         = h.event_class_code
      AND not exists (SELECT 'x'
                        FROM xla_extract_objects_gt o
                       WHERE o.object_name = e.object_name)
    UNION ALL
   SELECT r.entity_code
         ,r.event_class_code
         ,r.reference_object_name
         ,e.object_type_code
         ,C_REF_OBJECT_FLAG_Y          ref_object_flag
     FROM xla_reference_objects r,
          xla_extract_objects   e,
          xla_prod_acct_headers h
    WHERE h.application_id           = p_application_id
      AND h.amb_context_code         = p_amb_context_code
      AND h.product_rule_type_code   = p_product_rule_type_code
      AND h.product_rule_code        = p_product_rule_code
      AND h.accounting_required_flag = 'Y'
      AND r.application_id           = h.application_id
      AND r.entity_code              = h.entity_code
      AND r.event_class_code         = h.event_class_code
      AND e.application_id           = r.application_id
      AND e.entity_code              = r.entity_code
      AND e.event_class_code         = r.event_class_code
      AND not exists (SELECT 'x'
                        FROM xla_reference_objects_gt o
                       WHERE o.reference_object_name = r.reference_object_name);

   l_aad_objects       c_aad_objects%rowtype;
   l_message_name      VARCHAR2(30);

BEGIN

   l_application_id         := p_application_id;
   l_entity_code            := p_entity_code;
   l_event_class_code       := p_event_class_code;
   l_amb_context_code       := p_amb_context_code;
   l_product_rule_code      := p_product_rule_code;
   l_product_rule_type_code := p_product_rule_type_code;

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

   g_trace_label :='Validate_extract_objects';
   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_amb_context_code = '||p_amb_context_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_type_code = ' ||p_product_rule_type_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_code = ' ||p_product_rule_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   -- Validate extract objects for an event class
   IF p_event_class_code is not null then

      -- Check if atleast one extract object is assigned to the event class
      OPEN c_ec_obj_exist;
      FETCH c_ec_obj_exist
       INTO l_exist;
      IF c_ec_obj_exist%NOTFOUND THEN
         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_EC_NO_EXTRACT_OBJECTS'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EVENT_CLASS'
            ,p_category_sequence        => 2
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code);

          l_return := FALSE;
      END IF;
      CLOSE c_ec_obj_exist;

      -- Check if the extract objects assigned to the event class exist
      -- in the database

      OPEN c_ec_objects;
      LOOP
         FETCH c_ec_objects
          INTO l_ec_objects;
         EXIT WHEN c_ec_objects%notfound;

           IF l_ec_objects.ref_object_flag = C_REF_OBJECT_FLAG_Y THEN
              l_message_name := 'XLA_AB_REF_OBJECT_NOT_DEFINED';
           ELSE
              l_message_name := 'XLA_AB_EXT_OBJECT_NOT_DEFINED';
           END IF;

           Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => l_message_name
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_extract_object_name      => l_ec_objects.object_name
            ,p_extract_object_type      => l_ec_objects.object_type_code);

          l_return := FALSE;
      END LOOP;
      CLOSE c_ec_objects;

   -- Validate extract objects for an application accounting definition
   ELSIF p_product_rule_code is not null then

      -- Error all event classes that do not have extract objects assigned

      OPEN c_aad_obj_exist;
      LOOP
         FETCH c_aad_obj_exist
          INTO l_aad_obj_exist;
         EXIT WHEN c_aad_obj_exist%notfound;
           Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_EC_NO_EXTRACT_OBJECTS'
            ,p_message_type             => 'W'
            ,p_message_category         => 'EVENT_CLASS'
            ,p_category_sequence        => 2
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_aad_obj_exist.entity_code
            ,p_event_class_code         => l_aad_obj_exist.event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code);

          l_return := FALSE;
      END LOOP;
      CLOSE c_aad_obj_exist;

      -- Error all event classes whose extract objects
      -- are not defined in the database

      OPEN c_aad_objects;
      LOOP
         FETCH c_aad_objects
          INTO l_aad_objects;
         EXIT WHEN c_aad_objects%notfound;

           IF l_aad_objects.ref_object_flag = C_REF_OBJECT_FLAG_Y THEN
             l_message_name := 'XLA_AB_REF_OBJECT_NOT_DEFINED';
           ELSE
             l_message_name := 'XLA_AB_EXT_OBJECT_NOT_DEFINED';
           END IF;

           Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_EXT_OBJECT_NOT_DEFINED'
            ,p_message_type             => 'W'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_aad_objects.entity_code
            ,p_event_class_code         => l_aad_objects.event_class_code
            ,p_extract_object_name      => l_aad_objects.object_name
            ,p_extract_object_type      => l_aad_objects.object_type_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code);

          l_return := FALSE;
      END LOOP;
      CLOSE c_aad_objects;
   END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.validate_extract_objects');
END validate_extract_objects;  -- end of function

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Validate_sources                                                      |
|                                                                       |
| This routine is called to insert all sources for an event class into  |
| a global temporary table before calling validate_sources_with_extract |
|                                                                       |
+======================================================================*/
FUNCTION Validate_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
RETURN BOOLEAN
IS
   -- Variable Declaration

   l_application_id         NUMBER(15);
   l_entity_code            VARCHAR2(30);
   l_event_class_code       VARCHAR2(30);
   l_return                 BOOLEAN            := TRUE;
   l_exist                  VARCHAR2(1)        := NULL;

   -- Cursor Declaration

   -- Check if GT table has any sources
   CURSOR c_gt_sources
   IS
   SELECT 'x'
     FROM xla_evt_class_sources_gt
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

BEGIN

   l_application_id    := p_application_id;
   l_entity_code       := p_entity_code;
   l_event_class_code  := p_event_class_code;

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

   g_trace_label :='Validate_Sources';
   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   -- Insert all sources that are assigned to the event class into the GT table
   INSERT INTO xla_evt_class_sources_gt
         (application_id
        ,entity_code
        ,event_class_code
        ,source_application_id
        ,source_code
        ,source_datatype_code,source_level_code)
 (SELECT e.application_id
        ,e.entity_code
        ,e.event_class_code
        ,e.source_application_id
         ,e.source_code
         ,decode(s.datatype_code,'N','NUMBER',
                 'C','VARCHAR2', 'D','DATE') source_datatype_code,
           decode(s.translated_flag,'N',
            decode(e.source_code,'LANGUAGE',
            decode(e.level_code,'H','HEADER_MLS','L','LINE_MLS'),
            decode(e.level_code,'H',
                 'HEADER','L','LINE')),
                 'Y',
            decode(e.level_code,'H','HEADER_MLS','L','LINE_MLS'))
           source_level_code
     FROM xla_event_sources e, xla_sources_b s
    WHERE e.source_application_id = s.application_id
      AND e.source_code           = s.source_code
      AND e.source_type_code      = s.source_type_code
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code);

   OPEN c_gt_sources;
   FETCH c_gt_sources
    INTO l_exist;
   IF c_gt_sources%found THEN

        -- Call the function to validate all sources in the GT table
      IF NOT Xla_extract_integrity_pkg.validate_sources_with_extract
              (p_application_id    => l_application_id
              ,p_entity_code       => l_entity_code
              ,p_event_class_code  => l_event_class_code)  THEN
         l_return := FALSE;
      END IF;

   END IF;
   CLOSE c_gt_sources;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.validate_sources');
END Validate_sources;  -- end of function

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| Validate_sources_with_extract                                         |
|                                                                       |
| This routine is called to validate the sources with extract objects   |
|                                                                       |
+======================================================================*/
FUNCTION Validate_sources_with_extract
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_amb_context_code            IN  VARCHAR2
          ,p_product_rule_type_code      IN  VARCHAR2
          ,p_product_rule_code           IN  VARCHAR2)
RETURN BOOLEAN
IS

   -- Variable Declaration
   l_application_id         NUMBER(15);
   l_entity_code            VARCHAR2(30);
   l_event_class_code       VARCHAR2(30);
   l_amb_context_code       VARCHAR2(30);
   l_product_rule_code      VARCHAR2(30);
   l_product_rule_type_code VARCHAR2(1);
   l_return                 BOOLEAN            := TRUE;
   l_exist                  VARCHAR2(1)        := NULL;

   -- Variables of type Array
   l_array_pop_source_appl_id      t_array_id;
   l_array_pop_source_code         t_array_codes;
   l_array_pop_object_name         t_array_codes;
   l_array_pop_object_type         t_array_codes;
   l_array_pop_pop_flag            t_array_type_codes;
   l_array_pop_col_datatype        t_array_codes;

   l_array_ref_pop_source_appl_id  t_array_id;
   l_array_ref_pop_source_code     t_array_codes;
   l_array_ref_pop_object_name     t_array_codes;
   l_array_ref_pop_object_type     t_array_codes;
   l_array_ref_pop_pop_flag        t_array_type_codes;
   l_array_ref_pop_col_datatype    t_array_codes;
   l_array_ref_pop_join_condition  t_array_vl2000;
   l_array_ref_pop_linked_obj      t_array_codes;

   l_array_source_appl_id          t_array_id;
   l_array_source_code             t_array_codes;
   l_array_object_name             t_array_codes;
   l_array_object_type             t_array_codes;
   l_array_pop_flag                t_array_type_codes;
   l_array_col_datatype            t_array_codes;

   l_array_ref_source_appl_id      t_array_id;
   l_array_ref_source_code         t_array_codes;
   l_array_ref_object_name         t_array_codes;
   l_array_ref_object_type         t_array_codes;
   l_array_ref_pop_flag            t_array_type_codes;
   l_array_ref_col_datatype        t_array_codes;
   l_array_ref_join_condition      t_array_vl2000;
   l_array_ref_linked_obj          t_array_codes;

   l_array_dt_source_appl_id       t_array_id;
   l_array_dt_source_code          t_array_codes;
   l_array_dt_object_name          t_array_codes;
   l_array_dt_object_type          t_array_codes;
   l_array_dt_pop_flag             t_array_type_codes;
   l_array_dt_col_datatype         t_array_codes;

   l_array_ref_dt_source_appl_id   t_array_id;
   l_array_ref_dt_source_code      t_array_codes;
   l_array_ref_dt_object_name      t_array_codes;
   l_array_ref_dt_object_type      t_array_codes;
   l_array_ref_dt_pop_flag         t_array_type_codes;
   l_array_ref_dt_col_datatype     t_array_codes;
   l_array_ref_dt_join_condition   t_array_vl2000;

   -- Cursor Declaration

   -- Get all extract objects for the sources whose data type match
   -- and the always populated flag is "Yes"
   CURSOR c_always_pop
   IS
   SELECT g.source_application_id, g.source_code,
          o.object_name extract_object_name,
          o.object_type_code extract_object_type,
          o.always_populated_flag extract_object_pop_flag,
          g.source_datatype_code column_datatype_code
     FROM xla_evt_class_sources_gt g, xla_extract_objects o,
          xla_extract_objects_gt og
    WHERE g.application_id        = o.application_id
      AND g.entity_code           = o.entity_code
      AND g.event_class_code      = o.event_class_code
      AND g.source_level_code     = o.object_type_code
      AND g.source_application_id = o.application_id
      AND og.object_name          = o.object_name
      AND EXISTS (
             SELECT 1
               FROM dba_tab_columns t
              WHERE og.owner = t.owner
                AND o.object_name = t.table_name
                AND t.column_name = g.source_code
                AND DECODE(T.DATA_TYPE,'CHAR','VARCHAR2',T.DATA_TYPE) = G.SOURCE_DATATYPE_CODE
            )
      AND g.application_id        = p_application_id
      AND g.entity_code           = p_entity_code
      AND g.event_class_code      = p_event_class_code
      AND o.always_populated_flag = 'Y'
      AND g.extract_object_name IS NULL;


   -- Get all reference objects for the sources whose data type match
   -- and the always populated flag is "Yes"
   CURSOR c_ref_always_pop
   IS
   SELECT g.source_application_id,  g.source_code, r.reference_object_name extract_object_name,
          o.object_type_code extract_object_type,
          r.always_populated_flag extract_object_pop_flag,
          g.source_datatype_code column_datatype_code,
          r.join_condition, r.linked_to_ref_obj_name
     FROM xla_evt_class_sources_gt g, xla_reference_objects r, xla_extract_objects o,
          xla_reference_objects_gt og
    WHERE g.application_id         = r.application_id
      AND g.entity_code            = r.entity_code
      AND g.event_class_code       = r.event_class_code
      AND g.source_application_id  = r.reference_object_appl_id
      AND g.source_level_code      = o.object_type_code
      AND r.application_id         = o.application_id
      AND r.entity_code            = o.entity_code
      AND r.event_class_code       = o.event_class_code
      AND r.object_name            = o.object_name
      AND og.reference_object_name = r.reference_object_name
      AND EXISTS (
             SELECT 1
               FROM dba_tab_columns t
              WHERE og.owner = t.owner
                AND r.reference_object_name = t.table_name
                AND t.column_name = g.source_code
                AND DECODE(t.data_type,'CHAR','VARCHAR2',t.data_type) = g.source_datatype_code
            )
      AND g.application_id         = p_application_id
      AND g.entity_code            = p_entity_code
      AND g.event_class_code       = p_event_class_code
      AND r.always_populated_flag  = 'Y'
      AND g.extract_object_name IS NULL;


   -- Get all extract objects for the sources whose data type match
   -- and the always populated flag is "No"
   CURSOR c_same_datatype
   IS
   SELECT g.source_application_id, g.source_code,
          o.object_name extract_object_name,
          o.object_type_code extract_object_type,
          o.always_populated_flag extract_object_pop_flag,
          g.source_datatype_code column_datatype_code
     FROM xla_evt_class_sources_gt g, xla_extract_objects o,
          xla_extract_objects_gt og
    WHERE g.application_id        = o.application_id
      AND g.entity_code           = o.entity_code
      AND g.event_class_code      = o.event_class_code
      AND g.source_level_code     = o.object_type_code
      AND g.source_application_id = o.application_id
      AND og.object_name          = o.object_name
      AND EXISTS (
             SELECT 1
               FROM dba_tab_columns t
              WHERE og.owner = t.owner
                AND o.object_name = t.table_name
                AND t.column_name = g.source_code
                AND DECODE(T.DATA_TYPE,'CHAR','VARCHAR2',T.DATA_TYPE) = g.source_datatype_code
            )
      AND g.application_id        = p_application_id
      AND g.entity_code           = p_entity_code
      AND g.event_class_code      = p_event_class_code
      AND g.extract_object_name IS NULL;

   -- Get all reference objects for the sources whose data type match
   -- and the always populated flag is "No"
   CURSOR c_ref_same_datatype
   IS
   SELECT g.source_application_id,  g.source_code,
          r.reference_object_name extract_object_name,
          o.object_type_code extract_object_type,
          r.always_populated_flag extract_object_pop_flag,
          g.source_datatype_code column_datatype_code,
          r.join_condition,  r.linked_to_ref_obj_name
      FROM xla_evt_class_sources_gt g, xla_reference_objects r, xla_extract_objects o,
           xla_reference_objects_gt og
    WHERE g.application_id         = r.application_id
      AND g.entity_code            = r.entity_code
      AND g.event_class_code       = r.event_class_code
      AND g.source_application_id  = r.reference_object_appl_id
      AND g.source_level_code      = o.object_type_code
      AND r.application_id         = o.application_id
      AND r.entity_code            = o.entity_code
      AND r.event_class_code       = o.event_class_code
      AND r.object_name            = o.object_name
      AND og.reference_object_name = r.reference_object_name
      AND EXISTS (
             SELECT 1
               FROM dba_tab_columns t
              WHERE og.owner = t.owner
                AND r.reference_object_name = t.table_name
                AND t.column_name = g.source_code
                AND DECODE(t.data_type,'CHAR','VARCHAR2',t.data_type) = g.source_datatype_code
            )
      AND g.application_id         = p_application_id
      AND g.entity_code            = p_entity_code
      AND g.event_class_code       = p_event_class_code
      AND g.extract_object_name IS NULL;


   -- Get remainder of extract objects for the sources whose data type do not match
   CURSOR c_diff_datatype
   IS
   SELECT DISTINCT
          g.source_application_id, g.source_code,
          o.object_name extract_object_name,
          o.object_type_code extract_object_type,
          o.always_populated_flag extract_object_pop_flag,
          -- 4713242 Performance Fix
          (SELECT DECODE(t.data_type,'CHAR','VARCHAR2',t.data_type) COLUMN_DATATYPE_CODE
             FROM dba_tab_columns T
            WHERE og.owner = t.owner
              AND o.object_name = t.table_name
              AND t.column_name = g.source_code)
     FROM xla_evt_class_sources_gt g, xla_extract_objects o,
          xla_extract_objects_gt og
    WHERE g.application_id        = o.application_id
      AND g.entity_code           = o.entity_code
      AND g.event_class_code      = o.event_class_code
      AND g.source_level_code     = o.object_type_code
      AND g.source_application_id = o.application_id
      AND og.object_name          = o.object_name
      AND g.application_id        = p_application_id
      AND g.entity_code           = p_entity_code
      AND g.event_class_code      = p_event_class_code
      AND g.extract_object_name  IS NULL
      AND EXISTS (SELECT 1
                    FROM dba_tab_columns t
                   WHERE og.owner = t.owner
                     AND o.object_name = t.table_name
                     AND t.column_name = g.source_code);

   -- Get remainder of reference objects for the sources whose data type do not match
   CURSOR c_ref_diff_datatype
   IS
   SELECT DISTINCT g.source_application_id
          ,g.source_code
          ,r.reference_object_name extract_object_name
          ,o.object_type_code extract_object_type
          ,o.always_populated_flag extract_object_pop_flag
          -- 4713242 Performance Fix
          ,(SELECT DECODE(t.data_type,'CHAR','VARCHAR2',t.data_type) COLUMN_DATATYPE_CODE
             FROM dba_tab_columns T
            WHERE og.owner = t.owner
              AND r.reference_object_name = t.table_name
              AND t.column_name = g.source_code)
          ,r.join_condition
      FROM xla_evt_class_sources_gt g
          ,xla_reference_objects r
          ,xla_extract_objects o
          ,xla_reference_objects_gt og
    WHERE g.application_id         = r.application_id
      AND g.entity_code            = r.entity_code
      AND g.event_class_code       = r.event_class_code
      AND g.source_level_code      = o.object_type_code
      AND r.application_id         = o.application_id
      AND r.entity_code            = o.entity_code
      AND r.event_class_code       = o.event_class_code
      AND r.object_name            = o.object_name
      AND og.reference_object_name = r.reference_object_name
      AND g.application_id         = p_application_id
      AND g.entity_code            = p_entity_code
      AND g.event_class_code       = p_event_class_code
      AND g.extract_object_name  IS NULL
      AND EXISTS (SELECT 1
                    FROM dba_tab_columns t
                   WHERE og.owner                = t.owner
                     AND r.reference_object_name = t.table_name
                     AND t.column_name           = g.source_code);


   -- Get all sources from GT table with null extract object
   CURSOR c_null_obj
   IS
   SELECT source_application_id, source_code, source_level_code
    FROM xla_evt_class_sources_gt g
   WHERE g.application_id        = p_application_id
     AND g.entity_code           = p_entity_code
     AND g.event_class_code      = p_event_class_code
     AND extract_object_name IS NULL;

   l_null_obj   c_null_obj%rowtype;

   -- Get all sources from GT table whose datatype does not match with column datatype
   CURSOR c_datatype
   IS
   SELECT source_application_id, source_code, extract_object_name,
          extract_object_type_code
      FROM xla_evt_class_sources_gt g
     WHERE source_datatype_code    <> column_datatype_code
      AND extract_object_name  IS NOT NULL
       AND g.application_id        = p_application_id
       AND g.entity_code           = p_entity_code
       AND g.event_class_code      = p_event_class_code;

   l_datatype   c_datatype%rowtype;

BEGIN

   l_application_id         := p_application_id;
   l_entity_code            := p_entity_code;
   l_event_class_code       := p_event_class_code;
   l_amb_context_code       := p_amb_context_code;
   l_product_rule_code      := p_product_rule_code;
   l_product_rule_type_code := p_product_rule_type_code;

   g_trace_label :='Validate_sources_with_extract';

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_amb_context_code = '||p_amb_context_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_type_code = ' ||p_product_rule_type_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_code = ' ||p_product_rule_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   -- Get all extract objects which are valid with the source definition
   -- and the data type of source matches the column data type
   -- the extract object is always populated

   OPEN c_always_pop;
   FETCH c_always_pop
   BULK COLLECT INTO l_array_pop_source_appl_id, l_array_pop_source_code,
                     l_array_pop_object_name,l_array_pop_object_type,
                     l_array_pop_pop_flag, l_array_pop_col_datatype;

   -- Bulk update the GT table with the extract object name for each source
   IF l_array_pop_source_code.COUNT > 0 THEN
       FORALL i IN l_array_pop_source_code.FIRST..l_array_pop_source_code.LAST
         UPDATE xla_evt_class_sources_gt gt
            SET gt.extract_object_name          = l_array_pop_object_name(i),
               gt.extract_object_type_code     = l_array_pop_object_type(i),
               gt.always_populated_flag        = l_array_pop_pop_flag(i),
               gt.column_datatype_code         = l_array_pop_col_datatype(i),
               gt.reference_object_flag        = C_REF_OBJECT_FLAG_N
          WHERE gt.source_application_id        = l_array_pop_source_appl_id(i)
           AND gt.source_code                  = l_array_pop_source_code(i)
           AND gt.application_id               = p_application_id
           AND gt.entity_code                  = p_entity_code
           AND gt.event_class_code             = p_event_class_code;
   END IF;
   CLOSE c_always_pop;

   OPEN c_ref_always_pop;
   FETCH c_ref_always_pop
   BULK COLLECT INTO l_array_ref_pop_source_appl_id,
                     l_array_ref_pop_source_code, l_array_ref_pop_object_name,
                     l_array_ref_pop_object_type, l_array_ref_pop_pop_flag,
                     l_array_ref_pop_col_datatype, l_array_ref_pop_join_condition
                     ,l_array_ref_pop_linked_obj;

   -- Bulk update the GT table with the reference object name for each source
   IF l_array_ref_pop_source_code.COUNT > 0 THEN
       FORALL i IN l_array_ref_pop_source_code.FIRST..l_array_ref_pop_source_code.LAST
         UPDATE xla_evt_class_sources_gt gt
            SET gt.extract_object_name          = l_array_ref_pop_object_name(i),
               gt.extract_object_type_code     = l_array_ref_pop_object_type(i),
               gt.always_populated_flag        = l_array_ref_pop_pop_flag(i),
               gt.column_datatype_code         = l_array_ref_pop_col_datatype(i),
               gt.reference_object_flag        = C_REF_OBJECT_FLAG_Y,
               gt.join_condition               = l_array_ref_pop_join_condition(i)
          WHERE gt.source_application_id        = l_array_ref_pop_source_appl_id(i)
           AND gt.source_code                  = l_array_ref_pop_source_code(i)
           AND gt.application_id               = p_application_id
           AND gt.entity_code                  = p_entity_code
           AND gt.event_class_code             = p_event_class_code
           AND l_array_ref_pop_linked_obj(i) IS NULL;

       FORALL i IN l_array_ref_pop_source_code.FIRST..l_array_ref_pop_source_code.LAST
         UPDATE xla_evt_class_sources_gt gt
            SET gt.extract_object_name          = l_array_ref_pop_object_name(i),
               gt.extract_object_type_code     = l_array_ref_pop_object_type(i),
               gt.always_populated_flag        = l_array_ref_pop_pop_flag(i),
               gt.column_datatype_code         = l_array_ref_pop_col_datatype(i),
               gt.reference_object_flag        = C_REF_OBJECT_FLAG_Y,
               gt.join_condition               = l_array_ref_pop_join_condition(i)
          WHERE gt.source_application_id        = l_array_ref_pop_source_appl_id(i)
           AND gt.source_code                  = l_array_ref_pop_source_code(i)
           AND gt.application_id               = p_application_id
           AND gt.entity_code                  = p_entity_code
           AND gt.event_class_code             = p_event_class_code
           AND gt.extract_object_name            IS NULL
           AND l_array_ref_pop_linked_obj(i) IS NOT NULL;
   END IF;
   CLOSE c_ref_always_pop;


   -- Get all extract objects which are valid with the source definition
   -- and the data type of source matches the column data type
   -- and the extract object is not always populated
   OPEN c_same_datatype;
   FETCH c_same_datatype
   BULK COLLECT INTO l_array_source_appl_id, l_array_source_code,
                     l_array_object_name, l_array_object_type,
                     l_array_pop_flag, l_array_col_datatype;

   -- Bulk update the GT table with the extract object name for each source
   IF l_array_source_code.COUNT > 0 THEN
       FORALL i IN l_array_source_code.FIRST..l_array_source_code.LAST
         UPDATE xla_evt_class_sources_gt gt
            SET gt.extract_object_name          = l_array_object_name(i),
               gt.extract_object_type_code     = l_array_object_type(i),
               gt.always_populated_flag        = l_array_pop_flag(i),
               gt.column_datatype_code         = l_array_col_datatype(i),
               gt.reference_object_flag        = C_REF_OBJECT_FLAG_N
          WHERE gt.source_application_id        = l_array_source_appl_id(i)
           AND gt.source_code                  = l_array_source_code(i)
           AND gt.application_id               = p_application_id
           AND gt.entity_code                  = p_entity_code
           AND gt.event_class_code             = p_event_class_code;
   END IF;
   CLOSE c_same_datatype;

   -- Get all reference objects which are valid with the source definition
   -- and the data type of source matches the column data type
   -- and the extract object is not always populated
   OPEN c_ref_same_datatype;
   FETCH c_ref_same_datatype
   BULK COLLECT INTO l_array_ref_source_appl_id,
                     l_array_ref_source_code, l_array_ref_object_name,
                     l_array_ref_object_type, l_array_ref_pop_flag,
                     l_array_ref_col_datatype, l_array_ref_join_condition,
                     l_array_ref_linked_obj;

   -- Bulk update the GT table with the reference object name for each source
   IF l_array_ref_source_code.COUNT > 0 THEN
       FORALL i IN l_array_ref_source_code.FIRST..l_array_ref_source_code.LAST
         UPDATE xla_evt_class_sources_gt gt
            SET gt.extract_object_name          = l_array_ref_object_name(i),
               gt.extract_object_type_code     = l_array_ref_object_type(i),
               gt.always_populated_flag        = l_array_ref_pop_flag(i),
               gt.column_datatype_code         = l_array_ref_col_datatype(i),
               gt.reference_object_flag        = C_REF_OBJECT_FLAG_Y,
               gt.join_condition               = l_array_ref_join_condition(i)
          WHERE gt.source_application_id        = l_array_ref_source_appl_id(i)
           AND gt.source_code                  = l_array_ref_source_code(i)
           AND gt.application_id               = p_application_id
           AND gt.entity_code                  = p_entity_code
           AND gt.event_class_code             = p_event_class_code
           AND l_array_ref_linked_obj(i)  IS NULL;
       FORALL i IN l_array_ref_source_code.FIRST..l_array_ref_source_code.LAST
         UPDATE xla_evt_class_sources_gt gt
            SET gt.extract_object_name          = l_array_ref_object_name(i),
               gt.extract_object_type_code     = l_array_ref_object_type(i),
               gt.always_populated_flag        = l_array_ref_pop_flag(i),
               gt.column_datatype_code         = l_array_ref_col_datatype(i),
               gt.reference_object_flag        = C_REF_OBJECT_FLAG_Y,
               gt.join_condition               = l_array_ref_join_condition(i)
          WHERE gt.source_application_id        = l_array_ref_source_appl_id(i)
           AND gt.source_code                  = l_array_ref_source_code(i)
           AND gt.application_id               = p_application_id
           AND gt.entity_code                  = p_entity_code
           AND gt.event_class_code             = p_event_class_code
           AND gt.extract_object_name     IS NULL
           AND l_array_ref_linked_obj(i)  IS NOT NULL;
    END IF;
    CLOSE c_ref_same_datatype;


   -- Get all extract objects which are valid with the source definition
   -- but the data type of source may not match the column data type

   OPEN c_diff_datatype;
   FETCH c_diff_datatype
   BULK COLLECT INTO l_array_dt_source_appl_id, l_array_dt_source_code,
                     l_array_dt_object_name, l_array_dt_object_type,
                     l_array_dt_pop_flag, l_array_dt_col_datatype;

    -- Bulk update the GT table with the extract object name for each source
    IF l_array_dt_source_code.COUNT > 0 THEN
       FORALL j IN l_array_dt_source_code.FIRST..l_array_dt_source_code.LAST
         UPDATE xla_evt_class_sources_gt gt
            SET gt.extract_object_name          = l_array_dt_object_name(j),
                gt.extract_object_type_code     = l_array_dt_object_type(j),
                gt.always_populated_flag        = l_array_dt_pop_flag(j),
                gt.column_datatype_code         = l_array_dt_col_datatype(j),
                gt.reference_object_flag        = C_REF_OBJECT_FLAG_N
          WHERE gt.source_application_id        = l_array_dt_source_appl_id(j)
            AND gt.source_code                  = l_array_dt_source_code(j)
            AND gt.application_id               = p_application_id
            AND gt.entity_code                  = p_entity_code
            AND gt.event_class_code             = p_event_class_code;
    END IF;
    CLOSE c_diff_datatype;

   -- Get all reference objects which are valid with the source definition
   -- but the data type of source may not match the column data type

    OPEN c_ref_diff_datatype;
    FETCH c_ref_diff_datatype
    BULK COLLECT INTO l_array_ref_dt_source_appl_id, l_array_ref_dt_source_code,
                      l_array_ref_dt_object_name, l_array_ref_dt_object_type,
                      l_array_ref_dt_pop_flag, l_array_ref_dt_col_datatype,
                      l_array_ref_dt_join_condition;

    -- Bulk update the GT table with the reference object name for each source
    IF l_array_ref_dt_source_code.COUNT > 0 THEN
       FORALL j IN l_array_ref_dt_source_code.FIRST..l_array_ref_dt_source_code.LAST
       UPDATE xla_evt_class_sources_gt gt
          SET gt.extract_object_name          = l_array_ref_dt_object_name(j),
              gt.extract_object_type_code     = l_array_ref_dt_object_type(j),
              gt.always_populated_flag        = l_array_ref_dt_pop_flag(j),
              gt.column_datatype_code         = l_array_ref_dt_col_datatype(j),
              gt.reference_object_flag        = C_REF_OBJECT_FLAG_Y,
              gt.join_condition               = l_array_ref_dt_join_condition(j)
        WHERE gt.source_application_id        = l_array_ref_dt_source_appl_id(j)
          AND gt.source_code                  = l_array_ref_dt_source_code(j)
          AND gt.application_id               = p_application_id
          AND gt.entity_code                  = p_entity_code
          AND gt.event_class_code             = p_event_class_code;
    END IF;
    CLOSE c_ref_diff_datatype;


    -- Error all sources that do not exist in the right extract object
    OPEN c_null_obj;
    LOOP
      FETCH c_null_obj
        INTO l_null_obj;
       EXIT WHEN c_null_obj%notfound;
         Xla_amb_setup_err_pkg.stack_error
               (p_message_name             => 'XLA_AB_SRC_NOT_DEFINED_IN_EXT'
               ,p_message_type             => 'E'
               ,p_message_category         => 'EXTRACT_SOURCE'
               ,p_category_sequence        => 4
               ,p_application_id           => l_application_id
               ,p_entity_code              => l_entity_code
               ,p_event_class_code         => l_event_class_code
               ,p_amb_context_code         => l_amb_context_code
               ,p_product_rule_type_code   => l_product_rule_type_code
               ,p_product_rule_code        => l_product_rule_code
               ,p_source_application_id    => l_null_obj.source_application_id
               ,p_source_code              => l_null_obj.source_code
               ,p_source_type_code         => 'S'
               ,p_extract_object_type      => l_null_obj.source_level_code);

       l_return := FALSE;
    END LOOP;
    CLOSE c_null_obj;

   -- Error all sources that do not match the corresponding column datatype
    OPEN c_datatype;
    LOOP
       FETCH c_datatype
        INTO l_datatype;
       EXIT WHEN c_datatype%notfound;
         Xla_amb_setup_err_pkg.stack_error
               (p_message_name             => 'XLA_AB_SRC_DATATYPE_NOT_MATCH'
               ,p_message_type             => 'E'
               ,p_message_category         => 'EXTRACT_SOURCE'
               ,p_category_sequence        => 4
               ,p_application_id           => l_application_id
               ,p_entity_code              => l_entity_code
               ,p_event_class_code         => l_event_class_code
               ,p_amb_context_code         => l_amb_context_code
               ,p_product_rule_type_code   => l_product_rule_type_code
               ,p_product_rule_code        => l_product_rule_code
               ,p_source_application_id    => l_datatype.source_application_id
               ,p_source_code              => l_datatype.source_code
               ,p_source_type_code         => 'S'
               ,p_extract_object_name      => l_datatype.extract_object_name
               ,p_extract_object_type      => l_datatype.extract_object_type_code);

       l_return := FALSE;
    END LOOP;
    CLOSE c_datatype;

    -- Check primary keys for the extract objects when called from an AAD

    IF p_product_rule_code IS NOT NULL THEN
       IF NOT Chk_primary_keys_exist
                   (p_application_id         => l_application_id
                   ,p_entity_code            => l_entity_code
                   ,p_event_class_code       => l_event_class_code
                   ,p_amb_context_code       => l_amb_context_code
                   ,p_product_rule_type_code => l_product_rule_type_code
                   ,p_product_rule_code      => l_product_rule_code) THEN

          l_return := FALSE;

       END IF;
   END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.validate_sources_with_extract');
END validate_sources_with_extract;  -- end of function

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| Set_extract_object_owner                                              |
|                                                                       |
| This routine gets the owner for the extract object and stores it in   |
| a gt table                                                            |
|                                                                       |
+======================================================================*/


PROCEDURE Set_extract_object_owner
          (p_application_id              IN  NUMBER
          ,p_amb_context_code            IN  VARCHAR2
          ,p_product_rule_type_code      IN  VARCHAR2
          ,p_product_rule_code           IN  VARCHAR2
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
IS

   l_user             VARCHAR2(30);
   l_object_name      VARCHAR2(30);
   l_object_type      VARCHAR2(30);
   l_syn_owner        VARCHAR2(30);
   l_ref_object_flag  VARCHAR2(1);

   l_application_id         NUMBER(15);
   l_entity_code            VARCHAR2(30);
   l_event_class_code       VARCHAR2(30);
   l_amb_context_code       VARCHAR2(30);
   l_product_rule_code      VARCHAR2(30);
   l_product_rule_type_code VARCHAR2(1);

   CURSOR c_aad_objects
   IS
   SELECT distinct ext.object_name, C_REF_OBJECT_FLAG_N reference_object_flag
     FROM xla_extract_objects ext, xla_prod_acct_headers hdr
    WHERE ext.application_id         = hdr.application_id
      AND ext.entity_code            = hdr.entity_code
      AND ext.event_class_code       = hdr.event_class_code
      AND hdr.application_id         = p_application_id
      AND hdr.amb_context_code       = p_amb_context_code
      AND hdr.product_rule_type_code = p_product_rule_type_code
      AND hdr.product_rule_code      = p_product_rule_code
    UNION ALL
   SELECT distinct rfr.reference_object_name, C_REF_OBJECT_FLAG_Y reference_object_flag
     FROM xla_reference_objects rfr, xla_prod_acct_headers hdr
    WHERE rfr.application_id         = hdr.application_id
      AND rfr.entity_code            = hdr.entity_code
      AND rfr.event_class_code       = hdr.event_class_code
      AND hdr.application_id         = p_application_id
      AND hdr.amb_context_code       = p_amb_context_code
      AND hdr.product_rule_type_code = p_product_rule_type_code
      AND hdr.product_rule_code      = p_product_rule_code;

   CURSOR c_object_type
   IS
   SELECT usr.object_type
     FROM user_objects usr
    WHERE usr.object_name = l_object_name;

   CURSOR c_syn_owner
   IS
   SELECT syn.table_owner
     FROM user_synonyms syn
    WHERE syn.synonym_name = l_object_name;

BEGIN

   g_trace_label :='Set_extract_object_owner';

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_amb_context_code = '||p_amb_context_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_type_code = ' ||p_product_rule_type_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_code = ' ||p_product_rule_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   l_application_id         := p_application_id;
   l_entity_code            := p_entity_code;
   l_event_class_code       := p_event_class_code;
   l_amb_context_code       := p_amb_context_code;
   l_product_rule_code      := p_product_rule_code;
   l_product_rule_type_code := p_product_rule_type_code;

   DELETE FROM xla_extract_objects_gt;
   DELETE FROM xla_reference_objects_gt;

   -- Get owner for current schema
   SELECT user
     INTO l_user
     FROM DUAL;

   IF p_product_rule_code is NULL THEN

      -- Insert objects for an event class and current owner in GT table
      INSERT
        INTO xla_extract_objects_gt
             (object_name
             ,owner)
      SELECT ext.object_name, l_user
        FROM xla_extract_objects ext
       WHERE EXISTS (SELECT /*+ no_unnest */ 'c'
                       FROM user_objects usr
                      WHERE ext.object_name = usr.object_name
                        AND usr.object_type <> 'SYNONYM' )
         AND ext.application_id = p_application_id
         AND entity_code        = p_entity_code
         AND event_class_code   = p_event_class_code;

      -- Insert reference objects for an event class and current owner in GT table
      -- Assume duplicate objects are not used for an event class
      INSERT
        INTO xla_reference_objects_gt
            (reference_object_name
            ,owner)
      SELECT rfr.reference_object_name, l_user
        FROM xla_reference_objects rfr
       WHERE
         EXISTS (SELECT /*+ no_unnest */ 'c'
                       FROM user_objects usr
                      WHERE rfr.reference_object_name = usr.object_name
                        AND usr.object_type <> 'SYNONYM' )
         AND rfr.application_id     = p_application_id
         AND rfr.entity_code        = p_entity_code
         AND rfr.event_class_code   = p_event_class_code;

      -- Insert objects for an event class and different owner in GT table
      INSERT
        INTO xla_extract_objects_gt
             (object_name
             ,owner)
      SELECT ext.object_name
            ,(SELECT syn.table_owner
	           FROM user_objects  usr
	               ,user_synonyms syn
		      WHERE ext.object_name = usr.object_name
                AND ext.object_name = syn.synonym_name
                AND usr.object_type = 'SYNONYM')
        FROM xla_extract_objects ext
       WHERE EXISTS (SELECT /*+ no_unnest */ 'c'
	                   FROM user_objects  usr
	                       ,user_synonyms syn
		 	          WHERE ext.object_name = usr.object_name
                        AND ext.object_name = syn.synonym_name
                        AND usr.object_type = 'SYNONYM')
         AND ext.application_id = p_application_id
         AND entity_code        = p_entity_code
         AND event_class_code   = p_event_class_code;

      -- Insert objects for an event class and different owner in GT table
      -- Assume duplicate objects are not used for an event class
      INSERT
        INTO xla_reference_objects_gt
             (reference_object_name
             ,owner)
      SELECT rfr.reference_object_name
            ,(SELECT syn.table_owner
	            FROM user_objects  usr
	                ,user_synonyms syn
             -- change rfr.object_name to rfr.reference_object_name, as told by dimple
		       WHERE rfr.reference_object_name = usr.object_name
                 AND rfr.reference_object_name = syn.synonym_name
                 AND usr.object_type = 'SYNONYM')
        FROM xla_reference_objects rfr
       WHERE EXISTS (SELECT /*+ no_unnest */ 'c'
	                   FROM user_objects  usr
	                       ,user_synonyms syn
             -- change rfr.object_name to rfr.reference_object_name, as told by dimple
		 	          WHERE rfr.reference_object_name = usr.object_name
                        AND rfr.reference_object_name = syn.synonym_name
                        AND usr.object_type = 'SYNONYM')
         AND rfr.application_id    = p_application_id
         AND rfr.entity_code       = p_entity_code
         AND rfr.event_class_code  = p_event_class_code;

   ELSE

      -- Insert objects for an AAD and owner in GT table
      OPEN c_aad_objects;
      LOOP
        FETCH c_aad_objects
         INTO l_object_name, l_ref_object_flag;
        EXIT WHEN c_aad_objects%notfound;

        OPEN c_object_type;
        FETCH c_object_type
         INTO l_object_type;

        IF l_object_type <> 'SYNONYM' THEN
           IF l_ref_object_flag = 'N' THEN

              BEGIN
                 INSERT
                   INTO xla_extract_objects_gt
                       (object_name
                       ,owner)
                 VALUES(l_object_name
                       ,l_user);
              EXCEPTION
                 WHEN OTHERS THEN
                   Xla_amb_setup_err_pkg.stack_error
                    (p_message_name             => 'XLA_AB_EXT_OBJECT_ERROR'
                    ,p_message_type             => 'E'
                    ,p_message_category         => 'EXTRACT_OBJECT'
                    ,p_category_sequence        => 3
                    ,p_application_id           => l_application_id
                    ,p_entity_code              => l_entity_code
                    ,p_event_class_code         => l_event_class_code
                    ,p_extract_object_name      => l_object_name
                    ,p_amb_context_code         => l_amb_context_code
                    ,p_product_rule_type_code   => l_product_rule_type_code
                    ,p_product_rule_code        => l_product_rule_code);

              END;

           ELSE
              BEGIN
                 INSERT
                   INTO xla_reference_objects_gt
                       (reference_object_name
                       ,owner)
                 VALUES(l_object_name
                       ,l_user);
              EXCEPTION
                 WHEN OTHERS THEN
                   Xla_amb_setup_err_pkg.stack_error
                    (p_message_name             => 'XLA_AB_EXT_OBJECT_ERROR'
                    ,p_message_type             => 'E'
                    ,p_message_category         => 'EXTRACT_OBJECT'
                    ,p_category_sequence        => 3
                    ,p_application_id           => l_application_id
                    ,p_entity_code              => l_entity_code
                    ,p_event_class_code         => l_event_class_code
                    ,p_extract_object_name      => l_object_name
                    ,p_amb_context_code         => l_amb_context_code
                    ,p_product_rule_type_code   => l_product_rule_type_code
                    ,p_product_rule_code        => l_product_rule_code);

              END;
           END IF;
        ELSE
           OPEN c_syn_owner;
           FETCH c_syn_owner
            INTO l_syn_owner;

           IF l_ref_object_flag = 'N' THEN
              BEGIN
                 INSERT
                   INTO xla_extract_objects_gt
                       (object_name
                       ,owner)
                 VALUES(l_object_name
                       ,l_syn_owner);
              EXCEPTION
                 WHEN OTHERS THEN
                   Xla_amb_setup_err_pkg.stack_error
                    (p_message_name             => 'XLA_AB_EXT_OBJECT_ERROR'
                    ,p_message_type             => 'E'
                    ,p_message_category         => 'EXTRACT_OBJECT'
                    ,p_category_sequence        => 3
                    ,p_application_id           => l_application_id
                    ,p_entity_code              => l_entity_code
                    ,p_event_class_code         => l_event_class_code
                    ,p_extract_object_name      => l_object_name
                    ,p_amb_context_code         => l_amb_context_code
                    ,p_product_rule_type_code   => l_product_rule_type_code
                    ,p_product_rule_code        => l_product_rule_code);

              END;
           ELSE
              BEGIN
                 INSERT
                   INTO xla_reference_objects_gt
                       (reference_object_name
                       ,owner)
                 VALUES(l_object_name
                       ,l_syn_owner);
              EXCEPTION
                 WHEN OTHERS THEN
                   Xla_amb_setup_err_pkg.stack_error
                    (p_message_name             => 'XLA_AB_EXT_OBJECT_ERROR'
                    ,p_message_type             => 'E'
                    ,p_message_category         => 'EXTRACT_OBJECT'
                    ,p_category_sequence        => 3
                    ,p_application_id           => l_application_id
                    ,p_entity_code              => l_entity_code
                    ,p_event_class_code         => l_event_class_code
                    ,p_extract_object_name      => l_object_name
                    ,p_amb_context_code         => l_amb_context_code
                    ,p_product_rule_type_code   => l_product_rule_type_code
                    ,p_product_rule_code        => l_product_rule_code);

              END;
           END IF;

           CLOSE c_syn_owner;
        END IF;
        CLOSE c_object_type;
      END LOOP;
      CLOSE c_aad_objects;
    END IF;


EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.set_extract_object_owner');
END Set_extract_object_owner;  -- end of procedure


--=============================================================================
--          *********** private procedures and functions **********
--=============================================================================
--=============================================================================
--
-- Following are the private routines:
--
--    1.    Chk_primary_keys_exist
--    2.    Validate_accounting_sources
--    3.    Create_sources
--    4.    Assign_sources
--
--
--=============================================================================
/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Chk_primary_keys_exist                                                |
|                                                                       |
| This routine checks if the primary keys are defined in the extract    |
| objects based on extract object type                                  |
|                                                                       |
+======================================================================*/


FUNCTION Chk_primary_keys_exist
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_amb_context_code            IN  VARCHAR2
          ,p_product_rule_type_code      IN  VARCHAR2
          ,p_product_rule_code           IN  VARCHAR2)
RETURN BOOLEAN
IS

   -- Variable Declaration
   l_application_id         NUMBER(15);
   l_entity_code            VARCHAR2(30);
   l_event_class_code       VARCHAR2(30);
   l_amb_context_code       VARCHAR2(30);
   l_product_rule_code      VARCHAR2(30);
   l_product_rule_type_code VARCHAR2(1);
   l_return                 BOOLEAN            := TRUE;

   -- Cursor Declaration

   -- Note: No unnest hint has been added to the subquery based on recommendation
   -- from the performance team to improve performance

   -- Get all extract objects for an AAD which do not have event_id column
   CURSOR c_aad_event_id
   IS
   SELECT distinct extract_object_name, extract_object_type_code
    FROM xla_evt_class_sources_gt e, xla_extract_objects_gt og
    WHERE application_id      = p_application_id
      AND entity_code         = p_entity_code
      AND event_class_code    = p_event_class_code
      AND extract_object_name IS NOT NULL
      AND extract_object_name = og.object_name
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name   = og.object_name
                        AND og.owner       = t.owner
                       AND t.column_name  = 'EVENT_ID'
                       AND t.data_type    = 'NUMBER');
-- 4420371         AND t.NULLABLE     = 'N');

   l_aad_event_id   c_aad_event_id%rowtype;

   -- Get all extract objects for an AAD which do not have language column
   CURSOR c_aad_language
   IS
   SELECT distinct extract_object_name, extract_object_type_code
    FROM xla_evt_class_sources_gt e, xla_extract_objects_gt og
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND extract_object_name IS NOT NULL
     AND extract_object_type_code IN ('HEADER_MLS','LINE_MLS')
      AND extract_object_name = og.object_name
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name  = og.object_name
                        AND og.owner      = t.owner
                       AND t.column_name = 'LANGUAGE'
                       AND t.data_type   = 'VARCHAR2');
-- 4420371            AND t.NULLABLE    = 'N');

   l_aad_language   c_aad_language%rowtype;

   -- Get all extract objects for an AAD which do not have line_number column
   CURSOR c_aad_line_number
   IS
   SELECT distinct extract_object_name, extract_object_type_code
    FROM xla_evt_class_sources_gt e, xla_extract_objects_gt og
    WHERE application_id      = p_application_id
      AND entity_code         = p_entity_code
      AND event_class_code    = p_event_class_code
      AND extract_object_name IS NOT NULL
     AND extract_object_type_code IN ('LINE','LINE_MLS')
      AND extract_object_name = og.object_name
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name  = og.object_name
                        AND og.owner      = t.owner
                       AND t.column_name = 'LINE_NUMBER'
                       AND t.data_type   = 'NUMBER');
-- 4420371            AND t.NULLABLE    = 'N');

   l_aad_line_number   c_aad_line_number%rowtype;

   -- Get all extract objects for an AAD which do not have ledger_id column
   CURSOR c_aad_ledger_id
   IS
   SELECT distinct extract_object_name, extract_object_type_code
    FROM xla_evt_class_sources_gt e, xla_extract_objects_gt og, xla_subledgers app
    WHERE e.application_id           = p_application_id
      AND e.entity_code              = p_entity_code
      AND e.event_class_code         = p_event_class_code
      AND e.extract_object_name IS NOT NULL
     AND e.extract_object_type_code IN ('LINE','LINE_MLS')
      AND e.extract_object_name      = og.object_name
      AND e.application_id           = app.application_id
      AND app.alc_enabled_flag       = 'N'
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name  = og.object_name
                        AND og.owner      = t.owner
                       AND t.column_name = 'LEDGER_ID'
                       AND t.data_type   = 'NUMBER');

   l_aad_ledger_id   c_aad_ledger_id%rowtype;

   -- Get all extract objects for an event class which do not have event_id column
   CURSOR c_event_id
   IS
   SELECT e.object_name, object_type_code
    FROM xla_extract_objects e, xla_extract_objects_gt og
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND e.object_name    = og.object_name
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name  = og.object_name
                        AND og.owner      = t.owner
                       AND t.column_name = 'EVENT_ID'
                       AND t.data_type   = 'NUMBER')
-- 4420371             AND t.nullable    = 'N')
      AND EXISTS (SELECT 'y'
                        FROM xla_extract_objects_gt  a
                       WHERE a.object_name           = e.object_name);

   l_event_id   c_event_id%rowtype;

   -- Get all extract objects for an event class which do not have language column
   CURSOR c_language
   IS
   SELECT e.object_name, object_type_code
    FROM xla_extract_objects e, xla_extract_objects_gt og
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
     AND object_type_code IN ('HEADER_MLS','LINE_MLS')
      AND e.object_name    = og.object_name
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name  = og.object_name
                        AND og.owner      = t.owner
                       AND t.column_name = 'LANGUAGE'
                       AND t.data_type   = 'VARCHAR2')
-- 4420371            AND t.nullable    = 'N')
      AND EXISTS (SELECT 'y'
                        FROM xla_extract_objects_gt a
                       WHERE a.object_name           = e.object_name);

   l_language   c_language%rowtype;

   -- Get all extract objects for an event class which do not have line_number column
   CURSOR c_line_number
   IS
   SELECT e.object_name, object_type_code
    FROM xla_extract_objects e, xla_extract_objects_gt og
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
     AND object_type_code IN ('LINE','LINE_MLS')
      AND e.object_name    = og.object_name
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name  = og.object_name
                        AND og.owner      = t.owner
                       AND t.column_name = 'LINE_NUMBER'
                       AND t.data_type   = 'NUMBER')
-- 4420371            AND t.nullable    = 'N')
      AND EXISTS (SELECT 'y'
                        FROM xla_extract_objects_gt a
                       WHERE a.object_name           = e.object_name);

   l_line_number   c_line_number%rowtype;

   -- Get all extract objects for an event class which do not have ledger_id column
   CURSOR c_ledger_id
   IS
   SELECT e.object_name, object_type_code
    FROM xla_extract_objects e, xla_extract_objects_gt og, xla_subledgers app
    WHERE e.application_id   = p_application_id
      AND e.entity_code      = p_entity_code
      AND e.event_class_code = p_event_class_code
     AND e.object_type_code IN ('LINE','LINE_MLS')
      AND e.object_name    = og.object_name
      AND e.application_id = app.application_id
      AND app.alc_enabled_flag  = 'N'
      AND NOT EXISTS (SELECT 'x'
                      FROM dba_tab_columns t
                     WHERE t.table_name  = og.object_name
                        AND og.owner      = t.owner
                       AND t.column_name = 'LEDGER_ID'
                       AND t.data_type   = 'NUMBER')
      AND EXISTS (SELECT 'y'
                        FROM xla_extract_objects_gt a
                       WHERE a.object_name           = e.object_name);

   l_ledger_id   c_ledger_id%rowtype;

BEGIN

   l_application_id          := p_application_id;
   l_entity_code             := p_entity_code;
   l_event_class_code        := p_event_class_code;
   l_amb_context_code        := p_amb_context_code;
   l_product_rule_code       := p_product_rule_code;
   l_product_rule_type_code  := p_product_rule_type_code;

   g_trace_label :='Check_primary_keys_exist';

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_amb_context_code = '||p_amb_context_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_type_code = ' ||p_product_rule_type_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_product_rule_code = ' ||p_product_rule_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   -- Validate for an AAD
   IF p_product_rule_code is not null then

      -- Check if event_id exists with correct data type
      -- for all level extract objects
      OPEN c_aad_event_id;
      LOOP
         FETCH c_aad_event_id
          INTO l_aad_event_id;
         EXIT WHEN c_aad_event_id%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_EVENT_ID_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_aad_event_id.extract_object_name
            ,p_extract_object_type      => l_aad_event_id.extract_object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_aad_event_id;

     -- Check if the LANGUAGE exists with correct data type
     -- for header_mls and line_mls level extract objects

      OPEN c_aad_language;
      LOOP
         FETCH c_aad_language
          INTO l_aad_language;
         EXIT WHEN c_aad_language%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_LANGUAGE_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_aad_language.extract_object_name
            ,p_extract_object_type      => l_aad_language.extract_object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_aad_language;

     -- Check if the LINE_NUMBER exists with correct data type
     -- for Line, line_mls and base_currency level extract objects

      OPEN c_aad_line_number;
      LOOP
         FETCH c_aad_line_number
          INTO l_aad_line_number;
         EXIT WHEN c_aad_line_number%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_LINE_NUM_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_aad_line_number.extract_object_name
            ,p_extract_object_type      => l_aad_line_number.extract_object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_aad_line_number;

     -- Check if the LEDGER_ID exists with correct data type
     -- for base_currency level extract objects

      OPEN c_aad_ledger_id;
      LOOP
         FETCH c_aad_ledger_id
          INTO l_aad_ledger_id;
         EXIT WHEN c_aad_ledger_id%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_LED_ID_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_aad_ledger_id.extract_object_name
            ,p_extract_object_type      => l_aad_ledger_id.extract_object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_aad_ledger_id;

   ELSE
   -- Validate for an event class

      -- Check if event_id exists with correct data type
      -- for all level extract objects
      OPEN c_event_id;
      LOOP
         FETCH c_event_id
          INTO l_event_id;
         EXIT WHEN c_event_id%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_EVENT_ID_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_event_id.object_name
            ,p_extract_object_type      => l_event_id.object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_event_id;

     -- Check if the LANGUAGE exists with correct data type
     -- for header_mls and line_mls level extract objects

      OPEN c_language;
      LOOP
         FETCH c_language
          INTO l_language;
         EXIT WHEN c_language%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_LANGUAGE_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_language.object_name
            ,p_extract_object_type      => l_language.object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_language;

     -- Check if the LINE_NUMBER exists with correct data type
     -- for Line, line_mls and base_currency level extract objects

      OPEN c_line_number;
      LOOP
         FETCH c_line_number
          INTO l_line_number;
         EXIT WHEN c_line_number%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_LINE_NUM_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_line_number.object_name
            ,p_extract_object_type      => l_line_number.object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_line_number;

     -- Check if the LEDGER_ID exists with correct data type
     -- for base_currency level extract objects

      OPEN c_ledger_id;
      LOOP
         FETCH c_ledger_id
          INTO l_ledger_id;
         EXIT WHEN c_ledger_id%NOTFOUND;

         Xla_amb_setup_err_pkg.stack_error
            (p_message_name             => 'XLA_AB_PK_LED_ID_NOT_DEFINED'
            ,p_message_type             => 'E'
            ,p_message_category         => 'EXTRACT_OBJECT'
            ,p_category_sequence        => 3
            ,p_application_id           => l_application_id
            ,p_entity_code              => l_entity_code
            ,p_event_class_code         => l_event_class_code
            ,p_amb_context_code         => l_amb_context_code
            ,p_product_rule_type_code   => l_product_rule_type_code
            ,p_product_rule_code        => l_product_rule_code
            ,p_extract_object_name      => l_ledger_id.object_name
            ,p_extract_object_type      => l_ledger_id.object_type_code);
         l_return := FALSE;

      END LOOP;
      CLOSE c_ledger_id;
   END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.Chk_primary_keys_exist');
END Chk_primary_keys_exist;  -- end of function

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Validate_accounting_sources                                           |
|                                                                       |
| This routine validates the accounting source mappings for an event    |
| class                                                                 |
|                                                                       |
+======================================================================*/

FUNCTION Validate_accounting_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
RETURN BOOLEAN
IS
   -- Variable Declaration

   l_application_id         NUMBER(15);
   l_entity_code            VARCHAR2(30);
   l_event_class_code       VARCHAR2(30);
   l_return                 BOOLEAN            := TRUE;
   l_exist                  VARCHAR2(1)        := NULL;
   l_accounting_attribute_code VARCHAR2(30)    := NULL;

   -- Cursor Declaration

   -- Get all required accounting sources which are not mapped for the event class
   CURSOR c_reqd_sources
   IS
   SELECT accounting_attribute_code
     FROM xla_acct_attributes_b a
    WHERE a.assignment_required_code = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_evt_class_acct_attrs e
                       WHERE e.application_id              = p_application_id
                         AND e.event_class_code            = p_event_class_code
                         AND e.accounting_attribute_code   = a.accounting_attribute_code
                         AND e.default_flag                = 'Y');

   l_reqd_sources   c_reqd_sources%rowtype;

   -- Get all mappings groups that have atleast one accounting source from the
   -- group mapped to the event class
   CURSOR c_mapping_groups
   IS
   SELECT distinct assignment_group_code
     FROM xla_acct_attributes_b a
    WHERE assignment_group_code IS NOT NULL
      AND EXISTS     (SELECT 'x'
                        FROM xla_evt_class_acct_attrs e
                       WHERE e.application_id              = p_application_id
                         AND e.event_class_code            = p_event_class_code
                         AND e.accounting_attribute_code   = a.accounting_attribute_code
                         AND e.default_flag                = 'Y');

   l_mapping_groups   c_mapping_groups%rowtype;

   -- Get all required accounting sources for the above group that are not
   -- mapped to the event class
   CURSOR c_group_sources
   IS
   SELECT accounting_attribute_code
     FROM xla_acct_attributes_b a
    WHERE a.assignment_required_code = 'G'
      AND a.assignment_group_code    = l_mapping_groups.assignment_group_code
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_evt_class_acct_attrs e
                       WHERE e.application_id              = p_application_id
                          AND e.event_class_code           = p_event_class_code
                         AND e.accounting_attribute_code   = a.accounting_attribute_code
                         AND e.default_flag                = 'Y');

   l_group_sources   c_group_sources%rowtype;

   -- Check if event class has budget or encumbrance enabled
   CURSOR c_ec_attrs
   IS
   SELECT allow_budgets_flag, allow_encumbrance_flag
     FROM xla_event_class_attrs e
    WHERE e.application_id              = p_application_id
      AND e.entity_code                 = p_entity_code
      AND e.event_class_code            = p_event_class_code;

   l_ec_attrs   c_ec_attrs%rowtype;

   -- Check if event class has budget version id accounting source mapped
   CURSOR c_budget
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs e
    WHERE e.application_id              = p_application_id
      AND e.event_class_code            = p_event_class_code
      AND e.accounting_attribute_code   = 'BUDGET_VERSION_ID'
      AND e.default_flag                = 'Y';

   -- Check if event class has encumbrance type id accounting source mapped
/* 4458381
   CURSOR c_enc
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs e
    WHERE e.application_id              = p_application_id
      AND e.event_class_code            = p_event_class_code
      AND e.accounting_attribute_code   = 'ENCUMBRANCE_TYPE_ID'
      AND e.default_flag                = 'Y';
*/

   -- Check if reversed distribution id 2 is mapped for the event class
   CURSOR c_rev_dist_2
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code,
          a.source_type_code, a.source_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id               = p_application_id
      AND a.event_class_code             = p_event_class_code
      AND a.accounting_attribute_code    = 'REVERSED_DISTRIBUTION_ID2'
      AND default_flag                   = 'Y';

   l_rev_dist_2    c_rev_dist_2%rowtype;

   -- Check if distribution id 2 is mapped for the event class
   CURSOR c_dist_2
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_2'
      AND default_flag                = 'Y';

   -- Check if reversed distribution id 3 is mapped for the event class
   CURSOR c_rev_dist_3
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'REVERSED_DISTRIBUTION_ID3'
      AND default_flag                = 'Y';

   l_rev_dist_3    c_rev_dist_3%rowtype;

   -- Check if distribution id 3 is mapped for the event class
   CURSOR c_dist_3
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_3'
      AND a.default_flag              = 'Y';

   -- Check if reversed distribution id 4 is mapped for the event class
   CURSOR c_rev_dist_4
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'REVERSED_DISTRIBUTION_ID4'
      AND default_flag                = 'Y';

   l_rev_dist_4    c_rev_dist_4%rowtype;

   -- Check if distribution id 4 is mapped for the event class
   CURSOR c_dist_4
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_4'
      AND default_flag                = 'Y';

   -- Check if reversed distribution id 5 is mapped for the event class
   CURSOR c_rev_dist_5
   IS
   SELECT a.accounting_attribute_code, a.assignment_group_code
     FROM xla_evt_class_acct_attrs_fvl a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'REVERSED_DISTRIBUTION_ID5'
      AND a.default_flag              = 'Y';

   l_rev_dist_5    c_rev_dist_5%rowtype;

   -- Check if distribution id 5 is mapped for the event class
   CURSOR c_dist_5
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs a
    WHERE a.application_id            = p_application_id
      AND a.event_class_code          = p_event_class_code
      AND a.accounting_attribute_code = 'DISTRIBUTION_IDENTIFIER_5'
      AND a.default_flag              = 'Y';

   -- Get all accounting attributes assignments that have sources that are
   -- not mapped to the event class

   CURSOR c_sources
   IS
   SELECT s.accounting_attribute_code,
          s.source_type_code, s.source_code
     FROM xla_evt_class_acct_attrs s
    WHERE s.application_id        = p_application_id
      AND s.event_class_code      = p_event_class_code
      AND s.source_application_id = p_application_id
      AND s.source_type_code      = 'S'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources e
                       WHERE e.application_id             = s.application_id
                         AND e.event_class_code           = s.event_class_code
                         AND e.source_application_id      = s.source_application_id
                         AND e.source_type_code           = s.source_type_code
                         AND e.source_code                = s.source_code
                         AND e.active_flag                = 'Y');

   l_sources    c_sources%rowtype;

   -- Get all accounting attributes assignments that have derived sources that are
   -- not mapped to the event class

   CURSOR c_der_sources
   IS
   SELECT s.accounting_attribute_code, s.source_application_id,
          s.source_type_code, s.source_code
     FROM xla_evt_class_acct_attrs s
    WHERE s.application_id        = p_application_id
      AND s.event_class_code      = p_event_class_code
      AND s.source_application_id = p_application_id
      AND s.source_type_code      = 'D';

   l_der_sources    c_der_sources%rowtype;



BEGIN

   l_application_id         := p_application_id;
   l_entity_code            := p_entity_code;
   l_event_class_code       := p_event_class_code;

   g_trace_label :='Validate_accounting_sources';

  IF (g_log_level is NULL) THEN
      g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  END IF;

  IF (g_log_level is NULL) THEN
      g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
  END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

       -- Check if all required accounting sources are mapped for the event class

       OPEN c_reqd_sources;
       LOOP
          FETCH c_reqd_sources
           INTO l_reqd_sources;
          EXIT WHEN c_reqd_sources%notfound;

            Xla_amb_setup_err_pkg.stack_error
               (p_message_name             => 'XLA_AB_REQD_ACCT_SOURCES'
               ,p_message_type             => 'E'
               ,p_message_category         => 'ACCOUNTING_SOURCE'
               ,p_category_sequence        => 5
               ,p_application_id           => l_application_id
               ,p_entity_code              => l_entity_code
               ,p_event_class_code         => l_event_class_code
               ,p_accounting_source_code   => l_reqd_sources.accounting_attribute_code);

             l_return := FALSE;
         END LOOP;
         CLOSE c_reqd_sources;

       -- Get all mapping groups that have atleast one accounting source
       -- mapped for the event class

       OPEN c_mapping_groups;
       LOOP
          FETCH c_mapping_groups
           INTO l_mapping_groups;
          EXIT WHEN c_mapping_groups%NOTFOUND;

          -- Check if all required sources for the group are mapped for
          -- the event class

          OPEN c_group_sources;
          LOOP
             FETCH c_group_sources
              INTO l_group_sources;
             EXIT WHEN c_group_sources%NOTFOUND;
             Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_REQD_GRP_SOURCES'
                  ,p_message_type             => 'E'
                  ,p_message_category         => 'ACCOUNTING_SOURCE'
                  ,p_category_sequence        => 5
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_accounting_source_code   => l_group_sources.accounting_attribute_code
                  ,p_accounting_group_code    => l_mapping_groups.assignment_group_code);

             l_return := FALSE;
          END LOOP;
          CLOSE c_group_sources;

       END LOOP;
       CLOSE c_mapping_groups;

       -- Get budget and encumbrance flag for the event class

       OPEN c_ec_attrs;
       FETCH c_ec_attrs
        INTO l_ec_attrs;

       IF l_ec_attrs.allow_budgets_flag = 'Y' THEN

          -- Check if Budget Version Identifier is mapped for the
          -- event class
          OPEN c_budget;
          FETCH c_budget
           INTO l_exist;
          IF c_budget%NOTFOUND THEN
             Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_BUDGET_ACCTG_SRC'
                  ,p_message_type             => 'E'
                  ,p_message_category         => 'ACCOUNTING_SOURCE'
                  ,p_category_sequence        => 5
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_accounting_source_code   => 'BUDGET_VERSION_ID');

             l_return := FALSE;
          END IF;
          CLOSE c_budget;
       END IF;

/* 4458381
       IF l_ec_attrs.allow_encumbrance_flag = 'Y' THEN

          -- Check if Encumbrance Type Identifier is mapped for the
          -- event class
          OPEN c_enc;
          FETCH c_enc
           INTO l_exist;
          IF c_enc%NOTFOUND THEN
             Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_ENC_ACCTG_SRC'
                  ,p_message_type             => 'E'
                  ,p_message_category         => 'ACCOUNTING_SOURCE'
                  ,p_category_sequence        => 5
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_accounting_source_code   => 'ENCUMBRANCE_TYPE_ID');

             l_return := FALSE;
          END IF;
          CLOSE c_enc;
       END IF;
       CLOSE c_ec_attrs;
*/

   --
   -- Check if reversed distribution ids are mapped for a line type
   -- then the corresponding distribution ids are also mapped
   --
   OPEN c_rev_dist_2;
   FETCH c_rev_dist_2
    INTO l_rev_dist_2;
   IF c_rev_dist_2%found THEN

         OPEN c_dist_2;
         FETCH c_dist_2
          INTO l_exist;
         IF c_dist_2%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => l_application_id
              ,p_entity_code               => l_entity_code
              ,p_event_class_code          => l_event_class_code
              ,p_accounting_source_code    => l_rev_dist_2.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_2.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_2;
   END IF;
   CLOSE c_rev_dist_2;

   OPEN c_rev_dist_3;
   FETCH c_rev_dist_3
    INTO l_rev_dist_3;
   IF c_rev_dist_3%found THEN

         OPEN c_dist_3;
         FETCH c_dist_3
          INTO l_exist;
         IF c_dist_3%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => l_application_id
              ,p_entity_code               => l_entity_code
              ,p_event_class_code          => l_event_class_code
              ,p_accounting_source_code    => l_rev_dist_3.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_3.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_3;
   END IF;
   CLOSE c_rev_dist_3;

   OPEN c_rev_dist_4;
   FETCH c_rev_dist_4
    INTO l_rev_dist_4;
   IF c_rev_dist_4%found THEN

         OPEN c_dist_4;
         FETCH c_dist_4
          INTO l_exist;
         IF c_dist_4%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => l_application_id
              ,p_entity_code               => l_entity_code
              ,p_event_class_code          => l_event_class_code
              ,p_accounting_source_code    => l_rev_dist_4.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_4.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_4;
   END IF;
   CLOSE c_rev_dist_4;

   OPEN c_rev_dist_5;
   FETCH c_rev_dist_5
    INTO l_rev_dist_5;
   IF c_rev_dist_5%found THEN

         OPEN c_dist_5;
         FETCH c_dist_5
          INTO l_exist;
         IF c_dist_5%notfound THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_ACCT_REV_DIST_ID'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => l_application_id
              ,p_entity_code               => l_entity_code
              ,p_event_class_code          => l_event_class_code
              ,p_accounting_source_code    => l_rev_dist_5.accounting_attribute_code
              ,p_accounting_group_code     => l_rev_dist_5.assignment_group_code);

            l_return := FALSE;
         END IF;
         CLOSE c_dist_5;
   END IF;
   CLOSE c_rev_dist_5;

   -- check accounting attribute assignments that have derived sources
   -- that do not belong to the event class
   OPEN c_sources;
   LOOP
      FETCH c_sources
       INTO l_sources;
      EXIT WHEN c_sources%notfound;

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_ACCT_ATTR_SRCE'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => l_application_id
              ,p_entity_code               => l_entity_code
              ,p_event_class_code          => l_event_class_code
              ,p_accounting_source_code    => l_sources.accounting_attribute_code
              ,p_source_type_code          => l_sources.source_type_code
              ,p_source_code               => l_sources.source_code);

            l_return := FALSE;

   END LOOP;
   CLOSE c_sources;

      -- check accounting attribute assignments that have derived sources
      -- that do not belong to the event class
      OPEN c_der_sources;
      LOOP
         FETCH c_der_sources
          INTO l_der_sources;
         EXIT WHEN c_der_sources%notfound;

         IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => l_application_id
              ,p_derived_source_code      => l_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_entity_code              => p_entity_code
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'L')  = 'TRUE' THEN

            Xla_amb_setup_err_pkg.stack_error
              (p_message_name              => 'XLA_AB_EC_ACCT_ATTR_SRCE'
              ,p_message_type              => 'E'
              ,p_message_category          => 'ACCOUNTING_SOURCE'
              ,p_category_sequence         => 5
              ,p_application_id            => l_application_id
              ,p_entity_code               => p_entity_code
              ,p_event_class_code          => p_event_class_code
              ,p_accounting_source_code    => l_der_sources.accounting_attribute_code
              ,p_source_type_code          => l_der_sources.source_type_code
              ,p_source_code               => l_der_sources.source_code);

           l_return := FALSE;
         END IF;
      END LOOP;
      CLOSE c_der_sources;


   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.validate_accounting_sources');
END Validate_accounting_sources;  -- end of function

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Create_sources                                                        |
|                                                                       |
| This routine creates sources from the extract table definition        |
|                                                                       |
+======================================================================*/
FUNCTION Create_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
RETURN BOOLEAN
IS

   -- Array Declaration
   l_array_source_code             t_array_codes;
   l_array_datatype_code           t_array_type_codes;
   l_array_visible_flag            t_array_type_codes;
   l_array_translated_flag         t_array_type_codes;
   l_array_tl_source_code          t_array_codes;

   l_array_ref_source_appl_id      t_array_id;
   l_array_ref_source_code         t_array_codes;
   l_array_ref_datatype_code       t_array_type_codes;
   l_array_ref_visible_flag        t_array_type_codes;
   l_array_ref_translated_flag     t_array_type_codes;
   l_array_ref_tl_source_appl_id   t_array_id;
   l_array_ref_tl_source_code      t_array_codes;

   -- Variable Declaration

   l_application_id                NUMBER(15);
   l_entity_code                   VARCHAR2(30);
   l_event_class_code              VARCHAR2(30);
   l_return                        BOOLEAN      := TRUE;
   l_language_code                 VARCHAR2(4);
   l_column_name                   VARCHAR2(30);

   dml_errors EXCEPTION;
   PRAGMA exception_init(dml_errors, -24381);


   CURSOR c_languages
   IS
   SELECT language_code
     FROM fnd_languages
    WHERE installed_flag in ('I','B');

   CURSOR c_mls
   IS
   SELECT distinct c.column_name
     FROM dba_tab_columns c, xla_extract_objects e, xla_extract_objects_gt og
    WHERE c.table_name       = e.object_name
      AND e.object_name      = og.object_name
      AND og.owner           = c.owner
      AND e.application_id   = p_application_id
      AND e.entity_code      = p_entity_code
      AND e.event_class_code = p_event_class_code
      AND e.object_type_code IN ('HEADER_MLS','LINE_MLS')
      AND c.data_type        IN ('NUMBER','DATE')
      AND c.column_name      NOT IN ('EVENT_ID','LINE_NUMBER','LEDGER_ID');


   CURSOR c_sources
   IS
   SELECT distinct(c.column_name) source_code
         ,decode(c.data_type,'VARCHAR2','C','CHAR','C','NUMBER','N','DATE','D','C')  data_type_code
         ,decode(c.column_name,'EVENT_ID','N','LINE_NUMBER','N','LEDGER_ID','N','LANGUAGE','N','Y') visible_flag
       ,CASE e.object_type_code
             WHEN 'HEADER' THEN 'N'
             WHEN 'LINE'   THEN 'N'
             ELSE decode(c.data_type,'NUMBER','N','DATE','N', decode(c.column_name,'LANGUAGE','N','Y'))
           END           translated_flag
    FROM dba_tab_columns c, xla_extract_objects e, xla_extract_objects_gt og
   WHERE c.table_name       = e.object_name
     AND e.object_name      = og.object_name
     AND og.owner           = c.owner
     --
     --  Bug 5120836
     --  Do not create the LANGUAGE column from non-MLS objects
     --
     AND DECODE(e.object_type_code
               ,'HEADER_MLS'
               ,'MLS_COLUMNS'
               ,'LINE_MLS'
               ,'MLS_COLUMNS'
               ,c.column_name) <> 'LANGUAGE'
     AND e.application_id   = p_application_id
     AND e.entity_code      = p_entity_code
     AND e.event_class_code = p_event_class_code
     AND NOT EXISTS (SELECT 'x'
                       FROM xla_sources_b s
                      WHERE s.application_id    = e.application_id
                        AND s.source_type_code  = 'S'
                        AND s.source_code       = c.column_name);

   CURSOR c_ref_sources
   IS
   SELECT DISTINCT r.reference_object_appl_id
         , c.column_name source_code
         ,decode(c.data_type,'VARCHAR2','C','CHAR','C','NUMBER','N','DATE','D','C')  data_type_code
         ,decode(c.column_name,'EVENT_ID','N','LINE_NUMBER','N','LEDGER_ID','N','LANGUAGE','N','Y') visible_flag
       ,CASE e.object_type_code
             WHEN 'HEADER' THEN 'N'
             WHEN 'LINE'   THEN 'N'
             ELSE decode(c.data_type,'NUMBER','N','DATE','N', decode(c.column_name,'LANGUAGE','N','Y'))
           END           translated_flag
    FROM dba_tab_columns c, xla_reference_objects r,
         xla_reference_objects_gt og, xla_extract_objects e
   WHERE c.table_name                 = r.reference_object_name
     AND r.reference_object_name      = og.reference_object_name
     AND og.owner                     = c.owner
     AND r.application_id             = p_application_id
     AND r.entity_code                = p_entity_code
     AND r.event_class_code = p_event_class_code
     AND e.application_id   = p_application_id
     AND e.entity_code      = p_entity_code
     AND e.event_class_code = p_event_class_code
     AND e.object_name      = r.object_name
     --
     --  Bug 5120836
     --  Do not create the LANGUAGE column from non-MLS objects
     --
     AND DECODE(e.object_type_code
               ,'HEADER_MLS'
               ,'MLS_COLUMNS'
               ,'LINE_MLS'
               ,'MLS_COLUMNS'
               ,c.column_name) <> 'LANGUAGE'
     AND NOT EXISTS (SELECT 'x'
                       FROM xla_sources_b s
                      WHERE s.application_id    = r.reference_object_appl_id
                        AND s.source_type_code  = 'S'
                        AND s.source_code       = c.column_name);


   CURSOR c_tl_sources
   IS
   SELECT distinct source_code
    FROM xla_sources_b e
   WHERE e.application_id   = p_application_id
     AND NOT EXISTS (SELECT 'x'
                       FROM xla_sources_vl s
                      WHERE s.application_id    = e.application_id
                        AND s.source_type_code  = e.source_type_code
                        AND s.source_code       = e.source_code);

   CURSOR c_ref_tl_sources
   IS
   SELECT distinct reference_object_appl_id, source_code
    FROM xla_sources_b e, xla_reference_objects r
   WHERE e.application_id   = r.reference_object_appl_id
     AND r.application_id   = p_application_id
     AND NOT EXISTS (SELECT 'x'
                       FROM xla_sources_vl s
                      WHERE s.application_id    = r.reference_object_appl_id
                        AND s.source_type_code  = e.source_type_code
                        AND s.source_code       = e.source_code);

BEGIN

   l_application_id                := p_application_id;
   l_entity_code                   := p_entity_code;
   l_event_class_code              := p_event_class_code;

   g_trace_label :='Create_sources';

   IF (g_creation_date is NULL) THEN
      g_creation_date := sysdate;
   END IF;

   IF (g_last_update_date is NULL) THEN
      g_last_update_date := sysdate;
   END IF;

   IF (g_created_by is NULL) THEN
      g_created_by := xla_environment_pkg.g_usr_id;
   END IF;

   IF (g_last_update_login is NULL) THEN
      g_last_update_login := xla_environment_pkg.g_login_id;
   END IF;

   IF (g_last_updated_by is NULL) THEN
      g_last_updated_by := xla_environment_pkg.g_usr_id;
   END IF;

   IF (g_log_level is NULL) THEN
       g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   END IF;

   IF (g_log_level is NULL) THEN
       g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
   END IF;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   -- Error the columns that are not varchar2 and exist in MLS tables
   OPEN c_mls;
   LOOP
     FETCH c_mls
      INTO l_column_name;
     EXIT WHEN c_mls%notfound;

        Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_NUMBER_COL_IN_MLS'
                  ,p_message_type             => 'W'
                  ,p_message_category         => 'CREATE_SOURCE'
                  ,p_category_sequence        => 15
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_extract_column_name      => l_column_name);
        l_return := FALSE;

   END LOOP;
   CLOSE c_mls;

   OPEN c_sources;
   FETCH c_sources
   BULK COLLECT INTO l_array_source_code, l_array_datatype_code, l_array_visible_flag, l_array_translated_flag;

   -- Create sources in source_b table for all extract objects
   IF l_array_source_code.COUNT > 0 THEN
     BEGIN
      FORALL i IN l_array_source_code.FIRST..l_array_source_code.LAST SAVE EXCEPTIONS
        INSERT INTO xla_sources_b
         (source_code
         ,application_id
         ,source_type_code
         ,datatype_code
         ,sum_flag
         ,visible_flag
         ,enabled_flag
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,translated_flag
         ,key_flexfield_flag)
        VALUES
         (l_array_source_code(i)
         ,p_application_id
         ,'S'
         ,l_array_datatype_code(i)
         ,'N'
         ,l_array_visible_flag(i)
         ,'Y'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
         ,l_array_translated_flag(i)
         ,'N');

      EXCEPTION
        WHEN dml_errors THEN

             FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
               Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_SAME_COL_DIFF_DATATYPE'
                  ,p_message_type             => 'W'
                  ,p_message_category         => 'CREATE_SOURCE'
                  ,p_category_sequence        => 15
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_extract_column_name      => l_array_source_code(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX));
             END LOOP;

             l_return := FALSE;

      END;
   END IF;
   CLOSE c_sources;

   OPEN c_ref_sources;
   FETCH c_ref_sources
   BULK COLLECT INTO l_array_ref_source_appl_id,
                     l_array_ref_source_code, l_array_ref_datatype_code,
                     l_array_ref_visible_flag, l_array_ref_translated_flag;

   -- Create sources in source_b table for all reference objects
   IF l_array_ref_source_code.COUNT > 0 THEN
     BEGIN
      FORALL i IN l_array_ref_source_code.FIRST..l_array_ref_source_code.LAST SAVE EXCEPTIONS
        INSERT INTO xla_sources_b
         (source_code
         ,application_id
         ,source_type_code
         ,datatype_code
         ,sum_flag
         ,visible_flag
         ,enabled_flag
         ,key_flexfield_flag
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,translated_flag)
        VALUES
         (l_array_ref_source_code(i)
         ,l_array_ref_source_appl_id(i)
         ,'S'
         ,l_array_ref_datatype_code(i)
         ,'N'
         ,l_array_ref_visible_flag(i)
         ,'Y'
         ,'N'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
         ,l_array_ref_translated_flag(i));


      EXCEPTION
        WHEN dml_errors THEN
             FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
               Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_SAME_COL_DIFF_DATATYPE'
                  ,p_message_type             => 'W'
                  ,p_message_category         => 'CREATE_SOURCE'
                  ,p_category_sequence        => 15
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_extract_column_name      => l_array_ref_source_code(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX));
             END LOOP;

             l_return := FALSE;

      END;
   END IF;
   CLOSE c_ref_sources;

   -- Get all sources that exist in xla_sources_b but not in xla_sources_tl
   OPEN c_tl_sources;
   FETCH c_tl_sources
   BULK COLLECT INTO l_array_tl_source_code;

   IF l_array_tl_source_code.COUNT > 0 THEN
    -- Insert into sources_tl for all languages installed with same code and name

     OPEN c_languages;
     LOOP
     FETCH c_languages
      INTO l_language_code;
     EXIT WHEN c_languages%notfound;

       BEGIN
         FORALL i IN l_array_tl_source_code.FIRST..l_array_tl_source_code.LAST SAVE EXCEPTIONS
          INSERT INTO xla_sources_tl
           (source_code
           ,application_id
           ,source_type_code
           ,name
           ,language
           ,source_lang
           ,creation_date
           ,created_by
           ,last_updated_by
           ,last_update_date
           ,last_update_login)
          VALUES
           (l_array_tl_source_code(i)
           ,p_application_id
           ,'S'
           ,l_array_tl_source_code(i)
           ,l_language_code
           ,USERENV('LANG')
           ,g_creation_date
           ,g_created_by
           ,g_last_updated_by
           ,g_last_update_date
           ,g_last_update_login);

         EXCEPTION
           WHEN dml_errors THEN

             FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
               Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_SAME_NAME_DIFF_CODE'
                  ,p_message_type             => 'E'
                  ,p_message_category         => 'CREATE_SOURCE'
                  ,p_category_sequence        => 15
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_extract_column_name      => l_array_tl_source_code(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX)
                  ,p_language                 => l_language_code);
             END LOOP;

             l_return := FALSE;
         END;
       END LOOP;
       CLOSE c_languages;
     END IF;
     CLOSE c_tl_sources;

   -- Get all sources that exist in xla_sources_b but not in xla_sources_tl
   OPEN c_ref_tl_sources;
   FETCH c_ref_tl_sources
   BULK COLLECT INTO l_array_ref_tl_source_appl_id, l_array_ref_tl_source_code;

   IF l_array_ref_tl_source_code.COUNT > 0 THEN
    -- Insert into sources_tl for all languages installed with same code and name

      OPEN c_languages;
      LOOP
      FETCH c_languages
       INTO l_language_code;
      EXIT WHEN c_languages%notfound;

      BEGIN
         FORALL i IN l_array_ref_tl_source_code.FIRST..l_array_ref_tl_source_code.LAST SAVE EXCEPTIONS
          INSERT INTO xla_sources_tl
           (source_code
           ,application_id
           ,source_type_code
           ,name
           ,language
           ,source_lang
           ,creation_date
           ,created_by
           ,last_updated_by
           ,last_update_date
           ,last_update_login)
          VALUES
           (l_array_ref_tl_source_code(i)
           ,l_array_ref_tl_source_appl_id(i)
           ,'S'
           ,l_array_ref_tl_source_code(i)
           ,l_language_code
           ,USERENV('LANG')
           ,g_creation_date
           ,g_created_by
           ,g_last_updated_by
           ,g_last_update_date
           ,g_last_update_login);

         EXCEPTION
           WHEN dml_errors THEN

             FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
               Xla_amb_setup_err_pkg.stack_error
                  (p_message_name             => 'XLA_AB_SAME_NAME_DIFF_CODE'
                  ,p_message_type             => 'E'
                  ,p_message_category         => 'CREATE_SOURCE'
                  ,p_category_sequence        => 15
                  ,p_application_id           => l_application_id
                  ,p_entity_code              => l_entity_code
                  ,p_event_class_code         => l_event_class_code
                  ,p_extract_column_name      => l_array_ref_tl_source_code(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX)
                  ,p_language                 => l_language_code);
             END LOOP;

             l_return := FALSE;
      END;
      END LOOP;
      CLOSE c_languages;
   END IF;
   CLOSE c_ref_tl_sources;

   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.Create_sources');
END Create_sources;  -- end of procedure

/*======================================================================+
|                                                                       |
| Private Procedure                                                     |
|                                                                       |
| Assign_Sources                                                        |
|                                                                       |
| This routine assigns sources from the extract table definition to the |
| event class based on extract object level                             |
|                                                                       |
+======================================================================*/
PROCEDURE Assign_sources
          (p_application_id              IN  NUMBER
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2)
IS

BEGIN
   g_trace_label :='Assign_sources';

   IF (g_creation_date is NULL) THEN
      g_creation_date := sysdate;
   END IF;

   IF (g_last_update_date is NULL) THEN
      g_last_update_date := sysdate;
   END IF;

   IF (g_created_by is NULL) THEN
      g_created_by := xla_environment_pkg.g_usr_id;
   END IF;

   IF (g_last_update_login is NULL) THEN
      g_last_update_login := xla_environment_pkg.g_login_id;
   END IF;

   IF (g_last_updated_by is NULL) THEN
      g_last_updated_by := xla_environment_pkg.g_usr_id;
   END IF;

   IF (g_log_level is NULL) THEN
       g_log_level :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   END IF;

   IF (g_log_level is NULL) THEN
       g_log_enabled :=  fnd_log.test
                      (log_level  => g_log_level
             ,module     => C_DEFAULT_MODULE);
   END IF;


   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
     trace
      (p_msg      => 'Begin'
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_application_id = '  ||TO_CHAR(p_application_id)
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_entity_code = '||p_entity_code
      ,p_level    => C_LEVEL_PROCEDURE);
     trace
      (p_msg      => 'p_event_class_code = ' ||p_event_class_code
      ,p_level    => C_LEVEL_PROCEDURE);
   END IF;
    -- Sources are assigned at the highest level they are
    -- available in an always populated extract object

   -- Assign sources at header level to the event class
    -- for header extract objects that are always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,p_application_id
         ,'S'
         ,'Y'
         ,'H'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_extract_objects e, xla_extract_objects_gt og
    WHERE c.table_name            = e.object_name
      AND og.object_name          = e.object_name
      AND og.owner                = c.owner
      AND e.object_type_code     IN ('HEADER','HEADER_MLS')
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code
      AND e.always_populated_flag = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = p_application_id
                         AND s.source_code           = c.column_name));

     -- Assign sources at header level to the event class
    -- for header reference objects that are always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,r.reference_object_appl_id
         ,'S'
         ,'Y'
         ,'H'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_reference_objects r,
          xla_reference_objects_gt og, xla_extract_objects e
    WHERE c.table_name            = r.reference_object_name
      AND og.reference_object_name          = r.reference_object_name
      AND og.owner                = c.owner
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code
      AND e.object_name           = r.object_name
      AND e.object_type_code     IN ('HEADER','HEADER_MLS')
      AND r.application_id        = p_application_id
      AND r.entity_code           = p_entity_code
      AND r.event_class_code      = p_event_class_code
      AND r.always_populated_flag = 'Y'
            AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = r.reference_object_appl_id
                         AND s.source_code           = c.column_name));

     -- Assign sources at line level to the event class
    -- for line extract objects that are always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,p_application_id
         ,'S'
         ,'Y'
         ,'L'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_extract_objects e, xla_extract_objects_gt og
    WHERE c.table_name            = e.object_name
      AND og.object_name          = e.object_name
      AND og.owner                = c.owner
      AND e.object_type_code      IN ('LINE','LINE_MLS')
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code
      AND e.always_populated_flag = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = p_application_id
                         AND s.source_code           = c.column_name));

     -- Assign sources at line level to the event class
    -- for line reference objects that are always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,r.reference_object_appl_id
         ,'S'
         ,'Y'
         ,'L'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_reference_objects r,
          xla_reference_objects_gt og, xla_extract_objects e
    WHERE c.table_name            = r.reference_object_name
      AND og.reference_object_name          = r.reference_object_name
      AND og.owner                = c.owner
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code
      AND e.object_name           = r.object_name
      AND e.object_type_code      IN ('LINE','LINE_MLS')
      AND r.application_id        = p_application_id
      AND r.entity_code           = p_entity_code
      AND r.event_class_code      = p_event_class_code
      AND r.always_populated_flag = 'Y'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = r.reference_object_appl_id
                         AND s.source_code           = c.column_name));

     -- Assign sources at header level to the event class
    -- for header extract objects that are not always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,p_application_id
         ,'S'
         ,'Y'
         ,'H'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_extract_objects e, xla_extract_objects_gt og
    WHERE c.table_name            = e.object_name
      AND og.object_name          = e.object_name
      AND og.owner                = c.owner
      AND e.object_type_code     IN ('HEADER','HEADER_MLS')
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code
      AND e.always_populated_flag = 'N'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = p_application_id
                         AND s.source_code           = c.column_name));

    -- Assign sources at header level to the event class
    -- for header reference objects that are not always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,r.reference_object_appl_id
         ,'S'
         ,'Y'
         ,'H'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_reference_objects r,
          xla_reference_objects_gt og, xla_extract_objects e
    WHERE c.table_name            = r.reference_object_name
      AND og.reference_object_name          = r.reference_object_name
      AND og.owner                = c.owner
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code
      AND e.object_name           = r.object_name
      AND e.object_type_code     IN ('HEADER','HEADER_MLS')
      AND r.application_id        = p_application_id
      AND r.entity_code           = p_entity_code
      AND r.event_class_code      = p_event_class_code
      AND r.always_populated_flag = 'N'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = r.reference_object_appl_id
                         AND s.source_code           = c.column_name));

      -- Assign sources at line level to the event class
    -- for line extract objects that are not always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,p_application_id
         ,'S'
         ,'Y'
         ,'L'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_extract_objects e, xla_extract_objects_gt og
    WHERE c.table_name            = e.object_name
      AND og.object_name          = e.object_name
      AND og.owner                = c.owner
      AND e.object_type_code      IN ('LINE','LINE_MLS')
      AND e.application_id        = p_application_id
      AND e.entity_code           = p_entity_code
      AND e.event_class_code      = p_event_class_code
      AND e.always_populated_flag = 'N'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = p_application_id
                         AND s.source_code           = c.column_name));

     -- Assign sources at line level to the event class
    -- for line extract objects that are not always populated
    INSERT INTO xla_event_sources
         (source_code
         ,application_id
         ,entity_code
         ,event_class_code
         ,source_application_id
         ,source_type_code
         ,active_flag
         ,level_code
         ,creation_date
         ,created_by
         ,last_updated_by
         ,last_update_date
         ,last_update_login)
    (SELECT distinct (c.column_name)
         ,p_application_id
         ,p_entity_code
         ,p_event_class_code
         ,r.reference_object_appl_id
         ,'S'
         ,'Y'
         ,'L'
         ,g_creation_date
         ,g_created_by
         ,g_last_updated_by
         ,g_last_update_date
         ,g_last_update_login
     FROM dba_tab_columns c, xla_reference_objects r,
          xla_reference_objects_gt og, xla_extract_objects e
    WHERE c.table_name              = r.reference_object_name
      AND og.reference_object_name  = r.reference_object_name
      AND og.owner                  = c.owner
      AND e.application_id          = p_application_id
      AND e.entity_code             = p_entity_code
      AND e.event_class_code        = p_event_class_code
      AND e.object_name             = r.object_name
      AND e.object_type_code        IN ('LINE','LINE_MLS')
      AND r.application_id          = p_application_id
      AND r.entity_code             = p_entity_code
      AND r.event_class_code        = p_event_class_code
      AND r.always_populated_flag   = 'N'
      AND NOT EXISTS (SELECT 'x'
                        FROM xla_event_sources s
                       WHERE s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.source_application_id = r.reference_object_appl_id
                         AND s.source_code           = c.column_name));


   IF ((g_log_enabled = TRUE) AND (C_LEVEL_PROCEDURE >= g_log_level)) THEN
      trace
       (p_msg      => 'End'
       ,p_level    => C_LEVEL_PROCEDURE);
   END IF;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS THEN
   xla_exceptions_pkg.raise_message
       (p_location       => 'xla_extract_integrity_pkg.Assign_sources');
END Assign_sources;  -- end of procedure

END xla_extract_integrity_pkg;

/
