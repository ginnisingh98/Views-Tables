--------------------------------------------------------
--  DDL for Package Body ARP_ACCT_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ACCT_MAIN" AS
/* $Header: ARTACCMB.pls 120.19.12010000.9 2010/07/23 17:34:28 rmanikan ship $ */

/*========================================================================
 | Prototype Declarations
 *=======================================================================*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PG_DEL_FRM_GT_CNT NUMBER := NVL(FND_PROFILE.value('AR_DEL_FRM_GT_CNT'), 1000);

PROCEDURE Insert_Ae_Lines(p_ae_line_tbl IN ae_line_tbl_type);

PROCEDURE Init_Curr_Details(p_accounting_method IN OUT NOCOPY ar_system_parameters.accounting_method%TYPE);

PROCEDURE Dump_Dist_Amts(p_ae_line_rec  ar_distributions%ROWTYPE);

/*========================================================================
 | Public Functions/Procedures
 *=======================================================================*/

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This procedure calls the document main packages to create accounting
 |      for Receipts, Credit Memos and Adjustments.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 |      p_client_server IN      A value indicates that a call is made
 |                              from C code hence raise exception.
 | KNOWN ISSUES
 |	6-24-02  We are consciously not doing any modification to the
 |		 arp_acct_hook for the mrc trigger replacment.
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_mode          IN VARCHAR2,    -- DOCUMENT or ACCT_EVENT
                p_ae_doc_rec    IN ae_doc_rec_type,
                p_ae_event_rec  IN ae_event_rec_type,
                p_client_server IN VARCHAR2 DEFAULT NULL,
                --{HYUDETUPT
                p_from_llca_call  IN VARCHAR2 DEFAULT 'N',
                p_gt_id           IN NUMBER   DEFAULT NULL,
                --}
		p_called_from     IN VARCHAR2 DEFAULT NULL
                ) IS

  l_replace_default_processing 	BOOLEAN := FALSE;
  l_ae_created                  BOOLEAN := FALSE;
  l_ae_line_tbl                 ae_line_tbl_type;
  l_summarize			BOOLEAN := FALSE;
  l_sob_id			NUMBER;
  l_accounting_method           ar_system_parameters.accounting_method%TYPE;
  l_create_acct                 VARCHAR2(1) := 'Y';

  --Bug#2750340
  l_xla_ev_rec      arp_xla_events.xla_events_type;
  l_xla_doc_table   VARCHAR2(20);
  l_rows            NUMBER;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'ARP_ACCT_MAIN.Create_Acct_Entry()+');
   END IF;

 /*-----------------------------------------------------------------------+
  |Dump the document record details usefull for debugging purposes.       |
  +-----------------------------------------------------------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(  ' Document Type             :' || p_ae_doc_rec.document_type);
      arp_standard.debug(  ' Document Id               :' || p_ae_doc_rec.document_id);
      arp_standard.debug(  ' Accounting Entity Level   :' || p_ae_doc_rec.accounting_entity_level);
      arp_standard.debug(  ' Source Table              :' || p_ae_doc_rec.source_table);
      arp_standard.debug(  ' Source Id                 :' || p_ae_doc_rec.source_id);
      arp_standard.debug(  ' Source Id Old             :' || p_ae_doc_rec.source_id_old);
      arp_standard.debug(  ' Other Flag                :' || p_ae_doc_rec.other_flag);
      arp_standard.debug(  ' Miscel1                   :' || p_ae_doc_rec.miscel1);
      arp_standard.debug(  ' Miscel2                   :' || p_ae_doc_rec.miscel2);
      arp_standard.debug(  ' Miscel3                   :' || p_ae_doc_rec.miscel3);
      arp_standard.debug(  ' Miscel4                   :' || p_ae_doc_rec.miscel4);
      arp_standard.debug(  ' Miscel5                   :' || p_ae_doc_rec.miscel5);
      arp_standard.debug(  ' Miscel6                   :' || p_ae_doc_rec.miscel6);
      arp_standard.debug(  ' Miscel7                   :' || p_ae_doc_rec.miscel7);
      arp_standard.debug(  ' Miscel8                   :' || p_ae_doc_rec.miscel8);
      arp_standard.debug(  ' Event                     :' || p_ae_doc_rec.event);
      arp_standard.debug(  ' Deferred Tax              :' || p_ae_doc_rec.deferred_tax);
      arp_standard.debug(  ' Called_from               :' || p_ae_doc_rec.called_from);
      arp_standard.debug(  ' Tax account id            :' || p_ae_doc_rec.gl_tax_acct);
      --{HYUDETUPT
      arp_standard.debug(  ' p_from_llca_call          :' || p_from_llca_call);
      arp_standard.debug(  ' p_gt_id                   :' || p_gt_id);
      arp_standard.debug(  ' PG_DEL_FRM_GT_CNT         :' || PG_DEL_FRM_GT_CNT);
      arp_standard.debug(  ' p_called_from             :' || p_called_from);
      --}
   END IF;
                                                       /* Bug fix 2300268 : Added debug message*/
   /* * Bug 8689308 : Peroformance issue when multiple applications are made   *
      * for a single receipt due to piling up of data in GT tables. Hence      *
      * periodically delete the data from GT tables for every 1000 applications*
      * for a receipt.                                                         * */
   IF arp_det_dist_pkg.g_appln_count >= PG_DEL_FRM_GT_CNT THEN
        IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('Exceeded upper limit for maximum number of rows in ra_ar_gt');
         arp_standard.debug('Clear all gt tables');
        END IF;

      DELETE FROM ra_customer_trx_lines_gt;
        IF PG_DEBUG in ('Y', 'C') THEN
         l_rows := sql%rowcount;
         arp_standard.debug('No of rows deleted from ra_customer_trx_lines_gt : '||l_rows);
        END IF;

      DELETE FROM ra_ar_gt;
        IF PG_DEBUG in ('Y', 'C') THEN
         l_rows := SQL%ROWCOUNT;
         arp_standard.debug('No of rows deleted from ra_ar_gt : '||l_rows);
        END IF;

      DELETE FROM ra_ar_amounts_gt;
        IF PG_DEBUG in ('Y', 'C') THEN
         l_rows := SQL%ROWCOUNT;
         arp_standard.debug('No of rows deleted from ra_ar_amounts_gt : '||l_rows);
        END IF;

      DELETE FROM ar_base_dist_amts_gt;
        IF PG_DEBUG in ('Y', 'C') THEN
         l_rows := SQL%ROWCOUNT;
         arp_standard.debug('No of rows deleted from ar_base_dist_amts_gt : '||l_rows);
        END IF;

      DELETE FROM ar_line_app_detail_gt;
        IF PG_DEBUG in ('Y', 'C') THEN
         l_rows := SQL%ROWCOUNT;
         arp_standard.debug('No of rows deleted from ar_line_app_detail_gt : '||l_rows);
        END IF;

      DELETE FROM ar_ae_alloc_rec_gt;
        IF PG_DEBUG in ('Y', 'C') THEN
         l_rows := SQL%ROWCOUNT;
         arp_standard.debug('No of rows deleted from ar_ae_alloc_rec_gt : '||l_rows);
        END IF;
   END IF;

   Init_Curr_Details(p_accounting_method => l_accounting_method);


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'ARP_ACCT_MAIN - Accounting Method ' || l_accounting_method);
   END IF;

-- bug5655154, commented accounting_method = 'ACCRUAL' check
--   IF l_accounting_method = 'ACCRUAL' THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'Create_Acct_Entry - Processing Accounting Method ' || l_accounting_method);
      END IF;

  /*---------------------------------------------------------------------------+
   |Determine whether we really need to create accounting, in the case of MCD  |
   |as the drive is using the document id against source id we dont need to    |
   |check whether its accounting exists.The check below is a security mechanism|
   +---------------------------------------------------------------------------*/
      --Check is not required if the call is from auto receipts BUG 6660834
      IF NVL( p_called_from, 'NONE' ) NOT IN ('AUTORECAPI','AUTORECAPI2') THEN
	  IF ((p_ae_doc_rec.accounting_entity_level = 'ONE')
			AND (p_ae_doc_rec.source_table <> 'MCD'))  THEN
	  BEGIN

	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_standard.debug(  'ARP_ACCT_MAIN.Create_Acct_Entry - check whether accounting required ');
	     END IF;

	     select 'N'
	     into l_create_acct
	     from dual
	     where exists (select 'X'
			   from ar_distributions dist
			   where dist.source_id    = p_ae_doc_rec.source_id
			   and   dist.source_table = p_ae_doc_rec.source_table);

	     IF PG_DEBUG in ('Y', 'C') THEN
		arp_standard.debug(  'ARP_ACCT_MAIN.Create_Acct_Entry - accounting already exists');
	     END IF;

	     EXCEPTION
	     WHEN NO_DATA_FOUND THEN
		 IF PG_DEBUG in ('Y', 'C') THEN
		    arp_standard.debug(  'ARP_ACCT_MAIN.Create_Acct_Entry - creating accounting ');
		 END IF;
		 l_create_acct := 'Y';
	  END;

	  END IF; --end if check accounting required
      END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  'l_create_acct = ' || l_create_acct);
      END IF;

      IF (l_create_acct = 'N') THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(  'Ending Processing for l_create_acct = ' || l_create_acct);
         END IF;
         GOTO end_process_lbl;
      END IF;

     /*------------------------------------------------------+
      | Get Summarization Rules    		             |
      +------------------------------------------------------*/
      l_summarize := FALSE;

     /*------------------------------------------------------+
      | Call Hook to Override Accounting Entry		  |
      +------------------------------------------------------*/

      ARP_ACCT_HOOK.Override_Ae_Lines(
            p_mode                         => p_mode
           ,p_ae_doc_rec                   => p_ae_doc_rec
           ,p_ae_event_rec                 => p_ae_event_rec
           ,p_ae_line_tbl                  => l_ae_line_tbl
           ,p_ae_created                   => l_ae_created
           ,p_replace_default_processing   => l_replace_default_processing
	   );

      IF ( NOT l_replace_default_processing ) THEN

        /*------------------------------------------------------+
         | Accounting Entry Derivation	  		     |
         +------------------------------------------------------*/
         IF (( p_ae_doc_rec.document_type = 'RECEIPT') OR
                 ((p_ae_doc_rec.document_type = 'CREDIT_MEMO') AND
                      (p_ae_doc_rec.source_table = 'RA'))) THEN

   	   	ARP_RECEIPTS_MAIN.Execute(
                            p_mode         => p_mode,
                            p_ae_doc_rec   => p_ae_doc_rec,
                            p_ae_event_rec => p_ae_event_rec,
                            p_ae_line_tbl  => l_ae_line_tbl,
                            p_ae_created   => l_ae_created,
                            --{HYUDETUPT
                            p_from_llca_call => p_from_llca_call,
                            p_gt_id          => p_gt_id
                            --}
                                );

         ELSIF p_ae_doc_rec.document_type = 'ADJUSTMENT' OR
                  p_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN

          -- Added parameter for Line level adjustment
	       ARP_ADJUSTMENTS_MAIN.Execute(
                                p_mode,
                                p_ae_doc_rec,
                                p_ae_event_rec,
                                l_ae_line_tbl,
                                l_ae_created,
				p_from_llca_call => p_from_llca_call,
                                p_gt_id          => p_gt_id
                               );

         ELSIF p_ae_doc_rec.document_type = 'BILLS_RECEIVABLE' THEN

               ARP_BILLS_RECEIVABLE_MAIN.Execute(
                                p_mode,
                                p_ae_doc_rec,
                                p_ae_event_rec,
                                l_ae_line_tbl,
                                l_ae_created
                               );

         END IF;		-- Document type

      END IF;		-- Replace Default Processing?

     /*------------------------------------------------------+
      | Optionally Summarize Accounting Entry Lines created  |
      +------------------------------------------------------*/
       IF l_ae_created AND l_summarize THEN

         NULL;

       END IF;


     /*------------------------------------------------------+
      | Insert Accounting Entry Lines into AEL table         |
      +------------------------------------------------------*/
       IF l_ae_created THEN

           Insert_Ae_Lines(l_ae_line_tbl);

       END IF;

          --{ Bug#2750340 : Call ARP_XLA_EVENT
      IF arp_global.request_id IS NULL AND
         NVL( p_called_from, 'NONE' ) NOT IN ('AUTORECAPI','AUTORECAPI2','CUSTRECAPIBULK') THEN

         l_xla_ev_rec.xla_from_doc_id := p_ae_doc_rec.document_id;
         l_xla_ev_rec.xla_to_doc_id   := p_ae_doc_rec.document_id;
         l_xla_ev_rec.xla_mode        := 'O';
         l_xla_ev_rec.xla_call        := 'B';

         IF    p_ae_doc_rec.source_table = 'MCD' AND p_ae_doc_rec.document_type = 'RECEIPT' THEN
           l_xla_ev_rec.xla_doc_table := 'MCD';
           l_xla_ev_rec.xla_call  := 'D';
           ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
         ELSIF p_ae_doc_rec.source_table = 'RA'  AND p_ae_doc_rec.document_type = 'RECEIPT' THEN
           l_xla_ev_rec.xla_doc_table := 'APP';
           l_xla_ev_rec.xla_from_doc_id := p_ae_doc_rec.source_id;
           l_xla_ev_rec.xla_to_doc_id   := p_ae_doc_rec.source_id;
           ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
         ELSIF p_ae_doc_rec.source_table = 'RA'  AND p_ae_doc_rec.document_type = 'CREDIT_MEMO' THEN
           l_xla_ev_rec.xla_doc_table := 'CMAPP';
           l_xla_ev_rec.xla_from_doc_id := p_ae_doc_rec.source_id;
           l_xla_ev_rec.xla_to_doc_id   := p_ae_doc_rec.source_id;
           ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
         ELSIF p_ae_doc_rec.source_table = 'ADJ' AND p_ae_doc_rec.document_type = 'ADJUSTMENT' THEN
           l_xla_ev_rec.xla_doc_table := 'ADJ';
           ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
         ELSIF p_ae_doc_rec.source_table = 'ADJ' AND p_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN
           l_xla_ev_rec.xla_doc_table := 'ADJ';
           ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
         ELSIF p_ae_doc_rec.source_table = 'TH'  AND p_ae_doc_rec.document_type = 'BILLS_RECEIVABLE' THEN
           l_xla_ev_rec.xla_doc_table := 'TRH';
           ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
         END IF;

       END IF;
       --}

-- bug5655154, commented the end if condition
--   END IF; --end if ACCRUAL method of accounting

<<end_process_lbl>>
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'ARP_ACCT_MAIN.Create_Acct_Entry()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ACCT_MAIN.Create_Acct_Entry');
     END IF;
     IF p_client_server IS NULL THEN
        app_exception.raise_exception;
     ELSE
        RAISE;
     END IF;

END Create_Acct_Entry;

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed the document
 |      information, to create accounting entries for Receipts, Credit Memos
 |      or Adjustments.
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_ae_doc_rec    IN ae_doc_rec_type,
                p_client_server IN VARCHAR2 DEFAULT NULL,
                --{HYUDETUPT
                p_from_llca_call IN VARCHAR2 DEFAULT 'N',
                p_gt_id          IN NUMBER   DEFAULT NULL,
                --}
		p_called_from     IN VARCHAR2 DEFAULT NULL
                ) IS

l_mode          VARCHAR2(1);
l_ae_event_rec  ae_event_rec_type ;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded ARP_ACCT_MAIN.Create_Acct_Entry()+');
   END IF;

   Create_Acct_Entry(p_mode           => l_mode,
                     p_ae_doc_rec     => p_ae_doc_rec,
                     p_ae_event_rec   => l_ae_event_rec,
                     p_client_server  => p_client_server,
                     p_from_llca_call => p_from_llca_call,
                     p_gt_id          => p_gt_id,
		     p_called_from    => p_called_from );

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded ARP_ACCT_MAIN.Create_Acct_Entry()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: Overloaded ARP_ACCT_MAIN.Create_Acct_Entry');
     END IF;
     RAISE;
END Create_Acct_Entry;

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed the document
 |      information, to create accounting entries for Receipts, Credit Memos
 |      or Adjustments.
 |
 | PARAMETERS
 |      document_type           IN      Document Type
 |      document_id             IN      Document Id
 |      accounting_entity_level IN      Entitity Level accounting
 |      source_table            IN      Source table
 |      source_id               IN      Source Id
 |      source_id_old           IN      Source Id Old
 |      other_flag              IN      Other Flag
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_document_type           IN VARCHAR2,
                p_document_id             IN NUMBER  ,
                p_accounting_entity_level IN VARCHAR2,
                p_source_table            IN VARCHAR2,
                p_source_id               IN NUMBER  ,
                p_source_id_old           IN NUMBER  ,
                p_other_flag              IN VARCHAR2,
                p_client_server IN VARCHAR2 DEFAULT NULL,
                --{HYUDETUPT
                p_from_llca_call IN VARCHAR2 DEFAULT 'N',
                p_gt_id          IN NUMBER   DEFAULT NULL
                --}
                ) IS

l_mode          VARCHAR2(1);
l_ae_event_rec  ae_event_rec_type ;
l_ae_doc_rec    ae_doc_rec_type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded1 ARP_ACCT_MAIN.Create_Acct_Entry()+');
   END IF;

   l_ae_doc_rec.document_type            := p_document_type           ;
   l_ae_doc_rec.document_id              := p_document_id             ;
   l_ae_doc_rec.accounting_entity_level  := p_accounting_entity_level ;
   l_ae_doc_rec.source_table             := p_source_table            ;
   l_ae_doc_rec.source_id                := p_source_id               ;
   l_ae_doc_rec.source_id_old            := p_source_id_old           ;
   l_ae_doc_rec.other_flag               := p_other_flag              ;

   Create_Acct_Entry(p_mode          => l_mode,
                     p_ae_doc_rec    => l_ae_doc_rec,
                     p_ae_event_rec  => l_ae_event_rec,
                     p_client_server => p_client_server,
                     p_from_llca_call=> p_from_llca_call,
                     p_gt_id         => p_gt_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded1 ARP_ACCT_MAIN.Create_Acct_Entry()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: Overloaded1 ARP_ACCT_MAIN.Create_Acct_Entry');
     END IF;
     RAISE;

END Create_Acct_Entry;

/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed the document
 |      information, to create accounting entries for Receipts, Credit Memos
 |      or Adjustments. This is used by C code and it was necessary to overload
 |      this to pass the pay_sched_upd_yn, for Bills Receivable reconciliation
 |      on closure, required by autoadjustments, and postbatch, this avoided having
 |      to change other C routines.
 |
 | PARAMETERS
 |      document_type           IN      Document Type
 |      document_id             IN      Document Id
 |      accounting_entity_level IN      Entitity Level accounting
 |      source_table            IN      Source table
 |      source_id               IN      Source Id
 |      source_id_old           IN      Source Id Old
 |      other_flag              IN      Other Flag
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_document_type           IN VARCHAR2,
                p_document_id             IN NUMBER  ,
                p_accounting_entity_level IN VARCHAR2,
                p_source_table            IN VARCHAR2,
                p_source_id               IN NUMBER  ,
                p_source_id_old           IN NUMBER  ,
                p_other_flag              IN VARCHAR2,
                p_pay_sched_upd_yn        IN VARCHAR2,
                p_client_server           IN VARCHAR2,
                --{HYUDETUPT
                p_from_llca_call          IN VARCHAR2 DEFAULT 'N',
                p_gt_id                   IN NUMBER   DEFAULT NULL
                --}
                ) IS

l_mode          VARCHAR2(1);
l_ae_event_rec  ae_event_rec_type ;
l_ae_doc_rec    ae_doc_rec_type;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded1 ARP_ACCT_MAIN.Create_Acct_Entry()+');
   END IF;

   l_ae_doc_rec.document_type            := p_document_type           ;
   l_ae_doc_rec.document_id              := p_document_id             ;
   l_ae_doc_rec.accounting_entity_level  := p_accounting_entity_level ;
   l_ae_doc_rec.source_table             := p_source_table            ;
   l_ae_doc_rec.source_id                := p_source_id               ;
   l_ae_doc_rec.source_id_old            := p_source_id_old           ;
   l_ae_doc_rec.other_flag               := p_other_flag              ;
   l_ae_doc_rec.pay_sched_upd_yn         := p_pay_sched_upd_yn        ;

   Create_Acct_Entry(p_mode           => l_mode,
                     p_ae_doc_rec     => l_ae_doc_rec,
                     p_ae_event_rec   => l_ae_event_rec,
                     p_client_server  => p_client_server,
                     p_from_llca_call => p_from_llca_call,
                     p_gt_id          => p_gt_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded1 ARP_ACCT_MAIN.Create_Acct_Entry()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: Overloaded1 ARP_ACCT_MAIN.Create_Acct_Entry');
     END IF;
     RAISE;

END Create_Acct_Entry;


/*================================================================================*
 | PUBLIC PROCEDURE Insert_Ai_Exceptions                                          |
 |                                                                                |
 | DESCRIPTION                                                                    |
 |      Insert Autoinvoice Exceptions For Accounting Failures                     |
 |      -----------------------------------------------------                     |
 |      This procedure is called from the Autoinvoice Accounting call             |
 |      if any exception occurs during accounting of the commitment               |
 |      adjustments or CM applications in an Autoinvoice Batch.                   |
 |                                                                                |
 | PARAMETERS                                                                     |
 |      p_request_id    IN      Request_id                                        |
 |      p_document_id   IN      Document_id ( Adjustment id or Customer trx id )  |
 |      p_document_type IN      'ADJUSTMENT' or 'CREDIT_MEMO'                     |
 |      p_message_code  IN      Error message code to be inserted                 |
 *================================================================================*/
PROCEDURE Insert_Ai_Exceptions(
		p_request_id    IN NUMBER,
		p_document_id   IN NUMBER,
		p_document_type IN VARCHAR,
		p_message_code  IN VARCHAR
) IS
BEGIN

   	IF PG_DEBUG in ('Y', 'C') THEN
      		arp_standard.debug(   'ARP_ACCT_MAIN.Insert_Ai_Exceptions()+');
   	END IF;

	IF p_document_type = 'ADJUSTMENT' THEN

        	INSERT INTO RA_INTERFACE_ERRORS(
                	INTERFACE_LINE_ID,
                        MESSAGE_TEXT,
                        INVALID_VALUE,
                        ORG_ID )
                SELECT  il.interface_line_id,
                        arp_standard.fnd_message(p_message_code),
                        trx.customer_trx_id,
                        il.org_id
                FROM    RA_INTERFACE_LINES_GT il,
                        AR_ADJUSTMENTS        adj,
                        RA_CUSTOMER_TRX       trx
                WHERE   il.request_id = p_request_id
                AND     nvl(il.interface_status, '~') <> 'P'
                AND     il.customer_trx_id = trx.customer_trx_id
                AND     nvl(adj.subsequent_trx_id, adj.customer_trx_id) = trx.customer_trx_id
                AND     adj.adjustment_id = p_document_id;

	ELSIF p_document_type = 'CREDIT_MEMO' THEN

                INSERT INTO RA_INTERFACE_ERRORS(
                	INTERFACE_LINE_ID,
                        MESSAGE_TEXT,
                        INVALID_VALUE,
                        ORG_ID )
                SELECT  il.interface_line_id,
                        arp_standard.fnd_message(p_message_code),
                        trx.customer_trx_id,
                        il.org_id
                FROM    RA_INTERFACE_LINES_GT il,
                        RA_CUSTOMER_TRX       trx
                WHERE   il.request_id = p_request_id
                AND     nvl(il.interface_status, '~') <> 'P'
                AND     il.customer_trx_id = trx.customer_trx_id
                AND     trx.customer_trx_id = p_document_id;

	END IF;

        IF PG_DEBUG in ('Y', 'C') THEN
                arp_standard.debug(   'ARP_ACCT_MAIN.Insert_Ai_Exceptions()-');
        END IF;

END;


/*========================================================================
 | PUBLIC PROCEDURE Create_Acct_Entry
 |
 | DESCRIPTION
 |      Create accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure to which is passed a request_id
 |      from AUTORECEIPTS for processing the Receivable APPLICATION Rows
 |
 | PARAMETERS
 |      p_request_id    IN      Request_id
 |	p_called_from   IN      Either AUTOREC or AUTOINV
 *=======================================================================*/
PROCEDURE Create_Acct_Entry(
                p_request_id              IN NUMBER,
                p_called_from             IN VARCHAR
                ) IS

l_ae_event_rec  ae_event_rec_type ;
l_ae_doc_rec    ae_doc_rec_type;

CURSOR get_receipt_info(p_request_id IN number) IS
   SELECT cash_receipt_id from ar_cash_receipts
    where request_id = p_request_id;

CURSOR get_app_info(p_cash_receipt_id IN NUMBER) IS
   SELECT receivable_application_id,
          status
     FROM ar_receivable_applications
    where cash_Receipt_id = p_cash_receipt_id;

CURSOR  get_cm_info (p_request_id IN number) IS
   select rec.customer_trx_id customer_trx_id,
          rec.receivable_application_id rec_app_id
   from AR_RECEIVABLE_APPLICATIONS rec,
        RA_CUSTOMER_TRX            trx
   where trx.customer_trx_id = rec.customer_trx_id
     and trx.request_id = p_request_id;

CURSOR get_adj_info (p_request_id IN number) IS
   SELECT adjustment_id, code_combination_id
     FROM ar_adjustments
    WHERE request_id = p_request_id;

old_rec_app_id  ar_receivable_applications.receivable_application_id%TYPE;
--Bug#2750340
l_xla_ev_rec      arp_xla_events.xla_events_type;
l_xla_doc_table   VARCHAR2(20);

  adj_exist boolean := FALSE;
  cm_exist  boolean := FALSE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded2 ARP_ACCT_MAIN.Create_Acct_Entry()+');
   END IF;

   IF (p_called_from = 'AUTOREC' ) THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(  'calling for AUTO RECEIPTS');
      END IF;

      l_ae_doc_rec.document_type            := 'RECEIPT';
      l_ae_doc_rec.accounting_entity_level  := 'ONE';
      l_ae_doc_rec.source_table             := 'RA';

      FOR receipt_info IN get_receipt_info(p_request_id) LOOP
          l_ae_doc_rec.document_id := receipt_info.cash_receipt_id;
          old_rec_app_id := NULL;

          FOR app_info IN get_app_info(receipt_info.cash_receipt_id) LOOP

              l_ae_doc_rec.source_id := app_info.receivable_application_id;

              IF (app_info.status = 'APP') THEN
                 old_rec_app_id := app_info.receivable_application_id;
                 l_ae_doc_rec.source_id_old := NULL;
                 l_ae_doc_rec.other_flag := NULL;

              ELSE
                 /* check to see if this is the final unapp or
                    the paired unapp */

                 IF (old_rec_app_id is not null ) THEN
                    /* we have a pairing.. */
                    l_ae_doc_rec.source_id_old := old_rec_app_id;
                    l_ae_doc_rec.other_flag := 'PAIR';

                    /* reset old rec app id */
                    old_rec_app_id := NULL;
                 ELSE
                    l_ae_doc_rec.source_id_old := NULL;
                    l_ae_doc_rec.other_flag := NULL;
                 END IF;
              END IF;

              /* call Accting engine */
              arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

          END LOOP;
      END LOOP;

/*-- Commented this out based on Ramakant inputs autoreceipt will no longer be called
--   from ARZCAR -- but it will call ar_receipt_api_pub
--   XLA should be uptake in ar_receipt_api_pub
      -- Bug#2750340 {
      l_xla_ev_rec.xla_req_id      := p_request_id;
      l_xla_ev_rec.xla_mode        := 'B';
      l_xla_ev_rec.xla_call        := 'B';

      l_xla_ev_rec.xla_doc_table   := 'CR';
      ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);

      l_xla_ev_rec.xla_doc_table   := 'APP';
      ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
      -- }
*/
  ELSE

-- 1st Adjustment and 2 CM APP

      /* create adjustment entries */
      FOR adj_info in get_adj_info(p_request_id) LOOP

          adj_exist := TRUE; -- 4457617: call sla

	  SAVEPOINT Adj_Accounting_Call_Point;

	BEGIN
          arp_acct_main.Create_Acct_Entry('ADJUSTMENT',
                                          adj_info.adjustment_id,
                                          'ONE',
                                          'ADJ',
                                          adj_info.adjustment_id,
                                          adj_info.code_combination_id,
                                          'COMMITMENT');
	EXCEPTION
		WHEN ARP_ALLOCATION_PKG.flex_subs_ccid_error THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO Adj_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					adj_info.adjustment_id,
					'ADJUSTMENT',
					'AR_RAXTRX-1822');
			ELSE
				RAISE;
			END IF;
		WHEN ARP_ALLOCATION_PKG.invalid_ccid_error THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO Adj_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					adj_info.adjustment_id,
					'ADJUSTMENT',
					'AR_RAXTRX-1823');
			ELSE
				RAISE;
			END IF;
		WHEN ARP_ALLOCATION_PKG.rounding_error THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO Adj_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					adj_info.adjustment_id,
					'ADJUSTMENT',
					'AR_RAXTRX-1824');

			ELSE
				RAISE;
			END IF;
		WHEN ARP_ALLOCATION_PKG.invalid_allocation_base THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO Adj_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					adj_info.adjustment_id,
					'ADJUSTMENT',
					'AR_RAXTRX-1825');

			ELSE
				RAISE;
			END IF;
		WHEN NO_DATA_FOUND THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO Adj_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					adj_info.adjustment_id,
					'ADJUSTMENT',
					'AR_RAXTRX-1826');

			ELSE
				RAISE;
			END IF;
		WHEN OTHERS THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO Adj_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					adj_info.adjustment_id,
					'ADJUSTMENT',
					'AR_RAXTRX-1827');

			ELSE
				RAISE;
			END IF;
	END;
      END LOOP;


      /* create credit memo entries */
      FOR cm_info IN get_cm_info(p_request_id) LOOP

          cm_exist := TRUE; -- 4457617: call sla

          SAVEPOINT RA_Accounting_Call_Point;

	BEGIN
          arp_acct_main.Create_Acct_Entry('CREDIT_MEMO',
                                          cm_info.customer_trx_id,
                                          'ONE',
                                          'RA',
                                          cm_info.rec_app_id,
                                          NULL,
                                          NULL);
        EXCEPTION
		WHEN ARP_ALLOCATION_PKG.flex_subs_ccid_error THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO RA_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					cm_info.customer_trx_id,
					'CREDIT_MEMO',
					'AR_RAXTRX-1822');
			ELSE
				RAISE;
			END IF;
		WHEN ARP_ALLOCATION_PKG.invalid_ccid_error THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO RA_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					cm_info.customer_trx_id,
					'CREDIT_MEMO',
					'AR_RAXTRX-1823');
			ELSE
				RAISE;
			END IF;
		WHEN ARP_ALLOCATION_PKG.rounding_error THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO RA_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					cm_info.customer_trx_id,
					'CREDIT_MEMO',
					'AR_RAXTRX-1824');

			ELSE
				RAISE;
			END IF;
		WHEN ARP_ALLOCATION_PKG.invalid_allocation_base THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO RA_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					cm_info.customer_trx_id,
					'CREDIT_MEMO',
					'AR_RAXTRX-1825');

			ELSE
				RAISE;
			END IF;
		WHEN NO_DATA_FOUND THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO RA_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					cm_info.customer_trx_id,
					'CREDIT_MEMO',
					'AR_RAXTRX-1826');

			ELSE
				RAISE;
			END IF;
		WHEN OTHERS THEN
			IF p_called_from = 'AUTOINV' THEN
				ROLLBACK TO RA_Accounting_Call_Point;
				Insert_Ai_Exceptions(
					p_request_id,
					cm_info.customer_trx_id,
					'CREDIT_MEMO',
					'AR_RAXTRX-1827');

			ELSE
				RAISE;
			END IF;
        END;
      END LOOP;

      -- Bug#2750340
      l_xla_ev_rec.xla_req_id      := p_request_id;
      l_xla_ev_rec.xla_mode        := 'B';
      l_xla_ev_rec.xla_call        := 'B';

      /* 4457617: only call sla if CMAPP or ADJ exists.  Was raising a
         generic error in autoinvoice (raacae) */

/* Auto inv will use wrapper to control XLA event creation
--
      IF adj_exist
      THEN
         l_xla_ev_rec.xla_doc_table   := 'ADJ';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
      END IF;

      IF cm_exist
      THEN
         l_xla_ev_rec.xla_doc_table   := 'CMAPP';
         ARP_XLA_EVENTS.create_events(p_xla_ev_rec => l_xla_ev_rec);
      END IF;
--
*/
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded2 ARP_ACCT_MAIN.Create_Acct_Entry()-');
   END IF;

END Create_Acct_Entry;


/*========================================================================
 | PUBLIC PROCEDURE Delete_Acct_Entry
 |
 | DESCRIPTION
 |      Delete accounting entries for a document
 |      ----------------------------------------
 |      This procedure is the standard delete routine which calls packages
 |      for Receipts, Credit Memos and Adjustments to delete the accounting
 |      associated with the document for a source id
 |
 | PARAMETERS
 |      p_mode          IN      Document or Accounting Event mode
 |      p_ae_doc_rec    IN      Document Record
 |      p_ae_event_rec  IN      Event Record
 *=======================================================================*/
PROCEDURE Delete_Acct_Entry(
                p_mode          IN     VARCHAR2,    -- DOCUMENT or ACCT_EVENT
                p_ae_doc_rec    IN OUT NOCOPY ae_doc_rec_type,
                p_ae_event_rec  IN     ae_event_rec_type
                ) IS
l_ae_deleted                  BOOLEAN := FALSE;
l_paired_id                   ar_receivable_applications.receivable_application_id%TYPE;
l_accounting_method           ar_system_parameters.accounting_method%TYPE;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'ARP_ACCT_MAIN.Delete_Acct_Entry()+');
   END IF;

   Init_Curr_Details(p_accounting_method => l_accounting_method);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'ARP_ACCT_MAIN - Accounting Method ' || l_accounting_method);
   END IF;

     --begin 5655154, commented the accounting_method = 'ACCRUAL' check
--   IF l_accounting_method = 'ACCRUAL' THEN
     --end 5655154
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug(   'Delete_Acct_Entry - Processing Accounting Method ' || l_accounting_method);
      END IF;
     /*------------------------------------------------------+
      | Delete Accounting for Document                       |
      +------------------------------------------------------*/
      IF ( p_ae_doc_rec.document_type = 'RECEIPT' ) OR
              (p_ae_doc_rec.document_type = 'CREDIT_MEMO') THEN

            ARP_RECEIPTS_MAIN.Delete_Acct( p_mode,
                                           p_ae_doc_rec,
                                           p_ae_event_rec,
                                           l_ae_deleted
                                          );

      ELSIF p_ae_doc_rec.document_type = 'ADJUSTMENT' OR
               p_ae_doc_rec.document_type = 'FINANCE_CHARGES' THEN

            ARP_ADJUSTMENTS_MAIN.Delete_Acct( p_mode,
                                              p_ae_doc_rec,
                                              p_ae_event_rec,
                                              l_ae_deleted
                                             );

      ELSIF p_ae_doc_rec.document_type = 'BILLS_RECEIVABLE' THEN

            ARP_BILLS_RECEIVABLE_MAIN.Delete_Acct( p_mode,
                                                   p_ae_doc_rec,
                                                   p_ae_event_rec,
                                                   l_ae_deleted
                                                  );

      END IF;           -- Document type
     --begin 5655154, commented the endif condition
--   END IF; --end if Accounting method is accrual
     --end 5655154

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'ARP_ACCT_MAIN.Delete_Acct_Entry()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: ARP_ACCT_MAIN.Delete_Acct_Entry');
     END IF;
     RAISE;

END Delete_Acct_Entry;

/*========================================================================
 | PUBLIC PROCEDURE Delete_Acct_Entry
 |
 | DESCRIPTION
 |      Delete accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure which calls packages associated
 |      with a Receipt, Credit Memo or Adjustment document to delete the
 |      accounting for a source id.
 |
 | PARAMETERS
 |      p_ae_doc_rec    IN      Document Record
 *=======================================================================*/
PROCEDURE Delete_Acct_Entry(
                p_ae_doc_rec    IN OUT NOCOPY ae_doc_rec_type
                ) IS

l_mode          VARCHAR2(1);
l_ae_event_rec  ae_event_rec_type ;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded ARP_ACCT_MAIN.Delete_Acct_Entry()+');
   END IF;

   Delete_Acct_Entry(l_mode, p_ae_doc_rec, l_ae_event_rec);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded ARP_ACCT_MAIN.Delete_Acct_Entry()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: Overloaded ARP_ACCT_MAIN.Delete_Acct_Entry');
     END IF;
     RAISE;

END Delete_Acct_Entry;

/*========================================================================
 | PUBLIC PROCEDURE Delete_Acct_Entry
 |
 | DESCRIPTION
 |      Delete accounting entries for a document
 |      ----------------------------------------
 |      This is an overloaded procedure which calls packages associated
 |      with a Receipt, Credit Memo or Adjustment document to delete the
 |      accounting for a source id. Required for C code delete calls.
 |
 | PARAMETERS
 |      p_ae_doc_rec    IN      Document Record
 *=======================================================================*/
PROCEDURE Delete_Acct_Entry(
                p_document_type           IN     VARCHAR2,
                p_document_id             IN     NUMBER  ,
                p_accounting_entity_level IN     VARCHAR2,
                p_source_table            IN     VARCHAR2,
                p_source_id               IN     NUMBER  ,
                p_source_id_old           IN OUT NOCOPY NUMBER  ,
                p_other_flag              IN     VARCHAR2
                ) IS

l_mode          VARCHAR2(1);
l_ae_event_rec  ae_event_rec_type;
l_ae_doc_rec    ae_doc_rec_type;

BEGIN
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded ARP_ACCT_MAIN.Delete_Acct_Entry()+');
   END IF;

   l_ae_doc_rec.document_type            := p_document_type           ;
   l_ae_doc_rec.document_id              := p_document_id             ;
   l_ae_doc_rec.accounting_entity_level  := p_accounting_entity_level ;
   l_ae_doc_rec.source_table             := p_source_table            ;
   l_ae_doc_rec.source_id                := p_source_id               ;
   l_ae_doc_rec.source_id_old            := p_source_id_old           ;
   l_ae_doc_rec.other_flag               := p_other_flag              ;

   Delete_Acct_Entry(l_mode, l_ae_doc_rec, l_ae_event_rec);

   p_source_id_old := l_ae_doc_rec.source_id_old;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(   'Overloaded ARP_ACCT_MAIN.Delete_Acct_Entry()-');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug(  'EXCEPTION: Overloaded ARP_ACCT_MAIN.Delete_Acct_Entry');
     END IF;
     RAISE;

END Delete_Acct_Entry;

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
 *=======================================================================*/
PROCEDURE Insert_Ae_Lines(p_ae_line_tbl IN ae_line_tbl_type) IS

  l_ae_line_rec 	ar_distributions%ROWTYPE;
  l_ae_line_rec_empty   ar_distributions%ROWTYPE;
  l_dummy               ar_distributions.line_id%TYPE;

  i                     BINARY_INTEGER := 1;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ACCT_MAIN.Insert_Ae_Lines()+');
  END IF;


  -- Insert AE Lines
  FOR i IN p_ae_line_tbl.FIRST .. p_ae_line_tbl.LAST LOOP

    -- Initialize
    l_ae_line_rec := l_ae_line_rec_empty;

    -- Assign AE Line elements

    l_ae_line_rec.source_type              :=  p_ae_line_tbl(i).ae_line_type;
    l_ae_line_rec.source_type_secondary    :=  p_ae_line_tbl(i).ae_line_type_secondary;
    l_ae_line_rec.source_id                :=  p_ae_line_tbl(i).source_id;
    l_ae_line_rec.source_table             :=  p_ae_line_tbl(i).source_table;
    l_ae_line_rec.code_combination_id      :=  p_ae_line_tbl(i).account;
    l_ae_line_rec.amount_dr                :=  p_ae_line_tbl(i).entered_dr;
    l_ae_line_rec.amount_cr                :=  p_ae_line_tbl(i).entered_cr;
    l_ae_line_rec.acctd_amount_dr          :=  p_ae_line_tbl(i).accounted_dr;
    l_ae_line_rec.acctd_amount_cr          :=  p_ae_line_tbl(i).accounted_cr;
    l_ae_line_rec.source_id_secondary      :=  p_ae_line_tbl(i).source_id_secondary;
    l_ae_line_rec.source_table_secondary   :=  p_ae_line_tbl(i).source_table_secondary;
    l_ae_line_rec.currency_code            :=  p_ae_line_tbl(i).currency_code;
    l_ae_line_rec.currency_conversion_rate :=  p_ae_line_tbl(i).currency_conversion_rate;
    l_ae_line_rec.currency_conversion_type :=  p_ae_line_tbl(i).currency_conversion_type;
    l_ae_line_rec.currency_conversion_date :=  p_ae_line_tbl(i).currency_conversion_date;
    l_ae_line_rec.third_party_id           :=  p_ae_line_tbl(i).third_party_id;
    l_ae_line_rec.third_party_sub_id       :=  p_ae_line_tbl(i).third_party_sub_id;
    l_ae_line_rec.tax_group_code_id        :=  p_ae_line_tbl(i).tax_group_code_id;
    l_ae_line_rec.tax_code_id              :=  p_ae_line_tbl(i).tax_code_id;
    l_ae_line_rec.location_segment_id      :=  p_ae_line_tbl(i).location_segment_id;
    l_ae_line_rec.taxable_entered_dr       :=  p_ae_line_tbl(i).taxable_entered_dr;
    l_ae_line_rec.taxable_entered_cr       :=  p_ae_line_tbl(i).taxable_entered_cr;
    l_ae_line_rec.taxable_accounted_dr     :=  p_ae_line_tbl(i).taxable_accounted_dr;
    l_ae_line_rec.taxable_accounted_cr     :=  p_ae_line_tbl(i).taxable_accounted_cr;
    l_ae_line_rec.tax_link_id              :=  p_ae_line_tbl(i).tax_link_id;
    l_ae_line_rec.reversed_source_id       :=  p_ae_line_tbl(i).reversed_source_id;
    --{2979254
    l_ae_line_rec.ref_customer_trx_line_id :=  p_ae_line_tbl(i).ref_customer_trx_line_id;
    l_ae_line_rec.ref_prev_cust_trx_line_id :=  p_ae_line_tbl(i).ref_prev_cust_trx_line_id;
    l_ae_line_rec.ref_cust_trx_line_gl_dist_id :=  p_ae_line_tbl(i).ref_cust_trx_line_gl_dist_id;
    l_ae_line_rec.ref_line_id              :=  p_ae_line_tbl(i).ref_line_id;
    l_ae_line_rec.from_amount_dr           :=  p_ae_line_tbl(i).from_amount_dr;
    l_ae_line_rec.from_amount_cr           :=  p_ae_line_tbl(i).from_amount_cr;
    l_ae_line_rec.from_acctd_amount_dr     :=  p_ae_line_tbl(i).from_acctd_amount_dr;
    l_ae_line_rec.from_acctd_amount_cr     :=  p_ae_line_tbl(i).from_acctd_amount_cr;
    l_ae_line_rec.ref_account_class                :=  p_ae_line_tbl(i).ref_account_class;
    l_ae_line_rec.activity_bucket                   :=  p_ae_line_tbl(i).activity_bucket;
    l_ae_line_rec.ref_mf_dist_flag         :=  p_ae_line_tbl(i).ref_mf_dist_flag;
    l_ae_line_rec.ref_dist_ccid            :=  p_ae_line_tbl(i).ref_dist_ccid;
    --}

    Dump_Dist_Amts(l_ae_line_rec);


IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug(  'sob type = ' || ARP_ACCT_MAIN.ae_sys_rec.sob_type);
END IF;

    IF (NVL(ARP_ACCT_MAIN.ae_sys_rec.sob_type,'P') = 'P') THEN
       arp_distributions_pkg.insert_p(l_ae_line_rec, l_dummy);
    END IF;
  END LOOP;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'ARP_ACCT_MAIN.Insert_Ae_Lines()-');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ACCT_MAIN.Insert_Ae_Lines');
     END IF;
     RAISE;

END Insert_Ae_Lines;

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
       arp_standard.debug('ARP_ACCT_MAIN.Dump_Dist_Amts()+');
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug(  'set_of_books_id          = ' || ARP_ACCT_MAIN.ae_sys_rec.set_of_books_id);
       arp_standard.debug(  'source_type              = ' || p_ae_line_rec.source_type);
       arp_standard.debug(  'source_type_secondary    = ' || p_ae_line_rec.source_type_secondary);
       arp_standard.debug(  'source_id                = ' || p_ae_line_rec.source_id);
       arp_standard.debug(  'source_table             = ' || p_ae_line_rec.source_table);
       arp_standard.debug(  'code_combination_id      = ' || p_ae_line_rec.code_combination_id);
       arp_standard.debug(  'amount_dr                = ' || p_ae_line_rec.amount_dr);
       arp_standard.debug(  'amount_cr                = ' || p_ae_line_rec.amount_cr);
       arp_standard.debug(  'acctd_amount_dr          = ' || p_ae_line_rec.acctd_amount_dr);
       arp_standard.debug(  'acctd_amount_cr          = ' || p_ae_line_rec.acctd_amount_cr);
       arp_standard.debug(  'source_id_secondary      = ' || p_ae_line_rec.source_id_secondary);
       arp_standard.debug(  'source_table_secondary   = ' || p_ae_line_rec.source_table_secondary);
       arp_standard.debug(  'source_table_secondary   = ' || p_ae_line_rec.source_table_secondary);
       arp_standard.debug(  'currency_code            = ' || p_ae_line_rec.currency_code);
       arp_standard.debug(  'currency_conversion_rate = ' || p_ae_line_rec.currency_conversion_rate);
       arp_standard.debug(  'currency_conversion_type = ' || p_ae_line_rec.currency_conversion_type);
       arp_standard.debug(  'currency_conversion_date = ' || p_ae_line_rec.currency_conversion_date);
       arp_standard.debug(  'third_party_id           = ' || p_ae_line_rec.third_party_id);
       arp_standard.debug(  'third_party_sub_id       = ' || p_ae_line_rec.third_party_sub_id);
       arp_standard.debug(  'tax_group_code_id        = ' || p_ae_line_rec.tax_group_code_id);
       arp_standard.debug(  'tax_code_id              = ' || p_ae_line_rec.tax_code_id);
       arp_standard.debug(  'location_segment_id      = ' || p_ae_line_rec.location_segment_id);
       arp_standard.debug(  'taxable_entered_dr       = ' || p_ae_line_rec.taxable_entered_dr);
       arp_standard.debug(  'taxable_entered_cr       = ' || p_ae_line_rec.taxable_entered_cr);
       arp_standard.debug(  'taxable_accounted_dr     = ' || p_ae_line_rec.taxable_accounted_dr);
       arp_standard.debug(  'taxable_accounted_cr     = ' || p_ae_line_rec.taxable_accounted_cr);
       arp_standard.debug(  'tax_link_id              = ' || p_ae_line_rec.tax_link_id);
       arp_standard.debug(  'reversed_source_id       = ' || p_ae_line_rec.reversed_source_id);
    --{2979254
       arp_standard.debug(  'ref_customer_trx_line_id = ' || p_ae_line_rec.ref_customer_trx_line_id);
       arp_standard.debug(  'ref_prev_cust_trx_line_id = ' || p_ae_line_rec.ref_prev_cust_trx_line_id);
       arp_standard.debug(  'ref_cust_trx_line_gl_dist_id = '
                                                       || p_ae_line_rec.ref_cust_trx_line_gl_dist_id);
       arp_standard.debug(  'ref_line_id              = ' || p_ae_line_rec.ref_line_id);
       arp_standard.debug(  'from_amount_dr           = ' || p_ae_line_rec.from_amount_dr);
       arp_standard.debug(  'from_amount_cr           = ' || p_ae_line_rec.from_amount_cr);
       arp_standard.debug(  'from_acctd_amount_dr     = ' || p_ae_line_rec.from_acctd_amount_dr);
       arp_standard.debug(  'from_acctd_amount_cr     = ' || p_ae_line_rec.from_acctd_amount_cr);
       arp_standard.debug(  'ref_account_class                = ' || p_ae_line_rec.ref_account_class);
       arp_standard.debug(  'activity_bucket                   = ' || p_ae_line_rec.activity_bucket);
       arp_standard.debug(  'ref_dist_ccid            = ' || p_ae_line_rec.ref_dist_ccid);
    --}

       arp_standard.debug('ARP_ACCT_MAIN.Dump_Dist_Amts()-');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('EXCEPTION: ARP_ACCT_MAIN.Dump_Dist_Amts');
     END IF;
     RAISE;

END Dump_Dist_Amts;

/*========================================================================
 | PRIVATE PROCEDURE Init_Curr_Details
 |
 | DESCRIPTION
 |      Retrieves Currency, precision and gain loss account details
 |      -----------------------------------------------------------
 |
 | PARAMETERS
 |      NONE
 *=======================================================================*/
PROCEDURE Init_Curr_Details(p_accounting_method IN OUT NOCOPY ar_system_parameters.accounting_method%TYPE) IS

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_ACCT_MAIN.Init_Curr_Details(+)');
  END IF;

  SELECT sob.set_of_books_id,
         sob.chart_of_accounts_id,
         sob.currency_code,
         c.precision,
         c.minimum_accountable_unit,
         sysp.code_combination_id_gain,
         sysp.code_combination_id_loss,
         sysp.code_combination_id_round,
         sysp.accounting_method
  INTO   ae_sys_rec.set_of_books_id,
         ae_sys_rec.coa_id,
         ae_sys_rec.base_currency,
         ae_sys_rec.base_precision,
         ae_sys_rec.base_min_acc_unit,
         ae_sys_rec.gain_cc_id,
         ae_sys_rec.loss_cc_id,
         ae_sys_rec.round_cc_id,
         p_accounting_method
  FROM   ar_system_parameters sysp,
         gl_sets_of_books sob,
         fnd_currencies c
  WHERE  sob.set_of_books_id = sysp.set_of_books_id --would be the row returned from multi org view
  AND    sob.currency_code   = c.currency_code;

  --{BUG4301323: The sob_type needs to be defaulted to 'P' Primary
  ae_sys_rec.sob_type := 'P';
  --}

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('ARP_ACCT_MAIN.Init_Curr_Details(-)');
  END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('ARP_ACCT_MAIN.Init_Curr_Details - NO_DATA_FOUND' );
         END IF;
         RAISE;

    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: ARP_ACCT_MAIN.constructor(-)');
           arp_standard.debug(SQLERRM);
        END IF;
        RAISE;

END Init_Curr_Details;

END ARP_ACCT_MAIN;

/
