--------------------------------------------------------
--  DDL for Package Body XLA_SEG_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_SEG_RULES_PKG" AS
/* $Header: xlaamadr.pkb 120.25 2006/01/19 21:10:15 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_seg_rules_pkg                                                  |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Segment Rules Package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    20-Oct-04 Wynne Chan     Updated for Journal Lines Definitions     |
|                                                                       |
+======================================================================*/

TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_seg_rule_details                                               |
|                                                                       |
| Deletes all details of the segment rule                               |
|                                                                       |
+======================================================================*/

PROCEDURE delete_seg_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
IS

   l_segment_rule_detail_id    NUMBER(38);

   CURSOR c_seg_rule_details
   IS
   SELECT segment_rule_detail_id
     FROM xla_seg_rule_details
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code;

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.delete_seg_rule_details'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code  = '||p_segment_rule_code     , 20);

   OPEN c_seg_rule_details;
   LOOP
      FETCH c_seg_rule_details
       INTO l_segment_rule_detail_id;
      EXIT WHEN c_seg_rule_details%notfound;

      xla_conditions_pkg.delete_condition
        (p_context                 => 'S'
        ,p_segment_rule_detail_id  => l_segment_rule_detail_id);

   END LOOP;
   CLOSE c_seg_rule_details;

   DELETE
     FROM xla_seg_rule_details
    WHERE application_id            = p_application_id
      AND amb_context_code          = p_amb_context_code
      AND segment_rule_type_code    = p_segment_rule_type_code
      AND segment_rule_code         = p_segment_rule_code;

   xla_utility_pkg.trace('< xla_seg_rules_pkg.delete_seg_rule_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_seg_rule_details%ISOPEN THEN
         CLOSE c_seg_rule_details;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_seg_rule_details%ISOPEN THEN
         CLOSE c_seg_rule_details;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.delete_seg_rule_details');

END delete_seg_rule_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_seg_rule_details                                                 |
|                                                                       |
| Copies details of a segment rule into a new segment rule              |
|                                                                       |
+======================================================================*/

PROCEDURE copy_seg_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_old_segment_rule_type_code       IN VARCHAR2
  ,p_old_segment_rule_code            IN VARCHAR2
  ,p_new_segment_rule_type_code       IN VARCHAR2
  ,p_new_segment_rule_code            IN VARCHAR2
  ,p_old_transaction_coa_id           IN NUMBER
  ,p_new_transaction_coa_id           IN NUMBER)
IS

   l_condition_id                    integer;
   l_new_segment_rule_detail_id      integer;
   l_creation_date                   DATE;
   l_last_update_date                DATE;
   l_created_by                      INTEGER;
   l_last_update_login               INTEGER;
   l_last_updated_by                 INTEGER;
   l_value_flexfield_segment_code    VARCHAR2(30);
   l_value_flexfield_segment_name    VARCHAR2(80);
   l_con_flexfield_segment_code      VARCHAR2(30);
   l_con_flexfield_segment_name      VARCHAR2(80);
   l_con_v_flexfield_segment_code    VARCHAR2(30);
   l_con_v_flexfield_segment_name    VARCHAR2(80);
   l_inp_flex_appl_id                NUMBER(15);
   l_inp_id_flex_code                VARCHAR2(30);
   l_source_flex_appl_id             NUMBER(15);
   l_source_id_flex_code             VARCHAR2(30);
   l_value_source_flex_appl_id       NUMBER(15);
   l_value_source_id_flex_code       VARCHAR2(30);

   CURSOR c_seg_rule_details
   IS
   SELECT segment_rule_detail_id, user_sequence,
          value_type_code, value_source_application_id, value_source_type_code,
          value_source_code, value_constant, value_code_combination_id,
          value_mapping_set_code,
          value_flexfield_segment_code, input_source_application_id,
          input_source_type_code, input_source_code,
          value_segment_rule_appl_id, value_segment_rule_type_code,
          value_segment_rule_code, value_adr_version_num
     FROM xla_seg_rule_details
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_old_segment_rule_type_code
      AND segment_rule_code      = p_old_segment_rule_code;

   l_seg_rule_detail     c_seg_rule_details%rowtype;

   CURSOR c_input_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_seg_rule_detail.input_source_application_id
      AND source_type_code = l_seg_rule_detail.input_source_type_code
      AND source_code      = l_seg_rule_detail.input_source_code;


   CURSOR c_detail_conditions
   IS
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE segment_rule_detail_id = l_seg_rule_detail.segment_rule_detail_id;

   l_detail_condition    c_detail_conditions%rowtype;

   CURSOR c_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_detail_condition.source_application_id
      AND source_type_code = l_detail_condition.source_type_code
      AND source_code      = l_detail_condition.source_code;

   CURSOR c_value_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_detail_condition.value_source_application_id
      AND source_type_code = l_detail_condition.value_source_type_code
      AND source_code      = l_detail_condition.value_source_code;

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.copy_seg_rule_details'   , 10);

   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_old_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_old_segment_rule_code     , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_new_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_new_segment_rule_code     , 20);


   l_creation_date                   := sysdate;
   l_last_update_date                := sysdate;
   l_created_by                      := xla_environment_pkg.g_usr_id;
   l_last_update_login               := xla_environment_pkg.g_login_id;
   l_last_updated_by                 := xla_environment_pkg.g_usr_id;

   OPEN c_seg_rule_details;
   LOOP
      FETCH c_seg_rule_details
       INTO l_seg_rule_detail;
      EXIT WHEN c_seg_rule_details%notfound;

      IF l_seg_rule_detail.value_flexfield_segment_code is not null THEN
         IF l_seg_rule_detail.value_type_code = 'S' THEN
            IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN

                l_value_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_seg_rule_detail.value_flexfield_segment_code);
             ELSE
                l_value_flexfield_segment_code := l_seg_rule_detail.value_flexfield_segment_code;
             END IF;

         ELSIF l_seg_rule_detail.value_type_code = 'M' THEN
            -- value_type_code = 'M'

            OPEN c_input_source;
            FETCH c_input_source
             INTO l_inp_flex_appl_id, l_inp_id_flex_code;
            CLOSE c_input_source;

            IF l_inp_flex_appl_id = 101 and l_inp_id_flex_code = 'GL#' THEN

               IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                  l_value_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_seg_rule_detail.value_flexfield_segment_code);

                ELSE
                   l_value_flexfield_segment_code := l_seg_rule_detail.value_flexfield_segment_code;
                END IF;
            ELSE
               -- Other key flexfield segment
               l_value_flexfield_segment_code := l_seg_rule_detail.value_flexfield_segment_code;
            END IF;
         END IF;
      ELSE
         -- value_flexfield_segment_code is null
         l_value_flexfield_segment_code := l_seg_rule_detail.value_flexfield_segment_code;
      END IF;

      SELECT xla_seg_rule_details_s.nextval
        INTO l_new_segment_rule_detail_id
        FROM DUAL;

      INSERT INTO xla_seg_rule_details
           (segment_rule_detail_id
           ,application_id
           ,amb_context_code
           ,segment_rule_type_code
           ,segment_rule_code
           ,user_sequence
           ,value_type_code
           ,value_source_application_id
           ,value_source_type_code
           ,value_source_code
           ,value_constant
           ,value_mapping_set_code
           ,value_flexfield_segment_code
           ,input_source_application_id
           ,input_source_type_code
           ,input_source_code
           ,creation_date
           ,created_by
           ,last_update_date
           ,last_updated_by
           ,last_update_login
           ,value_code_combination_id
           ,value_segment_rule_appl_id
           ,value_segment_rule_type_code
           ,value_segment_rule_code
           ,value_adr_version_num
         )
      VALUES
           (l_new_segment_rule_detail_id
           ,p_application_id
           ,p_amb_context_code
           ,p_new_segment_rule_type_code
           ,p_new_segment_rule_code
           ,l_seg_rule_detail.user_sequence
           ,l_seg_rule_detail.value_type_code
           ,l_seg_rule_detail.value_source_application_id
           ,l_seg_rule_detail.value_source_type_code
           ,l_seg_rule_detail.value_source_code
           ,l_seg_rule_detail.value_constant
           ,l_seg_rule_detail.value_mapping_set_code
           ,l_value_flexfield_segment_code
           ,l_seg_rule_detail.input_source_application_id
           ,l_seg_rule_detail.input_source_type_code
           ,l_seg_rule_detail.input_source_code
           ,l_creation_date
           ,l_created_by
           ,l_last_update_date
           ,l_last_updated_by
           ,l_last_update_login
           ,l_seg_rule_detail.value_code_combination_id
           ,l_seg_rule_detail.value_segment_rule_appl_id
           ,l_seg_rule_detail.value_segment_rule_type_code
           ,l_seg_rule_detail.value_segment_rule_code
           ,l_seg_rule_detail.value_adr_version_num
           );

      OPEN c_detail_conditions;
      LOOP
         FETCH c_detail_conditions
          INTO l_detail_condition;
         EXIT WHEN c_detail_conditions%notfound;

         IF l_detail_condition.flexfield_segment_code is not null THEN

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
                                                ,p_qualifier_segment => l_detail_condition.flexfield_segment_code);

                ELSE
                   l_con_flexfield_segment_code := l_detail_condition.flexfield_segment_code;
                END IF;

            ELSE
               -- Other key flexfield segment
               l_con_flexfield_segment_code := l_detail_condition.flexfield_segment_code;
            END IF;
         ELSE
            l_con_flexfield_segment_code := l_detail_condition.flexfield_segment_code;
         END IF;

         -- check value_flexfield_segment_code
         IF l_detail_condition.value_flexfield_segment_code is not null THEN

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
                                                ,p_qualifier_segment => l_detail_condition.value_flexfield_segment_code);

                  ELSE
                    l_con_v_flexfield_segment_code := l_detail_condition.value_flexfield_segment_code;
                  END IF;

               ELSE
                  -- Other key flexfield segment
                  l_con_v_flexfield_segment_code := l_detail_condition.value_flexfield_segment_code;
               END IF;
         ELSE
            l_con_v_flexfield_segment_code := l_detail_condition.value_flexfield_segment_code;
         END IF;

         SELECT xla_conditions_s.nextval
           INTO l_condition_id
           FROM DUAL;

         INSERT INTO xla_conditions
              (condition_id
              ,user_sequence
              ,application_id
              ,amb_context_code
              ,segment_rule_detail_id
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
              ,l_detail_condition.user_sequence
              ,p_application_id
              ,p_amb_context_code
              ,l_new_segment_rule_detail_id
              ,l_detail_condition.bracket_left_code
              ,l_detail_condition.bracket_right_code
              ,l_detail_condition.value_type_code
              ,l_detail_condition.source_application_id
              ,l_detail_condition.source_type_code
              ,l_detail_condition.source_code
              ,l_con_flexfield_segment_code
              ,l_con_v_flexfield_segment_code
              ,l_detail_condition.value_source_application_id
              ,l_detail_condition.value_source_type_code
              ,l_detail_condition.value_source_code
              ,l_detail_condition.value_constant
              ,l_detail_condition.line_operator_code
              ,l_detail_condition.logical_operator_code
              ,l_creation_date
              ,l_created_by
              ,l_last_update_date
              ,l_last_updated_by
              ,l_last_update_login
              ,l_detail_condition.independent_value_constant);

      END LOOP;
      CLOSE c_detail_conditions;

   END LOOP;
   CLOSE c_seg_rule_details;

   xla_utility_pkg.trace('< xla_seg_rules_pkg.copy_seg_rule_details'    , 10);

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_seg_rule_details%ISOPEN THEN
         CLOSE c_seg_rule_details;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_seg_rule_details%ISOPEN THEN
         CLOSE c_seg_rule_details;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.copy_seg_rule_details');

END copy_seg_rule_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| rule_in_use                                                           |
|                                                                       |
| Returns true if the rule is in use by an accounting line type         |
|                                                                       |
+======================================================================*/

FUNCTION rule_in_use
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return                 BOOLEAN;
   l_exist                  VARCHAR2(1);
   l_line_definition_name   varchar2(80) := null;
   l_line_definition_owner  varchar2(80) := null;

   CURSOR c_assignment_exist
   IS
   SELECT event_class_code, event_type_code, line_definition_owner_code, line_definition_code
     FROM xla_line_defn_adr_assgns
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code;

   l_assignment_exist      c_assignment_exist%rowtype;

   CURSOR c_active_assignment_exist
   IS
   SELECT event_class_code, event_type_code, line_definition_owner_code, line_definition_code
     FROM xla_line_defn_adr_assgns s
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code
      AND exists (SELECT 'y'
                    FROM xla_line_defn_jlt_assgns p
                   WHERE p.application_id             = s.application_id
                     AND p.amb_context_code           = s.amb_context_code
                     AND p.event_class_code           = s.event_class_code
                     AND p.event_type_code            = s.event_type_code
                     AND p.line_definition_owner_code = s.line_definition_owner_code
                     AND p.line_definition_code       = s.line_definition_code
                     AND p.accounting_line_type_code  = s.accounting_line_type_code
                     AND p.accounting_line_code       = s.accounting_line_code
                     AND active_flag                  = 'Y');

   l_active_assignment_exist      c_active_assignment_exist%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.rule_in_use'   , 10);

   xla_utility_pkg.trace('event                   = '||p_event  , 20);
   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_segment_rule_code     , 20);

   IF p_event in ('DELETE','UPDATE') THEN
      OPEN c_assignment_exist;
      FETCH c_assignment_exist
       INTO l_assignment_exist;
      IF c_assignment_exist%found then

         xla_line_definitions_pvt.get_line_definition_info
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_event_class_code           => l_assignment_exist.event_class_code
           ,p_event_type_code            => l_assignment_exist.event_type_code
           ,p_line_definition_owner_code => l_assignment_exist.line_definition_owner_code
           ,p_line_definition_code       => l_assignment_exist.line_definition_code
           ,x_line_definition_name       => l_line_definition_name
           ,x_line_definition_owner      => l_line_definition_owner);

         l_return := TRUE;
      ELSE
         l_return := FALSE;
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
           ,p_event_class_code           => l_active_assignment_exist.event_class_code
           ,p_event_type_code            => l_active_assignment_exist.event_type_code
           ,p_line_definition_owner_code => l_active_assignment_exist.line_definition_owner_code
           ,p_line_definition_code       => l_active_assignment_exist.line_definition_code
           ,x_line_definition_name       => l_line_definition_name
           ,x_line_definition_owner      => l_line_definition_owner);

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_active_assignment_exist;

   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Invalid event passed'
        ,'LOCATION' ,'xla_seg_rules_pkg.rule_in_use');

   END IF;

   x_line_definition_name    := l_line_definition_name;
   x_line_definition_owner   := l_line_definition_owner;

   xla_utility_pkg.trace('< xla_seg_rules_pkg.rule_in_use'    , 10);

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
        (p_location   => 'xla_seg_rules_pkg.rule_in_use');

END rule_in_use;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| rule_is_invalid                                                       |
|                                                                       |
| Returns true if the rule is invalid                                   |
|                                                                       |
+======================================================================*/

FUNCTION rule_is_invalid
  (p_application_id                   IN  NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN  VARCHAR2
  ,p_segment_rule_code                IN  VARCHAR2
  ,p_message_name                     OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return                 BOOLEAN;
   l_exist                  VARCHAR2(1);
   l_segment_rule_detail_id NUMBER(38);
   l_count_all              NUMBER(10) := 0;
   l_count_only             NUMBER(10) := 0;
   l_count                  NUMBER(10) := 0;
   l_message_name           VARCHAR2(30);
   l_application_id         NUMBER(38);
   l_amb_context_code       VARCHAR2(30);
   l_segment_rule_type_code VARCHAR2(1);
   l_segment_rule_code      VARCHAR2(30);

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.rule_is_invalid'   , 10);

   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_segment_rule_code     , 20);

   l_application_id		:= p_application_id;
   l_amb_context_code		:= p_amb_context_code;
   l_segment_rule_type_code	:= p_segment_rule_type_code;
   l_segment_rule_code		:= p_segment_rule_code;

         IF xla_conditions_pkg.seg_condition_is_invalid
              (p_application_id         => l_application_id
              ,p_amb_context_code       => l_amb_context_code
              ,p_segment_rule_type_code => l_segment_rule_type_code
              ,p_segment_rule_code      => l_segment_rule_code
              ,p_message_name           => l_message_name)
         THEN
            p_message_name := l_message_name;
            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;

   xla_utility_pkg.trace('p_message_name       = '||p_message_name     , 20);
   xla_utility_pkg.trace('< xla_seg_rules_pkg.rule_is_invalid'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.rule_is_invalid');

END rule_is_invalid;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| seg_rule_is_locked                                                    |
|                                                                       |
| Returns true if the rule is in use by a locked journal line definition|
|                                                                       |
+======================================================================*/

FUNCTION seg_rule_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN;
   l_exist    VARCHAR2(1);

   CURSOR c_frozen_assignment_exist
   IS
   SELECT 'x'
     FROM xla_line_defn_adr_assgns s
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code
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

   CURSOR c_tab_assignment_exist
   IS
   SELECT 'x'
     FROM xla_tab_acct_def_details s
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code
      AND exists      (SELECT 'x'
                         FROM xla_tab_acct_defs_b a
                        WHERE a.application_id             = s.application_id
                          AND a.amb_context_code           = s.amb_context_code
                          AND a.account_definition_type_code  = s.account_definition_type_code
                          AND a.account_definition_code = s.account_definition_code
                          AND a.locking_status_flag        = 'Y');

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.seg_rule_is_locked'   , 10);

   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_segment_rule_code     , 20);

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

   xla_utility_pkg.trace('< xla_seg_rules_pkg.seg_rule_is_locked'    , 10);

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
        (p_location   => 'xla_seg_rules_pkg.seg_rule_is_locked');

END seg_rule_is_locked;

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
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                  IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag              IN OUT NOCOPY VARCHAR2)
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

  -- Retrive any event class/type assignment of an AAD that refer
  -- to the ADR
  CURSOR c_lock_aads IS
    SELECT xpa.entity_code
         , xpa.event_class_code
         , xpa.event_type_code
         , xpa.product_rule_type_code
         , xpa.product_rule_code
         , xpa.locking_status_flag
         , xpa.validation_status_code
      FROM xla_line_defn_adr_assgns xld
          ,xla_aad_line_defn_assgns xal
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = xal.application_id
       AND xpa.amb_context_code           = xal.amb_context_code
       AND xpa.product_rule_type_code     = xal.product_rule_type_code
       AND xpa.product_rule_code          = xal.product_rule_code
       AND xpa.event_class_code           = xal.event_class_code
       AND xpa.event_type_code            = xal.event_type_code
       AND xal.application_id             = xld.application_id
       AND xal.amb_context_code           = xld.amb_context_code
       AND xal.event_class_code           = xld.event_class_code
       AND xal.event_type_code            = xld.event_type_code
       AND xal.line_definition_owner_code = xld.line_definition_owner_code
       AND xal.line_definition_code       = xld.line_definition_code
       AND xld.application_id             = p_application_id
       AND xld.amb_context_code           = p_amb_context_code
       AND xld.segment_rule_type_code     = p_segment_rule_type_code
       AND xld.segment_rule_code          = p_segment_rule_code
       FOR UPDATE NOWAIT;

  CURSOR c_update_aads IS
    SELECT distinct xal.event_class_code
         , xal.product_rule_type_code
         , xal.product_rule_code
      FROM xla_line_defn_adr_assgns xad
          ,xla_aad_line_defn_assgns xal
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = xal.application_id
       AND xpa.amb_context_code           = xal.amb_context_code
       AND xpa.event_class_code           = xal.event_class_code
       AND xpa.event_type_code            = xal.event_type_code
       AND xal.application_id             = xad.application_id
       AND xal.amb_context_code           = xad.amb_context_code
       AND xal.event_class_code           = xad.event_class_code
       AND xal.event_type_code            = xad.event_type_code
       AND xal.line_definition_owner_code = xad.line_definition_owner_code
       AND xal.line_definition_code       = xad.line_definition_code
       AND xad.application_id             = p_application_id
       AND xad.amb_context_code           = p_amb_context_code
       AND xad.segment_rule_type_code     = p_segment_rule_type_code
       AND xad.segment_rule_code          = p_segment_rule_code;

   l_event_class_codes       t_array_codes;
   l_product_rule_type_codes t_array_type_codes;
   l_product_rule_codes      t_array_codes;
BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.uncompile_definitions'   , 10);

   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('amb_context_code        = '||p_amb_context_code  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_segment_rule_code     , 20);

  l_return := TRUE;

  FOR l_lock_aad IN c_lock_aads LOOP
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
           , last_update_date       = sysdate
           , last_updated_by        = xla_environment_pkg.g_usr_id
           , last_update_login      = xla_environment_pkg.g_login_id
       WHERE xld.application_id     = p_application_id
         AND xld.amb_context_code   = p_amb_context_code
         AND xld.validation_status_code <> 'N'
         AND EXISTS
             (SELECT 1
                FROM xla_line_defn_adr_assgns xad
               WHERE xad.application_id             = p_application_id
                 AND xad.amb_context_code           = p_amb_context_code
                 AND xad.segment_rule_type_code     = p_segment_rule_type_code
                 AND xad.segment_rule_code          = p_segment_rule_code
                 AND xad.event_class_code           = xld.event_class_code
                 AND xad.event_type_code            = xld.event_type_code
                 AND xad.line_definition_owner_code = xld.line_definition_owner_code
                 AND xad.line_definition_code       = xld.line_definition_code);

      OPEN c_update_aads;
      FETCH c_update_aads BULK COLLECT INTO l_event_class_codes
                                           ,l_product_rule_type_codes
                                           ,l_product_rule_codes;
      CLOSE c_update_aads;

      IF (l_event_class_codes.count > 0) THEN

        FORALL i IN 1..l_event_class_codes.LAST
          UPDATE xla_product_rules_b
             SET compile_status_code = 'N'
               , updated_flag        = 'Y'
               , last_update_date    = sysdate
               , last_updated_by     = xla_environment_pkg.g_usr_id
               , last_update_login   = xla_environment_pkg.g_login_id
           WHERE application_id          = p_application_id
             AND amb_context_code        = p_amb_context_code
             AND product_rule_type_code  = l_product_rule_type_codes(i)
             AND product_rule_code       = l_product_rule_codes(i)
             AND (compile_status_code    <> 'N' OR
                  updated_flag           <> 'Y');

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

   xla_utility_pkg.trace('< xla_seg_rules_pkg.uncompile_definitions'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;
      IF c_update_aads%ISOPEN THEN
         CLOSE c_update_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_lock_aads%ISOPEN THEN
         CLOSE c_lock_aads;
      END IF;
      IF c_update_aads%ISOPEN THEN
         CLOSE c_update_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.uncompile_definitions');

END uncompile_definitions;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| rule_in_use_by_tab                                                    |
|                                                                       |
| Returns true if the rule is in use by a transaction account definition|
|                                                                       |
+======================================================================*/

FUNCTION rule_in_use_by_tab
  (p_event                            IN VARCHAR2
  ,p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,p_trx_acct_def                     IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type                IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_type                    IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return              BOOLEAN;
   l_exist               VARCHAR2(1);
   l_application_name    varchar2(240) := null;
   l_trx_acct_def        varchar2(80) := null;
   l_trx_acct_def_type   varchar2(80) := null;
   l_trx_acct_type       varchar2(80) := null;

   CURSOR c_assignment_exist
   IS
   SELECT application_id, amb_context_code, account_definition_code,
          account_definition_type_code,
          account_type_code
     FROM xla_tab_acct_def_details
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code;

   l_assignment_exist      c_assignment_exist%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.rule_in_use_by_tab'   , 10);

   xla_utility_pkg.trace('event                   = '||p_event  , 20);
   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code
    , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_segment_rule_code     ,
 20);

   IF p_event in ('DELETE','UPDATE','DISABLE') THEN
      OPEN c_assignment_exist;
      FETCH c_assignment_exist
       INTO l_assignment_exist;
      IF c_assignment_exist%found then

         xla_validations_pkg.get_trx_acct_def_info
           (p_application_id          => l_assignment_exist.application_id
           ,p_amb_context_code        => l_assignment_exist.amb_context_code
           ,p_account_definition_type_code  => l_assignment_exist.account_definition_type_code
           ,p_account_definition_code       => l_assignment_exist.account_definition_code
           ,p_application_name        => l_application_name
           ,p_trx_acct_def            => l_trx_acct_def
           ,p_trx_acct_def_type       => l_trx_acct_def_type);

         xla_validations_pkg.get_trx_acct_type_info
           (p_application_id          => l_assignment_exist.application_id
           ,p_account_type_code       => l_assignment_exist.account_type_code
           ,p_trx_acct_type           => l_trx_acct_type);

         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_assignment_exist;

   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Invalid event passed'
        ,'LOCATION' ,'xla_seg_rules_pkg.rule_in_use_by_tab');

   END IF;

   p_trx_acct_def      := l_trx_acct_def;
   p_trx_acct_def_type := l_trx_acct_def_type;
   p_trx_acct_type     := l_trx_acct_type;

   xla_utility_pkg.trace('< xla_seg_rules_pkg.rule_in_use_by_tab'    , 10);

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
        (p_location   => 'xla_seg_rules_pkg.rule_in_use_by_tab');

END rule_in_use_by_tab;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
| Returns true if all the transaction account definitions using         |
| the segment rule are uncompiled                                       |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_tran_acct_def
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,p_application_name                 IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def                     IN OUT NOCOPY VARCHAR2
  ,p_trx_acct_def_type                IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   l_return   BOOLEAN := TRUE;
   l_exist    VARCHAR2(1);

   l_application_name    varchar2(240) := null;
   l_trx_acct_def        varchar2(80) := null;
   l_trx_acct_def_type   varchar2(80) := null;

   CURSOR c_trx_defs
   IS
   SELECT application_id, amb_context_code, account_definition_type_code,
          account_definition_code
     FROM xla_tab_acct_defs_b p
    WHERE exists (SELECT 'x'
                    FROM xla_tab_acct_def_details s
                   WHERE s.application_id         = p_application_id
                     AND s.amb_context_code       = p_amb_context_code
                     AND s.segment_rule_type_code = p_segment_rule_type_code
                     AND s.segment_rule_code      = p_segment_rule_code
                     AND s.application_id         = p.application_id
                     AND s.amb_context_code       = p.amb_context_code
                     AND s.account_definition_type_code = p.account_definition_type_code
                     AND s.account_definition_code = p.account_definition_code);

   l_trx_def   c_trx_defs%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.uncompile_tran_acct_def'   , 10);

   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code
    , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_segment_rule_code     ,
 20);

   OPEN c_trx_defs;
   LOOP
   FETCH c_trx_defs
    INTO l_trx_def;
   EXIT WHEN c_trx_defs%NOTFOUND or l_return=FALSE;

      IF xla_tab_acct_defs_pkg.uncompile_tran_acct_def
           (p_application_id               => l_trx_def.application_id
           ,p_amb_context_code             => l_trx_def.amb_context_code
           ,p_account_definition_type_code => l_trx_def.account_definition_type_code
           ,p_account_definition_code      => l_trx_def.account_definition_code) THEN

         l_return := TRUE;
      ELSE

         xla_validations_pkg.get_trx_acct_def_info
           (p_application_id          => l_trx_def.application_id
           ,p_amb_context_code        => l_trx_def.amb_context_code
           ,p_account_definition_type_code  => l_trx_def.account_definition_type_code
           ,p_account_definition_code       => l_trx_def.account_definition_code
           ,p_application_name        => l_application_name
           ,p_trx_acct_def            => l_trx_acct_def
           ,p_trx_acct_def_type       => l_trx_acct_def_type);

         l_return := FALSE;
      END IF;
   END LOOP;
   CLOSE c_trx_defs;

   p_application_name  := l_application_name;
   p_trx_acct_def      := l_trx_acct_def;
   p_trx_acct_def_type := l_trx_acct_def_type;

   xla_utility_pkg.trace('< xla_seg_rules_pkg.uncompile_tran_acct_def'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_trx_defs%ISOPEN THEN
         CLOSE c_trx_defs;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_trx_defs%ISOPEN THEN
         CLOSE c_trx_defs;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.uncompile_tran_acct_def');

END uncompile_tran_acct_def;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| check_copy_seg_rule_details                                           |
|                                                                       |
| Checks if the segment rule details can be copied into the new one     |
|                                                                       |
+======================================================================*/

FUNCTION check_copy_seg_rule_details
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_old_segment_rule_type_code       IN VARCHAR2
  ,p_old_segment_rule_code            IN VARCHAR2
  ,p_old_transaction_coa_id           IN NUMBER
  ,p_new_transaction_coa_id           IN NUMBER
  ,p_old_flex_value_set_id            IN NUMBER
  ,p_new_flex_value_set_id            IN NUMBER
  ,p_message                          IN OUT NOCOPY VARCHAR2
  ,p_token_1                          IN OUT NOCOPY VARCHAR2
  ,p_value_1                          IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_value_flexfield_segment_code    VARCHAR2(30);
   l_value_flexfield_segment_name    VARCHAR2(80);
   l_con_flexfield_segment_code      VARCHAR2(30);
   l_con_flexfield_segment_name      VARCHAR2(80);
   l_con_v_flexfield_segment_code    VARCHAR2(30);
   l_con_v_flexfield_segment_name    VARCHAR2(80);
   l_inp_flex_appl_id                NUMBER(15);
   l_inp_id_flex_code                VARCHAR2(30);
   l_source_flex_appl_id             NUMBER(15);
   l_source_id_flex_code             VARCHAR2(30);
   l_value_source_flex_appl_id       NUMBER(15);
   l_value_source_id_flex_code       VARCHAR2(30);
   l_return                          BOOLEAN := TRUE;


   CURSOR c_flex_value
   IS
   SELECT value_constant
     FROM xla_seg_rule_details seg
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_old_segment_rule_type_code
      AND segment_rule_code      = p_old_segment_rule_code
	  AND not exists (SELECT 'x'
	                    FROM fnd_flex_values ffv
					   WHERE ffv.flex_value_set_id = p_new_flex_value_set_id
					     AND ffv.flex_value        = seg.value_constant);

   l_flex_value     c_flex_value%rowtype;

   CURSOR c_seg_rule_details
   IS
   SELECT segment_rule_detail_id, user_sequence,
          value_type_code, value_source_application_id, value_source_type_code,
          value_source_code, value_constant, value_code_combination_id,
          value_mapping_set_code,
          value_flexfield_segment_code, input_source_application_id,
          input_source_type_code, input_source_code
     FROM xla_seg_rule_details
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_old_segment_rule_type_code
      AND segment_rule_code      = p_old_segment_rule_code;

   l_seg_rule_detail     c_seg_rule_details%rowtype;

   CURSOR c_input_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_seg_rule_detail.input_source_application_id
      AND source_type_code = l_seg_rule_detail.input_source_type_code
      AND source_code      = l_seg_rule_detail.input_source_code;

   CURSOR c_detail_conditions
   IS
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE segment_rule_detail_id = l_seg_rule_detail.segment_rule_detail_id;

   l_detail_condition    c_detail_conditions%rowtype;

   CURSOR c_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_detail_condition.source_application_id
      AND source_type_code = l_detail_condition.source_type_code
      AND source_code      = l_detail_condition.source_code;

   CURSOR c_value_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_detail_condition.value_source_application_id
      AND source_type_code = l_detail_condition.value_source_type_code
      AND source_code      = l_detail_condition.value_source_code;

BEGIN

   xla_utility_pkg.trace('> xla_seg_rules_pkg.check_copy_seg_rule_details'   , 10);

   xla_utility_pkg.trace('application_id          = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_old_segment_rule_type_code     , 20);
   xla_utility_pkg.trace('segment_rule_code       = '||p_old_segment_rule_code     , 20);

   IF p_new_flex_value_set_id is not null then
      IF p_old_flex_value_set_id <> p_new_flex_value_set_id THEN
         OPEN c_flex_value;
         FETCH c_flex_value
          INTO l_flex_value;
         IF c_flex_value%found THEN

            p_message := 'XLA_AB_FLEX_VALUE_NOT_EXIST';
            p_token_1 := 'FLEX_VALUE';
            p_value_1 := l_flex_value.value_constant;
            l_return := FALSE;

         END IF;
         CLOSE c_flex_value;
      END IF;
   END IF;

   IF l_return = TRUE THEN

   OPEN c_seg_rule_details;
   LOOP
      FETCH c_seg_rule_details
       INTO l_seg_rule_detail;
      EXIT WHEN c_seg_rule_details%notfound or l_return = FALSE;

      IF l_seg_rule_detail.value_flexfield_segment_code is not null THEN
         IF l_seg_rule_detail.value_type_code = 'S' THEN
            IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN

                l_value_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_seg_rule_detail.value_flexfield_segment_code);

                 IF l_value_flexfield_segment_code is null THEN
                    l_value_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_seg_rule_detail.value_flexfield_segment_code);

                    p_message := 'XLA_AB_TRX_COA_NO_QUAL';
                    p_token_1 := 'QUALIFIER_NAME';
                    p_value_1 := l_value_flexfield_segment_name;
                    l_return := FALSE;

                 END IF;
             END IF;

         ELSIF l_seg_rule_detail.value_type_code = 'M' THEN
            -- value_type_code = 'M'

            OPEN c_input_source;
            FETCH c_input_source
             INTO l_inp_flex_appl_id, l_inp_id_flex_code;
            CLOSE c_input_source;

            IF l_inp_flex_appl_id = 101 and l_inp_id_flex_code = 'GL#' THEN

               IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                  l_value_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_seg_rule_detail.value_flexfield_segment_code);

                    IF l_value_flexfield_segment_code is null THEN
                       l_value_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_seg_rule_detail.value_flexfield_segment_code);

                       p_message := 'XLA_AB_TRX_COA_NO_QUAL';
                       p_token_1 := 'QUALIFIER_NAME';
                       p_value_1 := l_value_flexfield_segment_name;
                       l_return := FALSE;

                    END IF;
                END IF;
            END IF;
         END IF;
      END IF;

      IF l_return = TRUE THEN

         OPEN c_detail_conditions;
         LOOP
            FETCH c_detail_conditions
             INTO l_detail_condition;
            EXIT WHEN c_detail_conditions%notfound or l_return = FALSE;

            IF l_detail_condition.flexfield_segment_code is not null THEN

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
                                                ,p_qualifier_segment => l_detail_condition.flexfield_segment_code);

                    IF l_con_flexfield_segment_code is null THEN
                       l_con_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_detail_condition.flexfield_segment_code);

                       p_message := 'XLA_AB_TRX_COA_NO_QUAL';
                       p_token_1 := 'QUALIFIER_NAME';
                       p_value_1 := l_con_flexfield_segment_name;
                       l_return := FALSE;

                    END IF;
                END IF;
            END IF;
         END IF;

         -- check value_flexfield_segment_code
         IF l_return = TRUE THEN
            IF l_detail_condition.value_flexfield_segment_code is not null THEN

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
                                                ,p_qualifier_segment => l_detail_condition.value_flexfield_segment_code);

                    IF l_con_v_flexfield_segment_code is null THEN
                       l_con_v_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_detail_condition.value_flexfield_segment_code);

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
       CLOSE c_detail_conditions;
      END IF;
   END LOOP;
   CLOSE c_seg_rule_details;
   END IF;

   xla_utility_pkg.trace('< xla_seg_rules_pkg.check_copy_seg_rule_details'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_seg_rule_details%ISOPEN THEN
         CLOSE c_seg_rule_details;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_seg_rule_details%ISOPEN THEN
         CLOSE c_seg_rule_details;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.check_copy_seg_rule_details');

END check_copy_seg_rule_details;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| rule_in_use_by_adr                                                    |
|                                                                       |
| Checks if the segment rule is used by another ADR                     |
|                                                                       |
+======================================================================*/
FUNCTION rule_in_use_by_adr
  (p_event                            IN  VARCHAR2
  ,p_application_id                   IN  NUMBER
  ,p_amb_context_code                 IN  VARCHAR2
  ,p_segment_rule_type_code           IN  VARCHAR2
  ,p_segment_rule_code                IN  VARCHAR2
  ,p_parent_seg_rule_appl_name        IN OUT NOCOPY VARCHAR2
  ,p_parent_segment_rule_type         IN OUT NOCOPY VARCHAR2
  ,p_parent_segment_rule_name         IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

  CURSOR c_adr_exist
  IS
  SELECT application_id
        ,amb_context_code
        ,segment_rule_type_code
        ,segment_rule_code
    FROM xla_seg_rule_details
   WHERE amb_context_code                   = p_amb_context_code
     AND value_segment_rule_appl_id         = p_application_id
     AND value_segment_rule_type_code       = p_segment_rule_type_code
     AND value_segment_rule_code            = p_segment_rule_code;

  l_adr                c_adr_exist%rowtype;
  l_application_name   varchar2(240);
  l_segment_rule_type  varchar2(80);
  l_segment_rule_name  varchar2(80);

  l_return            BOOLEAN;


BEGIN

   OPEN c_adr_exist;
   FETCH c_adr_exist
    INTO l_adr;
   IF c_adr_exist%found then

       xla_validations_pkg.get_segment_rule_info
           (p_application_id             => l_adr.application_id
           ,p_amb_context_code           => l_adr.amb_context_code
           ,p_segment_rule_type_code     => l_adr.segment_rule_type_code
           ,p_segment_rule_code          => l_adr.segment_rule_code
           ,p_application_name           => l_application_name
           ,p_segment_rule_name          => l_segment_rule_name
           ,p_segment_rule_type          => l_segment_rule_type);
     l_return := TRUE;
   ELSE
     l_return := FALSE;
   END IF;
   CLOSE c_adr_exist;

   p_parent_seg_rule_appl_name    := l_application_name;
   p_parent_segment_rule_name     := l_segment_rule_name;
   p_parent_segment_rule_type     := l_segment_rule_type;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.rule_in_use_by_adr');

END rule_in_use_by_adr;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| parent_seg_rule_is_locked                                             |
|                                                                       |
| Checks if the segment rule is used by a locked ADR                    |
|                                                                       |
+======================================================================*/
FUNCTION parent_seg_rule_is_locked
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN BOOLEAN
IS

  CURSOR c_parent_seg_rules
  IS
  SELECT application_id
        ,amb_context_code
        ,segment_rule_type_code
        ,segment_rule_code
   FROM xla_seg_rule_details s
  WHERE value_segment_rule_appl_id   = p_application_id
    AND value_segment_rule_type_code = p_segment_rule_type_code
    AND value_segment_rule_code      = p_segment_rule_code;

  l_parent_seg_rules  c_parent_seg_rules%rowtype;

  l_return BOOLEAN := FALSE;

BEGIN

  OPEN c_parent_seg_rules;
  LOOP
    FETCH c_parent_seg_rules
     INTO l_parent_seg_rules;
    EXIT WHEN c_parent_seg_rules%notfound or l_return = TRUE;

    IF seg_rule_is_locked
        (p_application_id                   => l_parent_seg_rules.application_id
        ,p_amb_context_code                 => l_parent_seg_rules.amb_context_code
        ,p_segment_rule_type_code           => l_parent_seg_rules.segment_rule_type_code
        ,p_segment_rule_code                => l_parent_seg_rules.segment_rule_code) THEN

        l_return := TRUE;

    END IF;
  END LOOP;
  CLOSE c_parent_seg_rules;

  return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_seg_rules_pkg.parent_seg_rule_is_locked');

END parent_seg_rule_is_locked;


END xla_seg_rules_pkg;

/
