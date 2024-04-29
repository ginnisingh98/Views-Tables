--------------------------------------------------------
--  DDL for Package Body ARP_RECONCILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RECONCILE" AS
/* $Header: ARTRECBB.pls 120.11.12010000.5 2009/03/04 16:30:41 spdixit ship $ */

/*=======================================================================+
 |  Global Constants
 +=======================================================================*/


  TYPE g_tax_rec_type IS RECORD (
       ae_location_segment_id     NUMBER,
       ae_tax_group_code_id       NUMBER,
       ae_tax_code_id             NUMBER,
       ae_code_combination_id     NUMBER,
       ae_amount                  NUMBER,
       ae_acctd_amount            NUMBER,
       ae_taxable_amount          NUMBER,
       ae_taxable_acctd_amount    NUMBER,
       ae_match_flag              VARCHAR2(1)
  );

  TYPE g_tax_tbl_type IS TABLE of g_tax_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE g_pay_rec_type IS RECORD (
       applied_customer_trx_id      NUMBER,
       applied_payment_schedule_id  NUMBER,
       amount_applied               NUMBER,
       acctd_amount_applied_to      NUMBER,
       line_applied                 NUMBER,
       tax_applied                  NUMBER,
       freight_applied              NUMBER,
       receivables_charges_applied  NUMBER
  );

  TYPE g_pay_tbl_type IS TABLE of g_pay_rec_type
    INDEX BY BINARY_INTEGER;

  g_ae_empty_line_tbl           ae_line_tbl_type;
  g_orig_cust_trx_id            NUMBER;
  g_call_num                    NUMBER;

/*============================================================================+
 | Private Procedure/Function prototypes                                      |
 +============================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE Check_Entry(p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE,
                      p_type             IN  VARCHAR2,
                      p_required         OUT NOCOPY BOOLEAN                               );

PROCEDURE Check_all_bills_closed(p_customer_trx_id     IN  NUMBER      ,
                                 p_all_br_closed       IN OUT NOCOPY VARCHAR2     );

PROCEDURE Reverse_Reconcile_entry(
                    p_mode                   IN             VARCHAR2,
                    p_ae_doc_rec             IN             ae_doc_rec_type,
                    p_ae_event_rec           IN             ae_event_rec_type,
                    p_ae_sys_rec             IN             ae_sys_rec_type,
                    p_customer_trx_id        IN             NUMBER,
                    p_calling_point          IN             VARCHAR2,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                );

PROCEDURE get_recon_acct(
                    p_mode                   IN             VARCHAR2,
                    p_ae_doc_rec             IN             ae_doc_rec_type,
                    p_ae_event_rec           IN             ae_event_rec_type,
                    p_ae_sys_rec             IN             ae_sys_rec_type,
                    p_customer_trx_id        IN             NUMBER,
                    p_customer_trx_line_id   IN             NUMBER,
                    p_calling_point          IN             VARCHAR2,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                );

PROCEDURE Reconcile_br_tax(
                    p_mode                   IN             VARCHAR2,
                    p_ae_doc_rec             IN             ae_doc_rec_type,
                    p_ae_event_rec           IN             ae_event_rec_type,
                    p_ae_sys_rec             IN             ae_sys_rec_type,
                    p_customer_trx_id        IN             NUMBER,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                     );

PROCEDURE Reconcile_trx_tax(
                    p_mode                   IN             VARCHAR2                       ,
                    p_ae_doc_rec             IN             ae_doc_rec_type                ,
                    p_ae_event_rec           IN             ae_event_rec_type              ,
                    p_ae_sys_rec             IN             ae_sys_rec_type                ,
                    p_cust_inv_rec           IN             ra_customer_trx%ROWTYPE        ,
                    p_customer_trx_id        IN             NUMBER                         ,
                    p_br_cust_trx_line_id    IN             NUMBER                         ,
                    p_calling_point          IN             VARCHAR2                       ,
                    p_pay_class              IN             VARCHAR2                       ,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER                 ,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                );

PROCEDURE Detect_Closure(p_customer_trx_id        IN  NUMBER   ,
                         p_pay_sched_upd_yn       IN  VARCHAR2 ,
                         p_pay_sched_upd_cm_yn    IN  VARCHAR2 ,
                         p_activity_amt           IN  NUMBER   ,
                         p_activity_acctd_amt     IN  NUMBER   ,
                         p_ae_sys_rec             IN  ae_sys_rec_type,
                         p_closed_pymt_yn         OUT NOCOPY VARCHAR2 ,
                         p_pay_class              OUT NOCOPY VARCHAR2  );

PROCEDURE Process_Recon(
                    p_mode                   IN             VARCHAR2                           ,
                    p_ae_doc_rec             IN             ae_doc_rec_type                    ,
                    p_ae_event_rec           IN             ae_event_rec_type                  ,
                    p_ae_sys_rec             IN             ae_sys_rec_type                    ,
                    p_cust_inv_rec           IN             ra_customer_trx%ROWTYPE            ,
                    p_br_cust_trx_line_id    IN             NUMBER                             ,
                    p_customer_trx_id        IN             NUMBER                             ,
                    p_simul_app              IN             VARCHAR2                           ,
                    p_calling_point          IN             VARCHAR2                           ,
                    p_pay_ctr                IN             BINARY_INTEGER                     ,
                    p_pay_tbl                IN             g_pay_tbl_type                     ,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER                     ,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                    );

PROCEDURE Assign_Elements(p_ae_line_rec           IN  OUT NOCOPY ae_line_rec_type           ,
                          p_g_ae_ctr              IN  OUT NOCOPY BINARY_INTEGER         ,
                          p_g_ae_line_tbl         IN  OUT NOCOPY ae_line_tbl_type  );

PROCEDURE Dump_Line_Amts(p_ae_line_rec  IN ae_line_rec_type);

PROCEDURE Build_Deferred_Tax (p_customer_trx_id     IN NUMBER,
                              p_br_cust_trx_line_id IN NUMBER,
                              p_location_segment_id IN NUMBER,
                              p_tax_group_code_id   IN NUMBER,
                              p_tax_code_id         IN NUMBER,
                              p_code_combination_id IN NUMBER,
                              p_ae_doc_rec          IN ae_doc_rec_type,
                              p_cust_inv_rec        IN ra_customer_trx%ROWTYPE,
                              p_calling_point       IN VARCHAR2,
                              p_ae_line_rec         IN OUT NOCOPY ae_line_rec_type);

PROCEDURE Build_Tax (p_customer_trx_id     IN NUMBER,
                     p_location_segment_id IN NUMBER,
                     p_tax_group_code_id   IN NUMBER,
                     p_tax_code_id         IN NUMBER,
                     p_code_combination_id IN NUMBER,
                     p_ae_line_rec         IN OUT NOCOPY ae_line_rec_type );

/*========================================================================
 | PUBLIC PROCEDURE Reconcile_trx_br
 |
 | DESCRIPTION
 |      Reconciles deferred tax for a Transaction or a Bills Receivable
 |      document, as the case may be.
 |
 | PARAMETERS
 |      p_mode                 IN     Document or Accounting Event mode
 |      p_ae_doc_rec           IN     Document Record
 |      p_ae_event_rec         IN     Event Record
 |      p_cust_inv_rec         IN     Contains currency, exchange rate, site
 |                                    details for the bill
 |      p_activity_cust_trx_id IN     Transaction to which the activity was made
 |      p_activity_amt         IN     Amount by which the Open Receivables was
 |                                    changed due to activity.
 |      p_activity_acctd_amt   IN     Accounted amount by which the Open
 |                                    Receivables was changed due to activity.
 |      p_g_ae_line_tbl        IN OUT NOCOPY Global accounting entries line table
 |                                    passed by parent routine
 |      p_g_ae_ctr             IN OUT NOCOPY Global counter for accounting entries
 |                                    table passed by parent routine
 *===========================================================================*/

PROCEDURE Reconcile_trx_br(
                  p_mode                 IN             VARCHAR2,
                  p_ae_doc_rec           IN             ae_doc_rec_type,
                  p_ae_event_rec         IN             ae_event_rec_type,
                  p_cust_inv_rec         IN             ra_customer_trx%ROWTYPE,
                  p_activity_cust_trx_id IN             NUMBER,
                  p_activity_amt         IN             NUMBER,
                  p_activity_acctd_amt   IN             NUMBER,
                  p_call_num             IN             NUMBER,
                  p_g_ae_line_tbl        IN OUT NOCOPY ae_line_tbl_type,
                  p_g_ae_ctr             IN OUT NOCOPY        BINARY_INTEGER               ) IS

l_ae_sys_rec ae_sys_rec_type;
l_closed_pymt_yn VARCHAR2(1);
l_calling_point VARCHAR2(4);
l_pay_class ar_payment_schedules.class%TYPE;
l_required BOOLEAN;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Check_Entry: ' || 'ARP_RECONCILE.Reconcile_trx_br ()+ ');
  END IF;

  --Set global variable for document being reconciled
   g_orig_cust_trx_id := p_activity_cust_trx_id;
   g_call_num := p_call_num;


   --GOTO end_process_lbl;
  --Get system options info
   l_ae_sys_rec.set_of_books_id   := ARP_ACCT_MAIN.ae_sys_rec.set_of_books_id;
   l_ae_sys_rec.gain_cc_id        := ARP_ACCT_MAIN.ae_sys_rec.gain_cc_id;
   l_ae_sys_rec.loss_cc_id        := ARP_ACCT_MAIN.ae_sys_rec.loss_cc_id;
   l_ae_sys_rec.round_cc_id       := ARP_ACCT_MAIN.ae_sys_rec.round_cc_id;
   l_ae_sys_rec.coa_id            := ARP_ACCT_MAIN.ae_sys_rec.coa_id;
   l_ae_sys_rec.base_currency     := ARP_ACCT_MAIN.ae_sys_rec.base_currency;
   l_ae_sys_rec.base_precision    := ARP_ACCT_MAIN.ae_sys_rec.base_precision;
   l_ae_sys_rec.base_min_acc_unit := ARP_ACCT_MAIN.ae_sys_rec.base_min_acc_unit;

   l_ae_sys_rec.sob_type          := ARP_ACCT_MAIN.ae_sys_rec.sob_type;

 --Set the calling mode
   IF (p_cust_inv_rec.drawee_site_use_id IS NULL) THEN
      l_calling_point := 'TRAN';
   ELSE
      l_calling_point := 'BILL';
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Check_Entry: ' || 'Calling point ' || l_calling_point);
   END IF;

 /*--------------------------------------------------------------------------+
  | If the Transaction is not deferred then do not do any process as there is|
  | no deferred tax to reconcile. Simillar processing for all Transactions on|
  | a Bills Receivable Document.                                             |
  +--------------------------------------------------------------------------*/
   Check_Entry(p_customer_trx_id  =>  p_activity_cust_trx_id,
               p_type             =>  l_calling_point       ,
               p_required         =>  l_required              );

 --If no deferred tax then processing is not required
   IF (NOT l_required) THEN
      GOTO end_process_lbl;
   END IF;

 /*--------------------------------------------------------------------------+
  | Call the Reversal routine only if the activity amounts are non zero. This|
  | is to ensure that the old reconciliation entries are not backed out, as  |
  | 0 amount activity indicates that there is no change in the Transactions  |
  | payment schedule. So the last image is unchanged.                        |
  +--------------------------------------------------------------------------*/
   IF ((nvl(p_activity_amt,0) + nvl(p_activity_acctd_amt,0)) <> 0) THEN
    --Call the Reversal routine
      Reverse_Reconcile_entry(p_mode             => p_mode                          ,
                              p_ae_doc_rec       => p_ae_doc_rec                    ,
                              p_ae_event_rec     => p_ae_event_rec                  ,
                              p_ae_sys_rec       => l_ae_sys_rec                    ,
                              p_customer_trx_id  => p_activity_cust_trx_id          ,
                              p_calling_point    => l_calling_point                 ,
                              p_g_ae_ctr         => p_g_ae_ctr                      ,
                              p_g_ae_line_tbl    => p_g_ae_line_tbl                  );
   END IF;

 /*-------------------------------------------------------------------------+
  | Determine whether the payment schedule of the Transaction or Bill is    |
  | closed, only on closure do we need to create the Reconciliation entry.  |
  +-------------------------------------------------------------------------*/
   Detect_Closure(p_customer_trx_id        =>  p_activity_cust_trx_id        ,
                  p_pay_sched_upd_yn       =>  p_ae_doc_rec.pay_sched_upd_yn ,
                  p_pay_sched_upd_cm_yn    =>  p_ae_doc_rec.pay_sched_upd_cm_yn ,
                  p_activity_amt           =>  p_activity_amt                ,
                  p_activity_acctd_amt     =>  p_activity_acctd_amt          ,
                  p_ae_sys_rec             =>  l_ae_sys_rec,
                  p_closed_pymt_yn         =>  l_closed_pymt_yn              ,
                  p_pay_class              =>  l_pay_class );

 /*-------------------------------------------------------------------------+
  | Reconcile deferred tax accounting on Bill or Transaction only if it is  |
  | closed. Note for a Bill the drawee site is always populated hence.      |
  +-------------------------------------------------------------------------*/
   IF (l_closed_pymt_yn = 'Y') THEN

      IF (p_cust_inv_rec.drawee_site_use_id IS NULL) THEN
         Reconcile_trx_tax(p_mode                   => p_mode                          ,
                           p_ae_doc_rec             => p_ae_doc_rec                    ,
                           p_ae_event_rec           => p_ae_event_rec                  ,
                           p_ae_sys_rec             => l_ae_sys_rec                    ,
                           p_cust_inv_rec           => p_cust_inv_rec                  ,
                           p_customer_trx_id        => p_activity_cust_trx_id          ,
                           p_br_cust_trx_line_id    => ''                              ,
                           p_calling_point          => 'TRAN'                          ,
                           p_pay_class              => l_pay_class                     ,
                           p_g_ae_ctr               => p_g_ae_ctr                      ,
                           p_g_ae_line_tbl          => p_g_ae_line_tbl                    );

      ELSE --reconcile tax accounting for a Bills Receivable document
         Reconcile_br_tax(p_mode                   => p_mode                          ,
                          p_ae_doc_rec             => p_ae_doc_rec                    ,
                          p_ae_event_rec           => p_ae_event_rec                  ,
                          p_ae_sys_rec             => l_ae_sys_rec                    ,
                          p_customer_trx_id        => p_activity_cust_trx_id          ,
                          p_g_ae_ctr               => p_g_ae_ctr                      ,
                          p_g_ae_line_tbl          => p_g_ae_line_tbl                    );

      END IF; --reconcile document

   END IF; --payment schedule is closed

<<end_process_lbl>>
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Check_Entry: ' || 'ARP_RECONCILE.Reconcile_trx_br ()- ');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Check_Entry: ' || 'EXCEPTION OTHERS: ARP_RECONCILE.Reconcile_trx_br ');
     END IF;
     RAISE;

END Reconcile_trx_br;

/* =======================================================================
 | PROCEDURE Check_Entry
 |
 | DESCRIPTION
 |      This routine checks whether the current Transaction to be Reconciled
 |      is deferred. Only then is processing really required.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_customer_trx_id       IN      Transaction identifier
 |      p_type                  IN      Transaction or Bill
 |      p_required              OUT NOCOPY     Flag indicates whether tax processing
 |                                      is required
 * ======================================================================*/
PROCEDURE Check_Entry(p_customer_trx_id  IN  ra_customer_trx.customer_trx_id%TYPE,
                      p_type             IN  VARCHAR2                            ,
                      p_required         OUT NOCOPY BOOLEAN                               ) IS

l_def_flag VARCHAR2(1);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Check_Entry - Checking for deferred tax');
   END IF;

   IF (p_type = 'TRAN') THEN

      BEGIN
         select 'Y'
         into   l_def_flag
         from dual
         where exists (select 'x'
                       from ra_cust_trx_line_gl_dist gld
                       where gld.account_class = 'TAX'
                       and   gld.customer_trx_id = p_customer_trx_id
                       and   gld.collected_tax_ccid IS NOT NULL
                      );

         p_required := TRUE; --Atleast one deferred tax line exists

         EXCEPTION
         WHEN NO_DATA_FOUND THEN
           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('ARP_RECONCILE.Check_Entry - NO DEFERRED TAX');
           END IF;
           p_required := FALSE; --Tax is not deferred processing not required
         WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('EXCEPTION OTHERS: ARP_RECONCILE.Check_Entry - Transaction check ');
            END IF;
            RAISE;
      END; --deferred tax processing required for Transactions

   ELSIF (p_type = 'BILL') THEN
      --BR entitity handler call
         ARP_PROCESS_BR_HEADER.move_deferred_tax(
               p_customer_trx_id  =>  p_customer_trx_id,
               p_required         =>  p_required);
   ELSE
         p_required := TRUE; --Enable processing this should never happen
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Check_Entry - DEFERRED TAX');
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION NO_DATA_FOUND: ARP_RECONCILE.Check_Entry ');
        END IF;
        RAISE;
   WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION OTHERS: ARP_RECONCILE.Check_Entry ');
        END IF;
        RAISE;
END Check_Entry;

/*========================================================================
 | PRIVATE PROCEDURE Reverse_Reconcile_entry
 |
 | DESCRIPTION
 |      Reverses out NOCOPY reconciliation entries by location, tax group, tax code
 |      and account for deferred tax entries. This is necessary because when
 |      this routine is called, at that point of time the sum total of any
 |      past reconciliation entries must be zero.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_ae_sys_rec    IN      System parameter details
 |      p_cust_inv_rec  IN      Contains currency, exchange rate, site
 |                              details for the bill
 |      p_g_ae_ctr      IN OUT NOCOPY  counter for global accounting lines table
 |      p_g_ae_line_tbl IN OUT NOCOPY  accounting lines table containing reconciled
 |                              entry
 *=======================================================================*/
PROCEDURE Reverse_Reconcile_entry(
                    p_mode                   IN             VARCHAR2                       ,
                    p_ae_doc_rec             IN             ae_doc_rec_type                ,
                    p_ae_event_rec           IN             ae_event_rec_type              ,
                    p_ae_sys_rec             IN             ae_sys_rec_type                ,
                    p_customer_trx_id        IN             NUMBER                         ,
                    p_calling_point          IN             VARCHAR2                       ,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER                 ,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                ) IS

l_cust_inv_rec ra_customer_trx%ROWTYPE;

 CURSOR get_assignments(p_customer_trx_id IN NUMBER) is
   SELECT ctl.customer_trx_id                     br_cust_trx_id             ,
          ctl.customer_trx_line_id                br_customer_trx_line_id    ,
          ctl.br_ref_customer_trx_id              br_ref_customer_trx_id     ,
          ctl.br_ref_payment_schedule_id          br_ref_payment_schedule_id ,
          ct.drawee_site_use_id                   drawee_site_use_id         ,
          ct.invoice_currency_code                invoice_currency_code      ,
          ct.exchange_rate                          exchange_rate              ,
                 ct.exchange_rate_type               exchange_rate_type         ,
            ct.exchange_date                      exchange_date              ,
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

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Reverse_Reconcile_Entry()+ ');
      arp_standard.debug('Reverse_Reconcile_entry: ' || 'p_customer_trx_id ' || p_customer_trx_id);
      arp_standard.debug('Reverse_Reconcile_entry: ' || 'p_calling_point ' || p_calling_point);
   END IF;

   IF p_calling_point IN ('TRAN', 'BLTR') THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Reverse_Reconcile_entry: ' || 'Calling get_recon_acct for 1 -' || p_calling_point);
      END IF;

     --get reconciliation entries customer trx line id, tax code, account
      get_recon_acct( p_mode                   => p_mode             ,
                      p_ae_doc_rec             => p_ae_doc_rec       ,
                      p_ae_event_rec           => p_ae_event_rec     ,
                      p_ae_sys_rec             => p_ae_sys_rec       ,
                      p_customer_trx_id        => p_customer_trx_id  ,
                      p_customer_trx_line_id   => ''                 ,
                      p_calling_point          => 'TRAN'             ,
                      p_g_ae_ctr               => p_g_ae_ctr         ,
                      p_g_ae_line_tbl          => p_g_ae_line_tbl      );

      --get transactions reconciliation entries only (not bills)
      --Reverse reconciliation entry if required

   ELSE

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Reverse_Reconcile_entry: ' || 'Calling get_recon_acct for 2 -' || p_calling_point);
      END IF;

    --Loop assignment times
        FOR l_assign_rec IN get_assignments(p_customer_trx_id) LOOP

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Reverse_Reconcile_entry: ' || 'l_assign_rec.drawee_site_use_id ' || l_assign_rec.drawee_site_use_id);
           END IF;

         --If assignment is a bill then Recursive call
            IF l_assign_rec.drawee_site_use_id IS NOT NULL THEN

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug('Reverse_Reconcile_entry: ' || 'Recursive call for l_assign_rec.br_ref_customer_trx_id ' || l_assign_rec.br_ref_customer_trx_id);
               END IF;
               Reverse_Reconcile_entry(
                     p_mode             => p_mode                              ,
                     p_ae_doc_rec       => p_ae_doc_rec                        ,
                     p_ae_event_rec     => p_ae_event_rec                      ,
                     p_ae_sys_rec       => p_ae_sys_rec                        ,
                     p_customer_trx_id  => l_assign_rec.br_ref_customer_trx_id ,
                     p_calling_point    => 'BILL'                              ,
                     p_g_ae_ctr         => p_g_ae_ctr                          ,
                     p_g_ae_line_tbl    => p_g_ae_line_tbl );
            ELSE
             -- get reconciliation entries customer trx line id,
             -- tax code, account
               get_recon_acct(
                 p_mode                 => p_mode             ,
                 p_ae_doc_rec           => p_ae_doc_rec       ,
                 p_ae_event_rec         => p_ae_event_rec     ,
                 p_ae_sys_rec           => p_ae_sys_rec       ,
                 p_customer_trx_id      => l_assign_rec.br_ref_customer_trx_id,
                 p_customer_trx_line_id => l_assign_rec.br_customer_trx_line_id,
                 p_calling_point        => 'BILL',
                 p_g_ae_ctr             => p_g_ae_ctr,
                 p_g_ae_line_tbl        => p_g_ae_line_tbl );

              --get reconciliation entries for transaction
                 get_recon_acct( p_mode                   => p_mode             ,
                                 p_ae_doc_rec             => p_ae_doc_rec       ,
                                 p_ae_event_rec           => p_ae_event_rec     ,
                                 p_ae_sys_rec             => p_ae_sys_rec       ,
                                 p_customer_trx_id        => l_assign_rec.br_ref_customer_trx_id        ,
                                 p_customer_trx_line_id   => l_assign_rec.br_customer_trx_line_id       ,
                                 p_calling_point          => 'BLTR'                                     ,
                                 p_g_ae_ctr               => p_g_ae_ctr                                 ,
                                 p_g_ae_line_tbl          => p_g_ae_line_tbl                             );

            END IF; --drawee site is not null

        END LOOP; --get assignments

   END IF; --drawee site is null

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Reverse_Reconcile_Entry()- ');
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION NO_DATA_FOUND: ARP_RECONCILE.Reverse_Reconcile_entry ');
      END IF;
      RAISE;
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Reverse_Reconcile_entry: ' || SQLERRM);
         arp_standard.debug('EXCEPTION OTHERS: ARP_RECONCILE.Reverse_Reconcile_entry ');
      END IF;
      RAISE;

END Reverse_Reconcile_entry;

/*========================================================================
 | PRIVATE PROCEDURE get_recon_acct
 |
 | DESCRIPTION
 |      Reverses out NOCOPY reconciliation entries by location, tax group, tax code
 |      and account for deferred tax entries. This is necessary because when
 |      this routine is called, at that point of time the sum total of any
 |      past reconciliation entries must be zero.
 |
 | PARAMETERS
 |      p_mode                 IN      Document or Accounting Event mode
 |      p_ae_doc_rec           IN      Document Record
 |      p_ae_event_rec         IN      Event Record
 |      p_ae_sys_rec           IN      System parameter details
 |      p_customer_trx_id      IN      Transaction Id
 |      p_customer_trx_line_id IN      transaction line id
 |      p_calling_point        IN      Callin from routine
 |      p_g_ae_ctr             IN OUT NOCOPY  counter for global accounting lines table
 |      p_g_ae_line_tbl        IN OUT NOCOPY  accounting lines table containing
 |                                     reconciled entry
 *=======================================================================*/
PROCEDURE get_recon_acct(
                    p_mode                   IN             VARCHAR2,
                    p_ae_doc_rec             IN             ae_doc_rec_type,
                    p_ae_event_rec           IN             ae_event_rec_type,
                    p_ae_sys_rec             IN             ae_sys_rec_type,
                    p_customer_trx_id        IN             NUMBER,
                    p_customer_trx_line_id   IN             NUMBER,
                    p_calling_point          IN             VARCHAR2,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type
                         ) IS

--
-- Get the Reconciliation entries created for Receipt applications
-- The source id secondary and table secondary are populated based
-- on which activity the reconciliation reversal is going to be created,
-- if under a Bill or BLTR, then the source table is CTL and source id
-- secondary is the assignment line id or parameter p_customer_trx_line_id
--

TYPE get_recon_acct_type IS REF CURSOR;
get_recon_accounting get_recon_acct_type;
l_recon_rec          get_recon_rec_type;

sql_stmt VARCHAR2(32000);

 select1_stmt VARCHAR2(4000) := '
     select source_type                   source_type,
            source_id_secondary           source_id_secondary,
            source_table_secondary        source_table_secondary,
            source_type_secondary         source_type_secondary,
            max(currency_code)            currency_code,
            max(currency_conversion_rate) currency_conversion_rate,
            max(currency_conversion_type) currency_conversion_type,
            max(currency_conversion_date) currency_conversion_date,
            max(third_party_id)           third_party_id,
            max(third_party_sub_id)       third_party_sub_id,
            max(reversed_source_id)       reversed_source_id,
            sum(amount)                   amount,
            sum(acctd_amount)             acctd_amount,
            sum(taxable_entered)          taxable_entered,
            sum(taxable_accounted)        taxable_accounted,
            location_segment_id           location_segment_id,
            tax_group_code_id             tax_group_code_id,
            tax_code_id                   tax_code_id,
            code_combination_id           code_combination_id
     from  ( ';

--inline query
select2_stmt  VARCHAR2(4000) := '
select
       ard.source_type                   source_type,
       decode(:p_calling_point,
              ''BLTR'', :p_customer_trx_line_id,
              ard.source_id_secondary)   source_id_secondary,
       decode(:p_calling_point,
              ''BLTR'', ''CTL'',
             ard.source_table_secondary) source_table_secondary,
       ard.source_type_secondary         source_type_secondary,
       max(ard.currency_code)            currency_code,
       max(ard.currency_conversion_rate) currency_conversion_rate,
       max(ard.currency_conversion_type) currency_conversion_type,
       max(ard.currency_conversion_date) currency_conversion_date,
       max(ard.third_party_id) third_party_id,
       max(ard.third_party_sub_id) third_party_sub_id,
       max(reversed_source_id) reversed_source_id,
       sum(nvl(ard.amount_dr,0) * -1 + nvl(ard.amount_cr,0)) amount,
       sum(nvl(ard.acctd_amount_dr,0) * -1 +
           nvl(ard.acctd_amount_cr,0)) acctd_amount,
       sum(nvl(ard.taxable_entered_dr,0) * -1 +
           nvl(ard.taxable_entered_cr,0)) taxable_entered,
       sum(nvl(ard.taxable_accounted_dr,0) * -1 +
           nvl(ard.taxable_accounted_cr,0)) taxable_accounted,
       ard.location_segment_id location_segment_id,
       ard.tax_group_code_id tax_group_code_id,
       ard.tax_code_id                   tax_code_id,
       ard.code_combination_id           code_combination_id';

from1_stmt VARCHAR2(150) := ' from  ar_distributions ard,
ar_receivable_applications app
where ';

where1_stmt VARCHAR2(3000) :=  ' app.applied_customer_trx_id = :p_customer_trx_id
   and   :p_calling_point  IN (''TRAN'', ''BLTR'')
   and   app.status = ''APP''
   and   nvl(app.confirmed_flag, ''Y'') = ''Y''
   and   ard.source_id = app.receivable_application_id
   and   ard.source_table = ''RA''
   and   ard.source_type IN (''TAX'', ''DEFERRED_TAX'')
   and   ard.source_type_secondary = ''RECONCILE''
   and   ard.source_id_secondary = :p_customer_trx_id ';

group_stmt VARCHAR2(4000) := ' group by ard.source_type,
         decode(:p_calling_point,
                ''BLTR'', :p_customer_trx_line_id,
                ard.source_id_secondary)   ,
         decode(:p_calling_point,
                ''BLTR'', ''CTL'',
                ard.source_table_secondary),
         ard.source_type_secondary,
         ard.location_segment_id,
         ard.tax_group_code_id,
         ard.tax_code_id,
         ard.code_combination_id
having ((sum(nvl(ard.amount_dr,0) * -1 + nvl(ard.amount_cr,0)) <> 0)
        OR (sum(nvl(ard.acctd_amount_dr,0) * -1 +
                nvl(ard.acctd_amount_cr,0)) <> 0)
        OR (sum(nvl(ard.taxable_entered_dr,0) * -1 +
                nvl(ard.taxable_entered_cr,0)) <> 0)
        OR (sum(nvl(ard.taxable_accounted_dr,0) * -1 +
                nvl(ard.taxable_accounted_cr,0)) <> 0))';

-- Get the Reconciliation entries created for Adjustments

from2_stmt VARCHAR2(150) :=   ' from  ar_distributions           ard,
ar_adjustments             adj
where  ';

where2_stmt VARCHAR2(3000) :=  '  adj.customer_trx_id = :p_customer_trx_id
   and   :p_calling_point  IN (''TRAN'', ''BLTR'')
   and   adj.status = ''A''
   and   ard.source_id = adj.adjustment_id
   and   ard.source_table = ''ADJ''
   and   ard.source_type IN (''TAX'', ''DEFERRED_TAX'')
   and   ard.source_type_secondary = ''RECONCILE''
   and   ard.source_id_secondary = :p_customer_trx_id ';

-- Get the Reconciliation entries created for Assignments of
-- transaction to a bill
select3_stmt  VARCHAR2(4000) := '
select
       ard.source_type                   source_type,
       decode(:p_calling_point,
              ''BLTR'', :p_customer_trx_line_id,
              :p_customer_trx_id)         source_id_secondary,
       decode(:p_calling_point,
              ''BLTR'',''CTL'',
              ''CT'')                      source_table_secondary,
       ard.source_type_secondary         source_type_secondary,
       max(ard.currency_code)            currency_code,
       max(ard.currency_conversion_rate) currency_conversion_rate,
       max(ard.currency_conversion_type) currency_conversion_type,
       max(ard.currency_conversion_date) currency_conversion_date,
       max(ard.third_party_id) third_party_id,
       max(ard.third_party_sub_id) third_party_sub_id,
       max(reversed_source_id) reversed_source_id,
       sum(nvl(ard.amount_dr,0) * -1 + nvl(ard.amount_cr,0)) amount,
       sum(nvl(ard.acctd_amount_dr,0) * -1 +
             nvl(ard.acctd_amount_cr,0)) acctd_amount,
       sum(nvl(ard.taxable_entered_dr,0) * -1 +
             nvl(ard.taxable_entered_cr,0)) taxable_entered,
       sum(nvl(ard.taxable_accounted_dr,0) * -1 +
             nvl(ard.taxable_accounted_cr,0)) taxable_accounted,
       ard.location_segment_id location_segment_id,
       ard.tax_group_code_id   tax_group_code_id,
       ard.tax_code_id         tax_code_id,
       ard.code_combination_id code_combination_id';

from3_stmt VARCHAR2(150) := 'from ra_customer_trx_lines ctl,
        ar_distributions      ard
   where ';

where3_stmt VARCHAR2(3000) :=  ' ctl.br_ref_customer_trx_id = :p_customer_trx_id
   and   :p_calling_point  IN (''TRAN'', ''BLTR'')
   and ard.source_id_secondary = ctl.customer_trx_line_id
   and ard.source_table_secondary = ''CTL''
   and ard.source_type_secondary =  ''RECONCILE''
   and ard.source_type IN (''TAX'', ''DEFERRED_TAX'') ';


group3_stmt VARCHAR2(4000) := 'group by ard.source_type,
         decode(:p_calling_point,
                ''BLTR'', :p_customer_trx_line_id,
                :p_customer_trx_id)         ,
         decode(:p_calling_point,
                ''BLTR'', ''CTL'',
                ''CT'')                      ,
         ard.source_type_secondary,
         ard.location_segment_id,
         ard.tax_group_code_id,
         ard.tax_code_id,
         ard.code_combination_id
having ((sum(nvl(ard.amount_dr,0) * -1 + nvl(ard.amount_cr,0)) <> 0)
        OR (sum(nvl(ard.acctd_amount_dr,0) * -1 +
                nvl(ard.acctd_amount_cr,0)) <> 0)
        OR (sum(nvl(ard.taxable_entered_dr,0) * -1 +
                nvl(ard.taxable_entered_cr,0)) <> 0)
        OR (sum(nvl(ard.taxable_accounted_dr,0) * -1 +
                nvl(ard.taxable_accounted_cr,0)) <> 0)) ';

--Get the Reconciliation entries created for assignments
select4_stmt  VARCHAR2(4000) := '
select
       ard.source_type source_type,
       ard.source_id_secondary source_id_secondary,
       ard.source_table_secondary source_table_secondary,
       ard.source_type_secondary source_type_secondary,
       max(ard.currency_code) currency_code,
       max(ard.currency_conversion_rate) currency_conversion_rate,
       max(ard.currency_conversion_type) currency_conversion_type,
       max(ard.currency_conversion_date) currency_conversion_date,
       max(ard.third_party_id) third_party_id,
       max(ard.third_party_sub_id) third_party_sub_id,
       max(reversed_source_id) reversed_source_id,
       sum(nvl(ard.amount_dr,0) * -1 + nvl(ard.amount_cr,0)) amount,
       sum(nvl(ard.acctd_amount_dr,0) * -1 +
           nvl(ard.acctd_amount_cr,0)) acctd_amount,
       sum(nvl(ard.taxable_entered_dr,0) * -1 +
           nvl(ard.taxable_entered_cr,0)) taxable_entered,
       sum(nvl(ard.taxable_accounted_dr,0) * -1 +
           nvl(ard.taxable_accounted_cr,0)) taxable_accounted,
       ard.location_segment_id location_segment_id,
       ard.tax_group_code_id   tax_group_code_id,
       ard.tax_code_id         tax_code_id,
       ard.code_combination_id code_combination_id ';

from4_stmt VARCHAR2(100) :=  ' from ar_distributions ard
where ';

where4_stmt VARCHAR2(3000) := ' ard.source_id_secondary = :p_customer_trx_line_id
and :p_calling_point = ''BILL''
and ard.source_table_secondary = ''CTL''
and ard.source_type_secondary = ''ASSIGNMENT_RECONCILE''
and ard.source_type IN (''TAX'', ''DEFERRED_TAX'') ';

group4_stmt VARCHAR2(4000) := ' group by ard.source_type,
         ard.source_id_secondary,
         ard.source_table_secondary,
         ard.source_type_secondary,
         ard.location_segment_id,
         ard.tax_group_code_id,
         ard.tax_code_id,
         ard.code_combination_id
having ((sum(nvl(ard.amount_dr,0) * -1 + nvl(ard.amount_cr,0)) <> 0)
        OR (sum(nvl(ard.acctd_amount_dr,0) * -1 +
                nvl(ard.acctd_amount_cr,0)) <> 0)
        OR (sum(nvl(ard.taxable_entered_dr,0) * -1 +
                nvl(ard.taxable_entered_cr,0)) <> 0)
        OR (sum(nvl(ard.taxable_accounted_dr,0) * -1 +
                nvl(ard.taxable_accounted_cr,0)) <> 0)) ';

group2 VARCHAR2(1000) := ')
group by source_type,
         source_id_secondary,
         source_table_secondary,
         source_type_secondary,
         location_segment_id,
         tax_group_code_id,
         tax_code_id,
         code_combination_id';

--from1_mrc_stmt VARCHAR2(100) :=  ' from  ar_mc_distributions_all         ard,
--         ar_receivable_applications app
--   where ';

--where1_mrc_stmt VARCHAR2(150) := ' ard.set_of_books_id = :sob_id and ';

--from2_mrc_stmt VARCHAR2(150) := ' from  ar_mc_distributions_all    ard,
--         ar_adjustments             adj
--   where  ';

--from3_mrc_stmt VARCHAR2(150) := ' from ra_customer_trx_lines ctl,
--        ar_mc_distributions_all   ard
--   where  ';

--from4_mrc_stmt VARCHAR2(100) := ' from ar_mc_distributions_all ard
--where ';

union_stmt VARCHAR2(15) := ' UNION ALL';

l_ae_line_rec ae_line_rec_type;
l_ae_empty_line_rec ae_line_rec_type;

sob_id NUMBER;

CRLF           VARCHAR2(10) := arp_global.CRLF;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Get_Recon_Acct()+ ');
      arp_standard.debug('get_recon_acct: ' || 'p_customer_trx_id      ' || p_customer_trx_id);
      arp_standard.debug('get_recon_acct: ' || 'p_customer_trx_line_id ' || p_customer_trx_line_id);
      arp_standard.debug('get_recon_acct: ' || 'p_calling_point        ' || p_calling_point);
   END IF;

   sob_id := p_ae_sys_rec.set_of_books_id;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('get_recon_acct: ' || 'set of books id = ' || to_char(sob_id));
   END IF;

   -- Construct Select Cursor based on reporting type:
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('get_recon_acct: ' || 'selecting cursor based on reporting type');
   END IF;

   sql_stmt :=  select1_stmt ||
                select2_stmt;   /* common between primary and reporting */

   IF ( p_ae_sys_rec.sob_type = 'P') THEN

     sql_stmt :=      sql_stmt || CRLF || from1_stmt  || CRLF ||
                                          where1_stmt || CRLF ||
                                          group_stmt  || CRLF ||
                  union_stmt   ||
                  select2_stmt || CRLF || from2_stmt  || CRLF ||
                                          where2_stmt || CRLF ||
                                          group_stmt  || CRLF ||
                  union_stmt   ||
                  select3_stmt || CRLF || from3_stmt  || CRLF ||
                                          where3_stmt || CRLF ||
                                          group3_stmt || CRLF ||
                  union_stmt   ||
                  select4_stmt || CRLF || from4_stmt  || CRLF ||
                                          where4_stmt || CRLF ||
                                          group4_stmt || CRLF ||
                  group2;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug ('get_recon_acct: ' || 'select_stmt  = ' || sql_stmt);
   END IF;

   IF ( p_ae_sys_rec.sob_type = 'P') THEN
      OPEN get_recon_accounting FOR sql_stmt
         USING p_calling_point, p_customer_trx_line_id,
   	       p_calling_point, p_customer_trx_id,
   	       p_calling_point, p_customer_trx_id,
	       p_calling_point, p_customer_trx_line_id,
	       p_calling_point, p_calling_point,
               p_customer_trx_line_id, p_calling_point,
               p_customer_trx_id, p_calling_point,
               p_customer_trx_id, p_calling_point,
               p_customer_trx_line_id, p_calling_point,
               p_calling_point, p_customer_trx_line_id,
               p_customer_trx_id,
               p_calling_point, p_customer_trx_id,
               p_calling_point, p_calling_point,
               p_customer_trx_line_id, p_customer_trx_id,
               p_calling_point, p_customer_trx_line_id,
               p_calling_point;

--{BUG4301323
   LOOP
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('get_recon_acct: ' || 'before fetch..');
     END IF;
 --get reconciliation entries customer trx line id, tax code, account
     FETCH get_recon_accounting into l_recon_rec;
     EXIT WHEN get_recon_accounting%NOTFOUND;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('get_recon_acct: ' || 'In the reverse reconciliation entries Loop ');
        arp_standard.debug('get_recon_acct: ' || 'tax_group_code_id  ' || l_recon_rec.tax_group_code_id);
        arp_standard.debug('get_recon_acct: ' || 'tax_code_id        ' || l_recon_rec.tax_code_id);
        arp_standard.debug('get_recon_acct: ' || 'location segment id ' || l_recon_rec.location_segment_id);
     END IF;

     l_ae_line_rec := l_ae_empty_line_rec;

       -- For each assignment with non zero reconciliation
       -- accounting create reversal entries
          l_ae_line_rec.ae_line_type           := l_recon_rec.source_type;
          l_ae_line_rec.ae_line_type_secondary := l_recon_rec.source_type_secondary;
          l_ae_line_rec.source_id              := p_ae_doc_rec.source_id;
          l_ae_line_rec.source_table           := p_ae_doc_rec.source_table;
          l_ae_line_rec.account                := l_recon_rec.code_combination_id;

       --Create amounts
          IF l_recon_rec.amount < 0 THEN
             l_ae_line_rec.entered_cr := abs(l_recon_rec.amount);
             l_ae_line_rec.entered_dr := NULL;
          ELSIF l_recon_rec.amount > 0 THEN
             l_ae_line_rec.entered_dr := abs(l_recon_rec.amount);
             l_ae_line_rec.entered_cr := NULL;
          END IF;

       --Create accounted amounts
          IF l_recon_rec.acctd_amount < 0 THEN
            l_ae_line_rec.accounted_cr := abs(l_recon_rec.acctd_amount);
            l_ae_line_rec.accounted_dr := NULL;
          ELSIF l_recon_rec.acctd_amount > 0 THEN
            l_ae_line_rec.accounted_dr := abs(l_recon_rec.acctd_amount);
            l_ae_line_rec.accounted_cr := NULL;
          END IF;

       --Create taxable amounts
          IF l_recon_rec.taxable_entered < 0 THEN
             l_ae_line_rec.taxable_entered_cr := abs(l_recon_rec.taxable_entered);
             l_ae_line_rec.taxable_entered_dr := NULL;
          ELSIF l_recon_rec.taxable_entered > 0 THEN
             l_ae_line_rec.taxable_entered_dr := abs(l_recon_rec.taxable_entered);
             l_ae_line_rec.taxable_entered_cr := NULL;
          END IF;

       --Create taxable accounted amounts
          IF l_recon_rec.taxable_accounted < 0 THEN
             l_ae_line_rec.taxable_accounted_cr := abs(l_recon_rec.taxable_accounted);
             l_ae_line_rec.taxable_accounted_dr := NULL;
          ELSIF l_recon_rec.taxable_accounted > 0 THEN
             l_ae_line_rec.taxable_accounted_dr := abs(l_recon_rec.taxable_accounted);
             l_ae_line_rec.taxable_accounted_cr := NULL;
          END IF;

          l_ae_line_rec.source_id_secondary := l_recon_rec.source_id_secondary;
          l_ae_line_rec.source_table_secondary := l_recon_rec.source_table_secondary;
          l_ae_line_rec.currency_code := l_recon_rec.currency_code;
          l_ae_line_rec.currency_conversion_rate := l_recon_rec.currency_conversion_rate;
          l_ae_line_rec.currency_conversion_type := l_recon_rec.currency_conversion_type;
          l_ae_line_rec.currency_conversion_date := l_recon_rec.currency_conversion_date;
          l_ae_line_rec.third_party_id := l_recon_rec.third_party_id;
          l_ae_line_rec.third_party_sub_id := l_recon_rec.third_party_sub_id;
          l_ae_line_rec.tax_group_code_id := l_recon_rec.tax_group_code_id;
          l_ae_line_rec.tax_code_id := l_recon_rec.tax_code_id;
          l_ae_line_rec.location_segment_id := l_recon_rec.location_segment_id;
          l_ae_line_rec.tax_link_id := '';
          l_ae_line_rec.reversed_source_id := '';

       --Reverse reversal entries for Bill
          Assign_Elements(p_ae_line_rec       =>    l_ae_line_rec  ,
                          p_g_ae_ctr          =>    p_g_ae_ctr     ,
                          p_g_ae_line_tbl     =>    p_g_ae_line_tbl );

    END LOOP; --get reconciliation entries

  -- Close cursor.
  CLOSE get_recon_accounting;

  END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Get_Recon_Acct()- ');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Get_Recon_Acct ');
      END IF;
      RAISE;
END get_recon_acct;

/*=========================================================================================
 | PRIVATE PROCEDURE Check_all_bills_closed
 |
 | DESCRIPTION
 |
 | All chained Bills starting from the current Bill must be closed for the Reconciliation
 | process to commence. The current Bill may be assigned to several other Bills so it is
 | important to ensure that thes Bills in turn are closed. This is because the deferred
 | tax liability on the originating Bill is transfered to all Bills, so the starting Bill
 | assignments representating deferred tax on the original Transactions must be reconciled
 | only if this condition is true.
 |
 | PARAMETERS
 |      p_customer_trx_id  IN   Current Bill or Transaction id
 |      p_all_br_closed    OUT NOCOPY  Flag indicating that the Bill or transaction
 |                              is a candidate for Reconciliation
 *========================================================================================*/
PROCEDURE Check_all_bills_closed(p_customer_trx_id     IN NUMBER      ,
                                 p_all_br_closed       IN OUT NOCOPY VARCHAR2     ) IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_RECONCILE.Check_all_bills_closed ()+ ');
  END IF;

  select 'N'
  into p_all_br_closed
  from dual
  where exists ( select /*+ ordered leading(rc.rct) use_nl(rc.rct ps)*/ 'x'
                 from ( select customer_trx_id
			from ra_customer_trx_lines rct
			start with br_ref_customer_trx_id = p_customer_trx_id
			connect by prior customer_trx_id = br_ref_customer_trx_id
		      ) rc, ar_payment_schedules ps
		 where ps.customer_trx_id = rc.customer_trx_id
                 and   ps.status = 'OP'
                 and   ps.customer_trx_id <> g_orig_cust_trx_id
               );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_RECONCILE.Check_all_bills_closed, -set p_all_br_closed to N ');
     arp_standard.debug('ARP_RECONCILE.Check_all_bills_closed ()- ');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND then
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('NO_DATA_FOUND : ARP_RECONCILE.Check_all_bills_closed, -set p_all_br_closed to Y ');
       END IF;
       p_all_br_closed := 'Y';
  WHEN OTHERS then
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Check_all_bills_closed ');
       END IF;
       RAISE;

END Check_all_bills_closed;

/*========================================================================
 | PRIVATE PROCEDURE Reconcile_trx_tax
 |
 | DESCRIPTION
 |      Reconciles the transaction deferred tax accounting. For transactions
 |      with no CM activity, reconciles actual accounting against the original
 |      tax on the Invoice. In case there is CM activity, since CM's have their
 |      own accounting, reconciles the actual non CM activity related accounting
 |      with accounting derived as a result of simulating a single activity equal
 |      to the sum of the non CM related activity and reconciles by tax code and
 |      account.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_ae_sys_rec    IN      System parameter details
 |      p_cust_inv_rec  IN      Contains currency, exchange rate, site
 |                              details for the bill
 |      p_g_ae_ctr      IN OUT NOCOPY  counter for lines table
 |      p_g_ae_line_tbl IN OUT NOCOPY  lines table containing reconciled entry
 *=======================================================================*/
PROCEDURE Reconcile_trx_tax(
                    p_mode                   IN             VARCHAR2                       ,
                    p_ae_doc_rec             IN             ae_doc_rec_type                ,
                    p_ae_event_rec           IN             ae_event_rec_type              ,
                    p_ae_sys_rec             IN             ae_sys_rec_type                ,
                    p_cust_inv_rec           IN             ra_customer_trx%ROWTYPE        ,
                    p_customer_trx_id        IN             NUMBER                         ,
                    p_br_cust_trx_line_id    IN             NUMBER                         ,
                    p_calling_point          IN             VARCHAR2                       ,
                    p_pay_class              IN             VARCHAR2                       ,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER                 ,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                ) IS


CURSOR get_single_activity IS
SELECT pay.payment_schedule_id                         payment_schedule_id,
       sum( nvl(app.amount_applied,0) +
            nvl(app.earned_discount_taken,0) +
            nvl(app.unearned_discount_taken,0))        amount,
      sum(nvl(app.acctd_amount_applied_to,0) +
          nvl(app.acctd_earned_discount_taken,0) +
          nvl(app.acctd_unearned_discount_taken,0))     acctd_amount,
       sum(nvl(app.line_applied,0) +
           nvl(app.line_ediscounted,0) +
           nvl(app.line_uediscounted,0))               line_amount,
       sum(nvl(app.tax_applied,0)     +
           nvl(app.tax_ediscounted,0) +
           nvl(app.tax_uediscounted,0))                tax_amount,
       sum(nvl(app.freight_applied,0) +
           nvl(app.freight_ediscounted,0) +
           nvl(app.freight_uediscounted,0))            freight_amount,
       sum(nvl(app.receivables_charges_applied,0) +
           nvl(app.charges_ediscounted,0) +
           nvl(app.charges_uediscounted,0))           receivables_charges_amount
FROM  ar_receivable_applications app,
      ar_payment_schedules pay
WHERE app.applied_customer_trx_id = p_customer_trx_id
AND   app.status = 'APP'
AND   nvl(app.confirmed_flag, 'Y') = 'Y'
AND   app.applied_payment_schedule_id = pay.payment_schedule_id
AND   app.application_type = 'CASH'       --only payments result in movement of
GROUP by pay.payment_schedule_id
UNION ALL --get adjustment bucket details
SELECT pay.payment_schedule_id                           payment_schedule_id,
       sum(nvl(adj.amount,0) * -1)                       amount,
       sum(nvl(adj.acctd_amount,0) * -1)                      acctd_amount,
       sum(nvl(adj.line_adjusted,0) * -1)                line_amount,
       sum(nvl(adj.tax_adjusted,0) * -1)                 tax_amount,
       sum(nvl(adj.freight_adjusted,0) * -1)             freight_amount,
       sum(nvl(adj.receivables_charges_adjusted,0) * -1) receivables_charges_amount
FROM ar_adjustments adj,
     ar_payment_schedules pay
WHERE adj.customer_trx_id = p_customer_trx_id
AND   adj.payment_schedule_id = pay.payment_schedule_id
AND   adj.status = 'A'
GROUP by pay.payment_schedule_id;

l_pay_tbl                 g_pay_tbl_type;
l_pay_empty_tbl           g_pay_tbl_type;

l_accum_amount            NUMBER := 0;
l_accum_acctd_amt         NUMBER := 0;
l_accum_line_amt          NUMBER := 0;
l_accum_tax_amt           NUMBER := 0;
l_accum_freight_amt       NUMBER := 0;
l_accum_charges_amt       NUMBER := 0;
l_accum_line_acctd_amt    NUMBER := 0;
l_accum_tax_acctd_amt     NUMBER := 0;
l_accum_freight_acctd_amt NUMBER := 0;
l_accum_charges_acctd_amt NUMBER := 0;
l_ctr                     NUMBER := 0;
l_cm_amt                  NUMBER := 0;
l_cm_acctd_amt            NUMBER := 0;
l_cm_line_amt             NUMBER := 0;
l_cm_tax_amt              NUMBER := 0;
l_cm_frt_amt              NUMBER := 0;
l_cm_chrg_amt             NUMBER := 0;
l_cached                  BOOLEAN;
l_simul_activity          VARCHAR2(1) := 'N';
l_pay_ctr                 NUMBER := 0;
l_all_br_closed           VARCHAR2(1) := 'N';

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_RECONCILE.Reconcile_Trx_Tax ()+ ');
     arp_standard.debug('Reconcile_trx_tax: ' || 'Input Parameters  ');
     arp_standard.debug('Reconcile_trx_tax: ' || 'p_customer_trx_id ' || p_customer_trx_id);
     arp_standard.debug('Reconcile_trx_tax: ' || 'p_br_cust_trx_line_id ' || p_br_cust_trx_line_id);
     arp_standard.debug('Reconcile_trx_tax: ' || 'p_calling_point ' || p_calling_point);
  END IF;

/*-----------------------------------------------------------------------------+
 | All chained Bills containing the current transaction assignment must be     |
 | closed for this process to commence. The current Bill may be assigned to    |
 | several other Bills so it is important to ensure that these Bills in turn   |
 | are closed. This is because the deferred tax liability on the originating   |
 | Bill is transfered to all Bills, so the starting Bill assignments           |
 | representating deferred tax on the original Transactions must be reconciled |
 | only if this condition is true.                                             |
 +----------------------------------------------------------------------------*/
   Check_all_bills_closed(p_customer_trx_id  => p_customer_trx_id ,
                          p_all_br_closed    => l_all_br_closed    );

 /*---------------------------------------------------------------------------+
  |Since the deferred tax liability for this transaction exists on Bills which|
  |are still open |hence the transaction reconciliation entry will be created |
  |when the Bill is closed so do not process.                                 |
  +---------------------------------------------------------------------------*/
   IF l_all_br_closed = 'N' THEN
      GOTO End_Transaction_Reconcile;
   END IF;

   l_pay_tbl := l_pay_empty_tbl;
   l_pay_ctr := 0;

 /*-----------------------------------------------------------------------------------------+
  |Level 1 Check.
  |Determine whether the Transaction being reconciled has CM applications which are non zero|
  |against it, if so then a flag is set to indicate that the reconciliation should be done  |
  |by simulating non-CM activity as CM's have their own accounting, so no deferred tax is   |
  |moved on application of the CM to the transaction, the deferred tax accounting is weighed|
  |by the accounting on the CM itself. Hence we reconcile against the actual deferred tax   |
  |accounting createed against the simulated single non CM activity related accounting.     |
  |In case there is no CM activity against a transaction, then we reconcile the actual      |
  |deferred tax accounting created against the original tax accounting on the transaction.  |
  |Since a user can create a CM (on account) and pay multiple deferred tax Transactions, we |
  |the tax accounting on the CM documents weighs the transactions to which it was applied.  |
  +-----------------------------------------------------------------------------------------*/
   BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Reconcile_trx_tax: ' || 'Check CM applications for deferred tax reconciliation ()+ ');
     END IF;

     l_cm_amt := 0; l_cm_acctd_amt := 0; l_cm_line_amt := 0;
     l_cm_tax_amt := 0; l_cm_frt_amt := 0; l_cm_chrg_amt := 0;

     SELECT sum(nvl(app.amount_applied,0))      ,
            sum(nvl(app.acctd_amount_applied_to,0)),
            sum(nvl(app.line_applied,0)),
            sum(nvl(app.tax_applied,0)),
            sum(nvl(app.freight_applied,0)),
            sum(nvl(app.receivables_charges_applied,0))
     INTO   l_cm_amt,
            l_cm_acctd_amt,
            l_cm_line_amt,
            l_cm_tax_amt,
            l_cm_frt_amt,
            l_cm_chrg_amt
     FROM ar_receivable_applications app
     WHERE app.applied_customer_trx_id = p_customer_trx_id
     AND   app.application_type = 'CM'
     AND   nvl(app.confirmed_flag, 'Y') = 'Y'
     AND   app.status = 'APP';

     IF ((l_cm_amt <> 0) OR (l_cm_acctd_amt <> 0) OR (l_cm_line_amt <> 0)
          OR (l_cm_tax_amt <> 0) OR (l_cm_frt_amt <> 0) OR (l_cm_chrg_amt <> 0)) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Reconcile_trx_tax: ' || 'Sum of CM applications to Transaction is not zero - simulate activity');
         END IF;
         l_simul_activity := 'Y';
     ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Reconcile_trx_tax: ' || 'Sum of CM applications is zero or no applications - do not simulate activity ');
         END IF;
         l_simul_activity := 'N';
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Reconcile_trx_tax: ' || 'Check CM applications for deferred tax reconciliation ()- ');
     END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('NO_DATA_FOUND : ARP_RECONCILE.Reconcile_trx_tax, CM applications do not exist ');
        END IF;
        l_simul_activity  := 'N';
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Reconcile_trx_tax: ' || 'set l_simul_activity ' || l_simul_activity);
        END IF;
     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Reconcile_trx_tax, in CM check applications sum');
        END IF;
        RAISE;

   END; --block to determine CM activity on transaction


 /*-------------------------------------------------------------------------------------------+
  |Level 2 check.                                                                             |
  |Check whether applications from CM to Transaction are not zero if so then the CM has been  |
  |applied to other transactions, and has in effect reduced its deferred tax amounts by tax   |
  |code - since we do not create deferred tax movements on CM application to Trx, hence we    |
  |simulate non CM activity on the CM which resulted in reducing its payment schedule balance.|
  |to reconcile its deferred tax.                                                             |
  +-------------------------------------------------------------------------------------------*/
   IF (l_simul_activity = 'N') AND (p_pay_class = 'CM') THEN
   BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Reconcile_trx_tax: ' || 'Check applications from CM to Transactions ()+ ');
     END IF;

     l_cm_amt := 0; l_cm_acctd_amt := 0; l_cm_line_amt := 0;
     l_cm_tax_amt := 0; l_cm_frt_amt := 0; l_cm_chrg_amt := 0;

     SELECT sum(nvl(app.amount_applied,0))      ,
            sum(nvl(app.acctd_amount_applied_to,0)),
            sum(nvl(app.line_applied,0)),
            sum(nvl(app.tax_applied,0)),
            sum(nvl(app.freight_applied,0)),
            sum(nvl(app.receivables_charges_applied,0))
     INTO   l_cm_amt,
            l_cm_acctd_amt,
            l_cm_line_amt,
            l_cm_tax_amt,
            l_cm_frt_amt,
            l_cm_chrg_amt
     FROM ar_receivable_applications app
     WHERE app.customer_trx_id = p_customer_trx_id
     AND   app.application_type = 'CM'
     AND   nvl(app.confirmed_flag, 'Y') = 'Y'
     AND   app.status = 'APP';

     IF ((l_cm_amt <> 0) OR (l_cm_acctd_amt <> 0) OR (l_cm_line_amt <> 0)
          OR (l_cm_tax_amt <> 0) OR (l_cm_frt_amt <> 0) OR (l_cm_chrg_amt <> 0)) THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Reconcile_trx_tax: ' || 'Applications from CM to Transaction are not zero - simulate activity');
         END IF;
         l_simul_activity := 'Y';
     ELSE
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('Reconcile_trx_tax: ' || 'Applications from CM to Transaction are zero - do not simulate activity ');
         END IF;
         l_simul_activity := 'N';
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Reconcile_trx_tax: ' || 'Check applications from CM to Transactions ()- ');
     END IF;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('NO_DATA_FOUND : ARP_RECONCILE.Reconcile_trx_tax, Applications from CM ' ||
                           'to Transaction do not exist ');
        END IF;
        l_simul_activity  := 'N';
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Reconcile_trx_tax: ' || 'set l_simul_activity ' || l_simul_activity);
        END IF;
     WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Reconcile_trx_tax, in CM applications ' ||
                           'from CM to Transaction');
        END IF;
        RAISE;

   END; --block to determine applications from CM to other transactions
   END IF;

 /*--------------------------------------------------------------------+
  |Cache the payment schedule details into the table if already cached |
  +--------------------------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Reconcile_trx_tax: ' || 'Processing Non CM activity ');
   END IF;

   IF (l_simul_activity = 'Y') THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Reconcile_trx_tax: ' || 'l_simul_activity ' || l_simul_activity);
      END IF;

      FOR l_activity IN get_single_activity LOOP

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Reconcile_trx_tax: ' || 'In loop get single activity');
          END IF;

          l_cached := FALSE;

          IF l_pay_tbl.EXISTS(l_pay_ctr) THEN

             FOR l_ctr IN l_pay_tbl.FIRST .. l_pay_tbl.LAST LOOP

                 IF (l_pay_tbl(l_ctr).applied_payment_schedule_id = l_activity.payment_schedule_id)
                 THEN
                   IF PG_DEBUG in ('Y', 'C') THEN
                      arp_standard.debug('Reconcile_trx_tax: ' || '5) Hit found in cache');
                   END IF;

               --Set the application record buckets
                   l_pay_tbl(l_ctr).applied_customer_trx_id     :=  p_customer_trx_id;

                   l_pay_tbl(l_ctr).applied_payment_schedule_id := l_activity.payment_schedule_id;

                   l_pay_tbl(l_ctr).amount_applied              :=
                       l_pay_tbl(l_ctr).amount_applied + l_activity.amount ;

                   l_pay_tbl(l_ctr).acctd_amount_applied_to     :=
                       l_pay_tbl(l_ctr).acctd_amount_applied_to + l_activity.acctd_amount ;

                   l_pay_tbl(l_ctr).line_applied                :=
                       l_pay_tbl(l_ctr).line_applied +l_activity.line_amount ;

                   l_pay_tbl(l_ctr).tax_applied                 :=
                       l_pay_tbl(l_ctr).tax_applied + l_activity.tax_amount ;

                   l_pay_tbl(l_ctr).freight_applied             :=
                       l_pay_tbl(l_ctr).freight_applied + l_activity.freight_amount ;

                   l_pay_tbl(l_ctr).receivables_charges_applied :=
                       l_pay_tbl(l_ctr).receivables_charges_applied + l_activity.receivables_charges_amount ;

                   l_cached := TRUE;

                   IF PG_DEBUG in ('Y', 'C') THEN
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').applied_customer_trx_id = '||l_pay_tbl(l_ctr).applied_customer_trx_id);
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').applied_payment_schedule_id = '||l_pay_tbl(l_ctr).applied_payment_schedule_id);
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').amount_applied = '||l_pay_tbl(l_ctr).amount_applied);
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').acctd_amount_applied_to = '||l_pay_tbl(l_ctr).acctd_amount_applied_to);
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').line_applied = '||l_pay_tbl(l_ctr).line_applied);
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').tax_applied= '||l_pay_tbl(l_ctr).tax_applied);
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').freight_applied= '||l_pay_tbl(l_ctr).freight_applied);
                      arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_ctr||').receivables_charges_applied= '||l_pay_tbl(l_ctr).receivables_charges_applied);
                   END IF;
                 END IF; --add to cache

              END LOOP; --process cached lines in payment table

           END IF; --payment schedule amounts table exists

         /*------------------------------------------------------------------------+
          |Cache the payment schedule details into the table if not already cached |
          +------------------------------------------------------------------------*/
           IF (NOT l_cached) THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Reconcile_trx_tax: ' || '5) Now caching');
              END IF;

              l_pay_ctr := l_pay_ctr + 1;

            --Set the application record buckets
              l_pay_tbl(l_pay_ctr).applied_customer_trx_id     := p_customer_trx_id;
              l_pay_tbl(l_pay_ctr).applied_payment_schedule_id := l_activity.payment_schedule_id;
              l_pay_tbl(l_pay_ctr).amount_applied              := l_activity.amount ;
              l_pay_tbl(l_pay_ctr).acctd_amount_applied_to     := l_activity.acctd_amount ;
              l_pay_tbl(l_pay_ctr).line_applied                := l_activity.line_amount ;
              l_pay_tbl(l_pay_ctr).tax_applied                 := l_activity.tax_amount ;
              l_pay_tbl(l_pay_ctr).freight_applied             := l_activity.freight_amount ;
              l_pay_tbl(l_pay_ctr).receivables_charges_applied := l_activity.receivables_charges_amount ;

              l_cached := TRUE;

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').applied_customer_trx_id = '||l_pay_tbl(l_pay_ctr).applied_customer_trx_id);
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').applied_payment_schedule_id = '||l_pay_tbl(l_pay_ctr).applied_payment_schedule_id);
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').amount_applied = '||l_pay_tbl(l_pay_ctr).amount_applied);
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').acctd_amount_applied_to = '||l_pay_tbl(l_pay_ctr).acctd_amount_applied_to);
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').line_applied = '||l_pay_tbl(l_pay_ctr).line_applied);
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').tax_applied= '||l_pay_tbl(l_pay_ctr).tax_applied);
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').freight_applied= '||l_pay_tbl(l_pay_ctr).freight_applied);
                 arp_standard.debug('Reconcile_trx_tax: ' || 'l_pay_tbl('||l_pay_ctr||').receivables_charges_applied= '||l_pay_tbl(l_pay_ctr).receivables_charges_applied);
              END IF;

           END IF; --not cached

      END LOOP; --process all activities for the current transaction

   END IF; --Simulate activity on document

  /*--------------------------------------------------------------------------+
   | Call the common Routine, to simulate an application for activity by      |
   | payment schedule.To reconcile against the actual accounting created in   |
   | the distributions accounting table.                                      |
   +--------------------------------------------------------------------------*/
    Process_Recon( p_mode                   =>    p_mode           ,
                   p_ae_doc_rec             =>    p_ae_doc_rec     ,
                   p_ae_event_rec           =>    p_ae_event_rec   ,
                   p_ae_sys_rec             =>    p_ae_sys_rec     ,
                   p_cust_inv_rec           =>    p_cust_inv_rec   ,
                   p_br_cust_trx_line_id    =>    p_br_cust_trx_line_id,
                   p_customer_trx_id        =>    p_customer_trx_id,
                   p_simul_app              =>    l_simul_activity ,
                   p_calling_point          =>    p_calling_point  ,
                   p_pay_ctr                =>    l_pay_ctr        ,
                   p_pay_tbl                =>    l_pay_tbl        ,
                   p_g_ae_ctr               =>    p_g_ae_ctr       ,
                   p_g_ae_line_tbl          =>    p_g_ae_line_tbl  );

<<End_Transaction_Reconcile>>
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_RECONCILE.Reconcile_trx_tax ()- ');
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION NO_DATA_FOUND: ARP_RECONCILE.Reconcile_trx_tax ');
   END IF;
   RAISE;

WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Reconcile_trx_tax ');
   END IF;
   RAISE;

END Reconcile_trx_tax;

/*========================================================================
 | PRIVATE PROCEDURE Reconcile_br_tax
 |
 | DESCRIPTION
 |      Reconciles each assignment on the Bill. Reconciliation is done
 |      only if the Bill is closed and all chained Bills are also closed.
 |      If an assignment is a Bill then this function is called recursively
 |      to go to the child bill and start processing with the same condition
 |      checks as was done for the parent bill.
 |
 | PARAMETERS
 |      p_mode            IN      Document or Accounting Event mode
 |      p_ae_doc_rec      IN      Document Record
 |      p_ae_event_rec    IN      Event Record
 |      p_ae_sys_rec      IN      System parameter details
 |      p_customer_trx_id IN      Bills Receivable trx id               ,
 |      p_g_ae_ctr        IN OUT NOCOPY  counter for global accounting lines table
 |      p_g_ae_line_tbl   IN OUT NOCOPY  accounting lines table containing reconciled
 |                                entry
 *=======================================================================*/
PROCEDURE Reconcile_br_tax(
                    p_mode                   IN             VARCHAR2                       ,
                    p_ae_doc_rec             IN             ae_doc_rec_type                ,
                    p_ae_event_rec           IN             ae_event_rec_type              ,
                    p_ae_sys_rec             IN             ae_sys_rec_type                ,
                    p_customer_trx_id        IN             NUMBER                         ,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER                 ,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                ) IS

 CURSOR get_assignments(p_customer_trx_id IN NUMBER) is
   SELECT ctl.customer_trx_id                     br_cust_trx_id             ,
          ctl.customer_trx_line_id                br_customer_trx_line_id    ,
          ctl.br_ref_customer_trx_id              br_ref_customer_trx_id     ,
          ctl.br_ref_payment_schedule_id          br_ref_payment_schedule_id ,
          ct.drawee_site_use_id                   drawee_site_use_id         ,
          ct.invoice_currency_code                invoice_currency_code      ,
            ct.exchange_rate       exchange_rate,
           ct.exchange_rate_type        exchange_rate_type,
          ct.exchange_date                 exchange_date,
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
     drawee_site_use_id         ra_customer_trx.drawee_site_use_id%TYPE,
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

l_cust_inv_rec ra_customer_trx%ROWTYPE;

l_assn_ctr      BINARY_INTEGER := 0;

l_pay_tbl       g_pay_tbl_type;

l_pay_empty_tbl g_pay_tbl_type;

l_pay_ctr       BINARY_INTEGER := 0;

l_br_tbl        l_br_tbl_type;

l_app_rec       ar_receivable_applications%ROWTYPE;

--The bill closed flag is defaulted to N
l_all_br_closed VARCHAR2(1) := 'N';
l_pay_class ar_payment_schedules.class%TYPE;
l_closed_pymt_yn VARCHAR2(1);

l_required BOOLEAN;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_RECONCILE.Reconcile_br_tax ()+');
  END IF;

/*----------------------------------------------------------------------------------------+
 | All chained Bills starting from the current Bill must be closed for the Reconciliation |
 | process to commence. The current Bill may be assigned to several other Bills so it is  |
 | important to ensure that thes Bills in turn are closed. This is because the deferred   |
 | tax liability on the originating Bill is transfered to all Bills, so the starting Bill |
 | assignments representating deferred tax on the original Transactions must be reconciled|
 | only if this condition is true.                                                        |
 +----------------------------------------------------------------------------------------*/
 Check_all_bills_closed(p_customer_trx_id  => p_customer_trx_id ,
                        p_all_br_closed    => l_all_br_closed    );

 IF (l_all_br_closed = 'Y') THEN

/*----------------------------------------------------------------------------------+
 | Get the shadow adjustments record for usage by the tax accounting engine to      |
 | create deferred tax accounting as though a single application was made to each   |
 | shadow adjustment (transaction assignment).                                      |
 +----------------------------------------------------------------------------------*/
  FOR l_assign_rec IN get_assignments(p_customer_trx_id) LOOP

    l_assn_ctr := l_assn_ctr + 1;

    l_br_tbl(l_assn_ctr).br_cust_trx_id             := l_assign_rec.br_cust_trx_id;
    l_br_tbl(l_assn_ctr).br_customer_trx_line_id    := l_assign_rec.br_customer_trx_line_id;
    l_br_tbl(l_assn_ctr).br_ref_customer_trx_id     := l_assign_rec.br_ref_customer_trx_id;
    l_br_tbl(l_assn_ctr).br_ref_payment_schedule_id := l_assign_rec.br_ref_payment_schedule_id;
    l_br_tbl(l_assn_ctr).drawee_site_use_id         := l_assign_rec.drawee_site_use_id;
    l_br_tbl(l_assn_ctr).br_adj_id                  := l_assign_rec.br_adj_id;
    l_br_tbl(l_assn_ctr).br_adj_amt                 := l_assign_rec.br_adj_amt;
    l_br_tbl(l_assn_ctr).br_adj_acctd_amt           := l_assign_rec.br_adj_acctd_amt;
    l_br_tbl(l_assn_ctr).br_adj_line_amt            := l_assign_rec.br_adj_line_amt;
    l_br_tbl(l_assn_ctr).br_adj_tax_amt             := l_assign_rec.br_adj_tax_amt;
    l_br_tbl(l_assn_ctr).br_adj_frt_amt             := l_assign_rec.br_adj_frt_amt;
    l_br_tbl(l_assn_ctr).br_adj_chrg_amt            := l_assign_rec.br_adj_chrg_amt;

 /*----------------------------------------------------------------------------------+
  | Derive the currency, exchange rate and third party information. Assignments on   |
  | a bill could have different third part and third party sub id information, hence |
  | we rederive it. The currency and exchange rate details of assignments match Bill |
  +----------------------------------------------------------------------------------*/
    l_cust_inv_rec.invoice_currency_code            := l_assign_rec.invoice_currency_code;
    l_cust_inv_rec.exchange_rate                    := l_assign_rec.exchange_rate;
    l_cust_inv_rec.exchange_rate_type               := l_assign_rec.exchange_rate_type;
    l_cust_inv_rec.exchange_date                    := l_assign_rec.exchange_date;
    l_cust_inv_rec.trx_date                         := l_assign_rec.trx_date;
    l_cust_inv_rec.bill_to_customer_id              := l_assign_rec.bill_to_customer_id;
    l_cust_inv_rec.bill_to_site_use_id              := l_assign_rec.bill_to_site_use_id;

 /*------------------------------------------------------------------------------+
  | Now create a application to simulate a single activity such as a payment to  |
  | each shadow adjustment (transaction assignment) on the Bill.                 |
  +------------------------------------------------------------------------------*/
    l_pay_tbl := l_pay_empty_tbl;
    l_pay_ctr := 1;               --always for each recursive call for a Bill to this routine

  --Set the application record buckets
    l_pay_tbl(l_pay_ctr).applied_customer_trx_id     := l_br_tbl(l_assn_ctr).br_ref_customer_trx_id;
    l_pay_tbl(l_pay_ctr).applied_payment_schedule_id := l_br_tbl(l_assn_ctr).br_ref_payment_schedule_id;
    l_pay_tbl(l_pay_ctr).amount_applied              := l_br_tbl(l_assn_ctr).br_adj_amt       * -1;
    l_pay_tbl(l_pay_ctr).acctd_amount_applied_to     := l_br_tbl(l_assn_ctr).br_adj_acctd_amt * -1;
    l_pay_tbl(l_pay_ctr).line_applied                := l_br_tbl(l_assn_ctr).br_adj_line_amt  * -1;
    l_pay_tbl(l_pay_ctr).tax_applied                 := l_br_tbl(l_assn_ctr).br_adj_tax_amt   * -1;
    l_pay_tbl(l_pay_ctr).freight_applied             := l_br_tbl(l_assn_ctr).br_adj_frt_amt   * -1;
    l_pay_tbl(l_pay_ctr).receivables_charges_applied := l_br_tbl(l_assn_ctr).br_adj_chrg_amt  * -1;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP applied_customer_trx_id ' || l_pay_tbl(l_pay_ctr).applied_customer_trx_id);
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP applied_payment_schedule_id ' || l_pay_tbl(l_pay_ctr).applied_payment_schedule_id);
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP amount_applied ' || l_pay_tbl(l_pay_ctr).amount_applied);
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP acctd_amount_applied_to ' || l_pay_tbl(l_pay_ctr).acctd_amount_applied_to);
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP line_applied ' || l_pay_tbl(l_pay_ctr).line_applied);
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP tax_applied ' || l_pay_tbl(l_pay_ctr).tax_applied);
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP freight_applied ' || l_pay_tbl(l_pay_ctr).freight_applied);
       arp_standard.debug('Reconcile_br_tax: ' || 'l_pay_tbl APP receivables_charges_applied ' || l_pay_tbl(l_pay_ctr).receivables_charges_applied);
       arp_standard.debug('Reconcile_br_tax: ' || 'Drawee Site Id ' || l_br_tbl(l_assn_ctr).drawee_site_use_id);
    END IF;

  /*--------------------------------------------------------------------------+
   | Recursive call required because current assignment is a bill of exchange.|
   | So the process of verifying that all Bills to which the current Bill is  |
   | assigned are closed, so that the assignments on the Bill will be         |
   | reconciled to simulate an application against each assignments shadow    |
   | adjustment.                                                              |
   +--------------------------------------------------------------------------*/
    IF l_br_tbl(l_assn_ctr).drawee_site_use_id IS NOT NULL THEN

       Reconcile_br_tax( p_mode               =>   p_mode         ,
                         p_ae_doc_rec         =>   p_ae_doc_rec   ,
                         p_ae_event_rec       =>   p_ae_event_rec ,
                         p_ae_sys_rec         =>   p_ae_sys_rec   ,
                         p_customer_trx_id    =>   l_br_tbl(l_assn_ctr).br_ref_customer_trx_id,
                         p_g_ae_ctr           =>   p_g_ae_ctr     ,
                         p_g_ae_line_tbl      =>   p_g_ae_line_tbl  );
    ELSE
     /*--------------------------------------------------------------------------+
      | If the Transaction is not deferred then do not do any process as there is|
      | no deferred tax to reconcile.                                            |
      +--------------------------------------------------------------------------*/
       Check_Entry(p_customer_trx_id  =>  l_br_tbl(l_assn_ctr).br_ref_customer_trx_id,
                   p_type             =>  'TRAN',
                   p_required         =>  l_required              );

       IF (l_required) THEN

  /*--------------------------------------------------------------------------+
   | Call the common Routine, to simulate an application for each adjustment  |
   | on the bills line therby deriving accounting for single activity on Bills|
   | line. Subsequently retrieve accounting actually created from accounting  |
   | table due to past activities and Reconcile what has been created with.   |
   | what should have been created if there were single applications to each  |
   | assignment.                                                              |
   +--------------------------------------------------------------------------*/
           Process_Recon( p_mode                   =>    p_mode         ,
                          p_ae_doc_rec             =>    p_ae_doc_rec   ,
                          p_ae_event_rec           =>    p_ae_event_rec ,
                          p_ae_sys_rec             =>    p_ae_sys_rec   ,
                          p_cust_inv_rec           =>    l_cust_inv_rec ,
                          p_br_cust_trx_line_id    =>    l_br_tbl(l_assn_ctr).br_customer_trx_line_id,
                          p_customer_trx_id        =>    l_br_tbl(l_assn_ctr).br_ref_customer_trx_id,
                          p_simul_app              =>    'Y'            ,
                          p_calling_point          =>    'BILL'         ,
                          p_pay_ctr                =>    l_pay_ctr      ,
                          p_pay_tbl                =>    l_pay_tbl      ,
                          p_g_ae_ctr               =>    p_g_ae_ctr     ,
                          p_g_ae_line_tbl          =>    p_g_ae_line_tbl  );

     /*----------------------------------------------------------------------+
      | Determine whether the payment schedule of the Transaction is closed, |
      | only on closure do we need to create the Reconciliation entry.       |
      +----------------------------------------------------------------------*/
             Detect_Closure(p_customer_trx_id        =>  l_br_tbl(l_assn_ctr).br_ref_customer_trx_id,
                            p_pay_sched_upd_yn       =>  'Y',
                            p_pay_sched_upd_cm_yn    =>  null,
                            p_activity_amt           =>   0 ,
                            p_activity_acctd_amt     =>   0 ,
                            p_ae_sys_rec             =>  p_ae_sys_rec ,
                            p_closed_pymt_yn         =>  l_closed_pymt_yn,
                            p_pay_class              =>  l_pay_class        );

  /*--------------------------------------------------------------------------+
   | Call the Transaction Reconciliation routine for this assignment. This is |
   | necessary because the transaction which is closed and assigned to another|
   | Bill needs to be Reconciled after the Bills assignment reconciliation    |
   | entry is built. The transaction reconciliation routine is called only if |
   | all Bills to which it has been assigned are also closed in addition to   |
   | it being closed. It is is also important that the Transaction assignment |
   | must be closed to Reconcile it.                                          |
   +--------------------------------------------------------------------------*/
             IF (l_closed_pymt_yn = 'Y') THEN
               Reconcile_trx_tax(p_mode                   => p_mode                          ,
                                 p_ae_doc_rec             => p_ae_doc_rec                    ,
                                 p_ae_event_rec           => p_ae_event_rec                  ,
                                 p_ae_sys_rec             => p_ae_sys_rec                    ,
                                 p_cust_inv_rec           => l_cust_inv_rec                  ,
                                 p_customer_trx_id        => l_br_tbl(l_assn_ctr).br_ref_customer_trx_id,
                                 p_br_cust_trx_line_id    => l_br_tbl(l_assn_ctr).br_customer_trx_line_id,
                                 p_calling_point          => 'BLTR'                          ,
                                 p_pay_class              => l_pay_class                     ,
                                 p_g_ae_ctr               => p_g_ae_ctr                      ,
                                 p_g_ae_line_tbl          => p_g_ae_line_tbl                    );

             END IF; --payment schedule of Trx is closed

       END IF; -- processing required for deferred transaction

    END IF; --drawee site is not null

  END LOOP; --process each shadow adjustment

 END IF; --All chained bills are closed

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('ARP_RECONCILE.Reconcile_br_tax ()-');
 END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION NO_DATA_FOUND : ARP_RECONCILE.Reconcile_br_tax ');
   END IF;
   RAISE;

WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Reconcile_br_tax ');
   END IF;
   RAISE;

END Reconcile_br_tax;

/* ==========================================================================
 | PROCEDURE Detect_Closure
 |
 | DESCRIPTION
 |    This routine detects whether a transaction is closed. Closure is defined
 |    as a point where the sum total for the amount due remaining and the
 |    accounted amount due remaining is zero for all installments on the
 |    Bill or Transaction. This routine passes a flag indicating as to whether
 |    reconciliation is required.
 |
 | SCOPE - PRIVATE
 |
 | PARAMETERS
 |    p_customer_trx_id                Transaction identifier
 |    p_pay_sched_upd_yn               Value denotes whether the payment
 |                                     schedule been updated or not, if not
 |                                     then this routine will add the activity
 |                                     on the Bill or transaction to the
 |                                     installments
 |                                     to make this decision
 |    p_activity_amt                   previous activity amount
 |    p_activity_acctd_amt             previous activity accounted amount
 |    p_closed_pymt_yn                 A Y value indicates that the Bill or
 |                                     transaction is a candidate for
 |				       reconciliation
 *==========================================================================*/
PROCEDURE Detect_Closure(p_customer_trx_id        IN  NUMBER   ,
                         p_pay_sched_upd_yn       IN  VARCHAR2 ,
                         p_pay_sched_upd_cm_yn    IN  VARCHAR2 ,
                         p_activity_amt           IN  NUMBER   ,
                         p_activity_acctd_amt     IN  NUMBER   ,
                         p_ae_sys_rec             IN  ae_sys_rec_type,
                         p_closed_pymt_yn         OUT NOCOPY VARCHAR2 ,
                         p_pay_class              OUT NOCOPY VARCHAR2 ) IS

l_amount_due_remaining       NUMBER := 0;
l_acctd_amount_due_remaining NUMBER := 0;
l_pay_sched_upd_yn           VARCHAR2(1);

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_RECONCILE.Detect_Closure()+');
    END IF;

 /*---------------------------------------------------------------------------+
  | Retrieve amount and accounted amount remaining for all installments on the|
  | Transaction                                                               |
  +---------------------------------------------------------------------------*/

   IF (p_ae_sys_rec.sob_type = 'P') THEN
      select sum(pay.amount_due_remaining)         ,
             sum(pay.acctd_amount_due_remaining)   ,
             max(pay.class)
      into l_amount_due_remaining,
           l_acctd_amount_due_remaining,
           p_pay_class
      from ar_payment_schedules pay
      where pay.customer_trx_id = p_customer_trx_id;
    END IF;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Detect_Closure: ' || 'p_customer_trx_id        ' || p_customer_trx_id);
       arp_standard.debug('Detect_Closure: ' || 'pay_class                ' || p_pay_class);
       arp_standard.debug('Detect_Closure: ' || 'p_pay_sched_upd_yn       ' || p_pay_sched_upd_yn);
       arp_standard.debug('Detect_Closure: ' || 'p_pay_sched_upd_cm_yn    ' || p_pay_sched_upd_cm_yn);
       arp_standard.debug('Detect_Closure: ' || 'g_call_num               ' || g_call_num);
       arp_standard.debug('Detect_Closure: ' || 'Parameter p_activity_amt ' || p_activity_amt);
       arp_standard.debug('Detect_Closure: ' || 'Parameter p_activity_acctd_amt ' || p_activity_acctd_amt);
       arp_standard.debug('Detect_Closure: ' || 'Selected pay l_amount_due_remaining ' || l_amount_due_remaining);
       arp_standard.debug('Detect_Closure: ' || 'Selected pay l_acctd_amount_due_remaining ' || l_acctd_amount_due_remaining);
    END IF;

  --Set the payment schedule updated flag
    IF (p_pay_class = 'CM') AND (g_call_num = 2) AND (p_pay_sched_upd_cm_yn IS NOT NULL) THEN
       l_pay_sched_upd_yn := p_pay_sched_upd_cm_yn;
    ELSE
       l_pay_sched_upd_yn := p_pay_sched_upd_yn;
    END IF;

 /*---------------------------------------------------------------------------+
  | Add this to the amount and accounted amount due to activity. Zero amounts |
  | will indicate that the Transaction has been closed.                       |
   +--------------------------------------------------------------------------*/
    IF (NVL(l_pay_sched_upd_yn, 'N') = 'N') THEN
       l_amount_due_remaining := l_amount_due_remaining + p_activity_amt;
       l_acctd_amount_due_remaining := l_acctd_amount_due_remaining +
                                       p_activity_acctd_amt;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Detect_Closure: ' || 'Payment schedule not updated hence calculating remaining amounts ');
          arp_standard.debug('Detect_Closure: ' || 'l_amount_due_remaining + p_activity_amt ' || l_amount_due_remaining);
          arp_standard.debug('Detect_Closure: ' || 'l_acctd_amount_due_remaining + p_activity_acctd_amt ' || l_acctd_amount_due_remaining);
       END IF;
    END IF;

  /*---------------------------------------------------------------------+
   | Set the payment schedule closed flag to indicate as to whether      |
   | reconciliation is required.                                         |
   +---------------------------------------------------------------------*/

    IF ((l_amount_due_remaining + l_acctd_amount_due_remaining) <> 0) THEN
       p_closed_pymt_yn := 'N'; --paymentschedule is not closed so do not call reconciliation routine
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Detect_Closure: ' || 'Transaction ' || p_customer_trx_id || ' payment schedule is not closed - do not reconcile ');
       END IF;
    ELSE
       p_closed_pymt_yn := 'Y';
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Detect_Closure: ' || 'Transaction ' || p_customer_trx_id || ' payment schedule is closed - reconcile ');
       END IF;
    END IF;

<<end_process_lbl1>>

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_RECONCILE.Detect_Closure()-');
    END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION NO_DATA_FOUND : ARP_RECONCILE.Detect_Closure ');
   END IF;
   RAISE;

WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Detect_Closure ');
   END IF;
   RAISE;

END Detect_Closure;

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
 *==========================================================================*/
PROCEDURE Assign_Elements(p_ae_line_rec           IN  OUT NOCOPY ae_line_rec_type           ,
                          p_g_ae_ctr              IN  OUT NOCOPY BINARY_INTEGER         ,
                          p_g_ae_line_tbl         IN  OUT NOCOPY ae_line_tbl_type  ) IS

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('ARP_RECONCILE.Assign_Elements()+');
    END IF;

  /*--------------------------------------------------------------------------------+
   | Do not create 0 amount Reconciliation entries if tax and taxable amounts are 0 |
   +--------------------------------------------------------------------------------*/
    IF ((nvl(p_ae_line_rec.entered_dr,0) + nvl(p_ae_line_rec.entered_cr,0) +
         nvl(p_ae_line_rec.accounted_dr,0) + nvl(p_ae_line_rec.accounted_cr,0) +
         nvl(p_ae_line_rec.taxable_entered_dr,0) + nvl(p_ae_line_rec.taxable_entered_cr,0) +
         nvl(p_ae_line_rec.taxable_accounted_dr,0) + nvl(p_ae_line_rec.taxable_accounted_cr,0)) = 0)
    THEN
       GOTO end_assign_elements;
    END IF;

  /*--------------------------------------------------------------------------------+
   | 1) Populate 0 values for the accounted amounts based on the sign of the amounts|
   +--------------------------------------------------------------------------------*/
   --Populate a 0 amount if the other bucket is null for accounted amounts
    IF ((p_ae_line_rec.entered_dr IS NOT NULL)
      AND (p_ae_line_rec.accounted_dr IS NULL) AND (p_ae_line_rec.accounted_cr IS NULL)) THEN
          p_ae_line_rec.accounted_dr := 0;
    ELSIF ((p_ae_line_rec.entered_cr IS NOT NULL)
          AND (p_ae_line_rec.accounted_cr IS NULL) AND (p_ae_line_rec.accounted_dr IS NULL)) THEN
          p_ae_line_rec.accounted_cr := 0;
    END IF;

  /*--------------------------------------------------------------------------------+
   | 1) Populate 0 values for the amounts based on the sign of the accounted amounts|
   +--------------------------------------------------------------------------------*/
    IF ((p_ae_line_rec.accounted_dr IS NOT NULL)
        AND (p_ae_line_rec.entered_dr IS NULL) AND (p_ae_line_rec.entered_cr IS NULL)) THEN
          p_ae_line_rec.entered_dr := 0;
    ELSIF ((p_ae_line_rec.accounted_cr IS NOT NULL)
         AND (p_ae_line_rec.entered_cr IS NULL) AND (p_ae_line_rec.entered_dr IS NULL)) THEN
          p_ae_line_rec.entered_cr := 0;
    END IF;

  /*--------------------------------------------------------------------------------+
   | 2) Populate 0 values for the taxable accounted amounts based on the sign of the|
   |    taxable amounts                                                             |
   +--------------------------------------------------------------------------------*/
    IF ((p_ae_line_rec.taxable_entered_dr IS NOT NULL)
       AND (p_ae_line_rec.taxable_accounted_dr IS NULL) AND (p_ae_line_rec.taxable_accounted_cr IS NULL)) THEN
          p_ae_line_rec.taxable_accounted_dr := 0;
    ELSIF ((p_ae_line_rec.taxable_entered_cr IS NOT NULL)
         AND (p_ae_line_rec.taxable_accounted_cr IS NULL) AND (p_ae_line_rec.taxable_accounted_dr IS NULL)) THEN
          p_ae_line_rec.taxable_accounted_cr := 0;
    END IF;

  /*--------------------------------------------------------------------------------+
   | 2) Populate 0 values for the taxable amounts based on the sign of the taxable  |
   |    accounted amounts                                                           |
   +--------------------------------------------------------------------------------*/
    IF ((p_ae_line_rec.taxable_accounted_dr IS NOT NULL)
        AND (p_ae_line_rec.taxable_entered_dr IS NULL) AND (p_ae_line_rec.taxable_entered_cr IS NULL)) THEN
          p_ae_line_rec.taxable_entered_dr := 0;
    ELSIF ((p_ae_line_rec.taxable_accounted_cr IS NOT NULL)
         AND (p_ae_line_rec.taxable_entered_cr IS NULL) AND (p_ae_line_rec.taxable_entered_dr IS NULL)) THEN
          p_ae_line_rec.taxable_entered_cr := 0;
    END IF;

  /*-----------------------------------------------------------------------------------+
   | 3) Populate 0 values for the taxable amounts based on the sign of the amounts     |
   +-----------------------------------------------------------------------------------*/
    IF ((p_ae_line_rec.entered_dr IS NOT NULL)
      AND (p_ae_line_rec.taxable_entered_dr IS NULL) AND (p_ae_line_rec.taxable_entered_cr IS NULL)) THEN
       p_ae_line_rec.taxable_entered_dr := 0;
    ELSIF ((p_ae_line_rec.entered_cr IS NOT NULL)
         AND (p_ae_line_rec.taxable_entered_cr IS NULL) AND (p_ae_line_rec.taxable_entered_dr IS NULL)) THEN
          p_ae_line_rec.taxable_entered_cr := 0;
    END IF;

  /*--------------------------------------------------------------------------------+
   | 3) Populate 0 values for the taxable accounted amounts based on the sign of the|
   |    accounted amounts                                                           |
   +--------------------------------------------------------------------------------*/
  --Now for the accounted amounts
    IF ((p_ae_line_rec.accounted_dr IS NOT NULL)
      AND (p_ae_line_rec.taxable_accounted_dr IS NULL) AND (p_ae_line_rec.taxable_accounted_cr IS NULL)) THEN
       p_ae_line_rec.taxable_accounted_dr := 0;
    ELSIF ((p_ae_line_rec.accounted_cr IS NOT NULL)
         AND (p_ae_line_rec.taxable_accounted_cr IS NULL) AND (p_ae_line_rec.taxable_accounted_dr IS NULL)) THEN
          p_ae_line_rec.taxable_accounted_cr := 0;
    END IF;

  /*--------------------------------------------------------------------------------+
   | 4) Populate 0 values for the amounts based on the sign of the taxable accounted|
   |    amounts                                                                     |
   +--------------------------------------------------------------------------------*/
    IF ((p_ae_line_rec.taxable_entered_dr IS NOT NULL)
       AND (p_ae_line_rec.entered_dr IS NULL) AND (p_ae_line_rec.entered_cr IS NULL)) THEN
       p_ae_line_rec.entered_dr := 0;
    ELSIF ((p_ae_line_rec.taxable_entered_cr IS NOT NULL)
         AND (p_ae_line_rec.entered_cr IS NULL) AND (p_ae_line_rec.entered_dr IS NULL)) THEN
          p_ae_line_rec.entered_cr := 0;
    END IF;

  /*--------------------------------------------------------------------------------+
   | 4) Populate 0 values for the accounted amounts based on the sign of the taxable|
   |    accounted amounts                                                           |
   +--------------------------------------------------------------------------------*/
    IF ((p_ae_line_rec.taxable_accounted_dr IS NOT NULL)
      AND (p_ae_line_rec.accounted_dr IS NULL) AND (p_ae_line_rec.accounted_cr IS NULL)) THEN
       p_ae_line_rec.accounted_dr := 0;
    ELSIF ((p_ae_line_rec.taxable_accounted_cr IS NOT NULL)
         AND (p_ae_line_rec.accounted_cr IS NULL) AND (p_ae_line_rec.accounted_dr IS NULL)) THEN
          p_ae_line_rec.accounted_cr := 0;
    END IF;

  /*------------------------------------------------------+
   | Store AE Line elements in Global AE Lines table      |
   +------------------------------------------------------*/
    p_g_ae_ctr := p_g_ae_ctr +1;

    p_g_ae_line_tbl(p_g_ae_ctr).ae_line_type             :=  p_ae_line_rec.ae_line_type;
    p_g_ae_line_tbl(p_g_ae_ctr).ae_line_type_secondary   :=  p_ae_line_rec.ae_line_type_secondary;
    p_g_ae_line_tbl(p_g_ae_ctr).source_id                :=  p_ae_line_rec.source_id;
    p_g_ae_line_tbl(p_g_ae_ctr).source_table             :=  p_ae_line_rec.source_table;
    p_g_ae_line_tbl(p_g_ae_ctr).account                  :=  p_ae_line_rec.account;
    p_g_ae_line_tbl(p_g_ae_ctr).entered_dr               :=  p_ae_line_rec.entered_dr;
    p_g_ae_line_tbl(p_g_ae_ctr).entered_cr               :=  p_ae_line_rec.entered_cr;
    p_g_ae_line_tbl(p_g_ae_ctr).accounted_dr             :=  p_ae_line_rec.accounted_dr;
    p_g_ae_line_tbl(p_g_ae_ctr).accounted_cr             :=  p_ae_line_rec.accounted_cr;
    p_g_ae_line_tbl(p_g_ae_ctr).source_id_secondary      :=  p_ae_line_rec.source_id_secondary;
    p_g_ae_line_tbl(p_g_ae_ctr).source_table_secondary   :=  p_ae_line_rec.source_table_secondary;
    p_g_ae_line_tbl(p_g_ae_ctr).currency_code            :=  p_ae_line_rec.currency_code;
    p_g_ae_line_tbl(p_g_ae_ctr).currency_conversion_rate :=  p_ae_line_rec.currency_conversion_rate;
    p_g_ae_line_tbl(p_g_ae_ctr).currency_conversion_type :=  p_ae_line_rec.currency_conversion_type;
    p_g_ae_line_tbl(p_g_ae_ctr).currency_conversion_date :=  p_ae_line_rec.currency_conversion_date;
    p_g_ae_line_tbl(p_g_ae_ctr).third_party_id           :=  p_ae_line_rec.third_party_id;
    p_g_ae_line_tbl(p_g_ae_ctr).third_party_sub_id       :=  p_ae_line_rec.third_party_sub_id;
    p_g_ae_line_tbl(p_g_ae_ctr).tax_group_code_id        :=  p_ae_line_rec.tax_group_code_id;
    p_g_ae_line_tbl(p_g_ae_ctr).tax_code_id              :=  p_ae_line_rec.tax_code_id;
    p_g_ae_line_tbl(p_g_ae_ctr).location_segment_id      :=  p_ae_line_rec.location_segment_id;
    p_g_ae_line_tbl(p_g_ae_ctr).taxable_entered_dr       :=  p_ae_line_rec.taxable_entered_dr;
    p_g_ae_line_tbl(p_g_ae_ctr).taxable_entered_cr       :=  p_ae_line_rec.taxable_entered_cr;
    p_g_ae_line_tbl(p_g_ae_ctr).taxable_accounted_dr     :=  p_ae_line_rec.taxable_accounted_dr;
    p_g_ae_line_tbl(p_g_ae_ctr).taxable_accounted_cr     :=  p_ae_line_rec.taxable_accounted_cr;
    p_g_ae_line_tbl(p_g_ae_ctr).applied_from_doc_table   :=  p_ae_line_rec.applied_from_doc_table;
    p_g_ae_line_tbl(p_g_ae_ctr).applied_from_doc_id      :=  p_ae_line_rec.applied_from_doc_id;
    p_g_ae_line_tbl(p_g_ae_ctr).applied_to_doc_table     :=  p_ae_line_rec.applied_to_doc_table;
    p_g_ae_line_tbl(p_g_ae_ctr).applied_to_doc_id        :=  p_ae_line_rec.applied_to_doc_id;
    p_g_ae_line_tbl(p_g_ae_ctr).tax_link_id              :=  p_ae_line_rec.tax_link_id;
    p_g_ae_line_tbl(p_g_ae_ctr).reversed_source_id       :=  p_ae_line_rec.reversed_source_id;
    p_g_ae_line_tbl(p_g_ae_ctr).summarize_flag           :=  'N';

    Dump_Line_Amts(p_ae_line_rec);

<<end_assign_elements>>
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'ARP_RECONCILE.Assign_Elements()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Assign_Elements');
     END IF;
     RAISE;

END Assign_Elements;

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
PROCEDURE Dump_Line_Amts(p_ae_line_rec  IN ae_line_rec_type) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Dump_Line_Amts()+');
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_line_type = ' || p_ae_line_rec.ae_line_type);
       arp_standard.debug('Dump_Line_Amts: ' || 'ae_line_type_secondary = ' || p_ae_line_rec.ae_line_type_secondary);
       arp_standard.debug('Dump_Line_Amts: ' || 'source_id    = ' || p_ae_line_rec.source_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'source_table = ' || p_ae_line_rec.source_table);
       arp_standard.debug('Dump_Line_Amts: ' || 'account      = ' || p_ae_line_rec.account);
       arp_standard.debug('Dump_Line_Amts: ' || 'entered_dr   = ' || p_ae_line_rec.entered_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'entered_cr   = ' || p_ae_line_rec.entered_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'accounted_dr = ' || p_ae_line_rec.accounted_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'accounted_cr = ' || p_ae_line_rec.accounted_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'source_id_secondary = ' || p_ae_line_rec.source_id_secondary);
       arp_standard.debug('Dump_Line_Amts: ' || 'source_table_secondary = ' || p_ae_line_rec.source_table_secondary);
       arp_standard.debug('Dump_Line_Amts: ' || 'currency_code = ' || p_ae_line_rec.currency_code);
       arp_standard.debug('Dump_Line_Amts: ' || 'currency_conversion_rate = ' || p_ae_line_rec.currency_conversion_rate);
       arp_standard.debug('Dump_Line_Amts: ' || 'currency_conversion_type = ' || p_ae_line_rec.currency_conversion_type);
       arp_standard.debug('Dump_Line_Amts: ' || 'currency_conversion_date = ' || p_ae_line_rec.currency_conversion_date);
       arp_standard.debug('Dump_Line_Amts: ' || 'third_party_id           = ' || p_ae_line_rec.third_party_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'third_party_sub_id       = ' || p_ae_line_rec.third_party_sub_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'tax_group_code_id        = ' || p_ae_line_rec.tax_group_code_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'tax_code_id              = ' || p_ae_line_rec.tax_code_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'location_segment_id      = ' || p_ae_line_rec.location_segment_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'taxable_entered_dr       = ' || p_ae_line_rec.taxable_entered_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'taxable_entered_cr       = ' || p_ae_line_rec.taxable_entered_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'taxable_accounted_dr     = ' || p_ae_line_rec.taxable_accounted_dr);
       arp_standard.debug('Dump_Line_Amts: ' || 'taxable_accounted_cr     = ' || p_ae_line_rec.taxable_accounted_cr);
       arp_standard.debug('Dump_Line_Amts: ' || 'applied_from_doc_table   = ' || p_ae_line_rec.applied_from_doc_table);
       arp_standard.debug('Dump_Line_Amts: ' || 'applied_from_doc_id      = ' || p_ae_line_rec.applied_from_doc_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'applied_to_doc_table     = ' || p_ae_line_rec.applied_to_doc_table);
       arp_standard.debug('Dump_Line_Amts: ' || 'applied_to_doc_id        = ' || p_ae_line_rec.applied_to_doc_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'tax_link_id              = ' || p_ae_line_rec.tax_link_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'reversed_source_id       = ' || p_ae_line_rec.reversed_source_id);
       arp_standard.debug('Dump_Line_Amts: ' || 'summarize_flag           = ' || p_ae_line_rec.summarize_flag);
      arp_standard.debug('ARP_RECONCILE.Dump_Line_Amts()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Dump_Line_Amts');
     END IF;
     RAISE;

END Dump_Line_Amts;

/*========================================================================
 | PRIVATE PROCEDURE Process_Recon
 |
 | DESCRIPTION
 |      Actually reconciles each assignment of a Bill. Reconciliation is done
 |      only if the Bill is closed and all chained Bills are also closed.
 |      If an assignment is a Bill then this function is called recursively
 |      to go to the child bill and start processing with the same condition
 |      checks as was done for the parent bill.
 |
 | PARAMETERS
 |      p_mode                   IN     Document or Accounting Event mode
 |      p_ae_doc_rec             IN     Document Record
 |      p_ae_event_rec           IN     Event Record
 |      p_ae_sys_rec             IN     System parameter details
 |      p_cust_inv_rec           IN     Contains currency, exchange rate, site
 |                                      details for the bill
 |      p_br_cust_trx_line_id    IN     Bills Receivable assignment line id
 |      p_customer_trx_id        IN     Transaction Id
 |      p_simul_app              IN     Indicates that for a Bill shadow
 |                                      adjustment
 |                                      or assignment simulate a payment event
 |      p_pay_ctr                IN     Application for assignment table counter
 |      p_pay_tbl                IN     Application details for assignment table
 |      p_g_ae_ctr               IN OUT NOCOPY Global accounting entry table counter
 |      p_g_ae_line_tbl          IN OUT NOCOPY Global accounting entry lines table
 |                                      containing accounting due to previous
 |                                      activity on Bills
 |                                      Transaction, or Bills (assignment)
 *=======================================================================*/
PROCEDURE Process_Recon(
                    p_mode                   IN             VARCHAR2                           ,
                    p_ae_doc_rec             IN             ae_doc_rec_type                    ,
                    p_ae_event_rec           IN             ae_event_rec_type                  ,
                    p_ae_sys_rec             IN             ae_sys_rec_type                    ,
                    p_cust_inv_rec           IN             ra_customer_trx%ROWTYPE            ,
                    p_br_cust_trx_line_id    IN             NUMBER                             ,
                    p_customer_trx_id        IN             NUMBER                             ,
                    p_simul_app              IN             VARCHAR2                           ,
                    p_calling_point          IN             VARCHAR2                           ,
                    p_pay_ctr                IN             BINARY_INTEGER                     ,
                    p_pay_tbl                IN             g_pay_tbl_type                     ,
                    p_g_ae_ctr               IN  OUT NOCOPY        BINARY_INTEGER                     ,
                    p_g_ae_line_tbl          IN  OUT NOCOPY ae_line_tbl_type                    ) IS

/*========================================================================+
 | Gets the initial deferred tax accounting for regular transactions      |
 +------------------------------------------------------------------------*/

CURSOR get_init_def_tax_acct IS
SELECT  ctl.location_segment_id                  location_segment_id ,
        decode(ctl.autotax,
               'N','',
               decode(ctl.location_segment_id,
                      '', decode(ctl.vat_tax_id,
                                 '','',
                                 ctl1.vat_tax_id, '',
                                 ctl1.vat_tax_id),
                      ''))                       tax_group_code_id,
        ctl.vat_tax_id                           tax_code_id,
        gld.code_combination_id                  account,
        sum(nvl(gld.amount,0))                   amount,
        sum(nvl(gld.acctd_amount,0))             acctd_amount,
        max(nvl(ctl.taxable_amount,0))           taxable_amount,
        max(decode(gld.account_class,
                   'TAX',
                    arpcurr.functional_amount(
                            nvl(ctl.taxable_amount,0),
                            p_ae_sys_rec.base_currency   ,
                                   p_cust_inv_rec.exchange_rate  ,
                                    p_ae_sys_rec.base_precision  ,
                                    p_ae_sys_rec.base_min_acc_unit),
                   '')) taxable_acctd_amount
       FROM ra_customer_trx           ct ,
            ra_cust_trx_line_gl_dist  gld,
            ra_customer_trx_lines     ctl,
            ra_customer_trx_lines     ctl1
       where ct.customer_trx_id       = p_customer_trx_id
       and   p_calling_point         IN ('TRAN', 'BLTR')
       and   ct.customer_trx_id       = gld.customer_trx_id
       and   gld.customer_trx_id      = ctl.customer_trx_id
       and   gld.customer_trx_line_id = ctl.customer_trx_line_id
       and   gld.account_class        = 'TAX'
       and   gld.collected_tax_ccid IS NOT NULL --deferred tax lines only
       and   gld.account_set_flag     = 'N'
       and   ctl.link_to_cust_trx_line_id = ctl1.customer_trx_line_id --outer join not required here
       and   not exists (select 'x'
                         from ra_customer_trx_lines ctl2
                         where ctl2.customer_trx_id = p_customer_trx_id
                         and   p_calling_point         IN ('TRAN', 'BLTR')
                         and   ctl2.autorule_complete_flag = 'N')
       group by ctl.customer_trx_line_id                        ,
                ctl.location_segment_id                         ,
               decode(ctl.autotax,'N','',
                  decode(ctl.location_segment_id,
                      '', decode(ctl.vat_tax_id,
                                 '','',
                                 ctl1.vat_tax_id, '',
                                 ctl1.vat_tax_id),
                      '')),
                ctl.vat_tax_id                                  ,
                gld.code_combination_id
       order by 1,2,3;

/*-------------------------------------------------------------------------+
 | Gets the accounting for applications on transactions from the accounting|
 | table for reconciliation purposes.                                      |
 +-------------------------------------------------------------------------*/

CURSOR get_def_tax_acct IS --get accounting for applications on transactions
   select ard.location_segment_id      location_segment_id    ,
          ard.tax_group_code_id        tax_group_code_id      ,
          ard.tax_code_id              tax_code_id            ,
          ard.code_combination_id      account                ,
          sum(nvl(ard.amount_dr,0) * -1 +
              nvl(ard.amount_cr,0))    amount                 ,
          sum(nvl(ard.acctd_amount_dr,0) * -1 +
              nvl(ard.acctd_amount_cr,0))  acctd_amount           ,
          sum(nvl(ard.taxable_entered_dr,0) * -1 +
              nvl(ard.taxable_entered_cr,0))    taxable_amount         ,
          sum(nvl(ard.taxable_accounted_dr,0) * -1 +
              nvl(ard.taxable_accounted_cr,0)) taxable_acctd_amount
   from  ar_distributions           ard,
         ar_receivable_applications app
   where p_ae_sys_rec.sob_type = 'P'
   and   app.applied_customer_trx_id = p_customer_trx_id
   and   p_calling_point  IN ('TRAN', 'BLTR')
   and   app.status = 'APP'
   and   nvl(app.confirmed_flag, 'Y') = 'Y'
   and   ard.source_id = app.receivable_application_id
   and   ard.source_table = 'RA'
   and   ard.source_type = 'DEFERRED_TAX'
   and   decode(ard.source_type_secondary,
                'RECONCILE', ard.source_id_secondary,
                p_customer_trx_id)  = p_customer_trx_id
   group by ard.location_segment_id  ,
            ard.tax_group_code_id    ,
            ard.tax_code_id          ,
            ard.code_combination_id
/*-------------------------------------------------------------------------+
 | Gets the accounting for adjustments on transactions from the accounting |
 | table for reconciliation purposes.                                      |
 +-------------------------------------------------------------------------*/
   UNION ALL--get accounting for adjustments on transaction
   select ard.location_segment_id      location_segment_id    ,
          ard.tax_group_code_id        tax_group_code_id      ,
          ard.tax_code_id              tax_code_id            ,
          ard.code_combination_id      account                ,
          sum(nvl(ard.amount_dr,0) * -1 +
              nvl(ard.amount_cr,0))    amount                 ,
          sum(nvl(ard.acctd_amount_dr,0) * -1 +
              nvl(ard.acctd_amount_cr,0)) acctd_amount           ,
          sum(nvl(ard.taxable_entered_dr,0) * -1 +
              nvl(ard.taxable_entered_cr,0))    taxable_amount         ,
          sum(nvl(ard.taxable_accounted_dr,0) * -1 +
              nvl(ard.taxable_accounted_cr,0)) taxable_acctd_amount
   from  ar_distributions           ard,
         ar_adjustments             adj
   where p_ae_sys_rec.sob_type = 'P'
   and   adj.customer_trx_id = p_customer_trx_id
   and   p_calling_point  IN ('TRAN', 'BLTR')
   and   adj.status = 'A'
   and   ard.source_id = adj.adjustment_id
   and   ard.source_table = 'ADJ'
   and   ard.source_type = 'DEFERRED_TAX'
   and   decode(ard.source_type_secondary,
                'RECONCILE', ard.source_id_secondary,
                p_customer_trx_id)  = p_customer_trx_id
   group by ard.location_segment_id  ,
            ard.tax_group_code_id    ,
            ard.tax_code_id          ,
            ard.code_combination_id
/*--------------------------------------------------------------------------+
 | Gets the accounting for activity on a Bill to which the transactions has |
 | been assigned. i.e. deferred tax accounting for transaction assignments  |
 | to the Bill. This is used to reconcile the transaction. p_customer_trx_id|
 | is null when processing assignments on a Bill. So the statement below is |
 | used for transactions only.                                              |
 +--------------------------------------------------------------------------*/
   UNION ALL--get accounting on Bills for Transactions
   select ard.location_segment_id               location_segment_id    ,
          ard.tax_group_code_id                 tax_group_code_id      ,
          ard.tax_code_id                       tax_code_id            ,
          ard.code_combination_id               account                ,
          sum(nvl(ard.amount_dr,0) * -1 +
              nvl(ard.amount_cr,0))             amount                 ,
          sum(nvl(ard.acctd_amount_dr,0) * -1 +
              nvl(ard.acctd_amount_cr,0))       acctd_amount           ,
          sum(nvl(ard.taxable_entered_dr,0) * -1 +
              nvl(ard.taxable_entered_cr,0))    taxable_amount         ,
          sum(nvl(ard.taxable_accounted_dr,0) * -1 +
              nvl(ard.taxable_accounted_cr,0)) taxable_acctd_amount
   from ra_customer_trx_lines ctl,
        ar_distributions      ard
   where p_ae_sys_rec.sob_type = 'P'
   and   ctl.br_ref_customer_trx_id = p_customer_trx_id
   and   p_calling_point  IN ('TRAN', 'BLTR')
   and ard.source_id_secondary = ctl.customer_trx_line_id
   and ard.source_table_secondary = 'CTL'
   and ard.source_type_secondary IN ('ASSIGNMENT', 'ASSIGNMENT_RECONCILE',
                                     'RECONCILE')
   and ard.source_type = 'DEFERRED_TAX'
   group by ard.location_segment_id  ,
            ard.tax_group_code_id    ,
            ard.tax_code_id          ,
            ard.code_combination_id
/*--------------------------------------------------------------------------+
 | Get the deferred tax accounting moved for the assignment on the Bill due |
 | to activity on the Bill from the accounting table. The assignment line id|
 | is used by the statement below.                                          |
 +--------------------------------------------------------------------------*/
   UNION ALL--reconcile bill only
   select ard.location_segment_id                  location_segment_id    ,
          ard.tax_group_code_id                    tax_group_code_id      ,
          ard.tax_code_id                          tax_code_id            ,
          ard.code_combination_id                  account                ,
          sum(nvl(ard.amount_dr,0) * -1 +
              nvl(ard.amount_cr,0))                amount                 ,
          sum(nvl(ard.acctd_amount_dr,0) * -1 +
              nvl(ard.acctd_amount_cr,0))          acctd_amount           ,
          sum(nvl(ard.taxable_entered_dr,0) * -1 +
              nvl(ard.taxable_entered_cr,0))    taxable_amount         ,
          sum(nvl(ard.taxable_accounted_dr,0) * -1 +
              nvl(ard.taxable_accounted_cr,0)) taxable_acctd_amount
   from  ar_distributions           ard
   where p_ae_sys_rec.sob_type = 'P'
   and   ard.source_id_secondary = p_br_cust_trx_line_id
   and p_calling_point = 'BILL'
   and ard.source_table_secondary = 'CTL'
   and ard.source_type_secondary IN ('ASSIGNMENT', 'ASSIGNMENT_RECONCILE')
   and ard.source_type = 'DEFERRED_TAX'
   group by ard.location_segment_id  ,
            ard.tax_group_code_id    ,
            ard.tax_code_id          ,
            ard.code_combination_id
   order by 1,2,3;


ae_tax_tbl            g_tax_tbl_type;
ae_tax_activity_tbl   g_tax_tbl_type;

l_ae_line_tbl         ae_line_tbl_type;
l_ae_line_rec         ae_line_rec_type;
l_ae_empty_line_rec   ae_line_rec_type;

l_ae_rule_rec         ae_rule_rec_type;

l_app_rec        ar_receivable_applications%ROWTYPE;
l_adj_rec        ar_adjustments%ROWTYPE;

l_tax_ctr        NUMBER := 0;
l_tax_ctr1       NUMBER := 0;
l_ctr            NUMBER;
l_ctr1           NUMBER;
l_ctr2           NUMBER;
l_ae_ctr         NUMBER;
l_cached         BOOLEAN;
l_cre_rec        BOOLEAN;
l_match_cond     BOOLEAN;
l_ae_doc_rec     ae_doc_rec_type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('ARP_RECONCILE.Process_Recon()+');
      arp_standard.debug('Process_Recon: ' || 'list Input of parameters ');
      arp_standard.debug('Process_Recon: ' || 'p_br_cust_trx_line_id ' || p_br_cust_trx_line_id);
      arp_standard.debug('Process_Recon: ' || 'p_customer_trx_id     ' || p_customer_trx_id);
      arp_standard.debug('Process_Recon: ' || 'p_simul_app           ' || p_simul_app);
      arp_standard.debug('Process_Recon: ' || 'p_calling_point       ' || p_calling_point);
      arp_standard.debug('Process_Recon: ' || 'p_pay_ctr             ' || p_pay_ctr);
   END IF;

/*-------------------------------------------------------------------------------+
 | For an assignment on a Bill simulate an activity such as an application which |
 | results in closing the amount assigned to the Bill due to the line assignment.|
 +-------------------------------------------------------------------------------*/
   IF (p_simul_app = 'Y') THEN

       l_ae_line_tbl := g_ae_empty_line_tbl;
       l_ae_ctr      := 0;

       l_ae_doc_rec := p_ae_doc_rec;
       l_ae_doc_rec.source_table := 'RA';

       IF p_pay_tbl.EXISTS(p_pay_ctr) THEN --atleast one activity exists

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Process_Recon: ' || 'p_pay_tbl simulate application ');
          END IF;

          FOR l_ctr3 IN p_pay_tbl.FIRST .. p_pay_tbl.LAST LOOP

              l_app_rec.applied_customer_trx_id     := p_pay_tbl(l_ctr3).applied_customer_trx_id      ;
              l_app_rec.applied_payment_schedule_id := p_pay_tbl(l_ctr3).applied_payment_schedule_id  ;
              l_app_rec.amount_applied              := p_pay_tbl(l_ctr3).amount_applied               ;
              l_app_rec.acctd_amount_applied_to     := p_pay_tbl(l_ctr3).acctd_amount_applied_to      ;
              l_app_rec.line_applied                := p_pay_tbl(l_ctr3).line_applied                 ;
              l_app_rec.tax_applied                 := p_pay_tbl(l_ctr3).tax_applied                  ;
              l_app_rec.freight_applied             := p_pay_tbl(l_ctr3).freight_applied              ;
              l_app_rec.receivables_charges_applied := p_pay_tbl(l_ctr3).receivables_charges_applied  ;

           /*-----------------------------------------------------------------------------+
            | Call Tax accounting engine to allocate deferred tax for the simulated single|
            | activity on the assignment.                                                 |
            +-----------------------------------------------------------------------------*/
              ARP_ALLOCATION_PKG.Allocate_Tax(
                    p_ae_doc_rec           => l_ae_doc_rec   ,     --Document detail
                    p_ae_event_rec         => p_ae_event_rec ,     --Event record
                    p_ae_rule_rec          => l_ae_rule_rec  ,     --Rule info for payment method
                    p_app_rec              => l_app_rec      ,     --Application details
                    p_cust_inv_rec         => p_cust_inv_rec ,     --Invoice details
                    p_adj_rec              => l_adj_rec      ,     --dummy adjustment record
                    p_ae_ctr               => l_ae_ctr       ,     --counter
                    p_ae_line_tbl          => l_ae_line_tbl  ,     --final tax accounting table
                    p_br_cust_trx_line_id  => ''             ,
                    p_simul_app            => p_simul_app   );

              IF l_ae_line_tbl.EXISTS(l_ae_ctr) THEN --Atleast one Tax line exists

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug('Process_Recon: ' || 'Caching Tax for simulated application ');
               END IF;

               FOR l_ctr1 IN l_ae_line_tbl.FIRST .. l_ae_line_tbl.LAST LOOP

             /*--------------------------------------------------------------------------------+
              |Cache the deferred tax accounting into the tax table.This is the deferred tax   |
              |created as though the amount on the shadow assignment of the transaction on     |
              |the bill were paid off through a single activity. Note in this case we          |
              |multiply the credits by -1 because we want to use the net amount by location    |
              |or tax code for the simulated application accounting, and add it to the actual  |
              |accounting for the Bills assignment. This will result in creating the offsetting|
              |reconciliation entries.                                                         |
              +--------------------------------------------------------------------------------*/
                  l_cached := FALSE;

                  IF ae_tax_tbl.EXISTS(l_tax_ctr) THEN

                     FOR l_ctr IN ae_tax_tbl.FIRST .. ae_tax_tbl.LAST LOOP

                         IF ((((l_ae_line_tbl(l_ctr1).location_segment_id IS NOT NULL)
                                AND (nvl(ae_tax_tbl(l_ctr).ae_location_segment_id,-999) = nvl(l_ae_line_tbl(l_ctr1).location_segment_id,-999)))
                             OR ((nvl(l_ae_line_tbl(l_ctr1).tax_group_code_id,-999) = nvl(ae_tax_tbl(l_ctr).ae_tax_group_code_id,-999))
                                  AND (l_ae_line_tbl(l_ctr1).tax_code_id IS NOT NULL)
                                  AND (nvl(ae_tax_tbl(l_ctr).ae_tax_code_id,-999) = nvl(l_ae_line_tbl(l_ctr1).tax_code_id,-999))))
                             AND (ae_tax_tbl(l_ctr).ae_code_combination_id = l_ae_line_tbl(l_ctr1).account)
                             AND (l_ae_line_tbl(l_ctr1).ae_line_type = 'DEFERRED_TAX'))
                         THEN

                            IF PG_DEBUG in ('Y', 'C') THEN
                               arp_standard.debug('Process_Recon: ' || '1) Hit found in cache ae_tax_tbl');
                            END IF;

                            ae_tax_tbl(l_ctr).ae_amount := ae_tax_tbl(l_ctr).ae_amount
                                            + nvl(l_ae_line_tbl(l_ctr1).entered_dr,0)
                                                + nvl(l_ae_line_tbl(l_ctr1).entered_cr,0) * -1;

                            ae_tax_tbl(l_ctr).ae_acctd_amount := ae_tax_tbl(l_ctr).ae_acctd_amount
                                            + nvl(l_ae_line_tbl(l_ctr1).accounted_dr,0)
                                                + nvl(l_ae_line_tbl(l_ctr1).accounted_cr,0) * -1; --bug6146807

                            ae_tax_tbl(l_ctr).ae_taxable_amount := ae_tax_tbl(l_ctr).ae_taxable_amount
                                            + nvl(l_ae_line_tbl(l_ctr1).taxable_entered_dr,0)
                                                + nvl(l_ae_line_tbl(l_ctr1).taxable_entered_cr,0) * -1;

                            ae_tax_tbl(l_ctr).ae_taxable_acctd_amount := ae_tax_tbl(l_ctr).ae_taxable_acctd_amount
                                            + nvl(l_ae_line_tbl(l_ctr1).taxable_accounted_dr,0)
                                                + nvl(l_ae_line_tbl(l_ctr1).taxable_accounted_cr,0) * -1;

                            l_cached := TRUE;

                         END IF; --grouping rule satisfied

                     END LOOP; --ae_tax_tbl to verify whether tax record is cached

                  END IF; --ae_tax_tbl exists

                /*-----------------------------------------------------------------------------+
                 |Cache the deferred tax accounting entry into the table if not already cached |
                 +-----------------------------------------------------------------------------*/
                  IF (NOT l_cached) AND (l_ae_line_tbl(l_ctr1).ae_line_type = 'DEFERRED_TAX')
                  THEN
                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_standard.debug('Process_Recon: ' || '1) Now caching in cache ae_tax_tbl');
                     END IF;

                     l_tax_ctr := l_tax_ctr + 1;

                     ae_tax_tbl(l_tax_ctr).ae_location_segment_id := l_ae_line_tbl(l_ctr1).location_segment_id;

                     ae_tax_tbl(l_tax_ctr).ae_tax_group_code_id := l_ae_line_tbl(l_ctr1).tax_group_code_id;

                     ae_tax_tbl(l_tax_ctr).ae_tax_code_id := l_ae_line_tbl(l_ctr1).tax_code_id;

                     ae_tax_tbl(l_tax_ctr).ae_code_combination_id  := l_ae_line_tbl(l_ctr1).account;

                     ae_tax_tbl(l_tax_ctr).ae_amount :=
                         nvl(l_ae_line_tbl(l_ctr1).entered_dr,0)
                                + nvl(l_ae_line_tbl(l_ctr1).entered_cr,0) * -1;

                     ae_tax_tbl(l_tax_ctr).ae_acctd_amount :=
                         nvl(l_ae_line_tbl(l_ctr1).accounted_dr,0)
                                + nvl(l_ae_line_tbl(l_ctr1).accounted_cr,0) * -1;

                     ae_tax_tbl(l_tax_ctr).ae_taxable_amount :=
                         nvl(l_ae_line_tbl(l_ctr1).taxable_entered_dr,0)
                                + nvl(l_ae_line_tbl(l_ctr1).taxable_entered_cr,0) * -1;

                     ae_tax_tbl(l_tax_ctr).ae_taxable_acctd_amount :=
                          nvl(l_ae_line_tbl(l_ctr1).taxable_accounted_dr,0)
                                + nvl(l_ae_line_tbl(l_ctr1).taxable_accounted_cr,0) * -1;

                     l_cached := TRUE;

                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_standard.debug('Process_Recon: ' || ' ');
                        arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_location_segment_id = ' || ae_tax_tbl(l_tax_ctr).ae_location_segment_id);
                        arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_tax_group_code_id = ' || ae_tax_tbl(l_tax_ctr).ae_tax_group_code_id);
                        arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_tax_code_id = ' || ae_tax_tbl(l_tax_ctr).ae_tax_code_id);
                        arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_code_combination_id = ' || ae_tax_tbl(l_tax_ctr).ae_code_combination_id);
                        arp_standard.debug('Process_Recon: ' || ' ');
                     END IF;

                  END IF; --not cached

             END LOOP; -- lines table

           END IF; --atleast one tax line exists

         END LOOP; --process the payment table for all simulated applications

      END IF; --payment table exists

   ELSE
  /*---------------------------------------------------------------------------------+
   |Cache the deferred tax from the original transaction accounting table for use in |
   |the reconciliation process                                                       |
   +---------------------------------------------------------------------------------*/
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Process_Recon: ' || 'Caching deferred tax from Original Transaction accounting ');
      END IF;

      FOR l_init_def_tax IN get_init_def_tax_acct LOOP

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Process_Recon: ' || 'Processing Original Transaction accounting ');
          END IF;

          l_cached := FALSE;

          IF ae_tax_tbl.EXISTS(l_tax_ctr) THEN --Atleast one cached deferred Tax line exists

            FOR l_ctr IN ae_tax_tbl.FIRST .. ae_tax_tbl.LAST LOOP

                IF ((((l_init_def_tax.location_segment_id IS NOT NULL)
                   AND (nvl(ae_tax_tbl(l_ctr).ae_location_segment_id,-999) = nvl(l_init_def_tax.location_segment_id,-999)))
                  OR ((l_init_def_tax.tax_code_id IS NOT NULL)
                      AND (nvl(ae_tax_tbl(l_ctr).ae_tax_code_id,-999) = nvl(l_init_def_tax.tax_code_id,-999))
                      AND (nvl(ae_tax_tbl(l_ctr).ae_tax_group_code_id,-999) = nvl(l_init_def_tax.tax_group_code_id,-999))))
                   AND (ae_tax_tbl(l_ctr).ae_code_combination_id = l_init_def_tax.account))
                THEN

                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_standard.debug('Process_Recon: ' || '2) Hit found in cache ae_tax_tbl');
                     END IF;

                     ae_tax_tbl(l_ctr).ae_amount := ae_tax_tbl(l_ctr).ae_amount
                                     + l_init_def_tax.amount;

                     ae_tax_tbl(l_ctr).ae_acctd_amount := ae_tax_tbl(l_ctr).ae_acctd_amount
                                     + l_init_def_tax.acctd_amount;

                     ae_tax_tbl(l_ctr).ae_taxable_amount := ae_tax_tbl(l_ctr).ae_taxable_amount
                                     + l_init_def_tax.taxable_amount;

                     ae_tax_tbl(l_ctr).ae_taxable_acctd_amount := ae_tax_tbl(l_ctr).ae_taxable_acctd_amount
                                     + l_init_def_tax.taxable_acctd_amount;

                     l_cached := TRUE;

                END IF; --grouping rule satisfied

            END LOOP; --ae_tax_tbl to verify whether tax record is cached

         END IF; --activity table exists for already cached entries

      /*---------------------------------------------------------------------------------+
       |If an entry is not already cached then cache the Original accounting             |
       +---------------------------------------------------------------------------------*/
         IF (NOT l_cached) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Process_Recon: ' || '2) Now caching in cache ae_tax_tbl');
            END IF;

            l_tax_ctr := l_tax_ctr + 1;

            ae_tax_tbl(l_tax_ctr).ae_location_segment_id    := l_init_def_tax.location_segment_id;

            ae_tax_tbl(l_tax_ctr).ae_tax_group_code_id      := l_init_def_tax.tax_group_code_id;

            ae_tax_tbl(l_tax_ctr).ae_tax_code_id            := l_init_def_tax.tax_code_id;

            ae_tax_tbl(l_tax_ctr).ae_code_combination_id    := l_init_def_tax.account;

            ae_tax_tbl(l_tax_ctr).ae_amount                 := l_init_def_tax.amount;

            ae_tax_tbl(l_tax_ctr).ae_acctd_amount           := l_init_def_tax.acctd_amount;

            ae_tax_tbl(l_tax_ctr).ae_taxable_amount         := l_init_def_tax.taxable_amount;

            ae_tax_tbl(l_tax_ctr).ae_taxable_acctd_amount   := l_init_def_tax.taxable_acctd_amount;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Process_Recon: ' || ' ');
               arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_location_segment_id = ' || ae_tax_tbl(l_tax_ctr).ae_location_segment_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_tax_group_code_id = ' || ae_tax_tbl(l_tax_ctr).ae_tax_group_code_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_tax_code_id = ' || ae_tax_tbl(l_tax_ctr).ae_tax_code_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_tax_ctr||').ae_code_combination_id = ' || ae_tax_tbl(l_tax_ctr).ae_code_combination_id);
               arp_standard.debug('Process_Recon: ' || ' ');
            END IF;

            l_cached := TRUE;

         END IF; --not cached then cache

      END LOOP; --process original tax on Invoice and cache

   END IF; --Simulating an application to reconcile against single activity

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Process_Recon: ' || 'Start caching physically created tax accounting entries due to past activity');
   END IF;

  /*---------------------------------------------------------------------------------+
   |Cache the deferred tax accounting entries physically created in ar_distributions |
   |due to activity on the bill.                                                     |
   +---------------------------------------------------------------------------------*/
    FOR l_inv_nr IN get_def_tax_acct LOOP

         l_cached := FALSE;

         IF ae_tax_activity_tbl.EXISTS(l_tax_ctr1) THEN

            FOR l_ctr IN ae_tax_activity_tbl.FIRST .. ae_tax_activity_tbl.LAST LOOP

             /*--------------------------------------------------------------------+
              |Add to accounting entry in cache if matching conditions             |
              +--------------------------------------------------------------------*/
                IF ((((l_inv_nr.location_segment_id IS NOT NULL)
                     AND (nvl(ae_tax_activity_tbl(l_ctr).ae_location_segment_id,-999) = nvl(l_inv_nr.location_segment_id,-999)))
                   OR ((nvl(ae_tax_activity_tbl(l_ctr).ae_tax_group_code_id,-999) = nvl(l_inv_nr.tax_group_code_id,-999))
                        AND (l_inv_nr.tax_code_id IS NOT NULL)
                        AND (nvl(ae_tax_activity_tbl(l_ctr).ae_tax_code_id,-999) = nvl(l_inv_nr.tax_code_id,-999))))
                   AND (ae_tax_activity_tbl(l_ctr).ae_code_combination_id = l_inv_nr.account))
                THEN

                   IF PG_DEBUG in ('Y', 'C') THEN
                      arp_standard.debug('Process_Recon: ' || '3) Hit found in cache ae_tax_activity_tbl');
                   END IF;

                   ae_tax_activity_tbl(l_ctr).ae_amount :=
                      ae_tax_activity_tbl(l_ctr).ae_amount + l_inv_nr.amount;

                   ae_tax_activity_tbl(l_ctr).ae_acctd_amount :=
                      ae_tax_activity_tbl(l_ctr).ae_acctd_amount + l_inv_nr.acctd_amount;

                   ae_tax_activity_tbl(l_ctr).ae_taxable_amount :=
                      ae_tax_activity_tbl(l_ctr).ae_taxable_amount + l_inv_nr.taxable_amount;

                   ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount :=
                      ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount +l_inv_nr.taxable_acctd_amount;

                   l_cached := TRUE;

                END IF;

            END LOOP; --for activity table from ar_distributions

         END IF; --activity table exists for already cached entries

        /*---------------------------------------------------------------------------------+
         |If an entry is not already cached when retrieved from ar_distributions then cache|
         +---------------------------------------------------------------------------------*/
         IF (NOT l_cached) THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Process_Recon: ' || '3) Now caching in cache ae_tax_activity_tbl');
            END IF;

            l_tax_ctr1 := l_tax_ctr1 + 1;
            ae_tax_activity_tbl(l_tax_ctr1).ae_location_segment_id  := l_inv_nr.location_segment_id;

            ae_tax_activity_tbl(l_tax_ctr1).ae_tax_group_code_id    := l_inv_nr.tax_group_code_id;

            ae_tax_activity_tbl(l_tax_ctr1).ae_tax_code_id          := l_inv_nr.tax_code_id;

            ae_tax_activity_tbl(l_tax_ctr1).ae_code_combination_id  := l_inv_nr.account;

            ae_tax_activity_tbl(l_tax_ctr1).ae_amount               := l_inv_nr.amount;

            ae_tax_activity_tbl(l_tax_ctr1).ae_acctd_amount         := l_inv_nr.acctd_amount;

            ae_tax_activity_tbl(l_tax_ctr1).ae_taxable_amount       := l_inv_nr.taxable_amount;

            ae_tax_activity_tbl(l_tax_ctr1).ae_taxable_acctd_amount := l_inv_nr.taxable_acctd_amount;

            l_cached := TRUE;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Process_Recon: ' || ' ');
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_location_segment_id = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_location_segment_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_tax_group_code_id = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_tax_group_code_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_tax_code_id = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_tax_code_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_amount      = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_amount);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_acctd_amount      = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_acctd_amount);
               arp_standard.debug('Process_Recon: ' || ' ');
            END IF;

         END IF; --not cached then cache

    END LOOP; --all activity

 /*---------------------------------------------------------------------------------+
  |Now cache the accounting entries from the global accounting table due to previous|
  |activity on the Transaction or Bill. These accounting entries are stored in a    |
  |PLSQL table by the parent routine which calls the reconciliation routine. This   |
  |table may also contain reconciliation entries for assignments on Bill when a     |
  |Transaction is being Reconciled.                                                 |
  +---------------------------------------------------------------------------------*/
    IF p_g_ae_line_tbl.EXISTS(p_g_ae_ctr) AND (g_call_num = 1) THEN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Process_Recon: ' || '4) Cache table p_g_ae_line_tbl Exists');
       END IF;

       FOR l_ctr1 IN p_g_ae_line_tbl.FIRST .. p_g_ae_line_tbl.LAST LOOP

            l_cached := FALSE;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Process_Recon: ' || '  ');
               arp_standard.debug('Process_Recon: ' || 'Checking whether global table accounting matches tax activity table');
               arp_standard.debug('Process_Recon: ' || 'p_br_cust_trx_line_id ' || p_br_cust_trx_line_id);
               arp_standard.debug('Process_Recon: ' || 'p_g_ae_line_tbl('|| l_ctr1 || ').source_id_secondary ' ||  p_g_ae_line_tbl(l_ctr1).source_id_secondary);
               arp_standard.debug('Process_Recon: ' || 'p_g_ae_line_tbl('|| l_ctr1 || ').source_table_secondary ' ||  p_g_ae_line_tbl(l_ctr1).source_table_secondary);
               arp_standard.debug('Process_Recon: ' || 'p_g_ae_line_tbl('|| l_ctr1 || ').ae_line_type ' ||  p_g_ae_line_tbl(l_ctr1).ae_line_type);
               arp_standard.debug('Process_Recon: ' || 'p_g_ae_line_tbl('|| l_ctr1 || ').location_segment_id ' ||  p_g_ae_line_tbl(l_ctr1).location_segment_id);
               arp_standard.debug('Process_Recon: ' || 'p_g_ae_line_tbl('|| l_ctr1 || ').tax_group_code_id ' ||  p_g_ae_line_tbl(l_ctr1).tax_group_code_id);
               arp_standard.debug('Process_Recon: ' || 'p_g_ae_line_tbl('|| l_ctr1 || ').tax_code_id ' ||  p_g_ae_line_tbl(l_ctr1).tax_code_id);
               arp_standard.debug('Process_Recon: ' || '  ');
            END IF;

            IF ae_tax_activity_tbl.EXISTS(l_tax_ctr1) THEN

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug('Process_Recon: ' || '4) Cache table ae_tax_activity_tbl Exists');
               END IF;

               FOR l_ctr IN ae_tax_activity_tbl.FIRST .. ae_tax_activity_tbl.LAST LOOP

                /*--------------------------------------------------------------------+
                 |Add to accounting entry in cache if matching conditions             |
                 +--------------------------------------------------------------------*/
                   IF ((((p_g_ae_line_tbl(l_ctr1).location_segment_id IS NOT NULL)
                         AND (nvl(ae_tax_activity_tbl(l_ctr).ae_location_segment_id,-999)
                                                   = nvl(p_g_ae_line_tbl(l_ctr1).location_segment_id,-999)))
                       OR ((nvl(ae_tax_activity_tbl(l_ctr).ae_tax_group_code_id,-999)
                                                   = nvl(p_g_ae_line_tbl(l_ctr1).tax_group_code_id,-999))
                            AND (p_g_ae_line_tbl(l_ctr1).tax_code_id IS NOT NULL)
                            AND (nvl(ae_tax_activity_tbl(l_ctr).ae_tax_code_id,-999)
                                                   = nvl(p_g_ae_line_tbl(l_ctr1).tax_code_id,-999))))

                  --condition beow is required because the Bills global accounting cache may have accounting
                  --entries for more than one assignment on the Bill, when br cust trx line id is populated
                  --it implies that the source_table_secondary is CTL in p_g_ae_line_tbl because this is the
                  --cache for the Bills accounting
                    AND ((p_calling_point  = 'TRAN')
                         OR ((p_calling_point IN ('BILL', 'BLTR')
                          AND (nvl(p_br_cust_trx_line_id,-999) = nvl(p_g_ae_line_tbl(l_ctr1).source_id_secondary,-999)))))
                    AND (ae_tax_activity_tbl(l_ctr).ae_code_combination_id = p_g_ae_line_tbl(l_ctr1).account)
                     AND (p_g_ae_line_tbl(l_ctr1).ae_line_type = 'DEFERRED_TAX'))
                   THEN

                     IF PG_DEBUG in ('Y', 'C') THEN
                        arp_standard.debug('Process_Recon: ' || '4) Hit found in cache ae_tax_activity_tbl');
                     END IF;

                     ae_tax_activity_tbl(l_ctr).ae_amount :=
                        ae_tax_activity_tbl(l_ctr).ae_amount + nvl(p_g_ae_line_tbl(l_ctr1).entered_dr,0) * -1
                           + nvl(p_g_ae_line_tbl(l_ctr1).entered_cr,0);

                     ae_tax_activity_tbl(l_ctr).ae_acctd_amount := ae_tax_activity_tbl(l_ctr).ae_acctd_amount
                          + nvl(p_g_ae_line_tbl(l_ctr1).accounted_dr,0) * -1
                             + nvl(p_g_ae_line_tbl(l_ctr1).accounted_cr,0) ;

                     ae_tax_activity_tbl(l_ctr).ae_taxable_amount := ae_tax_activity_tbl(l_ctr).ae_taxable_amount
                          + nvl(p_g_ae_line_tbl(l_ctr1).taxable_entered_dr,0) * -1
                             + nvl(p_g_ae_line_tbl(l_ctr1).taxable_entered_cr,0);

                     ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount := ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount
                          + nvl(p_g_ae_line_tbl(l_ctr1).taxable_accounted_dr,0) * -1
                             + nvl(p_g_ae_line_tbl(l_ctr1).taxable_accounted_cr,0);

                     l_cached := TRUE;

                  END IF;

            END LOOP; --for activity table from ar_distributions

         END IF; --activity table exists for already cached entries

        /*---------------------------------------------------------------------------------+
         |If an entry is not already cached when retrieved from ar_distributions then cache|
         +---------------------------------------------------------------------------------*/
         IF ((NOT l_cached)
            AND ((p_calling_point = 'TRAN')
                 OR ((p_calling_point IN ('BILL', 'BLTR'))
                    AND nvl(p_br_cust_trx_line_id,-999) = nvl(p_g_ae_line_tbl(l_ctr1).source_id_secondary,-999)))
                     AND (p_g_ae_line_tbl(l_ctr1).ae_line_type = 'DEFERRED_TAX'))
         THEN

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Process_Recon: ' || '4) Now caching in cache ae_tax_activity_tbl');
            END IF;

            l_tax_ctr1 := l_tax_ctr1 + 1;

            ae_tax_activity_tbl(l_tax_ctr1).ae_location_segment_id  := p_g_ae_line_tbl(l_ctr1).location_segment_id;

            ae_tax_activity_tbl(l_tax_ctr1).ae_tax_group_code_id    := p_g_ae_line_tbl(l_ctr1).tax_group_code_id;

            ae_tax_activity_tbl(l_tax_ctr1).ae_tax_code_id          := p_g_ae_line_tbl(l_ctr1).tax_code_id;

            ae_tax_activity_tbl(l_tax_ctr1).ae_code_combination_id  := p_g_ae_line_tbl(l_ctr1).account;

            ae_tax_activity_tbl(l_tax_ctr1).ae_amount               :=
                 nvl(p_g_ae_line_tbl(l_ctr1).entered_dr,0) * -1 + nvl(p_g_ae_line_tbl(l_ctr1).entered_cr,0);

            ae_tax_activity_tbl(l_tax_ctr1).ae_acctd_amount         :=
                nvl(p_g_ae_line_tbl(l_ctr1).accounted_dr,0) * -1 +  nvl(p_g_ae_line_tbl(l_ctr1).accounted_cr,0);

            ae_tax_activity_tbl(l_tax_ctr1).ae_taxable_amount       :=
                nvl(p_g_ae_line_tbl(l_ctr1).taxable_entered_dr,0) * -1
                    + nvl(p_g_ae_line_tbl(l_ctr1).taxable_entered_cr,0);

            ae_tax_activity_tbl(l_tax_ctr1).ae_taxable_acctd_amount :=
                nvl(p_g_ae_line_tbl(l_ctr1).taxable_accounted_dr,0) * -1
                    + nvl(p_g_ae_line_tbl(l_ctr1).taxable_accounted_cr,0);

            l_cached := TRUE;

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('Process_Recon: ' || ' ');
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_location_segment_id = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_location_segment_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_tax_group_code_id = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_tax_group_code_id);
               arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_tax_ctr1||').ae_tax_code_id = ' || ae_tax_activity_tbl(l_tax_ctr1).ae_tax_code_id);
               arp_standard.debug('Process_Recon: ' || ' ');
            END IF;

         END IF; --not cached then cache

     END LOOP; --all activity

   END IF; --entries exist in the global accounting table for a activity

  /*------------------------------------------------------------------------------------------+
   |Reconcile the simulated application accounting for deferred tax for the shadow adjustment |
   |accounting with that of the physically stored accounting entries in ar_distributions, due |
   |to activity on the Bill                                                                   |
   +------------------------------------------------------------------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('Process_Recon: ' || 'Reconciling original accounting with the activity accounting ');
    END IF;

    IF ae_tax_tbl.EXISTS(l_tax_ctr) THEN

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl Exists , ae_tax_activity_tbl Exists ');
       END IF;

       FOR l_ctr IN ae_tax_tbl.FIRST .. ae_tax_tbl.LAST LOOP

           IF PG_DEBUG in ('Y', 'C') THEN
              arp_standard.debug('Process_Recon: ' || 'Looping through table ae_tax_tbl to Reconcile l_ctr ' || l_ctr);
              arp_standard.debug('Process_Recon: ' || ' ');
              arp_standard.debug('Process_Recon: ' || '******** ');
              arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_ctr||').ae_location_segment_id = '|| ae_tax_tbl(l_ctr).ae_location_segment_id);
              arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_ctr||').ae_tax_group_code_id = '|| ae_tax_tbl(l_ctr).ae_tax_group_code_id);
              arp_standard.debug('Process_Recon: ' || 'ae_tax_tbl('||l_ctr||').ae_tax_code_id = '|| ae_tax_tbl(l_ctr).ae_tax_code_id);
              arp_standard.debug('Process_Recon: ' || '******** ');
           END IF;

           l_match_cond := FALSE;

           IF ae_tax_activity_tbl.EXISTS(l_tax_ctr1) THEN

             FOR l_ctr1 IN ae_tax_activity_tbl.FIRST .. ae_tax_activity_tbl.LAST LOOP

               IF PG_DEBUG in ('Y', 'C') THEN
                  arp_standard.debug('Process_Recon: ' || 'Looping through table ae_tax_activity_tbl l_ctr1 ' || l_ctr1);
                  arp_standard.debug('Process_Recon: ' || ' ');
                  arp_standard.debug('Process_Recon: ' || '>>>>>>>> COMPARE');
                  arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_ctr1||').ae_location_segment_id = '|| ae_tax_activity_tbl(l_ctr1).ae_location_segment_id);
                  arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_ctr1||').ae_tax_group_code_id = '|| ae_tax_activity_tbl(l_ctr1).ae_tax_group_code_id);
                  arp_standard.debug('Process_Recon: ' || 'ae_tax_activity_tbl('||l_ctr1||').ae_tax_code_id = '|| ae_tax_activity_tbl(l_ctr1).ae_tax_code_id);
                  arp_standard.debug('Process_Recon: ' || 'Amount ' || ae_tax_tbl(l_ctr).ae_amount || ' VS ' || ae_tax_activity_tbl(l_ctr1).ae_amount);
                  arp_standard.debug('Process_Recon: ' || 'Accounted Amount ' || ae_tax_tbl(l_ctr).ae_acctd_amount || ' VS ' || ae_tax_activity_tbl(l_ctr1).ae_acctd_amount);
                  arp_standard.debug('Process_Recon: ' || 'Taxable Amount ' || ae_tax_tbl(l_ctr).ae_taxable_amount || ' VS ' || ae_tax_activity_tbl(l_ctr1).ae_taxable_amount);
                  arp_standard.debug('Process_Recon: ' || 'Taxable Accounted Amount ' || ae_tax_tbl(l_ctr).ae_taxable_acctd_amount || ' VS ' || ae_tax_activity_tbl(l_ctr1).ae_taxable_acctd_amount);
                  arp_standard.debug('Process_Recon: ' || '>>>>>>>> COMPARE');
               END IF;

               IF (((ae_tax_tbl(l_ctr).ae_location_segment_id IS NOT NULL)
                   AND (ae_tax_activity_tbl(l_ctr1).ae_location_segment_id IS NOT NULL)
                   AND (nvl(ae_tax_tbl(l_ctr).ae_location_segment_id,-999)
                                              = nvl(ae_tax_activity_tbl(l_ctr1).ae_location_segment_id,-999)))
                   OR ((nvl(ae_tax_tbl(l_ctr).ae_tax_group_code_id,-999)
                                              = nvl(ae_tax_activity_tbl(l_ctr1).ae_tax_group_code_id,-999))
                      AND (ae_tax_tbl(l_ctr).ae_tax_code_id IS NOT NULL)
                      AND (ae_tax_activity_tbl(l_ctr1).ae_tax_code_id IS NOT NULL)
                      AND (nvl(ae_tax_tbl(l_ctr).ae_tax_code_id,-999)
                                              = nvl(ae_tax_activity_tbl(l_ctr1).ae_tax_code_id,-999)))
                   AND (ae_tax_tbl(l_ctr).ae_code_combination_id = ae_tax_activity_tbl(l_ctr1).ae_code_combination_id))
               THEN

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('Process_Recon: ' || 'Matching condition found in ae_tax_tbl, construct reconcile entry ');
                 END IF;

                 ae_tax_activity_tbl(l_ctr1).ae_match_flag := 'Y';

                 l_match_cond := TRUE;
                 l_cre_rec := FALSE;
                 l_ae_line_rec := l_ae_empty_line_rec;

              --deferred tax amounts
                 IF ((ae_tax_tbl(l_ctr).ae_amount + ae_tax_activity_tbl(l_ctr1).ae_amount) < 0) THEN

                    l_ae_line_rec.entered_dr := NULL;

                    l_ae_line_rec.entered_cr :=
                         abs(ae_tax_tbl(l_ctr).ae_amount + ae_tax_activity_tbl(l_ctr1).ae_amount);

                    l_cre_rec := TRUE;

                 ELSIF ((ae_tax_tbl(l_ctr).ae_amount + ae_tax_activity_tbl(l_ctr1).ae_amount) > 0) THEN

                    l_ae_line_rec.entered_dr :=
                        abs(ae_tax_tbl(l_ctr).ae_amount + ae_tax_activity_tbl(l_ctr1).ae_amount);

                    l_ae_line_rec.entered_cr := NULL;

                    l_cre_rec := TRUE;

                 END IF;

               --deferred tax accounted amounts
                   IF ((ae_tax_tbl(l_ctr).ae_acctd_amount + ae_tax_activity_tbl(l_ctr1).ae_acctd_amount) < 0) THEN

                    l_ae_line_rec.accounted_dr := NULL;

                    l_ae_line_rec.accounted_cr :=
                          abs(ae_tax_tbl(l_ctr).ae_acctd_amount + ae_tax_activity_tbl(l_ctr1).ae_acctd_amount) ;

                    l_cre_rec := TRUE;

                 ELSIF ((ae_tax_tbl(l_ctr).ae_acctd_amount + ae_tax_activity_tbl(l_ctr1).ae_acctd_amount) > 0) THEN

                       l_ae_line_rec.accounted_dr :=
                          abs(ae_tax_tbl(l_ctr).ae_acctd_amount + ae_tax_activity_tbl(l_ctr1).ae_acctd_amount);

                       l_ae_line_rec.accounted_cr := NULL;

                       l_cre_rec := TRUE;

                 END IF;

               --taxable amounts
                 IF ((ae_tax_tbl(l_ctr).ae_taxable_amount + ae_tax_activity_tbl(l_ctr1).ae_taxable_amount) < 0) THEN

                    l_ae_line_rec.taxable_entered_dr := NULL;

                    l_ae_line_rec.taxable_entered_cr :=
                       abs(ae_tax_tbl(l_ctr).ae_taxable_amount + ae_tax_activity_tbl(l_ctr1).ae_taxable_amount);

                    l_cre_rec := TRUE;

                 ELSIF ((ae_tax_tbl(l_ctr).ae_taxable_amount + ae_tax_activity_tbl(l_ctr1).ae_taxable_amount) > 0) THEN

                       l_ae_line_rec.taxable_entered_dr :=
                          abs(ae_tax_tbl(l_ctr).ae_taxable_amount + ae_tax_activity_tbl(l_ctr1).ae_taxable_amount);

                       l_ae_line_rec.taxable_entered_cr := NULL;

                       l_cre_rec := TRUE;

                 END IF;

               --taxable accounted amounts
                   IF ((ae_tax_tbl(l_ctr).ae_taxable_acctd_amount
                               + ae_tax_activity_tbl(l_ctr1).ae_taxable_acctd_amount) < 0) THEN

                    l_ae_line_rec.taxable_accounted_dr := NULL;

                    l_ae_line_rec.taxable_accounted_cr :=
                                     abs(ae_tax_tbl(l_ctr).ae_taxable_acctd_amount
                                                + ae_tax_activity_tbl(l_ctr1).ae_taxable_acctd_amount);

                    l_cre_rec := TRUE;

                 ELSIF ((ae_tax_tbl(l_ctr).ae_taxable_acctd_amount
                               + ae_tax_activity_tbl(l_ctr1).ae_taxable_acctd_amount) > 0) THEN

                       l_ae_line_rec.taxable_accounted_dr :=
                                     abs(ae_tax_tbl(l_ctr).ae_taxable_acctd_amount
                                              + ae_tax_activity_tbl(l_ctr1).ae_taxable_acctd_amount);

                       l_ae_line_rec.taxable_accounted_cr := NULL;

                       l_cre_rec := TRUE;

                 END IF;

                 EXIT; --loop activity table because tax and activity table match

               END IF; --deferred tax codes for tax and activity table match

           END LOOP; --activity table

         END IF; -- Tax activity table exists

        /*---------------------------------------------------------------------------------+
         |If no matching condition between tax table and tax activity table, then it means |
         |we need to create a reconciliation entry matching the original tax on the Bills  |
         |assignment or transaction.                                                       |
         +---------------------------------------------------------------------------------*/
           IF (NOT l_match_cond) THEN

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Process_Recon: ' || 'Matching condition not found in ae_tax_tbl, construct reconcile entry ');
              END IF;

           --set amount
              IF ae_tax_tbl(l_ctr).ae_amount > 0 THEN

                    l_ae_line_rec.entered_dr := abs(ae_tax_tbl(l_ctr).ae_amount);
                    l_ae_line_rec.entered_cr := NULL;
                    l_cre_rec := TRUE;
              ELSIF ae_tax_tbl(l_ctr).ae_amount < 0 THEN
                    l_ae_line_rec.entered_dr := NULL;
                    l_ae_line_rec.entered_cr := abs(ae_tax_tbl(l_ctr).ae_amount);
                    l_cre_rec := TRUE;
              END IF;

           --set accounted amount
              IF ae_tax_tbl(l_ctr).ae_acctd_amount > 0 THEN

                    l_ae_line_rec.accounted_dr := abs(ae_tax_tbl(l_ctr).ae_acctd_amount);
                    l_ae_line_rec.accounted_cr := NULL;
                    l_cre_rec := TRUE;
              ELSIF ae_tax_tbl(l_ctr).ae_acctd_amount < 0 THEN
                    l_ae_line_rec.accounted_dr := NULL;
                    l_ae_line_rec.accounted_cr := abs(ae_tax_tbl(l_ctr).ae_acctd_amount);
                    l_cre_rec := TRUE;
              END IF;

           --set taxable amount
              IF ae_tax_tbl(l_ctr).ae_taxable_amount > 0 THEN
                    l_ae_line_rec.taxable_entered_dr := abs(ae_tax_tbl(l_ctr).ae_taxable_amount);
                    l_ae_line_rec.taxable_entered_cr := NULL;
                    l_cre_rec := TRUE;
              ELSIF ae_tax_tbl(l_ctr).ae_taxable_amount < 0 THEN
                    l_ae_line_rec.taxable_entered_dr := NULL;
                    l_ae_line_rec.taxable_entered_cr := abs(ae_tax_tbl(l_ctr).ae_taxable_amount);
                    l_cre_rec := TRUE;
              END IF;

           --set taxable accounted amount
              IF ae_tax_tbl(l_ctr).ae_taxable_acctd_amount > 0 THEN
                    l_ae_line_rec.taxable_accounted_dr := abs(ae_tax_tbl(l_ctr).ae_taxable_acctd_amount);
                    l_ae_line_rec.taxable_accounted_cr := NULL;
                    l_cre_rec := TRUE;
              ELSIF ae_tax_tbl(l_ctr).ae_taxable_acctd_amount < 0 THEN
                    l_ae_line_rec.taxable_accounted_dr := NULL;
                    l_ae_line_rec.taxable_accounted_cr := abs(ae_tax_tbl(l_ctr).ae_taxable_acctd_amount);
                    l_cre_rec := TRUE;
              END IF;

           END IF; --no matching condition

        /*---------------------------------------------------------------------------------+
         |Build the ar distributions accounting record for cache into the global accounting|
         |table.                                                                           |
         +---------------------------------------------------------------------------------*/
           IF (l_cre_rec) THEN --set other attributes of accounting lines reconciliation entry

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('Process_Recon: ' || 'Assemble the l_ae_line_rec record for reconciliation entry ');
              END IF;

           --Build the Deferred Tax accounting entry
              Build_Deferred_Tax(
                       p_customer_trx_id     => p_customer_trx_id                        ,
                       p_br_cust_trx_line_id => p_br_cust_trx_line_id                    ,
                       p_location_segment_id => ae_tax_tbl(l_ctr).ae_location_segment_id ,
                       p_tax_group_code_id   => ae_tax_tbl(l_ctr).ae_tax_group_code_id   ,
                       p_tax_code_id         => ae_tax_tbl(l_ctr).ae_tax_code_id         ,
                       p_code_combination_id => ae_tax_tbl(l_ctr).ae_code_combination_id ,
                       p_ae_doc_rec          => p_ae_doc_rec                             ,
                       p_cust_inv_rec        => p_cust_inv_rec                           ,
                       p_calling_point       => p_calling_point                          ,
                       p_ae_line_rec         => l_ae_line_rec                             );

            --Assign tax lines reconciliation record to global accounting table
               Assign_Elements(p_ae_line_rec       =>    l_ae_line_rec  ,
                               p_g_ae_ctr          =>    p_g_ae_ctr     ,
                               p_g_ae_line_tbl     =>    p_g_ae_line_tbl );

            --Build the Collected tax accounting entry
               Build_Tax (p_customer_trx_id     => p_customer_trx_id,
                          p_location_segment_id => ae_tax_tbl(l_ctr).ae_location_segment_id  ,
                          p_tax_group_code_id   => ae_tax_tbl(l_ctr).ae_tax_group_code_id    ,
                          p_tax_code_id         => ae_tax_tbl(l_ctr).ae_tax_code_id          ,
                          p_code_combination_id => ae_tax_tbl(l_ctr).ae_code_combination_id  ,
                          p_ae_line_rec         => l_ae_line_rec                               );

            --Assign tax lines reconciliation record to global accounting table
               Assign_Elements(p_ae_line_rec       =>    l_ae_line_rec  ,
                               p_g_ae_ctr          =>    p_g_ae_ctr    ,
                               p_g_ae_line_tbl     =>    p_g_ae_line_tbl);

           END IF; --create reconciliation accounting record

       END LOOP; --tax table

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Process_Recon: ' || 'REVERSE SWEEP ');
       END IF;

    /*----------------------------------------------------------------------------+
     | Sweep through the tax activity table and if the matching flag is not Y then|
     | it means that the combination of tax group, tax code, tax account or tax   |
     | location and account does not exist on the Original Transaction - so back  |
     | out NOCOPY the deferred tax.                                                      |
     +----------------------------------------------------------------------------*/
       IF ae_tax_activity_tbl.EXISTS(l_tax_ctr1) THEN

          FOR l_ctr IN ae_tax_activity_tbl.FIRST .. ae_tax_activity_tbl.LAST LOOP

              IF nvl(ae_tax_activity_tbl(l_ctr).ae_match_flag, 'N') <> 'Y' THEN

               --Initialize record
                 l_ae_line_rec := l_ae_empty_line_rec;

               /*------------------------------------------------------------------+
                | Set the deferred tax accounting buckets, and taxable buckets for |
                | creation of the Deferred tax reversal on accounting created due  |
                | to activity as there is no match for on Original Transaction by  |
                | tax group, tax code, location and account                        |
                +------------------------------------------------------------------*/
                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('Process_Recon: ' || 'REVERSE SWEEP ae_tax_activity_tbl(l_ctr).ae_amount' || ae_tax_activity_tbl(l_ctr).ae_amount);
                 END IF;
                 IF ae_tax_activity_tbl(l_ctr).ae_amount > 0 THEN

                    l_ae_line_rec.entered_dr := abs(ae_tax_activity_tbl(l_ctr).ae_amount);
                    l_ae_line_rec.entered_cr := NULL;
                    l_cre_rec := TRUE;
                 ELSIF ae_tax_activity_tbl(l_ctr).ae_amount < 0 THEN
                       l_ae_line_rec.entered_dr := NULL;
                       l_ae_line_rec.entered_cr := abs(ae_tax_activity_tbl(l_ctr).ae_amount);
                       l_cre_rec := TRUE;
                 END IF;

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('Process_Recon: ' || 'REVERSE SWEEP ae_tax_activity_tbl(l_ctr).ae_acctd_amount' || ae_tax_activity_tbl(l_ctr).ae_acctd_amount);
                 END IF;
              --set accounted amount
                 IF ae_tax_activity_tbl(l_ctr).ae_acctd_amount > 0 THEN

                    l_ae_line_rec.accounted_dr := abs(ae_tax_activity_tbl(l_ctr).ae_acctd_amount);
                    l_ae_line_rec.accounted_cr := NULL;
                    l_cre_rec := TRUE;
                 ELSIF ae_tax_activity_tbl(l_ctr).ae_acctd_amount < 0 THEN
                       l_ae_line_rec.accounted_dr := NULL;
                       l_ae_line_rec.accounted_cr := abs(ae_tax_activity_tbl(l_ctr).ae_acctd_amount);
                       l_cre_rec := TRUE;
                 END IF;

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('Process_Recon: ' || 'REVERSE SWEEP ae_tax_activity_tbl(l_ctr).ae_taxable_amount' || ae_tax_activity_tbl(l_ctr).ae_taxable_amount);
                 END IF;
              --set taxable amount
                 IF ae_tax_activity_tbl(l_ctr).ae_taxable_amount > 0 THEN
                    l_ae_line_rec.taxable_entered_dr := abs(ae_tax_activity_tbl(l_ctr).ae_taxable_amount);
                    l_ae_line_rec.taxable_entered_cr := NULL;
                    l_cre_rec := TRUE;
                 ELSIF ae_tax_activity_tbl(l_ctr).ae_taxable_amount < 0 THEN
                       l_ae_line_rec.taxable_entered_dr := NULL;
                       l_ae_line_rec.taxable_entered_cr := abs(ae_tax_activity_tbl(l_ctr).ae_taxable_amount);
                       l_cre_rec := TRUE;
                 END IF;

                 IF PG_DEBUG in ('Y', 'C') THEN
                    arp_standard.debug('Process_Recon: ' || 'REVERSE SWEEP ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount' || ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount);
                 END IF;
              --set taxable accounted amount
                 IF ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount > 0 THEN
                    l_ae_line_rec.taxable_accounted_dr := abs(ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount);
                    l_ae_line_rec.taxable_accounted_cr := NULL;
                    l_cre_rec := TRUE;
                 ELSIF ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount < 0 THEN
                       l_ae_line_rec.taxable_accounted_dr := NULL;
                       l_ae_line_rec.taxable_accounted_cr := abs(ae_tax_activity_tbl(l_ctr).ae_taxable_acctd_amount);
                       l_cre_rec := TRUE;
                 END IF;

             --Build the Deferred Tax accounting entry
                 Build_Deferred_Tax(
                        p_customer_trx_id     => p_customer_trx_id                                 ,
                        p_br_cust_trx_line_id => p_br_cust_trx_line_id                             ,
                        p_location_segment_id => ae_tax_activity_tbl(l_ctr).ae_location_segment_id ,
                        p_tax_group_code_id   => ae_tax_activity_tbl(l_ctr).ae_tax_group_code_id   ,
                        p_tax_code_id         => ae_tax_activity_tbl(l_ctr).ae_tax_code_id         ,
                        p_code_combination_id => ae_tax_activity_tbl(l_ctr).ae_code_combination_id ,
                        p_ae_doc_rec          => p_ae_doc_rec                                      ,
                        p_cust_inv_rec        => p_cust_inv_rec                                    ,
                        p_calling_point       => p_calling_point                                   ,
                        p_ae_line_rec         => l_ae_line_rec                                      );

              --Assign tax lines reconciliation record to global accounting table
                 Assign_Elements(p_ae_line_rec       =>    l_ae_line_rec  ,
                                 p_g_ae_ctr          =>    p_g_ae_ctr     ,
                                 p_g_ae_line_tbl     =>    p_g_ae_line_tbl );

              --Build the Collected tax accounting entry
                 Build_Tax (p_customer_trx_id     => p_customer_trx_id,
                            p_location_segment_id => ae_tax_activity_tbl(l_ctr).ae_location_segment_id  ,
                            p_tax_group_code_id   => ae_tax_activity_tbl(l_ctr).ae_tax_group_code_id    ,
                            p_tax_code_id         => ae_tax_activity_tbl(l_ctr).ae_tax_code_id          ,
                            p_code_combination_id => ae_tax_activity_tbl(l_ctr).ae_code_combination_id  ,
                            p_ae_line_rec         => l_ae_line_rec                                        );

              --Assign tax lines reconciliation record to global accounting table
                 Assign_Elements(p_ae_line_rec       =>    l_ae_line_rec  ,
                                 p_g_ae_ctr          =>    p_g_ae_ctr    ,
                                 p_g_ae_line_tbl     =>    p_g_ae_line_tbl);

              END IF;

          END LOOP; --tax activity table

       END IF; --tax activity table exists

    END IF; --lines exist in tax and activity table

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('ARP_RECONCILE.Process_Recon ()-');
 END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION NO_DATA_FOUND : ARP_RECONCILE.Process_Recon ');
      END IF;
      RAISE;

   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Process_Recon ');
      END IF;
      RAISE;

END Process_Recon;

/*========================================================================
 | PRIVATE PROCEDURE Build_Deferred_Tax
 |
 | DESCRIPTION
 |      Builds the the deferred tax accounting entry for Reconciliation
 |      of the accounting, sets currency details, accounts, source and
 |      tax group, tax codes or location
 |
 | PARAMETERS
 |      p_customer_trx_id        IN      Transaction Id
 |      p_br_cust_trx_line_id    IN      Bills assignment line id
 |      p_location_segment_id    IN      Location segment
 |      p_tax_group_code_id      IN      Group Code
 |      p_tax_code_id            IN      Tax Code Id
 |      p_code_combination_id    IN      Ccid of deferred tax account
 |      p_ae_doc_rec             IN      Document Record
 |      p_cust_inv_rec           IN      Exchange rate details record
 |      p_ae_line_rec            IN      Line record
 +-----------------------------------------------------------------------------*/
PROCEDURE Build_Deferred_Tax (p_customer_trx_id     IN NUMBER,
                              p_br_cust_trx_line_id IN NUMBER,
                              p_location_segment_id IN NUMBER,
                              p_tax_group_code_id   IN NUMBER,
                              p_tax_code_id         IN NUMBER,
                              p_code_combination_id IN NUMBER,
                              p_ae_doc_rec          IN ae_doc_rec_type,
                              p_cust_inv_rec        IN ra_customer_trx%ROWTYPE,
                              p_calling_point       IN VARCHAR2,
                              p_ae_line_rec         IN OUT NOCOPY ae_line_rec_type     ) IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_RECONCILE.Build_Deferred_Tax ()+');
  END IF;

/*-----------------------------------------------------------------------------+
 | Create the Dr or Cr to the deferred tax account, set details such as rates, |
 | source type secondary , tax group, tax code or location id.                 |
 +-----------------------------------------------------------------------------*/
  IF p_location_segment_id IS NOT NULL THEN
     p_ae_line_rec.location_segment_id := p_location_segment_id;
  ELSE
     p_ae_line_rec.tax_group_code_id := p_tax_group_code_id;
     p_ae_line_rec.tax_code_id := p_tax_code_id;
  END IF;

/*-----------------------------------------------------------------------------+
 | Assign Currency Exchange rate information to initialisation record, tax link|
 | id is not populated. Create the Dr or Cr to the deferred tax account.       |
 +-----------------------------------------------------------------------------*/
  p_ae_line_rec.source_id                 := p_ae_doc_rec.source_id               ;
  p_ae_line_rec.source_table              := p_ae_doc_rec.source_table            ;
  p_ae_line_rec.ae_line_type              := 'DEFERRED_TAX'                       ;
  p_ae_line_rec.account                   := p_code_combination_id                ;

/*------------------------------------------------------------------------------+
 | Populate the secondary columns, for Bills Receivable we populate with the    |
 | Bill line id, however for transactions only the source type secondary is used|
 +------------------------------------------------------------------------------*/
  IF (p_calling_point IN ('BILL', 'BLTR')) THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_Deferred_Tax: ' || 'Setting source type secondary to ASSIGNMENT_RECONCILE');
     END IF;

   --set transaction reconciliation entries line type secondary when bill is closed
     IF (p_calling_point = 'BLTR') THEN
        p_ae_line_rec.ae_line_type_secondary    := 'RECONCILE'            ;
     ELSE
        p_ae_line_rec.ae_line_type_secondary    := 'ASSIGNMENT_RECONCILE' ;
     END IF;

     p_ae_line_rec.source_id_secondary       := p_br_cust_trx_line_id                ;
     p_ae_line_rec.source_table_secondary    := 'CTL'                                ;
  ELSE   --for transactions we only populate source type secondary for deferred tax
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_Deferred_Tax: ' || 'Setting source type secondary to RECONCILE');
     END IF;
     p_ae_line_rec.ae_line_type_secondary    := 'RECONCILE';
     p_ae_line_rec.source_id_secondary       := p_customer_trx_id;
     p_ae_line_rec.source_table_secondary    := 'CT';
  END IF;

  p_ae_line_rec.currency_code             := p_cust_inv_rec.invoice_currency_code ;
  p_ae_line_rec.currency_conversion_rate  := p_cust_inv_rec.exchange_rate         ;
  p_ae_line_rec.currency_conversion_type  := p_cust_inv_rec.exchange_rate_type    ;
  p_ae_line_rec.currency_conversion_date  := p_cust_inv_rec.exchange_date         ;
  p_ae_line_rec.third_party_id            := p_cust_inv_rec.bill_to_customer_id   ;
  p_ae_line_rec.third_party_sub_id        := p_cust_inv_rec.bill_to_site_use_id   ;
  p_ae_line_rec.tax_link_id               := ''                                   ;
  p_ae_line_rec.reversed_source_id        := ''                                   ;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_RECONCILE.Build_Deferred_Tax ()-');
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION NO_DATA_FOUND : ARP_RECONCILE.Build_Deferred_Tax ');
      END IF;
      RAISE;

   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Build_Deferred_Tax ');
      END IF;
      RAISE;

END Build_Deferred_Tax;

/*========================================================================
 | PRIVATE PROCEDURE Build_Tax
 |
 | DESCRIPTION
 |      Builds the line record swapping the amounts and taxable amounts.
 |      Sets the account.
 |
 | PARAMETERS
 |      p_customer_trx_id        IN      Transaction Id
 |      p_location_segment_id    IN      Location segment
 |      p_tax_group_code_id      IN      Group Code
 |      p_tax_code_id            IN      Tax Code Id
 |      p_code_combination_id    IN      Ccid of deferred tax account
 |      p_ae_line_rec            IN      Line record
 +-----------------------------------------------------------------------------*/
PROCEDURE Build_Tax (p_customer_trx_id     IN NUMBER,
                     p_location_segment_id IN NUMBER,
                     p_tax_group_code_id   IN NUMBER,
                     p_tax_code_id         IN NUMBER,
                     p_code_combination_id IN NUMBER,
                     p_ae_line_rec         IN OUT NOCOPY ae_line_rec_type ) IS

l_collected_ccid NUMBER;
l_swap_amt       NUMBER;

BEGIN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECONCILE.Build_Tax ()+');
     END IF;

  /*-----------------------------------------------------------------------------+
   | Create the Offsetting Dr or Cr to the Collected tax account. To do this, the|
   | tax code or location is used to retrieve the collected tax account.         |
   | Retrieve the offsetting collected tax account from the Invoices tax code or |
   | location from the accounting distributions. Note if the same tax group, tax |
   | code or location segment for a deferred tax account has more than one       |
   | collected tax account, then the max of the ccid contains the reconciled     |
   | difference. This may happen if it is possible to change distributions       |
   | manually. Ideally the combination of deferred and collected tax accounts    |
   | will not change.                                                            |
   +-----------------------------------------------------------------------------*/
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_Tax: ' || 'Fetching offsetting collected tax accounting entry');
        arp_standard.debug('Build_Tax: ' || 'Using parameter p_customer_trx_id '   || p_customer_trx_id);
        arp_standard.debug('Build_Tax: ' || 'Using parameter location_segment_id ' || p_location_segment_id);
        arp_standard.debug('Build_Tax: ' || 'Using parameter tax_group_code_id '   || p_tax_group_code_id);
        arp_standard.debug('Build_Tax: ' || 'Using parameter tax_code_id '         || p_tax_code_id);
        arp_standard.debug('Build_Tax: ' || 'Using parameter code_combination_id ' || p_code_combination_id);
     END IF;

--In R12 the vat tax id also called the tax rate id is the unique key
--there is no concept of tax group id and location segment id is no longer
--used - it is all vat tax id on TAX line type
     SELECT max(gld.collected_tax_ccid) ae_collected_tax_ccid
     INTO l_collected_ccid
     FROM ra_cust_trx_line_gl_dist  gld,
          ra_customer_trx_lines     ctl
     --ra_customer_trx_lines     ctl1
     WHERE ctl.customer_trx_id      = p_customer_trx_id
     AND   gld.customer_trx_id      = ctl.customer_trx_id
     AND   gld.customer_trx_line_id = ctl.customer_trx_line_id
     AND   gld.account_class        = 'TAX'
     AND   gld.account_set_flag     = 'N'
     AND   gld.collected_tax_ccid IS NOT NULL --deferred tax only
     AND   gld.code_combination_id  = p_code_combination_id
    -- AND   (((p_location_segment_id IS NOT NULL)
    --            AND (ctl.location_segment_id  = nvl(p_location_segment_id,-999)))
    --AND (p_tax_code_id IS NOT NULL)
     AND ctl.vat_tax_id = nvl(p_tax_code_id,-999)
    --AND   ctl.link_to_cust_trx_line_id = ctl1.customer_trx_line_id
    --AND  ctl1.vat_tax_id  =  nvl(p_tax_group_code_id,ctl1.vat_tax_id)
     AND   not exists (select 'x'
                       from ra_customer_trx_lines ctl1
                       where ctl1.customer_trx_id = p_customer_trx_id
                       and   ctl1.autorule_complete_flag = 'N');
--bug7484223
     IF l_collected_ccid IS NULL then

       IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('This code will be called in very rare scenario.');
         arp_standard.debug('This will derive tax ccid if above routine fails to derive.');
       END IF;

       SELECT max(gld.collected_tax_ccid) ae_collected_tax_ccid
       INTO l_collected_ccid
       FROM ra_cust_trx_line_gl_dist  gld,
            ra_customer_trx_lines     ctl
       --ra_customer_trx_lines     ctl1
       WHERE ctl.customer_trx_id      = p_customer_trx_id
       AND   gld.customer_trx_id      = ctl.customer_trx_id
       AND   gld.customer_trx_line_id = ctl.customer_trx_line_id
       AND   gld.account_class        = 'TAX'
       AND   gld.account_set_flag     = 'N'
       AND   gld.collected_tax_ccid IS NOT NULL --deferred tax only
      -- AND   gld.code_combination_id  = p_code_combination_id
      -- AND   (((p_location_segment_id IS NOT NULL)
      --            AND (ctl.location_segment_id  = nvl(p_location_segment_id,-999)))
      --AND (p_tax_code_id IS NOT NULL)
       AND ctl.vat_tax_id = nvl(p_tax_code_id,-999)
      --AND   ctl.link_to_cust_trx_line_id = ctl1.customer_trx_line_id
      --AND  ctl1.vat_tax_id  =  nvl(p_tax_group_code_id,ctl1.vat_tax_id)
       AND   not exists (select 'x'
                         from ra_customer_trx_lines ctl1
                         where ctl1.customer_trx_id = p_customer_trx_id
                         and   ctl1.autorule_complete_flag = 'N');
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('Build_Tax: Collected CCID: '||l_collected_ccid);
        arp_standard.debug('Build_Tax: ' || 'Completed fetching offsetting collected tax accounting entry');
     END IF;

     p_ae_line_rec.ae_line_type  := 'TAX';
     p_ae_line_rec.account       := l_collected_ccid;

   --Now swap debits and credits for the Collected tax amounts
     l_swap_amt                  := p_ae_line_rec.entered_dr;
     p_ae_line_rec.entered_dr    := p_ae_line_rec.entered_cr;
     p_ae_line_rec.entered_cr    := l_swap_amt;

   --Now swap debits and credits for the Collected tax accounted amounts
     l_swap_amt                  := p_ae_line_rec.accounted_dr;
     p_ae_line_rec.accounted_dr  := p_ae_line_rec.accounted_cr;
     p_ae_line_rec.accounted_cr  := l_swap_amt;

   --Now swap debits and credits for the Collected taxable amounts
     l_swap_amt                          := p_ae_line_rec.taxable_entered_dr;
     p_ae_line_rec.taxable_entered_dr    := p_ae_line_rec.taxable_entered_cr;
     p_ae_line_rec.taxable_entered_cr    := l_swap_amt;

   --Now swap debits and credits for the Collected taxable accounted amounts
     l_swap_amt                          := p_ae_line_rec.taxable_accounted_dr;
     p_ae_line_rec.taxable_accounted_dr  := p_ae_line_rec.taxable_accounted_cr;
     p_ae_line_rec.taxable_accounted_cr    := l_swap_amt;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('ARP_RECONCILE.Build_Tax ()-');
     END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION NO_DATA_FOUND : ARP_RECONCILE.Build_Tax ');
      END IF;
      RAISE;

   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION OTHERS : ARP_RECONCILE.Build_Tax ');
      END IF;
      RAISE;

END Build_Tax;

END ARP_RECONCILE;

/
