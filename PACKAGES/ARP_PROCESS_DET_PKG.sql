--------------------------------------------------------
--  DDL for Package ARP_PROCESS_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_PROCESS_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: ARDLAPPS.pls 120.7.12010000.1 2008/07/24 16:25:14 appldev ship $ */


/*-----------------------------------------------------------------------------+
 | Procedure   initialization                                                  |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |            p_customer_trx_id    invoice ID                                  |
 |            p_cash_receipt_id    receipt ID                                  |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |    1) Call arp_det_dist_pkg to copy trx line into ra_customer_trx_lines_gt  |
 |    2) Call get_inv_ps to cache the invoice payment schedule                 |
 +-----------------------------------------------------------------------------*/
PROCEDURE initialization
(p_customer_trx_id IN         NUMBER,
 p_cash_receipt_id IN         NUMBER,
 x_return_status   OUT NOCOPY VARCHAR2,
 x_msg_data        OUT NOCOPY VARCHAR2,
 x_msg_count       OUT NOCOPY NUMBER);


/*-----------------------------------------------------------------------------+
 | Procedure   application_execute                                             |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_level      Application Level (TRANSACTION/GROUP/LINE)               |
 |   p_group_id       Group_id req when Application level is GROUP             |
 |   p_ctl_id         customer_trx_line_id required when the application level |
 |                    is LINE                                                  |
 |   p_line_applied      Line amount applied                                   |
 |   p_tax_applied       Tax amount applied                                    |
 |   p_freight_applied   Freight amount applied                                |
 |   p_charges_applied   Charge amount applied                                 |
 |   --                                                                        |
 |   p_line_ediscounted  Earned Discount on Revenue                            |
 |   p_tax_ediscounted   Earned Discount on Tax                                |
 |   p_freight_ediscounted    Earned Discount on Freight                       |
 |   p_charges_ediscounted    Earned Discount on charge                        |
 |   --                                                                        |
 |   p_line_uediscounted  Unearned Discount on Revenue                         |
 |   p_tax_uediscounted   Unearned Discount on Tax                             |
 |   p_freight_uediscounted   Unearned Discount on Freight                     |
 |   p_charges_uediscounted   Unearned Discount on charge                      |
 |   p_customer_trx        Invoice record                                      |
 |   p_ae_sys_rec          Receivable system parameters                        |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |    1) Call cur_app_gt_id to looking for current apps                        |
 |    2) If found then call delete_application                                 |
 |    3) Call apply to do the application                                      |
 +-----------------------------------------------------------------------------*/
PROCEDURE application_execute
( p_app_level                      IN VARCHAR2,
  --
  p_source_data_key1               IN VARCHAR2,
  p_source_data_key2               IN VARCHAR2,
  p_source_data_key3               IN VARCHAR2,
  p_source_data_key4               IN VARCHAR2,
  p_source_data_key5               IN VARCHAR2,
  --
  p_ctl_id                         IN NUMBER,
  --
  p_line_applied                   IN NUMBER,
  p_tax_applied                    IN NUMBER,
  p_freight_applied                IN NUMBER,
  p_charges_applied                IN NUMBER,
  --
  p_line_ediscounted               IN NUMBER,
  p_tax_ediscounted                IN NUMBER,
  p_freight_ediscounted            IN NUMBER,
  p_charges_ediscounted            IN NUMBER,
  --
  p_line_uediscounted              IN NUMBER,
  p_tax_uediscounted               IN NUMBER,
  p_freight_uediscounted           IN NUMBER,
  p_charges_uediscounted           IN NUMBER,
  --
  x_return_status                  OUT NOCOPY VARCHAR2,
  x_msg_count                      OUT NOCOPY NUMBER,
  x_msg_data                       OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure   final_commit                                                    |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_customer_trx          Invoice record                                    |
 | Out                                                                         |
 |   x_ra_id                   receivable_application_id                       |
 |   x_amount_applied          the amount applied                              |
 |   x_amount_applied_from     the amount applied from                         |
 |   x_earned_discount_taken   the amount earned discounted                    |
 |   x_unearned_discount_taken the amount unearned discounted                  |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 | Return the information amount to be used by receipt_application             |
 |    Note arp_process_application.receipt_application will be modified to have|
 |    the receivable_application_id for the APP record as a input param        |
 | Call arp_det_dist_pkg.final_update_inv_ctl_rem_orig to update line balance  |
 | Call arp_det_dist_pkg.create_final_split to create detail application dist  |
 +-----------------------------------------------------------------------------*/
PROCEDURE final_commit
(p_gl_date                     IN  DATE,
 p_apply_date                  IN  DATE,
 p_attribute_category          IN VARCHAR2  DEFAULT NULL,
 p_attribute1                  IN VARCHAR2  DEFAULT NULL,
 p_attribute2                  IN VARCHAR2  DEFAULT NULL,
 p_attribute3                  IN VARCHAR2  DEFAULT NULL,
 p_attribute4                  IN VARCHAR2  DEFAULT NULL,
 p_attribute5                  IN VARCHAR2  DEFAULT NULL,
 p_attribute6                  IN VARCHAR2  DEFAULT NULL,
 p_attribute7                  IN VARCHAR2  DEFAULT NULL,
 p_attribute8                  IN VARCHAR2  DEFAULT NULL,
 p_attribute9                  IN VARCHAR2  DEFAULT NULL,
 p_attribute10                 IN VARCHAR2  DEFAULT NULL,
 p_attribute11                 IN VARCHAR2  DEFAULT NULL,
 p_attribute12                 IN VARCHAR2  DEFAULT NULL,
 p_attribute13                 IN VARCHAR2  DEFAULT NULL,
 p_attribute14                 IN VARCHAR2  DEFAULT NULL,
 p_attribute15                 IN VARCHAR2  DEFAULT NULL,
 p_global_attribute_category   IN VARCHAR2  DEFAULT NULL,
 p_global_attribute1           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute2           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute3           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute4           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute5           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute6           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute7           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute8           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute9           IN VARCHAR2  DEFAULT NULL,
 p_global_attribute10          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute11          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute12          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute13          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute14          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute15          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute16          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute17          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute18          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute19          IN VARCHAR2  DEFAULT NULL,
 p_global_attribute20          IN VARCHAR2  DEFAULT NULL,
 p_comments                    IN VARCHAR2  DEFAULT NULL,
 --{Cross Currency
 p_amount_applied_from         IN NUMBER    DEFAULT NULL,
 p_trans_to_receipt_rate       IN NUMBER    DEFAULT NULL,
 --}
 x_ra_rec                  OUT NOCOPY ar_receivable_applications%ROWTYPE,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_msg_count               OUT NOCOPY NUMBER,
 x_msg_data                OUT NOCOPY VARCHAR2);

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
(p_app_level         IN VARCHAR2 DEFAULT 'TRANSACTION',
 --
 p_source_data_key1  IN VARCHAR2 DEFAULT NULL,
 p_source_data_key2  IN VARCHAR2 DEFAULT NULL,
 p_source_data_key3  IN VARCHAR2 DEFAULT NULL,
 p_source_data_key4  IN VARCHAR2 DEFAULT NULL,
 p_source_data_key5  IN VARCHAR2 DEFAULT NULL,
 --
 p_ctl_id            IN NUMBER   DEFAULT NULL,
 x_line_rem          OUT NOCOPY  NUMBER,
 x_tax_rem           OUT NOCOPY  NUMBER,
 x_freight_rem       OUT NOCOPY  NUMBER,
 x_charges_rem       OUT NOCOPY  NUMBER,
 x_return_status     OUT NOCOPY  VARCHAR2,
 x_msg_data          OUT NOCOPY  VARCHAR2,
 x_msg_count         OUT NOCOPY  NUMBER);

/*-----------------------------------------------------------------------------+
 | Procedure   get_latest_amount_applied                                       |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_customer_trx_id The invoice ID                                          |
 |   p_app_level      Application Level (TRANSACTION/GROUP/LINE)               |
 |   p_group_id       Group_id req when Application level is GROUP             |
 |   p_ctl_id         customer_trx_line_id required when the application level |
 |                    is LINE                                                  |
 |   OUT                                                                       |
 |  x_line_app      The applied revenue amount for the level                   |
 |  x_tax_app       The applied tax amount for the level                       |
 |  x_freight_app   The applied freight amount for the level TRANSACTION only  |
 |  x_charges_app   The applied charges amount for the level TRANSACTION only  |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |  Read the applied amount on ar_line_aplication_detail_gt                    |
 +-----------------------------------------------------------------------------*/
PROCEDURE get_latest_amount_applied
(p_app_level          IN VARCHAR2 DEFAULT 'TRANSACTION',
 --
 p_source_data_key1   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key2   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key3   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key4   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key5   IN VARCHAR2 DEFAULT NULL,
 p_ctl_id             IN NUMBER   DEFAULT NULL,
 p_log_inv_line       IN VARCHAR2 DEFAULT 'Y',
 --
 x_line_app           OUT NOCOPY  NUMBER,
 x_tax_app            OUT NOCOPY  NUMBER,
 x_freight_app        OUT NOCOPY  NUMBER,
 x_charges_app        OUT NOCOPY  NUMBER,
 --
 x_line_ed            OUT NOCOPY  NUMBER,
 x_tax_ed             OUT NOCOPY  NUMBER,
 x_freight_ed         OUT NOCOPY  NUMBER,
 x_charges_ed         OUT NOCOPY  NUMBER,
 --
 x_line_uned          OUT NOCOPY  NUMBER,
 x_tax_uned           OUT NOCOPY  NUMBER,
 x_freight_uned       OUT NOCOPY  NUMBER,
 x_charges_uned       OUT NOCOPY  NUMBER,
 --
 x_return_status      OUT NOCOPY  VARCHAR2,
 x_msg_data           OUT NOCOPY  VARCHAR2,
 x_msg_count          OUT NOCOPY  NUMBER);

PROCEDURE get_app_ra_amounts
(p_gt_id                       IN NUMBER,
 x_ra_rec                      IN OUT NOCOPY ar_receivable_applications%ROWTYPE);


-- Common interface for detail distributions
FUNCTION base_for_proration
(p_customer_trx_id   IN NUMBER,
 p_gt_id             IN NUMBER,
 p_line_type         IN VARCHAR2,
 p_activity          IN VARCHAR2)
RETURN  NUMBER;

FUNCTION element_for_proration
(p_customer_trx_id        IN NUMBER,
 p_customer_trx_line_id   IN NUMBER,
 p_gt_id                  IN NUMBER,
 p_line_type              IN VARCHAR2,
 p_activity               IN VARCHAR2)
RETURN  NUMBER;

PROCEDURE verif_int_adj_line_tax
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 p_adj_rec          IN ar_adjustments%ROWTYPE,
 p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
 p_gt_id            IN NUMBER,
 p_line_flag        IN VARCHAR2 DEFAULT 'INTERFACE',
 p_tax_flag         IN VARCHAR2 DEFAULT 'INTERFACE',
 x_return_status    IN OUT NOCOPY VARCHAR2);


PROCEDURE verif_int_app_line_tax
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
 x_return_status    IN OUT NOCOPY VARCHAR2);


PROCEDURE breakup_discounts (
  lin_discount_in in  		 NUMBER,
  tax_discount_in in 		 NUMBER,
  frt_discount_in in 		 NUMBER,
  tot_earned_discount_in in 		 NUMBER,
  tot_unearned_discount_in in 		 NUMBER,
  ed_lin_out out nocopy number,
  ued_lin_out out nocopy number,
  ed_tax_out out nocopy number,
  ued_tax_out out nocopy number,
  ed_frt_out out nocopy number,
  ued_frt_out out nocopy number
);




END arp_process_det_pkg;

/
