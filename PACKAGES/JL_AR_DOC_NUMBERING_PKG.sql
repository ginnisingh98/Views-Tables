--------------------------------------------------------
--  DDL for Package JL_AR_DOC_NUMBERING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_DOC_NUMBERING_PKG" AUTHID CURRENT_USER as
/* $Header: jlarrdns.pls 120.6 2005/11/18 02:11:20 appradha ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

FUNCTION validate_trx_type (p_batch_source_id IN NUMBER,
                            p_trx_type IN NUMBER,
                            p_invoice_class IN VARCHAR2,
                            p_document_letter IN VARCHAR2,
                            p_interface_line_id IN NUMBER,
                            p_created_from IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION validate_four_digit (p_batch_source_id   IN NUMBER,
                              p_interface_line_id IN NUMBER,
                              p_created_from      IN VARCHAR2,
                              p_inventory_item_id IN NUMBER,
                              p_memo_line_id      IN NUMBER,
--added by venkat 12dec98 - start
                              p_so_org_id            IN VARCHAR2)
--added by venkat 12dec98 - end
RETURN  VARCHAR2;

FUNCTION validate_document_letter
                   (p_batch_source_id    IN NUMBER,
                    p_interface_line_id  IN NUMBER,
                    p_created_from       IN VARCHAR2,
                    p_ship_to_address_id IN NUMBER,
                    p_document_letter    IN OUT NOCOPY VARCHAR2,
--added by venkat 12dec98 - start
                    p_so_org_id             IN VARCHAR2)
--added by venkat 12dec98 - end
RETURN VARCHAR2;

FUNCTION get_imported_batch_source (p_batch_source_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_batch_source_type (p_batch_source_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION validate_transaction_date
                      (p_trx_date IN DATE,
                       p_batch_source_id IN NUMBER)
RETURN VARCHAR2;


FUNCTION validate_interface_lines ( p_request_id IN NUMBER
                                  , p_interface_line_id IN NUMBER
                                  , p_trx_type IN NUMBER
                                  , p_inventory_item_id IN NUMBER
                                  , p_memo_line_id IN NUMBER
                                  , p_trx_date IN DATE
                                  , p_orig_system_address_id IN NUMBER
--added by venkat 12dec98 - start
                                  , p_so_org_id IN VARCHAR2)
--added by venkat 12dec98 - end
RETURN BOOLEAN;

FUNCTION get_printing_count (p_cust_trx_id IN VARCHAR2)
RETURN NUMBER;

FUNCTION get_branch_number_method RETURN VARCHAR2;

FUNCTION get_flex_delimiter RETURN VARCHAR2;

FUNCTION get_flex_value(p_concat_segs IN VARCHAR2, p_flex_delimiter IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_num_bar_code(p_batch_source_id IN NUMBER, p_trx_type_id IN NUMBER, p_legal_entity_id IN NUMBER)  RETURN VARCHAR2;

FUNCTION get_point_of_sale_code(p_inv_org_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_doc_letter(p_batch_source_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION get_branch_number(p_batch_source_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION get_last_trx_date(p_batch_source_id  IN NUMBER) RETURN DATE;

FUNCTION get_adv_days(p_batch_source_id  IN NUMBER) RETURN VARCHAR2;

FUNCTION get_hr_branch_number(p_location_id  IN NUMBER) RETURN VARCHAR2;

-- Added by venkat 04-Aug-1999
FUNCTION trx_num_gen(p_batch_source_id IN NUMBER,
                     p_trx_number      IN VARCHAR2) RETURN VARCHAR2;


END JL_AR_DOC_NUMBERING_PKG;

 

/
