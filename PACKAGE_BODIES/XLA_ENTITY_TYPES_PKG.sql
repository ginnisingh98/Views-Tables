--------------------------------------------------------
--  DDL for Package Body XLA_ENTITY_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_ENTITY_TYPES_PKG" AS
/* $Header: xlaamdee.pkb 120.4 2004/11/20 01:10:35 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_entity_types_pkg                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Entity Types Package                                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| event_classes_exist                                                   |
|                                                                       |
| Returns true if the source is being used                              |
|                                                                       |
+======================================================================*/
FUNCTION event_classes_exist
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2)
RETURN BOOLEAN

IS

   --
   -- Private variables
   --
   l_count NUMBER(30) := 0;

   --
   -- Cursor declarations
   --
   CURSOR check_event_classes
   IS
   SELECT count(1)
     FROM xla_event_classes_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code;

   CURSOR check_enabled_event_classes
   IS
   SELECT count(1)
     FROM xla_event_classes_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND enabled_flag     = 'Y';

BEGIN
   xla_utility_pkg.trace('> xla_entity_types_pkg.event_classes_exist'                       , 10);

   xla_utility_pkg.trace('event               = '||p_event, 20);
   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_entity_code     , 20);

   IF p_event = 'DELETE' THEN

      OPEN check_event_classes;
      FETCH check_event_classes
       INTO l_count;
      CLOSE check_event_classes;

      IF l_count > 0 THEN
         RETURN TRUE;
      END IF;

   ELSIF p_event = 'DISABLE' THEN

      OPEN check_enabled_event_classes;
      FETCH check_enabled_event_classes
       INTO l_count;
      CLOSE check_enabled_event_classes;

      IF l_count > 0 THEN
         RETURN TRUE;
      END IF;

   END IF;

   xla_utility_pkg.trace('< xla_entity_types_pkg.event_classes_exist'                       , 10);
   RETURN FALSE;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_entity_types_pkg.event_classes_exist');

END event_classes_exist;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_entity_details                                                 |
|                                                                       |
| Deletes all details of the entity                                     |
|                                                                       |
+======================================================================*/

PROCEDURE delete_entity_details
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2)
IS

BEGIN

   xla_utility_pkg.trace('> xla_entity_types_pkg.delete_entity_details'        , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_entity_code     , 20);

   DELETE
     FROM xla_entity_id_mappings
    WHERE application_id = p_application_id
      AND entity_code    = p_entity_code;

   xla_utility_pkg.trace('< xla_entity_types_pkg.delete_entity_details'        , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_entity_types_pkg.delete_entity_details');

END delete_entity_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if all the product rules for the entity are uncompiled   |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                  IN NUMBER
  ,p_entity_code                     IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name    varchar2(240) := null;
   l_product_rule_name    varchar2(80) := null;
   l_product_rule_type    varchar2(80) := null;
   l_event_class_name     varchar2(80)  := null;
   l_event_type_name      varchar2(80)  := null;
   l_locking_status_flag  varchar2(1)   := null;

   -- Retrive any event class/type assignment of an AAD that is either
   -- being locked or validating
   CURSOR c_locked_aads IS
    SELECT xpa.entity_code, xpa.event_class_code, xpa.event_type_code,
           xpa.product_rule_type_code, xpa.product_rule_code,
           xpa.amb_context_code, xpa.locking_status_flag
      FROM xla_prod_acct_headers          xpa
     WHERE xpa.application_id             = p_application_id
       AND xpa.entity_code                = p_entity_code
       AND (xpa.validation_status_code    NOT IN ('E', 'Y', 'N') OR
            xpa.locking_status_flag       = 'Y');

   l_locked_aad   c_locked_aads%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_entity_types_pkg.uncompile_definitions'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code    = '||p_entity_code     , 20);

   OPEN c_locked_aads;
   FETCH c_locked_aads INTO l_locked_aad;
   IF (c_locked_aads%FOUND) THEN

      xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => l_locked_aad.amb_context_code
           ,p_product_rule_type_code  => l_locked_aad.product_rule_type_code
           ,p_product_rule_code       => l_locked_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

      xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_locked_aad.entity_code
           ,p_event_class_code        => l_locked_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

      xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_locked_aad.entity_code
           ,p_event_class_code        => l_locked_aad.event_class_code
           ,p_event_type_code         => l_locked_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

      l_locking_status_flag := l_locked_aad.locking_status_flag;

      l_return := FALSE;
   ELSE

      UPDATE xla_line_definitions_b     xld
         SET validation_status_code     = 'N'
       WHERE xld.application_id         = p_application_id
         AND xld.event_class_code       IN (SELECT event_class_code
                                              FROM xla_event_classes_b
                                             WHERE entity_code = p_entity_code)
         AND xld.validation_status_code <> 'N';

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.application_id         = p_application_id
         AND xpa.entity_code            = p_entity_code
         AND xpa.validation_status_code <> 'N';

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.application_id         = p_application_id
         AND xpr.compile_status_code    <> 'N'
         AND (xpr.amb_context_code
             ,xpr.product_rule_type_code
             ,xpr.product_rule_code)    IN
             (SELECT xpa.amb_context_code
                    ,xpa.product_rule_type_code
                    ,xpa.product_rule_code
                FROM xla_prod_acct_headers  xpa
               WHERE xpa.application_id         = p_application_id
                 AND xpa.entity_code            = p_entity_code);

      l_return := TRUE;
   END IF;
   CLOSE c_locked_aads;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_entity_types_pkg.uncompile_definitions'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_locked_aads%ISOPEN THEN
         CLOSE c_locked_aads;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_locked_aads%ISOPEN THEN
         CLOSE c_locked_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_entity_types_pkg.uncompile_definitions');

END uncompile_definitions ;

END xla_entity_types_pkg;

/
