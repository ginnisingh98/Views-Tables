--------------------------------------------------------
--  DDL for Package Body INV_CUST_CALC_EXP_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CUST_CALC_EXP_DATE" AS
/* $Header: INVCCEDB.pls 120.0.12000000.1 2007/04/02 09:17:03 nsinghi noship $ */

   l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

   PROCEDURE get_custom_lot_expiration_date
     ( p_mtli_lot_rec        IN  MTL_TRANSACTION_LOTS_INTERFACE%ROWTYPE
      ,p_mti_trx_rec               IN  MTL_TRANSACTIONS_INTERFACE%ROWTYPE
      ,p_mtlt_lot_rec        IN  MTL_TRANSACTION_LOTS_TEMP%ROWTYPE
      ,p_mmtt_trx_rec           IN  MTL_MATERIAL_TRANSACTIONS_TEMP%ROWTYPE
      ,p_table                        IN  NUMBER
      ,x_lot_expiration_date OUT NOCOPY DATE
      ,x_return_status       OUT NOCOPY VARCHAR2
     ) IS
   BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /***** Uncomment Following code to log the data present in mtl_transactions_interface,
      mtl_transactions_lots_interface, mtl_material_transactions_temp and mtl_transactions_lots_temp
      at runtime. *****/

      /*
      IF (l_debug = 1 )THEN
         inv_calculate_exp_date.log_transaction_rec( p_mtli_lot_rec => p_mtli_lot_rec
                             ,p_mti_trx_rec => p_mti_trx_rec
                             ,p_mtlt_lot_rec => p_mtlt_lot_rec
                             ,p_mmtt_trx_rec => p_mmtt_trx_rec
                             ,p_table => p_table);
      END IF;
      */

       /***** Put Custom code here to calculate the lot expiration date .
       If custom logic is not required for the calculating lot expiration date for
       then return lot expiration date as NULL *****/

   END get_custom_lot_expiration_date;

END INV_CUST_CALC_EXP_DATE;

/
