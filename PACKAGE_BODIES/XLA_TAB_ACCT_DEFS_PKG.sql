--------------------------------------------------------
--  DDL for Package Body XLA_TAB_ACCT_DEFS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_TAB_ACCT_DEFS_PKG" AS
/* $Header: xlatabtad.pkb 120.1 2005/04/18 22:12:06 dcshah ship $ */
/*======================================================================+
|             Copyright (c) 1995-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_tab_acct_defs_pkg                                              |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Tab Acct Defs Package                                          |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|                                                                       |
+======================================================================*/

/*======================================================================+
|                                                                       |
| Private Function                                                      |
|                                                                       |
| invalid_seg_rule                                                      |
|                                                                       |
| Returns true if sources for the seg rule are invalid                  |
|                                                                       |
+======================================================================*/

FUNCTION invalid_seg_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_account_type_code                IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2
  ,p_message_name                     IN OUT NOCOPY VARCHAR2
  ,p_source_name                      IN OUT NOCOPY VARCHAR2
  ,p_source_type                      IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS

   l_return                  BOOLEAN;
   l_exist                   VARCHAR2(1);
   l_application_id          NUMBER(38)   := p_application_id;
   l_account_type_code       VARCHAR2(30) := p_account_type_code;
   l_source_name             varchar2(80) := null;
   l_source_type             varchar2(80) := null;

   CURSOR c_seg_details
   IS
   SELECT 'x'
     FROM xla_seg_rule_details d
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code;

   CURSOR c_seg_value_sources
   IS
   SELECT value_source_type_code source_type_code, value_source_code source_code
     FROM xla_seg_rule_details d
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code
      AND value_source_code is not null
      AND value_source_type_code = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_tab_acct_type_srcs s
                       WHERE s.source_application_id = d.value_source_application_id
                         AND s.source_type_code      = d.value_source_type_code
                         AND s.source_code           = d.value_source_code
                         AND s.application_id        = p_application_id
                         AND s.account_type_code     = p_account_type_code)
   UNION
   SELECT input_source_type_code source_type_code, input_source_code source_code
     FROM xla_seg_rule_details d
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code
      AND input_source_code is not null
      AND input_source_type_code = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_tab_acct_type_srcs s
                       WHERE s.source_application_id = d.input_source_application_id
                         AND s.source_type_code      = d.input_source_type_code
                         AND s.source_code           = d.input_source_code
                         AND s.application_id        = p_application_id
                         AND s.account_type_code     = p_account_type_code);

   l_seg_value_sources         c_seg_value_sources%rowtype;

   CURSOR c_seg_condition_sources
   IS
   SELECT c.source_type_code, c.source_code
     FROM xla_conditions c, xla_seg_rule_details d
    WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
      AND d.application_id         = p_application_id
      AND d.amb_context_code       = p_amb_context_code
      AND d.segment_rule_type_code = p_segment_rule_type_code
      AND d.segment_rule_code      = p_segment_rule_code
      AND c.source_code is not null
      AND c.source_type_code       = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_tab_acct_type_srcs s
                       WHERE s.source_application_id = c.source_application_id
                         AND s.source_type_code      = c.source_type_code
                         AND s.source_code           = c.source_code
                         AND s.application_id        = p_application_id
                         AND s.account_type_code     = p_account_type_code)
   UNION
   SELECT c.value_source_type_code source_type_code, c.value_source_code source_code
     FROM xla_conditions c, xla_seg_rule_details d
    WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
      AND d.application_id         = p_application_id
      AND d.amb_context_code       = p_amb_context_code
      AND d.segment_rule_type_code = p_segment_rule_type_code
      AND d.segment_rule_code      = p_segment_rule_code
      AND c.value_source_code is not null
      AND c.value_source_type_code = 'S'
      AND NOT EXISTS (SELECT 'y'
                        FROM xla_tab_acct_type_srcs s
                       WHERE s.source_application_id = c.value_source_application_id
                         AND s.source_type_code      = c.value_source_type_code
                         AND s.source_code           = c.value_source_code
                         AND s.application_id        = p_application_id
                         AND s.account_type_code     = p_account_type_code);

   l_seg_condition_sources         c_seg_condition_sources%rowtype;

   CURSOR c_seg_value_der_sources
   IS
   SELECT value_source_type_code source_type_code, value_source_code source_code
     FROM xla_seg_rule_details d
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code
      AND value_source_code is not null
      AND value_source_type_code = 'D'
   UNION
   SELECT input_source_type_code source_type_code, input_source_code source_code
     FROM xla_seg_rule_details d
    WHERE application_id         = p_application_id
      AND amb_context_code       = p_amb_context_code
      AND segment_rule_type_code = p_segment_rule_type_code
      AND segment_rule_code      = p_segment_rule_code
      AND input_source_code is not null
      AND input_source_type_code = 'D';

   l_seg_value_der_sources         c_seg_value_der_sources%rowtype;

   CURSOR c_seg_condition_der_sources
   IS
   SELECT c.source_type_code source_type_code, c.source_code source_code
     FROM xla_conditions c, xla_seg_rule_details d
    WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
      AND d.application_id         = p_application_id
      AND d.amb_context_code       = p_amb_context_code
      AND d.segment_rule_type_code = p_segment_rule_type_code
      AND d.segment_rule_code      = p_segment_rule_code
      AND c.source_code is not null
      AND c.source_type_code       = 'D'
   UNION
   SELECT c.value_source_type_code source_type_code, c.value_source_code source_code
     FROM xla_conditions c, xla_seg_rule_details d
    WHERE c.segment_rule_detail_id = d.segment_rule_detail_id
      AND d.application_id         = p_application_id
      AND d.amb_context_code       = p_amb_context_code
      AND d.segment_rule_type_code = p_segment_rule_type_code
      AND d.segment_rule_code      = p_segment_rule_code
      AND c.value_source_code is not null
      AND c.value_source_type_code = 'D';

   l_seg_condition_der_sources         c_seg_condition_der_sources%rowtype;

BEGIN

   xla_utility_pkg.trace('> xla_tab_acct_defs_pkg.invalid_seg_rule'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code , 20);
   xla_utility_pkg.trace('segment_rule_code  = '||p_segment_rule_code     , 20);

      --
      -- check if segment rules has details existing
      --
      OPEN c_seg_details;
      FETCH c_seg_details
       INTO l_exist;
      IF c_seg_details%notfound then
         p_message_name := 'XLA_AB_SR_NO_DETAIL';
         l_return := TRUE;
      ELSE
         p_message_name := NULL;
         l_return := FALSE;
      END IF;
      CLOSE c_seg_details;

      IF l_return = FALSE THEN
         --
         -- check if segment rules has sources that do not belong to the event class
         --

         OPEN c_seg_value_sources;
         FETCH c_seg_value_sources
          INTO l_seg_value_sources;
         IF c_seg_value_sources%found then

            xla_validations_pkg.get_source_info
              (p_application_id    => l_application_id
              ,p_source_type_code  => l_seg_value_sources.source_type_code
              ,p_source_code       => l_seg_value_sources.source_code
              ,p_source_name       => l_source_name
              ,p_source_type       => l_source_type);

            p_message_name := 'XLA_AB_SR_UNASSN_SOURCE';
            p_source_name  := l_source_name;
            p_source_type  := l_source_type;

            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;
         CLOSE c_seg_value_sources;
      END IF;

      IF l_return = FALSE THEN
         OPEN c_seg_condition_sources;
         FETCH c_seg_condition_sources
          INTO l_seg_condition_sources;
         IF c_seg_condition_sources%found then

            xla_validations_pkg.get_source_info
              (p_application_id    => l_application_id
              ,p_source_type_code  => l_seg_condition_sources.source_type_code
              ,p_source_code       => l_seg_condition_sources.source_code
              ,p_source_name       => l_source_name
              ,p_source_type       => l_source_type);

            p_message_name := 'XLA_AB_SR_CON_UNASN_SRCE';
            p_source_name  := l_source_name;
            p_source_type  := l_source_type;

            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;
         CLOSE c_seg_condition_sources;
      END IF;

/*      IF l_return = FALSE THEN
         OPEN c_seg_value_der_sources;
         LOOP
         FETCH c_seg_value_der_sources
          INTO l_seg_value_der_sources;
         EXIT WHEN c_seg_value_der_sources%notfound or l_return = TRUE;

         IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => l_application_id
              ,p_derived_source_code      => l_seg_value_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_account_type_code        => l_account_type_code
              ,p_level                    => 'L') = 'TRUE' THEN

            xla_validations_pkg.get_source_info
              (p_application_id    => l_application_id
              ,p_source_type_code  => l_seg_value_der_sources.source_type_code
              ,p_source_code       => l_seg_value_der_sources.source_code
              ,p_source_name       => l_source_name
              ,p_source_type       => l_source_type);

            p_message_name := 'XLA_AB_SR_UNASSN_SOURCE';
            p_source_name  := l_source_name;
            p_source_type  := l_source_type;

            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;
         END LOOP;
         CLOSE c_seg_value_der_sources;
      END IF;

      IF l_return = FALSE THEN
         OPEN c_seg_condition_der_sources;
         LOOP
         FETCH c_seg_condition_der_sources
          INTO l_seg_condition_der_sources;
         EXIT WHEN c_seg_condition_der_sources%notfound or l_return = TRUE;

         IF xla_sources_pkg.derived_source_is_invalid
              (p_application_id           => l_application_id
              ,p_derived_source_code      => l_seg_condition_der_sources.source_code
              ,p_derived_source_type_code => 'D'
              ,p_account_type_code        => l_account_type_code
              ,p_level                    => 'L') = 'TRUE' THEN

            xla_validations_pkg.get_source_info
              (p_application_id    => l_application_id
              ,p_source_type_code  => l_seg_condition_der_sources.source_type_code
              ,p_source_code       => l_seg_condition_der_sources.source_code
              ,p_source_name       => l_source_name
              ,p_source_type       => l_source_type);

            p_message_name := 'XLA_AB_SR_CON_UNASN_SRCE';
            p_source_name  := l_source_name;
            p_source_type  := l_source_type;

            l_return := TRUE;
         ELSE
            p_message_name := NULL;
            l_return := FALSE;
         END IF;
         END LOOP;
         CLOSE c_seg_condition_der_sources;
      END IF;
*/

   xla_utility_pkg.trace('< xla_tab_acct_defs_pkg.invalid_seg_rule'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      IF c_seg_condition_sources%ISOPEN THEN
         CLOSE c_seg_condition_sources;
      END IF;
      IF c_seg_value_sources%ISOPEN THEN
         CLOSE c_seg_value_sources;
      END IF;
      IF c_seg_condition_der_sources%ISOPEN THEN
         CLOSE c_seg_condition_der_sources;
      END IF;
      IF c_seg_value_der_sources%ISOPEN THEN
         CLOSE c_seg_value_der_sources;
      END IF;
      RAISE;

   WHEN OTHERS                                   THEN
      IF c_seg_condition_sources%ISOPEN THEN
         CLOSE c_seg_condition_sources;
      END IF;
      IF c_seg_value_sources%ISOPEN THEN
         CLOSE c_seg_value_sources;
      END IF;
      IF c_seg_condition_der_sources%ISOPEN THEN
         CLOSE c_seg_condition_der_sources;
      END IF;
      IF c_seg_value_der_sources%ISOPEN THEN
         CLOSE c_seg_value_der_sources;
      END IF;

      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tab_acct_defs_pkg.invalid_seg_rule');

END invalid_seg_rule;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| invalid_segment_rule                                                  |
|                                                                       |
| Returns true if sources for the seg rule are invalid                  |
|                                                                       |
+======================================================================*/

FUNCTION invalid_segment_rule
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_account_type_code                IN VARCHAR2
  ,p_segment_rule_type_code           IN VARCHAR2
  ,p_segment_rule_code                IN VARCHAR2)
RETURN VARCHAR2
IS
   l_return                  VARCHAR2(30);
   l_exist                   VARCHAR2(1);
   l_application_id          NUMBER(38)   := p_application_id;
   l_account_type_code       VARCHAR2(30) := p_account_type_code;
   l_amb_context_code        VARCHAR2(30) := p_amb_context_code;
   l_segment_rule_type_code  VARCHAR2(1)  := p_segment_rule_type_code;
   l_segment_rule_code       VARCHAR2(30) := p_segment_rule_code;
   l_message_name            VARCHAR2(30);

   l_source_name             varchar2(80) := null;
   l_source_type             varchar2(80) := null;

BEGIN

   xla_utility_pkg.trace('> xla_tab_acct_defs_pkg.invalid_segment_rule'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);
   xla_utility_pkg.trace('segment_rule_type_code  = '||p_segment_rule_type_code , 20);
   xla_utility_pkg.trace('segment_rule_code  = '||p_segment_rule_code     , 20);

      --
      -- call invalid_seg_rule to see if segment rule is invalid
      --
      IF xla_tab_acct_defs_pkg.invalid_seg_rule
           (p_application_id           => l_application_id
           ,p_amb_context_code         => l_amb_context_code
           ,p_account_type_code        => l_account_type_code
           ,p_segment_rule_type_code   => l_segment_rule_type_code
           ,p_segment_rule_code        => l_segment_rule_code
           ,p_message_name             => l_message_name
           ,p_source_name              => l_source_name
           ,p_source_type              => l_source_type) THEN

         l_return := 'TRUE';
      ELSE
         l_return := 'FALSE';
      END IF;

   xla_utility_pkg.trace('< xla_tab_acct_defs_pkg.invalid_segment_rule'    , 10);
   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;

   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tab_acct_defs_pkg.invalid_segment_rule');

END invalid_segment_rule;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| uncompile_tran_acct_def                                               |
|                                                                       |
| Returns true if the transaction account definition is uncompiled      |
|                                                                       |
+======================================================================*/

FUNCTION uncompile_tran_acct_def
  (p_application_id                   IN NUMBER
  ,p_amb_context_code                 IN VARCHAR2
  ,p_account_definition_type_code     IN VARCHAR2
  ,p_account_definition_code          IN VARCHAR2)
RETURN BOOLEAN
IS

   l_return                BOOLEAN;
   l_exist                 VARCHAR2(1);

   CURSOR c_prod_rules
   IS
   SELECT 'x'
     FROM xla_tab_acct_defs_b
    WHERE application_id                  = p_application_id
      AND amb_context_code                = p_amb_context_code
      AND account_definition_type_code    = p_account_definition_type_code
      AND account_definition_code         = p_account_definition_code
      AND compile_status_code       in ('E','N','Y')
      AND locking_status_flag       = 'N'
   FOR UPDATE of compile_status_code NOWAIT;

BEGIN


   xla_utility_pkg.trace('> xla_tab_acct_defs_pkg.uncompile_tran_acct_def'   , 10);

   xla_utility_pkg.trace('application_id      = '||p_application_id  , 20);

   OPEN c_prod_rules;
   FETCH c_prod_rules
    INTO l_exist;
   IF c_prod_rules%found then

      UPDATE xla_tab_acct_defs_b
         SET compile_status_code = 'N'
       WHERE current of c_prod_rules;

      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_prod_rules;


   xla_utility_pkg.trace('< xla_tab_acct_defs_pkg.uncompile_tran_acct_def'    , 10);

   return l_return;

EXCEPTION
   WHEN xla_exceptions_pkg.application_exception THEN
      RAISE;
   WHEN OTHERS                                   THEN
      xla_exceptions_pkg.raise_message
        (p_location   => 'xla_tab_acct_defs_pkg.uncompile_tran_acct_def');

END uncompile_tran_acct_def;

END xla_tab_acct_defs_pkg;

/
