--------------------------------------------------------
--  DDL for Package Body CSTACCWO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTACCWO" AS
/* $Header: CSTACCWB.pls 115.4 2003/10/15 23:31:27 vtkamath ship $*/
/*===========================================================================

   PROCEDURE NAME:	Insert_Row()

===========================================================================*/
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
        x_period_id                number) IS


  x_progress VARCHAR2(3) := NULL;


BEGIN

 x_progress := '020';

INSERT into cst_pac_accrual_write_offs
       (write_off_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        write_off_gl_date,
        transaction_organization_id,
        item_master_organization_id,
        accrual_account_id,
        accrual_code,
        transaction_date,
        transaction_source_code,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        period_name,
        po_transaction_type,
        invoice_num,
        receipt_num,
        po_transaction_id,
        inv_transaction_id,
        inv_transaction_type_id,
        wip_transaction_id,
        wip_transaction_type_id,
        inventory_item_id,
        po_unit_of_measure,
        primary_unit_of_measure,
        transaction_quantity,
        net_po_line_quantity,
        po_header_id,
        po_num,
        po_line_num,
        po_line_id,
        po_distribution_id,
        vendor_id,
        vendor_name,
        transaction_unit_price,
        invoice_id,
        invoice_line_num,
        avg_receipt_price,
        transaction_amount,
        Adjustment_transaction,
        line_match_order,
        reason_id,
        comments,
        destination_type_code,
        write_off_code,
        legal_entity_id,
        cost_group_id,
        cost_type_id,
        period_id)
VALUES
       (x_write_off_id,
        x_last_update_date,
        x_last_updated_by,
        x_creation_date,
        x_created_by,
        x_last_update_login,
        x_write_off_date,
        x_transaction_organization_id,
        x_item_master_organization_id,
        x_accrual_account_id,
        x_accrual_code,
        x_transaction_date,
        x_transaction_source_code,
        x_request_id,
        x_program_application_id,
        x_program_id,
        x_program_update_date,
        x_period_name,
        x_po_transaction_type,
        x_invoice_num,
        x_receipt_num,
        x_po_transaction_id,
        x_inv_transaction_id,
        x_inv_transaction_type_id,
        x_wip_transaction_id,
        x_wip_transaction_type_id,
        x_inventory_item_id,
        x_po_unit_of_measure,
        x_primary_unit_of_measure,
        x_transaction_quantity,
        x_net_po_line_quantity,
        x_po_header_id,
        x_po_num,
        x_po_line_num,
        x_po_line_id,
        x_po_distribution_id,
        x_vendor_id,
        x_vendor_name,
        x_transaction_unit_price,
        x_invoice_id,
        x_invoice_line_num,
        x_avg_receipt_price,
        x_transaction_amount,
        x_adjustment_transaction,
        x_line_match_order,
        x_reason_id,
        x_comments,
        x_destination_type_code,
        x_write_off_code,
        x_legal_entity_id,
        x_cost_group_id,
        x_cost_type_id,
        x_period_id);

  exception

           when others then
                po_message_s.sql_error('Insert_Row', X_progress, sqlcode);
                raise;

END Insert_Row;


END CSTACCWO;



/
