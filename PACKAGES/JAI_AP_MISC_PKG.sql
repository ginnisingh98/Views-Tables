--------------------------------------------------------
--  DDL for Package JAI_AP_MISC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_MISC_PKG" AUTHID CURRENT_USER AS
/*  $Header: jai_ap_misc_pkg.pls 120.1.12000000.1 2007/10/24 18:20:14 rallamse noship $ */
  procedure jai_calc_ipv_erv ( P_errmsg OUT NOCOPY VARCHAR2,
                               P_retcode OUT NOCOPY Number,
             P_invoice_id in number,
             P_po_dist_id in number,
             P_invoice_distribution_id IN NUMBER,
             P_amount IN NUMBER,
             P_base_amount IN NUMBER,
             P_rcv_transaction_id IN NUMBER,
             P_invoice_price_variance IN NUMBER,
             P_base_invoice_price_variance IN NUMBER,
             P_price_var_ccid IN NUMBER,
             P_Exchange_rate_variance IN NUMBER,
             P_rate_var_ccid IN NUMBER
                      );

FUNCTION fetch_tax_target_amt
( p_invoice_id          IN NUMBER      ,
  p_line_location_id    IN NUMBER ,
  p_transaction_id      IN NUMBER ,
  p_parent_dist_id      IN NUMBER,
  p_tax_id              IN NUMBER
)
RETURN NUMBER ;

End JAI_AP_MISC_PKG;
 

/
