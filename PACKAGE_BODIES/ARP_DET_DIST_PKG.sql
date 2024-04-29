--------------------------------------------------------
--  DDL for Package Body ARP_DET_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_DET_DIST_PKG" AS
/* $Header: ARPDDB.pls 120.57.12010000.74 2010/08/03 06:46:09 nemani ship $ */

--{HYU possible_adj
TYPE g_amt_rem_type  IS RECORD (
   sum_tax_amt_rem              NUMBER,
   sum_tax_acctd_amt_rem        NUMBER,
   sum_line_amt_rem             NUMBER,
   sum_line_acctd_amt_rem       NUMBER,
   sum_frt_amt_rem              NUMBER,
   sum_frt_acctd_amt_rem        NUMBER,
   sum_all_amt_rem              NUMBER,
   sum_all_acctd_amt_rem        NUMBER,
   sum_line_frt_amt_rem         NUMBER,
   sum_line_frt_acctd_amt_rem   NUMBER,
   --
   sum_head_frt_amt_rem         NUMBER,
   sum_head_frt_acctd_amt_rem   NUMBER,
   --
   sum_chrg_amt_rem             NUMBER,
   sum_chrg_acctd_amt_rem       NUMBER,
   -- Need to display the amount original
   sum_tax_amt_orig             NUMBER,
   sum_tax_acctd_amt_orig       NUMBER,
   sum_line_amt_orig            NUMBER,
   sum_line_acctd_amt_orig      NUMBER,
   sum_frt_amt_orig             NUMBER,
   sum_frt_acctd_amt_orig       NUMBER,
   --
   sum_line_chrg_amt_rem        NUMBER,
   sum_line_chrg_acctd_amt_rem  NUMBER,
   sum_frt_chrg_amt_rem         NUMBER,
   sum_frt_chrg_acctd_amt_rem   NUMBER,
   --
   sum_head_frt_amt_orig        NUMBER,
   sum_line_frt_amt_orig        NUMBER,
   sum_head_frt_acctd_amt_orig  NUMBER,
   sum_line_frt_acctd_amt_orig  NUMBER,
   tl_for_rl                    VARCHAR2(1),
   tl_for_fl                    VARCHAR2(1) );
--}

g_rowid_tab  DBMS_SQL.VARCHAR2_TABLE;

PROCEDURE localdebug(p_txt  IN VARCHAR2);

PROCEDURE display_ra_ar_gt
(p_code  IN VARCHAR2 DEFAULT NULL,
 p_gt_id IN VARCHAR2);

PROCEDURE display_cust_trx_gt(p_customer_trx_id IN NUMBER);
/*
PROCEDURE br_set_original_rem_amt
(p_customer_trx_id     IN NUMBER);
*/
--}

g_bulk_fetch_rows      NUMBER := 10000;
g_ed_req               VARCHAR2(1) := 'N';
g_uned_req             VARCHAR2(1) := 'N';
g_cm_trx_id            NUMBER := null;
g_cm_upg_mthd          VARCHAR2(30);
g_gt_id                VARCHAR2(30);
--{BUG4414391
--g_se_gt_id             NUMBER := USERENV('SESSIONID');
--}

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

--{BUG#4414391
g_source_table     VARCHAR2(30) DEFAULT NULL;
g_line_flag        VARCHAR2(30) DEFAULT 'NORMAL';
g_tax_flag         VARCHAR2(30) DEFAULT 'NORMAL';
g_freight_flag     VARCHAR2(30) DEFAULT 'NORMAL';
g_charges_flag     VARCHAR2(30) DEFAULT 'NORMAL';
g_ed_line_flag     VARCHAR2(30) DEFAULT 'NORMAL';
g_ed_tax_flag      VARCHAR2(30) DEFAULT 'NORMAL';
g_uned_line_flag   VARCHAR2(30) DEFAULT 'NORMAL';
g_uned_tax_flag    VARCHAR2(30) DEFAULT 'NORMAL';
--}

l_sob_list             gl_ca_utility_pkg.r_sob_list;
previous_org_id        NUMBER(15);
previous_sob_id        NUMBER(15);
previous_ctx_id        NUMBER(15);
previous_pk_id_one     NUMBER;
previous_pk_id_two     NUMBER;

g_line_adj             NUMBER := 0;
g_tax_adj              NUMBER := 0;
g_frt_adj              NUMBER := 0;
g_chrg_adj             NUMBER := 0;
g_line_applied         NUMBER := 0;
g_tax_applied          NUMBER := 0;
g_frt_applied          NUMBER := 0;
g_chrg_applied         NUMBER := 0;
g_line_ed              NUMBER := 0;
g_tax_ed               NUMBER := 0;
g_frt_ed               NUMBER := 0;
g_chrg_ed              NUMBER := 0;
g_line_uned            NUMBER := 0;
g_tax_uned             NUMBER := 0;
g_frt_uned             NUMBER := 0;
g_chrg_uned            NUMBER := 0;
   --
g_acctd_line_adj       NUMBER := 0;
g_acctd_tax_adj        NUMBER := 0;
g_acctd_frt_adj        NUMBER := 0;
g_acctd_chrg_adj       NUMBER := 0;
g_acctd_line_applied   NUMBER := 0;
g_acctd_tax_applied    NUMBER := 0;
g_acctd_frt_applied    NUMBER := 0;
g_acctd_chrg_applied   NUMBER := 0;
g_acctd_line_ed        NUMBER := 0;
g_acctd_tax_ed         NUMBER := 0;
g_acctd_frt_ed         NUMBER := 0;
g_acctd_chrg_ed        NUMBER := 0;
g_acctd_line_uned      NUMBER := 0;
g_acctd_tax_uned       NUMBER := 0;
g_acctd_frt_uned       NUMBER := 0;
g_acctd_chrg_uned      NUMBER := 0;

g_cust_inv_rec         ra_customer_trx%ROWTYPE;

--{
g_run_from_amt               NUMBER;
g_run_from_total             NUMBER;
g_run_from_acctd_amt         NUMBER;
g_run_from_acctd_total       NUMBER;
g_current_trx_id             NUMBER;
--}

--{CASH and MFAR legacy
g_mode_process               VARCHAR2(30) := 'R12';
--}

--{HYU upgrade cash basis
g_upgrade_mode              VARCHAR2(30) := 'N';
g_currency_code             VARCHAR2(30);
g_org_id                    NUMBER;


--{FRT and CHRG
g_trx_line_frt             VARCHAR2(1) := 'N';
g_trx_line_chrg            VARCHAR2(1) := 'N';
--}

--HY Cash Basis Upgrade
FUNCTION CurrRound
( p_amount        IN NUMBER,
  p_currency_code IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER;


PROCEDURE conv_acctd_amt
  (p_pay_adj              IN VARCHAR2,
   p_adj_rec              IN ar_adjustments%ROWTYPE,
   p_app_rec              IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type);

PROCEDURE conv_acctd_amt_upg
  (p_pay_adj              IN VARCHAR2,
   p_adj_rec              IN ar_adjustments%ROWTYPE,
   p_app_rec              IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type);

PROCEDURE update_taxable
(p_gt_id             IN VARCHAR2,
 p_customer_trx_id   IN NUMBER,
 p_ae_sys_rec        IN arp_acct_main.ae_sys_rec_type);


PROCEDURE convert_ra_inv_to_cm
( p_inv_ra_rec     IN         ar_receivable_applications%ROWTYPE,
  p_cm_trx_id      IN         NUMBER,
  x_cm_ra_rec      IN OUT NOCOPY ar_receivable_applications%ROWTYPE,
  p_mode           IN         VARCHAR2 DEFAULT 'OLTP',
  p_gt_id          IN         VARCHAR2 DEFAULT NULL,
  p_from_llca      IN         VARCHAR2 DEFAULT 'N',
  p_upg_cm        IN          VARCHAR2 DEFAULT 'N');

/*-------------------------------------------------------------------------+
 | Routine elementary and data structure                                   |
 +-------------------------------------------------------------------------*/
TYPE gt_record    IS RECORD (gt_id      NUMBER,
                             app_level  VARCHAR2(30),
                             app_rec    ar_receivable_applications%ROWTYPE);

TYPE gt_tab_type  IS TABLE of gt_record INDEX BY BINARY_INTEGER;
g_gt_tab       gt_tab_type;
clear_gt_tab   gt_tab_type;

TYPE CHAR_HASH_TABLE IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(2000);

--
-- Structure to keep the input amount and the output amount of the proration
--
TYPE pro_res_tbl_type IS RECORD
( -- Groupe
  GROUPE                              DBMS_SQL.VARCHAR2_TABLE,
  -- Base
     -- ADJ and APP
     base_pro_amt                     DBMS_SQL.NUMBER_TABLE,
     base_pro_acctd_amt               DBMS_SQL.NUMBER_TABLE,
     BASE_CHRG_PRO_AMT                DBMS_SQL.NUMBER_TABLE,
     BASE_CHRG_PRO_ACCTD_AMT          DBMS_SQL.NUMBER_TABLE,
     base_frt_pro_amt                 DBMS_SQL.NUMBER_TABLE,
     base_frt_pro_acctd_amt           DBMS_SQL.NUMBER_TABLE,
     base_tax_pro_amt                 DBMS_SQL.NUMBER_TABLE,
     base_tax_pro_acctd_amt           DBMS_SQL.NUMBER_TABLE,
     -- ED
     base_ed_pro_amt                  DBMS_SQL.NUMBER_TABLE,
     base_ed_pro_acctd_amt            DBMS_SQL.NUMBER_TABLE,
     BASE_ed_CHRG_PRO_AMT             DBMS_SQL.NUMBER_TABLE,
     BASE_ed_CHRG_PRO_ACCTD_AMT       DBMS_SQL.NUMBER_TABLE,
     base_ed_frt_pro_amt              DBMS_SQL.NUMBER_TABLE,
     base_ed_frt_pro_acctd_amt        DBMS_SQL.NUMBER_TABLE,
     base_ed_tax_pro_amt              DBMS_SQL.NUMBER_TABLE,
     base_ed_tax_pro_acctd_amt        DBMS_SQL.NUMBER_TABLE,
     -- UNED
     base_uned_pro_amt                DBMS_SQL.NUMBER_TABLE,
     base_uned_pro_acctd_amt          DBMS_SQL.NUMBER_TABLE,
     BASE_uned_CHRG_PRO_AMT           DBMS_SQL.NUMBER_TABLE,
     BASE_uned_CHRG_PRO_ACCTD_AMT     DBMS_SQL.NUMBER_TABLE,
     base_uned_frt_pro_amt            DBMS_SQL.NUMBER_TABLE,
     base_uned_frt_pro_acctd_amt      DBMS_SQL.NUMBER_TABLE,
     base_uned_tax_pro_amt            DBMS_SQL.NUMBER_TABLE,
     base_uned_tax_pro_acctd_amt      DBMS_SQL.NUMBER_TABLE,
  -- Element numerator
     -- ADJ and APP
     elmt_pro_amt                     DBMS_SQL.NUMBER_TABLE,
     elmt_pro_acctd_amt               DBMS_SQL.NUMBER_TABLE,
     ELMT_CHRG_PRO_AMT                DBMS_SQL.NUMBER_TABLE,
     ELMT_CHRG_PRO_ACCTD_AMT          DBMS_SQL.NUMBER_TABLE,
     elmt_frt_pro_amt                 DBMS_SQL.NUMBER_TABLE,
     elmt_frt_pro_acctd_amt           DBMS_SQL.NUMBER_TABLE,
     elmt_tax_pro_amt                 DBMS_SQL.NUMBER_TABLE,
     elmt_tax_pro_acctd_amt           DBMS_SQL.NUMBER_TABLE,
     -- ED
     elmt_ed_pro_amt                  DBMS_SQL.NUMBER_TABLE,
     elmt_ed_pro_acctd_amt            DBMS_SQL.NUMBER_TABLE,
     ELMT_ed_CHRG_PRO_AMT             DBMS_SQL.NUMBER_TABLE,
     ELMT_ed_CHRG_PRO_ACCTD_AMT       DBMS_SQL.NUMBER_TABLE,
     elmt_ed_frt_pro_amt              DBMS_SQL.NUMBER_TABLE,
     elmt_ed_frt_pro_acctd_amt        DBMS_SQL.NUMBER_TABLE,
     elmt_ed_tax_pro_amt              DBMS_SQL.NUMBER_TABLE,
     elmt_ed_tax_pro_acctd_amt        DBMS_SQL.NUMBER_TABLE,
     -- UNED
     elmt_uned_pro_amt                DBMS_SQL.NUMBER_TABLE,
     elmt_uned_pro_acctd_amt          DBMS_SQL.NUMBER_TABLE,
     ELMT_uned_CHRG_PRO_AMT           DBMS_SQL.NUMBER_TABLE,
     ELMT_uned_CHRG_PRO_ACCTD_AMT     DBMS_SQL.NUMBER_TABLE,
     elmt_uned_frt_pro_amt            DBMS_SQL.NUMBER_TABLE,
     elmt_uned_frt_pro_acctd_amt      DBMS_SQL.NUMBER_TABLE,
     elmt_uned_tax_pro_amt            DBMS_SQL.NUMBER_TABLE,
     elmt_uned_tax_pro_acctd_amt      DBMS_SQL.NUMBER_TABLE,
  -- Amount to be allocated -- ADJ and APP
     buc_alloc_amt                    DBMS_SQL.NUMBER_TABLE,
     buc_alloc_acctd_amt              DBMS_SQL.NUMBER_TABLE,
     buc_chrg_alloc_amt               DBMS_SQL.NUMBER_TABLE,
     buc_chrg_alloc_acctd_amt         DBMS_SQL.NUMBER_TABLE,
     buc_frt_alloc_amt                DBMS_SQL.NUMBER_TABLE,
     buc_frt_alloc_acctd_amt          DBMS_SQL.NUMBER_TABLE,
     buc_tax_alloc_amt                DBMS_SQL.NUMBER_TABLE,
     buc_tax_alloc_acctd_amt          DBMS_SQL.NUMBER_TABLE,
     -- ED
     buc_ed_alloc_amt                 DBMS_SQL.NUMBER_TABLE,
     buc_ed_alloc_acctd_amt           DBMS_SQL.NUMBER_TABLE,
     buc_ed_chrg_alloc_amt            DBMS_SQL.NUMBER_TABLE,
     buc_ed_chrg_alloc_acctd_amt      DBMS_SQL.NUMBER_TABLE,
     buc_ed_frt_alloc_amt             DBMS_SQL.NUMBER_TABLE,
     buc_ed_frt_alloc_acctd_amt       DBMS_SQL.NUMBER_TABLE,
     buc_ed_tax_alloc_amt             DBMS_SQL.NUMBER_TABLE,
     buc_ed_tax_alloc_acctd_amt       DBMS_SQL.NUMBER_TABLE,
     -- UNED
     buc_uned_alloc_amt               DBMS_SQL.NUMBER_TABLE,
     buc_uned_alloc_acctd_amt         DBMS_SQL.NUMBER_TABLE,
     buc_uned_chrg_alloc_amt          DBMS_SQL.NUMBER_TABLE,
     buc_uned_chrg_alloc_acctd_amt    DBMS_SQL.NUMBER_TABLE,
     buc_uned_frt_alloc_amt           DBMS_SQL.NUMBER_TABLE,
     buc_uned_frt_alloc_acctd_amt     DBMS_SQL.NUMBER_TABLE,
     buc_uned_tax_alloc_amt           DBMS_SQL.NUMBER_TABLE,
     buc_uned_tax_alloc_acctd_amt     DBMS_SQL.NUMBER_TABLE,
  -- Currency
  FROM_CURRENCY                       DBMS_SQL.VARCHAR2_TABLE,
  TO_CURRENCY                         DBMS_SQL.VARCHAR2_TABLE,
  BASE_CURRENCY                       DBMS_SQL.VARCHAR2_TABLE,
  -- Result of the allocation
    -- ADJ and APP
    tl_alloc_amt                      DBMS_SQL.NUMBER_TABLE,
    tl_alloc_acctd_amt                DBMS_SQL.NUMBER_TABLE,
    tl_chrg_alloc_amt                 DBMS_SQL.NUMBER_TABLE,
    tl_chrg_alloc_acctd_amt           DBMS_SQL.NUMBER_TABLE,
    tl_frt_alloc_amt                  DBMS_SQL.NUMBER_TABLE,
    tl_frt_alloc_acctd_amt            DBMS_SQL.NUMBER_TABLE,
    tl_tax_alloc_amt                  DBMS_SQL.NUMBER_TABLE,
    tl_tax_alloc_acctd_amt            DBMS_SQL.NUMBER_TABLE,
    -- ED
    tl_ed_alloc_amt                   DBMS_SQL.NUMBER_TABLE,
    tl_ed_alloc_acctd_amt             DBMS_SQL.NUMBER_TABLE,
    tl_ed_chrg_alloc_amt              DBMS_SQL.NUMBER_TABLE,
    tl_ed_chrg_alloc_acctd_amt        DBMS_SQL.NUMBER_TABLE,
    tl_ed_frt_alloc_amt               DBMS_SQL.NUMBER_TABLE,
    tl_ed_frt_alloc_acctd_amt         DBMS_SQL.NUMBER_TABLE,
    tl_ed_tax_alloc_amt               DBMS_SQL.NUMBER_TABLE,
    tl_ed_tax_alloc_acctd_amt         DBMS_SQL.NUMBER_TABLE,
    -- UNED
    tl_uned_alloc_amt                 DBMS_SQL.NUMBER_TABLE,
    tl_uned_alloc_acctd_amt           DBMS_SQL.NUMBER_TABLE,
    tl_uned_chrg_alloc_amt            DBMS_SQL.NUMBER_TABLE,
    tl_uned_chrg_alloc_acctd_amt      DBMS_SQL.NUMBER_TABLE,
    tl_uned_frt_alloc_amt             DBMS_SQL.NUMBER_TABLE,
    tl_uned_frt_alloc_acctd_amt       DBMS_SQL.NUMBER_TABLE,
    tl_uned_tax_alloc_amt             DBMS_SQL.NUMBER_TABLE,
    tl_uned_tax_alloc_acctd_amt       DBMS_SQL.NUMBER_TABLE,
  --
  ROWID_ID                            DBMS_SQL.VARCHAR2_TABLE);

--
-- Internal structure for safety on proration
--
TYPE group_tbl_type IS RECORD
( GROUPE                      DBMS_SQL.VARCHAR2_TABLE,
  -- ADJ and APP
  RUN_ALLOC                   DBMS_SQL.NUMBER_TABLE,
  RUN_ACCTD_ALLOC             DBMS_SQL.NUMBER_TABLE,
  RUN_AMT                     DBMS_SQL.NUMBER_TABLE,
  RUN_ACCTD_AMT               DBMS_SQL.NUMBER_TABLE,
  RUN_CHRG_ALLOC              DBMS_SQL.NUMBER_TABLE,
  RUN_CHRG_ACCTD_ALLOC        DBMS_SQL.NUMBER_TABLE,
  RUN_CHRG_AMT                DBMS_SQL.NUMBER_TABLE,
  RUN_CHRG_ACCTD_AMT          DBMS_SQL.NUMBER_TABLE,
  RUN_FRT_ALLOC               DBMS_SQL.NUMBER_TABLE,
  RUN_FRT_ACCTD_ALLOC         DBMS_SQL.NUMBER_TABLE,
  RUN_FRT_AMT                 DBMS_SQL.NUMBER_TABLE,
  RUN_FRT_ACCTD_AMT           DBMS_SQL.NUMBER_TABLE,
  RUN_TAX_ALLOC               DBMS_SQL.NUMBER_TABLE,
  RUN_TAX_ACCTD_ALLOC         DBMS_SQL.NUMBER_TABLE,
  RUN_TAX_AMT                 DBMS_SQL.NUMBER_TABLE,
  RUN_TAX_ACCTD_AMT           DBMS_SQL.NUMBER_TABLE,
  -- ED
  RUN_ED_ALLOC                DBMS_SQL.NUMBER_TABLE,
  RUN_ED_ACCTD_ALLOC          DBMS_SQL.NUMBER_TABLE,
  RUN_ED_AMT                  DBMS_SQL.NUMBER_TABLE,
  RUN_ED_ACCTD_AMT            DBMS_SQL.NUMBER_TABLE,
  RUN_ED_CHRG_ALLOC           DBMS_SQL.NUMBER_TABLE,
  RUN_ED_CHRG_ACCTD_ALLOC     DBMS_SQL.NUMBER_TABLE,
  RUN_ED_CHRG_AMT             DBMS_SQL.NUMBER_TABLE,
  RUN_ED_CHRG_ACCTD_AMT       DBMS_SQL.NUMBER_TABLE,
  RUN_ED_FRT_ALLOC            DBMS_SQL.NUMBER_TABLE,
  RUN_ED_FRT_ACCTD_ALLOC      DBMS_SQL.NUMBER_TABLE,
  RUN_ED_FRT_AMT              DBMS_SQL.NUMBER_TABLE,
  RUN_ED_FRT_ACCTD_AMT        DBMS_SQL.NUMBER_TABLE,
  RUN_ED_TAX_ALLOC            DBMS_SQL.NUMBER_TABLE,
  RUN_ED_TAX_ACCTD_ALLOC      DBMS_SQL.NUMBER_TABLE,
  RUN_ED_TAX_AMT              DBMS_SQL.NUMBER_TABLE,
  RUN_ED_TAX_ACCTD_AMT        DBMS_SQL.NUMBER_TABLE,
  -- UNED
  RUN_UNED_ALLOC              DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_ACCTD_ALLOC        DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_AMT                DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_ACCTD_AMT          DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_CHRG_ALLOC         DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_CHRG_ACCTD_ALLOC   DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_CHRG_AMT           DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_CHRG_ACCTD_AMT     DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_FRT_ALLOC          DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_FRT_ACCTD_ALLOC    DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_FRT_AMT            DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_FRT_ACCTD_AMT      DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_TAX_ALLOC          DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_TAX_ACCTD_ALLOC    DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_TAX_AMT            DBMS_SQL.NUMBER_TABLE,
  RUN_UNED_TAX_ACCTD_AMT      DBMS_SQL.NUMBER_TABLE,
  GROUPE_INDEX                CHAR_HASH_TABLE);


--HY Cash Basis Upgrade
FUNCTION CurrRound
( p_amount        IN NUMBER,
  p_currency_code IN VARCHAR2 DEFAULT NULL)
RETURN NUMBER
IS
  l_return    NUMBER;
BEGIN
  IF g_upgrade_mode = 'Y' THEN
  l_return    := ar_unposted_item_util.CurrRound(p_amount,g_currency_code);
  ELSE
  l_return    := ar_unposted_item_util.CurrRound(p_amount,p_currency_code);
  END IF;
  RETURN l_return;
END;


--BUG#44144391
PROCEDURE get_gt_sequence
(x_gt_id         OUT NOCOPY NUMBER,
 x_return_status IN OUT NOCOPY VARCHAR2,
 x_msg_count     IN OUT NOCOPY NUMBER,
 x_msg_data      IN OUT NOCOPY VARCHAR2)
IS
  CURSOR c_gt IS
  SELECT ar_distribution_split_s.NEXTVAL
    FROM DUAL;
  no_sequence   EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_gt_sequence()+');
  END IF;
  OPEN c_gt;
  FETCH c_gt INTO x_gt_id;
  IF c_gt%NOTFOUND THEN
    RAISE no_sequence;
  END IF;
  CLOSE c_gt;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_gt_sequence()-');
  END IF;
EXCEPTION
  WHEN no_sequence THEN
   IF c_gt%ISOPEN THEN
     CLOSE c_gt;
   END IF;
   IF PG_DEBUG = 'Y' THEN
   localdebug('EXCEPTION no_sequence in in arp_dte_dist_pkg.get_gt_sequence');
   END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
   FND_MESSAGE.SET_TOKEN( 'TEXT', 'EXCEPTION no_sequence in arp_dte_dist_pkg.get_gt_sequence');
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
END get_gt_sequence;
--}


PROCEDURE localdebug(p_txt  IN VARCHAR2) IS
BEGIN
  IF PG_DEBUG = 'Y' THEN
    arp_debug.debug(p_txt);
  END IF;
END;


PROCEDURE set_mode_process
(p_customer_trx  IN ra_customer_trx%ROWTYPE,
 p_from_llca     IN VARCHAR2 DEFAULT 'N'    )
IS
  CURSOR cu_trx IS
  SELECT * FROM ra_customer_trx
  WHERE customer_trx_id = p_customer_trx.customer_trx_id;
  l_mark     VARCHAR2(30);
BEGIN
IF PG_DEBUG = 'Y' THEN
localdebug('arp_det_dist_pkg.set_mode_process()+');
localdebug('  p_customer_trx.customer_trx_id :'||p_customer_trx.customer_trx_id);
localdebug('  p_customer_trx.upgrade_method        :'||p_customer_trx.upgrade_method);
END IF;

  IF p_customer_trx.upgrade_method IS NULL THEN
     OPEN cu_trx;
     FETCH cu_trx INTO g_cust_inv_rec;
     IF cu_trx%NOTFOUND THEN
       RAISE no_data_found;
     ELSE
       l_mark := g_cust_inv_rec.upgrade_method;
     END IF;
     CLOSE cu_trx;
  ELSE
     l_mark := p_customer_trx.upgrade_method;
  END IF;

  IF l_mark = 'R12' THEN
    g_mode_process := 'R12';
  ELSIF l_mark = 'R12_11IMFAR' THEN
    g_mode_process := 'R12_11IMFAR';
  ELSIF l_mark = 'R12_11ICASH' THEN
    g_mode_process := 'R12_11ICASH';
  --{
  ELSIF l_mark = 'R12_NLB' THEN
    g_mode_process := 'R12_NLB';
  --}
  ELSIF l_mark = 'R12_MERGE' THEN
    g_mode_process := 'R12_MERGE';
  ELSE
    g_mode_process := 'R12_NLB';
  END IF;
IF PG_DEBUG = 'Y' THEN
localdebug('  g_mode_process :'||g_mode_process);
localdebug('arp_det_dist_pkg.set_mode_process()-');
END IF;

END;
--}


PROCEDURE stamping_ra
(p_app_id    IN NUMBER)
IS
BEGIN
  --
  -- application on a 11i Mfar transaction with Mfar adjustments
  --
  IF g_mode_process = 'R12_11IMFAR' THEN

    UPDATE ar_receivable_applications
       SET upgrade_method = 'R12_11IMFAR'
     WHERE receivable_application_id = p_app_id;

  --
  -- Application on a R12 transaction
  -- Note all 11i transactions without applications will be stamped as R12
  --
  ELSIF g_mode_process IN ('R12','R12_NLB') THEN

    UPDATE ar_receivable_applications
       SET upgrade_method = 'R12'
     WHERE receivable_application_id = p_app_id;

  --
  -- application on a 11i transaction with 11i adjustments (no Mfar)
  --
  ELSIF g_mode_process = 'R12_11ICASH' THEN

    UPDATE ar_receivable_applications
       SET upgrade_method = 'R12_11ICASH'
     WHERE receivable_application_id = p_app_id;

  --application on invoice having activity/application with summarized distributions
  ELSIF g_mode_process = 'R12_MERGE' THEN

    UPDATE ar_receivable_applications
       SET upgrade_method = 'R12_MERGE'
     WHERE receivable_application_id = p_app_id;

  END IF;
END;

PROCEDURE stamping_adj
(p_adj_id    IN NUMBER)
IS
BEGIN

  -- Adjustment has upgrade_method as
  -- 11I     -- At downtime upgrade
  -- 11IMFAR -- * At 11I Mfar transaction with Mfar adjustment being applied in R12
  --              done in set_original_rem_amt procedure
  --            * At extracted posting time if the adjustment is marked as 11I
  --              we need to update this flag to retrieve Mfar distributions
  --            Note this process is needed when application is getting posted
  -- R12     -- At the end of nornal process
  IF g_mode_process IN ('R12','R12_NLB','R12_11ICASH','R12_11IMFAR') THEN

    UPDATE ar_adjustments
       SET upgrade_method = 'R12'
     WHERE adjustment_id = p_adj_id;

  ELSIF g_mode_process IN ('R12_MERGE') THEN
    UPDATE ar_adjustments
       SET upgrade_method = 'R12_MERGE'
     WHERE adjustment_id = p_adj_id;
  END IF;
END;


--
-- Function procedure declaration
--
/*-----------------------------------------------------------------------+
 | plsql_proration                                                       |
 +-----------------------------------------------------------------------+
 | Does the proration based on the input pro_res_tbl_type parameter      |
 | structure                                                             |
 +-----------------------------------------------------------------------+
 | parameter IN OUT pro_res_tbl_type                                     |
 +-----------------------------------------------------------------------*/
PROCEDURE plsql_proration
( x_tab                  IN OUT NOCOPY pro_res_tbl_type,
  x_group_tbl            IN OUT NOCOPY group_tbl_type,
  p_group_level          IN VARCHAR2 DEFAULT 'NOGROUP',
  -- ADJ and APP
  x_run_amt              IN OUT NOCOPY NUMBER,
  x_run_alloc            IN OUT NOCOPY NUMBER,
  x_run_acctd_amt        IN OUT NOCOPY NUMBER,
  x_run_acctd_alloc      IN OUT NOCOPY NUMBER,
  x_run_chrg_amt         IN OUT NOCOPY NUMBER,
  x_run_chrg_alloc       IN OUT NOCOPY NUMBER,
  x_run_chrg_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_chrg_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_frt_amt         IN OUT NOCOPY NUMBER,
  x_run_frt_alloc       IN OUT NOCOPY NUMBER,
  x_run_frt_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_frt_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_tax_amt         IN OUT NOCOPY NUMBER,
  x_run_tax_alloc       IN OUT NOCOPY NUMBER,
  x_run_tax_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_tax_acctd_alloc IN OUT NOCOPY NUMBER,
  -- ED
  x_run_ed_amt              IN OUT NOCOPY NUMBER,
  x_run_ed_alloc            IN OUT NOCOPY NUMBER,
  x_run_ed_acctd_amt        IN OUT NOCOPY NUMBER,
  x_run_ed_acctd_alloc      IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_amt         IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_alloc       IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_ed_frt_amt         IN OUT NOCOPY NUMBER,
  x_run_ed_frt_alloc       IN OUT NOCOPY NUMBER,
  x_run_ed_frt_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_ed_frt_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_ed_tax_amt         IN OUT NOCOPY NUMBER,
  x_run_ed_tax_alloc       IN OUT NOCOPY NUMBER,
  x_run_ed_tax_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_ed_tax_acctd_alloc IN OUT NOCOPY NUMBER,
  -- UNED
  x_run_uned_amt              IN OUT NOCOPY NUMBER,
  x_run_uned_alloc            IN OUT NOCOPY NUMBER,
  x_run_uned_acctd_amt        IN OUT NOCOPY NUMBER,
  x_run_uned_acctd_alloc      IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_amt         IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_alloc       IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_uned_frt_amt         IN OUT NOCOPY NUMBER,
  x_run_uned_frt_alloc       IN OUT NOCOPY NUMBER,
  x_run_uned_frt_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_uned_frt_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_uned_tax_amt         IN OUT NOCOPY NUMBER,
  x_run_uned_tax_alloc       IN OUT NOCOPY NUMBER,
  x_run_uned_tax_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_uned_tax_acctd_alloc IN OUT NOCOPY NUMBER);

/*-----------------------------------------------------------------------+
 | update_line                                                           |
 +-----------------------------------------------------------------------+
 | Read ra_ar_gt for proration info                                      |
 | Does the proration plsql_proration                                    |
 | update ra_ar_gt with the result                                       |
 | for lines of a transaction                                            |
 +-----------------------------------------------------------------------+
 | parameter:                                                            |
 |  p_customer_trx_id         transaction id                             |
 |  p_gt_id                   global id                                  |
 +-----------------------------------------------------------------------*/
 PROCEDURE update_line
 (p_gt_id           IN VARCHAR2,
  p_customer_trx_id IN NUMBER,
  p_ae_sys_rec      IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | get_invoice_line_info                                                   |
 +-------------------------------------------------------------------------+
 | parameter :                                                             |
 |  p_gt_id                 global temporary id                            |
 |  p_customer_trx_id       transaction id                                 |
 |  p_ae_sys_rec            receivable system parameter                    |
 |  p_mode                  NORMAL / REMESTIM                              |
 +-------------------------------------------------------------------------*/
PROCEDURE get_invoice_line_info
  (p_gt_id                IN VARCHAR2,
   p_customer_trx_id      IN NUMBER,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type,
   p_mode                 IN VARCHAR2);

/*-------------------------------------------------------------------------+
 | get_invoice_line_info_cm                                                   |
 +-------------------------------------------------------------------------+
 | parameter :                                                             |
 |  p_gt_id                 global temporary id                            |
 |  p_customer_trx_id       transaction id                                 |
 |  p_ae_sys_rec            receivable system parameter                    |
 |  p_mode                  NORMAL / REMESTIM                              |
 +-------------------------------------------------------------------------*/
PROCEDURE get_invoice_line_info_cm
  (p_gt_id                IN VARCHAR2,
   p_customer_trx_id      IN NUMBER,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type,
   p_mode                 IN VARCHAR2);


/*-------------------------------------------------------------------------+
 | get_invoice_line_info_per_grp                                           |
 +-------------------------------------------------------------------------+
 | parameter :                                                             |
 |  p_gt_id                 global temporary id                            |
 |  p_customer_trx_id       transaction id                                 |
 |  p_source_data_key1..5   group identification                           |
 |  p_ae_sys_rec            receivable system parameter                    |
 +-------------------------------------------------------------------------*/
PROCEDURE get_invoice_line_info_per_grp
(p_gt_id               IN VARCHAR2,
 p_customer_trx_id     IN NUMBER,
-- p_group_id            IN VARCHAR2,
  --{HYUBPAGP
 p_source_data_key1    IN VARCHAR2,
 p_source_data_key2    IN VARCHAR2,
 p_source_data_key3    IN VARCHAR2,
 p_source_data_key4    IN VARCHAR2,
 p_source_data_key5    IN VARCHAR2,
  --}
 p_ae_sys_rec          IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | get_invoice_line_info_per_line                                          |
 +-------------------------------------------------------------------------+
 | parameter :                                                             |
 |  p_gt_id                 global temporary id                            |
 |  p_customer_trx_id       transaction id                                 |
 |  p_customer_trx_line_id  customer_trx_line_id                           |
 |  p_ae_sys_rec            receivable system parameter                    |
 +-------------------------------------------------------------------------*/
PROCEDURE get_invoice_line_info_per_line
(p_gt_id                IN VARCHAR2,
 p_customer_trx_id      IN NUMBER,
 p_customer_trx_line_id IN NUMBER,
 p_log_inv_line         IN VARCHAR2 DEFAULT 'N',
 p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | prepare_trx_line_proration                                              |
 +-------------------------------------------------------------------------+
 | This procedure determine the base                                       |
 |                          the element                                    |
 |                          the bucket                                     |
 | line amounts for prorations                                             |
 | It uses the bucket returned at the GPL gl_level                         |
 | to determine the buckets                                                |
 +-------------------------------------------------------------------------+
 | p_pay_adj         APP / ADJ                                             |
 |                   in case of APP ED/UNED will be                        |
 |                   kicked off.                                           |
 | p_adj_rec         adjustment record                                     |
 | p_app_rec         receivable application record                         |
 | p_ae_sys_rec      receivable system parameter                           |
 +-------------------------------------------------------------------------*/
  PROCEDURE prepare_trx_line_proration
  (p_gt_id            IN VARCHAR2,
   p_customer_trx_id  IN NUMBER,
   p_pay_adj          IN VARCHAR2,
   p_adj_rec          IN ar_adjustments%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | prepare_group_for_proration                                             |
 +-------------------------------------------------------------------------+
 | This procedure determine the base                                       |
 |                          the element                                    |
 |                          the bucket                                     |
 | group of lines proration                                                |
 | It inserts into ra_ar_gt with gp_level = 'GPL'                          |
 +-------------------------------------------------------------------------+
 | p_pay_adj         APP / ADJ                                             |
 |                   in case of APP ED/UNED will be                        |
 |                   kicked off.                                           |
 | p_adj_rec         adjustment record                                     |
 | p_app_rec         receivable application record                         |
 | p_ae_sys_rec      receivable system parameter                           |
 +-------------------------------------------------------------------------*/
PROCEDURE prepare_group_for_proration
  (p_gt_id            IN VARCHAR2,
   p_customer_trx_id  IN NUMBER,
   p_pay_adj          IN VARCHAR2,
   p_adj_rec          IN ar_adjustments%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | update_ctl_rem_orig                                                     |
 +-------------------------------------------------------------------------+
 | Update ra_customer_trx_lines                                            |
 | remaining and original amount                                           |
 | base on result in ra_ar_gt                                              |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_gt_id                   global id                                    |
 |  p_customer_trx_id         transaction id                               |
 |  p_pay_adj                 Application or Adjustment                    |
 |  p_customer_trx_line_id    transaction line id                          |
 |  p_source_data_key1..5     group identification                         |
 |  p_log_inv_line
 |  p_ae_sys_rec              system parameter                             |
 +-------------------------------------------------------------------------*/
PROCEDURE update_ctl_rem_orig
  (p_gt_id                IN VARCHAR2,
   p_customer_trx_id      IN NUMBER,
   p_pay_adj              IN VARCHAR2,
   p_customer_trx_line_id IN NUMBER   DEFAULT NULL,
--   p_group_id             IN VARCHAR2 DEFAULT NULL,
  --{HYUBPAGP
   p_source_data_key1     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key2     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key3     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key4     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key5     IN VARCHAR2 DEFAULT NULL,
  --}
   p_log_inv_line         IN VARCHAR2 DEFAULT 'N',
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type);


/*-------------------------------------------------------------------------+
 | get_inv_dist                                                            |
 +-------------------------------------------------------------------------+
 | parameter :                                                             |
 |  p_pay_adj          APP / ADJ / ED / UNED                               |
 |  p_gt_id            global temporary id                                 |
 |  p_customer_trx_id  transaction id                                      |
 |  p_adj_rec         adjustment record                                    |
 |  p_app_rec         receivable application record                        |
 |  p_ae_sys_rec       receivable system parameter                         |
 +-------------------------------------------------------------------------*/
PROCEDURE get_inv_dist
 (p_pay_adj                 IN VARCHAR2,
  p_customer_trx_id         IN NUMBER,
  p_gt_id                   IN VARCHAR2,
  p_adj_rec                 IN ar_adjustments%ROWTYPE,
  p_app_rec                 IN ar_receivable_applications%ROWTYPE,
  p_ae_sys_rec              IN arp_acct_main.ae_sys_rec_type);


/*-------------------------------------------------------------------------+
 | update_group_line                                                       |
 +-------------------------------------------------------------------------+
 | Read ra_ar_gt for proration info                                        |
 | Does the proration plsql_proration                                      |
 | update ra_ar_gt with the result                                         |
 | for group of line of all lines of a invoice                             |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id         transaction id                               |
 |  p_gt_id                   global id                                    |
 |  p_ae_sys_rec              system parameter                             |
 +-------------------------------------------------------------------------*/
PROCEDURE update_group_line
(p_gt_id           IN VARCHAR2,
 p_customer_trx_id IN NUMBER,
 p_ae_sys_rec      IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | create_split_distribution                                               |
 +-------------------------------------------------------------------------+
 | create records in ra_ar_concile                                         |
 | activity on a trx                                                       |
 +-------------------------------------------------------------------------+
 | parameters:                                                             |
 |  p_pay_adj            Application or Adjustment                         |
 |  p_customer_trx_id    transaction id                                    |
 |  p_gt_id              global id                                         |
 |  p_app_level          TRANSACTION/GROUP/LINE                            |
 |  p_ae_sys_rec         ar syst param                                     |
 +-------------------------------------------------------------------------*/
 PROCEDURE create_split_distribution
 (p_pay_adj                IN VARCHAR2,
  p_customer_trx_id        IN NUMBER,
  p_gt_id                  IN VARCHAR2,
  p_app_level              IN VARCHAR2,
  p_ae_sys_rec             IN arp_acct_main.ae_sys_rec_type);

/*-------------------------------------------------------------------------+
 | adjustment_detemination                                                 |
 +-------------------------------------------------------------------------+
 | ajustment boundary condition treatment                                  |
 +-------------------------------------------------------------------------+
 | parameters:                                                             |
 |  p_customer_trx_id    transaction id                                    |
 |  p_gt_id              global id                                         |
 |  p_pay_adj            ADJ/APP/ED/UNED                                   |
 |  p_ae_sys_rec         ar syst param                                     |
 |  p_adj_rec            adjustment record                                 |
 +-------------------------------------------------------------------------*/
 PROCEDURE adjustment_detemination
 (p_customer_trx_id   IN NUMBER,
  p_gt_id             IN VARCHAR2,
  p_pay_adj           IN VARCHAR2,
  p_ae_sys_rec        IN arp_acct_main.ae_sys_rec_type,
  p_adj_rec           IN ar_adjustments%ROWTYPE);

/*-------------------------------------------------------------------------+
 | proration_app_dist_trx                                                  |
 +-------------------------------------------------------------------------+
 | does the proration at distrib level and create the detail distributions |
 | for application                                                         |
 +-------------------------------------------------------------------------+
 | parameters:                                                             |
 |  p_customer_trx_id    transaction id                                    |
 |  p_gt_id              global id                                         |
 |  p_app_level          LINE/GROUP/TRANSACTION                            |
 |  p_ae_sys_rec         ar syst param                                     |
 |  p_app_rec            application record                                |
 +-------------------------------------------------------------------------*/
 PROCEDURE proration_app_dist_trx
    (p_gt_id            IN VARCHAR2,
     p_app_level        IN VARCHAR2,
     p_customer_trx_id  IN NUMBER,
     p_app_rec          IN ar_receivable_applications%ROWTYPE,
     p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type);

 PROCEDURE proration_adj_dist_trx
    (p_gt_id            IN VARCHAR2,
     p_app_level        IN VARCHAR2,
     p_customer_trx_id  IN NUMBER,
     p_adj_rec          IN ar_adjustments%ROWTYPE,
     p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type);


-------------
-- Body of the package
-------------
/*------------------------------------------+
 | return_existing_group is used internally |
 | by  plsql_proration to return an existing|
 | groupe order happens to be wrong         |
 +------------------------------------------*/
PROCEDURE  return_existing_group
(p_groupe                IN VARCHAR2,
 p_group_level           IN VARCHAR2 DEFAULT 'NOGROUP',
 x_group_tbl             IN OUT NOCOPY group_tbl_type,
 x_exist                 IN OUT NOCOPY BOOLEAN,
 -- ADJ and APP
 x_run_amt               IN OUT NOCOPY NUMBER,
 x_run_alloc             IN OUT NOCOPY NUMBER,
 x_run_acctd_amt         IN OUT NOCOPY NUMBER,
 x_run_acctd_alloc       IN OUT NOCOPY NUMBER,
 x_run_chrg_amt          IN OUT NOCOPY NUMBER,
 x_run_chrg_alloc        IN OUT NOCOPY NUMBER,
 x_run_chrg_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_chrg_acctd_alloc  IN OUT NOCOPY NUMBER,
 x_run_frt_amt          IN OUT NOCOPY NUMBER,
 x_run_frt_alloc        IN OUT NOCOPY NUMBER,
 x_run_frt_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_frt_acctd_alloc  IN OUT NOCOPY NUMBER,
 x_run_tax_amt          IN OUT NOCOPY NUMBER,
 x_run_tax_alloc        IN OUT NOCOPY NUMBER,
 x_run_tax_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_tax_acctd_alloc  IN OUT NOCOPY NUMBER,
 -- ED
 x_run_ed_amt               IN OUT NOCOPY NUMBER,
 x_run_ed_alloc             IN OUT NOCOPY NUMBER,
 x_run_ed_acctd_amt         IN OUT NOCOPY NUMBER,
 x_run_ed_acctd_alloc       IN OUT NOCOPY NUMBER,
 x_run_ed_chrg_amt          IN OUT NOCOPY NUMBER,
 x_run_ed_chrg_alloc        IN OUT NOCOPY NUMBER,
 x_run_ed_chrg_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_ed_chrg_acctd_alloc  IN OUT NOCOPY NUMBER,
 x_run_ed_frt_amt          IN OUT NOCOPY NUMBER,
 x_run_ed_frt_alloc        IN OUT NOCOPY NUMBER,
 x_run_ed_frt_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_ed_frt_acctd_alloc  IN OUT NOCOPY NUMBER,
 x_run_ed_tax_amt          IN OUT NOCOPY NUMBER,
 x_run_ed_tax_alloc        IN OUT NOCOPY NUMBER,
 x_run_ed_tax_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_ed_tax_acctd_alloc  IN OUT NOCOPY NUMBER,
 -- UNED
 x_run_uned_amt               IN OUT NOCOPY NUMBER,
 x_run_uned_alloc             IN OUT NOCOPY NUMBER,
 x_run_uned_acctd_amt         IN OUT NOCOPY NUMBER,
 x_run_uned_acctd_alloc       IN OUT NOCOPY NUMBER,
 x_run_uned_chrg_amt          IN OUT NOCOPY NUMBER,
 x_run_uned_chrg_alloc        IN OUT NOCOPY NUMBER,
 x_run_uned_chrg_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_uned_chrg_acctd_alloc  IN OUT NOCOPY NUMBER,
 x_run_uned_frt_amt          IN OUT NOCOPY NUMBER,
 x_run_uned_frt_alloc        IN OUT NOCOPY NUMBER,
 x_run_uned_frt_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_uned_frt_acctd_alloc  IN OUT NOCOPY NUMBER,
 x_run_uned_tax_amt          IN OUT NOCOPY NUMBER,
 x_run_uned_tax_alloc        IN OUT NOCOPY NUMBER,
 x_run_uned_tax_acctd_amt    IN OUT NOCOPY NUMBER,
 x_run_uned_tax_acctd_alloc  IN OUT NOCOPY NUMBER)

IS
i NUMBER(15);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.return_existing_group()+');
  localdebug('  p_groupe '||p_groupe);
  END IF;
  x_exist                := FALSE;
  -- ADJ and APP
  x_run_chrg_amt         := 0;
  x_run_chrg_alloc       := 0;
  x_run_chrg_acctd_amt   := 0;
  x_run_chrg_acctd_alloc := 0;
  x_run_frt_amt         := 0;
  x_run_frt_alloc       := 0;
  x_run_frt_acctd_amt   := 0;
  x_run_frt_acctd_alloc := 0;

   /*If the current proration is at line level and the source is INTERFACE, then
    we retain the counter values across various calls to the current procedure
    with in the context of update_line.This enables cumulative logic for proration
    of acctd amounts and thus avoids rounding issues. Please refer bug 8220511..*/
  IF nvl(p_group_level,'NOGROUP') <> 'L' OR g_tax_flag <>  'INTERFACE' OR g_line_flag <> 'INTERFACE' THEN
    x_run_amt              := 0;
    x_run_alloc            := 0;
    x_run_acctd_amt        := 0;
    x_run_acctd_alloc      := 0;
    x_run_tax_amt         := 0;
    x_run_tax_alloc       := 0;
    x_run_tax_acctd_amt   := 0;
    x_run_tax_acctd_alloc := 0;
  END IF;

  -- ED
  x_run_ed_chrg_amt         := 0;
  x_run_ed_chrg_alloc       := 0;
  x_run_ed_chrg_acctd_amt   := 0;
  x_run_ed_chrg_acctd_alloc := 0;
  x_run_ed_frt_amt         := 0;
  x_run_ed_frt_alloc       := 0;
  x_run_ed_frt_acctd_amt   := 0;
  x_run_ed_frt_acctd_alloc := 0;

   /*If the current proration is at line level and the source is INTERFACE, then
    we retain the counter values across various calls to the current procedure
    with in the context of update_line.This enables cumulative logic for proration
    of acctd amounts and thus avoids rounding issues. Please refer bug 8220511..*/
  IF nvl(p_group_level,'NOGROUP') <> 'L' OR g_ed_tax_flag <>  'INTERFACE' OR g_ed_line_flag <> 'INTERFACE' THEN
    x_run_ed_amt              := 0;
    x_run_ed_alloc            := 0;
    x_run_ed_acctd_amt        := 0;
    x_run_ed_acctd_alloc      := 0;
    x_run_ed_tax_amt         := 0;
    x_run_ed_tax_alloc       := 0;
    x_run_ed_tax_acctd_amt   := 0;
    x_run_ed_tax_acctd_alloc := 0;
  END IF;

  -- UNED
  x_run_uned_chrg_amt         := 0;
  x_run_uned_chrg_alloc       := 0;
  x_run_uned_chrg_acctd_amt   := 0;
  x_run_uned_chrg_acctd_alloc := 0;
  x_run_uned_frt_amt         := 0;
  x_run_uned_frt_alloc       := 0;
  x_run_uned_frt_acctd_amt   := 0;
  x_run_uned_frt_acctd_alloc := 0;

   /*If the current proration is at line level and the source is INTERFACE, then
    we retain the counter values across various calls to the current procedure
    with in the context of update_line.This enables cumulative logic for proration
    of acctd amounts and thus avoids rounding issues. Please refer bug 8220511..*/
  IF nvl(p_group_level,'NOGROUP') <> 'L' OR g_uned_tax_flag <>  'INTERFACE' OR g_uned_line_flag <> 'INTERFACE' THEN
    x_run_uned_amt              := 0;
    x_run_uned_alloc            := 0;
    x_run_uned_acctd_amt        := 0;
    x_run_uned_acctd_alloc      := 0;
    x_run_uned_tax_amt         := 0;
    x_run_uned_tax_alloc       := 0;
    x_run_uned_tax_acctd_amt   := 0;
    x_run_uned_tax_acctd_alloc := 0;
  END IF;

  IF  p_groupe <> 'NOGROUP' AND x_group_tbl.GROUPE.COUNT <> 0 THEN
    IF x_group_tbl.groupe_index.EXISTS( p_groupe ) THEN

	 i :=  x_group_tbl.groupe_index( p_groupe );

	 IF PG_DEBUG = 'Y' THEN
	    localdebug('found in cache(hash table) index '||i);
	 END IF;

         x_exist                := TRUE;
         -- ADJ and APP
         x_run_chrg_amt         := x_group_tbl.run_chrg_amt(i);
         x_run_chrg_alloc       := x_group_tbl.run_chrg_alloc(i);
         x_run_chrg_acctd_amt   := x_group_tbl.run_chrg_acctd_amt(i);
         x_run_chrg_acctd_alloc := x_group_tbl.run_chrg_acctd_alloc(i);
         x_run_frt_amt         := x_group_tbl.run_frt_amt(i);
         x_run_frt_alloc       := x_group_tbl.run_frt_alloc(i);
         x_run_frt_acctd_amt   := x_group_tbl.run_frt_acctd_amt(i);
         x_run_frt_acctd_alloc := x_group_tbl.run_frt_acctd_alloc(i);

	 /*If the current proration is at line level and the source is INTERFACE, then
	  we retain the counter values across various calls to the current procedure
	  with in the context of update_line.This enables cumulative logic for proration
	  of acctd amounts and thus avoids rounding issues. Please refer bug 8220511..*/
	 IF nvl(p_group_level,'NOGROUP') <> 'L' OR g_tax_flag <>  'INTERFACE' OR g_line_flag <> 'INTERFACE' THEN
	    x_run_amt              := x_group_tbl.run_amt(i);
	    x_run_alloc            := x_group_tbl.run_alloc(i);
	    x_run_acctd_amt        := x_group_tbl.run_acctd_amt(i);
	    x_run_acctd_alloc      := x_group_tbl.run_acctd_alloc(i);
	    x_run_tax_amt         := x_group_tbl.run_tax_amt(i);
	    x_run_tax_alloc       := x_group_tbl.run_tax_alloc(i);
	    x_run_tax_acctd_amt   := x_group_tbl.run_tax_acctd_amt(i);
	    x_run_tax_acctd_alloc := x_group_tbl.run_tax_acctd_alloc(i);
	 END IF;

         -- ED
         x_run_ed_chrg_amt         := x_group_tbl.run_ed_chrg_amt(i);
         x_run_ed_chrg_alloc       := x_group_tbl.run_ed_chrg_alloc(i);
         x_run_ed_chrg_acctd_amt   := x_group_tbl.run_ed_chrg_acctd_amt(i);
         x_run_ed_chrg_acctd_alloc := x_group_tbl.run_ed_chrg_acctd_alloc(i);
         x_run_ed_frt_amt         := x_group_tbl.run_ed_frt_amt(i);
         x_run_ed_frt_alloc       := x_group_tbl.run_ed_frt_alloc(i);
         x_run_ed_frt_acctd_amt   := x_group_tbl.run_ed_frt_acctd_amt(i);
         x_run_ed_frt_acctd_alloc := x_group_tbl.run_ed_frt_acctd_alloc(i);

	 /*If the current proration is at line level and the source is INTERFACE, then
	  we retain the counter values across various calls to the current procedure
	  with in the context of update_line.This enables cumulative logic for proration
	  of acctd amounts and thus avoids rounding issues. Please refer bug 8220511..*/
	 IF nvl(p_group_level,'NOGROUP') <> 'L' OR g_ed_tax_flag <>  'INTERFACE' OR g_ed_line_flag <> 'INTERFACE' THEN
	    x_run_ed_amt              := x_group_tbl.run_ed_amt(i);
	    x_run_ed_alloc            := x_group_tbl.run_ed_alloc(i);
	    x_run_ed_acctd_amt        := x_group_tbl.run_ed_acctd_amt(i);
	    x_run_ed_acctd_alloc      := x_group_tbl.run_ed_acctd_alloc(i);
	    x_run_ed_tax_amt         := x_group_tbl.run_ed_tax_amt(i);
	    x_run_ed_tax_alloc       := x_group_tbl.run_ed_tax_alloc(i);
	    x_run_ed_tax_acctd_amt   := x_group_tbl.run_ed_tax_acctd_amt(i);
	    x_run_ed_tax_acctd_alloc := x_group_tbl.run_ed_tax_acctd_alloc(i);
	 END IF;

	 -- UNED
         x_run_uned_chrg_amt         := x_group_tbl.run_uned_chrg_amt(i);
         x_run_uned_chrg_alloc       := x_group_tbl.run_uned_chrg_alloc(i);
         x_run_uned_chrg_acctd_amt   := x_group_tbl.run_uned_chrg_acctd_amt(i);
         x_run_uned_chrg_acctd_alloc := x_group_tbl.run_uned_chrg_acctd_alloc(i);
         x_run_uned_frt_amt         := x_group_tbl.run_ed_frt_amt(i);
         x_run_uned_frt_alloc       := x_group_tbl.run_ed_frt_alloc(i);
         x_run_uned_frt_acctd_amt   := x_group_tbl.run_ed_frt_acctd_amt(i);
         x_run_uned_frt_acctd_alloc := x_group_tbl.run_ed_frt_acctd_alloc(i);

	 /*If the current proration is at line level and the source is INTERFACE, then
	  we retain the counter values across various calls to the current procedure
	  with in the context of update_line.This enables cumulative logic for proration
	  of acctd amounts and thus avoids rounding issues. Please refer bug 8220511..*/
	 IF nvl(p_group_level,'NOGROUP') <> 'L' OR g_uned_tax_flag <>  'INTERFACE' OR g_uned_line_flag <> 'INTERFACE' THEN
           x_run_uned_amt              := x_group_tbl.run_uned_amt(i);
           x_run_uned_alloc            := x_group_tbl.run_uned_alloc(i);
           x_run_uned_acctd_amt        := x_group_tbl.run_uned_acctd_amt(i);
           x_run_uned_acctd_alloc      := x_group_tbl.run_uned_acctd_alloc(i);
           x_run_uned_tax_amt         := x_group_tbl.run_ed_tax_amt(i);
           x_run_uned_tax_alloc       := x_group_tbl.run_ed_tax_alloc(i);
           x_run_uned_tax_acctd_amt   := x_group_tbl.run_ed_tax_acctd_amt(i);
           x_run_uned_tax_acctd_alloc := x_group_tbl.run_ed_tax_acctd_alloc(i);
	 END IF;

         -- ADJ and APP
         IF PG_DEBUG = 'Y' THEN
	 localdebug('      x_run_amt              :'|| x_group_tbl.run_amt(i));
         localdebug('      x_run_alloc            :'|| x_group_tbl.run_alloc(i));
         localdebug('      x_run_acctd_amt        :'|| x_group_tbl.run_acctd_amt(i));
         localdebug('      x_run_acctd_alloc      :'|| x_group_tbl.run_acctd_alloc(i));
         localdebug('      x_run_chrg_amt         :'|| x_group_tbl.run_chrg_amt(i));
         localdebug('      x_run_chrg_alloc       :'|| x_group_tbl.run_chrg_alloc(i));
         localdebug('      x_run_chrg_acctd_amt   :'|| x_group_tbl.run_chrg_acctd_amt(i));
         localdebug('      x_run_chrg_acctd_alloc :'|| x_group_tbl.run_chrg_acctd_alloc(i));
         localdebug('      x_run_frt_amt         :'|| x_group_tbl.run_frt_amt(i));
         localdebug('      x_run_frt_alloc       :'|| x_group_tbl.run_frt_alloc(i));
         localdebug('      x_run_frt_acctd_amt   :'|| x_group_tbl.run_frt_acctd_amt(i));
         localdebug('      x_run_frt_acctd_alloc :'|| x_group_tbl.run_frt_acctd_alloc(i));
         localdebug('      x_run_tax_amt         :'|| x_group_tbl.run_tax_amt(i));
         localdebug('      x_run_tax_alloc       :'|| x_group_tbl.run_tax_alloc(i));
         localdebug('      x_run_tax_acctd_amt   :'|| x_group_tbl.run_tax_acctd_amt(i));
         localdebug('      x_run_tax_acctd_alloc :'|| x_group_tbl.run_tax_acctd_alloc(i));
         -- ED
         localdebug('      x_run_ed_amt              :'|| x_group_tbl.run_ed_amt(i));
         localdebug('      x_run_ed_alloc            :'|| x_group_tbl.run_ed_alloc(i));
         localdebug('      x_run_ed_acctd_amt        :'|| x_group_tbl.run_ed_acctd_amt(i));
         localdebug('      x_run_ed_acctd_alloc      :'|| x_group_tbl.run_ed_acctd_alloc(i));
         localdebug('      x_run_ed_chrg_amt         :'|| x_group_tbl.run_ed_chrg_amt(i));
         localdebug('      x_run_ed_chrg_alloc       :'|| x_group_tbl.run_ed_chrg_alloc(i));
         localdebug('      x_run_ed_chrg_acctd_amt   :'|| x_group_tbl.run_ed_chrg_acctd_amt(i));
         localdebug('      x_run_ed_chrg_acctd_alloc :'|| x_group_tbl.run_ed_chrg_acctd_alloc(i));
         localdebug('      x_run_ed_frt_amt         :'|| x_group_tbl.run_ed_frt_amt(i));
         localdebug('      x_run_ed_frt_alloc       :'|| x_group_tbl.run_ed_frt_alloc(i));
         localdebug('      x_run_ed_frt_acctd_amt   :'|| x_group_tbl.run_ed_frt_acctd_amt(i));
         localdebug('      x_run_ed_frt_acctd_alloc :'|| x_group_tbl.run_ed_frt_acctd_alloc(i));
         localdebug('      x_run_ed_tax_amt         :'|| x_group_tbl.run_ed_tax_amt(i));
         localdebug('      x_run_ed_tax_alloc       :'|| x_group_tbl.run_ed_tax_alloc(i));
         localdebug('      x_run_ed_tax_acctd_amt   :'|| x_group_tbl.run_ed_tax_acctd_amt(i));
         localdebug('      x_run_ed_tax_acctd_alloc :'|| x_group_tbl.run_ed_tax_acctd_alloc(i));
         -- UNED
         localdebug('      x_run_uned_amt              :'|| x_group_tbl.run_uned_amt(i));
         localdebug('      x_run_uned_alloc            :'|| x_group_tbl.run_uned_alloc(i));
         localdebug('      x_run_uned_acctd_amt        :'|| x_group_tbl.run_uned_acctd_amt(i));
         localdebug('      x_run_uned_acctd_alloc      :'|| x_group_tbl.run_uned_acctd_alloc(i));
         localdebug('      x_run_uned_chrg_amt         :'|| x_group_tbl.run_uned_chrg_amt(i));
         localdebug('      x_run_uned_chrg_alloc       :'|| x_group_tbl.run_uned_chrg_alloc(i));
         localdebug('      x_run_uned_chrg_acctd_amt   :'|| x_group_tbl.run_uned_chrg_acctd_amt(i));
         localdebug('      x_run_uned_chrg_acctd_alloc :'|| x_group_tbl.run_uned_chrg_acctd_alloc(i));
         localdebug('      x_run_uned_frt_amt         :'|| x_group_tbl.run_uned_frt_amt(i));
         localdebug('      x_run_uned_frt_alloc       :'|| x_group_tbl.run_uned_frt_alloc(i));
         localdebug('      x_run_uned_frt_acctd_amt   :'|| x_group_tbl.run_uned_frt_acctd_amt(i));
         localdebug('      x_run_uned_frt_acctd_alloc :'|| x_group_tbl.run_uned_frt_acctd_alloc(i));
         localdebug('      x_run_uned_tax_amt         :'|| x_group_tbl.run_uned_tax_amt(i));
         localdebug('      x_run_uned_tax_alloc       :'|| x_group_tbl.run_uned_tax_alloc(i));
         localdebug('      x_run_uned_tax_acctd_amt   :'|| x_group_tbl.run_uned_tax_acctd_amt(i));
         localdebug('      x_run_uned_tax_acctd_alloc :'|| x_group_tbl.run_uned_tax_acctd_alloc(i));
         END IF;
      END IF;
  END IF;
IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.return_existing_group()-');
END IF;
END return_existing_group;

/*------------------------------------------+
 | store_group is used internally           |
 | by  plsql_proration to store an group    |
 | before moving to another                 |
 +------------------------------------------*/
PROCEDURE  store_group
(p_groupe                IN VARCHAR2,
 -- ADJ and APP
 p_run_amt               IN NUMBER,
 p_run_alloc             IN NUMBER,
 p_run_acctd_amt         IN NUMBER,
 p_run_acctd_alloc       IN NUMBER,
 p_run_chrg_amt          IN NUMBER,
 p_run_chrg_alloc        IN NUMBER,
 p_run_chrg_acctd_amt    IN NUMBER,
 p_run_chrg_acctd_alloc  IN NUMBER,
 p_run_frt_amt          IN NUMBER,
 p_run_frt_alloc        IN NUMBER,
 p_run_frt_acctd_amt    IN NUMBER,
 p_run_frt_acctd_alloc  IN NUMBER,
 p_run_tax_amt          IN NUMBER,
 p_run_tax_alloc        IN NUMBER,
 p_run_tax_acctd_amt    IN NUMBER,
 p_run_tax_acctd_alloc  IN NUMBER,
 -- ED
 p_run_ed_amt               IN NUMBER,
 p_run_ed_alloc             IN NUMBER,
 p_run_ed_acctd_amt         IN NUMBER,
 p_run_ed_acctd_alloc       IN NUMBER,
 p_run_ed_chrg_amt          IN NUMBER,
 p_run_ed_chrg_alloc        IN NUMBER,
 p_run_ed_chrg_acctd_amt    IN NUMBER,
 p_run_ed_chrg_acctd_alloc  IN NUMBER,
 p_run_ed_frt_amt          IN NUMBER,
 p_run_ed_frt_alloc        IN NUMBER,
 p_run_ed_frt_acctd_amt    IN NUMBER,
 p_run_ed_frt_acctd_alloc  IN NUMBER,
 p_run_ed_tax_amt          IN NUMBER,
 p_run_ed_tax_alloc        IN NUMBER,
 p_run_ed_tax_acctd_amt    IN NUMBER,
 p_run_ed_tax_acctd_alloc  IN NUMBER,
 -- UNED
 p_run_uned_amt               IN NUMBER,
 p_run_uned_alloc             IN NUMBER,
 p_run_uned_acctd_amt         IN NUMBER,
 p_run_uned_acctd_alloc       IN NUMBER,
 p_run_uned_chrg_amt          IN NUMBER,
 p_run_uned_chrg_alloc        IN NUMBER,
 p_run_uned_chrg_acctd_amt    IN NUMBER,
 p_run_uned_chrg_acctd_alloc  IN NUMBER,
 p_run_uned_frt_amt          IN NUMBER,
 p_run_uned_frt_alloc        IN NUMBER,
 p_run_uned_frt_acctd_amt    IN NUMBER,
 p_run_uned_frt_acctd_alloc  IN NUMBER,
 p_run_uned_tax_amt          IN NUMBER,
 p_run_uned_tax_alloc        IN NUMBER,
 p_run_uned_tax_acctd_amt    IN NUMBER,
 p_run_uned_tax_acctd_alloc  IN NUMBER,
 --
 x_group_tbl             IN OUT NOCOPY group_tbl_type)
IS
  l_found   BOOLEAN := FALSE;
  l_cnt     NUMBER;
  i         NUMBER(15);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.store_group()+');
  localdebug('     p_groupe              :'||p_groupe);
  -- ADJ and APP
  localdebug('     p_run_amt             :'||p_run_amt);
  localdebug('     p_run_alloc           :'||p_run_alloc);
  localdebug('     p_run_acctd_amt       :'||p_run_acctd_amt);
  localdebug('     p_run_acctd_alloc     :'||p_run_acctd_alloc);
  localdebug('     p_run_chrg_amt        :'||p_run_chrg_amt);
  localdebug('     p_run_chrg_alloc      :'||p_run_chrg_alloc);
  localdebug('     p_run_chrg_acctd_amt  :'||p_run_chrg_acctd_amt);
  localdebug('     p_run_chrg_acctd_alloc:'||p_run_chrg_acctd_alloc);
  localdebug('     p_run_frt_amt        :'||p_run_frt_amt);
  localdebug('     p_run_frt_alloc      :'||p_run_frt_alloc);
  localdebug('     p_run_frt_acctd_amt  :'||p_run_frt_acctd_amt);
  localdebug('     p_run_frt_acctd_alloc:'||p_run_frt_acctd_alloc);
  localdebug('     p_run_tax_amt        :'||p_run_tax_amt);
  localdebug('     p_run_tax_alloc      :'||p_run_tax_alloc);
  localdebug('     p_run_tax_acctd_amt  :'||p_run_tax_acctd_amt);
  localdebug('     p_run_tax_acctd_alloc:'||p_run_tax_acctd_alloc);
  -- ED
  localdebug('     p_run_ed_amt             :'||p_run_ed_amt);
  localdebug('     p_run_ed_alloc           :'||p_run_ed_alloc);
  localdebug('     p_run_ed_acctd_amt       :'||p_run_ed_acctd_amt);
  localdebug('     p_run_ed_acctd_alloc     :'||p_run_ed_acctd_alloc);
  localdebug('     p_run_ed_chrg_amt        :'||p_run_ed_chrg_amt);
  localdebug('     p_run_ed_chrg_alloc      :'||p_run_ed_chrg_alloc);
  localdebug('     p_run_ed_chrg_acctd_amt  :'||p_run_ed_chrg_acctd_amt);
  localdebug('     p_run_ed_chrg_acctd_alloc:'||p_run_ed_chrg_acctd_alloc);
  localdebug('     p_run_ed_frt_amt        :'||p_run_ed_frt_amt);
  localdebug('     p_run_ed_frt_alloc      :'||p_run_ed_frt_alloc);
  localdebug('     p_run_ed_frt_acctd_amt  :'||p_run_ed_frt_acctd_amt);
  localdebug('     p_run_ed_frt_acctd_alloc:'||p_run_ed_frt_acctd_alloc);
  localdebug('     p_run_ed_tax_amt        :'||p_run_ed_tax_amt);
  localdebug('     p_run_ed_tax_alloc      :'||p_run_ed_tax_alloc);
  localdebug('     p_run_ed_tax_acctd_amt  :'||p_run_ed_tax_acctd_amt);
  localdebug('     p_run_ed_tax_acctd_alloc:'||p_run_ed_tax_acctd_alloc);
  -- UNED
  localdebug('     p_run_uned_amt             :'||p_run_uned_amt);
  localdebug('     p_run_uned_alloc           :'||p_run_uned_alloc);
  localdebug('     p_run_uned_acctd_amt       :'||p_run_uned_acctd_amt);
  localdebug('     p_run_uned_acctd_alloc     :'||p_run_uned_acctd_alloc);
  localdebug('     p_run_uned_chrg_amt        :'||p_run_uned_chrg_amt);
  localdebug('     p_run_uned_chrg_alloc      :'||p_run_uned_chrg_alloc);
  localdebug('     p_run_uned_chrg_acctd_amt  :'||p_run_uned_chrg_acctd_amt);
  localdebug('     p_run_uned_chrg_acctd_alloc:'||p_run_uned_chrg_acctd_alloc);
  localdebug('     p_run_uned_frt_amt        :'||p_run_uned_frt_amt);
  localdebug('     p_run_uned_frt_alloc      :'||p_run_uned_frt_alloc);
  localdebug('     p_run_uned_frt_acctd_amt  :'||p_run_uned_frt_acctd_amt);
  localdebug('     p_run_uned_frt_acctd_alloc:'||p_run_uned_frt_acctd_alloc);
  localdebug('     p_run_uned_tax_amt        :'||p_run_uned_tax_amt);
  localdebug('     p_run_uned_tax_alloc      :'||p_run_uned_tax_alloc);
  localdebug('     p_run_uned_tax_acctd_amt  :'||p_run_uned_tax_acctd_amt);
  localdebug('     p_run_uned_tax_acctd_alloc:'||p_run_uned_tax_acctd_alloc);
  END IF;

  IF  p_groupe <> 'NOGROUP' THEN
    IF x_group_tbl.groupe.COUNT = 0 THEN
	x_group_tbl.groupe(1)               := p_groupe;
	-- ADJ and APP
	x_group_tbl.run_amt(1)              := p_run_amt;
	x_group_tbl.run_alloc(1)            := p_run_alloc;
	x_group_tbl.run_acctd_amt(1)        := p_run_acctd_amt;
	x_group_tbl.run_acctd_alloc(1)      := p_run_acctd_alloc;
	x_group_tbl.run_chrg_amt(1)         := p_run_chrg_amt;
	x_group_tbl.run_chrg_alloc(1)       := p_run_chrg_alloc;
	x_group_tbl.run_chrg_acctd_amt(1)   := p_run_chrg_acctd_amt;
	x_group_tbl.run_chrg_acctd_alloc(1) := p_run_chrg_acctd_alloc;
	x_group_tbl.run_frt_amt(1)         := p_run_frt_amt;
	x_group_tbl.run_frt_alloc(1)       := p_run_frt_alloc;
	x_group_tbl.run_frt_acctd_amt(1)   := p_run_frt_acctd_amt;
	x_group_tbl.run_frt_acctd_alloc(1) := p_run_frt_acctd_alloc;
	x_group_tbl.run_tax_amt(1)         := p_run_tax_amt;
	x_group_tbl.run_tax_alloc(1)       := p_run_tax_alloc;
	x_group_tbl.run_tax_acctd_amt(1)   := p_run_tax_acctd_amt;
	x_group_tbl.run_tax_acctd_alloc(1) := p_run_tax_acctd_alloc;
	-- ED
	x_group_tbl.run_ed_amt(1)              := p_run_ed_amt;
	x_group_tbl.run_ed_alloc(1)            := p_run_ed_alloc;
	x_group_tbl.run_ed_acctd_amt(1)        := p_run_ed_acctd_amt;
	x_group_tbl.run_ed_acctd_alloc(1)      := p_run_ed_acctd_alloc;
	x_group_tbl.run_ed_chrg_amt(1)         := p_run_ed_chrg_amt;
	x_group_tbl.run_ed_chrg_alloc(1)       := p_run_ed_chrg_alloc;
	x_group_tbl.run_ed_chrg_acctd_amt(1)   := p_run_ed_chrg_acctd_amt;
	x_group_tbl.run_ed_chrg_acctd_alloc(1) := p_run_ed_chrg_acctd_alloc;
	x_group_tbl.run_ed_frt_amt(1)         := p_run_ed_frt_amt;
	x_group_tbl.run_ed_frt_alloc(1)       := p_run_ed_frt_alloc;
	x_group_tbl.run_ed_frt_acctd_amt(1)   := p_run_ed_frt_acctd_amt;
	x_group_tbl.run_ed_frt_acctd_alloc(1) := p_run_ed_frt_acctd_alloc;
	x_group_tbl.run_ed_tax_amt(1)         := p_run_ed_tax_amt;
	x_group_tbl.run_ed_tax_alloc(1)       := p_run_ed_tax_alloc;
	x_group_tbl.run_ed_tax_acctd_amt(1)   := p_run_ed_tax_acctd_amt;
	x_group_tbl.run_ed_tax_acctd_alloc(1) := p_run_ed_tax_acctd_alloc;
	-- UNED
	x_group_tbl.run_uned_amt(1)              := p_run_uned_amt;
	x_group_tbl.run_uned_alloc(1)            := p_run_uned_alloc;
	x_group_tbl.run_uned_acctd_amt(1)        := p_run_uned_acctd_amt;
	x_group_tbl.run_uned_acctd_alloc(1)      := p_run_uned_acctd_alloc;
	x_group_tbl.run_uned_chrg_amt(1)         := p_run_uned_chrg_amt;
	x_group_tbl.run_uned_chrg_alloc(1)       := p_run_uned_chrg_alloc;
	x_group_tbl.run_uned_chrg_acctd_amt(1)   := p_run_uned_chrg_acctd_amt;
	x_group_tbl.run_uned_chrg_acctd_alloc(1) := p_run_uned_chrg_acctd_alloc;
	x_group_tbl.run_uned_frt_amt(1)         := p_run_uned_frt_amt;
	x_group_tbl.run_uned_frt_alloc(1)       := p_run_uned_frt_alloc;
	x_group_tbl.run_uned_frt_acctd_amt(1)   := p_run_uned_frt_acctd_amt;
	x_group_tbl.run_uned_frt_acctd_alloc(1) := p_run_uned_frt_acctd_alloc;
	x_group_tbl.run_uned_tax_amt(1)         := p_run_uned_tax_amt;
	x_group_tbl.run_uned_tax_alloc(1)       := p_run_uned_tax_alloc;
	x_group_tbl.run_uned_tax_acctd_amt(1)   := p_run_uned_tax_acctd_amt;
	x_group_tbl.run_uned_tax_acctd_alloc(1) := p_run_uned_tax_acctd_alloc;
	x_group_tbl.groupe_index(p_groupe)      := 1;

    ELSIF x_group_tbl.groupe_index.EXISTS( p_groupe ) THEN
	 i :=  x_group_tbl.groupe_index( p_groupe );
	 IF PG_DEBUG = 'Y' THEN
	    localdebug('found in cache(hash table) index '||i);
	    localdebug('p_groupe '||p_groupe);
	 END IF;

	 x_group_tbl.groupe(i)               := p_groupe;
	 -- ADJ and APP
	 x_group_tbl.run_amt(i)              := p_run_amt;
	 x_group_tbl.run_alloc(i)            := p_run_alloc;
	 x_group_tbl.run_acctd_amt(i)        := p_run_acctd_amt;
	 x_group_tbl.run_acctd_alloc(i)      := p_run_acctd_alloc;
	 x_group_tbl.run_chrg_amt(i)         := p_run_chrg_amt;
	 x_group_tbl.run_chrg_alloc(i)       := p_run_chrg_alloc;
	 x_group_tbl.run_chrg_acctd_amt(i)   := p_run_chrg_acctd_amt;
	 x_group_tbl.run_chrg_acctd_alloc(i) := p_run_chrg_acctd_alloc;
	 x_group_tbl.run_frt_amt(i)         := p_run_frt_amt;
	 x_group_tbl.run_frt_alloc(i)       := p_run_frt_alloc;
	 x_group_tbl.run_frt_acctd_amt(i)   := p_run_frt_acctd_amt;
	 x_group_tbl.run_frt_acctd_alloc(i) := p_run_frt_acctd_alloc;
	 x_group_tbl.run_tax_amt(i)         := p_run_tax_amt;
	 x_group_tbl.run_tax_alloc(i)       := p_run_tax_alloc;
	 x_group_tbl.run_tax_acctd_amt(i)   := p_run_tax_acctd_amt;
	 x_group_tbl.run_tax_acctd_alloc(i) := p_run_tax_acctd_alloc;
	 -- ED
	 x_group_tbl.run_ed_amt(i)              := p_run_ed_amt;
	 x_group_tbl.run_ed_alloc(i)            := p_run_ed_alloc;
	 x_group_tbl.run_ed_acctd_amt(i)        := p_run_ed_acctd_amt;
	 x_group_tbl.run_ed_acctd_alloc(i)      := p_run_ed_acctd_alloc;
	 x_group_tbl.run_ed_chrg_amt(i)         := p_run_ed_chrg_amt;
	 x_group_tbl.run_ed_chrg_alloc(i)       := p_run_ed_chrg_alloc;
	 x_group_tbl.run_ed_chrg_acctd_amt(i)   := p_run_ed_chrg_acctd_amt;
	 x_group_tbl.run_ed_chrg_acctd_alloc(i) := p_run_ed_chrg_acctd_alloc;
	 x_group_tbl.run_ed_frt_amt(i)         := p_run_ed_frt_amt;
	 x_group_tbl.run_ed_frt_alloc(i)       := p_run_ed_frt_alloc;
	 x_group_tbl.run_ed_frt_acctd_amt(i)   := p_run_ed_frt_acctd_amt;
	 x_group_tbl.run_ed_frt_acctd_alloc(i) := p_run_ed_frt_acctd_alloc;
	 x_group_tbl.run_ed_tax_amt(i)         := p_run_ed_tax_amt;
	 x_group_tbl.run_ed_tax_alloc(i)       := p_run_ed_tax_alloc;
	 x_group_tbl.run_ed_tax_acctd_amt(i)   := p_run_ed_tax_acctd_amt;
	 x_group_tbl.run_ed_tax_acctd_alloc(i) := p_run_ed_tax_acctd_alloc;
	 -- UNED
	 x_group_tbl.run_uned_amt(i)              := p_run_uned_amt;
	 x_group_tbl.run_uned_alloc(i)            := p_run_uned_alloc;
	 x_group_tbl.run_uned_acctd_amt(i)        := p_run_uned_acctd_amt;
	 x_group_tbl.run_uned_acctd_alloc(i)      := p_run_uned_acctd_alloc;
	 x_group_tbl.run_uned_chrg_amt(i)         := p_run_uned_chrg_amt;
	 x_group_tbl.run_uned_chrg_alloc(i)       := p_run_uned_chrg_alloc;
	 x_group_tbl.run_uned_chrg_acctd_amt(i)   := p_run_uned_chrg_acctd_amt;
	 x_group_tbl.run_uned_chrg_acctd_alloc(i) := p_run_uned_chrg_acctd_alloc;
	 x_group_tbl.run_uned_frt_amt(i)         := p_run_uned_frt_amt;
	 x_group_tbl.run_uned_frt_alloc(i)       := p_run_uned_frt_alloc;
	 x_group_tbl.run_uned_frt_acctd_amt(i)   := p_run_uned_frt_acctd_amt;
	 x_group_tbl.run_uned_frt_acctd_alloc(i) := p_run_uned_frt_acctd_alloc;
	 x_group_tbl.run_uned_tax_amt(i)         := p_run_uned_tax_amt;
	 x_group_tbl.run_uned_tax_alloc(i)       := p_run_uned_tax_alloc;
	 x_group_tbl.run_uned_tax_acctd_amt(i)   := p_run_uned_tax_acctd_amt;
	 x_group_tbl.run_uned_tax_acctd_alloc(i) := p_run_uned_tax_acctd_alloc;
     ELSE
	 l_cnt                                     := x_group_tbl.groupe.COUNT;
	 x_group_tbl.groupe_index( p_groupe )      := l_cnt + 1;

	 IF PG_DEBUG = 'Y' THEN
	    localdebug('Added to cache(hash table) index '||l_cnt);
	    localdebug('p_groupe '||p_groupe);
	 END IF;

	 x_group_tbl.groupe(l_cnt+1)               := p_groupe;
	 -- ADJ and APP
	 x_group_tbl.run_amt(l_cnt+1)              := p_run_amt;
	 x_group_tbl.run_alloc(l_cnt+1)            := p_run_alloc;
	 x_group_tbl.run_acctd_amt(l_cnt+1)        := p_run_acctd_amt;
	 x_group_tbl.run_acctd_alloc(l_cnt+1)      := p_run_acctd_alloc;
	 x_group_tbl.run_chrg_amt(l_cnt+1)         := p_run_chrg_amt;
	 x_group_tbl.run_chrg_alloc(l_cnt+1)       := p_run_chrg_alloc;
	 x_group_tbl.run_chrg_acctd_amt(l_cnt+1)   := p_run_chrg_acctd_amt;
	 x_group_tbl.run_chrg_acctd_alloc(l_cnt+1) := p_run_chrg_acctd_alloc;
	 x_group_tbl.run_frt_amt(l_cnt+1)         := p_run_frt_amt;
	 x_group_tbl.run_frt_alloc(l_cnt+1)       := p_run_frt_alloc;
	 x_group_tbl.run_frt_acctd_amt(l_cnt+1)   := p_run_frt_acctd_amt;
	 x_group_tbl.run_frt_acctd_alloc(l_cnt+1) := p_run_frt_acctd_alloc;
	 x_group_tbl.run_tax_amt(l_cnt+1)         := p_run_tax_amt;
	 x_group_tbl.run_tax_alloc(l_cnt+1)       := p_run_tax_alloc;
	 x_group_tbl.run_tax_acctd_amt(l_cnt+1)   := p_run_tax_acctd_amt;
	 x_group_tbl.run_tax_acctd_alloc(l_cnt+1) := p_run_tax_acctd_alloc;
	 -- ED
	 x_group_tbl.run_ed_amt(l_cnt+1)              := p_run_ed_amt;
	 x_group_tbl.run_ed_alloc(l_cnt+1)            := p_run_ed_alloc;
	 x_group_tbl.run_ed_acctd_amt(l_cnt+1)        := p_run_ed_acctd_amt;
	 x_group_tbl.run_ed_acctd_alloc(l_cnt+1)      := p_run_ed_acctd_alloc;
	 x_group_tbl.run_ed_chrg_amt(l_cnt+1)         := p_run_ed_chrg_amt;
	 x_group_tbl.run_ed_chrg_alloc(l_cnt+1)       := p_run_ed_chrg_alloc;
	 x_group_tbl.run_ed_chrg_acctd_amt(l_cnt+1)   := p_run_ed_chrg_acctd_amt;
	 x_group_tbl.run_ed_chrg_acctd_alloc(l_cnt+1) := p_run_ed_chrg_acctd_alloc;
	 x_group_tbl.run_ed_frt_amt(l_cnt+1)         := p_run_ed_frt_amt;
	 x_group_tbl.run_ed_frt_alloc(l_cnt+1)       := p_run_ed_frt_alloc;
	 x_group_tbl.run_ed_frt_acctd_amt(l_cnt+1)   := p_run_ed_frt_acctd_amt;
	 x_group_tbl.run_ed_frt_acctd_alloc(l_cnt+1) := p_run_ed_frt_acctd_alloc;
	 x_group_tbl.run_ed_tax_amt(l_cnt+1)         := p_run_ed_tax_amt;
	 x_group_tbl.run_ed_tax_alloc(l_cnt+1)       := p_run_ed_tax_alloc;
	 x_group_tbl.run_ed_tax_acctd_amt(l_cnt+1)   := p_run_ed_tax_acctd_amt;
	 x_group_tbl.run_ed_tax_acctd_alloc(l_cnt+1) := p_run_ed_tax_acctd_alloc;
	 -- UNED
	 x_group_tbl.run_uned_amt(l_cnt+1)              := p_run_uned_amt;
	 x_group_tbl.run_uned_alloc(l_cnt+1)            := p_run_uned_alloc;
	 x_group_tbl.run_uned_acctd_amt(l_cnt+1)        := p_run_uned_acctd_amt;
	 x_group_tbl.run_uned_acctd_alloc(l_cnt+1)      := p_run_uned_acctd_alloc;
	 x_group_tbl.run_uned_chrg_amt(l_cnt+1)         := p_run_uned_chrg_amt;
	 x_group_tbl.run_uned_chrg_alloc(l_cnt+1)       := p_run_uned_chrg_alloc;
	 x_group_tbl.run_uned_chrg_acctd_amt(l_cnt+1)   := p_run_uned_chrg_acctd_amt;
	 x_group_tbl.run_uned_chrg_acctd_alloc(l_cnt+1) := p_run_uned_chrg_acctd_alloc;
	 x_group_tbl.run_uned_frt_amt(l_cnt+1)         := p_run_uned_frt_amt;
	 x_group_tbl.run_uned_frt_alloc(l_cnt+1)       := p_run_uned_frt_alloc;
	 x_group_tbl.run_uned_frt_acctd_amt(l_cnt+1)   := p_run_uned_frt_acctd_amt;
	 x_group_tbl.run_uned_frt_acctd_alloc(l_cnt+1) := p_run_uned_frt_acctd_alloc;
	 x_group_tbl.run_uned_tax_amt(l_cnt+1)         := p_run_uned_tax_amt;
	 x_group_tbl.run_uned_tax_alloc(l_cnt+1)       := p_run_uned_tax_alloc;
	 x_group_tbl.run_uned_tax_acctd_amt(l_cnt+1)   := p_run_uned_tax_acctd_amt;
	 x_group_tbl.run_uned_tax_acctd_alloc(l_cnt+1) := p_run_uned_tax_acctd_alloc;
     END IF;
   END IF;
   IF PG_DEBUG = 'Y' THEN
   localdebug('arp_det_dist_pkg.store_group()-');
   END IF;
END;


PROCEDURE plsql_proration
( x_tab                  IN OUT NOCOPY pro_res_tbl_type,
  x_group_tbl            IN OUT NOCOPY group_tbl_type,
  p_group_level          IN VARCHAR2 DEFAULT 'NOGROUP',
  -- ADJ and APP
  x_run_amt              IN OUT NOCOPY NUMBER,
  x_run_alloc            IN OUT NOCOPY NUMBER,
  x_run_acctd_amt        IN OUT NOCOPY NUMBER,
  x_run_acctd_alloc      IN OUT NOCOPY NUMBER,
  x_run_chrg_amt         IN OUT NOCOPY NUMBER,
  x_run_chrg_alloc       IN OUT NOCOPY NUMBER,
  x_run_chrg_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_chrg_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_frt_amt         IN OUT NOCOPY NUMBER,
  x_run_frt_alloc       IN OUT NOCOPY NUMBER,
  x_run_frt_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_frt_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_tax_amt         IN OUT NOCOPY NUMBER,
  x_run_tax_alloc       IN OUT NOCOPY NUMBER,
  x_run_tax_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_tax_acctd_alloc IN OUT NOCOPY NUMBER,
  -- ED
  x_run_ed_amt              IN OUT NOCOPY NUMBER,
  x_run_ed_alloc            IN OUT NOCOPY NUMBER,
  x_run_ed_acctd_amt        IN OUT NOCOPY NUMBER,
  x_run_ed_acctd_alloc      IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_amt         IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_alloc       IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_ed_chrg_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_ed_frt_amt         IN OUT NOCOPY NUMBER,
  x_run_ed_frt_alloc       IN OUT NOCOPY NUMBER,
  x_run_ed_frt_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_ed_frt_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_ed_tax_amt         IN OUT NOCOPY NUMBER,
  x_run_ed_tax_alloc       IN OUT NOCOPY NUMBER,
  x_run_ed_tax_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_ed_tax_acctd_alloc IN OUT NOCOPY NUMBER,
  -- UNED
  x_run_uned_amt              IN OUT NOCOPY NUMBER,
  x_run_uned_alloc            IN OUT NOCOPY NUMBER,
  x_run_uned_acctd_amt        IN OUT NOCOPY NUMBER,
  x_run_uned_acctd_alloc      IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_amt         IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_alloc       IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_uned_chrg_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_uned_frt_amt         IN OUT NOCOPY NUMBER,
  x_run_uned_frt_alloc       IN OUT NOCOPY NUMBER,
  x_run_uned_frt_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_uned_frt_acctd_alloc IN OUT NOCOPY NUMBER,
  x_run_uned_tax_amt         IN OUT NOCOPY NUMBER,
  x_run_uned_tax_alloc       IN OUT NOCOPY NUMBER,
  x_run_uned_tax_acctd_amt   IN OUT NOCOPY NUMBER,
  x_run_uned_tax_acctd_alloc IN OUT NOCOPY NUMBER)
IS
  l_group                VARCHAR2(900);
  -- ADJ and APP
  l_alloc                NUMBER          := 0;
  l_acctd_alloc          NUMBER          := 0;
  l_chrg_alloc           NUMBER          := 0;
  l_chrg_acctd_alloc     NUMBER          := 0;
  l_frt_alloc           NUMBER          := 0;
  l_frt_acctd_alloc     NUMBER          := 0;
  l_tax_alloc           NUMBER          := 0;
  l_tax_acctd_alloc           NUMBER          := 0;
  -- ED
  l_ed_alloc                  NUMBER          := 0;
  l_ed_acctd_alloc            NUMBER          := 0;
  l_ed_chrg_alloc             NUMBER          := 0;
  l_ed_chrg_acctd_alloc       NUMBER          := 0;
  l_ed_frt_alloc              NUMBER          := 0;
  l_ed_frt_acctd_alloc        NUMBER          := 0;
  l_ed_tax_alloc              NUMBER          := 0;
  l_ed_tax_acctd_alloc        NUMBER          := 0;
  -- UNED
  l_uned_alloc                NUMBER          := 0;
  l_uned_acctd_alloc          NUMBER          := 0;
  l_uned_chrg_alloc           NUMBER          := 0;
  l_uned_chrg_acctd_alloc     NUMBER          := 0;
  l_uned_frt_alloc           NUMBER          := 0;
  l_uned_frt_acctd_alloc     NUMBER          := 0;
  l_uned_tax_alloc           NUMBER          := 0;
  l_uned_tax_acctd_alloc     NUMBER          := 0;

  l_exist                BOOLEAN;
  tbl_pro_res_tbl_empty  EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.plsql_proration()+');
  END IF;
  IF x_tab.ROWID_ID.COUNT = 0 THEN
    RAISE tbl_pro_res_tbl_empty;
  END IF;

  IF x_group_tbl.GROUPE.COUNT <> 0 THEN
    l_group := x_group_tbl.GROUPE.LAST;
  ELSE
    l_group := 'NOGROUP';
  END IF;

  FOR i IN x_tab.ROWID_ID.FIRST .. x_tab.ROWID_ID.LAST LOOP
     IF PG_DEBUG = 'Y' THEN
     localdebug('current indice i:'||i);
     END IF;

     IF l_group <> x_tab.GROUPE(i) THEN
        -- put away the current group value
        store_group
        (p_groupe                => l_group,
         -- ADJ and APP
         p_run_amt               => x_run_amt,
         p_run_alloc             => x_run_alloc,
         p_run_acctd_amt         => x_run_acctd_amt,
         p_run_acctd_alloc       => x_run_acctd_alloc,
         p_run_chrg_amt          => x_run_chrg_amt,
         p_run_chrg_alloc        => x_run_chrg_alloc,
         p_run_chrg_acctd_amt    => x_run_chrg_acctd_amt,
         p_run_chrg_acctd_alloc  => x_run_chrg_acctd_alloc,
         p_run_frt_amt          => x_run_frt_amt,
         p_run_frt_alloc        => x_run_frt_alloc,
         p_run_frt_acctd_amt    => x_run_frt_acctd_amt,
         p_run_frt_acctd_alloc  => x_run_frt_acctd_alloc,
         p_run_tax_amt          => x_run_tax_amt,
         p_run_tax_alloc        => x_run_tax_alloc,
         p_run_tax_acctd_amt    => x_run_tax_acctd_amt,
         p_run_tax_acctd_alloc  => x_run_tax_acctd_alloc,
         -- ED
         p_run_ed_amt               => x_run_ed_amt,
         p_run_ed_alloc             => x_run_ed_alloc,
         p_run_ed_acctd_amt         => x_run_ed_acctd_amt,
         p_run_ed_acctd_alloc       => x_run_ed_acctd_alloc,
         p_run_ed_chrg_amt          => x_run_ed_chrg_amt,
         p_run_ed_chrg_alloc        => x_run_ed_chrg_alloc,
         p_run_ed_chrg_acctd_amt    => x_run_ed_chrg_acctd_amt,
         p_run_ed_chrg_acctd_alloc  => x_run_ed_chrg_acctd_alloc,
         p_run_ed_frt_amt          => x_run_ed_frt_amt,
         p_run_ed_frt_alloc        => x_run_ed_frt_alloc,
         p_run_ed_frt_acctd_amt    => x_run_ed_frt_acctd_amt,
         p_run_ed_frt_acctd_alloc  => x_run_ed_frt_acctd_alloc,
         p_run_ed_tax_amt          => x_run_ed_tax_amt,
         p_run_ed_tax_alloc        => x_run_ed_tax_alloc,
         p_run_ed_tax_acctd_amt    => x_run_ed_tax_acctd_amt,
         p_run_ed_tax_acctd_alloc  => x_run_ed_tax_acctd_alloc,
         -- UNED
         p_run_uned_amt               => x_run_uned_amt,
         p_run_uned_alloc             => x_run_uned_alloc,
         p_run_uned_acctd_amt         => x_run_uned_acctd_amt,
         p_run_uned_acctd_alloc       => x_run_uned_acctd_alloc,
         p_run_uned_chrg_amt          => x_run_uned_chrg_amt,
         p_run_uned_chrg_alloc        => x_run_uned_chrg_alloc,
         p_run_uned_chrg_acctd_amt    => x_run_uned_chrg_acctd_amt,
         p_run_uned_chrg_acctd_alloc  => x_run_uned_chrg_acctd_alloc,
         p_run_uned_frt_amt          => x_run_uned_frt_amt,
         p_run_uned_frt_alloc        => x_run_uned_frt_alloc,
         p_run_uned_frt_acctd_amt    => x_run_uned_frt_acctd_amt,
         p_run_uned_frt_acctd_alloc  => x_run_uned_frt_acctd_alloc,
         p_run_uned_tax_amt          => x_run_uned_tax_amt,
         p_run_uned_tax_alloc        => x_run_uned_tax_alloc,
         p_run_uned_tax_acctd_amt    => x_run_uned_tax_acctd_amt,
         p_run_uned_tax_acctd_alloc  => x_run_uned_tax_acctd_alloc,
         --
         x_group_tbl             => x_group_tbl);
        -- Check if the new group already exists in case DB ordering problem
        -- to initiate the correct running amount
        -- and initiate the running amount
        return_existing_group
        (p_groupe               => x_tab.GROUPE(i),
         x_group_tbl            => x_group_tbl,
         p_group_level          => p_group_level,
	 x_exist                => l_exist,
         -- ADJ and APP
         x_run_amt              => x_run_amt,
         x_run_alloc            => x_run_alloc,
         x_run_acctd_amt        => x_run_acctd_amt,
         x_run_acctd_alloc      => x_run_acctd_alloc,
         x_run_chrg_amt         => x_run_chrg_amt,
         x_run_chrg_alloc       => x_run_chrg_alloc,
         x_run_chrg_acctd_amt   => x_run_chrg_acctd_amt,
         x_run_chrg_acctd_alloc => x_run_chrg_acctd_alloc,
         x_run_frt_amt         => x_run_frt_amt,
         x_run_frt_alloc       => x_run_frt_alloc,
         x_run_frt_acctd_amt   => x_run_frt_acctd_amt,
         x_run_frt_acctd_alloc => x_run_frt_acctd_alloc,
         x_run_tax_amt         => x_run_tax_amt,
         x_run_tax_alloc       => x_run_tax_alloc,
         x_run_tax_acctd_amt   => x_run_tax_acctd_amt,
         x_run_tax_acctd_alloc => x_run_tax_acctd_alloc,
         -- ED
         x_run_ed_amt              => x_run_ed_amt,
         x_run_ed_alloc            => x_run_ed_alloc,
         x_run_ed_acctd_amt        => x_run_ed_acctd_amt,
         x_run_ed_acctd_alloc      => x_run_ed_acctd_alloc,
         x_run_ed_chrg_amt         => x_run_ed_chrg_amt,
         x_run_ed_chrg_alloc       => x_run_ed_chrg_alloc,
         x_run_ed_chrg_acctd_amt   => x_run_ed_chrg_acctd_amt,
         x_run_ed_chrg_acctd_alloc => x_run_ed_chrg_acctd_alloc,
         x_run_ed_frt_amt         => x_run_ed_frt_amt,
         x_run_ed_frt_alloc       => x_run_ed_frt_alloc,
         x_run_ed_frt_acctd_amt   => x_run_ed_frt_acctd_amt,
         x_run_ed_frt_acctd_alloc => x_run_ed_frt_acctd_alloc,
         x_run_ed_tax_amt         => x_run_ed_tax_amt,
         x_run_ed_tax_alloc       => x_run_ed_tax_alloc,
         x_run_ed_tax_acctd_amt   => x_run_ed_tax_acctd_amt,
         x_run_ed_tax_acctd_alloc => x_run_ed_tax_acctd_alloc,
         -- UNED
         x_run_uned_amt              => x_run_uned_amt,
         x_run_uned_alloc            => x_run_uned_alloc,
         x_run_uned_acctd_amt        => x_run_uned_acctd_amt,
         x_run_uned_acctd_alloc      => x_run_uned_acctd_alloc,
         x_run_uned_chrg_amt         => x_run_uned_chrg_amt,
         x_run_uned_chrg_alloc       => x_run_uned_chrg_alloc,
         x_run_uned_chrg_acctd_amt   => x_run_uned_chrg_acctd_amt,
         x_run_uned_chrg_acctd_alloc => x_run_uned_chrg_acctd_alloc,
         x_run_uned_frt_amt         => x_run_uned_frt_amt,
         x_run_uned_frt_alloc       => x_run_uned_frt_alloc,
         x_run_uned_frt_acctd_amt   => x_run_uned_frt_acctd_amt,
         x_run_uned_frt_acctd_alloc => x_run_uned_frt_acctd_alloc,
         x_run_uned_tax_amt         => x_run_uned_tax_amt,
         x_run_uned_tax_alloc       => x_run_uned_tax_alloc,
         x_run_uned_tax_acctd_amt   => x_run_uned_tax_acctd_amt,
         x_run_uned_tax_acctd_alloc => x_run_uned_tax_acctd_alloc);
       -- the current group is the new group
       l_group := x_tab.GROUPE(i);
     END IF;

   /********************************
    -- ADJ AND APP
    ********************************/
    /*-------------------------------------------------+
     | Running Rev amount in trx currency              |
     +-------------------------------------------------*/


    IF x_tab.base_pro_amt(i) <> 0 AND x_tab.buc_alloc_amt(i) <> 0 THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_run_amt:'||x_run_amt);
    localdebug('  x_tab.elmt_pro_amt(i):'||x_tab.elmt_pro_amt(i));
    localdebug('  x_tab.buc_alloc_amt(i):'||x_tab.buc_alloc_amt(i));
    localdebug('  x_tab.base_pro_amt(i):'||x_tab.base_pro_amt(i));
    END IF;
      x_run_amt := x_run_amt + x_tab.elmt_pro_amt(i);
      l_alloc    := CurrRound(  x_run_amt
                                 / x_tab.base_pro_amt(i)
                                 * x_tab.buc_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_alloc;
      -- MAJ proration_res_tbl.res_pro := l_alloc;
      x_tab.tl_alloc_amt(i) := l_alloc;
      x_run_alloc := x_run_alloc + l_alloc;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_tab.tl_alloc_amt(i):'||x_tab.tl_alloc_amt(i));
    localdebug('  x_run_alloc:'||x_run_alloc);
    localdebug('  l_alloc:'||l_alloc);
    END IF;
    ELSE
      x_tab.tl_alloc_amt(i) := 0;
    END IF;


    /*-------------------------------------------------+
     | Running Rev amount in base currency             |
     +-------------------------------------------------*/

    IF x_tab.base_pro_acctd_amt(i) <> 0 AND x_tab.buc_alloc_acctd_amt(i) <> 0 THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_run_acctd_amt:'||x_run_acctd_amt);
    localdebug('  x_tab.elmt_pro_acctd_amt(i):'||x_tab.elmt_pro_acctd_amt(i));
    localdebug('  x_tab.buc_alloc_acctd_amt(i):'||x_tab.buc_alloc_acctd_amt(i));
    localdebug('  x_tab.base_pro_acctd_amt(i):'||x_tab.base_pro_acctd_amt(i));
    END IF;
      x_run_acctd_amt := x_run_acctd_amt + x_tab.elmt_pro_acctd_amt(i);
      l_acctd_alloc    := CurrRound(  x_run_acctd_amt
                                 / x_tab.base_pro_acctd_amt(i)
                                 * x_tab.buc_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_acctd_alloc;
      -- MAJ proration_res_tbl.res_pro := l_alloc;
      x_tab.tl_alloc_acctd_amt(i) := l_acctd_alloc;
      x_run_acctd_alloc := x_run_acctd_alloc + l_acctd_alloc;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_tab.tl_alloc_acctd_amt(i):'||x_tab.tl_alloc_acctd_amt(i));
    localdebug('  x_run_acctd_alloc:'||x_run_acctd_alloc);
    localdebug('  l_acctd_alloc:'||l_acctd_alloc);
    END IF;
    ELSE
      x_tab.tl_alloc_acctd_amt(i) := 0;
    END IF;

    /*-------------------------------------------------+
     | Running tax amount in trx currency              |
     +-------------------------------------------------*/

    IF x_tab.BASE_tax_PRO_AMT(i) <> 0 AND x_tab.buc_tax_alloc_amt(i) <> 0 THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_run_tax_amt:'||x_run_tax_amt);
    localdebug('  x_tab.ELMT_tax_PRO_AMT(i):'||x_tab.ELMT_tax_PRO_AMT(i));
    localdebug('  x_tab.buc_tax_alloc_amt(i):'||x_tab.buc_tax_alloc_amt(i));
    localdebug('  x_tab.BASE_TAX_PRO_AMT(i):'||x_tab.BASE_tax_PRO_AMT(i));
    END IF;
      x_run_tax_amt := x_run_tax_amt + x_tab.ELMT_tax_PRO_AMT(i);
      l_tax_alloc    := CurrRound(  x_run_tax_amt
                                 / x_tab.BASE_tax_PRO_AMT(i)
                                 * x_tab.buc_tax_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_tax_alloc;
      x_tab.tl_tax_alloc_amt(i) := l_tax_alloc;
      x_run_tax_alloc := x_run_tax_alloc + l_tax_alloc;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_tab.tl_tax_alloc_amt(i):'||x_tab.tl_tax_alloc_amt(i));
    localdebug('  x_run_tax_alloc:'||x_run_tax_alloc);
    localdebug('  l_tax_alloc:'||l_tax_alloc);
    END IF;
    ELSE
      x_tab.tl_tax_alloc_amt(i) := 0;
    END IF;


    /*-------------------------------------------------+
     | Running tax acctd amount in trx currency        |
     +-------------------------------------------------*/
    IF x_tab.BASE_tax_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_tax_alloc_acctd_amt(i) <> 0 THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_run_tax_amt:'||x_run_tax_amt);
    localdebug('  x_tab.ELMT_tax_PRO_acctd_AMT(i):'||x_tab.ELMT_tax_PRO_acctd_AMT(i));
    localdebug('  x_tab.buc_tax_alloc_acctd_amt(i):'||x_tab.buc_tax_alloc_acctd_amt(i));
    localdebug('  x_tab.BASE_TAX_PRO_acctd_AMT(i):'||x_tab.BASE_tax_PRO_acctd_AMT(i));
    END IF;
      x_run_tax_acctd_amt := x_run_tax_acctd_amt + x_tab.ELMT_tax_PRO_ACCTD_AMT(i);
      l_tax_acctd_alloc    := CurrRound(  x_run_tax_acctd_amt
                                 / x_tab.BASE_tax_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_tax_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_tax_acctd_alloc;
      x_tab.tl_tax_alloc_acctd_amt(i) := l_tax_acctd_alloc;
      x_run_tax_acctd_alloc := x_run_tax_acctd_alloc + l_tax_acctd_alloc;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_tab.tl_tax_alloc_acctd_amt(i):'||x_tab.tl_tax_alloc_acctd_amt(i));
    localdebug('  x_run_tax_acctd_alloc:'||x_run_tax_acctd_alloc);
    localdebug('  l_tax_acctd_alloc:'||l_tax_acctd_alloc);
    END IF;
    ELSE
      x_tab.tl_tax_alloc_acctd_amt(i) := 0;
    END IF;


    /*-------------------------------------------------+
     | Running frt amount in trx currency              |
     +-------------------------------------------------*/

    IF x_tab.BASE_FRT_PRO_AMT(i) <> 0 AND x_tab.buc_frt_alloc_amt(i) <> 0 THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_run_frt_amt:'||x_run_frt_amt);
    localdebug('  x_tab.ELMT_frt_PRO_AMT(i):'||x_tab.ELMT_frt_PRO_AMT(i));
    localdebug('  x_tab.buc_frt_alloc_amt(i):'||x_tab.buc_frt_alloc_amt(i));
    localdebug('  x_tab.BASE_FRT_PRO_AMT(i):'||x_tab.BASE_FRT_PRO_AMT(i));
    END IF;
      x_run_frt_amt := x_run_frt_amt + x_tab.ELMT_FRT_PRO_AMT(i);
      l_frt_alloc    := CurrRound(  x_run_frt_amt
                                 / x_tab.BASE_FRT_PRO_AMT(i)
                                 * x_tab.buc_frt_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_frt_alloc;
      x_tab.tl_frt_alloc_amt(i) := l_frt_alloc;
      x_run_frt_alloc := x_run_frt_alloc + l_frt_alloc;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_tab.tl_frt_alloc_amt(i):'||x_tab.tl_frt_alloc_amt(i));
    localdebug('  x_run_frt_alloc:'||x_run_frt_alloc);
    localdebug('  l_frt_alloc:'||l_frt_alloc);
    END IF;
    ELSE
      x_tab.tl_frt_alloc_amt(i) := 0;
    END IF;


    /*-------------------------------------------------+
     | Running frt acctd amount in trx currency        |
     +-------------------------------------------------*/
    IF x_tab.BASE_FRT_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_frt_alloc_acctd_amt(i) <> 0 THEN
      x_run_frt_acctd_amt := x_run_frt_acctd_amt + x_tab.ELMT_FRT_PRO_ACCTD_AMT(i);
      l_frt_acctd_alloc    := CurrRound(  x_run_frt_acctd_amt
                                 / x_tab.BASE_FRT_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_frt_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_frt_acctd_alloc;
      x_tab.tl_frt_alloc_acctd_amt(i) := l_frt_acctd_alloc;
      x_run_frt_acctd_alloc := x_run_frt_acctd_alloc + l_frt_acctd_alloc;
    ELSE
      x_tab.tl_frt_alloc_acctd_amt(i) := 0;
    END IF;

    /*-------------------------------------------------+
     | Running chrg amount in trx currency             |
     +-------------------------------------------------*/

    IF x_tab.BASE_CHRG_PRO_AMT(i) <> 0 AND x_tab.buc_chrg_alloc_amt(i) <> 0 THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_run_chrg_amt:'||x_run_chrg_amt);
    localdebug('  x_tab.ELMT_CHRG_PRO_AMT(i):'||x_tab.ELMT_CHRG_PRO_AMT(i));
    localdebug('  x_tab.buc_chrg_alloc_amt(i):'||x_tab.buc_chrg_alloc_amt(i));
    localdebug('  x_tab.BASE_CHRG_PRO_AMT(i):'||x_tab.BASE_CHRG_PRO_AMT(i));
    localdebug('  x_tab.to_currency(i):'||x_tab.to_currency(i));
    END IF;
      x_run_chrg_amt := x_run_chrg_amt + x_tab.ELMT_CHRG_PRO_AMT(i);
      l_chrg_alloc    := CurrRound(  x_run_chrg_amt
                                 / x_tab.BASE_CHRG_PRO_AMT(i)
                                 * x_tab.buc_chrg_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_chrg_alloc;
      x_tab.tl_chrg_alloc_amt(i) := l_chrg_alloc;
      x_run_chrg_alloc := x_run_chrg_alloc + l_chrg_alloc;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  x_tab.tl_chrg_alloc_amt(i):'||x_tab.tl_chrg_alloc_amt(i));
    localdebug('  x_run_chrg_alloc:'||x_run_chrg_alloc);
    localdebug('  l_chrg_alloc:'||l_chrg_alloc);
    END IF;
    ELSE
      x_tab.tl_chrg_alloc_amt(i) := 0;
    END IF;


    /*-------------------------------------------------+
     | Running chrg acctd amount in trx currency       |
     +-------------------------------------------------*/
    IF x_tab.BASE_CHRG_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_chrg_alloc_acctd_amt(i) <> 0 THEN
      x_run_chrg_acctd_amt := x_run_chrg_acctd_amt + x_tab.ELMT_CHRG_PRO_ACCTD_AMT(i);
      l_chrg_acctd_alloc    := CurrRound(  x_run_chrg_acctd_amt
                                 / x_tab.BASE_CHRG_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_chrg_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_chrg_acctd_alloc;
      x_tab.tl_chrg_alloc_acctd_amt(i) := l_chrg_acctd_alloc;
      x_run_chrg_acctd_alloc := x_run_chrg_acctd_alloc + l_chrg_acctd_alloc;
    ELSE
      x_tab.tl_chrg_alloc_acctd_amt(i) := 0;
    END IF;


   /********************************
    -- ED
    ********************************/
   IF g_ed_req  = 'Y' THEN
      /*-------------------------------------------------+
       | Running Revenue amount in trx currency          |
       +-------------------------------------------------*/

      IF x_tab.base_ed_pro_amt(i) <> 0 AND x_tab.buc_ed_alloc_amt(i) <> 0 THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_ed_amt:'||x_run_ed_amt);
      localdebug('  x_tab.elmt_ed_pro_amt(i):'||x_tab.elmt_ed_pro_amt(i));
      localdebug('  x_tab.buc_ed_alloc_amt(i):'||x_tab.buc_ed_alloc_amt(i));
      localdebug('  x_tab.base_ed_pro_amt(i):'||x_tab.base_ed_pro_amt(i));
      END IF;
        x_run_ed_amt := x_run_ed_amt + x_tab.elmt_ed_pro_amt(i);
        l_ed_alloc    := CurrRound(  x_run_ed_amt
                                 / x_tab.base_ed_pro_amt(i)
                                 * x_tab.buc_ed_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_ed_alloc;
        -- MAJ proration_res_tbl.res_pro := l_alloc;
        x_tab.tl_ed_alloc_amt(i) := l_ed_alloc;
        x_run_ed_alloc := x_run_ed_alloc + l_ed_alloc;
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_ed_alloc_amt(i):'||x_tab.tl_ed_alloc_amt(i));
      localdebug('  x_run_ed_alloc:'||x_run_ed_alloc);
      localdebug('  l_ed_alloc:'||l_ed_alloc);
      END IF;
      ELSE
        x_tab.tl_ed_alloc_amt(i) := 0;
      END IF;


      /*-------------------------------------------------+
       | Running Revenue amount in base currency         |
       +-------------------------------------------------*/
      IF x_tab.base_ed_pro_acctd_amt(i) <> 0 AND x_tab.buc_ed_alloc_acctd_amt(i) <> 0 THEN
	IF PG_DEBUG = 'Y' THEN
	  localdebug('  x_run_ed_acctd_amt:'||x_run_ed_acctd_amt);
	  localdebug('  x_tab.elmt_ed_pro_acctd_amt(i):'||x_tab.elmt_ed_pro_acctd_amt(i));
	  localdebug('  x_tab.buc_ed_alloc_acctd_amt(i):'||x_tab.buc_ed_alloc_acctd_amt(i));
	  localdebug('  x_tab.base_ed_pro_acctd_amt(i):'||x_tab.base_ed_pro_acctd_amt(i));
	END IF;
        x_run_ed_acctd_amt := x_run_ed_acctd_amt + x_tab.elmt_ed_pro_acctd_amt(i);
        l_ed_acctd_alloc    := CurrRound(  x_run_ed_acctd_amt
                                 / x_tab.base_ed_pro_acctd_amt(i)
                                 * x_tab.buc_ed_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_ed_acctd_alloc;
        -- MAJ proration_res_tbl.res_pro := l_alloc;
        x_tab.tl_ed_alloc_acctd_amt(i) := l_ed_acctd_alloc;
        x_run_ed_acctd_alloc := x_run_ed_acctd_alloc + l_ed_acctd_alloc;
	IF PG_DEBUG = 'Y' THEN
	  localdebug('  x_tab.tl_ed_alloc_acctd_amt(i):'||x_tab.tl_ed_alloc_acctd_amt(i));
	  localdebug('  x_run_ed_acctd_alloc:'||x_run_ed_acctd_alloc);
	  localdebug('  l_ed_acctd_alloc:'||l_ed_acctd_alloc);
	END IF;
      ELSE
        x_tab.tl_ed_alloc_acctd_amt(i) := 0;
      END IF;



      /*-------------------------------------------------+
       | Running tax amount in trx currency              |
       +-------------------------------------------------*/

      IF x_tab.BASE_ed_tax_PRO_AMT(i) <> 0 AND x_tab.buc_ed_tax_alloc_amt(i) <> 0 THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_ed_tax_amt:'||x_run_ed_tax_amt);
      localdebug('  x_tab.ELMT_ed_tax_PRO_AMT(i):'||x_tab.ELMT_ed_tax_PRO_AMT(i));
      localdebug('  x_tab.buc_ed_tax_alloc_amt(i):'||x_tab.buc_ed_tax_alloc_amt(i));
      localdebug('  x_tab.BASE_ed_tax_PRO_AMT(i):'||x_tab.BASE_ed_tax_PRO_AMT(i));
      END IF;
        x_run_ed_tax_amt := x_run_ed_tax_amt + x_tab.ELMT_ed_tax_PRO_AMT(i);
        l_ed_tax_alloc    := CurrRound(  x_run_ed_tax_amt
                                 / x_tab.BASE_ed_tax_PRO_AMT(i)
                                 * x_tab.buc_ed_tax_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_ed_tax_alloc;
        x_tab.tl_ed_tax_alloc_amt(i) := l_ed_tax_alloc;
        x_run_ed_tax_alloc := x_run_ed_tax_alloc + l_ed_tax_alloc;
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_ed_tax_alloc_amt(i):'||x_tab.tl_ed_tax_alloc_amt(i));
      localdebug('  x_run_ed_tax_alloc:'||x_run_ed_tax_alloc);
      localdebug('  l_ed_tax_alloc:'||l_ed_tax_alloc);
      END IF;
      ELSE
        x_tab.tl_ed_tax_alloc_amt(i) := 0;
      END IF;


      /*-------------------------------------------------+
       | Running tax acctd amount in trx currency        |
       +-------------------------------------------------*/
      IF x_tab.BASE_ed_tax_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_ed_tax_alloc_acctd_amt(i) <> 0 THEN
	IF PG_DEBUG = 'Y' THEN
	  localdebug('  x_run_ed_tax_acctd_amt:'||x_run_ed_tax_acctd_amt);
	  localdebug('  x_tab.ELMT_ed_tax_PRO_ACCTD_AMT(i):'||x_tab.ELMT_ed_tax_PRO_ACCTD_AMT(i));
	  localdebug('  x_tab.buc_ed_tax_alloc_acctd_amt(i):'||x_tab.buc_ed_tax_alloc_acctd_amt(i));
	  localdebug('  x_tab.BASE_ed_tax_PRO_ACCTD_AMT(i):'||x_tab.BASE_ed_tax_PRO_ACCTD_AMT(i));
	END IF;
        x_run_ed_tax_acctd_amt := x_run_ed_tax_acctd_amt + x_tab.ELMT_ed_tax_PRO_ACCTD_AMT(i);
        l_ed_tax_acctd_alloc    := CurrRound(  x_run_ed_tax_acctd_amt
                                 / x_tab.BASE_ed_tax_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_ed_tax_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_ed_tax_acctd_alloc;
        x_tab.tl_ed_tax_alloc_acctd_amt(i) := l_ed_tax_acctd_alloc;
        x_run_ed_tax_acctd_alloc := x_run_ed_tax_acctd_alloc + l_ed_tax_acctd_alloc;
	IF PG_DEBUG = 'Y' THEN
	  localdebug('  x_tab.tl_ed_tax_alloc_acctd_amt(i):'||x_tab.tl_ed_tax_alloc_acctd_amt(i));
	  localdebug('  x_run_ed_tax_acctd_alloc:'||x_run_ed_tax_acctd_alloc);
	  localdebug('  l_ed_tax_acctd_alloc:'||l_ed_tax_acctd_alloc);
	END IF;
      ELSE
        x_tab.tl_ed_tax_alloc_acctd_amt(i) := 0;
      END IF;

      /*-------------------------------------------------+
       | Running frt amount in trx currency              |
       +-------------------------------------------------*/

      IF x_tab.BASE_ed_FRT_PRO_AMT(i) <> 0 AND x_tab.buc_ed_frt_alloc_amt(i) <> 0 THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_ed_frt_amt:'||x_run_ed_frt_amt);
      localdebug('  x_tab.ELMT_ed_FRT_PRO_AMT(i):'||x_tab.ELMT_ed_FRT_PRO_AMT(i));
      localdebug('  x_tab.buc_ed_frt_alloc_amt(i):'||x_tab.buc_ed_frt_alloc_amt(i));
      localdebug('  x_tab.BASE_ed_FRT_PRO_AMT(i):'||x_tab.BASE_ed_FRT_PRO_AMT(i));
      END IF;
        x_run_ed_frt_amt := x_run_ed_frt_amt + x_tab.ELMT_ed_FRT_PRO_AMT(i);
        l_ed_frt_alloc    := CurrRound(  x_run_ed_frt_amt
                                 / x_tab.BASE_ed_frt_PRO_AMT(i)
                                 * x_tab.buc_ed_frt_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_ed_frt_alloc;
        x_tab.tl_ed_frt_alloc_amt(i) := l_ed_frt_alloc;
        x_run_ed_frt_alloc := x_run_ed_frt_alloc + l_ed_frt_alloc;
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_ed_frt_alloc_amt(i):'||x_tab.tl_ed_frt_alloc_amt(i));
      localdebug('  x_run_ed_frt_alloc:'||x_run_ed_frt_alloc);
      localdebug('  l_ed_frt_alloc:'||l_ed_frt_alloc);
      END IF;
      ELSE
        x_tab.tl_ed_frt_alloc_amt(i) := 0;
      END IF;


      /*-------------------------------------------------+
       | Running frt acctd amount in trx currency        |
       +-------------------------------------------------*/
      IF x_tab.BASE_ed_FRT_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_ed_frt_alloc_acctd_amt(i) <> 0 THEN
        x_run_ed_frt_acctd_amt := x_run_ed_frt_acctd_amt + x_tab.ELMT_ed_FRT_PRO_ACCTD_AMT(i);
        l_ed_frt_acctd_alloc    := CurrRound(  x_run_ed_frt_acctd_amt
                                 / x_tab.BASE_ed_FRT_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_ed_frt_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_ed_frt_acctd_alloc;
        x_tab.tl_ed_frt_alloc_acctd_amt(i) := l_ed_frt_acctd_alloc;
        x_run_ed_frt_acctd_alloc := x_run_ed_frt_acctd_alloc + l_ed_frt_acctd_alloc;
      ELSE
        x_tab.tl_ed_frt_alloc_acctd_amt(i) := 0;
      END IF;

      /*-------------------------------------------------+
       | Running chrg amount in trx currency             |
       +-------------------------------------------------*/

      IF x_tab.BASE_ed_CHRG_PRO_AMT(i) <> 0 AND x_tab.buc_ed_chrg_alloc_amt(i) <> 0 THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_ed_chrg_amt:'||x_run_ed_chrg_amt);
      localdebug('  x_tab.ELMT_ed_CHRG_PRO_AMT(i):'||x_tab.ELMT_ed_CHRG_PRO_AMT(i));
      localdebug('  x_tab.buc_ed_chrg_alloc_amt(i):'||x_tab.buc_ed_chrg_alloc_amt(i));
      localdebug('  x_tab.BASE_ed_CHRG_PRO_AMT(i):'||x_tab.BASE_ed_CHRG_PRO_AMT(i));
      END IF;
        x_run_ed_chrg_amt := x_run_ed_chrg_amt + x_tab.ELMT_ed_CHRG_PRO_AMT(i);
        l_ed_chrg_alloc    := CurrRound(  x_run_ed_chrg_amt
                                 / x_tab.BASE_ed_CHRG_PRO_AMT(i)
                                 * x_tab.buc_ed_chrg_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_ed_chrg_alloc;
        x_tab.tl_ed_chrg_alloc_amt(i) := l_ed_chrg_alloc;
        x_run_ed_chrg_alloc := x_run_ed_chrg_alloc + l_ed_chrg_alloc;
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_ed_chrg_alloc_amt(i):'||x_tab.tl_ed_chrg_alloc_amt(i));
      localdebug('  x_run_ed_chrg_alloc:'||x_run_ed_chrg_alloc);
      localdebug('  l_ed_chrg_alloc:'||l_ed_chrg_alloc);
      END IF;
      ELSE
        x_tab.tl_ed_chrg_alloc_amt(i) := 0;
      END IF;


      /*-------------------------------------------------+
       | Running chrg acctd amount in trx currency       |
       +-------------------------------------------------*/
      IF x_tab.BASE_ed_CHRG_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_ed_chrg_alloc_acctd_amt(i) <> 0 THEN
        x_run_ed_chrg_acctd_amt := x_run_ed_chrg_acctd_amt + x_tab.ELMT_ed_CHRG_PRO_ACCTD_AMT(i);
        l_ed_chrg_acctd_alloc    := CurrRound(  x_run_ed_chrg_acctd_amt
                                 / x_tab.BASE_ed_CHRG_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_ed_chrg_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_ed_chrg_acctd_alloc;
        x_tab.tl_ed_chrg_alloc_acctd_amt(i) := l_ed_chrg_acctd_alloc;
        x_run_ed_chrg_acctd_alloc := x_run_ed_chrg_acctd_alloc + l_ed_chrg_acctd_alloc;
      ELSE
        x_tab.tl_ed_chrg_alloc_acctd_amt(i) := 0;
      END IF;

    ELSE

      x_tab.tl_ed_alloc_amt(i) := 0;
      x_tab.tl_ed_alloc_acctd_amt(i) := 0;
      x_tab.tl_ed_tax_alloc_amt(i) := 0;
      x_tab.tl_ed_tax_alloc_acctd_amt(i) := 0;
      x_tab.tl_ed_frt_alloc_amt(i) := 0;
      x_tab.tl_ed_frt_alloc_acctd_amt(i) := 0;
      x_tab.tl_ed_chrg_alloc_amt(i) := 0;
      x_tab.tl_ed_chrg_alloc_acctd_amt(i) := 0;

    END IF;

    /********************************
    -- UNED
    ********************************/
    IF g_uned_req = 'Y' THEN
      /*-------------------------------------------------+
       | Running revenue in trx currency                 |
       +-------------------------------------------------*/
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_uned_amt:'||x_run_uned_amt);
      localdebug('  x_tab.elmt_uned_pro_amt(i):'||x_tab.elmt_uned_pro_amt(i));
      localdebug('  x_tab.buc_uned_alloc_amt(i):'||x_tab.buc_uned_alloc_amt(i));
      localdebug('  x_tab.base_uned_pro_amt(i):'||x_tab.base_uned_pro_amt(i));
      END IF;

      IF x_tab.base_uned_pro_amt(i) <> 0 AND x_tab.buc_uned_alloc_amt(i) <> 0 THEN
        x_run_uned_amt := x_run_uned_amt + x_tab.elmt_uned_pro_amt(i);
        l_uned_alloc    := CurrRound(  x_run_uned_amt
                                 / x_tab.base_uned_pro_amt(i)
                                 * x_tab.buc_uned_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_uned_alloc;
        -- MAJ proration_res_tbl.res_pro := l_alloc;
        x_tab.tl_uned_alloc_amt(i) := l_uned_alloc;
        x_run_uned_alloc := x_run_uned_alloc + l_uned_alloc;
      ELSE
        x_tab.tl_uned_alloc_amt(i) := 0;
      END IF;

      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_uned_alloc_amt(i):'||x_tab.tl_uned_alloc_amt(i));
      localdebug('  x_run_uned_alloc:'||x_run_uned_alloc);
      localdebug('  l_uned_alloc:'||l_uned_alloc);
      END IF;

      /*-------------------------------------------------+
       | Running revenue in base currency                |
       +-------------------------------------------------*/
      IF x_tab.base_uned_pro_acctd_amt(i) <> 0 AND x_tab.buc_uned_alloc_acctd_amt(i) <> 0 THEN
        x_run_uned_acctd_amt := x_run_uned_acctd_amt + x_tab.elmt_uned_pro_acctd_amt(i);
        l_uned_acctd_alloc    := CurrRound(  x_run_uned_acctd_amt
                                 / x_tab.base_uned_pro_acctd_amt(i)
                                 * x_tab.buc_uned_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_uned_acctd_alloc;
        -- MAJ proration_res_tbl.res_pro := l_alloc;
        x_tab.tl_uned_alloc_acctd_amt(i) := l_uned_acctd_alloc;
        x_run_uned_acctd_alloc := x_run_uned_acctd_alloc + l_uned_acctd_alloc;
      ELSE
        x_tab.tl_uned_alloc_acctd_amt(i) := 0;
      END IF;



      /*-------------------------------------------------+
       | Running tax amount in trx currency              |
       +-------------------------------------------------*/
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_uned_tax_amt:'||x_run_uned_tax_amt);
      localdebug('  x_tab.ELMT_uned_tax_PRO_AMT(i):'||x_tab.ELMT_uned_tax_PRO_AMT(i));
      localdebug('  x_tab.buc_uned_tax_alloc_amt(i):'||x_tab.buc_uned_tax_alloc_amt(i));
      localdebug('  x_tab.BASE_uned_tax_PRO_AMT(i):'||x_tab.BASE_uned_tax_PRO_AMT(i));
      END IF;

      IF x_tab.BASE_uned_tax_PRO_AMT(i) <> 0 AND x_tab.buc_uned_tax_alloc_amt(i) <> 0 THEN
        x_run_uned_tax_amt := x_run_uned_tax_amt + x_tab.ELMT_uned_tax_PRO_AMT(i);
        l_uned_tax_alloc    := CurrRound(  x_run_uned_tax_amt
                                 / x_tab.BASE_uned_tax_PRO_AMT(i)
                                 * x_tab.buc_uned_tax_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_uned_tax_alloc;
        x_tab.tl_uned_tax_alloc_amt(i) := l_uned_tax_alloc;
        x_run_uned_tax_alloc := x_run_uned_tax_alloc + l_uned_tax_alloc;
      ELSE
        x_tab.tl_uned_tax_alloc_amt(i) := 0;
      END IF;

      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_uned_tax_alloc_amt(i):'||x_tab.tl_uned_tax_alloc_amt(i));
      localdebug('  x_run_uned_tax_alloc:'||x_run_uned_tax_alloc);
      localdebug('  l_uned_tax_alloc:'||l_uned_tax_alloc);
      END IF;

      /*-------------------------------------------------+
       | Running tax acctd amount in trx currency        |
       +-------------------------------------------------*/
      IF x_tab.BASE_uned_tax_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_uned_tax_alloc_acctd_amt(i) <> 0 THEN
        x_run_uned_tax_acctd_amt := x_run_uned_tax_acctd_amt + x_tab.ELMT_uned_tax_PRO_ACCTD_AMT(i);
        l_uned_tax_acctd_alloc    := CurrRound(  x_run_uned_tax_acctd_amt
                                 / x_tab.BASE_uned_tax_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_uned_tax_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_uned_tax_acctd_alloc;
        x_tab.tl_uned_tax_alloc_acctd_amt(i) := l_uned_tax_acctd_alloc;
        x_run_uned_tax_acctd_alloc := x_run_uned_tax_acctd_alloc + l_uned_tax_acctd_alloc;
      ELSE
        x_tab.tl_uned_tax_alloc_acctd_amt(i) := 0;
      END IF;


      /*-------------------------------------------------+
       | Running frt amount in trx currency              |
       +-------------------------------------------------*/
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_uned_frt_amt:'||x_run_uned_frt_amt);
      localdebug('  x_tab.ELMT_uned_frt_PRO_AMT(i):'||x_tab.ELMT_uned_frt_PRO_AMT(i));
      localdebug('  x_tab.buc_uned_frt_alloc_amt(i):'||x_tab.buc_uned_frt_alloc_amt(i));
      localdebug('  x_tab.BASE_uned_frt_PRO_AMT(i):'||x_tab.BASE_uned_frt_PRO_AMT(i));
      END IF;

      IF x_tab.BASE_uned_frt_PRO_AMT(i) <> 0 AND x_tab.buc_uned_frt_alloc_amt(i) <> 0 THEN
        x_run_uned_frt_amt := x_run_uned_frt_amt + x_tab.ELMT_uned_frt_PRO_AMT(i);
        l_uned_frt_alloc    := CurrRound(  x_run_uned_frt_amt
                                 / x_tab.BASE_uned_frt_PRO_AMT(i)
                                 * x_tab.buc_uned_frt_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_uned_frt_alloc;
        x_tab.tl_uned_frt_alloc_amt(i) := l_uned_frt_alloc;
        x_run_uned_frt_alloc := x_run_uned_frt_alloc + l_uned_frt_alloc;
      ELSE
        x_tab.tl_uned_frt_alloc_amt(i) := 0;
      END IF;

      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_uned_frt_alloc_amt(i):'||x_tab.tl_uned_frt_alloc_amt(i));
      localdebug('  x_run_uned_frt_alloc:'||x_run_uned_frt_alloc);
      localdebug('  l_uned_frt_alloc:'||l_uned_frt_alloc);
      END IF;

      /*-------------------------------------------------+
       | Running frt acctd amount in trx currency        |
       +-------------------------------------------------*/
      IF x_tab.BASE_uned_frt_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_uned_frt_alloc_acctd_amt(i) <> 0 THEN
        x_run_uned_frt_acctd_amt := x_run_uned_frt_acctd_amt + x_tab.ELMT_uned_frt_PRO_ACCTD_AMT(i);
        l_uned_frt_acctd_alloc    := CurrRound(  x_run_uned_frt_acctd_amt
                                 / x_tab.BASE_uned_frt_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_uned_frt_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_uned_frt_acctd_alloc;
        x_tab.tl_uned_frt_alloc_acctd_amt(i) := l_uned_frt_acctd_alloc;
        x_run_uned_frt_acctd_alloc := x_run_uned_frt_acctd_alloc + l_uned_frt_acctd_alloc;
      ELSE
        x_tab.tl_uned_frt_alloc_acctd_amt(i) := 0;
      END IF;

      /*-------------------------------------------------+
       | Running chrg amount in trx currency             |
       +-------------------------------------------------*/
      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_run_uned_chrg_amt:'||x_run_uned_chrg_amt);
      localdebug('  x_tab.ELMT_uned_CHRG_PRO_AMT(i):'||x_tab.ELMT_uned_CHRG_PRO_AMT(i));
      localdebug('  x_tab.buc_uned_chrg_alloc_amt(i):'||x_tab.buc_uned_chrg_alloc_amt(i));
      localdebug('  x_tab.BASE_uned_CHRG_PRO_AMT(i):'||x_tab.BASE_uned_CHRG_PRO_AMT(i));
      END IF;

      IF x_tab.BASE_uned_CHRG_PRO_AMT(i) <> 0 AND x_tab.buc_uned_chrg_alloc_amt(i) <> 0 THEN
        x_run_uned_chrg_amt := x_run_uned_chrg_amt + x_tab.ELMT_uned_CHRG_PRO_AMT(i);
        l_uned_chrg_alloc    := CurrRound(  x_run_uned_chrg_amt
                                 / x_tab.BASE_uned_CHRG_PRO_AMT(i)
                                 * x_tab.buc_uned_chrg_alloc_amt(i),
                                   x_tab.to_currency(i))
                               - x_run_uned_chrg_alloc;
        x_tab.tl_uned_chrg_alloc_amt(i) := l_uned_chrg_alloc;
        x_run_uned_chrg_alloc := x_run_uned_chrg_alloc + l_uned_chrg_alloc;
      ELSE
        x_tab.tl_uned_chrg_alloc_amt(i) := 0;
      END IF;

      IF PG_DEBUG = 'Y' THEN
      localdebug('  x_tab.tl_uned_chrg_alloc_amt(i):'||x_tab.tl_uned_chrg_alloc_amt(i));
      localdebug('  x_run_uned_chrg_alloc:'||x_run_uned_chrg_alloc);
      localdebug('  l_uned_chrg_alloc:'||l_uned_chrg_alloc);
      END IF;

      /*-------------------------------------------------+
       | Running chrg acctd amount in trx currency       |
       +-------------------------------------------------*/
      IF x_tab.BASE_uned_CHRG_PRO_ACCTD_AMT(i) <> 0 AND x_tab.buc_uned_chrg_alloc_acctd_amt(i) <> 0 THEN
        x_run_uned_chrg_acctd_amt := x_run_uned_chrg_acctd_amt + x_tab.ELMT_uned_CHRG_PRO_ACCTD_AMT(i);
        l_uned_chrg_acctd_alloc    := CurrRound(  x_run_uned_chrg_acctd_amt
                                 / x_tab.BASE_uned_CHRG_PRO_ACCTD_AMT(i)
                                 * x_tab.buc_uned_chrg_alloc_acctd_amt(i),
                                   x_tab.base_currency(i))
                               - x_run_uned_chrg_acctd_alloc;
        x_tab.tl_uned_chrg_alloc_acctd_amt(i) := l_uned_chrg_acctd_alloc;
        x_run_uned_chrg_acctd_alloc := x_run_uned_chrg_acctd_alloc + l_uned_chrg_acctd_alloc;
      ELSE
        x_tab.tl_uned_chrg_alloc_acctd_amt(i) := 0;
      END IF;
    ELSE

      x_tab.tl_uned_alloc_amt(i) := 0;
      x_tab.tl_uned_alloc_acctd_amt(i) := 0;
      x_tab.tl_uned_tax_alloc_amt(i) := 0;
      x_tab.tl_uned_tax_alloc_acctd_amt(i) := 0;
      x_tab.tl_uned_frt_alloc_amt(i) := 0;
      x_tab.tl_uned_frt_alloc_acctd_amt(i) := 0;
      x_tab.tl_uned_chrg_alloc_amt(i) := 0;
      x_tab.tl_uned_chrg_alloc_acctd_amt(i) := 0;

    END IF;

    IF i = x_tab.ROWID_ID.LAST THEN
      -- Store the last group
      store_group
      (p_groupe                => l_group,
       -- ADJ and APP
       p_run_amt               => x_run_amt,
       p_run_alloc             => x_run_alloc,
       p_run_acctd_amt         => x_run_acctd_amt,
       p_run_acctd_alloc       => x_run_acctd_alloc,
       p_run_chrg_amt          => x_run_chrg_amt,
       p_run_chrg_alloc        => x_run_chrg_alloc,
       p_run_chrg_acctd_amt    => x_run_chrg_acctd_amt,
       p_run_chrg_acctd_alloc  => x_run_chrg_acctd_alloc,
       p_run_frt_amt          => x_run_frt_amt,
       p_run_frt_alloc        => x_run_frt_alloc,
       p_run_frt_acctd_amt    => x_run_frt_acctd_amt,
       p_run_frt_acctd_alloc  => x_run_frt_acctd_alloc,
       p_run_tax_amt          => x_run_tax_amt,
       p_run_tax_alloc        => x_run_tax_alloc,
       p_run_tax_acctd_amt    => x_run_tax_acctd_amt,
       p_run_tax_acctd_alloc  => x_run_tax_acctd_alloc,
       -- ED
       p_run_ed_amt               => x_run_ed_amt,
       p_run_ed_alloc             => x_run_ed_alloc,
       p_run_ed_acctd_amt         => x_run_ed_acctd_amt,
       p_run_ed_acctd_alloc       => x_run_ed_acctd_alloc,
       p_run_ed_chrg_amt          => x_run_ed_chrg_amt,
       p_run_ed_chrg_alloc        => x_run_ed_chrg_alloc,
       p_run_ed_chrg_acctd_amt    => x_run_ed_chrg_acctd_amt,
       p_run_ed_chrg_acctd_alloc  => x_run_ed_chrg_acctd_alloc,
       p_run_ed_frt_amt          => x_run_ed_frt_amt,
       p_run_ed_frt_alloc        => x_run_ed_frt_alloc,
       p_run_ed_frt_acctd_amt    => x_run_ed_frt_acctd_amt,
       p_run_ed_frt_acctd_alloc  => x_run_ed_frt_acctd_alloc,
       p_run_ed_tax_amt          => x_run_ed_tax_amt,
       p_run_ed_tax_alloc        => x_run_ed_tax_alloc,
       p_run_ed_tax_acctd_amt    => x_run_ed_tax_acctd_amt,
       p_run_ed_tax_acctd_alloc  => x_run_ed_tax_acctd_alloc,
       -- UNED
       p_run_uned_amt               => x_run_uned_amt,
       p_run_uned_alloc             => x_run_uned_alloc,
       p_run_uned_acctd_amt         => x_run_uned_acctd_amt,
       p_run_uned_acctd_alloc       => x_run_uned_acctd_alloc,
       p_run_uned_chrg_amt          => x_run_uned_chrg_amt,
       p_run_uned_chrg_alloc        => x_run_uned_chrg_alloc,
       p_run_uned_chrg_acctd_amt    => x_run_uned_chrg_acctd_amt,
       p_run_uned_chrg_acctd_alloc  => x_run_uned_chrg_acctd_alloc,
       p_run_uned_frt_amt          => x_run_uned_frt_amt,
       p_run_uned_frt_alloc        => x_run_uned_frt_alloc,
       p_run_uned_frt_acctd_amt    => x_run_uned_frt_acctd_amt,
       p_run_uned_frt_acctd_alloc  => x_run_uned_frt_acctd_alloc,
       p_run_uned_tax_amt          => x_run_uned_tax_amt,
       p_run_uned_tax_alloc        => x_run_uned_tax_alloc,
       p_run_uned_tax_acctd_amt    => x_run_uned_tax_acctd_amt,
       p_run_uned_tax_acctd_alloc  => x_run_uned_tax_acctd_alloc,
       --
       x_group_tbl             => x_group_tbl);
    END IF;

  END LOOP;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.plsql_proration()-');
  END IF;
EXCEPTION
 WHEN tbl_pro_res_tbl_empty THEN
   IF PG_DEBUG = 'Y' THEN
   localdebug('EXCEPTION tbl_pro_res_tbl_empty in PLSQL_PRORATION '||
                      ' table containing element over which proration should happen is empty');
   END IF;
 WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
   localdebug('EXCEPTION OTHERS in PLSQL_PRORATION :'|| SQLERRM);
   END IF;
    RAISE;
END plsql_proration;



PROCEDURE update_line
(p_gt_id           IN VARCHAR2,
 p_customer_trx_id IN NUMBER,
 p_ae_sys_rec      IN arp_acct_main.ae_sys_rec_type)
IS
  CURSOR c_read_for_line IS
    SELECT /*+INDEX (b ra_ar_n1) INDEX(d RA_AR_AMOUNTS_GT_N1)*/
           b.group_id||'-'||b.line_type||'-'||
           b.ref_customer_trx_id || '-' ||
		   b.ref_customer_trx_line_id    groupe,
         -- ADJ AND APP
           --Base
           d.base_pro_amt,
           d.base_pro_acctd_amt,
           d.base_frt_pro_amt,
           d.base_frt_pro_acctd_amt,
           d.base_tax_pro_amt,
           d.base_tax_pro_acctd_amt,
           d.BASE_CHRG_PRO_AMT,
           d.BASE_CHRG_PRO_ACCTD_AMT,
           --Element
           d.elmt_pro_amt,
           d.elmt_pro_acctd_amt,
           d.ELMT_FRT_PRO_AMT,
           d.ELMT_FRT_PRO_ACCTD_AMT,
           d.ELMT_tax_PRO_AMT,
           d.ELMT_tax_PRO_ACCTD_AMT,
           d.ELMT_CHRG_PRO_AMT,
           d.ELMT_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           d.buc_alloc_amt,
           d.buc_alloc_acctd_amt,
           d.buc_frt_alloc_amt,
           d.buc_frt_alloc_acctd_amt,
           d.buc_tax_alloc_amt,
           d.buc_tax_alloc_acctd_amt,
           d.buc_chrg_alloc_amt,
           d.buc_chrg_alloc_acctd_amt,
         -- ED
           --Base
           d.base_ed_pro_amt,
           d.base_ed_pro_acctd_amt,
           d.BASE_ed_frt_PRO_AMT,
           d.BASE_ed_frt_PRO_ACCTD_AMT,
           d.BASE_ed_tax_PRO_AMT,
           d.BASE_ed_tax_PRO_ACCTD_AMT,
           d.BASE_ed_CHRG_PRO_AMT,
           d.BASE_ed_CHRG_PRO_ACCTD_AMT,
           --Element
           d.elmt_ed_pro_amt,
           d.elmt_ed_pro_acctd_amt,
           d.ELMT_ed_FRT_PRO_AMT,
           d.ELMT_ed_FRT_PRO_ACCTD_AMT,
           d.ELMT_ed_tax_PRO_AMT,
           d.ELMT_ed_tax_PRO_ACCTD_AMT,
           d.ELMT_ed_CHRG_PRO_AMT,
           d.ELMT_ed_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           d.buc_ed_alloc_amt,
           d.buc_ed_alloc_acctd_amt,
           d.buc_ed_frt_alloc_amt,
           d.buc_ed_frt_alloc_acctd_amt,
           d.buc_ed_tax_alloc_amt,
           d.buc_ed_tax_alloc_acctd_amt,
           d.buc_ed_chrg_alloc_amt,
           d.buc_ed_chrg_alloc_acctd_amt,
         -- UNED
           --Base
           d.base_uned_pro_amt,
           d.base_uned_pro_acctd_amt,
           d.BASE_uned_FRT_PRO_AMT,
           d.BASE_uned_FRT_PRO_ACCTD_AMT,
           d.BASE_uned_tax_PRO_AMT,
           d.BASE_uned_tax_PRO_ACCTD_AMT,
           d.BASE_uned_CHRG_PRO_AMT,
           d.BASE_uned_CHRG_PRO_ACCTD_AMT,
           --Element
           d.elmt_uned_pro_amt,
           d.elmt_uned_pro_acctd_amt,
           d.ELMT_uned_FRT_PRO_AMT,
           d.ELMT_uned_FRT_PRO_ACCTD_AMT,
           d.ELMT_uned_tax_PRO_AMT,
           d.ELMT_uned_tax_PRO_ACCTD_AMT,
           d.ELMT_uned_CHRG_PRO_AMT,
           d.ELMT_uned_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           d.buc_uned_alloc_amt,
           d.buc_uned_alloc_acctd_amt,
           d.buc_uned_frt_alloc_amt,
           d.buc_uned_frt_alloc_acctd_amt,
           d.buc_uned_tax_alloc_amt,
           d.buc_uned_tax_alloc_acctd_amt,
           d.buc_uned_chrg_alloc_amt,
           d.buc_uned_chrg_alloc_acctd_amt,
         ----
           --Currencies
           b.BASE_CURRENCY  ,
           b.TO_CURRENCY    ,
           b.FROM_CURRENCY  ,
           -- Rowid
           b.rowid
     FROM  RA_AR_GT b,
           RA_AR_AMOUNTS_GT d
    WHERE b.gt_id  = p_gt_id
      AND b.ref_customer_trx_id = p_customer_trx_id
      AND b.gp_level            = 'L'
      AND d.gt_id               = b.gt_id
      AND d.base_rec_rowid      = b.rowid
      --Bug#3611016
      AND b.SET_OF_BOOKS_ID     = p_ae_sys_rec.set_of_books_id
      AND (b.SOB_TYPE   = p_ae_sys_rec.sob_type OR
           (b.SOB_TYPE IS NULL AND p_ae_sys_rec.sob_type IS NULL))
     ORDER BY b.group_id||'-'||
              b.line_type||'-'||b.ref_customer_trx_id || '-' ||b.ref_customer_trx_line_id;
  l_tab  pro_res_tbl_type;

  l_group_tbl            group_tbl_type;
  l_group                VARCHAR2(900)    := 'NOGROUP';

  -- ADJ and APP
  l_run_amt              NUMBER          := 0;
  l_run_alloc            NUMBER          := 0;
  l_run_acctd_amt        NUMBER          := 0;
  l_run_acctd_alloc      NUMBER          := 0;
  l_alloc                NUMBER          := 0;
  l_acctd_alloc          NUMBER          := 0;

  l_run_chrg_amt         NUMBER          := 0;
  l_run_chrg_alloc       NUMBER          := 0;
  l_run_chrg_acctd_amt   NUMBER          := 0;
  l_run_chrg_acctd_alloc NUMBER          := 0;
  l_chrg_alloc           NUMBER          := 0;
  l_chrg_acctd_alloc     NUMBER          := 0;

  l_run_frt_amt         NUMBER          := 0;
  l_run_frt_alloc       NUMBER          := 0;
  l_run_frt_acctd_amt   NUMBER          := 0;
  l_run_frt_acctd_alloc NUMBER          := 0;
  l_frt_alloc           NUMBER          := 0;
  l_frt_acctd_alloc     NUMBER          := 0;

  l_run_tax_amt         NUMBER          := 0;
  l_run_tax_alloc       NUMBER          := 0;
  l_run_tax_acctd_amt   NUMBER          := 0;
  l_run_tax_acctd_alloc NUMBER          := 0;
  l_tax_alloc           NUMBER          := 0;
  l_tax_acctd_alloc     NUMBER          := 0;


  -- ED
  l_run_ed_amt              NUMBER          := 0;
  l_run_ed_alloc            NUMBER          := 0;
  l_run_ed_acctd_amt        NUMBER          := 0;
  l_run_ed_acctd_alloc      NUMBER          := 0;
  l_ed_alloc                NUMBER          := 0;
  l_ed_acctd_alloc          NUMBER          := 0;

  l_run_ed_chrg_amt         NUMBER          := 0;
  l_run_ed_chrg_alloc       NUMBER          := 0;
  l_run_ed_chrg_acctd_amt   NUMBER          := 0;
  l_run_ed_chrg_acctd_alloc NUMBER          := 0;
  l_ed_chrg_alloc           NUMBER          := 0;
  l_ed_chrg_acctd_alloc     NUMBER          := 0;

  l_run_ed_frt_amt         NUMBER          := 0;
  l_run_ed_frt_alloc       NUMBER          := 0;
  l_run_ed_frt_acctd_amt   NUMBER          := 0;
  l_run_ed_frt_acctd_alloc NUMBER          := 0;
  l_ed_frt_alloc           NUMBER          := 0;
  l_ed_frt_acctd_alloc     NUMBER          := 0;

  l_run_ed_tax_amt         NUMBER          := 0;
  l_run_ed_tax_alloc       NUMBER          := 0;
  l_run_ed_tax_acctd_amt   NUMBER          := 0;
  l_run_ed_tax_acctd_alloc NUMBER          := 0;
  l_ed_tax_alloc           NUMBER          := 0;
  l_ed_tax_acctd_alloc     NUMBER          := 0;

  -- UNED
  l_run_uned_amt              NUMBER          := 0;
  l_run_uned_alloc            NUMBER          := 0;
  l_run_uned_acctd_amt        NUMBER          := 0;
  l_run_uned_acctd_alloc      NUMBER          := 0;
  l_uned_alloc                NUMBER          := 0;
  l_uned_acctd_alloc          NUMBER          := 0;

  l_run_uned_chrg_amt         NUMBER          := 0;
  l_run_uned_chrg_alloc       NUMBER          := 0;
  l_run_uned_chrg_acctd_amt   NUMBER          := 0;
  l_run_uned_chrg_acctd_alloc NUMBER          := 0;
  l_uned_chrg_alloc           NUMBER          := 0;
  l_uned_chrg_acctd_alloc     NUMBER          := 0;

  l_run_uned_frt_amt         NUMBER          := 0;
  l_run_uned_frt_alloc       NUMBER          := 0;
  l_run_uned_frt_acctd_amt   NUMBER          := 0;
  l_run_uned_frt_acctd_alloc NUMBER          := 0;
  l_uned_frt_alloc           NUMBER          := 0;
  l_uned_frt_acctd_alloc     NUMBER          := 0;

  l_run_uned_tax_amt         NUMBER          := 0;
  l_run_uned_tax_alloc       NUMBER          := 0;
  l_run_uned_tax_acctd_amt   NUMBER          := 0;
  l_run_uned_tax_acctd_alloc NUMBER          := 0;
  l_uned_tax_alloc           NUMBER          := 0;
  l_uned_tax_acctd_alloc     NUMBER          := 0;

  l_exist                BOOLEAN;
  l_last_fetch           BOOLEAN;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_line()+');
  END IF;

  OPEN  c_read_for_line;
  LOOP
    FETCH c_read_for_line BULK COLLECT INTO
     l_tab.GROUPE                  ,
   -- ADJ and APP
     -- Base
     l_tab.base_pro_amt       ,
     l_tab.base_pro_acctd_amt ,
     l_tab.BASE_FRT_PRO_AMT       ,
     l_tab.BASE_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_tax_PRO_AMT       ,
     l_tab.BASE_tax_PRO_ACCTD_AMT ,
     l_tab.BASE_CHRG_PRO_AMT       ,
     l_tab.BASE_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_pro_amt       ,
     l_tab.elmt_pro_acctd_amt ,
     l_tab.ELMT_FRT_PRO_AMT       ,
     l_tab.ELMT_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_tax_PRO_AMT       ,
     l_tab.ELMT_tax_PRO_ACCTD_AMT ,
     l_tab.ELMT_CHRG_PRO_AMT       ,
     l_tab.ELMT_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_alloc_amt      ,
     l_tab.buc_alloc_acctd_amt,
     l_tab.buc_frt_alloc_amt      ,
     l_tab.buc_frt_alloc_acctd_amt,
     l_tab.buc_tax_alloc_amt      ,
     l_tab.buc_tax_alloc_acctd_amt,
     l_tab.buc_chrg_alloc_amt      ,
     l_tab.buc_chrg_alloc_acctd_amt,
   -- ED
     -- Base
     l_tab.base_ed_pro_amt       ,
     l_tab.base_ed_pro_acctd_amt ,
     l_tab.BASE_ed_FRT_PRO_AMT       ,
     l_tab.BASE_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_tax_PRO_AMT       ,
     l_tab.BASE_ed_tax_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_CHRG_PRO_AMT       ,
     l_tab.BASE_ed_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_ed_pro_amt       ,
     l_tab.elmt_ed_pro_acctd_amt ,
     l_tab.ELMT_ed_FRT_PRO_AMT       ,
     l_tab.ELMT_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_tax_PRO_AMT       ,
     l_tab.ELMT_ed_tax_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_CHRG_PRO_AMT       ,
     l_tab.ELMT_ed_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_ed_alloc_amt      ,
     l_tab.buc_ed_alloc_acctd_amt,
     l_tab.buc_ed_frt_alloc_amt      ,
     l_tab.buc_ed_frt_alloc_acctd_amt,
     l_tab.buc_ed_tax_alloc_amt      ,
     l_tab.buc_ed_tax_alloc_acctd_amt,
     l_tab.buc_ed_chrg_alloc_amt      ,
     l_tab.buc_ed_chrg_alloc_acctd_amt,
   -- UNED
     -- Base
     l_tab.base_uned_pro_amt       ,
     l_tab.base_uned_pro_acctd_amt ,
     l_tab.BASE_uned_FRT_PRO_AMT       ,
     l_tab.BASE_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_tax_PRO_AMT       ,
     l_tab.BASE_uned_tax_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_CHRG_PRO_AMT       ,
     l_tab.BASE_uned_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_uned_pro_amt       ,
     l_tab.elmt_uned_pro_acctd_amt ,
     l_tab.ELMT_uned_FRT_PRO_AMT       ,
     l_tab.ELMT_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_tax_PRO_AMT       ,
     l_tab.ELMT_uned_tax_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_CHRG_PRO_AMT       ,
     l_tab.ELMT_uned_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_uned_alloc_amt      ,
     l_tab.buc_uned_alloc_acctd_amt,
     l_tab.buc_uned_frt_alloc_amt      ,
     l_tab.buc_uned_frt_alloc_acctd_amt,
     l_tab.buc_uned_tax_alloc_amt      ,
     l_tab.buc_uned_tax_alloc_acctd_amt,
     l_tab.buc_uned_chrg_alloc_amt      ,
     l_tab.buc_uned_chrg_alloc_acctd_amt,
     --
     l_tab.BASE_CURRENCY  ,
     l_tab.TO_CURRENCY    ,
     l_tab.FROM_CURRENCY  ,
     --
     l_tab.ROWID_ID     LIMIT g_bulk_fetch_rows;

     IF c_read_for_line%NOTFOUND THEN
          l_last_fetch := TRUE;
     END IF;

     IF (l_tab.ROWID_ID.COUNT = 0) AND (l_last_fetch) THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug('COUNT = 0 and LAST FETCH ');
       END IF;
       EXIT;
     END IF;

     plsql_proration( x_tab               => l_tab,
                   x_group_tbl            => l_group_tbl,
                   p_group_level          => 'L',
		   -- ADJ and APP
                   x_run_amt              => l_run_amt,
                   x_run_alloc            => l_run_alloc,
                   x_run_acctd_amt        => l_run_acctd_amt,
                   x_run_acctd_alloc      => l_run_acctd_alloc,
                   x_run_chrg_amt         => l_run_chrg_amt,
                   x_run_chrg_alloc       => l_run_chrg_alloc,
                   x_run_chrg_acctd_amt   => l_run_chrg_acctd_amt,
                   x_run_chrg_acctd_alloc => l_run_chrg_acctd_alloc,
                   x_run_frt_amt         => l_run_frt_amt,
                   x_run_frt_alloc       => l_run_frt_alloc,
                   x_run_frt_acctd_amt   => l_run_frt_acctd_amt,
                   x_run_frt_acctd_alloc => l_run_frt_acctd_alloc,
                   x_run_tax_amt         => l_run_tax_amt,
                   x_run_tax_alloc       => l_run_tax_alloc,
                   x_run_tax_acctd_amt   => l_run_tax_acctd_amt,
                   x_run_tax_acctd_alloc => l_run_tax_acctd_alloc,
                   -- ED
                   x_run_ed_amt              => l_run_ed_amt,
                   x_run_ed_alloc            => l_run_ed_alloc,
                   x_run_ed_acctd_amt        => l_run_ed_acctd_amt,
                   x_run_ed_acctd_alloc      => l_run_ed_acctd_alloc,
                   x_run_ed_chrg_amt         => l_run_ed_chrg_amt,
                   x_run_ed_chrg_alloc       => l_run_ed_chrg_alloc,
                   x_run_ed_chrg_acctd_amt   => l_run_ed_chrg_acctd_amt,
                   x_run_ed_chrg_acctd_alloc => l_run_ed_chrg_acctd_alloc,
                   x_run_ed_frt_amt         => l_run_ed_frt_amt,
                   x_run_ed_frt_alloc       => l_run_ed_frt_alloc,
                   x_run_ed_frt_acctd_amt   => l_run_ed_frt_acctd_amt,
                   x_run_ed_frt_acctd_alloc => l_run_ed_frt_acctd_alloc,
                   x_run_ed_tax_amt         => l_run_ed_tax_amt,
                   x_run_ed_tax_alloc       => l_run_ed_tax_alloc,
                   x_run_ed_tax_acctd_amt   => l_run_ed_tax_acctd_amt,
                   x_run_ed_tax_acctd_alloc => l_run_ed_tax_acctd_alloc,
                   -- UNED
                   x_run_uned_amt              => l_run_uned_amt,
                   x_run_uned_alloc            => l_run_uned_alloc,
                   x_run_uned_acctd_amt        => l_run_uned_acctd_amt,
                   x_run_uned_acctd_alloc      => l_run_uned_acctd_alloc,
                   x_run_uned_chrg_amt         => l_run_uned_chrg_amt,
                   x_run_uned_chrg_alloc       => l_run_uned_chrg_alloc,
                   x_run_uned_chrg_acctd_amt   => l_run_uned_chrg_acctd_amt,
                   x_run_uned_chrg_acctd_alloc => l_run_uned_chrg_acctd_alloc,
                   x_run_uned_frt_amt         => l_run_uned_frt_amt,
                   x_run_uned_frt_alloc       => l_run_uned_frt_alloc,
                   x_run_uned_frt_acctd_amt   => l_run_uned_frt_acctd_amt,
                   x_run_uned_frt_acctd_alloc => l_run_uned_frt_acctd_alloc,
                   x_run_uned_tax_amt         => l_run_uned_tax_amt,
                   x_run_uned_tax_alloc       => l_run_uned_tax_alloc,
                   x_run_uned_tax_acctd_amt   => l_run_uned_tax_acctd_amt,
                   x_run_uned_tax_acctd_alloc => l_run_uned_tax_acctd_alloc
                   );

    IF PG_DEBUG = 'Y' THEN
    localdebug('     update ra_ar_gt trx_line_all ');
    END IF;
    FORALL i IN l_tab.ROWID_ID.FIRST .. l_tab.ROWID_ID.LAST
      UPDATE ra_ar_gt
      SET
          -- ADJ and APP
           tl_alloc_amt         = l_tab.tl_alloc_amt(i),
           tl_alloc_acctd_amt   = l_tab.tl_alloc_acctd_amt(i),
           tl_chrg_alloc_amt    = l_tab.tl_chrg_alloc_amt(i),
           tl_chrg_alloc_acctd_amt = l_tab.tl_chrg_alloc_acctd_amt(i),
           tl_frt_alloc_amt       = l_tab.tl_frt_alloc_amt(i),
           tl_frt_alloc_acctd_amt = l_tab.tl_frt_alloc_acctd_amt(i),
           tl_tax_alloc_amt       = l_tab.tl_tax_alloc_amt(i),
           tl_tax_alloc_acctd_amt = l_tab.tl_tax_alloc_acctd_amt(i),
          -- ED
           tl_ed_alloc_amt         = l_tab.tl_ed_alloc_amt(i),
           tl_ed_alloc_acctd_amt   = l_tab.tl_ed_alloc_acctd_amt(i),
           tl_ed_chrg_alloc_amt    = l_tab.tl_ed_chrg_alloc_amt(i),
           tl_ed_chrg_alloc_acctd_amt = l_tab.tl_ed_chrg_alloc_acctd_amt(i),
           tl_ed_frt_alloc_amt       = l_tab.tl_ed_frt_alloc_amt(i),
           tl_ed_frt_alloc_acctd_amt = l_tab.tl_ed_frt_alloc_acctd_amt(i),
           tl_ed_tax_alloc_amt       = l_tab.tl_ed_tax_alloc_amt(i),
           tl_ed_tax_alloc_acctd_amt = l_tab.tl_ed_tax_alloc_acctd_amt(i),
          -- UNED
           tl_uned_alloc_amt         = l_tab.tl_uned_alloc_amt(i),
           tl_uned_alloc_acctd_amt   = l_tab.tl_uned_alloc_acctd_amt(i),
           tl_uned_chrg_alloc_amt    = l_tab.tl_uned_chrg_alloc_amt(i),
           tl_uned_chrg_alloc_acctd_amt = l_tab.tl_uned_chrg_alloc_acctd_amt(i),
           tl_uned_frt_alloc_amt       = l_tab.tl_uned_frt_alloc_amt(i),
           tl_uned_frt_alloc_acctd_amt = l_tab.tl_uned_frt_alloc_acctd_amt(i),
           tl_uned_tax_alloc_amt       = l_tab.tl_uned_tax_alloc_amt(i),
           tl_uned_tax_alloc_acctd_amt = l_tab.tl_uned_tax_alloc_acctd_amt(i)
      WHERE rowid                     = l_tab.ROWID_ID(i);
    IF PG_DEBUG = 'Y' THEN
    localdebug('     update ra_ar_gt trx_line_all ');
    END IF;

  END LOOP;
  CLOSE c_read_for_line;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_line()-');
  END IF;
END update_line;


PROCEDURE get_invoice_line_info
  (p_gt_id                IN VARCHAR2,
   p_customer_trx_id      IN NUMBER,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type,
   p_mode                 IN VARCHAR2)
IS

  l_rows NUMBER;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_invoice_line_info()+');
  localdebug('   p_mode            :'||p_mode);
  localdebug('   p_customer_trx_id :'||p_customer_trx_id);
  localdebug('   sob_type          :'||p_ae_sys_rec.sob_type);
  localdebug('   set_of_books_id   :'||p_ae_sys_rec.set_of_books_id);
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('   for regular transaction');
  END IF;
      INSERT INTO RA_AR_GT
      ( GT_ID                     ,
        BASE_CURRENCY             ,
        TO_CURRENCY               ,
        REF_CUSTOMER_TRX_ID       ,
        REF_CUSTOMER_TRX_LINE_ID  ,
        --
        DUE_ORIG_AMT              ,
        DUE_ORIG_ACCTD_AMT        ,
--{line of type CHRG
        CHRG_ORIG_AMT             ,
        CHRG_ORIG_ACCTD_AMT       ,
--}
        --
        FRT_ORIG_AMT              ,
        FRT_ORIG_ACCTD_AMT        ,
        TAX_ORIG_AMT              ,
        TAX_ORIG_ACCTD_AMT        ,
        --
        DUE_REM_AMT               ,
        DUE_REM_ACCTD_AMT         ,
        CHRG_REM_AMT              ,
        CHRG_REM_ACCTD_AMT        ,
        --
          FRT_REM_AMT               ,
          FRT_REM_ACCTD_AMT         ,
          TAX_REM_AMT               ,
          TAX_REM_ACCTD_AMT         ,
          --
--{line of type CHRG
          CHRG_ADJ_REM_AMT        ,
          CHRG_ADJ_REM_ACCTD_AMT  ,
--}
          FRT_ADJ_REM_AMT           ,
          FRT_ADJ_REM_ACCTD_AMT     ,
        --
        LINE_TYPE                 ,
        group_id                  ,
        --{HYUBPAGP
        source_data_key1  ,
        source_data_key2  ,
        source_data_key3  ,
        source_data_key4  ,
        source_data_key5  ,
        --}
        --
        SUM_LINE_ORIG_AMT        ,
        SUM_LINE_ORIG_ACCTD_AMT  ,
--{line of type CHRG
        SUM_LINE_CHRG_ORIG_AMT        ,
        SUM_LINE_CHRG_ORIG_ACCTD_AMT  ,
--}
        SUM_LINE_FRT_ORIG_AMT        ,
        SUM_LINE_FRT_ORIG_ACCTD_AMT  ,
        SUM_LINE_TAX_ORIG_AMT        ,
        SUM_LINE_TAX_ORIG_ACCTD_AMT  ,
        --
        SUM_LINE_REM_AMT         ,
        SUM_LINE_REM_ACCTD_AMT   ,
        SUM_LINE_CHRG_REM_AMT    ,
        SUM_LINE_CHRG_REM_ACCTD_AMT,
        --
          SUM_LINE_FRT_REM_AMT        ,
          SUM_LINE_FRT_REM_ACCTD_AMT  ,
          SUM_LINE_TAX_REM_AMT        ,
          SUM_LINE_TAX_REM_ACCTD_AMT  ,
        --
        gp_level,
        --3611016
        set_of_books_id,
        sob_type,
--        se_gt_id,
        tax_link_id,
        tax_inc_flag
--{BUG#4415037
 ,INT_LINE_AMOUNT
 ,INT_TAX_AMOUNT
 ,INT_ED_LINE_AMOUNT
 ,INT_ED_TAX_AMOUNT
 ,INT_UNED_LINE_AMOUNT
 ,INT_UNED_TAX_AMOUNT
 ,SUM_INT_LINE_AMOUNT
 ,SUM_INT_TAX_AMOUNT
 ,SUM_INT_ED_LINE_AMOUNT
 ,SUM_INT_ED_TAX_AMOUNT
 ,SUM_INT_UNED_LINE_AMOUNT
 ,SUM_INT_UNED_TAX_AMOUNT
--}
        )
     SELECT  /*+INDEX (ctl ra_customer_trx_lines_gt_n1)*/
	        p_gt_id                       ,  --GT_ID
            p_ae_sys_rec.base_currency    ,  --BASE_CURRENCY
            trx.invoice_currency_code     ,  --TO_CURRENCY
            trx.customer_trx_id           ,  --REF_CUSTOMER_TRX_ID
            ctl.customer_trx_line_id      ,  --REF_CUSTOMER_TRX_LINE_ID
         -- Orig
            DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                 'CB'  ,ctl.amount_due_original, 0),          --DUE_ORIG_AMT
            DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                 'CB'  ,ctl.acctd_amount_due_original,0),    --DUE_ORIG_ACCTD_AMT
--{line of type CHRG
           DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0),        --CHRG_ORIG_AMT
           DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0),  --CHRG_ORIG_ACCTD_AMT
--}
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0),       --FRT_ORIG_AMT
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0), --FRT_ORIG_ACCTD_AMT
            DECODE(ctl.line_type,'TAX',ctl.amount_due_original, 0),          --TAX_ORIG_AMT
            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0),     --TAX_ORIG_ACCTD_AMT
         -- Remaining
            CASE WHEN SUM(DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                     'CB'  ,ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN
            DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                 'CB'  ,ctl.amount_due_original,0)
            ELSE
            DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                 'CB'  ,ctl.amount_due_remaining, 0) END,         --DUE_REM_AMT
            CASE WHEN SUM(DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_remaining,
                                     'CB'  ,ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN
            DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                 'CB'  ,ctl.acctd_amount_due_original,0)
            ELSE
            DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_remaining,
                                 'CB'  ,ctl.acctd_amount_due_remaining,0) END,   --DUE_REM_ACCTD_AMT
--{line of type CHRG
           CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_amount_remaining,0),
                                'CHARGES',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
           THEN
           DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0)
           ELSE
           DECODE(ctl.line_type,'CHARGES',ctl.amount_due_remaining,0) END,        --CHRG_REM_AMT
           CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CHARGES',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
           THEN
           DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0)
           ELSE
           DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_remaining,0) END,  --CHRG_REM_ACCTD_AMT
           -- NVL(ctl.chrg_amount_remaining,0)     ,                                  --CHRG_REM_AMT
           -- NVL(ctl.chrg_acctd_amount_remaining,0),                                 --CHRG_REM_ACCTD_AMT
--}
            --
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_remaining,0),
                                'FREIGHT',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0)
            ELSE
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_remaining,0) END,      --FRT_REM_AMT
                                                            /*Frt Rem on freight is the
                                                              rem amount of the freight calculated
                                                              from orig frt - cash application
                                                              frt adjustment variations are excluded
                                                              they are kept in frt_adj_rem_amt on rev line */
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'FREIGHT',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0)
            ELSE
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_remaining,0) END, --FRT_REM_ACCTD_AMT
            CASE WHEN SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN
            DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0)
            ELSE
            DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0) END,           --TAX_REM_AMT
            CASE WHEN SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN
            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0)
            ELSE
            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0) END,    --TAX_REM_ACCTD_AMT
--{line of type CHRG
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_amount_remaining,0),
                                'CHARGES',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN 0
            ELSE
            NVL(ctl.chrg_amount_remaining,0) END,                                       --CHRG_ADJ_REM_AMT
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CHARGES',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN 0
            ELSE
            NVL(ctl.chrg_acctd_amount_remaining,0) END,                                 --CHRG_ADJ_REM_ACCTD_AMT
--}
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_remaining,0),
                                'FREIGHT',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN 0
            ELSE
            NVL(ctl.frt_adj_remaining,0) END,                                            --FRT_ADJ_REM_AMT
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'FREIGHT',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN 0
            ELSE
            NVL(ctl.frt_adj_acctd_remaining,0) END,                                      --FRT_ADJ_REM_ACCTD_AMT
            --
            ctl.line_type                 ,                                  --LINE_TYPE
            --{HYU Group Id issue
--{
/*
            DECODE(ctl.SOURCE_DATA_KEY1 ||
                   ctl.SOURCE_DATA_KEY2 ||
                   ctl.SOURCE_DATA_KEY3 ||
                   ctl.SOURCE_DATA_KEY4 ||
                   ctl.SOURCE_DATA_KEY5, NULL, '00',
                     ctl.SOURCE_DATA_KEY1 ||'-'||
                     ctl.SOURCE_DATA_KEY2 ||'-'||
                     ctl.SOURCE_DATA_KEY3 ||'-'||
                     ctl.SOURCE_DATA_KEY4 ||'-'||
                     ctl.SOURCE_DATA_KEY5),                                    --GROUP_ID
*/
            '00-00-00-00-00',                                    --GROUP_ID
--}
            --NVL(ctl.SOURCE_DATA_KEY1,'00'),                                  --GROUP_ID
            --}
            --{HYUBPAGP
--{
/*
            NVL(ctl.source_data_key1,'00')  ,
            NVL(ctl.source_data_key2,'00')  ,
            NVL(ctl.source_data_key3,'00')  ,
            NVL(ctl.source_data_key4,'00')  ,
            NVL(ctl.source_data_key5,'00')  ,
*/
            '00'  ,
            '00'  ,
            '00'  ,
            '00'  ,
            '00'  ,
--}
            --}
            --
            SUM(DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                     'CB'  ,ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_ORIG_AMT
            SUM(DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                     'CB'  ,ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_ORIG_ACCTD_AMT
            --
--{HYUCHRG
            SUM(DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_ORIG_AMT
            SUM(DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_ORIG_ACCTD_AMT
--}
            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_FRT_ORIG_AMT
            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_FRT_ORIG_ACCTD_AMT
            --
            SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_ORIG_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_ORIG_ACCTD_AMT
            --
            CASE WHEN SUM(DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                     'CB'  ,ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN SUM(DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                     'CB'  ,ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE
            SUM(DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                     'CB'  ,ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) END,     --SUM_LINE_REM_AMT
            CASE WHEN SUM(DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_remaining,
                                     'CB'  ,ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN SUM(DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                     'CB'  ,ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE
            SUM(DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_remaining,
                                     'CB'  ,ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) END,     --SUM_LINE_REM_ACCTD_AMT

--{HYUCHRG
--            SUM(NVL(ctl.chrg_amount_remaining,0))
--                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_REM_AMT
--            SUM(NVL(ctl.chrg_acctd_amount_remaining,0))
--                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_REM_ACCTD_AMT
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_amount_remaining,0),
                                'CHARGES',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN SUM(DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE
            SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_amount_remaining,0),
                                'CHARGES',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) END,--SUM_LINE_CHRG_REM_AMT
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CHARGES',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN SUM(DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CHARGES',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) END,--SUM_LINE_CHRG_REM_ACCTD_AMT
--}
            --
            /*This is the sum of freight amount adjusted on the revenue line
              + sum of freight amount due remaining on the original freight line
              Those 2 amounts combined form the basis for cash receipt apps */
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_remaining,0),
                                'FREIGHT',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN SUM(DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_remaining,0),
                                'FREIGHT',NVL(ctl.amount_due_remaining,0),   /*HYU*/
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) END,--SUM_LINE_FRT_REM_AMT
            CASE WHEN SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'FREIGHT',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) = 0
            THEN SUM(DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'FREIGHT',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id  ) END,--SUM_LINE_FRT_REM_ACCTD_AMT
            --
            CASE WHEN SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) END,       --SUM_LINE_TAX_REM_AMT
            CASE WHEN SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) = 0
            THEN SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type )
            ELSE SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ) END,       --SUM_LINE_TAX_REM_ACCTD_AMT
            --
            'L',
            --Bug#3611016
            p_ae_sys_rec.set_of_books_id,
            p_ae_sys_rec.sob_type,
--            g_se_gt_id,
            --{Taxable_amount
            DECODE(ctl.line_type, 'TAX' ,ctl.link_to_cust_trx_line_id,
                                  'LINE',ctl.customer_trx_line_id,
                                  'CB'  ,ctl.customer_trx_line_id,
                                  NULL),
            DECODE(ctl.line_type,'LINE','Y',
                                 'CB'  ,'Y',
                                 'TAX','Y','N')
--{BUG#4415037
           ,CASE WHEN g_line_flag      = 'INTERFACE' THEN it.line_amount          ELSE NULL END  -- INT_LINE_AMOUNT
           ,CASE WHEN g_tax_flag       = 'INTERFACE' THEN it.tax_amount           ELSE NULL END  -- INT_TAX_AMOUNT
           ,CASE WHEN g_ed_line_flag   = 'INTERFACE' THEN it.ed_line_amount       ELSE NULL END  -- INT_ED_LINE_AMOUNT
           ,CASE WHEN g_ed_tax_flag    = 'INTERFACE' THEN it.ed_tax_amount        ELSE NULL END  -- INT_ED_TAX_AMOUNT
           ,CASE WHEN g_uned_line_flag = 'INTERFACE' THEN it.uned_line_amount     ELSE NULL END  -- INT_UNED_LINE_AMOUNT
           ,CASE WHEN g_uned_tax_flag  = 'INTERFACE' THEN it.uned_tax_amount     ELSE NULL END  -- INT_UNED_TAX_AMOUNT >> BUG 5736570
           ,CASE WHEN g_line_flag      = 'INTERFACE' THEN it.sum_line_amount      ELSE NULL END  -- SUM_INT_LINE_AMOUNT
           ,CASE WHEN g_tax_flag       = 'INTERFACE' THEN it.sum_tax_amount       ELSE NULL END  -- SUM_INT_TAX_AMOUNT
           ,CASE WHEN g_ed_line_flag   = 'INTERFACE' THEN it.sum_ed_line_amount   ELSE NULL END  -- SUM_INT_ED_LINE_AMOUNT
           ,CASE WHEN g_ed_tax_flag    = 'INTERFACE' THEN it.sum_ed_tax_amount    ELSE NULL END  -- SUM_INT_ED_TAX_AMOUNT
           ,CASE WHEN g_uned_line_flag = 'INTERFACE' THEN it.sum_uned_line_amount ELSE NULL END  -- SUM_INT_UNED_LINE_AMOUNT
           ,CASE WHEN g_uned_tax_flag  = 'INTERFACE' THEN it.sum_uned_tax_amount  ELSE NULL END  -- SUM_INT_UNED_TAX_AMOUNT
--}
       FROM ra_customer_trx          trx,
            ra_customer_trx_lines_gt ctl,
            (SELECT
			         gt_id                   gt_id
                    ,customer_trx_id         customer_trx_id
                    ,customer_trx_line_id    customer_trx_line_id
                    ,line_type               line_type
                    ,NVL(line_amount,0)      line_amount
                    ,NVL(tax_amount,0)       tax_amount
                    ,NVL(ed_line_amount,0)   ed_line_amount
                    ,NVL(ed_tax_amount,0)    ed_tax_amount
                    ,NVL(uned_line_amount,0) uned_line_amount
                    ,NVL(uned_tax_amount,0)  uned_tax_amount
                    ,SUM(NVL(line_amount,0)) OVER (PARTITION BY gt_id, customer_trx_id)      sum_line_amount
                    ,SUM(NVL(tax_amount,0))  OVER (PARTITION BY gt_id, customer_trx_id)      sum_tax_amount
                    ,SUM(NVL(ed_line_amount,0)) OVER (PARTITION BY gt_id, customer_trx_id)   sum_ed_line_amount
                    ,SUM(NVL(ed_tax_amount,0))  OVER (PARTITION BY gt_id, customer_trx_id)   sum_ed_tax_amount
                    ,SUM(NVL(uned_line_amount,0)) OVER (PARTITION BY gt_id, customer_trx_id) sum_uned_line_amount
                    ,SUM(NVL(uned_tax_amount,0))  OVER (PARTITION BY gt_id, customer_trx_id) sum_uned_tax_amount
               FROM
                (SELECT /*+INDEX (ar_line_dist_interface_gt ar_line_dist_interface_gt_n1)*/
                     gt_id                   gt_id
                    ,customer_trx_id         customer_trx_id
                    ,customer_trx_line_id    customer_trx_line_id
                    ,line_type               line_type
                    ,MAX(NVL(line_amount,0))      line_amount
                    ,MAX(NVL(tax_amount,0))       tax_amount
                    ,SUM(NVL(ed_line_amount,0))   ed_line_amount
                    ,SUM(NVL(ed_tax_amount,0))    ed_tax_amount
                    ,SUM(NVL(uned_line_amount,0)) uned_line_amount
                    ,SUM(NVL(uned_tax_amount,0))  uned_tax_amount
                 FROM ar_line_dist_interface_gt
              WHERE gt_id = p_gt_id
                AND customer_trx_id = p_customer_trx_id
                GROUP BY gt_id, customer_trx_id, customer_trx_line_id, line_type))    it
      WHERE trx.customer_trx_id  = p_customer_trx_id
        AND trx.customer_trx_id  = ctl.customer_trx_id
        AND ctl.customer_trx_line_id  = it.customer_trx_line_id (+);

  l_rows := sql%rowcount;
  g_appln_count := g_appln_count + l_rows;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  rows inserted = ' || l_rows);
  END IF;

  IF PG_DEBUG = 'Y' THEN
  display_ra_ar_gt(p_gt_id => p_gt_id);
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_invoice_line_info()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug('EXCEPTION get_invoice_line_info OTHERS :'||SQLERRM);
     END IF;
END get_invoice_line_info;


PROCEDURE get_invoice_line_info_cm
  (p_gt_id                IN VARCHAR2,
   p_customer_trx_id      IN NUMBER,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type,
   p_mode                 IN VARCHAR2)
IS

  l_rows NUMBER;

BEGIN
  localdebug('arp_det_dist_pkg.get_invoice_line_info_cm()+');
  localdebug('   p_mode            :'||p_mode);
  localdebug('   p_customer_trx_id :'||p_customer_trx_id);
  localdebug('   sob_type          :'||p_ae_sys_rec.sob_type);
  localdebug('   set_of_books_id   :'||p_ae_sys_rec.set_of_books_id);

  localdebug('   for regular transaction against cm');
      INSERT INTO RA_AR_GT
      ( GT_ID                     ,
        BASE_CURRENCY             ,
        TO_CURRENCY               ,
        REF_CUSTOMER_TRX_ID       ,
        REF_CUSTOMER_TRX_LINE_ID  ,
        --
        DUE_ORIG_AMT              ,
        DUE_ORIG_ACCTD_AMT        ,

        CHRG_ORIG_AMT             ,
        CHRG_ORIG_ACCTD_AMT       ,

        --
        FRT_ORIG_AMT              ,
        FRT_ORIG_ACCTD_AMT        ,
        TAX_ORIG_AMT              ,
        TAX_ORIG_ACCTD_AMT        ,
        --
        DUE_REM_AMT               ,
        DUE_REM_ACCTD_AMT         ,
        CHRG_REM_AMT              ,
        CHRG_REM_ACCTD_AMT        ,
        --
          FRT_REM_AMT               ,
          FRT_REM_ACCTD_AMT         ,
          TAX_REM_AMT               ,
          TAX_REM_ACCTD_AMT         ,
          --

          CHRG_ADJ_REM_AMT        ,
          CHRG_ADJ_REM_ACCTD_AMT  ,

          FRT_ADJ_REM_AMT           ,
          FRT_ADJ_REM_ACCTD_AMT     ,
        --
        LINE_TYPE                 ,
        group_id                  ,

        source_data_key1  ,
        source_data_key2  ,
        source_data_key3  ,
        source_data_key4  ,
        source_data_key5  ,

        --
        SUM_LINE_ORIG_AMT        ,
        SUM_LINE_ORIG_ACCTD_AMT  ,

        SUM_LINE_CHRG_ORIG_AMT        ,
        SUM_LINE_CHRG_ORIG_ACCTD_AMT  ,

        SUM_LINE_FRT_ORIG_AMT        ,
        SUM_LINE_FRT_ORIG_ACCTD_AMT  ,
        SUM_LINE_TAX_ORIG_AMT        ,
        SUM_LINE_TAX_ORIG_ACCTD_AMT  ,
        --
        SUM_LINE_REM_AMT         ,
        SUM_LINE_REM_ACCTD_AMT   ,
        SUM_LINE_CHRG_REM_AMT    ,
        SUM_LINE_CHRG_REM_ACCTD_AMT,
        --
          SUM_LINE_FRT_REM_AMT        ,
          SUM_LINE_FRT_REM_ACCTD_AMT  ,
          SUM_LINE_TAX_REM_AMT        ,
          SUM_LINE_TAX_REM_ACCTD_AMT  ,
        --
        gp_level,
        set_of_books_id,
        sob_type,
        tax_link_id,
        tax_inc_flag
        )
     SELECT  /*+INDEX (ctl ra_customer_trx_lines_gt_n1)*/
            p_gt_id                       ,  --GT_ID
            p_ae_sys_rec.base_currency    ,  --BASE_CURRENCY
            trx.invoice_currency_code     ,  --TO_CURRENCY
            trx.customer_trx_id           ,  --REF_CUSTOMER_TRX_ID
            ctl.customer_trx_line_id      ,  --REF_CUSTOMER_TRX_LINE_ID
         -- Orig
            DECODE(ctl.line_type,'LINE',ctl.cm_amt_due_orig,
                                 'CB'  ,ctl.cm_amt_due_orig, 0),          --DUE_ORIG_AMT
            DECODE(ctl.line_type,'LINE',ctl.cm_acctd_amt_due_orig,
                                 'CB'  ,ctl.cm_acctd_amt_due_orig,0),    --DUE_ORIG_ACCTD_AMT

           DECODE(ctl.line_type,'CHARGES',ctl.cm_amt_due_orig,0),        --CHRG_ORIG_AMT
           DECODE(ctl.line_type,'CHARGES',ctl.cm_acctd_amt_due_orig,0),  --CHRG_ORIG_ACCTD_AMT

            DECODE(ctl.line_type,'FREIGHT',ctl.cm_amt_due_orig,0),       --FRT_ORIG_AMT
            DECODE(ctl.line_type,'FREIGHT',ctl.cm_acctd_amt_due_orig,0), --FRT_ORIG_ACCTD_AMT
            DECODE(ctl.line_type,'TAX',ctl.cm_amt_due_orig, 0),          --TAX_ORIG_AMT
            DECODE(ctl.line_type,'TAX',ctl.cm_acctd_amt_due_orig,0),     --TAX_ORIG_ACCTD_AMT
         -- Remaining
            DECODE(ctl.line_type,'LINE',ctl.cm_amt_due_rem,
                                 'CB'  ,ctl.cm_amt_due_rem,0),         --DUE_REM_AMT
            DECODE(ctl.line_type,'LINE',ctl.cm_acctd_amt_due_rem,
                                 'CB'  ,ctl.cm_acctd_amt_due_rem,0),   --DUE_REM_ACCTD_AMT

           DECODE(ctl.line_type,'CHARGES',ctl.cm_amt_due_rem,0),        --CHRG_REM_AMT
           DECODE(ctl.line_type,'CHARGES',ctl.cm_acctd_amt_due_rem,0),  --CHRG_REM_ACCTD_AMT

            --
            DECODE(ctl.line_type,'FREIGHT',ctl.cm_amt_due_rem,0),      --FRT_REM_AMT
            DECODE(ctl.line_type,'FREIGHT',ctl.cm_acctd_amt_due_rem,0), --FRT_REM_ACCTD_AMT
            DECODE(ctl.line_type,'TAX',ctl.cm_amt_due_rem,0),           --TAX_REM_AMT
            DECODE(ctl.line_type,'TAX',ctl.cm_acctd_amt_due_rem,0) ,    --TAX_REM_ACCTD_AMT

            0,                                       --CHRG_ADJ_REM_AMT
            0,                                 --CHRG_ADJ_REM_ACCTD_AMT

            0,                                            --FRT_ADJ_REM_AMT
            0,                                      --FRT_ADJ_REM_ACCTD_AMT
            --
            ctl.line_type                 ,                                  --LINE_TYPE

            '00-00-00-00-00',                                    --GROUP_ID
            '00'  ,
            '00'  ,
            '00'  ,
            '00'  ,
            '00'  ,
            --
            SUM(DECODE(ctl.line_type,'LINE',ctl.cm_amt_due_orig,
                                     'CB'  ,ctl.cm_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_ORIG_AMT
            SUM(DECODE(ctl.line_type,'LINE',ctl.cm_acctd_amt_due_orig,
                                     'CB'  ,ctl.cm_acctd_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_ORIG_ACCTD_AMT
            --

            SUM(DECODE(ctl.line_type,'CHARGES',ctl.cm_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_ORIG_AMT
            SUM(DECODE(ctl.line_type,'CHARGES',ctl.cm_acctd_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_ORIG_ACCTD_AMT

            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.cm_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_FRT_ORIG_AMT
            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.cm_acctd_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_FRT_ORIG_ACCTD_AMT
            --
            SUM(DECODE(ctl.line_type,'TAX',ctl.cm_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_ORIG_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.cm_acctd_amt_due_orig,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_ORIG_ACCTD_AMT
            --
            SUM(DECODE(ctl.line_type,'LINE',ctl.cm_amt_due_rem,
                                     'CB'  ,ctl.cm_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ),     --SUM_LINE_REM_AMT
            SUM(DECODE(ctl.line_type,'LINE',ctl.cm_acctd_amt_due_rem,
                                     'CB'  ,ctl.cm_acctd_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ),     --SUM_LINE_REM_ACCTD_AMT

            SUM(DECODE(ctl.line_type,'CHARGES',ctl.cm_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_REM_AMT
            SUM(DECODE(ctl.line_type,'CHARGES',ctl.cm_acctd_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_CHRG_REM_ACCTD_AMT
            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.cm_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_FRT_REM_AMT
            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.cm_acctd_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_FRT_REM_ACCTD_AMT
            --
            SUM(DECODE(ctl.line_type,'TAX',ctl.cm_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ),       --SUM_LINE_TAX_REM_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.cm_acctd_amt_due_rem,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type  ),       --SUM_LINE_TAX_REM_ACCTD_AMT
            --
            'L',
            p_ae_sys_rec.set_of_books_id,
            p_ae_sys_rec.sob_type,
            --{Taxable_amount
            DECODE(ctl.line_type, 'TAX' ,ctl.link_to_cust_trx_line_id,
                                  'LINE',ctl.customer_trx_line_id,
                                  'CB'  ,ctl.customer_trx_line_id,
                                  NULL),
            DECODE(ctl.line_type,'LINE','Y',
                                 'CB'  ,'Y',
                                 'TAX','Y','N')
       FROM ra_customer_trx          trx,
            ra_customer_trx_lines_gt ctl
      WHERE trx.customer_trx_id  = p_customer_trx_id
        AND trx.customer_trx_id  = ctl.customer_trx_id
        AND ctl.cm_amt_due_orig is not null;

  l_rows := sql%rowcount;
  localdebug('  rows inserted = ' || l_rows);

  IF PG_DEBUG = 'Y' THEN
  display_ra_ar_gt(p_gt_id => p_gt_id);
  END IF;

  localdebug('arp_det_dist_pkg.get_invoice_line_info_cm()-');
EXCEPTION
  WHEN OTHERS THEN
     localdebug('EXCEPTION get_invoice_line_info_cm OTHERS :'||SQLERRM);
END get_invoice_line_info_cm;



PROCEDURE prepare_group_for_proration
  (p_gt_id            IN VARCHAR2,
   p_customer_trx_id  IN NUMBER,
   p_pay_adj          IN VARCHAR2,
   p_adj_rec          IN ar_adjustments%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type)
IS
  l_rows NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.prepare_group_for_proration()+');
  END IF;

  IF p_pay_adj = 'APP' THEN
      IF(p_app_rec.LINE_EDISCOUNTED IS NOT NULL    AND p_app_rec.LINE_EDISCOUNTED <> 0)    OR
        (p_app_rec.TAX_EDISCOUNTED  IS NOT NULL    AND p_app_rec.TAX_EDISCOUNTED <> 0)     OR
        (p_app_rec.FREIGHT_EDISCOUNTED IS NOT NULL AND p_app_rec.FREIGHT_EDISCOUNTED <> 0) OR
        (p_app_rec.CHARGES_EDISCOUNTED IS NOT NULL AND p_app_rec.CHARGES_EDISCOUNTED <> 0)
      THEN
         g_ed_req := 'Y';
      ELSE
         g_ed_req := 'N';
      END IF;
      IF(p_app_rec.LINE_UEDISCOUNTED IS NOT NULL AND p_app_rec.LINE_UEDISCOUNTED <> 0)    OR
        (p_app_rec.TAX_UEDISCOUNTED  IS NOT NULL    AND p_app_rec.TAX_UEDISCOUNTED <> 0)     OR
        (p_app_rec.FREIGHT_UEDISCOUNTED IS NOT NULL AND p_app_rec.FREIGHT_UEDISCOUNTED <> 0) OR
        (p_app_rec.CHARGES_UEDISCOUNTED IS NOT NULL AND p_app_rec.CHARGES_UEDISCOUNTED <> 0)
      THEN
         g_uned_req := 'Y';
      ELSE
         g_uned_req := 'N';
      END IF;
   END IF;

   IF PG_DEBUG = 'Y' THEN
   localdebug(' g_ed_req   :'||g_ed_req);
   localdebug(' g_uned_req :'||g_uned_req);
   END IF;
  ------------------------------------------------------------------------
  -- Create groups
  -- The group_id used currently is ra_customer_trx_lines.SOURCE_DATA_KEY1
  ------------------------------------------------------------------------
  INSERT INTO ra_ar_gt
  (gt_id,
   gp_level,
   group_id,
  --{HYUBPAGP
  source_data_key1  ,
  source_data_key2  ,
  source_data_key3  ,
  source_data_key4  ,
  source_data_key5  ,
  --}
   ref_customer_trx_id,
   from_currency,
   to_currency,
   base_currency,
   line_type,
   --
   SUM_LINE_ORIG_AMT           ,
   SUM_LINE_ORIG_ACCTD_AMT     ,
--{HYUCHRG
   SUM_LINE_CHRG_ORIG_AMT           ,
   SUM_LINE_CHRG_ORIG_ACCTD_AMT     ,
--}
   SUM_LINE_FRT_ORIG_AMT           ,
   SUM_LINE_FRT_ORIG_ACCTD_AMT     ,
   SUM_LINE_TAX_ORIG_AMT           ,
   SUM_LINE_TAX_ORIG_ACCTD_AMT     ,
   --
   SUM_LINE_REM_AMT            ,
   SUM_LINE_REM_ACCTD_AMT      ,
   SUM_LINE_CHRG_REM_AMT       ,
   SUM_LINE_CHRG_REM_ACCTD_AMT ,
   SUM_LINE_FRT_REM_AMT       ,
   SUM_LINE_FRT_REM_ACCTD_AMT ,
   SUM_LINE_TAX_REM_AMT            ,
   SUM_LINE_TAX_REM_ACCTD_AMT      ,
   --
   SUM_GP_LINE_ORIG_AMT        ,
   SUM_GP_LINE_ORIG_ACCTD_AMT  ,
--{HYUCHRG
   SUM_GP_LINE_CHRG_ORIG_AMT,
   SUM_GP_LINE_CHRG_ORIG_ACCTD_AM,
--}
   SUM_GP_LINE_FRT_ORIG_AMT        ,
   SUM_GP_LINE_FRT_ORIG_ACCTD_AMT  ,
   SUM_GP_LINE_TAX_ORIG_AMT        ,
   SUM_GP_LINE_TAX_ORIG_ACCTD_AMT  ,
   --
   SUM_GP_LINE_REM_AMT         ,
   SUM_GP_LINE_REM_ACCTD_AMT   ,
   SUM_GP_LINE_CHRG_REM_AMT    ,
   SUM_GP_LINE_CHRG_REM_ACCTD_AMT,
   SUM_GP_LINE_FRT_REM_AMT       ,
   SUM_GP_LINE_FRT_REM_ACCTD_AMT,
   SUM_GP_LINE_TAX_REM_AMT      ,
   SUM_GP_LINE_TAX_REM_ACCTD_AMT,
   --BUG#3611016
   set_of_books_id   ,
   sob_type,
--{HYUIssue
   ref_customer_trx_line_id
--}
--   se_gt_id
   --{Taxable amount
--   ,tax_link_id,
--   tax_inc_flag
   --}
   )
  SELECT /*+INDEX (rar ra_ar_n1)*/
          p_gt_id                        --GT_ID
         ,'GPL'                          --GP_LEVEL
         ,rar.group_id                   --GROUP_ID
         --{HYUBPAGP
         ,rar.source_data_key1
         ,rar.source_data_key2
         ,rar.source_data_key3
         ,rar.source_data_key4
         ,rar.source_data_key5
         --}
         ,rar.ref_customer_trx_id        --REF_CUSTOMER_TRX_ID
         ,rar.from_currency              --FROM_CURRENCY
         ,rar.to_currency                --TO_CURRENCY
         ,rar.base_currency              --BASE_CURRENCY
         ,rar.line_type                  --LINE_TYPE
         --
         ,rar.SUM_LINE_ORIG_AMT          --SUM_LINE_ORIG_AMT
         ,rar.SUM_LINE_ORIG_ACCTD_AMT    --SUM_LINE_ORIG_ACCTD_AMT
           --
--{HYUCHRG
         ,rar.SUM_LINE_CHRG_ORIG_AMT          --SUM_LINE_CHRG_ORIG_AMT
         ,rar.SUM_LINE_CHRG_ORIG_ACCTD_AMT    --SUM_LINE_CHRG_ORIG_ACCTD_AMT
--}
         ,rar.SUM_LINE_FRT_ORIG_AMT          --SUM_LINE_FRT_ORIG_AMT
         ,rar.SUM_LINE_FRT_ORIG_ACCTD_AMT    --SUM_LINE_FRT_ORIG_ACCTD_AMT
           --
         ,rar.SUM_LINE_TAX_ORIG_AMT          --SUM_LINE_TAX_ORIG_AMT
         ,rar.SUM_LINE_TAX_ORIG_ACCTD_AMT    --SUM_LINE_TAX_ORIG_ACCTD_AMT
         --
         ,rar.SUM_LINE_REM_AMT
         ,rar.SUM_LINE_REM_ACCTD_AMT
           --
         ,rar.SUM_LINE_CHRG_REM_AMT
         ,rar.SUM_LINE_CHRG_REM_ACCTD_AMT
           --
         ,rar.SUM_LINE_FRT_REM_AMT            --SUM_LINE_FRT_REM_AMT
         ,rar.SUM_LINE_FRT_REM_ACCTD_AMT      --SUM_LINE_FRT_REM_ACCTD_AMT
           --
         ,rar.SUM_LINE_TAX_REM_AMT
         ,rar.SUM_LINE_TAX_REM_ACCTD_AMT
         --
         ,SUM(rar.DUE_ORIG_AMT)        -- SUM_GP_LINE_ORIG_AMT
         ,SUM(rar.DUE_ORIG_ACCTD_AMT)  -- SUM_GP_LINE_ORIG_ACCTD_AMT
--{HYUCHRG
         ,SUM(rar.CHRG_ORIG_AMT)        -- SUM_GP_LINE_CHRG_ORIG_AMT
         ,SUM(rar.CHRG_ORIG_ACCTD_AMT)  -- SUM_GP_LINE_CHRG_ORIG_ACCTD_AM
--}
         ,SUM(rar.FRT_ORIG_AMT)        -- SUM_GP_LINE_FRT_ORIG_AMT
         ,SUM(rar.FRT_ORIG_ACCTD_AMT)  -- SUM_GP_LINE_FRT_ORIG_ACCTD_AMT
         ,SUM(rar.TAX_ORIG_AMT)        -- SUM_GP_LINE_TAX_ORIG_AMT
         ,SUM(rar.TAX_ORIG_ACCTD_AMT)  -- SUM_GP_LINE_TAX_ORIG_ACCTD_AMT
         --
         ,SUM(rar.DUE_REM_AMT)         -- SUM_GP_LINE_REM_AMT
         ,SUM(rar.DUE_REM_ACCTD_AMT)   -- SUM_GP_LINE_REM_ACCTD_AMT
--{HYUCHRG
         ,sgch.sum_gp_chrg_rem_amt       --SUM_GP_LINE_CHRG_REM_AMT       HYUCHRG
         ,sgch.sum_gp_chrg_rem_acctd_amt --SUM_GP_LINE_CHRG_REM_ACCTD_AMT HYUCHRG
--         ,SUM(rar.CHRG_REM_AMT)        -- SUM_GP_LINE_CHRG_REM_AMT
--         ,SUM(rar.CHRG_REM_ACCTD_AMT)  -- SUM_GP_LINE_CHRG_REM_ACCTD_AMT
--}
         ,sgfr.sum_gp_frt_rem_amt       --SUM_GP_LINE_FRT_REM_AMT       HYUFR
         ,sgfr.sum_gp_frt_rem_acctd_amt --SUM_GP_LINE_FRT_REM_ACCTD_AMT HYUFR
         ,SUM(rar.TAX_REM_AMT)         -- SUM_GP_LINE_TAX_REM_AMT
         ,SUM(rar.TAX_REM_ACCTD_AMT)   -- SUM_GP_LINE_TAX_REM_ACCTD_AMT
         --Bug#3611016
         ,p_ae_sys_rec.set_of_books_id
         ,p_ae_sys_rec.sob_type
--{HYUIssue
         ,rar.ref_customer_trx_line_id
--}
--         ,g_se_gt_id
         --{Taxable Amount
  --       ,rar.tax_link_id
  --       ,rar.tax_inc_flag
         --}
       FROM ra_ar_gt       rar,
            (SELECT /*+INDEX (b ra_ar_n1)*/
			         SUM(DECODE(b.line_type,'LINE'   ,b.FRT_ADJ_REM_AMT,
                                             'CB'     ,b.FRT_ADJ_REM_AMT,
                                             'FREIGHT',b.FRT_REM_AMT,
                                             0))                     sum_gp_frt_rem_amt
                     ,SUM(DECODE(b.line_type,'LINE'   ,b.FRT_ADJ_REM_ACCTD_AMT,
                                             'CB'     ,b.FRT_ADJ_REM_ACCTD_AMT,
                                             'FREIGHT',b.frt_rem_acctd_amt,
                                             0))                     sum_gp_frt_rem_acctd_amt
                     ,b.group_id
                     --{HYUBPAGP
                     ,b.source_data_key1
                     ,b.source_data_key2
                     ,b.source_data_key3
                     ,b.source_data_key4
                     ,b.source_data_key5
                     --{HYUIssue
                     ,b.ref_customer_trx_line_id
                     --}
               FROM ra_ar_gt  b
              WHERE b.ref_customer_trx_id  = p_customer_trx_id
                AND b.gt_id                = p_gt_id
                AND b.gp_level         = 'L'
                AND b.set_of_books_id  = p_ae_sys_rec.set_of_books_id
                AND (b.sob_type         = p_ae_sys_rec.sob_type OR
                     (b.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
               group by b.group_id
                        --{HYUBPAGP
                       ,b.source_data_key1
                       ,b.source_data_key2
                       ,b.source_data_key3
                       ,b.source_data_key4
                       ,b.source_data_key5
                     --{HYUIssue
                     ,b.ref_customer_trx_line_id
                     --}
                        --}
               )   sgfr,
--{HYUCHRG
            (SELECT  /*+INDEX (b ra_ar_n1)*/
			         SUM(DECODE(b.line_type,'LINE'   ,b.CHRG_ADJ_REM_AMT,
                                             'CB'     ,b.CHRG_ADJ_REM_AMT,
                                             'CHARGES',b.CHRG_REM_AMT,
                                             0))                     sum_gp_chrg_rem_amt
                     ,SUM(DECODE(b.line_type,'LINE'   ,b.CHRG_ADJ_REM_ACCTD_AMT,
                                             'CB'     ,b.CHRG_ADJ_REM_ACCTD_AMT,
                                             'CHARGES',b.chrg_rem_acctd_amt,
                                             0))                     sum_gp_chrg_rem_acctd_amt
                     ,b.group_id
                     --{HYUBPAGP
                     ,b.source_data_key1
                     ,b.source_data_key2
                     ,b.source_data_key3
                     ,b.source_data_key4
                     ,b.source_data_key5
                     --{HYUIssue
                     ,b.ref_customer_trx_line_id
                     --}
                     --}
               FROM ra_ar_gt  b
              WHERE b.ref_customer_trx_id  = p_customer_trx_id
                AND b.gt_id                = p_gt_id
                AND b.gp_level         = 'L'
                AND b.set_of_books_id  = p_ae_sys_rec.set_of_books_id
                AND (b.sob_type         = p_ae_sys_rec.sob_type OR
                      (b.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
               group by b.group_id
                        --{HYUBPAGP
                       ,b.source_data_key1
                       ,b.source_data_key2
                       ,b.source_data_key3
                       ,b.source_data_key4
                       ,b.source_data_key5
                     --{HYUIssue
                     ,b.ref_customer_trx_line_id
                     --}
                        --}
               )   sgch
--}
      WHERE rar.ref_customer_trx_id  = p_customer_trx_id
        AND rar.gt_id                = p_gt_id
        AND rar.gp_level             = 'L'
        AND rar.group_id             = sgfr.group_id
        --{HYUBPAGP
        AND rar.source_data_key1     = sgfr.source_data_key1
        AND rar.source_data_key2     = sgfr.source_data_key2
        AND rar.source_data_key3     = sgfr.source_data_key3
        AND rar.source_data_key4     = sgfr.source_data_key4
        AND rar.source_data_key5     = sgfr.source_data_key5
        --{HYUIssue
        AND rar.ref_customer_trx_line_id = sgfr.ref_customer_trx_line_id
        --}
        --}
--{HYUCHRG
        AND rar.group_id             = sgch.group_id
        AND rar.source_data_key1     = sgch.source_data_key1
        AND rar.source_data_key2     = sgch.source_data_key2
        AND rar.source_data_key3     = sgch.source_data_key3
        AND rar.source_data_key4     = sgch.source_data_key4
        AND rar.source_data_key5     = sgch.source_data_key5
        --{HYUIssue
        AND rar.ref_customer_trx_line_id = sgch.ref_customer_trx_line_id
        --}
--}
        --BUG#3611016
        AND rar.set_of_books_id      = p_ae_sys_rec.set_of_books_id
        AND (rar.sob_type             = p_ae_sys_rec.sob_type OR
              (rar.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
      GROUP BY  p_gt_id
               ,'GPL'
               ,rar.group_id
               --{HYUBPAGP
               ,rar.source_data_key1
               ,rar.source_data_key2
               ,rar.source_data_key3
               ,rar.source_data_key4
               ,rar.source_data_key5
               --}
               ,rar.ref_customer_trx_id
               --{HYUIssue
               ,rar.ref_customer_trx_line_id
               --}
               ,rar.from_currency
               ,rar.to_currency
               ,rar.base_currency
               ,rar.line_type
              --
               ,rar.SUM_LINE_ORIG_AMT
               ,rar.SUM_LINE_ORIG_ACCTD_AMT
               ,rar.SUM_LINE_CHRG_ORIG_AMT
               ,rar.SUM_LINE_CHRG_ORIG_ACCTD_AMT
               ,rar.SUM_LINE_FRT_ORIG_AMT
               ,rar.SUM_LINE_FRT_ORIG_ACCTD_AMT
               ,rar.SUM_LINE_TAX_ORIG_AMT
               ,rar.SUM_LINE_TAX_ORIG_ACCTD_AMT
              --
               ,rar.SUM_LINE_REM_AMT
               ,rar.SUM_LINE_REM_ACCTD_AMT
               ,rar.SUM_LINE_CHRG_REM_AMT
               ,rar.SUM_LINE_CHRG_REM_ACCTD_AMT
               ,rar.SUM_LINE_FRT_REM_AMT
               ,rar.SUM_LINE_FRT_REM_ACCTD_AMT
               ,rar.SUM_LINE_TAX_REM_AMT
               ,rar.SUM_LINE_TAX_REM_ACCTD_AMT
--{HYUCHRG
               ,sgch.sum_gp_chrg_rem_amt
               ,sgch.sum_gp_chrg_rem_acctd_amt
--}
               ,sgfr.sum_gp_frt_rem_amt
               ,sgfr.sum_gp_frt_rem_acctd_amt
               ,p_ae_sys_rec.set_of_books_id
               ,p_ae_sys_rec.sob_type;
--               ,g_se_gt_id;
               --{Taxble Amount
--               ,rar.tax_link_id
--               ,rar.tax_inc_flag;
               --}
    l_rows := sql%rowcount;
    g_appln_count := g_appln_count + l_rows;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  rows inserted = ' || l_rows);
    END IF;

    IF PG_DEBUG = 'Y' THEN
    display_ra_ar_gt(p_code => 'GPL', p_gt_id => p_gt_id);
    END IF;

   ---------------------------------
   -- Determine the bucket for group
   ---------------------------------
   INSERT INTO RA_AR_AMOUNTS_GT (
      gt_id
      ,gp_level
      ,base_rec_rowid
      ,ref_customer_trx_id
      ,ref_customer_trx_line_id
      ,base_pro_amt
      ,base_pro_acctd_amt
      ,base_frt_pro_amt
      ,base_frt_pro_acctd_amt
      ,base_tax_pro_amt
      ,base_tax_pro_acctd_amt
      ,BASE_CHRG_PRO_AMT
      ,BASE_CHRG_PRO_ACCTD_AMT

      ,elmt_pro_amt
      ,elmt_pro_acctd_amt
      ,ELMT_FRT_PRO_AMT
      ,ELMT_FRT_PRO_ACCTD_AMT
      ,ELMT_TAX_PRO_AMT
      ,ELMT_TAX_PRO_ACCTD_AMT
      ,ELMT_CHRG_PRO_AMT
      ,ELMT_CHRG_PRO_ACCTD_AMT

      ,buc_alloc_amt
      ,buc_alloc_acctd_amt
      ,buc_frt_alloc_amt
      ,buc_frt_alloc_acctd_amt
      ,buc_tax_alloc_amt
      ,buc_tax_alloc_acctd_amt
      ,buc_chrg_alloc_amt
      ,buc_chrg_alloc_acctd_amt

      ,base_ed_pro_amt
      ,base_ed_pro_acctd_amt
      ,BASE_ed_FRT_PRO_AMT
      ,BASE_ed_FRT_PRO_ACCTD_AMT
      ,BASE_ed_TAX_PRO_AMT
      ,BASE_ed_TAX_PRO_ACCTD_AMT
      ,BASE_ed_CHRG_PRO_AMT
      ,BASE_ed_CHRG_PRO_ACCTD_AMT

      ,elmt_ed_pro_amt
      ,elmt_ed_pro_acctd_amt
      ,ELMT_ed_FRT_PRO_AMT
      ,ELMT_ed_FRT_PRO_ACCTD_AMT
      ,ELMT_ed_TAX_PRO_AMT
      ,ELMT_ed_TAX_PRO_ACCTD_AMT
      ,ELMT_ed_CHRG_PRO_AMT
      ,ELMT_ed_CHRG_PRO_ACCTD_AMT

      ,buc_ed_alloc_amt
      ,buc_ed_alloc_acctd_amt
      ,buc_ed_frt_alloc_amt
      ,buc_ed_frt_alloc_acctd_amt
      ,buc_ed_tax_alloc_amt
      ,buc_ed_tax_alloc_acctd_amt
      ,buc_ed_chrg_alloc_amt
      ,buc_ed_chrg_alloc_acctd_amt

      ,base_uned_pro_amt
      ,base_uned_pro_acctd_amt
      ,BASE_uned_FRT_PRO_AMT
      ,BASE_uned_FRT_PRO_ACCTD_AMT
      ,BASE_uned_TAX_PRO_AMT
      ,BASE_uned_TAX_PRO_ACCTD_AMT
      ,BASE_uned_CHRG_PRO_AMT
      ,BASE_uned_CHRG_PRO_ACCTD_AMT

      ,elmt_uned_pro_amt
      ,elmt_uned_pro_acctd_amt
      ,ELMT_uned_FRT_PRO_AMT
      ,ELMT_uned_FRT_PRO_ACCTD_AMT
      ,ELMT_uned_TAX_PRO_AMT
      ,ELMT_uned_TAX_PRO_ACCTD_AMT
      ,ELMT_uned_CHRG_PRO_AMT
      ,ELMT_uned_CHRG_PRO_ACCTD_AMT

      ,buc_uned_alloc_amt
      ,buc_uned_alloc_acctd_amt
      ,buc_uned_frt_alloc_amt
      ,buc_uned_frt_alloc_acctd_amt
      ,buc_uned_tax_alloc_amt
      ,buc_uned_tax_alloc_acctd_amt
      ,buc_uned_chrg_alloc_amt
      ,buc_uned_chrg_alloc_acctd_amt
   )
   SELECT   /*+INDEX(a ra_ar_n1)*/
            a.gt_id,
            a.gp_level,
	    a.rowid,
            a.ref_customer_trx_id,
            a.ref_customer_trx_line_id,
 /**************************
  -- ADJ and APP
  **************************/
 -------
 -- BASE
 -------
            DECODE(p_pay_adj,
                  'ADJ',DECODE(a.SUM_LINE_REM_AMT, 0 ,
                             a.SUM_LINE_ORIG_AMT ,
                             a.SUM_LINE_REM_AMT),
                 a.SUM_LINE_REM_AMT),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              a.SUM_LINE_ORIG_ACCTD_AMT,
                              a.SUM_LINE_REM_ACCTD_AMT),
                 a.SUM_LINE_REM_ACCTD_AMT),

            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_AMT, 0 ,
                              a.SUM_LINE_ORIG_AMT ,
                              a.SUM_LINE_REM_AMT),
                 a.SUM_LINE_FRT_REM_AMT),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              a.SUM_LINE_ORIG_ACCTD_AMT,
                              a.SUM_LINE_REM_ACCTD_AMT),
                 a.SUM_LINE_FRT_REM_ACCTD_AMT),
   -- Base Tax
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_TAX_REM_AMT, 0 ,
                              a.SUM_LINE_TAX_ORIG_AMT ,
                              a.SUM_LINE_TAX_REM_AMT),
                 a.SUM_LINE_TAX_REM_AMT),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_TAX_REM_ACCTD_AMT, 0 ,
                              a.SUM_LINE_TAX_ORIG_ACCTD_AMT,
                              a.SUM_LINE_TAX_REM_ACCTD_AMT),
                 a.SUM_LINE_TAX_REM_ACCTD_AMT),
   -- Base Chrg
           DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_AMT, 0 ,
                              a.SUM_LINE_ORIG_AMT ,
                              a.SUM_LINE_REM_AMT),
                 a.SUM_LINE_CHRG_REM_AMT),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              a.SUM_LINE_ORIG_ACCTD_AMT ,
                              a.SUM_LINE_REM_ACCTD_AMT),
                 a.SUM_LINE_CHRG_REM_ACCTD_AMT),
  ----------
  -- Element
  ----------
   -- Elmt Rev
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_AMT, 0 ,
                              a.SUM_GP_LINE_ORIG_AMT ,
                              a.SUM_GP_LINE_REM_AMT),
                 a.SUM_GP_LINE_REM_AMT),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              a.SUM_GP_LINE_ORIG_ACCTD_AMT ,
                              a.SUM_GP_LINE_REM_ACCTD_AMT),
                 a.SUM_GP_LINE_REM_ACCTD_AMT),
   -- Elt Frt
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_AMT, 0 ,
                              a.SUM_GP_LINE_ORIG_AMT ,
                              a.SUM_GP_LINE_REM_AMT),
                 a.SUM_GP_LINE_FRT_REM_AMT),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              a.SUM_GP_LINE_ORIG_ACCTD_AMT ,
                              a.SUM_GP_LINE_REM_ACCTD_AMT),
                 a.SUM_GP_LINE_FRT_REM_ACCTD_AMT),
   -- Elt Tax
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_TAX_REM_AMT, 0 ,
                              a.SUM_GP_LINE_TAX_ORIG_AMT ,
                              a.SUM_GP_LINE_TAX_REM_AMT),
                 a.SUM_GP_LINE_TAX_REM_AMT),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_TAX_REM_ACCTD_AMT, 0 ,
                              a.SUM_GP_LINE_TAX_ORIG_ACCTD_AMT ,
                              a.SUM_GP_LINE_TAX_REM_ACCTD_AMT),
                 a.SUM_GP_LINE_TAX_REM_ACCTD_AMT),
   -- Elt Chrg
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_AMT, 0 ,
                              a.SUM_GP_LINE_ORIG_AMT ,
                              a.SUM_GP_LINE_REM_AMT),
                 a.sum_gp_line_chrg_rem_amt),
            DECODE(p_pay_adj,
                 'ADJ',DECODE(a.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              a.SUM_GP_LINE_ORIG_ACCTD_AMT ,
                              a.SUM_GP_LINE_REM_ACCTD_AMT),
                 a.sum_gp_line_chrg_rem_acctd_amt),
   ---------
   -- Bucket
   ---------
    -- Buc Rev
            arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'N',
                                                'N',
                                                'N'),
           arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'N'),
    --Buc Freight
           arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'N',
                                                'N',
                                                'Y'),
           arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'Y'),
    -- Buc Tax
           arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'N',
                                                'N',
                                                'N'),
           arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'N'),
    -- Buc Chrg
           arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'N',
                                                'Y',
                                                'N'),
           arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                a.line_type,
                                                'Y',
                                                'Y',
                                                'N'),
   /**************************
    -- ED
    **************************/
	    a.SUM_LINE_REM_AMT,     -- Base ED Rev over Rev line
	    a.SUM_LINE_REM_ACCTD_AMT,
	    a.SUM_LINE_FRT_REM_AMT, -- a.SUM_LINE_REM_AMT
	    a.SUM_LINE_FRT_REM_ACCTD_AMT,  -- a.SUM_LINE_REM_ACCTD_AMT
	    a.SUM_LINE_TAX_REM_AMT,
	    a.SUM_LINE_TAX_REM_ACCTD_AMT,
	    a.SUM_LINE_CHRG_REM_AMT,
	    a.SUM_LINE_CHRG_REM_ACCTD_AMT,
     --
	    a.SUM_GP_LINE_REM_AMT,         -- Elmt ED Rev
	    a.SUM_GP_LINE_REM_ACCTD_AMT,
	    a.SUM_GP_LINE_FRT_REM_AMT,     -- a.SUM_GP_LINE_REM_AMT
	    a.SUM_GP_LINE_FRT_REM_ACCTD_AMT,
	    a.SUM_GP_LINE_TAX_REM_AMT,
	    a.SUM_GP_LINE_TAX_REM_ACCTD_AMT,
	    a.SUM_GP_LINE_CHRG_REM_AMT,
	    a.SUM_GP_LINE_CHRG_REM_ACCTD_AMT,

          CASE
             when g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'N',
                                                'N',
                                                'N')
             else 0 end,
          CASE
             when  g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'N')
             else 0 end,
          CASE
             when  g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'N',
                                                'N',
                                                'Y')
             else 0 end,
          CASE
             when  g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'Y')
             else 0 end,
          CASE
             when g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'N',
                                                'N',
                                                'N')
             else 0 end,
          CASE
             when  g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'N')
             else 0 end,
          CASE
             when  g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'N',
                                                'Y',
                                                'N')
             else 0 end,
          CASE
             when  g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                a.line_type,
                                                'Y',
                                                'Y',
                                                'N')
             else 0 end,
   /**************************
    -- UNED
    **************************/
	    a.SUM_LINE_REM_AMT,
	    a.SUM_LINE_REM_ACCTD_AMT,
	    a.SUM_LINE_FRT_REM_AMT,
	    a.SUM_LINE_FRT_REM_ACCTD_AMT,
	    a.SUM_LINE_TAX_REM_AMT,
	    a.SUM_LINE_TAX_REM_ACCTD_AMT,
	    a.SUM_LINE_CHRG_REM_AMT,
	    a.SUM_LINE_CHRG_REM_ACCTD_AMT,
     --
	    a.SUM_GP_LINE_REM_AMT,
	    a.SUM_GP_LINE_REM_ACCTD_AMT,
	    a.SUM_GP_LINE_FRT_REM_AMT,
	    a.SUM_GP_LINE_FRT_REM_ACCTD_AMT,
	    a.SUM_GP_LINE_TAX_REM_AMT,
	    a.SUM_GP_LINE_TAX_REM_ACCTD_AMT,
	    a.SUM_GP_LINE_CHRG_REM_AMT,
	    a.SUM_GP_LINE_CHRG_REM_ACCTD_AMT,
     --
         CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'N',
                                                'N',
                                                'N')
            else 0 end,
         CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'N')
            else 0 end,
         CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'N',
                                                'N',
                                                'Y')
            else 0 end,
         CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'Y')
               else 0 end,
         CASE
             when  g_uned_req = 'Y' then
               arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'N',
                                                'N',
                                                'N')
            else 0 end,
         CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'Y',
                                                'N',
                                                'N')
            else 0 end,
         CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'N',
                                                'Y',
                                                'N')
            else 0 end,
         CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                a.line_type,
                                                'Y',
                                                'Y',
                                                'N')
               else 0 end
   FROM RA_AR_GT a
     WHERE a.gt_id                    = p_gt_id
       AND a.ref_customer_trx_id      = p_customer_trx_id
       AND a.gp_level                 = 'GPL'
       AND a.set_of_books_id          = p_ae_sys_rec.set_of_books_id
       AND (a.sob_type                 = p_ae_sys_rec.sob_type OR
             (a.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL));

    IF PG_DEBUG = 'Y' THEN
    display_ra_ar_gt(p_code => 'GPL',p_gt_id => p_gt_id);
    END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.prepare_group_for_proration()-');
  END IF;
END prepare_group_for_proration;

PROCEDURE dump_g_amt
IS
BEGIN
IF PG_DEBUG = 'Y' THEN
localdebug('-----------');
localdebug('g_line_adj           : '|| g_line_adj);
localdebug('g_tax_adj            : '|| g_tax_adj);
localdebug('g_frt_adj            : '|| g_frt_adj);
localdebug('g_chrg_adj           : '|| g_chrg_adj);
localdebug('g_acctd_line_adj     : '|| g_acctd_line_adj);
localdebug('g_acctd_tax_adj      : '|| g_acctd_tax_adj);
localdebug('g_acctd_frt_adj      : '|| g_acctd_frt_adj);
localdebug('g_acctd_chrg_adj     : '|| g_acctd_chrg_adj);

localdebug('-----------');
localdebug('g_line_applied  : '|| g_line_applied);
localdebug('g_tax_applied   : '|| g_tax_applied);
localdebug('g_frt_applied   : '|| g_frt_applied);
localdebug('g_chrg_applied  : '|| g_chrg_applied );
localdebug('g_line_ed       : '|| g_line_ed);
localdebug('g_tax_ed        : '|| g_tax_ed);
localdebug('g_frt_ed        : '|| g_frt_ed);
localdebug('g_chrg_ed       : '|| g_chrg_ed);
localdebug('g_line_uned     : '|| g_line_uned);
localdebug('g_tax_uned      : '|| g_tax_uned);
localdebug('g_frt_uned      : '|| g_frt_uned);
localdebug('g_chrg_uned     : '|| g_chrg_uned);

localdebug('g_acctd_line_applied   : '||g_acctd_line_applied);
localdebug('g_acctd_tax_applied    : '|| g_acctd_tax_applied);
localdebug('g_acctd_frt_applied    : '|| g_acctd_frt_applied);
localdebug('g_acctd_chrg_applied   : '|| g_acctd_chrg_applied);
localdebug('g_acctd_line_ed        : '|| g_acctd_line_ed);
localdebug('g_acctd_tax_ed         : '|| g_acctd_tax_ed);
localdebug('g_acctd_frt_ed         : '|| g_acctd_frt_ed);
localdebug('g_acctd_chrg_ed        : '|| g_acctd_chrg_ed);
localdebug('g_acctd_line_uned      : '|| g_acctd_line_uned);
localdebug('g_acctd_tax_uned       : '|| g_acctd_tax_uned);
localdebug('g_acctd_frt_uned       : '|| g_acctd_frt_uned);
localdebug('g_acctd_chrg_uned      : '|| g_acctd_chrg_uned);
localdebug('-----------');
END IF;
END;

PROCEDURE conv_acctd_amt
  (p_pay_adj              IN VARCHAR2,
   p_adj_rec              IN ar_adjustments%ROWTYPE,
   p_app_rec              IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type)
IS
  l_acctd_amt  NUMBER;
BEGIN
IF PG_DEBUG = 'Y' THEN
localdebug('arp_det_dist_pkg.conv_acctd_amt()+');
localdebug('    p_pay_adj :'||p_pay_adj);
localdebug('    p_app_rec.AMOUNT_APPLIED  :'||p_app_rec.AMOUNT_APPLIED);
localdebug('    p_app_rec.LINE_APPLIED    :'||p_app_rec.LINE_APPLIED);
localdebug('    p_app_rec.TAX_APPLIED     :'||p_app_rec.TAX_APPLIED);
END IF;

  g_line_adj       := 0;
  g_tax_adj        := 0;
  g_frt_adj        := 0;
  g_chrg_adj       := 0;
  g_line_applied   := 0;
  g_tax_applied    := 0;
  g_frt_applied    := 0;
  g_chrg_applied   := 0;
  g_line_ed        := 0;
  g_tax_ed         := 0;
  g_frt_ed         := 0;
  g_chrg_ed        := 0;
  g_line_uned      := 0;
  g_tax_uned       := 0;
  g_frt_uned       := 0;
  g_chrg_uned      := 0;


  g_acctd_line_adj       := 0;
  g_acctd_tax_adj        := 0;
  g_acctd_frt_adj        := 0;
  g_acctd_chrg_adj       := 0;
  g_acctd_line_applied   := 0;
  g_acctd_tax_applied    := 0;
  g_acctd_frt_applied    := 0;
  g_acctd_chrg_applied   := 0;
  g_acctd_line_ed        := 0;
  g_acctd_tax_ed         := 0;
  g_acctd_frt_ed         := 0;
  g_acctd_chrg_ed        := 0;
  g_acctd_line_uned      := 0;
  g_acctd_tax_uned       := 0;
  g_acctd_frt_uned       := 0;
  g_acctd_chrg_uned      := 0;


  IF p_pay_adj   = 'ADJ' THEN
    -- Trx currency
    -- HYU Adjustment distribution in the same sign of the header adjustment rem * -1
    -- because detail distribution passed for a negative adjustment ends to create
    -- debit write-off distributions in ARD. ARALLOCB create the write-off distributions
    -- in case of adjustments
    g_line_adj      := NVL(p_adj_rec.LINE_ADJUSTED,0);    -- -1*
    g_frt_adj       := NVL(p_adj_rec.FREIGHT_ADJUSTED,0); -- -1*
    g_tax_adj       := NVL(p_adj_rec.TAX_ADJUSTED,0);     -- -1*
    g_chrg_adj      := NVL(p_adj_rec.RECEIVABLES_CHARGES_ADJUSTED ,0);  -- -1*
    -- Based currency
    l_acctd_amt     := NVL(p_adj_rec.acctd_amount,0);     -- -1*

    arp_util.Set_Buckets(
                     p_header_acctd_amt   => l_acctd_amt                     ,
                     p_base_currency      => p_ae_sys_rec.base_currency      ,
                     p_exchange_rate      => g_cust_inv_rec.exchange_rate    ,
                     p_base_precision     => p_ae_sys_rec.base_precision     ,
                     p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit  ,
                     p_tax_amt            => g_tax_adj                       ,
                     p_charges_amt        => g_chrg_adj                      ,
                     p_line_amt           => g_line_adj                      ,
                     p_freight_amt        => g_frt_adj                       ,
                     p_tax_acctd_amt      => g_acctd_tax_adj                 ,
                     p_charges_acctd_amt  => g_acctd_chrg_adj                ,
                     p_line_acctd_amt     => g_acctd_line_adj                ,
                     p_freight_acctd_amt  => g_acctd_frt_adj                  );

  ELSE
    -- Distribution sign integration between ARPDDB and ARALLOCB
    -- To integrate with ARALLOCB as application distributions are * -1 in ARALLOCB
    -- For positive distributions creation, we need to pass a negative distribution
    -- => -1 * detail_dist (DR side) --> ARALLOCB (* -1) becomes positive distribution
    --    therefore created as Credit side of the accounting. Note ARALLOCB creates
    --    Credit REC distributions for Application
    g_line_applied    := NVL(p_app_rec.LINE_APPLIED,0)  * -1;
    g_tax_applied     := NVL(p_app_rec.TAX_APPLIED,0)   * -1;
    g_frt_applied     := NVL(p_app_rec.FREIGHT_APPLIED,0) * -1;
    g_chrg_applied    := NVL(p_app_rec.RECEIVABLES_CHARGES_APPLIED,0) * -1;
    l_acctd_amt       := NVL(p_app_rec.ACCTD_AMOUNT_APPLIED_TO,0) * -1;

    IF l_acctd_amt <> 0 THEN

      arp_util.Set_Buckets(p_header_acctd_amt   => l_acctd_amt                        ,
                           p_base_currency      => p_ae_sys_rec.base_currency         ,
                           p_exchange_rate      => g_cust_inv_rec.exchange_rate       ,
                           p_base_precision     => p_ae_sys_rec.base_precision        ,
                           p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit     ,
                           p_tax_amt            => g_tax_applied                      ,
                           p_charges_amt        => g_chrg_applied                     ,
                           p_line_amt           => g_line_applied                     ,
                           p_freight_amt        => g_frt_applied                      ,
                           p_tax_acctd_amt      => g_acctd_tax_applied                ,
                           p_charges_acctd_amt  => g_acctd_chrg_applied               ,
                           p_line_acctd_amt     => g_acctd_line_applied               ,
                           p_freight_acctd_amt  => g_acctd_frt_applied                 );
    END IF;

    --
    -- For ED and UNED discounts they are handled as adjustment distributions
    --    ARALLOCB that is ARALLOCB will create the Write-off side
    --    The credit REC for ED UNED are created by ARRECACB arp_receipt_main
    --    so for a positive ED it is like a negative adjustments, so detail_distributions
    --    for ED and UNED from ARPDDB need to be multiplied by -1 to be passed to ARALLOCB
    --
    g_line_ed         := NVL(p_app_rec.LINE_EDISCOUNTED,0) * -1;
    g_tax_ed          := NVL(p_app_rec.TAX_EDISCOUNTED,0)  * -1;
    g_frt_ed          := NVL(p_app_rec.FREIGHT_EDISCOUNTED,0) * -1;
    g_chrg_ed         := NVL(p_app_rec.CHARGES_EDISCOUNTED,0) * -1;
    l_acctd_amt       := NVL(p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN,0) * -1;

    IF l_acctd_amt <> 0 THEN

        arp_util.Set_Buckets(
                  p_header_acctd_amt   => l_acctd_amt                    ,
                  p_base_currency      => p_ae_sys_rec.base_currency     ,
                  p_exchange_rate      => g_cust_inv_rec.exchange_rate   ,
                  p_base_precision     => p_ae_sys_rec.base_precision    ,
                  p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit ,
                  p_tax_amt            => g_tax_ed                       ,
                  p_charges_amt        => g_chrg_ed                      ,
                  p_line_amt           => g_line_ed                      ,
                  p_freight_amt        => g_frt_ed                       ,
                  p_tax_acctd_amt      => g_acctd_tax_ed                 ,
                  p_charges_acctd_amt  => g_acctd_chrg_ed                ,
                  p_line_acctd_amt     => g_acctd_line_ed                ,
                  p_freight_acctd_amt  => g_acctd_frt_ed                  );
    END IF;


    g_line_uned       := NVL(p_app_rec.LINE_UEDISCOUNTED,0) * -1;
    g_tax_uned        := NVL(p_app_rec.TAX_UEDISCOUNTED,0)  * -1;
    g_frt_uned        := NVL(p_app_rec.FREIGHT_UEDISCOUNTED,0) * -1;
    g_chrg_uned       := NVL(p_app_rec.CHARGES_UEDISCOUNTED,0) * -1;
    l_acctd_amt       := NVL(p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN,0) * -1;

    IF l_acctd_amt <> 0 THEN

        arp_util.Set_Buckets(
                  p_header_acctd_amt   => l_acctd_amt                     ,
                  p_base_currency      => p_ae_sys_rec.base_currency      ,
                  p_exchange_rate      => g_cust_inv_rec.exchange_rate    ,
                  p_base_precision     => p_ae_sys_rec.base_precision     ,
                  p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit  ,
                  p_tax_amt            => g_tax_uned                      ,
                  p_charges_amt        => g_chrg_uned                     ,
                  p_line_amt           => g_line_uned                     ,
                  p_freight_amt        => g_frt_uned                      ,
                  p_tax_acctd_amt      => g_acctd_tax_uned                ,
                  p_charges_acctd_amt  => g_acctd_chrg_uned               ,
                  p_line_acctd_amt     => g_acctd_line_uned               ,
                  p_freight_acctd_amt  => g_acctd_frt_uned                 );
    END IF;

  END IF;
  dump_g_amt;
IF PG_DEBUG = 'Y' THEN
localdebug('arp_det_dist_pkg.conv_acctd_amt()-');
END IF;
END conv_acctd_amt;

--
-- This routine is similar to conv_acctd_amt, the only thing is it removes dependencies on
-- org context so that it is usable in Down time upgrade
--
PROCEDURE conv_acctd_amt_upg
  (p_pay_adj              IN VARCHAR2,
   p_adj_rec              IN ar_adjustments%ROWTYPE,
   p_app_rec              IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type)
IS
  l_acctd_amt  NUMBER;
BEGIN
  g_acctd_line_adj       := 0;
  g_acctd_tax_adj        := 0;
  g_acctd_frt_adj        := 0;
  g_acctd_chrg_adj       := 0;
  g_acctd_line_applied   := 0;
  g_acctd_tax_applied    := 0;
  g_acctd_frt_applied    := 0;
  g_acctd_chrg_applied   := 0;
  g_acctd_line_ed        := 0;
  g_acctd_tax_ed         := 0;
  g_acctd_frt_ed         := 0;
  g_acctd_chrg_ed        := 0;
  g_acctd_line_uned      := 0;
  g_acctd_tax_uned       := 0;
  g_acctd_frt_uned       := 0;
  g_acctd_chrg_uned      := 0;


  IF p_pay_adj   = 'ADJ' THEN
    -- Trx currency
    -- HYU Adjustment distribution in the same sign of the header adjustment rem * -1
    -- because detail distribution passed for a negative adjustment ends to create
    -- debit write-off distributions in ARD. ARALLOCB create the write-off distributions
    -- in case of adjustments
    g_line_adj      := NVL(p_adj_rec.LINE_ADJUSTED,0);    -- -1*
    g_frt_adj       := NVL(p_adj_rec.FREIGHT_ADJUSTED,0); -- -1*
    g_tax_adj       := NVL(p_adj_rec.TAX_ADJUSTED,0);     -- -1*
    g_chrg_adj      := NVL(p_adj_rec.RECEIVABLES_CHARGES_ADJUSTED ,0);  -- -1*
    -- Based currency
    l_acctd_amt     := NVL(p_adj_rec.acctd_amount,0);     -- -1*

    ar_unposted_item_util.Set_Buckets(
                     p_header_acctd_amt   => l_acctd_amt                     ,
                     p_base_currency      => p_ae_sys_rec.base_currency      ,
                     p_exchange_rate      => g_cust_inv_rec.exchange_rate    ,
                     p_base_precision     => p_ae_sys_rec.base_precision     ,
                     p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit  ,
                     p_tax_amt            => g_tax_adj                       ,
                     p_charges_amt        => g_chrg_adj                      ,
                     p_line_amt           => g_line_adj                      ,
                     p_freight_amt        => g_frt_adj                       ,
                     p_tax_acctd_amt      => g_acctd_tax_adj                 ,
                     p_charges_acctd_amt  => g_acctd_chrg_adj                ,
                     p_line_acctd_amt     => g_acctd_line_adj                ,
                     p_freight_acctd_amt  => g_acctd_frt_adj                  );

  ELSE
    -- Distribution sign integration between ARPDDB and ARALLOCB
    -- To integrate with ARALLOCB as application distributions are * -1 in ARALLOCB
    -- For positive distributions creation, we need to pass a negative distribution
    -- => -1 * detail_dist (DR side) --> ARALLOCB (* -1) becomes positive distribution
    --    therefore created as Credit side of the accounting. Note ARALLOCB creates
    --    Credit REC distributions for Application
    g_line_applied    := NVL(p_app_rec.LINE_APPLIED,0)  * -1;
    g_tax_applied     := NVL(p_app_rec.TAX_APPLIED,0)   * -1;
    g_frt_applied     := NVL(p_app_rec.FREIGHT_APPLIED,0) * -1;
    g_chrg_applied    := NVL(p_app_rec.RECEIVABLES_CHARGES_APPLIED,0) * -1;
    l_acctd_amt       := NVL(p_app_rec.ACCTD_AMOUNT_APPLIED_TO,0) * -1;

    IF l_acctd_amt <> 0 THEN

      ar_unposted_item_util.Set_Buckets(p_header_acctd_amt   => l_acctd_amt                        ,
                           p_base_currency      => p_ae_sys_rec.base_currency         ,
                           p_exchange_rate      => g_cust_inv_rec.exchange_rate       ,
                           p_base_precision     => p_ae_sys_rec.base_precision        ,
                           p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit     ,
                           p_tax_amt            => g_tax_applied                      ,
                           p_charges_amt        => g_chrg_applied                     ,
                           p_line_amt           => g_line_applied                     ,
                           p_freight_amt        => g_frt_applied                      ,
                           p_tax_acctd_amt      => g_acctd_tax_applied                ,
                           p_charges_acctd_amt  => g_acctd_chrg_applied               ,
                           p_line_acctd_amt     => g_acctd_line_applied               ,
                           p_freight_acctd_amt  => g_acctd_frt_applied                 );
    END IF;

    --
    -- For ED and UNED discounts they are handled as adjustment distributions
    --    ARALLOCB that is ARALLOCB will create the Write-off side
    --    The credit REC for ED UNED are created by ARRECACB arp_receipt_main
    --    so for a positive ED it is like a negative adjustments, so detail_distributions
    --    for ED and UNED from ARPDDB need to be multiplied by -1 to be passed to ARALLOCB
    --
    g_line_ed         := NVL(p_app_rec.LINE_EDISCOUNTED,0) * -1;
    g_tax_ed          := NVL(p_app_rec.TAX_EDISCOUNTED,0)  * -1;
    g_frt_ed          := NVL(p_app_rec.FREIGHT_EDISCOUNTED,0) * -1;
    g_chrg_ed         := NVL(p_app_rec.CHARGES_EDISCOUNTED,0) * -1;
    l_acctd_amt       := NVL(p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN,0) * -1;

    IF l_acctd_amt <> 0 THEN

        ar_unposted_item_util.Set_Buckets(
                  p_header_acctd_amt   => l_acctd_amt                    ,
                  p_base_currency      => p_ae_sys_rec.base_currency     ,
                  p_exchange_rate      => g_cust_inv_rec.exchange_rate   ,
                  p_base_precision     => p_ae_sys_rec.base_precision    ,
                  p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit ,
                  p_tax_amt            => g_tax_ed                       ,
                  p_charges_amt        => g_chrg_ed                      ,
                  p_line_amt           => g_line_ed                      ,
                  p_freight_amt        => g_frt_ed                       ,
                  p_tax_acctd_amt      => g_acctd_tax_ed                 ,
                  p_charges_acctd_amt  => g_acctd_chrg_ed                ,
                  p_line_acctd_amt     => g_acctd_line_ed                ,
                  p_freight_acctd_amt  => g_acctd_frt_ed                  );
    END IF;


    g_line_uned       := NVL(p_app_rec.LINE_UEDISCOUNTED,0) * -1;
    g_tax_uned        := NVL(p_app_rec.TAX_UEDISCOUNTED,0)  * -1;
    g_frt_uned        := NVL(p_app_rec.FREIGHT_UEDISCOUNTED,0) * -1;
    g_chrg_uned       := NVL(p_app_rec.CHARGES_UEDISCOUNTED,0) * -1;
    l_acctd_amt       := NVL(p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN,0) * -1;

    IF l_acctd_amt <> 0 THEN

        ar_unposted_item_util.Set_Buckets(
                  p_header_acctd_amt   => l_acctd_amt                     ,
                  p_base_currency      => p_ae_sys_rec.base_currency      ,
                  p_exchange_rate      => g_cust_inv_rec.exchange_rate    ,
                  p_base_precision     => p_ae_sys_rec.base_precision     ,
                  p_base_min_acc_unit  => p_ae_sys_rec.base_min_acc_unit  ,
                  p_tax_amt            => g_tax_uned                      ,
                  p_charges_amt        => g_chrg_uned                     ,
                  p_line_amt           => g_line_uned                     ,
                  p_freight_amt        => g_frt_uned                      ,
                  p_tax_acctd_amt      => g_acctd_tax_uned                ,
                  p_charges_acctd_amt  => g_acctd_chrg_uned               ,
                  p_line_acctd_amt     => g_acctd_line_uned               ,
                  p_freight_acctd_amt  => g_acctd_frt_uned                 );
    END IF;

  END IF;
END conv_acctd_amt_upg;



FUNCTION the_concern_bucket
  (p_pay_adj        IN VARCHAR2,
   p_line_type      IN VARCHAR2,
   p_acctd          IN VARCHAR2,
   p_chrg_bucket    IN VARCHAR2,
   p_frt_bucket     IN VARCHAR2)
RETURN NUMBER IS
    l_res   NUMBER;
BEGIN
    IF PG_DEBUG = 'Y' THEN
    localdebug('arp_det_dist_pkg.the_concern_bucket()+');
    localdebug('  p_pay_adj     :' ||p_pay_adj);
    localdebug('  p_line_type   :' ||p_line_type);
    localdebug('  p_acctd       :' ||p_acctd);
    localdebug('  p_chrg_bucket :' ||p_chrg_bucket);
    localdebug('  p_frt_bucket  :' ||p_frt_bucket);
    END IF;
    -- LINE over LINE
    -- TAX over TAX
    -- FREIGHT over LINE FOR ADJ
    --   and FREIGHT over LINE frt_adj_rem and over FREIGHT on amt_rem
      -- Chrg bucket on LINE for 11i
      -- Chrg bucket on LINE+FREIGHT for 11iX
    -- ED and UNED Revenue on Revenue line
    -- ED and UNED Tax on Tax line
    -- ED and UNED Chrg on Rev Line
    -- ED and UNED frt  on Rev Line


IF PG_DEBUG = 'Y' THEN
localdebug(' For Regular Transaction');
END IF;

    IF p_chrg_bucket = 'Y' THEN

      IF p_line_type IN ('LINE','CB') THEN
        IF    p_pay_adj = 'ADJ' THEN
          -- Chrg adjusted on Rev Line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_chrg_adj;     ELSE l_res    := g_chrg_adj;
          END IF;
        ELSIF p_pay_adj = 'APP' THEN
          -- Chrg paied on Rev line
          IF   p_acctd = 'Y' THEN
           l_res    := g_acctd_chrg_applied; ELSE l_res    := g_chrg_applied;
          END IF;
        ELSIF p_pay_adj = 'ED' THEN
          -- ED charge on Rev line
          IF   p_acctd = 'Y' THEN
           l_res    := g_acctd_chrg_ed;      ELSE l_res    := g_chrg_ed;
          END IF;
        ELSIF p_pay_adj = 'UNED' THEN
          --UNED charge on Rev line
          IF   p_acctd = 'Y' THEN
           l_res    := g_acctd_chrg_uned;    ELSE l_res    := g_chrg_uned;
          END IF;
        END IF;
      ELSIF  p_line_type IN ('CHARGES') THEN
--{HYUCHRG
        IF p_pay_adj = 'APP' THEN
          -- Chrg paid on Chrg line
          IF   p_acctd = 'Y' THEN
           l_res    := g_acctd_chrg_applied; ELSE l_res    := g_chrg_applied;
          END IF;
        ELSE
           l_res := 0;
        END IF;
--}

      ELSE
        -- Not line type LINE not chrg should be returned
        l_res := 0;
      END IF;

    ELSIF  p_frt_bucket = 'Y' THEN

      IF    p_line_type IN ('LINE','CB') THEN
        IF    p_pay_adj = 'ADJ' THEN
          -- Freight adjusted over Rev lines only
          IF   p_acctd = 'Y' THEN
           l_res    :=  g_acctd_frt_adj;     ELSE l_res    :=  g_frt_adj;
          END IF;
        ELSIF p_pay_adj = 'APP' THEN
          -- Freight paied over Rev line frt_adj_rem
          IF   p_acctd = 'Y' THEN
           l_res    := g_acctd_frt_applied;  ELSE l_res    := g_frt_applied;
          END IF;
        ELSIF p_pay_adj = 'ED' THEN
          -- ED Frt on Rev line
          IF   p_acctd = 'Y' THEN
           l_res    := g_acctd_frt_ed;       ELSE l_res    := g_frt_ed;
          END IF;
        ELSIF p_pay_adj = 'UNED' THEN
          -- UNED Frt on Rev line
          IF   p_acctd = 'Y' THEN
           l_res    := g_acctd_frt_uned;     ELSE l_res    := g_frt_uned;
          END IF;
        END IF;
      ELSIF p_line_type  = 'FREIGHT' THEN
        IF    p_pay_adj = 'ADJ' THEN
           -- Freight adjusted over rev line only
           l_res   := 0;
        ELSIF p_pay_adj = 'APP' THEN
          -- Freight paied over freight line remaining amount
          IF   p_acctd = 'Y' THEN
            l_res    := g_acctd_frt_applied; ELSE l_res    := g_frt_applied;
          END IF;
        ELSIF p_pay_adj = 'ED' THEN
          IF   p_acctd = 'Y' THEN
           --{ HYUED Frt over Rev line Only
            l_res    := g_acctd_frt_ed;       ELSE l_res    := g_frt_ed;
--           l_res := 0;                      ELSE l_res := 0;
           --}
          END IF;
        ELSIF p_pay_adj = 'UNED' THEN
          IF   p_acctd = 'Y' THEN
           --{ Frt HYUUNED over Rev line Only
           l_res    := g_acctd_frt_uned;     ELSE l_res    := g_frt_uned;
          -- l_res := 0;                      ELSE l_res := 0;
          END IF;
        END IF;
      ELSE
        -- Not Freight amount affected if the line type is TAX
        l_res := 0;
      END IF;

    ELSIF  p_chrg_bucket = 'N' AND p_frt_bucket = 'N' THEN

      IF p_line_type IN ('LINE','CB') THEN
        IF    p_pay_adj = 'ADJ' THEN
          -- Rev adjusted over Rev Line
          IF p_acctd = 'Y' THEN
            l_res    := g_acctd_line_adj;    ELSE  l_res    := g_line_adj;
          END IF;
        ELSIF p_pay_adj = 'APP' THEN
          -- Rev paied over Rev Line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_line_applied; ELSE  l_res    := g_line_applied;
          END IF;
        ELSIF p_pay_adj = 'ED' THEN
          -- ED Rev on Rev line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_line_ed;      ELSE  l_res    := g_line_ed;
          END IF;
        ELSIF p_pay_adj = 'UNED' THEN
          -- UNED Rev on Rev line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_line_uned;    ELSE  l_res    := g_line_uned;
          END IF;
        END IF;
      ELSIF p_line_type = 'TAX' THEN
        IF    p_pay_adj = 'ADJ' THEN
          --Tax adjusted on Tax Line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_tax_adj;      ELSE l_res    := g_tax_adj;
          END IF;
        ELSIF p_pay_adj = 'APP' THEN
          -- Tax applied on Tax line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_tax_applied;  ELSE l_res    := g_tax_applied;
          END IF;
        ELSIF p_pay_adj = 'ED' THEN
          -- ED Tax over Tax line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_tax_ed;       ELSE l_res    := g_tax_ed;
          END IF;
        ELSIF p_pay_adj = 'UNED' THEN
          -- UNED Tax over Tax Line
          IF p_acctd = 'Y' THEN
           l_res    := g_acctd_tax_uned;     ELSE l_res    := g_tax_uned;
          END IF;
        END IF;
      ELSE
        -- No tax amount affected to Rev or Frt line
        l_res := 0;
      END IF;
    END IF;

    IF PG_DEBUG = 'Y' THEN
    localdebug('  l_res : '|| l_res);
    localdebug('arp_det_dist_pkg.the_concern_bucket()-');
    END IF;
    RETURN l_res;
END the_concern_bucket;



PROCEDURE prepare_trx_line_proration
  (p_gt_id            IN VARCHAR2,
   p_customer_trx_id  IN NUMBER,
   p_pay_adj          IN VARCHAR2,
   p_adj_rec          IN ar_adjustments%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type)
IS
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.prepare_trx_line_proration()+');
  END IF;


-- To executed independently
--    prepare_group_for_proration(p_gt_id            => p_gt_id,
--                                p_customer_trx_id  => p_customer_trx_id);
--    update_group_line(p_gt_id           => p_gt_id,
--                   p_customer_trx_id => p_customer_trx_id);

   --replaced the update with an insert for better performance[Bug 6454022]
   INSERT INTO RA_AR_AMOUNTS_GT (
	gt_id ,
	gp_level,
	base_rec_rowid,
	ref_customer_trx_id ,
	ref_customer_trx_line_id,

   -- ADJ and APP
	base_pro_amt       ,
	base_pro_acctd_amt ,
	BASE_FRT_PRO_AMT       ,
	BASE_FRT_PRO_ACCTD_AMT ,
	BASE_TAX_PRO_AMT       ,
	BASE_TAX_PRO_ACCTD_AMT ,
	BASE_CHRG_PRO_AMT       ,
	BASE_CHRG_PRO_ACCTD_AMT ,

	elmt_pro_amt       ,
	elmt_pro_acctd_amt ,
	ELMT_FRT_PRO_AMT       ,
	ELMT_FRT_PRO_ACCTD_AMT ,
	ELMT_TAX_PRO_AMT       ,
	ELMT_TAX_PRO_ACCTD_AMT ,
	ELMT_CHRG_PRO_AMT       ,
	ELMT_CHRG_PRO_ACCTD_AMT ,

	buc_alloc_amt      ,
	buc_alloc_acctd_amt,
	buc_frt_alloc_amt      ,
	buc_frt_alloc_acctd_amt,
	buc_tax_alloc_amt      ,
	buc_tax_alloc_acctd_amt,
	buc_chrg_alloc_amt      ,
	buc_chrg_alloc_acctd_amt,
	--D
	base_ed_pro_amt       ,
	base_ed_pro_acctd_amt ,
	BASE_ed_FRT_PRO_AMT       ,
	BASE_ed_FRT_PRO_ACCTD_AMT ,
	BASE_ed_TAX_PRO_AMT       ,
	BASE_ed_TAX_PRO_ACCTD_AMT ,
	BASE_ed_CHRG_PRO_AMT       ,
	BASE_ed_CHRG_PRO_ACCTD_AMT ,

	elmt_ed_pro_amt       ,
	elmt_ed_pro_acctd_amt ,
	ELMT_ed_FRT_PRO_AMT       ,
	ELMT_ed_FRT_PRO_ACCTD_AMT ,
	ELMT_ed_TAX_PRO_AMT       ,
	ELMT_ed_TAX_PRO_ACCTD_AMT ,
	ELMT_ed_CHRG_PRO_AMT       ,
	ELMT_ed_CHRG_PRO_ACCTD_AMT ,

	buc_ed_alloc_amt      ,
	buc_ed_alloc_acctd_amt,
	buc_ed_frt_alloc_amt      ,
	buc_ed_frt_alloc_acctd_amt,
	buc_ed_tax_alloc_amt      ,
	buc_ed_tax_alloc_acctd_amt,
	buc_ed_chrg_alloc_amt      ,
	buc_ed_chrg_alloc_acctd_amt,
	--NED
	base_uned_pro_amt       ,
	base_uned_pro_acctd_amt ,
	BASE_uned_FRT_PRO_AMT       ,
	BASE_uned_FRT_PRO_ACCTD_AMT ,
	BASE_uned_TAX_PRO_AMT       ,
	BASE_uned_TAX_PRO_ACCTD_AMT ,
	BASE_uned_CHRG_PRO_AMT       ,
	BASE_uned_CHRG_PRO_ACCTD_AMT ,

	elmt_uned_pro_amt       ,
	elmt_uned_pro_acctd_amt ,
	ELMT_uned_FRT_PRO_AMT       ,
	ELMT_uned_FRT_PRO_ACCTD_AMT ,
	ELMT_uned_TAX_PRO_AMT       ,
	ELMT_uned_TAX_PRO_ACCTD_AMT ,
	ELMT_uned_CHRG_PRO_AMT       ,
	ELMT_uned_CHRG_PRO_ACCTD_AMT ,

	buc_uned_alloc_amt      ,
	buc_uned_alloc_acctd_amt,
	buc_uned_frt_alloc_amt      ,
	buc_uned_frt_alloc_acctd_amt,
	buc_uned_tax_alloc_amt      ,
	buc_uned_tax_alloc_acctd_amt,
	buc_uned_chrg_alloc_amt      ,
	buc_uned_chrg_alloc_acctd_amt
     )


    SELECT /*+INDEX(c ra_ar_n1) INDEX(b ra_ar_n1) INDEX(d RA_AR_AMOUNTS_GT_N1)*/
           c.gt_id
	   ,b.gp_level
	   ,b.rowid
           ,c.ref_customer_trx_id
           ,c.ref_customer_trx_line_id
          /**************************
          -- ADJ and APP
          **************************/
      --Base
           ,CASE WHEN g_line_flag = 'INTERFACE' THEN b.sum_int_line_amount ELSE d.elmt_pro_amt END
           ,CASE WHEN g_line_flag = 'INTERFACE' THEN b.sum_int_line_amount ELSE d.elmt_pro_acctd_amt END
           ,d.ELMT_FRT_PRO_AMT
           ,d.ELMT_FRT_PRO_ACCTD_AMT
           ,CASE WHEN g_tax_flag = 'INTERFACE' THEN b.sum_int_tax_amount ELSE d.ELMT_TAX_PRO_AMT END
           ,CASE WHEN g_tax_flag = 'INTERFACE' THEN b.sum_int_tax_amount ELSE d.ELMT_TAX_PRO_ACCTD_AMT END
           ,d.ELMT_CHRG_PRO_AMT
           ,d.ELMT_CHRG_PRO_ACCTD_AMT
       --Elmt
            -- For line
           ,CASE WHEN g_line_flag = 'INTERFACE' THEN b.int_line_amount
            ELSE
            DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_REM_AMT, 0 ,
                              b.DUE_ORIG_AMT ,
                              b.DUE_REM_AMT),
                 b.DUE_REM_AMT)
            END
           ,CASE WHEN g_line_flag = 'INTERFACE' THEN b.int_line_amount
            ELSE
            DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              b.DUE_ORIG_ACCTD_AMT ,
                              b.DUE_REM_ACCTD_AMT),
                 b.DUE_REM_ACCTD_AMT)
            END
            -- For freight
           ,DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_REM_AMT, 0 ,
                              b.DUE_ORIG_AMT ,
                              b.DUE_REM_AMT),
                 DECODE(b.line_type,'FREIGHT', b.FRT_REM_AMT,
                                    'LINE'   , b.frt_adj_rem_amt,
                                    'CB'     , b.frt_adj_rem_amt, 0))
           ,DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              b.DUE_ORIG_ACCTD_AMT ,
                              b.DUE_REM_ACCTD_AMT),
                 DECODE(b.line_type,'FREIGHT', b.FRT_REM_ACCTD_AMT,
                                    'LINE'   , b.frt_adj_rem_acctd_amt,
                                    'CB'     , b.frt_adj_rem_acctd_amt,0))
            -- For tax
           ,CASE WHEN g_tax_flag = 'INTERFACE' THEN b.int_tax_amount
            ELSE
            DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_TAX_REM_AMT, 0 ,
                              b.TAX_ORIG_AMT ,
                              b.TAX_REM_AMT),
                 b.TAX_REM_AMT)
            END
           ,CASE WHEN g_tax_flag = 'INTERFACE' THEN b.int_tax_amount
            ELSE
            DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_TAX_REM_ACCTD_AMT, 0 ,
                              b.TAX_ORIG_ACCTD_AMT ,
                              b.TAX_REM_ACCTD_AMT),
                 b.TAX_REM_ACCTD_AMT)
            END
            -- For Chrg
           ,DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_REM_AMT, 0 ,
                              b.DUE_ORIG_AMT ,
                              b.DUE_REM_AMT),
                 DECODE(b.line_type,'CHARGES', b.CHRG_REM_AMT,
                                    'LINE'   , b.chrg_adj_rem_amt,
                                    'CB'     , b.chrg_adj_rem_amt, 0))
           ,DECODE(p_pay_adj,
                 'ADJ',DECODE(b.SUM_LINE_REM_ACCTD_AMT, 0 ,
                              b.DUE_ORIG_ACCTD_AMT ,
                              b.DUE_REM_ACCTD_AMT),
                 DECODE(b.line_type,'CHARGES', b.CHRG_REM_ACCTD_AMT,
                                    'LINE'   , b.chrg_adj_rem_acctd_amt,
                                    'CB'     , b.chrg_adj_rem_acctd_amt,0))
     --Bucket
           ,CASE WHEN g_line_flag = 'NORMAL' THEN c.TL_ALLOC_AMT ELSE
             arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
	                                             b.line_type,
                                                'N',
                                                'N',
                                                'N') END
           ,CASE WHEN g_line_flag = 'NORMAL' THEN c.TL_ALLOC_ACCTD_AMT ELSE
             arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                b.line_type,
                                                'Y',
                                                'N',
                                                'N') END
           ,c.tl_frt_alloc_amt
           ,c.tl_frt_alloc_acctd_amt
           ,CASE WHEN g_tax_flag = 'NORMAL' THEN c.TL_TAX_ALLOC_AMT ELSE
              arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                b.line_type,
                                                'N',
                                                'N',
                                                'N') END
           ,CASE WHEN g_tax_flag = 'NORMAL' THEN c.TL_TAX_ALLOC_ACCTD_AMT  ELSE
              arp_det_dist_pkg.the_concern_bucket(p_pay_adj,
                                                b.line_type,
                                                'Y',
                                                'N',
                                                'N') END
           ,c.TL_CHRG_ALLOC_AMT
           ,c.TL_CHRG_ALLOC_ACCTD_AMT
          /**************************
          -- ED
          **************************/
  --Base
           ,CASE WHEN g_ed_line_flag = 'INTERFACE' THEN b.sum_int_ed_line_amount ELSE d.elmt_ed_pro_amt END
           ,CASE WHEN g_ed_line_flag = 'INTERFACE' THEN b.sum_int_ed_line_amount ELSE d.elmt_ed_pro_acctd_amt END
           ,d.elmt_ed_frt_pro_amt
           ,d.elmt_ed_frt_pro_acctd_amt
           ,CASE WHEN g_ed_tax_flag = 'INTERFACE' THEN b.sum_int_ed_tax_amount ELSE d.elmt_ed_tax_pro_amt END
           ,CASE WHEN g_ed_tax_flag = 'INTERFACE' THEN b.sum_int_ed_tax_amount ELSE d.elmt_ed_tax_pro_acctd_amt END
           ,d.ELMT_ed_CHRG_PRO_AMT
           ,d.ELMT_ed_CHRG_PRO_ACCTD_AMT
            --
   --Elmt
           ,CASE WHEN g_ed_line_flag = 'INTERFACE' THEN b.int_ed_line_amount
            ELSE
            DECODE(b.line_type,'LINE'   , b.DUE_REM_AMT,
                               'CB'     , b.due_rem_amt, 0)
            END
           ,CASE WHEN g_ed_line_flag = 'INTERFACE' THEN b.int_ed_line_amount
            ELSE
            DECODE(b.line_type,'LINE'   , b.DUE_REM_ACCTD_AMT,
                               'CB'     , b.due_rem_acctd_amt,0)
            END
           ,DECODE(b.line_type,'FREIGHT', b.frt_REM_AMT,
                               'LINE'   , b.frt_adj_rem_amt,
                               'CB'     , b.frt_adj_rem_amt,0)
           ,DECODE(b.line_type,'FREIGHT', b.frt_REM_ACCTD_AMT,
                               'LINE'   , b.frt_adj_rem_acctd_amt,
                               'CB'     , b.frt_adj_rem_acctd_amt,0)
           ,CASE WHEN g_ed_tax_flag = 'INTERFACE' THEN b.int_ed_tax_amount ELSE  b.TAX_REM_AMT  END
           ,CASE WHEN g_ed_tax_flag = 'INTERFACE' THEN b.int_ed_tax_amount ELSE  b.TAX_REM_ACCTD_AMT END
           ,DECODE(b.line_type,'CHARGES', b.chrg_REM_AMT,
                               'LINE'   , b.chrg_adj_rem_amt,
                               'CB'     , b.chrg_adj_rem_amt,0)
           ,DECODE(b.line_type,'CHARGES', b.chrg_REM_ACCTD_AMT,
                               'LINE'   , b.chrg_adj_rem_acctd_amt,
                               'CB'     , b.chrg_adj_rem_acctd_amt,0)
   --Bucket
           ,CASE WHEN g_ed_line_flag = 'NORMAL' THEN c.TL_ED_ALLOC_AMT ELSE
             CASE when g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                b.line_type,
                                                'N',
                                                'N',
                                                'N')
             else 0 end
            END
           ,CASE WHEN g_ed_line_flag = 'NORMAL' THEN c.TL_ED_ALLOC_ACCTD_AMT ELSE
             CASE
               when  g_ed_req = 'Y' then
                arp_det_dist_pkg.the_concern_bucket('ED',
                                                b.line_type,
                                                'Y',
                                                'N',
                                                'N')
               else 0 end
            END
           ,c.TL_ED_FRT_ALLOC_AMT
           ,c.TL_ED_FRT_ALLOC_ACCTD_AMT
           ,CASE WHEN g_ed_tax_flag = 'NORMAL' THEN c.TL_ED_TAX_ALLOC_AMT ELSE
             CASE
              when g_ed_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('ED',
                                                b.line_type,
                                                'N',
                                                'N',
                                                'N')
              else 0 end
            END
           ,CASE WHEN g_ed_tax_flag = 'NORMAL' THEN c.TL_ED_TAX_ALLOC_ACCTD_AMT ELSE
             CASE
              when  g_ed_req = 'Y' then
               arp_det_dist_pkg.the_concern_bucket('ED',
                                                b.line_type,
                                                'Y',
                                                'N',
                                                'N')
              else 0 end
            END
           ,c.TL_ED_CHRG_ALLOC_AMT
           ,c.TL_ED_CHRG_ALLOC_ACCTD_AMT

          /**************************
          -- UNED
          **************************/
   --Base
           ,CASE WHEN g_uned_line_flag = 'INTERFACE' THEN b.sum_int_uned_line_amount ELSE d.elmt_uned_pro_amt END
           ,CASE WHEN g_uned_line_flag = 'INTERFACE' THEN b.sum_int_uned_line_amount ELSE d.elmt_uned_pro_acctd_amt END
           ,d.elmt_uned_frt_pro_amt
           ,d.elmt_uned_frt_pro_acctd_amt
           ,CASE WHEN g_uned_tax_flag = 'INTERFACE' THEN b.sum_int_uned_tax_amount ELSE d.elmt_uned_tax_pro_amt END
           ,CASE WHEN g_uned_tax_flag = 'INTERFACE' THEN b.sum_int_uned_tax_amount ELSE d.elmt_uned_tax_pro_acctd_amt END
           ,d.ELMT_uned_CHRG_PRO_AMT
           ,d.ELMT_uned_CHRG_PRO_ACCTD_AMT
            --
--           ,b.DUE_REM_AMT
--           ,b.DUE_REM_ACCTD_AMT
--{BUG#4415037
--           ,DECODE(b.line_type,'LINE'   , b.DUE_REM_AMT,
--                               'CB'     , b.due_rem_amt,0)
--           ,DECODE(b.line_type,'LINE'   , b.DUE_REM_ACCTD_AMT,
--                               'CB'     , b.due_rem_acctd_amt,0)
   --Elmt
           ,CASE WHEN g_uned_line_flag = 'INTERFACE' THEN b.int_uned_line_amount
            ELSE
            DECODE(b.line_type,'LINE'   , b.DUE_REM_AMT,
                               'CB'     , b.due_rem_amt,0)
            END
           ,CASE WHEN g_uned_line_flag = 'INTERFACE' THEN b.int_uned_line_amount
            ELSE
            DECODE(b.line_type,'LINE'   , b.DUE_REM_ACCTD_AMT,
	                       'CB'     , b.due_rem_acctd_amt,0)
            END
           ,DECODE(b.line_type,'FREIGHT', b.frt_REM_AMT,
                               'LINE'   , b.frt_adj_rem_amt,
                               'CB'     , b.frt_adj_rem_amt,0)
           ,DECODE(b.line_type,'FREIGHT', b.frt_REM_ACCTD_AMT,
                               'LINE'   , b.frt_adj_rem_acctd_amt,
                               'CB'     , b.frt_adj_rem_acctd_amt,0)
--           ,DECODE(b.line_type,'LINE'   , b.DUE_REM_AMT,0)
--           ,DECODE(b.line_type,'LINE'   , b.DUE_REM_ACCTD_AMT,0)
           ,CASE WHEN g_uned_tax_flag = 'INTERFACE' THEN b.int_uned_tax_amount ELSE b.TAX_REM_AMT  END
           ,CASE WHEN g_uned_tax_flag = 'INTERFACE' THEN b.int_uned_tax_amount ELSE b.TAX_REM_ACCTD_AMT END
           ,DECODE(b.line_type,'CHARGES', b.chrg_REM_AMT,
                               'LINE'   , b.chrg_adj_rem_amt,
                               'CB'     , b.chrg_adj_rem_amt,0)
           ,DECODE(b.line_type,'CHARGES', b.chrg_REM_ACCTD_AMT,
                               'LINE'   , b.chrg_adj_rem_acctd_amt,
                               'CB'     , b.chrg_adj_rem_acctd_amt,0)
   --Bucket
           ,CASE WHEN g_uned_line_flag = 'NORMAL' THEN c.TL_UNED_ALLOC_AMT ELSE
             CASE
              when  g_uned_req = 'Y' then
               arp_det_dist_pkg.the_concern_bucket('UNED',
                                                b.line_type,
                                                'N',
                                                'N',
                                                'N')
              else 0 end
            END
           ,CASE WHEN g_uned_line_flag = 'NORMAL' THEN c.TL_UNED_ALLOC_ACCTD_AMT ELSE
             CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                b.line_type,
                                                'Y',
                                                'N',
                                                'N')
             else 0 end
            END
           ,c.TL_UNED_FRT_ALLOC_AMT
           ,c.TL_UNED_FRT_ALLOC_ACCTD_AMT
           ,CASE WHEN g_uned_tax_flag = 'NORMAL' THEN c.TL_UNED_TAX_ALLOC_AMT  ELSE
             CASE
             when  g_uned_req = 'Y' then
               arp_det_dist_pkg.the_concern_bucket('UNED',
                                                b.line_type,
                                                'N',
                                                'N',
                                                'N')
             else 0 end
            END
           ,CASE WHEN g_uned_tax_flag = 'NORMAL' THEN c.TL_UNED_TAX_ALLOC_ACCTD_AMT ELSE
             CASE
             when  g_uned_req = 'Y' then
              arp_det_dist_pkg.the_concern_bucket('UNED',
                                                b.line_type,
                                                'Y',
                                                'N',
                                                'N')
              else 0 end
            END
           ,c.TL_UNED_CHRG_ALLOC_AMT
           ,c.TL_UNED_CHRG_ALLOC_ACCTD_AMT
       FROM RA_AR_GT b,
            RA_AR_GT c,
	    RA_AR_AMOUNTS_GT d
      WHERE b.gt_id               = p_gt_id
--        AND b.se_gt_id            = g_se_gt_id
        AND b.ref_customer_trx_id = p_customer_trx_id
        AND b.gp_level            = 'L'
        --Bug#3611016
        AND b.set_of_books_id     = p_ae_sys_rec.set_of_books_id
        AND (b.sob_type            = p_ae_sys_rec.sob_type OR
             (b.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
        AND c.gt_id               = p_gt_id
        AND c.gp_level            = 'GPL'
        AND c.ref_customer_trx_id = p_customer_trx_id
        --Bug#3611016
        AND c.set_of_books_id     = p_ae_sys_rec.set_of_books_id
        AND (c.sob_type            = p_ae_sys_rec.sob_type OR
              (c.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
        AND c.gt_id               = d.gt_id
	AND c.rowid               = d.base_rec_rowid
  --      AND c.group_id            = b.group_id
  --{HYUBPAGP
        AND c.source_data_key1    = b.source_data_key1
        AND c.source_data_key2    = b.source_data_key2
        AND c.source_data_key3    = b.source_data_key3
        AND c.source_data_key4    = b.source_data_key4
        AND c.source_data_key5    = b.source_data_key5
  --}
        AND c.line_type           = b.line_type
  --{HYUIssue
        AND c.ref_customer_trx_line_id = b.ref_customer_trx_line_id;
  --}

  IF PG_DEBUG = 'Y' THEN
  display_ra_ar_gt(p_code  => 'L', p_gt_id => p_gt_id);
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.prepare_trx_line_proration()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('EXCEPTION OTHERS prepare_trx_line_proration:'||SQLERRM);
  END IF;
END  prepare_trx_line_proration;



PROCEDURE update_ctl_rem_orig
  (p_gt_id                IN VARCHAR2,
   p_customer_trx_id      IN NUMBER,
   p_pay_adj              IN VARCHAR2,
   p_customer_trx_line_id IN NUMBER   DEFAULT NULL,
   --{HYUBPAGP
   p_source_data_key1     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key2     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key3     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key4     IN VARCHAR2 DEFAULT NULL,
   p_source_data_key5     IN VARCHAR2 DEFAULT NULL,
   --}
   p_log_inv_line         IN VARCHAR2 DEFAULT 'N',
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type)
IS
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_ctl_rem_orig()+');
  localdebug('  p_customer_trx_line_id:'||p_customer_trx_line_id);
  localdebug('  p_source_data_key1    :'||p_source_data_key1);
  localdebug('  p_source_data_key2    :'||p_source_data_key2);
  localdebug('  p_source_data_key3    :'||p_source_data_key3);
  localdebug('  p_source_data_key4    :'||p_source_data_key4);
  localdebug('  p_source_data_key5    :'||p_source_data_key5);
  localdebug('  Update rem amount in ra_customer_trx_lines_gt for regular transaction');
  END IF;
   IF p_customer_trx_line_id IS NOT NULL THEN
  IF p_log_inv_line = 'N' THEN

    UPDATE /*+ index(A  RA_CUSTOMER_TRX_LINES_GT_N1)*/ ra_customer_trx_lines_gt a
       SET (a.AMOUNT_DUE_REMAINING        ,
            a.ACCTD_AMOUNT_DUE_REMAINING  ,
            a.AMOUNT_DUE_ORIGINAL         ,
            a.ACCTD_AMOUNT_DUE_ORIGINAL   ,
            a.CHRG_AMOUNT_REMAINING       ,
            a.CHRG_ACCTD_AMOUNT_REMAINING ,
            a.FRT_ADJ_REMAINING           ,
            a.FRT_ADJ_ACCTD_REMAINING     ,
            a.frt_ed_amount,
            a.frt_ed_acctd_amount,
            a.frt_uned_amount,
            a.frt_uned_acctd_amount) =
       (SELECT /*+INDEX (b ra_ar_n1)*/
	           DECODE(a.line_type, 'LINE',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
                                   'CB',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
                                   'TAX',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_amt,0),NVL(b.tl_tax_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_amt,0),NVL(b.tl_ed_tax_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_amt,0),NVL(b.tl_uned_tax_alloc_amt,0)),
                                   'FREIGHT',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_amt,0)),
                                   'CHARGES',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_amt,0)),
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_amt,0)),
                     0)                                                 -- AMOUNT_DUE_REMAINING
               ,DECODE(a.line_type, 'LINE',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
                                    'CB',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
                                    'TAX',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_acctd_amt,0),NVL(b.tl_tax_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_acctd_amt,0),NVL(b.tl_ed_tax_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_acctd_amt,0),NVL(b.tl_uned_tax_alloc_acctd_amt,0)),
                                    'FREIGHT',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_acctd_amt,0)),
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)),
--{HYUCHRG
                                    'CHARGES',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_acctd_amt,0)),
                     0)                                                -- ACCTD_AMOUNT_DUE_REMAINING
--}
               ,DECODE(a.line_type, 'LINE', NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
                                     'CB' , NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
                                 'FREIGHT', NVL(a.AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_AMT),
                                 'CHARGES', NVL(a.AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_AMT),
                                     'TAX', NVL(a.AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_AMT),
                                            0)                         -- AMOUNT_DUE_ORIGINAL
               ,DECODE(a.line_type, 'LINE', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
                                     'CB' , NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
                                 'FREIGHT', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_ACCTD_AMT),
                                 'CHARGES', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_ACCTD_AMT),
                                     'TAX', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_ACCTD_AMT),
                                            0)                         -- ACCTD_AMOUNT_DUE_ORIGINAL
--{HYUCHRG
--               ,NVL(a.CHRG_AMOUNT_REMAINING,0)
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),NVL(b.tl_chrg_alloc_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_amt,0),NVL(b.tl_ed_chrg_alloc_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_amt,0),NVL(b.tl_uned_chrg_alloc_amt,0))
--                                                                       -- CHRG_AMOUNT_REMAINING
--               ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),NVL(b.tl_chrg_alloc_acctd_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_acctd_amt,0),NVL(b.tl_ed_chrg_alloc_acctd_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_acctd_amt,0),NVL(b.tl_uned_chrg_alloc_acctd_amt,0))
--                                                                       -- CHRG_ACCTD_AMOUNT_REMAINING
               ,NVL(a.CHRG_AMOUNT_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_amt,0),
                                                                 'CB'  ,NVL(b.tl_chrg_alloc_amt,0),0))
                                                                       -- CHRG_AMOUNT_REMAINING
               ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_acctd_amt,0),
                                                                 'CB'  ,NVL(b.tl_chrg_alloc_acctd_amt,0),0))
                                                                       -- CHRG_ACCTD_AMOUNT_REMAINING
--}
               ,NVL(a.FRT_ADJ_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_amt,0),
                                                                 'CB'  ,NVL(b.tl_frt_alloc_amt,0),0))
                                                                       -- FRT_ADJ_REMAINING
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_amt,0),0))
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_amt,0),0))
               ,NVL(a.FRT_ADJ_ACCTD_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_acctd_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_acctd_amt,0),
                                                                 'CB'  ,NVL(b.tl_frt_alloc_acctd_amt,0),0))
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0)))
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)))
                                                                       -- FRT_ADJ_ACCTD_REMAINING
               ,NVL(a.frt_ed_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_amt,0),
                                                 'CB'  ,NVL(b.tl_ed_frt_alloc_amt,0), 0))
               ,NVL(a.frt_ed_acctd_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_acctd_amt,0),
                                                 'CB'  ,NVL(b.tl_ed_frt_alloc_acctd_amt,0),0))
               ,NVL(a.frt_uned_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_amt,0),
                                                 'CB'  ,NVL(b.tl_uned_frt_alloc_amt,0),0))
               ,NVL(a.frt_uned_acctd_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_acctd_amt,0),
                                                 'CB'  ,NVL(b.tl_uned_frt_alloc_acctd_amt,0),0))
          FROM RA_AR_GT b
         WHERE b.gt_id                = p_gt_id
--           AND b.se_gt_id             = g_se_gt_id
           AND a.customer_trx_id      = b.ref_customer_trx_id
           AND a.customer_trx_line_id = b.ref_customer_trx_line_id
--           AND a.group_id             = b.group_id
  --{HYUBPAGP
           AND NVL(a.source_data_key1,'00')     = b.source_data_key1
           AND NVL(a.source_data_key2,'00')     = b.source_data_key2
           AND NVL(a.source_data_key3,'00')     = b.source_data_key3
           AND NVL(a.source_data_key4,'00')     = b.source_data_key4
           AND NVL(a.source_data_key5,'00')     = b.source_data_key5
  --}
           --Bug#3611016
           AND (b.sob_type             = 'P' OR b.sob_type IS NULL)
           AND b.set_of_books_id      = a.set_of_books_id
           AND b.gp_level             = 'L')
     WHERE a.customer_trx_id   = p_customer_trx_id
       AND a.set_of_books_id   = p_ae_sys_rec.set_of_books_id
       AND p_customer_trx_line_id = a.customer_trx_line_id
--       AND DECODE( p_group_id, NULL, '-99', p_group_id)
--                   = DECODE(p_group_id, NULL, '-99', a.group_id)
  --{HYUBPAGP
       AND DECODE( p_source_data_key1, NULL, '-99', p_source_data_key1)
                   = DECODE(p_source_data_key1, NULL, '-99', a.source_data_key1)
       AND DECODE( p_source_data_key2, NULL, '-99', p_source_data_key2)
                   = DECODE(p_source_data_key2, NULL, '-99', a.source_data_key2)
       AND DECODE( p_source_data_key3, NULL, '-99', p_source_data_key3)
                   = DECODE(p_source_data_key3, NULL, '-99', a.source_data_key3)
       AND DECODE( p_source_data_key4, NULL, '-99', p_source_data_key4)
                   = DECODE(p_source_data_key4, NULL, '-99', a.source_data_key4)
       AND DECODE( p_source_data_key5, NULL, '-99', p_source_data_key5)
                   = DECODE(p_source_data_key5, NULL, '-99', a.source_data_key5)
  --}
       AND a.line_type IN ('LINE','FREIGHT','TAX','CB','CHARGES');

ELSE
        UPDATE /*+ index(A  RA_CUSTOMER_TRX_LINES_GT_N1)*/ ra_customer_trx_lines_gt a
		       SET (a.AMOUNT_DUE_REMAINING        ,
			    a.ACCTD_AMOUNT_DUE_REMAINING  ,
			    a.AMOUNT_DUE_ORIGINAL         ,
			    a.ACCTD_AMOUNT_DUE_ORIGINAL   ,
			    a.CHRG_AMOUNT_REMAINING       ,
			    a.CHRG_ACCTD_AMOUNT_REMAINING ,
			    a.FRT_ADJ_REMAINING           ,
			    a.FRT_ADJ_ACCTD_REMAINING     ,
			    a.frt_ed_amount,
			    a.frt_ed_acctd_amount,
			    a.frt_uned_amount,
			    a.frt_uned_acctd_amount) =
		       (SELECT /*+INDEX (b ra_ar_n1)*/
				   DECODE(a.line_type, 'LINE',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
						   'CB',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
						   'TAX',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_amt,0),NVL(b.tl_tax_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_amt,0),NVL(b.tl_ed_tax_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_amt,0),NVL(b.tl_uned_tax_alloc_amt,0)),
						   'FREIGHT',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_amt,0)),
						   'CHARGES',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_amt,0)),
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_amt,0)),
				     0)                                                 -- AMOUNT_DUE_REMAINING
			       ,DECODE(a.line_type, 'LINE',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
						    'CB',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
						    'TAX',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_acctd_amt,0),NVL(b.tl_tax_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_acctd_amt,0),NVL(b.tl_ed_tax_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_acctd_amt,0),NVL(b.tl_uned_tax_alloc_acctd_amt,0)),
						    'FREIGHT',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_acctd_amt,0)),
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)),
		--{HYUCHRG
						    'CHARGES',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_acctd_amt,0)),
				     0)                                                -- ACCTD_AMOUNT_DUE_REMAINING
		--}
			       ,DECODE(a.line_type, 'LINE', NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
						     'CB' , NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
						 'FREIGHT', NVL(a.AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_AMT),
						 'CHARGES', NVL(a.AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_AMT),
						     'TAX', NVL(a.AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_AMT),
							    0)                         -- AMOUNT_DUE_ORIGINAL
			       ,DECODE(a.line_type, 'LINE', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
						     'CB' , NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
						 'FREIGHT', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_ACCTD_AMT),
						 'CHARGES', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_ACCTD_AMT),
						     'TAX', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_ACCTD_AMT),
							    0)                         -- ACCTD_AMOUNT_DUE_ORIGINAL
		--{HYUCHRG
		--               ,NVL(a.CHRG_AMOUNT_REMAINING,0)
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),NVL(b.tl_chrg_alloc_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_amt,0),NVL(b.tl_ed_chrg_alloc_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_amt,0),NVL(b.tl_uned_chrg_alloc_amt,0))
		--                                                                       -- CHRG_AMOUNT_REMAINING
		--               ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),NVL(b.tl_chrg_alloc_acctd_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_acctd_amt,0),NVL(b.tl_ed_chrg_alloc_acctd_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_acctd_amt,0),NVL(b.tl_uned_chrg_alloc_acctd_amt,0))
		--                                                                       -- CHRG_ACCTD_AMOUNT_REMAINING
			       ,NVL(a.CHRG_AMOUNT_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_amt,0),
										 'CB'  ,NVL(b.tl_chrg_alloc_amt,0),0))
										       -- CHRG_AMOUNT_REMAINING
			       ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_acctd_amt,0),
										 'CB'  ,NVL(b.tl_chrg_alloc_acctd_amt,0),0))
										       -- CHRG_ACCTD_AMOUNT_REMAINING
		--}
			       ,NVL(a.FRT_ADJ_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_amt,0),
										 'CB'  ,NVL(b.tl_frt_alloc_amt,0),0))
										       -- FRT_ADJ_REMAINING
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_amt,0),0))
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_amt,0),0))
			       ,NVL(a.FRT_ADJ_ACCTD_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_acctd_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_acctd_amt,0),
										 'CB'  ,NVL(b.tl_frt_alloc_acctd_amt,0),0))
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0)))
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)))
										       -- FRT_ADJ_ACCTD_REMAINING
			       ,NVL(a.frt_ed_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_amt,0),
								 'CB'  ,NVL(b.tl_ed_frt_alloc_amt,0), 0))
			       ,NVL(a.frt_ed_acctd_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_acctd_amt,0),
								 'CB'  ,NVL(b.tl_ed_frt_alloc_acctd_amt,0),0))
			       ,NVL(a.frt_uned_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_amt,0),
								 'CB'  ,NVL(b.tl_uned_frt_alloc_amt,0),0))
			       ,NVL(a.frt_uned_acctd_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_acctd_amt,0),
								 'CB'  ,NVL(b.tl_uned_frt_alloc_acctd_amt,0),0))
			  FROM RA_AR_GT b
			 WHERE b.gt_id                = p_gt_id
		--           AND b.se_gt_id             = g_se_gt_id
			   AND a.customer_trx_id      = b.ref_customer_trx_id
			   AND a.customer_trx_line_id = b.ref_customer_trx_line_id
		--           AND a.group_id             = b.group_id
		  --{HYUBPAGP
			   AND NVL(a.source_data_key1,'00')     = b.source_data_key1
			   AND NVL(a.source_data_key2,'00')     = b.source_data_key2
			   AND NVL(a.source_data_key3,'00')     = b.source_data_key3
			   AND NVL(a.source_data_key4,'00')     = b.source_data_key4
			   AND NVL(a.source_data_key5,'00')     = b.source_data_key5
		  --}
			   --Bug#3611016
			   AND (b.sob_type             = 'P' OR b.sob_type IS NULL)
			   AND b.set_of_books_id      = a.set_of_books_id
			   AND b.gp_level             = 'L')
		     WHERE a.customer_trx_id   = p_customer_trx_id
		       AND a.set_of_books_id   = p_ae_sys_rec.set_of_books_id
		       AND p_customer_trx_line_id = a.customer_trx_line_id
		--       AND DECODE( p_group_id, NULL, '-99', p_group_id)
		--                   = DECODE(p_group_id, NULL, '-99', a.group_id)
		  --{HYUBPAGP
		       AND DECODE( p_source_data_key1, NULL, '-99', p_source_data_key1)
				   = DECODE(p_source_data_key1, NULL, '-99', a.source_data_key1)
		       AND DECODE( p_source_data_key2, NULL, '-99', p_source_data_key2)
				   = DECODE(p_source_data_key2, NULL, '-99', a.source_data_key2)
		       AND DECODE( p_source_data_key3, NULL, '-99', p_source_data_key3)
				   = DECODE(p_source_data_key3, NULL, '-99', a.source_data_key3)
		       AND DECODE( p_source_data_key4, NULL, '-99', p_source_data_key4)
				   = DECODE(p_source_data_key4, NULL, '-99', a.source_data_key4)
		       AND DECODE( p_source_data_key5, NULL, '-99', p_source_data_key5)
				   = DECODE(p_source_data_key5, NULL, '-99', a.source_data_key5)
		  --}
		       AND a.line_type IN ('LINE','CB');

            UPDATE /*+ index(A  RA_CUSTOMER_TRX_LINES_GT_N2)*/ ra_customer_trx_lines_gt a
		       SET (a.AMOUNT_DUE_REMAINING        ,
			    a.ACCTD_AMOUNT_DUE_REMAINING  ,
			    a.AMOUNT_DUE_ORIGINAL         ,
			    a.ACCTD_AMOUNT_DUE_ORIGINAL   ,
			    a.CHRG_AMOUNT_REMAINING       ,
			    a.CHRG_ACCTD_AMOUNT_REMAINING ,
			    a.FRT_ADJ_REMAINING           ,
			    a.FRT_ADJ_ACCTD_REMAINING     ,
			    a.frt_ed_amount,
			    a.frt_ed_acctd_amount,
			    a.frt_uned_amount,
			    a.frt_uned_acctd_amount) =
		       (SELECT /*+INDEX (b ra_ar_n1)*/
				   DECODE(a.line_type, 'LINE',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
						   'CB',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
						   'TAX',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_amt,0),NVL(b.tl_tax_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_amt,0),NVL(b.tl_ed_tax_alloc_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_amt,0),NVL(b.tl_uned_tax_alloc_amt,0)),
						   'FREIGHT',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_amt,0)),
						   'CHARGES',
				      NVL(a.AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_amt,0)),
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_amt,0)),
				     0)                                                 -- AMOUNT_DUE_REMAINING
			       ,DECODE(a.line_type, 'LINE',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
						    'CB',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
						    'TAX',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_acctd_amt,0),NVL(b.tl_tax_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_acctd_amt,0),NVL(b.tl_ed_tax_alloc_acctd_amt,0))
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_acctd_amt,0),NVL(b.tl_uned_tax_alloc_acctd_amt,0)),
						    'FREIGHT',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_acctd_amt,0)),
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)),
		--{HYUCHRG
						    'CHARGES',
				      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_acctd_amt,0)),
				     0)                                                -- ACCTD_AMOUNT_DUE_REMAINING
		--}
			       ,DECODE(a.line_type, 'LINE', NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
						     'CB' , NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
						 'FREIGHT', NVL(a.AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_AMT),
						 'CHARGES', NVL(a.AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_AMT),
						     'TAX', NVL(a.AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_AMT),
							    0)                         -- AMOUNT_DUE_ORIGINAL
			       ,DECODE(a.line_type, 'LINE', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
						     'CB' , NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
						 'FREIGHT', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_ACCTD_AMT),
						 'CHARGES', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_ACCTD_AMT),
						     'TAX', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_ACCTD_AMT),
							    0)                         -- ACCTD_AMOUNT_DUE_ORIGINAL
		--{HYUCHRG
		--               ,NVL(a.CHRG_AMOUNT_REMAINING,0)
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),NVL(b.tl_chrg_alloc_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_amt,0),NVL(b.tl_ed_chrg_alloc_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_amt,0),NVL(b.tl_uned_chrg_alloc_amt,0))
		--                                                                       -- CHRG_AMOUNT_REMAINING
		--               ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),NVL(b.tl_chrg_alloc_acctd_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_acctd_amt,0),NVL(b.tl_ed_chrg_alloc_acctd_amt,0))
		--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_acctd_amt,0),NVL(b.tl_uned_chrg_alloc_acctd_amt,0))
		--                                                                       -- CHRG_ACCTD_AMOUNT_REMAINING
			       ,NVL(a.CHRG_AMOUNT_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_amt,0),
										 'CB'  ,NVL(b.tl_chrg_alloc_amt,0),0))
										       -- CHRG_AMOUNT_REMAINING
			       ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_acctd_amt,0),
										 'CB'  ,NVL(b.tl_chrg_alloc_acctd_amt,0),0))
										       -- CHRG_ACCTD_AMOUNT_REMAINING
		--}
			       ,NVL(a.FRT_ADJ_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_amt,0),
										 'CB'  ,NVL(b.tl_frt_alloc_amt,0),0))
										       -- FRT_ADJ_REMAINING
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_amt,0),0))
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_amt,0),0))
			       ,NVL(a.FRT_ADJ_ACCTD_REMAINING,0)
				     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_acctd_amt,0),
							      DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_acctd_amt,0),
										 'CB'  ,NVL(b.tl_frt_alloc_acctd_amt,0),0))
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0)))
		--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0),
		--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)))
										       -- FRT_ADJ_ACCTD_REMAINING
			       ,NVL(a.frt_ed_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_amt,0),
								 'CB'  ,NVL(b.tl_ed_frt_alloc_amt,0), 0))
			       ,NVL(a.frt_ed_acctd_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_acctd_amt,0),
								 'CB'  ,NVL(b.tl_ed_frt_alloc_acctd_amt,0),0))
			       ,NVL(a.frt_uned_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_amt,0),
								 'CB'  ,NVL(b.tl_uned_frt_alloc_amt,0),0))
			       ,NVL(a.frt_uned_acctd_amount,0)
				     + DECODE(p_pay_adj,'ADJ',0,
					      DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_acctd_amt,0),
								 'CB'  ,NVL(b.tl_uned_frt_alloc_acctd_amt,0),0))
			  FROM RA_AR_GT b
			 WHERE b.gt_id                = p_gt_id
		--           AND b.se_gt_id             = g_se_gt_id
			   AND a.customer_trx_id      = b.ref_customer_trx_id
			   AND a.customer_trx_line_id = b.ref_customer_trx_line_id
		--           AND a.group_id             = b.group_id
		  --{HYUBPAGP
			   AND NVL(a.source_data_key1,'00')     = b.source_data_key1
			   AND NVL(a.source_data_key2,'00')     = b.source_data_key2
			   AND NVL(a.source_data_key3,'00')     = b.source_data_key3
			   AND NVL(a.source_data_key4,'00')     = b.source_data_key4
			   AND NVL(a.source_data_key5,'00')     = b.source_data_key5
		  --}
			   --Bug#3611016
			   AND (b.sob_type             = 'P' OR b.sob_type IS NULL)
			   AND b.set_of_books_id      = a.set_of_books_id
			   AND b.gp_level             = 'L')
		     WHERE a.customer_trx_id   = p_customer_trx_id
		       AND a.set_of_books_id   = p_ae_sys_rec.set_of_books_id
		       AND p_customer_trx_line_id = a.LINK_TO_CUST_TRX_LINE_ID
		--       AND DECODE( p_group_id, NULL, '-99', p_group_id)
		--                   = DECODE(p_group_id, NULL, '-99', a.group_id)
		  --{HYUBPAGP
		       AND DECODE( p_source_data_key1, NULL, '-99', p_source_data_key1)
				   = DECODE(p_source_data_key1, NULL, '-99', a.source_data_key1)
		       AND DECODE( p_source_data_key2, NULL, '-99', p_source_data_key2)
				   = DECODE(p_source_data_key2, NULL, '-99', a.source_data_key2)
		       AND DECODE( p_source_data_key3, NULL, '-99', p_source_data_key3)
				   = DECODE(p_source_data_key3, NULL, '-99', a.source_data_key3)
		       AND DECODE( p_source_data_key4, NULL, '-99', p_source_data_key4)
				   = DECODE(p_source_data_key4, NULL, '-99', a.source_data_key4)
		       AND DECODE( p_source_data_key5, NULL, '-99', p_source_data_key5)
				   = DECODE(p_source_data_key5, NULL, '-99', a.source_data_key5)
		  --}
		       AND a.line_type IN ('FREIGHT','TAX','CHARGES');
   END IF; -- End of p_log_inv_line check
ELSE
      UPDATE /*+ index(A  RA_CUSTOMER_TRX_LINES_GT_N1)*/ ra_customer_trx_lines_gt a
       SET (a.AMOUNT_DUE_REMAINING        ,
            a.ACCTD_AMOUNT_DUE_REMAINING  ,
            a.AMOUNT_DUE_ORIGINAL         ,
            a.ACCTD_AMOUNT_DUE_ORIGINAL   ,
            a.CHRG_AMOUNT_REMAINING       ,
            a.CHRG_ACCTD_AMOUNT_REMAINING ,
            a.FRT_ADJ_REMAINING           ,
            a.FRT_ADJ_ACCTD_REMAINING     ,
            a.frt_ed_amount,
            a.frt_ed_acctd_amount,
            a.frt_uned_amount,
            a.frt_uned_acctd_amount) =
       (SELECT /*+INDEX (b ra_ar_n1)*/
	           DECODE(a.line_type, 'LINE',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
                                   'CB',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_amt,0),NVL(b.tl_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_amt,0),NVL(b.tl_ed_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_amt,0),NVL(b.tl_uned_alloc_amt,0)),
                                   'TAX',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_amt,0),NVL(b.tl_tax_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_amt,0),NVL(b.tl_ed_tax_alloc_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_amt,0),NVL(b.tl_uned_tax_alloc_amt,0)),
                                   'FREIGHT',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_amt,0)),
                                   'CHARGES',
                      NVL(a.AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_amt,0)),
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_amt,0)),
                     0)                                                 -- AMOUNT_DUE_REMAINING
               ,DECODE(a.line_type, 'LINE',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
                                    'CB',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_alloc_acctd_amt,0),NVL(b.tl_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_alloc_acctd_amt,0),NVL(b.tl_ed_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_alloc_acctd_amt,0),NVL(b.tl_uned_alloc_acctd_amt,0)),
                                    'TAX',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_tax_alloc_acctd_amt,0),NVL(b.tl_tax_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_tax_alloc_acctd_amt,0),NVL(b.tl_ed_tax_alloc_acctd_amt,0))
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_tax_alloc_acctd_amt,0),NVL(b.tl_uned_tax_alloc_acctd_amt,0)),
                                    'FREIGHT',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_frt_alloc_acctd_amt,0)),
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',0,-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)),
--{HYUCHRG
                                    'CHARGES',
                      NVL(a.ACCTD_AMOUNT_DUE_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',0,NVL(b.tl_chrg_alloc_acctd_amt,0)),
                     0)                                                -- ACCTD_AMOUNT_DUE_REMAINING
--}
               ,DECODE(a.line_type, 'LINE', NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
                                     'CB' , NVL(a.AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_AMT),
                                 'FREIGHT', NVL(a.AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_AMT),
                                 'CHARGES', NVL(a.AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_AMT),
                                     'TAX', NVL(a.AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_AMT),
                                            0)                         -- AMOUNT_DUE_ORIGINAL
               ,DECODE(a.line_type, 'LINE', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
                                     'CB' , NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.DUE_ORIG_ACCTD_AMT),
                                 'FREIGHT', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.FRT_ORIG_ACCTD_AMT),
                                 'CHARGES', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.CHRG_ORIG_ACCTD_AMT),
                                     'TAX', NVL(a.ACCTD_AMOUNT_DUE_ORIGINAL,b.TAX_ORIG_ACCTD_AMT),
                                            0)                         -- ACCTD_AMOUNT_DUE_ORIGINAL
--{HYUCHRG
--               ,NVL(a.CHRG_AMOUNT_REMAINING,0)
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),NVL(b.tl_chrg_alloc_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_amt,0),NVL(b.tl_ed_chrg_alloc_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_amt,0),NVL(b.tl_uned_chrg_alloc_amt,0))
--                                                                       -- CHRG_AMOUNT_REMAINING
--               ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),NVL(b.tl_chrg_alloc_acctd_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_ed_chrg_alloc_acctd_amt,0),NVL(b.tl_ed_chrg_alloc_acctd_amt,0))
--                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_uned_chrg_alloc_acctd_amt,0),NVL(b.tl_uned_chrg_alloc_acctd_amt,0))
--                                                                       -- CHRG_ACCTD_AMOUNT_REMAINING
               ,NVL(a.CHRG_AMOUNT_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_amt,0),
                                                                 'CB'  ,NVL(b.tl_chrg_alloc_amt,0),0))
                                                                       -- CHRG_AMOUNT_REMAINING
               ,NVL(a.CHRG_ACCTD_AMOUNT_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_chrg_alloc_acctd_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_chrg_alloc_acctd_amt,0),
                                                                 'CB'  ,NVL(b.tl_chrg_alloc_acctd_amt,0),0))
                                                                       -- CHRG_ACCTD_AMOUNT_REMAINING
--}
               ,NVL(a.FRT_ADJ_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_amt,0),
                                                                 'CB'  ,NVL(b.tl_frt_alloc_amt,0),0))
                                                                       -- FRT_ADJ_REMAINING
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_amt,0),0))
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_amt,0),0))
               ,NVL(a.FRT_ADJ_ACCTD_REMAINING,0)
                     + DECODE(p_pay_adj,'ADJ',NVL(b.tl_frt_alloc_acctd_amt,0),
                                              DECODE(b.line_type,'LINE',NVL(b.tl_frt_alloc_acctd_amt,0),
                                                                 'CB'  ,NVL(b.tl_frt_alloc_acctd_amt,0),0))
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_ed_frt_alloc_acctd_amt,0)))
--                     + DECODE(p_pay_adj,'ADJ',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0),
--                                              DECODE(b.line_type,'LINE',-1*NVL(b.tl_uned_frt_alloc_acctd_amt,0)))
                                                                       -- FRT_ADJ_ACCTD_REMAINING
               ,NVL(a.frt_ed_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_amt,0),
                                                 'CB'  ,NVL(b.tl_ed_frt_alloc_amt,0), 0))
               ,NVL(a.frt_ed_acctd_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_ed_frt_alloc_acctd_amt,0),
                                                 'CB'  ,NVL(b.tl_ed_frt_alloc_acctd_amt,0),0))
               ,NVL(a.frt_uned_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_amt,0),
                                                 'CB'  ,NVL(b.tl_uned_frt_alloc_amt,0),0))
               ,NVL(a.frt_uned_acctd_amount,0)
                     + DECODE(p_pay_adj,'ADJ',0,
                              DECODE(b.line_type,'LINE',NVL(b.tl_uned_frt_alloc_acctd_amt,0),
                                                 'CB'  ,NVL(b.tl_uned_frt_alloc_acctd_amt,0),0))
          FROM RA_AR_GT b
         WHERE b.gt_id                = p_gt_id
--           AND b.se_gt_id             = g_se_gt_id
           AND a.customer_trx_id      = b.ref_customer_trx_id
           AND a.customer_trx_line_id = b.ref_customer_trx_line_id
--           AND a.group_id             = b.group_id
  --{HYUBPAGP
           AND NVL(a.source_data_key1,'00')     = b.source_data_key1
           AND NVL(a.source_data_key2,'00')     = b.source_data_key2
           AND NVL(a.source_data_key3,'00')     = b.source_data_key3
           AND NVL(a.source_data_key4,'00')     = b.source_data_key4
           AND NVL(a.source_data_key5,'00')     = b.source_data_key5
  --}
           --Bug#3611016
           AND (b.sob_type             = 'P' OR b.sob_type IS NULL)
           AND b.set_of_books_id      = a.set_of_books_id
           AND b.gp_level             = 'L')
     WHERE a.customer_trx_id   = p_customer_trx_id
       AND a.set_of_books_id   = p_ae_sys_rec.set_of_books_id
   --     AND DECODE( p_customer_trx_line_id, NULL, -99, p_customer_trx_line_id)
   --                = DECODE(p_customer_trx_line_id, NULL, -99,
   --                         DECODE(p_log_inv_line, 'N', a.customer_trx_line_id,
   --                                DECODE(a.line_type,'LINE', a.customer_trx_line_id,
   --                                                   'CB'  , a.customer_trx_line_id,
   --                                        a.LINK_TO_CUST_TRX_LINE_ID)))
--       AND DECODE( p_group_id, NULL, '-99', p_group_id)
--                   = DECODE(p_group_id, NULL, '-99', a.group_id)
  --{HYUBPAGP
       AND DECODE( p_source_data_key1, NULL, '-99', p_source_data_key1)
                   = DECODE(p_source_data_key1, NULL, '-99', a.source_data_key1)
       AND DECODE( p_source_data_key2, NULL, '-99', p_source_data_key2)
                   = DECODE(p_source_data_key2, NULL, '-99', a.source_data_key2)
       AND DECODE( p_source_data_key3, NULL, '-99', p_source_data_key3)
                   = DECODE(p_source_data_key3, NULL, '-99', a.source_data_key3)
       AND DECODE( p_source_data_key4, NULL, '-99', p_source_data_key4)
                   = DECODE(p_source_data_key4, NULL, '-99', a.source_data_key4)
       AND DECODE( p_source_data_key5, NULL, '-99', p_source_data_key5)
                   = DECODE(p_source_data_key5, NULL, '-99', a.source_data_key5)
  --}
       AND a.line_type IN ('LINE','FREIGHT','TAX','CB','CHARGES');
END IF; -- End of p_customer_trx_line_id check

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_ctl_rem_orig()-');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
        IF PG_DEBUG = 'Y' THEN
	localdebug('update_ctl_rem_orig EXCEPTION OTHERS :'||SQLERRM);
	END IF;
END update_ctl_rem_orig;



PROCEDURE get_inv_dist
 (p_pay_adj                 IN VARCHAR2,
  p_customer_trx_id         IN NUMBER,
  p_gt_id                   IN VARCHAR2,
  p_adj_rec                 IN ar_adjustments%ROWTYPE,
  p_app_rec                 IN ar_receivable_applications%ROWTYPE,
  p_ae_sys_rec              IN arp_acct_main.ae_sys_rec_type)
 IS

   l_rows NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_inv_dist()+');
  localdebug('  p_ae_sys_rec.set_of_books_id :'||p_ae_sys_rec.set_of_books_id);
  localdebug('  p_ae_sys_rec.sob_type        :'||p_ae_sys_rec.sob_type);
  END IF;

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
     DIST_AMT,             --HYUD LINE
     DIST_ACCTD_AMT,       --HYUD LINE
     DIST_CHRG_AMT,        --HYUD CHRG
     DIST_CHRG_ACCTD_AMT,  --HYUD CHRG
     DIST_FRT_AMT,         --HYUD FRT
     DIST_FRT_ACCTD_AMT,   --HYUD FRT
     DIST_TAX_AMT,         --HYUD TAX
     DIST_TAX_ACCTD_AMT,   --HYUD TAX
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
     --
  -- UNED
     DIST_uned_AMT                    ,
     DIST_uned_ACCTD_AMT              ,
     DIST_uned_chrg_AMT,
     DIST_uned_chrg_ACCTD_AMT,
     DIST_uned_frt_AMT      ,
     DIST_uned_frt_ACCTD_AMT,
     DIST_uned_tax_AMT      ,
     DIST_uned_tax_ACCTD_AMT,
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
     tax_link_id,
     tax_inc_flag
     )
   SELECT /*+INDEX (rar ra_ar_n1) LEADING(rar,ctlgd) USE_NL_WITH_INDEX(rar ra_ar_n1) USE_NL_WITH_INDEX(ctlgd RA_CUST_TRX_LINE_GL_DIST_N1)*/
          p_gt_id,
          ctlgd.amount,
          ctlgd.acctd_amount,
          ctlgd.account_class,
          -- The ccid_secondary is used to populate ar_line_apps_det.ccid
          -- which in turn served as ref_dist_ccid for cash basis accounting
          -- therefor only used at payment, hence should hit the collected ccid
          DECODE(ctlgd.account_class,'TAX',
		           DECODE(ctlgd.collected_tax_ccid,NULL,
                           ctlgd.code_combination_id,
                           ctlgd.collected_tax_ccid),
                 ctlgd.code_combination_id),
          ctlgd.cust_trx_line_gl_dist_id,
          ctlgd.customer_trx_line_id,
          ctlgd.customer_trx_id,
          rar.to_currency,
          rar.base_currency,
       -- ADJ and APP
          DECODE(rar.line_type,'LINE',ctlgd.amount,
	                       'CB'  ,ctlgd.amount,0),               --For Line DIST_AMT
          DECODE(rar.line_type,'LINE',ctlgd.acctd_amount,
	                       'CB'  ,ctlgd.acctd_amount,0),         --         DIST_ACCTD_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'CHARGES',ctlgd.amount,0),
                        DECODE(rar.line_type,'LINE',ctlgd.amount,
                                             'CB'  ,ctlgd.amount,0)),   --For Chrg DIST_CHRG_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'CHARGES',ctlgd.amount,0),
                        DECODE(rar.line_type,'LINE',ctlgd.acctd_amount,
                                           'CB'  ,ctlgd.acctd_amount,0)),--   DIST_CHRG_ACCTD_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'FREIGHT',ctlgd.amount,0),
                        DECODE(rar.line_type,'LINE',ctlgd.amount,
                                             'CB'  ,ctlgd.amount,0)),--For Frt  DIST_FRT_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'FREIGHT',ctlgd.amount,0),
                        DECODE(rar.line_type,'LINE',ctlgd.acctd_amount,
                                             'CB'  ,ctlgd.acctd_amount,0)),--   DIST_FRT_AMT
          DECODE(rar.line_type,'TAX',ctlgd.amount,0),                --For Tax  DIST_AMT
          DECODE(rar.line_type,'TAX',ctlgd.acctd_amount,0),          --         DIST_ACCTD_AMT
          --
          tl_alloc_amt          ,
          tl_alloc_acctd_amt    ,
          tl_chrg_alloc_amt     ,
          tl_chrg_alloc_acctd_amt,
          tl_frt_alloc_amt,
          tl_frt_alloc_acctd_amt,
          tl_tax_alloc_amt     ,
          tl_tax_alloc_acctd_amt,
          --
       -- ED
          DECODE(rar.line_type,'LINE',ctlgd.amount,
                               'CB'  ,ctlgd.amount,0),               --For Line DIST_AMT
          DECODE(rar.line_type,'LINE',ctlgd.acctd_amount,
                              'CB'  ,ctlgd.acctd_amount,0),         --         DIST_ACCTD_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'CHARGES',ctlgd.amount,0),
                 0),                                                 --For Chrg  DIST_CHRG_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'CHARGES',ctlgd.acctd_amount,0),
                 0),                                                 --          DIST_CHRG_ACCTD_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'FREIGHT',ctlgd.amount,0),
                 0),                                                 --For Frt DIST_FRT_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'FREIGHT',ctlgd.acctd_amount,0),
                 0),                                                 --        DIST_FRT_ACCTD_AMT

          DECODE(rar.line_type,'TAX',ctlgd.amount,0),                --For Tax  DIST_AMT
          DECODE(rar.line_type,'TAX',ctlgd.acctd_amount,0),          --         DIST_ACCTD_AMT
          tl_ed_alloc_amt          ,
          tl_ed_alloc_acctd_amt    ,
          tl_ed_chrg_alloc_amt     ,
          tl_ed_chrg_alloc_acctd_amt,

            tl_ed_frt_alloc_amt     ,
            tl_ed_frt_alloc_acctd_amt,
            tl_ed_tax_alloc_amt     ,
            tl_ed_tax_alloc_acctd_amt,
          --
       -- UNED
          DECODE(rar.line_type,'LINE',ctlgd.amount,
	                       'CB'  ,ctlgd.amount,0),               --For Line DIST_AMT
          DECODE(rar.line_type,'LINE',ctlgd.acctd_amount,
	                       'CB'  ,ctlgd.acctd_amount,0),         --         DIST_ACCTD_AMT

          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'CHARGES',ctlgd.amount,0),
                        0),                                          --For Charges  DIST_CHRG_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'CHARGES',ctlgd.acctd_amount,0),
                        0),                                           --            DIST_CHRG_ACCTD_AMT
--{ Uned Frt Element
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'FREIGHT',ctlgd.amount,0),
                        0),                                           --For Frt  DIST_FRT_AMT
          DECODE(p_pay_adj,'APP',
                 DECODE(rar.line_type,'FREIGHT',ctlgd.acctd_amount,0),
                        0),                                           --   DIST_FRT_ACCTD_AMT
--}
          DECODE(rar.line_type,'TAX',ctlgd.amount,0),                --For Tax  DIST_AMT
          DECODE(rar.line_type,'TAX',ctlgd.acctd_amount,0),          --         DIST_ACCTD_AMT
          -- Buc
          tl_uned_alloc_amt          ,
          tl_uned_alloc_acctd_amt    ,
          tl_uned_chrg_alloc_amt     ,
          tl_uned_chrg_alloc_acctd_amt,
          tl_uned_frt_alloc_amt     ,
          tl_uned_frt_alloc_acctd_amt,
          tl_uned_tax_alloc_amt     ,
          tl_uned_tax_alloc_acctd_amt,
          DECODE(p_pay_adj,'ADJ',p_adj_rec.TYPE,p_app_rec.APPLICATION_TYPE),
          DECODE(p_pay_adj,'ADJ','ADJ','RA'),
          DECODE(p_pay_adj,'ADJ',p_adj_rec.adjustment_id, p_app_rec.receivable_application_id),
          rar.line_type,
          --
          rar.group_id,
          rar.source_data_key1  ,
          rar.source_data_key2  ,
          rar.source_data_key3  ,
          rar.source_data_key4  ,
          rar.source_data_key5  ,
          'D',
          --BUG#3611016
          p_ae_sys_rec.set_of_books_id,
          p_ae_sys_rec.sob_type,
          rar.tax_link_id,
          rar.tax_inc_flag
     FROM ra_ar_gt                     rar,
          ra_cust_trx_line_gl_dist     ctlgd
    WHERE rar.gt_id                      = p_gt_id
      AND rar.ref_customer_trx_id        = p_customer_trx_id
      AND rar.gp_level                   = 'L'
      AND rar.ref_customer_trx_id        = ctlgd.customer_trx_id
      AND rar.ref_customer_trx_line_id   = ctlgd.customer_trx_line_id(+)
      --{HYU revrec adj api restriction
      AND ctlgd.account_set_flag         = 'N';
--{HYUTREATUNEARNUNBILLED
--      AND ctlgd.account_class         NOT IN ('UNEARN','UNBILL');

  l_rows := sql%rowcount;
  g_appln_count := g_appln_count + l_rows;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  rows inserted = ' || l_rows);
  localdebug('   -->Distributions gotten from transaction ');
  END IF;


/* Commented this portion of de code out for no adjustment will use LLCA in 11i,
   and unification of cash basis and accrual basis accounting is not required in 11i
   the is portion of the code is necessary in 11iX for unification of cash basis and accrual
   Without commenting out this piece of code the mechanism will not break
   because not adjustment will be created with detail distributions in 11i
   For performance reason, we might need to comment out this piece in 11i
*/

  IF p_pay_adj <> 'ADJ' THEN

   -- Need to insert adjustment distributions for cash basis representation
   -- Use for R12 and R12_11IMFAR, but not for R12_11ICASH (online_lazy_upg)
   -- As online_lazy_upg never goes here no need to add a if condition, add it for safety

   IF PG_DEBUG = 'Y' THEN
   localdebug('Get_inv_dist: Insert Adjustoment distributions');
   localdebug('  g_mode_process:'||g_mode_process);
   END IF;

   IF g_mode_process NOT IN ('R12_11ICASH','R12_MERGE') THEN

   IF PG_DEBUG = 'Y' THEN
   localdebug('  Normal R12 distributions');
   END IF;

   -- Adj Distribution R12
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
     DIST_AMT,             --HYUD LINE
     DIST_ACCTD_AMT,       --HYUD LINE
     DIST_CHRG_AMT,        --HYUD CHRG
     DIST_CHRG_ACCTD_AMT,  --HYUD CHRG
     DIST_FRT_AMT,         --HYUD FRT
     DIST_FRT_ACCTD_AMT,   --HYUD FRT
     DIST_TAX_AMT,         --HYUD TAX
     DIST_TAX_ACCTD_AMT,   --HYUD TAX
     --
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
     --
  -- UNED
     DIST_uned_AMT                    ,
     DIST_uned_ACCTD_AMT              ,
     DIST_uned_chrg_AMT,
     DIST_uned_chrg_ACCTD_AMT,
     DIST_uned_frt_AMT      ,
     DIST_uned_frt_ACCTD_AMT,
     DIST_uned_tax_AMT      ,
     DIST_uned_tax_ACCTD_AMT,
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
     ref_line_id              ,
     line_type                 ,
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
     tax_link_id,
     tax_inc_flag
     )
   SELECT /*+INDEX (rar ra_ar_n1)*/
          p_gt_id,     --gt_id
          NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),  --amt
                    --HYU A negative adj distrib increase the inv rec therefore the rem on trx line
                    -- For ARPDDB and ARALLOCB integration detail distribution from ARPDDB needs
                    -- to be created in the same sign of the parent adjustment <=>
                    -- ADJ -100 will create a set of det_dist for the Write-off account with a total
                    -- of -100 ending decrease the line balance, no need to multply by -1 removing it
          NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0), --acctd_amt  Rem * -1
          rrc.ref_account_class,   --account_class
          rrc.code_combination_id,  --ccid_secondary

          NVL(rrc.ref_cust_trx_line_gl_dist_id,
               DECODE(rrc.ref_account_class,'REV',
                      DECODE(rrc.activity_bucket,'ADJ_LINE' ,-6,  --Boundary line : -6
                                        'ADJ_FRT'  ,-9,  --Boundary frt  : -9 frt adjustment over Rev line
                             -7),                        --Boundary charge:-7
                                            'UNEARN',
                      DECODE(rrc.activity_bucket,'ADJ_LINE' ,-6,  --Boundary line : -6
                                        'ADJ_FRT'  ,-9,  --Boundary frt  : -9 frt adjustment over Rev line
                             -7),                        --Boundary charge:-7
                                            'UNBILL',
                      DECODE(rrc.activity_bucket,'ADJ_LINE' ,-6,  --Boundary line : -6
                                        'ADJ_FRT'  ,-9,  --Boundary frt  : -9 frt adjustment over Rev line
                             -7),                        --Boundary charge:-7

                      'TAX', -8,                        -- Boundary tax
                      'FREIGHT',-9)),                   -- Boundary freight : This should not happens as not adjustment
                                                                         --   will be tied to freight line
          NVL(rrc.ref_customer_trx_line_id,
               DECODE(rrc.ref_account_class,'REV',
                      DECODE(rrc.activity_bucket,'ADJ_LINE' ,-6, -- Boundary line:-6
                                        'ADJ_FRT'  ,-9, -- Boundary freight:-6
                             -7),                          -- Boundary charge:-7
                                            'UNEARN',
                      DECODE(rrc.activity_bucket,'ADJ_LINE' ,-6, -- Boundary line:-6
                                        'ADJ_FRT'  ,-9, -- Boundary freight:-6
                             -7),                          -- Boundary charge:-7
                                            'UNBILL',
                      DECODE(rrc.activity_bucket,'ADJ_LINE' ,-6, -- Boundary line:-6
                                        'ADJ_FRT'  ,-9, -- Boundary freight:-6
                             -7),                          -- Boundary charge:-7
                      'TAX', -8,                        -- Boundary tax
                      'FREIGHT',-9)),                   -- Boundary freight : This should not happens as not adjustment
                                                                         --   will be tied to freight line
          rar.ref_customer_trx_id,
          rar.to_currency,
          rar.base_currency,
      -- ADJ and APP  -- HYU "A reprendre ici"
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
								   0),         -- DIST_AMT
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
						   0),    -- DIST_ACCTD_AMT
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                   0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                   0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                   0           ),
								   0),         -- DIST_CHRG_AMT
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_CHRG_ACCTD_AMT
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                      'UNBILL',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_FRT_AMT
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_FRT_ACCTD_AMT
         DECODE(rrc.ref_account_class,'TAX',
                       CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.TAX_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,0),             -- DIST_TAX_AMT
         DECODE(rrc.ref_account_class,'TAX',
                       CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.TAX_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,0),       -- DIST_TAX_ACCTD_AMT
         --
         rar.tl_alloc_amt          ,
         rar.tl_alloc_acctd_amt    ,
         rar.tl_chrg_alloc_amt     ,
         rar.tl_chrg_alloc_acctd_amt,
         rar.tl_frt_alloc_amt          ,
         rar.tl_frt_alloc_acctd_amt    ,
         rar.tl_tax_alloc_amt          ,
         rar.tl_tax_alloc_acctd_amt    ,
         -- Elemt Rev
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
					   0) ,        -- DIST_ED_AMT  Rem * -1
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT' ,0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),

                       0),    -- DIST_ED_ACCTD_AMT  Rem * -1
         -- Elemt Chrg
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
									  'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
									  'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_ED_CHRG_AMT Rem * -1
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                       'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                       'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_ED_CHRG_ACCTD_AMT Rem * -1
         -- Elemt Frt
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_ED_FRT_AMT Rem * -1
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                       'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                       'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_ED_FRT_ACCTD_AMT Rem * -1
         -- Elemt Tax
         DECODE(rrc.ref_account_class,'TAX',
                       CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.TAX_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,0),             -- DIST_ED_TAX_AMT  Rem * -1
         DECODE(rrc.ref_account_class,'TAX',
                       CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.TAX_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,0),       -- DIST_ED_TAX_ACCTD_AMT Rem * -1
         --Bucket
          -- Buc Rev
          rar.tl_ed_alloc_amt          ,
          rar.tl_ed_alloc_acctd_amt    ,
          --Buc Chrg
          rar.tl_ed_chrg_alloc_amt     ,
          rar.tl_ed_chrg_alloc_acctd_amt,
          --Buc Frt
          rar.tl_ed_frt_alloc_amt          ,
          rar.tl_ed_frt_alloc_acctd_amt    ,
          --Buc Tax
          rar.tl_ed_tax_alloc_amt          ,
          rar.tl_ed_tax_alloc_acctd_amt    ,
          --
      -- UNED
         -- Rev Elemt
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
                                       'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
                                       'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END),
						  0),         -- DIST_UNED_AMT  Rem * -1
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',0,
                                  'ADJ_CHRG',0,
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.DUE_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END),
                         0),   -- DIST_UNED_ACCTD_AMT  Rem * -1
         -- Chrg Elemt
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_UNED_CHRG_AMT Rem * -1
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_CHRG',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.CHRG_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_UNED_CHRG_ACCTD_AMT  Rem * -1
         -- Frt Elemt
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_UNED_FRT_AMT  Rem * -1
         DECODE(rrc.ref_account_class,'REV',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNEARN',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
                                      'UNBILL',
                DECODE(rrc.activity_bucket,'ADJ_FRT',
                                  CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.FRT_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,
                                        0           ),
										0),         -- DIST_UNED_FRT_ACCTD_AMT  Rem * -1
         -- Tax Elemt
         DECODE(rrc.ref_account_class,'TAX',
                       CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                            OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.TAX_ORIG_AMT = 0 THEN
                                  0 ELSE NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0) END,0),             -- DIST_UNED_TAX_AMT  Rem * -1
         DECODE(rrc.ref_account_class,'TAX',
                       CASE WHEN SUM(NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0))
                                     OVER (PARTITION BY rar.ref_customer_trx_line_id||rrc.activity_bucket)
                                            + rar.TAX_ORIG_AMT = 0 THEN
                           0 ELSE NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0) END,0),       -- DIST_UNED_TAX_ACCTD_AMT Rem * -1
       --Bucket
         -- Rev
         rar.tl_uned_alloc_amt          ,
         rar.tl_uned_alloc_acctd_amt    ,
         --Chrg
         rar.tl_uned_chrg_alloc_amt     ,
         rar.tl_uned_chrg_alloc_acctd_amt,
         --Frt
         rar.tl_uned_frt_alloc_amt          ,
         rar.tl_uned_frt_alloc_acctd_amt    ,
         --Tax
         rar.tl_uned_tax_alloc_amt          ,
         rar.tl_uned_tax_alloc_acctd_amt    ,
         --
          p_app_rec.APPLICATION_TYPE,
          'RA',
          p_app_rec.receivable_application_id,
          rrc.line_id,
          rar.line_type,
          --
          rar.group_id,
          rar.source_data_key1  ,
          rar.source_data_key2  ,
          rar.source_data_key3  ,
          rar.source_data_key4  ,
          rar.source_data_key5  ,
          'D',
          --BUG#3611016
          p_ae_sys_rec.set_of_books_id,
          p_ae_sys_rec.sob_type,
          rrc.tax_link_id,   -- tax_link_id
          DECODE(rrc.ref_account_class,'TAX','Y',
                     --'REV',DECODE(NVL(adj.tax_adjusted,0),0, 'N','Y'),
		     'REV','Y', -- BUG 7597090
                     'N')   -- tax_inc_flag
     FROM ra_ar_gt                    rar,
          ar_distributions            rrc,
          ar_adjustments              adj
    WHERE rar.gt_id                      = p_gt_id
      AND rar.ref_customer_trx_id        = p_customer_trx_id
      AND rar.gp_level                   = 'L'
      AND adj.customer_trx_id            = p_customer_trx_id
      AND rrc.source_table               = 'ADJ'
      AND rrc.source_id                  = adj.adjustment_id
      AND rar.ref_customer_trx_line_id   = rrc.ref_customer_trx_line_id
      AND rar.ref_cust_trx_line_gl_dist_id IS NULL
      AND (adj.upgrade_method   = 'R12' OR adj.upgrade_method IS NULL);
-- exclude the FREIGHT from REV line
--      AND rrc.source_type               <> 'FREIGHT'; /*FREIGHT adjustment is included in REV*/

   l_rows := sql%rowcount;
   g_appln_count := g_appln_count + l_rows;
   IF PG_DEBUG = 'Y' THEN
   localdebug('  rows inserted = ' || l_rows);

   --{Boundary distributions
   localdebug('  Boundary R12 distributions');
   END IF;

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
     DIST_AMT,             --HYUD LINE
     DIST_ACCTD_AMT,       --HYUD LINE
     DIST_CHRG_AMT,        --HYUD CHRG
     DIST_CHRG_ACCTD_AMT,  --HYUD CHRG
     DIST_FRT_AMT,         --HYUD FRT
     DIST_FRT_ACCTD_AMT,   --HYUD FRT
     DIST_TAX_AMT,         --HYUD TAX
     DIST_TAX_ACCTD_AMT,   --HYUD TAX
     --
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
     --
  -- UNED
     DIST_uned_AMT                    ,
     DIST_uned_ACCTD_AMT              ,
     DIST_uned_chrg_AMT,
     DIST_uned_chrg_ACCTD_AMT,
     DIST_uned_frt_AMT      ,
     DIST_uned_frt_ACCTD_AMT,
     DIST_uned_tax_AMT      ,
     DIST_uned_tax_ACCTD_AMT,
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
     ref_line_id              ,
     line_type                 ,
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
     tax_link_id,
     tax_inc_flag
     )
   SELECT p_gt_id,                              --gt_id
          NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),                        --amt   Rem * -1
          NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),                  --acctd_amt  Rem * -1
          rrc.ref_account_class,                        --account_class
          rrc.code_combination_id,              --ccid_secondary
          rrc.ref_cust_trx_line_gl_dist_id,     -- (-6 line, -7 chrg, -8 tax, -9 frt)
          rrc.ref_customer_trx_line_id,
          p_customer_trx_id,
          trx.invoice_currency_code,
          arp_global.functional_currency,
      -- APP
         -- Elemt Rev
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-6,
               NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-6,
               NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_ACCTD_AMT Rem * -1
         --Elemt Chrg
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-7,
               NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_CHRG_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-7,
               NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_CHRG_ACCTD_AMT Rem * -1
         --Elemt Frt
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-9,
               NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_FRT_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-9,
               NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_FRT_ACCTD_AMT Rem * -1
         --Elemt Tax
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-8,
               NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_TAX_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-8,
               NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_TAX_ACCTD_AMT  Rem * -1
       --Bucket
         --Rev
         g_line_applied          ,
         g_acctd_line_applied    ,
         --Chrg
         g_chrg_applied          ,
         g_acctd_chrg_applied    ,
         --Frt
         g_frt_applied           ,
         g_acctd_frt_applied     ,
         --Tax
         g_tax_applied           ,
         g_acctd_tax_applied     ,
         --
      -- ED
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-6,
                 NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_ED_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-6,
                 NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_ED_ACCTD_AMT Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-7,
                 NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_ED_CHRG_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-7,
                 NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_ED_CHRG_ACCTD_AMT Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-9,
                 NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_ED_FRT_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-9,
                 NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_ED_FRT_ACCTD_AMT Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-8,
                 NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_ED_TAX_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-8,
                 NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_ED_TAX_ACCTD_AMT  Rem * -1
         --
          g_line_ed          ,
          g_acctd_line_ed    ,
          g_chrg_ed          ,
          g_acctd_chrg_ed    ,
          g_frt_ed           ,
          g_acctd_frt_ed     ,
          g_tax_ed           ,
          g_acctd_tax_ed     ,
          --
      -- UNED
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-6,
             NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_UNED_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-6,
             NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_UNED_ACCTD_AMT Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-7,
             NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_UNED_CHRG_AMT   Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-7,
             NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_UNED_CHRG_ACCTD_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-9,
             NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_UNED_FRT_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-9,
             NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_UNED_FRT_ACCTD_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-8,
             NVL(rrc.AMOUNT_CR,0) - NVL(rrc.AMOUNT_DR,0),0),         -- DIST_UNED_TAX_AMT  Rem * -1
         DECODE(rrc.ref_cust_trx_line_gl_dist_id,-8,
             NVL(rrc.ACCTD_AMOUNT_CR,0) - NVL(rrc.ACCTD_AMOUNT_DR,0),0),   -- DIST_UNED_TAX_ACCTD_AMT  Rem * -1
         --
          g_line_uned          ,
          g_acctd_line_uned    ,
          g_chrg_uned          ,
          g_acctd_chrg_uned    ,
          g_frt_uned           ,
          g_acctd_frt_uned     ,
          g_tax_uned           ,
          g_acctd_tax_uned     ,
          --
          p_app_rec.APPLICATION_TYPE,
          'RA',
          p_app_rec.receivable_application_id,
          rrc.line_id,
          DECODE(rrc.ref_cust_trx_line_gl_dist_id,-6,'LINE',
                                                  -7,'LINE',
                                                  -9,'LINE',
                                                  -8,'TAX' ),
          --
          g.group_id,
          g.source_data_key1  ,
          g.source_data_key2  ,
          g.source_data_key3  ,
          g.source_data_key4  ,
          g.source_data_key5  ,
          'D',
          p_ae_sys_rec.set_of_books_id,
          p_ae_sys_rec.sob_type,
          rrc.tax_link_id,   -- tax_link_id
          'N'   -- tax_inc_flag
     FROM ar_distributions   rrc,
          (SELECT /*+INDEX (ra_ar_gt ra_ar_n1)*/
		          MAX(group_id)  group_id,
                  --{HYUBPAGP
                  MAX(source_data_key1)  source_data_key1,
                  MAX(source_data_key2)  source_data_key2,
                  MAX(source_data_key3)  source_data_key3,
                  MAX(source_data_key4)  source_data_key4,
                  MAX(source_data_key5)  source_data_key5
                  --}
             FROM ra_ar_gt
            WHERE gt_id                      = p_gt_id
              AND ref_customer_trx_id        = p_customer_trx_id
              AND gp_level                   = 'L')  g,
          ar_adjustments     adj,
          ra_customer_trx    trx
--{Line Charge and Freight boundary
-- Insert freight dist or the charge dist only in the no CHARGES or FREIGHT line exist
-- As by default the boundary on those 2 lines exist only if there are no REV line on the invoice
-- But in the case the CHARGES or FREIGHT exist and we are not maintaining the balance on lines
-- The issue will be the amount applied in FRT or CHRG will get prorated on the initial
-- Freight line and charge line as there is no remaining on REV line for FRT and CHRG 100% of the amount
-- will be on the FRT and CHRG line, if we insert the boundary line here, the amount will be double accounted
--}
    WHERE adj.customer_trx_id              = p_customer_trx_id
      AND adj.adjustment_id                = rrc.source_id
      AND rrc.source_table                 = 'ADJ'
      AND ((rrc.ref_customer_trx_line_id = -6) OR  --Line
           (rrc.ref_customer_trx_line_id = -8) OR  --Tax
           (rrc.ref_customer_trx_line_id = -7 AND g_trx_line_chrg = 'N') OR  --Charges
           (rrc.ref_customer_trx_line_id = -9 AND g_trx_line_frt  = 'N'))    --Freight
      AND (adj.upgrade_method    = 'R12'   OR adj.upgrade_method IS NULL)
      AND adj.customer_trx_id    = trx.customer_trx_id;

   l_rows := sql%rowcount;
   g_appln_count := g_appln_count + l_rows;
   IF PG_DEBUG = 'Y' THEN
   localdebug('  rows inserted = ' || l_rows);
   localdebug('   -->Distribution gotten from adjustment R12 ');
   END IF;


  --{Get the dist from MFAR if required
  IF g_mode_process = 'R12_11IMFAR' THEN
   IF PG_DEBUG = 'Y' THEN
   localdebug('  Mfar 11I legacy to R12 distributions');
   END IF;
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
     DIST_AMT,             --HYUD LINE
     DIST_ACCTD_AMT,       --HYUD LINE
     DIST_CHRG_AMT,        --HYUD CHRG
     DIST_CHRG_ACCTD_AMT,  --HYUD CHRG
     DIST_FRT_AMT,         --HYUD FRT
     DIST_FRT_ACCTD_AMT,   --HYUD FRT
     DIST_TAX_AMT,         --HYUD TAX
     DIST_TAX_ACCTD_AMT,   --HYUD TAX
     --
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
     DIST_uned_AMT                    ,
     DIST_uned_ACCTD_AMT              ,
     DIST_uned_chrg_AMT,
     DIST_uned_chrg_ACCTD_AMT,
     DIST_uned_frt_AMT      ,
     DIST_uned_frt_ACCTD_AMT,
     DIST_uned_tax_AMT      ,
     DIST_uned_tax_ACCTD_AMT,
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
     ref_line_id              ,
     line_type                 ,
     --
     group_id,
     source_data_key1  ,
     source_data_key2  ,
     source_data_key3  ,
     source_data_key4  ,
     source_data_key5  ,
     gp_level,
     set_of_books_id,
     sob_type,
     tax_link_id,
     tax_inc_flag,
     ref_mf_dist_flag
     )
   SELECT /*+INDEX (rar ra_ar_n1)*/
          p_gt_id,                  --gt_id
          NVL(rrc.AMOUNT,0),        --amt in the sign of cor adj dist
          NVL(rrc.AMOUNT,0),        --acctd_amt is iden amt because in mfar world base and trx currency are the same
          ctlgd.account_class,      --account_class
          rrc.mf_adjustment_ccid,   --ccid_secondary
          rrc.cust_trx_line_gl_dist_id,  --ref_cust_trx_line_gl_dist_id no boundary can exist
          ctlgd.customer_trx_line_id,  -- ref_customer_trx_line_id  no boundary can exist
          rar.ref_customer_trx_id,
          rar.to_currency,
          rar.base_currency,
      -- ADJ and APP
         DECODE(ctlgd.account_class,'REV',NVL(rrc.AMOUNT,0),0),   -- DIST_AMT
         DECODE(ctlgd.account_class,'REV',NVL(rrc.AMOUNT,0),0),   -- DIST_ACCTD_AMT
         0,                         -- DIST_CHRG_AMT charges in psa are prorate on other lines
                                    -- need revisit at charge line introduced in AR
         0,                         -- DIST_CHRG_ACCTD_AMT
         DECODE(ctlgd.account_class,'FREIGHT',NVL(rrc.AMOUNT,0),0), -- DIST_FRT_AMT
                                                                    -- frt adjusted in psa are over frt line
         DECODE(ctlgd.account_class,'FREIGHT',NVL(rrc.AMOUNT,0),0), -- DIST_FRT_ACCTD_AMT
                                                                    -- frt adjusted in psa are over frt line
         DECODE(ctlgd.account_class,'TAX',NVL(rrc.AMOUNT,0),0),     -- DIST_TAX_AMT
         DECODE(ctlgd.account_class,'TAX',NVL(rrc.AMOUNT,0),0),     -- DIST_TAX_ACCTD_AMT
         --
         rar.tl_alloc_amt          ,
         rar.tl_alloc_acctd_amt    ,
         rar.tl_chrg_alloc_amt     ,
         rar.tl_chrg_alloc_acctd_amt,
         rar.tl_frt_alloc_amt          ,
         rar.tl_frt_alloc_acctd_amt    ,
         rar.tl_tax_alloc_amt          ,
         rar.tl_tax_alloc_acctd_amt    ,
      -- ED
         -- Elemt Rev
         DECODE(ctlgd.account_class,'REV',NVL(rrc.AMOUNT,0),0),  -- DIST_ED_AMT
         DECODE(ctlgd.account_class,'REV',NVL(rrc.AMOUNT,0),0),  -- DIST_ED_ACCTD_AMT
         -- Elemt Chrg
         0,         -- DIST_ED_CHRG_AMT
         0,         -- DIST_ED_CHRG_ACCTD_AMT
         -- Elemt Frt
         DECODE(ctlgd.account_class,'FREIGHT',NVL(rrc.AMOUNT,0),0),  -- DIST_ED_FRT_AMT
         DECODE(ctlgd.account_class,'FREIGHT',NVL(rrc.AMOUNT,0),0),  -- DIST_ED_FRT_ACCTD_AMT
         -- Elemt Tax
         DECODE(ctlgd.account_class,'TAX',NVL(rrc.AMOUNT,0),0),      -- DIST_ED_TAX_AMT
         DECODE(ctlgd.account_class,'TAX',NVL(rrc.AMOUNT,0),0),      -- DIST_ED_TAX_ACCTD_AMT
         --Bucket
          -- Buc Rev
          rar.tl_ed_alloc_amt          ,
          rar.tl_ed_alloc_acctd_amt    ,
          --Buc Chrg
          rar.tl_ed_chrg_alloc_amt     ,
          rar.tl_ed_chrg_alloc_acctd_amt,
          --Buc Frt
          rar.tl_ed_frt_alloc_amt          ,
          rar.tl_ed_frt_alloc_acctd_amt    ,
          --Buc Tax
          rar.tl_ed_tax_alloc_amt          ,
          rar.tl_ed_tax_alloc_acctd_amt    ,
          --
      -- UNED
         -- Rev Elemt
         DECODE(ctlgd.account_class,'REV',NVL(rrc.AMOUNT,0),0),   -- DIST_UNED_AMT
         DECODE(ctlgd.account_class,'REV',NVL(rrc.AMOUNT,0),0),   -- DIST_UNED_ACCTD_AMT
         -- Chrg Elemt
         0,         -- DIST_UNED_CHRG_AMT
         0,         -- DIST_UNED_CHRG_ACCTD_AMT
         -- Frt Elemt
         DECODE(ctlgd.account_class,'FREIGHT',NVL(rrc.AMOUNT,0),0), -- DIST_UNED_FRT_AMT
         DECODE(ctlgd.account_class,'FREIGHT',NVL(rrc.AMOUNT,0),0), -- DIST_UNED_FRT_ACCTD_AMT
         -- Tax Elemt
         DECODE(ctlgd.account_class,'TAX',NVL(rrc.AMOUNT,0),0),      -- DIST_UNED_TAX_AMT
         DECODE(ctlgd.account_class,'TAX',NVL(rrc.AMOUNT,0),0),      -- DIST_UNED_TAX_ACCTD_AMT
       --Bucket
         -- Rev
         rar.tl_uned_alloc_amt          ,
         rar.tl_uned_alloc_acctd_amt    ,
         --Chrg
         rar.tl_uned_chrg_alloc_amt     ,
         rar.tl_uned_chrg_alloc_acctd_amt,
         --Frt
         rar.tl_uned_frt_alloc_amt          ,
         rar.tl_uned_frt_alloc_acctd_amt    ,
         --Tax
         rar.tl_uned_tax_alloc_amt          ,
         rar.tl_uned_tax_alloc_acctd_amt    ,
         --
          p_app_rec.APPLICATION_TYPE,
          'RA',
          p_app_rec.receivable_application_id,
          -12345,           --ref_line_id -12345 at the insertion time need to interpret the ref_psa_dist_flag
          rar.line_type,
          --
          rar.group_id,
          rar.source_data_key1  ,
          rar.source_data_key2  ,
          rar.source_data_key3  ,
          rar.source_data_key4  ,
          rar.source_data_key5  ,
          'D',
          --BUG#3611016
          p_ae_sys_rec.set_of_books_id,
          p_ae_sys_rec.sob_type,
--          g_se_gt_id,
          DECODE(ctl.line_type,'TAX',ctl.link_to_cust_trx_line_id,
                      'LINE',ctl.customer_trx_line_id,
                      NULL),  -- tax_link_id
          DECODE(ctl.line_type,'TAX','Y',
                     'REV',DECODE(NVL(adj.tax_adjusted,0),0, 'N','Y'),
                     'N'),    -- tax_inc_flag
          'Y'                 -- ref_mf_dist_flag
     FROM ra_ar_gt                    rar,
          psa_mf_adj_dist_all         rrc,
          ra_cust_trx_line_gl_dist    ctlgd,
          ra_customer_trx_lines       ctl,
          ar_adjustments              adj
    WHERE rar.gt_id                      = p_gt_id
      AND rar.ref_customer_trx_id        = p_customer_trx_id
      AND rar.gp_level                   = 'L'
      AND rar.ref_customer_trx_line_id   = ctl.customer_trx_line_id
      AND rar.ref_customer_trx_line_id   = ctlgd.customer_trx_line_id
      AND rar.ref_cust_trx_line_gl_dist_id IS NULL
      AND ctlgd.cust_trx_line_gl_dist_id = rrc.cust_trx_line_gl_dist_id
      AND rrc.adjustment_id              = adj.adjustment_id
      AND adj.upgrade_method                   = '11IMFAR';  -- For adjustment the marks are R12 - 11I (cash) - 11IMFAR (Mfar)

   l_rows := sql%rowcount;
   g_appln_count := g_appln_count + l_rows;
   IF PG_DEBUG = 'Y' THEN
   localdebug('  rows inserted = ' || l_rows);
   localdebug('   -->Distribution gotten from adjustment 11IMFAR ');
   END IF;

   END IF;

   END IF;  -- g_mode_process <> 'R12_11iCASH'
 END IF;

  --Populate base distribution amounts
  INSERT INTO AR_BASE_DIST_AMTS_GT
   ( gt_id
     ,gp_level
     ,ref_customer_trx_id
     ,ref_customer_trx_line_id
     ,base_dist_amt
     ,base_dist_acctd_amt
     ,base_dist_chrg_amt
     ,base_dist_chrg_acctd_amt
     ,base_dist_frt_amt
     ,base_dist_frt_acctd_amt
     ,base_dist_tax_amt
     ,base_dist_tax_acctd_amt
     ,base_ed_dist_amt
     ,base_ed_dist_acctd_amt
     ,base_ed_dist_chrg_amt
     ,base_ed_dist_chrg_acctd_amt
     ,base_ed_dist_frt_amt
     ,base_ed_dist_frt_acctd_amt
     ,base_ed_dist_tax_amt
     ,base_ed_dist_tax_acctd_amt
     ,base_uned_dist_amt
     ,base_uned_dist_acctd_amt
     ,base_uned_dist_chrg_amt
     ,base_uned_dist_chrg_acctd_amt
     ,base_uned_dist_frt_amt
     ,base_uned_dist_frt_acctd_amt
     ,base_uned_dist_tax_amt
     ,base_uned_dist_tax_acctd_amt
     ,set_of_books_id
     ,sob_type)
  SELECT /*+INDEX (b ra_ar_n1)*/
	p_gt_id
	,b.gp_level
	,b.ref_customer_trx_id
	,b.ref_customer_trx_line_id
	-- ADJ and APP
	,SUM(b.dist_amt)                base_dist_amt
	,SUM(b.dist_acctd_amt)          base_dist_acctd_amt
	,SUM(b.dist_chrg_amt)           base_dist_chrg_amt
	,SUM(b.dist_chrg_acctd_amt)     base_dist_chrg_acctd_amt
	,SUM(b.dist_frt_amt)            base_dist_frt_amt
	,SUM(b.dist_frt_acctd_amt)      base_dist_frt_acctd_amt
	,SUM(b.dist_tax_amt)            base_dist_tax_amt
	,SUM(b.dist_tax_acctd_amt)      base_dist_tax_acctd_amt
	-- ED
	,SUM(b.dist_ed_amt)             base_ed_dist_amt
	,SUM(b.dist_ed_acctd_amt)       base_ed_dist_acctd_amt
	,SUM(b.dist_ed_chrg_amt)        base_ed_dist_chrg_amt
	,SUM(b.dist_ed_chrg_acctd_amt)  base_ed_dist_chrg_acctd_amt
	,SUM(b.dist_ed_frt_amt)         base_ed_dist_frt_amt
	,SUM(b.dist_ed_frt_acctd_amt)   base_ed_dist_frt_acctd_amt
	,SUM(b.dist_ed_tax_amt)         base_ed_dist_tax_amt
	,SUM(b.dist_ed_tax_acctd_amt)   base_ed_dist_tax_acctd_amt
	-- UNED
	,SUM(b.dist_uned_amt)             base_uned_dist_amt
	,SUM(b.dist_uned_acctd_amt)       base_uned_dist_acctd_amt
	,SUM(b.dist_uned_chrg_amt)        base_uned_dist_chrg_amt
	,SUM(b.dist_uned_chrg_acctd_amt)  base_uned_dist_chrg_acctd_amt
	,SUM(b.dist_uned_frt_amt)         base_uned_dist_frt_amt
	,SUM(b.dist_uned_frt_acctd_amt)   base_uned_dist_frt_acctd_amt
	,SUM(b.dist_uned_tax_amt)         base_uned_dist_tax_amt
	,SUM(b.dist_uned_tax_acctd_amt)   base_uned_dist_tax_acctd_amt
	,set_of_books_id
	,sob_type
   FROM ra_ar_gt b
   WHERE b.gt_id    = p_gt_id
   AND b.gp_level = 'D'
   AND b.set_of_books_id = p_ae_sys_rec.set_of_books_id
   AND (b.sob_type        = p_ae_sys_rec.sob_type OR
	 (b.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
   AND b.ref_cust_trx_line_gl_dist_id IS NOT NULL
   GROUP BY b.ref_customer_trx_id,
	    b.ref_customer_trx_line_id,
	    b.gp_level,
	    b.sob_type,b.set_of_books_id;

            --

   l_rows := sql%rowcount;
   IF PG_DEBUG = 'Y' THEN
   localdebug('  rows inserted(ar_base_dist_amts_gt) = ' || l_rows);

 localdebug('arp_det_dist_pkg.get_inv_dist()-');
 END IF;
END get_inv_dist;


PROCEDURE update_dist
(p_gt_id             IN VARCHAR2,
 p_customer_trx_id   IN NUMBER,
 p_ae_sys_rec        IN arp_acct_main.ae_sys_rec_type)
IS
  l_rows NUMBER;

  CURSOR c_read_for_line IS
    SELECT /*+ leading (A) index(A ra_ar_n1) INDEX(B ar_base_dist_amts_gt_n1)*/
	       line_type||'-'||a.ref_customer_trx_id||'-'||a.ref_customer_trx_line_id  groupe,
        -- ADJ and APP
           --Base
           b.BASE_dist_AMT,       --Base for Revenue distributions
           b.BASE_dist_ACCTD_AMT,
           b.BASE_dist_frt_AMT,       --Base for freight distributions HYUFR
           b.BASE_dist_frt_ACCTD_AMT,
           b.BASE_dist_tax_AMT,       --Base for tax distributions HYUFRTAX
           b.BASE_dist_tax_ACCTD_AMT,
           b.BASE_dist_chrg_AMT,       --Base for charge distributions
           b.BASE_dist_chrg_ACCTD_AMT,
           --Element
           DIST_AMT,                 --Element for Revenue distributions
           DIST_ACCTD_AMT,
           DIST_frt_AMT,                 --Element for freight distributions
           DIST_frt_ACCTD_AMT,
           DIST_tax_AMT,                 --Element for tax distributions
           DIST_tax_ACCTD_AMT,
           DIST_chrg_AMT,                 --Element for charge distributions
           DIST_chrg_ACCTD_AMT,
           --Amount to be allocated
           tl_alloc_amt,             --Allocation for Revenue distributions
           tl_alloc_acctd_amt,
           tl_frt_alloc_amt,         --Allocation for freight distributions
           tl_frt_alloc_acctd_amt,
           tl_tax_alloc_amt,         --Allocation for tax ditsributions
           tl_tax_alloc_acctd_amt,
           tl_chrg_alloc_amt,        --Allocation for charge distributions
           tl_chrg_alloc_acctd_amt,
        -- ED
           --Base
           b.BASE_ed_dist_AMT,      --Base ED on Rev
           b.BASE_ed_dist_ACCTD_AMT,
           b.BASE_ed_dist_frt_AMT,      --Base ED on Freight HYUFR
           b.BASE_ed_dist_frt_ACCTD_AMT,
           b.BASE_ed_dist_tax_AMT,      --Base ED on Tax HYUFRTAX
           b.BASE_ed_dist_tax_ACCTD_AMT,
           b.BASE_ed_dist_chrg_AMT,      --Base ED on Charge
           b.BASE_ed_dist_chrg_ACCTD_AMT,
           --Element
           DIST_ed_AMT,               --Element ED on Rev
           DIST_ed_ACCTD_AMT,
           DIST_ed_frt_AMT,               --Element ED on Freight HYUFR
           DIST_ed_frt_ACCTD_AMT,
           DIST_ed_tax_AMT,               --Element ED on Tax HYUFRTAX
           DIST_ed_tax_ACCTD_AMT,
           DIST_ed_chrg_AMT,               --Element ED on Charge
           DIST_ed_chrg_ACCTD_AMT,
           --Amount to be allocated
           tl_ed_alloc_amt,           --Allocation ED on Rev
           tl_ed_alloc_acctd_amt,
           tl_ed_frt_alloc_amt,       --Allocation ED on Freight HYUFR
           tl_ed_frt_alloc_acctd_amt,
           tl_ed_tax_alloc_amt,       --Allocation ED on Tax HYUFRTAX
           tl_ed_tax_alloc_acctd_amt,
           tl_ed_chrg_alloc_amt,
           tl_ed_chrg_alloc_acctd_amt,
        -- UNED
           --Base
           b.BASE_uned_dist_AMT,
           b.BASE_uned_dist_ACCTD_AMT,
           b.BASE_uned_dist_frt_AMT,
           b.BASE_uned_dist_frt_ACCTD_AMT,
           b.BASE_uned_dist_tax_AMT,
           b.BASE_uned_dist_tax_ACCTD_AMT,
           b.BASE_uned_dist_chrg_AMT,
           b.BASE_uned_dist_chrg_ACCTD_AMT,
           --Element
           DIST_uned_AMT,
           DIST_uned_ACCTD_AMT,
           DIST_uned_frt_AMT,
           DIST_uned_frt_ACCTD_AMT,
           DIST_uned_tax_AMT,
           DIST_uned_tax_ACCTD_AMT,
           DIST_uned_chrg_AMT,
           DIST_uned_chrg_ACCTD_AMT,
           --Amount to be allocated
           tl_uned_alloc_amt,
           tl_uned_alloc_acctd_amt,
           tl_uned_frt_alloc_amt,
           tl_uned_frt_alloc_acctd_amt,
           tl_uned_tax_alloc_amt,
           tl_uned_tax_alloc_acctd_amt,
           tl_uned_chrg_alloc_amt,
           tl_uned_chrg_alloc_acctd_amt,
           --Currencies
           NVL(BASE_CURRENCY, p_ae_sys_rec.base_currency) ,
           TO_CURRENCY    ,
           FROM_CURRENCY  ,
           -- Rowid
           a.rowid
     FROM  RA_AR_GT a,AR_BASE_DIST_AMTS_GT  b--[bug 6454022]
    WHERE a.gt_id  = p_gt_id
--      AND se_gt_id  = g_se_gt_id
      AND a.ref_customer_trx_id = p_customer_trx_id
      AND a.ref_cust_trx_line_gl_dist_id IS NOT NULL
      AND a.gp_level            = 'D'
      --BUG#3611016
      AND a.set_of_books_id     = p_ae_sys_rec.set_of_books_id
      AND (a.sob_type            = p_ae_sys_rec.sob_type OR (
            a.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
      AND b.gt_id    = a.gt_id
      AND b.gp_level = 'D'
      AND a.ref_customer_trx_id = b.ref_customer_trx_id
      AND a.ref_customer_trx_line_id = b.ref_customer_trx_line_id
      AND b.set_of_books_id     = p_ae_sys_rec.set_of_books_id
      AND (b.sob_type            = p_ae_sys_rec.sob_type OR (
            b.sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
      --source_table is populated in AR_BASE_DIST_AMTS_GT only for online_lazy_apply flow,the condition
      --is modified to restrict duplicate matching pairs [bug 8359020]
      AND nvl( a.source_type,'#$%') =
               DECODE( b.source_table,'CTLGD',nvl(b.source_type,'#$%'),
	               DECODE(b.source_type,null,nvl(a.source_type,'#$%'),b.source_type))
     ORDER BY a.line_type||'-'||a.ref_customer_trx_id||'-'||a.ref_customer_trx_line_id||'-'||a.account_class;

  l_tab  pro_res_tbl_type;

  l_group_tbl            group_tbl_type;
  l_group                VARCHAR2(60)    := 'NOGROUP';

-- ADJ and APP
  l_run_amt              NUMBER          := 0;
  l_run_alloc            NUMBER          := 0;
  l_run_acctd_amt        NUMBER          := 0;
  l_run_acctd_alloc      NUMBER          := 0;
  l_alloc                NUMBER          := 0;
  l_acctd_alloc          NUMBER          := 0;

  l_run_chrg_amt         NUMBER          := 0;
  l_run_chrg_alloc       NUMBER          := 0;
  l_run_chrg_acctd_amt   NUMBER          := 0;
  l_run_chrg_acctd_alloc NUMBER          := 0;
  l_chrg_alloc           NUMBER          := 0;
  l_chrg_acctd_alloc     NUMBER          := 0;

  l_run_frt_amt         NUMBER          := 0;
  l_run_frt_alloc       NUMBER          := 0;
  l_run_frt_acctd_amt   NUMBER          := 0;
  l_run_frt_acctd_alloc NUMBER          := 0;
  l_frt_alloc           NUMBER          := 0;
  l_frt_acctd_alloc     NUMBER          := 0;

  l_run_tax_amt         NUMBER          := 0;
  l_run_tax_alloc       NUMBER          := 0;
  l_run_tax_acctd_amt   NUMBER          := 0;
  l_run_tax_acctd_alloc NUMBER          := 0;
  l_tax_alloc           NUMBER          := 0;
  l_tax_acctd_alloc     NUMBER          := 0;

-- ED
  l_run_ed_amt              NUMBER          := 0;
  l_run_ed_alloc            NUMBER          := 0;
  l_run_ed_acctd_amt        NUMBER          := 0;
  l_run_ed_acctd_alloc      NUMBER          := 0;
  l_ed_alloc                NUMBER          := 0;
  l_ed_acctd_alloc          NUMBER          := 0;

  l_run_ed_chrg_amt         NUMBER          := 0;
  l_run_ed_chrg_alloc       NUMBER          := 0;
  l_run_ed_chrg_acctd_amt   NUMBER          := 0;
  l_run_ed_chrg_acctd_alloc NUMBER          := 0;
  l_ed_chrg_alloc           NUMBER          := 0;
  l_ed_chrg_acctd_alloc     NUMBER          := 0;

  l_run_ed_frt_amt         NUMBER          := 0;
  l_run_ed_frt_alloc       NUMBER          := 0;
  l_run_ed_frt_acctd_amt   NUMBER          := 0;
  l_run_ed_frt_acctd_alloc NUMBER          := 0;
  l_ed_frt_alloc           NUMBER          := 0;
  l_ed_frt_acctd_alloc     NUMBER          := 0;

  l_run_ed_tax_amt         NUMBER          := 0;
  l_run_ed_tax_alloc       NUMBER          := 0;
  l_run_ed_tax_acctd_amt   NUMBER          := 0;
  l_run_ed_tax_acctd_alloc NUMBER          := 0;
  l_ed_tax_alloc           NUMBER          := 0;
  l_ed_tax_acctd_alloc     NUMBER          := 0;

-- UNED
  l_run_uned_amt              NUMBER          := 0;
  l_run_uned_alloc            NUMBER          := 0;
  l_run_uned_acctd_amt        NUMBER          := 0;
  l_run_uned_acctd_alloc      NUMBER          := 0;
  l_uned_alloc                NUMBER          := 0;
  l_uned_acctd_alloc          NUMBER          := 0;

  l_run_uned_chrg_amt         NUMBER          := 0;
  l_run_uned_chrg_alloc       NUMBER          := 0;
  l_run_uned_chrg_acctd_amt   NUMBER          := 0;
  l_run_uned_chrg_acctd_alloc NUMBER          := 0;
  l_uned_chrg_alloc           NUMBER          := 0;
  l_uned_chrg_acctd_alloc     NUMBER          := 0;

  l_run_uned_frt_amt         NUMBER          := 0;
  l_run_uned_frt_alloc       NUMBER          := 0;
  l_run_uned_frt_acctd_amt   NUMBER          := 0;
  l_run_uned_frt_acctd_alloc NUMBER          := 0;
  l_uned_frt_alloc           NUMBER          := 0;
  l_uned_frt_acctd_alloc     NUMBER          := 0;

  l_run_uned_tax_amt         NUMBER          := 0;
  l_run_uned_tax_alloc       NUMBER          := 0;
  l_run_uned_tax_acctd_amt   NUMBER          := 0;
  l_run_uned_tax_acctd_alloc NUMBER          := 0;
  l_uned_tax_alloc           NUMBER          := 0;
  l_uned_tax_acctd_alloc     NUMBER          := 0;

  l_exist                BOOLEAN;
  l_last_fetch           BOOLEAN;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_dist()+');
  localdebug('   p_ae_sys_rec.set_of_books_id :'|| p_ae_sys_rec.set_of_books_id);
  localdebug('   p_ae_sys_rec.sob_type        :'|| p_ae_sys_rec.sob_type);
  END IF;
  OPEN  c_read_for_line;
  LOOP
    FETCH c_read_for_line BULK COLLECT INTO
     l_tab.GROUPE                  ,
  -- ADJ and APP
     -- Base
     l_tab.base_pro_amt       ,
     l_tab.base_pro_acctd_amt ,
     l_tab.BASE_FRT_PRO_AMT       ,
     l_tab.BASE_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_TAX_PRO_AMT       ,
     l_tab.BASE_TAX_PRO_ACCTD_AMT ,
     l_tab.BASE_CHRG_PRO_AMT       ,
     l_tab.BASE_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_pro_amt       ,
     l_tab.elmt_pro_acctd_amt ,
     l_tab.ELMT_FRT_PRO_AMT       ,
     l_tab.ELMT_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_TAX_PRO_AMT       ,
     l_tab.ELMT_TAX_PRO_ACCTD_AMT ,
     l_tab.ELMT_CHRG_PRO_AMT       ,
     l_tab.ELMT_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_alloc_amt      ,
     l_tab.buc_alloc_acctd_amt,
     l_tab.buc_frt_alloc_amt      ,
     l_tab.buc_frt_alloc_acctd_amt,
     l_tab.buc_tax_alloc_amt      ,
     l_tab.buc_tax_alloc_acctd_amt,
     l_tab.buc_chrg_alloc_amt      ,
     l_tab.buc_chrg_alloc_acctd_amt,
  -- ED
     -- Base
     l_tab.base_ed_pro_amt       ,
     l_tab.base_ed_pro_acctd_amt ,
     l_tab.BASE_ed_FRT_PRO_AMT       ,
     l_tab.BASE_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_TAX_PRO_AMT       ,
     l_tab.BASE_ed_TAX_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_CHRG_PRO_AMT       ,
     l_tab.BASE_ed_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_ed_pro_amt       ,
     l_tab.elmt_ed_pro_acctd_amt ,
     l_tab.ELMT_ed_FRT_PRO_AMT       ,
     l_tab.ELMT_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_TAX_PRO_AMT       ,
     l_tab.ELMT_ed_TAX_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_CHRG_PRO_AMT       ,
     l_tab.ELMT_ed_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_ed_alloc_amt      ,
     l_tab.buc_ed_alloc_acctd_amt,
     l_tab.buc_ed_frt_alloc_amt      ,
     l_tab.buc_ed_frt_alloc_acctd_amt,
     l_tab.buc_ed_tax_alloc_amt      ,
     l_tab.buc_ed_tax_alloc_acctd_amt,
     l_tab.buc_ed_chrg_alloc_amt      ,
     l_tab.buc_ed_chrg_alloc_acctd_amt,
  -- UNED
     -- Base
     l_tab.base_uned_pro_amt       ,
     l_tab.base_uned_pro_acctd_amt ,
     l_tab.BASE_uned_FRT_PRO_AMT       ,
     l_tab.BASE_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_TAX_PRO_AMT       ,
     l_tab.BASE_uned_TAX_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_CHRG_PRO_AMT       ,
     l_tab.BASE_uned_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_uned_pro_amt       ,
     l_tab.elmt_uned_pro_acctd_amt ,
     l_tab.ELMT_uned_FRT_PRO_AMT       ,
     l_tab.ELMT_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_TAX_PRO_AMT       ,
     l_tab.ELMT_uned_TAX_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_CHRG_PRO_AMT       ,
     l_tab.ELMT_uned_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_uned_alloc_amt      ,
     l_tab.buc_uned_alloc_acctd_amt,
     l_tab.buc_uned_frt_alloc_amt      ,
     l_tab.buc_uned_frt_alloc_acctd_amt,
     l_tab.buc_uned_tax_alloc_amt      ,
     l_tab.buc_uned_tax_alloc_acctd_amt,
     l_tab.buc_uned_chrg_alloc_amt      ,
     l_tab.buc_uned_chrg_alloc_acctd_amt,
     --
     l_tab.BASE_CURRENCY  ,
     l_tab.TO_CURRENCY    ,
     l_tab.FROM_CURRENCY  ,
     --
     l_tab.ROWID_ID     LIMIT g_bulk_fetch_rows;

     IF c_read_for_line%NOTFOUND THEN
          l_last_fetch := TRUE;
     END IF;

     IF (l_tab.ROWID_ID.COUNT = 0) AND (l_last_fetch) THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug('COUNT = 0 and LAST FETCH ');
       END IF;
       EXIT;
     END IF;

     plsql_proration( x_tab               => l_tab,
                   x_group_tbl            => l_group_tbl,
                 -- ADJ and APP
                   x_run_amt              => l_run_amt,
                   x_run_alloc            => l_run_alloc,
                   x_run_acctd_amt        => l_run_acctd_amt,
                   x_run_acctd_alloc      => l_run_acctd_alloc,
                   x_run_chrg_amt         => l_run_chrg_amt,
                   x_run_chrg_alloc       => l_run_chrg_alloc,
                   x_run_chrg_acctd_amt   => l_run_chrg_acctd_amt,
                   x_run_chrg_acctd_alloc => l_run_chrg_acctd_alloc,
                   x_run_frt_amt         => l_run_frt_amt,
                   x_run_frt_alloc       => l_run_frt_alloc,
                   x_run_frt_acctd_amt   => l_run_frt_acctd_amt,
                   x_run_frt_acctd_alloc => l_run_frt_acctd_alloc,
                   x_run_tax_amt         => l_run_tax_amt,
                   x_run_tax_alloc       => l_run_tax_alloc,
                   x_run_tax_acctd_amt   => l_run_tax_acctd_amt,
                   x_run_tax_acctd_alloc => l_run_tax_acctd_alloc,
                 -- ED
                   x_run_ed_amt              => l_run_ed_amt,
                   x_run_ed_alloc            => l_run_ed_alloc,
                   x_run_ed_acctd_amt        => l_run_ed_acctd_amt,
                   x_run_ed_acctd_alloc      => l_run_ed_acctd_alloc,
                   x_run_ed_chrg_amt         => l_run_ed_chrg_amt,
                   x_run_ed_chrg_alloc       => l_run_ed_chrg_alloc,
                   x_run_ed_chrg_acctd_amt   => l_run_ed_chrg_acctd_amt,
                   x_run_ed_chrg_acctd_alloc => l_run_ed_chrg_acctd_alloc,
                   x_run_ed_frt_amt         => l_run_ed_frt_amt,
                   x_run_ed_frt_alloc       => l_run_ed_frt_alloc,
                   x_run_ed_frt_acctd_amt   => l_run_ed_frt_acctd_amt,
                   x_run_ed_frt_acctd_alloc => l_run_ed_frt_acctd_alloc,
                   x_run_ed_tax_amt         => l_run_ed_tax_amt,
                   x_run_ed_tax_alloc       => l_run_ed_tax_alloc,
                   x_run_ed_tax_acctd_amt   => l_run_ed_tax_acctd_amt,
                   x_run_ed_tax_acctd_alloc => l_run_ed_tax_acctd_alloc,
                 -- UNED
                   x_run_uned_amt              => l_run_uned_amt,
                   x_run_uned_alloc            => l_run_uned_alloc,
                   x_run_uned_acctd_amt        => l_run_uned_acctd_amt,
                   x_run_uned_acctd_alloc      => l_run_uned_acctd_alloc,
                   x_run_uned_chrg_amt         => l_run_uned_chrg_amt,
                   x_run_uned_chrg_alloc       => l_run_uned_chrg_alloc,
                   x_run_uned_chrg_acctd_amt   => l_run_uned_chrg_acctd_amt,
                   x_run_uned_chrg_acctd_alloc => l_run_uned_chrg_acctd_alloc,
                   x_run_uned_frt_amt         => l_run_uned_frt_amt,
                   x_run_uned_frt_alloc       => l_run_uned_frt_alloc,
                   x_run_uned_frt_acctd_amt   => l_run_uned_frt_acctd_amt,
                   x_run_uned_frt_acctd_alloc => l_run_uned_frt_acctd_alloc,
                   x_run_uned_tax_amt         => l_run_uned_tax_amt,
                   x_run_uned_tax_alloc       => l_run_uned_tax_alloc,
                   x_run_uned_tax_acctd_amt   => l_run_uned_tax_acctd_amt,
                   x_run_uned_tax_acctd_alloc => l_run_uned_tax_acctd_alloc);

    FORALL i IN l_tab.ROWID_ID.FIRST .. l_tab.ROWID_ID.LAST
    UPDATE ra_ar_gt
      SET
        -- ADJ and APP
           tl_alloc_amt         = l_tab.tl_alloc_amt(i),
           tl_alloc_acctd_amt   = l_tab.tl_alloc_acctd_amt(i),
           tl_chrg_alloc_amt    = l_tab.tl_chrg_alloc_amt(i),
           tl_chrg_alloc_acctd_amt = l_tab.tl_chrg_alloc_acctd_amt(i),
           tl_frt_alloc_amt       = l_tab.tl_frt_alloc_amt(i),
           tl_frt_alloc_acctd_amt = l_tab.tl_frt_alloc_acctd_amt(i),
           tl_tax_alloc_amt       = l_tab.tl_tax_alloc_amt(i),
           tl_tax_alloc_acctd_amt = l_tab.tl_tax_alloc_acctd_amt(i),
        -- ED
           tl_ed_alloc_amt         = l_tab.tl_ed_alloc_amt(i),
           tl_ed_alloc_acctd_amt   = l_tab.tl_ed_alloc_acctd_amt(i),
           tl_ed_chrg_alloc_amt    = l_tab.tl_ed_chrg_alloc_amt(i),
           tl_ed_chrg_alloc_acctd_amt = l_tab.tl_ed_chrg_alloc_acctd_amt(i),
           tl_ed_frt_alloc_amt       = l_tab.tl_ed_frt_alloc_amt(i),
           tl_ed_frt_alloc_acctd_amt = l_tab.tl_ed_frt_alloc_acctd_amt(i),
           tl_ed_tax_alloc_amt       = l_tab.tl_ed_tax_alloc_amt(i),
           tl_ed_tax_alloc_acctd_amt = l_tab.tl_ed_tax_alloc_acctd_amt(i),
        -- UNED
           tl_uned_alloc_amt         = l_tab.tl_uned_alloc_amt(i),
           tl_uned_alloc_acctd_amt   = l_tab.tl_uned_alloc_acctd_amt(i),
           tl_uned_chrg_alloc_amt    = l_tab.tl_uned_chrg_alloc_amt(i),
           tl_uned_chrg_alloc_acctd_amt = l_tab.tl_uned_chrg_alloc_acctd_amt(i),
           tl_uned_frt_alloc_amt       = l_tab.tl_uned_frt_alloc_amt(i),
           tl_uned_frt_alloc_acctd_amt = l_tab.tl_uned_frt_alloc_acctd_amt(i),
           tl_uned_tax_alloc_amt       = l_tab.tl_uned_tax_alloc_amt(i),
           tl_uned_tax_alloc_acctd_amt = l_tab.tl_uned_tax_alloc_acctd_amt(i)
     WHERE rowid                     = l_tab.ROWID_ID(i);

     l_rows := sql%rowcount;
     IF PG_DEBUG = 'Y' THEN
     localdebug('  rows updated = ' || l_rows);
     END IF;

  END LOOP;
  CLOSE c_read_for_line;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_dist()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  EXCEPTION OTHERS update_dist :'||SQLERRM);
    END IF;
END update_dist;

PROCEDURE create_split_distribution
 (p_pay_adj                IN VARCHAR2,
  p_customer_trx_id        IN NUMBER,
  p_gt_id                  IN VARCHAR2,
  p_app_level              IN VARCHAR2,
  p_ae_sys_rec             IN arp_acct_main.ae_sys_rec_type)
IS
   l_amt    NUMBER;
   l_ind    VARCHAR2(10);
   l_org_id NUMBER;
   l_rows   NUMBER;
BEGIN
IF PG_DEBUG = 'Y' THEN
localdebug('arp_det_dist_pkg.create_split_distribution()+');
localdebug('  p_pay_adj        :'||p_pay_adj);
localdebug('  p_customer_trx_id:'||p_customer_trx_id);
localdebug('  p_app_level      :'||p_app_level);
localdebug('  p_ae_sys_rec.set_of_books_id  :'||p_ae_sys_rec.set_of_books_id);
localdebug('  p_ae_sys_rec.sob_type         :'||p_ae_sys_rec.sob_type);
localdebug('  p_gt_id          :'||p_gt_id);
END IF;

--Monoparsing
IF g_upgrade_mode = 'Y' THEN
  INSERT INTO AR_LINE_APP_DETAIL_GT
       ( DET_ID
         ,APP_LEVEL
         ,GROUP_ID
         ,source_data_key1
         ,source_data_key2
         ,source_data_key3
         ,source_data_key4
         ,source_data_key5
         ,REF_CUSTOMER_TRX_ID
         ,REF_CUSTOMER_TRX_LINE_ID
         ,REF_CUST_TRX_LINE_GL_DIST_ID
         ,REF_LINE_ID
         ,REF_DET_ID
         ,SOURCE_TYPE
         ,SOURCE_TABLE
         ,SOURCE_ID
         ,AMOUNT
         ,ACCTD_AMOUNT
         ,CCID
         ,BASE_CURRENCY
         ,FROM_CURRENCY
         ,TO_CURRENCY
         ,ref_account_class
         ,activity_bucket
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,gt_id
         ,tax_link_id
         ,tax_inc_flag
       ,  ledger_id
       ,  ref_mf_dist_flag
       ,  org_id
       ,  tax_code_id
       ,  location_segment_id
         )
      SELECT /*+INDEX (A ra_ar_n1)*/
	         NULL --ra_ar_s.NEXTVAL,
             ,p_app_level
             ,group_id
             ,source_data_key1
             ,source_data_key2
             ,source_data_key3
             ,source_data_key4
             ,source_data_key5
             ,REF_CUSTOMER_TRX_ID
,DECODE(b.act,'RAADJLINE'   , DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-6,REF_CUSTOMER_TRX_LINE_ID),
             'RAADJFREIGHT', DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-9,REF_CUSTOMER_TRX_LINE_ID),
             'RAADJTAX'    , DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-8,REF_CUSTOMER_TRX_LINE_ID),
             'RAADJCHARGES', DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-7,REF_CUSTOMER_TRX_LINE_ID),
                       REF_CUSTOMER_TRX_LINE_ID)
             ,REF_CUST_TRX_LINE_GL_DIST_ID
             ,REF_LINE_ID
             ,REF_DET_ID
             ,source_type
             ,source_table
             ,source_id
,DECODE(b.act,'RAADJLINE'   , tl_alloc_amt,
             'RAADJFREIGHT', tl_frt_alloc_amt,
             'RAADJTAX'    , tl_tax_alloc_amt,
             'RAADJCHARGES', tl_chrg_alloc_amt,
             'EDLINE'      , tl_ed_alloc_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_amt,
             'EDTAX'       , tl_ed_tax_alloc_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_amt,
             'UNEDLINE'    , tl_uned_alloc_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_amt)
--acctd_alloc
,DECODE(b.act,'RAADJLINE'   , tl_alloc_acctd_amt,
             'RAADJFREIGHT', tl_frt_alloc_acctd_amt,
             'RAADJTAX'    , tl_tax_alloc_acctd_amt,
             'RAADJCHARGES', tl_chrg_alloc_acctd_amt,
             'EDLINE'      , tl_ed_alloc_acctd_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_acctd_amt,
             'EDTAX'       , tl_ed_tax_alloc_acctd_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_acctd_amt,
             'UNEDLINE'    , tl_uned_alloc_acctd_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_acctd_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_acctd_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_acctd_amt)
             ,CCID_SECONDARY
             ,BASE_CURRENCY
             ,FROM_CURRENCY
             ,TO_CURRENCY
--Account_class
,DECODE(b.act,
 'RAADJLINE'   , DECODE(ACCOUNT_CLASS, 'INVOICE','REV',ACCOUNT_CLASS),
 'RAADJFREIGHT', DECODE(ACCOUNT_CLASS, 'INVOICE','FREIGHT',ACCOUNT_CLASS),
 'RAADJTAX'    , DECODE(ACCOUNT_CLASS, 'INVOICE','TAX',ACCOUNT_CLASS),
 'RAADJCHARGES', DECODE(ACCOUNT_CLASS, 'INVOICE','CHARGES',ACCOUNT_CLASS),
          ACCOUNT_CLASS)
--Activity Bucket
,DECODE(b.act,
 'RAADJLINE'   , DECODE(p_pay_adj,'APP','APP_LINE','ADJ','ADJ_LINE',''),
 'RAADJFREIGHT', DECODE(p_pay_adj,'APP','APP_FRT','ADJ','ADJ_FRT',''),
 'RAADJTAX'    , DECODE(p_pay_adj,'APP','APP_TAX','ADJ','ADJ_TAX',''),
 'RAADJCHARGES', DECODE(p_pay_adj,'APP','APP_CHRG','ADJ','ADJ_CHRG',''),
 'EDLINE'      , 'ED_LINE',
 'EDFREIGHT'   , 'ED_FRT',
 'EDTAX'       , 'ED_TAX',
 'EDCHARGES'   , 'ED_CHRG',
 'UNEDLINE'    , 'UNED_LINE',
 'UNEDFREIGHT' , 'UNED_FRT',
 'UNEDTAX'     , 'UNED_TAX',
 'UNEDCHARGES' , 'UNED_CHRG')
             ,SYSDATE
             ,1
             ,1
             ,SYSDATE
             ,1
             ,gt_id
            ,tax_link_id
            ,tax_inc_flag
           , p_ae_sys_rec.set_of_books_id
           , ref_mf_dist_flag
           , g_org_id
           , tax_code_id
           , location_segment_id
        FROM RA_AR_GT                                       a,
	    (SELECT DECODE(ROWNUM,1, 'RAADJLINE',
				 2,'RAADJFREIGHT',
				 3,'RAADJTAX',
				 4,'RAADJCHARGES',
				 5,'EDLINE',
				 6,'EDFREIGHT',
				 7,'EDTAX',
				 8,'EDCHARGES',
				 9,'UNEDLINE',
				 10,'UNEDFREIGHT',
				 11,'UNEDTAX',
				 12,'UNEDCHARGES',NULL) act
	    FROM DUAL CONNECT BY ROWNUM < 13 )  b
       WHERE REF_CUSTOMER_TRX_ID  = p_customer_trx_id
         AND gt_id                = p_gt_id
         AND REF_CUST_TRX_LINE_GL_DIST_ID IS NOT NULL
         AND gp_level             = 'D'
         AND set_of_books_id      = p_ae_sys_rec.set_of_books_id
         AND (sob_type             = p_ae_sys_rec.sob_type OR
                (sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
         AND (( NVL(DECODE(b.act,
             'RAADJLINE'   , tl_alloc_amt,
             'RAADJFREIGHT', tl_frt_alloc_amt,
             'RAADJTAX'    , tl_tax_alloc_amt,
             'RAADJCHARGES', tl_chrg_alloc_amt,
             'EDLINE'      , tl_ed_alloc_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_amt,
             'EDTAX'       , tl_ed_tax_alloc_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_amt,
             'UNEDLINE'    , tl_uned_alloc_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_amt),0)<> 0)
             OR
             ( NVL(DECODE(p_pay_adj||line_type,'ADJTAX', DECODE(b.act,'RAADJTAX',abs(amt)+abs(tl_tax_alloc_amt)),
	                            'APPTAX', DECODE(b.act, 'RAADJTAX',abs(amt)+abs(tl_tax_alloc_amt),
                                               'EDTAX',decode(g_ed_req,'Y',decode(abs(amt)+abs(tl_tax_alloc_amt),0,tl_ed_tax_alloc_amt,1),1),
                                               'UNEDTAX',decode(g_uned_req,'Y',decode(abs(amt)+abs(tl_tax_alloc_amt),0,tl_uned_tax_alloc_amt,1),1))),1)=0)
             OR
             ( NVL(DECODE(b.act,
             'RAADJLINE'   , tl_alloc_acctd_amt,
             'RAADJFREIGHT', tl_frt_alloc_acctd_amt,
             'RAADJTAX'    , tl_tax_alloc_acctd_amt,
             'RAADJCHARGES', tl_chrg_alloc_acctd_amt,
             'EDLINE'      , tl_ed_alloc_acctd_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_acctd_amt,
             'EDTAX'       , tl_ed_tax_alloc_acctd_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_acctd_amt,
             'UNEDLINE'    , tl_uned_alloc_acctd_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_acctd_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_acctd_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_acctd_amt),0)<>0)
	     OR
             ( NVL(DECODE(p_pay_adj||line_type,'ADJTAX', DECODE(b.act,'RAADJTAX',abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt)),
	                            'APPTAX', DECODE(b.act,'RAADJTAX',abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt),
                                               'EDTAX',decode(g_ed_req,'Y',decode(abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt),0,tl_ed_tax_alloc_acctd_amt,1),1),
                                               'UNEDTAX',decode(g_uned_req,'Y',decode(abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt),0,tl_uned_tax_alloc_acctd_amt,1),1))),1)=0));

  -- l_rows := sql%rowcount;
  -- localdebug('  rows inserted = ' || l_rows);
ELSE
  INSERT INTO AR_LINE_APP_DETAIL_GT
       ( DET_ID                       ,
         APP_LEVEL                    ,
         GROUP_ID                     ,
         source_data_key1  ,
         source_data_key2  ,
         source_data_key3  ,
         source_data_key4  ,
         source_data_key5  ,
         REF_CUSTOMER_TRX_ID          ,
         REF_CUSTOMER_TRX_LINE_ID     ,
         REF_CUST_TRX_LINE_GL_DIST_ID ,
         REF_LINE_ID                  ,
         REF_DET_ID                 ,
         SOURCE_TYPE                  ,
         SOURCE_TABLE                 ,
         SOURCE_ID                    ,
         AMOUNT                       ,
         ACCTD_AMOUNT                 ,
         CCID                         ,
         BASE_CURRENCY                ,
         FROM_CURRENCY                ,
         TO_CURRENCY                  ,
         ref_account_class                    ,
         activity_bucket                       ,
         CREATION_DATE                ,
         CREATED_BY                   ,
         LAST_UPDATED_BY              ,
         LAST_UPDATE_DATE             ,
         LAST_UPDATE_LOGIN            ,
         gt_id                        ,
         tax_link_id,
         tax_inc_flag,
         ledger_id,
         ref_mf_dist_flag,
         org_id,
         tax_code_id,
         location_segment_id
         )
      SELECT /*+INDEX (A RA_ar_n1)*/
	         NULL, --ra_ar_s.NEXTVAL,
             p_app_level    ,
             group_id       ,
             source_data_key1  ,
             source_data_key2  ,
             source_data_key3  ,
             source_data_key4  ,
             source_data_key5  ,
             REF_CUSTOMER_TRX_ID          ,
DECODE(b.act,'RAADJLINE'   , DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-6,REF_CUSTOMER_TRX_LINE_ID),
             'RAADJFREIGHT', DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-9,REF_CUSTOMER_TRX_LINE_ID),
             'RAADJTAX'    , DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-8,REF_CUSTOMER_TRX_LINE_ID),
             'RAADJCHARGES', DECODE(REF_CUSTOMER_TRX_LINE_ID,-10,-7,REF_CUSTOMER_TRX_LINE_ID),
                       REF_CUSTOMER_TRX_LINE_ID),
             REF_CUST_TRX_LINE_GL_DIST_ID,
             REF_LINE_ID       ,
             REF_DET_ID        ,
             source_type       ,
             source_table      ,
             source_id         ,
DECODE(b.act,'RAADJLINE'   , tl_alloc_amt,
             'RAADJFREIGHT', tl_frt_alloc_amt,
             'RAADJTAX'    , tl_tax_alloc_amt,
             'RAADJCHARGES', tl_chrg_alloc_amt,
             'EDLINE'      , tl_ed_alloc_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_amt,
             'EDTAX'       , tl_ed_tax_alloc_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_amt,
             'UNEDLINE'    , tl_uned_alloc_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_amt),
--acctd_alloc
DECODE(b.act,'RAADJLINE'   , tl_alloc_acctd_amt,
             'RAADJFREIGHT', tl_frt_alloc_acctd_amt,
             'RAADJTAX'    , tl_tax_alloc_acctd_amt,
             'RAADJCHARGES', tl_chrg_alloc_acctd_amt,
             'EDLINE'      , tl_ed_alloc_acctd_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_acctd_amt,
             'EDTAX'       , tl_ed_tax_alloc_acctd_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_acctd_amt,
             'UNEDLINE'    , tl_uned_alloc_acctd_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_acctd_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_acctd_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_acctd_amt),
             CCID_SECONDARY,
             BASE_CURRENCY,
             FROM_CURRENCY,
             TO_CURRENCY,
--Account_class
DECODE(b.act,
 'RAADJLINE'   , DECODE(ACCOUNT_CLASS, 'INVOICE','REV',ACCOUNT_CLASS),
 'RAADJFREIGHT', DECODE(ACCOUNT_CLASS, 'INVOICE','FREIGHT',ACCOUNT_CLASS),
 'RAADJTAX'    , DECODE(ACCOUNT_CLASS, 'INVOICE','TAX',ACCOUNT_CLASS),
 'RAADJCHARGES', DECODE(ACCOUNT_CLASS, 'INVOICE','CHARGES',ACCOUNT_CLASS),
          ACCOUNT_CLASS),
--Activity Bucket
DECODE(b.act,
 'RAADJLINE'   , DECODE(p_pay_adj,'APP','APP_LINE','ADJ','ADJ_LINE',''),
 'RAADJFREIGHT', DECODE(p_pay_adj,'APP','APP_FRT','ADJ','ADJ_FRT',''),
 'RAADJTAX'    , DECODE(p_pay_adj,'APP','APP_TAX','ADJ','ADJ_TAX',''),
 'RAADJCHARGES', DECODE(p_pay_adj,'APP','APP_CHRG','ADJ','ADJ_CHRG',''),
 'EDLINE'      , 'ED_LINE',
 'EDFREIGHT'   , 'ED_FRT',
 'EDTAX'       , 'ED_TAX',
 'EDCHARGES'   , 'ED_CHRG',
 'UNEDLINE'    , 'UNED_LINE',
 'UNEDFREIGHT' , 'UNED_FRT',
 'UNEDTAX'     , 'UNED_TAX',
 'UNEDCHARGES' , 'UNED_CHRG'),
             SYSDATE,
             arp_standard.profile.user_id,
             arp_standard.profile.user_id,
             SYSDATE,
             arp_standard.profile.last_update_login,
             gt_id,
            tax_link_id,
            tax_inc_flag,
            p_ae_sys_rec.set_of_books_id,
            ref_mf_dist_flag,
            arp_standard.sysparm.org_id,
            tax_code_id,
            location_segment_id
        FROM RA_AR_GT                                       a,
	    (SELECT DECODE(ROWNUM,1, 'RAADJLINE',
				 2,'RAADJFREIGHT',
				 3,'RAADJTAX',
				 4,'RAADJCHARGES',
				 5,'EDLINE',
				 6,'EDFREIGHT',
				 7,'EDTAX',
				 8,'EDCHARGES',
				 9,'UNEDLINE',
				 10,'UNEDFREIGHT',
				 11,'UNEDTAX',
				 12,'UNEDCHARGES',NULL) act
	    FROM DUAL CONNECT BY ROWNUM < 13 )  b
       WHERE REF_CUSTOMER_TRX_ID  = p_customer_trx_id
         AND gt_id                = p_gt_id
         AND REF_CUST_TRX_LINE_GL_DIST_ID IS NOT NULL
         AND gp_level             = 'D'
         AND set_of_books_id      = p_ae_sys_rec.set_of_books_id
         AND (sob_type             = p_ae_sys_rec.sob_type OR
                (sob_type IS NULL AND p_ae_sys_rec.sob_type IS NULL))
         AND (( NVL(DECODE(b.act,
             'RAADJLINE'   , tl_alloc_amt,
             'RAADJFREIGHT', tl_frt_alloc_amt,
             'RAADJTAX'    , tl_tax_alloc_amt,
             'RAADJCHARGES', tl_chrg_alloc_amt,
             'EDLINE'      , tl_ed_alloc_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_amt,
             'EDTAX'       , tl_ed_tax_alloc_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_amt,
             'UNEDLINE'    , tl_uned_alloc_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_amt),0)<> 0)
             OR
             ( NVL(DECODE(p_pay_adj||line_type,'ADJTAX', DECODE(b.act,'RAADJTAX',abs(amt)+abs(tl_tax_alloc_amt)),
	                            'APPTAX', DECODE(b.act, 'RAADJTAX',abs(amt)+abs(tl_tax_alloc_amt),
                                                'EDTAX',decode(g_ed_req,'Y',decode(abs(amt)+abs(tl_tax_alloc_amt),0,tl_ed_tax_alloc_amt,1),1),
                                                'UNEDTAX',decode(g_uned_req,'Y',decode(abs(amt)+abs(tl_tax_alloc_amt),0,tl_uned_tax_alloc_amt,1),1))),1)=0)
             OR
             ( NVL(DECODE(b.act,
             'RAADJLINE'   , tl_alloc_acctd_amt,
             'RAADJFREIGHT', tl_frt_alloc_acctd_amt,
             'RAADJTAX'    , tl_tax_alloc_acctd_amt,
             'RAADJCHARGES', tl_chrg_alloc_acctd_amt,
             'EDLINE'      , tl_ed_alloc_acctd_amt,
             'EDFREIGHT'   , tl_ed_frt_alloc_acctd_amt,
             'EDTAX'       , tl_ed_tax_alloc_acctd_amt,
             'EDCHARGES'   , tl_ed_chrg_alloc_acctd_amt,
             'UNEDLINE'    , tl_uned_alloc_acctd_amt,
             'UNEDFREIGHT' , tl_uned_frt_alloc_acctd_amt,
             'UNEDTAX'     , tl_uned_tax_alloc_acctd_amt,
             'UNEDCHARGES' , tl_uned_chrg_alloc_acctd_amt),0)<>0)
	     OR
             ( NVL(DECODE(p_pay_adj||line_type,'ADJTAX', DECODE(b.act,'RAADJTAX',abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt)),
	                            'APPTAX', DECODE(b.act, 'RAADJTAX',abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt),
                                                'EDTAX',decode(g_ed_req,'Y',decode(abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt),0,tl_ed_tax_alloc_acctd_amt,1),1),
                                                'UNEDTAX',decode(g_uned_req,'Y',decode(abs(acctd_amt)+abs(tl_tax_alloc_acctd_amt),0,tl_uned_tax_alloc_acctd_amt,1),1))),1)=0));

       l_rows := sql%rowcount;
       IF PG_DEBUG = 'Y' THEN
       localdebug('  rows inserted = ' || l_rows);
       END IF;
END IF;

--{Taxable_amount
/*update_taxable
(p_gt_id             => p_gt_id,
 p_customer_trx_id   => p_customer_trx_id,
 p_ae_sys_rec        => p_ae_sys_rec);*/
--}

    UPDATE /*+INDEX (AR_LINE_APP_DETAIL_GT AR_LINE_APP_DETAIL_GT_N1 */
       AR_LINE_APP_DETAIL_GT app_out
       SET (taxable_amount, taxable_acctd_amount)
       =
       (SELECT /*+INDEX (AR_LINE_APP_DETAIL_GT AR_LINE_APP_DETAIL_GT_N1 */
                  DECODE(app_out.activity_bucket, 'APP_TAX',
                              SUM(DECODE(activity_bucket,'APP_LINE',amount,
                                                         'ADJ_LINE',amount,
                                                         'APP_CHRG',amount,
                                                         'ADJ_CHRG',amount,
                                                         'APP_FRT' ,amount,
                                                         'ADJ_FRT' ,amount, 0)),
                                                  'ADJ_TAX',
                              SUM(DECODE(activity_bucket,'APP_LINE',amount,
                                                         'ADJ_LINE',amount,
                                                         'APP_CHRG',amount,
                                                         'ADJ_CHRG',amount,
                                                         'APP_FRT' ,amount,
                                                         'ADJ_FRT' ,amount, 0)),
                                                  'ED_TAX',
                              SUM(DECODE(activity_bucket,'ED_LINE',amount,
                                                         'ED_CHRG',amount,
                                                         'ED_FRT' ,amount, 0)),
                                                  'UNED_TAX',
                              SUM(DECODE(activity_bucket,'UNED_LINE',amount,
                                                         'UNED_CHRG',amount,
                                                         'UNED_FRT' ,amount, 0)),0) taxable_amount,
                  DECODE(app_out.activity_bucket, 'APP_TAX',
                              SUM(DECODE(activity_bucket,'APP_LINE',acctd_amount,
                                                         'ADJ_LINE',acctd_amount,
                                                         'APP_CHRG',acctd_amount,
                                                         'ADJ_CHRG',acctd_amount,
                                                         'APP_FRT' ,acctd_amount,
                                                         'ADJ_FRT' ,acctd_amount, 0)),
                                                  'ADJ_TAX',
                              SUM(DECODE(activity_bucket,'APP_LINE',acctd_amount,
                                                         'ADJ_LINE',acctd_amount,
                                                         'APP_CHRG',acctd_amount,
                                                         'ADJ_CHRG',acctd_amount,
                                                         'APP_FRT' ,acctd_amount,
                                                         'ADJ_FRT' ,acctd_amount, 0)),
                                                  'ED_TAX',
                              SUM(DECODE(activity_bucket,'ED_LINE',acctd_amount,
                                                         'ED_CHRG',acctd_amount,
                                                         'ED_FRT' ,acctd_amount, 0)),
                                                  'UNED_TAX',
                              SUM(DECODE(activity_bucket,'UNED_LINE',acctd_amount,
                                                         'UNED_CHRG',acctd_amount,
                                                         'UNED_FRT' ,acctd_amount, 0)),0) taxable_acctd_amount
        FROM AR_LINE_APP_DETAIL_GT  app_in
         WHERE gt_id = p_gt_id
         AND ref_customer_trx_id = p_customer_trx_id
         AND tax_link_id           IS NOT NULL
         AND tax_link_id         = app_out.tax_link_id)
    WHERE gt_id  = p_gt_id
      AND ref_customer_trx_id = p_customer_trx_id
      AND tax_link_id         IS NOT NULL
      AND DECODE(ref_account_class,'REV',tax_inc_flag,
                           'FREIGHT',tax_inc_flag,
                           'TAX','Y','N')  = 'Y';

IF PG_DEBUG = 'Y' THEN
localdebug('arp_det_dist_pkg.create_split_distribution()-');
END IF;
EXCEPTION
WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('  EXCEPTION OTHERS : create_split_distribution :'||SQLERRM);
  END IF;
END create_split_distribution;


PROCEDURE set_original_rem_amt_r12
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 x_return_status    IN OUT NOCOPY VARCHAR2,
 x_msg_count        IN OUT NOCOPY NUMBER,
 x_msg_data         IN OUT NOCOPY VARCHAR2,
 p_from_llca        IN VARCHAR2 DEFAULT 'N')
IS
  CURSOR c(p_customer_trx_id  IN NUMBER) IS
  SELECT SUM(AMOUNT),
         SUM(ACCTD_AMOUNT),
         customer_trx_line_id
    FROM ra_cust_trx_line_gl_dist
   WHERE customer_trx_id  = p_customer_trx_id
   GROUP BY customer_trx_line_id;

  l_amt_tab                   DBMS_SQL.NUMBER_TABLE;
  l_acctd_amt_tab             DBMS_SQL.NUMBER_TABLE;
  l_ctl_tab                   DBMS_SQL.NUMBER_TABLE;
  l_last_fetch                BOOLEAN := FALSE;
  l_found                     VARCHAR2(1) := 'N';
  l_trx_type                  VARCHAR2(30);
  l_c                             c%ROWTYPE;
  no_a_valid_trx              EXCEPTION;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.set_original_rem_amt_r12()+');
  localdebug('     p_customer_trx.customer_trx_id:'||p_customer_trx.customer_trx_id);
  END IF;
    OPEN c(p_customer_trx.customer_trx_id);
    LOOP
    FETCH c BULK COLLECT INTO l_amt_tab,
                              l_acctd_amt_tab,
                              l_ctl_tab
                    LIMIT g_bulk_fetch_rows;

       IF c%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

       IF (l_ctl_tab.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG = 'Y' THEN
	 localdebug('  COUNT = 0 and LAST FETCH ');
	 END IF;
         EXIT;
       END IF;
       l_found := 'Y';

       IF PG_DEBUG = 'Y' THEN
       localdebug('  Setting the Original and Remaining amounts R12');
       END IF;

       FORALL i IN l_ctl_tab.FIRST .. l_ctl_tab.LAST
       UPDATE ra_customer_trx_lines
          SET AMOUNT_DUE_REMAINING        = l_amt_tab(i),
              ACCTD_AMOUNT_DUE_REMAINING  = l_acctd_amt_tab(i),
              AMOUNT_DUE_ORIGINAL         = l_amt_tab(i),
              ACCTD_AMOUNT_DUE_ORIGINAL   = l_acctd_amt_tab(i),
              CHRG_AMOUNT_REMAINING       = 0,
              CHRG_ACCTD_AMOUNT_REMAINING = 0,
              FRT_ADJ_REMAINING           = 0,
              FRT_ADJ_ACCTD_REMAINING     = 0,
              FRT_ED_AMOUNT               = 0,
              FRT_ED_ACCTD_AMOUNT         = 0,
              FRT_UNED_AMOUNT             = 0,
              FRT_UNED_ACCTD_AMOUNT       = 0
        WHERE customer_trx_line_id        = l_ctl_tab(i);
    END LOOP;
    CLOSE c;

     IF l_found = 'N' THEN
	RAISE no_a_valid_trx;
     END IF;

	  IF PG_DEBUG = 'Y' THEN
	  localdebug('Setting transaction.upgrade_method to R12' );
	  END IF;
          UPDATE ra_customer_trx SET upgrade_method = 'R12'
          WHERE customer_trx_id = p_customer_trx.customer_trx_id;

   IF PG_DEBUG = 'Y' THEN
   localdebug('arp_det_dist_pkg.set_original_rem_amt_r12()-');
   END IF;

EXCEPTION
WHEN no_a_valid_trx  THEN
    IF c%ISOPEN THEN CLOSE c; END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug('EXCEPTION no_a_valid_trx :'||p_customer_trx.customer_trx_id);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
   FND_MESSAGE.SET_TOKEN( 'TEXT', 'EXCEPTION Not a Valid Trx ID');
   FND_MSG_PUB.ADD;
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
  WHEN OTHERS THEN
    IF c%ISOPEN THEN CLOSE c; END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug('EXCEPTION OTHERS in set_original_rem_amt_r12 :'||SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := 'EXCEPTION OTHERS in set_original_rem_amt_r12 :'||SQLERRM;
END set_original_rem_amt_r12;



PROCEDURE set_original_rem_amt_mfar
(p_customer_trx     IN ra_customer_trx%ROWTYPE)
IS
  CURSOR cmfar(p_customer_trx_id  IN NUMBER)  IS
  SELECT SUM(NVL(amount_due_remaining,0)) sum_due_rem,
         SUM(NVL(amount_due_original,0))  sum_due_orig,
         customer_trx_line_id             customer_trx_line_id
    FROM psa_mf_balances_view
   WHERE customer_trx_id      = p_customer_trx_id
   GROUP BY customer_trx_line_id;
  l_rem_amt_tab               DBMS_SQL.NUMBER_TABLE;
  l_orig_amt_tab              DBMS_SQL.NUMBER_TABLE;
  l_ctl_tab                   DBMS_SQL.NUMBER_TABLE;
  l_last_fetch                BOOLEAN := FALSE;
  l_found                     VARCHAR2(1);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.set_original_rem_amt_mfar()+');
  localdebug('    p_customer_trx.customer_trx_id:'||p_customer_trx.customer_trx_id);
  END IF;

    OPEN cmfar(p_customer_trx.customer_trx_id);
    LOOP
    FETCH cmfar BULK COLLECT INTO l_rem_amt_tab,    --for mfar remaining
                                  l_orig_amt_tab,   --for mfar original
                                  l_ctl_tab
                    LIMIT g_bulk_fetch_rows;

       IF cmfar%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

       IF (l_ctl_tab.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG = 'Y' THEN
	 localdebug('  COUNT = 0 and LAST FETCH ');
	 END IF;
         EXIT;
       END IF;

       IF PG_DEBUG = 'Y' THEN
       localdebug('  Setting the Original and Remaining amounts MFAR');
       END IF;

       FORALL i IN l_ctl_tab.FIRST .. l_ctl_tab.LAST
       UPDATE ra_customer_trx_lines
          SET AMOUNT_DUE_REMAINING        = l_rem_amt_tab(i),   -- Rem
              ACCTD_AMOUNT_DUE_REMAINING  = l_rem_amt_tab(i),   -- Rem transaction currency = functional
              AMOUNT_DUE_ORIGINAL         = l_orig_amt_tab(i),  -- original
              ACCTD_AMOUNT_DUE_ORIGINAL   = l_orig_amt_tab(i),  -- original
              CHRG_AMOUNT_REMAINING       = 0,
              CHRG_ACCTD_AMOUNT_REMAINING = 0,
              FRT_ADJ_REMAINING           = 0,
              FRT_ADJ_ACCTD_REMAINING     = 0,
              FRT_ED_AMOUNT               = 0,
              FRT_ED_ACCTD_AMOUNT         = 0,
              FRT_UNED_AMOUNT             = 0,
              FRT_UNED_ACCTD_AMOUNT       = 0
        WHERE customer_trx_line_id        = l_ctl_tab(i);

    END LOOP;
    CLOSE cmfar;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.set_original_rem_amt_mfar()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF cmfar%ISOPEN THEN CLOSE cmfar; END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  EXCEPTION OTHERS in set_original_rem_amt_mfar :'||SQLERRM);
    END IF;
END set_original_rem_amt_mfar;



PROCEDURE  re_calcul_rem_amt(p_customer_trx IN ra_customer_trx%ROWTYPE)
IS

/*bug6133206, multiplied APP amounts with '-1' to make them negative,
  for calculating the remaining amounts. */

CURSOR cu_rem_amt(p_customer_trx_id IN NUMBER) IS
 SELECT b.sum_orig                                                          sum_orig
       ,b.sum_acctd_orig                                                    sum_acctd_orig
       ,SUM((DECODE(a.activity_bucket,'ADJ_CHRG',amt
                    ,'APP_CHRG',DECODE(a.line_type,'LINE',amt,0) * -1,0)))       CHRG_ON_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'ADJ_CHRG',acctd_amt
                    ,'APP_CHRG',DECODE(a.line_type,'LINE',acctd_amt,0) * -1,0))) ACCTD_CHRG_ON_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'ADJ_FRT',amt
                    ,'APP_FRT',DECODE(a.line_type,'LINE',amt,0) * -1,0)))        FRT_ON_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'ADJ_FRT',amt
                    ,'APP_FRT',DECODE(a.line_type,'LINE',acctd_amt,0) * -1,0)))  ACCTD_FRT_ON_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'ED_FRT',amt,0)))                              ED_FRT_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'ED_FRT',acctd_amt,0)))                        ACCTD_ED_FRT_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'UNED_FRT',amt,0)))                            UNED_FRT_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'UNED_FRT',acctd_amt,0)))                      ACCTD_UNED_FRT_REV_LINE
       ,SUM((DECODE(a.activity_bucket,'ADJ_LINE',amt
                            ,'APP_LINE',(amt * -1)
                            ,'ED_LINE' ,amt
                            ,'UNED_LINE',amt -- line
                            ,'ADJ_TAX' ,amt
                            ,'APP_TAX' ,(amt * -1)
                            ,'ED_TAX' ,amt
                            ,'UNED_TAX',amt  --tax
                            ,'APP_FRT' ,(DECODE(a.line_type,'FREIGHT',amt,0) * -1)
                            ,'APP_CHRG',(DECODE(a.line_type,'CHARGES',amt,0) * -1)
                            ,0)))                                           REM_TYPE_LINE
       ,SUM((DECODE(a.activity_bucket,'ADJ_LINE',acctd_amt
                            ,'APP_LINE',(acctd_amt * -1)
                            ,'ED_LINE' ,acctd_amt
                            ,'UNED_LINE',acctd_amt -- line
                            ,'ADJ_TAX' ,acctd_amt
                            ,'APP_TAX' ,(acctd_amt * -1)
                            ,'ED_TAX' ,acctd_amt
                            ,'UNED_TAX',acctd_amt  --tax
                            ,'APP_FRT' ,(DECODE(a.line_type,'FREIGHT',acctd_amt,0) * -1)
                            ,'APP_CHRG',(DECODE(a.line_type,'CHARGES',acctd_amt,0) * -1)
                            ,0)))                                           ACCTD_REM_TYPE_LINE
       ,b.customer_trx_line_id                                              CUSTOMER_TRX_LINE_ID
FROM
(SELECT SUM( NVL(ard.amount_cr,0)       - NVL(ard.amount_dr,0)      ) amt,
       SUM( NVL(ard.acctd_amount_cr,0) - NVL(ard.acctd_amount_dr,0)) acctd_amt,
       ard.ref_customer_trx_line_id,
       ard.ref_account_class,
       ard.activity_bucket,
       ctl.line_type
  FROM ar_distributions      ard,
       ra_customer_trx_lines ctl
 WHERE ctl.customer_trx_id      = p_customer_trx_id
   AND ctl.customer_trx_line_id = ard.ref_customer_trx_line_id
 GROUP BY
       ard.ref_customer_trx_line_id,
       ard.ref_account_class,
       ard.activity_bucket,
       ctl.line_type) a,
(SELECT SUM(AMOUNT)          sum_orig,
        SUM(ACCTD_AMOUNT)    sum_acctd_orig,
        customer_trx_line_id
   FROM ra_cust_trx_line_gl_dist
  WHERE customer_trx_id  = p_customer_trx_id
  GROUP BY customer_trx_line_id) b
WHERE a.ref_customer_trx_line_id (+) =  b.customer_trx_line_id
GROUP BY b.customer_trx_line_id,
         b.sum_orig,
         b.sum_acctd_orig;

l_sum_orig                     DBMS_SQL.NUMBER_TABLE;
l_sum_acctd_orig               DBMS_SQL.NUMBER_TABLE;
l_CHRG_ON_REV_LINE             DBMS_SQL.NUMBER_TABLE;
l_ACCTD_CHRG_ON_REV_LINE       DBMS_SQL.NUMBER_TABLE;
l_FRT_ON_REV_LINE              DBMS_SQL.NUMBER_TABLE;
l_ACCTD_FRT_ON_REV_LINE        DBMS_SQL.NUMBER_TABLE;
l_ED_FRT_REV_LINE              DBMS_SQL.NUMBER_TABLE;
l_ACCTD_ED_FRT_REV_LINE        DBMS_SQL.NUMBER_TABLE;
l_UNED_FRT_REV_LINE            DBMS_SQL.NUMBER_TABLE;
l_ACCTD_UNED_FRT_REV_LINE      DBMS_SQL.NUMBER_TABLE;
l_REM_TYPE_LINE                DBMS_SQL.VARCHAR2_TABLE;
l_ACCTD_REM_TYPE_LINE          DBMS_SQL.NUMBER_TABLE;
l_CUSTOMER_TRX_LINE_ID         DBMS_SQL.NUMBER_TABLE;

l_last_fetch                   BOOLEAN := FALSE;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.re_calcul_rem_amt()+');
  localdebug('p_customer_trx_id = ' || p_customer_trx.customer_trx_id);
  END IF;
  OPEN cu_rem_amt(p_customer_trx.customer_trx_id);
  LOOP
    FETCH cu_rem_amt BULK COLLECT INTO
              l_sum_orig              ,
              l_sum_acctd_orig        ,
              l_chrg_on_rev_line      ,
              l_acctd_chrg_on_rev_line,
              l_frt_on_rev_line       ,
              l_acctd_frt_on_rev_line ,
              l_ed_frt_rev_line       ,
              l_acctd_ed_frt_rev_line ,
              l_uned_frt_rev_line     ,
              l_acctd_uned_frt_rev_line,
              l_rem_type_line         ,
              l_acctd_rem_type_line   ,
              l_customer_trx_line_id
            LIMIT g_bulk_fetch_rows;

     IF cu_rem_amt%NOTFOUND THEN
          l_last_fetch := TRUE;
     END IF;

     IF (l_CUSTOMER_TRX_LINE_ID.COUNT = 0) AND (l_last_fetch) THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug('COUNT = 0 and LAST FETCH ');
       END IF;
       EXIT;
     END IF;

     FORALL i IN l_CUSTOMER_TRX_LINE_ID.FIRST .. l_CUSTOMER_TRX_LINE_ID.LAST
     UPDATE ra_customer_trx_lines
        SET amount_due_original         = l_sum_orig(i),
            acctd_amount_due_original   = l_sum_acctd_orig(i),
		    AMOUNT_DUE_REMAINING        = l_sum_orig(i) + l_REM_TYPE_LINE(i),
            ACCTD_AMOUNT_DUE_REMAINING  = l_sum_acctd_orig(i) + l_ACCTD_REM_TYPE_LINE(i),
            CHRG_AMOUNT_REMAINING       = l_chrg_on_rev_line(i),
            CHRG_ACCTD_AMOUNT_REMAINING = l_ACCTD_chrg_on_rev_line(i),
            FRT_ADJ_REMAINING           = l_FRT_ON_REV_LINE(i),
            FRT_ADJ_ACCTD_REMAINING     = l_ACCTD_FRT_ON_REV_LINE(i),
            frt_ed_amount               = l_ED_FRT_REV_LINE(i),
            frt_ed_acctd_amount         = l_ACCTD_ED_FRT_REV_LINE(i),
            frt_uned_amount             = l_UNED_FRT_REV_LINE(i),
            frt_uned_acctd_amount       = l_ACCTD_UNED_FRT_REV_LINE(i)
      WHERE customer_trx_line_id        = l_CUSTOMER_TRX_LINE_ID(i)
        AND customer_trx_id             = p_customer_trx.customer_trx_id;
   END LOOP;
   CLOSE cu_rem_amt;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.re_calcul_rem_amt()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug(' EXCEPTION OTHERS re_calcul_rem_amt :'|| SQLERRM);
    END IF;
    RAISE;
END re_calcul_rem_amt;


/* For AUTOINV call, Overloaded call*/

PROCEDURE set_original_rem_amt_r12(p_request_id IN NUMBER)
AS

-- Get all invoices / debit memos which need balance stamping
--
CURSOR c01  IS
SELECT
      SUM(gld.AMOUNT),
      SUM(gld.ACCTD_AMOUNT),
      gld.customer_trx_line_id,
      inv.customer_trx_id
FROM
      ra_customer_trx inv,
      ra_cust_trx_line_gl_dist gld,
      ra_cust_trx_types ctt
WHERE inv.customer_trx_id = gld.customer_trx_id
      AND ctt.CUST_TRX_TYPE_ID = inv.CUST_TRX_TYPE_ID
      AND inv.request_id         = p_request_id
      AND ctt.TYPE in ('INV','DM')
GROUP BY gld.customer_trx_line_id,inv.customer_trx_id;

CURSOR c02  IS
SELECT
     customer_trx_id
FROM
     ra_customer_trx inv,
     ra_cust_trx_types ctt
WHERE request_id = P_request_id
      AND ctt.CUST_TRX_TYPE_ID = inv.CUST_TRX_TYPE_ID
      AND ctt.TYPE in ('INV','DM')
      AND EXISTS
	(SELECT 1
	 FROM ar_receivable_applications ar
	 WHERE ar.applied_customer_trx_id = inv.customer_trx_id
	 UNION
	 SELECT 1
	 FROM ar_adjustments ad
	 WHERE ad.customer_trx_id = inv.customer_trx_id
	);



  l_amt_tab                   DBMS_SQL.NUMBER_TABLE;
  l_acctd_amt_tab             DBMS_SQL.NUMBER_TABLE;
  l_ctl_tab                   DBMS_SQL.NUMBER_TABLE;
  l_ctl_hd_tab		      DBMS_SQL.NUMBER_TABLE;
  l_ctl_app_tab		      DBMS_SQL.NUMBER_TABLE;
  l_customer_trx              ra_customer_trx%ROWTYPE;
  l_last_fetch                BOOLEAN := FALSE;

  l_msg                   RA_INTERFACE_ERRORS.MESSAGE_TEXT%TYPE;
  l_return_status         VARCHAR2(100);
  l_msg_count             NUMBER:=0;
  l_msg_data              VARCHAR2(20000):= NULL;

BEGIN

 IF PG_DEBUG = 'Y' THEN
 localdebug('arp_det_dist_pkg.set_original_rem_amt_r12() OVERLOAD +');
 END IF;


   OPEN c01;
    LOOP
    FETCH c01 BULK COLLECT INTO l_amt_tab,
                              l_acctd_amt_tab,
                              l_ctl_tab,
			      l_ctl_hd_tab
                    LIMIT g_bulk_fetch_rows;

      IF c01%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

        IF (l_ctl_tab.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG = 'Y' THEN
	 localdebug('  COUNT = 0 and LAST FETCH ');
	 END IF;
        EXIT;
	END IF;


	       IF PG_DEBUG = 'Y' THEN
	       localdebug('  Setting the Original R12');
	       END IF;
	/*FORALL*/
       FOR i IN l_ctl_tab.FIRST .. l_ctl_tab.LAST
       LOOP
	  BEGIN
		       UPDATE ra_customer_trx_lines
			  SET AMOUNT_DUE_REMAINING        = l_amt_tab(i),
			      ACCTD_AMOUNT_DUE_REMAINING  = l_acctd_amt_tab(i),
			      AMOUNT_DUE_ORIGINAL         = l_amt_tab(i),
			      ACCTD_AMOUNT_DUE_ORIGINAL   = l_acctd_amt_tab(i),
			      CHRG_AMOUNT_REMAINING       = 0,
			      CHRG_ACCTD_AMOUNT_REMAINING = 0,
			      FRT_ADJ_REMAINING           = 0,
			      FRT_ADJ_ACCTD_REMAINING     = 0,
			      FRT_ED_AMOUNT               = 0,
			      FRT_ED_ACCTD_AMOUNT         = 0,
			      FRT_UNED_AMOUNT             = 0,
			      FRT_UNED_ACCTD_AMOUNT       = 0
			WHERE customer_trx_line_id        = l_ctl_tab(i);
	 EXCEPTION
	  WHEN OTHERS THEN
			    IF PG_DEBUG in ('Y', 'C') THEN
			       arp_standard.debug('Inserting into errors...');
			    END IF;

			    IF c01%ISOPEN THEN CLOSE c01; END IF;

			   l_msg := 'Error while stamping the balance amt'||l_ctl_hd_tab(i);


			    INSERT INTO ra_interface_errors
				   (
				   --org_id,
				   interface_line_id,
				   message_text
				   )
			    SELECT
				   --org_id,
				   customer_trx_line_id,
				   l_msg
			    FROM
				   ra_customer_trx_lines lines
			    WHERE
				   lines.customer_trx_id = l_ctl_hd_tab(i);
	 END;
	 END LOOP;

    END LOOP;
 CLOSE c01;


	  IF PG_DEBUG = 'Y' THEN
	  localdebug('Setting transaction.upgrade_method to R12' );
	  END IF;
          UPDATE ra_customer_trx inv SET upgrade_method = 'R12'
          WHERE request_id = p_request_id
	   AND EXISTS
	     ( SELECT 1
	       FROM ra_cust_trx_types ctt
	       WHERE ctt.CUST_TRX_TYPE_ID = inv.CUST_TRX_TYPE_ID
	       AND ctt.TYPE in ('INV','DM'))
           AND NOT EXISTS (
		      SELECT 1
		      FROM  ra_customer_trx_lines l, ra_interface_errors e
		      WHERE l.customer_trx_id = inv.customer_trx_id
		      AND   l.customer_trx_line_id = e.interface_line_id);

-- Setting the Original and Remaining amounts R12
--
l_last_fetch := FALSE;

OPEN c02;
    LOOP
    FETCH c02 BULK COLLECT INTO l_ctl_app_tab
                 LIMIT g_bulk_fetch_rows;

      IF c02%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;

        IF (l_ctl_app_tab.COUNT = 0) AND (l_last_fetch) THEN
         IF PG_DEBUG = 'Y' THEN
	 localdebug('  COUNT = 0 and LAST FETCH ');
	 END IF;
        EXIT;
	END IF;

       IF PG_DEBUG = 'Y' THEN
       localdebug('  Setting the Original and Remaining amounts R12');
       END IF;
        FOR i IN l_ctl_app_tab.FIRST .. l_ctl_app_tab.LAST
       LOOP
	 BEGIN
		l_customer_trx.customer_trx_id := l_ctl_app_tab(i);
		re_calcul_rem_amt(p_customer_trx => l_customer_trx);

	 EXCEPTION
		  WHEN OTHERS THEN
				    IF PG_DEBUG in ('Y', 'C') THEN
				       arp_standard.debug('Inserting into errors...');
				    END IF;

				    IF c02%ISOPEN THEN CLOSE c02; END IF;

				   l_msg := 'Error while stamping the balance amt'||l_ctl_app_tab(i);


				    INSERT INTO ra_interface_errors
					   (
					   --org_id,
					   interface_line_id,
					   message_text
					   )
				    SELECT
					   --org_id,
					   customer_trx_line_id,
					   l_msg
				    FROM
					   ra_customer_trx_lines lines
				    WHERE
					   lines.customer_trx_id = l_ctl_app_tab(i);
	 END;
	END LOOP;

    END LOOP;
 CLOSE c02;

-- Setting the Original and Remaining amounts R12 END
--

 IF PG_DEBUG = 'Y' THEN
 localdebug('arp_det_dist_pkg.set_original_rem_amt_r12() OVERLOAD -');
 END IF;
EXCEPTION

 WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  EXCEPTION OTHERS in set_original_rem_amt_r12 OVERLOAD :'||SQLERRM(SQLCODE));
    END IF;
    RAISE;
END set_original_rem_amt_r12; -- End of OVERLOAD procedure


PROCEDURE set_original_rem_amt
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 p_adj_id           IN NUMBER DEFAULT NULL,
 p_app_id           IN NUMBER DEFAULT NULL,
--{HYUNLB
 p_from_llca        IN VARCHAR2 DEFAULT 'N')
--}
IS

  CURSOR c_verif(p_customer_trx_id  IN NUMBER) IS
  SELECT trx.upgrade_method,
         ctl.amount_due_original,
         ctl.amount_due_remaining
    FROM ra_customer_trx       trx,
	     ra_customer_trx_lines ctl
   WHERE trx.customer_trx_id = p_customer_trx_id
     AND ctl.customer_trx_id = trx.customer_trx_id;

  l_trx_type                  VARCHAR2(30);
  l_lazy_res                  VARCHAR2(1) := 'N';
  l_mfar_res                  VARCHAR2(1) := 'N';
  l_11i_adj        VARCHAR2(1);
  l_mfar_adj       VARCHAR2(1);
  l_11i_app        VARCHAR2(1);
  l_mfar_app       VARCHAR2(1);
  l_return_status  VARCHAR2(1)   := fnd_api.g_ret_sts_success;
  l_msg_data       VARCHAR2(2000);
  l_msg_count      NUMBER;
--{HYUNBL
  l_verif_rec      c_verif%ROWTYPE;
--}
  no_need_to_set_orig_rem_amt EXCEPTION;
  no_a_valid_trx              EXCEPTION;
  no_llca_allowed             EXCEPTION;
  excep_set_org_rem_amt_r12 EXCEPTION; --LLCA
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.set_original_rem_amt()+');
  localdebug('  p_adj_id :'||p_adj_id );
  localdebug('  p_app_id :'||p_app_id );
  END IF;

  OPEN c_verif(p_customer_trx.customer_trx_id);
  FETCH c_verif INTO l_verif_rec;
  IF c_verif%NOTFOUND THEN  -- 1
     RAISE no_a_valid_trx;
  ELSE  --1
    IF l_verif_rec.upgrade_method IN ('R12','R12_11IMFAR') THEN --2

      IF PG_DEBUG = 'Y' THEN
      localdebug('balance on the transaction should have been updated ');
      localdebug('    No matter LLCA or not, they should be maintained ');
      localdebug('    transaction current upgrade_method :'|| l_verif_rec.upgrade_method);
      localdebug('    p_from_llca                  :'|| p_from_llca);
      localdebug('We are showing the balances on the first line to avoid loop');
      localdebug('    l_verif_rec.amount_due_original  :'||l_verif_rec.amount_due_original);
      localdebug('    l_verif_rec.amount_due_remaining :'||l_verif_rec.amount_due_remaining);
      END IF;
      -- The transaction has been llca applied, hence the balance is up to date
      -- NB balance should maintained after the activity
      RAISE no_need_to_set_orig_rem_amt;

    ELSIF l_verif_rec.upgrade_method = 'R12_NLB' AND p_from_llca = 'Y' THEN --2

      IF PG_DEBUG = 'Y' THEN
      localdebug('balance on the transaction should not be maintained untill today ');
	  localdebug('   Need to update it and the transaction will have balance maintained as the user is doing LLCA');
      END IF;
      --{HYUNLB
      -- Update rem amount
      re_calcul_rem_amt(p_customer_trx => p_customer_trx);

      IF PG_DEBUG = 'Y' THEN
      localdebug('   going forward and it should be marked as R12');
      END IF;
       UPDATE ra_customer_trx
          SET upgrade_method = 'R12'
        WHERE customer_trx_id = p_customer_trx.customer_trx_id;
       --}

    ELSIF l_verif_rec.upgrade_method = 'R12_11ICASH'  THEN --2

       IF p_from_llca = 'Y' THEN
          IF PG_DEBUG = 'Y' THEN
	  localdebug('As p_from_llca = Y and  transacation.upgrade_method = R12_11ICASH ');
          localdebug('11i legacy transaction none MFAR, no Line Level Cash Application is allowed');
	  END IF;
          RAISE no_llca_allowed;
       ELSE
          IF PG_DEBUG = 'Y' THEN
	  localdebug('Transaction level activity on R12_11ICASH transaction balance will not be maintained');
	  END IF;
       END IF;

    ELSIF l_verif_rec.upgrade_method = 'R12_MERGE'  THEN

       IF p_from_llca = 'Y' THEN
          IF PG_DEBUG = 'Y' THEN
	  localdebug('As p_from_llca = Y and  transacation.upgrade_method = R12_MERGE ');
          localdebug('This transaction is having activities with summarized distributions, '||
	             ' no Line Level Cash Application is allowed');
	  END IF;
          RAISE no_llca_allowed;
       ELSE
          IF PG_DEBUG = 'Y' THEN
	  localdebug('Transaction level activity on R12_MERGE transaction balance will not be maintained');
	  END IF;
       END IF;
    ELSE  --2
      IF PG_DEBUG = 'Y' THEN
      localdebug('At this point the transaction upgrade_method is not set');
      localdebug('  l_verif_rec.upgrade_method :'||l_verif_rec.upgrade_method );
      END IF;

      check_legacy_status
      (p_trx_id           => p_customer_trx.customer_trx_id,
       p_adj_id           => p_adj_id,
       p_app_id           => p_app_id,
       x_11i_adj          => l_11i_adj,
       x_mfar_adj         => l_mfar_adj,
       x_11i_app          => l_11i_app,
       x_mfar_app         => l_mfar_app);

      -- Normal R12
      IF     ((l_11i_adj  = 'N') AND (l_mfar_adj = 'N') AND
             (l_11i_app  = 'N') AND (l_mfar_app = 'N'))
      THEN  --3
       --{HYUNLB
        IF p_from_llca = 'Y' THEN

          IF PG_DEBUG = 'Y' THEN
	  localdebug('As user is Line Level activating the trx - p_from_llca:'||p_from_llca);
          localdebug('Updating the Line Balance' );
	  END IF;
--LLCA
	  --set_original_rem_amt_r12(p_customer_trx => p_customer_trx);
	set_original_rem_amt_r12(p_customer_trx => p_customer_trx,
	x_return_status   =>  l_return_status,
	x_msg_count      =>  l_msg_count,
	x_msg_data        =>  l_msg_data,
	p_from_llca    => 'Y');

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE excep_set_org_rem_amt_r12;
     END IF;


          /* localdebug('Setting transaction.upgrade_method to R12' );
          UPDATE ra_customer_trx SET upgrade_method = 'R12'
          WHERE customer_trx_id = p_customer_trx.customer_trx_id; */

        ELSE

          IF PG_DEBUG = 'Y' THEN
	  localdebug('This is a direct activity on the transaction - p_from_llca:'||p_from_llca);
          localdebug('No balance maintenance and setting transaction.upg_flag to R12_NLB');
	  END IF;
          --{HYUNLB
          -- By setting the upg_make to R12_NLB
          -- <=> Do not maintain the line balance
          -- R12_NLB
          UPDATE ra_customer_trx SET upgrade_method = 'R12_NLB'
          WHERE customer_trx_id = p_customer_trx.customer_trx_id;
          --}
        END IF;

      -- MFAR legacy R12_11IMFAR
      ELSIF  ((l_mfar_adj = 'Y') OR (l_mfar_app = 'Y'))
      THEN --3
       --
       -- The starting balance should start from PSA
       --
        IF PG_DEBUG = 'Y' THEN
	localdebug('No matter LLCA or not, this a 11I MFAR transaction, we need to maintained balance');
	END IF;
        set_original_rem_amt_mfar(p_customer_trx => p_customer_trx);

        IF PG_DEBUG = 'Y' THEN
	localdebug('Setting the transaction.upgrade_method to R12_11IMFAR');
	END IF;
        UPDATE ra_customer_trx SET upgrade_method = 'R12_11IMFAR'
         WHERE customer_trx_id = p_customer_trx.customer_trx_id;


      ELSIF ((l_11i_adj  = 'N') AND (l_11i_app  = 'Y'))
      THEN --3
       -- Normal we do not maintain the line level balance
       -- In this case the balance on the line are inaccurate
       -- Although future adjustment and future application can tied
       -- back to original transaction distributions, I mark them to use
       -- R12_11ICASH method, because a application in 11i can increase
       -- the balance of the lines as AR allow
	   -- positive credit memo applied to an invoice
       -- If we use the R12 method for applications, over applications can happen
       -- resulting impossibility to close the transaction
       IF p_from_llca = 'Y' THEN
         IF PG_DEBUG = 'Y' THEN
	 localdebug('On this transaction no 11i adjustments has occurs');
         localdebug('But some applications in 11i has happened');
         localdebug('This is a 11i legacy transaction with 11i activity- LLCA should be allowed');
	 END IF;
         RAISE no_llca_allowed;

       ELSE
         IF PG_DEBUG = 'Y' THEN
	 localdebug('On this transaction no 11i adjustments has occurs');
         localdebug('But some applications in 11i has happened');
         localdebug('No maintenace of the line balances, but we set them as original for cm');
	 --        set_original_rem_amt_r12(p_customer_trx => p_customer_trx);

         localdebug('Setting the transaction.upgrade_method');
	 END IF;
         UPDATE ra_customer_trx SET upgrade_method = 'R12_11ICASH'
         WHERE customer_trx_id = p_customer_trx.customer_trx_id;
       END IF;
     ELSE --3
     -- CASH legacy R12_11ICASH
     -- (l_11i_adj  = 'Y')
     -- In this case future applications need to be prorated over
     -- existing adjustment distributions without the possibility
     -- to tied back to the original distributions only buckets will
     -- be identificable


       IF p_from_llca = 'Y' THEN
         IF PG_DEBUG = 'Y' THEN
	 localdebug('On this transaction 11i adjustments has occurs');
         localdebug('This is a 11i legacy transaction with 11i activity- LLCA should be allowed');
	 END IF;
         RAISE no_llca_allowed;

       ELSE
         IF PG_DEBUG = 'Y' THEN
	 localdebug('On this transaction 11i adjustments has occurs');
         localdebug('No maintenace of the line balances');

--        set_original_rem_amt_r12(p_customer_trx => p_customer_trx);

         localdebug('Setting the transaction.upgrade_method');
	 END IF;
         UPDATE ra_customer_trx SET upgrade_method = 'R12_11ICASH'
          WHERE customer_trx_id = p_customer_trx.customer_trx_id;

       END IF;

     END IF; --3
    END IF; --2
  END IF; --1
  CLOSE c_verif;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.set_original_rem_amt()-');
  END IF;
EXCEPTION
  WHEN no_need_to_set_orig_rem_amt THEN
    IF c_verif%ISOPEN THEN     CLOSE c_verif;   END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug('  No need to set orig rem amount');
    localdebug('arp_det_dist_pkg.set_original_rem_amt()-');
    END IF;

  WHEN no_a_valid_trx  THEN
    IF c_verif%ISOPEN THEN     CLOSE c_verif;   END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug('EXCEPTION no_a_valid_trx :'||p_customer_trx.customer_trx_id);
    END IF;
    RAISE;

  WHEN  no_llca_allowed   THEN
    IF c_verif%ISOPEN THEN     CLOSE c_verif;   END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug('EXCEPTION NO_llca_allowed customer_trx_id :'||p_customer_trx.customer_trx_id);
    END IF;
    RAISE;

 WHEN excep_set_org_rem_amt_r12 THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('EXCEPTION_set_original_rem_amt_r12 error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;


  WHEN OTHERS THEN
    IF c_verif%ISOPEN THEN     CLOSE c_verif;   END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug(' EXCEPTION OTHERS set_original_rem_amt:'||SQLERRM);
    END IF;
    RAISE;
END set_original_rem_amt;


PROCEDURE insert_ra_ar_gt
( p_ra_ar_gt             IN ra_ar_gt%ROWTYPE,
  p_ar_base_dist_amts_gt IN ar_base_dist_amts_gt%ROWTYPE,
  p_ra_ar_amounts_gt     IN ra_ar_amounts_gt%ROWTYPE
 )
IS
  l_rows NUMBER;
  l_base_rowid ROWID;
BEGIN
  INSERT INTO ra_ar_gt
   (
      GT_ID
   ,BASE_CURRENCY
   ,TO_CURRENCY
   ,FROM_CURRENCY
   ,DET_ID
   ,LINE_ID
   ,REF_CUSTOMER_TRX_ID
   ,REF_CUSTOMER_TRX_LINE_ID
   ,REF_CUST_TRX_LINE_GL_DIST_ID
   ,REF_LINE_ID
   ,REF_DET_ID
   ,ACCOUNT_CLASS
   ,SOURCE_TYPE
   ,SOURCE_TABLE
   ,SOURCE_ID
   ,AMT
   ,ACCTD_AMT
   ,AMT_DR
   ,AMT_CR
   ,ACCTD_AMT_DR
   ,ACCTD_AMT_CR
   ,FROM_ACCTD_AMT_DR
   ,FROM_ACCTD_AMT_CR
   ,CCID
   ,CCID_SECONDARY
   ,DIST_AMT
   ,DIST_ACCTD_AMT
   ,ALLOC_AMT
   ,ALLOC_ACCTD_AMT
   ,FROM_ALLOC_AMT
   ,FROM_ALLOC_ACCTD_AMT
   ,tl_alloc_amt
   ,tl_alloc_acctd_amt
   ,tl_chrg_alloc_amt
   ,tl_chrg_alloc_acctd_amt
   --
     ,tl_frt_alloc_amt
     ,tl_frt_alloc_acctd_amt
     ,tl_tax_alloc_amt
     ,tl_tax_alloc_acctd_amt
   --
   ,DUE_REM_AMT
   ,DUE_REM_ACCTD_AMT
   --
      ,FRT_REM_AMT
      ,FRT_REM_ACCTD_AMT
      ,TAX_REM_AMT
      ,TAX_REM_ACCTD_AMT
   --
   ,DUE_ORIG_AMT
   ,DUE_ORIG_ACCTD_AMT
   --
      ,FRT_ORIG_AMT
      ,FRT_ORIG_ACCTD_AMT
      ,TAX_ORIG_AMT
      ,TAX_ORIG_ACCTD_AMT
   --
   ,CHRG_REM_AMT
   ,CHRG_REM_ACCTD_AMT
   --
      ,FRT_ADJ_REM_AMT
      ,FRT_ADJ_REM_ACCTD_AMT
   --
   ,LINE_TYPE
   ,SUM_LINE_REM_AMT
   ,SUM_LINE_REM_ACCTD_AMT
   --
      ,SUM_LINE_FRT_REM_AMT
      ,SUM_LINE_FRT_REM_ACCTD_AMT
      ,SUM_LINE_TAX_REM_AMT
      ,SUM_LINE_TAX_REM_ACCTD_AMT
   --
   ,SUM_LINE_ORIG_AMT
   ,SUM_LINE_ORIG_ACCTD_AMT
   --
      ,SUM_LINE_FRT_ORIG_AMT
      ,SUM_LINE_FRT_ORIG_ACCTD_AMT
      ,SUM_LINE_TAX_ORIG_AMT
      ,SUM_LINE_TAX_ORIG_ACCTD_AMT
   --
   ,SUM_LINE_CHRG_REM_AMT
   ,SUM_LINE_CHRG_REM_ACCTD_AMT
   --
   ,TL_ED_ALLOC_AMT
   ,TL_ED_ALLOC_ACCTD_AMT
   ,TL_ED_CHRG_ALLOC_AMT
   ,TL_ED_CHRG_ALLOC_ACCTD_AMT
   --
      ,TL_ED_FRT_ALLOC_AMT
      ,TL_ED_FRT_ALLOC_ACCTD_AMT
      ,TL_ED_TAX_ALLOC_AMT
      ,TL_ED_TAX_ALLOC_ACCTD_AMT
   --
   ,TL_UNED_ALLOC_AMT
   ,TL_UNED_ALLOC_ACCTD_AMT
   ,TL_UNED_CHRG_ALLOC_AMT
   ,TL_UNED_CHRG_ALLOC_ACCTD_AMT
   --
      ,TL_UNED_FRT_ALLOC_AMT
      ,TL_UNED_FRT_ALLOC_ACCTD_AMT
      ,TL_UNED_TAX_ALLOC_AMT
      ,TL_UNED_TAX_ALLOC_ACCTD_AMT
   --
   ,DIST_ED_AMT
   ,DIST_ED_ACCTD_AMT
   ,DIST_UNED_AMT
   ,DIST_UNED_ACCTD_AMT
   ,gp_level
   ,group_id

   ,source_data_key1
   ,source_data_key2
   ,source_data_key3
   ,source_data_key4
   ,source_data_key5

   , SET_OF_BOOKS_ID
   , SOB_TYPE
   , activity_bucket
    )
   VALUES
    (
      p_ra_ar_gt.GT_ID                                --GT_ID
   ,p_ra_ar_gt.BASE_CURRENCY                        --BASE_CURRENCY
   ,p_ra_ar_gt.TO_CURRENCY                          --TO_CURRENCY
   ,p_ra_ar_gt.FROM_CURRENCY                        --FROM_CURRENCY
   ,p_ra_ar_gt.DET_ID                             --DET_ID
   ,p_ra_ar_gt.LINE_ID                              --LINE_ID
   ,p_ra_ar_gt.REF_CUSTOMER_TRX_ID                  --REF_CUSTOMER_TRX_ID
   ,p_ra_ar_gt.REF_CUSTOMER_TRX_LINE_ID             --REF_CUSTOMER_TRX_LINE_ID
   ,p_ra_ar_gt.REF_CUST_TRX_LINE_GL_DIST_ID         --REF_CUST_TRX_LINE_GL_DIST_ID
   ,p_ra_ar_gt.REF_LINE_ID                          --REF_LINE_ID
   ,p_ra_ar_gt.REF_DET_ID                         --REF_DET_ID
   ,p_ra_ar_gt.ACCOUNT_CLASS                        --ACCOUNT_CLASS
   ,p_ra_ar_gt.SOURCE_TYPE                          --SOURCE_TYPE
   ,p_ra_ar_gt.SOURCE_TABLE                         --SOURCE_TABLE
   ,p_ra_ar_gt.SOURCE_ID                            --SOURCE_ID
   ,p_ra_ar_gt.AMT                                  --AMT
   ,p_ra_ar_gt.ACCTD_AMT                            --ACCTD_AMT
   ,p_ra_ar_gt.AMT_DR                               --AMT_DR
   ,p_ra_ar_gt.AMT_CR                               --AMT_CR
   ,p_ra_ar_gt.ACCTD_AMT_DR                         --ACCTD_AMT_DR
   ,p_ra_ar_gt.ACCTD_AMT_CR                         --ACCTD_AMT_CR
   ,p_ra_ar_gt.FROM_ACCTD_AMT_DR                    --FROM_ACCTD_AMT_DR
   ,p_ra_ar_gt.FROM_ACCTD_AMT_CR                    --FROM_ACCTD_AMT_CR
   ,p_ra_ar_gt.CCID                                 --CCID
   ,p_ra_ar_gt.CCID_SECONDARY                       --CCID_SECONDARY
   ,p_ra_ar_gt.DIST_AMT                             --DIST_AMT
   ,p_ra_ar_gt.DIST_ACCTD_AMT                       --DIST_ACCTD_AMT
   ,p_ra_ar_gt.ALLOC_AMT                            --ALLOC_AMT
   ,p_ra_ar_gt.ALLOC_ACCTD_AMT                      --ALLOC_ACCTD_AMT
   ,p_ra_ar_gt.FROM_ALLOC_AMT                       --FROM_ALLOC_AMT
   ,p_ra_ar_gt.FROM_ALLOC_ACCTD_AMT                 --FROM_ALLOC_ACCTD_AMT
   ,p_ra_ar_gt.tl_alloc_amt                         --TL_ALLOC_AMT
   ,p_ra_ar_gt.tl_alloc_acctd_amt                   --TL_ALLOC_ACCTD_AMT
   ,p_ra_ar_gt.tl_chrg_alloc_amt
   ,p_ra_ar_gt.tl_chrg_alloc_acctd_amt
   --
     ,p_ra_ar_gt.tl_frt_alloc_amt                    --TL_FRT_ALLOC_AMT
     ,p_ra_ar_gt.tl_frt_alloc_acctd_amt              --TL_FRT_ALLOC_ACCTD_AMT
     ,p_ra_ar_gt.tl_tax_alloc_amt
     ,p_ra_ar_gt.tl_tax_alloc_acctd_amt
   --
   ,p_ra_ar_gt.DUE_REM_AMT
   ,p_ra_ar_gt.DUE_REM_ACCTD_AMT
   --
     ,p_ra_ar_gt.FRT_REM_AMT
     ,p_ra_ar_gt.FRT_REM_ACCTD_AMT
     ,p_ra_ar_gt.TAX_REM_AMT
     ,p_ra_ar_gt.TAX_REM_ACCTD_AMT
   --
   ,p_ra_ar_gt.DUE_ORIG_AMT
   ,p_ra_ar_gt.DUE_ORIG_ACCTD_AMT
   --
     ,p_ra_ar_gt.FRT_ORIG_AMT
     ,p_ra_ar_gt.FRT_ORIG_ACCTD_AMT
     ,p_ra_ar_gt.TAX_ORIG_AMT
     ,p_ra_ar_gt.TAX_ORIG_ACCTD_AMT
   --
   ,p_ra_ar_gt.CHRG_REM_AMT
   ,p_ra_ar_gt.CHRG_REM_ACCTD_AMT
   --
     ,p_ra_ar_gt.FRT_ADJ_REM_AMT
     ,p_ra_ar_gt.FRT_ADJ_REM_ACCTD_AMT
   --
   ,p_ra_ar_gt.LINE_TYPE
   ,p_ra_ar_gt.SUM_LINE_REM_AMT
   ,p_ra_ar_gt.SUM_LINE_REM_ACCTD_AMT
   --
     ,p_ra_ar_gt.SUM_LINE_FRT_REM_AMT
     ,p_ra_ar_gt.SUM_LINE_FRT_REM_ACCTD_AMT
     ,p_ra_ar_gt.SUM_LINE_TAX_REM_AMT
     ,p_ra_ar_gt.SUM_LINE_TAX_REM_ACCTD_AMT
   --
   ,p_ra_ar_gt.SUM_LINE_ORIG_AMT
   ,p_ra_ar_gt.SUM_LINE_ORIG_ACCTD_AMT
   --
     ,p_ra_ar_gt.SUM_LINE_FRT_ORIG_AMT
     ,p_ra_ar_gt.SUM_LINE_FRT_ORIG_ACCTD_AMT
     ,p_ra_ar_gt.SUM_LINE_TAX_ORIG_AMT
     ,p_ra_ar_gt.SUM_LINE_TAX_ORIG_ACCTD_AMT
   --
   ,p_ra_ar_gt.SUM_LINE_CHRG_REM_AMT
   ,p_ra_ar_gt.SUM_LINE_CHRG_REM_ACCTD_AMT
   --
   ,p_ra_ar_gt.TL_ED_ALLOC_AMT
   ,p_ra_ar_gt.TL_ED_ALLOC_ACCTD_AMT
   ,p_ra_ar_gt.TL_ED_CHRG_ALLOC_AMT
   ,p_ra_ar_gt.TL_ED_CHRG_ALLOC_ACCTD_AMT
   --
     ,p_ra_ar_gt.TL_ED_FRT_ALLOC_AMT
     ,p_ra_ar_gt.TL_ED_FRT_ALLOC_ACCTD_AMT
     ,p_ra_ar_gt.TL_ED_TAX_ALLOC_AMT
     ,p_ra_ar_gt.TL_ED_TAX_ALLOC_ACCTD_AMT
   --
   ,p_ra_ar_gt.TL_UNED_ALLOC_AMT
   ,p_ra_ar_gt.TL_UNED_ALLOC_ACCTD_AMT
   ,p_ra_ar_gt.TL_UNED_CHRG_ALLOC_AMT
   ,p_ra_ar_gt.TL_UNED_CHRG_ALLOC_ACCTD_AMT
   --
     ,p_ra_ar_gt.TL_UNED_FRT_ALLOC_AMT
     ,p_ra_ar_gt.TL_UNED_FRT_ALLOC_ACCTD_AMT
     ,p_ra_ar_gt.TL_UNED_TAX_ALLOC_AMT
     ,p_ra_ar_gt.TL_UNED_TAX_ALLOC_ACCTD_AMT
   --
   ,p_ra_ar_gt.DIST_ED_AMT
   ,p_ra_ar_gt.DIST_ED_ACCTD_AMT
   ,p_ra_ar_gt.DIST_UNED_AMT
   ,p_ra_ar_gt.DIST_UNED_ACCTD_AMT
   ,p_ra_ar_gt.gp_level
   ,p_ra_ar_gt.group_id

   ,p_ra_ar_gt.source_data_key1
   ,p_ra_ar_gt.source_data_key2
   ,p_ra_ar_gt.source_data_key3
   ,p_ra_ar_gt.source_data_key4
   ,p_ra_ar_gt.source_data_key5

   ,p_ra_ar_gt.SET_OF_BOOKS_ID
   ,p_ra_ar_gt.SOB_TYPE
   ,p_ra_ar_gt.activity_bucket
    )  RETURNING ROWID INTO l_base_rowid;

  l_rows := sql%rowcount;
  g_appln_count := g_appln_count + l_rows;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  rows inserted = ' || l_rows);
  END IF;


  INSERT INTO AR_BASE_DIST_AMTS_GT
    (
      gt_id
      ,gp_level
      ,ref_customer_trx_id
      ,ref_customer_trx_line_id
      ,base_dist_amt
      ,base_dist_acctd_amt
      ,base_ed_dist_amt
      ,base_ed_dist_acctd_amt
      ,base_uned_dist_amt
      ,base_uned_dist_acctd_amt
      ,set_of_books_id
      ,sob_type
      ,source_table
    )
  VALUES
    (
      p_ra_ar_gt.gt_id
      ,p_ra_ar_gt.gp_level
      ,p_ra_ar_gt.ref_customer_trx_id
      ,p_ra_ar_gt.ref_customer_trx_line_id
      ,p_ar_base_dist_amts_gt.base_dist_amt
      ,p_ar_base_dist_amts_gt.base_dist_acctd_amt
      ,p_ar_base_dist_amts_gt.base_ed_dist_amt
      ,p_ar_base_dist_amts_gt.base_ed_dist_acctd_amt
      ,p_ar_base_dist_amts_gt.base_uned_dist_amt
      ,p_ar_base_dist_amts_gt.base_uned_dist_acctd_amt
      ,p_ra_ar_gt.SET_OF_BOOKS_ID
      ,p_ra_ar_gt.SOB_TYPE
      ,p_ra_ar_gt.SOURCE_TABLE
    );

  INSERT INTO RA_AR_AMOUNTS_GT
   (
      gt_id
      ,gp_level
      ,base_rec_rowid
      ,ref_customer_trx_id
      ,ref_customer_trx_line_id

      ,base_pro_amt
      ,base_pro_acctd_amt
      ,BASE_CHRG_PRO_AMT
      ,BASE_CHRG_PRO_ACCTD_AMT
      --
      ,BASE_FRT_PRO_AMT
      ,BASE_FRT_PRO_ACCTD_AMT
      ,BASE_TAX_PRO_AMT
      ,BASE_TAX_PRO_ACCTD_AMT
      --
      ,elmt_pro_amt
      ,elmt_pro_acctd_amt
      ,ELMT_CHRG_PRO_AMT
      ,ELMT_CHRG_PRO_ACCTD_AMT
      --
      ,ELMT_FRT_PRO_AMT
      ,ELMT_FRT_PRO_ACCTD_AMT
      ,ELMT_TAX_PRO_AMT
      ,ELMT_TAX_PRO_ACCTD_AMT
      --
      ,buc_alloc_amt
      ,buc_alloc_acctd_amt
      ,buc_chrg_alloc_amt
      ,buc_chrg_alloc_acctd_amt
      --
      ,buc_frt_alloc_amt
      ,buc_frt_alloc_acctd_amt
      ,buc_tax_alloc_amt
      ,buc_tax_alloc_acctd_amt

      ,BUC_ED_ALLOC_AMT
      ,BUC_ED_ALLOC_ACCTD_AMT
      ,BUC_ED_CHRG_ALLOC_AMT
      ,BUC_ED_CHRG_ALLOC_ACCTD_AMT
      --
      ,BUC_ED_FRT_ALLOC_AMT
      ,BUC_ED_FRT_ALLOC_ACCTD_AMT
      ,BUC_ED_TAX_ALLOC_AMT
      ,BUC_ED_TAX_ALLOC_ACCTD_AMT
      --
      ,ELMT_ED_PRO_AMT
      ,ELMT_ED_PRO_ACCTD_AMT
      ,ELMT_ED_CHRG_PRO_AMT
      ,ELMT_ED_CHRG_PRO_ACCTD_AMT
      --
      ,ELMT_ED_FRT_PRO_AMT
      ,ELMT_ED_FRT_PRO_ACCTD_AMT
      ,ELMT_ED_TAX_PRO_AMT
      ,ELMT_ED_TAX_PRO_ACCTD_AMT
      --
      ,BASE_ED_PRO_AMT
      ,BASE_ED_PRO_ACCTD_AMT
      ,BASE_ED_CHRG_PRO_AMT
      ,BASE_ED_CHRG_PRO_ACCTD_AMT
      --
      ,BASE_ED_FRT_PRO_AMT
      ,BASE_ED_FRT_PRO_ACCTD_AMT
      ,BASE_ED_TAX_PRO_AMT
      ,BASE_ED_TAX_PRO_ACCTD_AMT

      ,BUC_UNED_ALLOC_AMT
      ,BUC_UNED_ALLOC_ACCTD_AMT
      ,BUC_UNED_CHRG_ALLOC_AMT
      ,BUC_UNED_CHRG_ALLOC_ACCTD_AMT
      --
      ,BUC_UNED_FRT_ALLOC_AMT
      ,BUC_UNED_FRT_ALLOC_ACCTD_AMT
      ,BUC_UNED_TAX_ALLOC_AMT
      ,BUC_UNED_TAX_ALLOC_ACCTD_AMT
      --
      ,ELMT_UNED_PRO_AMT
      ,ELMT_UNED_PRO_ACCTD_AMT
      ,ELMT_UNED_CHRG_PRO_AMT
      ,ELMT_UNED_CHRG_PRO_ACCTD_AMT
      --
      ,ELMT_UNED_FRT_PRO_AMT
      ,ELMT_UNED_FRT_PRO_ACCTD_AMT
      ,ELMT_UNED_TAX_PRO_AMT
      ,ELMT_UNED_TAX_PRO_ACCTD_AMT
      --
      ,BASE_UNED_PRO_AMT
      ,BASE_UNED_PRO_ACCTD_AMT
      ,BASE_UNED_CHRG_PRO_AMT
      ,BASE_UNED_CHRG_PRO_ACCTD_AMT
      --
      ,BASE_UNED_FRT_PRO_AMT
      ,BASE_UNED_FRT_PRO_ACCTD_AMT
      ,BASE_UNED_TAX_PRO_AMT
      ,BASE_UNED_TAX_PRO_ACCTD_AMT
    )
  VALUES
   (
      p_ra_ar_gt.gt_id
      ,p_ra_ar_gt.gp_level
      ,l_base_rowid
      ,p_ra_ar_gt.ref_customer_trx_id
      ,p_ra_ar_gt.ref_customer_trx_line_id

      ,p_ra_ar_amounts_gt.base_pro_amt
      ,p_ra_ar_amounts_gt.base_pro_acctd_amt
      ,p_ra_ar_amounts_gt.BASE_CHRG_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_CHRG_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.BASE_FRT_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_FRT_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BASE_TAX_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_TAX_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.elmt_pro_amt
      ,p_ra_ar_amounts_gt.elmt_pro_acctd_amt
      ,p_ra_ar_amounts_gt.ELMT_CHRG_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_CHRG_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.ELMT_FRT_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_FRT_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.ELMT_TAX_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_TAX_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.buc_alloc_amt
      ,p_ra_ar_amounts_gt.buc_alloc_acctd_amt
      ,p_ra_ar_amounts_gt.buc_chrg_alloc_amt
      ,p_ra_ar_amounts_gt.buc_chrg_alloc_acctd_amt
      --
      ,p_ra_ar_amounts_gt.buc_frt_alloc_amt
      ,p_ra_ar_amounts_gt.buc_frt_alloc_acctd_amt
      ,p_ra_ar_amounts_gt.buc_tax_alloc_amt
      ,p_ra_ar_amounts_gt.buc_tax_alloc_acctd_amt

      ,p_ra_ar_amounts_gt.BUC_ED_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_ED_ALLOC_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BUC_ED_CHRG_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_ED_CHRG_ALLOC_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.BUC_ED_FRT_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_ED_FRT_ALLOC_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BUC_ED_TAX_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_ED_TAX_ALLOC_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.ELMT_ED_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_ED_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.ELMT_ED_CHRG_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_ED_CHRG_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.ELMT_ED_FRT_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_ED_FRT_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.ELMT_ED_TAX_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_ED_TAX_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.BASE_ED_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_ED_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BASE_ED_CHRG_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_ED_CHRG_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.BASE_ED_FRT_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_ED_FRT_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BASE_ED_TAX_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_ED_TAX_PRO_ACCTD_AMT

      ,p_ra_ar_amounts_gt.BUC_UNED_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_UNED_ALLOC_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BUC_UNED_CHRG_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_UNED_CHRG_ALLOC_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.BUC_UNED_FRT_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_UNED_FRT_ALLOC_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BUC_UNED_TAX_ALLOC_AMT
      ,p_ra_ar_amounts_gt.BUC_UNED_TAX_ALLOC_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.ELMT_UNED_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_UNED_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.ELMT_UNED_CHRG_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_UNED_CHRG_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.ELMT_UNED_FRT_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_UNED_FRT_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.ELMT_UNED_TAX_PRO_AMT
      ,p_ra_ar_amounts_gt.ELMT_UNED_TAX_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.BASE_UNED_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_UNED_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BASE_UNED_CHRG_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_UNED_CHRG_PRO_ACCTD_AMT
      --
      ,p_ra_ar_amounts_gt.BASE_UNED_FRT_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_UNED_FRT_PRO_ACCTD_AMT
      ,p_ra_ar_amounts_gt.BASE_UNED_TAX_PRO_AMT
      ,p_ra_ar_amounts_gt.BASE_UNED_TAX_PRO_ACCTD_AMT
    );
  l_rows := sql%rowcount;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  rows inserted into AR_BASE_DIST_AMTS_GT = ' || l_rows);
  END IF;
END insert_ra_ar_gt;


PROCEDURE adjustment_detemination
(p_customer_trx_id   IN NUMBER,
 p_gt_id             IN VARCHAR2,
 p_pay_adj           IN VARCHAR2,
 p_ae_sys_rec        IN arp_acct_main.ae_sys_rec_type,
 p_adj_rec           IN ar_adjustments%ROWTYPE)
IS
  CURSOR get_sum_per_line_type IS
  SELECT /*+INDEX (RA_AR_GT ra_ar_n1)*/
         MAX(sum_line_rem_amt),
         MAX(sum_line_rem_acctd_amt),
         MAX(sum_line_orig_amt),
         MAX(sum_line_orig_acctd_amt),
         MAX(sum_line_chrg_rem_amt),
         MAX(sum_line_chrg_rem_acctd_amt),
         --
         MAX(sum_line_frt_rem_amt),
         MAX(sum_line_frt_rem_acctd_amt),
         MAX(sum_line_frt_orig_amt),
         MAX(sum_line_frt_orig_acctd_amt),
         --
         MAX(sum_line_tax_rem_amt),
         MAX(sum_line_tax_rem_acctd_amt),
         MAX(sum_line_tax_orig_amt),
         MAX(sum_line_tax_orig_acctd_amt),
         --
         line_type
    FROM ra_ar_gt
   WHERE gt_id                = p_gt_id
--     AND se_gt_id             = g_se_gt_id
     AND ref_customer_trx_id  = p_customer_trx_id
     AND gp_level             = 'L' --'D'
   GROUP BY line_type;

  CURSOR cu_inv_cur IS
  SELECT invoice_currency_code,exchange_rate
    FROM ra_customer_trx
   WHERE customer_trx_id      = p_customer_trx_id;
  l_inv_currency                 VARCHAR2(30) := NULL;
  l_exchange_rate                ra_customer_trx.exchange_rate%type;
  l_sum_line_rem_amt             DBMS_SQL.NUMBER_TABLE;
  l_sum_line_rem_acctd_amt       DBMS_SQL.NUMBER_TABLE;
  l_sum_line_orig_amt            DBMS_SQL.NUMBER_TABLE;
  l_sum_line_orig_acctd_amt      DBMS_SQL.NUMBER_TABLE;
  l_sum_line_chrg_rem_amt        DBMS_SQL.NUMBER_TABLE;
  l_sum_line_chrg_rem_acctd_amt  DBMS_SQL.NUMBER_TABLE;
  --
  l_sum_line_frt_rem_amt             DBMS_SQL.NUMBER_TABLE;
  l_sum_line_frt_rem_acctd_amt       DBMS_SQL.NUMBER_TABLE;
  l_sum_line_frt_orig_amt            DBMS_SQL.NUMBER_TABLE;
  l_sum_line_frt_orig_acctd_amt      DBMS_SQL.NUMBER_TABLE;
  --
  l_sum_line_tax_rem_amt             DBMS_SQL.NUMBER_TABLE;
  l_sum_line_tax_rem_acctd_amt       DBMS_SQL.NUMBER_TABLE;
  l_sum_line_tax_orig_amt            DBMS_SQL.NUMBER_TABLE;
  l_sum_line_tax_orig_acctd_amt      DBMS_SQL.NUMBER_TABLE;
  --
  l_line_type                    DBMS_SQL.VARCHAR2_TABLE;
  l_ra_ar_gt                     ra_ar_gt%ROWTYPE;
  invoice_has_no_lines           EXCEPTION;
  not_an_adjustment              EXCEPTION;
  l_freight_boundary_done        VARCHAR2(1) := 'N';
  l_line_boundary_done           VARCHAR2(1) := 'N';
  l_tax_boundary_done            VARCHAR2(1) := 'N';
  l_chrg_boundary_done           VARCHAR2(1) := 'N';
  PROCEDURE line_boundary
  (p_adj_rec            IN ar_adjustments%ROWTYPE,
   p_sum_line_orig_amt  IN NUMBER,
   p_sum_line_rem_amt   IN NUMBER,
   p_inv_currency       IN VARCHAR2,
   p_customer_trx_id    IN NUMBER,
   p_gt_id              IN VARCHAR2,
   p_ae_sys_rec         IN arp_acct_main.ae_sys_rec_type,
   P_exchange_rate      IN ra_customer_trx.exchange_rate%type)
  IS
    l_ra_ar_gt              ra_ar_gt%ROWTYPE;
    l_ar_base_dist_amts_gt  ar_base_dist_amts_gt%ROWTYPE;
    l_ra_ar_amounts_gt      ra_ar_amounts_gt%ROWTYPE;
  BEGIN
     --Rev line boundary
     IF  NVL(p_adj_rec.line_adjusted,0) <> 0 AND
         NVL(p_sum_line_orig_amt,0)  =  0 AND
         NVL(p_sum_line_rem_amt,0)   =  0
     THEN
        IF PG_DEBUG = 'Y' THEN
	localdebug('   -6 Adjustment Boundary LINE condition met');
	END IF;
        l_ra_ar_gt.GT_ID      :=  p_gt_id;
        l_ra_ar_gt.AMT        :=  p_adj_rec.line_adjusted;
        l_ra_ar_gt.ACCTD_AMT  :=  currRound(p_adj_rec.line_adjusted * P_exchange_rate,
                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.ACCOUNT_CLASS               :=  'REV';
        l_ra_ar_gt.CCID_SECONDARY              :=  NULL; --Normally the auto accounting ccid
        l_ra_ar_gt.REF_CUST_TRX_LINE_GL_DIST_ID:=  -6;
        l_ra_ar_gt.REF_CUSTOMER_TRX_LINE_ID    :=  -6;
        l_ra_ar_gt.REF_CUSTOMER_TRX_ID         :=  p_customer_trx_id;
        l_ra_ar_gt.DIST_AMT                    :=  p_adj_rec.line_adjusted;
        l_ra_ar_gt.DIST_ACCTD_AMT              :=  currRound(p_adj_rec.line_adjusted * P_exchange_rate,
                                                                     p_ae_sys_rec.base_currency);
        l_ra_ar_gt.TO_CURRENCY                 :=  p_inv_currency;
        l_ra_ar_gt.BASE_CURRENCY               :=  p_ae_sys_rec.base_currency;
        l_ra_ar_gt.tl_alloc_amt                :=  p_adj_rec.line_adjusted;
        l_ra_ar_gt.tl_alloc_acctd_amt          :=  currRound(p_adj_rec.line_adjusted * P_exchange_rate,
                                                                     p_ae_sys_rec.base_currency);
        l_ra_ar_gt.tl_chrg_alloc_amt           :=  0;
        l_ra_ar_gt.tl_chrg_alloc_acctd_amt     :=  0;
        l_ra_ar_gt.tl_frt_alloc_amt            :=  0;
        l_ra_ar_gt.tl_frt_alloc_acctd_amt      :=  0;
        l_ra_ar_gt.tl_tax_alloc_amt            :=  0;
        l_ra_ar_gt.tl_tax_alloc_acctd_amt      :=  0;
        l_ar_base_dist_amts_gt.base_dist_amt        :=  p_adj_rec.line_adjusted;
        l_ar_base_dist_amts_gt.base_dist_acctd_amt  :=  currRound(p_adj_rec.line_adjusted * P_exchange_rate,
                                                                     p_ae_sys_rec.base_currency);
        l_ra_ar_gt.source_type                 :=  'LINE';
        l_ra_ar_gt.source_table                :=  'ADJ';
        l_ra_ar_gt.source_id                   :=  p_adj_rec.adjustment_id;
        l_ra_ar_gt.gp_level                    :=  'D';
        l_ra_ar_gt.group_id                    :=  '00';
  --{HYUBPAGP
        l_ra_ar_gt.source_data_key1            :=  '00';
        l_ra_ar_gt.source_data_key2            :=  '00';
        l_ra_ar_gt.source_data_key3            :=  '00';
        l_ra_ar_gt.source_data_key4            :=  '00';
        l_ra_ar_gt.source_data_key5            :=  '00';
  --}
--        l_ra_ar_gt.se_gt_id                    := g_se_gt_id;
        l_ra_ar_gt.set_of_books_id             := p_ae_sys_rec.set_of_books_id;
        l_ra_ar_gt.sob_type                    := p_ae_sys_rec.sob_type;
        l_ra_ar_gt.activity_bucket                      := 'ADJ';
        insert_ra_ar_gt(p_ra_ar_gt  =>  l_ra_ar_gt,
	                p_ar_base_dist_amts_gt => l_ar_base_dist_amts_gt,
			p_ra_ar_amounts_gt => l_ra_ar_amounts_gt
			);
      END IF;

      --Charge boundary is part of line boundary estimation because frt over revenue line
      IF NVL(p_adj_rec.receivables_charges_adjusted,0) <> 0 AND
         NVL(p_sum_line_orig_amt,0)                  = 0 AND
         NVL(p_sum_line_rem_amt,0)                   = 0
      THEN
        IF PG_DEBUG = 'Y' THEN
	localdebug('   -7 Adjustment Boundary CHARGES condition met');
	END IF;
        l_ra_ar_gt.GT_ID      :=  p_gt_id;
        l_ra_ar_gt.AMT        :=  p_adj_rec.receivables_charges_adjusted;
        l_ra_ar_gt.ACCTD_AMT  :=  currRound(p_adj_rec.receivables_charges_adjusted * P_exchange_rate,
                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.ACCOUNT_CLASS               :=  'REV';
        l_ra_ar_gt.CCID_SECONDARY              :=  NULL; --Normally the auto accounting ccid
        l_ra_ar_gt.REF_CUST_TRX_LINE_GL_DIST_ID:=  -7;
        l_ra_ar_gt.REF_CUSTOMER_TRX_LINE_ID    :=  -7;
        l_ra_ar_gt.REF_CUSTOMER_TRX_ID         :=  p_customer_trx_id;
        l_ra_ar_gt.DIST_AMT                    :=  p_adj_rec.receivables_charges_adjusted;
        l_ra_ar_gt.DIST_ACCTD_AMT              :=  currRound(p_adj_rec.receivables_charges_adjusted * P_exchange_rate,
                                                                     p_ae_sys_rec.base_currency);
        l_ra_ar_gt.TO_CURRENCY                 :=  p_inv_currency;
        l_ra_ar_gt.BASE_CURRENCY               :=  p_ae_sys_rec.base_currency;
        l_ra_ar_gt.tl_alloc_amt                :=  0;
        l_ra_ar_gt.tl_alloc_acctd_amt          :=  0;
        l_ra_ar_gt.tl_chrg_alloc_amt           :=  p_adj_rec.receivables_charges_adjusted;
        l_ra_ar_gt.tl_chrg_alloc_acctd_amt     := currRound(p_adj_rec.receivables_charges_adjusted * P_exchange_rate,
                                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.tl_frt_alloc_amt            :=  0;
        l_ra_ar_gt.tl_frt_alloc_acctd_amt      :=  0;
        l_ra_ar_gt.tl_tax_alloc_amt            :=  0;
        l_ra_ar_gt.tl_tax_alloc_acctd_amt      :=  0;
        l_ar_base_dist_amts_gt.base_dist_amt        :=  p_adj_rec.receivables_charges_adjusted;
        l_ar_base_dist_amts_gt.base_dist_acctd_amt  :=  currRound(p_adj_rec.receivables_charges_adjusted * P_exchange_rate,
                                                                     p_ae_sys_rec.base_currency);
        l_ra_ar_gt.source_type                 :=  'CHARGES';
        l_ra_ar_gt.source_table                :=  'ADJ';
        l_ra_ar_gt.source_id                   :=  p_adj_rec.adjustment_id;
        l_ra_ar_gt.gp_level                    :=  'D';
        l_ra_ar_gt.group_id                    :=  '00';
  --{HYUBPAGP
        l_ra_ar_gt.source_data_key1            :=  '00';
        l_ra_ar_gt.source_data_key2            :=  '00';
        l_ra_ar_gt.source_data_key3            :=  '00';
        l_ra_ar_gt.source_data_key4            :=  '00';
        l_ra_ar_gt.source_data_key5            :=  '00';
  --}
--        l_ra_ar_gt.se_gt_id                    := g_se_gt_id;
        l_ra_ar_gt.set_of_books_id             := p_ae_sys_rec.set_of_books_id;
        l_ra_ar_gt.sob_type                    := p_ae_sys_rec.sob_type;
        l_ra_ar_gt.activity_bucket                      := 'ADJ';
        insert_ra_ar_gt(p_ra_ar_gt  =>  l_ra_ar_gt,
	                p_ar_base_dist_amts_gt => l_ar_base_dist_amts_gt,
			p_ra_ar_amounts_gt => l_ra_ar_amounts_gt
			);
      END IF;

      --Frt boundary is part of line boundary estimation because frt over revenue line
      IF NVL(p_adj_rec.freight_adjusted,0) <> 0 AND
         NVL(p_sum_line_orig_amt,0)  = 0 AND
         NVL(p_sum_line_rem_amt,0)   = 0
      THEN
        IF PG_DEBUG = 'Y' THEN
	localdebug('   -9 Adjustment Boundary FREIGHT condition met');
	END IF;
        l_ra_ar_gt.GT_ID      :=  p_gt_id;
        l_ra_ar_gt.AMT        :=  p_adj_rec.freight_adjusted;
        l_ra_ar_gt.ACCTD_AMT  :=  currRound(p_adj_rec.freight_adjusted * P_exchange_rate,
                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.ACCOUNT_CLASS               := 'REV';
        l_ra_ar_gt.CCID_SECONDARY              := NULL; --Normally the auto accounting ccid
        l_ra_ar_gt.REF_CUST_TRX_LINE_GL_DIST_ID:= -9;
        l_ra_ar_gt.REF_CUSTOMER_TRX_LINE_ID    := -9;
        l_ra_ar_gt.REF_CUSTOMER_TRX_ID         := p_customer_trx_id;
        l_ra_ar_gt.DIST_AMT                    := p_adj_rec.freight_adjusted;
        l_ra_ar_gt.DIST_ACCTD_AMT              := currRound(p_adj_rec.tax_adjusted * P_exchange_rate,
                                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.TO_CURRENCY                 := p_inv_currency;
        l_ra_ar_gt.BASE_CURRENCY               := p_ae_sys_rec.base_currency;
        l_ra_ar_gt.tl_chrg_alloc_amt           := 0;
        l_ra_ar_gt.tl_chrg_alloc_acctd_amt     := 0;
        l_ra_ar_gt.tl_tax_alloc_amt            := 0;
        l_ra_ar_gt.tl_tax_alloc_acctd_amt      := 0;
        l_ra_ar_gt.tl_alloc_amt                := 0;
        l_ra_ar_gt.tl_alloc_acctd_amt          := 0;
        l_ra_ar_gt.tl_frt_alloc_amt            := p_adj_rec.freight_adjusted;
        l_ra_ar_gt.tl_frt_alloc_acctd_amt      := currRound(p_adj_rec.freight_adjusted * P_exchange_rate,
                                                                    p_ae_sys_rec.base_currency);
        l_ar_base_dist_amts_gt.base_dist_amt       := p_adj_rec.freight_adjusted;
        l_ar_base_dist_amts_gt.base_dist_acctd_amt := currRound(p_adj_rec.freight_adjusted * P_exchange_rate,
                                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.source_type                 := 'FREIGHT';
        l_ra_ar_gt.source_table                := 'ADJ';
        l_ra_ar_gt.source_id                   := p_adj_rec.adjustment_id;
        l_ra_ar_gt.gp_level                    := 'D';
        l_ra_ar_gt.group_id                    := '00';
  --{HYUBPAGP
        l_ra_ar_gt.source_data_key1            :=  '00';
        l_ra_ar_gt.source_data_key2            :=  '00';
        l_ra_ar_gt.source_data_key3            :=  '00';
        l_ra_ar_gt.source_data_key4            :=  '00';
        l_ra_ar_gt.source_data_key5            :=  '00';
  --}
--        l_ra_ar_gt.se_gt_id                    := g_se_gt_id;
        l_ra_ar_gt.set_of_books_id             := p_ae_sys_rec.set_of_books_id;
        l_ra_ar_gt.sob_type                    := p_ae_sys_rec.sob_type;
        l_ra_ar_gt.activity_bucket                      := 'ADJ';
        insert_ra_ar_gt(p_ra_ar_gt  =>  l_ra_ar_gt,
	                p_ar_base_dist_amts_gt => l_ar_base_dist_amts_gt,
			p_ra_ar_amounts_gt => l_ra_ar_amounts_gt
			);
      END IF;
  END  line_boundary;

  PROCEDURE tax_boundary
  (p_adj_rec            IN ar_adjustments%ROWTYPE,
   p_sum_line_tax_orig_amt  IN NUMBER,
   p_sum_line_tax_rem_amt   IN NUMBER,
   p_inv_currency       IN VARCHAR2,
   p_customer_trx_id    IN NUMBER,
   p_gt_id              IN VARCHAR2,
   p_ae_sys_rec         IN arp_acct_main.ae_sys_rec_type,
   P_exchange_rate      IN ra_customer_trx.exchange_rate%type)
  IS
    l_ra_ar_gt              ra_ar_gt%ROWTYPE;
    l_ar_base_dist_amts_gt  ar_base_dist_amts_gt%ROWTYPE;
    l_ra_ar_amounts_gt      ra_ar_amounts_gt%ROWTYPE;
  BEGIN
      IF NVL(p_adj_rec.tax_adjusted,0) <> 0 AND
         NVL(p_sum_line_tax_orig_amt,0)  = 0 AND
         NVL(p_sum_line_tax_rem_amt,0)   = 0
      THEN
        IF PG_DEBUG = 'Y' THEN
	localdebug('   -8 Adjustment Boundary TAX condition met');
	END IF;
        l_ra_ar_gt.GT_ID      :=  p_gt_id;
        l_ra_ar_gt.AMT        :=  p_adj_rec.tax_adjusted;
        l_ra_ar_gt.ACCTD_AMT  :=  currRound(p_adj_rec.tax_adjusted * P_exchange_rate,
                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.ACCOUNT_CLASS               :=  'TAX';
        l_ra_ar_gt.CCID_SECONDARY              :=  NULL; --Normally the auto accounting ccid
        l_ra_ar_gt.REF_CUST_TRX_LINE_GL_DIST_ID:=  -8;
        l_ra_ar_gt.REF_CUSTOMER_TRX_LINE_ID    :=  -8;
        l_ra_ar_gt.REF_CUSTOMER_TRX_ID         :=  p_customer_trx_id;
        l_ra_ar_gt.DIST_AMT                    :=  p_adj_rec.tax_adjusted;
        l_ra_ar_gt.DIST_ACCTD_AMT :=  currRound(p_adj_rec.tax_adjusted * P_exchange_rate,
                                                        p_ae_sys_rec.base_currency);
        l_ra_ar_gt.TO_CURRENCY                 :=  p_inv_currency;
        l_ra_ar_gt.BASE_CURRENCY               :=  p_ae_sys_rec.base_currency;
        l_ra_ar_gt.tl_chrg_alloc_amt           :=  0;
        l_ra_ar_gt.tl_chrg_alloc_acctd_amt     :=  0;
        l_ra_ar_gt.tl_frt_alloc_amt            :=  0;
        l_ra_ar_gt.tl_frt_alloc_acctd_amt      :=  0;
        l_ra_ar_gt.tl_alloc_amt                :=  0;
        l_ra_ar_gt.tl_alloc_acctd_amt          :=  0;
        l_ra_ar_gt.tl_tax_alloc_amt            :=  p_adj_rec.tax_adjusted;
        l_ra_ar_gt.tl_tax_alloc_acctd_amt      := currRound(p_adj_rec.tax_adjusted * P_exchange_rate,
                                                                    p_ae_sys_rec.base_currency);
        l_ar_base_dist_amts_gt.base_dist_amt        :=  p_adj_rec.tax_adjusted;
        l_ar_base_dist_amts_gt.base_dist_acctd_amt  :=  currRound(p_adj_rec.tax_adjusted * P_exchange_rate,
                                                                     p_ae_sys_rec.base_currency);
        l_ra_ar_gt.source_type                 :=  'TAX';
        l_ra_ar_gt.source_table                :=  'ADJ';
        l_ra_ar_gt.source_id                   :=  p_adj_rec.adjustment_id;
        l_ra_ar_gt.gp_level                    :=  'D';
        l_ra_ar_gt.group_id                    :=  '00';
  --{HYUBPAGP
        l_ra_ar_gt.source_data_key1            :=  '00';
        l_ra_ar_gt.source_data_key2            :=  '00';
        l_ra_ar_gt.source_data_key3            :=  '00';
        l_ra_ar_gt.source_data_key4            :=  '00';
        l_ra_ar_gt.source_data_key5            :=  '00';
  --}
--        l_ra_ar_gt.se_gt_id                    := g_se_gt_id;
        l_ra_ar_gt.set_of_books_id             := p_ae_sys_rec.set_of_books_id;
        l_ra_ar_gt.sob_type                    := p_ae_sys_rec.sob_type;
        l_ra_ar_gt.activity_bucket                      := 'ADJ';
        insert_ra_ar_gt(p_ra_ar_gt  =>  l_ra_ar_gt,
	                p_ar_base_dist_amts_gt => l_ar_base_dist_amts_gt,
			p_ra_ar_amounts_gt => l_ra_ar_amounts_gt
			);
      END IF;
  END tax_boundary;
/*
  Freight boundary procedure is not usefull at this time because frt adjustment
  is over revenue line and not freight lines
  Keep this procedure for future

  PROCEDURE freight_boundary
  (p_adj_rec            IN ar_adjustments%ROWTYPE,
   p_sum_line_frt_orig_amt  IN NUMBER,
   p_sum_line_frt_rem_amt   IN NUMBER,
   p_inv_currency       IN VARCHAR2,
   p_customer_trx_id    IN NUMBER,
   p_gt_id              IN NUMBER,
   p_ae_sys_rec         IN arp_acct_main.ae_sys_rec_type)
  IS
    l_ra_ar_gt              ra_ar_gt%ROWTYPE;
  BEGIN
      IF NVL(p_adj_rec.freight_adjusted,0) <> 0 AND
         NVL(p_sum_line_frt_orig_amt,0)  = 0 AND
         NVL(p_sum_line_frt_rem_amt,0)   = 0
      THEN
        localdebug('   -9 Adjustment Boundary FREIGHT condition met');
        l_ra_ar_gt.GT_ID      :=  p_gt_id;
        l_ra_ar_gt.AMT        :=  p_adj_rec.freight_adjusted;
        l_ra_ar_gt.ACCTD_AMT  :=  currRound(p_adj_rec.freight_adjusted,
                                                    p_ae_sys_rec.base_currency);
        l_ra_ar_gt.ACCOUNT_CLASS               :=  'FREIGHT';
        l_ra_ar_gt.CCID_SECONDARY              :=  NULL; --Normally the auto accounting ccid
        l_ra_ar_gt.REF_CUST_TRX_LINE_GL_DIST_ID:=  -9;
        l_ra_ar_gt.REF_CUSTOMER_TRX_LINE_ID    :=  -9;
        l_ra_ar_gt.REF_CUSTOMER_TRX_ID         :=  p_customer_trx_id;
        l_ra_ar_gt.DIST_AMT  :=  p_adj_rec.freight_adjusted;
        l_ra_ar_gt.DIST_ACCTD_AMT :=  currRound(p_adj_rec.tax_adjusted,
                                                        p_ae_sys_rec.base_currency);
        l_ra_ar_gt.TO_CURRENCY    :=  p_inv_currency;
        l_ra_ar_gt.BASE_CURRENCY  :=  p_ae_sys_rec.base_currency;
        l_ra_ar_gt.tl_chrg_alloc_amt          :=  0;
        l_ra_ar_gt.tl_chrg_alloc_acctd_amt    :=  0;
        l_ra_ar_gt.tl_tax_alloc_amt          := 0;
        l_ra_ar_gt.tl_tax_alloc_acctd_amt    := 0;
        l_ra_ar_gt.tl_alloc_amt          := 0;
        l_ra_ar_gt.tl_alloc_acctd_amt    := 0;
        l_ra_ar_gt.tl_frt_alloc_amt          :=  p_adj_rec.freight_adjusted;
        l_ra_ar_gt.tl_frt_alloc_acctd_amt    := currRound(p_adj_rec.freight_adjusted,
                                                              p_ae_sys_rec.base_currency);
        l_ra_ar_gt.base_dist_amt           :=  p_adj_rec.freight_adjusted;
        l_ra_ar_gt.base_dist_acctd_amt     :=  currRound(p_adj_rec.freight_adjusted,
                                                                     p_ae_sys_rec.base_currency);
        l_ra_ar_gt.source_type                 :=  'FREIGHT';
        l_ra_ar_gt.source_table                :=  'ADJ';
        l_ra_ar_gt.source_id                   :=  p_adj_rec.adjustment_id;
        l_ra_ar_gt.gp_level                    :=  'D';
        l_ra_ar_gt.group_id                    :=  '00';
        insert_ra_ar_gt(p_ra_ar_gt  =>  l_ra_ar_gt);
      END IF;
  END freight_boundary;
*/
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.adjustment_detemination()+');
  END IF;

  IF p_pay_adj <> 'ADJ' THEN
     RAISE not_an_adjustment;
  END IF;

  OPEN get_sum_per_line_type;
  FETCH get_sum_per_line_type BULK COLLECT INTO
             l_sum_line_rem_amt           ,
             l_sum_line_rem_acctd_amt     ,
             l_sum_line_orig_amt          ,
             l_sum_line_orig_acctd_amt    ,
             l_sum_line_chrg_rem_amt      ,
             l_sum_line_chrg_rem_acctd_amt,
             --
             l_sum_line_frt_rem_amt       ,
             l_sum_line_frt_rem_acctd_amt ,
             l_sum_line_frt_orig_amt      ,
             l_sum_line_frt_orig_acctd_amt,
             --
             l_sum_line_tax_rem_amt       ,
             l_sum_line_tax_rem_acctd_amt ,
             l_sum_line_tax_orig_amt      ,
             l_sum_line_tax_orig_acctd_amt,
             --
             l_line_type;
  CLOSE get_sum_per_line_type;
/*
  OPEN get_sum_per_line_type;
  FETCH get_sum_per_line_type BULK COLLECT INTO
             l_sum_line_rem_amt           ,
             l_sum_line_rem_acctd_amt     ,
             --
             l_sum_line_chrg_rem_amt      ,
             l_sum_line_chrg_rem_acctd_amt,
             --
             l_sum_line_frt_rem_amt       ,
             l_sum_line_frt_rem_acctd_amt ,
             --
             l_sum_line_tax_rem_amt       ,
             l_sum_line_tax_rem_acctd_amt ,
             --
             l_line_type;
  CLOSE get_sum_per_line_type;
*/
  IF l_line_type.COUNT = 0 THEN
     RAISE invoice_has_no_lines;
  END IF;
  /*Bug 7698161 Added new parameter in boundary condition for exchange rate
    passed value for it in calls for rutines
    line_boundary
    tax_boundary
    Used exchange rate to get accounted amount
  */
  l_exchange_rate := NULL;
  OPEN cu_inv_cur;
    FETCH cu_inv_cur INTO l_inv_currency,l_exchange_rate;
  CLOSE cu_inv_cur;
  l_exchange_rate := nvl(l_exchange_rate,1);

  FOR i IN l_line_type.FIRST .. l_line_type.LAST LOOP
    IF PG_DEBUG = 'Y' THEN
    localdebug('  Current line type :'||l_line_type(i));
    END IF;
      IF     l_line_type(i) IN ('LINE','CB') THEN
        line_boundary  (p_adj_rec            => p_adj_rec,
                        p_sum_line_orig_amt  => l_sum_line_orig_amt(i),
                        p_sum_line_rem_amt   => l_sum_line_rem_amt(i),
                        p_inv_currency       => l_inv_currency,
                        p_customer_trx_id    => p_customer_trx_id,
                        p_gt_id              => p_gt_id,
                        p_ae_sys_rec         => p_ae_sys_rec,
				p_exchange_rate      => l_exchange_rate);
        l_line_boundary_done := 'Y';
        l_freight_boundary_done  := 'Y';
        l_chrg_boundary_done := 'Y';
      ELSIF  l_line_type(i) = 'TAX' THEN

        tax_boundary   (p_adj_rec            => p_adj_rec,
                        p_sum_line_tax_orig_amt  => l_sum_line_tax_orig_amt(i),
                        p_sum_line_tax_rem_amt   => l_sum_line_tax_rem_amt(i),
                        p_inv_currency       => l_inv_currency,
                        p_customer_trx_id    => p_customer_trx_id,
                        p_gt_id              => p_gt_id,
                        p_ae_sys_rec         => p_ae_sys_rec,
				p_exchange_rate      => l_exchange_rate);
        l_tax_boundary_done := 'Y';

      /* Freight adj boundary part on revenue line because frt adj are tied to
         Rev lines
      ELSIF  l_line_type(i) = 'FREIGHT' THEN

        freight_boundary(p_adj_rec            => p_adj_rec,
                        p_sum_line_frt_orig_amt  => l_sum_line_frt_orig_amt(i),
                        p_sum_line_frt_rem_amt   => l_sum_line_frt_rem_amt(i),
                        p_inv_currency       => l_inv_currency,
                        p_customer_trx_id    => p_customer_trx_id,
                        p_gt_id              => p_gt_id,
                        p_ae_sys_rec         => p_ae_sys_rec);
        l_freight_boundary_done := 'Y';
        */
     END IF;
  END LOOP;

  IF  l_line_boundary_done <> 'Y' THEN
        line_boundary  (p_adj_rec            => p_adj_rec,
                        p_sum_line_orig_amt  => 0,
                        p_sum_line_rem_amt   => 0,
                        p_inv_currency       => l_inv_currency,
                        p_customer_trx_id    => p_customer_trx_id,
                        p_gt_id              => p_gt_id,
                        p_ae_sys_rec         => p_ae_sys_rec,
				p_exchange_rate      => l_exchange_rate);
        l_line_boundary_done    := 'Y';
        l_freight_boundary_done := 'Y';
        l_chrg_boundary_done    := 'Y';
  END IF;

/*
  IF l_freight_boundary_done <> 'Y' THEN
        freight_boundary(p_adj_rec           => p_adj_rec,
                        p_sum_line_frt_orig_amt  => 0,
                        p_sum_line_frt_rem_amt   => 0,
                        p_inv_currency       => l_inv_currency,
                        p_customer_trx_id    => p_customer_trx_id,
                        p_gt_id              => p_gt_id,
                        p_ae_sys_rec         => p_ae_sys_rec);
        l_freight_boundary_done := 'Y';
  END IF;
*/
  IF  l_tax_boundary_done <> 'Y' THEN
        tax_boundary   (p_adj_rec            => p_adj_rec,
                        p_sum_line_tax_orig_amt  => 0,
                        p_sum_line_tax_rem_amt   => 0,
                        p_inv_currency       => l_inv_currency,
                        p_customer_trx_id    => p_customer_trx_id,
                        p_gt_id              => p_gt_id,
                        p_ae_sys_rec         => p_ae_sys_rec,
				p_exchange_rate      => l_exchange_rate);
        l_tax_boundary_done := 'Y';
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.adjustment_detemination()-');
  END IF;
EXCEPTION
  WHEN not_an_adjustment  THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  EXCEPTION not_an_adjustment IN adjustment_detemination:'||'
'||                    '    p_customer_trx_id : '||p_customer_trx_id ||'
'||                    '    p_pay_adj         : '||p_pay_adj);

END IF;
  WHEN invoice_has_no_lines THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  EXCEPTION invoice_has_no_lines IN adjustment_detemination:'||'
'||                    '    p_customer_trx_id : '||p_customer_trx_id );

END IF;
--    RAISE;
END adjustment_detemination;




PROCEDURE update_group_line
(p_gt_id           IN VARCHAR2,
 p_customer_trx_id IN NUMBER,
 p_ae_sys_rec      IN arp_acct_main.ae_sys_rec_type)
IS
  CURSOR c_read_for_gline IS
    SELECT /*+ leading(B) INDEX(B ra_ar_n1) INDEX(D RA_AR_AMOUNTS_GT_N1)*/
           b.group_id     groupe,
         -- ADJ AND APP
           --Base
           d.base_pro_amt,
           d.base_pro_acctd_amt,
           d.base_frt_pro_amt,
           d.base_frt_pro_acctd_amt,
           d.base_tax_pro_amt,
           d.base_tax_pro_acctd_amt,
           d.BASE_CHRG_PRO_AMT,
           d.BASE_CHRG_PRO_ACCTD_AMT,
           --Element
           d.elmt_pro_amt,
           d.elmt_pro_acctd_amt,
           d.elmt_frt_pro_amt,
           d.elmt_frt_pro_acctd_amt,
           d.elmt_tax_pro_amt,
           d.elmt_tax_pro_acctd_amt,
           d.ELMT_CHRG_PRO_AMT,
           d.ELMT_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           d.buc_alloc_amt,
           d.buc_alloc_acctd_amt,
           d.buc_frt_alloc_amt,
           d.buc_frt_alloc_acctd_amt,
           d.buc_tax_alloc_amt,
           d.buc_tax_alloc_acctd_amt,
           d.buc_chrg_alloc_amt,
           d.buc_chrg_alloc_acctd_amt,
         -- ED
           --Base
           d.base_ed_pro_amt,
           d.base_ed_pro_acctd_amt,
           d.base_ed_frt_pro_amt,
           d.base_ed_frt_pro_acctd_amt,
           d.base_ed_tax_pro_amt,
           d.base_ed_tax_pro_acctd_amt,
           d.BASE_ed_CHRG_PRO_AMT,
           d.BASE_ed_CHRG_PRO_ACCTD_AMT,
           --Element
           d.elmt_ed_pro_amt,
           d.elmt_ed_pro_acctd_amt,
           d.elmt_ed_frt_pro_amt,
           d.elmt_ed_frt_pro_acctd_amt,
           d.elmt_ed_tax_pro_amt,
           d.elmt_ed_tax_pro_acctd_amt,
           d.ELMT_ed_CHRG_PRO_AMT,
           d.ELMT_ed_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           d.buc_ed_alloc_amt,
           d.buc_ed_alloc_acctd_amt,
           d.buc_ed_frt_alloc_amt,
           d.buc_ed_frt_alloc_acctd_amt,
           d.buc_ed_tax_alloc_amt,
           d.buc_ed_tax_alloc_acctd_amt,
           d.buc_ed_chrg_alloc_amt,
           d.buc_ed_chrg_alloc_acctd_amt,
         -- UNED
           --Base
           d.base_uned_pro_amt,
           d.base_uned_pro_acctd_amt,
           d.base_uned_frt_pro_amt,
           d.base_uned_frt_pro_acctd_amt,
           d.base_uned_tax_pro_amt,
           d.base_uned_tax_pro_acctd_amt,
           d.BASE_uned_CHRG_PRO_AMT,
           d.BASE_uned_CHRG_PRO_ACCTD_AMT,
           --Element
           d.elmt_uned_pro_amt,
           d.elmt_uned_pro_acctd_amt,
           d.elmt_uned_frt_pro_amt,
           d.elmt_uned_frt_pro_acctd_amt,
           d.elmt_uned_tax_pro_amt,
           d.elmt_uned_tax_pro_acctd_amt,
           d.ELMT_uned_CHRG_PRO_AMT,
           d.ELMT_uned_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           d.buc_uned_alloc_amt,
           d.buc_uned_alloc_acctd_amt,
           d.buc_uned_frt_alloc_amt,
           d.buc_uned_frt_alloc_acctd_amt,
           d.buc_uned_tax_alloc_amt,
           d.buc_uned_tax_alloc_acctd_amt,
           d.buc_uned_chrg_alloc_amt,
           d.buc_uned_chrg_alloc_acctd_amt,
         ----
           --Currencies
           b.BASE_CURRENCY  ,
           b.TO_CURRENCY    ,
           b.FROM_CURRENCY  ,
           -- Rowid
           b.rowid
     FROM  RA_AR_GT b,
           RA_AR_AMOUNTS_GT d
    WHERE b.gt_id               = p_gt_id
      AND b.ref_customer_trx_id = p_customer_trx_id
      AND b.gp_level            = 'GPL'
      AND d.gt_id               = b.gt_id
      AND d.base_rec_rowid      = b.rowid
      AND b.SET_OF_BOOKS_ID     = p_ae_sys_rec.set_of_books_id
      AND (b.SOB_TYPE            = p_ae_sys_rec.sob_type OR
            (b.SOB_TYPE IS NULL AND p_ae_sys_rec.sob_type IS NULL))
    ORDER BY b.group_id||'-'||
             b.line_type||'-'||
	     b.ref_customer_trx_line_id;

  l_tab  pro_res_tbl_type;

  l_group_tbl            group_tbl_type;
  l_group                VARCHAR2(60)    := 'NOGROUP';

  -- ADJ and APP
  l_run_amt              NUMBER          := 0;
  l_run_alloc            NUMBER          := 0;
  l_run_acctd_amt        NUMBER          := 0;
  l_run_acctd_alloc      NUMBER          := 0;
  l_alloc                NUMBER          := 0;
  l_acctd_alloc          NUMBER          := 0;

  l_run_chrg_amt         NUMBER          := 0;
  l_run_chrg_alloc       NUMBER          := 0;
  l_run_chrg_acctd_amt   NUMBER          := 0;
  l_run_chrg_acctd_alloc NUMBER          := 0;
  l_chrg_alloc           NUMBER          := 0;
  l_chrg_acctd_alloc     NUMBER          := 0;

  l_run_frt_amt         NUMBER          := 0;
  l_run_frt_alloc       NUMBER          := 0;
  l_run_frt_acctd_amt   NUMBER          := 0;
  l_run_frt_acctd_alloc NUMBER          := 0;
  l_frt_alloc           NUMBER          := 0;
  l_frt_acctd_alloc     NUMBER          := 0;

  l_run_tax_amt         NUMBER          := 0;
  l_run_tax_alloc       NUMBER          := 0;
  l_run_tax_acctd_amt   NUMBER          := 0;
  l_run_tax_acctd_alloc NUMBER          := 0;
  l_tax_alloc           NUMBER          := 0;
  l_tax_acctd_alloc     NUMBER          := 0;

  -- ED
  l_run_ed_amt              NUMBER          := 0;
  l_run_ed_alloc            NUMBER          := 0;
  l_run_ed_acctd_amt        NUMBER          := 0;
  l_run_ed_acctd_alloc      NUMBER          := 0;
  l_ed_alloc                NUMBER          := 0;
  l_ed_acctd_alloc          NUMBER          := 0;

  l_run_ed_chrg_amt         NUMBER          := 0;
  l_run_ed_chrg_alloc       NUMBER          := 0;
  l_run_ed_chrg_acctd_amt   NUMBER          := 0;
  l_run_ed_chrg_acctd_alloc NUMBER          := 0;
  l_ed_chrg_alloc           NUMBER          := 0;
  l_ed_chrg_acctd_alloc     NUMBER          := 0;

  l_run_ed_frt_amt         NUMBER          := 0;
  l_run_ed_frt_alloc       NUMBER          := 0;
  l_run_ed_frt_acctd_amt   NUMBER          := 0;
  l_run_ed_frt_acctd_alloc NUMBER          := 0;
  l_ed_frt_alloc           NUMBER          := 0;
  l_ed_frt_acctd_alloc     NUMBER          := 0;

  l_run_ed_tax_amt         NUMBER          := 0;
  l_run_ed_tax_alloc       NUMBER          := 0;
  l_run_ed_tax_acctd_amt   NUMBER          := 0;
  l_run_ed_tax_acctd_alloc NUMBER          := 0;
  l_ed_tax_alloc           NUMBER          := 0;
  l_ed_tax_acctd_alloc     NUMBER          := 0;

  -- UNED
  l_run_uned_amt              NUMBER          := 0;
  l_run_uned_alloc            NUMBER          := 0;
  l_run_uned_acctd_amt        NUMBER          := 0;
  l_run_uned_acctd_alloc      NUMBER          := 0;
  l_uned_alloc                NUMBER          := 0;
  l_uned_acctd_alloc          NUMBER          := 0;

  l_run_uned_chrg_amt         NUMBER          := 0;
  l_run_uned_chrg_alloc       NUMBER          := 0;
  l_run_uned_chrg_acctd_amt   NUMBER          := 0;
  l_run_uned_chrg_acctd_alloc NUMBER          := 0;
  l_uned_chrg_alloc           NUMBER          := 0;
  l_uned_chrg_acctd_alloc     NUMBER          := 0;

  l_run_uned_frt_amt         NUMBER          := 0;
  l_run_uned_frt_alloc       NUMBER          := 0;
  l_run_uned_frt_acctd_amt   NUMBER          := 0;
  l_run_uned_frt_acctd_alloc NUMBER          := 0;
  l_uned_frt_alloc           NUMBER          := 0;
  l_uned_frt_acctd_alloc     NUMBER          := 0;

  l_run_uned_tax_amt         NUMBER          := 0;
  l_run_uned_tax_alloc       NUMBER          := 0;
  l_run_uned_tax_acctd_amt   NUMBER          := 0;
  l_run_uned_tax_acctd_alloc NUMBER          := 0;
  l_uned_tax_alloc           NUMBER          := 0;
  l_uned_tax_acctd_alloc     NUMBER          := 0;

  l_exist                BOOLEAN;
  l_last_fetch           BOOLEAN;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_group_line()+');
  END IF;

  OPEN  c_read_for_gline;
  LOOP
    FETCH c_read_for_gline BULK COLLECT INTO
     l_tab.GROUPE                  ,
   -- ADJ and APP
     -- Base
     l_tab.base_pro_amt       ,
     l_tab.base_pro_acctd_amt ,
     l_tab.base_frt_pro_amt       ,
     l_tab.base_frt_pro_acctd_amt ,
     l_tab.base_tax_pro_amt       ,
     l_tab.base_tax_pro_acctd_amt ,
     l_tab.BASE_CHRG_PRO_AMT       ,
     l_tab.BASE_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_pro_amt       ,
     l_tab.elmt_pro_acctd_amt ,
     l_tab.elmt_frt_pro_amt       ,
     l_tab.elmt_frt_pro_acctd_amt ,
     l_tab.elmt_tax_pro_amt       ,
     l_tab.elmt_tax_pro_acctd_amt ,
     l_tab.ELMT_CHRG_PRO_AMT       ,
     l_tab.ELMT_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_alloc_amt      ,
     l_tab.buc_alloc_acctd_amt,
     l_tab.buc_frt_alloc_amt      ,
     l_tab.buc_frt_alloc_acctd_amt,
     l_tab.buc_tax_alloc_amt      ,
     l_tab.buc_tax_alloc_acctd_amt,
     l_tab.buc_chrg_alloc_amt      ,
     l_tab.buc_chrg_alloc_acctd_amt,
   -- ED
     -- Base
     l_tab.base_ed_pro_amt       ,
     l_tab.base_ed_pro_acctd_amt ,
     l_tab.base_ed_frt_pro_amt       ,
     l_tab.base_ed_frt_pro_acctd_amt ,
     l_tab.base_ed_tax_pro_amt       ,
     l_tab.base_ed_tax_pro_acctd_amt ,
     l_tab.BASE_ed_CHRG_PRO_AMT       ,
     l_tab.BASE_ed_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_ed_pro_amt       ,
     l_tab.elmt_ed_pro_acctd_amt ,
     l_tab.elmt_ed_frt_pro_amt       ,
     l_tab.elmt_ed_frt_pro_acctd_amt ,
     l_tab.elmt_ed_tax_pro_amt       ,
     l_tab.elmt_ed_tax_pro_acctd_amt ,
     l_tab.ELMT_ed_CHRG_PRO_AMT       ,
     l_tab.ELMT_ed_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_ed_alloc_amt      ,
     l_tab.buc_ed_alloc_acctd_amt,
     l_tab.buc_ed_frt_alloc_amt      ,
     l_tab.buc_ed_frt_alloc_acctd_amt,
     l_tab.buc_ed_tax_alloc_amt      ,
     l_tab.buc_ed_tax_alloc_acctd_amt,
     l_tab.buc_ed_chrg_alloc_amt      ,
     l_tab.buc_ed_chrg_alloc_acctd_amt,
   -- UNED
     -- Base
     l_tab.base_uned_pro_amt       ,
     l_tab.base_uned_pro_acctd_amt ,
     l_tab.base_uned_frt_pro_amt       ,
     l_tab.base_uned_frt_pro_acctd_amt ,
     l_tab.base_uned_tax_pro_amt       ,
     l_tab.base_uned_tax_pro_acctd_amt ,
     l_tab.BASE_uned_CHRG_PRO_AMT       ,
     l_tab.BASE_uned_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_uned_pro_amt       ,
     l_tab.elmt_uned_pro_acctd_amt ,
     l_tab.elmt_uned_frt_pro_amt       ,
     l_tab.elmt_uned_frt_pro_acctd_amt ,
     l_tab.elmt_uned_tax_pro_amt       ,
     l_tab.elmt_uned_tax_pro_acctd_amt ,
     l_tab.ELMT_uned_CHRG_PRO_AMT       ,
     l_tab.ELMT_uned_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_uned_alloc_amt      ,
     l_tab.buc_uned_alloc_acctd_amt,
     l_tab.buc_uned_frt_alloc_amt      ,
     l_tab.buc_uned_frt_alloc_acctd_amt,
     l_tab.buc_uned_tax_alloc_amt      ,
     l_tab.buc_uned_tax_alloc_acctd_amt,
     l_tab.buc_uned_chrg_alloc_amt      ,
     l_tab.buc_uned_chrg_alloc_acctd_amt,
     --
     l_tab.BASE_CURRENCY  ,
     l_tab.TO_CURRENCY    ,
     l_tab.FROM_CURRENCY  ,
     --
     l_tab.ROWID_ID     LIMIT g_bulk_fetch_rows;

     IF c_read_for_gline%NOTFOUND THEN
          l_last_fetch := TRUE;
     END IF;

     IF (l_tab.ROWID_ID.COUNT = 0) AND (l_last_fetch) THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug('COUNT = 0 and LAST FETCH ');
       END IF;
       EXIT;
     END IF;

     plsql_proration( x_tab               => l_tab,
                   x_group_tbl            => l_group_tbl,
                   -- ADJ and APP
                   x_run_amt              => l_run_amt,
                   x_run_alloc            => l_run_alloc,
                   x_run_acctd_amt        => l_run_acctd_amt,
                   x_run_acctd_alloc      => l_run_acctd_alloc,
                   x_run_frt_amt         => l_run_frt_amt,
                   x_run_frt_alloc       => l_run_frt_alloc,
                   x_run_frt_acctd_amt   => l_run_frt_acctd_amt,
                   x_run_frt_acctd_alloc => l_run_frt_acctd_alloc,
                   x_run_tax_amt         => l_run_tax_amt,
                   x_run_tax_alloc       => l_run_tax_alloc,
                   x_run_tax_acctd_amt   => l_run_tax_acctd_amt,
                   x_run_tax_acctd_alloc => l_run_tax_acctd_alloc,
                   x_run_chrg_amt         => l_run_chrg_amt,
                   x_run_chrg_alloc       => l_run_chrg_alloc,
                   x_run_chrg_acctd_amt   => l_run_chrg_acctd_amt,
                   x_run_chrg_acctd_alloc => l_run_chrg_acctd_alloc,
                   -- ED
                   x_run_ed_amt              => l_run_ed_amt,
                   x_run_ed_alloc            => l_run_ed_alloc,
                   x_run_ed_acctd_amt        => l_run_ed_acctd_amt,
                   x_run_ed_acctd_alloc      => l_run_ed_acctd_alloc,
                   x_run_ed_frt_amt         => l_run_ed_frt_amt,
                   x_run_ed_frt_alloc       => l_run_ed_frt_alloc,
                   x_run_ed_frt_acctd_amt   => l_run_ed_frt_acctd_amt,
                   x_run_ed_frt_acctd_alloc => l_run_ed_frt_acctd_alloc,
                   x_run_ed_tax_amt         => l_run_ed_tax_amt,
                   x_run_ed_tax_alloc       => l_run_ed_tax_alloc,
                   x_run_ed_tax_acctd_amt   => l_run_ed_tax_acctd_amt,
                   x_run_ed_tax_acctd_alloc => l_run_ed_tax_acctd_alloc,
                   x_run_ed_chrg_amt         => l_run_ed_chrg_amt,
                   x_run_ed_chrg_alloc       => l_run_ed_chrg_alloc,
                   x_run_ed_chrg_acctd_amt   => l_run_ed_chrg_acctd_amt,
                   x_run_ed_chrg_acctd_alloc => l_run_ed_chrg_acctd_alloc,
                   -- UNED
                   x_run_uned_amt              => l_run_uned_amt,
                   x_run_uned_alloc            => l_run_uned_alloc,
                   x_run_uned_acctd_amt        => l_run_uned_acctd_amt,
                   x_run_uned_acctd_alloc      => l_run_uned_acctd_alloc,
                   x_run_uned_frt_amt         => l_run_uned_frt_amt,
                   x_run_uned_frt_alloc       => l_run_uned_frt_alloc,
                   x_run_uned_frt_acctd_amt   => l_run_uned_frt_acctd_amt,
                   x_run_uned_frt_acctd_alloc => l_run_uned_frt_acctd_alloc,
                   x_run_uned_tax_amt         => l_run_uned_tax_amt,
                   x_run_uned_tax_alloc       => l_run_uned_tax_alloc,
                   x_run_uned_tax_acctd_amt   => l_run_uned_tax_acctd_amt,
                   x_run_uned_tax_acctd_alloc => l_run_uned_tax_acctd_alloc,
                   x_run_uned_chrg_amt         => l_run_uned_chrg_amt,
                   x_run_uned_chrg_alloc       => l_run_uned_chrg_alloc,
                   x_run_uned_chrg_acctd_amt   => l_run_uned_chrg_acctd_amt,
                   x_run_uned_chrg_acctd_alloc => l_run_uned_chrg_acctd_alloc);

    IF PG_DEBUG = 'Y' THEN
    localdebug('update ra_ar_gt trx_line_all ');
    END IF;
    FORALL i IN l_tab.ROWID_ID.FIRST .. l_tab.ROWID_ID.LAST
      UPDATE ra_ar_gt
      SET
          -- ADJ and APP
           tl_alloc_amt         = l_tab.tl_alloc_amt(i),
           tl_alloc_acctd_amt   = l_tab.tl_alloc_acctd_amt(i),
           tl_frt_alloc_amt         = l_tab.tl_frt_alloc_amt(i),
           tl_frt_alloc_acctd_amt   = l_tab.tl_frt_alloc_acctd_amt(i),
           tl_tax_alloc_amt         = l_tab.tl_tax_alloc_amt(i),
           tl_tax_alloc_acctd_amt   = l_tab.tl_tax_alloc_acctd_amt(i),
           tl_chrg_alloc_amt    = l_tab.tl_chrg_alloc_amt(i),
           tl_chrg_alloc_acctd_amt = l_tab.tl_chrg_alloc_acctd_amt(i),
          -- ED
           tl_ed_alloc_amt         = l_tab.tl_ed_alloc_amt(i),
           tl_ed_alloc_acctd_amt   = l_tab.tl_ed_alloc_acctd_amt(i),
           tl_ed_frt_alloc_amt         = l_tab.tl_ed_frt_alloc_amt(i),
           tl_ed_frt_alloc_acctd_amt   = l_tab.tl_ed_frt_alloc_acctd_amt(i),
           tl_ed_tax_alloc_amt         = l_tab.tl_ed_tax_alloc_amt(i),
           tl_ed_tax_alloc_acctd_amt   = l_tab.tl_ed_tax_alloc_acctd_amt(i),
           tl_ed_chrg_alloc_amt    = l_tab.tl_ed_chrg_alloc_amt(i),
           tl_ed_chrg_alloc_acctd_amt = l_tab.tl_ed_chrg_alloc_acctd_amt(i),
          -- UNED
           tl_uned_alloc_amt         = l_tab.tl_uned_alloc_amt(i),
           tl_uned_alloc_acctd_amt   = l_tab.tl_uned_alloc_acctd_amt(i),
           tl_uned_frt_alloc_amt         = l_tab.tl_uned_frt_alloc_amt(i),
           tl_uned_frt_alloc_acctd_amt   = l_tab.tl_uned_frt_alloc_acctd_amt(i),
           tl_uned_tax_alloc_amt         = l_tab.tl_uned_tax_alloc_amt(i),
           tl_uned_tax_alloc_acctd_amt   = l_tab.tl_uned_tax_alloc_acctd_amt(i),
           tl_uned_chrg_alloc_amt    = l_tab.tl_uned_chrg_alloc_amt(i),
           tl_uned_chrg_alloc_acctd_amt = l_tab.tl_uned_chrg_alloc_acctd_amt(i)
      WHERE rowid                     = l_tab.ROWID_ID(i);

  END LOOP;
  CLOSE c_read_for_gline;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_group_line()-');
  END IF;
END update_group_line;


PROCEDURE get_invoice_line_info_per_grp
(p_gt_id               IN VARCHAR2,
 p_customer_trx_id     IN NUMBER,
-- p_group_id            IN VARCHAR2,
  --{HYUBPAGP
 p_source_data_key1    IN VARCHAR2,
 p_source_data_key2    IN VARCHAR2,
 p_source_data_key3    IN VARCHAR2,
 p_source_data_key4    IN VARCHAR2,
 p_source_data_key5    IN VARCHAR2,
  --}
 p_ae_sys_rec          IN arp_acct_main.ae_sys_rec_type)
IS
  l_rows NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_invoice_line_info_per_grp()+');
  localdebug('   p_customer_trx_id :'||p_customer_trx_id);
  localdebug('   p_source_data_key1  :'||p_source_data_key1);
  localdebug('   p_source_data_key2  :'||p_source_data_key2);
  localdebug('   p_source_data_key3  :'||p_source_data_key3);
  localdebug('   p_source_data_key4  :'||p_source_data_key4);
  localdebug('   p_source_data_key5  :'||p_source_data_key5);
  localdebug('   p_gt_id           :'||p_gt_id);
  END IF;

  INSERT INTO RA_AR_GT
      ( GT_ID                     ,
        BASE_CURRENCY             ,
        TO_CURRENCY               ,
        REF_CUSTOMER_TRX_ID       ,
        REF_CUSTOMER_TRX_LINE_ID  ,
        --
        DUE_ORIG_AMT              ,
        DUE_ORIG_ACCTD_AMT        ,
--{line of type CHRG
        CHRG_ORIG_AMT           ,
        CHRG_ORIG_ACCTD_AMT     ,
--}
        --
        FRT_ORIG_AMT              ,
        FRT_ORIG_ACCTD_AMT        ,
        TAX_ORIG_AMT              ,
        TAX_ORIG_ACCTD_AMT        ,
        --
        DUE_REM_AMT               ,
        DUE_REM_ACCTD_AMT         ,
        CHRG_REM_AMT              ,
        CHRG_REM_ACCTD_AMT        ,
        --
          FRT_REM_AMT               ,
          FRT_REM_ACCTD_AMT         ,
          TAX_REM_AMT               ,
          TAX_REM_ACCTD_AMT         ,
          --
--{line of type CHRG
          CHRG_ADJ_REM_AMT           ,
          CHRG_ADJ_REM_ACCTD_AMT     ,
--}
          FRT_ADJ_REM_AMT           ,
          FRT_ADJ_REM_ACCTD_AMT     ,
        --
        LINE_TYPE                 ,
        group_id                  ,
  --{For Group identification
  source_data_key1  ,
  source_data_key2  ,
  source_data_key3  ,
  source_data_key4  ,
  source_data_key5  ,
  --}
        --
        SUM_LINE_ORIG_AMT        ,
        SUM_LINE_ORIG_ACCTD_AMT  ,
--{line of type CHRG
        SUM_LINE_CHRG_ORIG_AMT        ,
        SUM_LINE_CHRG_ORIG_ACCTD_AMT  ,
--}
        SUM_LINE_FRT_ORIG_AMT        ,
        SUM_LINE_FRT_ORIG_ACCTD_AMT  ,
        SUM_LINE_TAX_ORIG_AMT        ,
        SUM_LINE_TAX_ORIG_ACCTD_AMT  ,
        --
        SUM_LINE_REM_AMT         ,
        SUM_LINE_REM_ACCTD_AMT   ,
        SUM_LINE_CHRG_REM_AMT    ,
        SUM_LINE_CHRG_REM_ACCTD_AMT,
        --
          SUM_LINE_FRT_REM_AMT        ,
          SUM_LINE_FRT_REM_ACCTD_AMT  ,
          SUM_LINE_TAX_REM_AMT        ,
          SUM_LINE_TAX_REM_ACCTD_AMT  ,
        --
        gp_level,
        --
        set_of_books_id,
        sob_type
--        se_gt_id
        )
     SELECT /*+INDEX (ctl ra_customer_trx_lines_gt_n1)*/
	        p_gt_id                       ,  --GT_ID
            p_ae_sys_rec.base_currency    ,  --BASE_CURRENCY
            trx.invoice_currency_code     ,  --TO_CURRENCY
            trx.customer_trx_id           ,  --REF_CUSTOMER_TRX_ID
            ctl.customer_trx_line_id      ,  --REF_CUSTOMER_TRX_LINE_ID
         -- Orig
            DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                 'CB'  ,ctl.amount_due_original,0),          --DUE_ORIG_AMT
            DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                 'CB'  ,ctl.acctd_amount_due_original,0),    --DUE_ORIG_ACCTD_AMT
--{line of type CHRG
            DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0),       --CHRG_ORIG_AMT
            DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0), --CHRG_ORIG_ACCTD_AMT
--}
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0),       --FRT_ORIG_AMT
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0), --FRT_ORIG_ACCTD_AMT
            DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0),           --TAX_ORIG_AMT
            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0),     --TAX_ORIG_ACCTD_AMT
         -- Remaining
            DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                 'CB'  ,ctl.amount_due_remaining,0) ,        --DUE_REM_AMT
            DECODE(ctl.line_type,'LINE',acctd_amount_due_remaining,
                                 'CB'  ,acctd_amount_due_remaining,0),       --DUE_REM_ACCTD_AMT
--{line of type CHRG
--            ctl.chrg_amount_remaining     ,
--            ctl.chrg_acctd_amount_remaining,
            DECODE(ctl.line_type,'CHARGES',ctl.amount_due_remaining,0) ,     --CHRG_REM_AMT
            DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_remaining,0),--CHRG_REM_ACCTD_AMT
--}
            --
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_remaining,0) ,     --FRT_REM_AMT
                                                            /*Frt Rem on freight is the
                                                              rem amount of the freight calculated
                                                              from orig frt - cash application
                                                              frt adjustment variations are excluded
                                                              they are kept in frt_adj_rem_amt on rev line */
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_remaining,0), --FRT_REM_ACCTD_AMT
            DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0) ,          --TAX_REM_AMT
            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0),     --TAX_REM_ACCTD_AMT
--
--{line of type CHRG
            ctl.chrg_amount_remaining          ,                                --chrg_amount_remaining
            ctl.chrg_acctd_amount_remaining    ,                                --chrg_acctd_amount_remaining
--}
            ctl.frt_adj_remaining          ,                                  --FRT_ADJ_REM_AMT
            ctl.frt_adj_acctd_remaining    ,                                  --FRT_ADJ_REM_ACCTD_AMT
            --
            ctl.line_type                 ,                                  --LINE_TYPE
--            NVL(ctl.SOURCE_DATA_KEY1,'00'),                                --GROUP_ID
           DECODE(ctl.SOURCE_DATA_KEY1 ||
            ctl.SOURCE_DATA_KEY2 ||
            ctl.SOURCE_DATA_KEY3 ||
            ctl.SOURCE_DATA_KEY4 ||
            ctl.SOURCE_DATA_KEY5, NULL, '00',
                 ctl.SOURCE_DATA_KEY1 ||'-'||
                 ctl.SOURCE_DATA_KEY2 ||'-'||
                 ctl.SOURCE_DATA_KEY3 ||'-'||
                 ctl.SOURCE_DATA_KEY4 ||'-'||
                 ctl.SOURCE_DATA_KEY5),                                           --GROUP_ID
  --{Group identification
            NVL(ctl.source_data_key1,'00'),
            NVL(ctl.source_data_key2,'00'),
            NVL(ctl.source_data_key3,'00'),
            NVL(ctl.source_data_key4,'00'),
            NVL(ctl.source_data_key5,'00'),
  --}
            --
            SUM(DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                     'CB'  ,ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type                  ),         --SUM_LINE_ORIG_AMT
            SUM(DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                     'CB'  ,ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type ),                          --SUM_LINE_ORIG_ACCTD_AMT
--{line of type CHRG
            SUM(DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type ),                          --SUM_LINE_CHRG_ORIG_AMT
            SUM(DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type ),                          --SUM_LINE_CHRG_ORIG_ACCTD_AMT
--}
            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type ),                          --SUM_LINE_FRT_ORIG_AMT
            SUM(DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type ),                          --SUM_LINE_FRT_ORIG_ACCTD_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type ),                          --SUM_LINE_TAX_ORIG_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type ),                          --SUM_LINE_TAX_ORIG_ACCTD_AMT
            --
            SUM(DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                     'CB'  ,ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type  ),                         --SUM_LINE_REM_AMT
            SUM(DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_remaining,
                                     'CB'  ,ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,
                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
                                   ctl.line_type  ),                         --SUM_LINE_REM_ACCTD_AMT
--{line of type CHRG
            SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_amount_remaining,0),
                                'CHARGES',NVL(ctl.amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id,
                                           NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY5,'00') ),--SUM_LINE_CHRG_REM_AMT
            SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CB'     ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                'CHARGES',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id,
                                           NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY5,'00') ),--SUM_LINE_CHRG_REM_ACCTD_AMT
--            SUM(ctl.chrg_amount_remaining)
--                OVER (PARTITION BY trx.customer_trx_id,
--                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
--                                   ctl.line_type ),                          --SUM_LINE_CHRG_REM_AMT
--            SUM(ctl.chrg_acctd_amount_remaining)
--                OVER (PARTITION BY trx.customer_trx_id,
--                                   NVL(ctl.SOURCE_DATA_KEY1,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY2,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY3,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY4,'00'),
--                                   NVL(ctl.SOURCE_DATA_KEY5,'00'),
--                                   ctl.line_type ),                          --SUM_LINE_CHRG_REM_ACCTD_AMT
--}
            --
            /* This is the sum of freight amount adjusted on the revenue line
              + sum of freight amount due remaining on the original freight line
              Those 2 amounts combined form the basis for cash receipt apps */
            SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_remaining,0),
                                'FREIGHT',NVL(ctl.amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id,
                                           NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY5,'00') ),--SUM_LINE_FRT_REM_AMT
            SUM(DECODE
                 (ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'CB'     ,NVL(ctl.frt_adj_acctd_remaining,0),
                                'FREIGHT',NVL(ctl.acctd_amount_due_remaining,0),
                                 0)) OVER (PARTITION BY trx.customer_trx_id,
                                           NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY5,'00') ),--SUM_LINE_FRT_REM_ACCTD_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type,
                                           NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY5,'00')),       --SUM_LINE_TAX_REM_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type,
                                           NVL(ctl.SOURCE_DATA_KEY1,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY2,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY3,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY4,'00'),
                                           NVL(ctl.SOURCE_DATA_KEY5,'00')),       --SUM_LINE_TAX_REM_ACCTD_AMT
            --
            'L',
            --
            p_ae_sys_rec.set_of_books_id,
            p_ae_sys_rec.sob_type
--            g_se_gt_id
       FROM ra_customer_trx          trx,
            ra_customer_trx_lines_gt ctl
      WHERE trx.customer_trx_id               = p_customer_trx_id
        AND trx.customer_trx_id               = ctl.customer_trx_id
--        AND NVL(ctl.group_id,'00')            = p_group_id
          --{HYUBPAGP
        AND NVL(ctl.source_data_key1,'00')    = NVL(p_source_data_key1,'00')
        AND NVL(ctl.source_data_key2,'00')    = NVL(p_source_data_key2,'00')
        AND NVL(ctl.source_data_key3,'00')    = NVL(p_source_data_key3,'00')
        AND NVL(ctl.source_data_key4,'00')    = NVL(p_source_data_key4,'00')
        AND NVL(ctl.source_data_key5,'00')    = NVL(p_source_data_key5,'00');
          --}
  l_rows := sql%rowcount;
  g_appln_count := g_appln_count + l_rows;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  rows inserted = ' || l_rows);
  localdebug('arp_det_dist_pkg.get_invoice_line_info_per_grp()-');
  END IF;
END get_invoice_line_info_per_grp;


PROCEDURE get_invoice_line_info_per_line
(p_gt_id                IN VARCHAR2,
 p_customer_trx_id      IN NUMBER,
 p_customer_trx_line_id IN NUMBER,
 p_log_inv_line         IN VARCHAR2 DEFAULT 'N',
 p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type)
IS
  l_rows NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_invoice_line_info_per_line()+');
  localdebug('   p_customer_trx_id       :'||p_customer_trx_id);
  localdebug('   p_customer_trx_line_id  :'||p_customer_trx_line_id);
  localdebug('   p_gt_id                 :'||p_gt_id);
  END IF;

  INSERT INTO RA_AR_GT
      ( GT_ID                     ,
        BASE_CURRENCY             ,
        TO_CURRENCY               ,
        REF_CUSTOMER_TRX_ID       ,
        REF_CUSTOMER_TRX_LINE_ID  ,
        --
        DUE_ORIG_AMT              ,
        DUE_ORIG_ACCTD_AMT        ,
        --
        CHRG_ORIG_AMT              ,
        CHRG_ORIG_ACCTD_AMT        ,
        FRT_ORIG_AMT              ,
        FRT_ORIG_ACCTD_AMT        ,
        TAX_ORIG_AMT              ,
        TAX_ORIG_ACCTD_AMT        ,
        --
        DUE_REM_AMT               ,
        DUE_REM_ACCTD_AMT         ,
        CHRG_REM_AMT              ,
        CHRG_REM_ACCTD_AMT        ,
        --
          FRT_REM_AMT               ,
          FRT_REM_ACCTD_AMT         ,
          TAX_REM_AMT               ,
          TAX_REM_ACCTD_AMT         ,
          --
          FRT_ADJ_REM_AMT           ,
          FRT_ADJ_REM_ACCTD_AMT     ,
        --
        LINE_TYPE                 ,
        group_id                  ,
  --{HYUBPAGP
  source_data_key1  ,
  source_data_key2  ,
  source_data_key3  ,
  source_data_key4  ,
  source_data_key5  ,
  --}
        --
        SUM_LINE_ORIG_AMT        ,
        SUM_LINE_ORIG_ACCTD_AMT  ,
--{HYUCHRG
        SUM_LINE_CHRG_ORIG_AMT              ,
        SUM_LINE_CHRG_ORIG_ACCTD_AMT        ,
--}
        SUM_LINE_FRT_ORIG_AMT        ,
        SUM_LINE_FRT_ORIG_ACCTD_AMT  ,
        SUM_LINE_TAX_ORIG_AMT        ,
        SUM_LINE_TAX_ORIG_ACCTD_AMT  ,
        --
        SUM_LINE_REM_AMT         ,
        SUM_LINE_REM_ACCTD_AMT   ,
        SUM_LINE_CHRG_REM_AMT    ,
        SUM_LINE_CHRG_REM_ACCTD_AMT,
        --
          SUM_LINE_FRT_REM_AMT        ,
          SUM_LINE_FRT_REM_ACCTD_AMT  ,
          SUM_LINE_TAX_REM_AMT        ,
          SUM_LINE_TAX_REM_ACCTD_AMT  ,
        --
        gp_level,
        --
        set_of_books_id,
        sob_type,
        tax_link_id,
        tax_inc_flag)
--        se_gt_id)
     SELECT /*+INDEX (ctl ra_customer_trx_lines_gt_n1)*/
	        p_gt_id                       ,  --GT_ID
            p_ae_sys_rec.base_currency    ,  --BASE_CURRENCY
            trx.invoice_currency_code     ,  --TO_CURRENCY
            trx.customer_trx_id           ,  --REF_CUSTOMER_TRX_ID
            ctl.customer_trx_line_id      ,  --REF_CUSTOMER_TRX_LINE_ID
         -- Orig
            DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                 'CB'  ,ctl.amount_due_original,0),          --DUE_ORIG_AMT
            DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                 'CB'  ,ctl.acctd_amount_due_original,0),    --DUE_ORIG_ACCTD_AMT
--{HYUCHRG
            DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0),       --CHRG_ORIG_AMT
            DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0), --CHRG_ORIG_ACCTD_AMT
--}
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0),       --FRT_ORIG_AMT
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0), --FRT_ORIG_ACCTD_AMT
            DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0),           --TAX_ORIG_AMT
            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0),     --TAX_ORIG_ACCTD_AMT
         -- Remaining
            DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                 'CB'  ,ctl.amount_due_remaining,0) ,        --DUE_REM_AMT
            /*DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_remaining,
                                 'CB'  ,ctl.acctd_amount_due_remaining,0),   --DUE_REM_ACCTD_AMT*/
            DECODE(ctl.line_type,'LINE',
	                         DECODE(ctl.amount_due_remaining,0,
				        ctl.acctd_amount_due_remaining,
					DECODE(ctl.acctd_amount_due_remaining,0,
					        arpcurr.CurrRound( ctl.amount_due_remaining *
						                   nvl(trx.exchange_rate,1)
								   ,trx.invoice_currency_code),
					       ctl.acctd_amount_due_remaining)),
                                 'CB'  ,ctl.acctd_amount_due_remaining,0),   --DUE_REM_ACCTD_AMT
--{HYUCHRG
--            DECODE(ctl.line_type,'LINE',ctl.chrg_amount_remaining,
--                                 'CB'  ,ctl.chrg_amount_remaining,0),
--            DECODE(ctl.line_type,'LINE',ctl.chrg_acctd_amount_remaining,
--                                 'CB'  ,ctl.chrg_acctd_amount_remaining,0),
            DECODE(ctl.line_type,'CHARGES',ctl.amount_due_remaining,0) ,      --CHRG_REM_AMT
            DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_remaining,0), --CHRG_REM_ACCTD_AMT
--}
            --
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_remaining,0) ,     --FRT_REM_AMT
                                                            /*Frt Rem on freight is the
                                                              rem amount of the freight calculated
                                                              from orig frt - cash application
                                                              frt adjustment variations are excluded
                                                              they are kept in frt_adj_rem_amt on rev line */
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_remaining,0), --FRT_REM_ACCTD_AMT
            DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0) ,          --TAX_REM_AMT
            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0),    --TAX_REM_ACCTD_AMT
            ctl.frt_adj_remaining          ,                                 --FRT_ADJ_REM_AMT
            ctl.frt_adj_acctd_remaining    ,                                 --FRT_ADJ_REM_ACCTD_AMT
            --
            ctl.line_type                 ,                                  --LINE_TYPE
           DECODE(ctl.SOURCE_DATA_KEY1 ||
            ctl.SOURCE_DATA_KEY2 ||
            ctl.SOURCE_DATA_KEY3 ||
            ctl.SOURCE_DATA_KEY4 ||
            ctl.SOURCE_DATA_KEY5, NULL, '00',
                 ctl.SOURCE_DATA_KEY1 ||'-'||
                 ctl.SOURCE_DATA_KEY2 ||'-'||
                 ctl.SOURCE_DATA_KEY3 ||'-'||
                 ctl.SOURCE_DATA_KEY4 ||'-'||
                 ctl.SOURCE_DATA_KEY5),                                           --GROUP_ID
--            NVL(ctl.SOURCE_DATA_KEY1,'00'),                                  --GROUP_ID
  --{HYUBPAGP
            NVL(ctl.source_data_key1,'00'),
            NVL(ctl.source_data_key2,'00'),
            NVL(ctl.source_data_key3,'00'),
            NVL(ctl.source_data_key4,'00'),
            NVL(ctl.source_data_key5,'00'),
  --}
            --
            DECODE(ctl.line_type,'LINE',ctl.amount_due_original,
                                 'CB'  ,ctl.amount_due_original,0),          --SUM_LINE_ORIG_AMT
            DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_original,
                                 'CB'  ,ctl.acctd_amount_due_original,0),    --SUM_LINE_ORIG_ACCTD_AMT
--{HYUCHRG
            DECODE(ctl.line_type,'CHARGES',ctl.amount_due_original,0),       --SUM_LINE_CHRG_ORIG_AMT
            DECODE(ctl.line_type,'CHARGES',ctl.acctd_amount_due_original,0), --SUM_LINE_CHRG_ORIG_ACCTD_AMT
--}
            DECODE(ctl.line_type,'FREIGHT',ctl.amount_due_original,0),       --SUM_LINE_FRT_ORIG_AMT
            DECODE(ctl.line_type,'FREIGHT',ctl.acctd_amount_due_original,0), --SUM_LINE_FRT_ORIG_ACCTD_AMT

--HYUIssue
--            DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0),           --SUM_LINE_TAX_ORIG_AMT

            SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_ORIG_AMT
--            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_original,0),     --SUM_LINE_TAX_ORIG_ACCTD_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.ACCTD_amount_due_original,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_ORIG_ACCTD_AMT
--}
            --
            DECODE(ctl.line_type,'LINE',ctl.amount_due_remaining,
                                 'CB'  ,ctl.amount_due_remaining,0),         --SUM_LINE_REM_AMT
            DECODE(ctl.line_type,'LINE',
	                         DECODE(ctl.amount_due_remaining,0,
				        ctl.acctd_amount_due_remaining,
					DECODE(ctl.acctd_amount_due_remaining,0,
					        arpcurr.CurrRound( ctl.amount_due_remaining *
						                   nvl(trx.exchange_rate,1)
								   ,trx.invoice_currency_code),
					       ctl.acctd_amount_due_remaining)),
                                 'CB'  ,ctl.acctd_amount_due_remaining,0),   --SUM_LINE_REM_ACCTD_AMT
            /*DECODE(ctl.line_type,'LINE',ctl.acctd_amount_due_remaining,
                                 'CB'  ,ctl.acctd_amount_due_remaining,0),   --SUM_LINE_REM_ACCTD_AMT*/
--{HYUCHRG
--            ctl.chrg_amount_remaining,
--            ctl.chrg_acctd_amount_remaining,
            DECODE(ctl.line_type,'LINE'   ,NVL(ctl.chrg_amount_remaining,0),
                                 'CB'     ,NVL(ctl.chrg_amount_remaining,0),
                                 'CHARGES',NVL(ctl.amount_due_remaining,0),
                                 0),                                          --SUM_LINE_CHRG_REM_AMT
            DECODE(ctl.line_type,'LINE'   ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                 'CB'     ,NVL(ctl.chrg_acctd_amount_remaining,0),
                                 'CHARGES',NVL(ctl.acctd_amount_due_remaining,0),
                                 0),                                          --SUM_LINE_CHRG_REM_ACCTD_AMT
--}
            --
            DECODE(ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_remaining,0),
                                 'CB'     ,NVL(ctl.frt_adj_remaining,0),
                                 'FREIGHT',NVL(ctl.amount_due_remaining,0),
                                 0),                                          --SUM_LINE_FRT_REM_AMT
            DECODE(ctl.line_type,'LINE'   ,NVL(ctl.frt_adj_acctd_remaining,0),
                                 'CB'     ,NVL(ctl.frt_adj_acctd_remaining,0),
                                 'FREIGHT',NVL(ctl.acctd_amount_due_remaining,0),
                                 0),                                          --SUM_LINE_FRT_REM_ACCTD_AMT
--HYUIssue
--            DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0),           --SUM_LINE_TAX_REM_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_REM_AMT
--            DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0),     --SUM_LINE_TAX_REM_ACCTD_AMT
            SUM(DECODE(ctl.line_type,'TAX',ctl.acctd_amount_due_remaining,0))
                OVER (PARTITION BY trx.customer_trx_id,ctl.line_type ),      --SUM_LINE_TAX_REM_ACCTD_AMT
--}
            --
            'L',
            --
            p_ae_sys_rec.set_of_books_id,
            p_ae_sys_rec.sob_type,
            --{Taxable_amount
            DECODE(ctl.line_type, 'TAX' ,ctl.link_to_cust_trx_line_id,
                                  'LINE',ctl.customer_trx_line_id,
                                  'CB'  ,ctl.customer_trx_line_id,
                                  NULL),
            DECODE(ctl.line_type,'LINE','Y',
                                 'CB'  ,'Y',
                                 'TAX','Y','N')
--            g_se_gt_id
       FROM ra_customer_trx          trx,
            ( select *
	      from ra_customer_trx_lines_gt ctl2
	      where  ctl2.customer_trx_id  =  p_customer_trx_id
	      and ctl2.customer_trx_line_id = p_customer_trx_line_id
	      union all
	      select *
	      from ra_customer_trx_lines_gt ctl2
	      where ctl2.customer_trx_id  =  p_customer_trx_id
	      and ctl2.LINK_TO_CUST_TRX_LINE_ID = p_customer_trx_line_id
	      ) ctl
      WHERE trx.customer_trx_id         = p_customer_trx_id;


  l_rows := sql%rowcount;
  g_appln_count := g_appln_count + l_rows;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  rows inserted = ' || l_rows);
  localdebug('arp_det_dist_pkg.get_invoice_line_info_per_line()-');
  END IF;
END get_invoice_line_info_per_line;

PROCEDURE proration_app_dist_trx
    (p_gt_id            IN VARCHAR2,
     p_app_level        IN VARCHAR2,
     p_customer_trx_id  IN NUMBER,
     p_app_rec          IN ar_receivable_applications%ROWTYPE,
     p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type)
IS
   l_adj_rec     ar_adjustments%ROWTYPE;
BEGIN
    IF PG_DEBUG = 'Y' THEN
    localdebug('arp_det_dist_pkg.proration_app_dist_trx()+');
    localdebug('     p_gt_id                  :'||p_gt_id );
    localdebug('     application type         :'||p_app_rec.application_type );
    localdebug('     receivable_application_id:'||p_app_rec.receivable_application_id );
    localdebug('     set of books id          :'||p_ae_sys_rec.set_of_books_id );
    localdebug('     sob type                 :'||p_ae_sys_rec.sob_type );
    END IF;

    get_inv_dist
    (p_pay_adj              => 'APP',
     p_customer_trx_id      => p_customer_trx_id,
     p_gt_id                => p_gt_id,
     p_adj_rec              => l_adj_rec,
     p_app_rec              => p_app_rec,
     p_ae_sys_rec           => p_ae_sys_rec);


    update_dist(p_customer_trx_id => p_customer_trx_id,
             p_gt_id           => p_gt_id,
             p_ae_sys_rec      => p_ae_sys_rec);

    create_split_distribution
      (p_pay_adj               => 'APP',
       p_customer_trx_id       => p_customer_trx_id,
       p_gt_id                 => p_gt_id,
       p_app_level             => p_app_level,
       p_ae_sys_rec            => p_ae_sys_rec);

    IF PG_DEBUG = 'Y' THEN
    localdebug('arp_det_dist_pkg.proration_app_dist_trx()-');
    END IF;

END proration_app_dist_trx;


PROCEDURE proration_adj_dist_trx
    (p_gt_id            IN VARCHAR2,
     p_app_level        IN VARCHAR2,
     p_customer_trx_id  IN NUMBER,
     p_adj_rec          IN ar_adjustments%ROWTYPE,
     p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type)
IS
   l_app_rec     ar_receivable_applications%ROWTYPE;
BEGIN
    IF PG_DEBUG = 'Y' THEN
    localdebug('arp_det_dist_pkg.proration_adj_dist_trx()+');
    localdebug('     p_gt_id                  :'||p_gt_id );
    localdebug('     adj type                 :'||p_adj_rec.adjustment_type );
    localdebug('     adjustments_id           :'||p_adj_rec.adjustment_id );
    localdebug('     set of books id          :'||p_ae_sys_rec.set_of_books_id );
    localdebug('     sob type                 :'||p_ae_sys_rec.sob_type );
    END IF;

    get_inv_dist
    (p_pay_adj              => 'ADJ',
     p_customer_trx_id      => p_customer_trx_id,
     p_gt_id                => p_gt_id,
     p_adj_rec              => p_adj_rec,
     p_app_rec              => l_app_rec,
     p_ae_sys_rec           => p_ae_sys_rec);

    update_dist(p_customer_trx_id => p_customer_trx_id,
             p_gt_id           => p_gt_id,
             p_ae_sys_rec      => p_ae_sys_rec);

    IF PG_DEBUG = 'Y' THEN
    localdebug('adjustment_detemination');
    END IF;


    adjustment_detemination
            (p_customer_trx_id => p_customer_trx_id,
             p_gt_id           => p_gt_id,
             p_pay_adj         => 'ADJ',
             p_ae_sys_rec      => p_ae_sys_rec,
             p_adj_rec         => p_adj_rec);

    IF PG_DEBUG = 'Y' THEN
    localdebug('create_split_distribution');
    END IF;
    create_split_distribution
      (p_pay_adj               => 'ADJ',
       p_customer_trx_id       => p_customer_trx_id,
       p_gt_id                 => p_gt_id,
       p_app_level             => p_app_level,
       p_ae_sys_rec            => p_ae_sys_rec);

    IF PG_DEBUG = 'Y' THEN
    localdebug('arp_det_dist_pkg.proration_adj_dist_trx()-');
    END IF;

END proration_adj_dist_trx;

/*-------------------------------------------------------------------------+
 | Trx_level_cash_apply                                                    |
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
PROCEDURE Trx_level_cash_apply
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN VARCHAR2 DEFAULT NULL)
IS
  l_adj_rec        ar_adjustments%ROWTYPE;
  l_app_rec        ar_receivable_applications%ROWTYPE;
  l_gt_id          VARCHAR2(30);
  l_return_status  VARCHAR2(1)   := fnd_api.g_ret_sts_success;
  l_msg_data       VARCHAR2(2000);
  l_msg_count      NUMBER;
  E11i_trx_no_llca      EXCEPTION;
  excep_get_gt_sequence EXCEPTION;
  summrize_act_no_llca  EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_level_cash_apply()+');
  localdebug('   p_customer_trx_id       :'||p_customer_trx.customer_trx_id);
  END IF;
  g_cust_inv_rec    :=  p_customer_trx;

  IF p_gt_id IS NULL THEN
     --BUG#4414391
     get_gt_sequence (x_gt_id         => l_gt_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE excep_get_gt_sequence;
     END IF;
     --l_gt_id  := g_gt_id;
     --}
  ELSE
    l_gt_id  := p_gt_id;
  END IF;

  g_gt_id    := l_gt_id;

  set_mode_process(p_customer_trx  => g_cust_inv_rec,
                   p_from_llca     => 'Y');

  IF g_mode_process = 'R12_11ICASH' THEN

    -- Process OLTP application on old transactions
    -- with adjustments created in 11I
    RAISE E11i_trx_no_llca;

  ELSIF g_mode_process = 'R12_MERGE' THEN

    -- Process OLTP application on transaction with activities
    -- having summarized distributions
    RAISE summrize_act_no_llca;

  ELSE

   IF g_mode_process = 'R12_11IMFAR' THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;

     ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT
     ( p_app_rec         => p_app_rec,
       x_app_rec         => l_app_rec,
       p_app_level       => 'TRANSACTION',
       p_currency        => g_cust_inv_rec.invoice_currency_code,
       x_return_status   => l_return_status,
       x_msg_data        => l_msg_data,
       x_msg_count       => l_msg_count);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.G_EXC_ERROR;
     ELSE
       l_app_rec := p_app_rec;
     END IF;

   END IF;
 END IF;
 --}

  conv_acctd_amt(p_pay_adj         => 'APP',
                 p_adj_rec         => l_adj_rec,
                 p_app_rec         => p_app_rec,
                 p_ae_sys_rec      => p_ae_sys_rec);

  get_invoice_line_info(p_gt_id            => l_gt_id,
                        p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                        p_ae_sys_rec       => p_ae_sys_rec,
                        p_mode             => 'NORMAL');

  prepare_group_for_proration(p_gt_id           => l_gt_id,
                              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                              p_pay_adj         => 'APP',
                              p_adj_rec         => l_adj_rec,
                              p_app_rec         => p_app_rec,
                              p_ae_sys_rec      => p_ae_sys_rec);

  update_group_line(p_gt_id           => l_gt_id,
                 p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                 p_ae_sys_rec      => p_ae_sys_rec);

  prepare_trx_line_proration(p_gt_id           => l_gt_id,
                             p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                             p_pay_adj         => 'APP',
                             p_adj_rec         => l_adj_rec,
                             p_app_rec         => p_app_rec,
                             p_ae_sys_rec      => p_ae_sys_rec);

  update_line(p_gt_id           => l_gt_id,
           p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
           p_ae_sys_rec      => p_ae_sys_rec);


  update_ctl_rem_orig(p_gt_id           => l_gt_id,
                      p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                      p_pay_adj         => 'APP',
                      p_ae_sys_rec      => p_ae_sys_rec);

  proration_app_dist_trx(p_gt_id            => l_gt_id,
                         p_app_level        => 'TRANSACTION',
                         p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                         p_app_rec          => p_app_rec,
                         p_ae_sys_rec       => p_ae_sys_rec);

  --BUG#3611016 : Store the gt_id only for Primary set of books
--  IF p_ae_sys_rec.sob_type = 'P' THEN
--     store_gt_id(p_initial   => FALSE,
--                 p_app_level => 'TRANSACTION');
--  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_level_cash_apply()-');
  END IF;
EXCEPTION
 WHEN excep_get_gt_sequence THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('EXCEPTION_get_gt_sequence IN Trx_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN E11i_trx_no_llca THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('legacy transaction no trx level application allowed.');
  END IF;
  RAISE;
 WHEN fnd_api.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
  IF PG_DEBUG = 'Y' THEN
  localdebug('fnd_api.G_EXC_ERROR IN Trx_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('OTHERS IN Trx_level_cash_apply :'||SQLERRM);
  END IF;
  RAISE;
END Trx_level_cash_apply;

/*-------------------------------------------------------------------------+
 | Trx_gp_level_cash_apply                                                 |
 +-------------------------------------------------------------------------+
 | 1) get_invoice_line_info_per_grp                                        |
 | 2) prepare_group_for_proration                                          |
 | 3) update_group_line                                                    |
 | 4) prepare_trx_line_proration                                           |
 | 5) update_line                                                          |
 | 6) update_ctl_rem_orig                                                  |
 | 7) store_group_id                                                       |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id     transaction id                                   |
 |  p_group_id            source_data_key1                                 |
 |  p_app_rec             ar receivable application record                 |
 |  p_ae_sys_rec          ar system parameter                              |
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
   p_gt_id            IN VARCHAR2 DEFAULT NULL)
IS
  l_adj_rec         ar_adjustments%ROWTYPE;
  l_app_rec         ar_receivable_applications%ROWTYPE;
  l_gt_id           VARCHAR2(30);
  l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_data        VARCHAR2(2000);
  l_msg_count       NUMBER;
  E11i_gp_no_llca    EXCEPTION;
  excep_get_gt_sequence EXCEPTION;
  summrize_act_no_llca  EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_gp_level_cash_apply()+');
  localdebug('   p_customer_trx_id       :'||p_customer_trx.customer_trx_id);
  localdebug('   p_source_data_key1      :'||p_source_data_key1);
  localdebug('   p_source_data_key2      :'||p_source_data_key2);
  localdebug('   p_source_data_key3      :'||p_source_data_key3);
  localdebug('   p_source_data_key4      :'||p_source_data_key4);
  localdebug('   p_source_data_key5      :'||p_source_data_key5);
  END IF;

  g_cust_inv_rec    :=  p_customer_trx;

  IF p_gt_id IS NULL THEN
     --BUG#4414391
     get_gt_sequence (x_gt_id         => l_gt_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.G_EXC_ERROR;
     END IF;
     --l_gt_id  := g_gt_id;
     --}
  ELSE
    l_gt_id  := p_gt_id;
  END IF;

  g_gt_id    := l_gt_id;

  set_mode_process(p_customer_trx  => g_cust_inv_rec,
                   p_from_llca     => 'Y');

  IF g_mode_process = 'R12_11ICASH' THEN

    -- Process OLTP application on old transactions
    -- with adjustments created in 11I
    RAISE E11i_gp_no_llca;

  ELSIF g_mode_process = 'R12_MERGE' THEN

    -- Process OLTP application on transaction with activities
    -- having summarized distributions
    RAISE summrize_act_no_llca;

  ELSE

   IF g_mode_process = 'R12_11IMFAR' THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;

     ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT
     ( p_app_rec         => p_app_rec,
       x_app_rec         => l_app_rec,
       p_app_level       => 'GROUP',
       p_source_data_key1=> p_source_data_key1,
       p_source_data_key2=> p_source_data_key2,
       p_source_data_key3=> p_source_data_key3,
       p_source_data_key4=> p_source_data_key4,
       p_source_data_key5=> p_source_data_key5,
       p_ctl_id          => NULL,
       p_currency        => g_cust_inv_rec.invoice_currency_code,
       x_return_status   => l_return_status,
       x_msg_data        => l_msg_data,
       x_msg_count       => l_msg_count);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.G_EXC_ERROR;
     ELSE
       l_app_rec := p_app_rec;
     END IF;

   END IF;
  END IF;
 --}



  conv_acctd_amt(p_pay_adj         => 'APP',
                 p_adj_rec         => l_adj_rec,
                 p_app_rec         => l_app_rec,
                 p_ae_sys_rec      => p_ae_sys_rec);

  get_invoice_line_info_per_grp(p_gt_id           => l_gt_id,
                                p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
--                                p_group_id        => p_group_id,
                                --{HYUBPAGP
                                p_source_data_key1 =>  p_source_data_key1,
                                p_source_data_key2 =>  p_source_data_key2,
                                p_source_data_key3 =>  p_source_data_key3,
                                p_source_data_key4 =>  p_source_data_key4,
                                p_source_data_key5 =>  p_source_data_key5,
                                --}
                                p_ae_sys_rec      => p_ae_sys_rec);

  prepare_group_for_proration(p_gt_id           => l_gt_id,
                              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                              p_pay_adj         => 'APP',
                              p_adj_rec         => l_adj_rec,
                              p_app_rec         => l_app_rec,
                              p_ae_sys_rec      => p_ae_sys_rec);

  update_group_line(p_gt_id           => l_gt_id,
                 p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                 p_ae_sys_rec      => p_ae_sys_rec);

  prepare_trx_line_proration(p_gt_id           => l_gt_id,
                             p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                             p_pay_adj         => 'APP',
                             p_adj_rec         => l_adj_rec,
                             p_app_rec         => l_app_rec,
                             p_ae_sys_rec      => p_ae_sys_rec);

  update_line(p_gt_id           => l_gt_id,
              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
              p_ae_sys_rec      => p_ae_sys_rec);

  update_ctl_rem_orig(p_gt_id           => l_gt_id,
                      p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                      p_pay_adj         => 'APP',
                      p_ae_sys_rec      => p_ae_sys_rec,
--                      p_group_id        => p_group_id,
                      --{HYUBPAGP
                      p_source_data_key1 =>  p_source_data_key1,
                      p_source_data_key2 =>  p_source_data_key2,
                      p_source_data_key3 =>  p_source_data_key3,
                      p_source_data_key4 =>  p_source_data_key4,
                      p_source_data_key5 =>  p_source_data_key5);
                      --}

  proration_app_dist_trx(p_gt_id            => l_gt_id,
                         p_app_level        => 'GROUP',
                         p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                         p_app_rec          => l_app_rec,
                         p_ae_sys_rec       => p_ae_sys_rec);

  --BUG#3611016 : Store the gt_id only for Primary set of books
--  IF p_ae_sys_rec.sob_type = 'P' THEN
--    store_gt_id(p_initial   => FALSE,
--                p_app_level => 'GROUP');
--  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_gp_level_cash_apply()-');
  END IF;
EXCEPTION
 WHEN excep_get_gt_sequence THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('EXCEPTION_get_gt_sequence IN Trx_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN E11i_gp_no_llca THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('legacy transaction no group level application allowed.');
  END IF;
  RAISE;
 WHEN fnd_api.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
  IF PG_DEBUG = 'Y' THEN
  localdebug('fnd_api.G_EXC_ERROR IN Trx_gp_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('OTHERS IN Trx_gp_level_cash_apply :'||SQLERRM);
  END IF;
  RAISE;
END Trx_gp_level_cash_apply;


/*-------------------------------------------------------------------------+
 | Trx_line_level_cash_apply                                               |
 +-------------------------------------------------------------------------+
 | 1) get_invoice_line_info_per_line                                       |
 | 2) prepare_group_for_proration                                          |
 | 3) update_group_line                                                    |
 | 4) prepare_trx_line_proration                                           |
 | 5) update_line                                                          |
 | 6) update_ctl_rem_orig                                                  |
 | 7) store_group_id                                                       |
 +-------------------------------------------------------------------------+
 | parameter:                                                              |
 |  p_customer_trx_id      transaction id                                  |
 |  p_customer_trx_line_id customer_trx_line_id                            |
 |  p_app_rec              ar receivable application record                |
 |  p_ae_sys_rec           ar system parameter                             |
 +-------------------------------------------------------------------------*/
PROCEDURE Trx_line_level_cash_apply
  (p_customer_trx           IN ra_customer_trx%ROWTYPE,
   p_customer_trx_line_id   IN VARCHAR2,
   p_log_inv_line           IN VARCHAR2 DEFAULT 'N',
   p_app_rec                IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec             IN arp_acct_main.ae_sys_rec_type,
   p_gt_id                  IN VARCHAR2 DEFAULT NULL)
IS
  l_adj_rec         ar_adjustments%ROWTYPE;
  l_app_rec         ar_receivable_applications%ROWTYPE;
  l_gt_id           VARCHAR2(30);
  l_return_status   VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_data        VARCHAR2(2000);
  l_msg_count       NUMBER;
  E11i_line_no_llca  EXCEPTION;
  excep_get_gt_sequence EXCEPTION;
  summrize_act_no_llca  EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_line_level_cash_apply()+');
  localdebug('   p_customer_trx_id       :'||p_customer_trx.customer_trx_id);
  localdebug('   p_customer_trx_line_id  :'||p_customer_trx_line_id);
  END IF;

  g_cust_inv_rec    :=  p_customer_trx;

  IF p_gt_id IS NULL THEN
     --BUG#4414391
     get_gt_sequence (x_gt_id         => l_gt_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE excep_get_gt_sequence;
     END IF;
     --l_gt_id  := g_gt_id;
     --}
  ELSE
    l_gt_id  := p_gt_id;
  END IF;

  g_gt_id    := l_gt_id;

  set_mode_process(p_customer_trx  => g_cust_inv_rec,
                   p_from_llca     => 'Y');

  IF g_mode_process = 'R12_11ICASH' THEN

    -- Process OLTP application on old transactions
    -- with adjustments created in 11I
    RAISE E11i_line_no_llca;

  ELSIF g_mode_process = 'R12_MERGE' THEN

    -- Process OLTP application on transaction with activities
    -- having summarized distributions
    RAISE summrize_act_no_llca;

  ELSE

   IF g_mode_process = 'R12_11IMFAR' THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;

     ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT
     ( p_app_rec         => p_app_rec,
       x_app_rec         => l_app_rec,
       p_app_level       => 'LINE',
       p_ctl_id          => p_customer_trx_line_id ,
       p_currency        => g_cust_inv_rec.invoice_currency_code,
       x_return_status   => l_return_status,
       x_msg_data        => l_msg_data,
       x_msg_count       => l_msg_count);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.G_EXC_ERROR;
     ELSE
       l_app_rec := p_app_rec;
     END IF;

   ELSE
     l_app_rec := p_app_rec;

   END IF;
 END IF;
 --}


  conv_acctd_amt(p_pay_adj         => 'APP',
                    p_adj_rec         => l_adj_rec,
                    p_app_rec         => l_app_rec,
                    p_ae_sys_rec      => p_ae_sys_rec);

  get_invoice_line_info_per_line(p_gt_id                => l_gt_id,
                                 p_customer_trx_id      => g_cust_inv_rec.customer_trx_id,
                                 p_customer_trx_line_id => p_customer_trx_line_id,
                                 p_log_inv_line         => p_log_inv_line,
                                 p_ae_sys_rec           => p_ae_sys_rec);

  prepare_group_for_proration(p_gt_id           => l_gt_id,
                              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                              p_pay_adj         => 'APP',
                              p_adj_rec         => l_adj_rec,
                              p_app_rec         => l_app_rec,
                              p_ae_sys_rec      => p_ae_sys_rec);

  update_group_line(p_gt_id           => l_gt_id,
                    p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                    p_ae_sys_rec      => p_ae_sys_rec);

  prepare_trx_line_proration(p_gt_id           => l_gt_id,
                             p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                             p_pay_adj         => 'APP',
                             p_adj_rec         => l_adj_rec,
                             p_app_rec         => l_app_rec,
                             p_ae_sys_rec      => p_ae_sys_rec);

  update_line(p_gt_id           => l_gt_id,
              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
              p_ae_sys_rec      => p_ae_sys_rec);

  update_ctl_rem_orig(p_gt_id           => l_gt_id,
                      p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                      p_pay_adj         => 'APP',
                      p_ae_sys_rec      => p_ae_sys_rec,
                      p_log_inv_line    => p_log_inv_line,
                      p_customer_trx_line_id => p_customer_trx_line_id);

  proration_app_dist_trx(p_gt_id            => l_gt_id,
                         p_app_level        => 'LINE',
                         p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                         p_app_rec          => l_app_rec,
                         p_ae_sys_rec       => p_ae_sys_rec);

  --BUG#3611016 : Store the gt_id only for Primary set of books
--  IF p_ae_sys_rec.sob_type = 'P' THEN
--     store_gt_id(p_initial   => FALSE,
--                 p_app_level => 'LINE');
--  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_line_level_cash_apply()-');
  END IF;
EXCEPTION
 WHEN excep_get_gt_sequence THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('EXCEPTION_get_gt_sequence IN Trx_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN E11i_line_no_llca THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('legacy transaction no line level application allowed.');
  END IF;
  RAISE;
 WHEN fnd_api.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
  IF PG_DEBUG = 'Y' THEN
  localdebug('fnd_api.G_EXC_ERROR IN Trx_line_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('OTHERS IN Trx_line_level_cash_apply :'||SQLERRM);
  END IF;
  RAISE;
END Trx_line_level_cash_apply;


/*------------------------------------------------+
 | Procedure copy_trx_lines
 +------------------------------------------------
 | Purpose cache the transaction lines in memory
 | to enhance the performance of the process
 +------------------------------------------------
 | History
 |   Created     01-Nov-2004
 |   Modified    02-Feb-2005   BR Enhancement
 +------------------------------------------------*/
PROCEDURE copy_trx_lines
(p_customer_trx_id  IN NUMBER,
 p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
 p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE DEFAULT NULL)
IS
  CURSOR cu_line_loaded (p_customer_trx_id IN NUMBER,
			 p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE ) IS
  SELECT 'x'
    FROM ra_customer_trx_lines_gt
   WHERE customer_trx_id = p_customer_trx_id
   AND   customer_trx_line_id = NVL(p_customer_trx_line_id, customer_trx_line_id);
  l_exist  VARCHAR2(1);

  CURSOR c_frt_chrg IS
  SELECT MAX(line_type)
    FROM ra_customer_trx_lines_gt
   WHERE line_type        IN ('CHARGES','FREIGHT')
     AND customer_trx_id  = p_customer_trx_id
   GROUP BY line_type;

  l_frt_chrg     VARCHAR2(30);
  l_rows         NUMBER;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.copy_trx_lines()+');
  localdebug('     p_customer_trx_id :'||p_customer_trx_id);
  END IF;
  OPEN cu_line_loaded(p_customer_trx_id, p_customer_trx_line_id);
  FETCH cu_line_loaded INTO l_exist;

  IF cu_line_loaded%NOTFOUND THEN

   IF ( g_mode_process IN ('R12_NLB','R12_MERGE')
      OR (g_source_table  = 'ADJ' AND g_mode_process IN ('R12_11ICASH'))
      )
   THEN

     INSERT INTO ra_customer_trx_lines_gt
      (customer_trx_line_id,
       link_to_cust_trx_line_id,
       customer_trx_id     ,
       set_of_books_id     ,
       line_type           ,
       source_data_key1    ,
       source_data_key2    ,
       source_data_key3    ,
       source_data_key4    ,
       source_data_key5    ,
       amount_due_remaining,
       acctd_amount_due_remaining,
       amount_due_original       ,
       acctd_amount_due_original ,
       chrg_amount_remaining     ,
       chrg_acctd_amount_remaining,
       frt_adj_remaining      ,
       frt_adj_acctd_remaining,
       group_id               ,
       --{HYUBRe
       br_line_orig_amt ,
       br_tax_orig_amt  ,
       br_frt_orig_amt  ,
       br_chrg_orig_amt ,
       br_line_orig_acctd_amt,
       br_tax_orig_acctd_amt,
       br_frt_orig_acctd_amt,
       br_chrg_orig_acctd_amt,
       br_ref_customer_trx_id,
       br_adjustment_id,
       line_origin
       --}
       )
   SELECT
     tl.customer_trx_line_id,
     tl.link_to_cust_trx_line_id,
     tl.customer_trx_id     ,
     tl.set_of_books_id     ,
     tl.line_type           ,
     '00',
     '00',
     '00',
     '00',
     '00',
     orl.sum_amt,                    -- amount_due_remaining
     orl.sum_acctd_amt,              -- acctd_amount_due_remaining
     orl.sum_amt,                    -- amount_due_original
     orl.sum_acctd_amt,              -- acctd_amount_due_original
     fcrl.chrg_on_rev_line,          -- chrg_amount_remaining
     fcrl.acctd_chrg_on_rev_line,    -- chrg_acctd_amount_remaining
     fcrl.frt_on_rev_line,           -- frt_adj_remaining
     fcrl.acctd_frt_on_rev_line,     -- frt_Adj_acctd_remaining
     DECODE(tl.source_data_key1 ||
            tl.source_data_key2 ||
            tl.source_data_key3 ||
            tl.source_data_key4 ||
            tl.source_data_key5, NULL, '00',
                 tl.source_data_key1 ||'-'||
                 tl.source_data_key2 ||'-'||
                 tl.source_data_key3 ||'-'||
                 tl.source_data_key4 ||'-'||
                 tl.source_data_key5),
    --{HYU BRe
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    '',  --tl.br_ref_customer_trx_id,
    '',  --tl.br_adjustment_id,
    ''  --DECODE(tl.br_ref_customer_trx_id, NULL, 'CTL',   --Regular Trx Line
         --  DECODE(typ.type, 'BR','BR_BR_ORIG_ASSIG', --BR assigned to a BR
         --               'BR_TRX_ORIG_ASSIG')--Regular TRX assigned to BR
         --  )                                              --    LINE_ORIGIN
    --}
    FROM ra_customer_trx_lines   tl,
--         ra_customer_trx         br,
--         ra_cust_trx_types       typ,
        -- Amount for original and remaining for all type of lines on reve line
       (SELECT SUM(AMOUNT)           sum_amt,
               SUM(ACCTD_AMOUNT)     sum_acctd_amt,
               customer_trx_line_id
          FROM ra_cust_trx_line_gl_dist
         WHERE customer_trx_id  = p_customer_trx_id
         GROUP BY customer_trx_line_id)                                              orl,
        -- Amount for charges and freight on revenue line
        (SELECT  SUM((DECODE(a.activity_bucket,'ADJ_CHRG',amt,0)))         CHRG_ON_REV_LINE
                ,SUM((DECODE(a.activity_bucket,'ADJ_CHRG',acctd_amt,0)))   ACCTD_CHRG_ON_REV_LINE
                ,SUM((DECODE(a.activity_bucket,'ADJ_FRT' ,amt,0)))         FRT_ON_REV_LINE
                ,SUM((DECODE(a.activity_bucket,'ADJ_FRT' ,acctd_amt,0)))         ACCTD_FRT_ON_REV_LINE
                ,a.ref_customer_trx_line_id
           FROM
            (SELECT SUM( NVL(ard.amount_cr,0)       - NVL(ard.amount_dr,0)      ) amt,
                    SUM( NVL(ard.acctd_amount_cr,0) - NVL(ard.acctd_amount_dr,0)) acctd_amt,
                    ard.ref_customer_trx_line_id,
                    ard.activity_bucket
               FROM ar_adjustments        adj,
                    ar_distributions      ard,
                    ra_customer_trx_lines ctl
              WHERE ctl.customer_trx_id      = p_customer_trx_id
                AND ctl.line_type            = 'LINE'
                AND adj.customer_trx_id      = p_customer_trx_id
                AND adj.adjustment_id        = ard.source_id
                AND ard.source_table         = 'ADJ'
                AND ard.ref_customer_trx_line_id = ctl.customer_trx_line_id
                AND ard.activity_bucket              IN ('ADJ_CHRG','ADJ_FRT')
              GROUP BY ard.ref_customer_trx_line_id,
                       ard.activity_bucket) a
           GROUP BY a.ref_customer_trx_line_id)                                      fcrl
   WHERE tl.customer_trx_id        = p_customer_trx_id
     AND tl.customer_trx_line_id   = orl.customer_trx_line_id
     AND tl.customer_trx_line_id   = fcrl.ref_customer_trx_line_id(+)
     AND (tl.customer_trx_line_id   = NVL(p_customer_trx_line_id, tl.customer_trx_line_id)
          OR tl.link_to_cust_trx_line_id = NVL(p_customer_trx_line_id, tl.customer_trx_line_id));
--     AND tl.br_ref_customer_trx_id = br.customer_trx_id(+)
--	 AND br.cust_trx_type_id       = typ.cust_trx_type_id(+);

    l_rows := sql%rowcount;
    localdebug('  rows inserted = ' || l_rows);
  ELSE

  INSERT INTO ra_customer_trx_lines_gt
  (CUSTOMER_TRX_LINE_ID,
   LINK_TO_CUST_TRX_LINE_ID,
   CUSTOMER_TRX_ID     ,
   SET_OF_BOOKS_ID     ,
   LINE_TYPE           ,
   SOURCE_DATA_KEY1    ,
   SOURCE_DATA_KEY2    ,
   SOURCE_DATA_KEY3    ,
   SOURCE_DATA_KEY4    ,
   SOURCE_DATA_KEY5    ,
   AMOUNT_DUE_REMAINING,
   ACCTD_AMOUNT_DUE_REMAINING ,
   AMOUNT_DUE_ORIGINAL        ,
   ACCTD_AMOUNT_DUE_ORIGINAL  ,
   CHRG_AMOUNT_REMAINING      ,
   CHRG_ACCTD_AMOUNT_REMAINING,
   FRT_ADJ_REMAINING          ,
   FRT_ADJ_ACCTD_REMAINING    ,
   group_id                   ,
   --{HYUBRe
   BR_LINE_ORIG_AMT      ,
   BR_TAX_ORIG_AMT       ,
   BR_FRT_ORIG_AMT       ,
   BR_CHRG_ORIG_AMT      ,
   BR_LINE_ORIG_ACCTD_AMT,
   BR_TAX_ORIG_ACCTD_AMT ,
   BR_FRT_ORIG_ACCTD_AMT ,
   BR_CHRG_ORIG_ACCTD_AMT,
   BR_REF_CUSTOMER_TRX_ID,
   BR_ADJUSTMENT_ID,
   LINE_ORIGIN
   --}
    )
   SELECT
     tl.CUSTOMER_TRX_LINE_ID,
     tl.LINK_TO_CUST_TRX_LINE_ID,
     tl.CUSTOMER_TRX_ID     ,
     tl.SET_OF_BOOKS_ID     ,
     tl.LINE_TYPE           ,
     '00',
     '00',
     '00',
     '00',
     '00',
     tl.AMOUNT_DUE_REMAINING,
     tl.ACCTD_AMOUNT_DUE_REMAINING ,
     tl.AMOUNT_DUE_ORIGINAL        ,
     tl.ACCTD_AMOUNT_DUE_ORIGINAL  ,
     tl.CHRG_AMOUNT_REMAINING,
     tl.CHRG_ACCTD_AMOUNT_REMAINING,
     tl.FRT_ADJ_REMAINING,
     tl.FRT_ADJ_ACCTD_REMAINING,
     DECODE(tl.SOURCE_DATA_KEY1 ||
            tl.SOURCE_DATA_KEY2 ||
            tl.SOURCE_DATA_KEY3 ||
            tl.SOURCE_DATA_KEY4 ||
            tl.SOURCE_DATA_KEY5, NULL, '00',
                 tl.SOURCE_DATA_KEY1 ||'-'||
                 tl.SOURCE_DATA_KEY2 ||'-'||
                 tl.SOURCE_DATA_KEY3 ||'-'||
                 tl.SOURCE_DATA_KEY4 ||'-'||
                 tl.SOURCE_DATA_KEY5),
    --{HYU BRe
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    0 ,
    '',  --tl.BR_REF_CUSTOMER_TRX_ID,
    '',  --tl.BR_ADJUSTMENT_ID,
    ''   --DECODE(tl.BR_REF_CUSTOMER_TRX_ID, NULL, 'CTL',   --Regular Trx Line
         --  DECODE(typ.type, 'BR','BR_BR_ORIG_ASSIG', --BR assigned to a BR
		 --                        'BR_TRX_ORIG_ASSIG')--Regular TRX assigned to BR
		 --  )                                              --    LINE_ORIGIN
    --}
    FROM ra_customer_trx_lines   tl
--         ra_customer_trx         br,
--         ra_cust_trx_types       typ
   WHERE tl.customer_trx_id        = p_customer_trx_id
   AND   (tl.customer_trx_line_id   = NVL(p_customer_trx_line_id, tl.customer_trx_line_id)
          OR tl.link_to_cust_trx_line_id = NVL(p_customer_trx_line_id, tl.customer_trx_line_id));
--     AND tl.br_ref_customer_trx_id = br.customer_trx_id(+)
--	 AND br.cust_trx_type_id       = typ.cust_trx_type_id(+);

     l_rows := sql%rowcount;
     IF PG_DEBUG = 'Y' THEN
     localdebug('  rows inserted = ' || l_rows);
     END IF;

   END IF;


   --{SET the g_trx_line_frt or chrg flags
   OPEN c_frt_chrg;
   LOOP
     FETCH c_frt_chrg INTO l_frt_chrg;
     EXIT WHEN c_frt_chrg%NOTFOUND;
     IF l_frt_chrg = 'FREIGHT' THEN
       g_trx_line_frt  := 'Y';
     END IF;
     IF l_frt_chrg = 'CHARGES' THEN
       g_trx_line_chrg := 'Y';
     END IF;
   END LOOP;
   CLOSE c_frt_chrg;
   --}


  END IF;
  CLOSE cu_line_loaded;

  IF g_cm_trx_id is not null THEN
      localdebug('flow for regular cm');
      localdebug('   g_cm_trx_id                :'||g_cm_trx_id);
      localdebug('   g_cm_upg_mthd              :'||g_cm_upg_mthd);
   IF g_cm_upg_mthd IN ('R12_NLB','R12_MERGE') THEN
      UPDATE ra_customer_trx_lines_gt tl
      SET(cm_amt_due_orig,   cm_amt_due_rem,   cm_acctd_amt_due_orig,   cm_acctd_amt_due_rem) =
        (SELECT sum_amt,
           sum_amt,
           sum_acctd_amt,
           sum_acctd_amt
         FROM
          (SELECT SUM(amount) sum_amt,
             SUM(acctd_amount) sum_acctd_amt,
             customer_trx_line_id
           FROM ra_cust_trx_line_gl_dist
           WHERE customer_trx_id = g_cm_trx_id
           GROUP BY customer_trx_line_id)
        cm_gld,
           ra_customer_trx_lines cm_tl
         WHERE cm_tl.customer_trx_id = g_cm_trx_id
         AND cm_gld.customer_trx_line_id = cm_tl.customer_trx_line_id
         AND cm_tl.previous_customer_trx_line_id = tl.customer_trx_line_id)
      WHERE customer_trx_id = p_customer_trx_id;
     l_rows := sql%rowcount;
     IF PG_DEBUG = 'Y' THEN
     localdebug('  rows updated = ' || l_rows);
     END IF;
   ELSE
      UPDATE ra_customer_trx_lines_gt tl
      SET(cm_amt_due_orig,   cm_amt_due_rem,   cm_acctd_amt_due_orig,   cm_acctd_amt_due_rem) =
        (SELECT amount_due_original,
           amount_due_remaining,
           acctd_amount_due_original,
           acctd_amount_due_remaining
         FROM
           ra_customer_trx_lines cm_tl
         WHERE cm_tl.customer_trx_id = g_cm_trx_id
         AND cm_tl.previous_customer_trx_line_id = tl.customer_trx_line_id)
      WHERE customer_trx_id = p_customer_trx_id;
     l_rows := sql%rowcount;
     IF PG_DEBUG = 'Y' THEN
     localdebug('  rows updated = ' || l_rows);
     END IF;
   END IF;
  END IF;

  IF (PG_DEBUG = 'Y') THEN
	display_cust_trx_gt(p_customer_trx_id => p_customer_trx_id);
  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.copy_trx_lines()-');
  END IF;
EXCEPTION
 WHEN OTHERS THEN
   IF PG_DEBUG = 'Y' THEN
   localdebug('EXCEPTION OTHERS copy_trx_lines:'||SQLERRM);
   END IF;
END copy_trx_lines;



PROCEDURE final_update_inv_ctl_rem_orig
  (p_customer_trx     IN ra_customer_trx%ROWTYPE)
IS
  CURSOR c(p_customer_trx_id  IN NUMBER) IS
  SELECT /*+INDEX (ctl ra_customer_trx_lines_gt_n1)*/
         b.AMOUNT_DUE_REMAINING      ,
         b.ACCTD_AMOUNT_DUE_REMAINING,
         b.AMOUNT_DUE_ORIGINAL       ,
         b.ACCTD_AMOUNT_DUE_ORIGINAL ,
         b.CHRG_AMOUNT_REMAINING     ,
         b.CHRG_ACCTD_AMOUNT_REMAINING,
         b.FRT_ADJ_REMAINING         ,
         b.FRT_ADJ_ACCTD_REMAINING   ,
         b.frt_ed_amount,
         b.frt_ed_acctd_amount,
         b.frt_uned_amount,
         b.frt_uned_acctd_amount,
         b.customer_trx_line_id
    FROM ra_customer_trx_lines_gt b
   WHERE b.customer_trx_id = p_customer_trx_id;

  l_amt_rem_tab                 DBMS_SQL.NUMBER_TABLE;
  l_acctd_amt_rem_tab           DBMS_SQL.NUMBER_TABLE;
  l_amt_orig_tab                DBMS_SQL.NUMBER_TABLE;
  l_acctd_amt_orig_tab          DBMS_SQL.NUMBER_TABLE;
  l_chrg_amt_rem_tab            DBMS_SQL.NUMBER_TABLE;
  l_chrg_acctd_amt_rem_tab      DBMS_SQL.NUMBER_TABLE;
  l_frt_adj_amt_rem_tab         DBMS_SQL.NUMBER_TABLE;
  l_frt_adj_acctd_amt_rem_tab   DBMS_SQL.NUMBER_TABLE;
  l_frt_ed_amt_tab         DBMS_SQL.NUMBER_TABLE;
  l_frt_ed_acctd_amt_tab   DBMS_SQL.NUMBER_TABLE;
  l_frt_uned_amt_tab         DBMS_SQL.NUMBER_TABLE;
  l_frt_uned_acctd_amt_tab   DBMS_SQL.NUMBER_TABLE;
  l_ctl_id_tab                  DBMS_SQL.NUMBER_TABLE;
  l_last_fetch                  BOOLEAN := FALSE;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.final_update_inv_ctl_rem_orig()+');
  END IF;

  OPEN c(p_customer_trx.customer_trx_id);
  LOOP
  FETCH c BULK COLLECT INTO l_amt_rem_tab,
                            l_acctd_amt_rem_tab,
                            l_amt_orig_tab,
                            l_acctd_amt_orig_tab,
                            l_chrg_amt_rem_tab,
                            l_chrg_acctd_amt_rem_tab,
                            l_frt_adj_amt_rem_tab,
                            l_frt_adj_acctd_amt_rem_tab,
                            l_frt_ed_amt_tab,
                            l_frt_ed_acctd_amt_tab,
                            l_frt_uned_amt_tab,
                            l_frt_uned_acctd_amt_tab,
                            l_ctl_id_tab
                    LIMIT g_bulk_fetch_rows;

     IF c%NOTFOUND THEN
          l_last_fetch := TRUE;
     END IF;

     IF (l_ctl_id_tab.COUNT = 0) AND (l_last_fetch) THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug('COUNT = 0 and LAST FETCH ');
       END IF;
       EXIT;
     END IF;

     FORALL i IN l_ctl_id_tab.FIRST .. l_ctl_id_tab.LAST
     UPDATE ra_customer_trx_lines
        SET AMOUNT_DUE_REMAINING        = l_amt_rem_tab(i),
            ACCTD_AMOUNT_DUE_REMAINING  = l_acctd_amt_rem_tab(i),
            AMOUNT_DUE_ORIGINAL         = l_amt_orig_tab(i),
            ACCTD_AMOUNT_DUE_ORIGINAL   = l_acctd_amt_orig_tab(i),
            CHRG_AMOUNT_REMAINING       = l_chrg_amt_rem_tab(i),
            CHRG_ACCTD_AMOUNT_REMAINING = l_chrg_acctd_amt_rem_tab(i),
            FRT_ADJ_REMAINING           = l_frt_adj_amt_rem_tab(i),
            FRT_ADJ_ACCTD_REMAINING     = l_frt_adj_acctd_amt_rem_tab(i),
            frt_ed_amount               = l_frt_ed_amt_tab(i),
            frt_ed_acctd_amount         = l_frt_ed_acctd_amt_tab(i),
            frt_uned_amount             = l_frt_uned_amt_tab(i),
            frt_uned_acctd_amount       = l_frt_uned_acctd_amt_tab(i)
      WHERE customer_trx_line_id        = l_ctl_id_tab(i)
        AND customer_trx_id             = p_customer_trx.customer_trx_id;
   END LOOP;
   CLOSE c;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.final_update_inv_ctl_rem_orig()-');
  END IF;
END final_update_inv_ctl_rem_orig;


PROCEDURE create_final_split
(p_customer_trx     IN ra_customer_trx%ROWTYPE,
 p_app_rec          IN ar_receivable_applications%ROWTYPE,
 p_adj_rec          IN ar_adjustments%ROWTYPE,
 p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type)
IS
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.create_final_split()+');
-- From distributions
  localdebug(' p_app_rec.ACCTD_AMOUNT_APPLIED_FROM    :'||p_app_rec.ACCTD_AMOUNT_APPLIED_FROM);
  localdebug(' p_app_rec.AMOUNT_APPLIED_FROM          :'||p_app_rec.AMOUNT_APPLIED_FROM    );
  END IF;

  update_from_gt
  (p_from_amt            => p_app_rec.AMOUNT_APPLIED_FROM,
   p_from_acctd_amt      => p_app_rec.ACCTD_AMOUNT_APPLIED_FROM,
   p_ae_sys_rec          => p_ae_sys_rec,
   p_app_rec             => p_app_rec);

  IF     p_adj_rec.adjustment_id IS NOT NULL THEN

    Reconciliation
    (p_app_rec             => p_app_rec,
     p_adj_rec             => p_adj_rec,
     p_activity_type       => 'ADJ');

    stamping_adj(p_adj_id  => p_adj_rec.adjustment_id);
  ELSIF  p_app_rec.receivable_application_id IS NOT NULL THEN

    Reconciliation
    (p_app_rec             => p_app_rec,
     p_adj_rec             => p_adj_rec,
     p_activity_type       => 'RA');

    stamping_ra(p_app_id  => p_app_rec.receivable_application_id);
  END IF;

--  get_diag_flag;

--  IF g_diag_flag IN ('Y') THEN
  IF PG_DEBUG = 'Y' THEN
    diag_data;
  END IF;
--  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.create_final_split()-');
  END IF;
END create_final_split;

/*-------------------------------------------------------------------------+
 | Trx_level_direct_adjust                                                 |
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
 |  p_customer_trx_id     transaction id
 |  p_adj_rec             ar adjustment record
 |  p_ae_sys_rec          ar system parameter
 +-------------------------------------------------------------------------*/
PROCEDURE Trx_level_direct_adjust
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_adj_rec          IN ar_adjustments%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN NUMBER DEFAULT NULL)
IS
  l_app_rec        ar_receivable_applications%ROWTYPE;
  l_gt_id          NUMBER;
  l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count      NUMBER := 0;
  l_msg_data       VARCHAR2(2000);
  excep_get_gt_sequence EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_level_direct_adjust()+');
  localdebug('   p_customer_trx_id       :'||p_customer_trx.customer_trx_id);
  END IF;

  IF p_gt_id IS NULL THEN
     --BUG#4414391
     get_gt_sequence (x_gt_id         => l_gt_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE excep_get_gt_sequence;
     END IF;
     --l_gt_id  := g_gt_id;
     --}
  ELSE
    l_gt_id  := p_gt_id;
  END IF;

  g_gt_id    := l_gt_id;

  --{BUG#4415037
  set_interface_flag(p_source_table => 'ADJ');
  --}

  g_cust_inv_rec   := p_customer_trx;

  set_mode_process(p_customer_trx  => g_cust_inv_rec,
                   p_from_llca     => 'N');

  copy_trx_lines(p_customer_trx_id  => p_customer_trx.customer_trx_id,
                 p_ae_sys_rec       => p_ae_sys_rec);

  conv_acctd_amt(p_pay_adj         => 'ADJ',
                 p_adj_rec         => p_adj_rec,
                 p_app_rec         => l_app_rec,
                 p_ae_sys_rec      => p_ae_sys_rec);

  get_invoice_line_info(p_gt_id            => l_gt_id,
                        p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                        p_ae_sys_rec       => p_ae_sys_rec,
                        p_mode             => 'NORMAL');

  prepare_group_for_proration(p_gt_id           => l_gt_id,
                              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                              p_pay_adj         => 'ADJ',
                              p_adj_rec         => p_adj_rec,
                              p_app_rec         => l_app_rec,
                              p_ae_sys_rec      => p_ae_sys_rec);

  update_group_line(p_gt_id           => l_gt_id,
                    p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                    p_ae_sys_rec      => p_ae_sys_rec);

  prepare_trx_line_proration(p_gt_id           => l_gt_id,
                             p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                             p_pay_adj         => 'ADJ',
                             p_adj_rec         => p_adj_rec,
                             p_app_rec         => l_app_rec,
                             p_ae_sys_rec      => p_ae_sys_rec);

  update_line(p_gt_id           => l_gt_id,
           p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
           p_ae_sys_rec      => p_ae_sys_rec);


  update_ctl_rem_orig(p_gt_id           => l_gt_id,
                      p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                      p_pay_adj         => 'ADJ',
                      p_ae_sys_rec      => p_ae_sys_rec);

  proration_adj_dist_trx(p_gt_id            => l_gt_id,
                         p_app_level        => 'TRANSACTION',
                         p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                         p_adj_rec          => p_adj_rec,
                         p_ae_sys_rec       => p_ae_sys_rec);

--HYU
--BUG#3611016 : Store the gt_id only for Primary set of books
--  IF p_ae_sys_rec.sob_type = 'P' THEN
--     store_gt_id(p_initial   => FALSE,
--                 p_app_level => 'TRANSACTION');
--  END IF;

  --
  -- For invoice leagcy from 11i Cash basis, we do not maintain the balancing
  --
--{HYUNLB
--  IF g_mode_process <> 'R12_11ICASH' THEN
--     final_update_inv_ctl_rem_orig(p_customer_trx => p_customer_trx);
--  END IF;
--}
  IF g_mode_process IN ('R12','R12_11IMFAR') THEN
     final_update_inv_ctl_rem_orig(p_customer_trx => p_customer_trx);
  END IF;


  create_final_split(p_customer_trx => p_customer_trx,
                     p_app_rec      => l_app_rec,
                     p_adj_rec      => p_adj_rec,
                     p_ae_sys_rec   => p_ae_sys_rec);

  IF g_mode_process IN ('R12_MERGE') THEN
     UPDATE ar_adjustments
     SET upgrade_method = 'R12_MERGE'
     WHERE adjustment_id = p_adj_rec.adjustment_id;
  ELSE
    UPDATE ar_adjustments
    SET upgrade_method = 'R12'
    WHERE adjustment_id = p_adj_rec.adjustment_id;
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_level_direct_adjust()-');
  END IF;
EXCEPTION
 WHEN excep_get_gt_sequence THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('EXCEPTION_get_gt_sequence IN Trx_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('   EXCEPTION OTHER Trx_level_direct_adjust :'||SQLERRM);
    END IF;
--    RAISE;
END Trx_level_direct_adjust;

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
   p_inv_cm           IN VARCHAR2 DEFAULT 'I')
IS
  l_adj_rec         ar_adjustments%ROWTYPE;
  l_app_rec         ar_receivable_applications%ROWTYPE;
  l_gt_id           NUMBER;
  l_out_res         VARCHAR2(1);
  l_return_status  VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_msg_count      NUMBER := 0;
  l_msg_data       VARCHAR2(2000);
  l_upg_cm        VARCHAR2(1);
  l_rows           NUMBER;
  excep_get_gt_sequence EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_level_direct_cash_apply()+');
  localdebug('   p_customer_trx_id       :'||p_customer_trx.customer_trx_id);
  localdebug('   p_inv_cm                :'||p_inv_cm);
  END IF;

  IF p_gt_id IS NULL THEN
     --BUG#4414391
     get_gt_sequence (x_gt_id         => l_gt_id,
                      x_return_status => l_return_status,
                      x_msg_count     => l_msg_count,
                      x_msg_data      => l_msg_data);
     IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE excep_get_gt_sequence;
     END IF;
     --l_gt_id  := g_gt_id;
     --}
  ELSE
    l_gt_id  := p_gt_id;
  END IF;

  g_gt_id    := l_gt_id;

  --{BUG#4415037
  set_interface_flag(p_source_table => 'RA');
  --}

  g_cust_inv_rec    :=  p_customer_trx;

  set_mode_process(p_customer_trx  => g_cust_inv_rec,
                   p_from_llca     => 'N');

  IF g_mode_process IN ('R12_11ICASH','R12_MERGE') THEN

    -- Process OLTP application on old transactions
    -- with adjustments created in 11I
    online_lazy_apply
    (p_customer_trx     => g_cust_inv_rec,
     p_app_rec          => p_app_rec,
     p_ae_sys_rec       => p_ae_sys_rec,
     p_gt_id            => l_gt_id,
	 p_inv_cm           => p_inv_cm);

  ELSE

    g_cm_trx_id := null;
    IF p_app_rec.application_type = 'CM' AND
       p_inv_cm = 'I' THEN
     BEGIN
      select customer_trx_id, nvl(upgrade_method,'R12_NLB')
       into g_cm_trx_id, g_cm_upg_mthd
        from ra_customer_trx
        where customer_trx_id = p_app_rec.customer_trx_id
        and previous_customer_trx_id = p_app_rec.applied_customer_trx_id
        and nvl(upgrade_method, 'R12_NLB') in ('R12','R12_NLB','R12_11IMFAR');

      localdebug('   g_cm_trx_id                :'||g_cm_trx_id);
      localdebug('   g_cm_upg_mthd              :'||g_cm_upg_mthd);

     exec_revrec_if_required
          ( p_customer_trx_id  => g_cm_trx_id,
            p_app_rec          => l_app_rec,
            p_adj_rec          => l_adj_rec);

     EXCEPTION
      when others then
        g_cm_trx_id := null;
     END;
    END IF;

   -- Normal process for applications on transactions
   -- without adjustments in 11I
   copy_trx_lines(p_customer_trx_id  => p_customer_trx.customer_trx_id,
                  p_ae_sys_rec       => p_ae_sys_rec);


    -- If the application is from MFAR legacy the bucket of app charge can be wrong versus the
    -- remaining amount buckets of the transaction as the changes are prorated over all distributions
    IF g_mode_process = 'R12_11IMFAR' AND p_inv_cm = 'I' THEN
       l_return_status := FND_API.G_RET_STS_SUCCESS;

      ar_upgrade_cash_accrual.COMPARE_RA_REM_AMT
       ( p_app_rec         => p_app_rec,
         x_app_rec         => l_app_rec,
         p_app_level       => 'TRANSACTION',
         p_currency        => g_cust_inv_rec.invoice_currency_code,
         x_return_status   => l_return_status,
         x_msg_data        => l_msg_data,
         x_msg_count       => l_msg_count);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.G_EXC_ERROR;
      END IF;

IF PG_DEBUG = 'Y' THEN
localdebug('l_app_rec.RECEIVABLES_CHARGES_APPLIED :' ||l_app_rec.RECEIVABLES_CHARGES_APPLIED);
END IF;

    ELSIF g_mode_process IN ('R12','R12_11IMFAR','R12_NLB','R12_11ICASH','R12_MERGE') AND p_inv_cm = 'C' THEN

          IF  g_mode_process = 'R12_11ICASH' THEN
          l_upg_cm := 'Y' ;
          ELSE
          l_upg_cm := 'N' ;
          END IF;

          convert_ra_inv_to_cm
          ( p_inv_ra_rec     => p_app_rec,
            p_cm_trx_id      => g_cust_inv_rec.customer_trx_id,
            x_cm_ra_rec      => l_app_rec,
            p_mode           => 'OLTP',
	          p_gt_id          => l_gt_id,
            p_upg_cm        => l_upg_cm);

    ELSE
      l_app_rec := p_app_rec;
    END IF;
    --}

IF PG_DEBUG = 'Y' THEN
localdebug('l_app_rec.RECEIVABLES_CHARGES_APPLIED :' ||l_app_rec.RECEIVABLES_CHARGES_APPLIED);
END IF;

   conv_acctd_amt(p_pay_adj         => 'APP',
                   p_adj_rec         => l_adj_rec,
                   p_app_rec         => l_app_rec,
                   p_ae_sys_rec      => p_ae_sys_rec);


  IF g_cm_trx_id IS NOT NULL THEN
   get_invoice_line_info_cm(p_gt_id            => l_gt_id,
                         p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                         p_ae_sys_rec       => p_ae_sys_rec,
                         p_mode             => 'NORMAL');
   g_cm_trx_id := null;
  ELSE
   get_invoice_line_info(p_gt_id            => l_gt_id,
                         p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                         p_ae_sys_rec       => p_ae_sys_rec,
                         p_mode             => 'NORMAL');
  END IF;

   prepare_group_for_proration(p_gt_id           => l_gt_id,
                               p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                               p_pay_adj         => 'APP',
                               p_adj_rec         => l_adj_rec,
                               p_app_rec         => l_app_rec,
                               p_ae_sys_rec      => p_ae_sys_rec);

   update_group_line(p_gt_id           => l_gt_id,
                     p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                     p_ae_sys_rec      => p_ae_sys_rec);

   prepare_trx_line_proration(p_gt_id           => l_gt_id,
                              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                              p_pay_adj         => 'APP',
                              p_adj_rec         => l_adj_rec,
                              p_app_rec         => l_app_rec,
                              p_ae_sys_rec      => p_ae_sys_rec);

   update_line(p_gt_id           => l_gt_id,
               p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
               p_ae_sys_rec      => p_ae_sys_rec);

   update_ctl_rem_orig(p_gt_id           => l_gt_id,
                       p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                       p_pay_adj         => 'APP',
                       p_ae_sys_rec      => p_ae_sys_rec);

   proration_app_dist_trx(p_gt_id            => l_gt_id,
                          p_app_level        => 'TRANSACTION',
                          p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                          p_app_rec          => l_app_rec,
                          p_ae_sys_rec       => p_ae_sys_rec);

   --BUG#3611016 : Store the gt_id only for Primary set of books
--   IF p_ae_sys_rec.sob_type = 'P' THEN
--     store_gt_id(p_initial   => FALSE,
--                 p_app_level => 'TRANSACTION');
--   END IF;

   --HYU
   --  delete from ra_ar_st;
   --  insert into ra_ar_st select * from ra_ar_gt;

   --{HYUNLB
   -- final_update_inv_ctl_rem_orig(p_customer_trx => p_customer_trx);
   --}


  IF g_mode_process IN ('R12','R12_11IMFAR') THEN
     final_update_inv_ctl_rem_orig(p_customer_trx => p_customer_trx);
  END IF;

 END IF;
 -- End of difference between applications}

 create_final_split(p_customer_trx => p_customer_trx,
                    p_app_rec      => l_app_rec,
                    p_adj_rec      => l_adj_rec,
                    p_ae_sys_rec   => p_ae_sys_rec);


  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.trx_level_direct_cash_apply()-');
  END IF;
EXCEPTION
 WHEN excep_get_gt_sequence THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('EXCEPTION_get_gt_sequence IN Trx_level_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN fnd_api.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => l_msg_count,
                               p_data  => l_msg_data);
  IF PG_DEBUG = 'Y' THEN
  localdebug('fnd_api.G_EXC_ERROR IN Trx_level_direct_cash_apply error count:'||l_msg_count);
  localdebug('last error:'||l_msg_data);
  END IF;
  RAISE;
 WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('OTHERS IN Trx_level_direct_cash_apply :'||SQLERRM);
  END IF;
  RAISE;
END Trx_level_direct_cash_apply;


PROCEDURE  display_ra_ar_row(p_ra_ar_rec   IN  ra_ar_gt%ROWTYPE)
IS
BEGIN
   IF PG_DEBUG = 'Y' THEN
   localdebug(  'display_ra_ar_row +');
   localdebug(  '  source_data_key5               :'|| p_ra_ar_rec.SOURCE_DATA_KEY5);
   localdebug(  '  dist_ed_chrg_amt               :'|| p_ra_ar_rec.DIST_ED_CHRG_AMT);
   localdebug(  '  dist_ed_chrg_acctd_amt         :'|| p_ra_ar_rec.DIST_ED_CHRG_ACCTD_AMT);
   localdebug(  '  dist_uned_amt                  :'|| p_ra_ar_rec.DIST_UNED_AMT);
   localdebug(  '  dist_uned_acctd_amt            :'|| p_ra_ar_rec.DIST_UNED_ACCTD_AMT);
   localdebug(  '  dist_uned_frt_amt              :'|| p_ra_ar_rec.DIST_UNED_FRT_AMT);
   localdebug(  '  dist_uned_frt_acctd_amt        :'|| p_ra_ar_rec.DIST_UNED_FRT_ACCTD_AMT);
   localdebug(  '  dist_uned_tax_amt              :'|| p_ra_ar_rec.DIST_UNED_TAX_AMT);
   localdebug(  '  dist_uned_tax_acctd_amt        :'|| p_ra_ar_rec.DIST_UNED_TAX_ACCTD_AMT);
   localdebug(  '  dist_uned_chrg_amt             :'|| p_ra_ar_rec.DIST_UNED_CHRG_AMT);
   localdebug(  '  dist_uned_chrg_acctd_amt       :'|| p_ra_ar_rec.DIST_UNED_CHRG_ACCTD_AMT);
/*   localdebug(  '  base_dist_amt                  :'|| p_ra_ar_rec.BASE_DIST_AMT);
   localdebug(  '  base_dist_acctd_amt            :'|| p_ra_ar_rec.BASE_DIST_ACCTD_AMT);
   localdebug(  '  base_dist_frt_amt              :'|| p_ra_ar_rec.BASE_DIST_FRT_AMT);
   localdebug(  '  base_dist_frt_acctd_amt        :'|| p_ra_ar_rec.BASE_DIST_FRT_ACCTD_AMT);
   localdebug(  '  base_dist_tax_amt              :'|| p_ra_ar_rec.BASE_DIST_TAX_AMT);
   localdebug(  '  base_dist_tax_acctd_amt        :'|| p_ra_ar_rec.BASE_DIST_TAX_ACCTD_AMT);
   localdebug(  '  base_dist_chrg_amt             :'|| p_ra_ar_rec.BASE_DIST_CHRG_AMT);
   localdebug(  '  base_dist_chrg_acctd_amt       :'|| p_ra_ar_rec.BASE_DIST_CHRG_ACCTD_AMT);
   localdebug(  '  base_ed_dist_amt               :'|| p_ra_ar_rec.BASE_ED_DIST_AMT);
   localdebug(  '  base_ed_dist_acctd_amt         :'|| p_ra_ar_rec.BASE_ED_DIST_ACCTD_AMT);
   localdebug(  '  base_ed_dist_frt_amt           :'|| p_ra_ar_rec.BASE_ED_DIST_FRT_AMT);
   localdebug(  '  base_ed_dist_frt_acctd_amt     :'|| p_ra_ar_rec.BASE_ED_DIST_FRT_ACCTD_AMT);
   localdebug(  '  elmt_ed_frt_pro_acctd_amt      :'|| p_ra_ar_rec.ELMT_ED_FRT_PRO_ACCTD_AMT);
   localdebug(  '  elmt_ed_tax_pro_amt            :'|| p_ra_ar_rec.ELMT_ED_TAX_PRO_AMT);
   localdebug(  '  elmt_ed_tax_pro_acctd_amt      :'|| p_ra_ar_rec.ELMT_ED_TAX_PRO_ACCTD_AMT);
   localdebug(  '  base_ed_pro_amt                :'|| p_ra_ar_rec.BASE_ED_PRO_AMT);
   localdebug(  '  base_ed_pro_acctd_amt          :'|| p_ra_ar_rec.BASE_ED_PRO_ACCTD_AMT);
   localdebug(  '  base_ed_chrg_pro_amt           :'|| p_ra_ar_rec.BASE_ED_CHRG_PRO_AMT); */
   localdebug(  '  tax_rem_acctd_amt              :'|| p_ra_ar_rec.TAX_REM_ACCTD_AMT);
   localdebug(  '  line_type                      :'|| p_ra_ar_rec.LINE_TYPE);
   localdebug(  '  sum_line_orig_amt              :'|| p_ra_ar_rec.SUM_LINE_ORIG_AMT);
   localdebug(  '  sum_line_orig_acctd_amt        :'|| p_ra_ar_rec.SUM_LINE_ORIG_ACCTD_AMT);
   localdebug(  '  sum_line_frt_orig_amt          :'|| p_ra_ar_rec.SUM_LINE_FRT_ORIG_AMT);
   localdebug(  '  sum_line_frt_orig_acctd_amt    :'|| p_ra_ar_rec.SUM_LINE_FRT_ORIG_ACCTD_AMT);
   localdebug(  '  sum_line_tax_orig_amt          :'|| p_ra_ar_rec.SUM_LINE_TAX_ORIG_AMT);
/*   localdebug(  '  buc_uned_chrg_alloc_amt        :'|| p_ra_ar_rec.BUC_UNED_CHRG_ALLOC_AMT);
   localdebug(  '  buc_uned_chrg_alloc_acctd_amt  :'|| p_ra_ar_rec.BUC_UNED_CHRG_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_uned_frt_alloc_amt         :'|| p_ra_ar_rec.BUC_UNED_FRT_ALLOC_AMT);
   localdebug(  '  buc_uned_frt_alloc_acctd_amt   :'|| p_ra_ar_rec.BUC_UNED_FRT_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_uned_tax_alloc_amt         :'|| p_ra_ar_rec.BUC_UNED_TAX_ALLOC_AMT);
   localdebug(  '  buc_uned_tax_alloc_acctd_amt   :'|| p_ra_ar_rec.BUC_UNED_TAX_ALLOC_ACCTD_AMT);
   localdebug(  '  elmt_uned_pro_amt              :'|| p_ra_ar_rec.ELMT_UNED_PRO_AMT);
   localdebug(  '  elmt_uned_pro_acctd_amt        :'|| p_ra_ar_rec.ELMT_UNED_PRO_ACCTD_AMT);
   localdebug(  '  elmt_uned_chrg_pro_amt         :'|| p_ra_ar_rec.ELMT_UNED_CHRG_PRO_AMT);
   localdebug(  '  elmt_uned_chrg_pro_acctd_amt   :'|| p_ra_ar_rec.ELMT_UNED_CHRG_PRO_ACCTD_AMT);
   localdebug(  '  elmt_uned_frt_pro_amt          :'|| p_ra_ar_rec.ELMT_UNED_FRT_PRO_AMT);
   localdebug(  '  elmt_uned_frt_pro_acctd_amt    :'|| p_ra_ar_rec.ELMT_UNED_FRT_PRO_ACCTD_AMT);
   localdebug(  '  elmt_uned_tax_pro_amt          :'|| p_ra_ar_rec.ELMT_UNED_TAX_PRO_AMT);
   localdebug(  '  base_ed_dist_tax_amt           :'|| p_ra_ar_rec.BASE_ED_DIST_TAX_AMT);
   localdebug(  '  base_ed_dist_tax_acctd_amt     :'|| p_ra_ar_rec.BASE_ED_DIST_TAX_ACCTD_AMT);
   localdebug(  '  base_ed_dist_chrg_amt          :'|| p_ra_ar_rec.BASE_ED_DIST_CHRG_AMT);
   localdebug(  '  base_ed_dist_chrg_acctd_amt    :'|| p_ra_ar_rec.BASE_ED_DIST_CHRG_ACCTD_AMT);
   localdebug(  '  base_uned_dist_amt             :'|| p_ra_ar_rec.BASE_UNED_DIST_AMT);
   localdebug(  '  base_uned_dist_acctd_amt       :'|| p_ra_ar_rec.BASE_UNED_DIST_ACCTD_AMT);
   localdebug(  '  base_uned_dist_frt_amt         :'|| p_ra_ar_rec.BASE_UNED_DIST_FRT_AMT);
   localdebug(  '  base_uned_dist_frt_acctd_amt   :'|| p_ra_ar_rec.BASE_UNED_DIST_FRT_ACCTD_AMT);
   localdebug(  '  base_uned_dist_tax_amt         :'|| p_ra_ar_rec.BASE_UNED_DIST_TAX_AMT);
   localdebug(  '  base_uned_dist_tax_acctd_amt   :'|| p_ra_ar_rec.BASE_UNED_DIST_TAX_ACCTD_AMT);
   localdebug(  '  base_uned_dist_chrg_amt        :'|| p_ra_ar_rec.BASE_UNED_DIST_CHRG_AMT);
   localdebug(  '  base_uned_dist_chrg_acctd_amt  :'|| p_ra_ar_rec.BASE_UNED_DIST_CHRG_ACCTD_AMT);*/
   localdebug(  '  gp_level                       :'|| p_ra_ar_rec.GP_LEVEL);
   localdebug(  '  from_alloc_acctd_amt           :'|| p_ra_ar_rec.FROM_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_alloc_amt                   :'|| p_ra_ar_rec.TL_ALLOC_AMT);
   localdebug(  '  tl_alloc_acctd_amt             :'|| p_ra_ar_rec.TL_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_chrg_alloc_amt              :'|| p_ra_ar_rec.TL_CHRG_ALLOC_AMT);
   localdebug(  '  tl_chrg_alloc_acctd_amt        :'|| p_ra_ar_rec.TL_CHRG_ALLOC_ACCTD_AMT);
   localdebug(  '  tax_rem_amt                    :'|| p_ra_ar_rec.TAX_REM_AMT);
/*   localdebug(  '  buc_ed_alloc_acctd_amt         :'|| p_ra_ar_rec.BUC_ED_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_ed_chrg_alloc_amt          :'|| p_ra_ar_rec.BUC_ED_CHRG_ALLOC_AMT);
   localdebug(  '  base_ed_chrg_pro_acctd_amt     :'|| p_ra_ar_rec.BASE_ED_CHRG_PRO_ACCTD_AMT);*/
   localdebug(  '  group_id                       :'|| p_ra_ar_rec.GROUP_ID);
/*   localdebug(  '  elmt_uned_tax_pro_acctd_amt    :'|| p_ra_ar_rec.ELMT_UNED_TAX_PRO_ACCTD_AMT);
   localdebug(  '  base_uned_pro_amt              :'|| p_ra_ar_rec.BASE_UNED_PRO_AMT);
   localdebug(  '  base_uned_pro_acctd_amt        :'|| p_ra_ar_rec.BASE_UNED_PRO_ACCTD_AMT);
   localdebug(  '  base_uned_chrg_pro_amt         :'|| p_ra_ar_rec.BASE_UNED_CHRG_PRO_AMT);
   localdebug(  '  base_uned_chrg_pro_acctd_amt   :'|| p_ra_ar_rec.BASE_UNED_CHRG_PRO_ACCTD_AMT);
   localdebug(  '  base_uned_frt_pro_amt          :'|| p_ra_ar_rec.BASE_UNED_FRT_PRO_AMT);
   localdebug(  '  base_uned_frt_pro_acctd_amt    :'|| p_ra_ar_rec.BASE_UNED_FRT_PRO_ACCTD_AMT);
   localdebug(  '  base_uned_tax_pro_amt          :'|| p_ra_ar_rec.BASE_UNED_TAX_PRO_AMT);
   localdebug(  '  base_uned_tax_pro_acctd_amt    :'|| p_ra_ar_rec.BASE_UNED_TAX_PRO_ACCTD_AMT);*/
   localdebug(  '  dist_amt                       :'|| p_ra_ar_rec.DIST_AMT);
   localdebug(  '  dist_acctd_amt                 :'|| p_ra_ar_rec.DIST_ACCTD_AMT);
   localdebug(  '  dist_frt_amt                   :'|| p_ra_ar_rec.DIST_FRT_AMT);
   localdebug(  '  dist_frt_acctd_amt             :'|| p_ra_ar_rec.DIST_FRT_ACCTD_AMT);
   localdebug(  '  dist_tax_amt                   :'|| p_ra_ar_rec.DIST_TAX_AMT);
   localdebug(  '  dist_tax_acctd_amt             :'|| p_ra_ar_rec.DIST_TAX_ACCTD_AMT);
   localdebug(  '  dist_chrg_amt                  :'|| p_ra_ar_rec.DIST_CHRG_AMT);
   localdebug(  '  dist_chrg_acctd_amt            :'|| p_ra_ar_rec.DIST_CHRG_ACCTD_AMT);
   localdebug(  '  dist_ed_amt                    :'|| p_ra_ar_rec.DIST_ED_AMT);
   localdebug(  '  dist_ed_acctd_amt              :'|| p_ra_ar_rec.DIST_ED_ACCTD_AMT);
   localdebug(  '  dist_ed_frt_amt                :'|| p_ra_ar_rec.DIST_ED_FRT_AMT);
   localdebug(  '  dist_ed_frt_acctd_amt          :'|| p_ra_ar_rec.DIST_ED_FRT_ACCTD_AMT);
/*   localdebug(  '  elmt_pro_amt                   :'|| p_ra_ar_rec.ELMT_PRO_AMT);
   localdebug(  '  elmt_pro_acctd_amt             :'|| p_ra_ar_rec.ELMT_PRO_ACCTD_AMT);
   localdebug(  '  elmt_chrg_pro_amt              :'|| p_ra_ar_rec.ELMT_CHRG_PRO_AMT);
   localdebug(  '  elmt_chrg_pro_acctd_amt        :'|| p_ra_ar_rec.ELMT_CHRG_PRO_ACCTD_AMT);
   localdebug(  '  elmt_frt_pro_amt               :'|| p_ra_ar_rec.ELMT_FRT_PRO_AMT);
   localdebug(  '  elmt_frt_pro_acctd_amt         :'|| p_ra_ar_rec.ELMT_FRT_PRO_ACCTD_AMT);
   localdebug(  '  elmt_tax_pro_amt               :'|| p_ra_ar_rec.ELMT_TAX_PRO_AMT);
   localdebug(  '  elmt_tax_pro_acctd_amt         :'|| p_ra_ar_rec.ELMT_TAX_PRO_ACCTD_AMT);
   localdebug(  '  buc_alloc_amt                  :'|| p_ra_ar_rec.BUC_ALLOC_AMT);
   localdebug(  '  buc_alloc_acctd_amt            :'|| p_ra_ar_rec.BUC_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_chrg_alloc_amt             :'|| p_ra_ar_rec.BUC_CHRG_ALLOC_AMT);
   localdebug(  '  buc_chrg_alloc_acctd_amt       :'|| p_ra_ar_rec.BUC_CHRG_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_frt_alloc_amt              :'|| p_ra_ar_rec.BUC_FRT_ALLOC_AMT);
   localdebug(  '  buc_frt_alloc_acctd_amt        :'|| p_ra_ar_rec.BUC_FRT_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_tax_alloc_amt              :'|| p_ra_ar_rec.BUC_TAX_ALLOC_AMT);
   localdebug(  '  buc_tax_alloc_acctd_amt        :'|| p_ra_ar_rec.BUC_TAX_ALLOC_ACCTD_AMT);*/
   localdebug(  '  tl_ed_alloc_amt                :'|| p_ra_ar_rec.TL_ED_ALLOC_AMT);
   localdebug(  '  tl_ed_alloc_acctd_amt          :'|| p_ra_ar_rec.TL_ED_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_ed_chrg_alloc_amt           :'|| p_ra_ar_rec.TL_ED_CHRG_ALLOC_AMT);
   localdebug(  '  tl_ed_chrg_alloc_acctd_amt     :'|| p_ra_ar_rec.TL_ED_CHRG_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_ed_frt_alloc_amt            :'|| p_ra_ar_rec.TL_ED_FRT_ALLOC_AMT);
   localdebug(  '  gt_id                          :'|| p_ra_ar_rec.GT_ID);
   localdebug(  '  base_currency                  :'|| p_ra_ar_rec.BASE_CURRENCY);
   localdebug(  '  to_currency                    :'|| p_ra_ar_rec.TO_CURRENCY);
   localdebug(  '  from_currency                  :'|| p_ra_ar_rec.FROM_CURRENCY);
   localdebug(  '  det_id                         :'|| p_ra_ar_rec.DET_ID);
   localdebug(  '  line_id                        :'|| p_ra_ar_rec.LINE_ID);
   localdebug(  '  ref_customer_trx_id            :'|| p_ra_ar_rec.REF_CUSTOMER_TRX_ID);
   localdebug(  '  ref_customer_trx_line_id       :'|| p_ra_ar_rec.REF_CUSTOMER_TRX_LINE_ID);
   localdebug(  '  ref_cust_trx_line_gl_dist_id   :'|| p_ra_ar_rec.REF_CUST_TRX_LINE_GL_DIST_ID);
   localdebug(  '  ref_line_id                    :'|| p_ra_ar_rec.REF_LINE_ID);
   localdebug(  '  ref_det_id                     :'|| p_ra_ar_rec.REF_DET_ID);
   localdebug(  '  account_class                  :'|| p_ra_ar_rec.ACCOUNT_CLASS);
   localdebug(  '  source_type                    :'|| p_ra_ar_rec.SOURCE_TYPE);
   localdebug(  '  source_table                   :'|| p_ra_ar_rec.SOURCE_TABLE);
   localdebug(  '  source_id                      :'|| p_ra_ar_rec.SOURCE_ID);
   localdebug(  '  amt                            :'|| p_ra_ar_rec.AMT);
   localdebug(  '  acctd_amt                      :'|| p_ra_ar_rec.ACCTD_AMT);
   localdebug(  '  amt_dr                         :'|| p_ra_ar_rec.AMT_DR);
   localdebug(  '  amt_cr                         :'|| p_ra_ar_rec.AMT_CR);
   localdebug(  '  acctd_amt_dr                   :'|| p_ra_ar_rec.ACCTD_AMT_DR);
   localdebug(  '  acctd_amt_cr                   :'|| p_ra_ar_rec.ACCTD_AMT_CR);
   localdebug(  '  from_acctd_amt_dr              :'|| p_ra_ar_rec.FROM_ACCTD_AMT_DR);
   localdebug(  '  from_acctd_amt_cr              :'|| p_ra_ar_rec.FROM_ACCTD_AMT_CR);
   localdebug(  '  ccid                           :'|| p_ra_ar_rec.CCID);
   localdebug(  '  ccid_secondary                 :'|| p_ra_ar_rec.CCID_SECONDARY);
   localdebug(  '  alloc_amt                      :'|| p_ra_ar_rec.ALLOC_AMT);
   localdebug(  '  alloc_acctd_amt                :'|| p_ra_ar_rec.ALLOC_ACCTD_AMT);
   localdebug(  '  from_alloc_amt                 :'|| p_ra_ar_rec.FROM_ALLOC_AMT);
   localdebug(  '  sum_gp_line_orig_amt           :'|| p_ra_ar_rec.SUM_GP_LINE_ORIG_AMT);
   localdebug(  '  sum_gp_line_orig_acctd_amt     :'|| p_ra_ar_rec.SUM_GP_LINE_ORIG_ACCTD_AMT);
   localdebug(  '  sum_gp_line_frt_orig_amt       :'|| p_ra_ar_rec.SUM_GP_LINE_FRT_ORIG_AMT);
   localdebug(  '  sum_gp_line_frt_orig_acctd_amt :'|| p_ra_ar_rec.SUM_GP_LINE_FRT_ORIG_ACCTD_AMT);
   localdebug(  '  sum_gp_line_tax_orig_amt       :'|| p_ra_ar_rec.SUM_GP_LINE_TAX_ORIG_AMT);
   localdebug(  '  tl_frt_alloc_acctd_amt         :'|| p_ra_ar_rec.TL_FRT_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_tax_alloc_amt               :'|| p_ra_ar_rec.TL_TAX_ALLOC_AMT);
   localdebug(  '  tl_tax_alloc_acctd_amt         :'|| p_ra_ar_rec.TL_TAX_ALLOC_ACCTD_AMT);
   localdebug(  '  due_orig_amt                   :'|| p_ra_ar_rec.DUE_ORIG_AMT);
   localdebug(  '  due_orig_acctd_amt             :'|| p_ra_ar_rec.DUE_ORIG_ACCTD_AMT);
   localdebug(  '  frt_orig_amt                   :'|| p_ra_ar_rec.FRT_ORIG_AMT);
   localdebug(  '  frt_orig_acctd_amt             :'|| p_ra_ar_rec.FRT_ORIG_ACCTD_AMT);
   localdebug(  '  tax_orig_amt                   :'|| p_ra_ar_rec.TAX_ORIG_AMT);
   localdebug(  '  tax_orig_acctd_amt             :'|| p_ra_ar_rec.TAX_ORIG_ACCTD_AMT);
   localdebug(  '  due_rem_amt                    :'|| p_ra_ar_rec.DUE_REM_AMT);
   localdebug(  '  due_rem_acctd_amt              :'|| p_ra_ar_rec.DUE_REM_ACCTD_AMT);
   localdebug(  '  chrg_rem_amt                   :'|| p_ra_ar_rec.CHRG_REM_AMT);
   localdebug(  '  chrg_rem_acctd_amt             :'|| p_ra_ar_rec.CHRG_REM_ACCTD_AMT);
   localdebug(  '  frt_rem_amt                    :'|| p_ra_ar_rec.FRT_REM_AMT);
   localdebug(  '  frt_rem_acctd_amt              :'|| p_ra_ar_rec.FRT_REM_ACCTD_AMT);
   localdebug(  '  frt_adj_rem_amt                :'|| p_ra_ar_rec.FRT_ADJ_REM_AMT);
   localdebug(  '  frt_adj_rem_acctd_amt          :'|| p_ra_ar_rec.FRT_ADJ_REM_ACCTD_AMT);
   localdebug(  '  dist_ed_tax_amt                :'|| p_ra_ar_rec.DIST_ED_TAX_AMT);
/*   localdebug(  '  base_ed_frt_pro_amt            :'|| p_ra_ar_rec.BASE_ED_FRT_PRO_AMT);
   localdebug(  '  base_ed_frt_pro_acctd_amt      :'|| p_ra_ar_rec.BASE_ED_FRT_PRO_ACCTD_AMT);
   localdebug(  '  base_ed_tax_pro_amt            :'|| p_ra_ar_rec.BASE_ED_TAX_PRO_AMT);
   localdebug(  '  base_ed_tax_pro_acctd_amt      :'|| p_ra_ar_rec.BASE_ED_TAX_PRO_ACCTD_AMT);*/
   localdebug(  '  tl_uned_alloc_amt              :'|| p_ra_ar_rec.TL_UNED_ALLOC_AMT);
   localdebug(  '  tl_uned_alloc_acctd_amt        :'|| p_ra_ar_rec.TL_UNED_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_uned_chrg_alloc_amt         :'|| p_ra_ar_rec.TL_UNED_CHRG_ALLOC_AMT);
   localdebug(  '  tl_uned_chrg_alloc_acctd_amt   :'|| p_ra_ar_rec.TL_UNED_CHRG_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_uned_frt_alloc_amt          :'|| p_ra_ar_rec.TL_UNED_FRT_ALLOC_AMT);
   localdebug(  '  sum_gp_line_tax_orig_acctd_amt :'|| p_ra_ar_rec.SUM_GP_LINE_TAX_ORIG_ACCTD_AMT);
/*   localdebug(  '  buc_ed_chrg_alloc_acctd_amt    :'|| p_ra_ar_rec.BUC_ED_CHRG_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_ed_frt_alloc_amt           :'|| p_ra_ar_rec.BUC_ED_FRT_ALLOC_AMT);
   localdebug(  '  buc_ed_frt_alloc_acctd_amt     :'|| p_ra_ar_rec.BUC_ED_FRT_ALLOC_ACCTD_AMT);
   localdebug(  '  buc_ed_tax_alloc_amt           :'|| p_ra_ar_rec.BUC_ED_TAX_ALLOC_AMT);
   localdebug(  '  buc_ed_tax_alloc_acctd_amt     :'|| p_ra_ar_rec.BUC_ED_TAX_ALLOC_ACCTD_AMT);
   localdebug(  '  elmt_ed_pro_amt                :'|| p_ra_ar_rec.ELMT_ED_PRO_AMT);
   localdebug(  '  elmt_ed_pro_acctd_amt          :'|| p_ra_ar_rec.ELMT_ED_PRO_ACCTD_AMT);
   localdebug(  '  elmt_ed_chrg_pro_amt           :'|| p_ra_ar_rec.ELMT_ED_CHRG_PRO_AMT);
   localdebug(  '  elmt_ed_chrg_pro_acctd_amt     :'|| p_ra_ar_rec.ELMT_ED_CHRG_PRO_ACCTD_AMT);
   localdebug(  '  elmt_ed_frt_pro_amt            :'|| p_ra_ar_rec.ELMT_ED_FRT_PRO_AMT);*/
   localdebug(  '  sum_line_tax_orig_acctd_amt    :'|| p_ra_ar_rec.SUM_LINE_TAX_ORIG_ACCTD_AMT);
   localdebug(  '  sum_line_rem_amt               :'|| p_ra_ar_rec.SUM_LINE_REM_AMT);
   localdebug(  '  sum_line_rem_acctd_amt         :'|| p_ra_ar_rec.SUM_LINE_REM_ACCTD_AMT);
   localdebug(  '  sum_line_chrg_rem_amt          :'|| p_ra_ar_rec.SUM_LINE_CHRG_REM_AMT);
   localdebug(  '  sum_line_chrg_rem_acctd_amt    :'|| p_ra_ar_rec.SUM_LINE_CHRG_REM_ACCTD_AMT);
   localdebug(  '  sum_line_frt_rem_amt           :'|| p_ra_ar_rec.SUM_LINE_FRT_REM_AMT);
   localdebug(  '  sum_line_frt_rem_acctd_amt     :'|| p_ra_ar_rec.SUM_LINE_FRT_REM_ACCTD_AMT);
   localdebug(  '  sum_line_tax_rem_amt           :'|| p_ra_ar_rec.SUM_LINE_TAX_REM_AMT);
   localdebug(  '  sum_line_tax_rem_acctd_amt     :'|| p_ra_ar_rec.SUM_LINE_TAX_REM_ACCTD_AMT);
/*   localdebug(  '  base_pro_amt                   :'|| p_ra_ar_rec.BASE_PRO_AMT);
   localdebug(  '  base_pro_acctd_amt             :'|| p_ra_ar_rec.BASE_PRO_ACCTD_AMT);
   localdebug(  '  base_chrg_pro_amt              :'|| p_ra_ar_rec.BASE_CHRG_PRO_AMT);
   localdebug(  '  base_chrg_pro_acctd_amt        :'|| p_ra_ar_rec.BASE_CHRG_PRO_ACCTD_AMT);
   localdebug(  '  base_frt_pro_amt               :'|| p_ra_ar_rec.BASE_FRT_PRO_AMT);
   localdebug(  '  base_frt_pro_acctd_amt         :'|| p_ra_ar_rec.BASE_FRT_PRO_ACCTD_AMT);
   localdebug(  '  base_tax_pro_amt               :'|| p_ra_ar_rec.BASE_TAX_PRO_AMT);
   localdebug(  '  base_tax_pro_acctd_amt         :'|| p_ra_ar_rec.BASE_TAX_PRO_ACCTD_AMT);*/
   localdebug(  '  dist_ed_tax_acctd_amt          :'|| p_ra_ar_rec.DIST_ED_TAX_ACCTD_AMT);
   localdebug(  '  sum_gp_line_rem_amt            :'|| p_ra_ar_rec.SUM_GP_LINE_REM_AMT);
   localdebug(  '  sum_gp_line_rem_acctd_amt      :'|| p_ra_ar_rec.SUM_GP_LINE_REM_ACCTD_AMT);
   localdebug(  '  sum_gp_line_chrg_rem_amt       :'|| p_ra_ar_rec.SUM_GP_LINE_CHRG_REM_AMT);
   localdebug(  '  sum_gp_line_chrg_rem_acctd_amt :'|| p_ra_ar_rec.SUM_GP_LINE_CHRG_REM_ACCTD_AMT);
   localdebug(  '  sum_gp_line_frt_rem_amt        :'|| p_ra_ar_rec.SUM_GP_LINE_FRT_REM_AMT);
   localdebug(  '  sum_gp_line_frt_rem_acctd_amt  :'|| p_ra_ar_rec.SUM_GP_LINE_FRT_REM_ACCTD_AMT);
   localdebug(  '  sum_gp_line_tax_rem_amt        :'|| p_ra_ar_rec.SUM_GP_LINE_TAX_REM_AMT);
   localdebug(  '  sum_gp_line_tax_rem_acctd_amt  :'|| p_ra_ar_rec.SUM_GP_LINE_TAX_REM_ACCTD_AMT);
   localdebug(  '  set_of_books_id                :'|| p_ra_ar_rec.SET_OF_BOOKS_ID);
   localdebug(  '  sob_type                       :'|| p_ra_ar_rec.SOB_TYPE);
   localdebug(  '  activity_bucket                         :'|| p_ra_ar_rec.activity_bucket);
   localdebug(  '  source_data_key1               :'|| p_ra_ar_rec.SOURCE_DATA_KEY1);
   localdebug(  '  source_data_key2               :'|| p_ra_ar_rec.SOURCE_DATA_KEY2);
   localdebug(  '  source_data_key3               :'|| p_ra_ar_rec.SOURCE_DATA_KEY3);
   localdebug(  '  source_data_key4               :'|| p_ra_ar_rec.SOURCE_DATA_KEY4);
   localdebug(  '  tl_ed_frt_alloc_acctd_amt      :'|| p_ra_ar_rec.TL_ED_FRT_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_ed_tax_alloc_amt            :'|| p_ra_ar_rec.TL_ED_TAX_ALLOC_AMT);
   localdebug(  '  tl_ed_tax_alloc_acctd_amt      :'|| p_ra_ar_rec.TL_ED_TAX_ALLOC_ACCTD_AMT);
--   localdebug(  '  buc_ed_alloc_amt               :'|| p_ra_ar_rec.BUC_ED_ALLOC_AMT);
   localdebug(  '  tl_uned_frt_alloc_acctd_amt    :'|| p_ra_ar_rec.TL_UNED_FRT_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_uned_tax_alloc_amt          :'|| p_ra_ar_rec.TL_UNED_TAX_ALLOC_AMT);
   localdebug(  '  tl_uned_tax_alloc_acctd_amt    :'|| p_ra_ar_rec.TL_UNED_TAX_ALLOC_ACCTD_AMT);
--   localdebug(  '  buc_uned_alloc_amt             :'|| p_ra_ar_rec.BUC_UNED_ALLOC_AMT);
--   localdebug(  '  buc_uned_alloc_acctd_amt       :'|| p_ra_ar_rec.BUC_UNED_ALLOC_ACCTD_AMT);
   localdebug(  '  tl_frt_alloc_amt               :'|| p_ra_ar_rec.TL_FRT_ALLOC_AMT);
   localdebug(  'arp_det_dist_pkg.display_ra_ar_row()-');
   END IF;
END;


PROCEDURE display_ra_ar_gt
(p_code      IN VARCHAR2 DEFAULT NULL,
 p_gt_id     IN VARCHAR2)
IS
  CURSOR c1 IS
  SELECT * FROM ra_ar_gt
  WHERE gt_id = p_gt_id;

  CURSOR c2 IS
  SELECT * FROM ra_ar_gt
  WHERE gp_level = p_code
  AND gt_id = p_gt_id;

  l_record  c1%ROWTYPE;
  l_record2 c2%ROWTYPE;
BEGIN
 IF (PG_DEBUG = 'Y') THEN
  localdebug('arp_det_dist_pkg.display_ra_ar_gt()+');
  localdebug('  p_code : '||p_code);
  IF p_code IS NULL THEN
    OPEN c1;
    LOOP
      FETCH c1 INTO l_record;
      EXIT WHEN c1%NOTFOUND;
      display_ra_ar_row(l_record);
    END LOOP;
    CLOSE c1;
  ELSE
    OPEN c2;
    LOOP
      FETCH c2 INTO l_record2;
      EXIT WHEN c2%NOTFOUND;
      display_ra_ar_row(l_record2);
    END LOOP;
    CLOSE c2;
  END IF;
  localdebug('arp_det_dist_pkg.display_ra_ar_gt()-');
 END IF;
END;


PROCEDURE display_cust_trx_row
(p_record  IN ra_customer_trx_lines_gt%ROWTYPE)
IS
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.display_cust_trx_row()+');
  localdebug('  CUSTOMER_TRX_LINE_ID           :'|| p_record.CUSTOMER_TRX_LINE_ID);
  localdebug('  LINK_TO_CUST_TRX_LINE_ID       :'|| p_record.LINK_TO_CUST_TRX_LINE_ID);
  localdebug('  CUSTOMER_TRX_ID                :'|| p_record.CUSTOMER_TRX_ID);
  localdebug('  SET_OF_BOOKS_ID                :'|| p_record.SET_OF_BOOKS_ID);
  localdebug('  LINE_TYPE                      :'|| p_record.LINE_TYPE);
  localdebug('  SOURCE_DATA_KEY1               :'|| p_record.SOURCE_DATA_KEY1);
  localdebug('  SOURCE_DATA_KEY2               :'|| p_record.SOURCE_DATA_KEY2);
  localdebug('  SOURCE_DATA_KEY3               :'|| p_record.SOURCE_DATA_KEY3);
  localdebug('  SOURCE_DATA_KEY4               :'|| p_record.SOURCE_DATA_KEY4);
  localdebug('  SOURCE_DATA_KEY5               :'|| p_record.SOURCE_DATA_KEY5);
  localdebug('  AMOUNT_DUE_REMAINING           :'|| p_record.AMOUNT_DUE_REMAINING);
  localdebug('  ACCTD_AMOUNT_DUE_REMAINING     :'|| p_record.ACCTD_AMOUNT_DUE_REMAINING);
  localdebug('  AMOUNT_DUE_ORIGINAL            :'|| p_record.AMOUNT_DUE_ORIGINAL);
  localdebug('  ACCTD_AMOUNT_DUE_ORIGINAL      :'|| p_record.ACCTD_AMOUNT_DUE_ORIGINAL);
  localdebug('  CHRG_AMOUNT_REMAINING          :'|| p_record.CHRG_AMOUNT_REMAINING);
  localdebug('  CHRG_ACCTD_AMOUNT_REMAINING    :'|| p_record.CHRG_ACCTD_AMOUNT_REMAINING);
  localdebug('  FRT_ADJ_REMAINING              :'|| p_record.FRT_ADJ_REMAINING);
  localdebug('  FRT_ADJ_ACCTD_REMAINING        :'|| p_record.FRT_ADJ_ACCTD_REMAINING);
  localdebug('  FRT_ED_AMOUNT                  :'|| p_record.FRT_ED_AMOUNT);
  localdebug('  FRT_ED_ACCTD_AMOUNT            :'|| p_record.FRT_ED_ACCTD_AMOUNT);
  localdebug('  FRT_UNED_AMOUNT                :'|| p_record.FRT_UNED_AMOUNT);
  localdebug('  FRT_UNED_ACCTD_AMOUNT          :'|| p_record.FRT_UNED_ACCTD_AMOUNT);
  localdebug('  CM_AMT_DUE_REM                 :'|| p_record.CM_AMT_DUE_REM);
  localdebug('  CM_ACCTD_AMT_DUE_REM           :'|| p_record.CM_ACCTD_AMT_DUE_REM);
  localdebug('  CM_AMT_DUE_ORIG                :'|| p_record.CM_AMT_DUE_ORIG);
  localdebug('  CM_ACCTD_AMT_DUE_ORIG          :'|| p_record.CM_ACCTD_AMT_DUE_ORIG);
  localdebug('arp_det_dist_pkg.display_cust_trx_row()-');
  END IF;
END;

PROCEDURE display_cust_trx_gt(p_customer_trx_id IN NUMBER)
IS
  CURSOR c IS
  SELECT *
    FROM ra_customer_trx_lines_gt
    WHERE customer_trx_id = p_customer_trx_id;
  l_record  c%ROWTYPE;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.display_cust_trx_gt()+');
  END IF;
  OPEN c;
  LOOP
    FETCH c INTO l_record;
    EXIT WHEN c%NOTFOUND;
    display_cust_trx_row(l_record);
  END LOOP;
  CLOSE c;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.display_cust_trx_gt()-');
  END IF;
END;



--{HYU possible_adj
PROCEDURE get_orig_amt
(p_customer_trx_id IN            NUMBER,
 x_amt_rem         IN OUT NOCOPY g_amt_rem_type) IS
  CURSOR c IS
  SELECT SUM(NVL(amount_due_original,extended_amount)),
         line_type
    FROM ra_customer_trx_lines
   WHERE customer_trx_id = p_customer_trx_id
   GROUP BY line_type;

  CURSOR tl_for_rl IS
  SELECT customer_trx_line_id
    FROM ra_customer_trx_lines
   WHERE customer_trx_id = p_customer_trx_id
     AND line_type IN ('LINE','CB')
  MINUS
  SELECT link_to_cust_trx_line_id
    FROM ra_customer_trx_lines
   WHERE customer_trx_id = p_customer_trx_id
     AND line_type = 'TAX';

  l_amt    NUMBER;
  l_type   VARCHAR2(30);
  l_id     NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_orig_amt()+');
  localdebug('  p_customer_trx_id :'||p_customer_trx_id);
  END IF;
  x_amt_rem.sum_line_amt_orig  := 0;
  x_amt_rem.sum_tax_amt_orig   := 0;
  x_amt_rem.sum_frt_amt_orig   := 0;
  x_amt_rem.tl_for_rl          := 'N';
  OPEN c;
  LOOP
    FETCH c INTO l_amt, l_type;
    IF PG_DEBUG = 'Y' THEN
    localdebug(' l_type:'||l_type);
    localdebug(' l_amt :'||l_amt);
    END IF;
    EXIT WHEN c%NOTFOUND;
    IF    l_type IN ('LINE','CB') THEN
      x_amt_rem.sum_line_amt_orig := l_amt;
    ELSIF l_type = 'TAX' THEN
      x_amt_rem.sum_tax_amt_orig  := l_amt;
    ELSIF l_type = 'FREIGHT' THEN
      x_amt_rem.sum_frt_amt_orig  := l_amt;
    END IF;
  END LOOP;
  CLOSE c;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  x_amt_rem.sum_line_amt_orig :'||x_amt_rem.sum_line_amt_orig);
  localdebug('  x_amt_rem.sum_tax_amt_orig  :'||x_amt_rem.sum_tax_amt_orig);
  localdebug('  x_amt_rem.sum_frt_amt_orig  :'||x_amt_rem.sum_frt_amt_orig);
  END IF;
  OPEN tl_for_rl;
     FETCH tl_for_rl INTO l_id;
     IF tl_for_rl%NOTFOUND THEN
       x_amt_rem.tl_for_rl := 'Y';
     ELSE
       x_amt_rem.tl_for_rl := 'N';
     END IF;
  CLOSE tl_for_rl;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  x_amt_rem.tl_for_rl     :'||x_amt_rem.tl_for_rl);
  localdebug('arp_det_dist_pkg.get_orig_amt()-');
  END IF;
END;


/*------------------------------------------------------+
 | FUNCTION ed_uned_type                                |
 +------------------------------------------------------+
 | Parameters:                                          |
 | -----------                                          |
 | p_source_exec   'ED' 'UNED'                          |
 | p_app_rec       The app record and bucket info.      |
 | p_bucket        'TAX','LINE','FREIGHT','CHARGES'     |
 +------------------------------------------------------+
 | Return  'Y' in the bucket ED or UNED is concerned    |
 |         'N' otherwise                                |
 +------------------------------------------------------+
 | Created 26-OCT-03     Herve Yu                       |
 +------------------------------------------------------*/
FUNCTION ed_uned_type
( p_source_exec   IN VARCHAR2,
  p_app_rec       IN ar_receivable_applications%rowtype,
  p_bucket        IN VARCHAR2)
RETURN VARCHAR2
IS
  l_res  VARCHAR2(1) := 'N';
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.ed_uned_type()+');
  localdebug('  p_source_exec :'||p_source_exec);
  localdebug('  p_bucket      :'||p_bucket);
  END IF;
  IF  p_source_exec = 'ED' THEN
     IF    p_bucket = 'TAX' AND NVL(p_app_rec.tax_ediscounted,0) <> 0  THEN
        l_res := 'Y';
     ELSIF p_bucket IN ('LINE','CB') AND NVL(p_app_rec.line_ediscounted,0) <> 0 THEN
        l_res := 'Y';
     ELSIF p_bucket = 'FREIGHT' AND NVL(p_app_rec.freight_ediscounted,0) <> 0 THEN
        l_res := 'Y';
     ELSIF p_bucket = 'CHARGES' AND NVL(p_app_rec.charges_ediscounted,0) <> 0 THEN
        l_res := 'Y';
     END IF;
  ELSIF p_source_exec = 'UNED' THEN
     IF    p_bucket = 'TAX' AND NVL(p_app_rec.tax_uediscounted,0) <> 0  THEN
        l_res := 'Y';
     ELSIF p_bucket IN ('LINE','CB') AND NVL(p_app_rec.line_uediscounted,0) <> 0 THEN
        l_res := 'Y';
     ELSIF p_bucket = 'FREIGHT' AND NVL(p_app_rec.freight_uediscounted,0) <> 0 THEN
        l_res := 'Y';
     ELSIF p_bucket = 'CHARGES' AND NVL(p_app_rec.charges_uediscounted,0) <> 0 THEN
        l_res := 'Y';
     END IF;
  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  l_res :'||l_res);
  localdebug('arp_det_dist_pkg.ed_uned_type()-');
  END IF;
  RETURN l_res;
END;

/*------------------------------------------------------+
 | FUNCTION tax_adj_type                                |
 +------------------------------------------------------+
 | Parameters:                                          |
 | -----------                                          |
 | p_adj_rec       the adjustment record.               |
 | p_ae_rule_rec   containing accounting acitivity      |
 |                 and bucket info.                     |
 | p_amt_rem       containing amount kept at invoice    |
 |                 lines.                               |
 | p_app_rec       the app rec                          |
 | p_source_exec   'ADJ' 'ED' 'UNED'                    |
 +------------------------------------------------------+
 | Return the codification for tax adjustment           |
 |  Example of code returned TA_TCSINV_YTL              |
 |   meaning Tax adjustment with Tax Code Source =      |
 |   Invoice and                                        |
 |   the buckets Rev is <> 0                            |
 +------------------------------------------------------+
 | Created 26-OCT-03     Herve Yu                       |
 +------------------------------------------------------*/
FUNCTION tax_adj_type(p_adj_rec           IN  ar_adjustments%rowtype,
                      p_ae_rule_rec       IN  ae_rule_rec_type,
                      p_amt_rem           IN  g_amt_rem_type,
                      p_app_rec           IN ar_receivable_applications%rowtype,
                      p_source_exec       IN VARCHAR2)
RETURN VARCHAR2
IS
 l_type   VARCHAR2(30);
 l_amt    NUMBER;
 l_res    VARCHAR2(30);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.tax_adj_type()+');
  localdebug('  p_source_exec:'||p_source_exec);
  END IF;
  IF p_source_exec = 'ADJ' THEN
    IF    p_adj_rec.type = 'TAX' AND (nvl(p_adj_rec.amount,0) <> 0) THEN
       -- Tax Adjustment
       l_res := 'TA';
    ELSIF p_adj_rec.type IN ('LINE','CB') AND (nvl(p_adj_rec.tax_adjusted,0) <> 0) THEN
       -- Line Adjustment Tax bucket
       l_res := 'LATB';
    ELSIF p_adj_rec.type = 'CHARGES' AND (nvl(p_adj_rec.tax_adjusted,0) <> 0) THEN
       l_res := 'CATB';
    ELSIF p_adj_rec.type = 'FREIGHT' AND (nvl(p_adj_rec.tax_adjusted,0) <> 0) THEN
       l_res := 'FATB';
    ELSE
       l_res := 'NOT_CONCERN';
    END IF;
  ELSIF p_source_exec IN ('ED','UNED') THEN
    IF ed_uned_type(p_source_exec,p_app_rec,'TAX') = 'Y' THEN
       l_res := 'TA';
    END IF;
  END IF;
  IF l_res IN ('TA','LATB','CATB','FATB') THEN
    IF    p_ae_rule_rec.tax_code_source1 = 'INVOICE'  THEN
      l_res := l_res ||'_TCSINV';
      IF  p_amt_rem.sum_tax_amt_orig = 0 THEN
        l_res := l_res||'_NTL';
      ELSE
        l_res := l_res||'_YTL';
      END IF;
    ELSIF p_ae_rule_rec.tax_code_source1 = 'ACTIVITY'  THEN
      l_res := l_res ||'_TCSACT';
      IF  p_amt_rem.sum_tax_amt_orig = 0 THEN
        l_res := l_res||'_NTL';
      ELSE
        l_res := l_res||'_YTL';
      END IF;
    ELSIF p_ae_rule_rec.tax_code_source1 = 'NONE'  THEN
      IF    p_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE' THEN
        l_res := l_res || '_GASROI_TCSN';
        IF p_amt_rem.sum_tax_amt_orig = 0  THEN
          l_res := l_res||'_NTL';
        ELSE
          l_res := l_res||'_YTL';
        END IF;
      ELSIF  p_ae_rule_rec.gl_account_source1 = 'ACTIVITY_GL_ACCOUNT' THEN
        l_res := l_res||'_GASACT_TCSN';
/****
        IF    p_amt_rem.sum_tax_amt_orig = 0 THEN
          l_res := l_res||'_NTL';
        ELSE
          l_res := l_res||'_YTL';
        END IF;
****/
      ---Commented the above as part of bug# 6844079, the bug has detail description
      --- l_res will result in exception when _NTL is assigned
        l_res := l_res||'_YTL';

      ELSIF  p_ae_rule_rec.gl_account_source1 = 'TAX_CODE_ON_INVOICE' THEN
        l_res := l_res || '_GASTCI_TCSN';
        IF  p_amt_rem.sum_line_amt_orig = 0 THEN
           l_res := l_res ||'_NRL';
        ELSE
           l_res := l_res ||'_YRL';
        END IF;
        IF    p_amt_rem.sum_tax_amt_orig = 0 THEN
          l_res := l_res||'_NTL';
        ELSE
          l_res := l_res||'_YTL';
        END IF;
      END IF;
    END IF;
  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  l_res:'||l_res);
  localdebug('arp_det_dist_pkg.tax_adj_type()-');
  END IF;
  RETURN l_res;
END;



/*------------------------------------------------------+
 | FUNCTION line_adj_type                               |
 +------------------------------------------------------+
 | Parameters:                                          |
 | -----------                                          |
 | p_adj_rec       the adjustment record.               |
 | p_ae_rule_rec   containing accounting acitivity      |
 |                 and bucket info.                     |
 | p_amt_rem       containing amount kept at invoice    |
 |                 lines.                               |
 | p_app_rec       the app rec                          |
 | p_source_exec   'ADJ' 'ED' 'UNED'                    |
 +------------------------------------------------------+
 | Return the codification for line adjustment          |
 |  Example of code returned LA_GASROI_NRL              |
 |   meaning line adjustment with GL account Source     |
 |   Revenue on Invoice and                             |
 |   the buckets Rev is <> 0                            |
 +------------------------------------------------------+
 | Created 26-OCT-03     Herve Yu                       |
 +------------------------------------------------------*/
FUNCTION line_adj_type(p_adj_rec           IN  ar_adjustments%rowtype,
                       p_ae_rule_rec       IN  ae_rule_rec_type,
                       p_amt_rem           IN  g_amt_rem_type,
                       p_app_rec           IN ar_receivable_applications%rowtype,
                       p_source_exec       IN VARCHAR2)
RETURN VARCHAR2
IS
 l_res VARCHAR2(30);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.line_adj_type()+');
  localdebug('  p_source_exec:'||p_source_exec);
  END IF;
  IF p_source_exec = 'ADJ' THEN
    IF p_adj_rec.type = 'LINE' AND (nvl(p_adj_rec.amount,0) <> 0)  THEN
       l_res := 'LA';
    ELSE
       l_res := 'NOT_CONCERN';
    END IF;
  ELSIF p_source_exec IN ('ED','UNED') THEN
    IF ed_uned_type(p_source_exec,p_app_rec,'LINE') = 'Y' THEN
       l_res := 'LA';
    END IF;
  END IF;
  IF l_res  IN ('LA') THEN
    IF  p_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE' THEN
      l_res := l_res||'_GASROI';
      IF p_amt_rem.sum_line_amt_orig = 0   THEN
        l_res := l_res||'_NRL';
      ELSE
        l_res := l_res||'_YRL';
      END IF;
    ELSIF  p_ae_rule_rec.gl_account_source1 = 'ACTIVITY_GL_ACCOUNT' THEN
      l_res := l_res ||'_GASACT';
      IF p_amt_rem.sum_line_amt_orig = 0  THEN
        l_res := l_res||'_NRL';
      ELSE
        l_res := l_res||'_YRL';
      END IF;
    ELSIF  p_ae_rule_rec.gl_account_source1 = 'TAX_CODE_ON_INVOICE' THEN
      l_res := l_res ||'_GASTCI';
      IF p_amt_rem.sum_line_amt_orig  = 0  THEN
        l_res := l_res||'_NRL';
      ELSE
        l_res := l_res||'_YRL';
        IF p_amt_rem.tl_for_rl = 'Y' THEN
          l_res := l_res||'_YTR';
        ELSE
          l_res := l_res||'_NTR';
        END IF;
      END IF;
    END IF;

  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  l_res:'||l_res);
  localdebug('arp_det_dist_pkg.chrg_adj_type()-');
  END IF;
  RETURN l_res;
END;



/*------------------------------------------------------+
 | FUNCTION frt_adj_type                                |
 +------------------------------------------------------+
 | Parameters:                                          |
 | -----------                                          |
 | p_adj_rec       the adjustment record.               |
 | p_ae_rule_rec   containing accounting acitivity      |
 |                 and bucket info.                     |
 | p_amt_rem       containing amount kept at invoice    |
 |                 lines.                               |
 | p_app_rec       the app rec                          |
 | p_source_exec   'ADJ' 'ED' 'UNED'                    |
 +------------------------------------------------------+
 | Return the codification for freight adjustment       |
 |  Example of code returned FA_GASROI_YRL_YHFL_NLFL    |
 |   meaning freight adjustment with GL account Source  |
 |   Revenue on Invoice and                             |
 |   the buckets Rev and Freight at header are <> 0     |
 +------------------------------------------------------+
 | Created 26-OCT-03     Herve Yu                       |
 +------------------------------------------------------*/
FUNCTION frt_adj_type(p_adj_rec           IN  ar_adjustments%rowtype,
                      p_ae_rule_rec       IN  ae_rule_rec_type,
                      p_amt_rem           IN  g_amt_rem_type,
                      p_app_rec           IN ar_receivable_applications%rowtype,
                      p_source_exec       IN VARCHAR2)
RETURN VARCHAR2
IS
  l_res     VARCHAR2(30);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.frt_adj_type()+');
  localdebug('  p_source_exec:'||p_source_exec);
  END IF;
  IF p_source_exec = 'ADJ' THEN
    IF p_adj_rec.type = 'FREIGHT' AND (nvl(p_adj_rec.amount,0) <> 0)  THEN
      l_res := 'FA';
    ELSE
      l_res := 'NOT_CONCERN';
    END IF;
  ELSIF p_source_exec IN ('ED','UNED') THEN
    IF ed_uned_type(p_source_exec,p_app_rec,'FREIGHT') = 'Y' THEN
       l_res := 'FA';
    END IF;
  END IF;

  IF l_res IN ('FA')  THEN
    IF     p_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE' THEN
      l_res := l_res || '_GASROI';
      IF    p_amt_rem.sum_line_frt_amt_orig <> 0 THEN
         l_res  := l_res||'_NHFL_YLFL';
      ELSIF p_amt_rem.sum_head_frt_amt_orig <> 0 THEN
         l_res  := l_res||'_YHFL_NLFL';
      ELSIF p_amt_rem.sum_head_frt_amt_orig = 0 AND p_amt_rem.sum_line_frt_amt_orig = 0 THEN
         l_res  := l_res||'_NHFL_NLFL';
      END IF;
    ELSIF  p_ae_rule_rec.gl_account_source1 = 'ACTIVITY_GL_ACCOUNT' THEN
      l_res := l_res || '_GASACT';
      IF    p_amt_rem.sum_line_frt_amt_orig <> 0 THEN
         l_res  := l_res||'_NHFL_YLFL';
      ELSIF p_amt_rem.sum_head_frt_amt_orig <> 0 THEN
         l_res  := l_res||'_YHFL_NLFL';
      ELSIF p_amt_rem.sum_head_frt_amt_orig = 0 AND p_amt_rem.sum_line_frt_amt_orig = 0 THEN
         l_res  := l_res||'_NHFL_NLFL';
      END IF;
    ELSIF   p_ae_rule_rec.gl_account_source1 = 'TAX_CODE_ON_INVOICE' THEN
      l_res := l_res || '_GASTCI';
      IF  p_amt_rem.sum_line_frt_amt_orig <> 0 THEN
         l_res := l_res || '_NHFL_YLFL';
         IF  p_amt_rem.tl_for_fl = 'Y' THEN
           l_res := l_res || '_YTF';
         ELSE
           l_res  := l_res|| '_NTF';
         END IF;
      ELSIF p_amt_rem.sum_head_frt_amt_orig <> 0 THEN
         l_res := l_res || '_YHFL_NLFL';
         IF  p_amt_rem.tl_for_fl = 'Y' THEN
           l_res := l_res || '_YTF';
         ELSE
           l_res  := l_res|| '_NTF';
         END IF;
      ELSIF p_amt_rem.sum_head_frt_amt_orig = 0 AND p_amt_rem.sum_line_frt_amt_orig = 0 THEN
         l_res := l_res || '_NHFL_NLFL';
         IF  p_amt_rem.tl_for_fl = 'Y' THEN
           l_res := l_res || '_YTF';
         ELSE
           l_res  := l_res|| '_NTF';
         END IF;
      END IF;
    END IF;
  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  l_res:'||l_res);
  localdebug('arp_det_dist_pkg.frt_adj_type()-');
  END IF;
  RETURN l_res;
END;

/*------------------------------------------------------+
 | FUNCTION chrg_adj_type                               |
 +------------------------------------------------------+
 | Parameters:                                          |
 | -----------                                          |
 | p_adj_rec       the adjustment record.               |
 | p_ae_rule_rec   containing accounting acitivity      |
 |                 and bucket info.                     |
 | p_amt_rem       containing amount kept at invoice    |
 |                 lines.                               |
 | p_app_rec       the app rec                          |
 | p_source_exec   'ADJ' 'ED' 'UNED'                    |
 +------------------------------------------------------+
 | Return the codification for charge adjustment        |
 |  Example of code returned CA_GASACT_YRL_YHFL_NLFL    |
 |   meaning charge adjustment with GL account Activity |
 |   the buckets Rev and Freight at header are <> 0     |
 +------------------------------------------------------+
 | Created 26-OCT-03     Herve Yu                       |
 +------------------------------------------------------*/
FUNCTION chrg_adj_type(p_adj_rec           IN  ar_adjustments%rowtype,
                       p_ae_rule_rec       IN  ae_rule_rec_type,
                       p_amt_rem           IN  g_amt_rem_type,
                       p_app_rec           IN ar_receivable_applications%rowtype,
                       p_source_exec       IN VARCHAR2)
RETURN VARCHAR2
IS
  l_res         VARCHAR2(30);
  l_tot_frt_rev NUMBER;
  l_tot_frt     NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.chrg_adj_type()+');
  localdebug('  p_source_exec:'||p_source_exec);
  END IF;
  IF p_source_exec = 'ADJ' THEN
    IF p_adj_rec.type = 'CHARGES' AND (nvl(p_adj_rec.amount,0) <> 0)  THEN
      l_res := 'CA';
    ELSE
      l_res := 'NOT_CONCERN';
    END IF;
  ELSIF p_source_exec IN ('ED','UNED') THEN
    IF ed_uned_type(p_source_exec,p_app_rec,'CHARGES') = 'Y' THEN
       l_res := 'CA';
    END IF;
  END IF;

  IF l_res IN ('CA') THEN
    IF   p_ae_rule_rec.gl_account_source1 = 'ACTIVITY_GL_ACCOUNT' THEN
      l_res := l_res||'_GASACT';
      IF       p_amt_rem.sum_line_amt_orig <> 0 THEN
         l_res := l_res||'_YRL';
      ELSIF    p_amt_rem.sum_line_amt_orig = 0 THEN
         l_res := l_res||'_NRL';
      END IF;
      IF       p_amt_rem.sum_line_frt_amt_orig <> 0 THEN
         l_res := l_res||'_NHFL_YLFL';
      ELSIF    p_amt_rem.sum_head_frt_amt_orig <> 0 THEN
         l_res := l_res||'_YHFL_NLFL';
      ELSIF    p_amt_rem.sum_head_frt_amt_orig = 0
           AND p_amt_rem.sum_line_frt_amt_orig = 0 THEN
         l_res := l_res||'_NHFL_NLFL';
      END IF;
    ELSIF p_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE' THEN
      l_res := l_res||'_GASROI';
    ELSIF p_ae_rule_rec.gl_account_source1 = 'TAX_CODE_ON_INVOICE' THEN
      l_res := l_res||'_GASTCI';
    END IF;
  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  l_res:'||l_res);
  localdebug('arp_det_dist_pkg.chrg_adj_type()-');
  END IF;
  RETURN l_res;
END;

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
                          p_app_rec           IN  ar_receivable_applications%rowtype
                          )
IS
  l_source_exec   VARCHAR2(30);
  l_amt_rem       g_amt_rem_type;
  l_tax_adj       VARCHAR2(100);
  l_frt_adj       VARCHAR2(100);
  l_line_adj      VARCHAR2(100);
  l_chrg_adj      VARCHAR2(100);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.possible_adjust()+');
  END IF;

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  get_orig_amt(p_customer_trx_id => p_customer_trx_id,
               x_amt_rem         => l_amt_rem);

--  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     x_tax_adj := tax_adj_type(p_adj_rec       => p_adj_rec,
                               p_ae_rule_rec   => p_ae_rule_rec,
                               p_amt_rem       => l_amt_rem,
                               p_app_rec       => p_app_rec,
                               p_source_exec   => 'ADJ');

     IF PG_DEBUG = 'Y' THEN
     localdebug('x_tax_adj : '||x_tax_adj);
     END IF;

     x_line_adj := line_adj_type(p_adj_rec       => p_adj_rec,
                                 p_ae_rule_rec   => p_ae_rule_rec,
                                 p_amt_rem       => l_amt_rem,
                                 p_app_rec       => p_app_rec,
                                 p_source_exec   => 'ADJ');

     IF PG_DEBUG = 'Y' THEN
     localdebug('x_line_adj : '||x_line_adj);
     END IF;

     x_frt_adj  := frt_adj_type(p_adj_rec       => p_adj_rec,
                                p_ae_rule_rec   => p_ae_rule_rec,
                                p_amt_rem       => l_amt_rem,
                                p_app_rec       => p_app_rec,
                                p_source_exec   => 'ADJ');

     IF PG_DEBUG = 'Y' THEN
     localdebug('x_frt_adj : '||x_frt_adj);
     END IF;

     x_chrg_adj  := chrg_adj_type(p_adj_rec       => p_adj_rec,
                                  p_ae_rule_rec   => p_ae_rule_rec,
                                  p_amt_rem       => l_amt_rem,
                                  p_app_rec       => p_app_rec,
                                  p_source_exec   => 'ADJ');

     IF PG_DEBUG = 'Y' THEN
     localdebug('x_chrg_adj : '||x_chrg_adj);
     END IF;

--  END IF;

  -- The impossible cases
  IF x_line_adj IN ('LA_GASROI_NRL',
                    'LA_GASTCI_YRL_NTR',
                    'LA_GASTCI_NRL')
  THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('AR','AR_'||x_line_adj);
      fnd_msg_pub.add;
  END IF;

  IF x_tax_adj IN ('TA_TCSINV_NTL'  ,'TA_GASTCI_TCSN_NTL'  ,'TA_GASROI_TCSN_NTL',
                   'TA_GASACT_TCSN_NTL',
                   'LATB_TCSINV_NTL','LATB_GASTCI_TCSN_NTL','LATB_GASROI_TCSN_NTL',
                   'LATB_GASACT_TCSN_NTL',
                   'CATB_TCSINV_NTL','CATB_GASTCI_TCSN_NTL','CATB_GASROI_TCSN_NTL',
                   'CATB_GASACT_TCSN_NTL',
                   'FATB_TCSINV_NTL','FATB_GASTCI_TCSN_NTL','FATB_GASROI_TCSN_NTL',
                   'FATB_GASACT_TCSN_NTL'
                   ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('AR','AR_'||x_tax_adj);
      fnd_msg_pub.add;
  END IF;

  IF x_frt_adj IN ('FA_GASROI_NHFL_NLFL'    , 'FA_GASROI_YHFL_NLFL',
                   'FA_GASTCI_NHFL_NLFL_NTF', 'FA_GASTCI_NHFL_YLFL_NTF',
                   'FA_GASTCI_NHFL_NLFL_YTF', 'FA_GASTCI_YHFL_NLFL_NTF')  THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('AR','AR_'||x_frt_adj);
      fnd_msg_pub.add;
  END IF;

  -- IF g_chrg_adj IN ('CA_GASROI','CA_GASTCI') THEN --,'CA_GASACT_NRL_NHFL_NLFL') THEN
  -- We do not allowarge adjustment on 0 dollars invoice
  -- currently the case
  -- Invoice with 0 line, 0 tax, 0 Freight
  -- If adjusted with a line adjustment + chrg adjustment is breaking at application time
  --
--  IF g_chrg_adj IN ('CA_GASROI','CA_GASTCI','CA_GASACT_NRL_NHFL_NLFL') THEN
--HYU reautorise 'CA_GASACT_NRL_NHFL_NLFL'
  IF x_chrg_adj IN ('CA_GASROI','CA_GASTCI') THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name('AR','AR_'||x_chrg_adj);
      fnd_msg_pub.add;
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('  x_return_status :'||x_return_status);
  localdebug('arp_det_dist_pkg.possible_adjust()-');
  END IF;
END;


PROCEDURE get_from_currency
  (p_app_rec          IN ar_receivable_applications%ROWTYPE,
   x_from_curr_code   OUT NOCOPY  VARCHAR2)
IS
  CURSOR c_rec_curr(p_cr_id IN NUMBER) IS
  SELECT CURRENCY_CODE
    FROM ar_cash_receipts_all
   WHERE cash_receipt_id = p_cr_id;
  no_curr_on_the_cr   EXCEPTION;
BEGIN
  IF p_app_rec.cash_receipt_id IS NOT NULL THEN
    OPEN c_rec_curr(p_app_rec.cash_receipt_id);
    FETCH c_rec_curr INTO x_from_curr_code;
    IF c_rec_curr%NOTFOUND THEN
      RAISE no_curr_on_the_cr;
    END IF;
    CLOSE c_rec_curr;
  ELSIF p_app_rec.customer_trx_id IS NOT NULL THEN
    x_from_curr_code := g_cust_inv_rec.invoice_currency_code;
  END IF;
EXCEPTION
 WHEN no_curr_on_the_cr THEN
   IF c_rec_curr%ISOPEN THEN
      CLOSE c_rec_curr;
   END IF;
   IF PG_DEBUG = 'Y' THEN
   localdebug(' EXCEPTION no_curr_on_the_cr in get_from_currency cr_id:'||p_app_rec.cash_receipt_id);
   END IF;
 WHEN OTHERS THEN
   IF c_rec_curr%ISOPEN THEN
      CLOSE c_rec_curr;
   END IF;
   IF PG_DEBUG = 'Y' THEN
   localdebug(' EXCEPTION OTHERS in get_from_currency cr_id:'||SQLERRM);
   END IF;
END;

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
 |  17-DEC-2003  H. Yu  Created                                        |
 +---------------------------------------------------------------------*/
FUNCTION Accting_Proration_Fct
  (p_temp_amt                   IN NUMBER,
   p_base_proration             IN NUMBER,
   p_alloc_amount               IN NUMBER,
   p_base_currency              IN VARCHAR2,
   p_trx_currency               IN VARCHAR2,
   p_rec_currency               IN VARCHAR2,
   p_flag                       IN VARCHAR2)
RETURN NUMBER
IS
  l_result        NUMBER;
  l_process       VARCHAR2(1);
  l_run_amt       NUMBER;
  l_run_total     NUMBER;
  l_currency      VARCHAR2(30);
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.Accting_Proration_Fct()+');
  localdebug('  p_temp_amt       : '||p_temp_amt      );
  localdebug('  p_base_proration : '||p_base_proration);
  localdebug('  p_alloc_amount   : '||p_alloc_amount  );
  localdebug('  p_base_currency  : '||p_base_currency );
  localdebug('  p_trx_currency   : '||p_trx_currency  );
  localdebug('  p_rec_currency   : '||p_rec_currency  );
  localdebug('  p_flag           : '||p_flag          );
  END IF;
  l_process := 'Y';
  IF     p_flag = 'FROM_AMT'        THEN
    IF p_trx_currency = p_rec_currency THEN
      l_process := 'N';
    ELSE
      g_run_from_amt := g_run_from_amt + p_temp_amt;
      l_run_amt      := g_run_from_amt;
      l_run_total    := g_run_from_total;
      l_currency     := p_rec_currency;
      IF PG_DEBUG = 'Y' THEN
      localdebug('  g_run_from_amt   in '||p_flag||' : '||g_run_from_amt);
      localdebug('  g_run_from_total in '||p_flag||' : '||g_run_from_total);
      END IF;
    END IF;
  ELSIF  p_flag = 'FROM_ACCTD_AMT'  THEN
    IF p_trx_currency = p_base_currency AND
       p_rec_currency = p_base_currency
    THEN
      l_process := 'N';
    ELSE
      g_run_from_acctd_amt := g_run_from_acctd_amt + p_temp_amt;
      l_run_amt            := g_run_from_acctd_amt;
      l_run_total          := g_run_from_acctd_total;
      l_currency           := p_base_currency;
      IF PG_DEBUG = 'Y' THEN
      localdebug('  g_run_from_acctd_amt   in '||p_flag||' : '||g_run_from_acctd_amt);
      localdebug('  g_run_from_acctd_total in '||p_flag||' : '||g_run_from_acctd_total);
      END IF;
    END IF;
  END IF;
  IF l_process = 'Y' THEN
    IF p_base_proration <> 0 THEN
     l_result :=     CurrRound(  l_run_amt
                                 / p_base_proration
                                 * p_alloc_amount,
                                 l_currency)
                               - l_run_total;
    ELSE
     l_result := 0;
    END IF;
    l_run_total := l_run_total + l_result;

    IF     p_flag = 'FROM_AMT'        THEN
      g_run_from_total := l_run_total;
    ELSIF  p_flag = 'FROM_ACCTD_AMT'  THEN
      g_run_from_acctd_total := l_run_total;
    END IF;
  ELSE
    l_result := p_temp_amt;
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('  l_result : '|| l_result);
  localdebug('arp_det_dist_pkg.Accting_Proration_Fct()-');
  END IF;
  RETURN l_result;
EXCEPTION
 WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug(' EXCEPTION : Accting_Proration_Fct '||SQLERRM);
  END IF;
  app_exception.raise_exception;
END;

/*----------------------------------------------------------------------+
 | PROCEDURE update_from_gt                                             |
 +----------------------------------------------------------------------+
 | This procedure                                                       |
 |  does the updation of ar_ae_alloc_rec_gt for distributions in        |
 |  receipt currency and in base currency converted from receipt        |
 |  currency                                                            |
 |                                                                      |
 | Parameter                                                            |
 | p_from_amt            Amount allocated for line, frt, tax in Receipt |
 |                       currency                                       |
 | p_from_acctd_amt      Acctd Amount allocated for line, frt, tax in   |
 |                       in base currency from the Receipt currency     |
 |                       using exchange rate of the receipt             |
 | History                                                              |
 |  05-NOV-2004  H. Yu  Created                                         |
 +----------------------------------------------------------------------*/
PROCEDURE update_from_gt
(p_from_amt            IN NUMBER,
 p_from_acctd_amt      IN NUMBER,
 p_ae_sys_rec          IN arp_acct_main.ae_sys_rec_type,
 p_app_rec             IN ar_receivable_applications%ROWTYPE,
 p_gt_id               IN VARCHAR2 DEFAULT NULL,
 p_inv_currency        IN VARCHAr2 DEFAULT NULL)
IS
  CURSOR cu1(p_gt_id IN NUMBER) IS
  SELECT /*+INDEX (AR_LINE_APP_DETAIL_GT AR_LINE_APP_DETAIL_GT_N1)*/
         SUM(NVL(amount,0)),
         SUM(NVL(acctd_amount,0))
    FROM AR_LINE_APP_DETAIL_GT
   WHERE gt_id = p_gt_id
     AND activity_bucket IN ('APP_LINE','APP_CHRG','APP_TAX','APP_FRT',
                    'ADJ_LINE','ADJ_TAX','ADJ_CHRG','ADJ_FRT')
     AND (   NVL(amount,0)            <> 0
          OR NVL(acctd_amount,0)      <> 0);

  l_pro_base               NUMBER;
  l_pro_acctd_base         NUMBER;
  l_process                VARCHAR2(1);
  l_from_curr_code         VARCHAR2(30);
--{LLCA CROSS CURRENCY
  l_gt_id                  VARCHAR2(30);
  l_inv_currency           VARCHAR2(30);
--}
  no_from_amount_required  EXCEPTION;
  /* local variables introduced as part of bug 7343649 - vavenugo*/
  l_source_id              NUMBER;
  l_br_flag                VARCHAR2(1) DEFAULT 'N';
  l_br_count               NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_from_gt()+');
  END IF;

  --{LLCA CROSS CURRENCY
  IF   p_gt_id IS NULL THEN
    l_gt_id := g_gt_id;
  ELSE
    l_gt_id := p_gt_id;
  END IF;

  /* Bug 7343649. Populating l_source_id and l_br_flag. -vavenugo */
  /*Bug7391957, Added following SELECT statement within a BEGIN..END block */
  BEGIN
  select distinct source_id
  into l_source_id
  from ar_line_app_detail_gt
  where gt_id = l_gt_id
  AND source_table ='RA';

  select count(*)
  into l_br_count
  from ar_receivable_applications_all ra,
       ar_payment_schedules_all pay
  where ra.receivable_application_id = l_source_id and
        ra.applied_payment_schedule_id = pay.payment_schedule_id and
	pay.class ='BR';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
       NULL;
  WHEN OTHERS THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug(' EXCEPTION: update_from_gt :'||SQLERRM);
       END IF;
       RAISE;
  END;

  IF l_br_count > 0 THEN
     l_br_flag :='Y';
  END IF;


  IF   p_inv_currency IS NULL THEN
    l_inv_currency := g_cust_inv_rec.invoice_currency_code;
  ELSE
    l_inv_currency := p_inv_currency;
  END IF;
  --}
  g_run_from_amt               := 0;
  g_run_from_total             := 0;
  g_run_from_acctd_amt         := 0;
  g_run_from_acctd_total       := 0;

  IF p_app_rec.receivable_application_id IS NOT NULL THEN
     get_from_currency(p_app_rec          => p_app_rec,
                       x_from_curr_code   => l_from_curr_code);

     IF l_from_curr_code IS NULL AND p_app_rec.customer_trx_id IS NOT NULL THEN
        l_from_curr_code := l_inv_currency;
     END IF;
     IF PG_DEBUG = 'Y' THEN
     localdebug(' l_from_curr_code :'||l_from_curr_code);
     END IF;
  ELSE
     -- No from distribution process required as no receivable_application
     RAISE no_from_amount_required;
  END IF;

  /* Bug7343649 - vavenugo */
/* Check if the application involves BR and if so populate the base amounts using the new logic */
IF l_br_flag <> 'Y' THEN

  /* Proceed as usual */

  OPEN cu1(l_gt_id);
    FETCH cu1 INTO l_pro_base,
                   l_pro_acctd_base;
    IF cu1%NOTFOUND THEN
      l_process := 'N';
    ELSE
      l_process := 'Y';
    END IF;
  CLOSE cu1;

 ELSE

    /* Use new the logic */

     IF l_source_id is null THEN
      l_process := 'N';
    ELSE
      l_process := 'Y';
    END IF;


     SELECT amount_applied,acctd_amount_applied_to
     INTO l_pro_base, l_pro_acctd_base
     from ar_receivable_applications_all
     where receivable_application_id = l_source_id;

 END IF;
 /* End bug7343649 - vavenugo */


  IF PG_DEBUG = 'Y' THEN
  localdebug(' l_process 1 : '|| l_process);
  END IF;

  IF l_process = 'Y' THEN

    IF PG_DEBUG = 'Y' THEN
    localdebug(' l_pro_base           : '||l_pro_base);
    localdebug(' l_pro_acctd_base     : '|| l_pro_acctd_base);
    END IF;


    UPDATE AR_LINE_APP_DETAIL_GT a
    SET(FROM_AMOUNT                ,
        FROM_ACCTD_AMOUNT          ) =
    (SELECT DECODE(l_pro_base,0,0,
                 Accting_Proration_Fct
                 (AMOUNT,
                  l_pro_base,
                  p_from_amt,
                  p_ae_sys_rec.base_currency,
                  l_inv_currency,
                  l_from_curr_code,
                  'FROM_AMT')),
            DECODE(l_pro_acctd_base,0,0,
                 Accting_Proration_Fct
                 (ACCTD_AMOUNT,
                  l_pro_acctd_base,
                  p_from_acctd_amt,
                  p_ae_sys_rec.base_currency,
                  l_inv_currency,
                  l_from_curr_code,
                  'FROM_ACCTD_AMT'))
       FROM AR_LINE_APP_DETAIL_GT b
      WHERE a.rowid    = b.rowid
        AND b.gt_id    = l_gt_id
        AND b.activity_bucket IN
            ('APP_LINE','APP_CHRG','APP_TAX','APP_FRT',
             'ADJ_LINE','ADJ_TAX','ADJ_CHRG','ADJ_FRT',
             'ED_LINE','ED_TAX','ED_CHRG','ED_FRT',
             'UNED_LINE','UNED_TAX','UNED_CHRG','UNED_FRT'))
     WHERE ( NVL(a.amount,0) <> 0 OR NVL(a.acctd_amount,0) <> 0)
       AND a.gt_id = l_gt_id;

  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_from_gt()-');
  END IF;
EXCEPTION
  WHEN no_from_amount_required THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug(' Handled exception No from distribution process required- probably a adjustment or a CM APP');
    END IF;
  WHEN OTHERS THEN
    IF cu1%ISOPEN THEN CLOSE cu1; END IF;
    IF PG_DEBUG = 'Y' THEN
    localdebug(' EXCEPTION: update_from_gt :'||SQLERRM);
    END IF;
    RAISE;
END;



PROCEDURE exec_adj_api_if_required
  (p_adj_rec         IN ar_adjustments%ROWTYPE,
   p_app_rec         IN ar_receivable_applications%ROWTYPE,
   p_ae_rule_rec     IN ae_rule_rec_type,
   p_cust_inv_rec    IN ra_customer_trx%ROWTYPE)
IS

  CURSOR get_group_data_rev IS
   SELECT account_class           account_class,
          SUM(amount)             sum_amount,
          SUM(acctd_amount)       sum_acctd_amount,
          COUNT(account_class)    count
     FROM ra_cust_trx_line_gl_dist
    WHERE customer_trx_id = p_cust_inv_rec.customer_trx_id
      AND account_class IN ('UNEARN','UNBILL')
    GROUP BY account_class;

  l_account_class         VARCHAR2(30);
  l_sum_amount            NUMBER;
  l_sum_acctd_amount      NUMBER;
  l_count                 NUMBER;

  l_rev_adj_rec           AR_Revenue_Adjustment_PVT.Rev_Adj_Rec_Type;
  l_adj_id                NUMBER;
  l_dist_count            NUMBER;
  l_adj_number            ar_adjustments.adjustment_number%TYPE;
  l_ra_dist_tbl           AR_Revenue_Adjustment_PVT.RA_Dist_Tbl_Type;

  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_mesg                  VARCHAR2(2000) := '';
  ram_api_error           EXCEPTION;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.exec_adj_api_if_required()+');
  localdebug('  p_adj_rec.adjustment_id            :' || p_adj_rec.adjustment_id);
  localdebug('  p_app_rec.receivable_application_id:' || p_app_rec.receivable_application_id);
  localdebug('  p_cust_inv_rec.customer_trx_id     :' || p_cust_inv_rec.customer_trx_id);
  END IF;

  OPEN get_group_data_rev;
  FETCH get_group_data_rev INTO  l_account_class,
                                 l_sum_amount,
                                 l_sum_acctd_amount,
                                 l_count;

  IF get_group_data_rev%NOTFOUND THEN
    -- Normal invoice
     NULL;
  ELSE
    IF PG_DEBUG = 'Y' THEN
    localdebug('  l_sum_amount         :' || l_sum_amount);
    localdebug('  l_sum_acctd_amount   :' || l_sum_acctd_amount);
    END IF;

    IF ((l_sum_amount <> 0) OR (l_sum_acctd_amount <> 0)) THEN
       --
       --condition as to whether the RAM api will require to be called if gl account
       --source is revenue on invoice
       --
       IF (((p_adj_rec.adjustment_id IS NOT NULL)
           AND (p_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE')
                AND (((nvl(p_adj_rec.line_adjusted,0) + nvl(p_adj_rec.freight_adjusted,0) +
                       nvl(p_adj_rec.receivables_charges_adjusted,0)) <> 0)
                     OR ((p_ae_rule_rec.tax_code_source1 = 'NONE') AND (nvl(p_adj_rec.tax_adjusted,0) <> 0))
                    ))
           OR
           ((p_app_rec.receivable_application_id IS NOT NULL)
            AND (((p_ae_rule_rec.gl_account_source1 = 'REVENUE_ON_INVOICE')
                  AND (((nvl(p_app_rec.line_ediscounted,0) + nvl(p_app_rec.freight_ediscounted,0) +
                         nvl(p_app_rec.charges_ediscounted,0)) <> 0)
                         OR ((p_ae_rule_rec.tax_code_source1 = 'NONE') AND (nvl(p_app_rec.tax_ediscounted,0) <> 0))
                      ))
                 OR
                 ((p_ae_rule_rec.gl_account_source2 = 'REVENUE_ON_INVOICE')
                  AND (((nvl(p_app_rec.line_uediscounted,0) + nvl(p_app_rec.freight_uediscounted,0) +
                         nvl(p_app_rec.charges_uediscounted,0)) <> 0)
                        OR ((p_ae_rule_rec.tax_code_source2 = 'NONE') AND (nvl(p_app_rec.tax_uediscounted,0) <> 0))
                      ))
                ))
            )
       THEN --call revenue adjustment api

       /*----------------------------------------------------------------------------+
        | Call the revenue adjustment api to derive the revenue distributions on the |
        | fly, to allocate the amounts for gl account source = revenue on Invoice.   |
        +----------------------------------------------------------------------------*/
          l_rev_adj_rec.customer_trx_id := p_cust_inv_rec.customer_trx_id;
          l_rev_adj_rec.reason_code     := 'ACCOUNTING';

          IF PG_DEBUG = 'Y' THEN
	  localdebug('  Calling AR_Revenue_Adjustment_PVT.Earn_Revenue ');
	  END IF;

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


           IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)  THEN

               IF l_msg_count > 1 THEN
                  fnd_msg_pub.reset;
                --get only the first message from the api message stack for forms users
                  l_mesg := fnd_msg_pub.get(p_encoded=>FND_API.G_FALSE);
               ELSE
                  l_mesg := l_msg_data;
               END IF;

              localdebug('  l_mesg :' || l_mesg);

             --Now set the message token
               FND_MESSAGE.SET_NAME('AR', 'GENERIC_MESSAGE');
               FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', l_mesg);

               RAISE ram_api_error;

           END IF; --rev adj gl dist table exists and success from api

       END IF;

    END IF;

  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.exec_adj_api_if_required()-');
  END IF;
EXCEPTION
  WHEN ram_api_error THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug('ram_api_error - exec_adj_api_if_required :'||l_mesg );
     END IF;
     RAISE;
  WHEN OTHERS THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug('EXCEPTION: exec_adj_api_if_required :'||SQLERRM);
     END IF;
     RAISE;
END;


PROCEDURE exec_revrec_if_required
( p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE,
  p_app_rec          IN  ar_receivable_applications%ROWTYPE,
  p_adj_rec          IN  ar_adjustments%ROWTYPE)
IS
  CURSOR c1 IS
   SELECT ctl.customer_trx_id
     FROM ra_customer_trx_lines ctl
    WHERE ctl.customer_trx_id = p_customer_trx_id
      AND ctl.autorule_complete_flag||'' = 'N'
    GROUP BY ctl.customer_trx_id;
  l_dummy           NUMBER;
  l_rev_rec_req     BOOLEAN;
  l_sum_dist        NUMBER;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.exec_revrec_if_required()+');
  localdebug('  p_customer_trx_id                   :' || p_customer_trx_id);
  localdebug('  p_app_rec.receivable_application_id :' || p_app_rec.receivable_application_id);
  localdebug('  p_adj_rec.adjustment_id             :' || p_adj_rec.adjustment_id);

  localdebug('   Check whether Rev Recognition is to be Run');
  END IF;
  OPEN c1;
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('    No need to run rev rec for trx_id :' || p_customer_trx_id);
    END IF;
    l_rev_rec_req := FALSE;
  ELSE
    IF PG_DEBUG = 'Y' THEN
    localdebug('    Need to run rev rec for trx_id    :' || p_customer_trx_id);
    END IF;
    l_rev_rec_req := TRUE;
  END IF;
  CLOSE c1;

  IF l_rev_rec_req THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug('  Executing Rev Rec - calling ARP_AUTO_RULE.create_distributions');
     END IF;
     l_sum_dist := ARP_AUTO_RULE.create_distributions
                   ( p_commit => 'N',
                     p_debug  => 'N',
                     p_trx_id => p_customer_trx_id);
     IF PG_DEBUG = 'Y' THEN
     localdebug('   Completed running revenue recognition for Transaction');
     END IF;
  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug( 'arp_det_dist_pkg.exec_revrec_if_required()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug(  'EXCEPTION OTHERS exec_revrec_if_required :'||SQLERRM);
     END IF;
     RAISE;
END;


PROCEDURE exec_revrec_if_required
(p_init_msg_list    IN         VARCHAR2  DEFAULT FND_API.G_TRUE
,p_mode             IN         VARCHAR2  DEFAULT 'TRANSACTION'
,p_customer_trx_id  IN         NUMBER    DEFAULT NULL
,p_request_id       IN         NUMBER    DEFAULT NULL
,x_sum_dist         OUT NOCOPY NUMBER
,x_return_status    OUT NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER
,x_msg_data         OUT NOCOPY VARCHAR2)
IS
  CURSOR c1(p_customer_trx_id IN NUMBER) IS
   SELECT ctl.customer_trx_id
     FROM ra_customer_trx_lines ctl
    WHERE ctl.customer_trx_id = p_customer_trx_id
      AND ctl.autorule_complete_flag||'' = 'N'
    GROUP BY ctl.customer_trx_id;

  CURSOR c_trx_number(p_customer_trx_id IN NUMBER) IS
   SELECT ct.trx_number
     FROM ra_customer_trx ct
    WHERE ct.customer_trx_id = p_customer_trx_id;

  l_message         VARCHAR2(2000);
  l_trx_number      VARCHAR2(20);
  l_dummy           NUMBER;
  l_rev_rec_req     BOOLEAN;
  wrong_parameter   EXCEPTION;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.exec_revrec_if_required()+');
  localdebug('  p_mode              :' || p_mode);
  localdebug('  p_customer_trx_id   :' || p_customer_trx_id);
  localdebug('  p_request_id        :' || p_request_id);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF p_mode <> 'TRANSACTION' THEN
     x_msg_data  := 'Only transaction mode is supported currently.
';
     x_msg_count :=  1;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_mode = 'TRANSACTION' AND p_customer_trx_id IS NULL THEN
     x_msg_data  := x_msg_data||'The p_customer_trx_id is required, currently it is passed as null.
';
     x_msg_count := 1;
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
    RAISE wrong_parameter;
  END IF;


  IF PG_DEBUG = 'Y' THEN
  localdebug('   Check whether Rev Recognition is to be Run');
  END IF;
  OPEN c1(p_customer_trx_id);
  FETCH c1 INTO l_dummy;
  IF c1%NOTFOUND THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('    No need to run rev rec for trx_id :' || p_customer_trx_id);
    END IF;
    l_rev_rec_req := FALSE;
  ELSE
    IF PG_DEBUG = 'Y' THEN
    localdebug('    Need to run rev rec for trx_id    :' || p_customer_trx_id);
    END IF;
    l_rev_rec_req := TRUE;
  END IF;
  CLOSE c1;


  IF l_rev_rec_req THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug('  Executing Rev Rec - calling ARP_AUTO_RULE.create_distributions');
     END IF;
     x_sum_dist := ARP_AUTO_RULE.create_distributions
                   ( p_commit => 'N',
                     p_debug  => 'N',
                     p_trx_id => p_customer_trx_id);
     IF x_sum_dist < 0 THEN
        OPEN c_trx_number(p_customer_trx_id);
        FETCH c_trx_number INTO l_trx_number;
        CLOSE c_trx_number;
        FND_MESSAGE.SET_NAME( 'AR', 'AR_AUTORULE_ERROR' );
        FND_MESSAGE.SET_TOKEN( 'TRX_NUMBER', l_trx_number );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     IF PG_DEBUG = 'Y' THEN
     localdebug('   Completed running revenue recognition for Transaction');
     END IF;
  END IF;

  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;
  IF PG_DEBUG = 'Y' THEN
  localdebug( 'arp_det_dist_pkg.exec_revrec_if_required()-');
  END IF;
EXCEPTION
  WHEN fnd_api.G_EXC_ERROR THEN
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  WHEN wrong_parameter THEN localdebug(x_msg_count);

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := NVL(x_msg_count,0) + 1;
     x_msg_data :='EXCEPTION OTHERS exec_revrec_if_required :'||SQLERRM ;
     IF PG_DEBUG = 'Y' THEN
     localdebug(x_msg_data  );
     END IF;
END;

PROCEDURE update_taxable
(p_gt_id             IN VARCHAR2,
 p_customer_trx_id   IN NUMBER,
 p_ae_sys_rec        IN arp_acct_main.ae_sys_rec_type)
IS
  CURSOR c_read_for_taxable IS
   select
     GROUPE                  ,
  -- ADJ and APP
     -- Base
     base_pro_amt       ,
     base_pro_acctd_amt ,
     BASE_FRT_PRO_AMT       ,
     BASE_FRT_PRO_ACCTD_AMT ,
     sum(ELMT_TAX_PRO_AMT) over (partition by groupe) BASE_TAX_PRO_AMT ,
     sum(ELMT_TAX_PRO_ACCTD_AMT) over (partition by groupe) BASE_TAX_PRO_ACCTD_AMT ,
     BASE_CHRG_PRO_AMT       ,
     BASE_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     elmt_pro_amt       ,
     elmt_pro_acctd_amt ,
     ELMT_FRT_PRO_AMT       ,
     ELMT_FRT_PRO_ACCTD_AMT ,
     ELMT_TAX_PRO_AMT,
     ELMT_TAX_PRO_ACCTD_AMT ,
     ELMT_CHRG_PRO_AMT       ,
     ELMT_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     buc_alloc_amt      ,
     buc_alloc_acctd_amt,
     buc_frt_alloc_amt      ,
     buc_frt_alloc_acctd_amt,
     buc_tax_alloc_amt      ,
     buc_tax_alloc_acctd_amt,
     buc_chrg_alloc_amt      ,
     buc_chrg_alloc_acctd_amt,
  -- ED
     -- Base
     base_ed_pro_amt       ,
     base_ed_pro_acctd_amt ,
     BASE_ed_FRT_PRO_AMT       ,
     BASE_ed_FRT_PRO_ACCTD_AMT ,
     sum(ELMT_ed_TAX_PRO_AMT) over (partition by groupe) BASE_ed_TAX_PRO_AMT ,
     sum(ELMT_ed_TAX_PRO_ACCTD_AMT) over (partition by groupe) BASE_ed_TAX_PRO_ACCTD_AMT ,
     BASE_ed_CHRG_PRO_AMT       ,
     BASE_ed_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     elmt_ed_pro_amt       ,
     elmt_ed_pro_acctd_amt ,
     ELMT_ed_FRT_PRO_AMT       ,
     ELMT_ed_FRT_PRO_ACCTD_AMT ,
     ELMT_ed_TAX_PRO_AMT       ,
     ELMT_ed_TAX_PRO_ACCTD_AMT ,
     ELMT_ed_CHRG_PRO_AMT       ,
     ELMT_ed_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     buc_ed_alloc_amt      ,
     buc_ed_alloc_acctd_amt,
     buc_ed_frt_alloc_amt      ,
     buc_ed_frt_alloc_acctd_amt,
     buc_ed_tax_alloc_amt      ,
     buc_ed_tax_alloc_acctd_amt,
     buc_ed_chrg_alloc_amt      ,
     buc_ed_chrg_alloc_acctd_amt,
  -- UNED
     -- Base
     base_uned_pro_amt       ,
     base_uned_pro_acctd_amt ,
     BASE_uned_FRT_PRO_AMT       ,
     BASE_uned_FRT_PRO_ACCTD_AMT ,
     sum(ELMT_uned_TAX_PRO_AMT) over (partition by groupe) BASE_uned_TAX_PRO_AMT ,
     sum(ELMT_uned_TAX_PRO_ACCTD_AMT) over (partition by groupe) BASE_uned_TAX_PRO_ACCTD_AMT ,
     BASE_uned_CHRG_PRO_AMT       ,
     BASE_uned_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     elmt_uned_pro_amt       ,
     elmt_uned_pro_acctd_amt ,
     ELMT_uned_FRT_PRO_AMT       ,
     ELMT_uned_FRT_PRO_ACCTD_AMT ,
     ELMT_uned_TAX_PRO_AMT       ,
     ELMT_uned_TAX_PRO_ACCTD_AMT ,
     ELMT_uned_CHRG_PRO_AMT       ,
     ELMT_uned_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     buc_uned_alloc_amt      ,
     buc_uned_alloc_acctd_amt,
     buc_uned_frt_alloc_amt      ,
     buc_uned_frt_alloc_acctd_amt,
     buc_uned_tax_alloc_amt      ,
     buc_uned_tax_alloc_acctd_amt,
     buc_uned_chrg_alloc_amt      ,
     buc_uned_chrg_alloc_acctd_amt,
     --
     BASE_CURRENCY  ,
     TO_CURRENCY    ,
     FROM_CURRENCY  ,
     --
     rowid
    from (SELECT /*+INDEX (AR_LINE_APP_DETAIL_GT AR_LINE_APP_DETAIL_GT_N1)*/
	       tax_link_id     groupe,
        -- ADJ and APP
           --Base
           0 base_pro_amt, --Base for Revenue distributions
           0 base_pro_acctd_amt,
           0 BASE_FRT_PRO_AMT, --Base for freight distributions
           0 BASE_FRT_PRO_ACCTD_AMT,
           0 BASE_CHRG_PRO_AMT,                       --Base for charge distributions
           0 BASE_CHRG_PRO_ACCTD_AMT,
           --Element
           0 elmt_pro_amt, --Element for Revenue distributions
           0 elmt_pro_acctd_amt,
           0 ELMT_FRT_PRO_AMT, --Element for freight distributions
           0 ELMT_FRT_PRO_ACCTD_AMT,
           DECODE(activity_bucket||ref_account_class, 'ADJ_TAXTAX',
                     DECODE(SUM(DECODE(activity_bucket,'APP_TAX', amount, 'ADJ_TAX', amount, 0))
                            OVER (PARTITION BY tax_link_id ), 0, 1,
                            DECODE(activity_bucket,'APP_TAX', amount, 'ADJ_TAX', amount, 0)),
                   DECODE(activity_bucket,'APP_TAX', amount, 'ADJ_TAX', amount, 0)
                 ) ELMT_TAX_PRO_AMT,    --Element for tax distributions
           DECODE(activity_bucket||ref_account_class, 'ADJ_TAXTAX',
                     DECODE(SUM(DECODE(activity_bucket,'APP_TAX', acctd_amount, 'ADJ_TAX', acctd_amount, 0))
                            OVER (PARTITION BY tax_link_id ), 0, 1,
                            DECODE(activity_bucket,'APP_TAX', acctd_amount, 'ADJ_TAX', acctd_amount, 0)),
                   DECODE(activity_bucket,'APP_TAX', acctd_amount, 'ADJ_TAX', acctd_amount, 0)
                 ) ELMT_TAX_PRO_ACCTD_AMT,
           0 ELMT_CHRG_PRO_AMT, --Element for charge distributions
           0 ELMT_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           0 buc_alloc_amt,                        --Allocation for Revenue distributions
           0 buc_alloc_acctd_amt,
           0 buc_frt_alloc_amt,                        --Allocation for freight distributions
           0 buc_frt_alloc_acctd_amt,
           SUM(DECODE(activity_bucket,'APP_LINE',amount,
                             'ADJ_LINE',amount,
                             'APP_CHRG',amount,
                             'ADJ_CHRG',amount,
                             'APP_FRT' ,amount,
                             'ADJ_FRT' ,amount, 0))
                OVER (PARTITION BY tax_link_id ) buc_tax_alloc_amt,   -- Allocation for app and adj
                                                        -- taxable from the revenue distribution
           SUM(DECODE(activity_bucket,'APP_LINE',acctd_amount,
                             'ADJ_LINE',acctd_amount,
                             'APP_CHRG',acctd_amount,
                             'ADJ_CHRG',acctd_amount,
                             'APP_FRT' ,acctd_amount,
                             'ADJ_FRT' ,acctd_amount, 0))
                OVER (PARTITION BY tax_link_id ) buc_tax_alloc_acctd_amt,
           0 buc_chrg_alloc_amt,                        --Allocation for charge distributions
           0 buc_chrg_alloc_acctd_amt,
        -- ED
           --Base
           0 base_ed_pro_amt, --Base ED on Rev
           0 base_ed_pro_acctd_amt,
           0 BASE_ed_FRT_PRO_AMT, --Base ED on Freight HYUFR
           0 BASE_ed_FRT_PRO_ACCTD_AMT,
           0 BASE_ed_CHRG_PRO_AMT, --Base ED on Charge
           0 BASE_ed_CHRG_PRO_ACCTD_AMT,
           --Element
           0 elmt_ed_pro_amt, --Element ED on Rev
           0 elmt_ed_pro_acctd_amt,
           0 ELMT_ed_FRT_PRO_AMT, --Element ED on Freight
           0 ELMT_ed_FRT_PRO_ACCTD_AMT,
           DECODE(activity_bucket||ref_account_class, 'ED_TAXTAX',
                     DECODE(SUM(DECODE(activity_bucket,'ED_TAX', amount, 0))
                            OVER (PARTITION BY tax_link_id ), 0, 1,
                            DECODE(activity_bucket,'ED_TAX', amount, 0)),
                   DECODE(activity_bucket,'ED_TAX', amount, 0)
                 ) ELMT_ed_TAX_PRO_AMT,    --Element ED on Tax HYUFRTAX
           DECODE(activity_bucket||ref_account_class, 'ED_TAXTAX',
                     DECODE(SUM(DECODE(activity_bucket,'ED_TAX', acctd_amount, 0))
                            OVER (PARTITION BY tax_link_id ), 0, 1,
                            DECODE(activity_bucket,'ED_TAX', acctd_amount, 0)),
                   DECODE(activity_bucket,'ED_TAX', acctd_amount, 0)
                 ) ELMT_ed_TAX_PRO_ACCTD_AMT,
           0 ELMT_ed_CHRG_PRO_AMT, --Element ED on Charge
           0 ELMT_ed_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           0 buc_ed_alloc_amt, --Allocation ED on Rev
           0 buc_ed_alloc_acctd_amt,
           0 buc_ed_frt_alloc_amt, --Allocation ED on Freight
           0 buc_ed_frt_alloc_acctd_amt,
           SUM(DECODE(activity_bucket,'ED_LINE', amount,
                             'ED_CHRG', amount,
                             'ED_FRT' , amount,0))
                OVER (PARTITION BY tax_link_id ) buc_ed_tax_alloc_amt,  --Allocation ED on Tax by the rev ed
           SUM(DECODE(activity_bucket,'ED_LINE', acctd_amount,
                             'ED_CHRG', acctd_amount,
                             'ED_FRT' , acctd_amount,0))
                OVER (PARTITION BY tax_link_id ) buc_ed_tax_alloc_acctd_amt,
           0 buc_ed_chrg_alloc_amt,
           0 buc_ed_chrg_alloc_acctd_amt,
        -- UNED
           --Base
           0 base_uned_pro_amt,
           0 base_uned_pro_acctd_amt,
           0 BASE_uned_FRT_PRO_AMT,
           0 BASE_uned_FRT_PRO_ACCTD_AMT,
           0 BASE_uned_CHRG_PRO_AMT,
           0 BASE_uned_CHRG_PRO_ACCTD_AMT,
           --Element
           0 elmt_uned_pro_amt,
           0 elmt_uned_pro_acctd_amt,
           0 ELMT_uned_FRT_PRO_AMT,
           0 ELMT_uned_FRT_PRO_ACCTD_AMT,
           DECODE(activity_bucket||ref_account_class, 'UNED_TAXTAX',
                     DECODE(SUM(DECODE(activity_bucket,'UNED_TAX', amount, 0))
                            OVER (PARTITION BY tax_link_id ), 0, 1,
                            DECODE(activity_bucket,'UNED_TAX', amount, 0)),
                   DECODE(activity_bucket,'UNED_TAX', amount, 0)
                 ) ELMT_uned_TAX_PRO_AMT,    --Element ED on Tax HYUFRTAX
           DECODE(activity_bucket||ref_account_class, 'UNED_TAXTAX',
                     DECODE(SUM(DECODE(activity_bucket,'UNED_TAX', acctd_amount, 0))
                            OVER (PARTITION BY tax_link_id ), 0, 1,
                            DECODE(activity_bucket,'UNED_TAX', acctd_amount, 0)),
                   DECODE(activity_bucket,'UNED_TAX', acctd_amount, 0)
                 ) ELMT_uned_TAX_PRO_ACCTD_AMT,
           0 ELMT_uned_CHRG_PRO_AMT,
           0 ELMT_uned_CHRG_PRO_ACCTD_AMT,
           --Amount to be allocated
           0 buc_uned_alloc_amt,
           0 buc_uned_alloc_acctd_amt,
           0 buc_uned_frt_alloc_amt,
           0 buc_uned_frt_alloc_acctd_amt,
           SUM(DECODE(activity_bucket,'UNED_LINE', amount,
                             'UNED_CHRG', amount,
                             'UNED_FRT' , amount,0))
                OVER (PARTITION BY tax_link_id ) buc_uned_tax_alloc_amt,  --Allocation ED on Tax by the rev ed
           SUM(DECODE(activity_bucket,'UNED_LINE', acctd_amount,
                             'UNED_CHRG', acctd_amount,
                             'UNED_FRT' , acctd_amount,0))
                OVER (PARTITION BY tax_link_id ) buc_uned_tax_alloc_acctd_amt,
           0 buc_uned_chrg_alloc_amt,
           0 buc_uned_chrg_alloc_acctd_amt,
           --Currencies
         p_ae_sys_rec.base_currency           BASE_CURRENCY  ,
         g_cust_inv_rec.invoice_currency_code TO_CURRENCY    ,
         ''          FROM_CURRENCY  ,   --Not usefull in this case as taxable is not calculated with from currency
           -- Rowid
           rowid
     FROM  AR_LINE_APP_DETAIL_GT
    WHERE gt_id  = p_gt_id
      AND ref_customer_trx_id = p_customer_trx_id
      AND tax_link_id         IS NOT NULL
      AND DECODE(ref_account_class,'REV'    ,tax_inc_flag,
                           'FREIGHT',tax_inc_flag,
                           'TAX','Y','N')  = 'Y');
--      AND se_gt_id  = g_se_gt_id
--     ORDER BY line_type||'-'||ref_customer_trx_id||'-'||ref_customer_trx_line_id;

  l_tab  pro_res_tbl_type;

  l_group_tbl            group_tbl_type;
  l_group                VARCHAR2(60)    := 'NOGROUP';

-- ADJ and APP
  l_run_amt              NUMBER          := 0;
  l_run_alloc            NUMBER          := 0;
  l_run_acctd_amt        NUMBER          := 0;
  l_run_acctd_alloc      NUMBER          := 0;
  l_alloc                NUMBER          := 0;
  l_acctd_alloc          NUMBER          := 0;

  l_run_chrg_amt         NUMBER          := 0;
  l_run_chrg_alloc       NUMBER          := 0;
  l_run_chrg_acctd_amt   NUMBER          := 0;
  l_run_chrg_acctd_alloc NUMBER          := 0;
  l_chrg_alloc           NUMBER          := 0;
  l_chrg_acctd_alloc     NUMBER          := 0;

  l_run_frt_amt         NUMBER          := 0;
  l_run_frt_alloc       NUMBER          := 0;
  l_run_frt_acctd_amt   NUMBER          := 0;
  l_run_frt_acctd_alloc NUMBER          := 0;
  l_frt_alloc           NUMBER          := 0;
  l_frt_acctd_alloc     NUMBER          := 0;

  l_run_tax_amt         NUMBER          := 0;
  l_run_tax_alloc       NUMBER          := 0;
  l_run_tax_acctd_amt   NUMBER          := 0;
  l_run_tax_acctd_alloc NUMBER          := 0;
  l_tax_alloc           NUMBER          := 0;
  l_tax_acctd_alloc     NUMBER          := 0;

-- ED
  l_run_ed_amt              NUMBER          := 0;
  l_run_ed_alloc            NUMBER          := 0;
  l_run_ed_acctd_amt        NUMBER          := 0;
  l_run_ed_acctd_alloc      NUMBER          := 0;
  l_ed_alloc                NUMBER          := 0;
  l_ed_acctd_alloc          NUMBER          := 0;

  l_run_ed_chrg_amt         NUMBER          := 0;
  l_run_ed_chrg_alloc       NUMBER          := 0;
  l_run_ed_chrg_acctd_amt   NUMBER          := 0;
  l_run_ed_chrg_acctd_alloc NUMBER          := 0;
  l_ed_chrg_alloc           NUMBER          := 0;
  l_ed_chrg_acctd_alloc     NUMBER          := 0;

  l_run_ed_frt_amt         NUMBER          := 0;
  l_run_ed_frt_alloc       NUMBER          := 0;
  l_run_ed_frt_acctd_amt   NUMBER          := 0;
  l_run_ed_frt_acctd_alloc NUMBER          := 0;
  l_ed_frt_alloc           NUMBER          := 0;
  l_ed_frt_acctd_alloc     NUMBER          := 0;

  l_run_ed_tax_amt         NUMBER          := 0;
  l_run_ed_tax_alloc       NUMBER          := 0;
  l_run_ed_tax_acctd_amt   NUMBER          := 0;
  l_run_ed_tax_acctd_alloc NUMBER          := 0;
  l_ed_tax_alloc           NUMBER          := 0;
  l_ed_tax_acctd_alloc     NUMBER          := 0;

-- UNED
  l_run_uned_amt              NUMBER          := 0;
  l_run_uned_alloc            NUMBER          := 0;
  l_run_uned_acctd_amt        NUMBER          := 0;
  l_run_uned_acctd_alloc      NUMBER          := 0;
  l_uned_alloc                NUMBER          := 0;
  l_uned_acctd_alloc          NUMBER          := 0;

  l_run_uned_chrg_amt         NUMBER          := 0;
  l_run_uned_chrg_alloc       NUMBER          := 0;
  l_run_uned_chrg_acctd_amt   NUMBER          := 0;
  l_run_uned_chrg_acctd_alloc NUMBER          := 0;
  l_uned_chrg_alloc           NUMBER          := 0;
  l_uned_chrg_acctd_alloc     NUMBER          := 0;

  l_run_uned_frt_amt         NUMBER          := 0;
  l_run_uned_frt_alloc       NUMBER          := 0;
  l_run_uned_frt_acctd_amt   NUMBER          := 0;
  l_run_uned_frt_acctd_alloc NUMBER          := 0;
  l_uned_frt_alloc           NUMBER          := 0;
  l_uned_frt_acctd_alloc     NUMBER          := 0;

  l_run_uned_tax_amt         NUMBER          := 0;
  l_run_uned_tax_alloc       NUMBER          := 0;
  l_run_uned_tax_acctd_amt   NUMBER          := 0;
  l_run_uned_tax_acctd_alloc NUMBER          := 0;
  l_uned_tax_alloc           NUMBER          := 0;
  l_uned_tax_acctd_alloc     NUMBER          := 0;

  l_exist                BOOLEAN;
  l_last_fetch           BOOLEAN;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_tax()+');
  localdebug('   p_ae_sys_rec.set_of_books_id');
  localdebug('   p_ae_sys_rec.sob_type');
  END IF;
  OPEN  c_read_for_taxable;
  LOOP
    FETCH c_read_for_taxable BULK COLLECT INTO
     l_tab.GROUPE                  ,
  -- ADJ and APP
     -- Base
     l_tab.base_pro_amt       ,
     l_tab.base_pro_acctd_amt ,
     l_tab.BASE_FRT_PRO_AMT       ,
     l_tab.BASE_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_TAX_PRO_AMT       ,
     l_tab.BASE_TAX_PRO_ACCTD_AMT ,
     l_tab.BASE_CHRG_PRO_AMT       ,
     l_tab.BASE_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_pro_amt       ,
     l_tab.elmt_pro_acctd_amt ,
     l_tab.ELMT_FRT_PRO_AMT       ,
     l_tab.ELMT_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_TAX_PRO_AMT       ,
     l_tab.ELMT_TAX_PRO_ACCTD_AMT ,
     l_tab.ELMT_CHRG_PRO_AMT       ,
     l_tab.ELMT_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_alloc_amt      ,
     l_tab.buc_alloc_acctd_amt,
     l_tab.buc_frt_alloc_amt      ,
     l_tab.buc_frt_alloc_acctd_amt,
     l_tab.buc_tax_alloc_amt      ,
     l_tab.buc_tax_alloc_acctd_amt,
     l_tab.buc_chrg_alloc_amt      ,
     l_tab.buc_chrg_alloc_acctd_amt,
  -- ED
     -- Base
     l_tab.base_ed_pro_amt       ,
     l_tab.base_ed_pro_acctd_amt ,
     l_tab.BASE_ed_FRT_PRO_AMT       ,
     l_tab.BASE_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_TAX_PRO_AMT       ,
     l_tab.BASE_ed_TAX_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_CHRG_PRO_AMT       ,
     l_tab.BASE_ed_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_ed_pro_amt       ,
     l_tab.elmt_ed_pro_acctd_amt ,
     l_tab.ELMT_ed_FRT_PRO_AMT       ,
     l_tab.ELMT_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_TAX_PRO_AMT       ,
     l_tab.ELMT_ed_TAX_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_CHRG_PRO_AMT       ,
     l_tab.ELMT_ed_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_ed_alloc_amt      ,
     l_tab.buc_ed_alloc_acctd_amt,
     l_tab.buc_ed_frt_alloc_amt      ,
     l_tab.buc_ed_frt_alloc_acctd_amt,
     l_tab.buc_ed_tax_alloc_amt      ,
     l_tab.buc_ed_tax_alloc_acctd_amt,
     l_tab.buc_ed_chrg_alloc_amt      ,
     l_tab.buc_ed_chrg_alloc_acctd_amt,
  -- UNED
     -- Base
     l_tab.base_uned_pro_amt       ,
     l_tab.base_uned_pro_acctd_amt ,
     l_tab.BASE_uned_FRT_PRO_AMT       ,
     l_tab.BASE_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_TAX_PRO_AMT       ,
     l_tab.BASE_uned_TAX_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_CHRG_PRO_AMT       ,
     l_tab.BASE_uned_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_uned_pro_amt       ,
     l_tab.elmt_uned_pro_acctd_amt ,
     l_tab.ELMT_uned_FRT_PRO_AMT       ,
     l_tab.ELMT_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_TAX_PRO_AMT       ,
     l_tab.ELMT_uned_TAX_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_CHRG_PRO_AMT       ,
     l_tab.ELMT_uned_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_uned_alloc_amt      ,
     l_tab.buc_uned_alloc_acctd_amt,
     l_tab.buc_uned_frt_alloc_amt      ,
     l_tab.buc_uned_frt_alloc_acctd_amt,
     l_tab.buc_uned_tax_alloc_amt      ,
     l_tab.buc_uned_tax_alloc_acctd_amt,
     l_tab.buc_uned_chrg_alloc_amt      ,
     l_tab.buc_uned_chrg_alloc_acctd_amt,
     --
     l_tab.BASE_CURRENCY  ,
     l_tab.TO_CURRENCY    ,
     l_tab.FROM_CURRENCY  ,
     --
     l_tab.ROWID_ID     LIMIT g_bulk_fetch_rows;

     IF c_read_for_taxable%NOTFOUND THEN
          l_last_fetch := TRUE;
     END IF;

     IF (l_tab.ROWID_ID.COUNT = 0) AND (l_last_fetch) THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug('COUNT = 0 and LAST FETCH ');
       END IF;
       EXIT;
     END IF;

     plsql_proration( x_tab               => l_tab,
                   x_group_tbl            => l_group_tbl,
                 -- ADJ and APP
                   x_run_amt              => l_run_amt,
                   x_run_alloc            => l_run_alloc,
                   x_run_acctd_amt        => l_run_acctd_amt,
                   x_run_acctd_alloc      => l_run_acctd_alloc,
                   x_run_chrg_amt         => l_run_chrg_amt,
                   x_run_chrg_alloc       => l_run_chrg_alloc,
                   x_run_chrg_acctd_amt   => l_run_chrg_acctd_amt,
                   x_run_chrg_acctd_alloc => l_run_chrg_acctd_alloc,
                   x_run_frt_amt         => l_run_frt_amt,
                   x_run_frt_alloc       => l_run_frt_alloc,
                   x_run_frt_acctd_amt   => l_run_frt_acctd_amt,
                   x_run_frt_acctd_alloc => l_run_frt_acctd_alloc,
                   x_run_tax_amt         => l_run_tax_amt,
                   x_run_tax_alloc       => l_run_tax_alloc,
                   x_run_tax_acctd_amt   => l_run_tax_acctd_amt,
                   x_run_tax_acctd_alloc => l_run_tax_acctd_alloc,
                 -- ED
                   x_run_ed_amt              => l_run_ed_amt,
                   x_run_ed_alloc            => l_run_ed_alloc,
                   x_run_ed_acctd_amt        => l_run_ed_acctd_amt,
                   x_run_ed_acctd_alloc      => l_run_ed_acctd_alloc,
                   x_run_ed_chrg_amt         => l_run_ed_chrg_amt,
                   x_run_ed_chrg_alloc       => l_run_ed_chrg_alloc,
                   x_run_ed_chrg_acctd_amt   => l_run_ed_chrg_acctd_amt,
                   x_run_ed_chrg_acctd_alloc => l_run_ed_chrg_acctd_alloc,
                   x_run_ed_frt_amt         => l_run_ed_frt_amt,
                   x_run_ed_frt_alloc       => l_run_ed_frt_alloc,
                   x_run_ed_frt_acctd_amt   => l_run_ed_frt_acctd_amt,
                   x_run_ed_frt_acctd_alloc => l_run_ed_frt_acctd_alloc,
                   x_run_ed_tax_amt         => l_run_ed_tax_amt,
                   x_run_ed_tax_alloc       => l_run_ed_tax_alloc,
                   x_run_ed_tax_acctd_amt   => l_run_ed_tax_acctd_amt,
                   x_run_ed_tax_acctd_alloc => l_run_ed_tax_acctd_alloc,
                 -- UNED
                   x_run_uned_amt              => l_run_uned_amt,
                   x_run_uned_alloc            => l_run_uned_alloc,
                   x_run_uned_acctd_amt        => l_run_uned_acctd_amt,
                   x_run_uned_acctd_alloc      => l_run_uned_acctd_alloc,
                   x_run_uned_chrg_amt         => l_run_uned_chrg_amt,
                   x_run_uned_chrg_alloc       => l_run_uned_chrg_alloc,
                   x_run_uned_chrg_acctd_amt   => l_run_uned_chrg_acctd_amt,
                   x_run_uned_chrg_acctd_alloc => l_run_uned_chrg_acctd_alloc,
                   x_run_uned_frt_amt         => l_run_uned_frt_amt,
                   x_run_uned_frt_alloc       => l_run_uned_frt_alloc,
                   x_run_uned_frt_acctd_amt   => l_run_uned_frt_acctd_amt,
                   x_run_uned_frt_acctd_alloc => l_run_uned_frt_acctd_alloc,
                   x_run_uned_tax_amt         => l_run_uned_tax_amt,
                   x_run_uned_tax_alloc       => l_run_uned_tax_alloc,
                   x_run_uned_tax_acctd_amt   => l_run_uned_tax_acctd_amt,
                   x_run_uned_tax_acctd_alloc => l_run_uned_tax_acctd_alloc);

    FORALL i IN l_tab.ROWID_ID.FIRST .. l_tab.ROWID_ID.LAST
    UPDATE AR_LINE_APP_DETAIL_GT
       SET taxable_amount  =       DECODE(activity_bucket, 'APP_TAX', l_tab.tl_tax_alloc_amt(i),
                                                  'ADJ_TAX', l_tab.tl_tax_alloc_amt(i),
                                                  'ED_TAX', l_tab.tl_ed_tax_alloc_amt(i),
                                                  'UNED_TAX', l_tab.tl_uned_tax_alloc_amt(i)),
           taxable_acctd_amount =  DECODE(activity_bucket, 'APP_TAX', l_tab.tl_tax_alloc_acctd_amt(i),
                                                  'ADJ_TAX', l_tab.tl_tax_alloc_acctd_amt(i),
                                                  'ED_TAX', l_tab.tl_ed_tax_alloc_acctd_amt(i),
                                                  'UNED_TAX', l_tab.tl_uned_tax_alloc_acctd_amt(i))
     WHERE rowid                     = l_tab.ROWID_ID(i);
  END LOOP;
  CLOSE c_read_for_taxable;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_taxable()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('  EXCEPTION OTHERS update_taxable :'||SQLERRM);
    END IF;
END update_taxable;


PROCEDURE update_for_mrc_dist
(p_gt_id           IN VARCHAR2,
 p_customer_trx_id IN NUMBER,
 p_app_rec         IN ar_receivable_applications%ROWTYPE,
 p_adj_rec         IN ar_adjustments%ROWTYPE,
 p_ae_sys_rec      IN arp_acct_main.ae_sys_rec_type)
IS
  CURSOR c_mrc(p_acctd_adj_app_to IN NUMBER,
               p_acctd_app_from   IN NUMBER,
               p_acctd_ed         IN NUMBER,
               p_acctd_uned       IN NUMBER,
               p_from_curr_code   IN VARCHAR2)
  IS
    SELECT /*+INDEX (AR_LINE_APP_DETAIL_GT AR_LINE_APP_DETAIL_GT_N1)*/
	        DECODE(activity_bucket, 'ADJ_LINE', 'ADJ',
                          'ADJ_TAX' , 'ADJ',
                          'ADJ_FRT' , 'ADJ',
                          'ADJ_CHRG', 'ADJ',
                          'APP_LINE', 'APP',
                          'APP_TAX' , 'APP',
                          'APP_FRT' , 'APP',
                          'APP_CHRG', 'APP',
                          'ED_LINE' , 'ED',
                          'ED_TAX'  , 'ED',
                          'ED_FRT'  , 'ED',
                          'UNED_CHRG' , 'UNED',
                          'UNED_LINE' , 'UNED',
                          'UNED_TAX'  , 'UNED',
                          'UNED_FRT'  , 'UNED',
                          'UNED_CHRG' , 'UNED')    groupe,
        /* ADJ and APP */
         --BASE
           --Base for acctd_amount MRC
           0,
           SUM(DECODE(activity_bucket,'APP_LINE',amount,
                             'APP_TAX' ,amount,
                             'APP_FRT' ,amount,
                             'APP_CHRG',amount,
                             'ADJ_LINE',amount,
                             'ADJ_TAX' ,amount,
                             'ADJ_FRT' ,amount,
                             'ADJ_CHRG',amount,0)),
           --Base used for MRC
           0,
           0,
           --Base used for MRC from_acctd_amount
           0,
           SUM(DECODE(activity_bucket,'APP_LINE',amount,
                             'APP_TAX' ,amount,
                             'APP_FRT' ,amount,
                             'APP_CHRG',amount,0)),
           --Base not used in MRC
           0,
           0,
         --ELEMENT
           --Element for APP/ADJ acctd_amount MRC
           0,
           DECODE(activity_bucket,'APP_LINE',amount,
                         'APP_TAX' ,amount,
                         'APP_FRT' ,amount,
                         'APP_CHRG',amount,
                         'ADJ_LINE',amount,
                         'ADJ_TAX' ,amount,
                         'ADJ_FRT' ,amount,
                         'ADJ_CHRG',amount,0),
           --Element not used in MRC
           0,
           0,
           --Element used for MRC from_acctd_amount
           0,
           DECODE(activity_bucket,'APP_LINE',amount,
                         'APP_TAX' ,amount,
                         'APP_FRT' ,amount,
                         'APP_CHRG',amount,0),
           --Element not used
           0,
           0,
        --AMOUNT TO ALLOCATED
          --bucket MRC allocated the acctd_amount
           0,
           p_acctd_adj_app_to,
          --bucket not used
           0,
           0,
          --bucket used allocated the from_acctd_amount
           0,
           p_acctd_app_from,
          --bucket not used MRC
           0,
           0,
        /* ED */
        --BASE
           --Base for acctd_amount MRC
           0,
           SUM(DECODE(activity_bucket,'ED_LINE',amount,
                             'ED_TAX' ,amount,
                             'ED_FRT' ,amount,
                             'ED_CHRG',amount,0)),
           --Base not used
           0,
           0,
           --Base for from_acctd_amount - Not applicable for ED
           0,
           0,
           --Base not used
           0,
           0,
        --ELEMENT
           --Element for acctd_amount
           0,
           DECODE(activity_bucket,'ED_LINE',amount,
                         'ED_TAX' ,amount,
                         'ED_FRT' ,amount,
                         'ED_CHRG',amount,0),
           --Element not used
           0,
           0,
           --Element used for from_acctd_amount - Not applicable for discount
           0,
           0,
           --Element not used
           0,
           0,
        --AMOUNT TO BE ALLOCATED
          --bucket for acctd_amount MRC
           0,
           p_acctd_ed,
          --bucket not used
           0,
           0,
          --bucket not used - Note:from_acctd_amount not applicable for discount
           0,
           0,
          --bucket not used
           0,
           0,
        /* UNED */
         --BASE
           --Base for acctd_amount MRC
           0,
           SUM(DECODE(activity_bucket,'UNED_LINE',amount,
                             'UNED_TAX' ,amount,
                             'UNED_FRT' ,amount,
                             'UNED_CHRG',amount,0)),
           --Base not used
           0,
           0,
           --Base not used
           0,
           0,
           --Base not used
           0,
           0,
        --ELEMENT
           --Element for acctd_amount MRC
           0,
           DECODE(activity_bucket,'UNED_LINE',amount,
                         'UNED_TAX' ,amount,
                         'UNED_FRT' ,amount,
                         'UNED_CHRG',amount,0),
           --Element not used
           0,
           0,
           --Element not used
           0,
           0,
           --Element not used
           0,
           0,
        --AMOUNT TO BE ALLOCATED
           --Bucket for acctd_amount
           0,
           p_acctd_uned,
           --Bucket not used
           0,
           0,
           --Bucket not used
           0,
           0,
           --Bucket not used
           0,
           0,
           --Currencies
           p_ae_sys_rec.base_currency           BASE_CURRENCY  ,
           g_cust_inv_rec.invoice_currency_code TO_CURRENCY    ,
         --HYU
           p_from_curr_code                     FROM_CURRENCY,
           -- Rowid
           rowid
     FROM  AR_LINE_APP_DETAIL_GT
    WHERE gt_id  = p_gt_id
      AND ref_customer_trx_id = p_customer_trx_id
    ORDER BY DECODE(activity_bucket,  'ADJ_LINE', 'ADJ',
                          'ADJ_TAX' , 'ADJ',
                          'ADJ_FRT' , 'ADJ',
                          'ADJ_CHRG', 'ADJ',
                          'APP_LINE', 'APP',
                          'APP_TAX' , 'APP',
                          'APP_FRT' , 'APP',
                          'APP_CHRG', 'APP',
                          'ED_LINE' , 'ED',
                          'ED_TAX'  , 'ED',
                          'ED_FRT'  , 'ED',
                          'UNED_CHRG' , 'UNED',
                          'UNED_LINE' , 'UNED',
                          'UNED_TAX'  , 'UNED',
                          'UNED_FRT'  , 'UNED',
                          'UNED_CHRG' , 'UNED');

  l_tab  pro_res_tbl_type;

  l_group_tbl            group_tbl_type;
  l_group                VARCHAR2(900)    := 'NOGROUP';

  -- ADJ and APP
  l_run_amt              NUMBER          := 0;
  l_run_alloc            NUMBER          := 0;
  l_run_acctd_amt        NUMBER          := 0;
  l_run_acctd_alloc      NUMBER          := 0;
  l_alloc                NUMBER          := 0;
  l_acctd_alloc          NUMBER          := 0;

  l_run_chrg_amt         NUMBER          := 0;
  l_run_chrg_alloc       NUMBER          := 0;
  l_run_chrg_acctd_amt   NUMBER          := 0;
  l_run_chrg_acctd_alloc NUMBER          := 0;
  l_chrg_alloc           NUMBER          := 0;
  l_chrg_acctd_alloc     NUMBER          := 0;

  l_run_frt_amt         NUMBER          := 0;
  l_run_frt_alloc       NUMBER          := 0;
  l_run_frt_acctd_amt   NUMBER          := 0;
  l_run_frt_acctd_alloc NUMBER          := 0;
  l_frt_alloc           NUMBER          := 0;
  l_frt_acctd_alloc     NUMBER          := 0;

  l_run_tax_amt         NUMBER          := 0;
  l_run_tax_alloc       NUMBER          := 0;
  l_run_tax_acctd_amt   NUMBER          := 0;
  l_run_tax_acctd_alloc NUMBER          := 0;
  l_tax_alloc           NUMBER          := 0;
  l_tax_acctd_alloc     NUMBER          := 0;


  -- ED
  l_run_ed_amt              NUMBER          := 0;
  l_run_ed_alloc            NUMBER          := 0;
  l_run_ed_acctd_amt        NUMBER          := 0;
  l_run_ed_acctd_alloc      NUMBER          := 0;
  l_ed_alloc                NUMBER          := 0;
  l_ed_acctd_alloc          NUMBER          := 0;

  l_run_ed_chrg_amt         NUMBER          := 0;
  l_run_ed_chrg_alloc       NUMBER          := 0;
  l_run_ed_chrg_acctd_amt   NUMBER          := 0;
  l_run_ed_chrg_acctd_alloc NUMBER          := 0;
  l_ed_chrg_alloc           NUMBER          := 0;
  l_ed_chrg_acctd_alloc     NUMBER          := 0;

  l_run_ed_frt_amt         NUMBER          := 0;
  l_run_ed_frt_alloc       NUMBER          := 0;
  l_run_ed_frt_acctd_amt   NUMBER          := 0;
  l_run_ed_frt_acctd_alloc NUMBER          := 0;
  l_ed_frt_alloc           NUMBER          := 0;
  l_ed_frt_acctd_alloc     NUMBER          := 0;

  l_run_ed_tax_amt         NUMBER          := 0;
  l_run_ed_tax_alloc       NUMBER          := 0;
  l_run_ed_tax_acctd_amt   NUMBER          := 0;
  l_run_ed_tax_acctd_alloc NUMBER          := 0;
  l_ed_tax_alloc           NUMBER          := 0;
  l_ed_tax_acctd_alloc     NUMBER          := 0;

  -- UNED
  l_run_uned_amt              NUMBER          := 0;
  l_run_uned_alloc            NUMBER          := 0;
  l_run_uned_acctd_amt        NUMBER          := 0;
  l_run_uned_acctd_alloc      NUMBER          := 0;
  l_uned_alloc                NUMBER          := 0;
  l_uned_acctd_alloc          NUMBER          := 0;

  l_run_uned_chrg_amt         NUMBER          := 0;
  l_run_uned_chrg_alloc       NUMBER          := 0;
  l_run_uned_chrg_acctd_amt   NUMBER          := 0;
  l_run_uned_chrg_acctd_alloc NUMBER          := 0;
  l_uned_chrg_alloc           NUMBER          := 0;
  l_uned_chrg_acctd_alloc     NUMBER          := 0;

  l_run_uned_frt_amt         NUMBER          := 0;
  l_run_uned_frt_alloc       NUMBER          := 0;
  l_run_uned_frt_acctd_amt   NUMBER          := 0;
  l_run_uned_frt_acctd_alloc NUMBER          := 0;
  l_uned_frt_alloc           NUMBER          := 0;
  l_uned_frt_acctd_alloc     NUMBER          := 0;

  l_run_uned_tax_amt         NUMBER          := 0;
  l_run_uned_tax_alloc       NUMBER          := 0;
  l_run_uned_tax_acctd_amt   NUMBER          := 0;
  l_run_uned_tax_acctd_alloc NUMBER          := 0;
  l_uned_tax_alloc           NUMBER          := 0;
  l_uned_tax_acctd_alloc     NUMBER          := 0;

  l_exist                BOOLEAN;
  l_last_fetch           BOOLEAN;

  l_acctd_adj_app_to     NUMBER;
  l_acctd_app_from       NUMBER;
  l_acctd_ed             NUMBER;
  l_acctd_uned           NUMBER;
  l_from_curr_code       VARCHAR2(30);

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_mrc_for_dist()+');
  END IF;

  IF p_app_rec.receivable_application_id IS NOT NULL THEN
    l_acctd_adj_app_to:=   NVL(p_app_rec.acctd_amount_applied_to,0) * -1;
    l_acctd_app_from  :=   NVL(p_app_rec.acctd_amount_applied_from,0) * -1;
    l_acctd_ed        :=   NVL(p_app_rec.acctd_earned_discount_taken,0) * -1;
    l_acctd_uned      :=   NVL(p_app_rec.acctd_unearned_discount_taken,0) * -1;
  ELSIF p_adj_rec.adjustment_id IS NOT NULL THEN
    l_acctd_adj_app_to:=   NVL(p_adj_rec.acctd_amount,0);
    l_acctd_app_from  :=   0;
    l_acctd_ed        :=   0;
    l_acctd_uned      :=   0;
  END IF;

  IF p_app_rec.receivable_application_id IS NOT NULL THEN
     get_from_currency(p_app_rec          => p_app_rec,
                       x_from_curr_code   => l_from_curr_code);

     IF PG_DEBUG = 'Y' THEN
     localdebug(' l_from_curr_code :'||l_from_curr_code);
     END IF;
  END IF;

  IF l_from_curr_code IS NULL THEN
     l_from_curr_code := p_ae_sys_rec.base_currency;
  END IF;

  OPEN  c_mrc(p_acctd_adj_app_to =>l_acctd_adj_app_to,
              p_acctd_app_from   =>l_acctd_app_from  ,
              p_acctd_ed         =>l_acctd_ed  ,
              p_acctd_uned       =>l_acctd_uned ,
              p_from_curr_code   =>l_from_curr_code);
  LOOP
    FETCH c_mrc BULK COLLECT INTO
     l_tab.GROUPE                  ,
   -- ADJ and APP
     -- Base
     l_tab.base_pro_amt       ,
     l_tab.base_pro_acctd_amt ,
     l_tab.BASE_FRT_PRO_AMT       ,
     l_tab.BASE_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_tax_PRO_AMT       ,
     l_tab.BASE_tax_PRO_ACCTD_AMT ,
     l_tab.BASE_CHRG_PRO_AMT       ,
     l_tab.BASE_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_pro_amt       ,
     l_tab.elmt_pro_acctd_amt ,
     l_tab.ELMT_FRT_PRO_AMT       ,
     l_tab.ELMT_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_tax_PRO_AMT       ,
     l_tab.ELMT_tax_PRO_ACCTD_AMT ,
     l_tab.ELMT_CHRG_PRO_AMT       ,
     l_tab.ELMT_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_alloc_amt      ,
     l_tab.buc_alloc_acctd_amt,
     l_tab.buc_frt_alloc_amt      ,
     l_tab.buc_frt_alloc_acctd_amt,
     l_tab.buc_tax_alloc_amt      ,
     l_tab.buc_tax_alloc_acctd_amt,
     l_tab.buc_chrg_alloc_amt      ,
     l_tab.buc_chrg_alloc_acctd_amt,
   -- ED
     -- Base
     l_tab.base_ed_pro_amt       ,
     l_tab.base_ed_pro_acctd_amt ,
     l_tab.BASE_ed_FRT_PRO_AMT       ,
     l_tab.BASE_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_tax_PRO_AMT       ,
     l_tab.BASE_ed_tax_PRO_ACCTD_AMT ,
     l_tab.BASE_ed_CHRG_PRO_AMT       ,
     l_tab.BASE_ed_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_ed_pro_amt       ,
     l_tab.elmt_ed_pro_acctd_amt ,
     l_tab.ELMT_ed_FRT_PRO_AMT       ,
     l_tab.ELMT_ed_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_tax_PRO_AMT       ,
     l_tab.ELMT_ed_tax_PRO_ACCTD_AMT ,
     l_tab.ELMT_ed_CHRG_PRO_AMT       ,
     l_tab.ELMT_ed_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_ed_alloc_amt      ,
     l_tab.buc_ed_alloc_acctd_amt,
     l_tab.buc_ed_frt_alloc_amt      ,
     l_tab.buc_ed_frt_alloc_acctd_amt,
     l_tab.buc_ed_tax_alloc_amt      ,
     l_tab.buc_ed_tax_alloc_acctd_amt,
     l_tab.buc_ed_chrg_alloc_amt      ,
     l_tab.buc_ed_chrg_alloc_acctd_amt,
   -- UNED
     -- Base
     l_tab.base_uned_pro_amt       ,
     l_tab.base_uned_pro_acctd_amt ,
     l_tab.BASE_uned_FRT_PRO_AMT       ,
     l_tab.BASE_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_tax_PRO_AMT       ,
     l_tab.BASE_uned_tax_PRO_ACCTD_AMT ,
     l_tab.BASE_uned_CHRG_PRO_AMT       ,
     l_tab.BASE_uned_CHRG_PRO_ACCTD_AMT ,
     -- Element numerator
     l_tab.elmt_uned_pro_amt       ,
     l_tab.elmt_uned_pro_acctd_amt ,
     l_tab.ELMT_uned_FRT_PRO_AMT       ,
     l_tab.ELMT_uned_FRT_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_tax_PRO_AMT       ,
     l_tab.ELMT_uned_tax_PRO_ACCTD_AMT ,
     l_tab.ELMT_uned_CHRG_PRO_AMT       ,
     l_tab.ELMT_uned_CHRG_PRO_ACCTD_AMT ,
     -- Amount to be allocated
     l_tab.buc_uned_alloc_amt      ,
     l_tab.buc_uned_alloc_acctd_amt,
     l_tab.buc_uned_frt_alloc_amt      ,
     l_tab.buc_uned_frt_alloc_acctd_amt,
     l_tab.buc_uned_tax_alloc_amt      ,
     l_tab.buc_uned_tax_alloc_acctd_amt,
     l_tab.buc_uned_chrg_alloc_amt      ,
     l_tab.buc_uned_chrg_alloc_acctd_amt,
     --
     l_tab.BASE_CURRENCY  ,
     l_tab.TO_CURRENCY    ,
     l_tab.FROM_CURRENCY  ,
     --
     l_tab.ROWID_ID     LIMIT g_bulk_fetch_rows;

     IF c_mrc%NOTFOUND THEN
          l_last_fetch := TRUE;
     END IF;

     IF (l_tab.ROWID_ID.COUNT = 0) AND (l_last_fetch) THEN
       IF PG_DEBUG = 'Y' THEN
       localdebug('COUNT = 0 and LAST FETCH ');
       END IF;
       EXIT;
     END IF;

     plsql_proration( x_tab               => l_tab,
                   x_group_tbl            => l_group_tbl,
                   -- ADJ and APP
                   x_run_amt              => l_run_amt,
                   x_run_alloc            => l_run_alloc,
                   x_run_acctd_amt        => l_run_acctd_amt,
                   x_run_acctd_alloc      => l_run_acctd_alloc,
                   x_run_chrg_amt         => l_run_chrg_amt,
                   x_run_chrg_alloc       => l_run_chrg_alloc,
                   x_run_chrg_acctd_amt   => l_run_chrg_acctd_amt,
                   x_run_chrg_acctd_alloc => l_run_chrg_acctd_alloc,
                   x_run_frt_amt         => l_run_frt_amt,
                   x_run_frt_alloc       => l_run_frt_alloc,
                   x_run_frt_acctd_amt   => l_run_frt_acctd_amt,
                   x_run_frt_acctd_alloc => l_run_frt_acctd_alloc,
                   x_run_tax_amt         => l_run_tax_amt,
                   x_run_tax_alloc       => l_run_tax_alloc,
                   x_run_tax_acctd_amt   => l_run_tax_acctd_amt,
                   x_run_tax_acctd_alloc => l_run_tax_acctd_alloc,
                   -- ED
                   x_run_ed_amt              => l_run_ed_amt,
                   x_run_ed_alloc            => l_run_ed_alloc,
                   x_run_ed_acctd_amt        => l_run_ed_acctd_amt,
                   x_run_ed_acctd_alloc      => l_run_ed_acctd_alloc,
                   x_run_ed_chrg_amt         => l_run_ed_chrg_amt,
                   x_run_ed_chrg_alloc       => l_run_ed_chrg_alloc,
                   x_run_ed_chrg_acctd_amt   => l_run_ed_chrg_acctd_amt,
                   x_run_ed_chrg_acctd_alloc => l_run_ed_chrg_acctd_alloc,
                   x_run_ed_frt_amt         => l_run_ed_frt_amt,
                   x_run_ed_frt_alloc       => l_run_ed_frt_alloc,
                   x_run_ed_frt_acctd_amt   => l_run_ed_frt_acctd_amt,
                   x_run_ed_frt_acctd_alloc => l_run_ed_frt_acctd_alloc,
                   x_run_ed_tax_amt         => l_run_ed_tax_amt,
                   x_run_ed_tax_alloc       => l_run_ed_tax_alloc,
                   x_run_ed_tax_acctd_amt   => l_run_ed_tax_acctd_amt,
                   x_run_ed_tax_acctd_alloc => l_run_ed_tax_acctd_alloc,
                   -- UNED
                   x_run_uned_amt              => l_run_uned_amt,
                   x_run_uned_alloc            => l_run_uned_alloc,
                   x_run_uned_acctd_amt        => l_run_uned_acctd_amt,
                   x_run_uned_acctd_alloc      => l_run_uned_acctd_alloc,
                   x_run_uned_chrg_amt         => l_run_uned_chrg_amt,
                   x_run_uned_chrg_alloc       => l_run_uned_chrg_alloc,
                   x_run_uned_chrg_acctd_amt   => l_run_uned_chrg_acctd_amt,
                   x_run_uned_chrg_acctd_alloc => l_run_uned_chrg_acctd_alloc,
                   x_run_uned_frt_amt         => l_run_uned_frt_amt,
                   x_run_uned_frt_alloc       => l_run_uned_frt_alloc,
                   x_run_uned_frt_acctd_amt   => l_run_uned_frt_acctd_amt,
                   x_run_uned_frt_acctd_alloc => l_run_uned_frt_acctd_alloc,
                   x_run_uned_tax_amt         => l_run_uned_tax_amt,
                   x_run_uned_tax_alloc       => l_run_uned_tax_alloc,
                   x_run_uned_tax_acctd_amt   => l_run_uned_tax_acctd_amt,
                   x_run_uned_tax_acctd_alloc => l_run_uned_tax_acctd_alloc
                   );

    IF PG_DEBUG = 'Y' THEN
    localdebug('     update AR_LINE_APP_DETAIL_GT  RSOB:'||p_ae_sys_rec.set_of_books_id);
    END IF;
    FORALL i IN l_tab.ROWID_ID.FIRST .. l_tab.ROWID_ID.LAST
      UPDATE AR_LINE_APP_DETAIL_GT a
      SET  ACCTD_AMOUNT      = DECODE(a.activity_bucket, 'APP_LINE', l_tab.tl_alloc_acctd_amt(i),
                                                'APP_TAX' , l_tab.tl_alloc_acctd_amt(i),
                                                'APP_FRT' , l_tab.tl_alloc_acctd_amt(i),
                                                'APP_CHRG', l_tab.tl_alloc_acctd_amt(i),
                                                'ADJ_LINE', l_tab.tl_alloc_acctd_amt(i),
                                                'ADJ_TAX' , l_tab.tl_alloc_acctd_amt(i),
                                                'ADJ_FRT' , l_tab.tl_alloc_acctd_amt(i),
                                                'ADJ_CHRG', l_tab.tl_alloc_acctd_amt(i),
                                                'ED_LINE', l_tab.tl_ed_alloc_acctd_amt(i),
                                                'ED_TAX' , l_tab.tl_ed_alloc_acctd_amt(i),
                                                'ED_FRT' , l_tab.tl_ed_alloc_acctd_amt(i),
                                                'ED_CHRG', l_tab.tl_ed_alloc_acctd_amt(i),
                                                'UNED_LINE', l_tab.tl_uned_alloc_acctd_amt(i),
                                                'UNED_TAX' , l_tab.tl_uned_alloc_acctd_amt(i),
                                                'UNED_FRT' , l_tab.tl_uned_alloc_acctd_amt(i),
                                                'UNED_CHRG', l_tab.tl_uned_alloc_acctd_amt(i)),
            FROM_ACCTD_AMOUNT= DECODE(a.activity_bucket, 'APP_LINE', l_tab.tl_tax_alloc_acctd_amt(i),
                                                'APP_TAX' , l_tab.tl_tax_alloc_acctd_amt(i),
                                                'APP_FRT' , l_tab.tl_tax_alloc_acctd_amt(i),
                                                'APP_CHRG', l_tab.tl_tax_alloc_acctd_amt(i),
                                                'ADJ_LINE', l_tab.tl_tax_alloc_acctd_amt(i),
                                                'ADJ_TAX' , l_tab.tl_tax_alloc_acctd_amt(i),
                                                'ADJ_FRT' , l_tab.tl_tax_alloc_acctd_amt(i),
                                                'ADJ_CHRG', l_tab.tl_tax_alloc_acctd_amt(i),
                                                'ED_LINE', l_tab.tl_ed_tax_alloc_acctd_amt(i),
                                                'ED_TAX' , l_tab.tl_ed_tax_alloc_acctd_amt(i),
                                                'ED_FRT' , l_tab.tl_ed_tax_alloc_acctd_amt(i),
                                                'ED_CHRG', l_tab.tl_ed_tax_alloc_acctd_amt(i),
                                                'UNED_LINE', l_tab.tl_uned_tax_alloc_acctd_amt(i),
                                                'UNED_TAX' , l_tab.tl_uned_tax_alloc_acctd_amt(i),
                                                'UNED_FRT' , l_tab.tl_uned_tax_alloc_acctd_amt(i),
                                                'UNED_CHRG', l_tab.tl_uned_tax_alloc_acctd_amt(i)),
           ledger_id      = p_ae_sys_rec.set_of_books_id
      WHERE rowid                     = l_tab.ROWID_ID(i);
    IF PG_DEBUG = 'Y' THEN
    localdebug('     update iAR_LINE_APP_DETAIL_GT ');
    END IF;

  END LOOP;
  CLOSE c_mrc;
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.update_for_mrc_dist()-');
  END IF;
END update_for_mrc_dist;


--{For Cash Accrual Lazy update at posting
--
--Function to return next value to use as line_id
--
FUNCTION next_val(p_num IN NUMBER)
RETURN NUMBER
IS
  CURSOR c IS
  SELECT ar_cash_basis_distributions_s.NEXTVAL
    FROM DUAL;
  l_num  NUMBER;
BEGIN
  OPEN c;
  FETCH c INTO l_num;
  CLOSE c;
  RETURN (p_num + l_num);
END;



PROCEDURE insert_ard_gt
(p_gt_id       IN VARCHAR2,
 x_exec_status OUT NOCOPY VARCHAR2)
IS
  CURSOR c1 IS
  SELECT MAX(line_id)
    FROM ar_distributions_all;
  g_num  NUMBER;
  l_rows NUMBER;
BEGIN
  OPEN c1;
  FETCH c1 INTO g_num;
  IF c1%NOTFOUND THEN
    g_num := 0;
  END IF;
  CLOSE c1;

--UPDATE AR_LINE_APP_DETAIL_GT a SET
--(a.DET_ID                         ) =
--(SELECT next_val(g_num)
--   FROM AR_LINE_APP_DETAIL_GT b
--   WHERE a.rowid = b.rowid
--     AND a.gt_id = p_gt_id);
--IF SQL%FOUND THEN
--  x_exec_status := 'Y';
--
-- Keep audit data in ar_cash_basis_distributions
--
-- Note the index unique index 'AR_CASH_BASIS_DISTRIBUTIONS_U2' built on the columns
--RECEIVABLE_APPLICATION_ID
--SOURCE
--SOURCE_ID
--TYPE
--POSTING_CONTROL_ID
--need to be dropped. Because the combination is no longer unique
--  source_id --> adj_id  123
--  type      --> line for the adjustment is revenue on invoice and there are 2 rev line on the inv line 1 and line 2
--  source    --> ADJ
-- For the potion od the adj on line 1 (123, LINE, ADJ)
-- For the potion od the adj on line 2 (123, LINE, ADJ) the same. Therefore not unique
-- Need investigate on perf. part of the code

INSERT INTO ar_cash_basis_dists_all
( CASH_BASIS_DISTRIBUTION_ID
, CREATED_BY
, CREATION_DATE
, LAST_UPDATE_DATE
, LAST_UPDATED_BY
, LAST_UPDATE_LOGIN
, PROGRAM_APPLICATION_ID
, PROGRAM_ID
, PROGRAM_UPDATE_DATE
, RECEIVABLE_APPLICATION_ID
, SOURCE
, SOURCE_ID
, TYPE
, PAYMENT_SCHEDULE_ID
, GL_DATE
, CURRENCY_CODE
, AMOUNT
, ACCTD_AMOUNT
, CODE_COMBINATION_ID
, POSTING_CONTROL_ID
, GL_POSTED_DATE
, RECEIVABLE_APPLICATION_ID_CASH
, ORG_ID
, activity_bucket
, ref_account_class
, ref_customer_trx_id
, ref_customer_trx_line_id
, ref_cust_trx_line_gl_dist_id
, ref_line_id
-- BUG#4396273  removed the not approved columns
, FROM_AMOUNT
, FROM_ACCTD_AMOUNT
, LEDGER_ID
, BASE_CURRENCY
)
SELECT
    ar_distributions_s.NEXTVAL  -- cash_basis_distribution_id
,   lad.CREATED_BY              -- created_by
,   lad.CREATION_DATE           -- creation_date
,   lad.LAST_UPDATE_DATE        -- last_update_date
,   lad.LAST_UPDATED_BY         -- last_updated_by
,   lad.LAST_UPDATE_LOGIN       -- last_update_login
,   222                         -- PROGRAM_APPLICATION_ID
,   77777                       -- PROGRAM_ID  (batch upgrade cash basis at posting)
,   SYSDATE                     -- PROGRAM_UPDATE_DATE
,   lad.SOURCE_ID               -- RECEIVABLE_APPLICATION_ID
,   'RA'             --SOURCE (ADJ or INV)
,   lad.SOURCE_ID    --SOURCE_ID (used to be adj_id or ctlgd_id in 11i
                                                           --for now line_id will be fix with adj_id
,   DECODE(lad.activity_bucket,'ED_LINE','LINE',
                 'ED_TAX', 'TAX',
                 'ED_CHRG','CHARGES',
                 'ED_FRT' ,'FREIGHT',
                 'UNED_LINE','LINE',
                 'UNED_TAX','TAX',
                 'UNED_CHRG','CHARGES',
                 'UNED_FRT','FREIGHT',
                 'ADJ_LINE','LINE',
                 'ADJ_TAX','TAX',
                 'ADJ_CHRG','CHARGES',
                 'ADJ_FRT','FREIGHT',
                 'APP_LINE','LINE',
                 'APP_TAX','TAX',
                 'APP_CHRG','CHARGES',
                 'APP_FRT','FREIGHT')                  -- TYPE (LINE TAX FREIGHT CHARGES)
,   sch.payment_schedule_id     -- PAYMENT_SCHEDULE_ID
,   sch.gl_date                 -- GL_DATE
,   lad.TO_CURRENCY             -- CURRENCY_CODE
,  DECODE(lad.activity_bucket,'ED_LINE',lad.amount,
                 'ED_TAX', lad.amount,
                 'ED_CHRG',lad.amount,
                 'ED_FRT' ,lad.amount,
                 'UNED_LINE',lad.amount,
                 'UNED_TAX',lad.amount,
                 'UNED_CHRG',lad.amount,
                 'UNED_FRT',lad.amount,
                 'ADJ_LINE',lad.amount,
                 'ADJ_TAX',lad.amount,
                 'ADJ_CHRG',lad.amount,
                 'ADJ_FRT',lad.amount,
                 -1*lad.amount)                 --AMOUNT
,  DECODE(lad.activity_bucket,'ED_LINE',lad.acctd_amount,
                 'ED_TAX', lad.acctd_amount,
                 'ED_CHRG',lad.acctd_amount,
                 'ED_FRT' ,lad.acctd_amount,
                 'UNED_LINE',lad.acctd_amount,
                 'UNED_TAX',lad.acctd_amount,
                 'UNED_CHRG',lad.acctd_amount,
                 'UNED_FRT',lad.acctd_amount,
                 'ADJ_LINE',lad.acctd_amount,
                 'ADJ_TAX',lad.acctd_amount,
                 'ADJ_CHRG',lad.acctd_amount,
                 'ADJ_FRT',lad.acctd_amount,
                 -1* lad.acctd_amount)          --ACCTD_AMOUNT
,   lad.CCID                    -- CODE_COMBINATION_ID
,   -9999                       -- POSTING_CONTROL_ID -- We do maintain the posting control id in cash basis dists
                                                      -- to verify if the posting has occured check app pst ctl id
,   SYSDATE                     -- GL_POSTED_DATE  ( need to be reflag at the end by extract)
,   lad.SOURCE_ID               -- RECEIVABLE_APPLICATION_ID_CASH
,   sch.ORG_ID                  -- org_id
,   lad.activity_bucket
,   lad.ref_account_class
,   lad.ref_customer_trx_id
,   lad.ref_customer_trx_line_id
,   lad.ref_cust_trx_line_gl_dist_id
,   lad.ref_line_id
/*                      BUG#4396273 remove not approved columns*/
--HYU Add the From column bach Attention schema changes
, SIGN(DECODE(lad.activity_bucket,'ED_LINE',lad.acctd_amount,
                 'ED_TAX', lad.acctd_amount,
                 'ED_CHRG',lad.acctd_amount,
                 'ED_FRT' ,lad.acctd_amount,
                 'UNED_LINE',lad.acctd_amount,
                 'UNED_TAX',lad.acctd_amount,
                 'UNED_CHRG',lad.acctd_amount,
                 'UNED_FRT',lad.acctd_amount,
                 'ADJ_LINE',lad.acctd_amount,
                 'ADJ_TAX',lad.acctd_amount,
                 'ADJ_CHRG',lad.acctd_amount,
                 'ADJ_FRT',lad.acctd_amount,
                 -1* lad.acctd_amount)) * ABS(lad.from_amount)   --FROM_AMOUNT
, SIGN(DECODE(lad.activity_bucket,'ED_LINE',lad.acctd_amount,
                 'ED_TAX', lad.acctd_amount,
                 'ED_CHRG',lad.acctd_amount,
                 'ED_FRT' ,lad.acctd_amount,
                 'UNED_LINE',lad.acctd_amount,
                 'UNED_TAX',lad.acctd_amount,
                 'UNED_CHRG',lad.acctd_amount,
                 'UNED_FRT',lad.acctd_amount,
                 'ADJ_LINE',lad.acctd_amount,
                 'ADJ_TAX',lad.acctd_amount,
                 'ADJ_CHRG',lad.acctd_amount,
                 'ADJ_FRT',lad.acctd_amount,
                 -1* lad.acctd_amount)) * ABS(lad.from_acctd_amount)    --FROM_ACCTD_AMOUNT
,  lad.ledger_id                                     --LEDGER_ID
,  lad.base_currency                                --BASE_CURRENCY
FROM AR_LINE_APP_DETAIL_GT  lad,
     ar_payment_schedules_all       sch
WHERE lad.ref_customer_trx_id   = sch.customer_trx_id
  AND lad.gt_id                 = p_gt_id;
  l_rows := sql%rowcount;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  rows inserted = ' || l_rows);
  END IF;
END;

--{Lazy upgrade at posting
-- Modification, this is procedure will be called in downtime
PROCEDURE prepare_for_ra
(  p_gt_id                IN NUMBER,
   p_app_rec              IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec           IN arp_acct_main.ae_sys_rec_type,
   p_inv_cm               IN VARCHAR2 DEFAULT 'I',
   p_cash_mfar            IN VARCHAR2 DEFAULT 'CASH')
IS
  CURSOR cu_trx(p_trx_id IN NUMBER) IS
  SELECT * FROM ra_customer_trx_all
  WHERE customer_trx_id = p_trx_id;
  l_trx_rec       ra_customer_trx_all%ROWTYPE;
  l_exec_status   VARCHAR2(10) := 'N';
  l_adj_rec       ar_adjustments%ROWTYPE;
  l_app_rec       ar_receivable_applications%ROWTYPE;
  next_app        EXCEPTION;
BEGIN
--
PG_DEBUG := 'N';

g_upgrade_mode := 'Y';
g_currency_code := p_ae_sys_rec.base_currency;
g_org_id       := p_app_rec.org_id;

IF p_ae_sys_rec.sob_type = 'P' THEN

  IF   p_inv_cm = 'C' THEN
    OPEN cu_trx(p_trx_id => p_app_rec.customer_trx_id);
  ELSE
    OPEN cu_trx(p_trx_id => p_app_rec.applied_customer_trx_id);
  END IF;
  FETCH cu_trx INTO l_trx_rec;
  IF cu_trx%FOUND THEN
    g_cust_inv_rec.remittance_bank_account_id :=  l_trx_rec.remittance_bank_account_id;
    g_cust_inv_rec.override_remit_account_flag :=  l_trx_rec.override_remit_account_flag;
    g_cust_inv_rec.special_instructions :=  l_trx_rec.special_instructions;
    g_cust_inv_rec.remittance_batch_id :=  l_trx_rec.remittance_batch_id;
    g_cust_inv_rec.prepayment_flag :=  l_trx_rec.prepayment_flag;
    g_cust_inv_rec.ct_reference :=  l_trx_rec.ct_reference;
    g_cust_inv_rec.contract_id :=  l_trx_rec.contract_id;
    g_cust_inv_rec.bill_template_id :=  l_trx_rec.bill_template_id;
    g_cust_inv_rec.reversed_cash_receipt_id :=  l_trx_rec.reversed_cash_receipt_id;
    g_cust_inv_rec.interface_header_attribute7 :=  l_trx_rec.interface_header_attribute7;
    g_cust_inv_rec.interface_header_attribute8 :=  l_trx_rec.interface_header_attribute8;
    g_cust_inv_rec.interface_header_context :=  l_trx_rec.interface_header_context;
    g_cust_inv_rec.default_ussgl_trx_code_context :=  l_trx_rec.default_ussgl_trx_code_context;
    g_cust_inv_rec.drawee_bank_account_id :=  l_trx_rec.drawee_bank_account_id;
    g_cust_inv_rec.default_ussgl_transaction_code :=  l_trx_rec.default_ussgl_transaction_code;
    g_cust_inv_rec.recurred_from_trx_number :=  l_trx_rec.recurred_from_trx_number;
    g_cust_inv_rec.status_trx :=  l_trx_rec.status_trx;
    g_cust_inv_rec.doc_sequence_id :=  l_trx_rec.doc_sequence_id;
    g_cust_inv_rec.doc_sequence_value :=  l_trx_rec.doc_sequence_value;
    g_cust_inv_rec.paying_customer_id :=  l_trx_rec.paying_customer_id;
    g_cust_inv_rec.paying_site_use_id :=  l_trx_rec.paying_site_use_id;
    g_cust_inv_rec.related_batch_source_id :=  l_trx_rec.related_batch_source_id;
    g_cust_inv_rec.default_tax_exempt_flag :=  l_trx_rec.default_tax_exempt_flag;
    g_cust_inv_rec.created_from :=  l_trx_rec.created_from;
    g_cust_inv_rec.org_id :=  l_trx_rec.org_id;
    g_cust_inv_rec.request_id :=  l_trx_rec.request_id;
    g_cust_inv_rec.program_application_id :=  l_trx_rec.program_application_id;
    g_cust_inv_rec.program_id :=  l_trx_rec.program_id;
    g_cust_inv_rec.program_update_date :=  l_trx_rec.program_update_date;
    g_cust_inv_rec.finance_charges :=  l_trx_rec.finance_charges;
    g_cust_inv_rec.complete_flag :=  l_trx_rec.complete_flag;
    g_cust_inv_rec.posting_control_id :=  l_trx_rec.posting_control_id;
    g_cust_inv_rec.bill_to_address_id :=  l_trx_rec.bill_to_address_id;
    g_cust_inv_rec.ra_post_loop_number :=  l_trx_rec.ra_post_loop_number;
    g_cust_inv_rec.ship_to_address_id :=  l_trx_rec.ship_to_address_id;
    g_cust_inv_rec.credit_method_for_rules :=  l_trx_rec.credit_method_for_rules;
    g_cust_inv_rec.credit_method_for_installments :=  l_trx_rec.credit_method_for_installments;
    g_cust_inv_rec.receipt_method_id :=  l_trx_rec.receipt_method_id;
    g_cust_inv_rec.related_customer_trx_id :=  l_trx_rec.related_customer_trx_id;
    g_cust_inv_rec.invoicing_rule_id :=  l_trx_rec.invoicing_rule_id;
    g_cust_inv_rec.ship_via :=  l_trx_rec.ship_via;
    g_cust_inv_rec.ship_date_actual :=  l_trx_rec.ship_date_actual;
    g_cust_inv_rec.waybill_number :=  l_trx_rec.waybill_number;
    g_cust_inv_rec.fob_point :=  l_trx_rec.fob_point;
    g_cust_inv_rec.customer_bank_account_id :=  l_trx_rec.customer_bank_account_id;
    g_cust_inv_rec.printing_option :=  l_trx_rec.printing_option;
    g_cust_inv_rec.printing_count :=  l_trx_rec.printing_count;
    g_cust_inv_rec.printing_pending :=  l_trx_rec.printing_pending;
    g_cust_inv_rec.purchase_order :=  l_trx_rec.purchase_order;
    g_cust_inv_rec.purchase_order_revision :=  l_trx_rec.purchase_order_revision;
    g_cust_inv_rec.purchase_order_date :=  l_trx_rec.purchase_order_date;
    g_cust_inv_rec.customer_reference :=  l_trx_rec.customer_reference;
    g_cust_inv_rec.customer_reference_date :=  l_trx_rec.customer_reference_date;
    g_cust_inv_rec.comments :=  l_trx_rec.comments;
    g_cust_inv_rec.internal_notes :=  l_trx_rec.internal_notes;
    g_cust_inv_rec.exchange_rate_type :=  l_trx_rec.exchange_rate_type;
    g_cust_inv_rec.exchange_date :=  l_trx_rec.exchange_date;
    g_cust_inv_rec.exchange_rate :=  l_trx_rec.exchange_rate;
    g_cust_inv_rec.territory_id :=  l_trx_rec.territory_id;
    g_cust_inv_rec.invoice_currency_code :=  l_trx_rec.invoice_currency_code;
    g_cust_inv_rec.initial_customer_trx_id :=  l_trx_rec.initial_customer_trx_id;
    g_cust_inv_rec.agreement_id :=  l_trx_rec.agreement_id;
    g_cust_inv_rec.end_date_commitment :=  l_trx_rec.end_date_commitment;
    g_cust_inv_rec.start_date_commitment :=  l_trx_rec.start_date_commitment;
    g_cust_inv_rec.last_printed_sequence_num :=  l_trx_rec.last_printed_sequence_num;
    g_cust_inv_rec.attribute_category :=  l_trx_rec.attribute_category;
    g_cust_inv_rec.orig_system_batch_name :=  l_trx_rec.orig_system_batch_name;
    g_cust_inv_rec.customer_trx_id :=  l_trx_rec.customer_trx_id;
    g_cust_inv_rec.trx_number :=  l_trx_rec.trx_number;
    g_cust_inv_rec.cust_trx_type_id :=  l_trx_rec.cust_trx_type_id;
    g_cust_inv_rec.trx_date :=  l_trx_rec.trx_date;
    g_cust_inv_rec.set_of_books_id :=  l_trx_rec.set_of_books_id;
    g_cust_inv_rec.bill_to_contact_id :=  l_trx_rec.bill_to_contact_id;
    g_cust_inv_rec.batch_id :=  l_trx_rec.batch_id;
    g_cust_inv_rec.batch_source_id :=  l_trx_rec.batch_source_id;
    g_cust_inv_rec.reason_code :=  l_trx_rec.reason_code;
    g_cust_inv_rec.sold_to_customer_id :=  l_trx_rec.sold_to_customer_id;
    g_cust_inv_rec.sold_to_contact_id :=  l_trx_rec.sold_to_contact_id;
    g_cust_inv_rec.sold_to_site_use_id :=  l_trx_rec.sold_to_site_use_id;
    g_cust_inv_rec.bill_to_customer_id :=  l_trx_rec.bill_to_customer_id;
    g_cust_inv_rec.bill_to_site_use_id :=  l_trx_rec.bill_to_site_use_id;
    g_cust_inv_rec.ship_to_customer_id :=  l_trx_rec.ship_to_customer_id;
    g_cust_inv_rec.ship_to_contact_id :=  l_trx_rec.ship_to_contact_id;
    g_cust_inv_rec.ship_to_site_use_id :=  l_trx_rec.ship_to_site_use_id;
    g_cust_inv_rec.shipment_id :=  l_trx_rec.shipment_id;
    g_cust_inv_rec.remit_to_address_id :=  l_trx_rec.remit_to_address_id;
    g_cust_inv_rec.term_id :=  l_trx_rec.term_id;
    g_cust_inv_rec.term_due_date :=  l_trx_rec.term_due_date;
    g_cust_inv_rec.previous_customer_trx_id :=  l_trx_rec.previous_customer_trx_id;
    g_cust_inv_rec.primary_salesrep_id :=  l_trx_rec.primary_salesrep_id;
    g_cust_inv_rec.printing_original_date :=  l_trx_rec.printing_original_date;
    g_cust_inv_rec.printing_last_printed :=  l_trx_rec.printing_last_printed;
    g_cust_inv_rec.payment_server_order_num :=  l_trx_rec.payment_server_order_num;
    g_cust_inv_rec.approval_code :=  l_trx_rec.approval_code;
    g_cust_inv_rec.address_verification_code :=  l_trx_rec.address_verification_code;
    g_cust_inv_rec.old_trx_number :=  l_trx_rec.old_trx_number;
    g_cust_inv_rec.br_amount :=  l_trx_rec.br_amount;
    g_cust_inv_rec.br_unpaid_flag :=  l_trx_rec.br_unpaid_flag;
    g_cust_inv_rec.br_on_hold_flag :=  l_trx_rec.br_on_hold_flag;
    g_cust_inv_rec.drawee_id :=  l_trx_rec.drawee_id;
    g_cust_inv_rec.drawee_contact_id :=  l_trx_rec.drawee_contact_id;
    g_cust_inv_rec.drawee_site_use_id :=  l_trx_rec.drawee_site_use_id;
  ELSE
    RAISE next_app;
  END IF;

  IF cu_trx%ISOPEN THEN
    CLOSE cu_trx;
  END IF;

  IF p_inv_cm = 'C' THEN
     convert_ra_inv_to_cm
     ( p_inv_ra_rec     => p_app_rec,
       p_cm_trx_id      => g_cust_inv_rec.customer_trx_id,
       x_cm_ra_rec      => l_app_rec,
       p_mode           => 'BATCH',
       p_gt_id          => p_gt_id);
  ELSE
     l_app_rec := p_app_rec;
  END IF;

  conv_acctd_amt_upg(p_pay_adj         => 'APP',
                 p_adj_rec         => l_adj_rec,
                 p_app_rec         => l_app_rec,
                 p_ae_sys_rec      => p_ae_sys_rec);

  IF g_line_ed <> 0 OR
     g_acctd_line_ed <> 0 OR
     g_chrg_ed <> 0 OR
     g_acctd_chrg_ed <> 0 OR
     g_frt_ed <> 0 OR
     g_acctd_frt_ed <> 0 OR
     g_tax_ed <> 0 OR
     g_acctd_tax_ed <> 0
  THEN
     g_ed_req := 'Y';
  ELSE
     g_ed_req := 'N';
  END IF;


  IF g_line_uned <> 0 OR
     g_acctd_line_uned <> 0 OR
     g_chrg_uned <> 0 OR
     g_acctd_chrg_uned <> 0 OR
     g_frt_uned <> 0 OR
     g_acctd_frt_uned <> 0 OR
     g_tax_uned <> 0 OR
     g_acctd_tax_uned <> 0
  THEN
     g_uned_req := 'Y';
  ELSE
     g_uned_req := 'N';
  END IF;

IF p_cash_mfar = 'CASH' THEN

IF PG_DEBUG = 'Y' THEN
localdebug('p_gt_id:'||p_gt_id);
END IF;

  UPDATE RA_AR_GT SET
     tl_alloc_amt       = DECODE(account_class,'REV'     ,g_line_applied,
                                 'INVOICE' ,g_line_applied,0)
   , tl_alloc_acctd_amt = DECODE(account_class,'REV'     ,g_acctd_line_applied,
                                 'INVOICE' ,g_acctd_line_applied,0)
   , tl_chrg_alloc_amt  = DECODE(account_class,'CHARGES' ,g_chrg_applied,
                                 'INVOICE' ,g_chrg_applied,0)
   , tl_chrg_alloc_acctd_amt = DECODE(account_class,'CHARGES' ,g_acctd_chrg_applied,
                                     'INVOICE' ,g_acctd_chrg_applied,0)
   , tl_frt_alloc_amt   = DECODE(account_class,'FREIGHT' ,g_frt_applied,
                                'INVOICE' ,g_frt_applied,0)
   , tl_frt_alloc_acctd_amt = DECODE(account_class,'FREIGHT' ,g_acctd_frt_applied,
                                     'INVOICE' ,g_acctd_frt_applied,0)
   , tl_tax_alloc_amt   = DECODE(account_class,'TAX'     ,g_tax_applied,
                                'INVOICE' ,g_tax_applied,0)
   , tl_tax_alloc_acctd_amt = DECODE(account_class,'TAX'     ,g_acctd_tax_applied,
                                    'INVOICE' ,g_acctd_tax_applied,0)
     --
   , tl_ed_alloc_amt    = DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_line_ed,0),0)
   , tl_ed_alloc_acctd_amt  = DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_acctd_line_ed,0),0)
   , tl_ed_chrg_alloc_amt   = DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_chrg_ed,0),0)
   , tl_ed_chrg_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_acctd_chrg_ed,0),0)
   , tl_ed_frt_alloc_amt    = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_frt_ed,0),0)
   , tl_ed_frt_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_acctd_frt_ed,0),0)
   , tl_ed_tax_alloc_amt    = DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_tax_ed,0),0)
   , tl_ed_tax_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_acctd_tax_ed,0),0)
     --
   , tl_uned_alloc_amt      = DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_line_uned,0),0)
   , tl_uned_alloc_acctd_amt= DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_acctd_line_uned,0),0)
   , tl_uned_chrg_alloc_amt = DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_chrg_uned,0),0)
   , tl_uned_chrg_alloc_acctd_amt= DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_acctd_chrg_uned,0),0)
   , tl_uned_frt_alloc_amt  = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_frt_uned,0),0)
   , tl_uned_frt_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_acctd_frt_uned,0),0)
   , tl_uned_tax_alloc_amt  = DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_tax_uned,0),0)
   , tl_uned_tax_alloc_acctd_amt =DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_acctd_tax_uned,0),0)
     --
   , gt_id = p_gt_id
   , source_id = p_app_rec.receivable_application_id
   , source_table ='RA'
   , base_currency = p_ae_sys_rec.base_currency
  WHERE ref_customer_trx_id = g_cust_inv_rec.customer_trx_id;

  UPDATE ar_base_dist_amts_gt
  set  gt_id = p_gt_id
   , source_id = p_app_rec.receivable_application_id
   , source_table ='RA'
  WHERE ref_customer_trx_id = g_cust_inv_rec.customer_trx_id;


ELSIF p_cash_mfar = 'MFAR'  THEN

  UPDATE RA_AR_GT SET
    tl_alloc_amt         = DECODE(account_class,'REV'     ,g_line_applied,0)
   ,tl_alloc_acctd_amt   = DECODE(account_class,'REV'     ,g_acctd_line_applied,0)
   ,tl_chrg_alloc_amt    = g_chrg_applied
   ,tl_chrg_alloc_acctd_amt = g_acctd_chrg_applied
   ,tl_frt_alloc_amt     = DECODE(account_class,'FREIGHT' ,g_frt_applied,0)
   ,tl_frt_alloc_acctd_amt = DECODE(account_class,'FREIGHT' ,g_acctd_frt_applied,0)
   ,tl_tax_alloc_amt     = DECODE(account_class,'TAX'     ,g_tax_applied,0)
   ,tl_tax_alloc_acctd_amt = DECODE(account_class,'TAX'     ,g_acctd_tax_applied,0)
     --
   ,tl_ed_alloc_amt        = DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_line_ed,0),0)
   ,tl_ed_alloc_acctd_amt  = DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_acctd_line_ed,0),0)
   ,tl_ed_chrg_alloc_amt   = DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_chrg_ed,0),0)
   ,tl_ed_chrg_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_acctd_chrg_ed,0),0)
   ,tl_ed_frt_alloc_amt    = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_frt_ed,0),0)
   ,tl_ed_frt_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_acctd_frt_ed,0),0)
   ,tl_ed_tax_alloc_amt    = DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_tax_ed,0),0)
   ,tl_ed_tax_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_acctd_tax_ed,0),0)
     --
   ,tl_uned_alloc_amt      = DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_line_uned,0),0)
   ,tl_uned_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'REV'    ,g_acctd_line_uned,0),0)
   ,tl_uned_chrg_alloc_amt  = DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_chrg_uned,0),0)
   ,tl_uned_chrg_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'CHARGES',g_acctd_chrg_uned,0),0)
   ,tl_uned_frt_alloc_amt   = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_frt_uned,0),0)
   ,tl_uned_frt_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'FREIGHT',g_acctd_frt_uned,0),0)
   ,tl_uned_tax_alloc_amt   =  DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_tax_uned,0),0)
   ,tl_uned_tax_alloc_acctd_amt = DECODE(source_type,NULL,DECODE(account_class,'TAX'    ,g_acctd_tax_uned,0),0)
     --
   ,gt_id = p_gt_id
   ,source_id = p_app_rec.receivable_application_id
   ,source_table = 'RA'
   ,base_currency = p_ae_sys_rec.base_currency
  WHERE ref_customer_trx_id = g_cust_inv_rec.customer_trx_id;

  UPDATE ar_base_dist_amts_gt
  set  gt_id = p_gt_id
   , source_id = p_app_rec.receivable_application_id
   , source_table ='RA'
  WHERE ref_customer_trx_id = g_cust_inv_rec.customer_trx_id;

END IF;

--  delete from ra_ar;
--  insert into ra_ar select * from ra_ar_gt;


--g_se_gt_id := USERENV('SESSIONID');

update_dist
(p_gt_id             => p_gt_id,
 p_customer_trx_id   => g_cust_inv_rec.customer_trx_id,
 p_ae_sys_rec        => p_ae_sys_rec);

create_split_distribution
 (p_pay_adj                => 'APP',
  p_customer_trx_id        => g_cust_inv_rec.customer_trx_id,
  p_gt_id                  => p_gt_id,
  p_app_level              => 'RL',
  p_ae_sys_rec             => p_ae_sys_rec);

update_from_gt
(p_from_amt         => p_app_rec.amount_applied_from,
 p_from_acctd_amt   => p_app_rec.acctd_amount_applied_from,
 p_ae_sys_rec       => p_ae_sys_rec,
 p_app_rec          => l_app_rec,
 p_gt_id             => p_gt_id);


insert_ard_gt(p_gt_id => p_gt_id,
              x_exec_status =>l_exec_status );

--IF l_exec_status = 'Y' THEN
--   UPDATE ar_receivable_applications_all
--     SET upgrade_method = 'R12_11ICASH_POST'
--   WHERE receivable_application_id = p_app_rec.receivable_application_id;
--END IF;


END IF;

EXCEPTION
 WHEN next_app THEN NULL;
END;

-- OLTP legacy transaction with 11I adjustments

PROCEDURE check_legacy_status
  (p_trx_id           IN  NUMBER,
   p_adj_id           IN  NUMBER DEFAULT NULL,
   p_app_id           IN  NUMBER DEFAULT NULL,
   x_11i_adj          OUT NOCOPY  VARCHAR2,
   x_mfar_adj         OUT NOCOPY  VARCHAR2,
   x_11i_app          OUT NOCOPY  VARCHAR2,
   x_mfar_app         OUT NOCOPY  VARCHAR2)
IS
  CURSOR c IS
  SELECT tt.psa_trx_type_id                                   psa_tt_id,
         (SELECT adjustment_id
            FROM ar_adjustments adj
           WHERE customer_trx_id = trx.customer_trx_id
             AND upgrade_method        = '11I'
             AND rownum          = 1)                          c11iadj,
         (SELECT adjustment_id
            FROM ar_adjustments adj
           WHERE customer_trx_id = trx.customer_trx_id
             AND upgrade_method        = '11IMFAR'
             AND rownum          = 1)                           mfadj,
         (SELECT app.receivable_application_id
            FROM ar_receivable_applications app
           WHERE app.applied_customer_trx_id = trx.customer_trx_id
             AND NVL(app.upgrade_method,'NULL') IN ('11I_MFAR_UPG','NULL')
             AND NVL(p_app_id,-9) <> app.receivable_application_id  -- excluded the current app record
             AND rownum           = 1)                          app11i,
         (SELECT receivable_application_id
            FROM ar_receivable_applications app
           WHERE app.customer_trx_id = trx.customer_trx_id
             AND NVL(app.upgrade_method,'NULL') IN ('11I_MFAR_UPG','NULL')
             AND NVL(p_app_id,-9) <> app.receivable_application_id  -- excluded the current app record
             AND rownum          = 1)                          cmapp11i
    FROM ra_customer_trx            trx,
         psa_trx_types_all          tt
   WHERE trx.customer_trx_id  = p_trx_id
     AND trx.cust_trx_type_id = tt.psa_trx_type_id(+);

  l_record  c%ROWTYPE;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.check_legacy_status()+');
  END IF;

  OPEN c;
  FETCH c INTO l_record;
  IF c%NOTFOUND THEN
     x_11i_adj    := 'N';
     x_mfar_adj   := 'N';
     x_11i_app    := 'N';
     x_mfar_app   := 'N';
  ELSE
     -- c11iadj and mfadj can never be 'Y' at the same time
     IF  l_record.c11iadj IS NOT NULL THEN
       x_11i_adj  := 'Y';
     ELSE
       x_11i_adj  := 'N';
     END IF;
     IF  l_record.mfadj IS NOT NULL THEN
       x_mfar_adj := 'Y';
     ELSE
       x_mfar_adj := 'N';
     END IF;

     IF l_record.app11i IS NOT NULL OR  l_record.cmapp11i IS NOT NULL  THEN
        -- application does exist
        IF l_record.psa_tt_id IS NOT NULL THEN
            -- the app are mfar in 11i
            x_11i_app   := 'N';
            x_mfar_app  := 'Y';
        ELSE
            -- the app are accrual in 11i
            x_11i_app   := 'Y';
            x_mfar_app  := 'N';
        END IF;
     ELSE
        -- no application on this trx
        x_11i_app   := 'N';
        x_mfar_app  := 'N';
     END IF;
  END IF;
  CLOSE c;
  IF PG_DEBUG = 'Y' THEN
  localdebug('   11i adj existence     :'||x_11i_adj);
  localdebug('   11i mfar adj existence:'||x_mfar_adj);
  localdebug('   11i app existence     :'||x_11i_app);
  localdebug('   11i mfar app existence:'||x_mfar_app);
  localdebug('arp_det_dist_pkg.check_legacy_status()-');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug(' EXCEPTION OTHERS  check_legacy_status   :'||SQLERRM);
    END IF;
END check_legacy_status;




PROCEDURE check_lazy_apply_req
  (p_trx_id           IN  NUMBER,
   x_out_res          OUT NOCOPY  VARCHAR2)
IS
  CURSOR c11I IS
  SELECT 'Y'
    FROM ar_adjustments adj
   WHERE adj.customer_trx_id = p_trx_id
     AND adj.status          = 'A'
     AND adj.postable        = 'Y'
     AND adj.upgrade_method   IN ('11I','11IMFAR') ;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.check_lazy_apply_req()+');
  END IF;
  OPEN c11I;
  FETCH c11I INTO x_out_res;
  IF c11I%NOTFOUND THEN
     x_out_res := 'N';
  END IF;
  CLOSE c11I;
  IF PG_DEBUG = 'Y' THEN
  localdebug('  x_out_res : '|| x_out_res);
  localdebug('arp_det_dist_pkg.check_lazy_apply_req()-');
  END IF;
END;



PROCEDURE check_mf_trx
( p_cust_trx_type_id  IN NUMBER,
  x_out_res           OUT NOCOPY VARCHAR2)
IS
CURSOR c1 IS
SELECT 'Y'
  FROM psa_trx_types_all
 WHERE psa_trx_type_id  = p_cust_trx_type_id;
is_mf_trx   VARCHAR2(1);
BEGIN
  OPEN c1;
  FETCH c1 INTO  is_mf_trx;
  IF c1%NOTFOUND THEN
     is_mf_trx := 'N';
  ELSE
     is_mf_trx := 'Y';
  END IF;
  CLOSE c1;
  x_out_res := is_mf_trx;
END;


PROCEDURE online_lazy_apply
  (p_customer_trx     IN ra_customer_trx%ROWTYPE,
   p_app_rec          IN ar_receivable_applications%ROWTYPE,
   p_ae_sys_rec       IN arp_acct_main.ae_sys_rec_type,
   p_gt_id            IN NUMBER,
   --Add the p_inv_cm flag
   p_inv_cm           IN VARCHAR2 DEFAULT 'I')
IS
  l_adj_rec     ar_adjustments%ROWTYPE;
  l_app_rec     ar_receivable_applications%ROWTYPE;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.Online_lazy_apply()+');
  localdebug('  p_app_rec.applied_customer_trx_id : '||p_app_rec.applied_customer_trx_id);
  localdebug('  p_gt_id                          : '||p_gt_id);
  END IF;

  ar_upgrade_cash_accrual.get_direct_inv_dist
      (p_mode   => 'OLTP',
       p_trx_id => p_app_rec.applied_customer_trx_id,
       p_gt_id  => p_gt_id);

  ar_upgrade_cash_accrual.get_direct_adj_dist
      (p_mode   => 'OLTP',
       p_trx_id => p_app_rec.applied_customer_trx_id,
       p_gt_id  => p_gt_id);

  ar_upgrade_cash_accrual.get_direct_inv_adj_dist
      (p_mode   => 'OLTP',
       p_trx_id => p_app_rec.applied_customer_trx_id,
       p_gt_id  => p_gt_id);

  ar_upgrade_cash_accrual.update_base
      (p_gt_id  => p_gt_id);

--  g_se_gt_id :=  USERENV('SESSIONID');

  g_cust_inv_rec := p_customer_trx;

  IF p_inv_cm = 'C' THEN
    convert_ra_inv_to_cm
      (p_inv_ra_rec    => p_app_rec ,
       p_cm_trx_id     => g_cust_inv_rec.customer_trx_id,
       x_cm_ra_rec     => l_app_rec,
	   p_mode          => 'OLTP',
	   p_gt_id         => p_gt_id);
  ELSE
    l_app_rec  := p_app_rec;
  END IF;

  conv_acctd_amt(p_pay_adj         => 'APP',
                 p_adj_rec         => l_adj_rec,
                 p_app_rec         => l_app_rec,
                 p_ae_sys_rec      => p_ae_sys_rec);


  IF g_line_ed <> 0 OR
     g_acctd_line_ed <> 0 OR
     g_chrg_ed <> 0 OR
     g_acctd_chrg_ed <> 0 OR
     g_frt_ed <> 0 OR
     g_acctd_frt_ed <> 0 OR
     g_tax_ed <> 0 OR
     g_acctd_tax_ed <> 0
  THEN
     g_ed_req := 'Y';
  ELSE
     g_ed_req := 'N';
  END IF;


  IF g_line_uned <> 0 OR
     g_acctd_line_uned <> 0 OR
     g_chrg_uned <> 0 OR
     g_acctd_chrg_uned <> 0 OR
     g_frt_uned <> 0 OR
     g_acctd_frt_uned <> 0 OR
     g_tax_uned <> 0 OR
     g_acctd_tax_uned <> 0
  THEN
     g_uned_req := 'Y';
  ELSE
     g_uned_req := 'N';
  END IF;


  UPDATE RA_AR_GT a SET
  (  tl_alloc_amt          ,
     tl_alloc_acctd_amt    ,
     tl_chrg_alloc_amt     ,
     tl_chrg_alloc_acctd_amt,
     tl_frt_alloc_amt     ,
     tl_frt_alloc_acctd_amt,
     tl_tax_alloc_amt     ,
     tl_tax_alloc_acctd_amt,
     --
     tl_ed_alloc_amt          ,
     tl_ed_alloc_acctd_amt    ,
     tl_ed_chrg_alloc_amt     ,
     tl_ed_chrg_alloc_acctd_amt,
     tl_ed_frt_alloc_amt     ,
     tl_ed_frt_alloc_acctd_amt,
     tl_ed_tax_alloc_amt     ,
     tl_ed_tax_alloc_acctd_amt,
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
     gt_id,
--     se_gt_id,
     source_id,
     source_table,
     base_currency) =
  (SELECT /*+INDEX (b ra_ar_n1)*/
     DECODE(account_class,'REV'     ,g_line_applied,
	                      'INVOICE' ,g_line_applied,0)          -- tl_alloc_amt
,    DECODE(account_class,'REV'     ,g_acctd_line_applied,
                          'INVOICE' ,g_acctd_line_applied,0)    -- tl_alloc_acctd_amt
,    DECODE(account_class,'CHARGES' ,g_chrg_applied,
                          'INVOICE' ,g_chrg_applied,0)          -- tl_chrg_alloc_amt
,    DECODE(account_class,'CHARGES' ,g_acctd_chrg_applied,
                          'INVOICE' ,g_acctd_chrg_applied,0)    -- tl_chrg_alloc_acctd_amt
,    DECODE(account_class,'FREIGHT' ,g_frt_applied,
                          'INVOICE' ,g_frt_applied,0)           -- tl_frt_alloc_amt
,    DECODE(account_class,'FREIGHT' ,g_acctd_frt_applied,
                          'INVOICE' ,g_acctd_frt_applied,0)     -- tl_frt_alloc_acctd_amt
,    DECODE(account_class,'TAX'     ,g_tax_applied,
                          'INVOICE' ,g_tax_applied,0)           -- tl_tax_alloc_amt
,    DECODE(account_class,'TAX'     ,g_acctd_tax_applied,
                          'INVOICE' ,g_acctd_tax_applied,0)     -- tl_tax_alloc_acctd_amt
      --
,    DECODE(account_class,'REV'    ,g_line_ed,0)          -- tl_ed_alloc_amt
,    DECODE(account_class,'REV'    ,g_acctd_line_ed,0)    -- tl_ed_alloc_acctd_amt
,    DECODE(account_class,'CHARGES',g_chrg_ed,0)          -- tl_ed_chrg_alloc_amt
,    DECODE(account_class,'CHARGES',g_acctd_chrg_ed,0)    -- tl_ed_chrg_alloc_acctd_amt
,    DECODE(account_class,'FREIGHT',g_frt_ed,0)           -- tl_ed_frt_alloc_amt
,    DECODE(account_class,'FREIGHT',g_acctd_frt_ed,0)     -- tl_ed_frt_alloc_acctd_amt
,    DECODE(account_class,'TAX'    ,g_tax_ed,0)           -- tl_ed_tax_alloc_amt
,    DECODE(account_class,'TAX'    ,g_acctd_tax_ed,0)     -- tl_ed_tax_alloc_acctd_amt

,    DECODE(account_class,'REV'    ,g_line_uned,0)          -- tl_uned_alloc_amt
,    DECODE(account_class,'REV'    ,g_acctd_line_uned,0)    -- tl_uned_alloc_acctd_amt
,    DECODE(account_class,'CHARGES',g_chrg_uned,0)          -- tl_uned_chrg_alloc_amt
,    DECODE(account_class,'CHARGES',g_acctd_chrg_uned,0)    -- tl_uned_chrg_alloc_acctd_amt
,    DECODE(account_class,'FREIGHT',g_frt_uned,0)           -- tl_uned_frt_alloc_amt
,    DECODE(account_class,'FREIGHT',g_acctd_frt_uned,0)     -- tl_uned_frt_alloc_acctd_amt
,    DECODE(account_class,'TAX'    ,g_tax_uned,0)           -- tl_uned_tax_alloc_amt
,    DECODE(account_class,'TAX'    ,g_acctd_tax_uned,0)     -- tl_uned_tax_alloc_acctd_amt
,    p_gt_id
--,    USERENV('SESSIONID')
,    p_app_rec.receivable_application_id
,    'RA'
,    p_ae_sys_rec.base_currency
   FROM ra_ar_gt b
  WHERE a.rowid    = b.rowid
    AND a.gt_id    = p_gt_id);

--  delete from ra_ar;
--  insert into ra_ar select * from ra_ar_gt;

  update_dist
      (p_gt_id           => p_gt_id,
       p_customer_trx_id => l_app_rec.applied_customer_trx_id,
       p_ae_sys_rec      => p_ae_sys_rec);

  create_split_distribution
   (p_pay_adj            => 'APP',
    p_customer_trx_id    => l_app_rec.applied_customer_trx_id,
    p_gt_id              => p_gt_id,
    p_app_level          => 'RL',
    p_ae_sys_rec         => p_ae_sys_rec);

--{ For R12_11ICASH maintain from_acctd_amt
  update_from_gt
  (p_from_amt            => l_app_rec.AMOUNT_APPLIED_FROM,
   p_from_acctd_amt      => l_app_rec.ACCTD_AMOUNT_APPLIED_FROM,
   p_ae_sys_rec          => p_ae_sys_rec,
   p_app_rec             => p_app_rec);
--}

--delete from hy_line_application_detail;
--insert into hy_line_application_detail select * from AR_LINE_APP_DETAIL_GT;

   IF g_mode_process = 'R12_MERGE' THEN
       UPDATE ar_receivable_applications_all
       SET upgrade_method = 'R12_MERGE'
       WHERE receivable_application_id = l_app_rec.receivable_application_id;
   ELSE
       UPDATE ar_receivable_applications_all
       SET upgrade_method = 'R12_11ICASH'
       WHERE receivable_application_id = l_app_rec.receivable_application_id;
   END IF;

IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.Online_lazy_apply()-');
END IF;
EXCEPTION
  WHEN OTHERS THEN
    localdebug('OTHERS : Online_lazy_apply '||SQLERRM);
    RAISE;
END;
--}



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
 x_msg_count       OUT NOCOPY  NUMBER)
IS
 CURSOR c_trx IS
 SELECT /*+INDEX (ra_customer_trx_lines_gt ra_customer_trx_lines_gt_n1)*/
        NVL(SUM(DECODE(line_type,'LINE',NVL(AMOUNT_DUE_REMAINING,0))),0)      line_rem,
        NVL(SUM(DECODE(line_type,'TAX' ,NVL(AMOUNT_DUE_REMAINING,0))),0)      tax_rem,
        NVL(SUM(DECODE(line_type,'LINE',NVL(CHRG_AMOUNT_REMAINING,0))),0) +
	  NVL(SUM(DECODE(line_type,'CHARGES',NVL(AMOUNT_DUE_REMAINING,0))),0) chrg_rem,
        NVL(SUM(DECODE(line_type,'LINE',NVL(FRT_ADJ_REMAINING,0))),0) +
          NVL(SUM(DECODE(line_type,'FREIGHT',NVL(AMOUNT_DUE_REMAINING,0))),0) frt_rem
   FROM ra_customer_trx_lines_gt
  WHERE CUSTOMER_TRX_ID = p_customer_trx_id;

 CURSOR c_line IS
 SELECT /*+INDEX (ra_customer_trx_lines_gt ra_customer_trx_lines_gt_n1)*/
        NVL(SUM(DECODE(line_type,'LINE',NVL(AMOUNT_DUE_REMAINING,0))),0)      line_rem,
        NVL(SUM(DECODE(line_type,'TAX' ,NVL(AMOUNT_DUE_REMAINING,0))),0)      tax_rem,
        NVL(SUM(DECODE(line_type,'LINE',NVL(CHRG_AMOUNT_REMAINING,0))),0) +
          NVL(SUM(DECODE(line_type,'CHARGES',NVL(AMOUNT_DUE_REMAINING,0))),0) chrg_rem,
        NVL(SUM(DECODE(line_type,'LINE',NVL(FRT_ADJ_REMAINING,0))),0) +
          NVL(SUM(DECODE(line_type,'FREIGHT',NVL(AMOUNT_DUE_REMAINING,0))),0) frt_rem
   FROM ra_customer_trx_lines_gt
  WHERE CUSTOMER_TRX_ID = p_customer_trx_id
    AND DECODE(line_type,'LINE',customer_trx_line_id, LINK_TO_CUST_TRX_LINE_ID) = p_ctl_id;

 CURSOR c_gp IS
 SELECT /*+INDEX (ra_customer_trx_lines_gt ra_customer_trx_lines_gt_n1)*/
        NVL(SUM(DECODE(line_type,'LINE',NVL(AMOUNT_DUE_REMAINING,0))),0)      line_rem,
        NVL(SUM(DECODE(line_type,'TAX' ,NVL(AMOUNT_DUE_REMAINING,0))),0)      tax_rem,
        NVL(SUM(DECODE(line_type,'LINE',NVL(CHRG_AMOUNT_REMAINING,0))),0) +
          NVL(SUM(DECODE(line_type,'CHARGES',NVL(AMOUNT_DUE_REMAINING,0))),0) chrg_rem,
        NVL(SUM(DECODE(line_type,'LINE',NVL(FRT_ADJ_REMAINING,0))),0) +
          NVL(SUM(DECODE(line_type,'FREIGHT',NVL(AMOUNT_DUE_REMAINING,0))),0) frt_rem
   FROM ra_customer_trx_lines_gt
  WHERE CUSTOMER_TRX_ID  = p_customer_trx_id
    AND source_data_key1 = p_source_data_key1
	AND source_data_key2 = p_source_data_key2
	AND source_data_key3 = p_source_data_key3
	AND source_data_key4 = p_source_data_key4
	AND source_data_key5 = p_source_data_key5;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.get_latest_amount_remaining()+');
  localdebug('    p_customer_trx_id :'||p_customer_trx_id);
  localdebug('    p_app_level       :'||p_app_level);
  localdebug('    p_source_data_key1:'||p_source_data_key1);
  localdebug('    p_source_data_key2:'||p_source_data_key2);
  localdebug('    p_source_data_key3:'||p_source_data_key3);
  localdebug('    p_source_data_key4:'||p_source_data_key4);
  localdebug('    p_source_data_key5:'||p_source_data_key5);
  localdebug('    p_ctl_id          :'||p_ctl_id);
  END IF;
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


  IF PG_DEBUG = 'Y' THEN
  localdebug('    x_line_rem     :'||x_line_rem);
  localdebug('    x_tax_rem      :'||x_tax_rem);
  localdebug('    x_freight_rem  :'||x_freight_rem);
  localdebug('    x_charges_rem  :'||x_charges_rem);
  localdebug('arp_det_dist_pkg.get_latest_amount_remaining()-');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug('EXCEPTION NO_DATA_FOUND get_latest_amount_remaining:'||SQLERRM);
     END IF;
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'get_latest_amount_remaining NO_DATA_FOUND
 p_customer_trx_id :'||p_customer_trx_id||'
 p_app_level       :'||p_app_level||'
 p_ctl_id          :'||p_ctl_id||'
 p_source_data_key1:'||p_source_data_key1||'
 p_source_data_key2:'||p_source_data_key2||'
 p_source_data_key3:'||p_source_data_key3||'
 p_source_data_key4:'||p_source_data_key4||'
 p_source_data_key5:'||p_source_data_key5);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  WHEN OTHERS THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug('EXCEPTION OTHERS get_latest_amount_remaining:'||SQLERRM);
     END IF;
     FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
     FND_MESSAGE.SET_TOKEN( 'TEXT', 'arp_process_det_pkg.get_latest_amount_remaining-'||SQLERRM );
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_latest_amount_remaining;



PROCEDURE convert_ra_inv_to_cm
( p_inv_ra_rec     IN         ar_receivable_applications%ROWTYPE,
  p_cm_trx_id      IN         NUMBER,
  x_cm_ra_rec      IN OUT NOCOPY ar_receivable_applications%ROWTYPE,
  p_mode           IN         VARCHAR2 DEFAULT 'OLTP',
  p_gt_id          IN         VARCHAR2 DEFAULT NULL,
  p_from_llca      IN         VARCHAR2 DEFAULT 'N',
  p_upg_cm        IN         VARCHAR2 DEFAULT 'N')
IS
CURSOR cu_trx_balance(p_customer_trx_id IN NUMBER)
IS
SELECT a.Line_balance                                  line_balance,
       a.Tax_Balance                                   tax_balance,
       b.Frt_adj + b.Frt_ed + b.Frt_uned + b.Frt_app   freight_balance,
       d.chrg_adj + d.chrg_app                         charges_balance,
       c.invoice_currency_code                         invoice_currency_code
  FROM
      (SELECT SUM(DECODE(line_type,'LINE',amount_due_remaining,0))  Line_Balance
             ,SUM(DECODE(line_type,'TAX',amount_due_remaining,0))   Tax_Balance
             ,customer_trx_id
        FROM ra_customer_trx_lines
       GROUP BY customer_trx_id)      a,
      (SELECT SUM(DECODE(line_type,'LINE', frt_adj_remaining, 0))      Frt_adj,
              SUM(DECODE(line_type,'LINE', frt_ed_amount, 0))          Frt_ed,
              SUM(DECODE(line_type,'LINE', frt_uned_amount, 0))        Frt_uned,
              SUM(DECODE(line_type,'FREIGHT',amount_due_remaining, 0)) Frt_app,
              customer_trx_id
         FROM ra_customer_trx_lines
        GROUP BY customer_trx_id)     b,
      (SELECT SUM(DECODE(line_type,'LINE', chrg_amount_remaining, 0))  chrg_adj,
              SUM(DECODE(line_type,'CHARGES',amount_due_remaining, 0)) chrg_app,
              customer_trx_id
         FROM ra_customer_trx_lines
        GROUP BY customer_trx_id)     d,
       ar_payment_schedules          c
 WHERE b.customer_trx_id = a.customer_trx_id
   AND a.customer_trx_id = c.customer_trx_id
   AND a.customer_trx_id = d.customer_trx_id
   AND c.customer_trx_id = p_customer_trx_id;


CURSOR cu_cm_balance(p_customer_trx_id IN NUMBER, p_gt_id IN VARCHAR2)
IS
SELECT /*+INDEX (a ra_ar_n1) INDEX(ar_base_dist_amts_gt b)*/
       b.base_dist_amt                                 line_balance,
       b.base_dist_tax_amt                             tax_balance,
       b.base_dist_frt_amt                             freight_balance,
       b.base_dist_chrg_amt                            charges_balance,
       a.to_currency                                   invoice_currency_code
  FROM ra_ar_gt a,ar_base_dist_amts_gt b
 WHERE a.ref_customer_trx_id = p_customer_trx_id
     AND b.gt_id    = a.gt_id
     AND b.gp_level = 'D'
     AND a.ref_customer_trx_id = b.ref_customer_trx_id
     AND a.ref_customer_trx_line_id = b.ref_customer_trx_line_id;


CURSOR cu_trx_balance_nlb(p_customer_trx_id IN NUMBER)
IS
SELECT SUM(DECODE(a.line_type, 'LINE', sum_orig,0))       line_balance,
       SUM(DECODE(a.line_type, 'TAX' , sum_orig,0))       tax_balance,
       SUM(DECODE(a.line_type, 'FREIGHT' , sum_orig,0))   freight_balance,
       SUM(DECODE(a.line_type, 'CHARGES' , sum_orig,0))   charges_balance,
       a.invoice_currency_code                       invoice_currency_code
FROM
 (SELECT SUM(ctlgd.AMOUNT)           sum_orig,
         SUM(ctlgd.ACCTD_AMOUNT)     sum_acctd_orig,
         ctl.line_type               line_type,
         ctx.invoice_currency_code   invoice_currency_code
    FROM ra_customer_trx           ctx,
         ra_customer_trx_lines     ctl,
         ra_cust_trx_line_gl_dist  ctlgd
   WHERE ctx.customer_trx_id      = p_customer_trx_id
     AND ctx.customer_trx_id      = ctl.customer_trx_id
     AND ctl.customer_trx_line_id = ctlgd.customer_trx_line_id
   GROUP BY ctx.invoice_currency_code,
            ctl.line_type)   a
GROUP BY a.invoice_currency_code;


--  l_rem_record          cu_trx_balance%ROWTYPE;
  l_rem_line_balance             NUMBER;
  l_rem_tax_balance              NUMBER;
  l_rem_freight_balance          NUMBER;
  l_rem_charges_balance          NUMBER;
  l_rem_invoice_currency_code    VARCHAR2(30);
--

  l_cm_ra_rec           ar_receivable_applications%ROWTYPE;
  l_line_applied        NUMBER;
  l_tax_applied         NUMBER;
  l_freight_applied     NUMBER;
  l_charges_applied     NUMBER;
  l_base                NUMBER;
  l_run_amt             NUMBER;
  l_run_total           NUMBER;
  l_inv_rec             ra_customer_trx%ROWTYPE;
  no_rem_for_trx        EXCEPTION;
  no_amount_remaining   EXCEPTION;
  no_rem_for_trx_upg    EXCEPTION;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.convert_ra_inv_to_cm()+');
  localdebug('  p_cm_trx_id                           :' || p_cm_trx_id);
  localdebug('  p_mode                                :' || p_mode);
  localdebug('  p_inv_ra_rec.amount_applied           :' || p_inv_ra_rec.amount_applied);
  localdebug('  p_inv_ra_rec.amount_applied_from      :' || p_inv_ra_rec.amount_applied_from);
  localdebug('  p_inv_ra_rec.acctd_amount_applied_to  :' || p_inv_ra_rec.acctd_amount_applied_to);
  localdebug('  p_inv_ra_rec.acctd_amount_applied_from:' || p_inv_ra_rec.acctd_amount_applied_from);
  localdebug('  p_inv_ra_rec.line_applied             :' || p_inv_ra_rec.line_applied);
  localdebug('  p_inv_ra_rec.tax_applied              :' || p_inv_ra_rec.tax_applied);
  localdebug('  p_inv_ra_rec.freight_applied          :' || p_inv_ra_rec.freight_applied);
  localdebug('  p_inv_ra_rec.receivables_charges_applied:' || p_inv_ra_rec.receivables_charges_applied);
  localdebug('  p_from_llca                           :' || p_from_llca);
  localdebug('  p_gt_id                               :' || p_gt_id);
  END IF;

  x_cm_ra_rec   := p_inv_ra_rec;

  l_inv_rec.customer_trx_id := p_cm_trx_id;


IF p_mode = 'OLTP' THEN

  arp_det_dist_pkg.set_original_rem_amt
	    (p_customer_trx => l_inv_rec,
         p_app_id       => p_inv_ra_rec.receivable_application_id,
         --{HYUNLB
         p_from_llca    => p_from_llca);
         --}

  set_mode_process(p_customer_trx => l_inv_rec);

  --{HYUNLB
  IF    ( g_mode_process IN('R12_NLB','R12_MERGE') OR
          ( g_mode_process IN('R12_11ICASH') AND p_upg_cm = 'Y' )
        ) THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('opening cu_trx_balance_nlb');
    END IF;

    OPEN cu_trx_balance_nlb(p_cm_trx_id);
      FETCH cu_trx_balance_nlb INTO -- l_rem_record;
            l_rem_line_balance   ,
            l_rem_tax_balance    ,
            l_rem_freight_balance,
            l_rem_charges_balance,
            l_rem_invoice_currency_code;

      IF cu_trx_balance_nlb%NOTFOUND THEN
        RAISE no_rem_for_trx;
      END IF;
    CLOSE cu_trx_balance_nlb;
    IF PG_DEBUG = 'Y' THEN
    localdebug('closing cu_trx_balance_nlb');
    END IF;
  --}
  ELSIF     g_mode_process IN ('R12','R12_11IMFAR') THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('opening cu_trx_balance');
    END IF;

    OPEN cu_trx_balance(p_cm_trx_id);
      FETCH cu_trx_balance INTO -- l_rem_record;
            l_rem_line_balance   ,
            l_rem_tax_balance    ,
            l_rem_freight_balance,
            l_rem_charges_balance,
            l_rem_invoice_currency_code;

      IF cu_trx_balance%NOTFOUND THEN
        RAISE no_rem_for_trx;
      END IF;
    CLOSE cu_trx_balance;
    IF PG_DEBUG = 'Y' THEN
    localdebug('closing cu_trx_balance');
    END IF;

  ELSIF  g_mode_process IN ('R12_11ICASH') and p_upg_cm = 'N' THEN

    IF PG_DEBUG = 'Y' THEN
    localdebug('opening cu_cm_balance');
    END IF;

    OPEN cu_cm_balance(p_cm_trx_id , p_gt_id) ;
      FETCH cu_cm_balance INTO -- l_rem_record;
            l_rem_line_balance   ,
            l_rem_tax_balance    ,
            l_rem_freight_balance,
            l_rem_charges_balance,
            l_rem_invoice_currency_code;

      IF cu_cm_balance%NOTFOUND THEN
        RAISE no_rem_for_trx;
      END IF;
    CLOSE cu_cm_balance;

    IF PG_DEBUG = 'Y' THEN
    localdebug('close cu_cm_balance');
    END IF;

  END IF;

ELSIF p_mode = 'BATCH' THEN

    IF PG_DEBUG = 'Y' THEN
    localdebug('opening cu_cm_balance for batch mode');
    END IF;

    OPEN cu_cm_balance(p_cm_trx_id , p_gt_id) ;
      FETCH cu_cm_balance INTO -- l_rem_record;
            l_rem_line_balance   ,
            l_rem_tax_balance    ,
            l_rem_freight_balance,
            l_rem_charges_balance,
            l_rem_invoice_currency_code;

      IF cu_cm_balance%NOTFOUND THEN
        RAISE no_rem_for_trx_upg;
      END IF;
    CLOSE cu_cm_balance;

    IF PG_DEBUG = 'Y' THEN
    localdebug('close cu_cm_balance batch mode');
    END IF;

END IF;


  x_cm_ra_rec.amount_applied            := p_inv_ra_rec.amount_applied * -1;
  x_cm_ra_rec.amount_applied_from       := p_inv_ra_rec.amount_applied_from * -1;
  x_cm_ra_rec.acctd_amount_applied_to   := p_inv_ra_rec.acctd_amount_applied_to * -1;
  x_cm_ra_rec.acctd_amount_applied_from := p_inv_ra_rec.acctd_amount_applied_from * -1;
  --
  l_base                                := NVL(l_rem_line_balance,0) +
                                           NVL(l_rem_tax_balance,0)  +
                                           NVL(l_rem_freight_balance,0) +
                                           NVL(l_rem_charges_balance,0);
  --
  IF l_base = 0 THEN
    RAISE no_amount_remaining;
  END IF;
  --
  --
  l_run_amt      := 0;
  l_run_total    := 0;

  -- line_applied
  IF PG_DEBUG = 'Y' THEN
  localdebug('LINE_APPLIED:');
  localdebug(' l_run_amt                            :' || l_run_amt);
  localdebug(' l_run_total                          :' || l_run_total);
  localdebug(' l_rem_line_balance                   :' || NVL(l_rem_line_balance,0));
  localdebug(' p_inv_ra_rec.amount_applied          :' || NVL(p_inv_ra_rec.amount_applied,0));
  localdebug(' l_base                               :' || l_base);
  END IF;
  l_run_amt      := l_run_amt + NVL(l_rem_line_balance,0);
  l_line_applied := CurrRound( l_run_amt * NVL(p_inv_ra_rec.amount_applied,0)
                                      / l_base,  l_rem_invoice_currency_code ) - l_run_total;
  l_run_total    := l_run_total + l_line_applied;
  IF PG_DEBUG = 'Y' THEN
  localdebug(' l_line_applied                        :' || l_line_applied);



  -- tax_applied
  localdebug('TAX_APPLIED:');
  localdebug(' l_run_amt                            :' || l_run_amt);
  localdebug(' l_run_total                          :' || l_run_total);
  localdebug(' l_rem_tax_balance                    :' || NVL(l_rem_tax_balance,0));
  localdebug(' p_inv_ra_rec.amount_applied          :' || NVL(p_inv_ra_rec.amount_applied,0));
  localdebug(' l_base                               :' || l_base);
  END IF;

  l_run_amt      := l_run_amt + NVL(l_rem_tax_balance,0);
  l_tax_applied  := CurrRound( l_run_amt  * NVL(p_inv_ra_rec.amount_applied,0)
                                     / l_base ,  l_rem_invoice_currency_code ) - l_run_total;
  l_run_total    := l_run_total + l_tax_applied;
  IF PG_DEBUG = 'Y' THEN
  localdebug(' l_tax_applied                        :' || l_tax_applied);



  -- freight_applied
  localdebug('FREIGHT_APPLIED:');
  localdebug(' l_run_amt                            :' || l_run_amt);
  localdebug(' l_run_total                          :' || l_run_total);
  localdebug(' l_rem_freight_balance                :' || NVL(l_rem_freight_balance,0));
  localdebug(' p_inv_ra_rec.amount_applied          :' || NVL(p_inv_ra_rec.amount_applied,0));
  localdebug(' l_base                               :' || l_base);
  END IF;

  l_run_amt      := l_run_amt + NVL(l_rem_freight_balance,0);
  l_freight_applied  := CurrRound( l_run_amt * NVL(p_inv_ra_rec.amount_applied,0)
                                          / l_base ,  l_rem_invoice_currency_code ) - l_run_total;
  l_run_total    := l_run_total + l_freight_applied;
  IF PG_DEBUG = 'Y' THEN
  localdebug(' l_freight_applied                        :' || l_freight_applied);



  -- Charges_applied
  localdebug('CHARGES_APPLIED:');
  localdebug(' l_run_amt                            :' || l_run_amt);
  localdebug(' l_run_total                          :' || l_run_total);
  localdebug(' l_rem_charges_balance                :' || NVL(l_rem_charges_balance,0));
  localdebug(' p_inv_ra_rec.amount_applied          :' || NVL(p_inv_ra_rec.amount_applied,0));
  localdebug(' l_base                               :' || l_base);
  END IF;
  l_run_amt      := l_run_amt + NVL(l_rem_charges_balance,0);
  l_charges_applied  := CurrRound( l_run_amt * NVL(p_inv_ra_rec.amount_applied,0)
                                          / l_base ,  l_rem_invoice_currency_code ) - l_run_total;
  l_run_total    := l_run_total + l_charges_applied;
  IF PG_DEBUG = 'Y' THEN
  localdebug(' l_charges_applied                        :' || l_charges_applied);
  END IF;


  x_cm_ra_rec.line_applied       := l_line_applied    * -1;
  x_cm_ra_rec.tax_applied        := l_tax_applied     * -1;
  x_cm_ra_rec.freight_applied    := l_freight_applied * -1;
  x_cm_ra_rec.receivables_charges_applied := l_charges_applied * -1;

  IF PG_DEBUG = 'Y' THEN
  localdebug('  x_cm_ra_rec.amount_applied              :'||x_cm_ra_rec.amount_applied);
  localdebug('  x_cm_ra_rec.amount_applied_from         :'||x_cm_ra_rec.amount_applied_from);
  localdebug('  x_cm_ra_rec.acctd_amount_applied_to     :'||x_cm_ra_rec.acctd_amount_applied_to);
  localdebug('  x_cm_ra_rec.acctd_amount_applied_from   :'||x_cm_ra_rec.acctd_amount_applied_from);
  localdebug('  x_cm_ra_rec.line_applied                :'||x_cm_ra_rec.line_applied);
  localdebug('  x_cm_ra_rec.tax_applied                 :'||x_cm_ra_rec.tax_applied);
  localdebug('  x_cm_ra_rec.freight_applied             :'||x_cm_ra_rec.freight_applied);
  localdebug('  x_cm_ra_rec.receivables_charges_applied :'||x_cm_ra_rec.receivables_charges_applied);

  localdebug('arp_det_dist_pkg.convert_ra_inv_to_cm()-');
  END IF;
EXCEPTION
  WHEN  no_rem_for_trx_upg  THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug(' EXCEPTION no_rem_for_trx :'|| p_cm_trx_id);
     END IF;
     IF cu_cm_balance%ISOPEN THEN CLOSE cu_cm_balance; END IF;

  WHEN  no_rem_for_trx  THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug(' EXCEPTION no_rem_for_trx :'|| p_cm_trx_id);
     END IF;
     IF cu_trx_balance%ISOPEN THEN CLOSE cu_trx_balance; END IF;
     RAISE;
  WHEN no_amount_remaining   THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug(' EXCEPTION NO_AMOUNT_REMAINING FOR :'|| p_cm_trx_id);
     END IF;
     IF cu_trx_balance%ISOPEN THEN CLOSE cu_trx_balance; END IF;
     RAISE;
  WHEN OTHERS THEN
     IF PG_DEBUG = 'Y' THEN
     localdebug(' EXCEPTION OTHERS :'|| SQLERRM);
     END IF;
     IF cu_trx_balance%ISOPEN THEN CLOSE cu_trx_balance; END IF;
     RAISE;
END convert_ra_inv_to_cm;

PROCEDURE set_interface_flag
( p_source_table     IN VARCHAR2 DEFAULT NULL,
  p_line_flag        IN VARCHAR2 DEFAULT 'NORMAL',
  p_tax_flag         IN VARCHAR2 DEFAULT 'NORMAL',
  p_freight_flag     IN VARCHAR2 DEFAULT 'NORMAL',
  p_charges_flag     IN VARCHAR2 DEFAULT 'NORMAL',
  p_ed_line_flag     IN VARCHAR2 DEFAULT 'NORMAL',
  p_ed_tax_flag      IN VARCHAR2 DEFAULT 'NORMAL',
  p_uned_line_flag   IN VARCHAR2 DEFAULT 'NORMAL',
  p_uned_tax_flag    IN VARCHAR2 DEFAULT 'NORMAL')
IS
BEGIN
  g_source_table     := p_source_table;
  g_line_flag        := p_line_flag;
  g_tax_flag         := p_tax_flag;
  g_freight_flag     := p_freight_flag;
  g_charges_flag     := p_charges_flag;
  g_ed_line_flag     := p_ed_line_flag;
  g_ed_tax_flag      := p_ed_tax_flag;
  g_uned_line_flag   := p_uned_line_flag;
  g_uned_tax_flag    := p_uned_tax_flag;
END set_interface_flag;

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
 p_llca_from_call   IN VARCHAR2 DEFAULT NULL,
 p_customer_trx_line_id IN ra_customer_trx_lines.customer_trx_line_id%TYPE DEFAULT NULL)
IS
  l_app_rec        ar_receivable_applications%ROWTYPE;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.adjustment_with_interface()+');
  localdebug('  p_gt_id                              :'||p_gt_id);
  localdebug('  p_adj_rec.amount                     :'|| p_adj_rec.amount);
  localdebug('  p_adj_rec.acctd_amount               :'|| p_adj_rec.acctd_amount);
  localdebug('  p_customer_trx.invoice_currency_code :'|| p_customer_trx.invoice_currency_code);
  localdebug('  p_ae_sys_rec.base_currency           :'|| p_ae_sys_rec.base_currency);
  localdebug('  p_llca_from_call                     :'|| p_llca_from_call);
  END IF;

  x_return_status   := fnd_api.g_ret_sts_success;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  arp_process_det_pkg.verif_int_adj_line_tax(
       p_customer_trx  => p_customer_trx,
       p_adj_rec       => p_adj_rec,
       p_ae_sys_rec    => p_ae_sys_rec,
       p_gt_id         => p_gt_id,
       p_line_flag     => p_line_flag,
       p_tax_flag      => p_tax_flag,
       x_return_status => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  g_gt_id    := p_gt_id;

  set_interface_flag( p_source_table     => 'ADJ',
                      p_line_flag        => p_line_flag,
                      p_tax_flag         => p_tax_flag);

  g_cust_inv_rec   := p_customer_trx;

  set_mode_process(p_customer_trx  => g_cust_inv_rec);

    -- Added under Line Level Adjustment
 IF p_llca_from_call = 'Y' THEN
  set_original_rem_amt(
                 p_customer_trx => g_cust_inv_rec,
                 p_from_llca    => 'Y');
 END IF;

  copy_trx_lines(p_customer_trx_id  => p_customer_trx.customer_trx_id,
                 p_ae_sys_rec       => p_ae_sys_rec,
		 p_customer_trx_line_id => p_customer_trx_line_id);

  conv_acctd_amt(p_pay_adj         => 'ADJ',
                 p_adj_rec         => p_adj_rec,
                 p_app_rec         => l_app_rec,
                 p_ae_sys_rec      => p_ae_sys_rec);

  get_invoice_line_info(p_gt_id            => p_gt_id,
                        p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                        p_ae_sys_rec       => p_ae_sys_rec,
                        p_mode             => 'NORMAL');

  prepare_group_for_proration(p_gt_id           => p_gt_id,
                              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                              p_pay_adj         => 'ADJ',
                              p_adj_rec         => p_adj_rec,
                              p_app_rec         => l_app_rec,
                              p_ae_sys_rec      => p_ae_sys_rec);

  update_group_line(p_gt_id           => p_gt_id,
                    p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                    p_ae_sys_rec      => p_ae_sys_rec);

  prepare_trx_line_proration(p_gt_id           => p_gt_id,
                             p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                             p_pay_adj         => 'ADJ',
                             p_adj_rec         => p_adj_rec,
                             p_app_rec         => l_app_rec,
                             p_ae_sys_rec      => p_ae_sys_rec);

   update_line(p_gt_id           => p_gt_id,
               p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
               p_ae_sys_rec      => p_ae_sys_rec);

   update_ctl_rem_orig(p_gt_id           => p_gt_id,
                       p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                       p_pay_adj         => 'ADJ',
                       p_ae_sys_rec      => p_ae_sys_rec);

   proration_adj_dist_trx(p_gt_id            => p_gt_id,
                          p_app_level        => 'TRANSACTION',
                          p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                          p_adj_rec          => p_adj_rec,
                          p_ae_sys_rec       => p_ae_sys_rec);

  create_final_split(p_customer_trx => p_customer_trx,
                     p_app_rec      => l_app_rec,
                     p_adj_rec      => p_adj_rec,
                     p_ae_sys_rec   => p_ae_sys_rec);

 -- Added under Line Level Adjustment
  IF p_llca_from_call = 'Y' THEN
  final_update_inv_ctl_rem_orig(p_customer_trx => p_customer_trx);
  END IF;

  IF g_mode_process IN ('R12_MERGE') THEN
     UPDATE ar_adjustments
     SET upgrade_method = 'R12_MERGE'
     WHERE adjustment_id = p_adj_rec.adjustment_id;
  ELSE
    UPDATE ar_adjustments
    SET upgrade_method = 'R12'
    WHERE adjustment_id = p_adj_rec.adjustment_id;
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.adjustment_with_interface()-');
  END IF;
EXCEPTION
  WHEN fnd_api.G_EXC_ERROR THEN
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
    IF PG_DEBUG = 'Y' THEN
    localdebug('fnd_api.G_EXC_ERROR IN adjustment_with_interface error count:'||x_msg_count);
    localdebug('last error:'||x_msg_data);
    END IF;
    RAISE;
 WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('OTHERS IN adjustment_with_interface :'||SQLERRM);
  END IF;
  RAISE;
END;


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
   x_msg_data         IN OUT NOCOPY VARCHAR2)
IS
  l_adj_rec         ar_adjustments%ROWTYPE;
BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.application_with_interface()+');
  localdebug('   p_customer_trx_id        :'||p_customer_trx.customer_trx_id);
  localdebug('   p_gt_id                  :'||p_gt_id);
  END IF;

  x_return_status   := fnd_api.g_ret_sts_success;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  arp_process_det_pkg.verif_int_app_line_tax
   (p_customer_trx     => p_customer_trx,
    p_app_rec          => p_app_rec,
    p_ae_sys_rec       => p_ae_sys_rec,
    p_gt_id            => p_gt_id,
    p_line_flag        => p_line_flag,
    p_tax_flag         => p_tax_flag,
    p_ed_line_flag     => p_ed_line_flag,
    p_ed_tax_flag      => p_ed_tax_flag,
    p_uned_line_flag   => p_uned_line_flag,
    p_uned_tax_flag    => p_uned_tax_flag,
    x_return_status    => x_return_status);

  IF x_return_status <> fnd_api.g_ret_sts_success THEN
    RAISE fnd_api.G_EXC_ERROR;
  END IF;

  g_gt_id    := p_gt_id;

  set_interface_flag( p_source_table     => 'RA',
                      p_line_flag        => p_line_flag,
                      p_tax_flag         => p_tax_flag,
                      p_ed_line_flag     => p_ed_line_flag,
                      p_ed_tax_flag      => p_ed_tax_flag,
                      p_uned_line_flag   => p_uned_line_flag,
                      p_uned_tax_flag    => p_uned_tax_flag );

  g_cust_inv_rec    :=  p_customer_trx;

  set_mode_process(p_customer_trx  => g_cust_inv_rec);

  IF g_mode_process = 'R12_11ICASH' THEN
    IF PG_DEBUG = 'Y' THEN
    localdebug('application_with_interface is not supported for 11i transaction with activities');
    END IF;
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
    FND_MESSAGE.SET_TOKEN('TEXT','application_with_interface is not supported for 11i transaction with activities customer_trx_id :'||
                                 p_customer_trx.customer_trx_id);
    FND_MSG_PUB.ADD;
    x_return_status := fnd_api.g_ret_sts_success;
    RAISE fnd_api.G_EXC_ERROR;
  ELSE

   copy_trx_lines(p_customer_trx_id  => p_customer_trx.customer_trx_id,
                  p_ae_sys_rec       => p_ae_sys_rec);


    IF g_mode_process = 'R12_11IMFAR' THEN

      x_return_status := fnd_api.g_ret_sts_success;
      IF PG_DEBUG = 'Y' THEN
      localdebug('application_with_interface is not supported for 11i MFAR transaction with activities');
      END IF;
      FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT','application_with_interface is not supported for 11i MFAR transaction with activities customer_trx_id :'||
                                 p_customer_trx.customer_trx_id);
      FND_MSG_PUB.ADD;
      RAISE fnd_api.G_EXC_ERROR;

    END IF;
    --}

   conv_acctd_amt(p_pay_adj         => 'APP',
                   p_adj_rec         => l_adj_rec,
                   p_app_rec         => p_app_rec,
                   p_ae_sys_rec      => p_ae_sys_rec);


   get_invoice_line_info(p_gt_id            => p_gt_id,
                         p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                         p_ae_sys_rec       => p_ae_sys_rec,
                         p_mode             => 'NORMAL');

   prepare_group_for_proration(p_gt_id           => p_gt_id,
                               p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                               p_pay_adj         => 'APP',
                               p_adj_rec         => l_adj_rec,
                               p_app_rec         => p_app_rec,
                               p_ae_sys_rec      => p_ae_sys_rec);

   update_group_line(p_gt_id           => p_gt_id,
                     p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                     p_ae_sys_rec      => p_ae_sys_rec);

   prepare_trx_line_proration(p_gt_id           => p_gt_id,
                              p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                              p_pay_adj         => 'APP',
                              p_adj_rec         => l_adj_rec,
                              p_app_rec         => p_app_rec,
                              p_ae_sys_rec      => p_ae_sys_rec);

   update_line(p_gt_id           => p_gt_id,
               p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
               p_ae_sys_rec      => p_ae_sys_rec);

   update_ctl_rem_orig(p_gt_id           => p_gt_id,
                       p_customer_trx_id => g_cust_inv_rec.customer_trx_id,
                       p_pay_adj         => 'APP',
                       p_ae_sys_rec      => p_ae_sys_rec);

   proration_app_dist_trx(p_gt_id            => p_gt_id,
                          p_app_level        => 'TRANSACTION',
                          p_customer_trx_id  => g_cust_inv_rec.customer_trx_id,
                          p_app_rec          => p_app_rec,
                          p_ae_sys_rec       => p_ae_sys_rec);


 END IF;

 create_final_split(p_customer_trx => p_customer_trx,
                    p_app_rec      => p_app_rec,
                    p_adj_rec      => l_adj_rec,
                    p_ae_sys_rec   => p_ae_sys_rec);


 IF PG_DEBUG = 'Y' THEN
 localdebug('arp_det_dist_pkg.application_with_interface()-');
 END IF;
EXCEPTION
 WHEN fnd_api.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
  IF PG_DEBUG = 'Y' THEN
  localdebug('fnd_api.G_EXC_ERROR IN application_with_interface error count:'||x_msg_count);
  localdebug('last error:'||x_msg_data);
  END IF;
  RAISE;
 WHEN OTHERS THEN
  IF PG_DEBUG = 'Y' THEN
  localdebug('OTHERS IN application_with_interface :'||SQLERRM);
  END IF;
  RAISE;
END application_with_interface;




PROCEDURE Reconciliation
(p_app_rec             IN ar_receivable_applications%ROWTYPE,
 p_adj_rec             IN ar_adjustments%ROWTYPE,
 p_activity_type       IN VARCHAR2,
 p_gt_id               IN VARCHAR2 DEFAULT NULL)
IS
  CURSOR cu1(p_gt_id IN NUMBER) IS
  SELECT SUM(NVL(amount,0)),
         SUM(NVL(acctd_amount,0))
    FROM AR_LINE_APP_DETAIL_GT
   WHERE gt_id = p_gt_id;
  l_sum                    NUMBER;
  l_acctd_sum              NUMBER;

  CURSOR cu2(p_gt_id IN NUMBER) IS
  SELECT SUM(NVL(amount,0)),
         SUM(NVL(acctd_amount,0)),
         activity_bucket
    FROM AR_LINE_APP_DETAIL_GT
   WHERE gt_id = p_gt_id
   GROUP BY activity_bucket;
  l_activity              VARCHAR2(30);
  l_act_amount            NUMBER;
  l_acctd_act_amount      NUMBER;
  l_gt_id                 NUMBER;

  l_adj_amt               NUMBER := 0;
  l_adj_acctd_amt         NUMBER := 0;
  l_app_amt               NUMBER := 0;
  l_app_acctd_amt         NUMBER := 0;
  l_ed_amt                NUMBER := 0;
  l_ed_acctd_amt          NUMBER := 0;
  l_uned_amt              NUMBER := 0;
  l_uned_acctd_amt        NUMBER := 0;


  l_amt_tab         DBMS_SQL.NUMBER_TABLE;
  l_acctd_amt_tab   DBMS_SQL.NUMBER_TABLE;
  l_activity_tab    DBMS_SQL.VARCHAR2_TABLE;

  l_check_precision	VARCHAR2(1) := 'N';
  l_acctd_amt_sum	NUMBER;

BEGIN
  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.reconciliation()+');
  END IF;

  IF   p_gt_id IS NULL THEN
    l_gt_id := g_gt_id;
  ELSE
    l_gt_id := p_gt_id;
  END IF;

  localdebug('  l_gt_id :'||l_gt_id);

  OPEN cu1(l_gt_id);
  FETCH cu1 INTO l_sum, l_acctd_sum;
  CLOSE cu1;

  IF PG_DEBUG = 'Y' THEN
  localdebug('Reconciliation gross amount');
  END IF;
  IF     p_activity_type = 'RA' THEN
    IF     ABS(nvl(l_sum,0)) <> ABS(  NVL(p_app_rec.amount_applied,0)
                             + NVL(p_app_rec.earned_discount_taken,0)
                             + NVL(p_app_rec.unearned_discount_taken,0) )
    THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the amount l_sum   :'||l_sum);
      localdebug('application record the amount_applied :'||p_app_rec.amount_applied);
      localdebug('application record the amount_earned  :'||p_app_rec.earned_discount_taken);
      localdebug('application record the amount_unearned:'||p_app_rec.unearned_discount_taken);
      localdebug('Gross transaction amount do not reconcile');
      END IF;
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF  ABS(nvl(l_acctd_sum,0)) <> ABS(NVL(p_app_rec.acctd_amount_applied_to,0)
	                            +  NVL(p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN,0)
                                +  NVL(p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN,0)  ) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the acctd_amount l_acctd_sum  :'||l_acctd_sum);
      localdebug('application record the acctd_amount_applied:'||p_app_rec.acctd_amount_applied_to);
      localdebug('application record the acctd_amount_earned :'||p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN);
      localdebug('application record the acctd_amount_unearned:'||p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN);
      localdebug('Gross transaction acctd amount do not reconcile');
      END IF;
        l_check_precision := 'Y';
	l_acctd_amt_sum := ABS(NVL(p_app_rec.acctd_amount_applied_to,0)
	                            +  NVL(p_app_rec.ACCTD_UNEARNED_DISCOUNT_TAKEN,0)
                                +  NVL(p_app_rec.ACCTD_EARNED_DISCOUNT_TAKEN,0));

      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;
  ELSIF p_activity_type = 'ADJ' THEN
    IF     ABS(nvl(l_sum,0)) <> ABS(NVL(p_adj_rec.amount,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the amount l_sum  :'||l_sum);
      localdebug('adjustment record the amount:'||p_adj_rec.amount);
      localdebug('Gross transaction amount do not reconcile');
      END IF;
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF  ABS(nvl(l_acctd_sum,0)) <> ABS(NVL(p_adj_rec.acctd_amount,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the acctd_amount l_acctd_sum  :'||l_acctd_sum);
      localdebug('adjustment record the acctd_amount:'||p_adj_rec.acctd_amount);
      localdebug('Gross transaction acctd amount do not reconcile');
      END IF;
      l_check_precision := 'Y';
      l_acctd_amt_sum := ABS(NVL(p_adj_rec.acctd_amount,0));
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  IF p_activity_type = 'RA' THEN

    IF PG_DEBUG = 'Y' THEN
    localdebug('Reconciliation per bucket application amount');
    END IF;
    OPEN cu2(l_gt_id);
    FETCH cu2 BULK COLLECT INTO
       l_amt_tab     ,
       l_acctd_amt_tab,
       l_activity_tab;
    CLOSE cu2;

    IF l_activity_tab.COUNT <> 0 THEN

      FOR i IN l_activity_tab.FIRST .. l_activity_tab.LAST LOOP
        IF    l_activity_tab(i) IN ('APP_LINE','APP_TAX','APP_FRT','APP_CHRG') THEN
          l_app_amt       := l_app_amt + NVL(l_amt_tab(i),0);
          l_app_acctd_amt := l_app_acctd_amt + NVL(l_acctd_amt_tab(i),0);
        ELSIF l_activity_tab(i) IN ('ED_LINE','ED_FRT','ED_TAX','ED_CHRG') THEN
          l_ed_amt       := l_ed_amt + NVL(l_amt_tab(i),0);
          l_ed_acctd_amt := l_ed_acctd_amt + NVL(l_acctd_amt_tab(i),0);
        ELSIF l_activity_tab(i) IN ('UNED_LINE','UNED_FRT','UNED_TAX','UNED_CHRG') THEN
          l_uned_amt       := l_uned_amt + NVL(l_amt_tab(i),0);
          l_uned_acctd_amt := l_uned_acctd_amt + NVL(l_acctd_amt_tab(i),0);
        END IF;
      END LOOP;

    IF     ABS(l_app_amt) <> ABS(  NVL(p_app_rec.amount_applied,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the applied amount l_app_amt   :'||l_app_amt);
      localdebug('application record the amount_applied :'||p_app_rec.amount_applied);
      END IF;
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF  ABS(l_ed_amt) <> ABS(  NVL(p_app_rec.earned_discount_taken,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the ed amount l_ed_amt   :'||l_ed_amt);
      localdebug('application record the amount_earned :'||p_app_rec.earned_discount_taken);
      END IF;
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF  ABS(l_uned_amt) <> ABS(  NVL(p_app_rec.unearned_discount_taken,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the uned amount l_uned_amt  :'||l_uned_amt);
      localdebug('application record the amount_unearned:'||p_app_rec.unearned_discount_taken);
      END IF;
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF  ABS(l_app_acctd_amt) <> ABS(NVL(p_app_rec.acctd_amount_applied_to,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the applied amount l_app_acctd_amt   :'||l_app_acctd_amt);
      localdebug('application record the acctd_amount_applied :'||p_app_rec.acctd_amount_applied_to);
      END IF;
      l_check_precision := 'Y';
      l_acctd_amt_sum := ABS(NVL(p_app_rec.acctd_amount_applied_to,0));
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF  ABS(l_ed_acctd_amt) <> ABS(  NVL(p_app_rec.acctd_earned_discount_taken,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the ed amount l_ed_acctd_amt  :'||l_ed_acctd_amt);
      localdebug('application record the acctd_amount_earned :'||p_app_rec.acctd_earned_discount_taken);
      END IF;
      l_check_precision := 'Y';
      l_acctd_amt_sum := ABS(NVL(p_app_rec.acctd_earned_discount_taken,0));
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF  ABS(l_uned_acctd_amt) <> ABS(  NVL(p_app_rec.acctd_unearned_discount_taken,0)) THEN
      IF PG_DEBUG = 'Y' THEN
      localdebug('From the detail gt the ed amount l_uned_acctd_amt  :'||l_uned_acctd_amt);
      localdebug('application record the acctd_amount_unearned :'||p_app_rec.acctd_unearned_discount_taken);
      END IF;
      l_check_precision := 'Y';
      l_acctd_amt_sum := ABS(NVL(p_app_rec.acctd_unearned_discount_taken,0));
      RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    END IF;
  END IF;

  IF PG_DEBUG = 'Y' THEN
  localdebug('arp_det_dist_pkg.reconciliation()-');
  END IF;
EXCEPTION
WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
    IF NVL(l_check_precision, 'N') = 'Y' THEN
	IF PG_DEBUG = 'Y' THEN
	    localdebug('Checking for currency precision error');
	END IF;

	IF ARP_BALANCE_CHECK.CHECK_PRECISION (l_acctd_amt_sum) THEN
           FND_MESSAGE.SET_NAME( 'AR', 'AR_APP_CURR_PRECISION' );
           APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

	RAISE;
    END IF;
 RAISE;
END;

PROCEDURE verify_stamp_merge_dist_method(p_customer_trx_id IN NUMBER,
					 x_upg_method      IN OUT NOCOPY VARCHAR2) IS
BEGIN
  IF PG_DEBUG = 'Y' THEN
    localdebug('arp_det_dist_pkg.verify_stamp_merge_dist_method()+');
    localdebug('p_customer_trx_id         :'||p_customer_trx_id);
    localdebug('x_upg_method              :'||x_upg_method);
  END IF;

  IF p_customer_trx_id IS NULL THEN
    IF PG_DEBUG = 'Y' THEN
      localdebug('p_customer_trx_id is null,returning....');
      localdebug('arp_det_dist_pkg.verify_stamp_merge_dist_method()-');
    END IF;
    RETURN;
  END IF;

  IF x_upg_method IS NULL THEN
    SELECT upgrade_method
    INTO x_upg_method
    FROM ra_customer_trx
    where customer_trx_id = p_customer_trx_id;

    IF PG_DEBUG = 'Y' THEN
      localdebug('x_upg_method from db :'||x_upg_method);
    END IF;
  END IF;

  IF x_upg_method IS NULL AND
     (nvl(arp_standard.sysparm.create_detailed_dist_flag,'Y') = 'N' ) THEN

    update ra_customer_trx
    set upgrade_method = 'R12_MERGE'
    where customer_trx_id = p_customer_trx_id;

    x_upg_method := 'R12_MERGE';
  END IF;

  IF PG_DEBUG = 'Y' THEN
    localdebug('x_upg_method  '||x_upg_method);
    localdebug('arp_det_dist_pkg.verify_stamp_merge_dist_method()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      localdebug('Exception  verify_stamp_merge_dist_method '||SQLERRM);
      RAISE;
END verify_stamp_merge_dist_method;


PROCEDURE diag_data(p_gt_id  IN NUMBER DEFAULT NULL)
IS
  l_gt_id NUMBER;
CURSOR c(l_gt_id IN NUMBER) IS
SELECT
  FROM_AMOUNT,
  FROM_CURRENCY,
  GROUP_ID,
  GT_ID,
  LAST_UPDATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATE_LOGIN,
  LEDGER_ID,
  LINE_ID,
  ORG_ID,
  REF_CUSTOMER_TRX_ID,
  REF_CUSTOMER_TRX_LINE_ID,
  REF_CUST_TRX_LINE_GL_DIST_ID,
  REF_DET_ID,
  REF_LINE_ID,
  SE_GT_ID,
  SOURCE_DATA_KEY1,
  SOURCE_DATA_KEY2,
  SOURCE_DATA_KEY3,
  SOURCE_DATA_KEY4,
  SOURCE_DATA_KEY5,
  SOURCE_ID,
  SOURCE_TABLE,
  SOURCE_TYPE,
  TAXABLE_ACCTD_AMOUNT,
  TAXABLE_AMOUNT,
  TAX_INC_FLAG,
  TAX_LINK_ID,
  TO_CURRENCY,
  REF_MF_DIST_FLAG,
  ACCTD_AMOUNT,
  REF_ACCOUNT_CLASS,
  AMOUNT,
  APP_LEVEL,
  BASE_CURRENCY,
  ACTIVITY_BUCKET,
  CCID,
  CCID_SECONDARY,
  CREATED_BY,
  CREATION_DATE,
  DET_ID,
  FROM_ACCTD_AMOUNT
  FROM AR_LINE_APP_DETAIL_GT
  WHERE GT_ID = l_gt_id;

  l  c%ROWTYPE;
l_text   VARCHAR2(4000);

BEGIN
  IF   p_gt_id IS NULL THEN
    l_gt_id := g_gt_id;
  ELSE
    l_gt_id := p_gt_id;
  END IF;
/*
  INSERT INTO AR_LINE_APP_DETAIL_TMP
  (ACCTD_AMOUNT            ,
   REF_ACCOUNT_CLASS       ,
   AMOUNT                  ,
   APP_LEVEL               ,
   BASE_CURRENCY           ,
   ACTIVITY_BUCKET         ,
   CCID                    ,
   CCID_SECONDARY          ,
   CREATED_BY              ,
   CREATION_DATE           ,
   DET_ID                  ,
   FROM_ACCTD_AMOUNT       ,
   FROM_AMOUNT             ,
   FROM_CURRENCY           ,
   GROUP_ID                ,
   GT_ID                   ,
   LAST_UPDATED_BY         ,
   LAST_UPDATE_DATE        ,
   LAST_UPDATE_LOGIN       ,
   LEDGER_ID               ,
   LINE_ID                 ,
   ORG_ID                  ,
   REF_CUSTOMER_TRX_ID     ,
   REF_CUSTOMER_TRX_LINE_ID,
   REF_CUST_TRX_LINE_GL_DIST_ID,
   REF_DET_ID              ,
   REF_LINE_ID             ,
   SE_GT_ID                ,
   SOURCE_DATA_KEY1        ,
   SOURCE_DATA_KEY2        ,
   SOURCE_DATA_KEY3        ,
   SOURCE_DATA_KEY4        ,
   SOURCE_DATA_KEY5        ,
   SOURCE_ID               ,
   SOURCE_TABLE            ,
   SOURCE_TYPE             ,
   TAXABLE_ACCTD_AMOUNT    ,
   TAXABLE_AMOUNT          ,
   TAX_INC_FLAG            ,
   TAX_LINK_ID             ,
   TO_CURRENCY             ,
   REF_MF_DIST_FLAG        )
  SELECT
   ACCTD_AMOUNT            ,
   REF_ACCOUNT_CLASS       ,
   AMOUNT                  ,
   APP_LEVEL               ,
   BASE_CURRENCY           ,
   ACTIVITY_BUCKET         ,
   CCID                    ,
   CCID_SECONDARY          ,
   CREATED_BY              ,
   CREATION_DATE           ,
   DET_ID                  ,
   FROM_ACCTD_AMOUNT       ,
   FROM_AMOUNT             ,
   FROM_CURRENCY           ,
   GROUP_ID                ,
   GT_ID                   ,
   LAST_UPDATED_BY         ,
   LAST_UPDATE_DATE        ,
   LAST_UPDATE_LOGIN       ,
   LEDGER_ID               ,
   LINE_ID                 ,
   ORG_ID                  ,
   REF_CUSTOMER_TRX_ID     ,
   REF_CUSTOMER_TRX_LINE_ID,
   REF_CUST_TRX_LINE_GL_DIST_ID,
   REF_DET_ID              ,
   REF_LINE_ID             ,
   SE_GT_ID                ,
   SOURCE_DATA_KEY1        ,
   SOURCE_DATA_KEY2        ,
   SOURCE_DATA_KEY3        ,
   SOURCE_DATA_KEY4        ,
   SOURCE_DATA_KEY5        ,
   SOURCE_ID               ,
   SOURCE_TABLE            ,
   SOURCE_TYPE             ,
   TAXABLE_ACCTD_AMOUNT    ,
   TAXABLE_AMOUNT          ,
   TAX_INC_FLAG            ,
   TAX_LINK_ID             ,
   TO_CURRENCY             ,
   REF_MF_DIST_FLAG
  FROM AR_LINE_APP_DETAIL_GT
  WHERE GT_ID = l_gt_id;

  INSERT INTO ra_ar_tmp
  (ACCOUNT_CLASS               ,
   ACCTD_AMT                   ,
   ACCTD_AMT_CR                ,
   ACCTD_AMT_DR                ,
   ALLOC_ACCTD_AMT             ,
   ALLOC_AMT                   ,
   AMT                         ,
   AMT_CR                      ,
   AMT_DR                      ,
   BASE_CHRG_PRO_ACCTD_AMT     ,
   BASE_CHRG_PRO_AMT           ,
   BASE_CURRENCY               ,
   BASE_DIST_ACCTD_AMT         ,
   BASE_DIST_AMT               ,
   BASE_DIST_CHRG_ACCTD_AMT    ,
   BASE_DIST_CHRG_AMT          ,
   BASE_DIST_FRT_ACCTD_AMT     ,
   BASE_DIST_FRT_AMT           ,
   BASE_DIST_TAX_ACCTD_AMT     ,
   BASE_DIST_TAX_AMT           ,
   BASE_ED_CHRG_PRO_ACCTD_AMT  ,
   BASE_ED_CHRG_PRO_AMT        ,
   BASE_ED_DIST_ACCTD_AMT      ,
   BASE_ED_DIST_AMT            ,
   BASE_ED_DIST_CHRG_ACCTD_AMT ,
   BASE_ED_DIST_CHRG_AMT       ,
   BASE_ED_DIST_FRT_ACCTD_AMT  ,
   BASE_ED_DIST_FRT_AMT        ,
   BASE_ED_DIST_TAX_ACCTD_AMT  ,
   BASE_ED_DIST_TAX_AMT        ,
   BASE_ED_FRT_PRO_ACCTD_AMT   ,
   BASE_ED_FRT_PRO_AMT         ,
   BASE_ED_PRO_ACCTD_AMT       ,
   BASE_ED_PRO_AMT             ,
   BASE_ED_TAX_PRO_ACCTD_AMT   ,
   BASE_ED_TAX_PRO_AMT         ,
   BASE_FRT_PRO_ACCTD_AMT      ,
   BASE_FRT_PRO_AMT            ,
   BASE_PRO_ACCTD_AMT          ,
   BASE_PRO_AMT                ,
   BASE_TAX_PRO_ACCTD_AMT      ,
   BASE_TAX_PRO_AMT            ,
   BASE_UNED_CHRG_PRO_ACCTD_AMT     ,
   BASE_UNED_CHRG_PRO_AMT      ,
   BASE_UNED_DIST_ACCTD_AMT    ,
   BASE_UNED_DIST_AMT          ,
   BASE_UNED_DIST_CHRG_ACCTD_AMT    ,
   BASE_UNED_DIST_CHRG_AMT     ,
   BASE_UNED_DIST_FRT_ACCTD_AMT     ,
   BASE_UNED_DIST_FRT_AMT      ,
   BASE_UNED_DIST_TAX_ACCTD_AMT     ,
   BASE_UNED_DIST_TAX_AMT      ,
   BASE_UNED_FRT_PRO_ACCTD_AMT ,
   BASE_UNED_FRT_PRO_AMT       ,
   BASE_UNED_PRO_ACCTD_AMT     ,
   BASE_UNED_PRO_AMT           ,
   BASE_UNED_TAX_PRO_ACCTD_AMT ,
   BASE_UNED_TAX_PRO_AMT       ,
   ACTIVITY_BUCKET             ,
   BUC_ALLOC_ACCTD_AMT         ,
   BUC_ALLOC_AMT               ,
   BUC_CHRG_ALLOC_ACCTD_AMT    ,
   BUC_CHRG_ALLOC_AMT          ,
   BUC_ED_ALLOC_ACCTD_AMT      ,
   BUC_ED_ALLOC_AMT            ,
   BUC_ED_CHRG_ALLOC_ACCTD_AMT ,
   BUC_ED_CHRG_ALLOC_AMT       ,
   BUC_ED_FRT_ALLOC_ACCTD_AMT  ,
   BUC_ED_FRT_ALLOC_AMT        ,
   BUC_ED_TAX_ALLOC_ACCTD_AMT  ,
   BUC_ED_TAX_ALLOC_AMT        ,
   BUC_FRT_ALLOC_ACCTD_AMT     ,
   BUC_FRT_ALLOC_AMT           ,
   BUC_TAX_ALLOC_ACCTD_AMT     ,
   BUC_TAX_ALLOC_AMT           ,
   BUC_UNED_ALLOC_ACCTD_AMT    ,
   BUC_UNED_ALLOC_AMT          ,
   BUC_UNED_CHRG_ALLOC_ACCTD_AMT    ,
   BUC_UNED_CHRG_ALLOC_AMT     ,
   BUC_UNED_FRT_ALLOC_ACCTD_AMT     ,
   BUC_UNED_FRT_ALLOC_AMT      ,
   BUC_UNED_TAX_ALLOC_ACCTD_AMT     ,
   BUC_UNED_TAX_ALLOC_AMT      ,
   CCID                        ,
   CCID_SECONDARY              ,
   CHRG_REM_ACCTD_AMT          ,
   CHRG_REM_AMT                ,
   DET_ID                      ,
   DIST_ACCTD_AMT              ,
   DIST_AMT                    ,
   DIST_CHRG_ACCTD_AMT         ,
   DIST_CHRG_AMT               ,
   DIST_ED_ACCTD_AMT           ,
   DIST_ED_AMT                 ,
   DIST_ED_CHRG_ACCTD_AMT      ,
   DIST_ED_CHRG_AMT            ,
   DIST_ED_FRT_ACCTD_AMT       ,
   DIST_ED_FRT_AMT             ,
   DIST_ED_TAX_ACCTD_AMT       ,
   DIST_ED_TAX_AMT             ,
   DIST_FRT_ACCTD_AMT          ,
   DIST_FRT_AMT                ,
   DIST_TAX_ACCTD_AMT          ,
   DIST_TAX_AMT                ,
   DIST_UNED_ACCTD_AMT         ,
   DIST_UNED_AMT               ,
   DIST_UNED_CHRG_ACCTD_AMT    ,
   DIST_UNED_CHRG_AMT          ,
   DIST_UNED_FRT_ACCTD_AMT     ,
   DIST_UNED_FRT_AMT           ,
   DIST_UNED_TAX_ACCTD_AMT     ,
   DIST_UNED_TAX_AMT           ,
   DUE_ORIG_ACCTD_AMT          ,
   DUE_ORIG_AMT                ,
   DUE_REM_ACCTD_AMT           ,
   DUE_REM_AMT                 ,
   ELMT_CHRG_PRO_ACCTD_AMT     ,
   ELMT_CHRG_PRO_AMT           ,
   ELMT_ED_CHRG_PRO_ACCTD_AMT  ,
   ELMT_ED_CHRG_PRO_AMT        ,
   ELMT_ED_FRT_PRO_ACCTD_AMT   ,
   ELMT_ED_FRT_PRO_AMT         ,
   ELMT_ED_PRO_ACCTD_AMT       ,
   ELMT_ED_PRO_AMT             ,
   ELMT_ED_TAX_PRO_ACCTD_AMT   ,
   ELMT_ED_TAX_PRO_AMT         ,
   ELMT_FRT_PRO_ACCTD_AMT      ,
   ELMT_FRT_PRO_AMT            ,
   ELMT_PRO_ACCTD_AMT          ,
   ELMT_PRO_AMT                ,
   ELMT_TAX_PRO_ACCTD_AMT      ,
   ELMT_TAX_PRO_AMT            ,
   ELMT_UNED_CHRG_PRO_ACCTD_AMT      ,
   ELMT_UNED_CHRG_PRO_AMT      ,
   ELMT_UNED_FRT_PRO_ACCTD_AMT ,
   ELMT_UNED_FRT_PRO_AMT       ,
   ELMT_UNED_PRO_ACCTD_AMT     ,
   ELMT_UNED_PRO_AMT           ,
   ELMT_UNED_TAX_PRO_ACCTD_AMT ,
   ELMT_UNED_TAX_PRO_AMT       ,
   FROM_ACCTD_AMT_CR           ,
   FROM_ACCTD_AMT_DR           ,
   FROM_ALLOC_ACCTD_AMT        ,
   FROM_ALLOC_AMT              ,
   FROM_CURRENCY               ,
   FRT_ADJ_REM_ACCTD_AMT       ,
   FRT_ADJ_REM_AMT             ,
   FRT_ORIG_ACCTD_AMT          ,
   FRT_ORIG_AMT                ,
   FRT_REM_ACCTD_AMT           ,
   FRT_REM_AMT                 ,
   GP_LEVEL                    ,
   GROUP_ID                    ,
   GT_ID                       ,
   LINE_ID                     ,
   LINE_TYPE                   ,
   REF_CUSTOMER_TRX_ID         ,
   REF_CUSTOMER_TRX_LINE_ID    ,
   REF_CUST_TRX_LINE_GL_DIST_ID      ,
   REF_DET_ID                  ,
   REF_LINE_ID                 ,
   SET_OF_BOOKS_ID             ,
   SE_GT_ID                    ,
   SOB_TYPE                    ,
   SOURCE_DATA_KEY1            ,
   SOURCE_DATA_KEY2            ,
   SOURCE_DATA_KEY3            ,
   SOURCE_DATA_KEY4            ,
   SOURCE_DATA_KEY5            ,
   SOURCE_ID                   ,
   SOURCE_TABLE                ,
   SOURCE_TYPE                 ,
   SUM_GP_LINE_CHRG_REM_ACCTD_AMT   ,
   SUM_GP_LINE_CHRG_REM_AMT    ,
   SUM_GP_LINE_FRT_ORIG_ACCTD_AMT   ,
   SUM_GP_LINE_FRT_ORIG_AMT    ,
   SUM_GP_LINE_FRT_REM_ACCTD_AMT    ,
   SUM_GP_LINE_FRT_REM_AMT     ,
   SUM_GP_LINE_ORIG_ACCTD_AMT  ,
   SUM_GP_LINE_ORIG_AMT        ,
   SUM_GP_LINE_REM_ACCTD_AMT   ,
   SUM_GP_LINE_REM_AMT         ,
   SUM_GP_LINE_TAX_ORIG_ACCTD_AMT   ,
   SUM_GP_LINE_TAX_ORIG_AMT    ,
   SUM_GP_LINE_TAX_REM_ACCTD_AMT    ,
   SUM_GP_LINE_TAX_REM_AMT     ,
   SUM_LINE_CHRG_REM_ACCTD_AMT ,
   SUM_LINE_CHRG_REM_AMT       ,
   SUM_LINE_FRT_ORIG_ACCTD_AMT ,
   SUM_LINE_FRT_ORIG_AMT       ,
   SUM_LINE_FRT_REM_ACCTD_AMT  ,
   SUM_LINE_FRT_REM_AMT        ,
   SUM_LINE_ORIG_ACCTD_AMT     ,
   SUM_LINE_ORIG_AMT           ,
   SUM_LINE_REM_ACCTD_AMT      ,
   SUM_LINE_REM_AMT            ,
   SUM_LINE_TAX_ORIG_ACCTD_AMT ,
   SUM_LINE_TAX_ORIG_AMT       ,
   SUM_LINE_TAX_REM_ACCTD_AMT  ,
   SUM_LINE_TAX_REM_AMT        ,
   TAX_INC_FLAG                ,
   TAX_LINK_ID                 ,
   TAX_ORIG_ACCTD_AMT          ,
   TAX_ORIG_AMT                ,
   TAX_REM_ACCTD_AMT           ,
   TAX_REM_AMT                 ,
   TL_ALLOC_ACCTD_AMT          ,
   TL_ALLOC_AMT                ,
   TL_CHRG_ALLOC_ACCTD_AMT     ,
   TL_CHRG_ALLOC_AMT           ,
   TL_ED_ALLOC_ACCTD_AMT       ,
   TL_ED_ALLOC_AMT             ,
   TL_ED_CHRG_ALLOC_ACCTD_AMT  ,
   TL_ED_CHRG_ALLOC_AMT        ,
   TL_ED_FRT_ALLOC_ACCTD_AMT   ,
   TL_ED_FRT_ALLOC_AMT         ,
   TL_ED_TAX_ALLOC_ACCTD_AMT   ,
   TL_ED_TAX_ALLOC_AMT         ,
   TL_FRT_ALLOC_ACCTD_AMT      ,
   TL_FRT_ALLOC_AMT            ,
   TL_TAX_ALLOC_ACCTD_AMT      ,
   TL_TAX_ALLOC_AMT            ,
   TL_UNED_ALLOC_ACCTD_AMT     ,
   TL_UNED_ALLOC_AMT           ,
   TL_UNED_CHRG_ALLOC_ACCTD_AMT  ,
   TL_UNED_CHRG_ALLOC_AMT      ,
   TL_UNED_FRT_ALLOC_ACCTD_AMT ,
   TL_UNED_FRT_ALLOC_AMT       ,
   TL_UNED_TAX_ALLOC_ACCTD_AMT ,
   TL_UNED_TAX_ALLOC_AMT       ,
   TO_CURRENCY                 ,
   REF_MF_DIST_FLAG            ,
   CHRG_ORIG_AMT               ,
   CHRG_ORIG_ACCTD_AMT         ,
   CHRG_ADJ_REM_AMT            ,
   CHRG_ADJ_REM_ACCTD_AMT      ,
   SUM_LINE_CHRG_ORIG_AMT      ,
   SUM_LINE_CHRG_ORIG_ACCTD_AMT       ,
   SUM_GP_LINE_CHRG_ORIG_AMT   ,
   SUM_GP_LINE_CHRG_ORIG_ACCTD_AM     ,
   INT_LINE_AMOUNT             ,
   INT_TAX_AMOUNT              ,
   INT_ED_LINE_AMOUNT          ,
   INT_ED_TAX_AMOUNT           ,
   INT_UNED_LINE_AMOUNT        ,
   INT_UNED_TAX_AMOUNT         ,
   SUM_INT_LINE_AMOUNT         ,
   SUM_INT_TAX_AMOUNT          ,
   SUM_INT_ED_LINE_AMOUNT      ,
   SUM_INT_ED_TAX_AMOUNT       ,
   SUM_INT_UNED_LINE_AMOUNT    ,
   SUM_INT_UNED_TAX_AMOUNT     )
   SELECT
   ACCOUNT_CLASS               ,
   ACCTD_AMT                   ,
   ACCTD_AMT_CR                ,
   ACCTD_AMT_DR                ,
   ALLOC_ACCTD_AMT             ,
   ALLOC_AMT                   ,
   AMT                         ,
   AMT_CR                      ,
   AMT_DR                      ,
   BASE_CHRG_PRO_ACCTD_AMT     ,
   BASE_CHRG_PRO_AMT           ,
   BASE_CURRENCY               ,
   BASE_DIST_ACCTD_AMT         ,
   BASE_DIST_AMT               ,
   BASE_DIST_CHRG_ACCTD_AMT    ,
   BASE_DIST_CHRG_AMT          ,
   BASE_DIST_FRT_ACCTD_AMT     ,
   BASE_DIST_FRT_AMT           ,
   BASE_DIST_TAX_ACCTD_AMT     ,
   BASE_DIST_TAX_AMT           ,
   BASE_ED_CHRG_PRO_ACCTD_AMT  ,
   BASE_ED_CHRG_PRO_AMT        ,
   BASE_ED_DIST_ACCTD_AMT      ,
   BASE_ED_DIST_AMT            ,
   BASE_ED_DIST_CHRG_ACCTD_AMT ,
   BASE_ED_DIST_CHRG_AMT       ,
   BASE_ED_DIST_FRT_ACCTD_AMT  ,
   BASE_ED_DIST_FRT_AMT        ,
   BASE_ED_DIST_TAX_ACCTD_AMT  ,
   BASE_ED_DIST_TAX_AMT        ,
   BASE_ED_FRT_PRO_ACCTD_AMT   ,
   BASE_ED_FRT_PRO_AMT         ,
   BASE_ED_PRO_ACCTD_AMT       ,
   BASE_ED_PRO_AMT             ,
   BASE_ED_TAX_PRO_ACCTD_AMT   ,
   BASE_ED_TAX_PRO_AMT         ,
   BASE_FRT_PRO_ACCTD_AMT      ,
   BASE_FRT_PRO_AMT            ,
   BASE_PRO_ACCTD_AMT          ,
   BASE_PRO_AMT                ,
   BASE_TAX_PRO_ACCTD_AMT      ,
   BASE_TAX_PRO_AMT            ,
   BASE_UNED_CHRG_PRO_ACCTD_AMT     ,
   BASE_UNED_CHRG_PRO_AMT      ,
   BASE_UNED_DIST_ACCTD_AMT    ,
   BASE_UNED_DIST_AMT          ,
   BASE_UNED_DIST_CHRG_ACCTD_AMT    ,
   BASE_UNED_DIST_CHRG_AMT     ,
   BASE_UNED_DIST_FRT_ACCTD_AMT     ,
   BASE_UNED_DIST_FRT_AMT      ,
   BASE_UNED_DIST_TAX_ACCTD_AMT     ,
   BASE_UNED_DIST_TAX_AMT      ,
   BASE_UNED_FRT_PRO_ACCTD_AMT ,
   BASE_UNED_FRT_PRO_AMT       ,
   BASE_UNED_PRO_ACCTD_AMT     ,
   BASE_UNED_PRO_AMT           ,
   BASE_UNED_TAX_PRO_ACCTD_AMT ,
   BASE_UNED_TAX_PRO_AMT       ,
   ACTIVITY_BUCKET             ,
   BUC_ALLOC_ACCTD_AMT         ,
   BUC_ALLOC_AMT               ,
   BUC_CHRG_ALLOC_ACCTD_AMT    ,
   BUC_CHRG_ALLOC_AMT          ,
   BUC_ED_ALLOC_ACCTD_AMT      ,
   BUC_ED_ALLOC_AMT            ,
   BUC_ED_CHRG_ALLOC_ACCTD_AMT ,
   BUC_ED_CHRG_ALLOC_AMT       ,
   BUC_ED_FRT_ALLOC_ACCTD_AMT  ,
   BUC_ED_FRT_ALLOC_AMT        ,
   BUC_ED_TAX_ALLOC_ACCTD_AMT  ,
   BUC_ED_TAX_ALLOC_AMT        ,
   BUC_FRT_ALLOC_ACCTD_AMT     ,
   BUC_FRT_ALLOC_AMT           ,
   BUC_TAX_ALLOC_ACCTD_AMT     ,
   BUC_TAX_ALLOC_AMT           ,
   BUC_UNED_ALLOC_ACCTD_AMT    ,
   BUC_UNED_ALLOC_AMT          ,
   BUC_UNED_CHRG_ALLOC_ACCTD_AMT    ,
   BUC_UNED_CHRG_ALLOC_AMT     ,
   BUC_UNED_FRT_ALLOC_ACCTD_AMT     ,
   BUC_UNED_FRT_ALLOC_AMT      ,
   BUC_UNED_TAX_ALLOC_ACCTD_AMT     ,
   BUC_UNED_TAX_ALLOC_AMT      ,
   CCID                        ,
   CCID_SECONDARY              ,
   CHRG_REM_ACCTD_AMT          ,
   CHRG_REM_AMT                ,
   DET_ID                      ,
   DIST_ACCTD_AMT              ,
   DIST_AMT                    ,
   DIST_CHRG_ACCTD_AMT         ,
   DIST_CHRG_AMT               ,
   DIST_ED_ACCTD_AMT           ,
   DIST_ED_AMT                 ,
   DIST_ED_CHRG_ACCTD_AMT      ,
   DIST_ED_CHRG_AMT            ,
   DIST_ED_FRT_ACCTD_AMT       ,
   DIST_ED_FRT_AMT             ,
   DIST_ED_TAX_ACCTD_AMT       ,
   DIST_ED_TAX_AMT             ,
   DIST_FRT_ACCTD_AMT          ,
   DIST_FRT_AMT                ,
   DIST_TAX_ACCTD_AMT          ,
   DIST_TAX_AMT                ,
   DIST_UNED_ACCTD_AMT         ,
   DIST_UNED_AMT               ,
   DIST_UNED_CHRG_ACCTD_AMT    ,
   DIST_UNED_CHRG_AMT          ,
   DIST_UNED_FRT_ACCTD_AMT     ,
   DIST_UNED_FRT_AMT           ,
   DIST_UNED_TAX_ACCTD_AMT     ,
   DIST_UNED_TAX_AMT           ,
   DUE_ORIG_ACCTD_AMT          ,
   DUE_ORIG_AMT                ,
   DUE_REM_ACCTD_AMT           ,
   DUE_REM_AMT                 ,
   ELMT_CHRG_PRO_ACCTD_AMT     ,
   ELMT_CHRG_PRO_AMT           ,
   ELMT_ED_CHRG_PRO_ACCTD_AMT  ,
   ELMT_ED_CHRG_PRO_AMT        ,
   ELMT_ED_FRT_PRO_ACCTD_AMT   ,
   ELMT_ED_FRT_PRO_AMT         ,
   ELMT_ED_PRO_ACCTD_AMT       ,
   ELMT_ED_PRO_AMT             ,
   ELMT_ED_TAX_PRO_ACCTD_AMT   ,
   ELMT_ED_TAX_PRO_AMT         ,
   ELMT_FRT_PRO_ACCTD_AMT      ,
   ELMT_FRT_PRO_AMT            ,
   ELMT_PRO_ACCTD_AMT          ,
   ELMT_PRO_AMT                ,
   ELMT_TAX_PRO_ACCTD_AMT      ,
   ELMT_TAX_PRO_AMT            ,
   ELMT_UNED_CHRG_PRO_ACCTD_AMT      ,
   ELMT_UNED_CHRG_PRO_AMT      ,
   ELMT_UNED_FRT_PRO_ACCTD_AMT ,
   ELMT_UNED_FRT_PRO_AMT       ,
   ELMT_UNED_PRO_ACCTD_AMT     ,
   ELMT_UNED_PRO_AMT           ,
   ELMT_UNED_TAX_PRO_ACCTD_AMT ,
   ELMT_UNED_TAX_PRO_AMT       ,
   FROM_ACCTD_AMT_CR           ,
   FROM_ACCTD_AMT_DR           ,
   FROM_ALLOC_ACCTD_AMT        ,
   FROM_ALLOC_AMT              ,
   FROM_CURRENCY               ,
   FRT_ADJ_REM_ACCTD_AMT       ,
   FRT_ADJ_REM_AMT             ,
   FRT_ORIG_ACCTD_AMT          ,
   FRT_ORIG_AMT                ,
   FRT_REM_ACCTD_AMT           ,
   FRT_REM_AMT                 ,
   GP_LEVEL                    ,
   GROUP_ID                    ,
   GT_ID                       ,
   LINE_ID                     ,
   LINE_TYPE                   ,
   REF_CUSTOMER_TRX_ID         ,
   REF_CUSTOMER_TRX_LINE_ID    ,
   REF_CUST_TRX_LINE_GL_DIST_ID      ,
   REF_DET_ID                  ,
   REF_LINE_ID                 ,
   SET_OF_BOOKS_ID             ,
   SE_GT_ID                    ,
   SOB_TYPE                    ,
   SOURCE_DATA_KEY1            ,
   SOURCE_DATA_KEY2            ,
   SOURCE_DATA_KEY3            ,
   SOURCE_DATA_KEY4            ,
   SOURCE_DATA_KEY5            ,
   SOURCE_ID                   ,
   SOURCE_TABLE                ,
   SOURCE_TYPE                 ,
   SUM_GP_LINE_CHRG_REM_ACCTD_AMT   ,
   SUM_GP_LINE_CHRG_REM_AMT    ,
   SUM_GP_LINE_FRT_ORIG_ACCTD_AMT   ,
   SUM_GP_LINE_FRT_ORIG_AMT    ,
   SUM_GP_LINE_FRT_REM_ACCTD_AMT    ,
   SUM_GP_LINE_FRT_REM_AMT     ,
   SUM_GP_LINE_ORIG_ACCTD_AMT  ,
   SUM_GP_LINE_ORIG_AMT        ,
   SUM_GP_LINE_REM_ACCTD_AMT   ,
   SUM_GP_LINE_REM_AMT         ,
   SUM_GP_LINE_TAX_ORIG_ACCTD_AMT   ,
   SUM_GP_LINE_TAX_ORIG_AMT    ,
   SUM_GP_LINE_TAX_REM_ACCTD_AMT    ,
   SUM_GP_LINE_TAX_REM_AMT     ,
   SUM_LINE_CHRG_REM_ACCTD_AMT ,
   SUM_LINE_CHRG_REM_AMT       ,
   SUM_LINE_FRT_ORIG_ACCTD_AMT ,
   SUM_LINE_FRT_ORIG_AMT       ,
   SUM_LINE_FRT_REM_ACCTD_AMT  ,
   SUM_LINE_FRT_REM_AMT        ,
   SUM_LINE_ORIG_ACCTD_AMT     ,
   SUM_LINE_ORIG_AMT           ,
   SUM_LINE_REM_ACCTD_AMT      ,
   SUM_LINE_REM_AMT            ,
   SUM_LINE_TAX_ORIG_ACCTD_AMT ,
   SUM_LINE_TAX_ORIG_AMT       ,
   SUM_LINE_TAX_REM_ACCTD_AMT  ,
   SUM_LINE_TAX_REM_AMT        ,
   TAX_INC_FLAG                ,
   TAX_LINK_ID                 ,
   TAX_ORIG_ACCTD_AMT          ,
   TAX_ORIG_AMT                ,
   TAX_REM_ACCTD_AMT           ,
   TAX_REM_AMT                 ,
   TL_ALLOC_ACCTD_AMT          ,
   TL_ALLOC_AMT                ,
   TL_CHRG_ALLOC_ACCTD_AMT     ,
   TL_CHRG_ALLOC_AMT           ,
   TL_ED_ALLOC_ACCTD_AMT       ,
   TL_ED_ALLOC_AMT             ,
   TL_ED_CHRG_ALLOC_ACCTD_AMT  ,
   TL_ED_CHRG_ALLOC_AMT        ,
   TL_ED_FRT_ALLOC_ACCTD_AMT   ,
   TL_ED_FRT_ALLOC_AMT         ,
   TL_ED_TAX_ALLOC_ACCTD_AMT   ,
   TL_ED_TAX_ALLOC_AMT         ,
   TL_FRT_ALLOC_ACCTD_AMT      ,
   TL_FRT_ALLOC_AMT            ,
   TL_TAX_ALLOC_ACCTD_AMT      ,
   TL_TAX_ALLOC_AMT            ,
   TL_UNED_ALLOC_ACCTD_AMT     ,
   TL_UNED_ALLOC_AMT           ,
   TL_UNED_CHRG_ALLOC_ACCTD_AMT  ,
   TL_UNED_CHRG_ALLOC_AMT      ,
   TL_UNED_FRT_ALLOC_ACCTD_AMT ,
   TL_UNED_FRT_ALLOC_AMT       ,
   TL_UNED_TAX_ALLOC_ACCTD_AMT ,
   TL_UNED_TAX_ALLOC_AMT       ,
   TO_CURRENCY                 ,
   REF_MF_DIST_FLAG            ,
   CHRG_ORIG_AMT               ,
   CHRG_ORIG_ACCTD_AMT         ,
   CHRG_ADJ_REM_AMT            ,
   CHRG_ADJ_REM_ACCTD_AMT      ,
   SUM_LINE_CHRG_ORIG_AMT      ,
   SUM_LINE_CHRG_ORIG_ACCTD_AMT       ,
   SUM_GP_LINE_CHRG_ORIG_AMT   ,
   SUM_GP_LINE_CHRG_ORIG_ACCTD_AM     ,
   INT_LINE_AMOUNT             ,
   INT_TAX_AMOUNT              ,
   INT_ED_LINE_AMOUNT          ,
   INT_ED_TAX_AMOUNT           ,
   INT_UNED_LINE_AMOUNT        ,
   INT_UNED_TAX_AMOUNT         ,
   SUM_INT_LINE_AMOUNT         ,
   SUM_INT_TAX_AMOUNT          ,
   SUM_INT_ED_LINE_AMOUNT      ,
   SUM_INT_ED_TAX_AMOUNT       ,
   SUM_INT_UNED_LINE_AMOUNT    ,
   SUM_INT_UNED_TAX_AMOUNT
   FROM ra_ar_gt
   WHERE gt_id = l_gt_id;
*/

OPEN c(l_gt_id);
LOOP
  FETCH c INTO l;
  EXIT WHEN c%NOTFOUND;
IF PG_DEBUG = 'Y' THEN
localdebug('<FROM_AMOUNT>'||l.FROM_AMOUNT||'</FROM_AMOUNT>');
localdebug('<FROM_CURRENCY>'||l.FROM_CURRENCY||'</FROM_CURRENCY>');
localdebug('<GROUP_ID>'||l.GROUP_ID||'</GROUP_ID>');
localdebug('<GT_ID>'||l.GT_ID||'</GT_ID>');
localdebug('<LAST_UPDATED_BY>'||l.LAST_UPDATED_BY||'</LAST_UPDATED_BY>');
localdebug('<LAST_UPDATE_DATE>'||l.LAST_UPDATE_DATE||'</LAST_UPDATE_DATE>');
localdebug('<LAST_UPDATE_LOGIN>'||l.LAST_UPDATE_LOGIN||'</LAST_UPDATE_LOGIN>');
localdebug('<LEDGER_ID>'||l.LEDGER_ID||'</LEDGER_ID>');
localdebug('<LINE_ID>'||l.LINE_ID||'</LINE_ID>');
localdebug('<ORG_ID>'||l.ORG_ID||'</ORG_ID>');
localdebug('<REF_CUSTOMER_TRX_ID>'||l.REF_CUSTOMER_TRX_ID||'</REF_CUSTOMER_TRX_ID>');
localdebug('<REF_CUSTOMER_TRX_LINE_ID>'||l.REF_CUSTOMER_TRX_LINE_ID||'</REF_CUSTOMER_TRX_LINE_ID>');
localdebug('<REF_CUST_TRX_LINE_GL_DIST_ID>'||l.REF_CUST_TRX_LINE_GL_DIST_ID||'</REF_CUST_TRX_LINE_GL_DIST_ID>');
localdebug('<REF_DET_ID>'||l.REF_DET_ID||'</REF_DET_ID>');
localdebug('<REF_LINE_ID>'||l.REF_LINE_ID||'</REF_LINE_ID>');
localdebug('<SE_GT_ID>'||l.SE_GT_ID||'</SE_GT_ID>');
localdebug('<SOURCE_DATA_KEY1>'||l.SOURCE_DATA_KEY1||'</SOURCE_DATA_KEY1>');
localdebug('<SOURCE_DATA_KEY2>'||l.SOURCE_DATA_KEY2||'</SOURCE_DATA_KEY2>');
localdebug('<SOURCE_DATA_KEY3>'||l.SOURCE_DATA_KEY3||'</SOURCE_DATA_KEY3>');
localdebug('<SOURCE_DATA_KEY4>'||l.SOURCE_DATA_KEY4||'</SOURCE_DATA_KEY4>');
localdebug('<SOURCE_DATA_KEY5>'||l.SOURCE_DATA_KEY5||'</SOURCE_DATA_KEY5>');
localdebug('<SOURCE_ID>'||l.SOURCE_ID||'</SOURCE_ID>');
localdebug('<SOURCE_TABLE>'||l.SOURCE_TABLE||'</SOURCE_TABLE>');
localdebug('<SOURCE_TYPE>'||l.SOURCE_TYPE||'</SOURCE_TYPE>');
localdebug('<TAXABLE_ACCTD_AMOUNT>'||l.TAXABLE_ACCTD_AMOUNT||'</TAXABLE_ACCTD_AMOUNT>');
localdebug('<TAXABLE_AMOUNT>'||l.TAXABLE_AMOUNT||'</TAXABLE_AMOUNT>');
localdebug('<TAX_INC_FLAG>'||l.TAX_INC_FLAG||'</TAX_INC_FLAG>');
localdebug('<TAX_LINK_ID>'||l.TAX_LINK_ID||'</TAX_LINK_ID>');
localdebug('<TO_CURRENCY>'||l.TO_CURRENCY||'</TO_CURRENCY>');
localdebug('<REF_MF_DIST_FLAG>'||l.REF_MF_DIST_FLAG||'</REF_MF_DIST_FLAG>');
localdebug('<ACCTD_AMOUNT>'||l.ACCTD_AMOUNT||'</ACCTD_AMOUNT>');
localdebug('<REF_ACCOUNT_CLASS>'||l.REF_ACCOUNT_CLASS||'</REF_ACCOUNT_CLASS>');
localdebug('<AMOUNT>'||l.AMOUNT||'</AMOUNT>');
localdebug('<APP_LEVEL>'||l.APP_LEVEL||'</APP_LEVEL>');
localdebug('<BASE_CURRENCY>'||l.BASE_CURRENCY||'</BASE_CURRENCY>');
localdebug('<ACTIVITY_BUCKET>'||l.ACTIVITY_BUCKET||'</ACTIVITY_BUCKET>');
localdebug('<CCID>'||l.CCID||'</CCID>');
localdebug('<CCID_SECONDARY>'||l.CCID_SECONDARY||'</CCID_SECONDARY>');
localdebug('<DET_ID>'||l.DET_ID||'</DET_ID>');
localdebug('<FROM_ACCTD_AMOUNT>'||l.FROM_ACCTD_AMOUNT||'</FROM_ACCTD_AMOUNT>');
END IF;

END LOOP;
CLOSE c;
END;

PROCEDURE get_diag_flag IS
BEGIN
  IF g_diag_flag = 'NOT_SET' THEN
    g_diag_flag  := FND_PROFILE.VALUE('AR_EXTRACT_DIAG');
    IF g_diag_flag IS NULL THEN
      g_diag_flag  := 'N';
    END IF;
  END IF;
END;

END ARP_DET_DIST_PKG;

/
