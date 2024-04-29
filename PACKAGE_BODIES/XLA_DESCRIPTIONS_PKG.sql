--------------------------------------------------------
--  DDL for Package Body XLA_DESCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_DESCRIPTIONS_PKG" AS
/* $Header: xlaamdad.pkb 120.20 2005/04/28 18:42:32 masada ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_descriptions_pkg                                               |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Descriptions Package                                           |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

TYPE t_array_codes         IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE t_array_type_codes    IS TABLE OF VARCHAR2(1)  INDEX BY BINARY_INTEGER;

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
C_DEFAULT_MODULE      CONSTANT VARCHAR2(240) := 'xla.plsql.xla_descriptions_pkg';

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
      (p_location   => 'xla_descriptions_pkg.trace');
END trace;


/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| delete_description_details                                            |
|                                                                       |
| Deletes all details of the description                                |
|                                                                       |
+======================================================================*/

PROCEDURE delete_description_details
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_description_type_code           IN VARCHAR2
  ,p_description_code                IN VARCHAR2)
IS

   l_description_prio_id    NUMBER(38);

   CURSOR c_description_priorities
   IS
   SELECT description_prio_id
     FROM xla_desc_priorities
    WHERE application_id        = p_application_id
      AND amb_context_code      = p_amb_context_code
      AND description_type_code = p_description_type_code
      AND description_code      = p_description_code;

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.delete_description_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure delete_description_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'application_id = '||p_application_id||
                       ',amb_context_code = '||p_amb_context_code||
                       ',description_type_code = '||p_description_type_code||
                       ',description_code = '||p_description_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   OPEN c_description_priorities;
   LOOP
      FETCH c_description_priorities
       INTO l_description_prio_id;
      EXIT WHEN c_description_priorities%notfound;

      xla_conditions_pkg.delete_condition
        (p_context                 => 'D'
        ,p_description_prio_id     => l_description_prio_id);

      xla_descript_details_pkg.delete_desc_prio_details
        (p_description_prio_id     => l_description_prio_id);

   END LOOP;
   CLOSE c_description_priorities;

   DELETE
     FROM xla_desc_priorities
    WHERE application_id           = p_application_id
      AND amb_context_code         = p_amb_context_code
      AND description_type_code    = p_description_type_code
      AND description_code         = p_description_code;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure delete_description_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_description_priorities%ISOPEN THEN
         CLOSE c_description_priorities;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_description_priorities%ISOPEN THEN
         CLOSE c_description_priorities;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descriptions_pkg.delete_description_details');

END delete_description_details;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| copy_description_details                                              |
|                                                                       |
| Copies details of a description into a new description                |
|                                                                       |
+======================================================================*/

PROCEDURE copy_description_details
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_old_description_type_code       IN VARCHAR2
  ,p_old_description_code            IN VARCHAR2
  ,p_new_description_type_code       IN VARCHAR2
  ,p_new_description_code            IN VARCHAR2
  ,p_old_transaction_coa_id          IN NUMBER
  ,p_new_transaction_coa_id          IN NUMBER)

IS

   l_row_id                           ROWID;
   l_condition_id                    integer;
   l_new_description_prio_id         integer;
   l_description_detail_id           integer;
   l_creation_date                   DATE;
   l_last_update_date                DATE;
   l_created_by                      INTEGER;
   l_last_update_login               INTEGER;
   l_last_updated_by                 INTEGER;
   l_flexfield_segment_code          VARCHAR2(30);
   l_flexfield_segment_name          VARCHAR2(80);
   l_con_flexfield_segment_code      VARCHAR2(30);
   l_con_v_flexfield_segment_code    VARCHAR2(30);
   l_inp_flex_appl_id                NUMBER(15);
   l_inp_id_flex_code                VARCHAR2(30);
   l_source_flex_appl_id             NUMBER(15);
   l_source_id_flex_code             VARCHAR2(30);
   l_value_source_flex_appl_id       NUMBER(15);
   l_value_source_id_flex_code       VARCHAR2(30);

   CURSOR c_description_priorities
   IS
   SELECT description_prio_id, user_sequence
     FROM xla_desc_priorities
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND description_type_code  = p_old_description_type_code
      AND description_code       = p_old_description_code;

   l_description_priority     c_description_priorities%rowtype;

   CURSOR c_description_details
   IS
   SELECT user_sequence, value_type_code, literal, source_application_id,
          source_type_code, source_code, flexfield_segment_code, display_description_flag
     FROM xla_descript_details_vl
    WHERE description_prio_id    = l_description_priority.description_prio_id;

   l_description_detail     c_description_details%rowtype;

   CURSOR c_det_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_description_detail.source_application_id
      AND source_type_code = l_description_detail.source_type_code
      AND source_code      = l_description_detail.source_code;

   CURSOR c_detail_conditions
   IS
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE description_prio_id = l_description_priority.description_prio_id;

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

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.copy_description_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure copy_description_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'application_id = '||p_application_id||
                       ',amb_context_code = '||p_amb_context_code||
                       ',old_description_type_code = '||p_old_description_type_code||
                       ',old_description_code = '||p_old_description_code||
                       ',new_description_type_code = '||p_new_description_type_code||
                       ',new_description_code = '||p_new_description_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   l_creation_date           := sysdate;
   l_last_update_date        := sysdate;
   l_created_by              := xla_environment_pkg.g_usr_id;
   l_last_update_login       := xla_environment_pkg.g_login_id;
   l_last_updated_by         := xla_environment_pkg.g_usr_id;

   OPEN c_description_priorities;
   LOOP
      FETCH c_description_priorities
       INTO l_description_priority;
      EXIT WHEN c_description_priorities%notfound;

      SELECT xla_desc_priorities_s.nextval
        INTO l_new_description_prio_id
        FROM DUAL;

      INSERT INTO xla_desc_priorities
        (description_prio_id
        ,application_id
        ,amb_context_code
        ,description_type_code
        ,description_code
        ,user_sequence
        ,creation_date
        ,created_by
        ,last_update_date
        ,last_updated_by
        ,last_update_login)
      VALUES
        (l_new_description_prio_id
        ,p_application_id
        ,p_amb_context_code
        ,p_new_description_type_code
        ,p_new_description_code
        ,l_description_priority.user_sequence
        ,l_creation_date
        ,l_created_by
        ,l_last_update_date
        ,l_last_updated_by
        ,l_last_update_login);

      OPEN c_description_details;
      LOOP
         FETCH c_description_details
          INTO l_description_detail;
         EXIT WHEN c_description_details%notfound;

         IF l_description_detail.flexfield_segment_code is not null THEN
            OPEN c_det_source;
            FETCH c_det_source
             INTO l_inp_flex_appl_id, l_inp_id_flex_code;
            CLOSE c_det_source;

            IF l_inp_flex_appl_id = 101 and l_inp_id_flex_code = 'GL#' THEN

               IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                  l_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_description_detail.flexfield_segment_code);

                ELSE
                   l_flexfield_segment_code := l_description_detail.flexfield_segment_code;
                END IF;
            ELSE
               -- Other key flexfield segment
               l_flexfield_segment_code := l_description_detail.flexfield_segment_code;
            END IF;
         ELSE
            -- value_flexfield_segment_code is null
            l_flexfield_segment_code := l_description_detail.flexfield_segment_code;
         END IF;


         SELECT xla_descript_details_s.nextval
           INTO l_description_detail_id
           FROM DUAL;

	   xla_descript_details_f_pkg.insert_row
	     (x_rowid                            => l_row_id
	     ,x_description_detail_id            => l_description_detail_id
	     ,x_description_prio_id              => l_new_description_prio_id
         ,x_amb_context_code                 => p_amb_context_code
	     ,x_user_sequence                    => l_description_detail.user_sequence
      	 ,x_value_type_code                  => l_description_detail.value_type_code
	     ,x_source_application_id            => l_description_detail.source_application_id
	     ,x_source_type_code                 => l_description_detail.source_type_code
	     ,x_source_code                      => l_description_detail.source_code
	     ,x_flexfield_segment_code           => l_flexfield_segment_code
	     ,x_literal                          => l_description_detail.literal
         ,x_display_description_flag         => l_description_detail.display_description_flag
	     ,x_creation_date                    => l_creation_date
	     ,x_created_by                       => l_created_by
	     ,x_last_update_date                 => l_last_update_date
	     ,x_last_updated_by                  => l_last_updated_by
	     ,x_last_update_login                => l_last_update_login);

      END LOOP;
      CLOSE c_description_details;

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
           ,description_prio_id
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
           ,l_new_description_prio_id
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
   CLOSE c_description_priorities;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure copy_description_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;


EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_description_details%ISOPEN THEN
         CLOSE c_description_details;
      END IF;
      IF c_description_priorities%ISOPEN THEN
         CLOSE c_description_priorities;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_description_details%ISOPEN THEN
         CLOSE c_description_details;
      END IF;
      IF c_description_priorities%ISOPEN THEN
         CLOSE c_description_priorities;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descriptions_pkg.copy_description_details');

END copy_description_details;

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
  ,p_description_type_code            IN VARCHAR2
  ,p_description_code                 IN VARCHAR2
  ,x_product_rule_name                IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type                IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                 IN OUT NOCOPY VARCHAR2
  ,x_line_definition_name             IN OUT NOCOPY VARCHAR2
  ,x_line_definition_owner            IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return   BOOLEAN;
   l_exist    VARCHAR2(1);

   l_application_name      varchar2(80);
   l_product_rule_name     varchar2(80);
   l_product_rule_type     varchar2(80);
   l_event_class_name      varchar2(80);
   l_line_definition_owner varchar2(80);
   l_line_definition_name  varchar2(80);

   CURSOR c_header_assign_exist
   IS
   SELECT application_id, amb_context_code, product_rule_type_code, product_rule_code,
          entity_code, event_class_code
     FROM xla_prod_acct_headers
    WHERE application_id        = p_application_id
      AND amb_context_code      = p_amb_context_code
      AND description_type_code = p_description_type_code
      AND description_code      = p_description_code;

   l_header_assign_exist          c_header_assign_exist%rowtype;

   CURSOR c_line_assign_exist
   IS
   SELECT line_definition_owner_code, line_definition_code,
          event_class_code, event_type_code
     FROM xla_line_defn_jlt_assgns
    WHERE application_id        = p_application_id
      AND amb_context_code      = p_amb_context_code
      AND description_type_code = p_description_type_code
      AND description_code      = p_description_code;

   l_line_assign_exist          c_line_assign_exist%rowtype;

   CURSOR c_active_assign_exist
   IS
   SELECT line_definition_owner_code, line_definition_code,
          event_class_code, event_type_code
     FROM xla_line_defn_jlt_assgns
    WHERE application_id        = p_application_id
      AND amb_context_code      = p_amb_context_code
      AND description_type_code = p_description_type_code
      AND description_code      = p_description_code
      AND active_flag          = 'Y';

   l_active_assign_exist          c_active_assign_exist%rowtype;

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.rule_in_use';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure rule_in_use'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'event = '||p_event||
                       ',application_id = '||p_application_id||
                       ',amb_context_code = '||p_amb_context_code||
                       ',description_type_code = '||p_description_type_code||
                       ',description_code = '||p_description_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   l_application_name      := null;
   l_product_rule_name     := null;
   l_product_rule_type     := null;
   l_event_class_name      := null;
   l_line_definition_owner := null;
   l_line_definition_name  := null;

   IF p_event in ('DELETE','UPDATE') THEN
      OPEN c_header_assign_exist;
      FETCH c_header_assign_exist
       INTO l_header_assign_exist;
      IF c_header_assign_exist%found then
         l_return := TRUE;

         xla_validations_pkg.get_product_rule_info
           (p_application_id          => l_header_assign_exist.application_id
           ,p_amb_context_code        => l_header_assign_exist.amb_context_code
           ,p_product_rule_type_code  => l_header_assign_exist.product_rule_type_code
           ,p_product_rule_code       => l_header_assign_exist.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

         xla_validations_pkg.get_event_class_info
           (p_application_id          => l_header_assign_exist.application_id
           ,p_entity_code             => l_header_assign_exist.entity_code
           ,p_event_class_code        => l_header_assign_exist.event_class_code
           ,p_event_class_name        => l_event_class_name);

      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_header_assign_exist;

      IF l_return = FALSE THEN
         OPEN c_line_assign_exist;
         FETCH c_line_assign_exist
          INTO l_line_assign_exist;
         IF c_line_assign_exist%found then
            l_return := TRUE;

         xla_line_definitions_pvt.get_line_definition_info
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_event_class_code           => l_line_assign_exist.event_class_code
           ,p_event_type_code            => l_line_assign_exist.event_type_code
           ,p_line_definition_owner_code => l_line_assign_exist.line_definition_owner_code
           ,p_line_definition_code       => l_line_assign_exist.line_definition_code
           ,x_line_definition_name       => l_line_definition_name
           ,x_line_definition_owner      => l_line_definition_owner);

         ELSE
            l_return := FALSE;
         END IF;
         CLOSE c_line_assign_exist;
      END IF;

   ELSIF p_event = 'DISABLE' THEN
      OPEN c_header_assign_exist;
      FETCH c_header_assign_exist
       INTO l_header_assign_exist;
      IF c_header_assign_exist%found then
         l_return := TRUE;

         xla_validations_pkg.get_product_rule_info
           (p_application_id          => l_header_assign_exist.application_id
           ,p_amb_context_code        => l_header_assign_exist.amb_context_code
           ,p_product_rule_type_code  => l_header_assign_exist.product_rule_type_code
           ,p_product_rule_code       => l_header_assign_exist.product_rule_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

         xla_validations_pkg.get_event_class_info
           (p_application_id          => l_header_assign_exist.application_id
           ,p_entity_code             => l_header_assign_exist.entity_code
           ,p_event_class_code        => l_header_assign_exist.event_class_code
           ,p_event_class_name        => l_event_class_name);

      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_header_assign_exist;

      IF l_return = FALSE THEN
         OPEN c_active_assign_exist;
         FETCH c_active_assign_exist
          INTO l_active_assign_exist;
         IF c_active_assign_exist%found then
            l_return := TRUE;

         xla_line_definitions_pvt.get_line_definition_info
           (p_application_id             => p_application_id
           ,p_amb_context_code           => p_amb_context_code
           ,p_event_class_code           => l_active_assign_exist.event_class_code
           ,p_event_type_code            => l_active_assign_exist.event_type_code
           ,p_line_definition_owner_code => l_active_assign_exist.line_definition_owner_code
           ,p_line_definition_code       => l_active_assign_exist.line_definition_code
           ,x_line_definition_name       => l_line_definition_name
           ,x_line_definition_owner      => l_line_definition_owner);

         ELSE
            l_return := FALSE;
         END IF;
         CLOSE c_active_assign_exist;
      END IF;

   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Invalid event passed'
        ,'LOCATION' ,'xla_descriptions_pkg.rule_in_use');

   END IF;

   x_product_rule_name     := l_product_rule_name;
   x_product_rule_type     := l_product_rule_type;
   x_event_class_name      := l_event_class_name;
   x_line_definition_owner := l_line_definition_owner;
   x_line_definition_name  := l_line_definition_name;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure rule_in_use'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;


   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_header_assign_exist%ISOPEN THEN
         CLOSE c_header_assign_exist;
      END IF;
      IF c_line_assign_exist%ISOPEN THEN
         CLOSE c_line_assign_exist;
      END IF;
      IF c_active_assign_exist%ISOPEN THEN
         CLOSE c_active_assign_exist;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_header_assign_exist%ISOPEN THEN
         CLOSE c_header_assign_exist;
      END IF;
      IF c_line_assign_exist%ISOPEN THEN
         CLOSE c_line_assign_exist;
      END IF;
      IF c_active_assign_exist%ISOPEN THEN
         CLOSE c_active_assign_exist;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descriptions_pkg.rule_in_use');

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
  ,p_description_type_code            IN  VARCHAR2
  ,p_description_code                 IN  VARCHAR2
  ,p_message_name                     OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_application_id         NUMBER(38);
   l_amb_context_code       VARCHAR2(30);
   l_description_type_code  VARCHAR2(1);
   l_description_code       VARCHAR2(30);
   l_return                 BOOLEAN;
   l_exist                  VARCHAR2(1);
   l_message_name           VARCHAR2(30);

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.rule_is_invalid';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure rule_is_invalid'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'application_id = '||p_application_id||
                       ',amb_context_code = '||p_amb_context_code||
                       ',description_type_code = '||p_description_type_code||
                       ',description_code = '||p_description_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   l_application_id          := p_application_id;
   l_amb_context_code        := p_amb_context_code;
   l_description_type_code   := p_description_type_code;
   l_description_code        := p_description_code;

   IF xla_conditions_pkg.desc_condition_is_invalid
              (p_application_id        => l_application_id
              ,p_amb_context_code      => l_amb_context_code
              ,p_description_type_code => l_description_type_code
              ,p_description_code      => l_description_code
              ,p_message_name          => l_message_name)
   THEN
      p_message_name := l_message_name;
      l_return := TRUE;
   ELSE
      p_message_name := NULL;
      l_return := FALSE;
   END IF;

   xla_utility_pkg.trace('p_message_name       = '||p_message_name     , 20);
   xla_utility_pkg.trace('< xla_descriptions_pkg.rule_is_invalid'    , 10);

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure rule_is_invalid'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descriptions_pkg.rule_is_invalid');

END rule_is_invalid;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| description_is_locked                                                 |
|                                                                       |
| Returns true if the description is locked                             |
|                                                                       |
+======================================================================*/

FUNCTION description_is_locked
  (p_application_id                  IN  NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_description_type_code           IN  VARCHAR2
  ,p_description_code                IN  VARCHAR2)
RETURN BOOLEAN
IS

   l_return               BOOLEAN;
   l_exist                VARCHAR2(1);

   CURSOR c_frozen_header_assign_exist
   IS
   SELECT 'x'
     FROM xla_prod_acct_headers h
    WHERE application_id        = p_application_id
      AND amb_context_code      = p_amb_context_code
      AND description_type_code = p_description_type_code
      AND description_code      = p_description_code
      AND locking_status_flag   = 'Y';

   CURSOR c_frozen_line_assign_exist
   IS
   SELECT 'x'
      FROM xla_line_defn_jlt_assgns xjl
          ,xla_aad_line_defn_assgns xal
          ,xla_prod_acct_headers    xpa
     WHERE xpa.application_id             = xal.application_id
       AND xpa.amb_context_code           = xal.amb_context_code
       AND xpa.product_rule_type_code     = xal.product_rule_type_code
       AND xpa.product_rule_code          = xal.product_rule_code
       AND xpa.event_class_code           = xal.event_class_code
       AND xpa.event_type_code            = xal.event_type_code
       AND xpa.locking_status_flag        = 'Y'
       AND xal.application_id             = xjl.application_id
       AND xal.amb_context_code           = xjl.amb_context_code
       AND xal.event_class_code           = xjl.event_class_code
       AND xal.event_type_code            = xjl.event_type_code
       AND xal.line_definition_owner_code = xjl.line_definition_owner_code
       AND xal.line_definition_code       = xjl.line_definition_code
       AND xjl.application_id             = p_application_id
       AND xjl.amb_context_code           = p_amb_context_code
       AND xjl.description_type_code      = p_description_type_code
       AND xjl.description_code           = p_description_code;

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.description_is_locked';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure description_is_locked'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'application_id = '||p_application_id||
                       ',amb_context_code = '||p_amb_context_code||
                       ',description_type_code = '||p_description_type_code||
                       ',description_code = '||p_description_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   OPEN c_frozen_header_assign_exist;
   FETCH c_frozen_header_assign_exist
    INTO l_exist;
   IF c_frozen_header_assign_exist%found then
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_frozen_header_assign_exist;

   IF l_return = FALSE THEN
      OPEN c_frozen_line_assign_exist;
      FETCH c_frozen_line_assign_exist
       INTO l_exist;
      IF c_frozen_line_assign_exist%found then
         l_return := TRUE;
      ELSE
         l_return := FALSE;
      END IF;
      CLOSE c_frozen_line_assign_exist;
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure description_is_locked'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_frozen_header_assign_exist%ISOPEN THEN
         CLOSE c_frozen_header_assign_exist;
      END IF;
      IF c_frozen_line_assign_exist%ISOPEN THEN
         CLOSE c_frozen_line_assign_exist;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_frozen_header_assign_exist%ISOPEN THEN
         CLOSE c_frozen_header_assign_exist;
      END IF;
      IF c_frozen_line_assign_exist%ISOPEN THEN
         CLOSE c_frozen_line_assign_exist;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descriptions_pkg.description_is_locked');

END description_is_locked;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_definitions                                                 |
|                                                                       |
| Returns true if the application accounting definition and journal     |
| line definitions using the description are uncompiled                 |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_definitions
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_description_type_code           IN VARCHAR2
  ,p_description_code                IN VARCHAR2
  ,x_product_rule_name               IN OUT NOCOPY VARCHAR2
  ,x_product_rule_type               IN OUT NOCOPY VARCHAR2
  ,x_event_class_name                IN OUT NOCOPY VARCHAR2
  ,x_event_type_name                 IN OUT NOCOPY VARCHAR2
  ,x_locking_status_flag             IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

  l_return               BOOLEAN := TRUE;
  l_exist                VARCHAR2(1);

  l_application_name      varchar2(240);
  l_product_rule_name     varchar2(80);
  l_product_rule_type     varchar2(80);
  l_event_class_name      varchar2(80);
  l_event_type_name       varchar2(80);

  l_locked_entity_code            VARCHAR2(30);
  l_locked_event_class_code       VARCHAR2(30);
  l_locked_event_type_code        VARCHAR2(30);
  l_locked_aad_type_code          VARCHAR2(30);
  l_locked_aad_code               VARCHAR2(30);
  l_locking_status_flag           VARCHAR2(1);

  CURSOR c_lock_line_aads IS
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
       AND xjl.description_type_code      = p_description_type_code
       AND xjl.description_code           = p_description_code
       FOR UPDATE NOWAIT;

   CURSOR c_lock_header_aads IS
    SELECT xpa.entity_code
         , xpa.event_class_code
         , xpa.event_type_code
         , xpa.product_rule_type_code
         , xpa.product_rule_code
         , xpa.locking_status_flag
         , xpa.validation_status_code
      FROM xla_prod_acct_headers       xpa
     WHERE xpa.application_id          = p_application_id
       AND xpa.amb_context_code        = p_amb_context_code
       AND xpa.description_type_code   = p_description_type_code
       AND xpa.description_code        = p_description_code
       FOR UPDATE NOWAIT;

   CURSOR c_update_aads IS
    SELECT xpa.event_class_code
         , xpa.product_rule_type_code
         , xpa.product_rule_code
      FROM xla_prod_acct_headers      xpa
     WHERE xpa.application_id         = p_application_id
       AND xpa.amb_context_code       = p_amb_context_code
       AND xpa.description_type_code  = p_description_type_code
       AND xpa.description_code       = p_description_code
     UNION
    SELECT xpa.event_class_code
         , xpa.product_rule_type_code
         , xpa.product_rule_code
      FROM xla_prod_acct_headers        xpa
          ,xla_aad_line_defn_assgns     xal
          ,xla_line_defn_jlt_assgns     xjl
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
       AND xjl.description_type_code      = p_description_type_code
       AND xjl.description_code           = p_description_code;

   l_event_class_codes       t_array_codes;
   l_product_rule_type_codes t_array_type_codes;
   l_product_rule_codes      t_array_codes;

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.uncompile_definitions';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure uncompile_definitions'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

  IF (C_LEVEL_STATEMENT >= g_log_level) THEN
    trace(p_msg    => 'application_id = '||p_application_id||
                      ',amb_context_code = '||p_amb_context_code||
                      ',description_type_code = '||p_description_type_code||
                      ',description_code = '||p_description_code
         ,p_module => l_log_module
         ,p_level  => C_LEVEL_STATEMENT);
  END IF;

  l_application_name       := null;
  l_product_rule_name      := null;
  l_product_rule_type      := null;
  l_event_class_name       := null;
  l_event_type_name        := null;
  l_locking_status_flag    := null;

  l_return := TRUE;

  FOR l_lock_aad IN c_lock_header_aads LOOP
     IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
         l_lock_aad.locking_status_flag    = 'Y') THEN

       l_locked_entity_code         := l_lock_aad.entity_code;
       l_locked_event_class_code    := l_lock_aad.event_class_code;
       l_locked_event_type_code     := l_lock_aad.event_type_code;
       l_locked_aad_type_code       := l_lock_aad.product_rule_type_code;
       l_locked_aad_code            := l_lock_aad.product_rule_code;
       l_locking_status_flag        := l_lock_aad.locking_status_flag;

       l_return := FALSE;
       EXIT;
     END IF;
  END LOOP;

  IF (l_return) THEN
    FOR l_lock_aad IN c_lock_line_aads LOOP
       IF (l_lock_aad.validation_status_code NOT IN ('E', 'Y', 'N') OR
           l_lock_aad.locking_status_flag    = 'Y') THEN

         l_locked_entity_code         := l_lock_aad.entity_code;
         l_locked_event_class_code    := l_lock_aad.event_class_code;
         l_locked_event_type_code     := l_lock_aad.event_type_code;
         l_locked_aad_type_code       := l_lock_aad.product_rule_type_code;
         l_locked_aad_code            := l_lock_aad.product_rule_code;
         l_locking_status_flag        := l_lock_aad.locking_status_flag;

         l_return := FALSE;
         EXIT;
       END IF;
    END LOOP;
  END IF;

  IF (NOT l_return) THEN

    xla_validations_pkg.get_product_rule_info
           (p_application_id          => p_application_id
           ,p_amb_context_code        => p_amb_context_code
           ,p_product_rule_type_code  => l_locked_aad_type_code
           ,p_product_rule_code       => l_locked_aad_code
           ,p_application_name        => l_application_name
           ,p_product_rule_name       => l_product_rule_name
           ,p_product_rule_type       => l_product_rule_type);

    xla_validations_pkg.get_event_class_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_locked_entity_code
           ,p_event_class_code        => l_locked_event_class_code
           ,p_event_class_name        => l_event_class_name);

    xla_validations_pkg.get_event_type_info
           (p_application_id          => p_application_id
           ,p_entity_code             => l_locked_entity_code
           ,p_event_class_code        => l_locked_event_class_code
           ,p_event_type_code         => l_locked_event_type_code
           ,p_event_type_name         => l_event_type_name);

  ELSE
    UPDATE xla_line_definitions_b xld
       SET validation_status_code     = 'N'
         , last_update_date           = sysdate
         , last_updated_by            = xla_environment_pkg.g_usr_id
         , last_update_login          = xla_environment_pkg.g_login_id
     WHERE xld.application_id         = p_application_id
       AND xld.amb_context_code       = p_amb_context_code
       AND xld.validation_status_code <> 'N'
       AND EXISTS
           (SELECT 1
              FROM xla_line_defn_jlt_assgns xjl
             WHERE xjl.application_id             = p_application_id
               AND xjl.amb_context_code           = p_amb_context_code
               AND xjl.description_type_code      = p_description_type_code
               AND xjl.description_code           = p_description_code
               AND xjl.event_class_code           = xld.event_class_code
               AND xjl.event_type_code            = xld.event_type_code
               AND xjl.line_definition_owner_code = xld.line_definition_owner_code
               AND xjl.line_definition_code       = xld.line_definition_code);

    OPEN c_update_aads;
    FETCH c_update_aads BULK COLLECT INTO l_event_class_codes
                                         ,l_product_rule_type_codes
                                         ,l_product_rule_codes;
    CLOSE c_update_aads;

    IF (C_LEVEL_EVENT >= g_log_level) THEN
      trace(p_msg    => 'l_event_class_codes.count = '||l_event_class_codes.count,
            p_module => l_log_module,
            p_level  => C_LEVEL_EVENT);
    END IF;

    IF (l_event_class_codes.count > 0) THEN

      FORALL i IN 1..l_event_class_codes.LAST
        UPDATE xla_product_rules_b
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
        UPDATE xla_prod_acct_headers
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

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure uncompile_definitions'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_update_aads%ISOPEN THEN
         CLOSE c_update_aads;
      END IF;
      IF c_lock_line_aads%ISOPEN THEN
         CLOSE c_lock_line_aads;
      END IF;
      IF c_lock_header_aads%ISOPEN THEN
         CLOSE c_lock_header_aads;
      END IF;

      RAISE;
   WHEN OTHERS                                   THEN
      IF c_update_aads%ISOPEN THEN
         CLOSE c_update_aads;
      END IF;
      IF c_lock_line_aads%ISOPEN THEN
         CLOSE c_lock_line_aads;
      END IF;
      IF c_lock_header_aads%ISOPEN THEN
         CLOSE c_lock_header_aads;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descriptions_pkg.uncompile_definitions');

END uncompile_definitions;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| check_copy_description_details                                        |
|                                                                       |
| Checks if description can be copied                                   |
|                                                                       |
+======================================================================*/

FUNCTION check_copy_description_details
  (p_application_id                  IN NUMBER
  ,p_amb_context_code                IN VARCHAR2
  ,p_old_description_type_code       IN VARCHAR2
  ,p_old_description_code            IN VARCHAR2
  ,p_old_transaction_coa_id          IN NUMBER
  ,p_new_transaction_coa_id          IN NUMBER
  ,p_message                         IN OUT NOCOPY VARCHAR2
  ,p_token_1                         IN OUT NOCOPY VARCHAR2
  ,p_value_1                         IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN

IS

   l_row_id                           ROWID;
   l_condition_id                    integer;
   l_new_description_prio_id         integer;
   l_description_detail_id           integer;
   l_flexfield_segment_code          VARCHAR2(30);
   l_flexfield_segment_name          VARCHAR2(80);
   l_con_flexfield_segment_code      VARCHAR2(30);
   l_con_v_flexfield_segment_code    VARCHAR2(30);
   l_con_flexfield_segment_name      VARCHAR2(80);
   l_con_v_flexfield_segment_name    VARCHAR2(80);
   l_inp_flex_appl_id                NUMBER(15);
   l_inp_id_flex_code                VARCHAR2(30);
   l_source_flex_appl_id             NUMBER(15);
   l_source_id_flex_code             VARCHAR2(30);
   l_value_source_flex_appl_id       NUMBER(15);
   l_value_source_id_flex_code       VARCHAR2(30);
   l_return                          BOOLEAN := TRUE;

   CURSOR c_description_priorities
   IS
   SELECT description_prio_id, user_sequence
     FROM xla_desc_priorities
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND description_type_code  = p_old_description_type_code
      AND description_code       = p_old_description_code;

   l_description_priority     c_description_priorities%rowtype;

   CURSOR c_description_details
   IS
   SELECT user_sequence, value_type_code, literal, source_application_id,
          source_type_code, source_code, flexfield_segment_code, display_description_flag
     FROM xla_descript_details_vl
    WHERE description_prio_id    = l_description_priority.description_prio_id;

   l_description_detail     c_description_details%rowtype;

   CURSOR c_det_source
   IS
   SELECT flexfield_application_id, id_flex_code
     FROM xla_sources_b
    WHERE application_id   = l_description_detail.source_application_id
      AND source_type_code = l_description_detail.source_type_code
      AND source_code      = l_description_detail.source_code;

   CURSOR c_detail_conditions
   IS
   SELECT user_sequence, bracket_left_code, bracket_right_code, value_type_code,
          source_application_id, source_type_code, source_code,
          flexfield_segment_code, value_flexfield_segment_code,
          value_source_application_id, value_source_type_code,
          value_source_code, value_constant, line_operator_code,
          logical_operator_code, independent_value_constant
     FROM xla_conditions
    WHERE description_prio_id = l_description_priority.description_prio_id;

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

   l_log_module  VARCHAR2(240);
BEGIN
   IF g_log_enabled THEN
     l_log_module := C_DEFAULT_MODULE||'.check_copy_description_details';
   END IF;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'BEGIN of procedure check_copy_description_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   IF (C_LEVEL_STATEMENT >= g_log_level) THEN
     trace(p_msg    => 'application_id = '||p_application_id||
                       ',amb_context_code = '||p_amb_context_code||
                       ',old_description_type_code = '||p_old_description_type_code||
                       ',old_description_code = '||p_old_description_code
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_STATEMENT);
   END IF;

   OPEN c_description_priorities;
   LOOP
      FETCH c_description_priorities
       INTO l_description_priority;
      EXIT WHEN c_description_priorities%notfound or l_return = FALSE;

      OPEN c_description_details;
      LOOP
         FETCH c_description_details
          INTO l_description_detail;
         EXIT WHEN c_description_details%notfound or l_return = FALSE;

         IF l_description_detail.flexfield_segment_code is not null THEN
            OPEN c_det_source;
            FETCH c_det_source
             INTO l_inp_flex_appl_id, l_inp_id_flex_code;
            CLOSE c_det_source;

            IF l_inp_flex_appl_id = 101 and l_inp_id_flex_code = 'GL#' THEN

               IF p_new_transaction_coa_id is not null and p_old_transaction_coa_id is null THEN
                  l_flexfield_segment_code := xla_flex_pkg.get_qualifier_segment
                                                (p_application_id    => 101
                                                ,p_id_flex_code      => 'GL#'
                                                ,p_id_flex_num       => p_new_transaction_coa_id
                                                ,p_qualifier_segment => l_description_detail.flexfield_segment_code);

                  IF l_flexfield_segment_code is null THEN
                    l_flexfield_segment_name := xla_flex_pkg.get_qualifier_name
                                               (p_application_id    => 101
                                               ,p_id_flex_code      => 'GL#'
                                               ,p_qualifier_segment => l_description_detail.flexfield_segment_code);

                    p_message := 'XLA_AB_TRX_COA_NO_QUAL';
                    p_token_1 := 'QUALIFIER_NAME';
                    p_value_1 := l_flexfield_segment_name;
                    l_return := FALSE;

                  END IF;
                END IF;
            END IF;
         END IF;
      END LOOP;
      CLOSE c_description_details;

      IF l_return = TRUE THEN

         OPEN c_detail_conditions;
         LOOP
            FETCH c_detail_conditions
             INTO l_detail_condition;
            EXIT WHEN c_detail_conditions%notfound or l_return = FALSE ;

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
   CLOSE c_description_priorities;

   IF (C_LEVEL_PROCEDURE >= g_log_level) THEN
     trace(p_msg    => 'END of procedure check_copy_description_details'
          ,p_module => l_log_module
          ,p_level  => C_LEVEL_PROCEDURE);
   END IF;

   RETURN l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_description_details%ISOPEN THEN
         CLOSE c_description_details;
      END IF;
      IF c_description_priorities%ISOPEN THEN
         CLOSE c_description_priorities;
      END IF;
      RAISE;
   WHEN OTHERS                                   THEN
      IF c_detail_conditions%ISOPEN THEN
         CLOSE c_detail_conditions;
      END IF;
      IF c_description_details%ISOPEN THEN
         CLOSE c_description_details;
      END IF;
      IF c_description_priorities%ISOPEN THEN
         CLOSE c_description_priorities;
      END IF;
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_descriptions_pkg.check_copy_description_details');

END check_copy_description_details;

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


END xla_descriptions_pkg;

/
