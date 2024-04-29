--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_RULE_PVT" 
/* $Header: OKCVXIRB.pls 120.0.12010000.2 2011/02/07 13:34:38 serukull noship $ */
AS
   g_clause_rule_type           VARCHAR2 (30)           := 'CLAUSE_SELECTION';
   g_term_dev_rule_type         VARCHAR2 (30)             := 'TERM_DEVIATION';
   g_clause                     VARCHAR2 (30)                     := 'CLAUSE';
   g_question                   VARCHAR2 (30)                   := 'QUESTION';
   g_variable                   VARCHAR2 (30)                   := 'VARIABLE';
   g_rule_id                    okc_xprt_rule_hdrs_all.rule_id%TYPE;
   g_rule_intent                VARCHAR2 (1);
   g_rule_type                  VARCHAR2 (30);
   g_rule_status_code           VARCHAR2 (30);
   g_org_wide_flag              VARCHAR2 (1);
   g_org_id                     NUMBER;
   g_rule_outcome_id            okc_xprt_rule_outcomes.rule_outcome_id%TYPE;
   g_rule_condition_value_id    okc_xprt_rule_cond_vals.rule_condition_value_id%TYPE;
   g_rule_condition_id          okc_xprt_rule_conditions.rule_condition_id%TYPE;
   l_okc_i_not_null             VARCHAR2 (30)             := 'OKC_I_NOT_NULL';
   l_okc_i_invalid_value        VARCHAR2 (30)        := 'OKC_I_INVALID_VALUE';
   l_field                      VARCHAR2 (30)                      := 'FIELD';
   g_rule_count                 NUMBER;
   g_rule_condition_count       NUMBER;
   g_rule_condition_val_count   NUMBER;
   g_rule_outcome_count         NUMBER;
   g_rule_template_rule_count   NUMBER;


   g_unexpected_error CONSTANT VARCHAR2 (200) := 'OKC_UNEXPECTED_ERROR';
   g_sqlerrm_token         CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
   g_sqlcode_token         CONSTANT VARCHAR2 (200) := 'ERROR_CODE';

   -- Need to check uniquiness of condition
   PROCEDURE create_rule (p_rule_rec IN OUT NOCOPY rule_rec_type);

   PROCEDURE create_rule_header (
      p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type
   );

   PROCEDURE create_rule_header (
      p_rule_header_tbl   IN OUT NOCOPY   rule_header_tbl_type
   );

   PROCEDURE create_rule_condition (
      p_rule_condition_rec   IN OUT NOCOPY   rule_condition_rec_type
   );

   PROCEDURE create_rule_condition (
      p_rule_condition_tbl   IN OUT NOCOPY   rule_condition_tbl_type
   );

   PROCEDURE create_rule_condn_value (
      p_rule_condition_id    IN              NUMBER,
      p_rule_cond_vals_tbl   IN OUT NOCOPY   rule_cond_vals_tbl_type
   );

   PROCEDURE create_rule_outcome (
      p_rule_outcome_rec   IN OUT NOCOPY   rule_outcome_rec_type
   );

   PROCEDURE create_rule_outcome (
      p_rule_outcome_tbl   IN OUT NOCOPY   rule_outcome_tbl_type
   );

   PROCEDURE create_template_rules (
      p_template_rules_rec   IN OUT NOCOPY   template_rules_rec_type
   );

   PROCEDURE create_template_rules (
      p_template_rules_tbl   IN OUT NOCOPY   template_rules_tbl_type
   );

   PROCEDURE update_rule_header (
      p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type
   );

   PROCEDURE update_rule (p_rule_rec IN OUT NOCOPY rule_rec_type);

   PROCEDURE delete_rule_child_entities (
      p_rule_child_entities_rec   IN OUT NOCOPY   rule_child_entities_rec_type
   );

-------------------------------
-- PRIVATE PROCEDURES        --
-------------------------------
   FUNCTION isValidLookup(p_lookup_type VARCHAR2,p_lookup_code   VARCHAR2)
   RETURN VARCHAR2
   IS

        CURSOR c_validate_lookup
         IS
            SELECT 'Y'
              FROM fnd_lookup_values
             WHERE lookup_type = p_lookup_type
               AND lookup_code = p_lookup_code
               AND LANGUAGE = 'US'
               AND enabled_flag = 'Y'
               AND NVL (end_date_active, SYSDATE) >= SYSDATE;
               l_flag VARCHAR2(1);
   BEGIN
       OPEN c_validate_lookup;
       FETCH c_validate_lookup INTO l_flag;
       CLOSE c_validate_lookup;

       RETURN Nvl(l_flag,'N');

   EXCEPTION WHEN OTHERS THEN
     RETURN 'N';
   END;
   FUNCTION is_valid_rule (p_rule_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_flag   VARCHAR2 (1);
   BEGIN
      SELECT 'Y'
        INTO l_flag
        FROM okc_xprt_rule_hdrs_all
       WHERE rule_id = p_rule_id AND org_id = g_org_id;

      IF NVL (l_flag, 'N') = 'Y'
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_valid_rule;

   FUNCTION get_rule_type (p_rule_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_rule_type   okc_xprt_rule_hdrs_all.rule_type%TYPE;
   BEGIN
      SELECT rule_type
        INTO l_rule_type
        FROM okc_xprt_rule_hdrs_all
       WHERE rule_id = p_rule_id;

      RETURN l_rule_type;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_rule_type;

   -- To get LHS side values
   PROCEDURE get_question_details (
      p_question_id         IN              NUMBER,
      x_question_datatype   OUT NOCOPY      VARCHAR2,
      x_value_set_name      OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      SELECT question_datatype, value_set_name
        INTO x_question_datatype, x_value_set_name
        FROM okc_xprt_questions_b
       WHERE question_id = p_question_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END get_question_details;

   -- This function used to test validity of LHS value
   FUNCTION is_valid_question (p_question_id IN NUMBER, p_intent IN VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR cur_validate_question
      IS
         SELECT 'Y'
           FROM okc_xprt_questions_b
          WHERE question_type = 'Q'              -- Question Type must be 'Q'
            AND NVL (disabled_flag, 'N') = 'N'
            -- Disabled questions must not be available in the Rule creation/updataion
            AND question_intent = p_intent
            AND question_id = p_question_id;

      l_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_validate_question;

      FETCH cur_validate_question
       INTO l_flag;

      CLOSE cur_validate_question;

      IF NVL (l_flag, 'N') = 'Y'
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_valid_question;

   -- This function used to test validity of LHS value
   PROCEDURE is_valid_variable (
      p_variable_code       IN              VARCHAR2,
      p_intent              IN              VARCHAR2,
      x_valid_variable      OUT NOCOPY      VARCHAR2,
      x_vlaue_set_id        OUT NOCOPY      NUMBER,
      x_value_set_name      OUT NOCOPY      VARCHAR2,
      x_variable_datatype   OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      SELECT 'Y', var1.value_set_id, var1.value_set_name,
             var1.variable_datatype
        INTO x_valid_variable, x_vlaue_set_id, x_value_set_name,
             x_variable_datatype
        FROM (SELECT variable_intent, variable_code, variable_name,
                     a.description, xprt_value_set_name value_set_name,
                     variable_datatype, b.longlist_flag, b.validation_type,
                     b.flex_value_set_id value_set_id, variable_type,
                     vartype.meaning var_type_meaning
                FROM okc_bus_variables_v a,
                     fnd_flex_value_sets b,
                     fnd_lookups vartype
               WHERE contract_expert_yn = 'Y'
                 AND variable_datatype <> 'D'
                 AND a.xprt_value_set_name = b.flex_value_set_name(+)
                 AND vartype.lookup_type = 'OKC_ART_VAR_TYPE'
                 AND vartype.lookup_code = variable_type
              UNION
              SELECT variable_intent, variable_code, variable_name,
                     a.description, flex_value_set_name value_set_name,
                     variable_datatype, b.longlist_flag, b.validation_type,
                     b.flex_value_set_id value_set_id, variable_type,
                     vartype.meaning var_type_meaning
                FROM okc_bus_variables_v a,
                     fnd_flex_value_sets b,
                     fnd_lookups vartype
               WHERE a.variable_type = 'U'
                 AND a.value_set_id = b.flex_value_set_id
                 AND (   (    b.validation_type IN ('I', 'X', 'F')
                          AND b.format_type = 'C'
                         )
                      OR (a.variable_datatype = 'N'
                          AND b.validation_type = 'N'
                         )
                     )
                 AND vartype.lookup_type = 'OKC_ART_VAR_TYPE'
                 AND vartype.lookup_code = variable_type) var1
       WHERE var1.variable_code = p_variable_code
         AND var1.variable_intent = p_intent;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         x_vlaue_set_id := NULL;
         x_valid_variable := 'N';
         x_value_set_name := NULL;
         x_variable_datatype := NULL;
      WHEN OTHERS
      THEN
         x_vlaue_set_id := NULL;
         x_valid_variable := 'N';
         x_value_set_name := NULL;
         x_variable_datatype := NULL;
         RAISE;
   END is_valid_variable;

   -- This function used to test validity of RHS value
   FUNCTION is_valid_clause (p_article_id IN NUMBER, p_intent IN VARCHAR2)
      RETURN VARCHAR2
   IS
-- Need to check whether any conditions required for global clauses
-- Do not allow future dated clauses
-- Allow only standard clauses
-- Check Org ID
-- Get the validation from ArticlesSearchExpVO.xml
      CURSOR c_validate_clause
      IS
         SELECT 'Y'
           FROM okc_articles_all
          WHERE org_id = g_org_id
            AND standard_yn = 'Y'
            AND article_id = p_article_id
            AND article_intent = p_intent;

      CURSOR cur_val_adopted_article
      IS
         SELECT 'Y'
           FROM okc_articles_all art,
                okc_article_versions ver,
                okc_article_adoptions adp
          WHERE art.article_id = ver.article_id
            AND art.standard_yn = 'Y'
            AND ver.global_yn = 'Y'
            AND ver.article_status = 'APPROVED'
            AND adp.global_article_version_id = ver.article_version_id
            AND adp.adoption_type = 'ADOPTED'
            AND adp.adoption_status = 'APPROVED'
            AND art.article_id = p_article_id
            AND art.article_intent = p_intent
            AND adp.local_org_id = g_org_id;

      l_flag             VARCHAR2 (1);
      l_adopt_art_flag   VARCHAR2 (1);
   BEGIN
      OPEN c_validate_clause;

      FETCH c_validate_clause
       INTO l_flag;

      CLOSE c_validate_clause;

      IF NVL (l_flag, 'N') = 'Y'
      THEN
         RETURN 'Y';
      END IF;

      OPEN cur_val_adopted_article;

      FETCH cur_val_adopted_article
       INTO l_adopt_art_flag;

      CLOSE cur_val_adopted_article;

      RETURN NVL (l_adopt_art_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_valid_clause;

   -- This function used to test validity of RHS value
   FUNCTION is_valid_question (
      p_question_id         IN   NUMBER,
      p_intent              IN   VARCHAR2,
      p_question_datatype   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_validate_question
      IS
         SELECT 'Y'
           FROM okc_xprt_questions_b
          WHERE question_type = 'Q'              -- Question Type must be 'Q'
            AND NVL (disabled_flag, 'N') = 'N'
            -- Disabled questions must not be available in the Rule creation/updataion
            AND question_intent = p_intent
            AND question_id = p_question_id
            AND question_datatype = 'N';

      l_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_validate_question;

      FETCH cur_validate_question
       INTO l_flag;

      CLOSE cur_validate_question;

      IF NVL (l_flag, 'N') = 'Y'
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_valid_question;

   -- This function used to test validity of RHS value
   FUNCTION is_valid_constant (p_constant_id IN NUMBER, p_intent IN VARCHAR2)
      RETURN VARCHAR2
   IS
      CURSOR cur_validate_constant
      IS
         SELECT 'Y'
           FROM okc_xprt_questions_b
          WHERE question_type = 'C'              -- Constant Type must be 'Q'
            -- Disabled questions must not be available in the Rule creation/updataion
            AND question_intent = p_intent
            AND question_id = p_constant_id;

      l_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_validate_constant;

      FETCH cur_validate_constant
       INTO l_flag;

      CLOSE cur_validate_constant;

      IF NVL (l_flag, 'N') = 'Y'
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_valid_constant;

   -- This function used to test validity of RHS value
   FUNCTION is_valid_variable (
      p_variable_code   IN   VARCHAR2,
      p_intent          IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_validate_variable
      IS
         SELECT 'Y'
           FROM okc_bus_variables_v
          WHERE contract_expert_yn = 'Y'
            AND variable_datatype = 'N'
            AND variable_intent = p_intent
            AND variable_code = p_variable_code;

      l_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_validate_variable;

      FETCH cur_validate_variable
       INTO l_flag;

      CLOSE cur_validate_variable;

      IF NVL (l_flag, 'N') = 'Y'
      THEN
         RETURN 'Y';
      ELSE
         RETURN 'N';
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_valid_variable;

   PROCEDURE set_proc_error_message (p_proc IN VARCHAR2)
   IS
   BEGIN
      okc_api.set_message (p_app_name          => g_app_name,
                           p_msg_name          => 'OKC_I_ERROR_PROCEDURE',
                           p_token1            => 'PROCEDURE',
                           p_token1_value      => p_proc
                          );
   END set_proc_error_message;

   PROCEDURE set_rec_num_message (p_rec_num IN NUMBER)
   IS
   BEGIN
      okc_api.set_message (p_app_name          => g_app_name,
                           p_msg_name          => 'OKC_I_RECORD_NUM',
                           p_token1            => 'RECORD_NUM',
                           p_token1_value      => p_rec_num
                          );
   END set_rec_num_message;

-----------------------------------------------
   FUNCTION is_duplicate_outcome (
      p_rule_id           IN   NUMBER,
      p_object_type       IN   VARCHAR2,
      p_object_value_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_outcome_exists
      IS
         SELECT 'Y'
           FROM okc_xprt_rule_outcomes
          WHERE rule_id = p_rule_id
            AND object_type = p_object_type
            AND object_value_id = p_object_value_id;

      l_dup_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_outcome_exists;

      FETCH cur_outcome_exists
       INTO l_dup_flag;

      CLOSE cur_outcome_exists;

      RETURN NVL (l_dup_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_duplicate_outcome;

   -- This function is used to test the Outcome
   FUNCTION is_valid_outcome (
      p_rule_id           IN   NUMBER,
      p_object_type       IN   VARCHAR2,
      p_object_value_id   IN   NUMBER
   )
      RETURN VARCHAR2
   /*
      Need to check ON-HOLD and Expiry clauses in Outcome
      But as of now excluding the valdiation. Need to do this in future.
      Source: RulesAMImpl.java Method: checkClauseOutcomes
   */
   IS
      l_intent   VARCHAR2 (30);
   BEGIN
      SELECT intent
        INTO l_intent
        FROM okc_xprt_rule_hdrs_all
       WHERE rule_id = p_rule_id;

      IF p_object_type = g_clause
      THEN
         RETURN is_valid_clause (p_article_id      => p_object_value_id,
                                 p_intent          => l_intent
                                );
      ELSIF p_object_type = g_question
      THEN
         RETURN is_valid_question (p_question_id      => p_object_value_id,
                                   p_intent           => l_intent
                                  );
      END IF;

      RETURN 'N';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END is_valid_outcome;

---------------------------------
   PROCEDURE validate_rule_condn_val_tbl (
      p_object_value_type    IN   VARCHAR2,
      p_rule_intent          IN   VARCHAR2,
      p_value_set_name       IN   VARCHAR2 DEFAULT NULL,
      p_rule_cond_vals_tbl   IN   rule_cond_vals_tbl_type
   )
   IS
-- Question
-- CHECK question_type='Q'
-- Check whether it is enabled
      l_validate_flag     VARCHAR2 (1);
      l_value_set_id      NUMBER;
      l_validation_type   VARCHAR2 (10);
      l_value             VARCHAR2 (1000);
      l_proc         VARCHAR2 (120)  := 'VALIDATE_RULE_CONDN_VAL_TBL';
      l_failed_rec_num    NUMBER          := 0;
   BEGIN
      IF p_object_value_type = 'CLAUSE'
      THEN
         FOR i IN p_rule_cond_vals_tbl.FIRST .. p_rule_cond_vals_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            IF is_valid_clause
                  (p_article_id      => TO_NUMBER
                                           (p_rule_cond_vals_tbl (i).object_value_code
                                           ),
                   p_intent          => p_rule_intent
                  ) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_COND_VALUE',
                                    p_token1            => 'ENTITY',
                                    p_token1_value      => p_object_value_type
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      ELSIF p_object_value_type = 'QUESTION'
      THEN
         FOR i IN p_rule_cond_vals_tbl.FIRST .. p_rule_cond_vals_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            IF is_valid_question
                  (p_question_id            => TO_NUMBER
                                                  (p_rule_cond_vals_tbl (i).object_value_code
                                                  ),
                   p_intent                 => p_rule_intent,
                   p_question_datatype      => 'N'
                  ) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_COND_VALUE',
                                    p_token1            => 'ENTITY',
                                    p_token1_value      => p_object_value_type
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      ELSIF p_object_value_type = 'CONSTANT'
      THEN
         FOR i IN p_rule_cond_vals_tbl.FIRST .. p_rule_cond_vals_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            IF is_valid_constant
                  (p_constant_id      => TO_NUMBER
                                            (p_rule_cond_vals_tbl (i).object_value_code
                                            ),
                   p_intent           => p_rule_intent
                  ) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_COND_VALUE',
                                    p_token1            => 'ENTITY',
                                    p_token1_value      => p_object_value_type
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      ELSIF p_object_value_type = 'VARIABLE'
      THEN
         FOR i IN p_rule_cond_vals_tbl.FIRST .. p_rule_cond_vals_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            IF is_valid_variable
                  (p_variable_code      => p_rule_cond_vals_tbl (i).object_value_code,
                   p_intent             => p_rule_intent
                  ) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_COND_VALUE',
                                    p_token1            => 'ENTITY',
                                    p_token1_value      => p_object_value_type
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      ELSIF p_object_value_type = 'VALUE'
      THEN
         SELECT flex_value_set_id, validation_type
           INTO l_value_set_id, l_validation_type
           FROM fnd_flex_value_sets
          WHERE flex_value_set_name = p_value_set_name;

         FOR i IN p_rule_cond_vals_tbl.FIRST .. p_rule_cond_vals_tbl.LAST
         LOOP
            l_failed_rec_num := i;
            l_value := NULL;
            l_value :=
               okc_xprt_util_pvt.get_valueset_value
                  (p_object_value_set_id      => l_value_set_id,
                   p_object_value_code        => p_rule_cond_vals_tbl (i).object_value_code,
                   p_validation_type          => l_validation_type
                  );

            IF l_value IS NULL
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_COND_VALUE',
                                    p_token1            => 'ENTITY',
                                    p_token1_value      => p_object_value_type
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         set_proc_error_message (p_proc => l_proc);
         set_rec_num_message (p_rec_num => l_failed_rec_num);
         RAISE;
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         set_rec_num_message (p_rec_num => l_failed_rec_num);
         RAISE;
   END validate_rule_condn_val_tbl;

---------------------------------

   /** Method checks if no clause/question exists in both condition and outcome */
   FUNCTION validaterulecondition (p_rule_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR cur_conditions
      IS
         SELECT object_type, object_code, rule_condition_id
           FROM okc_xprt_rule_conditions
          WHERE rule_id = p_rule_id;

      CURSOR cur_condn_values (p_rule_condition_id NUMBER)
      IS
         SELECT TO_NUMBER (object_value_code) clause_id
           FROM okc_xprt_rule_cond_vals
          WHERE rule_condition_id = p_rule_condition_id;

      l_proc             VARCHAR2 (60) := 'validateRuleCondition';
      l_failed_rec_num   NUMBER        := 0;
   BEGIN
      FOR l_rec IN cur_conditions
      LOOP
         IF l_rec.object_type = g_question
         THEN
            -- A outcome exists with this question.
            IF is_duplicate_outcome (p_rule_id,
                                     l_rec.object_type,
                                     TO_NUMBER (l_rec.object_code)
                                    ) = 'Y'
            THEN
               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKC_XPRT_COND_OUTCOME_ERR'
                                   );
               set_proc_error_message (p_proc => l_proc);
               RETURN 'N';
            END IF;
         END IF;

         IF l_rec.object_type = g_clause
         THEN
            FOR clause_rec IN cur_condn_values (l_rec.rule_condition_id)
            LOOP
               -- A outcome exists with this clause.
               IF is_duplicate_outcome (p_rule_id,
                                        g_clause,
                                        clause_rec.clause_id
                                       ) = 'Y'
               THEN
                  okc_api.set_message
                                   (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKC_XPRT_COND_OUTCOME_ERR'
                                   );
                  set_proc_error_message (p_proc => l_proc);
                  RETURN 'N';
               END IF;
            END LOOP;
         END IF;
      END LOOP;

      RETURN 'Y';
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END validaterulecondition;

   PROCEDURE read_message (x_message IN OUT NOCOPY VARCHAR2)
   IS
      l_message   VARCHAR2 (2000);
   BEGIN
      FOR i IN 1 .. fnd_msg_pub.count_msg
      LOOP
         l_message := fnd_msg_pub.get (i, p_encoded => fnd_api.g_false);

         IF (LENGTH (l_message) + LENGTH (Nvl(x_message,' '))) <= 2500
         THEN
            x_message := x_message || l_message;
         ELSE
            EXIT;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END read_message;

   PROCEDURE create_rule_header (
      p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type
   )
   IS
      l_operating_unit   NUMBER;
      l_validate_flag    VARCHAR2 (1);
      l_proc             VARCHAR2 (120) := 'CREATE_RULE_HEADER';

      CURSOR cur_val_ou (p_org_id NUMBER)
      IS
         SELECT 'X'
           FROM hr_operating_units ou, hr_organization_information oi
          WHERE mo_global.check_access (ou.organization_id) = 'Y'
            AND oi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
            AND oi.organization_id = ou.organization_id
            AND NVL (date_to, SYSDATE) >= SYSDATE
            AND ou.organization_id = p_org_id;

      PROCEDURE default_rule_header (
         p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type
      )
      IS
         l_proc   VARCHAR2 (60) := 'DEFAULT_RULE_HEADER';
      BEGIN
         p_rule_header_rec.status_code := 'DRAFT';
         p_rule_header_rec.published_flag := 'N';
         p_rule_header_rec.object_version_number := 1;

         IF p_rule_header_rec.org_id = okc_api.g_miss_num
         THEN
            -- Derive the operating info
            p_rule_header_rec.org_id := mo_utils.get_default_org_id;
         END IF;

         -- IF  p_rule_header_rec.status_code = OKC_API.G_MISS_CHAR THEN
         -- END IF;
         IF p_rule_header_rec.org_wide_flag = okc_api.g_miss_char
         THEN
            p_rule_header_rec.org_wide_flag := 'N';
         END IF;

         --IF p_rule_header_rec.PUBLISHED_FLAG=OKC_API.G_MISS_CHAR THEN
         --END IF;
         IF p_rule_header_rec.line_level_flag = okc_api.g_miss_char
         THEN
            p_rule_header_rec.line_level_flag := NULL;
         END IF;

         -- Start Defaulting 'WHO' columns
         IF p_rule_header_rec.created_by = okc_api.g_miss_num
         THEN
            p_rule_header_rec.created_by := fnd_global.user_id;
         END IF;

         IF p_rule_header_rec.creation_date = okc_api.g_miss_date
         THEN
            p_rule_header_rec.creation_date := SYSDATE;
         END IF;

         IF p_rule_header_rec.last_updated_by = okc_api.g_miss_num
         THEN
            p_rule_header_rec.last_updated_by := fnd_global.user_id;
         END IF;

         IF p_rule_header_rec.last_update_date = okc_api.g_miss_date
         THEN
            p_rule_header_rec.last_update_date := SYSDATE;
         END IF;

         IF p_rule_header_rec.last_update_login = okc_api.g_miss_num
         THEN
            p_rule_header_rec.last_update_login := fnd_global.login_id;
         END IF;

         IF fnd_global.conc_request_id = -1
         THEN
            p_rule_header_rec.request_id := NULL;
         ELSE
            p_rule_header_rec.request_id := fnd_global.conc_request_id;
         END IF;

         IF fnd_global.conc_program_id = -1
         THEN
            p_rule_header_rec.program_id := NULL;
            p_rule_header_rec.program_update_date := NULL;
         ELSE
            p_rule_header_rec.program_id := fnd_global.conc_program_id;
            -- Directly initializing it to the sysdate
            p_rule_header_rec.program_update_date := SYSDATE;
         END IF;

         IF fnd_global.prog_appl_id = -1
         THEN
            p_rule_header_rec.program_application_id := NULL;
         ELSE
            p_rule_header_rec.program_application_id :=
                                                      fnd_global.prog_appl_id;
         END IF;
      END default_rule_header;

      PROCEDURE validate_header (p_rule_header_rec IN rule_header_rec_type)
      IS
         l_proc            VARCHAR2 (120) := 'VALIDATE_HEADER';

         CURSOR cur_rule_name_exists (p_rule_name VARCHAR2, p_org_id NUMBER)
         IS
            SELECT 'Y'
              FROM okc_xprt_rule_hdrs_all
             WHERE rule_name = p_rule_name AND org_id = p_org_id;

         l_validate_flag   VARCHAR2 (1);
      BEGIN
         IF p_rule_header_rec.org_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'ORG_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_rule_header_rec.intent IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'INTENT'
                                );
            RAISE fnd_api.g_exc_error;
         ELSE
            IF p_rule_header_rec.intent NOT IN ('B', 'S')
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'INTENT'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF p_rule_header_rec.rule_name IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_NAME'
                                );
            RAISE fnd_api.g_exc_error;
         ELSE
            OPEN cur_rule_name_exists (p_rule_header_rec.rule_name,
                                       p_rule_header_rec.org_id
                                      );

            FETCH cur_rule_name_exists
             INTO l_validate_flag;

            CLOSE cur_rule_name_exists;

            IF NVL (l_validate_flag, 'X') = 'Y'
            THEN
               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKC_XPRT_RULE_NAME_EXISTS'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            l_validate_flag := NULL;
         END IF;

         IF p_rule_header_rec.rule_type IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         ELSE
            -- verify the lookup from OKC_XPRT_RULE_TYPE and execlude the 'All' Type
            IF p_rule_header_rec.rule_type NOT IN
                                  (g_clause_rule_type, g_term_dev_rule_type)
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'RULE_TYPE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF p_rule_header_rec.condition_expr_code IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'CONDITION_EXPR_CODE'
                                );
            RAISE fnd_api.g_exc_error;

          ELSE
            -- OKC_XPRT_CONDITION_CRITERIA
            -- ALL -> Match all Conditions => All Conditions must be true
            -- ANY -> Match Any Condition
            IF p_rule_header_rec.condition_expr_code NOT IN ('ALL', 'ANY')
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'CONDITION_EXPR_CODE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF p_rule_header_rec.org_wide_flag NOT IN ('Y' , 'N') THEN
             okc_api.set_message (p_app_name          => g_app_name,
                                  p_msg_name          => l_okc_i_invalid_value,
                                  p_token1            => l_field,
                                  p_token1_value      => 'ORG_WIDE_FLAG'
                                 );
             RAISE fnd_api.g_exc_error;
         END IF;

      EXCEPTION
         WHEN fnd_api.g_exc_error
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END validate_header;
   BEGIN
      -- Default Header
      default_rule_header (p_rule_header_rec => p_rule_header_rec);

      -- Validate Operating Unit
      OPEN cur_val_ou (p_rule_header_rec.org_id);

      FETCH cur_val_ou
       INTO l_validate_flag;

      CLOSE cur_val_ou;

      IF NVL (l_validate_flag, 'Y') <> 'X'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_invalid_value,
                              p_token1            => l_field,
                              p_token1_value      => 'ORG_ID'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      l_validate_flag := NULL;

      -- Set Policy context
      mo_global.set_policy_context ('S', TO_CHAR (p_rule_header_rec.org_id));
      -- Validate Rule Header
         -- Rules
            -- Rule_Id => Can be generated from sequence  OKC_XPRT_RULE_HDRS_ALL_S
            -- Org_Id  => Derive or get it from the user input
            -- Intent  => User must pass the intent and the allowed values are 'B', 'S'
            -- Status_Code => Default to 'DRAFT'
            -- Rule_Name,CONDITION_EXPR_CODE,RULE_TYPE,
            -- PUBLISHED_FLAG,OBJECT_VERSION_NUMBER
            -- CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE
      validate_header (p_rule_header_rec => p_rule_header_rec);

      /*-- Get the rule id from Sequnce
      SELECT okc_xprt_rule_hdrs_all_s.NEXTVAL
        INTO p_rule_header_rec.rule_id
        FROM DUAL;*/

      -- Insert into Rule Header
      INSERT INTO okc_xprt_rule_hdrs_all
                  (rule_id,
                   org_id, intent,
                   status_code,
                   rule_name,
                   rule_description,
                   org_wide_flag,
                   published_flag,
                   condition_expr_code,
                   request_id,
                   object_version_number,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   program_id,
                   program_application_id,
                   program_update_date,
                   rule_type,
                   line_level_flag
                  )
           VALUES (okc_xprt_rule_hdrs_all_s.NEXTVAL,
                   p_rule_header_rec.org_id, p_rule_header_rec.intent,
                   p_rule_header_rec.status_code,
                   p_rule_header_rec.rule_name,
                   p_rule_header_rec.rule_description,
                   p_rule_header_rec.org_wide_flag,
                   p_rule_header_rec.published_flag,
                   p_rule_header_rec.condition_expr_code,
                   p_rule_header_rec.request_id,
                   p_rule_header_rec.object_version_number,
                   p_rule_header_rec.created_by,
                   p_rule_header_rec.creation_date,
                   p_rule_header_rec.last_updated_by,
                   p_rule_header_rec.last_update_date,
                   p_rule_header_rec.last_update_login,
                   p_rule_header_rec.program_id,
                   p_rule_header_rec.program_application_id,
                   p_rule_header_rec.program_update_date,
                   p_rule_header_rec.rule_type,
                   p_rule_header_rec.line_level_flag
                  )
        RETURNING rule_id
             INTO p_rule_header_rec.rule_id;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END create_rule_header;

   PROCEDURE create_rule_header (
      p_rule_header_tbl   IN OUT NOCOPY   rule_header_tbl_type
   )
   IS
   BEGIN
      IF p_rule_header_tbl.COUNT > 0
      THEN
         FOR i IN p_rule_header_tbl.FIRST .. p_rule_header_tbl.LAST
         LOOP
            create_rule_header (p_rule_header_rec => p_rule_header_tbl (i));
         END LOOP;
      END IF;
   END create_rule_header;

/*
  OBJECT_TYPE:  => Required
      Indicates if condition type is a clause, system or user defined variable or question.
      FK to FND lookup OKC_XPRT_COND_OBJECT_TYPE
      Valid values are CLAUSE, QUESTION, VARIABLE (System Variable)

  OBJECT_CODE:
      This is used where the condition types are either system or user defined variables or questoins.
      The code identifies the actual system or user defined variable or the question used in the condition.
      For clauses, this will be NULL.

  object_code_datatype:
      Indicates the datatype for the object_code. For Clause this is NULL.
      Used values are 'N': Numeric variable or Numeric Question, 'V': Character variable,
      'L': Character Question, 'B': Boolean (Yes/No) quesion.

  operator:  => Required
         Condition operator for Numeric variables and Questions: <=, >=, <>, = , >, <.
        For Character type variables and questions: IS, IS NOT, IN, NOT IN.

  object_value_set_name:
        FND value set name of Variables / Questions for the RHS of condition.

  object_value_type:     => Required
         Indicates if the RHS of condition is CLAUSE, VARIABLE, QUESTION, CONSTANT, VALUE.
          FK to FND lookup OKC_XPRT_COND_VALUE_TYPE

  object_value_code:
          Variable's value Id or Variable code or Clause Id or Constant Id or Question Id.
          This will be populated only if the condition has one value.

   Business Rules:
     Condition Type: The Clause type is available only for Clause Creation rules i.e
                     Rule type is: G_CLAUSE_RULE_TYPE

                     Variable: Use this type for the Clause Creation rules if a
                               system variable drives the clause selection on a business document.

                               For Policy Deviation rules, use this type if a system or user-defined variable
                               drives the policy deviation for a business document.

                     Question : Use this type if a user question should drive the clause selection or
                                policy deviation on business documents.

*/
   PROCEDURE create_rule_condition (
      p_rule_condition_rec   IN OUT NOCOPY   rule_condition_rec_type
   )
   IS
      l_rule_type           VARCHAR2 (30);
      l_rule_condition_id   NUMBER;

      PROCEDURE default_rule_condition (
         p_rule_condition_rec   IN OUT NOCOPY   rule_condition_rec_type
      )
      IS
      BEGIN
         IF p_rule_condition_rec.object_type = okc_api.g_miss_char
         THEN
            p_rule_condition_rec.object_type := NULL;
         END IF;

         IF p_rule_condition_rec.object_code = okc_api.g_miss_char
         THEN
            p_rule_condition_rec.object_code := NULL;
         END IF;

         IF p_rule_condition_rec.object_code_datatype = okc_api.g_miss_char
         THEN
            p_rule_condition_rec.object_code_datatype := NULL;
         END IF;

         IF p_rule_condition_rec.OPERATOR = okc_api.g_miss_char
         THEN
            p_rule_condition_rec.OPERATOR := NULL;
         END IF;

         IF p_rule_condition_rec.object_value_set_name = okc_api.g_miss_char
         THEN
            p_rule_condition_rec.object_value_set_name := NULL;
         END IF;

         IF p_rule_condition_rec.object_value_type = okc_api.g_miss_char
         THEN
            p_rule_condition_rec.object_value_type := NULL;
         END IF;

         IF p_rule_condition_rec.object_value_code = okc_api.g_miss_char
         THEN
            p_rule_condition_rec.object_value_code := NULL;
         END IF;

         IF p_rule_condition_rec.object_version_number = okc_api.g_miss_num
         THEN
            p_rule_condition_rec.object_version_number := 1;
         END IF;
      END default_rule_condition;

      PROCEDURE validate_rule_condition (
         p_rule_condition_rec   IN OUT NOCOPY   rule_condition_rec_type
      )
      IS
         CURSOR c_validate_lookup (
            p_lookup_type   VARCHAR2,
            p_lookup_code   VARCHAR2
         )
         IS
            SELECT 'Y'
              FROM fnd_lookup_values
             WHERE lookup_type = p_lookup_type
               AND lookup_code = p_lookup_code
               AND LANGUAGE = 'US'
               AND enabled_flag = 'Y'
               AND NVL (end_date_active, SYSDATE) >= SYSDATE;

         l_validate_flag       VARCHAR2 (1);
         i                     NUMBER;
         l_proc                VARCHAR2 (60)      := 'VALIDATE_RULE_CONDITION';
         l_rule_type           okc_xprt_rule_hdrs_all.rule_type%TYPE
                                                                := g_rule_type;
         l_rule_intent         okc_xprt_rule_hdrs_all.intent%TYPE
                                                              := g_rule_intent;
         l_question_datatype   VARCHAR2 (1);
         l_value_set_name      VARCHAR2 (60);
         l_operator_lookup     VARCHAR2 (240);
         x_valid_variable      VARCHAR2 (1);
         x_vlaue_set_id        NUMBER;
         x_value_set_name      VARCHAR2 (240);
         x_variable_datatype   VARCHAR2 (60);
      BEGIN
         /*
          SELECT rule_type, intent
            INTO l_rule_type, l_rule_intent
            FROM okc_xprt_rule_hdrs_all
           WHERE rule_id = p_rule_condition_rec.rule_id;

         */
         IF p_rule_condition_rec.rule_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_rule_condition_rec.object_type IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     p_rule_condition_rec.object_type <> 'CLAUSE'
            AND p_rule_condition_rec.object_code IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_CODE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;



         IF p_rule_condition_rec.OPERATOR IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OPERATOR'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     p_rule_condition_rec.object_type <> 'CLAUSE'
            AND p_rule_condition_rec.object_value_type IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_VALUE_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF NOT (p_rule_condition_rec.rule_cond_vals_tbl.COUNT > 0)
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_COND_VALS_TBL'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     l_rule_type = g_clause_rule_type
            AND p_rule_condition_rec.object_type NOT IN
                                           ('CLAUSE', 'QUESTION', 'VARIABLE')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     l_rule_type = g_term_dev_rule_type
            AND p_rule_condition_rec.object_type NOT IN
                                                     ('QUESTION', 'VARIABLE')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_rule_condition_rec.object_type = 'CLAUSE'
         THEN
            -- Set Object Code to null
            p_rule_condition_rec.object_code := NULL;
            -- Object Code type will also be null
            p_rule_condition_rec.object_code_datatype := NULL;

            -- Operator can't be null
            -- OKC_XPRT_CHAR_OPERATOR
            -- OKC_XPRT_NUMBER_OPERATOR
            OPEN c_validate_lookup ('OKC_XPRT_CHAR_OPERATOR',
                                    p_rule_condition_rec.OPERATOR
                                   );

            FETCH c_validate_lookup
             INTO l_validate_flag;

            IF c_validate_lookup%NOTFOUND
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'OPERATOR'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            CLOSE c_validate_lookup;

            -- Set the object_value_set_name to null;
            p_rule_condition_rec.object_value_set_name := NULL;
            -- set the  object_value_type  to 'CLAUSE'
            p_rule_condition_rec.object_value_type := 'CLAUSE';
            -- Validate the  p_rule_condition_rec.rule_cond_vals_tbl
            validate_rule_condn_val_tbl
               (p_object_value_type       => 'CLAUSE',
                p_rule_intent             => l_rule_intent,
                p_rule_cond_vals_tbl      => p_rule_condition_rec.rule_cond_vals_tbl
               );
         ELSIF p_rule_condition_rec.object_type = 'QUESTION'
         THEN
            IF is_valid_question
                  (p_question_id      => TO_NUMBER
                                             (p_rule_condition_rec.object_code),
                   p_intent           => l_rule_intent
                  ) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'OBJECT_CODE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            get_question_details
                (p_question_id            => TO_NUMBER
                                                (p_rule_condition_rec.object_code
                                                ),
                 x_question_datatype      => l_question_datatype,
                 x_value_set_name         => l_value_set_name
                );
            p_rule_condition_rec.object_code_datatype := l_question_datatype;
            p_rule_condition_rec.object_value_set_name := l_value_set_name;

            -- Operator can't be null
            -- OKC_XPRT_CHAR_OPERATOR
            -- OKC_XPRT_NUMBER_OPERATOR
            IF p_rule_condition_rec.object_code_datatype = 'B'
            THEN
               IF p_rule_condition_rec.OPERATOR NOT IN ('IS', 'IS_NOT')
               THEN
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => l_okc_i_invalid_value,
                                       p_token1            => l_field,
                                       p_token1_value      => 'OPERATOR'
                                      );
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSIF p_rule_condition_rec.object_code_datatype = 'L'
            THEN
               l_operator_lookup := 'OKC_XPRT_CHAR_OPERATOR';
            ELSIF p_rule_condition_rec.object_code_datatype = 'N'
            THEN
               l_operator_lookup := 'OKC_XPRT_NUMBER_OPERATOR';
            END IF;

            IF NVL (l_operator_lookup, 'X') IN
                       ('OKC_XPRT_CHAR_OPERATOR', 'OKC_XPRT_NUMBER_OPERATOR')
            THEN
               OPEN c_validate_lookup (l_operator_lookup,
                                       p_rule_condition_rec.OPERATOR
                                      );

               FETCH c_validate_lookup
                INTO l_validate_flag;

               IF c_validate_lookup%NOTFOUND
               THEN
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => l_okc_i_invalid_value,
                                       p_token1            => l_field,
                                       p_token1_value      => 'OPERATOR'
                                      );
                  RAISE fnd_api.g_exc_error;
               END IF;

               CLOSE c_validate_lookup;
            END IF;

            IF p_rule_condition_rec.object_value_type NOT IN
                                ('VALUE', 'QUESTION', 'VARIABLE', 'CONSTANT')
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'OBJECT_VALUE_TYPE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF     p_rule_condition_rec.object_type <> 'CLAUSE'
            AND p_rule_condition_rec.object_code_datatype IS NULL
            THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_CODE_DATATYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

            validate_rule_condn_val_tbl
               (p_object_value_type       => p_rule_condition_rec.object_value_type,
                p_rule_intent             => l_rule_intent,
                p_value_set_name          => p_rule_condition_rec.object_value_set_name,
                p_rule_cond_vals_tbl      => p_rule_condition_rec.rule_cond_vals_tbl
               );
         ELSIF p_rule_condition_rec.object_type = 'VARIABLE'
         THEN
            is_valid_variable
                        (p_variable_code          => p_rule_condition_rec.object_code,
                         p_intent                 => l_rule_intent,
                         x_valid_variable         => x_valid_variable,
                         x_vlaue_set_id           => x_vlaue_set_id,
                         x_value_set_name         => x_value_set_name,
                         x_variable_datatype      => x_variable_datatype
                        );

            IF x_valid_variable <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'OBJECT_CODE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            p_rule_condition_rec.object_code_datatype := x_variable_datatype;
            p_rule_condition_rec.object_value_set_name := x_value_set_name;

            IF p_rule_condition_rec.object_code_datatype = 'V'
            THEN
               l_operator_lookup := 'OKC_XPRT_CHAR_OPERATOR';
            ELSIF p_rule_condition_rec.object_code_datatype = 'N'
            THEN
               l_operator_lookup := 'OKC_XPRT_NUMBER_OPERATOR';
            END IF;

            OPEN c_validate_lookup (l_operator_lookup,
                                    p_rule_condition_rec.OPERATOR
                                   );

            FETCH c_validate_lookup
             INTO l_validate_flag;

            IF c_validate_lookup%NOTFOUND
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'OPERATOR'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            CLOSE c_validate_lookup;

            IF p_rule_condition_rec.object_value_type NOT IN
                                ('VALUE', 'QUESTION', 'VARIABLE', 'CONSTANT')
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'OBJECT_VALUE_TYPE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;



            validate_rule_condn_val_tbl
               (p_object_value_type       => p_rule_condition_rec.object_value_type,
                p_rule_intent             => l_rule_intent,
                p_value_set_name          => p_rule_condition_rec.object_value_set_name,
                p_rule_cond_vals_tbl      => p_rule_condition_rec.rule_cond_vals_tbl
               );
         END IF;

         IF
            -- p_rule_condition_rec.rule_cond_vals_tbl.Count=1
            p_rule_condition_rec.OPERATOR NOT IN ('IN', 'NOT_IN')
         THEN
            --i := p_rule_condition_rec.rule_cond_vals_tbl.first;
            p_rule_condition_rec.object_value_code :=
                p_rule_condition_rec.rule_cond_vals_tbl (1).object_value_code;
         ELSE
            p_rule_condition_rec.object_value_code := NULL;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END validate_rule_condition;
   BEGIN
      -- Default --> Set the unpassed values to null
      default_rule_condition (p_rule_condition_rec => p_rule_condition_rec);
      -- Validate  n Derive
      validate_rule_condition (p_rule_condition_rec => p_rule_condition_rec);

      /*SELECT okc_xprt_rule_condition_s.NEXTVAL
        INTO p_rule_condition_rec.rule_condition_id
        FROM DUAL;     */

      -- Insert
      INSERT INTO okc_xprt_rule_conditions
                  (rule_condition_id,
                   rule_id,
                   object_type,
                   object_code,
                   object_code_datatype,
                   OPERATOR,
                   object_value_set_name,
                   object_value_type,
                   object_value_code, object_version_number,
                   created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login
                  )
           VALUES (okc_xprt_rule_condition_s.NEXTVAL,
                   p_rule_condition_rec.rule_id,
                   -- Need to see to pass or derive
                   p_rule_condition_rec.object_type,
                   p_rule_condition_rec.object_code,
                   p_rule_condition_rec.object_code_datatype,
                   p_rule_condition_rec.OPERATOR,
                   p_rule_condition_rec.object_value_set_name,
                   p_rule_condition_rec.object_value_type,
                   p_rule_condition_rec.object_value_code, 1,
                   fnd_global.user_id, SYSDATE, fnd_global.user_id,
                   SYSDATE, fnd_global.login_id
                  )
        RETURNING rule_condition_id
             INTO p_rule_condition_rec.rule_condition_id;

      -- Values
      create_rule_condn_value
              (p_rule_condition_id       => p_rule_condition_rec.rule_condition_id,
               p_rule_cond_vals_tbl      => p_rule_condition_rec.rule_cond_vals_tbl
              );
   -- Insert
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END create_rule_condition;

   PROCEDURE create_rule_condition (
      p_rule_condition_tbl   IN OUT NOCOPY   rule_condition_tbl_type
   )
   IS
      l_proc             VARCHAR2 (60) := 'CREATE_RULE_CONDITION';
      l_failed_rec_num   NUMBER        := 0;
   BEGIN
      FOR i IN p_rule_condition_tbl.FIRST .. p_rule_condition_tbl.LAST
      LOOP
         l_failed_rec_num := i;

         IF     p_rule_condition_tbl (i).rule_id <> okc_api.g_miss_num
            AND g_rule_id <> NVL (p_rule_condition_tbl (i).rule_id, g_rule_id)
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_RULE_NO_MATCH',
                                 p_token1            => 'ENTITY',
                                 p_token1_value      => 'CONDITION'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         p_rule_condition_tbl (i).rule_id := g_rule_id;
         create_rule_condition
                              (p_rule_condition_rec      => p_rule_condition_tbl
                                                                           (i)
                              );
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         set_rec_num_message (p_rec_num => l_failed_rec_num);
         RAISE;
   END create_rule_condition;

/*This procedure assumes the Condition values has been validated */
   PROCEDURE create_rule_condn_value (
      p_rule_condition_id    IN              NUMBER,
      p_rule_cond_vals_tbl   IN OUT NOCOPY   rule_cond_vals_tbl_type
   )
   IS
      l_proc             VARCHAR2 (60) := 'CREATE_RULE_CONDN_VALUE';
      l_failed_rec_num   NUMBER        := 0;
   BEGIN
      FOR i IN p_rule_cond_vals_tbl.FIRST .. p_rule_cond_vals_tbl.LAST
      LOOP
         l_failed_rec_num := i;

         INSERT INTO okc_xprt_rule_cond_vals
                     (rule_condition_value_id,
                      rule_condition_id,
                      object_value_code, object_version_number,
                      created_by, creation_date, last_updated_by,
                      last_update_date, last_update_login
                     )
              VALUES (okc_xprt_rule_cond_vals_s.NEXTVAL
                                                       --p_rule_cond_vals_tbl(i).rule_condition_value_id
         ,
                      p_rule_condition_id
                                         --p_rule_cond_vals_tbl(i).rule_condition_id
         ,
                      p_rule_cond_vals_tbl (i).object_value_code, 1,
                      fnd_global.user_id, SYSDATE, fnd_global.user_id,
                      SYSDATE, fnd_global.login_id
                     )
           RETURNING rule_condition_value_id,
                     rule_condition_id
                INTO p_rule_cond_vals_tbl (i).rule_condition_value_id,
                     p_rule_cond_vals_tbl (i).rule_condition_id;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         set_rec_num_message (p_rec_num => l_failed_rec_num);
         RAISE;
   END create_rule_condn_value;

   PROCEDURE create_rule_outcome (
      p_rule_outcome_rec   IN OUT NOCOPY   rule_outcome_rec_type
   )
   IS
      PROCEDURE validate_rule_outcome (
         p_rule_outcome_rec   IN OUT NOCOPY   rule_outcome_rec_type
      )
      IS
         l_proc   VARCHAR2 (60) := 'VALIDATE_RULE_OUTCOME';
      BEGIN
         IF p_rule_outcome_rec.rule_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_rule_outcome_rec.object_type IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         ELSE
            IF p_rule_outcome_rec.object_type NOT IN ('QUESTION', 'CLAUSE')
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'OBJECT_TYPE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF p_rule_outcome_rec.object_value_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OBJECT_VALUE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF is_valid_rule (p_rule_id => p_rule_outcome_rec.rule_id) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF g_rule_type <> g_clause_rule_type
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF is_valid_outcome
                      (p_rule_id              => p_rule_outcome_rec.rule_id,
                       p_object_type          => p_rule_outcome_rec.object_type,
                       p_object_value_id      => p_rule_outcome_rec.object_value_id
                      ) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OUTCOME'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF is_duplicate_outcome
                      (p_rule_id              => p_rule_outcome_rec.rule_id,
                       p_object_type          => p_rule_outcome_rec.object_type,
                       p_object_value_id      => p_rule_outcome_rec.object_value_id
                      ) = 'Y'
         THEN
            -- Duplicate Outcome
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OUTCOME'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
         /* RWA Changes Start */
         IF     p_rule_outcome_rec.mandatory_yn IS NOT NULL
            AND p_rule_outcome_rec.mandatory_yn NOT IN ('Y','N') THEN

            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'MANDATORY_YN'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     p_rule_outcome_rec.mandatory_rwa IS NOT NULL
            AND isValidLookup('OKC_CLAUSE_RWA', p_rule_outcome_rec.mandatory_rwa) = 'N' THEN

            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'MANDATORY_RWA'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         /* RWA Changes End */

      END validate_rule_outcome;
   BEGIN

      /* RWA Changes Start */
      -- Default
      IF p_rule_outcome_rec.mandatory_yn = OKC_API.G_MISS_CHAR
       THEN
         p_rule_outcome_rec.mandatory_yn := NULL;
      END IF;

      IF p_rule_outcome_rec.mandatory_rwa = OKC_API.G_MISS_CHAR
       THEN
         p_rule_outcome_rec.mandatory_rwa := NULL;
      END IF;
      /* RWA Changes End */

      validate_rule_outcome (p_rule_outcome_rec => p_rule_outcome_rec);

      -- Insert into  okc_xprt_rule_outcomes table
      INSERT INTO okc_xprt_rule_outcomes
                  (rule_outcome_id,
                   rule_id,
                   object_type,
                   object_value_id, object_version_number,
                   created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login,mandatory_yn, mandatory_rwa
                  )
           VALUES (okc_xprt_rule_outcomes_s.NEXTVAL,
                   p_rule_outcome_rec.rule_id,
                   p_rule_outcome_rec.object_type,
                   p_rule_outcome_rec.object_value_id, 1,
                   fnd_global.user_id, SYSDATE, fnd_global.user_id,
                   SYSDATE, fnd_global.login_id,p_rule_outcome_rec.mandatory_yn, p_rule_outcome_rec.mandatory_rwa
                  )
        RETURNING rule_outcome_id
             INTO p_rule_outcome_rec.rule_outcome_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END create_rule_outcome;

   PROCEDURE create_rule_outcome (
      p_rule_outcome_tbl   IN OUT NOCOPY   rule_outcome_tbl_type
   )
   IS
      l_proc             VARCHAR2 (60) := 'CREATE_RULE_OUTCOME';
      l_failed_rec_num   NUMBER        := 0;
   BEGIN
      IF p_rule_outcome_tbl.COUNT > 0
      THEN
         FOR i IN p_rule_outcome_tbl.FIRST .. p_rule_outcome_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            IF     p_rule_outcome_tbl (i).rule_id <> okc_api.g_miss_num
               AND g_rule_id <>
                               NVL (p_rule_outcome_tbl (i).rule_id, g_rule_id)
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_RULE_NO_MATCH',
                                    p_token1            => 'ENTITY',
                                    p_token1_value      => 'OUTCOME'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            p_rule_outcome_tbl (i).rule_id := g_rule_id;
            create_rule_outcome (p_rule_outcome_rec      => p_rule_outcome_tbl
                                                                           (i));
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         set_rec_num_message (p_rec_num => l_failed_rec_num);
         RAISE;
   END create_rule_outcome;

   PROCEDURE create_template_rules (
      p_template_rules_tbl   IN OUT NOCOPY   template_rules_tbl_type
   )
   IS
      l_proc             VARCHAR2 (60) := 'CREATE_TEMPLATE_RULES';
      l_failed_rec_num   NUMBER        := 0;
   BEGIN
      IF p_template_rules_tbl.COUNT > 0
      THEN
         FOR i IN p_template_rules_tbl.FIRST .. p_template_rules_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            IF     p_template_rules_tbl (i).rule_id <> okc_api.g_miss_num
               AND g_rule_id <>
                             NVL (p_template_rules_tbl (i).rule_id, g_rule_id)
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_RULE_NO_MATCH',
                                    p_token1            => 'ENTITY',
                                    p_token1_value      => 'TEMPLATE_RULE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            create_template_rules
                              (p_template_rules_rec      => p_template_rules_tbl
                                                                           (i)
                              );
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_rec_num_message (p_rec_num => l_failed_rec_num);
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END create_template_rules;

   PROCEDURE create_template_rules (
      p_template_rules_rec   IN OUT NOCOPY   template_rules_rec_type
   )
   IS
      CURSOR cur_val_template
      IS
         SELECT 'Y'
           FROM okc_terms_templates_all temp, fnd_lookups status
          WHERE intent = g_rule_intent
            AND status.lookup_code = temp.status_code
            AND status.lookup_type = 'OKC_TERMS_TMPL_STATUS'
            AND contract_expert_enabled = 'Y'
            AND NVL (end_date, SYSDATE) >= SYSDATE
            AND org_id = g_org_id;

      CURSOR cur_dup_template
      IS
         SELECT 'Y'
           FROM okc_xprt_template_rules
          WHERE template_id = p_template_rules_rec.template_id
            AND rule_id = g_rule_id
            AND deleted_flag = NVL (p_template_rules_rec.deleted_flag, 'N');

      l_val_flag   VARCHAR2 (1);
      l_dup_flag   VARCHAR2 (1);
   BEGIN
      -- Default
      /*SELECT okc_xprt_template_rules_s.NEXTVAL
        INTO p_template_rules_rec.template_rule_id
        FROM DUAL;*/
      p_template_rules_rec.rule_id := g_rule_id;
      p_template_rules_rec.deleted_flag := 'N';
      p_template_rules_rec.published_flag := NULL;
      p_template_rules_rec.object_version_number := 1;
      p_template_rules_rec.created_by := fnd_global.user_id;
      p_template_rules_rec.creation_date := SYSDATE;
      p_template_rules_rec.last_updated_by := fnd_global.user_id;
      p_template_rules_rec.last_update_date := SYSDATE;
      p_template_rules_rec.last_update_login := fnd_global.login_id;

      -- Validate
      IF p_template_rules_rec.template_id IS NULL
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_not_null,
                              p_token1            => l_field,
                              p_token1_value      => 'TEMPLATE_ID'
                             );
         RAISE fnd_api.g_exc_error;
      ELSE
         OPEN cur_val_template;

         FETCH cur_val_template
          INTO l_val_flag;

         CLOSE cur_val_template;

         IF NVL (l_val_flag, 'X') <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'OUTCOME'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         l_val_flag := NULL;
      END IF;

      OPEN cur_dup_template;

      FETCH cur_dup_template
       INTO l_dup_flag;

      CLOSE cur_dup_template;

      IF NVL (l_dup_flag, 'N') = 'Y'
      THEN
         okc_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKC_XPRT_DUPLICATE_TMPL_ASSIGN'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Insert
      INSERT INTO okc_xprt_template_rules
                  (template_rule_id,
                   template_id,
                   rule_id,
                   deleted_flag,
                   published_flag,
                   object_version_number,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login
                  )
           VALUES (okc_xprt_template_rules_s.NEXTVAL,
                   p_template_rules_rec.template_id,
                   p_template_rules_rec.rule_id,
                   p_template_rules_rec.deleted_flag,
                   p_template_rules_rec.published_flag,
                   p_template_rules_rec.object_version_number,
                   p_template_rules_rec.created_by,
                   p_template_rules_rec.creation_date,
                   p_template_rules_rec.last_updated_by,
                   p_template_rules_rec.last_update_date,
                   p_template_rules_rec.last_update_login
                  )
        RETURNING template_rule_id
             INTO p_template_rules_rec.template_rule_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END create_template_rules;

/*

The system allows updates to the conditions, results, and template assignments.
However, you cannot update the following fields:
      Operating Unit
      Rule Type => You cannot change the intent on a rule that has conditions, results or template assignments defined
      Name     =>
      Intent  => You cannot change the intent on a rule that has conditions, results or template assignments defined.
      Apply to All Templates

      When Status is Draft you can not update the following:
       OU
       Rule Type
       Intent

      -- Manual status changes are not allowed
*/
   PROCEDURE update_rule_header (
      p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type
   )
   IS
      l_progress          VARCHAR2 (3)                     := '000';
      l_rule_header_row   okc_xprt_rule_hdrs_all%ROWTYPE;
      l_proc              VARCHAR2 (60)               := 'UPDATE_RULE_HEADER';

      PROCEDURE default_row (
         p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type,
         p_db_rule_header    IN              okc_xprt_rule_hdrs_all%ROWTYPE
      )
      IS
      BEGIN
         p_rule_header_rec.last_updated_by := fnd_global.user_id;
         p_rule_header_rec.last_update_date := SYSDATE;
         p_rule_header_rec.last_update_login := fnd_global.login_id;

         IF p_rule_header_rec.org_id = okc_api.g_miss_num
         THEN
            p_rule_header_rec.org_id := p_db_rule_header.org_id;
         END IF;

         IF p_rule_header_rec.intent = okc_api.g_miss_char
         THEN
            p_rule_header_rec.intent := p_db_rule_header.intent;
         END IF;

         IF p_rule_header_rec.status_code = okc_api.g_miss_char
         THEN
            p_rule_header_rec.status_code := p_db_rule_header.status_code;
         END IF;

         IF p_rule_header_rec.rule_name = okc_api.g_miss_char
         THEN
            p_rule_header_rec.rule_name := p_db_rule_header.rule_name;
         END IF;

         IF p_rule_header_rec.rule_description = okc_api.g_miss_char
         THEN
            p_rule_header_rec.rule_description :=
                                            p_db_rule_header.rule_description;
         END IF;

         IF p_rule_header_rec.org_wide_flag = okc_api.g_miss_char
         THEN
            p_rule_header_rec.org_wide_flag := p_db_rule_header.org_wide_flag;
         END IF;

         IF p_rule_header_rec.condition_expr_code = okc_api.g_miss_char
         THEN
            p_rule_header_rec.condition_expr_code :=
                                         p_db_rule_header.condition_expr_code;
         END IF;

         IF p_rule_header_rec.rule_type = okc_api.g_miss_char
         THEN
            p_rule_header_rec.rule_type := p_db_rule_header.rule_type;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END default_row;

      PROCEDURE validate_row (
         p_rule_header_rec   IN   rule_header_rec_type,
         p_db_rule_header    IN   okc_xprt_rule_hdrs_all%ROWTYPE
      )
      IS
         l_proc            VARCHAR2 (60) := 'VALIDATE_ROW';

         CURSOR cur_rule_name_exists (p_rule_name VARCHAR2, p_org_id NUMBER)
         IS
            SELECT 'Y'
              FROM okc_xprt_rule_hdrs_all
             WHERE rule_name = p_rule_name AND org_id = p_org_id;

         l_validate_flag   VARCHAR2 (1);
      BEGIN
         IF p_rule_header_rec.rule_name IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_NAME'
                                );
            RAISE fnd_api.g_exc_error;
         ELSE
            IF p_rule_header_rec.rule_name <> p_db_rule_header.rule_name
            THEN
               OPEN cur_rule_name_exists (p_rule_header_rec.rule_name,
                                          p_rule_header_rec.org_id
                                         );

               FETCH cur_rule_name_exists
                INTO l_validate_flag;

               CLOSE cur_rule_name_exists;

               IF NVL (l_validate_flag, 'X') = 'Y'
               THEN
                  okc_api.set_message
                                   (p_app_name      => g_app_name,
                                    p_msg_name      => 'OKC_XPRT_RULE_NAME_EXISTS'
                                   );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
         END IF;

           IF p_rule_header_rec.org_wide_flag NOT IN ('Y' , 'N') THEN
             okc_api.set_message (p_app_name          => g_app_name,
                                  p_msg_name          => l_okc_i_invalid_value,
                                  p_token1            => l_field,
                                  p_token1_value      => 'ORG_WIDE_FLAG'
                                 );
             RAISE fnd_api.g_exc_error;
         END IF;

         IF p_rule_header_rec.condition_expr_code NOT IN ('ALL', 'ANY')
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'CONDITION_EXPR_CODE'
                                   );
               RAISE fnd_api.g_exc_error;
          END IF;

      EXCEPTION
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END validate_row;

      PROCEDURE derive_row (
         p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type
      )
      IS
      BEGIN
         IF p_rule_header_rec.status_code = 'ACTIVE'
         THEN
            p_rule_header_rec.status_code := 'REVISION';
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END derive_row;

      PROCEDURE update_row (
         p_rule_header_rec   IN OUT NOCOPY   rule_header_rec_type
      )
      IS
         l_proc   VARCHAR2 (60) := 'UPDATE_ROW';
      BEGIN
         UPDATE okc_xprt_rule_hdrs_all
            SET status_code = p_rule_header_rec.status_code,
                rule_name = p_rule_header_rec.rule_name,
                rule_description = p_rule_header_rec.rule_description,
                org_wide_flag = p_rule_header_rec.org_wide_flag,
                condition_expr_code = p_rule_header_rec.condition_expr_code,
                object_version_number = object_version_number + 1,
                last_updated_by = fnd_global.user_id,
                last_update_date = SYSDATE,
                last_update_login = fnd_global.login_id
          WHERE rule_id = p_rule_header_rec.rule_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END update_row;
   BEGIN
      -- Detect what values are changed and throw exception if the update is not allowed

      -- Get the values from the db
      -- Compare it with the record
      l_progress := '010';

      BEGIN
         l_progress := '015';

         SELECT *
           INTO l_rule_header_row
           FROM okc_xprt_rule_hdrs_all
          WHERE rule_id = p_rule_header_rec.rule_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_ID'
                                );
            RAISE fnd_api.g_exc_error;
      END;

      -- If status is Active(Pending), Disable (Pending), Disabled then do not allow update to the
      -- Rule.
      l_progress := '020';

      IF l_rule_header_row.status_code IN
                                 ('PENDINGPUB', 'PENDINGDISABLE', 'INACTIVE')
      THEN
         l_progress := '025';
         -- Can't update anything just return the error.
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_RULE_STS_NO_UPD',
                              p_token1            => 'STATUS',
                              p_token1_value      => l_rule_header_row.status_code
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '030';

      -- Irrespective of status(draft,revision,active the following fields can't be updated by the user)
      IF (    p_rule_header_rec.org_id <> okc_api.g_miss_num
          AND NVL (p_rule_header_rec.org_id, -100) <> l_rule_header_row.org_id
         )
      THEN
         l_progress := '035';
         -- You can not change Org_Id.
         okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_RULE_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_rule_header_row.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'ORG_ID'
                            );
         RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '040';

      IF (    p_rule_header_rec.intent <> okc_api.g_miss_char
          AND NVL (p_rule_header_rec.intent, 'ABC') <>
                                                      l_rule_header_row.intent
         )
      THEN
         l_progress := '045';
         --  You can not change Intent.
         okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_RULE_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_rule_header_row.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'INTENT'
                            );
         RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '050';

      IF (    p_rule_header_rec.rule_type <> okc_api.g_miss_char
          AND NVL (p_rule_header_rec.rule_type, 'ABC') <>
                                                   l_rule_header_row.rule_type
         )
      THEN
         l_progress := '055';
         --  You can not change Rule Type
         okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_RULE_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_rule_header_row.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'RULE_TYPE'
                            );
         RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '060';

      IF (    p_rule_header_rec.status_code <> okc_api.g_miss_char
          AND NVL (p_rule_header_rec.status_code, 'ABC') <>
                                                 l_rule_header_row.status_code
         )
      THEN
         l_progress := '065';
         --  You can not change Status
         okc_api.set_message (p_app_name      => g_app_name,
                              p_msg_name      => 'OKC_I_RULE_STS_CHANGE'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      l_progress := '070';

      IF l_rule_header_row.status_code IN ('ACTIVE', 'REVISION')
      THEN
         /*
          The system allows updates to the conditions, results, and template assignments.
          However, you cannot update the following fields:
           Operating Unit =>  Covered in above code
           Rule Type      =>  Covered in above code
                              You cannot change the intent on a rule that has conditions, results or template assignments defined
           Name           =>
           Intent         =>  Covered in above code
                              You cannot change the intent on a rule that has conditions, results or template assignments defined.
           Apply to All Templates =>
         */
         l_progress := '075';

         IF (    p_rule_header_rec.rule_name <> okc_api.g_miss_char
             AND p_rule_header_rec.rule_name <> l_rule_header_row.rule_name
            )
         THEN
            l_progress := '080';
            --  You can not change rule_name
            okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_RULE_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_rule_header_row.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'RULE_NAME'
                            );
            RAISE fnd_api.g_exc_error;
         END IF;

         l_progress := '085';

         IF (    p_rule_header_rec.org_wide_flag <> okc_api.g_miss_char
             AND NVL (p_rule_header_rec.org_wide_flag, 'X') <>
                                               l_rule_header_row.org_wide_flag
            )
         THEN
            l_progress := '090';
            --  You can not change org_wide_flag
            okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_RULE_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_rule_header_row.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'ORG_WIDE_FLAG'
                            );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      l_progress := '100';
      -- set the policy context
      mo_global.set_policy_context ('S', TO_CHAR (l_rule_header_row.org_id));
      l_progress := '110';
      -- Default values for coulmns from table for which the values are not provided by user
      default_row (p_rule_header_rec      => p_rule_header_rec,
                   p_db_rule_header       => l_rule_header_row
                  );
      l_progress := '120';
      -- Validate the values provided by the user
      validate_row (p_rule_header_rec      => p_rule_header_rec,
                    p_db_rule_header       => l_rule_header_row
                   );
      -- Derive values ex; status change from active to  revision
      l_progress := '130';
      derive_row (p_rule_header_rec => p_rule_header_rec);

      IF     NVL (l_rule_header_row.org_wide_flag, 'N') <>
                                               p_rule_header_rec.org_wide_flag
         AND p_rule_header_rec.org_wide_flag = 'Y'
         AND l_rule_header_row.status_code = 'DRAFT'
      THEN
         -- Delete the Template Assignments if any.
         -- Same as changing the org wide flag from UI when the staus is 'DRAFT'.
         l_progress := '140';

         DELETE FROM okc_xprt_template_rules
               WHERE rule_id = p_rule_header_rec.rule_id;
      END IF;

      l_progress := '150';
      -- Update the Rule header
      update_row (p_rule_header_rec => p_rule_header_rec);
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END update_rule_header;

   PROCEDURE update_rule_header (
      p_rule_header_tbl   IN OUT NOCOPY   rule_header_tbl_type
   )
   IS
      l_proc             VARCHAR2 (60) := 'UPDATE_RULE_HEADER';
      l_failed_rec_num   NUMBER        := 0;
   BEGIN
      IF p_rule_header_tbl.COUNT > 0
      THEN
         FOR i IN p_rule_header_tbl.FIRST .. p_rule_header_tbl.LAST
         LOOP
            l_failed_rec_num := i;
            update_rule_header (p_rule_header_rec => p_rule_header_tbl (i));
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         set_rec_num_message (p_rec_num => l_failed_rec_num);
         RAISE;
   END update_rule_header;

   PROCEDURE create_rule (p_rule_rec IN OUT NOCOPY rule_rec_type)
   IS
      l_rule_type       okc_xprt_rule_hdrs_all.rule_type%TYPE;
      l_error_message   VARCHAR2 (2500);
      l_proc            VARCHAR2 (60)                        := 'CREATE_RULE';
   BEGIN
      -- PRE VALIDATION START
         -- Rule Header Must Exist
         -- Atleast one condition must exist
         -- Atleast one outcome is required for 'CLAUSE_SELECTION' type rules.
         -- If not throw invalid input error.
         --
      fnd_msg_pub.initialize;
      l_rule_type := p_rule_rec.rule_header_rec.rule_type;

      IF l_rule_type = g_clause_rule_type
      THEN
         IF NOT (    (p_rule_rec.rule_condition_tbl.COUNT > 0)
                 AND (p_rule_rec.rule_outcome_tbl.COUNT > 0)
                )
         THEN
            p_rule_rec.status := g_ret_sts_error;
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_XPRT_RULE_INCOMPLETE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF l_rule_type = g_term_dev_rule_type
      THEN
         IF NOT ((p_rule_rec.rule_condition_tbl.COUNT > 0))
         THEN
            p_rule_rec.status := g_ret_sts_error;
            okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_XPRT_POLICYRULE_INCOMPLETE'
                              );
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSE
         p_rule_rec.status := g_ret_sts_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_invalid_value,
                              p_token1            => l_field,
                              p_token1_value      => 'RULE_TYPE'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- PRE VALIDATION END
      BEGIN
         fnd_msg_pub.initialize;
         l_error_message := '';
         g_rule_id := NULL;
         g_rule_intent := NULL;
         g_rule_type := NULL;
         g_rule_status_code := NULL;
         g_org_wide_flag := NULL;
         g_org_id := NULL;
         create_rule_header (p_rule_header_rec      => p_rule_rec.rule_header_rec);
         g_rule_id := p_rule_rec.rule_header_rec.rule_id;
         g_rule_intent := p_rule_rec.rule_header_rec.intent;
         g_rule_type := p_rule_rec.rule_header_rec.rule_type;
         g_rule_status_code := p_rule_rec.rule_header_rec.status_code;
         g_org_wide_flag := p_rule_rec.rule_header_rec.org_wide_flag;
         g_org_id := p_rule_rec.rule_header_rec.org_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_rule_rec.status := g_ret_sts_error;
            RAISE;
      END;

      BEGIN
         fnd_msg_pub.initialize;
         l_error_message := '';
         create_rule_condition
                       (p_rule_condition_tbl      => p_rule_rec.rule_condition_tbl);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_rule_rec.status := g_ret_sts_error;
            RAISE;
      END;

      IF l_rule_type = g_clause_rule_type
      THEN
         BEGIN
            fnd_msg_pub.initialize;
            l_error_message := '';
            create_rule_outcome
                           (p_rule_outcome_tbl      => p_rule_rec.rule_outcome_tbl);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_rule_rec.status := g_ret_sts_error;
               RAISE;
         END;

         fnd_msg_pub.initialize;

         IF validaterulecondition (g_rule_id) = 'N'
         THEN
            p_rule_rec.status := g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF     NVL (p_rule_rec.rule_header_rec.org_wide_flag, 'X') <> 'Y'
         AND p_rule_rec.template_rules_tbl.COUNT > 0
      THEN
         BEGIN
            fnd_msg_pub.initialize;
            l_error_message := '';
            create_template_rules
                       (p_template_rules_tbl      => p_rule_rec.template_rules_tbl);
         EXCEPTION
            WHEN OTHERS
            THEN
               p_rule_rec.status := g_ret_sts_error;
               RAISE;
         END;
      END IF;

      -- POST VALIDATION
      -- Need to check whether Rule Header, condition and out come exists
      p_rule_rec.status := g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END create_rule;

   PROCEDURE update_rule (p_rule_rec IN OUT NOCOPY rule_rec_type)
   IS
      l_rule_type       okc_xprt_rule_hdrs_all.rule_type%TYPE;
      l_error_message   VARCHAR2 (2500);
   BEGIN
      BEGIN
         fnd_msg_pub.initialize;
         l_error_message := '';
         g_rule_id := NULL;
         g_rule_intent := NULL;
         g_rule_type := NULL;
         g_rule_status_code := NULL;
         g_org_wide_flag := NULL;
         g_org_id := NULL;
         update_rule_header (p_rule_header_rec      => p_rule_rec.rule_header_rec);
         g_rule_id := p_rule_rec.rule_header_rec.rule_id;
         g_rule_intent := p_rule_rec.rule_header_rec.intent;
         g_rule_type := p_rule_rec.rule_header_rec.rule_type;
         g_rule_status_code := p_rule_rec.rule_header_rec.status_code;
         g_org_wide_flag := p_rule_rec.rule_header_rec.org_wide_flag;
         g_org_id := p_rule_rec.rule_header_rec.org_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_rule_rec.status := g_ret_sts_error;
            RAISE;
      END;

      IF p_rule_rec.rule_condition_tbl.COUNT > 0
      THEN
         fnd_msg_pub.initialize;
         l_error_message := '';
         create_rule_condition
                       (p_rule_condition_tbl      => p_rule_rec.rule_condition_tbl);
      END IF;

      IF     l_rule_type = g_clause_rule_type
         AND p_rule_rec.rule_outcome_tbl.COUNT > 0
      THEN
         fnd_msg_pub.initialize;
         l_error_message := '';
         create_rule_outcome
                           (p_rule_outcome_tbl      => p_rule_rec.rule_outcome_tbl);
      END IF;

      IF     p_rule_rec.rule_header_rec.org_wide_flag <> 'Y'
         AND p_rule_rec.template_rules_tbl.COUNT > 0
      THEN
         fnd_msg_pub.initialize;
         l_error_message := '';
         create_template_rules
                       (p_template_rules_tbl      => p_rule_rec.template_rules_tbl);
      END IF;

      -- POST VALIDATION
      fnd_msg_pub.initialize;

      IF validaterulecondition (g_rule_id) = 'N'
      THEN
         p_rule_rec.status := g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Need to check whether Rule Header, condition and out come exists
      p_rule_rec.status := g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END update_rule;

   PROCEDURE delete_rule_child_entities (
      p_rule_child_entities_rec   IN OUT NOCOPY   rule_child_entities_rec_type
   )
   IS
      l_rule_type          VARCHAR2 (60);
      l_rule_status        VARCHAR2 (60);
      l_conditions_count   NUMBER;
      l_outcomes_count     NUMBER;
      l_flag               VARCHAR2 (1);
      l_failed_rec_num     NUMBER        := 0;
   BEGIN
      fnd_msg_pub.initialize;

      -- Get rule status, rule type
      BEGIN
         SELECT status_code, rule_type
           INTO g_rule_status_code, g_rule_type
           FROM okc_xprt_rule_hdrs_all
          WHERE rule_id = p_rule_child_entities_rec.rule_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_rule_child_entities_rec.status := g_ret_sts_error;
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'RULE_ID'
                                );
            RAISE;
      END;

      fnd_msg_pub.initialize;

      --  Check whether the rules is available for update
      IF g_rule_status_code NOT IN ('DRAFT', 'REVISION', 'ACTIVE')
      THEN
         -- Can't update anything just return the error
         p_rule_child_entities_rec.status := g_ret_sts_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_RULE_STS_NO_UPD',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_rule_status_code
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      --  Check validity of input conditions
      IF p_rule_child_entities_rec.rule_condition_id_tbl.COUNT > 0
      THEN
         FOR i IN
            p_rule_child_entities_rec.rule_condition_id_tbl.FIRST .. p_rule_child_entities_rec.rule_condition_id_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            BEGIN
               SELECT 'Y'
                 INTO l_flag
                 FROM okc_xprt_rule_conditions
                WHERE rule_id = p_rule_child_entities_rec.rule_id
                  AND rule_condition_id =
                           p_rule_child_entities_rec.rule_condition_id_tbl (i)
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_rule_child_entities_rec.status := g_ret_sts_error;
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => l_okc_i_invalid_value,
                                       p_token1            => l_field,
                                       p_token1_value      => 'RULE_CONDITION_ID'
                                      );
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  RAISE;
            END;
         END LOOP;

         /*As of now Commenting out the validation */

         --   Delete
         FORALL i IN INDICES OF p_rule_child_entities_rec.rule_condition_id_tbl
            DELETE FROM okc_xprt_rule_cond_vals
                  WHERE rule_condition_id =
                           p_rule_child_entities_rec.rule_condition_id_tbl (i);

         FORALL i IN INDICES OF p_rule_child_entities_rec.rule_condition_id_tbl
            DELETE FROM okc_xprt_rule_conditions
                  WHERE rule_condition_id =
                           p_rule_child_entities_rec.rule_condition_id_tbl (i);

         --  A valid rule requires atleasrt one condition.
         --  Atleast one condition must exist other wise return error
         SELECT COUNT (1)
           INTO l_conditions_count
           FROM okc_xprt_rule_conditions
          WHERE rule_id = p_rule_child_entities_rec.rule_id;

         IF l_conditions_count = 0
         THEN
            p_rule_child_entities_rec.status := g_ret_sts_error;
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_XPRT_RULE_INCOMPLETE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --  Check validity of input Outcomes and delete
      IF     g_rule_type = g_clause_rule_type
         AND p_rule_child_entities_rec.rule_outcome_id_tbl.COUNT > 1
      THEN
         FOR i IN
            p_rule_child_entities_rec.rule_outcome_id_tbl.FIRST .. p_rule_child_entities_rec.rule_outcome_id_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            BEGIN
               SELECT 'Y'
                 INTO l_flag
                 FROM okc_xprt_rule_outcomes
                WHERE rule_id = p_rule_child_entities_rec.rule_id
                  AND rule_outcome_id =
                             p_rule_child_entities_rec.rule_outcome_id_tbl (i)
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_rule_child_entities_rec.status := g_ret_sts_error;
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => l_okc_i_invalid_value,
                                       p_token1            => l_field,
                                       p_token1_value      => 'RULE_OUTCOME_ID'
                                      );
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  RAISE;
            END;
         END LOOP;

         --   Delete
         FORALL i IN INDICES OF p_rule_child_entities_rec.rule_outcome_id_tbl
            DELETE FROM okc_xprt_rule_outcomes
                  WHERE rule_outcome_id =
                             p_rule_child_entities_rec.rule_outcome_id_tbl (i);

         --  Atleast one outcome must exist for clause_selection rules
         SELECT COUNT (1)
           INTO l_outcomes_count
           FROM okc_xprt_rule_outcomes
          WHERE rule_id = p_rule_child_entities_rec.rule_id;

         IF l_outcomes_count = 0
         THEN
            p_rule_child_entities_rec.status := g_ret_sts_error;
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_XPRT_RULE_INCOMPLETE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      --  Check validity of template rules
      IF p_rule_child_entities_rec.template_rule_id_tbl.COUNT > 0
      THEN
         FOR i IN
            p_rule_child_entities_rec.template_rule_id_tbl.FIRST .. p_rule_child_entities_rec.template_rule_id_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            BEGIN
               SELECT 'Y'
                 INTO l_flag
                 FROM okc_xprt_template_rules
                WHERE rule_id = p_rule_child_entities_rec.rule_id
                  AND template_rule_id =
                            p_rule_child_entities_rec.template_rule_id_tbl (i)
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_rule_child_entities_rec.status := g_ret_sts_error;
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => l_okc_i_invalid_value,
                                       p_token1            => l_field,
                                       p_token1_value      => 'TEMPLATE_RULE_ID'
                                      );
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  RAISE;
            END;
         END LOOP;

         --As of now Commenting out the validation  */

         --   Delete
         FORALL i IN INDICES OF p_rule_child_entities_rec.template_rule_id_tbl
            DELETE FROM okc_xprt_template_rules
                  WHERE 1 = 1
                    AND template_rule_id =
                            p_rule_child_entities_rec.template_rule_id_tbl (i);
      END IF;

      --  Change the rule  status to 'REVISION' from active
      IF g_rule_status_code = 'ACTIVE'
      THEN
         UPDATE okc_xprt_rule_hdrs_all
            SET status_code = 'REVISION'
          WHERE rule_id = p_rule_child_entities_rec.rule_id;
      END IF;

      p_rule_child_entities_rec.status := g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END delete_rule_child_entities;

-------------------------------
--     PUBLIC PROCEDURES     --
-------------------------------
   PROCEDURE create_rule (
      p_rule_tbl   IN OUT NOCOPY   rule_tbl_type,
      p_commit     IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_success_count    NUMBER          := 0;
      l_error_count      NUMBER          := 0;
      l_input_count      NUMBER          := p_rule_tbl.COUNT;
      l_error_message    VARCHAR2 (2500);
      l_proc             VARCHAR2 (60)   := 'CREATE_RULE';
      l_failed_rec_num   NUMBER          := 0;
   BEGIN
      IF p_rule_tbl.COUNT > 0
      THEN
         FOR i IN p_rule_tbl.FIRST .. p_rule_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            BEGIN
               SAVEPOINT create_rule_sp;
               create_rule (p_rule_rec => p_rule_tbl (i));

               IF p_rule_tbl (i).status = g_ret_sts_success
               THEN
                  l_success_count := l_success_count + 1;

                  IF fnd_api.to_boolean (p_commit)
                  THEN
                     COMMIT;
                  END IF;
               ELSE
                  l_error_count := l_error_count + 1;
                  ROLLBACK TO create_rule_sp;
               END IF;
            EXCEPTION
               WHEN fnd_api.g_exc_error
               THEN
                  p_rule_tbl (i).status := g_ret_sts_error;
                  set_proc_error_message (p_proc => l_proc);
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  read_message (l_error_message);
                  p_rule_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO create_rule_sp;
                  fnd_msg_pub.initialize;
               WHEN OTHERS
               THEN
                  p_rule_tbl (i).status := g_ret_sts_error;
                  set_proc_error_message (p_proc => l_proc);
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => g_unexpected_error,
                                       p_token1            => g_sqlcode_token,
                                       p_token1_value      => SQLCODE,
                                       p_token2            => g_sqlerrm_token,
                                       p_token2_value      => SQLERRM
                                      );
                  read_message (l_error_message);
                  p_rule_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO create_rule_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO create_rule_sp;
         RAISE;
   END create_rule;

   PROCEDURE update_rule (
      p_rule_tbl   IN OUT NOCOPY   rule_tbl_type,
      p_commit     IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_success_count    NUMBER          := 0;
      l_error_count      NUMBER          := 0;
      l_input_count      NUMBER          := p_rule_tbl.COUNT;
      l_error_message    VARCHAR2 (2500);
      l_proc             VARCHAR2 (60)   := 'UPDATE_RULE';
      l_failed_rec_num   NUMBER          := 0;
   BEGIN
      IF p_rule_tbl.COUNT > 0
      THEN
         FOR i IN p_rule_tbl.FIRST .. p_rule_tbl.LAST
         LOOP
            BEGIN
               l_failed_rec_num := i;
               SAVEPOINT update_rule_sp;
               update_rule (p_rule_rec => p_rule_tbl (i));

               IF p_rule_tbl (i).status = g_ret_sts_success
               THEN
                  l_success_count := l_success_count + 1;

                  IF fnd_api.to_boolean (p_commit)
                  THEN
                     COMMIT;
                  END IF;
               ELSE
                  l_error_count := l_error_count + 1;
                  ROLLBACK TO update_rule_sp;
               END IF;
            EXCEPTION
               WHEN fnd_api.g_exc_error
               THEN
                  p_rule_tbl (i).status := g_ret_sts_error;
                  set_proc_error_message (p_proc => l_proc);
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  read_message (l_error_message);
                  p_rule_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO update_rule_sp;
                  fnd_msg_pub.initialize;
               WHEN OTHERS
               THEN
                  p_rule_tbl (i).status := g_ret_sts_error;
                  set_proc_error_message (p_proc => l_proc);
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => g_unexpected_error,
                                       p_token1            => g_sqlcode_token,
                                       p_token1_value      => SQLCODE,
                                       p_token2            => g_sqlerrm_token,
                                       p_token2_value      => SQLERRM
                                      );
                  read_message (l_error_message);
                  p_rule_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO update_rule_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO update_rule_sp;
         RAISE;
   END update_rule;

   PROCEDURE delete_rule_child_entities (
      p_rule_child_entities_tbl   IN OUT NOCOPY   rule_child_entities_tbl_type,
      p_commit                    IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_success_count    NUMBER          := 0;
      l_error_count      NUMBER          := 0;
      l_input_count      NUMBER          := p_rule_child_entities_tbl.COUNT;
      l_error_message    VARCHAR2 (2500);
      l_proc             VARCHAR2 (60)   := 'DELETE_RULE_CHILD_ENTITIES';
      l_failed_rec_num   NUMBER          := 0;
   BEGIN
      IF p_rule_child_entities_tbl.COUNT > 0
      THEN
         FOR i IN
            p_rule_child_entities_tbl.FIRST .. p_rule_child_entities_tbl.LAST
         LOOP
            BEGIN
               SAVEPOINT del_rule_child_entity_sp;
               l_failed_rec_num := i;
               delete_rule_child_entities
                   (p_rule_child_entities_rec      => p_rule_child_entities_tbl
                                                                           (i)
                   );

               IF p_rule_child_entities_tbl (i).status = g_ret_sts_success
               THEN
                  l_success_count := l_success_count + 1;

                  IF fnd_api.to_boolean (p_commit)
                  THEN
                     COMMIT;
                  END IF;
               ELSE
                  l_error_count := l_error_count + 1;
                  ROLLBACK TO del_rule_child_entity_sp;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_rule_child_entities_tbl (i).status := g_ret_sts_error;
                  set_proc_error_message (p_proc => l_proc);
                  set_rec_num_message (p_rec_num => l_failed_rec_num);

                  read_message (l_error_message);
                  p_rule_child_entities_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO del_rule_child_entity_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO del_rule_child_entity_sp;
         RAISE;
   END delete_rule_child_entities;
END okc_xprt_rule_pvt;

/
