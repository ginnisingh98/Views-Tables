--------------------------------------------------------
--  DDL for Package JAI_AP_TDS_OLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_TDS_OLD_PKG" 
/* $Header: jai_ap_tds_old.pls 120.1 2005/07/20 12:55:13 avallabh ship $ */
AUTHID CURRENT_USER AS
PROCEDURE cancel_invoice
(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2,
  p_invoice_id IN NUMBER
);

PROCEDURE process_prepayment_unapply
(
errbuf OUT NOCOPY VARCHAR2,
retcode OUT NOCOPY VARCHAR2,
p_invoice_id 				IN 			NUMBER,
p_last_updated_by 			IN 			NUMBER,
p_last_update_date 			IN 			DATE,
p_created_by 				IN 			NUMBER,
p_creation_date 			IN 			DATE,
p_org_id 					IN 			NUMBER,
p_prepay_dist_id 			IN 			NUMBER,
p_inv_dist_id 				IN 			NUMBER,
p_attribute 				IN 			VARCHAR2
);

PROCEDURE process_prepayment_apply(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2,
  p_invoice_id        IN     NUMBER,
  p_invoice_distribution_id   IN     NUMBER,
  p_amount          IN     NUMBER,
  p_last_updated_by       IN     NUMBER,
  p_last_update_date      IN     DATE,
  p_created_by        IN     NUMBER,
  p_creation_date       IN     DATE,
  p_org_id          IN     NUMBER,
  p_prepay_dist_id      IN     NUMBER,
  p_param           IN     VARCHAR2,
  p_attribute         IN     VARCHAR2
);

PROCEDURE approve_invoice
(
errbuf OUT NOCOPY VARCHAR2,
retcode OUT NOCOPY VARCHAR2,
p_parent_request_id     IN      NUMBER,
p_vendor_id         IN      NUMBER,
p_vendor_site_id      IN      NUMBER,
p_invoice_id        IN      NUMBER,
p_invoice_num         IN      VARCHAR2 DEFAULT NULL,
p_inv_type          IN      VARCHAR2 DEFAULT NULL
);


FUNCTION get_invoice_status (l_invoice_id IN NUMBER,
                                                  l_invoice_amount IN NUMBER,
                                                  l_payment_status_flag IN VARCHAR2,
                                                  l_invoice_type_lookup_code IN VARCHAR2,
                                                  I_org_id number )
         RETURN VARCHAR2;

END jai_ap_tds_old_pkg;
 

/
