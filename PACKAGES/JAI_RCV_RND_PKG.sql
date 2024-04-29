--------------------------------------------------------
--  DDL for Package JAI_RCV_RND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_RCV_RND_PKG" AUTHID CURRENT_USER AS
/* $Header: jai_rcv_rnd.pls 120.2 2007/04/19 06:50:28 bgowrava ship $ */
  gb_debug            CONSTANT BOOLEAN       := true;
  LV_RG23_REGISTER    CONSTANT VARCHAR2(10)  := 'RG23';
  LV_PLA_REGISTER     CONSTANT VARCHAR2(10)  := 'PLA';

  -- this cursor gives the no of ITEM_CLASSes present in an excise invoice
  CURSOR c_cgin_chk_for_2nd_claim(p_shipment_header_id IN NUMBER,
        p_excise_invoice_no in varchar2, p_excise_invoice_date in date,
        p_vendor_id IN NUMBER,p_vendor_site_id IN NUMBER) IS
    SELECT
      nvl(sum(decode(cenvat_claimed_ptg, 100, 1, 0)), 0)  cent_percent_cnt,
      nvl(sum(decode(cenvat_claimed_ptg, 50, 1, 0)),0)    fifty_percent_cnt,
      nvl(sum(decode(cenvat_claimed_ptg, 0, 1, 0)),0)     zero_percent_cnt,
      count(1) tot_cnt
    FROM JAI_RCV_LINES a, JAI_RCV_CENVAT_CLAIMS b, rcv_transactions c /*bgowrava for forward porting bug#5674376*/
    WHERE a.shipment_line_id = b.shipment_line_id
    AND a.excise_invoice_no = p_excise_invoice_no
    AND a.excise_invoice_date = p_excise_invoice_date
    AND a.shipment_header_id = p_shipment_header_id
    AND ( (nvl(b.vendor_id,-999) = nvl(p_vendor_id,-999)
           AND nvl(b.vendor_site_id,-999) = nvl(p_vendor_site_id,-999)
           AND b.vendor_changed_flag = 'Y' )
           OR (nvl(c.vendor_id,-999) = nvl(p_vendor_id,-999)
           AND nvl(c.vendor_site_id,-999) = nvl(p_vendor_site_id,-999)
           AND b.vendor_changed_flag = 'N' ) ); /*bgowrava for forward porting bug#5674376*/

  CURSOR c_full_cgin_chk(cp_shipment_header_id IN NUMBER, cp_excise_invoice_no IN VARCHAR2,
      cp_excise_invoice_date IN DATE,cp_vendor_id  IN NUMBER  ,
                         cp_vendor_site_id  IN NUMBER) IS
    SELECT nvl(sum(decode(c.item_class, 'CGIN', 1, 0)), 0) cgin_cnt, count(1) total_cnt
    FROM JAI_RCV_LINES a, JAI_RCV_CENVAT_CLAIMS b,/*bgowrava for forward porting bug#5674376*/
    JAI_INV_ITM_SETUPS c, RCV_TRANSACTIONS d /*bgowrava for forward porting bug#5674376*/
    WHERE a.shipment_header_id = cp_shipment_header_id
    AND   b.transaction_id      = d.transaction_id /*bgowrava for forward porting bug#5674376*/
    AND   a.transaction_id      = b.transaction_id /*bgowrava for forward porting bug#5674376*/
    AND a.organization_id = c.organization_id
    AND a.inventory_item_id = c.inventory_item_id
    AND a.excise_invoice_no = cp_excise_invoice_no
    AND a.excise_invoice_date = cp_excise_invoice_date
    AND ( (nvl(b.vendor_id,-999) = nvl(cp_vendor_id,-999)
           AND nvl(b.vendor_site_id,-999) = nvl(cp_vendor_site_id,-999)
           AND b.vendor_changed_flag = 'Y' )
           OR (nvl(d.vendor_id,-999) = nvl(cp_vendor_id,-999)
           AND nvl(d.vendor_site_id,-999) = nvl(cp_vendor_site_id,-999)
           AND b.vendor_changed_flag = 'N' ) );/*bgowrava for forward porting bug#5674376*/

  PROCEDURE do_rounding(
    p_err_buf               OUT NOCOPY VARCHAR2,
    p_ret_code              OUT NOCOPY NUMBER,
    P_ORGANIZATION_ID       IN  NUMBER,
    P_TRANSACTION_TYPE      IN  VARCHAR2,
    P_REGISTER_TYPE         IN  VARCHAR2,
     PV_EX_INVOICE_FROM_DATE  IN  VARCHAR2, /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
    PV_EX_INVOICE_TO_DATE    IN  VARCHAR2  /* rallamse bug#4336482 changed to VARCHAR2 from DATE */
  );

  FUNCTION get_parent_register_id(
    p_register_id IN NUMBER
  ) RETURN NUMBER;

  PROCEDURE pass_accounting(
      p_organization_id           number,
      p_transaction_id            number,
      p_transaction_date          date,
      p_shipment_line_id          number,
      p_acct_type                 varchar2,
      p_acct_nature               varchar2,
      p_source                    varchar2,
      p_category                  varchar2,
      p_code_combination_id       number,
      p_entered_dr                number,
      p_entered_cr                number,
      p_created_by                number,
      p_currency_code             varchar2,
      p_currency_conversion_type  varchar2,
      p_currency_conversion_date  varchar2,
      p_currency_conversion_rate  varchar2,
      p_receipt_num               varchar2
  );

  PROCEDURE do_rtv_rounding(
    p_organization_id       in  number,
    p_transaction_type      in  varchar2,
    p_register_type         in  varchar2,
    p_ex_invoice_from_date  in  date,
    p_ex_invoice_to_date    in  date
  );

END jai_rcv_rnd_pkg;

/
