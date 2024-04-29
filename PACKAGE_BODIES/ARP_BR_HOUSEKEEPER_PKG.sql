--------------------------------------------------------
--  DDL for Package Body ARP_BR_HOUSEKEEPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BR_HOUSEKEEPER_PKG" AS
/* $Header: ARRBRHKB.pls 120.6 2005/06/03 20:41:32 vcrisost ship $ */


/*----------------------------------------------------+
 | Package global record (private) for BR information |
 +----------------------------------------------------*/
TYPE BR_rec_type IS RECORD (
    customer_trx_id              ar_payment_schedules.customer_trx_id%TYPE,
    payment_schedule_id          ar_payment_schedules.payment_schedule_id%TYPE,
    maturity_date                ar_payment_schedules.due_date%TYPE,
    reserved_type                ar_payment_schedules.reserved_type%TYPE,
    reserved_value               ar_payment_schedules.reserved_value%TYPE,
    amount_due_remaining         ar_payment_schedules.amount_due_remaining%TYPE,
    tax_remaining                ar_payment_schedules.tax_remaining%TYPE,
    gl_date                      ar_transaction_history.gl_date%TYPE,
    transaction_history_id       ar_transaction_history.transaction_history_id%TYPE,
    prv_trx_history_id           ar_transaction_history.prv_trx_history_id%TYPE,
    status                       ar_transaction_history.status%TYPE,
    event                        ar_transaction_history.event%TYPE,
    org_id                       ar_transaction_history.org_id%TYPE);

/*-----------------------------------------------------------------+
 | Package global variables (private) to be used in sub procedures |
 +-----------------------------------------------------------------*/
pg_gl_date                      DATE;
pg_effective_date               DATE;
pg_deferred_tax_exists          BOOLEAN := TRUE;
pg_collection_days              ar_receipt_method_accounts.br_collection_days%TYPE;
pg_risk_elimination_days        ar_receipt_method_accounts.risk_elimination_days%TYPE;
pg_rct_inherit_inv_num_flag     ar_receipt_methods.receipt_inherit_inv_num_flag%TYPE;
pg_receipt_method_id            ar_batches.receipt_method_id%TYPE;
pg_remit_bank_acct_use_id       ar_batches.remit_bank_acct_use_id%type;
pg_remittance_batch_date        ar_batches.batch_date%TYPE;
pg_endorsement_date             DATE;
pg_called_from                  VARCHAR2(50);

pg_BR_rec                       BR_rec_type;


/*--------------------------+
 | Exception for API errors |
 +--------------------------*/
API_exception                   EXCEPTION;

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

procedure create_and_apply_Receipt(p_move_deferred_tax         IN VARCHAR2 DEFAULT 'Y',
                                   p_receipt_date              IN DATE);

procedure approve_Adjustment(p_adjustment_rec    IN OUT NOCOPY ar_adjustments%ROWTYPE,
                             p_move_deferred_tax IN     VARCHAR2 DEFAULT 'Y');

procedure apply_Receipt(p_move_deferred_tax         IN VARCHAR2 DEFAULT 'Y',
                        p_receipt_date              IN DATE);

procedure create_maturity_date_event(p_move_deferred_tax IN VARCHAR2 DEFAULT 'Y',
                                     p_event_date        DATE);

PROCEDURE prev_posted_trh(p_transaction_history_id IN  ar_transaction_history.transaction_history_id%TYPE,
                          p_trh_rec                OUT NOCOPY ar_transaction_history%ROWTYPE);

PROCEDURE fetch_remittance_setup_data(p_status             IN ar_transaction_history.status%TYPE,
                                      p_batch_id           IN ar_batches.batch_id%TYPE DEFAULT NULL);

PROCEDURE fetch_endorsement_setup_data(p_receivables_trx_id IN ar_receivables_trx.receivables_trx_id%TYPE);

PROCEDURE process_standard_remitted;
PROCEDURE process_factored;
PROCEDURE process_endorsed;

PROCEDURE write_API_output(p_msg_count        IN NUMBER,
                           p_msg_data         IN VARCHAR2);

PROCEDURE write_debug_and_log(p_message IN VARCHAR2);

FUNCTION validate_and_default_gl_date(p_gl_date                in date,
                                      p_doc_date               in date,
                                      p_validation_date1       in date,
                                      p_validation_date2       in date,
                                      p_validation_date3       in date,
                                      p_default_date1          in date,
                                      p_default_date2          in date,
                                      p_default_date3          in date) RETURN DATE;

FUNCTION validate_against_doc_gl_date(p_gl_date                in date,
                                      p_doc_gl_date            in date) RETURN DATE;

/*===========================================================================+
 | PROCEDURE ar_br_housekeeper                                               |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Loops through matured Bills Receivable documents and creates maturity  |
 |    and /or payment events depending on the given parameters.              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
function ar_br_housekeeper(p_effective_date          IN DATE,
                           p_gl_date                 IN DATE,
                           p_maturity_date_low       IN DATE,
                           p_maturity_date_high      IN DATE,
                           p_trx_gl_date_low         IN DATE,
                           p_trx_gl_date_high        IN DATE,
                           p_cust_trx_type_id        IN ra_cust_trx_types.cust_trx_type_id%TYPE,
                           p_include_factored_BR     IN VARCHAR2 DEFAULT 'Y',
                           p_include_std_remitted_BR IN VARCHAR2 DEFAULT 'Y',
                           p_include_endorsed_BR     IN VARCHAR2 DEFAULT 'Y') RETURN BOOLEAN IS

 /*--------------------------------------+
  | Cursor for matured BR transactions   |
  +--------------------------------------*/
  CURSOR matured_cur IS
    select ps.customer_trx_id,
           ps.payment_schedule_id,
           ps.due_date maturity_date,
           ps.reserved_type,
           ps.reserved_value,
           ps.amount_due_remaining,
           ps.tax_remaining,
           trh.gl_date,
           trh.transaction_history_id,
           trh.prv_trx_history_id,
           trh.status,
           trh.event,
           ps.org_id
    from ar_transaction_history trh, ar_payment_schedules ps
    where
    /*-----------------------------------------------------+
     | Restrict the transaction type if given as parameter |
     +-----------------------------------------------------*/
          ps.cust_trx_type_id   = NVL(p_cust_trx_type_id,ps.cust_trx_type_id)
    and   ps.class              = 'BR'
    and   ps.reserved_type      in ('REMITTANCE','ADJUSTMENT')

    /*---------------------------------------------------------------------------------+
     | Restrict the maturity date to be earlier than effective_date given as parameter |
     +---------------------------------------------------------------------------------*/
    and   trunc(ps.due_date) <= trunc(NVL(p_effective_date, SYSDATE))

    /*--------------------------------------------------------------------------------+
     | Restrict the maturity date to be within maturity date range given as parameter |
     +--------------------------------------------------------------------------------*/
    and   trunc(ps.due_date) between trunc(NVL(p_maturity_date_low ,ps.due_date))
                        and   trunc(NVL(p_maturity_date_high,ps.due_date))

    /*--------------------------------------------------------------------------------+
     | Restrict the transaction GL date to be within GL date range given as parameter |
     +--------------------------------------------------------------------------------*/
    and   trunc(ps.gl_date) between trunc(NVL(p_trx_gl_date_low ,ps.gl_date))
                       and   trunc(NVL(p_trx_gl_date_high,ps.gl_date))
    and   ps.customer_trx_id = trh.customer_trx_id
    and   trh.current_record_flag = 'Y'
    /*-------------------------------------------------------------------------------------------------------------------+
     | Restrict the BR status depending on flags given as parameter.                                                     |
     | If p_include_std_remitted_BR = 'Y' then BRs with status 'REMITTED' are included                                   |
     | If p_include_factored_BR = 'Y' then BRs with statuses 'FACTORED' and 'MATURED_PEND_RISK_ELIMINATION' are included |
     | If p_include_endorsed_BR = 'Y' then BRs with status 'ENDORSED' are included                                       |
     | If all or some of the flags are 'Y' then the corresponding statuses are included                                  |
     +-------------------------------------------------------------------------------------------------------------------*/
    and   trh.status in (decode(NVL(p_include_std_remitted_BR,'Y'),
                                    'Y','REMITTED',NULL),
                         decode(NVL(p_include_factored_BR,'Y'),
                                    'Y','FACTORED',NULL),
                         decode(NVL(p_include_factored_BR,'Y'),
                                    'Y','MATURED_PEND_RISK_ELIMINATION',NULL),
                         decode(NVL(p_include_endorsed_BR,'Y'),
                                    'Y','ENDORSED',NULL)
                         )
    FOR UPDATE OF ps.reserved_type, trh.status NOWAIT;

  l_BR_rec                     BR_rec_type;
  l_default_gl_date            DATE;
  l_deferred_tax_exists        BOOLEAN := FALSE;

BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.ar_br_housekeeper()+' );
  write_debug_and_log( 'p_effective_date = '||to_char(p_effective_date));
  write_debug_and_log( 'p_gl_date = '       ||to_char(p_gl_date));
  write_debug_and_log( 'p_maturity_date_low = '  ||to_char(p_maturity_date_low));
  write_debug_and_log( 'p_maturity_date_high = ' ||to_char(p_maturity_date_high));
  write_debug_and_log( 'p_trx_gl_date_low = '    ||to_char(p_trx_gl_date_low));
  write_debug_and_log( 'p_trx_gl_date_high = '   ||to_char(p_trx_gl_date_high));
  write_debug_and_log( 'p_cust_trx_type_id = '   ||to_char(p_cust_trx_type_id));
  write_debug_and_log( 'p_include_factored_BR = '||p_include_factored_BR);
  write_debug_and_log( 'p_include_std_remitted_BR = '||p_include_std_remitted_BR);
  write_debug_and_log( 'p_include_endorsed_BR = '    ||p_include_endorsed_BR);

 /*------------------------------------------------------------------------+
  | Validate GL date. If gl_date is not passed try to default it. If given |
  | GL_date is valid use that If given GL_date is invalid or null then try |
  | current date If neither the given GL_date nor SYSDATE is valid, then   |
  | the GL_DATE will be defaulted to the last date of the most recent open |
  | period.                                                                |
  +------------------------------------------------------------------------*/
  l_default_gl_date := arp_br_housekeeper_pkg.validate_and_default_gl_date(p_gl_date,
                                                                           NULL,NULL,NULL,NULL,
                                                                           SYSDATE,
                                                                           NULL,NULL);
  IF l_default_gl_date is not NULL THEN

    pg_gl_date := l_default_gl_date;
    write_debug_and_log( 'pg_gl_date = '||to_char(pg_gl_date));

  ELSE
   /*-----------------------------------------------------+
    | Invalid GL_date and system was unable to default it |
    +-----------------------------------------------------*/
    write_debug_and_log( 'Invalid GL date' );
    RETURN FALSE;

  END IF;

 /*----------------------------------------------------------------------------+
  | Copy gl_date to a package global, so it can be seen form the sub procedures|
  +----------------------------------------------------------------------------*/
  pg_effective_date := NVL(p_effective_date,SYSDATE);

  write_debug_and_log( 'pg_effective_date = '||to_char(pg_effective_date));

 /*---------------------------------------------------------------------------+
  | Loop through matured BR transactions. Have to use WHILE loop since the    |
  | copy to package global record gives error with FOR loop.                  |
  | ORA-21615: copy of an OTS (named or simple) instance failed               |
  | ORA-21614: constraint violation for attribute number [6]                  |
  +---------------------------------------------------------------------------*/
  OPEN  matured_cur;
  FETCH matured_cur INTO l_BR_rec;

 /*---------------------------------------------------------------------------+
  | If no BRs were selected, write information to the log. The processing will|
  | skip the loop and exit the program. TRUE is returned as value since no    |
  | error occurred.                                                           |
  +---------------------------------------------------------------------------*/
  IF matured_cur%NOTFOUND THEN

     write_debug_and_log( 'No Bills Receivable transactions matching the given criteria' );

  END IF;

 /*--------------------------------------+
  | Process the selected BR transactions |
  +--------------------------------------*/
  WHILE matured_cur%FOUND LOOP

   /*-----------------------------------------------------------+
    | Copy values from local record to a package global record, |
    | so the values can be seen form the sub procedures         |
    +-----------------------------------------------------------*/
    pg_BR_rec := l_BR_rec;

   /*--------------------------+
    | Lock rest of the tables  |
    +--------------------------*/
    arp_process_br_header.lock_transaction(pg_BR_rec.customer_trx_id);

    write_debug_and_log( 'pg_BR_rec.customer_trx_id = '       ||to_char(pg_BR_rec.customer_trx_id));
    write_debug_and_log( 'pg_BR_rec.payment_schedule_id = '   ||to_char(pg_BR_rec.payment_schedule_id));
    write_debug_and_log( 'pg_BR_rec.maturity_date = '         ||to_char(pg_BR_rec.maturity_date));
    write_debug_and_log( 'pg_BR_rec.reserved_type = '         ||pg_BR_rec.reserved_type);
    write_debug_and_log( 'pg_BR_rec.reserved_value = '        ||to_char(pg_BR_rec.reserved_value));
    write_debug_and_log( 'pg_BR_rec.amount_due_remaining = '  ||to_char(pg_BR_rec.amount_due_remaining));
    write_debug_and_log( 'pg_BR_rec.tax_remaining = '         ||to_char(pg_BR_rec.tax_remaining));
    write_debug_and_log( 'pg_BR_rec.gl_date = '               ||to_char(pg_BR_rec.gl_date));
    write_debug_and_log( 'pg_BR_rec.transaction_history_id = '||to_char(pg_BR_rec.transaction_history_id));
    write_debug_and_log( 'pg_BR_rec.prv_trx_history_id = '    ||to_char(pg_BR_rec.prv_trx_history_id));
    write_debug_and_log( 'pg_BR_rec.status = '                ||pg_BR_rec.status);
    write_debug_and_log( 'pg_BR_rec.event  = '                ||pg_BR_rec.event);
    write_debug_and_log( 'pg_BR_rec.org_id = '                ||to_char(pg_BR_rec.org_id));

   /*-----------------------------------------------------------+
    | Check whether tax exists for this BR, this information is |
    | used when deciding whether to move deferred tax or not    |
    +-----------------------------------------------------------*/
    ARP_PROCESS_BR_HEADER.move_deferred_tax(pg_BR_rec.customer_trx_id,l_deferred_tax_exists);

    IF l_deferred_tax_exists THEN

       pg_deferred_tax_exists := TRUE;

    ELSE

       pg_deferred_tax_exists := FALSE;

    END IF;

   /*--------------------------------------------------+
    | Based on the status and dates branch the code    |
    +--------------------------------------------------*/

    IF pg_BR_rec.status = 'REMITTED' THEN

      pg_called_from := 'BR_REMITTED';
      arp_br_housekeeper_pkg.process_standard_remitted;

    ELSIF pg_BR_rec.status = 'FACTORED' or pg_BR_rec.status = 'MATURED_PEND_RISK_ELIMINATION' THEN

      pg_called_from := 'BR_FACTORED_WITH_RECOURSE';
      arp_br_housekeeper_pkg.process_factored;

    ELSIF pg_BR_rec.status = 'ENDORSED' THEN

      pg_called_from := NULL;
      arp_br_housekeeper_pkg.process_endorsed;

    ELSE

     /*--------------------------------------------------+
      | Not supported BR transaction status, this should |
      | never happen unless the main query is changed    |
      +--------------------------------------------------*/
      write_debug_and_log( 'Status '|| pg_BR_rec.status ||' not supported' );
      APP_EXCEPTION.raise_exception;

    END IF;

    FETCH matured_cur INTO l_BR_rec;

  END LOOP;

  CLOSE matured_cur;

  write_debug_and_log( 'arp_br_housekeeper_pkg.ar_br_housekeeper()-' );
  return(TRUE);

  EXCEPTION
  WHEN OTHERS THEN
        IF matured_cur%ISOPEN THEN
          CLOSE matured_cur;
        END IF;
	write_debug_and_log('Exception: arp_br_housekeeper_pkg.ar_br_housekeeper '||SQLERRM);
	RAISE;

END ar_br_housekeeper;


/*===========================================================================+
 | PROCEDURE process_standard_remitted                                       |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |  This procedure processes standard remitted bills receivable transactions |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  NONE                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-JUN-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE process_standard_remitted IS

  l_move_deferred_tax          VARCHAR2(1) := 'Y';
  l_receipt_date               DATE;

BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.process_standard_remitted()+' );

 /*-------------------------------------------------+
  | Fetch information from the BR remittance batch  |
  | The procedure populates a package global record |
  | with the data, accessible to all sub procedures |
  +-------------------------------------------------*/
  arp_br_housekeeper_pkg.fetch_remittance_setup_data(pg_BR_rec.status,
                                                     pg_BR_rec.reserved_value);

 /*--------------------------------------------------------+
  | Check whether we have remitted after the maturity date |
  | and branch the code accordingly                        |
  +--------------------------------------------------------*/
  IF trunc(pg_remittance_batch_date) >= trunc(pg_BR_rec.maturity_date) THEN

   /*----------------------------------------------------------------+
    | Check whether we have passed remittance date + collection_days |
    | and branch the code accordingly                                |
    +----------------------------------------------------------------*/
    IF trunc(pg_effective_date) < (trunc(pg_remittance_batch_date) + NVL(pg_collection_days,0)) THEN

     /*----------------------------------------------------+
      | BR was remitted late and remittance has not passed |
      | collection days, do nothing                        |
      +----------------------------------------------------*/
      write_debug_and_log('Bills Receivable was remitted late and remittance has not passed collection days, Bills receivable not processed ');

    ELSE

     /*----------------------------------------------------------------+
      | BR was remitted late and remittance has passed collection days,|
      | create receipt, apply it and deferred tax is moved as part     |
      | of the application. Deferred tax is only moved if tax to       |
      | be moved exists                                                |
      +----------------------------------------------------------------*/
      IF pg_deferred_tax_exists THEN
        l_move_deferred_tax := 'Y';
      ELSE
        l_move_deferred_tax := 'N';
      END IF;

      l_receipt_date := pg_remittance_batch_date + NVL(pg_collection_days,0);
      create_and_apply_Receipt(l_move_deferred_tax,l_receipt_date);

    END IF; /* l_remittance_past_effective */

  ELSE

   /*----------------------------------------------------------------+
    | BR was remitted within maturity, create receipt, apply it and  |
    | deferred tax is moved as part of the application. Deferred tax |
    | is only moved if tax to be moved exists                        |
    +----------------------------------------------------------------*/
    IF pg_deferred_tax_exists THEN
      l_move_deferred_tax := 'Y';
    ELSE
      l_move_deferred_tax := 'N';
    END IF;

    l_receipt_date := pg_BR_rec.maturity_date;
    create_and_apply_Receipt(l_move_deferred_tax,l_receipt_date);

  END IF; /* l_remittace_past_maturity */

  write_debug_and_log( 'arp_br_housekeeper_pkg.process_standard_remitted()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.process_standard_remitted '||SQLERRM);
      RAISE;
END process_standard_remitted;

/*===========================================================================+
 | PROCEDURE process_factored                                                |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |  This procedure processes factored bills receivable transactions          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  NONE                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-JUN-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE process_factored IS

  l_move_deferred_tax          VARCHAR2(1) := 'Y';
  prev_trh_rec                 ar_transaction_history%ROWTYPE;
  l_cutoff_date                DATE;
  l_remitted_late              BOOLEAN := FALSE;
  l_event_date                 DATE;

BEGIN

  write_debug_and_log( 'arp_br_housekeeper_pkg.process_factored()+' );

 /*-------------------------------------------------+
  | Fetch information from the BR remittance batch  |
  | The procedure populates a package global record |
  | with the data, accessible to all sub procedures |
  +-------------------------------------------------*/
  arp_br_housekeeper_pkg.fetch_remittance_setup_data(pg_BR_rec.status,
                                                     pg_BR_rec.reserved_value);

 /*-------------------------------------------------+
  | Fetch information on the previous posted        |
  | transaction record for this BR. This information|
  | is used to decide what processing is needed for |
  | the Bills Receivable.                           |
  +-------------------------------------------------*/
  arp_br_housekeeper_pkg.prev_posted_trh(pg_BR_rec.transaction_history_id,
                                         prev_trh_rec);

 /*--------------------------------------------------------+
  | Check whether we have remitted after the maturity date |
  | and branch the code accordingly                        |
  +--------------------------------------------------------*/
  IF trunc(pg_remittance_batch_date) >= trunc(pg_BR_rec.maturity_date) THEN

    l_cutoff_date   := pg_remittance_batch_date;
    l_remitted_late := TRUE;
    l_event_date    := pg_remittance_batch_date + NVL(pg_risk_elimination_days,0);

  ELSE
    l_cutoff_date   := pg_BR_rec.maturity_date;
    l_remitted_late := FALSE;
    l_event_date    := pg_BR_rec.maturity_date;
  END IF;

 /*-------------------------------------------------------------------------------+
  | Check whether Effective date has passed maturity date + risk elimination days |
  +-------------------------------------------------------------------------------*/
  IF trunc(pg_effective_date) < (trunc(l_cutoff_date) + NVL(pg_risk_elimination_days,0)) THEN

   /*---------------------------------------------------------------------+
    | Effective date has NOT passed maturity date + risk elimination days |
    +---------------------------------------------------------------------*/

    IF trunc(pg_effective_date) < trunc(l_cutoff_date) THEN

     /*------------------------------------------------------------+
      | Effective date is earlier than the cutoff date, do nothing |
      +------------------------------------------------------------*/
      NULL;

    ELSE

     /*--------------------------------------------------------+
      | Effective date is earlier than the cutoff date + risk, |
      | but later than l_cutoff_date date. Move VAT if needed  |
      +--------------------------------------------------------*/

      IF pg_BR_rec.status = 'FACTORED' THEN

        /*--------------------------------------------------------------+
         | Bill has matured and maturity event has not yet taken place, |
         | move deferred tax as part of MATURITY_DATE transaction       |
         | history record. Deferred tax is only moved if tax to be moved|
         | exists and the BR was not remitted late                      |
         +--------------------------------------------------------------*/
        IF pg_deferred_tax_exists AND NOT l_remitted_late THEN
          l_move_deferred_tax := 'Y';
        ELSE
          l_move_deferred_tax := 'N';
        END IF;

        create_maturity_date_event(l_move_deferred_tax,l_event_date);

      END IF; /* status = FACTORED */

    END IF; /* cutoff past effective */

  ELSE

   /*---------------------------------------------------------------+
    | Effective date has passed cutoff date + risk elimination days |
    +---------------------------------------------------------------*/
   /*---------------------------------------------------------------+
    | The maturity event has not yet happened, so STD application   |
    | is reversed and a normal application is done. Deferred Tax is |
    | moved as part of the application. Deferred tax is only moved  |
    | if tax to be moved exists. Non-postable maturity date event   |
    | is created to be consistent                                   |
    +--------------------------------------------------------------*/

    IF pg_deferred_tax_exists THEN
      l_move_deferred_tax := 'Y';
    ELSE
      l_move_deferred_tax := 'N';
    END IF;

    IF pg_BR_rec.status = 'FACTORED' THEN

      create_maturity_date_event('N',l_event_date);

    ELSE /* The status must be Matured pending risk elimination */

      /*---------------------------------------------------------------+
       | If maturity date event exists and it was postable, do not move|
       | deferred tax again                                            |
       +---------------------------------------------------------------*/
      IF prev_trh_rec.event = 'MATURITY_DATE' AND prev_trh_rec.postable_flag = 'Y' THEN

        l_move_deferred_tax := 'N';

      END IF;
    END IF;

   /*---------------------------------------------------------------+
    | Pass in the apply date for the application. If BR was remitted|
    | late we use the remittance batch date + risk elimination.     |
    | Otherwise we use the maturity date.                           |
    +---------------------------------------------------------------*/
    apply_Receipt(l_move_deferred_tax,l_event_date);

  END IF; /* cutoff past risk */

  write_debug_and_log( 'arp_br_housekeeper_pkg.process_factored()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.process_factored '||SQLERRM);
      RAISE;

END process_factored;

/*===========================================================================+
 | PROCEDURE process_endorsed                                                |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |  This procedure processes endorsed bills receivable transactions          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  NONE                                                    |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-JUN-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE process_endorsed IS

 /*---------------------------------------------+
  | Cursor to fetch last Endorsement adjustment |
  +---------------------------------------------*/
  CURSOR last_adjustment_cur IS
    select adj.*
    from ar_adjustments adj
    where adj.customer_trx_id = pg_BR_rec.customer_trx_id
    and   adj.status = 'W'
    order by adj.adjustment_id desc;

  last_adjustment_rec          ar_adjustments%ROWTYPE;

  l_move_deferred_tax          VARCHAR2(1) := 'Y';
  prev_trh_rec                 ar_transaction_history%ROWTYPE;

BEGIN

  write_debug_and_log( 'arp_br_housekeeper_pkg.process_endorsed()+' );

 /*-----------------------------------+
  | Fetch last Endorsement adjustment |
  +-----------------------------------*/
  OPEN last_adjustment_cur;
  FETCH last_adjustment_cur INTO last_adjustment_rec;

   /*---------------------------------------------+
    | If last Endorsement adjusment is not found, |
    | stop processing and raise an exception      |
    +---------------------------------------------*/
   IF last_adjustment_cur%NOTFOUND THEN

     write_debug_and_log( 'Last endorsement adjustment for Bills Receivable transaction cannot be found' );
     CLOSE last_adjustment_cur;
     APP_EXCEPTION.raise_exception;

   END IF;

  CLOSE last_adjustment_cur;

 /*-------------------------------------------------+
  | Fetch information from the receivable activity  |
  | The procedure populates a package global record |
  | with the data, accessible to all sub procedures |
  +-------------------------------------------------*/
  arp_br_housekeeper_pkg.fetch_endorsement_setup_data(last_adjustment_rec.receivables_trx_id);

 /*-------------------------------------------------+
  | Fetch information on the previous posted        |
  | transaction record for this BR. This information|
  | is used to decide what processing is needed for |
  | the Bills Receivable.                           |
  +-------------------------------------------------*/
  arp_br_housekeeper_pkg.prev_posted_trh(pg_BR_rec.transaction_history_id,
                                         prev_trh_rec);

 /*--------------------------------------------------------------------+
  | Check whether we have passed maturity date + risk_elimination_days |
  | and branch the code accordingly                                    |
  +--------------------------------------------------------------------*/

 /*--------------------------------------------------------+
  | Check whether we have endorsed after the maturity date |
  | and branch the code accordingly                        |
  +--------------------------------------------------------*/
  IF trunc(last_adjustment_rec.apply_date) >= trunc(pg_BR_rec.maturity_date) THEN

   /*--------------------------------------------------------------------+
    | Check whether we have passed endorsed date + risk_elimination_days |
    | and branch the code accordingly                                    |
    +--------------------------------------------------------------------*/
    IF trunc(pg_effective_date) < (trunc(last_adjustment_rec.apply_date) + NVL(pg_risk_elimination_days,0)) THEN

       /*----------------------------------------------------+
        | BR was endorsed after maturity and endorsed date   |
        | has not passed risk elimination days, do nothing   |
        +----------------------------------------------------*/
        write_debug_and_log('Bills Receivable was endorsed after maturity date and endorsement date ' ||
                            'has not passed risk elimination days, Bills receivable not processed ');

    ELSE

     /*----------------------------------------------------------------+
      | BR was endorsed after maturity and endorsement date has passed |
      | risk elimination days. Approve the adjustment, deferred        |
      | tax is moved as part of the adjustment. Deferred tax is only   |
      | moved if tax to be moved exists.                               |
      +----------------------------------------------------------------*/
      IF pg_deferred_tax_exists THEN
        l_move_deferred_tax := 'Y';
      ELSE
        l_move_deferred_tax := 'N';
      END IF;

      IF prev_trh_rec.event = 'MATURITY_DATE' AND prev_trh_rec.postable_flag = 'Y' THEN

        l_move_deferred_tax := 'N';

      END IF;

     /*-------------------------------------+
      | Approve the endorsement adjustment  |
      +-------------------------------------*/
      approve_Adjustment(last_adjustment_rec,l_move_deferred_tax);

    END IF; /* endorsement date past effective */

  ELSE

   /*---------------------------------+
    | BR was endorsed before maturity |
    +---------------------------------*/
   /*--------------------------------------------------------------------+
    | Check whether we have passed maturity date + risk_elimination_days |
    | and branch the code accordingly                                    |
    +--------------------------------------------------------------------*/
    IF trunc(pg_effective_date) < (trunc(pg_BR_rec.maturity_date) + NVL(pg_risk_elimination_days,0)) THEN

     /*---------------------------------------------------------------------+
      | Effective date has NOT passed maturity date + risk elimination days |
      +---------------------------------------------------------------------*/

      IF trunc(pg_effective_date) < trunc(pg_BR_rec.maturity_date) THEN

       /*--------------------------------------------------------------+
        | Effective date is earlier than the maturity date, do nothing |
        +--------------------------------------------------------------*/
        NULL;

      ELSE

       /*----------------------------------------------------------+
        | Effective date is earlier than the maturity date + risk, |
        | but later than maturity date. Move VAT if needed         |
        +----------------------------------------------------------*/

        IF pg_deferred_tax_exists AND prev_trh_rec.event <> 'MATURITY_DATE' THEN

          create_maturity_date_event('Y',pg_BR_rec.maturity_date);

        END IF;

      END IF;
    ELSE

     /*----------------------------------------------------------+
      | BR was endorsed before maturity and effective date is    |
      | later than the maturity date + risk                      |
      +----------------------------------------------------------*/
     /*-------------------------------------+
      | Approve the endorsement adjustment  |
      | Move VAT if needed                  |
      +-------------------------------------*/

      IF pg_deferred_tax_exists AND prev_trh_rec.event <> 'MATURITY_DATE' THEN
        l_move_deferred_tax := 'Y';
      ELSE
        l_move_deferred_tax := 'N';
      END IF;

      approve_Adjustment(last_adjustment_rec,l_move_deferred_tax);

    END IF; /* effective date before maturity + risk */

  END IF; /* endorsed after maturity */

  write_debug_and_log( 'arp_br_housekeeper_pkg.process_endorsed()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.process_endorsed '||SQLERRM);
      RAISE;

END process_endorsed;


/*===========================================================================+
 | PROCEDURE create_and_apply_Receipt                                        |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Creates and applies a receipt to BR document on payment event. Moves   |
 |    deferred tax if parameter p_move_deferred_tax is given as 'Y'.         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_move_deferred_tax - Indicates whether deferred tax is |
 |                                         moved.                            |
 |                   p_receipt_date      - Date to be used for the receipt   |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Jani Rautiainen      Created                             |
 |     30_APR-2001  V Crisostomo         Bug 1759305 : for rate types <> User|
 |					 pass a null exchange rate	     |
 |     25-MAY-2005  V Crisostomo	 SSA-R12 : add org_id                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE create_and_apply_Receipt(p_move_deferred_tax         IN VARCHAR2 DEFAULT 'Y',
                                   p_receipt_date              IN DATE) IS

 /*----------------------------------------+
  | Cursor to fetch BR related information |
  +----------------------------------------*/

  /*
     Bug 1759305 : Receipt API expects an exchange rate ONLY when
     exchange_rate_type = 'User', for all other exchange_rate_type values,
     the exchange_rate should be null since the receipt API handles reading
     the rate from the database
  */

  CURSOR BR_cur IS
  SELECT ps.invoice_currency_code,
         ps.exchange_rate_type,
         decode(ps.exchange_rate_type,'User',ps.exchange_rate,null) exchange_rate,
         ps.exchange_date,
         ps.customer_id,
         ps.customer_trx_id,
         ps.payment_schedule_id,
         ps.amount_due_remaining,
         ct.drawee_site_use_id,
         ct.override_remit_account_flag,
         ct.remit_bank_acct_use_id,
         ct.customer_bank_account_id,
         ct.trx_number,
         ct.term_due_date maturity_date,
         ct.org_id
  FROM ra_customer_trx ct, ar_payment_schedules ps
  WHERE ct.customer_trx_id = pg_BR_rec.customer_trx_id
  AND   ps.customer_trx_id = ct.customer_trx_id;

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_cr_id                    NUMBER;
  l_receipt_number           ar_cash_receipts.receipt_number%TYPE;
  l_receipt_date             DATE;
  BR_rec                     BR_cur%ROWTYPE;
  l_trh_rec                  ar_transaction_history%ROWTYPE;
  l_transaction_history_id   ar_transaction_history.transaction_history_id%TYPE;
  l_default_gl_date          DATE;
  l_org_return_status        VARCHAR2(1);
  l_org_id                   NUMBER;

BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.create_and_apply_Receipt()+' );


  BEGIN

  /*------------------------------+
   | Fetch BR related information |
   +------------------------------*/
   OPEN BR_cur;
   FETCH BR_cur INTO BR_rec;

  /*------------------------------------------------------------+
   | If BR is not found, stop processing and raise an exception |
   +------------------------------------------------------------*/
   IF BR_cur%NOTFOUND THEN

     write_debug_and_log( 'Bills Receivable transaction cannot be found' );
     CLOSE BR_cur;
     APP_EXCEPTION.raise_exception;

   END IF;

   CLOSE BR_cur;

   /* SSA change */
   l_org_id := BR_Rec.org_id;
   l_org_return_status := FND_API.G_RET_STS_SUCCESS;
   ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                            p_return_status =>l_org_return_status);

   IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      write_debug_and_log('arp_br_housekeeper_pkg.create_and_apply_Receipt : l_org_return_status <> SUCCESS');
      RAISE API_exception;
   ELSE

  /*-------------------------------------------+
   | Check if receipt number inherited from BR |
   | If not inherited, the Receipt API will    |
   | default it from sequence                  |
   +-------------------------------------------*/
   IF NVL(pg_rct_inherit_inv_num_flag,'N') = 'Y' THEN
     write_debug_and_log( 'pg_rct_inherit_inv_num_flag = Y ' );

     l_receipt_number := BR_rec.trx_number;

     write_debug_and_log( 'l_receipt_number = '||l_receipt_number );

   END IF;

   l_default_gl_date := arp_br_housekeeper_pkg.validate_against_doc_gl_date(pg_gl_date,
                                                                            pg_BR_rec.gl_date);

  /*--------------------------------------------------------+
   | Receipt date, apply date, deposit date and receipt     |
   | maturity date are BR maturity_date if the BR was       |
   | remitted before maturity. If the BR was remitted after |
   | maturity date then the remittance batch date +         |
   | collection days is used.                               |
   +--------------------------------------------------------*/
   l_receipt_date := p_receipt_date;

   write_debug_and_log( 'l_receipt_date = '||to_char(l_receipt_date));


  /*------------------------------------------------+
   | Call Receipt API to create and apply a receipt |
   +------------------------------------------------*/
   AR_RECEIPT_API_PUB.Create_and_apply(
      p_api_version                  => 1.0,
      p_init_msg_list                => FND_API.G_TRUE,
      x_return_status                => l_return_status,
      x_msg_count                    => l_msg_count,
      x_msg_data                     => l_msg_data,
      p_currency_code                => BR_rec.invoice_currency_code,
      p_exchange_rate_type           => BR_rec.exchange_rate_type,
      p_exchange_rate                => BR_rec.exchange_rate,
      p_exchange_rate_date           => BR_rec.exchange_date,
      p_amount                       => BR_rec.amount_due_remaining,
      p_receipt_number               => l_receipt_number,
      p_receipt_date                 => l_receipt_date,
      p_gl_date                      => l_default_gl_date,
      p_maturity_date                => l_receipt_date,
      p_called_from                  => pg_called_from,
      p_customer_id                  => BR_rec.customer_id,
      p_customer_bank_account_id     => BR_rec.customer_bank_account_id,
      p_customer_site_use_id         => BR_rec.drawee_site_use_id,
      p_override_remit_account_flag  => BR_rec.override_remit_account_flag,
      p_remittance_bank_account_id   => pg_remit_bank_acct_use_id,
      p_deposit_date                 => l_receipt_date,
      p_receipt_method_id            => pg_receipt_method_id,
      p_cr_id		             => l_cr_id,
      p_customer_trx_id              => BR_rec.customer_trx_id,
      p_applied_payment_schedule_id  => BR_rec.payment_schedule_id,
      p_amount_applied               => BR_rec.amount_due_remaining,
      p_apply_date                   => l_receipt_date,
      p_apply_gl_date                => l_default_gl_date,
      p_move_deferred_tax            => p_move_deferred_tax,
      p_org_id                       => BR_rec.org_id);

 /*------------------------------------------------+
  | Write API output to the concurrent program log |
  +------------------------------------------------*/
  IF NVL(l_msg_count,0)  > 0 Then

      /* Bug 1855821 : indicate in the log file the receipt API procedure that raised the error */
      write_debug_and_log('API error count : AR_RECEIPT_API_PUB.Create_and_apply : '||to_char(NVL(l_msg_count,0)));

      write_API_output(l_msg_count,l_msg_data);

  END IF;

 /*-----------------------------------------------------+
  | If API return status is not SUCCESS raise exception |
  +-----------------------------------------------------*/
  IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

   /*-----------------------------------------------------+
    | Success update the batch id on the current cash     |
    | receipt history record.                             |
    +-----------------------------------------------------*/
    arp_br_remit_batches.update_br_remit_batch_to_crh(l_cr_id,pg_BR_rec.reserved_value);

  ELSE
   /*---------------------------+
    | Error, raise an exception |
    +---------------------------*/
    RAISE API_exception;

  END IF;
  END IF; /* l_org_return_status <> FND_API.G_RET_STS_SUCCESS */

 /*----------------------------------+
  | APIs propagate exception upwards |
  +----------------------------------*/
  EXCEPTION
    WHEN API_exception THEN
      write_debug_and_log('API Exception: arp_br_housekeeper_pkg.create_and_apply_Receipt '||SQLERRM);
      RAISE;

    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.create_and_apply_Receipt '||SQLERRM);
      RAISE;

  END;

 /*-----------------------------------------------------------------+
  |  Payment schedule was closed, create transaction history record |
  +-----------------------------------------------------------------*/

 /*--------------------------------------------+
  |  Initialize the transaction history record |
  +--------------------------------------------*/
  IF l_org_return_status = FND_API.G_RET_STS_SUCCESS THEN
  l_trh_rec.customer_trx_id          := pg_BR_rec.customer_trx_id;
  l_trh_rec.status                   := 'CLOSED';
  l_trh_rec.event                    := 'CLOSED';
  l_trh_rec.batch_id                 := NULL;
  l_trh_rec.trx_date                 := l_receipt_date;
  l_trh_rec.gl_date                  := l_default_gl_date;
  l_trh_rec.current_record_flag      := 'Y';
  l_trh_rec.current_accounted_flag   := 'N';
  l_trh_rec.postable_flag            := 'N';
  l_trh_rec.first_posted_record_flag := 'N';
  l_trh_rec.posting_control_id       := -3;
  l_trh_rec.gl_posted_date           := NULL;
  l_trh_rec.prv_trx_history_id       := NULL;
  l_trh_rec.created_from             := 'ARRBRHKB';
  l_trh_rec.comments                 := NULL;
  l_trh_rec.maturity_date            := pg_BR_rec.maturity_date;
  l_trh_rec.org_id                   := pg_BR_rec.org_id;

 /*----------------------------------------+
  |  Insert the transaction history record |
  +----------------------------------------*/
  ARP_PROC_TRANSACTION_HISTORY.insert_transaction_history(l_trh_rec,
                                                          l_transaction_history_id);

  END IF; /* l_org_return_status <> FND_API.G_RET_STS_SUCCESS */

  write_debug_and_log( 'arp_br_housekeeper_pkg.create_and_apply_Receipt()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.create_and_apply_Receipt'||SQLERRM);
      RAISE;

END create_and_apply_Receipt;

/*===========================================================================+
 | PROCEDURE approve_Adjustment                                              |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Approves adjusment (endorsement) related to BR document on risk        |
 |    elimination event. Moves deferred tax if parameter p_move_deferred_tax |
 |    is given as 'Y'.                                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_move_deferred_tax - Indicates whether deferred tax is |
 |                                         moved.                            |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE approve_Adjustment(p_adjustment_rec    IN OUT NOCOPY ar_adjustments%ROWTYPE,
                             p_move_deferred_tax IN     VARCHAR2 DEFAULT 'Y') IS

  l_adj_rec            ar_adjustments%rowtype;
  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);

  l_trh_rec                  ar_transaction_history%ROWTYPE;
  l_transaction_history_id   ar_transaction_history.transaction_history_id%TYPE;
  l_default_gl_date          DATE;
  l_event_date               DATE;

  l_org_return_status        VARCHAR2(1);
  l_org_id                   NUMBER;
BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.approve_Adjustment()+' );

  /* SSA change */
  l_org_id := p_adjustment_rec.org_id;
  l_org_return_status := FND_API.G_RET_STS_SUCCESS;
  ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                           p_return_status =>l_org_return_status);

  IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     write_debug_and_log('arp_br_housekeeper_pkg.approve_adjustment : l_org_return_status <> SUCCESS');
     RAISE API_exception;
  ELSE

 /*--------------------------------------------------------+
  | Check whether we have endorsed after the maturity date |
  | and set the event data accordingly                     |
  +--------------------------------------------------------*/
  IF trunc(p_adjustment_rec.apply_date) >= trunc(pg_BR_rec.maturity_date) THEN

    l_event_date                := p_adjustment_rec.apply_date + NVL(pg_risk_elimination_days,0);
    p_adjustment_rec.apply_date := p_adjustment_rec.apply_date + NVL(pg_risk_elimination_days,0);

  ELSE

    l_event_date                := pg_BR_rec.maturity_date + NVL(pg_risk_elimination_days,0);
    p_adjustment_rec.apply_date := pg_BR_rec.maturity_date;

  END IF;

 /*----------------------------------------------+
  | Check that the GL date on the adjustment is  |
  | still valid. If it is not then try to default|
  | the gl date given to the housekeeper by the  |
  | user. If that is also invalid default to the |
  | next available open period.                  |
  +----------------------------------------------*/
  l_default_gl_date := arp_br_housekeeper_pkg.validate_and_default_gl_date(p_adjustment_rec.gl_date,
                                                                           NULL,NULL,NULL,NULL,
                                                                           pg_gl_date,
                                                                           NULL,NULL);

 /*----------------------------------------------+
  | The GL date might be updated give the        |
  | adjustment record as parameter to the API    |
  +----------------------------------------------*/
  IF l_default_gl_date IS NOT NULL THEN

    l_adj_rec         := p_adjustment_rec;
    l_adj_rec.status  := 'A';
    l_adj_rec.gl_date := l_default_gl_date;

  END IF;

  BEGIN
   /*----------------------------------------------+
    | Call Adjustment API to approve an adjustment |
    +----------------------------------------------*/
    ar_adjust_pub.approve_Adjustment (
      p_api_name          => 'AR_ADJUST_PUB',
      p_api_version       => 1.0,
      p_init_msg_list     => FND_API.G_TRUE,
      p_msg_count         => l_msg_count,
      p_msg_data          => l_msg_data,
      p_return_status     => l_return_status,
      p_adj_rec             => l_adj_rec,
      p_chk_approval_limits => FND_API.G_FALSE,
      p_move_deferred_tax   => p_move_deferred_tax,
      p_old_adjust_id       => p_adjustment_rec.adjustment_id,
      p_org_id              => p_adjustment_rec.org_id);

   /*------------------------------------------------+
    | Write API output to the concurrent program log |
    +------------------------------------------------*/
    IF NVL(l_msg_count,0)  > 0 Then

        /* Bug 1855821 :
           the errors raised here are from Adjustment API, but since this is similar to the
           Receipt API call, I am applying the same code changes done for Receipt API where
           I am printing more information in the log file */
        write_debug_and_log('API error count : AR_ADJUST_PUB.approve_adjustment : '||to_char(NVL(l_msg_count,0)));

        write_API_output(l_msg_count,l_msg_data);

    END IF;

 /*-----------------------------------------------------+
  | If API return status is not SUCCESS raise exception |
  +-----------------------------------------------------*/
  IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

   /*-----------------------------------------------------+
    | Success do nothing, else branch introduced to make  |
    | sure that NULL case will also raise exception       |
    +-----------------------------------------------------*/
    NULL;

  ELSE
   /*---------------------------+
    | Error, raise an exception |
    +---------------------------*/
    RAISE API_exception;

  END IF;

 /*----------------------------------+
  | APIs propagate exception upwards |
  +----------------------------------*/
    EXCEPTION
      WHEN API_exception THEN
        write_debug_and_log('API Exception: arp_br_housekeeper_pkg.create_and_apply_Receipt '||SQLERRM);
        RAISE;

      WHEN OTHERS THEN
        write_debug_and_log('Exception: arp_br_housekeeper_pkg.create_and_apply_Receipt '||SQLERRM);
        RAISE;

  END;

 /*-----------------------------------------------------------------+
  |  Payment schedule was closed, create transaction history record |
  +-----------------------------------------------------------------*/

 /*--------------------------------------------+
  |  Initialize the transaction history record |
  +--------------------------------------------*/
  l_trh_rec.customer_trx_id          := pg_BR_rec.customer_trx_id;
  l_trh_rec.status                   := 'CLOSED';
  l_trh_rec.event                    := 'RISK_ELIMINATED';
  l_trh_rec.batch_id                 := NULL;
  l_trh_rec.trx_date                 := l_event_date;
  l_trh_rec.gl_date                  := l_adj_rec.gl_date;
  l_trh_rec.current_record_flag      := 'Y';
  l_trh_rec.current_accounted_flag   := 'N';
  l_trh_rec.postable_flag            := 'N';
  l_trh_rec.first_posted_record_flag := 'N';
  l_trh_rec.posting_control_id       := -3;
  l_trh_rec.gl_posted_date           := NULL;
  l_trh_rec.prv_trx_history_id       := NULL;
  l_trh_rec.created_from             := 'ARRBRHKB';
  l_trh_rec.comments                 := NULL;
  l_trh_rec.maturity_date            := pg_BR_rec.maturity_date;
  l_trh_rec.org_id                   := pg_BR_rec.org_id;

 /*----------------------------------------+
  |  Insert the transaction history record |
  +----------------------------------------*/
  ARP_PROC_TRANSACTION_HISTORY.insert_transaction_history(l_trh_rec,
                                                          l_transaction_history_id);

  END IF;  /* l_org_return_status <> FND_API.G_RET_STS_SUCCESS */

  write_debug_and_log( 'arp_br_housekeeper_pkg.approve_Adjustment()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.approve_Adjustment'||SQLERRM);
      RAISE;

END approve_Adjustment;

/*===========================================================================+
 | PROCEDURE apply_Receipt                                                   |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Unapplies BR document from Short Term Debt and creates normal          |
 |    application on risk elimination event. Moves deferred tax if parameter |
 |    p_move_deferred_tax is given as 'Y'.                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_move_deferred_tax - Indicates whether deferred tax is |
 |                                         moved.                            |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE apply_Receipt(p_move_deferred_tax         VARCHAR2 DEFAULT 'Y',
                        p_receipt_date              IN DATE) IS

 /*--------------------------------------------------+
  | Cursor to fetch last Short Term Debt application |
  +--------------------------------------------------*/
  CURSOR last_std_application_cur IS
    select rap.receivable_application_id, rap.cash_receipt_id, rap.gl_date, rap.apply_date,
           rap.org_id
    from ar_receivable_applications rap
    where rap.link_to_customer_trx_id     = pg_BR_rec.customer_trx_id
    and   rap.status                      = 'ACTIVITY'
    and   rap.applied_payment_schedule_id = -2
    and   rap.display                     = 'Y'
    order by rap.receivable_application_id desc;

  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
  l_apply_date     DATE;

  last_std_application_rec   last_std_application_cur%ROWTYPE;
  l_trh_rec                  ar_transaction_history%ROWTYPE;
  l_transaction_history_id   ar_transaction_history.transaction_history_id%TYPE;
  l_default_gl_date          DATE;
  l_event_date               DATE;

  l_org_return_status        VARCHAR2(1);
  l_org_id                   NUMBER;
BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.apply_Receipt()+' );

 /*------------------------+
  | Fetch last application |
  +------------------------*/
  OPEN last_std_application_cur;
  FETCH last_std_application_cur INTO last_std_application_rec;

 /*------------------------------------------------------------------+
  | If last STD is not found, stop processing and raise an exception |
  +------------------------------------------------------------------*/
  IF last_std_application_cur%NOTFOUND THEN

     write_debug_and_log( 'Last Short Term Debt application cannot be found' );
     CLOSE last_std_application_cur;
     APP_EXCEPTION.raise_exception;

   END IF;

  CLOSE last_std_application_cur;

  /* SSA change */
  l_org_id := last_std_application_rec.org_id;
  l_org_return_status := FND_API.G_RET_STS_SUCCESS;
  ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                           p_return_status =>l_org_return_status);

  IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     write_debug_and_log('arp_br_housekeeper_pkg.apply_receipt : l_org_return_status <> SUCCESS');
     RAISE API_exception;
  ELSE

  l_default_gl_date := arp_br_housekeeper_pkg.validate_against_doc_gl_date(pg_gl_date,
                                                                           last_std_application_rec.gl_date);
  BEGIN
   /*------------------------------------+
    | Unapply from STD using Receipt API |
    +------------------------------------*/

    AR_RECEIPT_API_PUB.Activity_unapplication(
      p_api_version                 => 1.0,
      p_init_msg_list               => FND_API.G_TRUE,
      x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data,
      p_cash_receipt_id             => last_std_application_rec.cash_receipt_id,
      p_receivable_application_id   => last_std_application_rec.receivable_application_id,
      p_reversal_gl_date            => l_default_gl_date,
      p_called_from                 => pg_called_from,
      p_org_id                      => last_std_application_rec.org_id);

   /*------------------------------------------------+
    | Write API output to the concurrent program log |
    +------------------------------------------------*/
    IF NVL(l_msg_count,0)  > 0 Then

        /* Bug 1855821 : indicate in the log file the receipt API procedure that raised the error */
        write_debug_and_log('API error count : AR_RECEIPT_API_PUB.Activity_unapplication : '||
                             to_char(NVL(l_msg_count,0)));
        write_API_output(l_msg_count,l_msg_data);

    END IF;

   /*-----------------------------------------------------+
    | If API return status is not SUCCESS raise exception |
    +-----------------------------------------------------*/
    IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

     /*-----------------------------------------------------+
      | Success do nothing, else branch introduced to make  |
      | sure that NULL case will also raise exception       |
      +-----------------------------------------------------*/
      NULL;

    ELSE
     /*---------------------------+
      | Error, raise an exception |
      +---------------------------*/
      RAISE API_exception;

    END IF;

   /*----------------------------------+
    | APIs propagate exception upwards |
    +----------------------------------*/
    EXCEPTION
      WHEN API_exception THEN
        write_debug_and_log('API Exception: arp_br_housekeeper_pkg.create_and_apply_Receipt '||SQLERRM);
        RAISE;

      WHEN OTHERS THEN
        write_debug_and_log('Exception: arp_br_housekeeper_pkg.apply_Receipt '||SQLERRM);
        RAISE;
  END;

  BEGIN

  /*-----------------------------------------------------+
   | Apply date is maturity_date + risk elimination days |
   +-----------------------------------------------------*/
   l_apply_date := p_receipt_date;

   IF trunc(last_std_application_rec.apply_date) > trunc(l_apply_date) THEN

     l_apply_date := last_std_application_rec.apply_date;

   END IF;

   /*---------------------------------------------+
    | Create normal application using Receipt API |
    +---------------------------------------------*/

    write_debug_and_log('will call AR_RECEIPT_API_PUB.Apply');

    AR_RECEIPT_API_PUB.Apply(
      p_api_version                 => 1.0,
      p_init_msg_list               => FND_API.G_TRUE,
      x_return_status               => l_return_status,
      x_msg_count                   => l_msg_count,
      x_msg_data                    => l_msg_data,
      p_cash_receipt_id             => last_std_application_rec.cash_receipt_id,
      p_customer_trx_id             => pg_BR_rec.customer_trx_id,
      p_applied_payment_schedule_id => pg_BR_rec.payment_schedule_id,
      p_amount_applied              => pg_BR_rec.amount_due_remaining,
      p_apply_date                  => l_apply_date,
      p_apply_gl_date               => l_default_gl_date,
      p_called_from                 => pg_called_from,
      p_move_deferred_tax           => p_move_deferred_tax,
      p_org_id                      => pg_BR_rec.org_id);

   /*------------------------------------------------+
    | Write API output to the concurrent program log |
    +------------------------------------------------*/
    IF NVL(l_msg_count,0)  > 0 Then

        /* Bug 1855821 : indicate in the log file the receipt API procedure that raised the error */
        write_debug_and_log('API error count : AR_RECEIPT_API_PUB.Apply : '|| to_char(NVL(l_msg_count,0)));

        write_API_output(l_msg_count,l_msg_data);

    END IF;

   /*-----------------------------------------------------+
    | If API return status is not SUCCESS raise exception |
    +-----------------------------------------------------*/
    IF l_return_status = FND_API.G_RET_STS_SUCCESS Then

     /*-----------------------------------------------------+
      | Success do nothing, else branch introduced to make  |
      | sure that NULL case will also raise exception       |
      +-----------------------------------------------------*/
      NULL;

    ELSE
     /*---------------------------+
      | Error, raise an exception |
      +---------------------------*/
      RAISE API_exception;

    END IF;



   /*----------------------------------+
    | APIs propagate exception upwards |
    +----------------------------------*/
    EXCEPTION
      WHEN API_exception THEN
        write_debug_and_log('API Exception: arp_br_housekeeper_pkg.create_and_apply_Receipt '||SQLERRM);
        RAISE;

      WHEN OTHERS THEN
        write_debug_and_log('Exception: arp_br_housekeeper_pkg.apply_Receipt '||SQLERRM);
        RAISE;
  END;

 /*-----------------------------------------------------------------+
  |  Payment schedule was closed, create transaction history record |
  +-----------------------------------------------------------------*/

 /*--------------------------------------------------------+
  | Check whether we have remitted after the maturity date |
  | and set the event data accordingly                     |
  +--------------------------------------------------------*/
  IF trunc(pg_remittance_batch_date) >= trunc(pg_BR_rec.maturity_date) THEN
    l_event_date    := pg_remittance_batch_date + NVL(pg_risk_elimination_days,0);
  ELSE
    l_event_date    := pg_BR_rec.maturity_date  + NVL(pg_risk_elimination_days,0);
  END IF;

 /*--------------------------------------------+
  |  Initialize the transaction history record |
  +--------------------------------------------*/
  l_trh_rec.customer_trx_id          := pg_BR_rec.customer_trx_id;
  l_trh_rec.status                   := 'CLOSED';
  l_trh_rec.event                    := 'RISK_ELIMINATED';
  l_trh_rec.batch_id                 := NULL;
  l_trh_rec.trx_date                 := l_event_date;
  l_trh_rec.gl_date                  := pg_gl_date;
  l_trh_rec.current_record_flag      := 'Y';
  l_trh_rec.current_accounted_flag   := 'N';
  l_trh_rec.postable_flag            := 'N';
  l_trh_rec.first_posted_record_flag := 'N';
  l_trh_rec.posting_control_id       := -3;
  l_trh_rec.gl_posted_date           := NULL;
  l_trh_rec.prv_trx_history_id       := NULL;
  l_trh_rec.created_from             := 'ARRBRHKB';
  l_trh_rec.comments                 := NULL;
  l_trh_rec.maturity_date            := pg_BR_rec.maturity_date;
  l_trh_rec.org_id                   := pg_BR_rec.org_id;

 /*----------------------------------------+
  |  Insert the transaction history record |
  +----------------------------------------*/
  ARP_PROC_TRANSACTION_HISTORY.insert_transaction_history(l_trh_rec,
                                                          l_transaction_history_id);


  END IF;  /* l_org_return_status <> FND_API.G_RET_STS_SUCCESS */

  write_debug_and_log( 'arp_br_housekeeper_pkg.apply_Receipt()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.apply_Receipt '||SQLERRM);
      RAISE;

END apply_Receipt;

/*===========================================================================+
 | PROCEDURE create_maturity_date_event                                      |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Create maturity date event in transaction history table.               |
 |    Moves deferred tax if parameter p_move_deferred_tax is given as 'Y'.   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_move_deferred_tax - Indicates whether deferred tax is |
 |                                         moved.                            |
 |                   p_event_date        - The date that the event occurs    |
 |              OUT:                                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE create_maturity_date_event(p_move_deferred_tax VARCHAR2 DEFAULT 'Y',
                                     p_event_date        DATE) IS

  l_trh_rec                ar_transaction_history%ROWTYPE;
  l_transaction_history_id ar_transaction_history.transaction_history_id%TYPE;
  l_event_date             DATE;
BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.create_maturity_date_event()+' );

 /*-----------------------+
  | fetch previous record |
  +-----------------------*/
  l_trh_rec.customer_trx_id := pg_BR_rec.customer_trx_id;

  ARP_TRANSACTION_HISTORY_PKG.fetch_f_trx_id(l_trh_rec);

 /*--------------------------------------------------------+
  | Check whether we have remitted after the maturity date |
  | and set the event data accordingly                     |
  +--------------------------------------------------------*/
  IF l_trh_rec.status = 'ENDORSED' THEN
      l_event_date    := pg_BR_rec.maturity_date;
  ELSE
    IF trunc(pg_remittance_batch_date) >= trunc(pg_BR_rec.maturity_date) THEN
      l_event_date    := pg_remittance_batch_date;
    ELSE
      l_event_date    := pg_BR_rec.maturity_date;
    END IF;
  END IF;

 /*----------------------------------------+
  | Fill in information for the new record |
  +----------------------------------------*/
  l_trh_rec.transaction_history_id   := NULL;
  l_trh_rec.event                    := 'MATURITY_DATE';
  l_trh_rec.batch_id                 := NULL;
  l_trh_rec.trx_date                 := l_event_date;
  l_trh_rec.gl_date                  := pg_BR_rec.maturity_date;
  l_trh_rec.current_record_flag      := 'Y';
  l_trh_rec.first_posted_record_flag := 'N';
  l_trh_rec.posting_control_id       := -3;
  l_trh_rec.gl_posted_date           := NULL;
  l_trh_rec.prv_trx_history_id       := NULL;
  l_trh_rec.created_from             := 'ARRBRHKB';
  l_trh_rec.comments                 := NULL;
  l_trh_rec.maturity_date            := pg_BR_rec.maturity_date;
  l_trh_rec.org_id                   := pg_BR_rec.org_id;

 /*--------------------------------------------+
  | The status changes for maturity date event |
  | only for BRs factored with recource        |
  +--------------------------------------------*/
  IF l_trh_rec.status = 'FACTORED' THEN
    l_trh_rec.status := 'MATURED_PEND_RISK_ELIMINATION';
  END IF;

 /*---------------------------------------------+
  | Maturity date event has only deferred tax   |
  | accounting under it. So if tax is not moved |
  | the record is not postable.                 |
  +---------------------------------------------*/
  IF p_move_deferred_tax = 'Y' THEN
    l_trh_rec.postable_flag            := 'Y';
    l_trh_rec.current_accounted_flag   := 'Y';
  ELSE
    l_trh_rec.postable_flag            := 'N';
    l_trh_rec.current_accounted_flag   := 'N';
  END IF;

 /*--------------------------------------------------+
  | Call TRH entity handler with event MATURITY_DATE |
  +--------------------------------------------------*/
  ARP_PROC_TRANSACTION_HISTORY.insert_transaction_history(l_trh_rec,
                                                          l_transaction_history_id,
                                                          p_move_deferred_tax);

  write_debug_and_log( 'arp_br_housekeeper_pkg.create_maturity_date_event()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.create_maturity_date_event '||SQLERRM);
      RAISE;

END create_maturity_date_event;

/*===========================================================================+
 | PROCEDURE prev_posted_trh                                                 |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    This function fetches the previous posted transaction history record   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN                                                           |
 |               p_transaction_history_id - BR transaction history_id        |
 |                                                                           |
 |              OUT                                                          |
 |               p_trh_rec - BR transaction history record                   |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-JUN-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE prev_posted_trh(p_transaction_history_id IN  ar_transaction_history.transaction_history_id%TYPE,
                          p_trh_rec                OUT NOCOPY ar_transaction_history%ROWTYPE) IS

 /*------------------------------------------------------------+
  | Cursor to fetch previous posted transaction history record |
  +------------------------------------------------------------*/
  CURSOR prev_trh_cur IS
    select th.*
    from ar_transaction_history th
    where (postable_flag = 'Y' or event = 'MATURITY_DATE')
    connect by prior prv_trx_history_id = transaction_history_id
    start with transaction_history_id = p_transaction_history_id
    order by transaction_history_id desc;

BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.prev_posted_trh()+' );

 /*--------------------------------------------------+
  | Fetch previous posted transaction history record |
  +--------------------------------------------------*/
  OPEN prev_trh_cur;
  FETCH prev_trh_cur INTO p_trh_rec;

 /*-------------------------------------------------------------+
  | If previous posted transaction history record is not found, |
  | stop processing and raise an exception                      |
  +-------------------------------------------------------------*/
  IF prev_trh_cur%NOTFOUND THEN
    write_debug_and_log( 'Previous transaction history record cannot be found' );
    CLOSE prev_trh_cur;
    APP_EXCEPTION.raise_exception;
  END IF;

  CLOSE prev_trh_cur;

  write_debug_and_log( 'arp_br_housekeeper_pkg.prev_posted_trh()-' );

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.prev_posted_trh '||SQLERRM);
      RAISE;

END prev_posted_trh;

/*===========================================================================+
 | PROCEDURE fetch_remittance_setup_data                                     |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    This function fetches Bills Receivable transaction setup data          |
 |    ie recovery days used by remittance                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN                                                           |
 |               p_status   - BR transaction status                          |
 |               p_batch_id - Batch ID for remittance                        |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-JUN-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_remittance_setup_data(p_status             IN ar_transaction_history.status%TYPE,
                                      p_batch_id           IN ar_batches.batch_id%TYPE DEFAULT NULL) IS
 /*------------------------------------------------+
  | Fetch remittance data from BR remittance batch |
  +------------------------------------------------*/
  CURSOR remittance_setup_cur IS
    SELECT NVL(rma.br_collection_days,0) collection_days,
           NVL(rma.risk_elimination_days,0) risk_elimination_days,
           rm.receipt_inherit_inv_num_flag,
           ab.receipt_method_id,
           ab.remit_bank_acct_use_id,
           ab.batch_date
    FROM ar_batches ab, ar_receipt_method_accounts rma, ar_receipt_methods rm
    WHERE ab.batch_id           = p_batch_id
    and   rma.remit_bank_acct_use_id   = ab.remit_bank_acct_use_id
    and   rma.receipt_method_id = ab.receipt_method_id
    and   rm.receipt_method_id  = ab.receipt_method_id;

  remittance_setup_rec   remittance_setup_cur%ROWTYPE;

BEGIN

  write_debug_and_log( 'arp_br_housekeeper_pkg.fetch_remittance_setup_data()' );

 /*-----------------------------+
  | Fetch remittance setup data |
  +-----------------------------*/
  OPEN remittance_setup_cur;
  FETCH remittance_setup_cur INTO remittance_setup_rec;

 /*----------------------------------------+
  | If remittance batch is not found, stop |
  | processing and raise an exception      |
  +----------------------------------------*/
  IF remittance_setup_cur%NOTFOUND THEN

    write_debug_and_log( 'Previous transaction history record cannot be found' );
    CLOSE remittance_setup_cur;
    APP_EXCEPTION.raise_exception;

  END IF;

  CLOSE remittance_setup_cur;

  IF p_status = 'REMITTED' THEN

   /*--------------------------------------------------------------------+
    | If processing BR with status REMITTED the collections days is used |
    +--------------------------------------------------------------------*/
    pg_collection_days              := remittance_setup_rec.collection_days;
    pg_risk_elimination_days        := NULL;

  ELSIF p_status = 'FACTORED' or p_status = 'MATURED_PEND_RISK_ELIMINATION' THEN

   /*-------------------------------------------------------------------------+
    | If processing BR with status FACTORED the risk elimination days is used |
    +-------------------------------------------------------------------------*/
    pg_collection_days              := NULL;
    pg_risk_elimination_days        := remittance_setup_rec.risk_elimination_days;

  ELSE

    write_debug_and_log( 'Status '|| p_status ||' not supported' );
    APP_EXCEPTION.raise_exception;

  END IF;

 /*--------------------------------------------+
  | Copy values to package global variables to |
  | make them visible to the sub procedures    |
  +--------------------------------------------*/
  pg_rct_inherit_inv_num_flag := remittance_setup_rec.receipt_inherit_inv_num_flag;
  pg_receipt_method_id        := remittance_setup_rec.receipt_method_id;
  pg_remit_bank_acct_use_id   := remittance_setup_rec.remit_bank_acct_use_id;
  pg_remittance_batch_date    := remittance_setup_rec.batch_date;

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.fetch_remittance_setup_data '||SQLERRM);
      RAISE;

END fetch_remittance_setup_data;

/*===========================================================================+
 | PROCEDURE fetch_endorsement_setup_data                                    |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    This function fetches Bills Receivable transaction setup data          |
 |    ie recovery days used by endorsement                                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN                                                           |
 |               p_receivables_trx_id - Receivable activity for endorsement  |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     30-JUN-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE fetch_endorsement_setup_data(p_receivables_trx_id IN ar_receivables_trx.receivables_trx_id%TYPE) IS

 /*--------------------------------+
  | Fetch receivable activity data |
  +--------------------------------*/
  CURSOR endorsement_setup_cur IS
    SELECT NVL(rt.risk_elimination_days,0) risk_elimination_days
    FROM  ar_receivables_trx rt
    WHERE rt.receivables_trx_id = p_receivables_trx_id;

  endorsement_setup_rec endorsement_setup_cur%ROWTYPE;

BEGIN

  write_debug_and_log( 'arp_br_housekeeper_pkg.fetch_endorsement_setup_data()' );

 /*----------------------------------------+
  | Fetch receivable activity setup_data   |
  +----------------------------------------*/
  OPEN endorsement_setup_cur;
  FETCH endorsement_setup_cur INTO endorsement_setup_rec;

 /*-------------------------------------------+
  | If receivable activity is not found, stop |
  | processing and raise an exception         |
  +-------------------------------------------*/
  IF endorsement_setup_cur%NOTFOUND THEN

    write_debug_and_log( 'Endorsement receivable activity cannot be found' );
    CLOSE endorsement_setup_cur;
    APP_EXCEPTION.raise_exception;

  END IF;

  CLOSE endorsement_setup_cur;

 /*--------------------------------------------+
  | Copy values to package global variables to |
  | make them visible to the sub procedures    |
  +--------------------------------------------*/
  pg_collection_days              := NULL;
  pg_risk_elimination_days        := endorsement_setup_rec.risk_elimination_days;
  pg_rct_inherit_inv_num_flag     := NULL;
  pg_receipt_method_id            := NULL;
  pg_remit_bank_acct_use_id       := NULL;

  EXCEPTION
    WHEN OTHERS THEN
      write_debug_and_log('Exception: arp_br_housekeeper_pkg.fetch_endorsement_setup_data '||SQLERRM);
      RAISE;

END fetch_endorsement_setup_data;

/*===========================================================================+
 | PROCEDURE write_API_output                                                |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Writes API output to the concurrent program log. Messages from the     |
 |    API can contain warnings and errors                                    |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_msg_count  - Number of messages from the API          |
 |                   p_msg_data   - Actual messages from the API             |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE write_API_output(p_msg_count        IN NUMBER,
                           p_msg_data         IN VARCHAR2) IS

  l_msg_data       VARCHAR2(2000);
BEGIN

  IF p_msg_count  = 1 Then
   /*------------------------------------------------+
    | There is one message returned by the API, so it|
    | has been sent out in the parameter x_msg_data  |
    +------------------------------------------------*/
    write_debug_and_log(p_msg_data);

  ELSIF p_msg_count > 1 Then
   /*-------------------------------------------------------+
    | There are more than one messages returned by the API, |
    | so call them in a loop and print the messages         |
    +-------------------------------------------------------*/

    FOR l_count IN 1..p_msg_count LOOP

         l_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
         write_debug_and_log(to_char(l_count)||' : '||l_msg_data);

    END LOOP;

  END IF;

EXCEPTION
  WHEN others THEN
   /*-------------------------------------------------------+
    | Error writing to the log, nothing we can do about it. |
    | Error is not raised since API messages also contain   |
    | non fatal warnings. If a real exception happened it   |
    | is handled on the calling routine.                    |
    +-------------------------------------------------------*/
    NULL;

END write_API_output;

/*===========================================================================+
 | PROCEDURE write_debug_and_log                                             |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Writes standard messages to standard debugging and to the log          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:  p_message - Message to be writted                       |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     17-APR-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
PROCEDURE write_debug_and_log(p_message IN VARCHAR2) IS

BEGIN

 /*------------------------------------------------+
  | Write the message to log and to the standard   |
  | debugging channel                              |
  +------------------------------------------------*/
  IF FND_GLOBAL.CONC_REQUEST_ID is not null THEN

   /*------------------------------------------------+
    | Only write to the log if call was made from    |
    | concurrent program.                            |
    +------------------------------------------------*/
    fnd_file.put_line(FND_FILE.LOG,p_message);

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(p_message);
  END IF;

EXCEPTION
  WHEN others THEN
   /*-------------------------------------------------------+
    | Error writing to the log, nothing we can do about it. |
    | Error is not raised since API messages also contain   |
    | non fatal warnings. If a real exception happened it   |
    | is handled on the calling routine.                    |
    +-------------------------------------------------------*/
    NULL;

END write_debug_and_log;

/*===========================================================================+
 | FUNCTION validate_and_default_gl_date                                     |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Validates and defaults GL date                                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS:IN: p_gl_date          Date used in the                         |
 |               p_doc_date         arp_util.validate_and_default_gl_date    |
 |               p_validation_date1 to validate and / or default             |
 |               p_validation_date2 gl_date. For more information see        |
 |               p_validation_date3 ARP_STANDARD.validate_and_default_gl_date|
 |               p_default_date1                                             |
 |               p_default_date2                                             |
 |               p_default_date3                                             |
 |                                                                           |
 | RETURNS    : Defaulted GL_DATE                                            |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-AUG-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
FUNCTION validate_and_default_gl_date(p_gl_date                in date,
                                      p_doc_date               in date,
                                      p_validation_date1       in date,
                                      p_validation_date2       in date,
                                      p_validation_date3       in date,
                                      p_default_date1          in date,
                                      p_default_date2          in date,
                                      p_default_date3          in date) RETURN DATE IS

  l_defaulting_rule_used       VARCHAR2(50);
  l_default_gl_date            DATE;
  l_error_message              VARCHAR2(240);

BEGIN
  write_debug_and_log( 'arp_br_housekeeper_pkg.validate_and_default_gl_date()' );

 /*---------------------------------------------+
  | Validate GL date. If gl_date is not passed  |
  | try to default it                           |
  +---------------------------------------------*/
  IF (arp_util.validate_and_default_gl_date(p_gl_date,
                                            p_doc_date,
                                            p_validation_date1,
                                            p_validation_date2,
                                            p_validation_date3,
                                            p_default_date1,
                                            p_default_date2,
                                            p_default_date3,
                                            'N',
                                            NULL,
                                            arp_global.set_of_books_id,
                                            arp_global.G_AR_APP_ID,
                                            l_default_gl_date,
                                            l_defaulting_rule_used,
                                            l_error_message) = TRUE) THEN

        RETURN l_default_gl_date;

  ELSE
   /*-----------------------------------------------------+
    | Invalid GL_date and system was unable to default it |
    +-----------------------------------------------------*/
    write_debug_and_log( 'Invalid GL date' );

    RETURN to_date(NULL);

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
	write_debug_and_log('Exception: arp_br_housekeeper_pkg.validate_and_default_gl_date '||SQLERRM);
	RAISE;

END validate_and_default_gl_date;

/*===========================================================================+
 | FUNCTION validate_against_doc_gl_date                                    |
 |    	                                                                     |
 | DESCRIPTION                                                               |
 |    Checks that the GL date is not before the transaction gl date          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS:IN: p_gl_date          GL Date given as parameter to the report |
 |               p_doc_gl_date      Transaction GL Date                      |
 |                                                                           |
 | RETURNS    :  GL Date                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     07-AUG-2000  Jani Rautiainen      Created                             |
 |                                                                           |
 +===========================================================================*/
FUNCTION validate_against_doc_gl_date(p_gl_date                in date,
                                      p_doc_gl_date            in date) RETURN DATE IS

  l_default_gl_date            DATE;
BEGIN

  write_debug_and_log( 'arp_br_housekeeper_pkg.validate_against_doc_gl_date()' );

 /*--------------------------------------------------------------+
  | If parameters are null return the Gl date given as parameter |
  | to the report as nothing was changed.                        |
  +--------------------------------------------------------------*/
  IF (p_gl_date is null or p_doc_gl_date is null) THEN

    RETURN pg_gl_date;

  END IF;

 /*------------------------------------------------------------------------+
  | If trx gl date is after the GL Date given as parameter to the report   |
  | we validate the trx gl date and use that as a GL Date. If trx GL date  |
  | id is not valid, then the GL_DATE will be defaulted to the last date of|
  | the most recent open period.                                           |
  +------------------------------------------------------------------------*/
  IF trunc(p_gl_date) < trunc(p_doc_gl_date) THEN

    l_default_gl_date := arp_br_housekeeper_pkg.validate_and_default_gl_date(p_doc_gl_date,
                                                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL);
    IF l_default_gl_date is not NULL THEN

      write_debug_and_log( 'gl_date defaulted = '||to_char(l_default_gl_date));
      RETURN l_default_gl_date;

    ELSE
     /*-----------------------------------------------------+
      | Invalid GL_date and system was unable to default it |
      +-----------------------------------------------------*/
      write_debug_and_log( 'GL date could not be defaulted' );
      return p_gl_date;

    END IF;

  ELSE
   /*------------------------------------------------------------------------+
    | If trx GL date is before the GL date given as parameter to the report  |
    | we can use the given GL date directly                                  |
    +------------------------------------------------------------------------*/
    return p_gl_date;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN
	write_debug_and_log('Exception: arp_br_housekeeper_pkg.validate_against_doc_gl_date '||SQLERRM);
	RAISE;

END validate_against_doc_gl_date;

END arp_br_housekeeper_pkg;

/
