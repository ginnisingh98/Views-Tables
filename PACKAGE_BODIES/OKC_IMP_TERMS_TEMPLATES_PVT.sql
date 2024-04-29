--------------------------------------------------------
--  DDL for Package Body OKC_IMP_TERMS_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_IMP_TERMS_TEMPLATES_PVT" 
/*$Header: OKCVITTB.pls 120.0.12010000.7 2013/11/04 06:43:09 serukull noship $*/
AS
   CURSOR cur_val_lookup (p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
   IS
      SELECT 'Y'
        FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code
         AND enabled_flag = 'Y'
         AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, SYSDATE - 1)
                                 AND NVL (TRUNC (end_date_active),
                                          TRUNC (SYSDATE)
                                         );

   CURSOR cur_lookup_meaning (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
   )
   IS
      SELECT 'Y', meaning
        FROM fnd_lookups
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code
         AND enabled_flag = 'Y'
         AND TRUNC (SYSDATE) BETWEEN NVL (start_date_active, SYSDATE - 1)
                                 AND NVL (TRUNC (end_date_active),
                                          TRUNC (SYSDATE)
                                         );

   CURSOR cur_validate_ou (p_org_id IN NUMBER)
   IS
      SELECT 'Y'
        FROM hr_operating_units ou, hr_organization_information oi
       WHERE mo_global.check_access (ou.organization_id) = 'Y'
         AND oi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
         AND oi.organization_id = ou.organization_id
         AND NVL (date_to, SYSDATE) >= SYSDATE
         AND ou.organization_id = p_org_id;

   g_template_id                  NUMBER;
   g_template_intent              VARCHAR2 (60);
   g_template_status_code         VARCHAR2 (60);
   g_template_start_date          DATE;
   g_template_end_date            DATE;
   g_template_org_id              NUMBER;
   g_clause_update_allowed        VARCHAR2 (1);
   g_deliverable_update_allowed   VARCHAR2 (1);
   g_headerinfo_update_allowed    VARCHAR2 (1);
   g_unexpected_error    CONSTANT VARCHAR2 (200) := 'OKC_UNEXPECTED_ERROR';
   g_sqlerrm_token       CONSTANT VARCHAR2 (200) := 'ERROR_MESSAGE';
   g_sqlcode_token       CONSTANT VARCHAR2 (200) := 'ERROR_CODE';

   PROCEDURE create_section (
      p_section_rec   IN OUT NOCOPY   section_rec_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_article (
      p_article_rec   IN OUT NOCOPY   k_article_rec_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_deliverable (
      p_deliverable_rec   IN OUT NOCOPY   deliverable_rec_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_template (
      p_template_rec   IN OUT NOCOPY   terms_template_rec_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE update_template (
      p_template_rec   IN OUT NOCOPY   terms_template_rec_type
   );

   PROCEDURE create_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type
   );

   PROCEDURE validate_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type,
      p_mode             IN              VARCHAR2 := 'CREATE'
   );

   PROCEDURE update_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type
   );

   PROCEDURE delete_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type
   );

---------------------------------------------------------------
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

-------------------------------------------------------------
   PROCEDURE read_message (x_message IN OUT NOCOPY VARCHAR2)
   IS
      l_message   VARCHAR2 (2000);
   BEGIN
      FOR i IN 1 .. fnd_msg_pub.count_msg
      LOOP
         l_message := fnd_msg_pub.get (i, p_encoded => fnd_api.g_false);

         IF (LENGTH (l_message) + LENGTH (NVL (x_message, ' '))) <= 2500
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

-------------------
-- Deliverable Helper procedures/functions
   FUNCTION getuomvalue (p_duration IN NUMBER, p_uom IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      IF p_duration IS NOT NULL AND p_duration > 1 AND 'MTH' = p_uom
      THEN
         RETURN 'MTHS';
      ELSE
         IF p_duration IS NOT NULL AND p_duration <= 1 AND 'MTH' = p_uom
         THEN
            RETURN 'MTH';
         END IF;
      END IF;

      IF p_duration IS NOT NULL AND p_duration > 1 AND 'WK' = p_uom
      THEN
         RETURN 'WKS';
      ELSE
         IF p_duration IS NOT NULL AND p_duration <= 1 AND 'WK' = p_uom
         THEN
            RETURN 'WK';
         END IF;
      END IF;

      IF p_duration IS NOT NULL AND p_duration > 1 AND 'DAY' = p_uom
      THEN
         RETURN 'DAYS';
      ELSE
         IF p_duration IS NOT NULL AND p_duration <= 1 AND 'DAY' = p_uom
         THEN
            RETURN 'DAY';
         END IF;
      END IF;

      RETURN p_uom;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END getuomvalue;

   FUNCTION getdeldisplaysequence (p_deliverable_id IN NUMBER)
      RETURN NUMBER
   IS
      l_disp_sequence   NUMBER;
   BEGIN
      l_disp_sequence := REMAINDER (p_deliverable_id, 1000);

      IF l_disp_sequence < 0
      THEN
         RETURN l_disp_sequence + 1000;
      ELSE
         RETURN l_disp_sequence;
      END IF;
   END getdeldisplaysequence;

    FUNCTION isvalidcontact (p_contact_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR cur_val_contact
      IS
         SELECT 'Y'
           FROM per_all_people_f e
          WHERE e.current_employee_flag = 'Y'
            AND TRUNC (SYSDATE) BETWEEN NVL (e.effective_start_date,
                                             SYSDATE - 1
                                            )
                                    AND NVL (e.effective_end_date,
                                             SYSDATE + 1)
            AND person_id = p_contact_id;

      -- CWK contract worket
      CURSOR cur_val_contact2
      IS
         SELECT 'Y'
           FROM per_all_people_f e
          WHERE e.current_npw_flag = 'Y'
            AND TRUNC (SYSDATE) BETWEEN NVL (e.effective_start_date,
                                             SYSDATE - 1
                                            )
                                    AND NVL (e.effective_end_date,
                                             SYSDATE + 1)
            AND person_id = p_contact_id;

      l_valid_contact   VARCHAR2 (1) := 'N';
   BEGIN

      OPEN cur_val_contact;
      FETCH cur_val_contact
       INTO l_valid_contact;
        IF  cur_val_contact%FOUND THEN
            CLOSE cur_val_contact;
            RETURN 'Y';
        END IF;
        CLOSE  cur_val_contact;


         IF NVL (fnd_profile.VALUE ('HR_TREAT_CWK_AS_EMP'), 'N') = 'Y'
         THEN



            OPEN cur_val_contact;
            FETCH cur_val_contact
             INTO l_valid_contact;

            IF cur_val_contact%FOUND THEN
              CLOSE cur_val_contact;
              RETURN 'Y';
            END IF;

            CLOSE cur_val_contact;

         END IF;


      RETURN 'N';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidcontact;

   FUNCTION isvalidstartbusdocevent (
      p_document_type      IN   VARCHAR2,
      p_deliverable_type   IN   VARCHAR2,
      p_bus_doc_event_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_val_event
      IS
         SELECT 'Y'
           FROM okc_bus_doc_events_v evts,
                okc_bus_doc_types_b doctypes,
                okc_del_bus_doc_combxns delcomb,
                okc_deliverable_types_b deltypes
          WHERE evts.bus_doc_event_id = p_bus_doc_event_id
            AND 'TEMPLATE' = p_document_type
            AND deltypes.deliverable_type_code = p_deliverable_type
            AND doctypes.document_type_class = delcomb.document_type_class
            AND deltypes.deliverable_type_code = delcomb.deliverable_type_code
            AND doctypes.document_type = evts.bus_doc_type
            AND (   doctypes.document_type IN (
                       SELECT target_response_doc_type
                         FROM okc_bus_doc_types_b
                        WHERE document_type_class =
                                                   delcomb.document_type_class
                          AND target_response_doc_type IS NOT NULL)
                 OR doctypes.show_in_lov_yn = 'Y'
                )
            AND (   evts.start_end_qualifier = 'BOTH'
                 OR evts.start_end_qualifier = 'START'
                );

      l_valid_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_val_event;

      FETCH cur_val_event
       INTO l_valid_flag;

      CLOSE cur_val_event;

      RETURN NVL (l_valid_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidstartbusdocevent;

   FUNCTION isvalidendbusdocevent (
      p_document_type      IN   VARCHAR2,
      p_deliverable_type   IN   VARCHAR2,
      p_bus_doc_event_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_val_event
      IS
         SELECT 'Y'
           FROM okc_bus_doc_events_v evts,
                okc_bus_doc_types_b doctypes,
                okc_del_bus_doc_combxns delcomb,
                okc_deliverable_types_b deltypes
          WHERE 'TEMPLATE' = p_document_type
            AND evts.bus_doc_event_id = p_bus_doc_event_id
            AND deltypes.deliverable_type_code = p_deliverable_type
            --- :selectedDeliverableType
            AND doctypes.document_type_class = delcomb.document_type_class
            AND deltypes.deliverable_type_code = delcomb.deliverable_type_code
            AND doctypes.show_in_lov_yn = 'Y'
            AND doctypes.document_type = evts.bus_doc_type
            AND (   evts.start_end_qualifier = 'BOTH'
                 OR evts.start_end_qualifier = 'END'
                );

      l_valid_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_val_event;

      FETCH cur_val_event
       INTO l_valid_flag;

      CLOSE cur_val_event;

      RETURN NVL (l_valid_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidendbusdocevent;

   PROCEDURE get_event_details (
      p_event_id       IN              NUMBER,
      x_before_after   OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      SELECT before_after
        INTO x_before_after
        FROM okc_bus_doc_events_b
       WHERE bus_doc_event_id = p_event_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END get_event_details;

  FUNCTION getprintduedatemsgname (
      p_recurring_flag            IN   VARCHAR2,
      p_start_fixed_flag          IN   VARCHAR2,
      p_end_fixed_flag            IN   VARCHAR2,
      p_repeating_frequency_uom   IN   VARCHAR2,
      p_relative_st_date_uom      IN   VARCHAR2,
      p_relative_end_date_uom     IN   VARCHAR2,
      p_start_evt_before_after    IN   VARCHAR2,
      p_end_evt_before_after      IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_print_due_dt_msg_name
      IS
         SELECT message_name
           FROM okc_del_messages
          WHERE 1 = 1
            AND recurring_flag = p_recurring_flag
            AND start_fixed_flag = p_start_fixed_flag
            AND end_fixed_flag = p_end_fixed_flag
            AND Nvl(repeating_frequency_uom,'a') = Nvl(p_repeating_frequency_uom, 'a')
            AND Nvl(relative_st_date_uom,'a') = Nvl(p_relative_st_date_uom ,'a')
            AND Nvl(relative_end_date_uom,'a') = Nvl(p_relative_end_date_uom,'a')
            AND Nvl(start_evt_before_after,'a') = Nvl(p_start_evt_before_after,'a')
            AND Nvl(end_evt_before_after,'a') = Nvl(p_end_evt_before_after,'a');

      l_msg_name   VARCHAR2 (60);
   BEGIN
      OPEN cur_print_due_dt_msg_name;

      FETCH cur_print_due_dt_msg_name
       INTO l_msg_name;

      CLOSE cur_print_due_dt_msg_name;

      RETURN l_msg_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END getprintduedatemsgname;

   FUNCTION isvalidstendeventsmatch (
      p_st_event_id    IN   NUMBER,
      p_end_event_id   IN   NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR cur_val_event
      IS
         SELECT 'Y'
           FROM okc_bus_doc_events_b start_event,
                okc_bus_doc_events_b end_event
          WHERE start_event.bus_doc_event_id = p_st_event_id  --start event id
            AND end_event.bus_doc_event_id = p_end_event_id     --end event id
            AND start_event.bus_doc_type = end_event.bus_doc_type
         UNION
         SELECT 'Y'
           FROM okc_bus_doc_events_b start_event,
                okc_bus_doc_events_b end_event,
                okc_bus_doc_types_b end_type
          WHERE start_event.bus_doc_event_id = p_st_event_id  --start event id
            AND end_event.bus_doc_event_id = p_end_event_id     --end event id
            AND end_type.document_type = end_event.bus_doc_type
            AND start_event.bus_doc_type = end_type.target_response_doc_type
         UNION
         SELECT 'Y'
           FROM okc_bus_doc_events_b start_event,
                okc_bus_doc_events_b end_event,
                okc_bus_doc_types_b start_type
          WHERE start_event.bus_doc_event_id = p_st_event_id  --start event id
            AND end_event.bus_doc_event_id = p_end_event_id     --end event id
            AND start_type.document_type = start_event.bus_doc_type
            AND end_event.bus_doc_type = start_type.target_response_doc_type;

      l_val_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_val_event;

      FETCH cur_val_event
       INTO l_val_flag;

      CLOSE cur_val_event;

      RETURN NVL (l_val_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidstendeventsmatch;

-------------------
   FUNCTION inittemplateinfo (p_template_id IN NUMBER)
      RETURN VARCHAR2
   IS
   BEGIN
      /*IF p_template_id = Nvl(g_template_id,'-1') THEN
         RETURN 'Y';
      END IF;*/
      SELECT template_id, intent, status_code,
             start_date, end_date, org_id
        INTO g_template_id, g_template_intent, g_template_status_code,
             g_template_start_date, g_template_end_date, g_template_org_id
        FROM okc_terms_templates_all
       WHERE template_id = p_template_id;

      IF g_template_status_code IN ('DRAFT', 'REVISION', 'REJECTED')
      THEN
         g_clause_update_allowed := 'Y';
         g_deliverable_update_allowed := 'Y';
         g_headerinfo_update_allowed := 'Y';
      ELSE
         g_clause_update_allowed := 'N';
         g_deliverable_update_allowed := 'N';

         IF g_template_status_code = 'APPROVED'
         THEN
            g_headerinfo_update_allowed := 'Y';
         ELSE
            g_headerinfo_update_allowed := 'N';
         END IF;
      END IF;

      RETURN 'Y';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END inittemplateinfo;

   FUNCTION isvalidou (p_org_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_validate_ou (p_org_id);

      FETCH cur_validate_ou
       INTO l_flag;

      CLOSE cur_validate_ou;

      RETURN NVL (l_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         IF cur_validate_ou%ISOPEN
         THEN
            CLOSE cur_validate_ou;
         END IF;

         RETURN 'N';
   END isvalidou;

   FUNCTION isvalidtemplate (p_template_id IN NUMBER, p_org_id IN NUMBER)
      RETURN VARCHAR2
   IS
      l_flag   VARCHAR2 (1);
   BEGIN
      SELECT 'Y'
        INTO l_flag
        FROM okc_terms_templates_all
       WHERE template_id = p_template_id AND org_id = p_org_id;

      RETURN NVL (l_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidtemplate;

   FUNCTION isvalidlookup (p_lookup_type IN VARCHAR2, p_lookup_code IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_val_lookup (p_lookup_type, p_lookup_code);

      FETCH cur_val_lookup
       INTO l_flag;

      CLOSE cur_val_lookup;

      RETURN NVL (l_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidlookup;

   FUNCTION isvalidlookup (
      p_lookup_type   IN              VARCHAR2,
      p_lookup_code   IN              VARCHAR2,
      x_meaning       OUT NOCOPY      VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_flag   VARCHAR2 (1);
   --l_lookup_meaning VARCHAR2(80);
   BEGIN
      OPEN cur_lookup_meaning (p_lookup_type, p_lookup_code);

      FETCH cur_lookup_meaning
       INTO l_flag, x_meaning;

      CLOSE cur_lookup_meaning;

      RETURN NVL (l_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidlookup;

   FUNCTION isvalidsection (p_template_id IN NUMBER, p_scn_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR cur_validate_section
      IS
         SELECT 'Y'
           FROM okc_sections_b
          WHERE document_type = 'TEMPLATE'
            AND document_id = p_template_id
            AND ID = p_scn_id;

      l_flag   VARCHAR2 (1);
   BEGIN
      OPEN cur_validate_section;

      FETCH cur_validate_section
       INTO l_flag;

      CLOSE cur_validate_section;

      RETURN NVL (l_flag, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END isvalidsection;

   FUNCTION isvalidclause (
      p_article_id   IN   NUMBER,
      p_org_id       IN   NUMBER,
      p_intent       IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_art_flag         VARCHAR2 (1);
      l_adopt_art_flag   VARCHAR2 (1);

      CURSOR cur_val_article
      IS
         SELECT 'Y'
           FROM okc_articles_all
          WHERE 1 = 1
            AND standard_yn = 'Y'
            AND org_id = p_org_id
            AND article_intent = p_intent
            AND article_id = p_article_id;

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
            AND adp.local_org_id = p_org_id;
   BEGIN
      OPEN cur_val_article;

      FETCH cur_val_article
       INTO l_art_flag;

      CLOSE cur_val_article;

      IF NVL (l_art_flag, 'N') = 'Y'
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
   END isvalidclause;

   FUNCTION validate_bus_doc_type (p_bus_doc_type IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_valid_bus_doc_type   VARCHAR2 (1);
      l_bus_doc_type         VARCHAR2 (120) := p_bus_doc_type;
      l_tmpl_intent          VARCHAR2 (120) := g_template_intent;
   BEGIN
      SELECT 'Y'
        INTO l_valid_bus_doc_type
        FROM okc_bus_doc_types_b bus, fnd_lookups fnd
       WHERE bus.document_type <> 'TEMPLATE'
         AND DECODE (bus.document_type_class,
                     'REPOSITORY', NVL (bus.enable_contract_terms_yn, 'N'),
                     NVL (bus.show_in_lov_yn, 'Y')
                    ) = 'Y'
         AND bus.intent = fnd.lookup_code
         AND fnd.lookup_type = 'OKC_TERMS_INTENT'
         AND bus.intent = l_tmpl_intent
         AND bus.document_type = l_bus_doc_type;

      RETURN NVL (l_valid_bus_doc_type, 'N');
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'N';
   END validate_bus_doc_type;

   FUNCTION validate_tmpl_usage_id (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type,
      p_mode             IN              VARCHAR2 DEFAULT 'UPDATE'
   )
      RETURN VARCHAR2
   IS
      l_valid_tmpl_usage_id     VARCHAR2 (1)                      := 'Y';
      l_document_type           VARCHAR2 (30);
      l_object_version_number   NUMBER;
      l_db_rec                  okc_allowed_tmpl_usages%ROWTYPE;
   BEGIN
      SELECT *
        INTO l_db_rec
        FROM okc_allowed_tmpl_usages
       WHERE template_id = p_template_id
         AND allowed_tmpl_usages_id = p_tmpl_usage_rec.allowed_tmpl_usages_id;

      IF (p_tmpl_usage_rec.object_version_number = okc_api.g_miss_num)
      THEN
         p_tmpl_usage_rec.object_version_number :=
                                               l_db_rec.object_version_number;
      END IF;

      IF p_mode = 'UPDATE'
      THEN
         IF (p_tmpl_usage_rec.document_type = okc_api.g_miss_char)
         THEN
            p_tmpl_usage_rec.document_type := l_db_rec.document_type;
         END IF;

         IF p_tmpl_usage_rec.default_yn = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.default_yn := l_db_rec.default_yn;
         END IF;

         IF p_tmpl_usage_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute_category :=
                                                  l_db_rec.attribute_category;
         END IF;

         IF p_tmpl_usage_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute1 := l_db_rec.attribute1;
         END IF;

         IF p_tmpl_usage_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute2 := l_db_rec.attribute2;
         END IF;

         IF p_tmpl_usage_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute3 := l_db_rec.attribute3;
         END IF;

         IF p_tmpl_usage_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute4 := l_db_rec.attribute4;
         END IF;

         IF p_tmpl_usage_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute5 := l_db_rec.attribute5;
         END IF;

         IF p_tmpl_usage_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute6 := l_db_rec.attribute6;
         END IF;

         IF p_tmpl_usage_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute7 := l_db_rec.attribute7;
         END IF;

         IF p_tmpl_usage_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute8 := l_db_rec.attribute8;
         END IF;

         IF p_tmpl_usage_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute9 := l_db_rec.attribute9;
         END IF;

         IF p_tmpl_usage_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute10 := l_db_rec.attribute10;
         END IF;

         IF p_tmpl_usage_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute11 := l_db_rec.attribute11;
         END IF;

         IF p_tmpl_usage_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute12 := l_db_rec.attribute12;
         END IF;

         IF p_tmpl_usage_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute13 := l_db_rec.attribute13;
         END IF;

         IF p_tmpl_usage_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute14 := l_db_rec.attribute14;
         END IF;

         IF p_tmpl_usage_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute15 := l_db_rec.attribute15;
         END IF;
      END IF;

      RETURN NVL (l_valid_tmpl_usage_id, 'N');
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN 'N';
      WHEN OTHERS
      THEN
         RETURN 'N';
   END validate_tmpl_usage_id;

--------------------------------------------------------------
   PROCEDURE validate_template (
      p_template_rec   IN OUT NOCOPY   terms_template_rec_type
   )
   IS
      CURSOR cur_val_ou (p_org_id IN NUMBER)
      IS
         SELECT 'X'
           FROM hr_operating_units ou, hr_organization_information oi
          WHERE mo_global.check_access (ou.organization_id) = 'Y'
            AND oi.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS'
            AND oi.organization_id = ou.organization_id
            AND NVL (date_to, SYSDATE) >= SYSDATE
            AND ou.organization_id = p_org_id;

      l_val_lookup   VARCHAR2 (1);
      l_proc         VARCHAR2 (60) := 'VALIDATE_TEMPLATE';
   BEGIN
      -- Validate the required fields
      IF p_template_rec.template_name IS NULL
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_NOT_NULL',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'TEMPLATE_NAME'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_template_rec.intent IS NULL
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_NOT_NULL',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'INTENT'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      IF     p_template_rec.contract_expert_enabled = 'Y'
         AND p_template_rec.xprt_scn_code IS NULL
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_NOT_NULL',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'XPRT_SCN_CODE'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      IF     p_template_rec.contract_expert_enabled IS NULL
         AND p_template_rec.xprt_scn_code IS NOT NULL
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_NOT_NULL',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'CONTRACT_EXPERT_ENABLED'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate the input attributes
      IF p_template_rec.intent NOT IN ('B', 'S')
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_INVALID_VALUE',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'INTENT'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- validate section code
      IF p_template_rec.xprt_scn_code IS NOT NULL
      THEN
         OPEN cur_val_lookup ('OKC_ARTICLE_SECTION',
                              p_template_rec.xprt_scn_code
                             );

         FETCH cur_val_lookup
          INTO l_val_lookup;

         CLOSE cur_val_lookup;

         IF NVL (l_val_lookup, 'X') <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'XPRT_SCN_CODE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         l_val_lookup := NULL;
      END IF;

      -- Validate OU, OU must be in the current

      -- Global flag can be applicable only for global org
      IF p_template_rec.global_flag = 'Y'
      THEN
         IF p_template_rec.org_id <> fnd_profile.VALUE ('OKC_GLOBAL_ORG_ID')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'GLOBAL_ORG_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   -- Validate numbering scheme
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END validate_template;

-------------------------------------------------------------
   PROCEDURE create_template (
      p_template_rec   IN OUT NOCOPY   terms_template_rec_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      x_return_status    VARCHAR2 (1);
      x_msg_count        NUMBER;
      x_msg_data         VARCHAR2 (2000);
      l_operating_unit   NUMBER;
      l_validate_flag    VARCHAR2 (1)    := 'Y';

      PROCEDURE default_template (
         p_template_rec   IN OUT NOCOPY   terms_template_rec_type
      )
      IS
      BEGIN
         IF p_template_rec.template_id = okc_api.g_miss_num
         THEN
            p_template_rec.template_id := NULL;
         END IF;

         IF p_template_rec.template_name = okc_api.g_miss_char
         THEN
            p_template_rec.template_name := NULL;
         END IF;

         IF p_template_rec.intent = okc_api.g_miss_char
         THEN
            p_template_rec.intent := NULL;
         END IF;

         -- IF p_template_rec.status_code = okc_api.g_miss_char
         -- THEN
         p_template_rec.status_code := 'DRAFT';

         -- END IF;
         IF p_template_rec.start_date = okc_api.g_miss_date
         THEN
            p_template_rec.start_date := SYSDATE;
         END IF;

         IF p_template_rec.end_date = okc_api.g_miss_date
         THEN
            p_template_rec.end_date := NULL;
         END IF;

         IF p_template_rec.global_flag = okc_api.g_miss_char
         THEN
            p_template_rec.global_flag := 'N';
         END IF;

         IF p_template_rec.instruction_text = okc_api.g_miss_char
         THEN
            p_template_rec.instruction_text := NULL;
         END IF;

         IF p_template_rec.description = okc_api.g_miss_char
         THEN
            p_template_rec.description := NULL;
         END IF;

         IF p_template_rec.working_copy_flag = okc_api.g_miss_char
         THEN
            p_template_rec.working_copy_flag := 'N';
         END IF;

         IF p_template_rec.parent_template_id = okc_api.g_miss_num
         THEN
            p_template_rec.parent_template_id := NULL;
         END IF;

         IF p_template_rec.contract_expert_enabled = okc_api.g_miss_char
         THEN
            p_template_rec.contract_expert_enabled := 'N';
         END IF;

         IF p_template_rec.template_model_id = okc_api.g_miss_num
         THEN
            p_template_rec.template_model_id := NULL;
         END IF;

         IF p_template_rec.tmpl_numbering_scheme = okc_api.g_miss_num
         THEN
            p_template_rec.tmpl_numbering_scheme := NULL;
         END IF;

         IF p_template_rec.print_template_id = okc_api.g_miss_num
         THEN
            p_template_rec.print_template_id := NULL;
         END IF;

         IF p_template_rec.approval_wf_key = okc_api.g_miss_char
         THEN
            p_template_rec.approval_wf_key := NULL;
         END IF;

         IF p_template_rec.cz_export_wf_key = okc_api.g_miss_char
         THEN
            p_template_rec.cz_export_wf_key := NULL;
         END IF;

         IF p_template_rec.org_id = okc_api.g_miss_num
         THEN
            p_template_rec.org_id := mo_utils.get_default_org_id;
         END IF;

         IF p_template_rec.orig_system_reference_code = okc_api.g_miss_char
         THEN
            p_template_rec.orig_system_reference_code := NULL;
         END IF;

         IF p_template_rec.orig_system_reference_id1 = okc_api.g_miss_num
         THEN
            p_template_rec.orig_system_reference_id1 := NULL;
         END IF;

         IF p_template_rec.orig_system_reference_id2 = okc_api.g_miss_num
         THEN
            p_template_rec.orig_system_reference_id2 := NULL;
         END IF;

         IF p_template_rec.object_version_number = okc_api.g_miss_num
         THEN
            p_template_rec.object_version_number := 1;
         END IF;

         IF p_template_rec.hide_yn = okc_api.g_miss_char
         THEN
            p_template_rec.hide_yn := NULL;
         END IF;

         IF p_template_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_template_rec.attribute_category := NULL;
         END IF;

         IF p_template_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute1 := NULL;
         END IF;

         IF p_template_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute2 := NULL;
         END IF;

         IF p_template_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute3 := NULL;
         END IF;

         IF p_template_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute4 := NULL;
         END IF;

         IF p_template_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute5 := NULL;
         END IF;

         IF p_template_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute6 := NULL;
         END IF;

         IF p_template_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute7 := NULL;
         END IF;

         IF p_template_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute8 := NULL;
         END IF;

         IF p_template_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute9 := NULL;
         END IF;

         IF p_template_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute10 := NULL;
         END IF;

         IF p_template_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute11 := NULL;
         END IF;

         IF p_template_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute12 := NULL;
         END IF;

         IF p_template_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute13 := NULL;
         END IF;

         IF p_template_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute14 := NULL;
         END IF;

         IF p_template_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute15 := NULL;
         END IF;

         IF p_template_rec.xprt_request_id = okc_api.g_miss_num
         THEN
            p_template_rec.xprt_request_id := NULL;
         END IF;

         IF p_template_rec.xprt_clause_mandatory_flag = okc_api.g_miss_char
         THEN
            p_template_rec.xprt_clause_mandatory_flag := 'N';
         END IF;

         IF p_template_rec.xprt_scn_code = okc_api.g_miss_char
         THEN
            p_template_rec.xprt_scn_code := NULL;
         END IF;

         IF p_template_rec.LANGUAGE = okc_api.g_miss_char
         THEN
            p_template_rec.LANGUAGE := NULL;
         END IF;

         IF p_template_rec.translated_from_tmpl_id = okc_api.g_miss_num
         THEN
            p_template_rec.translated_from_tmpl_id := NULL;
         END IF;
      END default_template;
   BEGIN
      -- Default Row
      default_template (p_template_rec => p_template_rec);
      fnd_msg_pub.initialize;

      -- Set the policy context
      IF p_template_rec.org_id IS NOT NULL
      THEN
         IF isvalidou (p_org_id => p_template_rec.org_id) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'ORG_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Set Policy context
         mo_global.set_policy_context ('S', TO_CHAR (p_template_rec.org_id));
      ELSE
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_NOT_NULL',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'ORG_ID'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate Row
      BEGIN
         validate_template (p_template_rec => p_template_rec);
      EXCEPTION
         WHEN fnd_api.g_exc_error
         THEN
            p_template_rec.status := g_ret_sts_error;
            RAISE;
         WHEN OTHERS
         THEN
            p_template_rec.status := g_ret_sts_error;
            RAISE;
      END;

      -- Call OKC_TERMS_TEMPLATES_GRP Insert
         /*
           OKC_TERMS_TEMPLATES_ALL_S => Sequnce value will derived in the grp package
           WHO columns,Object version numberr also derived in the package.
         */
      BEGIN
         okc_terms_templates_grp.create_template
            (p_api_version                     => 1,
             p_init_msg_list                   => fnd_api.g_true,
             p_validation_level                => fnd_api.g_valid_level_full,
             p_commit                          => fnd_api.g_false,
             x_return_status                   => x_return_status,
             x_msg_count                       => x_msg_count,
             x_msg_data                        => x_msg_data,
             p_template_name                   => p_template_rec.template_name,
             p_template_id                     => p_template_rec.template_id,
             p_working_copy_flag               => p_template_rec.working_copy_flag,
             p_intent                          => p_template_rec.intent,
             p_status_code                     => p_template_rec.status_code,
             p_start_date                      => p_template_rec.start_date,
             p_end_date                        => p_template_rec.end_date,
             p_global_flag                     => p_template_rec.global_flag,
             p_parent_template_id              => p_template_rec.parent_template_id,
             p_print_template_id               => p_template_rec.print_template_id,
             p_contract_expert_enabled         => p_template_rec.contract_expert_enabled,
             p_xprt_clause_mandatory_flag      => p_template_rec.xprt_clause_mandatory_flag,
             p_xprt_scn_code                   => p_template_rec.xprt_scn_code,
             p_template_model_id               => p_template_rec.template_model_id,
             p_instruction_text                => p_template_rec.instruction_text,
             p_tmpl_numbering_scheme           => p_template_rec.tmpl_numbering_scheme,
             p_description                     => p_template_rec.description,
             p_approval_wf_key                 => p_template_rec.approval_wf_key,
             p_cz_export_wf_key                => p_template_rec.cz_export_wf_key,
             p_orig_system_reference_code      => p_template_rec.orig_system_reference_code,
             p_orig_system_reference_id1       => p_template_rec.orig_system_reference_id1,
             p_orig_system_reference_id2       => p_template_rec.orig_system_reference_id2,
             p_org_id                          => p_template_rec.org_id,
             p_attribute_category              => p_template_rec.attribute_category,
             p_attribute1                      => p_template_rec.attribute1,
             p_attribute2                      => p_template_rec.attribute2,
             p_attribute3                      => p_template_rec.attribute3,
             p_attribute4                      => p_template_rec.attribute4,
             p_attribute5                      => p_template_rec.attribute5,
             p_attribute6                      => p_template_rec.attribute6,
             p_attribute7                      => p_template_rec.attribute7,
             p_attribute8                      => p_template_rec.attribute8,
             p_attribute9                      => p_template_rec.attribute9,
             p_attribute10                     => p_template_rec.attribute10,
             p_attribute11                     => p_template_rec.attribute11,
             p_attribute12                     => p_template_rec.attribute12,
             p_attribute13                     => p_template_rec.attribute13,
             p_attribute14                     => p_template_rec.attribute14,
             p_attribute15                     => p_template_rec.attribute15,
             p_translated_from_tmpl_id         => p_template_rec.translated_from_tmpl_id,
             p_language                        => p_template_rec.LANGUAGE,
             x_template_id                     => p_template_rec.template_id
            );

         IF x_return_status <> g_ret_sts_success
         THEN
            p_template_rec.status := g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         ELSE
            p_template_rec.status := g_ret_sts_success;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END;
   -- All existing Contract Expert rules with the Apply to All Templates option
   -- selected are assigned to the template automatically.
   -- In display VO will take care the above case.
   EXCEPTION
      WHEN OTHERS
      THEN
         p_template_rec.status := g_ret_sts_error;
         RAISE;
   END create_template;

   PROCEDURE update_template (
      p_template_rec   IN OUT NOCOPY   terms_template_rec_type
   )
   IS
      l_template_db_rec   okc_terms_templates_all%ROWTYPE;
      l_progress          VARCHAR2 (3)                      := '000';
      x_return_status     VARCHAR2 (1);
      x_msg_count         NUMBER;
      x_msg_data          VARCHAR2 (2000);

      PROCEDURE default_row (
         p_template_rec      IN OUT NOCOPY   terms_template_rec_type,
         p_template_db_rec   IN              okc_terms_templates_all%ROWTYPE
      )
      IS
      BEGIN
         IF p_template_rec.template_id = okc_api.g_miss_num
         THEN
            p_template_rec.template_id := p_template_db_rec.template_id;
         END IF;

         IF p_template_rec.template_name = okc_api.g_miss_char
         THEN
            p_template_rec.template_name := p_template_db_rec.template_name;
         END IF;

         IF p_template_rec.intent = okc_api.g_miss_char
         THEN
            p_template_rec.intent := p_template_db_rec.intent;
         END IF;

         IF p_template_rec.status_code = okc_api.g_miss_char
         THEN
            p_template_rec.status_code := p_template_db_rec.status_code;
         END IF;

         IF p_template_rec.start_date = okc_api.g_miss_date
         THEN
            p_template_rec.start_date := p_template_db_rec.start_date;
         END IF;

         IF p_template_rec.end_date = okc_api.g_miss_date
         THEN
            p_template_rec.end_date := p_template_db_rec.end_date;
         END IF;

         IF p_template_rec.global_flag = okc_api.g_miss_char
         THEN
            p_template_rec.global_flag := p_template_db_rec.global_flag;
         END IF;

         IF p_template_rec.instruction_text = okc_api.g_miss_char
         THEN
            p_template_rec.instruction_text :=
                                           p_template_db_rec.instruction_text;
         END IF;

         IF p_template_rec.description = okc_api.g_miss_char
         THEN
            p_template_rec.description := p_template_db_rec.description;
         END IF;

         IF p_template_rec.working_copy_flag = okc_api.g_miss_char
         THEN
            p_template_rec.working_copy_flag :=
                                          p_template_db_rec.working_copy_flag;
         END IF;

         IF p_template_rec.parent_template_id = okc_api.g_miss_num
         THEN
            p_template_rec.parent_template_id :=
                                         p_template_db_rec.parent_template_id;
         END IF;

         IF p_template_rec.contract_expert_enabled = okc_api.g_miss_char
         THEN
            p_template_rec.contract_expert_enabled :=
                                    p_template_db_rec.contract_expert_enabled;
         END IF;

         IF p_template_rec.template_model_id = okc_api.g_miss_num
         THEN
            p_template_rec.template_model_id :=
                                          p_template_db_rec.template_model_id;
         END IF;

         IF p_template_rec.tmpl_numbering_scheme = okc_api.g_miss_num
         THEN
            p_template_rec.tmpl_numbering_scheme :=
                                      p_template_db_rec.tmpl_numbering_scheme;
         END IF;

         IF p_template_rec.print_template_id = okc_api.g_miss_num
         THEN
            p_template_rec.print_template_id :=
                                          p_template_db_rec.print_template_id;
         END IF;

         IF p_template_rec.approval_wf_key = okc_api.g_miss_char
         THEN
            p_template_rec.approval_wf_key :=
                                            p_template_db_rec.approval_wf_key;
         END IF;

         IF p_template_rec.cz_export_wf_key = okc_api.g_miss_char
         THEN
            p_template_rec.cz_export_wf_key :=
                                           p_template_db_rec.cz_export_wf_key;
         END IF;

         IF p_template_rec.last_update_login = okc_api.g_miss_num
         THEN
            p_template_rec.last_update_login :=
                                          p_template_db_rec.last_update_login;
         END IF;

         IF p_template_rec.creation_date = okc_api.g_miss_date
         THEN
            p_template_rec.creation_date := p_template_db_rec.creation_date;
         END IF;

         IF p_template_rec.created_by = okc_api.g_miss_num
         THEN
            p_template_rec.created_by := p_template_db_rec.created_by;
         END IF;

         IF p_template_rec.last_updated_by = okc_api.g_miss_num
         THEN
            p_template_rec.last_updated_by :=
                                            p_template_db_rec.last_updated_by;
         END IF;

         IF p_template_rec.last_update_date = okc_api.g_miss_date
         THEN
            p_template_rec.last_update_date :=
                                           p_template_db_rec.last_update_date;
         END IF;

         IF p_template_rec.org_id = okc_api.g_miss_num
         THEN
            p_template_rec.org_id := p_template_db_rec.org_id;
         END IF;

         IF p_template_rec.orig_system_reference_code = okc_api.g_miss_char
         THEN
            p_template_rec.orig_system_reference_code :=
                                 p_template_db_rec.orig_system_reference_code;
         END IF;

         IF p_template_rec.orig_system_reference_id1 = okc_api.g_miss_num
         THEN
            p_template_rec.orig_system_reference_id1 :=
                                  p_template_db_rec.orig_system_reference_id1;
         END IF;

         IF p_template_rec.orig_system_reference_id2 = okc_api.g_miss_num
         THEN
            p_template_rec.orig_system_reference_id2 :=
                                  p_template_db_rec.orig_system_reference_id2;
         END IF;

         IF p_template_rec.object_version_number = okc_api.g_miss_num
         THEN
            p_template_rec.object_version_number :=
                                      p_template_db_rec.object_version_number;
         END IF;

         IF p_template_rec.hide_yn = okc_api.g_miss_char
         THEN
            p_template_rec.hide_yn := p_template_db_rec.hide_yn;
         END IF;

         IF p_template_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_template_rec.attribute_category :=
                                         p_template_db_rec.attribute_category;
         END IF;

         IF p_template_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute1 := p_template_db_rec.attribute1;
         END IF;

         IF p_template_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute2 := p_template_db_rec.attribute2;
         END IF;

         IF p_template_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute3 := p_template_db_rec.attribute3;
         END IF;

         IF p_template_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute4 := p_template_db_rec.attribute4;
         END IF;

         IF p_template_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute5 := p_template_db_rec.attribute5;
         END IF;

         IF p_template_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute6 := p_template_db_rec.attribute6;
         END IF;

         IF p_template_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute7 := p_template_db_rec.attribute7;
         END IF;

         IF p_template_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute8 := p_template_db_rec.attribute8;
         END IF;

         IF p_template_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute9 := p_template_db_rec.attribute9;
         END IF;

         IF p_template_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute10 := p_template_db_rec.attribute10;
         END IF;

         IF p_template_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute11 := p_template_db_rec.attribute11;
         END IF;

         IF p_template_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute12 := p_template_db_rec.attribute12;
         END IF;

         IF p_template_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute13 := p_template_db_rec.attribute13;
         END IF;

         IF p_template_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute14 := p_template_db_rec.attribute14;
         END IF;

         IF p_template_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_template_rec.attribute15 := p_template_db_rec.attribute15;
         END IF;

         IF p_template_rec.xprt_request_id = okc_api.g_miss_num
         THEN
            p_template_rec.xprt_request_id :=
                                            p_template_db_rec.xprt_request_id;
         END IF;

         IF p_template_rec.xprt_clause_mandatory_flag = okc_api.g_miss_char
         THEN
            p_template_rec.xprt_clause_mandatory_flag :=
                                 p_template_db_rec.xprt_clause_mandatory_flag;
         END IF;

         IF p_template_rec.xprt_scn_code = okc_api.g_miss_char
         THEN
            p_template_rec.xprt_scn_code := p_template_db_rec.xprt_scn_code;
         END IF;

         IF p_template_rec.LANGUAGE = okc_api.g_miss_char
         THEN
            p_template_rec.LANGUAGE := p_template_db_rec.LANGUAGE;
         END IF;

         IF p_template_rec.translated_from_tmpl_id = okc_api.g_miss_num
         THEN
            p_template_rec.translated_from_tmpl_id :=
                                    p_template_db_rec.translated_from_tmpl_id;
         END IF;
      END default_row;
   BEGIN
      -- Detect what values are changed and throw exception if the update is not allowed

      -- Get the values from the db
      -- Compare it with the record

      --
      BEGIN
         l_progress := '010';

         SELECT *
           INTO l_template_db_rec
           FROM okc_terms_templates_all
          WHERE template_id = p_template_rec.template_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
      END;

      --
      IF inittemplateinfo (p_template_rec.template_id) <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_INVALID_VALUE',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'TEMPLATE_ID'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      --
      IF g_headerinfo_update_allowed = 'N'
      THEN
         l_progress := '020';
         -- Can't update anything just return the error.
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD',
                              p_token1            => 'STATUS',
                              p_token1_value      => l_template_db_rec.status_code
                             );
         RAISE fnd_api.g_exc_error;
      ELSE
         -- Org Id Can't be changed
         IF     p_template_rec.org_id <> okc_api.g_miss_num
            AND NVL (p_template_rec.org_id, -1) <> l_template_db_rec.org_id
         THEN
            --  You can not change ORG_ID
            okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_template_db_rec.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'ORG_ID'
                            );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Intent Can't be changed
         IF     p_template_rec.intent <> okc_api.g_miss_char
            AND NVL (p_template_rec.intent, 'ABC') <> l_template_db_rec.intent
         THEN
            --  You can not change Intent
            okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_template_db_rec.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'INTENT'
                            );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Status Can't be changed
         IF     p_template_rec.status_code <> okc_api.g_miss_char
            AND NVL (p_template_rec.status_code, 'ABC') <>
                                                 l_template_db_rec.status_code
         THEN
            --  You can not change Status
            okc_api.set_message (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_I _TEMP_STS_CHANGE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF l_template_db_rec.status_code = 'APPROVED'
         THEN
            -- Name Can't be changed
            IF     p_template_rec.template_name <> okc_api.g_miss_char
               AND NVL (p_template_rec.template_name, 'ABC') <>
                                               l_template_db_rec.template_name
            THEN
               --  You can not change TEmplate NAme
               okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_template_db_rec.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'TEMPLATE_NAME'
                            );
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Start Date Can't be changed
            IF     p_template_rec.start_date <> okc_api.g_miss_date
               AND NVL (p_template_rec.start_date, okc_api.g_miss_date) <>
                                                  l_template_db_rec.start_date
            THEN
               --  You can not change Start Date
               okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_template_db_rec.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'START_DATE'
                            );
               RAISE fnd_api.g_exc_error;
            END IF;

            -- Contract Expert enabled can't be changed
            IF     p_template_rec.contract_expert_enabled <>
                                                           okc_api.g_miss_char
               AND NVL (p_template_rec.contract_expert_enabled, 'ABC') <>
                                     l_template_db_rec.contract_expert_enabled
            THEN
               --  You can not change Contract Expert Enabled
               okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_template_db_rec.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'CONTRACT_EXPERT_ENABLED'
                            );
               RAISE fnd_api.g_exc_error;
            END IF;

            --
            IF     p_template_rec.xprt_scn_code <> okc_api.g_miss_char
               AND NVL (p_template_rec.xprt_scn_code, 'ABC') <>
                                               l_template_db_rec.xprt_scn_code
            THEN
               --  You can not change xprt_scn_code
               okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_template_db_rec.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'XPRT_SCN_CODE'
                            );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF     p_template_rec.xprt_clause_mandatory_flag <>
                                                           okc_api.g_miss_char
               AND NVL (p_template_rec.xprt_clause_mandatory_flag, 'ABC') <>
                                  l_template_db_rec.xprt_clause_mandatory_flag
            THEN
               --  You can not change xprt_scn_code
               okc_api.set_message
                            (p_app_name          => g_app_name,
                             p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD_FIELD',
                             p_token1            => 'STATUS',
                             p_token1_value      => l_template_db_rec.status_code,
                             p_token2            => 'FIELD',
                             p_token2_value      => 'XPRT_CLAUSE_MANDATORY_FLAG'
                            );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;              -- l_template_db_rec.status_code    = 'APPROVED'
      END IF;                             -- g_headerinfo_update_allowed = 'N'

      l_progress := '100';
      -- set the policy context
      mo_global.set_policy_context ('S', TO_CHAR (l_template_db_rec.org_id));
      l_progress := '110';
      -- Default values for coulmns from table for which the values are not provided by user
      default_row (p_template_rec         => p_template_rec,
                   p_template_db_rec      => l_template_db_rec
                  );
      l_progress := '120';

      -- Validate Row
      BEGIN
         validate_template (p_template_rec => p_template_rec);
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END;

      -- update_row
      BEGIN
         okc_terms_templates_grp.update_template
            (p_api_version                     => 1,
             p_init_msg_list                   => fnd_api.g_true,
             p_validation_level                => fnd_api.g_valid_level_full,
             p_commit                          => fnd_api.g_false,
             x_return_status                   => x_return_status,
             x_msg_count                       => x_msg_count,
             x_msg_data                        => x_msg_data,
             p_template_name                   => p_template_rec.template_name,
             p_template_id                     => p_template_rec.template_id,
             p_working_copy_flag               => p_template_rec.working_copy_flag,
             p_intent                          => p_template_rec.intent,
             p_status_code                     => p_template_rec.status_code,
             p_start_date                      => p_template_rec.start_date,
             p_end_date                        => p_template_rec.end_date,
             p_global_flag                     => p_template_rec.global_flag,
             p_parent_template_id              => p_template_rec.parent_template_id,
             p_print_template_id               => p_template_rec.print_template_id,
             p_contract_expert_enabled         => p_template_rec.contract_expert_enabled,
             p_xprt_clause_mandatory_flag      => p_template_rec.xprt_clause_mandatory_flag,
             p_xprt_scn_code                   => p_template_rec.xprt_scn_code,
             p_template_model_id               => p_template_rec.template_model_id,
             p_instruction_text                => p_template_rec.instruction_text,
             p_tmpl_numbering_scheme           => p_template_rec.tmpl_numbering_scheme,
             p_description                     => p_template_rec.description,
             p_approval_wf_key                 => p_template_rec.approval_wf_key,
             p_cz_export_wf_key                => p_template_rec.cz_export_wf_key,
             p_orig_system_reference_code      => p_template_rec.orig_system_reference_code,
             p_orig_system_reference_id1       => p_template_rec.orig_system_reference_id1,
             p_orig_system_reference_id2       => p_template_rec.orig_system_reference_id2,
             p_org_id                          => p_template_rec.org_id,
             p_attribute_category              => p_template_rec.attribute_category,
             p_attribute1                      => p_template_rec.attribute1,
             p_attribute2                      => p_template_rec.attribute2,
             p_attribute3                      => p_template_rec.attribute3,
             p_attribute4                      => p_template_rec.attribute4,
             p_attribute5                      => p_template_rec.attribute5,
             p_attribute6                      => p_template_rec.attribute6,
             p_attribute7                      => p_template_rec.attribute7,
             p_attribute8                      => p_template_rec.attribute8,
             p_attribute9                      => p_template_rec.attribute9,
             p_attribute10                     => p_template_rec.attribute10,
             p_attribute11                     => p_template_rec.attribute11,
             p_attribute12                     => p_template_rec.attribute12,
             p_attribute13                     => p_template_rec.attribute13,
             p_attribute14                     => p_template_rec.attribute14,
             p_attribute15                     => p_template_rec.attribute15,
             p_translated_from_tmpl_id         => p_template_rec.translated_from_tmpl_id,
             p_language                        => p_template_rec.LANGUAGE,
             p_object_version_number           => p_template_rec.object_version_number
            );

         IF x_return_status <> g_ret_sts_success
         THEN
            p_template_rec.status := g_ret_sts_error;
            RAISE fnd_api.g_exc_error;
         ELSE
            p_template_rec.status := g_ret_sts_success;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END update_template;

   PROCEDURE create_template (
      p_template_tbl   IN OUT NOCOPY   terms_template_tbl_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_success_count    NUMBER          := 0;
      l_error_count      NUMBER          := 0;
      l_input_count      NUMBER          := p_template_tbl.COUNT;
      l_error_message    VARCHAR2 (2500);
      l_proc             VARCHAR2 (60)   := 'CREATE_TEMPLATE';
      l_failed_rec_num   NUMBER          := 0;
   BEGIN
      IF p_template_tbl.COUNT > 0
      THEN
         FOR i IN p_template_tbl.FIRST .. p_template_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            BEGIN
               SAVEPOINT create_template_sp;
               create_template (p_template_rec => p_template_tbl (i));

               IF p_template_tbl (i).status = g_ret_sts_success
               THEN
                  l_success_count := l_success_count + 1;

                  IF fnd_api.to_boolean (p_commit)
                  THEN
                     COMMIT;
                  END IF;
               ELSE
                  l_error_count := l_error_count + 1;
                  ROLLBACK TO create_template_sp;
               END IF;
            EXCEPTION
               WHEN fnd_api.g_exc_error
               THEN
                  p_template_tbl (i).status := g_ret_sts_error;
                  set_proc_error_message (p_proc => l_proc);
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  read_message (l_error_message);
                  p_template_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO create_template_sp;
                  fnd_msg_pub.initialize;
               WHEN OTHERS
               THEN
                  p_template_tbl (i).status := g_ret_sts_error;
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
                  p_template_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO create_template_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO create_template_sp;
         RAISE;
   END create_template;

   PROCEDURE update_template (
      p_template_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.terms_template_tbl_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_success_count    NUMBER          := 0;
      l_error_count      NUMBER          := 0;
      l_input_count      NUMBER          := p_template_tbl.COUNT;
      l_error_message    VARCHAR2 (2500);
      l_proc             VARCHAR2 (60)   := 'UPDATE_TEMPLATE';
      l_failed_rec_num   NUMBER          := 0;
   BEGIN
      IF p_template_tbl.COUNT > 0
      THEN
         FOR i IN p_template_tbl.FIRST .. p_template_tbl.LAST
         LOOP
            l_failed_rec_num := i;

            BEGIN
               SAVEPOINT update_template_sp;
               update_template (p_template_rec => p_template_tbl (i));

               IF p_template_tbl (i).status = g_ret_sts_success
               THEN
                  l_success_count := l_success_count + 1;

                  IF fnd_api.to_boolean (p_commit)
                  THEN
                     COMMIT;
                  END IF;
               ELSE
                  l_error_count := l_error_count + 1;
                  ROLLBACK TO update_template_sp;
               END IF;
            EXCEPTION
               WHEN fnd_api.g_exc_error
               THEN
                  p_template_tbl (i).status := g_ret_sts_error;
                  set_proc_error_message (p_proc => l_proc);
                  set_rec_num_message (p_rec_num => l_failed_rec_num);
                  read_message (l_error_message);
                  p_template_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO update_template_sp;
                  fnd_msg_pub.initialize;
               WHEN OTHERS
               THEN
                  p_template_tbl (i).status := g_ret_sts_error;
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
                  p_template_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO update_template_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK TO update_template_sp;
         RAISE;
   END update_template;

   PROCEDURE create_section (
      p_section_rec   IN OUT NOCOPY   section_rec_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      x_return_status   VARCHAR2 (1);
      x_msg_count       NUMBER;
      x_msg_data        VARCHAR2 (2000);
      l_error_message   VARCHAR2 (2500);
      l_proc            VARCHAR2 (60)   := 'CREATE_SECTION';

      PROCEDURE default_row (p_section_rec IN OUT NOCOPY section_rec_type)
      IS
      BEGIN
         IF p_section_rec.ID = okc_api.g_miss_num
         THEN
            /* SELECT okc_sections_b_s.NEXTVAL
               INTO p_section_rec.ID
               FROM DUAL;    */
            p_section_rec.ID := NULL;
         END IF;

         -- Indicates if the section refers to a contract header or a standard clause set.
         IF p_section_rec.scn_type = okc_api.g_miss_char
         THEN
            p_section_rec.scn_type := NULL;
         END IF;

         -- Contract header id for this section. If -99, then the section refers to a standard clause set.
         IF p_section_rec.chr_id = okc_api.g_miss_num
         THEN
            p_section_rec.chr_id := NULL;
         END IF;

         -- Standard Clause Set code, for formatting standard clause sets.
         -- If -99, then this section refers to a contract.
         IF p_section_rec.sat_code = okc_api.g_miss_char
         THEN
            p_section_rec.sat_code := NULL;
         END IF;

         -- Sequence number for the section
         IF p_section_rec.section_sequence = okc_api.g_miss_num
         THEN
            p_section_rec.section_sequence := NULL;
         END IF;

         --    Sequential number set at 1 on insert and incremented on update.
         --   Used by APIs to ensure current record is passed.
         IF p_section_rec.object_version_number = okc_api.g_miss_num
         THEN
            p_section_rec.object_version_number := 1;
         END IF;

         IF p_section_rec.created_by = okc_api.g_miss_num
         THEN
            p_section_rec.created_by := fnd_global.user_id;
         END IF;

         IF p_section_rec.creation_date = okc_api.g_miss_date
         THEN
            p_section_rec.creation_date := SYSDATE;
         END IF;

         IF p_section_rec.last_updated_by = okc_api.g_miss_num
         THEN
            p_section_rec.last_updated_by := fnd_global.user_id;
         END IF;

         IF p_section_rec.last_update_date = okc_api.g_miss_date
         THEN
            p_section_rec.last_update_date := SYSDATE;
         END IF;

         IF p_section_rec.last_update_login = okc_api.g_miss_num
         THEN
            p_section_rec.last_update_login := fnd_global.login_id;
         END IF;

         -- The label to be printed for the section, such as III. or 3.
         IF p_section_rec.label = okc_api.g_miss_char
         THEN
            p_section_rec.label := NULL;
         END IF;

         -- Indicates parent section for this subsection
         IF p_section_rec.scn_id = okc_api.g_miss_num
         THEN
            p_section_rec.scn_id := NULL;
         END IF;

         IF p_section_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_section_rec.attribute_category := NULL;
         END IF;

         IF p_section_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute1 := NULL;
         END IF;

         IF p_section_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute2 := NULL;
         END IF;

         IF p_section_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute3 := NULL;
         END IF;

         IF p_section_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute4 := NULL;
         END IF;

         IF p_section_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute5 := NULL;
         END IF;

         IF p_section_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute6 := NULL;
         END IF;

         IF p_section_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute7 := NULL;
         END IF;

         IF p_section_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute8 := NULL;
         END IF;

         IF p_section_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute9 := NULL;
         END IF;

         IF p_section_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute10 := NULL;
         END IF;

         IF p_section_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute11 := NULL;
         END IF;

         IF p_section_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute12 := NULL;
         END IF;

         IF p_section_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute13 := NULL;
         END IF;

         IF p_section_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute14 := NULL;
         END IF;

         IF p_section_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_section_rec.attribute15 := NULL;
         END IF;

         IF p_section_rec.security_group_id = okc_api.g_miss_num
         THEN
            p_section_rec.security_group_id := NULL;
         END IF;

         IF p_section_rec.old_id = okc_api.g_miss_num
         THEN
            p_section_rec.old_id := NULL;
         END IF;

         -- Business document type. Refers to document_type in okc_bus_doc_types_b
         IF p_section_rec.document_type = okc_api.g_miss_char
         THEN
            p_section_rec.document_type := 'TEMPLATE';
         END IF;

         --    Business document identifier. Refers to ID in various business document header tables
         IF p_section_rec.document_id = okc_api.g_miss_num
         THEN
            p_section_rec.document_id := NULL;
         END IF;

         --   section identifier
         IF p_section_rec.scn_code = okc_api.g_miss_char
         THEN
            p_section_rec.scn_code := NULL;
         END IF;

         -- Text to capture Section description
         IF p_section_rec.description = okc_api.g_miss_char
         THEN
            p_section_rec.description := NULL;
         END IF;

         IF p_section_rec.amendment_description = okc_api.g_miss_char
         THEN
            p_section_rec.amendment_description := NULL;
         END IF;

         IF p_section_rec.amendment_operation_code = okc_api.g_miss_char
         THEN
            p_section_rec.amendment_operation_code := NULL;
         END IF;

         IF p_section_rec.orig_system_reference_code = okc_api.g_miss_char
         THEN
            p_section_rec.orig_system_reference_code := NULL;
         END IF;

         IF p_section_rec.orig_system_reference_id1 = okc_api.g_miss_num
         THEN
            p_section_rec.orig_system_reference_id1 := NULL;
         END IF;

         IF p_section_rec.orig_system_reference_id2 = okc_api.g_miss_num
         THEN
            p_section_rec.orig_system_reference_id2 := NULL;
         END IF;

         -- Indicator for printing section when the document is printed. Valid values are Y and N.
         IF p_section_rec.print_yn = okc_api.g_miss_char
         THEN
            p_section_rec.print_yn := 'Y';
         END IF;

         IF p_section_rec.summary_amend_operation_code = okc_api.g_miss_char
         THEN
            p_section_rec.summary_amend_operation_code := NULL;
         END IF;

         -- Section title. This column is migrated from okc_sections_tl table
         IF p_section_rec.heading = okc_api.g_miss_char
         THEN
            p_section_rec.heading := NULL;
         END IF;

         IF p_section_rec.last_amended_by = okc_api.g_miss_num
         THEN
            p_section_rec.last_amended_by := NULL;
         END IF;

         IF p_section_rec.last_amendment_date = okc_api.g_miss_date
         THEN
            p_section_rec.last_amendment_date := NULL;
         END IF;
      END default_row;

      PROCEDURE validate_row (p_section_rec IN OUT NOCOPY section_rec_type)
      IS
         l_val_lookup    VARCHAR2 (1);
         l_exists_flag   VARCHAR2 (1);
         l_proc          VARCHAR2 (60) := 'VALIDATE_SECTION';
      BEGIN
         -- not null
         IF p_section_rec.section_sequence IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'SECTION_SEQUENCE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_section_rec.document_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                -- since the flow is for only templates
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_section_rec.scn_code IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'SCN_CODE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Validate Docuemnt Type
         IF p_section_rec.document_type <> 'TEMPLATE'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         /*IF inittemplateinfo (p_template_id => p_section_rec.document_id) <>
                                                                           'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;  */

         -- Validate SCN ID for sub-sections
         IF p_section_rec.scn_id IS NOT NULL
         THEN
            IF isvalidsection (p_template_id      => p_section_rec.document_id,
                               p_scn_id           => p_section_rec.scn_id
                              ) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_VALUE',
                                    p_token1            => 'FIELD',
                                    p_token1_value      => 'SCN_ID'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         -- Validate SCN_CODE
         IF isvalidlookup (p_lookup_type      => 'OKC_ARTICLE_SECTION',
                           p_lookup_code      => p_section_rec.scn_code,
                           x_meaning          => p_section_rec.description
                          ) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'SCN_CODE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      -- Add validation for sequence
      EXCEPTION
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END validate_row;
   BEGIN
      SAVEPOINT create_section_sp;
      fnd_msg_pub.initialize;

      -- PRE - VALIDATION
      IF p_section_rec.document_id <> NVL (g_template_id, -1)
      THEN
         IF inittemplateinfo (p_template_id => p_section_rec.document_id) <>
                                                                          'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF g_clause_update_allowed <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_INS_OBJ',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code,
                              p_token2            => 'OBJECT',
                              p_token2_value      => 'SECTION'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Default Row
      default_row (p_section_rec => p_section_rec);

      -- Set Org Context

      -- Validate Row
      BEGIN
         fnd_msg_pub.initialize;
         validate_row (p_section_rec => p_section_rec);
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK TO create_section_sp;
            RAISE;
      END;

      fnd_msg_pub.initialize;
      -- Call to Insert Row
      okc_terms_sections_grp.create_section
         (p_api_version                     => 1,
          p_init_msg_list                   => fnd_api.g_true,
          p_validation_level                => fnd_api.g_valid_level_full,
          p_commit                          => fnd_api.g_false,
          x_return_status                   => x_return_status,
          x_msg_count                       => x_msg_count,
          x_msg_data                        => x_msg_data,
          p_mode                            => 'NORMAL', --'AMEND' or 'NORMAL'
          p_id                              => p_section_rec.ID,
          p_section_sequence                => p_section_rec.section_sequence,
          p_label                           => p_section_rec.label,
          p_scn_id                          => p_section_rec.scn_id,
          p_heading                         => p_section_rec.description,
          -- Mimicking the front end functionality
          p_description                     => p_section_rec.description,
          p_document_type                   => p_section_rec.document_type,
          p_document_id                     => p_section_rec.document_id,
          p_scn_code                        => p_section_rec.scn_code,
          p_amendment_description           => p_section_rec.amendment_description,
          p_orig_system_reference_code      => p_section_rec.orig_system_reference_code,
          p_orig_system_reference_id1       => p_section_rec.orig_system_reference_id1,
          p_orig_system_reference_id2       => p_section_rec.orig_system_reference_id2,
          p_print_yn                        => p_section_rec.print_yn,
          p_attribute_category              => p_section_rec.attribute_category,
          p_attribute1                      => p_section_rec.attribute1,
          p_attribute2                      => p_section_rec.attribute2,
          p_attribute3                      => p_section_rec.attribute3,
          p_attribute4                      => p_section_rec.attribute4,
          p_attribute5                      => p_section_rec.attribute5,
          p_attribute6                      => p_section_rec.attribute6,
          p_attribute7                      => p_section_rec.attribute7,
          p_attribute8                      => p_section_rec.attribute8,
          p_attribute9                      => p_section_rec.attribute9,
          p_attribute10                     => p_section_rec.attribute10,
          p_attribute11                     => p_section_rec.attribute11,
          p_attribute12                     => p_section_rec.attribute12,
          p_attribute13                     => p_section_rec.attribute13,
          p_attribute14                     => p_section_rec.attribute14,
          p_attribute15                     => p_section_rec.attribute15,
          x_id                              => p_section_rec.ID
         );

      IF x_return_status = g_ret_sts_success
      THEN
         p_section_rec.status := x_return_status;
      ELSE
         p_section_rec.status := g_ret_sts_error;
         ROLLBACK TO create_section_sp;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         p_section_rec.status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         read_message (l_error_message);
         p_section_rec.errmsg := l_error_message;
         ROLLBACK TO create_section_sp;
         fnd_msg_pub.initialize;
      WHEN OTHERS
      THEN
         p_section_rec.status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         read_message (l_error_message);
         p_section_rec.errmsg := l_error_message;
         ROLLBACK TO create_section_sp;
         fnd_msg_pub.initialize;
   END create_section;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
   PROCEDURE create_article (
      p_article_rec   IN OUT NOCOPY   k_article_rec_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      x_return_status   VARCHAR2 (1);
      x_msg_count       NUMBER;
      x_msg_data        VARCHAR2 (2000);
      l_error_message   VARCHAR2 (2500);
      l_proc            VARCHAR2 (60)   := 'CREATE_ARTICLE';

-------------SUB PROC-----------------------------------------------
      PROCEDURE default_row (p_article_rec IN OUT NOCOPY k_article_rec_type)
      IS
      BEGIN
         /*
         IF p_article_rec.ID = okc_api.g_miss_num
         THEN
            SELECT
              INTO p_article_rec.ID
              FROM DUAL;
         END IF; */
         IF p_article_rec.sav_sae_id = okc_api.g_miss_num
         THEN
            p_article_rec.sav_sae_id := NULL;
         END IF;

         IF p_article_rec.sav_sav_release = okc_api.g_miss_char
         THEN
            p_article_rec.sav_sav_release := NULL;
         END IF;

         IF p_article_rec.sbt_code = okc_api.g_miss_char
         THEN
            p_article_rec.sbt_code := NULL;
         END IF;

         IF p_article_rec.cat_type = okc_api.g_miss_char
         THEN
            p_article_rec.cat_type := NULL;
         END IF;

         IF p_article_rec.chr_id = okc_api.g_miss_num
         THEN
            p_article_rec.chr_id := NULL;
         END IF;

         IF p_article_rec.cle_id = okc_api.g_miss_num
         THEN
            p_article_rec.cle_id := NULL;
         END IF;

         IF p_article_rec.cat_id = okc_api.g_miss_num
         THEN
            p_article_rec.cat_id := NULL;
         END IF;

         IF p_article_rec.dnz_chr_id = okc_api.g_miss_num
         THEN
            p_article_rec.dnz_chr_id := NULL;
         END IF;

         IF p_article_rec.object_version_number = okc_api.g_miss_num
         THEN
            p_article_rec.object_version_number := 1;
         END IF;

         IF p_article_rec.created_by = okc_api.g_miss_num
         THEN
            p_article_rec.created_by := fnd_global.user_id;
         END IF;

         IF p_article_rec.creation_date = okc_api.g_miss_date
         THEN
            p_article_rec.creation_date := SYSDATE;
         END IF;

         IF p_article_rec.last_updated_by = okc_api.g_miss_num
         THEN
            p_article_rec.last_updated_by := fnd_global.user_id;
         END IF;

         IF p_article_rec.last_update_date = okc_api.g_miss_date
         THEN
            p_article_rec.last_update_date := SYSDATE;
         END IF;

         IF p_article_rec.fulltext_yn = okc_api.g_miss_char
         THEN
            p_article_rec.fulltext_yn := NULL;
         END IF;

         IF p_article_rec.last_update_login = okc_api.g_miss_num
         THEN
            p_article_rec.last_update_login := fnd_global.login_id;
         END IF;

         IF p_article_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_article_rec.attribute_category := NULL;
         END IF;

         IF p_article_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute1 := NULL;
         END IF;

         IF p_article_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute2 := NULL;
         END IF;

         IF p_article_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute3 := NULL;
         END IF;

         IF p_article_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute4 := NULL;
         END IF;

         IF p_article_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute5 := NULL;
         END IF;

         IF p_article_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute6 := NULL;
         END IF;

         IF p_article_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute7 := NULL;
         END IF;

         IF p_article_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute8 := NULL;
         END IF;

         IF p_article_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute9 := NULL;
         END IF;

         IF p_article_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute10 := NULL;
         END IF;

         IF p_article_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute11 := NULL;
         END IF;

         IF p_article_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute12 := NULL;
         END IF;

         IF p_article_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute13 := NULL;
         END IF;

         IF p_article_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute14 := NULL;
         END IF;

         IF p_article_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_article_rec.attribute15 := NULL;
         END IF;

         IF p_article_rec.security_group_id = okc_api.g_miss_num
         THEN
            p_article_rec.security_group_id := NULL;
         END IF;

         IF p_article_rec.old_id = okc_api.g_miss_num
         THEN
            p_article_rec.old_id := NULL;
         END IF;

         IF    p_article_rec.document_type = okc_api.g_miss_char
            OR p_article_rec.document_type IS NULL
         THEN
            p_article_rec.document_type := 'TEMPLATE';
         END IF;

         IF p_article_rec.document_id = okc_api.g_miss_num
         THEN
            p_article_rec.document_id := NULL;
         END IF;

         IF p_article_rec.source_flag = okc_api.g_miss_char
         THEN
            p_article_rec.source_flag := NULL;
         END IF;

         IF p_article_rec.mandatory_yn = okc_api.g_miss_char
         THEN
            p_article_rec.mandatory_yn := 'N';
         END IF;

         -- Rwa changes start
         IF p_article_rec.mandatory_rwa = okc_api.g_miss_char
         THEN
            p_article_rec.mandatory_rwa := NULL;
         END IF;

         -- Rwa changes end
         IF p_article_rec.scn_id = okc_api.g_miss_num
         THEN
            p_article_rec.scn_id := NULL;
         END IF;

         IF p_article_rec.label = okc_api.g_miss_char
         THEN
            p_article_rec.label := NULL;
         END IF;

         IF p_article_rec.display_sequence = okc_api.g_miss_num
         THEN
            p_article_rec.display_sequence := NULL;
         END IF;

         IF p_article_rec.amendment_description = okc_api.g_miss_char
         THEN
            p_article_rec.amendment_description := NULL;
         END IF;

         IF p_article_rec.article_version_id = okc_api.g_miss_num
         THEN
            p_article_rec.article_version_id := NULL;
         END IF;

         IF p_article_rec.orig_system_reference_code = okc_api.g_miss_char
         THEN
            p_article_rec.orig_system_reference_code := NULL;
         END IF;

         IF p_article_rec.orig_system_reference_id1 = okc_api.g_miss_num
         THEN
            p_article_rec.orig_system_reference_id1 := NULL;
         END IF;

         IF p_article_rec.orig_system_reference_id2 = okc_api.g_miss_num
         THEN
            p_article_rec.orig_system_reference_id2 := NULL;
         END IF;

         IF p_article_rec.amendment_operation_code = okc_api.g_miss_char
         THEN
            p_article_rec.amendment_operation_code := NULL;
         END IF;

         IF p_article_rec.summary_amend_operation_code = okc_api.g_miss_char
         THEN
            p_article_rec.summary_amend_operation_code := NULL;
         END IF;

         IF p_article_rec.change_nonstd_yn = okc_api.g_miss_char
         THEN
            p_article_rec.change_nonstd_yn := 'N';
         END IF;

         IF p_article_rec.print_text_yn = okc_api.g_miss_char
         THEN
            p_article_rec.print_text_yn := 'N';
         END IF;

         IF p_article_rec.ref_article_id = okc_api.g_miss_num
         THEN
            p_article_rec.ref_article_id := NULL;
         END IF;

         IF p_article_rec.ref_article_version_id = okc_api.g_miss_num
         THEN
            p_article_rec.ref_article_version_id := NULL;
         END IF;

         IF p_article_rec.orig_article_id = okc_api.g_miss_num
         THEN
            p_article_rec.orig_article_id := p_article_rec.sav_sae_id;
         END IF;

         IF p_article_rec.last_amended_by = okc_api.g_miss_num
         THEN
            p_article_rec.last_amended_by := NULL;
         END IF;

         IF p_article_rec.last_amendment_date = okc_api.g_miss_date
         THEN
            p_article_rec.last_amendment_date := TO_DATE (NULL);
         END IF;
      END default_row;

      ------------- SUB PROC END -----------------------------------------------
      PROCEDURE validate_row (p_article_rec IN OUT NOCOPY k_article_rec_type)
      IS
         l_proc   VARCHAR2 (60) := 'VALIDATE_ARTICLE';
      BEGIN
         -- Validate required fields can't be null
         IF p_article_rec.sav_sae_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'SAV_SAE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_article_rec.document_type IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'DOCUMENT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_article_rec.document_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'DOCUMENT_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_article_rec.scn_id IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'SCN_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_article_rec.display_sequence IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'DISPLAY_SEQUENCE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Validate the input values
         /*
         IF inittemplateinfo (p_template_id => p_article_rec.document_id) <>
                                                                           'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;   */
         IF isvalidou (p_org_id => g_template_org_id) <> 'Y'
         THEN
            -- Can'not access template from this resp
            okc_api.set_message
               (p_app_name      => g_app_name,
                p_msg_name      => 'Can not access Template. Please change the responsibility'
               );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Set the policy context

         -- Validate the  sav_sae_id
         IF (isvalidclause (p_article_id      => p_article_rec.sav_sae_id,
                            p_org_id          => g_template_org_id,
                            p_intent          => g_template_intent
                           )
            ) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'SAV_SAE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Validate

         -- Validate Display sequence
            -- As of now skip this validation

         -- Validate SCN_ID Section ID
         IF isvalidsection (p_template_id      => p_article_rec.document_id,
                            p_scn_id           => p_article_rec.scn_id
                           ) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'SCN_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         /* RWA Changes Start */
         IF     p_article_rec.mandatory_yn IS NOT NULL
            AND p_article_rec.mandatory_yn NOT IN ('Y', 'N')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'MANDATORY_YN'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     p_article_rec.mandatory_rwa IS NOT NULL
            AND isvalidlookup ('OKC_CLAUSE_RWA', p_article_rec.mandatory_rwa) =
                                                                           'N'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'MANDATORY_RWA'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      /* RWA Changes End */
      EXCEPTION
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END validate_row;
   ------------- SUB PROC END -----------------------------------------------
   BEGIN
      SAVEPOINT create_article_sp;
      fnd_msg_pub.initialize;

      IF p_article_rec.document_id <> NVL (g_template_id, -1)
      THEN
         IF inittemplateinfo (p_template_id => p_article_rec.document_id) <>
                                                                          'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF g_clause_update_allowed <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_INS_OBJ',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code,
                              p_token2            => 'OBJECT',
                              p_token2_value      => 'ARTICLE'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- default_row
      default_row (p_article_rec => p_article_rec);

      -- Validate Row
      BEGIN
         fnd_msg_pub.initialize;
         validate_row (p_article_rec => p_article_rec);
      EXCEPTION
         WHEN OTHERS
         THEN
            ROLLBACK TO create_article_sp;
            RAISE;
      END;

      -- Call Insert Statement.
      INSERT INTO okc_k_articles_b
                  (ID, sav_sae_id,
                   sav_sav_release, sbt_code,
                   cat_type, chr_id,
                   cle_id, cat_id,
                   dnz_chr_id,
                   object_version_number,
                   created_by, creation_date,
                   last_updated_by,
                   last_update_date, fulltext_yn,
                   last_update_login,
                   attribute_category,
                   attribute1, attribute2,
                   attribute3, attribute4,
                   attribute5, attribute6,
                   attribute7, attribute8,
                   attribute9, attribute10,
                   attribute11, attribute12,
                   attribute13, attribute14,
                   attribute15,
                   security_group_id, old_id,
                   document_type, document_id,
                   source_flag, mandatory_yn,
                   scn_id, label,
                   display_sequence,
                   amendment_description,
                   article_version_id,
                   orig_system_reference_code,
                   orig_system_reference_id1,
                   orig_system_reference_id2,
                   amendment_operation_code,
                   summary_amend_operation_code,
                   change_nonstd_yn,
                   print_text_yn, ref_article_id,
                   ref_article_version_id,
                   orig_article_id,
                   last_amended_by,
                   last_amendment_date,
                   mandatory_rwa
                  )
           VALUES (okc_k_articles_b_s.NEXTVAL, p_article_rec.sav_sae_id,
                   p_article_rec.sav_sav_release, p_article_rec.sbt_code,
                   p_article_rec.cat_type, p_article_rec.chr_id,
                   p_article_rec.cle_id, p_article_rec.cat_id,
                   p_article_rec.dnz_chr_id,
                   p_article_rec.object_version_number,
                   p_article_rec.created_by, p_article_rec.creation_date,
                   p_article_rec.last_updated_by,
                   p_article_rec.last_update_date, p_article_rec.fulltext_yn,
                   p_article_rec.last_update_login,
                   p_article_rec.attribute_category,
                   p_article_rec.attribute1, p_article_rec.attribute2,
                   p_article_rec.attribute3, p_article_rec.attribute4,
                   p_article_rec.attribute5, p_article_rec.attribute6,
                   p_article_rec.attribute7, p_article_rec.attribute8,
                   p_article_rec.attribute9, p_article_rec.attribute10,
                   p_article_rec.attribute11, p_article_rec.attribute12,
                   p_article_rec.attribute13, p_article_rec.attribute14,
                   p_article_rec.attribute15,
                   p_article_rec.security_group_id, p_article_rec.old_id,
                   p_article_rec.document_type, p_article_rec.document_id,
                   p_article_rec.source_flag, p_article_rec.mandatory_yn,
                   p_article_rec.scn_id, p_article_rec.label,
                   p_article_rec.display_sequence,
                   p_article_rec.amendment_description,
                   p_article_rec.article_version_id,
                   p_article_rec.orig_system_reference_code,
                   p_article_rec.orig_system_reference_id1,
                   p_article_rec.orig_system_reference_id2,
                   p_article_rec.amendment_operation_code,
                   p_article_rec.summary_amend_operation_code,
                   p_article_rec.change_nonstd_yn,
                   p_article_rec.print_text_yn, p_article_rec.ref_article_id,
                   p_article_rec.ref_article_version_id,
                   p_article_rec.orig_article_id,
                   p_article_rec.last_amended_by,
                   p_article_rec.last_amendment_date,
                   p_article_rec.mandatory_rwa
                  )
        RETURNING ID
             INTO p_article_rec.ID;

      p_article_rec.status := g_ret_sts_success;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         p_article_rec.status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         read_message (l_error_message);
         p_article_rec.errmsg := l_error_message;
         ROLLBACK TO create_article_sp;
         fnd_msg_pub.initialize;
      WHEN OTHERS
      THEN
         p_article_rec.status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         read_message (l_error_message);
         p_article_rec.errmsg := l_error_message;
         ROLLBACK TO create_article_sp;
         fnd_msg_pub.initialize;
   END create_article;

   PROCEDURE create_section (
      p_section_tbl   IN OUT NOCOPY   section_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
      FOR i IN 1 .. p_section_tbl.COUNT
      LOOP
         create_section (p_section_rec => p_section_tbl (i));
      END LOOP;
   END create_section;

   PROCEDURE create_article (
      p_article_tbl   IN OUT NOCOPY   k_article_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
      FOR i IN 1 .. p_article_tbl.COUNT
      LOOP
         create_article (p_article_rec => p_article_tbl (i));
      END LOOP;
   END create_article;

   PROCEDURE create_template_revision (
      p_template_id         IN              NUMBER,
      p_copy_deliverables   IN              VARCHAR2 DEFAULT 'Y',
      p_commit              IN              VARCHAR2 := fnd_api.g_false,
      x_new_template_id     OUT NOCOPY      NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER
   )
   IS
      l_proc   VARCHAR2 (120) := 'CREATE_TEMPLATE_REVISION';
   BEGIN
      fnd_msg_pub.initialize;

      -- PRE-VALIDATION
      IF inittemplateinfo (p_template_id => p_template_id) <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_INVALID_VALUE',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'TEMPLATE_ID'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_template_status_code <> 'APPROVED'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_TERMS_REV_TMPL_INVALID',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Call 2 API
      okc_terms_copy_grp.create_template_revision
                                  (p_api_version            => 1,
                                   p_init_msg_list          => fnd_api.g_true,
                                   p_commit                 => p_commit,
                                   p_template_id            => p_template_id,
                                   p_copy_deliverables      => p_copy_deliverables,
                                   x_template_id            => x_new_template_id,
                                   x_return_status          => x_return_status,
                                   x_msg_data               => x_msg_data,
                                   x_msg_count              => x_msg_count
                                  );
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         read_message (x_msg_data);
         fnd_msg_pub.initialize;
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         read_message (x_msg_data);
         fnd_msg_pub.initialize;
   END create_template_revision;

   PROCEDURE delete_articles (
      p_template_id        IN              NUMBER,
      p_k_article_id_tbl   IN              k_article_id_tbl_type,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      x_k_article_id_tbl   OUT NOCOPY      k_article_id_tbl_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_proc   VARCHAR2 (60) := 'DELETE_ARTICLES';
   BEGIN
      fnd_msg_pub.initialize;

      IF p_template_id <> NVL (g_template_id, -1)
      THEN
         IF inittemplateinfo (p_template_id => p_template_id) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- Validate Template OU also:
      IF g_clause_update_allowed <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_DEL_OBJ',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code,
                              p_token2            => 'OBJECT',
                              p_token2_value      => 'ARTICLE'
                             );
         RAISE fnd_api.g_exc_error;
      ELSE
         FORALL i IN 1 .. p_k_article_id_tbl.COUNT
            DELETE FROM okc_k_articles_b
                  WHERE ID = p_k_article_id_tbl (i)
                    AND document_type = 'TEMPLATE'
                    AND document_id = p_template_id
              RETURNING       ID
            BULK COLLECT INTO x_k_article_id_tbl;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT;
      END IF;

      x_return_status := g_ret_sts_success;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         read_message (x_msg_data);

         IF fnd_api.to_boolean (p_commit)
         THEN
            COMMIT;
         END IF;

         fnd_msg_pub.initialize;
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         read_message (x_msg_data);

         IF fnd_api.to_boolean (p_commit)
         THEN
            COMMIT;
         END IF;

         fnd_msg_pub.initialize;
   END delete_articles;

   PROCEDURE delete_sections (
      p_template_id      IN              NUMBER,
      p_section_id_tbl   IN              section_id_tbl_type,
      p_commit           IN              VARCHAR2 := fnd_api.g_false,
      x_section_id_tbl   OUT NOCOPY      section_id_tbl_type,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_data         OUT NOCOPY      VARCHAR2
   )
   IS
      --l_k_article_id_tbl  k_article_id_tbl_type
      l_proc   VARCHAR2 (60) := 'DELETE_SECTIONS';
   BEGIN
      fnd_msg_pub.initialize;

      IF p_template_id <> NVL (g_template_id, -1)
      THEN
         IF inittemplateinfo (p_template_id => p_template_id) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF g_clause_update_allowed <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_DEL_OBJ',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code,
                              p_token2            => 'OBJECT',
                              p_token2_value      => 'SECTION'
                             );
         RAISE fnd_api.g_exc_error;
      ELSE
         FORALL i IN 1 .. p_section_id_tbl.COUNT
            DELETE FROM okc_sections_b
                  WHERE ID = p_section_id_tbl (i)
                    AND document_type = 'TEMPLATE'
                    AND document_id = p_template_id
              RETURNING       ID
            BULK COLLECT INTO x_section_id_tbl;
      END IF;

      -- Delete Articles associated with the section
      FORALL i IN 1 .. x_section_id_tbl.COUNT
         DELETE FROM okc_k_articles_b
               WHERE scn_id = x_section_id_tbl (i)
                 AND document_type = 'TEMPLATE'
                 AND document_id = p_template_id;
      x_return_status := g_ret_sts_success;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         read_message (x_msg_data);

         IF fnd_api.to_boolean (p_commit)
         THEN
            COMMIT;
         END IF;

         fnd_msg_pub.initialize;
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         read_message (x_msg_data);

         IF fnd_api.to_boolean (p_commit)
         THEN
            COMMIT;
         END IF;

         fnd_msg_pub.initialize;
   END delete_sections;

   /**
     * Copy the p_deliverable_rec.deliverable_id to p_deliverable_rec.original_deliverable_id
     *          p_deliverable_rec.display_sequence is  p_deliverable_rec.deliverable_id%1000 => remainder
     * Populate the internal ORg
     */
   PROCEDURE create_deliverable (
      p_deliverable_rec   IN OUT NOCOPY   deliverable_rec_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_start_date_fixed          VARCHAR2 (1);
      l_end_date_fixed            VARCHAR2 (1);
      l_start_evt_before_after    VARCHAR2 (1);
      l_end_evt_before_after      VARCHAR2 (1);
      l_repeating_frequency_uom   VARCHAR2 (30);
      l_relative_st_date_uom      VARCHAR2 (30);
      l_relative_end_date_uom     VARCHAR2 (30);
      l_proc                      VARCHAR2 (60)   := 'CREATE_DELIVERABLE';
      l_error_message             VARCHAR2 (2500);

      PROCEDURE default_row (
         p_deliverable_rec   IN OUT NOCOPY   deliverable_rec_type
      )
      IS
      BEGIN
         IF p_deliverable_rec.deliverable_id = okc_api.g_miss_num
         THEN
            SELECT okc_deliverable_id_s.NEXTVAL
              INTO p_deliverable_rec.deliverable_id
              FROM DUAL;
         END IF;

         IF p_deliverable_rec.business_document_type = okc_api.g_miss_char
         THEN
            p_deliverable_rec.business_document_type := 'TEMPLATE';
         END IF;

         IF p_deliverable_rec.business_document_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.business_document_id := NULL;
         END IF;

         IF p_deliverable_rec.business_document_number = okc_api.g_miss_char
         THEN
            p_deliverable_rec.business_document_number := NULL;
         END IF;

         IF p_deliverable_rec.deliverable_type = okc_api.g_miss_char
         THEN
            p_deliverable_rec.deliverable_type := NULL;
         END IF;

         IF p_deliverable_rec.responsible_party = okc_api.g_miss_char
         THEN
            p_deliverable_rec.responsible_party := NULL;
         END IF;

		 -- Pre-11iCU2 -- Bug 4228090
		 IF p_deliverable_rec.responsible_party = 'BUYER_ORG' THEN
              p_deliverable_rec.responsible_party  := 'INTERNAL_ORG';
         END IF;

         IF p_deliverable_rec.internal_party_contact_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.internal_party_contact_id := NULL;
         END IF;

         IF p_deliverable_rec.external_party_contact_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.external_party_contact_id := NULL;
         END IF;

         IF p_deliverable_rec.deliverable_name = okc_api.g_miss_char
         THEN
            p_deliverable_rec.deliverable_name := NULL;
         END IF;

         IF p_deliverable_rec.description = okc_api.g_miss_char
         THEN
            p_deliverable_rec.description := NULL;
         END IF;

         IF p_deliverable_rec.comments = okc_api.g_miss_char
         THEN
            p_deliverable_rec.comments := NULL;
         END IF;

         IF p_deliverable_rec.display_sequence = okc_api.g_miss_num
         THEN
            p_deliverable_rec.display_sequence :=
                     getdeldisplaysequence (p_deliverable_rec.deliverable_id);
         END IF;

         IF p_deliverable_rec.fixed_due_date_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.fixed_due_date_yn := 'Y';
         END IF;

         IF p_deliverable_rec.actual_due_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.actual_due_date := NULL;
         END IF;

         IF p_deliverable_rec.print_due_date_msg_name = okc_api.g_miss_char
         THEN
            p_deliverable_rec.print_due_date_msg_name := NULL;
         END IF;

         IF p_deliverable_rec.recurring_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.recurring_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_prior_due_date_value = okc_api.g_miss_num
         THEN
            p_deliverable_rec.notify_prior_due_date_value := NULL;
         END IF;

         IF p_deliverable_rec.notify_prior_due_date_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_prior_due_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.notify_prior_due_date_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_prior_due_date_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_completed_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_completed_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_overdue_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_overdue_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_escalation_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_escalation_yn := 'N';
         END IF;

         IF p_deliverable_rec.notify_escalation_value = okc_api.g_miss_num
         THEN
            p_deliverable_rec.notify_escalation_value := NULL;
         END IF;

         IF p_deliverable_rec.notify_escalation_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.notify_escalation_uom := NULL;
         END IF;

         IF p_deliverable_rec.escalation_assignee = okc_api.g_miss_num
         THEN
            p_deliverable_rec.escalation_assignee := NULL;
         END IF;

         IF p_deliverable_rec.amendment_operation = okc_api.g_miss_char
         THEN
            p_deliverable_rec.amendment_operation := NULL;
         END IF;

         IF p_deliverable_rec.prior_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.prior_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.amendment_notes = okc_api.g_miss_char
         THEN
            p_deliverable_rec.amendment_notes := NULL;
         END IF;

         IF p_deliverable_rec.completed_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.completed_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.overdue_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.overdue_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.escalation_notification_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.escalation_notification_id := NULL;
         END IF;

         IF p_deliverable_rec.LANGUAGE = okc_api.g_miss_char
         THEN
            p_deliverable_rec.LANGUAGE := USERENV ('Lang');
         END IF;

         IF p_deliverable_rec.original_deliverable_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.original_deliverable_id :=
                                             p_deliverable_rec.deliverable_id;
         END IF;

         IF p_deliverable_rec.requester_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.requester_id := NULL;
         END IF;

         IF p_deliverable_rec.external_party_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.external_party_id := NULL;
         END IF;

         IF p_deliverable_rec.recurring_del_parent_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.recurring_del_parent_id := NULL;
         END IF;

         --IF p_deliverable_rec.business_document_version = okc_api.g_miss_num
         --THEN
         p_deliverable_rec.business_document_version := -99;

         --END IF;
         IF p_deliverable_rec.relative_st_date_duration = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_st_date_duration := NULL;
         END IF;

         IF p_deliverable_rec.relative_st_date_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.relative_st_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.relative_st_date_event_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_st_date_event_id := NULL;
         END IF;

         IF p_deliverable_rec.relative_end_date_duration = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_end_date_duration := NULL;
         END IF;

         IF p_deliverable_rec.relative_end_date_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.relative_end_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.relative_end_date_event_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.relative_end_date_event_id := NULL;
         END IF;

         IF p_deliverable_rec.repeating_day_of_month = okc_api.g_miss_char
         THEN
            p_deliverable_rec.repeating_day_of_month := NULL;
         END IF;

         IF p_deliverable_rec.repeating_day_of_week = okc_api.g_miss_char
         THEN
            p_deliverable_rec.repeating_day_of_week := NULL;
         END IF;

         IF p_deliverable_rec.repeating_frequency_uom = okc_api.g_miss_char
         THEN
            p_deliverable_rec.repeating_frequency_uom := NULL;
         END IF;

         IF p_deliverable_rec.repeating_duration = okc_api.g_miss_num
         THEN
            p_deliverable_rec.repeating_duration := NULL;
         END IF;

         IF p_deliverable_rec.fixed_start_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.fixed_start_date := NULL;
         END IF;

         IF p_deliverable_rec.fixed_end_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.fixed_end_date := NULL;
         END IF;

         IF p_deliverable_rec.manage_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.manage_yn := 'N';
         END IF;

         IF p_deliverable_rec.internal_party_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.internal_party_id := NULL;
         END IF;

         --IF p_deliverable_rec.deliverable_status = okc_api.g_miss_char
         --THEN
         p_deliverable_rec.deliverable_status := 'INACTIVE';

         --END IF;
         IF p_deliverable_rec.status_change_notes = okc_api.g_miss_char
         THEN
            p_deliverable_rec.status_change_notes := NULL;
         END IF;

         IF p_deliverable_rec.created_by = okc_api.g_miss_num
         THEN
            p_deliverable_rec.created_by := fnd_global.user_id;
         END IF;

         IF p_deliverable_rec.creation_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.creation_date := SYSDATE;
         END IF;

         IF p_deliverable_rec.last_updated_by = okc_api.g_miss_num
         THEN
            p_deliverable_rec.last_updated_by := fnd_global.user_id;
         END IF;

         IF p_deliverable_rec.last_update_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.last_update_date := SYSDATE;
         END IF;

         IF p_deliverable_rec.last_update_login = okc_api.g_miss_num
         THEN
            p_deliverable_rec.last_update_login := fnd_global.login_id;
         END IF;

         IF p_deliverable_rec.object_version_number = okc_api.g_miss_num
         THEN
            p_deliverable_rec.object_version_number := 1;
         END IF;

         IF p_deliverable_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute_category := NULL;
         END IF;

         IF p_deliverable_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute1 := NULL;
         END IF;

         IF p_deliverable_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute2 := NULL;
         END IF;

         IF p_deliverable_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute3 := NULL;
         END IF;

         IF p_deliverable_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute4 := NULL;
         END IF;

         IF p_deliverable_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute5 := NULL;
         END IF;

         IF p_deliverable_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute6 := NULL;
         END IF;

         IF p_deliverable_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute7 := NULL;
         END IF;

         IF p_deliverable_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute8 := NULL;
         END IF;

         IF p_deliverable_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute9 := NULL;
         END IF;

         IF p_deliverable_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute10 := NULL;
         END IF;

         IF p_deliverable_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute11 := NULL;
         END IF;

         IF p_deliverable_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute12 := NULL;
         END IF;

         IF p_deliverable_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute13 := NULL;
         END IF;

         IF p_deliverable_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute14 := NULL;
         END IF;

         IF p_deliverable_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_deliverable_rec.attribute15 := NULL;
         END IF;

         IF p_deliverable_rec.disable_notifications_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.disable_notifications_yn := 'N';
         END IF;

         IF p_deliverable_rec.last_amendment_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.last_amendment_date := NULL;
         END IF;

         IF p_deliverable_rec.business_document_line_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.business_document_line_id := NULL;
         END IF;

         IF p_deliverable_rec.external_party_site_id = okc_api.g_miss_num
         THEN
            p_deliverable_rec.external_party_site_id := NULL;
         END IF;

         IF p_deliverable_rec.start_event_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.start_event_date := NULL;
         END IF;

         IF p_deliverable_rec.end_event_date = okc_api.g_miss_date
         THEN
            p_deliverable_rec.end_event_date := NULL;
         END IF;

         IF p_deliverable_rec.summary_amend_operation_code =
                                                           okc_api.g_miss_char
         THEN
            p_deliverable_rec.summary_amend_operation_code := NULL;
         END IF;

         IF p_deliverable_rec.external_party_role = okc_api.g_miss_char
         THEN
            p_deliverable_rec.external_party_role := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_prior_due_date_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.pay_hold_prior_due_date_yn := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_prior_due_date_value =
                                                            okc_api.g_miss_num
         THEN
            p_deliverable_rec.pay_hold_prior_due_date_value := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_prior_due_date_uom =
                                                           okc_api.g_miss_char
         THEN
            p_deliverable_rec.pay_hold_prior_due_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.pay_hold_overdue_yn = okc_api.g_miss_char
         THEN
            p_deliverable_rec.pay_hold_overdue_yn := NULL;
         END IF;
      END default_row;

      PROCEDURE validate_row (
         p_deliverable_rec   IN OUT NOCOPY   deliverable_rec_type
      )
      IS
         l_fixedstartdateyn   VARCHAR2 (30);
         l_starteventcode     VARCHAR2 (240);
         l_startba            VARCHAR2 (240);
         l_endeventcode       VARCHAR2 (240);
         l_endba              VARCHAR2 (240);
         l_continue           VARCHAR2 (1);
         l_startduration      NUMBER;
         l_endduration        NUMBER;
         l_uom                VARCHAR2 (120);
         l_proc               VARCHAR2 (60)  := 'VALIDATE_DELIVERABLE';
         l_column_name        VARCHAR2 (240);


	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);
      BEGIN
         -- Validate Header Info

         -- Business Document Type must be 'TEMPLATE'
         IF p_deliverable_rec.business_document_type <> 'TEMPLATE'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'BUSINESS_DOCUMENT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         --  Validate the Deliverable Type
         IF p_deliverable_rec.deliverable_type NOT IN
                           ('CONTRACTUAL', 'INTERNAL_PURCHASING', 'SOURCING')
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'DELIVERABLE_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         -- Validate the  responsible_party
         IF (   (    p_deliverable_rec.deliverable_type = 'CONTRACTUAL'
                 AND p_deliverable_rec.responsible_party NOT IN
                                                ('SUPPLIER_ORG', 'BUYER_ORG')
                )
             OR (    p_deliverable_rec.deliverable_type =
                                          'INTERNAL_PURCHASING'
                 AND p_deliverable_rec.responsible_party <> 'BUYER_ORG'
                )
              OR   (    p_deliverable_rec.deliverable_type =
                                          'SOURCING'
                 AND p_deliverable_rec.responsible_party <> 'SUPPLIER_ORG'
                   )
            )
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'RESPONSIBLE_PARTY'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     p_deliverable_rec.internal_party_contact_id IS NOT NULL
            AND isvalidcontact (p_deliverable_rec.internal_party_contact_id) <>
                                                                           'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'RESPONSIBLE_PARTY'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF     p_deliverable_rec.requester_id IS NOT NULL
            AND isvalidcontact (p_deliverable_rec.requester_id) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'REQUESTER_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;

         IF p_deliverable_rec.deliverable_name IS NULL
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_NOT_NULL',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'DELIVERABLE_NAME'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;



----------------------------------
         IF     p_deliverable_rec.recurring_yn = 'Y'
            AND p_deliverable_rec.repeating_frequency_uom = 'WK'
         THEN
            IF p_deliverable_rec.repeating_duration IS NULL
            THEN
               okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_NULL_REPEAT_WEEK_UI'
                                 );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_deliverable_rec.repeating_duration < 0
            THEN
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_NEG_REPEAT_WEEK_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );

               RAISE fnd_api.g_exc_error;
            END IF;

            IF isvalidlookup
                  (p_lookup_type      => 'DAY_OF_WEEK',
                   p_lookup_code      => TO_CHAR
                                            (p_deliverable_rec.repeating_day_of_week
                                            )
                  ) <> 'Y'
            THEN
               okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_INVALID_DAY_OF_WEEK'
                                 );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF     p_deliverable_rec.recurring_yn = 'Y'
            AND p_deliverable_rec.repeating_frequency_uom = 'MTH'
         THEN
            IF p_deliverable_rec.repeating_duration IS NULL
            THEN
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_NULL_REPEAT_MONTH_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );

               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_deliverable_rec.repeating_duration < 0
            THEN
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_NEG_REPEAT_MONTH_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF isvalidlookup
                  (p_lookup_type      => 'OKC_DAY_OF_MONTH',
                   p_lookup_code      => TO_CHAR
                                            (p_deliverable_rec.repeating_day_of_month
                                            )
                  ) <> 'Y'
            THEN
               okc_api.set_message
                                (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_DEL_INVALID_DAY_OF_MONTH'
                                );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

        --------------

         -- CASE : 1 One Time deliverable and Fixed Due date, then fixed_due_date _yn will be 'Y'.
         IF  p_deliverable_rec.fixed_due_date_yn = 'Y' THEN
             --  PRINT_DUE_DATE_MSG_NAME is null in this case
             p_deliverable_rec.PRINT_DUE_DATE_MSG_NAME := NULL;

              -- Fixed start date is required for this kind of deliverable.
              IF p_deliverable_rec.fixed_start_date IS NULL THEN
                  okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'FIXED_START_DATE'
                               );
                   RAISE fnd_api.g_exc_error;
             END IF;



             BEGIN

              SELECT column_name
              INTO l_column_name
              FROM (SELECT 'RECURRING_YN' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.recurring_yn = 'Y'
                    UNION
                    SELECT 'RELATIVE_ST_DATE_DURATION' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_st_date_duration IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_ST_DATE_UOM' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_st_date_uom IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_ST_DATE_EVENT_ID' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_st_date_event_id IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_END_DATE_DURATION' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_end_date_duration IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_END_DATE_UOM' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_end_date_uom IS NOT NULL
                    UNION
                    SELECT 'RELATIVE_END_DATE_EVENT_ID' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.relative_end_date_event_id IS NOT NULL
                    UNION
                    SELECT 'REPEATING_DAY_OF_MONTH' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_day_of_month IS NOT NULL
                    UNION
                    SELECT 'REPEATING_DAY_OF_WEEK' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_day_of_week IS NOT NULL
                    UNION
                    SELECT 'REPEATING_FREQUENCY_UOM' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_frequency_uom IS NOT NULL
                    UNION
                    SELECT 'REPEATING_DURATION' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.repeating_duration IS NOT NULL
                    UNION
                    SELECT 'FIXED_END_DATE' column_name
                      FROM DUAL
                    WHERE p_deliverable_rec.fixed_end_date IS NOT NULL)
          WHERE ROWNUM = 1;

                okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => l_column_name
                               );

                okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );



                RAISE fnd_api.g_exc_error;


             EXCEPTION
             WHEN No_Data_Found THEN
              NULL;
             END;
         END IF;

         -- CASE : 2 : One time deliverable but it is event based (Relative)
         -- In this case  fixed_due_date_yn and RECURRING_YN both will be 'N'.
         IF p_deliverable_rec.fixed_due_date_yn = 'N'
         AND p_deliverable_rec.RECURRING_YN  = 'N'
         THEN
            IF p_deliverable_rec.relative_st_date_event_id IS NULL
            THEN
               okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_EVENT_ID'
                               );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_deliverable_rec.relative_st_date_duration IS NULL
            THEN
               okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_DURATION'
                               );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF p_deliverable_rec.relative_st_date_uom IS NULL
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_NOT_NULL',
                                    p_token1            => 'FIELD',
                                    p_token1_value      => 'RELATIVE_ST_DATE_UOM'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;



               IF isvalidstartbusdocevent
                     (p_document_type         => p_deliverable_rec.business_document_type,
                      p_deliverable_type      => p_deliverable_rec.deliverable_type,
                      p_bus_doc_event_id      => p_deliverable_rec.relative_st_date_event_id
                     ) <> 'Y'
               THEN
                  okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_EVENT_ID'
                               );
                  RAISE fnd_api.g_exc_error;
               END IF;


           BEGIN
            SELECT column_name
            INTO l_column_name
  FROM (SELECT 'RELATIVE_END_DATE_DURATION' column_name
          FROM DUAL
         WHERE p_deliverable_rec.relative_end_date_duration IS NOT NULL
        UNION
        SELECT 'RELATIVE_END_DATE_UOM'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.relative_end_date_uom IS NOT NULL
        UNION
        SELECT 'RELATIVE_END_DATE_EVENT_ID' column_name
          FROM DUAL
         WHERE p_deliverable_rec.relative_end_date_event_id IS NOT NULL
        UNION
        SELECT 'REPEATING_DAY_OF_MONTH'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_day_of_month IS NOT NULL
        UNION
        SELECT 'REPEATING_DAY_OF_WEEK'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_day_of_week IS NOT NULL
        UNION
        SELECT 'REPEATING_FREQUENCY_UOM' column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_frequency_uom IS NOT NULL
        UNION
        SELECT 'REPEATING_DURATION'     column_name
          FROM DUAL
         WHERE p_deliverable_rec.repeating_duration IS NOT NULL
        UNION
        SELECT 'FIXED_END_DATE'   column_name
          FROM DUAL
         WHERE p_deliverable_rec.fixed_end_date IS NOT NULL
        UNION
        SELECT 'FIXED_START_DATE'  column_name
          FROM DUAL
         WHERE p_deliverable_rec.fixed_start_date IS NOT NULL)
       WHERE ROWNUM = 1;

                okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );

                okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => l_column_name
                               );

                RAISE fnd_api.g_exc_error;
         EXCEPTION
          WHEN No_Data_Found THEN
           NULL;
          END;
         END IF;  -- IF p_deliverable_rec.fixed_due_date_yn = 'N' AND p_deliverable_rec.RECURRING_YN  = 'N'


         -- CASE 3 : Repeating deliverable and non-event based deliverable.
                    -- Here the following four sub-cases can exist:
                        -- 3.a Both Start and end dates are fixed.
                        -- 3.b Start date is fixed but end date is event based/relative
                        -- 3.c Start date is event based(Relative) and end date is fixed.
                        -- 3.d Both Start date and end dates are event based(Relative).

         IF p_deliverable_rec.RECURRING_YN = 'Y'
         THEN
            -- In all 3.a..3.d cases Repeating information can not be null.
            BEGIN
            select column_name  INTO l_column_name from
                (
                select 'REPEATING_DURATION' column_name   from dual where p_deliverable_rec.REPEATING_DURATION is null
                union
                select 'REPEATING_FREQUENCY_UOM' column_name  from dual where p_deliverable_rec.REPEATING_FREQUENCY_UOM is null
                union
                select 'REPEATING_DAY_OF_WEEK' column_name  from dual where p_deliverable_rec.REPEATING_FREQUENCY_UOM  = 'WK' and  p_deliverable_rec.REPEATING_DAY_OF_WEEK is null
                union
                select 'REPEATING_DAY_OF_MONTH' column_name  from dual where p_deliverable_rec.REPEATING_FREQUENCY_UOM  = 'MTH' and  p_deliverable_rec.REPEATING_DAY_OF_MONTH is null
                )
              where rownum =1;

                     okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => l_column_name
                               );
                     okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );


                   RAISE fnd_api.g_exc_error;
            EXCEPTION
            WHEN No_Data_Found THEN NULL;
            END;


            -- If we check for following thnings then we will cover all of 3.a to 3.d cases
            -- Either Fixed Start date must exist or Start Event info must exist.
            -- Either Fixed end date must exist or End Event info must exist.
            IF  p_deliverable_rec.fixed_start_date IS NULL
            AND p_deliverable_rec.relative_st_date_event_id IS NULL
            THEN
                    okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );
                     okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'FIXED_START_DATE'
                               );
                   RAISE fnd_api.g_exc_error;
            END IF;

            IF  p_deliverable_rec.fixed_end_date IS NULL
            AND p_deliverable_rec.relative_end_date_event_id IS NULL
            THEN
                    okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                              );
                     okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'FIXED_END_DATE'
                               );
                   RAISE fnd_api.g_exc_error;
            END IF;

           -- When Fixed Start date is entered, then Relative St event information must not be entered.
           IF p_deliverable_rec.fixed_start_date IS NOT NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_ST_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_DURATION IS NOT NULL
                  union
                  select  'RELATIVE_ST_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_UOM is not null
                  union
                  select 'RELATIVE_ST_DATE_EVENT_ID'  column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_EVENT_ID is not null
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_INVALID_VALUE',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;
           END IF;

           -- When Relative st event is entered, then verify if the min info required for this is entered.
           IF p_deliverable_rec.RELATIVE_ST_DATE_EVENT_ID is not NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_ST_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_DURATION IS  NULL
                  union
                  select  'RELATIVE_ST_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_ST_DATE_UOM is NULL
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_NOT_NULL',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;

           END IF;

           -- When Fixed end date is entered, then Relative End event information must not be entered.
           IF p_deliverable_rec.fixed_end_date IS NOT NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_END_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_DURATION IS NOT NULL
                  union
                  select  'RELATIVE_END_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_UOM is not null
                  union
                  select 'RELATIVE_END_DATE_EVENT_ID'  column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_EVENT_ID is not null
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_INVALID_VALUE',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;
           END IF;

           -- When Relative End event is entered, then verify if the min info required for this is entered.
           IF p_deliverable_rec.RELATIVE_END_DATE_EVENT_ID is not NULL THEN
              begin
                  select column_name into l_column_name from
                  (
                  select 'RELATIVE_END_DATE_DURATION' column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_DURATION IS  NULL
                  union
                  select  'RELATIVE_END_DATE_UOM'   column_name from dual where p_deliverable_rec.RELATIVE_END_DATE_UOM is NULL
                  )
                  where rownum =1;



                  okc_api.set_message
                                                (p_app_name      => g_app_name,
                                                p_msg_name      => 'OKC_DEL_INCONSISTENT_DUE_DATES'
                                                );

                                  okc_api.set_message
                                                (p_app_name          => g_app_name,
                                                  p_msg_name          => 'OKC_I_NOT_NULL',
                                                  p_token1            => 'FIELD',
                                                  p_token1_value      => l_column_name
                                                );

                                  RAISE fnd_api.g_exc_error;
                  exception
                  when no_data_found then
                  null;
                end;

           END IF;

            IF ( p_deliverable_rec.relative_st_date_duration < 0
                 OR (InStr
                        (
                         To_Char(p_deliverable_rec.relative_st_date_duration)
                         ,'.'
                        )
                         <>0
                     )
               )
            THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_NEG_REL_ST_DUR_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );

               RAISE fnd_api.g_exc_error;
            END IF;


            IF p_deliverable_rec.relative_st_date_event_id IS NOT NULL
            THEN
               IF isvalidstartbusdocevent
                     (p_document_type         => p_deliverable_rec.business_document_type,
                      p_deliverable_type      => p_deliverable_rec.deliverable_type,
                      p_bus_doc_event_id      => p_deliverable_rec.relative_st_date_event_id
                     ) <> 'Y'
               THEN
                  okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_INVALID_VALUE',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'RELATIVE_ST_DATE_EVENT_ID'
                               );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

           IF p_deliverable_rec.relative_end_date_event_id IS NOT NULL
            THEN
               IF isvalidendbusdocevent
                     (p_document_type         => p_deliverable_rec.business_document_type,
                      p_deliverable_type      => p_deliverable_rec.deliverable_type,
                      p_bus_doc_event_id      => p_deliverable_rec.relative_end_date_event_id
                     ) <> 'Y'
               THEN
                  okc_api.set_message
                              (p_app_name          => g_app_name,
                               p_msg_name          => 'OKC_I_INVALID_VALUE',
                               p_token1            => 'FIELD',
                               p_token1_value      => 'RELATIVE_END_DATE_EVENT_ID'
                              );
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;

           IF p_deliverable_rec.relative_st_date_event_id IS NOT NULL AND
              p_deliverable_rec.relative_end_date_event_id IS NOT NULL
              AND  isvalidstendeventsmatch
                                (p_deliverable_rec.relative_st_date_event_id,
                                 p_deliverable_rec.relative_end_date_event_id
                                ) <> 'Y'
            THEN
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_INVLD_EVENT_DOCTYPE_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);
             /*  okc_api.set_message
                              (p_app_name      => g_app_name,
                               p_msg_name      => 'OKC_DEL_INVLD_EVENT_DOCTYPE_UI'
                              );*/
               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );

               RAISE fnd_api.g_exc_error;
            END IF;

           IF (p_deliverable_rec.fixed_start_date IS NOT NULL AND
            p_deliverable_rec.fixed_end_date IS NOT NULL AND
            (p_deliverable_rec.fixed_start_date >
                                                p_deliverable_rec.fixed_end_date))
            THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);

              /* okc_api.set_message
                             (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_INVALID_VALUE',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'OKC_DEL_END_BEFORE_START_UI'
                             );*/
               okc_api.set_message
                             (p_app_name          => g_app_name,
                              p_msg_name          => l_resolved_msg_name
                             );

               RAISE fnd_api.g_exc_error;
            END IF;

             IF ( p_deliverable_rec.repeating_duration < 0
                OR  (InStr(To_Char(p_deliverable_rec.repeating_duration),'.')<>0)
               )
            THEN
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_NEG_REPEAT_WEEK_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

               okc_api.set_message (p_app_name      => g_app_name,
                                    p_msg_name      => l_resolved_msg_name,
																    p_token1 => 'DEL_TOKEN',
                                    p_token1_value => l_resolved_token
                                   );


               RAISE fnd_api.g_exc_error;
             END IF;
          IF  p_deliverable_rec.repeating_frequency_uom = 'WK'
         THEN



            IF isvalidlookup
                  (p_lookup_type      => 'DAY_OF_WEEK',
                   p_lookup_code      => TO_CHAR
                                            (p_deliverable_rec.repeating_day_of_week
                                            )
                  ) <> 'Y'
            THEN
               okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_INVALID_DAY_OF_WEEK'
                                 );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         IF     p_deliverable_rec.recurring_yn = 'Y'
            AND p_deliverable_rec.repeating_frequency_uom = 'MTH'
         THEN
            IF isvalidlookup
                  (p_lookup_type      => 'OKC_DAY_OF_MONTH',
                   p_lookup_code      => TO_CHAR
                                            (p_deliverable_rec.repeating_day_of_month
                                            )
                  ) <> 'Y'
            THEN
               okc_api.set_message
                                (p_app_name      => g_app_name,
                                 p_msg_name      => 'OKC_DEL_INVALID_DAY_OF_MONTH'
                                );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

        ---------------

         /*
           //if deliverable is recurring and the start event and the end event are the same
          //we should do the following checks:
          //(1) If both the dates are before the event then
          //Validation: Start duration > End duration
          //(e.g. 10 days should be greater than 1 week)
          //
          //(2) If Start date is before the event and End date is after the event then
          //Validation: No problem
          //
          //(3) If Start date is after the event and End date is before the event then
          //Validation: Error Start date should be before the End date
          //
          //(4) If both the dates are after the event then
          //Validation: Start duration < End duration
         */
         IF     p_deliverable_rec.recurring_yn = 'Y'
            AND p_deliverable_rec.relative_st_date_event_id IS NOT NULL
            AND p_deliverable_rec.relative_end_date_event_id IS NOT NULL
            AND p_deliverable_rec.relative_st_date_duration IS NOT NULL
            AND p_deliverable_rec.relative_end_date_duration IS NOT NULL
            AND p_deliverable_rec.relative_st_date_uom IS NOT NULL
            AND p_deliverable_rec.relative_end_date_uom IS NOT NULL
         THEN
            BEGIN
               SELECT business_event_code, before_after, 'Y'
                 INTO l_starteventcode, l_startba, l_continue
                 FROM okc_bus_doc_events_b
                WHERE bus_doc_event_id =
                                   p_deliverable_rec.relative_st_date_event_id;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  l_continue := 'N';
            END;

            IF l_continue = 'Y'
            THEN
               BEGIN
                  SELECT business_event_code, before_after, 'Y'
                    INTO l_endeventcode, l_endba, l_continue
                    FROM okc_bus_doc_events_b
                   WHERE bus_doc_event_id =
                                  p_deliverable_rec.relative_end_date_event_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     l_continue := 'N';
               END;

               IF l_continue = 'Y'
               THEN
                  IF     l_starteventcode IS NOT NULL
                     AND l_starteventcode = l_endeventcode
                  THEN
                     /*
                      //if the getDays method cannot find a match, it will return -1
                     //so if startDuration or endDuration is less than 0, we know that we didn't find a match
                     //in this case we won't compare, because we can't
                     */
                     l_uom := p_deliverable_rec.relative_st_date_uom;
                     l_startduration :=
                          TO_NUMBER
                                 (p_deliverable_rec.relative_st_date_duration)
                        * (CASE l_uom
                              WHEN 'DAY'
                                 THEN 1
                              WHEN 'WK'
                                 THEN 7
                              WHEN 'MTH'
                                 THEN 30
                              ELSE -1
                           END
                          );
                     l_endduration :=
                          TO_NUMBER
                                 (p_deliverable_rec.relative_end_date_duration)
                        * (CASE p_deliverable_rec.relative_end_date_uom
                              WHEN 'DAY'
                                 THEN 1
                              WHEN 'WK'
                                 THEN 7
                              WHEN 'MTH'
                                 THEN 30
                              ELSE -1
                           END
                          );

                     IF l_startduration >= 0 AND l_endduration >= 0
                     THEN
                        -- Scenario 1
                        IF (    'B' = l_startba
                            AND 'B' = 'l_endBA'
                            AND (l_startduration < l_endduration)
                           )
                        THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

                  /*         okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_END_BEFORE_START_UI'
                                 );*/
                           okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => l_resolved_msg_name,
                                  p_token1        => 'DEL_TOKEN',
                                  p_token1_value  => l_resolved_token
                                 );
                           RAISE fnd_api.g_exc_error;
                        END IF;

                        -- Scenario 2 is always valid no need to check

                        -- Scenario 3
                        IF ('A' = l_startba AND 'B' = l_endba)
                        THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

                  /*         okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_END_BEFORE_START_UI'
                                 );*/
                           okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => l_resolved_msg_name,
                                  p_token1        => 'DEL_TOKEN',
                                  p_token1_value  => l_resolved_token
                                 );

                           RAISE fnd_api.g_exc_error;
                        END IF;

                        IF (    'A' = l_startba
                            AND 'A' = l_endba
                            AND l_startduration > l_endduration
                           )
                        THEN
				          -- Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_END_BEFORE_START_UI',p_deliverable_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_deliverable_rec.business_document_type);

                  /*         okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => 'OKC_DEL_END_BEFORE_START_UI'
                                 );*/
                           okc_api.set_message
                                 (p_app_name      => g_app_name,
                                  p_msg_name      => l_resolved_msg_name,
                                  p_token1        => 'DEL_TOKEN',
                                  p_token1_value  => l_resolved_token
                                 );

                           RAISE fnd_api.g_exc_error;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;
       END IF; --IF p_deliverable_rec.RECURRING_YN = 'Y'

        IF p_deliverable_rec.NOTIFY_ESCALATION_YN = 'Y'
        THEN
           IF p_deliverable_rec.NOTIFY_ESCALATION_VALUE IS NULL
           THEN
                  okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'NOTIFY_ESCALATION_VALUE'
                               );
                               RAISE fnd_api.g_exc_error;

           END IF;

           IF p_deliverable_rec.NOTIFY_ESCALATION_UOM IS NULL
           THEN
                okc_api.set_message
                               (p_app_name          => g_app_name,
                                p_msg_name          => 'OKC_I_NOT_NULL',
                                p_token1            => 'FIELD',
                                p_token1_value      => 'NOTIFY_ESCALATION_UOM'
                               );
                               RAISE fnd_api.g_exc_error;

           END IF;
        END IF;

         IF p_deliverable_rec.escalation_assignee IS NOT NULL
         THEN
            IF isvalidcontact (p_deliverable_rec.escalation_assignee) <> 'Y'
            THEN
               okc_api.set_message (p_app_name          => g_app_name,
                                    p_msg_name          => 'OKC_I_INVALID_VALUE',
                                    p_token1            => 'FIELD',
                                    p_token1_value      => 'ESCALATION_ASSIGNEE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

      EXCEPTION
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END validate_row;
   BEGIN
      SAVEPOINT create_deliverable_sp;
      fnd_msg_pub.initialize;

      IF p_deliverable_rec.business_document_id <> NVL (g_template_id, -1)
      THEN
         IF inittemplateinfo
                     (p_template_id      => p_deliverable_rec.business_document_id) <>
                                                                          'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF g_template_intent = 'S'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_INVALID_VALUE',
                              p_token1            => 'FIELD',
                              p_token1_value      => 'TEMPLATE_INTENT'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      IF g_deliverable_update_allowed <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_INS_OBJ',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code,
                              p_token2            => 'OBJECT',
                              p_token2_value      => 'DELIVERABLE'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      default_row (p_deliverable_rec => p_deliverable_rec);

      BEGIN
         fnd_msg_pub.initialize;
         validate_row (p_deliverable_rec => p_deliverable_rec);
      EXCEPTION
         WHEN OTHERS
         THEN
            RAISE;
      END;

   IF p_deliverable_rec.print_due_date_msg_name IS NULL
    OR p_deliverable_rec.print_due_date_msg_name = OKC_API.G_MISS_CHAR
    THEN
         IF p_deliverable_rec.relative_st_date_event_id IS NOT NULL
         THEN
            l_start_date_fixed := 'N';
            get_event_details (p_deliverable_rec.relative_st_date_event_id,
                               l_start_evt_before_after
                              );
         ELSE
            l_start_date_fixed := 'Y';
         END IF;

		IF  p_deliverable_rec.recurring_yn = 'Y' THEN
           IF p_deliverable_rec.relative_end_date_event_id IS NULL THEN
            l_end_date_fixed := 'Y';
           ELSE
           l_end_date_fixed := 'N';
           get_event_details (p_deliverable_rec.relative_end_date_event_id,
                               l_end_evt_before_after
                              );
           END IF;
         ELSE
          l_end_date_fixed := 'N';
          get_event_details (p_deliverable_rec.relative_end_date_event_id,
                               l_end_evt_before_after
                              );
         END IF;


    IF p_deliverable_rec.repeating_duration IS NOT NULL
        AND p_deliverable_rec.repeating_frequency_uom IS NOT NULL THEN

         l_repeating_frequency_uom :=
            getuomvalue (p_duration      => p_deliverable_rec.repeating_duration,
                         p_uom           => p_deliverable_rec.repeating_frequency_uom
                        );
        ELSE
            l_repeating_frequency_uom := NULL;
        END IF;

        IF p_deliverable_rec.relative_st_date_duration IS not NULL AND
            p_deliverable_rec.relative_st_date_uom IS NOT NULL
           THEN
         l_relative_st_date_uom :=
            getuomvalue
                   (p_duration      => p_deliverable_rec.relative_st_date_duration,
                    p_uom           => p_deliverable_rec.relative_st_date_uom
                   );
         ELSE
         l_relative_st_date_uom := NULL;
         END IF;

         IF p_deliverable_rec.relative_end_date_duration IS NOT NULL AND
            p_deliverable_rec.relative_end_date_uom IS NOT NULL THEN

         l_relative_end_date_uom :=
            getuomvalue
                  (p_duration      => p_deliverable_rec.relative_end_date_duration,
                   p_uom           => p_deliverable_rec.relative_end_date_uom
                  );
          ELSE
            l_relative_end_date_uom := NULL;
          END IF;


		p_deliverable_rec.print_due_date_msg_name :=
            getprintduedatemsgname
                      (p_recurring_flag               => p_deliverable_rec.recurring_yn,
                       p_start_fixed_flag             => l_start_date_fixed,
                       p_end_fixed_flag               => l_end_date_fixed,
                       p_repeating_frequency_uom      => l_repeating_frequency_uom,
                       p_relative_st_date_uom         => l_relative_st_date_uom,
                       p_relative_end_date_uom        => l_relative_end_date_uom,
                       p_start_evt_before_after       => l_start_evt_before_after,
                       p_end_evt_before_after         => l_end_evt_before_after
                      );
         end if;

      INSERT INTO okc_deliverables
                  (deliverable_id,
                   business_document_type,
                   business_document_id,
                   business_document_number,
                   deliverable_type,
                   responsible_party,
                   internal_party_contact_id,
                   external_party_contact_id,
                   deliverable_name,
                   description, comments,
                   display_sequence,
                   fixed_due_date_yn,
                   actual_due_date,
                   print_due_date_msg_name,
                   recurring_yn,
                   notify_prior_due_date_value,
                   notify_prior_due_date_uom,
                   notify_prior_due_date_yn,
                   notify_completed_yn,
                   notify_overdue_yn,
                   notify_escalation_yn,
                   notify_escalation_value,
                   notify_escalation_uom,
                   escalation_assignee,
                   amendment_operation,
                   prior_notification_id,
                   amendment_notes,
                   completed_notification_id,
                   overdue_notification_id,
                   escalation_notification_id,
                   LANGUAGE,
                   original_deliverable_id,
                   requester_id,
                   external_party_id,
                   recurring_del_parent_id,
                   business_document_version,
                   relative_st_date_duration,
                   relative_st_date_uom,
                   relative_st_date_event_id,
                   relative_end_date_duration,
                   relative_end_date_uom,
                   relative_end_date_event_id,
                   repeating_day_of_month,
                   repeating_day_of_week,
                   repeating_frequency_uom,
                   repeating_duration,
                   fixed_start_date,
                   fixed_end_date,
                   manage_yn,
                   internal_party_id,
                   deliverable_status,
                   status_change_notes,
                   created_by,
                   creation_date,
                   last_updated_by,
                   last_update_date,
                   last_update_login,
                   object_version_number,
                   attribute_category,
                   attribute1,
                   attribute2,
                   attribute3,
                   attribute4,
                   attribute5,
                   attribute6,
                   attribute7,
                   attribute8,
                   attribute9,
                   attribute10,
                   attribute11,
                   attribute12,
                   attribute13,
                   attribute14,
                   attribute15,
                   disable_notifications_yn,
                   last_amendment_date,
                   business_document_line_id,
                   external_party_site_id,
                   start_event_date,
                   end_event_date,
                   summary_amend_operation_code,
                   external_party_role,
                   pay_hold_prior_due_date_yn,
                   pay_hold_prior_due_date_value,
                   pay_hold_prior_due_date_uom,
                   pay_hold_overdue_yn
                  )
           VALUES (p_deliverable_rec.deliverable_id,
                   p_deliverable_rec.business_document_type,
                   p_deliverable_rec.business_document_id,
                   TO_CHAR (p_deliverable_rec.business_document_id),
                   -- business_document_number,
                   p_deliverable_rec.deliverable_type,
                   p_deliverable_rec.responsible_party,
                   p_deliverable_rec.internal_party_contact_id,
                   p_deliverable_rec.external_party_contact_id,
                   p_deliverable_rec.deliverable_name,
                   p_deliverable_rec.description, p_deliverable_rec.comments,
                   p_deliverable_rec.display_sequence,
                   p_deliverable_rec.fixed_due_date_yn,
                   p_deliverable_rec.actual_due_date,
                   p_deliverable_rec.print_due_date_msg_name,
                   p_deliverable_rec.recurring_yn,
                   p_deliverable_rec.notify_prior_due_date_value,
                   p_deliverable_rec.notify_prior_due_date_uom,
                   p_deliverable_rec.notify_prior_due_date_yn,
                   p_deliverable_rec.notify_completed_yn,
                   p_deliverable_rec.notify_overdue_yn,
                   p_deliverable_rec.notify_escalation_yn,
                   p_deliverable_rec.notify_escalation_value,
                   p_deliverable_rec.notify_escalation_uom,
                   p_deliverable_rec.escalation_assignee,
                   p_deliverable_rec.amendment_operation,
                   p_deliverable_rec.prior_notification_id,
                   p_deliverable_rec.amendment_notes,
                   p_deliverable_rec.completed_notification_id,
                   p_deliverable_rec.overdue_notification_id,
                   p_deliverable_rec.escalation_notification_id,
                   p_deliverable_rec.LANGUAGE,
                   p_deliverable_rec.original_deliverable_id,
                   p_deliverable_rec.requester_id,
                   p_deliverable_rec.external_party_id,
                   p_deliverable_rec.recurring_del_parent_id,
                   p_deliverable_rec.business_document_version,
                   p_deliverable_rec.relative_st_date_duration,
                   p_deliverable_rec.relative_st_date_uom,
                   p_deliverable_rec.relative_st_date_event_id,
                   p_deliverable_rec.relative_end_date_duration,
                   p_deliverable_rec.relative_end_date_uom,
                   p_deliverable_rec.relative_end_date_event_id,
                   p_deliverable_rec.repeating_day_of_month,
                   p_deliverable_rec.repeating_day_of_week,
                   p_deliverable_rec.repeating_frequency_uom,
                   p_deliverable_rec.repeating_duration,
                   p_deliverable_rec.fixed_start_date,
                   p_deliverable_rec.fixed_end_date,
                   p_deliverable_rec.manage_yn,
                   p_deliverable_rec.internal_party_id,
                   p_deliverable_rec.deliverable_status,
                   p_deliverable_rec.status_change_notes,
                   p_deliverable_rec.created_by,
                   p_deliverable_rec.creation_date,
                   p_deliverable_rec.last_updated_by,
                   p_deliverable_rec.last_update_date,
                   p_deliverable_rec.last_update_login,
                   p_deliverable_rec.object_version_number,
                   p_deliverable_rec.attribute_category,
                   p_deliverable_rec.attribute1,
                   p_deliverable_rec.attribute2,
                   p_deliverable_rec.attribute3,
                   p_deliverable_rec.attribute4,
                   p_deliverable_rec.attribute5,
                   p_deliverable_rec.attribute6,
                   p_deliverable_rec.attribute7,
                   p_deliverable_rec.attribute8,
                   p_deliverable_rec.attribute9,
                   p_deliverable_rec.attribute10,
                   p_deliverable_rec.attribute11,
                   p_deliverable_rec.attribute12,
                   p_deliverable_rec.attribute13,
                   p_deliverable_rec.attribute14,
                   p_deliverable_rec.attribute15,
                   p_deliverable_rec.disable_notifications_yn,
                   p_deliverable_rec.last_amendment_date,
                   p_deliverable_rec.business_document_line_id,
                   p_deliverable_rec.external_party_site_id,
                   p_deliverable_rec.start_event_date,
                   p_deliverable_rec.end_event_date,
                   p_deliverable_rec.summary_amend_operation_code,
                   p_deliverable_rec.external_party_role,
                   p_deliverable_rec.pay_hold_prior_due_date_yn,
                   p_deliverable_rec.pay_hold_prior_due_date_value,
                   p_deliverable_rec.pay_hold_prior_due_date_uom,
                   p_deliverable_rec.pay_hold_overdue_yn
                  );

      p_deliverable_rec.status := g_ret_sts_success;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         p_deliverable_rec.status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         read_message (l_error_message);
         p_deliverable_rec.errmsg := l_error_message;
         ROLLBACK TO create_deliverable_sp;
         fnd_msg_pub.initialize;
      WHEN OTHERS
      THEN
         p_deliverable_rec.status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         read_message (l_error_message);
         p_deliverable_rec.errmsg := l_error_message;
         ROLLBACK TO create_deliverable_sp;
         fnd_msg_pub.initialize;
   END create_deliverable;

   PROCEDURE create_deliverable (
      p_deliverable_tbl   IN OUT NOCOPY   deliverable_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   )
   IS
   BEGIN
      IF p_deliverable_tbl.COUNT > 0
      THEN
         FOR i IN p_deliverable_tbl.FIRST .. p_deliverable_tbl.LAST
         LOOP
            BEGIN
               create_deliverable (p_deliverable_rec      => p_deliverable_tbl
                                                                          (i));
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_deliverable_tbl (i).status := g_ret_sts_error;
                  p_deliverable_tbl (i).errmsg := SQLERRM;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END create_deliverable;

   PROCEDURE delete_deliverables (
      p_template_id          IN              NUMBER,
      p_deliverable_id_tbl   IN              deliverable_id_tbl_type,
      p_commit               IN              VARCHAR2 := fnd_api.g_false,
      x_deliverable_id_tbl   OUT NOCOPY      deliverable_id_tbl_type,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2
   )
   IS
      --l_k_article_id_tbl  k_article_id_tbl_type
      l_proc   VARCHAR2 (60) := 'DELETE_DELIVERABLES';
   BEGIN
      fnd_msg_pub.initialize;

      IF p_template_id <> NVL (g_template_id, -1)
      THEN
         IF inittemplateinfo (p_template_id => p_template_id) <> 'Y'
         THEN
            okc_api.set_message (p_app_name          => g_app_name,
                                 p_msg_name          => 'OKC_I_INVALID_VALUE',
                                 p_token1            => 'FIELD',
                                 p_token1_value      => 'TEMPLATE_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      IF g_deliverable_update_allowed <> 'Y'
      THEN
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_DEL_OBJ',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code,
                              p_token2            => 'OBJECT',
                              p_token2_value      => 'DELIVERABLE'
                             );
         RAISE fnd_api.g_exc_error;
      ELSE
         FORALL i IN 1 .. p_deliverable_id_tbl.COUNT
            DELETE FROM okc_deliverables
                  WHERE deliverable_id = p_deliverable_id_tbl (i)
                    AND business_document_type = 'TEMPLATE'
                    AND business_document_id = p_template_id
              RETURNING       deliverable_id
            BULK COLLECT INTO x_deliverable_id_tbl;
      END IF;

      x_return_status := g_ret_sts_success;

      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         read_message (x_msg_data);

         IF fnd_api.to_boolean (p_commit)
         THEN
            COMMIT;
         END IF;

         fnd_msg_pub.initialize;
      WHEN OTHERS
      THEN
         x_return_status := g_ret_sts_error;
         set_proc_error_message (p_proc => l_proc);
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => g_unexpected_error,
                              p_token1            => g_sqlcode_token,
                              p_token1_value      => SQLCODE,
                              p_token2            => g_sqlerrm_token,
                              p_token2_value      => SQLERRM
                             );
         read_message (x_msg_data);

         IF fnd_api.to_boolean (p_commit)
         THEN
            COMMIT;
         END IF;

         fnd_msg_pub.initialize;
   END delete_deliverables;

   PROCEDURE validate_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type,
      p_mode             IN              VARCHAR2 := 'CREATE'
   )
   IS
      l_progress     VARCHAR2 (3);
      l_proc         VARCHAR2 (60) := 'VALIDATE_TMPL_USAGE';
      l_doc_intent   VARCHAR2 (1);

      CURSOR l_doc_intent_csr
      IS
         SELECT intent
           FROM okc_bus_doc_types_b
          WHERE document_type = p_tmpl_usage_rec.document_type;
   BEGIN
      l_progress := '010';

      IF p_template_id IS NULL
      THEN
         okc_api.set_message (g_app_name,
                              okc_api.g_required_value,
                              okc_api.g_col_name_token,
                              'TEMPLATE_ID'
                             );
         RAISE fnd_api.g_exc_error;
      -- Template id must not be null and it must be a valid template
      ELSIF inittemplateinfo (p_template_id) <> 'Y'
      THEN
         okc_api.set_message (g_app_name,
                              okc_api.g_invalid_value,
                              okc_api.g_col_name_token,
                              'TEMPLATE_ID'
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Validate template status
      IF g_headerinfo_update_allowed = 'N'
      THEN
         l_progress := '020';
         -- Can't update anything just return the error.
         okc_api.set_message (p_app_name          => g_app_name,
                              p_msg_name          => 'OKC_I_TEMP_STS_NO_UPD',
                              p_token1            => 'STATUS',
                              p_token1_value      => g_template_status_code
                             );
         RAISE fnd_api.g_exc_error;
      END IF;

      -- If mode is update or delete, validate the allowed_tmpl_usages_id with template id
      -- Get object version number and document type details if the user has not already provided.
      IF (p_mode = 'UPDATE' OR p_mode = 'DELETE')
      THEN
         IF p_tmpl_usage_rec.allowed_tmpl_usages_id IS NULL
         THEN
            okc_api.set_message (g_app_name,
                                 okc_api.g_required_value,
                                 okc_api.g_col_name_token,
                                 'ALLOWED_TMPL_USAGES_ID'
                                );
            RAISE fnd_api.g_exc_error;
          -- Validate and initialize the p_tmpl_usage_rec
         ELSIF validate_tmpl_usage_id (p_template_id, p_tmpl_usage_rec,
                                       p_mode) <> 'Y'
         THEN
            okc_api.set_message (g_app_name,
                                 okc_api.g_invalid_value,
                                 okc_api.g_col_name_token,
                                 'ALLOWED_TMPL_USAGES_ID'
                                );
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      -- If the mode is delete do not validate the document_type
      IF p_mode <> 'DELETE'
      THEN
         -- Validate document Type
         IF p_tmpl_usage_rec.document_type IS NULL
         THEN
            okc_api.set_message (g_app_name,
                                 okc_api.g_required_value,
                                 okc_api.g_col_name_token,
                                 'DOCUMENT_TYPE'
                                );
            RAISE fnd_api.g_exc_error;
         ELSE
            l_doc_intent := NULL;

            OPEN l_doc_intent_csr;

            FETCH l_doc_intent_csr
             INTO l_doc_intent;

            CLOSE l_doc_intent_csr;

            IF g_template_intent <> l_doc_intent
            THEN
               okc_api.set_message (g_app_name,
                                    'OKC_TMPL_ALWD_USG_WRONG_INTENT',
                                    'DOCUMENT_TYPE',
                                    p_tmpl_usage_rec.document_type
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;

            IF validate_bus_doc_type (p_tmpl_usage_rec.document_type) <> 'Y'
            THEN
               okc_api.set_message (g_app_name,
                                    okc_api.g_invalid_value,
                                    okc_api.g_col_name_token,
                                    'DOCUMENT_TYPE'
                                   );
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END validate_tmpl_usage;

   PROCEDURE create_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type
   )
   IS
      x_return_status   VARCHAR2 (1);
      x_msg_count       NUMBER;
      x_msg_data        VARCHAR2 (2000);
      l_proc            VARCHAR2 (60)   := 'CREATE_TMPL_USAGE';

      PROCEDURE default_row (
         p_template_id      IN              NUMBER,
         p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type
      )
      IS
         l_proc   VARCHAR2 (60) := 'DEFAULT_ROW';
      BEGIN
         -- IF p_tmpl_usage_rec.ALLOWED_TMPL_USAGES_ID = OKC_API.G_MISS_NUM  THEN p_tmpl_usage_rec.ALLOWED_TMPL_USAGES_ID:= NULL;  END IF;
         IF p_tmpl_usage_rec.document_type = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.document_type := NULL;
         END IF;

         IF p_tmpl_usage_rec.default_yn = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.default_yn := 'N';
         END IF;

         IF p_tmpl_usage_rec.last_update_login = okc_api.g_miss_num
         THEN
            p_tmpl_usage_rec.last_update_login := fnd_global.login_id;
         END IF;

         IF p_tmpl_usage_rec.creation_date = okc_api.g_miss_date
         THEN
            p_tmpl_usage_rec.creation_date := SYSDATE;
         END IF;

         IF p_tmpl_usage_rec.created_by = okc_api.g_miss_num
         THEN
            p_tmpl_usage_rec.created_by := fnd_global.user_id;
         END IF;

         IF p_tmpl_usage_rec.last_updated_by = okc_api.g_miss_num
         THEN
            p_tmpl_usage_rec.last_updated_by := fnd_global.user_id;
         END IF;

         IF p_tmpl_usage_rec.last_update_date = okc_api.g_miss_date
         THEN
            p_tmpl_usage_rec.last_update_date := SYSDATE;
         END IF;

         IF p_tmpl_usage_rec.object_version_number = okc_api.g_miss_num
         THEN
            p_tmpl_usage_rec.object_version_number := 1;
         END IF;

         IF p_tmpl_usage_rec.attribute_category = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute_category := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute1 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute1 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute2 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute2 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute3 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute3 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute4 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute4 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute5 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute5 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute6 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute6 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute7 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute7 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute8 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute8 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute9 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute9 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute10 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute10 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute11 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute11 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute12 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute12 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute13 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute13 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute14 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute14 := NULL;
         END IF;

         IF p_tmpl_usage_rec.attribute15 = okc_api.g_miss_char
         THEN
            p_tmpl_usage_rec.attribute15 := NULL;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            set_proc_error_message (p_proc => l_proc);
            RAISE;
      END default_row;
   BEGIN
      -- Default the  Row
      default_row (p_template_id         => p_template_id,
                   p_tmpl_usage_rec      => p_tmpl_usage_rec
                  );
      -- Validate the Row
      validate_tmpl_usage (p_template_id         => p_template_id,
                           p_tmpl_usage_rec      => p_tmpl_usage_rec,
                           p_mode                => 'CREATE'
                          );
      -- Insert the Row
      okc_allowed_tmpl_usages_grp.create_allowed_tmpl_usages
          (p_api_version                 => 1,
           p_init_msg_list               => fnd_api.g_true,
           p_validation_level            => fnd_api.g_valid_level_full,
           p_commit                      => fnd_api.g_false,
           x_return_status               => x_return_status,
           x_msg_count                   => x_msg_count,
           x_msg_data                    => x_msg_data,
           p_template_id                 => p_template_id,
           p_document_type               => p_tmpl_usage_rec.document_type,
           p_default_yn                  => p_tmpl_usage_rec.default_yn,
           p_allowed_tmpl_usages_id      => NULL,
           p_attribute_category          => p_tmpl_usage_rec.attribute_category,
           p_attribute1                  => p_tmpl_usage_rec.attribute1,
           p_attribute2                  => p_tmpl_usage_rec.attribute2,
           p_attribute3                  => p_tmpl_usage_rec.attribute3,
           p_attribute4                  => p_tmpl_usage_rec.attribute4,
           p_attribute5                  => p_tmpl_usage_rec.attribute5,
           p_attribute6                  => p_tmpl_usage_rec.attribute6,
           p_attribute7                  => p_tmpl_usage_rec.attribute7,
           p_attribute8                  => p_tmpl_usage_rec.attribute8,
           p_attribute9                  => p_tmpl_usage_rec.attribute9,
           p_attribute10                 => p_tmpl_usage_rec.attribute10,
           p_attribute11                 => p_tmpl_usage_rec.attribute11,
           p_attribute12                 => p_tmpl_usage_rec.attribute12,
           p_attribute13                 => p_tmpl_usage_rec.attribute13,
           p_attribute14                 => p_tmpl_usage_rec.attribute14,
           p_attribute15                 => p_tmpl_usage_rec.attribute15,
           x_allowed_tmpl_usages_id      => p_tmpl_usage_rec.allowed_tmpl_usages_id
          );

      IF x_return_status <> g_ret_sts_success
      THEN
         p_tmpl_usage_rec.status := g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END create_tmpl_usage;

   PROCEDURE create_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_tbl   IN OUT NOCOPY   tmpl_usage_tbl_type,
      p_commit           IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_error_message   VARCHAR2 (2000);
   BEGIN
      IF p_tmpl_usage_tbl.COUNT > 0
      THEN
         FOR i IN p_tmpl_usage_tbl.FIRST .. p_tmpl_usage_tbl.LAST
         LOOP
            BEGIN
               fnd_msg_pub.initialize;
               SAVEPOINT create_tmpl_usage_sp;
               create_tmpl_usage (p_template_id         => p_template_id,
                                  p_tmpl_usage_rec      => p_tmpl_usage_tbl
                                                                           (i)
                                 );
               p_tmpl_usage_tbl (i).status := g_ret_sts_success;

               IF fnd_api.to_boolean (p_commit)
               THEN
                  COMMIT;
               END IF;
            EXCEPTION
               WHEN fnd_api.g_exc_error
               THEN
                  p_tmpl_usage_tbl (i).status := g_ret_sts_error;
                  read_message (l_error_message);
                  p_tmpl_usage_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO create_tmpl_usage_sp;
                  fnd_msg_pub.initialize;
               WHEN OTHERS
               THEN
                  p_tmpl_usage_tbl (i).status := g_ret_sts_error;
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => g_unexpected_error,
                                       p_token1            => g_sqlcode_token,
                                       p_token1_value      => SQLCODE,
                                       p_token2            => g_sqlerrm_token,
                                       p_token2_value      => SQLERRM
                                      );
                  read_message (l_error_message);
                  p_tmpl_usage_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO create_tmpl_usage_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END create_tmpl_usage;

   PROCEDURE update_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type
   )
   IS
      l_proc            VARCHAR2 (60)   := 'UPDATE_TMPL_USAGE';
      x_return_status   VARCHAR2 (1);
      x_msg_count       NUMBER;
      x_msg_data        VARCHAR2 (2000);
   BEGIN
      -- Do Basic Validation
      validate_tmpl_usage (p_template_id, p_tmpl_usage_rec, 'UPDATE');
      -- Call API to validate and Update
      okc_allowed_tmpl_usages_grp.update_allowed_tmpl_usages
         (p_api_version                 => 1,
          p_init_msg_list               => fnd_api.g_true,
          p_validation_level            => fnd_api.g_valid_level_full,
          p_commit                      => fnd_api.g_false,
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                    => x_msg_data,
          p_template_id                 => p_template_id,
          p_document_type               => p_tmpl_usage_rec.document_type,
          p_default_yn                  => p_tmpl_usage_rec.default_yn,
          p_allowed_tmpl_usages_id      => p_tmpl_usage_rec.allowed_tmpl_usages_id,
          p_attribute_category          => p_tmpl_usage_rec.attribute_category,
          p_attribute1                  => p_tmpl_usage_rec.attribute1,
          p_attribute2                  => p_tmpl_usage_rec.attribute2,
          p_attribute3                  => p_tmpl_usage_rec.attribute3,
          p_attribute4                  => p_tmpl_usage_rec.attribute4,
          p_attribute5                  => p_tmpl_usage_rec.attribute5,
          p_attribute6                  => p_tmpl_usage_rec.attribute6,
          p_attribute7                  => p_tmpl_usage_rec.attribute7,
          p_attribute8                  => p_tmpl_usage_rec.attribute8,
          p_attribute9                  => p_tmpl_usage_rec.attribute9,
          p_attribute10                 => p_tmpl_usage_rec.attribute10,
          p_attribute11                 => p_tmpl_usage_rec.attribute11,
          p_attribute12                 => p_tmpl_usage_rec.attribute12,
          p_attribute13                 => p_tmpl_usage_rec.attribute13,
          p_attribute14                 => p_tmpl_usage_rec.attribute14,
          p_attribute15                 => p_tmpl_usage_rec.attribute15,
          p_object_version_number       => p_tmpl_usage_rec.object_version_number
         );

      IF x_return_status <> g_ret_sts_success
      THEN
         p_tmpl_usage_rec.status := g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END update_tmpl_usage;

   PROCEDURE update_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_tbl   IN OUT NOCOPY   tmpl_usage_tbl_type,
      p_commit           IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_error_message   VARCHAR2 (2000);
   BEGIN
      IF p_tmpl_usage_tbl.COUNT > 0
      THEN
         FOR i IN p_tmpl_usage_tbl.FIRST .. p_tmpl_usage_tbl.LAST
         LOOP
            BEGIN
               fnd_msg_pub.initialize;
               SAVEPOINT update_tmpl_usage_sp;
               update_tmpl_usage (p_template_id         => p_template_id,
                                  p_tmpl_usage_rec      => p_tmpl_usage_tbl
                                                                           (i)
                                 );
               p_tmpl_usage_tbl (i).status := g_ret_sts_success;

               IF fnd_api.to_boolean (p_commit)
               THEN
                  COMMIT;
               END IF;
            EXCEPTION
               WHEN fnd_api.g_exc_error
               THEN
                  p_tmpl_usage_tbl (i).status := g_ret_sts_error;
                  read_message (l_error_message);
                  p_tmpl_usage_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO update_tmpl_usage_sp;
                  fnd_msg_pub.initialize;
               WHEN OTHERS
               THEN
                  p_tmpl_usage_tbl (i).status := g_ret_sts_error;
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => g_unexpected_error,
                                       p_token1            => g_sqlcode_token,
                                       p_token1_value      => SQLCODE,
                                       p_token2            => g_sqlerrm_token,
                                       p_token2_value      => SQLERRM
                                      );
                  read_message (l_error_message);
                  p_tmpl_usage_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO create_tmpl_usage_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END update_tmpl_usage;

   PROCEDURE delete_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_rec   IN OUT NOCOPY   tmpl_usage_rec_type
   )
   IS
      l_proc            VARCHAR2 (60)   := 'DELETE_TMPL_USAGE';
      x_return_status   VARCHAR2 (1);
      x_msg_count       NUMBER;
      x_msg_data        VARCHAR2 (2000);
   BEGIN
      -- Do Basic Validation
      validate_tmpl_usage (p_template_id, p_tmpl_usage_rec, 'DELETE');
      -- Call API to validate and Update
      okc_allowed_tmpl_usages_grp.delete_allowed_tmpl_usages
         (p_api_version                 => 1,
          p_init_msg_list               => fnd_api.g_true,
          p_commit                      => fnd_api.g_false,
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                    => x_msg_data,
          p_allowed_tmpl_usages_id      => p_tmpl_usage_rec.allowed_tmpl_usages_id,
          p_object_version_number       => p_tmpl_usage_rec.object_version_number
         );

      IF x_return_status <> g_ret_sts_success
      THEN
         p_tmpl_usage_rec.status := g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         set_proc_error_message (p_proc => l_proc);
         RAISE;
   END delete_tmpl_usage;

   PROCEDURE delete_tmpl_usage (
      p_template_id      IN              NUMBER,
      p_tmpl_usage_tbl   IN OUT NOCOPY   tmpl_usage_tbl_type,
      p_commit           IN              VARCHAR2 := fnd_api.g_false
   )
   IS
      l_error_message   VARCHAR2 (2000);
   BEGIN
      IF p_tmpl_usage_tbl.COUNT > 0
      THEN
         FOR i IN p_tmpl_usage_tbl.FIRST .. p_tmpl_usage_tbl.LAST
         LOOP
            BEGIN
               fnd_msg_pub.initialize;
               SAVEPOINT delete_tmpl_usage_sp;
               delete_tmpl_usage (p_template_id         => p_template_id,
                                  p_tmpl_usage_rec      => p_tmpl_usage_tbl
                                                                           (i)
                                 );
               p_tmpl_usage_tbl (i).status := g_ret_sts_success;

               IF fnd_api.to_boolean (p_commit)
               THEN
                  COMMIT;
               END IF;
            EXCEPTION
               WHEN fnd_api.g_exc_error
               THEN
                  p_tmpl_usage_tbl (i).status := g_ret_sts_error;
                  read_message (l_error_message);
                  p_tmpl_usage_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO delete_tmpl_usage_sp;
                  fnd_msg_pub.initialize;
               WHEN OTHERS
               THEN
                  p_tmpl_usage_tbl (i).status := g_ret_sts_error;
                  okc_api.set_message (p_app_name          => g_app_name,
                                       p_msg_name          => g_unexpected_error,
                                       p_token1            => g_sqlcode_token,
                                       p_token1_value      => SQLCODE,
                                       p_token2            => g_sqlerrm_token,
                                       p_token2_value      => SQLERRM
                                      );
                  read_message (l_error_message);
                  p_tmpl_usage_tbl (i).errmsg := l_error_message;
                  ROLLBACK TO delete_tmpl_usage_sp;
                  fnd_msg_pub.initialize;
            END;
         END LOOP;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END delete_tmpl_usage;
END okc_imp_terms_templates_pvt;

/
