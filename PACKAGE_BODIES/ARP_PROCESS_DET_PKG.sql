--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_DET_PKG" AS
/* $Header: ARDLAPPB.pls 120.20.12010000.8 2010/05/12 03:03:27 nemani ship $*/
g_gt_id              NUMBER := 0;
g_payschedule_trx    ar_payment_schedules%ROWTYPE;
g_payschedule_rec    ar_payment_schedules%ROWTYPE;
g_payschedule_clr    ar_payment_schedules%ROWTYPE;
g_app_ra_id          NUMBER;
g_bulk_fetch_rows    NUMBER := 10000;
g_customer_trx       ra_customer_trx%ROWTYPE;
g_ae_sys_rec         arp_acct_main.ae_sys_rec_type;
g_cash_receipt       ar_cash_receipts%ROWTYPE;

g_unapplied_ccid     NUMBER;
g_ed_ccid            NUMBER;
g_uned_ccid          NUMBER;
g_unidentified_ccid  NUMBER;
g_clearing_ccid      NUMBER;
g_remittance_ccid    NUMBER;
g_cash_ccid          NUMBER;
g_on_account_ccid    NUMBER;
g_factor_ccid        NUMBER;
g_inv_rec_ccid       NUMBER;


------------------------Local procedures -----
/*-----------------------------------------------------------------------------+
 | Procedure get_inv_ps                                                        |
 +-----------------------------------------------------------------------------+
 | Parameter : p_customer_trx_id     invoice ID                                |
 | Action    : Copy the invoice payment schedule into g_payschedule_trx global |
 +-----------------------------------------------------------------------------*/
PROCEDURE get_inv_ps
(x_return_status     IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure get_rec_ps                                                        |
 +-----------------------------------------------------------------------------+
 | Parameter : p_cr_id      CR ID                                              |
 | Action    : Copy the receipt payment schedule into g_payschedule_rec global |
 +-----------------------------------------------------------------------------*/
PROCEDURE get_rec_ps
(p_cr_id             IN            NUMBER,
 x_return_status     IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure upd_inv_ps                                                        |
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
 |   p_ps_rec              Payment schedule invoice                            |
 |   p_ae_sys_rec          Receivable system parameters                        |
 |   --                                                                        |
 |   x_apps_rec           Out variable containing the ar_receivable_apps_gt rec|
 +-----------------------------------------------------------------------------+
 | Action    : Compute payment schedule effect based on amount arguments       |
 |             then update the global variable g_payschedule_rec               |
 |             Return a record ar_receivable_apps_gt type with the amount info |
 +-----------------------------------------------------------------------------*/
PROCEDURE upd_inv_ps(
  p_app_level                      IN VARCHAR2,
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
  p_ps_rec                         IN ar_payment_schedules%ROWTYPE,
  --
  x_app_rec                        OUT     NOCOPY ar_receivable_apps_gt%ROWTYPE,
  x_return_status                  IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure insert_rapps_p                                                    |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :  insert p_rec_apps in ar_receivable_apps_gt                     |
 +-----------------------------------------------------------------------------*/
PROCEDURE insert_rapps_p
(p_app_rec           IN ar_receivable_apps_gt%ROWTYPE,
 x_return_status     IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure res_ctl_rem_amt_for_app                                           |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :  restore the amounts in the ra_customer_trx_lines_gt            |
 +-----------------------------------------------------------------------------*/
PROCEDURE res_ctl_rem_amt_for_app
(p_app_rec           IN ar_receivable_apps_gt%ROWTYPE,
 x_return_status     IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure res_inv_ps                                                        |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :  restore the amounts in the g_payschedule_trx based on the input|
 +-----------------------------------------------------------------------------*/
PROCEDURE res_inv_ps
(p_app_rec           IN ar_receivable_apps_gt%ROWTYPE,
 x_return_status     IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure delete_application                                                |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |     1) Call res_inv_ps to restore payment schedule                          |
 |     2) Call res_ctl_rem_amt_for_app to restore the ra_customer_trx_lines_gt |
 |         amounts                                                             |
 |     3) Delete the record from ar_receivable_apps_gt                         |
 +-----------------------------------------------------------------------------*/
PROCEDURE delete_application
(p_app_rec           IN ar_receivable_apps_gt%ROWTYPE,
 x_return_status     IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure do_apply                                                          |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 |   p_customer_trx   invoice record                                           |
 |   p_ae_sys_rec     receivable system parameter                              |
 |   p_gt_id          global ID                                                |
 +-----------------------------------------------------------------------------+
 | Action    :  Call arp_det_dist_pkg to do the application                    |
 +-----------------------------------------------------------------------------*/
PROCEDURE do_apply
(p_app_rec           IN ar_receivable_apps_gt%ROWTYPE,
 p_gt_id             IN            VARCHAR2,
 x_return_status     IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | Procedure    apply                                                          |
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
 |            1) Call upd_inv_ps                                               |
 |            2) Call do_apply                                                 |
 +-----------------------------------------------------------------------------*/
PROCEDURE apply
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
  x_return_status                  IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------------------+
 | FUNCTION cur_app_gt_id                                                      |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |    p_app_level      Application level TRANSACTION/GROUP/LINE                |
 |    p_group_id       Group_id required if level is GROUP                     |
 |    p_ctl_id         customer_trx_line_id required if level is LINE          |
 |  Out variable                                                               |
 |    x_app_rec        return the current ar_receivable_apps_gt record matching|
 |                     the search criteria in ar_receivable_apps_gt            |
 |  Return :                                                                   |
 |    Gt_id of that record matching the search criteria                        |
 |    If no row found the n returns NO_GT_ID                                   |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |  Search for the current ar_receivable_apps_gt record that match the criteria|
 +-----------------------------------------------------------------------------*/
FUNCTION cur_app_gt_id
( p_app_level         IN VARCHAR2,
  --
  p_source_data_key1  IN VARCHAR2,
  p_source_data_key2  IN VARCHAR2,
  p_source_data_key3  IN VARCHAR2,
  p_source_data_key4  IN VARCHAR2,
  p_source_data_key5  IN VARCHAR2,
  --
  p_ctl_id            IN NUMBER,
  x_app_rec           OUT NOCOPY ar_receivable_apps_gt%ROWTYPE)
RETURN VARCHAR2;


PROCEDURE dump_payschedule(p_ps_rec  IN ar_payment_schedules%ROWTYPE);



--
PROCEDURE get_trx_db_app
( x_line_app    OUT NOCOPY NUMBER,
  x_tax_app     OUT NOCOPY NUMBER,
  x_frt_app     OUT NOCOPY NUMBER,
  x_chrg_app    OUT NOCOPY NUMBER,
  x_line_ed     OUT NOCOPY NUMBER,
  x_tax_ed      OUT NOCOPY NUMBER,
  x_frt_ed      OUT NOCOPY NUMBER,
  x_chrg_ed     OUT NOCOPY NUMBER,
  x_line_uned   OUT NOCOPY NUMBER,
  x_tax_uned    OUT NOCOPY NUMBER,
  x_frt_uned    OUT NOCOPY NUMBER,
  x_chrg_uned   OUT NOCOPY NUMBER)
IS
CURSOR c_trx_db IS
   SELECT SUM( DECODE (activity_bucket,'APP_LINE',amt,0)),
          SUM( DECODE (activity_bucket,'APP_TAX' ,amt,0)),
          SUM( DECODE (activity_bucket,'APP_FRT' ,amt,0)),
          SUM( DECODE (activity_bucket,'APP_CHRG',amt,0)),
          SUM( DECODE (activity_bucket,'ED_LINE' ,amt,0)),
          SUM( DECODE (activity_bucket,'ED_TAX'  ,amt,0)),
          SUM( DECODE (activity_bucket,'ED_FRT'  ,amt,0)),
          SUM( DECODE (activity_bucket,'ED_CHRG' ,amt,0)),
          SUM( DECODE (activity_bucket,'UNED_LINE' ,amt,0)),
          SUM( DECODE (activity_bucket,'UNED_TAX'  ,amt,0)),
          SUM( DECODE (activity_bucket,'UNED_FRT'  ,amt,0)),
          SUM( DECODE (activity_bucket,'UNED_CHRG' ,amt,0))
   FROM (SELECT ctl.line_type,
                ctl.customer_trx_line_id,
                ctl.link_to_cust_trx_line_id,
                NVL(ctl.link_to_cust_trx_line_id,ctl.customer_trx_line_id),
                amt_tab.amt,
                amt_tab.activity_bucket,
                amt_tab.ref_account_class
          FROM ra_customer_trx_lines_all                                                         ctl,
              (select SUM(NVL(ard.amount_cr,0) - NVL(ard.amount_dr,0))           amt,
                      ard.activity_bucket                                                 activity_bucket,
                      ard.ref_account_class                                              ref_account_class,
                      ard.ref_customer_trx_line_id                               ref_customer_trx_line_id
                 from ar_distributions_all ard
                WHERE ard.source_table = 'RA'
                  AND ard.source_id IN
                     (select receivable_application_id
                        from ar_receivable_applications_all
                       where applied_customer_trx_id =   g_customer_trx.customer_trx_id)
                GROUP BY ard.activity_bucket,
                         ard.ref_account_class,
                         ard.ref_customer_trx_line_id)                                            amt_tab
         WHERE ctl.customer_trx_line_id = amt_tab.ref_customer_trx_line_id);
BEGIN
arp_standard.debug(' get_trx_db_app +');
  OPEN c_trx_db;
  FETCH c_trx_db INTO x_line_app ,
                      x_tax_app  ,
                      x_frt_app  ,
                      x_chrg_app ,
                      x_line_ed  ,
                      x_tax_ed   ,
                      x_frt_ed   ,
                      x_chrg_ed  ,
                      x_line_uned,
                      x_tax_uned ,
                      x_frt_uned ,
                      x_chrg_uned;
  IF c_trx_db%NOTFOUND THEN
    x_line_app := 0;
    x_tax_app  := 0;
    x_frt_app  := 0;
    x_chrg_app := 0;
    x_line_ed  := 0;
    x_tax_ed   := 0;
    x_frt_ed   := 0;
    x_chrg_ed  := 0;
    x_line_uned:= 0;
    x_tax_uned := 0;
    x_frt_uned := 0;
    x_chrg_uned:= 0;
  END IF;
  CLOSE c_trx_db;
arp_standard.debug('   x_line_app   '||x_line_app);
arp_standard.debug('   x_tax_app    '||x_tax_app);
arp_standard.debug('   x_frt_app    '||x_frt_app);
arp_standard.debug('   x_chrg_app   '||x_chrg_app);
arp_standard.debug('   x_line_ed    '||x_line_ed);
arp_standard.debug('   x_tax_ed     '||x_tax_ed);
arp_standard.debug('   x_frt_ed     '||x_frt_ed);
arp_standard.debug('   x_chrg_ed    '||x_chrg_ed);
arp_standard.debug('   x_line_uned  '||x_line_uned);
arp_standard.debug('   x_tax_uned   '||x_tax_uned);
arp_standard.debug('   x_frt_uned   '||x_frt_uned);
arp_standard.debug('   x_chrg_uned  '||x_chrg_uned);
arp_standard.debug(' get_trx_db_app -');
END;

PROCEDURE get_group_db_app
(p_source_data_key1   IN VARCHAR2,
 p_source_data_key2   IN VARCHAR2,
 p_source_data_key3   IN VARCHAR2,
 p_source_data_key4   IN VARCHAR2,
 p_source_data_key5   IN VARCHAR2,
 --
 x_line_app    OUT NOCOPY NUMBER,
 x_tax_app     OUT NOCOPY NUMBER,
 x_line_ed     OUT NOCOPY NUMBER,
 x_tax_ed      OUT NOCOPY NUMBER,
 x_line_uned   OUT NOCOPY NUMBER,
 x_tax_uned    OUT NOCOPY NUMBER)
IS
CURSOR c_group_db
(p_source_data_key1   IN VARCHAR2,
 p_source_data_key2   IN VARCHAR2,
 p_source_data_key3   IN VARCHAR2,
 p_source_data_key4   IN VARCHAR2,
 p_source_data_key5   IN VARCHAR2)
IS
SELECT SUM( DECODE (activity_bucket,'APP_LINE',amt,0)),
       SUM( DECODE (activity_bucket,'APP_TAX' ,amt,0)),
       SUM( DECODE (activity_bucket,'ED_LINE' ,amt,0)),
       SUM( DECODE (activity_bucket,'ED_TAX'  ,amt,0)),
       SUM( DECODE (activity_bucket,'UNED_LINE' ,amt,0)),
       SUM( DECODE (activity_bucket,'UNED_TAX'  ,amt,0))
FROM (
SELECT ctl.line_type,
       ctl.customer_trx_line_id,
       ctl.link_to_cust_trx_line_id,
       NVL(ctl.link_to_cust_trx_line_id,ctl.customer_trx_line_id),
       amt_tab.amt,
       amt_tab.activity_bucket,
       amt_tab.ref_account_class,
       ctl.source_data_key1,
       ctl.source_data_key2,
       ctl.source_data_key3,
       ctl.source_data_key4,
       ctl.source_data_key5
  FROM ra_customer_trx_lines_gt                                                         ctl,
      (select SUM(NVL(ard.amount_cr,0) - NVL(ard.amount_dr,0))           amt,
              ard.activity_bucket                                                 activity_bucket,
              ard.ref_account_class                                              ref_account_class,
              ard.ref_customer_trx_line_id                               ref_customer_trx_line_id
       from ar_distributions_all ard
       WHERE ard.source_table = 'RA'
         AND ard.source_id IN
             (select receivable_application_id
                from ar_receivable_applications_all
               where applied_customer_trx_id = g_customer_trx.customer_trx_id)
      GROUP BY ard.activity_bucket,
               ard.ref_account_class,
               ard.ref_customer_trx_line_id)                                            amt_tab
 WHERE ctl.customer_trx_line_id = amt_tab.ref_customer_trx_line_id
   AND ctl.source_data_key1     = NVL(p_source_data_key1,'00')
   AND ctl.source_data_key2     = NVL(p_source_data_key2,'00')
   AND ctl.source_data_key3     = NVL(p_source_data_key3,'00')
   AND ctl.source_data_key4     = NVL(p_source_data_key4,'00')
   AND ctl.source_data_key5     = NVL(p_source_data_key5,'00'));
BEGIN
arp_standard.debug(' get_group_db_app +');
arp_standard.debug('   p_source_data_key1   '||p_source_data_key1);
arp_standard.debug('   p_source_data_key2   '||p_source_data_key2);
arp_standard.debug('   p_source_data_key3   '||p_source_data_key3);
arp_standard.debug('   p_source_data_key4   '||p_source_data_key4);
arp_standard.debug('   p_source_data_key5   '||p_source_data_key5);
  OPEN c_group_db
   (p_source_data_key1 => p_source_data_key1,
    p_source_data_key2 => p_source_data_key2,
    p_source_data_key3 => p_source_data_key3,
    p_source_data_key4 => p_source_data_key4,
    p_source_data_key5 => p_source_data_key5);
  FETCH c_group_db INTO x_line_app ,
                        x_tax_app  ,
                        x_line_ed  ,
                        x_tax_ed   ,
                        x_line_uned,
                        x_tax_uned ;
  IF c_group_db%NOTFOUND THEN
     x_line_app  := 0;
     x_tax_app   := 0;
     x_line_ed   := 0;
     x_tax_ed    := 0;
     x_line_uned := 0;
     x_tax_uned  := 0;
  END IF;
  CLOSE c_group_db;
arp_standard.debug('   x_line_app   '||x_line_app);
arp_standard.debug('   x_tax_app    '||x_tax_app);
arp_standard.debug('   x_line_ed    '||x_line_ed);
arp_standard.debug('   x_tax_ed     '||x_tax_ed);
arp_standard.debug('   x_line_uned  '||x_line_uned);
arp_standard.debug('   x_tax_uned   '||x_tax_uned);
arp_standard.debug(' get_group_db_app -');
END;

PROCEDURE get_log_line_db_app
(p_log_line_id IN  NUMBER,
 --
 x_line_app    OUT NOCOPY NUMBER,
 x_tax_app     OUT NOCOPY NUMBER,
 x_line_ed     OUT NOCOPY NUMBER,
 x_tax_ed      OUT NOCOPY NUMBER,
 x_line_uned   OUT NOCOPY NUMBER,
 x_tax_uned    OUT NOCOPY NUMBER)
IS
CURSOR c_log_line(p_log_line_id   IN NUMBER) IS
SELECT app_line,
       app_tax,
       ed_line,
       ed_tax,
       uned_line,
       uned_tax
FROM(
(SELECT SUM( DECODE (activity_bucket,'APP_LINE',amt,0))  app_line,
       SUM( DECODE (activity_bucket,'APP_TAX' ,amt,0))   app_tax,
       SUM( DECODE (activity_bucket,'ED_LINE' ,amt,0))   ed_line,
       SUM( DECODE (activity_bucket,'ED_TAX'  ,amt,0))   ed_tax,
       SUM( DECODE (activity_bucket,'UNED_LINE' ,amt,0)) uned_line,
       SUM( DECODE (activity_bucket,'UNED_TAX'  ,amt,0)) uned_tax,
       log_line_id                              log_line_id
FROM (SELECT ctl.line_type,
             ctl.customer_trx_line_id,
             ctl.link_to_cust_trx_line_id,
             NVL(ctl.link_to_cust_trx_line_id,ctl.customer_trx_line_id)  log_line_id,
             amt_tab.amt,
             amt_tab.activity_bucket,
             amt_tab.ref_account_class,
             ctl.source_data_key1,
             ctl.source_data_key2,
             ctl.source_data_key3,
             ctl.source_data_key4,
             ctl.source_data_key5
        FROM ra_customer_trx_lines_gt                                                         ctl,
            (select SUM(NVL(ard.amount_cr,0) - NVL(ard.amount_dr,0))           amt,
                    ard.activity_bucket                                                 activity_bucket,
                    ard.ref_account_class                                              ref_account_class,
                    ard.ref_customer_trx_line_id                               ref_customer_trx_line_id
               from ar_distributions_all ard
              WHERE ard.source_table = 'RA'
                AND ard.source_id IN
                   (select receivable_application_id
                      from ar_receivable_applications_all
                     where applied_customer_trx_id =  g_customer_trx.customer_trx_id)
              GROUP BY ard.activity_bucket,
                       ard.ref_account_class,
                       ard.ref_customer_trx_line_id)                                            amt_tab
       WHERE ctl.customer_trx_line_id = amt_tab.ref_customer_trx_line_id       )
GROUP BY log_line_id))     log_line_tab
WHERE log_line_tab.log_line_id = p_log_line_id;
BEGIN
arp_standard.debug(' get_log_line_db_app +');
arp_standard.debug('   p_log_line_id   '||p_log_line_id);
  OPEN c_log_line(p_log_line_id  => p_log_line_id);
  FETCH c_log_line INTO  x_line_app ,
                         x_tax_app  ,
                         x_line_ed  ,
                         x_tax_ed   ,
                         x_line_uned,
                         x_tax_uned ;
  IF c_log_line%NOTFOUND THEN
     x_line_app    := 0;
     x_tax_app     := 0;
     x_line_ed     := 0;
     x_tax_ed      := 0;
     x_line_uned   := 0;
     x_tax_uned    := 0;
  END IF;
  CLOSE c_log_line;
arp_standard.debug('   x_line_app   '||x_line_app);
arp_standard.debug('   x_tax_app    '||x_tax_app);
arp_standard.debug('   x_line_ed    '||x_line_ed);
arp_standard.debug('   x_tax_ed     '||x_tax_ed);
arp_standard.debug('   x_line_uned  '||x_line_uned);
arp_standard.debug('   x_tax_uned   '||x_tax_uned);
arp_standard.debug(' get_log_line_db_app -');
END;


-- procedures and functions Body

PROCEDURE dump_payschedule(p_ps_rec  IN ar_payment_schedules%ROWTYPE)
IS
BEGIN
arp_standard.debug('p_ps_rec.amount_applied               :'||p_ps_rec.amount_applied);
arp_standard.debug('p_ps_rec.discount_taken_earned        :'||p_ps_rec.discount_taken_earned);
arp_standard.debug('p_ps_rec.discount_taken_unearned      :'||p_ps_rec.discount_taken_unearned);
arp_standard.debug('p_ps_rec.discount_remaining           :'||p_ps_rec.discount_remaining);
arp_standard.debug('p_ps_rec.amount_line_items_remaining  :'||p_ps_rec.amount_line_items_remaining);
arp_standard.debug('p_ps_rec.receivables_charges_remaining:'||p_ps_rec.receivables_charges_remaining);
arp_standard.debug('p_ps_rec.tax_remaining                :'||p_ps_rec.tax_remaining);
arp_standard.debug('p_ps_rec.freight_remaining            :'||p_ps_rec.freight_remaining);
END dump_payschedule;

PROCEDURE dump_sys_param
IS
BEGIN
  arp_standard.debug('g_ae_sys_rec.set_of_books_id  :'||g_ae_sys_rec.set_of_books_id);
  arp_standard.debug('g_ae_sys_rec.coa_id           :'||g_ae_sys_rec.coa_id);
  arp_standard.debug('g_ae_sys_rec.base_currency    :'||g_ae_sys_rec.base_currency);
  arp_standard.debug('g_ae_sys_rec.base_precision   :'||g_ae_sys_rec.base_precision);
  arp_standard.debug('g_ae_sys_rec.base_min_acc_unit:'||g_ae_sys_rec.base_min_acc_unit);
  arp_standard.debug('g_ae_sys_rec.gain_cc_id       :'||g_ae_sys_rec.gain_cc_id);
  arp_standard.debug('g_ae_sys_rec.loss_cc_id       :'||g_ae_sys_rec.loss_cc_id);
  arp_standard.debug('g_ae_sys_rec.round_cc_id      :'||g_ae_sys_rec.round_cc_id);
  arp_standard.debug('g_ae_sys_rec.SOB_TYPE         :'||g_ae_sys_rec.SOB_TYPE);
END dump_sys_param;

/*-----------------------------------------------------------------------------+
 | Procedure get_inv_ps                                                        |
 +-----------------------------------------------------------------------------+
 | Parameter : p_customer_trx_id     invoice ID                                |
 | Action    : Copy the invoice payment schedule into g_payschedule_trx global |
 +-----------------------------------------------------------------------------*/
PROCEDURE get_inv_ps
(x_return_status     IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_ps IS
  SELECT *
    FROM ar_payment_schedules
   WHERE class           in ('INV','DM')   /* Bug 5189370 */
     AND customer_trx_id = g_customer_trx.customer_trx_id
     AND status          = 'OP';
  l_cpt                      NUMBER := 0;
  l_inv_ps                   ar_payment_schedules%ROWTYPE;
  no_installed_inv_allowed   EXCEPTION;
  no_op_trx_pay_schedule     EXCEPTION;
  no_customer_trx_cache      EXCEPTION;
BEGIN
  arp_standard.debug('get_inv_ps +');
  arp_standard.debug('   g_customer_trx.customer_trx_id :'||g_customer_trx.customer_trx_id);
  IF g_customer_trx.customer_trx_id IS NULL THEN
    RAISE no_customer_trx_cache;
  END IF;
  OPEN c_ps;
  LOOP
    IF l_cpt > 1 THEN
      CLOSE c_ps;
      RAISE no_installed_inv_allowed;
    END IF;
    FETCH c_ps INTO l_inv_ps;
    EXIT WHEN c_ps%NOTFOUND;
    l_cpt := l_cpt + 1;
  END LOOP;
  CLOSE c_ps;
  IF l_cpt = 0 THEN
    RAISE no_op_trx_pay_schedule;
  ELSE
    g_payschedule_trx := l_inv_ps;
  END IF;
--  dump_payschedule(g_payschedule_trx);
  arp_standard.debug('get_inv_ps -');
EXCEPTION
  WHEN no_customer_trx_cache    THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_inv_ps-no_customer_trx_cache
 Please verify if initialization has been successfully' );
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    arp_standard.debug
     ('EXCEPTION get_inv_ps no_installed_inv_allowed customer_trx_id '||g_customer_trx.customer_trx_id);
  WHEN no_installed_inv_allowed THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_inv_ps-no_installed_inv_allowed customer_trx_id:'
                          ||g_customer_trx.customer_trx_id);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    arp_standard.debug
     ('EXCEPTION get_inv_ps no_installed_inv_allowed customer_trx_id '||g_customer_trx.customer_trx_id);
  WHEN no_op_trx_pay_schedule   THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_inv_ps-no_open_trx_pay_schedule customer_trx_id:'
                          ||g_customer_trx.customer_trx_id);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    arp_standard.debug
     ('EXCEPTION get_inv_ps no_op_trx_pay_schedule customer_trx_id '||g_customer_trx.customer_trx_id);
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_inv_ps-'||SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    arp_standard.debug('EXCEPTION get_inv_ps OTHERS '||SQLERRM);
END get_inv_ps;


/*-----------------------------------------------------------------------------+
 | Procedure get_rec_ps                                                        |
 +-----------------------------------------------------------------------------+
 | Parameter : p_cr_id      CR ID                                              |
 | Action    : Copy the receipt payment schedule into g_payschedule_rec global |
 +-----------------------------------------------------------------------------*/
PROCEDURE get_rec_ps
(p_cr_id             IN NUMBER,
 x_return_status     IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_ps IS
  SELECT *
    FROM ar_payment_schedules
   WHERE class           = 'PMT'
     AND cash_receipt_id = p_cr_id
     AND status          = 'OP';
  l_cpt                      NUMBER := 0;
  l_rec_ps                   ar_payment_schedules%ROWTYPE;
  no_op_rec_pay_schedule     EXCEPTION;
BEGIN
  arp_standard.debug('get_rec_ps +');
  arp_standard.debug('   p_cr_id :'||p_cr_id);
  OPEN c_ps;
    FETCH c_ps INTO l_rec_ps;
    IF c_ps%NOTFOUND THEN
      RAISE no_op_rec_pay_schedule;
    ELSE
      g_payschedule_rec := l_rec_ps;
    END IF;
  CLOSE c_ps;
  arp_standard.debug('get_rec_ps -');
EXCEPTION
  WHEN no_op_rec_pay_schedule   THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_rec_ps no_open_rec_pay_schedule' );
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    arp_standard.debug
     ('EXCEPTION get_rec_ps no_op_rec_pay_schedule p_cr_id '||p_cr_id);
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_rec_ps:'||SQLERRM );
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    arp_standard.debug
     ('EXCEPTION get_rec_ps OTHERS '||SQLERRM);
END get_rec_ps;


/*-----------------------------------------------------------------------------+
 | Procedure upd_inv_ps                                                        |
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
 |   p_ps_rec              Payment schedule invoice                            |
 |   p_ae_sys_rec          Receivable system parameters                        |
 |   --                                                                        |
 |   x_apps_rec           Out variable containing the ar_receivable_apps_gt rec|
 +-----------------------------------------------------------------------------+
 | Action    : Compute payment schedule effect based on amount arguments       |
 |             then update the global variable g_payschedule_rec               |
 |             Return a record ar_receivable_apps_gt type with the amount info |
 +-----------------------------------------------------------------------------*/
PROCEDURE upd_inv_ps(
  p_app_level                      IN VARCHAR2,
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
  p_ps_rec                         IN ar_payment_schedules%ROWTYPE,
  --
  x_app_rec                        OUT NOCOPY ar_receivable_apps_gt%ROWTYPE,
  x_return_status                  IN OUT NOCOPY VARCHAR2)
IS
l_amount_applied           NUMBER := 0;
l_discount_taken_total     NUMBER:=0;
l_tax_discounted           NUMBER:=0;
l_freight_discounted       NUMBER:=0;
l_line_discounted          NUMBER:=0;
l_charges_discounted       NUMBER:=0;
l_line_remaining           NUMBER:=0;
l_tax_remaining            NUMBER:=0;
l_rec_charges_remaining    NUMBER:=0;
l_freight_remaining        NUMBER:=0;
l_tax_applied              NUMBER:=0;
l_freight_applied          NUMBER:=0;
l_line_applied             NUMBER:=0;
l_charges_applied          NUMBER:=0;
l_tax_ediscounted          NUMBER:=0;
l_freight_ediscounted      NUMBER:=0;
l_line_ediscounted         NUMBER:=0;
l_charges_ediscounted      NUMBER:=0;
l_tax_uediscounted         NUMBER:=0;
l_freight_uediscounted     NUMBER:=0;
l_line_uediscounted        NUMBER:=0;
l_charges_uediscounted     NUMBER:=0;
l_acctd_amount_applied     NUMBER:=0;
l_acctd_earned_discount_taken  NUMBER:=0;
l_acctd_unearned_disc_taken    NUMBER:=0;
l_nocopy_amt_due_remain        NUMBER;
l_nocopy_acctd_amt_due_remain  NUMBER;
l_applied_concern         VARCHAR2(50);
l_earned_concern          VARCHAR2(50);
l_uearned_concern         VARCHAR2(50);
l_apps_rec                ar_receivable_apps_gt%ROWTYPE;
l_gt_id                   VARCHAR2(30);
l_ps_rec                  ar_payment_schedules%ROWTYPE;
l_discount_taken_earned   NUMBER := 0;
l_discount_taken_unearned NUMBER := 0;
neg_app_amt               EXCEPTION;
neg_earned_amt            EXCEPTION;
neg_unearned_amt          EXCEPTION;

  FUNCTION is_bucket_concern
  (p_line_applied     IN         NUMBER,
   p_tax_applied      IN         NUMBER,
   p_freight_applied  IN         NUMBER,
   p_charges_applied  IN         NUMBER,
   x_amount_applied   OUT NOCOPY NUMBER,
   p_bc_ps_rec        IN ar_payment_schedules%ROWTYPE)
  RETURN VARCHAR2
  IS
    l_line_applied     NUMBER;
    l_tax_applied      NUMBER;
    l_freight_applied  NUMBER;
    l_charges_applied   NUMBER;
    l_amount_due_original NUMBER;
    l_acctd_amount_due_original NUMBER;

  BEGIN
    l_line_applied     := NVL(p_line_applied   ,0);
    l_tax_applied      := NVL(p_tax_applied    ,0);
    l_freight_applied  := NVL(p_freight_applied,0);
    l_charges_applied   := NVL(p_charges_applied ,0);
    --
    -- Non negative amount allowed
    --
  arp_standard.debug(' is_bucket_concern(+)' );
  arp_standard.debug(' amount_line_items_original : '||p_bc_ps_rec.amount_line_items_original);
  arp_standard.debug(' tax_original : '||p_bc_ps_rec.tax_original);
  arp_standard.debug(' freight_applied : '||p_bc_ps_rec.freight_original);
  arp_standard.debug(' charges_applied : '||p_bc_ps_rec.RECEIVABLES_CHARGES_CHARGED);

If p_ctl_id IS NOT NULL
Then
    /* Due to rounding issues with the proration some of the lines may end up with
       due_remaining as negative,to let the LLCA go threw for these lines we will
       make use of AMOUNT_DUE_REMAINING sign.Ref bug 7307197 */
    SELECT  nvl(AMOUNT_DUE_REMAINING,AMOUNT_DUE_ORIGINAL)
    INTO l_amount_due_original
    FROM ra_customer_trx_lines
    WHERE customer_trx_line_id  = p_ctl_id;

    IF    (sign(l_line_applied) <> sign(l_amount_due_original)
          AND l_line_applied <> 0)
    THEN   RETURN 'PBLINENEG';
    ELSIF (sign(l_tax_applied) <> sign(l_amount_due_original)
          and l_tax_applied     <> 0 )
    THEN   RETURN 'PBTAXNEG';
    ELSIF (sign(l_freight_applied) <> sign(l_amount_due_original)
          AND l_freight_applied <> 0 )
    THEN   RETURN 'PBFRTNEG';
    ELSIF (sign(l_charges_applied) <> sign(l_amount_due_original)
          AND l_charges_applied <> 0 )
    THEN   RETURN 'PBCHRGNEG';
    END IF;

Else

   IF    (sign(l_line_applied) <> sign(p_bc_ps_rec.amount_line_items_original)
          AND l_line_applied <> 0)
    THEN   RETURN 'PBLINENEG';
    ELSIF (sign(l_tax_applied) <> sign(p_bc_ps_rec.tax_original)
          and l_tax_applied     <> 0 )
    THEN   RETURN 'PBTAXNEG';
    ELSIF ((sign(l_freight_applied) <> sign(p_bc_ps_rec.freight_original)
            AND p_bc_ps_rec.freight_original <> 0)
          AND l_freight_applied <> 0 )
    THEN   RETURN 'PBFRTNEG';
    ELSIF ((sign(l_charges_applied) <> sign(p_bc_ps_rec.RECEIVABLES_CHARGES_CHARGED)
            AND p_bc_ps_rec.RECEIVABLES_CHARGES_CHARGED <> 0)
          AND l_charges_applied <> 0 )
    THEN   RETURN 'PBCHRGNEG';
    END IF;
End If;
    --
    -- If all bucket 0 then not concern
    --
    IF  l_line_applied     = 0 AND
        l_tax_applied      = 0 AND
        l_freight_applied  = 0 AND
        l_charges_applied   = 0
    THEN
       x_amount_applied := 0;
       RETURN 'N';
    ELSE
       x_amount_applied := l_line_applied + l_tax_applied +
                           l_freight_applied + l_charges_applied;
       RETURN 'Y';
    END IF;
  END is_bucket_concern;
BEGIN
  arp_standard.debug('arp_process_det_pkg.upd_inv_ps+' );
  arp_standard.debug('  p_line_applied                :'||p_line_applied);
  arp_standard.debug('  p_tax_applied                 :'||p_tax_applied);
  arp_standard.debug('  p_freight_applied             :'||p_freight_applied);
  arp_standard.debug('  p_charges_applied             :'||p_charges_applied);
  --
  arp_standard.debug('  p_line_ediscounted            :'||p_line_ediscounted);
  arp_standard.debug('  p_tax_ediscounted             :'||p_tax_ediscounted);
  arp_standard.debug('  p_freight_ediscounted         :'||p_freight_ediscounted);
  arp_standard.debug('  p_charges_ediscounted         :'||p_charges_ediscounted);
  --
  arp_standard.debug('  p_line_uediscounted           :'||p_line_uediscounted);
  arp_standard.debug('  p_tax_uediscounted            :'||p_tax_uediscounted);
  arp_standard.debug('  p_freight_uediscounted        :'||p_freight_uediscounted);
  arp_standard.debug('  p_charges_uediscounted        :'||p_charges_uediscounted);
  --
  arp_standard.debug('  payment_schedule_id           : '||g_payschedule_trx.payment_schedule_id );
  l_ps_rec           := g_payschedule_trx;
  l_applied_concern  := is_bucket_concern(p_line_applied     => p_line_applied,
                                          p_tax_applied      => p_tax_applied,
                                          p_freight_applied  => p_freight_applied,
                                          p_charges_applied  => p_charges_applied,
                                          x_amount_applied   => l_amount_applied,
					  p_bc_ps_rec        => p_ps_rec );

  IF l_applied_concern IN ('PBLINENEG', 'PBTAXNEG','PBFRTNEG','PBCHRGNEG') THEN
     RAISE neg_app_amt;
  END IF;
  l_earned_concern   := is_bucket_concern(p_line_applied     => p_line_ediscounted,
                                          p_tax_applied      => p_tax_ediscounted,
                                          p_freight_applied  => p_freight_ediscounted,
                                          p_charges_applied   => p_charges_ediscounted,
                                          x_amount_applied   => l_discount_taken_earned,
					  p_bc_ps_rec        => p_ps_rec  );
  IF l_earned_concern IN ('PBLINENEG', 'PBTAXNEG','PBFRTNEG','PBCHRGNEG') THEN
     RAISE neg_earned_amt;
  END IF;
  l_uearned_concern  := is_bucket_concern(p_line_applied     => p_line_uediscounted,
                                          p_tax_applied      => p_tax_uediscounted,
                                          p_freight_applied  => p_freight_uediscounted,
                                          p_charges_applied  => p_charges_uediscounted,
                                          x_amount_applied   => l_discount_taken_unearned,
					  p_bc_ps_rec        => p_ps_rec );
  IF l_earned_concern IN ('PBLINENEG', 'PBTAXNEG','PBFRTNEG','PBCHRGNEG') THEN
     RAISE neg_unearned_amt;
  END IF;
  l_line_discounted    := NVL(p_line_uediscounted,0) + NVL(p_line_ediscounted,0);
  l_tax_discounted     := NVL(p_tax_uediscounted,0) + NVL(p_tax_ediscounted,0);
  l_freight_discounted := NVL(p_freight_uediscounted,0) + NVL(p_freight_ediscounted,0);
  l_charges_discounted := NVL(p_charges_uediscounted,0) + NVL(p_charges_ediscounted,0);
  l_discount_taken_total :=   l_line_discounted + l_tax_discounted
                            + l_freight_discounted + l_charges_discounted;

  IF l_earned_concern  = 'Y' THEN
    l_nocopy_amt_due_remain       := l_ps_rec.amount_due_remaining;
    l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;
    arp_util.calc_acctd_amount
             (p_currency          => NULL,
              p_precision         => NULL,
              p_mau               => NULL,
              p_rate              => l_ps_rec.exchange_rate,
              p_type              => '-',             /** ADR must be reduced by amount_applied */
              p_master_from       => l_nocopy_amt_due_remain,             /* Current ADR */
              p_acctd_master_from => l_nocopy_acctd_amt_due_remain,       /* Current Acctd. ADR */
              p_detail            => l_discount_taken_earned,             /* Earned discount */
              p_master_to         => l_ps_rec.amount_due_remaining,       /* New ADR */
              p_acctd_master_to   => l_ps_rec.acctd_amount_due_remaining, /* New Acctd. ADR */
              p_acctd_detail      => l_acctd_earned_discount_taken );     /* Acct. amount_applied */
  END IF;
  IF l_uearned_concern  = 'Y' THEN
    l_nocopy_amt_due_remain       := l_ps_rec.amount_due_remaining;
    l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;
    arp_util.calc_acctd_amount
            (p_currency          => NULL,
             p_precision         => NULL,
             p_mau               => NULL,
             p_rate              => l_ps_rec.exchange_rate,
             p_type              => '-',              /** ADR must be reduced by amount_applied */
             p_master_from       => l_nocopy_amt_due_remain,             /* Current ADR */
             p_acctd_master_from => l_nocopy_acctd_amt_due_remain,       /* Current Acctd. ADR */
             p_detail            => l_discount_taken_unearned,           /* Unearned discount */
             p_master_to         => l_ps_rec.amount_due_remaining,       /* New ADR */
             p_acctd_master_to   => l_ps_rec.acctd_amount_due_remaining, /* New Acctd. ADR */
             p_acctd_detail      => l_acctd_unearned_disc_taken );       /* Acct. amount_applied */
  END IF;
  IF l_applied_concern  = 'Y' THEN
    l_nocopy_amt_due_remain       := l_ps_rec.amount_due_remaining;
    l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;
    arp_util.calc_acctd_amount
             (p_currency          => NULL,
              p_precision         => NULL,
              p_mau               => NULL,
              p_rate              => l_ps_rec.exchange_rate,
              p_type              => '-',            /** ADR must be reduced by amount_applied */
              p_master_from       => l_nocopy_amt_due_remain,             /* Current ADR */
              p_acctd_master_from => l_nocopy_acctd_amt_due_remain,       /* Current Acctd. ADR */
              p_detail            => l_amount_applied,                    /* Receipt Amount */
              p_master_to         => l_ps_rec.amount_due_remaining,       /* New ADR */
              p_acctd_master_to   => l_ps_rec.acctd_amount_due_remaining, /* New Acctd. ADR */
              p_acctd_detail      => l_acctd_amount_applied );            /* Acct. amount_applied */
  END IF;
  l_ps_rec.amount_applied          :=  NVL(l_ps_rec.amount_applied,0)
                                      + l_amount_applied;
  l_ps_rec.discount_taken_earned   :=  NVL(l_ps_rec.discount_taken_earned,0)
                                      + l_discount_taken_earned;
  l_ps_rec.discount_taken_unearned :=  NVL(l_ps_rec.discount_taken_unearned,0)
                                      + l_discount_taken_unearned;
  l_ps_rec.discount_remaining      :=   NVL(l_ps_rec.discount_remaining,0)
                                      - l_discount_taken_total;
  l_ps_rec.amount_line_items_remaining :=
                             NVL(l_ps_rec.amount_line_items_remaining,0) -
                             ( NVL( p_line_applied, 0 ) +
                               NVL( l_line_discounted, 0 ) );
  l_ps_rec.receivables_charges_remaining :=
                             NVL (l_ps_rec.receivables_charges_remaining, 0 ) -
                             ( NVL( p_charges_applied, 0 ) +
                               NVL( l_charges_discounted , 0 ) );
  l_ps_rec.tax_remaining := NVL( l_ps_rec.tax_remaining, 0 ) -
                              ( NVL( p_tax_applied, 0 ) +
                                NVL( l_tax_discounted, 0 ) );
  l_ps_rec.freight_remaining := NVL( l_ps_rec.freight_remaining, 0 ) -
                              ( NVL( p_freight_applied, 0 ) +
                                NVL( l_freight_discounted, 0 ) );
  g_payschedule_trx :=   l_ps_rec;
--  dump_payschedule(g_payschedule_trx);
  --
  g_gt_id           :=   g_gt_id + 1;
  l_gt_id           :=   userenv('SESSIONID')||'_'||g_gt_id;
  --
  l_apps_rec.GT_ID                      := l_gt_id;
  l_apps_rec.app_level                  := p_app_level;
  l_apps_rec.source_data_key1           := p_source_data_key1;
  l_apps_rec.source_data_key2           := p_source_data_key2;
  l_apps_rec.source_data_key3           := p_source_data_key3;
  l_apps_rec.source_data_key4           := p_source_data_key4;
  l_apps_rec.source_data_key5           := p_source_data_key5;
  l_apps_rec.ctl_id                     := p_ctl_id;
  --
  l_apps_rec.RECEIVABLE_APPLICATION_ID  := g_app_ra_id;
  l_apps_rec.AMOUNT_APPLIED             := l_amount_applied;
  l_apps_rec.CODE_COMBINATION_ID        := g_inv_rec_ccid;
  l_apps_rec.SET_OF_BOOKS_ID            := g_ae_sys_rec.set_of_books_id;
  l_apps_rec.APPLICATION_TYPE           := 'CASH';
  l_apps_rec.PAYMENT_SCHEDULE_ID        := p_ps_rec.payment_schedule_id;
  l_apps_rec.APPLIED_CUSTOMER_TRX_ID    := p_ps_rec.customer_trx_id;
  l_apps_rec.LINE_APPLIED               := p_line_applied;
  l_apps_rec.TAX_APPLIED                := p_tax_applied;
  l_apps_rec.FREIGHT_APPLIED            := p_freight_applied;
  l_apps_rec.RECEIVABLES_CHARGES_APPLIED:= p_charges_applied;
  l_apps_rec.EARNED_DISCOUNT_TAKEN      := l_discount_taken_earned;
  l_apps_rec.UNEARNED_DISCOUNT_TAKEN    := l_discount_taken_unearned;
  --  l_apps_rec.ACCTD_AMOUNT_APPLIED_FROM  := p_unapp_rec_apps.ACCTD_AMOUNT_APPLIED_FROM;
  l_apps_rec.ACCTD_AMOUNT_APPLIED_TO    := l_acctd_amount_applied;
  l_apps_rec.ACCTD_EARNED_DISCOUNT_TAKEN:= l_acctd_earned_discount_taken;
  l_apps_rec.EARNED_DISCOUNT_CCID       := g_ed_ccid;
  l_apps_rec.UNEARNED_DISCOUNT_CCID     := g_uned_ccid;
  l_apps_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN := l_acctd_unearned_disc_taken;
--  l_apps_rec.AMOUNT_APPLIED_FROM        := p_unapp_rec_apps.AMOUNT_APPLIED_FROM;
  l_apps_rec.LINE_EDISCOUNTED           := p_line_ediscounted;
  l_apps_rec.TAX_EDISCOUNTED            := p_tax_ediscounted;
  l_apps_rec.FREIGHT_EDISCOUNTED        := p_freight_ediscounted;
  l_apps_rec.CHARGES_EDISCOUNTED        := p_charges_ediscounted;
  l_apps_rec.LINE_UEDISCOUNTED          := p_line_uediscounted;
  l_apps_rec.TAX_UEDISCOUNTED           := p_tax_uediscounted;
  l_apps_rec.FREIGHT_UEDISCOUNTED       := p_freight_uediscounted;
  l_apps_rec.CHARGES_UEDISCOUNTED       := p_charges_uediscounted;
  l_apps_rec.STATUS                     := 'APP';
  insert_rapps_p(p_app_rec       => l_apps_rec,
                 x_return_status => x_return_status);
  x_app_rec := l_apps_rec;
  arp_standard.debug( 'arp_process_det_pkg.upd_inv_ps-' );
EXCEPTION
  WHEN neg_app_amt  THEN
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     IF     l_earned_concern = 'PBLINENEG' THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-line applied amt is negative');
     ELSIF  l_earned_concern = 'PBTAXNEG'  THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-tax applied amt is negative');
     ELSIF  l_earned_concern = 'PBFRTNEG'  THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-freight applied amt is negative');
     ELSIF  l_earned_concern = 'PBCHRGNEG' THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-charge applied amt is negative');
     END IF;
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN neg_earned_amt  THEN
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     IF     l_earned_concern = 'PBLINENEG' THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-line earned amt is negative');
     ELSIF  l_earned_concern = 'PBTAXNEG'  THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-tax earned amt is negative');
     ELSIF  l_earned_concern = 'PBFRTNEG'  THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-freight earned amt is negative');
     ELSIF  l_earned_concern = 'PBCHRGNEG' THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-charge earned amt is negative');
     END IF;
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN neg_unearned_amt  THEN
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     IF     l_earned_concern = 'PBLINENEG' THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-line unearned amt is negative');
     ELSIF  l_earned_concern = 'PBTAXNEG'  THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-tax unearned amt is negative');
     ELSIF  l_earned_concern = 'PBFRTNEG'  THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-freight unearned amt is negative');
     ELSIF  l_earned_concern = 'PBCHRGNEG' THEN
       FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-charge unearned amt is negative');
     END IF;
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.upd_inv_ps-'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     arp_util.debug('EXCEPTION OTHERS arp_process_det_pkg.upd_inv_ps:'||SQLERRM );
END upd_inv_ps;



PROCEDURE disp_app_rec
(p_app_rec       IN ar_receivable_apps_gt%ROWTYPE)
IS
BEGIN
  arp_standard.debug('p_app_rec.GT_ID                          :'||p_app_rec.GT_ID);
  arp_standard.debug('p_app_rec.app_level                      :'||p_app_rec.app_level);
  arp_standard.debug('p_app_rec.group_id                       :'||p_app_rec.group_id);
  arp_standard.debug('p_app_rec.ctl_id                         :'||p_app_rec.ctl_id);
  arp_standard.debug('p_app_rec.RECEIVABLE_APPLICATION_ID      :'||p_app_rec.RECEIVABLE_APPLICATION_ID);
  arp_standard.debug('p_app_rec.AMOUNT_APPLIED                 :'||p_app_rec.AMOUNT_APPLIED);
  arp_standard.debug('p_app_rec.CODE_COMBINATION_ID            :'||p_app_rec.CODE_COMBINATION_ID);
  arp_standard.debug('p_app_rec.SET_OF_BOOKS_ID                :'||p_app_rec.SET_OF_BOOKS_ID);
  arp_standard.debug('p_app_rec.APPLICATION_TYPE               :'||p_app_rec.APPLICATION_TYPE);
  arp_standard.debug('p_app_rec.PAYMENT_SCHEDULE_ID            :'||p_app_rec.PAYMENT_SCHEDULE_ID);
  arp_standard.debug('p_app_rec.CASH_RECEIPT_ID                :'||p_app_rec.CASH_RECEIPT_ID);
  arp_standard.debug('p_app_rec.APPLIED_CUSTOMER_TRX_ID        :'||p_app_rec.APPLIED_CUSTOMER_TRX_ID);
  arp_standard.debug('p_app_rec.APPLIED_CUSTOMER_TRX_LINE_ID   :'||p_app_rec.APPLIED_CUSTOMER_TRX_LINE_ID);
  arp_standard.debug('p_app_rec.APPLIED_PAYMENT_SCHEDULE_ID    :'||p_app_rec.APPLIED_PAYMENT_SCHEDULE_ID);
  arp_standard.debug('p_app_rec.CUSTOMER_TRX_ID                :'||p_app_rec.CUSTOMER_TRX_ID);
  arp_standard.debug('p_app_rec.LINE_APPLIED                   :'||p_app_rec.LINE_APPLIED);
  arp_standard.debug('p_app_rec.TAX_APPLIED                    :'||p_app_rec.TAX_APPLIED);
  arp_standard.debug('p_app_rec.FREIGHT_APPLIED                :'||p_app_rec.freight_APPLIED);
  arp_standard.debug('p_app_rec.RECEIVABLES_CHARGES_APPLIED    :'||p_app_rec.RECEIVABLES_CHARGES_APPLIED);
  arp_standard.debug('p_app_rec.EARNED_DISCOUNT_TAKEN          :'||p_app_rec.EARNED_DISCOUNT_TAKEN);
  arp_standard.debug('p_app_rec.UNEARNED_DISCOUNT_TAKEN        :'||p_app_rec.UNEARNED_DISCOUNT_TAKEN);
  arp_standard.debug('p_app_rec.APPLICATION_RULE               :'||p_app_rec.APPLICATION_RULE);
  arp_standard.debug('p_app_rec.ACCTD_AMOUNT_APPLIED_FROM      :'||p_app_rec.ACCTD_AMOUNT_APPLIED_FROM);
  arp_standard.debug('p_app_rec.ACCTD_AMOUNT_APPLIED_TO        :'||p_app_rec.ACCTD_AMOUNT_APPLIED_TO);
  arp_standard.debug('p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN    :'||p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN);
  arp_standard.debug('p_app_rec.EARNED_DISCOUNT_CCID           :'||p_app_rec.EARNED_DISCOUNT_CCID);
  arp_standard.debug('p_app_rec.UNEARNED_DISCOUNT_CCID         :'||p_app_rec.UNEARNED_DISCOUNT_CCID);
  arp_standard.debug('p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN  :'||p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN);
  arp_standard.debug('p_app_rec.ORG_ID                         :'||p_app_rec.ORG_ID);
  arp_standard.debug('p_app_rec.AMOUNT_APPLIED_FROM            :'||p_app_rec.AMOUNT_APPLIED_FROM );
  arp_standard.debug('p_app_rec.RULE_SET_ID                    :'||p_app_rec.RULE_SET_ID);
  arp_standard.debug('p_app_rec.LINE_EDISCOUNTED               :'||p_app_rec.LINE_EDISCOUNTED);
  arp_standard.debug('p_app_rec.TAX_EDISCOUNTED                :'||p_app_rec.TAX_EDISCOUNTED);
  arp_standard.debug('p_app_rec.FREIGHT_EDISCOUNTED            :'||p_app_rec.FREIGHT_EDISCOUNTED);
  arp_standard.debug('p_app_rec.CHARGES_EDISCOUNTED            :'||p_app_rec.CHARGES_EDISCOUNTED);
  arp_standard.debug('p_app_rec.LINE_UEDISCOUNTED              :'||p_app_rec.LINE_UEDISCOUNTED);
  arp_standard.debug('p_app_rec.TAX_UEDISCOUNTED               :'||p_app_rec.TAX_UEDISCOUNTED);
  arp_standard.debug('p_app_rec.FREIGHT_UEDISCOUNTED           :'||p_app_rec.FREIGHT_UEDISCOUNTED);
  arp_standard.debug('p_app_rec.CHARGES_UEDISCOUNTED           :'||p_app_rec.CHARGES_UEDISCOUNTED);
END disp_app_rec;


/*-----------------------------------------------------------------------------+
 | Procedure insert_rapps_p                                                    |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :  insert p_rec_apps in ar_receivable_apps_gt                     |
 +-----------------------------------------------------------------------------*/
PROCEDURE insert_rapps_p
(p_app_rec       IN ar_receivable_apps_gt%ROWTYPE,
 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
arp_standard.debug('insert_rapps_p +');
disp_app_rec(p_app_rec);
INSERT INTO ar_receivable_apps_gt
(GT_ID
,app_level
,source_data_key1
,source_data_key2
,source_data_key3
,source_data_key4
,source_data_key5
,ctl_id
,RECEIVABLE_APPLICATION_ID
,AMOUNT_APPLIED
,CODE_COMBINATION_ID
,SET_OF_BOOKS_ID
,APPLICATION_TYPE
,PAYMENT_SCHEDULE_ID
,CASH_RECEIPT_ID
,APPLIED_CUSTOMER_TRX_ID
,APPLIED_CUSTOMER_TRX_LINE_ID
,APPLIED_PAYMENT_SCHEDULE_ID
,CUSTOMER_TRX_ID
,LINE_APPLIED
,TAX_APPLIED
,FREIGHT_APPLIED
,RECEIVABLES_CHARGES_APPLIED
,EARNED_DISCOUNT_TAKEN
,UNEARNED_DISCOUNT_TAKEN
,APPLICATION_RULE
,ACCTD_AMOUNT_APPLIED_FROM
,ACCTD_AMOUNT_APPLIED_TO
,ACCTD_EARNED_DISCOUNT_TAKEN
,EARNED_DISCOUNT_CCID
,UNEARNED_DISCOUNT_CCID
,ACCTD_UNEARNED_DISCOUNT_TAKEN
,ORG_ID
,AMOUNT_APPLIED_FROM
,RULE_SET_ID
,LINE_EDISCOUNTED
,TAX_EDISCOUNTED
,FREIGHT_EDISCOUNTED
,CHARGES_EDISCOUNTED
,LINE_UEDISCOUNTED
,TAX_UEDISCOUNTED
,FREIGHT_UEDISCOUNTED
,CHARGES_UEDISCOUNTED)  VALUES
(p_app_rec.GT_ID
,p_app_rec.app_level
,p_app_rec.source_data_key1
,p_app_rec.source_data_key2
,p_app_rec.source_data_key3
,p_app_rec.source_data_key4
,p_app_rec.source_data_key5
,p_app_rec.ctl_id
,p_app_rec.RECEIVABLE_APPLICATION_ID
,p_app_rec.AMOUNT_APPLIED
,p_app_rec.CODE_COMBINATION_ID
,p_app_rec.SET_OF_BOOKS_ID
,p_app_rec.APPLICATION_TYPE
,p_app_rec.PAYMENT_SCHEDULE_ID
,p_app_rec.CASH_RECEIPT_ID
,p_app_rec.APPLIED_CUSTOMER_TRX_ID
,p_app_rec.APPLIED_CUSTOMER_TRX_LINE_ID
,p_app_rec.APPLIED_PAYMENT_SCHEDULE_ID
,p_app_rec.CUSTOMER_TRX_ID
,p_app_rec.LINE_APPLIED
,p_app_rec.TAX_APPLIED
,p_app_rec.FREIGHT_APPLIED
,p_app_rec.RECEIVABLES_CHARGES_APPLIED
,p_app_rec.EARNED_DISCOUNT_TAKEN
,p_app_rec.UNEARNED_DISCOUNT_TAKEN
,p_app_rec.APPLICATION_RULE
,p_app_rec.ACCTD_AMOUNT_APPLIED_FROM
,p_app_rec.ACCTD_AMOUNT_APPLIED_TO
,p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN
,p_app_rec.EARNED_DISCOUNT_CCID
,p_app_rec.UNEARNED_DISCOUNT_CCID
,p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN
,p_app_rec.ORG_ID
,p_app_rec.AMOUNT_APPLIED_FROM
,p_app_rec.RULE_SET_ID
,p_app_rec.LINE_EDISCOUNTED
,p_app_rec.TAX_EDISCOUNTED
,p_app_rec.FREIGHT_EDISCOUNTED
,p_app_rec.CHARGES_EDISCOUNTED
,p_app_rec.LINE_UEDISCOUNTED
,p_app_rec.TAX_UEDISCOUNTED
,p_app_rec.FREIGHT_UEDISCOUNTED
,p_app_rec.CHARGES_UEDISCOUNTED);
arp_standard.debug('insert_rapps_p -');
EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION insert_rapps_p OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS insert_rapps_p:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END insert_rapps_p;


/*-----------------------------------------------------------------------------+
 | Procedure res_ctl_rem_amt_for_app                                           |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :  restore the amounts in the ra_customer_trx_lines_gt            |
 +-----------------------------------------------------------------------------*/
PROCEDURE res_ctl_rem_amt_for_app
(p_app_rec        IN            ar_receivable_apps_gt%ROWTYPE,
 x_return_status  IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_app(p_app_rec IN ar_receivable_apps_gt%ROWTYPE)
  IS
  SELECT SUM(DECODE(b.ref_account_class,
                    'REV',
                     DECODE(b.REF_DET_ID,NULL,b.AMOUNT,0),
                     0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),             -- FOR REV LINE AMOUNT_DUE_REMAINING
         SUM(DECODE(b.ref_account_class,
                    'REV',
                     DECODE(b.REF_DET_ID,NULL,b.ACCTD_AMOUNT,0),
                     0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),             -- FOR REV LINE ACCTD_AMOUNT_DUE_REMAINING
         SUM(DECODE(b.ref_account_class,
                    'REV',
                     DECODE(b.REF_DET_ID,NULL,0,
                            DECODE(b.SOURCE_TYPE,'FREIGHT',b.AMOUNT,0)),
                     0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),             -- FOR REV LINE FRT_ADJ_REMAINING
         SUM(DECODE(b.ref_account_class,
                    'REV',
                     DECODE(b.REF_DET_ID,NULL,0,
                            DECODE(b.SOURCE_TYPE,'FREIGHT',b.ACCTD_AMOUNT,0)),
                     0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),             -- FOR REV LINE FRT_ADJ_ACCTD_REMAINING
         SUM(DECODE(b.ref_account_class,
                    'REV',
                     DECODE(b.REF_DET_ID,NULL,0,
                            DECODE(b.SOURCE_TYPE,'CHARGES',b.AMOUNT,0)),
                     0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),             -- FOR REV LINE CHRG_ADJ_REMAINING
         SUM(DECODE(b.ref_account_class,
                    'REV',
                     DECODE(b.REF_DET_ID,NULL,0,
                            DECODE(b.SOURCE_TYPE,'CHARGES',b.ACCTD_AMOUNT,0)),
                     0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),             -- FOR REV LINE CHRG_ADJ_ACCTD_REMAINING
         SUM(DECODE(b.ref_account_class,
                    'TAX',
                    b.AMOUNT,
                    0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),              -- FOR TAX
         SUM(DECODE(b.ref_account_class,
                    'TAX',
                    b.ACCTD_AMOUNT,
                    0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),              -- FOR ACCTD TAX
         SUM(DECODE(b.ref_account_class,
                    'FREIGHT',
                    b.AMOUNT,
                    0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),              -- FOR FREIGHT
         SUM(DECODE(b.ref_account_class,
                    'FREIGHT',
                    b.ACCTD_AMOUNT,
                    0))
             OVER (PARTITION BY b.ref_customer_trx_line_id),              -- FOR ACCTD FREIGHT
         b.REF_CUSTOMER_TRX_LINE_ID,
         c.line_type
    FROM AR_LINE_APP_DETAIL_GT     b,
         ra_customer_trx_lines_gt          c
   WHERE b.gt_id                    = p_app_rec.gt_id
     AND b.app_level                = p_app_rec.app_level
     AND b.REF_CUSTOMER_TRX_LINE_ID = c.customer_trx_line_id;

  l_rev_amt_rem_tab                 DBMS_SQL.NUMBER_TABLE;
  l_rev_acctd_amt_rem_tab                 DBMS_SQL.NUMBER_TABLE;
  l_frt_adj_amt_rem_tab             DBMS_SQL.NUMBER_TABLE;
  l_frt_adj_acctd_amt_rem_tab             DBMS_SQL.NUMBER_TABLE;
  l_chrg_adj_amt_rem_tab            DBMS_SQL.NUMBER_TABLE;
  l_chrg_adj_acctd_amt_rem_tab            DBMS_SQL.NUMBER_TABLE;
  l_tax_amt_rem_tab                 DBMS_SQL.NUMBER_TABLE;
  l_tax_acctd_amt_rem_tab                 DBMS_SQL.NUMBER_TABLE;
  l_frt_amt_rem_tab                 DBMS_SQL.NUMBER_TABLE;
  l_frt_acctd_amt_rem_tab                 DBMS_SQL.NUMBER_TABLE;
  l_ctl_id_tab                            DBMS_SQL.NUMBER_TABLE;
  l_line_type_tab                         DBMS_SQL.VARCHAR2_TABLE;
  l_last_fetch                            BOOLEAN := FALSE;
BEGIN
arp_standard.debug('res_ctl_rem_amt_for_app +');
disp_app_rec(p_app_rec);
  OPEN c_app(p_app_rec);
  LOOP
      FETCH c_app BULK COLLECT INTO l_rev_amt_rem_tab,
                              l_rev_acctd_amt_rem_tab,
                              l_frt_adj_amt_rem_tab,
                              l_frt_adj_acctd_amt_rem_tab,
                              l_chrg_adj_amt_rem_tab,
                              l_chrg_adj_acctd_amt_rem_tab,
                              l_tax_amt_rem_tab,
                              l_tax_acctd_amt_rem_tab,
                              l_frt_amt_rem_tab,
                              l_frt_acctd_amt_rem_tab,
                              l_ctl_id_tab,
                              l_line_type_tab
                        LIMIT g_bulk_fetch_rows;

       IF c_app%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

       IF (l_ctl_id_tab.COUNT = 0) AND (l_last_fetch) THEN
         arp_standard.debug('COUNT = 0 and LAST FETCH ');
         EXIT;
       END IF;

       FORALL i IN l_ctl_id_tab.FIRST .. l_ctl_id_tab.LAST
       UPDATE ra_customer_trx_lines_gt
          SET AMOUNT_DUE_REMAINING  =
                        DECODE(l_line_type_tab(i),
                               'LINE',   AMOUNT_DUE_REMAINING + l_rev_amt_rem_tab(i),
                               'FREIGHT',AMOUNT_DUE_REMAINING + l_frt_amt_rem_tab(i),
                               'TAX',    AMOUNT_DUE_REMAINING + l_tax_amt_rem_tab(i),
                               AMOUNT_DUE_REMAINING),
              ACCTD_AMOUNT_DUE_REMAINING  =
                        DECODE(l_line_type_tab(i),
                               'LINE',   ACCTD_AMOUNT_DUE_REMAINING + l_rev_acctd_amt_rem_tab(i),
                               'FREIGHT',ACCTD_AMOUNT_DUE_REMAINING + l_frt_acctd_amt_rem_tab(i),
                               'TAX',    ACCTD_AMOUNT_DUE_REMAINING + l_tax_acctd_amt_rem_tab(i),
                               ACCTD_AMOUNT_DUE_REMAINING),
              FRT_ADJ_REMAINING     =
                        FRT_ADJ_REMAINING + l_frt_adj_amt_rem_tab(i),
              FRT_ADJ_ACCTD_REMAINING     =
                        FRT_ADJ_ACCTD_REMAINING + l_frt_adj_acctd_amt_rem_tab(i),
              CHRG_AMOUNT_REMAINING =
                        CHRG_AMOUNT_REMAINING + l_chrg_adj_amt_rem_tab(i),
              CHRG_ACCTD_AMOUNT_REMAINING =
                        CHRG_ACCTD_AMOUNT_REMAINING + l_chrg_adj_acctd_amt_rem_tab(i)
        WHERE customer_trx_line_id = l_ctl_id_tab(i);
   END LOOP;
   CLOSE c_app;
  arp_standard.debug('res_ctl_rem_amt_for_app -');
EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION res_ctl_rem_amt_for_app OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS res_ctl_rem_amt_for_app:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END res_ctl_rem_amt_for_app;


/*-----------------------------------------------------------------------------+
 | Procedure res_inv_ps                                                        |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :  restore the amounts in the g_payschedule_trx based on the input|
 +-----------------------------------------------------------------------------*/
PROCEDURE res_inv_ps
(p_app_rec        IN ar_receivable_apps_gt%ROWTYPE,
 x_return_status  IN OUT NOCOPY VARCHAR2)
IS
 l_ps_rec      ar_payment_schedules%ROWTYPE;
 l_line_discounted      NUMBER;
 l_tax_discounted       NUMBER;
 l_charges_discounted   NUMBER;
 l_discount_taken_total NUMBER;
 l_freight_discounted   NUMBER;
BEGIN
arp_standard.debug('res_inv_ps +');
disp_app_rec(p_app_rec);
  l_ps_rec           := g_payschedule_trx;

  l_ps_rec.amount_applied          :=  NVL(l_ps_rec.amount_applied,0)
                                      - p_app_rec.AMOUNT_APPLIED;
  l_ps_rec.discount_taken_earned   :=  NVL(l_ps_rec.discount_taken_earned,0)
                                      - p_app_rec.EARNED_DISCOUNT_TAKEN;
  l_ps_rec.discount_taken_unearned :=  NVL(l_ps_rec.discount_taken_unearned,0)
                                      - p_app_rec.UNEARNED_DISCOUNT_TAKEN;

  l_line_discounted    := NVL(p_app_rec.LINE_UEDISCOUNTED,0) + NVL(p_app_rec.LINE_EDISCOUNTED,0);
  l_tax_discounted     := NVL(p_app_rec.TAX_UEDISCOUNTED,0) + NVL(p_app_rec.TAX_EDISCOUNTED,0);
  l_freight_discounted := NVL(p_app_rec.FREIGHT_UEDISCOUNTED,0) + NVL(p_app_rec.FREIGHT_EDISCOUNTED,0);
  l_charges_discounted := NVL(p_app_rec.CHARGES_UEDISCOUNTED,0) + NVL(p_app_rec.CHARGES_EDISCOUNTED,0);

  l_discount_taken_total :=   l_line_discounted + l_tax_discounted
                            + l_freight_discounted + l_charges_discounted;

  l_ps_rec.discount_remaining      :=   NVL(l_ps_rec.discount_remaining,0)
                                      + l_discount_taken_total;

  l_ps_rec.amount_line_items_remaining :=
                             NVL(l_ps_rec.amount_line_items_remaining,0) +
                             ( NVL( p_app_rec.LINE_APPLIED, 0 ) +
                               NVL( l_line_discounted, 0 ) );
  l_ps_rec.receivables_charges_remaining :=
                             NVL (l_ps_rec.receivables_charges_remaining, 0 ) +
                             ( NVL( p_app_rec.RECEIVABLES_CHARGES_APPLIED, 0 ) +
                               NVL( l_charges_discounted , 0 ) );
  l_ps_rec.tax_remaining := NVL( l_ps_rec.tax_remaining, 0 ) +
                              ( NVL( p_app_rec.TAX_APPLIED, 0 ) +
                                NVL( l_tax_discounted, 0 ) );
  l_ps_rec.freight_remaining := NVL( l_ps_rec.freight_remaining, 0 ) +
                              ( NVL( p_app_rec.FREIGHT_APPLIED, 0 ) +
                                NVL( l_freight_discounted, 0 ) );
  g_payschedule_trx :=   l_ps_rec;
arp_standard.debug('res_inv_ps -');
EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION res_inv_ps OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS res_inv_ps:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END res_inv_ps;


/*-----------------------------------------------------------------------------+
 | Procedure delete_application                                                |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |     1) Call res_inv_ps to restore payment schedule                          |
 |     2) Call res_ctl_rem_amt_for_app to restore the ra_customer_trx_lines_gt |
 |         amounts                                                             |
 |     3) Delete the record from ar_receivable_apps_gt                         |
 +-----------------------------------------------------------------------------*/
PROCEDURE delete_application
(p_app_rec        IN ar_receivable_apps_gt%ROWTYPE,
 x_return_status  IN OUT NOCOPY VARCHAR2)
IS
BEGIN
arp_standard.debug('delete_application +');
  -- 1 restore ps inv
  res_inv_ps(p_app_rec       => p_app_rec,
             x_return_status => x_return_status);

  -- 2 restore inv rem amt
  res_ctl_rem_amt_for_app(p_app_rec        => p_app_rec,
                          x_return_status  => x_return_status);

  -- 3 delete the application from ar_receivable_apps_gt
  DELETE FROM ar_receivable_apps_gt
  WHERE gt_id     = p_app_rec.gt_id
  AND   app_level = p_app_rec.app_level;

  -- 4 delete the distributions created by the application
  DELETE FROM AR_LINE_APP_DETAIL_GT
  WHERE gt_id     = p_app_rec.gt_id
  AND   app_level = p_app_rec.app_level;

arp_standard.debug('delete_application -');
EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION delete_application OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS delete_application:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END delete_application;


PROCEDURE copy_app_rec
(p_app_rec       IN            ar_receivable_apps_gt%ROWTYPE,
 x_ra_rec        IN OUT NOCOPY ar_receivable_applications%ROWTYPE,
 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
arp_standard.debug('copy_app_rec +');
disp_app_rec(p_app_rec);
 x_ra_rec.RECEIVABLE_APPLICATION_ID      := p_app_rec.RECEIVABLE_APPLICATION_ID;
 x_ra_rec.AMOUNT_APPLIED                 := p_app_rec.AMOUNT_APPLIED;
 x_ra_rec.CODE_COMBINATION_ID            := p_app_rec.CODE_COMBINATION_ID;
 x_ra_rec.SET_OF_BOOKS_ID                := p_app_rec.SET_OF_BOOKS_ID;
 x_ra_rec.APPLICATION_TYPE               := p_app_rec.APPLICATION_TYPE;
 x_ra_rec.PAYMENT_SCHEDULE_ID            := p_app_rec.PAYMENT_SCHEDULE_ID;
 x_ra_rec.CASH_RECEIPT_ID                := p_app_rec.CASH_RECEIPT_ID;
 x_ra_rec.APPLIED_CUSTOMER_TRX_ID        := p_app_rec.APPLIED_CUSTOMER_TRX_ID;
 x_ra_rec.APPLIED_CUSTOMER_TRX_LINE_ID   := p_app_rec.APPLIED_CUSTOMER_TRX_LINE_ID;
 x_ra_rec.APPLIED_PAYMENT_SCHEDULE_ID    := p_app_rec.APPLIED_PAYMENT_SCHEDULE_ID;
 x_ra_rec.CUSTOMER_TRX_ID                := p_app_rec.CUSTOMER_TRX_ID;
 x_ra_rec.LINE_APPLIED                   := p_app_rec.LINE_APPLIED;
 x_ra_rec.TAX_APPLIED                    := p_app_rec.TAX_APPLIED;
 x_ra_rec.FREIGHT_APPLIED                := p_app_rec.FREIGHT_APPLIED;
 x_ra_rec.RECEIVABLES_CHARGES_APPLIED    := p_app_rec.RECEIVABLES_CHARGES_APPLIED;
 x_ra_rec.EARNED_DISCOUNT_TAKEN          := p_app_rec.EARNED_DISCOUNT_TAKEN;
 x_ra_rec.UNEARNED_DISCOUNT_TAKEN        := p_app_rec.UNEARNED_DISCOUNT_TAKEN;
 x_ra_rec.APPLICATION_RULE               := p_app_rec.APPLICATION_RULE;
 x_ra_rec.ACCTD_AMOUNT_APPLIED_FROM      := p_app_rec.ACCTD_AMOUNT_APPLIED_FROM;
 x_ra_rec.ACCTD_AMOUNT_APPLIED_TO        := p_app_rec.ACCTD_AMOUNT_APPLIED_TO;
 x_ra_rec.ACCTD_EARNED_DISCOUNT_TAKEN    := p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN;
 x_ra_rec.EARNED_DISCOUNT_CCID           := p_app_rec.EARNED_DISCOUNT_CCID;
 x_ra_rec.UNEARNED_DISCOUNT_CCID         := p_app_rec.UNEARNED_DISCOUNT_CCID;
 x_ra_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN  := p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN;
 x_ra_rec.ORG_ID                         := p_app_rec.ORG_ID;
 x_ra_rec.AMOUNT_APPLIED_FROM            := p_app_rec.AMOUNT_APPLIED_FROM;
 x_ra_rec.RULE_SET_ID                    := p_app_rec.RULE_SET_ID;
 x_ra_rec.LINE_EDISCOUNTED               := p_app_rec.LINE_EDISCOUNTED;
 x_ra_rec.TAX_EDISCOUNTED                := p_app_rec.TAX_EDISCOUNTED;
 x_ra_rec.FREIGHT_EDISCOUNTED            := p_app_rec.FREIGHT_EDISCOUNTED;
 x_ra_rec.CHARGES_EDISCOUNTED            := p_app_rec.CHARGES_EDISCOUNTED;
 x_ra_rec.LINE_UEDISCOUNTED              := p_app_rec.LINE_UEDISCOUNTED;
 x_ra_rec.TAX_UEDISCOUNTED               := p_app_rec.TAX_UEDISCOUNTED;
 x_ra_rec.FREIGHT_UEDISCOUNTED           := p_app_rec.FREIGHT_UEDISCOUNTED;
 x_ra_rec.CHARGES_UEDISCOUNTED           := p_app_rec.CHARGES_UEDISCOUNTED;
 x_ra_rec.STATUS                         := p_app_rec.STATUS;

arp_standard.debug('   x_ra_rec.LINE_APPLIED:'||x_ra_rec.LINE_APPLIED);
arp_standard.debug('   x_ra_rec.TAX_APPLIED:'||x_ra_rec.TAX_APPLIED);

arp_standard.debug('copy_app_rec -');
EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION copy_app_rec OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS copy_app_rec:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END copy_app_rec;


/*-----------------------------------------------------------------------------+
 | Procedure do_apply                                                          |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_app_rec        variable of type ar_receivable_apps_gt                   |
 |   p_customer_trx   invoice record                                           |
 |   p_ae_sys_rec     receivable system parameter                              |
 |   p_gt_id          global ID                                                |
 +-----------------------------------------------------------------------------+
 | Action    :  Call arp_det_dist_pkg to do the application                    |
 +-----------------------------------------------------------------------------*/
PROCEDURE do_apply
(p_app_rec      IN ar_receivable_apps_gt%ROWTYPE,
 p_gt_id        IN VARCHAR2,
 x_return_status IN OUT NOCOPY VARCHAR2)
IS
  l_ra_rec      ar_receivable_applications%ROWTYPE;
BEGIN
arp_standard.debug('do_apply +');
  copy_app_rec(p_app_rec     => p_app_rec,
               x_ra_rec      => l_ra_rec,
               x_return_status    => x_return_status);

dump_sys_param;

  IF p_app_rec.app_level = 'TRANSACTION' THEN

    ARP_DET_DIST_PKG.Trx_level_cash_apply
     (p_customer_trx     => g_customer_trx,
      p_app_rec          => l_ra_rec,
      p_ae_sys_rec       => g_ae_sys_rec,
      p_gt_id            => p_gt_id);

  ELSIF p_app_rec.app_level = 'GROUP' THEN

    ARP_DET_DIST_PKG.Trx_gp_level_cash_apply
     (p_customer_trx     => g_customer_trx,
      --
      p_source_data_key1 => p_app_rec.source_data_key1,
      p_source_data_key2 => p_app_rec.source_data_key2,
      p_source_data_key3 => p_app_rec.source_data_key3,
      p_source_data_key4 => p_app_rec.source_data_key4,
      p_source_data_key5 => p_app_rec.source_data_key5,
      --
      p_app_rec          => l_ra_rec,
      p_ae_sys_rec       => g_ae_sys_rec,
      p_gt_id            => p_gt_id);

  ELSIF p_app_rec.app_level = 'LINE' THEN

arp_standard.debug(' HYU   l_ra_rec.LINE_APPLIED:'||l_ra_rec.LINE_APPLIED);
arp_standard.debug(' HYU   l_ra_rec.TAX_APPLIED:'||l_ra_rec.TAX_APPLIED);

    ARP_DET_DIST_PKG.Trx_line_level_cash_apply
     (p_customer_trx     => g_customer_trx,
      p_customer_trx_line_id => p_app_rec.ctl_id,
      p_log_inv_line     => 'Y',
      p_app_rec          => l_ra_rec,
      p_ae_sys_rec       => g_ae_sys_rec,
      p_gt_id            => p_gt_id);

  END IF;
arp_standard.debug('do_apply -');
EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION do_apply OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS do_apply:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_apply;


/*-----------------------------------------------------------------------------+
 | Procedure    apply                                                          |
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
 |            1) Call upd_inv_ps                                               |
 |            2) Call do_apply                                                 |
 +-----------------------------------------------------------------------------*/
PROCEDURE apply
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
  x_return_status           IN OUT NOCOPY VARCHAR2)
IS
 l_app_rec ar_receivable_apps_gt%ROWTYPE;
BEGIN
arp_standard.debug('apply +');

arp_standard.debug(' Calling upd_inv_ps +');

 upd_inv_ps(
  p_app_level              => p_app_level,
  --
  p_source_data_key1       => p_source_data_key1,
  p_source_data_key2       => p_source_data_key2,
  p_source_data_key3       => p_source_data_key3,
  p_source_data_key4       => p_source_data_key4,
  p_source_data_key5       => p_source_data_key5,
  --
  p_ctl_id                 => p_ctl_id,
  --
  p_line_applied           => p_line_applied,
  p_tax_applied            => p_tax_applied,
  p_freight_applied        => p_freight_applied,
  p_charges_applied        => p_charges_applied,
  --
  p_line_ediscounted       => p_line_ediscounted,
  p_tax_ediscounted        => p_tax_ediscounted,
  p_freight_ediscounted    => p_freight_ediscounted,
  p_charges_ediscounted    => p_charges_ediscounted,
  --
  p_line_uediscounted      => p_line_uediscounted,
  p_tax_uediscounted       => p_tax_uediscounted,
  p_freight_uediscounted   => p_freight_uediscounted,
  p_charges_uediscounted   => p_charges_uediscounted,
  p_ps_rec                 => g_payschedule_trx,
  --
  x_app_rec               => l_app_rec,
  x_return_status         => x_return_status);

arp_standard.debug('   x_return_status :'||  x_return_status);

arp_standard.debug(' Calling upd_inv_ps -');

 do_apply
  (p_app_rec      => l_app_rec,
   p_gt_id        => l_app_rec.gt_id,
   x_return_status=> x_return_status);
arp_standard.debug('apply -');
EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION apply OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS apply:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END apply;

PROCEDURE dump_ccid
IS
BEGIN
  arp_standard.debug('g_unapplied_ccid      :'||g_unapplied_ccid);
  arp_standard.debug('g_ed_ccid             :'||g_ed_ccid);
  arp_standard.debug('g_uned_ccid           :'||g_uned_ccid);
  arp_standard.debug('g_unidentified_ccid   :'||g_unidentified_ccid);
  arp_standard.debug('g_clearing_ccid       :'||g_clearing_ccid);
  arp_standard.debug('g_remittance_ccid     :'||g_remittance_ccid);
  arp_standard.debug('g_cash_ccid           :'||g_cash_ccid);
  arp_standard.debug('g_on_account_ccid     :'||g_on_account_ccid);
  arp_standard.debug('g_factor_ccid         :'||g_factor_ccid);
  arp_standard.debug('g_inv_rec_ccid        :'||g_inv_rec_ccid);
END dump_ccid;

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
 x_msg_count       OUT NOCOPY NUMBER)
IS
  CURSOR c     IS
  SELECT *
    FROM ra_customer_trx
   WHERE customer_trx_id = p_customer_trx_id;
  CURSOR c_cr  IS
  SELECT *
    FROM ar_cash_receipts
   WHERE cash_receipt_id = p_cash_receipt_id;
  CURSOR c_sys IS
    SELECT sob.set_of_books_id,
         sob.chart_of_accounts_id,
         sob.currency_code,
         c.precision,
         c.minimum_accountable_unit,
         sysp.code_combination_id_gain,
         sysp.code_combination_id_loss,
         sysp.code_combination_id_round
  FROM   ar_system_parameters sysp,
         gl_sets_of_books sob,
         fnd_currencies c
  WHERE  sob.set_of_books_id = sysp.set_of_books_id
  AND    sob.currency_code   = c.currency_code;
  CURSOR c_acct  IS
      SELECT rma.unapplied_ccid
         , ed.code_combination_id
         , uned.code_combination_id
         , rma.unidentified_ccid
         , rma.receipt_clearing_ccid
         , rma.remittance_ccid
         , rma.cash_ccid
         , rma.on_account_ccid
         , rma.factor_ccid
         , ctlgd.code_combination_id
    FROM   ar_cash_receipts 		cr
         , ar_cash_receipt_history 	crh
         , ar_receipt_methods 	        rm
         , ce_bank_acct_uses            aba
         , ce_bank_branches_v           bp
         , ce_bank_accounts             cba
         , ar_receipt_method_accounts	rma
         , ar_receivables_trx           ed
         , ar_receivables_trx           uned
         , ra_cust_trx_line_gl_dist     ctlgd
    WHERE  cr.cash_receipt_id		= p_cash_receipt_id
    AND	   cr.cash_receipt_id		= crh.cash_receipt_id
    AND    crh.current_record_flag	= 'Y'
    AND    rm.receipt_method_id		= cr.receipt_method_id
    AND    cr.remit_bank_acct_use_id    = aba.bank_acct_use_id
    AND    aba.bank_account_id          = cba.bank_account_id
    AND    bp.branch_party_id           = cba.bank_branch_id
    AND    rma.remit_bank_acct_use_id   = aba.bank_acct_use_id
    AND    rma.receipt_method_id	    = rm.receipt_method_id
    AND    rma.edisc_receivables_trx_id = ed.receivables_trx_id (+)
    AND    rma.unedisc_receivables_trx_id= uned.receivables_trx_id (+)
    AND    ctlgd.customer_trx_id        = p_customer_trx_id
    AND    ctlgd.account_class          = 'REC';

   CURSOR c1 IS
   SELECT ctl.customer_trx_id
     FROM ra_customer_trx_lines ctl
    WHERE ctl.customer_trx_id = p_customer_trx_id
      AND ctl.autorule_complete_flag||'' = 'N'
    GROUP BY ctl.customer_trx_id;

   CURSOR c_trx_number(p_customer_trx_id IN NUMBER) IS
    SELECT ct.trx_number
      FROM ra_customer_trx ct
     WHERE ct.customer_trx_id = p_customer_trx_id;

  l_dummy           NUMBER;
  l_rev_rec_req     BOOLEAN;
  l_sum_dist        NUMBER;
  l_trx_number      VARCHAR2(20);

  not_valid_trx   EXCEPTION;
  no_sys_param    EXCEPTION;
  not_valid_cr    EXCEPTION;
  rev_rec_error   EXCEPTION;
BEGIN
arp_standard.debug('initialization +');
  SAVEPOINT initialization;
  x_return_status := fnd_api.g_ret_sts_success;
  OPEN c;
  FETCH c INTO g_customer_trx;
  IF c%NOTFOUND THEN
    CLOSE c;
    RAISE not_valid_trx;
  END IF;
  CLOSE c;
  OPEN c_cr;
  FETCH c_cr INTO g_cash_receipt;
  IF c_cr%NOTFOUND THEN
    CLOSE c_cr;
    RAISE not_valid_cr;
  END IF;
  CLOSE c_cr;
  OPEN c_sys;
  FETCH c_sys INTO
         g_ae_sys_rec.set_of_books_id,
         g_ae_sys_rec.coa_id,
         g_ae_sys_rec.base_currency,
         g_ae_sys_rec.base_precision,
         g_ae_sys_rec.base_min_acc_unit,
         g_ae_sys_rec.gain_cc_id,
         g_ae_sys_rec.loss_cc_id,
         g_ae_sys_rec.round_cc_id;
  IF c_sys%NOTFOUND THEN
     CLOSE c_sys;
     RAISE no_sys_param;
  ELSE
     g_ae_sys_rec.SOB_TYPE := 'P';
     dump_sys_param;
  END IF;
  CLOSE c_sys;
  OPEN  c_acct;
  FETCH c_acct INTO g_unapplied_ccid
                   ,g_ed_ccid
                   ,g_uned_ccid
                   ,g_unidentified_ccid
                   ,g_clearing_ccid
                   ,g_remittance_ccid
                   ,g_cash_ccid
                   ,g_on_account_ccid
                   ,g_factor_ccid
                   ,g_inv_rec_ccid;
  CLOSE c_acct;
  dump_ccid;

 arp_standard.debug('   Check whether Rev Recognition is to be Run');
 OPEN c1;
 FETCH c1 INTO l_dummy;
 IF c1%NOTFOUND THEN
   arp_standard.debug('    No need to run rev rec for trx_id :' || p_customer_trx_id);
   l_rev_rec_req := FALSE;
 ELSE
   arp_standard.debug('    Need to run rev rec for trx_id    :' || p_customer_trx_id);
   l_rev_rec_req := TRUE;
 END IF;
 CLOSE c1;

 IF l_rev_rec_req THEN
    arp_standard.debug('  Executing Rev Rec - calling ARP_AUTO_RULE.create_distributions');
    l_sum_dist := ARP_AUTO_RULE.create_distributions
                  ( p_commit => 'N',
                    p_debug  => 'N',
                    p_trx_id => p_customer_trx_id);

    IF l_sum_dist < 0 THEN
       RAISE rev_rec_error;
    END IF;
    arp_standard.debug('   Completed running revenue recognition for Transaction');
 END IF;


  ARP_DET_DIST_PKG.set_original_rem_amt
     (p_customer_trx     => g_customer_trx,
	  p_from_llca        => 'Y');

  ARP_DET_DIST_PKG.copy_trx_lines (p_customer_trx_id => p_customer_trx_id,
                                p_ae_sys_rec       => g_ae_sys_rec);

  get_inv_ps(x_return_status   => x_return_status);

  get_rec_ps(p_cr_id           => g_cash_receipt.cash_receipt_id,
             x_return_status   => x_return_status);

  SELECT ar_receivable_applications_s.nextval
    INTO g_app_ra_id
    FROM dual;

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

arp_standard.debug('initialization -');
EXCEPTION
WHEN no_sys_param THEN
     ROLLBACK TO initialization;
     arp_standard.debug('EXCEPTION initialization no_sys_param');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_NO_ROW_IN_SYSTEM_PARAMETERS' );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
WHEN not_valid_trx       THEN
     ROLLBACK TO initialization;
     arp_standard.debug('EXCEPTION initialization not_valid_trx');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'not_valid_trx initialization p_customer_trx_id:'||
                            p_customer_trx_id );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
WHEN not_valid_cr        THEN
     ROLLBACK TO initialization;
     arp_standard.debug('EXCEPTION initialization not_valid_cr');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'not_valid_cr initialization p_cash_receipt_id:'||
                            p_cash_receipt_id );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO initialization;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);
WHEN rev_rec_error THEN
     ROLLBACK TO initialization;
     OPEN c_trx_number(p_customer_trx_id);
     FETCH c_trx_number INTO l_trx_number;
     CLOSE c_trx_number;
     arp_standard.debug('Error in Rev Rec - ARP_AUTO_RULE.create_distributions for trx_id :'||p_customer_trx_id);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_AUTORULE_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TRX_NUMBER', l_trx_number );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

WHEN OTHERS THEN
     ROLLBACK TO initialization;
     arp_standard.debug('EXCEPTION initialization OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS initialization:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END initialization;


/*-----------------------------------------------------------------------------+
 | FUNCTION cur_app_gt_id                                                      |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |    p_app_level      Application level TRANSACTION/GROUP/LINE                |
 |    p_group_id       Group_id required if level is GROUP                     |
 |    p_ctl_id         customer_trx_line_id required if level is LINE          |
 |  Out variable                                                               |
 |    x_app_rec        return the current ar_receivable_apps_gt record matching|
 |                     the search criteria in ar_receivable_apps_gt            |
 |  Return :                                                                   |
 |    Gt_id of that record matching the search criteria                        |
 |    If no row found the n returns NO_GT_ID                                   |
 +-----------------------------------------------------------------------------+
 | Action    :                                                                 |
 |  Search for the current ar_receivable_apps_gt record that match the criteria|
 +-----------------------------------------------------------------------------*/
FUNCTION cur_app_gt_id
( p_app_level         IN VARCHAR2,
  p_source_data_key1  IN VARCHAR2,
  p_source_data_key2  IN VARCHAR2,
  p_source_data_key3  IN VARCHAR2,
  p_source_data_key4  IN VARCHAR2,
  p_source_data_key5  IN VARCHAR2,
  p_ctl_id            IN NUMBER,
  x_app_rec           OUT NOCOPY ar_receivable_apps_gt%ROWTYPE)
RETURN VARCHAR2
IS
 CURSOR c_trx IS
 SELECT *
   FROM ar_receivable_apps_gt
  WHERE app_level = 'TRANSACTION'
  AND 1=2;

 CURSOR c_grp IS
 SELECT *
   FROM ar_receivable_apps_gt
  WHERE app_level = 'GROUP'
    AND source_data_key1  = p_source_data_key1
    AND source_data_key2  = p_source_data_key2
    AND source_data_key3  = p_source_data_key3
    AND source_data_key4  = p_source_data_key4
    AND source_data_key5  = p_source_data_key5;

 CURSOR c_ctl IS
 SELECT *
   FROM ar_receivable_apps_gt
  WHERE app_level = 'LINE'
    AND ctl_id    = p_ctl_id;
 l_res  VARCHAR2(30);
BEGIN
arp_standard.debug('cur_app_gt_id +');
arp_standard.debug('   p_app_level :'||p_app_level);
arp_standard.debug('   p_source_data_key1  :'||p_source_data_key1);
arp_standard.debug('   p_source_data_key2  :'||p_source_data_key2);
arp_standard.debug('   p_source_data_key3  :'||p_source_data_key3);
arp_standard.debug('   p_source_data_key4  :'||p_source_data_key4);
arp_standard.debug('   p_source_data_key5  :'||p_source_data_key5);
arp_standard.debug('   p_ctl_id    :'||p_ctl_id);
 IF      p_app_level = 'TRANSACTION' THEN
   OPEN c_trx;
   FETCH c_trx INTO x_app_rec;
   IF c_trx%NOTFOUND THEN
     l_res := 'NO_GT_ID';
   ELSE
     l_res := x_app_rec.gt_id;
   END IF;
   CLOSE c_trx;
 ELSIF  p_app_level = 'GROUP' THEN
   OPEN c_grp;
   FETCH c_grp INTO x_app_rec;
   IF c_grp%NOTFOUND THEN
     l_res := 'NO_GT_ID';
   ELSE
     l_res := x_app_rec.gt_id;
   END IF;
   CLOSE c_grp;
 ELSIF  p_app_level = 'LINE' THEN
   OPEN c_ctl;
   FETCH c_ctl INTO x_app_rec;
   IF c_ctl%NOTFOUND THEN
     l_res := 'NO_GT_ID';
   ELSE
     l_res := x_app_rec.gt_id;
   END IF;
   CLOSE c_ctl;
 ELSE
   l_res := 'X';
 END IF;
arp_standard.debug('   l_res :'||l_res);
arp_standard.debug('cur_app_gt_id -');
RETURN l_res;
EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION cur_app_gt_id OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS cur_app_gt_id:'||SQLERRM );
     FND_MSG_PUB.ADD;
     RETURN FND_API.G_RET_STS_UNEXP_ERROR;
END cur_app_gt_id;


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
  p_source_data_key1               IN VARCHAR2,
  p_source_data_key2               IN VARCHAR2,
  p_source_data_key3               IN VARCHAR2,
  p_source_data_key4               IN VARCHAR2,
  p_source_data_key5               IN VARCHAR2,
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
  x_msg_data                       OUT NOCOPY VARCHAR2)
IS
  cur_gt_id     VARCHAR2(30);
  l_app_rec     ar_receivable_apps_gt%ROWTYPE;
  unexpected_error  EXCEPTION;
BEGIN
arp_standard.debug('application_execute +');
  SAVEPOINT first_delete_then_apply;

  x_return_status  := fnd_api.g_ret_sts_success;

  cur_gt_id := cur_app_gt_id( p_app_level ,
                              p_source_data_key1  ,
                              p_source_data_key2  ,
                              p_source_data_key3  ,
                              p_source_data_key4  ,
                              p_source_data_key5  ,
                              p_ctl_id    ,
                              l_app_rec);

  IF      cur_gt_id = 'X'        THEN
    RAISE unexpected_error;
  ELSIF   cur_gt_id <> 'NO_GT_ID' THEN
    -- First delete
    delete_application
      (p_app_rec       => l_app_rec,
       x_return_status => x_return_status);

  ELSIF   cur_gt_id = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Apply
  apply(p_app_level    => p_app_level,
       --
        p_source_data_key1  => p_source_data_key1,
        p_source_data_key2  => p_source_data_key2,
        p_source_data_key3  => p_source_data_key3,
        p_source_data_key4  => p_source_data_key4,
        p_source_data_key5  => p_source_data_key5,
       --
        p_ctl_id       => p_ctl_id,
       --
        p_line_applied => p_line_applied,
        p_tax_applied  => p_tax_applied,
        p_freight_applied => p_freight_applied,
        p_charges_applied => p_charges_applied,
       --
        p_line_ediscounted => p_line_ediscounted,
        p_tax_ediscounted => p_tax_ediscounted,
        p_freight_ediscounted => p_freight_ediscounted,
        p_charges_ediscounted => p_charges_ediscounted,
       --
        p_line_uediscounted => p_line_uediscounted,
        p_tax_uediscounted => p_tax_uediscounted,
        p_freight_uediscounted => p_freight_uediscounted,
        p_charges_uediscounted => p_charges_uediscounted,
       --
        x_return_status => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

arp_standard.debug('application_execute -');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO first_delete_then_apply;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
  WHEN unexpected_error THEN
     ROLLBACK TO first_delete_then_apply;
     arp_standard.debug('EXCEPTION first_delete_then_apply unexpected_error - p_app_level:'
                        ||p_app_level||' - p_source_data_key1 :'||p_source_data_key1 ||' - p_ctl_id :'||p_ctl_id);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'Unexpected first_delete_then_apply - p_app_level:'
                           ||p_app_level||' - p_source_data_key1 :'||p_source_data_key1 ||' - p_ctl_id :'||p_ctl_id);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
  WHEN OTHERS THEN
     ROLLBACK TO first_delete_then_apply;
     arp_standard.debug('EXCEPTION first_delete_then_apply OTHERS:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'OTHERS first_delete_then_apply:'||SQLERRM );
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
END application_execute;

PROCEDURE get_app_ra_amounts
(p_gt_id                       IN NUMBER,
 x_ra_rec                      IN OUT NOCOPY ar_receivable_applications%ROWTYPE)
IS
  CURSOR c IS
  SELECT SUM(AMOUNT_APPLIED),
         SUM(AMOUNT_APPLIED_FROM),
         SUM(EARNED_DISCOUNT_TAKEN),
         SUM(UNEARNED_DISCOUNT_TAKEN),
         SUM(LINE_APPLIED),
         SUM(TAX_APPLIED),
         SUM(FREIGHT_APPLIED),
         SUM(RECEIVABLES_CHARGES_APPLIED),
         SUM(EARNED_DISCOUNT_TAKEN),
         SUM(UNEARNED_DISCOUNT_TAKEN),
         MAX(ACCTD_AMOUNT_APPLIED_FROM),
         SUM(ACCTD_AMOUNT_APPLIED_TO),
         SUM(ACCTD_EARNED_DISCOUNT_TAKEN),
         SUM(ACCTD_UNEARNED_DISCOUNT_TAKEN),
         MAX(AMOUNT_APPLIED_FROM),
         SUM(LINE_EDISCOUNTED),
         SUM(TAX_EDISCOUNTED),
         SUM(FREIGHT_EDISCOUNTED),
         SUM(CHARGES_EDISCOUNTED),
         SUM(LINE_UEDISCOUNTED),
         SUM(TAX_UEDISCOUNTED),
         SUM(FREIGHT_UEDISCOUNTED),
         SUM(CHARGES_UEDISCOUNTED),
         MAX(receivable_application_id)
    FROM ar_receivable_apps_gt
   WHERE gt_id = p_gt_id;
BEGIN
 OPEN c;
 FETCH c INTO
 x_ra_rec.amount_applied          ,
 x_ra_rec.AMOUNT_APPLIED_FROM     ,
 x_ra_rec.EARNED_DISCOUNT_TAKEN   ,
 x_ra_rec.UNEARNED_DISCOUNT_TAKEN ,
 x_ra_rec.LINE_APPLIED            ,
 x_ra_rec.TAX_APPLIED             ,
 x_ra_rec.FREIGHT_APPLIED         ,
 x_ra_rec.RECEIVABLES_CHARGES_APPLIED,
 x_ra_rec.EARNED_DISCOUNT_TAKEN   ,
 x_ra_rec.UNEARNED_DISCOUNT_TAKEN ,
 x_ra_rec.ACCTD_AMOUNT_APPLIED_FROM,
 x_ra_rec.ACCTD_AMOUNT_APPLIED_TO  ,
 x_ra_rec.ACCTD_EARNED_DISCOUNT_TAKEN,
 x_ra_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN,
 x_ra_rec.AMOUNT_APPLIED_FROM      ,
 x_ra_rec.LINE_EDISCOUNTED         ,
 x_ra_rec.TAX_EDISCOUNTED          ,
 x_ra_rec.FREIGHT_EDISCOUNTED     ,
 x_ra_rec.CHARGES_EDISCOUNTED     ,
 x_ra_rec.LINE_UEDISCOUNTED       ,
 x_ra_rec.TAX_UEDISCOUNTED        ,
 x_ra_rec.FREIGHT_UEDISCOUNTED    ,
 x_ra_rec.CHARGES_UEDISCOUNTED    ,
 x_ra_rec.receivable_application_id;
 CLOSE c;
END get_app_ra_amounts;




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
 x_msg_data                OUT NOCOPY VARCHAR2)
IS
  CURSOR c IS
  SELECT SUM(AMOUNT_APPLIED),
         SUM(AMOUNT_APPLIED_FROM),
         SUM(EARNED_DISCOUNT_TAKEN),
         SUM(UNEARNED_DISCOUNT_TAKEN),
         SUM(LINE_APPLIED),
         SUM(TAX_APPLIED),
         SUM(FREIGHT_APPLIED),
         SUM(RECEIVABLES_CHARGES_APPLIED),
         SUM(EARNED_DISCOUNT_TAKEN),
         SUM(UNEARNED_DISCOUNT_TAKEN),
         MAX(ACCTD_AMOUNT_APPLIED_FROM),
         SUM(ACCTD_AMOUNT_APPLIED_TO),
         SUM(ACCTD_EARNED_DISCOUNT_TAKEN),
         SUM(ACCTD_UNEARNED_DISCOUNT_TAKEN),
         MAX(AMOUNT_APPLIED_FROM),
         SUM(LINE_EDISCOUNTED),
         SUM(TAX_EDISCOUNTED),
         SUM(FREIGHT_EDISCOUNTED),
         SUM(CHARGES_EDISCOUNTED),
         SUM(LINE_UEDISCOUNTED),
         SUM(TAX_UEDISCOUNTED),
         SUM(FREIGHT_UEDISCOUNTED),
         SUM(CHARGES_UEDISCOUNTED),
         MAX(receivable_application_id)
    FROM ar_receivable_apps_gt
   WHERE applied_customer_trx_id = g_customer_trx.customer_trx_id;
  l_adj_rec   ar_adjustments%ROWTYPE;

  x_application_ref_id         NUMBER;
  x_application_ref_num        VARCHAR2(30);
  x_receivable_application_id  NUMBER;
  x_acctd_amount_applied_from  NUMBER;
  x_acctd_amount_applied_to    NUMBER;
  x_claim_reason_name          VARCHAR2(30);

  l_app_from                   NUMBER;
  l_tx_rate                    NUMBER;

BEGIN
arp_standard.debug('final_commit +');
arp_standard.debug('   customer_trx_id :'||g_customer_trx.customer_trx_id);

savepoint final_commit;

  x_return_status := fnd_api.g_ret_sts_success;
  OPEN c;
  FETCH c INTO x_ra_rec.AMOUNT_APPLIED,
               x_ra_rec.AMOUNT_APPLIED_FROM,
               x_ra_rec.EARNED_DISCOUNT_TAKEN,
               x_ra_rec.UNEARNED_DISCOUNT_TAKEN,
               x_ra_rec.LINE_APPLIED,
               x_ra_rec.TAX_APPLIED,
               x_ra_rec.FREIGHT_APPLIED,
               x_ra_rec.RECEIVABLES_CHARGES_APPLIED,
               x_ra_rec.EARNED_DISCOUNT_TAKEN,
               x_ra_rec.UNEARNED_DISCOUNT_TAKEN,
               x_ra_rec.ACCTD_AMOUNT_APPLIED_FROM,
               x_ra_rec.ACCTD_AMOUNT_APPLIED_TO,
               x_ra_rec.ACCTD_EARNED_DISCOUNT_TAKEN,
               x_ra_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN,
               x_ra_rec.AMOUNT_APPLIED_FROM,
               x_ra_rec.LINE_EDISCOUNTED,
               x_ra_rec.TAX_EDISCOUNTED,
               x_ra_rec.FREIGHT_EDISCOUNTED,
               x_ra_rec.CHARGES_EDISCOUNTED,
               x_ra_rec.LINE_UEDISCOUNTED,
               x_ra_rec.TAX_UEDISCOUNTED,
               x_ra_rec.FREIGHT_UEDISCOUNTED,
               x_ra_rec.CHARGES_UEDISCOUNTED,
               x_ra_rec.receivable_application_id;
  IF c%FOUND THEN
    --
    UPDATE ar_line_app_detail_gt
    SET gt_id = USERENV('SESSIONID')
    WHERE gt_id LIKE USERENV('SESSIONID')||'%';
    --
    UPDATE ar_receivable_apps_gt
    SET gt_id = USERENV('SESSIONID')
    WHERE gt_id LIKE USERENV('SESSIONID')||'%';

/*
    arp_det_dist_pkg.final_update_inv_ctl_rem_orig
       (p_customer_trx => g_customer_trx);

    arp_det_dist_pkg.create_final_split
       (p_customer_trx => g_customer_trx,
        p_app_rec      => x_ra_rec,
        p_adj_rec      => l_adj_rec,
        p_ae_sys_rec   => g_ae_sys_rec);
*/

IF NVL(p_amount_applied_from,0) <> 0 THEN

  l_app_from := p_amount_applied_from;

ELSE

  IF    (x_ra_rec.amount_applied_from IS NOT NULL
     AND x_ra_rec.amount_applied_from <> 0
	 AND x_ra_rec.amount_applied_from <> x_ra_rec.amount_applied)
   THEN
    l_app_from := x_ra_rec.amount_applied_from;
  ELSE
    l_app_from := x_ra_rec.AMOUNT_APPLIED;
  END IF;

END IF;

arp_standard.debug(' x_ra_rec.amount_applied:'||x_ra_rec.amount_applied);
arp_standard.debug(' p_amount_applied_from  :'||p_amount_applied_from);
arp_standard.debug(' x_ra_rec.amount_applied_from:'||x_ra_rec.amount_applied_from);
arp_standard.debug(' l_app_from             :'||l_app_from);


IF NVL(p_trans_to_receipt_rate,0) <> 0 THEN
  l_tx_rate  := p_trans_to_receipt_rate;
ELSE
  l_tx_rate  := x_ra_rec.trans_to_receipt_rate;
END IF;



    -- call arp_process_application
    arp_process_application.receipt_application(
     p_receipt_ps_id         => g_payschedule_rec.payment_schedule_id,
	 p_invoice_ps_id         => g_payschedule_trx.payment_schedule_id,
     p_amount_applied        => x_ra_rec.amount_applied,
     p_amount_applied_from   => l_app_from,
     p_trans_to_receipt_rate => l_tx_rate,
     p_invoice_currency_code => g_customer_trx.invoice_currency_code,
     p_receipt_currency_code => g_cash_receipt.currency_code,
     p_earned_discount_taken => x_ra_rec.earned_discount_taken,
     p_unearned_discount_taken =>x_ra_rec.unearned_discount_taken,
     p_apply_date             => p_apply_date,
     p_gl_date                => p_gl_date,
     p_ussgl_transaction_code => NULL,
     p_customer_trx_line_id   => NULL,
     p_application_ref_type   => NULL,
     p_application_ref_id     => NULL,
     p_application_ref_num    => NULL,
     p_secondary_application_ref_id => NULL,
     p_attribute_category     => p_attribute_category,
     p_attribute1  => p_attribute1,
     p_attribute2  => p_attribute2,
     p_attribute3  => p_attribute3,
     p_attribute4  => p_attribute4,
     p_attribute5  => p_attribute5,
     p_attribute6  => p_attribute6,
     p_attribute7  => p_attribute7,
     p_attribute8 => p_attribute8,
     p_attribute9 => p_attribute9,
     p_attribute10 => p_attribute10,
     p_attribute11 => p_attribute11,
     p_attribute12 => p_attribute12,
     p_attribute13 => p_attribute13,
     p_attribute14 => p_attribute14,
     p_attribute15 => p_attribute15,
     p_global_attribute_category => p_global_attribute_category,
     p_global_attribute1 => p_global_attribute1,
     p_global_attribute2 => p_global_attribute2,
     p_global_attribute3 => p_global_attribute3,
     p_global_attribute4 => p_global_attribute4,
     p_global_attribute5 => p_global_attribute5,
     p_global_attribute6 => p_global_attribute6,
     p_global_attribute7 => p_global_attribute7,
     p_global_attribute8 => p_global_attribute8,
     p_global_attribute9 => p_global_attribute9,
     p_global_attribute10 => p_global_attribute10,
     p_global_attribute11 => p_global_attribute11,
     p_global_attribute12 => p_global_attribute11,
     p_global_attribute13 => p_global_attribute13,
     p_global_attribute14 => p_global_attribute14,
     p_global_attribute15 => p_global_attribute15,
     p_global_attribute16 => p_global_attribute16,
     p_global_attribute17 => p_global_attribute17,
     p_global_attribute18 => p_global_attribute18,
     p_global_attribute19 => p_global_attribute19,
     p_global_attribute20 => p_global_attribute20,
     p_comments => p_comments,
     p_module_name => 'LLCAFINALCOMMIT',
     p_module_version => '1.0',
	-- OUT NOCOPY
     x_application_ref_id => x_application_ref_id,
     x_application_ref_num => x_application_ref_num,
     x_return_status       => x_return_status,
     x_msg_count           => x_msg_count,
     x_msg_data            => x_msg_data,
     p_out_rec_application_id => x_receivable_application_id,
     p_acctd_amount_applied_from => x_acctd_amount_applied_from,
     p_acctd_amount_applied_to => x_acctd_amount_applied_to,
     x_claim_reason_name     => x_claim_reason_name,
     p_called_from           => NULL,
     p_move_deferred_tax     => NULL,
     p_link_to_trx_hist_id   => NULL,
     p_amount_due_remaining  => NULL,
     p_payment_set_id        => NULL,
     p_application_ref_reason => NULL,
     p_customer_reference     => NULL,
     p_customer_reason        => NULL,
     from_llca_call     => 'Y',
     p_gt_id            => USERENV('SESSIONID'));

  END IF;
  CLOSE c;

  IF x_return_status = fnd_api.g_ret_sts_success THEN
    arp_ps_util.populate_closed_dates( p_gl_date,
                                       p_apply_date,
                                       g_payschedule_trx.class,
                                       g_payschedule_trx );
    -- update inv ps
    arp_ps_pkg.update_p( g_payschedule_trx);

    arp_det_dist_pkg.final_update_inv_ctl_rem_orig(p_customer_trx =>g_customer_trx);

    x_ra_rec.application_ref_id := x_application_ref_id;
    x_ra_rec.application_ref_num := x_application_ref_num;
    x_ra_rec.receivable_application_id := x_receivable_application_id;
    --{Cross Currency
    x_ra_rec.amount_applied_from :=   p_amount_applied_from;
    x_ra_rec.trans_to_receipt_rate := p_trans_to_receipt_rate;
    x_ra_rec.acctd_amount_applied_from := x_acctd_amount_applied_from;
    x_ra_rec.acctd_amount_applied_to  := x_acctd_amount_applied_to; /* Bug 5189370 */
    --}
    DELETE FROM ra_customer_trx_lines_gt WHERE customer_trx_id = g_customer_trx.customer_trx_id;
    g_payschedule_trx := g_payschedule_clr;
    g_payschedule_rec := g_payschedule_clr;

    DELETE FROM ra_ar_gt WHERE gt_id = TO_CHAR(USERENV('SESSIONID'));
    DELETE FROM ar_line_app_detail_gt WHERE gt_id = TO_CHAR(USERENV('SESSIONID'));
    DELETE FROM ar_receivable_apps_gt where gt_id = TO_CHAR(USERENV('SESSIONID')); /* 5438627 */
    DELETE FROM ar_ae_alloc_rec_gt where ae_id = TO_CHAR(USERENV('SESSIONID')); /* 5438627 */



  END IF;

arp_standard.debug('final_commit -');
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK TO final_commit;
     arp_standard.debug('EXCEPTION OTHERS final_commit:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.final_commit-'||SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END final_commit;


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
(p_app_level          IN VARCHAR2 DEFAULT 'TRANSACTION',
 p_source_data_key1   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key2   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key3   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key4   IN VARCHAR2 DEFAULT NULL,
 p_source_data_key5   IN VARCHAR2 DEFAULT NULL,
 p_ctl_id             IN NUMBER   DEFAULT NULL,
 x_line_rem           OUT NOCOPY  NUMBER,
 x_tax_rem            OUT NOCOPY  NUMBER,
 x_freight_rem        OUT NOCOPY  NUMBER,
 x_charges_rem        OUT NOCOPY  NUMBER,
 x_return_status      OUT NOCOPY  VARCHAR2,
 x_msg_data           OUT NOCOPY  VARCHAR2,
 x_msg_count          OUT NOCOPY  NUMBER)
IS
 CURSOR c_trx IS
 SELECT SUM(DECODE(line_type,'LINE',NVL(AMOUNT_DUE_REMAINING,0)))      line_rem,
        SUM(DECODE(line_type,'TAX' ,NVL(AMOUNT_DUE_REMAINING,0)))      tax_rem,
        SUM(DECODE(line_type,'LINE',NVL(CHRG_AMOUNT_REMAINING,0)))     chrg_rem,
        SUM(DECODE(line_type,'LINE',NVL(FRT_ADJ_REMAINING,0))) +
                SUM(DECODE(line_type,'FREIGHT',NVL(AMOUNT_DUE_REMAINING,0))) frt_rem
   FROM ra_customer_trx_lines_gt
  WHERE CUSTOMER_TRX_ID = g_customer_trx.customer_trx_id;

 CURSOR c_line IS
 SELECT SUM(DECODE(line_type,'LINE',NVL(AMOUNT_DUE_REMAINING,0)))      line_rem,
        SUM(DECODE(line_type,'TAX' ,NVL(AMOUNT_DUE_REMAINING,0)))      tax_rem,
        SUM(DECODE(line_type,'LINE',NVL(CHRG_AMOUNT_REMAINING,0)))     chrg_rem,
        SUM(DECODE(line_type,'LINE',NVL(FRT_ADJ_REMAINING,0))) +
          SUM(DECODE(line_type,'FREIGHT',NVL(AMOUNT_DUE_REMAINING,0))) frt_rem
   FROM ra_customer_trx_lines_gt
  WHERE CUSTOMER_TRX_ID = g_customer_trx.customer_trx_id
    AND DECODE(line_type,'LINE',customer_trx_line_id, LINK_TO_CUST_TRX_LINE_ID) = p_ctl_id;

 CURSOR c_gp IS
 SELECT SUM(DECODE(line_type,'LINE',NVL(AMOUNT_DUE_REMAINING,0)))      line_rem,
        SUM(DECODE(line_type,'TAX' ,NVL(AMOUNT_DUE_REMAINING,0)))      tax_rem,
        SUM(DECODE(line_type,'LINE',NVL(CHRG_AMOUNT_REMAINING,0)))     chrg_rem,
        SUM(DECODE(line_type,'LINE',NVL(FRT_ADJ_REMAINING,0))) +
          SUM(DECODE(line_type,'FREIGHT',NVL(AMOUNT_DUE_REMAINING,0))) frt_rem
   FROM ra_customer_trx_lines_gt
  WHERE CUSTOMER_TRX_ID     = g_customer_trx.customer_trx_id
    AND source_data_key1    = NVL(p_source_data_key1,'00')
    AND source_data_key2    = NVL(p_source_data_key2,'00')
    AND source_data_key3    = NVL(p_source_data_key3,'00')
    AND source_data_key4    = NVL(p_source_data_key4,'00')
    AND source_data_key5    = NVL(p_source_data_key5,'00');
BEGIN
  arp_standard.debug('get_latest_amount_remaining +');
  arp_standard.debug('    customer_trx_id   :'||g_customer_trx.customer_trx_id);
  arp_standard.debug('    p_app_level       :'||p_app_level);
  arp_standard.debug('    p_source_data_key1:'||p_source_data_key1);
  arp_standard.debug('    p_ctl_id          :'||p_ctl_id);
  IF     p_app_level = 'TRANSACTION' THEN
    OPEN c_trx;
    FETCH c_trx INTO x_line_rem, x_tax_rem, x_charges_rem, x_freight_rem;
    CLOSE c_trx;
  ELSIF  p_app_level = 'GROUP' THEN
    OPEN c_gp;
    FETCH c_gp INTO x_line_rem, x_tax_rem, x_charges_rem, x_freight_rem;
    CLOSE c_gp;
  ELSIF  p_app_level = 'LINE' THEN
    OPEN c_line;
    FETCH c_line INTO x_line_rem, x_tax_rem, x_charges_rem, x_freight_rem;
    CLOSE c_line;
  END IF;
  arp_standard.debug('    x_line_rem     :'||x_line_rem);
  arp_standard.debug('    x_tax_rem      :'||x_tax_rem);
  arp_standard.debug('    x_freight_rem  :'||x_freight_rem);
  arp_standard.debug('    x_charges_rem  :'||x_charges_rem);
  arp_standard.debug('get_latest_amount_remaining -');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     arp_standard.debug('EXCEPTION NO_DATA_FOUND get_latest_amount_remaining:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'get_latest_amount_remaining NO_DATA_FOUND
 customer_trx_id   :'||g_customer_trx.customer_trx_id||'
 p_app_level       :'||p_app_level||'
 p_ctl_id          :'||p_ctl_id);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION OTHERS get_latest_amount_remaining:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_latest_amount_remaining-'||SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_latest_amount_remaining;

/*-----------------------------------------------------------------------------+
 | Procedure   get_latest_amount_applied                                       |
 +-----------------------------------------------------------------------------+
 | Parameter :                                                                 |
 |   p_customer_trx_id The invoice ID                                          |
 |   p_app_level      Application Level (TRANSACTION/GROUP/LINE)               |
 |   p_group_id       Group_id req when Application level is GROUP             |
 |   p_ctl_id         customer_trx_line_id required when the application level |
 |                    is LINE                                                  |
 |   p_log_inv_line   'N'/'Y' if 'N' then only return the amount applied on    |
 |                    a trx line. If 'Y' then should the ctl_id  be a line     |
 |                    type LINE and the TAX and FREIGHT line linked to the LINE|
 |                    line will be part of the result                          |
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
 x_msg_count          OUT NOCOPY  NUMBER)
IS
  CURSOR c_trx_local IS
   SELECT SUM(NVL(LINE_APPLIED,0))         app_line,
          SUM(NVL(TAX_APPLIED,0))           app_tax,
          SUM(NVL(FREIGHT_APPLIED,0))       app_frt,
          SUM(NVL(RECEIVABLES_CHARGES_APPLIED,0))   app_chrg,
          SUM(NVL(LINE_EDISCOUNTED,0))      ed_line,
          SUM(NVL(TAX_EDISCOUNTED,0))       ed_tax,
          SUM(NVL(FREIGHT_EDISCOUNTED,0))   ed_frt,
          SUM(NVL(CHARGES_EDISCOUNTED,0))   ed_chrg,
          SUM(NVL(LINE_UEDISCOUNTED,0))     uned_line,
          SUM(NVL(TAX_UEDISCOUNTED,0))      uned_tax,
          SUM(NVL(FREIGHT_UEDISCOUNTED,0))  uned_frt,
          SUM(NVL(CHARGES_UEDISCOUNTED,0))  uned_chrg
     FROM ar_receivable_apps_gt;

  CURSOR c_gp_local IS
  SELECT SUM(NVL(LINE_APPLIED,0))          app_line,
         SUM(NVL(TAX_APPLIED,0))           app_tax,
         SUM(NVL(LINE_EDISCOUNTED,0))      ed_line,
         SUM(NVL(TAX_EDISCOUNTED,0))       ed_tax,
         SUM(NVL(LINE_UEDISCOUNTED,0))     uned_line,
         SUM(NVL(TAX_UEDISCOUNTED,0))      uned_tax
    FROM ar_receivable_apps_gt
   WHERE SOURCE_DATA_KEY1 = NVL(p_source_data_key1,'00')
     AND SOURCE_DATA_KEY2 = NVL(p_source_data_key2,'00')
     AND SOURCE_DATA_KEY3 = NVL(p_source_data_key3,'00')
     AND SOURCE_DATA_KEY4 = NVL(p_source_data_key4,'00')
     AND SOURCE_DATA_KEY5 = NVL(p_source_data_key5,'00');

  CURSOR c_log_inv_line IS
  SELECT SUM(NVL(LINE_APPLIED,0))          app_line,
         SUM(NVL(TAX_APPLIED,0))           app_tax,
         SUM(NVL(LINE_EDISCOUNTED,0))      ed_line,
         SUM(NVL(TAX_EDISCOUNTED,0))       ed_tax,
         SUM(NVL(LINE_UEDISCOUNTED,0))     uned_line,
         SUM(NVL(TAX_UEDISCOUNTED,0))      uned_tax
    FROM ar_receivable_apps_gt
   WHERE CTL_ID = p_ctl_id;

   CURSOR cu_line IS
    SELECT DECODE(line_type,'LINE','OK',line_type)
      FROM ra_customer_trx_lines_gt
     WHERE customer_trx_line_id  = p_ctl_id;

 l_line_app   NUMBER := 0;
 l_tax_app    NUMBER := 0;
 l_frt_app    NUMBER := 0;
 l_chrg_app   NUMBER := 0;
 l_line_ed    NUMBER := 0;
 l_tax_ed     NUMBER := 0;
 l_frt_ed     NUMBER := 0;
 l_chrg_ed    NUMBER := 0;
 l_line_uned  NUMBER := 0;
 l_tax_uned   NUMBER := 0;
 l_frt_uned   NUMBER := 0;
 l_chrg_uned  NUMBER := 0;


 l_db_line_app   NUMBER := 0;
 l_db_tax_app    NUMBER := 0;
 l_db_frt_app    NUMBER := 0;
 l_db_chrg_app   NUMBER := 0;
 l_db_line_ed    NUMBER := 0;
 l_db_tax_ed     NUMBER := 0;
 l_db_frt_ed     NUMBER := 0;
 l_db_chrg_ed    NUMBER := 0;
 l_db_line_uned  NUMBER := 0;
 l_db_tax_uned   NUMBER := 0;
 l_db_frt_uned   NUMBER := 0;
 l_db_chrg_uned  NUMBER := 0;

    l_res                      VARCHAR2(30);
    not_a_valid_inv_line       EXCEPTION;
    not_a_line_type_inv_line   EXCEPTION;
BEGIN
  arp_standard.debug('get_latest_amount_applied +');
  arp_standard.debug('    p_customer_trx_id :'||g_customer_trx.customer_trx_id);
  arp_standard.debug('    p_app_level       :'||p_app_level);
  arp_standard.debug('    p_source_data_key1:'||p_source_data_key1);
  arp_standard.debug('    p_ctl_id          :'||p_ctl_id);

  x_line_app           := l_line_app;
  x_tax_app            := l_tax_app;
  x_freight_app        := l_frt_app;
  x_charges_app        := l_chrg_app;
  x_line_ed            := l_line_ed;
  x_tax_ed             := l_tax_ed;
  x_freight_ed         := l_frt_ed;
  x_charges_ed         := l_chrg_ed;
  x_line_uned          := l_line_uned;
  x_tax_uned           := l_tax_uned;
  x_freight_uned       := l_frt_uned;
  x_charges_uned       := l_chrg_uned;

  IF     p_app_level = 'TRANSACTION' THEN
   get_trx_db_app(x_line_app => l_db_line_app,
                  x_tax_app  => l_db_tax_app,
                  x_frt_app  => l_db_frt_app,
                  x_chrg_app => l_db_chrg_app,
                  x_line_ed  => l_db_line_ed,
                  x_tax_ed   => l_db_tax_ed,
                  x_frt_ed   => l_db_frt_ed,
                  x_chrg_ed  => l_db_chrg_ed,
                  x_line_uned=> l_db_line_uned,
                  x_tax_uned => l_db_tax_uned,
                  x_frt_uned => l_db_frt_uned,
                  x_chrg_uned=> l_db_chrg_uned);

  IF l_db_line_app IS NULL THEN
   l_db_line_app    := 0;
   l_db_tax_app     := 0;
   l_db_frt_app     := 0;
   l_db_chrg_app    := 0;
   l_db_line_ed     := 0;
   l_db_tax_ed      := 0;
   l_db_frt_ed      := 0;
   l_db_chrg_ed     := 0;
   l_db_line_uned   := 0;
   l_db_tax_uned    := 0;
   l_db_frt_uned    := 0;
   l_db_chrg_uned   := 0;
  END IF;

  OPEN c_trx_local;
    FETCH c_trx_local INTO l_line_app,
                        l_tax_app,
                        l_frt_app,
                        l_chrg_app,
                        l_line_ed,
                        l_tax_ed,
                        l_frt_ed,
                        l_chrg_ed,
                        l_line_uned,
                        l_tax_uned,
                        l_frt_uned,
                        l_chrg_uned;

    IF (c_trx_local%FOUND)  THEN
      x_line_app           := l_db_line_app  + NVL(l_line_app,0);
      x_tax_app            := l_db_tax_app   + NVL(l_tax_app,0);
      x_freight_app        := l_db_frt_app   + NVL(l_frt_app,0);
      x_charges_app        := l_db_chrg_app  + NVL(l_chrg_app,0);
      x_line_ed            := l_db_line_ed   + NVL(l_line_ed,0);
      x_tax_ed             := l_db_tax_ed    + NVL(l_tax_ed,0);
      x_freight_ed         := l_db_frt_ed    + NVL(l_frt_ed,0);
      x_charges_ed         := l_db_chrg_ed   + NVL(l_chrg_ed,0);
      x_line_uned          := l_db_line_uned + NVL(l_line_uned,0);
      x_tax_uned           := l_db_tax_uned  + NVL(l_tax_uned,0);
      x_freight_uned       := l_db_frt_uned  + NVL(l_frt_uned,0);
      x_charges_uned       := l_db_chrg_uned + NVL(l_chrg_uned,0);
    ELSE
      x_line_app           := l_db_line_app;
      x_tax_app            := l_db_tax_app;
      x_freight_app        := l_db_frt_app;
      x_charges_app        := l_db_chrg_app;
      x_line_ed            := l_db_line_ed;
      x_tax_ed             := l_db_tax_ed;
      x_freight_ed         := l_db_frt_ed;
      x_charges_ed         := l_db_chrg_ed;
      x_line_uned          := l_db_line_uned;
      x_tax_uned           := l_db_tax_uned;
      x_freight_uned       := l_db_frt_uned;
      x_charges_uned       := l_db_chrg_uned;
    END IF;
  CLOSE c_trx_local;


  ELSIF  p_app_level = 'GROUP' THEN

    get_group_db_app
      (p_source_data_key1 => p_source_data_key1,
       p_source_data_key2 => p_source_data_key2,
       p_source_data_key3 => p_source_data_key3,
       p_source_data_key4 => p_source_data_key4,
       p_source_data_key5 => p_source_data_key5,
       x_line_app         => l_db_line_app,
       x_tax_app          => l_db_tax_app,
       x_line_ed          => l_db_line_ed,
       x_tax_ed           => l_db_tax_ed,
       x_line_uned        => l_db_line_uned,
       x_tax_uned         => l_db_tax_uned);

  IF l_db_line_app IS NULL THEN
   l_db_line_app    := 0;
   l_db_tax_app     := 0;
   l_db_line_ed     := 0;
   l_db_tax_ed      := 0;
   l_db_line_uned   := 0;
   l_db_tax_uned    := 0;
  END IF;

   OPEN c_gp_local;
   FETCH c_gp_local INTO l_line_app,
                         l_tax_app,
                         l_line_ed,
                         l_tax_ed,
                         l_line_uned,
                         l_tax_uned;
    IF c_gp_local%FOUND    THEN
      x_line_app           := l_db_line_app + NVL(l_line_app,0);
      x_tax_app            := l_db_tax_app  + NVL(l_tax_app,0);
      x_line_ed            := l_db_line_ed  + NVL(l_line_ed,0);
      x_tax_ed             := l_db_tax_ed   + NVL(l_tax_ed,0);
      x_line_uned          := l_db_line_uned + NVL(l_line_uned,0);
      x_tax_uned           := l_db_tax_uned + NVL(l_tax_uned,0);
    ELSE
      x_line_app           := l_db_line_app;
      x_tax_app            := l_db_tax_app;
      x_line_ed            := l_db_line_ed;
      x_tax_ed             := l_db_tax_ed;
      x_line_uned          := l_db_line_uned;
      x_tax_uned           := l_db_tax_uned;
    END IF;
  CLOSE c_gp_local;

  ELSIF  p_app_level = 'LINE' THEN

    get_log_line_db_app
      (p_log_line_id      => p_ctl_id,
       x_line_app         => l_db_line_app,
       x_tax_app          => l_db_tax_app,
       x_line_ed          => l_db_line_ed,
       x_tax_ed           => l_db_tax_ed,
       x_line_uned        => l_db_line_uned,
       x_tax_uned         => l_db_tax_uned);

  IF l_db_line_app IS NULL THEN
   l_db_line_app    := 0;
   l_db_tax_app     := 0;
   l_db_line_ed     := 0;
   l_db_tax_ed      := 0;
   l_db_line_uned   := 0;
   l_db_tax_uned    := 0;
  END IF;

   OPEN c_log_inv_line;
   FETCH c_log_inv_line INTO l_line_app,
                             l_tax_app,
                             l_line_ed,
                             l_tax_ed,
                             l_line_uned,
                             l_tax_uned;
    IF c_log_inv_line%FOUND    THEN
      x_line_app           := l_db_line_app + NVL(l_line_app,0);
      x_tax_app            := l_db_tax_app  + NVL(l_tax_app,0);
      x_line_ed            := l_db_line_ed + NVL(l_line_ed,0);
      x_tax_ed             := l_db_tax_ed + NVL(l_tax_ed,0);
      x_line_uned          := l_db_line_uned + NVL(l_line_uned,0);
      x_tax_uned           := l_db_tax_uned + NVL(l_tax_uned,0);
    ELSE
      x_line_app           := l_db_line_app;
      x_tax_app            := l_db_tax_app;
      x_line_ed            := l_db_line_ed;
      x_tax_ed             := l_db_tax_ed;
      x_line_uned          := l_db_line_uned;
      x_tax_uned           := l_db_tax_uned;
    END IF;
  CLOSE c_log_inv_line;

  END IF;
  arp_standard.debug('    x_line_app     :'||x_line_app);
  arp_standard.debug('    x_tax_app      :'||x_tax_app);
  arp_standard.debug('    x_freight_app  :'||x_freight_app);
  arp_standard.debug('    x_charges_app  :'||x_charges_app);
  arp_standard.debug('    x_line_ed      :'||x_line_ed);
  arp_standard.debug('    x_tax_ed       :'||x_tax_ed);
  arp_standard.debug('    x_freight_ed   :'||x_freight_ed);
  arp_standard.debug('    x_charges_ed   :'||x_charges_ed);
  arp_standard.debug('    x_line_uned    :'||x_line_uned);
  arp_standard.debug('    x_tax_uned     :'||x_tax_uned);
  arp_standard.debug('    x_freight_uned :'||x_freight_uned);
  arp_standard.debug('    x_charges_uned :'||x_charges_uned);
  arp_standard.debug('get_latest_amount_applied -');
EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION OTHERS get_latest_amount_applied:'||SQLERRM);
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_latest_amount_applied-'||SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_latest_amount_applied;



FUNCTION base_for_proration
(p_customer_trx_id   IN NUMBER,
 p_gt_id             IN NUMBER,
 p_line_type         IN VARCHAR2,
 p_activity          IN VARCHAR2)
RETURN  NUMBER
IS
  CURSOR cu_base IS
  SELECT SUM(DECODE(p_activity,
                    'APP'     ,DECODE(p_line_type,'LINE', NVL(line_amount,0),
                                                  'TAX' , NVL(tax_amount,0) ,0),
                    'ADJ'     ,DECODE(p_line_type,'LINE', NVL(line_amount,0),
                                                  'TAX' , NVL(tax_amount,0) ,0),
                    'ED'      ,DECODE(p_line_type,'LINE', NVL(ed_line_amount,0),
                                                  'TAX' , NVL(ed_tax_amount,0) ,0),
                    'UNED'    ,DECODE(p_line_type,'LINE', NVL(uned_line_amount,0),
                                                  'TAX' , NVL(uned_tax_amount,0) ,0),0))
    FROM ar_line_dist_interface_gt
   WHERE customer_trx_id  = p_customer_trx_id
     AND gt_id            = p_gt_id;
  l_res   NUMBER;
BEGIN
  OPEN cu_base;
  FETCH cu_base INTO l_res;
  IF cu_base%NOTFOUND THEN
     l_res  := 0;
  END IF;
  CLOSE cu_base;
  RETURN l_res;
END;

FUNCTION element_for_proration
(p_customer_trx_id        IN NUMBER,
 p_customer_trx_line_id   IN NUMBER,
 p_gt_id                  IN NUMBER,
 p_line_type              IN VARCHAR2,
 p_activity               IN VARCHAR2)
RETURN  NUMBER
IS
  CURSOR cu_element IS
  SELECT DECODE(p_activity,'APP' ,DECODE(line_type,'LINE',line_amount     , 'TAX',tax_amount,NULL),
                           'ED'  ,DECODE(line_type,'LINE',ed_line_amount  , 'TAX',ed_tax_amount,NULL),
                           'UNED',DECODE(line_type,'LINE',uned_line_amount, 'TAX',uned_tax_amount,NULL),NULL)
    FROM ar_line_dist_interface_gt
   WHERE customer_trx_id      = p_customer_trx_id
     AND customer_trx_line_id = p_customer_trx_line_id
     AND gt_id                = p_gt_id
     AND line_type            = p_line_type;
  l_res   NUMBER;
BEGIN
  OPEN cu_element;
  FETCH cu_element INTO l_res;
  IF cu_element%NOTFOUND THEN
     l_res  := 0;
  END IF;
  CLOSE cu_element;
  RETURN l_res;
END;


PROCEDURE verif_int_adj_line_tax
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 p_adj_rec          IN ar_adjustments%ROWTYPE,
 p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
 p_gt_id            IN NUMBER,
 p_line_flag        IN VARCHAR2 DEFAULT 'INTERFACE',
 p_tax_flag         IN VARCHAR2 DEFAULT 'INTERFACE',
 x_return_status    IN OUT NOCOPY VARCHAR2)
IS
  CURSOR verif_amt IS
  SELECT /*+INDEX (ar_line_dist_interface_gt ar_line_dist_interface_gt_n1)*/
          CASE WHEN p_line_flag      = 'INTERFACE' THEN SUM(NVL(line_amount,0))      ELSE NULL END
         ,CASE WHEN p_tax_flag       = 'INTERFACE' THEN SUM(NVL(tax_amount,0))       ELSE NULL END
    FROM ar_line_dist_interface_gt
   WHERE gt_id           = p_gt_id
     AND customer_trx_id = p_customer_trx.customer_trx_id
	 AND source_table    = 'ADJ';

  l_sum_line       NUMBER;
  l_sum_tax        NUMBER;
  l_sum_ed_line    NUMBER;
  l_sum_ed_tax     NUMBER;
  l_sum_uned_line  NUMBER;
  l_sum_uned_tax   NUMBER;
  i                NUMBER := 0;
BEGIN
  arp_standard.debug('verif_int_adj_line_tax +');
  arp_standard.debug('  adjustment_id  :'||p_adj_rec.adjustment_id);
  arp_standard.debug('  p_line_flag    :'||p_line_flag);
  arp_standard.debug('  p_tax_flag     :'||p_tax_flag);

  IF p_gt_id  IS NULL THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug('  p_gt_id IS NULL, please excecute arp_det_dist_pkg.get_gt_sequence');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT','  p_gt_id IS NULL, please excecute arp_det_dist_pkg.get_gt_sequence');
     FND_MSG_PUB.ADD;
  ELSE

  IF    ((p_adj_rec.amount IS NULL) AND (p_adj_rec.acctd_amount IS NULL))
        OR
        ((p_adj_rec.amount = 0    ) AND (p_adj_rec.acctd_amount = 0    ))
  THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug('  Adjustment record amount and accounted amount causes no need to execute');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT','  Adjustment record amount and accounted amount causes no need to execute');
     FND_MSG_PUB.ADD;
  ELSIF ((p_adj_rec.amount IS NULL) AND (p_adj_rec.acctd_amount IS NOT NULL))
        OR
        ((p_adj_rec.amount = 0    ) AND (p_adj_rec.acctd_amount <> 0       ))
        OR
        ((p_adj_rec.amount <> p_adj_rec.acctd_amount) AND
             (p_customer_trx.invoice_currency_code = p_ae_sys_rec.base_currency))
  THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug('  Adjustment record combination causes an invalid combination');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT','  Adjustment record combination causes an invalid combination');
     FND_MSG_PUB.ADD;
  END IF;

  OPEN verif_amt;
  FETCH verif_amt INTO   l_sum_line       ,
                         l_sum_tax        ;
  CLOSE verif_amt;

  arp_standard.debug('  sum line from ar_line_dist_interface_gt, l_sum_line      :'||l_sum_line);
  arp_standard.debug('  sum tax from ar_line_dist_interface_gt, l_sum_tax        :'||l_sum_tax);

  IF (l_sum_line      = NULL) AND (l_sum_tax      = NULL )
  THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug(' There is no line amount and tax amount in the interface table for this adjustment');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT',' There is no line amount and tax amount in the interface table for adjustment -'||
	                    ' adjustment_id : ' || p_adj_rec.adjustment_id);
  END IF;


  IF (p_line_flag = 'Y') AND (l_sum_line <> p_adj_rec.line_adjusted) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug('  Adjustment line_adjusted <> l_sum_line from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','  Adjustment line_adjusted <> l_sum_line from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  IF (p_tax_flag = 'Y') AND (l_sum_tax <> p_adj_rec.tax_adjusted) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug('  Adjustment tax_adjusted <> l_sum_tax from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','  Adjustment tax_adjusted <> l_sum_tax from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  END IF;
  arp_standard.debug('verif_int_adj_line_tax -');
END;


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
 x_return_status    IN OUT NOCOPY VARCHAR2)
IS
  CURSOR verif_amt IS
  SELECT /*+INDEX (ar_line_dist_interface_gt ar_line_dist_interface_gt_n1)*/
          CASE WHEN p_line_flag      = 'INTERFACE' THEN SUM(NVL(line_amount,0))      ELSE NULL END
         ,CASE WHEN p_tax_flag       = 'INTERFACE' THEN SUM(NVL(tax_amount,0))       ELSE NULL END
         ,CASE WHEN p_ed_line_flag   = 'INTERFACE' THEN SUM(NVL(ed_line_amount,0))   ELSE NULL END
         ,CASE WHEN p_ed_tax_flag    = 'INTERFACE' THEN SUM(NVL(ed_tax_amount,0))    ELSE NULL END
         ,CASE WHEN p_uned_line_flag = 'INTERFACE' THEN SUM(NVL(uned_line_amount,0)) ELSE NULL END
         ,CASE WHEN p_uned_tax_flag  = 'INTERFACE' THEN SUM(NVL(uned_tax_amount,0))  ELSE NULL END
    FROM ar_line_dist_interface_gt
   WHERE gt_id           = p_gt_id
     AND customer_trx_id = p_customer_trx.customer_trx_id
	 AND source_table    = 'RA';

  l_sum_line       NUMBER;
  l_sum_tax        NUMBER;
  l_sum_ed_line    NUMBER;
  l_sum_ed_tax     NUMBER;
  l_sum_uned_line  NUMBER;
  l_sum_uned_tax   NUMBER;
  i                NUMBER := 0;
BEGIN
  arp_standard.debug('verif_int_app_line_tax +');
  arp_standard.debug('  receivable_application_id           :'||p_app_rec.receivable_application_id);
  arp_standard.debug('  p_app_rec.amount_applied            :'||p_app_rec.amount_applied);
  arp_standard.debug('  p_app_rec.acctd_amount_applied_to   :'||p_app_rec.acctd_amount_applied_to);
  arp_standard.debug('  p_customer_trx.invoice_currency_code:'||p_customer_trx.invoice_currency_code);
  arp_standard.debug('  p_ae_sys_rec.base_currency          :'||p_ae_sys_rec.base_currency);
  arp_standard.debug('  p_line_flag       :'||p_line_flag);
  arp_standard.debug('  p_tax_flag        :'||p_tax_flag);
  arp_standard.debug('  p_ed_line_flag    :'||p_ed_line_flag);
  arp_standard.debug('  p_ed_tax_flag     :'||p_ed_tax_flag);
  arp_standard.debug('  p_uned_line_flag  :'||p_uned_line_flag);
  arp_standard.debug('  p_uned_tax_flag   :'||p_uned_tax_flag);

  IF p_gt_id  IS NULL THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug('  p_gt_id IS NULL, please excecute arp_det_dist_pkg.get_gt_sequence');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT','  p_gt_id IS NULL, please excecute arp_det_dist_pkg.get_gt_sequence');
     FND_MSG_PUB.ADD;
  ELSE

  IF    ((p_app_rec.amount_applied IS NULL) AND (p_app_rec.acctd_amount_applied_to IS NULL))
        OR
        ((p_app_rec.amount_applied = 0    ) AND (p_app_rec.acctd_amount_applied_to = 0    ))
  THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug(' Application record amount and accounted amount to causes no need to execute'||
	                    ' as no amount in amount_applied and acctd_amount_applied_to bucket');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT',' Application record amount and accounted amount to causes no need to execute'||
	                    ' as no amount in amount_applied and acctd_amount_applied_to bucket');
     FND_MSG_PUB.ADD;
  ELSIF ((p_app_rec.amount_applied IS NULL) AND (p_app_rec.acctd_amount_applied_to IS NOT NULL))
        OR
        ((p_app_rec.amount_applied = 0    ) AND (p_app_rec.acctd_amount_applied_to <> 0       ))
        OR
        ((p_app_rec.amount_applied <> p_app_rec.acctd_amount_applied_to) AND
             (p_customer_trx.invoice_currency_code = p_ae_sys_rec.base_currency))
  THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug(' Application record combination causes an invalid combination on amount bucket');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT','  Application record combination causes an invalid combination');
     FND_MSG_PUB.ADD;
  END IF;

  OPEN verif_amt;
  FETCH verif_amt INTO   l_sum_line       ,
                         l_sum_tax        ,
                         l_sum_ed_line    ,
                         l_sum_ed_tax     ,
                         l_sum_uned_line  ,
                         l_sum_uned_tax   ;
  CLOSE verif_amt;

  arp_standard.debug('TABLE  ar_line_dist_interface_gt ');
  arp_standard.debug('  l_sum_line        :'||l_sum_line);
  arp_standard.debug('  l_sum_tax         :'||l_sum_tax);
  arp_standard.debug('  l_sum_ed_line     :'||l_sum_ed_line);
  arp_standard.debug('  l_sum_ed_tax      :'||l_sum_ed_tax);
  arp_standard.debug('  l_sum_uned_line   :'||l_sum_uned_line);
  arp_standard.debug('  l_sum_uned_tax    :'||l_sum_uned_tax);

  arp_standard.debug('RECORD  p_app_rec ');
  arp_standard.debug('  p_app_rec.line_applied              :'||p_app_rec.line_applied);
  arp_standard.debug('  p_app_rec.tax_applied               :'||p_app_rec.tax_applied);
  arp_standard.debug('  p_app_rec.LINE_EDISCOUNTED          :'||p_app_rec.LINE_EDISCOUNTED);
  arp_standard.debug('  p_app_rec.TAX_EDISCOUNTED           :'||p_app_rec.TAX_EDISCOUNTED);
  arp_standard.debug('  p_app_rec.LINE_UEDISCOUNTED         :'||p_app_rec.LINE_UEDISCOUNTED);
  arp_standard.debug('  p_app_rec.TAX_UEDISCOUNTED          :'||p_app_rec.TAX_UEDISCOUNTED);


  IF (l_sum_line      = NULL) AND (l_sum_tax      = NULL ) AND
     (l_sum_ed_line   = NULL) AND (l_sum_ed_tax   = NULL ) AND
     (l_sum_uned_line = NULL) AND (l_sum_uned_tax = NULL )
  THEN
     x_return_status    := fnd_api.g_ret_sts_error;
     arp_standard.debug(' There is no line amount, tax amount for app, edisc and unedisc in the interface table for this application');
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
     FND_MESSAGE.SET_TOKEN('TEXT',' There is no line amount, tax amount for app, edisc and unedisc in the interface table for this application'||
	                    ' receivable_application_id : ' || p_app_rec.receivable_application_id);
  END IF;


  IF (p_line_flag = 'Y') AND (l_sum_line <> p_app_rec.line_applied) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug('  Application line_applied ('||p_app_rec.line_applied||')<> l_sum_line('||l_sum_line||') from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','  Application line_applied ('||p_app_rec.line_applied||')<> l_sum_line('||l_sum_line||') from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  IF (p_tax_flag = 'Y') AND (l_sum_tax <> p_app_rec.tax_applied) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug(' Adjustment tax_adjusted ('||p_app_rec.tax_applied||')<> l_sum_tax('||l_sum_tax||') from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT',' Adjustment tax_adjusted ('||p_app_rec.tax_applied||')<> l_sum_tax('||l_sum_tax||') from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  IF (p_ed_line_flag = 'Y') AND (l_sum_ed_line <> p_app_rec.LINE_EDISCOUNTED) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug('  Application line_ediscounted ('||p_app_rec.LINE_EDISCOUNTED||')<> l_sum_ed_line('||l_sum_ed_line||') from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','  Application line_ediscounted ('||p_app_rec.LINE_EDISCOUNTED||')<> l_sum_ed_line('||l_sum_ed_line||') from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  IF (p_ed_tax_flag = 'Y') AND (l_sum_ed_tax <> p_app_rec.TAX_EDISCOUNTED) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug('  Application tax_ediscounted ('||p_app_rec.tax_EDISCOUNTED||')<> l_sum_ed_tax('||l_sum_ed_tax||') from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','  Application tax_ediscounted ('||p_app_rec.tax_EDISCOUNTED||')<> l_sum_ed_tax('||l_sum_ed_tax||') from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  IF (p_uned_line_flag = 'Y') AND (l_sum_uned_line <> p_app_rec.LINE_uEDISCOUNTED) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug('  Application line_uediscounted ('||p_app_rec.LINE_uEDISCOUNTED||')<> l_sum_uned_line('||l_sum_uned_line||') from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','  Application line_uediscounted ('||p_app_rec.LINE_uEDISCOUNTED||')<> l_sum_uned_line('||l_sum_uned_line||') from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  IF (p_uned_tax_flag = 'Y') AND (l_sum_uned_tax <> p_app_rec.TAX_uEDISCOUNTED) THEN
    x_return_status    := fnd_api.g_ret_sts_error;
    arp_standard.debug('  Application tax_uediscounted ('||p_app_rec.tax_uEDISCOUNTED||')<> l_sum_uned_tax('||l_sum_uned_tax||') from ar_line_dist_interface_gt');
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','  Application tax_uediscounted ('||p_app_rec.tax_uEDISCOUNTED||')<> l_sum_uned_tax('||l_sum_uned_tax||') from ar_line_dist_interface_gt');
    FND_MSG_PUB.ADD;
  END IF;

  END IF;
  arp_standard.debug('verif_int_app_line_tax -');
END;



PROCEDURE breakup_discounts (
/*--------------------------------------------------------------------------+
 private procedure used for LLCA bucket-wise breakup RM Jul 19, 2005
+---------------------------------------------------------------------------*/
  --in variables
  lin_discount_in in  		 NUMBER,
  tax_discount_in in 		 NUMBER,
  frt_discount_in in 		 NUMBER,
  tot_earned_discount_in in 		 NUMBER,
  tot_unearned_discount_in in 		 NUMBER,
  --out variables
  ed_lin_out out nocopy number,
  ued_lin_out out nocopy number,
  ed_tax_out out nocopy number,
  ued_tax_out out nocopy number,
  ed_frt_out out nocopy number,
  ued_frt_out out nocopy number
)
IS
l_denom number;
begin

  arp_standard.debug ('llc brk dsc lin in= ' || lin_discount_in);
  arp_standard.debug ('llc brk dsc tax in= ' || tax_discount_in);
  arp_standard.debug ('llc brk dsc frt in= ' || frt_discount_in);
  arp_standard.debug ('llc brk dsc ed in= ' || tot_earned_discount_in);
  arp_standard.debug ('llc brk dsc ued in= ' || tot_unearned_discount_in);

  l_denom := tot_earned_discount_in + tot_unearned_discount_in;

  if l_denom <> 0 then
    ed_lin_out := (lin_discount_in / l_denom) * tot_earned_discount_in;
    ued_lin_out := lin_discount_in - ed_lin_out;

    ed_tax_out := (tax_discount_in / l_denom) * tot_earned_discount_in;
    ued_tax_out :=  tax_discount_in - ed_tax_out;

    ed_frt_out := (frt_discount_in / l_denom) * tot_earned_discount_in;
    ued_frt_out := frt_discount_in - ed_frt_out;

  end if;
  arp_standard.debug ('llc ed_lin_out '||ed_lin_out );
  arp_standard.debug ('llc ued_lin_out '||ued_lin_out );
  arp_standard.debug ('llc ed_tax_out '||ed_tax_out );
  arp_standard.debug ('llc ued_tax_out '||ued_tax_out );
  arp_standard.debug ('llc ed_frt_out '||ed_frt_out );
  arp_standard.debug ('llc ued_frt_out '||ued_frt_out );

END breakup_discounts;




END arp_process_det_pkg;

/
