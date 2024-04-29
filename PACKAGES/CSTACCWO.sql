--------------------------------------------------------
--  DDL for Package CSTACCWO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTACCWO" AUTHID CURRENT_USER AS
/* $Header: CSTACCWS.pls 115.4 2003/10/15 23:29:20 vtkamath ship $*/

PROCEDURE Insert_Row(
        x_write_off_id             number,
        x_last_update_date         date,
        x_last_updated_by          number,
        x_creation_date            date,
        x_created_by               number,
        x_last_update_login        number,
        x_write_off_date           date,
        x_transaction_organization_id     number,
        x_item_master_organization_id     number,
        x_accrual_account_id       number,
        x_accrual_code             varchar2,
        x_transaction_date         date,
        x_transaction_source_code  varchar2,
        x_request_id               number,
        x_program_application_id   number,
        x_program_id               number,
        x_program_update_date      date,
        x_period_name              varchar2,
        x_po_transaction_type      varchar2,
        x_invoice_num              varchar2,
        x_receipt_num              varchar2,
        x_po_transaction_id        number,
        x_inv_transaction_id       number,
        x_inv_transaction_type_id  number,
        x_wip_transaction_id       number,
        x_wip_transaction_type_id  number,
        x_inventory_item_id        number,
        x_po_unit_of_measure       varchar2,
        x_primary_unit_of_measure  varchar2,
        x_transaction_quantity     number,
        x_net_po_line_quantity     number,
        x_po_header_id             number,
        x_po_num                   varchar2,
        x_po_line_num              number,
        x_po_line_id               number,
        x_po_distribution_id       number,
        x_vendor_id                number,
        x_vendor_name              varchar2,
        x_transaction_unit_price   number,
        x_invoice_id               number,
        x_invoice_line_num         number,
        x_avg_receipt_price        number,
        x_transaction_amount       number,
        x_adjustment_transaction   number,
        x_line_match_order         number,
        x_reason_id                number,
        x_comments                 varchar2,
        x_destination_type_code    varchar2,
        x_write_off_code           varchar2,
        x_legal_entity_id          number,
        x_cost_group_id            number,
        x_cost_type_id             number,
        x_period_id                number);





END CSTACCWO;


 

/
