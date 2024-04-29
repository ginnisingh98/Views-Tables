--------------------------------------------------------
--  DDL for Package Body FA_XLA_DRILL_GT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_XLA_DRILL_GT_PKG" AS
/* $Header: FAXLAGTB.pls 120.0.12010000.3 2009/07/19 08:28:59 glchen ship $   */

/*=========================================================================+
 | Function Name:                                                          |
 |    load_trx_gt                                                  |
 |                                                                         |
 | Description:                                                            |
 |    This function will insert the transaction_header_id into the GT table|
 |    so that the inquiry view fa_ael_sl_v returns correct data.           |
 |                                                                         |
 +=========================================================================*/
FUNCTION load_trx_gt(
   p_transaction_header_id       NUMBER,
   p_book_type_code              VARCHAR2
) return BOOLEAN IS

BEGIN

   insert into
   fa_inquiry_trx_gt (transaction_header_id, book_type_code)
   values(p_transaction_header_id, p_book_type_code);

   return TRUE;

EXCEPTION

   when others then
      return FALSE;
END load_trx_gt;


END FA_XLA_DRILL_GT_PKG;

/
