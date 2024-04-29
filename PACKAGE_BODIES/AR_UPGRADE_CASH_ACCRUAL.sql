--------------------------------------------------------
--  DDL for Package Body AR_UPGRADE_CASH_ACCRUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_UPGRADE_CASH_ACCRUAL" AS
/* $Header: ARUPGLZB.pls 120.13.12010000.5 2010/03/05 07:49:09 nemani ship $ */

g_ae_sys_rec    arp_acct_main.ae_sys_rec_type;
g_ind_current   NUMBER := -9;
g_run_tot       NUMBER := 0;
g_run_acctd_tot NUMBER := 0;

PROCEDURE create_cash_distributions;

--PROCEDURE create_mfar_distributions;



PROCEDURE local_log
(p_msg_text        IN VARCHAR2,
 p_msg_level       IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
BEGIN
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
     arp_standard.debug(p_msg_text);
  END IF;
END;

PROCEDURE log(
   message       IN VARCHAR2,
   newline       IN BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF NVL(fnd_global.CONC_REQUEST_ID,0) <> 0 THEN
    IF message = 'NEWLINE' THEN
      FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
    ELSIF (newline) THEN
      FND_FILE.put_line(fnd_file.log,message);
    ELSE
      FND_FILE.put(fnd_file.log,message);
    END IF;
  ELSE
    local_log(message);
  END IF;
END log;



FUNCTION fct_acct_amt
  (p_amt             IN NUMBER,
   p_base_amt        IN NUMBER,
   p_base_acctd_amt  IN NUMBER,
   p_currency_code   IN VARCHAR2,
   p_base_currency   IN VARCHAR2,
   p_ind_id          IN NUMBER)
RETURN NUMBER
IS
  l_acctd_amt NUMBER;
BEGIN
   IF g_ind_current <> p_ind_id THEN
      g_run_tot       := 0;
      g_run_acctd_tot := 0;
      g_ind_current   := p_ind_id;
   END IF;
   g_run_tot   := g_run_tot + p_amt;
   IF (p_base_amt <> p_base_acctd_amt)     AND
      (p_currency_code <> p_base_currency) AND
      (p_base_acctd_amt <> 0)
   THEN
       l_acctd_amt := arpcurr.CurrRound(g_run_tot / p_base_amt * p_base_acctd_amt , p_base_currency) - g_run_acctd_tot;
   ELSE
       l_acctd_amt := p_amt;
   END IF;
   g_run_acctd_tot := g_run_acctd_tot + l_acctd_amt;
   RETURN l_acctd_amt;
END;



PROCEDURE Init_Curr_Details
  (p_sob_id            IN NUMBER,
   p_org_id            IN NUMBER,
   x_accounting_method IN OUT NOCOPY ar_system_parameters.accounting_method%TYPE)
 IS
BEGIN
log('Init_Curr_Details +');
  SELECT sob.set_of_books_id,
         sob.chart_of_accounts_id,
         sob.currency_code,
         c.precision,
         c.minimum_accountable_unit,
         sysp.code_combination_id_gain,
         sysp.code_combination_id_loss,
         sysp.code_combination_id_round,
         sysp.accounting_method
  INTO   g_ae_sys_rec.set_of_books_id,
         g_ae_sys_rec.coa_id,
         g_ae_sys_rec.base_currency,
         g_ae_sys_rec.base_precision,
         g_ae_sys_rec.base_min_acc_unit,
         g_ae_sys_rec.gain_cc_id,
         g_ae_sys_rec.loss_cc_id,
         g_ae_sys_rec.round_cc_id,
         x_accounting_method
  FROM   ar_system_parameters_all sysp,
         gl_sets_of_books         sob,
         fnd_currencies           c
  WHERE  sysp.org_id         = p_org_id
  AND    sob.set_of_books_id = sysp.set_of_books_id --would be the row returned from multi org view
  AND    sob.currency_code   = c.currency_code;
log('Init_Curr_Details -');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         log('Init_Curr_Details - NO_DATA_FOUND' );
         RAISE;
    WHEN OTHERS THEN
        log('EXCEPTION OTHERS : '||SQLERRM);
        RAISE;
END Init_Curr_Details;


PROCEDURE stamping_11i_app_post
IS
BEGIN
  log(' stamping_11i_app_post +');
  UPDATE ar_receivable_applications_all ra
  SET ra.upgrade_method = 'R12_11ICASH_POST'
  WHERE ra.receivable_application_id IN (
    SELECT app.receivable_application_id
    FROM xla_events_gt                   evt,
         ar_receivable_applications_all  app
    WHERE evt.event_type_code IN ( 'RECP_CREATE'      ,'RECP_UPDATE'      ,
                                 'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                                 'CM_CREATE'        ,'CM_UPDATE')
      AND evt.event_id        = app.event_id
      AND app.status          = 'APP'
      AND app.upgrade_method        IS NULL
      AND EXISTS (SELECT '1'
                    FROM ar_adjustments_all                                adj
                  WHERE adj.customer_trx_id = app.applied_customer_trx_id
                    AND adj.upgrade_method  = '11I'
                    AND adj.status          = 'A'
                    AND adj.postable        = 'Y'));
  log(' stamping_11i_app_post -');
EXCEPTION
WHEN OTHERS THEN
  log('EXCEPTION OTHERS: stamping_11i_cash_app_post :'||SQLERRM);
END;





PROCEDURE conv_amt
(p_acctd_amt        IN NUMBER,
 p_trx_currency     IN VARCHAR2,
 p_base_currency    IN VARCHAR2,
 --
 p_line_amt         IN NUMBER,
 p_tax_amt          IN NUMBER,
 p_frt_amt          IN NUMBER,
 p_chrg_amt         IN NUMBER,
 --
 x_line_acctd_amt   OUT NOCOPY NUMBER,
 x_tax_acctd_amt    OUT NOCOPY NUMBER,
 x_frt_acctd_amt    OUT NOCOPY NUMBER,
 x_chrg_acctd_amt   OUT NOCOPY NUMBER)
IS
  l_same          VARCHAR2(1) := 'N';
  l_run_tot       NUMBER := 0;
  l_run_acctd_tot NUMBER := 0;
  --
  l_line          NUMBER;
  l_tax           NUMBER;
  l_frt           NUMBER;
  l_chrg          NUMBER;
  l_acctd_line    NUMBER;
  l_acctd_tax     NUMBER;
  l_acctd_frt     NUMBER;
  l_acctd_chrg    NUMBER;
  l_base          NUMBER;
BEGIN
log('conv_amt +');
  --
  -- Note the p_xxx_amt should not be null at this point
  -- The code is not checking the null value of the argument for perf
  --
  l_base  := p_line_amt + p_tax_amt + p_frt_amt + p_chrg_amt;
  IF l_base = 0 THEN
     l_same := 'Y';
  ELSE
    IF (p_trx_currency = p_base_currency) OR
       (l_base = p_acctd_amt)
    THEN
      l_same := 'Y';
    END IF;
  END IF;

  IF l_same = 'N' THEN
    -- line
    l_line          := p_line_amt;
    l_run_tot       := l_run_tot + l_line;
    l_acctd_line    := arpcurr.CurrRound( l_run_tot * p_acctd_amt /l_base , p_base_currency ) - l_run_acctd_tot;
    l_run_acctd_tot := l_run_acctd_tot + l_acctd_line;
    -- tax
    l_tax           := p_tax_amt;
    l_run_tot       := l_run_tot + l_tax;
    l_acctd_tax     := arpcurr.CurrRound( l_run_tot * p_acctd_amt /l_base , p_base_currency ) - l_run_acctd_tot;
    l_run_acctd_tot := l_run_acctd_tot + l_acctd_tax;
    -- freight
    l_frt           := p_frt_amt;
    l_run_tot       := l_run_tot + l_frt;
    l_acctd_frt     := arpcurr.CurrRound( l_run_tot * p_acctd_amt /l_base , p_base_currency ) - l_run_acctd_tot;
    l_run_acctd_tot := l_run_acctd_tot + l_acctd_frt;
    -- charges
    l_chrg          := p_chrg_amt;
    l_run_tot       := l_run_tot + l_chrg;
    l_acctd_chrg    := arpcurr.CurrRound( l_run_tot * p_acctd_amt /l_base , p_base_currency ) - l_run_acctd_tot;
    l_run_acctd_tot := l_run_acctd_tot + l_acctd_chrg;
  ELSE
    -- Line
    l_line          := p_line_amt;
    l_acctd_line    := l_line;
    -- tax
    l_tax           := p_tax_amt;
    l_acctd_tax     := l_tax;
    -- freight
    l_frt           := p_frt_amt;
    l_acctd_frt     := l_frt;
    -- charges
    l_chrg          := p_chrg_amt;
    l_acctd_chrg    := l_chrg;
  END IF;

  x_line_acctd_amt  := l_acctd_line;
  x_tax_acctd_amt   := l_acctd_tax;
  x_frt_acctd_amt   := l_acctd_frt;
  x_chrg_acctd_amt  := l_acctd_chrg;

log('  x_line_acctd_amt :'||  x_line_acctd_amt);
log('  x_tax_acctd_amt  :'||  x_tax_acctd_amt);
log('  x_frt_acctd_amt  :'||  x_frt_acctd_amt);
log('  x_chrg_acctd_amt :'||  x_chrg_acctd_amt);
log('conv_amt -');
END;






PROCEDURE get_direct_inv_dist
  (p_mode                 IN VARCHAR2,
   p_trx_id               IN NUMBER   DEFAULT NULL,
   p_gt_id                IN NUMBER   DEFAULT NULL)
IS
BEGIN
log('get_direct_inv_dist +');
log('  p_mode   :'||p_mode);
log('  p_trx_id :'||p_trx_id);
log('  p_gt_id  :'||p_gt_id);

IF p_mode = 'OLTP' THEN
   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
  --{HYUBPAGP
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
  --}
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     --{Taxable Amount
     tax_link_id,
     tax_inc_flag,
     --}
     tax_code_id,
     location_segment_id
     )
SELECT
      p_gt_id                     -- GT_ID
,     ctlgd.amount                -- AMT
,     ctlgd.acctd_amount          -- ACCTD_AMT
,     DECODE(ctl.line_type,'LINE','REV',
                           'TAX','TAX',
                           'FREIGHT','FREIGHT',
                           'CHARGES','CHARGES',
                           'CB','REV')      -- ACCOUNT_CLASS
,     DECODE(ctlgd.collected_tax_ccid,
              NULL, ctlgd.code_combination_id,
              0   , ctlgd.code_combination_id,
                 ctlgd.collected_tax_ccid)  -- CCID_SECONDARY
,     DECODE(ctl.line_type,'LINE',-6,
                           'TAX',-8,
                           'FREIGHT',-9,
                           'CHARGES',-7,
                           'CB',-6) -- REF_CUST_TRX_LINE_GL_DIST_ID
--,     ctlgd.cust_trx_line_gl_dist_id -- REF_CUST_TRX_LINE_GL_DIST_ID
,     DECODE(ctl.line_type,'LINE',-6,
                           'TAX',-8,
                           'FREIGHT',-9,
                           'CHARGES',-7,
                           'CB',-6) -- REF_CUSTOMER_TRX_LINE_ID
,     trx.customer_trx_id         -- REF_CUSTOMER_TRX_ID
,     trx.invoice_currency_code   -- TO_CURRENCY
,     NULL                        -- BASE_CURRENCY
  -- ADJ and APP Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)          -- DIST_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0)    -- DIST_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       -- DIST_CHRG_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_CHRG_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_FRT_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_FRT_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)           -- DIST_TAX_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)     -- DIST_TAX_ACCTD_AMT
     -- Buc
,     0         -- tl_alloc_amt
,     0    -- tl_alloc_acctd_amt
,     0          -- tl_chrg_alloc_amt
,     0    -- tl_chrg_alloc_acctd_amt
,     0           -- tl_frt_alloc_amt
,     0     -- tl_frt_alloc_acctd_amt
,     0           -- tl_tax_alloc_amt
,     0     -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,
                           'CB'  ,ctlgd.amount, 0)       -- DIST_ed_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,
                           'CB'  ,ctlgd.acctd_amount, 0) -- DIST_ed_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)    -- DIST_ed_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_ed_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)    -- DIST_ed_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_ed_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)        -- DIST_ed_tax_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)  -- DIST_ed_tax_ACCTD_AMT
     --
,    0       -- tl_ed_alloc_amt
,    0       -- tl_ed_alloc_acctd_amt
,    0       -- tl_ed_chrg_alloc_amt
,    0       -- tl_ed_chrg_alloc_acctd_amt
,    0       -- tl_ed_frt_alloc_amt
,    0       -- tl_ed_frt_alloc_acctd_amt
,    0       -- tl_ed_tax_alloc_amt
,    0       -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)       -- DIST_uned_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0) -- DIST_uned_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)    -- DIST_uned_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_uned_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_uned_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_uned_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)        -- DIST_uned_tax_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)  -- DIST_uned_tax_ACCTD_AMT
     --
,    0          -- tl_uned_alloc_amt
,    0    -- tl_uned_alloc_acctd_amt
,    0          -- tl_uned_chrg_alloc_amt
,    0    -- tl_uned_chrg_alloc_acctd_amt
,    0           -- tl_uned_frt_alloc_amt
,    0     -- tl_uned_frt_alloc_acctd_amt
,    0           -- tl_uned_tax_alloc_amt
,    0     -- tl_uned_tax_alloc_acctd_amt
     --
,    NULL    -- source_type
,    'CTLGD' -- source_table
,    NULL    -- source_id
,    ctl.line_type  -- line_type
     --
,    NULL     -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    trx.set_of_books_id  -- set_of_books_id
,    'P'                 -- sob_type
,    USERENV('SESSIONID')   -- se_gt_id
     --{Taxable Amount
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
     --}
,    DECODE(ctl.line_type,'LINE',taxx.vat_tax_id,ctl.vat_tax_id) vat_tax_id
,    DECODE(ctl.line_type,'LINE',taxx.location_segment_id,ctl.location_segment_id)
FROM ra_customer_trx          trx,
     ra_customer_trx_lines    ctl,
     ra_cust_trx_line_gl_dist ctlgd,
     ( select ctl_tax.*
       from ra_customer_trx_lines ctl_tax
       where customer_trx_id = p_trx_id
       and nvl(ctl_tax.line_number,1) = 1
       and line_type = 'TAX'
     ) taxx
WHERE trx.customer_trx_id      =  p_trx_id
  AND ctl.customer_trx_id      =  trx.customer_trx_id
  AND ctl.customer_trx_line_id =  ctlgd.customer_trx_line_id
  AND ctl.line_type            IN ('LINE','TAX','FREIGHT','CHARGES','CB')
  AND ctl.customer_trx_line_id = taxx.link_to_cust_trx_line_id(+)
  AND ctlgd.account_class      IN ('REV','SUSPENSE','UNBILL','UNEARN','FREIGHT','TAX')
  AND ctlgd.account_set_flag   = 'N'
  AND NOT EXISTS (SELECT '1' FROM RA_AR_GT
                  WHERE source_table = 'CTLGD'
                    AND REF_CUSTOMER_TRX_ID  = p_trx_id );

ELSIF p_mode = 'BATCH' THEN

   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     tax_link_id,
     tax_inc_flag,
     tax_code_id,
     location_segment_id
     )
SELECT
      p_gt_id                     -- GT_ID
,     ctlgd.amount                -- AMT
,     ctlgd.acctd_amount          -- ACCTD_AMT
,     DECODE(ctl.line_type,'LINE','REV',
                           'TAX','TAX',
                           'FREIGHT','FREIGHT',
                           'CHARGES','CHARGES',
                           'CB','REV')      -- ACCOUNT_CLASS
,     DECODE(ctlgd.collected_tax_ccid,
              NULL, ctlgd.code_combination_id,
              0   , ctlgd.code_combination_id,
                 ctlgd.collected_tax_ccid)  -- CCID_SECONDARY
,     ctlgd.cust_trx_line_gl_dist_id -- REF_CUST_TRX_LINE_GL_DIST_ID
,     DECODE(ctl.line_type,'LINE',-6,
                           'TAX',-8,
                           'FREIGHT',-9,
                           'CHARGES',-7,
                           'CB',-6)  --ctl.customer_trx_line_id    -- REF_CUSTOMER_TRX_LINE_ID
,     trx.customer_trx_id         -- REF_CUSTOMER_TRX_ID
,     trx.invoice_currency_code   -- TO_CURRENCY
,     NULL  -- BASE_CURRENCY
  -- ADJ and APP Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)          -- DIST_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0)    -- DIST_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       -- DIST_CHRG_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_CHRG_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_FRT_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_FRT_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)           -- DIST_TAX_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)     -- DIST_TAX_ACCTD_AMT
     -- Buc
,     0      -- tl_alloc_amt
,     0      -- tl_alloc_acctd_amt
,     0      -- tl_chrg_alloc_amt
,     0      -- tl_chrg_alloc_acctd_amt
,     0      -- tl_frt_alloc_amt
,     0      -- tl_frt_alloc_acctd_amt
,     0      -- tl_tax_alloc_amt
,     0      -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)       -- DIST_ed_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0) -- DIST_ed_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)    -- DIST_ed_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_ed_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)    -- DIST_ed_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_ed_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)        -- DIST_ed_tax_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)  -- DIST_ed_tax_ACCTD_AMT
     --
,    0          -- tl_ed_alloc_amt
,    0    -- tl_ed_alloc_acctd_amt
,    0          -- tl_ed_chrg_alloc_amt
,    0    -- tl_ed_chrg_alloc_acctd_amt
,    0           -- tl_ed_frt_alloc_amt
,    0     -- tl_ed_frt_alloc_acctd_amt
,    0           -- tl_ed_tax_alloc_amt
,    0     -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)       -- DIST_uned_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0) -- DIST_uned_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)    -- DIST_uned_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_uned_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_uned_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_uned_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)        -- DIST_uned_tax_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)  -- DIST_uned_tax_ACCTD_AMT
     --
,    0          -- tl_uned_alloc_amt
,    0    -- tl_uned_alloc_acctd_amt
,    0          -- tl_uned_chrg_alloc_amt
,    0    -- tl_uned_chrg_alloc_acctd_amt
,    0           -- tl_uned_frt_alloc_amt
,    0     -- tl_uned_frt_alloc_acctd_amt
,    0           -- tl_uned_tax_alloc_amt
,    0     -- tl_uned_tax_alloc_acctd_amt
     --
,    NULL    -- source_type
,    'CTLGD' -- source_table
,    NULL    -- source_id
,    ctl.line_type  -- line_type
     --
,    NULL     -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    trx.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')   -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
,    DECODE(ctl.line_type,'LINE',taxx.vat_tax_id,ctl.vat_tax_id) vat_tax_id
,    DECODE(ctl.line_type,'LINE',taxx.location_segment_id,ctl.location_segment_id)
FROM xla_events_gt                                     evt,
     ar_receivable_applications_all                    app,
     ar_system_parameters_all                          ars,
     ra_customer_trx_all                               trx,
     ra_customer_trx_lines_all                         ctl,
     ra_cust_trx_line_gl_dist_all                      ctlgd,
     ( select ctl_tax.*
       from ra_customer_trx_lines ctl_tax
       where nvl(ctl_tax.line_number,1) = 1
       and line_type = 'TAX'
     ) taxx
WHERE  evt.event_type_code IN ('RECP_CREATE'      ,'RECP_UPDATE'  ,
                               'RECP_RATE_ADJUST' ,'RECP_REVERSE' ,
                               'CM_CREATE'        ,'CM_UPDATE'    )
   AND evt.application_id          = 222
   AND evt.event_id                = app.event_id
   AND app.status                  = 'APP'
   AND app.upgrade_method          IS NULL
   AND app.org_id                  = ars.org_id
   AND ars.accounting_method       = 'CASH'
   AND app.applied_customer_trx_id = trx.customer_trx_id
   AND trx.customer_trx_id         = ctl.customer_trx_id
   AND ctl.customer_trx_line_id    = ctlgd.customer_trx_line_id
   AND ctl.line_type               IN ('LINE','TAX','FREIGHT','CHARGES','CB')
   AND ctlgd.account_class         IN ('REV','SUSPENSE','UNBILL','UNEARN','FREIGHT','TAX')
   AND ctlgd.account_set_flag      = 'N'
   AND ctl.customer_trx_line_id    = taxx.link_to_cust_trx_line_id(+)
   AND EXISTS (SELECT '1' FROM ar_adjustments_all adj
                  WHERE adj.customer_trx_id = app.applied_customer_trx_id
                    AND adj.upgrade_method  = '11I'
                    AND adj.status          = 'A'
                    AND adj.postable        = 'Y');

/*
FROM ( -- Applied to transactions
      SELECT DISTINCT inv.customer_trx_id,
                      inv.invoice_currency_code,
                      inv.set_of_books_id
        FROM xla_events_gt                   evt,
             ar_receivable_applications_all  app,
             ra_customer_trx_all             inv,
             ar_system_parameters_all        ars
       WHERE evt.event_type_code
                  IN (  'RECP_CREATE'      ,'RECP_UPDATE'      ,
                        'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
						'CM_CREATE'        ,'CM_UPDATE'         )
         AND evt.event_id                = app.event_id
         AND app.applied_customer_trx_id = inv.customer_trx_id
         AND app.upgrade_method          IS NULL
         AND ars.org_id                  = app.org_id
         AND ars.accounting_method       = 'CASH'
         AND NOT EXISTS ( SELECT '1'
                  FROM psa_trx_types_all psa
                 WHERE inv.cust_trx_type_id = psa.psa_trx_type_id)
      UNION
       -- From CM in the case of CM APP
	  SELECT DISTINCT inv.customer_trx_id,
                      inv.invoice_currency_code,
                      inv.set_of_books_id
        FROM xla_events_gt                   evt,
             ar_receivable_applications_all  app,
             ra_customer_trx_all             inv,
             ar_system_parameters_all        ars
       WHERE evt.event_type_code
                  IN (  'CM_CREATE'        ,'CM_UPDATE'         )
         AND evt.event_id                = app.event_id
         AND app.customer_trx_id         = inv.customer_trx_id
         AND app.upgrade_method               IS NULL
         AND ars.org_id                  = app.org_id
         AND ars.accounting_method       = 'CASH'
         AND NOT EXISTS ( SELECT '1'
                  FROM psa_trx_types_all psa
                 WHERE inv.cust_trx_type_id = psa.psa_trx_type_id))          trx,
     ra_customer_trx_lines_all                         ctl,
     ra_cust_trx_line_gl_dist_all                      ctlgd
 WHERE trx.customer_trx_id         = ctl.customer_trx_id
   AND ctl.customer_trx_line_id    = ctlgd.customer_trx_line_id
   AND ctl.line_type            IN ('LINE','TAX','FREIGHT','CHARGES','CB')
   AND ctlgd.account_class      IN ('REV','SUSPENSE','UNBILL','UNEARN','FREIGHT','TAX')
   AND ctlgd.account_set_flag   = 'N';
*/
END IF;
log('get_direct_inv_dist -');
EXCEPTION
WHEN OTHERS THEN
  log('EXCEPTION OTHERS: get_direct_inv_dist :'||SQLERRM);
END get_direct_inv_dist;





PROCEDURE get_direct_mf_inv_dist
  (p_mode                 IN VARCHAR2 DEFAULT 'BATCH',
   p_gt_id                IN NUMBER   DEFAULT NULL)
IS
BEGIN
log('get_direct_mf_inv_dist +');
log('  p_gt_id  :'||p_gt_id);

IF p_mode = 'BATCH' THEN

   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     tax_link_id,
     tax_inc_flag
     )
SELECT
      p_gt_id                     -- GT_ID
,     ctlgd.amount                -- AMT
,     ctlgd.acctd_amount          -- ACCTD_AMT
,     DECODE(ctl.line_type,'LINE','REV',
                           'TAX','TAX',
                           'FREIGHT','FREIGHT',
                           'CHARGES','CHARGES',
                           'CB','REV')      -- ACCOUNT_CLASS
,     DECODE(ctlgd.collected_tax_ccid,
              NULL, ctlgd.code_combination_id,
              0   , ctlgd.code_combination_id,
                 ctlgd.collected_tax_ccid)  -- CCID_SECONDARY
,     ctlgd.cust_trx_line_gl_dist_id -- REF_CUST_TRX_LINE_GL_DIST_ID
,     ctl.customer_trx_line_id       -- REF_CUSTOMER_TRX_LINE_ID
,     trx.customer_trx_id            -- REF_CUSTOMER_TRX_ID
,     trx.invoice_currency_code      -- TO_CURRENCY
,     NULL  -- BASE_CURRENCY
  -- ADJ and APP Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)          -- DIST_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0)    -- DIST_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)       -- DIST_CHRG_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_CHRG_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_FRT_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_FRT_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)           -- DIST_TAX_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)     -- DIST_TAX_ACCTD_AMT
     -- Buc
,     0      -- tl_alloc_amt
,     0      -- tl_alloc_acctd_amt
,     0      -- tl_chrg_alloc_amt
,     0      -- tl_chrg_alloc_acctd_amt
,     0      -- tl_frt_alloc_amt
,     0      -- tl_frt_alloc_acctd_amt
,     0      -- tl_tax_alloc_amt
,     0      -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)       -- DIST_ed_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0) -- DIST_ed_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)    -- DIST_ed_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_ed_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)    -- DIST_ed_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_ed_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)        -- DIST_ed_tax_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)  -- DIST_ed_tax_ACCTD_AMT
     --
,    0          -- tl_ed_alloc_amt
,    0    -- tl_ed_alloc_acctd_amt
,    0          -- tl_ed_chrg_alloc_amt
,    0    -- tl_ed_chrg_alloc_acctd_amt
,    0           -- tl_ed_frt_alloc_amt
,    0     -- tl_ed_frt_alloc_acctd_amt
,    0           -- tl_ed_tax_alloc_amt
,    0     -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,     DECODE(ctl.line_type,'LINE',ctlgd.amount,0)       -- DIST_uned_AMT
,     DECODE(ctl.line_type,'LINE',ctlgd.acctd_amount,0) -- DIST_uned_ACCTD_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.amount,0)    -- DIST_uned_chrg_AMT
,     DECODE(ctl.line_type,'CHARGES',ctlgd.acctd_amount,0) -- DIST_uned_chrg_ACCTD_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.amount,0)       -- DIST_uned_frt_AMT
,     DECODE(ctl.line_type,'FREIGHT',ctlgd.acctd_amount,0) -- DIST_uned_frt_ACCTD_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.amount,0)        -- DIST_uned_tax_AMT
,     DECODE(ctl.line_type,'TAX',ctlgd.acctd_amount,0)  -- DIST_uned_tax_ACCTD_AMT
     --
,    0          -- tl_uned_alloc_amt
,    0    -- tl_uned_alloc_acctd_amt
,    0          -- tl_uned_chrg_alloc_amt
,    0    -- tl_uned_chrg_alloc_acctd_amt
,    0           -- tl_uned_frt_alloc_amt
,    0     -- tl_uned_frt_alloc_acctd_amt
,    0           -- tl_uned_tax_alloc_amt
,    0     -- tl_uned_tax_alloc_acctd_amt
     --
,    NULL    -- source_type
,    'CTLGD' -- source_table
,    NULL    -- source_id
,    ctl.line_type  -- line_type
     --
,    NULL     -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    trx.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')   -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
FROM ( -- Applied to transactions
      SELECT DISTINCT inv.customer_trx_id,
                      inv.invoice_currency_code,
                      inv.set_of_books_id
        FROM xla_events_gt                   evt,
             ar_receivable_applications_all  app,
             ra_customer_trx_all             inv,
             psa_trx_types_all               psa
       WHERE evt.event_type_code
                  IN (  'RECP_CREATE'      ,'RECP_UPDATE'      ,
                        'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                        'CM_CREATE'        ,'CM_UPDATE'         )
         AND evt.event_id                = app.event_id
         AND app.applied_customer_trx_id = inv.customer_trx_id
         AND inv.cust_trx_type_id        = psa.psa_trx_type_id
         AND app.upgrade_method               IS NULL
      UNION
       -- From CM in the case of CM APP
	  SELECT DISTINCT inv.customer_trx_id,
                      inv.invoice_currency_code,
                      inv.set_of_books_id
        FROM xla_events_gt                   evt,
             ar_receivable_applications_all  app,
             ra_customer_trx_all             inv,
             psa_trx_types_all               psa
       WHERE evt.event_type_code
                  IN (  'CM_CREATE'        ,'CM_UPDATE'         )
         AND evt.event_id                = app.event_id
         AND app.customer_trx_id         = inv.customer_trx_id
         AND inv.cust_trx_type_id        = psa.psa_trx_type_id
         AND app.upgrade_method               IS NULL)          trx,
     ra_customer_trx_lines_all                         ctl,
     ra_cust_trx_line_gl_dist_all                      ctlgd
 WHERE trx.customer_trx_id         = ctl.customer_trx_id
   AND ctl.customer_trx_line_id    = ctlgd.customer_trx_line_id
   AND ctl.line_type            IN ('LINE','TAX','FREIGHT','CHARGES','CB')
   AND ctlgd.account_class      IN ('REV','SUSPENSE','UNBILL','UNEARN','FREIGHT','TAX')
   AND ctlgd.account_set_flag   = 'N';
END IF;
log('get_direct_mf_inv_dist -');
EXCEPTION
WHEN OTHERS THEN
  log('EXCEPTION OTHERS: get_direct_mf_inv_dist :'||SQLERRM);
END get_direct_mf_inv_dist;






PROCEDURE get_direct_adj_dist
  (p_mode                 IN VARCHAR2,
   p_trx_id               IN NUMBER  DEFAULT NULL,
   p_gt_id                IN NUMBER  DEFAULT NULL)
IS
BEGIN
log('get_direct_adj_dist +');
log('   p_mode   : '|| p_mode);
log('   p_trx_id : '|| p_trx_id);
log('   p_gt_id  : '|| p_gt_id);
 IF p_mode = 'OLTP' THEN
   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     --{Taxable Amount
     tax_link_id,
     tax_inc_flag,
     --}
     ref_line_id,
     tax_code_id,
     location_segment_id
     )
SELECT
   p_gt_id                                          -- GT_ID
,  NVL(ard.amount_cr,0)
        - NVL(ard.amount_dr,0)                      -- AMT
,  NVL(ard.acctd_amount_cr,0)
        - NVL(ard.acctd_amount_dr,0)                -- ACCTD_AMT
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ','REV',
                               'TAX','TAX',
                      'DEFERRED_TAX','TAX',
                   'ADJ_NON_REC_TAX','TAX','REV'),
            'TAX' ,DECODE(ard.source_type,'TAX','TAX',
                               'ADJ','TAX',
                      'DEFERRED_TAX','TAX',
                   'ADJ_NON_REC_TAX','TAX','TAX'),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              'FREIGHT','FREIGHT'),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              'CHARGES','CHARGES'),
            'REV')                                 -- ACCOUNT_CLASS
,  ard.code_combination_id                         -- CCID_SECONDARY
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ',-6,
                               'TAX',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-6),
            'TAX' ,DECODE(ard.source_type,'TAX',-8,
                               'ADJ',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-8),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              -9,-9),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              -7,-7),
            -6)                                    -- REF_CUST_TRX_LINE_GL_DIST_ID
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ',-6,
                               'TAX',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-6),
            'TAX' ,DECODE(ard.source_type,'TAX',-8,
                               'ADJ',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-8),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              -9,-9),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              -7,-7),
            -6)                                    -- REF_CUSTOMER_TRX_LINE_ID
,  adj.customer_trx_id                             -- REF_CUSTOMER_TRX_ID
,  trx.invoice_currency_code                       -- TO_CURRENCY
,  NULL                      -- BASE_CURRENCY
  -- ADJ and APP Elmt
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                 'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_AMT
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ACCTD_AMT
   --
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_CHRG_AMT
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_CHRG_ACCTD_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_FRT_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_FRT_ACCTD_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_TAX_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_TAX_ACCTD_AMT
  -- Buc
,     0          -- tl_alloc_amt
,     0    -- tl_alloc_acctd_amt
,     0          -- tl_chrg_alloc_amt
,     0    -- tl_chrg_alloc_acctd_amt
,     0           -- tl_frt_alloc_amt
,     0     -- tl_frt_alloc_acctd_amt
,     0           -- tl_tax_alloc_amt
,     0     -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                 'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_AMT
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_ACCTD_AMT
   --
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_chrg_AMT
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_chrg_ACCTD_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_frt_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_frt_ACCTD_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_tax_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_tax_ACCTD_AMT
--,     0      -- DIST_ed_AMT
--,     0      -- DIST_ed_ACCTD_AMT
--,     0      -- DIST_ed_chrg_AMT
--,     0      -- DIST_ed_chrg_ACCTD_AMT
--,     0      -- DIST_ed_frt_AMT
--,     0      -- DIST_ed_frt_ACCTD_AMT
--,     0      -- DIST_ed_tax_AMT
--,     0      -- DIST_ed_tax_ACCTD_AMT
     --
,     0      -- tl_ed_alloc_amt
,     0      -- tl_ed_alloc_acctd_amt
,     0      -- tl_ed_chrg_alloc_amt
,     0      -- tl_ed_chrg_alloc_acctd_amt
,     0      -- tl_ed_frt_alloc_amt
,     0      -- tl_ed_frt_alloc_acctd_amt
,     0      -- tl_ed_tax_alloc_amt
,     0      -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                 'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_AMT
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_ACCTD_AMT
   --
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_chrg_AMT
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_chrg_ACCTD_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_frt_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_frt_ACCTD_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_tax_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_tax_ACCTD_AMT
--,     0      -- DIST_uned_AMT
--,     0      -- DIST_uned_ACCTD_AMT
--,     0      -- DIST_uned_chrg_AMT
--,     0      -- DIST_uned_chrg_ACCTD_AMT
--,     0      -- DIST_uned_frt_AMT
--,     0      -- DIST_uned_frt_ACCTD_AMT
--,     0      -- DIST_uned_tax_AMT
--,     0      -- DIST_uned_tax_ACCTD_AMT
     --
,     0      -- tl_uned_alloc_amt
,     0      -- tl_uned_alloc_acctd_amt
,     0      -- tl_uned_chrg_alloc_amt
,     0      -- tl_uned_chrg_alloc_acctd_amt
,     0      -- tl_uned_frt_alloc_amt
,     0      -- tl_uned_frt_alloc_acctd_amt
,     0      -- tl_uned_tax_alloc_amt
,     0      -- tl_uned_tax_alloc_acctd_amt
     --
,    ard.source_type      -- source_type
,    ard.source_table     -- source_table
,    ard.source_id        -- source_id
,    DECODE(adj.type,
          'LINE',DECODE(ard.source_type,'ADJ','LINE',
                                        'TAX','TAX',
                               'DEFERRED_TAX','TAX','LINE'),
           'TAX','TAX',
          'CHARGES','CHARGES',
          'FREIGHT','FREIGHT', 'LINE')      -- line_type
     --
,    NULL                                   -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    adj.set_of_books_id  -- set_of_books_id
,    'P'                 -- sob_type
,    USERENV('SESSIONID')      -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
,    ard.line_id  -- ref_line_id
,    decode(adj.type, 'TAX', ard.tax_code_id, taxx.vat_tax_id)
,    decode(adj.type, 'TAX', ard.location_segment_id, taxx.location_segment_id)
FROM ar_adjustments   adj,
     ar_distributions ard,
     ( select customer_trx_id, vat_tax_id, location_segment_id
       from ra_customer_trx_lines
       where customer_trx_id = p_trx_id
       and line_type = 'LINE'
       and rownum = 1
     ) taxx,
     (SELECT MAX(ref_customer_trx_id) ref_customer_trx_id,
             MAX(to_currency)         invoice_currency_code
       FROM  ra_ar_gt
       WHERE gt_id = p_gt_id
       GROUP BY ref_customer_trx_id, to_currency)     trx
WHERE adj.customer_trx_id= p_trx_id
  AND adj.customer_trx_id= trx.ref_customer_trx_id
  AND adj.customer_trx_id= taxx.customer_trx_id(+)
  AND adj.status         = 'A'
  AND adj.postable       = 'Y'
  AND ard.source_table   = 'ADJ'
  AND ard.source_id      = adj.adjustment_id
  AND adj.type           IN  ('LINE','CHARGES','TAX','FREIGHT')
  AND DECODE(
         adj.type, 'LINE',DECODE(ard.source_type,
                         'ADJ','Y',
                         'TAX','Y',
                         'DEFERRED_TAX','Y',
                         'ADJ_NON_REC_TAX','Y','N'),
                   'CHARGES',DECODE(ard.source_type,
                            'FINCHRG','Y','N'),
                   'TAX',DECODE(ard.source_type,
                         'TAX','Y',
                         'DEFERRED_TAX','Y',
                         'ADJ','Y',
                         'ADJ_NON_REC_TAX','Y','N'),
                   'FREIGHT',DECODE(ard.source_type,
                             'ADJ','Y','N'),
                   'N')  = 'Y';

ELSIF p_mode = 'BATCH' THEN

   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     --{Taxable Amount
     tax_link_id,
     tax_inc_flag,
     --}
     ref_line_id,
     tax_code_id,
     location_segment_id
     )
SELECT
   p_gt_id                                          -- GT_ID
,  NVL(ard.amount_cr,0)
        - NVL(ard.amount_dr,0)                      -- AMT
,  NVL(ard.acctd_amount_cr,0)
        - NVL(ard.acctd_amount_dr,0)                -- ACCTD_AMT
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ','REV',
                               'TAX','TAX',
                      'DEFERRED_TAX','TAX',
                   'ADJ_NON_REC_TAX','TAX','REV'),
            'TAX' ,DECODE(ard.source_type,'TAX','TAX',
                               'ADJ','TAX',
                      'DEFERRED_TAX','TAX',
                   'ADJ_NON_REC_TAX','TAX','TAX'),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              'FREIGHT','FREIGHT'),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              'CHARGES','CHARGES'),
            'REV')                                 -- ACCOUNT_CLASS
,  ard.code_combination_id                        -- CCID_SECONDARY
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ',-6,
                               'TAX',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-6),
            'TAX' ,DECODE(ard.source_type,'TAX',-8,
                               'ADJ',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-8),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              -9,-9),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              -7,-7),
            -6)                                    -- REF_CUST_TRX_LINE_GL_DIST_ID
,  DECODE(adj.type,
            'LINE',DECODE(ard.source_type,'ADJ',-6,
                               'TAX',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-6),
            'TAX' ,DECODE(ard.source_type,'TAX',-8,
                               'ADJ',-8,
                      'DEFERRED_TAX',-8,
                   'ADJ_NON_REC_TAX',-8,-8),
            'FREIGHT' ,DECODE(ard.source_type,'ADJ',
                              -9,-9),
            'CHARGES',DECODE(ard.source_type,'FINCHRG',
                              -7,-7),
            -6)                                    -- REF_CUSTOMER_TRX_LINE_ID
,  adj.customer_trx_id                             -- REF_CUSTOMER_TRX_ID
,  trx.invoice_currency_code                       -- TO_CURRENCY
,  NULL                      -- BASE_CURRENCY
  -- ADJ and APP Elmt
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                 'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_AMT
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ACCTD_AMT
   --
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
								   'ADJ',   (NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_CHRG_AMT
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
								   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_CHRG_ACCTD_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_FRT_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_FRT_ACCTD_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_TAX_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_TAX_ACCTD_AMT
  -- Buc
,     0          -- tl_alloc_amt
,     0    -- tl_alloc_acctd_amt
,     0          -- tl_chrg_alloc_amt
,     0    -- tl_chrg_alloc_acctd_amt
,     0           -- tl_frt_alloc_amt
,     0     -- tl_frt_alloc_acctd_amt
,     0           -- tl_tax_alloc_amt
,     0     -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                 'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_AMT
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_ACCTD_AMT
   --
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_chrg_AMT
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_chrg_ACCTD_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_frt_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_frt_ACCTD_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_ed_tax_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_ed_tax_ACCTD_AMT
--,     0      -- DIST_ed_AMT
--,     0      -- DIST_ed_ACCTD_AMT
--,     0      -- DIST_ed_chrg_AMT
--,     0      -- DIST_ed_chrg_ACCTD_AMT
--,     0      -- DIST_ed_frt_AMT
--,     0      -- DIST_ed_frt_ACCTD_AMT
--,     0      -- DIST_ed_tax_AMT
--,     0      -- DIST_ed_tax_ACCTD_AMT
     --
,     0      -- tl_ed_alloc_amt
,     0      -- tl_ed_alloc_acctd_amt
,     0      -- tl_ed_chrg_alloc_amt
,     0      -- tl_ed_chrg_alloc_acctd_amt
,     0      -- tl_ed_frt_alloc_amt
,     0      -- tl_ed_frt_alloc_acctd_amt
,     0      -- tl_ed_tax_alloc_amt
,     0      -- tl_ed_tax_alloc_acctd_amt

  -- UNED
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                 'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_AMT
,  DECODE(adj.type,'LINE', DECODE(ard.source_type,
                                'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_ACCTD_AMT
   --
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_chrg_AMT
,  DECODE(adj.type,'CHARGES',DECODE(ard.source_type,
                                   'FINCHRG',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_chrg_ACCTD_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_frt_AMT
,  DECODE(adj.type,'FREIGHT',DECODE(ard.source_type,
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_frt_ACCTD_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'ADJ',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.amount_cr,0)-NVL(ard.amount_dr,0)),0),
                           0)                      -- DIST_uned_tax_AMT
,  DECODE(adj.type,'TAX',  DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'ADJ',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                   'LINE', DECODE(ard.source_type,
                                   'TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                'ADJ_NON_REC_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),
                                   'DEFERRED_TAX',(NVL(ard.acctd_amount_cr,0)-NVL(ard.acctd_amount_dr,0)),0),
                           0)                      -- DIST_uned_tax_ACCTD_AMT
--,     0      -- DIST_uned_AMT
--,     0      -- DIST_uned_ACCTD_AMT
--,     0      -- DIST_uned_chrg_AMT
--,     0      -- DIST_uned_chrg_ACCTD_AMT
--,     0      -- DIST_uned_frt_AMT
--,     0      -- DIST_uned_frt_ACCTD_AMT
--,     0      -- DIST_uned_tax_AMT
--,     0      -- DIST_uned_tax_ACCTD_AMT
     --
,     0      -- tl_uned_alloc_amt
,     0      -- tl_uned_alloc_acctd_amt
,     0      -- tl_uned_chrg_alloc_amt
,     0      -- tl_uned_chrg_alloc_acctd_amt
,     0      -- tl_uned_frt_alloc_amt
,     0      -- tl_uned_frt_alloc_acctd_amt
,     0      -- tl_uned_tax_alloc_amt
,     0      -- tl_uned_tax_alloc_acctd_amt
     --
,    ard.source_type      -- source_type
,    ard.source_table     -- source_table
,    ard.source_id        -- source_id
,    DECODE(adj.type,
          'LINE',DECODE(ard.source_type,'ADJ','LINE',
                                        'TAX','TAX',
                               'DEFERRED_TAX','TAX','LINE'),
           'TAX','TAX',
          'CHARGES','CHARGES',
          'FREIGHT','FREIGHT', 'LINE')      -- line_type
     --
,    NULL                                   -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    adj.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')      -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
,    ard.line_id  -- ref_line_id
,    ard.tax_code_id
,    ard.location_segment_id
  FROM ar_adjustments_all                               adj,
       ar_distributions_all                             ard,
       ar_system_parameters_all                         ars,
       (SELECT MAX(ref_customer_trx_id) ref_customer_trx_id,
               MAX(to_currency)         invoice_currency_code
         FROM  ra_ar_gt
         GROUP BY ref_customer_trx_id, to_currency)     trx
 WHERE adj.customer_trx_id = trx.ref_customer_trx_id
   AND adj.status          = 'A'
   AND adj.postable        = 'Y'
   AND adj.upgrade_method  = '11I'
   AND adj.adjustment_id   = ard.source_id
   AND ard.source_table    = 'ADJ'
   AND adj.type           IN  ('LINE','CHARGES','TAX','FREIGHT')
   AND adj.org_id          = ars.org_id
   AND ars.accounting_method = 'CASH'
   AND DECODE(adj.type, 'LINE',DECODE(ard.source_type,
                         'ADJ','Y',
                         'TAX','Y',
                         'DEFERRED_TAX','Y',
                         'ADJ_NON_REC_TAX','Y','N'),
                   'CHARGES',DECODE(ard.source_type,
                            'FINCHRG','Y',
							'ADJ','Y','N'),
                   'TAX',DECODE(ard.source_type,
                         'TAX','Y',
                         'DEFERRED_TAX','Y',
                         'ADJ','Y',
                         'ADJ_NON_REC_TAX','Y','N'),
                   'FREIGHT',DECODE(ard.source_type,
                             'ADJ','Y','N'),
                   'N')  = 'Y';
END IF;
log('get_direct_adj_dist -');
EXCEPTION
WHEN OTHERS THEN
  log('EXCEPTION OTHERS: get_direct_adj_dist :'||SQLERRM);
END get_direct_adj_dist;





--HYU probably no longer usefull
PROCEDURE get_direct_mf_adj_dist
  (p_mode                 IN VARCHAR2,
   p_gt_id                IN NUMBER  DEFAULT NULL)
IS
BEGIN
log('get_direct_mf_adj_dist +');
log('  p_mode  : '||p_mode);
log('  p_gt_id : '||p_gt_id);

IF p_mode = 'BATCH' THEN
   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     --{Taxable Amount
     tax_link_id,
     tax_inc_flag,
     --}
     ref_line_id,
     ref_mf_dist_flag
     )
SELECT
   p_gt_id                           -- GT_ID
,  NVL(psad.amount,0)                -- AMT
,  NVL(psad.amount,0)                -- ACCTD_AMT
,  ctlgd.account_class               -- ACCOUNT_CLASS
,  psad.mf_adjustment_ccid           -- CCID_SECONDARY
,  ctlgd.cust_trx_line_gl_dist_id    -- REF_CUST_TRX_LINE_GL_DIST_ID
,  ctl.customer_trx_line_id          -- REF_CUSTOMER_TRX_LINE_ID
,  ctlgd.customer_trx_id             -- REF_CUSTOMER_TRX_ID
,  trx.invoice_currency_code         -- TO_CURRENCY
,  NULL                              -- BASE_CURRENCY
  -- ADJ and APP Elmt
,  DECODE(ctl.line_type,'LINE', NVL(psad.amount,0),0)     -- DIST_AMT
,  DECODE(ctl.line_type,'LINE', NVL(psad.amount,0),0)     -- DIST_ACCTD_AMT
   -- PSA 11i Charges adj are prorated over all distributions
,  NVL(psad.amount,0)                                     -- DIST_CHRG_AMT
,  NVL(psad.amount,0)                                     -- DIST_CHRG_ACCTD_AMT
,  DECODE(ctl.line_type,'FREIGHT',NVL(psad.amount,0),0)   -- DIST_FRT_AMT
,  DECODE(ctl.line_type,'FREIGHT',NVL(psad.amount,0),0)   -- DIST_FRT_ACCTD_AMT
,  DECODE(ctl.line_type,'TAX'    ,NVL(psad.amount,0),0)   -- DIST_TAX_AMT
,  DECODE(ctl.line_type,'TAX'    ,NVL(psad.amount,0),0)   -- DIST_TAX_ACCTD_AMT
  -- Buc
,     0          -- tl_alloc_amt
,     0    -- tl_alloc_acctd_amt
,     0          -- tl_chrg_alloc_amt
,     0    -- tl_chrg_alloc_acctd_amt
,     0           -- tl_frt_alloc_amt
,     0     -- tl_frt_alloc_acctd_amt
,     0           -- tl_tax_alloc_amt
,     0     -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     0      -- DIST_ed_AMT
,     0      -- DIST_ed_ACCTD_AMT
,     0      -- DIST_ed_chrg_AMT
,     0      -- DIST_ed_chrg_ACCTD_AMT
,     0      -- DIST_ed_frt_AMT
,     0      -- DIST_ed_frt_ACCTD_AMT
,     0      -- DIST_ed_tax_AMT
,     0      -- DIST_ed_tax_ACCTD_AMT
     --
,     0      -- tl_ed_alloc_amt
,     0      -- tl_ed_alloc_acctd_amt
,     0      -- tl_ed_chrg_alloc_amt
,     0      -- tl_ed_chrg_alloc_acctd_amt
,     0      -- tl_ed_frt_alloc_amt
,     0      -- tl_ed_frt_alloc_acctd_amt
,     0      -- tl_ed_tax_alloc_amt
,     0      -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,     0      -- DIST_uned_AMT
,     0      -- DIST_uned_ACCTD_AMT
,     0      -- DIST_uned_chrg_AMT
,     0      -- DIST_uned_chrg_ACCTD_AMT
,     0      -- DIST_uned_frt_AMT
,     0      -- DIST_uned_frt_ACCTD_AMT
,     0      -- DIST_uned_tax_AMT
,     0      -- DIST_uned_tax_ACCTD_AMT
     --
,     0      -- tl_uned_alloc_amt
,     0      -- tl_uned_alloc_acctd_amt
,     0      -- tl_uned_chrg_alloc_amt
,     0      -- tl_uned_chrg_alloc_acctd_amt
,     0      -- tl_uned_frt_alloc_amt
,     0      -- tl_uned_frt_alloc_acctd_amt
,     0      -- tl_uned_tax_alloc_amt
,     0      -- tl_uned_tax_alloc_acctd_amt
     --
,    adj.type                 -- source_type
,    'ADJ'                    -- source_table
,    adj.adjustment_id        -- source_id
,    ctl.line_type            -- line_type
     --
,    NULL                                   -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    adj.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')      -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
,    NULL      -- ref_line_id
,    'Y'       -- REF_MF_DIST_FLAG
  FROM ar_adjustments_all                               adj,
       psa_mf_adj_dist_all                              psad,
       (SELECT MAX(ref_customer_trx_id) ref_customer_trx_id,
               MAX(to_currency)         invoice_currency_code
         FROM  ra_ar_gt
         GROUP BY ref_customer_trx_id, to_currency)     trx,
       ra_customer_trx_lines_all                        ctl,
       ra_cust_trx_line_gl_dist_all                     ctlgd
 WHERE adj.customer_trx_id = trx.ref_customer_trx_id
   AND adj.status          = 'A'
   AND adj.postable        = 'Y'
   AND adj.upgrade_method        = '11IMFAR'
   AND adj.type           IN  ('LINE','CHARGES','TAX','FREIGHT','INVOICE')
   AND adj.adjustment_id   = psad.adjustment_id
   AND psad.cust_trx_line_gl_dist_id = ctlgd.cust_trx_line_gl_dist_id
   AND ctlgd.customer_trx_line_id = ctl.customer_trx_line_id;
END IF;
log('get_direct_mf_adj_dist -');
EXCEPTION
WHEN OTHERS THEN
  log('EXCEPTION OTHERS: get_direct_mf_adj_dist :'||SQLERRM);
END get_direct_mf_adj_dist;








PROCEDURE get_direct_inv_adj_dist
  (p_mode                 IN VARCHAR2,
   p_trx_id               IN NUMBER  DEFAULT NULL,
   p_gt_id                IN NUMBER  DEFAULT NULL)
IS
BEGIN
log('get_direct_inv_adj_dist +');
log('   p_mode   : '|| p_mode);
log('   p_trx_id : '|| p_trx_id);
log('   p_gt_id  : '|| p_gt_id);

IF p_mode = 'BATCH' THEN
   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     --{Taxable Amount
     tax_link_id,
     tax_inc_flag,
     --}
     ref_line_id
     )
SELECT
   p_gt_id                                       -- GT_ID
,  NVL(adj.amount,0)                             -- AMT
,  NVL(adj.acctd_amount,0)                       -- ACCTD_AMT
,  'INVOICE'                                     -- ACCOUNT_CLASS
,  adj.code_combination_id                       -- CCID_SECONDARY
,  -10                                           -- REF_CUST_TRX_LINE_GL_DIST_ID
,  -10                                           -- REF_CUSTOMER_TRX_LINE_ID
,  adj.customer_trx_id                           -- REF_CUSTOMER_TRX_ID
,  trx.invoice_currency_code                     -- TO_CURRENCY
,  NULL                                          -- BASE_CURRENCY
  -- ADJ and APP Elmt
,  NVL(adj.line_adjusted,0)                      -- DIST_AMT
,  fct_acct_amt(NVL(adj.line_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_ACCTD_AMT
   --
,  NVL(adj.receivables_charges_adjusted,0)       -- DIST_CHRG_AMT
,  fct_acct_amt(NVL(adj.receivables_charges_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_CHRG_ACCTD_AMT
,  NVL(adj.freight_adjusted,0)                   -- DIST_FRT_AMT
,  fct_acct_amt(NVL(adj.freight_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_FRT_ACCTD_AMT
,  NVL(adj.tax_adjusted,0)                       -- DIST_TAX_AMT
,  fct_acct_amt(NVL(adj.tax_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_TAX_ACCTD_AMT
  -- Buc
,     0          -- tl_alloc_amt
,     0          -- tl_alloc_acctd_amt
,     0          -- tl_chrg_alloc_amt
,     0          -- tl_chrg_alloc_acctd_amt
,     0          -- tl_frt_alloc_amt
,     0          -- tl_frt_alloc_acctd_amt
,     0          -- tl_tax_alloc_amt
,     0          -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     0      -- DIST_ed_AMT
,     0      -- DIST_ed_ACCTD_AMT
,     0      -- DIST_ed_chrg_AMT
,     0      -- DIST_ed_chrg_ACCTD_AMT
,     0      -- DIST_ed_frt_AMT
,     0      -- DIST_ed_frt_ACCTD_AMT
,     0      -- DIST_ed_tax_AMT
,     0      -- DIST_ed_tax_ACCTD_AMT
     --
,     0      -- tl_ed_alloc_amt
,     0      -- tl_ed_alloc_acctd_amt
,     0      -- tl_ed_chrg_alloc_amt
,     0      -- tl_ed_chrg_alloc_acctd_amt
,     0      -- tl_ed_frt_alloc_amt
,     0      -- tl_ed_frt_alloc_acctd_amt
,     0      -- tl_ed_tax_alloc_amt
,     0      -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,     0      -- DIST_uned_AMT
,     0      -- DIST_uned_ACCTD_AMT
,     0      -- DIST_uned_chrg_AMT
,     0      -- DIST_uned_chrg_ACCTD_AMT
,     0      -- DIST_uned_frt_AMT
,     0      -- DIST_uned_frt_ACCTD_AMT
,     0      -- DIST_uned_tax_AMT
,     0      -- DIST_uned_tax_ACCTD_AMT
     --
,     0      -- tl_uned_alloc_amt
,     0      -- tl_uned_alloc_acctd_amt
,     0      -- tl_uned_chrg_alloc_amt
,     0      -- tl_uned_chrg_alloc_acctd_amt
,     0      -- tl_uned_frt_alloc_amt
,     0      -- tl_uned_frt_alloc_acctd_amt
,     0      -- tl_uned_tax_alloc_amt
,     0      -- tl_uned_tax_alloc_acctd_amt
     --
,    'INVOICE'            -- source_type
,    'ADJ'                -- source_table
,    adj.adjustment_id    -- source_id
,    'INVOICE'            -- line_type
     --
,    NULL                 -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    adj.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')      -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
,    NULL -- ref_line_id
FROM ar_adjustments_all                                         adj,
     ar_system_parameters_all                                   ars,
--  For performance this sql is not nec as for legacy data
--  we are proposing no tied by to original line
--  in new transaction the ref_line_id will be present
--     (SELECT MAX(line_id)       line_id,
--             source_id          source_id
--        FROM ar_distributions_all
--       WHERE source_table = 'ADJ'
--       GROUP BY source_id)                                      ard,
     (SELECT MAX(ref_customer_trx_id)    ref_customer_trx_id,
             MAX(to_currency)            invoice_currency_code
        FROM ra_ar_gt
       WHERE source_table = 'CTLGD'
       GROUP BY ref_customer_trx_id,
                to_currency)                                    trx,
     gl_sets_of_books                                           sob
WHERE adj.customer_trx_id = trx.ref_customer_trx_id
  AND adj.type            = 'INVOICE'
  AND adj.status          = 'A'
  AND adj.postable        = 'Y'
  AND adj.set_of_books_id = sob.set_of_books_id
  AND adj.org_id          = ars.org_id
  AND ars.accounting_method = 'CASH';
--  AND adj.adjustment_id   = ard.source_id;


ELSIF p_mode = 'OLTP' THEN


   INSERT INTO RA_AR_GT
   ( GT_ID                       ,
     AMT                         ,
     ACCTD_AMT                   ,
     ACCOUNT_CLASS               ,
     CCID_SECONDARY              ,
     REF_CUST_TRX_LINE_GL_DIST_ID,
     REF_CUSTOMER_TRX_LINE_ID    ,
     REF_CUSTOMER_TRX_ID         ,
     TO_CURRENCY                 ,
     BASE_CURRENCY               ,
  -- ADJ and APP Elmt
     DIST_AMT                    ,
     DIST_ACCTD_AMT              ,
     DIST_CHRG_AMT               ,
     DIST_CHRG_ACCTD_AMT         ,
     DIST_FRT_AMT                ,
     DIST_FRT_ACCTD_AMT          ,
     DIST_TAX_AMT                ,
     DIST_TAX_ACCTD_AMT          ,
     -- Buc
       tl_alloc_amt          ,
       tl_alloc_acctd_amt    ,
       tl_chrg_alloc_amt     ,
       tl_chrg_alloc_acctd_amt,
       tl_frt_alloc_amt     ,
       tl_frt_alloc_acctd_amt,
       tl_tax_alloc_amt     ,
       tl_tax_alloc_acctd_amt,
  -- ED Elmt
     DIST_ed_AMT,
     DIST_ed_ACCTD_AMT,
     DIST_ed_chrg_AMT,
     DIST_ed_chrg_ACCTD_AMT,
     DIST_ed_frt_AMT      ,
     DIST_ed_frt_ACCTD_AMT,
     DIST_ed_tax_AMT      ,
     DIST_ed_tax_ACCTD_AMT,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
  -- UNED
     DIST_uned_AMT              ,
     DIST_uned_ACCTD_AMT        ,
     DIST_uned_chrg_AMT         ,
     DIST_uned_chrg_ACCTD_AMT   ,
     DIST_uned_frt_AMT          ,
     DIST_uned_frt_ACCTD_AMT    ,
     DIST_uned_tax_AMT          ,
     DIST_uned_tax_ACCTD_AMT    ,
     --
     tl_uned_alloc_amt          ,
     tl_uned_alloc_acctd_amt    ,
     tl_uned_chrg_alloc_amt     ,
     tl_uned_chrg_alloc_acctd_amt,
     tl_uned_frt_alloc_amt     ,
     tl_uned_frt_alloc_acctd_amt,
     tl_uned_tax_alloc_amt     ,
     tl_uned_tax_alloc_acctd_amt,
     --
     source_type               ,
     source_table              ,
     source_id                 ,
     line_type,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     --
     set_of_books_id,
     sob_type,
     se_gt_id,
     --{Taxable Amount
     tax_link_id,
     tax_inc_flag,
     --}
     ref_line_id
     )
SELECT
   p_gt_id                                       -- GT_ID
,  NVL(adj.amount,0)                             -- AMT
,  NVL(adj.acctd_amount,0)                       -- ACCTD_AMT
,  'INVOICE'                                     -- ACCOUNT_CLASS
,  adj.code_combination_id                       -- CCID_SECONDARY
,  -10                                           -- REF_CUST_TRX_LINE_GL_DIST_ID
,  -10                                           -- REF_CUSTOMER_TRX_LINE_ID
,  adj.customer_trx_id                           -- REF_CUSTOMER_TRX_ID
,  trx.invoice_currency_code                     -- TO_CURRENCY
,  NULL                                          -- BASE_CURRENCY
  -- ADJ and APP Elmt
,  NVL(adj.line_adjusted,0)                      -- DIST_AMT
,  fct_acct_amt(NVL(adj.line_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_ACCTD_AMT
   --
,  NVL(adj.receivables_charges_adjusted,0)       -- DIST_CHRG_AMT
,  fct_acct_amt(NVL(adj.receivables_charges_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_CHRG_ACCTD_AMT
,  NVL(adj.freight_adjusted,0)                   -- DIST_FRT_AMT
,  fct_acct_amt(NVL(adj.freight_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_FRT_ACCTD_AMT
,  NVL(adj.tax_adjusted,0)                       -- DIST_TAX_AMT
,  fct_acct_amt(NVL(adj.tax_adjusted,0),
                NVL(adj.amount,0),
                NVL(adj.acctd_amount,0),
                trx.invoice_currency_code,
                sob.currency_code,
                adj.adjustment_id)               -- DIST_TAX_ACCTD_AMT
  -- Buc
,     0          -- tl_alloc_amt
,     0          -- tl_alloc_acctd_amt
,     0          -- tl_chrg_alloc_amt
,     0          -- tl_chrg_alloc_acctd_amt
,     0          -- tl_frt_alloc_amt
,     0          -- tl_frt_alloc_acctd_amt
,     0          -- tl_tax_alloc_amt
,     0          -- tl_tax_alloc_acctd_amt
  -- ED Elmt
,     0      -- DIST_ed_AMT
,     0      -- DIST_ed_ACCTD_AMT
,     0      -- DIST_ed_chrg_AMT
,     0      -- DIST_ed_chrg_ACCTD_AMT
,     0      -- DIST_ed_frt_AMT
,     0      -- DIST_ed_frt_ACCTD_AMT
,     0      -- DIST_ed_tax_AMT
,     0      -- DIST_ed_tax_ACCTD_AMT
     --
,     0      -- tl_ed_alloc_amt
,     0      -- tl_ed_alloc_acctd_amt
,     0      -- tl_ed_chrg_alloc_amt
,     0      -- tl_ed_chrg_alloc_acctd_amt
,     0      -- tl_ed_frt_alloc_amt
,     0      -- tl_ed_frt_alloc_acctd_amt
,     0      -- tl_ed_tax_alloc_amt
,     0      -- tl_ed_tax_alloc_acctd_amt
  -- UNED
,     0      -- DIST_uned_AMT
,     0      -- DIST_uned_ACCTD_AMT
,     0      -- DIST_uned_chrg_AMT
,     0      -- DIST_uned_chrg_ACCTD_AMT
,     0      -- DIST_uned_frt_AMT
,     0      -- DIST_uned_frt_ACCTD_AMT
,     0      -- DIST_uned_tax_AMT
,     0      -- DIST_uned_tax_ACCTD_AMT
     --
,     0      -- tl_uned_alloc_amt
,     0      -- tl_uned_alloc_acctd_amt
,     0      -- tl_uned_chrg_alloc_amt
,     0      -- tl_uned_chrg_alloc_acctd_amt
,     0      -- tl_uned_frt_alloc_amt
,     0      -- tl_uned_frt_alloc_acctd_amt
,     0      -- tl_uned_tax_alloc_amt
,     0      -- tl_uned_tax_alloc_acctd_amt
     --
,    'INVOICE'            -- source_type
,    'ADJ'                -- source_table
,    adj.adjustment_id    -- source_id
,    'INVOICE'            -- line_type
     --
,    NULL                 -- group_id
,    '00'     -- source_data_key1
,    '00'     -- source_data_key2
,    '00'     -- source_data_key3
,    '00'     -- source_data_key4
,    '00'     -- source_data_key5
,    'D'      -- gp_level
     --
,    adj.set_of_books_id  -- set_of_books_id
,    'P'                  -- sob_type
,    USERENV('SESSIONID')      -- se_gt_id
,    NULL      -- tax_link_id
,    NULL      -- tax_inc_flag
,    NULL  -- ref_line_id
FROM ar_adjustments                                      adj,
     ar_system_parameters_all                            ars,
     (SELECT MAX(ref_customer_trx_id) ref_customer_trx_id,
             MAX(to_currency)         invoice_currency_code
       FROM  ra_ar_gt
       WHERE gt_id = p_gt_id
       GROUP BY ref_customer_trx_id, to_currency)        trx,
     gl_sets_of_books                                    sob
WHERE adj.customer_trx_id = p_trx_id
  AND adj.customer_trx_id = trx.ref_customer_trx_id
  AND adj.type            = 'INVOICE'
  AND adj.status          = 'A'
  AND adj.postable        = 'Y'
  AND adj.upgrade_method        = '11I'
  AND adj.set_of_books_id = sob.set_of_books_id
  AND adj.org_id          = ars.org_id
  AND ars.accounting_method = 'CASH';


END IF;
log('get_direct_inv_adj_dist -');
EXCEPTION
WHEN OTHERS THEN
   log('EXCEPTION OTHERS: get_direct_inv_adj_dist :'||SQLERRM);
END get_direct_inv_adj_dist;








PROCEDURE update_base
(p_gt_id    IN NUMBER DEFAULT NULL)
IS
BEGIN
log('update_base +');
--populate the base amounts
INSERT INTO ar_base_dist_amts_gt
(   gt_id,
    gp_level,
    ref_customer_trx_id ,
    ref_customer_trx_line_id,
    base_dist_amt           ,
    base_dist_acctd_amt     ,
    base_dist_chrg_amt           ,
    base_dist_chrg_acctd_amt     ,
    base_dist_frt_amt           ,
    base_dist_frt_acctd_amt     ,
    base_dist_tax_amt           ,
    base_dist_tax_acctd_amt     ,

    base_ed_dist_amt           ,
    base_ed_dist_acctd_amt     ,
    base_ed_dist_chrg_amt      ,
    base_ed_dist_chrg_acctd_amt,
    base_ed_dist_frt_amt       ,
    base_ed_dist_frt_acctd_amt ,
    base_ed_dist_tax_amt       ,
    base_ed_dist_tax_acctd_amt ,

    base_uned_dist_amt,
    base_uned_dist_acctd_amt,
    base_uned_dist_chrg_amt,
    base_uned_dist_chrg_acctd_amt,
    base_uned_dist_frt_amt,
    base_uned_dist_frt_acctd_amt,
    base_uned_dist_tax_amt,
    base_uned_dist_tax_acctd_amt,
    set_of_books_id,
    sob_type,
    source_table,
    source_type
)
SELECT DISTINCT
       a.gt_id,
       a.gp_level,
       a.ref_customer_trx_id ,
       a.ref_customer_trx_line_id,

       s.sum_dist_amt,
       s.sum_dist_acctd_amt,
       s.sum_dist_chrg_amt,
       s.sum_dist_chrg_acctd_amt,
       s.sum_dist_frt_amt,
       s.sum_dist_frt_acctd_amt,
       s.sum_dist_tax_amt,
       s.sum_dist_tax_acctd_amt,
       --
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_acctd_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_chrg_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_chrg_acctd_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_frt_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_frt_acctd_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_tax_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_ed_tax_acctd_amt,0),
--	       --
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_acctd_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_chrg_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_chrg_acctd_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_frt_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_frt_acctd_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_tax_amt,0),
--       DECODE(a.source_table,'CTLGD',s.sum_dist_uned_tax_acctd_amt,0),

       s.sum_dist_ed_amt,
       s.sum_dist_ed_acctd_amt,
       s.sum_dist_ed_chrg_amt,
       s.sum_dist_ed_chrg_acctd_amt,
       s.sum_dist_ed_frt_amt,
       s.sum_dist_ed_frt_acctd_amt,
       s.sum_dist_ed_tax_amt,
       s.sum_dist_ed_tax_acctd_amt,
       --
       s.sum_dist_uned_amt,
       s.sum_dist_uned_acctd_amt,
       s.sum_dist_uned_chrg_amt,
       s.sum_dist_uned_chrg_acctd_amt,
       s.sum_dist_uned_frt_amt,
       s.sum_dist_uned_frt_acctd_amt,
       s.sum_dist_uned_tax_amt,
       s.sum_dist_uned_tax_acctd_amt,

       a.set_of_books_id,
       a.sob_type,
       a.source_table,
       a.source_type
  FROM (SELECT
        SUM(NVL(b.DIST_AMT,0))                 sum_dist_amt ,
        SUM(NVL(b.DIST_ACCTD_AMT,0))           sum_dist_acctd_amt,
        SUM(NVL(b.DIST_CHRG_AMT,0))            sum_dist_chrg_amt,
        SUM(NVL(b.DIST_CHRG_ACCTD_AMT,0))      sum_dist_chrg_acctd_amt,
        SUM(NVL(b.DIST_FRT_AMT,0))             sum_dist_frt_amt,
        SUM(NVL(b.DIST_FRT_ACCTD_AMT,0))       sum_dist_frt_acctd_amt,
        SUM(NVL(b.DIST_TAX_AMT,0))             sum_dist_tax_amt,
        SUM(NVL(b.DIST_TAX_ACCTD_AMT,0))       sum_dist_tax_acctd_amt,
        --
        SUM(NVL(b.DIST_ed_AMT,0))              sum_dist_ed_amt,
        SUM(NVL(b.DIST_ed_ACCTD_AMT,0))        sum_dist_ed_acctd_amt,
        SUM(NVL(b.DIST_ed_chrg_AMT,0))         sum_dist_ed_chrg_amt,
        SUM(NVL(b.DIST_ed_chrg_ACCTD_AMT,0))   sum_dist_ed_chrg_acctd_amt,
        SUM(NVL(b.DIST_ed_frt_AMT,0))          sum_dist_ed_frt_amt,
        SUM(NVL(b.DIST_ed_frt_ACCTD_AMT,0))    sum_dist_ed_frt_acctd_amt,
        SUM(NVL(b.DIST_ed_tax_AMT,0))          sum_dist_ed_tax_amt,
        SUM(NVL(b.DIST_ed_tax_ACCTD_AMT,0))    sum_dist_ed_tax_acctd_amt,
        --
        SUM(NVL(b.DIST_uned_AMT,0))            sum_dist_uned_amt,
        SUM(NVL(b.DIST_uned_ACCTD_AMT,0))      sum_dist_uned_acctd_amt,
        SUM(NVL(b.DIST_uned_chrg_AMT,0))       sum_dist_uned_chrg_amt,
        SUM(NVL(b.DIST_uned_chrg_ACCTD_AMT,0)) sum_dist_uned_chrg_acctd_amt,
        SUM(NVL(b.DIST_uned_frt_AMT,0))        sum_dist_uned_frt_amt,
        SUM(NVL(b.DIST_uned_frt_ACCTD_AMT,0))  sum_dist_uned_frt_acctd_amt,
        SUM(NVL(b.DIST_uned_tax_AMT,0))        sum_dist_uned_tax_amt,
        SUM(NVL(b.DIST_uned_tax_ACCTD_AMT,0))  sum_dist_uned_tax_acctd_amt,
        b.ref_customer_trx_id                  ref_customer_trx_id,
        b.gt_id                                gt_id
      FROM ra_ar_gt b
     GROUP BY b.ref_customer_trx_id,
              b.gt_id )      s,
     ra_ar_gt a
WHERE a.ref_customer_trx_id = s.ref_customer_trx_id
  AND a.gt_id               = s.gt_id
  AND a.gt_id               = NVL(p_gt_id,a.gt_id);

log('update_base -');
EXCEPTION
WHEN OTHERS THEN
   log('EXCEPTION OTHERS: update_base :'||SQLERRM);
END update_base;







PROCEDURE create_distributions
IS
 l_cash_post           VARCHAR2(1) := 'N';
 l_mfar_post           VARCHAR2(1) := 'N';

-- MFAR full upgraded to ARD this routine not used
FUNCTION is_mfar_post
RETURN VARCHAR2
IS
  CURSOR c1 IS
    SELECT app.receivable_application_id
    FROM xla_events_gt                   evt,
         ar_receivable_applications_all  app
    WHERE evt.event_type_code IN ('RECP_CREATE'      ,'RECP_UPDATE'      ,
                                 'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                                 'CM_CREATE'        ,'CM_UPDATE')
      AND evt.event_id        = app.event_id
      AND app.status          = 'APP'
      AND app.upgrade_method  IS NULL
      AND EXISTS (SELECT '1'
                    FROM ar_adjustments_all                                adj
                  WHERE adj.customer_trx_id = app.applied_customer_trx_id
                    AND adj.upgrade_method        = '11IMFAR'
                    AND adj.status          = 'A'
                    AND adj.postable        = 'Y')
  MINUS -- This is to avoid corrupted data. In the case the same invoice has MF and none MF adjustment
        -- theorically impossible
    SELECT app.receivable_application_id
    FROM xla_events_gt                   evt,
         ar_receivable_applications_all  app
    WHERE evt.event_type_code IN ('RECP_CREATE'      ,'RECP_UPDATE'      ,
                                 'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                                 'CM_CREATE'        ,'CM_UPDATE')
      AND evt.event_id        = app.event_id
      AND app.status          = 'APP'
      AND app.upgrade_method        IS NULL
      AND EXISTS (SELECT '1'
                    FROM ar_adjustments_all                                adj
                  WHERE adj.customer_trx_id = app.applied_customer_trx_id
                    AND adj.upgrade_method        = '11I'
                    AND adj.status          = 'A'
                    AND adj.postable        = 'Y');


  l_res    VARCHAR2(1);
  l_ra_id  NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 INTO l_ra_id;
  IF c1%NOTFOUND THEN
    l_res := 'N';
  ELSE
    l_res := 'Y';
  END IF;
  CLOSE c1;
  RETURN l_res;
END is_mfar_post;


FUNCTION is_cash_post
RETURN VARCHAR2
IS
  CURSOR c1 IS
    SELECT app.receivable_application_id
    FROM xla_events_gt                   evt,
         ar_receivable_applications_all  app,
         ar_system_parameters_all        ars
    WHERE evt.event_type_code IN ('RECP_CREATE'     ,'RECP_UPDATE'      ,
                                 'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                                 'CM_CREATE'        ,'CM_UPDATE')
      AND evt.event_id          = app.event_id
      AND app.status            = 'APP'
      AND app.upgrade_method    IS NULL
      AND app.org_id            = ars.org_id
      AND ars.accounting_method = 'CASH'
      AND EXISTS (SELECT '1'
                    FROM ar_adjustments_all                                adj
                  WHERE adj.customer_trx_id = app.applied_customer_trx_id
                    AND adj.upgrade_method        = '11I'
                    AND adj.status          = 'A'
                    AND adj.postable        = 'Y');
  l_res    VARCHAR2(1);
  l_ra_id  NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 INTO l_ra_id;
  IF c1%NOTFOUND THEN
    l_res := 'N';
  ELSE
    l_res := 'Y';
  END IF;
  CLOSE c1;
  RETURN l_res;
END is_cash_post;

BEGIN
log('create_distributions +');

  l_cash_post  := is_cash_post;
  IF l_cash_post = 'Y' THEN
    create_cash_distributions;
  END IF;

-- Mfar post might be obsolete as AR will migrate all MFAR data into ar_distributions
-- As all MFAR data into ar_distributions
--  l_mfar_post := is_mfar_post;
--  IF l_mfar_post = 'Y' THEN
--    create_mfar_distributions;
--  END IF;


log('create_distributions -');
EXCEPTION
  WHEN OTHERS THEN
     log(  'EXCEPTION OTHERS Create_distributions: '||SQLERRM);
     RAISE;
END Create_distributions;









PROCEDURE create_cash_distributions
IS
  l_sob_id			NUMBER;
  l_accounting_method           ar_system_parameters.accounting_method%TYPE;
  l_create_acct                 VARCHAR2(1) := 'Y';
  l_gt_id                       NUMBER := 0;

  CURSOR c_app IS
  SELECT app.*
  FROM xla_events_gt                   evt,
       ar_receivable_applications_all  app,
       ar_system_parameters_all        ars
  WHERE evt.event_type_code IN ( 'RECP_CREATE'      ,'RECP_UPDATE' ,
                                 'RECP_RATE_ADJUST' ,'RECP_REVERSE',
                                 'CM_CREATE'        ,'CM_UPDATE' )
   AND evt.event_id             = app.event_id
   AND app.status               = 'APP'
   AND app.upgrade_method       IS NULL
   AND app.org_id               = ars.org_id
   AND ars.accounting_method    = 'CASH'
   AND NOT EXISTS (SELECT '1'
                     FROM psa_trx_types_all   psa,
                          ra_customer_trx_all inv
                    WHERE inv.customer_trx_id  = app.applied_customer_trx_id
                      AND inv.cust_trx_type_id = psa.psa_trx_type_id);
/*
-- Only to reconcile for CMAPP the applied to transaction
-- as the from cm can not have been adjusted
-- and in cash basis we only need to post applications
-- which is on the to document
  CURSOR c_cm_from_app IS
  SELECT app.*
  FROM xla_events_gt                   evt,
       ar_receivable_applications_all  app,
       ar_system_parameters_all        ars
  WHERE evt.event_type_code IN ('CM_CREATE','CM_UPDATE')
    AND evt.event_id        = app.event_id
    AND app.status          = 'APP'
    AND app.upgrade_method  IS NULL
    AND app.org_id               = ars.org_id
    AND ars.accounting_method    = 'CASH'
    AND NOT EXISTS (SELECT '1'
                     FROM psa_trx_types_all   psa,
                          ra_customer_trx_all inv
                    WHERE inv.customer_trx_id  = app.customer_trx_id
                      AND inv.cust_trx_type_id = psa.psa_trx_type_id);
*/
 l_app_rec             ar_receivable_applications%ROWTYPE;
 l_line_acctd_amt      NUMBER;
 l_tax_acctd_amt       NUMBER;
 l_frt_acctd_amt       NUMBER;
 l_chrg_acctd_amt      NUMBER;
 l_ed_line_acctd_amt   NUMBER;
 l_ed_tax_acctd_amt    NUMBER;
 l_ed_frt_acctd_amt    NUMBER;
 l_ed_chrg_acctd_amt   NUMBER;
 l_ued_line_acctd_amt  NUMBER;
 l_ued_tax_acctd_amt   NUMBER;
 l_ued_frt_acctd_amt   NUMBER;
 l_ued_chrg_acctd_amt  NUMBER;
 dummy                 VARCHAR2(1);
 l_ra_list             DBMS_SQL.NUMBER_TABLE;
 erase_ra_list         DBMS_SQL.NUMBER_TABLE;
 i                     NUMBER := 0;
 end_process_stop      EXCEPTION;



BEGIN
log('create_cash_distributions +');


   DELETE FROM ra_ar_gt;

   -- Get the distributions ready
   get_direct_inv_dist(p_mode   => 'BATCH');

   get_direct_adj_dist(p_mode   => 'BATCH');

   get_direct_inv_adj_dist(p_mode => 'BATCH');

   update_base;

   -- Cash Basis
   OPEN c_app;
   LOOP

     FETCH c_app INTO l_app_rec;
     EXIT WHEN c_app%NOTFOUND;

     Init_Curr_Details(p_sob_id            => l_app_rec.set_of_books_id,
                       p_org_id            => l_app_rec.org_id,
                       x_accounting_method => l_accounting_method);

     fnd_client_info.set_currency_context(g_ae_sys_rec.set_of_books_id);

     l_gt_id        :=  l_gt_id + 1;

      -- proration
      arp_det_dist_pkg.prepare_for_ra
      (  p_gt_id                => l_gt_id,
         p_app_rec              => l_app_rec,
         p_ae_sys_rec           => g_ae_sys_rec,
         p_inv_cm               => 'I',
         p_cash_mfar            => 'CASH');

     arp_standard.debug(  'setting the currency context back to null');
     fnd_client_info.set_currency_context(NULL);

   END LOOP;
   CLOSE c_app;


   -- For the from document CM
--   OPEN c_cm_from_app;
--   LOOP
--     FETCH c_cm_from_app INTO l_app_rec;
--     EXIT WHEN c_app%NOTFOUND;
--     Init_Curr_Details(p_sob_id            => l_app_rec.set_of_books_id,
--                       p_org_id            => l_app_rec.org_id,
--                       x_accounting_method => l_accounting_method);
--     fnd_client_info.set_currency_context(g_ae_sys_rec.set_of_books_id);
--     l_gt_id        :=  l_gt_id + 1;
      -- proration
--      arp_det_dist_pkg.prepare_for_ra
--      (  p_gt_id                => l_gt_id,
--         p_app_rec              => l_app_rec,
--         p_ae_sys_rec           => g_ae_sys_rec,
--         p_inv_cm               => 'C',
--         p_cash_mfar            => 'CASH');
--     arp_standard.debug(  'setting the currency context back to null');
--     fnd_client_info.set_currency_context(NULL);
--   END LOOP;
--   CLOSE c_cm_from_app;

   -- Stamping the CASH applications
   stamping_11i_app_post;


log('create_cash_distributions -');
EXCEPTION
  WHEN OTHERS THEN
     log(  'EXCEPTION OTHERS Create_cash_distributions: '||SQLERRM);
     RAISE;
END Create_cash_distributions;








/*
PROCEDURE create_mfar_distributions
IS
  l_sob_id			NUMBER;
  l_accounting_method           ar_system_parameters.accounting_method%TYPE;
  l_create_acct                 VARCHAR2(1) := 'Y';
  l_gt_id                       NUMBER := 0;

  CURSOR c_app IS
  SELECT app.*
  FROM xla_events_gt                   evt,
       ar_receivable_applications_all  app
  WHERE evt.event_type_code IN ( 'RECP_CREATE'      ,'RECP_UPDATE' ,
                                 'RECP_RATE_ADJUST' ,'RECP_REVERSE',
                                 'CM_CREATE'        ,'CM_UPDATE' )
   AND evt.event_id        = app.event_id
   AND app.status          = 'APP'
   AND app.upgrade_method        IS NULL
   AND EXISTS (SELECT '1' FROM ar_adjustments_all adj
               WHERE adj.customer_trx_id = app.applied_customer_trx_id
                 AND adj.upgrade_method        = '11IMFAR'
                 AND adj.status          = 'A'
                 AND adj.postable        = 'Y')
  MINUS
  SELECT app.*
  FROM xla_events_gt                   evt,
       ar_receivable_applications_all  app
  WHERE evt.event_type_code IN ( 'RECP_CREATE'      ,'RECP_UPDATE' ,
                                 'RECP_RATE_ADJUST' ,'RECP_REVERSE',
                                 'CM_CREATE'        ,'CM_UPDATE' )
   AND evt.event_id        = app.event_id
   AND app.status          = 'APP'
   AND app.upgrade_method        IS NULL
   AND EXISTS (SELECT '1' FROM ar_adjustments_all adj
               WHERE adj.customer_trx_id = app.applied_customer_trx_id
                 AND adj.upgrade_method        = '11I'
                 AND adj.status          = 'A'
                 AND adj.postable        = 'Y');


  CURSOR c_cm_from_app IS
  SELECT app.*
  FROM xla_events_gt                   evt,
       ar_receivable_applications_all  app
  WHERE evt.event_type_code IN ('CM_CREATE','CM_UPDATE')
    AND evt.event_id        = app.event_id
    AND app.status          = 'APP'
    AND app.upgrade_method        IS NULL
    AND EXISTS (SELECT '1' FROM ar_adjustments_all adj
                 WHERE adj.customer_trx_id = app.customer_trx_id
                   AND adj.upgrade_method        = '11IMFAR'
                   AND adj.status          = 'A'
                   AND adj.postable        = 'Y')
   MINUS
  SELECT app.*
  FROM xla_events_gt                   evt,
       ar_receivable_applications_all  app
  WHERE evt.event_type_code IN ('CM_CREATE','CM_UPDATE')
    AND evt.event_id        = app.event_id
    AND app.status          = 'APP'
    AND app.upgrade_method        IS NULL
    AND EXISTS (SELECT '1' FROM ar_adjustments_all adj
                 WHERE adj.customer_trx_id = app.customer_trx_id
                   AND adj.upgrade_method        = '11I'
                   AND adj.status          = 'A'
                   AND adj.postable        = 'Y');


 l_app_rec             ar_receivable_applications%ROWTYPE;
 l_line_acctd_amt      NUMBER;
 l_tax_acctd_amt       NUMBER;
 l_frt_acctd_amt       NUMBER;
 l_chrg_acctd_amt      NUMBER;
 l_ed_line_acctd_amt   NUMBER;
 l_ed_tax_acctd_amt    NUMBER;
 l_ed_frt_acctd_amt    NUMBER;
 l_ed_chrg_acctd_amt   NUMBER;
 l_ued_line_acctd_amt  NUMBER;
 l_ued_tax_acctd_amt   NUMBER;
 l_ued_frt_acctd_amt   NUMBER;
 l_ued_chrg_acctd_amt  NUMBER;
 dummy                 VARCHAR2(1);
 l_ra_list             DBMS_SQL.NUMBER_TABLE;
 erase_ra_list         DBMS_SQL.NUMBER_TABLE;
 i                     NUMBER := 0;
 end_process_stop      EXCEPTION;

BEGIN

log('create_mfar_distributions +');


   DELETE FROM ra_ar_gt;

   -- Get the distributions ready
   get_direct_mf_inv_dist(p_mode   => 'BATCH');

   get_direct_mf_adj_dist(p_mode   => 'BATCH');

   update_base;

   -- MFAR basis
   OPEN c_app;
   LOOP

     FETCH c_app INTO l_app_rec;
     EXIT WHEN c_app%NOTFOUND;

     Init_Curr_Details(p_sob_id            => l_app_rec.set_of_books_id,
                       p_org_id            => l_app_rec.org_id,
                       x_accounting_method => l_accounting_method);

     fnd_client_info.set_currency_context(g_ae_sys_rec.set_of_books_id);

     l_gt_id        :=  l_gt_id + 1;

      -- proration
      arp_det_dist_pkg.prepare_for_ra
      (  p_gt_id                => l_gt_id,
         p_app_rec              => l_app_rec,
         p_ae_sys_rec           => g_ae_sys_rec,
         p_inv_cm               => 'I',
         p_cash_mfar            => 'MFAR');

     arp_standard.debug(  'setting the currency context back to null');
     fnd_client_info.set_currency_context(NULL);

   END LOOP;
   CLOSE c_app;

   -- For the from document CM
   OPEN c_cm_from_app;
   LOOP

     FETCH c_cm_from_app INTO l_app_rec;
     EXIT WHEN c_app%NOTFOUND;

     Init_Curr_Details(p_sob_id            => l_app_rec.set_of_books_id,
                       p_org_id            => l_app_rec.org_id,
                       x_accounting_method => l_accounting_method);

     fnd_client_info.set_currency_context(g_ae_sys_rec.set_of_books_id);

     l_gt_id        :=  l_gt_id + 1;

      -- proration
      arp_det_dist_pkg.prepare_for_ra
      (  p_gt_id                => l_gt_id,
         p_app_rec              => l_app_rec,
         p_ae_sys_rec           => g_ae_sys_rec,
         p_inv_cm               => 'C',
         p_cash_mfar            => 'MFAR');


     arp_standard.debug(  'setting the currency context back to null');
     fnd_client_info.set_currency_context(NULL);

   END LOOP;
   CLOSE c_cm_from_app;

   -- Stamping the MFAR applications
   stamping_11i_mfar_app_post;

log('create_mfar_distributions -');
EXCEPTION
  WHEN OTHERS THEN
     log(  'EXCEPTION OTHERS Create_mfar_distributions: '||SQLERRM);
     RAISE;
END Create_mfar_distributions;
*/













---------------------------------------
-- PROCEDURE COMPARE_RA_REM_AMT
---------------------------------------
-- Arguments Input
--  p_app_rec         IN  ar_receivable_applications%ROWTYPE -- the application record initial
--  p_app_level       IN  VARCHAR2 DEFAULT 'TRANSACTION'     -- level of application
--  p_group_id        IN  VARCHAR2 DEFAULT NULL              -- if level = GROUP then which group
--  p_ctl_id          IN  NUMBER   DEFAULT NULL              -- if level = LINE then which line
--  p_currency        IN  VARCHAR2                           -- transactional currency
--------------
-- Outputs
--  x_app_rec         OUT NOCOPY ar_receivable_applications%ROWTYPE -- after leasing the result app_rec
--  x_return_status   IN OUT NOCOPY VARCHAR2
--  x_msg_data        IN OUT NOCOPY VARCHAR2
--  x_msg_count       IN OUT NOCOPY NUMBER
--------------
-- Objective:
--  When does a application on a 11i MFAR transaction, the amount allocated per bucket can in disconcordance
--  with the remaining amounts stamped in AR on the transaction because
--  AR tied the charges and freight adjusted to revenue line
--  but PSA tied the freight to freight line
--  prorate the charges on all lines
--  Therefore  remaining amount calculated by AR can not the same from PSA
--  For legacy transaction originate by PSA, in the upgrade AR should ensure:
--  * the overall amount remaining all buckets and application all buckets are not incompatible
--    that is no overapplication
--  * the ED UNED bucket are not mixed with the application buckets
--  * but the disconcordance between the rem and the application amount per bucket will be
--    handled by the amount applied bucket
----------------------------------------
PROCEDURE COMPARE_RA_REM_AMT
( p_app_rec         IN         ar_receivable_applications%ROWTYPE,
  x_app_rec         OUT NOCOPY ar_receivable_applications%ROWTYPE,
  p_app_level       IN         VARCHAR2 DEFAULT 'TRANSACTION',
  p_source_data_key1 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key2 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key3 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key4 IN         VARCHAR2 DEFAULT NULL,
  p_source_data_key5 IN         VARCHAR2 DEFAULT NULL,
  p_ctl_id           IN         NUMBER   DEFAULT NULL,
  p_currency         IN         VARCHAR2,
  x_return_status    IN OUT NOCOPY VARCHAR2,
  x_msg_data         IN OUT NOCOPY VARCHAR2,
  x_msg_count        IN OUT NOCOPY NUMBER)
IS
  l_line_rem        NUMBER;
  l_tax_rem         NUMBER;
  l_freight_rem     NUMBER;
  l_chrg_rem        NUMBER;

  l_chrg_app        NUMBER;
  l_chrg_ed         NUMBER;
  l_chrg_uned       NUMBER;
  l_chrg_entire     NUMBER;

  l_freight_app       NUMBER;
  l_freight_ed        NUMBER;
  l_freight_uned      NUMBER;
  l_freight_entire    NUMBER;

  l_tax_app           NUMBER;
  l_tax_ed            NUMBER;
  l_tax_uned          NUMBER;
  l_tax_entire        NUMBER;

  l_line_app          NUMBER;
  l_line_ed           NUMBER;
  l_line_uned         NUMBER;
  l_line_entire       NUMBER;

  l_entire            NUMBER;
  l_rem               NUMBER;

  l_new_line_entire     NUMBER;
  l_new_tax_entire      NUMBER;
  l_new_freight_entire  NUMBER;
  l_new_chrg_entire     NUMBER;

  l_run_rem         NUMBER := 0;
  l_line_apps       NUMBER := 0;
  l_run_apps        NUMBER := 0;
  l_tax_apps        NUMBER := 0;
  l_freight_apps    NUMBER := 0;
  l_chrg_apps       NUMBER := 0;
  over_applications     EXCEPTION;


BEGIN
  arp_standard.debug('COMPARE_RA_REM_AMT +');

  x_app_rec := p_app_rec;

  ARP_DET_DIST_PKG.get_latest_amount_remaining
   (p_customer_trx_id => p_app_rec.applied_customer_trx_id,
    p_app_level       => p_app_level,
    p_source_data_key1=> p_source_data_key1,
    p_source_data_key2=> p_source_data_key2,
    p_source_data_key3=> p_source_data_key3,
    p_source_data_key4=> p_source_data_key4,
    p_source_data_key5=> p_source_data_key5,
    p_ctl_id          => p_ctl_id,
    x_line_rem        => l_line_rem,
    x_tax_rem         => l_tax_rem,
    x_freight_rem     => l_freight_rem,
    x_charges_rem     => l_chrg_rem,
    x_return_status   => x_return_status,
    x_msg_data        => x_msg_data,
    x_msg_count       => x_msg_count);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  l_chrg_app     := NVL(p_app_rec.receivables_charges_applied,0);
  l_chrg_ed      := NVL(p_app_rec.charges_ediscounted,0);
  l_chrg_uned    := NVL(p_app_rec.charges_uediscounted,0);
  l_chrg_entire  := l_chrg_app + l_chrg_ed + l_chrg_uned;

  l_freight_app  := NVL(p_app_rec.freight_applied,0);
  l_freight_ed   := NVL(p_app_rec.freight_ediscounted,0);
  l_freight_uned := NVL(p_app_rec.freight_uediscounted,0);
  l_freight_entire  := l_freight_app + l_freight_ed + l_freight_uned;

  l_tax_app      := NVL(p_app_rec.tax_applied,0);
  l_tax_ed       := NVL(p_app_rec.tax_ediscounted,0);
  l_tax_uned     := NVL(p_app_rec.tax_uediscounted,0);
  l_tax_entire   := l_tax_app + l_tax_ed + l_tax_uned;

  l_line_app     := NVL(p_app_rec.line_applied,0);
  l_line_ed      := NVL(p_app_rec.line_ediscounted,0);
  l_line_uned    := NVL(p_app_rec.line_uediscounted,0);
  l_line_entire  := l_line_app + l_line_ed + l_line_uned;

  --
  l_entire := l_chrg_entire + l_freight_entire + l_tax_entire + l_line_entire;
  l_rem    := l_chrg_rem    + l_freight_rem    + l_tax_rem    + l_line_rem;
  --

  arp_standard.debug('  l_chrg_app :'||l_chrg_app);
  arp_standard.debug('  l_chrg_ed  :'||l_chrg_ed);
  arp_standard.debug('  l_chrg_uned:'||l_chrg_uned);

  arp_standard.debug('  l_freight_app :'||l_freight_app);
  arp_standard.debug('  l_freight_ed  :'||l_freight_ed);
  arp_standard.debug('  l_freight_uned:'||l_freight_uned);

  arp_standard.debug('  l_tax_app :'||l_tax_app);
  arp_standard.debug('  l_tax_ed  :'||l_tax_ed);
  arp_standard.debug('  l_tax_uned:'||l_tax_uned);

  arp_standard.debug('  l_line_app :'||l_line_app);
  arp_standard.debug('  l_line_ed  :'||l_line_ed);
  arp_standard.debug('  l_line_uned:'||l_line_uned);

  arp_standard.debug('  Sum of all the bucket of the application       :'||l_entire);
  arp_standard.debug('  Sum of all the remaining bucket on transaction :'||l_rem);


  --
  -- We should verify that all rem are less or equal to the all buckets of the application
  -- Otherwise this is a abnormal situation as it means overapplication
  --
  IF l_entire > l_rem THEN
    arp_standard.debug('  SUM_ALL_APP_BUCKET > SUM_ALL_REM_BUCKET - Overapplication');
    RAISE over_applications;
  END IF;

  --
  --Prorate sum of apps over rem
  --
  arp_standard.debug('  l_run_rem :'||l_run_rem);
  arp_standard.debug('  l_line_rem :'||l_line_rem);

   l_run_rem  := l_run_rem + l_line_rem;

   l_line_apps :=  arpcurr.CurrRound(  l_run_rem
                                            / l_rem
                                            * l_entire,
                                            p_currency)
                                         - l_run_apps;

   l_run_apps :=  l_run_apps + l_line_apps;

  arp_standard.debug('  l_line_apps :'||l_line_apps);
  arp_standard.debug('  l_run_apps :'||l_run_apps);

   --

  arp_standard.debug('  l_run_rem :'||l_run_rem);
  arp_standard.debug('  l_tax_rem :'||l_tax_rem);

   l_run_rem  := l_run_rem + l_tax_rem;

   l_tax_apps :=  arpcurr.CurrRound(  l_run_rem
                                            / l_rem
                                            * l_entire,
                                            p_currency)
                                         - l_run_apps;


   l_run_apps :=  l_run_apps + l_tax_apps;

  arp_standard.debug('  l_tax_apps :'||l_tax_apps);
  arp_standard.debug('  l_run_apps :'||l_run_apps);

   --
  arp_standard.debug('  l_run_rem :'||l_run_rem);
  arp_standard.debug('  l_freight_rem :'||l_freight_rem);

   l_run_rem  := l_run_rem + l_freight_rem;

   l_freight_apps :=  arpcurr.CurrRound(  l_run_rem
                                            / l_rem
                                            * l_entire,
                                            p_currency)
                                         - l_run_apps;


   l_run_apps :=  l_run_apps + l_freight_apps;

  arp_standard.debug('  l_freight_apps :'||l_freight_apps);
  arp_standard.debug('  l_run_apps :'||l_run_apps);
   --
  arp_standard.debug('  l_run_rem :'||l_run_rem);
  arp_standard.debug('  l_chrg_rem :'||l_chrg_rem);

   l_run_rem  := l_run_rem + l_chrg_rem;

   l_chrg_apps :=  arpcurr.CurrRound(  l_run_rem
                                            / l_rem
                                            * l_entire,
                                            p_currency)
                                         - l_run_apps;


   l_run_apps :=  l_run_apps + l_chrg_apps;

  arp_standard.debug('  l_chrg_apps :'||l_chrg_apps);
  arp_standard.debug('  l_run_apps :'||l_run_apps);

   IF l_line_apps <> l_line_entire THEN
      l_line_apps := l_line_apps - l_line_ed - l_line_uned;
   END IF;

   IF l_tax_apps <> l_tax_entire THEN
      l_tax_apps := l_tax_apps - l_tax_ed - l_tax_uned;
   END IF;

   IF l_freight_apps <> l_freight_entire THEN
      l_freight_apps := l_freight_apps - l_freight_ed - l_freight_uned;
   END IF;

   IF l_chrg_apps <> l_chrg_entire THEN
      l_chrg_apps := l_chrg_apps - l_chrg_ed - l_chrg_uned;
   END IF;

   x_app_rec.LINE_APPLIED               := l_line_apps;
   x_app_rec.TAX_APPLIED                := l_tax_apps;
   x_app_rec.FREIGHT_APPLIED            := l_freight_apps;
   x_app_rec.RECEIVABLES_CHARGES_APPLIED:= l_chrg_apps;
  arp_standard.debug('COMPARE_RA_REM_AMT -');

EXCEPTION
 WHEN   over_applications   THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'EXCEPTION over_applications in ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT
sum amount remaining from the invoice:'||l_rem ||'
sum of application buckets           :'||l_entire );
    FND_MSG_PUB.ADD;
    arp_standard.debug('EXCEPTION fnd_api.g_exc_error - over applications ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT
sum amount remaining from the invoice:'||l_rem ||'
sum of application buckets           :'||l_entire );
 WHEN   fnd_api.g_exc_error   THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'EXCEPTION fnd_api.g_exc_error in ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT' );
    FND_MSG_PUB.ADD;
    arp_standard.debug('EXCEPTION fnd_api.g_exc_error - fnd_api.g_exc_error ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT');
 WHEN   OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', 'EXCEPTION - OTHERS ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT: '||SQLERRM );
    FND_MSG_PUB.ADD;
    arp_standard.debug('EXCEPTION - OTHERS ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT: '||SQLERRM);
END COMPARE_RA_REM_AMT;






PROCEDURE stamping_11i_mfar_app_post
IS
BEGIN
arp_standard.debug('stamping_11i_mfar_app_post +');
  UPDATE ar_receivable_applications_all ra
  SET ra.upgrade_method = 'R12_11IMFAR_POST'
  WHERE ra.receivable_application_id IN (
    SELECT app.receivable_application_id
      FROM xla_events_gt                 evt,
           ar_receivable_applications_all  app
     WHERE evt.event_type_code IN ('RECP_CREATE'      ,'RECP_UPDATE'      ,
                                  'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                                  'CM_CREATE'        ,'CM_UPDATE')
       AND evt.event_id        = app.event_id
       AND app.status          = 'APP'
       AND app.upgrade_method        IS NULL
       AND EXISTS (SELECT '1'
                     FROM ar_adjustments_all                                adj
                    WHERE adj.customer_trx_id = app.applied_customer_trx_id
                      AND adj.upgrade_method        = '11IMFAR'
                      AND adj.status          = 'A'
                      AND adj.postable        = 'Y')
     MINUS
    SELECT app.receivable_application_id
      FROM xla_events_gt                 evt,
           ar_receivable_applications_all  app
     WHERE evt.event_type_code IN ('RECP_CREATE'      ,'RECP_UPDATE'      ,
                                  'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                                  'CM_CREATE'        ,'CM_UPDATE')
       AND evt.event_id        = app.event_id
       AND app.status          = 'APP'
       AND app.upgrade_method        IS NULL
       AND EXISTS (SELECT '1'
                     FROM ar_adjustments_all                                adj
                    WHERE adj.customer_trx_id = app.applied_customer_trx_id
                      AND adj.upgrade_method        = '11I'
                      AND adj.status          = 'A'
                      AND adj.postable        = 'Y')
                      );
arp_standard.debug('stamping_11i_mfar_app_post -');
EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug('EXCEPTION OTHERS : stamping_11i_mfar_app_post :' || SQLERRM);
    RAISE;
END stamping_11i_mfar_app_post;



PROCEDURE stamping_11i_cash_app_post
IS
BEGIN
arp_standard.debug('stamping_11i_cash_app_post +');
  UPDATE ar_receivable_applications_all ra
  SET ra.upgrade_method = 'R12_11ICASH_POST'
  WHERE ra.receivable_application_id IN (
    SELECT app.receivable_application_id
      FROM xla_events_gt                   evt,
           ar_receivable_applications_all  app
     WHERE evt.event_type_code IN ( 'RECP_CREATE'      ,'RECP_UPDATE'      ,
                                    'RECP_RATE_ADJUST' ,'RECP_REVERSE'     ,
                                    'CM_CREATE'        ,'CM_UPDATE')
       AND evt.event_id        = app.event_id
       AND app.status          = 'APP'
       AND app.upgrade_method        IS NULL
--       AND app.cash_receipt_id = cr.cash_receipt_id(+)
       AND EXISTS (SELECT '1'
                     FROM ar_adjustments_all                                adj
                    WHERE adj.customer_trx_id = app.applied_customer_trx_id
                      AND adj.upgrade_method        = '11I'
                      AND adj.status          = 'A'
                      AND adj.postable        = 'Y'));
arp_standard.debug('stamping_11i_cash_app_post -');
EXCEPTION
  WHEN OTHERS THEN
    arp_standard.debug('EXCEPTION OTHERS : stamping_11i_mfar_app_post :' || SQLERRM);
    RAISE;
END stamping_11i_cash_app_post;






---------------------------------------
-- PROCEDURE portion_to_move
---------------------------------------
-- Calculate the portion to move from the total to each bucket
--  based on the ratio argument
--  for example:
--   total to move = 15
--     freight ratio = 10
--     tax ratio     = 20
--     line ratio    = 40
--     chrg ratio    = 80
--     ---
--     freight_portion to move = 1
--     tax_portion to move = 2
--     line_portion to move = 4
--     chrg_portion to move = 8
----------------------------------------
PROCEDURE portion_to_move
(p_total_to_move     IN NUMBER,
 p_freight_ratio     IN NUMBER  DEFAULT 0,
 p_tax_ratio         IN NUMBER  DEFAULT 0,
 p_line_ratio        IN NUMBER  DEFAULT 0,
 p_chrg_ratio        IN NUMBER  DEFAULT 0,
 p_currency          IN VARCHAR2,
 x_freight_portion   OUT NOCOPY NUMBER,
 x_tax_portion       OUT NOCOPY NUMBER,
 x_line_portion      OUT NOCOPY NUMBER,
 x_chrg_portion      OUT NOCOPY NUMBER)
IS
    l_sum_base        NUMBER := 0;
    l_run_ratio       NUMBER := 0;
    l_run_portion     NUMBER := 0;
    l_freight_ratio   NUMBER := 0;
    l_tax_ratio       NUMBER := 0;
    l_line_ratio      NUMBER := 0;
    l_chrg_ratio      NUMBER := 0;
    l_total_to_move   NUMBER := 0;
    l_line_portion    NUMBER;
    l_tax_portion     NUMBER;
    l_freight_portion NUMBER;
    l_chrg_portion    NUMBER;
BEGIN
    arp_standard.debug('  portion_to_move +');
    arp_standard.debug('    p_total_to_move  :'|| p_total_to_move);
    arp_standard.debug('    p_freight_ratio  :'|| p_freight_ratio);
    arp_standard.debug('    p_tax_ratio      :'|| p_tax_ratio);
    arp_standard.debug('    p_line_ratio     :'|| p_line_ratio);
    arp_standard.debug('    p_chrg_ratio     :'|| p_chrg_ratio);

    IF (p_total_to_move IS NOT NULL) THEN l_total_to_move := p_total_to_move; END IF;
    IF (p_freight_ratio IS NOT NULL)  THEN l_freight_ratio := p_freight_ratio; END IF;
    IF (p_tax_ratio IS NOT NULL)  THEN l_tax_ratio := p_tax_ratio; END IF;
    IF (p_line_ratio IS NOT NULL) THEN l_line_ratio := p_line_ratio; END IF;
    IF (p_chrg_ratio IS NOT NULL) THEN l_chrg_ratio := p_chrg_ratio; END IF;

    l_sum_base   := l_freight_ratio + l_tax_ratio + l_line_ratio + l_chrg_ratio;

    IF l_total_to_move = 0 THEN
       arp_standard.debug('The amount to move is 0, we return 0 for all portion');
       x_freight_portion   := 0;
       x_tax_portion   := 0;
       x_line_portion  := 0;
       x_chrg_portion  := 0;
    ELSIF  l_sum_base = 0 THEN
       arp_standard.debug('The sum of all ratio is 0, we return 0 for all portion');
       x_freight_portion   := 0;
       x_tax_portion   := 0;
       x_line_portion  := 0;
       x_chrg_portion  := 0;
    ELSE
       --
       l_run_ratio  := l_run_ratio + l_line_ratio;
       l_line_portion  := arpcurr.CurrRound(  l_run_ratio
                                            / l_sum_base
                                            * l_total_to_move,
                                            p_currency)
                                         - l_run_portion;
       l_run_portion := l_run_portion + l_line_portion;
       --
       l_run_ratio  := l_run_ratio + l_tax_ratio;
       l_tax_portion  := arpcurr.CurrRound(  l_run_ratio
                                            / l_sum_base
                                            * l_total_to_move,
                                            p_currency)
                                         - l_run_portion;
       l_run_portion := l_run_portion + l_tax_portion;
       --
       l_run_ratio  := l_run_ratio + l_freight_ratio;
       l_freight_portion  := arpcurr.CurrRound(  l_run_ratio
                                            / l_sum_base
                                            * l_total_to_move,
                                            p_currency)
                                         - l_run_portion;
       l_run_portion := l_run_portion + l_freight_portion;
       --
       l_run_ratio  := l_run_ratio + l_chrg_ratio;
       l_chrg_portion  := arpcurr.CurrRound(  l_run_ratio
                                            / l_sum_base
                                            * l_total_to_move,
                                            p_currency)
                                         - l_run_portion;
       l_run_portion := l_run_portion + l_chrg_portion;
       --
       x_freight_portion   := l_freight_portion;
       x_tax_portion   := l_tax_portion;
       x_line_portion  := l_line_portion;
       x_chrg_portion  := l_chrg_portion;
   END IF;
EXCEPTION
     WHEN OTHERS THEN
       arp_standard.debug('EXCEPTION OTHERS - portion_to_move '||SQLERRM);
       RAISE;
END;

---------------------------------------
-- PROCEDURE move_bucket
---------------------------------------
-- Determine the amount to move and
-- Does the movement of the bucket for bucket originate the movement
-- For example:
--  p_chrg_entire meaning Chrg (ED UNED APP) of an application
--  is greater then the Chrg remaining on the invoice to apply
--  we need to reconcile the surplus amount from the chrg to move
--  to other buckets
--------------
-- Consider we have a surplus of 15 usd of charge to move, so
-- if which bucket = 'CHRG' then 15 usd will be moved to line, tax, freight buckets
-- Consider we have a surplus of 10 usd of freight to move, so
-- if which bucket = 'FREIGHT' then 10 usd will be moved to line, tax buckets
-- Consider we have a surplus of 5 usd of tax to move, so
-- if which bucket = 'TAX' then 5 usd will be moved to line
-- No movement is allowed on LINE bucket the surplus stay in line buckets
---------------
-- The new entire amount by bucket are returned in x_XXX_entire output argument
----------------------------------------
PROCEDURE move_bucket
  (p_line_entire       IN NUMBER,
   p_freight_entire    IN NUMBER,
   p_tax_entire        IN NUMBER,
   p_chrg_entire       IN NUMBER,
   --
   p_line_rem          IN NUMBER,
   p_freight_rem       IN NUMBER,
   p_tax_rem           IN NUMBER,
   p_chrg_rem          IN NUMBER,
   --
   p_which_bucket      IN VARCHAR2,
   p_currency          IN VARCHAR2,
   --
   x_line_entire       OUT NOCOPY NUMBER,
   x_freight_entire    OUT NOCOPY NUMBER,
   x_tax_entire        OUT NOCOPY NUMBER,
   x_chrg_entire       OUT NOCOPY NUMBER)
IS
  --
  l_entire            NUMBER;
  l_rem               NUMBER;
  --
  l_freight_ratio     NUMBER;
  l_tax_ratio         NUMBER;
  l_line_ratio        NUMBER;
  l_chrg_ratio        NUMBER;
  l_freight_portion   NUMBER;
  l_tax_portion       NUMBER;
  l_line_portion      NUMBER;
  l_chrg_portion      NUMBER;
  l_to_move           NUMBER;
  --
  l_line_entire       NUMBER;
  l_freight_entire    NUMBER;
  l_tax_entire        NUMBER;
  l_chrg_entire       NUMBER;
  --
  chrg_rem_greater_chrg_app   EXCEPTION;
  frt_rem_greater_frt_app     EXCEPTION;
  tax_rem_greater_tax_app     EXCEPTION;
  --
BEGIN
  arp_standard.debug('move_bucket +');

  l_line_entire       := p_line_entire;
  l_freight_entire    := p_freight_entire;
  l_tax_entire        := p_tax_entire;
  l_chrg_entire       := p_chrg_entire;

  IF p_which_bucket = 'CHRG' THEN

     l_entire           := p_chrg_entire;
     l_rem              := p_chrg_rem;
     --
     -- no portion to move for charges
     -- the dif between rem_chrg and (APP, ED, UNED Charges) is to be reallocated to line -tax -freight
     --
     l_freight_ratio   := p_freight_entire;
     l_tax_ratio       := p_tax_entire;
     l_line_ratio      := p_line_entire;
     l_chrg_ratio      := 0;

     --
     -- The charges being applied is greater then the remaining on the transaction
     -- This is due to PSA legacy data because the charges adjusted are over all type of line
     -- hence a portion of remaing charges are affected to other buckets such as freight or tax
     --
     IF l_entire > l_rem THEN
       arp_standard.debug('moving portion charges bucket to other line, tax, freight bucket');
       l_to_move     := l_entire  - l_rem;
       l_chrg_entire := l_entire  - l_to_move;
     ELSE
       RAISE chrg_rem_greater_chrg_app;
     END IF;

  ELSIF p_which_bucket = 'FREIGHT' THEN

     l_entire           := p_freight_entire;
     l_rem              := p_freight_rem;
     --
     -- no portion to move for freight and charges
     -- the dif between rem_chrg and (APP, ED, UNED Charges) is to be reallocated to line -tax
     --
     l_freight_ratio   := 0;
     l_tax_ratio       := p_tax_entire;
     l_line_ratio      := p_line_entire;
     l_chrg_ratio      := 0;

     IF l_entire > l_rem THEN
       arp_standard.debug('moving portion freight bucket to line and tax');
       l_to_move        := l_entire  - l_rem;
       l_freight_entire := l_entire  - l_to_move;
     ELSE
       RAISE frt_rem_greater_frt_app;
     END IF;

  ELSIF p_which_bucket = 'TAX' THEN

     l_entire           := p_tax_entire;
     l_rem              := p_tax_rem;
     --
     -- no portion to move for tax, freight and charges
     -- the dif between rem_chrg and (APP, ED, UNED tax) is to be reallocated to line
     --
     l_freight_ratio   := 0;
     l_tax_ratio       := 0;
     l_line_ratio      := p_line_entire;
     l_chrg_ratio      := 0;

     IF l_entire > l_rem THEN
       arp_standard.debug('moving portion tax bucket to other line');
       l_to_move        := l_entire  - l_rem;
       l_tax_entire     := l_entire  - l_to_move;
     ELSE
       RAISE tax_rem_greater_tax_app;
     END IF;

  ELSIF p_which_bucket = 'LINE' THEN

  -- This code do not need to be executed for line
     NULL;

  ELSE

    x_line_entire      := p_line_entire;
    x_freight_entire   := p_freight_entire;
    x_tax_entire       := p_tax_entire;
    x_chrg_entire      := p_chrg_entire;

  END IF;

  IF l_entire > l_rem THEN

     -- logic of charges movement.
     -- Move charge equivalently over line - tax - freight
     arp_standard.debug('  '||p_which_bucket||' to move : '||  l_to_move );

     portion_to_move
      (p_total_to_move    => l_to_move,
       p_freight_ratio    => l_freight_ratio,
       p_tax_ratio        => l_tax_ratio,
       p_line_ratio       => l_line_ratio,
       p_chrg_ratio       => l_chrg_ratio,
       p_currency         => p_currency,
       x_freight_portion  => l_freight_portion,
       x_tax_portion      => l_tax_portion,
       x_line_portion     => l_line_portion,
       x_chrg_portion     => l_chrg_portion);

    x_line_entire    := l_line_entire + l_line_portion;
    x_freight_entire := l_freight_entire + l_freight_portion;
    x_tax_entire     := l_tax_entire + l_tax_portion;
    x_chrg_entire    := l_chrg_entire + l_chrg_portion;

  END IF;
  arp_standard.debug('   x_line_entire    :'|| x_line_entire);
  arp_standard.debug('   x_freight_entire :'|| x_freight_entire);
  arp_standard.debug('   x_tax_entire     :'|| x_tax_entire);
  arp_standard.debug('   x_chrg_entire    :'|| x_chrg_entire);
  arp_standard.debug('move_bucket -');
EXCEPTION
  WHEN chrg_rem_greater_chrg_app   THEN
   x_line_entire      := p_line_entire;
   x_freight_entire   := p_freight_entire;
   x_tax_entire       := p_tax_entire;
   x_chrg_entire      := p_chrg_entire;
   arp_standard.debug('   USER EXCEPTION chrg_rem_greater_chrg_app');
   arp_standard.debug('   x_line_entire    :'|| x_line_entire);
   arp_standard.debug('   x_freight_entire :'|| x_freight_entire);
   arp_standard.debug('   x_tax_entire     :'|| x_tax_entire);
   arp_standard.debug('   x_chrg_entire    :'|| x_chrg_entire);
   arp_standard.debug('move_bucket -');
  WHEN frt_rem_greater_frt_app     THEN
   x_line_entire      := p_line_entire;
   x_freight_entire   := p_freight_entire;
   x_tax_entire       := p_tax_entire;
   x_chrg_entire      := p_chrg_entire;
   arp_standard.debug('   USER EXCEPTION frt_rem_greater_frt_app');
   arp_standard.debug('   x_line_entire    :'|| x_line_entire);
   arp_standard.debug('   x_freight_entire :'|| x_freight_entire);
   arp_standard.debug('   x_tax_entire     :'|| x_tax_entire);
   arp_standard.debug('   x_chrg_entire    :'|| x_chrg_entire);
   arp_standard.debug('move_bucket -');
  WHEN tax_rem_greater_tax_app     THEN
   x_line_entire      := p_line_entire;
   x_freight_entire   := p_freight_entire;
   x_tax_entire       := p_tax_entire;
   x_chrg_entire      := p_chrg_entire;
   arp_standard.debug('   USER EXCEPTION tax_rem_greater_tax_app');
   arp_standard.debug('   x_line_entire    :'|| x_line_entire);
   arp_standard.debug('   x_freight_entire :'|| x_freight_entire);
   arp_standard.debug('   x_tax_entire     :'|| x_tax_entire);
   arp_standard.debug('   x_chrg_entire    :'|| x_chrg_entire);
   arp_standard.debug('move_bucket -');
  WHEN OTHERS THEN
    RAISE;
END;

---------------------------------------
-- PROCEDURE lease_app_bucket_amts
---------------------------------------
-- This a wrapper which will lease the entire application amt buckets
-- based on the remaining of the transaction
--------------
-- For example :
--  The application has
--   ED + UNED + APP for line    - x_line_entire   => 100
--   ED + UNED + APP for freight - x_freight_entire=> 30
--   ED + UNED + APP for tax     - x_tax_entire    => 16
--   ED + UNED + APP for chrg    - x_chrg_entire   => 6
--------------
--  The transaction has remaining
--    on line      p_line_rem          => 200
--    on freight   p_freight_rem       => 30
--    on tax       p_tax_rem           => 15
--    on charges   p_chrg_rem          => 3
----------------
--  sum all rem > sum all entire buckets ==> no over applications - OK
--  The result will be
--   x_line_entire      => 104
--   x_freight_entire   => 30
--   x_tax_entire       => 15
--   x_chrg_entire      => 3
--  Note in this example the surplus from tax and charges are absorbed by line buckets
----------------------------------------
PROCEDURE lease_app_bucket_amts
(p_line_rem          IN NUMBER,
 p_tax_rem           IN NUMBER,
 p_freight_rem       IN NUMBER,
 p_chrg_rem          IN NUMBER,
 --
 p_currency          IN VARCHAR2,
 --
 x_line_entire       IN OUT NOCOPY NUMBER,
 x_tax_entire        IN OUT NOCOPY NUMBER,
 x_freight_entire    IN OUT NOCOPY NUMBER,
 x_chrg_entire       IN OUT NOCOPY NUMBER)
IS
  l_app          NUMBER;
  l_rem          NUMBER;
  l_cur_line     NUMBER;
  l_cur_tax      NUMBER;
  l_cur_freight  NUMBER;
  l_cur_chrg     NUMBER;
  l_tmp_line     NUMBER;
  l_tmp_tax      NUMBER;
  l_tmp_freight  NUMBER;
  l_tmp_chrg     NUMBER;
  l_line_rem     NUMBER;
  l_tax_rem      NUMBER;
  l_freight_rem  NUMBER;
  l_chrg_rem     NUMBER;
  l_bucket       VARCHAR2(30);
  i              NUMBER := 0;
  over_applications  EXCEPTION;

BEGIN
  arp_standard.debug('lease_app_bucket_amts +');
  arp_standard.debug('   p_line_rem   :'|| p_line_rem);
  arp_standard.debug('   p_tax_rem    :'|| p_tax_rem);
  arp_standard.debug('   p_freight_rem:'|| p_freight_rem);
  arp_standard.debug('   p_chrg_rem   :'|| p_chrg_rem);
  arp_standard.debug('   -----------------------------');

  l_cur_line  := NVL(x_line_entire,0);
  l_cur_tax   := NVL(x_tax_entire,0);
  l_cur_freight := NVL(x_freight_entire,0);
  l_cur_chrg  := NVL(x_chrg_entire,0);

  l_line_rem  := NVL(p_line_rem,0);
  l_tax_rem   := NVL(p_tax_rem,0);
  l_freight_rem := NVL(p_freight_rem,0);
  l_chrg_rem  := NVL(p_chrg_rem,0);

  l_app := l_cur_line + l_cur_tax + l_cur_freight + l_cur_chrg;
  l_rem := l_line_rem + l_tax_rem + l_freight_rem + l_chrg_rem;

  IF l_app > l_rem THEN
    RAISE over_applications;
  END IF;

  LOOP

    i := i + 1;

    IF    i = 1 THEN  l_bucket := 'CHRG';
    ELSIF i = 2 THEN  l_bucket := 'FREIGHT';
    ELSIF i = 3 THEN  l_bucket := 'TAX';
    ELSE              l_bucket := 'LINE';
    END IF;

    EXIT WHEN l_bucket = 'LINE';


   move_bucket
   (p_line_entire       => l_cur_line,
    p_freight_entire    => l_cur_freight,
    p_tax_entire        => l_cur_tax,
    p_chrg_entire       => l_cur_chrg,
    --
    p_line_rem          => l_line_rem,
    p_freight_rem       => l_freight_rem,
    p_tax_rem           => l_tax_rem,
    p_chrg_rem          => l_chrg_rem,
    --
    p_which_bucket      => l_bucket,
    p_currency          => p_currency,
    --
    x_line_entire       => l_tmp_line,
    x_freight_entire    => l_tmp_freight,
    x_tax_entire        => l_tmp_tax,
    x_chrg_entire       => l_tmp_chrg);

    l_cur_line    := l_tmp_line;
    l_cur_freight := l_tmp_freight;
    l_cur_tax     := l_tmp_tax;
    l_cur_chrg    := l_tmp_chrg;

 END LOOP;

 x_line_entire       := l_cur_line;
 x_tax_entire        := l_cur_tax;
 x_freight_entire    := l_cur_freight;
 x_chrg_entire       := l_cur_chrg;
 arp_standard.debug('  x_line_app          :'|| l_cur_line);
 arp_standard.debug('  x_tax_app           :'|| l_cur_tax);
 arp_standard.debug('  x_freight_app       :'|| l_cur_freight);
 arp_standard.debug('  x_chrg_app          :'|| l_cur_chrg);
 arp_standard.debug('lease_app_bucket_amts -');

EXCEPTION
 WHEN   over_applications   THEN
    arp_standard.debug('EXCEPTION fnd_api.g_exc_error - over applications ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT
sum amount remaining from the invoice:'||l_rem ||'
sum of application buckets           :'||l_app );

END;

END;

/
