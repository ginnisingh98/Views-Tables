--------------------------------------------------------
--  DDL for Package OKC_TERMS_MIGRATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_MIGRATE_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGTMGS.pls 120.0.12010000.5 2011/12/09 13:40:27 serukull noship $ */

/*
 */

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

Procedure Create_Contract_Terms
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_contract_source         IN   VARCHAR2,
				    p_contract_tmpl_id        IN   Number default NULL,
				    p_contract_tmpl_name      IN   Varchar2 default NULL,
				    p_attachment_file_loc     IN   Varchar2 default NULL,
				    p_attachment_file_name    IN   Varchar2 default NULL,
				    p_attachment_file_desc    IN   Varchar2 default NULL
                        );

Procedure Add_Contract_Doc
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_contract_category       IN   Varchar2,
				    p_contract_doc_type       IN   Varchar2,
				    p_url                     IN   varchar2,
				    p_attachment_file_loc     IN   Varchar2 ,
				    p_attachment_file_name    IN   Varchar2 ,
				    p_description             IN   Varchar2
                        );

Procedure Add_Standard_Clause
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_section_id              IN   NUMBER DEFAULT null,
				    p_section_name            IN   Varchar2 default null,
				    p_clause_version_id       IN   Number default null,
				    p_clause_title            IN   Varchar2 default null,
				    p_clause_version_num      IN   Number default null,
				    p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
				    x_Contract_clause_id      OUT  NOCOPY Number,
            p_display_sequence  IN NUMBER DEFAULT NULL,
            p_mode                         IN VARCHAR2 := 'NORMAL' -- Other value 'AMEND'
);

Procedure Add_Non_Standard_Clause
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_section_id              IN   NUMBER DEFAULT null,
				    p_section_name            IN   Varchar2 default null,
				    p_clause_title            IN   Varchar2,
				    p_clause_text             IN   CLOB DEFAULT null,
				    p_clause_type             IN   Varchar2 default 'OTHER',
				    p_clause_disp_name        IN   Varchar2 default null,
				    p_clause_description      IN   Varchar2 default null,
				    p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
            p_edited_in_word             IN VARCHAR2 DEFAULT 'N',
 	          p_clause_text_in_word       IN BLOB DEFAULT NULL,
				    x_contract_clause_id      OUT  NOCOPY Number,
				    x_clause_version_id       OUT  NOCOPY Number
                        );

Procedure Add_Section
                      ( p_api_version             IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	               OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number,
				    p_document_type           IN   Varchar2,
				    p_document_id             IN   Number,
				    p_section_source          IN   Varchar2,
				    p_section_name            IN   Varchar2,
				    p_section_description     IN   Varchar2 default null,
				    p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
				    x_section_id              OUT  NOCOPY Number
                        );

PROCEDURE Apps_Initialize(p_api_version      IN  NUMBER,
                          p_user_name        IN VARCHAR2,
                          p_resp_name  IN VARCHAR2,
                          p_org_id     IN number);

FUNCTION get_valueset_id (
    p_value_set_id    IN NUMBER,
    p_var_value       IN VARCHAR2,
    p_validation_type        IN VARCHAR2) RETURN NUMBER ;

PROCEDURE update_variable_values(p_api_version      IN  NUMBER,
                                 p_doc_type         IN  VARCHAR2,
                                 p_doc_id           IN  NUMBER,
                                 p_k_clause_id        IN  NUMBER DEFAULT NULL,
                                 p_clause_title      IN  VARCHAR2 DEFAULT NULL,
                                 p_clause_version   IN  NUMBER DEFAULT NULL,
                                 p_variable_name    IN VARCHAR2,
                                 p_variable_value   IN VARCHAR2,
                                 p_override_global_yn IN VARCHAR2,
                                 p_global_variable_value  IN VARCHAR2 := NULL,
                                 p_init_msg_list		IN   Varchar2 default FND_API.G_FALSE,
                                 p_commit	          IN   Varchar2 default FND_API.G_FALSE,
                                 x_return_status	  OUT  NOCOPY Varchar2,
                                 x_msg_data	        OUT  NOCOPY Varchar2,
                                 x_msg_count	      OUT  NOCOPY Number
                               );

PROCEDURE Create_template_usages(p_api_version      IN  NUMBER,
                                 p_document_type         IN  VARCHAR2,
                                 p_document_id           IN  NUMBER,
                                 p_contract_source         IN   VARCHAR2,
				                         p_contract_tmpl_id        IN   Number := NULL,
				                         p_contract_tmpl_name      IN   Varchar2 default NULL,
                                 p_authoring_party_code   IN VARCHAR2 := NULL,
                                 p_autogen_deviations_flag IN VARCHAR2 := NULL,
                                 p_lock_terms_flag        IN VARCHAR2 := NULL,
                                 p_enable_reporting_flag  IN VARCHAR2 := NULL,
                                 p_approval_abstract_text IN CLOB := NULL,
                                 p_locked_by_user_name   IN VARCHAR2 DEFAULT NULL,
                                 p_legal_contact_name IN VARCHAR2 DEFAULT NULL,
                                 p_contract_admin_name IN VARCHAR2 DEFAULT NULL,
                                 p_primary_template    IN VARCHAR2 DEFAULT 'Y',
                                 p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                                 p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                                 x_return_status	          OUT  NOCOPY Varchar2,
                                 x_msg_data	               OUT  NOCOPY Varchar2,
                                 x_msg_count	          OUT  NOCOPY Number);

PROCEDURE create_deliverables(p_api_version      IN  NUMBER,
                                 p_document_type         IN  VARCHAR2,
                                 p_document_id           IN  NUMBER,
                                 p_deliverable_rec       IN   deliverable_rec_type,
                                 p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                                 p_commit	               IN   Varchar2 default FND_API.G_FALSE,
                                 x_return_status	          OUT  NOCOPY Varchar2,
                                 x_msg_data	               OUT  NOCOPY Varchar2,
                                 x_msg_count	          OUT  NOCOPY Number
                                 );

PROCEDURE remove_std_clause_from_doc(p_api_version             IN   Number,
                        p_init_msg_list		  IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	          IN   Varchar2 default FND_API.G_FALSE,
                        p_mode                    IN VARCHAR2 default'NORMAL',
            		p_document_type           IN   Varchar2,
             		p_document_id             IN   Number,
                        p_clause_version_id       IN   Number default null,
			p_clause_title            IN   Varchar2 default null,
			p_clause_version_num      IN   Number default null,
			p_renumber_terms          IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	          OUT  NOCOPY Varchar2,
                        x_msg_data	          OUT  NOCOPY Varchar2,
                        x_msg_count	          OUT  NOCOPY Number);

PROCEDURE remove_clause_id_from_doc(p_api_version    IN   Number,
                        p_init_msg_list		     IN   Varchar2 default FND_API.G_FALSE,
                        p_commit	             IN   Varchar2 default FND_API.G_FALSE,
                        p_mode                       IN VARCHAR2 default'NORMAL',
            		p_document_type              IN   Varchar2,
             		p_document_id                IN   Number,
                        p_clause_id                  IN   Number default null,
			p_renumber_terms             IN   Varchar2 default FND_API.G_FALSE,
                        x_return_status	             OUT  NOCOPY Varchar2,
                        x_msg_data	             OUT  NOCOPY Varchar2,
                         x_msg_count	             OUT  NOCOPY NUMBER
                        ,p_locking_enabled_yn IN VARCHAR2 DEFAULT 'N'
                        );

END OKC_TERMS_MIGRATE_GRP;

/
