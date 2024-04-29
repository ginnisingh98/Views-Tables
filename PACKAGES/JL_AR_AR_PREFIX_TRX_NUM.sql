--------------------------------------------------------
--  DDL for Package JL_AR_AR_PREFIX_TRX_NUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_AR_PREFIX_TRX_NUM" AUTHID CURRENT_USER AS
/*$Header: jlarruts.pls 115.3 2002/11/21 01:59:50 vsidhart ship $*/

PROCEDURE update_trx_number_date (
  p_batch_source_id           IN     ra_customer_trx_all.batch_source_id%TYPE,
  p_trx_number                IN OUT NOCOPY ra_customer_trx_all.trx_number%TYPE,
  p_trx_date                  IN OUT NOCOPY ra_customer_trx_all.trx_date%TYPE );

END JL_AR_AR_PREFIX_TRX_NUM;

 

/
