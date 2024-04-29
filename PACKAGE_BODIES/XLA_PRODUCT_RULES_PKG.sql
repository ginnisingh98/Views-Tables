--------------------------------------------------------
--  DDL for Package Body XLA_PRODUCT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_PRODUCT_RULES_PKG" AS
/* $Header: xlaampad.pkb 120.48 2006/02/22 22:35:33 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_product_rules_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Product Rules Package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

-------------------------------------------------------------------------------
-- declaring private package variables
-------------------------------------------------------------------------------
g_creation_date                   DATE;
g_last_update_date                DATE;
g_created_by                      INTEGER;
g_last_update_login               INTEGER;
g_last_updated_by                 INTEGER;

-------------------------------------------------------------------------------
-- declaring private package arrays
-------------------------------------------------------------------------------
TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;
TYPE t_array_id            IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| is_accounting_reversal                                                |
|                                                                       |
| Returns true if accounting reversal sources are assigned to the       |
| event class                                                           |
|                                                                       |
+======================================================================*/

FUNCTION is_accounting_reversal
  (p_application_id                   IN NUMBER
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return                  BOOLEAN;
   l_exist                   VARCHAR2(1);
   l_application_id          NUMBER(38);
   l_entity_code             VARCHAR2(30);
   l_event_class_code        VARCHAR2(30);
   l_source_name             varchar2(80) := null;
   l_source_type             varchar2(80) := null;

   CURSOR c_event_sources
   IS
   SELECT 'x'
     FROM xla_evt_class_acct_attrs e
    WHERE e.application_id                    = p_application_id
      AND e.event_class_code                  = p_event_class_code
      AND e.accounting_attribute_code         = 'ACCOUNTING_REVERSAL_OPTION';

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.is_accounting_reversal'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code  = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);

   l_application_id          := p_application_id;
   l_entity_code             := p_entity_code;
   l_event_class_code        := p_event_class_code;

   OPEN c_event_sources;
   FETCH c_event_sources
    INTO l_exist;
   IF c_event_sources%found then
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_event_sources;

   xla_utility_pkg.trace('< xla_product_rules_pkg.is_accounting_reversal'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.is_accounting_reversal');

END is_accounting_reversal;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| invalid_hdr_ac                                                        |
|                                                                       |
| Returns true if sources for the header analytical criteria are invalid|
|                                                                       |
+======================================================================*/

FUNCTION invalid_hdr_ac
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_anal_criterion_type_code         IN VARCHAR2
  ,p_analytical_criterion_code        IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return                  BOOLEAN;
   l_exist                   VARCHAR2(1);
   l_source_name             varchar2(80) := null;
   l_source_type             varchar2(80) := null;

   CURSOR c_anal
   IS
   SELECT 'x'
     FROM xla_analytical_hdrs_b  a
    WHERE amb_context_code               = p_amb_context_code
      AND analytical_criterion_code      = p_analytical_criterion_code
      AND analytical_criterion_type_code = p_anal_criterion_type_code
      AND balancing_flag = 'Y';

   CURSOR c_event_sources
   IS
   SELECT 'x'
     FROM xla_analytical_sources  a
    WHERE application_id                 = p_application_id
      AND amb_context_code               = p_amb_context_code
      AND event_class_code               = p_event_class_code
      AND analytical_criterion_code      = p_analytical_criterion_code
      AND analytical_criterion_type_code = p_anal_criterion_type_code;

   CURSOR c_hdr_analytical
   IS
   SELECT a.source_code, a.source_type_code
     FROM xla_analytical_sources  a
    WHERE application_id                 = p_application_id
      AND amb_context_code               = p_amb_context_code
      AND event_class_code               = p_event_class_code
      AND analytical_criterion_code      = p_analytical_criterion_code
      AND analytical_criterion_type_code = p_anal_criterion_type_code
      AND source_type_code               = 'S'
      AND not exists (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = a.source_application_id
                         AND s.source_type_code      = a.source_type_code
                         AND s.source_code           = a.source_code
                         AND s.application_id        = p_application_id
                         AND s.event_class_code      = p_event_class_code
                         AND s.active_flag           = 'Y'
                         AND s.level_code            = 'H');

   l_hdr_analytical     c_hdr_analytical%rowtype;

   CURSOR c_analytical_der_sources
   IS
   SELECT a.source_code, a.source_type_code
     FROM xla_analytical_sources  a
    WHERE application_id                 = p_application_id
      AND amb_context_code               = p_amb_context_code
      AND event_class_code               = p_event_class_code
      AND analytical_criterion_code      = p_analytical_criterion_code
      AND analytical_criterion_type_code = p_anal_criterion_type_code
      AND a.source_type_code             = 'D';

   l_analytical_der_sources     c_analytical_der_sources%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.invalid_hdr_ac'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('analytical_criterion_type_code  = '||p_anal_criterion_type_code , 20);
   xla_utility_pkg.trace('analytical_criterion_code  = '||p_analytical_criterion_code     , 20);

   OPEN c_anal;
   FETCH c_anal
    INTO l_exist;
   IF c_anal%found then
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_anal;

   IF l_return = FALSE THEN

      OPEN c_event_sources;
      FETCH c_event_sources
       INTO l_exist;
      IF c_event_sources%found then
         l_return := FALSE;
      ELSE
         l_return := TRUE;
      END IF;
      CLOSE c_event_sources;
   END IF;

   IF l_return = FALSE THEN

      OPEN c_hdr_analytical;
      FETCH c_hdr_analytical
       INTO l_hdr_analytical;
      IF c_hdr_analytical%found then
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_hdr_analytical;
   END IF;

      --
      -- check analytical criteria has derived sources that do not belong to the event class
      --
      IF l_return = FALSE THEN
         OPEN c_analytical_der_sources;
         LOOP
         FETCH c_analytical_der_sources
          INTO l_analytical_der_sources;
         EXIT WHEN c_analytical_der_sources%notfound or l_return = TRUE;

         IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => p_application_id
              ,p_derived_source_code      => l_analytical_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_event_class_code         => p_event_class_code
              ,p_level                    => 'H')  = 'TRUE' THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         END LOOP;
         CLOSE c_analytical_der_sources;
      END IF;

   xla_utility_pkg.trace('< xla_product_rules_pkg.invalid_hdr_ac'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.invalid_hdr_ac');

END invalid_hdr_ac;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| invalid_header_desc                                                   |
|                                                                       |
| Returns true if sources for the header description are invalid        |
|                                                                       |
+======================================================================*/

FUNCTION invalid_header_desc
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return                  BOOLEAN;
   l_exist                   VARCHAR2(1);
   l_application_id          NUMBER(38);
   l_entity_code             VARCHAR2(30);
   l_event_class_code        VARCHAR2(30);
   l_source_name             VARCHAR2(80) := null;
   l_source_type             VARCHAR2(80) := null;

   CURSOR c_desc_detail_sources
   IS
   SELECT d.source_type_code, d.source_code
     FROM xla_descript_details_b d, xla_desc_priorities p
    WHERE d.description_prio_id   = p.description_prio_id
      AND p.application_id        = p_application_id
      AND p.amb_context_code      = p_amb_context_code
      AND p.description_type_code = p_description_type_code
      AND p.description_code      = p_description_code
      AND d.source_code is not null
      AND d.source_type_code      = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = d.source_application_id
                         AND s.source_type_code      = d.source_type_code
                         AND s.source_code           = d.source_code
                         AND s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.active_flag          = 'Y'
                         AND s.level_code            = 'H');

   l_desc_detail_sources           c_desc_detail_sources%rowtype;

   CURSOR c_desc_condition_sources
   IS
   SELECT c.source_type_code source_type_code, c.source_code source_code
     FROM xla_conditions c, xla_desc_priorities d
    WHERE c.description_prio_id   = d.description_prio_id
      AND d.application_id        = p_application_id
      AND d.amb_context_code      = p_amb_context_code
      AND d.description_type_code = p_description_type_code
      AND d.description_code      = p_description_code
      AND c.source_code is not null
      AND c.source_type_code      = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = c.source_application_id
                         AND s.source_type_code      = c.source_type_code
                         AND s.source_code           = c.source_code
                         AND s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.active_flag          = 'Y'
                         AND s.level_code            = 'H')
   UNION
   SELECT c.value_source_type_code source_type_code, c.value_source_code source_code
     FROM xla_conditions c, xla_desc_priorities d
    WHERE c.description_prio_id     = d.description_prio_id
      AND d.application_id          = p_application_id
      AND d.amb_context_code        = p_amb_context_code
      AND d.description_type_code   = p_description_type_code
      AND d.description_code        = p_description_code
      AND c.value_source_code is not null
      AND c.value_source_type_code  = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_event_sources s
                       WHERE s.source_application_id = c.value_source_application_id
                         AND s.source_type_code      = c.value_source_type_code
                         AND s.source_code           = c.value_source_code
                         AND s.application_id        = p_application_id
                         AND s.entity_code           = p_entity_code
                         AND s.event_class_code      = p_event_class_code
                         AND s.active_flag          = 'Y'
                         AND s.level_code            = 'H');

   l_desc_condition_sources           c_desc_condition_sources%rowtype;

   CURSOR c_desc_detail_der_sources
   IS
   SELECT d.source_type_code source_type_code, d.source_code source_code
     FROM xla_descript_details_b d, xla_desc_priorities p
    WHERE d.description_prio_id   = p.description_prio_id
      AND p.application_id        = p_application_id
      AND p.amb_context_code      = p_amb_context_code
      AND p.description_type_code = p_description_type_code
      AND p.description_code      = p_description_code
      AND d.source_code is not null
      AND d.source_type_code      = 'D';

   l_desc_detail_der_sources           c_desc_detail_der_sources%rowtype;

   CURSOR c_desc_condition_der_sources
   IS
   SELECT c.source_type_code source_type_code, c.source_code source_code
     FROM xla_conditions c, xla_desc_priorities d
    WHERE c.description_prio_id   = d.description_prio_id
      AND d.application_id        = p_application_id
      AND d.amb_context_code      = p_amb_context_code
      AND d.description_type_code = p_description_type_code
      AND d.description_code      = p_description_code
      AND c.source_code is not null
      AND c.source_type_code      = 'D'
   UNION
   SELECT c.value_source_type_code source_type_code, c.value_source_code source_code
     FROM xla_conditions c, xla_desc_priorities d
    WHERE c.description_prio_id     = d.description_prio_id
      AND d.application_id          = p_application_id
      AND d.amb_context_code        = p_amb_context_code
      AND d.description_type_code   = p_description_type_code
      AND d.description_code        = p_description_code
      AND c.value_source_code is not null
      AND c.value_source_type_code  = 'D';

   l_desc_condition_der_sources           c_desc_condition_der_sources%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.invalid_header_desc'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code  = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('description_type_code  = '||p_description_type_code , 20);
   xla_utility_pkg.trace('description_code  = '||p_description_code     , 20);

      --
      -- check description has seeded sources that do not belong to the event class
      --

   l_application_id          := p_application_id;
   l_entity_code             := p_entity_code;
   l_event_class_code        := p_event_class_code;

      OPEN c_desc_detail_sources;
      FETCH c_desc_detail_sources
       INTO l_desc_detail_sources;
      IF c_desc_detail_sources%found then
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_desc_detail_sources;

      IF l_return = FALSE THEN
         OPEN c_desc_condition_sources;
         FETCH c_desc_condition_sources
          INTO l_desc_condition_sources;
         IF c_desc_condition_sources%found then
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         CLOSE c_desc_condition_sources;
      END IF;

      --
      -- check description has derived sources that do not belong to the event class
      --
      IF l_return = FALSE THEN
         OPEN c_desc_detail_der_sources;
         LOOP
         FETCH c_desc_detail_der_sources
          INTO l_desc_detail_der_sources;
         EXIT WHEN c_desc_detail_der_sources%notfound or l_return = TRUE;

         IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => l_application_id
              ,p_derived_source_code      => l_desc_detail_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_entity_code              => l_entity_code
              ,p_event_class_code         => l_event_class_code
              ,p_level                    => 'H')  = 'TRUE' THEN
            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         END LOOP;
         CLOSE c_desc_detail_der_sources;
      END IF;

      IF l_return = FALSE THEN
         OPEN c_desc_condition_der_sources;
         LOOP
         FETCH c_desc_condition_der_sources
          INTO l_desc_condition_der_sources;
         EXIT WHEN c_desc_condition_der_sources%notfound or l_return = TRUE;


         IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => l_application_id
              ,p_derived_source_code      => l_desc_condition_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_entity_code              => l_entity_code
              ,p_event_class_code         => l_event_class_code
              ,p_level                    => 'H') = 'TRUE' THEN

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
         END LOOP;
         CLOSE c_desc_condition_der_sources;
      END IF;

   xla_utility_pkg.trace('< xla_product_rules_pkg.invalid_header_desc'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_desc_condition_sources%ISOPEN THEN
         CLOSE c_desc_condition_sources;
      END IF;
      IF c_desc_detail_sources%ISOPEN THEN
         CLOSE c_desc_detail_sources;
      END IF;
      RAISE;

   WHEN OTHERS                                   THEN
      IF c_desc_condition_sources%ISOPEN THEN
         CLOSE c_desc_condition_sources;
      END IF;
      IF c_desc_detail_sources%ISOPEN THEN
         CLOSE c_desc_detail_sources;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.invalid_header_desc');

END invalid_header_desc;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_product_rule_details                                           |
|                                                                       |
| Deletes all details of the product rule                               |
|                                                                       |
+======================================================================*/

PROCEDURE delete_product_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2)
IS

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.delete_product_rule_details'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('product_rule_type_code  = '||p_product_rule_type_code     , 20);
   xla_utility_pkg.trace('product_rule_code  = '||p_product_rule_code     , 20);

   DELETE
     FROM xla_aad_header_ac_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code;

   DELETE
     FROM xla_aad_hdr_acct_attrs
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code;

   DELETE
     FROM xla_aad_line_defn_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code;

   DELETE
     FROM xla_prod_acct_headers
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code;

   xla_utility_pkg.trace('< xla_product_rules_pkg.delete_product_rule_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.delete_product_rule_details');

END delete_product_rule_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_prod_header_details                                            |
|                                                                       |
| Deletes all details of the event class and event type assignment      |
|                                                                       |
+======================================================================*/

PROCEDURE delete_prod_header_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2)
IS

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.delete_prod_header_details'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('product_rule_type_code  = '||p_product_rule_type_code     , 20);
   xla_utility_pkg.trace('product_rule_code  = '||p_product_rule_code     , 20);

   DELETE
     FROM xla_aad_header_ac_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code
      AND event_class_code          = p_event_class_code
      AND event_type_code           = p_event_type_code;

   DELETE
     FROM xla_aad_hdr_acct_attrs
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code
      AND event_class_code          = p_event_class_code
      AND event_type_code           = p_event_type_code;

   DELETE
     FROM xla_aad_line_defn_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code
      AND event_class_code          = p_event_class_code
      AND event_type_code           = p_event_type_code;

   xla_utility_pkg.trace('< xla_product_rules_pkg.delete_prod_header_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.delete_prod_header_details');

END delete_prod_header_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_product_rule_details                                             |
|                                                                       |
| Copies details of a product rule into a new product rule              |
|                                                                       |
+======================================================================*/

PROCEDURE copy_product_rule_details
  (p_application_id                       IN NUMBER
  ,p_amb_context_code                     IN VARCHAR2
  ,p_old_product_rule_type_code           IN VARCHAR2
  ,p_old_product_rule_code                IN VARCHAR2
  ,p_new_product_rule_type_code           IN VARCHAR2
  ,p_new_product_rule_code                IN VARCHAR2
  ,p_include_header_assignments           IN VARCHAR2
  ,p_include_line_assignments             IN VARCHAR2)
IS
  l_creation_date       DATE;
  l_last_update_date    DATE;
  l_created_by          INTEGER;
  l_last_update_login   INTEGER;
  l_last_updated_by     INTEGER;

BEGIN

  xla_utility_pkg.trace('> xla_product_rules_pkg.copy_product_rule_details'   , 10);

  xla_utility_pkg.trace('application_id                = '||p_application_id  , 20);
  xla_utility_pkg.trace('old_product_rule_type_code = '||p_old_product_rule_type_code , 20);
  xla_utility_pkg.trace('old_product_rule_code  = '||p_old_product_rule_code     , 20);
  xla_utility_pkg.trace('new_product_rule_type_code = '||p_new_product_rule_type_code , 20);
  xla_utility_pkg.trace('new_product_rule_code   = '||p_new_product_rule_code     , 20);
  xla_utility_pkg.trace('include_header_assignments = '||p_include_header_assignments , 20);
  xla_utility_pkg.trace('include_line_assignments = '||p_include_line_assignments , 20);

  l_creation_date     := sysdate;
  l_last_update_date  := sysdate;
  l_created_by        := xla_environment_pkg.g_usr_id;
  l_last_update_login := xla_environment_pkg.g_login_id;
  l_last_updated_by   := xla_environment_pkg.g_usr_id;

  INSERT INTO xla_prod_acct_headers
              (application_id
              ,amb_context_code
              ,product_rule_type_code
              ,product_rule_code
              ,entity_code
              ,event_class_code
              ,event_type_code
              ,description_type_code
              ,description_code
              ,accounting_required_flag
              ,Locking_status_flag
              ,validation_status_code
              ,creation_date
              ,created_by
              ,last_update_date
              ,last_updated_by
              ,last_update_login)
    SELECT p_application_id
          ,p_amb_context_code
          ,p_new_product_rule_type_code
          ,p_new_product_rule_code
          ,entity_code
          ,event_class_code
          ,event_type_code
          ,decode(p_include_header_assignments,'Y',description_type_code,NULL)
          ,decode(p_include_header_assignments,'Y',description_code,NULL)
          ,accounting_required_flag
          ,locking_status_flag
          ,'N'
          ,l_creation_date
          ,l_created_by
          ,l_last_update_date
          ,l_last_updated_by
          ,l_last_update_login
      FROM xla_prod_acct_headers
     WHERE application_id            = p_application_id
       AND amb_context_code          = p_amb_context_code
       AND product_rule_type_code    = p_old_product_rule_type_code
       AND product_rule_code         = p_old_product_rule_code;

  IF (p_include_header_assignments = 'Y') THEN
    INSERT INTO xla_aad_header_ac_assgns
                (application_id
                ,amb_context_code
                ,product_rule_type_code
                ,product_rule_code
                ,event_class_code
                ,event_type_code
                ,analytical_criterion_type_code
                ,analytical_criterion_code
                ,object_version_number
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login)
      SELECT p_application_id
            ,p_amb_context_code
            ,p_new_product_rule_type_code
            ,p_new_product_rule_code
            ,event_class_code
            ,event_type_code
            ,analytical_criterion_type_code
            ,analytical_criterion_code
            ,1
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
        FROM xla_aad_header_ac_assgns
       WHERE application_id            = p_application_id
         AND amb_context_code          = p_amb_context_code
         AND product_rule_type_code    = p_old_product_rule_type_code
         AND product_rule_code         = p_old_product_rule_code;

    INSERT INTO xla_aad_hdr_acct_attrs
                (application_id
                ,amb_context_code
                ,product_rule_type_code
                ,product_rule_code
                ,event_class_code
                ,event_type_code
                ,accounting_attribute_code
                ,source_application_id
                ,source_type_code
                ,source_code
                ,event_class_default_flag
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login)
      SELECT p_application_id
            ,p_amb_context_code
            ,p_new_product_rule_type_code
            ,p_new_product_rule_code
            ,event_class_code
            ,event_type_code
            ,accounting_attribute_code
            ,source_application_id
            ,source_type_code
            ,source_code
            ,event_class_default_flag
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
        FROM xla_aad_hdr_acct_attrs
       WHERE application_id            = p_application_id
         AND amb_context_code          = p_amb_context_code
         AND product_rule_type_code    = p_old_product_rule_type_code
         AND product_rule_code         = p_old_product_rule_code;
  END IF;

  IF p_include_line_assignments = 'Y' THEN

    INSERT INTO xla_aad_line_defn_assgns
                 (application_id
                 ,amb_context_code
                 ,product_rule_type_code
                 ,product_rule_code
                 ,event_class_code
                 ,event_type_code
                 ,line_definition_owner_code
                 ,line_definition_code
                 ,object_version_number
                 ,creation_date
                 ,created_by
                 ,last_update_date
                 ,last_updated_by
                 ,last_update_login)
      SELECT p_application_id
            ,p_amb_context_code
            ,p_new_product_rule_type_code
            ,p_new_product_rule_code
            ,event_class_code
            ,event_type_code
            ,line_definition_owner_code
            ,line_definition_code
            ,1
            ,l_creation_date
            ,l_created_by
            ,l_last_update_date
            ,l_last_updated_by
            ,l_last_update_login
        FROM xla_aad_line_defn_assgns
       WHERE application_id            = p_application_id
         AND amb_context_code          = p_amb_context_code
         AND product_rule_type_code    = p_old_product_rule_type_code
         AND product_rule_code         = p_old_product_rule_code;
  END IF;

  xla_utility_pkg.trace('< xla_product_rules_pkg.copy_product_rule_details'    , 10);

EXCEPTION
  WHEN xla_exceptions_pkg.application_exception THEN
    RAISE;

  WHEN OTHERS                                   THEN
    xla_exceptions_pkg.raise_message
      (p_location   => 'xla_product_rules_pkg.copy_product_rule_details');

END copy_product_rule_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| product_rule_in_use                                                   |
|                                                                       |
| Returns true if the product rule is assigned to an accounting method  |
|                                                                       |
+======================================================================*/

FUNCTION product_rule_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_accounting_method_name           IN OUT NOCOPY VARCHAR2
  ,p_accounting_method_type           IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return                   BOOLEAN;
   l_exist                    VARCHAR2(1);
   l_accounting_method_name   VARCHAR2(80) := null;
   l_accounting_method_type   VARCHAR2(80) := null;

   CURSOR c_assignment_exist
   IS
   SELECT accounting_method_code, accounting_method_type_code
     FROM xla_acctg_method_rules
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code;

   l_assignment_exist     c_assignment_exist%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.product_rule_in_use'   , 10);

   xla_utility_pkg.trace('event                   = '||p_event  , 20);
   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('product_rule_type_code  = '||p_product_rule_type_code     , 20);
   xla_utility_pkg.trace('product_rule_code  = '||p_product_rule_code     , 20);

   IF p_event in ('DELETE','UPDATE','DISABLE') THEN
      OPEN c_assignment_exist;
      FETCH c_assignment_exist
       INTO l_assignment_exist;
      IF c_assignment_exist%found then

         xla_validations_pkg.get_accounting_method_info
           (p_accounting_method_type_code  => l_assignment_exist.accounting_method_type_code
           ,p_accounting_method_code       => l_assignment_exist.accounting_method_code
           ,p_accounting_method_name       => l_accounting_method_name
           ,p_accounting_method_type       => l_accounting_method_type);

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_assignment_exist;

   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Invalid event passed'
        ,'LOCATION' ,'xla_product_rules_pkg.product_rule_in_use');

   END IF;

   p_accounting_method_name    := l_accounting_method_name;
   p_accounting_method_type    := l_accounting_method_type;

   xla_utility_pkg.trace('< xla_product_rules_pkg.product_rule_in_use'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_assignment_exist%ISOPEN THEN
         CLOSE c_assignment_exist;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_assignment_exist%ISOPEN THEN
         CLOSE c_assignment_exist;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.product_rule_in_use');

END product_rule_in_use;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| invalid_header_description                                            |
|                                                                       |
| Returns true if sources for the header description are invalid        |
|                                                                       |
+======================================================================*/

FUNCTION invalid_header_description
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2)
RETURN VARCHAR2
IS

   l_return                  VARCHAR2(30);
   l_exist                   VARCHAR2(1);
   l_application_id          NUMBER(38);
   l_entity_code             VARCHAR2(30);
   l_event_class_code        VARCHAR2(30);
   l_amb_context_code        VARCHAR2(30);
   l_description_type_code   VARCHAR2(1);
   l_description_code        VARCHAR2(30);
   l_message_name            VARCHAR2(30);

   l_source_name             varchar2(80) := null;
   l_source_type             varchar2(80) := null;

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.invalid_header_description'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code  = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('description_type_code  = '||p_description_type_code , 20);
   xla_utility_pkg.trace('description_code  = '||p_description_code     , 20);

   l_application_id          := p_application_id;
   l_entity_code             := p_entity_code;
   l_event_class_code        := p_event_class_code;
   l_amb_context_code        := p_amb_context_code;
   l_description_type_code   := p_description_type_code;
   l_description_code        := p_description_code;

      --
      -- call invalid_header_desc to see if description is invalid
      --
      IF xla_product_rules_pkg.invalid_header_desc
           (p_application_id           => l_application_id
           ,p_amb_context_code         => l_amb_context_code
           ,p_entity_code              => l_entity_code
           ,p_event_class_code         => l_event_class_code
           ,p_description_type_code    => l_description_type_code
           ,p_description_code         => l_description_code) THEN

         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;

   xla_utility_pkg.trace('< xla_product_rules_pkg.invalid_header_description'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.invalid_header_description');

END invalid_header_description;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_product_rule                                                |
|                                                                       |
| Returns true if the product rule gets uncompiled                      |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_product_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return                BOOLEAN;
   l_exist                 VARCHAR2(1);

   CURSOR c_prod_rules
   IS
   SELECT 'x'
     FROM xla_product_rules_b
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code
      AND compile_status_code       in ('E','N','Y')
      AND locking_status_flag       = 'N'
   FOR UPDATE of compile_status_code NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.uncompile_product_rule'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('product_rule_type_code  = '||p_product_rule_type_code     , 20);
   xla_utility_pkg.trace('product_rule_code  = '||p_product_rule_code     , 20);

   OPEN c_prod_rules;
   FETCH c_prod_rules INTO l_exist;
   IF c_prod_rules%found then

      UPDATE xla_product_rules_b
         SET compile_status_code = 'N'
       WHERE current of c_prod_rules;

      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_prod_rules;

   xla_utility_pkg.trace('< xla_product_rules_pkg.uncompile_product_rule'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.uncompile_product_rule');

END uncompile_product_rule;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| set_compile_status                                                    |
|                                                                       |
| Returns true if the compile_status is changed as desired              |
|                                                                       |
+======================================================================*/

FUNCTION set_compile_status
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_status                           IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return                BOOLEAN;
   l_exist                 VARCHAR2(1);

   CURSOR c_prod_rules
   IS
   SELECT 'x'
     FROM xla_product_rules_b
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND product_rule_type_code    = p_product_rule_type_code
      AND product_rule_code         = p_product_rule_code
   FOR UPDATE of compile_status_code NOWAIT;

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.set_compile_status'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('product_rule_type_code  = '||p_product_rule_type_code     , 20);
   xla_utility_pkg.trace('product_rule_code  = '||p_product_rule_code     , 20);

   OPEN c_prod_rules;
   FETCH c_prod_rules
    INTO l_exist;
   IF c_prod_rules%found then

      UPDATE xla_product_rules_b
         SET compile_status_code = p_status
       WHERE current of c_prod_rules;

      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_prod_rules;

   xla_utility_pkg.trace('< xla_product_rules_pkg.set_compile_status'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.set_compile_status');

END set_compile_status;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| invalid_hdr_analytical                                                |
|                                                                       |
| Returns true if sources for the reference set are invalid             |
|                                                                       |
+======================================================================*/

FUNCTION invalid_hdr_analytical
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_anal_criterion_type_code          IN VARCHAR2
  ,p_analytical_criterion_code         IN VARCHAR2)
RETURN VARCHAR2
IS

   l_return                    VARCHAR2(30);
   l_exist                     VARCHAR2(1);
   l_source_code               VARCHAR2(30);
   l_message_name              VARCHAR2(30) := null;
   l_source_name               VARCHAR2(80) := null;
   l_source_type               VARCHAR2(80) := null;

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.invalid_hdr_analytical'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('analytical_criterion_type_code  = '||p_anal_criterion_type_code , 20);
   xla_utility_pkg.trace('analytical_criterion_code  = '||p_analytical_criterion_code     , 20);

      --
      -- call invalid_hdr_analytical to see if header analytical criteria is invalid
      --
      IF xla_product_rules_pkg.invalid_hdr_ac
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_event_class_code           => p_event_class_code
           ,p_anal_criterion_type_code    => p_anal_criterion_type_code
           ,p_analytical_criterion_code   => p_analytical_criterion_code) THEN

         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;

   xla_utility_pkg.trace('< xla_product_rules_pkg.invalid_hdr_analytical'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.invalid_hdr_analytical');

END invalid_hdr_analytical;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| create_accounting_attributes                                          |
|                                                                       |
| Creates accounting attributes for the line type                       |
|                                                                       |
+======================================================================*/

PROCEDURE create_accounting_attributes
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_product_rule_type_code           IN VARCHAR2
  ,p_product_rule_code                IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_event_type_code                  IN VARCHAR2)
IS

   -- Array Declaration
   l_arr_acct_attribute_code         t_array_codes;
   l_arr_source_application_id       t_array_id;
   l_arr_source_type_code            t_array_codes;
   l_arr_source_code                 t_array_codes;

   -- Local variables
   l_exist    VARCHAR2(1);

    CURSOR c_acct_sources
    IS
    SELECT 'x'
      FROM xla_aad_hdr_acct_attrs
     WHERE application_id            = p_application_id
       AND amb_context_code          = p_amb_context_code
       AND product_rule_type_code    = p_product_rule_type_code
       AND product_rule_code         = p_product_rule_code
       AND event_class_code          = p_event_class_code
       AND event_type_code           = p_event_type_code;

    CURSOR c_attr_source
    IS
    SELECT e.accounting_attribute_code, e.source_application_id,
           e.source_type_code, e.source_code
      FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.default_flag              = 'Y'
       AND e.accounting_attribute_code = l.accounting_attribute_code
       AND l.assignment_level_code     = 'EVT_CLASS_AAD';

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.create_accounting_attributes'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);

        OPEN c_acct_sources;
        FETCH c_acct_sources
         INTO l_exist;
        IF c_acct_sources%notfound THEN
           -- Insert accounting attributes of level 'EVT_CLASS_AAD' and 'AAD_ONLY'
           -- with null source mapping
           INSERT into xla_aad_hdr_acct_attrs(
                application_id
               ,amb_context_code
               ,product_rule_type_code
               ,product_rule_code
               ,event_class_code
               ,event_type_code
               ,accounting_attribute_code
               ,source_application_id
               ,source_type_code
               ,source_code
               ,event_class_default_flag
               ,creation_date
               ,created_by
               ,last_update_date
               ,last_updated_by
               ,last_update_login)
           (SELECT distinct p_application_id
                  ,p_amb_context_code
                  ,p_product_rule_type_code
                  ,p_product_rule_code
                  ,p_event_class_code
                  ,p_event_type_code
                  ,e.accounting_attribute_code
                  ,null
                  ,null
                  ,null
                  ,decode(e.accounting_attribute_code,'ACCRUAL_REVERSAL_GL_DATE'
                         ,'N','Y')
                  ,g_creation_date
                  ,g_created_by
                  ,g_last_update_date
                  ,g_last_updated_by
                  ,g_last_update_login
              FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
             WHERE e.application_id            = p_application_id
               AND e.event_class_code          = p_event_class_code
               AND e.accounting_attribute_code = l.accounting_attribute_code
               AND l.assignment_level_code     = 'EVT_CLASS_AAD'
            UNION
            SELECT distinct p_application_id
                  ,p_amb_context_code
                  ,p_product_rule_type_code
                  ,p_product_rule_code
                  ,p_event_class_code
                  ,p_event_type_code
                  ,l.accounting_attribute_code
                  ,null
                  ,null
                  ,null
                  ,'N'
                  ,g_creation_date
                  ,g_created_by
                  ,g_last_update_date
                  ,g_last_updated_by
                  ,g_last_update_login
              FROM xla_acct_attributes_b l
             WHERE l.assignment_level_code     = 'AAD_ONLY');

            -- Update the default source mappings on the AAD
            OPEN c_attr_source;
            FETCH c_attr_source
            BULK COLLECT INTO l_arr_acct_attribute_code, l_arr_source_application_id,
                              l_arr_source_type_code, l_arr_source_code;

            IF l_arr_acct_attribute_code.COUNT > 0 THEN
               FORALL i IN l_arr_acct_attribute_code.FIRST..l_arr_acct_attribute_code.LAST

               UPDATE xla_aad_hdr_acct_attrs
                  SET source_application_id     = l_arr_source_application_id(i)
                     ,source_type_code          = l_arr_source_type_code(i)
                     ,source_code               = l_arr_source_code(i)
                WHERE application_id            = p_application_id
                  AND amb_context_code          = p_amb_context_code
                  AND product_rule_type_code    = p_product_rule_type_code
                  AND product_rule_code         = p_product_rule_code
                  AND event_class_code          = p_event_class_code
                  AND event_type_code           = p_event_type_code
                  AND accounting_attribute_code = l_arr_acct_attribute_code(i)
                  AND event_class_default_flag  = 'Y';


            END IF;
            CLOSE c_attr_source;

        END IF;
        CLOSE c_acct_sources;

   xla_utility_pkg.trace('< xla_product_rules_pkg.create_accounting_attributes'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.create_accounting_attributes');

END create_accounting_attributes;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_default_attr_assignment                                           |
|                                                                       |
| Gets the default source assignments for the accounting attribute      |
|                                                                       |
+======================================================================*/

PROCEDURE get_default_attr_assignment
  (p_application_id                   IN NUMBER
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_attribute_code        IN VARCHAR2
  ,p_source_application_id            IN OUT NOCOPY NUMBER
  ,p_source_type_code                 IN OUT NOCOPY VARCHAR2
  ,p_source_code                      IN OUT NOCOPY VARCHAR2
  ,p_source_name                      IN OUT NOCOPY VARCHAR2
  ,p_source_type_dsp                  IN OUT NOCOPY VARCHAR2)
IS

   l_exist    VARCHAR2(1);

    CURSOR c_dflt_source
    IS
    SELECT e.source_application_id, e.source_type_code, e.source_code,
           s.name, l.meaning source_type_dsp
      FROM xla_evt_class_acct_attrs e, xla_sources_tl s, xla_lookups l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.accounting_attribute_code = p_accounting_attribute_code
       AND e.default_flag              = 'Y'
       AND e.source_application_id     = s.application_id (+)
       AND e.source_type_code          = s.source_type_code (+)
       AND e.source_code               = s.source_code (+)
       AND s.language (+)              = USERENV('LANG')
       AND e.source_type_code          = l.lookup_code (+)
       AND l.lookup_type  (+)          = 'XLA_SOURCE_TYPE';

BEGIN

   xla_utility_pkg.trace('> xla_product_rules_pkg.get_default_attr_assignment'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);

        OPEN c_dflt_source;
        FETCH c_dflt_source
         INTO p_source_application_id, p_source_type_code, p_source_code,
              p_source_name, p_source_type_dsp;
        IF c_dflt_source%notfound THEN
           p_source_application_id := null;
           p_source_type_code      := null;
           p_source_code           := null;
           p_source_name           := null;
           p_source_type_dsp       := null;

        END IF;
        CLOSE c_dflt_source;

   xla_utility_pkg.trace('< xla_product_rules_pkg.get_default_attr_assignment'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_product_rules_pkg.get_default_attr_assignment');

END get_default_attr_assignment;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Uncompiles all AADs for an application                                |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                  IN  NUMBER
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
       AND (xpa.validation_status_code    NOT IN ('E', 'Y', 'N') OR
            xpa.locking_status_flag       = 'Y');

   l_locked_aad   c_locked_aads%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_event_classes_pkg.uncompile_definitions'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);

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
         AND xld.validation_status_code <> 'N';

      UPDATE xla_prod_acct_headers      xpa
         SET validation_status_code     = 'N'
       WHERE xpa.application_id         = p_application_id
         AND xpa.validation_status_code <> 'N';

      UPDATE xla_product_rules_b        xpr
         SET compile_status_code        = 'N'
       WHERE xpr.application_id         = p_application_id
         AND xpr.compile_status_code    <> 'N';

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

BEGIN

g_creation_date		:= sysdate;
g_last_update_date	:= sysdate;
g_created_by		:= xla_environment_pkg.g_usr_id;
g_last_update_login	:= xla_environment_pkg.g_login_id;
g_last_updated_by	:= xla_environment_pkg.g_usr_id;

END xla_product_rules_pkg;

/
