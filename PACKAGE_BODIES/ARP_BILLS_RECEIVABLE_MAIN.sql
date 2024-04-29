--------------------------------------------------------
--  DDL for Package Body ARP_BILLS_RECEIVABLE_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BILLS_RECEIVABLE_MAIN" AS
/* $Header: ARBRACMB.pls 120.13.12010000.2 2009/09/24 12:35:24 dgaurab ship $ */

/* =======================================================================
 | Package Globals
 * ======================================================================*/
  g_mode			VARCHAR2(30);
  g_ae_doc_rec			ae_doc_rec_type;
  g_ae_event_rec		ae_event_rec_type;
  g_ae_line_tbl                 ae_line_tbl_type;
  g_empty_ae_line_tbl           ae_line_tbl_type;
  g_ae_sys_rec                  ae_sys_rec_type;
  g_ae_line_ctr                 BINARY_INTEGER;
  g_event                       VARCHAR2(30);
  g_previous_status             VARCHAR2(30);

/* =======================================================================
 | Source Table constants
 * ======================================================================*/
  C_TH             CONSTANT VARCHAR2(14) := 'TH';
  C_CTL            CONSTANT VARCHAR2(14) := 'CTL';

/* =======================================================================
 | Source Type constants
 * ======================================================================*/
  C_REC             CONSTANT VARCHAR2(14) := 'REC';
  C_UNPAIDREC       CONSTANT VARCHAR2(14) := 'UNPAIDREC';
  C_FACTOR          CONSTANT VARCHAR2(14) := 'FACTOR';
  C_REMITTANCE      CONSTANT VARCHAR2(14) := 'REMITTANCE';
  C_TAX             CONSTANT VARCHAR2(14) := 'TAX';
  C_DEFERRED_TAX    CONSTANT VARCHAR2(14) := 'DEFERRED_TAX';

/* =======================================================================
 | Source Secondary Type constant
 * ======================================================================*/
  C_ASSIGNMENT      CONSTANT VARCHAR2(14) := 'ASSIGNMENT';

/* =======================================================================
 | Bills Receivable status constants
 * ======================================================================*/
  C_INCOMPLETE         CONSTANT VARCHAR2(20) := 'INCOMPLETE';
  C_PENDING_ACCEPTANCE CONSTANT VARCHAR2(20) := 'PENDING_ACCEPTANCE';
  C_PENDING_REMITTANCE CONSTANT VARCHAR2(20) := 'PENDING_REMITTANCE';
  C_REMITTED           CONSTANT VARCHAR2(20) := 'REMITTED';
  C_FACTORED           CONSTANT VARCHAR2(20) := 'FACTORED';
  C_UNPAID             CONSTANT VARCHAR2(20) := 'UNPAID';
  C_CANCELLED          CONSTANT VARCHAR2(20) := 'CANCELLED';
  C_ENDORSED           CONSTANT VARCHAR2(20) := 'ENDORSED';

/* =======================================================================
 | Bills Receivable event constants
 * ======================================================================*/
  C_MATURITY_DATE      CONSTANT VARCHAR2(20) := 'MATURITY_DATE';
  C_RECALLED           CONSTANT VARCHAR2(20) := 'RECALLED';

/* =======================================================================
 | Private Procedure/Function prototypes
 * ======================================================================*/
  PROCEDURE Init_Ae_Lines;

  PROCEDURE Derive_Accounting_Entry;

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Delete_TH(p_ae_deleted   OUT NOCOPY BOOLEAN);

  PROCEDURE Reverse_BR;

  PROCEDURE Get_Doc_Entitity_Data (
                p_level          IN  VARCHAR2                           ,
                p_app_rec        OUT NOCOPY ar_receivable_applications%ROWTYPE ,
                p_cust_inv_rec   OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_trh_rec        OUT NOCOPY ar_transaction_history%ROWTYPE     , -- jrautiai
                p_rule_rec       OUT NOCOPY ae_rule_rec_type                     );

  PROCEDURE Create_Ae_Lines_Common (
                p_level         IN VARCHAR2 );

  PROCEDURE Create_Ae_Lines_BR(
                p_app_rec        IN ar_receivable_applications%ROWTYPE ,
                p_cust_inv_rec   IN ra_customer_trx%ROWTYPE            ,
                p_trh_rec        IN ar_transaction_history%ROWTYPE     , -- jrautiai
                p_rule_rec       IN ae_rule_rec_type                     );

  PROCEDURE Assign_Ael_Elements(
                p_ae_line_rec           IN ae_line_rec_type );


  PROCEDURE initialize_global_variables(p_trh_rec IN ar_transaction_history%ROWTYPE);

  FUNCTION trx_history_status(p_transaction_history_id  IN ar_transaction_history.transaction_history_id%TYPE) RETURN VARCHAR2;

  PROCEDURE create_exchanged_trx_acct(p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE,
                                      p_ae_rule_rec     IN ae_rule_rec_type);

  FUNCTION find_exchanged_trx_acct(p_transaction_history_id      IN ar_transaction_history.transaction_history_id%TYPE) RETURN NUMBER;

  PROCEDURE reverse_exchanged_trx_acct(p_transaction_history_id  IN  ar_transaction_history.transaction_history_id%TYPE);

  PROCEDURE reverse_single_dist_line(p_dist_rec   IN ar_distributions%ROWTYPE);

  PROCEDURE reverse_old_acct(p_transaction_history_id IN ar_transaction_history.transaction_history_id%TYPE,
                             p_ps_id                  IN ar_payment_schedules.payment_schedule_id%TYPE);

  PROCEDURE find_rec_dist_record(p_transaction_history_id IN  ar_transaction_history.transaction_history_id%TYPE,
                                 p_sign                   IN  NUMBER,
                                 p_dist_rec               OUT NOCOPY ar_distributions%ROWTYPE);


  PROCEDURE find_prev_posted_hist_record(p_transaction_history_id IN  ar_transaction_history.transaction_history_id%TYPE,
                                         p_trh_rec                OUT NOCOPY ar_transaction_history%ROWTYPE,
                                         p_status                 IN  ar_transaction_history.status%TYPE DEFAULT NULL,
                                         p_event                  IN  ar_transaction_history.event%TYPE DEFAULT NULL);

  PROCEDURE reverse_deferred_tax(p_transaction_history_id ar_transaction_history.transaction_history_id%TYPE);

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
 |      deletes the accounting associated with Transaction history source
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
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Delete_Acct()+');
  END IF;

  /*----------------------------------------------------+
   | Copy Document/Event Data to Global                 |
   +----------------------------------------------------*/
  g_mode         := p_mode;
  g_ae_doc_rec   := p_ae_doc_rec;
  g_ae_event_rec := p_ae_event_rec;

  IF ( g_ae_doc_rec.source_table = C_TH ) THEN

     Delete_TH(p_ae_deleted => p_ae_deleted) ;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Delete_Acct()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Delete_Acct');
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
                   p_ae_created          OUT NOCOPY BOOLEAN) IS


BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Execute()+');
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

  -- MRC Trigger Replacement: Initialize new global variable.
  g_ae_sys_rec.sob_type          := NVL(ARP_ACCT_MAIN.ae_sys_rec.sob_type,'P');

  /*------------------------------------------------------+
   | Derive Accounting Entry                              |
   +------------------------------------------------------*/
  Derive_Accounting_Entry;

  /*------------------------------------------------------+
   | Return Accounting Entry Creation Status              |
   +------------------------------------------------------*/
  p_ae_line_tbl := g_ae_line_tbl;

  IF g_ae_line_tbl.EXISTS(g_ae_line_ctr) THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  'bills receivable... p_ea_created = TRUE');
    END IF;
    p_ae_created := TRUE;

  ELSE

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  'bills receivable... p_ea_created = FALSE');
    END IF;
    p_ae_created := FALSE;

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Execute()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'ARP_BILLS_RECEIVABLE_MAIN.Execute - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Execute');
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
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Init_Ae_Lines()+');
  END IF;

  g_ae_line_tbl := g_empty_ae_line_tbl;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Init_Ae_Lines()-');
  END IF;
EXCEPTION

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Init_Ae_Lines');
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
PROCEDURE Derive_Accounting_Entry IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Derive_Accounting_Entry()+');
  END IF;

  /*------------------------------------------------------------+
   | Create Accounting Entries at the Document Entity level.    |
   +------------------------------------------------------------*/
  IF ( g_ae_doc_rec.accounting_entity_level = 'ONE' ) THEN

     IF ((g_ae_doc_rec.source_id_old IS NOT NULL) and (g_ae_doc_rec.other_flag = 'REVERSE')) THEN

       /*------------------------------------------------------------+
        | Reverse Accounting Entry Lines for Transaction History     |
        | accounting                                                 |
        +------------------------------------------------------------*/
       Reverse_BR;

     ELSIF ( g_ae_doc_rec.source_table = C_TH ) THEN

       /*---------------------------------------------------------+
        | Create Accounting Entry Lines, Bills Receivable         |
        +---------------------------------------------------------*/
       Create_Ae_Lines_Common(p_level => C_TH);

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
     arp_standard.debug(   'ARP_BILLS_RECEIVABLE_MAIN.Derive_Accounting_Entry()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Derive_Accounting_Entry');
     END IF;
     RAISE;
END Derive_Accounting_Entry;

/* =======================================================================
 |
 | PROCEDURE Delete_TH
 |
 | DESCRIPTION
 |      Deletes accounting associated with a Transaction History id
 |      from the AR_DISTRIBUTIONS table.This routine deletes all records
 |      matching the input source_id. Note records from child table
 |      (AR_DISTRIBUTIONS) be deleted first.
 | NOTE
 |      If this routine is called there must be accounting for the
 |      parent Transaction history id in the distributions table
 |      otherwise a NO_DATA_FOUND exception will be raised. In other
 |      words the routine call should be valid.
 |
 | PARAMETERS
 |      p_ae_deleted       indicates whether records were deleted
 |                         for source_id
 * ======================================================================*/
PROCEDURE Delete_TH(p_ae_deleted          OUT NOCOPY BOOLEAN) IS

l_trans_hist            ar_transaction_history.transaction_history_id%TYPE;

-- MRC Trigger Replacement:
l_ar_dist_key_value_list   gl_ca_utility_pkg.r_key_value_arr;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_BILLS_RECEIVABLE_MAIN.Delete_TH()+');
    END IF;

 /*-------------------------------------------------------------------+
  | Verify that the source id is a valid candidate for deletion       |
  +-------------------------------------------------------------------*/
    SELECT th.transaction_history_id
    INTO   l_trans_hist
    FROM   ar_transaction_history th
    WHERE  th.transaction_history_id = g_ae_doc_rec.source_id
    AND    th.gl_posted_date is null
    AND    th.posting_control_id = -3
    AND    th.postable_flag = 'Y'
    AND    g_ae_doc_rec.source_table = C_TH;

 /*-------------------------------------------------------------------+
  | Delete all accounting for source id and source table combination  |
  | if valid candidate for deletion, if not then a NO_DATA_FOUND      |
  | exception will be raised by the above select statement.           |
  +-------------------------------------------------------------------*/
    DELETE FROM AR_DISTRIBUTIONS
    WHERE  source_id    = g_ae_doc_rec.source_id
    AND    source_table = C_TH
    RETURNING line_id
    BULK COLLECT INTO l_ar_dist_key_value_list;

    /*---------------------------------+
     | Calling central MRC library     |
     | for MRC Integration             |
     +---------------------------------*/
--{BUG4301323
--     ar_mrc_engine.maintain_mrc_data(
--               p_event_mode        => 'DELETE',
--               p_table_name        => 'AR_DISTRIBUTIONS',
--               p_mode              => 'BATCH',
--               p_key_value_list    => l_ar_dist_key_value_list);
--}

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_BILLS_RECEIVABLE_MAIN.Delete_TH()-');
    END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BILLS_RECEIVABLE_MAIN.Delete_TH - NO_DATA_FOUND' );
     END IF;
     p_ae_deleted := FALSE;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Delete_TH');
     END IF;
     p_ae_deleted := FALSE;
     RAISE ;

END Delete_TH;

/* =======================================================================
 |
 | PROCEDURE Reverse_BR
 |
 | DESCRIPTION
 |      This procedure reverses the records in AR_DISTRIBUTIONS for a
 |      accounting associated with a Bills Receivable Transaction history.
 |
 | PARAMETERS
 |      None
 * ======================================================================*/
PROCEDURE Reverse_BR  IS

-- MRC Trigger Replacement:  Enumerate all columns and add union

CURSOR get_old_ard  IS
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
              ard.ref_line_id,
              ard.from_amount_dr,
              ard.from_amount_cr,
              ard.from_acctd_amount_dr,
              ard.from_acctd_amount_cr
              --}
       from   ar_distributions ard
       where  NVL(g_ae_sys_rec.sob_type,'P') = 'P'
         and  ard.source_id = g_ae_doc_rec.source_id_old
         and    ard.source_table = g_ae_doc_rec.source_table
       order  by line_id ;
/*BUG4301323
      UNION
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
              ard.ref_line_id,
              ard.from_amount_dr,
              ard.from_amount_cr,
              ard.from_acctd_amount_dr,
              ard.from_acctd_amount_cr
              --}
       from   ar_mc_distributions_all ard
       where  g_ae_sys_rec.sob_type = 'R'
         and  ard.set_of_books_id = g_ae_sys_rec.set_of_books_id
         and  ard.source_id = g_ae_doc_rec.source_id_old
         and  ard.source_table = g_ae_doc_rec.source_table
       order  by line_id ;
*/

l_ard_rec                ar_distributions%ROWTYPE;

BEGIN

  arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Reverse_BR()+');
  --{HYUDETUPT change the structure of this code so that it does not break everytime schema changes

  OPEN get_old_ard;
  LOOP
    FETCH get_old_ard INTO
        l_ard_rec.line_id,
        l_ard_rec.source_id,
        l_ard_rec.source_table,
        l_ard_rec.source_type,
        l_ard_rec.code_combination_id,
        l_ard_rec.amount_dr,
        l_ard_rec.amount_cr,
        l_ard_rec.acctd_amount_dr,
        l_ard_rec.acctd_amount_cr,
        l_ard_rec.creation_date,
        l_ard_rec.created_by,
        l_ard_rec.last_updated_by,
        l_ard_rec.last_update_date,
        l_ard_rec.last_update_login,
        l_ard_rec.org_id,
        l_ard_rec.source_table_secondary,
        l_ard_rec.source_id_secondary,
        l_ard_rec.currency_code,
        l_ard_rec.currency_conversion_rate,
        l_ard_rec.currency_conversion_type,
        l_ard_rec.currency_conversion_date,
        l_ard_rec.taxable_entered_dr,
        l_ard_rec.taxable_entered_cr,
        l_ard_rec.taxable_accounted_dr,
        l_ard_rec.taxable_accounted_cr,
        l_ard_rec.tax_link_id,
        l_ard_rec.third_party_id,
        l_ard_rec.third_party_sub_id,
        l_ard_rec.reversed_source_id,
        l_ard_rec.tax_code_id,
        l_ard_rec.location_segment_id,
        l_ard_rec.source_type_secondary,
        l_ard_rec.tax_group_code_id,
              --{BUG#2979254
        l_ard_rec.ref_customer_trx_line_id,
        l_ard_rec.ref_cust_trx_line_gl_dist_id,
        l_ard_rec.ref_line_id,
        l_ard_rec.from_amount_dr,
        l_ard_rec.from_amount_cr,
        l_ard_rec.from_acctd_amount_dr,
        l_ard_rec.from_acctd_amount_cr;
     EXIT WHEN get_old_ard%NOTFOUND;

     reverse_single_dist_line(l_ard_rec);

  END LOOP;
  CLOSE get_old_ard;
  --}
  arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Reverse_BR()-');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    arp_standard.debug('ARP_BILLS_RECEIVABLE_MAIN.Reverse_BR - NO_DATA_FOUND' );
    RAISE;

  WHEN OTHERS THEN
    arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Reverse_BR');
    RAISE ;

END Reverse_BR;

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
 |      p_cust_inv_rec   Invoice document or On Account Credit Memo data
 |      p_rule_rec       Rule record
 |
 | NOTES
 * ======================================================================*/
PROCEDURE Get_Doc_Entitity_Data (
                p_level          IN VARCHAR2                            ,
                p_app_rec        OUT NOCOPY ar_receivable_applications%ROWTYPE ,
                p_cust_inv_rec   OUT NOCOPY ra_customer_trx%ROWTYPE            ,
                p_trh_rec        OUT NOCOPY ar_transaction_history%ROWTYPE     ,
                p_rule_rec       OUT NOCOPY ae_rule_rec_type) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Get_Doc_Entitity_Data()+');
   END IF;

/*----------------------------------------------------------------------------+
 | Retrieve the data required for accounting for a bills receivable document  |
 | Note : In this case we use the p_app_rec (receivable applications), this is|
 |        because we want to simulate a Receipt application (payment) event   |
 |        to move Deferred Tax using the tax accounting engine. This also     |
 |        minimizes the changes to the tax accounting engine (ARALLOCB.pls).  |
 +----------------------------------------------------------------------------*/

   -- MRC TRIGGER Replacement:  Modified to call functions for currency
   -- sensitive data.

   IF p_level = C_TH then
      select '',
             pay.customer_trx_id,
             pay.payment_schedule_id,
             pay.amount_due_remaining,
--{BUG#4301323
--             DECODE(g_ae_sys_rec.sob_type, 'P',
--                    pay.acctd_amount_due_remaining,
--                    arp_mrc_acct_main.get_ps_entity_data(
--                      pay.payment_schedule_id,
--                      g_ae_sys_rec.set_of_books_id)) acctd_amount_due_remaining,
             pay.acctd_amount_due_remaining      acctd_amount_due_remaining,
--}
             pay.amount_line_items_remaining,
             pay.tax_remaining,
             pay.freight_remaining,
             pay.receivables_charges_remaining,
             'Y',
             ctinv.invoice_currency_code,
--{BUG#4301323
--             DECODE(g_ae_sys_rec.sob_type, 'P',
--                    ctinv.exchange_rate,
--                    arp_mrc_acct_main.get_ctx_exg_rate(
--                        ctinv.customer_trx_id,
--                        g_ae_sys_rec.set_of_books_id)) exchange_rate,
             ctinv.exchange_rate             exchange_rate,
--}
--{BUG#4301323
--             DECODE(g_ae_sys_rec.sob_type, 'P',
--                    ctinv.exchange_rate_type,
--                    arp_mrc_acct_main.get_ctx_exg_rate_type(
--                        ctinv.customer_trx_id,
--                        g_ae_sys_rec.set_of_books_id)) exchange_rate_type,
             ctinv.exchange_rate_type      exchange_rate_type,
--}
--{BUG#4301323
--             DECODE(g_ae_sys_rec.sob_type, 'P',
--                    ctinv.exchange_date,
--                    arp_mrc_acct_main.get_ctx_exg_date(
--                        ctinv.customer_trx_id,
--                        g_ae_sys_rec.set_of_books_id)) exchange_date,
            ctinv.exchange_date             exchange_date,
--}
             ctinv.trx_date,
             ctinv.bill_to_customer_id,
             ctinv.bill_to_site_use_id,
             ctinv.drawee_site_use_id,
             th.customer_trx_id,
             th.status,
             th.event,
             th.prv_trx_history_id
      into   p_app_rec.receivable_application_id,
             p_app_rec.applied_customer_trx_id,
             p_app_rec.applied_payment_schedule_id,
             p_app_rec.amount_applied,
             p_app_rec.acctd_amount_applied_to,
             p_app_rec.line_applied,
             p_app_rec.tax_applied,
             p_app_rec.freight_applied,
             p_app_rec.receivables_charges_applied,
             p_app_rec.confirmed_flag,
             p_cust_inv_rec.invoice_currency_code,
             p_cust_inv_rec.exchange_rate,
             p_cust_inv_rec.exchange_rate_type,
             p_cust_inv_rec.exchange_date,
             p_cust_inv_rec.trx_date,
             p_cust_inv_rec.bill_to_customer_id, --3rd party
             p_cust_inv_rec.bill_to_site_use_id, --3rd party sub id
             p_cust_inv_rec.drawee_site_use_id,
             p_trh_rec.customer_trx_id,
             p_trh_rec.status,
             p_trh_rec.event,
             p_trh_rec.prv_trx_history_id
      from ar_transaction_history     th,
           ra_customer_trx            ctinv,
           ar_payment_schedules       pay
      where th.transaction_history_id = g_ae_doc_rec.source_id
      and   th.customer_trx_id = ctinv.customer_trx_id
      and   ctinv.customer_trx_id = pay.customer_trx_id;

/*-----------------------------------------------------------------------------+
 | Initialize the rules buffer for discounts (Bills have no discounts) however |
 | since the tax accounting engine is to be called we simulate a application   |
 | hence in this case we initialize our rule buffer.                           |
 +----------------------------------------------------------------------------*/
    IF g_event in ('MATURITY_DATE','UNPAID') THEN
         select 'NO_SOURCE', --gl account source
                'NO_SOURCE', -- tax code source
                '',          -- tax recoverable flag
                '',          -- discount ccid
                '',          --asset tax code
                '',          --liability tax code
                ''         ,
                ''         ,
                'NO_SOURCE',
                'NO_SOURCE',
                '',
                '',
                '',
                '',
                ''                                         ,
                ''
         into   p_rule_rec.gl_account_source1, --Initialize Earned discounts
                p_rule_rec.tax_code_source1,
                p_rule_rec.tax_recoverable_flag1,
                p_rule_rec.code_combination_id1,
                p_rule_rec.asset_tax_code1,
                p_rule_rec.liability_tax_code1,
                p_rule_rec.act_tax_non_rec_ccid1,
                p_rule_rec.act_vat_tax_id1,
                p_rule_rec.gl_account_source2, --Initialize Unearned discounts
                p_rule_rec.tax_code_source2,
                p_rule_rec.tax_recoverable_flag2,
                p_rule_rec.code_combination_id2,
                p_rule_rec.asset_tax_code2,
                p_rule_rec.liability_tax_code2,
                p_rule_rec.act_tax_non_rec_ccid2,
                p_rule_rec.act_vat_tax_id2
         from   dual;

      END IF; --end if Maturity date event

   END IF; --end if p_level = C_TH

   initialize_global_variables(p_trh_rec);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Get_Doc_Entitity_Data()-');
   END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_BILLS_RECEIVABLE_MAIN.Get_Doc_Entitity_Data - NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Get_Doc_Entitity_Data');
     END IF;
     RAISE ;

END Get_Doc_Entitity_Data;

/* =======================================================================
 | PROCEDURE Create_Ae_Lines_Common
 |
 | DESCRIPTION
 |      This procedure creates the AE lines at each entity level. Used
 |      for creating lines as part of each accounting event associated
 |      with the entity Transaction history.
 |
 |      Functions:
 |      	- Create AE lines.
 |      	- Get additional data to determine the type of AE lines
 |
 | PARAMETERS
 |      p_level       Entity level from which the procedure was called
 * ======================================================================*/
PROCEDURE Create_Ae_Lines_Common (
		p_level 	IN VARCHAR2 ) IS

  l_app_rec		ar_receivable_applications%ROWTYPE ;
  l_cust_inv_rec        ra_customer_trx%ROWTYPE            ;
  l_trh_rec             ar_transaction_history%ROWTYPE     ; -- jrautiai
  l_rule_rec            ae_rule_rec_type                   ;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_Common()+');
   END IF;

   /*-------------------------------------------------------------+
    | Get Document Entitity specific data                         |
    +-------------------------------------------------------------*/

     Get_Doc_Entitity_Data(p_level          => p_level        ,
                           p_app_rec        => l_app_rec      ,
                           p_cust_inv_rec   => l_cust_inv_rec ,
                           p_trh_rec        => l_trh_rec      , -- jrautiai
                           p_rule_rec       => l_rule_rec      );

  /*------------------------------------------------------+
   | Create AE Lines for Transaction History              |
   +------------------------------------------------------*/
   IF (p_level = C_TH) THEN	-- Entity level Transaction History

   /*------------------------------------------------------+
    | Create AE Lines for Transaction History Accounting   |
    +------------------------------------------------------*/
     Create_Ae_Lines_BR(p_app_rec        => l_app_rec        ,
                        p_cust_inv_rec   => l_cust_inv_rec   ,
                        p_trh_rec        => l_trh_rec        , -- jrautiai
                        p_rule_rec       => l_rule_rec        );

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_Common()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_Common');
     END IF;
     RAISE;

END Create_Ae_Lines_Common;

/* =======================================================================
 | PROCEDURE Create_Ae_Lines_BR
 |
 | DESCRIPTION
 |      This procedure creates the AE lines for accounting events associated
 |      with the transaction history record
 |
 |      Functions:
 |              - Create AE lines for Transaction history.
 |              - Determines Amounts Dr/Cr.
 |
 | PARAMETERS
 |      p_app_rec       Receivables Application Record(Transaction data)
 |      p_cust_inv_rec  Invoice header Record
 |      p_rule_rec      Rule Record
 * ======================================================================*/
PROCEDURE Create_Ae_Lines_BR(
		p_app_rec 	 IN ar_receivable_applications%ROWTYPE                 ,
                p_cust_inv_rec   IN ra_customer_trx%ROWTYPE                            ,
                p_trh_rec        IN ar_transaction_history%ROWTYPE                     , -- jrautiai
                p_rule_rec       IN ae_rule_rec_type                                     ) IS

  l_app_id                ar_receivable_applications.receivable_application_id%TYPE;
  l_ael_line_rec	      ae_line_rec_type;
  l_empty_ael_line_rec	  ae_line_rec_type;
  l_adj_rec               ar_adjustments%ROWTYPE;
  l_ae_line_tbl           ae_line_tbl_type;
  l_ae_ctr                BINARY_INTEGER := 0;
  l_ctr                   BINARY_INTEGER;
  l_account_class         VARCHAR(30) := NULL;
  l_ccid                  number;
  l_concat_segments       varchar2(2000);
  l_num_failed_dist_rows  number;
  l_prev_posted_trh_rec   ar_transaction_history%ROWTYPE;
  l_ae_deleted            BOOLEAN := FALSE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_BR()+');
  END IF;

 /*-------------------------------------------------------------------------+
  | Create accounting based on the record status and event that took place  |
  +-------------------------------------------------------------------------*/
  IF g_event = C_MATURITY_DATE THEN

   /*------------------------------------------------------------+
    | Maturity date events only tax is moved, that is done later |
    +------------------------------------------------------------*/
    NULL;

  ELSIF g_event = C_RECALLED THEN --recall

   /*------------------------------------------------------------+
    | Recall event cancels all accounting on the previous record |
    | Deferred tax is not moved and autoaccounting is not called |
    +------------------------------------------------------------*/

   /*-----------------------------------------------------+
    | Find the previous posted transaction history record |
    +-----------------------------------------------------*/
    find_prev_posted_hist_record(g_ae_doc_rec.source_id,l_prev_posted_trh_rec);
    g_ae_doc_rec.source_id_old := l_prev_posted_trh_rec.transaction_history_id;

   /*-------------------------------------------------+
    | Reverse accounting by the reverse functionality |
    +-------------------------------------------------*/
    g_ae_doc_rec.other_flag := 'REVERSE';
    Reverse_BR;

  ELSIF p_trh_rec.status = C_PENDING_REMITTANCE THEN

   /*---------------------------------------------------------------+
    | When status becomes PENDING_REMITTANCE the accounting depends |
    | on the previous status. Autoaccounting is called called with  |
    | class REC for both cases.                                     |
    +---------------------------------------------------------------*/
    l_account_class := C_REC;

    IF g_previous_status in (C_INCOMPLETE,C_PENDING_ACCEPTANCE) THEN

     /*---------------------------------------------------------------+
      | When previous status is INCOMPLETE or PENDING_ACCEPTANCE      |
      | accounting is created for all exchanged transactions.         |
      +---------------------------------------------------------------*/
      create_exchanged_trx_acct(p_trh_rec.customer_trx_id,
                                p_rule_rec);

    ELSE -- C_UNPAID -- restate

     /*---------------------------------------------------------------+
      | Otherwise the previous status is UNPAID so the BR was restated|
      | The old accounting is reversed.                               |
      +---------------------------------------------------------------*/
      reverse_old_acct(g_ae_doc_rec.source_id,
                       p_app_rec.applied_payment_schedule_id);

    END IF;

  ELSIF p_trh_rec.status = C_CANCELLED THEN
   /*---------------------------------------------------------------+
    | When status becomes CANCELLED the previous accounting         |
    | is and all the accounting for the exchanged transactions is   |
    | reversed. Autoaccounting is not called.                       |
    +---------------------------------------------------------------*/

   /*---------------------------------------+
    | The old accounting is reversed.       |
    +---------------------------------------*/
    reverse_old_acct(g_ae_doc_rec.source_id,
                     p_app_rec.applied_payment_schedule_id);

   /*----------------------------------------------------------------------+
    | Reverse accounting for exchanged transactions created at completion. |
    +----------------------------------------------------------------------*/
    reverse_exchanged_trx_acct(g_ae_doc_rec.source_id);

  ELSIF p_trh_rec.status = C_UNPAID THEN
   /*-----------------------------------------------------------------+
    | When status becomes UNPAID the old accounting is                |
    | reversed. Autoaccounting is called called with class UNPAIDREC. |
    +-----------------------------------------------------------------*/

    l_account_class := C_UNPAIDREC;

   /*---------------------------------------+
    | The old accounting is reversed.       |
    +---------------------------------------*/
    reverse_old_acct(g_ae_doc_rec.source_id,
                     p_app_rec.applied_payment_schedule_id);

  ELSIF p_trh_rec.status = C_REMITTED THEN
   /*-------------------------------------------------------------------+
    | When status becomes STANDARD_REMITTED the old accounting is       |
    | reversed. Autoaccounting is called called with class REMITTANCE.  |
    +-------------------------------------------------------------------*/

    l_account_class := C_REMITTANCE;

   /*---------------------------------------+
    | The old accounting is reversed.       |
    +---------------------------------------*/
    reverse_old_acct(g_ae_doc_rec.source_id,
                     p_app_rec.applied_payment_schedule_id);

  ELSIF p_trh_rec.status = C_FACTORED THEN

   /*-------------------------------------------------------------------+
    | When status becomes FACTORED the old accounting is                |
    | reversed. Autoaccounting is called called with class FACTOR.      |
    +-------------------------------------------------------------------*/

    l_account_class := C_FACTOR;

   /*---------------------------------------+
    | The old accounting is reversed.       |
    +---------------------------------------*/
    reverse_old_acct(g_ae_doc_rec.source_id,
                     p_app_rec.applied_payment_schedule_id);

  ELSE -- all other cases reverse the previous accounting
   /*--------------------------------------------------------------------------+
    | Not supported, raise an error to notify that this has to be implemented. |
    +--------------------------------------------------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_BR - status '||p_trh_rec.status||' not supported');
    END IF;
    APP_EXCEPTION.raise_exception;

  END IF;

  /*----------------------------------------------------------+
   | If l_account_class is populated we call auto accounting. |
   +----------------------------------------------------------*/

   IF l_account_class is not null THEN

     BEGIN

      /*-----------------------+
       | Call auto accounting. |
       +-----------------------*/
       arp_auto_accounting_br.do_autoaccounting(
                                     'I',
                                     l_account_class,
                                     p_trh_rec.customer_trx_id,
                                     null, -- receivable_application_id
                                     null, -- br_unpaid_ccid
                                     null, -- cust_trx_type_id
                                     null, -- site_use_id
                                     null, -- receipt_method_id
                                     null, -- bank_account_id
                                     l_ccid, -- (out)
                                     l_concat_segments, -- (out)
                                     l_num_failed_dist_rows); -- (out)

     EXCEPTION
       WHEN arp_auto_accounting.no_ccid THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_BR - AutoAccounting Failed' );
         END IF;
         RAISE;
       WHEN OTHERS THEN
         RAISE;
     END;
   END IF;

  /*--------------------------------------------------------------------------+
   | Call the tax accounting engine for the deferred tax Maturity date event  |
   | for Bills Receivable                                                     |
   +--------------------------------------------------------------------------*/
   IF (g_event = C_MATURITY_DATE) AND (nvl(g_ae_doc_rec.deferred_tax,'Y') = 'Y')
      AND ((p_app_rec.amount_applied <> 0) or (p_app_rec.acctd_amount_applied_to <> 0)) THEN

      l_ae_line_tbl := g_empty_ae_line_tbl;
      l_ae_ctr      := 0;

    /*---------------------------------------------------------------------------+
     | The deferred tax flag is set by the Bills Receivable Houskeeper. Call the |
     | Bills Receivable wrapper routine to move deferred tax for the remaining   |
     | amount and accounted amount on the tax buckets, simulating a receipt      |
     | application. Hence it is noticible that the p_app_rec record is used for  |
     | processing associated with the maturity date event.                       |
     +---------------------------------------------------------------------------*/
       ARP_BR_ALLOC_WRAPPER_PKG.Allocate_Tax_BR_Main(
                 p_mode                 => g_mode         ,     --Document mode
                 p_ae_doc_rec           => g_ae_doc_rec   ,     --Document detail
                 p_ae_event_rec         => g_ae_event_rec ,     --Event record
                 p_ae_rule_rec          => p_rule_rec     ,     --Rule info for payment method
                 p_app_rec              => p_app_rec      ,     --Application details
                 p_cust_inv_rec         => p_cust_inv_rec ,     --Invoice details
                 p_adj_rec              => l_adj_rec      ,     --dummy adjustment record
                 p_ae_sys_rec           => g_ae_sys_rec   ,     --system parameters
                 p_ae_ctr               => l_ae_ctr       ,     --counter
                 p_ae_line_tbl          => l_ae_line_tbl); --final tax accounting table

       IF l_ae_line_tbl.EXISTS(l_ae_ctr) THEN --Atleast one Tax line exists

          FOR l_ctr IN l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST LOOP

            /*-----------------------------------------------------------------------+
             | It is necessary to populate the record and then call assign elements  |
             | because of standards and that the User Hook could override accounting |
             | so need to populate this record (rather than direct table assignments)|
             +-----------------------------------------------------------------------*/
              l_ael_line_rec := l_empty_ael_line_rec;
              l_ael_line_rec := l_ae_line_tbl(l_ctr);

            /*----------------------------------+
             | Assign AEL for REC for document  |
             +----------------------------------*/
              Assign_Ael_Elements( p_ae_line_rec         => l_ael_line_rec );

          END LOOP; --end loop tax accounting table

       END IF; --end if atleast one tax line exists

   ELSIF (g_event = C_UNPAID AND g_previous_status in (C_ENDORSED,C_FACTORED)) THEN

     /*-------------------------------------------------------------------+
      | Need to back out NOCOPY all deferred tax related to MATURITY_DATE row    |
      +-------------------------------------------------------------------*/
      reverse_deferred_tax(g_ae_doc_rec.source_id);

   END IF; --end if Maturity date event for a Bill


  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_BR()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: NO_DATA_FOUND' );
     END IF;
     RAISE;

  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Create_Ae_Lines_BR');
     END IF;
     RAISE;

END Create_Ae_Lines_BR;

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
       arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Assign_Ael_Elements()+');
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
    g_ae_line_tbl(g_ae_line_ctr).tax_code_id              :=  p_ae_line_rec.tax_code_id;
    g_ae_line_tbl(g_ae_line_ctr).tax_group_code_id        :=  p_ae_line_rec.tax_group_code_id;
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
    g_ae_line_tbl(g_ae_line_ctr).from_amount_dr           :=  p_ae_line_rec.from_amount_dr;
    g_ae_line_tbl(g_ae_line_ctr).from_amount_cr           :=  p_ae_line_rec.from_amount_cr;
    g_ae_line_tbl(g_ae_line_ctr).from_acctd_amount_dr     :=  p_ae_line_rec.from_acctd_amount_dr;
    g_ae_line_tbl(g_ae_line_ctr).from_acctd_amount_cr     :=  p_ae_line_rec.from_acctd_amount_cr;
    g_ae_line_tbl(g_ae_line_ctr).activity_bucket                   :=  p_ae_line_rec.activity_bucket;
    g_ae_line_tbl(g_ae_line_ctr).ref_account_class                :=  p_ae_line_rec.ref_account_class;
    --}

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.Assign_Ael_Elements()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.Assign_Ael_Elements');
     END IF;
     RAISE;

END Assign_Ael_Elements;

/* =======================================================================
 | PROCEDURE initialize_global_variables
 |
 | DESCRIPTION
 |      This procedure detects the event that took place on the BR
 |      when accounting engine was called.
 |
 | PARAMETERS
 |      p_trh_rec     Transaction history record
 |
 | 02/11/05     VCRISOST        Bug 4178326 : if within the same window
 |                              session user Recalls, then Unpays a BR
 |                              accounting entries are incorrect for
 |                              UNPAID event
 |
 * ======================================================================*/
PROCEDURE initialize_global_variables(p_trh_rec IN ar_transaction_history%ROWTYPE) IS

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.initialize_global_variables()+');
  END IF;

 /*-----------------------------+
  | Fetch the previous status   |
  +-----------------------------*/
  g_previous_status := trx_history_status(p_trh_rec.prv_trx_history_id);

  IF p_trh_rec.event = C_MATURITY_DATE THEN

   /*-------------------------------------------------------------+
    | Bills Receivable transaction maturity date event occurred   |
    +-------------------------------------------------------------*/
    g_event := C_MATURITY_DATE;

  ELSIF p_trh_rec.event = C_RECALLED THEN

   /*-----------------+
    | BR was recalled |
    +-----------------*/
    g_event := C_RECALLED;

  ELSIF p_trh_rec.status = C_UNPAID THEN

   /*----------------------------------------------------------+
    | BR UNPAID, if the previous status was PENDING_REMITTANCE |
    | then no deferred tax has been moved, so it is not backed |
    | out. This information is used in the main routine to     |
    | decide whether to move the deferred tax or not           |
    +----------------------------------------------------------*/
    IF g_previous_status <> C_PENDING_REMITTANCE THEN

      g_event := C_UNPAID;
    ELSE

      -- Bug 4178326 : need to initialize this back to NULL, otherwise
      -- code uses the g_event from previous action and accounting is
      -- created incorrectly
      g_event := NULL;

    END IF;

  ELSE
    g_event := NULL;
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.initialize_global_variables()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.initialize_global_variables');
       END IF;
       RAISE;

END initialize_global_variables;

/* =======================================================================
 | PROCEDURE trx_history_status
 |
 | DESCRIPTION
 |      This function returns the status of the BR
 |
 | PARAMETERS
 |      p_transaction_history_id     Transaction history ID
 * ======================================================================*/
FUNCTION trx_history_status(p_transaction_history_id ar_transaction_history.transaction_history_id%TYPE) RETURN VARCHAR2 IS

 /*-----------------------------+
  | Cursor to return the status |
  +-----------------------------*/
  CURSOR history_status_cur IS
    SELECT status
    FROM ar_transaction_history
    WHERE transaction_history_id = p_transaction_history_id;

 history_status_rec history_status_cur%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.trx_history_status()');
  END IF;

  /*------------------+
   | fetch the status |
   +------------------*/
   OPEN history_status_cur;
   FETCH history_status_cur INTO history_status_rec;

  /*---------------------------------+
   | If status not found return NULL |
   +---------------------------------*/
   IF history_status_cur%NOTFOUND THEN
     CLOSE history_status_cur;
     RETURN NULL;
   END IF;

   CLOSE history_status_cur;

   RETURN history_status_rec.status;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.trx_history_status');
       END IF;
       RAISE;

END trx_history_status;

/* =======================================================================
 | PROCEDURE reverse_single_dist_line
 |
 | DESCRIPTION
 |      This procedure reverses single distribution record given as parameter.
 |
 | PARAMETERS
 |      p_dist_rec     Distribution record
 * ======================================================================*/
PROCEDURE reverse_single_dist_line(p_dist_rec ar_distributions%ROWTYPE) IS
  l_ael_line_rec         ae_line_rec_type;
  l_ael_empty_line_rec   ae_line_rec_type;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_single_dist_line()+');
  END IF;

 /*---------------------------+
  | Initialize build record   |
  +---------------------------*/
  l_ael_line_rec := l_ael_empty_line_rec ;

 /*----------------------+
  | Fill in the record   |
  +----------------------*/
  l_ael_line_rec.ae_line_type               := p_dist_rec.source_type;
  l_ael_line_rec.ae_line_type_secondary     := p_dist_rec.source_type_secondary;
  l_ael_line_rec.source_id                  := g_ae_doc_rec.source_id;
  l_ael_line_rec.source_table               := g_ae_doc_rec.source_table;
  l_ael_line_rec.source_id_secondary        := p_dist_rec.source_id_secondary;
  l_ael_line_rec.source_table_secondary     := p_dist_rec.source_table_secondary;
  l_ael_line_rec.account                    := p_dist_rec.code_combination_id;
  l_ael_line_rec.reversed_source_id         := NULL; /* used only for Receipt App by MRC */

 /*-----------------------------------------+
  | For reversals swap debits and credits   |
  +-----------------------------------------*/
  l_ael_line_rec.entered_cr   := p_dist_rec.amount_dr;
  l_ael_line_rec.accounted_cr := p_dist_rec.acctd_amount_dr;

  l_ael_line_rec.entered_dr   := p_dist_rec.amount_cr;
  l_ael_line_rec.accounted_dr := p_dist_rec.acctd_amount_cr;

  l_ael_line_rec.taxable_entered_cr    := p_dist_rec.taxable_entered_dr;
  l_ael_line_rec.taxable_accounted_cr  := p_dist_rec.taxable_accounted_dr;

  l_ael_line_rec.taxable_entered_dr    := p_dist_rec.taxable_entered_cr;
  l_ael_line_rec.taxable_accounted_dr  := p_dist_rec.taxable_accounted_cr;

  l_ael_line_rec.currency_code               := p_dist_rec.currency_code;
  l_ael_line_rec.currency_conversion_rate    := p_dist_rec.currency_conversion_rate;
  l_ael_line_rec.currency_conversion_type    := p_dist_rec.currency_conversion_type;
  l_ael_line_rec.currency_conversion_date    := p_dist_rec.currency_conversion_date;
  l_ael_line_rec.third_party_id              := p_dist_rec.third_party_id;
  l_ael_line_rec.third_party_sub_id          := p_dist_rec.third_party_sub_id;
  l_ael_line_rec.tax_code_id                 := p_dist_rec.tax_code_id;
  l_ael_line_rec.tax_group_code_id           := p_dist_rec.tax_group_code_id;
  l_ael_line_rec.location_segment_id         := p_dist_rec.location_segment_id;
  l_ael_line_rec.tax_link_id                 := p_dist_rec.tax_link_id;
  --{BUG#2979254
  l_ael_line_rec.ref_customer_trx_line_id    := p_dist_rec.ref_customer_trx_line_id;
  l_ael_line_rec.ref_cust_trx_line_gl_dist_id := p_dist_rec.ref_cust_trx_line_gl_dist_id;
  l_ael_line_rec.ref_line_id                 := p_dist_rec.ref_line_id;
  --}
  --{BUG#3377004
  l_ael_line_rec.from_amount_dr              := p_dist_rec.from_amount_cr;
  l_ael_line_rec.from_amount_cr              := p_dist_rec.from_amount_dr;
  l_ael_line_rec.from_acctd_amount_dr        := p_dist_rec.from_acctd_amount_cr;
  l_ael_line_rec.from_acctd_amount_cr        := p_dist_rec.from_acctd_amount_dr;
  --}

 /*---------------------------+
  | Assign AEL for Reversal   |
  +---------------------------*/
  Assign_Ael_Elements( p_ae_line_rec        => l_ael_line_rec );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_single_dist_line()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.reverse_single_dist_line');
       END IF;
       RAISE;

END reverse_single_dist_line;

/* =======================================================================
 | PROCEDURE reverse_old_acct
 |
 | DESCRIPTION
 |      This procedure reverses previous accounting. This is used
 |      when reclassification reverses the old accounting.
 |
 | PARAMETERS
 |      p_transaction_history_id     Transaction history ID
 |      p_ps_id                      Payment Schedule ID
 * ======================================================================*/
PROCEDURE reverse_old_acct(p_transaction_history_id IN ar_transaction_history.transaction_history_id%TYPE,
                           p_ps_id                  IN ar_payment_schedules.payment_schedule_id%TYPE) IS

 /*----------------------------------------------------------+
  | This is used in deciding which distribution record       |
  | to reverse and whether the amount has changed since last |
  | accounting due to ie an receipt application.             |
  +----------------------------------------------------------*/

  --MRC TRigger Replacement:  Enumerate Columns and select currency
  --sensitive data.
  CURSOR ps_cur IS
   select ps.amount_due_original,
          ps.amount_due_remaining,
--{BUG4301323
--          DECODE(g_ae_sys_rec.sob_type, 'P',
--                    ps.acctd_amount_due_remaining,
--                    arp_mrc_acct_main.get_ps_entity_data(
--                      ps.payment_schedule_id,
--                      g_ae_sys_rec.set_of_books_id)) acctd_amount_due_remaining
          ps.acctd_amount_due_remaining    acctd_amount_due_remaining
--}
   from ar_payment_schedules ps
   where ps.payment_schedule_id = p_ps_id;

 l_ard_rec                     ar_distributions%ROWTYPE;
 l_prev_posted_trh_rec         ar_transaction_history%ROWTYPE;
 l_ps_rec                      ps_cur%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_old_acct()+');
  END IF;

 /*--------------------------------------+
  | Find previous posted history record  |
  +--------------------------------------*/
  find_prev_posted_hist_record(g_ae_doc_rec.source_id,l_prev_posted_trh_rec);

 /*-------------------------------------------------------------------+
  | Fetch the PS. This is used in deciding which distribution record  |
  | to reverse and whether the amount has changed since last          |
  | accounting due to ie an receipt application.                      |
  +-------------------------------------------------------------------*/
  OPEN ps_cur;
  FETCH ps_cur INTO l_ps_rec;
  CLOSE ps_cur;

 /*-------------------------------------------------------------------+
  | Find the accounting for the previous posted history record        |
  +-------------------------------------------------------------------*/
  find_rec_dist_record(l_prev_posted_trh_rec.transaction_history_id, SIGN(l_ps_rec.amount_due_original),l_ard_rec );

 /*-------------------------------------------------------------------+
  | If the amount remaining has changed after the previous accounting |
  | use the amount due remaining as the amount accounted              |
  +-------------------------------------------------------------------*/
  IF NVL(l_ps_rec.amount_due_remaining,0) <> 0 THEN

    IF (SIGN(l_ps_rec.amount_due_original) > 0) THEN

      IF ((nvl(l_ard_rec.AMOUNT_DR,0) <> NVL(l_ps_rec.amount_due_remaining,0)) OR (nvl(l_ard_rec.ACCTD_AMOUNT_DR,0) <> NVL(l_ps_rec.acctd_amount_due_remaining,0))) THEN
        l_ard_rec.AMOUNT_DR := l_ps_rec.amount_due_remaining;
        l_ard_rec.ACCTD_AMOUNT_DR := l_ps_rec.acctd_amount_due_remaining;
      END IF;

    ELSIF (SIGN(l_ps_rec.amount_due_original) < 0) THEN
      IF  ((nvl(l_ard_rec.AMOUNT_CR,0) <> NVL(l_ps_rec.amount_due_remaining,0)) OR (nvl(l_ard_rec.ACCTD_AMOUNT_CR,0) <> NVL(l_ps_rec.acctd_amount_due_remaining,0))) THEN
        l_ard_rec.AMOUNT_CR := l_ps_rec.amount_due_remaining;
        l_ard_rec.ACCTD_AMOUNT_CR := l_ps_rec.acctd_amount_due_remaining;
      END IF;
    END IF;
  ELSE
   /*------------------------------------------------------+
    | BR was cancelled, we use the amounts on the previous |
    | record (no activities exist on cancelled BR), so here|
    | we leave the amounts as is and do nothing            |
    +------------------------------------------------------*/
    NULL;
  END IF;

 /*---------------------------------------------------------------------+
  | Reverse the accounting for the previous posted history record       |
  +---------------------------------------------------------------------*/
  reverse_single_dist_line(l_ard_rec);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_old_acct()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.reverse_old_acct');
       END IF;
       RAISE;

END reverse_old_acct;

/* =======================================================================
 | PROCEDURE find_prev_posted_hist_record
 |
 | DESCRIPTION
 |      This function finds the previous posted history record. If we are
 |      not specifically looking for MATURITY_DATE events (by giving value
 |      MATURITY_DATE as parameter p_event) posted history records with
 |      MATURITY_DATE event are skipped since they have only deferred tax
 |      accounting. If status is given as parameter the function only looks
 |      at given statuses.
 |
 | PARAMETERS
 |      p_transaction_history_id     Transaction history ID
 |      p_status                     Transaction history status
 |      p_event                      Transaction history event
 * ======================================================================*/
PROCEDURE find_prev_posted_hist_record(p_transaction_history_id IN  ar_transaction_history.transaction_history_id%TYPE,
                                       p_trh_rec                OUT NOCOPY ar_transaction_history%ROWTYPE,
                                       p_status                 IN  ar_transaction_history.status%TYPE DEFAULT NULL,
                                       p_event                  IN  ar_transaction_history.event%TYPE DEFAULT NULL) IS

 /*-----------------------------------------------------+
  | Cursor to return the previous posted history record |
  | The cursor returns path of all posted records from  |
  | the current one to the first posted record. If      |
  | status and /or evenrt was given as parameter the    |
  | cursor only looks for specific status and/or event. |
  +-----------------------------------------------------*/
  CURSOR history_cur IS
    SELECT *
    FROM ar_transaction_history
    WHERE postable_flag = 'Y'
    AND status = NVL(p_status,status)
    AND event  = NVL(p_event,event)
    CONNECT BY PRIOR prv_trx_history_id = transaction_history_id
    START WITH transaction_history_id = p_transaction_history_id
    ORDER BY transaction_history_id desc;

 history_rec              history_cur%ROWTYPE;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.find_prev_posted_hist_record()');
 END IF;

 /*--------------------------+
  | Fetch the current record |
  +--------------------------*/
  OPEN history_cur;
  FETCH history_cur INTO history_rec;

 /*---------------------------------------------+
  | Loop through previous posted records in the |
  | reverse order they were created. Exit when  |
  | first posted record, which is not           |
  | MATURITY_DATE event is found                |
  +---------------------------------------------*/
  WHILE history_cur%FOUND LOOP

    FETCH history_cur INTO history_rec;

   /*----------------------------------+
    | Check whether we are looking for |
    | MATURITY_DATE event or not       |
    +----------------------------------*/

    IF p_event = C_MATURITY_DATE THEN

     /*-------------------------------------+
      | Exit with last posted MATURITY_DATE |
      | transaction history record          |
      +-------------------------------------*/
      IF history_rec.event = C_MATURITY_DATE THEN
        EXIT;
      END IF;

    ELSE

     /*-----------------------------------------------------+
      | In all other cases MATURITY_DATE events are skipped |
      | since they have only deferred tax related to them   |
      +-----------------------------------------------------*/
      IF history_rec.event <> C_MATURITY_DATE THEN
        EXIT;
      END IF;

    END IF;
  END LOOP;

  CLOSE history_cur;

  IF history_rec.transaction_history_id IS NULL THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('find_prev_posted_hist_record: ' || 'Previous posted history record cannot be found.');
    END IF;
    RAISE NO_DATA_FOUND;
  END IF;

  p_trh_rec := history_rec;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.find_prev_posted_hist_record');
       END IF;
       RAISE;

END find_prev_posted_hist_record;

/* =======================================================================
 | PROCEDURE find_rec_dist_record
 |
 | DESCRIPTION
 |      This procedure find receivable accounting on a
 |      transaction history record.
 |
 | PARAMETERS
 |      p_transaction_history_id     Transaction history ID
 |      p_sign                       Sign of the original BR amount, used to decide
 |                                     whether to select debut or credit amount
 |      p_dist_rec                   Distribution record
 * ======================================================================*/
PROCEDURE find_rec_dist_record(p_transaction_history_id IN  ar_transaction_history.transaction_history_id%TYPE,
                               p_sign                   IN  NUMBER,
                               p_dist_rec               OUT NOCOPY ar_distributions%ROWTYPE) IS

 /*-----------------------------------------------------+
  | Cursor to return the accounting record for          |
  | given transaction history record. This is used to   |
  | in reclassification reversing the                   |
  | receivable accounting.                              |
  +-----------------------------------------------------*/

  -- MRC Trigger Replacement:  Enumerated cursor and added union for
  -- Reporting SOB data
  CURSOR distribution_cur IS
    select line_id,
           source_id,
           source_table,
           source_type,
           code_combination_id,
           amount_dr,
           amount_cr,
           acctd_amount_dr,
           acctd_amount_cr,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           org_id,
           source_table_secondary,
           source_id_secondary,
           currency_code,
           currency_conversion_rate,
           currency_conversion_type,
           currency_conversion_date,
           taxable_entered_dr,
           taxable_entered_cr,
           taxable_accounted_dr,
           taxable_accounted_cr,
           tax_link_id,
           third_party_id,
           third_party_sub_id,
           reversed_source_id,
           tax_code_id,
           location_segment_id,
           source_type_secondary,
           tax_group_code_id,
           --{BUG#2979254
           ref_customer_trx_line_id,
           ref_cust_trx_line_gl_dist_id,
           ref_line_id,
           from_amount_dr,
           from_amount_cr,
           from_acctd_amount_dr,
           from_acctd_amount_cr
           --}
    from ar_distributions
    where NVL(g_ae_sys_rec.sob_type,'P') = 'P'
      and source_id = p_transaction_history_id
      and source_table = C_TH
      and source_type in (C_REC,C_FACTOR,C_REMITTANCE,C_UNPAIDREC)
      AND source_id_secondary is null
      AND source_table_secondary is null
      AND source_type_secondary is null
      and   (((sign(p_sign) > 0)
             and ((nvl(AMOUNT_DR,0) <> 0) OR (nvl(ACCTD_AMOUNT_DR,0) <> 0))
             and (nvl(AMOUNT_CR,0) = 0) and (nvl(ACCTD_AMOUNT_CR,0) = 0))
        OR ((sign(p_sign) < 0)
             and ((nvl(AMOUNT_CR,0) <> 0) OR (nvl(ACCTD_AMOUNT_CR,0) <> 0))
             and (nvl(AMOUNT_DR,0) = 0) and (nvl(ACCTD_AMOUNT_DR,0) = 0)))
   order by line_id desc;
/*BUG4301323
   UNION
    select line_id,
           source_id,
           source_table,
           source_type,
           code_combination_id,
           amount_dr,
           amount_cr,
           acctd_amount_dr,
           acctd_amount_cr,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           org_id,
           source_table_secondary,
           source_id_secondary,
           currency_code,
           currency_conversion_rate,
           currency_conversion_type,
           currency_conversion_date,
           taxable_entered_dr,
           taxable_entered_cr,
           taxable_accounted_dr,
           taxable_accounted_cr,
           tax_link_id,
           third_party_id,
           third_party_sub_id,
           reversed_source_id,
           tax_code_id,
           location_segment_id,
           source_type_secondary,
           tax_group_code_id,
           --{BUG#2979254
           ref_customer_trx_line_id,
           ref_cust_trx_line_gl_dist_id,
           ref_line_id,
           from_amount_dr,
           from_amount_cr,
           from_acctd_amount_dr,
           from_acctd_amount_cr
           --}
    from ar_mc_distributions_all
    where g_ae_sys_rec.sob_type = 'R'
      and set_of_books_id = g_ae_sys_rec.set_of_books_id
      and source_id = p_transaction_history_id
      and source_table = C_TH
      and source_type in (C_REC,C_FACTOR,C_REMITTANCE,C_UNPAIDREC)
      AND source_id_secondary is null
      AND source_table_secondary is null
      AND source_type_secondary is null
      and   (((sign(p_sign) > 0)
             and ((nvl(AMOUNT_DR,0) <> 0) OR (nvl(ACCTD_AMOUNT_DR,0) <> 0))
             and (nvl(AMOUNT_CR,0) = 0) and (nvl(ACCTD_AMOUNT_CR,0) = 0))
        OR ((sign(p_sign) < 0)
             and ((nvl(AMOUNT_CR,0) <> 0) OR (nvl(ACCTD_AMOUNT_CR,0) <> 0))
             and (nvl(AMOUNT_DR,0) = 0) and (nvl(ACCTD_AMOUNT_DR,0) = 0)))
   order by line_id desc;
*/
 distribution_rec ar_distributions%ROWTYPE;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.find_rec_dist_record()+');
 END IF;

 /*-----------------------------------+
  | Fetch the accounting record       |
  +-----------------------------------*/
  --{HYUDETUPT change the structure of this code so that it does not break everytime schema changes
  OPEN distribution_cur;
  FETCH distribution_cur INTO
           distribution_rec.line_id,
           distribution_rec.source_id,
           distribution_rec.source_table,
           distribution_rec.source_type,
           distribution_rec.code_combination_id,
           distribution_rec.amount_dr,
           distribution_rec.amount_cr,
           distribution_rec.acctd_amount_dr,
           distribution_rec.acctd_amount_cr,
           distribution_rec.creation_date,
           distribution_rec.created_by,
           distribution_rec.last_updated_by,
           distribution_rec.last_update_date,
           distribution_rec.last_update_login,
           distribution_rec.org_id,
           distribution_rec.source_table_secondary,
           distribution_rec.source_id_secondary,
           distribution_rec.currency_code,
           distribution_rec.currency_conversion_rate,
           distribution_rec.currency_conversion_type,
           distribution_rec.currency_conversion_date,
           distribution_rec.taxable_entered_dr,
           distribution_rec.taxable_entered_cr,
           distribution_rec.taxable_accounted_dr,
           distribution_rec.taxable_accounted_cr,
           distribution_rec.tax_link_id,
           distribution_rec.third_party_id,
           distribution_rec.third_party_sub_id,
           distribution_rec.reversed_source_id,
           distribution_rec.tax_code_id,
           distribution_rec.location_segment_id,
           distribution_rec.source_type_secondary,
           distribution_rec.tax_group_code_id,
           --{BUG#2979254
           distribution_rec.ref_customer_trx_line_id,
           distribution_rec.ref_cust_trx_line_gl_dist_id,
           distribution_rec.ref_line_id,
           distribution_rec.from_amount_dr,
           distribution_rec.from_amount_cr,
           distribution_rec.from_acctd_amount_dr,
           distribution_rec.from_acctd_amount_cr;

  IF distribution_cur%NOTFOUND THEN

    CLOSE distribution_cur;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('find_rec_dist_record: ' || 'Receivable accounting record cannot be found.');
    END IF;
    APP_EXCEPTION.raise_exception;

  END IF;

  IF distribution_cur%ISOPEN THEN
    CLOSE distribution_cur;
  END IF;
  --}

 /*------------------------------+
  | Return the accounting record |
  +------------------------------*/
  p_dist_rec := distribution_rec;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.find_rec_dist_record()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.find_rec_dist_record');
       END IF;
       RAISE;

END find_rec_dist_record;

/* =======================================================================
 | PROCEDURE find_exchanged_trx_acct
 |
 | DESCRIPTION
 |      This function finds the original history record with stautus
 |      PENDING_REMITTANCE, which has the accounting for the exchanged
 |      transactions under it.
 |
 | PARAMETERS
 |      p_transaction_history_id     Transaction history ID
 * ======================================================================*/
FUNCTION find_exchanged_trx_acct(p_transaction_history_id ar_transaction_history.transaction_history_id%TYPE) RETURN NUMBER IS

 l_prev_posted_history_id       ar_transaction_history.transaction_history_id%TYPE;
 l_prev_posted_trh_rec          ar_transaction_history%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.find_exchanged_trx_acct()');
  END IF;

 /*-------------------------------------------------------------------+
  | Store the current transaction history record id in local variable |
  | This is used as parameter in the loop.                            |
  +-------------------------------------------------------------------*/
  l_prev_posted_history_id := p_transaction_history_id;

  LOOP

   /*-------------------------------------------------------+
    | Find the previous posted transaction history record   |
    | with status PRENDING_REMITTANCE.                      |
    +-------------------------------------------------------*/
    find_prev_posted_hist_record(l_prev_posted_history_id,l_prev_posted_trh_rec,C_PENDING_REMITTANCE);

   /*-------------------------------------------------------+
    | Check whether the previous status for the record is   |
    | INCOMPLETE or PENDING_ACCEPTANCE. If so this record   |
    | has the exchanged transaction accounting under it so  |
    | exit the loop, otherwise loop to next                 |
    | PENDING_REMITTANCE record                             |
    +-------------------------------------------------------*/
    IF trx_history_status(l_prev_posted_trh_rec.prv_trx_history_id) in (C_INCOMPLETE,C_PENDING_ACCEPTANCE)
       OR l_prev_posted_trh_rec.transaction_history_id IS NULL THEN

      EXIT;

    END IF;

    l_prev_posted_history_id := l_prev_posted_trh_rec.transaction_history_id;

  END LOOP;

  IF l_prev_posted_trh_rec.transaction_history_id IS NULL THEN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('find_exchanged_trx_acct: ' || 'Previous transaction history record with exchange accountin cannot be found.');
    END IF;
    APP_EXCEPTION.raise_exception;

  END IF;

  RETURN l_prev_posted_trh_rec.transaction_history_id;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.find_exchanged_trx_acct');
       END IF;
       RAISE;

END find_exchanged_trx_acct;

/* =======================================================================
 | PROCEDURE reverse_exchanged_trx_acct
 |
 | DESCRIPTION
 |      This procedure reverses the accounting created for the exchanged
 |      transactions when BR was completed (to status PENDING_REMITTANCE).
 |
 | PARAMETERS
 |      p_transaction_history_id     Transaction history ID
 * ======================================================================*/
PROCEDURE reverse_exchanged_trx_acct(p_transaction_history_id ar_transaction_history.transaction_history_id%TYPE) IS

 /*--------------------------------------------------+
  | Cursor to return the accounting for exchanged    |
  | transactions. The accounting for exchanged       |
  | transactions has the secondary columns populated |
  +--------------------------------------------------*/

  -- MRC Trigger Replacement:  Enumerated Columns and added UNION to
  -- select currency sensitive data.

  CURSOR last_exchange_accounting_cur(l_transaction_history_id ar_transaction_history.transaction_history_id%TYPE) IS
    select line_id,
           source_id,
           source_table,
           source_type,
           code_combination_id,
           amount_dr,
           amount_cr,
           acctd_amount_dr,
           acctd_amount_cr,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           org_id,
           source_table_secondary,
           source_id_secondary,
           currency_code,
           currency_conversion_rate,
           currency_conversion_type,
           currency_conversion_date,
           taxable_entered_dr,
           taxable_entered_cr,
           taxable_accounted_dr,
           taxable_accounted_cr,
           tax_link_id,
           third_party_id,
           third_party_sub_id,
           reversed_source_id,
           tax_code_id,
           location_segment_id,
           source_type_secondary,
           tax_group_code_id,
           --{BUG#2979254
           ref_customer_trx_line_id,
           ref_cust_trx_line_gl_dist_id,
           ref_line_id,
           from_amount_dr,
           from_amount_cr,
           from_acctd_amount_dr,
           from_acctd_amount_cr
           --}
    FROM ar_distributions
    WHERE NVL(g_ae_sys_rec.sob_type,'P') = 'P'
    AND source_id = l_transaction_history_id
    AND source_table = C_TH
    AND source_type =  C_REC
    AND source_id_secondary is not null
    AND source_table_secondary = C_CTL
    AND source_type_secondary = C_ASSIGNMENT
    ORDER BY line_id ASC;
/*BUG4301323
  UNION
    select line_id,
           source_id,
           source_table,
           source_type,
           code_combination_id,
           amount_dr,
           amount_cr,
           acctd_amount_dr,
           acctd_amount_cr,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           org_id,
           source_table_secondary,
           source_id_secondary,
           currency_code,
           currency_conversion_rate,
           currency_conversion_type,
           currency_conversion_date,
           taxable_entered_dr,
           taxable_entered_cr,
           taxable_accounted_dr,
           taxable_accounted_cr,
           tax_link_id,
           third_party_id,
           third_party_sub_id,
           reversed_source_id,
           tax_code_id,
           location_segment_id,
           source_type_secondary,
           tax_group_code_id,
           --{BUG#2979254
           ref_customer_trx_line_id,
           ref_cust_trx_line_gl_dist_id,
           ref_line_id,
           from_amount_dr,
           from_amount_cr,
           from_acctd_amount_dr,
           from_acctd_amount_cr
           --}
    FROM ar_mc_distributions_all
    WHERE g_ae_sys_rec.sob_type = 'R'
    AND set_of_books_id = g_ae_sys_rec.set_of_books_id
    AND source_id = l_transaction_history_id
    AND source_table = C_TH
    AND source_type =  C_REC
    AND source_id_secondary is not null
    AND source_table_secondary = C_CTL
    AND source_type_secondary = C_ASSIGNMENT
    ORDER BY line_id ASC;
*/
 last_exchange_accounting_rec ar_distributions%ROWTYPE;
 l_last_exchanged_history_id ar_transaction_history.transaction_history_id%TYPE;

BEGIN
 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_exchanged_trx_acct()+');
 END IF;

 /*-------------------------------------------------------+
  | Find the original posted transaction history record   |
  | with status PENDING_REMITTANCE.                       |
  +-------------------------------------------------------*/
  l_last_exchanged_history_id := find_exchanged_trx_acct(p_transaction_history_id);

 /*-------------------------------------------------------+
  | Loop through the exchanged transaction accounting     |
  | under the transaction history record                  |
  +-------------------------------------------------------*/
  OPEN last_exchange_accounting_cur(l_last_exchanged_history_id);
  LOOP
     FETCH last_exchange_accounting_cur INTO
--      FOR last_exchange_accounting_rec IN last_exchange_accounting_cur(l_last_exchanged_history_id) LOOP
           last_exchange_accounting_rec.line_id,
           last_exchange_accounting_rec.source_id,
           last_exchange_accounting_rec.source_table,
           last_exchange_accounting_rec.source_type,
           last_exchange_accounting_rec.code_combination_id,
           last_exchange_accounting_rec.amount_dr,
           last_exchange_accounting_rec.amount_cr,
           last_exchange_accounting_rec.acctd_amount_dr,
           last_exchange_accounting_rec.acctd_amount_cr,
           last_exchange_accounting_rec.creation_date,
           last_exchange_accounting_rec.created_by,
           last_exchange_accounting_rec.last_updated_by,
           last_exchange_accounting_rec.last_update_date,
           last_exchange_accounting_rec.last_update_login,
           last_exchange_accounting_rec.org_id,
           last_exchange_accounting_rec.source_table_secondary,
           last_exchange_accounting_rec.source_id_secondary,
           last_exchange_accounting_rec.currency_code,
           last_exchange_accounting_rec.currency_conversion_rate,
           last_exchange_accounting_rec.currency_conversion_type,
           last_exchange_accounting_rec.currency_conversion_date,
           last_exchange_accounting_rec.taxable_entered_dr,
           last_exchange_accounting_rec.taxable_entered_cr,
           last_exchange_accounting_rec.taxable_accounted_dr,
           last_exchange_accounting_rec.taxable_accounted_cr,
           last_exchange_accounting_rec.tax_link_id,
           last_exchange_accounting_rec.third_party_id,
           last_exchange_accounting_rec.third_party_sub_id,
           last_exchange_accounting_rec.reversed_source_id,
           last_exchange_accounting_rec.tax_code_id,
           last_exchange_accounting_rec.location_segment_id,
           last_exchange_accounting_rec.source_type_secondary,
           last_exchange_accounting_rec.tax_group_code_id,
           --{BUG#2979254
           last_exchange_accounting_rec.ref_customer_trx_line_id,
           last_exchange_accounting_rec.ref_cust_trx_line_gl_dist_id,
           last_exchange_accounting_rec.ref_line_id,
           last_exchange_accounting_rec.from_amount_dr,
           last_exchange_accounting_rec.from_amount_cr,
           last_exchange_accounting_rec.from_acctd_amount_dr,
           last_exchange_accounting_rec.from_acctd_amount_cr;

      EXIT WHEN last_exchange_accounting_cur%NOTFOUND;
   /*--------------------------------------------------+
    | Reverse the exchanged transaction accounting     |
    +--------------------------------------------------*/
    reverse_single_dist_line(last_exchange_accounting_rec);

  END LOOP;
  CLOSE last_exchange_accounting_cur;

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_exchanged_trx_acct()-');
 END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.reverse_exchanged_trx_acct');
       END IF;
       RAISE;
END reverse_exchanged_trx_acct;

/* =======================================================================
 | PROCEDURE create_exchanged_trx_acct
 |
 | DESCRIPTION
 |      This procedure creates the accounting for the exchanged
 |      transactions when BR is completed (to status PENDING_REMITTANCE).
 |
 | PARAMETERS
 |      p_customer_trx_id     Transaction ID
 * ======================================================================*/
PROCEDURE create_exchanged_trx_acct
(p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE,
 -- HYUDETDIST
 p_ae_rule_rec     IN ae_rule_rec_type)
 --}
 IS
 /*--------------------------------------------------+
  | Cursor to return all rows exchanged on the BR.   |
  +--------------------------------------------------*/

  -- MRC Trigger Replacement:  select currency sensitive data.
  CURSOR all_exchanges_cur(l_customer_trx_id ra_customer_trx.customer_trx_id%TYPE) IS
    SELECT ctl.br_ref_customer_trx_id          source_trx_id,
           ctl.br_ref_payment_schedule_id      source_ps_id,
           ctl.customer_trx_line_id,
           adj.amount       adjustment_amount,
--{BUG4301323
--           decode(g_ae_sys_rec.sob_type, 'P',
--                  adj.acctd_amount,
--                  arp_mrc_acct_main.get_adj_entity_data(
--                     adj.adjustment_id,
--                     g_ae_sys_rec.set_of_books_id))  adjustment_acctd_amount,
           adj.acctd_amount    adjustment_acctd_amount,
--}
           --{HYUDETDIST
           adj.adjustment_id                 adjustment_id,
           adj.line_adjusted                 adjustment_line_amount,
           adj.freight_adjusted              adjustment_freight_amount,
           adj.tax_adjusted                  adjustment_tax_amount,
           adj.receivables_charges_adjusted  adjustment_charges_amount,
           adj.payment_schedule_id           adjustment_ps_id,
           adj.type                          adjustment_type,
           --}
--{BUG#5016132
           adj.receivables_trx_id            adj_rec_trx_id,
           adj.adjustment_type               adj_adj_type,
--}
           assignment_ps.class,
           assignment_ps.customer_id          assignment_customer_id,
           assignment_ps.customer_site_use_id assignment_site_use_id,
           assignment_ps.amount_due_original  assignment_amount_due_original,
           ps.invoice_currency_code,
--{BUG4301323
--           decode(g_ae_sys_rec.sob_type, 'P',
--                  ps.exchange_rate,
--                  arp_mrc_acct_main.get_ps_exg_rate(
--                        ps.payment_schedule_id,
--                        g_ae_sys_rec.set_of_books_id)) exchange_rate,
           ps.exchange_rate              exchange_rate,
--}
--{BUG4301323
--           decode(g_ae_sys_rec.sob_type, 'P',
--                  ps.exchange_rate_type,
--                  arp_mrc_acct_main.get_ps_exg_rate_type(
--                        ps.payment_schedule_id,
--                        g_ae_sys_rec.set_of_books_id)) exchange_rate_type,
           ps.exchange_rate_type          exchange_rate_type,
--}
--{BUG4301323
--           decode(g_ae_sys_rec.sob_type, 'P',
--                  ps.exchange_date,
--                  arp_mrc_acct_main.get_ps_exg_date(
--                        ps.payment_schedule_id,
--                        g_ae_sys_rec.set_of_books_id)) exchange_date
            ps.exchange_date              exchange_date
--}
    FROM ra_customer_trx_lines ctl,
         ar_payment_schedules ps,
         ar_payment_schedules assignment_ps,
         ar_adjustments adj
    WHERE assignment_ps.payment_schedule_id = ctl.br_ref_payment_schedule_id
    AND   ps.customer_trx_id                = ctl.customer_trx_id
    AND   adj.adjustment_id                 = ctl.br_adjustment_id
    /* Bug 8558443 */
    AND   assignment_ps.class <> 'BR'
    AND   ctl.customer_trx_line_id IN (
                 SELECT distinct ctl_in.customer_trx_line_id
                 FROM ra_customer_trx_lines ctl_in
                 WHERE ctl_in.br_ref_customer_trx_id is not null
                   START WITH ctl_in.customer_trx_id = l_customer_trx_id
                   CONNECT BY PRIOR ctl_in.br_ref_customer_trx_id = ctl_in.customer_trx_id);

  CURSOR c_trx(p_customer_trx_id  IN NUMBER)
  IS
  SELECT * FROM ra_customer_trx
  WHERE customer_trx_id = p_customer_trx_id;


 /*--------------------------------------------------+
  | Cursor for the accounting on normal transactions |
  | from table ra_cust_trx_line_gl_dist              |
  +--------------------------------------------------*/
  CURSOR TRX_exchange_cur(l_customer_trx_id ra_customer_trx.customer_trx_id%TYPE) IS
    SELECT dist.code_combination_id
    FROM   ra_cust_trx_line_gl_dist dist
    WHERE  dist.customer_trx_id = l_customer_trx_id
    AND    dist.account_class = C_REC
    AND    dist.latest_rec_flag = 'Y';

 /*--------------------------------------------------+
  | Cursor for the currenct accounted record of the  |
  | exchanged BR                                     |
  +--------------------------------------------------*/
  CURSOR BR_exchange_cur(l_customer_trx_id ra_customer_trx.customer_trx_id%TYPE) IS
    SELECT th.transaction_history_id
    FROM   ar_transaction_history th
    WHERE  th.customer_trx_id = l_customer_trx_id
    AND    th.current_accounted_flag = 'Y';

  all_exchanges_rec all_exchanges_cur%ROWTYPE;
  TRX_exchange_rec TRX_exchange_cur%ROWTYPE;
  BR_exchange_rec BR_exchange_cur%ROWTYPE;
  BR_dist_rec ar_distributions%ROWTYPE;

  l_ael_line_rec         ae_line_rec_type;
  l_ael_empty_line_rec   ae_line_rec_type;
  --{HYUDETDIST
  l_adj_rec              ar_adjustments%ROWTYPE;
  l_cust_trx_rec         ra_customer_trx%ROWTYPE;
  l_app_rec              ar_receivable_applications%ROWTYPE;
  l_ae_ctr               NUMBER := 0;
  l_ae_line_tbl          ae_line_tbl_type;
  l_ae_empty_line_tbl    ae_line_tbl_type;
  l_current_trx_id       NUMBER := -9999;
  --}

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.create_exchanged_trx_acct()+');
  END IF;


 /*--------------------------------------------------+
  | Loop through all transactions exchanged for BR   |
  +--------------------------------------------------*/
  FOR all_exchanges_rec IN all_exchanges_cur(p_customer_trx_id) LOOP

    --{HYUDETDIST
    --Get the shadow adjustment data
    l_adj_rec.customer_trx_id  := all_exchanges_rec.source_trx_id;
    l_adj_rec.amount           := all_exchanges_rec.adjustment_amount;
    l_adj_rec.acctd_amount     := all_exchanges_rec.adjustment_acctd_amount;
    l_adj_rec.line_adjusted    := all_exchanges_rec.adjustment_line_amount;
    l_adj_rec.freight_adjusted := all_exchanges_rec.adjustment_freight_amount;
    l_adj_rec.tax_adjusted     := all_exchanges_rec.adjustment_tax_amount;
    l_adj_rec.receivables_charges_adjusted  := all_exchanges_rec.adjustment_charges_amount;
    l_adj_rec.adjustment_id    := all_exchanges_rec.adjustment_id;
    l_adj_rec.payment_schedule_id    := all_exchanges_rec.adjustment_ps_id;
    l_adj_rec.type             := all_exchanges_rec.adjustment_type;
    --{BUG#5016123
    l_adj_rec.receivables_trx_id :=  all_exchanges_rec.adj_rec_trx_id;
    l_adj_rec.adjustment_type    :=  all_exchanges_rec.adj_adj_type;
    --}
    -- Get the assigned invoice row
    OPEN c_trx(p_customer_trx_id  => all_exchanges_rec.source_trx_id);
    FETCH c_trx INTO l_cust_trx_rec;
    CLOSE c_trx;

   /*--------------------------+
    | Initialize build record  |
    +--------------------------*/
    l_ael_line_rec := l_ael_empty_line_rec ;
    l_ae_line_tbl  := l_ae_empty_line_tbl ;

    -- Call allocation in simulation mode
    arp_allocation_pkg.Allocate_Tax (
                  p_ae_doc_rec    =>      g_ae_doc_rec,
                  p_ae_event_rec  =>      g_ae_event_rec,
                  p_ae_rule_rec   =>      p_ae_rule_rec,
                  p_app_rec       =>      l_app_rec,
                  p_cust_inv_rec  =>      l_cust_trx_rec,
                  p_adj_rec       =>      l_adj_rec,
                  p_ae_ctr        =>      l_ae_ctr,
                  p_ae_line_tbl   =>      l_ae_line_tbl,
                  p_br_cust_trx_line_id => all_exchanges_rec.source_trx_id,
                  p_simul_app     =>      'Y',
                  p_from_llca_call =>     'N',
                  p_gt_id          =>     NULL);

    --
    -- Create the detail distributions
    --
    IF l_ae_ctr <> 0 THEN

      FOR i IN l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST LOOP

     /*---------------------------+
      | Deduct debits and credits |
      +---------------------------*/
      -- Need top switch sign here not at adjustment for balance at line level
      l_ael_line_rec.entered_cr         := l_ae_line_tbl(i).entered_dr;
      l_ael_line_rec.entered_dr         := l_ae_line_tbl(i).entered_cr;
      l_ael_line_rec.accounted_cr       := l_ae_line_tbl(i).accounted_dr;
      l_ael_line_rec.accounted_dr       := l_ae_line_tbl(i).accounted_cr;
      l_ael_line_rec.from_amount_cr     := l_ae_line_tbl(i).from_amount_dr;
      l_ael_line_rec.from_amount_dr     := l_ae_line_tbl(i).from_amount_cr;
      l_ael_line_rec.taxable_entered_cr := l_ae_line_tbl(i).taxable_entered_dr;
      l_ael_line_rec.taxable_entered_dr := l_ae_line_tbl(i).taxable_entered_cr;
      l_ael_line_rec.taxable_accounted_cr := l_ae_line_tbl(i).taxable_accounted_dr;
      l_ael_line_rec.taxable_accounted_dr := l_ae_line_tbl(i).taxable_accounted_cr;
      --
      l_ael_line_rec.ref_customer_trx_line_id     := l_ae_line_tbl(i).ref_customer_trx_line_id;
      l_ael_line_rec.ref_cust_trx_line_gl_dist_id := l_ae_line_tbl(i).ref_cust_trx_line_gl_dist_id;
      l_ael_line_rec.ref_line_id                  := l_ae_line_tbl(i).ref_line_id;
      l_ael_line_rec.activity_bucket                       := l_ae_line_tbl(i).activity_bucket;
      l_ael_line_rec.ref_account_class                    := l_ae_line_tbl(i).ref_account_class;

     /*---------------------+
      | Fill in the record  |
      +---------------------*/
      l_ael_line_rec.source_id    := g_ae_doc_rec.source_id;
      l_ael_line_rec.source_table := C_TH;
      l_ael_line_rec.ae_line_type := C_REC;
      l_ael_line_rec.currency_code            := all_exchanges_rec.invoice_currency_code;
      l_ael_line_rec.currency_conversion_rate := all_exchanges_rec.exchange_rate;
      l_ael_line_rec.currency_conversion_type := all_exchanges_rec.exchange_rate_type;
      l_ael_line_rec.currency_conversion_date := all_exchanges_rec.exchange_date;
      l_ael_line_rec.source_id_secondary      := all_exchanges_rec.customer_trx_line_id;
      l_ael_line_rec.third_party_id           := all_exchanges_rec.assignment_customer_id;
      l_ael_line_rec.third_party_sub_id       := all_exchanges_rec.assignment_site_use_id;
      l_ael_line_rec.ae_line_type_secondary   := C_ASSIGNMENT;
      l_ael_line_rec.source_table_secondary   := C_CTL;


      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('source id = ' || to_char(l_ael_line_rec.source_id));
         arp_standard.debug('currency code = ' || l_ael_line_rec.currency_code);
      END IF;


      IF NVL(all_exchanges_rec.class,'INV') <> 'BR' THEN

       /*--------------------------------------------------+
        | If exchanges transaction is not BR fetch account |
        | from table ra_cust_trx_line_gl_dist.             |
        +--------------------------------------------------*/
        IF l_current_trx_id   <> all_exchanges_rec.source_trx_id THEN

          OPEN TRX_exchange_cur(all_exchanges_rec.source_trx_id);
          FETCH TRX_exchange_cur INTO TRX_exchange_rec;
          l_ael_line_rec.account            := TRX_exchange_rec.code_combination_id;
          CLOSE TRX_exchange_cur;

          l_current_trx_id := all_exchanges_rec.source_trx_id;

        ELSE
          l_ael_line_rec.account            := TRX_exchange_rec.code_combination_id;

        END IF;

      ELSE

      /*--------------------------------------------------+
       | If exchanges transaction is  BR fetch the        |
       | current accounted history record.                |
       +--------------------------------------------------*/
        IF l_current_trx_id   <> all_exchanges_rec.source_trx_id THEN

          OPEN BR_exchange_cur(all_exchanges_rec.source_trx_id);
          FETCH BR_exchange_cur INTO BR_exchange_rec;
          CLOSE BR_exchange_cur;
         /*--------------------------------------------------+
          | Fetch the receivable accounting for the BR       |
          | and use that as account.                         |
          +--------------------------------------------------*/
          find_rec_dist_record(BR_exchange_rec.transaction_history_id,
                               SIGN(all_exchanges_rec.assignment_amount_due_original),
                               BR_dist_rec);
          l_ael_line_rec.account            := BR_dist_rec.code_combination_id;

        ELSE
          l_ael_line_rec.account            := BR_dist_rec.code_combination_id;
        END IF;

      END IF;

     /*---------------------------+
      | Assign AEL for TH record  |
      +---------------------------*/
      Assign_Ael_Elements( p_ae_line_rec 	=> l_ael_line_rec );
    END LOOP;
   END IF;

  END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.create_exchanged_trx_acct()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.create_exchanged_trx_acct');
       END IF;
       RAISE;

END create_exchanged_trx_acct;

/* =======================================================================
 | PROCEDURE reverse_deferred_tax
 |
 | DESCRIPTION
 |      This procedure reverses deferred tax on given transaction history record
 |
 | PARAMETERS
 |      p_transaction_history_id     Transaction history ID
 * ======================================================================*/
PROCEDURE reverse_deferred_tax(p_transaction_history_id ar_transaction_history.transaction_history_id%TYPE) IS

 /*--------------------------------------------------+
  | Cursor to return the tax accounting for given    |
  | transactions history record                      |
  +--------------------------------------------------*/

  -- MRC Trigger Replacment: enumerated columns and added union to select
  -- currency sensitive data.

  CURSOR tax_accounting_cur(l_transaction_history_id ar_transaction_history.transaction_history_id%TYPE) IS
    select line_id,
           source_id,
           source_table,
           source_type,
           code_combination_id,
           amount_dr,
           amount_cr,
           acctd_amount_dr,
           acctd_amount_cr,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           org_id,
           source_table_secondary,
           source_id_secondary,
           currency_code,
           currency_conversion_rate,
           currency_conversion_type,
           currency_conversion_date,
           taxable_entered_dr,
           taxable_entered_cr,
           taxable_accounted_dr,
           taxable_accounted_cr,
           tax_link_id,
           third_party_id,
           third_party_sub_id,
           reversed_source_id,
           tax_code_id,
           location_segment_id,
           source_type_secondary,
           tax_group_code_id,
           --{BUG#2979254
           ref_customer_trx_line_id,
           ref_cust_trx_line_gl_dist_id,
           ref_line_id,
           from_amount_dr,
           from_amount_cr,
           from_acctd_amount_dr,
           from_acctd_amount_cr
           --}
    FROM ar_distributions
    WHERE NVL(g_ae_sys_rec.sob_type,'P') = 'P'
    AND source_id = l_transaction_history_id
    AND source_table = C_TH
    AND source_type in (C_DEFERRED_TAX,C_TAX)
    ORDER BY line_id ASC;
/*BUG4301323
 UNION
    select line_id,
           source_id,
           source_table,
           source_type,
           code_combination_id,
           amount_dr,
           amount_cr,
           acctd_amount_dr,
           acctd_amount_cr,
           creation_date,
           created_by,
           last_updated_by,
           last_update_date,
           last_update_login,
           org_id,
           source_table_secondary,
           source_id_secondary,
           currency_code,
           currency_conversion_rate,
           currency_conversion_type,
           currency_conversion_date,
           taxable_entered_dr,
           taxable_entered_cr,
           taxable_accounted_dr,
           taxable_accounted_cr,
           tax_link_id,
           third_party_id,
           third_party_sub_id,
           reversed_source_id,
           tax_code_id,
           location_segment_id,
           source_type_secondary,
           tax_group_code_id,
           --{BUG#2979254
           ref_customer_trx_line_id,
           ref_cust_trx_line_gl_dist_id,
           ref_line_id,
           from_amount_dr,
           from_amount_cr,
           from_acctd_amount_dr,
           from_acctd_amount_cr
           --}
    FROM ar_mc_distributions_all
    WHERE g_ae_sys_rec.sob_type = 'R'
    AND set_of_books_id = g_ae_sys_rec.set_of_books_id
    AND source_id = l_transaction_history_id
    AND source_table = C_TH
    AND source_type in (C_DEFERRED_TAX,C_TAX)
    ORDER BY line_id ASC;
*/
 tax_accounting_rec ar_distributions%ROWTYPE;
 l_prev_posted_trh_rec   ar_transaction_history%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_deferred_tax()+');
  END IF;

  BEGIN
   /*-------------------------------------------------------+
    | Find the original posted transaction history record   |
    | with MATURITY_DATE event .                            |
    +-------------------------------------------------------*/
    find_prev_posted_hist_record(p_transaction_history_id,l_prev_posted_trh_rec,NULL,C_MATURITY_DATE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      /*---------------------------------------------+
       | No deferred tax exists, so none is reversed |
       +---------------------------------------------*/
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('reverse_deferred_tax: ' || 'No Deferred tax exist, so none is reversed ');
       END IF;
       NULL;

  END;

 /*---------------------------------+
  | Only reverse tax, if tax exists |
  +---------------------------------*/
  IF l_prev_posted_trh_rec.transaction_history_id IS NOT NULL THEN

   /*-------------------------------------------------------+
    | Loop through the tax accounting under the transaction |
    | history record                                        |
    +-------------------------------------------------------*/
--    FOR tax_accounting_rec IN tax_accounting_cur(l_prev_posted_trh_rec.transaction_history_id) LOOP
    --{HYUDETUPT change the structure of this code so that it does not break everytime schema changes
    OPEN tax_accounting_cur(l_prev_posted_trh_rec.transaction_history_id);
    LOOP
      FETCH tax_accounting_cur INTO
           tax_accounting_rec.line_id,
           tax_accounting_rec.source_id,
           tax_accounting_rec.source_table,
           tax_accounting_rec.source_type,
           tax_accounting_rec.code_combination_id,
           tax_accounting_rec.amount_dr,
           tax_accounting_rec.amount_cr,
           tax_accounting_rec.acctd_amount_dr,
           tax_accounting_rec.acctd_amount_cr,
           tax_accounting_rec.creation_date,
           tax_accounting_rec.created_by,
           tax_accounting_rec.last_updated_by,
           tax_accounting_rec.last_update_date,
           tax_accounting_rec.last_update_login,
           tax_accounting_rec.org_id,
           tax_accounting_rec.source_table_secondary,
           tax_accounting_rec.source_id_secondary,
           tax_accounting_rec.currency_code,
           tax_accounting_rec.currency_conversion_rate,
           tax_accounting_rec.currency_conversion_type,
           tax_accounting_rec.currency_conversion_date,
           tax_accounting_rec.taxable_entered_dr,
           tax_accounting_rec.taxable_entered_cr,
           tax_accounting_rec.taxable_accounted_dr,
           tax_accounting_rec.taxable_accounted_cr,
           tax_accounting_rec.tax_link_id,
           tax_accounting_rec.third_party_id,
           tax_accounting_rec.third_party_sub_id,
           tax_accounting_rec.reversed_source_id,
           tax_accounting_rec.tax_code_id,
           tax_accounting_rec.location_segment_id,
           tax_accounting_rec.source_type_secondary,
           tax_accounting_rec.tax_group_code_id,
           --{BUG#2979254
           tax_accounting_rec.ref_customer_trx_line_id,
           tax_accounting_rec.ref_cust_trx_line_gl_dist_id,
           tax_accounting_rec.ref_line_id,
           tax_accounting_rec.from_amount_dr,
           tax_accounting_rec.from_amount_cr,
           tax_accounting_rec.from_acctd_amount_dr,
           tax_accounting_rec.from_acctd_amount_cr;

      EXIT WHEN tax_accounting_cur%NOTFOUND;
     /*--------------------------------+
      | Reverse the tax accounting     |
      +--------------------------------*/
      reverse_single_dist_line(tax_accounting_rec);

    END LOOP;
    CLOSE tax_accounting_cur;
    --}
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_BILLS_RECEIVABLE_MAIN.reverse_deferred_tax()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION: ARP_BILLS_RECEIVABLE_MAIN.reverse_deferred_tax');
       END IF;
       RAISE;
END reverse_deferred_tax;

END ARP_BILLS_RECEIVABLE_MAIN;

/
