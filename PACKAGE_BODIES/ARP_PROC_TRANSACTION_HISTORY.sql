--------------------------------------------------------
--  DDL for Package Body ARP_PROC_TRANSACTION_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROC_TRANSACTION_HISTORY" AS
/* $Header: ARTETRHB.pls 120.10.12010000.3 2008/08/03 08:23:09 vavenugo ship $ */

/*--------------------------------------------------------+
 |  Dummy constants for use in update and lock operations |
 +--------------------------------------------------------*/

  AR_TEXT_DUMMY   CONSTANT VARCHAR2(10) := '~~!@#$*&^';
  AR_FLAG_DUMMY   CONSTANT VARCHAR2(10) := '~';
  AR_NUMBER_DUMMY CONSTANT NUMBER(15)   := -999999999999999;
  AR_DATE_DUMMY   CONSTANT DATE         := to_date(1, 'J');

SUBTYPE ae_doc_rec_type   IS arp_acct_main.ae_doc_rec_type;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

FUNCTION find_prev_accounted_id(p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE) RETURN NUMBER;

PROCEDURE insert_BR_ps(
        p_trh_rec       IN  ar_transaction_history%ROWTYPE,
        p_ps_id         OUT NOCOPY ar_payment_schedules.payment_schedule_id%TYPE);

PROCEDURE calculate_BR_amounts(
        p_customer_trx_id       IN  ra_customer_trx.customer_trx_id%TYPE,
        p_amount                OUT NOCOPY NUMBER,
        p_acctd_amount          OUT NOCOPY NUMBER,
        p_line_amount           OUT NOCOPY NUMBER,
        p_tax_amount            OUT NOCOPY NUMBER,
        p_freight_amount        OUT NOCOPY NUMBER,
        p_charges_amount        OUT NOCOPY NUMBER);

FUNCTION previous_history_exists(p_customer_trx_id ra_customer_trx.customer_trx_id%TYPE) RETURN BOOLEAN;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_transaction_history                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts a record into ar_transaction_history for bills receivable      |
 |    transaction. If this is not the first history record the previous      |
 |    record flags are updated. If this is the completion record             |
 |    payment schedule is created for the BR. MRC information is created     |
 |    if MRC functionality is enabled                                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:      p_trh_rec                                           |
 |              OUT:     p_transaction_history_id                            |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE insert_transaction_history(p_trh_rec                IN  OUT NOCOPY ar_transaction_history%rowtype,
                                     p_transaction_history_id OUT NOCOPY     ar_transaction_history.transaction_history_id%type,
                                     p_move_deferred_tax      IN      VARCHAR2 DEFAULT 'N') IS

  l_ae_doc_rec         ae_doc_rec_type;
  l_old_trh_rec        ar_transaction_history%ROWTYPE;
  l_old_acctd_trh_rec  ar_transaction_history%ROWTYPE;
  l_prev_acctd_id      ar_transaction_history.transaction_history_id%TYPE;
  l_ps_id              ar_payment_schedules.payment_schedule_id%TYPE;
  --Bug# 2750340
  l_xla_ev_rec         ARP_XLA_EVENTS.XLA_EVENTS_TYPE;

  /*Bug 7299779 -- vavenugo */
  /* Variables declared for updating events */
  l_event_source_info   xla_events_pub_pkg.t_event_source_info;
  l_event_id            NUMBER;
  l_security            xla_events_pub_pkg.t_security;
  l_event_count         NUMBER;
  l_trh_count           NUMBER;

  cursor update_event (p_trx_id ra_customer_trx.customer_trx_id%TYPE)
  is
  select distinct trh.event_id
  from ar_transaction_history_all trh
  where trh.customer_trx_id = p_trx_id and
  trh.event_id is not null  and    /* This condition is to make sure that null events are not selected for update. Null events get inserted in TRH when fields like maturity date are updated */
  not exists
  ( select 'Y'
    from ar_transaction_history_all trh_sub
    where trh_sub.customer_trx_id = p_trx_id and
    trh_sub.postable_flag ='Y' and
    trh_sub.event_id = trh.event_id
  );



BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug(  'arp_proc_transaction_history.insert_transaction_history()+');
  END IF;

 /*------------------------------------------------+
  |  All the validation and defaulting is done in  |
  |  the BR API, so none is done in the entity     |
  |  handler.                                      |
  +------------------------------------------------*/

 /*--------------------------------------------------+
  | Lock rows in other tables that reference this    |
  | customer_trx_id                                  |
  +--------------------------------------------------*/
  arp_process_br_header.lock_transaction(p_trh_rec.customer_trx_id);

 /*----------------------------------------+
  | fetch previous record if one exists    |
  +----------------------------------------*/
  IF previous_history_exists(p_trh_rec.customer_trx_id) THEN

    l_old_trh_rec.customer_trx_id := p_trh_rec.customer_trx_id;
    ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id(l_old_trh_rec);

  END IF;

 /*--------------------------------------------------+
  | If this is not the first history record, update  |
  | the previous records current flags               |
  +--------------------------------------------------*/

  IF l_old_trh_rec.transaction_history_id IS NOT NULL THEN

   /*-----------------------------------------------------------------+
    | set the prv_trx_history_id to point to the previous record      |
    +-----------------------------------------------------------------*/
    p_trh_rec.prv_trx_history_id := l_old_trh_rec.transaction_history_id;

   /*--------------------------------------------------+
    | If the new record created is postable update the |
    | current_accounted_flag of previous record to 'N' |
    +--------------------------------------------------*/

    IF NVL(p_trh_rec.postable_flag,'N') = 'Y' THEN

     /*--------------------------------------------------------------------+
      | Check whether the previous record was the current accounted record |
      +--------------------------------------------------------------------*/

      IF NVL(l_old_trh_rec.current_accounted_flag,'N') = 'N' THEN
       /*--------------------------------------------------------------------------+
        | Previous record was not the accounted record, so find the correct record |
        +--------------------------------------------------------------------------*/
        l_prev_acctd_id := find_prev_accounted_id(l_old_trh_rec.customer_trx_id);

       /*------------------------------------------+
        | Update previous accounted history record |
        | if one exists. If one does not exist this|
        | we are inserting the first accounted row |
        +------------------------------------------*/
        IF l_prev_acctd_id is not null THEN

         /*-----------------------------------------+
          | Initialize the record with dummy values |
          +-----------------------------------------*/
          ARP_TRANSACTION_HISTORY_PKG.set_to_dummy(l_old_acctd_trh_rec);

         /*----------------------------+
          | Set the flag to be updated |
          +----------------------------*/
          l_old_acctd_trh_rec.current_accounted_flag := 'N';

         /*--------------------------------------+
          | Update the previous accounted record |
          +--------------------------------------*/
          ARP_PROC_TRANSACTION_HISTORY.update_transaction_history(l_old_acctd_trh_rec,
                                                                  l_prev_acctd_id);

        ELSE

         /*-----------------------------------------+
          | This is the first posted record         |
          +-----------------------------------------*/
          p_trh_rec.first_posted_record_flag := 'Y';

        END IF;
      ELSE
       /*------------------------------------------------------------------------+
        | Previous record was the accounted record, so set the flag to update it |
        +------------------------------------------------------------------------*/
        l_old_trh_rec.current_accounted_flag := 'N';

      END IF;

    END IF;

   /*------------------------------------------------------------+
    | Update the current record indicator of the previous record |
    +------------------------------------------------------------*/
    l_old_trh_rec.current_record_flag := 'N';

   /*-----------------------------+
    |  Update the previous record |
    +-----------------------------*/
    ARP_PROC_TRANSACTION_HISTORY.update_transaction_history(l_old_trh_rec,
                                                            l_old_trh_rec.transaction_history_id);

  END IF;

 /*---------------------------------------------------------------+
  | Payment schedule needs to be created if the BR was completed  |
  +---------------------------------------------------------------*/
  IF p_trh_rec.status = 'PENDING_REMITTANCE' AND p_trh_rec.event in ('COMPLETED','ACCEPTED') THEN

   /*--------------------------+
    |  Create payment schedule |
    +--------------------------*/
    arp_proc_transaction_history.insert_BR_ps(p_trh_rec,l_ps_id);

  END IF;

 /*----------------------+
  |  call table-handler  |
  +----------------------*/

  arp_transaction_history_pkg.insert_p(p_trh_rec, p_transaction_history_id);



  /*--------------------------------------------+
   |  Call MRC logic to create MRC rows         |
   |  This needs to be done before accounting   |
   |  since the MRC trigger on ar_distributions |
   |  table expects for the MRC row to exists   |
   +--------------------------------------------*/

--{BUG#4301323
--  ARP_PROC_TRANSACTION_HISTORY.insert_mrc_transaction_hist(p_trh_rec,
--                                                           p_transaction_history_id);
--}

--Bug# 2750340
  /*--------------------------------------------+
   |  Need to call ARP XLA to create or update  |
   |  the life cycle of a TH                    |
   |  This routine is called by all the TH WB   |
   |  And it is a central place for TH lifecycle|
   +--------------------------------------------*/
   arp_standard.debug('p_transaction_history_id :'||p_transaction_history_id);

   l_xla_ev_rec.xla_from_doc_id := p_transaction_history_id;
   l_xla_ev_rec.xla_to_doc_id   := p_transaction_history_id;
   l_xla_ev_rec.xla_doc_table   := 'TRH';
   l_xla_ev_rec.xla_mode        := 'O';
   l_xla_ev_rec.xla_call        := 'B';

   -- Now call the stored program
   arp_xla_events.create_events(l_xla_ev_rec);




 /*----------------------------------------------------------------------+
  |  call accounting engine if needed. Accounting engine creates the     |
  |  accounting in ar_distributions table, it also calls auto accounting |
  |  and deferred tax if needed                                          |
  +----------------------------------------------------------------------*/

  IF NVL(p_trh_rec.postable_flag,'N') = 'Y' THEN

    l_ae_doc_rec.document_type           := 'BILLS_RECEIVABLE';
    l_ae_doc_rec.document_id             := p_transaction_history_id;
    l_ae_doc_rec.accounting_entity_level := 'ONE';
    l_ae_doc_rec.source_table            := 'TH';
    l_ae_doc_rec.source_id               := p_transaction_history_id;
    l_ae_doc_rec.event                   := p_trh_rec.event;
    l_ae_doc_rec.deferred_tax            := p_move_deferred_tax;
    arp_acct_main.Create_Acct_Entry(l_ae_doc_rec);

  ELSIF (p_trh_rec.status = 'INCOMPLETE' AND l_old_trh_rec.status = 'PENDING_REMITTANCE') THEN

   /*----------------------------------------------------------+
    | If the Bills was incompleted we need to delete           |
    | the accounting for previous PENDING_REMITTANCE           |
    | record since This scenario is only possible if           |
    | the BR does not have any activities or reclassifications |
    | on it. The validation is done in the calling             |
    | functionality                                            |
    +----------------------------------------------------------*/

   /*----------------------------------------------------------+
    | Since the previous history is not necessarily postable   |
    | accounting needs to be reversed on the previout accounted|
    | transaction history record                               |
    +----------------------------------------------------------*/
    l_prev_acctd_id := find_prev_accounted_id(l_old_trh_rec.customer_trx_id);

    l_ae_doc_rec.document_type           := 'BILLS_RECEIVABLE';
    l_ae_doc_rec.document_id             := l_prev_acctd_id;
    l_ae_doc_rec.accounting_entity_level := 'ONE';
    l_ae_doc_rec.source_table            := 'TH';
    l_ae_doc_rec.source_id               := l_prev_acctd_id;
    arp_acct_main.Delete_Acct_Entry(l_ae_doc_rec);


   /*----------------------------------------------------------+
    | If the Bills was incompleted we need to update also the  |
    | the other flags from the previous PENDING_REMITTANCE     |
    | record since the accounting engine will delete the       |
    | accounting rows for it. This scenario is only possible if|
    | the BR does not have any activities or reclassifications |
    | on it. The validation is done in the calling             |
    | functionality                                            |
    +----------------------------------------------------------*/

    /*-----------------------------------------+
     | Initialize the record with dummy values |
     +-----------------------------------------*/
     ARP_TRANSACTION_HISTORY_PKG.set_to_dummy(l_old_acctd_trh_rec);

    /*----------------------------+
     | Set the flag to be updated |
     +----------------------------*/
     l_old_acctd_trh_rec.current_accounted_flag 	:= 'N';
     l_old_acctd_trh_rec.postable_flag            	:= 'N';
     l_old_acctd_trh_rec.first_posted_record_flag 	:= 'N';

    /*--------------------------------------+
     | Update the previous accounted record |
     +--------------------------------------*/
     ARP_PROC_TRANSACTION_HISTORY.update_transaction_history(l_old_acctd_trh_rec,
                	                                     l_prev_acctd_id);


  END IF;



/* Bug 7299779 (refer bug for description of fix) - vavenugo */

/* Identify and update the events only when the status changes from INCOMPLETE TO PENDING_REMITTANCE */
IF (p_trh_rec.status = 'PENDING_REMITTANCE' AND l_old_trh_rec.status = 'INCOMPLETE') THEN

   select count(distinct trh.event_id)
   into l_event_count
   from ar_transaction_history_all trh
   where trh.customer_trx_id = p_trh_rec.customer_trx_id and
   not exists
       ( select 'Y'
         from ar_transaction_history_all trh_sub
         where trh_sub.customer_trx_id = p_trh_rec.customer_trx_id and
         trh_sub.postable_flag ='Y' and
         trh_sub.event_id = trh.event_id
       );

 If l_event_count > 0 then

  /* Values selected to populate the IN parameters of the xla procedure */
  select xet.legal_entity_id legal_entity_id,
         trx.SET_OF_BOOKS_ID set_of_books_id,
         xet.entity_code     entity_code
  into
        l_event_source_info.legal_entity_id,
        l_event_source_info.ledger_id,
        l_event_source_info.entity_type_code
  from
        ra_customer_trx trx ,
	xla_transaction_entities_upg  xet
  where       trx.customer_trx_id       = p_trh_rec.customer_trx_id
        and   trx.customer_trx_id       = xet.source_id_int_1
        and   xet.entity_code           ='BILLS_RECEIVABLE'
        AND   xet.application_id        = 222
        AND   trx.SET_OF_BOOKS_ID       = xet.LEDGER_ID;

   l_event_source_info.application_id    := 222;
   l_event_source_info.source_id_int_1   := p_trh_rec.customer_trx_id;
   l_security.security_id_int_1          := p_trh_rec.org_id;

   /* Open the cursor containing the events to be updated and call the xla procedure for every event */

   open update_event (p_trh_rec.customer_trx_id);
   loop
   fetch update_event into l_event_id;
   exit when update_event%NOTFOUND;
   xla_events_pub_pkg.update_event
   (   p_event_source_info    => l_event_source_info,
       p_event_id             => l_event_id,
       p_event_status_code    => 'N',
       p_valuation_method     => null,
       p_security_context     => l_security  );
   end loop;
 end if;

END IF;

/* End Bug 7299779 - vavenugo */

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug(  'arp_proc_transaction_history.insert_transaction_history()-');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_proc_transaction_history.insert_transaction_history()');
        END IF;
        RAISE;

END insert_transaction_history;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_transaction_history                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Updates a record into ar_transaction_history for bills receivable      |
 |    transaction. MRC information is updated if MRC functionality is enabled|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:  p_trx_rec                                              |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/

PROCEDURE update_transaction_history(p_trh_rec                IN OUT NOCOPY ar_transaction_history%rowtype,
                                     p_transaction_history_id IN     ar_transaction_history.transaction_history_id%TYPE) IS

  CURSOR trh_customer_trx_cur IS
    SELECT customer_trx_id
    FROM ar_transaction_history
    WHERE transaction_history_id = p_transaction_history_id;

  trh_customer_trx_rec trh_customer_trx_cur%ROWTYPE;
  l_customer_trx_id    ar_transaction_history.customer_trx_id%TYPE;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_proc_transaction_history.update_transaction_history()+');
   END IF;

 /*------------------------------------------------+
  |  All the validation and defaulting is done in  |
  |  the BR API, so none is done in the entity     |
  |  handler.                                      |
  +------------------------------------------------*/

 /*------------------------------------------------+
  |  If customer_trx_id is not passed we need to   |
  |  fetch it.                                     |
  +------------------------------------------------*/
  IF p_trh_rec.customer_trx_id IS NULL OR p_trh_rec.customer_trx_id = AR_NUMBER_DUMMY THEN

    OPEN trh_customer_trx_cur;
    FETCH trh_customer_trx_cur INTO trh_customer_trx_rec;
    CLOSE trh_customer_trx_cur;

    l_customer_trx_id := trh_customer_trx_rec.customer_trx_id;

  ELSE

    l_customer_trx_id := p_trh_rec.customer_trx_id;

  END IF;

 /*-----------------------------------------------------------------+
  |  Lock rows in other tables that reference this customer_trx_id  |
  +-----------------------------------------------------------------*/
   arp_process_br_header.lock_transaction(l_customer_trx_id);

  /*----------------------+
   |  call table-handler  |
   +----------------------*/

   arp_transaction_history_pkg.update_p(p_trh_rec, p_transaction_history_id);

  /*-------------------------------------+
   | None of MRC columns can be updated  |
   +-------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_proc_transaction_history.update_transaction_history()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_proc_transaction_history.update_transaction_history()');
        END IF;
        RAISE;

END update_transaction_history;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_transaction_history                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes row from ar_transaction_history for Bills Receivable           |
 |    Transaction. MRC information is deleted if MRC functionality is enabled|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_transaction_history_id                                |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE delete_transaction_history(p_transaction_history_id IN ar_transaction_history.transaction_history_id%TYPE) IS

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_proc_transaction_history.delete_transaction_history()+');
   END IF;

  /*--------------------------------+
   |  lock history record           |
   +-------------------------------*/
   arp_transaction_history_pkg.lock_p(p_trh_id => p_transaction_history_id);

  /*--------------------------------+
   |  delete the history record     |
   +-------------------------------*/
   arp_transaction_history_pkg.delete_p(p_trh_id => p_transaction_history_id);

  /*---------------------------------------------------+
   | Delete all accounting related to the history row  |
   +---------------------------------------------------*/
   arp_proc_transaction_history.delete_transaction_hist_dist(p_transaction_history_id);

  /*------------------------------------------+
   |  Call MRC logic to delete MRC rows       |
   +------------------------------------------*/
--{BUG#4301323
--   ARP_PROC_TRANSACTION_HISTORY.delete_mrc_transaction_hist(p_transaction_history_id);
--}

--Bug# 2750340
   arp_xla_events.delete_event( p_document_id  => p_transaction_history_id,
                                p_doc_table    => 'TRH');


   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_proc_transaction_history.delete_transaction_history()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_proc_transaction_history.delete_transaction_history()');
        END IF;
        RAISE;

END delete_transaction_history;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    delete_transaction_history                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Deletes distribution rows from ar_distributions for given transaction  |
 |    history record.                                                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_transaction_history_id                                |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |   28-MAR-2000  Jani Rautiainen      Created                               |
 |   10-MAY-2000  Debbie Jancis        Added call to delete from             |
 |				       ar_distributions after call to delete |
 |				       using table handler since that will   |
 |				       not be modified to handle MRC ar      |
 |				       distributions deletes.  Added call to |
 |				       ar_mrc_engine for processing.         |
 +===========================================================================*/
PROCEDURE delete_transaction_hist_dist(p_transaction_history_id IN ar_transaction_history.transaction_history_id%TYPE) IS

 /*----------------------------------------+
  |  Cursor for distribution records       |
  |  related to the transaction history    |
  +----------------------------------------*/
/* Start FP Bug 5741803 chng the defination to check for source table */
  CURSOR distribution_cur IS
    select dist.line_id
    from ar_distributions dist
    where source_id = p_transaction_history_id
    and source_table = 'TH';
/* End FP Bug 5741803 SPDIXIT */
  distribution_rec distribution_cur%ROWTYPE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_proc_transaction_history.delete_transaction_hist_dist()+');
   END IF;

  /*----------------------------------------+
   |  Loop through all distribution records |
   |  related to the transaction history    |
   +----------------------------------------*/

   FOR distribution_rec IN distribution_cur LOOP

    /*-----------------------------+
     |  Delete distribution record |
     +-----------------------------*/
     arp_distributions_pkg.delete_p(distribution_rec.line_id);

   END LOOP;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug(  'arp_proc_transaction_history.delete_transaction_hist_dist()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug(  'EXCEPTION:  arp_proc_transaction_history.delete_transaction_hist_dist()');
        END IF;
        RAISE;

END delete_transaction_hist_dist;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    find_prev_accounted_id                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Finds previous accounted record. Note that this will return NULL       |
 |    if previous accounted record does not exist.                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_id                                       |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
FUNCTION find_prev_accounted_id(p_customer_trx_id IN ra_customer_trx.customer_trx_id%TYPE) RETURN NUMBER IS

 /*----------------------------------+
  |  Cursor for finding the previous |
  |  accounted transaction history   |
  +----------------------------------*/
  CURSOR prev_acctd_trh_cur IS
    select transaction_history_id
    from ar_transaction_history
    where current_accounted_flag = 'Y'
    and customer_trx_id = p_customer_trx_id;

  prev_acctd_trh_rec prev_acctd_trh_cur%ROWTYPE;

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_proc_transaction_history.find_prev_accounted_id()+');
   END IF;

  /*---------------------------------------------------+
   |  Fetch the previous accounted transaction history |
   +---------------------------------------------------*/
   OPEN prev_acctd_trh_cur;
   FETCH prev_acctd_trh_cur INTO prev_acctd_trh_rec;
   CLOSE prev_acctd_trh_cur;

   RETURN prev_acctd_trh_rec.transaction_history_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_util.debug('arp_proc_transaction_history.find_prev_accounted_id()-');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('EXCEPTION:  arp_proc_transaction_history.find_prev_accounted_id()');
        END IF;
        RAISE;

END find_prev_accounted_id;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_BR_ps                                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Inserts an payment schedule for Bills Receivable                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_trh_rec   - Record containing the transaction history |
 |                                 recor being created.                      |
 |              OUT: p_ps_id     - PS id of the record created               |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |     25-MAY-2005  V Crisostomo	 SSA-R12 : add org_id                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE insert_BR_ps(
        p_trh_rec       IN  ar_transaction_history%ROWTYPE,
        p_ps_id         OUT NOCOPY ar_payment_schedules.payment_schedule_id%TYPE) IS

l_trx_rec         ra_customer_trx%ROWTYPE;
l_ps_rec	  ar_payment_schedules%ROWTYPE;
l_ps_id		  ar_payment_schedules.payment_schedule_id%TYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_proc_transaction_history.insert_BR_ps()+');
  END IF;

 /*------------------------------------+
  |  Fetch the transaction information |
  +------------------------------------*/
  arp_ct_pkg.fetch_p(l_trx_rec, p_trh_rec.customer_trx_id);


 /*-------------------------------------------------------------------------+
  |  fill record columns with data from transaction and transaction history |
  +-------------------------------------------------------------------------*/
  l_ps_rec.due_date			:= l_trx_rec.term_due_date;
  l_ps_rec.gl_date			:= p_trh_rec.gl_date;
  l_ps_rec.gl_date_closed		:= TO_DATE('12/31/4712','MM/DD/YYYY');
  l_ps_rec.actual_date_closed		:= TO_DATE('12/31/4712','MM/DD/YYYY');
  l_ps_rec.trx_date			:= l_trx_rec.trx_date;
  l_ps_rec.number_of_due_dates		:= 1;
  l_ps_rec.org_id                       := l_trx_rec.org_id;

 /*-------------------------------------------------------------------------+
  |  Calculate the payment schedule amount using shadow adjustment created  |
  |  against the assignments.                                               |
  +-------------------------------------------------------------------------*/
  arp_proc_transaction_history.calculate_BR_amounts(
        l_trx_rec.customer_trx_id,
        l_ps_rec.amount_due_original,
        l_ps_rec.acctd_amount_due_remaining,
        l_ps_rec.amount_line_items_original,
        l_ps_rec.tax_original,
        l_ps_rec.freight_original,
        l_ps_rec.receivables_charges_charged);

  l_ps_rec.amount_due_remaining          := l_ps_rec.amount_due_original;
  l_ps_rec.amount_line_items_remaining   := l_ps_rec.amount_line_items_original;
  l_ps_rec.tax_remaining                 := l_ps_rec.tax_original;
  l_ps_rec.freight_remaining             := l_ps_rec.freight_original;
  l_ps_rec.receivables_charges_remaining := l_ps_rec.receivables_charges_charged;
  l_ps_rec.amount_applied		 := NULL;
  l_ps_rec.amount_credited               := NULL;

  l_ps_rec.status			:= 'OP';
  l_ps_rec.class			:= 'BR';
  l_ps_rec.trx_number			:= l_trx_rec.trx_number;
  l_ps_rec.cust_trx_type_id		:= l_trx_rec.cust_trx_type_id;
  l_ps_rec.customer_id			:= l_trx_rec.drawee_id;
  l_ps_rec.customer_site_use_id		:= l_trx_rec.drawee_site_use_id;
  l_ps_rec.customer_trx_id		:= l_trx_rec.customer_trx_id;
  l_ps_rec.invoice_currency_code	:= l_trx_rec.invoice_currency_code;
  l_ps_rec.exchange_rate_type		:= l_trx_rec.exchange_rate_type;
  l_ps_rec.exchange_rate		:= l_trx_rec.exchange_rate;
  l_ps_rec.exchange_date		:= l_trx_rec.exchange_date;
  l_ps_rec.term_id                      := NULL;
  l_ps_rec.terms_sequence_number        := 1;

 /*--------------------------------------------+
  |  insert record into payment schedule table |
  +--------------------------------------------*/
  arp_ps_pkg.insert_p(l_ps_rec, l_ps_id);

  p_ps_id := l_ps_id;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_proc_transaction_history.insert_BR_ps()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION: arp_proc_transaction_history.insert_BR_ps()');
      END IF;
      RAISE;

END insert_BR_ps;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    calculate_BR_amounts                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calculate the payment schedule amount using shadow adjustment created  |
 |    against the assignments.                                               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_id - Transaction ID                      |
 |                                                                           |
 |              OUT: p_amount          - Sum of adjustments                  |
 |                   p_acctd_amount    - Sum of adjustments in functional    |
 |                                       currency.                           |
 |                   p_line_amount     - Sum of adjustment line amounts      |
 |                   p_tax_amount      - Sum of adjustment tax amounts       |
 |                   p_freight_amount  - Sum of adjustment freight amounts   |
 |                   p_charges_amount  - Sum of adjustment charges amounts   |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE calculate_BR_amounts(
        p_customer_trx_id       IN  ra_customer_trx.customer_trx_id%TYPE,
        p_amount                OUT NOCOPY NUMBER,
        p_acctd_amount          OUT NOCOPY NUMBER,
        p_line_amount           OUT NOCOPY NUMBER,
        p_tax_amount            OUT NOCOPY NUMBER,
        p_freight_amount        OUT NOCOPY NUMBER,
        p_charges_amount        OUT NOCOPY NUMBER) IS

 /*----------------------------------------+
  |  Cursor for totals on the adjustments. |
  |  The currency and exchange rate has to |
  |  be exactly the same on all assignments|
  |  so the totals can be summed together  |
  +----------------------------------------*/
  CURSOR br_amounts_cur IS
    SELECT sum(nvl(amount,0)) total_amount,
           sum(nvl(acctd_amount,0)) total_acctd_amount,
           sum(nvl(line_adjusted,0)) total_line,
           sum(nvl(freight_adjusted,0)) total_freight,
           sum(nvl(tax_adjusted,0)) total_tax,
           sum(nvl(receivables_charges_adjusted,0)) total_charges
    FROM ra_customer_trx_lines ctl,
         ar_adjustments adj
    WHERE ctl.customer_trx_id = p_customer_trx_id
    AND   adj.adjustment_id   = ctl.br_adjustment_id;

  br_amounts_rec br_amounts_cur%ROWTYPE;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_proc_transaction_history.calculate_BR_amounts()+');
  END IF;

 /*---------------------------------------+
  |  Fetch the totals on the adjustments  |
  +---------------------------------------*/
  OPEN br_amounts_cur;
  FETCH br_amounts_cur INTO br_amounts_rec;
  CLOSE br_amounts_cur;

 /*------------------+
  |  Return results  |
  +------------------*/
  p_amount         := -nvl(br_amounts_rec.total_amount,0);
  p_acctd_amount   := -nvl(br_amounts_rec.total_acctd_amount,0);
  p_line_amount    := -nvl(br_amounts_rec.total_line,0);
  p_tax_amount     := -nvl(br_amounts_rec.total_tax,0);
  p_freight_amount := -nvl(br_amounts_rec.total_freight,0);
  p_charges_amount := -nvl(br_amounts_rec.total_charges,0);

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_proc_transaction_history.calculate_BR_amounts()-');
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION: arp_proc_transaction_history.calculate_BR_amounts()');
      END IF;
      RAISE;

END calculate_BR_amounts;




/*===========================================================================+
 | PROCEDURE                                                                 |
 |    previous_history_exists                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This function is used to find out NOCOPY whether an previous transaction      |
 |    history record exists.                                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_customer_trx_id                                       |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : TRUE  - If a previous transaction history record exists      |
 |              FALSE - If previous transaction history record does not exist|
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-MAR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
FUNCTION previous_history_exists(p_customer_trx_id ra_customer_trx.customer_trx_id%TYPE) RETURN BOOLEAN IS

  CURSOR previous_history_exists_cur IS
    SELECT 'exists'
    FROM   ar_transaction_history
    WHERE  customer_trx_id = p_customer_trx_id
    AND    current_record_flag = 'Y';

 previous_history_exists_rec previous_history_exists_cur%ROWTYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_PROC_TRANSACTION_HISTORY.previous_history_exists()+');
  END IF;

  OPEN previous_history_exists_cur;
  FETCH previous_history_exists_cur INTO previous_history_exists_rec;

  IF previous_history_exists_cur%NOTFOUND THEN
    CLOSE previous_history_exists_cur;
    RETURN FALSE;
  END IF;

  CLOSE previous_history_exists_cur;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_PROC_TRANSACTION_HISTORY.previous_history_exists()-');
  END IF;

  RETURN TRUE;

END previous_history_exists;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    create_trh_for_receipt_act                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |  This procedure creates the CLOSED / UNPAID / PENDING_REMITTANCE record   |
 |  when an action takes place on a receipt applied to BR transaction        |
 |  This should only be used if receipt application / unapplication /reversal|
 |  does not cause reclassification accounting on the BR. This is intended   |
 |  to be used from the RWB when doing actions on a receipt applied to a BR  |
 |  This is also called from the BR Housekeeper program to create the BR     |
 |  CLOSED record, since no reclassification happens in that case.           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  l_old_ps_rec   Image of the payment schedule before     |
 |                                  receipt impacted it.                     |
 |                   p_app_rec      The APP record which impacted BR trx     |
 |                   p_called_from  Information from where called from       |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUL-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
procedure create_trh_for_receipt_act(p_old_ps_rec   IN ar_payment_schedules%ROWTYPE,
                                     p_app_rec      IN ar_receivable_applications%ROWTYPE,
                                     p_called_from  IN VARCHAR2) IS

  l_new_ps_rec               ar_payment_schedules%ROWTYPE;
  l_trh_rec                  ar_transaction_history%ROWTYPE;
  l_transaction_history_id   ar_transaction_history.transaction_history_id%TYPE;

BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_PROC_TRANSACTION_HISTORY.create_trh_for_receipt_act()+');
  END IF;

 /*--------------------------------------------+
  |  Initialize the transaction history record |
  |  with common information                   |
  +--------------------------------------------*/
  l_trh_rec.customer_trx_id          := p_old_ps_rec.customer_trx_id;
  l_trh_rec.current_record_flag      := 'Y';
  l_trh_rec.current_accounted_flag   := 'N';
  l_trh_rec.postable_flag            := 'N';
  l_trh_rec.first_posted_record_flag := 'N';
  l_trh_rec.posting_control_id       := -3;
  l_trh_rec.gl_posted_date           := NULL;
  l_trh_rec.created_from             := p_called_from;
  l_trh_rec.trx_date                 := p_app_rec.apply_date;
  l_trh_rec.gl_date                  := p_app_rec.gl_date;
  l_trh_rec.comments                 := p_app_rec.comments;
  l_trh_rec.maturity_date            := p_old_ps_rec.due_date;
  l_trh_rec.batch_id                 := NULL;

 /*--------------------------------------------------+
  |  Fetch the updated image of the payment schedule |
  +--------------------------------------------------*/
  arp_ps_pkg.fetch_p( p_old_ps_rec.payment_schedule_id, l_new_ps_rec );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('create_trh_for_receipt_act: ' || 'old_status      = '||p_old_ps_rec.status);
     arp_util.debug('create_trh_for_receipt_act: ' || 'new_status      = '||l_new_ps_rec.status);
  END IF;

  IF NVL(p_old_ps_rec.status,'OP') = 'OP' AND NVL(l_new_ps_rec.status,'OP') = 'CL'
     OR NVL(p_old_ps_rec.status,'OP') = 'CL' AND NVL(l_new_ps_rec.status,'OP') = 'OP'
     THEN

    IF NVL(p_old_ps_rec.status,'OP') = 'CL' AND NVL(l_new_ps_rec.status,'OP') = 'OP' THEN

      /*-----------------------------------------------------------------+
       |  Payment schedule was closed, check whether BR transaction has  |
       |  passed the maturity date                                       |
       +-----------------------------------------------------------------*/
       IF trunc(p_old_ps_rec.due_date) >= trunc(SYSDATE) THEN

        /*-----------------------------------------------------------+
         |  BR has NOT passed maturity date, so record created with  |
         |  PENDING_REMITTANCE / UNPAID                              |
         +-----------------------------------------------------------*/
         l_trh_rec.status := 'PENDING_REMITTANCE';
         l_trh_rec.event  := 'UNPAID';

       ELSE

        /*-------------------------------------------------------+
         |  BR has passed maturity date, so record created with  |
         |  PENDING_REMITTANCE / UNPAID                          |
         +-------------------------------------------------------*/
         l_trh_rec.status := 'UNPAID';
         l_trh_rec.event  := 'UNPAID';

       END IF;

    ELSIF NVL(p_old_ps_rec.status,'OP') = 'OP' AND NVL(l_new_ps_rec.status,'OP') = 'CL' THEN

      /*-----------------------------------------------------------------+
       |  Payment schedule was opened, create transaction history record |
       +-----------------------------------------------------------------*/

       l_trh_rec.status := 'CLOSED';
       l_trh_rec.event  := 'CLOSED';

    END IF;

   /*------------------------------------+
    |  Cannot insert NULL into trx_date  |
    +------------------------------------*/
    IF l_trh_rec.trx_date IS NULL THEN

      l_trh_rec.trx_date := SYSDATE;

    END IF;

   /*-------------------------------------------+
    |  Call entity handler to create the record |
    +-------------------------------------------*/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.customer_trx_id          = '||to_char(l_trh_rec.customer_trx_id));
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.current_record_flag      = '||l_trh_rec.current_record_flag);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.current_accounted_flag   = '||l_trh_rec.current_accounted_flag);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.postable_flag            = '||l_trh_rec.postable_flag);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.first_posted_record_flag = '||l_trh_rec.first_posted_record_flag);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.posting_control_id       = '||to_char(l_trh_rec.posting_control_id));
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.gl_posted_date           = '||to_char(l_trh_rec.gl_posted_date));
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.created_from             = '||l_trh_rec.created_from);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.trx_date                 = '||to_char(l_trh_rec.trx_date));
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.gl_date                  = '||to_char(l_trh_rec.gl_date));
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.comments                 = '||l_trh_rec.comments);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.maturity_date            = '||to_char(l_trh_rec.maturity_date));
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.batch_id                 = '||to_char(l_trh_rec.batch_id));
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.status                   = '||l_trh_rec.status);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.event                    = '||l_trh_rec.event);
       arp_util.debug('create_trh_for_receipt_act: ' || 'l_trh_rec.trx_date                 = '||to_char(l_trh_rec.trx_date));
    END IF;

    ARP_PROC_TRANSACTION_HISTORY.insert_transaction_history(l_trh_rec, l_transaction_history_id);

  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARP_PROC_TRANSACTION_HISTORY.create_trh_for_receipt_act()+');
  END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_util.debug('ARP_PROC_TRANSACTION_HISTORY.create_trh_for_receipt_act');
        END IF;
        RAISE;

END create_trh_for_receipt_act;

END ARP_PROC_TRANSACTION_HISTORY;

/
