--------------------------------------------------------
--  DDL for Package Body GMF_SUBLEDGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_SUBLEDGER_PKG" AS
/* $Header: gmfslupb.pls 120.10.12010000.4 2009/10/30 09:22:50 vpedarla ship $ */

/*****************************************************************************
 *  PACKAGE
 *    gmf_subledger_pkg
 *
 *  DESCRIPTION
 *    Subledger Update Process pkg
 *
 *  CONTENTS
 *    PROCEDURE	test_update ( ... )
 *
 *  NOTES
 *    scheduled_on in control table is always sysdate since we are called
 *    at the appropriate time by conc.mgr.
 *
 *  HISTORY
 *    24-Dec-2002 Rajesh Seshadri - Created
 *    14-Apr-2004 Dinesh Vadivel - Bug # 3196846
 *                Added Lot Cost Adjustment related changes TDD 13.13.5
 *    30-OCT-2009 Vpedarla - Bug: 8978816
 *		  modified the procedure insert_control_record. Since Order management
 *		  entity is not getting executed in pre-processor wrapper
 *
 *  TBD
 *    - messages using msg dict.
 *
 ******************************************************************************/

  G_CURRENT_RUNTIME_LEVEL     NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  G_LEVEL_UNEXPECTED CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR      CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION  CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT      CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE  CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT  CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME      CONSTANT VARCHAR2(50) :='GMF.PLSQL.GMF_SUBLEDGER_PKG.';

  g_log_msg                     FND_LOG_MESSAGES.message_text%TYPE;

  g_legal_entity_id             NUMBER;
  g_legal_entity_name           VARCHAR2(250);
  g_ledger_id                   NUMBER;
  g_ledger_name                 VARCHAR2(250);
  g_process_category            VARCHAR2(250);

  g_cost_type_id                NUMBER;        /* New cost type terminology */
  g_cost_type_code              VARCHAR2(40);  /* cm_mthd_mst.cost_mthd_code */
  g_cost_method_type            NUMBER;        /* cm_mthd_mst.cost_type */
  g_cost_method                 VARCHAR2(100); /* lkup 'GMF_COST_METHOD' meaning */
  g_default_cost_type_id        NUMBER;

  g_crev_curr_cost_type_id      NUMBER;
  g_crev_curr_cost_mthd_code    VARCHAR2(30);
  g_crev_curr_calendar          VARCHAR2(30);
  g_crev_curr_period            VARCHAR2(30);
  g_crev_curr_period_id         NUMBER;

  g_crev_prev_cost_type_id      NUMBER;
  g_crev_prev_cost_mthd         VARCHAR2(30);
  g_crev_prev_calendar          VARCHAR2(30);
  g_crev_prev_period            VARCHAR2(30);
  g_crev_prev_period_id         NUMBER;

  g_crev_gl_trans_date          DATE;

/* forward declarations */
PROCEDURE end_process (
  p_errstat IN VARCHAR2,
  p_errmsg  IN VARCHAR2
  );

PROCEDURE inter_mod_cal_conv(
  x_inv_fiscal_year      OUT NOCOPY NUMBER,
  x_inv_period           OUT NOCOPY NUMBER,
  x_inv_per_synch        OUT NOCOPY VARCHAR2,
  x_inv_per_start_date   OUT NOCOPY DATE,
  x_inv_per_end_date     OUT NOCOPY DATE,
  x_retstatus            OUT NOCOPY VARCHAR2,
  x_errbuf               OUT NOCOPY VARCHAR2 );

/************************************************************************************************
 *  PROCEDURE
 *    update_process
 *
 *  DESCRIPTION
 *    Wrapper to the subledger update concurrent program.  Accepts the
 *    parameters to the subledger process, validates it, inserts the control
 *    record, then submits the subledger process as a child request.  It puts
 *    itself in a paused state till the program completes and returns the
 *    status back to the ccm.
 *
 *  INPUT PARAMETERS
 *    All parameters to the conc. request
 *
 *  HISTORY
 *    26-Dec-2002 Rajesh Seshadri
 *
 *    14-Apr-2004 Dinesh Vadivel Bug # 3196846 Lot Cost Adjsutment related changes TDD 13.13.5
 *	          Now allowing the process to be submitted for CM source even if
 *                GL Cost Method is a Lot Cost Method.Also, skipping the validation of
 *                "revaluation parameter" for Lot Cost Method.
 *************************************************************************************************/
PROCEDURE update_process(
    x_errbuf                  OUT NOCOPY VARCHAR2
  , x_retcode                 OUT NOCOPY VARCHAR2
  , p_legal_entity_id         IN         VARCHAR2
  , p_ledger_id               IN         VARCHAR2
  , p_cost_type_id            IN         VARCHAR2
  , p_gl_fiscal_year          IN         VARCHAR2
  , p_gl_period               IN         VARCHAR2
  , p_test_posting            IN         VARCHAR2
  , p_open_gl_date            IN         VARCHAR2
  , p_posting_start_date      IN         VARCHAR2
  , p_posting_end_date        IN         VARCHAR2
  , p_post_if_no_cost         IN         VARCHAR2
  , p_process_category        IN         VARCHAR2
  , p_crev_curr_calendar      IN         VARCHAR2
  , p_crev_curr_period        IN         VARCHAR2
  , p_crev_prev_cost_type_id  IN         VARCHAR2
  , p_crev_prev_calendar      IN         VARCHAR2
  , p_crev_prev_period        IN         VARCHAR2
  , p_crev_gl_trans_date      IN         VARCHAR2
/* start invconv umoogala
  p_post_cm		                IN VARCHAR2,
  p_post_ic		                IN VARCHAR2,
  p_post_om		                IN VARCHAR2,
  p_post_pm		                IN VARCHAR2,
  p_post_pur	                IN VARCHAR2
*/
  ) AS

  l_closed_per_ind              NUMBER(3) := 0;
  l_open_gl_fiscal_year         NUMBER(15);
  l_open_gl_period              NUMBER(15);

/* Start INVCONV umoogala
  l_inv_fiscal_year             ic_cldr_dtl.fiscal_year%TYPE;
  l_inv_period                  ic_cldr_dtl.period%TYPE;
*/
  l_inv_fiscal_year             org_acct_periods.period_year%TYPE;
  l_inv_period                  org_acct_periods.period_num%TYPE;

  l_subledger_ref_no            NUMBER(15) := NULL;

  l_conc_id                     NUMBER(15) := 0;
  l_msg_text                    VARCHAR2(2000);

  l_retstatus                   VARCHAR2(1);
  l_errbuf                      VARCHAR2(2000);

  /* conc status */
  l_conc_req_status             BOOLEAN;
  l_conc_phase                  VARCHAR2(240);
  l_conc_status                 VARCHAR2(240);
  l_conc_dev_phase              VARCHAR2(240);
  l_conc_dev_status             VARCHAR2(240);
  l_conc_msg                    VARCHAR2(240);

  /* req globals for sub-re     quests */
  l_req_data                    VARCHAR2(10);
  l_child_conc_id               NUMBER(15);

/* Start INVCONV umoogala
  l_crev_curr_mthd 	VARCHAR2(4);
  l_crev_curr_calendar    VARCHAR2(4);
  l_crev_curr_period	VARCHAR2(4);
  l_crev_prev_mthd	VARCHAR2(4);
  l_crev_prev_calendar	VARCHAR2(4);
  l_crev_prev_period	VARCHAR2(4);
*/
  l_crev_curr_cost_type_id      NUMBER;
  l_crev_curr_period_id         NUMBER;

  l_crev_prev_cost_type_id      NUMBER;
  l_crev_prev_period_id         NUMBER;

  l_crev_gl_trans_date          DATE;
  l_crev_inv_prev_period_id     NUMBER;

  l_lot_actual_cost             NUMBER;
  l_post_cm 		                VARCHAR2(2);

  /* exceptions */
  e_all_done                    EXCEPTION;
  e_req_submit_error            EXCEPTION;
  e_validation_failed           EXCEPTION;
  e_ctlrec_failed               EXCEPTION;
  e_reval_error                 EXCEPTION;


/* Start INVCONV umoogala
  CURSOR c_fiscal_policy(cp_co_code VARCHAR2)
  IS
    SELECT NVL(mthd.lot_actual_cost,0)
      FROM gl_plcy_mst plcy, cm_mthd_mst mthd
     WHERE plcy.co_code = cp_co_code
  ;
*/
  l_procedure_name CONSTANT VARCHAR2(30) := 'UPDATE_PROCESS';

BEGIN

  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  g_log_msg := 'Begin of procedure '|| l_procedure_name;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  l_req_data := FND_CONC_GLOBAL.REQUEST_DATA;

  IF( l_req_data IS NOT NULL )
  THEN
    l_child_conc_id := TO_NUMBER(l_req_data);

    /* now get the status for this req id */
    l_conc_req_status := fnd_concurrent.get_request_status(
                            request_id     => l_child_conc_id,
                            appl_shortname => NULL,
                            program        => NULL,
                            phase          => l_conc_phase,
                            status         => l_conc_status,
                            dev_phase      => l_conc_dev_phase,
                            dev_status     => l_conc_dev_status,
                            message        => l_conc_msg)
    ;

    x_errbuf := l_conc_msg;

    IF( l_conc_dev_phase = 'COMPLETE' )
    THEN
      IF( l_conc_dev_status = 'NORMAL' )
      THEN
        end_process('NORMAL',l_conc_msg);
        x_retcode := 0;
      ELSIF( l_conc_dev_status = 'WARNING' )
      THEN
        end_process('WARNING', l_conc_msg);
        x_retcode := 1;
      ELSE
        end_process('ERROR', l_conc_msg);
        x_retcode := 3;
      END IF;
    ELSE
      /* What to do for all other phases? raise a warning */
      end_process('WARNING', l_conc_dev_phase || ':' ||
        l_conc_dev_status || ': ' || l_conc_msg);
      x_retcode := 1;
    END IF;

    RETURN;
  END IF;


  --
  -- Populate Global variables
  --
  g_log_msg := l_procedure_name || ': Populate Global variables';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  g_legal_entity_id          := TO_NUMBER(p_legal_entity_id);
  g_ledger_id                := TO_NUMBER(p_ledger_id);
  g_cost_type_id             := TO_NUMBER(p_cost_type_id);


  /* Bug#5708175 ANTHIYAG 12-Dec-2006 Start */
  /*************************************
  SELECT le.organization_name, led.name,
         mthd.cost_type, mthd.cost_mthd_code, lk.meaning,
         mthd.default_lot_cost_type_id
    INTO g_legal_entity_name, g_ledger_name,
         g_cost_method_type, g_cost_type_code, g_cost_method,
         g_default_cost_type_id
    FROM org_organization_definitions le, gl_ledgers led,
         cm_mthd_mst mthd, gem_lookups lk
   WHERE le.organization_id = g_legal_entity_id
     AND led.ledger_id      = g_ledger_id
     AND mthd.cost_type_id  = g_cost_type_id
     AND lk.lookup_type     = 'GMF_COST_METHOD'
     AND lk.lookup_code     = mthd.cost_type;
  **************************************/
  BEGIN
    SELECT      gle.legal_entity_name
    INTO        g_legal_entity_name
    FROM        gmf_legal_entities gle
    WHERE       gle.legal_entity_id = g_legal_entity_id ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      g_log_msg := l_procedure_name || ': No data found in gmf_legal_entities query';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;
      RAISE;
  END;
  BEGIN
    SELECT      gl.name
    INTO        g_ledger_name
    FROM        gl_ledgers gl
    WHERE       gl.ledger_id = g_ledger_id;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      g_log_msg := l_procedure_name || ': No data found in gl_ledgers query';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;
      RAISE;
  END;
  BEGIN
    SELECT      mthd.cost_type,
                mthd.cost_mthd_code,
                lk.meaning,
                nvl(mthd.default_lot_cost_type_id, -1)
    INTO        g_cost_method_type,
                g_cost_type_code,
                g_cost_method,
                g_default_cost_type_id
    FROM        cm_mthd_mst mthd,
                gem_lookups lk
    WHERE       mthd.cost_type_id  = g_cost_type_id
    AND         lk.lookup_type     = 'GMF_COST_METHOD'
    AND         lk.lookup_code     = mthd.cost_type ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      g_log_msg := l_procedure_name || ': No data found in cost types query';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;
      RAISE;
  END;
  /* Bug#5708175 ANTHIYAG 12-Dec-2006 End */

  g_process_category         := p_process_category;

  g_crev_curr_cost_type_id   := g_cost_type_id;
  g_crev_curr_cost_mthd_code := g_cost_type_code;
  g_crev_curr_calendar       := p_crev_curr_calendar;
  g_crev_curr_period         := p_crev_curr_period;

  g_crev_prev_cost_type_id   := TO_NUMBER(p_crev_prev_cost_type_id);
  g_crev_prev_calendar       := p_crev_prev_calendar;
  g_crev_prev_period         := p_crev_prev_period;

  g_crev_gl_trans_date       := FND_DATE.canonical_to_date(p_crev_gl_trans_date);


  IF g_crev_curr_calendar IS NULL OR g_crev_curr_period IS NULL OR
     g_crev_prev_cost_type_id IS NULL OR g_crev_prev_calendar IS NULL OR
     g_crev_prev_period IS NULL
  THEN

    -- IF p_post_cm = 1 or p_process_category = 'REVALUATION_TRANSACTIONS'
    IF p_process_category = 'REVALUATION_TRANSACTIONS'
    THEN
      fnd_message.set_name('GMF','CM_NO_RVAL_PARMS');
      x_errbuf := fnd_message.get;
      RAISE e_reval_error;
    END IF;

    g_crev_curr_period_id := NULL;
    g_crev_prev_period_id := NULL;
    g_crev_prev_cost_mthd := NULL;

  ELSE

    g_log_msg := l_procedure_name || ': query cost reval data';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;


    SELECT curr.period_id, prev.period_id,
           mthd.cost_mthd_code
      INTO g_crev_curr_period_id, g_crev_prev_period_id,
                                  g_crev_prev_cost_mthd
      FROM gmf_period_statuses curr, gmf_period_statuses prev, cm_mthd_mst mthd
     WHERE curr.legal_entity_id  = g_legal_entity_id
       AND curr.cost_type_id     = g_cost_type_id
       AND curr.calendar_code    = g_crev_curr_calendar
       AND curr.period_code      = g_crev_curr_period
       AND prev.legal_entity_id  = g_legal_entity_id
       AND prev.cost_type_id     = g_crev_prev_cost_type_id
       AND prev.calendar_code    = g_crev_prev_calendar
       AND prev.period_code      = g_crev_prev_period
       AND mthd.cost_type_id     = g_crev_prev_cost_type_id
    ;
  END IF;

  --
  -- End of -- Populate Global variables
  --


  gmf_util.log('Starting GMF SLA Pre-Processor program:');
  gmf_util.log(' Legal Entity       =>'  || g_legal_entity_name);
  gmf_util.log(' Ledger             =>'  || g_ledger_name);
  gmf_util.log(' Cost Type          =>'  || g_cost_type_code);
  gmf_util.log(' Cost Method        =>'  || g_cost_method);
  gmf_util.log(' Process Category   =>'  || g_process_category);

  gmf_util.log(' gl_fiscal_year     =>'  || p_gl_fiscal_year);
  gmf_util.log(' gl_period          =>'  || p_gl_period);
  gmf_util.log(' test_posting       =>'  || p_test_posting);

  gmf_util.log(' open_gl_date       =>'  || p_open_gl_date);

  gmf_util.log(' posting_start_date =>'  || p_posting_start_date);
  gmf_util.log(' posting_end_date   =>'  || p_posting_end_date);

  gmf_util.log(' post_if_no_cost    =>'  || p_post_if_no_cost);

/* Start INVCONV umoogala
  gmf_util.log(' post CM =>' || p_post_cm);
  gmf_util.log(' post IC =>' || p_post_ic);
  gmf_util.log(' post OM =>' || p_post_om);
  gmf_util.log(' post OP =>' || p_post_op);
  gmf_util.log(' post PM =>' || p_post_pm);
  gmf_util.log(' post PO =>' || p_post_po);
  gmf_util.log(' post PUR =>' || p_post_pur);
*/

  /* Validate input params */
  g_log_msg := l_procedure_name || ': calling validate_parameters procedure';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  validate_parameters(
      p_gl_fiscal_year          => p_gl_fiscal_year,
      p_gl_period               => p_gl_period,
      p_test_posting            => p_test_posting,
      p_posting_start_date      => p_posting_start_date,
      p_posting_end_date        => p_posting_end_date,
      p_open_gl_date            => p_open_gl_date,
/* Start INVCONV umoogala
      p_co_code                 => p_co_code,
      p_post_cm                 => p_post_cm,
      p_post_ic                 => p_post_ic,
      p_post_om                 => p_post_om,
      p_post_op                 => p_post_op,
      p_post_pm                 => p_post_pm,
      p_post_po                 => p_post_po,
      p_post_pur                => p_post_pur,
*/
      x_closed_per_ind          => l_closed_per_ind,
      x_crev_gl_trans_date      => l_crev_gl_trans_date,
      x_open_gl_fiscal_year     => l_open_gl_fiscal_year,
      x_open_gl_period          => l_open_gl_period,
/* Start INVCONV umoogala
      x_crev_curr_mthd          => l_crev_curr_mthd,
      x_crev_curr_calendar      => l_crev_curr_calendar,
      x_crev_curr_period        => l_crev_curr_period,
      x_crev_prev_mthd          => l_crev_prev_mthd,
      x_crev_prev_calendar      => l_crev_prev_calendar,
      x_crev_prev_period        => l_crev_prev_period,
*/
      x_inv_fiscal_year         => l_inv_fiscal_year,
      x_inv_period              => l_inv_period,
      x_retstatus               => l_retstatus,
      x_errbuf                  => l_errbuf
  );

  IF( l_retstatus <> 'S' )
  THEN
    x_errbuf := l_errbuf;
    RAISE e_validation_failed;
  END IF;

  /* insert the control record */
  g_log_msg := l_procedure_name || ': inserting the control record into gl_subr_sta';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  insert_control_record(
    p_user_id               	   => FND_GLOBAL.user_id,
    p_gl_fiscal_year             => TO_NUMBER(p_gl_fiscal_year),
    p_gl_period               	 => TO_NUMBER(p_gl_period),
    p_posting_start_date         => FND_DATE.canonical_to_date(p_posting_start_date),
    p_posting_end_date           => FND_DATE.canonical_to_date(p_posting_end_date),
    p_test_posting               => p_test_posting,
/* Start INVCONV umoogala
    p_co_code               	   => p_co_code,
    p_post_cm               	   => l_post_cm, --p_post_cm,
    p_post_ic               	   => p_post_ic,
    p_post_om                    => p_post_om,
    p_post_op               	   => p_post_op,
    p_post_pm               	   => p_post_pm,
    p_post_po               	   => p_post_po,
    p_post_pur               	   => p_post_pur,
*/
    p_closed_per_ind             => l_closed_per_ind,
    p_open_gl_date               => FND_DATE.canonical_to_date(p_open_gl_date),
    p_crev_gl_trans_date         => l_crev_gl_trans_date,
    p_open_gl_fiscal_year        => l_open_gl_fiscal_year,
    p_open_gl_period             => l_open_gl_period,
    p_post_if_no_cost            => p_post_if_no_cost,
    p_default_language           => USERENV('LANG'),
/* Start INVCONV umoogala
    p_crev_curr_mthd             => l_crev_curr_mthd,
    P_crev_curr_calendar         => l_crev_curr_calendar,
    p_crev_curr_period           => l_crev_curr_period,
    p_crev_prev_mthd             => l_crev_prev_mthd,
    p_crev_prev_calendar         => l_crev_prev_calendar,
    p_crev_prev_period           => l_crev_prev_period,
*/
    p_inv_fiscal_year            => l_inv_fiscal_year,
    p_inv_period               	 => l_inv_period,
    x_subledger_ref_no           => l_subledger_ref_no,
    x_retstatus               	 => l_retstatus,
    x_errbuf                     => l_errbuf
  );

  IF( l_retstatus <> 'S' )
  THEN
    x_errbuf := l_errbuf;
    RAISE e_ctlrec_failed;
  END IF;

  COMMIT;

  g_log_msg := l_procedure_name || ': Submitting concurrent request';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  l_conc_id := FND_REQUEST.SUBMIT_REQUEST(
      'GMF','GMFXUPD','OPM Subledger Accounting Pre-Processor',
      fnd_date.date_to_canonical(SYSDATE),
      TRUE, '-r',TO_CHAR(l_subledger_ref_no),
      CHR(0),'','','','','','','','','','','','',
      '','','','','','','','','','','','','','','',
      '','','','','','','','','','','','','','','',
      '','','','','','','','','','','','','','','',
      '','','','','','','','','','','','','','','',
      '','','','','','','','','','','','','','','',
      '','','','','','','','','','');

  IF (l_conc_id = 0)
  THEN
    l_msg_text := FND_MESSAGE.get;
    RAISE e_req_submit_error;
  ELSE
    UPDATE gl_subr_sta
       SET request_id = l_conc_id
     WHERE reference_no = l_subledger_ref_no;

    COMMIT;
  END IF;

  fnd_message.set_name('GMF','GL_NOTE_REF_NO');
  fnd_message.set_token('S1', l_subledger_ref_no);
  l_msg_text := fnd_message.get;
  gmf_util.log(l_msg_text);

  g_log_msg := l_procedure_name || ': concurrent request submitted. Reference#: ' || l_subledger_ref_no;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  /* wait for child request to complete */
  FND_CONC_GLOBAL.SET_REQ_GLOBALS(
    conc_status => 'PAUSED',
    request_data => l_conc_id);

  x_retcode := 0;
  x_errbuf := 'Concurrent request submitted. Reference#: ' || TO_CHAR(l_subledger_ref_no) ;

EXCEPTION
  WHEN e_req_submit_error THEN
    x_retcode := 3;
    x_errbuf := l_msg_text;

    g_log_msg := l_procedure_name || ': e_req_submit_error: ' || x_errbuf;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

    end_process('ERROR', l_msg_text);

  WHEN e_validation_failed THEN
    x_retcode := 3;

    g_log_msg := 'e_validation_failed: ' || x_errbuf;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

    end_process('ERROR', l_errbuf);

  WHEN e_ctlrec_failed THEN
    x_retcode := 3;

    g_log_msg := 'e_ctlrec_failed: ' || x_errbuf;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

    end_process('ERROR', l_errbuf);

  WHEN e_reval_error THEN
    x_retcode := 3;

    g_log_msg := 'error: ' || x_errbuf;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

  WHEN others THEN
    x_retcode := 3;
    x_errbuf := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

    g_log_msg := 'in when other. error: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

    end_process('ERROR', x_errbuf);
    -- TBD RAISE;

END update_process;

/*****************************************************************************
 *  PROCEDURE
 *    end_process
 *
 *  DESCRIPTION
 *    Sets the concurrent manager completion status
 *
 *  INPUT PARAMETERS
 *    pi_errstat - Completion status, must be one of 'NORMAL', 'WARNING', or
 *	'ERROR'
 *    pi_errmsg - Completion message to be passed back
 *
 *  HISTORY
 *    26-Dec-2002 Rajesh Seshadri
 *
 ******************************************************************************/

PROCEDURE end_process (
  p_errstat IN VARCHAR2,
  p_errmsg  IN VARCHAR2
  )
AS
  l_retval BOOLEAN;
  l_procedure_name CONSTANT VARCHAR2(30) := 'END_PROCESS';
BEGIN

  g_log_msg := 'Begin of procedure '|| l_procedure_name;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  l_retval := fnd_concurrent.set_completion_status(p_errstat,p_errmsg);

END end_process;

/*********************************************************************************************
 *  PROCEDURE
 *    validate_parameters
 *
 *  DESCRIPTION
 *    Validates the input parameters
 *
 *  INPUT PARAMETERS
 *    All parameters to the conc. request
 *
 *  HISTORY
 *    26-Dec-2002 Rajesh Seshadri
 *
 *    14-Apr-2004 Dinesh Vadivel Bug #3196846 Lot Cost Adjustment related changes. TDD 13.13.5
 *                Now allowing the process to be submitted for CM source even
 *                if GL Cost Method is a Lot Cost Method. Also, skipping the
 *                validation of "revaluation parameter" for Lot Cost Method.
 *    30-Oct-2006 Anand Thiyagarajan Bug#5623121
 *      Modifications to convert the GL start and End dates, which are considered to be in LE Timezone
 *      to Server Timezone before comparing them with the Posting Start and end dates passed in Server Time Zones.
 *
 *********************************************************************************************/
PROCEDURE validate_parameters(
  p_gl_fiscal_year          IN         VARCHAR2,
  p_gl_period               IN         VARCHAR2,
  p_test_posting            IN         VARCHAR2,
  p_open_gl_date            IN         VARCHAR2,
  p_posting_start_date      IN         VARCHAR2,
  p_posting_end_date        IN         VARCHAR2,
/* Start INVCONV umoogala
  p_co_code                 IN         VARCHAR2,
  p_post_cm                 IN         VARCHAR2,
  p_post_ic                 IN         VARCHAR2,
  p_post_om                 IN         VARCHAR2,
  p_post_op                 IN         VARCHAR2,
  p_post_pm                 IN         VARCHAR2,
  p_post_po                 IN         VARCHAR2,
  p_post_pur                IN         VARCHAR2,
*/
  x_closed_per_ind          OUT NOCOPY NUMBER,
  x_crev_gl_trans_date      OUT NOCOPY DATE,
  x_open_gl_fiscal_year     OUT NOCOPY NUMBER,
  x_open_gl_period          OUT NOCOPY NUMBER,
/* Start INVCONV umoogala
  x_crev_curr_mthd          OUT NOCOPY VARCHAR2,
  x_crev_curr_calendar      OUT NOCOPY VARCHAR2,
  x_crev_curr_period        OUT NOCOPY VARCHAR2,
  x_crev_prev_mthd          OUT NOCOPY VARCHAR2,
  x_crev_prev_calendar      OUT NOCOPY VARCHAR2,
  x_crev_prev_period        OUT NOCOPY VARCHAR2,
*/
  x_inv_fiscal_year         OUT NOCOPY NUMBER,
  x_inv_period              OUT NOCOPY NUMBER,
  x_retstatus               OUT NOCOPY VARCHAR2,
  x_errbuf               		OUT NOCOPY VARCHAR2
  ) AS

  /* fiscal year */
  CURSOR c_fiscal_year(cp_le_id NUMBER, cp_ledger_id NUMBER,
                       cp_fiscal_year NUMBER)
  IS
    SELECT DISTINCT glp.period_year
      FROM
            gl_periods glp,
            gl_period_sets gps,
            gl_sets_of_books gsb
     WHERE
            glp.period_year           = cp_fiscal_year
       AND  gsb.set_of_books_id       = cp_ledger_id
       AND  gsb.period_set_name       = glp.period_set_name
       AND  gsb.accounted_period_type = glp.period_type
       AND  glp.period_set_name       = gps.period_set_name
  ;

  /* fiscal period */
  CURSOR c_gl_period(cp_le_id NUMBER, cp_ledger_id NUMBER,
                     cp_gl_fiscal_year NUMBER, cp_gl_period NUMBER,
                     cp_gl_date DATE)
  IS
    SELECT	glp.period_name, glp.period_year, glp.period_num,
            glp.start_date, glp.end_date, sts.closing_status
    FROM
          gl_periods glp,
          gl_period_statuses sts,
          gl_sets_of_books   gsob
    WHERE
           glp.period_set_name    = gsob.period_set_name       -- use the sob period-name
      AND  glp.period_type        = gsob.accounted_period_type -- and sob period-type
      AND  gsob.set_of_books_id   = cp_ledger_id
      AND  glp.period_year        = NVL(cp_gl_fiscal_year, glp.period_year)
      AND  glp.period_num         = NVL(cp_gl_period, glp.period_num)
      AND  NVL(trunc(cp_gl_date), glp.start_date)
              BETWEEN glp.start_date AND glp.end_date
      AND  glp.period_name        = sts.period_name -- for use of sts_u2 index
      AND  glp.period_num         = sts.period_num
      AND  glp.period_year        = sts.period_year
      AND  sts.set_of_books_id    = cp_ledger_id
      AND  sts.application_id     = (
                                      SELECT application_id
                                      FROM fnd_application
                                      WHERE application_short_name = 'SQLGL')
  ;

  l_gl_fiscal_year          NUMBER(15);
  l_gl_period               NUMBER(15);

  l_open_gl_date            DATE;
  l_posting_start_date      DATE;
  l_posting_end_date        DATE;

  l_gl_period_name          gl_periods.period_name%TYPE;
  l_gl_period_year          gl_periods.period_year%TYPE;
  l_gl_period_num           gl_periods.period_num%TYPE;

  l_gl_per_start_date       DATE;
  l_gl_per_real_start_date  DATE;
  l_gl_per_end_date         DATE;
  l_gl_per_real_end_date    DATE;

  l_gl_period_status        gl_period_statuses.closing_status%TYPE;
  l_gl_period_status_2      gl_period_statuses.closing_status%TYPE;

  l_closed_per_ind          NUMBER(2) := 0;
  l_crev_gl_trans_date      DATE;
  l_crev_gl_date            DATE;

  l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_PARAMETERS';

  l_co_source          VARCHAR2(1);
  l_source_selected    BOOLEAN;

  l_retstatus          VARCHAR2(1);
  l_inv_fiscal_year    org_acct_periods.period_year%TYPE := NULL;
  l_inv_period         org_acct_periods.period_num%TYPE  := NULL;
  l_errbuf             VARCHAR2(2000);
  l_lot_actual_cost    NUMBER := 0;
  l_post_cm            VARCHAR2(2);

  /* exceptions */
  e_invalid_parameter  EXCEPTION;

BEGIN

  g_log_msg := 'Begin of procedure '|| l_procedure_name;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  --
  -- Validating GL Fiscal Year
  --
  g_log_msg := 'validating GL Fiscal Year';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  l_gl_fiscal_year := TO_NUMBER(p_gl_fiscal_year);

  OPEN c_fiscal_year(g_legal_entity_id, g_ledger_id, l_gl_fiscal_year);
  FETCH c_fiscal_year INTO l_gl_fiscal_year;
  IF( c_fiscal_year%NOTFOUND )
  THEN
    x_errbuf := 'Invalid GL Fiscal Year: ' || l_gl_fiscal_year ;
    CLOSE c_fiscal_year;
    RAISE e_invalid_parameter;
  END IF;
  CLOSE c_fiscal_year;


  --
  -- Validating GL Period
  --
  g_log_msg := 'validating GL Period';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  l_gl_period := TO_NUMBER(p_gl_period);

  OPEN c_gl_period(g_legal_entity_id, g_ledger_id, l_gl_fiscal_year, l_gl_period, null);
  FETCH c_gl_period INTO l_gl_period_name, l_gl_period_year, l_gl_period_num,
                         l_gl_per_start_date, l_gl_per_end_date, l_gl_period_status;
  IF( c_gl_period%NOTFOUND )
  THEN
    x_errbuf := 'Invalid GL Period: ' || l_gl_period ;
    CLOSE c_gl_period;
    RAISE e_invalid_parameter;
  END IF;
  CLOSE c_gl_period;

  --
  -- Validating date ranges
  --
  g_log_msg := 'validating date ranges';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  l_gl_per_real_start_date := gmf_legal_entity_tz.convert_le_to_srv_tz(l_gl_per_start_date, g_legal_entity_id);                   /* Bug#5623121 ANTHIYAG 30-Oct-2006 */
  l_gl_per_real_end_date   := gmf_legal_entity_tz.convert_le_to_srv_tz(l_gl_per_end_date + 1 - (1/86400), g_legal_entity_id);     /* Bug#5623121 ANTHIYAG 30-Oct-2006 */

  l_open_gl_date 	     := FND_DATE.canonical_to_date(p_open_gl_date);
  l_posting_start_date := FND_DATE.canonical_to_date(p_posting_start_date);
  l_posting_end_date   := FND_DATE.canonical_to_date(p_posting_end_date);

  /* Validate if dates are correct */
  IF( l_posting_start_date > l_posting_end_date )
  THEN
    fnd_message.set_name('GMF', 'GL_INVALID_DATERANGE');
    x_errbuf := fnd_message.get;
    RAISE e_invalid_parameter;
  END IF;

  --
  -- Validating posting dates against GL Period
  --
  g_log_msg := 'Validating posting dates against GL Period';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  /* Validate against the periods real start and end dates */
  /* Note: is this additional validation necessary? */
  IF  (l_posting_start_date < l_gl_per_real_start_date            /* Bug#5623121 ANTHIYAG 30-Oct-2006 */
  AND l_gl_per_real_start_date IS NOT NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMF','GMF_INVALID_DATE_FOR_PERIOD');
    FND_MESSAGE.SET_TOKEN('S1', fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, l_posting_start_date), 'FND_NO_CONVERT'));
    FND_MESSAGE.SET_TOKEN('S2', fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, l_gl_per_real_start_date), 'FND_NO_CONVERT'));
    FND_MESSAGE.SET_TOKEN('S3', fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, l_gl_per_real_end_date), 'FND_NO_CONVERT'));
    x_errbuf := fnd_message.get;
    RAISE e_invalid_parameter;
  END IF;

  IF  (l_posting_end_date > l_gl_per_real_end_date                /* Bug#5623121 ANTHIYAG 30-Oct-2006 */
  AND l_gl_per_real_end_date IS NOT NULL)
  THEN
    FND_MESSAGE.SET_NAME('GMF','GMF_INVALID_DATE_FOR_PERIOD');
    FND_MESSAGE.SET_TOKEN('S1', fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, l_posting_end_date), 'FND_NO_CONVERT'));
    FND_MESSAGE.SET_TOKEN('S2', fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, l_gl_per_real_start_date), 'FND_NO_CONVERT'));
    FND_MESSAGE.SET_TOKEN('S3', fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, l_gl_per_real_end_date), 'FND_NO_CONVERT'));
    x_errbuf := fnd_message.get;
    RAISE e_invalid_parameter;
  END IF;

  --
  -- check the status of gl_period passed in
  --
  g_log_msg := 'verifying the status of gl_period passed in. status: ' || l_gl_period_status;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  IF( l_gl_period_status NOT IN ('F','N','O') )
  THEN
    IF( l_open_gl_date IS NULL )
    THEN
      x_errbuf := 'GL Period is closed. Open GL date required' ;
      g_log_msg := 'error: ' || x_errbuf;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;

      RAISE e_invalid_parameter;
    END IF;

    /* get the open gl date's year/period */
    OPEN c_gl_period(g_legal_entity_id, g_ledger_id, NULL, NULL, l_open_gl_date);
    FETCH c_gl_period INTO l_gl_period_name, l_gl_period_year, l_gl_period_num,
                           l_gl_per_start_date, l_gl_per_end_date, l_gl_period_status_2;

    IF( c_gl_period%NOTFOUND )
    THEN
      x_errbuf := 'Unable to find period for Open GL Date: ' || to_char(l_open_gl_date,'YYYY/MM/DD HH24:MI:SS') ;
      CLOSE c_gl_period;
      g_log_msg := 'error: ' || x_errbuf;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;


      RAISE e_invalid_parameter;
    END IF;
    CLOSE c_gl_period;

    IF( l_gl_period_status_2 NOT IN ('F','N','O') )
    THEN
      x_errbuf := 'Open GL Date not in an Open GL Period' ;
      g_log_msg := 'error: ' || x_errbuf;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;

      RAISE e_invalid_parameter;
    END IF;

    l_closed_per_ind      := 1;
    x_open_gl_fiscal_year := l_gl_period_year;
    x_open_gl_period      := l_gl_period_num;

  ELSE
    l_closed_per_ind := 0;  /* Bug 2230751 */
  END IF;  /* closed per */

  x_closed_per_ind := l_closed_per_ind;

  /* validate the sources */
  l_source_selected := TRUE;


  /**
  * check costing parameters
  * Note: the rval current period dates must be checked against
  * the gl period's real start and end date
  * we already validate if the posting st/end dates are within
  * the real st/end dates.
  */

  IF  (g_process_category = 'REVALUATION_TRANSACTIONS')
  AND (g_cost_method_type <> 6)  /* Non-Lot Cost Method */
  THEN
    g_log_msg := 'calling check_costing procedure';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;


    check_costing(
      p_test_posting 	     => p_test_posting,
      p_period_start_date  => l_gl_per_real_start_date,
      p_period_end_date    => l_gl_per_real_end_date,
      p_closed_period_ind  => l_closed_per_ind,
      p_open_gl_date 	     => l_open_gl_date,
      x_crev_gl_trans_date => x_crev_gl_trans_date,
      x_inv_fiscal_year    => l_inv_fiscal_year,
      x_inv_period 	       => l_inv_period,
      x_retstatus 	       => l_retstatus,
      x_errbuf 	           => l_errbuf)
    ;

    IF( l_retstatus <> 'S' )
    THEN
      x_errbuf := l_errbuf;
      g_log_msg := l_procedure_name || ': error returned from check_costing procedure. ' ||
                   'error: ' || x_errbuf;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;


      RAISE e_invalid_parameter;
    ELSE
      x_inv_fiscal_year := l_inv_fiscal_year;
      x_inv_period      := l_inv_period;
    END IF;
  END IF;

  x_retstatus := 'S';

EXCEPTION
  WHEN e_invalid_parameter THEN
    x_retstatus := 'E';

  WHEN others THEN
    x_retstatus := 'E';
    x_errbuf := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

    g_log_msg := 'in when other. error: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;
END validate_parameters;

/*************************************************************************************************
 *  PROCEDURE
 *    insert_control_record
 *
 *  DESCRIPTION
 *    Inserts a control record after verifying there is no other running or
 *    scheduled process for the same parameters.
 *
 *  INPUT PARAMETERS
 *    All columns of the control table
 *
 *  ASSUMPTIONS
 *    All column data have been validated and if CM source is selected then
 *    appropriate INV calendar parameters have also been validated.
 *
 *  HISTORY
 *    26-Dec-2002 Rajesh Seshadri
 *    Uday Phadtare SEP-08-2008 Bug 7355006. If process_category is 'PRODUCTIONS_TRANSACTIONS'
 *    then set l_post_pm as 1.
 *************************************************************************************************/
PROCEDURE insert_control_record(
  p_user_id                IN         NUMBER,
  p_gl_fiscal_year         IN         NUMBER,
  p_gl_period              IN         NUMBER,
  p_posting_start_date     IN         DATE,
  p_posting_end_date       IN         DATE,
  p_test_posting           IN         VARCHAR2,
/* Start INVCONV umoogala
  p_post_cm                IN         VARCHAR2,
  p_post_ic                IN         VARCHAR2,
  p_post_om                IN         VARCHAR2,
  p_post_op                IN         VARCHAR2,
  p_post_pm                IN         VARCHAR2,
  p_post_po                IN         VARCHAR2,
  p_post_pur               IN         VARCHAR2,
*/
  p_closed_per_ind         IN         NUMBER,
  p_open_gl_date           IN         DATE,
  p_crev_gl_trans_date     IN         DATE,
  p_open_gl_fiscal_year    IN         NUMBER,
  p_open_gl_period         IN         NUMBER,
  p_post_if_no_cost        IN         VARCHAR2,
  p_default_language       IN         VARCHAR2,
/* Start INVCONV umoogala
  p_crev_curr_mthd         IN         VARCHAR2,
  p_crev_curr_calendar     IN         VARCHAR2,
  p_crev_curr_period       IN         VARCHAR2,
  p_crev_prev_mthd         IN         VARCHAR2,
  p_crev_prev_calendar     IN         VARCHAR2,
  p_crev_prev_period       IN         VARCHAR2,
*/
  p_inv_fiscal_year        IN         VARCHAR2,
  p_inv_period             IN         NUMBER,
  x_subledger_ref_no       OUT NOCOPY NUMBER,
  x_retstatus              OUT NOCOPY VARCHAR2,
  x_errbuf                 OUT NOCOPY VARCHAR2
  ) AS


  CURSOR c_sch(cp_le_id NUMBER,  cp_ledger_id NUMBER, cp_cost_type_id NUMBER,
               cp_gl_fiscal_year NUMBER, cp_gl_period  NUMBER,
               cp_post_cm VARCHAR2, cp_post_ic VARCHAR2,
               cp_post_om VARCHAR2, cp_post_pm VARCHAR2,
               cp_post_pur VARCHAR2 )
  IS
    SELECT reference_no, request_id, count(*) over()
      FROM gl_subr_sta
     WHERE legal_entity_id   = cp_le_id
       AND ledger_id         = cp_ledger_id
       AND cost_type_id      = cp_cost_type_id
       AND fiscal_year       = cp_gl_fiscal_year
       AND period            = cp_gl_period
       AND completion_ind    = 0
       AND stop_ind          = 0
       AND rownum            = 1
       AND ((post_ic         = cp_post_ic  AND post_ic  = 1) OR
            (post_pm         = cp_post_pm  AND post_pm  = 1) OR
            (post_cm         = cp_post_cm  AND post_cm  = 1) OR
            (post_om         = cp_post_om  AND post_om  = 1) OR
            (post_pur        = cp_post_pur AND post_pur = 1))
    ;


  l_reference_no      gl_subr_sta.reference_no%TYPE;
  l_request_id        gl_subr_sta.request_id%TYPE;
  l_sch_count         NUMBER(15);
  l_subledger_ref_no  NUMBER(15)  := NULL;

  e_insert_error      EXCEPTION;
  l_procedure_name CONSTANT VARCHAR2(30) := 'INSERT_CONTROL_RECORD';

  l_post_cm	   VARCHAR2(1) := 0;
  l_post_ic	   VARCHAR2(1) := 0;
  l_post_om	   VARCHAR2(1) := 0;
  l_post_pm	   VARCHAR2(1) := 0;
  l_post_pur   VARCHAR2(1) := 0;

  l_period_id  gmf_period_statuses.period_id%TYPE;


BEGIN

  g_log_msg := 'Begin of procedure '|| l_procedure_name;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  x_retstatus := 'E';

  IF  (g_process_category = 'REVALUATION_TRANSACTIONS') THEN l_post_cm  := 1; END IF;
  IF  (g_process_category = 'INVENTORY_TRANSACTIONS')   THEN l_post_ic  := 1; END IF;
  IF  (g_process_category = 'PRODUCTION_TRANSACTIONS')  THEN l_post_pm  := 1; END IF;

  -- Bug: 8978816 Vpedarla modified the below line. Since Order management entity is not getting executed in pre-processor wrapper
  IF  (g_process_category = 'ORDER_MANAGEMENT_TRANSACTIONS')         THEN l_post_om  := 1; END IF;
 -- IF  (g_process_category = 'ORDER_MANAGEMENT')         THEN l_post_om  := 1; END IF;
  IF  (g_process_category = 'PURCHASING_TRANSACTIONS')  THEN l_post_pur := 1; END IF;
  IF  (g_process_category = 'PRODUCTIONS_TRANSACTIONS') THEN l_post_pm  := 1; END IF; --Bug 7355006

  /* check for already running or scheduled process for same params */
  g_log_msg := 'check for already running or scheduled process for same params';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  open c_sch (g_legal_entity_id, g_ledger_id, g_cost_type_id,
              p_gl_fiscal_year, p_gl_period,
              l_post_cm, l_post_ic, l_post_om, l_post_pm, l_post_pur);
  FETCH c_sch INTO l_reference_no, l_request_id, l_sch_count;
  CLOSE c_sch;

  IF( l_sch_count > 0 )
  THEN
    fnd_message.set_name('GMF','GL_TRN_POST_SCHEDULED');
    fnd_message.set_token('S1', l_reference_no);
    fnd_message.set_token('S2', l_request_id);
    x_errbuf := fnd_message.get;
    RAISE e_insert_error;
  END IF;

  IF g_cost_method_type = 6
  THEN
   l_period_id := 0;
  ELSE
    /* Getting period_id for LE, CT and dates */
    g_log_msg := 'Getting period_id for LE, CT and dates.';

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

    BEGIN
      SELECT period_id
        INTO l_period_id
        FROM gmf_period_statuses prdsta
       WHERE
             prdsta.legal_entity_id = g_legal_entity_id
         AND prdsta.cost_type_id    = g_cost_type_id
         AND p_posting_start_date between prdsta.start_date and prdsta.end_date
         AND p_posting_end_date between prdsta.start_date and prdsta.end_date
      ;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        fnd_message.set_name('GMF','GMF_PERIOD_NOT_FOUND');
        fnd_message.set_token('S1', g_legal_entity_name);
        fnd_message.set_token('S2', g_cost_type_code);
        fnd_message.set_token('S3', p_posting_start_date);
        fnd_message.set_token('S4', p_posting_end_date);
        x_errbuf := fnd_message.get;
        RAISE e_insert_error;
    END;
  END IF;

  -- B 7203807
  Select gem5_reference_no_s.NEXTVAL INTO l_subledger_ref_no From Dual;

    /* insert the control record */
  INSERT INTO gl_subr_sta
  (
    co_code,
    current_state,
    start_time,
    end_time,
    completion_ind,
    started_by,
    stop_ind,
    reference_no,
    fiscal_year,
    period,
    period_start_date,
    period_end_date,
    test_posting,
    scheduled_on,
    aborted_by,
    update_stage,
    errors_found,
    errors_posted,
    errors_limit,
    rows_posted,
    abort_reason,
    creation_date,
    created_by,
    delete_mark,
    in_use,
    last_update_date,
    last_updated_by,
    closed_per_ind,
    gl_date,
    gl_fiscal_year,
    gl_period,
    incl_no_cost,
    default_language,
    crev_curr_mthd,
    crev_curr_calendar,
    crev_curr_period,
    crev_prev_mthd,
    crev_prev_calendar,
    crev_prev_period,
    crev_gl_trans_date,
    crev_inv_prev_cal,
    crev_inv_prev_per,
    legal_entity_id,
    legal_entity_name,
    ledger_id,
    process_category,
    cost_type_id,
    period_id,
    cost_mthd_code,
    cost_type,
    default_cost_type_id,
    default_cost_mthd_code,
    cost_basis,
    extract_hdr_rows_posted,
    extract_line_rows_posted,
    crev_curr_cost_type_id,
    crev_curr_period_id,
    crev_prev_cost_type_id,
    crev_prev_period_id,
    post_cm,
    post_ic,
    post_om,
    post_pm,
    post_pur,
    base_currency
  )
  SELECT
    NULL,                       /* co_code */
    0,	                        /* current_state */
    NULL, 	                    /* start_time */
    NULL,	                      /* end_time */
    0,	                        /* completion_ind */
    p_user_id, 	                /* started_by */
    0,	                        /* stop_ind */
    l_subledger_ref_no,         /* reference_no B7203807 */
    p_gl_fiscal_year,	          /* fiscal_year */
    p_gl_period,		            /* period */
    p_posting_start_date,       /* period_start_date */
    p_posting_end_date,	                 /* period_end_date */
    DECODE(p_test_posting,'N',0,1),
    FND_DATE.date_to_canonical(SYSDATE), /* scheduled_on - always sysdate */
    NULL,	                      /* aborted_by */
    0,	                        /* update_stage */
    0,	                        /* errors_found */
    0,	                        /* errors_posted */
    0,	                        /* errors_limit */
    0, 	                        /* rows_posted */
    NULL, 	                    /* abort_reason */
    SYSDATE,	                  /* creation_date */
    p_user_id,	                /* created_by */
    0,	                        /* delete_mark */
    0, 	                        /* in_use */
    SYSDATE, 	                  /* last_update_date */
    p_user_id, 	                /* last_updated_by */
    p_closed_per_ind,           /* closed_per_ind */
    p_open_gl_date,	            /* gl_date */
    p_open_gl_fiscal_year,	    /* gl_fiscal_year */
    p_open_gl_period,	          /* gl_period */
    DECODE(p_post_if_no_cost,'Y',1,0),	 /* incl_no_cost */
    p_default_language,		               /* default_language */
    g_crev_curr_cost_mthd_code, /* crev_curr_mthd */
    g_crev_curr_calendar,       /* crev_curr_calendar */
    g_crev_curr_period,       	/* crev_curr_period */
    g_crev_prev_cost_mthd,      /* crev_prev_mthd */
    g_crev_prev_calendar,    	  /* crev_prev_calendar */
    g_crev_prev_period,		      /* crev_prev_period */
    g_crev_gl_trans_date,
    p_inv_fiscal_year,
    p_inv_period,
    g_legal_entity_id,
    g_legal_entity_name,
    g_ledger_id,
    g_process_category,
    g_cost_type_id,
    l_period_id,
    g_cost_type_code,           /* cost_mthd_code */
    g_cost_method_type,         /* cost_type */
    g_default_cost_type_id,
    DECODE(g_default_cost_type_id, NULL, NULL,             /* default_lot_cost_mthd */
      (SELECT default_lot_cost_mthd from cm_mthd_mst
        WHERE cost_type_id      = g_default_cost_type_id
          AND delete_mark       = 0)),
    plcy.cost_basis,
    0,                          /* extract_hdr_rows_posted, */
    0,                          /* extract_line_rows_posted, */
    g_crev_curr_cost_type_id,
    g_crev_curr_period_id,
    g_crev_prev_cost_type_id,
    g_crev_prev_period_id,
    l_post_cm,
    l_post_ic,
    l_post_om,
    l_post_pm,
    l_post_pur,
    plcy.base_currency_code
  FROM
    gmf_fiscal_policies plcy
  WHERE
        plcy.legal_entity_id   = g_legal_entity_id
    AND plcy.delete_mark       = 0
  ;

  IF sql%rowcount = 0
  THEN
    x_errbuf := l_procedure_name || ': failed to insert control record';
    g_log_msg := 'failed to insert control record';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;
    l_subledger_ref_no := NULL; -- B7203807
    RAISE e_insert_error;
  END IF;

  x_subledger_ref_no := l_subledger_ref_no;

  x_retstatus := 'S';

  g_log_msg := l_procedure_name || ': ' || sql%rowcount || ' control record inserted into gl_subr_sta table. ' ||
               ' end of procedure';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


EXCEPTION
  WHEN e_insert_error
  THEN

    g_log_msg := x_errbuf;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

    x_retstatus := 'E';

END insert_control_record;

/**********************************************************************************
 # PROCEDURE
 #    check_costing
 # SYNOPSIS
 #    proc check_costing
 # DESCRIPTION
 #    procedure to fetch cost revaluation parameters and other
 #    initializations	for cost revalualtion.
 # HISTORY
 #  Sukarna Reddy dt 01/08/01 Bug 1108647 Perform Posting only if
 #  the inventory period  is final close. In case of test posting
 #  preliminary closed inventory period is OK.
 #  Venkat Chukkapalli 06/19/01 Bug 1837429 Modified the check to
 #  make sure that subledger period start and end dates are within
 #  current reval period.
 #  Anand Thiyagarajan Bug#5623121 30-Oct-2006
 #    Modified Code to fetch the prior period inventory period details
 #    and the status of preliminary close from the gmf_period_balances
 #    table rather than calling the procedure gmf_periodclose_pub.
 #  Uday Phadtare Bug 7503258 NOV-18-2008. Modified CURSOR cur_inv_period_status
 #    to avoid error CM_AC_INVENT_NOT_CL when running OPM Accounting Pre-processor.
 **********************************************************************************/

PROCEDURE check_costing(
  p_test_posting         IN VARCHAR2,
  p_period_start_date    IN DATE,
  p_period_end_date      IN DATE,
  p_closed_period_ind    IN  NUMBER,
  p_open_gl_date         IN  DATE,
  x_crev_gl_trans_date   OUT NOCOPY DATE,
/* Start INVCONV umoogala
  x_crev_curr_mthd       OUT NOCOPY VARCHAR2,
  x_crev_curr_calendar   OUT NOCOPY VARCHAR2,
  x_crev_curr_period     OUT NOCOPY VARCHAR2,
  x_crev_prev_mthd       OUT NOCOPY VARCHAR2,
  x_crev_prev_calendar   OUT NOCOPY VARCHAR2,
  x_crev_prev_period     OUT NOCOPY VARCHAR2,
*/
  x_inv_fiscal_year      OUT NOCOPY NUMBER,
  x_inv_period           OUT NOCOPY NUMBER,
  x_retstatus            OUT NOCOPY VARCHAR2,
  x_errbuf               OUT NOCOPY VARCHAR2
  )
IS


  CURSOR c_stend(cp_period_id NUMBER)
  IS
    SELECT start_date, end_date
      FROM gmf_period_statuses
     WHERE period_id = cp_period_id
  ;

  lc_prior_stend_tmp c_stend%ROWTYPE;
  lc_curr_stend_tmp  c_stend%ROWTYPE;

  -- X_crev_prior_end_date cm_cldr_dtl.end_date%TYPE;
  -- X_crev_curr_start_date cm_cldr_dtl.start_date%TYPE;

  /* TBD - what about cost_mthd ? */
  CURSOR c_chk_consq_perd(cp_le_id number, cp_cost_type_id number,
                          cp_prior_end_date DATE, cp_curr_start_date DATE)
  IS
    SELECT COUNT(1)
      FROM gmf_period_statuses
     WHERE legal_entity_id =  cp_le_id
       -- AND cost_type_id    =  cp_cost_type_id
       AND start_date      >= cp_prior_end_date
       AND end_date        <= cp_curr_start_date
  ;

  CURSOR c_check_icperd(cp_co_code VARCHAR2,
                        cp_inv_fiscal_year VARCHAR2, cp_inv_period NUMBER) IS
  SELECT closed_period_ind
  FROM   ic_cldr_dtl
  WHERE
  orgn_code = cp_co_code
  AND fiscal_year = cp_inv_fiscal_year
  AND period = cp_inv_period;

  /* Bug#5623121 ANTHIYAG 30-Oct-2006 Start */
  CURSOR cur_prior_period_id
  (
  p_legal_entity_id       NUMBER,
  p_cost_type_id          NUMBER,
  p_period_start_date     DATE,
  p_period_end_date       DATE
  )
  IS
  SELECT                  preprd.period_id
  FROM                    gmf_period_statuses prdsta,
                          gmf_period_statuses preprd
  WHERE                   prdsta.legal_entity_id = p_legal_entity_id
  AND                     prdsta.cost_type_id    = p_cost_type_id
  AND                     preprd.legal_entity_id = prdsta.legal_entity_id
  AND                     preprd.cost_type_id = prdsta.cost_type_id
  AND                     p_period_start_date between prdsta.start_date and prdsta.end_date
  AND                     p_period_end_date between prdsta.start_date and prdsta.end_date
  AND                     preprd.end_date < prdsta.end_date
  ORDER BY                preprd.end_date desc;

  --Bug 7503258. Added outer joins and decode of oap.open_flag
  CURSOR cur_inv_period_status
  (
  p_period_id            NUMBER
  )
  IS
  SELECT                NVL(SUM(DECODE(NVL(gpb.period_close_status,DECODE(oap.open_flag,'Y','~','P')),
                                       'F',1,'P',1, 0)),0) AS close_status
  FROM                  org_acct_periods oap,
                        hr_organization_information hoi,
                        mtl_parameters mp,
                        gmf_period_statuses gps,
                        gl_ledgers gl,
                        gmf_period_balances gpb
  WHERE                 gps.period_id = p_period_id
  AND                   hoi.org_information2 = gps.legal_entity_id
  AND                   hoi.org_information1 = gl.ledger_id
  AND                   oap.period_set_name = gl.period_set_name
  AND                   hoi.org_information_context = 'Accounting Information'
  AND                   hoi.organization_id = oap.organization_id
  AND                   hoi.organization_id = mp.organization_id
  AND                   mp.process_enabled_flag = 'Y'
  AND                   oap.schedule_close_date =  TRUNC(gps.end_date)
  AND                   oap.organization_id = gpb.organization_id(+)
  AND                   oap.acct_period_id = gpb.acct_period_id(+);

  l_prior_period_id      NUMBER;
  l_close_status         NUMBER;
  /* Bug#5623121 ANTHIYAG 30-Oct-2006 End */

  l_close_per_ind        NUMBER(5);
  X_count                NUMBER(15);
  X_rvar                 NUMBER(15);

  l_inv_fiscal_year      ic_cldr_hdr.fiscal_year%TYPE;
  l_inv_period           ic_cldr_dtl.period%TYPE;
  l_inv_per_start_date   DATE;
  l_inv_per_end_date     DATE;
  l_inv_per_synch        VARCHAR2(1);
  l_retstatus            VARCHAR2(1);
  l_errbuf               VARCHAR2(2000);

  e_reval_error          exception;

  l_procedure_name       CONSTANT VARCHAR2(30) := 'CHECK_COSTING';

  l_inv_period_close_status BOOLEAN;

BEGIN

  g_log_msg := 'Begin of procedure '|| l_procedure_name;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  x_retstatus := 'E';


  IF g_crev_curr_period_id IS NULL or g_crev_prev_period_id IS NULL
  THEN
    fnd_message.set_name('GMF','CM_NO_RVAL_PARMS');
    x_errbuf := fnd_message.get;
    RAISE e_reval_error;
  END IF;


  --
  -- Check to see if current and prior period are successive
  --
  -- First get the start and end date for the cost reval prior period.
  -- OPEN c_stend(p_co_code, lc_reval_tmp.crev_prior_calendar, lc_reval_tmp.crev_prior_period);
  --
  g_log_msg := 'Check to see if current and prior period are successive';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  OPEN c_stend(g_crev_prev_period_id);
  FETCH c_stend INTO lc_prior_stend_tmp;
  IF( c_stend%NOTFOUND )
  THEN
    CLOSE c_stend;
    -- fnd_message.set_name('GMF','GMF_BAD_CREV_PRIOR_PERIOD');
    x_errbuf := 'Unable to find period dates for prior period' ;
    RAISE e_reval_error;
  END IF;
  CLOSE c_stend;

  --
  -- Now get the start and end date for the cost reval current period.
  --
  g_log_msg := 'Now get the start and end date for the cost reval current period';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  OPEN c_stend(g_crev_curr_period_id);
  FETCH c_stend  INTO  lc_curr_stend_tmp;
  IF( c_stend%NOTFOUND )
  THEN
    CLOSE c_stend;
    x_errbuf := 'Unable to find period dates for current period' ;
    RAISE e_reval_error;
  END IF;
  CLOSE c_stend;

  /*
   * Check if there is any period between the end_date of prior period and
   * start_date of current period. If there are any then period are not
   * consecutive. Display the message and return the error
   */
  g_log_msg := 'Check for consecutive periods';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;


  --
  -- Get the no of rows between the periods
  --
  OPEN c_chk_consq_perd(g_legal_entity_id, g_cost_type_id,
                        lc_prior_stend_tmp.end_date, lc_curr_stend_tmp.start_date);
  FETCH c_chk_consq_perd INTO X_count;
  CLOSE c_chk_consq_perd;
  IF( X_count > 0 )
  THEN
    fnd_message.set_name('GMF','CM_NOT_CONSEC_PRD');
    x_errbuf := fnd_message.get;
    RAISE e_reval_error;
  END IF;

  --
  -- Get the inventory period for the costing period
  -- TBD how to send errors from this proc?
  --

  /* Bug#5623121 ANTHIYAG 30-Oct-2006 Start */
  g_log_msg := l_procedure_name || ': Getting the inventory period for the Previous costing period';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  /******************************************************************************************
  * Based on LE, Cost type, Period Start and End Dates fetch the Previous costing period id *
  ******************************************************************************************/
  OPEN cur_prior_period_id  (
                            p_legal_entity_id  => g_legal_entity_id,
                            p_cost_type_id => g_cost_type_id,
                            p_period_start_date => p_period_start_date,
                            p_period_end_date => p_period_end_date
                            );
  FETCH cur_prior_period_id INTO l_prior_period_id;
  CLOSE cur_prior_period_id;

  /*************************************************************************
  * Fetch Inventory period and year for the Prior Period Costing Period Id *
  *************************************************************************/
  BEGIN
    SELECT          period_year,
                    period_num
    INTO            x_inv_fiscal_year,
                    x_inv_period
    FROM            org_acct_periods oap,
                    hr_organization_information hoi,
                    gmf_period_statuses gps,
                    gl_ledgers gl
    WHERE           gps.period_id = l_prior_period_id
    AND             hoi.org_information2 = gps.legal_entity_id
    AND             hoi.org_information1 = gl.ledger_id
    AND             oap.period_set_name = gl.period_set_name
    AND             hoi.org_information_context = 'Accounting Information'
    AND             hoi.organization_id = oap.organization_id
    AND             oap.schedule_close_date =  TRUNC(gps.end_date)
    AND             ROWNUM = 1;
  EXCEPTION
    WHEN no_data_found THEN
      x_inv_fiscal_year := NULL;
      x_inv_period := NULL;
  END;

  g_log_msg := l_procedure_name || ': Inventory Period Year and Number fetched is : ' || x_inv_fiscal_year ||'/'|| x_inv_period;
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  /*************************************************************************************
  * Check if atleast premilinary close has been done for the Previous Inventory Period *
  *************************************************************************************/
  OPEN cur_inv_period_status (p_period_id => l_prior_period_id);
  FETCH cur_inv_period_status INTO l_close_status;
  CLOSE cur_inv_period_status;

  IF (NVL (l_close_status, 0) <= 0) THEN
    g_log_msg := l_procedure_name || ': Inventory Period Year and Number: ' || x_inv_fiscal_year ||'/'|| x_inv_period || ' is not closed ';
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;
    FND_MESSAGE.SET_NAME ('GMF', 'CM_AC_INVENT_NOT_CL');
    x_errbuf := fnd_message.get;
    RAISE e_reval_error;
  END IF;
  /* Bug#5623121 ANTHIYAG 30-Oct-2006 End */

  --
  -- Check current costing period is equivalent to gl yr/prd
  -- Bug 1837429
  --
  g_log_msg := l_procedure_name || ': Check current costing period is equivalent to gl yr/prd';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  IF( p_period_start_date < lc_curr_stend_tmp.start_date OR
      p_period_start_date > lc_curr_stend_tmp.end_date OR
      p_period_end_date < lc_curr_stend_tmp.start_date OR
      p_period_end_date > lc_curr_stend_tmp.end_date)
  THEN
    fnd_message.set_name('GMF','GL_INVALID_CURR_REVALPRD');
    x_errbuf := fnd_message.get;
    RAISE e_reval_error;
  END IF;


  g_log_msg := l_procedure_name || ': Checking whether GL Date ' || to_char(g_crev_gl_trans_date, 'DD-MON-YYYY') ||
                ' is with data range: ' || to_char(p_period_start_date,  'DD-MON-YYYY') || ' and ' || to_char(p_period_end_date,  'DD-MON-YYYY');
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  /* Bug 2230751 */
  IF (p_closed_period_ind = 0)
  THEN
    IF (gmf_legal_entity_tz.convert_le_to_srv_tz(g_crev_gl_trans_date, g_legal_entity_id) NOT BETWEEN p_period_start_date and p_period_end_date)  /* Bug#5623121 ANTHIYAG 30-Oct-2006 */
    THEN
      fnd_message.set_name('GMF','GMF_GL_DATE_MUST_WITHIN_PERIOD');
      fnd_message.set_token('START_DATE', fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, p_period_start_date), 'FND_NO_CONVERT')); /* Bug#5623121 ANTHIYAG 30-Oct-2006 */
      fnd_message.set_token('END_DATE',fnd_date.date_to_displayDT(gmf_legal_entity_tz.convert_srv_to_le(g_legal_entity_id, p_period_end_date), 'FND_NO_CONVERT')); /* Bug#5623121 ANTHIYAG 30-Oct-2006 */
      x_errbuf := fnd_message.get;
      RAISE e_reval_error;
    ELSE
      x_crev_gl_trans_date := g_crev_gl_trans_date;
    END IF;
  ELSIF(p_closed_period_ind = 1)
  THEN
    x_crev_gl_trans_date := p_open_gl_date;
    g_crev_gl_trans_date := p_open_gl_date;
  END IF;

  x_retstatus := 'S';

EXCEPTION
  WHEN e_reval_error THEN
    x_retstatus := 'E';

    g_log_msg := l_procedure_name || ': error: ' || x_errbuf;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

END check_costing;

/*##########################################################################
  # NAME
  #     inter_mod_cal_conv
  #
  # RETURNS
  #  The matching Inv fiscal year and period if they exist.
  #
  #  In addition we return the following information in x_inv_per_synch
  #  if there is a matching Inv period.
  #
  #  Y - If the Inv period is identical to the source-period
  #      (the start/end dates match)
  #  N - If the Inv period is not identical to the source-period
  #      (the end date matches but not the start date)
  #
  #  If a matching Inv period does not exist or in case of db or unknown
  #  errors we return 'E' in the status.
  #
  # NOTES:
  #  The second cursor for the inv periods as found in GLSLDDS.fmb
  #  is not needed as the same info can be retrieved by fetching again
  #  from the first cursor on ic_cldr tables.  Again this is only needed
  #  for the start date of the matching inv period.
  #  The start/end dates are not used elsewhere!!
  #
  # HISTORY
  #   12-Nov-99 Rajesh Seshadri Bug 1064535 - use delete_mark on ic_cldr_hdr
  ############################################################################# */

PROCEDURE inter_mod_cal_conv(
  x_inv_fiscal_year    OUT NOCOPY NUMBER,
  x_inv_period         OUT NOCOPY NUMBER,
  x_inv_per_synch      OUT NOCOPY VARCHAR2,
  x_inv_per_start_date OUT NOCOPY DATE,
  x_inv_per_end_date   OUT NOCOPY DATE,
  x_retstatus          OUT NOCOPY VARCHAR2,
  x_errbuf             OUT NOCOPY VARCHAR2 )
IS

/* Start INVCONV umoogala
  CURSOR c_cmsrc_info(cp_co_code VARCHAR2, cp_source_calendar VARCHAR2, cp_source_period VARCHAR2) IS
*/
  CURSOR c_cmsrc_info(cp_period_id number)
  IS
    SELECT start_date, end_date
      FROM gmf_period_statuses
     WHERE period_id = cp_period_id
  ;

  lc_cmcal_info c_cmsrc_info%ROWTYPE;


  CURSOR c_ictrg_info(cp_le_id NUMBER, cp_cm_end_date DATE)
  IS
    SELECT
           d1.period_year fiscal_year, d1.period_num period,
           d1.period_start_date begin_date, d2.schedule_close_date period_end_date
      FROM
           org_organization_definitions org,
           org_acct_periods d1,
           org_acct_periods d2
     WHERE
           org.legal_entity      = cp_le_id
       AND d2.period_year        = d1.period_year
       AND org.organization_id   = d1.organization_id
       AND org.organization_id   = d2.organization_id
       AND TRUNC(d1.schedule_close_date+1-1/86400) = TRUNC(cp_cm_end_date)
       AND d2.schedule_close_date  <= d1.schedule_close_date
     ORDER BY
         d2.schedule_close_date desc
  ;

  lc_iccal_info c_ictrg_info%ROWTYPE;

  --
  -- to get the begin date of ic period
  --
  l_is_first_inv_period   BOOLEAN;
  lc_iccal_info2          c_ictrg_info%ROWTYPE;
  e_invalid_inv_period    EXCEPTION;
  l_procedure_name CONSTANT VARCHAR2(30) := 'INTER_MOD_CAL_CONV';

BEGIN

  g_log_msg := 'Begin of procedure '|| l_procedure_name;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  x_inv_per_synch := 'N';
  x_retstatus := 'E';

  --
  --
  --
  OPEN c_cmsrc_info(g_crev_prev_period_id);
  FETCH c_cmsrc_info INTO lc_cmcal_info;
  IF (c_cmsrc_info%NOTFOUND) THEN
    CLOSE c_cmsrc_info;
    x_errbuf := 'Unable to find source period end dates' ;
    RAISE e_invalid_inv_period;
  END IF;
  CLOSE c_cmsrc_info;

  l_is_first_inv_period := FALSE;

  --
  -- find matching inv period
  --
  OPEN c_ictrg_info(g_legal_entity_id, lc_cmcal_info.end_date);
  FETCH c_ictrg_info INTO lc_iccal_info;
  IF (c_ictrg_info%NOTFOUND)
  THEN
    CLOSE c_ictrg_info;
    x_errbuf := 'Unable to find matching inv period' ;
    RAISE e_invalid_inv_period;
  END IF;

  --
  -- see if there is another row available.
  -- set FLAG when no more rows.
  --
  FETCH c_ictrg_info INTO lc_iccal_info2;
  IF( c_ictrg_info%NOTFOUND )
  THEN
    l_is_first_inv_period := TRUE;
  END IF;
  CLOSE c_ictrg_info;

  --
  --
  --
  x_inv_per_end_date := lc_iccal_info.period_end_date;

  IF( l_is_first_inv_period )
  THEN
    x_inv_per_start_date := lc_iccal_info.begin_date;
  ELSE
    x_inv_per_start_date := lc_iccal_info2.period_end_date + 1;
  END IF;

  IF( TRUNC(x_inv_per_start_date) = TRUNC(lc_cmcal_info.start_date) )
  THEN
    x_inv_per_synch := 'Y';
  END IF;

  x_inv_fiscal_year := lc_iccal_info.fiscal_year;
  x_inv_period      := lc_iccal_info.period;

  x_retstatus := 'S';

EXCEPTION
  WHEN e_invalid_inv_period THEN
    x_retstatus := 'E';

    g_log_msg := l_procedure_name || ': error: ' || x_errbuf;
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
    THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
    END IF;

END inter_mod_cal_conv;

PROCEDURE populate_global (
    p_legal_entity_id         IN         VARCHAR2
  , p_ledger_id               IN         VARCHAR2
  , p_cost_type_id            IN         VARCHAR2
  , p_post_cm                 IN         VARCHAR2
  , p_crev_curr_calendar      IN         VARCHAR2
  , p_crev_curr_period        IN         VARCHAR2
  , p_crev_prev_cost_type_id  IN         VARCHAR2
  , p_crev_prev_calendar      IN         VARCHAR2
  , p_crev_prev_period        IN         VARCHAR2
  , p_crev_gl_trans_date      IN         VARCHAR2
  )
IS
  l_procedure_name CONSTANT VARCHAR2(30) := 'POPULATE_GLOBAL';
BEGIN

  --
  -- Populate Global variables
  --
  g_log_msg := l_procedure_name || ': Populate Global variables';
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
  THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
  END IF;

  IF p_post_cm = 1
  THEN
    g_process_category := 'REVALUATION_TRANSACTIONS';
  ELSE
    g_process_category := NULL; /* Bug#5623121 ANTHIYAG 30-Oct-2006 */
  END IF;

  g_legal_entity_id          := TO_NUMBER(p_legal_entity_id);
  g_ledger_id                := TO_NUMBER(p_ledger_id);
  g_cost_type_id             := TO_NUMBER(p_cost_type_id);

	/* Bug#5708175 ANTHIYAG 12-Dec-2006 Start */
  /*************************************
  SELECT le.organization_name, led.name,
         mthd.cost_type, mthd.cost_mthd_code, lk.meaning,
         mthd.default_lot_cost_type_id
    INTO g_legal_entity_name, g_ledger_name,
         g_cost_method_type, g_cost_type_code, g_cost_method,
         g_default_cost_type_id
    FROM org_organization_definitions le, gl_ledgers led,
         cm_mthd_mst mthd, gem_lookups lk
   WHERE le.organization_id = g_legal_entity_id
     AND led.ledger_id      = g_ledger_id
     AND mthd.cost_type_id  = g_cost_type_id
     AND lk.lookup_type     = 'GMF_COST_METHOD'
     AND lk.lookup_code     = mthd.cost_type;
  **************************************/
  BEGIN
    SELECT      gle.legal_entity_name
    INTO        g_legal_entity_name
    FROM        gmf_legal_entities gle
    WHERE       gle.legal_entity_id = g_legal_entity_id ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      g_log_msg := l_procedure_name || ': No data found in gmf_legal_entities query';
			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
			END IF;
      RAISE;
  END;
  BEGIN
    SELECT      gl.name
    INTO        g_ledger_name
    FROM        gl_ledgers gl
    WHERE       gl.ledger_id = g_ledger_id;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      g_log_msg := l_procedure_name || ': No data found in gl_ledgers query';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;
      RAISE;
  END;
  BEGIN
    SELECT      mthd.cost_type,
                mthd.cost_mthd_code,
                lk.meaning,
                nvl(mthd.default_lot_cost_type_id, -1)
    INTO        g_cost_method_type,
                g_cost_type_code,
                g_cost_method,
                g_default_cost_type_id
    FROM        cm_mthd_mst mthd,
                gem_lookups lk
    WHERE       mthd.cost_type_id  = g_cost_type_id
    AND         lk.lookup_type     = 'GMF_COST_METHOD'
    AND         lk.lookup_code     = mthd.cost_type ;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      g_log_msg := l_procedure_name || ': No data found in cost types query';
			IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
			  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
			END IF;
      RAISE;
  END;
	/* Bug#5708175 ANTHIYAG 12-Dec-2006 End */

  g_crev_curr_cost_type_id   := g_cost_type_id;
  g_crev_curr_cost_mthd_code := g_cost_type_code;
  g_crev_curr_calendar       := p_crev_curr_calendar;
  g_crev_curr_period         := p_crev_curr_period;

  g_crev_prev_cost_type_id   := TO_NUMBER(p_crev_prev_cost_type_id);
  g_crev_prev_calendar       := p_crev_prev_calendar;
  g_crev_prev_period         := p_crev_prev_period;

--  g_crev_gl_trans_date       := FND_DATE.canonical_to_date(p_crev_gl_trans_date);
  g_crev_gl_trans_date       := p_crev_gl_trans_date;


  IF g_cost_method_type <> 6
    THEN
    IF g_crev_curr_calendar IS NULL OR g_crev_curr_period IS NULL OR
       g_crev_prev_cost_type_id IS NULL OR g_crev_prev_calendar IS NULL OR
       g_crev_prev_period IS NULL
    THEN
      g_crev_curr_period_id := NULL;
      g_crev_prev_period_id := NULL;
      g_crev_prev_cost_mthd := NULL;

    ELSE

      g_log_msg := l_procedure_name || ': query cost reval data';
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL )
      THEN
         FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME || l_procedure_name, g_log_msg);
      END IF;


      SELECT curr.period_id, prev.period_id,
             mthd.cost_mthd_code
        INTO g_crev_curr_period_id, g_crev_prev_period_id,
                                    g_crev_prev_cost_mthd
        FROM gmf_period_statuses curr, gmf_period_statuses prev, cm_mthd_mst mthd
       WHERE curr.legal_entity_id  = g_legal_entity_id
         AND curr.cost_type_id     = g_cost_type_id
         AND curr.calendar_code    = g_crev_curr_calendar
         AND curr.period_code      = g_crev_curr_period
         AND prev.legal_entity_id  = g_legal_entity_id
         AND prev.cost_type_id     = g_crev_prev_cost_type_id
         AND prev.calendar_code    = g_crev_prev_calendar
         AND prev.period_code      = g_crev_prev_period
         AND mthd.cost_type_id     = g_crev_prev_cost_type_id
      ;
    END IF;
  END IF;

  --
  -- End of -- Populate Global variables
  --

END populate_global;

END gmf_subledger_pkg;

/
