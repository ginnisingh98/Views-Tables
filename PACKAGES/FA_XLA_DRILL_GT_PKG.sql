--------------------------------------------------------
--  DDL for Package FA_XLA_DRILL_GT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_DRILL_GT_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXLAGTS.pls 120.0.12010000.3 2009/07/19 08:29:37 glchen ship $   */

/*=========================================================================+
 | Function Name:                                                          |
 |    load_trx_gt                                                          |
 |                                                                         |
 | Description:                                                            |
 |    This function will insert the transaction_header_id into the GT table|
 |    so that the inquiry view fa_ael_sl_v returns correct data.           |
 |                                                                         |
 +=========================================================================*/
FUNCTION load_trx_gt(
   p_transaction_header_id       NUMBER,
   p_book_type_code              VARCHAR2
) return BOOLEAN;


END FA_XLA_DRILL_GT_PKG;

/
