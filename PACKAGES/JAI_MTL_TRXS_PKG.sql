--------------------------------------------------------
--  DDL for Package JAI_MTL_TRXS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_MTL_TRXS_PKG" AUTHID CURRENT_USER AS
/*$Header: jai_mtl_trxs_pkg.pls 120.2.12010000.2 2008/11/19 12:16:46 mbremkum ship $  */

/*----------------------------------------------------------------------------------------------------------------------
CHANGE HISTORY:             FILENAME: jai_mtl_trxs_pkg.pls
S.No    Date                Author and Details
------------------------------------------------------------------------------------------------------------------------
1.  01-08-2007           rchandan for bug#6030615 , Version 120.0
                         Issue : Inter org Forward porting
                                 This is a new file in R12 now.
2.  12-May-2008        Changes by nprashar . Forward porting of 11i bug  # 6086452 for R12 bug 6710747.

------------------------------------------------------------------------------------------------------------------------
*/

PROCEDURE cenvat_process( p_transaction_temp_id          IN  NUMBER,
        p_transaction_type in varchar2,
        p_excise_inv_no in varchar2,/*Changes by nprashar for bug # 6710747*/
        p_process_status OUT NOCOPY VARCHAR2,
        p_process_message OUT NOCOPY VARCHAR2);

PROCEDURE recv_vat_process(p_organization_id         IN NUMBER,
         p_location_id             IN NUMBER,
         p_set_of_books_id in number,
         p_currency in varchar2,
         p_transaction_header_id   IN NUMBER,
         p_transaction_temp_id     IN NUMBER,
         p_vat_invoice_no          IN VARCHAR2,
         p_process_status  OUT NOCOPY VARCHAR2,
         p_process_message OUT NOCOPY VARCHAR2);

type claimrec is record(receipt_num JAI_RCV_TRANSACTIONS.receipt_num%type,
                        receipt_qty JAI_RCV_TRANSACTIONS.quantity%type,
                        claimed_ptg JAI_RCV_CENVAT_CLAIMS.cenvat_claimed_ptg%type,
                        qty_to_claim JAI_RCV_CENVAT_CLAIMS.quantity_for_2nd_claim%type,
                        cenvat_amt_to_apply JAI_RCV_CENVAT_CLAIMS.cenvat_amt_for_2nd_claim%type,
                        shipment_line_id JAI_RCV_CENVAT_CLAIMS.shipment_line_id%type,
                        cenvat_claimed_amt JAI_RCV_CENVAT_CLAIMS.cenvat_claimed_amt%type,
                        other_cenvat_claimed_amt JAI_RCV_CENVAT_CLAIMS.other_cenvat_claimed_amt%type,
                        other_cenvat_amt_to_apply JAI_RCV_CENVAT_CLAIMS.other_cenvat_amt_for_2nd_claim%type ,
                        cenvat_amount JAI_RCV_CENVAT_CLAIMS.cenvat_amount%type,
                        other_cenvat_Amt JAI_RCV_CENVAT_CLAIMS.other_cenvat_Amt%type,
                        transaction_id JAI_RCV_CENVAT_CLAIMS.transaction_id%type,
                        excise_invoice_no JAI_RCV_TRANSACTIONS.excise_invoice_no%type,
                        excise_invoice_date JAI_RCV_TRANSACTIONS.excise_invoice_date%type);

type claimcur is ref cursor return claimrec;

PROCEDURE cenvat_recpt_det(block_data  in OUT NOCOPY claimcur,
                           p_organization_id in number);
 PROCEDURE do_cenvat_Acctg(
  p_set_of_books_id          IN NUMBER,
  p_transaction_temp_id      IN NUMBER,
  p_je_source_name           IN VARCHAR2,
  p_je_category_name         IN VARCHAR2,
  p_currency_code            IN VARCHAR2,
  p_register_type            IN VARCHAR2,
  p_process_status           OUT NOCOPY VARCHAR2,
  p_process_message          OUT NOCOPY VARCHAR2
  );


  procedure cenvat_auto_claim
  (p_transaction_Temp_id IN NUMBER,
   p_shipment_line_id    IN NUMBER,
   p_applied_quantity    IN NUMBER
  );


  procedure do_costing
  (
  transaction_id IN NUMBER,
  process_flag OUT NOCOPY varchar2,
  process_msg OUT NOCOPY varchar2
  );


  PROCEDURE avg_cost_entry(
      p_txn_header_id               IN OUT NOCOPY NUMBER,
      p_item_id                     IN NUMBER,
      p_organization_id             IN NUMBER,
      p_uom_code                    IN VARCHAR2,
      p_transaction_date            IN DATE,
      p_transaction_type_id         IN NUMBER,
      p_transaction_source_type_id  IN NUMBER,
      p_transaction_id              IN NUMBER,
      p_cost_group_id               IN NUMBER,
      p_receiving_account_id        IN NUMBER,
      p_absorption_account_id       IN NUMBER,
      p_value_change                IN NUMBER,
      p_transaction_action_id       IN NUMBER ,
      p_from_organization_id        IN NUMBER ,
      p_from_subinventory           IN VARCHAR2,
      p_to_subinventory             IN VARCHAR2,
      p_txn_quantity                IN NUMBER
);


  PROCEDURE std_cost_entry(
  p_transaction_id             IN  NUMBER,
  p_reference_account          IN  NUMBER,
  p_inventory_item_id          IN  NUMBER,
  p_organization_id            IN  NUMBER,
  p_transaction_source_id      IN  NUMBER,
  p_transaction_source_type_id IN  NUMBER,
  p_primary_quantity           IN  NUMBER,
  p_transaction_date           IN  DATE,
  p_cost_amount                IN  NUMBER,
  p_process_flag OUT NOCOPY VARCHAR2,
  p_process_msg OUT NOCOPY VARCHAR2
  );

  PROCEDURE process_vat_claim_acctg(
            p_repository_id       IN  NUMBER,
            p_process_status      OUT NOCOPY  VARCHAR2,
            p_process_message     OUT NOCOPY  VARCHAR2);

  PROCEDURE CGVAT_REPOSIT_ENTRY(p_organization_id         IN NUMBER,
                                p_location_id             IN NUMBER,
                                p_Set_of_books_id       IN number,
                                p_currency in varchar2,
                                p_transaction_header_id   IN NUMBER,
                                p_transaction_temp_id     IN NUMBER,
                                p_transaction_id          IN NUMBER,
                                p_vat_invoice_no          IN VARCHAR2,
                                p_tax_type in varchar2,
                                p_amount in number,
                                p_claim_schedule_id in number,
                                p_process_status  OUT NOCOPY VARCHAR2,
                                p_process_message OUT NOCOPY VARCHAR2) ;

 PROCEDURE claim_balance_cgvat(
                 p_term_id                 IN      jai_rgm_terms.term_id%TYPE DEFAULT NULL,
                 p_shipment_header_id      IN      rcv_shipment_headers.shipment_header_id%TYPE DEFAULT NULL,
                 p_shipment_line_id        IN      rcv_shipment_lines.shipment_line_id%TYPE DEFAULT NULL,
                 p_transaction_id          IN      rcv_transactions.transaction_id%TYPE DEFAULT NULL,
                 p_tax_type                IN      jai_cmn_taxes_all.tax_type%TYPE DEFAULT NULL,
                 p_tax_id                  IN      jai_cmn_taxes_all.tax_id%TYPE DEFAULT NULL,
                 p_receipt_num             IN      VARCHAR2,
                 P_applied_qty             IN      NUMBER,
                 p_organization_id         IN      NUMBER,
                 p_inventory_item_id       IN      NUMBER,
                 p_location_id             IN      NUMBER,
                 p_Set_of_books_id         IN      NUMBER,
                 p_currency                IN      VARCHAR2,
                 p_transaction_header_id   IN      NUMBER,
                 p_transaction_temp_id     IN      NUMBER,
                 p_vat_invoice_no          IN      VARCHAR2,
                 p_process_status         OUT      NOCOPY  VARCHAR2,
                 p_process_message        OUT      NOCOPY  VARCHAR2);


  PROCEDURE default_taxes(
    p_to_organization_id              number      ,
    p_to_location_code                VARCHAR2    ,
    p_transfer_subinventory           varchar2    ,
    p_toorg_location_id               number      ,
    p_organization_id                 number      ,
    p_subinventory_code               varchar2    ,
    p_transaction_type_id             number      ,
    p_header_id                       NUMBER      ,
    p_line_id                         NUMBER      ,
    p_inventory_item_id               NUMBER      ,
    p_uom_code                        VARCHAR2    ,
    p_line_quantity                   NUMBER      ,
    p_item_cost                       NUMBER      ,
    p_currency                        VARCHAR2    ,
    p_currency_conv_factor            NUMBER      ,
    p_date_order                      DATE        ,
    p_Iproc_profile_val               number      ,
    p_assessable_value          OUT NOCOPY  NUMBER      ,
    p_vat_assessable_value      OUT NOCOPY  NUMBER      ,
    p_tax_amount             IN OUT NOCOPY  NUMBER
  );

  PROCEDURE  sync_with_base_trx(
    p_transaction_header_id IN NUMBER,
    p_transaction_temp_id   IN NUMBER,
    p_event                 IN VARCHAR2
  );

END;

/
