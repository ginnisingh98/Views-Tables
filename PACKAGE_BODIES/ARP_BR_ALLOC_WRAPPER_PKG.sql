--------------------------------------------------------
--  DDL for Package Body ARP_BR_ALLOC_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BR_ALLOC_WRAPPER_PKG" AS
/* $Header: ARTWRAPB.pls 115.10 2004/03/16 03:22:30 vahluwal noship $ */

/* =======================================================================
 | Package Globals BR - Bills Receivable
 * ======================================================================*/
  g_ae_line_tbl         ae_line_tbl_type;
  g_empty_ae_line_tbl   ae_line_tbl_type;
  g_ae_line_ctr         BINARY_INTEGER;

/* =======================================================================
 | Prototype declarations
 * ======================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Get_Assign_Rate_Alloc_Tax(
                 p_mode                   IN      VARCHAR2                          ,
                 p_ae_doc_rec             IN      ae_doc_rec_type                   ,
                 p_ae_event_rec           IN      ae_event_rec_type                 ,
                 p_cust_inv_rec           IN      ra_customer_trx%ROWTYPE           ,
                 p_ae_sys_rec             IN      ae_sys_rec_type                   ,
                 p_ae_rule_rec            IN OUT NOCOPY  ae_rule_rec_type                  ,
                 p_app_rec                IN OUT NOCOPY  ar_receivable_applications%ROWTYPE,
                 p_adj_rec                IN OUT NOCOPY  ar_adjustments%ROWTYPE             );

PROCEDURE Assign_Ael_Elements(
                p_mode                  IN VARCHAR2          ,
                p_ae_doc_rec            IN ae_doc_rec_type   ,
                p_ae_event_rec          IN ae_event_rec_type ,
                p_ae_line_rec           IN ae_line_rec_type );

PROCEDURE Allocate_Tax_BR_Main(
                 p_mode                   IN      VARCHAR2                            ,
                 p_ae_doc_rec             IN      ae_doc_rec_type                     ,
                 p_ae_event_rec           IN      ae_event_rec_type                   ,
                 p_ae_rule_rec            IN      ae_rule_rec_type                    ,
                 p_app_rec                IN      ar_receivable_applications%ROWTYPE  ,
                 p_cust_inv_rec           IN      ra_customer_trx%ROWTYPE             ,
                 p_adj_rec                IN      ar_adjustments%ROWTYPE              ,
                 p_ae_sys_rec             IN      ae_sys_rec_type                     ,
                 p_ae_ctr                 IN OUT NOCOPY  BINARY_INTEGER                      ,
                 p_ae_line_tbl            IN OUT NOCOPY  ae_line_tbl_type) IS

l_ae_doc_rec  ae_doc_rec_type;
l_ae_rule_rec ae_rule_rec_type;
l_app_rec     ar_receivable_applications%ROWTYPE;
l_adj_rec     ar_adjustments%ROWTYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'ARP_ALLOC_WRAPPER_PKG.Allocate_Tax_BR_Main (+)' );
  END IF;

/*-----------------------------------------------------------------------------------+
 | Initialize the compatible records matching input parameters passed to this routine|
 | This is necessary because the records below are changed for processing purposes.  |
 +-----------------------------------------------------------------------------------*/
  l_ae_doc_rec  := p_ae_doc_rec;
  l_ae_rule_rec := p_ae_rule_rec;
  l_app_rec     := p_app_rec;
  l_adj_rec     := p_adj_rec;

/*-----------------------------------------------------------------------------------+
 | Set called from to Wrapper to indicate that call made from this routine to the tax|
 | Accounting engine.                                                                |
 +-----------------------------------------------------------------------------------*/
  l_ae_doc_rec.called_from := 'WRAPPER';

/*-----------------------------------------------------------------------------------+
 | Override the source table setting it to RA as we are simulating an application    |
 | for the maturity date event as if we are applying the whole amount to a Bill using|
 | a receipt application.                                                            |
 +-----------------------------------------------------------------------------------*/
  IF (l_ae_doc_rec.event = 'MATURITY_DATE') THEN
     l_ae_doc_rec.source_table := 'RA';
  END IF;

  g_ae_line_ctr := 0;
  g_ae_line_tbl := g_empty_ae_line_tbl;

  IF l_ae_doc_rec.source_table = 'RA' THEN
     l_ae_rule_rec.tax_amt_alloc         := nvl(l_app_rec.tax_applied,0)                 * -1;
     l_ae_rule_rec.charges_amt_alloc     := nvl(l_app_rec.receivables_charges_applied,0) * -1;
     l_ae_rule_rec.line_amt_alloc        := nvl(l_app_rec.line_applied,0)                * -1;
     l_ae_rule_rec.freight_amt_alloc     := nvl(l_app_rec.freight_applied,0)             * -1;

     arp_util.Set_Buckets(
                  p_header_acctd_amt   => nvl(l_app_rec.acctd_amount_applied_to,0)       * -1 ,
                  p_base_currency      => p_ae_sys_rec.base_currency                          ,
                  p_exchange_rate      => p_cust_inv_rec.exchange_rate                        ,
                  p_base_precision     => p_ae_sys_rec.base_precision                         ,
                  p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit                      ,
                  p_tax_amt            => l_ae_rule_rec.tax_amt_alloc                         ,
                  p_charges_amt        => l_ae_rule_rec.charges_amt_alloc                     ,
                  p_line_amt           => l_ae_rule_rec.line_amt_alloc                        ,
                  p_freight_amt        => l_ae_rule_rec.freight_amt_alloc                     ,
                  p_tax_acctd_amt      => l_ae_rule_rec.tax_acctd_amt_alloc                   ,
                  p_charges_acctd_amt  => l_ae_rule_rec.charges_acctd_amt_alloc               ,
                  p_line_acctd_amt     => l_ae_rule_rec.line_acctd_amt_alloc                  ,
                  p_freight_acctd_amt  => l_ae_rule_rec.freight_acctd_amt_alloc                 );

     Get_Assign_Rate_Alloc_Tax(
                 p_mode           =>   p_mode         ,
                 p_ae_doc_rec     =>   l_ae_doc_rec   ,
                 p_ae_event_rec   =>   p_ae_event_rec ,
                 p_cust_inv_rec   =>   p_cust_inv_rec ,
                 p_ae_sys_rec     =>   p_ae_sys_rec   ,
                 p_ae_rule_rec    =>   l_ae_rule_rec  ,
                 p_app_rec        =>   l_app_rec      ,
                 p_adj_rec        =>   l_adj_rec        );

  ELSIF l_ae_doc_rec.source_table = 'ADJ' THEN
        l_ae_rule_rec.tax_amt_alloc       := nvl(l_adj_rec.tax_adjusted,0);
        l_ae_rule_rec.charges_amt_alloc   := nvl(l_adj_rec.receivables_charges_adjusted,0);
        l_ae_rule_rec.line_amt_alloc      := nvl(l_adj_rec.line_adjusted,0);
        l_ae_rule_rec.freight_amt_alloc   := nvl(l_adj_rec.freight_adjusted,0);

     arp_util.Set_Buckets(
                  p_header_acctd_amt   => nvl(l_adj_rec.acctd_amount,0)                     ,
                  p_base_currency      => p_ae_sys_rec.base_currency                        ,
                  p_exchange_rate      => p_cust_inv_rec.exchange_rate                      ,
                  p_base_precision     => p_ae_sys_rec.base_precision                       ,
                  p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit                    ,
                  p_tax_amt            => l_ae_rule_rec.tax_amt_alloc                       ,
                  p_charges_amt        => l_ae_rule_rec.charges_amt_alloc                   ,
                  p_line_amt           => l_ae_rule_rec.line_amt_alloc                      ,
                  p_freight_amt        => l_ae_rule_rec.freight_amt_alloc                   ,
                  p_tax_acctd_amt      => l_ae_rule_rec.tax_acctd_amt_alloc                 ,
                  p_charges_acctd_amt  => l_ae_rule_rec.charges_acctd_amt_alloc             ,
                  p_line_acctd_amt     => l_ae_rule_rec.line_acctd_amt_alloc                ,
                  p_freight_acctd_amt  => l_ae_rule_rec.freight_acctd_amt_alloc               );


     Get_Assign_Rate_Alloc_Tax(
                 p_mode            => p_mode         ,
                 p_ae_doc_rec      => l_ae_doc_rec   ,
                 p_ae_event_rec    => p_ae_event_rec ,
                 p_cust_inv_rec    => p_cust_inv_rec ,
                 p_ae_sys_rec      => p_ae_sys_rec   ,
                 p_ae_rule_rec     => l_ae_rule_rec  ,
                 p_app_rec         => l_app_rec      ,
                 p_adj_rec         => l_adj_rec        );

  ELSE --Unknown source table
     NULL; --Raise an Error ?
  END IF;

 /*-----------------------------------------------------------------+
  | Assign Tax allocated lines to the the in out NOCOPY table to pass      |
  | back to calling rountine                                        |
  +-----------------------------------------------------------------*/
   IF g_ae_line_tbl.EXISTS(g_ae_line_ctr) THEN

      p_ae_line_tbl := g_ae_line_tbl;
      p_ae_ctr      := g_ae_line_ctr;

   END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'ARP_ALLOC_WRAPPER_PKG.Allocate_Tax_BR_Main (-)' );
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'ARP_ALLOC_WRAPPER_PKG.Allocate_Tax_BR_Main - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'EXCEPTION: ARP_ALLOC_WRAPPER_PKG.Allocate_Tax_BR_Main');
     END IF;
     RAISE;

END Allocate_Tax_BR_Main;

/*=========================================================================
 |
 | PROCEDURE Get_Assign_Rate_Alloc_Tax
 |
 | DESCRIPTION
 |      This routine takes a header adjustment or application and creates
 |      sub adjustments or applications for each assignment. Further if an
 |      assignment is a Bill of Exchange then this routine is called
 |      recursively to to allocate the sub activity to assignments for that
 |      Bill
 |
 | PARAMETERS
 |      p_ae_doc_rec       document record
 |      p_ae_event_rec     accounting event record
 |      p_ae_rule_rec      Rule and allocation amounts record
 |      p_app_rec          Application record
 |      p_cust_inv_rec     Customer and exchange rate details for Bill
 |      p_adj_rec          Adjustment record
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 *=======================================================================*/
PROCEDURE Get_Assign_Rate_Alloc_Tax(
                 p_mode                   IN      VARCHAR2                          ,
                 p_ae_doc_rec             IN      ae_doc_rec_type                   ,
                 p_ae_event_rec           IN      ae_event_rec_type                 ,
                 p_cust_inv_rec           IN      ra_customer_trx%ROWTYPE           ,
                 p_ae_sys_rec             IN      ae_sys_rec_type                   ,
                 p_ae_rule_rec            IN OUT NOCOPY  ae_rule_rec_type                  ,
                 p_app_rec                IN OUT NOCOPY  ar_receivable_applications%ROWTYPE,
                 p_adj_rec                IN OUT NOCOPY  ar_adjustments%ROWTYPE             ) IS

CURSOR get_assignments(p_customer_trx_id IN NUMBER) is
   SELECT ctl.customer_trx_id                     br_cust_trx_id             ,
          ctl.customer_trx_line_id                br_customer_trx_line_id    ,
          ctl.br_ref_customer_trx_id              br_ref_customer_trx_id     ,
          ctl.br_ref_payment_schedule_id          br_ref_payment_schedule_id ,
          ct.drawee_id                            drawee_id                  ,
          ct.drawee_site_use_id                   drawee_site_use_id         ,
          ct.invoice_currency_code                invoice_currency_code      ,
          ct.exchange_rate                        exchange_rate              ,
          ct.exchange_rate_type                   exchange_rate_type         ,
          ct.exchange_date                        exchange_date              ,
          ct.trx_date                             trx_date                   ,
          ct.bill_to_customer_id                  bill_to_customer_id        ,
          ct.bill_to_site_use_id                  bill_to_site_use_id        ,
          adj.adjustment_id                       br_adj_id                  ,
          nvl(adj.amount,0)                       br_adj_amt                 ,
          nvl(adj.acctd_amount,0)                 br_adj_acctd_amt           ,
          nvl(adj.line_adjusted,0)                br_adj_line_amt            ,
          nvl(adj.tax_adjusted,0)                 br_adj_tax_amt             ,
          nvl(adj.freight_adjusted,0)             br_adj_frt_amt             ,
          nvl(adj.receivables_charges_adjusted,0) br_adj_chrg_amt
FROM ra_customer_trx_lines ctl,
     ar_adjustments  adj,
     ra_customer_trx ct
WHERE ctl.customer_trx_id = p_customer_trx_id
AND   ctl.br_adjustment_id = adj.adjustment_id
AND   ct.customer_trx_id = ctl.br_ref_customer_trx_id
AND   adj.status = 'A'
order by ctl.customer_trx_line_id;

TYPE l_br_rec_type IS RECORD (
     br_cust_trx_id             NUMBER,
     br_customer_trx_line_id    NUMBER,
     br_ref_customer_trx_id     NUMBER,
     br_ref_payment_schedule_id NUMBER,
     drawee_id                  NUMBER,
     drawee_site_use_id         NUMBER,
     invoice_currency_code      ra_customer_trx.invoice_currency_code%TYPE,
     exchange_rate              NUMBER,
     exchange_rate_type         ra_customer_trx.exchange_rate_type%TYPE,
     exchange_date              DATE,
     trx_date                   DATE,
     bill_to_customer_id        NUMBER,
     bill_to_site_use_id        NUMBER,
     br_adj_id                  NUMBER,
     br_adj_amt                 NUMBER,
     br_adj_acctd_amt           NUMBER,
     br_adj_line_amt            NUMBER,
     br_adj_tax_amt             NUMBER,
     br_adj_frt_amt             NUMBER,
     br_adj_chrg_amt            NUMBER,
     br_adj_line_acctd_amt      NUMBER,
     br_adj_tax_acctd_amt       NUMBER,
     br_adj_frt_acctd_amt       NUMBER,
     br_adj_chrg_acctd_amt      NUMBER
);

TYPE l_br_tbl_type IS TABLE of l_br_rec_type
  INDEX BY BINARY_INTEGER;

l_ae_line_tbl         ae_line_tbl_type;
l_ael_line_rec        ae_line_rec_type;
l_empty_ael_line_rec  ae_line_rec_type;

l_br_tbl l_br_tbl_type;
l_assn_ctr BINARY_INTEGER := 0;
l_assn_tot_tax_amt NUMBER := 0;
l_assn_tot_tax_acctd_amt NUMBER := 0;
l_assn_tot_chrg_amt NUMBER := 0;
l_assn_tot_chrg_acctd_amt NUMBER := 0;
l_assn_tot_line_amt NUMBER := 0;
l_assn_tot_line_acctd_amt NUMBER := 0;
l_assn_tot_frt_amt NUMBER := 0;
l_assn_tot_frt_acctd_amt NUMBER := 0;
l_pro_tax_amt NUMBER := 0;
l_pro_tax_acctd_amt  NUMBER := 0;
l_pro_chrg_amt NUMBER := 0;
l_pro_chrg_acctd_amt  NUMBER := 0;
l_pro_line_amt NUMBER := 0;
l_pro_line_acctd_amt  NUMBER := 0;
l_pro_frt_amt NUMBER := 0;
l_pro_frt_acctd_amt  NUMBER := 0;
l_pro_amt NUMBER := 0;
l_pro_acctd_amt  NUMBER := 0;
l_ae_ctr NUMBER;
l_customer_trx_id NUMBER;
l_tax_activity_amt NUMBER := 0;
l_tax_activity_acctd_amt NUMBER := 0;
l_chrg_activity_amt NUMBER := 0;
l_chrg_activity_acctd_amt NUMBER := 0;
l_line_activity_amt NUMBER := 0;
l_line_activity_acctd_amt NUMBER := 0;
l_frt_activity_amt NUMBER := 0;
l_frt_activity_acctd_amt NUMBER := 0;
l_tax_run_amt_tot NUMBER :=0;
l_tax_run_acctd_amt_tot NUMBER :=0;
l_chrg_run_amt_tot NUMBER :=0;
l_chrg_run_acctd_amt_tot NUMBER :=0;
l_line_run_amt_tot NUMBER :=0;
l_line_run_acctd_amt_tot NUMBER :=0;
l_frt_run_amt_tot NUMBER :=0;
l_frt_run_acctd_amt_tot NUMBER :=0;
l_tax_run_pro_amt_tot NUMBER := 0;
l_tax_run_pro_acctd_amt_tot NUMBER := 0;
l_chrg_run_pro_amt_tot NUMBER := 0;
l_chrg_run_pro_acctd_amt_tot NUMBER := 0;
l_line_run_pro_amt_tot NUMBER := 0;
l_line_run_pro_acctd_amt_tot NUMBER := 0;
l_frt_run_pro_amt_tot NUMBER := 0;
l_frt_run_pro_acctd_amt_tot NUMBER := 0;

l_cust_inv_rec ra_customer_trx%ROWTYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_ALLOC_WRAPPER_PKG.Get_Assign_Rate_Alloc_Tax (+)');
  END IF;
/*------------------------------------------------------------------------------+
 | Set the header amounts for the line, tax, freight, charges buckets. These are|
 | used for allocation to create sub activities from the master activity for    |
 | each assignment.                                                             |
 +------------------------------------------------------------------------------*/
  IF p_ae_doc_rec.source_table = 'RA' THEN

     l_customer_trx_id         := p_app_rec.applied_customer_trx_id       ;

  ELSIF p_ae_doc_rec.source_table = 'ADJ' THEN

     l_customer_trx_id         := p_adj_rec.customer_trx_id               ;

  END IF;

  l_tax_activity_amt        := p_ae_rule_rec.tax_amt_alloc             ;
  l_tax_activity_acctd_amt  := p_ae_rule_rec.tax_acctd_amt_alloc       ;
  l_chrg_activity_amt       := p_ae_rule_rec.charges_amt_alloc         ;
  l_chrg_activity_acctd_amt := p_ae_rule_rec.charges_acctd_amt_alloc   ;
  l_line_activity_amt       := p_ae_rule_rec.line_amt_alloc            ;
  l_line_activity_acctd_amt := p_ae_rule_rec.line_acctd_amt_alloc      ;
  l_frt_activity_amt        := p_ae_rule_rec.freight_amt_alloc         ;
  l_frt_activity_acctd_amt  := p_ae_rule_rec.freight_acctd_amt_alloc   ;

/*------------------------------------------------------------------------------+
 | Get the shadow adjustments rule record for usage by the tax accounting engine|
 | to move the deferred after prorating over each assignment.                   |
 +------------------------------------------------------------------------------*/
  FOR l_assign_rec IN get_assignments(p_customer_trx_id => l_customer_trx_id) LOOP

    l_assn_ctr := l_assn_ctr + 1;

    l_br_tbl(l_assn_ctr).br_cust_trx_id             := l_assign_rec.br_cust_trx_id;
    l_br_tbl(l_assn_ctr).br_customer_trx_line_id    := l_assign_rec.br_customer_trx_line_id;
    l_br_tbl(l_assn_ctr).br_ref_customer_trx_id     := l_assign_rec.br_ref_customer_trx_id;
    l_br_tbl(l_assn_ctr).br_ref_payment_schedule_id := l_assign_rec.br_ref_payment_schedule_id;
    l_br_tbl(l_assn_ctr).drawee_id                  := l_assign_rec.drawee_id;
    l_br_tbl(l_assn_ctr).drawee_site_use_id         := l_assign_rec.drawee_site_use_id;
    l_br_tbl(l_assn_ctr).br_adj_id                  := l_assign_rec.br_adj_id;
    l_br_tbl(l_assn_ctr).br_adj_amt                 := l_assign_rec.br_adj_amt;
    l_br_tbl(l_assn_ctr).br_adj_acctd_amt           := l_assign_rec.br_adj_acctd_amt;
    l_br_tbl(l_assn_ctr).br_adj_line_amt            := l_assign_rec.br_adj_line_amt;
    l_br_tbl(l_assn_ctr).br_adj_tax_amt             := l_assign_rec.br_adj_tax_amt;
    l_br_tbl(l_assn_ctr).br_adj_frt_amt             := l_assign_rec.br_adj_frt_amt;
    l_br_tbl(l_assn_ctr).br_adj_chrg_amt            := l_assign_rec.br_adj_chrg_amt;

 /*------------------------------------------------------------------------------------+
  | Derive the currency, exchange rate and third party information. Assignments on     |
  | a bill could have different third part and third party sub id information, hence   |
  | we rederive it. The currency and exchange rate details of assignments match Invoice|
  +------------------------------------------------------------------------------------*/
    l_br_tbl(l_assn_ctr).invoice_currency_code      := l_assign_rec.invoice_currency_code;
    l_br_tbl(l_assn_ctr).exchange_rate              := l_assign_rec.exchange_rate;
    l_br_tbl(l_assn_ctr).exchange_rate_type         := l_assign_rec.exchange_rate_type;
    l_br_tbl(l_assn_ctr).exchange_date              := l_assign_rec.exchange_date;
    l_br_tbl(l_assn_ctr).trx_date                   := l_assign_rec.trx_date;
    l_br_tbl(l_assn_ctr).bill_to_customer_id        := l_assign_rec.bill_to_customer_id;
    l_br_tbl(l_assn_ctr).bill_to_site_use_id        := l_assign_rec.bill_to_site_use_id;

/*------------------------------------------------------------------------------+
 | Get the accounted tax amounts from the shadow adjustments as a rate for each |
 | adjustment is required as tax for each adjustment / total tax. This is done  |
 | for both amounts and accounted amounts, to move deferred tax for adjustment  |
 | or application for each assignment correctly                                 |
 +------------------------------------------------------------------------------*/
    arp_util.Set_Buckets(
                 p_header_acctd_amt   => l_br_tbl(l_assn_ctr).br_adj_acctd_amt             ,
                 p_base_currency      => p_ae_sys_rec.base_currency                        ,
                 p_exchange_rate      => l_br_tbl(l_assn_ctr).exchange_rate                ,
                 p_base_precision     => p_ae_sys_rec.base_precision                       ,
                 p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit                    ,
                 p_tax_amt            => l_br_tbl(l_assn_ctr).br_adj_tax_amt               ,
                 p_charges_amt        => l_br_tbl(l_assn_ctr).br_adj_chrg_amt              ,
                 p_line_amt           => l_br_tbl(l_assn_ctr).br_adj_line_amt              ,
                 p_freight_amt        => l_br_tbl(l_assn_ctr).br_adj_frt_amt               ,
                 p_tax_acctd_amt      => l_br_tbl(l_assn_ctr).br_adj_tax_acctd_amt         ,
                 p_charges_acctd_amt  => l_br_tbl(l_assn_ctr).br_adj_chrg_acctd_amt        ,
                 p_line_acctd_amt     => l_br_tbl(l_assn_ctr).br_adj_line_acctd_amt        ,
                 p_freight_acctd_amt  => l_br_tbl(l_assn_ctr).br_adj_frt_acctd_amt          );

    l_assn_tot_tax_amt := l_assn_tot_tax_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_tax_amt;
    l_assn_tot_tax_acctd_amt  := l_assn_tot_tax_acctd_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_tax_acctd_amt;

    l_assn_tot_chrg_amt := l_assn_tot_chrg_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_chrg_amt;
    l_assn_tot_chrg_acctd_amt := l_assn_tot_chrg_acctd_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_chrg_acctd_amt;

    l_assn_tot_line_amt := l_assn_tot_line_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_line_amt;
    l_assn_tot_line_acctd_amt := l_assn_tot_line_acctd_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_line_acctd_amt;

    l_assn_tot_frt_amt := l_assn_tot_frt_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_frt_amt;
    l_assn_tot_frt_acctd_amt := l_assn_tot_frt_acctd_amt
                                       + l_br_tbl(l_assn_ctr).br_adj_frt_acctd_amt;

  END LOOP; --end loop through assignments

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_tax_amt = ' || l_assn_tot_tax_amt);
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_tax_acctd_amt = ' || l_assn_tot_tax_acctd_amt);
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_chrg_amt = ' || l_assn_tot_chrg_amt);
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_chrg_acctd_amt = ' || l_assn_tot_chrg_acctd_amt);
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_line_amt = ' || l_assn_tot_line_amt);
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_line_acctd_amt = ' || l_assn_tot_line_acctd_amt);
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_frt_amt = ' || l_assn_tot_frt_amt);
     arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || ' l_assn_tot_frt_acctd_amt = ' || l_assn_tot_frt_acctd_amt);
  END IF;

/*------------------------------------------------------------------------------+
 | Loop through assignments calling the tax accounting engine after allocating  |
 | the adjustment or application over each assignment, mimmicing activities on  |
 | each assignment.                                                             |
 +------------------------------------------------------------------------------*/
  IF l_br_tbl.EXISTS(l_assn_ctr) THEN

     FOR l_ctr IN l_br_tbl.FIRST .. l_br_tbl.LAST LOOP

      /*------------------------------------------------------------------------------------+
       | Derive the currency, exchange rate and third party information. Assignments on     |
       | a bill could have different third part and third party sub id information, hence   |
       | we rederive it. The currency and exchange rate details of assignments match Invoice|
       +------------------------------------------------------------------------------------*/
        l_cust_inv_rec.invoice_currency_code := l_br_tbl(l_assn_ctr).invoice_currency_code;
        l_cust_inv_rec.exchange_rate         := l_br_tbl(l_assn_ctr).exchange_rate;
        l_cust_inv_rec.exchange_rate_type    := l_br_tbl(l_assn_ctr).exchange_rate_type;
        l_cust_inv_rec.exchange_date         := l_br_tbl(l_assn_ctr).exchange_date;
        l_cust_inv_rec.trx_date              := l_br_tbl(l_assn_ctr).trx_date;
        l_cust_inv_rec.bill_to_customer_id   := l_br_tbl(l_assn_ctr).bill_to_customer_id;
        l_cust_inv_rec.bill_to_site_use_id   := l_br_tbl(l_assn_ctr).bill_to_site_use_id;
        l_cust_inv_rec.drawee_id             := l_br_tbl(l_assn_ctr).drawee_id;
        l_cust_inv_rec.drawee_site_use_id    := l_br_tbl(l_assn_ctr).drawee_site_use_id;

      /*------------------------------------------------------------------------------+
       | Allocate tax for activity on Bills Receivable,Tax lines 10, 20, 30, 40,      |
       | Tax Total 100, Tax on Discount 10                                            |
       |                                                                              |
       | Line 1  a -> 10 * 10/100  = 1 (allocated)                                    |
       |                                                                              |
       | Line 2    -> (10 + 20)/100 * 10 = 3                                          |
       |         b -> 3 - a = 2 (allocated)                                           |
       |                                                                              |
       | Line 3    -> (10 + 20 + 30) * 10/100 = 6                                     |
       |         c -> 6 - a - b = 3                                                   |
       | Line .....                                                                   |
       +------------------------------------------------------------------------------*/
        l_tax_run_amt_tot       := l_tax_run_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_tax_amt;
        l_tax_run_acctd_amt_tot := l_tax_run_acctd_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_tax_acctd_amt;
        l_pro_tax_amt := 0;

     /*------------------------------------------------------------------------------+
      | Allocate the amounts over each assignment using rates from the shadow        |
      | adjustments.                                                                 |
      +------------------------------------------------------------------------------*/
        IF l_assn_tot_tax_amt <> 0 THEN
           l_pro_tax_amt :=
             arpcurr.CurrRound(l_tax_run_amt_tot/l_assn_tot_tax_amt * l_tax_activity_amt,
                               l_cust_inv_rec.invoice_currency_code) - l_tax_run_pro_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_tax_amt for '|| l_ctr || ' = '||
                          l_pro_tax_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated Tax amount in currency of Invoice                 |
         +------------------------------------------------------------------------------*/
          l_tax_run_pro_amt_tot := l_tax_run_pro_amt_tot + l_pro_tax_amt;

        END IF;

      /*------------------------------------------------------------------------------+
       | Allocate the tax accounted amounts over each assignment using rates from the |
       | shadow adjustments.                                                          |
       +------------------------------------------------------------------------------*/
        l_pro_tax_acctd_amt := 0;

        IF l_assn_tot_tax_acctd_amt <> 0 THEN
           l_pro_tax_acctd_amt :=
              arpcurr.CurrRound(l_tax_run_acctd_amt_tot / l_assn_tot_tax_acctd_amt
                                 * l_tax_activity_acctd_amt, p_ae_sys_rec.base_currency)
                                    - l_tax_run_pro_acctd_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_tax_acctd_amt for '|| l_ctr || ' = '||
                               l_pro_tax_acctd_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated Tax accounted amount in base currency             |
         +------------------------------------------------------------------------------*/
          l_tax_run_pro_acctd_amt_tot := l_tax_run_pro_acctd_amt_tot + l_pro_tax_acctd_amt;
        END IF;

      /*--------------------------------------------------------------------------+
       | Allocate charges for activity on Bills Receivable                        |
       +--------------------------------------------------------------------------*/

        l_chrg_run_amt_tot       := l_chrg_run_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_chrg_amt;
        l_chrg_run_acctd_amt_tot := l_chrg_run_acctd_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_chrg_acctd_amt;
        l_pro_chrg_amt := 0;

     /*------------------------------------------------------------------------------+
      | Allocate the charges amounts over each assignment using rates from the shadow|
      | adjustments.                                                                 |
      +------------------------------------------------------------------------------*/
        IF l_assn_tot_chrg_amt <> 0 THEN
           l_pro_chrg_amt :=
             arpcurr.CurrRound(l_chrg_run_amt_tot/l_assn_tot_chrg_amt * l_chrg_activity_amt,
                               l_cust_inv_rec.invoice_currency_code) - l_chrg_run_pro_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_chrg_amt for '|| l_ctr || ' = '||
                          l_pro_chrg_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated Tax amount in currency of Invoice                 |
         +------------------------------------------------------------------------------*/
          l_chrg_run_pro_amt_tot := l_chrg_run_pro_amt_tot + l_pro_chrg_amt;

        END IF;

      /*------------------------------------------------------------------------------+
       | Allocate the charges accounted amounts over each assignment using rates from |
       | the shadow adjustments.                                                      |
       +------------------------------------------------------------------------------*/
        l_pro_chrg_acctd_amt := 0;

        IF l_assn_tot_chrg_acctd_amt <> 0 THEN
           l_pro_chrg_acctd_amt :=
              arpcurr.CurrRound(l_chrg_run_acctd_amt_tot / l_assn_tot_chrg_acctd_amt
                                 * l_chrg_activity_acctd_amt, p_ae_sys_rec.base_currency)
                                    - l_chrg_run_pro_acctd_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_chrg_acctd_amt for '|| l_ctr || ' = '||
                               l_pro_chrg_acctd_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated charges accounted amount in base currency         |
         +------------------------------------------------------------------------------*/
          l_chrg_run_pro_acctd_amt_tot := l_chrg_run_pro_acctd_amt_tot + l_pro_chrg_acctd_amt;
        END IF;


      /*--------------------------------------------------------------------------+
       | Allocate line for activity on Bills Receivable                           |
       +--------------------------------------------------------------------------*/

        l_line_run_amt_tot       := l_line_run_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_line_amt;
        l_line_run_acctd_amt_tot := l_line_run_acctd_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_line_acctd_amt;
        l_pro_line_amt := 0;

     /*------------------------------------------------------------------------------+
      | Allocate the line amounts over each assignment using rates from the shadow   |
      | adjustments.                                                                 |
      +------------------------------------------------------------------------------*/
        IF l_assn_tot_line_amt <> 0 THEN
           l_pro_line_amt :=
             arpcurr.CurrRound(l_line_run_amt_tot/l_assn_tot_line_amt * l_line_activity_amt,
                               l_cust_inv_rec.invoice_currency_code) - l_line_run_pro_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_line_amt for '|| l_ctr || ' = '||
                          l_pro_line_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated line amount in currency of Invoice                |
         +------------------------------------------------------------------------------*/
          l_line_run_pro_amt_tot := l_line_run_pro_amt_tot + l_pro_line_amt;

        END IF;

      /*------------------------------------------------------------------------------+
       | Allocate the line accounted amounts over each assignment using rates from    |
       | the shadow adjustments.                                                      |
       +------------------------------------------------------------------------------*/
        l_pro_line_acctd_amt := 0;

        IF l_assn_tot_line_acctd_amt <> 0 THEN
           l_pro_line_acctd_amt :=
              arpcurr.CurrRound(l_line_run_acctd_amt_tot / l_assn_tot_line_acctd_amt
                                 * l_line_activity_acctd_amt, p_ae_sys_rec.base_currency)
                                    - l_line_run_pro_acctd_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_line_acctd_amt for '|| l_ctr || ' = '||
                               l_pro_line_acctd_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated line accounted amount in base currency            |
         +------------------------------------------------------------------------------*/
          l_line_run_pro_acctd_amt_tot := l_line_run_pro_acctd_amt_tot + l_pro_line_acctd_amt;
        END IF;

      /*--------------------------------------------------------------------------+
       | Allocate freight for activity on Bills Receivable                        |
       +--------------------------------------------------------------------------*/

        l_frt_run_amt_tot        := l_frt_run_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_frt_amt;
        l_frt_run_acctd_amt_tot := l_frt_run_acctd_amt_tot
                                     + l_br_tbl(l_ctr).br_adj_frt_acctd_amt;
        l_pro_frt_amt := 0;

     /*------------------------------------------------------------------------------+
      | Allocate the freight amounts over each assignment using rates from the shadow|
      | adjustments.                                                                 |
      +------------------------------------------------------------------------------*/
        IF l_assn_tot_frt_amt <> 0 THEN
           l_pro_frt_amt :=
             arpcurr.CurrRound(l_frt_run_amt_tot/l_assn_tot_frt_amt * l_frt_activity_amt,
                               l_cust_inv_rec.invoice_currency_code) - l_frt_run_pro_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_frt_amt for '|| l_ctr || ' = '||
                          l_pro_frt_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated freight amount in currency of Invoice             |
         +------------------------------------------------------------------------------*/
          l_frt_run_pro_amt_tot := l_frt_run_pro_amt_tot + l_pro_frt_amt;

        END IF;

      /*------------------------------------------------------------------------------+
       | Allocate the freight accounted amounts over each assignment using rates from |
       | the shadow adjustments.                                                      |
       +------------------------------------------------------------------------------*/
        l_pro_frt_acctd_amt := 0;

        IF l_assn_tot_frt_acctd_amt <> 0 THEN
           l_pro_frt_acctd_amt :=
              arpcurr.CurrRound(l_frt_run_acctd_amt_tot / l_assn_tot_frt_acctd_amt
                                 * l_frt_activity_acctd_amt, p_ae_sys_rec.base_currency)
                                    - l_frt_run_pro_acctd_amt_tot;

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_frt_acctd_amt for '|| l_ctr || ' = '||
                               l_pro_frt_acctd_amt);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated freight accounted amount in base currency         |
         +------------------------------------------------------------------------------*/
          l_frt_run_pro_acctd_amt_tot := l_frt_run_pro_acctd_amt_tot + l_pro_frt_acctd_amt;
        END IF;

        l_pro_amt       := l_pro_tax_amt + l_pro_chrg_amt
                           + l_pro_line_amt + l_pro_frt_amt;

        l_pro_acctd_amt := l_pro_tax_acctd_amt + l_pro_chrg_acctd_amt
                           + l_pro_line_acctd_amt + l_pro_frt_acctd_amt;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_amt = ' || l_pro_amt);
           arp_standard.debug('Get_Assign_Rate_Alloc_Tax: ' || 'l_pro_acctd_amt = ' || l_pro_acctd_amt);
        END IF;

     /*------------------------------------------------------------------------------+
      | Now create a tax only application or adjustment, so that individual activity |
      | is simulated for each assignment. Its as if we have a single activity and it |
      | gets broken up into multiple activities over each assignment.                |
      +------------------------------------------------------------------------------*/
           IF (p_ae_doc_rec.source_table = 'RA') THEN

            --Set the application record buckets
              p_app_rec.applied_customer_trx_id     := l_br_tbl(l_ctr).br_ref_customer_trx_id;
              p_app_rec.applied_payment_schedule_id := l_br_tbl(l_ctr).br_ref_payment_schedule_id;
              p_app_rec.amount_applied              := l_pro_amt       * -1;
              p_app_rec.acctd_amount_applied_to     := l_pro_acctd_amt * -1;
              p_app_rec.line_applied                := l_pro_line_amt  * -1;
              p_app_rec.tax_applied                 := l_pro_tax_amt   * -1;
              p_app_rec.freight_applied             := l_pro_frt_amt   * -1;
              p_app_rec.receivables_charges_applied := l_pro_chrg_amt  * -1;

            --Initialize the allocation buckets for payments
              p_ae_rule_rec.tax_amt_alloc             := l_pro_tax_amt;
              p_ae_rule_rec.tax_acctd_amt_alloc       := l_pro_tax_acctd_amt;
              p_ae_rule_rec.charges_amt_alloc         := l_pro_chrg_amt;
              p_ae_rule_rec.charges_acctd_amt_alloc   := l_pro_chrg_acctd_amt;
              p_ae_rule_rec.line_amt_alloc            := l_pro_line_amt;
              p_ae_rule_rec.line_acctd_amt_alloc      := l_pro_line_acctd_amt;
              p_ae_rule_rec.freight_amt_alloc         := l_pro_frt_amt;
              p_ae_rule_rec.freight_acctd_amt_alloc   := l_pro_frt_acctd_amt;

           ELSIF (p_ae_doc_rec.source_table = 'ADJ') THEN

              --Set the adjustment record buckets
                 p_adj_rec.customer_trx_id               := l_br_tbl(l_ctr).br_ref_customer_trx_id;
                 p_adj_rec.payment_schedule_id           := l_br_tbl(l_ctr).br_ref_payment_schedule_id;
                 p_adj_rec.amount                        := l_pro_amt       ;
                 p_adj_rec.acctd_amount                  := l_pro_acctd_amt ;
                 p_adj_rec.line_adjusted                 := l_pro_line_amt  ;
                 p_adj_rec.tax_adjusted                  := l_pro_tax_amt   ;
                 p_adj_rec.freight_adjusted              := l_pro_frt_amt   ;
                 p_adj_rec.receivables_charges_adjusted  := l_pro_chrg_amt  ;

              --Set the adjustment assignment allocation buckets
                 p_ae_rule_rec.tax_amt_alloc             := l_pro_tax_amt       ;
                 p_ae_rule_rec.tax_acctd_amt_alloc       := l_pro_tax_acctd_amt ;
                 p_ae_rule_rec.charges_amt_alloc         := l_pro_chrg_amt      ;
                 p_ae_rule_rec.charges_acctd_amt_alloc   := l_pro_chrg_acctd_amt;
                 p_ae_rule_rec.line_amt_alloc            := l_pro_line_amt      ;
                 p_ae_rule_rec.line_acctd_amt_alloc      := l_pro_line_acctd_amt;
                 p_ae_rule_rec.freight_amt_alloc         := l_pro_frt_amt       ;
                 p_ae_rule_rec.freight_acctd_amt_alloc   := l_pro_frt_acctd_amt ;

           END IF;

           l_ae_line_tbl := g_empty_ae_line_tbl;
           l_ae_ctr      := 0;

        /*--------------------------------------------------------------------------+
         | Recursive call required because current assignment is a bill of exchange.|
         | So the process of allocation of buckets and call to the tax accounting   |
         | engine starts over again.
         +--------------------------------------------------------------------------*/
           IF l_br_tbl(l_ctr).drawee_site_use_id IS NOT NULL THEN

              Get_Assign_Rate_Alloc_Tax(
                    p_mode               =>   p_mode         ,
                    p_ae_doc_rec         =>   p_ae_doc_rec   ,
                    p_ae_event_rec       =>   p_ae_event_rec ,
                    p_cust_inv_rec       =>   l_cust_inv_rec ,
                    p_ae_sys_rec         =>   p_ae_sys_rec   ,
                    p_ae_rule_rec        =>   p_ae_rule_rec  ,
                    p_app_rec            =>   p_app_rec      ,
                    p_adj_rec            =>   p_adj_rec       );

           ELSE
           /*-----------------------------------------------------------------------------+
            | Call Tax accounting engine to allocate deferred tax for the tax adjusted or |
            | applied. For the maturity date event an application is simulated, without   |
            | discounts.                                                                  |
            +-----------------------------------------------------------------------------*/

              ARP_ALLOCATION_PKG.Allocate_Tax(
                    p_ae_doc_rec           => p_ae_doc_rec   ,     --Document detail
                    p_ae_event_rec         => p_ae_event_rec ,     --Event record
                    p_ae_rule_rec          => p_ae_rule_rec  ,     --Rule info for payment method
                    p_app_rec              => p_app_rec      ,     --Application details
                    p_cust_inv_rec         => l_cust_inv_rec ,     --Invoice details
                    p_adj_rec              => p_adj_rec      ,     --dummy adjustment record
                    p_ae_ctr               => l_ae_ctr       ,     --counter
                    p_ae_line_tbl          => l_ae_line_tbl  ,     --final tax accounting table
                    p_br_cust_trx_line_id  => l_br_tbl(l_ctr).br_customer_trx_line_id,
                    p_simul_app            => '');

              IF l_ae_line_tbl.EXISTS(l_ae_ctr) THEN --Atleast one Tax line exists

                FOR l_ctr1 IN l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST LOOP

                   --It is necessary to populate the record and then call assign elements

                     l_ael_line_rec := l_empty_ael_line_rec;
                     l_ael_line_rec := l_ae_line_tbl(l_ctr1);
              /*---------------------------------------------------------------------------------+
               | When the tax accounting engine is called for the maturity date event we simulate|
               | a Receipt application, hence the tax accounting engine uses a source table of RA|
               | however for the maturity date event the source table should be TH, so in this   |
               | case the source table is overriden from RA - applications to TH - Transaction   |
               | history.                                                                        |
               +---------------------------------------------------------------------------------*/
                     IF ((l_ael_line_rec.source_table = 'RA')
                                               AND (p_ae_doc_rec.event = 'MATURITY_DATE')) THEN
                        l_ael_line_rec.source_table := 'TH';
                     END IF;

                 /*----------------------------------------------------------------------------------+
                  | Populate the source table secondary for accounting created by the tax accounting |
                  | engine, because its is important to distinguish tax moved for a specific exchange|
                  | or transaction on the Bill. (tax codes and other accounting grouping attributes  |
                  | could be common across different transactions.)                                  |
                  +----------------------------------------------------------------------------------*/
                     l_ael_line_rec.source_table_secondary := 'CTL';
                     l_ael_line_rec.source_id_secondary    := l_br_tbl(l_ctr).br_customer_trx_line_id;
                     l_ael_line_rec.ae_line_type_secondary := 'ASSIGNMENT';

                   /*------------------------------------------------------------+
                    |Add the current tax allocation to the global table necessary|
                    |due to recursion. The global table is returned as output to |
                    |the calling parent routine.                                 |
                    +------------------------------------------------------------*/
                     Assign_Ael_Elements( p_mode         => p_mode,
                                          p_ae_doc_rec   => p_ae_doc_rec,
                                          p_ae_event_rec => p_ae_event_rec,
                                          p_ae_line_rec  => l_ael_line_rec );

                END LOOP;

             END IF; --end if atleast one tax line

           END IF; --check whether assignment is an exchange

     END LOOP; --end loop all assignments for a Bill

  END IF; --end if Bills Receivable Table exists

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_ALLOC_WRAPPER_PKG.Get_Assign_Rate_Alloc_Tax (-)');
  END IF;

END Get_Assign_Rate_Alloc_Tax;

/* =======================================================================
 | PROCEDURE Assign_Ael_Elements
 |
 | DESCRIPTION
 |      This procedure stores the AE Line record into AE Lines PLSQL table.
 |      Functions:
 |              - Determine regular or negative Dr/Cr.
 |              - Store AE Line Record in AE Lines PLSQL Table.
 |              - In a fully implemented SLA model, Will determine the
 |                account to use based on AE Line type and other parameters.
 |              - In a fully implemented SLA model, Will determine the
 |                account descriptions.
 |
 | GUIDELINE
 |      - This procedure can be shared across document types
 |      - Recommendation is to have one per document type(AE Derivation)
 |
 | PARAMETERS
 |      p_ae_line_rec     AE Line Record
 * ======================================================================*/
PROCEDURE Assign_Ael_Elements(
                p_mode                  IN VARCHAR2          ,
                p_ae_doc_rec            IN ae_doc_rec_type   ,
                p_ae_event_rec          IN ae_event_rec_type ,
                p_ae_line_rec           IN ae_line_rec_type ) IS

  l_account                     NUMBER;
  l_account_valid               BOOLEAN;
  l_replace_default_account     BOOLEAN;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_BR_ALLOC_WRAPPER_PKG.Assign_Ael_Elements()+');
    END IF;

   /*------------------------------------------------------+
    | Call Hook to Override Account                        |
    +------------------------------------------------------*/
    ARP_ACCT_HOOK.Override_Account(
                p_mode                    => p_mode,
                p_ae_doc_rec              => p_ae_doc_rec,
                p_ae_event_rec            => p_ae_event_rec,
                p_ae_line_rec             => p_ae_line_rec,
                p_account                 => l_account,
                p_account_valid           => l_account_valid,
                p_replace_default_account => l_replace_default_account
                );

    IF ( NOT l_replace_default_account ) THEN

      /*------------------------------------------------------+
       | SLA : Build Account for AE Line Type                 |
       |       When SLA is fully implemented Account Builder  |
       |       will be called from here.                      |
       +------------------------------------------------------*/
       l_account := p_ae_line_rec.account;

    END IF;             -- Replace default account?

   /*------------------------------------------------------+
    | SLA : Build Account description for AE Line Type     |
    |       When SLA is fully implemented Description      |
    |       builder will be called from here.              |
    +------------------------------------------------------*/

   /*------------------------------------------------------+
    | SLA : Check Negative Dr/Cr for AE Line               |
    |       When SLA is fully implemented.                 |
    +------------------------------------------------------*/

   /*------------------------------------------------------+
    | Store AE Line elements in AE Lines temp table        |
    +------------------------------------------------------*/
    g_ae_line_ctr := g_ae_line_ctr +1;

    g_ae_line_tbl(g_ae_line_ctr).ae_line_type             :=  p_ae_line_rec.ae_line_type;
    g_ae_line_tbl(g_ae_line_ctr).ae_line_type_secondary   :=  p_ae_line_rec.ae_line_type_secondary;
    g_ae_line_tbl(g_ae_line_ctr).source_id                :=  p_ae_line_rec.source_id;
    g_ae_line_tbl(g_ae_line_ctr).source_table             :=  p_ae_line_rec.source_table;
    g_ae_line_tbl(g_ae_line_ctr).account                  :=  p_ae_line_rec.account;
    g_ae_line_tbl(g_ae_line_ctr).entered_dr               :=  p_ae_line_rec.entered_dr;
    g_ae_line_tbl(g_ae_line_ctr).entered_cr               :=  p_ae_line_rec.entered_cr;
    g_ae_line_tbl(g_ae_line_ctr).accounted_dr             :=  p_ae_line_rec.accounted_dr;
    g_ae_line_tbl(g_ae_line_ctr).accounted_cr             :=  p_ae_line_rec.accounted_cr;
    g_ae_line_tbl(g_ae_line_ctr).source_id_secondary      :=  p_ae_line_rec.source_id_secondary;
    g_ae_line_tbl(g_ae_line_ctr).source_table_secondary   :=  p_ae_line_rec.source_table_secondary;
    g_ae_line_tbl(g_ae_line_ctr).currency_code            :=  p_ae_line_rec.currency_code;
    g_ae_line_tbl(g_ae_line_ctr).currency_conversion_rate :=  p_ae_line_rec.currency_conversion_rate;
    g_ae_line_tbl(g_ae_line_ctr).currency_conversion_type :=  p_ae_line_rec.currency_conversion_type;
    g_ae_line_tbl(g_ae_line_ctr).currency_conversion_date :=  p_ae_line_rec.currency_conversion_date;
    g_ae_line_tbl(g_ae_line_ctr).third_party_id           :=  p_ae_line_rec.third_party_id;
    g_ae_line_tbl(g_ae_line_ctr).third_party_sub_id       :=  p_ae_line_rec.third_party_sub_id;
    g_ae_line_tbl(g_ae_line_ctr).tax_group_code_id        :=  p_ae_line_rec.tax_group_code_id;
    g_ae_line_tbl(g_ae_line_ctr).tax_code_id              :=  p_ae_line_rec.tax_code_id;
    g_ae_line_tbl(g_ae_line_ctr).location_segment_id      :=  p_ae_line_rec.location_segment_id;
    g_ae_line_tbl(g_ae_line_ctr).taxable_entered_dr       :=  p_ae_line_rec.taxable_entered_dr;
    g_ae_line_tbl(g_ae_line_ctr).taxable_entered_cr       :=  p_ae_line_rec.taxable_entered_cr;
    g_ae_line_tbl(g_ae_line_ctr).taxable_accounted_dr     :=  p_ae_line_rec.taxable_accounted_dr;
    g_ae_line_tbl(g_ae_line_ctr).taxable_accounted_cr     :=  p_ae_line_rec.taxable_accounted_cr;
    g_ae_line_tbl(g_ae_line_ctr).applied_from_doc_table   :=  p_ae_line_rec.applied_from_doc_table;
    g_ae_line_tbl(g_ae_line_ctr).applied_from_doc_id      :=  p_ae_line_rec.applied_from_doc_id;
    g_ae_line_tbl(g_ae_line_ctr).applied_to_doc_table     :=  p_ae_line_rec.applied_to_doc_table;
    g_ae_line_tbl(g_ae_line_ctr).applied_to_doc_id        :=  p_ae_line_rec.applied_to_doc_id;
    g_ae_line_tbl(g_ae_line_ctr).tax_link_id              :=  p_ae_line_rec.tax_link_id;
    g_ae_line_tbl(g_ae_line_ctr).reversed_source_id       :=  p_ae_line_rec.reversed_source_id;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_BR_ALLOC_WRAPPER_PKG.Assign_Ael_Elements()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_BR_ALLOC_WRAPPER_PKG.Assign_Ael_Elements');
     END IF;
     RAISE;

END Assign_Ael_Elements;

END ARP_BR_ALLOC_WRAPPER_PKG;

/
