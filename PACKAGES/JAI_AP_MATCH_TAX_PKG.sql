--------------------------------------------------------
--  DDL for Package JAI_AP_MATCH_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_AP_MATCH_TAX_PKG" 
/* $Header: jai_ap_match_tax.pls 120.5 2007/07/05 12:39:55 brathod ship $ */
AUTHID CURRENT_USER AS
PROCEDURE process_batch
(
p_errbuf OUT NOCOPY VARCHAR2,
p_retcode OUT NOCOPY VARCHAR2,
p_org_id			  IN		number, -- added by bug#3218695
p_process_all_org	  IN		varchar2 -- added by bug#3218695
);

PROCEDURE process_online
(
errbuf                        OUT  NOCOPY       VARCHAR2,
retcode                       OUT  NOCOPY       VARCHAR2,
inv_id                                IN        NUMBER,
pn_invoice_line_number                IN        NUMBER, -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
po_dist_id                            IN        NUMBER,
qty_inv                               IN        NUMBER,
p_shipment_header_id                  IN        NUMBER,
p_packing_slip_num                    IN        VARCHAR2,
p_receipt_code                                  VARCHAR2,
p_rematch                                       VARCHAR2,
rcv_tran_id                           IN        NUMBER,
v_dist_amount                         IN        NUMBER,
--p_project_id                                    NUMBER, Obsoleted  Bug# 4445989
--p_task_id                                       NUMBER, Obsoleted  Bug# 4445989
--p_expenditure_type                              VARCHAR2, Obsoleted , Bug# 4445989
--p_expenditure_organization_id                   NUMBER, Obsoleted , Bug# 4445989
--p_expenditure_item_date                         DATE, Obsoleted , Bug# 4445989
v_org_id                              IN        NUMBER
 /* 5763527, Introduced for Project implementation */
 , p_project_id                                    NUMBER
 , p_task_id                                       NUMBER
 , p_expenditure_type                              VARCHAR2
 , p_expenditure_organization_id                   NUMBER
 , p_expenditure_item_date                         DATE
  /* End 5763527 */
);

PROCEDURE process_batch_record (
  err_mesg OUT NOCOPY VARCHAR2,
  inv_id                          IN      NUMBER,
  pn_invoice_line_number          IN      NUMBER,  -- Using pn_invoice_line_number instead of dist_line_no for Bug#4445989
  po_dist_id                      IN      NUMBER,
  qty_inv                         IN      NUMBER,
  p_shipment_header_id            IN      NUMBER,
  p_packing_slip_num              IN      VARCHAR2,
  p_receipt_code                          VARCHAR2,
  p_rematch                               VARCHAR2,
  rcv_tran_id                     IN      NUMBER,
  v_dist_amount                   IN      NUMBER,
  --p_project_id                            NUMBER,
  --p_task_id                               NUMBER,
  --p_expenditure_type                      VARCHAR2,
  --p_expenditure_organization_id           NUMBER,
  --p_expenditure_item_date                 DATE,
  v_org_id                        IN      NUMBER
  /* 5763527, Introduced parameters for Project Implementation */
  ,p_project_id                            NUMBER
  ,p_task_id                               NUMBER
  ,p_expenditure_type                      VARCHAR2
  ,p_expenditure_organization_id           NUMBER
  ,p_expenditure_item_date                 DATE
  /* End 5763527 */

) ;

END jai_ap_match_tax_pkg;

/
