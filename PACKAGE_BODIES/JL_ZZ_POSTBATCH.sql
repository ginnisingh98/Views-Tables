--------------------------------------------------------
--  DDL for Package Body JL_ZZ_POSTBATCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_POSTBATCH" as
/*$Header: jlarrpbb.pls 115.0 99/07/16 02:59:47 porting ship $*/

PROCEDURE populate_gdfs (
  p_cash_receipt_id           IN     ar_cash_receipts_all.cash_receipt_id%TYPE,
  p_batch_id                  IN     ar_batches.batch_id%TYPE )
IS
BEGIN

  IF fnd_profile.value ('JGZZ_COUNTRY_CODE') = 'AR' THEN

    UPDATE ar_cash_receipts
    SET    global_attribute1 = (SELECT name
                                FROM ar_batches
                                WHERE batch_id = p_batch_id),
           global_attribute_category = 'JL.AR.ARXRWMAI.RGW_FOLDER'
    WHERE  cash_receipt_id = p_cash_receipt_id;

  END IF;

END populate_gdfs;

END JL_ZZ_POSTBATCH;


/
