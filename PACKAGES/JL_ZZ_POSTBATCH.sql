--------------------------------------------------------
--  DDL for Package JL_ZZ_POSTBATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_POSTBATCH" AUTHID CURRENT_USER AS
/*$Header: jlarrpbs.pls 115.0 99/07/16 02:59:52 porting ship $*/

PROCEDURE populate_gdfs (
  p_cash_receipt_id           IN     ar_cash_receipts_all.cash_receipt_id%TYPE,
  p_batch_id                  IN     ar_batches.batch_id%TYPE );

END JL_ZZ_POSTBATCH;

 

/
