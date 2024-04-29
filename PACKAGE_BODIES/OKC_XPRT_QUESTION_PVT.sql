--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_QUESTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_QUESTION_PVT" AS
/*$Header: OKCVXIQB.pls 120.0.12010000.3 2012/04/12 05:46:13 serukull noship $*/

   l_debug                          VARCHAR2 (1)
                            := NVL (fnd_profile.VALUE ('AFLOG_ENABLED'), 'N');
---------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
---------------------------------------------------------------------------
   g_fnd_app               CONSTANT VARCHAR2 (200) := okc_api.g_fnd_app;
   g_invalid_value         CONSTANT VARCHAR2 (200) := okc_api.g_invalid_value;
   g_col_name_token        CONSTANT VARCHAR2 (200)
                                                  := okc_api.g_col_name_token;
---------------------------------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------------------------------
   g_pkg_name              CONSTANT VARCHAR2 (200) := 'OKC_XPRT_QUESTION_PVT';
   g_app_name              CONSTANT VARCHAR2 (3)   := okc_api.g_app_name;
------------------------------------------------------------------------------
-- GLOBAL CONSTANTS
------------------------------------------------------------------------------
   g_false                 CONSTANT VARCHAR2 (1)   := fnd_api.g_false;
   g_true                  CONSTANT VARCHAR2 (1)   := fnd_api.g_true;
   g_ret_sts_success       CONSTANT VARCHAR2 (1) := fnd_api.g_ret_sts_success;
   g_ret_sts_error         CONSTANT VARCHAR2 (1)   := fnd_api.g_ret_sts_error;
   g_ret_sts_unexp_error   CONSTANT VARCHAR2 (1)
                                             := fnd_api.g_ret_sts_unexp_error;
   g_unexpected_error      CONSTANT VARCHAR2 (200) := 'OKC_UNEXPECTED_ERROR';
   g_sqlerrm_token         CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
   g_sqlcode_token         CONSTANT VARCHAR2 (200) := 'ERROR_CODE';
   l_OKC_I_NOT_NULL         VARCHAR2 (30)  := 'OKC_I_NOT_NULL';
   --l_okc_xprt_imp_qc_not_null       VARCHAR2 (30)
     --                                           := 'OKC_XPRT_IMP_QC_NOT_NULL';
   l_okc_i_invalid_value       VARCHAR2 (30)
                                                := 'OKC_I_INVALID_VALUE';
   l_field                          VARCHAR2 (30)  := 'FIELD';
   g_exc_error                      EXCEPTION;

   PROCEDURE validate_question_name (
      p_question_name     IN              VARCHAR2,
      --p_question_intent IN              VARCHAR2,
      p_question_type     IN              VARCHAR2,
      p_lang              IN              VARCHAR2,
      p_question_id       IN              NUMBER DEFAULT NULL,
      x_return_status     OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR cur_question_exists
      IS
         SELECT 'X'
           FROM okc_xprt_questions_b b, okc_xprt_questions_tl t
          WHERE b.question_id = t.question_id
            AND b.question_type = t.question_type
            -- AND b.question_intent = p_question_intent
            AND t.question_type = p_question_type
            AND Upper(t.question_name) = Upper(p_question_name)
            AND t.question_id  <> Nvl(p_question_id,-1)
            AND t.LANGUAGE = p_lang;

      l_validate_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_question_exists;

      FETCH cur_question_exists
       INTO l_validate_flag;

      CLOSE cur_question_exists;

      IF NVL (l_validate_flag, 'Y') = 'X'
      THEN
         x_return_status := g_ret_sts_error;

         IF p_question_type = 'Q'
         THEN
            x_return_status := g_ret_sts_error;
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_XPRT_DUP_QST_NAME'
                                );
            RETURN;
         ELSE
            x_return_status := g_ret_sts_error;
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_XPRT_DUP_CON_NAME'
                                );
           RETURN;
         END IF;
      END IF;

      x_return_status := g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END validate_question_name;

   PROCEDURE isQuestionPromptExists
     (p_question_prompt     IN            VARCHAR2,
      p_question_intent   IN              VARCHAR2,
      p_lang              IN              VARCHAR2,
      p_question_id       IN              NUMBER DEFAULT NULL,
      x_return_status     OUT NOCOPY      VARCHAR2
     )
   IS
   CURSOR cur_question_exists
      IS
         SELECT 'X'
           FROM okc_xprt_questions_b b, okc_xprt_questions_tl t
          WHERE b.question_id = t.question_id
            AND b.question_type = t.question_type
            AND b.question_intent = p_question_intent
            AND t.question_type = 'Q'
            AND Upper(t.prompt) = Upper(p_question_prompt)
            AND t.question_id  <> Nvl(p_question_id,-1)
            AND t.LANGUAGE = p_lang;

      l_validate_flag   VARCHAR2 (1);
   BEGIN
        OPEN cur_question_exists;

      FETCH cur_question_exists
       INTO l_validate_flag;

      CLOSE cur_question_exists;

      IF NVL (l_validate_flag, 'Y') = 'X'
      THEN
         x_return_status := g_ret_sts_error;

          okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_XPRT_DUP_QST_PROMPT'
                                );
          RETURN;
       END IF;

      x_return_status := g_ret_sts_success;
    EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END isQuestionPromptExists;


   PROCEDURE default_row (
      p_xprt_question_rec   IN OUT NOCOPY   xprt_qn_const_rec_type,
      x_returns_status      OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN

     IF p_xprt_question_rec.QN_CONST_id  = okc_api.g_miss_num
     THEN
         p_xprt_question_rec.QN_CONST_id := NULL;
     END IF;


     IF p_xprt_question_rec.QN_CONST_type  = okc_api.g_miss_char
     THEN
         p_xprt_question_rec.QN_CONST_type := NULL;
     END IF;

     IF p_xprt_question_rec.QN_CONST_intent  = okc_api.g_miss_char
     THEN
         p_xprt_question_rec.QN_CONST_intent := NULL;
     END IF;

     IF (p_xprt_question_rec.disabled_flag = okc_api.g_miss_char)
      THEN
         p_xprt_question_rec.disabled_flag := 'N';
     END IF;


     IF p_xprt_question_rec.question_datatype  = okc_api.g_miss_char
     THEN
         p_xprt_question_rec.question_datatype := NULL;
     END IF;

     IF p_xprt_question_rec.QN_CONST_type = 'C' THEN
         p_xprt_question_rec.question_datatype := 'N';
         p_xprt_question_rec.value_set_name := NULL;
         p_xprt_question_rec.prompt := NULL;
     END IF;

      --  When question_datatype is Yes or No ('B') then default 'value set' to OKC_XPRT_YES_NO
      IF p_xprt_question_rec.question_datatype = 'B'
      THEN
         p_xprt_question_rec.value_set_name := 'OKC_XPRT_YES_NO';
      --  When question_datatype is Numeric ('N') then default 'value set' to null
      ELSIF  p_xprt_question_rec.question_datatype = 'N'
        THEN
         p_xprt_question_rec.value_set_name := NULL;
      END IF;

      IF p_xprt_question_rec.value_set_name = okc_api.g_miss_char THEN
         p_xprt_question_rec.value_set_name := NULL;
      END IF;


      IF    p_xprt_question_rec.default_value  = okc_api.g_miss_num
        OR  p_xprt_question_rec.QN_CONST_type  = 'Q'
      THEN
         p_xprt_question_rec.default_value := NULL;
      END IF;

      IF    p_xprt_question_rec.minimum_value = okc_api.g_miss_num

      THEN
         p_xprt_question_rec.minimum_value := NULL;
      END IF;

      IF p_xprt_question_rec.maximum_value = okc_api.g_miss_num

      THEN
         p_xprt_question_rec.maximum_value := NULL;
      END IF;


      IF (p_xprt_question_rec.question_sync_flag = okc_api.g_miss_char)
      THEN
         IF (p_xprt_question_rec.qn_const_type = 'Q')
         THEN
            p_xprt_question_rec.question_sync_flag := 'Y';
         ELSE
            p_xprt_question_rec.question_sync_flag := 'N';
         END IF;
      END IF;

      IF (p_xprt_question_rec.object_version_number = okc_api.g_miss_num)
      THEN
         p_xprt_question_rec.object_version_number := 1;
      END IF;

         -- Default who columns
      IF p_xprt_question_rec.created_by = okc_api.g_miss_num
      THEN
         p_xprt_question_rec.created_by := fnd_global.user_id;
      END IF;

      IF p_xprt_question_rec.creation_date = okc_api.g_miss_date
      THEN
         p_xprt_question_rec.creation_date := SYSDATE;
      END IF;

      -- Default Who Coulmns
      p_xprt_question_rec.last_update_date := SYSDATE;
      p_xprt_question_rec.last_updated_by := fnd_global.user_id;
      p_xprt_question_rec.last_update_login := fnd_global.login_id;


         IF fnd_global.conc_request_id = -1
         THEN
            p_xprt_question_rec.request_id := NULL;
         ELSE
            p_xprt_question_rec.request_id := fnd_global.conc_request_id;
         END IF;

         IF fnd_global.conc_program_id = -1
         THEN
            p_xprt_question_rec.program_id := NULL;
            p_xprt_question_rec.program_update_date := NULL;
         ELSE
            p_xprt_question_rec.program_id := fnd_global.conc_program_id;
            -- Directly initializing it to the sysdate
            p_xprt_question_rec.program_update_date := SYSDATE;
         END IF;

         IF fnd_global.prog_appl_id = -1
         THEN
            p_xprt_question_rec.program_application_id := NULL;
         ELSE
            p_xprt_question_rec.program_application_id :=
                                                      fnd_global.prog_appl_id;
         END IF;

        IF (p_xprt_question_rec.source_lang = okc_api.g_miss_char)
         THEN
          p_xprt_question_rec.source_lang := USERENV ('LANG');
        END IF;

        IF  p_xprt_question_rec.QN_CONST_name  = okc_api.g_miss_char
        THEN
            p_xprt_question_rec.QN_CONST_name := NULL;
        END IF;

        IF  p_xprt_question_rec.lang  = okc_api.g_miss_char
        THEN
            p_xprt_question_rec.lang := NULL;
        END IF;

        IF  p_xprt_question_rec.source_lang  = okc_api.g_miss_char
        THEN
            p_xprt_question_rec.source_lang := NULL;
        END IF;

        IF  p_xprt_question_rec.description  = okc_api.g_miss_char
        THEN
            p_xprt_question_rec.description := NULL;
        END IF;

        IF  p_xprt_question_rec.prompt  = okc_api.g_miss_char
        THEN
            p_xprt_question_rec.prompt := NULL;
        END IF;


      x_returns_status := g_ret_sts_success;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_returns_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END default_row;

   PROCEDURE validate_row (
      p_xprt_question_rec   IN              xprt_qn_const_rec_type,
      p_val_qn_name         IN              VARCHAR2 DEFAULT 'Y',
      x_return_status       OUT NOCOPY      VARCHAR2
   )
   IS
      x_error_count               NUMBER        := 0;
      l_validate_flag             VARCHAR2 (1);
      l_qn_type_lookup_type       VARCHAR2 (30) := 'OKC_XPRT_QUESTION_TYPE';
      l_qn_datatype_lookup_type   VARCHAR2 (30)
                                              := 'OKC_XPRT_QUESTION_DATATYPE';
      l_return_status             VARCHAR2 (1);

      --x_error_message VARCHAR2(2000);
      CURSOR cur_val_question_lookup (
         p_lookup_type   IN   VARCHAR2,
         p_lookup_code   IN   VARCHAR2
      )
      IS
         SELECT 'X'
           FROM fnd_lookup_values
          WHERE lookup_type = p_lookup_type
            --AND    langauge = UserEnv('Lang') P_lang
            AND lookup_code = p_lookup_code
            AND enabled_flag = 'Y'
            AND SYSDATE >= start_date_active
            AND (end_date_active IS NULL OR SYSDATE <= end_date_active);

      CURSOR cur_validate_valueset (p_value_set_name IN VARCHAR2)
      IS
         SELECT 'X'
           FROM fnd_flex_value_sets
          WHERE flex_value_set_name = p_value_set_name;
   BEGIN
      x_return_status := g_ret_sts_success;

      -- Assuming Defaulting has been done prior to the validation
      -- VALIDATION FOR FIELDS THAT ARE COMMON FOR BOTH QUESTIONS/CONSTANTS
      -- Question Type/Question Intent/Disabled Flag/question_datatype/question_sync_flag/object_version_number
      -- Question Name/Langauge/

      /**
      * This indicates the question type. FK to FND lookup OKC_XPRT_QUESTION_TYPE.
      * Possible values are Q and C. Q: Question, C: Constants
      **/
      IF p_xprt_question_rec.QN_CONST_type IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_not_null,
                              p_token1            => l_field,
                              p_token1_value      => 'QUESTION_TYPE'
                             );
      ELSE
         OPEN cur_val_question_lookup (l_qn_type_lookup_type,
                                       p_xprt_question_rec.QN_CONST_type
                                      );

         FETCH cur_val_question_lookup
          INTO l_validate_flag;

         CLOSE cur_val_question_lookup;

         IF NVL (l_validate_flag, 'Y') <> 'X'
         THEN
            x_error_count := x_error_count + 1;
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'QUESTION_TYPE'
                                );
         END IF;
      END IF;

      /**
      * Intent of Question or Constant. B: Buy, S: Sell.
      **/
      IF p_xprt_question_rec.QN_CONST_intent IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_OKC_I_NOT_NULL,
                              p_token1            => l_field,
                              p_token1_value      => 'INTENT'
                             );
      ELSE
         IF p_xprt_question_rec.QN_CONST_intent NOT IN ('B', 'S')
         THEN
            x_error_count := x_error_count + 1;
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_invalid_value,
                                 p_token1            => l_field,
                                 p_token1_value      => 'INTENT'
                                );
         END IF;
      END IF;

      IF p_xprt_question_rec.disabled_flag IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_not_null,
                              p_token1            => l_field,
                              p_token1_value      => 'DISABLED_FLAG'
                             );
      END IF;

      IF p_xprt_question_rec.question_sync_flag IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_not_null,
                              p_token1            => l_field,
                              p_token1_value      => 'QUESTION_SYNC_FLAG'
                             );
      END IF;

      IF p_xprt_question_rec.object_version_number IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_not_null,
                              p_token1            => l_field,
                              p_token1_value      => 'OBJECT_VERSION_NUMBER'
                             );
      END IF;

      IF p_xprt_question_rec.question_datatype IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_not_null,
                              p_token1            => l_field,
                              p_token1_value      => 'RESPONSE_TYPE'
                             );
      END IF;

      IF p_xprt_question_rec.QN_CONST_name IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_OKC_I_NOT_NULL,
                              p_token1            => l_field,
                              p_token1_value      => 'NAME'
                             );
      END IF;

      IF p_xprt_question_rec.source_lang IS NULL
      THEN
         x_error_count := x_error_count + 1;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => l_okc_i_not_null,
                              p_token1            => l_field,
                              p_token1_value      => 'SOURCE_LANG'
                             );
      END IF;

      -- A Question/Constant name must be unique
      IF p_xprt_question_rec.QN_CONST_name IS NOT NULL
         --AND p_xprt_question_rec.question_intent IS NOT NULL
         AND p_xprt_question_rec.QN_CONST_type IS NOT NULL
         AND p_xprt_question_rec.source_lang IS NOT NULL
         AND p_val_qn_name = 'Y'
      THEN
         validate_question_name
                   (p_question_name        => p_xprt_question_rec.QN_CONST_name,
                    --p_question_intent      => p_xprt_question_rec.question_intent,
                    p_question_type        => p_xprt_question_rec.QN_CONST_type,
                    p_lang                 => p_xprt_question_rec.source_lang,
                    p_question_id       => p_xprt_question_rec.QN_CONST_id,
                    x_return_status        => l_return_status
                   );

         IF (l_return_status <> g_ret_sts_success)
         THEN
            x_error_count := x_error_count + 1;
         END IF;
      END IF;

      -- Question Related Validations
      IF (p_xprt_question_rec.QN_CONST_type = 'Q')
      THEN
         -- Check Question Prompt
         IF p_xprt_question_rec.prompt IS NULL
         THEN
            x_error_count := x_error_count + 1;
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'QUESTION_PROMPT'
                                );
         ELSE
            l_return_status := NULL;
           IF    p_xprt_question_rec.prompt IS NOT NULL
             AND p_xprt_question_rec.QN_CONST_intent IS NOT NULL
             AND p_xprt_question_rec.source_lang IS NOT NULL
           THEN

                isQuestionPromptExists(p_question_prompt   => p_xprt_question_rec.prompt,
                                       p_question_intent   => p_xprt_question_rec.QN_CONST_intent,
                                       p_lang              => p_xprt_question_rec.source_lang,
                                       p_question_id       => p_xprt_question_rec.QN_CONST_id,
                                       x_return_status     => l_return_status  );

                 IF (l_return_status <> g_ret_sts_success)
                  THEN
                      x_error_count := x_error_count + 1;
                 END IF;

            END IF;
          END IF;

         l_validate_flag := NULL;
         -- Check Question Response Type
         IF p_xprt_question_rec.question_datatype IS NOT NULL
         THEN
            OPEN cur_val_question_lookup
                                       (l_qn_datatype_lookup_type,
                                        p_xprt_question_rec.question_datatype
                                       );

            FETCH cur_val_question_lookup
             INTO l_validate_flag;

            CLOSE cur_val_question_lookup;

            IF NVL (l_validate_flag, 'Y') <> 'X'
            THEN
               x_error_count := x_error_count + 1;
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'RESPONSE_TYPE'
                                   );
            -- IF Response Type is List of Values validate Valueset.
            ELSIF p_xprt_question_rec.question_datatype = 'L'
            THEN
               IF p_xprt_question_rec.value_set_name IS NULL
               THEN
                  x_error_count := x_error_count + 1;
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => l_okc_i_not_null,
                                       p_token1            => l_field,
                                       p_token1_value      => 'VALUE_SET_NAME'
                                      );
               ELSE
                  l_validate_flag := NULL;
                  OPEN cur_validate_valueset
                                          (p_xprt_question_rec.value_set_name);

                  FETCH cur_validate_valueset
                   INTO l_validate_flag;

                  CLOSE cur_validate_valueset;

                  IF NVL (l_validate_flag, 'Y') <> 'X'
                  THEN
                     x_error_count := x_error_count + 1;
                     okc_api.set_message
                                   (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'VALUE_SET_NAME'
                                   );
                  END IF;
               END IF;
            END IF;                            --  Question Data Type is valid
         END IF;                               -- Check Question Response Type
      -- Constants Related Validations
      ELSIF (p_xprt_question_rec.QN_CONST_type = 'C')
      THEN
         IF p_xprt_question_rec.DEFAULT_VALUE IS NULL
         THEN
            x_error_count := x_error_count + 1;
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => l_okc_i_not_null,
                                 p_token1            => l_field,
                                 p_token1_value      => 'DEFAULT_VALUE'
                                );
         END IF;
      END IF;

      IF (x_error_count > 0)
      THEN
         x_return_status := g_ret_sts_error;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END validate_row;

   PROCEDURE insert_row (
      p_question_id              IN OUT NOCOPY   NUMBER,
      p_question_type            IN              VARCHAR2,
      p_question_intent          IN              VARCHAR2,
      p_disabled_flag            IN              VARCHAR2,
      p_question_datatype        IN              VARCHAR2,
      p_value_set_name           IN              VARCHAR2,
      p_default_value            IN              NUMBER,
      p_minimum_value            IN              NUMBER,
      p_maximum_value            IN              NUMBER,
      p_question_sync_flag       IN              VARCHAR2,
      p_object_version_number    IN              NUMBER,
      p_created_by               IN              NUMBER,
      p_creation_date            IN              DATE,
      p_last_updated_by          IN              NUMBER,
      p_last_update_date         IN              DATE,
      p_last_update_login        IN              NUMBER,
      p_program_id               IN              NUMBER,
      p_request_id               IN              NUMBER,
      p_program_application_id   IN              NUMBER,
      p_program_update_date      IN              DATE,
      p_tl_question_type         IN              VARCHAR2,
      p_source_lang              IN              VARCHAR2,
      p_question_name            IN              VARCHAR2,
      p_description              IN              VARCHAR2,
      p_prompt                   IN              VARCHAR2,
      x_return_status            OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN

      x_return_status := g_ret_sts_success;

      IF p_question_id IS NULL
      THEN
         SELECT OKC_XPRT_QUESTIONS_B_S.NEXTVAL
           INTO p_question_id
           FROM DUAL;
      END IF;

      INSERT INTO okc_xprt_questions_b
                  (question_id, question_type, question_intent,
                   disabled_flag, question_datatype, value_set_name,
                   DEFAULT_VALUE, minimum_value, maximum_value,
                   question_sync_flag, object_version_number,
                   created_by, creation_date, last_updated_by,
                   last_update_date, last_update_login, program_id,
                   request_id, program_application_id,
                   program_update_date
                  )
           VALUES (p_question_id, p_question_type, p_question_intent,
                   p_disabled_flag, p_question_datatype, p_value_set_name,
                   p_default_value, p_minimum_value, p_maximum_value,
                   p_question_sync_flag, p_object_version_number,
                   p_created_by, p_creation_date, p_last_updated_by,
                   p_last_update_date, p_last_update_login, p_program_id,
                   p_request_id, p_program_application_id,
                   p_program_update_date
                  )
               -- returning question_id into p_question_id
                  ;

      INSERT INTO okc_xprt_questions_tl
                  (question_id, question_name, question_type, LANGUAGE,
                   source_lang, description, prompt, created_by,
                   creation_date, last_updated_by, last_update_date,
                   last_update_login)
         SELECT p_question_id, p_question_name, p_question_type,
                l.language_code, p_source_lang, p_description, p_prompt,
                p_created_by, p_creation_date, p_last_updated_by,
                p_last_update_date, p_last_update_login
           FROM fnd_languages l
          WHERE l.installed_flag IN ('I', 'B')
            AND NOT EXISTS (
                   SELECT NULL
                     FROM okc_xprt_questions_tl t
                    WHERE t.question_id = p_question_id
                      AND t.LANGUAGE = l.language_code);
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END insert_row;

   PROCEDURE read_message (
      p_entity    IN  VARCHAR2,
      p_process   IN              VARCHAR2,
      p_action    IN VARCHAR2,
      x_message   IN OUT NOCOPY   VARCHAR2
   )
   IS
      l_message   VARCHAR2 (2000);
      l_entity    VARCHAR2(30);

   BEGIN





      FOR i IN 1 .. fnd_msg_pub.count_msg
      LOOP
         l_message := fnd_msg_pub.get (i, p_encoded => fnd_api.g_false);


         IF LENGTH (l_message) + LENGTH (Nvl(x_message,' ')) <= 2500
         THEN

            x_message := x_message || l_message;

         ELSE
           EXIT;
         END IF;
      END LOOP;



      IF Nvl(p_entity,'Q') = 'Q' THEN
         l_entity := 'QUESTION';
      ELSE
         l_entity := 'CONSTANT';
      END IF;

      fnd_msg_pub.initialize;

      IF p_action = 'CREATE' THEN
        okc_api.set_message(p_app_name => g_app_name,
                            p_msg_name => 'OKC_I_CREATION_ENTITY_FAIL',
                            p_token1   => 'ENTITY',
                            p_token1_value => l_entity
                           );
      ELSIF p_action ='UPDATE' THEN
         okc_api.set_message(p_app_name => g_app_name,
                            p_msg_name => 'OKC_I_UPDATE_ENTITY_FAIL',
                            p_token1   => 'ENTITY',
                            p_token1_value => l_entity
                           );
      END IF;

      okc_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKC_I_ERROR_PROCEDURE',
                          p_token1       => 'PROCEDURE',
                          p_token1_value =>  p_process
                          );

       l_message  :=    fnd_msg_pub.get (1, p_encoded => fnd_api.g_false);
       l_message  :=    l_message || fnd_msg_pub.get (2, p_encoded => fnd_api.g_false);

       x_message  :=     x_message ||'  '||l_message;



   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END read_message;

   PROCEDURE create_question (
      p_xprt_question_rec   IN OUT NOCOPY   xprt_qn_const_rec_type,
      p_commit              IN VARCHAR2 := FND_API.G_FALSE,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_data            OUT NOCOPY      VARCHAR2
   )
   IS
      l_return_status    VARCHAR2 (1);
      l_return_status2   VARCHAR2 (1);

   BEGIN
      /**
      *  Default Row
      *  Validate Row
      *  Insert Row
      **/
      SAVEPOINT create_question_sp;
      x_return_status :=  g_ret_sts_success;




      fnd_msg_pub.initialize;
      default_row (p_xprt_question_rec      => p_xprt_question_rec,
                   x_returns_status         => l_return_status
                  );


      IF l_return_status <> g_ret_sts_success
      THEN

         x_return_status := l_return_status;
         -- x_msg_count     := FND_MSG_PUB.Count_Msg;
         read_message( p_xprt_question_rec.qn_const_type
                     ,'DEFAULT_ROW'
                     , 'CREATE'
                     , x_msg_data);

         fnd_msg_pub.initialize;
         ROLLBACK TO create_question_sp;
         RETURN;
      END IF;


      l_return_status := NULL;
      fnd_msg_pub.initialize;
      validate_row (p_xprt_question_rec      => p_xprt_question_rec,
                    x_return_status          => l_return_status
                   );



      IF l_return_status <> g_ret_sts_success
      THEN

         x_return_status := l_return_status;
         -- x_msg_count     := FND_MSG_PUB.Count_Msg;
         read_message (p_xprt_question_rec.qn_const_type
         ,'VALIDATE_ROW', 'CREATE',x_msg_data);
         fnd_msg_pub.initialize;
         ROLLBACK TO create_question_sp;
         RETURN;
      END IF;

      l_return_status := '';
      fnd_msg_pub.initialize;

      insert_row
         (p_question_id                 => p_xprt_question_rec.QN_CONST_id,
          p_question_type               => p_xprt_question_rec.QN_CONST_type,
          p_question_intent             => p_xprt_question_rec.QN_CONST_intent,
          p_disabled_flag               => p_xprt_question_rec.disabled_flag,
          p_question_datatype           => p_xprt_question_rec.question_datatype,
          p_value_set_name              => p_xprt_question_rec.value_set_name,
          p_default_value               => p_xprt_question_rec.DEFAULT_VALUE,
          p_minimum_value               => p_xprt_question_rec.minimum_value,
          p_maximum_value               => p_xprt_question_rec.maximum_value,
          p_question_sync_flag          => p_xprt_question_rec.question_sync_flag,
          p_object_version_number       => p_xprt_question_rec.object_version_number,
          p_created_by                  => p_xprt_question_rec.created_by,
          p_creation_date               => p_xprt_question_rec.creation_date,
          p_last_updated_by             => p_xprt_question_rec.last_updated_by,
          p_last_update_date            => p_xprt_question_rec.last_update_date,
          p_last_update_login           => p_xprt_question_rec.last_update_login,
          p_program_id                  => p_xprt_question_rec.program_id,
          p_request_id                  => p_xprt_question_rec.request_id,
          p_program_application_id      => p_xprt_question_rec.program_application_id,
          p_program_update_date         => p_xprt_question_rec.program_update_date,
          p_tl_question_type            => p_xprt_question_rec.qn_const_type,
          p_source_lang                 => p_xprt_question_rec.source_lang,
          p_question_name               => p_xprt_question_rec.QN_CONST_name,
          p_description                 => p_xprt_question_rec.description,
          p_prompt                      => p_xprt_question_rec.prompt,
          x_return_status               => l_return_status
         );

      IF l_return_status <> g_ret_sts_success
      THEN

         x_return_status := l_return_status;
         read_message (p_xprt_question_rec.qn_const_type, 'INSERT_ROW', 'CREATE', x_msg_data);
         fnd_msg_pub.initialize;
         ROLLBACK TO create_question_sp;
         RETURN;
      END IF;

      IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT ;
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_unexp_error;
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
   END create_question;

   PROCEDURE update_question(p_xprt_update_question_rec IN OUT NOCOPY xprt_qn_const_rec_type,
                             p_commit                   IN VARCHAR2 := FND_API.G_FALSE,
                             x_return_status            OUT NOCOPY VARCHAR2,
                             x_msg_data                 OUT NOCOPY VARCHAR2) IS

    l_update_flag VARCHAR2(1);

    l_question_type     OKC_XPRT_QUESTIONS_B.question_type%type;
    l_question_intent   OKC_XPRT_QUESTIONS_B.Question_intent%TYPE;
    l_disabled_flag     OKC_XPRT_QUESTIONS_B.disabled_flag%TYPE;
    l_question_datatype OKC_XPRT_QUESTIONS_B.question_datatype%TYPE;
    l_value_set_name    OKC_XPRT_QUESTIONS_B.value_set_name%TYPE;
    l_object_version_number  NUMBER;

    l_question_name OKC_XPRT_QUESTIONS_TL.question_name%TYPE;
    l_source_lang   OKC_XPRT_QUESTIONS_TL.source_lang%TYPE;
    l_lang          OKC_XPRT_QUESTIONS_TL.language%TYPE;
    l_description   OKC_XPRT_QUESTIONS_TL.description%TYPE;
    l_prompt        OKC_XPRT_QUESTIONS_TL.prompt%TYPE;

    l_default_value OKC_XPRT_QUESTIONS_B.default_value%TYPE;

    l_val_question_name_flag VARCHAR2(1) := 'N';
    l_return_status          varchar2(1);
    l_error_count            NUMBER := 0;

    l_ret_status VARCHAR2(1);
    l_entity VARCHAR2(30);

  BEGIN



    x_return_status := G_RET_STS_SUCCESS;
    --x_msg_count     := 0;
    x_msg_data := NULL;
    -- Update QuestionSyncFlag to 'Y' for any changes
    -- Increment Object Version Number
    -- Update Last Updated By
    -- Update Last Update Date
    -- Update Last Update Login

    -- Assuming question id is passed for the update rec
    -- If it is not passed need to derive it from the
    FND_MSG_PUB.initialize;
    BEGIN
      SELECT question_type,
             question_intent,
             disabled_flag,
             question_datatype,
             value_set_name,
             default_value,
             object_version_number
        INTO l_question_type,
             l_question_intent,
             l_disabled_flag,
             l_question_datatype,
             l_value_set_name,
             l_default_value,
             l_object_version_number
        FROM okc_xprt_questions_b
       WHERE question_id = p_xprt_update_question_rec.QN_CONST_id
         AND question_type = p_xprt_update_question_rec.QN_CONST_type;





      SELECT question_name, language, source_lang, description, prompt
        INTO l_question_name, l_lang, l_source_lang, l_description, l_prompt
        FROM okc_xprt_questions_tl
       WHERE question_id = p_xprt_update_question_rec.qn_const_id
         AND language =
             Decode(p_xprt_update_question_rec.lang,OKC_API.G_MISS_CHAR, UserEnv('lang'),
                                                    NULL,UserEnv('lang')
                                                   ,p_xprt_update_question_rec.lang)
        AND question_type = p_xprt_update_question_rec.qn_const_type
                                                           ;

    EXCEPTION
      WHEN No_Data_Found THEN
        x_return_status := g_ret_sts_error;
        okc_api.set_message
                                   (p_app_name          => g_app_name,
                                    p_msg_name          => l_okc_i_invalid_value,
                                    p_token1            => l_field,
                                    p_token1_value      => 'QUESTION_ID'
                                   );
        x_msg_data  :=  fnd_msg_pub.get (1, p_encoded => fnd_api.g_false);
         FND_MSG_PUB.initialize;
        RETURN;

      WHEN OTHERS THEN
        x_return_status := g_ret_sts_unexp_error;
        -- x_msg_count  := 1;
        Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_UNEXPECTED_ERROR,
                            p_token1       => G_SQLCODE_TOKEN,
                            p_token1_value => sqlcode,
                            p_token2       => G_SQLERRM_TOKEN,
                            p_token2_value => sqlerrm);
        x_msg_data  :=  fnd_msg_pub.get (1, p_encoded => fnd_api.g_false);
        FND_MSG_PUB.initialize;
        RETURN;
    END;

    IF
      (   p_xprt_update_question_rec.qn_const_type <> OKC_API.G_MISS_CHAR
      AND p_xprt_update_question_rec.qn_const_type <> l_question_type)
      OR  p_xprt_update_question_rec.qn_const_type IS NULL
    THEN
        x_return_status := G_RET_STS_ERROR;
        Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKC_I_NO_CHANGE',
                            p_token1   => 'FIELD',
                            p_token1_value => 'QUESTION_TYPE' );
        x_msg_data  :=  fnd_msg_pub.get (1, p_encoded => fnd_api.g_false);
        FND_MSG_PUB.initialize;
        RETURN;
    END IF;



    SAVEPOINT update_question_sp;
    -- Validate the attributes
    l_return_status := '';
    FND_MSG_PUB.initialize;

    l_return_status := G_RET_STS_SUCCESS;
    l_update_flag   := okc_xprt_util_pvt.Ok_To_Delete_Question(p_question_id => p_xprt_update_question_rec.qn_const_id);

    IF  l_question_type= 'Q' THEN
      l_entity  := 'QUESTION';
    ELSE
      l_entity  := 'CONSTANT';
    END IF;

    IF Nvl(l_update_flag,'Y') = 'N' THEN
      -- Question/Constant Used in a Rule

      IF  p_xprt_update_question_rec.qn_const_intent IS NULL
            OR
          (p_xprt_update_question_rec.qn_const_intent <> OKC_API.G_MISS_CHAR
           AND
           p_xprt_update_question_rec.qn_const_intent <> l_question_intent
           )
      THEN
          l_return_status := G_RET_STS_ERROR;
          Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKC_I_QC_USED_IN_RULE',
                              p_token1    => 'ENTITY'   ,
                              p_token1_value => l_entity,
                              p_token2  => 'FIELD',
                              p_token2_value  => 'QUESTION_INTENT');
      END IF;

      IF p_xprt_update_question_rec.qn_const_name IS NULL
         OR
         (p_xprt_update_question_rec.qn_const_name <> OKC_API.G_MISS_CHAR AND
          p_xprt_update_question_rec.qn_const_name <> l_question_name) THEN
        l_return_status := G_RET_STS_ERROR;
        Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKC_I_QC_USED_IN_RULE',
                              p_token1    => 'ENTITY'   ,
                              p_token1_value => l_entity,
                              p_token2  => 'FIELD',
                              p_token2_value  => 'QUESTION_NAME');
      END IF;

      -- Check whether user wants to update fields that are not allowed to update
      IF (l_question_type = 'Q') THEN
        --  Question Record
        -- VALIDATE Response Type/ Value Set
        IF p_xprt_update_question_rec.question_datatype IS NULL
         OR
           (p_xprt_update_question_rec.question_datatype <>
            OKC_API.G_MISS_CHAR AND p_xprt_update_question_rec.question_datatype <>
            l_question_datatype)

         THEN
          l_return_status := G_RET_STS_ERROR;
          Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKC_I_QC_USED_IN_RULE',
                              p_token1    => 'ENTITY'   ,
                              p_token1_value => l_entity,
                              p_token2  => 'FIELD',
                              p_token2_value  => 'QUESTION_DATATYPE');

        END IF;

        IF p_xprt_update_question_rec.value_set_name IS NULL OR
          (p_xprt_update_question_rec.value_set_name <>
           OKC_API.G_MISS_CHAR AND
           p_xprt_update_question_rec.value_set_name <> l_value_set_name) THEN
           l_return_status := G_RET_STS_ERROR;
           Okc_Api.Set_Message(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKC_I_QC_USED_IN_RULE',
                              p_token1    => 'ENTITY'   ,
                              p_token1_value => l_entity,
                              p_token2  => 'FIELD',
                              p_token2_value  => 'VALUE_SET_NAME');

        END IF;
      END IF;
    END IF;

    IF l_return_status <> G_RET_STS_SUCCESS THEN
      x_return_status := G_RET_STS_ERROR;
      read_message(p_xprt_update_question_rec.qn_const_type,'UPDATE_QUESTION', 'UPDATE', x_msg_data);
      FND_MSG_PUB.initialize;
      ROLLBACK TO update_question_sp;
      return;
    END IF;



    -- Record whether intent or question/constant name is changed
    -- If changed need to validate for duplicates
    IF p_xprt_update_question_rec.qn_const_name IS NULL
       OR
        (p_xprt_update_question_rec.qn_const_name <> OKC_API.G_MISS_CHAR
         AND
         p_xprt_update_question_rec.qn_const_name <> l_question_name) THEN
            l_val_question_name_flag := 'Y';
    END IF;



    -- Default the attributes
    p_xprt_update_question_rec.last_updated_by   := fnd_global.user_id;
    p_xprt_update_question_rec.last_update_date  := SYSDATE;
    p_xprt_update_question_rec.last_update_login := fnd_global.login_id;

    IF  p_xprt_update_question_rec.qn_const_type = OKC_API.G_MISS_CHAR THEN
        p_xprt_update_question_rec.qn_const_type :=  l_question_type;
    END IF;

    IF p_xprt_update_question_rec.qn_const_type = 'Q' THEN
       p_xprt_update_question_rec.question_sync_flag := 'Y';
    ELSE
       p_xprt_update_question_rec.question_sync_flag := 'N';
    END IF;

    IF p_xprt_update_question_rec.qn_const_intent = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.qn_const_intent := l_question_intent;
    END IF;

    IF p_xprt_update_question_rec.disabled_flag = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.disabled_flag := l_disabled_flag;
    END IF;

    IF p_xprt_update_question_rec.qn_const_type = 'C' THEN
       p_xprt_update_question_rec.question_datatype := 'N';
    END IF;


    IF p_xprt_update_question_rec.question_datatype = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.question_datatype := l_question_datatype;
     ELSE
      IF p_xprt_update_question_rec.question_datatype = 'B' THEN
         p_xprt_update_question_rec.value_set_name := 'OKC_XPRT_YES_NO';
      ELSIF p_xprt_update_question_rec.question_datatype = 'N' THEN
         p_xprt_update_question_rec.value_set_name := NULL;
      END IF;
    END IF;

    IF p_xprt_update_question_rec.value_set_name = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.value_set_name := l_value_set_name;
    END IF;

    IF p_xprt_update_question_rec.default_value = OKC_API.G_MISS_NUM THEN
      p_xprt_update_question_rec.default_value := l_default_value;
    END IF;

    IF p_xprt_update_question_rec.qn_const_name = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.qn_const_name := l_question_name;
    END IF;

    IF p_xprt_update_question_rec.lang = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.lang := l_lang;
    END IF;

     IF p_xprt_update_question_rec.source_lang = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.source_lang := l_source_lang;
    END IF;


    IF p_xprt_update_question_rec.description = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.description := l_description;
    END IF;

    IF p_xprt_update_question_rec.prompt = OKC_API.G_MISS_CHAR THEN
      p_xprt_update_question_rec.prompt := l_prompt;
    END IF;



    validate_row(p_xprt_question_rec => p_xprt_update_question_rec,
                 p_val_qn_name       => l_val_question_name_flag,
                 x_return_status     => l_ret_status);

    IF l_ret_status <> G_RET_STS_SUCCESS
     THEN
      x_return_status := G_RET_STS_ERROR;
      read_message(p_xprt_update_question_rec.qn_const_type,'VALIDATE_ROW','UPDATE', x_msg_data);
      FND_MSG_PUB.initialize;
      ROLLBACK TO update_question_sp;
      RETURN;
    END IF;



    UPDATE okc_xprt_questions_b

       SET question_intent       = p_xprt_update_question_rec.qn_const_intent,
           disabled_flag         = p_xprt_update_question_rec.disabled_flag,
           question_datatype     = p_xprt_update_question_rec.question_datatype,
           value_set_name        = p_xprt_update_question_rec.value_set_name,
           default_value         = p_xprt_update_question_rec.default_value,
           question_sync_flag    = p_xprt_update_question_rec.question_sync_flag,
           object_version_number = l_object_version_number + 1,
           last_updated_by       = p_xprt_update_question_rec.last_updated_by,
           last_update_date      = p_xprt_update_question_rec.last_update_date,
           last_update_login     = p_xprt_update_question_rec.last_update_login

     WHERE question_id = p_xprt_update_question_rec.qn_const_id;

    UPDATE okc_xprt_questions_tl
       SET question_name     = p_xprt_update_question_rec.qn_const_name,
           description       = p_xprt_update_question_rec.description,
           prompt            = p_xprt_update_question_rec.prompt,
           last_updated_by   = p_xprt_update_question_rec.last_updated_by,
           last_update_date  = p_xprt_update_question_rec.last_update_date,
           last_update_login = p_xprt_update_question_rec.last_update_login
     WHERE question_id       = p_xprt_update_question_rec.qn_const_id
       AND LANGUAGE          = p_xprt_update_question_rec.lang;

       x_return_status := G_RET_STS_SUCCESS;

      IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT ;
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := g_ret_sts_unexp_error;

      Okc_Api.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);

      x_msg_data  :=  fnd_msg_pub.get (1, p_encoded => fnd_api.g_false);
      ROLLBACK TO update_question_sp;
  END update_question;
END okc_xprt_question_pvt;

/
