--------------------------------------------------------
--  DDL for Package OZF_SD_REQUEST_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SD_REQUEST_HEADER_PKG" AUTHID CURRENT_USER AS
/* $Header: ozftshds.pls 120.2.12010000.2 2009/02/04 09:23:40 bkunjan ship $ */

PROCEDURE Insert_Row(
    p_request_header_id             NUMBER,
    p_object_version_NUMBER         NUMBER,
    p_last_update_date              DATE,
    p_last_updated_by               NUMBER,
    p_creation_date                 DATE,
    p_created_by                    NUMBER,
    p_last_update_login             NUMBER,
    p_request_id                    NUMBER,
    p_program_application_id        NUMBER,
    p_program_update_date           DATE,
    p_program_id                    NUMBER,
    p_created_from                  VARCHAR2,
    p_request_number                VARCHAR2,
    p_request_class                 VARCHAR2,
    p_offer_type                    VARCHAR2,
    p_offer_id                      NUMBER,
    p_root_request_header_id        NUMBER,
    p_linked_request_header_id      NUMBER,
    p_request_start_date            DATE,
    p_request_end_date              DATE,
    p_user_status_id                VARCHAR2,
    p_request_outcome               VARCHAR2,
    p_decline_reason_code           VARCHAR2,
    p_return_reason_code            VARCHAR2,
    p_request_currency_code         VARCHAR2,
    p_authorization_number          VARCHAR2,
    p_sd_requested_budget_amount    NUMBER,
    p_sd_approved_budget_amount     NUMBER,
    p_attribute_category            VARCHAR2,
    p_attribute1                    VARCHAR2,
    p_attribute2                    VARCHAR2,
    p_attribute3                    VARCHAR2,
    p_attribute4                    VARCHAR2,
    p_attribute5                    VARCHAR2,
    p_attribute6                    VARCHAR2,
    p_attribute7                    VARCHAR2,
    p_attribute8                    VARCHAR2,
    p_attribute9                    VARCHAR2,
    p_attribute10                   VARCHAR2,
    p_attribute11                   VARCHAR2,
    p_attribute12                   VARCHAR2,
    p_attribute13                   VARCHAR2,
    p_attribute14                   VARCHAR2,
    p_attribute15                   VARCHAR2,
    p_supplier_id                   NUMBER,
    p_supplier_site_id              NUMBER,
    p_supplier_contact_id           NUMBER,
    p_internal_submission_date      DATE,
    p_assignee_response_by_date      DATE,
    p_assignee_response_date         DATE,
    p_submtd_by_for_supp_appr       VARCHAR2,
    p_supplier_response_by_date     DATE,
    p_supplier_response_date        DATE,
    p_supplier_submission_date      DATE,
    p_requestor_id                  NUMBER,
    p_supplier_quote_number         VARCHAR2,
    p_internal_order_number         NUMBER,
    p_sales_order_currency          VARCHAR2,
    p_request_source                VARCHAR2,
    p_assignee_resource_id           NUMBER,
    p_org_id                        NUMBER,
    p_security_group_id             NUMBER,
    p_accrual_type                  VARCHAR2,
    p_cust_account_id               VARCHAR2,
    p_supplier_email                VARCHAR2,
    p_supplier_phone                VARCHAR2,
    p_request_type_setup_id         NUMBER,
    p_request_basis                 VARCHAR2,
    p_supplier_contact_name         VARCHAR2 --//Bugfix 7822442
    );

PROCEDURE Update_Row(
    p_request_header_id	            NUMBER,
    p_object_version_NUMBER         NUMBER,
    p_last_update_date              DATE,
    p_last_updated_by               NUMBER,
    p_last_update_login             NUMBER,
    p_request_id                    NUMBER,
    p_program_application_id        NUMBER,
    p_program_update_date           DATE,
    p_program_id                    NUMBER,
    p_created_from                  VARCHAR2,
    p_request_number                VARCHAR2,
    p_request_class                 VARCHAR2,
    p_offer_type                    VARCHAR2,
    p_offer_id                      NUMBER,
    p_root_request_header_id        NUMBER,
    p_linked_request_header_id      NUMBER,
    p_request_start_date            DATE,
    p_request_end_date              DATE,
    p_user_status_id                VARCHAR2,
    p_request_outcome               VARCHAR2,
    p_decline_reason_code           VARCHAR2,
    p_return_reason_code            VARCHAR2,
    p_request_currency_code         VARCHAR2,
    p_authorization_number          VARCHAR2,
    p_sd_requested_budget_amount    NUMBER,
    p_sd_approved_budget_amount     NUMBER,
    p_attribute_category            VARCHAR2,
    p_attribute1                    VARCHAR2,
    p_attribute2                    VARCHAR2,
    p_attribute3                    VARCHAR2,
    p_attribute4                    VARCHAR2,
    p_attribute5                    VARCHAR2,
    p_attribute6                    VARCHAR2,
    p_attribute7                    VARCHAR2,
    p_attribute8                    VARCHAR2,
    p_attribute9                    VARCHAR2,
    p_attribute10                   VARCHAR2,
    p_attribute11                   VARCHAR2,
    p_attribute12                   VARCHAR2,
    p_attribute13                   VARCHAR2,
    p_attribute14                   VARCHAR2,
    p_attribute15                   VARCHAR2,
    p_supplier_id                   NUMBER,
    p_supplier_site_id              NUMBER,
    p_supplier_contact_id           NUMBER,
    p_internal_submission_date      DATE,
    p_assignee_response_by_date     DATE,
    p_assignee_response_date        DATE,
    p_submtd_by_for_supp_appr       VARCHAR2,
    p_supplier_response_by_date     DATE,
    p_supplier_response_date        DATE,
    p_supplier_submission_date      DATE,
    p_requestor_id                  NUMBER,
    p_supplier_quote_number         VARCHAR2,
    p_internal_order_number         NUMBER,
    p_sales_order_currency          VARCHAR2,
    p_request_source                VARCHAR2,
    p_assignee_resource_id          NUMBER,
    p_org_id                        NUMBER,
    p_security_group_id             NUMBER,
    p_accrual_type                  VARCHAR2,
    p_cust_account_id               VARCHAR2,
    p_supplier_email                VARCHAR2,
    p_supplier_phone                VARCHAR2,
    p_request_type_setup_id         NUMBER,
    p_request_basis                 VARCHAR2,
    p_supplier_contact_name         VARCHAR2 --//Bugfix 7822442
    );
END OZF_SD_REQUEST_HEADER_PKG;

/