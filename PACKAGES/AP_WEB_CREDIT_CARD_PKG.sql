--------------------------------------------------------
--  DDL for Package AP_WEB_CREDIT_CARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CREDIT_CARD_PKG" AUTHID CURRENT_USER AS
/* $Header: apwccrds.pls 120.6.12010000.2 2009/08/04 13:11:51 meesubra ship $ */

/* Function introduced in OIE.J
   It returns 'Y' if a transaction has level2 data
   and expense tpye as 'HOTEL'.  Ideally, we should
   have a column in ap_credit_card_trxns_all table which
   should get populated during loading the transaciotn if
   level2 transaction is present.
*/
FUNCTION HAS_DETAILED_TRXN (p_trx_id IN VARCHAR2)
 RETURN VARCHAR2;

/* Introduced in R12 */
function create_iby_card(p_card_number IN VARCHAR2,
                          p_party_id    IN NUMBER,
                          p_exp_date    IN Date DEFAULT NULL
                          ) return number;

/* Introduced in R12 */
function get_card_id(p_card_number IN VARCHAR2,
                     p_card_program_id IN VARCHAR2 DEFAULT NULL,
                     p_party_id IN NUMBER DEFAULT NULL,
                     p_request_id IN VARCHAR2 DEFAULT NULL
                     ) return number;

/* Returns card_reference_id (IBY_CREDITCARD.instrid) */
FUNCTION get_card_reference_id(p_document_payable_id IN NUMBER) return NUMBER;

END AP_WEB_CREDIT_CARD_PKG;

/
