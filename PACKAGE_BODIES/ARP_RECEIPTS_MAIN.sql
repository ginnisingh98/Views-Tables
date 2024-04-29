--------------------------------------------------------
--  DDL for Package Body ARP_RECEIPTS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RECEIPTS_MAIN" AS
/* $Header: ARRECACB.pls 120.60.12010000.24 2010/08/03 06:59:39 nemani ship $ */

/* =======================================================================
 | Package Globals
 * ======================================================================*/
  g_mode			VARCHAR2(30);
  g_ae_doc_rec			ae_doc_rec_type;
  g_ae_event_rec		ae_event_rec_type;
  g_ae_line_tbl                 ae_line_tbl_type;
  g_empty_ae_line_tbl           ae_line_tbl_type;
  g_empty_ae_app_pair_tbl       ae_app_pair_tbl_type;
  g_ae_sys_rec                  ae_sys_rec_type;
  g_ae_line_ctr                 BINARY_INTEGER;

  TYPE g_ae_miscel_rec_type IS RECORD (
  gain_loss_ccid      ar_system_parameters.code_combination_id_gain%TYPE,
  fixed_rate          varchar2(1)
  );

  --{3377004
  TYPE ctl_rem_amt_type IS RECORD
  (customer_trx_line_id           DBMS_SQL.NUMBER_TABLE,
   amount_due_remaining           DBMS_SQL.NUMBER_TABLE,
   acctd_amount_due_remaining     DBMS_SQL.NUMBER_TABLE,
   chrg_amount_remaining          DBMS_SQL.NUMBER_TABLE,
   chrg_acctd_amount_remaining    DBMS_SQL.NUMBER_TABLE);
  --}


/* =======================================================================
 | Private Procedure/Function prototypes
 * ======================================================================*/
  PROCEDURE Init_Ae_Lines;

  PROCEDURE Derive_Accounting_Entry
    --{HYUDETUPT
    (p_from_llca_call  IN  VARCHAR2,
     p_gt_id           IN  NUMBER);
    --}


  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Delete_RA(p_ae_deleted   OUT NOCOPY BOOLEAN);

  PROCEDURE Delete_MCD(p_ae_deleted   OUT NOCOPY BOOLEAN);

  PROCEDURE Reverse_Receipt_CM;

  PROCEDURE Get_Doc_Entitity_Data (
                p_level          IN  VARCHAR2                           ,
                p_app_rec        OUT NOCOPY ar_receivable_applications%ROWTYPE ,
                p_cr_rec         OUT NOCOPY ar_cash_receipts%ROWTYPE           ,
                p_cust_inv_rec   OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_cust_cm_rec    OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_ctlgd_cm_rec   OUT NOCOPY ra_cust_trx_line_gl_dist%ROWTYPE   ,
                p_miscel_rec     OUT NOCOPY g_ae_miscel_rec_type               ,
                p_vat_rec        OUT NOCOPY ar_vat_tax%ROWTYPE                 ,
                p_curr_rec       OUT NOCOPY ae_curr_rec_type                   ,
                p_rule_rec       OUT NOCOPY ae_rule_rec_type                     );

  PROCEDURE Act_Tax_Non_Rec_Ccid (
                p_type                  IN  VARCHAR2                                    ,
                p_asset_tax_code        IN  VARCHAR2                                    ,
                p_apply_date            IN  DATE                                        ,
                p_act_tax_non_rec_ccid  OUT NOCOPY ar_receivables_trx.code_combination_id%TYPE ,
                p_act_vat_tax_id        OUT NOCOPY ar_vat_tax.vat_tax_id%TYPE                    );

  PROCEDURE Create_Ae_Lines_Common (
                p_level         IN VARCHAR2,
                --{HYUDETUPT
                p_from_llca_call  IN VARCHAR2,
                p_gt_id           IN NUMBER
                --}
                  );

  PROCEDURE Create_Ae_Lines_RA(
                p_app_rec        IN ar_receivable_applications%ROWTYPE ,
                p_cr_rec         IN ar_cash_receipts%ROWTYPE           ,
                p_cust_inv_rec   IN ra_customer_trx%ROWTYPE            ,
                p_cust_cm_rec    IN ra_customer_trx%ROWTYPE            ,
                p_ctlgd_cm_rec   IN ra_cust_trx_line_gl_dist%ROWTYPE   ,
                p_miscel_rec     IN g_ae_miscel_rec_type               ,
                p_rule_rec       IN ae_rule_rec_type                   ,
                --{
                p_from_llca_call IN VARCHAR2,
                p_gt_id          IN NUMBER
                --}
                );

  PROCEDURE Create_Ae_Lines_MCD(
                p_cr_rec         IN ar_cash_receipts%ROWTYPE           ,
                p_vat_rec        IN ar_vat_tax%ROWTYPE                 ,
                p_curr_rec       IN ae_curr_rec_type                   );

  PROCEDURE Assign_Ael_Elements(
                p_ae_line_rec           IN ae_line_rec_type );


  --{3377004
  FUNCTION ctl_id_index(p_ctl_id_tab  IN DBMS_SQL.NUMBER_TABLE,
                        p_ctl_id      IN NUMBER)
  RETURN NUMBER;

  PROCEDURE init_rem_amt(x_rem_amt IN OUT NOCOPY ctl_rem_amt_type,
                         p_index   IN NUMBER);

--{BUG#5437275 Need from amt for activity distributions
FUNCTION from_num_amt
(p_to_curr          IN VARCHAR2,
 p_from_curr        IN VARCHAR2,
 p_to_curr_rate     IN NUMBER,  -- vavenugo bug6653443
 p_from_curr_rate   IN NUMBER,  -- vavenugo bug6653443
 p_to_den_amt       IN NUMBER,
 p_from_num_amt     IN NUMBER,
 p_to_num_amt       IN NUMBER)
RETURN NUMBER
IS
  l_res    NUMBER;
BEGIN
/* vavenugo bug6653443 */
--  IF p_to_curr = p_from_curr THEN
  IF (p_to_curr = p_from_curr AND p_to_curr_rate = p_from_curr_rate) THEN
    l_res := p_to_num_amt;
  ELSE
    IF p_to_den_amt IS NULL OR p_to_den_amt = 0 THEN
      l_res := p_to_num_amt;
    ELSE
      l_res := arpcurr.CurrRound(
                     p_from_num_amt /
                     p_to_den_amt   *
                     p_to_num_amt, p_from_curr);
    END IF;
  END IF;
  RETURN l_res;
END;



/* =======================================================================
 | Procedures/functions
 * ======================================================================*/
/* =======================================================================
 | PUBLIC PROCEDURE Delete_Acct
 |
 | DESCRIPTION
 |      Accounting Entry Deletion
 |      -------------------------
 |      This procedure is the Accounting Entry deletion routine which
 |      deletes data associated with Receipts based on event and source
 |      table.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_ae_deleted    OUT NOCOPY     AE Lines deletion status
 * ======================================================================*/
PROCEDURE Delete_Acct( p_mode         IN  VARCHAR2,
                       p_ae_doc_rec   IN  OUT NOCOPY ae_doc_rec_type,
                       p_ae_event_rec IN  ae_event_rec_type,
                       p_ae_deleted   OUT NOCOPY BOOLEAN            ) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Delete_Acct()+');
  END IF;

  /*----------------------------------------------------+
   | Copy Document/Event Data to Global                 |
   +----------------------------------------------------*/
  g_mode         := p_mode;
  g_ae_doc_rec   := p_ae_doc_rec;
  g_ae_event_rec := p_ae_event_rec;

  IF ( g_ae_doc_rec.source_table = 'RA' ) THEN

     Delete_RA(p_ae_deleted => p_ae_deleted) ;

  /*---------------------------------------------------------------+
   | If paired id of deleted UNAPP record is returned if delete is |
   | followed by a create for update of a UNAPP record             |
   +---------------------------------------------------------------*/
     p_ae_doc_rec.source_id_old := g_ae_doc_rec.source_id_old ;

  ELSIF ( g_ae_doc_rec.source_table = 'MCD' ) THEN

     Delete_MCD(p_ae_deleted => p_ae_deleted) ;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Delete_Acct()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_RECEIPTS_MAIN.Delete_Acct');
     END IF;
     RAISE;

END Delete_Acct;

/* =======================================================================
 | PUBLIC PROCEDURE Execute
 |
 | DESCRIPTION
 | 	Accounting Entry Derivation Method
 | 	----------------------------------
 | 	This procedure is the Accounting Entry derivation method for all
 | 	accounting events associated with the receivable applications layer.
 |
 | 	Functions of the AE Derivation Method are:
 | 		- Single Entry Point for easy extensibility
 | 		- Read Event Data
 | 		- Read Transaction and Setup Data
 | 		- Determine AE Lines affected
 | 		- Derive AE Lines
 | 		- Return AE Lines created in a PL/SQL table.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 | 	p_ae_event_rec	IN	Event Record
 | 	p_ae_line_tbl	OUT NOCOPY	AE Lines table
 | 	p_ae_created	OUT NOCOPY	AE Lines creation status
 * ======================================================================*/
PROCEDURE Execute( p_mode                IN VARCHAR2,
                   p_ae_doc_rec          IN ae_doc_rec_type,
                   p_ae_event_rec        IN ae_event_rec_type,
                   p_ae_line_tbl         OUT NOCOPY ae_line_tbl_type,
                   p_ae_created          OUT NOCOPY BOOLEAN,
--{HYUDETUPT
p_from_llca_call  IN  VARCHAR2 DEFAULT 'N',
p_gt_id           IN  NUMBER   DEFAULT NULL
--}
                   ) IS


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Execute()+');
  END IF;
  /*------------------------------------------------------+
   | Initialize Accounting Entry Header and Lines	  |
   +------------------------------------------------------*/
  g_ae_line_ctr := 0;
  Init_Ae_Lines;

  /*---------------------------------------------------------------+
   | Copy Document/Event Data to Global, derive System Options info|
   +---------------------------------------------------------------*/
  g_mode 	 := p_mode;
  g_ae_doc_rec 	 := p_ae_doc_rec;
  g_ae_event_rec := p_ae_event_rec;

  --Get system options info

  g_ae_sys_rec.set_of_books_id   := ARP_ACCT_MAIN.ae_sys_rec.set_of_books_id;
  g_ae_sys_rec.gain_cc_id        := ARP_ACCT_MAIN.ae_sys_rec.gain_cc_id;
  g_ae_sys_rec.loss_cc_id        := ARP_ACCT_MAIN.ae_sys_rec.loss_cc_id;
  g_ae_sys_rec.round_cc_id       := ARP_ACCT_MAIN.ae_sys_rec.round_cc_id;
  g_ae_sys_rec.coa_id            := ARP_ACCT_MAIN.ae_sys_rec.coa_id;
  g_ae_sys_rec.base_currency     := ARP_ACCT_MAIN.ae_sys_rec.base_currency;
  g_ae_sys_rec.base_precision    := ARP_ACCT_MAIN.ae_sys_rec.base_precision;
  g_ae_sys_rec.base_min_acc_unit := ARP_ACCT_MAIN.ae_sys_rec.base_min_acc_unit;

  -- MRC TRIGGER REPLACEMENT
  -- Initialize a new global variable:
  g_ae_sys_rec.sob_type          := ARP_ACCT_MAIN.ae_sys_rec.sob_type;

  /*------------------------------------------------------+
   | Derive Accounting Entry                              |
   +------------------------------------------------------*/
  Derive_Accounting_Entry
    --{HYUDETUPT
    (p_from_llca_call  => p_from_llca_call,
     p_gt_id           => p_gt_id);
    --}

  /*------------------------------------------------------+
   | Return Accounting Entry Creation Status              |
   +------------------------------------------------------*/
  p_ae_line_tbl := g_ae_line_tbl;

  IF g_ae_line_tbl.EXISTS(g_ae_line_ctr) THEN
    p_ae_created := TRUE;

  ELSE
    p_ae_created := FALSE;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Execute()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ARP_RECEIPTS_MAIN.Execute - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_RECEIPTS_MAIN.Execute');
     END IF;
     RAISE;

END Execute;


/* =======================================================================
 |
 | PROCEDURE Init_Ae_Lines
 |
 | DESCRIPTION
 |      Initialises the Global lines table
 |
 | PARAMETERS
 |      NONE
 * ======================================================================*/
PROCEDURE Init_Ae_Lines IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Init_Ae_Lines()+');
  END IF;

  g_ae_line_tbl := g_empty_ae_line_tbl;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Init_Ae_Lines()-');
  END IF;
EXCEPTION

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_RECEIPTS_MAIN.Init_Ae_Lines');
     END IF;
     RAISE;

END Init_Ae_Lines;


/* =======================================================================
 |
 | PROCEDURE Derive_Accounting_Entry
 |
 | DESCRIPTION
 |      This procedure gets the necessary transaction data and determines
 |      the accounting entries to be created at each of entity level.
 |
 | PARAMETERS
 | 	Event_Rec	Global Event Record
 * ======================================================================*/
PROCEDURE Derive_Accounting_Entry
--{HYUDETUPT
  (p_from_llca_call   IN VARCHAR2,
   p_gt_id            IN NUMBER)
--}
IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Derive_Accounting_Entry()+');
     arp_standard.debug(   '     p_from_llca_call : '||p_from_llca_call);
     arp_standard.debug(   '     p_gt_id          : '||p_gt_id);
  END IF;
  /*------------------------------------------------------------+
   | Create Accounting Entries at the Document Entity level.    |
   +------------------------------------------------------------*/
  IF ( g_ae_doc_rec.accounting_entity_level = 'ONE' ) THEN

     IF ((g_ae_doc_rec.source_id_old IS NOT NULL) and (g_ae_doc_rec.other_flag = 'REVERSE')) THEN

    /*------------------------------------------------------------+
     | Reverse Accounting Entry Lines Misc Cash Receipts, Cash    |
     | Receipts and Credit Memos                                  |
     +------------------------------------------------------------*/
         Reverse_Receipt_CM;

     ELSIF ( g_ae_doc_rec.source_table = 'RA' ) THEN

       /*---------------------------------------------------------+
        | Create Accounting Entry Lines, Receipt and CM's         |
        +---------------------------------------------------------*/
           Create_Ae_Lines_Common(p_level => 'RA',
                                  --{HYUDETUPT
                                  p_from_llca_call => p_from_llca_call,
                                  p_gt_id          => p_gt_id
                                  --}
                                  );

     ELSIF ( g_ae_doc_rec.source_table = 'MCD' ) THEN

       /*---------------------------------------------------------------+
        | Create Accounting Entry Lines, Misc Cash Receipts and Payments|
        +---------------------------------------------------------------*/
            Create_Ae_Lines_Common(p_level => 'MCD',
                                  --{HYUDETUPT
                                  p_from_llca_call => p_from_llca_call,
                                  p_gt_id          => p_gt_id
                                  --}
                                  );

     END IF;

  END IF;		-- accounting_entity_level = ONE

  /*------------------------------------------------------+
   | Create Accounting Entries at the Document Level      |
   | (All Entities)                                       |
   +------------------------------------------------------*/
  IF ( g_ae_doc_rec.accounting_entity_level = 'ALL' ) THEN

	NULL;

  END IF;		-- accounting_entity_level = ALL?

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_RECEIPTS_MAIN.Derive_Accounting_Entry()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_RECEIPTS_MAIN.Derive_Accounting_Entry');
     END IF;
     RAISE;
END Derive_Accounting_Entry;

/* =======================================================================
 |
 | PROCEDURE Delete_RA
 |
 | DESCRIPTION
 |      Deletes accounting associated with a Receivable application id
 |      from the AR_DISTRIBUTIONS table.This routine deletes all records
 |      matching the input source_id. Note records from child table
 |      (AR_DISTRIBUTIONS) be deleted first.
 |
 | PARAMETERS
 |      p_ae_deleted       indicates whether records were deleted
 |                         for source_id
 * ======================================================================*/
PROCEDURE Delete_RA(p_ae_deleted          OUT NOCOPY BOOLEAN) IS

l_status                ar_receivable_applications.status%TYPE;

l_ar_dist_key_value_list   gl_ca_utility_pkg.r_key_value_arr;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_RECEIPTS_MAIN.Delete_RA()+');
    END IF;

 /*-------------------------------------------------------------------+
  | Verify that the source id is a valid candidate for deletion       |
  +-------------------------------------------------------------------*/
    SELECT ra.status
    INTO   l_status
    FROM   ar_receivable_applications ra
    WHERE  ra.receivable_application_id = g_ae_doc_rec.source_id
    /* bug 1454382 : when a receipt application is unapplied, the reversal_gl_date is populated
       even when it's only a reversal of the application and not the whole receipt, hence, this
       condition was causing an EXCEPTION when the receipt was being deleted.
       Fix is to comment out NOCOPY the following line.

    AND    ra.reversal_gl_date is null                --Not rate adjusted or reversed
    */
    AND    ra.posting_control_id = -3
    AND    g_ae_doc_rec.source_table = 'RA'
    AND    nvl(ra.confirmed_flag,'Y') = 'Y' ;

 /*----------------------------------------------------------------------+
  | Get the app id of the record with which the UNAPP is paired this     |
  | is necessary as in update mode delete is called first and then create|
  +----------------------------------------------------------------------*/
    IF l_status = 'UNAPP' THEN

       SELECT ard.source_id_secondary
       INTO   g_ae_doc_rec.source_id_old
       FROM   ar_distributions ard
       where  ard.source_id = g_ae_doc_rec.source_id
       and    ard.source_table = 'RA';

    END IF;

 /*-------------------------------------------------------------------+
  | Delete all accounting for source id and source table combination  |
  | if valid candidate for deletion                                   |
  +-------------------------------------------------------------------*/

  -- MRC Trigger Elimination:
    DELETE FROM AR_DISTRIBUTIONS
    WHERE  source_id    =  g_ae_doc_rec.source_id
    AND    source_table = 'RA';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_RECEIPTS_MAIN.Delete_RA()-');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECEIPTS_MAIN.Delete_RA - NO_DATA_FOUND' );
     END IF;
     p_ae_deleted := FALSE;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Delete_RA - OTHERS');
     END IF;
     p_ae_deleted := FALSE;
     RAISE ;

END Delete_RA;

/* =======================================================================
 |
 | PROCEDURE Delete_MCD
 |
 | DESCRIPTION
 |      Deletes accounting associated with a Miscellaneous Cash Receipt or
 |      Payment. Note record from child (AR_DISTRIBUTIONS) table must be
 |      deleted first.
 |
 | PARAMETERS
 |      p_ae_deleted       indicates whether records were deleted
 |                         for source_id
 * ======================================================================*/
PROCEDURE Delete_MCD(p_ae_deleted   OUT NOCOPY BOOLEAN) IS

CURSOR del_misc_rec IS
   SELECT mcd.misc_cash_distribution_id misc_dist_id
   FROM   ar_misc_cash_distributions mcd
   WHERE  mcd.cash_receipt_id = g_ae_doc_rec.document_id
   AND    mcd.reversal_gl_date IS NULL  --For rate adjustments picks up records with new rate not those reversed
   AND    mcd.posting_control_id = -3   --Not posted
   AND EXISTS (SELECT 'x'
               FROM  ar_distributions ard
               WHERE ard.source_id = mcd.misc_cash_distribution_id
               AND   ard.source_table = 'MCD');

l_dummy VARCHAR2(1);

l_ar_dist_key_value_list   gl_ca_utility_pkg.r_key_value_arr;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_RECEIPTS_MAIN.Delete_MCD()+');
    END IF;

    p_ae_deleted := FALSE;
    l_dummy := 'N';

    FOR l_misc_rec IN del_misc_rec LOOP

        DELETE FROM ar_distributions ard
        WHERE  ard.source_id = l_misc_rec.misc_dist_id
        AND    ard.source_table = 'MCD'
        RETURNING line_id
        BULK COLLECT INTO l_ar_dist_key_value_list;

        p_ae_deleted := TRUE;
        l_dummy := 'Y';

    END LOOP;

--Force a No data found exception to be raised if call made and no rows to delete
    SELECT 'x'
    INTO l_dummy
    FROM dual
    WHERE l_dummy = 'Y';

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_RECEIPTS_MAIN.Delete_MCD()-');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECEIPTS_MAIN.Delete_MCD - NO_DATA_FOUND' );
     END IF;
     p_ae_deleted := FALSE;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Delete_MCD');
     END IF;
     p_ae_deleted := FALSE;
     RAISE ;

END Delete_MCD;

/* =======================================================================
 |
 | PROCEDURE Reverse_Receipt_CM
 |
 | DESCRIPTION
 |      This procedure reverses the records in AR_DISTRIBUTIONS for a
 |      Misc Cash Receipt, Cash Receipts and Credit Memo applications.
 |      There is a concept of caching used for UNAPP records, as if they
 |      are paired before Reversal they need to be paired after Reversal.
 |      In order for this caching to work, the APP, ACC and UNID records
 |      must be processed before the UNAPP records
 |
 |      For Bills Receivable linked deferred tax for an application being
 |      reversed is also backed out NOCOPY by using a link id to reverse out NOCOPY the
 |      tax accounting associated with the Transaction history record for
 |      the maturity date event for a Bill. For this change a union was
 |      added and the source table is populated from g_ae_doc_rec
 |
 | PARAMETERS
 |      None
 * ======================================================================*/
PROCEDURE Reverse_Receipt_CM IS

-- MRC TRIGGER REPLACEMENT: Enumerate all columns and add two more unions
-- to retrieve MRC data

CURSOR get_old_ard  IS
       select ard.line_id,
              ard.source_type,
              ard.source_id_secondary,
              ard.source_type_secondary,
              ard.source_table_secondary,
              ard.code_combination_id,
              ard.amount_dr,
              ard.amount_cr,
              ard.acctd_amount_dr,
              ard.acctd_amount_cr,
              ard.taxable_entered_cr,
              ard.taxable_entered_dr,
              ard.taxable_accounted_cr,
              ard.taxable_accounted_dr,
              ard.currency_code,
              ard.currency_conversion_rate,
              ard.currency_conversion_type,
              ard.currency_conversion_date,
              ard.third_party_id,
              ard.third_party_sub_id,
              ard.tax_group_code_id,
              ard.tax_code_id,
              ard.location_segment_id,
              ard.tax_link_id,
              ard.ref_customer_trx_line_id,
              ard.ref_prev_cust_trx_line_id,
              ard.ref_cust_trx_line_gl_dist_id,
              ard.ref_line_id,
              --{2979254 ref_dist_ccid and ref_dist_flag
              ard.ref_dist_ccid,
              nvl(ard.ref_mf_dist_flag,
                     decode(ard.source_table||ard.source_type||app.upgrade_method||ard.ref_dist_ccid, 'RARECR12',
                         decode(abs((nvl(app.earned_discount_taken,0)+nvl(app.unearned_discount_taken,0))),
                                abs(nvl(ard.amount_dr,0)-nvl(ard.amount_cr,0)),'D'))) ref_mf_dist_flag,
              ard.ref_account_class,
              ard.activity_bucket,
              --}
              --{3377004
              ard.from_amount_dr,
              ard.from_amount_cr,
              ard.from_acctd_amount_dr,
              ard.from_acctd_amount_cr,
              DECODE(ard.ref_customer_trx_line_id, NULL, 'N',
                     DECODE(ard.ref_line_id, NULL, 'ADDCTL',
                            DECODE(line_trx_type.line_type,'CHARGES','ADDCTL',
                                    DECODE(adjsrctp.source_type||adjsrctp.activity_bucket,
                                                                 'CHARGESADJ_CHRG','ADDCHRG'
                                                                ,'FINCHRGADJ_CHRG','ADDCHRG'
                                                                ,'ADJADJ_CHRG','ADDCHRG'
                                                                ,'ADDCTL'))))    WHICH_BUCKET,
              line_trx_type.type                   trx_type
              --}
       from   ar_distributions ard,
              ar_distributions adjsrctp,
              ar_receivable_applications app,
              --{ For CM APP on legacy from 11i
             (SELECT tt.type                      type,
                     ctl.customer_trx_line_id     customer_trx_line_id,
                     ctl.line_type                line_type
                FROM ra_customer_trx_lines   ctl,
                     ra_customer_trx         trx,
                     ra_cust_trx_types       tt
               WHERE ctl.customer_trx_id  = trx.customer_trx_id
                 AND trx.cust_trx_type_id = tt.cust_trx_type_id
                 AND tt.org_id            = trx.org_id)         line_trx_type
              --}
       where  g_ae_sys_rec.sob_type = 'P'
       and    ard.source_id    = g_ae_doc_rec.source_id_old
       and    ard.source_table = g_ae_doc_rec.source_table
       and    app.receivable_application_id (+) = ard.source_id
       and    nvl(ard.source_type_secondary,'X') NOT IN
                             ('ASSIGNMENT_RECONCILE','RECONCILE')
       and    ard.ref_line_id              = adjsrctp.line_id(+)          --3377004
       and    ard.ref_customer_trx_line_id = line_trx_type.customer_trx_line_id(+)
       UNION
       select ard.line_id,
              ard.source_type,
              ard.source_id_secondary,
              ard.source_type_secondary,
              ard.source_table_secondary,
              ard.code_combination_id,
              ard.amount_dr,
              ard.amount_cr,
              ard.acctd_amount_dr,
              ard.acctd_amount_cr,
              ard.taxable_entered_cr,
              ard.taxable_entered_dr,
              ard.taxable_accounted_cr,
              ard.taxable_accounted_dr,
              ard.currency_code,
              ard.currency_conversion_rate,
              ard.currency_conversion_type,
              ard.currency_conversion_date,
              ard.third_party_id,
              ard.third_party_sub_id,
              ard.tax_group_code_id,
              ard.tax_code_id,
              ard.location_segment_id,
              ard.tax_link_id,
              ard.ref_customer_trx_line_id,
              ard.ref_prev_cust_trx_line_id,
              ard.ref_cust_trx_line_gl_dist_id,
              ard.ref_line_id,
              --{2979254 ref_dist_ccid and ref_dist_flag
              ard.ref_dist_ccid,
              ard.ref_mf_dist_flag,
              ard.ref_account_class,
              ard.activity_bucket,
              --}
              --{3377004
              ard.from_amount_dr,
              ard.from_amount_cr,
              ard.from_acctd_amount_dr,
              ard.from_acctd_amount_cr,
              DECODE(ard.ref_customer_trx_line_id, NULL, 'N',
                     DECODE(ard.ref_line_id, NULL, 'ADDCTL',
                            DECODE(line_trx_type.line_type,'CHARGES','ADDCTL',
                                    DECODE(adjsrctp.source_type||adjsrctp.activity_bucket,
                                                                 'CHARGESADJ_CHRG','ADDCHRG'
                                                                ,'FINCHRGADJ_CHRG','ADDCHRG'
                                                                ,'ADJADJ_CHRG','ADDCHRG'
                                                                ,'ADDCTL'))))    WHICH_BUCKET,
              line_trx_type.type                   trx_type
              --}
       from ar_distributions ard,
            ar_receivable_applications app,
            ar_distributions adjsrctp,
            -- For CM APP on legacy from 11i
            (SELECT tt.type                      type,
                    ctl.customer_trx_line_id     customer_trx_line_id,
                    ctl.line_type                line_type
               FROM ra_customer_trx_lines   ctl,
                    ra_customer_trx         trx,
                    ra_cust_trx_types       tt
              WHERE ctl.customer_trx_id  = trx.customer_trx_id
                AND trx.cust_trx_type_id = tt.cust_trx_type_id
                AND tt.org_id            = trx.org_id)         line_trx_type
             --}
       where g_ae_sys_rec.sob_type = 'P'
       and   app.receivable_application_id = g_ae_doc_rec.source_id_old
       and   ard.source_id = app.link_to_trx_hist_id
       and   nvl(ard.source_type_secondary,'X') NOT IN
                             ('ASSIGNMENT_RECONCILE','RECONCILE')
       and   ard.source_table = 'TH' --for Bills Receivable Standard/Factored
       and   nvl(g_ae_doc_rec.event,'NONE') <> 'RISK_UNELIMINATED'
       and   ard.ref_line_id  = adjsrctp.line_id(+)          --3377004
       and   ard.ref_customer_trx_line_id = line_trx_type.customer_trx_line_id(+)
	   order by 1;

-- The maintenance of the line balances is not required for transaction marked as R12_11ICASH
CURSOR verif_trx_mark(p_app_id IN NUMBER)
IS
SELECT trx.upgrade_method                  trx_upgrade_method,
       app.applied_customer_trx_id   trx_id,
       cm.upgrade_method                   cm_upgrade_method,
       app.customer_trx_id           cm_id,
       app.upgrade_method                  app_upgrade_method
  FROM ar_receivable_applications app,
       ra_customer_trx            trx,
       ra_customer_trx            cm
 WHERE app.receivable_application_id = p_app_id
   AND app.applied_customer_trx_id   = trx.customer_trx_id
   AND app.customer_trx_id           = cm.customer_trx_id(+);

l_record_mark     verif_trx_mark%ROWTYPE;
l_trx_rec         ra_customer_trx%ROWTYPE;
l_requery         VARCHAR2(1) := 'N';
/*-------------------------------------------------------------------+
 | Get exchange rate, third part details and amounts for transaction |
 | to which application has been made. There is a bit of redundancy  |
 | as the main select routine for document could be used, however    |
 | did not want to destabilize any logic in Get_Doc_Entitity_Data    |
 +-------------------------------------------------------------------*/
CURSOR get_app_details IS
SELECT app.applied_customer_trx_id                 applied_customer_trx_id,
       app.application_type                        application_type,
       app.amount_applied + nvl(app.earned_discount_taken,0)
       + nvl(app.unearned_discount_taken,0)        amount_applied     ,
       nvl(app.acctd_amount_applied_to,0) +
       nvl(app.acctd_earned_discount_taken,0) +
       nvl(app.acctd_unearned_discount_taken,0)    acctd_amount_applied_to,
       app.customer_trx_id                          customer_trx_id,
       app.acctd_amount_applied_from                     acctd_amount_applied_from,
       ctinv.invoice_currency_code                       invoice_currency_code,
       ctinv.exchange_rate                           exchange_rate,
       ctinv.exchange_rate_type   exchange_rate_type,
       ctinv.exchange_date                          exchange_date,
       ctinv.trx_date                               trx_date,
       ctinv.bill_to_customer_id                    bill_to_customer_id,
       ctinv.bill_to_site_use_id                    bill_to_site_use_id,
       ctinv.drawee_id                              drawee_id,
       ctinv.drawee_site_use_id                     drawee_site_use_id,
       ctcm.invoice_currency_code                   cm_invoice_currency_code,
       ctcm.exchange_rate                           cm_exchange_rate,
      ctcm.exchange_rate_type                       cm_exchange_rate_type,
       ctcm.exchange_date                           cm_exchange_date,
       ctcm.trx_date                                cm_trx_date,
       ctcm.bill_to_customer_id                     cm_bill_to_customer_id,
       ctcm.bill_to_site_use_id                     cm_bill_to_site_use_id
       from ar_receivable_applications app  ,
            ra_customer_trx            ctinv,
            ra_customer_trx            ctcm
       where app.receivable_application_id = g_ae_doc_rec.source_id_old
       and   app.status = 'APP'
       and   nvl(confirmed_flag,'Y') = 'Y'
       and   g_ae_doc_rec.source_table = 'RA'
       and   app.applied_customer_trx_id = ctinv.customer_trx_id
       and   app.customer_trx_id = ctcm.customer_trx_id (+);

l_ael_line_rec              ae_line_rec_type;
l_ael_empty_line_rec        ae_line_rec_type;
i                           BINARY_INTEGER:= 1;
l_set_pairing_id            BOOLEAN:= FALSE;
l_ae_line_tbl               ae_line_tbl_type;
l_ae_ctr                    NUMBER;
l_ctr                       NUMBER;
l_cust_inv_rec              ra_customer_trx%ROWTYPE;
l_cust_cm_rec               ra_customer_trx%ROWTYPE;
l_applied_customer_trx_id   NUMBER;
l_amount_applied            NUMBER;
l_acctd_amount_applied_to   NUMBER;
--{3377004
l_ctl_rem_amt               ctl_rem_amt_type;
l_index                     NUMBER := 0;
l_app_upg_method            ar_receivable_applications.upgrade_method%type;

--}
BEGIN
  arp_standard.debug( 'ARP_RECEIPTS_MAIN.Reverse_Receipt_CM()+');

   -- Check for upgrade_method
   OPEN verif_trx_mark(g_ae_doc_rec.source_id_old);
   FETCH verif_trx_mark INTO l_record_mark;
   IF verif_trx_mark%NOTFOUND THEN
      -- Nothing will happen as no distributions will be picked up
      l_requery := 'N';
   ELSE
      l_requery := 'N';
	  IF l_record_mark.trx_upgrade_method IS NULL AND l_record_mark.trx_id IS NOT NULL THEN
	    l_trx_rec.customer_trx_id := l_record_mark.trx_id;
	    arp_det_dist_pkg.set_original_rem_amt(p_customer_trx => l_trx_rec);
        l_requery  := 'Y';
      END IF;
      IF l_record_mark.cm_upgrade_method IS NULL AND l_record_mark.cm_id IS NOT NULL THEN
	    l_trx_rec.customer_trx_id := l_record_mark.cm_id;
	    arp_det_dist_pkg.set_original_rem_amt(p_customer_trx => l_trx_rec);
        l_requery  := 'Y';
      END IF;

      l_app_upg_method := l_record_mark.app_upgrade_method;
   END IF;
   CLOSE verif_trx_mark;

   IF l_requery = 'Y' THEN
     OPEN verif_trx_mark(g_ae_doc_rec.source_id_old);
     FETCH verif_trx_mark INTO l_record_mark;
     CLOSE verif_trx_mark;
   END IF;
   --}
   --ard_cash_receipt_id Global variable for package
    IF ard_cash_receipt_id <> g_ae_doc_rec.document_id THEN

    --Initialise pairing table for UNAPP records for new CR

      ae_app_pair_tbl  := g_empty_ae_app_pair_tbl;
      ae_app_pair_tbl_ctr := 0;
      ard_cash_receipt_id := g_ae_doc_rec.document_id;

    END IF;

    FOR l_ard_rec in get_old_ard LOOP

     --Initialize build record
       l_ael_line_rec := l_ael_empty_line_rec ;

     --There is a chance that the current record may have a paired UNAPP record
     --so cache the new app and old app source id's in the table to determine pairing in Rel 11.5
     /* J Rautiainen BR Implementation */
       IF l_ard_rec.source_type IN ('REC', 'ACC', 'UNID','SHORT_TERM_DEBT','FACTOR','REMITTANCE','UNPAIDREC',
                                    'OTHER ACC','ACTIVITY') THEN

          ae_app_pair_tbl_ctr := ae_app_pair_tbl_ctr + 1;
          ae_app_pair_tbl(ae_app_pair_tbl_ctr).status        := l_ard_rec.source_type;
          ae_app_pair_tbl(ae_app_pair_tbl_ctr).source_id     := g_ae_doc_rec.source_id;
          ae_app_pair_tbl(ae_app_pair_tbl_ctr).source_id_old := g_ae_doc_rec.source_id_old;
          ae_app_pair_tbl(ae_app_pair_tbl_ctr).source_table  := g_ae_doc_rec.source_table;

       ELSIF l_ard_rec.source_type = 'UNAPP' AND ae_app_pair_tbl.EXISTS(ae_app_pair_tbl_ctr) THEN

             FOR i IN ae_app_pair_tbl.FIRST .. ae_app_pair_tbl.LAST LOOP

              --We have hit the APP record associated with this UNAPP record
                IF ae_app_pair_tbl(i).source_id_old = l_ard_rec.source_id_secondary  THEN
                  l_ael_line_rec.source_id_secondary    := ae_app_pair_tbl(i).source_id; -- Pair New UNAPP with new APP
                  l_ael_line_rec.source_table_secondary := ae_app_pair_tbl(i).source_table;
                  l_set_pairing_id := TRUE;
                  EXIT;
                END IF;

             --If a Release pre release 11.0 receipt is being reversed then there would be no
             --secondary id populated to indicate pairing as it is difficult to determine this,
             --this would be part of a future release.

             END LOOP;
       END IF;

       l_ael_line_rec.ae_line_type               := l_ard_rec.source_type            ;
       l_ael_line_rec.ae_line_type_secondary     := l_ard_rec.source_type_secondary  ;
       l_ael_line_rec.source_id                  := g_ae_doc_rec.source_id           ;
       l_ael_line_rec.source_table               := g_ae_doc_rec.source_table        ;

       IF (NOT l_set_pairing_id) THEN --if not set above
          l_ael_line_rec.source_id_secondary        := l_ard_rec.source_id_secondary    ;
          l_ael_line_rec.source_table_secondary     := l_ard_rec.source_table_secondary ;
       END IF;

       l_ael_line_rec.account                    := l_ard_rec.code_combination_id    ;

     --Set reversed source id for APP - REC records only for Receipts as this is a
     --requirement by MRC to know which gain or loss account needs to be offset in
     --their reporting set of books as for all APP records there could be a gain or
     --loss
     /* J Rautiainen BR implementation */
       IF ((g_ae_doc_rec.source_table = 'RA') AND
           (l_ard_rec.source_type in ('REC','FACTOR','REMITTANCE','UNPAIDREC',
           --{3377004
           'EDISC','UNEDISC'))) THEN
           --EDISC and UNEDISC should be also back out from Reversal process
           --otherwise the line level balance will be wrong because the amounts
           --affected to EDISC and UNEDISC are missing
           --}
          l_ael_line_rec.reversed_source_id         := g_ae_doc_rec.source_id_old     ;
       END IF;

     -- For reversals swap debits and credits
       l_ael_line_rec.entered_cr   := l_ard_rec.amount_dr;
       l_ael_line_rec.accounted_cr := l_ard_rec.acctd_amount_dr;

       l_ael_line_rec.entered_dr   := l_ard_rec.amount_cr;
       l_ael_line_rec.accounted_dr := l_ard_rec.acctd_amount_cr;

       l_ael_line_rec.taxable_entered_cr    := l_ard_rec.taxable_entered_dr;
       l_ael_line_rec.taxable_accounted_cr  := l_ard_rec.taxable_accounted_dr;

       l_ael_line_rec.taxable_entered_dr    := l_ard_rec.taxable_entered_cr;
       l_ael_line_rec.taxable_accounted_dr  := l_ard_rec.taxable_accounted_cr;

       l_ael_line_rec.currency_code               := l_ard_rec.currency_code;
       l_ael_line_rec.currency_conversion_rate    := l_ard_rec.currency_conversion_rate;
       l_ael_line_rec.currency_conversion_type    := l_ard_rec.currency_conversion_type;
       l_ael_line_rec.currency_conversion_date    := l_ard_rec.currency_conversion_date;
       l_ael_line_rec.third_party_id              := l_ard_rec.third_party_id;
       l_ael_line_rec.third_party_sub_id          := l_ard_rec.third_party_sub_id;
       l_ael_line_rec.tax_group_code_id           := l_ard_rec.tax_group_code_id;
       l_ael_line_rec.tax_code_id                 := l_ard_rec.tax_code_id;
       l_ael_line_rec.location_segment_id         := l_ard_rec.location_segment_id;
       l_ael_line_rec.tax_link_id                 := l_ard_rec.tax_link_id;
       --{BUG#2979254
       l_ael_line_rec.ref_customer_trx_line_id    := l_ard_rec.ref_customer_trx_line_id;
       l_ael_line_rec.ref_prev_cust_trx_line_id   := l_ard_rec.ref_prev_cust_trx_line_id;
       l_ael_line_rec.ref_cust_trx_line_gl_dist_id:= l_ard_rec.ref_cust_trx_line_gl_dist_id;
       l_ael_line_rec.ref_line_id                 := l_ard_rec.ref_line_id;
       --}
       --{ref_dist_ccid + ref_mf_dist_flag
       l_ael_line_rec.ref_account_class                   := l_ard_rec.ref_account_class;
       l_ael_line_rec.activity_bucket                      := l_ard_rec.activity_bucket;
       l_ael_line_rec.ref_dist_ccid               := l_ard_rec.ref_dist_ccid;

       /**during the upgrade MFAR cash and eversal rows are created from  PSA in ARD as
          a RA row hence we need to explictly set the flag to Y in order to pass the
	  accounts in ARD as it is to XLA and GL with out deriving the ccid's using
	  BSV or Account via business flows
       */
       IF NVL(l_app_upg_method,'NULL') = '11I_MFAR_UPG' THEN
	   l_ael_line_rec.ref_mf_dist_flag := 'U';
       ELSE
           l_ael_line_rec.ref_mf_dist_flag            := l_ard_rec.ref_mf_dist_flag;
       END IF;

       --}
       --{3377004
       l_ael_line_rec.from_amount_dr              := l_ard_rec.from_amount_cr;
       l_ael_line_rec.from_amount_cr              := l_ard_rec.from_amount_dr;
       l_ael_line_rec.from_acctd_amount_dr        := l_ard_rec.from_acctd_amount_cr;
       l_ael_line_rec.from_acctd_amount_cr        := l_ard_rec.from_acctd_amount_dr;
       --}
       -- Assign AEL for Reversal
       Assign_Ael_Elements( p_ae_line_rec        => l_ael_line_rec );

      --{3377004
      arp_standard.debug(' l_ard_rec.WHICH_BUCKET:'||l_ard_rec.WHICH_BUCKET);
      arp_standard.debug(' l_ard_rec.ref_customer_trx_line_id:'||l_ard_rec.ref_customer_trx_line_id);
      arp_standard.debug(' l_ard_rec.ref_prev_cust_trx_line_id:'||l_ard_rec.ref_prev_cust_trx_line_id);
      arp_standard.debug(' l_ard_rec.ref_line_id:'||l_ard_rec.ref_line_id);
      arp_standard.debug(' trx_upgrade_method         :'||l_record_mark.trx_upgrade_method);
      arp_standard.debug(' cm_upgrade_method          :'||l_record_mark.cm_upgrade_method);
      arp_standard.debug(' ard.ref_mf_dist_flag       :'||NVL(l_ard_rec.ref_mf_dist_flag,'Y') );

      IF  l_ard_rec.WHICH_BUCKET = 'N'  OR NVL(l_ard_rec.ref_mf_dist_flag,'Y') = 'N'  THEN

         NULL;

      ELSIF l_ard_rec.WHICH_BUCKET = 'ADDCTL' THEN

         IF (l_ard_rec.trx_type  IN ('INV', 'DM')  /*Bug 8552302 */
		         AND l_record_mark.trx_upgrade_method  NOT IN ('R12_11ICASH','R12_NLB')) OR
		    (l_ard_rec.trx_type  = 'CM'
			     AND l_record_mark.cm_upgrade_method   NOT IN ('R12_11ICASH','R12_NLB'))
		 THEN --HYUNLB

           l_index := ctl_id_index(l_ctl_rem_amt.customer_trx_line_id,
                                   l_ard_rec.ref_customer_trx_line_id);

           IF NOT l_ctl_rem_amt.amount_due_remaining.EXISTS(l_index) THEN
             init_rem_amt(x_rem_amt => l_ctl_rem_amt,
                          p_index   => l_index);
           END IF;

           l_ctl_rem_amt.customer_trx_line_id(l_index) := l_ard_rec.ref_customer_trx_line_id;

           IF l_ard_rec.source_type IN ('EDISC','UNEDISC') THEN
             l_ctl_rem_amt.amount_due_remaining(l_index) :=
                 NVL(l_ctl_rem_amt.amount_due_remaining(l_index),0)
                 + (-NVL(l_ard_rec.amount_cr,0) + NVL(l_ard_rec.amount_dr,0));

             l_ctl_rem_amt.acctd_amount_due_remaining(l_index) :=
                 NVL(l_ctl_rem_amt.acctd_amount_due_remaining(l_index),0)
              + (NVL(-l_ard_rec.acctd_amount_cr,0) + NVL(l_ard_rec.acctd_amount_dr,0));
           ELSE
             l_ctl_rem_amt.amount_due_remaining(l_index) :=
                 NVL(l_ctl_rem_amt.amount_due_remaining(l_index),0)
              + (NVL(l_ard_rec.amount_cr,0) - NVL(l_ard_rec.amount_dr,0));

             l_ctl_rem_amt.acctd_amount_due_remaining(l_index) :=
               NVL(l_ctl_rem_amt.acctd_amount_due_remaining(l_index),0)
              + (NVL(l_ard_rec.acctd_amount_cr,0) - NVL(l_ard_rec.acctd_amount_dr,0));
           END IF;
           arp_standard.debug('l_ctl_rem_amt.customer_trx_line_id('||l_index||'):'||
                               l_ctl_rem_amt.customer_trx_line_id(l_index));
           arp_standard.debug('l_ctl_rem_amt.amount_due_remaining('||l_index||'):'||
                               l_ctl_rem_amt.amount_due_remaining(l_index));
           arp_standard.debug('l_ctl_rem_amt.acctd_amount_due_remaining('||l_index||'):'||
                               l_ctl_rem_amt.acctd_amount_due_remaining(l_index));

         END IF; --1

     ELSIF l_ard_rec.WHICH_BUCKET = 'ADDCHRG' THEN

         IF (l_ard_rec.trx_type  IN ('INV', 'DM')
		         AND l_record_mark.trx_upgrade_method  NOT IN ('R12_11ICASH','R12_NLB')) OR
		    (l_ard_rec.trx_type  = 'CM'
			     AND l_record_mark.cm_upgrade_method   NOT IN ('R12_11ICASH','R12_NLB'))
		 THEN --HYUNLB

            l_index := ctl_id_index(l_ctl_rem_amt.customer_trx_line_id,
                                    l_ard_rec.ref_customer_trx_line_id);

            IF NOT l_ctl_rem_amt.chrg_amount_remaining.EXISTS(l_index) THEN
              init_rem_amt(x_rem_amt => l_ctl_rem_amt,
                           p_index   => l_index);
            END IF;

            l_ctl_rem_amt.customer_trx_line_id(l_index) := l_ard_rec.ref_customer_trx_line_id;

           IF l_ard_rec.source_type IN ('EDISC','UNEDISC') THEN
             l_ctl_rem_amt.chrg_amount_remaining(l_index) :=
                NVL(l_ctl_rem_amt.chrg_amount_remaining(l_index),0)
                + (-NVL(l_ard_rec.amount_cr,0) + NVL(l_ard_rec.amount_dr,0));

             l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index) :=
              NVL(l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index),0)
               + (-NVL(l_ard_rec.acctd_amount_cr,0) + NVL(l_ard_rec.acctd_amount_dr,0));
           ELSE
             l_ctl_rem_amt.chrg_amount_remaining(l_index) :=
                NVL(l_ctl_rem_amt.chrg_amount_remaining(l_index),0)
                + (NVL(l_ard_rec.amount_cr,0) - NVL(l_ard_rec.amount_dr,0));

             l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index) :=
                NVL(l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index),0)
                + (NVL(l_ard_rec.acctd_amount_cr,0) - NVL(l_ard_rec.acctd_amount_dr,0));
           END IF;
           arp_standard.debug('l_ctl_rem_amt.customer_trx_line_id('||l_index||'):'||
                               l_ctl_rem_amt.customer_trx_line_id(l_index));
           arp_standard.debug('l_ctl_rem_amt.chrg_amount_remaining('||l_index||'):'||
                               l_ctl_rem_amt.chrg_amount_remaining(l_index));
           arp_standard.debug('l_ctl_rem_amt.chrg_acctd_amount_remaining('||l_index||'):'||
                               l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index));

         END IF;
       END IF;

    --}
    END LOOP;

    --{bug#4554703 - cm reversal needs to flag the app record as r12
    -- always. There should not be any differences
    UPDATE ar_receivable_applications
    SET upgrade_method = 'R12'
    WHERE receivable_application_id = g_ae_doc_rec.source_id;
    --}

    --{3377004
    IF l_index <> 0 THEN

      FORALL m IN l_ctl_rem_amt.customer_trx_line_id.FIRST .. l_ctl_rem_amt.customer_trx_line_id.LAST
      UPDATE ra_customer_trx_lines
      SET  AMOUNT_DUE_REMAINING        = AMOUNT_DUE_REMAINING        + l_ctl_rem_amt.amount_due_remaining(m),
           ACCTD_AMOUNT_DUE_REMAINING  = ACCTD_AMOUNT_DUE_REMAINING  + l_ctl_rem_amt.acctd_amount_due_remaining(m),
           CHRG_AMOUNT_REMAINING       = CHRG_AMOUNT_REMAINING       + l_ctl_rem_amt.chrg_amount_remaining(m),
           CHRG_ACCTD_AMOUNT_REMAINING = CHRG_ACCTD_AMOUNT_REMAINING + l_ctl_rem_amt.chrg_acctd_amount_remaining(m)
      WHERE customer_trx_line_id       = l_ctl_rem_amt.customer_trx_line_id(m);

      --BUG#4753570 make the amount on trx line and gloabl has to in sync
      FORALL m IN l_ctl_rem_amt.customer_trx_line_id.FIRST .. l_ctl_rem_amt.customer_trx_line_id.LAST
      UPDATE ra_customer_trx_lines_gt
      SET  AMOUNT_DUE_REMAINING        = AMOUNT_DUE_REMAINING        + l_ctl_rem_amt.amount_due_remaining(m),
           ACCTD_AMOUNT_DUE_REMAINING  = ACCTD_AMOUNT_DUE_REMAINING  + l_ctl_rem_amt.acctd_amount_due_remaining(m),
           CHRG_AMOUNT_REMAINING       = CHRG_AMOUNT_REMAINING       + l_ctl_rem_amt.chrg_amount_remaining(m),
           CHRG_ACCTD_AMOUNT_REMAINING = CHRG_ACCTD_AMOUNT_REMAINING + l_ctl_rem_amt.chrg_acctd_amount_remaining(m)
      WHERE customer_trx_line_id       = l_ctl_rem_amt.customer_trx_line_id(m);


    END IF;
    --}

 /*-----------------------------------------------------------------------------------+
  |Call the Reconciliation routine, this is necessary because the transaction or Bill |
  |which may have been overapplied is now closed due to reversal, or else the reversal|
  |may have resulted in re-opening the transaction, hence we need to back out NOCOPY the old |
  |reconciliation entries for the Bill or the Transactions                            |
  +-----------------------------------------------------------------------------------*/
     FOR l_get_app in get_app_details LOOP --loop executes once only for APP

      /*-------------------------------------------------------------------------------+
       | Set currency and exchange rate details to that of the document which has been |
       | applied. These details will get overriden by the transaction line assignment  |
       | exchange rate details for Bill.                                               |
       +-------------------------------------------------------------------------------*/
         l_cust_inv_rec.invoice_currency_code := l_get_app.invoice_currency_code;
         l_cust_inv_rec.exchange_rate         := l_get_app.exchange_rate;
         l_cust_inv_rec.exchange_rate_type    := l_get_app.exchange_rate_type;
         l_cust_inv_rec.exchange_date         := l_get_app.exchange_date;
         l_cust_inv_rec.trx_date              := l_get_app.trx_date;
         l_cust_inv_rec.bill_to_customer_id   := l_get_app.bill_to_customer_id;
         l_cust_inv_rec.bill_to_site_use_id   := l_get_app.bill_to_site_use_id;
         l_cust_inv_rec.drawee_id             := l_get_app.drawee_id;
         l_cust_inv_rec.drawee_site_use_id    := l_get_app.drawee_site_use_id;

    --Required to determine whether the payment schedule is closed or not
         l_applied_customer_trx_id            := l_get_app.applied_customer_trx_id;
         l_amount_applied                     := l_get_app.amount_applied;
         l_acctd_amount_applied_to            := l_get_app.acctd_amount_applied_to;

         ARP_RECONCILE.Reconcile_trx_br(
              p_mode                     => g_mode                             ,
              p_ae_doc_rec               => g_ae_doc_rec                       ,
              p_ae_event_rec             => g_ae_event_rec                     ,
              p_cust_inv_rec             => l_cust_inv_rec                     ,
              p_activity_cust_trx_id     => l_applied_customer_trx_id          ,
              p_activity_amt             => l_amount_applied * -1              ,
              p_activity_acctd_amt       => l_acctd_amount_applied_to   * -1   ,
              p_call_num                 => 1                                  ,
              p_g_ae_line_tbl            => g_ae_line_tbl                      ,
              p_g_ae_ctr                 => g_ae_line_ctr                         );

         IF l_get_app.application_type = 'CM' THEN
               l_cust_cm_rec.invoice_currency_code := l_get_app.cm_invoice_currency_code;
               l_cust_cm_rec.exchange_rate         := l_get_app.cm_exchange_rate;
               l_cust_cm_rec.exchange_rate_type    := l_get_app.cm_exchange_rate_type;
               l_cust_cm_rec.exchange_date         := l_get_app.cm_exchange_date;
               l_cust_cm_rec.trx_date              := l_get_app.cm_trx_date;
               l_cust_cm_rec.bill_to_customer_id   := l_get_app.cm_bill_to_customer_id;
               l_cust_cm_rec.bill_to_site_use_id   := l_get_app.cm_bill_to_site_use_id;

          --Required to determine whether the payment schedule is closed or not
               l_applied_customer_trx_id           := l_get_app.customer_trx_id;
               l_amount_applied                    := l_get_app.amount_applied;
               l_acctd_amount_applied_to           := l_get_app.acctd_amount_applied_from;

               ARP_RECONCILE.Reconcile_trx_br(
                 p_mode                     => g_mode                             ,
                 p_ae_doc_rec               => g_ae_doc_rec                       ,
                 p_ae_event_rec             => g_ae_event_rec                     ,
                 p_cust_inv_rec             => l_cust_inv_rec                     ,
                 p_activity_cust_trx_id     => l_applied_customer_trx_id          ,
                 p_activity_amt             => l_amount_applied                   ,
                 p_activity_acctd_amt       => l_acctd_amount_applied_to          ,
                 p_call_num                 => 2                                  ,
                 p_g_ae_line_tbl            => g_ae_line_tbl                      ,
                 p_g_ae_ctr                 => g_ae_line_ctr                        );

         END IF; --application type is CM

     END LOOP; -- reconciliation routine called for applications

  arp_standard.debug( 'ARP_RECEIPTS_MAIN.Reverse_Receipt_CM()-');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     arp_standard.debug('ARP_RECEIPTS_MAIN.Reverse_Receipt_CM - NO_DATA_FOUND' );
     RAISE;

  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Reverse_Receipt_CM:'||SQLERRM);
     RAISE ;

END Reverse_Receipt_CM;

/* =======================================================================
 |
 | PROCEDURE Get_Doc_Entitity_Data
 |
 | DESCRIPTION
 |      This procedure gets the necessary transaction data for each entity
 |      level.
 |
 | PARAMETERS
 | 	p_level          Entitity Level
 |      p_app_rec        Application Record
 |      p_cr_rec         Cash Receipt Record
 |      p_cust_inv_rec   Invoice document or On Account Credit Memo data
 |      p_cust_cm_rec    Credit Memo data
 |      p_ctlgd_cm_rec   Receivable account for Credit Memo
 |      p_miscel_rec     Gain Loss ccid and fixed rate flag
 |      p_vat_rec        Tax details
 |      p_curr_rec       Currency details for Misc Cash document
 |
 | NOTES
 |     The variables miscle1..8 hold currency, exchange rate and pay from
 |     customer, site information. This is necessary because it may be
 |     possible that the Receipt is cached and the applications are created
 |     first as in autoreceipts, hence if the outer join to cash receipts
 |     returns a null then the document structure values are used.
 |
 | MODIFICATION HISTORY
 |     S.Nambiar      14-May-01  Balancing segment for ACTIVITY applications
 |                               will be replaced with balancing segment
 |                               of receipt's UNAPP.
 * ======================================================================*/
PROCEDURE Get_Doc_Entitity_Data (
                p_level          IN VARCHAR2                            ,
                p_app_rec        OUT NOCOPY ar_receivable_applications%ROWTYPE ,
                p_cr_rec         OUT NOCOPY ar_cash_receipts%ROWTYPE           ,
                p_cust_inv_rec   OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_cust_cm_rec    OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_ctlgd_cm_rec   OUT NOCOPY ra_cust_trx_line_gl_dist%ROWTYPE   ,
                p_miscel_rec     OUT NOCOPY g_ae_miscel_rec_type               ,
                p_vat_rec        OUT NOCOPY ar_vat_tax%ROWTYPE                 ,
                p_curr_rec       OUT NOCOPY ae_curr_rec_type                   ,
                p_rule_rec       OUT NOCOPY ae_rule_rec_type) IS

l_gain_loss_ccid ar_system_parameters.code_combination_id_gain%TYPE;
l_concat_segs    varchar2(240)  ;
l_concat_ids     varchar2(2000) ;
l_concat_descs   varchar2(2000) ;
l_arerror        varchar2(2000) ;
l_id_dummy       ar_receivable_applications.code_combination_id%TYPE;
l_cr_unapp_ccid  ar_receivable_applications.code_combination_id%TYPE;
l_le_id          NUMBER;
l_effective_date DATE;
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(1024);
l_return_status  VARCHAR2(10);
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_RECEIPTS_MAIN.Get_Doc_Entitity_Data()+');
   END IF;

   IF p_level = 'RA' then

      select ra.receivable_application_id                      ,
             ra.applied_customer_trx_id                        ,
             ra.customer_trx_id                                ,
             ra.applied_payment_schedule_id                    ,
             ra.code_combination_id                            ,
             ra.amount_applied                                 ,
             ra.amount_applied_from                            ,
              ra.acctd_amount_applied_to              acctd_amount_applied_to,
              ra.acctd_amount_applied_from             acctd_amount_applied_from,
             ra.line_applied                                   ,
             ra.tax_applied                                    ,
             ra.freight_applied                                ,
             ra.receivables_charges_applied                    ,
             ra.earned_discount_ccid                           ,
             ra.earned_discount_taken                          ,
             ra.acctd_earned_discount_taken     acctd_earned_discount_taken,
             ra.line_ediscounted                               ,
             ra.tax_ediscounted                                ,
             ra.freight_ediscounted                            ,
             ra.charges_ediscounted                            ,
             ra.unearned_discount_ccid                         ,
             ra.unearned_discount_taken                        ,
             ra.acctd_unearned_discount_taken    acctd_unearned_discount_taken,
             ra.line_uediscounted                              ,
             ra.tax_uediscounted                               ,
             ra.freight_uediscounted                           ,
             ra.charges_uediscounted                           ,
             ra.status                                         ,
             ra.application_type                               ,
             ra.application_ref_id                             ,
             ra.cash_receipt_id                                ,
             ra.reversal_gl_date                               ,
             ra.apply_date                                     ,
             ra.confirmed_flag                                 ,
             ra.receivables_trx_id			       ,
             ra.cash_receipt_id                                ,
             nvl(cr.currency_code, g_ae_doc_rec.miscel1)       ,
             nvl(cr.exchange_rate, g_ae_doc_rec.miscel2),
             nvl(cr.exchange_rate_type, g_ae_doc_rec.miscel3),
             nvl(cr.exchange_date, g_ae_doc_rec.miscel4),
             nvl(cr.pay_from_customer, g_ae_doc_rec.miscel5)   ,
             nvl(cr.customer_site_use_id, g_ae_doc_rec.miscel6),
             nvl(cr.remit_bank_acct_use_id,g_ae_doc_rec.miscel7),
             nvl(cr.receipt_method_id, g_ae_doc_rec.miscel8)   ,
             ctinv.invoice_currency_code                       ,
             ctinv.exchange_rate,
             ctinv.exchange_rate_type,
             ctinv.exchange_date,
             ctinv.trx_date                                    ,
             ctinv.bill_to_customer_id                         ,
             ctinv.bill_to_site_use_id                         ,
             ctinv.drawee_id                                   ,
             ctinv.drawee_site_use_id                          ,
             ctinv.upgrade_method                                    , --Invoice upgrade_method
             ctinv.customer_trx_id                             ,
             ctcm.invoice_currency_code                        ,
             ctcm.trx_date                                     ,
             ctcm.exchange_rate,
             ctcm.exchange_rate_type ,
             ctcm.exchange_date,
             ctcm.bill_to_customer_id                          ,
             ctcm.bill_to_site_use_id                          ,
             ctcm.upgrade_method                                     , --Cm upgrade_method
             ctcm.customer_trx_id                              ,
             ctlgdcm.code_combination_id                       ,
             decode(ra.status,
                    'APP', decode(
                               sign(ra.acctd_amount_applied_from -
                                    ra.acctd_amount_applied_to),
                                  -1, g_ae_sys_rec.loss_cc_id,
                                   1, g_ae_sys_rec.gain_cc_id,
                                   ''),
                    'ACTIVITY', decode(
                                   sign(ra.acctd_amount_applied_from -
                                        ra.acctd_amount_applied_to),
                                    -1, g_ae_sys_rec.loss_cc_id,
                                     1, g_ae_sys_rec.gain_cc_id,
                                    '')),
             DECODE(g_ae_doc_rec.document_type,'CREDIT_MEMO',ra.code_combination_id,rma.unapplied_ccid) -- Bug 4112494 CM refunds
      into   p_app_rec.receivable_application_id        ,
             p_app_rec.applied_customer_trx_id          ,
             p_app_rec.customer_trx_id                  ,
             p_app_rec.applied_payment_schedule_id      ,
             p_app_rec.code_combination_id              ,
             p_app_rec.amount_applied                   ,
             p_app_rec.amount_applied_from              ,
             p_app_rec.acctd_amount_applied_to          ,
             p_app_rec.acctd_amount_applied_from        ,
             p_app_rec.line_applied                     ,
             p_app_rec.tax_applied                      ,
             p_app_rec.freight_applied                  ,
             p_app_rec.receivables_charges_applied      ,
             p_app_rec.earned_discount_ccid             ,
             p_app_rec.earned_discount_taken            ,
             p_app_rec.acctd_earned_discount_taken      ,
             p_app_rec.line_ediscounted                 ,
             p_app_rec.tax_ediscounted                  ,
             p_app_rec.freight_ediscounted              ,
             p_app_rec.charges_ediscounted              ,
             p_app_rec.unearned_discount_ccid           ,
             p_app_rec.unearned_discount_taken          ,
             p_app_rec.acctd_unearned_discount_taken    ,
             p_app_rec.line_uediscounted                ,
             p_app_rec.tax_uediscounted                 ,
             p_app_rec.freight_uediscounted             ,
             p_app_rec.charges_uediscounted             ,
             p_app_rec.status                           ,
             p_app_rec.application_type                 ,
             p_app_rec.application_ref_id               ,
             p_app_rec.cash_receipt_id                  ,
             p_app_rec.reversal_gl_date                 ,
             p_app_rec.apply_date                       ,
             p_app_rec.confirmed_flag                   ,
	     p_app_rec.receivables_trx_id               ,
             p_cr_rec.cash_receipt_id                   ,
             p_cr_rec.currency_code                     ,
             p_cr_rec.exchange_rate                     ,
             p_cr_rec.exchange_rate_type                ,
             p_cr_rec.exchange_date                     ,
             p_cr_rec.pay_from_customer                 ,
             p_cr_rec.customer_site_use_id              ,
             p_cr_rec.remit_bank_acct_use_id        ,
             p_cr_rec.receipt_method_id                 ,
             p_cust_inv_rec.invoice_currency_code       ,
             p_cust_inv_rec.exchange_rate               ,
             p_cust_inv_rec.exchange_rate_type          ,
             p_cust_inv_rec.exchange_date               ,
             p_cust_inv_rec.trx_date                    ,
             p_cust_inv_rec.bill_to_customer_id         ,
             p_cust_inv_rec.bill_to_site_use_id         ,
             p_cust_inv_rec.drawee_id                   ,
             p_cust_inv_rec.drawee_site_use_id          ,
             p_cust_inv_rec.upgrade_method                    ,    -- Invoice upgrade_method
             p_cust_inv_rec.customer_trx_id             ,
             p_cust_cm_rec.invoice_currency_code        ,
	     p_cust_cm_rec.trx_date                     ,
             p_cust_cm_rec.exchange_rate                ,
             p_cust_cm_rec.exchange_rate_type           ,
             p_cust_cm_rec.exchange_date                ,
             p_cust_cm_rec.bill_to_customer_id          ,
             p_cust_cm_rec.bill_to_site_use_id          ,
             p_cust_cm_rec.upgrade_method                     ,    -- CM upgrade_method
             p_cust_cm_rec.customer_trx_id              ,
             p_ctlgd_cm_rec.code_combination_id         ,
             l_gain_loss_ccid                           ,
             l_cr_unapp_ccid
      from ar_receivable_applications ra      ,
           ar_cash_receipts           cr      ,
           ar_receipt_method_accounts rma     ,
           ra_customer_trx            ctinv   ,
           ra_customer_trx            ctcm    ,
           ra_cust_trx_line_gl_dist   ctlgdcm
      where ra.receivable_application_id = g_ae_doc_rec.source_id
      and   ra.cash_receipt_id = cr.cash_receipt_id (+)              --CR UNID, ACC, UNAPP exchange rate Information
      and   cr.remit_bank_acct_use_id = rma.remit_bank_acct_use_id (+)  --UNAPP ccid for receipt
      and   cr.receipt_method_id = rma.receipt_method_id (+)
      and   ra.applied_customer_trx_id = ctinv.customer_trx_id (+)   --INV REC or On Account CM exchange rate Information
      and   ra.customer_trx_id = ctcm.customer_trx_id (+)            --CM REC exchange rate Information
      and   ra.customer_trx_id = ctlgdcm.customer_trx_id (+)         --CM REC account ccid
      and   decode(ra.application_type,
                   'CASH', 'REC',
                   'CM'  , ctlgdcm.account_class)  = 'REC'
      and   decode(ra.application_type,
                   'CASH', 'Y',
                   'CM'  , ctlgdcm.latest_rec_flag) = 'Y';

    --Replace balancing segment for gain, loss or round ccid matching that of
    --Receivable account of Invoice or On Account Credit Memo

      IF (p_app_rec.status in ('APP','ACTIVITY')) AND
           (sign(p_app_rec.acctd_amount_applied_from - p_app_rec.acctd_amount_applied_to) <> 0) THEN

         p_miscel_rec.fixed_rate := 'N';

         IF p_app_rec.status = 'APP' THEN

            IF p_app_rec.application_type = 'CASH' THEN
               BEGIN
                   p_miscel_rec.fixed_rate := arpcurr.isfixedrate(p_cr_rec.currency_code   		,
                                                                  g_ae_sys_rec.base_currency 	        ,
                                                                  p_cr_rec.receipt_date       	        ,
						        	  p_cust_inv_rec.invoice_currency_code 	,
							          p_cust_inv_rec.trx_date
                                                                 );
               EXCEPTION
                    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
                         p_miscel_rec.fixed_rate := 'N'; --Posting treats this as null
                    WHEN OTHERS THEN
                         RAISE;
               END;

	      IF NVL(p_miscel_rec.fixed_rate,'N') = 'N' AND
		 p_cr_rec.currency_code = p_cust_inv_rec.invoice_currency_code AND
		 p_cr_rec.exchange_rate = p_cust_inv_rec.exchange_rate THEN
                 p_miscel_rec.fixed_rate := 'Y';
	      END IF;
            END IF;

	    IF p_app_rec.application_type = 'CM' THEN
               BEGIN
                   p_miscel_rec.fixed_rate := arpcurr.isfixedrate(p_cust_cm_rec.invoice_currency_code   ,
                                                                  g_ae_sys_rec.base_currency 	        ,
                                                                  p_cust_cm_rec.trx_date     	        ,
						        	  p_cust_inv_rec.invoice_currency_code 	,
							          p_cust_inv_rec.trx_date
                                                                 );
               EXCEPTION
                    WHEN GL_CURRENCY_API.INVALID_CURRENCY THEN
                         p_miscel_rec.fixed_rate := 'N'; --Posting treats this as null
                    WHEN OTHERS THEN
                         RAISE;
               END;

	      IF NVL(p_miscel_rec.fixed_rate,'N') = 'N' AND
		 p_cust_cm_rec.invoice_currency_code = p_cust_inv_rec.invoice_currency_code AND
		 p_cust_cm_rec.exchange_rate = p_cust_inv_rec.exchange_rate THEN
                 p_miscel_rec.fixed_rate := 'Y';
	      END IF;
            END IF;

            --If fixed rate, override the gain or loss ccid with the round ccid from system parameters
            IF p_miscel_rec.fixed_rate = 'Y' THEN
               l_gain_loss_ccid := g_ae_sys_rec.round_cc_id;
            END IF;

            ARP_ALLOCATION_PKG.Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id           ,
                                               p_original_ccid => l_gain_loss_ccid              ,
                                               p_subs_ccid     => p_app_rec.code_combination_id ,
                                               p_actual_ccid   => p_miscel_rec.gain_loss_ccid     );
         ELSE

            --Replace balancing segment for gain, loss ccid matching that of receipts UNAPP
            --for ACTIVITY application.

            ARP_ALLOCATION_PKG.Substitute_Ccid(p_coa_id        => g_ae_sys_rec.coa_id           ,
                                               p_original_ccid => l_gain_loss_ccid              ,
                                               p_subs_ccid     => l_cr_unapp_ccid               ,
                                               p_actual_ccid   => p_miscel_rec.gain_loss_ccid     );

         END IF;

      END IF;

      IF p_app_rec.status = 'APP' and p_app_rec.application_type = 'CASH' then

         /* 4922353 - always get LE regardless of
              response from is_le_subscriber */
         select legal_entity_id
         into   l_le_id
         from   ra_customer_trx
         where  customer_trx_id = p_app_rec.applied_customer_trx_id;

         /* 4594101 - Check if legal entities are in use and, if so,
            include the new child/detail table in the join */
         IF arp_legal_entity_util.is_le_subscriber
         THEN
           /* LE is in use */

           /* 5236782 - there are cases where no rows will exist
              in ar_rec_trx_le_details.  The following sql has
              been modified to ignore these cases without error */

         select nvl(ed.gl_account_source,'NO_SOURCE')      ,
                nvl(ed.tax_code_source,'NO_SOURCE')        ,
                ed.tax_recoverable_flag                    ,
                ed.code_combination_id                     ,  --activity gl account earned discount
                nvl(edd.asset_tax_code, ed.asset_tax_code) ,
                nvl(edd.liability_tax_code, ed.liability_tax_code),
                ''                                         ,
                ''                                         ,
                nvl(uned.gl_account_source,'NO_SOURCE')    ,
                nvl(uned.tax_code_source,'NO_SOURCE')      ,
                uned.tax_recoverable_flag                  ,
                uned.code_combination_id                   ,  --activity gl account unearned discount
                nvl(unedd.asset_tax_code,uned.asset_tax_code),
                nvl(unedd.liability_tax_code,uned.liability_tax_code),
                ''                                         ,
                ''
         into   p_rule_rec.gl_account_source1     , --Earned discounts
                p_rule_rec.tax_code_source1       ,
                p_rule_rec.tax_recoverable_flag1  ,
                p_rule_rec.code_combination_id1   ,
                p_rule_rec.asset_tax_code1        ,
                p_rule_rec.liability_tax_code1    ,
                p_rule_rec.act_tax_non_rec_ccid1  ,
                p_rule_rec.act_vat_tax_id1        ,
                p_rule_rec.gl_account_source2     , --Unearned discounts
                p_rule_rec.tax_code_source2       ,
                p_rule_rec.tax_recoverable_flag2  ,
                p_rule_rec.code_combination_id2   ,
                p_rule_rec.asset_tax_code2        ,
                p_rule_rec.liability_tax_code2    ,
                p_rule_rec.act_tax_non_rec_ccid2  ,
                p_rule_rec.act_vat_tax_id2
         from   ar_receipt_method_accounts rma,
                ar_receivables_trx ed,
                ar_rec_trx_le_details edd,
                ar_receivables_trx uned,
                ar_rec_trx_le_details unedd
         where  rma.receipt_method_id = p_cr_rec.receipt_method_id
         and    rma.remit_bank_acct_use_id = p_cr_rec.remit_bank_acct_use_id
         and    rma.edisc_receivables_trx_id   = ed.receivables_trx_id (+)
         and    ed.receivables_trx_id          = edd.receivables_trx_id (+)
         and    edd.legal_entity_id   (+)      = l_le_id
         and    rma.unedisc_receivables_trx_id = uned.receivables_trx_id (+)
         and    uned.receivables_trx_id        = unedd.receivables_trx_id (+)
         and    unedd.legal_entity_id (+)      = l_le_id;

         ELSE
           /* OU is in use, reference ar_receivables_trx directly */

         select nvl(ed.gl_account_source,'NO_SOURCE')      ,
                nvl(ed.tax_code_source,'NO_SOURCE')        ,
                ed.tax_recoverable_flag                    ,
                ed.code_combination_id                     ,  --activity gl account earned discount
                ed.asset_tax_code                          ,
                ed.liability_tax_code                      ,
                ''                                         ,
                ''                                         ,
                nvl(uned.gl_account_source,'NO_SOURCE')    ,
                nvl(uned.tax_code_source,'NO_SOURCE')      ,
                uned.tax_recoverable_flag                  ,
                uned.code_combination_id                   ,  --activity gl account unearned discount
                uned.asset_tax_code                        ,
                uned.liability_tax_code                    ,
                ''                                         ,
                ''
         into   p_rule_rec.gl_account_source1     , --Earned discounts
                p_rule_rec.tax_code_source1       ,
                p_rule_rec.tax_recoverable_flag1  ,
                p_rule_rec.code_combination_id1   ,
                p_rule_rec.asset_tax_code1        ,
                p_rule_rec.liability_tax_code1    ,
                p_rule_rec.act_tax_non_rec_ccid1  ,
                p_rule_rec.act_vat_tax_id1        ,
                p_rule_rec.gl_account_source2     , --Unearned discounts
                p_rule_rec.tax_code_source2       ,
                p_rule_rec.tax_recoverable_flag2  ,
                p_rule_rec.code_combination_id2   ,
                p_rule_rec.asset_tax_code2        ,
                p_rule_rec.liability_tax_code2    ,
                p_rule_rec.act_tax_non_rec_ccid2  ,
                p_rule_rec.act_vat_tax_id2
         from   ar_receipt_method_accounts rma,
                ar_receivables_trx ed,
                ar_receivables_trx uned
         where  rma.receipt_method_id = p_cr_rec.receipt_method_id
         and    rma.remit_bank_acct_use_id = p_cr_rec.remit_bank_acct_use_id
         and    rma.edisc_receivables_trx_id   = ed.receivables_trx_id (+)
         and    rma.unedisc_receivables_trx_id = uned.receivables_trx_id (+) ;

         END IF;

       /* Initialize etax for rate validation */
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
           p_transaction_date => p_app_rec.apply_date,
           p_related_doc_date => NULL,
           p_adjusted_doc_date=> NULL,
           x_effective_date   => l_effective_date);

       /*---------------------------------------------------------------------+
        | Get the non recoverable tax ccid if tax code source is ACTIVITY for |
        | Earned discounts.                                                   |
        +---------------------------------------------------------------------*/
         IF ((p_rule_rec.tax_code_source1 = 'ACTIVITY')
            AND (p_rule_rec.asset_tax_code1 IS NOT NULL)
                AND nvl(p_app_rec.earned_discount_taken,0) <> 0) THEN

                Act_Tax_Non_Rec_Ccid('EDISC'                         ,
                                     p_rule_rec.asset_tax_code1      ,
                                     p_app_rec.apply_date            ,
                                     p_rule_rec.act_tax_non_rec_ccid1,
                                     p_rule_rec.act_vat_tax_id1         );

         END IF; --end if activity earned dicsounts

       /*---------------------------------------------------------------------+
        | Get the non recoverable tax ccid if tax code source is ACTIVITY for |
        | Unearned discounts.                                                 |
        +---------------------------------------------------------------------*/
         IF ((p_rule_rec.tax_code_source2 = 'ACTIVITY')
             AND (p_rule_rec.asset_tax_code2 IS NOT NULL)
                 AND nvl(p_app_rec.unearned_discount_taken,0) <> 0) THEN

                 Act_Tax_Non_Rec_Ccid('UNEDISC'                         ,
                                      p_rule_rec.asset_tax_code2        ,
                                      p_app_rec.apply_date              ,
                                      p_rule_rec.act_tax_non_rec_ccid2  ,
                                      p_rule_rec.act_vat_tax_id2          );

         END IF; --end if activity unearned discounts

      END IF; --end if cash application

   ELSIF p_level = 'MCD' then

      select cr.cash_receipt_id                  ,
             cr.amount                           ,
             cr.vat_tax_id                       ,
             cr.tax_rate                         ,
             cr.currency_code                    ,
             cr.exchange_rate              exchange_rate,
             cr.exchange_rate_type         exchange_rate_type,
             cr.exchange_date              exchange_date,
             cr.pay_from_customer                ,
             cr.customer_site_use_id             ,
             decode(avt.tax_rate_id, null, null,
                arp_etax_util.get_tax_account(cr.vat_tax_id,
                                           cr.deposit_date,
                                           'TAX',
                                           'TAX_RATE')),
             avt.tax_rate_id                     ,
             fc.precision                        ,
             fc.minimum_accountable_unit
      into  p_cr_rec.cash_receipt_id                   ,
            p_cr_rec.amount                            ,
            p_cr_rec.vat_tax_id                        ,
            p_cr_rec.tax_rate                          ,
            p_cr_rec.currency_code                     ,
            p_cr_rec.exchange_rate                     ,
            p_cr_rec.exchange_rate_type                ,
            p_cr_rec.exchange_date                     ,
            p_cr_rec.pay_from_customer                 ,
            p_cr_rec.customer_site_use_id              ,
            p_vat_rec.tax_account_id                   ,
            p_vat_rec.vat_tax_id                       ,
            p_curr_rec.precision                       ,
            p_curr_rec.minimum_accountable_unit
      from ar_cash_receipts           cr      ,
           zx_rates_b                 avt     ,
           fnd_currencies             fc
      where cr.cash_receipt_id      = g_ae_doc_rec.document_id
      and   cr.currency_code        = fc.currency_code
      and   cr.vat_tax_id           = avt.tax_rate_id    (+);

      p_vat_rec.tax_account_id := g_ae_doc_rec.gl_tax_acct; /* Bug fix 2300268 */
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_RECEIPTS_MAIN.Get_Doc_Entitity_Data()-');
   END IF;

EXCEPTION
  WHEN ARP_ALLOCATION_PKG.flex_subs_ccid_error THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECEIPTS_MAIN.Get_Doc_Entitity_Data - flex_subs_ccid_error');
     END IF;
     RAISE;

  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECEIPTS_MAIN.Get_Doc_Entitity_Data - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Get_Doc_Entitity_Data');
     END IF;
     RAISE ;

END Get_Doc_Entitity_Data;

/* ============================================================================
 | PROCEDURE Act_Tax_Non_Rec_Ccid
 |
 | DESCRIPTION
 |      This procedure gets the Non Recoverable account when TAX CODE
 |      SOURCE is activity tax code. For Cash Receipts, liability tax
 |      code is used, functionality has been provided for Receipts which
 |      are positive (currently indicate reversals) however this functionality
 |      for reversal would not get utilized currently.
 |
 | PARAMETERS
 |      p_type               IN  Earned discount, Unearned discount amount
 |      p_asset_tax_code     IN  Asset Tax Code from Receivables Trx discount
 |      p_apply_date         IN  Receipt apply date which restricts Tax Code
 * ============================================================================*/
PROCEDURE Act_Tax_Non_Rec_Ccid (
                p_type                 IN VARCHAR2                                     ,
                p_asset_tax_code       IN VARCHAR2                                     ,
                p_apply_date           IN DATE                                         ,
                p_act_tax_non_rec_ccid OUT NOCOPY ar_receivables_trx.code_combination_id%TYPE ,
                p_act_vat_tax_id       OUT NOCOPY ar_vat_tax.vat_tax_id%TYPE                   ) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_RECEIPTS_MAIN.Act_Tax_Non_Rec_Ccid()+');
   END IF;

  /*--------------------------------------------------------+
   | Get non recoverable tax account for asset or liability |
   | tax code for finance charges                           |
   +--------------------------------------------------------*/
             p_act_tax_non_rec_ccid := null;
             p_act_vat_tax_id       := null;

       SELECT tax_rate_id
       INTO   p_act_vat_tax_id
       FROM   zx_sco_rates
       WHERE  tax_rate_code = p_asset_tax_code
       AND    p_apply_date BETWEEN nvl(effective_from, p_apply_date) AND
                     nvl(effective_to, p_apply_date);

       /* Now get the corresponding account */
       IF p_type IN ('EDISC','UNEDISC')
       THEN

         /* 5659355 - non recoverable - should use EDISC_NON_REC
               and UNEDISC_NON_REC */
            IF p_type = 'EDISC'
            THEN
                p_act_tax_non_rec_ccid :=
                    arp_etax_util.get_tax_account(p_act_vat_tax_id,
                                                  p_apply_date,
                                                  'EDISC_NON_REC',
                                                  'TAX_RATE');
            ELSE
              /* UNEDISC */
                p_act_tax_non_rec_ccid :=
                    arp_etax_util.get_tax_account(p_act_vat_tax_id,
                                                  p_apply_date,
                                                  'UNEDISC_NON_REC',
                                                  'TAX_RATE');

            END IF;
       ELSE
           p_act_tax_non_rec_ccid := NULL;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug( 'ARP_RECEIPTS_MAIN.Act_Tax_Non_Rec_Ccid()+');
       END IF;

EXCEPTION
 /*-------------------------------------------------------------------+
  | Invalid ccid error will be raised in tax allocation routine hence |
  | null exception for no data found for non recoverable account.     |
  +-------------------------------------------------------------------*/
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Act_Tax_Non_Rec_Ccid - NO_DATA_FOUND');
     END IF;
     null;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Act_Tax_Non_Rec_Ccid');
     END IF;
     RAISE ;

END Act_Tax_Non_Rec_Ccid;

/* =======================================================================
 | PROCEDURE Create_Ae_Lines_Common
 |
 | DESCRIPTION
 |      This procedure creates the AE lines at each entity level. Used
 |      for creating lines as part of Receipt Creation and Reversals.
 |
 |      Functions:
 |      	- Create AE lines.
 |      	- Get additional data to determine the type of AE lines
 |
 | PARAMETERS
 |      p_level       Entity level from which the procedure was called
 * ======================================================================*/
PROCEDURE Create_Ae_Lines_Common (
		p_level 	IN VARCHAR2,
        --{HYUDETUPT
        p_from_llca_call  IN VARCHAR2,
        p_gt_id           IN NUMBER
        --}
     ) IS

  l_miscel_rec          g_ae_miscel_rec_type ;
  l_app_rec		ar_receivable_applications%ROWTYPE ;
  l_cr_rec              ar_cash_receipts%ROWTYPE           ;
  l_cust_inv_rec        ra_customer_trx%ROWTYPE            ;
  l_cust_cm_rec         ra_customer_trx%ROWTYPE            ;
  l_ctlgd_cm_rec        ra_cust_trx_line_gl_dist%ROWTYPE   ;
  l_vat_rec             ar_vat_tax%ROWTYPE                 ;
  l_curr_rec            ae_curr_rec_type                   ;
  l_rule_rec            ae_rule_rec_type                   ;
  l_tmp_upg_method      ra_customer_trx.upgrade_method%TYPE;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_RECEIPTS_MAIN.Create_Ae_Lines_Common()+');
   END IF;

   /*-------------------------------------------------------------+
    | Get Document Entitity specific data                         |
    +-------------------------------------------------------------*/

     Get_Doc_Entitity_Data(p_level          => p_level        ,
                           p_app_rec        => l_app_rec      ,
                           p_cr_rec         => l_cr_rec       ,
                           p_cust_inv_rec   => l_cust_inv_rec ,
                           p_cust_cm_rec    => l_cust_cm_rec  ,
                           p_ctlgd_cm_rec   => l_ctlgd_cm_rec ,
                           p_miscel_rec     => l_miscel_rec   ,
                           p_vat_rec        => l_vat_rec      ,
                           p_curr_rec       => l_curr_rec     ,
                           p_rule_rec       => l_rule_rec      );

  /*------------------------------------------------------+
   | Create AE Lines for Cash Receipt                     |
   +------------------------------------------------------*/
   IF ((p_level = 'RA') AND (nvl(l_app_rec.confirmed_flag, 'Y') = 'Y')) THEN	-- Entity level receivable_application

    --{LLCA CROSS CURRENCY
    IF p_from_llca_call = 'Y' THEN
      IF l_app_rec.acctd_amount_applied_from IS NOT NULL OR l_app_rec.amount_applied_from IS NOT NULL THEN
         ARP_DET_DIST_PKG.update_from_gt
          (p_from_amt        => l_app_rec.amount_applied_from,
           p_from_acctd_amt  => l_app_rec.acctd_amount_applied_from,
           p_ae_sys_rec      => g_ae_sys_rec,
           p_app_rec         => l_app_rec,
           p_gt_id           => p_gt_id,
           p_inv_currency    => l_cust_inv_rec.invoice_currency_code);

         UPDATE ar_receivable_applications SET upgrade_method = 'R12'
          WHERE receivable_application_id = l_app_rec.receivable_application_id;

      END IF;
    END IF;
    --}

    /**If Detailed distributions is disabled for the current operating unit then
       it will stamp the invoice with upgrade_method as R12_MERGE*/
    IF l_cust_inv_rec.customer_trx_id IS NOT NULL THEN
      ARP_DET_DIST_PKG.verify_stamp_merge_dist_method
	    ( l_cust_inv_rec.customer_trx_id,
	      l_tmp_upg_method );

      /**Above proc call will update the invoice header record to database.As l_cust_inv_rec
	 is fetched from db prior to the update,manually setting it with new value */
      IF nvl(l_tmp_upg_method,'R12_NLB') = 'R12_MERGE'  THEN
	l_cust_inv_rec.upgrade_method := l_tmp_upg_method;
      END IF;
    END IF;
    /**If Detailed distributions is disabled for the current operating unit then
       it will stamp the credit memo with upgrade_method as R12_MERGE*/
    IF  l_cust_cm_rec.customer_trx_id IS NOT NULL THEN
      l_tmp_upg_method := NULL;

      ARP_DET_DIST_PKG.verify_stamp_merge_dist_method
	    ( l_cust_cm_rec.customer_trx_id,
	      l_tmp_upg_method );

      /**Above proc call will update the credit memo header record to database.As l_cust_cm_rec
	 is fetched from db prior to the update,manually setting it with new value */
      IF nvl(l_tmp_upg_method,'R12_NLB') = 'R12_MERGE'  THEN
	 l_cust_cm_rec.upgrade_method := l_tmp_upg_method;
      END IF;
    END IF;

  	/*------------------------------------------------------+
   	 | Create AE Lines for Receivables, On-Account or       |
         | Unidentified or Unapplied                            |
   	 +------------------------------------------------------*/
  	   Create_Ae_Lines_RA(p_app_rec        => l_app_rec        ,
                              p_cr_rec         => l_cr_rec         ,
                              p_cust_inv_rec   => l_cust_inv_rec   ,
                              p_cust_cm_rec    => l_cust_cm_rec    ,
                              p_ctlgd_cm_rec   => l_ctlgd_cm_rec   ,
                              p_miscel_rec     => l_miscel_rec     ,
                              p_rule_rec       => l_rule_rec        ,
                              --{HYUDETUPT
                              p_from_llca_call => p_from_llca_call,
                              p_gt_id          => p_gt_id
                              --}
                              );

    ELSIF p_level = 'MCD' THEN  -- Entity level = ar_misc_cash_distributions
          /*------------------------------------------------------+
           | Create AE Lines for Misc Cash Receipts, Payments     |
           +------------------------------------------------------*/

           Create_Ae_Lines_MCD(p_cr_rec         => l_cr_rec         ,
                               p_vat_rec        => l_vat_rec        ,
                               p_curr_rec       => l_curr_rec       );

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_RECEIPTS_MAIN.Create_Ae_Lines_Common()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Create_Ae_Lines_Common');
     END IF;
     RAISE;

END Create_Ae_Lines_Common;

/* ================================================================================
 | PROCEDURE Create_Ae_Lines_RA
 |
 | DESCRIPTION
 |      This procedure creates the AE lines for Unidentified, On-Account
 |      and Receivables and also creates the pairing Unapplied Cash record
 |
 |      Functions:
 |              - Create AE lines for Receivable and Unapplied Cash.
 |              - Determines Amounts Dr/Cr.
 |
 | PARAMETERS
 |      p_app_rec       Receivables Application Record(Transaction data)
 |      p_cr_rec        Cash Receipt Record
 |      p_cust_inv_rec  Invoice header Record
 |      p_cust_cm_rec   CM header Record
 |      p_ctlgd_cm_rec  CM distributions REC account ccid
 |
 | 02-Jul-2001          S.Nambiar         Bug 1859937 In case of receipt chargeback
 |                                        or credit card refund ,instead of
 |                                        acctd_amount_aplied_from,
 |                                        acctd_amount_applied_to
 |                                        should be used  to credit/debit.
 | 12-MAY-2003          J.Beckett         Bug 2821139 As above for payment netting
 |                                        i.e. where receivables_trx_id = -16
 * =================================================================================*/
PROCEDURE Create_Ae_Lines_RA(
		p_app_rec 	 IN ar_receivable_applications%ROWTYPE                 ,
                p_cr_rec         IN ar_cash_receipts%ROWTYPE                           ,
                p_cust_inv_rec   IN ra_customer_trx%ROWTYPE                            ,
                p_cust_cm_rec    IN ra_customer_trx%ROWTYPE                            ,
                p_ctlgd_cm_rec   IN ra_cust_trx_line_gl_dist%ROWTYPE                   ,
                p_miscel_rec     IN g_ae_miscel_rec_type                               ,
                p_rule_rec       IN ae_rule_rec_type                                   ,
                --{HYUDETUPT
                p_from_llca_call IN VARCHAR2,
                p_gt_id          IN NUMBER
                --}
                  ) IS
  l_app_id              ar_receivable_applications.receivable_application_id%TYPE;
  l_ael_line_rec	ae_line_rec_type;
  l_empty_ael_line_rec	ae_line_rec_type;
  l_adj_rec             ar_adjustments%ROWTYPE;
  l_ae_line_tbl         ae_line_tbl_type;
  l_ae_ctr              BINARY_INTEGER := 0;
  l_ctr                 BINARY_INTEGER;
  --{BUG#2927254
  l_app_rec             ar_receivable_applications%ROWTYPE;
  l_cust_inv_cm_rec     ra_customer_trx%ROWTYPE;
  l_i                   BINARY_INTEGER;
  l_j                   BINARY_INTEGER;
  l_amount_applied      NUMBER;
  l_acctd_amount_applied NUMBER;
  l_rec_amt    Number;
  l_call_alloc_tax  Boolean := TRUE;

  l_def_tax_flag       VARCHAR2(1);
  l_from_curr          ar_cash_receipts.currency_code%type;
  l_from_curr_rate     ar_cash_receipts.exchange_rate%type;

  --}

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_RECEIPTS_MAIN.Create_Ae_Lines_RA()+');
  END IF;


/*-------------------------------------------------------------------+
 | Set counters to indicate dual creation of receivables for CM and  |
 | CM and Invoices for CM applications - detail level of granularity |
 +-------------------------------------------------------------------*/
  IF p_app_rec.application_type = 'CM' THEN
     l_j := 2;
     l_from_curr := p_cust_cm_rec.invoice_currency_code;
     l_from_curr_rate := p_cust_cm_rec.exchange_rate;
  ELSE
     l_j := 1;
     l_from_curr := p_cr_rec.currency_code;
     l_from_curr_rate := p_cr_rec.exchange_rate;
  END IF;


 /*-------------------------------------------------------------+
  | Get exchange rate and third part info from Cash Receipt for |
  | building ACC, UNID, UNAPP                                   |
  +-------------------------------------------------------------*/
   l_ael_line_rec.source_id                := p_app_rec.receivable_application_id;
   l_ael_line_rec.source_table             := 'RA';
   l_ael_line_rec.account                  := p_app_rec.code_combination_id; --ccid for UNAPP, UNID, ACC and APP
   l_ael_line_rec.currency_code            := p_cr_rec.currency_code;
   l_ael_line_rec.currency_conversion_rate := p_cr_rec.exchange_rate;
   l_ael_line_rec.currency_conversion_type := p_cr_rec.exchange_rate_type;
   l_ael_line_rec.currency_conversion_date := p_cr_rec.exchange_date;
   l_ael_line_rec.third_party_id           := p_cr_rec.pay_from_customer;
   l_ael_line_rec.third_party_sub_id       := p_cr_rec.customer_site_use_id;
   l_ael_line_rec.ae_line_type_secondary   := '';

  /*-----------------------------------------------------------+
   | Accounting Entry Line Type UNID, ACC, REC (APP) for       |
   | UNID records set the third_party_id and third_party_sub_id|
   | to null as receipt is unidentified.                       |
   +-----------------------------------------------------------*/

   IF p_app_rec.status IN ('ACC', 'UNID', 'UNAPP','ACTIVITY','OTHER ACC') THEN

      IF (p_app_rec.status = 'ACC') THEN
         l_ael_line_rec.ae_line_type := 'ACC';

      ELSIF (p_app_rec.status = 'OTHER ACC') THEN
         l_ael_line_rec.ae_line_type := 'OTHER ACC';

      ELSIF (p_app_rec.status = 'UNID') THEN
         l_ael_line_rec.ae_line_type       := 'UNID';
         l_ael_line_rec.third_party_id     := '';
         l_ael_line_rec.third_party_sub_id := '';

      ELSIF (p_app_rec.status = 'ACTIVITY') THEN

         IF p_app_rec.applied_payment_schedule_id = -2 THEN
           l_ael_line_rec.ae_line_type       := 'SHORT_TERM_DEBT';
         ELSE
           l_ael_line_rec.ae_line_type       := 'ACTIVITY';
         END IF;

      ELSIF (p_app_rec.status = 'UNAPP') THEN
         l_ael_line_rec.ae_line_type := 'UNAPP';

         IF g_ae_doc_rec.other_flag = 'PAIR' THEN

          --A value of PAIR indicates that the UNAPP is paired with an APP, ACC, UNID

            l_ael_line_rec.source_id_secondary    := g_ae_doc_rec.source_id_old;
            l_ael_line_rec.source_table_secondary := 'RA';

         END IF;

      END IF;

     /*----------------------------------------------------------------+
      |Bug 1859937 In case of receipt chargeback or credit card refund |
      |(application ref_id is populated in both these cases),instead of|
      |acctd_amount_aplied_from,acctd_amount_applied_to should be used |
      |to credit/debit.                                                |
      +----------------------------------------------------------------*/
      IF ( sign( p_app_rec.amount_applied ) = -1 ) THEN  --Debits

         --BUG#5437275
         l_ael_line_rec.entered_dr       := abs(p_app_rec.amount_applied);
         l_ael_line_rec.from_amount_dr   := abs(p_app_rec.amount_applied_from);

         l_ael_line_rec.entered_cr           := NULL;
         l_ael_line_rec.accounted_cr         := NULL;
         l_ael_line_rec.from_amount_cr       := NULL;
         l_ael_line_rec.from_acctd_amount_cr := NULL;

         IF ((p_app_rec.status = 'ACTIVITY') AND (p_app_rec.application_ref_id is not null OR p_app_rec.receivables_trx_id = -16)) THEN
            l_ael_line_rec.accounted_dr         := abs(p_app_rec.acctd_amount_applied_to);
            l_ael_line_rec.from_acctd_amount_dr := abs(p_app_rec.acctd_amount_applied_from);
          ELSE
            l_ael_line_rec.accounted_dr         := abs(p_app_rec.acctd_amount_applied_from);
            l_ael_line_rec.from_acctd_amount_dr := abs(p_app_rec.acctd_amount_applied_to);
         END IF;

      ELSE

         --BUG#5437275
         l_ael_line_rec.entered_cr       := p_app_rec.amount_applied;
         l_ael_line_rec.from_amount_cr   := abs(p_app_rec.amount_applied_from);

         l_ael_line_rec.entered_dr       := NULL;
         l_ael_line_rec.from_amount_dr   := NULL;
         l_ael_line_rec.accounted_dr          := NULL;
         l_ael_line_rec.from_acctd_amount_dr  := NULL;

         IF ((p_app_rec.status = 'ACTIVITY') AND (p_app_rec.application_ref_id is not null OR p_app_rec.receivables_trx_id = -16)) THEN
            l_ael_line_rec.accounted_cr         := p_app_rec.acctd_amount_applied_to;
            l_ael_line_rec.from_acctd_amount_cr := abs(p_app_rec.acctd_amount_applied_from);
         ELSE
            l_ael_line_rec.accounted_cr         := p_app_rec.acctd_amount_applied_from;
            l_ael_line_rec.from_acctd_amount_cr := abs(p_app_rec.acctd_amount_applied_to);
         END IF;

      END IF;

     -- Assign AEL for UNID, ACC for Receipts
      Assign_Ael_Elements( p_ae_line_rec 	=> l_ael_line_rec );
   END IF;

   IF ((p_app_rec.status = 'APP') OR
       ((p_app_rec.status = 'ACTIVITY') AND
	    (p_app_rec.application_ref_id is not null OR p_app_rec.receivables_trx_id = -16))) THEN

     IF (p_app_rec.status = 'APP') THEN

      /*--------------------------------------------------------------------------------+
       | Derive Receivable amounts, for Receipt applications, REC for Invoice document. |
       | On-Account Credit Memos combined with Receipts, REC for Credit Memo document.  |
       +--------------------------------------------------------------------------------*/
        l_ael_line_rec.ae_line_type := 'REC';

        /* J Rautiainen BR Implementation
         * Override the source type if it is passed */
        IF g_ae_doc_rec.override_source_type IS NOT NULL THEN
          l_ael_line_rec.ae_line_type := g_ae_doc_rec.override_source_type;
        END IF;

	      l_rec_amt := 0;
            IF p_app_rec.amount_applied <> 0 THEN
              SELECT SUM( abs(nvl(amount_line_items_original,0)) +
	                  abs(nvl(tax_original,0)) +
			  abs(nvl(discount_original,0)) +
			  abs(nvl(freight_original,0)) +
			  abs(nvl(receivables_charges_charged,0)) )
              INTO
	         l_rec_amt
              FROM ar_payment_schedules
	      where customer_trx_id = p_app_rec.applied_customer_trx_id
              GROUP BY customer_trx_id;
            END IF;

        /* Bug 2306701. Zero amount application of Credit memo is same as Positive
           application. */
        /* Bug fix 3247264. The sign of amount_applied + discounts should be considered
           for deciding on Debit or Credit */
        IF ( sign( p_app_rec.amount_applied +
                   nvl(p_app_rec.earned_discount_taken,0) +
                   nvl(p_app_rec.unearned_discount_taken,0) ) in (-1,0 )) THEN

           --{EDISC or UNEDISC REC Distr will be created by this pack.
           --The REC on document or ON ACCT will move to Allocation package.
           IF  (NVL(p_app_rec.earned_discount_taken,0) <> 0 OR
                NVL(p_app_rec.unearned_discount_taken,0) <> 0 ) AND l_rec_amt <> 0
           THEN

              l_ael_line_rec.entered_dr  := abs((nvl(p_app_rec.earned_discount_taken,0) +
                                                      nvl(p_app_rec.unearned_discount_taken,0)));

              --BUG#5437275
              l_ael_line_rec.from_amount_dr := abs(from_num_amt
                                            (p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                             p_from_curr   => l_from_curr,                     --Bug 9817467
					     p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
					     p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                             p_to_den_amt  => p_app_rec.AMOUNT_APPLIED,
                                             p_from_num_amt=> nvl(p_app_rec.AMOUNT_APPLIED_FROM,p_app_rec.AMOUNT_APPLIED),  -- vavenugo bug6653443
                                             p_to_num_amt  => abs((nvl(p_app_rec.earned_discount_taken,0) +
                                                                  nvl(p_app_rec.unearned_discount_taken,0)))));

              l_ael_line_rec.entered_cr      := NULL;
              l_ael_line_rec.from_amount_cr  := NULL;


              l_ael_line_rec.accounted_dr := abs((nvl(p_app_rec.acctd_earned_discount_taken,0) +
                                                nvl(p_app_rec.acctd_unearned_discount_taken,0)));

              l_ael_line_rec.from_acctd_amount_dr  :=
                   abs(from_num_amt(p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                    p_from_curr   => l_from_curr,                     --Bug 9817467
				    p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
                                    p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                    p_to_den_amt  => p_app_rec.ACCTD_AMOUNT_APPLIED_TO,
                                    p_from_num_amt=> p_app_rec.ACCTD_AMOUNT_APPLIED_FROM,
                                    p_to_num_amt  => abs((nvl(p_app_rec.acctd_earned_discount_taken,0) +
                                                          nvl(p_app_rec.acctd_unearned_discount_taken,0)))));
              l_ael_line_rec.accounted_cr          := NULL;
              l_ael_line_rec.from_acctd_amount_cr  := NULL;


           ELSE
           --}
           -- For REC (APP) and discounts, accounting in currency of Invoice document
              l_ael_line_rec.entered_dr   := abs((p_app_rec.amount_applied +
                                                   nvl(p_app_rec.earned_discount_taken,0) +
                                                      nvl(p_app_rec.unearned_discount_taken,0)));
             --BUG#5437275
              l_ael_line_rec.from_amount_dr  :=
                   abs(from_num_amt(p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                    p_from_curr   => l_from_curr,                     --Bug 9817467
				    p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
                                    p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                    p_to_den_amt  => p_app_rec.AMOUNT_APPLIED,
                                    p_from_num_amt=> nvl(p_app_rec.AMOUNT_APPLIED_FROM,p_app_rec.AMOUNT_APPLIED),  -- vavenugo bug6653443
                                    p_to_num_amt  => abs((nvl(p_app_rec.amount_applied +
                                                          p_app_rec.earned_discount_taken,0) +
                                                          nvl(p_app_rec.unearned_discount_taken,0)))));

              l_ael_line_rec.entered_cr      := NULL;
              l_ael_line_rec.from_amount_cr  := NULL;

              l_ael_line_rec.accounted_dr := abs((p_app_rec.acctd_amount_applied_to +
                                                   nvl(p_app_rec.acctd_earned_discount_taken,0) +
                                                   nvl(p_app_rec.acctd_unearned_discount_taken,0)));
              l_ael_line_rec.from_acctd_amount_dr  :=
                   abs(from_num_amt(p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                    p_from_curr   => l_from_curr,                     --Bug 9817467
				    p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
                                    p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                    p_to_den_amt  => p_app_rec.ACCTD_AMOUNT_APPLIED_TO,
                                    p_from_num_amt=> p_app_rec.ACCTD_AMOUNT_APPLIED_FROM,
                                    p_to_num_amt  => abs((p_app_rec.acctd_amount_applied_to +
                          nvl(p_app_rec.acctd_earned_discount_taken,0) +
                          nvl(p_app_rec.acctd_unearned_discount_taken,0)))));

              l_ael_line_rec.accounted_cr          := NULL;
              l_ael_line_rec.from_acctd_amount_cr  := NULL;

           END IF;

        ELSE   -- Credit Receivables for INV, if amount_applied is 0 then accounting record created

           --{EDISC or UNEDISC REC Distr will be created by this pack.
           --The REC on document or ON ACCT will move to Allocation package.
           IF  (NVL(p_app_rec.earned_discount_taken,0) <> 0 OR
                NVL(p_app_rec.unearned_discount_taken,0) <> 0 ) AND l_rec_amt <> 0
           THEN

              l_ael_line_rec.entered_cr   := abs((nvl(p_app_rec.earned_discount_taken,0) +
                                                      nvl(p_app_rec.unearned_discount_taken,0)));

              --BUG#5437275
              l_ael_line_rec.from_amount_cr  :=
                   abs(from_num_amt(p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                    p_from_curr   => l_from_curr,                     --Bug 9817467
				    p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
                                    p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                    p_to_den_amt  => p_app_rec.AMOUNT_APPLIED,
                                    p_from_num_amt=> nvl(p_app_rec.AMOUNT_APPLIED_FROM,p_app_rec.AMOUNT_APPLIED),  -- vavenugo bug6653443
                                    p_to_num_amt  => abs((nvl(p_app_rec.earned_discount_taken,0) +
                             nvl(p_app_rec.unearned_discount_taken,0)))));

              l_ael_line_rec.entered_dr      := NULL;
              l_ael_line_rec.from_amount_dr  := NULL;

              l_ael_line_rec.accounted_cr := abs((nvl(p_app_rec.acctd_earned_discount_taken,0) +
                                                  nvl(p_app_rec.acctd_unearned_discount_taken,0)));

              l_ael_line_rec.from_acctd_amount_cr  :=
                   abs(from_num_amt(p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                    p_from_curr   => l_from_curr,                     --Bug 9817467
				    p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
                                    p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                    p_to_den_amt  => p_app_rec.ACCTD_AMOUNT_APPLIED_TO,
                                    p_from_num_amt=> p_app_rec.ACCTD_AMOUNT_APPLIED_FROM,
                                    p_to_num_amt  => abs((nvl(p_app_rec.acctd_earned_discount_taken,0) +
                             nvl(p_app_rec.acctd_unearned_discount_taken,0)))));

              l_ael_line_rec.accounted_dr         := NULL;
              l_ael_line_rec.from_acctd_amount_dr := NULL;

           ELSE
           --}

              l_ael_line_rec.entered_cr   := p_app_rec.amount_applied +
                                              nvl(p_app_rec.earned_discount_taken,0) +
                                                 nvl(p_app_rec.unearned_discount_taken,0);
              l_ael_line_rec.from_amount_cr  :=
                   abs(from_num_amt(p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                    p_from_curr   => l_from_curr,                     --Bug 9817467
				    p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
                                    p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                    p_to_den_amt  => p_app_rec.AMOUNT_APPLIED,
                                    p_from_num_amt=> nvl(p_app_rec.AMOUNT_APPLIED_FROM,p_app_rec.AMOUNT_APPLIED),  -- vavenugo bug6653443
                                    p_to_num_amt  => abs((nvl(p_app_rec.amount_applied +
                              p_app_rec.earned_discount_taken,0) +
                              nvl(p_app_rec.unearned_discount_taken,0)))));

              l_ael_line_rec.entered_dr   := NULL;
              l_ael_line_rec.from_amount_dr  := NULL;

              l_ael_line_rec.accounted_cr := p_app_rec.acctd_amount_applied_to +
                                              nvl(p_app_rec.acctd_earned_discount_taken,0) +
                                                 nvl(p_app_rec.acctd_unearned_discount_taken,0);

              l_ael_line_rec.from_acctd_amount_cr  :=
                   abs(from_num_amt(p_to_curr     => p_cust_inv_rec.invoice_currency_code,
                                    p_from_curr   => l_from_curr,                     --Bug 9817467
				    p_to_curr_rate  => p_cust_inv_rec.exchange_rate,  -- vavenugo bug6653443
                                    p_from_curr_rate  => l_from_curr_rate,            -- Bug 9817467 -- vavenugo bug6653443
                                    p_to_den_amt  => p_app_rec.ACCTD_AMOUNT_APPLIED_TO,
                                    p_from_num_amt=> p_app_rec.ACCTD_AMOUNT_APPLIED_FROM,
                                    p_to_num_amt  => abs((p_app_rec.acctd_amount_applied_to +
                          nvl(p_app_rec.acctd_earned_discount_taken,0) +
                          nvl(p_app_rec.acctd_unearned_discount_taken,0)))));
              l_ael_line_rec.accounted_dr := NULL;
              l_ael_line_rec.from_acctd_amount_dr  := NULL;

           END IF;
        END IF;

        -- Override exchange rate information and use Invoice Rate for Receivables (APP)
        -- or Credit Memo for On Account CM with Receipts in this case p_cust_inv_rec
        -- holds the exchange rate info of the CM

        l_ael_line_rec.currency_code            := p_cust_inv_rec.invoice_currency_code;
        l_ael_line_rec.currency_conversion_rate := p_cust_inv_rec.exchange_rate;
        l_ael_line_rec.currency_conversion_type := p_cust_inv_rec.exchange_rate_type;
        l_ael_line_rec.currency_conversion_date := p_cust_inv_rec.exchange_date;

        IF p_cust_inv_rec.drawee_site_use_id IS NOT NULL THEN
           l_ael_line_rec.third_party_id           := p_cust_inv_rec.drawee_id;
           l_ael_line_rec.third_party_sub_id       := p_cust_inv_rec.drawee_site_use_id;
        ELSE
           l_ael_line_rec.third_party_id           := p_cust_inv_rec.bill_to_customer_id;
           l_ael_line_rec.third_party_sub_id       := p_cust_inv_rec.bill_to_site_use_id;
        END IF;

     -- Assign AEL for REC(APP) for Invoice document or On-Account CM's combined with Receipts
     -- going forward blls receivable will also be created by alloc routione for REC
     -- issues with rate, third party info
           /*bug 6151622*/
   /* Bug 6803266: Reverted changes of bug 6151622 and added condition to chk defered_tax as N*/

	--deferred tax check
	IF p_cust_inv_rec.upgrade_method = 'R12_MERGE' THEN
	  BEGIN
	    select 'Y'
	    into l_def_tax_flag
	    from  ra_cust_trx_line_gl_dist gld
	    where gld.account_class = 'TAX'
	    and   gld.customer_trx_id = p_cust_inv_rec.customer_trx_id
	    and   gld.collected_tax_ccid IS NOT NULL
	    and   rownum = 1;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
		l_def_tax_flag := 'N';
	  END;
        END IF;

      /*If the upgrade_method stamped on the invoice is R12_MERGE and if these exists

       1 > No deffered tax then receivable row with entire application amount gets created
          upfront there by avoiding expensive call to detailed allocation engine

       2 > Earn/unearn discount then existing logic will anyway makes this condition true and
           will have a REC row created for the offset amount of discount
       */

	IF ( p_cust_inv_rec.drawee_site_use_id IS NOT NULL
	     AND nvl(g_ae_doc_rec.deferred_tax,'Y') = 'N' )
           OR ((nvl(p_app_rec.earned_discount_taken,0) <> 0)
                   OR (nvl(p_app_rec.unearned_discount_taken,0) <> 0)
		   OR l_rec_amt = 0
                   OR (p_app_rec.amount_applied = 0))
	   OR ( p_cust_inv_rec.upgrade_method = 'R12_MERGE' AND
	        nvl(l_def_tax_flag,'N') = 'N' ) THEN /* Added check from 0 amount applied */
							   /*Bug fix 6721786 */
              IF l_rec_amt = 0 THEN
                l_call_alloc_tax := FALSE;
              END IF;
	    IF PG_DEBUG in ('Y', 'C') THEN
	       arp_standard.debug( 'Calling Assign_elements..inside R12_MERGE');
	    END IF;

	  /** will be stamping the ref_mf_dist_flag as D on all REC offset rows for discounts
	      inorder to differentiate them from other REC rows in ARD.
	   */
	   IF (nvl(p_app_rec.earned_discount_taken,0) <> 0)   OR
	      (nvl(p_app_rec.unearned_discount_taken,0) <> 0) THEN
	       l_ael_line_rec.ref_mf_dist_flag := 'D';
	   END IF;

         -- Need to create detailed distributions even when amount_applied is zero
         IF nvl(p_cust_inv_rec.upgrade_method,'R12_NLB') in ('R12_NLB','R12','R12_11IMFAR')
            AND p_app_rec.amount_applied = 0 AND p_cust_inv_rec.drawee_site_use_id IS NULL THEN
           -- Invoice
           arp_standard.debug('amount_applied is zero');
   	       arp_standard.debug('Creating detailed distributions for invoice');

            l_ael_line_rec.ae_line_type           := 'REC';
            l_ael_line_rec.ae_line_type_secondary := '';
            l_ael_line_rec.entered_dr             := 0;
            l_ael_line_rec.from_amount_dr         := 0;
            l_ael_line_rec.entered_cr             := NULL;
            l_ael_line_rec.from_amount_cr         := NULL;
            l_ael_line_rec.accounted_dr           := 0;
            l_ael_line_rec.from_acctd_amount_dr   := 0;
            l_ael_line_rec.accounted_cr           := NULL;
            l_ael_line_rec.from_acctd_amount_cr   := NULL;
            l_ael_line_rec.account                      := p_app_rec.code_combination_id;
            l_ael_line_rec.currency_code                := p_cust_inv_rec.invoice_currency_code;
            l_ael_line_rec.currency_conversion_rate     := p_cust_inv_rec.exchange_rate;
            l_ael_line_rec.currency_conversion_type     := p_cust_inv_rec.exchange_rate_type;
            l_ael_line_rec.currency_conversion_date     := p_cust_inv_rec.exchange_date;
            l_ael_line_rec.third_party_id               := p_cust_inv_rec.bill_to_customer_id;
            l_ael_line_rec.third_party_sub_id           := p_cust_inv_rec.bill_to_site_use_id;

           For gl_rec_inv in (select cust_trx_line_gl_dist_id,
                                 customer_trx_line_id,
                                 code_combination_id,
                                 decode(account_class,       'REV',     account_class,
                                                             'UNBILL',  account_class,
                                                             'UNEARN',  account_class,
                                                             'TAX',     account_class,
                                                             'FREIGHT', account_class,
                                                             'CHARGES', account_class,
                                                             NULL) account_class,
                                 decode(account_class,       'REV',     'APP_LINE',
                                                             'UNBILL',  'APP_LINE',
                                                             'UNEARN',  'APP_LINE',
                                                             'TAX',     'APP_TAX',
                                                             'FREIGHT', 'APP_FRT',
                                                             'CHARGES', 'APP_CHRG',
                                                             NULL) activity_bucket
                          from   ra_cust_trx_line_gl_dist
                          where  customer_trx_id = p_cust_inv_rec.customer_trx_id
                          and    customer_trx_line_id is not null
                          and    account_set_flag = 'N') Loop

            l_ael_line_rec.ref_customer_trx_line_id     := gl_rec_inv.customer_trx_line_id;
            l_ael_line_rec.ref_cust_trx_line_gl_dist_id := gl_rec_inv.cust_trx_line_gl_dist_id;
            l_ael_line_rec.ref_account_class            := gl_rec_inv.account_class;
            l_ael_line_rec.activity_bucket              := gl_rec_inv.activity_bucket;
            l_ael_line_rec.ref_dist_ccid                := gl_rec_inv.code_combination_id;

            Assign_Ael_Elements( p_ae_line_rec   => l_ael_line_rec );
           End Loop;

          -- CM
          IF p_app_rec.application_type = 'CM' THEN
   	       arp_standard.debug('Creating detailed distributions for CM');

            l_ael_line_rec.ae_line_type           := 'REC';
            l_ael_line_rec.ae_line_type_secondary := '';
            l_ael_line_rec.entered_dr             := NULL;
            l_ael_line_rec.from_amount_dr         := NULL;
            l_ael_line_rec.entered_cr             := 0;
            l_ael_line_rec.from_amount_cr         := 0;
            l_ael_line_rec.accounted_dr           := NULL;
            l_ael_line_rec.from_acctd_amount_dr   := NULL;
            l_ael_line_rec.accounted_cr           := 0;
            l_ael_line_rec.from_acctd_amount_cr   := 0;
            l_ael_line_rec.account                      := p_ctlgd_cm_rec.code_combination_id;
            l_ael_line_rec.currency_code                := p_cust_cm_rec.invoice_currency_code;
            l_ael_line_rec.currency_conversion_rate     := p_cust_cm_rec.exchange_rate;
            l_ael_line_rec.currency_conversion_type     := p_cust_cm_rec.exchange_rate_type;
            l_ael_line_rec.currency_conversion_date     := p_cust_cm_rec.exchange_date;
            l_ael_line_rec.third_party_id               := p_cust_cm_rec.bill_to_customer_id;
            l_ael_line_rec.third_party_sub_id           := p_cust_cm_rec.bill_to_site_use_id;

           For gl_rec_cm in (select cust_trx_line_gl_dist_id,
                                 customer_trx_line_id,
                                 code_combination_id,
                                 decode(account_class,       'REV',     account_class,
                                                             'UNBILL',  account_class,
                                                             'UNEARN',  account_class,
                                                             'TAX',     account_class,
                                                             'FREIGHT', account_class,
                                                             'CHARGES', account_class,
                                                             NULL) account_class,
                                 decode(account_class,       'REV',     'APP_LINE',
                                                             'UNBILL',  'APP_LINE',
                                                             'UNEARN',  'APP_LINE',
                                                             'TAX',     'APP_TAX',
                                                             'FREIGHT', 'APP_FRT',
                                                             'CHARGES', 'APP_CHRG',
                                                             NULL) activity_bucket
                          from   ra_cust_trx_line_gl_dist
                          where  customer_trx_id = p_cust_cm_rec.customer_trx_id
                          and    customer_trx_line_id is not null
                          and    account_set_flag = 'N') Loop

            l_ael_line_rec.ref_customer_trx_line_id     := gl_rec_cm.customer_trx_line_id;
            l_ael_line_rec.ref_cust_trx_line_gl_dist_id := gl_rec_cm.cust_trx_line_gl_dist_id;
            l_ael_line_rec.ref_account_class            := gl_rec_cm.account_class;
            l_ael_line_rec.activity_bucket              := gl_rec_cm.activity_bucket;
            l_ael_line_rec.ref_dist_ccid                := gl_rec_cm.code_combination_id;

            Assign_Ael_Elements( p_ae_line_rec   => l_ael_line_rec );
           End Loop;
          END IF;
         ELSE
            Assign_Ael_Elements( p_ae_line_rec   => l_ael_line_rec );
         END IF;

           -- reset ref_mf_dist_flag to null
           l_ael_line_rec.ref_mf_dist_flag := NULL;
        END IF;

      END IF;
      /*--------------------------------------------------------------------------------+
       | Derive Round, Gain or Loss accounting for Receipts and Credit Memo applications|
       | On-Account Credit Memos combined with Receipts.                                |
       +--------------------------------------------------------------------------------*/
        IF sign(p_app_rec.acctd_amount_applied_from - p_app_rec.acctd_amount_applied_to) = -1 THEN

           IF (p_miscel_rec.fixed_rate = 'Y') THEN
              l_ael_line_rec.ae_line_type := 'CURR_ROUND';  --Currency Round account
           ELSE
              l_ael_line_rec.ae_line_type := 'EXCH_LOSS'; --Exchange Loss
           END IF;

           --Null out NOCOPY exchange rate and currency information
           l_ael_line_rec.currency_code            := NULL;
           l_ael_line_rec.currency_conversion_rate := NULL;
           l_ael_line_rec.currency_conversion_type := NULL;
           l_ael_line_rec.currency_conversion_date := NULL;
           l_ael_line_rec.third_party_id           := NULL;
           l_ael_line_rec.third_party_sub_id       := NULL;

           l_ael_line_rec.account := p_miscel_rec.gain_loss_ccid;

           l_ael_line_rec.accounted_dr := abs(p_app_rec.acctd_amount_applied_from
                                                                   - p_app_rec.acctd_amount_applied_to);
           l_ael_line_rec.entered_dr   := 0 ;

           l_ael_line_rec.from_acctd_amount_dr := 0;
           l_ael_line_rec.from_amount_dr   := 0 ;


           l_ael_line_rec.entered_cr   := NULL;
           l_ael_line_rec.accounted_cr := NULL;
           l_ael_line_rec.from_acctd_amount_cr := NULL;
           l_ael_line_rec.from_amount_cr   := NULL ;

          -- Assign AEL for Exchange Loss
           Assign_Ael_Elements( p_ae_line_rec 	=> l_ael_line_rec );

        ELSIF sign(p_app_rec.acctd_amount_applied_from - p_app_rec.acctd_amount_applied_to) = 1 THEN

           IF (p_miscel_rec.fixed_rate = 'Y') THEN
              l_ael_line_rec.ae_line_type := 'CURR_ROUND';   --Currency Round account
           ELSE
              l_ael_line_rec.ae_line_type := 'EXCH_GAIN';  --Exchange Gain
           END IF;

           --Null out NOCOPY exchange rate and currency information

           l_ael_line_rec.currency_code            := NULL;
           l_ael_line_rec.currency_conversion_rate := NULL;
           l_ael_line_rec.currency_conversion_type := NULL;
           l_ael_line_rec.currency_conversion_date := NULL;
           l_ael_line_rec.third_party_id           := NULL;
           l_ael_line_rec.third_party_sub_id       := NULL;

           --Exchange rate currency and other details are from the Invoice or Credit Memo document
           l_ael_line_rec.account := p_miscel_rec.gain_loss_ccid;

           l_ael_line_rec.accounted_cr := p_app_rec.acctd_amount_applied_from
                                                                   - p_app_rec.acctd_amount_applied_to ;
           l_ael_line_rec.entered_cr   := 0 ;


           l_ael_line_rec.from_acctd_amount_cr := 0;
           l_ael_line_rec.from_amount_cr:= 0;


           l_ael_line_rec.entered_dr   := NULL;
           l_ael_line_rec.accounted_dr := NULL;
           l_ael_line_rec.from_acctd_amount_dr := NULL;
           l_ael_line_rec.from_amount_dr   := NULL ;


          -- Assign AEL for Exchange Gain
           Assign_Ael_Elements( p_ae_line_rec 	=> l_ael_line_rec );

        END IF;

        -- Call tax accounting routine for Receipt payments, earned and unearned discounts
        -- for Receipts, if amount_applied, earned discounts or unearned discounts is non zero

--        IF ((p_app_rec.application_type <> 'CM')
          IF (((nvl(p_app_rec.earned_discount_taken,0) <> 0) OR (nvl(p_app_rec.unearned_discount_taken,0) <> 0)
               OR (p_app_rec.amount_applied <> 0)) AND (p_app_rec.status ='APP')) THEN

           l_ae_line_tbl := g_empty_ae_line_tbl;
           l_ae_ctr      := 0;

        /*---------------------------------------------------------------------------+
         | Verify whether invalid rule setup has occurred at the Receivable Activity |
         | in this case raise an error stating that the rule be set up correctly.    |
         +---------------------------------------------------------------------------*/
           IF (((((p_rule_rec.gl_account_source1 = 'NO_SOURCE') OR (p_rule_rec.tax_code_source1 = 'NO_SOURCE'))
                 OR ((p_rule_rec.tax_code_source1 = 'INVOICE') AND (nvl(p_rule_rec.tax_recoverable_flag1, 'X') NOT IN ('Y','N'))))
               AND (nvl(p_app_rec.earned_discount_taken,0) <> 0))
           OR ((((p_rule_rec.gl_account_source2 = 'NO_SOURCE') OR (p_rule_rec.tax_code_source2 = 'NO_SOURCE'))
                 OR ((p_rule_rec.tax_code_source2 = 'INVOICE') AND (nvl(p_rule_rec.tax_recoverable_flag2, 'X') NOT IN ('Y','N'))))
               AND (nvl(p_app_rec.unearned_discount_taken,0) <> 0))) THEN

              RAISE ARP_ALLOCATION_PKG.invalid_allocation_base;

           END IF;

        /*---------------------------------------------------------------------------+
         | The deferred tax flag is set by the Bills Receivable Houskeeper. When this|
         | is No, it means that there is no Tax accounting impact, as the maturity   |
         | date event would have moved the deferred tax. For Transactions and where  |
         | the Maturity date event merges with the creation of Receipt application,  |
         | the Tax accounting Wrapper routine is called. For Transactions the normal |
         | Tax accounting routine is called. Note for Bills Receivable we only move  |
         | deferred tax as there is no discount.                                     |
         +---------------------------------------------------------------------------*/
           IF (nvl(g_ae_doc_rec.deferred_tax,'Y') = 'Y') THEN

              FOR l_i in 1..l_j LOOP

                 IF l_i = 1 THEN

                    l_cust_inv_cm_rec := p_cust_inv_rec;
                    l_app_rec := p_app_rec;
                    g_ae_doc_rec.inv_cm_app_mode := 'I';

                 ELSIF l_i = 2 THEN

                  --{HYUDETUPT

                   -- move to detail distribution
                   ------------------------------
                   -- at this level we pass the ra_record as it is and add a flag to allocation to
                   -- indicate the document allocating
                   --
                   l_app_rec := p_app_rec;
                   l_app_rec.applied_customer_trx_id       := p_app_rec.customer_trx_id;
                   l_app_rec.customer_trx_id               := p_app_rec.customer_trx_id;
                   l_app_rec.receivable_application_id     := p_app_rec.receivable_application_id;
                   --{switch of accounted amount for CM G/L
                   l_app_rec.acctd_amount_applied_from     := p_app_rec.acctd_amount_applied_to;
                   l_app_rec.acctd_amount_applied_to       := p_app_rec.acctd_amount_applied_from;
                   --}
                   g_ae_doc_rec.inv_cm_app_mode := 'C';
                   l_cust_inv_cm_rec := p_cust_cm_rec;

                 END IF;

                 -- Bug 6598080 - Modified if condition to restrict duplicate record entry for BR to CM application.
                 IF p_cust_inv_rec.drawee_site_use_id IS NULL
                       OR ((l_i = 2) AND (p_cust_inv_rec.drawee_site_use_id IS NOT NULL) AND  (p_app_rec.application_type = 'CM')) THEN --application to Transaction

                  IF l_call_alloc_tax = TRUE THEN
                   ARP_ALLOCATION_PKG.Allocate_Tax(
                        p_ae_doc_rec           => g_ae_doc_rec   ,     --Document detail
                        p_ae_event_rec         => g_ae_event_rec ,     --Event record
                        p_ae_rule_rec          => p_rule_rec     ,     --Rule info for payment method
                        p_app_rec              => l_app_rec      ,     --Application details
                        p_cust_inv_rec         => l_cust_inv_cm_rec,   --p_cust_inv_rec ,     --Invoice, details
                        p_adj_rec              => l_adj_rec      ,     --dummy adjustment record
                        p_ae_ctr               => l_ae_ctr       ,     --counter
                        p_ae_line_tbl          => l_ae_line_tbl  ,     --final tax accounting table
                        p_br_cust_trx_line_id  => NULL,
                        p_simul_app            => NULL               ,
                        --{HYUDETUPT
                        p_from_llca_call       => p_from_llca_call,
                        p_gt_id                => p_gt_id,
                        -- Need to move the ra record conversion from inv to cm at detail distribution
                        p_inv_cm               => g_ae_doc_rec.inv_cm_app_mode
                        );
                  END IF;

                 ELSE --application to Bills Receivable

                   ARP_BR_ALLOC_WRAPPER_PKG.Allocate_Tax_BR_Main(
                        p_mode                 => g_mode         ,     --Mode
                        p_ae_doc_rec           => g_ae_doc_rec   ,     --Document detail
                        p_ae_event_rec         => g_ae_event_rec ,     --Event record
                        p_ae_rule_rec          => p_rule_rec     ,     --Rule info for payment method
                        p_app_rec              => p_app_rec      ,     --Application details
                        p_cust_inv_rec         => p_cust_inv_rec ,     --Invoice details
                        p_adj_rec              => l_adj_rec      ,     --dummy adjustment record
                        p_ae_sys_rec           => g_ae_sys_rec   ,     --system parameters
                        p_ae_ctr               => l_ae_ctr       ,     --counter
                        p_ae_line_tbl          => l_ae_line_tbl); --final tax accounting table
                        -- There is no requirement from converting ra record from inv to cm for BR
                        -- as we can not apply CM to BR


                 END IF; --application to Bill or Transaction

              END LOOP; --dual call to allocation routine

           ELSE
         /*-----------------------------------------------------------------------+
          | do not call the Tax accounting to move deferred tax this happens when |
          | the Bills Receivable Housekeeper determines that the maturity date    |
          | event is seperate from the creation of the application, for standard  |
          | Remittance and Factored (with Recourse) we need to update the link id |
          | so the last Transaction History Record must be Standard Remitted or   |
          | pending risk elimination                                              |
          +-----------------------------------------------------------------------*/
              update ar_receivable_applications
              set link_to_trx_hist_id   = (select max(th.transaction_history_id)
                                           from ar_transaction_history th
                                           where th.customer_trx_id = p_app_rec.applied_customer_trx_id
                                           and th.event = 'MATURITY_DATE'
                                           and exists (select 'x'
                                                       from ar_distributions ard
                                                       where ard.source_id = th.transaction_history_id
                                                       and ard.source_table = 'TH'))
              where receivable_application_id = p_app_rec.receivable_application_id;

           END IF; --End if Tax accounting or deferred tax required

           IF l_ae_line_tbl.EXISTS(l_ae_ctr) THEN --Atleast one Tax line exists

              FOR l_ctr IN l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST LOOP

                --It is necessary to populate the record and then call assign elements
                --because of standards and that the User Hook could override accounting
                --so need to populate this record (rather than direct table assignments)

                  l_ael_line_rec := l_empty_ael_line_rec;
                  l_ael_line_rec := l_ae_line_tbl(l_ctr);

                --Asign AEL for REC for Credit Memo document
                  Assign_Ael_Elements( p_ae_line_rec         => l_ael_line_rec );

              END LOOP; --lines table

           END IF; --line table records exist

        END IF; --deferred tax is to be moved

   END IF; --receipt aplication and discounts or payment is non zero move deferred tax

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'p_cust_cm_rec.upgrade_method  '||p_cust_cm_rec.upgrade_method);
  END IF;

  --deferred tax check
  IF p_cust_cm_rec.upgrade_method = 'R12_MERGE' THEN
    BEGIN
      select 'Y'
      into l_def_tax_flag
      from  ra_cust_trx_line_gl_dist gld
      where gld.account_class = 'TAX'
      and   gld.customer_trx_id = p_cust_cm_rec.customer_trx_id
      and   gld.collected_tax_ccid IS NOT NULL
      and   rownum = 1;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	  l_def_tax_flag := 'N';
    END;
  END IF;

  --Receivable account record for CM Bills Receivable only
  -- Bug 6598080 - Modified if condition
  IF p_app_rec.application_type = 'CM'
      AND ((p_app_rec.amount_applied = 0 AND
        nvl(p_cust_cm_rec.upgrade_method,'R12_NLB') in ('R12_MERGE','R12_11ICASH'))
        OR
      (p_cust_cm_rec.upgrade_method = 'R12_MERGE' AND
        nvl(l_def_tax_flag,'N') = 'N') ) then

     l_ael_line_rec.ae_line_type := 'REC';
     l_ael_line_rec.ae_line_type_secondary := '';

      /* Bug 2306701. Zero amount application of Credit memo is same as Positive
           application. */

     IF ( sign( p_app_rec.amount_applied ) in  (-1,0)) THEN   -- Credit Receivables for CM

        -- For REC (APP) and discounts, accounting in currency of Invoice document

        l_ael_line_rec.entered_cr   := abs(p_app_rec.amount_applied);

        l_ael_line_rec.accounted_cr := abs(p_app_rec.acctd_amount_applied_from);

        l_ael_line_rec.entered_dr   := NULL;
        l_ael_line_rec.accounted_dr := NULL;

     ELSE

        l_ael_line_rec.entered_dr   := p_app_rec.amount_applied;

        l_ael_line_rec.accounted_dr := p_app_rec.acctd_amount_applied_from;

        l_ael_line_rec.entered_cr   := NULL;
        l_ael_line_rec.accounted_cr := NULL;

     END IF;

    -- Override exchange rate information and use Credit Memo Rate
     l_ael_line_rec.account                  := p_ctlgd_cm_rec.code_combination_id;
     l_ael_line_rec.currency_code            := p_cust_cm_rec.invoice_currency_code;
     l_ael_line_rec.currency_conversion_rate := p_cust_cm_rec.exchange_rate;
     l_ael_line_rec.currency_conversion_type := p_cust_cm_rec.exchange_rate_type;
     l_ael_line_rec.currency_conversion_date := p_cust_cm_rec.exchange_date;
     l_ael_line_rec.third_party_id           := p_cust_cm_rec.bill_to_customer_id;
     l_ael_line_rec.third_party_sub_id       := p_cust_cm_rec.bill_to_site_use_id;

     --Asign AEL for REC for Credit Memo document
     IF p_cust_inv_rec.drawee_site_use_id IS NOT NULL OR sign(p_app_rec.amount_applied) = 0 OR
        p_cust_cm_rec.upgrade_method = 'R12_MERGE' THEN
        Assign_Ael_Elements( p_ae_line_rec      => l_ael_line_rec );
     END IF;

  END IF;


  --Receivable account record for CM Activity only
  IF    p_app_rec.application_type     = 'CM'
    AND p_cust_inv_rec.customer_trx_id IS NULL
    AND p_app_rec.amount_applied       <> 0
    AND p_app_rec.status               = 'ACTIVITY'
  THEN

     l_app_rec                               := p_app_rec;
     l_app_rec.applied_customer_trx_id       := p_app_rec.customer_trx_id;
     l_app_rec.customer_trx_id               := p_app_rec.customer_trx_id;
     l_app_rec.receivable_application_id     := p_app_rec.receivable_application_id;
     l_app_rec.acctd_amount_applied_from     := p_app_rec.acctd_amount_applied_to;
     l_app_rec.acctd_amount_applied_to       := p_app_rec.acctd_amount_applied_from;
     g_ae_doc_rec.inv_cm_app_mode            := 'C';
     l_cust_inv_cm_rec                       := p_cust_cm_rec;

     ARP_ALLOCATION_PKG.Allocate_Tax(
                        p_ae_doc_rec           => g_ae_doc_rec   ,     --Document detail
                        p_ae_event_rec         => g_ae_event_rec ,     --Event record
                        p_ae_rule_rec          => p_rule_rec     ,     --Rule info for payment method
                        p_app_rec              => l_app_rec      ,     --Application details
                        p_cust_inv_rec         => l_cust_inv_cm_rec,   --p_cust_inv_rec ,     --Invoice, details
                        p_adj_rec              => l_adj_rec      ,     --dummy adjustment record
                        p_ae_ctr               => l_ae_ctr       ,     --counter
                        p_ae_line_tbl          => l_ae_line_tbl  ,     --final tax accounting table
                        p_br_cust_trx_line_id  => NULL,
                        p_simul_app            => NULL               ,
                        p_from_llca_call       => p_from_llca_call,
                        p_gt_id                => p_gt_id,
                        p_inv_cm               => g_ae_doc_rec.inv_cm_app_mode
                        );


      IF l_ae_line_tbl.EXISTS(l_ae_ctr) THEN --Atleast one Tax line exists

              FOR l_ctr IN l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST LOOP

                --It is necessary to populate the record and then call assign elements
                --because of standards and that the User Hook could override accounting
                --so need to populate this record (rather than direct table assignments)

                  l_ael_line_rec := l_empty_ael_line_rec;
                  l_ael_line_rec := l_ae_line_tbl(l_ctr);

                --Asign AEL for REC for Credit Memo document
                  Assign_Ael_Elements( p_ae_line_rec         => l_ael_line_rec );

              END LOOP; --lines table

     END IF; --line table records exist

  END IF;

/*-----------------------------------------------------------------------------------+
 |Call the Reconciliation routine, this is necessary because the transaction or Bill |
 |which may have been overapplied is now closed due to reversal, or else the reversal|
 |may have resulted in re-opening the transaction, hence we need to back out NOCOPY the old |
 |reconciliation entries for the Bill or the Transactions                            |
 +-----------------------------------------------------------------------------------*/
  IF (p_app_rec.status = 'APP') THEN

     ARP_RECONCILE.Reconcile_trx_br(
                   p_mode                     => g_mode                             ,
                   p_ae_doc_rec               => g_ae_doc_rec                       ,
                   p_ae_event_rec             => g_ae_event_rec                     ,
                   p_cust_inv_rec             => p_cust_inv_rec                     ,
                   p_activity_cust_trx_id     => p_app_rec.applied_customer_trx_id  ,
                   p_activity_amt             => p_app_rec.amount_applied * -1      ,
                   p_activity_acctd_amt       => p_app_rec.acctd_amount_applied_to * -1,
                   p_call_num                 => 1                                  ,
                   p_g_ae_line_tbl            => g_ae_line_tbl                      ,
                   p_g_ae_ctr                 => g_ae_line_ctr                        );

     IF p_app_rec.application_type = 'CM' THEN

           ARP_RECONCILE.Reconcile_trx_br(
                      p_mode                     => g_mode                                 ,
                      p_ae_doc_rec               => g_ae_doc_rec                           ,
                      p_ae_event_rec             => g_ae_event_rec                         ,
                      p_cust_inv_rec             => p_cust_cm_rec                          ,
                      p_activity_cust_trx_id     => p_app_rec.customer_trx_id              ,
                      p_activity_amt             => p_app_rec.amount_applied               ,
                      p_activity_acctd_amt       => p_app_rec.acctd_amount_applied_from    ,
                      p_call_num                 => 2                                      ,
                      p_g_ae_line_tbl            => g_ae_line_tbl                          ,
                      p_g_ae_ctr                 => g_ae_line_ctr                            );

     END IF; --application type is Credit Memo

  END IF; -- reconciliation routine called for applications only

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_RECEIPTS_MAIN.Create_Ae_Lines_RA()-');
  END IF;

EXCEPTION
  WHEN ARP_ALLOCATION_PKG.invalid_allocation_base THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECEIPTS_MAIN.Create_Ae_Lines_RA - invalid_rule_error');
     END IF;
     fnd_message.set_name('AR','AR_INVALID_ACTIVITY');
     RAISE;

  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECEIPTS_MAIN.Create_Ae_Lines_RA - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Create_Ae_Lines_RA');
     END IF;
     RAISE;

END Create_Ae_Lines_RA;

/* =======================================================================
 | PROCEDURE Create_Ae_Lines_MCD
 |
 | DESCRIPTION
 |      This procedure creates the AE lines for Unidentified, On-Account
 |      and Receivables and also creates the pairing Unapplied Cash record
 |      Will be used when Creating Receipts and Reversing Receipts
 |
 |      Functions:
 |              - Create AE lines for Receivable and Unapplied Cash.
 |              - Determines Amounts Dr/Cr.
 |
 | PARAMETERS
 |      p_cr_rec        Cash Receipt Record
 |      p_vat_rec       VAT tax Record
 |      p_curr_rec      Currency Record
 * ======================================================================*/
PROCEDURE Create_Ae_Lines_MCD(
                p_cr_rec         IN ar_cash_receipts%ROWTYPE    ,
                p_vat_rec        IN ar_vat_tax%ROWTYPE          ,
                p_curr_rec       IN ae_curr_rec_type            ) IS

  -- MRC TRigger REPLACEMENT:  modified cursor to extract acctd_amount
  -- based on function.

  CURSOR get_mcd_rec IS
  SELECT mcd.misc_cash_distribution_id misc_cash_distribution_id ,
         mcd.code_combination_id       code_combination_id ,
         mcd.percent                   percent ,
         mcd.amount                    amount ,
         mcd.acctd_amount              acctd_amount
  FROM  ar_misc_cash_distributions mcd
  WHERE mcd.cash_receipt_id  = g_ae_doc_rec.document_id
  AND   g_ae_sys_rec.sob_type = 'P'
  AND   mcd.reversal_gl_date is null   --so we create only new rate adjusted or new mcd records
  AND   mcd.posting_control_id = -3
  AND   not exists (select 'x'
                    from ar_distributions ard
                    where ard.source_id = mcd.misc_cash_distribution_id
                    and   ard.source_table = 'MCD')
  ORDER by misc_cash_distribution_id;
--{BUG4301323
/*  UNION
  SELECT mcd.misc_cash_distribution_id  misc_cash_distribution_id,
         mcd.code_combination_id        code_combination_id,
         mcd.percent                    percent,
         mcd.amount                     amount,
         mcd_mrc.acctd_amount           acctd_amount
  FROM  ar_misc_cash_distributions mcd,
        ar_mc_misc_cash_dists mcd_mrc
  WHERE mcd.cash_receipt_id  = g_ae_doc_rec.document_id
  AND   mcd.misc_cash_distribution_id = mcd_mrc.misc_cash_distribution_id
  AND   g_ae_sys_rec.sob_type = 'R'
  AND   mcd_mrc.set_of_books_id = g_ae_sys_rec.set_of_books_id
  AND   mcd.reversal_gl_date is null   --so we create only new rate adjusted or new mcd records.
  AND   mcd_mrc.posting_control_id = -3
  AND   not exists (select 'x'
                    from ar_mc_distributions_all ard
                    where ard.source_id = mcd.misc_cash_distribution_id
                    and   ard.source_table = 'MCD'
                    and   ard.set_of_books_id = g_ae_sys_rec.set_of_books_id)
*/
  l_ael_line_rec              ae_line_rec_type;
  l_mcd_first_rec_id          ar_misc_cash_distributions.misc_cash_distribution_id%TYPE ;

  l_mcd_actual_acctd_amt      NUMBER  := 0;
  l_mcd_amount                NUMBER  := 0;
  l_mcd_acctd_amount          NUMBER  := 0;
  l_mcd_run_amt_tot           NUMBER  := 0;
  l_mcd_run_acctd_amt_tot     NUMBER  := 0;
  l_mcd_run_pro_amt_tot       NUMBER  := 0;
  l_mcd_run_pro_acctd_amt_tot NUMBER  := 0;
  l_mcd_tax_amt               NUMBER  := 0;
  l_mcd_tax_acctd_amt         NUMBER  := 0;
  l_mcd_taxable_amt           NUMBER  := 0;
  l_mcd_taxable_acctd_amt     NUMBER  := 0;
  l_mcd_exists                BOOLEAN := FALSE;
  l_dummy                     VARCHAR2(1);
/* Added for bug 2494858 */
  l_precision	              NUMBER  := 0;
  l_extended_precision	      NUMBER  := 0;
  l_rounding_rule	      VARCHAR2(30);
  l_min_acct_unit	      NUMBER  := 0;
/* end of bug 2494858 */
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_RECEIPTS_MAIN.Create_Ae_Lines_MCD()+');
  END IF;

/* Added the next two statements for bug 2494858 */
  l_rounding_rule := arp_standard.sysparm.tax_rounding_rule;
  fnd_currency.get_info(p_cr_rec.currency_code,l_precision,l_extended_precision,l_min_acct_unit);


 /*-------------------------------------------------------------+
  | Get exchange rate and third part info from Cash Receipt for |
  | building MISCCASH records in AR_DISTRIBUTIONS               |
  +-------------------------------------------------------------*/
   l_mcd_first_rec_id                      := '';

   l_ael_line_rec.source_table             := 'MCD';
   l_ael_line_rec.source_id_secondary      := p_cr_rec.cash_receipt_id;
   l_ael_line_rec.source_table_secondary   := 'CR';
   l_ael_line_rec.currency_code            := p_cr_rec.currency_code;
   l_ael_line_rec.currency_conversion_rate := p_cr_rec.exchange_rate;
   l_ael_line_rec.currency_conversion_type := p_cr_rec.exchange_rate_type;
   l_ael_line_rec.currency_conversion_date := p_cr_rec.exchange_date;
   l_ael_line_rec.third_party_id           := p_cr_rec.pay_from_customer;
   l_ael_line_rec.third_party_sub_id       := p_cr_rec.customer_site_use_id;

   FOR l_mcd_rec in get_mcd_rec LOOP

       IF l_mcd_first_rec_id IS NULL THEN
          l_mcd_first_rec_id := l_mcd_rec.misc_cash_distribution_id;
          l_mcd_exists := TRUE;
       END IF;

       l_mcd_actual_acctd_amt  := l_mcd_actual_acctd_amt + l_mcd_rec.acctd_amount;

       l_ael_line_rec.source_id     := l_mcd_rec.misc_cash_distribution_id;
       l_ael_line_rec.ae_line_type  := 'MISCCASH';
       l_ael_line_rec.account       := l_mcd_rec.code_combination_id;


       IF (nvl(p_cr_rec.tax_rate,0) <> 0) THEN

        /*------------------------------------------------------------------------------+
         | Maintain running total amounts for MCD amounts and MCD accounted amounts     |
         +------------------------------------------------------------------------------*/
          l_mcd_run_amt_tot       := l_mcd_run_amt_tot + l_mcd_rec.amount;
          l_mcd_run_acctd_amt_tot := l_mcd_run_acctd_amt_tot + l_mcd_rec.acctd_amount;

        /*------------------------------------------------------------------------------+
         | Determine actual MCD amounts and accounted amounts using the following.      |
         | Line 1 100, Line 2 200, Line 3 300 (Total MCD amount = 600) Tax 2%           |
         |                                                                              |
         |  1 - 2/(100 + 2)= .98039216                                                  |
         |                                                                              |
         | Line 1  a -> .98039216 * 100  = 98.04 (allocated)                            |
         |                                                                              |
         | Line 2    -> (100 + 200) * .98 = 294.12                                      |
         |         b -> 294.12 - a = 196.08 (allocated)                                 |
         |                                                                              |
         | Line 3    -> (100 + 200 + 300) * .98 = 588.24                                |
         |         c -> 588.24 - a - b = 294.12                                         |
         +------------------------------------------------------------------------------*/

          l_mcd_amount    := arpcurr.CurrRound(l_mcd_run_amt_tot * (1 - (p_cr_rec.tax_rate/(100 + p_cr_rec.tax_rate))),
                                               p_cr_rec.currency_code) - l_mcd_run_pro_amt_tot;

        /*------------------------------------------------------------------------------+
         | Running total for prorated mcd amount in currency of Invoice                 |
         +------------------------------------------------------------------------------*/
          l_mcd_run_pro_amt_tot := l_mcd_run_pro_amt_tot + l_mcd_amount;

        /*------------------------------------------------------------------------------+
         | Calculate MCD accounted amount for MCD line                                  |
         +------------------------------------------------------------------------------*/
          l_mcd_acctd_amount  := arpcurr.CurrRound(l_mcd_run_acctd_amt_tot * (1 - (p_cr_rec.tax_rate/(100 + p_cr_rec.tax_rate))),
                                                   g_ae_sys_rec.base_currency) - l_mcd_run_pro_acctd_amt_tot;

        /*------------------------------------------------------------------------------+
         | Running total for prorated MCD accounted amount in currency of Invoice       |
         +------------------------------------------------------------------------------*/
          l_mcd_run_pro_acctd_amt_tot := l_mcd_run_pro_acctd_amt_tot + l_mcd_acctd_amount;


       ELSE

          l_mcd_amount                := l_mcd_rec.amount;
          l_mcd_run_pro_amt_tot       := l_mcd_run_pro_amt_tot + l_mcd_amount;

          l_mcd_acctd_amount          := l_mcd_rec.acctd_amount;
          l_mcd_run_pro_acctd_amt_tot := l_mcd_run_pro_acctd_amt_tot + l_mcd_acctd_amount;

       END IF;
       /* Bug 2233284
          tax_link_id need to be assigned even if the tax_rate is zero */
       IF p_cr_rec.tax_rate is NOT NULL THEN
          l_ael_line_rec.tax_link_id := 1;
       ELSE
          l_ael_line_rec.tax_link_id := NULL;
       END IF;

       IF sign(l_mcd_amount) = -1 THEN    -- Debits for Misc Cash Payments

          l_ael_line_rec.entered_dr   := abs(l_mcd_amount);
          l_ael_line_rec.accounted_dr := abs(l_mcd_acctd_amount);
          l_ael_line_rec.entered_cr   := NULL;
          l_ael_line_rec.accounted_cr := NULL;

       ELSE  -- Credits for Misc Cash Receipts includes 0 dollar amounts

             l_ael_line_rec.entered_cr   := l_mcd_amount;
             l_ael_line_rec.accounted_cr := l_mcd_acctd_amount;
             l_ael_line_rec.entered_dr   := NULL;
             l_ael_line_rec.accounted_dr := NULL;

       END IF;

    -- Assign AEL for Misc Cash Distributions
       Assign_Ael_Elements( p_ae_line_rec        => l_ael_line_rec );

   END LOOP;

  -- Create Tax line if required for Misc Cash Receipt or Misc Cash Payment
    /* Bug 2233284
       The Tax accounting line should be created for 0% tax rate also.
       IF ((nvl(p_cr_rec.tax_rate,0) <> 0) AND (l_mcd_exists)) THEN */

     IF ((p_cr_rec.tax_rate IS NOT NULL) AND (l_mcd_exists)) THEN

       l_ael_line_rec.source_table  := 'MCD';
       l_ael_line_rec.source_id     := l_mcd_first_rec_id;   -- Hook tax line with first MCD line
       l_ael_line_rec.ae_line_type  := 'TAX';
       l_ael_line_rec.ae_line_type_secondary  := 'MISCCASH';
       l_ael_line_rec.account       := p_vat_rec.tax_account_id;
       l_ael_line_rec.tax_code_id   := p_vat_rec.vat_tax_id;
       l_ael_line_rec.tax_link_id   := 1;

     /*------------------------------------------------------------------------------+
      | Calculate Tax for MCD using rate from Misc Cash Receipt or Payment           |
      +------------------------------------------------------------------------------*/
/* The below statement is commented for bug 2494858 and the next statement is added */
     /*  l_mcd_tax_amt        := arpcurr.CurrRound(p_cr_rec.amount * (p_cr_rec.tax_rate/(100 + p_cr_rec.tax_rate)),
                                                 p_cr_rec.currency_code);*/

       l_mcd_tax_amt := arp_etax_util.tax_curr_round(p_cr_rec.amount * p_cr_rec.tax_rate/(100 + p_cr_rec.tax_rate),p_cr_rec.currency_code,l_precision,l_min_acct_unit,l_rounding_rule,'Y');

     /*------------------------------------------------------------------------------+
      | Maintain running totals adding tax amount                                    |
      +------------------------------------------------------------------------------*/
       l_mcd_run_pro_amt_tot := l_mcd_run_pro_amt_tot + l_mcd_tax_amt;

     /*------------------------------------------------------------------------------+
      | Calculate Tax accounted for MCD using rate from Misc Cash Receipt or Payment |
      +------------------------------------------------------------------------------*/
  /* The below statement is commented for bug 2494858 and the next two statements are added */
     /*  l_mcd_tax_acctd_amt  := arpcurr.CurrRound(l_mcd_actual_acctd_amt * (p_cr_rec.tax_rate/(100 + p_cr_rec.tax_rate)),
                                                 g_ae_sys_rec.base_currency); */

      fnd_currency.get_info(g_ae_sys_rec.base_currency, l_precision,l_extended_precision, l_min_acct_unit);

      l_mcd_tax_acctd_amt := arp_etax_util.tax_curr_round(l_mcd_actual_acctd_amt * p_cr_rec.tax_rate/(100 + p_cr_rec.tax_rate), g_ae_sys_rec.base_currency, l_precision, l_min_acct_unit, l_rounding_rule, 'Y');

     /*------------------------------------------------------------------------------+
      | Maintain running totals for tax accounted                                    |
      +------------------------------------------------------------------------------*/
       l_mcd_run_pro_acctd_amt_tot := l_mcd_run_pro_acctd_amt_tot + l_mcd_tax_acctd_amt;

     /*------------------------------------------------------------------------------+
      | Calculate Taxable amount and Taxable accounted amount for Tax                |
      +------------------------------------------------------------------------------*/
       l_mcd_taxable_amt        := p_cr_rec.amount - l_mcd_tax_amt;

       l_mcd_taxable_acctd_amt  := l_mcd_actual_acctd_amt - l_mcd_tax_acctd_amt ;

     /*------------------------------------------------------------------------------+
      | Set Debit or Credits for Tax accounting record                               |
      +------------------------------------------------------------------------------*/
       IF sign(p_cr_rec.amount) = -1 THEN    --Debit Tax Account Payments

          l_ael_line_rec.entered_dr   := abs(l_mcd_tax_amt);
          l_ael_line_rec.accounted_dr := abs(l_mcd_tax_acctd_amt);

          l_ael_line_rec.entered_cr   := NULL;
          l_ael_line_rec.accounted_cr := NULL;

          l_ael_line_rec.taxable_entered_dr   := abs(l_mcd_taxable_amt);
          l_ael_line_rec.taxable_accounted_dr := abs(l_mcd_taxable_acctd_amt);

          l_ael_line_rec.taxable_entered_cr   := NULL;
          l_ael_line_rec.taxable_accounted_cr := NULL;

       ELSE --Credit Tax Account Receipts

          l_ael_line_rec.entered_cr   := l_mcd_tax_amt;
          l_ael_line_rec.accounted_cr := l_mcd_tax_acctd_amt;

          l_ael_line_rec.entered_dr   := NULL;
          l_ael_line_rec.accounted_dr := NULL;

          l_ael_line_rec.taxable_entered_cr   := l_mcd_taxable_amt;
          l_ael_line_rec.taxable_accounted_cr := l_mcd_taxable_acctd_amt;

          l_ael_line_rec.taxable_entered_dr   := NULL;
          l_ael_line_rec.taxable_accounted_dr := NULL;

       END IF;

     /*------------------------------------------------------------------------------+
      | Asign AEL for Tax line for Misc Cash                                         |
      +------------------------------------------------------------------------------*/
       Assign_Ael_Elements( p_ae_line_rec       => l_ael_line_rec );

     END IF;  --End if tax rate is not null

   /*------------------------------------------------------------------------------+
    | Raise no data found exception if this routine is called then MCD must exist  |
    | for creation of accounting                                                   |
    +------------------------------------------------------------------------------*/
     IF NOT l_mcd_exists THEN
        select 'x'
        into l_dummy
        from dual
        where 1 = 2;
     END IF;

  /*--------------------------------------------------------------------------------------------+
   |Now process for rounding correction generic in terms of the Maths which requires to be done |
   |End result is that the entered and accounted amounts must reconcile with those in the MCD   |
   |table, rounding correction is added to the first MCD line. As there exists atleast one MCD  |
   |hence process for rounding.                                                                 |
   +--------------------------------------------------------------------------------------------*/
     IF sign(p_cr_rec.amount) = -1 THEN  -- Add rounding correction to debits for Payments

        g_ae_line_tbl(1).entered_dr      :=  g_ae_line_tbl(1).entered_dr +
                                                 abs(p_cr_rec.amount) - abs(l_mcd_run_pro_amt_tot);

        g_ae_line_tbl(1).accounted_dr    :=  g_ae_line_tbl(1).accounted_dr +
                                                 abs(l_mcd_actual_acctd_amt) - abs(l_mcd_run_pro_acctd_amt_tot);

     ELSE  -- Add rounding correction for credits for Receipts

        g_ae_line_tbl(1).entered_cr      :=  g_ae_line_tbl(1).entered_cr   +
                                                 abs(p_cr_rec.amount) - abs(l_mcd_run_pro_amt_tot);

        g_ae_line_tbl(1).accounted_cr    :=  g_ae_line_tbl(1).accounted_cr +
                                                 abs(l_mcd_actual_acctd_amt) - abs(l_mcd_run_pro_acctd_amt_tot);

     END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_RECEIPTS_MAIN.Create_Ae_Lines_MCD()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECEIPTS_MAIN.Create_Ae_Lines_MCD - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Create_Ae_Lines_MCD');
     END IF;
     RAISE;

END Create_Ae_Lines_MCD;

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
               	p_ae_line_rec 		IN ae_line_rec_type ) IS

  l_account			NUMBER;
  l_account_valid		BOOLEAN;
  l_replace_default_account	BOOLEAN;

BEGIN
    arp_global.init_global;  --bug6024475
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_RECEIPTS_MAIN.Assign_Ael_Elements()+');
    END IF;

   /*------------------------------------------------------+
    | Call Hook to Override Account                        |
    +------------------------------------------------------*/
    ARP_ACCT_HOOK.Override_Account(
        	p_mode                  => g_mode,
        	p_ae_doc_rec            => g_ae_doc_rec,
        	p_ae_event_rec          => g_ae_event_rec,
		p_ae_line_rec		=> p_ae_line_rec,
		p_account		=> l_account,
		p_account_valid		=> l_account_valid,
		p_replace_default_account => l_replace_default_account
		);

    IF ( NOT l_replace_default_account ) THEN

      /*------------------------------------------------------+
       | SLA : Build Account for AE Line Type                 |
       |       When SLA is fully implemented Account Builder  |
       |       will be called from here.                      |
       +------------------------------------------------------*/
       l_account := p_ae_line_rec.account;

    END IF;		-- Replace default account?

   /*------------------------------------------------------+
    | SLA : Build Account description for AE Line Type     |
    |       When SLA is fully implemented Description 	   |
    |       builder will be called from here.              |
    +------------------------------------------------------*/

   /*------------------------------------------------------+
    | SLA : Check Negative Dr/Cr for AE Line 		   |
    |       When SLA is fully implemented.            	   |
    +------------------------------------------------------*/

   /*------------------------------------------------------+
    | Store AE Line elements in AE Lines temp table        |
    +------------------------------------------------------*/
    g_ae_line_ctr := g_ae_line_ctr +1;

    g_ae_line_tbl(g_ae_line_ctr).ae_line_type             :=  p_ae_line_rec.ae_line_type;
    g_ae_line_tbl(g_ae_line_ctr).ae_line_type_secondary   :=  p_ae_line_rec.ae_line_type_secondary;
    g_ae_line_tbl(g_ae_line_ctr).source_id                :=  p_ae_line_rec.source_id;
    g_ae_line_tbl(g_ae_line_ctr).source_table             :=  p_ae_line_rec.source_table;

    /*bug6024475 Passing the value of l_account after checking its validty and values of flags */
    if (l_replace_default_account and l_account_valid and l_account>0) then
        IF fnd_flex_keyval.validate_ccid(
                         appl_short_name  => 'SQLGL',
                         key_flex_code    => 'GL#',
                         structure_number => arp_global.chart_of_accounts_id,
                         combination_id   => l_account) THEN
		g_ae_line_tbl(g_ae_line_ctr).account      :=  l_account;
--bug6313298
	  IF (p_ae_line_rec.source_table = 'RA') then
		Update ar_receivable_applications set code_combination_id = l_account
		where receivable_application_id = p_ae_line_rec.source_id and status in
		('ACC', 'UNID', 'UNAPP', 'ACTIVITY', 'OTHER ACC');
	  END IF;
	else
		raise invalid_ccid_error;
	end if;
    else
		g_ae_line_tbl(g_ae_line_ctr).account      :=  p_ae_line_rec.account;
    end if;
    /*bug6024475 end*/

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
    --{3377004
    --{ref_dist_ccid + ref_mf_dist_flag
    g_ae_line_tbl(g_ae_line_ctr).ref_dist_ccid            :=  p_ae_line_rec.ref_dist_ccid;
    g_ae_line_tbl(g_ae_line_ctr).ref_mf_dist_flag         :=  p_ae_line_rec.ref_mf_dist_flag;
    g_ae_line_tbl(g_ae_line_ctr).ref_account_class                :=  p_ae_line_rec.ref_account_class;
    g_ae_line_tbl(g_ae_line_ctr).activity_bucket                   :=  p_ae_line_rec.activity_bucket;
    --}
    g_ae_line_tbl(g_ae_line_ctr).ref_line_id              :=  p_ae_line_rec.ref_line_id;
    g_ae_line_tbl(g_ae_line_ctr).ref_customer_trx_line_id :=  p_ae_line_rec.ref_customer_trx_line_id;
    g_ae_line_tbl(g_ae_line_ctr).ref_prev_cust_trx_line_id :=  p_ae_line_rec.ref_prev_cust_trx_line_id;
    g_ae_line_tbl(g_ae_line_ctr).ref_cust_trx_line_gl_dist_id :=  p_ae_line_rec.ref_cust_trx_line_gl_dist_id;
    g_ae_line_tbl(g_ae_line_ctr).from_amount_dr           :=  p_ae_line_rec.from_amount_dr;
    g_ae_line_tbl(g_ae_line_ctr).from_amount_cr           :=  p_ae_line_rec.from_amount_cr;
    g_ae_line_tbl(g_ae_line_ctr).from_acctd_amount_dr     :=  p_ae_line_rec.from_acctd_amount_dr;
    g_ae_line_tbl(g_ae_line_ctr).from_acctd_amount_cr     :=  p_ae_line_rec.from_acctd_amount_cr;
    --}
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_RECEIPTS_MAIN.Assign_Ael_Elements()-');
    END IF;

EXCEPTION
/*bug 6024475 adds a new exception.*/
  WHEN invalid_ccid_error THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Invalid Account ccid - ARP_RECEIPTS_MAIN.Assign_Ael_Elements' );
     END IF;
     fnd_message.set_name('AR','AR_INVALID_ACCOUNT');
     RAISE;
/* bug6024475 end*/
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_RECEIPTS_MAIN.Assign_Ael_Elements');
     END IF;
     RAISE;

END Assign_Ael_Elements;

--{3377004
FUNCTION ctl_id_index(p_ctl_id_tab  IN DBMS_SQL.NUMBER_TABLE,
                      p_ctl_id      IN NUMBER)
RETURN NUMBER
IS
  result  NUMBER;
  cnt     NUMBER := 0;
BEGIN
  arp_standard.debug('ctl_id_index+');
  result := -1;
  cnt := p_ctl_id_tab.COUNT;
  IF cnt > 0 THEN
    FOR i IN p_ctl_id_tab.FIRST .. p_ctl_id_tab.LAST LOOP
      IF p_ctl_id_tab(i) = p_ctl_id THEN
        result := i;
        EXIT;
      END IF;
    END LOOP;
  ELSE
    result := 1;
  END IF;
  IF result = -1 THEN
     result := cnt + 1;
  END IF;
  arp_standard.debug('  result index:'||result);
  arp_standard.debug('ctl_id_index-');
  RETURN result;
END;

PROCEDURE init_rem_amt(x_rem_amt IN OUT NOCOPY ctl_rem_amt_type,
                       p_index   IN NUMBER)
IS
BEGIN
  x_rem_amt.customer_trx_line_id(p_index) := 0;
  x_rem_amt.amount_due_remaining(p_index) := 0;
  x_rem_amt.acctd_amount_due_remaining(p_index) := 0;
  x_rem_amt.chrg_amount_remaining(p_index) := 0;
  x_rem_amt.chrg_acctd_amount_remaining(p_index) := 0;
END;
--}


END ARP_RECEIPTS_MAIN;

/
