--------------------------------------------------------
--  DDL for Package IEX_DUNNINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DUNNINGS_PKG" AUTHID CURRENT_USER AS
/* $Header: iextduns.pls 120.4.12010000.4 2010/02/05 12:41:07 gnramasa ship $ */

     PROCEDURE insert_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_dunning_id                     IN OUT NOCOPY NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_request_id                       NUMBER
	, p_financial_charge                 NUMBER default null
        , p_letter_name                      VARCHAR2 default null
        , p_interest_amt                     NUMBER default null
        , p_dunning_plan_id                  NUMBER default null
        , p_contact_destination              varchar2 default null
        , p_contact_party_id                 NUMBER default null
	, p_delivery_status                  varchar2
        , p_parent_dunning_id                number
	, p_dunning_mode		     varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_confirmation_mode                varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_org_id                           number
	, p_ag_dn_xref_id                    number default null
	, p_correspondence_date              date   default trunc(sysdate)
     );

     PROCEDURE delete_row(
        p_dunning_id                      NUMBER
     );

     PROCEDURE update_row(
          p_rowid                            VARCHAR2
        , p_dunning_id                       NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_request_id                       NUMBER
	, p_financial_charge                 NUMBER default null
        , p_letter_name                      VARCHAR2 default null
        , p_interest_amt                     NUMBER default null
        , p_dunning_plan_id                  NUMBER default null
        , p_contact_destination              varchar2 default null
        , p_contact_party_id                 NUMBER default null
	, p_delivery_status                  varchar2
        , p_parent_dunning_id                number
	, p_dunning_mode		     varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_confirmation_mode                varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_ag_dn_xref_id                    number default null
	, p_correspondence_date              date default trunc(sysdate)
     );


     PROCEDURE lock_row(
          p_rowid                            VARCHAR2
        , p_dunning_id                       NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_financial_charge                 NUMBER default null
        , p_letter_name                      VARCHAR2 default null
        , p_interest_amt                     NUMBER default null
        , p_dunning_plan_id                  NUMBER default null
        , p_contact_destination              varchar2 default null
        , p_contact_party_id                 NUMBER default null
     );

PROCEDURE insert_Staged_Dunning_row(
          px_rowid                          IN OUT NOCOPY VARCHAR2
        , px_dunning_trx_id                 IN OUT NOCOPY NUMBER
        , p_dunning_id                       NUMBER
        , p_cust_trx_id                      NUMBER default null
        , p_payment_schedule_id              NUMBER
        , p_ag_dn_xref_id                    NUMBER
        , p_stage_number                     NUMBER default null
	, p_created_by                       NUMBER
	, p_creation_date                    DATE
	, p_last_updated_by                  NUMBER
        , p_last_update_date                 DATE
        , p_last_update_login                NUMBER
        , p_object_version_number	     NUMBER
     );

/*
     PROCEDURE update_Staged_Dunning_row(
          p_rowid                            VARCHAR2
        , p_dunning_id                       NUMBER
        , p_template_id                      NUMBER
        , p_callback_yn                      VARCHAR2
        , p_callback_date                    DATE
        , p_campaign_sched_id                NUMBER
        , p_status                           VARCHAR2
        , p_delinquency_id                   NUMBER
        , p_ffm_request_id                   NUMBER
        , p_xml_request_id                   NUMBER
        , p_xml_template_id                  NUMBER
        , p_object_id                        NUMBER
        , p_object_type                      VARCHAR2
        , p_dunning_object_id                NUMBER
        , p_dunning_level                    VARCHAR2
        , p_dunning_method                   VARCHAR2
        , p_amount_due_remaining             NUMBER
        , p_currency_code                    VARCHAR2
        , p_last_update_date                 DATE
        , p_last_updated_by                  NUMBER
        , p_creation_date                    DATE
        , p_created_by                       NUMBER
        , p_last_update_login                NUMBER
        , p_request_id                       NUMBER
	, p_financial_charge                 NUMBER default null
        , p_letter_name                      VARCHAR2 default null
        , p_interest_amt                     NUMBER default null
        , p_dunning_plan_id                  NUMBER default null
        , p_contact_destination              varchar2 default null
        , p_contact_party_id                 NUMBER default null
	, p_delivery_status                  varchar2
        , p_parent_dunning_id                number
	, p_dunning_mode		     varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_confirmation_mode                varchar2  -- added by gnramasa for bug 8489610 14-May-09
	, p_dunning_plan_line_id             number
     );

*/

END iex_dunnings_pkg;

/
