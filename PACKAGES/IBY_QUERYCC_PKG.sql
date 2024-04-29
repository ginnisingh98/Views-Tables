--------------------------------------------------------
--  DDL for Package IBY_QUERYCC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_QUERYCC_PKG" AUTHID CURRENT_USER as
/*$Header: ibyqrccs.pls 115.17 2003/04/29 18:30:14 jleybovi ship $*/

 PROCEDURE listvpsid (merchant_id_in   IN  VARCHAR2,
                      batch_id_in      IN  VARCHAR2,
                      vendor_id_in     IN  NUMBER,
                      vendor_key_in    IN  VARCHAR2,
                      viby_id          OUT NOCOPY VARCHAR2);

  /* Check if this is a duplicate order or new one or retry */
  PROCEDURE checkunqorder
	(order_id_in       IN    VARCHAR2,
         merchant_id_in    IN    VARCHAR2,
	 payment_operation IN    VARCHAR2,
         trxn_type_in      IN    NUMBER,
         check_status_out  OUT NOCOPY NUMBER,
         parent_trace_number_out OUT NOCOPY VARCHAR2,
	 bepid_out OUT NOCOPY NUMBER,
         bepkey_out OUT NOCOPY VARCHAR2,
         trxnid_out OUT NOCOPY NUMBER,
         trxnref_out OUT NOCOPY VARCHAR2
        );

  /* Check if this batch id is duplicate, new one or retry */
  PROCEDURE checkunqbatch (batch_id_in     IN  VARCHAR2,
                           merchant_id_in  IN  VARCHAR2,
                           stat            OUT NOCOPY NUMBER,
                           viby_bid          OUT NOCOPY VARCHAR2);

  /* Gets the oldest order_id not yet settled */
  PROCEDURE getorderid (merchant_id_in    IN      VARCHAR2,
                      vendor_suffix     IN      VARCHAR2,
                      order_id_out      OUT NOCOPY VARCHAR2);

  /*
   * USE: Gets the amount values associate with a particular trxn.
   *
   * ARGS:
   *    1. the transaction id of the transaction to fetch
   *    2. the trxn type id of the transaction to fetch
   *    3. an auxillary, 'equivalent' trxn type id
   *    4. the status of the trxn
   *    5. an auxillary, 'equivalnet' status
   * OUTS:
   *    6. the amount (i.e. price) of the transaction
   *    7. the currency code of the transaction
   *    8. the status of the trxn
   *
   */
  PROCEDURE getTrxnInfo
  (
  trxnid_in	IN	iby_trxn_summaries_all.transactionid%TYPE,
  trxntypeid_in IN	iby_trxn_summaries_all.trxntypeid%TYPE,
  trxntypeid_aux_in IN	iby_trxn_summaries_all.trxntypeid%TYPE DEFAULT NULL,
  status_in     IN      iby_trxn_summaries_all.status%TYPE,
  status_aux_in IN      iby_trxn_summaries_all.status%TYPE DEFAULT NULL,
  amount_out	OUT NOCOPY iby_trxn_summaries_all.amount%TYPE,
  currency_out	OUT NOCOPY iby_trxn_summaries_all.currencynamecode%TYPE,
  status_out	OUT NOCOPY iby_trxn_summaries_all.status%TYPE
  );


END iby_querycc_pkg;

 

/
