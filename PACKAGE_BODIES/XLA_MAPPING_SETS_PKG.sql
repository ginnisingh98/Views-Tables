--------------------------------------------------------
--  DDL for Package Body XLA_MAPPING_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_MAPPING_SETS_PKG" AS
/* $Header: xlaamdms.pkb 120.7 2004/11/02 18:59:34 wychan ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_mapping_sets_pkg                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Mapping Sets Package                                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_mapping_set_details                                            |
|                                                                       |
| Deletes all details of the mapping set                                |
|                                                                       |
+======================================================================*/

PROCEDURE delete_mapping_set_details
  (p_mapping_set_code                IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2)
IS

BEGIN

   xla_utility_pkg.trace('> xla_mapping_sets_pkg.delete_mapping_set_details'   , 10);

   xla_utility_pkg.trace('mapping_set_code  = '||p_mapping_set_code     , 20);

   DELETE
     FROM xla_mapping_set_values
    WHERE mapping_set_code         = p_mapping_set_code
      AND amb_context_code         = p_amb_context_code;

   xla_utility_pkg.trace('< xla_mapping_sets_pkg.delete_mapping_set_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_mapping_sets_pkg.delete_seg_rule_details');

END delete_mapping_set_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| mapping_set_in_use                                                    |
|                                                                       |
| Returns true if the mapping set is in use by an account               |
| derivation rule                                                       |
|                                                                       |
+======================================================================*/

FUNCTION mapping_set_in_use
  (p_event                            IN VARCHAR2
  ,p_mapping_set_code                 IN VARCHAR2
  ,p_amb_context_code                 IN VARCHAR2
  ,p_application_id                   IN OUT NOCOPY NUMBER
  ,p_segment_rule_code                IN OUT NOCOPY VARCHAR2
  ,p_segment_rule_type_code           IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN;

   CURSOR c_assignment_exist
   IS
   SELECT application_id, amb_context_code, segment_rule_code, segment_rule_type_code
     FROM xla_seg_rule_details
    WHERE value_mapping_set_code = p_mapping_set_code
      AND amb_context_code       = p_amb_context_code
      AND value_mapping_set_code is not null;

   l_assignment_exist c_assignment_exist%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_mapping_sets_pkg.mapping_set_in_use'   , 10);

   xla_utility_pkg.trace('event                   = '||p_event  , 20);
   xla_utility_pkg.trace('mapping_set_code        = '||p_mapping_set_code     , 20);

   IF p_event in ('DELETE','UPDATE','DISABLE') THEN
      OPEN c_assignment_exist;
      FETCH c_assignment_exist
       INTO l_assignment_exist;
      IF c_assignment_exist%found then
         p_application_id := l_assignment_exist.application_id;
         p_segment_rule_code := l_assignment_exist.segment_rule_code;
         p_segment_rule_type_code := l_assignment_exist.segment_rule_type_code;

         l_return := TRUE;
      ELSE
         p_application_id := null;
         p_segment_rule_code := null;
         p_segment_rule_type_code := null;

         l_return := FALSE;
      END IF;
      CLOSE c_assignment_exist;

   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Invalid event passed'
        ,'LOCATION' ,'xla_mapping_sets_pkg.mapping_set_in_use');

   END IF;

   xla_utility_pkg.trace('< xla_mapping_sets_pkg.mapping_set_in_use'    , 10);

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
        (p_location   => 'xla_mapping_sets_pkg.mapping_set_in_use');

END mapping_set_in_use;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| mapping_set_is_locked                                                 |
|                                                                       |
| Returns true if the mapping set is in use by a locked product rule    |
|                                                                       |
+======================================================================*/

FUNCTION mapping_set_is_locked
  (p_mapping_set_code                IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN;
   l_exist    VARCHAR2(1);

   CURSOR c_frozen_assignment_exist
   IS
   SELECT 'x'
     FROM xla_seg_rule_details xsr
    WHERE xsr.value_mapping_set_code    = p_mapping_set_code
      AND xsr.amb_context_code          = p_amb_context_code
      AND xsr.value_mapping_set_code is not null
      AND exists      (SELECT 'x'
                         FROM xla_line_defn_adr_assgns xld
                            , xla_aad_line_defn_assgns xal
                            , xla_prod_acct_headers    xpa
                        WHERE xsr.application_id             = xld.application_id
                          AND xsr.amb_context_code           = xld.amb_context_code
                          AND xsr.segment_rule_type_code     = xld.segment_rule_type_code
                          AND xsr.segment_rule_code          = xld.segment_rule_code
                          AND xld.application_id             = xal.application_id
                          AND xld.amb_context_code           = xal.amb_context_code
                          AND xld.event_class_code           = xal.event_class_code
                          AND xld.event_type_code            = xal.event_type_code
                          AND xld.line_definition_owner_code = xal.line_definition_owner_code
                          AND xld.line_definition_code       = xal.line_definition_code
                          AND xal.application_id             = xpa.application_id
                          AND xal.amb_context_code           = xpa.amb_context_code
                          AND xal.product_rule_type_code     = xpa.product_rule_type_code
                          AND xal.product_rule_code          = xpa.product_rule_code
                          AND xal.event_class_code           = xpa.event_class_code
                          AND xal.event_type_code            = xpa.event_type_code
                          AND xpa.locking_status_flag        = 'Y');

   CURSOR c_tab_assignment_exist
   IS
   SELECT 'x'
     FROM xla_seg_rule_details d
    WHERE d.value_mapping_set_code    = p_mapping_set_code
      AND d.amb_context_code          = p_amb_context_code
      AND d.value_mapping_set_code is not null
      AND exists      (SELECT 'x'
                         FROM xla_tab_acct_defs_b a, xla_tab_acct_def_details s
                        WHERE a.application_id               = s.application_id
                          AND a.amb_context_code             = s.amb_context_code
                          AND a.account_definition_type_code = s.account_definition_type_code
                          AND a.account_definition_code      = s.account_definition_code
                          AND s.application_id               = d.application_id
                          AND s.amb_context_code             = d.amb_context_code
                          AND s.segment_rule_type_code       = d.segment_rule_type_code
                          AND s.segment_rule_code            = d.segment_rule_code
                          AND a.locking_status_flag          = 'Y');

BEGIN

   xla_utility_pkg.trace('> xla_mapping_sets_pkg.mapping_set_is_locked'   , 10);

   xla_utility_pkg.trace('mapping_set_code       = '||p_mapping_set_code     , 20);

   OPEN c_frozen_assignment_exist;
   FETCH c_frozen_assignment_exist
    INTO l_exist;
   IF c_frozen_assignment_exist%found then
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_frozen_assignment_exist;

   IF l_return = FALSE THEN
      OPEN c_tab_assignment_exist;
      FETCH c_tab_assignment_exist
       INTO l_exist;
      IF c_tab_assignment_exist%found then
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_tab_assignment_exist;
   END IF;

   xla_utility_pkg.trace('< xla_mapping_sets_pkg.mapping_set_is_locked'    , 10);

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
        (p_location   => 'xla_mapping_sets_pkg.mapping_set_is_locked');

END mapping_set_is_locked;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_product_rule                                                |
|                                                                       |
| Wrapper for uncompile_definitions                                     |
| Provided for backward-compatibility, to be obsoleted                  |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_product_rule
  (p_mapping_set_code                IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2
  ,p_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,p_product_rule_type               IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_event_class_name     varchar2(80) := null;
   l_event_type_name      varchar2(80) := null;
   l_locking_status_flag  varchar2(80) := null;

   l_return   BOOLEAN := TRUE;

BEGIN

   xla_utility_pkg.trace('> xla_mapping_sets_pkg.uncompile_product_rule'   , 10);

   xla_utility_pkg.trace('mapping_set_code       = '||p_mapping_set_code     , 20);

   l_return := uncompile_definitions
           (p_mapping_set_code        => p_mapping_set_code
           ,p_amb_context_code        => p_amb_context_code
           ,x_product_rule_name       => p_product_rule_name
           ,x_product_rule_type       => p_product_rule_type
           ,x_event_class_name        => l_event_class_name
           ,x_event_type_name         => l_event_type_name
           ,x_locking_status_flag     => l_locking_status_flag);

   xla_utility_pkg.trace('< xla_mapping_sets_pkg.uncompile_product_rule'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_mapping_sets_pkg.uncompile_product_rule');

END uncompile_product_rule;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Sets status of assigned application accounting definitions and        |
| journal lines definitions to uncompiled                               |
|                                                                       |
+======================================================================*/
FUNCTION uncompile_definitions
  (p_mapping_set_code                IN VARCHAR2
  ,p_amb_context_code                IN VARCHAR2
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
   l_product_rule_name    varchar2(80) := null;
   l_product_rule_type    varchar2(80) := null;
   l_event_class_name     varchar2(80) := null;
   l_event_type_name      varchar2(80) := null;
   l_locking_status_flag  varchar2(80) := null;

   CURSOR c_prod_rules
   IS
   SELECT application_id, amb_context_code, segment_rule_type_code, segment_rule_code
     FROM xla_seg_rule_details d
    WHERE d.value_mapping_set_code    = p_mapping_set_code
      AND d.value_mapping_set_code is not null;

   l_prod_rule   c_prod_rules%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_mapping_sets_pkg.uncompile_definitions'   , 10);

   xla_utility_pkg.trace('mapping_set_code       = '||p_mapping_set_code     , 20);

   OPEN c_prod_rules;
   LOOP
   FETCH c_prod_rules
    INTO l_prod_rule;
   EXIT WHEN c_prod_rules%NOTFOUND or l_return=FALSE;

      IF xla_seg_rules_pkg.uncompile_definitions
           (p_application_id          => l_prod_rule.application_id
           ,p_amb_context_code        => l_prod_rule.amb_context_code
           ,p_segment_rule_type_code  => l_prod_rule.segment_rule_type_code
           ,p_segment_rule_code       => l_prod_rule.segment_rule_code
           ,x_product_rule_name       => l_product_rule_name
           ,x_product_rule_type       => l_product_rule_type
           ,x_event_class_name        => l_event_class_name
           ,x_event_type_name         => l_event_type_name
           ,x_locking_status_flag     => l_locking_status_flag) THEN

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
   END LOOP;
   CLOSE c_prod_rules;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_mapping_sets_pkg.uncompile_definitions'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_prod_rules%ISOPEN THEN
         CLOSE c_prod_rules;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_prod_rules%ISOPEN THEN
         CLOSE c_prod_rules;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_mapping_sets_pkg.uncompile_definitions');

END uncompile_definitions;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
|                                                                       |
| Returns true if all the tads  using the mapping set are               |
| uncompiled                                                            |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_tran_acct_def
  (p_mapping_set_code                IN  VARCHAR2
  ,p_amb_context_code                IN  VARCHAR2
  ,p_trx_acct_def                    IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type               IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name     varchar2(240) := null;
   l_trx_acct_def         varchar2(80) := null;
   l_trx_acct_def_type    varchar2(80) := null;

   CURSOR c_prod_rules
   IS
   SELECT application_id, amb_context_code,
          segment_rule_type_code, segment_rule_code
     FROM xla_seg_rule_details d
    WHERE d.value_mapping_set_code    = p_mapping_set_code
      AND d.value_mapping_set_code is not null;


   l_prod_rule   c_prod_rules%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_mapping_sets_pkg.uncompile_tran_acct_def'   , 10);

   xla_utility_pkg.trace('mapping_set_code       = '||p_mapping_set_code     , 20);

   OPEN c_prod_rules;
   LOOP
   FETCH c_prod_rules
    INTO l_prod_rule;
   EXIT WHEN c_prod_rules%NOTFOUND or l_return=FALSE;
      IF xla_seg_rules_pkg.uncompile_tran_acct_def
           (p_application_id          => l_prod_rule.application_id
           ,p_amb_context_code        => l_prod_rule.amb_context_code
           ,p_segment_rule_type_code  => l_prod_rule.segment_rule_type_code
           ,p_segment_rule_code       => l_prod_rule.segment_rule_code
           ,p_application_name        => l_application_name
           ,p_trx_acct_def            => l_trx_acct_def
           ,p_trx_acct_def_type       => l_trx_acct_def_type) THEN

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
   END LOOP;
   CLOSE c_prod_rules;

   p_trx_acct_def := l_trx_acct_def;
   p_trx_acct_def_type := l_trx_acct_def_type;

   xla_utility_pkg.trace('< xla_mapping_sets_pkg.uncompile_tran_acct_def'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_prod_rules%ISOPEN THEN
         CLOSE c_prod_rules;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_prod_rules%ISOPEN THEN
         CLOSE c_prod_rules;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_mapping_sets_pkg.uncompile_tran_acct_def');

END uncompile_tran_acct_def;

END xla_mapping_sets_pkg;

/
