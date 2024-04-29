--------------------------------------------------------
--  DDL for Package Body XLA_LINE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_LINE_TYPES_PKG" AS
/* $Header: xlaamdlt.pkb 120.31 2006/02/15 19:51:51 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_line_types_pkg                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Line Types Package                                             |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    19-Oct-01 Wynne Chan     Modified for the Journal Line Definitions |
|    1-Mar-05  W. Shen        Modified for the ledger currency project  |
|    15-May-05 eklau          Modified for MPA project - 4262811.       |
|                                                                       |
+======================================================================*/

-------------------------------------------------------------------------------
-- declaring private package variables
-------------------------------------------------------------------------------
g_creation_date                   DATE := sysdate;
g_last_update_date                DATE := sysdate;
g_created_by                      INTEGER := xla_environment_pkg.g_usr_id;
g_last_update_login               INTEGER := xla_environment_pkg.g_login_id;
g_last_updated_by                 INTEGER := xla_environment_pkg.g_usr_id;

-------------------------------------------------------------------------------
-- declaring private package arrays
-------------------------------------------------------------------------------
TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;
TYPE t_array_id            IS TABLE OF NUMBER(15)   INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- forward declarion of private procedures and functions
-------------------------------------------------------------------------------

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Chk_line_accting_sources                                              |
|                                                                       |
| Returns false if accounting sources at the line level are invalid     |
|                                                                       |
+======================================================================*/
FUNCTION Chk_line_accting_sources
          (p_application_id              IN  NUMBER
          ,p_amb_context_code            IN  VARCHAR2
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_accounting_line_type_code   IN  VARCHAR2
          ,p_accounting_line_code        IN  VARCHAR2
          ,p_message_name                IN OUT NOCOPY VARCHAR2
          ,p_accounting_attribute_name   IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_line_type_details                                              |
|                                                                       |
| Deletes all details of the line type                                  |
|                                                                       |
+======================================================================*/

PROCEDURE delete_line_type_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
IS

   l_application_id          NUMBER(38)   := p_application_id;
   l_entity_code             VARCHAR2(30) := p_entity_code;
   l_event_class_code        VARCHAR2(30) := p_event_class_code;
   l_amb_context_code        VARCHAR2(30) := p_amb_context_code;
   l_accounting_line_code    VARCHAR2(30) := p_accounting_line_code;
   l_accounting_line_type_code VARCHAR2(1) := p_accounting_line_type_code;

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.delete_line_type_details'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code  = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code     , 20);

   xla_conditions_pkg.delete_condition
     (p_context                   => 'A'
     ,p_application_id            => l_application_id
     ,p_amb_context_code          => l_amb_context_code
     ,p_entity_code               => l_entity_code
     ,p_event_class_code          => l_event_class_code
     ,p_accounting_line_type_code => l_accounting_line_type_code
     ,p_accounting_line_code      => l_accounting_line_code);

   DELETE
   FROM xla_jlt_acct_attrs
  WHERE application_id            = p_application_id
    AND amb_context_code          = p_amb_context_code
    AND event_class_code          = p_event_class_code
    AND accounting_line_type_code = p_accounting_line_type_code
    AND accounting_line_code      = p_accounting_line_code;

   xla_utility_pkg.trace('< xla_line_types_pkg.delete_line_type_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.delete_line_type_details');

END delete_line_type_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_line_type_details                                                |
|                                                                       |
| Copies details of a segment rule into a new segment rule              |
|                                                                       |
+======================================================================*/

PROCEDURE copy_line_type_details
  (p_application_id                       IN NUMBER
  ,p_amb_context_code                     IN VARCHAR2
  ,p_entity_code                          IN VARCHAR2
  ,p_event_class_code                     IN VARCHAR2
  ,p_old_accting_line_type_code           IN VARCHAR2
  ,p_old_accounting_line_code             IN VARCHAR2
  ,p_new_accting_line_type_code           IN VARCHAR2
  ,p_new_accounting_line_code             IN VARCHAR2
  ,p_old_transaction_coa_id               IN NUMBER
  ,p_new_transaction_coa_id               IN NUMBER)
IS

   l_condition_id                    integer;
   l_creation_date                   DATE := sysdate;
   l_last_update_date                DATE := sysdate;
   l_created_by                      INTEGER := xla_environment_pkg.g_usr_id;
   l_last_update_login               INTEGER := xla_environment_pkg.g_login_id;
   l_last_updated_by                 INTEGER := xla_environment_pkg.g_usr_id;
   l_con_flexfield_segment_code      VARCHAR2(30);
   l_con_v_flexfield_segment_code    VARCHAR2(30);
   l_source_flex_appl_id             NUMBER(15);
   l_source_id_flex_code             VARCHAR2(30);
   l_value_source_flex_appl_id       NUMBER(15);
   l_value_source_id_flex_code       VARCHAR2(30);

   CURSOR c_conditions
   IS
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND entity_code               = p_entity_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_old_accting_line_type_code
      AND accounting_line_code      = p_old_accounting_line_code;

   l_condition        c_conditions%rowtype;

   CURSOR c_acct_sources
   IS
   SELECT accounting_attribute_code, source_application_id,
          source_type_code, source_code, event_class_default_flag
     FROM xla_jlt_acct_attrs
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_old_accting_line_type_code
      AND accounting_line_code      = p_old_accounting_line_code;

   l_acct_source        c_acct_sources%rowtype;

   CURSOR c_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_condition.source_application_id
      AND source_type_code = l_condition.source_type_code
      AND source_code      = l_condition.source_code;

   CURSOR c_value_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_condition.value_source_application_id
      AND source_type_code = l_condition.value_source_type_code
      AND source_code      = l_condition.value_source_code;

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.copy_line_type_details'   , 10);

   xla_utility_pkg.trace('application_id                = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code                   = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code              = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('old_accounting_line_type_code = '||p_old_accting_line_type_code    , 20);
   xla_utility_pkg.trace('old_accounting_line_code      = '||p_old_accounting_line_code     , 20);
   xla_utility_pkg.trace('new_accounting_line_type_code = '||p_new_accting_line_type_code    , 20);
   xla_utility_pkg.trace('new_accounting_line_code      = '||p_new_accounting_line_code     , 20);


      OPEN c_conditions;
      LOOP
         FETCH c_conditions
          INTO l_condition;
         EXIT WHEN c_conditions%notfound;

         IF l_condition.flexfield_segment_code is not null THEN

            OPEN c_source;
            FETCH c_source
             INTO l_source_flex_appl_id, l_source_id_flex_code;
            CLOSE c_source;

            IF l_source_flex_appl_id = 101 and l_source_id_flex_code = 'GL#' THEN

               IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                  l_con_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_condition.flexfield_segment_code);

                ELSE
                   l_con_flexfield_segment_code := l_condition.flexfield_segment_code;
                END IF;

            ELSE
               -- Other key flexfield segment
               l_con_flexfield_segment_code := l_condition.flexfield_segment_code;
            END IF;
         ELSE
            l_con_flexfield_segment_code := l_condition.flexfield_segment_code;
         END IF;

         -- check value_flexfield_segment_code
         IF l_condition.value_flexfield_segment_code is not null THEN

               OPEN c_value_source;
               FETCH c_value_source
                INTO l_value_source_flex_appl_id, l_value_source_id_flex_code;
               CLOSE c_value_source;

               IF l_value_source_flex_appl_id = 101 and l_value_source_id_flex_code = 'GL#' THEN

                  IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                     l_con_v_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_condition.value_flexfield_segment_code);

                  ELSE
                    l_con_v_flexfield_segment_code := l_condition.value_flexfield_segment_code;
                  END IF;

               ELSE
                  -- Other key flexfield segment
                  l_con_v_flexfield_segment_code := l_condition.value_flexfield_segment_code;
               END IF;
         ELSE
            l_con_v_flexfield_segment_code := l_condition.value_flexfield_segment_code;
         END IF;

         SELECT xla_conditions_s.nextval
           INTO l_condition_id
           FROM DUAL;

         INSERT INTO xla_conditions
           (condition_id
           ,user_sequence
           ,application_id
           ,amb_context_code
           ,entity_code
           ,event_class_code
           ,accounting_line_type_code
           ,accounting_line_code
           ,bracket_left_code
           ,bracket_right_code
           ,value_type_code
           ,source_application_id
           ,source_type_code
           ,source_code
           ,flexfield_segment_code
           ,value_flexfield_segment_code
           ,value_source_application_id
           ,value_source_type_code
           ,value_source_code
           ,value_constant
           ,line_operator_code
           ,logical_operator_code
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,independent_value_constant)
         VALUES
           (l_condition_id
           ,l_condition.user_sequence
           ,p_application_id
           ,p_amb_context_code
           ,p_entity_code
           ,p_event_class_code
           ,p_new_accting_line_type_code
           ,p_new_accounting_line_code
           ,l_condition.bracket_left_code
           ,l_condition.bracket_right_code
           ,l_condition.value_type_code
           ,l_condition.source_application_id
           ,l_condition.source_type_code
           ,l_condition.source_code
           ,l_con_flexfield_segment_code
           ,l_con_v_flexfield_segment_code
           ,l_condition.value_source_application_id
           ,l_condition.value_source_type_code
           ,l_condition.value_source_code
           ,l_condition.value_constant
           ,l_condition.line_operator_code
           ,l_condition.logical_operator_code
           ,l_creation_date
           ,l_created_by
           ,l_last_update_date
           ,l_last_updated_by
           ,l_last_update_login
           ,l_condition.independent_value_constant);

      END LOOP;
      CLOSE c_conditions;

      OPEN c_acct_sources;
      LOOP
         FETCH c_acct_sources
          INTO l_acct_source;
         EXIT WHEN c_acct_sources%notfound;

         INSERT INTO xla_jlt_acct_attrs
           (application_id
           ,amb_context_code
           ,event_class_code
           ,accounting_line_type_code
           ,accounting_line_code
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
         VALUES
           (p_application_id
           ,p_amb_context_code
           ,p_event_class_code
           ,p_new_accting_line_type_code
           ,p_new_accounting_line_code
           ,l_acct_source.accounting_attribute_code
           ,l_acct_source.source_application_id
           ,l_acct_source.source_type_code
           ,l_acct_source.source_code
           ,l_acct_source.event_class_default_flag
           ,l_creation_date
           ,l_created_by
           ,l_last_update_date
           ,l_last_updated_by
           ,l_last_update_login);
      END LOOP;
      CLOSE c_acct_sources;

   xla_utility_pkg.trace('< xla_line_types_pkg.copy_line_type_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_conditions%ISOPEN THEN
         CLOSE c_conditions;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_conditions%ISOPEN THEN
         CLOSE c_conditions;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.copy_line_type_details');

END copy_line_type_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| line_type_in_use                                                      |
|                                                                       |
| Returns true if the line type is in use by a line definition          |
|                                                                       |
+======================================================================*/

FUNCTION line_type_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return              BOOLEAN;
   l_exist               VARCHAR2(1);

   CURSOR c_assignment_exist
   IS
   SELECT event_type_code, line_definition_owner_code, line_definition_code
     FROM xla_line_defn_jlt_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_accounting_line_type_code
      AND accounting_line_code      = p_accounting_line_code;

   l_assignment_exist         c_assignment_exist%rowtype;

   CURSOR c_active_assignment_exist
   IS
   SELECT event_type_code, line_definition_owner_code, line_definition_code
     FROM xla_line_defn_jlt_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_accounting_line_type_code
      AND accounting_line_code      = p_accounting_line_code
      AND active_flag               = 'Y';

   l_active_assignment_exist         c_active_assignment_exist%rowtype;

   CURSOR c_mpa_assignment_exist
   IS
   SELECT event_type_code, line_definition_owner_code, line_definition_code,
          accounting_line_type_code, accounting_line_code
     FROM xla_mpa_jlt_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND mpa_accounting_line_type_code = p_accounting_line_type_code
      AND mpa_accounting_line_code      = p_accounting_line_code;

   l_mpa_assignment_exist         c_mpa_assignment_exist%rowtype;

   CURSOR c_mpa_active_assignment_exist
   IS
   SELECT mpa_jlt.event_type_code,
          mpa_jlt.line_definition_owner_code,
	  mpa_jlt.line_definition_code,
          mpa_jlt.accounting_line_type_code,
	  mpa_jlt.accounting_line_code
     FROM xla_mpa_jlt_assgns mpa_jlt,
	      xla_line_defn_jlt_assgns jlt
    WHERE mpa_jlt.application_id            = p_application_id
      AND mpa_jlt.amb_context_code          = p_amb_context_code
      AND mpa_jlt.event_class_code          = p_event_class_code
      AND mpa_jlt.mpa_accounting_line_type_code = p_accounting_line_type_code
      AND mpa_jlt.mpa_accounting_line_code      = p_accounting_line_code
	  and mpa_jlt.application_id            = jlt.application_id
	  and mpa_jlt.amb_context_code          = jlt.amb_context_code
	  and mpa_jlt.event_class_code          = jlt.event_class_code
	  and mpa_jlt.line_definition_owner_code = jlt.line_definition_owner_code
	  and mpa_jlt.line_definition_code      = jlt.line_definition_code
	  and mpa_jlt.accounting_line_type_code = jlt.accounting_line_type_code
	  and mpa_jlt.accounting_line_code      = jlt.accounting_line_code
	  and jlt.active_flag                   = 'Y';

   l_mpa_active_assignment_exist         c_mpa_active_assignment_exist%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.line_type_in_use'   , 10);

   xla_utility_pkg.trace('event                   = '||p_event  , 20);
   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('amb_context_code      = '||p_amb_context_code  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code     , 20);

   IF p_event in ('DELETE','UPDATE') THEN
      OPEN c_assignment_exist;
      FETCH c_assignment_exist
       INTO l_assignment_exist;
      IF c_assignment_exist%found then

         xla_line_definitions_pvt.get_line_definition_info
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_event_class_code           => p_event_class_code
           ,p_event_type_code            => l_assignment_exist.event_type_code
           ,p_line_definition_owner_code => l_assignment_exist.line_definition_owner_code
           ,p_line_definition_code       => l_assignment_exist.line_definition_code
           ,x_line_definition_owner      => x_line_definition_owner
           ,x_line_definition_name       => x_line_definition_name);

         l_return := TRUE;
      ELSE
         OPEN  c_mpa_assignment_exist;
         FETCH c_mpa_assignment_exist
          INTO l_mpa_assignment_exist;
         IF c_mpa_assignment_exist%found then

            xla_line_definitions_pvt.get_line_definition_info
              (p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => l_mpa_assignment_exist.event_type_code
              ,p_line_definition_owner_code => l_mpa_assignment_exist.line_definition_owner_code
              ,p_line_definition_code       => l_mpa_assignment_exist.line_definition_code
              ,x_line_definition_owner      => x_line_definition_owner
              ,x_line_definition_name       => x_line_definition_name);

             l_return := TRUE;
         ELSE
             l_return := FALSE;
         END IF;
	 CLOSE c_mpa_assignment_exist;
      END IF;
      CLOSE c_assignment_exist;

   ELSIF p_event = ('DISABLE') THEN
      OPEN c_active_assignment_exist;
      FETCH c_active_assignment_exist
       INTO l_active_assignment_exist;
      IF c_active_assignment_exist%found then

         xla_line_definitions_pvt.get_line_definition_info
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_event_class_code           => p_event_class_code
           ,p_event_type_code            => l_active_assignment_exist.event_type_code
           ,p_line_definition_owner_code => l_active_assignment_exist.line_definition_owner_code
           ,p_line_definition_code       => l_active_assignment_exist.line_definition_code
           ,x_line_definition_owner      => x_line_definition_owner
           ,x_line_definition_name       => x_line_definition_name);

         l_return := TRUE;
      ELSE
         OPEN  c_mpa_active_assignment_exist;
         FETCH c_mpa_active_assignment_exist
          INTO l_mpa_active_assignment_exist;
         IF c_mpa_active_assignment_exist%found then

            xla_line_definitions_pvt.get_line_definition_info
              (p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => l_mpa_active_assignment_exist.event_type_code
              ,p_line_definition_owner_code => l_mpa_active_assignment_exist.line_definition_owner_code
              ,p_line_definition_code       => l_mpa_active_assignment_exist.line_definition_code
              ,x_line_definition_owner      => x_line_definition_owner
              ,x_line_definition_name       => x_line_definition_name);

            l_return := TRUE;
         ELSE
            l_return := FALSE;
         END IF;
	 CLOSE c_mpa_active_assignment_exist;
      END IF;
      CLOSE c_active_assignment_exist;

   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Invalid event passed'
        ,'LOCATION' ,'xla_line_types_pkg.line_type_in_use');

   END IF;

   xla_utility_pkg.trace('< xla_line_types_pkg.line_type_in_use'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_assignment_exist%ISOPEN THEN
         CLOSE c_assignment_exist;
      END IF;
      IF c_active_assignment_exist%ISOPEN THEN
         CLOSE c_active_assignment_exist;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_assignment_exist%ISOPEN THEN
         CLOSE c_assignment_exist;
      END IF;
      IF c_active_assignment_exist%ISOPEN THEN
         CLOSE c_active_assignment_exist;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.line_type_in_use');

END line_type_in_use;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| line_type_is_invalid                                                  |
|                                                                       |
| Returns true if the line type is invalid                              |
|                                                                       |
+======================================================================*/

FUNCTION line_type_is_invalid
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2
  ,p_accounting_attribute_name        IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return                  BOOLEAN;
   l_exist                   VARCHAR2(1);
   l_segment_rule_type_code  VARCHAR2(1);
   l_segment_rule_code       VARCHAR2(30);
   l_description_type_code   VARCHAR2(1);
   l_description_code        VARCHAR2(30);
   l_message_name            VARCHAR2(30);
   l_accounting_attribute_name VARCHAR2(80);
   l_count                   NUMBER(10);
   l_application_id          NUMBER(38)   := p_application_id;
   l_entity_code             VARCHAR2(30) := p_entity_code;
   l_event_class_code        VARCHAR2(30) := p_event_class_code;
   l_amb_context_code        VARCHAR2(30) := p_amb_context_code;
   l_accounting_line_code    VARCHAR2(30) := p_accounting_line_code;
   l_accounting_line_type_code VARCHAR2(1) := p_accounting_line_type_code;

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.line_type_is_invalid'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code  = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code     , 20);

      --
      -- check if condition is invalid
      --
         IF xla_conditions_pkg.acct_condition_is_invalid
              (p_application_id            => l_application_id
              ,p_amb_context_code          => l_amb_context_code
              ,p_entity_code               => l_entity_code
              ,p_event_class_code          => l_event_class_code
              ,p_accounting_line_type_code => l_accounting_line_type_code
              ,p_accounting_line_code      => l_accounting_line_code
              ,p_message_name              => l_message_name)
         THEN
            p_message_name              := l_message_name;
            p_accounting_attribute_name := NULL;
            l_return                    := TRUE;
         ELSE
            p_message_name              := NULL;
            p_accounting_attribute_name := NULL;
            l_return                    := FALSE;
         END IF;

      IF l_return = FALSE THEN
         IF NOT chk_line_accting_sources
              (p_application_id            => l_application_id
              ,p_amb_context_code          => l_amb_context_code
              ,p_entity_code               => l_entity_code
              ,p_event_class_code          => l_event_class_code
              ,p_accounting_line_type_code => l_accounting_line_type_code
              ,p_accounting_line_code      => l_accounting_line_code
              ,p_message_name              => l_message_name
              ,p_accounting_attribute_name => l_accounting_attribute_name)
         THEN
            p_message_name              := l_message_name;
            p_accounting_attribute_name := l_accounting_attribute_name;
            l_return                    := TRUE;
         ELSE
            p_message_name              := NULL;
            p_accounting_attribute_name := NULL;
            l_return                    := FALSE;
         END IF;
      END IF;

   xla_utility_pkg.trace('p_message_name       = '||p_message_name     , 20);
   xla_utility_pkg.trace('< xla_line_types_pkg.line_type_is_invalid'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.line_type_is_invalid');

END line_type_is_invalid;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| line_type_is_locked                                                   |
|                                                                       |
| Returns true if the line type is used by a frozen line definition     |
|                                                                       |
+======================================================================*/

FUNCTION line_type_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_entity_code                      IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN;
   l_exist    VARCHAR2(1);

   CURSOR c_frozen_assignment_exist
   IS
   SELECT 'x'
     FROM xla_line_defn_jlt_assgns s
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_accounting_line_type_code
      AND accounting_line_code      = p_accounting_line_code
      AND exists      (SELECT 'x'
                         FROM xla_aad_line_defn_assgns a
                             ,xla_prod_acct_headers    h
                        WHERE h.application_id             = a.application_id
                          AND h.amb_context_code           = a.amb_context_code
                          AND h.product_rule_type_code     = a.product_rule_type_code
                          AND h.product_rule_code          = a.product_rule_code
                          AND h.event_class_code           = a.event_class_code
                          AND h.event_type_code            = a.event_type_code
                          AND h.locking_status_flag        = 'Y'
                          AND a.application_id             = s.application_id
                          AND a.amb_context_code           = s.amb_context_code
                          AND a.event_class_code           = s.event_class_code
                          AND a.event_type_code            = s.event_type_code
                          AND a.line_definition_owner_code = s.line_definition_owner_code
                          AND a.line_definition_code       = s.line_definition_code);

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.line_type_is_locked'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code  = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code     , 20);

      OPEN c_frozen_assignment_exist;
      FETCH c_frozen_assignment_exist
       INTO l_exist;
      IF c_frozen_assignment_exist%found then
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_frozen_assignment_exist;

   xla_utility_pkg.trace('< xla_line_types_pkg.line_type_is_locked'    , 10);

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
        (p_location   => 'xla_line_types_pkg.line_type_is_locked');

END line_type_is_locked;

/* ---------------------------------------------------------------------
  This is a public procedure. It is used to delete the assignments of
  those accounting attributes that is not needed for a gain/loss line
  type. It is called when user change a credit or debit line type to
  gain/loss line type. Some accounting attribute assignments existed
  for the line type should be deleted
--------------------------------------------------------------------- */
PROCEDURE delete_non_gain_acct_attrs(
p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
IS
BEGIN
   xla_utility_pkg.trace('> xla_line_types_pkg.delete_non_gain_acct_attrs'   , 10);   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('amb_context_code      = '||p_amb_context_code  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code , 20);

  delete xla_jlt_acct_attrs
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code
     AND accounting_attribute_code in (
                                     'ENTERED_CURRENCY_AMOUNT'
                                     ,'ENTERED_CURRENCY_CODE'
                                     ,'EXCHANGE_RATE_TYPE'
                                     ,'EXCHANGE_DATE'
                                     ,'EXCHANGE_RATE'
                                      );
   xla_utility_pkg.trace('< xla_line_types_pkg.delete_non_gain_acct_attrs'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.delete_non_gain_acct_attrs');
END delete_non_gain_acct_attrs;


/* ---------------------------------------------------------------------
  This is a public procedure. It is insert the assignments of
  those accounting attributes that is not needed for a gain/loss line
  type but needed for normal debit/credit line type. It is called when
  user change a gain/loss line type to credit or debit line type. Gain/loss
  line type don't have the assignment for some accounting attributes. This
  procedure will insert the assignment for those attributes
--------------------------------------------------------------------- */
PROCEDURE insert_non_gain_acct_attrs(
p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
IS
    CURSOR c_attr_source
    IS
    SELECT e.accounting_attribute_code, e.source_application_id,
           e.source_type_code, e.source_code
      FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.default_flag              = 'Y'
       AND e.accounting_attribute_code = l.accounting_attribute_code
       AND l.assignment_level_code     = 'EVT_CLASS_JLT'
       AND e.accounting_attribute_code in (
                           'ENTERED_CURRENCY_AMOUNT'
                           ,'ENTERED_CURRENCY_CODE'
                           ,'EXCHANGE_RATE_TYPE'
                           ,'EXCHANGE_DATE'
                           ,'EXCHANGE_RATE');

   l_arr_acct_attribute_code         t_array_codes;
   l_arr_source_application_id       t_array_id;
   l_arr_source_type_code            t_array_codes;
   l_arr_source_code                 t_array_codes;

BEGIN
   xla_utility_pkg.trace('> xla_line_types_pkg.insert_non_gain_acct_attrs'   , 10);
   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('amb_context_code      = '||p_amb_context_code  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code , 20);

   INSERT into xla_jlt_acct_attrs(
      application_id
     ,amb_context_code
     ,event_class_code
     ,accounting_line_type_code
     ,accounting_line_code
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
        ,p_event_class_code
        ,p_accounting_line_type_code
        ,p_accounting_line_code
        ,e.accounting_attribute_code
        ,null
        ,null
        ,null
        ,'Y'
        ,g_creation_date
        ,g_created_by
        ,g_last_update_date
        ,g_last_updated_by
        ,g_last_update_login
      FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.accounting_attribute_code = l.accounting_attribute_code
       AND l.assignment_level_code     = 'EVT_CLASS_JLT'
       AND e.accounting_attribute_code in (
                           'ENTERED_CURRENCY_AMOUNT'
                           ,'ENTERED_CURRENCY_CODE'
                           ,'EXCHANGE_RATE_TYPE'
                           ,'EXCHANGE_DATE'
                           ,'EXCHANGE_RATE')
                           );

   -- Update the default source mappings on the JLT for
   -- the accounting attributes just inserted
   OPEN c_attr_source;
   FETCH c_attr_source
   BULK COLLECT INTO l_arr_acct_attribute_code, l_arr_source_application_id,
                     l_arr_source_type_code, l_arr_source_code;

   IF l_arr_acct_attribute_code.COUNT > 0 THEN
     FORALL i IN l_arr_acct_attribute_code.FIRST..l_arr_acct_attribute_code.LAST
       UPDATE xla_jlt_acct_attrs
          SET source_application_id     = l_arr_source_application_id(i)
             ,source_type_code          = l_arr_source_type_code(i)
             ,source_code               = l_arr_source_code(i)
        WHERE application_id            = p_application_id
          AND amb_context_code          = p_amb_context_code
          AND event_class_code          = p_event_class_code
          AND accounting_line_type_code = p_accounting_line_type_code
          AND accounting_line_code      = p_accounting_line_code
          AND accounting_attribute_code = l_arr_acct_attribute_code(i)
          AND event_class_default_flag  = 'Y';
   END IF;
   CLOSE c_attr_source;

   xla_utility_pkg.trace('< xla_line_types_pkg.insert_non_gain_acct_attrs'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.insert_non_gain_acct_attrs');

END insert_non_gain_acct_attrs;

/* ---------------------------------------------------------------------
  This is a public procedure. It checks if assignment to some accounting
  attributes exists at the jlt level. For gain/loss line type, some
  accounting attributes are not needed. This function is used for that
  purpose
--------------------------------------------------------------------- */
FUNCTION non_gain_acct_attrs_exists
(p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2)
return boolean
is
l_temp VARCHAR2(1);
l_result boolean;
cursor c_non_gain_acct_attrs is
  SELECT 'x'
    FROM xla_jlt_acct_attrs
   WHERE application_id            = p_application_id
     AND amb_context_code          = p_amb_context_code
     AND event_class_code          = p_event_class_code
     AND accounting_line_type_code = p_accounting_line_type_code
     AND accounting_line_code      = p_accounting_line_code
     AND accounting_attribute_code in (
                                     'ENTERED_CURRENCY_AMOUNT'
                                     ,'ENTERED_CURRENCY_CODE'
                                     ,'EXCHANGE_RATE_TYPE'
                                     ,'EXCHANGE_DATE'
                                     ,'EXCHANGE_RATE'
                                      );
BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.non_gain_acct_attrs_exists'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('amb_context_code      = '||p_amb_context_code  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code , 20);

  open c_non_gain_acct_attrs;
  fetch c_non_gain_acct_attrs into l_temp;
  IF c_non_gain_acct_attrs%notfound THEN
    l_result := false;
  ELSE
    l_result := true;
  END IF;

  return l_result;

   xla_utility_pkg.trace('< xla_line_types_pkg.non_gain_acct_attrs_exists'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.non_gain_acct_attrs_exists');
END non_gain_acct_attrs_exists;



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
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_side_code                        IN VARCHAR2
  ,p_business_method_code             IN VARCHAR2
)
IS

   -- Array Declaration
   l_arr_acct_attribute_code         t_array_codes;
   l_arr_source_application_id       t_array_id;
   l_arr_source_type_code            t_array_codes;
   l_arr_source_code                 t_array_codes;

   l_arr_p_acct_attribute_code         t_array_codes;
   l_arr_p_source_application_id       t_array_id;
   l_arr_p_source_type_code            t_array_codes;
   l_arr_p_source_code                 t_array_codes;

   -- Local Variables
   l_exist    VARCHAR2(1);

    CURSOR c_acct_sources
    IS
    SELECT 'x'
      FROM xla_jlt_acct_attrs
     WHERE application_id            = p_application_id
       AND amb_context_code          = p_amb_context_code
       AND event_class_code          = p_event_class_code
       AND accounting_line_type_code = p_accounting_line_type_code
       AND accounting_line_code      = p_accounting_line_code;

    CURSOR c_attr_source
    IS
    SELECT e.accounting_attribute_code, e.source_application_id,
           e.source_type_code, e.source_code
      FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.default_flag              = 'Y'
       AND e.accounting_attribute_code = l.accounting_attribute_code
       AND l.assignment_level_code     = 'EVT_CLASS_JLT';

    CURSOR c_prior_entry_source
    IS
    SELECT e.accounting_attribute_code, e.source_application_id,
           e.source_type_code, e.source_code
      FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.default_flag              = 'Y'
       AND e.accounting_attribute_code = l.accounting_attribute_code
       AND l.assignment_level_code     = 'EVT_CLASS_JLT'
       AND l.inherited_flag            = 'N';

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.create_accounting_attributes'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code, 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code     , 20);

        OPEN c_acct_sources;
        FETCH c_acct_sources
         INTO l_exist;
        IF c_acct_sources%notfound THEN

           -- Insert accounting attributes of level 'EVT_CLASS_JLT' and 'JLT_ONLY'
           -- with null source mapping
           IF p_side_code = 'G' THEN
             INSERT into xla_jlt_acct_attrs(
                application_id
               ,amb_context_code
               ,event_class_code
               ,accounting_line_type_code
               ,accounting_line_code
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
                  ,p_event_class_code
                  ,p_accounting_line_type_code
                  ,p_accounting_line_code
                  ,e.accounting_attribute_code
                  ,null
                  ,null
                  ,null
                  ,'Y'
                  ,g_creation_date
                  ,g_created_by
                  ,g_last_update_date
                  ,g_last_updated_by
                  ,g_last_update_login
                FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
               WHERE e.application_id            = p_application_id
                 AND e.event_class_code          = p_event_class_code
                 AND e.accounting_attribute_code = l.accounting_attribute_code
                 AND l.assignment_level_code     = 'EVT_CLASS_JLT'
                 AND e.accounting_attribute_code not in (
                                     'ENTERED_CURRENCY_AMOUNT'
                                     ,'ENTERED_CURRENCY_CODE'
                                     ,'EXCHANGE_RATE_TYPE'
                                     ,'EXCHANGE_DATE'
                                     ,'EXCHANGE_RATE')
                 AND l.assignment_group_code NOT IN ('MULTIPERIOD_CODE'
                                                    ,'BUSINESS_FLOW')
              UNION
              SELECT distinct p_application_id
                  ,p_amb_context_code
                  ,p_event_class_code
                  ,p_accounting_line_type_code
                  ,p_accounting_line_code
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
               WHERE l.assignment_level_code     = 'JLT_ONLY'
                                     );
           ELSE
             INSERT into xla_jlt_acct_attrs(
                application_id
               ,amb_context_code
               ,event_class_code
               ,accounting_line_type_code
               ,accounting_line_code
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
                  ,p_event_class_code
                  ,p_accounting_line_type_code
                  ,p_accounting_line_code
                  ,e.accounting_attribute_code
                  ,null
                  ,null
                  ,null
                  ,'Y'
                  ,g_creation_date
                  ,g_created_by
                  ,g_last_update_date
                  ,g_last_updated_by
                  ,g_last_update_login
                FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
               WHERE e.application_id            = p_application_id
                 AND e.event_class_code          = p_event_class_code
                 AND e.accounting_attribute_code = l.accounting_attribute_code
                 AND l.assignment_level_code     = 'EVT_CLASS_JLT'
              UNION
              SELECT distinct p_application_id
                  ,p_amb_context_code
                  ,p_event_class_code
                  ,p_accounting_line_type_code
                  ,p_accounting_line_code
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
               WHERE l.assignment_level_code     = 'JLT_ONLY');
           END IF;

           IF p_business_method_code = 'PRIOR_ENTRY' THEN
               -- Update the default source mappings on the JLT for the accounting
               -- attributes that are not inherited

               OPEN c_prior_entry_source;
               FETCH c_prior_entry_source
               BULK COLLECT INTO l_arr_p_acct_attribute_code, l_arr_p_source_application_id,
                                 l_arr_p_source_type_code, l_arr_p_source_code;

               IF l_arr_p_acct_attribute_code.COUNT > 0 THEN
                  FORALL i IN l_arr_p_acct_attribute_code.FIRST..l_arr_p_acct_attribute_code.LAST

                  UPDATE xla_jlt_acct_attrs
                     SET source_application_id     = l_arr_p_source_application_id(i)
                        ,source_type_code          = l_arr_p_source_type_code(i)
                        ,source_code               = l_arr_p_source_code(i)
                   WHERE application_id            = p_application_id
                     AND amb_context_code          = p_amb_context_code
                     AND event_class_code          = p_event_class_code
                     AND accounting_line_type_code = p_accounting_line_type_code
                     AND accounting_line_code      = p_accounting_line_code
                     AND accounting_attribute_code = l_arr_p_acct_attribute_code(i)
                     AND event_class_default_flag  = 'Y';
                END IF;
                CLOSE c_prior_entry_source;

           -- Not a prior entry jlt
           ELSE

               -- Update the default source mappings on the JLT for all accounting attributes
               OPEN c_attr_source;
               FETCH c_attr_source
               BULK COLLECT INTO l_arr_acct_attribute_code, l_arr_source_application_id,
                                 l_arr_source_type_code, l_arr_source_code;

               IF l_arr_acct_attribute_code.COUNT > 0 THEN
                  FORALL i IN l_arr_acct_attribute_code.FIRST..l_arr_acct_attribute_code.LAST

                  UPDATE xla_jlt_acct_attrs
                     SET source_application_id     = l_arr_source_application_id(i)
                        ,source_type_code          = l_arr_source_type_code(i)
                        ,source_code               = l_arr_source_code(i)
                   WHERE application_id            = p_application_id
                     AND amb_context_code          = p_amb_context_code
                     AND event_class_code          = p_event_class_code
                     AND accounting_line_type_code = p_accounting_line_type_code
                     AND accounting_line_code      = p_accounting_line_code
                     AND accounting_attribute_code = l_arr_acct_attribute_code(i)
                     AND event_class_default_flag  = 'Y';
               END IF;
               CLOSE c_attr_source;
           END IF;
        END IF;
        CLOSE c_acct_sources;

   xla_utility_pkg.trace('< xla_line_types_pkg.create_accounting_attributes'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.create_accounting_attributes');

END create_accounting_attributes;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if all the application accounting definitions and        |
| journal line definitions using this journal line type are uncompiled  |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN := TRUE;
   l_application_name     varchar2(240) := null;
   l_product_rule_name    varchar2(80)  := null;
   l_product_rule_type    varchar2(80)  := null;
   l_event_class_name     varchar2(80)  := null;
   l_event_type_name      varchar2(80)  := null;
   l_locking_status_flag  varchar2(1)   := null;

   CURSOR c_locked_aads IS
    SELECT xpa.entity_code
         , xpa.event_class_code
         , xpa.event_type_code
         , xpa.product_rule_type_code
         , xpa.product_rule_code
         , xpa.locking_status_flag
         , xpa.validation_status_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_aad_line_defn_assgns xal
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = xal.application_id
       AND xpa.amb_context_code           = xal.amb_context_code
       AND xpa.product_rule_type_code     = xal.product_rule_type_code
       AND xpa.product_rule_code          = xal.product_rule_code
       AND xpa.event_class_code           = xal.event_class_code
       AND xpa.event_type_code            = xal.event_type_code
       AND xal.application_id             = xjl.application_id
       AND xal.amb_context_code           = xjl.amb_context_code
       AND xal.event_class_code           = xjl.event_class_code
       AND xal.event_type_code            = xjl.event_type_code
       AND xal.line_definition_owner_code = xjl.line_definition_owner_code
       AND xal.line_definition_code       = xjl.line_definition_code
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.accounting_line_type_code  = p_accounting_line_type_code
       AND xjl.accounting_line_code       = p_accounting_line_code
       FOR UPDATE NOWAIT;

  CURSOR c_update_aads IS
    SELECT xal.event_class_code
         , xal.product_rule_type_code
         , xal.product_rule_code
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_aad_line_defn_assgns xal
          ,xla_prod_acct_headers    xpa
          ,xla_product_rules_b      xpr
     WHERE xpr.application_id             = xpa.application_id
       AND xpr.amb_context_code           = xpa.amb_context_code
       AND xpr.product_rule_type_code     = xpa.product_rule_type_code
       AND xpr.product_rule_code          = xpa.product_rule_code
       AND xpa.application_id             = xal.application_id
       AND xpa.amb_context_code           = xal.amb_context_code
       AND xpa.event_class_code           = xal.event_class_code
       AND xpa.event_type_code            = xal.event_type_code
       AND xal.application_id             = xjl.application_id
       AND xal.amb_context_code           = xjl.amb_context_code
       AND xal.event_class_code           = xjl.event_class_code
       AND xal.event_type_code            = xjl.event_type_code
       AND xal.line_definition_owner_code = xjl.line_definition_owner_code
       AND xal.line_definition_code       = xjl.line_definition_code
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.event_class_code           = p_event_class_code
       AND xjl.accounting_line_type_code  = p_accounting_line_type_code
       AND xjl.accounting_line_code       = p_accounting_line_code;

  l_event_class_codes       t_array_codes;
  l_product_rule_type_codes t_array_type_codes;
  l_product_rule_codes      t_array_codes;
BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.uncompile_definitions'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('amb_context_code      = '||p_amb_context_code  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code     , 20);

   l_return := TRUE;

   FOR l_lock_aad IN c_locked_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => p_amb_context_code
           ,p_product_rule_type_code  => l_lock_aad.product_rule_type_code
           ,p_product_rule_code       => l_lock_aad.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

       xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_class_name        => l_event_class_name);

       xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_lock_aad.entity_code
           ,p_event_class_code        => l_lock_aad.event_class_code
           ,p_event_type_code         => l_lock_aad.event_type_code
           ,p_event_type_name         => l_event_type_name);

       l_locking_status_flag        := l_lock_aad.locking_status_flag;
       l_return := FALSE;
       EXIT;
     END IF;
  END LOOP;

  IF (l_return) THEN

    UPDATE xla_line_definitions_b xld
       SET validation_status_code = 'N'
     WHERE xld.application_id         = p_application_id
       AND xld.amb_context_code       = p_amb_context_code
       AND xld.event_class_code       = p_event_class_code
       AND xld.validation_status_code <> 'N'
       AND EXISTS
           (SELECT 1
              FROM xla_line_defn_jlt_assgns xjl
             WHERE xjl.application_id             = p_application_id
               AND xjl.amb_context_code           = p_amb_context_code
               AND xjl.event_class_code           = p_event_class_code
               AND xjl.accounting_line_type_code  = p_accounting_line_type_code
               AND xjl.accounting_line_code       = p_accounting_line_code
               AND xjl.event_type_code            = xld.event_type_code
               AND xjl.line_definition_owner_code = xld.line_definition_owner_code
               AND xjl.line_definition_code       = xld.line_definition_code);

    OPEN c_update_aads;
    FETCH c_update_aads BULK COLLECT INTO l_event_class_codes
                                           ,l_product_rule_type_codes
                                           ,l_product_rule_codes;
    CLOSE c_update_aads;

    IF (l_event_class_codes.count > 0) THEN

      FORALL i IN 1..l_event_class_codes.LAST
        UPDATE xla_product_rules_b xpr
           SET compile_status_code    = 'N'
             , updated_flag           = 'Y'
             , last_update_date       = sysdate
             , last_updated_by        = xla_environment_pkg.g_usr_id
             , last_update_login      = xla_environment_pkg.g_login_id
         WHERE application_id         = p_application_id
           AND amb_context_code       = p_amb_context_code
           AND product_rule_type_code = l_product_rule_type_codes(i)
           AND product_rule_code      = l_product_rule_codes(i)
           AND (compile_status_code   <> 'N' OR
                updated_flag          <> 'Y');

       FORALL i IN 1..l_event_class_codes.LAST
        UPDATE xla_prod_acct_headers xpa
           SET validation_status_code = 'N'
             , last_update_date       = sysdate
             , last_updated_by        = xla_environment_pkg.g_usr_id
             , last_update_login      = xla_environment_pkg.g_login_id
         WHERE application_id         = p_application_id
           AND amb_context_code       = p_amb_context_code
           AND event_class_code       = l_event_class_codes(i)
           AND product_rule_type_code = l_product_rule_type_codes(i)
           AND product_rule_code      = l_product_rule_codes(i)
           AND validation_status_code <> 'N';

    END IF;

    UPDATE xla_appli_amb_contexts
       SET updated_flag      = 'Y'
         , last_update_date  = sysdate
         , last_updated_by   = xla_environment_pkg.g_usr_id
         , last_update_login = xla_environment_pkg.g_login_id
     WHERE application_id    = p_application_id
       AND amb_context_code  = p_amb_context_code
       AND updated_flag      <> 'Y';

   END IF;

   x_product_rule_name   := l_product_rule_name;
   x_product_rule_type   := l_product_rule_type;
   x_event_class_name    := l_event_class_name;
   x_event_type_name     := l_event_type_name;
   x_locking_status_flag := l_locking_status_flag;

   xla_utility_pkg.trace('< xla_line_types_pkg.uncompile_definitions'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_update_aads%ISOPEN THEN
         CLOSE c_update_aads;
      END IF;
      IF c_locked_aads%ISOPEN THEN
         CLOSE c_locked_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_update_aads%ISOPEN THEN
         CLOSE c_update_aads;
      END IF;
      IF c_locked_aads%ISOPEN THEN
         CLOSE c_locked_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.uncompile_definitions');

END uncompile_definitions;

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

   xla_utility_pkg.trace('> xla_line_types_pkg.get_default_attr_assignment'   , 10);

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

   xla_utility_pkg.trace('< xla_line_types_pkg.get_default_attr_assignment'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.get_default_attr_assignment');

END get_default_attr_assignment;

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| Chk_line_accting_sources                                              |
|                                                                       |
| Returns false if accounting sources at the line level are invalid     |
|                                                                       |
+======================================================================*/
FUNCTION Chk_line_accting_sources
          (p_application_id              IN  NUMBER
          ,p_amb_context_code            IN  VARCHAR2
          ,p_entity_code                 IN  VARCHAR2
          ,p_event_class_code            IN  VARCHAR2
          ,p_accounting_line_type_code   IN  VARCHAR2
          ,p_accounting_line_code        IN  VARCHAR2
          ,p_message_name                IN OUT NOCOPY VARCHAR2
          ,p_accounting_attribute_name   IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return                      BOOLEAN      := TRUE;
   l_exist                       VARCHAR2(1)  := null;
   l_application_id              NUMBER(38)   := p_application_id;
   l_amb_context_code            VARCHAR2(30) := p_amb_context_code;
   l_entity_code                 VARCHAR2(30) := p_entity_code;
   l_event_class_code            VARCHAR2(30) := p_event_class_code;
   l_accounting_line_type_code   VARCHAR2(1) := p_accounting_line_type_code;
   l_accounting_line_code        VARCHAR2(30) := p_accounting_line_code;
   l_count                       NUMBER(38);
   l_source_name                 VARCHAR2(80) := null;
   l_source_type                 VARCHAR2(80) := null;
   l_meaning                     VARCHAR2(80) := null;
   l_accounting_attribute_name   VARCHAR2(80) := null;
   l_business_method_code        VARCHAR2(30);

   -- Get the business flow method for the JLT
   CURSOR c_business_method
   IS
   SELECT business_method_code
     FROM xla_acct_line_types_b
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_accounting_line_type_code
      AND accounting_line_code      = p_accounting_line_code;

   -- Get all mapping groups that have accounting sources mapped for the line type
   CURSOR c_mapping_group
   IS
   SELECT distinct s.assignment_group_code
     FROM xla_acct_attributes_b s
    WHERE s.assignment_group_code     IS NOT NULL
      AND EXISTS (SELECT 'x'
                    FROM xla_jlt_acct_attrs a
                   WHERE a.application_id            = p_application_id
                     AND a.amb_context_code          = p_amb_context_code
                     AND a.event_class_code          = p_event_class_code
                     AND a.accounting_line_type_code = p_accounting_line_type_code
                     AND a.accounting_line_code      = p_accounting_line_code
                     AND a.accounting_attribute_code = s.accounting_attribute_code
                     AND a.source_code               IS NOT NULL
                   UNION
                  SELECT 'x'
                    FROM xla_evt_class_acct_attrs_fvl e
                   WHERE e.application_id            = p_application_id
                     AND e.event_class_code          = p_event_class_code
                     AND e.accounting_attribute_code = s.accounting_attribute_code
                     AND e.assignment_level_code     = 'EVT_CLASS_ONLY'
                     AND e.default_flag              = 'Y');

   l_mapping_group    c_mapping_group%rowtype;

   -- Get all accounting attributes required within the group that are not
   -- mapped for the line type
   CURSOR c_group_accting_sources
   IS
   SELECT s.name
     FROM xla_acct_attributes_vl s
    WHERE assignment_level_code    = 'EVT_CLASS_JLT'
      AND assignment_required_code = 'G'
      AND assignment_group_code    = l_mapping_group.assignment_group_code
      AND exists     (SELECT 'x'
                        FROM xla_jlt_acct_attrs a
                       WHERE a.application_id            = p_application_id
                         AND a.amb_context_code          = p_amb_context_code
                         AND a.event_class_code          = p_event_class_code
                         AND a.accounting_line_type_code = p_accounting_line_type_code
                         AND a.accounting_line_code      = p_accounting_line_code
                         AND a.source_code               IS NULL
                         AND a.accounting_attribute_code = s.accounting_attribute_code);

   -- Get all accounting attributes required within the group that are not
   -- mapped for the line type and have the inherited flag set to 'N'
   CURSOR c_prior_entry
   IS
   SELECT s.name
     FROM xla_acct_attributes_vl s
    WHERE assignment_level_code    = 'EVT_CLASS_JLT'
      AND assignment_required_code = 'G'
      AND inherited_flag           = 'N'
      AND assignment_group_code    = l_mapping_group.assignment_group_code
      AND exists     (SELECT 'x'
                        FROM xla_jlt_acct_attrs a
                       WHERE a.application_id            = p_application_id
                         AND a.amb_context_code          = p_amb_context_code
                         AND a.event_class_code          = p_event_class_code
                         AND a.accounting_line_type_code = p_accounting_line_type_code
                         AND a.accounting_line_code      = p_accounting_line_code
                         AND a.source_code               IS NULL
                         AND a.accounting_attribute_code = s.accounting_attribute_code);

BEGIN

      -- Get the business flow method for the JLT
      OPEN c_business_method;
      FETCH c_business_method
       INTO l_business_method_code;
      CLOSE c_business_method;

      --
      -- Check if all or none of group accounting sources identifiers have a mapping
      --
      OPEN c_mapping_group;
      LOOP
         FETCH c_mapping_group
          INTO l_mapping_group;
         EXIT WHEN c_mapping_group%notfound OR l_return = FALSE;

         IF l_business_method_code = 'PRIOR_ENTRY' THEN
            OPEN c_prior_entry;
            FETCH c_prior_entry
             INTO l_accounting_attribute_name;
            IF c_prior_entry%found THEN
               p_message_name              := 'XLA_AB_LINE_GRP_ACCT_ATTR';
               p_accounting_attribute_name := l_accounting_attribute_name;
               l_return := FALSE;
            END IF;
            CLOSE c_prior_entry;
         ELSE
            OPEN c_group_accting_sources;
            FETCH c_group_accting_sources
             INTO l_accounting_attribute_name;
            IF c_group_accting_sources%found THEN

               p_message_name              := 'XLA_AB_LINE_GRP_ACCT_ATTR';
               p_accounting_attribute_name := l_accounting_attribute_name;
               l_return := FALSE;

            END IF;
            CLOSE c_group_accting_sources;
         END IF;
      END LOOP;
      CLOSE c_mapping_group;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.Chk_line_accting_sources');

END Chk_line_accting_sources;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| check_copy_line_type_details                                          |
|                                                                       |
| Checks if line type can be copied into a new one                      |
|                                                                       |
+======================================================================*/

FUNCTION check_copy_line_type_details
  (p_application_id                       IN NUMBER
  ,p_amb_context_code                     IN VARCHAR2
  ,p_entity_code                          IN VARCHAR2
  ,p_event_class_code                     IN VARCHAR2
  ,p_old_accting_line_type_code           IN VARCHAR2
  ,p_old_accounting_line_code             IN VARCHAR2
  ,p_old_transaction_coa_id               IN NUMBER
  ,p_new_transaction_coa_id               IN NUMBER
  ,p_message                              IN OUT NOCOPY VARCHAR2
  ,p_token_1                              IN OUT NOCOPY VARCHAR2
  ,p_value_1                              IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   l_condition_id                    integer;
   l_creation_date                   DATE := sysdate;
   l_last_update_date                DATE := sysdate;
   l_created_by                      INTEGER := xla_environment_pkg.g_usr_id;
   l_last_update_login               INTEGER := xla_environment_pkg.g_login_id;
   l_last_updated_by                 INTEGER := xla_environment_pkg.g_usr_id;
   l_con_flexfield_segment_code      VARCHAR2(30);
   l_con_flexfield_segment_name      VARCHAR2(80);
   l_con_v_flexfield_segment_code    VARCHAR2(30);
   l_con_v_flexfield_segment_name    VARCHAR2(80);
   l_source_flex_appl_id             NUMBER(15);
   l_source_id_flex_code             VARCHAR2(30);
   l_value_source_flex_appl_id       NUMBER(15);
   l_value_source_id_flex_code       VARCHAR2(30);
   l_return                          BOOLEAN := TRUE;

   CURSOR c_conditions
   IS
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND entity_code               = p_entity_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_old_accting_line_type_code
      AND accounting_line_code      = p_old_accounting_line_code;

   l_condition        c_conditions%rowtype;

   CURSOR c_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_condition.source_application_id
      AND source_type_code = l_condition.source_type_code
      AND source_code      = l_condition.source_code;

   CURSOR c_value_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_condition.value_source_application_id
      AND source_type_code = l_condition.value_source_type_code
      AND source_code      = l_condition.value_source_code;

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.check_copy_line_type_details'   , 10);

   xla_utility_pkg.trace('application_id                = '||p_application_id  , 20);
   xla_utility_pkg.trace('entity_code                   = '||p_entity_code     , 20);
   xla_utility_pkg.trace('event_class_code              = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('old_accounting_line_type_code = '||p_old_accting_line_type_code    , 20);
   xla_utility_pkg.trace('old_accounting_line_code      = '||p_old_accounting_line_code     , 20);

      OPEN c_conditions;
      LOOP
         FETCH c_conditions
          INTO l_condition;
         EXIT WHEN c_conditions%notfound or l_return = FALSE;

         IF l_condition.flexfield_segment_code is not null THEN

            OPEN c_source;
            FETCH c_source
             INTO l_source_flex_appl_id, l_source_id_flex_code;
            CLOSE c_source;

            IF l_source_flex_appl_id = 101 and l_source_id_flex_code = 'GL#' THEN

               IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                  l_con_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_condition.flexfield_segment_code);

                     IF l_con_flexfield_segment_code is null THEN
                       l_con_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_condition.flexfield_segment_code);

                       p_message := 'XLA_AB_TRX_COA_NO_QUAL';
                       p_token_1 := 'QUALIFIER_NAME';
                       p_value_1 := l_con_flexfield_segment_name;
                       l_return := FALSE;

                    END IF;
                END IF;
            END IF;
         END IF;

         IF l_return = TRUE THEN
            -- check value_flexfield_segment_code
            IF l_condition.value_flexfield_segment_code is not null THEN

               OPEN c_value_source;
               FETCH c_value_source
                INTO l_value_source_flex_appl_id, l_value_source_id_flex_code;
               CLOSE c_value_source;

               IF l_value_source_flex_appl_id = 101 and l_value_source_id_flex_code = 'GL#' THEN

                  IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                     l_con_v_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_condition.value_flexfield_segment_code);

                         IF l_con_v_flexfield_segment_code is null THEN
                            l_con_v_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_condition.value_flexfield_segment_code);

                            p_message := 'XLA_AB_TRX_COA_NO_QUAL';
                            p_token_1 := 'QUALIFIER_NAME';
                            p_value_1 := l_con_v_flexfield_segment_name;
                            l_return := FALSE;

                         END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
      END LOOP;
      CLOSE c_conditions;

   xla_utility_pkg.trace('< xla_line_types_pkg.check_copy_line_type_details'    , 10);

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_conditions%ISOPEN THEN
         CLOSE c_conditions;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_conditions%ISOPEN THEN
         CLOSE c_conditions;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.check_copy_line_type_details');

END check_copy_line_type_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| update_acct_attrs                                                     |
|                                                                       |
| Updates accounting attributes for the line type                       |
|                                                                       |
+======================================================================*/

PROCEDURE update_acct_attrs(
   p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,p_business_method_code             IN VARCHAR2)
IS

   -- Array Declaration
   l_arr_acct_attribute_code         t_array_codes;
   l_arr_source_application_id       t_array_id;
   l_arr_source_type_code            t_array_codes;
   l_arr_source_code                 t_array_codes;

   l_arr_p_acct_attribute_code         t_array_codes;
   l_arr_p_source_application_id       t_array_id;
   l_arr_p_source_type_code            t_array_codes;
   l_arr_p_source_code                 t_array_codes;

   -- Local Variables
   l_exist    VARCHAR2(1);


    CURSOR c_prior_entry
    IS
    SELECT e.accounting_attribute_code
      FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.default_flag              = 'Y'
       AND e.accounting_attribute_code = l.accounting_attribute_code
       AND l.assignment_level_code     = 'EVT_CLASS_JLT'
       AND l.inherited_flag            = 'Y';

    CURSOR c_non_prior_entry
    IS
    SELECT e.accounting_attribute_code, e.source_application_id,
           e.source_type_code, e.source_code
      FROM xla_evt_class_acct_attrs e, xla_acct_attributes_b l
     WHERE e.application_id            = p_application_id
       AND e.event_class_code          = p_event_class_code
       AND e.default_flag              = 'Y'
       AND e.accounting_attribute_code = l.accounting_attribute_code
       AND l.assignment_level_code     = 'EVT_CLASS_JLT'
       AND l.inherited_flag            = 'Y';

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.update_acct_attrs'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('event_class_code  = '||p_event_class_code     , 20);
   xla_utility_pkg.trace('accounting_line_type_code  = '||p_accounting_line_type_code     , 20);
   xla_utility_pkg.trace('accounting_line_code  = '||p_accounting_line_code     , 20);

           IF p_business_method_code = 'PRIOR_ENTRY' THEN
               -- Update the inherited accounting attributes to null source mapping

               OPEN c_prior_entry;
               FETCH c_prior_entry
               BULK COLLECT INTO l_arr_p_acct_attribute_code;

               IF l_arr_p_acct_attribute_code.COUNT > 0 THEN
                  FORALL i IN l_arr_p_acct_attribute_code.FIRST..l_arr_p_acct_attribute_code.LAST

                  UPDATE xla_jlt_acct_attrs
                     SET source_application_id     = null
                        ,source_type_code          = null
                        ,source_code               = null
                   WHERE application_id            = p_application_id
                     AND amb_context_code          = p_amb_context_code
                     AND event_class_code          = p_event_class_code
                     AND accounting_line_type_code = p_accounting_line_type_code
                     AND accounting_line_code      = p_accounting_line_code
                     AND accounting_attribute_code = l_arr_p_acct_attribute_code(i);
                END IF;
                CLOSE c_prior_entry;
           -- Not a prior entry jlt
           ELSE

               -- Update the default source mappings on the JLT for the accounting attributes
               -- whose inherited flag is 'Y'
               OPEN c_non_prior_entry;
               FETCH c_non_prior_entry
               BULK COLLECT INTO l_arr_acct_attribute_code, l_arr_source_application_id,
                                 l_arr_source_type_code, l_arr_source_code;

               IF l_arr_acct_attribute_code.COUNT > 0 THEN
                  FORALL i IN l_arr_acct_attribute_code.FIRST..l_arr_acct_attribute_code.LAST

                  UPDATE xla_jlt_acct_attrs
                     SET source_application_id     = l_arr_source_application_id(i)
                        ,source_type_code          = l_arr_source_type_code(i)
                        ,source_code               = l_arr_source_code(i)
                        ,event_class_default_flag  = 'Y'
                   WHERE application_id            = p_application_id
                     AND amb_context_code          = p_amb_context_code
                     AND event_class_code          = p_event_class_code
                     AND accounting_line_type_code = p_accounting_line_type_code
                     AND accounting_line_code      = p_accounting_line_code
                     AND accounting_attribute_code = l_arr_acct_attribute_code(i);
               END IF;
               CLOSE c_non_prior_entry;
           END IF;

   xla_utility_pkg.trace('< xla_line_types_pkg.update_acct_attrs'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_line_types_pkg.update_acct_attrs');

END update_acct_attrs;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| mpa_line_type_in_use                                                  |
|                                                                       |
| Returns true if the line is in used by a JLD                          |
|                                                                       |
+======================================================================*/

FUNCTION mpa_line_type_in_use
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_event_class_code                 IN VARCHAR2
  ,p_accounting_line_type_code        IN VARCHAR2
  ,p_accounting_line_code             IN VARCHAR2
  ,x_mpa_option_code                  IN OUT NOCOPY VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return              BOOLEAN;
   l_exist               VARCHAR2(1);
   l_mpa_option_code     VARCHAR2(30);

   CURSOR c_mpa_option_code
   IS
   SELECT mpa_option_code
     FROM xla_acct_line_types_b
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_accounting_line_type_code
      AND accounting_line_code      = p_accounting_line_code;

   CURSOR c_assignment_exist
   IS
   SELECT event_type_code, line_definition_owner_code, line_definition_code
     FROM xla_line_defn_jlt_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND accounting_line_type_code = p_accounting_line_type_code
      AND accounting_line_code      = p_accounting_line_code;

   l_assignment_exist         c_assignment_exist%rowtype;

   CURSOR c_mpa_assignment_exist
   IS
   SELECT event_type_code, line_definition_owner_code, line_definition_code,
          accounting_line_type_code, accounting_line_code
     FROM xla_mpa_jlt_assgns
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND event_class_code          = p_event_class_code
      AND mpa_accounting_line_type_code = p_accounting_line_type_code
      AND mpa_accounting_line_code      = p_accounting_line_code;

   l_mpa_assignment_exist         c_mpa_assignment_exist%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_line_types_pkg.mpa_line_type_in_use'   , 10);

   OPEN c_mpa_option_code;
   FETCH c_mpa_option_code
    INTO l_mpa_option_code;
   CLOSE c_mpa_option_code;

   IF l_mpa_option_code = 'ACCRUAL' THEN
      OPEN c_assignment_exist;
      FETCH c_assignment_exist
       INTO l_assignment_exist;
      IF c_assignment_exist%found then

         xla_line_definitions_pvt.get_line_definition_info
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_event_class_code           => p_event_class_code
           ,p_event_type_code            => l_assignment_exist.event_type_code
           ,p_line_definition_owner_code => l_assignment_exist.line_definition_owner_code
           ,p_line_definition_code       => l_assignment_exist.line_definition_code
           ,x_line_definition_owner      => x_line_definition_owner
           ,x_line_definition_name       => x_line_definition_name);

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_assignment_exist;

   ELSIF l_mpa_option_code = 'RECOGNITION' THEN
      OPEN  c_mpa_assignment_exist;
      FETCH c_mpa_assignment_exist
       INTO l_mpa_assignment_exist;
      IF c_mpa_assignment_exist%found then

            xla_line_definitions_pvt.get_line_definition_info
              (p_application_id             => p_application_id
              ,p_amb_context_code           => p_amb_context_code
              ,p_event_class_code           => p_event_class_code
              ,p_event_type_code            => l_mpa_assignment_exist.event_type_code
              ,p_line_definition_owner_code => l_mpa_assignment_exist.line_definition_owner_code
              ,p_line_definition_code       => l_mpa_assignment_exist.line_definition_code
              ,x_line_definition_owner      => x_line_definition_owner
              ,x_line_definition_name       => x_line_definition_name);

             l_return := TRUE;
      ELSE
             l_return := FALSE;
      END IF;
	  CLOSE c_mpa_assignment_exist;

   END IF;

   xla_utility_pkg.trace('< xla_line_types_pkg.mpa_line_type_in_use'    , 10);
   x_mpa_option_code := l_mpa_option_code;

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
        (p_location   => 'xla_line_types_pkg.mpa_line_type_in_use');

END mpa_line_type_in_use;

END xla_line_types_pkg;

/
