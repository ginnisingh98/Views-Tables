--------------------------------------------------------
--  DDL for Package CSE_IPA_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_IPA_TRANS_PKG" AUTHID CURRENT_USER AS
/*  $Header: CSEIPATS.pls 120.7 2006/09/11 23:07:13 brmanesh noship $ */

 G_API_NAME CONSTANT    VARCHAR2(30) := 'CSE_IPA_TRANS_PKG';

 TYPE nl_pa_interface_rec_type IS RECORD (
   transaction_source               varchar2(30),
   batch_name                       varchar2(50),
   expenditure_ending_date          date,
   employee_number                  varchar2(30),
   organization_name                VARCHAR2(240),
   expenditure_item_date            date,
   project_number                   varchar2(100),
   task_number                      varchar2(100),
   expenditure_type                 varchar2(150),
   non_labor_resource               varchar2(150),
   non_labor_resource_org_name      varchar2(60),
   quantity                         number,
   raw_cost                         number,
   expenditure_comment              varchar2(240),
   transaction_status_code          varchar2(2),
   transaction_rejection_code       varchar2(30),
   expenditure_id                   number,
   orig_transaction_reference       varchar2(30),
   attribute_category               varchar2(30),
   attribute1                       varchar2(150),
   attribute2                       varchar2(150),
   attribute3                       varchar2(150),
   attribute4                       varchar2(150),
   attribute5                       varchar2(150),
   attribute6                       varchar2(150),
   attribute7                       varchar2(150),
   attribute8                       varchar2(150),
   attribute9                       varchar2(150),
   attribute10                      varchar2(150),
   raw_cost_rate                    number,
   interface_id                     number,
   unmatched_negative_txn_flag      varchar2(1),
   expenditure_item_id              number,
   org_id                           number,
   dr_code_combination_id           number,
   cr_code_combination_id           number,
   cdl_system_reference1            varchar2(30),
   cdl_system_reference2            varchar2(30),
   cdl_system_reference3            varchar2(30),
   cdl_system_reference4            varchar2(30),
   cdl_system_reference5            varchar2(30),
   gl_date                          date,
   burdened_cost                    number,
   burdened_cost_rate               number,
   system_linkage                   varchar2(30),
   txn_interface_id                 number,
   user_transaction_source          varchar2(80),
   created_by                       number,
   creation_date                    date,
   last_updated_by                  number,
   last_update_date                 date,
   receipt_currency_amount          number,
   receipt_currency_code            varchar2(15),
   receipt_exchange_rate            number,
   denom_currency_code              varchar2(15),
   denom_raw_cost                   number,
   denom_burdened_cost              number,
   acct_rate_date                   date,
   acct_rate_type                   varchar2(30),
   acct_exchange_rate               number,
   acct_raw_cost                    number,
   acct_burdened_cost               number,
   acct_exchange_rounding_limit     number,
   project_currency_code            varchar2(15),
   project_rate_date                date,
   project_rate_type                varchar2(30),
   project_exchange_rate            number,
   orig_exp_txn_reference1          varchar2(60),
   orig_exp_txn_reference2          varchar2(60),
   orig_exp_txn_reference3          varchar2(60),
   orig_user_exp_txn_reference      varchar2(60),
   vendor_number                    varchar2(30),
   override_to_organization_name    varchar2(60),
   reversed_orig_txn_reference      varchar2(30),
   billable_flag                    varchar2(1),
   person_business_group_name       varchar2(60),
   net_zero_adjustment_flag         varchar2(1),
   adjusted_expenditure_item_id     number,
   organization_id                  number,
   inventory_item_id                number,
   po_number                        varchar2(20),
   po_header_id                     number,
   po_line_num                      number,
   po_line_id                       number,
   vendor_id                        number,
   project_id                       number,
   task_id                          number,
   document_type                    varchar2(30),
   document_distribution_type       varchar2(30));

  TYPE NL_PA_Interface_Tbl_TYPE IS TABLE OF NL_PA_Interface_Rec_TYPE INDEX BY BINARY_INTEGER;

  PROCEDURE Populate_PA_Interface(
    P_NL_PA_Interface_Tbl  IN NL_PA_Interface_Tbl_TYPE,
    x_Return_Status           OUT NOCOPY VARCHAR2,
    x_Error_Message           OUT NOCOPY VARCHAR2);

  PROCEDURE get_fa_asset_category (
    p_item_id              IN     NUMBER,
    p_inv_master_org_id    IN     NUMBER,
    p_transaction_id       IN     NUMBER,
    x_asset_category_id       OUT NOCOPY NUMBER,
    x_asset_category          OUT NOCOPY VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_error_message           OUT NOCOPY VARCHAR2);

  PROCEDURE get_fa_location_segment (
    p_fa_location_id      IN     NUMBER,
    p_transaction_id      IN     NUMBER,
    x_fa_location            OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_error_message          OUT NOCOPY VARCHAR2);

  PROCEDURE get_product_name (
    p_project_id          IN     NUMBER,
    p_transaction_id      IN     NUMBER,
    x_product_name           OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_error_message          OUT NOCOPY VARCHAR2);

  PROCEDURE get_grouping_attribute(
    p_item_id             IN     NUMBER,
    p_organization_id     IN     NUMBER,
    p_project_id          IN     NUMBER,
    p_fa_location_id      IN     NUMBER,
    p_transaction_id      IN     NUMBER,
    p_org_id              IN     NUMBER,
    x_attribute8             OUT NOCOPY VARCHAR2,
    x_attribute9             OUT NOCOPY VARCHAR2,
    x_attribute10            OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_error_message          OUT NOCOPY VARCHAR2);

END CSE_IPA_TRANS_PKG;

 

/
