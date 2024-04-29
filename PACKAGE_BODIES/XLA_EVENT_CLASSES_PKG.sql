--------------------------------------------------------
--  DDL for Package Body XLA_EVENT_CLASSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVENT_CLASSES_PKG" AS
/* $Header: xlaamdec.pkb 120.9 2005/05/24 12:19:21 ksvenkat ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_classes_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event Classes Package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| class_details_exist                                                   |
|                                                                       |
| Returns true if details of the class exist                            |
|                                                                       |
+======================================================================*/
FUNCTION class_details_exist
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
RETURN BOOLEAN
IS

   --
   -- Private variables
   --
   l_exist  varchar2(1);
   l_return BOOLEAN;

   --
   -- Cursor declarations
   --
   CURSOR check_event_types
   IS
   SELECT 'x'
     FROM xla_event_types_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND event_type_code  <> p_event_class_code||'_ALL';

   CURSOR check_enabled_event_types
   IS
   SELECT 'x'
     FROM xla_event_types_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND event_type_code  <> p_event_class_code||'_ALL'
      AND enabled_flag     = 'Y';

   CURSOR check_line_types
   IS
   SELECT 'x'
     FROM xla_acct_line_types_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

   CURSOR check_enabled_line_types
   IS
   SELECT 'x'
     FROM xla_acct_line_types_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND enabled_flag     = 'Y';

   CURSOR check_analytical
   IS
   SELECT 'x'
     FROM xla_analytical_sources
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

   CURSOR check_prod_rules
   IS
   SELECT 'x'
     FROM xla_prod_acct_headers
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

BEGIN
   xla_utility_pkg.trace('> xla_event_classes_pkg.class_details_exist'                       , 10);

   xla_utility_pkg.trace('event               = '||p_event, 20);
   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_entity_code     , 20);
   xla_utility_pkg.trace('entity_code         = '||p_event_class_code     , 20);

   IF p_event = 'DELETE' THEN

      OPEN check_event_types;
      FETCH check_event_types
       INTO l_exist;
      IF check_event_types%found THEN
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE check_event_types;

      IF l_return = FALSE THEN
         OPEN check_line_types;
         FETCH check_line_types
          INTO l_exist;
         IF check_line_types%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_line_types;
      END IF;

      IF l_return = FALSE THEN
         OPEN check_prod_rules;
         FETCH check_prod_rules
          INTO l_exist;
         IF check_prod_rules%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_prod_rules;
      END IF;

      IF l_return = FALSE THEN
         OPEN check_analytical;
         FETCH check_analytical
          INTO l_exist;
         IF check_analytical%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_analytical;
      END IF;

   ELSIF p_event = 'DISABLE' THEN

      OPEN check_enabled_event_types;
      FETCH check_enabled_event_types
       INTO l_exist;
      IF check_enabled_event_types%found THEN
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE check_enabled_event_types;

      IF l_return = FALSE THEN
         OPEN check_enabled_line_types;
         FETCH check_enabled_line_types
          INTO l_exist;
         IF check_enabled_line_types%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_enabled_line_types;
      END IF;

      IF l_return = FALSE THEN
         OPEN check_prod_rules;
         FETCH check_prod_rules
          INTO l_exist;
         IF check_prod_rules%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_prod_rules;
      END IF;

      IF l_return = FALSE THEN
         OPEN check_analytical;
         FETCH check_analytical
          INTO l_exist;
         IF check_analytical%found THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE check_analytical;
      END IF;

   END IF;

   xla_utility_pkg.trace('< xla_event_classes_pkg.class_details_exist'                       , 10);
   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_event_classes_pkg.class_details_exist');

END class_details_exist;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_class_details                                                  |
|                                                                       |
| Deletes all details of the class                                      |
|                                                                       |
+======================================================================*/

PROCEDURE delete_class_details
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
IS

   l_event_mapping_id   integer;
   l_application_id     integer;
   l_event_class_code   varchar2(30);

   CURSOR c_event_mappings
   IS
   SELECT event_mapping_id
     FROM xla_event_mappings_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;
BEGIN

   xla_utility_pkg.trace('> xla_event_classes_pkg.delete_class_details'                    , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code    = '||p_event_class_code     , 20);

   l_application_id	:= p_application_id;
   l_event_class_code	:= p_event_class_code;

   DELETE
     FROM xla_event_sources
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

   DELETE
     FROM xla_extract_objects
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

   DELETE
     FROM xla_event_class_predecs
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code;

   OPEN c_event_mappings;
   LOOP
   FETCH c_event_mappings
    INTO l_event_mapping_id;
   EXIT WHEN c_event_mappings%notfound;

      xla_event_mappings_f_pkg.delete_row
        (x_event_mapping_id   => l_event_mapping_id);

   END LOOP;
   CLOSE c_event_mappings;

   xla_acct_setup_pkg.delete_event_class_setup
     (p_application_id             => l_application_id
     ,p_event_class_code           => l_event_class_code);

   DELETE
     FROM xla_event_class_attrs
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code;

     xla_event_types_f_pkg.delete_row
       (x_application_id                   => p_application_id
       ,x_entity_code                      => p_entity_code
       ,x_event_class_code                 => p_event_class_code
       ,x_event_type_code                  => p_event_class_code||'_ALL');

   xla_utility_pkg.trace('< xla_event_classes_pkg.delete_class_details'                    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_event_classes_pkg.delete_class_details');

END delete_class_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| create_default_event_type                                             |
|                                                                       |
| Creates a default event type for the class                            |
|                                                                       |
+======================================================================*/

PROCEDURE create_default_event_type
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
IS

BEGIN

   xla_utility_pkg.trace('> xla_event_classes_pkg.create_default_event_type'                 , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_entity_code     , 20);

   xla_utility_pkg.trace('< xla_event_classes_pkg.create_default_event_type'                , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_event_classes_pkg.create_default_event_type');

END create_default_event_type;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if all the application accounting definitions and        |
| journal line definitions using this segment rule are uncompiled       |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                  IN  NUMBER
  ,p_event_class_code                IN  VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     varchar2(240) := null;
   l_product_rule_name    varchar2(80)  := null;
   l_product_rule_type    varchar2(80)  := null;
   l_event_class_name     varchar2(80)  := null;
   l_event_type_name      varchar2(80)  := null;
   l_locking_status_flag  varchar2(1)   := null;

   -- Retrive any event class/type assignment of an AAD that is either
   -- being locked or validating
   CURSOR c_locked_aads IS
    SELECT xpa.entity_code, xpa.event_class_code, xpa.event_type_code,
           xpa.product_rule_type_code, xpa.product_rule_code,
           xpa.amb_context_code, xpa.locking_status_flag
      FROM xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = p_application_id
       AND xpa.event_class_code           = p_event_class_code
       AND (xpa.validation_status_code    NOT IN ('E', 'Y', 'N') OR
            xpa.locking_status_flag       = 'Y');

   l_locked_aad   c_locked_aads%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_event_classes_pkg.uncompile_definitions'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code    = '||p_event_class_code     , 20);

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
         AND xld.event_class_code       = p_event_class_code
         AND xld.validation_status_code <> 'N';

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.application_id         = p_application_id
         AND xpa.event_class_code       = p_event_class_code
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
                 AND xpa.event_class_code       = p_event_class_code);

      l_return := TRUE;
   END IF;
   CLOSE c_locked_aads;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_event_classes_pkg.uncompile_definitions'    , 10);

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
        (p_location   => 'xla_event_classes_pkg.uncompile_definitions');

END uncompile_definitions;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| event_class_is_locked                                                 |
|                                                                       |
| Returns true if the line type is used by a frozen line definition     |
|                                                                       |
+======================================================================*/

FUNCTION event_class_is_locked
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN;
   l_exist    VARCHAR2(1);

   CURSOR c_frozen_assignment_exist
   IS
   SELECT 'x'
     FROM xla_prod_acct_headers s
    WHERE application_id            = p_application_id
      AND event_class_code          = p_event_class_code
      AND locking_status_flag       = 'Y';
BEGIN

   xla_utility_pkg.trace('> xla_event_classes_pkg.event_class_is_locked'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);

      OPEN c_frozen_assignment_exist;
      FETCH c_frozen_assignment_exist
       INTO l_exist;
      IF c_frozen_assignment_exist%found then
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_frozen_assignment_exist;

   xla_utility_pkg.trace('< xla_event_classes_pkg.event_class_is_locked'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_frozen_assignment_exist%ISOPEN THEN
         CLOSE c_frozen_assignment_exist;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_frozen_assignment_exist%ISOPEN THEN
         CLOSE c_frozen_assignment_exist;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_event_classes_pkg.event_class_is_locked');

END event_class_is_locked;


END xla_event_classes_pkg;

/
