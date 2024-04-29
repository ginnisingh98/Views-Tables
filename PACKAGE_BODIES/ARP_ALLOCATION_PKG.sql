--------------------------------------------------------
--  DDL for Package Body ARP_ALLOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ALLOCATION_PKG" AS
/* $Header: ARALLOCB.pls 120.76.12010000.20 2010/07/23 03:26:08 nemani ship $ */

/*=======================================================================+
 |  Global Constants
 +=======================================================================*/
  g_ae_doc_rec                  ae_doc_rec_type;
  g_ae_event_rec                ae_event_rec_type;
  g_ae_rule_rec                 ae_rule_rec_type;
  g_ae_sys_rec                  ae_sys_rec_type;
  g_ae_curr_rec                 ae_curr_rec_type;
  g_cust_inv_rec                ra_customer_trx%ROWTYPE;

  g_ae_summarize_tbl            ae_line_tbl_type;
  g_ae_empty_line_tbl           ae_line_tbl_type;
  g_ae_rev_ctr                  BINARY_INTEGER := 0; -- Count of revenue lines
  g_ae_tax_ctr                  BINARY_INTEGER := 0; -- Count of tax lines
  g_ae_unearn_rev_ctr           BINARY_INTEGER := 0; -- Count of unearn and unbilled lines
  g_ae_ctr                      BINARY_INTEGER := 0;
  g_ae_summ_ctr                 BINARY_INTEGER := 0;

  g_amount_due_remaining        NUMBER;
  g_acctd_amount_due_remaining  NUMBER;
  g_amount_due_original         NUMBER;
  g_orig_line_amt_alloc         NUMBER;
  g_orig_line_acctd_amt_alloc   NUMBER;
  g_sum_unearn_rev_amt          NUMBER;
  g_sum_unearn_rev_acctd_amt    NUMBER;

  g_ae_def_tax                  BOOLEAN;
  g_done_def_tax                BOOLEAN;
  g_bound_tax                   BOOLEAN;
  g_bound_freight               BOOLEAN;
  g_bound_activity              BOOLEAN;
  g_added_tax                   BOOLEAN;
  g_ovrrd_code                  VARCHAR2(1);
  g_id                          NUMBER := 0;
  g_ed_adj_activity_link        NUMBER := 0;
  g_uned_activity_link          NUMBER := 0;
  g_link_ctr                    NUMBER := 0;
  g_bulk_fetch_rows             NUMBER := 400;
  g_override1                   VARCHAR2(1);
  g_override2                   VARCHAR2(1);
  g_br_cust_trx_line_id         ra_customer_trx_lines.customer_trx_line_id%TYPE;
  g_simul_app                   VARCHAR2(1);
  g_ae_code_combination_id_app  NUMBER;

  g_exec                  VARCHAR2(30);
  g_receivables_trx_id    NUMBER;
  g_prim_det_dist_done    VARCHAR2(1) := 'N';

  g_adj_act_gl_acct_ccid    NUMBER := -9999;

/*==============================================================================+
 | Private Procedure/Function prototypes                                        |
 +==============================================================================*/
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  PROCEDURE adj_boundary_account (p_receivables_trx_id   IN     NUMBER,
                                  p_bucket               IN     VARCHAR2,
                                  p_ctlgd_id             IN     NUMBER,
                                  x_ccid                 IN OUT NOCOPY NUMBER);

  PROCEDURE Get_Tax_Curr(p_invoice_id          IN ra_customer_trx.customer_trx_id%TYPE,
                         p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE);

  PROCEDURE Get_Invoice_Distributions(p_invoice_id     IN NUMBER,
                                      p_app_rec        IN ar_receivable_applications%ROWTYPE,
                                      p_adj_rec        IN ar_adjustments%ROWTYPE,
                                      p_process_ed_adj IN VARCHAR2,
                                      p_process_uned   IN VARCHAR2,
                                      p_process_pay    IN VARCHAR2);

  PROCEDURE Override_Accounts(p_app_rec   IN  ar_receivable_applications%ROWTYPE,
                              p_adj_rec   IN  ar_adjustments%ROWTYPE,
                              p_override1 OUT NOCOPY  VARCHAR2,
                              p_override2 OUT NOCOPY VARCHAR2);

  PROCEDURE Check_Entry(p_invoice_id   IN  ra_customer_trx.customer_trx_id%TYPE,
                        p_app_rec      IN  ar_receivable_applications%ROWTYPE,
                        p_adj_rec      IN  ar_adjustments%ROWTYPE,
                        p_required     OUT NOCOPY BOOLEAN);

  PROCEDURE Get_Tax_Link_Id(p_process_ed_adj IN VARCHAR2,
                            p_process_uned   IN VARCHAR2,
                            p_process_pay    IN VARCHAR2);

  FUNCTION  Get_Acctd_Amt(p_amount       IN NUMBER ) RETURN NUMBER;

  PROCEDURE Process_Amounts(p_app_rec   IN ar_receivable_applications%ROWTYPE,
                            p_adj_rec   IN ar_adjustments%ROWTYPE);

  PROCEDURE Doc_Tax_Acct_Rule(p_type_acct IN VARCHAR2                           ,
                              p_app_rec   IN ar_receivable_applications%ROWTYPE ,
                              p_adj_rec   IN ar_adjustments%ROWTYPE              );

  PROCEDURE Init_Amts(p_type_acct    IN VARCHAR2                          ,
                      p_app_rec      IN ar_receivable_applications%ROWTYPE,
                      p_adj_rec      IN ar_adjustments%ROWTYPE             );

  PROCEDURE Gross_To_Activity_GL(p_type_acct      IN VARCHAR2);

  PROCEDURE Init_Rev_Tax_Tab;

  PROCEDURE Alloc_Rev_Tax_Amt(p_type_acct IN VARCHAR2);

  PROCEDURE Set_Taxable_Amt(p_type_acct IN VARCHAR2);

  PROCEDURE Set_Taxable_Split_Amt(p_type_acct IN VARCHAR2);

  PROCEDURE Allocate_Tax_To_Rev(p_type_acct   IN VARCHAR2);

  PROCEDURE Set_Rev_Links(p_type_acct         IN VARCHAR2);

  PROCEDURE Get_Rules(p_type_acct            IN     VARCHAR2,
                      p_gl_account_source    OUT NOCOPY   VARCHAR2,
                      p_tax_code_source      OUT NOCOPY   VARCHAR2,
                      p_tax_recoverable_flag OUT NOCOPY   VARCHAR2);

  PROCEDURE Build_Lines;  --(p_type_acct      IN VARCHAR2);

  PROCEDURE Build_Rev(p_gl_account_source     IN ar_receivables_trx.gl_account_source%TYPE     ,
                      p_tax_code_source       IN ar_receivables_trx.tax_code_source%TYPE       ,
                      p_tax_recoverable_flag  IN ar_receivables_trx.tax_recoverable_flag%TYPE  ,
                      p_ae_line_init_rec      IN ar_ae_alloc_rec_gt%ROWTYPE                       );

  PROCEDURE Build_Tax(p_tax_code_source       IN ar_receivables_trx.tax_code_source%TYPE       ,
                      p_tax_recoverable_flag  IN ar_receivables_trx.tax_recoverable_flag%TYPE  ,
                      p_ae_line_init_rec      IN ar_ae_alloc_rec_gt%ROWTYPE                       );

  PROCEDURE Build_Charges_Freight_All(p_type_acct         IN VARCHAR2          ,
                                      p_ae_line_init_rec  IN ar_ae_alloc_rec_gt%ROWTYPE,
                                      p_build_all         IN BOOLEAN );

  PROCEDURE Create_Debits_Credits(p_amount               IN NUMBER       ,
                                  p_acctd_amount         IN NUMBER       ,
                                  p_taxable_amount       IN NUMBER       ,
                                  p_taxable_acctd_amount IN NUMBER       ,
                                  p_from_amount          IN NUMBER       ,
                                  p_from_acctd_amount    IN NUMBER       ,
                                  p_ae_line_rec          IN OUT NOCOPY ar_ae_alloc_rec_gt%ROWTYPE,
                                  p_paired_flag          IN VARCHAR2 DEFAULT NULL,
                                  p_calling_point        IN VARCHAR2 DEFAULT NULL);


  PROCEDURE Summarize_Accounting_Lines;

  PROCEDURE Summarize_Acct_Lines_Hdr_Level;

  PROCEDURE Assign_Elements(p_ae_line_rec           IN ar_ae_alloc_rec_gt%ROWTYPE);

  PROCEDURE Insert_Ae_Lines(p_ae_line_tbl IN ar_ae_alloc_rec_gt%ROWTYPE);

  PROCEDURE Cache_Ae_Lines(p_ae_line_tbl IN ar_ae_alloc_rec_gt%ROWTYPE);

  PROCEDURE Dump_Alloc_Rev_Tax(p_type      IN VARCHAR2,
                               p_alloc_rec IN ar_ae_alloc_rec_gt%ROWTYPE);

  PROCEDURE Dump_Init_Amts(p_type_acct    IN VARCHAR2                            ,
                           p_app_rec      IN ar_receivable_applications%ROWTYPE  ,
                           p_adj_rec      IN ar_adjustments%ROWTYPE               );

  PROCEDURE Dump_Line_Amts(p_ae_line_rec  IN ar_ae_alloc_rec_gt%ROWTYPE);

  PROCEDURE Dump_Dist_Amts(p_ae_line_rec  ar_distributions%ROWTYPE);

  FUNCTION source_exec(p_process_ed_adj   IN VARCHAR2,
                       p_process_uned     IN VARCHAR2,
                       p_process_pay      IN VARCHAR2,
                       p_source_table     IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION source_exec(p_type_acct       IN VARCHAR2,
                       p_source_table    IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION the_tax_code_source(p_bucket   IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION the_tax_recoverable_flag(p_bucket   IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION the_gl_account_source(p_bucket   IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION get_adj_act_ccid RETURN NUMBER;

--BUG#5245153
FUNCTION get_adj_act_ccid RETURN NUMBER
IS
CURSOR c IS
SELECT CODE_COMBINATION_ID
  FROM ar_adjustments
 WHERE adjustment_id = g_ae_doc_rec.document_id;
BEGIN
  IF g_adj_act_gl_acct_ccid   = -9999 THEN
    IF g_ae_doc_rec.source_table = 'ADJ' THEN
    OPEN c;
    FETCH c INTO g_adj_act_gl_acct_ccid ;
    IF c%NOTFOUND THEN
     g_adj_act_gl_acct_ccid := -1;
    END IF;
    CLOSE c;
    END IF;
  END IF;
  RETURN g_adj_act_gl_acct_ccid;
END;

FUNCTION the_gl_account_source(p_bucket   IN VARCHAR2)
RETURN VARCHAR2
IS
    l_res    VARCHAR2(30);
BEGIN
    IF    p_bucket IN ('ADJ_LINE' ,'ADJ_TAX'  , 'ADJ_FRT'  , 'ADJ_CHRG') THEN
      l_res := g_ae_rule_rec.gl_account_source1;
    ELSIF p_bucket IN ('APP_LINE' ,'APP_TAX'  , 'APP_FRT'  , 'APP_CHRG') THEN
      l_res := 'ACTIVITY_GL_ACCOUNT';
    ELSIF p_bucket IN ('ED_LINE' ,'ED_TAX'  , 'ED_FRT'  , 'ED_CHRG') THEN
      l_res := g_ae_rule_rec.gl_account_source1;
    ELSIF p_bucket IN ('UNED_LINE' ,'UNED_TAX'  , 'UNED_FRT'  , 'UNED_CHRG') THEN
      l_res := g_ae_rule_rec.gl_account_source2;
    ELSE
      l_res :=  g_ae_rule_rec.tax_code_source1;
    END IF;
    arp_standard.debug(' the_gl_account_source for bucket '||p_bucket||' is '||l_res);
    RETURN l_res;
END;


FUNCTION the_tax_code_source
(p_bucket   IN VARCHAR2)
RETURN VARCHAR2
IS
  l_res     VARCHAR2(30);
BEGIN
  IF    p_bucket IN ('ADJ_LINE' ,'ADJ_TAX'  , 'ADJ_FRT'  , 'ADJ_CHRG') THEN
     l_res := g_ae_rule_rec.tax_code_source1;
  ELSIF p_bucket IN ('APP_LINE' ,'APP_TAX'  , 'APP_FRT'  , 'APP_CHRG') THEN
     l_res :=  'INVOICE';
  ELSIF p_bucket IN ('ED_LINE' ,'ED_TAX'  , 'ED_FRT'  , 'ED_CHRG') THEN
     l_res :=  g_ae_rule_rec.tax_code_source1;
  ELSIF p_bucket IN ('UNED_LINE' ,'UNED_TAX'  , 'UNED_FRT'  , 'UNED_CHRG') THEN
     l_res := g_ae_rule_rec.tax_code_source2;
  ELSE
     l_res :=  g_ae_rule_rec.tax_code_source1;
  END IF;
  arp_standard.debug(' the_tax_code_source for bucket '||p_bucket||' is '|| l_res);
  RETURN l_res;
END;

FUNCTION the_tax_recoverable_flag
(p_bucket   IN VARCHAR2)
RETURN VARCHAR2
IS
  l_res    VARCHAR2(30);
BEGIN
 IF p_bucket IN ('ADJ_LINE','ADJ_TAX'  ,'ADJ_FRT'  , 'ADJ_CHRG' ) THEN
    l_res :=  g_ae_rule_rec.tax_recoverable_flag1;
 ELSIF p_bucket IN ('APP_LINE','APP_TAX'  ,'APP_FRT'  , 'APP_CHRG' ) THEN
     l_res := 'Y';
 ELSIF p_bucket IN ('ED_LINE','ED_TAX'  ,'ED_FRT'  , 'ED_CHRG' ) THEN
     l_res := g_ae_rule_rec.tax_recoverable_flag1;
 ELSIF p_bucket IN ('UNED_LINE','UNED_TAX' ,'UNED_FRT' ,'UNED_CHRG') THEN
     l_res := g_ae_rule_rec.tax_recoverable_flag2;
 ELSE
     l_res := g_ae_rule_rec.tax_recoverable_flag1;
 END IF;
 arp_standard.debug(' the_tax_recoverable_flag for bucket '||p_bucket||' is '|| l_res);
 RETURN l_res;
END;

FUNCTION source_exec
(p_process_ed_adj   IN VARCHAR2,
 p_process_uned     IN VARCHAR2,
 p_process_pay      IN VARCHAR2,
 p_source_table     IN VARCHAR2)
RETURN VARCHAR2
IS
  l_source_exec  VARCHAR2(30);
BEGIN
  l_source_exec := NULL;
  arp_standard.debug('source_exec +');
  arp_standard.debug('  p_process_ed_adj :'||p_process_ed_adj);
  arp_standard.debug('  p_process_uned   :'||p_process_uned  );
  arp_standard.debug('  p_process_pay    :'||p_process_pay  );
  arp_standard.debug('  p_source_table   :'||p_source_table  );
  IF    p_process_ed_adj = 'Y' AND p_source_table = 'ADJ' THEN
    l_source_exec := 'ADJ';
  ELSIF p_process_ed_adj = 'Y' AND p_source_table = 'RA' THEN
    l_source_exec := 'ED';
  ELSIF p_process_uned = 'Y' AND p_source_table = 'RA' THEN
    l_source_exec := 'UNED';
  ELSIF p_process_pay  = 'Y' AND p_source_table = 'RA' THEN
    l_source_exec := 'PAY';
  END IF;
  arp_standard.debug('  l_source_exec :'||l_source_exec);
  arp_standard.debug('source_exec -');
  RETURN l_source_exec;
END;


FUNCTION source_exec
(p_type_acct       IN VARCHAR2,
 p_source_table     IN VARCHAR2)
RETURN VARCHAR2
IS
  l_source_exec  VARCHAR2(30);
  l_process_ed_adj  VARCHAR2(1) := 'N';
  l_process_uned    VARCHAR2(1) := 'N';
  l_process_pay     VARCHAR2(1) := 'N';
BEGIN
  l_source_exec := NULL;
  arp_standard.debug('source_exec +');
  arp_standard.debug('  p_type_acct      :'||p_type_acct);
  arp_standard.debug('  p_source_table   :'||p_source_table  );
  IF     p_type_acct = 'ED_ADJ' THEN
     l_process_ed_adj := 'Y';
  ELSIF  p_type_acct = 'UNED' THEN
     l_process_uned   := 'Y';
  ELSIF  p_type_acct = 'PAY' THEN
     l_process_pay    := 'Y';
  END IF;
  l_source_exec := source_exec(p_process_ed_adj   => l_process_ed_Adj,
                               p_process_uned     => l_process_uned,
                               p_process_pay      => l_process_pay,
                               p_source_table     => p_source_table);

  arp_standard.debug('  l_source_exec :'||l_source_exec);
  arp_standard.debug('source_exec -');
  RETURN l_source_exec;
END;

/* =======================================================================
 | PROCEDURE Allocate_Tax
 |
 | DESCRIPTION
 |      This procedure is the cover routine which will tax account for
 |      discounts, adjustments and finance charges. The rule details
 |      and document, event details are passed to this procedure which will
 |      help determine the manner in which discounts and adjustments are
 |      allocated over specific accounts based on Activity Rule.
 |
 | PARAMETERS
 |      p_ae_doc_rec            IN      Document record
 |      p_ae_event_rec          IN      Event record
 |      p_app_rec               IN      Application record for discounts
 |      p_adj_rec               IN      Adjustment record for adjustments
 |      p_ae_rule_rec           IN      Rule record
 |      p_ae_line_tbl           OUT     Table with accounting for discounts
 |                                      or adjustments
 * ======================================================================*/
PROCEDURE Allocate_Tax (
                  p_ae_doc_rec    IN      ae_doc_rec_type,
                  p_ae_event_rec  IN      ae_event_rec_type,
                  p_ae_rule_rec   IN      ae_rule_rec_type,
                  p_app_rec       IN      ar_receivable_applications%ROWTYPE,
                  p_cust_inv_rec  IN      ra_customer_trx%ROWTYPE,
                  p_adj_rec       IN      ar_adjustments%ROWTYPE,
                  p_ae_ctr        IN OUT NOCOPY  BINARY_INTEGER,
                  p_ae_line_tbl   IN OUT NOCOPY  ae_line_tbl_type,
                  p_br_cust_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE default NULL,
                  p_simul_app      IN     VARCHAR2 default NULL,
                  p_from_llca_call IN     VARCHAR2 DEFAULT 'N',
                  p_gt_id          IN     NUMBER   DEFAULT NULL,
                  -- this flag is introduced to indicate if the application need conversion
                  p_inv_cm         IN     VARCHAR2 DEFAULT 'I'
                    ) IS

l_invoice_id          ra_customer_trx.customer_trx_id%TYPE          ;
l_payment_schedule_id ar_payment_schedules.payment_schedule_id%TYPE ;
l_ed_adj_acct   VARCHAR2(10)   := 0;
l_uned_acct     VARCHAR2(10)   := 0;
l_linked_tax    BOOLEAN        := FALSE;
l_required      BOOLEAN        := TRUE;
l_rev_rec_req   BOOLEAN        := TRUE;
l_sum_dist      NUMBER;
l_gl_account_source_old     ar_receivables_trx.gl_account_source%TYPE;
l_tax_code_source_old       ar_receivables_trx.tax_code_source%TYPE;
l_tax_recoverable_flag_old  ar_receivables_trx.tax_recoverable_flag%TYPE;
l_process_ed_adj  VARCHAR2(1) := 'N';
l_process_uned    VARCHAR2(1) := 'N';
l_process_pay     VARCHAR2(1) := 'N';
l_le_id           NUMBER;
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(1024);
l_effective_date  DATE;
l_return_status   VARCHAR2(10);
--{
l_line_adj          VARCHAR2(50);
l_tax_adj           VARCHAR2(50);
l_frt_adj           VARCHAR2(50);
l_chrg_adj          VARCHAR2(50);
l_cm_app            VARCHAR2(1) := 'N';
l_gt_id             NUMBER;
l_cnt               NUMBER;
l_type              VARCHAR2(30);
--}
What_kind_of_activity   EXCEPTION;
impossible_adjust       EXCEPTION;
BEGIN
--  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_ALLOCATION_PKG.Allocate_Tax()+');
--  END IF;

/*----------------------------------------------------------------------------+
 | Assign globals and get system options info                                 |
 +----------------------------------------------------------------------------*/
  g_ae_doc_rec                   := p_ae_doc_rec        ;
  g_ae_event_rec                 := p_ae_event_rec      ;
  g_ae_rule_rec                  := p_ae_rule_rec       ;

  g_cust_inv_rec                 := p_cust_inv_rec      ;

  g_ae_sys_rec.set_of_books_id   := ARP_ACCT_MAIN.ae_sys_rec.set_of_books_id;
  g_ae_sys_rec.gain_cc_id        := ARP_ACCT_MAIN.ae_sys_rec.gain_cc_id;
  g_ae_sys_rec.loss_cc_id        := ARP_ACCT_MAIN.ae_sys_rec.loss_cc_id;
  g_ae_sys_rec.round_cc_id       := ARP_ACCT_MAIN.ae_sys_rec.round_cc_id;
  g_ae_sys_rec.coa_id            := ARP_ACCT_MAIN.ae_sys_rec.coa_id;
  g_ae_sys_rec.base_currency     := ARP_ACCT_MAIN.ae_sys_rec.base_currency;
  g_ae_sys_rec.base_precision    := ARP_ACCT_MAIN.ae_sys_rec.base_precision;
  g_ae_sys_rec.base_min_acc_unit := ARP_ACCT_MAIN.ae_sys_rec.base_min_acc_unit;

  -- MRC TRIGGER replacement
  -- Initialize a new global variable:
  g_ae_sys_rec.sob_type          := NVL(ARP_ACCT_MAIN.ae_sys_rec.sob_type,'P');

  g_ae_code_combination_id_app := p_app_rec.code_combination_id;
  g_ae_rev_ctr         := 0;
  g_ae_tax_ctr         := 0;
  g_ae_unearn_rev_ctr  := 0;
  g_ae_ctr             := 0;
  g_ae_summ_ctr        := 0;
  g_ae_summarize_tbl   := g_ae_empty_line_tbl ;

  g_amount_due_remaining       := 0;
  g_acctd_amount_due_remaining := 0;
  g_amount_due_original        := 0;

  g_sum_unearn_rev_amt         := 0;
  g_sum_unearn_rev_acctd_amt   := 0;

  g_ae_def_tax           := FALSE;
  g_done_def_tax         := FALSE;
  g_bound_tax            := FALSE;
  g_bound_freight        := FALSE;
  g_bound_activity       := FALSE;
  g_added_tax            := FALSE;
  g_ovrrd_code           := '';

--  ER :  LIne Level adjustment API- Changed the p_gt_id check , Placed the NVL

  IF NVL(p_gt_id,0) = 0  THEN
    SELECT ar_distribution_split_s.NEXTVAL INTO g_id FROM DUAL;
  ELSE
    g_id                   := p_gt_id;
  END IF;
  arp_standard.debug(' p_gt_id  :'||p_gt_id);
  arp_standard.debug(' g_id     :'||g_id);
  --}
  g_ed_adj_activity_link := 0;
  g_uned_activity_link   := 0;
  g_link_ctr             := 0;
  adj_code_combination_id := '';
  g_override1            := '';
  g_override2            := '';

--set the BR cust trx line id i.e. line id of assignment on BR document
  IF p_br_cust_trx_line_id IS NOT NULL THEN
    g_br_cust_trx_line_id := p_br_cust_trx_line_id;

  ELSE

    g_br_cust_trx_line_id := NULL;
  END IF;

--set the Simulation flag
  IF p_simul_app IS NOT NULL AND p_simul_app = 'Y' THEN
    g_simul_app  := p_simul_app;

  ELSE
    g_simul_app  := NULL;

  END IF;

  arp_standard.debug('g_ae_doc_rec+');
  arp_standard.debug(' g_ae_doc_rec.document_type:'||g_ae_doc_rec.document_type);
  arp_standard.debug(' g_ae_doc_rec.document_id  :'||g_ae_doc_rec.document_id);
  arp_standard.debug(' g_ae_doc_rec.accounting_entity_level:'||g_ae_doc_rec.accounting_entity_level);
  arp_standard.debug(' g_ae_doc_rec.source_table:  '||g_ae_doc_rec.source_table);
  arp_standard.debug(' g_ae_doc_rec.source_id:     '||g_ae_doc_rec.source_id);
  arp_standard.debug(' g_ae_doc_rec.source_id_old: '||g_ae_doc_rec.source_id_old);
  arp_standard.debug(' g_ae_doc_rec.other_flag:    '||g_ae_doc_rec.other_flag);
  arp_standard.debug(' g_ae_doc_rec.miscel1:       '||g_ae_doc_rec.miscel1);
  arp_standard.debug(' g_ae_doc_rec.event:         '||g_ae_doc_rec.event);
  arp_standard.debug(' g_ae_doc_rec.deferred_tax:  '||g_ae_doc_rec.deferred_tax);
  arp_standard.debug(' g_ae_doc_rec.pay_sched_upd_yn:'||g_ae_doc_rec.pay_sched_upd_yn);
  arp_standard.debug(' g_ae_doc_rec.pay_sched_upd_cm_yn:'||g_ae_doc_rec.pay_sched_upd_cm_yn);
  arp_standard.debug(' g_ae_doc_rec.override_source_type:'||g_ae_doc_rec.override_source_type);
  arp_standard.debug(' g_ae_doc_rec.gl_tax_acct:   '||g_ae_doc_rec.gl_tax_acct);
  arp_standard.debug(' g_ae_doc_rec.inv_cm_app_mode:'||g_ae_doc_rec.inv_cm_app_mode);
  arp_standard.debug('g_ae_doc_rec-');

  arp_standard.debug('g_ae_rule_rec+');
  arp_standard.debug(' g_ae_rule_rec.gl_account_source1 :'||g_ae_rule_rec.gl_account_source1);
  arp_standard.debug(' g_ae_rule_rec.tax_code_source1   :'||g_ae_rule_rec.tax_code_source1);
  arp_standard.debug(' g_ae_rule_rec.tax_recoverable_flag1  :'||g_ae_rule_rec.tax_recoverable_flag1);
  arp_standard.debug(' g_ae_rule_rec.code_combination_id1   :'||g_ae_rule_rec.code_combination_id1);
  arp_standard.debug(' g_ae_rule_rec.asset_tax_code1        :'||g_ae_rule_rec.asset_tax_code1);
  arp_standard.debug(' g_ae_rule_rec.liability_tax_code1    :'||g_ae_rule_rec.liability_tax_code1);
  arp_standard.debug(' g_ae_rule_rec.act_tax_non_rec_ccid1  :'||g_ae_rule_rec.act_tax_non_rec_ccid1);
  arp_standard.debug(' g_ae_rule_rec.act_vat_tax_id1        :'||g_ae_rule_rec.act_vat_tax_id1);
  arp_standard.debug(' g_ae_rule_rec.gl_account_source2 :'||g_ae_rule_rec.gl_account_source2);
  arp_standard.debug(' g_ae_rule_rec.tax_code_source2   :'||g_ae_rule_rec.tax_code_source2);
  arp_standard.debug(' g_ae_rule_rec.tax_recoverable_flag2  :'||g_ae_rule_rec.tax_recoverable_flag2);
  arp_standard.debug(' g_ae_rule_rec.code_combination_id2   :'||g_ae_rule_rec.code_combination_id2);
  arp_standard.debug(' g_ae_rule_rec.asset_tax_code2        :'||g_ae_rule_rec.asset_tax_code2);
  arp_standard.debug(' g_ae_rule_rec.liability_tax_code2    :'||g_ae_rule_rec.liability_tax_code2);
  arp_standard.debug(' g_ae_rule_rec.act_tax_non_rec_ccid2  :'||g_ae_rule_rec.act_tax_non_rec_ccid2);
  arp_standard.debug(' g_ae_rule_rec.act_vat_tax_id2        :'||g_ae_rule_rec.act_vat_tax_id2);
  arp_standard.debug('g_ae_rule_rec-');

  arp_standard.debug('g_ae_event_rec+');
  arp_standard.debug(' g_ae_event_rec.event_type     :'||g_ae_event_rec.event_type);
  arp_standard.debug(' g_ae_event_rec.event_id       :'||g_ae_event_rec.event_id);
  arp_standard.debug(' g_ae_event_rec.event_date     :'||g_ae_event_rec.event_date);
  arp_standard.debug(' g_ae_event_rec.event_status   :'||g_ae_event_rec.event_status);
  arp_standard.debug('g_ae_event_rec-');



/*----------------------------------------------------------------------------+
 | Get Invoice for which Tax accounting is required based on Rules            |
 +----------------------------------------------------------------------------*/
   IF g_ae_doc_rec.source_table = 'RA' THEN
      l_invoice_id          := p_app_rec.applied_customer_trx_id;
      l_payment_schedule_id := p_app_rec.applied_payment_schedule_id;

      --{CMAPP
      IF p_app_rec.applied_customer_trx_id = p_app_rec.customer_trx_id THEN
         l_cm_app := 'Y';
      END IF;
      --}
   ELSE
      l_invoice_id  := p_adj_rec.customer_trx_id;
      l_payment_schedule_id := p_adj_rec.payment_schedule_id;
   END IF;

/* Initialize zx */
   SELECT legal_entity_id
   INTO   l_le_id
   FROM   ra_customer_trx
   WHERE  customer_trx_id = l_invoice_id;

   zx_api_pub.set_tax_security_context(
           p_api_version      => 1.0,
           p_init_msg_list    => 'T',
           p_commit           => 'F',
           p_validation_level => NULL,
           x_return_status    => l_return_status,
           x_msg_count        => l_msg_count,
           x_msg_data         => l_msg_data,
           p_internal_org_id  => arp_standard.sysparm.org_id,
           p_legal_entity_id  => l_le_id,
           p_transaction_date => nvl(p_app_rec.apply_date,
                                     p_adj_rec.apply_date),
           p_related_doc_date => NULL,
           p_adjusted_doc_date=> NULL,
           x_effective_date   => l_effective_date);

/*----------------------------------------------------------------------------+
 | Check whether processing is really required if not then exit               |
 |                                                                            |
 | No need to make changes to this procedure as all checking will be done     |
 | based on primary data.  If revenue recognition has not been run on first   |
 | iteration, it will be complete by end of first iteration and before        |
 | second iteration.                                                          |
 +----------------------------------------------------------------------------*/
  IF nvl(g_cust_inv_rec.upgrade_method,'NONE') = 'R12_MERGE' AND
    g_ae_doc_rec.source_table IN ('RA','ADJ') THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Upgrade method is R12_MERGE,check whether further processing is needed');
    END IF;

    Check_Entry(p_invoice_id     => l_invoice_id    ,
	       p_app_rec        => p_app_rec       ,
	       p_adj_rec        => p_adj_rec       ,
	       p_required       => l_required    );

    IF NOT l_required THEN            --processing not required
      IF PG_DEBUG in ('Y', 'C') THEN
	arp_standard.debug('Check_Entry return value false,avoidng call to detailed accting engine.');
      END IF;

      GOTO end_process_lbl;
    END IF;
  END IF;

  IF NVL(g_ae_sys_rec.sob_type,'P') = 'P' THEN

   --  ER :  LIne Level adjustment API- Changed the p_gt_id check , Placed the NVL

    IF  (p_from_llca_call = 'N'  AND NVL(p_gt_id,0) = 0 ) THEN

      l_gt_id  := g_id;

      IF (    (p_app_rec.receivable_application_id IS NOT NULL)
          AND (p_adj_rec.adjustment_id             IS NOT NULL))
      THEN
         arp_standard.debug('Problem is this a application or adjustment allocation ?');
         arp_standard.debug(' Both receivable_application_id :' ||p_app_rec.receivable_application_id);
         arp_standard.debug(' and adjustment_id_id           :' ||p_adj_rec.adjustment_id);
         arp_standard.debug(' are not null');
         RAISE What_kind_of_activity;
      ELSIF (p_app_rec.receivable_application_id IS NOT NULL) OR
            (p_app_rec.receivable_application_id IS NULL       AND
			 p_app_rec.applied_customer_trx_id   IS NOT NULL   AND
			 p_app_rec.applied_payment_schedule_id IS NOT NULL AND
			 (NVL(p_app_rec.amount_applied,0)             <> 0 OR
              NVL(p_app_rec.acctd_amount_applied_to,0)    <> 0 OR
              NVL(p_app_rec.line_applied,0)               <> 0 OR
              NVL(p_app_rec.tax_applied,0)                <> 0 OR
              NVL(p_app_rec.freight_applied,0)            <> 0 OR
              NVL(p_app_rec.receivables_charges_applied,0)<> 0 ))
      THEN
         IF p_inv_cm = 'C' THEN
           g_cust_inv_rec.customer_trx_id := p_app_rec.customer_trx_id;
         ELSE
           g_cust_inv_rec.customer_trx_id := p_app_rec.applied_customer_trx_id;
         END IF;

         ARP_DET_DIST_PKG.exec_revrec_if_required
          ( p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
            p_app_rec          => p_app_rec,
            p_adj_rec          => p_adj_rec);

         ARP_DET_DIST_PKG.exec_adj_api_if_required
           (p_adj_rec          => p_adj_rec,
            p_app_rec          => p_app_rec,
            p_ae_rule_rec      => g_ae_rule_rec,
            p_cust_inv_rec     => g_Cust_inv_rec);

         ARP_DET_DIST_PKG.set_original_rem_amt
           (p_customer_trx  => g_cust_inv_rec,
		    p_adj_id        => p_adj_rec.adjustment_id,
			p_app_id        => p_app_rec.receivable_application_id);

         ARP_DET_DIST_PKG.Trx_level_direct_cash_apply
           (p_customer_trx     => g_cust_inv_rec,
            p_app_rec          => p_app_rec,
            p_ae_sys_rec       => g_ae_sys_rec,
            p_gt_id            => l_gt_id,
            p_inv_cm           => p_inv_cm);

      ELSIF (p_adj_rec.adjustment_id IS NOT NULL)
      THEN
         g_Cust_inv_rec.customer_trx_id := p_adj_rec.customer_trx_id;
         g_receivables_trx_id           := p_adj_rec.receivables_trx_id;

         ARP_DET_DIST_PKG.exec_revrec_if_required
          ( p_customer_trx_id  => p_adj_rec.customer_trx_id,
            p_app_rec          => p_app_rec,
            p_adj_rec          => p_adj_rec);

         ARP_DET_DIST_PKG.exec_adj_api_if_required
           (p_adj_rec          => p_adj_rec,
            p_app_rec          => p_app_rec,
            p_ae_rule_rec      => g_ae_rule_rec,
            p_cust_inv_rec     => g_Cust_inv_rec);

         ARP_DET_DIST_PKG.set_original_rem_amt
           (p_customer_trx  => g_cust_inv_rec,
		    p_adj_id        => p_adj_rec.adjustment_id,
			p_app_id        => p_app_rec.receivable_application_id);


         ARP_DET_DIST_PKG.possible_adjust
           (p_adj_rec           => p_adj_rec,
            p_ae_rule_rec       => g_ae_rule_rec,
            p_customer_trx_id   => g_cust_inv_rec.customer_trx_id,
            x_return_status     => l_return_status,
            x_line_adj          => l_line_adj,
            x_tax_adj           => l_tax_adj,
            x_frt_adj           => l_frt_adj,
            x_chrg_adj          => l_chrg_adj,
            p_app_rec           => p_app_rec);

         arp_standard.debug('  x_line_adj :'||l_line_adj);
         arp_standard.debug('  x_tax_adj  :'||l_tax_adj);
         arp_standard.debug('  x_frt_adj  :'||l_frt_adj);
         arp_standard.debug('  x_chrg_adj :'||l_chrg_adj);
         arp_standard.debug('  l_return_status :'||l_return_status);

         IF   l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE impossible_adjust;
         END IF;

         ARP_DET_DIST_PKG.Trx_level_direct_adjust
           (p_customer_trx     => g_cust_inv_rec,
            p_adj_rec          => p_adj_rec,
            p_ae_sys_rec       => g_ae_sys_rec,
            p_gt_id            => l_gt_id);

      ELSIF (    (p_adj_rec.adjustment_id IS NULL)
             AND (p_app_rec.receivable_application_id IS NULL)
	     AND (NVL(g_simul_app,'N') = 'N')) -- added to avoid check for simulation [bug 8464438]
      THEN
         arp_standard.debug('Problem is this a application or adjustment allocation ?');
         arp_standard.debug(' Both receivable_application_id  and adjustment_id_id  are null');
         RAISE What_kind_of_activity;
      END IF;
      g_prim_det_dist_done := 'Y';

    ELSE

      l_gt_id := p_gt_id;
      g_prim_det_dist_done := 'Y';

    END IF;

  END IF;
--}

/*----------------------------------------------------------------------------+
 | Get tax rounding rules and currency details                                |
 +----------------------------------------------------------------------------*/
   arp_standard.debug(' HYU calling Get_Tax_Curr');
   --{CMAPP
   IF l_cm_app <> 'Y' THEN
     Get_Tax_Curr(p_invoice_id          => l_invoice_id,
                  p_payment_schedule_id => l_payment_schedule_id);
   END IF;

/*----------------------------------------------------------------------------+
 | Set the flags for processinf discounts, adjustments and payments           |
 +----------------------------------------------------------------------------*/
   IF (((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.earned_discount_taken,0) <> 0))
       OR ((g_ae_doc_rec.source_table = 'ADJ') AND (nvl(p_adj_rec.amount,0) <> 0))) THEN
       l_process_ed_adj := 'Y';
   END IF;

   IF ((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.unearned_discount_taken,0) <> 0)) THEN
      l_process_uned := 'Y';
   END IF;

   IF (   --def_tax? (g_ae_def_tax) AND (NOT g_done_def_tax) AND
           (g_ae_doc_rec.source_table = 'RA')
       AND (nvl(p_app_rec.amount_applied,0) <> 0)) THEN
       l_process_pay := 'Y';
   END IF;

   arp_standard.debug(' l_process_ed_adj:'||l_process_ed_adj);
   arp_standard.debug(' l_process_uned:'||l_process_uned);
   arp_standard.debug(' l_process_pay:'||l_process_pay);

/*----------------------------------------------------------------------------+
 | Get Invoice Revenue and Tax distributions for Non Rule Invoice             |
 +----------------------------------------------------------------------------*/
   arp_standard.debug(' Calling Get_Invoice_Distributions');


   Get_Invoice_Distributions(p_invoice_id     => l_invoice_id     ,
                             p_app_rec        => p_app_rec        ,
                             p_adj_rec        => p_adj_rec        ,
                             p_process_ed_adj => l_process_ed_adj ,
                             p_process_uned   => l_process_uned   ,
                             p_process_pay    => l_process_pay      );
   --GOTO end_process_lbl;

/*----------------------------------------------------------------------------+
 | Set tax link ids for Invoices Tax distributions (lines), call this routine |
 | only if tax really needs to be linked otherwise the link id is null. Now it|
 | is important to call the Get_Tax_Link_Id routine based on earned or unearn |
 | discount because ther rules can be different and if one has the rule       |
 | ACTIVITY then the link basis becomes different as it is off the activity   |
 | tax code. So this condition. Process for earned discounts, adjustments     |
 +----------------------------------------------------------------------------*/
--    IF l_process_ed_adj = 'Y' THEN
--     g_exec := NULL;
--     g_exec := source_exec(p_type_acct    => 'ED_ADJ',
 --                          p_source_table =>  g_ae_doc_rec.source_table);
--}
     /*----------------------------------------------------------------------------+
      | Process for Earned discounts                                               |
      +----------------------------------------------------------------------------*/
        Process_Amounts(p_app_rec   => p_app_rec   ,
                        p_adj_rec   => p_adj_rec    );

--     END IF;

  /*----------------------------------------------------------------------------+
   | Set tax link ids for Unearned discounts and link, override revenue using   |
   | rules on unearned discount activity.                                       |
   +----------------------------------------------------------------------------*/
--     IF l_process_uned = 'Y' THEN
--     g_exec := NULL;
--     g_exec := source_exec(p_type_acct    => 'UNED',
--                           p_source_table =>  g_ae_doc_rec.source_table);
--}
     /*------------------------------------------------------------------------------+
      | Initialise Revenue table to reuse cells for allocating line amounts          |
      +------------------------------------------------------------------------------*/
-- we should initializing the amount in ar_ae_alloc_rec_gt        Init_Rev_Tax_Tab;

     /*----------------------------------------------------------------------------+
      | Process for Unearned discounts                                             |
      +----------------------------------------------------------------------------*/
--        Process_Amounts(p_app_rec   => p_app_rec,
--                        p_adj_rec   => p_adj_rec  );

--     END IF; --end if unearned discounts

  /*----------------------------------------------------------------------------+
   | Set tax link ids for Payment, in this case we default the rule to revenue  |
   | on invoice, tax code on invoice recoverable and process for deferred tax   |
   +----------------------------------------------------------------------------*/
--    IF l_process_pay = 'Y' THEN
   /*----------------------------------------------------------------------------+
    | Since processing for discounts is complete, force set the rules below so   |
    | that we may process for payments and use a link basis between tax and      |
    | revenue and calculate deferred taxable using payment non tax amount        |
    +----------------------------------------------------------------------------*/
--      g_ae_rule_rec.gl_account_source1    := 'ACTIVITY_GL_ACCOUNT';
--      g_ae_rule_rec.tax_code_source1      := 'INVOICE';
--      g_ae_rule_rec.tax_recoverable_flag1 := 'Y';
--      g_ae_rule_rec.code_combination_id1  :=  g_ae_rule_rec.receivable_account;
--}
     /*------------------------------------------------------------------------------+
      | Initialise Revenue table to reuse cells for allocating line amounts          |
      +------------------------------------------------------------------------------*/
-- we should initializing the amount in ar_ae_alloc_rec_gt        Init_Rev_Tax_Tab;
--     g_exec := NULL;
--     g_exec := source_exec(p_type_acct    => 'PAY',
--                           p_source_table =>  g_ae_doc_rec.source_table);
--}
     /*------------------------------------------------------------------------+
      | Process for  deferred tax for Payments                                 |
      +------------------------------------------------------------------------*/
--        Process_Amounts(p_type_acct => 'PAY'       ,
--                        p_app_rec   => p_app_rec   ,
--                        p_adj_rec   => p_adj_rec    );
--     END IF; --end if payments

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'upgrade method '||g_cust_inv_rec.upgrade_method);
   END IF;

 /*----------------------------------------------------------------------------+
  | Summarize built accounting lines for revenue and tax to net out accounting |
  +----------------------------------------------------------------------------*/
   IF nvl(g_cust_inv_rec.upgrade_method,'NONE') = 'R12_MERGE' AND
      g_ae_doc_rec.source_table IN ('RA','ADJ') THEN
     Summarize_Acct_Lines_Hdr_Level;
   ELSE
     Summarize_Accounting_Lines;

     IF g_ae_doc_rec.inv_cm_app_mode = 'C' THEN
      arp_standard.debug('Updating CM ard to stamp ref_prev_cust_trx_line_id');

      update ar_distributions ard
      set ref_prev_cust_trx_line_id = (select previous_customer_trx_line_id
                                       from ra_customer_trx_lines
                                       where customer_trx_line_id = ard.ref_customer_trx_line_id)
      where source_id = g_ae_doc_rec.source_id
      and source_table = 'RA'
      and ref_customer_trx_line_id in (select customer_trx_line_id
                                       from ra_customer_trx_lines ctl_cm,
                                            ar_receivable_applications ra
                                       where ra.receivable_application_id = g_ae_doc_rec.source_id
                                       and ra.customer_trx_id = ctl_cm.customer_trx_id
                                       and ctl_cm.previous_customer_trx_line_id is not null);

      l_cnt := sql%rowcount;

      arp_standard.debug('CM ard rows updated : '||l_cnt);

      IF l_cnt > 0 THEN
       arp_standard.debug('Updating INV ard to stamp ref_prev_cust_trx_line_id');

       update ar_distributions ard
       set ref_prev_cust_trx_line_id = (select ref_customer_trx_line_id
                                        from ar_distributions
                                        where source_id = g_ae_doc_rec.source_id
                                        and ref_prev_cust_trx_line_id = ard.ref_customer_trx_line_id
                                        and rownum = 1)
       where source_id = g_ae_doc_rec.source_id
       and source_table = 'RA'
       and ref_customer_trx_line_id in (select customer_trx_line_id
                                        from ra_customer_trx_lines ctl_inv,
                                             ar_receivable_applications ra
                                        where ra.receivable_application_id = g_ae_doc_rec.source_id
                                        and ra.applied_customer_trx_id = ctl_inv.customer_trx_id);
       l_cnt := sql%rowcount;

       arp_standard.debug('INV ard rows updated : '||l_cnt);
      END IF;
     END IF;
   END IF;

 /*---------------------------------------------------------------------------------+
  | Assign summarized lines to the the in out table to pass back to calling rountine|
  +---------------------------------------------------------------------------------*/

   IF nvl(g_simul_app,'N') = 'Y' THEN

      IF g_ae_summarize_tbl.EXISTS(g_ae_summ_ctr) THEN

         p_ae_line_tbl := g_ae_summarize_tbl;
         p_ae_ctr      := g_ae_summ_ctr;

      END IF;

   END IF;


 /*---------------------------------------------------------------------------------+
  | Clean up the Global temporary tables.                                           |
  +---------------------------------------------------------------------------------*/
    --not required since in cases like mass applications g_id will increment

   g_br_cust_trx_line_id := NULL;
   g_simul_app  := NULL;
   g_adj_act_gl_acct_ccid := -9999;

<<end_process_lbl>>
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_ALLOCATION_PKG.Allocate_Tax()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ARP_ALLOCATION_PKG.Allocate_Tax - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN What_kind_of_activity THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ALLOCATION_PKG.Allocate_Tax - What_kind_of_activity');
     END IF;
     RAISE;

  WHEN impossible_adjust THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ALLOCATION_PKG.Allocate_Tax - impossible_adjust');
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ALLOCATION_PKG.Allocate_Tax:'||SQLERRM);
     END IF;
     RAISE;

END Allocate_Tax;

/* =======================================================================
 | PROCEDURE Check_Entry
 |
 | DESCRIPTION
 |      This routine checks whether Tax accounting processing is really
 |      required and whether revenue recognition needs to be run.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_invoice_id            IN      Invoice identifier
 |      p_app_rec               IN      Applications record
 |      p_adj_rec               IN      Adjustment record
 |      p_required              OUT     Flag indicates whether tax processing
 |                                      is required
 * ======================================================================*/
PROCEDURE Check_Entry(p_invoice_id  IN  ra_customer_trx.customer_trx_id%TYPE,
                      p_app_rec     IN  ar_receivable_applications%ROWTYPE,
                      p_adj_rec     IN  ar_adjustments%ROWTYPE,
                      p_required    OUT NOCOPY BOOLEAN) IS

l_dummy       NUMBER;
l_ae_def_tax  BOOLEAN := FALSE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(   'ARP_ALLOCATION_PKG.Check_Entry()+');
  END IF;

  --Is tax deferred
  BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'ARP_ALLOCATION_PKG.Check_Entry - Checking for deferred tax');
    END IF;

    select gld.customer_trx_id
    into l_dummy
    from  ra_cust_trx_line_gl_dist gld
    where gld.account_class = 'TAX'
    and   gld.customer_trx_id = p_invoice_id
    and   gld.collected_tax_ccid IS NOT NULL
    group by gld.customer_trx_id;

    l_ae_def_tax := TRUE; --Atleast one deferred tax line exists

    IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'ARP_ALLOCATION_PKG.Check_Entry - DEFERRED TAX');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  'ARP_ALLOCATION_PKG.Check_Entry - NO DEFERRED TAX');
      END IF;
      l_ae_def_tax := FALSE; --Tax is not deferred
  END;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(' g_ae_doc_rec.source_table:'||g_ae_doc_rec.source_table);
    arp_standard.debug(' p_app_rec.earned_discount_taken:'||p_app_rec.earned_discount_taken);
    arp_standard.debug(' p_app_rec.unearned_discount_taken:'||p_app_rec.unearned_discount_taken);
    arp_standard.debug(' p_app_rec.amount_applied:'||p_app_rec.amount_applied);
  END IF;

  --Set processing required flag
  IF ((g_ae_doc_rec.source_table = 'RA')
    AND (((nvl(p_app_rec.earned_discount_taken,0) <> 0)
	   OR (nvl(p_app_rec.unearned_discount_taken,0) <> 0))
	   OR ((l_ae_def_tax) AND (nvl(p_app_rec.amount_applied,0) <> 0))))
    OR ((g_ae_doc_rec.source_table = 'ADJ') AND (nvl(p_adj_rec.amount,0) <> 0))
  THEN
    p_required := TRUE;
  ELSE
    p_required := FALSE;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug(   'ARP_ALLOCATION_PKG.Check_Entry()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
	  arp_standard.debug(  'EXCEPTION: ARP_ALLOCATION_PKG.Check_Entry');
       END IF;
       RAISE;
END Check_Entry;

/* =======================================================================
 | PROCEDURE Get_Tax_Curr
 |
 | DESCRIPTION
 |      This routine gets the Invoice currency details and Tax rounding
 |      rules for the same.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_invoice_id            IN      Invoice identifier
 * ======================================================================*/
PROCEDURE Get_Tax_Curr(p_invoice_id          IN ra_customer_trx.customer_trx_id%TYPE          ,
                       p_payment_schedule_id IN ar_payment_schedules.payment_schedule_id%TYPE   ) IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Tax_Curr()+');
     arp_standard.debug( '  p_invoice_id                           = ' || p_invoice_id);
     arp_standard.debug( '  p_payment_schedule_id                  = ' || p_payment_schedule_id);
  END IF;

/*----------------------------------------------------------------------------+
 | Get Invoice tax rounding rules and currency information                    |
 |                                                                            |
 | Modified select to get the acctd amount due remaining from the correct     |
 | sob (MRC TRIGGER REPLACEMENT)                                              |
 +----------------------------------------------------------------------------*/
 IF (NVL(g_ae_sys_rec.sob_type,'P') = 'P') THEN
      select    fc.precision                        ,
                fc.minimum_accountable_unit         ,
                pay.amount_due_remaining            ,
                pay.acctd_amount_due_remaining      ,
                pay.amount_due_original
      into      g_ae_curr_rec.precision                ,
                g_ae_curr_rec.minimum_accountable_unit ,
                g_amount_due_remaining                 ,
                g_acctd_amount_due_remaining           ,
                g_amount_due_original
      from ra_customer_trx      ct      ,
           ar_payment_schedules pay     ,
           fnd_currencies       fc
      where ct.customer_trx_id = p_invoice_id
      and   pay.customer_trx_id = ct.customer_trx_id
      and   pay.payment_schedule_id = p_payment_schedule_id
      and   ct.invoice_currency_code = fc.currency_code;
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( ' g_ae_curr_rec.precision                = ' || g_ae_curr_rec.precision);
     arp_standard.debug( ' g_ae_curr_rec.minimum_accountable_unit = ' || g_ae_curr_rec.minimum_accountable_unit);
     arp_standard.debug( ' g_amount_due_remaining                 = ' || g_amount_due_remaining);
     arp_standard.debug( ' g_acctd_amount_due_remaining           = ' || g_acctd_amount_due_remaining);
     arp_standard.debug( ' g_amount_due_original                  = ' || g_amount_due_original);
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Tax_Curr()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_ALLOCATION_PKG.Get_Tax_Curr - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Get_Tax_Curr');
     END IF;
     RAISE;

END Get_Tax_Curr;

/* =======================================================================
 | PROCEDURE Get_Invoice_Distributions
 |
 | DESCRIPTION
 |      Retrieves Revenue and Tax amounts for Invoice and Tax lines,
 |      including the non recoverable tax accounts off the tax code or
 |      location segment. This routine gets all the base data from the
 |      Invoice document so that Tax accounting may be done based on Rules
 |      for a activity for adjustments, finance charges or discounts.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_invoice_id            IN      Invoice identifier
 |                                      or adjustments
 |
 | NOTES : THE ORDERING OF THE CURSOR inv_dist_non_rule IS VERY IMPORTANT
 * ======================================================================*/
PROCEDURE Get_Invoice_Distributions(
                        p_invoice_id           IN      NUMBER,
                        p_app_rec              IN      ar_receivable_applications%ROWTYPE,
                        p_adj_rec              IN      ar_adjustments%ROWTYPE,
                        p_process_ed_adj       IN      VARCHAR2,
                        p_process_uned         IN      VARCHAR2,
                        p_process_pay          IN      VARCHAR2 ) IS

CURSOR get_group_data_tax IS
SELECT /*+ INDEX(ar_ae_alloc_rec_gt AR_AE_ALLOC_REC_GT_N3) */
       decode(ae_collected_tax_ccid,
              '',ae_account_class,
              'DEFTAX')                       ae_account_class      ,
       SUM(ae_amount)                         sum_ae_amount         ,
       SUM(ae_acctd_amount)                   sum_ae_acctd_amount   ,
       max(ae_code_combination_id)            ae_code_combination_id,
       max(decode(ae_override_ccid1,'',2,1))  ae_override_ccid1     ,
       max(decode(ae_override_ccid2,'',2,1))  ae_override_ccid2     ,
       count(ae_account_class)                ae_count
FROM ar_ae_alloc_rec_gt
WHERE ae_id = g_id
GROUP BY decode(ae_collected_tax_ccid,
                '',ae_account_class,
                'DEFTAX');

CURSOR get_group_data_rev IS
SELECT /*+ INDEX(ar_ae_alloc_rec_gt AR_AE_ALLOC_REC_GT_N3) */
       ae_account_class                       ae_account_class      ,
       SUM(ae_amount)                         sum_ae_amount         ,
       SUM(ae_acctd_amount)                   sum_ae_acctd_amount   ,
       max(ae_code_combination_id)            ae_code_combination_id,
       ''                                     ae_override_ccid1     ,
       ''                                     ae_override_ccid2     ,
       count(ae_account_class)                ae_count
FROM ar_ae_alloc_rec_gt
WHERE ae_id = g_id
AND   ae_account_class <> 'TAX'
GROUP BY ae_account_class;

CURSOR l_rev_unearn(p_type IN VARCHAR2, p_trx_line_id IN NUMBER) IS
SELECT /*+ INDEX(ar_ae_alloc_rec_gt AR_AE_ALLOC_REC_GT_N1) */ *
FROM  ar_ae_alloc_rec_gt
WHERE ae_id = g_id
AND   ae_account_class = p_type
AND   ae_customer_trx_line_id = p_trx_line_id
AND   ae_customer_trx_id = p_invoice_id;


l_rev_adj_rec AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;
l_inv_assign  ar_ae_alloc_rec_gt%ROWTYPE;

l_rev_ctr    BINARY_INTEGER    ;
l_ctr        BINARY_INTEGER    ;
l_ctr1       BINARY_INTEGER    ;
l_ctr2       BINARY_INTEGER    ;
l_ctr3       BINARY_INTEGER    ;

l_adj_id     NUMBER            ;
l_dist_count NUMBER            ;
l_ae_tax_id  NUMBER            ;
l_adj_number ar_adjustments.adjustment_number%TYPE;

l_ra_dist_tbl AR_Revenue_Adjustment_PVT.RA_Dist_Tbl_Type;

l_return_status VARCHAR2(1)   ;
l_msg_count     NUMBER        ;
l_msg_data      VARCHAR2(2000);
l_mesg          VARCHAR2(2000) := '';

g_ae_alloc_rev_tbl ar_ae_alloc_rec_gt%ROWTYPE;
g_ae_alloc_tax_tbl ar_ae_alloc_rec_gt%ROWTYPE;
l_override1 VARCHAR2(1) := 'N';
l_override2 VARCHAR2(1) := 'N';
l_gl_account_source    ar_receivables_trx.gl_account_source%TYPE    ;
l_tax_code_source      ar_receivables_trx.tax_code_source%TYPE      ;
l_tax_recoverable_flag ar_receivables_trx.tax_recoverable_flag%TYPE ;

CURSOR crevccid IS
SELECT decode(
       max(decode(b.account_class,'REV',b.code_combination_id,0)), -- REV row gets priority
       0,max(b.code_combination_id), -- If no REV row, pick max of ccid as usual
       max(decode(b.account_class,'REV',b.code_combination_id,0))
       ),
       ctl.ae_cust_trx_line_gl_dist_id
  FROM ra_cust_trx_line_gl_dist b,
       ar_ae_alloc_rec_gt       ctl
 WHERE ctl.ae_tax_link_id     = b.customer_trx_line_id
   AND ctl.ae_account_class   = 'TAX'
  GROUP BY ctl.ae_cust_trx_line_gl_dist_id;

l_ccid_tab     DBMS_SQL.NUMBER_TABLE;
l_ctlgd_tab    DBMS_SQL.NUMBER_TABLE;


BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Invoice_Distributions()+');
  END IF;
/*------------------------------------------------------------------------------+
 | Initialise revenue, tax amounts and accounted amounts                        |
 +------------------------------------------------------------------------------*/
   g_ae_rule_rec.revenue_amt          := 0;
   g_ae_rule_rec.revenue_acctd_amt    := 0;
   g_ae_rule_rec.tax_amt              := 0;
   g_ae_rule_rec.tax_acctd_amt        := 0;
   g_ae_rule_rec.def_tax_amt          := 0;
   g_ae_rule_rec.def_tax_acctd_amt    := 0;

 --------------------------------------------------------------------------------
 --Override account flags
 --------------------------------------------------------------------------------
  Override_Accounts(p_app_rec   =>  p_app_rec  ,
                    p_adj_rec   =>  p_adj_rec  ,
                    p_override1 =>  l_override1,
                    p_override2 =>  l_override2 );

/*----------------------------------------------------------------------------+
 | Insert Tax distributions                                                   |
 | MRC Trigger Replacement.   Modified to insert currency sensitive columns   |
 +----------------------------------------------------------------------------*/
   insert into ar_ae_alloc_rec_gt (
     ae_id                       ,
     ae_account_class            ,
     ae_customer_trx_id          ,
     ae_customer_trx_line_id     ,
     ae_cust_trx_line_gl_dist_id ,
     ae_link_to_cust_trx_line_id ,
     ae_tax_type                 ,
     ae_code_combination_id      ,
     ae_collected_tax_ccid       ,
     ae_line_amount              ,
     ae_amount                   ,
     ae_acctd_amount             ,
     ae_tax_group_code_id        ,
     ae_tax_id                   ,
     ae_taxable_amount           ,
     ae_taxable_acctd_amount     ,
     ae_adj_ccid                 ,
     ae_edisc_ccid               ,
     ae_unedisc_ccid             ,
     ae_finchrg_ccid             ,
     ae_adj_non_rec_tax_ccid     ,
     ae_edisc_non_rec_tax_ccid   ,
     ae_unedisc_non_rec_tax_ccid ,
     ae_finchrg_non_rec_tax_ccid ,
     ae_override_ccid1           ,
     ae_override_ccid2           ,
     ae_tax_link_id              , -- link_to_cust_trx_line_id
     ae_tax_link_id_ed_adj       , -- link_to_cust_trx_line_id
     ae_tax_link_id_uned         , -- link_to_cust_trx_line_id
     ae_tax_link_id_act          , -- left null populate later
     ae_pro_amt                  ,
     ae_pro_acctd_amt            ,
     ae_pro_frt_chrg_amt         ,
     ae_pro_frt_chrg_acctd_amt   ,
     ae_pro_taxable_amt          ,
     ae_pro_taxable_acctd_amt    ,
     ae_pro_split_taxable_amt       ,
     ae_pro_split_taxable_acctd_amt ,
     ae_pro_recov_taxable_amt       ,
     ae_pro_recov_taxable_acctd_amt ,
     ae_pro_def_tax_amt          ,
     ae_pro_def_tax_acctd_amt    ,
     ae_summarize_flag           ,
     ae_counted_flag             ,
     ae_autotax                  ,
     ae_sum_alloc_amt            ,
     ae_sum_alloc_acctd_amt      ,
     ae_tax_line_count           ,
     ref_account_class                   ,
     activity_bucket                      ,
     ae_ref_line_id,
     ae_from_pro_amt,
     ae_from_pro_acctd_amt,
     ref_dist_ccid,
     ref_mf_dist_flag
     )
       SELECT
          g_id                                      ae_id,
          gld.account_class                         ae_account_class,
          ctl.customer_trx_id                       ae_customer_trx_id,
          ctl.customer_trx_line_id                  ae_customer_trx_line_id,
          gld.cust_trx_line_gl_dist_id              ae_cust_trx_line_gl_dist_id ,
          nvl(ctl.link_to_cust_trx_line_id,-9999)   ae_link_to_cust_trx_line_id,
          decode(ctl.location_segment_id,
                     '','VAT',
                     'LOC')                         ae_tax_type,
          gld.code_combination_id                   ae_code_combination_id,
          gld.collected_tax_ccid                    ae_collected_tax_ccid,
          ctl.extended_amount                  ae_line_amount,
          nvl(gld.amount,0)                    ae_amount,
          NVL(gld.acctd_amount,0)                     ae_acctd_amount,
          decode(ctl.location_segment_id,
                    '',
                    decode(nvl(ctl.autotax,'Y'),
                          'N', '',
                           decode(nvl(line.location_segment_id,line.vat_tax_id),
                                '','',
                                nvl(ctl.location_segment_id, ctl.vat_tax_id),'',
                                nvl(line.location_segment_id,line.vat_tax_id))),
                         '')                       ae_tax_group_code_id,
          nvl(ctl.location_segment_id,ctl.vat_tax_id) ae_tax_id,
          ctl.taxable_amount                          ae_taxable_amount,
          arpcurr.functional_amount(nvl(ctl.taxable_amount,0)       ,
                       g_ae_sys_rec.base_currency   ,
                       g_cust_inv_rec.exchange_rate,
                       g_ae_sys_rec.base_precision  ,
                       g_ae_sys_rec.base_min_acc_unit) ae_taxable_acctd_amount,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'ADJ')         ae_adj_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'EDISC')       ae_edisc_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'UNEDISC')     ae_unedisc_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'FINCHRG')     ae_finchrg_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'ADJ_NON_REC') ae_adj_non_rec_tax_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'EDISC_NON_REC') ae_edisc_non_rec_tax_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'UNEDISC_NON_REC') ae_unedisc_non_rec_tax_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'FINCHRG_NON_REC') ae_finchrg_non_rec_tax_ccid,
          decode(g_ae_rule_rec.tax_code_source1,
                     'INVOICE', decode(g_ae_rule_rec.tax_recoverable_flag1,
                                       'N',
                                       decode(g_ae_doc_rec.source_table,
                                              'RA',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'EDISC_NON_REC'),
                                              'ADJ',
                                              decode(g_ae_doc_rec.document_type,
                                                     'ADJUSTMENT',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'ADJ_NON_REC'),
                                                    'FINANCE_CHARGES',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'FINCHRG_NON_REC'),
                                                             ''),
                                                        ''),
                                           ''),
                        'ACTIVITY', g_ae_rule_rec.act_tax_non_rec_ccid1,
                        '')                          ae_override_ccid1,
              decode(g_ae_rule_rec.tax_code_source2,
                         'INVOICE',decode(g_ae_rule_rec.tax_recoverable_flag2,
                                          'N', decode(g_ae_doc_rec.source_table,
                                                      'RA',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        gld.gl_date,
                                        'UNEDISC_NON_REC'),
                                                      ''),
                                          ''),
                         'ACTIVITY', g_ae_rule_rec.act_tax_non_rec_ccid2,
                         '')                           ae_override_ccid2,
              ctl.link_to_cust_trx_line_id             ae_tax_link_id,
              ctl.link_to_cust_trx_line_id             ae_tax_link_id_ed_adj,
              ctl.link_to_cust_trx_line_id             ae_tax_link_id_uned,
              ctl.link_to_cust_trx_line_id             ae_tax_link_id_act,
              det.amount                         ae_pro_amt,
              det.acctd_amount                   ae_pro_acctd_amt,
              0                                  ae_pro_frt_chrg_amt,
              0                                  ae_pro_frt_chrg_acctd_amt,
              det.taxable_amount                 ae_pro_taxable_amt,
              det.taxable_acctd_amount           ae_pro_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_split_taxable_amt ,
              det.taxable_acctd_amount           ae_pro_split_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_recov_taxable_amt,
              det.taxable_acctd_amount           ae_pro_recov_taxable_acctd_amt,
              0                                  ae_pro_def_tax_amt,
              0                                  ae_pro_def_tax_acctd_amt,
             'N'                                 ae_summarize_flag,
             'N'                                 ae_counted_flag,
              ctl.autotax                   ae_autotax,
             0                                   ae_sum_alloc_amt,
             0                                   ae_sum_alloc_acctd_amt,
             Get_Tax_Count(ctl.link_to_cust_trx_line_id) ae_tax_line_count,
             det.ref_account_class                       ref_account_class,
             det.activity_bucket                          activity_bucket,
             det.ref_line_id                     ae_ref_line_id,
             det.from_amount                     ae_from_pro_amt,
             det.from_acctd_amount               ae_from_pro_acctd_amt,
             det.ccid                            ref_dist_ccid,
             det.ref_mf_dist_flag
       FROM ra_customer_trx_lines     ctl,
            ra_cust_trx_line_gl_dist  gld,
            ra_customer_trx_lines     line,
            ar_line_app_detail_gt     det
       where ctl.customer_trx_id = p_invoice_id
       and   ctl.line_type = 'TAX'
       and   gld.customer_trx_line_id = ctl.customer_trx_line_id
       and   gld.account_set_flag = 'N'
       and   ctl.link_to_cust_trx_line_id = line.customer_trx_line_id (+)
       and   'LINE' = line.line_type (+)
       AND   det.ref_customer_trx_id   = ctl.customer_trx_id
       AND   det.ref_customer_trx_line_id = ctl.customer_trx_line_id
       AND   det.ref_cust_trx_line_gl_dist_id = gld.cust_trx_line_gl_dist_id
       AND   det.gt_id                    = g_id
       AND   det.ledger_id                = g_ae_sys_rec.set_of_books_id;
       /* and   not exists (select 'x'
                         from ra_customer_trx_lines ctl1
                         where ctl1.customer_trx_id = p_invoice_id
                         and   ctl1.autorule_complete_flag = 'N')   */
                /* nvl(tax.location_segment_id,tax.vat_tax_id),
                decode(tax.location_segment_id,
                                   '','VAT',
                                   'LOC') */


      arp_standard.debug('p_process_ed_adj:'||p_process_ed_adj);
      arp_standard.debug('p_process_uned:'||p_process_uned);


      IF ((NVL(p_process_ed_adj,'N')        = 'Y' AND
           g_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE' AND
           g_ae_rule_rec.tax_code_source1   = 'NONE') OR
         ( NVL(p_process_uned,'N')          = 'Y' AND
           g_ae_rule_rec.gl_account_source2 = 'REVENUE_ON_INVOICE' AND
           g_ae_rule_rec.tax_code_source2   = 'NONE'))
      THEN
         OPEN crevccid;
         FETCH crevccid BULK COLLECT INTO
           l_ccid_tab ,
           l_ctlgd_tab;
         CLOSE crevccid;
         IF l_ctlgd_tab.COUNT > 0 THEN
           FORALL k IN l_ccid_tab.FIRST .. l_ccid_tab.LAST
           UPDATE ar_ae_alloc_rec_gt
              SET ae_code_combination_id = l_ccid_tab(k)
            WHERE ae_cust_trx_line_gl_dist_id = l_ctlgd_tab(k);
         END IF;
     END IF;



   insert into ar_ae_alloc_rec_gt (
     ae_id                       ,
     ae_account_class            ,
     ae_customer_trx_id          ,
     ae_customer_trx_line_id     ,
     ae_cust_trx_line_gl_dist_id ,
     ae_link_to_cust_trx_line_id ,
     ae_tax_type                 ,
     ae_code_combination_id      ,
     ae_collected_tax_ccid       ,
     ae_line_amount              ,
     ae_amount                   ,
     ae_acctd_amount             ,
     ae_tax_group_code_id        ,
     ae_tax_id                   ,
     ae_taxable_amount           ,
     ae_taxable_acctd_amount     ,
     ae_adj_ccid                 ,
     ae_edisc_ccid               ,
     ae_unedisc_ccid             ,
     ae_finchrg_ccid             ,
     ae_adj_non_rec_tax_ccid     ,
     ae_edisc_non_rec_tax_ccid   ,
     ae_unedisc_non_rec_tax_ccid ,
     ae_finchrg_non_rec_tax_ccid ,
     ae_override_ccid1           ,
     ae_override_ccid2           ,
     ae_tax_link_id              ,
     ae_tax_link_id_ed_adj       ,
     ae_tax_link_id_uned         ,
     ae_tax_link_id_act          ,
     ae_pro_amt                  ,
     ae_pro_acctd_amt            ,
     ae_pro_frt_chrg_amt         ,
     ae_pro_frt_chrg_acctd_amt   ,
     ae_pro_taxable_amt          ,
     ae_pro_taxable_acctd_amt    ,
     ae_pro_split_taxable_amt       ,
     ae_pro_split_taxable_acctd_amt ,
     ae_pro_recov_taxable_amt       ,
     ae_pro_recov_taxable_acctd_amt ,
     ae_pro_def_tax_amt          ,
     ae_pro_def_tax_acctd_amt    ,
     ae_summarize_flag           ,
     ae_counted_flag             ,
     ae_autotax                  ,
     ae_sum_alloc_amt            ,
     ae_sum_alloc_acctd_amt      ,
     ae_tax_line_count           ,
     ref_account_class                   ,
     activity_bucket                      ,
     AE_REF_LINE_ID,
     ae_from_pro_amt,
     ae_from_pro_acctd_amt,
     ref_dist_ccid,
     ref_mf_dist_flag
     )
       SELECT
          g_id                                      ae_id,
          'TAX'                                     ae_account_class,
          det.ref_customer_trx_id                   ae_customer_trx_id,
          det.ref_customer_trx_line_id              ae_customer_trx_line_id,
          det.ref_cust_trx_line_gl_dist_id          ae_cust_trx_line_gl_dist_id ,
          ''                                        ae_link_to_cust_trx_line_id,
          decode(ctl.location_segment_id,
                     '','VAT',
                     'LOC')                         ae_tax_type,
          --''                                        ae_tax_type,
          ''                                        ae_code_combination_id,
          ''                                        ae_collected_tax_ccid,
          ''                                        ae_line_amount,
          ''                                        ae_amount,
          ''                                        ae_acctd_amount,
          decode(ctl.location_segment_id,
                    '',
                    decode(nvl(ctl.autotax,'Y'),
                          'N', '',
                           decode(nvl(line.location_segment_id,line.vat_tax_id),
                                '','',
                                nvl(ctl.location_segment_id, ctl.vat_tax_id),'',
                                nvl(line.location_segment_id,line.vat_tax_id))),
                         '')                       ae_tax_group_code_id,
          nvl(ctl.location_segment_id,ctl.vat_tax_id) ae_tax_id,
          --''                                        ae_tax_group_code_id,
          --''                                        ae_tax_id,
          det.amount                                ae_taxable_amount,
          arpcurr.functional_amount(nvl(det.amount,0)       ,
                       g_ae_sys_rec.base_currency   ,
                       g_cust_inv_rec.exchange_rate,
                       g_ae_sys_rec.base_precision  ,
                       g_ae_sys_rec.base_min_acc_unit) ae_taxable_acctd_amount,

          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'ADJ')         ae_adj_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'EDISC')       ae_edisc_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'UNEDISC')     ae_unedisc_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'FINCHRG')     ae_finchrg_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'ADJ_NON_REC') ae_adj_non_rec_tax_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'EDISC_NON_REC') ae_edisc_non_rec_tax_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'UNEDISC_NON_REC') ae_unedisc_non_rec_tax_ccid,
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'FINCHRG_NON_REC') ae_finchrg_non_rec_tax_ccid,
          decode(g_ae_rule_rec.tax_code_source1,
                     'INVOICE', decode(g_ae_rule_rec.tax_recoverable_flag1,
                                       'N',
                                       decode(g_ae_doc_rec.source_table,
                                              'RA',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'EDISC_NON_REC'),
                                              'ADJ',
                                              decode(g_ae_doc_rec.document_type,
                                                     'ADJUSTMENT',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'ADJ_NON_REC'),
                                                    'FINANCE_CHARGES',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'FINCHRG_NON_REC'),
                                                             ''),
                                                        ''),
                                           ''),
                        'ACTIVITY', g_ae_rule_rec.act_tax_non_rec_ccid1,
                        '')                          ae_override_ccid1,
              decode(g_ae_rule_rec.tax_code_source2,
                         'INVOICE',decode(g_ae_rule_rec.tax_recoverable_flag2,
                                          'N', decode(g_ae_doc_rec.source_table,
                                                      'RA',
          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                        null,
                                        'UNEDISC_NON_REC'),
                                                      ''),
                                          ''),
                         'ACTIVITY', g_ae_rule_rec.act_tax_non_rec_ccid2,
                         '')                           ae_override_ccid2,

--          ''                                         ae_adj_ccid,
--          ''                                         ae_edisc_ccid,
--          ''                                         ae_unedisc_ccid,
--          ''                                         ae_finchrg_ccid,
--          ''                                         ae_adj_non_rec_tax_ccid,
--          ''                                         ae_edisc_non_rec_tax_ccid,
--          ''                                         ae_unedisc_non_rec_tax_ccid,
--          ''                                         ae_finchrg_non_rec_tax_ccid,
--          ''                                         ae_override_ccid1,
--          ''                                         ae_override_ccid2,
          ''                                         ae_tax_link_id,
          ''                                         ae_tax_link_id_ed_adj,
          ''                                         ae_tax_link_id_uned,
          ''                                  ae_tax_link_id_act,
          det.amount                          ae_pro_amt,
          det.acctd_amount                    ae_pro_acctd_amt,
          0                                   ae_pro_frt_chrg_amt,
          0                                   ae_pro_frt_chrg_acctd_amt,
              det.taxable_amount                 ae_pro_taxable_amt,
              det.taxable_acctd_amount           ae_pro_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_split_taxable_amt ,
              det.taxable_acctd_amount           ae_pro_split_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_recov_taxable_amt,
              det.taxable_acctd_amount           ae_pro_recov_taxable_acctd_amt,
          0                                   ae_pro_def_tax_amt,
          0                                   ae_pro_def_tax_acctd_amt,
          'N'                                 ae_summarize_flag,
          'N'                                 ae_counted_flag,
          ''                                  ae_autotax,
          0                                   ae_sum_alloc_amt,
          0                                   ae_sum_alloc_acctd_amt,
          ''                                  ae_tax_line_count,
          det.ref_account_class                       ref_account_class,
          det.activity_bucket                          activity_bucket,
          det.ref_line_id                     ae_line_id,
          det.from_amount                     ae_from_pro_amt,
          det.from_acctd_amount               ae_from_pro_acctd_amt,
          det.ccid                            ref_dist_ccid,
          det.ref_mf_dist_flag                ref_mf_dist_flag
       FROM ar_line_app_detail_gt  det,
            ra_customer_trx_lines  ctl,
            ra_customer_trx_lines  line,
            ( SELECT customer_trx_id,
                     nvl(location_segment_id,-9999) location_segment_id,
		     nvl(vat_tax_id,-9999) tax_code_id,
		     min(customer_trx_line_id) customer_trx_line_id
	      FROM ra_customer_trx_lines tax
	      GROUP BY customer_trx_id,
                       location_segment_id,
		       vat_tax_id ) tax_link
       WHERE det.ref_customer_trx_id = p_invoice_id
       AND   gt_id   = g_id
       AND   det.ref_customer_trx_id            = tax_link.customer_trx_id
       AND   NVL(det.location_segment_id,-9999) = tax_link.location_segment_id
       AND   NVL(det.tax_code_id,-9999)         = tax_link.tax_code_id
       AND   ctl.customer_trx_line_id           = tax_link.customer_trx_line_id
       AND   ctl.customer_trx_id                = det.ref_customer_trx_id
       AND   ctl.link_to_cust_trx_line_id       = line.customer_trx_line_id (+)
       AND   'LINE'                             = line.line_type (+)
       AND   det.ledger_id   = g_ae_sys_rec.set_of_books_id
       AND   ref_customer_trx_line_id IN (-8);
--              (-6, --Boundary line : -6
--               -7, --Boundary charge:-7
--               -8, --Boundary tax
--               -9); --Boundary freight




      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Get_Invoice_Distributions: ' || 'Tax and Deferred Tax amount accumulators, non recoverable account validation');
      END IF;

      for l_get_group_data IN get_group_data_tax LOOP

       /*---------------------------------------------------------------------+
        | Validate account setup for Non Recoverable tax accounts for earned  |
        | discounts and adjustments                                           |
        +---------------------------------------------------------------------*/
        /*
            IF ((((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.tax_ediscounted,0) <> 0))
              OR ((g_ae_doc_rec.source_table = 'ADJ') AND (nvl(p_adj_rec.tax_adjusted,0) <> 0)))
              AND (((g_ae_rule_rec.tax_code_source1 = 'INVOICE') AND (g_ae_rule_rec.tax_recoverable_flag1 = 'N'))
                   OR (g_ae_rule_rec.tax_code_source1 = 'ACTIVITY'))
              AND (l_get_group_data.ae_override_ccid1 = 2)) THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('Get_Invoice_Distributions: ' || 'Invalid CCid error');
                END IF;
                RAISE invalid_ccid_error;

            END IF;
        */

       /*----------------------------------------------------------------+
        | Validate account setup for Non Recoverable tax accounts for    |
        | unearned discounts                                             |
        +----------------------------------------------------------------*/
        /*
          IF (((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.tax_uediscounted,0) <> 0))
              AND (((g_ae_rule_rec.tax_code_source2 = 'INVOICE') AND (g_ae_rule_rec.tax_recoverable_flag2 = 'N'))
                   OR (g_ae_rule_rec.tax_code_source2 = 'ACTIVITY'))
              AND (l_get_group_data.ae_override_ccid2 = 2)) THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Get_Invoice_Distributions: ' || 'Invalid CCid error');
              END IF;
              RAISE invalid_ccid_error;

          END IF;
        */
--}
       /*-------------------------------------------------------------------+
        | Total accumulators for tax and tax accounted amount               |
        +-------------------------------------------------------------------*/
          g_ae_rule_rec.tax_amt       := g_ae_rule_rec.tax_amt +
                                         l_get_group_data.sum_ae_amount;
          g_ae_rule_rec.tax_acctd_amt := g_ae_rule_rec.tax_acctd_amt +
                                         l_get_group_data.sum_ae_acctd_amount;

      /*----------------------------------------------------------------------+
       | Total accumulators for deferred tax and deferred tax accounted amount|
       +----------------------------------------------------------------------*/
          IF l_get_group_data.ae_account_class = 'DEFTAX' THEN
             g_ae_rule_rec.def_tax_amt       := l_get_group_data.sum_ae_amount;
             g_ae_rule_rec.def_tax_acctd_amt := l_get_group_data.sum_ae_acctd_amount;
          END IF;

       --Assign tax lines
          g_ae_tax_ctr := g_ae_tax_ctr + l_get_group_data.ae_count;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_tax_ctr = ' || g_ae_tax_ctr);
             arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.def_tax_amt = ' ||
                                g_ae_rule_rec.def_tax_amt);
             arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.def_tax_acctd_amt = ' ||
                                g_ae_rule_rec.def_tax_acctd_amt);
             arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.tax_amt = ' || g_ae_rule_rec.tax_amt);
             arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.tax_acctd_amt = ' ||
                                g_ae_rule_rec.tax_acctd_amt);
          END IF;

     END LOOP;

 -----------------------------------------------------------------------------
 --Set the tax link ids
 -----------------------------------------------------------------------------
 /* Obsolete
     Get_Tax_Link_Id(p_process_ed_adj => p_process_ed_adj,
                     p_process_uned   => p_process_uned,
                     p_process_pay    => p_process_pay);
  */
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Get_Invoice_Distributions: ' || 'Inserting Revenue lines');
   END IF;


/*----------------------------------------------------------------------------+
 | Insert the Revenue, Unearned, Receivable, Suppense, Tax lines into the     |
 | temporary allocation table for computation purposes to build final         |
 | accounting                                                                 |
 +----------------------------------------------------------------------------*/
--note we have removed the outer join to lines table for REC,
--  since UNBILL and UNEARN
--always have a customer_trx_line_id

  -- MRC Trigger Replacement:  get currency sensitive data
   insert into ar_ae_alloc_rec_gt (
     ae_id                       ,
     ae_account_class            ,
     ae_customer_trx_id          ,
     ae_customer_trx_line_id     ,
     ae_cust_trx_line_gl_dist_id ,
     ae_link_to_cust_trx_line_id ,
     ae_tax_type                 ,
     ae_code_combination_id      ,
     ae_collected_tax_ccid       ,
     ae_line_amount              ,
     ae_amount                   ,
     ae_acctd_amount             ,
     ae_tax_group_code_id        ,
     ae_tax_id                   ,
     ae_taxable_amount           ,
     ae_taxable_acctd_amount     ,
     ae_adj_ccid                 ,
     ae_edisc_ccid               ,
     ae_unedisc_ccid             ,
     ae_finchrg_ccid             ,
     ae_adj_non_rec_tax_ccid     ,
     ae_edisc_non_rec_tax_ccid   ,
     ae_unedisc_non_rec_tax_ccid ,
     ae_finchrg_non_rec_tax_ccid ,
     ae_override_ccid1           ,
     ae_override_ccid2           ,
     ae_tax_link_id              ,
     ae_tax_link_id_ed_adj       ,
     ae_tax_link_id_uned         ,
     ae_tax_link_id_act          ,
     ae_pro_amt                  ,
     ae_pro_acctd_amt            ,
     ae_pro_frt_chrg_amt         ,
     ae_pro_frt_chrg_acctd_amt   ,
     ae_pro_taxable_amt          ,
     ae_pro_taxable_acctd_amt    ,
     ae_pro_split_taxable_amt      ,
     ae_pro_split_taxable_acctd_amt ,
     ae_pro_recov_taxable_amt      ,
     ae_pro_recov_taxable_acctd_amt ,
     ae_pro_def_tax_amt          ,
     ae_pro_def_tax_acctd_amt    ,
     ae_summarize_flag           ,
     ae_counted_flag             ,
     ae_autotax                  ,
     ae_sum_alloc_amt            ,
     ae_sum_alloc_acctd_amt      ,
     ae_tax_line_count           ,
     ref_account_class                   ,
     activity_bucket,
     ae_ref_line_id,
     ae_from_pro_amt,
     ae_from_pro_acctd_amt,
     --{ref_dist_ccid
     ref_dist_ccid,
     ref_mf_dist_flag
     --}
     )
       SELECT g_id                    ae_id,
              decode(gld.account_class,
                     'REV'     ,'REVEARN',
                     'CHARGES' ,'REVEARN',
                     'SUSPENSE','REVEARN',
                     'UNBILL'  ,'REVUNEARN',
                     'UNEARN'  ,'REVUNEARN',
                     'FREIGHT' ,'FREIGHT')    ae_account_class,
              ctl.customer_trx_id             ae_customer_trx_id,
              ctl.customer_trx_line_id        ae_customer_trx_line_id,
              gld.cust_trx_line_gl_dist_id    ae_cust_trx_line_gl_dist_id ,
              nvl(ctl.link_to_cust_trx_line_id,
                  -9999)                      ae_link_to_cust_trx_line_id,
              decode(gld.account_class,
                     'FREIGHT','FREIGHT',
                     'REV')                                ae_tax_type,
              gld.code_combination_id         ae_code_combination_id,
              gld.collected_tax_ccid          ae_collected_tax_ccid,
              decode(gld.account_class,
                        'REV', nvl(ctl.revenue_amount,0),
                        'FREIGHT', nvl(ctl.revenue_amount,0),
                        'SUSPENSE',(ctl.extended_amount -
                                    nvl(ctl.revenue_amount,0)),
                        ctl.extended_amount)  ae_line_amount,
              nvl(gld.amount,0)           ae_amount,
              NVL(gld.acctd_amount,0)          ae_acctd_amount,
              ''                               ae_tax_group_code_id,
              ''                               ae_tax_id,
              ''                               ae_taxable_amount,
              ''                               ae_taxable_acctd_amount,
              ''                               ae_adj_ccid,
              ''                               ae_edisc_ccid,
              ''                               ae_unedisc_ccid,
              ''                               ae_finchrg_ccid,
              ''                               ae_adj_non_rec_tax_ccid,
              ''                               ae_edisc_non_rec_tax_ccid,
              ''                               ae_unedisc_non_rec_tax_ccid,
              ''                               ae_finchrg_non_rec_tax_ccid,
              decode(l_override1,
                         'Y',
                         decode(g_ae_rule_rec.gl_account_source1,
                                'ACTIVITY_GL_ACCOUNT',
                                    g_ae_rule_rec.code_combination_id1,
                                'TAX_CODE_ON_INVOICE',b5.override_ccid1,
                                  ''),
                         '')                   ae_override_ccid1,
/*
              DECODE(l_override1,
                         'Y',
                         DECODE( DECODE(det.activity_bucket, 'APP_LINE', 'ACTIVITY_GL_ACCOUNT',
                                                'APP_TAX' , 'ACTIVITY_GL_ACCOUNT',
                                                'APP_FRT' , 'ACTIVITY_GL_ACCOUNT',
                                                'APP_CHRG', 'ACTIVITY_GL_ACCOUNT',
                                                  g_ae_rule_rec.gl_account_source1),
                                'ACTIVITY_GL_ACCOUNT',
                                        DECODE(det.activity_bucket,'APP_LINE',g_ae_rule_rec.receivable_account,
                                                      'APP_TAX' ,g_ae_rule_rec.receivable_account,
                                                      'APP_FRT' ,g_ae_rule_rec.receivable_account,
                                                      'APP_CHRG',g_ae_rule_rec.receivable_account,
                                                            g_ae_rule_rec.code_combination_id1),
                                'TAX_CODE_ON_INVOICE',b5.override_ccid1,
                                  ''),
                         '')                   ae_override_ccid1,
*/
              decode(l_override2,
                         'Y',
                         decode(g_ae_rule_rec.gl_account_source2,
                                'ACTIVITY_GL_ACCOUNT',
                                   g_ae_rule_rec.code_combination_id2,
                                'TAX_CODE_ON_INVOICE',b5.override_ccid2,
                                 ''),
                         '')                   ae_override_ccid2        ,
--              ''                                ae_tax_link_id           ,
--              ''                                ae_tax_link_id_ed_adj    ,
--              ''                                ae_tax_link_id_uned      ,
              ctl.customer_trx_line_id          ae_tax_link_id,
              ctl.customer_trx_line_id          ae_tax_link_id_ed_adj,
              ctl.customer_trx_line_id          ae_tax_link_id_uned,
              ctl.customer_trx_line_id          ae_tax_link_id_act       ,
              det.amount                        ae_pro_amt               ,
              det.acctd_amount                  ae_pro_acctd_amt         ,
              0                                 ae_pro_frt_chrg_amt      ,
              0                                 ae_pro_frt_chrg_acctd_amt,
              det.taxable_amount                 ae_pro_taxable_amt,
              det.taxable_acctd_amount           ae_pro_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_split_taxable_amt ,
              det.taxable_acctd_amount           ae_pro_split_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_recov_taxable_amt,
              det.taxable_acctd_amount           ae_pro_recov_taxable_acctd_amt,
              0                                 ae_pro_def_tax_amt       ,
              0                                 ae_pro_def_tax_acctd_amt ,
             'N'                                ae_summarize_flag        ,
             'N'                                ae_counted_flag          ,
             ''                                 ae_autotax               ,
             0                                  ae_sum_alloc_amt         ,
             0                                  ae_sum_alloc_acctd_amt   ,
             0                                  ae_tax_line_count        ,
             det.ref_account_class                 ref_account_class,
             det.activity_bucket                    activity_bucket,
             det.ref_line_id               ae_ref_line_id,
             det.from_amount                     ae_from_pro_amt,
             det.from_acctd_amount               ae_from_pro_acctd_amt,
             --{ref_dist_ccid
             det.ccid                            ref_dist_ccid,
             det.ref_mf_dist_flag                ref_mf_dist_flag
             --}
       from ra_customer_trx_lines     ctl,
            ra_cust_trx_line_gl_dist  gld,
            ar_line_app_detail_gt  det,
            (select b4.ae_link_to_cust_trx_line_id ae_link_to_cust_trx_line_id,
                    max(decode(g_ae_rule_rec.gl_account_source1,
                           'TAX_CODE_ON_INVOICE',
                            decode(g_ae_doc_rec.source_table,
                                   'RA', b4.ae_edisc_ccid,
                                   'ADJ',decode(g_ae_doc_rec.document_type,
                                   'ADJUSTMENT', b4.ae_adj_ccid,
                                   'FINANCE_CHARGES',b4.ae_finchrg_ccid,
                                                                      ''),
                                                         ''),
                           ''))               override_ccid1,
                    max(decode(g_ae_rule_rec.gl_account_source2,
                        'TAX_CODE_ON_INVOICE', decode(g_ae_doc_rec.source_table,
                                                      'RA', b4.ae_unedisc_ccid,
                                                         ''),
                           ''))               override_ccid2
             from ar_ae_alloc_rec_gt b4
             where b4.rowid IN
               (select /*+ INDEX(b3 AR_AE_ALLOC_REC_GT_N3) */
                     min(b3.rowid)
                from ar_ae_alloc_rec_gt b3
                where b3.ae_id = g_id
                and   b3.ae_account_class = 'TAX'
                and   (((decode(g_ae_doc_rec.source_table,
                              'RA', decode(b3.ae_edisc_ccid,
                                           '','N',
                                           'Y'),
                              'ADJ',decode(g_ae_doc_rec.document_type,
                                           'ADJUSTMENT', decode(b3.ae_adj_ccid,
                                                                '','N',
                                                                'Y'),
                                           'FINANCE_CHARGES',decode(b3.ae_finchrg_ccid,
                                                                    '','N',
                                                                    'Y')),
                              'N')  = 'Y')
                          AND (l_override1 = 'Y')
                          AND (g_ae_rule_rec.gl_account_source1 = 'TAX_CODE_ON_INVOICE'))
                       OR
                       ((decode(g_ae_doc_rec.source_table,
                                'RA', decode(b3.ae_unedisc_ccid,
                                             '','N',
                                             'Y'),
                                'N') = 'Y')
                         AND (l_override2 = 'Y')
                         AND (g_ae_rule_rec.gl_account_source2 = 'TAX_CODE_ON_INVOICE')))
                group by b3.ae_link_to_cust_trx_line_id)
	      group by b4.ae_link_to_cust_trx_line_id
	     -- Bug 6719986 Added union sql to get the rows for TAX line of zero percentage tax.
	     UNION
             select ctl.link_to_cust_trx_line_id ae_link_to_cust_trx_line_id,
                    max(decode(g_ae_rule_rec.gl_account_source1,
                           'TAX_CODE_ON_INVOICE',
                            decode(g_ae_doc_rec.source_table,
                                   'RA',  arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'EDISC'),
                                   'ADJ',decode(g_ae_doc_rec.document_type,
                                                'ADJUSTMENT',
                                          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'ADJ'),
                                                'FINANCE_CHARGES',
                                          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'FINCHRG'),
                                                                      ''),
                                                         ''),
                           ''))               override_ccid1,
                    max(decode(g_ae_rule_rec.gl_account_source2,
                        'TAX_CODE_ON_INVOICE', decode(g_ae_doc_rec.source_table,
                                                      'RA',
                                          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'UNEDISC'),
                                                         ''),
                           ''))               override_ccid2
            from ra_customer_trx_lines ctl,
	    ra_cust_trx_line_gl_dist  gld
            where gld.customer_trx_line_id = ctl.customer_trx_line_id
	    and   gld.account_set_flag = 'N'
	    and   ctl.customer_trx_id = p_invoice_id
	    and   ctl.rowid in
		     (select min(ctl1.rowid)
		      from ra_customer_trx_lines ctl1,
			  (select /*+ INDEX(b3 AR_AE_ALLOC_REC_GT_N3) */
			   count(*) tax_count
			   from ar_ae_alloc_rec_gt b3
			   where b3.ae_id = g_id
			   and   b3.ae_account_class = 'TAX') tx
		      where ctl1.customer_trx_id = p_invoice_id
		      and   ctl1.line_type = 'TAX'
		      and tx.tax_count = 0
		      group by ctl1.link_to_cust_trx_line_id)
              group by ctl.link_to_cust_trx_line_id
                ) b5
       where ctl.customer_trx_id = p_invoice_id
       AND   ctl.line_type  IN ('LINE','FREIGHT','CB','CHARGES')
       --and   gld.customer_trx_id = ctl.customer_trx_id
       and   gld.customer_trx_line_id = ctl.customer_trx_line_id
       AND   gld.account_class IN ('REV','SUSPENSE','UNBILL','UNEARN','FREIGHT','CHARGES')
       and   gld.account_set_flag              = 'N'
       and   decode(ctl.line_type,
                    'FREIGHT', ctl.link_to_cust_trx_line_id,  --first available tax code netexpense account
                    ctl.customer_trx_line_id) = b5.ae_link_to_cust_trx_line_id (+)
       AND   det.ref_customer_trx_id          = ctl.customer_trx_id
       AND   det.ref_customer_trx_line_id     = ctl.customer_trx_line_id
       AND   det.ref_cust_trx_line_gl_dist_id = gld.cust_trx_line_gl_dist_id
       AND   det.ledger_id                = g_ae_sys_rec.set_of_books_id
       AND   det.gt_id                  =  g_id;
       /* and   not exists (select 'x'
                         from ra_customer_trx_lines ctl1
                         where ctl1.customer_trx_id = p_invoice_id
                         and   ctl1.autorule_complete_flag = 'N')   */
--       group by decode(gld.account_class,
--                       'REV'     ,'REVEARN',
--                       'SUSPENSE','REVEARN',
--                       'UNBILL'  ,'REVUNEARN',
--                       'UNEARN'  ,'REVUNEARN',
--                       'FREIGHT' ,'FREIGHT'),
--                decode(gld.account_class,
--                       'FREIGHT','FREIGHT',
--                       'REV')                           ,
--                gld.cust_trx_line_gl_dist_id            ,
--                ctl.customer_trx_id                     ,
--                nvl(ctl.link_to_cust_trx_line_id,-9999) ,
--                ctl.customer_trx_line_id                ,
--                gld.code_combination_id                 ,
--                gld.collected_tax_ccid                    ;
--}
        /* order by decode(gld.account_class,
                       'REV'     ,'REVEARN',
                       'SUSPENSE','REVEARN',
                       'UNBILL'  ,'REVUNEARN',
                       'UNEARN'  ,'REVUNEARN',
                       'TAX'     ,'TAX'),
                ctl.customer_trx_id           ,
                ctl.customer_trx_line_id   ; */


   insert into ar_ae_alloc_rec_gt (
     ae_id                       ,
     ae_account_class            ,
     ae_customer_trx_id          ,
     ae_customer_trx_line_id     ,
     ae_cust_trx_line_gl_dist_id ,
     ae_link_to_cust_trx_line_id ,
     ae_tax_type                 ,
     ae_code_combination_id      ,
     ae_collected_tax_ccid       ,
     ae_line_amount              ,
     ae_amount                   ,
     ae_acctd_amount             ,
     ae_tax_group_code_id        ,
     ae_tax_id                   ,
     ae_taxable_amount           ,
     ae_taxable_acctd_amount     ,
     ae_adj_ccid                 ,
     ae_edisc_ccid               ,
     ae_unedisc_ccid             ,
     ae_finchrg_ccid             ,
     ae_adj_non_rec_tax_ccid     ,
     ae_edisc_non_rec_tax_ccid   ,
     ae_unedisc_non_rec_tax_ccid ,
     ae_finchrg_non_rec_tax_ccid ,
     ae_override_ccid1           ,
     ae_override_ccid2           ,
     ae_tax_link_id              ,
     ae_tax_link_id_ed_adj       ,
     ae_tax_link_id_uned         ,
     ae_tax_link_id_act          ,
     ae_pro_amt                  ,
     ae_pro_acctd_amt            ,
     ae_pro_frt_chrg_amt         ,
     ae_pro_frt_chrg_acctd_amt   ,
     ae_pro_taxable_amt          ,
     ae_pro_taxable_acctd_amt    ,
     ae_pro_split_taxable_amt       ,
     ae_pro_split_taxable_acctd_amt ,
     ae_pro_recov_taxable_amt       ,
     ae_pro_recov_taxable_acctd_amt ,
     ae_pro_def_tax_amt          ,
     ae_pro_def_tax_acctd_amt    ,
     ae_summarize_flag           ,
     ae_counted_flag             ,
     ae_autotax                  ,
     ae_sum_alloc_amt            ,
     ae_sum_alloc_acctd_amt      ,
     ae_tax_line_count           ,
     ref_account_class                   ,
     activity_bucket                      ,
     ae_ref_line_id,
     ae_from_pro_amt,
     ae_from_pro_acctd_amt,
     --{ref_dist_ccid
     ref_dist_ccid,
     ref_mf_dist_flag
     --}
     )
       SELECT
          g_id                                      ae_id,
          DECODE(det.ref_account_class,'REV','REVEARN',
                               det.ref_account_class)       ae_account_class,
          det.ref_customer_trx_id                   ae_customer_trx_id,
          det.ref_customer_trx_line_id              ae_customer_trx_line_id,
          det.ref_cust_trx_line_gl_dist_id          ae_cust_trx_line_gl_dist_id ,
          ''                                        ae_link_to_cust_trx_line_id,
          ''                                        ae_tax_type,
          ''                                        ae_code_combination_id,
          ''                                        ae_collected_tax_ccid,
          ''                                        ae_line_amount,
          ''                                        ae_amount,
          ''                                        ae_acctd_amount,
          ''                                        ae_tax_group_code_id,
          ''                                        ae_tax_id,
          det.amount                                ae_taxable_amount,
          arpcurr.functional_amount(nvl(det.amount,0)       ,
                       g_ae_sys_rec.base_currency   ,
                       g_cust_inv_rec.exchange_rate,
                       g_ae_sys_rec.base_precision  ,
                       g_ae_sys_rec.base_min_acc_unit) ae_taxable_acctd_amount,
          ''                                         ae_adj_ccid,
          ''                                         ae_edisc_ccid,
          ''                                         ae_unedisc_ccid,
          ''                                         ae_finchrg_ccid,
          ''                                         ae_adj_non_rec_tax_ccid,
          ''                                         ae_edisc_non_rec_tax_ccid,
          ''                                         ae_unedisc_non_rec_tax_ccid,
          ''                                         ae_finchrg_non_rec_tax_ccid,
	  decode(l_override1,
		     'Y',
		     decode(g_ae_rule_rec.gl_account_source1,
			    'ACTIVITY_GL_ACCOUNT',
				g_ae_rule_rec.code_combination_id1,
			    'TAX_CODE_ON_INVOICE',b5.override_ccid1,
			      ''),
		     '')                             ae_override_ccid1,
	  decode(l_override2,
		     'Y',
		     decode(g_ae_rule_rec.gl_account_source2,
			    'ACTIVITY_GL_ACCOUNT',
			       g_ae_rule_rec.code_combination_id2,
			    'TAX_CODE_ON_INVOICE',b5.override_ccid2,
			     ''),
		     '')                             ae_override_ccid2,
          ''                                         ae_tax_link_id,
          ''                                         ae_tax_link_id_ed_adj,
          ''                                         ae_tax_link_id_uned,
          ''                                  ae_tax_link_id_act,
          det.amount                          ae_pro_amt,
          det.acctd_amount                    ae_pro_acctd_amt,
          0                                   ae_pro_frt_chrg_amt,
          0                                   ae_pro_frt_chrg_acctd_amt,
              det.taxable_amount                 ae_pro_taxable_amt,
              det.taxable_acctd_amount           ae_pro_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_split_taxable_amt ,
              det.taxable_acctd_amount           ae_pro_split_taxable_acctd_amt,
              det.taxable_amount                 ae_pro_recov_taxable_amt,
              det.taxable_acctd_amount           ae_pro_recov_taxable_acctd_amt,
          0                                   ae_pro_def_tax_amt,
          0                                   ae_pro_def_tax_acctd_amt,
          'N'                                 ae_summarize_flag,
          'N'                                 ae_counted_flag,
          ''                                  ae_autotax,
          0                                   ae_sum_alloc_amt,
          0                                   ae_sum_alloc_acctd_amt,
          ''                                  ae_tax_line_count,
          det.ref_account_class                       ref_account_class,
          det.activity_bucket                          activity_bucket,
          det.ref_line_id                     ae_ref_line_id,
             det.from_amount                     ae_from_pro_amt,
             det.from_acctd_amount               ae_from_pro_acctd_amt,
             det.ccid                            ref_dist_ccid,
             det.ref_mf_dist_flag                ref_mf_dist_flag
       FROM  ar_line_app_detail_gt  det,
             ra_customer_trx_lines  ctl,
	    ( SELECT customer_trx_id,
	             NVL(location_segment_id,-9999) location_segment_id,
	             NVL(vat_tax_id,-9999) tax_code_id,
	             MIN(NVL(link_to_cust_trx_line_id,customer_trx_line_id)) link_to_cust_trx_line_id
	      FROM ra_customer_trx_lines tax
	      GROUP BY customer_trx_id,
	            location_segment_id,
	            vat_tax_id ) tax_link,
           ( select b4.ae_link_to_cust_trx_line_id ae_link_to_cust_trx_line_id,
                    max(decode(g_ae_rule_rec.gl_account_source1,
                           'TAX_CODE_ON_INVOICE',
                            decode(g_ae_doc_rec.source_table,
                                   'RA', b4.ae_edisc_ccid,
                                   'ADJ',decode(g_ae_doc_rec.document_type,
                                   'ADJUSTMENT', b4.ae_adj_ccid,
                                   'FINANCE_CHARGES',b4.ae_finchrg_ccid,
                                                                      ''),
                                                         ''),
                           ''))               override_ccid1,
                    max(decode(g_ae_rule_rec.gl_account_source2,
                        'TAX_CODE_ON_INVOICE', decode(g_ae_doc_rec.source_table,
                                                      'RA', b4.ae_unedisc_ccid,
                                                         ''),
                           ''))               override_ccid2
             from ar_ae_alloc_rec_gt b4
             where b4.rowid IN
               (select /*+ INDEX(b3 AR_AE_ALLOC_REC_GT_N3) */
                     min(b3.rowid)
                from ar_ae_alloc_rec_gt b3
                where b3.ae_id = g_id
                and   b3.ae_account_class = 'TAX'
                and   (((decode(g_ae_doc_rec.source_table,
                              'RA', decode(b3.ae_edisc_ccid,
                                           '','N',
                                           'Y'),
                              'ADJ',decode(g_ae_doc_rec.document_type,
                                           'ADJUSTMENT', decode(b3.ae_adj_ccid,
                                                                '','N',
                                                                'Y'),
                                           'FINANCE_CHARGES',decode(b3.ae_finchrg_ccid,
                                                                    '','N',
                                                                    'Y')),
                              'N')  = 'Y')
                          AND (l_override1 = 'Y')
                          AND (g_ae_rule_rec.gl_account_source1 = 'TAX_CODE_ON_INVOICE'))
                       OR
                       ((decode(g_ae_doc_rec.source_table,
                                'RA', decode(b3.ae_unedisc_ccid,
                                             '','N',
                                             'Y'),
                                'N') = 'Y')
                         AND (l_override2 = 'Y')
                         AND (g_ae_rule_rec.gl_account_source2 = 'TAX_CODE_ON_INVOICE')))
                group by b3.ae_link_to_cust_trx_line_id)
	      group by b4.ae_link_to_cust_trx_line_id
	     -- Bug 6719986 Added union sql to get the rows for TAX line of zero percentage tax.
	     UNION
             select ctl.link_to_cust_trx_line_id ae_link_to_cust_trx_line_id,
                    max(decode(g_ae_rule_rec.gl_account_source1,
                           'TAX_CODE_ON_INVOICE',
                            decode(g_ae_doc_rec.source_table,
                                   'RA',  arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'EDISC'),
                                   'ADJ',decode(g_ae_doc_rec.document_type,
                                                'ADJUSTMENT',
                                          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'ADJ'),
                                                'FINANCE_CHARGES',
                                          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'FINCHRG'),
                                                                      ''),
                                                         ''),
                           ''))               override_ccid1,
                    max(decode(g_ae_rule_rec.gl_account_source2,
                        'TAX_CODE_ON_INVOICE', decode(g_ae_doc_rec.source_table,
                                                      'RA',
                                          arp_etax_util.get_tax_account(ctl.customer_trx_line_id,
                                                                        gld.gl_date,
                                                                        'UNEDISC'),
                                                         ''),
                           ''))               override_ccid2
            from ra_customer_trx_lines ctl,
	    ra_cust_trx_line_gl_dist  gld
            where gld.customer_trx_line_id = ctl.customer_trx_line_id
	    and   gld.account_set_flag = 'N'
	    and   ctl.customer_trx_id = p_invoice_id
	    and   ctl.rowid in
		     (select min(ctl1.rowid)
		      from ra_customer_trx_lines ctl1,
			  (select /*+ INDEX(b3 AR_AE_ALLOC_REC_GT_N3) */
			   count(*) tax_count
			   from ar_ae_alloc_rec_gt b3
			   where b3.ae_id = g_id
			   and   b3.ae_account_class = 'TAX') tx
		      where ctl1.customer_trx_id = p_invoice_id
		      and   ctl1.line_type = 'TAX'
		      and tx.tax_count = 0
		      group by ctl1.link_to_cust_trx_line_id)
              group by ctl.link_to_cust_trx_line_id
                ) b5
       WHERE det.ref_customer_trx_id = p_invoice_id
       AND   det.ledger_id           = g_ae_sys_rec.set_of_books_id
       AND   gt_id   = g_id
       AND   ref_customer_trx_line_id IN (-6,-7,-9)
       AND   det.ref_customer_trx_id    = tax_link.customer_trx_id
       AND   NVL(det.location_segment_id,-9999) = tax_link.location_segment_id
       AND   nvl(det.tax_code_id,-9999) = tax_link.tax_code_id
       AND   ctl.customer_trx_line_id   = tax_link.link_to_cust_trx_line_id
       AND   ctl.customer_trx_id        = det.ref_customer_trx_id
       and   decode(ctl.line_type,
                    'FREIGHT', ctl.link_to_cust_trx_line_id,  --first available tax code netexpense account
                    ctl.customer_trx_line_id) = b5.ae_link_to_cust_trx_line_id (+);

--              (-6, --Boundary line : -6
--               -7, --Boundary charge:-7
--               -8, --Boundary tax
--               -9); --Boundary freight

/*------------------------------------------------------------------------------+
 | Sum functions to set amount sums and counts required for decision making     |
 +------------------------------------------------------------------------------*/
  FOR l_get_group_data IN get_group_data_rev  LOOP

      IF l_get_group_data.ae_account_class = 'REVEARN' THEN

         g_ae_rev_ctr := l_get_group_data.ae_count;

       --Revenue total amounts and accounted amounts accumulator
          g_ae_rule_rec.revenue_amt       := l_get_group_data.sum_ae_amount;
          g_ae_rule_rec.revenue_acctd_amt := l_get_group_data.sum_ae_acctd_amount;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rev_ctr ' || g_ae_rev_ctr);
             arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.revenue_amt  = ' || g_ae_rule_rec.revenue_amt);
             arp_standard.debug('Get_Invoice_Distributions: ' ||
                                'g_ae_rule_rec.revenue_acctd_amt = ' || g_ae_rule_rec.revenue_acctd_amt);
          END IF;

      ELSIF l_get_group_data.ae_account_class = 'REVUNEARN' THEN

             g_ae_unearn_rev_ctr        := l_get_group_data.ae_count;

             g_sum_unearn_rev_amt       := l_get_group_data.sum_ae_amount;
             g_sum_unearn_rev_acctd_amt := l_get_group_data.sum_ae_acctd_amount;

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Get_Invoice_Distributions: ' ||
                                    'g_sum_unearn_rev_amt       = ' || g_sum_unearn_rev_amt);
                arp_standard.debug('Get_Invoice_Distributions: ' ||
                                   'g_sum_unearn_rev_acctd_amt = ' || g_sum_unearn_rev_acctd_amt);
             END IF;


      ELSIF l_get_group_data.ae_account_class = 'REVXREC' THEN

           null;
          /* g_ae_rule_rec.receivable_amt        := l_get_group_data.sum_ae_amount;
          g_ae_rule_rec.receivable_acctd_amt  := l_get_group_data.sum_ae_acctd_amount;

          g_ae_rule_rec.receivable_account    := l_get_group_data.ae_code_combination_id;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Get_Invoice_Distributions: ' ||
              'g_ae_rule_rec.receivable_amt = ' || g_ae_rule_rec.receivable_amt);
             arp_standard.debug('Get_Invoice_Distributions: ' ||
              'g_ae_rule_rec.receivable_acctd_amt = ' || g_ae_rule_rec.receivable_acctd_amt);
             arp_standard.debug('Get_Invoice_Distributions: ' ||
              'g_ae_rule_rec.receivable_account = ' || g_ae_rule_rec.receivable_account);
          END IF; */

      END IF;

  END LOOP;

/*---------------------------------------------------------------------------+
 | Total accumulators for Receivable account class, and receivable ccid      |
 |                                                                           |
 | Modified for MRC TRIGGER REPLACEMENT:  get data from source depending     |
 | on the sob type                                                           |
 +---------------------------------------------------------------------------*/

  IF (NVL(g_ae_sys_rec.sob_type,'P') =  'P') THEN
      SELECT amount,
             acctd_amount,
             code_combination_id
      INTO g_ae_rule_rec.receivable_amt,
           g_ae_rule_rec.receivable_acctd_amt,
           g_ae_rule_rec.receivable_account
      FROM ra_cust_trx_line_gl_dist
      where customer_trx_id = p_invoice_id
        AND account_class = 'REC'
        and latest_rec_flag = 'Y';
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.receivable_amt = ' ||
                      g_ae_rule_rec.receivable_amt);
     arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.receivable_acctd_amt = ' ||
                      g_ae_rule_rec.receivable_acctd_amt);
     arp_standard.debug('Get_Invoice_Distributions: ' ||
                        'g_ae_rule_rec.receivable_account = ' || g_ae_rule_rec.receivable_account);
  END IF;

/*------------------------------------------------------------------------------+
 | Ascertain as to whether the revenue adjustment api will be used to derive the|
 | revenue distributions and the code combinations using autoaccounting, to     |
 | allocate the line amounts to gl account source = 'REVENUE ON INVOICE' or     |
 | tax code source is none for tax amount.                                      |
 +------------------------------------------------------------------------------*/
/*IF ((g_sum_unearn_rev_amt <> 0) OR (g_sum_unearn_rev_acctd_amt <> 0)) THEN
       --
       --condition as to whether the RAM api will require to be called if gl account
       --source is revenue on invoice
       --
     IF (((g_ae_doc_rec.source_table = 'ADJ')
           AND (g_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE')
                AND (((nvl(p_adj_rec.line_adjusted,0) + nvl(p_adj_rec.freight_adjusted,0) +
                       nvl(p_adj_rec.receivables_charges_adjusted,0)) <> 0)
                     OR ((g_ae_rule_rec.tax_code_source1 = 'NONE') AND (nvl(p_adj_rec.tax_adjusted,0) <> 0))
                    ))
           OR
           ((g_ae_doc_rec.source_table = 'RA')
            AND (((g_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE')
                  AND (((nvl(p_app_rec.line_ediscounted,0) + nvl(p_app_rec.freight_ediscounted,0) +
                         nvl(p_app_rec.charges_ediscounted,0)) <> 0)
                         OR ((g_ae_rule_rec.tax_code_source1 = 'NONE') AND (nvl(p_app_rec.tax_ediscounted,0) <> 0))
                      ))
                 OR
                 ((g_ae_rule_rec.gl_account_source2 = 'REVENUE_ON_INVOICE')
                  AND (((nvl(p_app_rec.line_uediscounted,0) + nvl(p_app_rec.freight_uediscounted,0) +
                         nvl(p_app_rec.charges_uediscounted,0)) <> 0)
                        OR ((g_ae_rule_rec.tax_code_source2 = 'NONE') AND (nvl(p_app_rec.tax_uediscounted,0) <> 0))
                      ))
                ))
         )
     THEN --call revenue adjustment api
*/
   /*----------------------------------------------------------------------------+
    | Call the revenue adjustment api to derive the revenue distributions on the |
    | fly, to allocate the amounts for gl account source = revenue on Invoice.   |
    +----------------------------------------------------------------------------*/
/*
        l_rev_adj_rec.customer_trx_id := p_invoice_id;
        l_rev_adj_rec.reason_code     := 'ACCOUNTING';

        AR_Revenue_Adjustment_PVT.Earn_Revenue
              (   p_api_version           => 2
                 ,p_init_msg_list         => FND_API.G_TRUE
                 ,p_commit                => FND_API.G_FALSE
                 ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
                 ,x_return_status         => l_return_status
                 ,x_msg_count             => l_msg_count
                 ,x_msg_data              => l_msg_data
                 ,p_rev_adj_rec           => l_rev_adj_rec
                 ,x_adjustment_id         => l_adj_id
                 ,x_adjustment_number     => l_adj_number
                 ,x_dist_count            => l_dist_count
                 ,x_ra_dist_tbl           => l_ra_dist_tbl);

        IF l_ra_dist_tbl.EXISTS(l_dist_count) AND (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN

            FOR l_ctr2 IN l_ra_dist_tbl.FIRST .. l_ra_dist_tbl.LAST LOOP

              --process revenue distributions only
                IF l_ra_dist_tbl(l_ctr2).account_class = 'REV' THEN

                    l_ae_tax_id := '';
*/
                /*----------------------------------------------------------------------------+
                 |Unearn lines may have the tax code id set as they are associate with the    |
                 |original invoice lines, sweep through the unearned table for invoice lines  |
                 |which was the source for deriving the earned revenue using the rev adj api  |
                 +----------------------------------------------------------------------------*/
/*
                    IF g_ae_unearn_rev_ctr > 0
                      AND l_ra_dist_tbl(l_ctr2).account_class = 'REV' THEN

                    --later on convert this into a join between the dist temp table
                    --and the ar_ae_alloc_rec_gt table
                       FOR g_ae_alloc_unearn_rev_tbl IN
                              l_rev_unearn('REVUNEARN', l_ra_dist_tbl(l_ctr2).customer_trx_line_id) LOOP
                              l_ae_tax_id := g_ae_alloc_unearn_rev_tbl.ae_tax_id;
                              EXIT;

                       END LOOP; --unearned revenue table

                    END IF; --dist class is REV

                --Assign revenue lines and increment row counter
                    g_ae_rev_ctr := g_ae_rev_ctr + 1;

                --assign elements
                    g_ae_alloc_rev_tbl.ae_account_class   := 'REVEARN';
                    g_ae_alloc_rev_tbl.ae_tax_id          := l_ae_tax_id;
                    g_ae_alloc_rev_tbl.ae_customer_trx_id :=
                                                       l_ra_dist_tbl(l_ctr2).customer_trx_id;
                    g_ae_alloc_rev_tbl.ae_customer_trx_line_id  :=
                                                       l_ra_dist_tbl(l_ctr2).customer_trx_line_id;
                    g_ae_alloc_rev_tbl.ae_code_combination_id   :=
                                                       l_ra_dist_tbl(l_ctr2).code_combination_id;
                    g_ae_alloc_rev_tbl.ae_amount                := l_ra_dist_tbl(l_ctr2).amount;
                    g_ae_alloc_rev_tbl.ae_acctd_amount          := l_ra_dist_tbl(l_ctr2).acctd_amount;
                    g_ae_alloc_rev_tbl.ae_pro_amt               := 0;
                    g_ae_alloc_rev_tbl.ae_pro_acctd_amt         := 0;
                    g_ae_alloc_rev_tbl.ae_pro_taxable_amt       := 0;
                    g_ae_alloc_rev_tbl.ae_pro_taxable_acctd_amt := 0;
                    g_ae_alloc_rev_tbl.ae_pro_split_taxable_amt := '';
                    g_ae_alloc_rev_tbl.ae_pro_split_taxable_acctd_amt := '';
                    g_ae_alloc_rev_tbl.ae_pro_recov_taxable_amt := '';
                    g_ae_alloc_rev_tbl.ae_pro_recov_taxable_acctd_amt := '';
                    g_ae_alloc_rev_tbl.ae_pro_def_tax_amt       := 0;
                    g_ae_alloc_rev_tbl.ae_pro_def_tax_acctd_amt := 0;
                    g_ae_alloc_rev_tbl.ae_counted_flag          := 'N';

                    Assign_Elements(g_ae_alloc_rev_tbl);

                 --Revenue total amounts and accounted amounts accumulator
                    g_ae_rule_rec.revenue_amt       :=
                          g_ae_rule_rec.revenue_amt + g_ae_alloc_rev_tbl.ae_amount;
                    g_ae_rule_rec.revenue_acctd_amt :=
                          g_ae_rule_rec.revenue_acctd_amt + g_ae_alloc_rev_tbl.ae_acctd_amount;

                END IF; --revenue distributions only

            END LOOP; --end loop gl dist table from rev adj

         ELSIF ((l_return_status <> FND_API.G_RET_STS_SUCCESS)
                OR ((l_dist_count = 0) AND (l_return_status = FND_API.G_RET_STS_SUCCESS))) THEN

               IF l_msg_count > 1 THEN
                  fnd_msg_pub.reset;
                --get only the first message from the api message stack for forms users
                  l_mesg := fnd_msg_pub.get(p_encoded=>FND_API.G_FALSE);
               ELSE
                  l_mesg := l_msg_data;
               END IF;

             --Now set the message token
               FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
               FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_mesg);

               RAISE ram_api_error;

         END IF; --rev adj gl dist table exists and success from api

        --api Error handling

        --independent of the activity rule add the unearned entries to the revenue array,
        --to add to the sum of the line amount and accounted amount used as an allocation
        --basis to allocate amounts and formulate taxable amounts
       ELSE

          IF g_ae_unearn_rev_ctr > 0 THEN
*/
--             UPDATE /*+ INDEX(ar_ae_alloc_rec_gt AR_AE_ALLOC_REC_GT_N3 */ ar_ae_alloc_rec_gt
/*
             SET ae_account_class = 'REVEARN'
             WHERE ae_id = g_id
             AND   ae_account_class = 'REVUNEARN';

          --Add the unearned count to the revenue count
             g_ae_rev_ctr := g_ae_rev_ctr + g_ae_unearn_rev_ctr;

          --Add the unearned amounts to the revenue amounts
             g_ae_rule_rec.revenue_amt       :=
               g_ae_rule_rec.revenue_amt + g_sum_unearn_rev_amt;
             g_ae_rule_rec.revenue_acctd_amt :=
               g_ae_rule_rec.revenue_acctd_amt + g_sum_unearn_rev_acctd_amt;

          END IF; --unearned revenue entry exists

       END IF; --ram api is called to derive revenue distributions

   END IF; --there exists a non zero unearned amount or accounted amount
*/
 /*----------------------------------------------------------------------------------+
  | Set the tax link id's for the revenue lines - we do this here since ram api is   |
  | called after the insert of original revenue, hence all link ids set at one time. |
  +----------------------------------------------------------------------------------*/
   UPDATE /*+ INDEX(b1 AR_AE_ALLOC_REC_GT_N3) */
          ar_ae_alloc_rec_gt b1
   SET (b1.ae_tax_link_id, b1.ae_tax_link_id_ed_adj, b1.ae_tax_link_id_uned) =
        (select /*+ INDEX(b8 AR_AE_ALLOC_REC_GT_N3) */
                max(b8.ae_tax_link_id)        ae_tax_link_id,
                max(b8.ae_tax_link_id_ed_adj) ae_tax_link_id_ed_adj,
                max(b8.ae_tax_link_id_uned)   ae_tax_link_id_uned
             from ar_ae_alloc_rec_gt b8
             where b8.ae_id = g_id
             and   b8.ae_account_class = 'TAX'
             and   b8.ae_link_to_cust_trx_line_id = b1.ae_customer_trx_line_id)
   WHERE b1.ae_id = g_id
   AND   b1.ae_account_class IN ('REVEARN','REVUNEARN')  --MAINTAINTAXLINKID
   AND   EXISTS (select /*+ INDEX(b2 AR_AE_ALLOC_REC_GT_N3) */
                        'x'
                 from ar_ae_alloc_rec_gt b2
                 where b2.ae_id = g_id
                 and   b2.ae_account_class = 'TAX'
                 and   b2.ae_link_to_cust_trx_line_id = b1.ae_customer_trx_line_id);

 /*----------------------------------------------------------------------------------+
  | Get revenue amount totals, and fill up the revenue total table when tax code     |
  | source is NONE and there exists a tax amount to be allocated to gl account source|
  | Caches revenue amount and accounted amount totals for each Invoice Line, if      |
  | already cached then add to existing accumulators, totals for each Invoice        |
  | are required to be cached for rule allocating tax to revenue if TAX CODE         |
  | source is NONE.                                                                  |
  +----------------------------------------------------------------------------------*/

   IF (((g_ae_doc_rec.source_table = 'RA')
        AND (((nvl(p_app_rec.tax_ediscounted,0) <> 0) AND (g_ae_rule_rec.tax_code_source1 = 'NONE'))
             OR ((nvl(p_app_rec.tax_uediscounted,0) <> 0) AND (g_ae_rule_rec.tax_code_source2 = 'NONE'))))
       OR ((g_ae_doc_rec.source_table = 'ADJ') AND (g_ae_rule_rec.tax_code_source1 = 'NONE')
            AND (nvl(p_adj_rec.tax_adjusted,0) <> 0))) AND (g_ae_rev_ctr > 0)
   THEN

           UPDATE /*+ INDEX(at1 AR_AE_ALLOC_REC_GT_N3) */
                  ar_ae_alloc_rec_gt at1
           SET    (at1.ae_inv_line         ,
                   at1.ae_sum_rev_amt      ,
                   at1.ae_sum_rev_acctd_amt,
                   at1.ae_count) =
                     (SELECT /*+ INDEX(at2 AR_AE_ALLOC_REC_GT_N1) */
                             at2.ae_customer_trx_line_id,
                             sum(at2.ae_amount),
                             sum(at2.ae_acctd_amount),
                             count(at2.ae_customer_trx_line_id)
                      FROM ar_ae_alloc_rec_gt at2
                      WHERE at2.ae_id = g_id
                      AND   at2.ae_customer_trx_line_id = at1.ae_customer_trx_line_id
                      AND   at2.ae_account_class IN ('REVEARN','REVUNEARN') --MAINTAINTAXLINKID
                      GROUP BY at2.ae_customer_trx_line_id)
           WHERE at1.ae_id = g_id
           AND   at1.ae_account_class IN ('REVEARN','REVUNEARN'); --MAINTAINTAXLINKID

   END IF; --create revenue total table


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Get_Invoice_Distributions: ' ||
                         'g_ae_rule_rec.gl_account_source1    = '||g_ae_rule_rec.gl_account_source1);
      arp_standard.debug('Get_Invoice_Distributions: ' ||
                         'g_ae_rule_rec.tax_code_source1      = '||g_ae_rule_rec.tax_code_source1);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.tax_recoverable_flag1 = '||
                         g_ae_rule_rec.tax_recoverable_flag1);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.code_combination_id1  = '||
                         g_ae_rule_rec.code_combination_id1);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.asset_tax_code1       = '||
                         g_ae_rule_rec.asset_tax_code1);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.liability_tax_code1   = '||
                         g_ae_rule_rec.liability_tax_code1);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.act_tax_non_rec_ccid1 = '||
                         g_ae_rule_rec.act_tax_non_rec_ccid1);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.gl_account_source2    = '||
                         g_ae_rule_rec.gl_account_source2);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.tax_code_source2      = '||
                         g_ae_rule_rec.tax_code_source2);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.tax_recoverable_flag2 = '||
                         g_ae_rule_rec.tax_recoverable_flag2);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.code_combination_id2  = '||
                         g_ae_rule_rec.code_combination_id2);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.asset_tax_code2       = '||
                         g_ae_rule_rec.asset_tax_code2);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.liability_tax_code2   = '||
                         g_ae_rule_rec.liability_tax_code2);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.act_tax_non_rec_ccid2 = '||
                         g_ae_rule_rec.act_tax_non_rec_ccid2);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.receivable_account    = '||
                         g_ae_rule_rec.receivable_account);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.receivable_amt        = '||
                         g_ae_rule_rec.receivable_amt);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.receivable_acctd_amt  = '||
                         g_ae_rule_rec.receivable_acctd_amt);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.revenue_amt           = '||
                         g_ae_rule_rec.revenue_amt);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.revenue_acctd_amt     = '||
                         g_ae_rule_rec.revenue_acctd_amt);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.tax_amt               = '||
                         g_ae_rule_rec.tax_amt);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.tax_acctd_amt         = '||
                         g_ae_rule_rec.tax_acctd_amt);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.def_tax_amt           = '||
                         g_ae_rule_rec.def_tax_amt);
      arp_standard.debug('Get_Invoice_Distributions: ' || 'g_ae_rule_rec.def_tax_acctd_amt     = '||
                         g_ae_rule_rec.def_tax_acctd_amt);
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Invoice_Distributions()-');
  END IF;


EXCEPTION
  WHEN invalid_ccid_error THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Invalid Tax ccid - ARP_ALLOCATION_PKG.Get_Invoice_Distributions' );
     END IF;
     fnd_message.set_name('AR','AR_INVALID_TAX_ACCOUNT');
     RAISE;

  WHEN ram_api_error THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ram_api_error - ARP_ALLOCATION_PKG.Get_Invoice_Distributions' );
     END IF;
     RAISE;

  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_ALLOCATION_PKG.Get_Invoice_Distributions - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Get_Invoice_Distributions');
     END IF;
     RAISE;

END Get_Invoice_Distributions;

/* ==========================================================================
 | PROCEDURE Get_Tax_Link_Id
 |
 | DESCRIPTION
 |      Assigns Tax link Ids to each tax line in the tax table. The Rule
 |      assigining a tax link id is if for an Invoice line tax distribution
 |      there exists another tax distribution for an different Invoice line
 |      with the same Tax codes and count of Tax distributions for these
 |      Invoice lines then the Tax distributions of the first Invoice Line
 |      can be grouped with the Tax distributions of the second Invoice line.
 |      Tax link id can be common across different Invoice documents
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_type_acct         IN     Indicates accounting to be done for Earned
 |                                 discounts Adjustments or Unearned discounts
 *===========================================================================*/
PROCEDURE Get_Tax_Link_Id(p_process_ed_adj IN VARCHAR2,
                          p_process_uned   IN VARCHAR2,
                          p_process_pay    IN VARCHAR2) IS

l_link_ctr        BINARY_INTEGER := 0; --Actual Tax link id counter
l_link_ctr1       BINARY_INTEGER := 0; --In case earned and unearned require link id

l_gl_account_source    ar_receivables_trx.gl_account_source%TYPE    ;
l_tax_code_source      ar_receivables_trx.tax_code_source%TYPE      ;
l_tax_recoverable_flag ar_receivables_trx.tax_recoverable_flag%TYPE ;

cursor get_tax IS
select /*+ INDEX(ar_ae_alloc_rec_gt AR_AE_ALLOC_REC_GT_N3) */
      ae_link_to_cust_trx_line_id
from ar_ae_alloc_rec_gt
where ae_id = g_id
and ae_account_class = 'TAX'
group by ae_link_to_cust_trx_line_id
order by ae_link_to_cust_trx_line_id;

inv_line_tbl  DBMS_SQL.NUMBER_TABLE;

l_last_fetch BOOLEAN := FALSE;
l_mirror_link_ctr VARCHAR2(1) := 'N';
l_set_ed_adj_link VARCHAR2(1) := 'N';
l_set_uned_link   VARCHAR2(1) := 'N';
l_set_pay_link    VARCHAR2(1) := 'N';

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Tax_Link_Id()+');
   END IF;

   l_link_ctr := g_link_ctr;

  -----------------------------------------------------------------------------
  --Set earned discount and adjustment link flag
  -----------------------------------------------------------------------------
   IF ((p_process_ed_adj = 'Y') AND (g_ed_adj_activity_link = 0)) THEN
      l_set_ed_adj_link := 'Y';
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Get_Tax_Link_Id: ' || ' l_set_ed_adj_link ' || l_set_ed_adj_link);
      END IF;
   END IF;

  -----------------------------------------------------------------------------
  --Set unearned discount link flag
  -----------------------------------------------------------------------------
   IF ((p_process_uned = 'Y') AND (g_uned_activity_link = 0)) THEN
      l_set_uned_link := 'Y';
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Get_Tax_Link_Id: ' || ' l_set_uned_link ' || l_set_uned_link);
      END IF;
   END IF;

  -----------------------------------------------------------------------------
  --Set payment link flag to calculate taxable amounts for deferred tax
  -----------------------------------------------------------------------------
   IF p_process_pay = 'Y' THEN
      l_set_pay_link := 'Y';
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Get_Tax_Link_Id: ' || 'l_set_pay_link ' || l_set_pay_link);
      END IF;
   END IF;

  -----------------------------------------------------------------------------
  --Set the mirror link counter since seperate links maintained for discounts
  --earned and unearned
  -----------------------------------------------------------------------------
   IF l_set_ed_adj_link = 'Y' AND l_set_uned_link = 'Y' THEN
      l_mirror_link_ctr := 'Y';
      l_link_ctr1 := l_link_ctr + g_ae_tax_ctr + 1;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Get_Tax_Link_Id: ' || 'l_mirror_link_ctr ' || l_mirror_link_ctr);
         arp_standard.debug('Get_Tax_Link_Id: ' || ' l_link_ctr1 ' || l_link_ctr1);
      END IF;
   END IF;

  -----------------------------------------------------------------------------
  --Verify as to whether links require to be created
  -----------------------------------------------------------------------------
   IF (g_ae_tax_ctr > 0)
      AND ((l_set_ed_adj_link = 'Y') OR (l_set_uned_link = 'Y') OR (l_set_pay_link = 'Y'))
   THEN
  /*-------------------------------------------------------------------------------+
   | Link basis for tax code source other than ACTIVITY tax code is off the tax on |
   | the Invoice (Tax distribitions on Invoice) so this processing is required.    |
   | Set the tax line counts for each tax distribution associated with Invoice line|
   +-------------------------------------------------------------------------------*/
      OPEN get_tax;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Get_Tax_Link_Id: ' || 'Opened get_tax Cursor ');
      END IF;

      LOOP
      --initialize record

        FETCH get_tax BULK COLLECT INTO
        inv_line_tbl
        LIMIT g_bulk_fetch_rows;

       IF get_tax%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

       IF (inv_line_tbl.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Get_Tax_Link_Id: ' || 'COUNT = 0 and LAST FETCH ');
         END IF;
         EXIT;
       END IF;

       FOR i IN inv_line_tbl.FIRST .. inv_line_tbl.LAST LOOP

        --replace with a function

             IF ((l_set_pay_link = 'Y') OR (l_set_ed_adj_link = 'Y')
                  OR ((l_set_uned_link = 'Y') AND (l_mirror_link_ctr = 'N'))) THEN
                  l_link_ctr := l_link_ctr + 1;
             END IF;

             IF ((l_set_uned_link = 'Y') AND (l_mirror_link_ctr = 'Y')) THEN
                l_link_ctr1 := l_link_ctr1 + 1;
             END IF;

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Get_Tax_Link_Id: ' || 'Link Id l_link_ctr  ' || l_link_ctr);
                arp_standard.debug('Get_Tax_Link_Id: ' || 'Link Id l_link_ctr1 ' || l_link_ctr1);
                arp_standard.debug('Get_Tax_Link_Id: ' ||  'inv_line_tbl(' || i || ') = '|| inv_line_tbl(i));
             END IF;

             update /*+ INDEX(art3 AR_AE_ALLOC_REC_GT_N4) */
                   ar_ae_alloc_rec_gt art3
             set art3.ae_tax_link_id        = decode(l_set_pay_link,
                                                     'Y', l_link_ctr,
                                                     ''),
                 art3.ae_tax_link_id_ed_adj = decode(l_set_ed_adj_link,
                                                     'Y', l_link_ctr,
                                                     art3.ae_tax_link_id_ed_adj),
                 art3.ae_tax_link_id_uned   = decode(l_set_uned_link,
                                                     'Y', decode(l_mirror_link_ctr,
                                                                 'Y', l_link_ctr1,
                                                                 l_link_ctr),
                                                     art3.ae_tax_link_id_uned),
                 art3.ae_counted_flag       = 'Y'
             where ae_id = g_id
             and art3.ae_account_class = 'TAX'
             and art3.ae_counted_flag = 'N'
             and art3.ae_link_to_cust_trx_line_id IN
             (select to_line
             from(
             select /*+ INDEX(art1 AR_AE_ALLOC_REC_GT_N4) INDEX(art2 AR_AE_ALLOC_REC_GT_N2) */
                    art1.ae_link_to_cust_trx_line_id            from_line      ,
                    art2.ae_link_to_cust_trx_line_id            to_line        ,
                    max(art1.ae_tax_line_count)                 tax_line_count ,
                    1                                           hit_count
             from ar_ae_alloc_rec_gt art1,
                  ar_ae_alloc_rec_gt art2
             where art1.ae_id = g_id
             and   art1.ae_account_class            = 'TAX'
             and   art1.ae_account_class            = art2.ae_account_class
             and   art1.ae_tax_id                   = art2.ae_tax_id
             and   art1.ae_tax_type                 = art2.ae_tax_type
             and   art1.ae_tax_line_count           = art2.ae_tax_line_count
             and   art1.ae_link_to_cust_trx_line_id = inv_line_tbl(i)
             --and   art1.ae_link_to_cust_trx_line_id <> art2.ae_link_to_cust_trx_line_id
             and   art2.ae_id = art1.ae_id
             and   art1.ae_counted_flag = 'N'
             and   art2.ae_counted_flag = 'N'
             group by art1.ae_link_to_cust_trx_line_id,
                      art2.ae_link_to_cust_trx_line_id,
                      art1.ae_tax_id,
                      art1.ae_tax_type)
             group by from_line, to_line
             having sum(hit_count) = max(tax_line_count));

             IF SQL%NOTFOUND THEN
                IF ((l_set_pay_link = 'Y') OR (l_set_ed_adj_link = 'Y')
                     OR ((l_set_uned_link = 'Y') AND (l_mirror_link_ctr = 'N'))) THEN
                     l_link_ctr := l_link_ctr - 1;
                END IF;

                IF ((l_set_uned_link = 'Y') AND (l_mirror_link_ctr = 'Y')) THEN
                   l_link_ctr1 := l_link_ctr1 - 1;
                END IF;

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('Get_Tax_Link_Id: ' || 'Reversed Link Id l_link_ctr  ' || l_link_ctr);
                   arp_standard.debug('Get_Tax_Link_Id: ' || 'Reversed Link Id l_link_ctr1 ' || l_link_ctr1);
                END IF;
             END IF;

         END LOOP; --sweep tax lines to formulate link

       --Exit if Last fetch
         IF l_last_fetch THEN
            EXIT;
         END IF;

        END LOOP; --process revenue tax bulk fetch

        CLOSE get_tax;

   END IF; --End if tax code source is ACTIVITY

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Tax_Link_Id()-');
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Get_Tax_Link_Id: ' || 'SQLERRM ' || SQLERRM);
        arp_standard.debug('ARP_ALLOCATION_PKG.Get_Tax_Link_Id - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Get_Tax_Link_Id: ' || 'SQLERRM ' || SQLERRM);
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Get_Tax_Link_Id');
     END IF;
     RAISE;

END Get_Tax_Link_Id;

/* ==========================================================================
 | PROCEDURE Override_Accounts
 |
 | DESCRIPTION
 |      Sets the Override account flags for earned discounts, adjustments
 |      unearned discounts
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_app_rec       IN    Earned and Unearned discount details
 |      p_adj_rec       IN    Adjustment details
 |      p_override1     IN    Override Earned discount/Adjustment account
 |      p_override2     IN    Override Unearned discount account
 *==========================================================================*/
PROCEDURE Override_Accounts(p_app_rec   IN  ar_receivable_applications%ROWTYPE,
                            p_adj_rec   IN  ar_adjustments%ROWTYPE,
                            p_override1 OUT NOCOPY  VARCHAR2,
                            p_override2 OUT NOCOPY VARCHAR2 ) IS
BEGIN
     /*------------------------------------------------------------------------------+
      | Set the override flagse for earned discounts/adjustments, unearned discounts |
      | as default FALSE                                                             |
      +------------------------------------------------------------------------------*/
       p_override1 := 'N';
       p_override2 := 'N';

     /*------------------------------------------------------------------------------+
      | Override revenue accounts for discounts and adjustments                      |
      +------------------------------------------------------------------------------*/
       IF g_ae_rule_rec.gl_account_source1 IN ('ACTIVITY_GL_ACCOUNT', 'TAX_CODE_ON_INVOICE') THEN

        /*------------------------------------------------------------------------------+
         | Override revenue account using first net expense account from tax for earned |
         | discounts.                                                                   |
         +------------------------------------------------------------------------------*/
          IF (g_ae_doc_rec.source_table = 'RA')
              AND (((nvl(p_app_rec.line_ediscounted,0) + nvl(p_app_rec.freight_ediscounted,0) +
                    nvl(p_app_rec.charges_ediscounted,0)) <> 0)
                   OR ((g_ae_rule_rec.tax_code_source1 = 'NONE') AND (nvl(p_app_rec.tax_ediscounted,0) <> 0)))
          THEN
             p_override1 := 'Y';

        /*------------------------------------------------------------------------------+
         | Override revenue account using first net expense account from tax for        |
         | adjustments.                                                                 |
         +------------------------------------------------------------------------------*/
          ELSIF g_ae_doc_rec.source_table = 'ADJ' AND g_ae_doc_rec.document_type = 'ADJUSTMENT'
               AND (((nvl(p_adj_rec.line_adjusted,0) + nvl(p_adj_rec.freight_adjusted,0) +
                      nvl(p_adj_rec.receivables_charges_adjusted,0)) <> 0)
                    OR ((g_ae_rule_rec.tax_code_source1 = 'NONE') AND (nvl(p_adj_rec.tax_adjusted,0) <> 0)))
               THEN
                   p_override1 := 'Y';

        /*------------------------------------------------------------------------------+
         | Override revenue account using first net expense account from tax for        |
         | finance charges.                                                             |
         +------------------------------------------------------------------------------*/
          ELSIF g_ae_doc_rec.source_table = 'ADJ' AND g_ae_doc_rec.document_type = 'FINANCE_CHARGES'
               AND (((nvl(p_adj_rec.line_adjusted,0) + nvl(p_adj_rec.freight_adjusted,0) +
                      nvl(p_adj_rec.receivables_charges_adjusted,0)) <> 0)
                    OR ((g_ae_rule_rec.tax_code_source1 = 'NONE') AND (nvl(p_adj_rec.tax_adjusted,0) <> 0)))
               THEN
                  p_override1 := 'Y';
          END IF;

       END IF; --End if TAX_CODE_ON_INVOICE for earned discounts, adjustments

     /*------------------------------------------------------------------------------+
      | Override revenue account using first net expense account from tax for        |
      | unearned discounts.                                                          |
      +------------------------------------------------------------------------------*/
       IF g_ae_rule_rec.gl_account_source2 IN ('ACTIVITY_GL_ACCOUNT', 'TAX_CODE_ON_INVOICE') THEN
          IF (g_ae_doc_rec.source_table = 'RA')
              AND (((nvl(p_app_rec.line_uediscounted,0) + nvl(p_app_rec.freight_uediscounted,0) +
                     nvl(p_app_rec.charges_uediscounted,0)) <> 0)
                   OR ((g_ae_rule_rec.tax_code_source2 = 'NONE') AND (nvl(p_app_rec.tax_uediscounted,0) <> 0)))
          THEN
             p_override2 := 'Y';

          END IF; --override enable condition

        END IF; --tax code on invoice for unearned discounts

      --set the global variables to be used in Build_Rev
        g_override1 := p_override1;
        g_override2 := p_override2;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Override_Accounts ');
     END IF;
     RAISE;

END Override_Accounts;

/* ==========================================================================
 | PROCEDURE Process_Amounts
 |
 | DESCRIPTION
 |      Allocates discounts or adjustments over Revenue and Tax distributions
 |      based on Rules set up at receivable activity level.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_type_acct          IN  Flag to indicate accounting for Earned
 |                               discounts Adjustments or Unearned discounts
 *==========================================================================*/
PROCEDURE Process_Amounts(p_app_rec   IN ar_receivable_applications%ROWTYPE,
                          p_adj_rec   IN ar_adjustments%ROWTYPE) IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Process_Amounts()+');
  END IF;

/*------------------------------------------------------------------------------+
 | Initialise revenue amounts to allocate for discounts or adjustments          |
 +------------------------------------------------------------------------------*/
/*
  Init_Amts(p_type_acct         => p_type_acct,
            p_app_rec           => p_app_rec  ,
            p_adj_rec           => p_adj_rec   );
*/
--}

/*------------------------------------------------------------------------------+
 | Build gross to activity gl account, for payments where deferred tax exists   |
 | this routine is never called and the else block is executed                  |
 +------------------------------------------------------------------------------*/
 /*
  IF (((p_type_acct = 'ED_ADJ') AND (g_ae_rule_rec.gl_account_source1 = 'ACTIVITY_GL_ACCOUNT')
        AND (g_ae_rule_rec.tax_code_source1 = 'NONE'))
      OR ((p_type_acct = 'UNED') AND (g_ae_rule_rec.gl_account_source2 = 'ACTIVITY_GL_ACCOUNT')
           AND (g_ae_rule_rec.tax_code_source2 = 'NONE')))
     AND ((NOT g_ae_def_tax) AND (g_done_def_tax)) THEN

      Gross_To_Activity_GL(p_type_acct => p_type_acct);

  ELSE
  */
  --}
   /*---------------------------------------------------------------------------------+
    | Allocate discount, adjustment, finance charge amounts over tax. Tax is allocated|
    | if there is either an amount or accounted amount tax base in this case if the   |
    | tax rule is NONE then only deferred tax treatment is done with tax going to line|
    | buckets for allocation otherwise.                                               |
    +---------------------------------------------------------------------------------*/
   --  Alloc_Rev_Tax_Amt(p_type_acct => p_type_acct) ;
   --}
    /*------------------------------------------------------------------------------+
     | Allocate Tax to Revenue. When processing reaches this point then it means    |
     | there exists zero or non zero revenue lines so allocate tax to revenue. For  |
     | payments there is no need to allocate tax to revenue as the deferred tax is  |
     | only required to be moved.                                                   |
     +------------------------------------------------------------------------------*/
/*
      IF ((g_ae_tax_ctr > 0)
           AND ((g_ae_rule_rec.tax_amt_alloc <> 0)
                OR (g_ae_rule_rec.tax_acctd_amt_alloc <> 0))
           AND ((NOT g_bound_tax) AND (NOT g_bound_activity)))
         AND (p_type_acct <> 'PAY')
      THEN

         Allocate_Tax_To_Rev(p_type_acct   => p_type_acct);

      END IF;
*/
   /*---------------------------------------------------------------------------------+
    | Set actual link ids for Revenue and Tax lines. Where revenue amounts are zero   |
    | this routine will not get executed as there is no revenue to link to, so link id|
    | for revenue and tax allocations is null.
    +---------------------------------------------------------------------------------*/
-- Set_link_Id needs to be executed every time
-- because it allows to TAX line to tie to the Revenue associated
-- in 11i we use a special sequence to tie tax line to the revenue line alone with summarization
-- in 11iX we use the each tax line should be tied individualy to its revnue line related
-- we use the link_to_cust_trx_line_id
-- The tax link line id only concerns activity on tax invoice disctributions
-- In the case of distribution affected to TAX, the actual link to tax id is
-- link_to_cust_trx_line_id if there is a distribution affected to 'REV' with the
-- ref_customer_trx_line_id equals to the link_to_cust_trx_line_id of the tax distribution
-- In the case of disctribution affected to REV, the actual link to tax id is
-- the ref_customer_trx_line_id if there is a link_to_cust_trx_line_id of a tax distribution
-- equals to it
--
--     IF (g_ae_tax_ctr > 0) AND (g_ae_rev_ctr > 0)
--        AND (NOT g_bound_tax) AND (NOT g_bound_activity) AND (p_type_acct <> 'PAY') THEN

      /*---------------------------------------------------------------------------------+
       | Set actual link ids for Revenue lines with non zero amounts or accounted amounts|
       +---------------------------------------------------------------------------------*/
        Set_Rev_Links(p_type_acct => 'ANYTHING');

--     END IF;
--}
   /*------------------------------------------------------------------------------+
    | Build Revenue and Tax Lines based on rules                                   |
    +------------------------------------------------------------------------------*/
     Build_Lines; --(p_type_acct    => p_type_acct );

--  END IF; --Gross to activity GL Account

/*------------------------------------------------------------------------------+
 | Only for discount and adjustment amounts to be accounted, the rule columns   |
 | need to be updated with Rule used.If there is just a payment then the rule   |
 | information is not maintained.                                               |
 +------------------------------------------------------------------------------*/
  IF (((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.earned_discount_taken,0) <> 0))
       OR ((g_ae_doc_rec.source_table = 'ADJ') AND (nvl(p_adj_rec.amount,0) <> 0))
       OR ((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.unearned_discount_taken,0) <> 0))) THEN

/*------------------------------------------------------------------------------+
 | For payments do not call the document rule routine as this is not required   |
 +------------------------------------------------------------------------------*/
   -- This is part of avoiding calling process_amount for ED_ADJ and UNED and PAY
   IF    ((g_ae_doc_rec.source_table = 'ADJ') AND (nvl(p_adj_rec.amount,0) <> 0))
      OR ((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.earned_discount_taken,0) <> 0))
   THEN

     Doc_Tax_Acct_Rule(p_type_acct => 'ED_ADJ',
                       p_app_rec   => p_app_rec  ,
                       p_adj_rec   => p_adj_rec   );
   END IF;

   IF    ((g_ae_doc_rec.source_table = 'RA') AND (nvl(p_app_rec.unearned_discount_taken,0) <> 0))
   THEN
     Doc_Tax_Acct_Rule(p_type_acct => 'UNED',
                       p_app_rec   => p_app_rec  ,
                       p_adj_rec   => p_adj_rec   );
   END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Process_Amounts()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Process_Amounts');
     END IF;
     RAISE;

END Process_Amounts;

/* ==========================================================================
 | PROCEDURE Doc_Tax_Acct_Rule
 |
 | DESCRIPTION
 |      Updates the discount or adjustment with the accounting Rule used to
 |      allocate the line, tax, freight charges to required accounts. This
 |      helps in keeping a history of which rule was used as accounts for a
 |      receivable activity can change. The rule used and the amount buckets
 |      for the discount or adjustment can then be used to determine the nature
 |      of the accounting if required.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_type_acct          IN  Flag to indicate accounting for Earned
 |                               discounts Adjustments or Unearned discounts
 |      p_app_rec            IN  Receivable Application detail record
 |      p_adj_rec            IN  Adjustment detail record
 *==========================================================================*/
PROCEDURE Doc_Tax_Acct_Rule(p_type_acct IN VARCHAR2                           ,
                            p_app_rec   IN ar_receivable_applications%ROWTYPE ,
                            p_adj_rec   IN ar_adjustments%ROWTYPE              ) IS

l_gl_account_source    ar_receivables_trx.gl_account_source%TYPE    ;
l_tax_code_source      ar_receivables_trx.tax_code_source%TYPE      ;
l_tax_recoverable_flag ar_receivables_trx.tax_recoverable_flag%TYPE ;
l_rule_used            VARCHAR2(3);

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Doc_Tax_Acct_Rule()+');
  END IF;

 /*-------------------------------------------------------------------------------+
  | Get Rules so that parent discount or adjustment record can be updated with the|
  | Rule details.                                                                 |
  +-------------------------------------------------------------------------------*/
   Get_Rules(p_type_acct            => p_type_acct,
             p_gl_account_source    => l_gl_account_source,
             p_tax_code_source      => l_tax_code_source,
             p_tax_recoverable_flag => l_tax_recoverable_flag);

 /*---------------------------------------------------------------------------------+
  | Set up 1 out of 12 possible Rules that could be setup for a receivable activity.|
  +--------------------------------------------------------------------------------*/
   IF (l_gl_account_source = 'ACTIVITY_GL_ACCOUNT') AND (l_tax_code_source = 'INVOICE')
      AND (l_tax_recoverable_flag = 'Y') THEN

      l_rule_used := '31';

   ELSIF (l_gl_account_source = 'ACTIVITY_GL_ACCOUNT') AND (l_tax_code_source = 'INVOICE')
         AND (l_tax_recoverable_flag = 'N') THEN

         l_rule_used := '32';

   ELSIF (l_gl_account_source = 'ACTIVITY_GL_ACCOUNT') AND (l_tax_code_source = 'NONE') THEN

          l_rule_used := '33';

   ELSIF (l_gl_account_source = 'ACTIVITY_GL_ACCOUNT') AND (l_tax_code_source = 'ACTIVITY') THEN

         l_rule_used := '34';

   ELSIF (l_gl_account_source = 'TAX_CODE_ON_INVOICE') AND (l_tax_code_source = 'INVOICE')
         AND (l_tax_recoverable_flag = 'Y') THEN

         l_rule_used := '21';

   ELSIF (l_gl_account_source = 'TAX_CODE_ON_INVOICE') AND (l_tax_code_source = 'INVOICE')
         AND (l_tax_recoverable_flag = 'N') THEN

         l_rule_used := '22';

   ELSIF (l_gl_account_source = 'TAX_CODE_ON_INVOICE') AND (l_tax_code_source = 'NONE') THEN

         l_rule_used := '23';

   ELSIF (l_gl_account_source = 'TAX_CODE_ON_INVOICE') AND (l_tax_code_source = 'ACTIVITY') THEN

         l_rule_used := '24';

   ELSIF (l_gl_account_source = 'REVENUE_ON_INVOICE') AND (l_tax_code_source = 'INVOICE')
         AND (l_tax_recoverable_flag = 'Y') THEN

         l_rule_used := '11';

   ELSIF (l_gl_account_source = 'REVENUE_ON_INVOICE') AND (l_tax_code_source = 'INVOICE')
         AND (l_tax_recoverable_flag = 'N') THEN

         l_rule_used := '12';

   ELSIF (l_gl_account_source = 'REVENUE_ON_INVOICE') AND (l_tax_code_source = 'NONE') THEN

         l_rule_used := '13';

   ELSIF (l_gl_account_source = 'REVENUE_ON_INVOICE') AND (l_tax_code_source = 'ACTIVITY') THEN

         l_rule_used := '14';

   END IF;

   l_rule_used := l_rule_used || g_ovrrd_code;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Doc_Tax_Acct_Rule: ' || 'Rule being used being updated ' || l_rule_used);
   END IF;

 /*-------------------------------------------------------------------------------+
  | Update the correct bucket with Rule used for a discount or an adjustment      |
  +-------------------------------------------------------------------------------*/
   IF ((g_ae_doc_rec.source_table = 'RA') AND (p_type_acct = 'ED_ADJ')) THEN

      UPDATE ar_receivable_applications
      SET    edisc_tax_acct_rule = l_rule_used
      WHERE  receivable_application_id = g_ae_doc_rec.source_id;

   ELSIF ((g_ae_doc_rec.source_table = 'ADJ') AND (p_type_acct = 'ED_ADJ')) THEN
         /* Bug 5659539 - When ccid is overriden while creating adjustment thru API,
          overriden ccid should be considered, but not from activities setup(adj_code_combination_id)
	This is done by checking if created_from is ADJ_API or not in update stmt. */

         UPDATE ar_adjustments
         SET    adj_tax_acct_rule = l_rule_used,
                -- code_combination_id = nvl(adj_code_combination_id, code_combination_id)
		code_combination_id = DECODE(created_from,
                                             'ADJ_API', nvl(code_combination_id, adj_code_combination_id),
                                             nvl(adj_code_combination_id, code_combination_id)
                                            )
         WHERE  adjustment_id = g_ae_doc_rec.source_id;

   ELSIF ((g_ae_doc_rec.source_table = 'RA') AND (p_type_acct = 'UNED')) THEN

         UPDATE ar_receivable_applications
         SET    unedisc_tax_acct_rule = l_rule_used
         WHERE  receivable_application_id = g_ae_doc_rec.source_id;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Doc_Tax_Acct_Rule()-');
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_ALLOCATION_PKG.Doc_Tax_Acct_Rule- NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Doc_Tax_Acct_Rule');
     END IF;
     RAISE;

END Doc_Tax_Acct_Rule;

/* ==========================================================================
 | PROCEDURE Init_Amts
 |
 | DESCRIPTION
 |      Sets amounts and accounted amount base for line, tax, freight,charges
 |      from buckets of the Receivable application or adjustment.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_type_acct          IN  Flag to indicate accounting for Earned
 |                               discounts Adjustments or Unearned discounts
 *==========================================================================*/
PROCEDURE Init_Amts( p_type_acct    IN VARCHAR2                       ,
                     p_app_rec      IN ar_receivable_applications%ROWTYPE,
                     p_adj_rec      IN ar_adjustments%ROWTYPE ) IS

CURSOR chk_tax_chrg(p_cust_id IN NUMBER) IS
       select 1
       from dual
       where exists(select 'x'
                    from ar_adjustments
                    where type = 'CHARGES'
                    and nvl(tax_adjusted,0) <> 0
                    and status = 'A'
                    and customer_trx_id = p_cust_id);

l_gl_account_source    ar_receivables_trx.gl_account_source%TYPE    ;
l_tax_code_source      ar_receivables_trx.tax_code_source%TYPE      ;
l_tax_recoverable_flag ar_receivables_trx.tax_recoverable_flag%TYPE ;
l_customer_trx_id NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Init_Amts()+');
  END IF;

/*---------------------------------------------------------------------------+
 | When called from is the Wrapper routine for Bills Receivable, then the    |
 | initialization is not required to be done. This is because the bucket     |
 | amounts are set by the Wrapper routine                                    |
 +---------------------------------------------------------------------------*/
    IF (nvl(g_ae_doc_rec.called_from,'NONE') <> 'WRAPPER') THEN

       g_ae_rule_rec.line_amt_alloc            := 0;
       g_ae_rule_rec.line_acctd_amt_alloc      := 0;
       g_ae_rule_rec.tax_amt_alloc             := 0;
       g_ae_rule_rec.tax_acctd_amt_alloc       := 0;
       g_ae_rule_rec.freight_amt_alloc         := 0;
       g_ae_rule_rec.freight_acctd_amt_alloc   := 0;
       g_ae_rule_rec.charges_amt_alloc         := 0;
       g_ae_rule_rec.charges_acctd_amt_alloc   := 0;

    END IF;

  g_orig_line_amt_alloc := 0;
  g_orig_line_acctd_amt_alloc := 0;

  g_bound_tax      := FALSE;
  g_bound_activity := FALSE;
  g_added_tax      := FALSE;
  g_ovrrd_code     := '';

 /*-------------------------------------------------------------------------------+
  | Get Rules so that parent discount or adjustment record can be updated with the|
  | Rule details.                                                                 |
  +-------------------------------------------------------------------------------*/
   Get_Rules(p_type_acct            => p_type_acct,
             p_gl_account_source    => l_gl_account_source,
             p_tax_code_source      => l_tax_code_source,
             p_tax_recoverable_flag => l_tax_recoverable_flag);

/*------------------------------------------------------------------------------+
 | Set amounts and accounted amounts to allocate for Earned discounts           |
 +------------------------------------------------------------------------------*/

  IF ((p_type_acct = 'ED_ADJ') AND (g_ae_doc_rec.source_table = 'RA')
      AND (nvl(p_app_rec.earned_discount_taken,0) <> 0)) THEN

     g_ae_rule_rec.tax_amt_alloc       := nvl(p_app_rec.tax_ediscounted,0)     * -1;
     g_ae_rule_rec.charges_amt_alloc   := nvl(p_app_rec.charges_ediscounted,0) * -1;
     g_ae_rule_rec.line_amt_alloc      := nvl(p_app_rec.line_ediscounted,0)    * -1;
     g_ae_rule_rec.freight_amt_alloc   := nvl(p_app_rec.freight_ediscounted,0) * -1;

    arp_util.Set_Buckets(
                  p_header_acctd_amt   => nvl(p_app_rec.acctd_earned_discount_taken,0) * -1 ,
                  p_base_currency      => g_ae_sys_rec.base_currency                        ,
                  p_exchange_rate      => g_cust_inv_rec.exchange_rate                      ,
                  p_base_precision     => g_ae_sys_rec.base_precision                       ,
                  p_base_min_acc_unit  => g_ae_sys_rec.base_min_acc_unit                    ,
                  p_tax_amt            => g_ae_rule_rec.tax_amt_alloc                       ,
                  p_charges_amt        => g_ae_rule_rec.charges_amt_alloc                   ,
                  p_line_amt           => g_ae_rule_rec.line_amt_alloc                      ,
                  p_freight_amt        => g_ae_rule_rec.freight_amt_alloc                   ,
                  p_tax_acctd_amt      => g_ae_rule_rec.tax_acctd_amt_alloc                 ,
                  p_charges_acctd_amt  => g_ae_rule_rec.charges_acctd_amt_alloc             ,
                  p_line_acctd_amt     => g_ae_rule_rec.line_acctd_amt_alloc                ,
                  p_freight_acctd_amt  => g_ae_rule_rec.freight_acctd_amt_alloc               );

     Dump_Init_Amts(p_type_acct => p_type_acct,
                    p_app_rec   => p_app_rec  ,
                    p_adj_rec   => p_adj_rec   );

  --Check Accounted Amounts for reconciliation with header accounted amount
     IF ((g_ae_rule_rec.line_acctd_amt_alloc  +
           g_ae_rule_rec.tax_acctd_amt_alloc     +
             g_ae_rule_rec.freight_acctd_amt_alloc  +
                g_ae_rule_rec.charges_acctd_amt_alloc) <> (nvl(p_app_rec.acctd_earned_discount_taken,0) * -1))
     THEN

        RAISE rounding_error;

     END IF;

/*-----------------------------------------------------------------------------------+
 | Set amounts and accounted amounts to allocate for Adjustments and Finance charges.|
 +-----------------------------------------------------------------------------------*/
  ELSIF ((p_type_acct = 'ED_ADJ') AND (g_ae_doc_rec.source_table = 'ADJ')
          AND (nvl(p_adj_rec.amount,0) <> 0))  THEN

/*---------------------------------------------------------------------------+
 | When called from the Wrapper routine for Bills Receivable, the            |
 | bucket amounts are set by the Wrapper, so its not necessary to set it here|
 +---------------------------------------------------------------------------*/
     IF (nvl(g_ae_doc_rec.called_from,'NONE') <> 'WRAPPER') THEN

        g_ae_rule_rec.tax_amt_alloc       := nvl(p_adj_rec.tax_adjusted,0);
        g_ae_rule_rec.charges_amt_alloc   := nvl(p_adj_rec.receivables_charges_adjusted,0);
        g_ae_rule_rec.line_amt_alloc      := nvl(p_adj_rec.line_adjusted,0);
        g_ae_rule_rec.freight_amt_alloc   := nvl(p_adj_rec.freight_adjusted,0);

        arp_util.Set_Buckets(
                     p_header_acctd_amt   => nvl(p_adj_rec.acctd_amount,0)                     ,
                     p_base_currency      => g_ae_sys_rec.base_currency                        ,
                     p_exchange_rate      => g_cust_inv_rec.exchange_rate                      ,
                     p_base_precision     => g_ae_sys_rec.base_precision                       ,
                     p_base_min_acc_unit  => g_ae_sys_rec.base_min_acc_unit                    ,
                     p_tax_amt            => g_ae_rule_rec.tax_amt_alloc                       ,
                     p_charges_amt        => g_ae_rule_rec.charges_amt_alloc                   ,
                     p_line_amt           => g_ae_rule_rec.line_amt_alloc                      ,
                     p_freight_amt        => g_ae_rule_rec.freight_amt_alloc                   ,
                     p_tax_acctd_amt      => g_ae_rule_rec.tax_acctd_amt_alloc                 ,
                     p_charges_acctd_amt  => g_ae_rule_rec.charges_acctd_amt_alloc             ,
                     p_line_acctd_amt     => g_ae_rule_rec.line_acctd_amt_alloc                ,
                     p_freight_acctd_amt  => g_ae_rule_rec.freight_acctd_amt_alloc               );
     END IF;

     Dump_Init_Amts(p_type_acct => p_type_acct,
                    p_app_rec   => p_app_rec  ,
                    p_adj_rec   => p_adj_rec   );

  --Check Accounted Amounts for reconciliation with header accounted amount
     IF ((g_ae_rule_rec.line_acctd_amt_alloc    +
             g_ae_rule_rec.tax_acctd_amt_alloc     +
                g_ae_rule_rec.freight_acctd_amt_alloc  +
                  g_ae_rule_rec.charges_acctd_amt_alloc) <> nvl(p_adj_rec.acctd_amount,0))
     THEN

        RAISE rounding_error;

     END IF;

/*------------------------------------------------------------------------------+
 | Set amounts and accounted amounts to allocate for Earned discounts           |
 +------------------------------------------------------------------------------*/
  ELSIF ((p_type_acct = 'UNED') AND (g_ae_doc_rec.source_table = 'RA')
          AND (nvl(p_app_rec.unearned_discount_taken,0) <> 0)) THEN

     g_ae_rule_rec.tax_amt_alloc       := nvl(p_app_rec.tax_uediscounted,0)     * -1;
     g_ae_rule_rec.charges_amt_alloc   := nvl(p_app_rec.charges_uediscounted,0) * -1;
     g_ae_rule_rec.line_amt_alloc      := nvl(p_app_rec.line_uediscounted,0)    * -1;
     g_ae_rule_rec.freight_amt_alloc   := nvl(p_app_rec.freight_uediscounted,0) * -1;

     arp_util.Set_Buckets(
                  p_header_acctd_amt   => nvl(p_app_rec.acctd_unearned_discount_taken,0) * -1 ,
                  p_base_currency      => g_ae_sys_rec.base_currency                          ,
                  p_exchange_rate      => g_cust_inv_rec.exchange_rate                        ,
                  p_base_precision     => g_ae_sys_rec.base_precision                         ,
                  p_base_min_acc_unit  => g_ae_sys_rec.base_min_acc_unit                      ,
                  p_tax_amt            => g_ae_rule_rec.tax_amt_alloc                         ,
                  p_charges_amt        => g_ae_rule_rec.charges_amt_alloc                     ,
                  p_line_amt           => g_ae_rule_rec.line_amt_alloc                        ,
                  p_freight_amt        => g_ae_rule_rec.freight_amt_alloc                     ,
                  p_tax_acctd_amt      => g_ae_rule_rec.tax_acctd_amt_alloc                   ,
                  p_charges_acctd_amt  => g_ae_rule_rec.charges_acctd_amt_alloc               ,
                  p_line_acctd_amt     => g_ae_rule_rec.line_acctd_amt_alloc                  ,
                  p_freight_acctd_amt  => g_ae_rule_rec.freight_acctd_amt_alloc                 );

     Dump_Init_Amts(p_type_acct => p_type_acct,
                    p_app_rec   => p_app_rec  ,
                    p_adj_rec   => p_adj_rec   );

  --Check Accounted Amounts for reconciliation with header accounted amount
     IF ((g_ae_rule_rec.line_acctd_amt_alloc  +
            g_ae_rule_rec.tax_acctd_amt_alloc    +
              g_ae_rule_rec.freight_acctd_amt_alloc +
                g_ae_rule_rec.charges_acctd_amt_alloc) <> nvl(p_app_rec.acctd_unearned_discount_taken,0) * -1)
     THEN

        RAISE rounding_error;

     END IF;
/*------------------------------------------------------------------------------+
 | Set amounts and accounted amounts to allocate for Payments for deferred tax  |
 +------------------------------------------------------------------------------*/
  ELSIF (((p_type_acct = 'PAY') AND (g_ae_def_tax) AND (NOT g_done_def_tax))
           AND (nvl(p_app_rec.amount_applied,0) <> 0)) THEN
  /*---------------------------------------------------------------------------+
   | Only the tax applied is used to move deferred tax from interim to         |
   | collected tax account. When called from the Wrapper routine for Bills     |
   | Receivable, the bucket amounts are set by the Wrapper, so its not         |
   | necessary to set it here                                                  |
   +---------------------------------------------------------------------------*/
     IF (nvl(g_ae_doc_rec.called_from,'NONE') <> 'WRAPPER') THEN

        g_ae_rule_rec.tax_amt_alloc         := nvl(p_app_rec.tax_applied,0)                 * -1;
        g_ae_rule_rec.charges_amt_alloc     := nvl(p_app_rec.receivables_charges_applied,0) * -1;
        g_ae_rule_rec.line_amt_alloc        := nvl(p_app_rec.line_applied,0)                * -1;
        g_ae_rule_rec.freight_amt_alloc     := nvl(p_app_rec.freight_applied,0)             * -1;

         arp_util.Set_Buckets(
                       p_header_acctd_amt   => nvl(p_app_rec.acctd_amount_applied_to,0)       * -1 ,
                       p_base_currency      => g_ae_sys_rec.base_currency                          ,
                       p_exchange_rate      => g_cust_inv_rec.exchange_rate                        ,
                       p_base_precision     => g_ae_sys_rec.base_precision                         ,
                       p_base_min_acc_unit  => g_ae_sys_rec.base_min_acc_unit                      ,
                       p_tax_amt            => g_ae_rule_rec.tax_amt_alloc                         ,
                       p_charges_amt        => g_ae_rule_rec.charges_amt_alloc                     ,
                       p_line_amt           => g_ae_rule_rec.line_amt_alloc                        ,
                       p_freight_amt        => g_ae_rule_rec.freight_amt_alloc                     ,
                       p_tax_acctd_amt      => g_ae_rule_rec.tax_acctd_amt_alloc                   ,
                       p_charges_acctd_amt  => g_ae_rule_rec.charges_acctd_amt_alloc               ,
                       p_line_acctd_amt     => g_ae_rule_rec.line_acctd_amt_alloc                  ,
                       p_freight_acctd_amt  => g_ae_rule_rec.freight_acctd_amt_alloc                 );
      END IF;

     Dump_Init_Amts(p_type_acct => p_type_acct,
                    p_app_rec   => p_app_rec  ,
                    p_adj_rec   => p_adj_rec   );

  --Check Accounted Amounts for reconciliation with header accounted amount
     IF ((g_ae_rule_rec.line_acctd_amt_alloc   +
            g_ae_rule_rec.tax_acctd_amt_alloc   +
              g_ae_rule_rec.freight_acctd_amt_alloc   +
                g_ae_rule_rec.charges_acctd_amt_alloc  )       <> nvl(p_app_rec.acctd_amount_applied_to,0) * -1)
     THEN

        RAISE rounding_error;

     END IF;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.line_amt_alloc ' || g_ae_rule_rec.line_amt_alloc);
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.line_acctd_amt_alloc ' || g_ae_rule_rec.line_acctd_amt_alloc);
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.tax_amt_alloc ' || g_ae_rule_rec.tax_amt_alloc);
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.tax_acctd_amt_alloc ' || g_ae_rule_rec.tax_acctd_amt_alloc);
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.freight_amt_alloc ' || g_ae_rule_rec.freight_amt_alloc);
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.freight_acctd_amt_alloc ' || g_ae_rule_rec.freight_acctd_amt_alloc);
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.charges_amt_alloc ' || g_ae_rule_rec.charges_amt_alloc);
     arp_standard.debug('Init_Amts: ' || 'g_ae_rule_rec.charges_acctd_amt_alloc ' || g_ae_rule_rec.charges_acctd_amt_alloc);
  END IF;

/*------------------------------------------------------------------------------+
 | If atleast one charges adjustment exists then add the charge to the line     |
 | it as the taxable amount.                                                    |
 +------------------------------------------------------------------------------*/
 --Get the customer trx id
   IF g_ae_doc_rec.source_table = 'RA' THEN
      l_customer_trx_id := p_app_rec.applied_customer_trx_id;
   ELSE
      l_customer_trx_id := p_adj_rec.customer_trx_id;
   END IF;

 --Check whether atleast one charges adjustment with tax exists
   FOR l_chk_tax_chrg IN chk_tax_chrg(p_cust_id => l_customer_trx_id) LOOP

    --add the charge to line to have a common taxable basis
       g_ae_rule_rec.line_amt_alloc := g_ae_rule_rec.line_amt_alloc
                                           + g_ae_rule_rec.charges_amt_alloc;

       g_ae_rule_rec.line_acctd_amt_alloc := g_ae_rule_rec.line_acctd_amt_alloc
                                               + g_ae_rule_rec.charges_acctd_amt_alloc;

    --set the charge to zero
       g_ae_rule_rec.charges_amt_alloc := 0;

       g_ae_rule_rec.charges_acctd_amt_alloc := 0;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Init_Amts: ' || 'Tax inclusive charges adjustments exist - charge added to line');
      END IF;

   END LOOP; --tax inclusive charges

   g_orig_line_amt_alloc := g_ae_rule_rec.line_amt_alloc;
   g_orig_line_acctd_amt_alloc := g_ae_rule_rec.line_acctd_amt_alloc;

/*------------------------------------------------------------------------------+
 | Boundary conditions in this case we cant allocate the tax amount or accounted|
 | amount over the original tax on Invoice and then add to the revenue for that |
 | tax due to TAX_CODE_SOURCE = NONE, hence tax is added to line and allocated. |
 | Boundary condition flag is set. Note in this case we do not override the rule|
 | When the boundary flag is set the tax link id will be null and taxable for   |
 | tax allocations will be derived from the original Invoice                    |
 +------------------------------------------------------------------------------*/
  IF (((g_ae_rule_rec.tax_amt_alloc <> 0) AND (g_ae_rule_rec.tax_amt = 0))
        OR ((g_ae_rule_rec.tax_acctd_amt_alloc <> 0) AND (g_ae_rule_rec.tax_acctd_amt = 0))) THEN

     g_bound_tax := TRUE; --applicable to ACTIVITY also hence set here

     IF (l_tax_code_source IN ('NONE', 'INVOICE')) THEN

         IF (((p_type_acct = 'ED_ADJ') OR (p_type_acct = 'PAY')) AND (l_tax_code_source =  'INVOICE')) THEN

         /* Override the rule may want to use this in the future
            g_ae_rule_rec.tax_code_source1   := 'NONE';          */

           g_ovrrd_code := '1';

           IF (p_type_acct = 'PAY') THEN
              g_ae_rule_rec.tax_code_source1      := 'NONE';
              g_ae_rule_rec.tax_recoverable_flag1 := '';
           ELSE
              RAISE invalid_allocation_base;
           END IF;

         ELSIF ((p_type_acct = 'UNED') AND (l_tax_code_source =  'INVOICE')) THEN

         /* Override the rule may want to use this in the future
            g_ae_rule_rec.tax_code_source2   := 'NONE';          */

           g_ovrrd_code := '1'; --indicates rules overriden

           RAISE invalid_allocation_base;

         END IF; --end if type of account and tax code source is Invoice

         g_ae_rule_rec.line_amt_alloc       := g_ae_rule_rec.line_amt_alloc
                                                               + g_ae_rule_rec.tax_amt_alloc;
         g_ae_rule_rec.line_acctd_amt_alloc := g_ae_rule_rec.line_acctd_amt_alloc
                                                               + g_ae_rule_rec.tax_acctd_amt_alloc;
         g_added_tax := TRUE;

         IF (g_ovrrd_code IS NULL) THEN
            g_ovrrd_code := '2'; --indicates tax added to line
         END IF;

     END IF; --end if tax code source is Invoice or None

  END IF; --end if tax base is 0 on original Invoice


/*-----------------------------------------------------------------------------------+
 | Boundary conditions for activity gl account - gl account source in this case we do|
 | not override the rule we just set the boundary flag the tax code source rule will |
 | be used as is unless overriden by one of the above conditions. In such a case the |
 | link id for tax will be null, and taxable derived from original Invoice.          |
 +-----------------------------------------------------------------------------------*/
  IF ((((g_ae_rule_rec.line_amt_alloc + g_ae_rule_rec.freight_amt_alloc + g_ae_rule_rec.charges_amt_alloc) <> 0)
       AND (g_ae_rule_rec.revenue_amt = 0))
        OR (((g_ae_rule_rec.line_acctd_amt_alloc + g_ae_rule_rec.freight_acctd_amt_alloc + g_ae_rule_rec.charges_acctd_amt_alloc) <> 0)
             AND (g_ae_rule_rec.revenue_acctd_amt = 0))) THEN

     g_bound_activity := TRUE; --set boundary condition for activity

  /*-----------------------------------------------------------------------------------+
   |Add the tax to line bucket so that allocation can be done in the case the procedure|
   |Allocate_Tax_To_Rev will not be used as the revenue base on original Invoice is 0  |
   +-----------------------------------------------------------------------------------*/
     IF ((l_tax_code_source = 'NONE') AND (NOT g_bound_tax)) THEN

        g_ae_rule_rec.line_amt_alloc       := g_ae_rule_rec.line_amt_alloc + g_ae_rule_rec.tax_amt_alloc;
        g_ae_rule_rec.line_acctd_amt_alloc := g_ae_rule_rec.line_acctd_amt_alloc + g_ae_rule_rec.tax_acctd_amt_alloc;
        g_added_tax := TRUE;

        IF (g_ovrrd_code IS NULL) THEN
           g_ovrrd_code := '2';  --indicates tax added to line
        END IF;

     END IF; --end if tax code source is NONE

  /*-------------------------------------------------------------------------------------+
   |Override the rule for gl account source as line amount or accounted amount cannot be |
   |allocated uniformly over revenue amount or accounted amount base on original Invoice.|
   +-------------------------------------------------------------------------------------*/
     IF (l_gl_account_source IN ('REVENUE_ON_INVOICE', 'TAX_CODE_ON_INVOICE')) THEN

        IF ((p_type_acct = 'ED_ADJ') OR (p_type_acct = 'PAY')) THEN

           /* override the rule on GL Account Source kept for future usage most logical setting
              g_ae_rule_rec.gl_account_source1 := 'ACTIVITY_GL_ACCOUNT'; */

           RAISE invalid_allocation_base;

        ELSIF (p_type_acct = 'UNED') THEN

           /* override the rule on GL Account Source kept for future usage most logical setting
              g_ae_rule_rec.gl_account_source2 := 'ACTIVITY_GL_ACCOUNT'; */

           RAISE invalid_allocation_base;

        END IF;

        IF (g_ovrrd_code = '1') THEN
            null; --dont set code again
        ELSIF (g_ovrrd_code = '2') THEN
            g_ovrrd_code := 3; --indicates tax added to line and gl account source rule overriden
        ELSIF g_ovrrd_code IS NULL THEN
            g_ovrrd_code := 4; --indicates gl account source overriden
        END IF;

     END IF; --end if revenue on invoice or tax code on invoice

  END IF; --end if revenue amount or accounted amount base is 0


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Init_Amts()-');
  END IF;

EXCEPTION
  WHEN rounding_error THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Rounding error: ARP_ALLOCATION_PKG.Init_Amts');
       END IF;
       fnd_message.set_name('AR','AR_ROUNDING_ERROR');
       fnd_message.set_token('ROUTINE','ARP_ALLOCATION_PKG.INIT_AMTS');
       RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Init_Amts');
     END IF;
     RAISE;

END Init_Amts;

/* ==========================================================================
 | PROCEDURE Gross_To_Activity_GL
 |
 | DESCRIPTION
 |      This routine creates the standard Gross to Activity GL Account
 |      accounting entry.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      NONE
 *==========================================================================*/
PROCEDURE Gross_To_Activity_GL(p_type_acct      IN VARCHAR2) IS

l_ae_line_init_rec     ar_ae_alloc_rec_gt%ROWTYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_ALLOCATION_PKG.Gross_To_Activity_GL()+');
  END IF;

 /*----------------------------------------------------------------------------+
  | Assign Currency Exchange rate information to initialisation record         |
  +----------------------------------------------------------------------------*/
   l_ae_line_init_rec.ae_source_id                 := g_ae_doc_rec.source_id               ;
   l_ae_line_init_rec.ae_source_table              := g_ae_doc_rec.source_table            ;
   l_ae_line_init_rec.ae_currency_code             := g_cust_inv_rec.invoice_currency_code ;
   l_ae_line_init_rec.ae_currency_conversion_rate  := g_cust_inv_rec.exchange_rate         ;
   l_ae_line_init_rec.ae_currency_conversion_type  := g_cust_inv_rec.exchange_rate_type    ;
   l_ae_line_init_rec.ae_currency_conversion_date  := g_cust_inv_rec.exchange_date         ;

   IF (g_cust_inv_rec.drawee_site_use_id IS NOT NULL) THEN --if Bill
      l_ae_line_init_rec.ae_third_party_id            := g_cust_inv_rec.drawee_id;
      l_ae_line_init_rec.ae_third_party_sub_id        := g_cust_inv_rec.drawee_site_use_id  ;
   ELSE
      l_ae_line_init_rec.ae_third_party_id            := g_cust_inv_rec.bill_to_customer_id   ;
      l_ae_line_init_rec.ae_third_party_sub_id        := g_cust_inv_rec.bill_to_site_use_id   ;
   END IF;

 /*----------------------------------------------------------------------------+
  | Build accounting for any Charges and Freight amounts to activity GL account|
  +----------------------------------------------------------------------------*/
   Build_Charges_Freight_All(p_type_acct        => p_type_acct       ,
                             p_ae_line_init_rec => l_ae_line_init_rec,
                             p_build_all        => TRUE   );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Gross_To_Activity_GL()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Gross_To_Activity_GL');
     END IF;
     RAISE;

END Gross_To_Activity_GL;

/* ==========================================================================
 | PROCEDURE Init_Rev_Tax_Tab
 |
 | DESCRIPTION
 |      Initialise cells in tables which are used for calculations, this is
 |      required because an application may require allocation of discounts
 |      for earned discounts and then for unearned discounts
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      NONE
 *==========================================================================*/
PROCEDURE Init_Rev_Tax_Tab IS

l_ctr                 BINARY_INTEGER;

BEGIN
  arp_standard.debug('ARP_ALLOCATION_PKG.Init_Rev_Tax_Tab()+');

/*------------------------------------------------------------------------------+
 | Set the prorate amount and summarized flags to null because they may have    |
 | been set for earned discounts.                                               |
 +------------------------------------------------------------------------------*/

  UPDATE /*+ INDEX(ar_ae_alloc_rec_gt AR_AE_ALLOC_REC_GT_N3)*/
        ar_ae_alloc_rec_gt
  SET ae_pro_amt                     = 0  ,
      ae_pro_acctd_amt               = 0  ,
      ae_pro_frt_chrg_amt            = 0  ,
      ae_pro_frt_chrg_acctd_amt      = 0  ,
      ae_pro_taxable_amt             = 0  ,
      ae_pro_taxable_acctd_amt       = 0  ,
      ae_pro_split_taxable_amt       = '' ,
      ae_pro_split_taxable_acctd_amt = '' ,
      ae_pro_recov_taxable_amt       = '' ,
      ae_pro_recov_taxable_acctd_amt = '' ,
      ae_pro_def_tax_amt             = 0  ,
      ae_pro_def_tax_acctd_amt       = 0  ,
      ae_sum_alloc_amt               = 0  ,
      ae_sum_alloc_acctd_amt         = 0  ,
      ae_tax_link_id_act             = '' ,
      ae_counted_flag                = 'N'
   WHERE ae_id = g_id;

  arp_standard.debug( 'ARP_ALLOCATION_PKG.Init_Rev_Tax_Tab()-');

EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Init_Rev_Tax_Tab');
     RAISE;

END Init_Rev_Tax_Tab;

/* ==========================================================================
 | FUNCTION Get_Acctd_Amt
 |
 | DESCRIPTION
 |      Returns accounted amount using invoice exchange rate converting to
 |      base currency.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |      p_amount             IN  Amount which needs to be converted into
 |                               base or functional currency accounted amount
 *==========================================================================*/
FUNCTION  Get_Acctd_Amt(p_amount       IN NUMBER ) RETURN NUMBER IS

l_acctd_amount NUMBER;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Acctd_Amt()-');
  END IF;

  l_acctd_amount := arpcurr.functional_amount(p_amount                                   ,
                                              g_ae_sys_rec.base_currency                 ,
                                              g_cust_inv_rec.exchange_rate               ,
                                              g_ae_sys_rec.base_precision                ,
                                              g_ae_sys_rec.base_min_acc_unit               );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Acctd_Amt()-');
  END IF;

  RETURN l_acctd_amount ;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Get_Acctd_Amt: ' || 'EXCEPTION: ARP_ALLOCATION_PKG.Init_Amts');
     END IF;
     RAISE;

END Get_Acctd_Amt;

/* ==========================================================================
 | PROCEDURE Alloc_Rev_Tax_Amt
 |
 | DESCRIPTION
 |      Allocate Tax amount over tax distributions for tax lines
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |       None
 *==========================================================================*/
PROCEDURE Alloc_Rev_Tax_Amt(p_type_acct IN VARCHAR2) IS

--Rev variables
l_rev_run_amt_tot             NUMBER := 0    ;
l_rev_run_acctd_amt_tot       NUMBER := 0    ;
l_rev_run_pro_amt_tot         NUMBER := 0    ;
l_rev_run_pro_acctd_amt_tot   NUMBER := 0    ;

--Frt, chrg variables
l_frt_run_pro_amt_tot         NUMBER := 0    ;
l_frt_run_pro_acctd_amt_tot   NUMBER := 0    ;

--Tax variables
l_ctr                        BINARY_INTEGER;
l_last_tax                   BINARY_INTEGER := 0;
l_last_def_tax               BINARY_INTEGER := 0;
l_tax_run_amt_tot            NUMBER := 0;
l_tax_run_acctd_amt_tot      NUMBER := 0;
l_tax_run_pro_amt_tot        NUMBER := 0;
l_tax_run_pro_acctd_amt_tot  NUMBER := 0;
l_def_tax_run_amt_tot        NUMBER := 0;
l_def_tax_run_acctd_amt_tot  NUMBER := 0;
l_pro_def_tax_run_amt        NUMBER := 0;
l_pro_def_tax_run_acctd_amt  NUMBER := 0;
l_tax_applied                NUMBER := 0;
l_tax_acctd_applied          NUMBER := 0;
l_rowid                      VARCHAR2(50);

TYPE g_ae_alloc_type IS RECORD (
     l_rowid                   DBMS_SQL.VARCHAR2_TABLE,
     ae_account_class          DBMS_SQL.VARCHAR2_TABLE,
     ae_amount                 DBMS_SQL.NUMBER_TABLE,
     ae_acctd_amount           DBMS_SQL.NUMBER_TABLE,
     ae_pro_amt                DBMS_SQL.NUMBER_TABLE,
     ae_pro_acctd_amt          DBMS_SQL.NUMBER_TABLE,
     ae_taxable_amount         DBMS_SQL.NUMBER_TABLE,
     ae_taxable_acctd_amount   DBMS_SQL.NUMBER_TABLE,
     ae_pro_frt_chrg_amt       DBMS_SQL.NUMBER_TABLE,
     ae_pro_frt_chrg_acctd_amt DBMS_SQL.NUMBER_TABLE,
     ae_pro_taxable_amt        DBMS_SQL.NUMBER_TABLE,
     ae_pro_taxable_acctd_amt  DBMS_SQL.NUMBER_TABLE,
     ae_collected_tax_ccid     DBMS_SQL.NUMBER_TABLE,
     ae_pro_def_tax_amt        DBMS_SQL.NUMBER_TABLE,
     ae_pro_def_tax_acctd_amt  DBMS_SQL.NUMBER_TABLE
);

g_ae_alloc_rev_tax_tbl       g_ae_alloc_type;

CURSOR l_rev_tax_cur IS
SELECT /*+ INDEX(ar_ae_alloc_rec_gt AR_AE_ALLOC_REC_GT_N3) */
       rowid,
       ae_account_class,
       ae_amount,
       ae_acctd_amount,
       ae_pro_amt,
       ae_pro_acctd_amt,
       ae_taxable_amount,
       ae_taxable_acctd_amount,
       ae_pro_taxable_amt,
       ae_pro_taxable_acctd_amt,
       ae_pro_frt_chrg_amt,
       ae_pro_frt_chrg_acctd_amt,
       ae_collected_tax_ccid,
       ae_pro_def_tax_amt,
       ae_pro_def_tax_acctd_amt
FROM ar_ae_alloc_rec_gt
WHERE ae_id = g_id
AND ae_account_class IS NOT NULL
ORDER BY ae_account_class, ae_customer_trx_line_id;

l_process_rev      BOOLEAN;
l_process_frt      BOOLEAN;
l_process_tax      BOOLEAN;
l_last_fetch       BOOLEAN;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Alloc_Rev_Tax_Amt()+');
   END IF;

/*------------------------------------------------------------------------------+
 | Allocate discount, adjustment, finance charge amounts over revenue. The check|
 | below is required because for PA it appears that amount could be zero but    |
 | accounted amount could be present. The revenue amount is allocated only if   |
 | there is a valid non zero revenue base to allocate otherwise the line amount |
 | would be allocated to the Activity GL account                                |
 +------------------------------------------------------------------------------*/
   l_process_rev := FALSE;

/*------------------------------------------------------------------------------+
 | Set process revenue flag                                                     |
 +------------------------------------------------------------------------------*/
   IF (((g_ae_rule_rec.line_amt_alloc <> 0) AND (g_ae_rule_rec.revenue_amt <> 0))
       OR ((g_ae_rule_rec.line_acctd_amt_alloc <> 0) AND (g_ae_rule_rec.revenue_acctd_amt <> 0)))
      AND (g_ae_rev_ctr > 0) THEN

       l_process_rev := TRUE;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'Process Revenue is True ');
       END IF;

   END IF;

   l_process_frt := FALSE;

   IF ((((g_ae_rule_rec.freight_amt_alloc + g_ae_rule_rec.charges_amt_alloc) <> 0)
      AND (g_ae_rule_rec.revenue_amt <> 0))
      OR
      (((g_ae_rule_rec.freight_acctd_amt_alloc + g_ae_rule_rec.charges_acctd_amt_alloc) <> 0)
        AND (g_ae_rule_rec.revenue_acctd_amt <> 0))) AND (g_ae_rev_ctr > 0) THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'Process Freight is True ');
      END IF;
      l_process_frt := TRUE;

   END IF;

   l_process_tax := FALSE;

/*------------------------------------------------------------------------------+
 | Set process tax flag                                                         |
 +------------------------------------------------------------------------------*/
   IF (((g_ae_rule_rec.tax_amt_alloc <> 0) OR (g_ae_rule_rec.tax_acctd_amt_alloc <> 0))
       OR ((g_ae_rule_rec.line_amt_alloc <> 0) OR (g_ae_rule_rec.line_acctd_amt_alloc <> 0)))
      AND (g_ae_tax_ctr > 0) THEN

      l_process_tax := TRUE;
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'Process Tax is True ');
      END IF;

   END IF;

/*------------------------------------------------------------------------------+
 | Set tax applied and accounted and allocate over tax, this is done using a    |
 | RATE which is determined based on the total deferred tax over the actual tax |
 | The arpcurr round function is used to round to precision for curency of      |
 | Invoice and functional currency.                                             |
 +------------------------------------------------------------------------------*/
   IF ((g_ae_def_tax) AND (NOT g_done_def_tax) AND (p_type_acct = 'PAY'))
      AND l_process_tax THEN

      IF g_ae_rule_rec.tax_amt <> 0 THEN --prevent zero divide

         l_tax_applied       := arpcurr.CurrRound(g_ae_rule_rec.tax_amt_alloc    *
                                   g_ae_rule_rec.def_tax_amt/g_ae_rule_rec.tax_amt,
                                   g_cust_inv_rec.invoice_currency_code);
      END IF; --amt not zero

      IF g_ae_rule_rec.tax_acctd_amt <> 0 THEN --prevent zero divide

         l_tax_acctd_applied := arpcurr.CurrRound(g_ae_rule_rec.tax_acctd_amt_alloc   *
                                 g_ae_rule_rec.def_tax_acctd_amt/g_ae_rule_rec.tax_acctd_amt,
                                 g_ae_sys_rec.base_currency);
      END IF; --accounted amt not zero

   END IF; --process Tax

 /*------------------------------------------------------------------------------+
  | Loop through tax to allocate tax on discounts and adjustments payments       |
  +------------------------------------------------------------------------------*/
  IF l_process_rev OR l_process_frt OR l_process_tax THEN

     OPEN l_rev_tax_cur;

     LOOP

      FETCH l_rev_tax_cur BULK COLLECT INTO
            g_ae_alloc_rev_tax_tbl.l_rowid,
            g_ae_alloc_rev_tax_tbl.ae_account_class,
            g_ae_alloc_rev_tax_tbl.ae_amount,
            g_ae_alloc_rev_tax_tbl.ae_acctd_amount,
            g_ae_alloc_rev_tax_tbl.ae_pro_amt,
            g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt,
            g_ae_alloc_rev_tax_tbl.ae_taxable_amount,
            g_ae_alloc_rev_tax_tbl.ae_taxable_acctd_amount,
            g_ae_alloc_rev_tax_tbl.ae_pro_taxable_amt,
            g_ae_alloc_rev_tax_tbl.ae_pro_taxable_acctd_amt,
            g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_amt,
            g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_acctd_amt,
            g_ae_alloc_rev_tax_tbl.ae_collected_tax_ccid,
            g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_amt,
            g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_acctd_amt
       LIMIT g_bulk_fetch_rows;

       IF l_rev_tax_cur%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

       IF (g_ae_alloc_rev_tax_tbl.l_rowid.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'COUNT = 0 and LAST FETCH ');
         END IF;
         EXIT;
       END IF;

    FOR i IN g_ae_alloc_rev_tax_tbl.l_rowid.FIRST .. g_ae_alloc_rev_tax_tbl.l_rowid.LAST LOOP

      IF ((l_process_rev) OR (l_process_frt)) AND g_ae_alloc_rev_tax_tbl.ae_account_class(i) = 'REVEARN' THEN

      /*------------------------------------------------------------------------------+
       | Maintain running total amounts for Revenue amounts and accounted amounts, set|
       | cached flag.
       +------------------------------------------------------------------------------*/
          l_rev_run_amt_tot       := l_rev_run_amt_tot + g_ae_alloc_rev_tax_tbl.ae_amount(i);
          l_rev_run_acctd_amt_tot := l_rev_run_acctd_amt_tot + g_ae_alloc_rev_tax_tbl.ae_acctd_amount(i);

        /*------------------------------------------------------------------------------+
         | Allocate revenue for discount or adjustments to each revenue line in Invoice |
         | currency. Rev lines 10, 20, 30, 40, Rev Total 100, Discount 10               |
         | Line 1  a -> 10 * 10/100  = 1 (allocated)                                    |
         |                                                                              |
         | Line 2    -> (10 + 20)/100 * 10 = 3                                          |
         |         b -> 3 - a = 2 (allocated)                                           |
         |                                                                              |
         | Line 3    -> (10 + 20 + 30) * 10/100 = 6                                     |
         |         c -> 6 - a - b = 3                                                   |
         | Line .....                                                                   |
         +------------------------------------------------------------------------------*/
         IF g_ae_rule_rec.revenue_amt <> 0 THEN

          /*------------------------------------------------------------------------------+
           | Process line amounts                                                         |
           +------------------------------------------------------------------------------*/
            IF l_process_rev THEN
            g_ae_alloc_rev_tax_tbl.ae_pro_amt(i) :=
            arpcurr.CurrRound(l_rev_run_amt_tot / g_ae_rule_rec.revenue_amt * g_ae_rule_rec.line_amt_alloc,
                              g_cust_inv_rec.invoice_currency_code) - l_rev_run_pro_amt_tot;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_amt = '||
                                g_ae_alloc_rev_tax_tbl.ae_pro_amt(i));
            END IF;

          /*------------------------------------------------------------------------------+
           | Running total for prorated Revenue amount in currency of Invoice             |
           +------------------------------------------------------------------------------*/
            l_rev_run_pro_amt_tot := l_rev_run_pro_amt_tot
                                         + g_ae_alloc_rev_tax_tbl.ae_pro_amt(i);
            END IF;

          /*------------------------------------------------------------------------------+
           | Process Freight and charges                                                  |
           +------------------------------------------------------------------------------*/
            IF l_process_frt THEN
            g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_amt(i) :=
            arpcurr.CurrRound(l_rev_run_amt_tot / g_ae_rule_rec.revenue_amt *
                              (g_ae_rule_rec.freight_amt_alloc + g_ae_rule_rec.charges_amt_alloc),
                              g_cust_inv_rec.invoice_currency_code) - l_frt_run_pro_amt_tot;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_amt('||i||') = '||
                                g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_amt(i));
            END IF;

          /*------------------------------------------------------------------------------+
           | Running total for prorated Freight amount in currency of Invoice             |
           +------------------------------------------------------------------------------*/
            l_frt_run_pro_amt_tot := l_frt_run_pro_amt_tot
                                         + g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_amt(i);
            END IF;

         END IF;

        /*------------------------------------------------------------------------------+
         | Calculate accounted amount for revenue amount allocated to each revenue line |
         +------------------------------------------------------------------------------*/
         IF g_ae_rule_rec.revenue_acctd_amt <> 0 THEN

          /*------------------------------------------------------------------------------+
           | Process Line accounted amounts                                               |
           +------------------------------------------------------------------------------*/
            IF l_process_rev THEN
            g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(i) :=
             arpcurr.CurrRound(l_rev_run_acctd_amt_tot / g_ae_rule_rec.revenue_acctd_amt
                               * g_ae_rule_rec.line_acctd_amt_alloc, g_ae_sys_rec.base_currency)
                                   - l_rev_run_pro_acctd_amt_tot;

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt = '||
                                 g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(i));
             END IF;

          /*------------------------------------------------------------------------------+
           | Running total for prorated Revenue accounted amount in base currency         |
           +------------------------------------------------------------------------------*/
            l_rev_run_pro_acctd_amt_tot := l_rev_run_pro_acctd_amt_tot
                                                 + g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(i);
            END IF;
          /*------------------------------------------------------------------------------+
           | Process Freight and charges                                                  |
           +------------------------------------------------------------------------------*/
            IF l_process_frt THEN
            g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_acctd_amt(i) :=
             arpcurr.CurrRound(l_rev_run_acctd_amt_tot / g_ae_rule_rec.revenue_acctd_amt
                               * (g_ae_rule_rec.freight_acctd_amt_alloc + g_ae_rule_rec.charges_acctd_amt_alloc),
                               g_ae_sys_rec.base_currency) - l_frt_run_pro_acctd_amt_tot;

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_acctd_amt('||i||') = '||
                                 g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_acctd_amt(i));
             END IF;

          /*------------------------------------------------------------------------------+
           | Running total for prorated Freight accounted amount in base currency         |
           +------------------------------------------------------------------------------*/
            l_frt_run_pro_acctd_amt_tot := l_frt_run_pro_acctd_amt_tot
                                            + g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_acctd_amt(i);

            END IF;
         END IF; --revenue accounted amount is not zero

         --Dump_Alloc_Rev_Tax(p_type => 'REV_TAX', p_alloc_rec => g_ae_alloc_rev_tax_tbl);

      END IF; --process revenue

   /*------------------------------------------------------------------------------+
    | Allocate tax amounts, deferred tax amounts                                   |
    +------------------------------------------------------------------------------*/
      IF l_process_tax AND g_ae_alloc_rev_tax_tbl.ae_account_class(i) = 'TAX' THEN

     /*------------------------------------------------------------------------------+
      | Maintain running total amounts for Tax amounts and accounted amounts         |
      +------------------------------------------------------------------------------*/
         l_tax_run_amt_tot       := l_tax_run_amt_tot + g_ae_alloc_rev_tax_tbl.ae_amount(i);
         l_tax_run_acctd_amt_tot := l_tax_run_acctd_amt_tot + g_ae_alloc_rev_tax_tbl.ae_acctd_amount(i);

         IF g_ae_rule_rec.tax_amt <> 0 THEN --prevent zero divide
           /*------------------------------------------------------------------------------+
            | Allocate tax for discount or adjustments to each tax line in Invoice         |
            | currency. Tax lines 10, 20, 30, 40, Tax Total 100, Tax on Discount 10        |
            | Line 1  a -> 10 * 10/100  = 1 (allocated)                                    |
            |                                                                              |
            | Line 2    -> (10 + 20)/100 * 10 = 3                                          |
            |         b -> 3 - a = 2 (allocated)                                           |
            |                                                                              |
            | Line 3    -> (10 + 20 + 30) * 10/100 = 6                                     |
            |         c -> 6 - a - b = 3                                                   |
            | Line .....                                                                   |
            +------------------------------------------------------------------------------*/

            g_ae_alloc_rev_tax_tbl.ae_pro_amt(i) :=
             arpcurr.CurrRound(l_tax_run_amt_tot / g_ae_rule_rec.tax_amt * g_ae_rule_rec.tax_amt_alloc,
                               g_cust_inv_rec.invoice_currency_code) - l_tax_run_pro_amt_tot;

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_amt = '||
                                 g_ae_alloc_rev_tax_tbl.ae_pro_amt(i));
             END IF;

          /*------------------------------------------------------------------------------+
           | Running total for prorated Tax amount in currency of Invoice                 |
           +------------------------------------------------------------------------------*/
            l_tax_run_pro_amt_tot := l_tax_run_pro_amt_tot + g_ae_alloc_rev_tax_tbl.ae_pro_amt(i);

         END IF;

         IF g_ae_rule_rec.tax_acctd_amt <> 0 THEN --prevent zero divide
          /*------------------------------------------------------------------------------+
           | Calculate accounted amount for tax amount allocated to each tax line         |
           +------------------------------------------------------------------------------*/
            g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(i) :=
            arpcurr.CurrRound(l_tax_run_acctd_amt_tot / g_ae_rule_rec.tax_acctd_amt
                              * g_ae_rule_rec.tax_acctd_amt_alloc, g_ae_sys_rec.base_currency)
                                     - l_tax_run_pro_acctd_amt_tot;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt = '||
                                g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(i));
            END IF;

         /*------------------------------------------------------------------------------+
          | Running total for prorated Tax accounted amount in base currency             |
          +------------------------------------------------------------------------------*/
            l_tax_run_pro_acctd_amt_tot := l_tax_run_pro_acctd_amt_tot + g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(i);

        END IF;

      /*-------------------------------------------------------------------------------+
       | Calculate taxable as "allocated tax amount/actual tax amt * actual taxable"   |
       | to get accurate basis for taxable only if a boundary condition exists         |
       +-------------------------------------------------------------------------------*/
        IF ((g_bound_tax) OR (g_bound_activity))
           AND ((g_orig_line_amt_alloc <> 0) OR (g_orig_line_acctd_amt_alloc <> 0)) THEN

           IF g_ae_alloc_rev_tax_tbl.ae_amount(i) <> 0 THEN

              g_ae_alloc_rev_tax_tbl.ae_pro_taxable_amt(i) :=
                   arpcurr.CurrRound(g_ae_alloc_rev_tax_tbl.ae_taxable_amount(i) *
                                     g_ae_alloc_rev_tax_tbl.ae_pro_amt(i) / g_ae_alloc_rev_tax_tbl.ae_amount(i),
                                     g_cust_inv_rec.invoice_currency_code);

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_taxable_amt = '||
                                  g_ae_alloc_rev_tax_tbl.ae_pro_taxable_amt(i));
              END IF;

           END IF; --end if ae_amount is zero

         /*------------------------------------------------------------------------------+
          | Calculate taxable accounted amount                                           |
          +------------------------------------------------------------------------------*/
           IF g_ae_alloc_rev_tax_tbl.ae_acctd_amount(i) <> 0 THEN

              g_ae_alloc_rev_tax_tbl.ae_pro_taxable_acctd_amt(i) :=
                arpcurr.CurrRound(g_ae_alloc_rev_tax_tbl.ae_taxable_acctd_amount(i) *
                             g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(i) / g_ae_alloc_rev_tax_tbl.ae_acctd_amount(i),
                             g_ae_sys_rec.base_currency);

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_taxable_acctd_amt = '||
                                g_ae_alloc_rev_tax_tbl.ae_pro_taxable_acctd_amt(i));
              END IF;

           END IF; --end if ae_acctd_amount is zero

        END IF; --End if Boundary condition

      /*------------------------------------------------------------------------------+
       | Allocation of tax based on payment is done for all tax lines only deferred   |
       | tax amounts will be moved from interim to collected tax account              |
       +------------------------------------------------------------------------------*/
        IF (g_ae_doc_rec.source_table = 'RA') AND (g_ae_alloc_rev_tax_tbl.ae_collected_tax_ccid(i) IS NOT NULL)
           AND (NOT g_done_def_tax)
        THEN
         /*------------------------------------------------------------------------------+
          | Maintain running total amounts for Revenue amounts and accounted amounts     |
          +------------------------------------------------------------------------------*/
           l_def_tax_run_amt_tot           := l_def_tax_run_amt_tot +
                                                        g_ae_alloc_rev_tax_tbl.ae_amount(i);
           l_def_tax_run_acctd_amt_tot     := l_def_tax_run_acctd_amt_tot +
                                                        g_ae_alloc_rev_tax_tbl.ae_acctd_amount(i);

         /*---------------------------------------------------------------------------------+
          | Calculate deferred tax amount to be moved from interim to collected tax account |
          +---------------------------------------------------------------------------------*/
           IF g_ae_rule_rec.def_tax_amt <> 0 THEN

              g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_amt(i) :=
                        arpcurr.CurrRound(l_def_tax_run_amt_tot / g_ae_rule_rec.def_tax_amt * l_tax_applied,
                                          g_cust_inv_rec.invoice_currency_code) - l_pro_def_tax_run_amt;

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_amt = '||
                                  g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_amt(i));
              END IF;

           /*------------------------------------------------------------------------------+
            | Running total for prorated deferred tax amount in currency of Invoice        |
            +------------------------------------------------------------------------------*/
             l_pro_def_tax_run_amt := l_pro_def_tax_run_amt + g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_amt(i);

           END IF;

         /*------------------------------------------------------------------------------+
          | Calculate deferred tax accounted amount to be moved from interim to collected|
          | tax account                                                                  |
          +------------------------------------------------------------------------------*/
           IF g_ae_rule_rec.def_tax_acctd_amt <> 0 THEN

              g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_acctd_amt(i) :=
                arpcurr.CurrRound(l_def_tax_run_acctd_amt_tot / g_ae_rule_rec.def_tax_acctd_amt
                                  * l_tax_acctd_applied, g_ae_sys_rec.base_currency)
                                          - l_pro_def_tax_run_acctd_amt;

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_acctd_amt = '||
                                  g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_acctd_amt(i));
              END IF;

             /*------------------------------------------------------------------------------+
              | Running total for prorated deferred tax accounted amount in base currency    |
              +------------------------------------------------------------------------------*/
               l_pro_def_tax_run_acctd_amt :=
                  l_pro_def_tax_run_acctd_amt + g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_acctd_amt(i);

           END IF;

           l_last_def_tax := l_ctr;

        END IF; --End if payment not zero

        --Dump_Alloc_Rev_Tax(p_type => 'REV_TAX', p_alloc_rec => g_ae_alloc_rev_tax_tbl);

        l_last_tax := l_ctr;

      END IF; --process tax

    END LOOP;  --loop bulk fetched rows

   /*------------------------------------------------------------------------------+
    | Update the amounts for revenue or tax based on rowid                         |
    +------------------------------------------------------------------------------*/
      FORALL m IN g_ae_alloc_rev_tax_tbl.l_rowid.FIRST .. g_ae_alloc_rev_tax_tbl.l_rowid.LAST
          UPDATE ar_ae_alloc_rec_gt
           SET  ae_pro_amt             = g_ae_alloc_rev_tax_tbl.ae_pro_amt(m),
             ae_pro_acctd_amt          = g_ae_alloc_rev_tax_tbl.ae_pro_acctd_amt(m),
             ae_pro_taxable_amt        = g_ae_alloc_rev_tax_tbl.ae_pro_taxable_amt(m),
             ae_pro_taxable_acctd_amt  = g_ae_alloc_rev_tax_tbl.ae_pro_taxable_acctd_amt(m),
             ae_pro_frt_chrg_amt       = g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_amt(m),
             ae_pro_frt_chrg_acctd_amt = g_ae_alloc_rev_tax_tbl.ae_pro_frt_chrg_acctd_amt(m),
             ae_pro_def_tax_amt        = g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_amt(m),
             ae_pro_def_tax_acctd_amt  = g_ae_alloc_rev_tax_tbl.ae_pro_def_tax_acctd_amt(m)
          WHERE rowid = g_ae_alloc_rev_tax_tbl.l_rowid(m);

  --Exit if Last fetch
    IF l_last_fetch THEN
       EXIT;
    END IF;

   END LOOP; --process revenue tax bulk fetch

   CLOSE l_rev_tax_cur;

   END IF; --process revenue or tax

 /*---------------------------------------------------------------------------------+
  | Call taxable amount routine, to build the taxable amounts and accounted amounts |
  +---------------------------------------------------------------------------------*/
   IF (NOT g_bound_tax) AND (NOT g_bound_activity) and l_process_tax THEN
       Set_Taxable_Amt(p_type_acct => p_type_acct);
       Set_Taxable_Split_Amt(p_type_acct => p_type_acct);
   END IF;

 /*------------------------------------------------------------------------------+
  | Abnormal rounding correction condition this should never happen, however this|
  | is a safety mechanism. For payments check rounding only when type acct is PAY|
  +------------------------------------------------------------------------------*/
   IF ((((l_tax_run_pro_amt_tot <> g_ae_rule_rec.tax_amt_alloc) AND (g_ae_rule_rec.tax_amt <> 0))
          OR ((l_tax_run_pro_acctd_amt_tot <> g_ae_rule_rec.tax_acctd_amt_alloc)
              AND (g_ae_rule_rec.tax_acctd_amt <> 0)))
      OR ((((l_pro_def_tax_run_amt <> l_tax_applied) AND (g_ae_rule_rec.def_tax_amt <> 0))
             OR ((l_pro_def_tax_run_acctd_amt <> l_tax_acctd_applied) AND (g_ae_rule_rec.def_tax_acctd_amt <> 0)))
              AND (g_ae_def_tax) AND (NOT g_done_def_tax) AND (p_type_acct = 'PAY')))
      AND l_process_tax THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_tax_run_pro_amt_tot : '||l_tax_run_pro_amt_tot||
                         ' <> '||'g_ae_rule_rec.tax_amt_alloc : '||g_ae_rule_rec.tax_amt_alloc);
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_tax_run_pro_acctd_amt_tot : '||l_tax_run_pro_acctd_amt_tot||
                         ' <> '||'g_ae_rule_rec.tax_acctd_amt_alloc : '||g_ae_rule_rec.tax_acctd_amt_alloc);
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_pro_def_tax_run_amt : '||l_pro_def_tax_run_amt||
                         ' <> '||'l_tax_applied : '||l_tax_applied);
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_pro_def_tax_run_acctd_amt : '||l_pro_def_tax_run_acctd_amt||
                         ' <> '||'l_tax_acctd_applied : '||l_tax_acctd_applied);
      END IF;

      RAISE rounding_error;

   END IF; --tax rounding condition check

/*------------------------------------------------------------------------------+
 | Abnormal rounding correction condition this should never happen, however this|
 | is a safety mechanism.                                                       |
 +------------------------------------------------------------------------------*/
   IF (((l_rev_run_pro_amt_tot <> g_ae_rule_rec.line_amt_alloc) AND (g_ae_rule_rec.revenue_amt <> 0))
          OR ((l_rev_run_pro_acctd_amt_tot <> g_ae_rule_rec.line_acctd_amt_alloc)
              AND (g_ae_rule_rec.revenue_acctd_amt <>0))) AND l_process_rev THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_rev_run_pro_amt_tot : '||l_rev_run_pro_amt_tot||
                         ' <> '||'g_ae_rule_rec.line_amt_alloc : '||g_ae_rule_rec.line_amt_alloc);
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_rev_run_pro_acctd_amt_tot : '||l_rev_run_pro_acctd_amt_tot||
                         ' <> '||'g_ae_rule_rec.line_acctd_amt_alloc : '||g_ae_rule_rec.line_acctd_amt_alloc);
      END IF;

      RAISE rounding_error;

   END IF; --check rounding for revenue

 /*------------------------------------------------------------------------------+
  | Abnormal rounding correction condition this should never happen, however this|
  | is a safety mechanism.                                                       |
  +------------------------------------------------------------------------------*/
   IF (((l_frt_run_pro_amt_tot <> (g_ae_rule_rec.freight_amt_alloc + g_ae_rule_rec.charges_amt_alloc))
        AND (g_ae_rule_rec.revenue_amt <> 0))
      OR ((l_frt_run_pro_acctd_amt_tot <>
                  (g_ae_rule_rec.freight_acctd_amt_alloc + g_ae_rule_rec.charges_acctd_amt_alloc))
           AND (g_ae_rule_rec.revenue_acctd_amt <>0))) AND l_process_frt THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_frt_run_pro_amt_tot : '||l_frt_run_pro_amt_tot||
                         ' <> '||'g_ae_rule_rec.freight_amt_alloc ' || g_ae_rule_rec.freight_amt_alloc ||
                         ' + g_ae_rule_rec.charges_amt_alloc ' || g_ae_rule_rec.charges_amt_alloc );
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || 'l_frt_run_pro_acctd_amt_tot : '||l_frt_run_pro_acctd_amt_tot||
                         ' <> '||'g_ae_rule_rec.freight_acctd_amt_alloc ' || g_ae_rule_rec.freight_acctd_amt_alloc ||
                         ' + g_ae_rule_rec.charges_acctd_amt_alloc ' || g_ae_rule_rec.charges_acctd_amt_alloc );
      END IF;

      RAISE rounding_error;

   END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'ARP_ALLOCATION_PKG.Alloc_Rev_Tax_Amt()-');
 END IF;

EXCEPTION

  WHEN rounding_error THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Rounding Error: ARP_ALLOCATION_PKG.Alloc_Rev_Tax_Amt' );
     END IF;
     fnd_message.set_name('AR','AR_ROUNDING_ERROR');
     fnd_message.set_token('ROUTINE','ARP_ALLOCATION_PKG.ALLOC_REV_TAX_AMT');
     RAISE;

   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Alloc_Rev_Tax_Amt: ' || SQLERRM);
         arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Alloc_Rev_Tax_Amt');
      END IF;
      RAISE;

END Alloc_Rev_Tax_Amt;

/* ==========================================================================
 | PROCEDURE Set_Taxable_Amt
 |
 | DESCRIPTION
 |      Derive Taxable amounts for Tax, when this routine is called the tax
 |      table has to exist.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |       p_type_acct      IN    Indicates accounting for earned, unearned
 |                              discounts or adjustments
 *==========================================================================*/
PROCEDURE Set_Taxable_Amt(p_type_acct IN VARCHAR2) IS

l_ctr                    BINARY_INTEGER;
l_ctr1                   BINARY_INTEGER;

CURSOR set_taxable_and_link IS
select /*+ INDEX(a2 AR_AE_ALLOC_REC_GT_N3) */
       a2.rowid,
       a3.link_id,
       a3.line_id,
       a3.amt,
       a3.acctd_amt
from ar_ae_alloc_rec_gt a2,
(select  /*+ INDEX(a1 AR_AE_ALLOC_REC_GT_N3) */
         a1.ae_id                   ae_id,
         decode(p_type_acct,
                'ED_ADJ', a1.ae_tax_link_id_ed_adj,
                'UNED'  , a1.ae_tax_link_id_uned,
                'PAY'   , a1.ae_tax_link_id)          link_id,
         a1.ae_customer_trx_line_id line_id,
         sum(a1.ae_pro_amt)         amt,
         sum(a1.ae_pro_acctd_amt)   acctd_amt
from ar_ae_alloc_rec_gt a1
where a1.ae_id = g_id
and a1.ae_account_class IN ('REVEARN','REVUNEARN') --MAINTAINLINKTAXID
group by
         a1.ae_id,
		 decode(p_type_acct,
                'ED_ADJ', a1.ae_tax_link_id_ed_adj,
                'UNED'  , a1.ae_tax_link_id_uned,
                'PAY'   , a1.ae_tax_link_id),
         a1.ae_customer_trx_line_id) a3
where a2.ae_id = g_id
and a3.ae_id = a2.ae_id
and a2.ae_link_to_cust_trx_line_id = a3.line_id
and a2.ae_account_class = 'TAX'
and decode(p_type_acct,
           'ED_ADJ', a2.ae_tax_link_id_ed_adj,
           'UNED'  , a2.ae_tax_link_id_uned,
           'PAY'   , a2.ae_tax_link_id) = a3.link_id
order by a3.link_id, (abs(a3.amt) + abs(a3.acctd_amt)) DESC, a3.line_id;

TYPE num_type   IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
TYPE rowid_type IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

rowid_tbl      rowid_type;
line_id_tbl    num_type;
link_id_tbl    num_type;
amt_tbl        num_type;
acctd_amt_tbl  num_type;

l_last_fetch BOOLEAN := FALSE;

prev_sum_of_amounts NUMBER;
prev_link_id        NUMBER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Set_Taxable_Amt()+');
   END IF;

   OPEN set_taxable_and_link;

   prev_link_id := -9999;
   prev_sum_of_amounts := 0;

   LOOP
    --initialize record

      FETCH set_taxable_and_link BULK COLLECT INTO
            rowid_tbl,
            link_id_tbl,
            line_id_tbl,
            amt_tbl,
            acctd_amt_tbl
        LIMIT g_bulk_fetch_rows;

      IF set_taxable_and_link%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF (rowid_tbl.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Set_Taxable_Amt: ' || 'COUNT = 0 and LAST FETCH ');
         END IF;
         EXIT;
      END IF;

      FOR i IN rowid_tbl.FIRST .. rowid_tbl.LAST LOOP

        --Initialize the sum of amounts and link to that of new link line
          IF prev_link_id <> link_id_tbl(i) THEN
             prev_link_id := link_id_tbl(i);
             prev_sum_of_amounts := 0;
          END IF;

       --Verify whether there exists a non zero amount, accounted amount for link id
          IF  ((abs(amt_tbl(i)) + abs(acctd_amt_tbl(i))) = 0)
              AND prev_link_id = link_id_tbl(i)
              AND prev_sum_of_amounts = 0 THEN
              link_id_tbl(i) := '';
          END IF;

          prev_sum_of_amounts := prev_sum_of_amounts + abs(amt_tbl(i)) + abs(acctd_amt_tbl(i));
      END LOOP;

    --Bulk update
      FORALL m IN rowid_tbl.FIRST .. rowid_tbl.LAST
        UPDATE ar_ae_alloc_rec_gt
        SET ae_pro_taxable_amt       = amt_tbl(m),
            ae_pro_taxable_acctd_amt = acctd_amt_tbl(m),
            ae_tax_link_id_act       = link_id_tbl(m)
        WHERE rowid = rowid_tbl(m)
        AND link_id_tbl(m) IS NOT NULL;

   --Exit if Last fetch
      IF l_last_fetch THEN
         EXIT;
      END IF;

   END LOOP; --Bulk fetch

   CLOSE set_taxable_and_link;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Set_Taxable_Amt()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Set_Taxable_Amt');
     END IF;
     RAISE;

END Set_Taxable_Amt;


/* ==========================================================================
 | PROCEDURE Set_Taxable_Split_Amt
 |
 | DESCRIPTION
 |      Derive Taxable split amounts for Tax, when this routine is called the
 |      table has to exist. Required to ensure that the taxable amount is not
 |      overstated if the tax line has splits.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |       p_type_acct      IN    Indicates accounting for earned, unearned
 |                              discounts or adjustments
 *==========================================================================*/
PROCEDURE Set_Taxable_Split_Amt(p_type_acct IN VARCHAR2) IS

CURSOR set_taxable_split IS
select /*+ INDEX(a1 AR_AE_ALLOC_REC_GT_N3) */
       a1.rowid                       row_id,
       a1.ae_link_to_cust_trx_line_id inv_line_id,
       a1.ae_tax_id                   tax_id,
       a1.ae_tax_type                 tax_type,
       a1.ae_code_combination_id      ae_code_combination_id,
       a1.ae_collected_tax_ccid       ae_collected_tax_ccid,
       a1.ae_pro_taxable_amt          pro_taxable_amt,
       a1.ae_pro_taxable_acctd_amt    pro_taxable_acctd_amt,
       0                              taxable_amt_split,
       0                              taxable_acctd_amt_split,
       ''                             taxable_amt_r_split,
       ''                             taxable_acctd_amt_r_split
from ar_ae_alloc_rec_gt a1,
     (select /*+ INDEX(a2 AR_AE_ALLOC_REC_GT_N3) */
             a2.ae_link_to_cust_trx_line_id ae_link_to_cust_trx_line_id,
             a2.ae_tax_type                 ae_tax_type,
             a2.ae_tax_id                   ae_tax_id
      from ar_ae_alloc_rec_gt a2
      where a2.ae_id = g_id
      and a2.ae_account_class = 'TAX'
      group by a2.ae_link_to_cust_trx_line_id,
               a2.ae_tax_type,
               a2.ae_tax_id
      having count(*) > 1) a3
where a1.ae_id = g_id
and a1.ae_account_class = 'TAX'
and a1.ae_link_to_cust_trx_line_id = a3.ae_link_to_cust_trx_line_id
and a1.ae_tax_id = a3.ae_tax_id
and a1.ae_tax_type = a3.ae_tax_type
order by a1.ae_link_to_cust_trx_line_id,
         a1.ae_tax_type,
         a1.ae_tax_id,
         decode(a1.ae_collected_tax_ccid,
                '',2,
                1),
         a1.ae_code_combination_id,
         a1.ae_collected_tax_ccid;

TYPE num_type   IS TABLE OF NUMBER       INDEX BY BINARY_INTEGER;
TYPE var_type   IS TABLE OF VARCHAR2(3)  INDEX BY BINARY_INTEGER;
TYPE rowid_type IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

rowid_tbl                     rowid_type;
line_id_tbl                   num_type;
tax_id_tbl                    num_type;
tax_type_tbl                  var_type;
taxable_amt_tbl               num_type;
taxable_acctd_amt_tbl         num_type;
taxable_amt_split_tbl         num_type;
taxable_acctd_amt_split_tbl   num_type;
taxable_amt_recov_tbl         num_type;
taxable_acctd_amt_recov_tbl   num_type;
tax_ccid_tbl                  num_type;
tax_collected_ccid_tbl        num_type;

l_last_fetch                  BOOLEAN := FALSE;
l_prev_customer_trx_line_id   NUMBER;
l_prev_tax_id                 NUMBER;
l_prev_tax_type               VARCHAR2(3);
l_prev_ccid                   NUMBER;
l_prev_collected_ccid         NUMBER;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Set_Taxable_Split_Amt()+');
   END IF;

   OPEN set_taxable_split;

   l_prev_customer_trx_line_id := -9999;
   l_prev_tax_id := -9999;
   l_prev_tax_type := 'XXX';
   l_prev_ccid := -9999;
   l_prev_collected_ccid := -9999;

   LOOP
    --initialize record

      FETCH set_taxable_split BULK COLLECT INTO
            rowid_tbl,
            line_id_tbl,
            tax_id_tbl,
            tax_type_tbl,
            tax_ccid_tbl,
            tax_collected_ccid_tbl,
            taxable_amt_tbl,
            taxable_acctd_amt_tbl,
            taxable_amt_split_tbl,
            taxable_acctd_amt_split_tbl,
            taxable_amt_recov_tbl,
            taxable_acctd_amt_recov_tbl
        LIMIT g_bulk_fetch_rows;

      IF set_taxable_split%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

      IF (rowid_tbl.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Set_Taxable_Split_Amt: ' || 'COUNT = 0 and LAST FETCH ');
         END IF;
         EXIT;
      END IF;

      FOR i IN rowid_tbl.FIRST .. rowid_tbl.LAST LOOP
        /*------------------------------------------------------------------+
         | For splits set the second, third splits to 0, so that only the   |
         | first split taxable will be used in sum function, therby ensuring|
         | that the taxable amount is counted only once in Build_Tax.       |
         +------------------------------------------------------------------*/
          IF l_prev_customer_trx_line_id = line_id_tbl(i)
              AND l_prev_tax_id = tax_id_tbl(i)
              AND l_prev_tax_type = tax_type_tbl(i) THEN
             taxable_amt_split_tbl(i)       := 0;
             taxable_acctd_amt_split_tbl(i) := 0;

             IF l_prev_ccid <> tax_ccid_tbl(i) THEN
                taxable_amt_recov_tbl(i)       :=  taxable_amt_tbl(i);
                taxable_acctd_amt_recov_tbl(i) := taxable_acctd_amt_tbl(i);
             END IF;

          ELSE
             taxable_amt_split_tbl(i)       := taxable_amt_tbl(i);
             taxable_acctd_amt_split_tbl(i) := taxable_acctd_amt_tbl(i);
          END IF;

          l_prev_customer_trx_line_id := line_id_tbl(i);
          l_prev_tax_id := tax_id_tbl(i);
          l_prev_tax_type := tax_type_tbl(i);
          l_prev_ccid := tax_ccid_tbl(i);
          l_prev_collected_ccid := tax_collected_ccid_tbl(i);

      END LOOP;

    --Bulk update
      FORALL m IN rowid_tbl.FIRST .. rowid_tbl.LAST
        UPDATE ar_ae_alloc_rec_gt
        SET ae_pro_split_taxable_amt       = taxable_amt_split_tbl(m),
            ae_pro_split_taxable_acctd_amt = taxable_acctd_amt_split_tbl(m),
            ae_pro_recov_taxable_amt       = taxable_amt_recov_tbl(m),
            ae_pro_recov_taxable_acctd_amt = taxable_acctd_amt_recov_tbl(m)
        WHERE rowid = rowid_tbl(m);

   --Exit if Last fetch
      IF l_last_fetch THEN
         EXIT;
      END IF;

   END LOOP; --Bulk fetch

   CLOSE set_taxable_split;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Set_Taxable_Split_Amt()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Set_Taxable_Split_Amt');
     END IF;
     RAISE;

END Set_Taxable_Split_Amt;

/* ==========================================================================
 | PROCEDURE Allocate_Tax_To_Rev
 |
 | DESCRIPTION
 |      Allocate Tax amount over revenue amounts based on Rule tax code source
 |      NONE
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |       p_type_acct      IN    Indicates accounting for earned, unearned
 |                              discounts or adjustments
 *==========================================================================*/
PROCEDURE Allocate_Tax_To_Rev(p_type_acct      IN VARCHAR2) IS

l_ctr  BINARY_INTEGER := 0;
l_ctr1 BINARY_INTEGER := 0;
l_ctr2 BINARY_INTEGER := 0;

l_rev_run_amt_tot             NUMBER ;
l_rev_run_pro_amt_tot         NUMBER ;
l_rev_run_acctd_amt_tot       NUMBER ;
l_rev_run_pro_acctd_amt_tot   NUMBER ;
l_tax_amt_pro_rev             NUMBER ;
l_tax_acctd_amt_pro_rev       NUMBER ;
l_weight_amt                  NUMBER ;
l_weight_acctd_amt            NUMBER ;
l_base_amt                    NUMBER ;
l_base_acctd_amt              NUMBER ;
l_prev_tax_cust_trx_line_id   NUMBER ;
l_prev_code_combination_id    NUMBER ;
l_prev_collected_tax_ccid     NUMBER ;
l_prev_tax_amt                NUMBER ;
l_prev_tax_acctd_amt          NUMBER ;

l_dummy                       VARCHAR2(1);
l_rev_rowid                   VARCHAR2(50);

l_not_found                   BOOLEAN := FALSE;

g_ae_alloc_tax_tbl   ar_ae_alloc_rec_gt%ROWTYPE;
g_ae_alloc_rev_tbl   ar_ae_alloc_rec_gt%ROWTYPE;
g_ae_alloc_empty_tbl ar_ae_alloc_rec_gt%ROWTYPE;

CURSOR alloc_tax_rev IS
       SELECT /*+ INDEX(ae1 AR_AE_ALLOC_REC_GT_N3) INDEX(ae2 AR_AE_ALLOC_REC_GT_N1) */
              ae2.rowid                          ,
              ae1.ae_customer_trx_line_id        ,
              ae1.ae_link_to_cust_trx_line_id    ,
              ae1.ae_code_combination_id         ,
              nvl(ae1.ae_collected_tax_ccid,-9999),
              ae1.ae_pro_amt                     ,
              ae1.ae_pro_acctd_amt               ,
              ae2.ae_sum_rev_amt                 ,
              ae2.ae_sum_rev_acctd_amt           ,
              ae2.ae_count                       ,
              ae2.ae_amount                      ,
              ae2.ae_acctd_amount
       FROM ar_ae_alloc_rec_gt ae1,
            ar_ae_alloc_rec_gt ae2
       WHERE ae1.ae_id = g_id
       AND   ae1.ae_account_class = 'TAX'
       AND   ae2.ae_id = ae1.ae_id
       AND   ae2.ae_account_class IN ('REVEARN','REVUNEARN') --MAINTAINTAXLINKID
       AND   ae1.ae_link_to_cust_trx_line_id = ae2.ae_customer_trx_line_id
       AND   ((ae1.ae_pro_amt <> 0)
               OR (ae1.ae_pro_acctd_amt <> 0))
       ORDER BY ae1.ae_customer_trx_line_id, ae1.ae_link_to_cust_trx_line_id;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Allocate_Tax_To_Rev: ' ||  'ARP_ALLOCATION_PKG.Alloc_Tax_To_Rev()+');
   END IF;

   IF (((p_type_acct = 'ED_ADJ') AND (g_ae_rule_rec.tax_code_source1 = 'NONE'))
       OR ((p_type_acct = 'UNED') AND (g_ae_rule_rec.tax_code_source2 = 'NONE'))) THEN

    /*------------------------------------------------------------------------------+
     | Allocate each tax line to the Revenue lines for an Invoice line              |
     +------------------------------------------------------------------------------*/
      l_tax_amt_pro_rev              := 0;
      l_tax_acctd_amt_pro_rev        := 0;
      l_rev_run_amt_tot              := 0;
      l_rev_run_acctd_amt_tot        := 0;
      l_rev_run_pro_amt_tot          := 0;
      l_rev_run_pro_acctd_amt_tot    := 0;
      l_prev_tax_amt                 := 0;
      l_prev_tax_acctd_amt           := 0;

      OPEN alloc_tax_rev;

      l_prev_tax_cust_trx_line_id := -9999;
      l_prev_code_combination_id  := -9999;
      l_prev_collected_tax_ccid   := -9999;

      LOOP

      --no need to initialize as a fetch will return a value
      --and for last row we want to retain the old values

      --fetch from cursor
         FETCH alloc_tax_rev
         INTO l_rev_rowid,
              g_ae_alloc_tax_tbl.ae_customer_trx_line_id     ,
              g_ae_alloc_tax_tbl.ae_link_to_cust_trx_line_id ,
              g_ae_alloc_tax_tbl.ae_code_combination_id      ,
              g_ae_alloc_tax_tbl.ae_collected_tax_ccid       ,
              g_ae_alloc_tax_tbl.ae_pro_amt                  ,
              g_ae_alloc_tax_tbl.ae_pro_acctd_amt            ,
              g_ae_alloc_rev_tbl.ae_sum_rev_amt              ,
              g_ae_alloc_rev_tbl.ae_sum_rev_acctd_amt        ,
              g_ae_alloc_rev_tbl.ae_count                    ,
              g_ae_alloc_rev_tbl.ae_amount                   ,
              g_ae_alloc_rev_tbl.ae_acctd_amount               ;

       --Set cursor not found flag
         IF alloc_tax_rev%NOTFOUND THEN
            l_not_found := TRUE;
         END IF;

       /*------------------------------------------------------------------------------+
        | If current tax line not equals previous then check for rounding corrections  |
        +------------------------------------------------------------------------------*/
         IF ((l_prev_tax_cust_trx_line_id <> g_ae_alloc_tax_tbl.ae_customer_trx_line_id)
             OR ((l_prev_tax_cust_trx_line_id = g_ae_alloc_tax_tbl.ae_customer_trx_line_id)
                 AND ((l_prev_code_combination_id <> g_ae_alloc_tax_tbl.ae_code_combination_id)
                       OR (l_prev_collected_tax_ccid <> g_ae_alloc_tax_tbl.ae_collected_tax_ccid)))
             OR (l_not_found))
           AND (l_prev_tax_cust_trx_line_id <> -9999) THEN

           /*------------------------------------------------------------------------------+
            | Abnormal rounding correction condition this should never happen, however this|
            | is a safety mechanism. Check that tax all tax is allocated over revenue lines|
            +------------------------------------------------------------------------------*/
             IF ((l_rev_run_pro_amt_tot <> l_prev_tax_amt) OR
                      (l_rev_run_pro_acctd_amt_tot <> l_prev_tax_acctd_amt))             THEN

                IF PG_DEBUG in ('Y', 'C') THEN
                   arp_standard.debug('Allocate_Tax_To_Rev: ' || 'l_rev_run_pro_amt_tot :'
                   || l_rev_run_pro_amt_tot ||
                   ' <> ' || 'l_prev_tax_amt :'
                   || l_prev_tax_amt);
                   arp_standard.debug('Allocate_Tax_To_Rev: ' || 'l_rev_run_pro_acctd_amt_tot :'
                   || l_rev_run_pro_acctd_amt_tot ||
                   ' <> ' || 'l_prev_tax_acctd_amt :'
                   || l_prev_tax_acctd_amt);
                END IF;

                RAISE rounding_error;

             END IF; --End if rounding error

             l_tax_amt_pro_rev              := 0;
             l_tax_acctd_amt_pro_rev        := 0;
             l_rev_run_amt_tot              := 0;
             l_rev_run_acctd_amt_tot        := 0;
             l_rev_run_pro_amt_tot          := 0;
             l_rev_run_pro_acctd_amt_tot    := 0;
             l_prev_tax_amt                 := 0;
             l_prev_tax_acctd_amt           := 0;

          END IF; --prev tax line not equal to current tax line

        --cursor fetch returns not data
          IF l_not_found THEN
             EXIT; --loop
          END IF;

          l_weight_amt                   := 0;
          l_weight_acctd_amt             := 0;
          l_base_amt                     := 0;
          l_base_acctd_amt               := 0;

        /*------------------------------------------------------------------------------+
         | Set Revenue amount and accounted amounts totals                              |
         +------------------------------------------------------------------------------*/
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Allocate_Tax_To_Rev: ' || 'Invoice line                      '
                               || g_ae_alloc_tax_tbl.ae_link_to_cust_trx_line_id);
             arp_standard.debug('Allocate_Tax_To_Rev: ' || 'g_ae_alloc_rev_tbl.ae_sum_rev_amt '
                               || g_ae_alloc_rev_tbl.ae_sum_rev_amt);
             arp_standard.debug('Allocate_Tax_To_Rev: ' || 'g_ae_alloc_rev_tbl.ae_sum_rev_acctd_amt '
                               || g_ae_alloc_rev_tbl.ae_sum_rev_acctd_amt);
             arp_standard.debug('Allocate_Tax_To_Rev: ' || 'Tax amount            =           '
                               || g_ae_alloc_tax_tbl.ae_pro_amt);
             arp_standard.debug('Allocate_Tax_To_Rev: ' || 'Tax accounted amount  =           '
                               || g_ae_alloc_tax_tbl.ae_pro_acctd_amt);
          END IF;

       /*------------------------------------------------------------------------------+
        | Set base to prorate tax over revenue, this is applicable when for an Invoice |
        | Line the revenue amount or accounted amount is zero so equal weights are     |
        | to the 0 distributions                                                       |
        +------------------------------------------------------------------------------*/
          IF g_ae_alloc_rev_tbl.ae_sum_rev_amt = 0 THEN
             l_weight_amt := 1;
             l_base_amt   := g_ae_alloc_rev_tbl.ae_count;
          ELSE
             l_weight_amt := g_ae_alloc_rev_tbl.ae_amount;
             l_base_amt   := g_ae_alloc_rev_tbl.ae_sum_rev_amt;
          END IF;

          IF g_ae_alloc_rev_tbl.ae_sum_rev_acctd_amt = 0 THEN
             l_weight_acctd_amt := 1;
             l_base_acctd_amt   := g_ae_alloc_rev_tbl.ae_count;
          ELSE
             l_weight_acctd_amt := g_ae_alloc_rev_tbl.ae_acctd_amount;
             l_base_acctd_amt   := g_ae_alloc_rev_tbl.ae_sum_rev_acctd_amt;
          END IF;

       /*------------------------------------------------------------------------------+
        | Maintain running total amounts for Revenue amounts and accounted amounts     |
        +------------------------------------------------------------------------------*/
          l_rev_run_amt_tot       := l_rev_run_amt_tot + l_weight_amt;
          l_rev_run_acctd_amt_tot := l_rev_run_acctd_amt_tot + l_weight_acctd_amt;

          l_tax_amt_pro_rev := arpcurr.CurrRound(l_rev_run_amt_tot / l_base_amt
                                  * g_ae_alloc_tax_tbl.ae_pro_amt,
                                  g_cust_inv_rec.invoice_currency_code) - l_rev_run_pro_amt_tot ;

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Allocate_Tax_To_Rev: ' || 'l_tax_amt_pro_rev ' || l_tax_amt_pro_rev);
          END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated Revenue amount in currency of Invoice             |
         +------------------------------------------------------------------------------*/
           l_rev_run_pro_amt_tot := l_rev_run_pro_amt_tot + l_tax_amt_pro_rev;

        /*------------------------------------------------------------------------------+
         | Calculate accounted amount for revenue amount allocated to each revenue line |
         +------------------------------------------------------------------------------*/
           l_tax_acctd_amt_pro_rev := arpcurr.CurrRound(l_rev_run_acctd_amt_tot /
                                        l_base_acctd_amt
                                        * g_ae_alloc_tax_tbl.ae_pro_acctd_amt,
                                        g_ae_sys_rec.base_currency) - l_rev_run_pro_acctd_amt_tot ;
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Allocate_Tax_To_Rev: ' || 'l_tax_acctd_amt_pro_rev ' || l_tax_acctd_amt_pro_rev);
           END IF;

        /*------------------------------------------------------------------------------+
         | Running total for prorated Revenue accounted amount in base currency         |
         +------------------------------------------------------------------------------*/
           l_rev_run_pro_acctd_amt_tot := l_rev_run_pro_acctd_amt_tot + l_tax_acctd_amt_pro_rev;

           l_prev_tax_cust_trx_line_id := g_ae_alloc_tax_tbl.ae_customer_trx_line_id;
           l_prev_code_combination_id  := g_ae_alloc_tax_tbl.ae_code_combination_id;
           l_prev_collected_tax_ccid   := g_ae_alloc_tax_tbl.ae_collected_tax_ccid;
           l_prev_tax_amt              := g_ae_alloc_tax_tbl.ae_pro_amt;
           l_prev_tax_acctd_amt        := g_ae_alloc_tax_tbl.ae_pro_acctd_amt;

        /*------------------------------------------------------------------------------+
         | Add tax allocated amount and accounted amount to revenue amounts allocated   |
         +------------------------------------------------------------------------------*/
           UPDATE ar_ae_alloc_rec_gt ae1
           SET ae1.ae_pro_amt       = ae1.ae_pro_amt + l_tax_amt_pro_rev,
               ae1.ae_pro_acctd_amt = ae1.ae_pro_acctd_amt + l_tax_acctd_amt_pro_rev
           WHERE ae1.rowid = l_rev_rowid;

      END LOOP; --End loop allocate tax

      CLOSE alloc_tax_rev;

   END IF; --End if TAX_CODE_SOURCE = 'NONE'

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Allocate_Tax_To_Rev: ' ||  'ARP_ALLOCATION_PKG.Alloc_Tax_To_Rev()-');
   END IF;

EXCEPTION
  WHEN rounding_error THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Allocate_Tax_To_Rev: ' || 'Rounding Error: ARP_ALLOCATION_PKG.Alloc_Tax_To_Rev' );
     END IF;
     fnd_message.set_name('AR','AR_ROUNDING_ERROR');
     fnd_message.set_token('ROUTINE','ARP_ALLOCATION_PKG.ALLOC_TAX_TO_REV');
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Allocate_Tax_To_Rev: ' || 'EXCEPTION: ARP_ALLOCATION_PKG.Alloc_Tax_To_Rev');
     END IF;
     RAISE;

END Allocate_Tax_To_Rev;

/* ==========================================================================
 | PROCEDURE Set_Rev_Links
 |
 | DESCRIPTION
 |      Sets Actual Revenue link id's using rules and the tax link id total
 |      table. It is necessary to set the actual link id based on whether
 |      a given revenue line has associated tax allocations, if it does not
 |      then the link id is null.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |       p_type_acct      IN    Indicates accounting for earned, unearned
 |                              discounts or adjustments
 *==========================================================================*/
PROCEDURE Set_Rev_Links(p_type_acct      IN VARCHAR2) IS

l_gl_account_source    ar_receivables_trx.gl_account_source%TYPE    ;
l_tax_code_source      ar_receivables_trx.tax_code_source%TYPE      ;
l_tax_recoverable_flag ar_receivables_trx.tax_recoverable_flag%TYPE ;

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_ALLOCATION_PKG.Set_Rev_Links()+');
    END IF;

   /*-------------------------------------------------------------------------------+
    | Set Rules to determine whether Revenue link id needs to be set                |
    +-------------------------------------------------------------------------------*/
/*
     Get_Rules(p_type_acct            => p_type_acct,
               p_gl_account_source    => l_gl_account_source,
               p_tax_code_source      => l_tax_code_source,
               p_tax_recoverable_flag => l_tax_recoverable_flag);
*/
--}
    /*--------------------------------------------------------------------------------+
     | Set up actual link ids for revenue lines so that at summarization only required|
     | number of lines are created.                                                   |
     +--------------------------------------------------------------------------------*/
--{HYUDETUPT
--      UPDATE /*+ INDEX(ae1 AR_AE_ALLOC_REC_GT_N3) */
--             ar_ae_alloc_rec_gt ae1
--      SET ae1.ae_tax_link_id_act = decode(p_type_acct,
--                                          'ED_ADJ', ae1.ae_tax_link_id_ed_adj,
--                                          'UNED'  , ae1.ae_tax_link_id_uned  ,
--                                          '')
--      WHERE ae1.ae_id = g_id
--      AND ae1.ae_account_class = 'REVEARN'
--      AND (((ae1.ae_pro_amt <> 0) OR (ae1.ae_pro_acctd_amt <> 0))
--           AND decode(p_type_acct,
--                       'ED_ADJ', decode(ae1.ae_tax_link_id_ed_adj,
--                                        '','N',
--                                        'Y'),
--                       'UNED', decode(ae1.ae_tax_link_id_uned,
--                                      '','N',
--                                      'Y'),
--                       'N') = 'Y')
--      AND EXISTS
--              (SELECT /*+ INDEX(ae1 AR_AE_ALLOC_REC_GT_N3) */
--                      ae2.ae_account_class
--               FROM ar_ae_alloc_rec_gt ae2
--               WHERE ae2.ae_account_class = 'TAX'
--               AND ae2.ae_id = ae1.ae_id
--               AND decode(p_type_acct,
--                          'ED_ADJ', ae2.ae_tax_link_id_ed_adj,
--                          'UNED'  , ae2.ae_tax_link_id_uned  ,
--                          'Y') = decode(p_type_acct,
--                                       'ED_ADJ', ae1.ae_tax_link_id_ed_adj,
--                                       'UNED'  , ae1.ae_tax_link_id_uned  ,
--                                       'N')
--               AND (((l_tax_code_source = 'INVOICE')
--                      OR (l_tax_code_source = 'ACTIVITY'))
--                    OR ((l_tax_code_source = 'NONE')
--                         AND (ae2.ae_collected_tax_ccid IS NOT NULL)
--                         AND ((g_ae_rule_rec.line_amt_alloc <> 0)
--                              OR (g_ae_rule_rec.line_acctd_amt_alloc <> 0)) ))
--              );
--}
-- for a rev distribution ae_tax_link_id_act = ref_customer_trx_line_id
-- if it exists a tax distribution with ae_tax_link_id equal to it
arp_standard.debug('setlink 1');
UPDATE /*+ index( a1 AR_AE_ALLOC_REC_GT_N4 ) */
   ar_ae_alloc_rec_gt a1
   SET (a1.ae_tax_link_id_act) =
       (SELECT /*+ index( a2 AR_AE_ALLOC_REC_GT_N4 ) */
            MAX(a2.ae_tax_link_id)
          FROM ar_ae_alloc_rec_gt a2
         WHERE a2.ae_id = g_id
           AND a2.ref_account_class = 'TAX'
           AND a1.ae_customer_trx_line_id = a2.ae_tax_link_id)
 WHERE a1.ae_id  = g_id
   AND a1.ref_account_class IN ('REV','UNEARN','UNBILL');

/*MAINTAINTAXLINKID
arp_standard.debug('setlink 2');
-- for a tax distribution ae_tax_link_id_act = line_to_cust_trx_line_id
-- if it exists a rev distribution with ref_customer_trx_line_id equal to it
UPDATE ar_ae_alloc_rec_gt a1
   SET (a1.ae_tax_link_id_act) =
       (SELECT MAX(a2.ae_tax_link_id)
          FROM ar_ae_alloc_rec_gt a2
         WHERE a2.ae_id = g_id
           AND a2.ref_account_class IN ('REV','UNEARN','UNBILL')
           AND a1.ae_tax_link_id = a2.ae_customer_trx_line_id)
 WHERE a1.ae_id  = g_id
   AND a1.ref_account_class = 'TAX';
*/
/*
-- We need to update taxable_amount for tax line
-- We need to create 2 buckets
--  1: SUM(ae_pro_amt) where bucket IN (ED_LINE, UNED_LINE, APP_LINE)
--  2: Individual elements ae_pro_amt where bucket IN (ED_TAX, UNED_TAX, APP_TAX)
-- Group by ae_tax_link_id_act
--  3: Proration using the elements 2 and allocation amt in 1
-- ==> ae_pro_taxable_amt, ae_pro_split_taxable_amt,

UPDATE ar_ae_alloc_rec_gt a1
   SET (a1.ae_tax_link_id_act,
        a1.AE_PRO_TAXABLE_AMT,
        a1.AE_PRO_TAXABLE_ACCTD_AMT,
        a1.AE_PRO_SPLIT_TAXABLE_AMT,
        a1.AE_PRO_SPLIT_TAXABLE_ACCTD_AMT,
        a1.AE_PRO_RECOV_TAXABLE_AMT,
        a1.AE_PRO_RECOV_TAXABLE_ACCTD_AMT) =
       (SELECT MAX(a2.ae_tax_link_id),
               MAX(a2.AE_PRO_AMT),
               MAX(a2.AE_PRO_ACCTD_AMT),
               MAX(a2.AE_PRO_AMT),
               MAX(a2.AE_PRO_ACCTD_AMT),
               MAX(a2.AE_PRO_AMT),
               MAX(a2.AE_PRO_ACCTD_AMT)
          FROM ar_ae_alloc_rec_gt a2
         WHERE a2.ae_id = g_id
           AND a2.ref_account_class = 'REV'
           AND a1.ae_tax_link_id = a2.ae_customer_trx_line_id)
 WHERE a1.ae_id  = g_id
   AND a1.ref_account_class = 'TAX';
*/

arp_standard.debug(' setlink 3');
--}

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_ALLOCATION_PKG.Set_Rev_Links()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Set_Rev_Links'||SQLERRM);
     RAISE;

END Set_Rev_Links;

/* ==========================================================================
 | PROCEDURE Get_Rules
 |
 | DESCRIPTION
 |      Gets the actual rule for the receivable activity
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_type_acct      IN    Indicates earned, unearned discount or adjustment
 |                           accounting
 *==========================================================================*/
PROCEDURE Get_Rules(p_type_acct            IN     VARCHAR2,
                    p_gl_account_source    OUT NOCOPY   VARCHAR2,
                    p_tax_code_source      OUT NOCOPY   VARCHAR2,
                    p_tax_recoverable_flag OUT NOCOPY   VARCHAR2) IS

BEGIN
   arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Rules()+');

 /*----------------------------------------------------------------------------+
  | Set Rules for Discounts, Adjustments and Finance charges                   |
  +----------------------------------------------------------------------------*/
   IF ((p_type_acct = 'ED_ADJ') OR (p_type_acct = 'PAY')) THEN

      p_gl_account_source    := g_ae_rule_rec.gl_account_source1    ;
      p_tax_code_source      := g_ae_rule_rec.tax_code_source1      ;
      p_tax_recoverable_flag := g_ae_rule_rec.tax_recoverable_flag1 ;

 /*----------------------------------------------------------------------------+
  | Set Rules for Unearned Discounts                                           |
  +----------------------------------------------------------------------------*/
   ELSIF p_type_acct = 'UNED' THEN

      p_gl_account_source           := g_ae_rule_rec.gl_account_source2    ;
      p_tax_code_source             := g_ae_rule_rec.tax_code_source2      ;
      p_tax_recoverable_flag        := g_ae_rule_rec.tax_recoverable_flag2 ;

   END IF;

   arp_standard.debug( 'ARP_ALLOCATION_PKG.Get_Rules()-');

EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Get_Rules');
     RAISE;

END Get_Rules;

/* ==========================================================================
 | PROCEDURE Build_Lines
 |
 | DESCRIPTION
 |      Build actual accounting entries for Tax accounting for discounts and
 |      adjustments
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_type_acct      IN    Indicates earned, unearned discount or adjustment
 |                           accounting
 *==========================================================================*/
PROCEDURE Build_Lines IS --(p_type_acct      IN VARCHAR2) IS

l_gl_account_source    ar_receivables_trx.gl_account_source%TYPE    ;
l_tax_code_source      ar_receivables_trx.tax_code_source%TYPE      ;
l_tax_recoverable_flag ar_receivables_trx.tax_recoverable_flag%TYPE ;
l_ae_line_init_rec     ar_ae_alloc_rec_gt%ROWTYPE                     ;

BEGIN

    arp_standard.debug( 'ARP_ALLOCATION_PKG.Build_Lines()+');

--  Get_Rules(p_type_acct            => p_type_acct,
--            p_gl_account_source    => l_gl_account_source,
--            p_tax_code_source      => l_tax_code_source,
--            p_tax_recoverable_flag => l_tax_recoverable_flag);

 /*----------------------------------------------------------------------------+
  | Assign Currency Exchange rate information to initialisation record         |
  +----------------------------------------------------------------------------*/
   l_ae_line_init_rec.ae_id                        := g_id                                 ;
   l_ae_line_init_rec.ae_source_id                 := g_ae_doc_rec.source_id               ;
   l_ae_line_init_rec.ae_source_table              := g_ae_doc_rec.source_table            ;
   l_ae_line_init_rec.ae_currency_code             := g_cust_inv_rec.invoice_currency_code ;
   l_ae_line_init_rec.ae_currency_conversion_rate  := g_cust_inv_rec.exchange_rate         ;
   l_ae_line_init_rec.ae_currency_conversion_type  := g_cust_inv_rec.exchange_rate_type    ;
   l_ae_line_init_rec.ae_currency_conversion_date  := g_cust_inv_rec.exchange_date         ;

--Set Third party details
   IF (g_cust_inv_rec.drawee_site_use_id IS NOT NULL) THEN --if Bill
      l_ae_line_init_rec.ae_third_party_id            := g_cust_inv_rec.drawee_id;
      l_ae_line_init_rec.ae_third_party_sub_id        := g_cust_inv_rec.drawee_site_use_id  ;
   ELSE
      l_ae_line_init_rec.ae_third_party_id            := g_cust_inv_rec.bill_to_customer_id   ;
      l_ae_line_init_rec.ae_third_party_sub_id        := g_cust_inv_rec.bill_to_site_use_id   ;
   END IF;

 /*----------------------------------------------------------------------------+
  | Build Revenue lines based on rules. For payments only deferred tax is to be|
  | moved so don not call build revenue routine at all                         |
  +----------------------------------------------------------------------------*/
    Build_Rev(p_gl_account_source     => l_gl_account_source     ,
              p_tax_code_source       => l_tax_code_source       ,
              p_tax_recoverable_flag  => l_tax_recoverable_flag  ,
              p_ae_line_init_rec      => l_ae_line_init_rec        );

 /*----------------------------------------------------------------------------+
  | Build Tax lines based on rules, if boundary condition then only deferred   |
  | tax lines will be created, with taxable off the original Invoice.          |
  +----------------------------------------------------------------------------*/
   Build_Tax(p_tax_code_source       => l_tax_code_source       ,
             p_tax_recoverable_flag  => l_tax_recoverable_flag  ,
             p_ae_line_init_rec      => l_ae_line_init_rec        );

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'ARP_ALLOCATION_PKG.Build_Lines()-');
 END IF;

EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Build_Lines');
     RAISE;

END Build_Lines;

/* ==========================================================================
 | PROCEDURE Build_Rev
 |
 | DESCRIPTION
 |    Build actual accounting entries for Revenue or line amounts for
 |    discounts and adjustments
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_type_acct             IN    Indicates earned, unearned discount or
 |                                  adjustment accounting
 |    p_gl_account_source     IN    Source of gl account
 |    p_tax_recoverable_flag  IN    Indicates whether TAX is recoverable
 |    p_ae_line_init_rec      IN    Initialization record contains details
 |                                  for exchange rate, source table, id
 |                                  common to all accounting entries
 *==========================================================================*/
PROCEDURE Build_Rev(p_gl_account_source     IN ar_receivables_trx.gl_account_source%TYPE     ,
                    p_tax_code_source       IN ar_receivables_trx.tax_code_source%TYPE       ,
                    p_tax_recoverable_flag  IN ar_receivables_trx.tax_recoverable_flag%TYPE  ,
                    p_ae_line_init_rec      IN ar_ae_alloc_rec_gt%ROWTYPE                        ) IS

l_ae_line_rec         ar_ae_alloc_rec_gt%ROWTYPE                  ;
l_ctr                 BINARY_INTEGER                            ;
l_actual_account      ar_distributions.code_combination_id%TYPE ;
l_source_type         ar_distributions.source_type%TYPE         ;

--PL/SQL table object,this collection is used for bulk processing of inserts
TYPE ae_alloc_rec_gt_tab IS TABLE OF ar_ae_alloc_rec_gt%ROWTYPE INDEX BY BINARY_INTEGER;
l_ae_alloc_rec_gt_tab ae_alloc_rec_gt_tab;
l_ae_alloc_empty_tab  ae_alloc_rec_gt_tab;

l_last_fetch     BOOLEAN := FALSE;
l_bulk_index     NUMBER := 0;

l_line_charges_amt          NUMBER := 0;
l_line_charges_acctd_amt    NUMBER := 0;
l_freight_charges_amt       NUMBER := 0;
l_freight_charges_acctd_amt NUMBER := 0;

/*-------------------------------------------------------------------------------+
 | Summarize Revenue lines, this routine would be executed even in the case where|
 | revenue base amounts are zero, so the single accounting entry to activity GL  |
 | Account is built later, however if tax code source is NONE then there may be  |
 | tax allocated to its revenue, hence need to summarize. Note for payments we   |
 | dont need to summarize as only deferred tax is moved, However no additional   |
 | accounting is required.                                                       |
 +-------------------------------------------------------------------------------*/
  CURSOR l_summarize_rev IS
  SELECT /*+ INDEX(ae1 AR_AE_ALLOC_REC_GT_N3) */
         ae1.ae_tax_link_id_act,
         ae1.ae_customer_trx_line_id,
         ae1.ae_cust_trx_line_gl_dist_id,
         ae1.ae_ref_line_id,
         ae1.ref_account_class,
         ae1.activity_bucket,
         ae1.ref_dist_ccid,
         ae1.ref_mf_dist_flag,
         DECODE(DECODE(ae1.activity_bucket,
                 'APP_LINE' , 'ACTIVITY_GL_ACCOUNT',
                 'APP_TAX'  , 'ACTIVITY_GL_ACCOUNT',
                 'APP_FRT'  , 'ACTIVITY_GL_ACCOUNT',
                 'APP_CHRG' , 'ACTIVITY_GL_ACCOUNT',
                 'ADJ_LINE' , g_ae_rule_rec.gl_account_source1,
                 'ADJ_TAX'  , g_ae_rule_rec.gl_account_source1,
                 'ADJ_FRT'  , g_ae_rule_rec.gl_account_source1,
                 'ADJ_CHRG' , g_ae_rule_rec.gl_account_source1,
                 'ED_LINE'  , g_ae_rule_rec.gl_account_source1,
                 'ED_TAX'   , g_ae_rule_rec.gl_account_source1,
                 'ED_FRT'   , g_ae_rule_rec.gl_account_source1,
                 'ED_CHRG'  , g_ae_rule_rec.gl_account_source1,
                 'UNED_LINE', g_ae_rule_rec.gl_account_source2,
                 'UNED_TAX' , g_ae_rule_rec.gl_account_source2,
                 'UNED_FRT' , g_ae_rule_rec.gl_account_source2,
                 'UNED_CHRG', g_ae_rule_rec.gl_account_source2,
                              g_ae_rule_rec.gl_account_source1),
                'TAX_CODE_ON_INVOICE',DECODE(ae1.activity_bucket,
                                        'ADJ_LINE' , ae1.ae_override_ccid1,
                                        'ADJ_TAX'  , ae1.ae_override_ccid1,
                                        'ADJ_FRT'  , ae1.ae_override_ccid1,
                                        'ADJ_CHRG' , ae1.ae_override_ccid1,
                                        'ED_LINE'  , ae1.ae_override_ccid1,
                                        'ED_TAX'   , ae1.ae_override_ccid1,
                                        'ED_FRT'   , ae1.ae_override_ccid1,
                                        'ED_CHRG'  , ae1.ae_override_ccid1,
                                                     ae1.ae_override_ccid2),
                'ACTIVITY_GL_ACCOUNT',DECODE(ae1.activity_bucket,
                                       'ADJ_LINE' , ae1.ae_override_ccid1,
                                       'ADJ_TAX'  , ae1.ae_override_ccid1,
                                       'ADJ_FRT'  , ae1.ae_override_ccid1,
                                       'ADJ_CHRG' , ae1.ae_override_ccid1,
                                       'ED_LINE'  , ae1.ae_override_ccid1,
                                       'ED_TAX'   , ae1.ae_override_ccid1,
                                       'ED_FRT'   , ae1.ae_override_ccid1,
                                       'ED_CHRG'  , ae1.ae_override_ccid1,
                                       'APP_LINE' , g_ae_rule_rec.receivable_account,
                                       'APP_TAX'  , g_ae_rule_rec.receivable_account,
                                       'APP_FRT'  , g_ae_rule_rec.receivable_account,
                                       'APP_CHRG' , g_ae_rule_rec.receivable_account,
                                                    ae1.ae_override_ccid2),
                'REVENUE_ON_INVOICE',ae1.ae_code_combination_id,
                '') actual_account,
         nvl(ae1.ae_pro_amt,0) ae_pro_amt,
         nvl(ae1.ae_pro_acctd_amt,0) ae_pro_acctd_amt,
         nvl(ae1.ae_pro_frt_chrg_amt,0) ae_pro_frt_chrg_amt,
         nvl(ae1.ae_pro_frt_chrg_acctd_amt,0) ae_pro_frt_chrg_acctd_amt,
         nvl(ae1.ae_from_pro_amt,0) ae_from_pro_amt,
         nvl(ae1.ae_from_pro_acctd_amt,0) ae_from_pro_acctd_amt,
         nvl(ae1.ae_from_pro_chrg_amt,0) ae_from_pro_chrg_amt,
         nvl(ae1.ae_from_pro_chrg_acctd_amt,0) ae_from_pro_chrg_acctd_amt
  FROM   ar_ae_alloc_rec_gt ae1
  WHERE ae1.ae_id = g_id
  AND   ae1.ae_account_class IN ('REVEARN',
                                 'FREIGHT',
                                 'REVUNEARN',
                                 'CHARGES');
--  AND (((g_exec = 'ADJ')
--       AND (ae_ref_line_id IS NULL))
--       OR (p_type_acct = 'PAY' OR g_exec = 'ED' OR g_exec = 'UNED')) ;

g_ae_summ_rev_tbl   l_summarize_rev%ROWTYPE;

TYPE summarize_rev_cur IS TABLE OF l_summarize_rev%ROWTYPE;
g_ae_summ_rev_blk_tbl summarize_rev_cur;

BEGIN

 arp_standard.debug( 'ARP_ALLOCATION_PKG.Build_Rev()+');

 adj_code_combination_id := '';

 /*----------------------------------------------------------------------------+
  | Process all revenue lines to be built                                      |
  +----------------------------------------------------------------------------*/
   arp_standard.debug('Open l_summarize_rev +');

   OPEN l_summarize_rev;

   LOOP
   FETCH l_summarize_rev BULK COLLECT INTO g_ae_summ_rev_blk_tbl LIMIT g_bulk_fetch_rows;

   --reinitialize
   l_ae_alloc_rec_gt_tab := l_ae_alloc_empty_tab;
   l_bulk_index := 0;

      IF l_summarize_rev%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;

   FOR i IN 1..g_ae_summ_rev_blk_tbl.count LOOP
      --Assign the record from PL/SQL table to a cursor variable,this variable
      --is used for accessing the current record data in the following code
      g_ae_summ_rev_tbl := g_ae_summ_rev_blk_tbl(i);
      l_actual_account  := g_ae_summ_rev_tbl.actual_account;


/*----------------------------------------------------------------------------+
 | Populate source type for earned discounts                                  |
 +----------------------------------------------------------------------------*/
  IF g_ae_summ_rev_tbl.activity_bucket IN ('ED_LINE', 'ED_TAX', 'ED_FRT','ED_CHRG')  THEN
     l_source_type                 := 'EDISC' ;
    --Set the Activity GL Account
    -- l_actual_account := g_ae_rule_rec.code_combination_id1;
  /*----------------------------------------------------------------------------+
   | Populate source type for finance charges                                   |
   +----------------------------------------------------------------------------*/
  ELSIF g_ae_summ_rev_tbl.activity_bucket IN ('ADJ_LINE', 'ADJ_TAX', 'ADJ_FRT','ADJ_CHRG') THEN

     IF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN
           l_source_type              := 'ADJ';
     ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN
           l_source_type              := 'FINCHRG';
     END IF;

     IF g_ae_summ_rev_tbl.ae_cust_trx_line_gl_dist_id = -9 THEN
     --For adjustment boundary ccid
     adj_boundary_account
     (p_receivables_trx_id   => g_receivables_trx_id,
      p_bucket               => g_ae_summ_rev_tbl.activity_bucket,
      p_ctlgd_id             => g_ae_summ_rev_tbl.ae_cust_trx_line_gl_dist_id,
      x_ccid                 => l_actual_account);
     END IF;

    --Set the Activity GL Account
    IF l_actual_account IS NULL THEN
     l_actual_account := g_ae_rule_rec.code_combination_id1;
    END IF;


 /*----------------------------------------------------------------------------+
  | Populate source type for unearned discounts                                |
  +----------------------------------------------------------------------------*/
  ELSIF g_ae_summ_rev_tbl.activity_bucket IN ('UNED_LINE', 'UNED_TAX', 'UNED_FRT','UNED_CHRG') THEN
     l_source_type                 := 'UNEDISC' ;
  END IF;




    /*----------------------------------------------------------------------------+
     | Initialize record with exchange rate, source id, table details for new line|
     +----------------------------------------------------------------------------*/
       l_ae_line_rec                             := p_ae_line_init_rec;
       l_ae_line_rec.ae_line_type                := l_source_type;
       l_ae_line_rec.ref_dist_ccid               := g_ae_summ_rev_tbl.ref_dist_ccid;
       l_ae_line_rec.ref_mf_dist_flag            := g_ae_summ_rev_tbl.ref_mf_dist_flag;

     /*----------------------------------------------------------------------------+
      | Set Tax link id                                                            |
      +----------------------------------------------------------------------------*/
       l_ae_line_rec.ae_tax_link_id              := g_ae_summ_rev_tbl.ae_tax_link_id_act;
       l_ae_line_rec.ae_customer_trx_line_id     := g_ae_summ_rev_tbl.ae_customer_trx_line_id;
       l_ae_line_rec.ae_cust_trx_line_gl_dist_id := g_ae_summ_rev_tbl.ae_cust_trx_line_gl_dist_id;
       l_ae_line_rec.ae_ref_line_id              := g_ae_summ_rev_tbl.ae_ref_line_id;
       l_ae_line_rec.ae_tax_link_id              := g_ae_summ_rev_tbl.ae_tax_link_id_act;
       l_ae_line_rec.ref_account_class           := g_ae_summ_rev_tbl.ref_account_class;
       l_ae_line_rec.activity_bucket             := g_ae_summ_rev_tbl.activity_bucket;
       l_ae_line_rec.ae_account                  := g_ae_rule_rec.receivable_account;


     arp_standard.debug(' g_ae_rule_rec.receivable_account 1:'||g_ae_rule_rec.receivable_account);
     arp_standard.debug(' p_gl_account_source :'||p_gl_account_source);
     arp_standard.debug(' g_override1 :'||g_override1);
     arp_standard.debug(' g_override2 :'||g_override2);
     arp_standard.debug(' g_ae_doc_rec.other_flag :'||g_ae_doc_rec.other_flag);
     arp_standard.debug(' l_actual_account :'||l_actual_account);

     /*----------------------------------------------------------------------------+
      | Use Revenue or Net Expense accounts based on Rules                         |
      +----------------------------------------------------------------------------*/
       IF ((the_gl_account_source(g_ae_summ_rev_tbl.activity_bucket) = 'ACTIVITY_GL_ACCOUNT') OR
           (the_gl_account_source(g_ae_summ_rev_tbl.activity_bucket) = 'TAX_CODE_ON_INVOICE'))
          AND (((g_ae_summ_rev_tbl.activity_bucket IN ('ED_LINE','ED_TAX','ED_FRT','ED_CHRG',
                                                       'ADJ_FRT','ADJ_CHRG','ADJ_LINE')) --BUG#5245153
                 AND (nvl(g_override1,'N') = 'Y'))
                OR (( g_ae_summ_rev_tbl.activity_bucket IN ('UNED_LINE','UNED_TAX','UNED_FRT','UNED_CHRG'))
                    AND (nvl(g_override2, 'N') = 'Y'))) THEN

           IF l_actual_account IS NULL THEN
              RAISE invalid_ccid_error;
           END IF;

         /*------------------------------------------------------------------------------------+
          | Substitute balancing segment for Net Expense account or Activity Gl Account        |
          | in the case of Deposits and Guarantees the accounting is derived by Autoaccounting |
          | there is no need to do further processing for accounting.                          |
          +------------------------------------------------------------------------------------*/
            IF (g_ae_doc_rec.other_flag IN ('COMMITMENT', 'CHARGEBACK', 'CBREVERSAL')) THEN
               arp_standard.debug('Build_Rev: ' || 'Commitment account derived by Autoaccounting');
               l_ae_line_rec.ae_account  := l_actual_account;

            ELSE
	    -- Bugfix 1948917.
	    IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
               Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id             ,
                               p_original_ccid => l_actual_account                ,
                               p_subs_ccid     => g_ae_rule_rec.receivable_account,
                               p_actual_ccid   => l_ae_line_rec.ae_account             );

          --BUG#5245153
          IF (l_ae_line_rec.ae_account <> l_actual_account) AND
             (the_gl_account_source(g_ae_summ_rev_tbl.activity_bucket) = 'ACTIVITY_GL_ACCOUNT') AND
             (g_ae_summ_rev_tbl.activity_bucket = 'ADJ_LINE') AND
             (g_ae_doc_rec.source_table = 'ADJ')
          THEN
             IF get_adj_act_ccid <> l_ae_line_rec.ae_account THEN
               BEGIN
                UPDATE ar_adjustments
                   SET code_Combination_id = l_ae_line_rec.ae_account
                 WHERE adjustment_id = g_ae_doc_rec.document_id;
                 g_adj_act_gl_acct_ccid := l_ae_line_rec.ae_account;
               EXCEPTION
                 WHEN no_data_found THEN g_adj_act_gl_acct_ccid := l_ae_line_rec.ae_account;
               END;
             END IF;
          END IF;

	    ELSE
	       l_ae_line_rec.ae_account := l_actual_account;
	    END IF;

            END IF;


       ELSIF the_gl_account_source(g_ae_summ_rev_tbl.activity_bucket) = 'REVENUE_ON_INVOICE' THEN
               l_ae_line_rec.ae_account := l_actual_account;
       ELSIF  the_gl_account_source(g_ae_summ_rev_tbl.activity_bucket) = 'ACTIVITY_GL_ACCOUNT'
           AND  g_ae_summ_rev_tbl.activity_bucket IN ('APP_LINE','APP_TAX','APP_FRT','APP_CHRG')
                --{BUG#5122552
-- BUG#5245153 ,'ADJ_FRT','ADJ_CHRG','ADJ_LINE')
                --}
           THEN
               l_ae_line_rec.ae_account := l_actual_account;
       END IF;

      /*----------------------------------------------------------------------------+
       | Set the activity ccid which will be stamped on adj.code_combination_id     |
       +----------------------------------------------------------------------------*/
        IF adj_code_combination_id IS NULL and p_gl_account_source = 'ACTIVITY_GL_ACCOUNT'
           AND (((nvl(g_ae_summ_rev_tbl.ae_pro_amt,0) <> 0)
                  OR (nvl(g_ae_summ_rev_tbl.ae_pro_acctd_amt,0) <> 0))
                OR ((nvl(g_ae_summ_rev_tbl.ae_pro_frt_chrg_amt,0) <> 0)
                     OR (nvl(g_ae_summ_rev_tbl.ae_pro_frt_chrg_acctd_amt,0) <> 0)))
        THEN
           adj_code_combination_id := l_ae_line_rec.ae_account;
        END IF;

       /*----------------------------------------------------------------------------+
        | Assign Accounting Debits and Credits based on prorated amount signs        |
        +----------------------------------------------------------------------------*/
         IF ((nvl(g_ae_summ_rev_tbl.ae_pro_amt,0) <> 0)
                                     OR (nvl(g_ae_summ_rev_tbl.ae_pro_acctd_amt,0) <> 0)) THEN

           --IF p_type_acct = 'PAY' THEN
           IF g_ae_summ_rev_tbl.activity_bucket IN ('APP_LINE','APP_TAX','APP_FRT','APP_CHRG') THEN

              -- ARALLOCB creates the REC account entries for APPS so for a cash application
              -- the accounting needs to be positive CR REC
              -- As ARPDDB passed the detail distributions as negative, we need to multiply by -1
              Create_Debits_Credits(g_ae_summ_rev_tbl.ae_pro_amt       * -1,
                                    g_ae_summ_rev_tbl.ae_pro_acctd_amt * -1,
                                    ''                                 ,
                                    ''                                 ,
                                    g_ae_summ_rev_tbl.ae_from_pro_amt  * -1,
                                    g_ae_summ_rev_tbl.ae_from_pro_acctd_amt * -1,
                                    l_ae_line_rec );

              l_ae_line_rec.ae_line_type := 'REC';

	       -- Bug 6598080
              IF g_ae_doc_rec.called_from = 'WRAPPER' THEN
                 l_ae_line_rec.ae_account := g_ae_code_combination_id_app;
              END IF;

            ELSE
             -- in the case of ADJ, ARALLOCB creates the Write off accounting
             -- for negative adjustment <=> CR REC <=> DB WO, in this case the distribution should negative
             -- As ARPDDB passes the detail distributions in the sign of the header adjustment that is negative
             -- so no need to multiply by -1

             Create_Debits_Credits(g_ae_summ_rev_tbl.ae_pro_amt        ,
                                   g_ae_summ_rev_tbl.ae_pro_acctd_amt  ,
                                   ''                                  ,
                                   ''                                  ,
                                    g_ae_summ_rev_tbl.ae_from_pro_amt       ,
                                    g_ae_summ_rev_tbl.ae_from_pro_acctd_amt ,
                                   l_ae_line_rec );
           END IF;

       /*----------------------------------------------------------------------------+
        | Assign built Revenue line to global lines table                            |
        +----------------------------------------------------------------------------*/
             --Commented out the call,Instead will do bulk binding to insert the records
	     --Assign_Elements(l_ae_line_rec);
             l_ae_line_rec.ae_id :=  g_id;
	     l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');

	     l_bulk_index := l_bulk_index + 1;
	     l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

      END IF; --End if ae_pro_amt or ae_pro_acctd_amt is non zero

     END LOOP;--end of pl/sql table loop

     /**In procedure Assign_Elements,g_ae_ctr is incremented for each record
        inserted.But no code segment in this package uses the value of the
	variable,thus not incremented the variable here.*/
     FORALL i IN l_ae_alloc_rec_gt_tab.first..l_ae_alloc_rec_gt_tab.last
	INSERT INTO ar_ae_alloc_rec_gt VALUES l_ae_alloc_rec_gt_tab(i);

     --Exit Last fetch
     IF l_last_fetch THEN
            EXIT;
     END IF;

       --Now build freight and charges if any
--         IF ((nvl(g_ae_summ_rev_tbl.ae_pro_frt_chrg_amt,0) <> 0)
--                                     OR (nvl(g_ae_summ_rev_tbl.ae_pro_frt_chrg_acctd_amt,0) <> 0)) THEN
--          --Link id null always for freight and charges
--             l_ae_line_rec.ae_tax_link_id := '';
--             IF p_type_acct = 'PAY' THEN
           /*----------------------------------------------------------------------------+
            | Assign Accounting Debits and Credits based on prorated amount signs        |
            +----------------------------------------------------------------------------*/
--                Create_Debits_Credits(g_ae_summ_rev_tbl.ae_pro_chrg_amt * -1          ,
--                                      g_ae_summ_rev_tbl.ae_pro_chrg_acctd_amt * -1    ,
--                                      ''                                         ,
--                                      ''                                         ,
--                                      g_ae_summ_rev_tbl.ae_from_pro_chrg_amt * -1          ,
--                                      g_ae_summ_rev_tbl.ae_from_pro_chrg_acctd_amt * -1    ,
--                                      l_ae_line_rec );
--                l_ae_line_rec.ae_line_type := 'REC';
--
--             ELSE
--}
           /*----------------------------------------------------------------------------+
            | Assign Accounting Debits and Credits based on prorated amount signs        |
            +----------------------------------------------------------------------------*/
--             Create_Debits_Credits(g_ae_summ_rev_tbl.ae_pro_frt_chrg_amt        ,
--                                   g_ae_summ_rev_tbl.ae_pro_frt_chrg_acctd_amt  ,
--                                   ''                                         ,
--                                   ''                                         ,
--                                   --HYU--{
--                                   g_ae_summ_rev_tbl.ae_from_pro_chrg_amt,
--                                   g_ae_summ_rev_tbl.ae_from_pro_chrg_acctd_amt,
--                                   l_ae_line_rec );
--
--           END IF; --HYUDETUPT
           --Create the freight and charges
--             Assign_Elements(l_ae_line_rec);
--         END IF; --freight and charges prorates are not zero

   END LOOP;

-- END IF; --End if Build Revenue lines

  arp_standard.debug( 'ARP_ALLOCATION_PKG.Build_Rev()-');

EXCEPTION
  WHEN invalid_ccid_error THEN
     arp_standard.debug('Invalid Tax ccid - ARP_ALLOCATION_PKG.Build_Rev' );
     fnd_message.set_name('AR','AR_INVALID_TAX_ACCOUNT');
     RAISE;

  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Build_Rev');
     RAISE;

END Build_Rev;


/*--------------------------------------------------------------------------+
 | Tax distrition ccid substitute ccid                                      |
 +--------------------------------------------------------------------------*/
PROCEDURE substite_tax_bal_seg
(p_line_type       IN     VARCHAR2,
 p_gas             IN     VARCHAR2,
 p_tcs             IN     VARCHAR2,
 p_tax_rec_flag    IN     VARCHAR2,
 p_ccid            IN     NUMBER,
 x_ccid            OUT  NOCOPY  NUMBER)
IS
  l_call   VARCHAR2(1) := 'Y';
BEGIN
  arp_standard.debug('substite_tax_bal_seg       +');
  arp_standard.debug('p_line_type       :'||p_line_type);
  arp_standard.debug('p_gas             :'||p_gas);
  arp_standard.debug('p_tcs             :'||p_tcs);
  arp_standard.debug('p_tax_rec_flag    :'||p_tax_rec_flag);
  arp_standard.debug('p_ccid            :'||p_ccid);

  x_ccid  := p_ccid;

   IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN

     IF p_line_type IN ('TAX', 'DEFERRED_TAX') THEN
         l_call := 'N';
     ELSE

       IF     p_gas    = 'ACTIVITY_GL_ACCOUNT' THEN
         IF     p_tcs    = 'NONE'                THEN     l_call := 'Y';
         ELSIF  p_tcs    = 'ACTIVITY'            THEN     l_call := 'Y';
         ELSIF  p_tcs    = 'INVOICE'             THEN
             IF   p_tax_rec_flag = 'Y'  THEN  l_call := 'N';
             ELSE  l_call := 'Y';
             END IF;
         END IF;
       ELSIF  p_gas    = 'REVENUE_ON_INVOICE'  THEN
         IF     p_tcs    = 'NONE'                THEN     l_call := 'N';
         ELSIF  p_tcs    = 'ACTIVITY'            THEN     l_call := 'Y';
         ELSIF  p_tcs    = 'INVOICE'             THEN
             IF   p_tax_rec_flag = 'Y'  THEN  l_call := 'N';
             ELSE  l_call := 'Y';
             END IF;
         END IF;
       ELSIF  p_gas    = 'TAX_CODE_ON_INVOICE'  THEN
         IF     p_tcs    = 'NONE'                THEN     l_call := 'Y';
         ELSIF  p_tcs    = 'ACTIVITY'            THEN     l_call := 'Y';
         ELSIF  p_tcs    = 'INVOICE'             THEN
             IF   p_tax_rec_flag = 'Y'  THEN  l_call := 'N';
             ELSE  l_call := 'Y';
             END IF;
         END IF;
       END IF;
    END IF;
    IF l_call = 'Y' THEN
        Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id             ,
                        p_original_ccid => p_ccid                          ,
                        p_subs_ccid     => g_ae_rule_rec.receivable_account,
                        p_actual_ccid   => x_ccid             );
    ELSE
       x_ccid := p_ccid;
    END IF;
  ELSE
    x_ccid := p_ccid;
  END IF;
  arp_standard.debug('x_ccid            :'||x_ccid);
  arp_standard.debug('substite_tax_bal_seg       -');
END;


/* ==========================================================================
 | PROCEDURE Build_Tax
 |
 | DESCRIPTION
 |    Build actual accounting entries for Tax amounts for discounts and
 |    adjustments
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_type_acct             IN    Indicates earned, unearned discount or
 |                                  adjustment accounting
 |    p_tax_code_source       IN    Source of gl account
 |    p_tax_recoverable_flag  IN    Indicates whether TAX is recoverable
 |    p_ae_line_init_rec      IN    Initialization record contains details
 |                                  for exchange rate, source table, id
 |                                  common to all accounting entries
 | History
 |   21-NOV-2003  Herve Yu   from_amount_dr      , from_amount_cr
 |                           from_acctd_amount_dr, from_acctd_amount_cr
 *==========================================================================*/
PROCEDURE Build_Tax(p_tax_code_source       IN ar_receivables_trx.tax_code_source%TYPE       ,
                    p_tax_recoverable_flag  IN ar_receivables_trx.tax_recoverable_flag%TYPE  ,
                    p_ae_line_init_rec      IN ar_ae_alloc_rec_gt%ROWTYPE                        ) IS

l_ae_line_rec         ar_ae_alloc_rec_gt%ROWTYPE                  ;
l_ae_line_rec_empty   ar_ae_alloc_rec_gt%ROWTYPE                  ;
l_ctr                 BINARY_INTEGER                            ;
l_actual_account      ar_distributions.code_combination_id%TYPE ;
l_org_inv_tax_code_id ar_distributions.tax_code_id%TYPE         ;
l_org_inv_loc_seg_id  ar_distributions.location_segment_id%TYPE ;
l_taxable_amt         NUMBER;
l_taxable_acctd_amt   NUMBER;

l_source_type_secondary ar_distributions.source_type_secondary%TYPE;

--PL/SQL table object,this collection is used for bulk processing of inserts
TYPE ae_alloc_rec_gt_tab IS TABLE OF ar_ae_alloc_rec_gt%ROWTYPE INDEX BY  BINARY_INTEGER;
l_ae_alloc_rec_gt_tab ae_alloc_rec_gt_tab;
l_ae_alloc_empty_tab  ae_alloc_rec_gt_tab;

l_last_fetch     BOOLEAN := FALSE;
l_bulk_index     NUMBER := 0;

CURSOR summarize_tax IS
SELECT /*+ INDEX(ae1 AR_AE_ALLOC_REC_GT_N3) */
       nvl(ae_pro_amt,0) ae_pro_amt,
       nvl(ae_pro_acctd_amt,0) ae_pro_acctd_amt,
       nvl(ae_pro_taxable_amt,0) ae_pro_taxable_amt,
       nvl(ae_pro_taxable_acctd_amt,0) ae_pro_taxable_acctd_amt,
       nvl(ae_from_pro_amt,0) ae_from_pro_amt,
       nvl(ae_from_pro_acctd_amt,0) ae_from_pro_acctd_amt,
       nvl(ae_pro_split_taxable_amt,nvl(ae_pro_taxable_amt,0)) ae_pro_split_taxable_amt,
       nvl(ae_pro_split_taxable_acctd_amt,nvl(ae_pro_taxable_acctd_amt,0)) ae_pro_split_taxable_acctd_amt,
       nvl(ae_pro_recov_taxable_amt,nvl(ae_pro_split_taxable_amt,nvl(ae_pro_taxable_amt,0)))
       ae_pro_recov_taxable_amt,
       nvl(ae_pro_recov_taxable_acctd_amt,nvl(ae_pro_split_taxable_acctd_amt,nvl(ae_pro_taxable_acctd_amt,0)))
       ae_pro_recov_taxable_acctd_amt,
       DECODE(ae1.ae_collected_tax_ccid,
              '', DECODE( DECODE(activity_bucket, 'ADJ_LINE' , g_ae_rule_rec.tax_code_source1,
                            'ADJ_TAX'  , g_ae_rule_rec.tax_code_source1,
                            'ADJ_FRT'  , g_ae_rule_rec.tax_code_source1,
                            'ADJ_CHRG' , g_ae_rule_rec.tax_code_source1,
                            'APP_LINE' , 'INVOICE',
                            'APP_TAX'  , 'INVOICE',
                            'APP_FRT'  , 'INVOICE',
                            'APP_CHRG' , 'INVOICE',
                            'ED_LINE'  , g_ae_rule_rec.tax_code_source1,
                            'ED_TAX'   , g_ae_rule_rec.tax_code_source1,
                            'ED_FRT'   , g_ae_rule_rec.tax_code_source1,
                            'ED_CHRG'  , g_ae_rule_rec.tax_code_source1,
                            'UNED_LINE', g_ae_rule_rec.tax_code_source2,
                            'UNED_TAX' , g_ae_rule_rec.tax_code_source2,
                            'UNED_FRT' , g_ae_rule_rec.tax_code_source2,
                            'UNED_CHRG', g_ae_rule_rec.tax_code_source2,
                                         g_ae_rule_rec.tax_code_source1),
                        'INVOICE',
                        DECODE(DECODE(activity_bucket,
                                     'ADJ_LINE' , g_ae_rule_rec.tax_recoverable_flag1,
                                     'ADJ_TAX'  , g_ae_rule_rec.tax_recoverable_flag1,
                                     'ADJ_FRT'  , g_ae_rule_rec.tax_recoverable_flag1,
                                     'ADJ_CHRG' , g_ae_rule_rec.tax_recoverable_flag1,
                                     'APP_LINE' , 'Y',
                                     'APP_TAX'  , 'Y',
                                     'APP_FRT'  , 'Y',
                                     'APP_CHRG' , 'Y',
                                     'ED_LINE'  , g_ae_rule_rec.tax_recoverable_flag1,
                                     'ED_TAX'   , g_ae_rule_rec.tax_recoverable_flag1,
                                     'ED_FRT'   , g_ae_rule_rec.tax_recoverable_flag1,
                                     'ED_CHRG'  , g_ae_rule_rec.tax_recoverable_flag1,
                                     'UNED_LINE', g_ae_rule_rec.tax_recoverable_flag2,
                                     'UNED_TAX' , g_ae_rule_rec.tax_recoverable_flag2,
                                     'UNED_FRT' , g_ae_rule_rec.tax_recoverable_flag2,
                                     'UNED_CHRG', g_ae_rule_rec.tax_recoverable_flag2,
                                                  g_ae_rule_rec.tax_recoverable_flag1),
                                      'Y', ae1.ae_code_combination_id,
                                          ''),
                          'NONE',ae1.ae_code_combination_id,
                          ''),
              ae1.ae_code_combination_id) ae_code_combination_id,
       ae1.ae_collected_tax_ccid,
       DECODE(ae1.activity_bucket,
                    'ADJ_LINE' ,ae1.ae_override_ccid1,
                    'ADJ_TAX'  ,ae1.ae_override_ccid1,
                    'ADJ_FRT'  ,ae1.ae_override_ccid1,
                    'ADJ_CHRG' ,ae1.ae_override_ccid1,
                    'ED_LINE'  ,ae1.ae_override_ccid1,
                    'ED_TAX'   ,ae1.ae_override_ccid1,
                    'ED_FRT'   ,ae1.ae_override_ccid1,
                    'ED_CHRG'  ,ae1.ae_override_ccid1,
                    'UNED_LINE',ae1.ae_override_ccid2,
                    'UNED_TAX' ,ae1.ae_override_ccid2,
                    'UNED_FRT' ,ae1.ae_override_ccid2,
                    'UNED_CHRG',ae1.ae_override_ccid2,
               '') actual_account,
       ae1.ae_tax_type,
       ae1.ae_tax_id,
       NVL(ae1.ae_tax_group_code_id,'') ae_tax_group_code_id,
       NVL(ae1.ae_tax_link_id_act,'') ae_tax_link_id_act,
       ae1.ae_customer_trx_line_id,
       ae1.ae_cust_trx_line_gl_dist_id,
       ae1.ae_ref_line_id,
       ae1.ref_account_class,
       ae1.activity_bucket,
       --{ref_dist_ccid
       ae1.ref_dist_ccid,
       ae1.ref_mf_dist_flag,
       --}
       ae1.ae_adj_ccid
      ,d.code_combination_id actual_tax_ccid
      ,ae1.ae_unedisc_ccid
      ,ae1.ae_edisc_ccid
FROM ar_ae_alloc_rec_gt ae1,
     ra_cust_trx_line_gl_dist d
WHERE ae1.ae_id = g_id
AND ae1.ae_account_class = 'TAX'
AND ae1.ae_cust_trx_line_gl_dist_id = d.cust_trx_line_gl_dist_id(+);

g_ae_summ_tax_tbl       summarize_tax%ROWTYPE;

TYPE summarize_tax_cur IS TABLE OF summarize_tax%ROWTYPE;
g_ae_summ_tax_blk_tbl summarize_tax_cur := summarize_tax_cur();

l_multi_factor      NUMBER := 1;
l_actual_tax_ccid   NUMBER;
BEGIN

 arp_standard.debug( 'ARP_ALLOCATION_PKG.Build_Tax()+');
 arp_standard.debug( 'p_tax_code_source:'||p_tax_code_source);
 arp_standard.debug( 'p_tax_recoverable_flag:'||p_tax_recoverable_flag);



-- IF (((g_ae_rule_rec.tax_amt_alloc <> 0) OR (g_ae_rule_rec.tax_acctd_amt_alloc <> 0))
--    OR ((g_ae_rule_rec.line_amt_alloc <> 0) OR (g_ae_rule_rec.line_acctd_amt_alloc <>0))) THEN
 /*------------------------------------------------------------------------------+
  | Tax due to activity tax code is independent of the original tax on invoice   |
  | hence this tax needs to be built first to the Non Recoverable Account on the |
  | activity Tax Code. With the taxable being the line amount or accounted amount|
  | This condition occurs only if tax distributions cannot be used for allocation|
  +------------------------------------------------------------------------------*/
--   IF ((p_tax_code_source = 'ACTIVITY') AND ((g_bound_tax) OR (g_bound_activity))) THEN
      /*--------------------------------------------------------------------------------+
       | Initialize record to create new line with exchange rate defaulting from Invoice|
       +--------------------------------------------------------------------------------*/
--        l_ae_line_rec := p_ae_line_init_rec;
      /*----------------------------------------------------------------------------+
       | Assign Tax link id, and tax id for Tax lines                               |
       +----------------------------------------------------------------------------*/
--        IF ((g_ae_rule_rec.line_amt_alloc <> 0) OR (g_ae_rule_rec.line_acctd_amt_alloc <> 0)) THEN
--           IF p_type_acct = 'ED_ADJ' THEN
--              l_ae_line_rec.ae_tax_link_id := g_ed_adj_activity_link;
--           ELSIF p_type_acct = 'UNED' THEN
--              l_ae_line_rec.ae_tax_link_id := g_uned_activity_link;
--           END IF;
--        END IF;
       /*----------------------------------------------------------------------------+
        | Override the tax code id as for rule ACTIVITY the tax code must be from the|
        | receivable activity                                                        |
        +----------------------------------------------------------------------------*/
--         IF ((p_tax_code_source = 'ACTIVITY') AND (p_type_acct = 'ED_ADJ')) THEN
--            l_ae_line_rec.ae_tax_code_id         := g_ae_rule_rec.act_vat_tax_id1;
--            l_ae_line_rec.ae_location_segment_id := '';
--         ELSIF ((p_tax_code_source = 'ACTIVITY') AND (p_type_acct = 'UNED')) THEN
--            l_ae_line_rec.ae_tax_code_id         := g_ae_rule_rec.act_vat_tax_id2;
--            l_ae_line_rec.ae_location_segment_id := '';
--         END IF;
       /*----------------------------------------------------------------------------+
        | Populate the source type for earned discounts non recoverable account      |
        +----------------------------------------------------------------------------*/
--         IF p_type_acct = 'ED_ADJ' THEN
--            IF g_ae_doc_rec.source_table = 'RA' THEN
--               l_ae_line_rec.ae_line_type    := 'EDISC_NON_REC_TAX' ;
          /*----------------------------------------------------------------------------+
           | Populate the source type for adjustment non recoverable account            |
           +----------------------------------------------------------------------------*/
--            ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN
--                  l_ae_line_rec.ae_line_type := 'ADJ_NON_REC_TAX';
          /*----------------------------------------------------------------------------+
           | Populate the source type for finance charges non recoverable account       |
           +----------------------------------------------------------------------------*/
--            ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN
--                  l_ae_line_rec.ae_line_type := 'FINCHRG_NON_REC_TAX';
--            END IF;
           --Set account
--            l_actual_account := g_ae_rule_rec.act_tax_non_rec_ccid1;
        /*----------------------------------------------------------------------------+
         | Populate the source type for unearned discounts non recoverable account    |
         +----------------------------------------------------------------------------*/
--         ELSIF p_type_acct = 'UNED' THEN
--               l_ae_line_rec.ae_line_type    := 'UNEDISC_NON_REC_TAX' ;
              --Set account for unearned discounts
--               l_actual_account := g_ae_rule_rec.act_tax_non_rec_ccid2;
--         END IF;
       /*-----------------------------------------------------------------------------+
        | Level 2 validation in case the non recoverable tax account setup on activity|
        | tax code is null - request user to set it up.                               |
        +-----------------------------------------------------------------------------*/
--         IF l_actual_account IS NULL THEN
--            arp_standard.debug('Activity Non Recoverable Account ');
--            RAISE invalid_ccid_error;
--         END IF;
       /*----------------------------------------------------------------------------+
        | Create first accounting entry for Debit/Credit to Non Recoverable/Override |
        | Account, Setup Non Recoverable account for debits/credits                  |
        | Substitute balancing segment for Non Recoverable Tax Account               |
        +----------------------------------------------------------------------------*/
	-- Bugfix 1948917.
--	IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N'THEN
--          Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id              ,
--                          p_original_ccid => l_actual_account                 ,
--                          p_subs_ccid     => g_ae_rule_rec.receivable_account ,
--                          p_actual_ccid   => l_ae_line_rec.ae_account             );
--	ELSE
--	  l_ae_line_rec.ae_account := l_actual_account;
--	END IF;
        /*----------------------------------------------------------------------------+
         | Set taxable amounts and accounted amounts, if there is no line amount to   |
         | then the taxable is calculated using the original tax line on the invoice  |
         +----------------------------------------------------------------------------*/
--          l_taxable_amt        := g_ae_rule_rec.line_amt_alloc;
--          l_taxable_acctd_amt  := g_ae_rule_rec.line_acctd_amt_alloc;
        /*----------------------------------------------------------------------------+
         | Create Debits/Credits for Non Recoverable Tax Account                      |
         +----------------------------------------------------------------------------*/
--           Create_Debits_Credits(g_ae_rule_rec.tax_amt_alloc         ,
--                                 g_ae_rule_rec.tax_acctd_amt_alloc   ,
--                                 l_taxable_amt                       ,
--                                 l_taxable_acctd_amt                 ,
--                                 '','',
--                                 l_ae_line_rec);
         /*----------------------------------------------------------------------------+
          | Assign Non Recoverable accounting record to lines table                    |
          +----------------------------------------------------------------------------*/
--            Assign_Elements(l_ae_line_rec);
--            l_ae_line_rec := l_ae_line_rec_empty;
--   END IF;  --end if Build Tax for ACTIVITY
--}
 /*----------------------------------------------------------------------------+
  | Populate the source type secondary for receipts/adjustments with tax       |
  +----------------------------------------------------------------------------*/
--{HYUDETUPT merge inside the loop part of avoiding triple execution of process_amount
--   IF p_type_acct = 'ED_ADJ' THEN
--      IF g_ae_doc_rec.source_table = 'RA' THEN
--         l_source_type_secondary  := 'EDISC' ;
    /*----------------------------------------------------------------------------+
     | Populate the source type secondary for adjustments with tax                |
     +----------------------------------------------------------------------------*/
--      ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN
--            l_source_type_secondary    := 'ADJ';
    /*----------------------------------------------------------------------------+
     | Populate the source type secondary for finance charges tax inclusive       |
     +----------------------------------------------------------------------------*/
--      ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN
--            l_source_type_secondary    := 'FINCHRG';
--      END IF;
 /*----------------------------------------------------------------------------+
  | Populate the source type secondary for unearned discounts                  |
  +----------------------------------------------------------------------------*/
--   ELSIF p_type_acct = 'UNED' THEN
--         l_source_type_secondary       := 'UNEDISC' ;
--   END IF; --end if type of account
--}


 /*----------------------------------------------------------------------------+
  | Process all tax lines to be built                                          |
  +----------------------------------------------------------------------------*/

    OPEN summarize_tax;

    LOOP
    FETCH summarize_tax BULK COLLECT INTO g_ae_summ_tax_blk_tbl LIMIT g_bulk_fetch_rows;

    --reinitialize
    l_ae_alloc_rec_gt_tab := l_ae_alloc_empty_tab;
    l_bulk_index := 0;

    IF summarize_tax%NOTFOUND THEN
      l_last_fetch := TRUE;
    END IF;

    FOR i IN 1..g_ae_summ_tax_blk_tbl.count LOOP

       g_ae_summ_tax_tbl := g_ae_summ_tax_blk_tbl(i);

       l_actual_account   := g_ae_summ_tax_tbl.actual_account;
       l_actual_tax_ccid  := g_ae_summ_tax_tbl.actual_tax_ccid;

       arp_standard.debug('Tax g_ae_summ_tax_tbl.ae_customer_trx_line_id:'||g_ae_summ_tax_tbl.ae_customer_trx_line_id);

       /*--------------------------------------------------------------------------------+
        | Initialize record to create new line with exchange rate defaulting from Invoice|
        +--------------------------------------------------------------------------------*/
         l_ae_line_rec := p_ae_line_init_rec;

       /*----------------------------------------------------------------------------+
        | Assign Tax link id, and tax id for Tax lines                               |
        +----------------------------------------------------------------------------*/
         l_ae_line_rec.ae_tax_link_id := g_ae_summ_tax_tbl.ae_tax_link_id_act;
         l_ae_line_rec.ae_customer_trx_line_id := g_ae_summ_tax_tbl.ae_customer_trx_line_id;
         l_ae_line_rec.ae_cust_trx_line_gl_dist_id := g_ae_summ_tax_tbl.ae_cust_trx_line_gl_dist_id;
         l_ae_line_rec.ae_ref_line_id := g_ae_summ_tax_tbl.ae_ref_line_id;
         l_ae_line_rec.ref_account_class := g_ae_summ_tax_tbl.ref_account_class;
         l_ae_line_rec.activity_bucket    := g_ae_summ_tax_tbl.activity_bucket;
         --{ref_dist_ccid
         l_ae_line_rec.ref_dist_ccid    := g_ae_summ_tax_tbl.ref_dist_ccid;
         l_ae_line_rec.ref_mf_dist_flag := g_ae_summ_tax_tbl.ref_mf_dist_flag;
         --}

         arp_standard.debug('  g_ae_summ_tax_tbl.activity_bucket :'||g_ae_summ_tax_tbl.activity_bucket);

   --Earned discount
   IF g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX') THEN
        l_source_type_secondary  := 'EDISC' ;
    /*----------------------------------------------------------------------------+
     | Populate the source type secondary for adjustments with tax                |
     +----------------------------------------------------------------------------*/
   -- Adj tax
   ELSIF g_ae_summ_tax_tbl.activity_bucket IN ('ADJ_TAX') THEN

      IF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN
            l_source_type_secondary    := 'ADJ';
     /*----------------------------------------------------------------------------+
      | Populate the source type secondary for finance charges tax inclusive       |
      +----------------------------------------------------------------------------*/
      ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN
            l_source_type_secondary    := 'FINCHRG';
      END IF;
 /*----------------------------------------------------------------------------+
  | Populate the source type secondary for unearned discounts                  |
  +----------------------------------------------------------------------------*/
   --Uned Disc
   ELSIF g_ae_summ_tax_tbl.activity_bucket IN ('UNED_TAX') THEN
         l_source_type_secondary       := 'UNEDISC' ;
   END IF; --end if type of account
   arp_standard.debug('  l_source_type_secondary :'||l_source_type_secondary);



   /*----------------------------------------------------------------------------+
    | Override the tax code id as for rule ACTIVITY the tax code must be from the|
    | receivable activity                                                        |
    +----------------------------------------------------------------------------*/
    --
    -- Setting ae_tax_code_id
    --         ae_location_segment_id
    --
    IF (((the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) = 'ACTIVITY') AND
         (g_ae_summ_tax_tbl.activity_bucket IN ('ADJ_TAX', 'ED_TAX'))))
              AND (NOT g_bound_tax) AND (NOT g_bound_activity) THEN

            l_ae_line_rec.ae_tax_code_id         := g_ae_rule_rec.act_vat_tax_id1;
            l_ae_line_rec.ae_location_segment_id := '';

     ELSIF (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) ='ACTIVITY') AND
           (g_ae_summ_tax_tbl.activity_bucket IN ('UNED_TAX'))
            AND (NOT g_bound_tax) AND (NOT g_bound_activity) THEN

            l_ae_line_rec.ae_tax_code_id         := g_ae_rule_rec.act_vat_tax_id2;
            l_ae_line_rec.ae_location_segment_id := '';

     ELSE
            IF g_ae_summ_tax_tbl.ae_tax_type = 'VAT' THEN
               l_ae_line_rec.ae_tax_group_code_id   := g_ae_summ_tax_tbl.ae_tax_group_code_id;
               l_ae_line_rec.ae_tax_code_id         := g_ae_summ_tax_tbl.ae_tax_id;
            ELSE --implies LOC or location based tax
               l_ae_line_rec.ae_location_segment_id := g_ae_summ_tax_tbl.ae_tax_id;
            END IF;
     END IF;




    /*----------------------------------------------------------------------------+
     | If tax is recoverable then debit/credit the Interim/Tax Account with       |
     | discount, adjustment amount                                                |
     +----------------------------------------------------------------------------*/
    --
    --Set line_type
    -- For APP_TAX, ED_TAX, UNED_TAX, ADJ_TAX
    -- Tax and Def tax
    --
    IF     (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) = 'INVOICE')
             AND (the_tax_recoverable_flag(g_ae_summ_tax_tbl.activity_bucket) = 'Y')
             AND (NOT g_bound_tax) THEN

--          IF    g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX') THEN
--                l_ae_line_rec.ae_line_type    := 'EDISC';
--          ELSIF g_ae_summ_tax_tbl.activity_bucket IN ('UNED_TAX') THEN
--                l_ae_line_rec.ae_line_type    := 'UNEDISC';
          /*----------------------------------------------------------------------------+
           | Verify whether TAX is deferred                                             |
           +----------------------------------------------------------------------------*/
          IF g_ae_summ_tax_tbl.ae_collected_tax_ccid IS NULL THEN
                l_ae_line_rec.ae_line_type    := 'TAX';
          ELSE --Tax is deferred
                l_ae_line_rec.ae_line_type    := 'DEFERRED_TAX';
          END IF;


          /*--------------------------------------------------------------------------------------+
           | Set the source type secondary to indicate TAX/DEFERRED TAX on discounts, adjustments |
           +--------------------------------------------------------------------------------------*/
          l_ae_line_rec.ae_line_type_secondary  := l_source_type_secondary;

           --Assign account
          l_ae_line_rec.ae_account := g_ae_summ_tax_tbl.ae_code_combination_id;

          /*----------------------------------------------------------------------------+
           | Create accounting debits or credits as applicable                          |
           +----------------------------------------------------------------------------*/
         IF g_ae_summ_tax_tbl.activity_bucket IN ('APP_TAX') THEN
               --
               -- APP_TAX
               --

               -- Bug 6598080
              IF g_ae_doc_rec.called_from = 'WRAPPER' THEN
                 l_ae_line_rec.ae_account := g_ae_code_combination_id_app;
              ELSE
	       l_ae_line_rec.ae_account := g_ae_rule_rec.receivable_account;
               arp_standard.debug('CCID for APP_TAX l_ae_line_rec.ae_account :'|| l_ae_line_rec.ae_account);
              END IF;

               /*----------------------------------------------------------------------------+
                | Create accounting debits or credits as applicable                          |
                +----------------------------------------------------------------------------*/
                 -- Application for tax. ARALLOCB creates the CR REC, as ARPDDB passes negative
                 -- detail distributions, we need ti multiply by -1 so that the distribution
                 -- for ARALLOCB are created as positive <=> CR REC
                  Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt       * -1,
                                        g_ae_summ_tax_tbl.ae_pro_acctd_amt * -1,
                                        g_ae_summ_tax_tbl.ae_pro_recov_taxable_amt      * -1,
                                        g_ae_summ_tax_tbl.ae_pro_recov_taxable_acctd_amt* -1,
                                        g_ae_summ_tax_tbl.ae_from_pro_amt       * -1,
                                        g_ae_summ_tax_tbl.ae_from_pro_acctd_amt * -1,
                                        l_ae_line_rec);

                  l_ae_line_rec.ae_line_type    := 'REC';
         ELSE
              --
              --For  ADJ_TAX, ED_TAX, UNED_TAX
              --
               l_ae_line_rec.ae_account := g_ae_summ_tax_tbl.ae_code_combination_id;
               arp_standard.debug('1 CCID for '||g_ae_summ_tax_tbl.activity_bucket||
                                  ' l_ae_line_rec.ae_account :'|| l_ae_line_rec.ae_account);

               --Boundary Adj
               adj_boundary_account
                 (p_receivables_trx_id   => g_receivables_trx_id,
                  p_bucket               => g_ae_summ_tax_tbl.ref_account_class,
                  p_ctlgd_id             => g_ae_summ_tax_tbl.ae_cust_trx_line_gl_dist_id,
                  x_ccid                 => l_ae_line_rec.ae_account);

               arp_standard.debug('2 CCID for '||g_ae_summ_tax_tbl.activity_bucket||
                                  ' l_ae_line_rec.ae_account :'|| l_ae_line_rec.ae_account);

              l_actual_account := l_ae_line_rec.ae_account;
              substite_tax_bal_seg
               (p_line_type       => l_ae_line_rec.ae_line_type,
                p_gas             => the_gl_account_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tcs             => the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tax_rec_flag    => the_tax_recoverable_flag(g_ae_summ_tax_tbl.activity_bucket),
                p_ccid            => l_actual_account,
                x_ccid            => l_ae_line_rec.ae_account);


--BUG#5245153
--    IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
--                 l_actual_account := l_ae_line_rec.ae_account;
--                 Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id              ,
--                                 p_original_ccid => l_actual_account         ,
--                                 p_subs_ccid     => g_ae_rule_rec.receivable_account ,
--                                 p_actual_ccid   => l_ae_line_rec.ae_account             );
--	END IF;
--}
               /*----------------------------------------------------------------------------+
                | Create accounting debits or credits as applicable                          |
                +----------------------------------------------------------------------------*/
                 -- Accounting for Activities
                 -- ARALLOCB creates the activity side of the accounting <=>
                 -- WO for Adjustments : negative ADJ > ARPDDB passes negative detail distributions > ARALLOCB creates DB WO
                 -- ED activity accounting for ED: positive ED > ARADDB passes negative detail distributions > ARALLOCB creates DB ED activity
                 -- UNED activity accounting for UNED: positive UNED > ARADDB passes negative detail distributions > ARALLOCB creates DB UNED activity
                 -- therefor no need to multiply by -1
                  Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt               ,
                                        g_ae_summ_tax_tbl.ae_pro_acctd_amt         ,
                                        g_ae_summ_tax_tbl.ae_pro_recov_taxable_amt ,
                                        g_ae_summ_tax_tbl.ae_pro_recov_taxable_acctd_amt ,
                                        g_ae_summ_tax_tbl.ae_from_pro_amt          ,
                                        g_ae_summ_tax_tbl.ae_from_pro_acctd_amt    ,
                                        l_ae_line_rec);
        END IF;

        --Assign_Elements(l_ae_line_rec);
        l_ae_line_rec.ae_id :=  g_id;
	l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	l_bulk_index := l_bulk_index + 1;
	l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;


 ELSIF     --This is only possible for ADJ_TAX, ED_TAX, UNED_TAX
           -- Attention Verify why the APP_TAX non_recoverable
               (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) = 'INVOICE')
           AND (the_tax_recoverable_flag(g_ae_summ_tax_tbl.activity_bucket) = 'N')
           AND (NOT g_bound_tax)
           AND (g_ae_summ_tax_tbl.activity_bucket NOT IN ('APP_TAX'))
 THEN
      /*----------------------------------------------------------------------------+
       | Populate the source type for earned discounts non recoverable account      |
       +----------------------------------------------------------------------------*/
       --IF p_type_acct = 'ED_ADJ' THEN
       --
       -- Set line_type
       --
       IF (g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX','ADJ_TAX' )) THEN

           IF g_ae_doc_rec.source_table = 'RA' THEN
              l_ae_line_rec.ae_line_type    := 'EDISC_NON_REC_TAX' ;
           /*----------------------------------------------------------------------------+
            | Populate the source type for adjustment non recoverable account            |
            +----------------------------------------------------------------------------*/
           ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN
              l_ae_line_rec.ae_line_type := 'ADJ_NON_REC_TAX';
           /*----------------------------------------------------------------------------+
            | Populate the source type for finance charges non recoverable account       |
            +----------------------------------------------------------------------------*/
           ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN
              l_ae_line_rec.ae_line_type := 'FINCHRG_NON_REC_TAX';
           END IF;

       --Set l_actual_account, set by summarize cursor

       /*----------------------------------------------------------------------------+
        | Populate the source type for unearned discounts non recoverable account    |
        +----------------------------------------------------------------------------*/
               --  ELSIF p_type_acct = 'UNED' THEN
       ELSIF (g_ae_summ_tax_tbl.activity_bucket IN ('UNED_LINE','UNED_TAX','UNED_FRT','UNED_CHRG')) THEN
           l_ae_line_rec.ae_line_type    := 'UNEDISC_NON_REC_TAX' ;
                     --Set l_actual_account, set by summarize cursor
       END IF;

       /*-----------------------------------------------------------------------------+
        | Level 2 validation in case the non recoverable tax account setup on tax code|
        | is null - request user to set it up.                                        |
        +-----------------------------------------------------------------------------*/

        IF    l_actual_account IS NULL  THEN --is null
               --Boundary Adj
              adj_boundary_account
              (p_receivables_trx_id   => g_receivables_trx_id,
               p_bucket               => g_ae_summ_tax_tbl.activity_bucket,
               p_ctlgd_id             => g_ae_summ_tax_tbl.ae_cust_trx_line_gl_dist_id,
               x_ccid                 => l_actual_account);
            IF l_actual_account IS NULL  THEN
               arp_standard.debug('Invoice Non Recoverable Account is NULL');
               RAISE invalid_ccid_error;
            END IF;
        END IF;


        substite_tax_bal_seg
               (p_line_type       => l_ae_line_rec.ae_line_type,
                p_gas             => the_gl_account_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tcs             => the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tax_rec_flag    => the_tax_recoverable_flag(g_ae_summ_tax_tbl.activity_bucket),
                p_ccid            => l_actual_account,
                x_ccid            => l_ae_line_rec.ae_account);



               /*----------------------------------------------------------------------------+
                | Create first accounting entry for Debit/Credit to Non Recoverable/Override |
                | Account, Setup Non Recoverable account for debits/credits                  |
                | Substitute balancing segment for Non Recoverable Tax Account               |
                +----------------------------------------------------------------------------*/
    -- Bugfix 1948917.
--    IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
--                 Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id              ,
--                                 p_original_ccid => l_actual_account                 ,
--                                 p_subs_ccid     => g_ae_rule_rec.receivable_account ,
--                                 p_actual_ccid   => l_ae_line_rec.ae_account             );
--	 ELSE
--		 l_ae_line_rec.ae_account := l_actual_account;
--	 END IF;




        /*----------------------------------------------------------------------------+
         | Create Debits/Credits for Non Recoverable Tax Account                      |
         +----------------------------------------------------------------------------*/

       arp_standard.debug('Create Debits/Credits for Non Recoverable Tax Account');
       -- Creation of activity accounting
       -- ADJ UNED ED distributions
       -- ARALLOC creates:
       -- * ADJ - WO side of accounting <=> negative ADJ => DB activty WO. As ARPDDB passes neg  detail distrib
       --       no need to multiply by -1
       -- * ED and UNED - Discount Activity side of the accounting. For positive ED UNED, ARPDDB passes negative
       --       deatil distributions and ARALLOCB creates DB of Activity, therefore no need to multiply by -1
       Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt                    ,
                             g_ae_summ_tax_tbl.ae_pro_acctd_amt              ,
                             g_ae_summ_tax_tbl.ae_pro_split_taxable_amt      ,
                             g_ae_summ_tax_tbl.ae_pro_split_taxable_acctd_amt,
                             g_ae_summ_tax_tbl.ae_from_pro_amt               ,
                             g_ae_summ_tax_tbl.ae_from_pro_acctd_amt         ,
                             l_ae_line_rec);

        /*----------------------------------------------------------------------------+
         | Assign Non Recoverable accounting record to lines table                    |
         +----------------------------------------------------------------------------*/
         --Assign_Elements(l_ae_line_rec);
	 l_bulk_index := l_bulk_index + 1;
         l_ae_line_rec.ae_id :=  g_id;
	 l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	 l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

ELSIF   -- Activity Tax accounting not for APP_TAX
            (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket)='ACTIVITY')
        AND (NOT g_bound_tax) AND (NOT g_bound_activity)
      --AND (p_type_acct <> 'PAY')
        AND g_ae_summ_tax_tbl.activity_bucket NOT IN ('APP_LINE','APP_TAX','APP_FRT','APP_CHRG') --TCSACT
THEN
        /*----------------------------------------------------------------------------+
         | Populate the source type for earned discounts non recoverable account      |
         +----------------------------------------------------------------------------*/
         -- IF p_type_acct = 'ED_ADJ' THEN

         --
         -- Set line_type
         --
         IF g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX','ADJ_TAX')  THEN
             IF g_ae_doc_rec.source_table = 'RA' THEN
                l_ae_line_rec.ae_line_type    := 'EDISC_NON_REC_TAX' ;
             /*----------------------------------------------------------------------------+
              | Populate the source type for adjustment non recoverable account            |
              +----------------------------------------------------------------------------*/
             ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN
                l_ae_line_rec.ae_line_type := 'ADJ_NON_REC_TAX';
             /*----------------------------------------------------------------------------+
              | Populate the source type for finance charges non recoverable account       |
              +----------------------------------------------------------------------------*/
             ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN
                l_ae_line_rec.ae_line_type := 'FINCHRG_NON_REC_TAX';
             END IF;
             --Set by summarize cursor l_actual_account := g_ae_rule_rec.act_tax_non_rec_ccid1;
             /*----------------------------------------------------------------------------+
              | Populate the source type for unearned discounts non recoverable account    |
              +----------------------------------------------------------------------------*/
              --  ELSIF p_type_acct = 'UNED' THEN
         ELSIF g_ae_summ_tax_tbl.activity_bucket IN ('UNED_TAX') THEN
             l_ae_line_rec.ae_line_type    := 'UNEDISC_NON_REC_TAX' ;
             --Set by summarize cursor l_actual_account := g_ae_rule_rec.act_tax_non_rec_ccid2;
         END IF;


         /*-----------------------------------------------------------------------------+
          | Level 2 validation in case the non recoverable tax account setup on activity|
          | tax code is null - request user to set it up.                               |
          +-----------------------------------------------------------------------------*/
         IF l_actual_account IS NULL THEN --is null
                --Boundary Adj
                adj_boundary_account
               (p_receivables_trx_id   => g_receivables_trx_id,
                p_bucket               => g_ae_summ_tax_tbl.activity_bucket,
                p_ctlgd_id             => g_ae_summ_tax_tbl.ae_cust_trx_line_gl_dist_id,
                x_ccid                 => l_actual_account );

             IF l_actual_account IS NULL THEN --is null
               arp_standard.debug('Activity Non Recoverable Account is NULL');
               RAISE invalid_ccid_error;
             END IF;

         END IF;

        substite_tax_bal_seg
               (p_line_type       => l_ae_line_rec.ae_line_type,
                p_gas             => the_gl_account_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tcs             => the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tax_rec_flag    => the_tax_recoverable_flag(g_ae_summ_tax_tbl.activity_bucket),
                p_ccid            => l_actual_account,
                x_ccid            => l_ae_line_rec.ae_account);


         /*----------------------------------------------------------------------------+
          | Create first accounting entry for Debit/Credit to Non Recoverable/Override |
          | Account, Setup Non Recoverable account for debits/credits                  |
          | Substitute balancing segment for Non Recoverable Tax Account               |
          +----------------------------------------------------------------------------*/
	       -- Bugfix 1948917.
--         IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
--               Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id              ,
--                               p_original_ccid => l_actual_account                 ,
--                               p_subs_ccid     => g_ae_rule_rec.receivable_account ,
--                               p_actual_ccid   => l_ae_line_rec.ae_account             );
--         ELSE
--               l_ae_line_rec.ae_account := l_actual_account;
--         END IF;


         /*----------------------------------------------------------------------------+
          | Create Debits/Credits for Non Recoverable Tax Account                      |
          +----------------------------------------------------------------------------*/
         arp_standard.debug(' Create Debits/Credits for Non Recoverable Tax Account');
         -- Creation of activity accounting
         -- ADJ UNED ED distributions
         -- ARALLOC creates:
         -- * ADJ - WO side of accounting <=> negative ADJ => DB activty WO. As ARPDDB passes neg  detail distrib
         --       no need to multiply by -1
         -- * ED and UNED - Discount Activity side of the accounting. For positive ED UNED, ARPDDB passes negative
         --       deatil distributions and ARALLOCB creates DB of Activity, therefore no need to multiply by -1
         Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt                 ,
                               g_ae_summ_tax_tbl.ae_pro_acctd_amt           ,
                               g_ae_summ_tax_tbl.ae_pro_split_taxable_amt   ,
                               g_ae_summ_tax_tbl.ae_pro_split_taxable_acctd_amt ,
                               g_ae_summ_tax_tbl.ae_from_pro_amt            ,
                               g_ae_summ_tax_tbl.ae_from_pro_acctd_amt      ,
                               l_ae_line_rec);

         /*----------------------------------------------------------------------------+
          | Assign Non Recoverable accounting record to lines table                    |
          +----------------------------------------------------------------------------*/
         --Assign_Elements(l_ae_line_rec);
	 l_bulk_index := l_bulk_index + 1;
         l_ae_line_rec.ae_id :=  g_id;
	 l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	 l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

         /*----------------------------------------------------------------------------+
          | Assign Non Recoverable accounting record to lines table                    |
          +----------------------------------------------------------------------------*/
         IF g_ae_summ_tax_tbl.ae_tax_type = 'VAT' THEN
            l_ae_line_rec.ae_tax_group_code_id   := g_ae_summ_tax_tbl.ae_tax_group_code_id;
            l_ae_line_rec.ae_tax_code_id         := g_ae_summ_tax_tbl.ae_tax_id;
         ELSE --implies LOC or location based tax
            l_ae_line_rec.ae_location_segment_id := g_ae_summ_tax_tbl.ae_tax_id;
         END IF;


 ELSIF     (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) = 'NONE')
             AND (g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX','UNED_TAX',
                  'ADJ_TAX'    --BUG#5185726: include ADJ_TAX
                  ))
             AND (NOT g_bound_tax) THEN

          IF    g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX') THEN
                l_ae_line_rec.ae_line_type    := 'EDISC';
          ELSIF g_ae_summ_tax_tbl.activity_bucket IN ('UNED_TAX') THEN
                l_ae_line_rec.ae_line_type    := 'UNEDISC';
          ELSIF g_ae_summ_tax_tbl.activity_bucket IN ('ADJ_TAX') THEN --BUG#5185726: include ADJ_TAX
                l_ae_line_rec.ae_line_type    := 'ADJ';
          END IF;

          /*----------------------------------------------------------------------------+
           | Create accounting debits or credits as applicable                          |
           +----------------------------------------------------------------------------*/


          IF g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX',
		            'ADJ_TAX') --BUG#5185726: include ADJ_TAX
          THEN
             IF g_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE' AND
                g_ae_rule_rec.tax_code_source1   = 'NONE'
             THEN
                l_ae_line_rec.ae_account := g_ae_summ_tax_tbl.ae_code_combination_id;
             ELSIF g_ae_rule_rec.gl_account_source1 = 'TAX_CODE_ON_INVOICE' AND
                   g_ae_rule_rec.tax_code_source1   = 'NONE'
             THEN
                IF g_ae_summ_tax_tbl.activity_bucket = 'ADJ_TAX' THEN
                   l_ae_line_rec.ae_account := g_ae_summ_tax_tbl.ae_adj_ccid;
                ELSE
                   l_ae_line_rec.ae_account := g_ae_summ_tax_tbl.ae_edisc_ccid;
                END IF;
             ELSE
                l_ae_line_rec.ae_account := g_ae_rule_rec.code_combination_id1;
             END IF;
          ELSE
             IF g_ae_rule_rec.gl_account_source2 = 'REVENUE_ON_INVOICE' AND
                g_ae_rule_rec.tax_code_source2   = 'NONE'
             THEN
                l_ae_line_rec.ae_account := g_ae_summ_tax_tbl.ae_code_combination_id;
             ELSIF g_ae_rule_rec.gl_account_source2 = 'TAX_CODE_ON_INVOICE' AND
                   g_ae_rule_rec.tax_code_source2   = 'NONE'
             THEN
                l_ae_line_rec.ae_account := g_ae_summ_tax_tbl.ae_unedisc_ccid;
             ELSE
                l_ae_line_rec.ae_account := g_ae_rule_rec.code_combination_id2;
             END IF;
          END IF;

        l_actual_account := l_ae_line_rec.ae_account;
        substite_tax_bal_seg
               (p_line_type       => l_ae_line_rec.ae_line_type,
                p_gas             => the_gl_account_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tcs             => the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket),
                p_tax_rec_flag    => the_tax_recoverable_flag(g_ae_summ_tax_tbl.activity_bucket),
                p_ccid            => l_actual_account,
                x_ccid            => l_ae_line_rec.ae_account);


           /*----------------------------------------------------------------------------+
            | Create accounting debits or credits as applicable                          |
            +----------------------------------------------------------------------------*/
           -- Accounting for Activities
           -- ARALLOCB creates the activity side of the accounting <=>
           -- WO for Adjustments : negative ADJ > ARPDDB passes negative detail distributions > ARALLOCB creates DB WO
           -- ED activity accounting for ED: positive ED > ARADDB passes negative detail distributions > ARALLOCB creates DB ED activity
           -- UNED activity accounting for UNED: positive UNED > ARADDB passes negative detail distributions > ARALLOCB creates DB UNED activity
           -- therefor no need to multiply by -1
           Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt               ,
                                 g_ae_summ_tax_tbl.ae_pro_acctd_amt         ,
                                 g_ae_summ_tax_tbl.ae_pro_recov_taxable_amt ,
                                 g_ae_summ_tax_tbl.ae_pro_recov_taxable_acctd_amt ,
                                 g_ae_summ_tax_tbl.ae_from_pro_amt          ,
                                 g_ae_summ_tax_tbl.ae_from_pro_acctd_amt    ,
                                l_ae_line_rec);
         -- Assign_Elements(l_ae_line_rec);
	 l_bulk_index := l_bulk_index + 1;
         l_ae_line_rec.ae_id :=  g_id;
	 l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	 l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

  END IF;





        /*------------------------------------------------------------------------------+
         | Create accounting entries for deferred tax where tax is non recoverable. For |
         | adjustments in the sign of the receivable, a refund takes place when these   |
         | accounting entries are created. Eg -ve adjustment Dr Interim, Cr Collected,  |
         | positive adjustments Cr Interim, Dr Collected, users would need to run       |
         | reports based on the accounting created, so that they can handle deferred    |
         | Invoices when such accounting takes place and create necessary offsetting    |
         | adjustments as required. For boundary conditions we dont create regular      |
         | accounting entries, but only move the deferred tax due to discount or payment|
         | hence the if condtruct using g_bound_tax for the above accounting conditions|
         +------------------------------------------------------------------------------*/

     IF (      (g_ae_summ_tax_tbl.ae_collected_tax_ccid IS NOT NULL)
           AND  ((   (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) = 'INVOICE')
                 AND (the_tax_recoverable_flag(g_ae_summ_tax_tbl.activity_bucket) = 'N'))
             OR (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) = 'ACTIVITY')
             OR (the_tax_code_source(g_ae_summ_tax_tbl.activity_bucket) = 'NONE')))
           AND (g_ae_summ_tax_tbl.activity_bucket IN ('ED_TAX','UNED_TAX','ADJ_TAX'))
     THEN

         /*--------------------------------------------------------------------------------------+
          | Set the source type secondary to indicate TAX/DEFERRED TAX on discounts, adjustments |
          +--------------------------------------------------------------------------------------*/
          l_ae_line_rec.ae_line_type_secondary  := l_source_type_secondary;

          --{BUG#3509185
          /*----------------------------------------------------------------------------------------+
           |For BR adjustments set the secondary table, id, type columns as the                     |
           |are critical in reconciliation process. Bills has tax code source as NONE               |
           |for adjustments against it which ae of type endorsements. Override the above            |
           |type secondary if bill line assignment. The setting below is used for BR reconciliation |
           |On closure of the bill, and if not set correctly will orphan the deferred tax entries.  |
           +----------------------------------------------------------------------------------------*/
           IF g_br_cust_trx_line_id IS NOT NULL THEN
              IF (     (g_ae_doc_rec.source_table = 'RA')
                   AND (g_ae_doc_rec.event = 'MATURITY_DATE')) THEN
                     l_ae_line_rec.ae_source_table := 'TH';
              END IF;
              /*----------------------------------------
               |Populate the source table secondary for the accounting created by tax accounting
               |engine, because it is important to distinguish tax moved foor a specific exchange
               |or transaction on the Bill. ( tax codes and other accounting grouping attributes
               |could be common accross different transactions.)
               +-------------------------------------------------*/
               l_ae_line_rec.ae_source_table_secondary := 'CTL';
               l_ae_line_rec.ae_source_id_secondary    := g_br_cust_trx_line_id;
               l_ae_line_rec.ae_line_type_secondary   := 'ASSIGNMENT';
          END IF; --BR
          --}
          /*----------------------------------------------------------------------------+
           | Create second accounting entry for Debit/Credit to Interim Tax account     |
           +----------------------------------------------------------------------------*/
          l_ae_line_rec.ae_line_type := 'DEFERRED_TAX' ;
          IF  l_actual_tax_ccid IS NOT NULL THEN
              l_ae_line_rec.ae_account := l_actual_tax_ccid;
          ELSE
              l_ae_line_rec.ae_account      := g_ae_summ_tax_tbl.ae_code_combination_id;
          END IF;
          /*----------------------------------------------------------------------------+
           | Create Debits/Credits for Interim Tax account to move deferred tax         |
           +----------------------------------------------------------------------------*/
           --
           -- If ED_TAX or UNED_TAX then the DEFERRED_TAX accounting same sign as ED or UNED TAX distributions
           l_multi_factor := 1;


           Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt               * l_multi_factor,
                                 g_ae_summ_tax_tbl.ae_pro_acctd_amt         * l_multi_factor,
                                 g_ae_summ_tax_tbl.ae_pro_split_taxable_amt * l_multi_factor,
                                 g_ae_summ_tax_tbl.ae_pro_split_taxable_acctd_amt * l_multi_factor,
                                 g_ae_summ_tax_tbl.ae_from_pro_amt          * l_multi_factor,
                                 g_ae_summ_tax_tbl.ae_from_pro_acctd_amt    * l_multi_factor,
                                 l_ae_line_rec);

            /*----------------------------------------------------------------------------+
             | Assign debit/credit for Interim tax to build table                         |
             +----------------------------------------------------------------------------*/
            --Assign_Elements(l_ae_line_rec);
	    l_bulk_index := l_bulk_index + 1;
            l_ae_line_rec.ae_id :=  g_id;
	    l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	    l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

            /*----------------------------------------------------------------------------+
             | Create third accounting entry for Debit/Credit to Collected Tax account    |
             +----------------------------------------------------------------------------*/
            l_ae_line_rec.ae_line_type := 'TAX' ;
            l_ae_line_rec.ae_account      := g_ae_summ_tax_tbl.ae_collected_tax_ccid;

            /*----------------------------------------------------------------------------+
             | Create Debits/Credits for Collected Tax account to move deferred tax       |
             +----------------------------------------------------------------------------*/
            Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt   * -1 * l_multi_factor ,
                                  g_ae_summ_tax_tbl.ae_pro_acctd_amt * -1 * l_multi_factor,
                                  g_ae_summ_tax_tbl.ae_pro_split_taxable_amt * -1* l_multi_factor,
                                  g_ae_summ_tax_tbl.ae_pro_split_taxable_acctd_amt * -1* l_multi_factor,
                                  g_ae_summ_tax_tbl.ae_from_pro_amt * -1  * l_multi_factor,
                                  g_ae_summ_tax_tbl.ae_from_pro_acctd_amt * -1 * l_multi_factor,
                                  l_ae_line_rec,
                                 'Y');

            /*----------------------------------------------------------------------------+
             | Assign debit/credit for Collected Tax account to build table               |
             +----------------------------------------------------------------------------*/
             --Assign_Elements(l_ae_line_rec);
	     l_bulk_index := l_bulk_index + 1;
             l_ae_line_rec.ae_id :=  g_id;
	     l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	     l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

     END IF;





     /*----------------------------------------------------------------------------+
      | Create Debits/Credits for moving prorate deferred tax as a result of       |
      | Payment from Interim Account to Collected Tax account                      |
      +----------------------------------------------------------------------------*/
   IF ((g_ae_summ_tax_tbl.ae_collected_tax_ccid IS NOT NULL) --is not null
              AND (NOT g_done_def_tax)
              AND (g_ae_summ_tax_tbl.activity_bucket IN ('APP_TAX'))
              AND (nvl(g_ae_doc_rec.document_type,'RECEIPT') <> 'CREDIT_MEMO'))
   THEN
          l_ae_line_rec := p_ae_line_init_rec; --Initialise record

         /*--------------------------------------------------------------------------------------+
          | Set the source type secondary to indicate TAX/DEFERRED TAX on discounts, adjustments |
          +--------------------------------------------------------------------------------------*/
           l_ae_line_rec.ae_line_type_secondary  := 'PAYMENT';

          --{BUG#3509185
          /*------------------------------------------------------------------------------------+
           | For Bills receivable adjustments set the secondary table, id, type columns as thes |
           | are critical in the reconciliation process. Bills have a Tax code source of NONE   |
           | for adjustments against it which are of type endorsments. Override the above line  |
           | type secondry if bill line assignment. The setting below is used for BR reconcile  |
           | on closure of Bill, and if not set correctly will orphan the deferred tax entries. |
           +------------------------------------------------------------------------------------*/
            IF g_br_cust_trx_line_id IS NOT NULL THEN
               IF ((g_ae_doc_rec.source_table = 'RA')
                                   AND (g_ae_doc_rec.event = 'MATURITY_DATE')) THEN
                  l_ae_line_rec.ae_source_table := 'TH';
               END IF;
           /*----------------------------------------------------------------------------------+
            | Populate the source table secondary for accounting created by the tax accounting |
            | engine, because its is important to distinguish tax moved for a specific exchange|
            | or transaction on the Bill. (tax codes and other accounting grouping attributes  |
            | could be common across different transactions.)                                  |
            +----------------------------------------------------------------------------------*/
               l_ae_line_rec.ae_source_table_secondary := 'CTL';
               l_ae_line_rec.ae_source_id_secondary    := g_br_cust_trx_line_id;
               l_ae_line_rec.ae_line_type_secondary := 'ASSIGNMENT'; --override fefault value
            END IF; --end if BR
            --}

       --Set the tax code or location segment id
          IF g_ae_summ_tax_tbl.ae_tax_type = 'VAT' THEN
             l_ae_line_rec.ae_tax_group_code_id := g_ae_summ_tax_tbl.ae_tax_group_code_id;
             l_ae_line_rec.ae_tax_code_id := g_ae_summ_tax_tbl.ae_tax_id;
          ELSE --implies LOC or location based tax
             l_ae_line_rec.ae_location_segment_id := g_ae_summ_tax_tbl.ae_tax_id;
          END IF;

          l_ae_line_rec.ae_line_type := 'DEFERRED_TAX' ;
          l_ae_line_rec.ae_account   := l_actual_tax_ccid;

        /*-----------------------------------------------------------------------------+
         |Deferred tax for payments is not linked to revenue allocations for discounts |
         |or adjustments. Set link id for tax moved due to payments to '' as they have |
         |no link basis - revenue to link to, they indicate movements due to payments  |
         |from the Interim to Collected Tax accounts.                                  |
         +-----------------------------------------------------------------------------*/
          l_ae_line_rec.ae_tax_link_id := g_ae_summ_tax_tbl.ae_tax_link_id_act;

          Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt           ,
                                g_ae_summ_tax_tbl.ae_pro_acctd_amt     ,
                                g_ae_summ_tax_tbl.ae_pro_split_taxable_amt    ,
                                g_ae_summ_tax_tbl.ae_pro_split_taxable_acctd_amt,
                                --HYU--{
                                g_ae_summ_tax_tbl.ae_from_pro_amt           ,
                                g_ae_summ_tax_tbl.ae_from_pro_acctd_amt     ,
                                --HYU--}
                                l_ae_line_rec);

       /*----------------------------------------------------------------------------+
        | Assign debit/credit for Interim Tax account for payments to build table    |
        +----------------------------------------------------------------------------*/
         --Assign_Elements(l_ae_line_rec);
	 l_bulk_index := l_bulk_index + 1;
         l_ae_line_rec.ae_id :=  g_id;
	 l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	 l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

       /*----------------------------------------------------------------------------+
        | Create third accounting entry for Debit/Credit to Collected Tax account    |
        +----------------------------------------------------------------------------*/
         l_ae_line_rec.ae_line_type := 'TAX' ;
         l_ae_line_rec.ae_account      := g_ae_summ_tax_tbl.ae_collected_tax_ccid;

       /*----------------------------------------------------------------------------+
        | Create Debits/Credits for Collected Tax account for payment                |
        +----------------------------------------------------------------------------*/
         Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt * -1               ,
                               g_ae_summ_tax_tbl.ae_pro_acctd_amt * -1         ,
                               g_ae_summ_tax_tbl.ae_pro_split_taxable_amt  * -1        ,
                               g_ae_summ_tax_tbl.ae_pro_split_taxable_acctd_amt * -1   ,
                               --HYU--{
                               g_ae_summ_tax_tbl.ae_from_pro_amt * -1               ,
                               g_ae_summ_tax_tbl.ae_from_pro_acctd_amt * -1         ,
                               --HYU--}
                               l_ae_line_rec,
                               'Y');

       /*----------------------------------------------------------------------------+
        | Assign debit/credit for Collected tax account for payments to build table  |
        +----------------------------------------------------------------------------*/
         --Assign_Elements(l_ae_line_rec);
	 l_bulk_index := l_bulk_index + 1;
         l_ae_line_rec.ae_id :=  g_id;
	 l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	 l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;

     END IF; --End if create debits/credits for deferred tax associated with payment






       IF   (g_br_cust_trx_line_id IS NOT NULL)      AND
            (g_ae_doc_rec.source_table = 'TH')       AND
            (g_ae_summ_tax_tbl.activity_bucket  = 'ADJ_TAX')
       THEN
             Create_Debits_Credits(g_ae_summ_tax_tbl.ae_pro_amt               ,
                                   g_ae_summ_tax_tbl.ae_pro_acctd_amt         ,
                                   g_ae_summ_tax_tbl.ae_pro_recov_taxable_amt ,
                                   g_ae_summ_tax_tbl.ae_pro_recov_taxable_acctd_amt,
                                   --HYU--{
                                   g_ae_summ_tax_tbl.ae_from_pro_amt          ,
                                   g_ae_summ_tax_tbl.ae_from_pro_acctd_amt    ,
                                   --HYU--}
                                   l_ae_line_rec);
              --Assign_Elements(l_ae_line_rec);
	      l_bulk_index := l_bulk_index + 1;
              l_ae_line_rec.ae_id :=  g_id;
	      l_ae_line_rec.ae_summarize_flag := NVL(l_ae_line_rec.ae_summarize_flag,'N');
	      l_ae_alloc_rec_gt_tab( l_bulk_index ) := l_ae_line_rec;
        END IF;
        --}


   END LOOP; --For each Tax line build accounting entries

   /**In procedure Assign_Elements,g_ae_ctr is incremented for each record
    inserted.But no code segment in this package uses the value of the
    variable,thus not incremented the variable here.*/
   FORALL i IN l_ae_alloc_rec_gt_tab.first..l_ae_alloc_rec_gt_tab.last
   INSERT INTO ar_ae_alloc_rec_gt VALUES l_ae_alloc_rec_gt_tab(i);

   --Exit Last fetch
   IF l_last_fetch THEN
	EXIT;
    END IF;


  END LOOP;

  --close cursor
  CLOSE summarize_tax;

 /*------------------------------------------------------------+
  | Done processing deferred tax, so mark flag to signify this |
  +------------------------------------------------------------*/
   --IF p_type_acct = 'PAY' THEN
   IF g_ae_summ_tax_tbl.activity_bucket IN ('APP_LINE','APP_TAX','APP_FRT','APP_CHRG') THEN
      g_done_def_tax := TRUE;
   END IF;

--END IF; -- Build tax only if a tax amount or line amount exists amount exists
        -- i.e. if both line alloc and tax alloc are zero then there is nothing







 arp_standard.debug( 'ARP_ALLOCATION_PKG.Build_Tax()-');

EXCEPTION
  WHEN invalid_ccid_error THEN
     arp_standard.debug('Invalid Tax ccid - ARP_ALLOCATION_PKG.Build_Tax' );
     fnd_message.set_name('AR','AR_INVALID_TAX_ACCOUNT');
     RAISE;

  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Build_Tax');
     RAISE;

END Build_Tax;

/* ==========================================================================
 | PROCEDURE Build_Charges_Freight_All
 |
 | DESCRIPTION
 |    Build actual accounting entries for Charges and Freight accounts
 |    to Activity GL Account
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_type_acct             IN    Indicates earned, unearned discount or
 |                                  adjustment accounting
 |    p_ae_line_init_rec      IN    Initialization record contains details
 |                                  for exchange rate, source table, id
 |                                  common to all accounting entries
 |
 | NOTES
 |    In the code below we add the freight and charges amounts to the line
 |    this would already have been done in the Init_Amts routine. These
 |    statements are retained they can be removed later if required and are
 |    only for reference purposes. In reality the IF construct below which
 |    creates the accounting would be true only if p_build_all is true
 |    indicating Gross to Activity Gl account. In this case we route the
 |    creation through this routine.
 |  History
 |    21-NOV-2003   Herve Yu   from_amount_dr      ,  from_amount_cr
 |                             from_acctd_amount_dr,  from_acctd_amount_cr
 *==========================================================================*/
PROCEDURE Build_Charges_Freight_All(p_type_acct         IN VARCHAR2         ,
                                    p_ae_line_init_rec  IN ar_ae_alloc_rec_gt%ROWTYPE,
                                    p_build_all         IN BOOLEAN ) IS

l_ae_line_rec         ar_ae_alloc_rec_gt%ROWTYPE;
l_actual_account      ar_distributions.code_combination_id%TYPE ;
l_line_tax_amt        NUMBER := 0;
l_line_tax_acctd_amt  NUMBER := 0;

BEGIN

  arp_standard.debug('ARP_ALLOCATION_PKG.Build_Charges_Freight_All()+');

  adj_code_combination_id := '';

/*----------------------------------------------------------------------------------+
 | Build All flag indicates that Rule is Gross to Activity GL account for type Acct |
 +----------------------------------------------------------------------------------*/
  IF ((p_build_all = TRUE) AND (NOT g_added_tax)) THEN

     l_line_tax_amt       := g_ae_rule_rec.line_amt_alloc + g_ae_rule_rec.tax_amt_alloc;
     l_line_tax_acctd_amt := g_ae_rule_rec.line_acctd_amt_alloc + g_ae_rule_rec.tax_acctd_amt_alloc;

  ELSIF ((p_build_all = TRUE) AND (g_added_tax)) THEN

      --In this case tax would have been added to line bucket
        l_line_tax_amt       := g_ae_rule_rec.line_amt_alloc;
        l_line_tax_acctd_amt := g_ae_rule_rec.line_acctd_amt_alloc;

  END IF;

/*-----------------------------------------------------------------------------+
 | If freight or charges exists then create an accounting entry for a sum total|
 | or Gross to Activity GL Account                                             |
 +-----------------------------------------------------------------------------*/

  IF ((((g_ae_rule_rec.freight_amt_alloc <> 0) OR (g_ae_rule_rec.freight_acctd_amt_alloc <> 0))
       OR ((g_ae_rule_rec.charges_amt_alloc <> 0) AND (g_ae_rule_rec.charges_acctd_amt_alloc <> 0)))
       OR (p_build_all = TRUE))
  THEN

   /*----------------------------------------------------------------------------+
    | Initialize record with exchange rate, source id, table details for new line|
    +----------------------------------------------------------------------------*/
     l_ae_line_rec := p_ae_line_init_rec;

   /*----------------------------------------------------------------------------+
    | Populate source type for earned discounts                                  |
    +----------------------------------------------------------------------------*/
     IF p_type_acct = 'ED_ADJ' THEN

        IF g_ae_doc_rec.source_table = 'RA' THEN

           l_ae_line_rec.ae_line_type    := 'EDISC' ;

      /*----------------------------------------------------------------------------+
       | Populate source type for unearned discounts                                |
       +----------------------------------------------------------------------------*/
        ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN

              l_ae_line_rec.ae_line_type := 'ADJ';

      /*----------------------------------------------------------------------------+
       | Populate source type for finance charges                                   |
       +----------------------------------------------------------------------------*/
        ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN

              l_ae_line_rec.ae_line_type := 'FINCHRG';

        END IF;

        l_ae_line_rec.ae_account := g_ae_rule_rec.code_combination_id1;

  /*----------------------------------------------------------------------------+
   | Populate source type for unearned discounts                                |
   +----------------------------------------------------------------------------*/
    ELSIF p_type_acct = 'UNED' THEN

          l_ae_line_rec.ae_line_type    := 'UNEDISC';
          l_ae_line_rec.ae_account         := g_ae_rule_rec.code_combination_id2;

    END IF;

     l_actual_account := l_ae_line_rec.ae_account;

  /*--------------------------------------------------------------------------------+
   | Substitute balancing segment for the Activity GL Account, for deposites we     |
   | dont need to substitute the segment as the account is derived by Autoaccounting|
   | and should be in the balancing segment as that of the Receivable on Deposit    |
   +--------------------------------------------------------------------------------*/
    IF (g_ae_doc_rec.other_flag IN ('COMMITMENT', 'CHARGEBACK', 'CBREVERSAL')) THEN
       arp_standard.debug('Account derived by Autoaccounting');
    ELSE
     -- Bugfix 1948917.
     IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
     Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id             ,
                     p_original_ccid => l_actual_account                ,
                     p_subs_ccid     => g_ae_rule_rec.receivable_account,
                     p_actual_ccid   => l_ae_line_rec.ae_account             );
     ELSE
      l_ae_line_rec.ae_account := l_actual_account;
     END IF;
    END IF;

  /*----------------------------------------------------------------------------+
   | Set the activity ccid which will be stamped on adj.code_combination_id     |
   +----------------------------------------------------------------------------*/
    IF adj_code_combination_id IS NULL
       AND (((g_ae_rule_rec.freight_amt_alloc + g_ae_rule_rec.charges_amt_alloc +
             l_line_tax_amt) <> 0)
            OR ((g_ae_rule_rec.freight_acctd_amt_alloc + g_ae_rule_rec.charges_acctd_amt_alloc +
                 l_line_tax_acctd_amt) <> 0)) THEN
       adj_code_combination_id := l_ae_line_rec.ae_account;
    END IF;

  /*----------------------------------------------------------------------------+
   | Assign Accounting Debits and Credits based on prorated amount signs        |
   +----------------------------------------------------------------------------*/
     Create_Debits_Credits(g_ae_rule_rec.freight_amt_alloc       +
                           g_ae_rule_rec.charges_amt_alloc       +
                           l_line_tax_amt                          ,
                           g_ae_rule_rec.freight_acctd_amt_alloc +
                           g_ae_rule_rec.charges_acctd_amt_alloc +
                           l_line_tax_acctd_amt                    ,
                           ''                                      ,
                           ''                                      ,
                           '','',
                           l_ae_line_rec );

  /*----------------------------------------------------------------------------+
   | Assign built sum of Charges and Freight amounts to Activity gl account     |
   +----------------------------------------------------------------------------*/
     Assign_Elements(l_ae_line_rec);

  END IF; --end if p_build_all is TRUE

  arp_standard.debug('ARP_ALLOCATION_PKG.Build_Charges_Freight_All()-');

EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Build_Charges_Freight_All');
     RAISE;

END Build_Charges_Freight_All;


/* ==========================================================================
 | PROCEDURE Substitute_Ccid
 |
 | DESCRIPTION
 |    Builds the gain, loss, round account based on input parameters
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_coa_id                IN    Chart of Accounts id
 |    p_original_ccid         IN    Original ccid
 |    p_subs_ccid             IN    Substitute ccid
 |    p_actual_ccid           OUT   Actual or return ccid
 *==========================================================================*/
PROCEDURE Substitute_Ccid(p_coa_id        IN  gl_sets_of_books.chart_of_accounts_id%TYPE        ,
                          p_original_ccid IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_subs_ccid     IN  ar_system_parameters.code_combination_id_gain%TYPE,
                          p_actual_ccid   OUT NOCOPY ar_system_parameters.code_combination_id_gain%TYPE) IS

l_concat_segs           varchar2(240)                                           ;
l_concat_ids            varchar2(2000)                                          ;
l_concat_descs          varchar2(2000)                                          ;
l_arerror               varchar2(2000)                                          ;
l_actual_gain_loss_ccid ar_system_parameters_all.code_combination_id_gain%TYPE  ;
l_ctr                   BINARY_INTEGER                                          ;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Substitute_Ccid()+');
   END IF;

/*----------------------------------------------------------------------------+
 | Set other in out variables used by flex routine                            |
 +----------------------------------------------------------------------------*/
   p_actual_ccid           := NULL;
   l_actual_gain_loss_ccid := NULL; --must always be derived
   l_concat_segs           := NULL;
   l_concat_ids            := NULL;
   l_concat_descs          := NULL;

/*----------------------------------------------------------------------------+
 | Verify from Cache whether the final ccid for a given combination of chart  |
 | of accounts, orig ccid and substitute ccid already exists in cache.        |
 +----------------------------------------------------------------------------*/

   IF cache_ctr > 0 THEN
      FOR l_ctr IN flex_parms_tbl.FIRST .. flex_parms_tbl.LAST LOOP
          IF flex_parms_tbl(l_ctr).coa_id = p_coa_id AND
                flex_parms_tbl(l_ctr).orig_ccid = p_original_ccid  AND
                   flex_parms_tbl(l_ctr).subs_ccid = p_subs_ccid THEN --hit found

             l_actual_gain_loss_ccid := flex_parms_tbl(l_ctr).actual_ccid;

             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder Cache: Chart of Accounts ' || p_coa_id);
                arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder Cache: Original CCID     ' || p_original_ccid);
                arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder Cache: Substitute CCID   ' || p_subs_ccid);
                arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder Cache: Actual CCID       ' || l_actual_gain_loss_ccid);
             END IF;

             EXIT; --exit loop as hit is found

          END IF;
      END LOOP;
   END IF;

/*----------------------------------------------------------------------------+
 | Derive gain loss account using flex routine                                |
 +----------------------------------------------------------------------------*/
   IF l_actual_gain_loss_ccid is NULL THEN

      IF NOT ar_flexbuilder_wf_pkg.substitute_balancing_segment (
                                              x_arflexnum     => p_coa_id                         ,
                                              x_arorigccid    => p_original_ccid                  ,
                                              x_arsubsticcid  => p_subs_ccid                      ,
                                              x_return_ccid   => l_actual_gain_loss_ccid          ,
                                              x_concat_segs   => l_concat_segs                    ,
                                              x_concat_ids    => l_concat_ids                     ,
                                              x_concat_descrs => l_concat_descs                   ,
                                              x_arerror       => l_arerror                          ) THEN

       /*----------------------------------------------------------------------------+
        | Invalid account raise user exception                                       |
        +----------------------------------------------------------------------------*/
         RAISE flex_subs_ccid_error;

      END IF;

    /*----------------------------------------------------------------------------+
     | Cache the gain loss account as it has been successfully derived            |
     +----------------------------------------------------------------------------*/
      cache_ctr := cache_ctr + 1;  --counter is never reset within a success unit
      flex_parms_tbl(cache_ctr).coa_id      := p_coa_id;
      flex_parms_tbl(cache_ctr).orig_ccid   := p_original_ccid;
      flex_parms_tbl(cache_ctr).subs_ccid   := p_subs_ccid;
      flex_parms_tbl(cache_ctr).actual_ccid := l_actual_gain_loss_ccid;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder : Chart of Accounts ' || p_coa_id);
         arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder : Original CCID     ' || p_original_ccid);
         arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder : Substitute CCID   ' || p_subs_ccid);
         arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder : Actual CCID       ' || l_actual_gain_loss_ccid);
      END IF;

   END IF;

   p_actual_ccid := l_actual_gain_loss_ccid;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Substitute_Ccid()-');
   END IF;

EXCEPTION
WHEN flex_subs_ccid_error  THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Flexbuilder error: ARP_ALLOCATION_PKG.Substitute_Ccid');
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Chart of Accounts ' || p_coa_id);
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Original CCID     ' || p_original_ccid);
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Substitute CCID   ' || p_subs_ccid);
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Actual CCID       ' || l_actual_gain_loss_ccid);
     END IF;
     fnd_message.set_name('AR','AR_FLEX_CCID_ERROR');
     fnd_message.set_token('COA',TO_CHAR(p_coa_id));
     fnd_message.set_token('ORG_CCID',TO_CHAR(p_original_ccid));
     fnd_message.set_token('SUB_CCID',TO_CHAR(p_subs_ccid));
     RAISE;

WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Substitute_Ccid');
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Chart of Accounts ' || p_coa_id);
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Original CCID     ' || p_original_ccid);
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Substitute CCID   ' || p_subs_ccid);
        arp_standard.debug('Substitute_Ccid: ' || 'Flexbuilder error: Actual CCID       ' || l_actual_gain_loss_ccid);
     END IF;
     RAISE;

END Substitute_Ccid;

/* ==========================================================================
 | PROCEDURE Create_Debits_Credits
 |
 | DESCRIPTION
 |    Populates accounting debit and credit amounts and taxable amounts based
 |    on signs
 |
 | NOTES
 |    Them amounts and accounted amounts are always in the same sign as the
 |    other or zero. When both the amounts and accounted amounts are zero,
 |    the taxable amount or taxable accounted amount are used to determine
 |    the debits and credit entries.
 |
 |    This routine is never called when both amount and taxable amounts are
 |    zero.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_amount                IN    Amount
 |    p_acctd_amount          IN    Accounted Amount
 |    p_taxable_amount        IN    Taxable Amount
 |    p_taxable_acctd_amount  IN    Taxable Accounted Amount
 |    p_ae_line_rec           OUT   Line record
 | History
 |  21-NOV-2003   Herve Yu    from_amount_dr      , from_amount_cr
 |                            from_acctd_amount_dr, from_acctd_amount_cr
 *==========================================================================*/
PROCEDURE Create_Debits_Credits(p_amount               IN NUMBER       ,
                                p_acctd_amount         IN NUMBER       ,
                                p_taxable_amount       IN NUMBER       ,
                                p_taxable_acctd_amount IN NUMBER       ,
                                --HYU--{
                                p_from_amount               IN NUMBER       ,
                                p_from_acctd_amount         IN NUMBER       ,
                                --HYU--}
                                p_ae_line_rec          IN OUT NOCOPY ar_ae_alloc_rec_gt%ROWTYPE,
                                p_paired_flag          IN VARCHAR2 DEFAULT NULL,
                                p_calling_point        IN VARCHAR2 DEFAULT NULL) IS

l_taxable_set BOOLEAN;

BEGIN
   arp_standard.debug( 'ARP_ALLOCATION_PKG.Create_Debits_Credits()+');

   arp_standard.debug('p_amount ' || p_amount);
   arp_standard.debug('p_acctd_amount ' || p_acctd_amount);
   arp_standard.debug('p_taxable_amount' || p_taxable_amount);
   arp_standard.debug('p_taxable_acctd_amount' || p_taxable_acctd_amount);
   arp_standard.debug('p_calling_point       ' || p_calling_point);

   l_taxable_set := FALSE;

 /*----------------------------------------------------------------------------+
  | Set negativity indicator for 0 amounts and taxable amounts based on sign of|
  | the receivable. When summarizing finally just use the indicator do not set |
  +----------------------------------------------------------------------------*/
   IF ((p_amount = 0) AND (p_acctd_amount = 0) AND (nvl(p_taxable_amount,0) = 0)
      AND (nvl(p_taxable_acctd_amount,0) = 0) AND (nvl(p_calling_point,'X') <> 'SUMMARIZE')) THEN

      arp_standard.debug('g_ae_rule_rec.line_amt_alloc ' || g_ae_rule_rec.line_amt_alloc);
      arp_standard.debug('g_ae_rule_rec.tax_amt_alloc ' || g_ae_rule_rec.tax_amt_alloc);
      arp_standard.debug('p_paired_flag ' || p_paired_flag);

    --set negativity indicator for debits nullvalue indicates a credit
      IF ((g_ae_rule_rec.line_amt_alloc + g_ae_rule_rec.tax_amt_alloc) < 0) THEN
         p_ae_line_rec.ae_neg_ind := -1;

         IF nvl(p_paired_flag, 'N') = 'Y' THEN
            p_ae_line_rec.ae_neg_ind := NULL; --Create Credit to Collected tax account
         END IF;

         arp_standard.debug('p_ae_line_rec.ae_neg_ind < 0 condition ' || p_ae_line_rec.ae_neg_ind);

      ELSE
         p_ae_line_rec.ae_neg_ind := NULL; --set to create Credits

         IF nvl(p_paired_flag, 'N') = 'Y' THEN
            p_ae_line_rec.ae_neg_ind := -1;  --Create Debit to collected tax account
         END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('p_ae_line_rec.ae_neg_ind >= 0 condition ' || p_ae_line_rec.ae_neg_ind);
        END IF;

      END IF; --default is null

   END IF; --end if negativity indicator set condition

 /*----------------------------------------------------------------------------+
  | Create accounting amount and taxable amount debits based on signs          |
  +----------------------------------------------------------------------------*/
   IF ((p_amount < 0) OR (p_acctd_amount < 0)) THEN
      p_ae_line_rec.ae_entered_dr           := abs(p_amount)              ;
      p_ae_line_rec.ae_accounted_dr         := abs(p_acctd_amount)        ;

      p_ae_line_rec.ae_entered_cr           := NULL                       ;
      p_ae_line_rec.ae_accounted_cr         := NULL                       ;
      p_ae_line_rec.ae_from_amount_dr       := abs(p_from_amount)              ;
      p_ae_line_rec.ae_from_acctd_amount_dr := abs(p_from_acctd_amount)        ;
      p_ae_line_rec.ae_from_amount_cr       := NULL                       ;
      p_ae_line_rec.ae_from_acctd_amount_cr := NULL                       ;

 --Tax amounts are zero, however taxable amounts used to determine Dr, Cr
   ELSIF (((p_amount = 0) AND (p_acctd_amount = 0))
          AND ((nvl(p_taxable_amount,0) <> 0) OR (nvl(p_taxable_acctd_amount,0) <> 0))) THEN
 /*----------------------------------------------------------------------------+
  | Create accounting amount and taxable amount credits based on sign          |
  +----------------------------------------------------------------------------*/
      IF ((nvl(p_taxable_amount,0) < 0) OR (nvl(p_taxable_acctd_amount,0) < 0)) THEN
         p_ae_line_rec.ae_entered_dr           := abs(p_amount)              ;
         p_ae_line_rec.ae_accounted_dr         := abs(p_acctd_amount)        ;
         p_ae_line_rec.ae_from_amount_dr       := abs(p_from_amount)              ;
         p_ae_line_rec.ae_from_acctd_amount_dr := abs(p_from_acctd_amount)        ;

         IF p_ae_line_rec.ae_line_type IN ('TAX','DEFERRED_TAX','ADJ_NON_REC_TAX',
                                           'EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX',
                                           'FINCHRG_NON_REC_TAX')
         THEN
            l_taxable_set := TRUE;
            p_ae_line_rec.ae_taxable_entered_dr   := abs(p_taxable_amount);
            p_ae_line_rec.ae_taxable_accounted_dr := abs(p_taxable_acctd_amount);
         END IF;

         p_ae_line_rec.ae_entered_cr           := NULL                       ;
         p_ae_line_rec.ae_accounted_cr         := NULL                       ;
         p_ae_line_rec.ae_taxable_entered_cr   := NULL                       ;
         p_ae_line_rec.ae_taxable_accounted_cr := NULL                       ;
         p_ae_line_rec.ae_from_amount_cr       := NULL                       ;
         p_ae_line_rec.ae_from_acctd_amount_cr := NULL                       ;

      ELSE  --Create Credits
         p_ae_line_rec.ae_entered_cr           := abs(p_amount)              ;
         p_ae_line_rec.ae_accounted_cr         := abs(p_acctd_amount)        ;
         p_ae_line_rec.ae_from_amount_cr       := abs(p_from_amount)         ;
         p_ae_line_rec.ae_from_acctd_amount_cr := abs(p_from_acctd_amount)   ;

         --{need to comment this out for taxable amount in the case of application
         --IF p_ae_line_rec.ae_line_type IN ('TAX','DEFERRED_TAX','ADJ_NON_REC_TAX',
         --                                  'EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX',
         --                                  'FINCHRG_NON_REC_TAX')
         --THEN
         --   l_taxable_set := TRUE;
           p_ae_line_rec.ae_taxable_entered_cr   := abs(p_taxable_amount);
           p_ae_line_rec.ae_taxable_accounted_cr := abs(p_taxable_acctd_amount);
         --END IF;

         p_ae_line_rec.ae_entered_dr           := NULL                       ;
         p_ae_line_rec.ae_accounted_dr         := NULL                       ;
         p_ae_line_rec.ae_taxable_entered_dr   := NULL                       ;
         p_ae_line_rec.ae_taxable_accounted_dr := NULL                       ;
         p_ae_line_rec.ae_from_amount_dr       := NULL              ;
         p_ae_line_rec.ae_from_acctd_amount_dr := NULL              ;

      END IF; --line amount is negative for Debits

 /*------------------------------------------------------------------------------------------+
  |Tax amounts are zero, taxable amounts are also zero use negativity indicator for Dr and Cr|
  |we need to do this for tax lines, and only when called from the final Summary routine.    |
  +------------------------------------------------------------------------------------------*/
   ELSIF (((p_amount = 0) AND (p_acctd_amount = 0))
          AND (nvl(p_taxable_amount,0) = 0) AND (nvl(p_taxable_acctd_amount,0) = 0)
          AND (nvl(p_calling_point, 'X') = 'SUMMARIZE')) THEN

          IF (nvl(p_ae_line_rec.ae_neg_ind,0) < 0) THEN --Create Debits
             p_ae_line_rec.ae_entered_dr           := abs(p_amount)               ;
             p_ae_line_rec.ae_accounted_dr         := abs(p_acctd_amount)         ;
             p_ae_line_rec.ae_taxable_entered_dr   := abs(p_taxable_amount)       ;
             p_ae_line_rec.ae_taxable_accounted_dr := abs(p_taxable_acctd_amount) ;
             p_ae_line_rec.ae_from_amount_dr       := abs(p_from_amount)              ;
             p_ae_line_rec.ae_from_acctd_amount_dr := abs(p_from_acctd_amount)        ;

             l_taxable_set := TRUE;

             p_ae_line_rec.ae_entered_cr           := NULL                       ;
             p_ae_line_rec.ae_accounted_cr         := NULL                       ;
             p_ae_line_rec.ae_taxable_entered_cr   := NULL                       ;
             p_ae_line_rec.ae_taxable_accounted_cr := NULL                       ;
             p_ae_line_rec.ae_from_amount_cr       := NULL                       ;
             p_ae_line_rec.ae_from_acctd_amount_cr := NULL                       ;

          ELSE --create Credits for accounting entry
             p_ae_line_rec.ae_entered_cr           := abs(p_amount)              ;
             p_ae_line_rec.ae_accounted_cr         := abs(p_acctd_amount)        ;
             p_ae_line_rec.ae_taxable_entered_cr   := abs(p_taxable_amount)      ;
             p_ae_line_rec.ae_taxable_accounted_cr := abs(p_taxable_acctd_amount);
             p_ae_line_rec.ae_from_amount_cr       := abs(p_from_amount)         ;
             p_ae_line_rec.ae_from_acctd_amount_cr := abs(p_from_acctd_amount)   ;
             l_taxable_set := TRUE;

             p_ae_line_rec.ae_entered_dr           := NULL                       ;
             p_ae_line_rec.ae_accounted_dr         := NULL                       ;
             p_ae_line_rec.ae_taxable_entered_dr   := NULL                       ;
             p_ae_line_rec.ae_taxable_accounted_dr := NULL                       ;
             p_ae_line_rec.ae_from_amount_dr       := NULL        ;
             p_ae_line_rec.ae_from_acctd_amount_dr := NULL        ;

          END IF; --negativity indicator

   ELSE --create Credits
 /*----------------------------------------------------------------------------+
  | Create accounting amount and taxable amount credits based on sign          |
  +----------------------------------------------------------------------------*/
      p_ae_line_rec.ae_entered_cr           := abs(p_amount)              ;
      p_ae_line_rec.ae_accounted_cr         := abs(p_acctd_amount)        ;

      p_ae_line_rec.ae_entered_dr           := NULL                       ;
      p_ae_line_rec.ae_accounted_dr         := NULL                       ;
      p_ae_line_rec.ae_from_amount_cr       := abs(p_from_amount)              ;
      p_ae_line_rec.ae_from_acctd_amount_cr := abs(p_from_acctd_amount)        ;
      p_ae_line_rec.ae_from_amount_dr       := NULL                       ;
      p_ae_line_rec.ae_from_acctd_amount_dr := NULL                       ;

   END IF; --sign of amounts

 /*----------------------------------------------------------------------------+
  | Set the taxable amounts and accounted amounts                              |
  +----------------------------------------------------------------------------*/
 -- This need to be executed every time???
 --  IF (p_ae_line_rec.ae_line_type IN ('TAX', 'DEFERRED_TAX', 'ADJ_NON_REC_TAX',
 --                                    'EDISC_NON_REC_TAX','UNEDISC_NON_REC_TAX',
 --                                    'FINCHRG_NON_REC_TAX')
 --     AND (NOT l_taxable_set)) THEN

 --      l_taxable_set := TRUE;

      IF ((nvl(p_taxable_amount,0) < 0) OR (nvl(p_taxable_acctd_amount,0) < 0))
      THEN
          p_ae_line_rec.ae_taxable_entered_dr   := abs(p_taxable_amount)       ;
          p_ae_line_rec.ae_taxable_accounted_dr := abs(p_taxable_acctd_amount) ;
          p_ae_line_rec.ae_taxable_entered_cr   := NULL                        ;
          p_ae_line_rec.ae_taxable_accounted_cr := NULL                        ;

      ELSIF (((nvl(p_taxable_amount,0) = 0) AND (nvl(p_taxable_acctd_amount,0) = 0))
             AND ((p_amount <> 0) OR (p_acctd_amount <> 0)))
      THEN
             IF ((p_amount < 0) OR (p_acctd_amount < 0)) THEN
                p_ae_line_rec.ae_taxable_entered_dr    := abs(p_taxable_amount);
                p_ae_line_rec.ae_taxable_accounted_dr  := abs(p_taxable_acctd_amount);
                p_ae_line_rec.ae_taxable_entered_cr    := NULL;
                p_ae_line_rec.ae_taxable_accounted_cr  := NULL;
             ELSE
                p_ae_line_rec.ae_taxable_entered_cr    := abs(p_taxable_amount);
                p_ae_line_rec.ae_taxable_accounted_cr  := abs(p_taxable_acctd_amount);
                p_ae_line_rec.ae_taxable_entered_dr    := NULL;
                p_ae_line_rec.ae_taxable_accounted_dr  := NULL;
             END IF;
      ELSE
          p_ae_line_rec.ae_taxable_entered_cr   := abs(p_taxable_amount)       ;
          p_ae_line_rec.ae_taxable_accounted_cr := abs(p_taxable_acctd_amount) ;
          p_ae_line_rec.ae_taxable_entered_dr   := NULL                        ;
          p_ae_line_rec.ae_taxable_accounted_dr := NULL                        ;

      END IF; --sign of taxable amount

--   END IF; --if line type is tax and taxable amount is not set
--   arp_standard.debug('Start Credit Debit Dump');
--   Dump_Line_Amts(p_ae_line_rec);
--   arp_standard.debug('End Credit Debit Dump');

   arp_standard.debug( 'ARP_ALLOCATION_PKG.Create_Debits_Credits()-');

EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Create_Debits_Credits');
     RAISE;

END Create_Debits_Credits;

/* ==========================================================================
 | PROCEDURE Summarize_Accounting_Lines
 |
 | DESCRIPTION
 |    Net out the accounting for earned discounts, unearned discounts and
 |    payments, for adjustment (includes finance charges) multiple layers
 |    of accounting lines will not exist however this routine will be
 |    executed.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    NONE
 | History
 |   21-NOV-2003  Herve Yu    from_amount_dr       , from_amount_cr,
 |                            from_acctd_amount_dr , from_acctd_amount_cr
 *==========================================================================*/
PROCEDURE Summarize_Accounting_Lines IS

l_ctr1           BINARY_INTEGER;
l_ctr2           BINARY_INTEGER;
--BUG#3509185  l_summ_ctr       BINARY_INTEGER := 0;
l_ent_amt        NUMBER;
l_ent_acctd_amt  NUMBER;
l_txb_amt        NUMBER;
l_txb_acctd_amt  NUMBER;
l_from_ent_amt        NUMBER;
l_from_ent_acctd_amt  NUMBER;
l_ae_line_rec    ar_ae_alloc_rec_gt%ROWTYPE;
l_ae_empty_rec   ar_ae_alloc_rec_gt%ROWTYPE;

CURSOR summarize_lines IS
SELECT /*+ INDEX(a1 AR_AE_ALLOC_REC_GT_N3) */
       NVL(a1.ae_entered_dr,0)           * -1 + NVL(a1.ae_entered_cr,0),
       NVL(a1.ae_accounted_dr,0)         * -1 + NVL(a1.ae_accounted_cr,0),
--       SUM(NVL(ae_pro_amt,0)),
--       SUM(NVL(ae_pro_acctd_amt,0)),
       NVL(a1.ae_taxable_entered_dr,0)   * -1 + NVL(a1.ae_taxable_entered_cr,0),
       NVL(a1.ae_taxable_accounted_dr,0) * -1 + NVL(a1.ae_taxable_accounted_cr,0),
       NVL(a1.ae_from_amount_dr,0)       * -1 + NVL(a1.ae_from_amount_cr,0),
       NVL(a1.ae_from_acctd_amount_dr,0) * -1 + NVL(a1.ae_from_acctd_amount_cr,0),
       a1.ae_line_type,
       a1.ae_line_type_secondary,
       a1.ae_source_id,
       a1.ae_source_table,
       a1.ae_account,
       a1.ae_source_id_secondary,
       a1.ae_source_table_secondary,
       a1.ae_currency_code,
       a1.ae_currency_conversion_rate,
       a1.ae_currency_conversion_type,
       a1.ae_currency_conversion_date,
       a1.ae_third_party_id,
       a1.ae_third_party_sub_id,
       a1.ae_tax_group_code_id,
       a1.ae_tax_code_id,
       a1.ae_location_segment_id,
       a1.ae_tax_link_id,
       decode(a1.ae_neg_ind,
              -1, decode(Retain_Neg_Ind(a1.rowid),
                         1, a1.ae_neg_ind,
                         ''),
              a1.ae_neg_ind),
       a1.ae_reversed_source_id,
       DECODE(a1.ae_cust_trx_line_gl_dist_id,0 ,''
                                            ,-1,'',a1.ae_customer_trx_line_id),
       DECODE(a1.ae_cust_trx_line_gl_dist_id,0 ,''
                                            ,-1,'',a1.ae_cust_trx_line_gl_dist_id),
       a1.ae_ref_line_id,
       a1.ref_account_class,
       a1.activity_bucket,
       a1.ref_dist_ccid,
       a1.ref_mf_dist_flag
FROM ar_ae_alloc_rec_gt a1
WHERE a1.ae_id = g_id
AND a1.ae_summarize_flag = 'N'
AND a1.ae_account_class IS NULL
AND (NVL(a1.ae_entered_dr,0) <> 0 OR NVL(a1.ae_entered_cr,0) <> 0 OR
     NVL(a1.ae_accounted_dr,0) <> 0 OR NVL(a1.ae_accounted_cr,0) <> 0  /*6321537*/
     OR (a1.ae_line_type IN ('TAX','DEFERRED_TAX','EDISC_NON_REC_TAX',
                             'UNEDISC_NON_REC_TAX','ADJ_NON_REC_TAX',
                              'FINCHRG_NON_REC_TAX')
      AND (NVL(a1.ae_entered_dr,0) = 0 AND NVL(a1.ae_entered_cr,0) = 0 AND
           NVL(a1.ae_accounted_dr,0) = 0 AND NVL(a1.ae_accounted_cr,0) = 0)));
--AND NVL(ae_pro_amt,0) <> 0
--}
/*
GROUP BY  a1.ae_customer_trx_line_id,
          a1.ae_cust_trx_line_gl_dist_id,
          a1.ae_ref_line_id,
          a1.ae_line_type,
          a1.ae_line_type_secondary,
          a1.ae_source_id,
          a1.ae_source_table,
          a1.ae_account,
          a1.ae_source_id_secondary,
          a1.ae_source_table_secondary,
          a1.ae_currency_code,
          a1.ae_currency_conversion_rate,
          a1.ae_currency_conversion_type,
          a1.ae_currency_conversion_date,
          a1.ae_third_party_id,
          a1.ae_third_party_sub_id,
          a1.ae_tax_group_code_id,
          a1.ae_tax_code_id,
          a1.ae_location_segment_id,
          a1.ae_tax_link_id,
          decode(a1.ae_neg_ind,
                 -1, decode(Retain_Neg_Ind(a1.rowid),
                            1, a1.ae_neg_ind,
                            ''),
                 a1.ae_neg_ind),
          a1.ae_reversed_source_id,
--{HYUDETUPT
          a1.ref_account_class,
          a1.activity_bucket
--}
 ORDER BY  decode(a1.ae_line_type,
                'EDISC'              ,-6,
                'ADJ'                ,-6,
                'FINCHRG'            ,-6,
                'UNEDISC'            ,-6,
                a1.ae_tax_link_id),
          decode(a1.ae_line_type,
                 'EDISC_NON_REC_TAX' , -5,
                 'ADJ_NON_REC_TAX'    ,-5,
                 'FINCHRG_NON_REC_TAX',-5,
                 'UNEDISC_NON_REC_TAX',-5,
                 'DEFERRED_TAX',decode(a1.ae_line_type_secondary,
                                       'EDISC'  , -4,
                                       'ADJ'    , -4,
                                       'FINCHRG', -4,
                                       'UNEDISC', -4,
                                       -2),
                 'TAX'         ,decode(a1.ae_line_type_secondary,
                                       'EDISC'  , -3,
                                       'ADJ'    , -3,
                                       'FINCHRG', -3,
                                       'UNEDISC', -3,
                                       -1),
                a1.ae_tax_link_id);
*/

BEGIN
    arp_standard.debug( 'ARP_ALLOCATION_PKG.Summarize_Accounting_Lines()+');
 /*------------------------------------------------------------------------------+
  |Summarize Accounting entries for revenue and tax to net out accounting entries|
  |because the table g_ae_line_tbl contains accounting for earned discounts,     |
  |unearned discounts and payments, so the requirement for another level of      |
  |summarization for netting                                                     |
  +------------------------------------------------------------------------------*/
   --Bulk processing of distribution records [Bug 6454022]
   IF NVL(g_simul_app,'N') = 'N' THEN
     IF (NVL(g_ae_sys_rec.sob_type,'P') = 'P') THEN

	INSERT INTO  ar_distributions (
		line_id,
		source_id,
		source_table,
		source_type,
		source_type_secondary,
		code_combination_id,
		amount_dr,
		amount_cr,
		acctd_amount_dr,
		acctd_amount_cr,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		source_id_secondary,
		source_table_secondary,
		currency_code        ,
		currency_conversion_rate,
		currency_conversion_type,
		currency_conversion_date,
		third_party_id,
		third_party_sub_id,
		tax_code_id,
		location_segment_id,
		taxable_entered_dr,
		taxable_entered_cr,
		taxable_accounted_dr,
		taxable_accounted_cr,
		tax_link_id,
		reversed_source_id,
		tax_group_code_id,
		org_id,
		ref_customer_trx_line_id,
		ref_cust_trx_line_gl_dist_id,
		ref_line_id,
		from_amount_dr,
		from_amount_cr,
		from_acctd_amount_dr,
		from_acctd_amount_cr,
		ref_account_class,
		activity_bucket,
		ref_dist_ccid,
		ref_mf_dist_flag
  	 )
	 SELECT   ar_distributions_s.nextval,
		  al.ae_source_id,
		  al.ae_source_table,
		  al.ae_line_type,
		  al.ae_line_type_secondary,
		  al.ae_account,
		  CASE WHEN (amount < 0) OR (acctd_amount < 0) THEN  abs(amount)
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
		         CASE WHEN (nvl(taxable_amount,0) < 0) OR
				   (nvl(taxable_acctd_amount,0) < 0) THEN abs(amount)
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0) THEN abs(amount)
			      ELSE null END
		  ELSE  null END  ae_entered_dr,

		  CASE WHEN (amount < 0) OR (acctd_amount < 0) THEN null
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
			 CASE WHEN (nvl(taxable_amount,0) < 0) OR
				   (nvl(taxable_acctd_amount,0) < 0) THEN null
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0) THEN null
			 ELSE abs(amount) END
		  ELSE abs(amount) END ae_entered_cr,

		  CASE WHEN (amount < 0) OR (acctd_amount < 0) THEN abs(acctd_amount)
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
			 CASE WHEN (nvl(taxable_amount,0) < 0) OR
			           (nvl(taxable_acctd_amount,0) < 0) THEN abs(acctd_amount)
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0) THEN abs(acctd_amount)
			 ELSE null END
		  ELSE null END ae_accounted_dr,

		  CASE WHEN (amount < 0) OR (acctd_amount < 0) THEN null
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
			 CASE WHEN (nvl(taxable_amount,0) < 0) OR
				   (nvl(taxable_acctd_amount,0) < 0) THEN null
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0) THEN null
			 ELSE abs(acctd_amount) END
		  ELSE abs(acctd_amount) END ae_accounted_cr,

		  arp_standard.profile.user_id,
		  SYSDATE,
		  arp_standard.profile.user_id,
		  SYSDATE,
		  arp_standard.profile.last_update_login,
		  al.ae_source_id_secondary,
		  al.ae_source_table_secondary,
		  al.ae_currency_code,
		  al.ae_currency_conversion_rate,
		  al.ae_currency_conversion_type,
		  al.ae_currency_conversion_date,
		  al.ae_third_party_id,
		  al.ae_third_party_sub_id,
		  al.ae_tax_code_id,
		  al.ae_location_segment_id,
		  CASE WHEN ( nvl(taxable_amount,0) < 0) OR
			    ( nvl(taxable_acctd_amount,0) < 0) THEN abs(taxable_amount)
		       WHEN ( nvl(taxable_amount,0) = 0 ) AND
			    ( nvl(taxable_acctd_amount,0) = 0 ) AND
			    ( ( amount < 0 ) OR ( acctd_amount < 0 )) THEN abs(taxable_amount)
		  ELSE	null END  ae_taxable_entered_dr,

		  CASE WHEN ( nvl(taxable_amount,0) < 0) OR
			    ( nvl(taxable_acctd_amount,0) < 0) THEN null
		       WHEN ( nvl(taxable_amount,0) = 0 ) AND
			    ( nvl(taxable_acctd_amount,0) = 0 ) AND
			    ( ( amount < 0 ) OR ( acctd_amount < 0 ))THEN null
		  ELSE abs(taxable_amount) END ae_taxable_entered_cr,

		  CASE WHEN ( nvl(taxable_amount,0) < 0) OR
			    ( nvl(taxable_acctd_amount,0) < 0)THEN abs(taxable_acctd_amount)
		       WHEN ( nvl(taxable_amount,0) = 0 ) AND
			    ( nvl(taxable_acctd_amount,0) = 0 ) AND
			    ( ( amount < 0 ) OR ( acctd_amount < 0 ))THEN abs(taxable_acctd_amount)
		  ELSE null END ae_taxable_accounted_dr,

		  CASE WHEN ( nvl(taxable_amount,0) < 0) OR
			    ( nvl(taxable_acctd_amount,0) < 0)THEN null
		       WHEN ( nvl(taxable_amount,0) = 0 ) AND
			    ( nvl(taxable_acctd_amount,0) = 0 ) AND
			    ( ( amount < 0 ) OR ( acctd_amount < 0 ))THEN null
		  ELSE	abs(taxable_acctd_amount) END ae_taxable_accounted_cr ,
		  al.ae_tax_link_id,
		  al.ae_reversed_source_id,
		  al.ae_tax_group_code_id,
		  arp_standard.sysparm.org_id, /* SSA changes anuj */
		  al.ae_customer_trx_line_id,
		  al.ae_cust_trx_line_gl_dist_id,
		  al.ae_ref_line_id,
		  CASE WHEN (amount < 0) OR (acctd_amount < 0) THEN abs(from_amount)
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
			 CASE WHEN (nvl(taxable_amount,0) < 0) OR
				   (nvl(taxable_acctd_amount,0) < 0)THEN abs(from_amount)
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0) THEN abs(from_amount)
			      ELSE null END
		  ELSE null END ae_from_amount_dr,

		  CASE WHEN (amount < 0) OR (acctd_amount < 0)THEN null
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
			 CASE WHEN (nvl(taxable_amount,0) < 0) OR
				   (nvl(taxable_acctd_amount,0) < 0) THEN null
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0)THEN null
			 ELSE abs(from_amount) END
		  ELSE abs(from_amount) END ae_from_amount_cr,

		  CASE WHEN (amount < 0) OR (acctd_amount < 0)THEN abs(from_acctd_amount)
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
			 CASE WHEN (nvl(taxable_amount,0) < 0) OR
				   (nvl(taxable_acctd_amount,0) < 0)THEN abs(from_acctd_amount)
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0)THEN abs(from_acctd_amount)
			 ELSE null END
		  ELSE null END ae_from_acctd_amount_dr,

		  CASE WHEN (amount < 0) OR (acctd_amount < 0) THEN null
		       WHEN (amount = 0) AND (acctd_amount = 0) THEN
			 CASE WHEN (nvl(taxable_amount,0) < 0) OR
				   (nvl(taxable_acctd_amount,0) < 0)THEN null
			      WHEN (nvl(taxable_amount,0) = 0) AND
				   (nvl(taxable_acctd_amount,0) = 0) AND
				   (nvl(ae_neg_ind,0) < 0)THEN null
			 ELSE abs(from_acctd_amount) END
		  ELSE abs(from_acctd_amount) END ae_from_acctd_amount_cr,
		  al.ref_account_class,
		  al.activity_bucket,
		  al.ref_dist_ccid,
		  al.ref_mf_dist_flag
	  from
	  ( --Defined it as a subquery as some of the values[Amount columns] derived in this
	    --  select are used for further calculations in the main select.
	    SELECT /*+ INDEX(a1 AR_AE_ALLOC_REC_GT_N3) */
		   NVL(a1.ae_entered_dr,0)           * -1 + NVL(a1.ae_entered_cr,0) amount,
		   NVL(a1.ae_accounted_dr,0)         * -1 + NVL(a1.ae_accounted_cr,0) acctd_amount,
		   NVL(a1.ae_taxable_entered_dr,0)   * -1 + NVL(a1.ae_taxable_entered_cr,0)  taxable_amount,
		   NVL(a1.ae_taxable_accounted_dr,0) * -1 + NVL(a1.ae_taxable_accounted_cr,0) taxable_acctd_amount,
		   NVL(a1.ae_from_amount_dr,0)       * -1 + NVL(a1.ae_from_amount_cr,0)  from_amount,
		   NVL(a1.ae_from_acctd_amount_dr,0) * -1 + NVL(a1.ae_from_acctd_amount_cr,0) from_acctd_amount,
		   a1.ae_line_type,
		   a1.ae_line_type_secondary,
		   a1.ae_source_id,
		   a1.ae_source_table,
		   a1.ae_account,
		   a1.ae_source_id_secondary,
		   a1.ae_source_table_secondary,
		   a1.ae_currency_code,
		   a1.ae_currency_conversion_rate,
		   a1.ae_currency_conversion_type,
		   a1.ae_currency_conversion_date,
		   a1.ae_third_party_id,
		   a1.ae_third_party_sub_id,
		   a1.ae_tax_group_code_id,
		   a1.ae_tax_code_id,
		   a1.ae_location_segment_id,
		   a1.ae_tax_link_id,
		   decode(a1.ae_neg_ind,
			  -1, decode(Retain_Neg_Ind(a1.rowid),
				     1, a1.ae_neg_ind,
				     ''),
			  a1.ae_neg_ind) ae_neg_ind,
		   a1.ae_reversed_source_id,
		   DECODE(a1.ae_cust_trx_line_gl_dist_id,0 ,''
							,-1,'',a1.ae_customer_trx_line_id)
							ae_customer_trx_line_id,
		   DECODE(a1.ae_cust_trx_line_gl_dist_id,0 ,''
							,-1,'',a1.ae_cust_trx_line_gl_dist_id)
							ae_cust_trx_line_gl_dist_id,
		   a1.ae_ref_line_id,
		   a1.ref_account_class,
		   a1.activity_bucket,
		   a1.ref_dist_ccid,
		   a1.ref_mf_dist_flag
	    FROM ar_ae_alloc_rec_gt a1
	    WHERE a1.ae_id = g_id
	    AND a1.ae_summarize_flag = 'N'
	    AND a1.ae_account_class IS NULL
	    AND (NVL(a1.ae_entered_dr,0) <> 0 OR NVL(a1.ae_entered_cr,0) <> 0
              OR NVL(a1.ae_accounted_dr,0) <> 0 OR NVL(a1.ae_accounted_cr,0) <> 0
              OR (a1.ae_line_type IN ('TAX','DEFERRED_TAX','EDISC_NON_REC_TAX',
                     'UNEDISC_NON_REC_TAX','ADJ_NON_REC_TAX','FINCHRG_NON_REC_TAX')
                AND (NVL(a1.ae_entered_dr,0) = 0 AND NVL(a1.ae_entered_cr,0) = 0 AND
                     NVL(a1.ae_accounted_dr,0) = 0 AND NVL(a1.ae_accounted_cr,0) = 0)))
	  ) al;
     END IF;
   --If the simulation flag is set to Y then continue with the existing logic
   ELSE
   OPEN summarize_lines;

   LOOP
     /*----------------------------------------------------------------------------+
      | Initialise summarize record                                                |
      +----------------------------------------------------------------------------*/
       l_ae_line_rec := l_ae_empty_rec ;

       FETCH summarize_lines
       INTO l_ent_amt       ,
            l_ent_acctd_amt ,
            l_txb_amt       ,
            l_txb_acctd_amt ,
            l_from_ent_amt      ,
            l_from_ent_acctd_amt,
            l_ae_line_rec.ae_line_type,
            l_ae_line_rec.ae_line_type_secondary,
            l_ae_line_rec.ae_source_id,
            l_ae_line_rec.ae_source_table,
            l_ae_line_rec.ae_account,
            l_ae_line_rec.ae_source_id_secondary,
            l_ae_line_rec.ae_source_table_secondary,
            l_ae_line_rec.ae_currency_code,
            l_ae_line_rec.ae_currency_conversion_rate,
            l_ae_line_rec.ae_currency_conversion_type,
            l_ae_line_rec.ae_currency_conversion_date,
            l_ae_line_rec.ae_third_party_id,
            l_ae_line_rec.ae_third_party_sub_id,
            l_ae_line_rec.ae_tax_group_code_id,
            l_ae_line_rec.ae_tax_code_id,
            l_ae_line_rec.ae_location_segment_id,
            l_ae_line_rec.ae_tax_link_id,
            l_ae_line_rec.ae_neg_ind,
            l_ae_line_rec.ae_reversed_source_id,
            l_ae_line_rec.ae_customer_trx_line_id,
            l_ae_line_rec.ae_cust_trx_line_gl_dist_id,
            l_ae_line_rec.ae_ref_line_id,
            l_ae_line_rec.ref_account_class,
            l_ae_line_rec.activity_bucket,
			l_ae_line_rec.ref_dist_ccid,
            l_ae_line_rec.ref_mf_dist_flag;

       --Set cursor not found flag
         IF summarize_lines%NOTFOUND THEN
            EXIT;
         END IF;

       /*------------------------------------------------------------------------------+
        | Build final debits and credits for entered amount. It is important to route  |
        | through the Create Debits and Credits function, rather than directly insert  |
        | into the ar_ae_alloc_rec_gt.                                                   |
        +------------------------------------------------------------------------------*/
         Create_Debits_Credits(l_ent_amt, l_ent_acctd_amt,
                               l_txb_amt, l_txb_acctd_amt,
                               l_from_ent_amt, l_from_ent_acctd_amt,
                               l_ae_line_rec,
                               NULL, 'SUMMARIZE');

         --BUG#3509185 l_summ_ctr := l_summ_ctr + 1;
         l_ae_line_rec.ae_summarize_flag := 'Y';

         Dump_Line_Amts(l_ae_line_rec);

         --BUG#3509185  Insert_Ae_Lines(p_ae_line_tbl => l_ae_line_rec);
         --{BUG#3509185
           Cache_Ae_Lines(p_ae_line_tbl => l_ae_line_rec);
         --}


   END LOOP; --End loop summarize lines

   CLOSE summarize_lines;
   END IF;

   --g_ae_summ_ctr := l_summ_ctr;

   arp_standard.debug( 'ARP_ALLOCATION_PKG.Summarize_Accounting_Lines()-');

EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Summarize_Accounting_Lines:'||SQLERRM);
     RAISE;

END Summarize_Accounting_Lines;


/* ==========================================================================
 | PROCEDURE Summarize_Acct_Lines_Hdr_Level
 |
 | DESCRIPTION
 |    Net out the accounting for earned discounts, unearned discounts and
 |    payments, for adjustment (includes finance charges) multiple layers
 |    of accounting lines will not exist however this routine will be
 |    executed.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    NONE
 *==========================================================================*/
PROCEDURE Summarize_Acct_Lines_Hdr_Level IS

l_ctr1           BINARY_INTEGER;
l_ctr2           BINARY_INTEGER;
l_ent_amt        NUMBER;
l_ent_acctd_amt  NUMBER;
l_txb_amt        NUMBER;
l_txb_acctd_amt  NUMBER;
l_from_ent_amt        NUMBER;
l_from_ent_acctd_amt  NUMBER;
l_ae_line_rec    ar_ae_alloc_rec_gt%ROWTYPE;
l_ae_empty_rec   ar_ae_alloc_rec_gt%ROWTYPE;

CURSOR summarize_lines IS
SELECT /*+ INDEX(a1 AR_AE_ALLOC_REC_GT_N3) */
       SUM(NVL(a1.ae_entered_dr,0)           * -1 + NVL(a1.ae_entered_cr,0)),
       SUM(NVL(a1.ae_accounted_dr,0)         * -1 + NVL(a1.ae_accounted_cr,0)),
       SUM(NVL(a1.ae_taxable_entered_dr,0)   * -1 + NVL(a1.ae_taxable_entered_cr,0)),
       SUM(NVL(a1.ae_taxable_accounted_dr,0) * -1 + NVL(a1.ae_taxable_accounted_cr,0)),
       SUM(NVL(a1.ae_from_amount_dr,0)       * -1 + NVL(a1.ae_from_amount_cr,0)),
       SUM(NVL(a1.ae_from_acctd_amount_dr,0) * -1 + NVL(a1.ae_from_acctd_amount_cr,0)),
       a1.ae_line_type,
       a1.ae_line_type_secondary,
       a1.ae_source_id,
       a1.ae_source_table,
       a1.ae_account,
       a1.ae_source_id_secondary,
       a1.ae_source_table_secondary,
       a1.ae_currency_code,
       a1.ae_currency_conversion_rate,
       a1.ae_currency_conversion_type,
       a1.ae_currency_conversion_date,
       a1.ae_third_party_id,
       a1.ae_third_party_sub_id,
       a1.ae_tax_group_code_id,
       a1.ae_tax_code_id,
       a1.ae_location_segment_id,
       a1.ae_tax_link_id,
       decode(a1.ae_neg_ind,
              -1, decode(Retain_Neg_Ind(a1.rowid),
                         1, a1.ae_neg_ind,
                         ''),
              a1.ae_neg_ind),
       a1.ae_reversed_source_id
FROM ar_ae_alloc_rec_gt a1
WHERE a1.ae_id = g_id
AND a1.ae_summarize_flag = 'N'
AND a1.ae_account_class IS NULL
GROUP BY  a1.ae_line_type,
          a1.ae_line_type_secondary,
          a1.ae_source_id,
          a1.ae_source_table,
          a1.ae_account,
          a1.ae_source_id_secondary,
          a1.ae_source_table_secondary,
          a1.ae_currency_code,
          a1.ae_currency_conversion_rate,
          a1.ae_currency_conversion_type,
          a1.ae_currency_conversion_date,
          a1.ae_third_party_id,
          a1.ae_third_party_sub_id,
          a1.ae_tax_group_code_id,
          a1.ae_tax_code_id,
          a1.ae_location_segment_id,
          a1.ae_tax_link_id,
          decode(a1.ae_neg_ind,
                 -1, decode(Retain_Neg_Ind(a1.rowid),
                            1, a1.ae_neg_ind,
                            ''),
                 a1.ae_neg_ind),
          a1.ae_reversed_source_id
 ORDER BY  decode(a1.ae_line_type,
                'EDISC'              ,-6,
                'ADJ'                ,-6,
                'FINCHRG'            ,-6,
                'UNEDISC'            ,-6,
                a1.ae_tax_link_id),
          decode(a1.ae_line_type,
                 'EDISC_NON_REC_TAX' , -5,
                 'ADJ_NON_REC_TAX'    ,-5,
                 'FINCHRG_NON_REC_TAX',-5,
                 'UNEDISC_NON_REC_TAX',-5,
                 'DEFERRED_TAX',decode(a1.ae_line_type_secondary,
                                       'EDISC'  , -4,
                                       'ADJ'    , -4,
                                       'FINCHRG', -4,
                                       'UNEDISC', -4,
                                       -2),
                 'TAX'         ,decode(a1.ae_line_type_secondary,
                                       'EDISC'  , -3,
                                       'ADJ'    , -3,
                                       'FINCHRG', -3,
                                       'UNEDISC', -3,
                                       -1),
                a1.ae_tax_link_id);

BEGIN

   arp_standard.debug( 'ARP_ALLOCATION_PKG.Summarize_Acct_Lines_Hdr_Level()+');

 /*------------------------------------------------------------------------------+
  |Summarize Accounting entries for revenue and tax to net out accounting entries|
  |because the table g_ae_line_tbl contains accounting for earned discounts,     |
  |unearned discounts and payments, so the requirement for another level of      |
  |summarization for netting                                                     |
  +------------------------------------------------------------------------------*/
   OPEN summarize_lines;

   LOOP
     /*----------------------------------------------------------------------------+
      | Initialise summarize record                                                |
      +----------------------------------------------------------------------------*/
       l_ae_line_rec := l_ae_empty_rec ;

       FETCH summarize_lines
       INTO l_ent_amt       ,
            l_ent_acctd_amt ,
            l_txb_amt       ,
            l_txb_acctd_amt ,
            l_from_ent_amt      ,
            l_from_ent_acctd_amt,
            l_ae_line_rec.ae_line_type,
            l_ae_line_rec.ae_line_type_secondary,
            l_ae_line_rec.ae_source_id,
            l_ae_line_rec.ae_source_table,
            l_ae_line_rec.ae_account,
            l_ae_line_rec.ae_source_id_secondary,
            l_ae_line_rec.ae_source_table_secondary,
            l_ae_line_rec.ae_currency_code,
            l_ae_line_rec.ae_currency_conversion_rate,
            l_ae_line_rec.ae_currency_conversion_type,
            l_ae_line_rec.ae_currency_conversion_date,
            l_ae_line_rec.ae_third_party_id,
            l_ae_line_rec.ae_third_party_sub_id,
            l_ae_line_rec.ae_tax_group_code_id,
            l_ae_line_rec.ae_tax_code_id,
            l_ae_line_rec.ae_location_segment_id,
            l_ae_line_rec.ae_tax_link_id,
            l_ae_line_rec.ae_neg_ind,
            l_ae_line_rec.ae_reversed_source_id;

       --Set cursor not found flag
         IF summarize_lines%NOTFOUND THEN
            EXIT;
         END IF;

       /*------------------------------------------------------------------------------+
        | Build final debits and credits for entered amount. It is important to route  |
        | through the Create Debits and Credits function, rather than directly insert  |
        | into the ar_ae_alloc_rec_gt.                                                   |
        +------------------------------------------------------------------------------*/
         Create_Debits_Credits(l_ent_amt, l_ent_acctd_amt,
                               l_txb_amt, l_txb_acctd_amt,
                               l_from_ent_amt, l_from_ent_acctd_amt,
                               l_ae_line_rec,
                               NULL, 'SUMMARIZE');

         l_ae_line_rec.ae_summarize_flag := 'Y';

         IF nvl(g_simul_app,'N') = 'N' THEN
            Insert_Ae_Lines(p_ae_line_tbl => l_ae_line_rec);

         ELSIF  nvl(g_simul_app,'N') = 'Y' THEN
            Cache_Ae_Lines(p_ae_line_tbl => l_ae_line_rec);
         END IF;

	 IF PG_DEBUG IN ('Y','C') THEN
	   Dump_Line_Amts(l_ae_line_rec);
	 END IF;

   END LOOP; --End loop summarize lines

   CLOSE summarize_lines;

   arp_standard.debug( 'ARP_ALLOCATION_PKG.Summarize_Acct_Lines_Hdr_Level()-');

EXCEPTION
WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Summarize_Acct_Lines_Hdr_Level');
     RAISE;

END Summarize_Acct_Lines_Hdr_Level;


/* ==========================================================================
 | PROCEDURE Get_Tax_Count
 |
 | DESCRIPTION
 |    Gets tax code, location count for a invoice line.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    NONE
 *==========================================================================*/
FUNCTION Get_Tax_Count(p_invoice_line_id IN NUMBER) RETURN NUMBER IS

l_count  NUMBER := 0;

BEGIN

   select sum(a1.tax_count)
   into l_count
   from (select 1                                  tax_count
         from ra_customer_trx_lines a2
         where a2.line_type = 'TAX'
         and   a2.link_to_cust_trx_line_id = p_invoice_line_id
         group by nvl(a2.location_segment_id, a2.vat_tax_id),
                  decode(a2.location_segment_id,
                         '', 'VAT',
                         'LOC')
        ) a1;

   RETURN(l_count);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RAISE;
   WHEN OTHERS THEN
        RAISE;

END Get_Tax_Count;

/* ==========================================================================
 | PROCEDURE Retain_Neg_Ind
 |
 | DESCRIPTION
 |    Ascertains as to whether there is another non zero line into which the
 |    0 amount line (amount, accounted amount, taxable amount, taxable
 |    accounted amount) can get merged
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    NONE
 *==========================================================================*/
FUNCTION Retain_Neg_Ind(p_rowid IN ROWID) RETURN NUMBER IS

l_amount NUMBER := 0;

BEGIN

     SELECT /*+ INDEX(a1 AR_AE_ALLOC_REC_GT_N3) */
            ABS(SUM(NVL(a1.ae_entered_dr,0)           * -1 + NVL(a1.ae_entered_cr,0))) +
            ABS(SUM(NVL(a1.ae_accounted_dr,0)         * -1 + NVL(a1.ae_accounted_cr,0))) +
            ABS(SUM(NVL(a1.ae_taxable_entered_dr,0)   * -1 + NVL(a1.ae_taxable_entered_cr,0))) +
            ABS(SUM(NVL(a1.ae_taxable_accounted_dr,0) * -1 + NVL(a1.ae_taxable_accounted_cr,0)))
     INTO l_amount
     FROM ar_ae_alloc_rec_gt a1,
          ar_ae_alloc_rec_gt a2
     WHERE a1.ae_id = g_id
     AND a1.ae_summarize_flag = 'N'
     AND a1.ae_account_class IS NULL
     AND a2.rowid = p_rowid
     AND a1.rowid <> a2.rowid
     AND nvl(a1.ae_line_type, '-99') = nvl(a2.ae_line_type, '-99')
     AND nvl(a1.ae_line_type_secondary, '-99') = nvl(a2.ae_line_type_secondary, '-99')
     AND nvl(a1.ae_source_id,-9999) = nvl(a2.ae_source_id,-9999)
     AND nvl(a1.ae_source_table,'-99') = nvl(a2.ae_source_table,'-99')
     AND nvl(a1.ae_account,-9999) = nvl(a2.ae_account,-9999)
     AND nvl(a1.ae_source_id_secondary,-9999) = nvl(a2.ae_source_id_secondary,-9999)
     AND nvl(a1.ae_source_table_secondary,'-99') = nvl(a2.ae_source_table_secondary,'-99')
     AND nvl(a1.ae_currency_code, '-99') = nvl(a2.ae_currency_code, '-99')
     AND nvl(a1.ae_currency_conversion_rate, -9999) = nvl(a2.ae_currency_conversion_rate, -9999)
     AND nvl(a1.ae_currency_conversion_type,'-99') = nvl(a2.ae_currency_conversion_type,'-99')
     AND nvl(a1.ae_currency_conversion_date,to_date('01-01-1949','DD-MM-YYYY'))
              = nvl(a2.ae_currency_conversion_date,to_date('01-01-1949','DD-MM-YYYY'))
     AND nvl(a1.ae_third_party_id, -9999) = nvl(a2.ae_third_party_id, -9999)
     AND nvl(a1.ae_third_party_sub_id, -9999) = nvl(a2.ae_third_party_sub_id, -9999)
     AND nvl(a1.ae_tax_group_code_id, -9999) = nvl(a2.ae_tax_group_code_id, -9999)
     AND nvl(a1.ae_tax_code_id, -9999) = nvl(a2.ae_tax_code_id, -9999)
     AND nvl(a1.ae_location_segment_id, -9999) = nvl(a2.ae_location_segment_id, -9999)
     AND nvl(a1.ae_tax_link_id, -9999) = nvl(a2.ae_tax_link_id, -9999)
     AND nvl(a1.ae_reversed_source_id,-9999) = nvl(a2.ae_reversed_source_id,-9999);

     IF l_amount <> 0 THEN
        RETURN(0);
     ELSE
        RETURN(1);
     END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     RETURN(1);
WHEN OTHERS THEN
     RAISE;

END Retain_Neg_Ind;

/* ==========================================================================
 | PROCEDURE Assign_Elements
 |
 | DESCRIPTION
 |    Assign revenue or tax lines built to global table which will eventually
 |    be summarized
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    NONE
 | Hidtory
 |   21-NOV-2003   Herve Yu  from_amount_dr      , from_amount_cr,
 |                           from_acctd_amount_dr, from_acctd_amount_cr
 *==========================================================================*/
PROCEDURE Assign_Elements(p_ae_line_rec           IN ar_ae_alloc_rec_gt%ROWTYPE) IS

BEGIN
   IF PG_DEBUG IN ('Y','C') THEN
    arp_standard.debug( 'ARP_ALLOCATION_PKG.Assign_Elements()+');
   END IF;
   /*------------------------------------------------------+
    | Store AE Line elements in AE Lines temp table        |
    +------------------------------------------------------*/
    g_ae_ctr := g_ae_ctr +1;

    insert into ar_ae_alloc_rec_gt
    ( ae_id,
      ae_account_class            ,
      ae_customer_trx_id          ,
      ae_customer_trx_line_id     ,
      ae_link_to_cust_trx_line_id ,
      ae_tax_type                 ,
      ae_code_combination_id      ,
      ae_collected_tax_ccid       ,
      ae_line_amount              ,
      ae_amount                   ,
      ae_acctd_amount             ,
      ae_taxable_amount           ,
      ae_taxable_acctd_amount     ,
      ae_adj_ccid                 ,
      ae_edisc_ccid               ,
      ae_unedisc_ccid             ,
      ae_finchrg_ccid             ,
      ae_adj_non_rec_tax_ccid     ,
      ae_edisc_non_rec_tax_ccid   ,
      ae_unedisc_non_rec_tax_ccid ,
      ae_finchrg_non_rec_tax_ccid ,
      ae_override_ccid1           ,
      ae_override_ccid2           ,
      ae_tax_link_id              ,
      ae_tax_link_id_ed_adj       ,
      ae_tax_link_id_uned         ,
      ae_tax_link_id_act          ,
      ae_pro_amt                  ,
      ae_pro_acctd_amt            ,
      ae_pro_chrg_amt             ,
      ae_pro_chrg_acctd_amt       ,
      ae_pro_taxable_amt          ,
      ae_pro_taxable_acctd_amt    ,
      ae_counted_flag             ,
      ae_autotax                  ,
      ae_sum_alloc_amt            ,
      ae_sum_alloc_acctd_amt      ,
      ae_tax_line_count           ,
      ae_line_type                   ,
      ae_line_type_secondary         ,
      ae_source_id                   ,
      ae_source_table                ,
      ae_account                     ,
      ae_entered_dr                  ,
      ae_entered_cr                  ,
      ae_accounted_dr                ,
      ae_accounted_cr                ,
      ae_source_id_secondary         ,
      ae_source_table_secondary      ,
      ae_currency_code               ,
      ae_currency_conversion_rate    ,
      ae_currency_conversion_type    ,
      ae_currency_conversion_date    ,
      ae_third_party_id              ,
      ae_third_party_sub_id          ,
      ae_tax_group_code_id           ,
      ae_tax_code_id                 ,
      ae_location_segment_id         ,
      ae_taxable_entered_dr          ,
      ae_taxable_entered_cr          ,
      ae_taxable_accounted_dr        ,
      ae_taxable_accounted_cr        ,
      ae_reversed_source_id          ,
      ae_neg_ind                     ,
      ae_summarize_flag              ,
      ae_cust_trx_line_gl_dist_id    ,
      ae_ref_line_id                 ,
      ae_from_amount_dr              ,
      ae_from_amount_cr              ,
      ae_from_acctd_amount_dr        ,
      ae_from_acctd_amount_cr        ,
      ref_account_class,
      activity_bucket,
      ref_dist_ccid,
      ref_mf_dist_flag
      )
VALUES
    ( g_id,
      p_ae_line_rec.ae_account_class            ,
      p_ae_line_rec.ae_customer_trx_id          ,
      p_ae_line_rec.ae_customer_trx_line_id     ,
      p_ae_line_rec.ae_link_to_cust_trx_line_id ,
      p_ae_line_rec.ae_tax_type                 ,
      p_ae_line_rec.ae_code_combination_id      ,
      p_ae_line_rec.ae_collected_tax_ccid       ,
      p_ae_line_rec.ae_line_amount              ,
      p_ae_line_rec.ae_amount                   ,
      p_ae_line_rec.ae_acctd_amount             ,
      p_ae_line_rec.ae_taxable_amount           ,
      p_ae_line_rec.ae_taxable_acctd_amount     ,
      p_ae_line_rec.ae_adj_ccid                 ,
      p_ae_line_rec.ae_edisc_ccid               ,
      p_ae_line_rec.ae_unedisc_ccid             ,
      p_ae_line_rec.ae_finchrg_ccid             ,
      p_ae_line_rec.ae_adj_non_rec_tax_ccid     ,
      p_ae_line_rec.ae_edisc_non_rec_tax_ccid   ,
      p_ae_line_rec.ae_unedisc_non_rec_tax_ccid ,
      p_ae_line_rec.ae_finchrg_non_rec_tax_ccid ,
      p_ae_line_rec.ae_override_ccid1           ,
      p_ae_line_rec.ae_override_ccid2           ,
      p_ae_line_rec.ae_tax_link_id              ,
      p_ae_line_rec.ae_tax_link_id_ed_adj       ,
      p_ae_line_rec.ae_tax_link_id_uned         ,
      p_ae_line_rec.ae_tax_link_id_act          ,
      p_ae_line_rec.ae_pro_amt                  ,
      p_ae_line_rec.ae_pro_acctd_amt            ,
      p_ae_line_rec.ae_pro_chrg_amt             ,
      p_ae_line_rec.ae_pro_chrg_acctd_amt       ,
      p_ae_line_rec.ae_pro_taxable_amt          ,
      p_ae_line_rec.ae_pro_taxable_acctd_amt    ,
      p_ae_line_rec.ae_counted_flag             ,
      p_ae_line_rec.ae_autotax                  ,
      p_ae_line_rec.ae_sum_alloc_amt            ,
      p_ae_line_rec.ae_sum_alloc_acctd_amt      ,
      p_ae_line_rec.ae_tax_line_count           ,
      p_ae_line_rec.ae_line_type                   ,
      p_ae_line_rec.ae_line_type_secondary         ,
      p_ae_line_rec.ae_source_id                   ,
      p_ae_line_rec.ae_source_table                ,
      p_ae_line_rec.ae_account                     ,
      p_ae_line_rec.ae_entered_dr                  ,
      p_ae_line_rec.ae_entered_cr                  ,
      p_ae_line_rec.ae_accounted_dr                ,
      p_ae_line_rec.ae_accounted_cr                ,
      p_ae_line_rec.ae_source_id_secondary         ,
      p_ae_line_rec.ae_source_table_secondary      ,
      p_ae_line_rec.ae_currency_code               ,
      p_ae_line_rec.ae_currency_conversion_rate    ,
      p_ae_line_rec.ae_currency_conversion_type    ,
      p_ae_line_rec.ae_currency_conversion_date    ,
      p_ae_line_rec.ae_third_party_id              ,
      p_ae_line_rec.ae_third_party_sub_id          ,
      p_ae_line_rec.ae_tax_group_code_id           ,
      p_ae_line_rec.ae_tax_code_id                 ,
      p_ae_line_rec.ae_location_segment_id         ,
      p_ae_line_rec.ae_taxable_entered_dr          ,
      p_ae_line_rec.ae_taxable_entered_cr          ,
      p_ae_line_rec.ae_taxable_accounted_dr        ,
      p_ae_line_rec.ae_taxable_accounted_cr        ,
      p_ae_line_rec.ae_reversed_source_id          ,
      p_ae_line_rec.ae_neg_ind                     ,
      NVL(p_ae_line_rec.ae_summarize_flag,'N')     ,
      p_ae_line_rec.ae_cust_trx_line_gl_dist_id    ,
      p_ae_line_rec.ae_ref_line_id                 ,
      p_ae_line_rec.ae_from_amount_dr              ,
      p_ae_line_rec.ae_from_amount_cr              ,
      p_ae_line_rec.ae_from_acctd_amount_dr        ,
      p_ae_line_rec.ae_from_acctd_amount_cr        ,
      p_ae_line_rec.ref_account_class,
      p_ae_line_rec.activity_bucket,
      p_ae_line_rec.ref_dist_ccid,
      p_ae_line_rec.ref_mf_dist_flag
      );

    Dump_Line_Amts(p_ae_line_rec);

   IF PG_DEBUG IN ('Y','C') THEN
    arp_standard.debug( 'ARP_ALLOCATION_PKG.Assign_Elements()-');
   END IF;
EXCEPTION
  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Assign_Elements');
     RAISE;

END Assign_Elements;

/*========================================================================
 | PRIVATE PROCEDURE Insert_Ae_Lines
 |
 | DESCRIPTION
 |      Inserts into AR_DISTRIBUTIONS accounting lines
 |      ----------------------------------------------
 |      Calls the table handler for AR_DISTRIBUTIONS to insert accounting
 |      for a given document into the underlying table.
 |
 | PARAMETERS
 |      p_ae_line_tbl   IN      Accounting lines table
 | History
 |   24-NOV-2003  Herve Yu     Distributions in the receipt currency
 *=======================================================================*/
PROCEDURE Insert_Ae_Lines(p_ae_line_tbl IN ar_ae_alloc_rec_gt%ROWTYPE) IS

  l_ae_line_rec         ar_distributions%ROWTYPE;
  l_ae_line_rec_empty   ar_distributions%ROWTYPE;
  l_dummy               ar_distributions.line_id%TYPE;

BEGIN

  arp_standard.debug( 'ARP_ALLOCATION_PKG.Insert_Ae_Lines()+');

-- Initialize
   l_ae_line_rec := l_ae_line_rec_empty;

-- Assign AE Line elements
   l_ae_line_rec.source_type              :=  p_ae_line_tbl.ae_line_type;
   l_ae_line_rec.source_type_secondary    :=  p_ae_line_tbl.ae_line_type_secondary;
   l_ae_line_rec.source_id                :=  p_ae_line_tbl.ae_source_id;
   l_ae_line_rec.source_table             :=  p_ae_line_tbl.ae_source_table;
   l_ae_line_rec.code_combination_id      :=  p_ae_line_tbl.ae_account;
   l_ae_line_rec.amount_dr                :=  p_ae_line_tbl.ae_entered_dr;
   l_ae_line_rec.amount_cr                :=  p_ae_line_tbl.ae_entered_cr;
   l_ae_line_rec.acctd_amount_dr          :=  p_ae_line_tbl.ae_accounted_dr;
   l_ae_line_rec.acctd_amount_cr          :=  p_ae_line_tbl.ae_accounted_cr;
   l_ae_line_rec.from_amount_dr           :=  p_ae_line_tbl.ae_from_amount_dr;
   l_ae_line_rec.from_amount_cr           :=  p_ae_line_tbl.ae_from_amount_cr;
   l_ae_line_rec.from_acctd_amount_dr     :=  p_ae_line_tbl.ae_from_acctd_amount_dr;
   l_ae_line_rec.from_acctd_amount_cr     :=  p_ae_line_tbl.ae_from_acctd_amount_cr;
   l_ae_line_rec.source_id_secondary      :=  p_ae_line_tbl.ae_source_id_secondary;
   l_ae_line_rec.source_table_secondary   :=  p_ae_line_tbl.ae_source_table_secondary;
   l_ae_line_rec.currency_code            :=  p_ae_line_tbl.ae_currency_code;
   l_ae_line_rec.currency_conversion_rate :=  p_ae_line_tbl.ae_currency_conversion_rate;
   l_ae_line_rec.currency_conversion_type :=  p_ae_line_tbl.ae_currency_conversion_type;
   l_ae_line_rec.currency_conversion_date :=  p_ae_line_tbl.ae_currency_conversion_date;
   l_ae_line_rec.third_party_id           :=  p_ae_line_tbl.ae_third_party_id;
   l_ae_line_rec.third_party_sub_id       :=  p_ae_line_tbl.ae_third_party_sub_id;
   l_ae_line_rec.tax_group_code_id        :=  p_ae_line_tbl.ae_tax_group_code_id;
   l_ae_line_rec.tax_code_id              :=  p_ae_line_tbl.ae_tax_code_id;
   l_ae_line_rec.location_segment_id      :=  p_ae_line_tbl.ae_location_segment_id;
   l_ae_line_rec.taxable_entered_dr       :=  p_ae_line_tbl.ae_taxable_entered_dr;
   l_ae_line_rec.taxable_entered_cr       :=  p_ae_line_tbl.ae_taxable_entered_cr;
   l_ae_line_rec.taxable_accounted_dr     :=  p_ae_line_tbl.ae_taxable_accounted_dr;
   l_ae_line_rec.taxable_accounted_cr     :=  p_ae_line_tbl.ae_taxable_accounted_cr;
   l_ae_line_rec.tax_link_id              :=  p_ae_line_tbl.ae_tax_link_id;
   l_ae_line_rec.reversed_source_id       :=  p_ae_line_tbl.ae_reversed_source_id;
   l_ae_line_rec.ref_account_class                :=  p_ae_line_tbl.ref_account_class;
   l_ae_line_rec.activity_bucket                   :=  p_ae_line_tbl.activity_bucket;
   l_ae_line_rec.ref_customer_trx_line_id :=  p_ae_line_tbl.ae_customer_trx_line_id;
   l_ae_line_rec.ref_cust_trx_line_gl_dist_id :=  p_ae_line_tbl.ae_cust_trx_line_gl_dist_id;
   l_ae_line_rec.ref_dist_ccid    :=  p_ae_line_tbl.ref_dist_ccid;
   l_ae_line_rec.ref_mf_dist_flag :=  p_ae_line_tbl.ref_mf_dist_flag;

   l_ae_line_rec.ref_line_id              :=  p_ae_line_tbl.ae_ref_line_id;

   Dump_Dist_Amts(l_ae_line_rec);

--Insert into ar_distributions
   IF (NVL(g_ae_sys_rec.sob_type,'P') = 'P') THEN

       arp_distributions_pkg.insert_p(l_ae_line_rec, l_dummy);
--{BUG#4301323
--   ELSE
        /* need to insert records into the MRC table.  Calling new
           mrc engine */

               -- before we call the ar_mrc_engine, we need the line_id of
        -- the primary row.   If the Source type is EXCH_GAIN, EXCH_LOSS
        -- or CURR_ROUND, use a new line_id from the sequence.
--  arp_standard.debug('source type = ' || l_ae_line_rec.source_type);
--        if (l_ae_line_rec.source_type = 'EXCH_GAIN' or
--           l_ae_line_rec.source_type = 'EXCH_LOSS' or
--           l_ae_line_rec.source_type = 'CURR_ROUND' )  THEN
--           select  ar_distributions_s.nextval
--             into l_ae_line_rec.line_id
--           from dual;
--        ELSE
--         BEGIN
--           select line_id
--             into l_ae_line_rec.line_id
--             from ar_distributions
--            where source_id = l_ae_line_rec.source_id
--              and source_table = l_ae_line_rec.source_table
--              and source_type = l_ae_line_rec.source_type
--              and (source_type_secondary =
--                           l_ae_line_rec.source_type_secondary
--                   OR source_type_secondary IS NULL)
--              and ( amount_dr = l_ae_line_rec.amount_dr OR
--                    amount_dr IS NULL)
--              and ( amount_cr = l_ae_line_rec.amount_cr OR
--                    amount_cr IS NULL)
--              and code_combination_id = l_ae_line_rec.code_combination_id;
--           EXCEPTION
--            WHEN OTHERS THEN
--             arp_standard.debug('Can not determine Line id so created new one');
--             select  ar_distributions_s.nextval
--               into l_ae_line_rec.line_id
--               from dual;
--           END;
--           arp_standard.debug('line id = ' || to_char(l_ae_line_rec.line_id));
--        END IF;
--        arp_standard.debug('before calling mrc_acct_main');
--        arp_mrc_acct_main.insert_mrc_dis_data
--                     (l_ae_line_rec,
--                      arp_acct_main.ae_sys_rec.set_of_books_id);
--}
   END IF;
   arp_standard.debug( 'ARP_ACCT_MAIN.Insert_Ae_Lines()-');

END Insert_Ae_Lines;


/*========================================================================
 | PRIVATE PROCEDURE Cache_Ae_Lines
 |
 | DESCRIPTION
 |      Inserts into AR_DISTRIBUTIONS accounting lines
 |      ----------------------------------------------
 |      Calls the table handler for AR_DISTRIBUTIONS to insert accounting
 |      for a given document into the underlying table.
 |
 | PARAMETERS
 |      p_ae_line_tbl   IN      Accounting lines table
 |
 *=======================================================================*/
PROCEDURE Cache_Ae_Lines(p_ae_line_tbl IN ar_ae_alloc_rec_gt%ROWTYPE) IS

BEGIN


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Cache_Ae_Lines()+');
  END IF;

  g_ae_summ_ctr := g_ae_summ_ctr + 1;

  g_ae_summarize_tbl(g_ae_summ_ctr).ae_line_type               :=  p_ae_line_tbl.ae_line_type;
  g_ae_summarize_tbl(g_ae_summ_ctr).source_id                  :=  p_ae_line_tbl.ae_source_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).source_table               :=  p_ae_line_tbl.ae_source_table;
  g_ae_summarize_tbl(g_ae_summ_ctr).account                    :=  p_ae_line_tbl.ae_account;
  g_ae_summarize_tbl(g_ae_summ_ctr).entered_dr                 :=  p_ae_line_tbl.ae_entered_dr;
  g_ae_summarize_tbl(g_ae_summ_ctr).entered_cr                 :=  p_ae_line_tbl.ae_entered_cr;
  g_ae_summarize_tbl(g_ae_summ_ctr).accounted_dr               :=  p_ae_line_tbl.ae_accounted_dr;
  g_ae_summarize_tbl(g_ae_summ_ctr).accounted_cr               :=  p_ae_line_tbl.ae_accounted_cr;
  g_ae_summarize_tbl(g_ae_summ_ctr).ae_line_type_secondary     :=  p_ae_line_tbl.ae_line_type_secondary;
  g_ae_summarize_tbl(g_ae_summ_ctr).source_id_secondary        :=  p_ae_line_tbl.ae_source_id_secondary;
  g_ae_summarize_tbl(g_ae_summ_ctr).source_table_secondary     :=  p_ae_line_tbl.ae_source_table_secondary;
  g_ae_summarize_tbl(g_ae_summ_ctr).currency_code              :=  p_ae_line_tbl.ae_currency_code;
  g_ae_summarize_tbl(g_ae_summ_ctr).currency_conversion_rate   :=  p_ae_line_tbl.ae_currency_conversion_rate;
  g_ae_summarize_tbl(g_ae_summ_ctr).currency_conversion_type   :=  p_ae_line_tbl.ae_currency_conversion_type;
  g_ae_summarize_tbl(g_ae_summ_ctr).currency_conversion_date   :=  p_ae_line_tbl.ae_currency_conversion_date;
  g_ae_summarize_tbl(g_ae_summ_ctr).third_party_id             :=  p_ae_line_tbl.ae_third_party_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).third_party_sub_id         :=  p_ae_line_tbl.ae_third_party_sub_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).tax_group_code_id          :=  p_ae_line_tbl.ae_tax_group_code_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).tax_code_id                :=  p_ae_line_tbl.ae_tax_code_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).location_segment_id        :=  p_ae_line_tbl.ae_location_segment_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).taxable_entered_dr         :=  p_ae_line_tbl.ae_taxable_entered_dr;
  g_ae_summarize_tbl(g_ae_summ_ctr).taxable_entered_cr         :=  p_ae_line_tbl.ae_taxable_entered_cr;
  g_ae_summarize_tbl(g_ae_summ_ctr).taxable_accounted_dr       :=  p_ae_line_tbl.ae_taxable_accounted_dr;
  g_ae_summarize_tbl(g_ae_summ_ctr).taxable_accounted_cr       :=  p_ae_line_tbl.ae_taxable_accounted_cr;
  g_ae_summarize_tbl(g_ae_summ_ctr).tax_link_id                :=  p_ae_line_tbl.ae_tax_link_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).reversed_source_id         :=  p_ae_line_tbl.ae_reversed_source_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).ref_customer_trx_line_id   :=  p_ae_line_tbl.ae_customer_trx_line_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).ref_cust_trx_line_gl_dist_id:=  p_ae_line_tbl.ae_cust_trx_line_gl_dist_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).ref_line_id                :=  p_ae_line_tbl.ae_ref_line_id;
  g_ae_summarize_tbl(g_ae_summ_ctr).activity_bucket            :=  p_ae_line_tbl.activity_bucket;
  g_ae_summarize_tbl(g_ae_summ_ctr).ref_account_class          :=  p_ae_line_tbl.ref_account_class;
  g_ae_summarize_tbl(g_ae_summ_ctr).ref_dist_ccid              :=  p_ae_line_tbl.ref_dist_ccid;
  g_ae_summarize_tbl(g_ae_summ_ctr).ref_mf_dist_flag           :=  p_ae_line_tbl.ref_mf_dist_flag;
  g_ae_summarize_tbl(g_ae_summ_ctr).from_amount_dr             :=  p_ae_line_tbl.ae_from_amount_dr;
  g_ae_summarize_tbl(g_ae_summ_ctr).from_amount_cr             :=  p_ae_line_tbl.ae_from_amount_cr;
  g_ae_summarize_tbl(g_ae_summ_ctr).from_acctd_amount_dr       :=  p_ae_line_tbl.ae_from_acctd_amount_dr;
  g_ae_summarize_tbl(g_ae_summ_ctr).from_acctd_amount_cr       :=  p_ae_line_tbl.ae_from_acctd_amount_cr;



  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ALLOCATION_PKG.Cache_Ae_Lines()-');
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'OTHERS EXCEPTION : ARP_ALLOCATION_PKG.Cache_Ae_Lines()');
  END IF;

END Cache_Ae_Lines;

/*========================================================================
 | PRIVATE FUNCTION  Set_Adj_CCID
 |
 | DESCRIPTION
 |      Sets the global Variable adj_code_combination_id to NULL
 |      Gets the global Variable adj_code_combination_id
 |      Used by library ARXTWADJ.pld
 |
 | PARAMETERS
 |      p_action   IN VARCHAR2
 *=======================================================================*/
FUNCTION Set_Adj_CCID(p_action IN VARCHAR2) RETURN NUMBER IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ACCT_MAIN.Set_Adj_CCID()+');
   END IF;

   IF p_action = 'S' THEN --Set
      adj_code_combination_id := '';
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Set_Adj_CCID: ' ||  'adj_code_combination_id ' || adj_code_combination_id);
   END IF;

   RETURN(adj_code_combination_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ACCT_MAIN.Set_Adj_CCID()-');
   END IF;

EXCEPTION
WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'Exception : ARP_ACCT_MAIN.Set_Adj_CCID');
    END IF;
    RAISE;

END Set_Adj_CCID;


/* ==========================================================================
 | PROCEDURE Dump_Alloc_Rev_Tax
 |
 | DESCRIPTION
 |    Dumps data stored in the Allocation Revenue or Tax table
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_type                 IN      Indicates Rev or Tax
 |    p_alloc_rec            IN      Allocation details Record
 *==========================================================================*/
PROCEDURE Dump_Alloc_Rev_Tax(p_type IN VARCHAR2, p_alloc_rec IN ar_ae_alloc_rec_gt%ROWTYPE) IS

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Dump_Alloc_Rev_Tax()+');
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_id = ' ||
                                     p_alloc_rec.ae_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_account_class = ' ||
                                     p_alloc_rec.ae_account_class);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_customer_trx_id = ' ||
                                     p_alloc_rec.ae_customer_trx_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_customer_trx_line_id = ' ||
                                     p_alloc_rec.ae_customer_trx_line_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_link_to_cust_trx_line_id= ' ||
                                     p_alloc_rec.ae_link_to_cust_trx_line_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_tax_type= ' ||
                                     p_alloc_rec.ae_tax_type);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_code_combination_id= ' ||
                                     p_alloc_rec.ae_code_combination_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_collected_tax_ccid= ' ||
                                     p_alloc_rec.ae_collected_tax_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_line_amount= ' ||
                                     p_alloc_rec.ae_line_amount);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_amount= ' ||
                                     p_alloc_rec.ae_amount);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_acctd_amount= ' ||
                                     p_alloc_rec.ae_acctd_amount);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_tax_group_code_id= ' ||
                                     p_alloc_rec.ae_tax_group_code_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_tax_id= ' ||
                                     p_alloc_rec.ae_tax_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_taxable_amount= ' ||
                                     p_alloc_rec.ae_taxable_amount);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_taxable_acctd_amount= ' ||
                                     p_alloc_rec.ae_taxable_acctd_amount);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_adj_ccid= ' ||
                                     p_alloc_rec.ae_adj_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_edisc_ccid= ' ||
                                     p_alloc_rec.ae_edisc_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_unedisc_ccid= ' ||
                                     p_alloc_rec.ae_unedisc_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_finchrg_ccid= ' ||
                                     p_alloc_rec.ae_finchrg_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_adj_non_rec_tax_ccid= ' ||
                                     p_alloc_rec.ae_adj_non_rec_tax_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_edisc_non_rec_tax_ccid= ' ||
                                     p_alloc_rec.ae_edisc_non_rec_tax_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_unedisc_non_rec_tax_ccid= ' ||
                                     p_alloc_rec.ae_unedisc_non_rec_tax_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_finchrg_non_rec_tax_ccid= ' ||
                                     p_alloc_rec.ae_finchrg_non_rec_tax_ccid);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_override_ccid1= ' ||
                                     p_alloc_rec.ae_override_ccid1);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_override_ccid2= ' ||
                                     p_alloc_rec.ae_override_ccid2);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_tax_link_id= ' ||
                                     p_alloc_rec.ae_tax_link_id);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_tax_link_id_ed_adj= ' ||
                                     p_alloc_rec.ae_tax_link_id_ed_adj);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_tax_link_id_uned= ' ||
                                     p_alloc_rec.ae_tax_link_id_uned);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_tax_link_id_act= ' ||
                                     p_alloc_rec.ae_tax_link_id_act);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_pro_amt= ' ||
                                     p_alloc_rec.ae_pro_amt);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_pro_acctd_amt= ' ||
                                     p_alloc_rec.ae_pro_acctd_amt);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_pro_taxable_amt= ' ||
                                     p_alloc_rec.ae_pro_taxable_amt);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_pro_taxable_acctd_amt= ' ||
                                     p_alloc_rec.ae_pro_taxable_acctd_amt);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_pro_def_tax_amt= ' ||
                                     p_alloc_rec.ae_pro_def_tax_amt);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_pro_def_tax_acctd_amt= ' ||
                                     p_alloc_rec.ae_pro_def_tax_acctd_amt);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_summarize_flag= ' ||
                                     p_alloc_rec.ae_summarize_flag);
      arp_standard.debug('Dump_Alloc_Rev_Tax: ' || 'g_ae_alloc_'||p_type||'_tbl.ae_counted_flag  = ' ||
                                     p_alloc_rec.ae_counted_flag);
      arp_standard.debug( 'ARP_ALLOCATION_PKG.Dump_Alloc_Rev_Tax()-');
   END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Dump_Alloc_Rev_Tax');
     END IF;
     RAISE;

END Dump_Alloc_Rev_Tax;

/* ==========================================================================
 | PROCEDURE Dump_Init_Amts
 |
 | DESCRIPTION
 |    Dumps data derived by the Init_Amts routine for Revenue and Tax
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_type_acct            IN      Type of accounting
 |    p_app_rec              IN      Receivable application record
 |    p_adj_rec              IN      Adjustment Record
 *==========================================================================*/
PROCEDURE Dump_Init_Amts(p_type_acct    IN VARCHAR2                          ,
                         p_app_rec      IN ar_receivable_applications%ROWTYPE,
                         p_adj_rec      IN ar_adjustments%ROWTYPE             ) IS
BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_ALLOCATION_PKG.Dump_Init_Amts()+');
      arp_standard.debug('Dump_Init_Amts: ' || 'p_type_acct = ' || p_type_acct);
   END IF;

   IF p_type_acct = 'ED_ADJ' AND g_ae_doc_rec.source_table = 'RA' THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.earned_discount_taken       = ' || p_app_rec.earned_discount_taken);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.acctd_earned_discount_taken = ' || p_app_rec.acctd_earned_discount_taken);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.line_ediscounted            = ' || p_app_rec.line_ediscounted);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.tax_ediscounted             = ' || p_app_rec.tax_ediscounted);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.freight_ediscounted         = ' || p_app_rec.freight_ediscounted);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.charges_ediscounted         = ' || p_app_rec.charges_ediscounted);
      END IF;

   ELSIF p_type_acct = 'PAY' AND g_ae_doc_rec.source_table = 'RA' THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.amount_applied              = ' || p_app_rec.amount_applied);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.acctd_amount_applied_to     = ' || p_app_rec.acctd_amount_applied_to);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.line_applied                = ' || p_app_rec.line_applied);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.tax_applied                 = ' || p_app_rec.tax_applied);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.freight_applied             = ' || p_app_rec.freight_applied);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.receivables_charges_applied = ' || p_app_rec.receivables_charges_applied);
      END IF;

   ELSIF p_type_acct = 'ED_ADJ' AND g_ae_doc_rec.source_table = 'ADJ' THEN

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Dump_Init_Amts: ' || 'p_adj_rec.amount                   = ' || p_adj_rec.amount);
            arp_standard.debug('Dump_Init_Amts: ' || 'p_adj_rec.acctd_amount             = ' || p_adj_rec.acctd_amount);
            arp_standard.debug('Dump_Init_Amts: ' || 'p_adj_rec.line_adjusted            = ' || p_adj_rec.line_adjusted);
            arp_standard.debug('Dump_Init_Amts: ' || 'p_adj_rec.tax_adjusted             = ' || p_adj_rec.tax_adjusted);
            arp_standard.debug('Dump_Init_Amts: ' || 'p_adj_rec.freight_adjusted         = ' || p_adj_rec.freight_adjusted);
            arp_standard.debug('Dump_Init_Amts: ' || 'p_adj_rec.receivables_charges_adjusted = '
                                                           || p_adj_rec.receivables_charges_adjusted);
         END IF;

   ELSIF p_type_acct = 'UNED' AND g_ae_doc_rec.source_table = 'RA' THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.unearned_discount_taken       = ' || p_app_rec.unearned_discount_taken);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.acctd_unearned_discount_taken = ' || p_app_rec.acctd_unearned_discount_taken);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.line_uediscounted             = ' || p_app_rec.line_uediscounted);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.tax_uediscounted              = ' || p_app_rec.tax_uediscounted);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.freight_uediscounted          = ' || p_app_rec.freight_uediscounted);
         arp_standard.debug('Dump_Init_Amts: ' || 'p_app_rec.charges_uediscounted          = ' || p_app_rec.charges_uediscounted);
      END IF;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.line_amt_alloc            = '||g_ae_rule_rec.line_amt_alloc);
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.line_acctd_amt_alloc      = '||g_ae_rule_rec.line_acctd_amt_alloc);
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.tax_amt_alloc             = '||g_ae_rule_rec.tax_amt_alloc);
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.tax_acctd_amt_alloc       = '||g_ae_rule_rec.tax_acctd_amt_alloc);
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.freight_amt_alloc         = '||g_ae_rule_rec.freight_amt_alloc);
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.freight_acctd_amt_alloc   = '||g_ae_rule_rec.freight_acctd_amt_alloc);
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.charges_amt_alloc         = '||g_ae_rule_rec.charges_amt_alloc);
      arp_standard.debug('Dump_Init_Amts: ' || 'g_ae_rule_rec.charges_acctd_amt_alloc   = '||g_ae_rule_rec.charges_acctd_amt_alloc);
      arp_standard.debug('ARP_ALLOCATION_PKG.Dump_Init_Amts()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Dump_Init_Amts');
     END IF;
     RAISE;

END Dump_Init_Amts;

/* ==========================================================================
 | PROCEDURE Dump_Line_Amts
 |
 | DESCRIPTION
 |    Dumps data accounting line data
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_ae_line_rec          IN      Accounting lines record
 *==========================================================================*/
PROCEDURE Dump_Line_Amts(p_ae_line_rec  IN ar_ae_alloc_rec_gt%ROWTYPE) IS

BEGIN

       arp_standard.debug('ARP_ALLOCATION_PKG.Dump_Line_Amts()+');
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_id = ' || p_ae_line_rec.ae_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_line_type = ' || p_ae_line_rec.ae_line_type);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_line_type_secondary = ' || p_ae_line_rec.ae_line_type_secondary);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_source_id    = ' || p_ae_line_rec.ae_source_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_source_table = ' || p_ae_line_rec.ae_source_table);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_account      = ' || p_ae_line_rec.ae_account);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_entered_dr   = ' || p_ae_line_rec.ae_entered_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_entered_cr   = ' || p_ae_line_rec.ae_entered_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_accounted_dr = ' || p_ae_line_rec.ae_accounted_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_accounted_cr = ' || p_ae_line_rec.ae_accounted_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_source_id_secondary = ' || p_ae_line_rec.ae_source_id_secondary);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_source_table_secondary = ' || p_ae_line_rec.ae_source_table_secondary);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_currency_code = ' || p_ae_line_rec.ae_currency_code);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_currency_conversion_rate = ' || p_ae_line_rec.ae_currency_conversion_rate);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_currency_conversion_type = ' || p_ae_line_rec.ae_currency_conversion_type);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_currency_conversion_date = ' || p_ae_line_rec.ae_currency_conversion_date);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_third_party_id           = ' || p_ae_line_rec.ae_third_party_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_third_party_sub_id       = ' || p_ae_line_rec.ae_third_party_sub_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_tax_group_code_id        = ' || p_ae_line_rec.ae_tax_group_code_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_tax_code_id              = ' || p_ae_line_rec.ae_tax_code_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_location_segment_id      = ' || p_ae_line_rec.ae_location_segment_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_taxable_entered_dr       = ' || p_ae_line_rec.ae_taxable_entered_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_taxable_entered_cr       = ' || p_ae_line_rec.ae_taxable_entered_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_taxable_accounted_dr     = ' || p_ae_line_rec.ae_taxable_accounted_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_taxable_accounted_cr     = ' || p_ae_line_rec.ae_taxable_accounted_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_tax_link_id              = ' || p_ae_line_rec.ae_tax_link_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_reversed_source_id       = ' || p_ae_line_rec.ae_reversed_source_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_summarize_flag           = ' || p_ae_line_rec.ae_summarize_flag);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_neg_ind               = ' || p_ae_line_rec.ae_neg_ind);

       arp_standard.debug('Dump_Line_Amts: ' || 'activity_bucket                   = ' || p_ae_line_rec.activity_bucket);
       arp_standard.debug('Dump_Line_Amts: ' || 'ref_account_class                = ' || p_ae_line_rec.ref_account_class);
       arp_standard.debug('Dump_Line_Amts: ' || 'ref_customer_trx_line_id = ' || p_ae_line_rec.ae_customer_trx_line_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ref_cust_trx_line_gl_dist_id= ' || p_ae_line_rec.ae_cust_trx_line_gl_dist_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ref_line_id              = ' || p_ae_line_rec.ae_ref_line_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'ref_dist_ccid            = ' || p_ae_line_rec.ref_dist_ccid);
       arp_standard.debug('Dump_Line_Amts: ' || 'ref_mf_dist_flag         = ' || p_ae_line_rec.ref_mf_dist_flag);

      arp_standard.debug('ARP_ALLOCATION_PKG.Dump_Line_Amts()-');

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Dump_Line_Amts');
     END IF;
     RAISE;

END Dump_Line_Amts;

/* ==========================================================================
 | PROCEDURE Dump_Dist_Amts
 |
 | DESCRIPTION
 |    Dumps data accounting line data
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_ae_line_rec          IN      Accounting lines record
 *==========================================================================*/
PROCEDURE Dump_Dist_Amts(p_ae_line_rec  IN ar_distributions%ROWTYPE) IS
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_ALLOCATION_PKG.Dump_Dist_Amts()+');
       arp_standard.debug('Dump_Dist_Amts: ' || 'ae_id                    = ' || g_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'source_type              = ' || p_ae_line_rec.source_type);
       arp_standard.debug('Dump_Dist_Amts: ' || 'source_type_secondary    = ' || p_ae_line_rec.source_type_secondary);
       arp_standard.debug('Dump_Dist_Amts: ' || 'source_id                = ' || p_ae_line_rec.source_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'source_table             = ' || p_ae_line_rec.source_table);
       arp_standard.debug('Dump_Dist_Amts: ' || 'code_combination_id      = ' || p_ae_line_rec.code_combination_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'amount_dr                = ' || p_ae_line_rec.amount_dr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'amount_cr                = ' || p_ae_line_rec.amount_cr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'acctd_amount_dr          = ' || p_ae_line_rec.acctd_amount_dr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'acctd_amount_cr          = ' || p_ae_line_rec.acctd_amount_cr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'source_id_secondary      = ' || p_ae_line_rec.source_id_secondary);
       arp_standard.debug('Dump_Dist_Amts: ' || 'source_table_secondary   = ' || p_ae_line_rec.source_table_secondary);
       arp_standard.debug('Dump_Dist_Amts: ' || 'currency_code            = ' || p_ae_line_rec.currency_code);
       arp_standard.debug('Dump_Dist_Amts: ' || 'currency_conversion_rate = ' || p_ae_line_rec.currency_conversion_rate);
       arp_standard.debug('Dump_Dist_Amts: ' || 'currency_conversion_type = ' || p_ae_line_rec.currency_conversion_type);
       arp_standard.debug('Dump_Dist_Amts: ' || 'currency_conversion_date = ' || p_ae_line_rec.currency_conversion_date);
       arp_standard.debug('Dump_Dist_Amts: ' || 'third_party_id           = ' || p_ae_line_rec.third_party_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'third_party_sub_id       = ' || p_ae_line_rec.third_party_sub_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'tax_group_code_id        = ' || p_ae_line_rec.tax_group_code_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'tax_code_id              = ' || p_ae_line_rec.tax_code_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'location_segment_id      = ' || p_ae_line_rec.location_segment_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'taxable_entered_dr       = ' || p_ae_line_rec.taxable_entered_dr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'taxable_entered_cr       = ' || p_ae_line_rec.taxable_entered_cr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'taxable_accounted_dr     = ' || p_ae_line_rec.taxable_accounted_dr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'taxable_accounted_cr     = ' || p_ae_line_rec.taxable_accounted_cr);
       arp_standard.debug('Dump_Dist_Amts: ' || 'tax_link_id              = ' || p_ae_line_rec.tax_link_id);
       arp_standard.debug('Dump_Dist_Amts: ' || 'reversed_source_id       = ' || p_ae_line_rec.reversed_source_id);
       arp_standard.debug('ARP_ALLOCATION_PKG.Dump_Dist_Amts()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ALLOCATION_PKG.Dump_Dist_Amts');
     END IF;
     RAISE;

END Dump_Dist_Amts;

PROCEDURE adj_boundary_account
(p_receivables_trx_id   IN     NUMBER,
 p_bucket               IN     VARCHAR2,
 p_ctlgd_id             IN     NUMBER,
 x_ccid                 IN OUT NOCOPY NUMBER)
IS
FUNCTION fct_adj_ccid
  (p_bucket                IN VARCHAR2,
   p_customer_trx_id       IN NUMBER,
   p_gl_account_source     IN VARCHAR2,
   p_code_combination_id   IN NUMBER,
   p_tax_code_source       IN VARCHAR2,
   p_receivables_trx_id    IN NUMBER)
RETURN NUMBER
 IS
   CURSOR c1 IS
   SELECT arp_etax_util.get_tax_account(tax.tax_rate_id,
                                        null,
                                        'ADJ',
                                        'TAX_RATE'),
          arp_etax_util.get_tax_account(tax.tax_rate_id,
                                        null,
                                        'ADJ_NON_REC',
                                        'TAX_RATE'),
          rt.tax_recoverable_flag
     FROM ar_receivables_trx  rt,
          zx_sco_rates        tax
    WHERE rt.receivables_trx_id = p_receivables_trx_id
      AND rt.asset_tax_code        = tax.tax_rate_code
      AND sysdate between nvl(tax.effective_from, sysdate) AND
                          nvl(tax.effective_to, sysdate);

   CURSOR c1_le(p_legal_entity_id NUMBER) IS
   SELECT arp_etax_util.get_tax_account(tax.tax_rate_id,
                                        null,
                                        'ADJ',
                                        'TAX_RATE'),
          arp_etax_util.get_tax_account(tax.tax_rate_id,
                                        null,
                                        'ADJ_NON_REC',
                                        'TAX_RATE'),
          rt.tax_recoverable_flag
     FROM ar_receivables_trx    rt,
          ar_rec_trx_le_details rtd,
          zx_sco_rates          tax
    WHERE rt.receivables_trx_id = p_receivables_trx_id
      AND rtd.receivables_trx_id (+) = rt.receivables_trx_id
      AND rtd.legal_entity_id (+)    = p_legal_entity_id
      AND nvl(rtd.asset_tax_code, rt.asset_tax_code)
                                     = tax.tax_rate_code
      AND trunc(sysdate) between nvl(tax.effective_from, trunc(sysdate)) AND
                                 nvl(tax.effective_to, trunc(sysdate));

   CURSOR c2 IS
   SELECT arp_etax_util.get_tax_account(tl.customer_trx_line_id,
                                        trunc(sysdate),
                                        'ADJ',
                                        'TAX_LINE'),
          arp_etax_util.get_tax_account(tl.customer_trx_line_id,
                                        trunc(sysdate),
                                        'FINCHRG',
                                        'TAX_LINE')
     FROM ra_customer_trx_lines   tl
    WHERE tl.customer_trx_id   = p_customer_trx_id
      AND tl.line_type         = 'TAX'
      AND tl.tax_line_id IS NOT NULL;

   l_adj_ccid                   NUMBER;
   l_finchrg_ccid               NUMBER;
   l_adj_non_rec_tax_ccid       NUMBER;
   l_tax_recoverable_flag       VARCHAR2(10);
   l_le_id                      NUMBER;
 BEGIN
   arp_standard.debug('fct_adj_ccid +');
   arp_standard.debug('   p_bucket             :'||p_bucket);
   arp_standard.debug('   p_customer_trx_id    :'||p_customer_trx_id);
   arp_standard.debug('   p_gl_account_source  :'||p_gl_account_source);
   arp_standard.debug('   p_code_combination_id:'||p_code_combination_id);
   arp_standard.debug('   p_tax_code_source    :'||p_tax_code_source);
   arp_standard.debug('   p_receivables_trx_id :'||p_receivables_trx_id);

   /* Determine if LE is required and fetch from target
      transaction */
   IF arp_legal_entity_util.is_le_subscriber
   THEN
      /* get LE from target trx */
      SELECT legal_entity_id
      INTO   l_le_id
      FROM   ra_customer_trx
      WHERE  customer_trx_id = p_customer_trx_id;
   ELSE
      /* Not required/used, set to null */
      l_le_id := NULL;
   END IF;

   -- Tax boundary
   IF p_bucket = 'ADJ_TAX' THEN
     arp_standard.debug('  Tax boundary');
     IF p_tax_code_source = 'ACTIVITY' THEN
        arp_standard.debug('    tax_code_source ACTIVITY');

        IF l_le_id IS NOT NULL
        THEN
           OPEN c1_le(l_le_id);
           FETCH c1_le INTO l_adj_ccid,
                     l_adj_non_rec_tax_ccid,
                     l_tax_recoverable_flag;
           CLOSE c1_le;
        ELSE
           OPEN c1;
           FETCH c1 INTO l_adj_ccid,
                     l_adj_non_rec_tax_ccid,
                     l_tax_recoverable_flag;
           CLOSE c1;
        END IF;
        arp_standard.debug('      l_adj_ccid     :'||l_adj_ccid);
        arp_standard.debug('      l_adj_non_rec_tax_ccid     :'||l_adj_non_rec_tax_ccid);
        arp_standard.debug('      l_tax_recoverable_flag     :'||l_tax_recoverable_flag);
        IF l_tax_recoverable_flag = 'N' THEN
            arp_standard.debug('       Returning  l_adj_non_rec_tax_ccid :'||l_adj_non_rec_tax_ccid);
            RETURN l_adj_non_rec_tax_ccid;
        ELSE
            arp_standard.debug('       Returning  l_adj_ccid :'||l_adj_ccid);
            RETURN l_adj_ccid;
        END IF;
     ELSIF p_tax_code_source = 'INVOICE' THEN
        -- unexpected situation no tax line on invoice
        arp_standard.debug('   tax code source INVOICE unexpected');
        arp_standard.debug('       Returning  -8');
        RETURN -8;
     ELSIF p_tax_code_source = 'NONE' THEN
        --unexpected situation inpossible for tax adjustment
        arp_standard.debug('   tax code source NONE unexpected');
        arp_standard.debug('       Returning  -8');
        RETURN -8;
     END IF;
   -- Line boundary
   ELSIF p_bucket = 'ADJ_LINE' THEN
     arp_standard.debug('  Line boundary');
     IF p_gl_account_source = 'ACTIVITY_GL_ACCOUNT' THEN
        arp_standard.debug('    gl_acount_source ACTIVITY_GL_ACCOUNT');
        arp_standard.debug('      Returning p_code_combination_id:'||p_code_combination_id);
        RETURN p_code_combination_id;
     ELSIF p_gl_account_source = 'TAX_CODE_ON_INVOICE' THEN
        arp_standard.debug('    gl_acount_source TAX_CODE_ON_INVOICE');
        OPEN c2;
        FETCH c2 INTO l_adj_ccid,
                      l_finchrg_ccid;
        CLOSE c2;
        arp_standard.debug('      l_adj_ccid     :'||l_adj_ccid);
        arp_standard.debug('      l_finchrg_ccid :'||l_finchrg_ccid);
        arp_standard.debug('       Returning  l_adj_ccid :'||l_adj_ccid);
        RETURN l_adj_ccid;
     ELSIF p_gl_account_source = 'REVENUE_ON_INVOICE' THEN
        -- Unexpected situation - no invoice line
        arp_standard.debug('   gl account source REVENUE_ON_INVOICE unexpected');
        arp_standard.debug('       Returning  -6');
        RETURN -6;
     END IF;
   -- Chrg boundary
   ELSIF p_bucket = 'ADJ_CHRG' THEN
     arp_standard.debug('  Charges boundary');
     IF p_gl_account_source = 'ACTIVITY_GL_ACCOUNT' THEN
        arp_standard.debug('    gl_acount_source ACTIVITY_GL_ACCOUNT');
        arp_standard.debug('      Returning p_code_combination_id:'||p_code_combination_id);
        RETURN p_code_combination_id;
     ELSIF p_gl_account_source = 'TAX_CODE_ON_INVOICE' THEN
        OPEN c2;
        FETCH c2 INTO l_adj_ccid,
                      l_finchrg_ccid;
        CLOSE c2;
        arp_standard.debug('      l_adj_ccid     :'||l_adj_ccid);
        arp_standard.debug('      l_finchrg_ccid :'||l_finchrg_ccid);
        arp_standard.debug('       Returning  l_finchrg_ccid :'||l_finchrg_ccid);
        RETURN l_finchrg_ccid;
     ELSIF p_gl_account_source = 'REVENUE_ON_INVOICE' THEN
        --Chrg boundary <=> no original amount invoice line so REVENUE_ON_INVOICE is unexpected
        arp_standard.debug('   gl account source REVENUE_ON_INVOICE unexpected');
        arp_standard.debug('       Returning  -7');
        RETURN -7;
     END IF;
   -- Chrg boundary
   ELSIF p_bucket = 'ADJ_FRT' THEN
     arp_standard.debug('  Charges boundary');
     IF p_gl_account_source = 'ACTIVITY_GL_ACCOUNT' THEN
        arp_standard.debug('    gl_acount_source ACTIVITY_GL_ACCOUNT');
        arp_standard.debug('      Returning p_code_combination_id:'||p_code_combination_id);
        RETURN p_code_combination_id;
     ELSIF p_gl_account_source = 'TAX_CODE_ON_INVOICE' THEN
        OPEN c2;
        FETCH c2 INTO l_adj_ccid,
                      l_finchrg_ccid;
        CLOSE c2;
        arp_standard.debug('      l_adj_ccid     :'||l_adj_ccid);
        arp_standard.debug('      l_finchrg_ccid :'||l_finchrg_ccid);
        arp_standard.debug('       Returning  L_ADJ_CCID :'||l_adj_ccid);
        RETURN l_adj_ccid;
     ELSIF p_gl_account_source = 'REVENUE_ON_INVOICE' THEN
        --Frt boundary <=> no original amount invoice line so REVENUE_ON_INVOICE is unexpected
        arp_standard.debug('   gl account source REVENUE_ON_INVOICE unexpected');
        arp_standard.debug('       Returning  -9');
        RETURN -9;
     END IF;
   END IF;
END;
BEGIN
--   IF     g_ae_summ_tax_tbl.bucket IN ('ADJ_LINE','ADJ_TAX','ADJ_FRT','ADJ_CHRG')
--      AND g_ae_summ_rev_tbl.ae_cust_trx_line_gl_dist_id IN (-6,-7,-8,-9)
 arp_standard.debug('  p_receivables_trx_id  :'||  p_receivables_trx_id);
 arp_standard.debug('  p_bucket              :'||  p_bucket);
 arp_standard.debug('  p_ctlgd_id            :'||  p_ctlgd_id );
  -- bug#5016123
  -- No Accounting should be created for the adj the ccid should keep the receivable ccid
  -- of the initial doc - but the distributions generated by the shadow adjustment
  -- should serve as template for the Transaction history
  -- BR shadow adjustment
   IF  p_receivables_trx_id  = -15 THEN
      x_ccid := NULL;
   ELSIF  p_bucket IN ('ADJ_LINE','ADJ_TAX','ADJ_FRT','ADJ_CHRG')
--      AND p_ctlgd_id IN (-6,-7,-8,-9)
   THEN
      x_ccid := fct_adj_ccid (p_bucket            => p_bucket,
                              p_customer_trx_id   => g_Cust_inv_rec.customer_trx_id,
                              p_gl_account_source => g_ae_rule_rec.gl_account_source1,
                              p_code_combination_id => g_ae_rule_rec.code_combination_id1,
                              p_tax_code_source    => g_ae_rule_rec.tax_code_source1,
                              p_receivables_trx_id  => p_receivables_trx_id);
   arp_standard.debug('  x_ccid            :'||  x_ccid );
   END IF;
END;


END ARP_ALLOCATION_PKG;

/
