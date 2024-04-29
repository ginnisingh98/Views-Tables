--------------------------------------------------------
--  DDL for Package Body XLA_EVENT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_EVENT_TYPES_PKG" AS
/* $Header: xlaamdet.pkb 120.5 2005/06/23 20:15:17 ksvenkat ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_event_types_pkg                                                |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Event Types Package                                            |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    11-Nov-04 Wynne Chan     Changed for AAD Enhancements - JLD        |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| type_details_exist                                                    |
|                                                                       |
| Returns true if details of the class exist                            |
|                                                                       |
+======================================================================*/
FUNCTION type_details_exist
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2
  ,p_accounting_flag                  IN VARCHAR2
  ,p_tax_flag                         IN VARCHAR2
  ,p_message                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   --
   -- Private variables
   --
   l_count  NUMBER(10) := 0;
   l_exist  varchar2(1);
   l_return BOOLEAN := FALSE;

   l_application_id     NUMBER(38) := p_application_id;
   l_entity_code        VARCHAR2(30) := p_entity_code;
   l_event_class_code   VARCHAR2(30) := p_event_class_code;
   l_event_type_code    VARCHAR2(30) := p_event_type_code;
   l_message            VARCHAR2(30) := null;
   --
   -- Cursor declarations
   --

   CURSOR check_prod_rules
   IS
   SELECT 'x'
     FROM xla_prod_acct_headers
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND event_type_code  = p_event_type_code;

   CURSOR check_jld
   IS
   SELECT 'x'
     FROM xla_line_definitions_b
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code
      AND event_type_code  = p_event_type_code;

   CURSOR event_type_count
   IS
   SELECT count(1)
     FROM xla_event_types_vl
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND event_type_code <> p_event_class_code||'_ALL'
      AND accounting_flag  = 'Y'
      AND enabled_flag     = 'Y';

   CURSOR check_class_prod_rules
   IS
   SELECT 'x'
     FROM xla_prod_acct_headers
    WHERE application_id   = p_application_id
      AND entity_code      = p_entity_code
      AND event_class_code = p_event_class_code
      AND event_type_code  = p_event_class_code||'_ALL';

   CURSOR check_class_jld
   IS
   SELECT 'x'
     FROM xla_line_definitions_b
    WHERE application_id   = p_application_id
      AND event_class_code = p_event_class_code
      AND event_type_code  = p_event_class_code||'_ALL';

BEGIN
   xla_utility_pkg.trace('> xla_event_types_pkg.type_details_exist'                       , 10);

   xla_utility_pkg.trace('event               = '||p_event, 20);
   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code         = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code    = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('event_type_code     = '||p_event_type_code     , 20);

   IF p_event in ('DELETE','DISABLE') THEN

      IF p_accounting_flag = 'Y' THEN

         OPEN check_prod_rules;
         FETCH check_prod_rules
          INTO l_exist;
         IF check_prod_rules%found THEN
            l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
            l_return := TRUE;
         ELSE
            l_message := null;
            l_return := FALSE;
         END IF;
         CLOSE check_prod_rules;

         IF l_return = FALSE THEN
            OPEN check_jld;
            FETCH check_jld
             INTO l_exist;

            IF check_jld%found THEN
               l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
               l_return := TRUE;
            ELSE
               l_message := null;
               l_return := FALSE;
            END IF;
            CLOSE check_jld;
         END IF;

         IF l_return = FALSE THEN
            OPEN event_type_count;
            FETCH event_type_count
             INTO l_count;
            CLOSE event_type_count;

            IF l_count =1 THEN
               OPEN check_class_prod_rules;
               FETCH check_class_prod_rules
                INTO l_exist;
               IF check_class_prod_rules%found THEN
                  l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
                  l_return := TRUE;
               ELSE
                  l_message := null;
                  l_return := FALSE;
               END IF;
               CLOSE check_class_prod_rules;

               IF l_return = FALSE THEN
                  OPEN check_class_jld;
                  FETCH check_class_jld
                   INTO l_exist;
                  IF check_class_jld%found THEN
                     l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
                     l_return := TRUE;
                  ELSE
                     l_message := null;
                     l_return := FALSE;
                  END IF;
                  CLOSE check_class_jld;
               END IF;
            END IF;
         END IF;
      END IF;

      IF p_tax_flag = 'Y' THEN

         IF l_return = FALSE THEN

            IF zx_taxevent_pub.is_event_type_valid
                 (p_application_id   => l_application_id
                 ,p_entity_code      => l_entity_code
                 ,p_event_class_code => l_event_class_code
                 ,p_event_type_code  => l_event_type_code) THEN

               l_message := 'XLA_AB_TAX_DETAILS_EXIST';
               l_return := TRUE;
            ELSE
               l_message := null;
               l_return := FALSE;
            END IF;
         END IF;
      END IF;

   ELSIF p_event = 'DEACCOUNTING' THEN

      OPEN check_prod_rules;
      FETCH check_prod_rules
       INTO l_exist;
      IF check_prod_rules%found THEN
         l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
         l_return := TRUE;
      ELSE
         l_message := null;
         l_return := FALSE;
      END IF;
      CLOSE check_prod_rules;

      IF l_return = FALSE THEN
         OPEN check_jld;
         FETCH check_jld
          INTO l_exist;

         IF check_jld%found THEN
            l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
            l_return := TRUE;
         ELSE
            l_message := null;
            l_return := FALSE;
         END IF;
         CLOSE check_jld;
      END IF;

      IF l_return = FALSE THEN
         OPEN event_type_count;
         FETCH event_type_count
          INTO l_count;
         CLOSE event_type_count;

         IF l_count =1 THEN
            OPEN check_class_prod_rules;
            FETCH check_class_prod_rules
             INTO l_exist;
            IF check_class_prod_rules%found THEN
               l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
               l_return := TRUE;
            ELSE
               l_message := null;
               l_return := FALSE;
            END IF;
            CLOSE check_class_prod_rules;

            IF l_return = FALSE THEN
               OPEN check_class_jld;
               FETCH check_class_jld
                INTO l_exist;
               IF check_class_jld%found THEN
                  l_message := 'XLA_AB_EVENT_TYPE_IN_USE';
                  l_return := TRUE;
               ELSE
                  l_message := null;
                  l_return := FALSE;
               END IF;
               CLOSE check_class_jld;
            END IF;
         END IF;
      END IF;

   ELSIF p_event = 'DETAX' THEN

      IF zx_taxevent_pub.is_event_type_valid
          (p_application_id   => l_application_id
           ,p_entity_code      => l_entity_code
           ,p_event_class_code => l_event_class_code
           ,p_event_type_code  => l_event_type_code) THEN

         l_message := 'XLA_AB_TAX_DETAILS_EXIST';
         l_return := TRUE;
      ELSE
         l_message := null;
         l_return := FALSE;
      END IF;

   END IF;

   xla_utility_pkg.trace('< xla_event_types_pkg.type_details_exist'   , 10);
   p_message := l_message;
   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_event_types_pkg.type_details_exist');

END type_details_exist;

END xla_event_types_pkg;

/
