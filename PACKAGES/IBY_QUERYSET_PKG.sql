--------------------------------------------------------
--  DDL for Package IBY_QUERYSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_QUERYSET_PKG" AUTHID CURRENT_USER as
/*$Header: ibyqsets.pls 115.5 2002/11/19 23:49:58 jleybovi ship $*/

  /* This procedure gets the trxn info for this particular     */
  /* trxn.  Given a PayeeID, order_id, split_id            */
  /* (splitId), payment_operation, and BEPID, it returns   */
  /* the status (if the operation occurred before -- useful for*/
  /* determining retries) and the set_trxn_id to indicate the  */
  /* parent SET trxn to the vendor.                            */
  PROCEDURE get_settrxninfo
        (merchant_id_in          IN     IBY_Payee.PayeeID%TYPE,
         order_id_in             IN     iby_trxn_summaries_all.TangibleID%TYPE,
         split_id_in             IN     iby_trxn_extended.SplitID%TYPE,
         payment_operation_in    IN     iby_trxn_summaries_all.PaymentMethodName%TYPE,
         vendor_id_in            IN     IBY_BEPInfo.BEPID%TYPE,
         status_out              OUT NOCOPY iby_trxn_summaries_all.Status%TYPE,
         prev_set_trxn_id_in_out IN OUT NOCOPY iby_trxn_extended.SETTrxnID%TYPE,
         price_out               OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
         currency_out            OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE,
         previous_price_out      OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
         previous_currency_out   OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE);
  /* Procedure used to get the status for a particular SET     */
  /* trxn.  The status_out will be set to some value if the    */
  /* order occurred previously, else it'll be null.            */
  PROCEDURE getStatus_SET
       (order_id_in           IN   iby_trxn_summaries_all.TangibleID%TYPE,
        merchant_id_in        IN   IBY_Payee.PayeeID%TYPE,
        payment_operation_in  IN   VARCHAR2,
        split_id_in           IN   iby_trxn_extended.SplitID%TYPE,
        status_out            OUT NOCOPY iby_trxn_summaries_all.Status%TYPE);
  PROCEDURE getAmount_SET
       (order_id_in           IN   iby_trxn_summaries_all.TangibleID%TYPE,
        merchant_id_in        IN   IBY_Payee.PayeeID%TYPE,
        payment_operation_in  IN   VARCHAR2,
        split_id_in           IN   iby_trxn_extended.SplitID%TYPE,
        price_out             OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
        currency_out          OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE);
  /* Procedure used for orasubsequentauth instead of the       */
  /* getStatus_SET procedure.  It performs some special        */
  /* processing.                                               */
  PROCEDURE processsplitauth
        (merchant_id_in        IN     IBY_Payee.PayeeID%TYPE,
         order_id_in           IN     iby_trxn_summaries_all.TangibleID%TYPE,
         prev_split_id_in      IN     iby_trxn_extended.SPlitID%TYPE,
         split_id_in           IN     iby_trxn_extended.SPlitID%TYPE,
         vendor_id_in          IN     IBY_Payee.PayeeID%TYPE,
         status_out            OUT NOCOPY iby_trxn_summaries_all.Status%TYPE,
         set_trxn_id_out       IN OUT NOCOPY iby_trxn_extended.SETTrxnID%TYPE,
         previous_price_out    OUT NOCOPY iby_trxn_summaries_all.Amount%TYPE,
         previous_currency_out OUT NOCOPY iby_trxn_summaries_all.CurrencyNameCode%TYPE);
END iby_queryset_pkg;

 

/
