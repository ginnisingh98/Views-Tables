--------------------------------------------------------
--  DDL for Package OKC_IMP_TERMS_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_IMP_TERMS_TEMPLATES_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCVITTS.pls 120.0.12010000.5 2011/05/27 10:33:24 serukull noship $*/
------------------------------------------------------------------------------
-- GLOBAL VARIABLES
------------------------------------------------------------------------------
   g_pkg_name              CONSTANT VARCHAR2 (200)
                                             := 'OKC_IMP_TERMS_TEMPLATES_PVT';
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

   TYPE terms_template_rec_type IS RECORD (
      template_id                  okc_terms_templates_all.template_id%TYPE
                                                        := okc_api.g_miss_num,
      template_name                okc_terms_templates_all.template_name%TYPE
                                                       := okc_api.g_miss_char,
      intent                       okc_terms_templates_all.intent%TYPE
                                                       := okc_api.g_miss_char,
      status_code                  okc_terms_templates_all.status_code%TYPE
                                                       := okc_api.g_miss_char,
      start_date                   okc_terms_templates_all.start_date%TYPE
                                                       := okc_api.g_miss_date,
      end_date                     okc_terms_templates_all.end_date%TYPE
                                                       := okc_api.g_miss_date,
      global_flag                  okc_terms_templates_all.global_flag%TYPE
                                                       := okc_api.g_miss_char,
      instruction_text             okc_terms_templates_all.instruction_text%TYPE
                                                       := okc_api.g_miss_char,
      description                  okc_terms_templates_all.description%TYPE
                                                       := okc_api.g_miss_char,
      working_copy_flag            okc_terms_templates_all.working_copy_flag%TYPE
                                                       := okc_api.g_miss_char,
      parent_template_id           okc_terms_templates_all.parent_template_id%TYPE
                                                        := okc_api.g_miss_num,
      contract_expert_enabled      okc_terms_templates_all.contract_expert_enabled%TYPE
                                                       := okc_api.g_miss_char,
      template_model_id            okc_terms_templates_all.template_model_id%TYPE
                                                        := okc_api.g_miss_num,
      tmpl_numbering_scheme        okc_terms_templates_all.tmpl_numbering_scheme%TYPE
                                                        := okc_api.g_miss_num,
      print_template_id            okc_terms_templates_all.print_template_id%TYPE
                                                        := okc_api.g_miss_num,
      approval_wf_key              okc_terms_templates_all.approval_wf_key%TYPE
                                                       := okc_api.g_miss_char,
      cz_export_wf_key             okc_terms_templates_all.cz_export_wf_key%TYPE
                                                       := okc_api.g_miss_char,
      last_update_login            NUMBER               := okc_api.g_miss_num,
      creation_date                DATE                := okc_api.g_miss_date,
      created_by                   NUMBER               := okc_api.g_miss_num,
      last_updated_by              NUMBER               := okc_api.g_miss_num,
      last_update_date             DATE                := okc_api.g_miss_date,
      org_id                       okc_terms_templates_all.org_id%TYPE
                                                        := okc_api.g_miss_num,
      orig_system_reference_code   okc_terms_templates_all.orig_system_reference_code%TYPE
                                                       := okc_api.g_miss_char,
      orig_system_reference_id1    okc_terms_templates_all.orig_system_reference_id1%TYPE
                                                        := okc_api.g_miss_num,
      orig_system_reference_id2    okc_terms_templates_all.orig_system_reference_id2%TYPE
                                                        := okc_api.g_miss_num,
      object_version_number        NUMBER               := okc_api.g_miss_num,
      hide_yn                      okc_terms_templates_all.hide_yn%TYPE
                                                       := okc_api.g_miss_char,
      attribute_category           okc_terms_templates_all.attribute_category%TYPE
                                                       := okc_api.g_miss_char,
      attribute1                   okc_terms_templates_all.attribute1%TYPE
                                                       := okc_api.g_miss_char,
      attribute2                   okc_terms_templates_all.attribute2%TYPE
                                                       := okc_api.g_miss_char,
      attribute3                   okc_terms_templates_all.attribute3%TYPE
                                                       := okc_api.g_miss_char,
      attribute4                   okc_terms_templates_all.attribute4%TYPE
                                                       := okc_api.g_miss_char,
      attribute5                   okc_terms_templates_all.attribute5%TYPE
                                                       := okc_api.g_miss_char,
      attribute6                   okc_terms_templates_all.attribute6%TYPE
                                                       := okc_api.g_miss_char,
      attribute7                   okc_terms_templates_all.attribute7%TYPE
                                                       := okc_api.g_miss_char,
      attribute8                   okc_terms_templates_all.attribute8%TYPE
                                                       := okc_api.g_miss_char,
      attribute9                   okc_terms_templates_all.attribute9%TYPE
                                                       := okc_api.g_miss_char,
      attribute10                  okc_terms_templates_all.attribute10%TYPE
                                                       := okc_api.g_miss_char,
      attribute11                  okc_terms_templates_all.attribute11%TYPE
                                                       := okc_api.g_miss_char,
      attribute12                  okc_terms_templates_all.attribute12%TYPE
                                                       := okc_api.g_miss_char,
      attribute13                  okc_terms_templates_all.attribute13%TYPE
                                                       := okc_api.g_miss_char,
      attribute14                  okc_terms_templates_all.attribute14%TYPE
                                                       := okc_api.g_miss_char,
      attribute15                  okc_terms_templates_all.attribute15%TYPE
                                                       := okc_api.g_miss_char,
      xprt_request_id              NUMBER               := okc_api.g_miss_num,
      xprt_clause_mandatory_flag   okc_terms_templates_all.xprt_clause_mandatory_flag%TYPE
                                                       := okc_api.g_miss_char,
      xprt_scn_code                okc_terms_templates_all.xprt_scn_code%TYPE
                                                       := okc_api.g_miss_char,
      LANGUAGE                     okc_terms_templates_all.LANGUAGE%TYPE
                                                       := okc_api.g_miss_char,
      translated_from_tmpl_id      okc_terms_templates_all.translated_from_tmpl_id%TYPE
                                                        := okc_api.g_miss_num,
      status                       VARCHAR2 (1),
      errmsg                       VARCHAR2 (2500)
   );

   TYPE terms_template_tbl_type IS TABLE OF terms_template_rec_type
      INDEX BY PLS_INTEGER;

   TYPE tmpl_usage_rec_type IS RECORD (
      allowed_tmpl_usages_id   okc_allowed_tmpl_usages.allowed_tmpl_usages_id%TYPE
                                                        := okc_api.g_miss_num,

      document_type            okc_allowed_tmpl_usages.document_type%TYPE
                                                       := okc_api.g_miss_char,
      default_yn               okc_allowed_tmpl_usages.default_yn%TYPE
                                                       := okc_api.g_miss_char,
      last_update_login        NUMBER                   := okc_api.g_miss_num,
      creation_date            DATE                    := okc_api.g_miss_date,
      created_by               NUMBER                   := okc_api.g_miss_num,
      last_updated_by          NUMBER                   := okc_api.g_miss_num,
      last_update_date         DATE                    := okc_api.g_miss_date,
      object_version_number    NUMBER                   := okc_api.g_miss_num,
      attribute_category       okc_allowed_tmpl_usages.attribute_category%TYPE
                                                       := okc_api.g_miss_char,
      attribute1               okc_allowed_tmpl_usages.attribute1%TYPE
                                                       := okc_api.g_miss_char,
      attribute2               okc_allowed_tmpl_usages.attribute2%TYPE
                                                       := okc_api.g_miss_char,
      attribute3               okc_allowed_tmpl_usages.attribute3%TYPE
                                                       := okc_api.g_miss_char,
      attribute4               okc_allowed_tmpl_usages.attribute4%TYPE
                                                       := okc_api.g_miss_char,
      attribute5               okc_allowed_tmpl_usages.attribute5%TYPE
                                                       := okc_api.g_miss_char,
      attribute6               okc_allowed_tmpl_usages.attribute6%TYPE
                                                       := okc_api.g_miss_char,
      attribute7               okc_allowed_tmpl_usages.attribute7%TYPE
                                                       := okc_api.g_miss_char,
      attribute8               okc_allowed_tmpl_usages.attribute8%TYPE
                                                       := okc_api.g_miss_char,
      attribute9               okc_allowed_tmpl_usages.attribute9%TYPE
                                                       := okc_api.g_miss_char,
      attribute10              okc_allowed_tmpl_usages.attribute10%TYPE
                                                       := okc_api.g_miss_char,
      attribute11              okc_allowed_tmpl_usages.attribute11%TYPE
                                                       := okc_api.g_miss_char,
      attribute12              okc_allowed_tmpl_usages.attribute12%TYPE
                                                       := okc_api.g_miss_char,
      attribute13              okc_allowed_tmpl_usages.attribute13%TYPE
                                                       := okc_api.g_miss_char,
      attribute14              okc_allowed_tmpl_usages.attribute14%TYPE
                                                       := okc_api.g_miss_char,
      attribute15              okc_allowed_tmpl_usages.attribute15%TYPE
                                                       := okc_api.g_miss_char,
      status                   VARCHAR2 (1),
      errmsg                   VARCHAR2 (2500)
   );

   TYPE tmpl_usage_tbl_type IS TABLE OF tmpl_usage_rec_type
      INDEX BY PLS_INTEGER;

   TYPE section_rec_type IS RECORD (
      ID                             okc_sections_b.ID%TYPE
                                                        := okc_api.g_miss_num,
      scn_type                       okc_sections_b.scn_type%TYPE
                                                       := okc_api.g_miss_char,
      chr_id                         okc_sections_b.chr_id%TYPE
                                                        := okc_api.g_miss_num,
      sat_code                       okc_sections_b.sat_code%TYPE
                                                       := okc_api.g_miss_char,
      section_sequence               okc_sections_b.section_sequence%TYPE
                                                        := okc_api.g_miss_num,
      object_version_number          NUMBER             := okc_api.g_miss_num,
      created_by                     NUMBER             := okc_api.g_miss_num,
      creation_date                  okc_sections_b.creation_date%TYPE
                                                       := okc_api.g_miss_date,
      last_updated_by                NUMBER             := okc_api.g_miss_num,
      last_update_date               okc_sections_b.last_update_date%TYPE
                                                       := okc_api.g_miss_date,
      last_update_login              NUMBER             := okc_api.g_miss_num,
      label                          okc_sections_b.label%TYPE
                                                       := okc_api.g_miss_char,
      scn_id                         okc_sections_b.scn_id%TYPE
                                                        := okc_api.g_miss_num,
      attribute_category             okc_sections_b.attribute_category%TYPE
                                                       := okc_api.g_miss_char,
      attribute1                     okc_sections_b.attribute1%TYPE
                                                       := okc_api.g_miss_char,
      attribute2                     okc_sections_b.attribute2%TYPE
                                                       := okc_api.g_miss_char,
      attribute3                     okc_sections_b.attribute3%TYPE
                                                       := okc_api.g_miss_char,
      attribute4                     okc_sections_b.attribute4%TYPE
                                                       := okc_api.g_miss_char,
      attribute5                     okc_sections_b.attribute5%TYPE
                                                       := okc_api.g_miss_char,
      attribute6                     okc_sections_b.attribute6%TYPE
                                                       := okc_api.g_miss_char,
      attribute7                     okc_sections_b.attribute7%TYPE
                                                       := okc_api.g_miss_char,
      attribute8                     okc_sections_b.attribute8%TYPE
                                                       := okc_api.g_miss_char,
      attribute9                     okc_sections_b.attribute9%TYPE
                                                       := okc_api.g_miss_char,
      attribute10                    okc_sections_b.attribute10%TYPE
                                                       := okc_api.g_miss_char,
      attribute11                    okc_sections_b.attribute11%TYPE
                                                       := okc_api.g_miss_char,
      attribute12                    okc_sections_b.attribute12%TYPE
                                                       := okc_api.g_miss_char,
      attribute13                    okc_sections_b.attribute13%TYPE
                                                       := okc_api.g_miss_char,
      attribute14                    okc_sections_b.attribute14%TYPE
                                                       := okc_api.g_miss_char,
      attribute15                    okc_sections_b.attribute15%TYPE
                                                       := okc_api.g_miss_char,
      security_group_id              okc_sections_b.security_group_id%TYPE
                                                        := okc_api.g_miss_num,
      old_id                         okc_sections_b.old_id%TYPE
                                                        := okc_api.g_miss_num,
      document_type                  okc_sections_b.document_type%TYPE
                                                       := okc_api.g_miss_char,
      document_id                    okc_sections_b.document_id%TYPE
                                                        := okc_api.g_miss_num,
      scn_code                       okc_sections_b.scn_code%TYPE
                                                       := okc_api.g_miss_char,
      description                    okc_sections_b.description%TYPE
                                                       := okc_api.g_miss_char,
      amendment_description          okc_sections_b.amendment_description%TYPE
                                                       := okc_api.g_miss_char,
      amendment_operation_code       okc_sections_b.amendment_operation_code%TYPE
                                                       := okc_api.g_miss_char,
      orig_system_reference_code     okc_sections_b.orig_system_reference_code%TYPE
                                                       := okc_api.g_miss_char,
      orig_system_reference_id1      okc_sections_b.orig_system_reference_id1%TYPE
                                                        := okc_api.g_miss_num,
      orig_system_reference_id2      okc_sections_b.orig_system_reference_id2%TYPE
                                                        := okc_api.g_miss_num,
      print_yn                       okc_sections_b.print_yn%TYPE
                                                       := okc_api.g_miss_char,
      summary_amend_operation_code   okc_sections_b.summary_amend_operation_code%TYPE
                                                       := okc_api.g_miss_char,
      heading                        okc_sections_b.heading%TYPE
                                                       := okc_api.g_miss_char,
      last_amended_by                okc_sections_b.last_amended_by%TYPE
                                                        := okc_api.g_miss_num,
      last_amendment_date            okc_sections_b.last_amendment_date%TYPE
                                                       := okc_api.g_miss_date,
      status                         VARCHAR2 (1),
      errmsg                         VARCHAR2 (2500)
   );

   TYPE section_tbl_type IS TABLE OF section_rec_type
      INDEX BY PLS_INTEGER;

   TYPE k_article_rec_type IS RECORD (
      ID                             okc_k_articles_b.ID%TYPE
                                                        := okc_api.g_miss_num,
      sav_sae_id                     okc_k_articles_b.sav_sae_id%TYPE
                                                        := okc_api.g_miss_num,
      sav_sav_release                okc_k_articles_b.sav_sav_release%TYPE
                                                       := okc_api.g_miss_char,
      sbt_code                       okc_k_articles_b.sbt_code%TYPE
                                                       := okc_api.g_miss_char,
      cat_type                       okc_k_articles_b.cat_type%TYPE
                                                       := okc_api.g_miss_char,
      chr_id                         okc_k_articles_b.chr_id%TYPE
                                                        := okc_api.g_miss_num,
      cle_id                         okc_k_articles_b.cle_id%TYPE
                                                        := okc_api.g_miss_num,
      cat_id                         okc_k_articles_b.cat_id%TYPE
                                                        := okc_api.g_miss_num,
      dnz_chr_id                     okc_k_articles_b.dnz_chr_id%TYPE
                                                        := okc_api.g_miss_num,
      object_version_number          NUMBER             := okc_api.g_miss_num,
      created_by                     NUMBER             := okc_api.g_miss_num,
      creation_date                  okc_k_articles_b.creation_date%TYPE
                                                       := okc_api.g_miss_date,
      last_updated_by                NUMBER             := okc_api.g_miss_num,
      last_update_date               okc_k_articles_b.last_update_date%TYPE
                                                       := okc_api.g_miss_date,
      fulltext_yn                    okc_k_articles_b.fulltext_yn%TYPE
                                                       := okc_api.g_miss_char,
      last_update_login              NUMBER             := okc_api.g_miss_num,
      attribute_category             okc_k_articles_b.attribute_category%TYPE
                                                       := okc_api.g_miss_char,
      attribute1                     okc_k_articles_b.attribute1%TYPE
                                                       := okc_api.g_miss_char,
      attribute2                     okc_k_articles_b.attribute2%TYPE
                                                       := okc_api.g_miss_char,
      attribute3                     okc_k_articles_b.attribute3%TYPE
                                                       := okc_api.g_miss_char,
      attribute4                     okc_k_articles_b.attribute4%TYPE
                                                       := okc_api.g_miss_char,
      attribute5                     okc_k_articles_b.attribute5%TYPE
                                                       := okc_api.g_miss_char,
      attribute6                     okc_k_articles_b.attribute6%TYPE
                                                       := okc_api.g_miss_char,
      attribute7                     okc_k_articles_b.attribute7%TYPE
                                                       := okc_api.g_miss_char,
      attribute8                     okc_k_articles_b.attribute8%TYPE
                                                       := okc_api.g_miss_char,
      attribute9                     okc_k_articles_b.attribute9%TYPE
                                                       := okc_api.g_miss_char,
      attribute10                    okc_k_articles_b.attribute10%TYPE
                                                       := okc_api.g_miss_char,
      attribute11                    okc_k_articles_b.attribute11%TYPE
                                                       := okc_api.g_miss_char,
      attribute12                    okc_k_articles_b.attribute12%TYPE
                                                       := okc_api.g_miss_char,
      attribute13                    okc_k_articles_b.attribute13%TYPE
                                                       := okc_api.g_miss_char,
      attribute14                    okc_k_articles_b.attribute14%TYPE
                                                       := okc_api.g_miss_char,
      attribute15                    okc_k_articles_b.attribute15%TYPE
                                                       := okc_api.g_miss_char,
      security_group_id              okc_k_articles_b.security_group_id%TYPE
                                                        := okc_api.g_miss_num,
      old_id                         okc_k_articles_b.old_id%TYPE
                                                        := okc_api.g_miss_num,
      document_type                  okc_k_articles_b.document_type%TYPE
                                                       := okc_api.g_miss_char,
      document_id                    okc_k_articles_b.document_id%TYPE
                                                        := okc_api.g_miss_num,
      source_flag                    okc_k_articles_b.source_flag%TYPE
                                                       := okc_api.g_miss_char,
      mandatory_yn                   okc_k_articles_b.mandatory_yn%TYPE
                                                       := okc_api.g_miss_char,
      scn_id                         okc_k_articles_b.scn_id%TYPE
                                                        := okc_api.g_miss_num,
      label                          okc_k_articles_b.label%TYPE
                                                       := okc_api.g_miss_char,
      display_sequence               okc_k_articles_b.display_sequence%TYPE
                                                        := okc_api.g_miss_num,
      amendment_description          okc_k_articles_b.amendment_description%TYPE
                                                       := okc_api.g_miss_char,
      article_version_id             okc_k_articles_b.article_version_id%TYPE
                                                        := okc_api.g_miss_num,
      orig_system_reference_code     okc_k_articles_b.orig_system_reference_code%TYPE
                                                       := okc_api.g_miss_char,
      orig_system_reference_id1      okc_k_articles_b.orig_system_reference_id1%TYPE
                                                        := okc_api.g_miss_num,
      orig_system_reference_id2      okc_k_articles_b.orig_system_reference_id2%TYPE
                                                        := okc_api.g_miss_num,
      amendment_operation_code       okc_k_articles_b.amendment_operation_code%TYPE
                                                       := okc_api.g_miss_char,
      summary_amend_operation_code   okc_k_articles_b.summary_amend_operation_code%TYPE
                                                       := okc_api.g_miss_char,
      change_nonstd_yn               okc_k_articles_b.change_nonstd_yn%TYPE
                                                       := okc_api.g_miss_char,
      print_text_yn                  okc_k_articles_b.print_text_yn%TYPE
                                                       := okc_api.g_miss_char,
      ref_article_id                 okc_k_articles_b.ref_article_id%TYPE
                                                        := okc_api.g_miss_num,
      ref_article_version_id         okc_k_articles_b.ref_article_version_id%TYPE
                                                        := okc_api.g_miss_num,
      orig_article_id                okc_k_articles_b.orig_article_id%TYPE
                                                        := okc_api.g_miss_num,
      last_amended_by                okc_k_articles_b.last_amended_by%TYPE
                                                        := okc_api.g_miss_num,
      last_amendment_date            okc_k_articles_b.last_amendment_date%TYPE
                                                       := okc_api.g_miss_date,
      mandatory_rwa                  okc_k_articles_b.mandatory_rwa%TYPE
                                                       := okc_api.g_miss_char,
      status                         VARCHAR2 (1),
      errmsg                         VARCHAR2 (2500)
   );

   TYPE k_article_tbl_type IS TABLE OF k_article_rec_type
      INDEX BY PLS_INTEGER;

   TYPE deliverable_rec_type IS RECORD (
      deliverable_id                  okc_deliverables.deliverable_id%TYPE
                                                        := okc_api.g_miss_num,
      business_document_type          okc_deliverables.business_document_type%TYPE
                                                       := okc_api.g_miss_char,
      business_document_id            okc_deliverables.business_document_id%TYPE
                                                        := okc_api.g_miss_num,
      business_document_number        okc_deliverables.business_document_number%TYPE
                                                       := okc_api.g_miss_char,
      deliverable_type                okc_deliverables.deliverable_type%TYPE
                                                       := okc_api.g_miss_char,
      responsible_party               okc_deliverables.responsible_party%TYPE
                                                       := okc_api.g_miss_char,
      internal_party_contact_id       okc_deliverables.internal_party_contact_id%TYPE
                                                        := okc_api.g_miss_num,
      external_party_contact_id       okc_deliverables.external_party_contact_id%TYPE
                                                        := okc_api.g_miss_num,
      deliverable_name                okc_deliverables.deliverable_name%TYPE
                                                       := okc_api.g_miss_char,
      description                     okc_deliverables.description%TYPE
                                                       := okc_api.g_miss_char,
      comments                        okc_deliverables.comments%TYPE
                                                       := okc_api.g_miss_char,
      display_sequence                okc_deliverables.display_sequence%TYPE
                                                        := okc_api.g_miss_num,
      fixed_due_date_yn               okc_deliverables.fixed_due_date_yn%TYPE
                                                       := okc_api.g_miss_char,
      actual_due_date                 okc_deliverables.actual_due_date%TYPE
                                                       := okc_api.g_miss_date,
      print_due_date_msg_name         okc_deliverables.print_due_date_msg_name%TYPE
                                                       := okc_api.g_miss_char,
      recurring_yn                    okc_deliverables.recurring_yn%TYPE
                                                       := okc_api.g_miss_char,
      notify_prior_due_date_value     okc_deliverables.notify_prior_due_date_value%TYPE
                                                        := okc_api.g_miss_num,
      notify_prior_due_date_uom       okc_deliverables.notify_prior_due_date_uom%TYPE
                                                       := okc_api.g_miss_char,
      notify_prior_due_date_yn        okc_deliverables.notify_prior_due_date_yn%TYPE
                                                       := okc_api.g_miss_char,
      notify_completed_yn             okc_deliverables.notify_completed_yn%TYPE
                                                       := okc_api.g_miss_char,
      notify_overdue_yn               okc_deliverables.notify_overdue_yn%TYPE
                                                       := okc_api.g_miss_char,
      notify_escalation_yn            okc_deliverables.notify_escalation_yn%TYPE
                                                       := okc_api.g_miss_char,
      notify_escalation_value         okc_deliverables.notify_escalation_value%TYPE
                                                        := okc_api.g_miss_num,
      notify_escalation_uom           okc_deliverables.notify_escalation_uom%TYPE
                                                       := okc_api.g_miss_char,
      escalation_assignee             okc_deliverables.escalation_assignee%TYPE
                                                        := okc_api.g_miss_num,
      amendment_operation             okc_deliverables.amendment_operation%TYPE
                                                       := okc_api.g_miss_char,
      prior_notification_id           okc_deliverables.prior_notification_id%TYPE
                                                        := okc_api.g_miss_num,
      amendment_notes                 okc_deliverables.amendment_notes%TYPE
                                                       := okc_api.g_miss_char,
      completed_notification_id       okc_deliverables.completed_notification_id%TYPE
                                                        := okc_api.g_miss_num,
      overdue_notification_id         okc_deliverables.overdue_notification_id%TYPE
                                                        := okc_api.g_miss_num,
      escalation_notification_id      okc_deliverables.escalation_notification_id%TYPE
                                                        := okc_api.g_miss_num,
      LANGUAGE                        okc_deliverables.LANGUAGE%TYPE
                                                       := okc_api.g_miss_char,
      original_deliverable_id         okc_deliverables.original_deliverable_id%TYPE
                                                        := okc_api.g_miss_num,
      requester_id                    okc_deliverables.requester_id%TYPE
                                                        := okc_api.g_miss_num,
      external_party_id               okc_deliverables.external_party_id%TYPE
                                                        := okc_api.g_miss_num,
      recurring_del_parent_id         okc_deliverables.recurring_del_parent_id%TYPE
                                                        := okc_api.g_miss_num,
      business_document_version       okc_deliverables.business_document_version%TYPE
                                                        := okc_api.g_miss_num,
      relative_st_date_duration       okc_deliverables.relative_st_date_duration%TYPE
                                                        := okc_api.g_miss_num,
      relative_st_date_uom            okc_deliverables.relative_st_date_uom%TYPE
                                                       := okc_api.g_miss_char,
      relative_st_date_event_id       okc_deliverables.relative_st_date_event_id%TYPE
                                                        := okc_api.g_miss_num,
      relative_end_date_duration      okc_deliverables.relative_end_date_duration%TYPE
                                                        := okc_api.g_miss_num,
      relative_end_date_uom           okc_deliverables.relative_end_date_uom%TYPE
                                                       := okc_api.g_miss_char,
      relative_end_date_event_id      okc_deliverables.relative_end_date_event_id%TYPE
                                                        := okc_api.g_miss_num,
      repeating_day_of_month          okc_deliverables.repeating_day_of_month%TYPE
                                                       := okc_api.g_miss_char,
      repeating_day_of_week           okc_deliverables.repeating_day_of_week%TYPE
                                                       := okc_api.g_miss_char,
      repeating_frequency_uom         okc_deliverables.repeating_frequency_uom%TYPE
                                                       := okc_api.g_miss_char,
      repeating_duration              okc_deliverables.repeating_duration%TYPE
                                                        := okc_api.g_miss_num,
      fixed_start_date                okc_deliverables.fixed_start_date%TYPE
                                                       := okc_api.g_miss_date,
      fixed_end_date                  okc_deliverables.fixed_end_date%TYPE
                                                       := okc_api.g_miss_date,
      manage_yn                       okc_deliverables.manage_yn%TYPE
                                                       := okc_api.g_miss_char,
      internal_party_id               okc_deliverables.internal_party_id%TYPE
                                                        := okc_api.g_miss_num,
      deliverable_status              okc_deliverables.deliverable_status%TYPE
                                                       := okc_api.g_miss_char,
      status_change_notes             okc_deliverables.status_change_notes%TYPE
                                                       := okc_api.g_miss_char,
      created_by                      NUMBER            := okc_api.g_miss_num,
      creation_date                   okc_deliverables.creation_date%TYPE
                                                       := okc_api.g_miss_date,
      last_updated_by                 NUMBER            := okc_api.g_miss_num,
      last_update_date                okc_deliverables.last_update_date%TYPE
                                                       := okc_api.g_miss_date,
      last_update_login               NUMBER            := okc_api.g_miss_num,
      object_version_number           NUMBER            := okc_api.g_miss_num,
      attribute_category              okc_deliverables.attribute_category%TYPE
                                                       := okc_api.g_miss_char,
      attribute1                      okc_deliverables.attribute1%TYPE
                                                       := okc_api.g_miss_char,
      attribute2                      okc_deliverables.attribute2%TYPE
                                                       := okc_api.g_miss_char,
      attribute3                      okc_deliverables.attribute3%TYPE
                                                       := okc_api.g_miss_char,
      attribute4                      okc_deliverables.attribute4%TYPE
                                                       := okc_api.g_miss_char,
      attribute5                      okc_deliverables.attribute5%TYPE
                                                       := okc_api.g_miss_char,
      attribute6                      okc_deliverables.attribute6%TYPE
                                                       := okc_api.g_miss_char,
      attribute7                      okc_deliverables.attribute7%TYPE
                                                       := okc_api.g_miss_char,
      attribute8                      okc_deliverables.attribute8%TYPE
                                                       := okc_api.g_miss_char,
      attribute9                      okc_deliverables.attribute9%TYPE
                                                       := okc_api.g_miss_char,
      attribute10                     okc_deliverables.attribute10%TYPE
                                                       := okc_api.g_miss_char,
      attribute11                     okc_deliverables.attribute11%TYPE
                                                       := okc_api.g_miss_char,
      attribute12                     okc_deliverables.attribute12%TYPE
                                                       := okc_api.g_miss_char,
      attribute13                     okc_deliverables.attribute13%TYPE
                                                       := okc_api.g_miss_char,
      attribute14                     okc_deliverables.attribute14%TYPE
                                                       := okc_api.g_miss_char,
      attribute15                     okc_deliverables.attribute15%TYPE
                                                       := okc_api.g_miss_char,
      disable_notifications_yn        okc_deliverables.disable_notifications_yn%TYPE
                                                       := okc_api.g_miss_char,
      last_amendment_date             okc_deliverables.last_amendment_date%TYPE
                                                       := okc_api.g_miss_date,
      business_document_line_id       okc_deliverables.business_document_line_id%TYPE
                                                        := okc_api.g_miss_num,
      external_party_site_id          okc_deliverables.external_party_site_id%TYPE
                                                        := okc_api.g_miss_num,
      start_event_date                okc_deliverables.start_event_date%TYPE
                                                       := okc_api.g_miss_date,
      end_event_date                  okc_deliverables.end_event_date%TYPE
                                                       := okc_api.g_miss_date,
      summary_amend_operation_code    okc_deliverables.summary_amend_operation_code%TYPE
                                                       := okc_api.g_miss_char,
      external_party_role             okc_deliverables.external_party_role%TYPE
                                                       := okc_api.g_miss_char,
      pay_hold_prior_due_date_yn      okc_deliverables.pay_hold_prior_due_date_yn%TYPE
                                                       := okc_api.g_miss_char,
      pay_hold_prior_due_date_value   okc_deliverables.pay_hold_prior_due_date_value%TYPE
                                                        := okc_api.g_miss_num,
      pay_hold_prior_due_date_uom     okc_deliverables.pay_hold_prior_due_date_uom%TYPE
                                                       := okc_api.g_miss_char,
      pay_hold_overdue_yn             okc_deliverables.pay_hold_overdue_yn%TYPE
                                                       := okc_api.g_miss_char,
      status                          VARCHAR2 (1),
      errmsg                          VARCHAR2 (2500)
   );

   TYPE deliverable_tbl_type IS TABLE OF deliverable_rec_type
      INDEX BY PLS_INTEGER;

   TYPE k_article_id_tbl_type IS TABLE OF NUMBER
      INDEX BY PLS_INTEGER;

   TYPE section_id_tbl_type IS TABLE OF NUMBER
      INDEX BY PLS_INTEGER;

   TYPE deliverable_id_tbl_type IS TABLE OF NUMBER
      INDEX BY PLS_INTEGER;

   PROCEDURE create_template (
      p_template_tbl   IN OUT NOCOPY   terms_template_tbl_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_tmpl_usage (
      p_template_id       IN NUMBER,
      p_tmpl_usage_tbl    IN OUT NOCOPY   tmpl_usage_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE update_tmpl_usage(
      p_template_id      IN NUMBER ,
      p_tmpl_usage_tbl   IN OUT NOCOPY   tmpl_usage_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE delete_tmpl_usage (
      p_template_id      IN NUMBER ,
      p_tmpl_usage_tbl   IN OUT NOCOPY   tmpl_usage_tbl_type,
      p_commit           IN VARCHAR2 := fnd_api.g_false
                                );

   PROCEDURE create_article (
      p_article_tbl   IN OUT NOCOPY   k_article_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_section (
      p_section_tbl   IN OUT NOCOPY   section_tbl_type,
      p_commit        IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_deliverable (
      p_deliverable_tbl   IN OUT NOCOPY   deliverable_tbl_type,
      p_commit            IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE create_template_revision (
      p_template_id         IN              NUMBER,
      p_copy_deliverables   IN              VARCHAR2 DEFAULT 'Y',
      p_commit              IN              VARCHAR2 := fnd_api.g_false,
      x_new_template_id     OUT NOCOPY      NUMBER,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER
   );

   PROCEDURE update_template (
      p_template_tbl   IN OUT NOCOPY   okc_imp_terms_templates_pvt.terms_template_tbl_type,
      p_commit         IN              VARCHAR2 := fnd_api.g_false
   );

   PROCEDURE delete_articles (
      p_template_id        IN              NUMBER,
      p_k_article_id_tbl   IN              k_article_id_tbl_type,
      p_commit             IN              VARCHAR2 := fnd_api.g_false,
      x_k_article_id_tbl   OUT NOCOPY      k_article_id_tbl_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_data           OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_sections (
      p_template_id      IN              NUMBER,
      p_section_id_tbl   IN              section_id_tbl_type,
      p_commit           IN              VARCHAR2 := fnd_api.g_false,
      x_section_id_tbl   OUT NOCOPY      section_id_tbl_type,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_data         OUT NOCOPY      VARCHAR2
   );

   PROCEDURE delete_deliverables (
      p_template_id          IN              NUMBER,
      p_deliverable_id_tbl   IN              deliverable_id_tbl_type,
      p_commit               IN              VARCHAR2 := fnd_api.g_false,
      x_deliverable_id_tbl   OUT NOCOPY      deliverable_id_tbl_type,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2
   );
END okc_imp_terms_templates_pvt;

/
