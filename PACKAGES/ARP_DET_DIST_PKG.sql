--------------------------------------------------------
--  DDL for Package ARP_DET_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_DET_DIST_PKG" AUTHID CURRENT_USER AS
/* $Header: ARPDDS.pls 120.18.12010000.7 2009/10/22 07:18:06 aghoraka ship $ */

SUBTYPE ae_rule_rec_type  IS ARP_ACCT_MAIN.ae_app_rule_rec_type;

g_appln_count NUMBER := 0;

/*------------------------------------------------------------------+
 | the_concern_bucket                                               |
 +------------------------------------------------------------------+
 | What is the bucket of allocation amount to use base on line type |
 | This is line level proration not for distribution                |
 +------------------------------------------------------------------+
 | Return the bucket based on the input parameters                  |
 +------------------------------------------------------------------+
 |  p_pay_adj        APP / ADJ / ED / UNED
 |  p_line_type      LINE / TAX / FREIGHT
 |  p_line_adj       Adj line bucket
 |  p_tax_adj        Adj tax bucket
 |  p_frt_adj        Adj freight bucket
 |  p_chrg_adj       Adj charge bucket
 |  p_line_applied   App line
 |  p_tax_applied    App tax
 |  p_frt_applied    App freight
 |  p_chrg_applied   App charge
 |  p_line_ed        ED  line
 |  p_tax_ed         ED  tax
 |  p_frt_ed         ED  freight
 |  p_chrg_ed        ED  charge
 |  p_line_uned      UNED line
 |  p_tax_uned       UNED tax
 |  p_frt_uned       UNED freight
 |  p_chrg_uned      UNED charge
 |  p_acctd          Y / N accouting bucket
 |  p_chrg_bucket    Y / N charge bucket
 |  p_frt_bucket     Y / N frt bucket
 |  p_base_currency  function currency
 +------------------------------------------------------------------*/
  FUNCTION the_concern_bucket
  (p_pay_adj        IN VARCHAR2,
   p_line_type      IN VARCHAR2,
   p_acctd          IN VARCHAR2,
   p_chrg_bucket    IN VARCHAR2,
   p_frt_bucket     IN VARCHAR2)
  RETURN NUMBER;


/*-------------------------------------------------------------------------+
 | Trx_level_cash_apply                                                    |
 +-------------------------------------------------------------------------+
 | 1) get_invoice_line_info                                                |
 | 2) prepare_group_for_proration                                          |
 | 3) maj_group_line                                                       |
 | 4) prepare_trx_line_proration                                           |
 | 5) maj_line                                                             |
 | 6) update_ctl_rem_orig                                                  |
 | 7) store_group_id                                                       |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id     transaction id
 |  p_app_rec             ar receivable application record
 |  p_ae_sys_rec          ar system parameter
 +-------------------------------------------------------------------------*/
PROCEDURE Trx_level_cash_apply
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN VARCHAR2 DEFAULT NULL);


/*-------------------------------------------------------------------------+
 | Trx_gp_level_cash_apply                                                 |
 +-------------------------------------------------------------------------+
 | 1) get_invoice_line_info_per_grp                                        |
 | 2) prepare_group_for_proration                                          |
 | 3) maj_group_line                                                       |
 | 4) prepare_trx_line_proration                                           |
 | 5) maj_line                                                             |
 | 6) update_ctl_rem_orig                                                  |
 | 7) store_group_id                                                       |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id     transaction id
 |  p_group_id            source_data_key1
 |  p_app_rec             ar receivable application record
 |  p_ae_sys_rec          ar system parameter
 +-------------------------------------------------------------------------*/
PROCEDURE Trx_gp_level_cash_apply
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
--   p_group_id         IN VARCHAR2,
  --{HYUBPAGP
   p_source_data_key1 IN VARCHAR2,
   p_source_data_key2 IN VARCHAR2,
   p_source_data_key3 IN VARCHAR2,
   p_source_data_key4 IN VARCHAR2,
   p_source_data_key5 IN VARCHAR2,
  --}
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN VARCHAR2 DEFAULT NULL);


/*-------------------------------------------------------------------------+
 | Trx_line_level_cash_apply                                               |
 +-------------------------------------------------------------------------+
 | 1) get_invoice_line_info_per_line                                       |
 | 2) prepare_group_for_proration                                          |
 | 3) maj_group_line                                                       |
 | 4) prepare_trx_line_proration                                           |
 | 5) maj_line                                                             |
 | 6) update_ctl_rem_orig                                                  |
 | 7) store_group_id                                                       |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id      transaction id
 |  p_customer_trx_line_id customer_trx_line_id
 |  p_app_rec              ar receivable application record
 |  p_ae_sys_rec           ar system parameter
 +-------------------------------------------------------------------------*/
PROCEDURE Trx_line_level_cash_apply
  (p_customer_trx           IN ra_customer_trx%ROWTYPE,
   p_customer_trx_line_id   IN VARCHAR2,
   p_log_inv_line           IN VARCHAR2 DEFAULT 'N',
   p_app_rec                IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec             IN arp_acct_main.ae_sys_rec_type,
   p_gt_id                  IN VARCHAR2 DEFAULT NULL  );


/*-------------------------------------------------------------------------+
 | Trx_level_direct_adjust                                                 |
 +-------------------------------------------------------------------------+
 | 1) get_invoice_line_info                                                |
 | 2) prepare_group_for_proration                                          |
 | 3) maj_group_line                                                       |
 | 4) prepare_trx_line_proration                                           |
 | 5) maj_line                                                             |
 | 6) update_ctl_rem_orig                                                  |
 | 7) store_gt_id                                                          |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id     transaction id
 |  p_adj_rec             ar adjustment record
 |  p_ae_sys_rec          ar system parameter
 +-------------------------------------------------------------------------*/
PROCEDURE Trx_level_direct_adjust
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_adj_rec          IN ar_adjustments%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN NUMBER DEFAULT NULL);


/*-----------------------------------------------------------+
 | PROCEDURE gt_initial                                      |
 +-----------------------------------------------------------+
 | Note: procedure is to be called at commit point.          |
 |   will create in ar_line_application_detail the detail    |
 |   distribution for llca at all level                      |
 +-----------------------------------------------------------*/
--PROCEDURE gt_initial;

/*-----------------------------------------------------------+
 | PROCEDURE set_original_rem_amt                            |
 +-----------------------------------------------------------+
 | Note: procedure updates the balance on ctl line when trx  |
 | does not have any activities on it. It should be called   |
 | ideally on transaction completion point                   |
 +-----------------------------------------------------------*/
PROCEDURE set_original_rem_amt
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 p_adj_id           IN NUMBER DEFAULT   NULL,
 p_app_id           IN NUMBER DEFAULT   NULL,
--{HYUNLB
 p_from_llca        IN VARCHAR2 DEFAULT 'N');
--}
/*-----------------------------------------------------------+
 | PROCEDURE copy_trx_lines                                  |
 +-----------------------------------------------------------+
 | Note: procedure copy the invoice line from ra_customer    |
 | trx_lines into ra_customer_trx_lines_gt.                  |
 +-----------------------------------------------------------*/
PROCEDURE copy_trx_lines
(p_customer_trx_id  IN NUMBER,
 p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
 p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE DEFAULT NULL);


/*-----------------------------------------------------------+
 | PROCEDURE final_update_inv_ctl_rem_orig                   |
 +-----------------------------------------------------------+
 | Note: procedure updates the balance on ctl line once user |
 | commit the activities on the transactions.                |
 +-----------------------------------------------------------*/
PROCEDURE final_update_inv_ctl_rem_orig
(p_customer_trx     IN ra_customer_trx%ROWTYPE);


/*-----------------------------------------------------------+
 | PROCEDURE create_final_split                              |
 +-----------------------------------------------------------+
 | Note: procedure creates the detail distributions in       |
 | ar_line_application_detail at commit point                |
 +-----------------------------------------------------------*/
PROCEDURE create_final_split
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 p_app_rec          IN ar_receivable_applications%ROWTYPE,
 p_adj_rec          IN ar_adjustments%ROWTYPE,
 p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | update_dist                                                             |
 +-------------------------------------------------------------------------+
 | Read ra_ar_gt for proration info                                        |
 | Does the proration plsql_proration                                      |
 | update ra_ar_gt with the result                                         |
 | for distributions of all lines of a invoice                             |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id         transaction id                               |
 |  p_gt_id                   global id                                    |
 +-------------------------------------------------------------------------*/
 PROCEDURE update_dist
 (p_gt_id           IN VARCHAR2,
  p_customer_trx_id IN NUMBER,
  p_ae_sys_rec      IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | Trx_level_direct_cash_apply                                             |
 +-------------------------------------------------------------------------+
 | 1) get_invoice_line_info                                                |
 | 2) prepare_group_for_proration                                          |
 | 3) update_group_line                                                    |
 | 4) prepare_trx_line_proration                                           |
 | 5) update_line                                                          |
 | 6) update_ctl_rem_orig                                                  |
 | 7) store_gt_id                                                          |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id     transaction id                                   |
 |  p_app_rec             ar receivable application record                 |
 |  p_ae_sys_rec          ar system parameter                              |
 +-------------------------------------------------------------------------*/
PROCEDURE Trx_level_direct_cash_apply
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN NUMBER   DEFAULT NULL,
   p_inv_cm           IN VARCHAR2 DEFAULT 'I');


/*-----------------------------------------------------------+
 | PROCEDURE possible_adjust                                 |
 |  check if a particular adjustment is possible.            |
 +-----------------------------------------------------------+
 | Parameters:                                               |
 | -----------                                               |
 | p_adj_rec       the adjustment record.                    |
 | p_ae_rule_rec   containing accounting acitivity           |
 |                 and bucket info.                          |
 | p_amt_rem       containing amount kept at invoice         |
 |                 lines.                                    |
 | x_return_status value according to the possibility        |
 |                 of the adjustment                         |
 |                  FND_API.G_RET_STS_SUCCESS if possible    |
 |                  FND_API.G_RET_STS_ERROR   if imposssible |
 | x_line_adj      codification for line adjustment          |
 | x_tax_adj       codification for tax adjustment           |
 | x_frt_adj       codification for freight adjustment       |
 | x_chrg_adj      codification for charge adjustment        |
 +-----------------------------------------------------------+
 | Created 26-OCT-03     Herve Yu                            |
 +-----------------------------------------------------------*/
PROCEDURE possible_adjust(p_adj_rec           IN  ar_adjustments%rowtype,
                          p_ae_rule_rec       IN  ae_rule_rec_type,
                          p_customer_trx_id   IN  NUMBER,
                          x_return_status     OUT NOCOPY VARCHAR2,
                          x_line_adj          OUT NOCOPY VARCHAR2,
                          x_tax_adj           OUT NOCOPY VARCHAR2,
                          x_frt_adj           OUT NOCOPY VARCHAR2,
                          x_chrg_adj          OUT NOCOPY VARCHAR2,
                          p_app_rec           IN  ar_receivable_applications%rowtype);


/*---------------------------------------------------------------------+
 | FUNCTION Accting_Proration_Fct                                      |
 +---------------------------------------------------------------------+
 | This function                                                       |
 |  does the proration and return the value in a row by row manner     |
 |  usefull for function in SQL statement updation                     |
 |                                                                     |
 | Parameter                                                           |
 | p_temp_amt           distribution amount template for proration     |
 |                      for example ae_pro_amt(i)                      |
 | p_base_proration     base for proration                             |
 |                      for example sum ae_pro_amt(i)                  |
 | p_alloc_amount       The amount for which distribution need to be   |
 |                      computed. For example p_app_rec.from_amt_applied
 | p_base_currency      Base currency code                             |
 | p_trx_currency       Trx  currency code                             |
 | p_rec_currency       Rec  currency code                             |
 | p_flag               indication of which from distribution to compute
 |                       p_flag = 'FROM_AMT'                           |
 |                       p_flag = 'FROM_ACCTD_AMT'                     |
 |                       p_flag = 'FROM_CHRG_AMT'                      |
 |                       p_flag = 'FROM_CHRG_ACCTD_AMT'                |
 | History                                                             |
 |  05-NOV-2004  H. Yu  Created                                        |
 +---------------------------------------------------------------------*/
FUNCTION Accting_Proration_Fct
  (p_temp_amt                   IN NUMBER,
   p_base_proration             IN NUMBER,
   p_alloc_amount               IN NUMBER,
   p_base_currency              IN VARCHAR2,
   p_trx_currency               IN VARCHAR2,
   p_rec_currency               IN VARCHAR2,
   p_flag                       IN VARCHAR2)
RETURN NUMBER;

PROCEDURE exec_adj_api_if_required
  (p_adj_rec         IN ar_adjustments%ROWTYPE,
   p_app_rec         IN ar_receivable_applications%ROWTYPE,
   p_ae_rule_rec     IN ae_rule_rec_type,
   p_cust_inv_rec    IN ra_customer_trx%ROWTYPE);

PROCEDURE exec_revrec_if_required
( p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE,
  p_app_rec          IN  ar_receivable_applications%ROWTYPE,
  p_adj_rec          IN  ar_adjustments%ROWTYPE);

PROCEDURE update_for_mrc_dist
(p_gt_id           IN VARCHAR2,
 p_customer_trx_id IN NUMBER,
 p_app_rec         IN ar_receivable_applications%ROWTYPE,
 p_adj_rec         IN ar_adjustments%ROWTYPE,
 p_ae_sys_rec      IN arp_acct_main.ae_sys_rec_type);


PROCEDURE prepare_for_ra
(  p_gt_id                IN NUMBER,
   p_app_rec              IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type,
   p_inv_cm               IN VARCHAR2 DEFAULT 'I',
   p_cash_mfar            IN VARCHAR2 DEFAULT 'CASH');

--legacy lazy upgrade
PROCEDURE check_lazy_apply_req
  (p_trx_id           IN  NUMBER,
   x_out_res          OUT NOCOPY  VARCHAR2);

PROCEDURE check_mf_trx
( p_cust_trx_type_id  IN NUMBER,
  x_out_res           OUT NOCOPY VARCHAR2);


PROCEDURE online_lazy_apply
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN NUMBER,
   p_inv_cm           IN VARCHAR2 DEFAULT 'I');

FUNCTION next_val(p_num IN NUMBER)
RETURN NUMBER;


/*-----------------------------------------------------------------------------+
 | Procedure   get_latest_amount_remaining                                     |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_customer_trx_id The invoice ID                                          |
 |   p_app_level      Application Level (TRANSACTION/GROUP/LINE)               |
 |   p_group_id       Group_id req when Application level is GROUP             |
 |   p_ctl_id         customer_trx_line_id required when the application level |
 |                    is LINE                                                  |
 |   OUT                                                                       |
 |  x_line_rem      The remaining revenue amount for the level                 |
 |  x_tax_rem       The remaining tax amount for the level                     |
 |  x_freight_rem   The remaining freight amount for the level TRANSACTION only|
 |  x_charges_rem   The remaining charges amount for the level TRANSACTION only|
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |  Read the remaining amount on ra_customer_trx_lines_gt                      |
 +-----------------------------------------------------------------------------*/
PROCEDURE get_latest_amount_remaining
(p_customer_trx_id  IN NUMBER,
 p_app_level        IN VARCHAR2 DEFAULT 'TRANSACTION',
 p_source_data_key1 IN VARCHAR2 DEFAULT NULL,
 p_source_data_key2 IN VARCHAR2 DEFAULT NULL,
 p_source_data_key3 IN VARCHAR2 DEFAULT NULL,
 p_source_data_key4 IN VARCHAR2 DEFAULT NULL,
 p_source_data_key5 IN VARCHAR2 DEFAULT NULL,
 p_ctl_id           IN NUMBER   DEFAULT NULL,
 x_line_rem        OUT NOCOPY  NUMBER,
 x_tax_rem         OUT NOCOPY  NUMBER,
 x_freight_rem     OUT NOCOPY  NUMBER,
 x_charges_rem     OUT NOCOPY  NUMBER,
 x_return_status   OUT NOCOPY  VARCHAR2,
 x_msg_data        OUT NOCOPY  VARCHAR2,
 x_msg_count       OUT NOCOPY  NUMBER);

--BUG#44144391
PROCEDURE get_gt_sequence
(x_gt_id         OUT NOCOPY NUMBER,
 x_return_status IN OUT NOCOPY VARCHAR2,
 x_msg_count     IN OUT NOCOPY NUMBER,
 x_msg_data      IN OUT NOCOPY VARCHAR2);

PROCEDURE set_interface_flag
( p_source_table     IN VARCHAR2 DEFAULT NULL,
  p_line_flag        IN VARCHAR2 DEFAULT 'NORMAL',
  p_tax_flag         IN VARCHAR2 DEFAULT 'NORMAL',
  p_freight_flag     IN VARCHAR2 DEFAULT 'NORMAL',
  p_charges_flag     IN VARCHAR2 DEFAULT 'NORMAL',
  p_ed_line_flag     IN VARCHAR2 DEFAULT 'NORMAL',
  p_ed_tax_flag      IN VARCHAR2 DEFAULT 'NORMAL',
  p_uned_line_flag   IN VARCHAR2 DEFAULT 'NORMAL',
  p_uned_tax_flag    IN VARCHAR2 DEFAULT 'NORMAL');

PROCEDURE adjustment_with_interface
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 p_adj_rec          IN ar_adjustments%ROWTYPE,
 p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
 p_gt_id            IN NUMBER,
 p_line_flag        IN VARCHAR2 DEFAULT 'INTERFACE',
 p_tax_flag         IN VARCHAR2 DEFAULT 'INTERFACE',
 p_init_msg_list    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
 x_return_status    IN OUT NOCOPY VARCHAR2,
 x_msg_count        IN OUT NOCOPY NUMBER,
 x_msg_data         IN OUT NOCOPY VARCHAR2,
 p_llca_from_call   IN  VARCHAR2 DEFAULT NULL,
 p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE DEFAULT NULL);

PROCEDURE application_with_interface
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN NUMBER,
   p_line_flag        IN VARCHAR2 DEFAULT 'INTERFACE',
   p_tax_flag         IN VARCHAR2 DEFAULT 'INTERFACE',
   p_ed_line_flag     IN VARCHAR2 DEFAULT 'NORMAL',
   p_ed_tax_flag      IN VARCHAR2 DEFAULT 'NORMAL',
   p_uned_line_flag   IN VARCHAR2 DEFAULT 'NORMAL',
   p_uned_tax_flag    IN VARCHAR2 DEFAULT 'NORMAL',
   p_init_msg_list    IN VARCHAR2 DEFAULT FND_API.G_FALSE,
   x_return_status    IN OUT NOCOPY VARCHAR2,
   x_msg_count        IN OUT NOCOPY NUMBER,
   x_msg_data         IN OUT NOCOPY VARCHAR2);
--}

--{For Cross Currency this procedure needs to be called externally
PROCEDURE update_from_gt
(p_from_amt            IN NUMBER,
 p_from_acctd_amt      IN NUMBER,
 p_ae_sys_rec          IN arp_acct_main.ae_sys_rec_type,
 p_app_rec             IN ar_receivable_applications%ROWTYPE,
 p_gt_id               IN VARCHAR2 DEFAULT NULL,
 p_inv_currency        IN VARCHAr2 DEFAULT NULL);
--}


--{ Diagnostic
g_diag_flag           VARCHAR2(30) := 'NOT_SET';
PROCEDURE get_diag_flag;
PROCEDURE diag_data(p_gt_id  IN NUMBER DEFAULT NULL);

PROCEDURE Reconciliation
(p_app_rec             IN ar_receivable_applications%ROWTYPE,
 p_adj_rec             IN ar_adjustments%ROWTYPE,
 p_activity_type       IN VARCHAR2,
 p_gt_id               IN VARCHAR2 DEFAULT NULL);
--}

--{BUG#5098099
PROCEDURE check_legacy_status
  (p_trx_id           IN  NUMBER,
   p_adj_id           IN  NUMBER DEFAULT NULL,
   p_app_id           IN  NUMBER DEFAULT NULL,
   x_11i_adj          OUT NOCOPY  VARCHAR2,
   x_mfar_adj         OUT NOCOPY  VARCHAR2,
   x_11i_app          OUT NOCOPY  VARCHAR2,
   x_mfar_app         OUT NOCOPY  VARCHAR2);
--}

--{BUG#5412633
PROCEDURE exec_revrec_if_required
(p_init_msg_list    IN         VARCHAR2  DEFAULT FND_API.G_TRUE
,p_mode             IN         VARCHAR2  DEFAULT 'TRANSACTION'
,p_customer_trx_id  IN         NUMBER    DEFAULT NULL
,p_request_id       IN         NUMBER    DEFAULT NULL
,x_sum_dist         OUT NOCOPY NUMBER
,x_return_status    OUT NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER
,x_msg_data         OUT NOCOPY VARCHAR2);

PROCEDURE set_original_rem_amt_r12
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 x_return_status   IN  OUT NOCOPY VARCHAR2,
 x_msg_count        IN OUT NOCOPY NUMBER,
 x_msg_data         IN OUT NOCOPY VARCHAR2,
 p_from_llca        IN VARCHAR2 DEFAULT 'N');

PROCEDURE set_original_rem_amt_r12(p_request_id     IN NUMBER);

PROCEDURE verify_stamp_merge_dist_method
(p_customer_trx_id IN         NUMBER,
 x_upg_method      IN OUT NOCOPY VARCHAR2);

END;

/
