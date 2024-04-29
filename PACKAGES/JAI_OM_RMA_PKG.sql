--------------------------------------------------------
--  DDL for Package JAI_OM_RMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_OM_RMA_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_om_rma.pls 120.2 2006/02/17 12:19:54 hjujjuru ship $ */

procedure default_taxes_onto_line
(
  p_header_id                       NUMBER,
  p_line_id                         NUMBER,
  p_inventory_item_id               NUMBER,
  p_warehouse_id                    NUMBER,
  --p_context                         VARCHAR2,
  p_new_reference_line_id           NUMBER,
  p_new_ref_customer_trx_line_id    NUMBER,
  p_line_number                     NUMBER,
  /* Commented for DFF Elimination by Ramananda */
  -- p_old_attribute2                  VARCHAR2,
  --p_old_attribute3                  VARCHAR2,
  --p_old_attribute4                  VARCHAR2,
  --p_old_attribute5                  VARCHAR2,
  --p_old_attribute14                 VARCHAR2,
  --p_attribute2                      VARCHAR2,
  --p_attribute3                      VARCHAR2,
  --p_attribute4                      VARCHAR2,
  --p_attribute5                      VARCHAR2,
  --p_attribute14                     VARCHAR2,
  --p_attribute15                     VARCHAR2,
  p_old_return_context                VARCHAR2,
  pn_delivery_detail_id               number,
  pv_allow_excise_flag                varchar2,
  pv_allow_sales_flag                 varchar2,
  pn_excise_duty_per_unit           number,
  pn_excise_duty_rate               number,
  p_old_reference_line_id           NUMBER,
  p_old_ref_customer_trx_line_id     NUMBER,
  p_old_ordered_quantity            NUMBER,
  p_old_cancelled_quantity          NUMBER,
  p_new_return_context              VARCHAR2,
  p_new_ordered_quantity             NUMBER,
  p_new_cancelled_quantity          NUMBER,
  p_uom                             VARCHAR2,
  p_old_selling_price               NUMBER,
  p_new_selling_price               NUMBER, -- added by sriram Bug
  p_item_type_code                  VARCHAR2,
  p_serviced_quantity               NUMBER,
  p_creation_date                   DATE,
  p_created_by                      NUMBER,
  p_last_update_date                DATE,
  p_last_updated_by                 NUMBER,
  p_last_update_login               NUMBER,
  p_source_document_type_id         NUMBER,
  p_line_category_code              OE_ORDER_LINES_ALL.LINE_CATEGORY_CODE%TYPE
);

FUNCTION cal_excise_duty
( p_rma_line_id  IN NUMBER,
  p_transaction_quantity  IN NUMBER
) RETURN NUMBER ;


END jai_om_rma_pkg;
 

/
