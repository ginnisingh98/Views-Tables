--------------------------------------------------------
--  DDL for Package Body ARP_ADJUSTMENTS_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ADJUSTMENTS_MAIN" AS
/* $Header: ARTADJMB.pls 120.12.12010000.5 2009/07/10 11:03:49 mpsingh ship $ */

/* =======================================================================
 | Package Globals
 * ======================================================================*/
  g_mode			VARCHAR2(30);
  g_ae_doc_rec			ae_doc_rec_type;
  g_ae_event_rec		ae_event_rec_type;
  g_ae_line_tbl                 ae_line_tbl_type;
  g_empty_ae_line_tbl           ae_line_tbl_type;
  g_ae_sys_rec                  ae_sys_rec_type;
  g_ae_line_ctr                 BINARY_INTEGER ;

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

  PROCEDURE Derive_Accounting_Entry(p_from_llca_call      IN  VARCHAR2 DEFAULT 'N',
				    p_gt_id               IN  NUMBER   DEFAULT NULL
  );

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  PROCEDURE Delete_ADJ(p_ae_deleted   OUT NOCOPY BOOLEAN);

  PROCEDURE Reverse_Adjustment;

  PROCEDURE Get_Doc_Entitity_Data (
                p_level          IN  VARCHAR2                           ,
                p_adj_rec        OUT NOCOPY ar_adjustments%ROWTYPE             ,
                p_cust_inv_rec   OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_ctlgd_inv_rec  OUT NOCOPY ra_cust_trx_line_gl_dist%ROWTYPE   ,
                p_rule_rec       OUT NOCOPY ae_rule_rec_type                   ,
                p_ard_rec        OUT NOCOPY ar_distributions%ROWTYPE              );

-- Added parameter for Line Level Adjustment
  PROCEDURE Create_Ae_Lines_Common (
                p_level         IN VARCHAR2,
		p_from_llca_call      IN  VARCHAR2 DEFAULT 'N',
		p_gt_id               IN  NUMBER   DEFAULT NULL);
-- Added parameter for Line Level Adjustment
  PROCEDURE Create_Ae_Lines_ADJ(
                p_adj_rec        IN ar_adjustments%ROWTYPE             ,
                p_cust_inv_rec   IN ra_customer_trx%ROWTYPE            ,
                p_ctlgd_inv_rec  IN ra_cust_trx_line_gl_dist%ROWTYPE   ,
                p_rule_rec       IN ae_rule_rec_type                   ,
                p_ard_rec        IN ar_distributions%ROWTYPE           ,
		p_from_llca_call      IN  VARCHAR2 DEFAULT 'N'         ,
		p_gt_id               IN  NUMBER   DEFAULT NULL);

  PROCEDURE Assign_Ael_Elements(
                p_ae_line_rec           IN ae_line_rec_type );

  --{3377004
  FUNCTION ctl_id_index(p_ctl_id_tab  IN DBMS_SQL.NUMBER_TABLE,
                        p_ctl_id      IN NUMBER)
  RETURN NUMBER;

  PROCEDURE init_rem_amt(x_rem_amt IN OUT NOCOPY ctl_rem_amt_type,
                         p_index   IN NUMBER);
  --}

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
 |      deletes data associated with Adjustments based on event and source
 |      table.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_ae_deleted    OUT NOCOPY     AE Lines deletion status
 * ======================================================================*/
PROCEDURE Delete_Acct( p_mode         IN  VARCHAR2,
                       p_ae_doc_rec   IN  ae_doc_rec_type,
                       p_ae_event_rec IN  ae_event_rec_type,
                       p_ae_deleted   OUT NOCOPY BOOLEAN            ) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_ADJUSTMENTS_MAIN.Delete_Acct()+');
  END IF;

  /*----------------------------------------------------+
   | Copy Document/Event Data to Global                 |
   +----------------------------------------------------*/
  g_mode         := p_mode;
  g_ae_doc_rec   := p_ae_doc_rec;
  g_ae_event_rec := p_ae_event_rec;

  IF ( g_ae_doc_rec.source_table = 'ADJ' ) THEN

     Delete_ADJ(p_ae_deleted => p_ae_deleted) ;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_ADJUSTMENTS_MAIN.Delete_Acct()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ADJUSTMENTS_MAIN.Delete_Acct');
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
 | 	accounting events associated with the Adjustments layer.
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
		   p_from_llca_call      IN  VARCHAR2 DEFAULT 'N',
		   p_gt_id               IN  NUMBER   DEFAULT NULL) IS


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_ADJUSTMENTS_MAIN.Execute()+');
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
  Derive_Accounting_Entry( p_from_llca_call  => p_from_llca_call,
                            p_gt_id          => p_gt_id);

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
     arp_standard.debug(   'ARP_ADJUSTMENTS_MAIN.Execute()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ARP_ADJUSTMENTS_MAIN.Execute - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ADJUSTMENTS_MAIN.Execute');
     END IF;
     RAISE;

END Execute;


/* =======================================================================
 |
 | PROCEDURE Init_Ae_Lines
 |
 * ======================================================================*/
PROCEDURE Init_Ae_Lines IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_ADJUSTMENTS_MAIN.Init_Ae_Lines()+');
  END IF;

  g_ae_line_tbl := g_empty_ae_line_tbl;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_ADJUSTMENTS_MAIN.Init_Ae_Lines()-');
  END IF;
EXCEPTION

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ADJUSTMENTS_MAIN.Init_Ae_Lines');
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
PROCEDURE Derive_Accounting_Entry (p_from_llca_call      IN  VARCHAR2 DEFAULT 'N',
				   p_gt_id               IN  NUMBER   DEFAULT NULL
)
IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(  'ARP_ADJUSTMENTS_MAIN.Derive_Accounting_Entry()+');
  END IF;
  /*------------------------------------------------------------+
   | Create Accounting Entries at the Document Entity level.    |
   +------------------------------------------------------------*/
  IF ( g_ae_doc_rec.accounting_entity_level = 'ONE' ) THEN

     IF ((g_ae_doc_rec.source_id_old IS NOT NULL) and (g_ae_doc_rec.other_flag = 'REVERSE')) THEN
        Reverse_Adjustment;

     ELSIF ( g_ae_doc_rec.source_table = 'ADJ' ) THEN

       /*---------------------------------------------------------+
        | Create Accounting Entry Lines, Adjustments              |
        +---------------------------------------------------------*/
           Create_Ae_Lines_Common(p_level => 'ADJ',
			    p_from_llca_call => p_from_llca_call,
                            p_gt_id          => p_gt_id);

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
     arp_standard.debug(   'ARP_ADJUSTMENTS_MAIN.Derive_Accounting_Entry()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ADJUSTMENTS_MAIN.Derive_Accounting_Entry');
     END IF;
     RAISE;

END Derive_Accounting_Entry;

/* =======================================================================
 |
 | PROCEDURE Delete_ADJ
 |
 | DESCRIPTION
 |      Deletes accounting associated with a Adjustment id from the
 |      AR_DISTRIBUTIONS table.This routine deletes all records
 |      matching the input source_id. Note records from child table
 |      (AR_DISTRIBUTIONS) be deleted first.
 |
 | PARAMETERS
 |      p_ae_deleted       indicates whether records were deleted
 |                         for source_id
 * ======================================================================*/
PROCEDURE Delete_ADJ(p_ae_deleted   OUT NOCOPY BOOLEAN) IS

l_source_id ar_distributions.source_id%TYPE;

l_ar_dist_key_value_list   gl_ca_utility_pkg.r_key_value_arr;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Delete_ADJ()+');
    END IF;

 /*-------------------------------------------------------------------+
  | Verify that the source id is a valid candidate for deletion       |
  +-------------------------------------------------------------------*/
    SELECT adj.adjustment_id
    INTO   l_source_id
    FROM   ar_adjustments adj
    WHERE  adj.adjustment_id = g_ae_doc_rec.source_id
    AND    adj.posting_control_id = -3
    AND    g_ae_doc_rec.source_table = 'ADJ'
    AND EXISTS (SELECT 'x'
                FROM  ar_distributions ard
                WHERE ard.source_id = adj.adjustment_id
                AND   ard.source_table = 'ADJ');

 /*-------------------------------------------------------------------+
  | Delete all accounting for source id and source table combination  |
  | if valid candidate for deletion                                   |
  +-------------------------------------------------------------------*/

    -- modified for mrc trigger elimination.
    DELETE FROM AR_DISTRIBUTIONS
    WHERE  source_id    =  l_source_id
    AND    source_table = 'ADJ'
    RETURNING line_id
    BULK COLLECT INTO l_ar_dist_key_value_list;

    /*---------------------------------+
     | Calling central MRC library     |
     | for MRC Integration             |
     +---------------------------------*/
--{BUG#4301323
--     ar_mrc_engine.maintain_mrc_data(
--               p_event_mode        => 'DELETE',
--               p_table_name        => 'AR_DISTRIBUTIONS',
--               p_mode              => 'BATCH',
--               p_key_value_list    => l_ar_dist_key_value_list);
--}

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Delete_ADJ()-');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Delete_ADJ - NO_DATA_FOUND' );
     END IF;
     p_ae_deleted := FALSE;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ADJUSTMENTS_MAIN.Delete_ADJ');
     END IF;
     p_ae_deleted := FALSE;
     RAISE ;

END Delete_ADJ;

/* =======================================================================
 |
 | PROCEDURE Reverse_Adjustment
 |
 | DESCRIPTION
 |      This procedure reverses the records in AR_DISTRIBUTIONS for a
 |      Adjustment. It gets the accounting for the old adjustment and
 |      simply swaps the amount columns creating new accounting for the
 |      new adjustment id. Adjustment reversals occur for receivable trx id
 |      -13.
 |
 |      For Bills Receivable linked deferred tax for an application being
 |      reversed is also backed out NOCOPY by using a link id to reverse out NOCOPY the
 |      tax accounting associated with the Transaction history record for
 |      the maturity date event for a Bill. For this change a union was
 |      added and the source table is populated from g_ae_doc_rec
 |
 |      Reversals are opposite images of the old adjustment, with the exception
 |      that reconciliation entries are not reversed from the old adjustment,
 |      it is left to the Reconciliation routine to do this as an effect across
 |      all activity.
 |
 | PARAMETERS
 |      None
 * ======================================================================*/
PROCEDURE Reverse_Adjustment IS

-- MRC TRIGGER REPLACEMENT: Enumerate all columns and add two more unions
-- to retrieve MRC data

CURSOR get_old_ard  IS
       select ard.source_type,
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
              --{BUG#2979254
              ard.ref_customer_trx_line_id,
              ard.ref_cust_trx_line_gl_dist_id,
              ard.ref_line_id,
              --}
              --{3377004
              DECODE( ard.ref_customer_trx_line_id, NULL,'N',
                      DECODE(adj.type,'CHARGES','ADDCHRG','ADDCTL')) WHICH_BUCKET,
              --}
	      ard.ref_account_class,
	      ard.activity_bucket,
	      ard.ref_dist_ccid
       from   ar_distributions ard,
              ar_adjustments   adj
       where  g_ae_sys_rec.sob_type = 'P'
       and    ard.source_id = g_ae_doc_rec.source_id_old
       and    ard.source_table = g_ae_doc_rec.source_table
       and    nvl(ard.source_type_secondary,'X') NOT IN
                                  ('ASSIGNMENT_RECONCILE','RECONCILE')
       and    adj.adjustment_id(+) = g_ae_doc_rec.source_id_old  --3377004
       UNION
       select ard.source_type,
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
              --{BUG#2979254
              ard.ref_customer_trx_line_id,
              ard.ref_cust_trx_line_gl_dist_id,
              ard.ref_line_id,
              --}
              --{3377004
              DECODE( ard.ref_customer_trx_line_id, NULL,'N',
                      DECODE(adj.type,'CHARGES','ADDCHRG','ADDCTL')) WHICH_BUCKET,
              --}
	      ard.ref_account_class,
	      ard.activity_bucket,
	      ard.ref_dist_ccid
       from ar_distributions ard,
            ar_adjustments adj
       where g_ae_sys_rec.sob_type = 'P'
       and   adj.adjustment_id = g_ae_doc_rec.source_id_old
       and   ard.source_id = adj.link_to_trx_hist_id
       and   ard.source_table = 'TH' --for Bills Receivable Standard/Factored
       and   nvl(ard.source_type_secondary,'X') NOT IN
                                    ('ASSIGNMENT_RECONCILE','RECONCILE')
       and   nvl(g_ae_doc_rec.event,'NONE') <> 'RISK_UNELIMINATED'
       order  by 1 ;
--{BUG4301323
/*
       UNION
          select ard.source_type,
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
              --{BUG#2979254
              ard.ref_customer_trx_line_id,
              ard.ref_cust_trx_line_gl_dist_id,
              ard.ref_line_id,
              --}
              --{3377004
              DECODE( ard.ref_customer_trx_line_id, NULL,'N',
                      DECODE(adj.type,'CHARGES','ADDCHRG','ADDCTL')) WHICH_BUCKET
              --}
       from   ar_mc_distributions_all ard,
              ar_adjustments          adj
       where  g_ae_sys_rec.sob_type = 'R'
         and  ard.set_of_books_id = g_ae_sys_rec.set_of_books_id
         and  ard.source_id = g_ae_doc_rec.source_id_old
         and  ard.source_table = g_ae_doc_rec.source_table
         and  nvl(ard.source_type_secondary,'X') NOT IN
                                  ('ASSIGNMENT_RECONCILE','RECONCILE')
         and  adj.adjustment_id(+)  = g_ae_doc_rec.source_id_old  --3377004
         UNION
         select ard.source_type,
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
              --{BUG#2979254
              ard.ref_customer_trx_line_id,
              ard.ref_cust_trx_line_gl_dist_id,
              ard.ref_line_id,
              --}
              --{3377004
              DECODE( ard.ref_customer_trx_line_id, NULL,'N',
                      DECODE(adj.type,'CHARGES','ADDCHRG','ADDCTL')) WHICH_BUCKET
              --}
       from ar_mc_distributions_all ard,
            ar_adjustments adj
       where g_ae_sys_rec.sob_type = 'R'
       and   g_ae_sys_rec.set_of_books_id = ard.set_of_books_id
       and   adj.adjustment_id = g_ae_doc_rec.source_id_old
       and   ard.source_id = adj.link_to_trx_hist_id
       and   ard.source_table = 'TH' --for Bills Receivable Standard/Factored
       and   nvl(ard.source_type_secondary,'X') NOT IN
                                    ('ASSIGNMENT_RECONCILE','RECONCILE')
       and   nvl(g_ae_doc_rec.event,'NONE') <> 'RISK_UNELIMINATED'
       order  by 1 ;
*/
-- MRC Trigger Replacement: modified cursor to extact information.

CURSOR get_adj_details IS
SELECT adj.customer_trx_id                         customer_trx_id,
       adj.amount                                  amount,
--{BUG4301323
--       DECODE(g_ae_sys_rec.sob_type, 'P',
--              adj.acctd_amount,
--              arp_mrc_acct_main.get_adj_entity_data(
--                  adj.adjustment_id,
--                  g_ae_sys_rec.set_of_books_id))   acctd_amount,
         adj.acctd_amount                         acctd_amount,
--}
       ctinv.invoice_currency_code                 invoice_currency_code   ,
--{BUG4301323
--       DECODE(g_ae_sys_rec.sob_type, 'P',
--              ctinv.exchange_rate,
--              arp_mrc_acct_main.get_ctx_exg_rate(
--                   ctinv.customer_trx_id,
--                   g_ae_sys_rec.set_of_books_id))  exchange_rate,
       ctinv.exchange_rate                          exchange_rate,
--}
--{BUG4301323
--       DECODE(g_ae_sys_rec.sob_type, 'P',
--              ctinv.exchange_rate_type,
--              arp_mrc_acct_main.get_ctx_exg_rate_type(
--                    ctinv.customer_trx_id,
--                   g_ae_sys_rec.set_of_books_id))  exchange_rate_type,
       ctinv.exchange_rate_type                     exchange_rate_type,
--}
--{BUG4301323
--       DECODE(g_ae_sys_rec.sob_type, 'P',
--              ctinv.exchange_date,
--              arp_mrc_acct_main.get_ctx_exg_date(
--                    ctinv.customer_trx_id,
--                   g_ae_sys_rec.set_of_books_id))  exchange_date,
       ctinv.exchange_date                         exchange_date,
--}
       ctinv.trx_date                              trx_date,
       ctinv.bill_to_customer_id                   bill_to_customer_id,
       ctinv.bill_to_site_use_id                   bill_to_site_use_id,
       ctinv.drawee_id                             drawee_id,
       ctinv.drawee_site_use_id                    drawee_site_use_id
       from ar_adjustments   adj,
            ra_customer_trx  ctinv
       where adj.adjustment_id = g_ae_doc_rec.source_id_old
       and   adj.status = 'A'
       and   g_ae_doc_rec.source_table = 'ADJ'
       and   adj.customer_trx_id = ctinv.customer_trx_id;

l_ael_line_rec          ae_line_rec_type;
l_ael_empty_line_rec    ae_line_rec_type;
i                       BINARY_INTEGER := 1;
l_cust_inv_rec          ra_customer_trx%ROWTYPE;
l_customer_trx_id       NUMBER;
l_amount                NUMBER;
l_acctd_amount          NUMBER;
--{3377004
l_ctl_rem_amt               ctl_rem_amt_type;
l_index                     NUMBER := 0;
--}

BEGIN

  arp_standard.debug( 'ARP_ADJUSTMENTS_MAIN.Reverse_Adjustments()+');

--Reverse all adjustment accounting
    FOR l_ard_rec in get_old_ard LOOP

     --Initialize build record source id secondary and table is null for Adjustments
       l_ael_line_rec := l_ael_empty_line_rec ;

       l_ael_line_rec.ae_line_type               := l_ard_rec.source_type            ;
       l_ael_line_rec.ae_line_type_secondary     := l_ard_rec.source_type_secondary  ;
       l_ael_line_rec.source_id                  := g_ae_doc_rec.source_id           ;
       l_ael_line_rec.source_table               := g_ae_doc_rec.source_table        ;
       l_ael_line_rec.source_table_secondary     := l_ard_rec.source_table_secondary ;
       l_ael_line_rec.source_id_secondary        := l_ard_rec.source_id_secondary    ;
       l_ael_line_rec.account                    := l_ard_rec.code_combination_id    ;

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
       l_ael_line_rec.reversed_source_id          := '';
       l_ael_line_rec.tax_group_code_id           := l_ard_rec.tax_group_code_id;
       l_ael_line_rec.tax_code_id                 := l_ard_rec.tax_code_id;
       l_ael_line_rec.location_segment_id         := l_ard_rec.location_segment_id;
       l_ael_line_rec.tax_link_id                 := l_ard_rec.tax_link_id;
       --{BUG#2979254
       l_ael_line_rec.ref_customer_trx_line_id    := l_ard_rec.ref_customer_trx_line_id;
       l_ael_line_rec.ref_cust_trx_line_gl_dist_id := l_ard_rec.ref_cust_trx_line_gl_dist_id;
       l_ael_line_rec.ref_line_id                 := l_ard_rec.ref_line_id;
       --}
       l_ael_line_rec.ref_account_class		  := l_ard_rec.ref_account_class;
       l_ael_line_rec.activity_bucket		  := l_ard_rec.activity_bucket;
       l_ael_line_rec.ref_dist_ccid		  := l_ard_rec.ref_dist_ccid;
    -- Assign AEL for Reversal
      Assign_Ael_Elements( p_ae_line_rec        => l_ael_line_rec );


      --{3377004
      arp_standard.debug(' l_ard_rec.WHICH_BUCKET:'||l_ard_rec.WHICH_BUCKET);
      arp_standard.debug(' l_ard_rec.ref_customer_trx_line_id:'||l_ard_rec.ref_customer_trx_line_id);
      arp_standard.debug(' l_ard_rec.ref_line_id:'||l_ard_rec.ref_line_id);
      IF    l_ard_rec.WHICH_BUCKET = 'N' THEN
         NULL;
      ELSIF l_ard_rec.WHICH_BUCKET = 'ADDCTL' THEN

        l_index := ctl_id_index(l_ctl_rem_amt.customer_trx_line_id,
                                l_ard_rec.ref_customer_trx_line_id);

        IF NOT l_ctl_rem_amt.amount_due_remaining.EXISTS(l_index) THEN
          init_rem_amt(x_rem_amt => l_ctl_rem_amt,
                       p_index   => l_index);
        END IF;

        l_ctl_rem_amt.customer_trx_line_id(l_index) := l_ard_rec.ref_customer_trx_line_id;

        -- Bug 8626971
	l_ctl_rem_amt.amount_due_remaining(l_index) :=
                 NVL(l_ctl_rem_amt.amount_due_remaining(l_index),0)
           --   + (NVL(l_ard_rec.amount_cr,0) - NVL(l_ard_rec.amount_dr,0));
	        + (NVL(l_ael_line_rec.entered_cr,0) - NVL(l_ael_line_rec.entered_dr,0));

        l_ctl_rem_amt.acctd_amount_due_remaining(l_index) :=
               NVL(l_ctl_rem_amt.acctd_amount_due_remaining(l_index),0)
          --  + (NVL(l_ard_rec.acctd_amount_cr,0) - NVL(l_ard_rec.acctd_amount_dr,0));
              + (NVL(l_ael_line_rec.accounted_cr,0) - NVL(l_ael_line_rec.accounted_dr,0));

        arp_standard.debug('l_ctl_rem_amt.customer_trx_line_id('||l_index||'):'||
                               l_ctl_rem_amt.customer_trx_line_id(l_index));
        arp_standard.debug('l_ctl_rem_amt.amount_due_remaining('||l_index||'):'||
                               l_ctl_rem_amt.amount_due_remaining(l_index));
        arp_standard.debug('l_ctl_rem_amt.acctd_amount_due_remaining('||l_index||'):'||
                               l_ctl_rem_amt.acctd_amount_due_remaining(l_index));

      ELSIF l_ard_rec.WHICH_BUCKET = 'ADDCHRG' THEN

        l_index := ctl_id_index(l_ctl_rem_amt.customer_trx_line_id,
                                l_ard_rec.ref_customer_trx_line_id);

        IF NOT l_ctl_rem_amt.chrg_amount_remaining.EXISTS(l_index) THEN
          init_rem_amt(x_rem_amt => l_ctl_rem_amt,
                       p_index   => l_index);
        END IF;

        l_ctl_rem_amt.customer_trx_line_id(l_index) := l_ard_rec.ref_customer_trx_line_id;

        l_ctl_rem_amt.chrg_amount_remaining(l_index) :=
                NVL(l_ctl_rem_amt.chrg_amount_remaining(l_index),0)
             + (NVL(l_ard_rec.amount_cr,0) - NVL(l_ard_rec.amount_dr,0));

        l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index) :=
              NVL(l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index),0)
           + (NVL(l_ard_rec.acctd_amount_cr,0) - NVL(l_ard_rec.acctd_amount_dr,0));

        arp_standard.debug('l_ctl_rem_amt.customer_trx_line_id('||l_index||'):'||
                               l_ctl_rem_amt.customer_trx_line_id(l_index));
        arp_standard.debug('l_ctl_rem_amt.chrg_amount_remaining('||l_index||'):'||
                               l_ctl_rem_amt.chrg_amount_remaining(l_index));
        arp_standard.debug('l_ctl_rem_amt.chrg_acctd_amount_remaining('||l_index||'):'||
                               l_ctl_rem_amt.chrg_acctd_amount_remaining(l_index));

      END IF;
    --}
    END LOOP;

    --{3377004
    IF l_index <> 0 THEN
      FORALL m IN l_ctl_rem_amt.customer_trx_line_id.FIRST .. l_ctl_rem_amt.customer_trx_line_id.LAST
      UPDATE ra_customer_trx_lines
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
  |reconciliation entries for the Bill or the Transactions. The reversal of the       |
  |adjustment accounting must take place to call the Reversal Routine. When called    |
  |this routine will always attempt do a reversal, first reverse accounting then call |
  |the reconciliation routine. Note the reversal of Reconciliation entries is left to |
  |The Reconciliation routine below i.e. we do not reverse them in the above cursor.  |
  +-----------------------------------------------------------------------------------*/
    arp_standard.debug('Before call to Reconciliation routine');

    FOR l_get_adj in get_adj_details LOOP --loop executes once only for adjustment

       /*-------------------------------------------------------------------------------+
        | Set currency and exchange rate details to that of the document which has been |
        | adjusted. These details will get overriden by the transaction line assignment |
        | exchange rate details for Bill.                                               |
        +-------------------------------------------------------------------------------*/
         l_cust_inv_rec.invoice_currency_code := l_get_adj.invoice_currency_code;
         l_cust_inv_rec.exchange_rate         := l_get_adj.exchange_rate;
         l_cust_inv_rec.exchange_rate_type    := l_get_adj.exchange_rate_type;
         l_cust_inv_rec.exchange_date         := l_get_adj.exchange_date;
         l_cust_inv_rec.trx_date              := l_get_adj.trx_date;
         l_cust_inv_rec.bill_to_customer_id   := l_get_adj.bill_to_customer_id;
         l_cust_inv_rec.bill_to_site_use_id   := l_get_adj.bill_to_site_use_id;
         l_cust_inv_rec.drawee_id             := l_get_adj.drawee_id;
         l_cust_inv_rec.drawee_site_use_id    := l_get_adj.drawee_site_use_id;

       --Required to determine whether the payment schedule is closed or not
       --emulate sign of Receipt application
         l_customer_trx_id           := l_get_adj.customer_trx_id      ;
         l_amount                    := l_get_adj.amount               ;
         l_acctd_amount              := l_get_adj.acctd_amount         ;

         ARP_RECONCILE.Reconcile_trx_br(
           p_mode                     => g_mode                             ,
           p_ae_doc_rec               => g_ae_doc_rec                       ,
           p_ae_event_rec             => g_ae_event_rec                     ,
           p_cust_inv_rec             => l_cust_inv_rec                     ,
           p_activity_cust_trx_id     => l_customer_trx_id                  ,
           p_activity_amt             => l_amount                           ,
           p_activity_acctd_amt       => l_acctd_amount                     ,
           p_call_num                 => 1                                  ,
           p_g_ae_line_tbl            => g_ae_line_tbl                      ,
           p_g_ae_ctr                 => g_ae_line_ctr                        );

        END LOOP; --get adjustment details

  arp_standard.debug( 'ARP_ADJUSTMENTS_MAIN.Reverse_Adjustments()-');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Reverse_Adjustments - NO_DATA_FOUND' );
     RAISE;

  WHEN OTHERS THEN
     arp_standard.debug('EXCEPTION: ARP_ADJUSTMENTS_MAIN.Reverse_Adjustments');
     RAISE ;

END Reverse_Adjustment;


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
 |      p_adj_rec        Adjustment Record
 |      p_cust_inv_rec   Invoice document or On Account Credit Memo data
 |      p_ctlgd_inv_rec  Receivable account for Adjustment
 |      p_rule_rec       Rule record
 |      p_ard_rec        Distributions record used by Bills Receivable
 * ======================================================================*/
PROCEDURE Get_Doc_Entitity_Data (
                p_level          IN VARCHAR2                            ,
                p_adj_rec        OUT NOCOPY ar_adjustments%ROWTYPE             ,
                p_cust_inv_rec   OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_ctlgd_inv_rec  OUT NOCOPY ra_cust_trx_line_gl_dist%ROWTYPE   ,
                p_rule_rec       OUT NOCOPY ae_rule_rec_type                   ,
                p_ard_rec        OUT NOCOPY ar_distributions%ROWTYPE               ) IS

  l_tax_rate_id NUMBER;
  l_le_id           NUMBER;
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(1024);
  l_effective_date  DATE;
  l_return_status   VARCHAR2(10);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Get_Doc_Entitity_Data()+');
   END IF;

   IF p_level = 'ADJ' then

      /* receivables activities can now be set up for either org
         or legal entity.  When set up by legal entity, there is a
         new child table that carries the asset_tax_code for each
         activity/LE pair. */

      IF arp_legal_entity_util.is_le_subscriber
      THEN
         /* LE setup is enabled */
         /* 5236782 - but ar_rec_trx_le_details not required for adj */
      select adj.adjustment_id                               ,
             adj.customer_trx_id                             ,
             adj.customer_trx_line_id                        ,
             adj.payment_schedule_id                         ,
             adj.receivables_trx_id                          ,
             adj.code_combination_id                         ,
             adj.apply_date                                  ,
             adj.gl_date                                     ,
             adj.type                                        ,
             adj.status                                      ,
             adj.amount                                      ,
             adj.acctd_amount                                ,
             adj.line_adjusted                               ,
             adj.freight_adjusted                            ,
             adj.tax_adjusted                                ,
             adj.receivables_charges_adjusted                ,
             ctinv.invoice_currency_code                     ,
             ctinv.exchange_rate           exchange_rate,
             ctinv.exchange_rate_type      exchange_rate_type,
             ctinv.exchange_date             exchange_date,
             ctinv.bill_to_customer_id                       ,
             ctinv.bill_to_site_use_id                       ,
             ctinv.drawee_id                                 ,
             ctinv.drawee_site_use_id                        ,
	     ctinv.upgrade_method                            ,
             ctlgdinv.code_combination_id                    ,
             decode(g_ae_doc_rec.other_flag,
                    'CBREVERSAL', 'ACTIVITY_GL_ACCOUNT',        --trx id -12
                    'CHARGEBACK', 'ACTIVITY_GL_ACCOUNT',        --trx id -11
                    'COMMITMENT', 'ACTIVITY_GL_ACCOUNT',        --trx od -1
                    nvl(rt.gl_account_source, 'NO_SOURCE'))  ,
             decode(g_ae_doc_rec.other_flag,
                    'CBREVERSAL', 'NONE',                      --trx id -12
                    'CHARGEBACK', 'NONE',                      --trx id -11
                    'COMMITMENT', 'NONE',                      --trx id -1
                    nvl(rt.tax_code_source  , 'NO_SOURCE'))  ,
             decode(g_ae_doc_rec.other_flag,
                    'CBREVERSAL', '',
                    'CHARGEBACK', '',
                    'COMMITMENT', '',
                    rt.tax_recoverable_flag)                 ,
             decode(g_ae_doc_rec.other_flag,
                  'CBREVERSAL',g_ae_doc_rec.source_id_old, --chargeback reversal
                  'CHARGEBACK',g_ae_doc_rec.source_id_old, --chargeback
                  'COMMITMENT',g_ae_doc_rec.source_id_old, --commitments
                  'OVERRIDE'  ,g_ae_doc_rec.source_id_old, --when user specifies account
                    rt.code_combination_id)                  ,  --in adjustment form
             nvl(rtd.asset_tax_code, rt.asset_tax_code)      ,
             nvl(rtd.liability_tax_code, rt.liability_tax_code),
             ''                                              ,
             ''                                              ,
             'NO_SOURCE'                                     ,
             'NO_SOURCE'                                     ,
             ''                                              ,
             ''                                              ,
             ''                                              ,
             ''                                              ,
             ''                                              ,
             ''
      into   p_adj_rec.adjustment_id                       ,
             p_adj_rec.customer_trx_id                     ,
             p_adj_rec.customer_trx_line_id                ,
             p_adj_rec.payment_schedule_id                 ,
             p_adj_rec.receivables_trx_id                  ,
             p_adj_rec.code_combination_id                 ,
             p_adj_rec.apply_date                          ,
             p_adj_rec.gl_date                             ,
             p_adj_rec.type                                ,
             p_adj_rec.status                              ,
             p_adj_rec.amount                              ,
             p_adj_rec.acctd_amount                        ,
             p_adj_rec.line_adjusted                       ,
             p_adj_rec.freight_adjusted                    ,
             p_adj_rec.tax_adjusted                        ,
             p_adj_rec.receivables_charges_adjusted        ,
             p_cust_inv_rec.invoice_currency_code          ,
             p_cust_inv_rec.exchange_rate                  ,
             p_cust_inv_rec.exchange_rate_type             ,
             p_cust_inv_rec.exchange_date                  ,
             p_cust_inv_rec.bill_to_customer_id            ,
             p_cust_inv_rec.bill_to_site_use_id            ,
             p_cust_inv_rec.drawee_id                      ,
             p_cust_inv_rec.drawee_site_use_id             ,
	     p_cust_inv_rec.upgrade_method                 ,
             p_ctlgd_inv_rec.code_combination_id           ,
             p_rule_rec.gl_account_source1                 ,
             p_rule_rec.tax_code_source1                   ,
             p_rule_rec.tax_recoverable_flag1              ,
             p_rule_rec.code_combination_id1               ,
             p_rule_rec.asset_tax_code1                    ,
             p_rule_rec.liability_tax_code1                ,
             p_rule_rec.act_tax_non_rec_ccid1              ,
             p_rule_rec.act_vat_tax_id1                    ,
             p_rule_rec.gl_account_source2                 ,
             p_rule_rec.tax_code_source2                   ,
             p_rule_rec.tax_recoverable_flag2              ,
             p_rule_rec.code_combination_id2               ,
             p_rule_rec.asset_tax_code2                    ,
             p_rule_rec.liability_tax_code2                ,
             p_rule_rec.act_tax_non_rec_ccid2              ,
             p_rule_rec.act_vat_tax_id2
      from ar_adjustments             adj     ,
           ar_receivables_trx         rt      ,
           ar_rec_trx_le_details      rtd     ,
           ra_customer_trx            ctinv   ,
           ra_cust_trx_line_gl_dist   ctlgdinv
      where adj.adjustment_id = g_ae_doc_rec.source_id
      and   adj.status = 'A'                        --only approved adjustments
      and   adj.receivables_trx_id = rt.receivables_trx_id
      and   rtd.receivables_trx_id (+) = rt.receivables_trx_id
      and   nvl(rtd.legal_entity_id, ctinv.legal_entity_id)
                   = ctinv.legal_entity_id
      and   adj.customer_trx_id = ctinv.customer_trx_id  --INV REC exchange rate Information
      and   adj.customer_trx_id = ctlgdinv.customer_trx_id (+) --REC account ccid
      and   'REC' = ctlgdinv.account_class (+)
      and   'Y' = ctlgdinv.latest_rec_flag (+) ;

      ELSE
         /* Setup is by OU, don't need child table */

      select adj.adjustment_id                               ,
             adj.customer_trx_id                             ,
             adj.customer_trx_line_id                        ,
             adj.payment_schedule_id                         ,
             adj.receivables_trx_id                          ,
             adj.code_combination_id                         ,
             adj.apply_date                                  ,
             adj.gl_date                                     ,
             adj.type                                        ,
             adj.status                                      ,
             adj.amount                                      ,
             adj.acctd_amount                                ,
             adj.line_adjusted                               ,
             adj.freight_adjusted                            ,
             adj.tax_adjusted                                ,
             adj.receivables_charges_adjusted                ,
             ctinv.invoice_currency_code                     ,
             ctinv.exchange_rate           exchange_rate,
             ctinv.exchange_rate_type      exchange_rate_type,
             ctinv.exchange_date             exchange_date,
             ctinv.bill_to_customer_id                       ,
             ctinv.bill_to_site_use_id                       ,
             ctinv.drawee_id                                 ,
             ctinv.drawee_site_use_id                        ,
	     ctinv.upgrade_method                            ,
             ctlgdinv.code_combination_id                    ,
             decode(g_ae_doc_rec.other_flag,
                    'CBREVERSAL', 'ACTIVITY_GL_ACCOUNT',        --trx id -12
                    'CHARGEBACK', 'ACTIVITY_GL_ACCOUNT',        --trx id -11
                    'COMMITMENT', 'ACTIVITY_GL_ACCOUNT',        --trx od -1
                    nvl(rt.gl_account_source, 'NO_SOURCE'))  ,
             decode(g_ae_doc_rec.other_flag,
                    'CBREVERSAL', 'NONE',                      --trx id -12
                    'CHARGEBACK', 'NONE',                      --trx id -11
                    'COMMITMENT', 'NONE',                      --trx id -1
                    nvl(rt.tax_code_source  , 'NO_SOURCE'))  ,
             decode(g_ae_doc_rec.other_flag,
                    'CBREVERSAL', '',
                    'CHARGEBACK', '',
                    'COMMITMENT', '',
                    rt.tax_recoverable_flag)                 ,
             decode(g_ae_doc_rec.other_flag,
                  'CBREVERSAL',g_ae_doc_rec.source_id_old, --chargeback reversal
                  'CHARGEBACK',g_ae_doc_rec.source_id_old, --chargeback
                  'COMMITMENT',g_ae_doc_rec.source_id_old, --commitments
                  'OVERRIDE'  ,g_ae_doc_rec.source_id_old, --when user specifies account
                    rt.code_combination_id)                  ,  --in adjustment form
             rt.asset_tax_code                               ,
             rt.liability_tax_code                           ,
             ''                                              ,
             ''                                              ,
             'NO_SOURCE'                                     ,
             'NO_SOURCE'                                     ,
             ''                                              ,
             ''                                              ,
             ''                                              ,
             ''                                              ,
             ''                                              ,
             ''
      into   p_adj_rec.adjustment_id                       ,
             p_adj_rec.customer_trx_id                     ,
             p_adj_rec.customer_trx_line_id                ,
             p_adj_rec.payment_schedule_id                 ,
             p_adj_rec.receivables_trx_id                  ,
             p_adj_rec.code_combination_id                 ,
             p_adj_rec.apply_date                          ,
             p_adj_rec.gl_date                             ,
             p_adj_rec.type                                ,
             p_adj_rec.status                              ,
             p_adj_rec.amount                              ,
             p_adj_rec.acctd_amount                        ,
             p_adj_rec.line_adjusted                       ,
             p_adj_rec.freight_adjusted                    ,
             p_adj_rec.tax_adjusted                        ,
             p_adj_rec.receivables_charges_adjusted        ,
             p_cust_inv_rec.invoice_currency_code          ,
             p_cust_inv_rec.exchange_rate                  ,
             p_cust_inv_rec.exchange_rate_type             ,
             p_cust_inv_rec.exchange_date                  ,
             p_cust_inv_rec.bill_to_customer_id            ,
             p_cust_inv_rec.bill_to_site_use_id            ,
             p_cust_inv_rec.drawee_id                      ,
             p_cust_inv_rec.drawee_site_use_id             ,
	     p_cust_inv_rec.upgrade_method                 ,
             p_ctlgd_inv_rec.code_combination_id           ,
             p_rule_rec.gl_account_source1                 ,
             p_rule_rec.tax_code_source1                   ,
             p_rule_rec.tax_recoverable_flag1              ,
             p_rule_rec.code_combination_id1               ,
             p_rule_rec.asset_tax_code1                    ,
             p_rule_rec.liability_tax_code1                ,
             p_rule_rec.act_tax_non_rec_ccid1              ,
             p_rule_rec.act_vat_tax_id1                    ,
             p_rule_rec.gl_account_source2                 ,
             p_rule_rec.tax_code_source2                   ,
             p_rule_rec.tax_recoverable_flag2              ,
             p_rule_rec.code_combination_id2               ,
             p_rule_rec.asset_tax_code2                    ,
             p_rule_rec.liability_tax_code2                ,
             p_rule_rec.act_tax_non_rec_ccid2              ,
             p_rule_rec.act_vat_tax_id2
      from ar_adjustments             adj     ,
           ar_receivables_trx         rt      ,
           ra_customer_trx            ctinv   ,
           ra_cust_trx_line_gl_dist   ctlgdinv
      where adj.adjustment_id = g_ae_doc_rec.source_id
      and   adj.status = 'A'                        --only approved adjustments
      and   adj.receivables_trx_id = rt.receivables_trx_id
      and   adj.customer_trx_id = ctinv.customer_trx_id  --INV REC exchange rate Information
      and   adj.customer_trx_id = ctlgdinv.customer_trx_id (+) --REC account ccid
      and   'REC' = ctlgdinv.account_class (+)
      and   'Y' = ctlgdinv.latest_rec_flag (+) ;

      END IF;

  /*----------------------------------------------------------+
   | Process for endorsements for Bills Receivable, get the   |
   | Receivable account to offset the Write off account,      |
   | based on the sign of the payment schedule, the Unpaid    |
   | Bills receivable, or Bills Receivable account is selected|
   +----------------------------------------------------------*/
      IF (p_cust_inv_rec.drawee_site_use_id IS NOT null) THEN

         -- MRC Trigger Replacment.  Enumerated columns.  Branched based
         -- on primary or  Reporting.
          IF ( g_ae_sys_rec.sob_type = 'P') THEN
            select ard.line_id,
              ard.source_id,
              ard.source_table,
              ard.source_type,
              ard.code_combination_id,
              ard.amount_dr,
              ard.amount_cr,
              ard.acctd_amount_dr,
              ard.acctd_amount_cr,
              ard.creation_date,
              ard.created_by,
              ard.last_updated_by,
              ard.last_update_date,
              ard.last_update_login,
              ard.org_id,
              ard.source_table_secondary,
              ard.source_id_secondary,
              ard.currency_code,
              ard.currency_conversion_rate,
              ard.currency_conversion_type,
              ard.currency_conversion_date,
              ard.taxable_entered_dr,
              ard.taxable_entered_cr,
              ard.taxable_accounted_dr,
              ard.taxable_accounted_cr,
              ard.tax_link_id,
              ard.third_party_id,
              ard.third_party_sub_id,
              ard.reversed_source_id,
              ard.tax_code_id,
              ard.location_segment_id,
              ard.source_type_secondary,
              ard.tax_group_code_id,
              --{BUG#2979254
              ard.ref_customer_trx_line_id,
              ard.ref_cust_trx_line_gl_dist_id,
              ard.ref_line_id
              --}
         INTO p_ard_rec.line_id,
              p_ard_rec.source_id,
              p_ard_rec.source_table,
              p_ard_rec.source_type,
              p_ard_rec.code_combination_id,
              p_ard_rec.amount_dr,
              p_ard_rec.amount_cr,
              p_ard_rec.acctd_amount_dr,
              p_ard_rec.acctd_amount_cr,
              p_ard_rec.creation_date,
              p_ard_rec.created_by,
              p_ard_rec.last_updated_by,
              p_ard_rec.last_update_date,
              p_ard_rec.last_update_login,
              p_ard_rec.org_id,
              p_ard_rec.source_table_secondary,
              p_ard_rec.source_id_secondary,
              p_ard_rec.currency_code,
              p_ard_rec.currency_conversion_rate,
              p_ard_rec.currency_conversion_type,
              p_ard_rec.currency_conversion_date,
              p_ard_rec.taxable_entered_dr,
              p_ard_rec.taxable_entered_cr,
              p_ard_rec.taxable_accounted_dr,
              p_ard_rec.taxable_accounted_cr,
              p_ard_rec.tax_link_id,
              p_ard_rec.third_party_id,
              p_ard_rec.third_party_sub_id,
              p_ard_rec.reversed_source_id,
              p_ard_rec.tax_code_id,
              p_ard_rec.location_segment_id,
              p_ard_rec.source_type_secondary,
              p_ard_rec.tax_group_code_id,
              --{BUG#2979254
              p_ard_rec.ref_customer_trx_line_id,
              p_ard_rec.ref_cust_trx_line_gl_dist_id,
              p_ard_rec.ref_line_id
              --}
            from   ar_transaction_history th,
                   ar_payment_schedules pay,
                   ar_distributions ard
           where
                 th.transaction_history_id =
                     (select max(th1.transaction_history_id)
                        from ar_transaction_history th1
                       where nvl(th1.POSTABLE_FLAG, 'N') = 'Y'
                         and   th1.status IN ('UNPAID', 'PENDING_REMITTANCE')
                         and   th1.customer_trx_id = p_adj_rec.customer_trx_id)
             and   th.customer_trx_id = pay.customer_trx_id
             and   ard.source_id = th.transaction_history_id
             and   ard.source_table = 'TH'
             and   (((sign(pay.amount_due_original) > 0)
                      and ((nvl(ard.AMOUNT_DR,0) <> 0) OR
                           (nvl(ard.ACCTD_AMOUNT_DR,0) <> 0))
                      and (nvl(ard.AMOUNT_CR,0) = 0) and
                          (nvl(ard.ACCTD_AMOUNT_CR,0) = 0))
                    OR ((sign(pay.amount_due_original) < 0)
                         and ((nvl(ard.AMOUNT_CR,0) <> 0) OR
                              (nvl(ard.ACCTD_AMOUNT_CR,0) <> 0))
                         and (nvl(ard.AMOUNT_DR,0) = 0) and
                              (nvl(ard.ACCTD_AMOUNT_DR,0) = 0)));
         END IF;

         p_ctlgd_inv_rec.code_combination_id := p_ard_rec.code_combination_id;

      END IF;

  /*--------------------------------------------------------+
   | Get non recoverable tax account for asset or liability |
   | tax code for finance charges                           |
   +--------------------------------------------------------*/
      IF (p_rule_rec.tax_code_source1 = 'ACTIVITY')
            AND (p_rule_rec.asset_tax_code1 IS NOT NULL)
      THEN

        /* Initialize zx */
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
           p_transaction_date => p_adj_rec.apply_date,
           p_related_doc_date => NULL,
           p_adjusted_doc_date=> NULL,
           x_effective_date   => l_effective_date);

        BEGIN
           /* Get tax_rate_id from zx_rates based on tax_rate_code (asset_tax_code)
              and then call function to get underlying accounts */
         SELECT tax_rate_id
         INTO   l_tax_rate_id
         FROM   zx_sco_rates
         WHERE  tax_rate_code = p_rule_rec.asset_tax_code1
         AND    p_adj_rec.apply_date BETWEEN
                   NVL(effective_from, p_adj_rec.apply_date) AND
                   NVL(effective_to, p_adj_rec.apply_date);

         p_rule_rec.act_tax_non_rec_ccid1 :=
              arp_etax_util.get_tax_account(l_tax_rate_id,
                                            p_adj_rec.apply_date,
                                            'ADJ_NON_REC',
                                            'TAX_RATE');

         p_rule_rec.act_vat_tax_id1 :=
              arp_etax_util.get_tax_account(l_tax_rate_id,
                                            p_adj_rec.apply_date,
                                            'FINCHRG_NON_REC',
                                            'TAX_RATE');

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Get_Doc_Entitity_Data - ' ||
                                     'ACT_TAX_NON_REC_CCID - '|| 'NO_DATA_FOUND' );
             END IF;
             NULL;

          WHEN OTHERS THEN
             IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug('EXCEPTION: ARP_ADJUSTMENTS_MAIN.'||
                                     'Get_Doc_Entitity_Data - ACT_TAX_NON_REC_CCID ');
             END IF;
             RAISE ;
        END;

       END IF; --end if tax code source is activity

   END IF; --end if p_level = ADJ

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Get_Doc_Entitity_Data()-');
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_ADJUSTMENTS_MAIN.Get_Doc_Entitity_Data - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ADJUSTMENTS_MAIN.Get_Doc_Entitity_Data');
     END IF;
     RAISE ;

END Get_Doc_Entitity_Data;

/* =======================================================================
 | PROCEDURE Create_Ae_Lines_Common
 |
 | DESCRIPTION
 |      This procedure creates the AE lines at each entity level. Used
 |      for creating lines as part of Adjustment creation.
 |
 |      Functions:
 |      	- Create AE lines.
 |      	- Get additional data to determine the type of AE lines
 |
 | PARAMETERS
 |      p_level       Entity level from which the procedure was called
 * ======================================================================*/
PROCEDURE Create_Ae_Lines_Common (
		p_level 	      IN VARCHAR2,
		p_from_llca_call      IN  VARCHAR2 DEFAULT 'N',
		p_gt_id               IN  NUMBER   DEFAULT NULL) IS

  l_adj_rec		ar_adjustments%ROWTYPE ;
  l_cust_inv_rec        ra_customer_trx%ROWTYPE            ;
  l_ctlgd_inv_rec       ra_cust_trx_line_gl_dist%ROWTYPE   ;
  l_rule_rec            ae_rule_rec_type                   ;
  l_ard_rec             ar_distributions%ROWTYPE           ;
  l_tmp_upg_method      ra_customer_trx.upgrade_method%TYPE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_ADJUSTMENTS_MAIN.Create_Ae_Lines_Common()+');
   END IF;

   /*-------------------------------------------------------------+
    | Get Document Entitity specific data                         |
    +-------------------------------------------------------------*/

     Get_Doc_Entitity_Data(p_level          => p_level         ,
                           p_adj_rec        => l_adj_rec       ,
                           p_cust_inv_rec   => l_cust_inv_rec  ,
                           p_ctlgd_inv_rec  => l_ctlgd_inv_rec ,
                           p_rule_rec       => l_rule_rec      ,
                           p_ard_rec        => l_ard_rec         );

    /**If Detailed distributions is disabled for the current operating unit then
       we will stamp the invoice with upgrade_method as R12_MERGE*/
    ARP_DET_DIST_PKG.verify_stamp_merge_dist_method
	  ( l_adj_rec.customer_trx_id,
	    l_tmp_upg_method );

    /**Above proc call will update the invoice header record to database.As l_cust_inv_rec
       is fetched from db prior to the update,manually setting it with new value */
    IF nvl(l_tmp_upg_method,'R12_NLB') = 'R12_MERGE'  THEN
      l_cust_inv_rec.upgrade_method := l_tmp_upg_method;
    END IF;

  /*------------------------------------------------------+
   | Create AE Lines for Adjustment                       |
   +------------------------------------------------------*/
   IF p_level = 'ADJ' THEN	-- Entity level = ar_adjustments

  	/*------------------------------------------------------+
   	 | Create AE Lines for Receivables                      |
   	 +------------------------------------------------------*/
  	  -- added parameter for Line Level Adjustment
	   Create_Ae_Lines_ADJ(p_adj_rec        => l_adj_rec         ,
                               p_cust_inv_rec   => l_cust_inv_rec    ,
                               p_ctlgd_inv_rec  => l_ctlgd_inv_rec   ,
                               p_rule_rec       => l_rule_rec        ,
                               p_ard_rec        => l_ard_rec         ,
			       p_from_llca_call => p_from_llca_call  ,
                               p_gt_id          => p_gt_id);

   END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ADJUSTMENTS_MAIN.Create_Ae_Lines_Common()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ADJUSTMENTS_MAIN.Create_Ae_Lines_Common');
     END IF;
     RAISE;

END Create_Ae_Lines_Common;

/* =======================================================================
 | PROCEDURE Create_Ae_Lines_ADJ
 |
 | DESCRIPTION
 |      This procedure creates the AE lines for Receivables
 |
 |      Functions:
 |              - Create AE lines for Receivable .
 |              - Determines Amounts Dr/Cr.
 |
 | PARAMETERS
 |      p_adj_rec       Adjustments Record
 |      p_cust_inv_rec  Invoice header Record
 |      p_ctlgd_inv_rec  REC account ccid record
 |      p_rule_rec      Rule record
 |      p_ard_rec       Distributions record used by Bills Receivable
 * ======================================================================*/
PROCEDURE Create_Ae_Lines_ADJ(
		p_adj_rec 	 IN ar_adjustments%ROWTYPE                             ,
                p_cust_inv_rec   IN ra_customer_trx%ROWTYPE                            ,
                p_ctlgd_inv_rec  IN ra_cust_trx_line_gl_dist%ROWTYPE                   ,
                p_rule_rec       IN ae_rule_rec_type                                   ,
                p_ard_rec        IN ar_distributions%ROWTYPE                           ,
		p_from_llca_call      IN  VARCHAR2 DEFAULT 'N'                         ,
		p_gt_id               IN  NUMBER   DEFAULT NULL) IS
    l_subs_bal_seg        VARCHAR2(1);  /*7125756*/
  l_code_combination_id ar_adjustments.code_combination_id%TYPE; /*7125756*/
  l_ael_line_rec	ae_line_rec_type;
  l_empty_ael_line_rec	ae_line_rec_type;
  l_app_rec             ar_receivable_applications%ROWTYPE;
  l_ae_line_tbl         ae_line_tbl_type;
  l_ae_ctr              BINARY_INTEGER := 0;
  l_ctr                 BINARY_INTEGER;
  l_actual_ccid         ar_adjustments.code_combination_id%TYPE := null;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'Create_Ae_Lines_ADJ.Create_Ae_Lines_ADJ()+');
  END IF;

 /*-------------------------------------------------------------+
  | Get exchange rate and third part info from Invoice adjusted |
  | for building receivable REC                                 |
  +-------------------------------------------------------------*/
   l_ael_line_rec.source_id                := p_adj_rec.adjustment_id;
   l_ael_line_rec.source_table             := 'ADJ';

 /*-------------------------------------------------------------+
  | Set the source tyoe to the previous accounting record which |
  | needs to be offset for the Bills Receivable. This could be  |
  | the Bills Receivable or Unpaid Bills Receivable account.    |
  +-------------------------------------------------------------*/
   IF p_cust_inv_rec.drawee_site_use_id IS NOT NULL THEN
      l_ael_line_rec.ae_line_type             := p_ard_rec.source_type;
   ELSE
      l_ael_line_rec.ae_line_type             := 'REC';
   END IF;

   l_ael_line_rec.ae_line_type_secondary   := '';
   l_ael_line_rec.account                  := p_ctlgd_inv_rec.code_combination_id; --ccid for REC
   l_ael_line_rec.currency_code            := p_cust_inv_rec.invoice_currency_code;
   l_ael_line_rec.currency_conversion_rate := p_cust_inv_rec.exchange_rate;
   l_ael_line_rec.currency_conversion_type := p_cust_inv_rec.exchange_rate_type;
   l_ael_line_rec.currency_conversion_date := p_cust_inv_rec.exchange_date;

   IF p_cust_inv_rec.drawee_site_use_id IS NOT NULL THEN --if Bill
      l_ael_line_rec.third_party_id           := p_cust_inv_rec.drawee_id;
      l_ael_line_rec.third_party_sub_id       := p_cust_inv_rec.drawee_site_use_id;
   ELSE
      l_ael_line_rec.third_party_id           := p_cust_inv_rec.bill_to_customer_id;
      l_ael_line_rec.third_party_sub_id       := p_cust_inv_rec.bill_to_site_use_id;
   END IF; --Bill

 /*--------------------------------------------------------------------------------+
  | Derive Receivable amounts, for Adjustments.                                    |
  +--------------------------------------------------------------------------------*/

   IF ( sign( p_adj_rec.amount ) = -1 ) THEN   -- Credit Receivables for INV

       l_ael_line_rec.entered_cr   := abs(p_adj_rec.amount);
       l_ael_line_rec.entered_dr   := NULL;

       l_ael_line_rec.accounted_cr := abs(p_adj_rec.acctd_amount);
       l_ael_line_rec.accounted_dr := NULL;

   ELSE   -- Debit Receivables for INV, if amount adjusted is 0 then accounting record created

       l_ael_line_rec.entered_dr   := p_adj_rec.amount;
       l_ael_line_rec.entered_cr   := NULL;

       l_ael_line_rec.accounted_dr := p_adj_rec.acctd_amount;
       l_ael_line_rec.accounted_cr := NULL;

   END IF;

 /*-------------------------------------------------------------+
  | Assign AEL for REC for Invoice document for adjustment      |
  +-------------------------------------------------------------*/
   Assign_Ael_Elements( p_ae_line_rec 	=> l_ael_line_rec );

 /*---------------------------------------------------------------------------+
  | Call tax accounting routine for Adjustments if amount adjusted is non zero|
  +---------------------------------------------------------------------------*/

    IF (nvl(p_adj_rec.amount,0) <> 0) THEN

       l_ae_line_tbl := g_empty_ae_line_tbl;
       l_ae_ctr      := 0;

   /*---------------------------------------------------------------------------+
    | Verify whether invalid rule setup has occurred at the Receivable Activity |
    | in this case raise an error stating that the rule be set up correctly.    |
    +---------------------------------------------------------------------------*/
       IF (((p_rule_rec.gl_account_source1 = 'NO_SOURCE') OR (p_rule_rec.tax_code_source1 = 'NO_SOURCE'))
            OR ((p_rule_rec.tax_code_source1 = 'INVOICE')
                     AND (nvl(p_rule_rec.tax_recoverable_flag1, 'X') NOT IN ('Y','N'))))
       THEN

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
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('g_ae_doc_rec.deferred_tax ' || g_ae_doc_rec.deferred_tax);
          arp_standard.debug('p_cust_inv_rec.drawee_site_use_id '
                                                                             || p_cust_inv_rec.drawee_site_use_id);
       END IF;

       IF (nvl(g_ae_doc_rec.deferred_tax,'Y') = 'Y') THEN

         IF p_cust_inv_rec.drawee_site_use_id IS NULL THEN --check whether adjustment to bill

            -- Added parameter for Line level Adjustment
	    ARP_ALLOCATION_PKG.Allocate_Tax(
                        p_ae_doc_rec           => g_ae_doc_rec   ,     --Document detail
                        p_ae_event_rec         => g_ae_event_rec ,     --Event record
                        p_ae_rule_rec          => p_rule_rec     ,     --Rule info for payment method
                        p_app_rec              => l_app_rec      ,     --dummy applications record
                        p_cust_inv_rec         => p_cust_inv_rec ,     --Invoice details
                        p_adj_rec              => p_adj_rec      ,     --adjustment details
                        p_ae_ctr               => l_ae_ctr       ,     --counter
                        p_ae_line_tbl          => l_ae_line_tbl  ,     --final tax accounting table
			p_from_llca_call => p_from_llca_call     ,     --Line Adj detail
                        p_gt_id          => p_gt_id);
         ELSE /*---------------------------------------------------------------------+
               | This condition occurs for endorsments without recourse only since   |
               | adjustment is gross to activity, hence the Wrapper is called to     |
               | move deferred tax only. The parent adjustment must be of type       |
               | INVOICE. The wrapper breaks the adjustment into sub adjustments     |
               | for each assignment. This is necessary to enable accurate reporting |
               | of taxable amount for deferred tax using link ids. So in this case  |
               | we cannot simply create one accounting entry for gross to activity  |
               | gl account.                                                         |
               +---------------------------------------------------------------------*/
            ARP_BR_ALLOC_WRAPPER_PKG.Allocate_Tax_BR_Main(
                        p_mode                 => g_mode         ,     --Mode
                        p_ae_doc_rec           => g_ae_doc_rec   ,     --Document detail
                        p_ae_event_rec         => g_ae_event_rec ,     --Event record
                        p_ae_rule_rec          => p_rule_rec     ,     --Rule info for payment method
                        p_app_rec              => l_app_rec      ,     --Application details
                        p_cust_inv_rec         => p_cust_inv_rec ,     --Invoice details
                        p_adj_rec              => p_adj_rec      ,     --adjustment record
                        p_ae_sys_rec           => g_ae_sys_rec   ,     --system parameters
                        p_ae_ctr               => l_ae_ctr       ,     --counter
                        p_ae_line_tbl          => l_ae_line_tbl    ); --final tax accounting table

         END IF; --adjustment to Bill or Transaction
       ELSE --adjustments with recourse (when Maturity date not same as risk eliminate event
       /*-----------------------------------------------------------------------+
        | Do not call the Tax accounting to move deferred tax this happens when |
        | the Bills Receivable Housekeeper determines that the maturity date    |
        | event is seperate from the creation of the adjustment, for approved   |
        | Endorsments, we need to update the link id  so the last Transaction   |
        | History Record must be for Matured Pending Risk elimination Endorsment|
        +-----------------------------------------------------------------------*/
          update ar_adjustments
          set link_to_trx_hist_id   = (select max(th.transaction_history_id)
                                       from ar_transaction_history th
                                       where th.customer_trx_id = p_adj_rec.customer_trx_id
                                       and th.event = 'MATURITY_DATE'
                                       and exists (select 'x'
                                                   from ar_distributions ard
                                                   where ard.source_id = th.transaction_history_id
                                                   and ard.source_table = 'TH'))
          where adjustment_id = p_adj_rec.adjustment_id;

        /*-----------------------------------------------------------------------+
         | Create the Release 11 Writeoff to the Activity GL Account. Note that  |
         | the deferred tax would already have been moved at the maturity date   |
         | event, so we do not call the Tax accounting engine as the only        |
         | accounting allowed is Gross to Activity Gl Account i.e. GL ACCOUNT    |
         | SOURCE = 'ACTIVITY GL ACCOUNT', TAX CODE SOURCE = 'NONE', in this case|
         | a single accounting entry is created.
         +-----------------------------------------------------------------------*/
          IF p_cust_inv_rec.drawee_site_use_id IS NOT NULL THEN

             l_ael_line_rec.ae_line_type  := 'ADJ';
             l_ael_line_rec.account       := p_rule_rec.code_combination_id1; --ccid for writeoff

             IF ( sign( p_adj_rec.amount ) = -1 ) THEN   -- Dr the Write-off account

                l_ael_line_rec.entered_cr   := NULL;
                l_ael_line_rec.entered_dr   := abs(p_adj_rec.amount);

                l_ael_line_rec.accounted_cr := NULL;
                l_ael_line_rec.accounted_dr := abs(p_adj_rec.acctd_amount);

             ELSE   -- Cr the Write-off account

                l_ael_line_rec.entered_dr   := NULL;
                l_ael_line_rec.entered_cr   := p_adj_rec.amount;

                l_ael_line_rec.accounted_dr := NULL;
                l_ael_line_rec.accounted_cr := p_adj_rec.acctd_amount;

             END IF;

          /*-------------------------------------------------------------+
           | Assign AEL for ADJ Writeoff for adjustment                  |
           +-------------------------------------------------------------*/
             Assign_Ael_Elements( p_ae_line_rec 	=> l_ael_line_rec );

         END IF; --End if document is a bills receivable

       END IF; --End if deferred tax required to be moved

      /*-------------------------------------------------------------+
       | Assign AEL for Tax accounting                               |
       +-------------------------------------------------------------*/
       IF l_ae_line_tbl.EXISTS(l_ae_ctr) THEN --Atleast one Tax line exists

         FOR l_ctr IN l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST LOOP

             --It is necessary to populate the record and then call assign elements
             --because of standards and that the User Hook could override accounting
             --so need to populate this record (rather than direct table assignments)

             l_ael_line_rec := l_empty_ael_line_rec;
             l_ael_line_rec := l_ae_line_tbl(l_ctr);

           /*--------------------------------------------------------------+
            | Asign AEL for tax accounting for adjustments, finance charges|
            +--------------------------------------------------------------*/
             Assign_Ael_Elements( p_ae_line_rec         => l_ael_line_rec );

          END LOOP; --process tax lines

      END IF; --atleast one tax line exists

    ELSE --if adjustment is a zero amount adjustment then Credit the Write off account

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Processing Credit to Write Off for 0 amount adjustment ');
       END IF;

     --Substitute the balancing segment
     --Bugfix 1948917.
     --BugFix7125756

     l_subs_bal_seg := 'N';
     IF p_adj_rec.type = 'TAX' THEN
       IF (((p_rule_rec.tax_code_source1 = 'INVOICE') AND (p_rule_rec.tax_recoverable_flag1 = 'Y'))
           OR (p_rule_rec.tax_code_source1 = 'NONE') )THEN
            select min(code_combination_id)
            into l_code_combination_id
            from ra_cust_trx_line_gl_dist ctlgd
            where ctlgd.account_class = 'TAX'
            and   ctlgd.account_set_flag = 'N'
            and   ctlgd.customer_trx_id = p_adj_rec.customer_trx_id;

          l_subs_bal_seg := 'N';
       ELSIF (p_rule_rec.tax_code_source1 = 'ACTIVITY')
             AND (p_rule_rec.asset_tax_code1 IS NOT NULL) THEN
               l_code_combination_id := p_rule_rec.act_tax_non_rec_ccid1;
               l_subs_bal_seg := 'Y';
       ELSIF p_rule_rec.tax_code_source1 = 'INVOICE' AND p_rule_rec.tax_recoverable_flag1 = 'N' THEN
               select
               min(decode(alv.location_segment_id,
                       '',avt.adj_non_rec_tax_ccid,
                       alv.adj_non_rec_tax_ccid))
               into l_code_combination_id
               FROM ra_customer_trx_lines     ctl,
                    ar_vat_tax                avt,
                    ar_location_accounts      alv
               where ctl.customer_trx_id = p_adj_rec.customer_trx_id
               and   ctl.line_type = 'TAX'
               and   ctl.location_segment_id  = alv.location_segment_id(+)
               and   ctl.vat_tax_id           = avt.vat_tax_id(+);


               l_subs_bal_seg := 'Y';

       END IF;
       IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N'
          AND l_subs_bal_seg = 'Y' THEN
              ARP_ALLOCATION_PKG.Substitute_Ccid(
                  p_coa_id        => g_ae_sys_rec.coa_id            ,
                  p_original_ccid => l_code_combination_id,
                  p_subs_ccid     => l_ael_line_rec.account         , --Rec account
                  p_actual_ccid   => l_actual_ccid                   );
       ELSE
              l_actual_ccid := l_code_combination_id; --p_rule_rec.code_combination_id1;
       END IF;
     ELSE
   --END BUGFIX7125756
     IF NVL(FND_PROFILE.value('AR_DISABLE_REC_ACTIVITY_BALSEG_SUBSTITUTION'), 'N') = 'N' THEN
       ARP_ALLOCATION_PKG.Substitute_Ccid(
                  p_coa_id        => g_ae_sys_rec.coa_id            ,
                  p_original_ccid => p_rule_rec.code_combination_id1,
                  p_subs_ccid     => l_ael_line_rec.account         , --Rec account
                  p_actual_ccid   => l_actual_ccid                   );
     ELSE
       l_actual_ccid := p_rule_rec.code_combination_id1;
     END IF;
    END IF;
     --Set the actual account
       l_ael_line_rec.account := l_actual_ccid;

     --Set the source type
       IF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'ADJUSTMENT' THEN

           l_ael_line_rec.ae_line_type := 'ADJ';

      /*----------------------------------------------------------------------------+
       | Populate source type for finance charges                                   |
       +----------------------------------------------------------------------------*/
       ELSIF g_ae_doc_rec.source_table = 'ADJ' and g_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN

             l_ael_line_rec.ae_line_type := 'FINCHRG';

       END IF;

     --Set the amounts and accounted amounts
       l_ael_line_rec.entered_cr   := abs(p_adj_rec.amount);
       l_ael_line_rec.entered_dr   := NULL;

       l_ael_line_rec.accounted_cr := abs(p_adj_rec.acctd_amount);
       l_ael_line_rec.accounted_dr := NULL;

     /*-------------------------------------------------------------+
      | Assign AEL for REC for Invoice document for adjustment      |
      +-------------------------------------------------------------*/
       Assign_Ael_Elements( p_ae_line_rec       => l_ael_line_rec );

   END IF; --adjustment amount is non zero

/*------------------------------------------------------------------------------------+
 |Call the Reconciliation routine, this is necessary because the transaction or Bill  |
 |which may have been overapplied is now closed due to adjustment or overapplied      |
 |may have resulted in re-opening the transaction, hence we need to back out NOCOPY the old  |
 |reconciliation entries for the Bill or the Transactions                             |
 +------------------------------------------------------------------------------------*/
   ARP_RECONCILE.Reconcile_trx_br(
                      p_mode                     => g_mode                             ,
                      p_ae_doc_rec               => g_ae_doc_rec                       ,
                      p_ae_event_rec             => g_ae_event_rec                     ,
                      p_cust_inv_rec             => p_cust_inv_rec                     ,
                      p_activity_cust_trx_id     => p_adj_rec.customer_trx_id          ,
                      p_activity_amt             => p_adj_rec.amount                   ,
                      p_activity_acctd_amt       => p_adj_rec.acctd_amount             ,
                      p_call_num                 => 1                                  ,
                      p_g_ae_line_tbl            => g_ae_line_tbl                      ,
                      p_g_ae_ctr                 => g_ae_line_ctr                        );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Create_Ae_Lines_ADJ.Create_Ae_Lines_ADJ()-');
   END IF;

EXCEPTION
  WHEN ARP_ALLOCATION_PKG.invalid_allocation_base THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Create_Ae_Lines_ADJ.Create_Ae_Lines_ADJ - invalid_rule_error');
     END IF;
     fnd_message.set_name('AR','AR_INVALID_ACTIVITY');
     RAISE;

  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: Create_Ae_Lines_ADJ.Create_Ae_Lines_ADJ');
     END IF;
     RAISE;

END Create_Ae_Lines_ADJ;

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

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_ADJUSTMENTS_MAIN.Assign_Ael_Elements()+');
    END IF;

   /*------------------------------------------------------+
    | Call Hook to Override Account                        |
    +------------------------------------------------------*/
    ARP_ACCT_HOOK.Override_Account(
        	p_mode                    => g_mode,
        	p_ae_doc_rec              => g_ae_doc_rec,
        	p_ae_event_rec            => g_ae_event_rec,
		p_ae_line_rec		  => p_ae_line_rec,
		p_account		  => l_account,
		p_account_valid		  => l_account_valid,
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
    --{3377004
    g_ae_line_tbl(g_ae_line_ctr).ref_line_id              :=  p_ae_line_rec.ref_line_id;
    g_ae_line_tbl(g_ae_line_ctr).ref_customer_trx_line_id :=  p_ae_line_rec.ref_customer_trx_line_id;
    g_ae_line_tbl(g_ae_line_ctr).ref_cust_trx_line_gl_dist_id :=  p_ae_line_rec.ref_cust_trx_line_gl_dist_id;
    --}
    g_ae_line_tbl(g_ae_line_ctr).ref_account_class	  :=  p_ae_line_rec.ref_account_class;
    g_ae_line_tbl(g_ae_line_ctr).activity_bucket	  :=  p_ae_line_rec.activity_bucket;
    g_ae_line_tbl(g_ae_line_ctr).ref_dist_ccid		  :=  p_ae_line_rec.ref_dist_ccid;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_ADJUSTMENTS_MAIN.Assign_Ael_Elements()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ADJUSTMENTS_MAIN.Assign_Ael_Elements');
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

END ARP_ADJUSTMENTS_MAIN;

/
