--------------------------------------------------------
--  DDL for Package Body ZX_JG_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_JG_EXTRACT_PKG" AS
/* $Header: zxriextrajgppvtb.pls 120.4.12010000.10 2010/01/29 21:45:44 skorrapa ship $ */

-----------------------------------------
--Public Variable Declarations
-----------------------------------------
--
--  Define Global  Variables;
--

   TYPE numtab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   g_chart_of_accounts_id  NUMBER;
   g_user_id               NUMBER;
   g_today                 DATE;
   g_login_id              NUMBER;
   g_request_id            NUMBER;
   g_balancing_seg         VARCHAR2(30);
   g_acct_seg_from         VARCHAR2(30);
   g_acct_seg_to           VARCHAR2(30);

   TYPE t_acct_all_tbl       IS TABLE OF VARCHAR2(750)  INDEX BY BINARY_INTEGER;
   TYPE t_acct_all_desc_tbl  IS TABLE OF VARCHAR2(7200) INDEX BY BINARY_INTEGER;
   TYPE t_bal_seg_tbl        IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
   TYPE t_bal_seg_desc_tbl   IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
   TYPE t_acct_seg_tbl       IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
   TYPE t_acct_seg_desc_tbl  IS TABLE OF VARCHAR2(240)  INDEX BY BINARY_INTEGER;
   TYPE t_ccid_tbl           IS TABLE OF NUMBER(15)     INDEX BY BINARY_INTEGER;
   TYPE t_acct_date_tbl      IS TABLE OF ZX_REP_ACTG_EXT_T.ACCOUNTING_DATE%TYPE  INDEX BY BINARY_INTEGER;

   g_acct_all_tbl          t_acct_all_tbl;
   g_acct_all_desc_tbl     t_acct_all_desc_tbl;
   g_bal_seg_tbl           t_bal_seg_tbl;
   g_bal_seg_desc_tbl      t_bal_seg_desc_tbl;
   g_acct_seg_tbl          t_acct_seg_tbl;
   g_acct_seg_desc_tbl     t_acct_seg_desc_tbl;

   PG_DEBUG                         VARCHAR2(1);
  g_current_runtime_level           NUMBER ;
  g_level_statement       CONSTANT  NUMBER  := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER  := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER  := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER  := FND_LOG.LEVEL_UNEXPECTED;
  g_error_buffer                    VARCHAR2(100);



 /**
   * Function Name: currency_round
   *
   * This function is for rounding that will be used in tax prorating logic.
   *
   * @return     rounded currency amount
   * @parameter: p_amount
   * @parameter: p_precistion
   * @parameter: p_minimum_accountable_unit
   *
   *
   **/

   FUNCTION currency_round(p_amount                   IN OUT NOCOPY NUMBER,
                           p_precision                IN NUMBER,
                           p_minimum_accountable_unit IN NUMBER)
      RETURN NUMBER
   IS
     l_amount NUMBER;
   BEGIN

     IF 'Y' = PG_DEBUG THEN
       arp_util_tax.debug('zx_jg_extract_pkg.currency_round()+');
     END IF;

     IF p_precision IS NOT NULL THEN
       l_amount := Round(p_amount, p_precision);
     ELSIF p_minimum_accountable_unit IS NOT NULL THEN
       l_amount := Round(p_amount / p_minimum_accountable_unit) * p_minimum_accountable_unit;
     ELSE
       IF 'Y' = PG_DEBUG THEN
         arp_util_tax.debug('EXCEPTION in CURRENCY_ROUND()');
         arp_util_tax.debug('Precision or Minimum Accountable Unit must be NOT NULL');
       END IF;
       RAISE program_error;
     END IF;

     IF 'Y' = PG_DEBUG THEN
       arp_util_tax.debug('zx_jg_extract_pkg.currency_round()-');
     END IF;

     RETURN l_amount;

   END currency_round;


 /**
   * Procedure Name: prorate_tax
   *
   * This procedure prorate tax per taxable account
   * and is called from GET_AR_TAXABLE.
   * Proraction is done for AR Transactions
   *
   *
   * @param    p_tax_total
   * @param    p_tax_funcl_curr_total
   * @param    p_tax_amt_tbl
   * @param    p_tax_amt_funcl_curr_tbl
   * @param    p_minimum_accountable_unit_tbl
   * @param    p_func_precistion_tbl
   * @param    p_func_min_account_unit_tbl
   * @param    p_current_line
   * @param    p_last_line
   **/


   PROCEDURE prorate_tax (
     p_tax_total                    IN NUMBER,
     p_tax_funcl_curr_total         IN NUMBER,
     p_percent_tbl                  IN OUT NOCOPY numtab,
     p_tax_amt_tbl                  IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_TBL,
     p_tax_amt_funcl_curr_tbl       IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL,
     p_precision_tbl                IN OUT NOCOPY numtab,
     p_minimum_accountable_unit_tbl IN OUT NOCOPY numtab,
     p_func_precision               IN NUMBER,
     p_func_min_account_unit        IN NUMBER,
     p_current_line                 IN NUMBER,
     p_last_line                    IN NUMBER)
     IS

  rounderr              NUMBER;
  rounderr_funcl_curr   NUMBER;
  alloc_tax             NUMBER;
  alloc_tax_funcl_curr  NUMBER;
  full_tax              NUMBER;
  full_tax_funcl_curr   NUMBER;

  BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.prorate_tax()+',
         'prorate_tax');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.prorate_tax',
         'prorate_tax='||To_char(p_tax_total)||', Acctd tax='||To_char(p_tax_funcl_curr_total));
    END IF;

    IF p_current_line = p_last_line THEN
      p_tax_amt_tbl(p_current_line) := p_tax_total;
      p_tax_amt_funcl_curr_tbl(p_current_line) := p_tax_funcl_curr_total;
      RETURN;
    END IF;

    rounderr             := 0;
    rounderr_funcl_curr  := 0;
    alloc_tax            := 0;
    alloc_tax_funcl_curr := 0;

    FOR i IN p_current_line..p_last_line-1 LOOP
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.prorate_tax',
           'Percent='||To_char(Round(p_percent_tbl(i)*100, 3))||
           ', Precision='||To_char(p_precision_tbl(i))||
           ', Mimimum Accountable Unit='||To_char(p_minimum_accountable_unit_tbl(i)));
      END IF;

      IF (p_percent_tbl(i) = 0) THEN
        full_tax            := 0;
        full_tax_funcl_curr := 0;
      ELSIF (p_percent_tbl(i) = 100) THEN
        full_tax            := p_tax_total;
        full_tax_funcl_curr := p_tax_funcl_curr_total;
      ELSE
        full_tax            := p_tax_total * p_percent_tbl(i) + rounderr;
        full_tax_funcl_curr := p_tax_funcl_curr_total * p_percent_tbl(i) + rounderr_funcl_curr;
      END IF;

      p_tax_amt_tbl(i)            := currency_round(full_tax, p_precision_tbl(i), p_minimum_accountable_unit_tbl(i));
      p_tax_amt_funcl_curr_tbl(i) := currency_round(full_tax_funcl_curr, p_func_precision, p_func_min_account_unit);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.prorate_tax',
           'Tax Amount='||To_char(p_tax_amt_tbl(i))||', Acctd Tax Amount='||To_char(p_tax_amt_funcl_curr_tbl(i)));
      END IF;

      rounderr             := full_tax - p_tax_amt_tbl(i);
      rounderr_funcl_curr  := full_tax_funcl_curr - p_tax_amt_funcl_curr_tbl(i);

      alloc_tax            := alloc_tax + p_tax_amt_tbl(i);
      alloc_tax_funcl_curr := alloc_tax_funcl_curr + p_tax_amt_funcl_curr_tbl(i);

    END LOOP;

    p_tax_amt_tbl(p_last_line)            := p_tax_total - alloc_tax;
    p_tax_amt_funcl_curr_tbl(p_last_line) := p_tax_funcl_curr_total - alloc_tax_funcl_curr;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.prorate_tax',
         'Tax Amount='||To_char(p_tax_amt_tbl(p_last_line))||', Acctd Tax Amount='||To_char(p_tax_amt_funcl_curr_tbl(p_last_line)));
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.prorate_tax()-',
         'prorate_tax');
    END IF;

  END prorate_tax;



 /**
   * PROCEDURE  Name: insert_row
   *
   + This procedure insert fetched accounting info into zx_rep_actg_ext_t table
   * and calculated tax/taxable amount into zx_rep_trx_jx_ext_t table
   *
   * @parameter: p_detail_tax_line_id_tbl
   * @parameter: p_taxable_amt_tbl
   * @parameter: p_taxable_amt_funcl_curr_tbl
   * @parameter: p_tax_amt_tbl
   * @parameter: p_tax_amt_funcl_curr_tbl
   *
   **/

   PROCEDURE insert_row (
     p_detail_tax_line_id_tbl        IN ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
     p_taxable_amt_tbl               IN ZX_EXTRACT_PKG.TAXABLE_AMT_TBL,
     p_taxable_amt_funcl_curr_tbl    IN ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL,
     p_tax_amt_tbl                   IN ZX_EXTRACT_PKG.TAX_AMT_TBL,
     p_tax_amt_funcl_curr_tbl        IN ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL)

   IS

         count_tbl     numtab;
         j             integer;

   BEGIN

     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.insert_row()+',
          'insert_row API call ');
     END IF;

     j := 0;

     -- Filter the lines by user parameter 'Balancing Segment'
     -- And Account Segment From/To

      /*
       * Insert accounting info to TRL acct ext table
       */
     FOR i in p_detail_tax_line_id_tbl.first..p_detail_tax_line_id_tbl.last LOOP

   /*    IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.insert_row()+',
            'For Loop : ');
       END IF;
   */
       --  IF g_balancing_seg = g_bal_seg_tbl(p_ccid_tbl(i)) AND
       --   g_acct_seg_tbl(p_ccid_tbl(i)) BETWEEN g_acct_seg_from AND g_acct_seg_to THEN

   /*    IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.insert_row()+',
                            'g_balancing_seg : ');
       END IF;
   */
       /*    INSERT INTO ZX_REP_ACTG_EXT_T
            (
               request_id,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login,
               actg_ext_line_id,
               detail_tax_line_id,
               accounting_date,
               trx_taxable_account,
               trx_taxable_account_desc,
               trx_taxable_balancing_segment,
               trx_taxable_balseg_desc,
               trx_taxable_natural_account,
               trx_taxable_natacct_seg_desc
              )
              VALUES
              (
               g_request_id,
               g_user_id,
               g_today,
               g_user_id,
               g_today,
               g_login_id,
               zx_rep_actg_ext_t_s.NEXTVAL,
               p_detail_tax_line_id_tbl(i),
               p_acct_date_tbl(i),
               substrb(g_acct_all_tbl(p_ccid_tbl(i)),1,240),
               g_acct_all_desc_tbl(p_ccid_tbl(i)),
               g_bal_seg_tbl(p_ccid_tbl(i)),
               g_bal_seg_desc_tbl(p_ccid_tbl(i)),
               g_acct_seg_tbl(p_ccid_tbl(i)),
               g_acct_seg_desc_tbl(p_ccid_tbl(i))
              ); */

          /*
           *  Insert Prorated amount into jx ext itf
           */

       INSERT INTO zx_rep_trx_jx_ext_t (
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         detail_tax_line_ext_id,
         detail_tax_line_id,
         numeric1,
         numeric2,
         numeric3,
         numeric4
         )
       VALUES (
         g_request_id,
         g_user_id,
         g_today,
         g_user_id,
         g_today,
         g_login_id,
         zx_rep_trx_jx_ext_t_s.NEXTVAL,
         p_detail_tax_line_id_tbl(i),
         p_taxable_amt_tbl(i),
         p_taxable_amt_funcl_curr_tbl(i),
         p_tax_amt_tbl(i),
         p_tax_amt_funcl_curr_tbl(i)
       );

       --   END IF;
     END LOOP;

     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.insert_row()-',
          'insert_row()-: ');
     END IF;

   EXCEPTION
      WHEN OTHERS THEN

       IF (g_level_procedure >= g_current_runtime_level ) THEN
              FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.insert_row()-',
                            'insert_row(EXCEPTION)- ');
       END IF;
       RAISE;

   END insert_row;

 /*-------------------+
  | Private Procedure |
  +-------------------*/

 /**
   * Procedure Name: initialize
   *
   * @return     none
   * @parameter: p_trl_global_variables_rec
   *
   *
   **/

  PROCEDURE initialize (
    p_trl_global_variables_rec IN         ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE,
    l_func_precision           OUT NOCOPY NUMBER,
    l_func_min_account_unit    OUT NOCOPY NUMBER,
    l_sob_type                 OUT NOCOPY VARCHAR2)
  IS

  BEGIN

    IF 'Y' = PG_DEBUG THEN
      arp_util_tax.debug('zx_jg_extract_pkg.initialize()+');
    END IF;

    g_user_id              := fnd_global.user_id;
    g_today                := sysdate;
    g_login_id             := fnd_global.login_id;
    g_chart_of_accounts_id := p_trl_global_variables_rec.chart_of_accounts_id;
    g_request_id           := p_trl_global_variables_rec.request_id;
    g_balancing_seg        := p_trl_global_variables_rec.balancing_segment_low;
    g_acct_seg_from        := p_trl_global_variables_rec.taxable_account_low;
   -- g_acct_seg_from        := p_trl_global_variables_rec.tax_account_low;
   -- g_acct_seg_to          := p_trl_global_variables_rec.tax_account_high;
    g_acct_seg_to          := p_trl_global_variables_rec.taxable_account_high;

    BEGIN
      SELECT precision,
             minimum_accountable_unit,
             decode(alc_ledger_type_code,'SOURCE','P',
                                         'TARGET','R',
                                         'NONE','N')
       INTO  l_func_precision,
             l_func_min_account_unit,
             l_sob_type
       FROM  gl_ledgers sob,
             fnd_currencies curr
      WHERE sob.ledger_id = p_trl_global_variables_rec.ledger_id
        AND sob.currency_code = curr.currency_code;

      IF 'Y' = PG_DEBUG THEN
        arp_util_tax.debug('zx_jg_extract_pkg.initialize()-');
      END IF;

      EXCEPTION
        WHEN OTHERS THEN
          IF 'Y' = PG_DEBUG THEN
            arp_util_tax.debug('ledger_id = '||p_trl_global_variables_rec.ledger_id);
          END IF;
          RAISE;
      END;

   END initialize;

 /**
   * Procedure Name: set_accounting_info_obsolete
   *
   * This procedure get and cache accounting info using fa_rx_flex_pkg
   *
   * @return     none
   * @parameter: p_ccid_tbl
   *
   *
   **/

   PROCEDURE set_accounting_info_obsolete(p_ccid_tbl  IN t_ccid_tbl)
   IS

   BEGIN
     IF 'Y' = PG_DEBUG THEN
       arp_util_tax.debug('zx_jg_extract_pkg.set_accounting_info()+');
     END IF;

     FOR i in p_ccid_tbl.first..p_ccid_tbl.last LOOP
       IF g_acct_all_tbl.exists(p_ccid_tbl(i)) THEN
         null;
       ELSE
         g_acct_all_tbl(p_ccid_tbl(i)) :=  fa_rx_flex_pkg.get_value(101,
                                                                    'GL#',
                                                                    g_chart_of_accounts_id,
                                                                    'ALL',
                                                                    p_ccid_tbl(i));
       END IF;

       IF g_acct_all_desc_tbl.exists(p_ccid_tbl(i)) THEN
         null;
       ELSE
         g_acct_all_desc_tbl(p_ccid_tbl(i)) :=  fa_rx_flex_pkg.get_description(101,
                                                                               'GL#',
                                                                                g_chart_of_accounts_id,
                                                                               'ALL',
                                                                                g_acct_all_tbl(p_ccid_tbl(i)));
       END IF;

       IF g_bal_seg_tbl.exists(p_ccid_tbl(i)) THEN
         null;
       ELSE
         g_bal_seg_tbl(p_ccid_tbl(i)) :=  fa_rx_flex_pkg.get_value(101,
                                                                   'GL#',
                                                                    g_chart_of_accounts_id,
                                                                   'GL_BALANCING',
                                                                    p_ccid_tbl(i));
       END IF;

       IF g_bal_seg_desc_tbl.exists(p_ccid_tbl(i)) THEN
         null;
       ELSE
         g_bal_seg_desc_tbl(p_ccid_tbl(i)) :=  fa_rx_flex_pkg.get_description(101,
                                                                             'GL#',
                                                                              g_chart_of_accounts_id,
                                                                             'GL_BALANCING',
                                                                              g_bal_seg_tbl(p_ccid_tbl(i)));
       END IF;

       IF g_acct_seg_tbl.exists(p_ccid_tbl(i)) THEN
         null;
       ELSE
         g_acct_seg_tbl(p_ccid_tbl(i)) :=  fa_rx_flex_pkg.get_value(101,
                                                                    'GL#',
                                                                     g_chart_of_accounts_id,
                                                                    'GL_ACCOUNT',
                                                                     p_ccid_tbl(i));
       END IF;

       IF g_acct_seg_desc_tbl.exists(p_ccid_tbl(i)) THEN
         null;
       ELSE
         g_acct_seg_desc_tbl(p_ccid_tbl(i)) := fa_rx_flex_pkg.get_description(101,
                                                                              'GL#',
                                                                               g_chart_of_accounts_id,
                                                                              'GL_ACCOUNT',
                                                                               g_acct_seg_tbl(p_ccid_tbl(i)));
       END IF;

     END LOOP;

     IF 'Y' = PG_DEBUG THEN
        arp_util_tax.debug('zx_jg_extract_pkg.set_accounting_info()-');
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       IF 'Y' = PG_DEBUG THEN
         arp_util_tax.debug('zx_jg_extract_pkg.set_accounting_info(EXCEPTION)-');
       END IF;
       RAISE;

   END set_accounting_info_obsolete;

 /**
   * PROCEDURE  Name: reset_result_tables
   *
   * This procedure reset the cached value of temporary variables
   *
   * @parameter: p_detail_tax_line_id_tbl
   * @parameter: p_trx_id_tbl
   * @parameter: p_tax_line_id_tbl
   * @parameter: p_trx_line_id_tbl
   * @parameter: p_event_class_code_tbl
   * @parameter: p_taxable_amt_tbl
   * @parameter: p_tax_rate_id_tbl
   * @parameter: p_extract_source_ledger_tbl
   * @parameter: p_ledger_id_tbl
   * @parameter: l_detail_tax_line_id_tbl
   * @parameter: l_taxable_amt_tbl
   * @parameter: l_taxable_amt_funcl_curr_tbl
   * @parameter: l_tax_amt_tbl
   * @parameter: l_tax_amt_funcl_curr_tbl
   * @parameter: l_ccid_tbl
   * @parameter: l_acct_date_tbl
   *
   **/

   PROCEDURE reset_result_tables
     (p_detail_tax_line_id_tbl     IN OUT NOCOPY ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
      p_trx_id_tbl                 IN OUT NOCOPY ZX_EXTRACT_PKG.TRX_ID_TBL,
      p_tax_line_id_tbl            IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_LINE_ID_TBL,
      p_trx_line_id_tbl            IN OUT NOCOPY ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
      p_tax_dist_id_tbl            IN OUT NOCOPY ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL,
      p_event_class_code_tbl       IN OUT NOCOPY ZX_EXTRACT_PKG.EVENT_CLASS_CODE_TBL,
      p_taxable_amt_tbl            IN OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_TBL,
      p_tax_amt_tbl                IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_TBL,
      p_tax_amt_funcl_curr_tbl     IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL,
      p_tax_rate_id_tbl            IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
      p_extract_source_ledger_tbl  IN OUT NOCOPY ZX_EXTRACT_PKG.EXTRACT_SOURCE_LEDGER_TBL,
      p_ledger_id_tbl              IN OUT NOCOPY ZX_EXTRACT_PKG.LEDGER_ID_TBL,
      l_detail_tax_line_id_tbl     IN OUT NOCOPY ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
      l_taxable_amt_tbl            IN OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_TBL,
      l_taxable_amt_funcl_curr_tbl IN OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL,
      l_tax_amt_tbl                IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_TBL,
      l_tax_amt_funcl_curr_tbl     IN OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL,
      l_ccid_tbl                   IN OUT NOCOPY t_ccid_tbl,
      l_acct_date_tbl              IN OUT NOCOPY t_acct_date_tbl)
  IS

  BEGIN
    IF 'Y' = PG_DEBUG THEN
      arp_util_tax.debug('zx_jg_extract_pkg.reset_result_tables()+');
    END IF;

    FOR i in p_detail_tax_line_id_tbl.first..p_detail_tax_line_id_tbl.last LOOP
      p_detail_tax_line_id_tbl.delete(i);
      p_trx_id_tbl.delete(i);
      p_tax_line_id_tbl.delete(i);
      p_trx_line_id_tbl.delete(i);
      p_tax_dist_id_tbl.delete(i);
      p_event_class_code_tbl.delete(i);
      p_tax_dist_id_tbl.delete(i);
      p_taxable_amt_tbl.delete(i);
      p_tax_amt_tbl.delete(i);
      p_tax_amt_funcl_curr_tbl.delete(i);
      p_tax_rate_id_tbl.delete(i);
      p_extract_source_ledger_tbl.delete(i);
      p_ledger_id_tbl.delete(i);
    END LOOP;

    FOR j in l_detail_tax_line_id_tbl.first..l_detail_tax_line_id_tbl.last LOOP
      l_detail_tax_line_id_tbl.delete(j);
      l_taxable_amt_tbl.delete(j);
      l_taxable_amt_funcl_curr_tbl.delete(j);
      l_tax_amt_tbl.delete(j);
      l_tax_amt_funcl_curr_tbl.delete(j);
      l_ccid_tbl.delete(j);
      l_acct_date_tbl.delete(j);
    END LOOP;

    IF 'Y' = PG_DEBUG THEN
      arp_util_tax.debug('zx_jg_extract_pkg.reset_result_tables()-');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF 'Y' = PG_DEBUG THEN
        arp_util_tax.debug('zx_jg_extract_pkg.reset_result_tables(EXCEPTION)-');
      END IF;
      RAISE;

  END reset_result_tables;



/**
   * Procedure Name: get_gl_taxable_obsolete
   *
   * @param    c_detail_tax_line_id_tbl
   * @param    c_trx_id_tbl
   * @param    c_tax_line_id_tbl
   * @param    c_trx_line_id_tbl
   * @param    p_minimum_accountable_unit
   * @param    p_func_precistion
   * @param    p_func_min_account_unit
   **/


   PROCEDURE get_gl_taxable_obsolete
     ( c_detail_tax_line_id_tbl        IN ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
       c_trx_id_tbl                    IN ZX_EXTRACT_PKG.TRX_ID_TBL,
       c_tax_line_id_tbl               IN ZX_EXTRACT_PKG.TAX_LINE_ID_TBL,
       c_trx_line_id_tbl               IN ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
       t_detail_tax_line_id_tbl        OUT NOCOPY ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
       t_ccid_tbl                      OUT NOCOPY t_ccid_tbl,
       t_acct_date_tbl                 OUT NOCOPY t_acct_date_tbl,
       t_taxable_amt_tbl               OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_TBL,
       t_taxable_amt_funcl_curr_tbl    OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL,
       t_tax_amt_tbl                   OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_TBL,
       t_tax_amt_funcl_curr_tbl        OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL
       )
   IS

   l_detail_tax_line_id_tbl     ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;

   --
   -- Cursor definition
   --
   CURSOR c_gl (c_detail_tax_line_id in NUMBER,
                c_trx_id in NUMBER,
                c_tax_line_id IN NUMBER) IS
      SELECT c_detail_tax_line_id detail_tax_line_id,
             trx_line.code_combination_id,
             header.default_effective_date accounting_date,
             itf.taxable_amt,
             itf.taxable_amt_funcl_curr,
             itf.tax_amt,
             itf.tax_amt_funcl_curr
        FROM gl_je_headers       header,
             gl_je_lines         trx_line,
             gl_je_lines         tax_line,
             zx_rep_trx_detail_t itf
       WHERE header.je_header_id = c_trx_id
         AND tax_line.je_header_id = header.je_header_id
         AND tax_line.je_line_num = c_tax_line_id
         AND tax_line.je_header_id = trx_line.je_header_id
         AND tax_line.tax_group_id = trx_line.tax_group_id
         AND itf.detail_tax_line_id  = c_detail_tax_line_id
         AND NVL(trx_line.tax_line_flag,'N') <> 'Y';
--         FOR UPDATE;


   BEGIN

     IF 'Y' = PG_DEBUG THEN
       arp_util_tax.debug('zx_jg_extract_pkg.get_gl_taxable()+');
     END IF;

     FOR i in c_detail_tax_line_id_tbl.first..c_detail_tax_line_id_tbl.last LOOP
       FOR crow_gl IN c_gl(c_detail_tax_line_id_tbl(i),c_trx_id_tbl(i),c_tax_line_id_tbl(i)) LOOP
         t_detail_tax_line_id_tbl(i)     := crow_gl.detail_tax_line_id;
         t_ccid_tbl(i)                   := crow_gl.code_combination_id;
         t_acct_date_tbl(i)              := crow_gl.accounting_date;
         t_taxable_amt_tbl(i)            := crow_gl.taxable_amt;
         t_taxable_amt_funcl_curr_tbl(i) := crow_gl.taxable_amt_funcl_curr;
         t_tax_amt_tbl(i)                := crow_gl.tax_amt;
         t_tax_amt_funcl_curr_tbl(i)     := crow_gl.tax_amt_funcl_curr;

       END LOOP;

     END LOOP;

    IF 'Y' = PG_DEBUG THEN
      arp_util_tax.debug('zx_jg_extract_pkg.get_gl_taxable()-');
    END IF;

   END get_gl_taxable_obsolete;


 /**
   * Procedure Name: get_ap_taxable_obsolete
   *
   * @param    c_detail_tax_line_id_tbl
   * @param    c_trx_id_tbl
   * @param    c_tax_line_id_tbl
   * @param    c_trx_line_id_tbl
   *
   **/


   PROCEDURE get_ap_taxable_obsolete (
     c_detail_tax_line_id_tbl        IN ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
     c_trx_id_tbl                    IN ZX_EXTRACT_PKG.TRX_ID_TBL,
     c_tax_line_id_tbl               IN ZX_EXTRACT_PKG.TAX_LINE_ID_TBL,
     c_trx_line_id_tbl               IN ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
     c_tax_dist_id_tbl               IN ZX_EXTRACT_PKG.ACTG_SOURCE_ID_TBL,
     c_ledger_id_tbl                 IN  ZX_EXTRACT_PKG.ledger_id_tbl,
     t_detail_tax_line_id_tbl        OUT NOCOPY ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
     t_ccid_tbl                      OUT NOCOPY t_ccid_tbl,
     t_acct_date_tbl                 OUT NOCOPY t_acct_date_tbl,
     t_taxable_amt_tbl               OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_TBL,
     t_taxable_amt_funcl_curr_tbl    OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL,
     t_tax_amt_tbl                   OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_TBL,
     t_tax_amt_funcl_curr_tbl        OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL
                            ) IS

   l_detail_tax_line_id_tbl     ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
   j                            INTEGER;
   k                            INTEGER;
   k_taxable_amt_tbl             ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;

   --
   -- Private Data Type
   --

   -- TYPE crow_type IS REF CURSOR;

   --
   -- Cursor definition
   --
 /*  CURSOR c_ap (c_detail_tax_line_id in NUMBER, c_trx_id in NUMBER, c_trx_line_id IN NUMBER, c_tax_line_id IN NUMBER) IS
                  SELECT c_detail_tax_line_id detail_tax_line_id,
                         ael.code_combination_id,
                         aeh.accounting_date,
                         zx_dist.taxable_amt,
                         zx_dist.taxable_amt_funcl_curr,
                         zx_dist.prd_tax_amt,
                         zx_dist.prd_tax_amt_funcl_curr
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_headers         aeh,
                         xla_ae_lines           ael,
                         xla_acct_class_assgns  acs,
                         xla_assignment_defns_b asd
                   WHERE zx_dist.trx_id = c_trx_id
                     AND zx_dist.tax_line_id = c_tax_line_id
                     AND zx_dist.trx_line_id = c_trx_line_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INV_DIST'
                     AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND aeh.ae_header_id   = ael.ae_header_id
                     AND acs.program_code   = 'TAX_REP_LEDGER_PROCUREMENT'
                     AND acs.program_code = asd.program_code
                     --AND asd.assignment_code = 'TAX_REPORTING_LEDGER_ACCTS'
                     AND asd.assignment_code = acs.assignment_code
                     AND asd.enabled_flag = 'Y'
                     AND acs.accounting_class_code = ael.accounting_class_code
                     FOR UPDATE;
         */

   CURSOR c_ap (c_detail_tax_line_id in NUMBER, c_trx_id in NUMBER, c_trx_line_id IN NUMBER, c_tax_line_id IN NUMBER,
                c_tax_dist_id NUMBER, c_ledger_id number) IS
                  SELECT c_detail_tax_line_id detail_tax_line_id,
                         ael.code_combination_id,
                         aeh.accounting_date,
                         zx_dist.taxable_amt,
                         zx_dist.taxable_amt_funcl_curr,
                         zx_dist.rec_nrec_tax_amt,
                         zx_dist.rec_nrec_tax_amt_funcl_curr
                    FROM zx_rec_nrec_dist zx_dist,
                         xla_distribution_links lnk,
                         xla_ae_headers         aeh,
                         xla_ae_lines           ael,
                         xla_acct_class_assgns  acs,
                         xla_assignment_defns_b asd
                   WHERE zx_dist.trx_id = c_trx_id
                     AND zx_dist.tax_line_id = c_tax_line_id
                     AND zx_dist.trx_line_id = c_trx_line_id
                     AND lnk.application_id = 200
                     AND lnk.source_distribution_type = 'AP_INV_DIST'
                     AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
                     AND zx_dist.rec_nrec_tax_dist_id = c_tax_dist_id
                     AND lnk.ae_header_id   = ael.ae_header_id
                     AND lnk.ae_line_num    = ael.ae_line_num
                     AND aeh.ae_header_id   = ael.ae_header_id
                     AND acs.program_code   = 'TAX_REP_LEDGER_PROCUREMENT'
                     AND acs.program_code = asd.program_code
                     AND acs.assignment_code = asd.assignment_code
                     AND acs.program_owner_code    = asd.program_owner_code
                     AND acs.assignment_owner_code = asd.assignment_owner_code
                     AND asd.enabled_flag = 'Y'
                     AND ael.ledger_id = c_ledger_id
                     AND acs.accounting_class_code = ael.accounting_class_code;
--                     FOR UPDATE;

   BEGIN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable()+',
                                      'get_ap_taxable : ');
      END IF;


     j := 0;
     k:=0;

     FOR i in c_detail_tax_line_id_tbl.first..c_detail_tax_line_id_tbl.last LOOP

       IF (g_level_procedure >= g_current_runtime_level ) THEN
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                      'c_detail_tax_line_id_tbl : '|| to_char(c_detail_tax_line_id_tbl(i)));
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                      'c_trx_line_id_tbl(i) : '|| to_char(c_trx_line_id_tbl(i)));
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                      'c_trx_id_tbl(i) : '|| to_char(c_trx_id_tbl(i)));
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                      'c_tax_line_id_tbl(i) : '|| to_char(c_tax_line_id_tbl(i)));
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                      'c_tax_dist_id_tbl(i) : '|| to_char(c_tax_dist_id_tbl(i)));
         FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                      'c_ledger_id_tbl(i) : '|| to_char(c_ledger_id_tbl(i)));
       END IF;

       FOR crow_ap IN c_ap(c_detail_tax_line_id_tbl(i), c_trx_id_tbl(i), c_trx_line_id_tbl(i),
                       c_tax_line_id_tbl(i),  c_tax_dist_id_tbl(i), c_ledger_id_tbl(i))

       LOOP
         IF (g_level_procedure >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    't_detail_tax_line_id_tbl(j): '||to_char(crow_ap.detail_tax_line_id));
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    't_ccid_tbl(j): '||to_char(crow_ap.code_combination_id));
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    'crow_ap.taxable_amt: '||to_char(crow_ap.taxable_amt));
         END IF;

         -- k:= to_number(to_char(c_trx_id_tbl(i))||to_char(c_trx_line_id_tbl(i)));

         IF i = 1 THEN
            k:=1;
         ELSE
            IF (c_trx_id_tbl(i) <> c_trx_id_tbl(i-1)) OR
                  (c_trx_line_id_tbl(i) <> c_trx_line_id_tbl(i-1)) THEN
                k:=k+1;
            END IF;
         END IF;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    'K : '||to_char(k));
         END IF;

         j := j+1;
         t_detail_tax_line_id_tbl(j)     := crow_ap.detail_tax_line_id;
         t_ccid_tbl(j)                   := crow_ap.code_combination_id;
         t_acct_date_tbl(j)              := crow_ap.accounting_date;
          -- t_taxable_amt_tbl(j)            := crow_ap.taxable_amt;
         --  t_taxable_amt_funcl_curr_tbl(j) := crow_ap.taxable_amt_funcl_curr;
         t_tax_amt_tbl(j)                := crow_ap.rec_nrec_tax_amt;
         t_tax_amt_funcl_curr_tbl(j)     := crow_ap.rec_nrec_tax_amt_funcl_curr;

         IF k_taxable_amt_tbl.EXISTS(k) THEN
           t_taxable_amt_tbl(j)            := 0;
           k_taxable_amt_tbl(k)            := 0;
           t_taxable_amt_funcl_curr_tbl(j) := 0;
           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    'k value test IF: ');
           END IF;
         ELSE
           t_taxable_amt_tbl(j) :=crow_ap.taxable_amt;
           k_taxable_amt_tbl(k) :=crow_ap.taxable_amt;
           t_taxable_amt_funcl_curr_tbl(j) := crow_ap.taxable_amt_funcl_curr;

           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    'k value test else: ');
           END IF;
         END IF;

         IF (g_level_procedure >= g_current_runtime_level ) THEN
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    't_detail_tax_line_id_tbl(j): '||to_char(t_detail_tax_line_id_tbl(j)));
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    't_ccid_tbl(j): '||to_char(t_ccid_tbl(j)));
           FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    't_taxable_amt_tbl(j): '||to_char(t_taxable_amt_tbl(j)));
         END IF;

       END LOOP;

     END LOOP;


     IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable()-',
                                      'get_ap_taxable : ');
     END IF;

   END get_ap_taxable_obsolete;


 /**
   * Procedure Name: get_ar_taxable
   *
   * This procedure gets taxable amount from AR trx tables and
   * also getst accunting ccid from XLA table.
   *
   * @param    c_event_class_code_tbl
   * @param    c_trx_id_tbl
   * @param    c_tax_line_id_tbl
   * @param    c_taxable_amt_tbl
   * @param    c_tax_rate_id_tbl
   * @param    p_sob_type
   * @param    p_func_precision
   * @param    p_func_min_account_unit
   *
   **/

   PROCEDURE get_ar_taxable (
     c_detail_tax_line_id_tbl       IN ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
     c_event_class_code_tbl         IN ZX_EXTRACT_PKG.EVENT_CLASS_CODE_TBL,
     c_trx_id_tbl                   IN ZX_EXTRACT_PKG.TRX_ID_TBL,
     c_tax_line_id_tbl              IN ZX_EXTRACT_PKG.TAX_LINE_ID_TBL,
     c_trx_line_id_tbl              IN ZX_EXTRACT_PKG.TRX_LINE_ID_TBL,
     c_taxable_amt_tbl              IN ZX_EXTRACT_PKG.TAXABLE_AMT_TBL,
     c_taxable_amt_funcl_curr_tbl   IN ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL,
     c_tax_amt_tbl                  IN ZX_EXTRACT_PKG.TAX_AMT_TBL,
     c_tax_amt_funcl_curr_tbl       IN ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL,
     c_tax_rate_id_tbl              IN ZX_EXTRACT_PKG.TAX_RATE_ID_TBL,
     p_sob_type                     IN VARCHAR2,
     p_func_precision               IN NUMBER,
     p_func_min_account_unit        IN NUMBER,
     t_detail_tax_line_id_tbl       OUT NOCOPY ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL,
     t_ccid_tbl                     OUT NOCOPY t_ccid_tbl,
     t_acct_date_tbl                OUT NOCOPY t_acct_date_tbl,
     t_taxable_amt_tbl              OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_TBL,
     t_taxable_amt_funcl_curr_tbl   OUT NOCOPY ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL,
     t_tax_amt_tbl                  OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_TBL,
     t_tax_amt_funcl_curr_tbl       OUT NOCOPY ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL) IS

   CURSOR  c_ar_inv (c_detail_tax_line_id in NUMBER) IS
     SELECT detail_tax_line_id,
            actg_line_ccid code_combination_id,
            accounting_date ,
            0 taxable_amt, -- -1*zx_dist.taxable_amt taxable_amt,
            0 taxable_amt_funcl_curr,  -- -1*zx_dist.taxable_amt_funcl_curr taxable_amt_funcl_curr,
            0 tax_amt, -- -1*zx_dist.prd_tax_amt tax_amt,
            0 tax_amt_funcl_curr -- -1*zx_dist.prd_tax_amt_funcl_curr tax_amt_funcl_curr
      FROM zx_rep_actg_ext_t
      WHERE detail_tax_line_id = c_detail_tax_line_id;

-- Commentted as this is no call to the cursor.
/***
   CURSOR c_ar_inv1(c_detail_tax_line_id in NUMBER,
                   c_trx_id             in NUMBER,
                   c_trx_line_id        IN NUMBER,
                   c_tax_line_id        IN NUMBER
                   ) IS

     SELECT c_detail_tax_line_id detail_tax_line_id,
            ael.code_combination_id,
            aeh.accounting_date,
            0 taxable_amt, -- -1*zx_dist.taxable_amt taxable_amt,
            0 taxable_amt_funcl_curr,  -- -1*zx_dist.taxable_amt_funcl_curr taxable_amt_funcl_curr,
            0 tax_amt, -- -1*zx_dist.prd_tax_amt tax_amt,
            0 tax_amt_funcl_curr -- -1*zx_dist.prd_tax_amt_funcl_curr tax_amt_funcl_curr
       FROM ra_cust_trx_line_gl_dist_all gl_dist,
            xla_distribution_links lnk,
            xla_ae_headers         aeh,
            xla_ae_lines           ael,
            xla_acct_class_assgns  acs,
            xla_assignment_defns_b asd
      WHERE gl_dist.customer_trx_id = c_trx_id
        AND gl_dist.customer_trx_line_id = c_trx_line_id
        AND gl_dist.account_class = 'REV'
        AND lnk.application_id = 222
        AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
        AND lnk.source_distribution_id_num_1 = gl_dist.cust_trx_line_gl_dist_id
        AND lnk.ae_header_id   = ael.ae_header_id
        AND lnk.ae_line_num    = ael.ae_line_num
        AND ael.application_id = lnk.application_id
        AND aeh.ae_header_id   = ael.ae_header_id
        AND aeh.application_id = lnk.application_id
        AND acs.program_code   = 'TAX_REPORTING_LEDGER_SALES'
        AND acs.program_code    = asd.program_code
        AND acs.assignment_code = asd.assignment_code
        AND acs.program_owner_code    = asd.program_owner_code
        AND acs.assignment_owner_code = asd.assignment_owner_code
        AND asd.enabled_flag = 'Y'
        AND acs.accounting_class_code = ael.accounting_class_code;
--        FOR UPDATE;
***/
         /*   SELECT c_detail_tax_line_id detail_tax_line_id,
                   ael.code_combination_id,
                   aeh.accounting_date,
                   -1*zx_dist.taxable_amt taxable_amt,
                   -1*zx_dist.taxable_amt_funcl_curr taxable_amt_funcl_curr,
                   -1*zx_dist.prd_tax_amt tax_amt,
                   -1*zx_dist.prd_tax_amt_funcl_curr tax_amt_funcl_curr
              FROM zx_rec_nrec_dist zx_dist,
                   xla_distribution_links lnk,
                   xla_ae_headers         aeh,
                   xla_ae_lines           ael,
                   xla_acct_class_assgns  acs,
                   xla_assignment_defns_b asd
             WHERE zx_dist.trx_id = c_trx_id
               AND zx_dist.tax_line_id = c_tax_line_id
               AND zx_dist.trx_line_id = c_trx_line_id
               AND lnk.application_id = 222
               AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS'
               AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_id
               AND lnk.ae_header_id   = ael.ae_header_id
               AND lnk.ae_line_num    = ael.ae_line_num
               AND aeh.ae_header_id   = ael.ae_header_id
               AND acs.program_code   = 'TAX_REPORTING_LEDGER'
               AND acs.program_code = asd.program_code
               AND asd.assignment_code = 'TAX_REPORTING_LEDGER_ACCTS'
               AND asd.assignment_code = acs.assignment_code
               AND asd.enabled_flag = 'Y'
               AND acs.accounting_class_code = ael.accounting_class_code
               FOR UPDATE; */

   TYPE crow_type IS REF CURSOR;
   c_row                                 crow_type;

   l_cur_aradj                           VARCHAR2(10000);
   l_cur_armisc                          VARCHAR2(10000);
   l_cur_arra                            VARCHAR2(10000);

   l_ar_adjustments                      VARCHAR2(30);
   l_ar_cash_receipts                    VARCHAR2(30);
   l_ar_distributions                    VARCHAR2(30);
   l_ar_receivable_applications          VARCHAR2(30);
   l_ar_misc_cash_distributions          VARCHAR2(30);
   l_ra_customer_trx                     VARCHAR2(30);
   l_ra_customer_trx_lines               VARCHAR2(30);
   l_ra_cust_trx_line_gl_dist            VARCHAR2(30);

   l_percent_tbl                         numtab;
   l_tax_amt_tbl                         ZX_EXTRACT_PKG.TAX_AMT_TBL;
   l_tax_amt_funcl_curr_tbl              ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL;
   l_precision_tbl                       numtab;
   l_minimum_accountable_unit_tbl        numtab;

   j                                     INTEGER;
   k                                     INTEGER;
   l_first_line                          INTEGER;

  BEGIN

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable()+',
                                     'get_ar_taxable : ');
    END IF;

    /* --------------------------------------------------------- *
     * Case1.  Set of Books is Reporting Book                    *
     * --------------------------------------------------------- */

    IF p_sob_type = 'R' THEN
      l_ar_adjustments               := 'ar_adjustments_mrc_v';
      l_ar_cash_receipts             := 'ar_cash_receipts_mrc_v';
      l_ar_distributions             := 'ar_distributions_mrc_v';
      l_ar_receivable_applications   := 'ar_receivable_apps_mrc_v';
      l_ar_misc_cash_distributions   := 'ar_misc_cash_dists_mrc_v';
      l_ra_cust_trx_line_gl_dist     := 'ra_trx_line_gl_dist_mrc_v';
      l_ra_customer_trx              := 'ra_customer_trx_mrc_v';
      l_ra_customer_trx_lines        := 'ra_cust_trx_ln_mrc_v';

    /* --------------------------------------------------------- *
     * Case2.  Set of Books is Primary Book or Not MRC Book      *
     * --------------------------------------------------------- */
    ELSIF p_sob_type <> 'R' AND p_sob_type IS NOT NULL  THEN
      l_ar_adjustments               := 'ar_adjustments_all';
      l_ar_cash_receipts             := 'ar_cash_receipts_all';
      l_ar_distributions             := 'ar_distributions_all';
      l_ar_receivable_applications   := 'ar_receivable_applications_all';
      l_ar_misc_cash_distributions   := 'ar_misc_cash_distributions_all';
      l_ra_cust_trx_line_gl_dist     := 'ra_cust_trx_line_gl_dist_all';
      l_ra_customer_trx              := 'ra_customer_trx_all';
      l_ra_customer_trx_lines        := 'ra_customer_trx_lines_all';

    ELSE
      IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable()+',
                                     'Unable to specify if the Book is Reporting Book or  Not ');
      END IF;
    END IF;

    l_ar_adjustments               := 'ar_adjustments_all';
    l_ar_cash_receipts             := 'ar_cash_receipts_all';
    l_ar_distributions             := 'ar_distributions_all';

    /* ----------------------------------------------------------------- *
     *      Defined following 3 new cursors which use Dynamic SQL        *
     *                                                                   *
     *  l_cur_aradj    -- replacement for CURSOR aradj                   *
     *  l_cur_armisc   -- replacement for CURSOR armis                   *
     *  l_cur_arra     -- replacement for CURSOR arra                    *
     *                                                                   *
     * ----------------------------------------------------------------- */

    l_cur_aradj :=  'SELECT
           :c_detail_tax_line_id,
           ael.code_combination_id ccid,
           Decode(:c_taxable_total, 0, 0,
           (Nvl(adjlndist.amount_dr,0)+Nvl(-1*adjlndist.amount_cr,0))/:c_taxable_total) percent,
           Nvl(adjlndist.amount_dr,0)+Nvl(-1*adjlndist.amount_cr,0) taxable_amount,
           Nvl(adjlndist.acctd_amount_dr,0)+Nvl(-1*adjlndist.acctd_amount_cr,0) acctd_taxable_amount,
           curr.precision,
           curr.minimum_accountable_unit,
           aeh.accounting_date
           FROM
           '|| l_ar_distributions ||' adjlndist,
           '|| l_ar_distributions ||' adjtxdist,
           '|| l_ar_adjustments ||' adj,
           '|| l_ra_customer_trx ||' trx,
            fnd_currencies curr,
            xla_distribution_links lnk,
            xla_ae_headers         aeh,
            xla_ae_lines           ael,
            xla_acct_class_assgns  acs,
            xla_assignment_defns_b asd
           WHERE
           adj.adjustment_id = :c_trx_id AND
           trx.customer_trx_id = adj.customer_trx_id AND
           adjlndist.source_id = adj.adjustment_id AND
           adjtxdist.source_id = adj.adjustment_id AND
           adjlndist.source_table = ''ADJ'' AND
           adjtxdist.source_table = ''ADJ'' AND
           adjlndist.source_type IN (''ADJ'', ''FINCHRG'') AND
           adjtxdist.source_type = ''TAX'' AND
           adjlndist.tax_link_id = adjtxdist.tax_link_id AND
           adjtxdist.tax_code_id = :c_tax_rate_id AND
           lnk.application_id = 222 AND
           lnk.source_distribution_type = ''AR_DISTRIBUTIONS_ALL'' AND
           lnk.source_distribution_id_num_1 = adjlndist.line_id AND
           lnk.ae_header_id   = ael.ae_header_id AND
           lnk.ae_line_num    = ael.ae_line_num AND
           ael.application_id = lnk.application_id AND
           aeh.application_id = lnk.application_id AND
           aeh.ae_header_id   = ael.ae_header_id AND
           trx.invoice_currency_code = curr.currency_code AND
           acs.program_code   = ''TAX_REPORTING_LEDGER_SALES''  AND
           acs.program_code = asd.program_code AND
           acs.assignment_code = asd.assignment_code AND
           acs.program_owner_code    = asd.program_owner_code AND
           acs.assignment_owner_code = asd.assignment_owner_code AND
           asd.enabled_flag = ''Y'' AND
           acs.accounting_class_code = ael.accounting_class_code';

     /*  l_cur_aradj :=  'SELECT
                          :c_detail_tax_line_id,
                          ael.code_combination_id ccid,
             Decode(:c_taxable_total, 0, 0,
             (Nvl(adjlndist.amount_dr,0)+Nvl(-1*adjlndist.amount_cr,0))/:c_taxable_total) percent,
             Nvl(adjlndist.amount_dr,0)+Nvl(-1*adjlndist.amount_cr,0) taxable_amount,
             Nvl(adjlndist.acctd_amount_dr,0)+Nvl(-1*adjlndist.acctd_amount_cr,0) acctd_taxable_amount,
             curr.precision,
             curr.minimum_accountable_unit,
             aeh.accounting_date
             FROM
             '|| l_ar_distributions ||' adjlndist,
             '|| l_ar_distributions ||' adjtxdist,
             '|| l_ar_adjustments ||' adj,
             '|| l_ra_customer_trx ||' trx,
              fnd_currencies curr,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines           ael,
              xla_acct_class_assgns  acs,
              xla_assignment_defns_b asd
             WHERE
             adj.adjustment_id = :c_trx_id AND
             trx.customer_trx_id = adj.customer_trx_id AND
             adjlndist.source_id = adj.adjustment_id AND
             adjtxdist.source_id = adj.adjustment_id AND
             adjlndist.source_table = ''ADJ'' AND
             adjtxdist.source_table = ''ADJ'' AND
             adjlndist.source_type IN (''ADJ'', ''FINCHRG'') AND
             adjtxdist.source_type = ''TAX'' AND
             adjlndist.tax_link_id = adjtxdist.tax_link_id AND
             adjtxdist.tax_code_id = :c_tax_rate_id AND
             lnk.application_id = 222 AND
             lnk.source_distribution_type = ''AR_DISTRIBUTIONS'' AND
             lnk.source_distribution_id_num_1 = zx_dist.trx_line_id AND
             lnk.ae_header_id   = ael.ae_header_id AND
             lnk.ae_line_num    = ael.ae_line_num AND
             aeh.ae_header_id   = ael.ae_header_id AND
             trx.invoice_currency_code = curr.currency_code AND
             acs.program_code   = ''TAX_REPORTING_LEDGER''  AND
             acs.program_code = asd.program_code            AND
             asd.assignment_code = ''TAX_REPORTING_LEDGER_ACCTS'' AND
             asd.assignment_code = acs.assignment_code            AND
             asd.enabled_flag = ''Y'' AND
             acs.accounting_class_code = ael.accounting_class_code';
       */

    l_cur_armisc := 'SELECT
           :c_detail_tax_line_id,
           ael.code_combination_id ccid,
           Decode(:c_taxable_total, 0, 0, (Nvl(d.amount_dr,0)+Nvl(-1*d.amount_cr,0))/:c_taxable_total) percent,
           Nvl(d.amount_dr,0)+Nvl(-1*d.amount_cr,0) taxable_amount,
           Nvl(d.acctd_amount_dr,0)+Nvl(-1*d.acctd_amount_cr,0) acctd_taxable_amount,
           curr.precision,
           curr.minimum_accountable_unit,
           aeh.accounting_date
           FROM
           '|| l_ar_cash_receipts ||' cr,
           '|| l_ar_misc_cash_distributions ||' mcd,
           '|| l_ar_distributions ||' d,
            xla_distribution_links lnk,
            xla_ae_headers         aeh,
            xla_ae_lines           ael,
           fnd_currencies         curr,
           xla_acct_class_assgns  acs,
           xla_assignment_defns_b asd
           WHERE
           cr.cash_receipt_id = :c_trx_id AND
           cr.cash_receipt_id = mcd.cash_receipt_id AND
           d.source_table = ''MCD'' AND
           d.source_id = mcd.misc_cash_distribution_id AND
           d.source_type <> ''TAX'' AND
           lnk.application_id = 222 AND
           lnk.source_distribution_type = ''AR_DISTRIBUTIONS_ALL'' AND
           lnk.source_distribution_id_num_1 = d.line_id AND
           lnk.ae_header_id   = ael.ae_header_id AND
           lnk.ae_line_num    = ael.ae_line_num AND
           ael.application_id = lnk.application_id AND
           aeh.application_id = lnk.application_id AND
           aeh.ae_header_id   = ael.ae_header_id AND
           cr.currency_code = curr.currency_code AND
           acs.program_code   = ''TAX_REPORTING_LEDGER_SALES''  AND
           acs.program_code = asd.program_code AND
           acs.assignment_code = asd.assignment_code AND
           acs.program_owner_code    = asd.program_owner_code AND
           acs.assignment_owner_code = asd.assignment_owner_code AND
           asd.enabled_flag = ''Y'' AND
           acs.accounting_class_code = ael.accounting_class_code';

 /*l_cur_armisc := 'SELECT
                          :c_detail_tax_line_id,
                          ael.code_combination_id ccid,
             Decode(:c_taxable_total, 0, 0, (Nvl(d.amount_dr,0)+Nvl(-1*d.amount_cr,0))/:c_taxable_total) percent,
             Nvl(d.amount_dr,0)+Nvl(-1*d.amount_cr,0) taxable_amount,
             Nvl(d.acctd_amount_dr,0)+Nvl(-1*d.acctd_amount_cr,0) acctd_taxable_amount,
             curr.precision,
             curr.minimum_accountable_unit,
             aeh.accounting_date
             FROM
             '|| l_ar_cash_receipts ||' cr,
             '|| l_ar_misc_cash_distributions ||' mcd,
             '|| l_ar_distributions ||' d,
              xla_distribution_links lnk,
              xla_ae_headers         aeh,
              xla_ae_lines           ael,
             fnd_currencies         curr,
             xla_acct_class_assgns  acs,
             xla_assignment_defns_b asd
             WHERE
             cr.cash_receipt_id = :c_trx_id AND
             cr.cash_receipt_id = mcd.cash_receipt_id AND
             d.source_table = ''MCD'' AND
             d.source_id = mcd.misc_cash_distribution_id AND
             d.source_type <> ''TAX'' AND
             lnk.application_id = 222 AND
             lnk.source_distribution_type = ''AR_DISTRIBUTIONS_ALL'' AND
             lnk.source_distribution_id_num_1 = zx_dist.trx_line_id AND
             lnk.ae_header_id   = ael.ae_header_id AND
             lnk.ae_line_num    = ael.ae_line_num AND
             aeh.ae_header_id   = ael.ae_header_id AND
             cr.currency_code = curr.currency_code AND
             acs.program_code   = ''TAX_REPORTING_LEDGER_SALES''  AND
             acs.program_code = asd.program_code            AND
             asd.assignment_code = ''TAX_REPORTING_LEDGER_ACCTS'' AND
             asd.assignment_code = acs.assignment_code            AND
             asd.enabled_flag = ''Y'' AND
             acs.accounting_class_code = ael.accounting_class_code';
*/

l_cur_arra := 'SELECT
           :c_detail_tax_line_id,
           Decode(:c_taxable_total, 0, 0, (Nvl(dtax.amount_cr,0)+Nvl(-1*dtax.amount_dr,0))/:c_taxable_total) percent,
           (nvl(DTAX.TAXABLE_ENTERED_CR,0) - nvl(DTAX.TAXABLE_ENTERED_DR,0)) taxable_amount,
           (nvl(DTAX.TAXABLE_ACCOUNTED_CR,0) - nvl(DTAX.TAXABLE_ACCOUNTED_DR,0)) acctd_taxable_amount,
           curr.precision,
           curr.minimum_accountable_unit
           FROM
           '|| l_ar_distributions ||' dtax,
           '|| l_ar_distributions ||' d,
           '|| l_ar_receivable_applications ||' ra,
           '|| l_ar_cash_receipts ||' cr,
           fnd_currencies curr
           WHERE
           cr.cash_receipt_id = :c_trx_id AND
           d.source_table = ''RA'' AND
           d.line_id = :c_trx_line_id AND
           dtax.source_table = ''RA'' AND
           dtax.source_type = ''TAX'' and
           dtax.source_id = d.source_id AND
           Nvl(d.tax_link_id,0) = Nvl(dtax.tax_link_id,0) AND
           ra.receivable_application_id = d.source_id AND
           ra.receivable_application_id = dtax.source_id AND
           ra.cash_receipt_id = cr.cash_receipt_id AND
           curr.currency_code = cr.currency_code ';

/*    l_cur_arra := 'SELECT
           :c_detail_tax_line_id,
           ael.code_combination_id ccid,
           Decode(c_taxable_total, 0, 0, (Nvl(d.amount_dr,0)+Nvl(-1*d.amount_cr,0))/:c_taxable_total) percent,
           Nvl(d.amount_dr,0)+Nvl(-1*d.amount_cr,0) taxable_amount,
           Nvl(d.acctd_amount_dr,0)+Nvl(-1*d.acctd_amount_cr,0) acctd_taxable_amount,
           curr.precision,
           curr.minimum_accountable_unit,
           aeh.accounting_date
           FROM
           '|| l_ar_distributions ||' dtax,
           '|| l_ar_distributions ||' d,
           '|| l_ar_receivable_applications ||' ra,
           '|| l_ar_cash_receipts ||' cr,
           fnd_currencies curr,
           xla_distribution_links lnk,
           xla_ae_headers         aeh,
           xla_ae_lines           ael,
           xla_acct_class_assgns  acs,
           xla_assignment_defns_b asd
           WHERE
           -- dtax.line_id = :c_acctg_dist_id AND
           cr.cash_receipt_id = :c_trx_id AND
           dtax.source_table = ''RA'' AND
           d.source_table = ''RA'' AND
           d.source_id = dtax.source_id AND
           d.source_type <> ''TAX'' and
           dtax.source_type = ''TAX'' and
           (d.tax_link_id = -1 OR Nvl(d.tax_link_id,0) = Nvl(dtax.tax_link_id,0)) AND
           ra.receivable_application_id = dtax.source_id AND
           cr.cash_receipt_id = ra.cash_receipt_id AND
           lnk.application_id = 222 AND
           lnk.source_distribution_type = ''AR_DISTRIBUTIONS'' AND
           lnk.source_distribution_id_num_1 = zx_dist.trx_line_id AND
           lnk.ae_header_id   = ael.ae_header_id AND
           lnk.ae_line_num    = ael.ae_line_num AND
           ael.application_id = lnk.application_id AND
           aeh.application_id = lnk.application_id AND
           aeh.ae_header_id   = ael.ae_header_id AND
           cr.currency_code = curr.currency_code AND
           acs.program_code   = ''TAX_REPORTING_LEDGER''  AND
           acs.program_code = asd.program_code AND
           acs.assignment_code = asd.assignment_code AND
           acs.program_owner_code    = asd.program_owner_code AND
           acs.assignment_owner_code = asd.assignment_owner_code AND
           asd.enabled_flag = ''Y'' AND
           acs.accounting_class_code = ael.accounting_class_code';
*/
    j := 0;
    k := 0;

    FOR i in c_event_class_code_tbl.first..c_event_class_code_tbl.last LOOP
      IF c_event_class_code_tbl(i) IN ('INVOICE', 'CREDIT_MEMO', 'DEBIT_MEMO') THEN
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable()+',
                                  'Getting INV/CM/DM : ');
        END IF;

         /*FOR c_ar_inv_row IN c_ar_inv(c_detail_tax_line_id_tbl(i),
                                        c_trx_id_tbl(i),
                                        c_trx_line_id_tbl(i),
                                        c_tax_line_id_tbl(i)) */
        FOR c_ar_inv_row IN c_ar_inv(c_detail_tax_line_id_tbl(i))
        LOOP
          j := j+1;
          t_detail_tax_line_id_tbl(j)     := c_ar_inv_row.detail_tax_line_id;
          t_ccid_tbl(j)                   := c_ar_inv_row.code_combination_id;
          t_acct_date_tbl(j)              := c_ar_inv_row.accounting_date;
        --  t_taxable_amt_tbl(j)            := c_taxable_amt_tbl(i);
        --  t_taxable_amt_funcl_curr_tbl(j) := c_taxable_amt_funcl_curr_tbl(i);
          t_tax_amt_tbl(j)                := c_tax_amt_tbl(i);
          t_tax_amt_funcl_curr_tbl(j)     := c_tax_amt_funcl_curr_tbl(i);
          --t_taxable_amt_tbl(j)            := c_ar_inv_row.taxable_amt;
          --t_taxable_amt_funcl_curr_tbl(j) := c_ar_inv_row.taxable_amt_funcl_curr;
          --t_tax_amt_tbl(j)                := c_ar_inv_row.tax_amt;
          --t_tax_amt_funcl_curr_tbl(j)     := c_ar_inv_row.tax_amt_funcl_curr;
          IF i = 1 THEN
             k := 1;
          ELSE
             IF (c_trx_id_tbl(i) <> c_trx_id_tbl(i-1)) OR
                  (c_trx_line_id_tbl(i) <> c_trx_line_id_tbl(i-1)) THEN
                k:=k+1;
             END IF;
          END IF;

          IF t_taxable_amt_tbl.EXISTS(k) THEN
           t_taxable_amt_tbl(j)            := 0;
           t_taxable_amt_funcl_curr_tbl(j) := 0;
           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    'Inside IF: ');
           END IF;
          ELSE
           t_taxable_amt_tbl(j) := c_taxable_amt_tbl(i);
           t_taxable_amt_funcl_curr_tbl(j) := c_taxable_amt_funcl_curr_tbl(i);
           IF (g_level_procedure >= g_current_runtime_level ) THEN
               FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ap_taxable',
                                    'Inside else: ');
           END IF;
          END IF;

          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    't_detail_tax_line_id_tbl(j): '||to_char(t_detail_tax_line_id_tbl(j)));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    't_ccid_tbl(j): '||to_char(t_ccid_tbl(j)));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    't_taxable_amt_tbl(j): '||to_char(t_taxable_amt_tbl(j)));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    't_taxable_amt_funcl_curr_tbl(j): '||to_char(t_taxable_amt_funcl_curr_tbl(j)));
          END IF;

        END LOOP;

      ELSIF c_event_class_code_tbl(i) IN ('ADJ') THEN

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'Getting ADJ:' );
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'c_trx_id_tbl(i):'||to_char(c_trx_id_tbl(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'c_tax_rate_id_tbl(i):'||to_char(c_tax_rate_id_tbl(i)));
        END IF;

        l_first_line := j+1;

        OPEN c_row FOR l_cur_aradj USING c_detail_tax_line_id_tbl(i),
                                         c_taxable_amt_tbl(i),
                                         c_taxable_amt_tbl(i),
                                         c_trx_id_tbl(i),
                                         c_tax_rate_id_tbl(i);
        LOOP
          FETCH  c_row INTO t_detail_tax_line_id_tbl(j+1),
                            t_ccid_tbl(j+1),
                            l_percent_tbl(j+1),
                            t_taxable_amt_tbl(j+1),
                            t_taxable_amt_funcl_curr_tbl(j+1),
                            l_precision_tbl(j+1),
                            l_minimum_accountable_unit_tbl(j+1),
                            t_acct_date_tbl(j+1);
          EXIT WHEN c_row%NOTFOUND;
          IF (g_level_procedure >= g_current_runtime_level ) THEN
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                     'l_cur_aradj : t_detail_tax_line_id_tbl(j): '||to_char(t_detail_tax_line_id_tbl(j+1)));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                     'l_cur_aradj : t_ccid_tbl(j): '||to_char(t_ccid_tbl(j+1)));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                   'l_cur_aradj : t_taxable_amt_tbl(j): '||to_char(t_taxable_amt_tbl(j+1)));
            FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                   'l_cur_aradj : t_taxable_amt_tbl(j): '||to_char(j));
          END IF;
          j := j+1;
        END LOOP;
        CLOSE c_row;

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                     'l_cur_aradj : prorate_tax call: ');
        END IF;

        prorate_tax(-1*c_tax_amt_tbl(i),
                    -1*c_tax_amt_funcl_curr_tbl(i),
                    l_percent_tbl,
                    t_tax_amt_tbl,
                    t_tax_amt_funcl_curr_tbl,
                    l_precision_tbl,
                    l_minimum_accountable_unit_tbl,
                    p_func_precision,
                    p_func_min_account_unit,
                    l_first_line,
                    j
                   );

      ELSIF c_event_class_code_tbl(i) IN ('MISC_CASH_RECEIPT') THEN

        IF 'Y' = PG_DEBUG THEN
          arp_util_tax.debug('Getting MCR');
        END IF;

        l_first_line := j+1;
        OPEN c_row FOR l_cur_armisc USING c_detail_tax_line_id_tbl(i),
                                          c_taxable_amt_tbl(i),
                                          c_taxable_amt_tbl(i),
                                          c_trx_id_tbl(i);
        LOOP
          FETCH  c_row INTO t_detail_tax_line_id_tbl(j+1),
                            t_ccid_tbl(j+1),
                            l_percent_tbl(j+1),
                            t_taxable_amt_tbl(j+1),
                            t_taxable_amt_funcl_curr_tbl(j+1),
                            l_precision_tbl(j+1),
                            l_minimum_accountable_unit_tbl(j+1),
                            t_acct_date_tbl(j+1);
          EXIT WHEN c_row%NOTFOUND;
          j := j+1;
        END LOOP;
        CLOSE c_row;

        prorate_tax(-1*c_tax_amt_tbl(i),
                    -1*c_tax_amt_funcl_curr_tbl(i),
                    l_percent_tbl,
                    t_tax_amt_tbl,
                    t_tax_amt_funcl_curr_tbl,
                    l_precision_tbl,
                    l_minimum_accountable_unit_tbl,
                    p_func_precision,
                    p_func_min_account_unit,
                    l_first_line,
                    j
                   );

      ELSIF c_event_class_code_tbl(i) IN ('EDISC', 'UNEDISC', 'APP') THEN

        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'Getting DISC/APP' );
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'c_trx_id_tbl(i):'||to_char(c_trx_id_tbl(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'c_tax_rate_id_tbl(i):'||to_char(c_tax_rate_id_tbl(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'c_taxable_amt_tbl(i):'||to_char(c_taxable_amt_tbl(i)));
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'c_trx_line_id_tbl(i):'||to_char(c_trx_line_id_tbl(i)));
        END IF;

        l_first_line := j+1;

        OPEN c_row FOR l_cur_arra USING c_detail_tax_line_id_tbl(i),
                                        c_taxable_amt_tbl(i),
                                        c_taxable_amt_tbl(i),
                                        c_trx_id_tbl(i),
                                        c_trx_line_id_tbl(i);
        LOOP

          FETCH  c_row INTO t_detail_tax_line_id_tbl(j+1),
                            l_percent_tbl(j+1),
                            t_taxable_amt_tbl(j+1),
                            t_taxable_amt_funcl_curr_tbl(j+1),
                            l_precision_tbl(j+1),
                            l_minimum_accountable_unit_tbl(j+1);

          EXIT WHEN c_row%NOTFOUND;
          j := j+1;

        END LOOP;
        CLOSE c_row;

        prorate_tax(c_tax_amt_tbl(i),
                    c_tax_amt_funcl_curr_tbl(i),
                    l_percent_tbl,
                    t_tax_amt_tbl,
                    t_tax_amt_funcl_curr_tbl,
                    l_precision_tbl,
                    l_minimum_accountable_unit_tbl,
                    p_func_precision,
                    p_func_min_account_unit,
                    l_first_line,
                    j
                   );

      ELSE
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'Unknown Trx_Class_Code' );
        END IF;

        app_exception.raise_exception;

      END IF;
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable',
                                    'dtl cursor loop :');
      END IF;
    END LOOP;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_ar_taxable.END',
                                    'zx_jg_extract.get_ar_taxable()-');
    END IF;

  END get_ar_taxable;



 /**
   * procedure Name: get_taxable
   *
   * Wrapper procedure to get prorated taxa amount per taxable accont
   * and accounting info.
   *
   * @param p_trx_global_variabl_variables_rec
   *
   **/

  PROCEDURE get_taxable (
    p_trl_global_variables_rec IN ZX_EXTRACT_PKG.TRL_GLOBAL_VARIABLES_REC_TYPE)
  IS

  --
  -- Private Parameters
  --
  p_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
  p_trx_id_tbl                    ZX_EXTRACT_PKG.TRX_ID_TBL;
  p_tax_line_id_tbl               ZX_EXTRACT_PKG.TAX_LINE_ID_TBL;
  p_trx_line_id_tbl               ZX_EXTRACT_PKG.TRX_LINE_ID_TBL;
  p_tax_dist_id_tbl               ZX_EXTRACT_PKG.actg_source_id_tbl;
  p_event_class_code_tbl          ZX_EXTRACT_PKG.EVENT_CLASS_CODE_TBL;
  p_taxable_amt_tbl               ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;
  p_taxable_amt_funcl_curr_tbl    ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL;
  p_tax_amt_tbl                   ZX_EXTRACT_PKG.TAX_AMT_TBL;
  p_tax_amt_funcl_curr_tbl        ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL;
  p_tax_rate_id_tbl               ZX_EXTRACT_PKG.TAX_RATE_ID_TBL;
  p_extract_source_ledger_tbl     ZX_EXTRACT_PKG.EXTRACT_SOURCE_LEDGER_TBL;
  p_ledger_id_tbl                 ZX_EXTRACT_PKG.LEDGER_ID_TBL;
  l_detail_tax_line_id_tbl        ZX_EXTRACT_PKG.DETAIL_TAX_LINE_ID_TBL;
  l_ccid_tbl                      t_ccid_tbl;
  l_acct_date_tbl                 t_acct_date_tbl;
  l_percent_tbl                   numtab;
  l_taxable_amt_tbl               ZX_EXTRACT_PKG.TAXABLE_AMT_TBL;
  l_taxable_amt_funcl_curr_tbl    ZX_EXTRACT_PKG.TAXABLE_AMT_FUNCL_CURR_TBL;
  l_tax_amt_tbl                   ZX_EXTRACT_PKG.TAX_AMT_TBL;
  l_tax_amt_funcl_curr_tbl        ZX_EXTRACT_PKG.TAX_AMT_FUNCL_CURR_TBL;
  l_precision_tbl                 numtab;
  l_minimum_accountable_unit_tbl  numtab;
  l_func_precision                NUMBER;
  l_func_min_account_unit         NUMBER;
  l_sob_type                      GL_SETS_OF_BOOKS.MRC_SOB_TYPE_CODE%TYPE;

  --
  -- Cursor definitions
  --

  CURSOR c_trl_itf(c_request_id IN NUMBER, c_source_ledger IN VARCHAR2) IS
    SELECT detail_tax_line_id,
           trx_id,
           tax_line_id,
           trx_line_id,
           actg_source_id,
           event_class_code,
           taxable_amt,
           taxable_amt_funcl_curr,
           tax_amt,
           tax_amt_funcl_curr,
           tax_rate_id,
           extract_source_ledger,
           ledger_id
     FROM  zx_rep_trx_detail_t
     WHERE request_id = c_request_id
       AND extract_source_ledger = c_source_ledger;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
       FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable.BEGIN',
                                      'zx_jg_extract.get_taxable()+');
    END IF;

    PG_DEBUG := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

    IF p_trl_global_variables_rec.report_name = 'ZXJGTAX' THEN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable',
           'initialize Call '||p_trl_global_variables_rec.report_name);
      END IF;

      -- Set values from TRL global variables

      initialize(p_trl_global_variables_rec,
                 l_func_precision,
                 l_func_min_account_unit,
                 l_sob_type);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable',
           'Get gl taxable transactions ');
      END IF;

-- 8411005 : commenting out the loop by loop execution
--           and directly using sql to fetch the data instead of sequential
--           query and inserting data into zx_rep_trx_jx_ext_t table
/***
      OPEN c_trl_itf(p_trl_global_variables_rec.request_id, 'GL');
      FETCH c_trl_itf BULK COLLECT INTO p_detail_tax_line_id_tbl,
                                        p_trx_id_tbl,
                                        p_tax_line_id_tbl,
                                        p_trx_line_id_tbl,
                                        p_tax_dist_id_tbl,
                                        p_event_class_code_tbl,
                                        p_taxable_amt_tbl,
                                        p_tax_amt_tbl,
                                        p_tax_amt_funcl_curr_tbl,
                                        p_tax_rate_id_tbl,
                                        p_extract_source_ledger_tbl,
                                        p_ledger_id_tbl;
      CLOSE c_trl_itf;

      IF p_detail_tax_line_id_tbl.count > 0 THEN

        -- Get taxable amount
        get_gl_taxable(p_detail_tax_line_id_tbl,
                       p_trx_id_tbl,
                       p_tax_line_id_tbl,
                       p_trx_line_id_tbl,
      -- p_tax_dist_id_tbl,
                       l_detail_tax_line_id_tbl,
                       l_ccid_tbl,
                       l_acct_date_tbl,
                       l_taxable_amt_tbl,
                       l_taxable_amt_funcl_curr_tbl,
                       l_tax_amt_tbl,
                       l_tax_amt_funcl_curr_tbl);

        -- Set accounting info
        --set_accounting_info(l_ccid_tbl);

        -- Insert accounting infor and prorated amount into TRL interface table
        insert_row(p_detail_tax_line_id_tbl,
                   l_taxable_amt_tbl,
                   l_taxable_amt_funcl_curr_tbl,
                   l_tax_amt_tbl,
                   l_tax_amt_funcl_curr_tbl,
                   l_ccid_tbl,
                   l_acct_date_tbl);

        -- Reset result table
        reset_result_tables(p_detail_tax_line_id_tbl,
                            p_trx_id_tbl,
                            p_tax_line_id_tbl,
                            p_trx_line_id_tbl,
                            p_tax_dist_id_tbl,
                            p_event_class_code_tbl,
                            p_taxable_amt_tbl,
                            p_tax_amt_tbl,
                            p_tax_amt_funcl_curr_tbl,
                            p_tax_rate_id_tbl,
                            p_extract_source_ledger_tbl,
                            p_ledger_id_tbl,
                            l_detail_tax_line_id_tbl,
                            l_taxable_amt_tbl,
                            l_taxable_amt_funcl_curr_tbl,
                            l_tax_amt_tbl,
                            l_tax_amt_funcl_curr_tbl,
                            l_ccid_tbl,
                            l_acct_date_tbl);

      END IF;
***/

       INSERT INTO zx_rep_trx_jx_ext_t (
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         detail_tax_line_ext_id,
         detail_tax_line_id,
         numeric1,
         numeric2,
         numeric3,
         numeric4
         )
       SELECT
         g_request_id,
         g_user_id,
         g_today,
         g_user_id,
         g_today,
         g_login_id,
         zx_rep_trx_jx_ext_t_s.NEXTVAL,
         detail_tax_line_id,
         taxable_amt,
         taxable_amt_funcl_curr,
         tax_amt,
         tax_amt_funcl_curr
       FROM (
           SELECT  itf.detail_tax_line_id,
                   itf.taxable_amt,
                   itf.taxable_amt_funcl_curr,
                   itf.tax_amt,
                   itf.tax_amt_funcl_curr
              FROM zx_rep_trx_detail_t itf
             WHERE itf.request_id = g_request_id
               and itf.extract_source_ledger = 'GL'
               and itf.application_id = 101
               and itf.entity_code = 'GL_JE_LINES'
           );

      -- For AP transactions
      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable',
           'Get AP taxable transactions ');
      END IF;

-- 8247493 : commenting out the loop by loop execution
--           and directly using sql to fetch the data instead of sequential
--           query and inserting data into zx_rep_trx_jx_ext_t table
/***
      OPEN c_trl_itf(p_trl_global_variables_rec.request_id, 'AP');
      FETCH c_trl_itf BULK COLLECT INTO p_detail_tax_line_id_tbl,
                                        p_trx_id_tbl,
                                        p_tax_line_id_tbl,
                                        p_trx_line_id_tbl,
                                        p_tax_dist_id_tbl,
                                        p_event_class_code_tbl,
                                        p_taxable_amt_tbl,
                                        p_tax_amt_tbl,
                                        p_tax_amt_funcl_curr_tbl,
                                        p_tax_rate_id_tbl,
                                        p_extract_source_ledger_tbl,
                                        p_ledger_id_tbl;
      CLOSE c_trl_itf;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable',
           'Rows fetched from c_trl_itf :'||to_char(p_detail_tax_line_id_tbl.count));
      END IF;

      IF p_detail_tax_line_id_tbl.count > 0 THEN
        get_ap_taxable(p_detail_tax_line_id_tbl,
                       p_trx_id_tbl,
                       p_tax_line_id_tbl,
                       p_trx_line_id_tbl,
                       p_tax_dist_id_tbl,
                       p_ledger_id_tbl,
                       l_detail_tax_line_id_tbl,
                       l_ccid_tbl,
                       l_acct_date_tbl,
                       l_taxable_amt_tbl,
                       l_taxable_amt_funcl_curr_tbl,
                       l_tax_amt_tbl,
                       l_tax_amt_funcl_curr_tbl);

        -- Set accounting info
        --set_accounting_info(l_ccid_tbl);

        -- Insert accounting infor and prorated amount into TRL interface table
        insert_row(l_detail_tax_line_id_tbl,
                   l_taxable_amt_tbl,
                   l_taxable_amt_funcl_curr_tbl,
                   l_tax_amt_tbl,
                   l_tax_amt_funcl_curr_tbl,
                   l_ccid_tbl,
                   l_acct_date_tbl);

        -- Reset result table
        reset_result_tables(p_detail_tax_line_id_tbl,
                            p_trx_id_tbl,
                            p_tax_line_id_tbl,
                            p_trx_line_id_tbl,
                            p_tax_dist_id_tbl,
                            p_event_class_code_tbl,
                            p_taxable_amt_tbl,
                            p_tax_amt_tbl,
                            p_tax_amt_funcl_curr_tbl,
                            p_tax_rate_id_tbl,
                            p_extract_source_ledger_tbl,
                            p_ledger_id_tbl,
                            l_detail_tax_line_id_tbl,
                            l_taxable_amt_tbl,
                            l_taxable_amt_funcl_curr_tbl,
                            l_tax_amt_tbl,
                            l_tax_amt_funcl_curr_tbl,
                            l_ccid_tbl,
                            l_acct_date_tbl);
      END IF;
***/

       INSERT INTO zx_rep_trx_jx_ext_t (
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         detail_tax_line_ext_id,
         detail_tax_line_id,
         numeric1,
         numeric2,
         numeric3,
         numeric4
         )
       SELECT
         g_request_id,
         g_user_id,
         g_today,
         g_user_id,
         g_today,
         g_login_id,
         zx_rep_trx_jx_ext_t_s.NEXTVAL,
         detail_tax_line_id,
         CASE WHEN tax_line_change= 1 OR (NVL(reverse_flag,'N') = 'Y' AND recoverable_flag = 'N') THEN taxable_amt
              ELSE 0
         END,
         CASE WHEN tax_line_change= 1 OR (NVL(reverse_flag,'N') = 'Y' AND recoverable_flag = 'N') THEN taxable_amt_funcl_curr
              ELSE 0
         END,
         rec_nrec_tax_amt,
         rec_nrec_tax_amt_funcl_curr
      FROM (
        SELECT /*+ leading(trl_tmp) parallel(trl_tmp) use_nl(trl_tmp zx_dist lnk) */
               trl_tmp.detail_tax_line_id,
               ael.code_combination_id,
               aeh.accounting_date,
               zx_dist.rec_nrec_tax_amt,
               NVL(zx_dist.rec_nrec_tax_amt_funcl_curr,zx_dist.rec_nrec_tax_amt) rec_nrec_tax_amt_funcl_curr,
               zx_dist.taxable_amt,
               NVL(zx_dist.taxable_amt_funcl_curr,zx_dist.taxable_amt) taxable_amt_funcl_curr,
               zx_dist.reverse_flag,
               zx_dist.recoverable_flag,
               RANK() OVER (PARTITION BY zx_dist.trx_id,
                                         zx_dist.trx_line_id
                            ORDER BY NVL(zx_dist.reverse_flag,'N'),
                                     NVL(zx_dist.RECOVERABLE_FLAG,'N'),
                                     zx_dist.rec_nrec_tax_dist_id,
                                     trl_tmp.detail_tax_line_id
                            ) AS tax_line_change
        FROM zx_rep_trx_detail_t    trl_tmp,
             zx_rep_actg_ext_t      act,
             zx_rec_nrec_dist       zx_dist,
             xla_distribution_links lnk,
             xla_ae_headers         aeh,
             xla_ae_lines           ael,
             xla_acct_class_assgns  acs,
             xla_assignment_defns_b asd
        WHERE trl_tmp.request_id            = g_request_id
          AND trl_tmp.extract_source_ledger = 'AP'
          AND trl_tmp.entity_code           = 'AP_INVOICES'
          AND trl_tmp.detail_tax_line_id    = act.detail_tax_line_id
          AND zx_dist.application_id        = trl_tmp.application_id
          AND zx_dist.entity_code           = trl_tmp.entity_code
          AND zx_dist.event_class_code      = trl_tmp.event_class_code
          AND zx_dist.trx_id                = trl_tmp.trx_id
          AND zx_dist.trx_line_id           = trl_tmp.trx_line_id
          AND zx_dist.tax_line_id           = trl_tmp.tax_line_id
          AND zx_dist.rec_nrec_tax_dist_id     = trl_tmp.actg_source_id
          AND lnk.source_distribution_id_num_1 = zx_dist.trx_line_dist_id
          AND lnk.application_id               = 200
          AND lnk.source_distribution_type     = 'AP_INV_DIST'
          AND lnk.ae_header_id          = act.actg_header_id
          AND lnk.event_id              = act.actg_event_id
          AND lnk.ae_header_id          = ael.ae_header_id
          AND lnk.ae_line_num           = ael.ae_line_num
          AND ael.application_id        = lnk.application_id
          AND ael.ledger_id             = trl_tmp.ledger_id
          AND aeh.application_id        = lnk.application_id
          AND aeh.event_id              = lnk.event_id
          AND aeh.ae_header_id          = ael.ae_header_id
          AND acs.accounting_class_code = ael.accounting_class_code
          AND acs.program_code          = 'TAX_REP_LEDGER_PROCUREMENT'
          AND acs.program_owner_code    = asd.program_owner_code
          AND acs.program_code          = asd.program_code
          AND acs.assignment_owner_code = asd.assignment_owner_code
          AND acs.assignment_code       = asd.assignment_code
          AND asd.enabled_flag          = 'Y'
      UNION ALL
        SELECT /*+ leading(trl_tmp) parallel(trl_tmp) use_nl(trl_tmp zx_dist lnk) */
               trl_tmp.detail_tax_line_id,
               ael.code_combination_id,
               aeh.accounting_date,
               zx_dist.rec_nrec_tax_amt,
               NVL(zx_dist.rec_nrec_tax_amt_funcl_curr,zx_dist.rec_nrec_tax_amt) rec_nrec_tax_amt_funcl_curr,
               zx_dist.taxable_amt,
               NVL(zx_dist.taxable_amt_funcl_curr,zx_dist.taxable_amt) taxable_amt_funcl_curr,
               zx_dist.reverse_flag,
               zx_dist.recoverable_flag,
               RANK() OVER (PARTITION BY zx_dist.trx_id,
                                         zx_dist.trx_line_id
                            ORDER BY NVL(zx_dist.reverse_flag,'N'),
                                     NVL(zx_dist.RECOVERABLE_FLAG,'N'),
                                     zx_dist.rec_nrec_tax_dist_id,
                                     trl_tmp.detail_tax_line_id
                            ) AS tax_line_change
        FROM zx_rep_trx_detail_t          trl_tmp,
             zx_rep_actg_ext_t            act,
             zx_rec_nrec_dist             zx_dist,
             ap_invoice_distributions_all ap_dist,
             ap_prepay_app_dists          pre_dist,
             xla_ae_headers               aeh,
             xla_distribution_links       lnk,
             xla_ae_lines                 ael,
             xla_acct_class_assgns        acs,
             xla_assignment_defns_b       asd
       WHERE trl_tmp.request_id            = g_request_id
         AND trl_tmp.extract_source_ledger = 'AP'
         AND trl_tmp.entity_code           = 'AP_INVOICES'
         AND trl_tmp.event_class_code      = 'STANDARD INVOICES'
         AND trl_tmp.detail_tax_line_id    = act.detail_tax_line_id
         AND zx_dist.application_id        = trl_tmp.application_id
         AND zx_dist.entity_code           = trl_tmp.entity_code
         AND zx_dist.event_class_code      = trl_tmp.event_class_code
         AND zx_dist.trx_id                = trl_tmp.trx_id
         AND zx_dist.trx_line_id           = trl_tmp.trx_line_id
         AND zx_dist.tax_line_id           = trl_tmp.tax_line_id
         AND zx_dist.trx_level_type        = 'LINE'
         AND zx_dist.rec_nrec_tax_dist_id  = trl_tmp.actg_source_id
         AND ap_dist.invoice_id            = zx_dist.trx_id
         AND ap_dist.line_type_lookup_code = 'ITEM'
         AND pre_dist.prepay_app_distribution_id = zx_dist.trx_line_dist_id
         AND pre_dist.prepay_dist_lookup_code  = 'PREPAY APPL'
         AND pre_dist.invoice_distribution_id  = ap_dist.invoice_distribution_id
         AND lnk.source_distribution_id_num_1  = pre_dist.prepay_app_dist_id
         AND lnk.application_id                = 200
         AND lnk.source_distribution_type      = 'AP_PREPAY'
         AND lnk.ae_header_id           = act.actg_header_id
         AND lnk.event_id               = act.actg_event_id
         AND lnk.ae_header_id           = ael.ae_header_id
         AND lnk.ae_line_num            = ael.ae_line_num
         AND lnk.application_id         = zx_dist.application_id
         AND ael.application_id         = lnk.application_id
         AND ael.ledger_id              = trl_tmp.ledger_id
         AND ael.accounting_class_code <> 'LIABILITY'
         AND aeh.application_id         = lnk.application_id
         AND aeh.event_id               = lnk.event_id
         AND aeh.ae_header_id           = ael.ae_header_id
         AND acs.accounting_class_code  = ael.accounting_class_code
         AND acs.program_code           = 'TAX_REP_LEDGER_PROCUREMENT'
         AND acs.program_owner_code     = asd.program_owner_code
         AND acs.program_code           = asd.program_code
         AND acs.assignment_owner_code  = asd.assignment_owner_code
         AND asd.assignment_code        = acs.assignment_code
         AND asd.enabled_flag           = 'Y'
        );

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable',
           'Get AR taxable transactions ');
      END IF;

      -- For AR Transactions

      OPEN c_trl_itf(p_trl_global_variables_rec.request_id, 'AR');
      FETCH c_trl_itf BULK COLLECT INTO p_detail_tax_line_id_tbl,
                                        p_trx_id_tbl,
                                        p_tax_line_id_tbl,
                                        p_trx_line_id_tbl,
                                        p_tax_dist_id_tbl,
                                        p_event_class_code_tbl,
                                        p_taxable_amt_tbl,
                                        p_taxable_amt_funcl_curr_tbl,
                                        p_tax_amt_tbl,
                                        p_tax_amt_funcl_curr_tbl,
                                        p_tax_rate_id_tbl,
                                        p_extract_source_ledger_tbl,
                                        p_ledger_id_tbl;
      CLOSE c_trl_itf;

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable',
           'After c_trl_itf Cursor Call for AR taxable transactions ');
      END IF;

      IF p_detail_tax_line_id_tbl.count > 0 THEN
        get_ar_taxable(p_detail_tax_line_id_tbl,
                       p_event_class_code_tbl,
                       p_trx_id_tbl,
                       p_tax_line_id_tbl,
                       p_trx_line_id_tbl,
                      -- p_tax_dist_id_tbl,
                       p_taxable_amt_tbl,
                       p_taxable_amt_funcl_curr_tbl,
                       p_tax_amt_tbl,
                       p_tax_amt_funcl_curr_tbl,
                       p_tax_rate_id_tbl,
                       l_sob_type,
                       l_func_precision,
                       l_func_min_account_unit,
                       l_detail_tax_line_id_tbl,
                       l_ccid_tbl,
                       l_acct_date_tbl,
                       l_taxable_amt_tbl,
                       l_taxable_amt_funcl_curr_tbl,
                       l_tax_amt_tbl,
                       l_tax_amt_funcl_curr_tbl);
        -- Set accounting info
        --set_accounting_info(l_ccid_tbl);

        -- Insert accounting infor and prorated amount into TRL interface table
        IF (g_level_procedure >= g_current_runtime_level ) THEN
          FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable',
             'insert_row API call ');
        END IF;

        insert_row(l_detail_tax_line_id_tbl,
                   l_taxable_amt_tbl,
                   l_taxable_amt_funcl_curr_tbl,
                   l_tax_amt_tbl,
                   l_tax_amt_funcl_curr_tbl);

      END IF; -- IF p_detail_tax_line_id_tbl.count > 0

    END IF; -- IF report_name = ..
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure, 'ZX.TRL.zx_jg_extract.get_taxable.END',
         'zx_jg_extract_pkg.get_taxable()- ');
    END IF;

  END get_taxable;

END zx_jg_extract_pkg;

/
