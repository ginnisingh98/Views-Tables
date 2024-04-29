--------------------------------------------------------
--  DDL for Package Body CE_XLA_ACCT_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_XLA_ACCT_EVENTS_PKG" AS
/* $Header: cexlaevb.pls 120.16.12010000.4 2008/09/16 16:36:25 csutaria ship $ */

PROCEDURE log(p_msg varchar2) is
BEGIN
--  FND_FILE.PUT_LINE(FND_FILE.LOG,p_msg);
  cep_standard.debug(p_msg);
END log;


FUNCTION Validate_GL_Date(X_accounting_date DATE,
			  X_ledger_id       NUMBER,
		          X_cashflow_date   DATE) RETURN DATE IS
  l_count		NUMBER;
  l_accounting_date 	DATE;
BEGIN
  IF X_accounting_date IS NULL THEN
    log('No accounting date has been passed');
  END IF;

  log('validate accounting date '|| X_accounting_date);
  SELECT  count(*)
  INTO	  l_count
  FROM	  gl_period_statuses glp
  WHERE	  glp.ledger_id = X_ledger_id
  AND	  glp.closing_status in ('O','F')
  AND	  glp.application_id = 101
  AND	  glp.adjustment_period_flag = 'N'
  AND	  X_accounting_date BETWEEN
		glp.start_date AND glp.end_date;

  IF l_count > 0 THEN
    log('accounting date '|| X_accounting_date);
    RETURN X_accounting_date;
  ELSE
    -- Return the next open GL date
    SELECT  MIN(start_date)
    INTO    l_accounting_date
    FROM    gl_period_statuses
    WHERE   closing_status = 'O'
    AND     ledger_id = X_ledger_id
    AND     application_id = 101
    AND     adjustment_period_flag = 'N'
    AND     start_date >= nvl(X_accounting_date, X_cashflow_date);
    log('corrected accounting date '|| l_accounting_date);
    RETURN l_accounting_date;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     log('No Open period');
     RETURN X_accounting_date;
  WHEN OTHERS THEN
     log('EXCEPTION Validate_GL_Date');
     RAISE;
END Validate_GL_Date;


PROCEDURE Update_SLA_Event_Status(X_event_id		NUMBER,
				  X_event_status_code	VARCHAR2,
				  X_event_source_info   xla_events_pub_pkg.t_event_source_info,
  				  X_security_context    xla_events_pub_pkg.t_security) IS
  l_event_type_code	VARCHAR2(30);
BEGIN
  log('Updating SLA event: '|| X_event_id);
  log('260: ' || X_event_source_info.application_id);
  log('Trx ID: '|| X_event_source_info.source_id_int_1);
  log('CE_CASHFLOWS: '||X_event_source_info.entity_type_code);
  log('LE: '||X_event_source_info.legal_entity_id);
  log('Ledger: '||X_event_source_info.ledger_id);
  log('trx num: '||X_event_source_info.transaction_number);


  XLA_EVENTS_PUB_PKG.update_event(p_event_source_info 	=> X_event_source_info,
				  p_event_id 		=> X_event_id,
				  p_event_type_code	=> null,
				  p_event_date 		=> null,
				  p_event_status_code   => X_event_status_code,
                       	 	  p_valuation_method  	=> '',
				  p_security_context	=> X_security_context);

  log('Updated SLA event: '|| X_event_id);
END Update_SLA_Event_Status;

/*========================================================================
 | PUBLIC PROCEDURE Raise_SLA_Event
 |
 | DESCRIPTION
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS p_ev_rec which contains
 |
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-APR-2005           BHCHUNG           CREATED
 *=======================================================================*/
PROCEDURE Raise_SLA_Event(X_event_type_code	VARCHAR2,
		       X_event_date		DATE,
                       X_event_status_code	VARCHAR2,
		       X_rowid			ROWID,
		       X_event_source_info	xla_events_pub_pkg.t_event_source_info,
		       X_security_context	xla_events_pub_pkg.t_security,
		       X_reference_info         xla_events_pub_pkg.t_event_reference_info) IS
  l_event_id NUMBER;
BEGIN
  log('Raise SLA event with event_type code: '|| X_event_type_code);
  log('Raise SLA event with event_date: '|| X_event_date);
  log('Raise SLA event with event_status_code: '|| X_event_status_code);
  log('Raise SLA event with rowid: '|| X_rowid);

  l_event_id := XLA_EVENTS_PUB_PKG.create_event(
			p_event_source_info => X_event_source_info,
			p_event_type_code   => X_event_type_code,
			p_event_date	    => X_event_date,
			p_event_status_code => X_event_status_code,
			p_event_number      => NULL,
			p_reference_info    => X_reference_info,
                        p_valuation_method  => '',
			p_security_context  => X_security_context);

  log('Event_id: '||l_event_id);
  log('Row ID: '||X_rowid);
  -- Update event_id in history table
  UPDATE ce_cashflow_acct_h
  SET event_id = l_event_id
  WHERE rowid = X_rowid;

EXCEPTION
  WHEN OTHERS THEN
     log('EXCEPTION in Raise SLA Event');
     RAISE;
END Raise_SLA_Event;

/*========================================================================
 | PUBLIC PROCEDURE Create_Event
 |
 | DESCRIPTION
 |
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |    X_trx_id:      cashflow_id
 |    X_event_type:  Event Type Code
 |    X_gl_date:  GL date for clearing and unclearing
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-APR-2005           BHCHUNG           CREATED
 *=======================================================================*/
PROCEDURE Create_Event( X_trx_id		NUMBER,
		        X_event_type_code	VARCHAR2,
		        X_gl_date		DATE DEFAULT NULL) IS
  l_previous_row_id		ROWID;
  l_previous_event_id		NUMBER;
  l_previous_ae_status		VARCHAR2(30);
  l_creation_event_id		NUMBER;
  l_creation_ae_status		VARCHAR2(30);
  l_accounting_date		DATE;
  l_previous_acct_date		DATE;
  l_creation_row_id		ROWID;
  l_rowid			ROWID;

  l_event_source_info     xla_events_pub_pkg.t_event_source_info;
  l_reference_info        xla_events_pub_pkg.t_event_reference_info;
  l_security_context      xla_events_pub_pkg.t_security;

  l_cleared_date		DATE;
  l_cleared_amount		NUMBER;
  l_cleared_exchange_date	DATE;
  l_cleared_exchange_rate_type	VARCHAR2(30);
  l_cleared_exchange_rate 	NUMBER;
  l_clearing_charges_amount	NUMBER;
  l_clearing_error_amount	NUMBER;
  l_cashflow_date		DATE;
  l_ledger_id			NUMBER;
  l_transfer_date		DATE;

BEGIN
  -- set parameters
    --
  -- initialize event source info
  --
  l_event_source_info.application_id := 260;
  l_event_source_info.source_id_int_1 := X_trx_id;
  l_event_source_info.entity_type_code := 'CE_CASHFLOWS';
  --
  -- Populate event source info record and security context
  --
  select  cf.cashflow_legal_entity_id,
	  cf.cashflow_ledger_id,
	  cf.cashflow_legal_entity_id,
	  cf.cashflow_id,
	  cf.cleared_date,
	  cf.cleared_amount,
	  cf.cleared_exchange_date,
    	  cf.cleared_exchange_rate_type,
 	  cf.cleared_exchange_rate,
	  cf.clearing_charges_amount,
	  cf.clearing_error_amount,
          cf.cashflow_date,
	  cf.cashflow_ledger_id
  into	  l_event_source_info.legal_entity_id,
	  l_event_source_info.ledger_id,
          l_security_context.security_id_int_1,
	  l_event_source_info.transaction_number,
  	  l_cleared_date,
  	  l_cleared_amount,
  	  l_cleared_exchange_date,
  	  l_cleared_exchange_rate_type,
  	  l_cleared_exchange_rate,
  	  l_clearing_charges_amount,
  	  l_clearing_error_amount,
	  l_cashflow_date,
	  l_ledger_id
  from 	  ce_cashflows cf,
	  ce_payment_transactions trx
  where   trx.trxn_reference_number(+) = cf.trxn_reference_number
  and     cf.cashflow_id = X_trx_id;

  log('le '|| l_event_source_info.legal_entity_id);
  log('ledger '|| l_event_source_info.ledger_id);
  log('cashflow id '|| l_event_source_info.transaction_number);
  log('cashflow date '|| l_cashflow_date);

  -- get the previous ae information and update the currect record flag to 'N'
  BEGIN
    SELECT rowid,
	   event_id,
           status_code,
	   accounting_date
    INTO   l_previous_row_id,
	   l_previous_event_id,
	   l_previous_ae_status,
           l_previous_acct_date
    FROM   ce_cashflow_acct_h
    WHERE  cashflow_id = X_trx_id
    AND    current_record_flag = 'Y';

    UPDATE ce_cashflow_acct_h
    SET    current_record_flag = 'N'
    WHERE  event_id = l_previous_event_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	log('No accounting previous event exists for this cashflow');
  END;

  --
  -- Populate ce_cashflow_acct_h table with new event info.
  -- Also, update current record flag to 'Y'.
  --
  IF X_event_type_code = 'CE_BAT_CREATED' THEN
    log('Raise create event: ' ||X_event_type_code);
    -- make sure accounting date is in open period. If not then use the first
    -- available valid accounting date.

    l_accounting_date := l_cashflow_date;

    -- populate history table
    CE_CASHFLOW_HIST_PKG.insert_row(l_rowid,
		 		0,
 				X_trx_id,
 				X_event_type_code,
 				l_accounting_date,
 				'NOT_APPLICABLE', -- Bug 7409147
 				'Y',
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				'N',
 				null,
 				null,
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1));

    -- l_event_source_info.source_id_char_1 := l_rowid;
    log('Row ID: '||l_rowid);
    -- Raise Create AE in SLA with unprocessed status
    -- Cashflow date is used for accounting date
    Raise_SLA_Event(X_event_type_code,
		    l_accounting_date,
                    XLA_EVENTS_PUB_PKG.c_event_noaction, --Bug 7387802
		    l_rowid,
		    l_event_source_info,
		    l_security_context,
		    l_reference_info );

  ELSIF X_event_type_code IN ('CE_BAT_CLEARED','CE_STMT_RECORDED') THEN
    log('Raise event: ' ||X_event_type_code);
    -- make sure accounting date is in open period. If not then use the first
    -- available valid accounting date.
    IF X_event_type_code = 'CE_BAT_CLEARED' THEN
      l_accounting_date := X_gl_date;
    ELSE
      l_accounting_date := l_cleared_date;
    END IF;

    -- populate history table
    CE_CASHFLOW_HIST_PKG.insert_row(l_rowid,
		 		0,
 				X_trx_id,
 				X_event_type_code,
 				l_accounting_date,
 				'UNACCOUNTED',
 				'Y',
				l_cleared_date,
  	  			l_cleared_amount,
  	  			l_cleared_exchange_rate,
  	  			l_cleared_exchange_date,
  	  			l_cleared_exchange_rate_type,
  	  			l_clearing_charges_amount,
  	  			l_clearing_error_amount,
 				'N',
 				null,
 				null,
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1));

    -- l_event_source_info.source_id_char_1 := l_rowid;
    log('Row ID: '||l_rowid);
    -- Raise Clearing AE in SLA with unprocessed status
    Raise_SLA_Event(X_event_type_code,
		    l_accounting_date,
                    XLA_EVENTS_PUB_PKG.c_event_unprocessed,
		    l_rowid,
		    l_event_source_info,
		    l_security_context,
		    l_reference_info );
  ELSIF X_event_type_code IN ('CE_BAT_UNCLEARED', 'CE_STMT_CANCELED') THEN
    log('Raise event: ' ||X_event_type_code);
    -- make sure accounting date is in open period. If not then use the first
    -- available valid accounting date.
    IF X_event_type_code = 'CE_BAT_UNCLEARED' THEN
      l_accounting_date := X_gl_date;
    ELSE
      l_accounting_date := Validate_GL_Date(l_previous_acct_date, l_ledger_id, l_cashflow_date);
    END IF;

    IF l_previous_ae_status <> 'ACCOUNTED' THEN  -- clearing event is unaccounted
      -- Change AE status in SLA to 'no action'
      -- l_event_source_info.source_id_char_1 := l_previous_row_id;
      Update_SLA_Event_Status(l_previous_event_id,
	            	      XLA_EVENTS_PUB_PKG.c_event_noaction,
			      l_event_source_info,
			      l_security_context);

      -- Change AE status in history table to 'not applicable'.
      UPDATE ce_cashflow_acct_h
      SET    status_code = 'NOT_APPLICABLE'
      WHERE  event_id = l_previous_event_id;

      -- populate history table with 'Not Applicable' status
      CE_CASHFLOW_HIST_PKG.insert_row(l_rowid,
		 		0,
 				X_trx_id,
 				X_event_type_code,
 				l_accounting_date,
 				'NOT_APPLICABLE',
 				'Y',
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				'Y',
 				X_trx_id,
 				rowidtochar(l_previous_row_id),
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1));

      -- l_event_source_info.source_id_char_1 := l_rowid;
      log('Row ID: '||l_rowid);

      -- Raise Unclearing AE in SLA with status 'no action'
      Raise_SLA_Event(X_event_type_code,
		    l_accounting_date,
                    XLA_EVENTS_PUB_PKG.c_event_noaction,
		    l_rowid,
		    l_event_source_info,
		    l_security_context,
		    l_reference_info );

    ELSE  -- clearing event is accounted

      -- populate history table with 'UNACCOUNTED' status
      CE_CASHFLOW_HIST_PKG.insert_row(l_rowid,
		 		0,
 				X_trx_id,
 				X_event_type_code,
 				l_accounting_date,
 				'UNACCOUNTED',
 				'Y',
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				'Y',
 				X_trx_id,
 				rowidtochar(l_previous_row_id),
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1));

      -- l_event_source_info.source_id_char_1 := l_rowid;
      log('Row ID: '||l_rowid);

      -- Raise Unclearing AE in SLA with status 'unprocessed'
      Raise_SLA_Event(X_event_type_code,
		    l_accounting_date,
                    XLA_EVENTS_PUB_PKG.c_event_unprocessed,
		    l_rowid,
		    l_event_source_info,
		    l_security_context,
		    l_reference_info );

    END IF;
  ELSIF X_event_type_code = 'CE_BAT_CANCELED' THEN
    log('Raise event: ' ||X_event_type_code);
    -- get the creation ae information
    BEGIN
      --bug 7327306
	  SELECT event_id,
             status_code,
             accounting_date,
	     rowid
      INTO   l_creation_event_id,
	     l_creation_ae_status,
             l_accounting_date,
             l_creation_row_id
      FROM   ce_cashflow_acct_h
	  WHERE  event_id = (SELECT  Max(event_id)
                         FROM    ce_cashflow_acct_h
                         WHERE   cashflow_id = X_trx_id
                         AND     event_type = 'CE_BAT_CREATED');

    log('Creation event acct status: '|| l_creation_ae_status);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	log('No creation accounting event exists');
    END;

    -- make sure accounting date is in open period. If not then use the first
    -- available valid accounting date.
     l_accounting_date := Validate_GL_Date(l_accounting_date, l_ledger_id, l_cashflow_date);

     -- -- Bug 7409147 removed the if condition as the cancel event from BAT is unaccountable
     -- like creation

      log('Creation event is always unaccounted');
      -- Change AE status in SLA to 'no action'
      -- l_event_source_info.source_id_char_1 := l_creation_row_id;
      Update_SLA_Event_Status(l_creation_event_id,
	            	      XLA_EVENTS_PUB_PKG.c_event_noaction,
			      l_event_source_info,
			      l_security_context);

     log('Inserting History with type code: ' ||X_event_type_code);
      -- populate history table with 'Not Applicable' status
      CE_CASHFLOW_HIST_PKG.insert_row(l_rowid,
		 		0,
 				X_trx_id,
 				X_event_type_code,
 				l_accounting_date,
 				'NOT_APPLICABLE',
 				'Y',
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				null,
 				'Y',
 				X_trx_id,
 				rowidtochar(l_creation_row_id),
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1),
 				sysdate,
 				nvl(fnd_global.user_id, -1));

      -- l_event_source_info.source_id_char_1 := l_rowid;
      log('Row ID: '||l_rowid);

      -- Raise Cancel AE in SLA with status 'no action'
      Raise_SLA_Event(X_event_type_code,
		    l_accounting_date,
                    XLA_EVENTS_PUB_PKG.c_event_noaction,
		    l_rowid,
		    l_event_source_info,
		    l_security_context,
		    l_reference_info );


  ELSE
    log('Exception incorrect event type code: '||X_event_type_code);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
	log('Exception in creating sla event');
    RAISE;
END Create_Event;


/*========================================================================
 | PRIVATE PROCEDURE postaccounting
 |
 | DESCRIPTION
 |   Callout API to be called from SLA accounting engine.
 |   As postaccounting action, API needs to perform the following:
 |
 |   The following is the API logic:
 |
 |   1.	If p_accounting_mode = 'D' (draft accounting) then don't do anything.
 |   2.	Based on p_report_request_id, get the list of event ID from XLA_ENTITY_EVENTS_V
 |   3.	For each event ID, check the PROCESS_STATUS_CODE column in XLA_ENTITY_EVENTS_V.
 |	If process_status_code = 'E' then
 |		Update cash flow acct history status (status_code) to 'Accounting Error'
 |	Else if process_status_code = 'P' then
 |		Update cash flow acct history status (status_code) to 'Accounted'
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-APR-2005           BHCHUNG           CREATED
 *=======================================================================*/
PROCEDURE postaccounting
   (p_application_id     NUMBER
   ,p_ledger_id          NUMBER
   ,p_process_category   VARCHAR2
   ,p_end_date           DATE
   ,p_accounting_mode    VARCHAR2
   ,p_valuation_method   VARCHAR2
   ,p_security_id_int_1  NUMBER
   ,p_security_id_int_2  NUMBER
   ,p_security_id_int_3  NUMBER
   ,p_security_id_char_1 VARCHAR2
   ,p_security_id_char_2 VARCHAR2
   ,p_security_id_char_3 VARCHAR2
   ,p_report_request_id  NUMBER    ) IS

  CURSOR event_cur IS
    SELECT event_id,
           process_status_code
    FROM   xla_entity_events_v
    WHERE  request_id = p_report_request_id
    AND    application_id = 260;

BEGIN
  log('Start postaccounting call-out API');
  IF p_accounting_mode = 'D' THEN
    RETURN;  -- draft accounting mode. Don't do anything
  END IF;

  FOR c_rec IN event_cur LOOP
    IF c_rec.process_status_code = 'E' THEN  -- accounting error
      UPDATE ce_cashflow_acct_h
      SET    status_code = 'ACCOUNTING_ERROR'
      WHERE  event_id = c_rec.event_id;
    ELSIF c_rec.process_status_code = 'P' THEN
      UPDATE ce_cashflow_acct_h
      SET    status_code = 'ACCOUNTED'
      WHERE  event_id = c_rec.event_id
      and   status_code <> 'NOT_APPLICABLE'; -- Bug 7409147
    END IF;
  END LOOP;

EXCEPTION
WHEN OTHERS THEN
  log('Exception in postaccounting');
  RAISE;
END postaccounting;

/*========================================================================
 | PRIVATE PROCEDURE preaccounting
 |
 | DESCRIPTION
 |   Callout API to be called from SLA accounting engine.
 |   No action requires. This is stubbed API.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-APR-2005           BHCHUNG           CREATED
 *=======================================================================*/
PROCEDURE preaccounting
   (p_application_id     NUMBER
   ,p_ledger_id          NUMBER
   ,p_process_category   VARCHAR2
   ,p_end_date           DATE
   ,p_accounting_mode    VARCHAR2
   ,p_valuation_method   VARCHAR2
   ,p_security_id_int_1  NUMBER
   ,p_security_id_int_2  NUMBER
   ,p_security_id_int_3  NUMBER
   ,p_security_id_char_1 VARCHAR2
   ,p_security_id_char_2 VARCHAR
   ,p_security_id_char_3 VARCHAR2
   ,p_report_request_id  NUMBER                    ) IS
BEGIN
  log('Start preaccounting call-out API');
END preaccounting;

  /*========================================================================
 | PRIVATE PROCEDURE extract
 |
 | DESCRIPTION
 |   Callout API to be called from SLA accounting engine.
 |   No action requires. This is stubbed API.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-APR-2005           BHCHUNG           CREATED
 *=======================================================================*/
PROCEDURE extract
   (p_application_id     NUMBER
   ,p_accounting_mode    VARCHAR2                     ) IS
BEGIN
  log('Start extract call-out API');
END extract;

/*========================================================================
 | PRIVATE PROCEDURE postprocessing
 |
 | DESCRIPTION
 |   Callout API to be called from SLA accounting engine.
 |   No action requires. This is stubbed API.
 |
 | KNOWN ISSUES
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 06-APR-2005           BHCHUNG           CREATED
 *=======================================================================*/
PROCEDURE postprocessing
   (p_application_id     NUMBER
   ,p_accounting_mode    VARCHAR2                     ) IS
BEGIN
  log('Start postprocessing call-out API');
END postprocessing;

FUNCTION ce_policy
   (obj_schema VARCHAR2
   ,obj_name VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  log('Start ce_policy');

  RETURN '1 =  CEP_STANDARD.check_ba_security(security_id_int_1,''CEBAA'')';
  log('Exit ce_policy');
END ce_policy;

END CE_XLA_ACCT_EVENTS_PKG;

/
