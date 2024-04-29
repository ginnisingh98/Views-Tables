--------------------------------------------------------
--  DDL for Package INV_CUST_CALC_EXP_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CUST_CALC_EXP_DATE" AUTHID CURRENT_USER AS
/* $Header: INVCCEDS.pls 120.0.12000000.1 2007/04/02 09:12:05 cmsops noship $ */

PROCEDURE get_custom_lot_expiration_date
  ( p_mtli_lot_rec        IN  MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE
   ,p_mti_trx_rec	        IN  MTL_TRANSACTIONS_INTERFACE%ROWTYPE
   ,p_mtlt_lot_rec        IN  MTL_TRANSACTION_LOTS_TEMP%ROWTYPE
   ,p_mmtt_trx_rec	     IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
   ,p_table		           IN  NUMBER
   ,x_lot_expiration_date OUT NOCOPY DATE
   ,x_return_status       OUT NOCOPY VARCHAR2
  );
END INV_CUST_CALC_EXP_DATE;

 

/
