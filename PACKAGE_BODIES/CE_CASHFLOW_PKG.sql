--------------------------------------------------------
--  DDL for Package Body CE_CASHFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CASHFLOW_PKG" as
/* $Header: cecashpb.pls 120.4.12010000.5 2010/02/19 11:04:30 talapati ship $ */

l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
--  l_DEBUG varchar2(1) := 'Y';

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       update_ce_cashflows
|  DESCRIPTION                                                          |
|       update records in CE_CASHFLOWS					|
|  CALLED BY                                                            |
|       clear_cashflow
 --------------------------------------------------------------------- */
PROCEDURE update_ce_cashflows(
    	X_CASHFLOW_ID   		number,
	X_TRX_STATUS			varchar2,
        X_actual_value_date  		date,
        X_CLEARED_DATE          	date,
        X_CLEARED_AMOUNT    		number,
        X_CLEARED_ERROR_AMOUNT          number,
        X_CLEARED_CHARGE_AMOUNT         number,
        X_CLEARED_EXCHANGE_RATE_TYPE    varchar2,
        X_CLEARED_EXCHANGE_RATE_DATE    date,
        X_CLEARED_EXCHANGE_RATE         number,
	X_NEW_TRX_STATUS		varchar2,
	X_CLEARED_BY_FLAG		VARCHAR2 ,
        X_LAST_UPDATE_DATE      	date,
        X_LAST_UPDATED_BY       	number,
        X_LAST_UPDATE_LOGIN     	number,
	X_STATEMENT_LINE_ID  		number,
	X_PASSIN_MODE			varchar2
	)   IS
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_CASHFLOW_PKG.UPDATE_CE_CASHFLOWS');
  	cep_standard.debug('X_PASSIN_MODE: '|| X_PASSIN_MODE ||
			   ', X_STATEMENT_LINE_ID: '|| X_STATEMENT_LINE_ID||
			   ', X_TRX_STATUS: '||X_TRX_STATUS||
			   ', X_NEW_TRX_STATUS: '|| X_NEW_TRX_STATUS
			);
  	cep_standard.debug('X_CLEARED_BY_FLAG: '|| X_CLEARED_BY_FLAG ||
			   ', X_CASHFLOW_ID: '|| X_CASHFLOW_ID ||
			   ', X_CLEARED_AMOUNT: '|| X_CLEARED_AMOUNT
			);
  END IF;

    -- MANUAL_L, MANUAL_H, AUTO (X_TRX_STATUS = 'CLEARED', X_NEW_TRX_STATUS = 'RECONCILED')
    -- MANUAL  (X_TRX_STATUS = 'RECONCILED', X_NEW_TRX_STATUS = 'CLEARED'),
  IF ((X_PASSIN_MODE <> 'MANUAL_UC' and X_TRX_STATUS = 'CLEARED') or
	 ((X_PASSIN_MODE <> 'MANUAL_C' or X_PASSIN_MODE = 'MANUAL') and X_NEW_TRX_STATUS = 'CLEARED')) THEN
      -- for cleared cashflows, keep current clear info
    UPDATE CE_CASHFLOWS
    SET CASHFLOW_STATUS_CODE 		= X_NEW_TRX_STATUS,
 	  CLEARED_BY_FLAG 		= X_CLEARED_BY_FLAG,
          LAST_UPDATE_DATE      	= X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY       	= X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN     	= X_LAST_UPDATE_LOGIN,
	  STATEMENT_LINE_ID		= X_STATEMENT_LINE_ID
    WHERE CASHFLOW_ID = X_CASHFLOW_ID;
  ELSE
    -- MANUAL_C  (X_TRX_STATUS = 'CREATED', X_NEW_TRX_STATUS = 'CLEARED'),
    -- MANUAL_UC (X_TRX_STATUS = 'CLEARED', X_NEW_TRX_STATUS = 'CREATED' ),
    -- MANUAL (X_TRX_STATUS = 'CLEARED', X_NEW_TRX_STATUS = 'CREATED')
    -- MANUAL_L, MANUAL_H, AUTO (X_TRX_STATUS = 'CREATED', X_NEW_TRX_STATUS = 'RECONCILED')
    UPDATE CE_CASHFLOWS
    SET CASHFLOW_STATUS_CODE 		= X_NEW_TRX_STATUS,
          ACTUAL_VALUE_DATE		= X_actual_value_date,
	  CLEARED_DATE 			= X_CLEARED_DATE ,
	  CLEARED_AMOUNT 		= abs(X_CLEARED_AMOUNT),
	  CLEARED_EXCHANGE_RATE		= X_CLEARED_EXCHANGE_RATE,
	  CLEARED_EXCHANGE_DATE		= X_CLEARED_EXCHANGE_RATE_DATE,
	  CLEARED_EXCHANGE_RATE_TYPE	= X_CLEARED_EXCHANGE_RATE_TYPE ,
	  CLEARING_CHARGES_AMOUNT	= X_CLEARED_CHARGE_AMOUNT,
	  CLEARING_ERROR_AMOUNT		= X_CLEARED_ERROR_AMOUNT,
 	  CLEARED_BY_FLAG 		= X_CLEARED_BY_FLAG,
          LAST_UPDATE_DATE      	= X_LAST_UPDATE_DATE,
          LAST_UPDATED_BY       	= X_LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN     	= X_LAST_UPDATE_LOGIN,
	  STATEMENT_LINE_ID		= X_STATEMENT_LINE_ID
    WHERE CASHFLOW_ID = X_CASHFLOW_ID;

  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_CASHFLOW_PKG.UPDATE_CE_CASHFLOWS');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_CASHFLOW_PKG.UPDATE_CE_CASHFLOWS');
    END IF;
    RAISE;
END UPDATE_CE_CASHFLOWS;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       RAISE_ACCT_EVENT
|  CALLED BY                                                            |
|       clear_cashflow    			        |
 --------------------------------------------------------------------- */
PROCEDURE RAISE_ACCT_EVENT(
	 X_CASHFLOW_ID 			number,
	 X_ACCTG_EVENT 			varchar2,
       	 X_ACCOUNTING_DATE 		date,
 	 X_EVENT_STATUS_CODE		VARCHAR2,
 	 X_EVENT_ID			IN OUT NOCOPY NUMBER) IS
--x_event_id  number;
BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('>>CE_CASHFLOW_PKG.RAISE_ACCT_EVENT');
  END IF;

  ce_xla_acct_events_pkg.create_event(
		X_trx_id 	    => X_CASHFLOW_ID,
		X_event_type_code   => X_ACCTG_EVENT ,
		X_GL_DATE	    => X_ACCOUNTING_DATE);

/*  x_event_id := ce_xla_acct_events_pkg.create_events(
		X_trx_id 	    => X_CASHFLOW_ID,
		X_event_type_code   => X_ACCTG_EVENT ,
		X_event_date	    => X_ACCOUNTING_DATE,
		X_event_status_code => X_EVENT_STATUS_CODE);

*/
  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_CASHFLOW_PKG.RAISE_ACCT_EVENT');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_CASHFLOW_PKG.RAISE_ACCT_EVENT');
    END IF;
    RAISE;
END RAISE_ACCT_EVENT;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       clear_cashflow                                                  |
|  DESCRIPTION                                                          |
|  CALLS                                                                |
|       update_ce_cashflows                                             |
|  CALLED BY                                                            |
|       CE_AUTO_BANK_CLEAR1.reconcile_trx                               |
|       CE_AUTO_BANK_CLEAR1.unclear_process                             |
 --------------------------------------------------------------------- */
PROCEDURE clear_cashflow (
        x_cashflow_id                NUMBER,
        x_trx_status                 VARCHAR2,
        x_actual_value_date          DATE,
        x_accounting_date            DATE,
        x_cleared_date               DATE,
        x_cleared_amount             NUMBER,
        x_cleared_error_amount       NUMBER,
        x_cleared_charge_amount      NUMBER,
        x_cleared_exchange_rate_type VARCHAR2,
        x_cleared_exchange_rate_date DATE,
        x_cleared_exchange_rate      NUMBER,
        x_passin_mode                VARCHAR2,
        x_statement_line_id          NUMBER,
        x_statement_line_type        VARCHAR2
        )   IS

    x_cleared_by_flag         VARCHAR2(1);
    x_current_cleared_by_flag VARCHAR2(1);
    x_new_trx_status          VARCHAR2(15);
    x_event_id                NUMBER;
    x_source_trxn_type        VARCHAR2(30);
    x_new_stmt_ln_id          NUMBER;
    x_trx_stmt_ln_id          NUMBER;
    x_new_statement_line_type VARCHAR2(30);
    x_cashflow_status_code    VARCHAR2(30);
    x_cf_trx_status           VARCHAR2(30);
    l_acctg_event             varchar2(30);

BEGIN
  IF l_DEBUG in ('Y', 'C') THEN
    cep_standard.debug('>>CE_CASHFLOW_PKG.clear_cashflow');
  END IF;

  /* bug 7395052 - added CLEARED_BY_FLAG column which was earlier being
   * fetched by a separate query after
   *     ELSIF (X_PASSIN_MODE in ( 'MANUAL', 'MANUAL_UC'))
   */
  SELECT SOURCE_TRXN_TYPE,
         STATEMENT_LINE_ID,
         CASHFLOW_STATUS_CODE,
         cleared_by_flag
    INTO x_source_trxn_type,
         x_trx_stmt_ln_id,
         x_cashflow_status_code,
         x_current_cleared_by_flag
    FROM ce_cashflows
   WHERE cashflow_id = X_CASHFLOW_ID;

  X_NEW_STMT_LN_ID     	    := nvl(X_STATEMENT_LINE_ID, x_trx_stmt_ln_id);
  X_NEW_STATEMENT_LINE_TYPE := X_STATEMENT_LINE_TYPE;

  -- IBY will not pass X_TRX_STATUS for cashflows in IBY batch
  IF (X_TRX_STATUS is null) THEN
    X_CF_TRX_STATUS := X_CASHFLOW_STATUS_CODE;
  ELSE
    X_CF_TRX_STATUS := X_TRX_STATUS;
  END IF;

  IF (X_PASSIN_MODE = 'MANUAL_C')
  THEN    -- manual clearing
    X_NEW_TRX_STATUS  := 'CLEARED';
    X_CLEARED_BY_FLAG := 'M';

  ELSIF (X_PASSIN_MODE in ( 'MANUAL_L', 'MANUAL_H', 'AUTO'))
  THEN  --manual/auto reconciliation
    IF (X_CF_TRX_STATUS = 'CLEARED')
    THEN
        X_NEW_TRX_STATUS  := 'RECONCILED';
        X_CLEARED_BY_FLAG := 'M';
    ELSIF (X_CF_TRX_STATUS = 'CREATED')
    THEN
        X_NEW_TRX_STATUS  := 'RECONCILED';
        X_CLEARED_BY_FLAG := 'R';
    ELSE
        FND_MESSAGE.set_name( 'CE', 'CE_CF_CANNOT_RECON' );
        RAISE APP_EXCEPTION.application_exception;
    END IF;

  ELSIF (X_PASSIN_MODE in ( 'MANUAL', 'MANUAL_UC'))
  THEN   -- manual unreconciled/ manual unclearing

    /* Bug 7395052 - Removed redundant query call */
    --  select cleared_by_flag
    --  into x_current_cleared_by_flag
    --  from ce_cashflows
    --  where cashflow_id = X_CASHFLOW_ID;

    /* Bug 7395052 - Added condition to ensure that if the trx is a
       statement cashflow, its status should not become created */
    IF (x_source_trxn_type = 'STMT')
    THEN
        X_NEW_TRX_STATUS  := 'CLEARED';
    ELSE
        X_NEW_TRX_STATUS  := 'CREATED';
    END IF;

    IF (x_current_cleared_by_flag = 'R')
    THEN
        X_CLEARED_BY_FLAG := NULL;
    ELSIF (x_current_cleared_by_flag = 'M')
    THEN
        X_CLEARED_BY_FLAG := 'M';
    ELSE
        FND_MESSAGE.set_name( 'CE', 'CE_CF_CANNOT_UNRECON' );
        RAISE APP_EXCEPTION.application_exception;
    END IF;

  END IF;


  IF (X_PASSIN_MODE in ('MANUAL_C','MANUAL_L', 'MANUAL_H', 'AUTO')) THEN

    -- UPDATE CE_CASHFLOWS
    update_ce_cashflows(
    	X_CASHFLOW_ID   		=> X_CASHFLOW_ID,
	X_TRX_STATUS			=> X_CF_TRX_STATUS,
        X_actual_value_date  		=> X_actual_value_date,
        X_CLEARED_DATE          	=> X_CLEARED_DATE ,
        X_CLEARED_AMOUNT    		=> abs(X_CLEARED_AMOUNT),
        X_CLEARED_ERROR_AMOUNT          => X_CLEARED_ERROR_AMOUNT,
        X_CLEARED_CHARGE_AMOUNT         => X_CLEARED_CHARGE_AMOUNT,
        X_CLEARED_EXCHANGE_RATE_TYPE    => X_CLEARED_EXCHANGE_RATE_TYPE ,
        X_CLEARED_EXCHANGE_RATE_DATE    => X_CLEARED_EXCHANGE_RATE_DATE,
        X_CLEARED_EXCHANGE_RATE         => X_CLEARED_EXCHANGE_RATE,
	X_NEW_TRX_STATUS		=> X_NEW_TRX_STATUS,
	X_CLEARED_BY_FLAG		=> X_CLEARED_BY_FLAG,
        X_LAST_UPDATE_DATE      	=> sysdate,
        X_LAST_UPDATED_BY       	=> NVL(FND_GLOBAL.user_id,-1),
        X_LAST_UPDATE_LOGIN     	=> NVL(FND_GLOBAL.user_id,-1),
	X_STATEMENT_LINE_ID		=> x_new_stmt_ln_id,
	X_PASSIN_MODE 			=> X_PASSIN_MODE
        );

    -- bug 5203892 do not raise any acctg event for STMT (JEC) cashflows
    --             when clearing/unclearing (reconciliation/unreconciliation)
    IF x_source_trxn_type = 'BAT' THEN
      l_acctg_event := 'CE_BAT_CLEARED';
    --ELSE
      --l_acctg_event := 'CE_STMT_RECORDED';
    --END IF;

      -- RAISE CLEARING/UNCLEARING ACCOUNTING EVENT
      IF (X_CF_TRX_STATUS = 'CREATED') THEN
        RAISE_ACCT_EVENT
	(X_CASHFLOW_ID 			=> X_CASHFLOW_ID,
	 X_ACCTG_EVENT 			=> l_acctg_event,     --'CLEARING',
         X_ACCOUNTING_DATE 		=> X_ACCOUNTING_DATE,
	 X_EVENT_STATUS_CODE		=> 'UNPROCESSED',
	 X_EVENT_ID			=> X_EVENT_ID);
      END IF;
    END IF;  --x_source_trxn_type = 'BAT'

  ELSIF (X_PASSIN_MODE in ('MANUAL', 'MANUAL_UC')) THEN
    -- MANUAL (unreconciled), MANUAL_UC (uncleared)
    -- do not remove ce_cashflows.statement_line_id when unclearing/unreconciling JEC/ZBA trx
    -- x_source_trxn_type: 'STMT'  (JEC trx), 'BAT' (ZBA trx)

    IF (X_STATEMENT_LINE_TYPE is null) and
	( X_NEW_STMT_LN_ID is not null) THEN
	select trx_type
	into X_NEW_STATEMENT_LINE_TYPE
	from ce_statement_lines
	where statement_line_id = X_NEW_STMT_LN_ID;
    END IF;

    IF (x_source_trxn_type <> 'STMT')  THEN
      IF (X_NEW_STATEMENT_LINE_TYPE not in ('SWEEP_IN', 'SWEEP_OUT')) THEN
	X_NEW_STMT_LN_ID := NULL;
      END IF;
    END IF;

    IF  ((X_PASSIN_MODE =  'MANUAL_UC') or (X_NEW_TRX_STATUS = 'CREATED' and X_CLEARED_BY_FLAG is null)) THEN
      update_ce_cashflows(
    	X_CASHFLOW_ID   		=> X_CASHFLOW_ID,
	X_TRX_STATUS			=> X_CF_TRX_STATUS,
        X_actual_value_date  		=> null,
        X_CLEARED_DATE          	=> null,
        X_CLEARED_AMOUNT    		=> null,
        X_CLEARED_ERROR_AMOUNT          => null,
        X_CLEARED_CHARGE_AMOUNT         => null,
        X_CLEARED_EXCHANGE_RATE_TYPE    => null,
        X_CLEARED_EXCHANGE_RATE_DATE    => null,
        X_CLEARED_EXCHANGE_RATE         => null,
	X_NEW_TRX_STATUS		=> X_NEW_TRX_STATUS,
	X_CLEARED_BY_FLAG		=> X_CLEARED_BY_FLAG ,
        X_LAST_UPDATE_DATE      	=> sysdate,
        X_LAST_UPDATED_BY       	=> NVL(FND_GLOBAL.user_id,-1),
        X_LAST_UPDATE_LOGIN     	=> NVL(FND_GLOBAL.user_id,-1),
	X_STATEMENT_LINE_ID		=> x_new_stmt_ln_id,
	X_PASSIN_MODE 			=> X_PASSIN_MODE
        );

    ELSE

      -- UPDATE CE_CASHFLOWS
      update_ce_cashflows(
    	X_CASHFLOW_ID   		=> X_CASHFLOW_ID,
	X_TRX_STATUS			=> X_CF_TRX_STATUS,
        X_actual_value_date  		=> X_actual_value_date,
        X_CLEARED_DATE          	=> X_CLEARED_DATE ,
        X_CLEARED_AMOUNT    		=> abs(X_CLEARED_AMOUNT),
        X_CLEARED_ERROR_AMOUNT          => X_CLEARED_ERROR_AMOUNT,
        X_CLEARED_CHARGE_AMOUNT         => X_CLEARED_CHARGE_AMOUNT,
        X_CLEARED_EXCHANGE_RATE_TYPE    => X_CLEARED_EXCHANGE_RATE_TYPE ,
        X_CLEARED_EXCHANGE_RATE_DATE    => X_CLEARED_EXCHANGE_RATE_DATE,
        X_CLEARED_EXCHANGE_RATE         => X_CLEARED_EXCHANGE_RATE,
	X_NEW_TRX_STATUS		=> X_NEW_TRX_STATUS,
	X_CLEARED_BY_FLAG		=> X_CLEARED_BY_FLAG ,
        X_LAST_UPDATE_DATE      	=> sysdate,
        X_LAST_UPDATED_BY       	=> NVL(FND_GLOBAL.user_id,-1),
        X_LAST_UPDATE_LOGIN     	=> NVL(FND_GLOBAL.user_id,-1),
	X_STATEMENT_LINE_ID		=> x_new_stmt_ln_id,
	X_PASSIN_MODE 			=> X_PASSIN_MODE
        );
    END IF;

    -- bug 5203892 do not raise any acctg event for STMT (JEC) cashflows
    --             when clearing/unclearing (reconciliation/unreconciliation)
    IF x_source_trxn_type = 'BAT' THEN
      l_acctg_event := 'CE_BAT_UNCLEARED';
    --ELSE
    --  l_acctg_event := 'CE_STMT_CANCELED';
    --END IF;

      -- RAISE CLEARING/UNCLEARING ACCOUNTING EVENT
      IF (X_CF_TRX_STATUS in ( 'CLEARED', 'RECONCILED')) THEN
        RAISE_ACCT_EVENT
	(X_CASHFLOW_ID 			=> X_CASHFLOW_ID,
	 X_ACCTG_EVENT 			=> l_acctg_event, --'UNCLEARING',
         X_ACCOUNTING_DATE 		=> X_ACCOUNTING_DATE,
	 X_EVENT_STATUS_CODE		=> 'UNPROCESSED',
	 X_EVENT_ID			=> X_EVENT_ID);

      END IF;
    END IF; --x_source_trxn_type = 'BAT'

  END IF;

  IF l_DEBUG in ('Y', 'C') THEN
  	cep_standard.debug('<<CE_CASHFLOW_PKG.clear_cashflow');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF l_DEBUG in ('Y', 'C') THEN
    	cep_standard.debug('EXCEPTION: CE_CASHFLOW_PKG.clear_cashflow');
    END IF;
    RAISE;
END clear_cashflow;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       update_user_lines                                               |
|  DESCRIPTION                                                          |
|       To insert/update user defined inflows/outflows                  |
|    CALLED BY                                                          |
|       CashPositionAMImpl.java                                         |
 --------------------------------------------------------------------- */
PROCEDURE UPDATE_USER_LINES
(
 X_WORKSHEET_HEADER_ID  IN NUMBER,
 X_WORKSHEET_LINE_ID    IN NUMBER,
 X_LINE_DESCRIPTION     IN VARCHAR2,
 X_SOURCE_TYPE          IN VARCHAR2,
 X_BANK_ACCOUNT_ID      IN NUMBER,
 X_AS_OF_DATE           IN DATE,
 X_AMOUNT               IN NUMBER
) IS
l_amount NUMBER;
BEGIN
      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug('>>CE_CASHFLOW_PKG.update_user_lines');
      END IF;

      IF X_SOURCE_TYPE = 'UDO' AND X_AMOUNT <0 THEN
         l_amount :=  -1*X_AMOUNT;
      ELSE
         l_amount :=  X_AMOUNT;
      END IF;

      INSERT INTO
      CE_CP_WORKSHEET_USER_LINES
      (
      WORKSHEET_HEADER_ID,
      WORKSHEET_LINE_ID,
      LINE_DESCRIPTION,
      SOURCE_TYPE,
      BANK_ACCOUNT_ID,
      AS_OF_DATE,
      AMOUNT
      )
      VALUES
      (
      X_WORKSHEET_HEADER_ID,
      X_WORKSHEET_LINE_ID,
      X_LINE_DESCRIPTION,
      X_SOURCE_TYPE,
      X_BANK_ACCOUNT_ID,
      Trunc(X_AS_OF_DATE),
      l_amount
    );
    IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug('<<CE_CASHFLOW_PKG.update_user_lines');
    END IF;
EXCEPTION
  WHEN Dup_Val_On_Index THEN
      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug('Updating CE_WORKSHEET_USER_LINES');
      END IF;
      UPDATE CE_CP_WORKSHEET_USER_LINES
      SET
            SOURCE_TYPE = X_SOURCE_TYPE,
            AMOUNT = l_amount
      WHERE WORKSHEET_HEADER_ID = X_WORKSHEET_HEADER_ID
      AND   WORKSHEET_LINE_ID   = X_WORKSHEET_LINE_ID
      AND   BANK_ACCOUNT_ID     = X_BANK_ACCOUNT_ID
      AND   Trunc(AS_OF_DATE)   = Trunc(X_AS_OF_DATE);

      UPDATE CE_CP_WORKSHEET_USER_LINES
      SET
            LINE_DESCRIPTION = X_LINE_DESCRIPTION
      WHERE WORKSHEET_HEADER_ID = X_WORKSHEET_HEADER_ID
      AND   WORKSHEET_LINE_ID   = X_WORKSHEET_LINE_ID
      AND   Trunc(AS_OF_DATE)   = Trunc(X_AS_OF_DATE);
      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug('<<CE_CASHFLOW_PKG.update_user_lines');
      END IF;
  WHEN OTHERS THEN
      IF l_DEBUG in ('Y', 'C') THEN
    	    cep_standard.debug('EXCEPTION: CE_CASHFLOW_PKG.update_user_lines');
      END IF;
      RAISE;
END UPDATE_USER_LINES;

END CE_CASHFLOW_PKG;

/
