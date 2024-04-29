--------------------------------------------------------
--  DDL for Package Body AR_CREATE_ACCTING_SRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CREATE_ACCTING_SRS" AS
/*$Header: ARSACCTB.pls 120.11.12010000.2 2009/01/30 13:15:56 anchandn ship $*/

g_exec_status      VARCHAR2(1) := fnd_api.G_RET_STS_SUCCESS;

g_xla_run          VARCHAR2(1) := 'Y';
--Local procedures
PROCEDURE log(
   message       IN VARCHAR2,
   newline       IN BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

PROCEDURE out(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.output, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.output,message);
  ELSE
    FND_FILE.put(fnd_file.output,message);
  END IF;
END out;

PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  out(message, newline);
  log(message, newline);
END outandlog;

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

PROCEDURE revrec_per_org
(p_report_mode    IN  VARCHAR2 := 'S',
 p_max_workers    IN  NUMBER := 2,
 p_interval       IN  NUMBER := 60,
 p_max_wait       IN  NUMBER := 180,
 p_org_id         IN  NUMBER,
 x_out_request_id OUT NOCOPY NUMBER)
IS
 revrec_sub_pb    EXCEPTION;
BEGIN
  outandlog('Submitting Revenue Recognition ARTERRPM for Org_id:'||p_org_id);
  FND_REQUEST.SET_ORG_ID(p_org_id);
  x_out_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         application=>'AR',
                         program=>'ARTERRPM',
                         sub_request=>FALSE,
                         argument1=> p_report_mode,
                         argument2=> p_max_workers,
                         argument3=> p_interval,
                         argument4=> p_max_wait,
                         argument5=> p_org_id );
  IF x_out_request_id <> 0 THEN
     outandlog('Revenue Recognition submitted for Org_id:'||p_org_id||' by the request '||x_out_request_id);
     INSERT INTO ar_submission_ctrl_gt
     (worker_id         , --org_id
      batch_id          , --batch_id
      script_name       , --script_name
      status            , --
      order_num         , --order helper number
      request_id        , --request_id
      table_name        ) --table_name
      VALUES
     (p_org_id,
      NULL,
      'ARTERRPM',
      'SUBMITTED',
      1,
      x_out_request_id,
      'REVREC');
     COMMIT;
  ELSE
     RAISE revrec_sub_pb;
  END IF;
EXCEPTION
  WHEN revrec_sub_pb THEN
     log(logerror(SQLERRM));
  WHEN OTHERS THEN
     log(logerror(SQLERRM));
END;


PROCEDURE rev_contigency_per_org
(p_org_id         IN NUMBER,
 x_out_request_id OUT NOCOPY NUMBER)
IS
  rev_contingency_sub_pb  EXCEPTION;
BEGIN
  outandlog('submit_rev_contigency for org_id :'||p_org_id);
  FND_REQUEST.SET_ORG_ID(p_org_id);

  IF (ar_revenue_management_pvt.revenue_management_enabled) THEN

  x_out_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         application=>'AR',
                         program=>'ARREVSWP',
                         sub_request=>FALSE,
                         argument1 =>p_org_id);
  IF x_out_request_id <> 0 THEN
     outandlog('submit_rev_contigency for org_id :'||p_org_id||' has submitted the request :'||x_out_request_id);
     INSERT INTO ar_submission_ctrl_gt
     (worker_id         , --org_id
      batch_id          , --batch_id
      script_name       , --script_name
      status            , --
      order_num         , --order helper number
      request_id        , --request_id
      table_name        ) --table_name
      VALUES
     (p_org_id,
      NULL,
      'ARREVSWP',
      'SUBMITTED',
      2,
      x_out_request_id,
      'REVCONTEN');
     COMMIT;
  ELSE
     RAISE rev_contingency_sub_pb;
  END IF;

  END IF;
EXCEPTION
  WHEN rev_contingency_sub_pb THEN
     log(logerror(SQLERRM));
  WHEN OTHERS THEN
     log(logerror(SQLERRM));
END;


PROCEDURE sla_create_accounting
(p_request_id     IN  NUMBER   DEFAULT NULL
,p_entity_id      IN  NUMBER   DEFAULT NULL
,p_src_app        IN  NUMBER   DEFAULT NULL
,p_app            IN  NUMBER   DEFAULT NULL
,p_dummy_param0   IN  VARCHAR2 DEFAULT NULL
,p_ledger         IN  NUMBER
,p_proc_categ     IN  VARCHAR2 DEFAULT NULL
,p_end_date       IN  DATE
,p_create_acct    IN  VARCHAR2
,p_dummy_param1   IN  VARCHAR2 DEFAULT NULL
,p_acct_mode      IN  VARCHAR2
,p_dummy_param2   IN  VARCHAR2 DEFAULT NULL
,p_errors_only    IN  VARCHAR2
,p_report         IN  VARCHAR2
,p_transf_gl      IN  VARCHAR2
,p_dummy_param3   IN  VARCHAR2 DEFAULT NULL
,p_post_to_gl     IN  VARCHAR2
,p_gl_batch_name  IN  VARCHAR2 DEFAULT NULL
,p_mixed_currency IN  NUMBER   DEFAULT NULL
,p_val_meth       IN  VARCHAR2 DEFAULT NULL
,p_sec_id_int_1   IN  NUMBER   DEFAULT NULL
,p_sec_id_int_2   IN  NUMBER   DEFAULT NULL
,p_sec_id_int_3   IN  NUMBER   DEFAULT NULL
,p_sec_id_char_1  IN  VARCHAR2 DEFAULT NULL
,p_sec_id_char_2  IN  VARCHAR2 DEFAULT NULL
,p_sec_id_char_3  IN  VARCHAR2 DEFAULT NULL
--BUG#5391740
,p_include_user_trx_id_flag     IN VARCHAR2 DEFAULT 'N'
,p_include_user_trx_identifiers IN VARCHAR2 DEFAULT NULL
,p_debug_flag                   IN VARCHAR2 DEFAULT NULL
)
IS
 CURSOR c_app_name(p_app_id  IN NUMBER) IS
  SELECT application_name
    FROM FND_APPLICATION_VL FVL
   WHERE application_id = p_src_app;

 CURSOR c_ledger_name(p_ledger_id  IN NUMBER) IS
  SELECT name
    FROM gl_ledgers
   WHERE ledger_id = p_ledger_id;

 CURSOR c_valid_date(p_ledger_id IN VARCHAR2,
                     p_date      IN DATE) IS
  SELECT 'Y'
    FROM gl_period_statuses  glp
   WHERE glp.application_id  = 222
     AND p_date     BETWEEN glp.start_date AND glp.end_date
     AND glp.set_of_books_id = p_ledger
     AND glp.closing_status  IN ('O','F');

 l_res                 VARCHAr2(1);
 l_iso_language        VARCHAR2(30);
 l_iso_territory       VARCHAR2(30);
 l_bool                BOOLEAN;
 l_request_id          NUMBER;
 l_src_app             VARCHAR2(240);
 l_app                 VARCHAR2(240);
 l_ledger_name         VARCHAR2(30);
 x_msg_count           NUMBER;
 x_msg_data            VARCHAR2(2000);
 create_acct_sub_pb    EXCEPTION;
 accting_date_pb       EXCEPTION;
BEGIN
  outandlog('sla_create_accounting for the ledger: '||p_ledger);

/*BUG#5687816 -- Remove the verification to AR accounting period status
  IF  p_acct_mode = 'F' THEN
    log('ledger_id:'||p_ledger);
    log('End Date :'||p_end_date);
    OPEN c_valid_date(p_ledger_id => p_ledger,
                      p_date      => p_end_date);
    FETCH c_valid_date INTO l_res;
    IF c_valid_date%NOTFOUND THEN
       FND_MSG_PUB.initialize;
       FND_MESSAGE.SET_NAME('AR','AR_ACCT_PERIOD_NOT_OPEN');
       FND_MSG_PUB.ADD;
       RAISE accting_date_pb;
   END IF;
  END IF;
*/

  OPEN c_app_name(p_src_app);
  FETCH c_app_name INTO l_src_app;
  CLOSE c_app_name;

  OPEN c_app_name(p_app);
  FETCH c_app_name INTO l_app;
  CLOSE c_app_name;

  OPEN c_ledger_name(p_ledger);
  FETCH c_ledger_name INTO l_ledger_name;
  CLOSE c_ledger_name;

  SELECT lower(iso_language),iso_territory
    INTO   l_iso_language,
           l_iso_territory
    FROM   FND_LANGUAGES
   WHERE  language_code = USERENV('LANG');


  l_bool := fnd_request.add_layout
           (template_appl_name => 'XLA',
			template_code      => 'XLAACCPB01',
			template_language  => l_iso_language,
 			template_territory => l_iso_territory,
			output_format      => 'PDF');

  l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                         application=>'XLA',
                         program=>'XLAACCPB',
                         sub_request=>FALSE,
                         argument1 =>p_app,
                         argument2 =>p_src_app,
                         argument3 =>p_dummy_param0,
                         argument4 =>p_ledger,
                         argument5 =>p_proc_categ,
                         argument6 =>fnd_date.date_to_canonical(p_end_date),
                         argument7 =>p_create_acct,
                         argument8 =>p_dummy_param1,
                         argument9 =>p_acct_mode,
                         argument10=>p_dummy_param2,
                         argument11=>p_errors_only,
                         argument12=>p_report,
                         argument13=>p_transf_gl,
                         argument14=>p_dummy_param3,
                         argument15=>p_post_to_gl,
                         argument16=>p_gl_batch_name,
                         argument17=>p_mixed_currency,
                         argument18=>'N',
                         argument19=>p_request_id,
                         argument20=>p_entity_id,
                         argument21=>l_src_app,
                         argument22=>l_app,
                         argument23=>l_ledger_name,
                         argument24=>p_proc_categ,
                         argument25=>p_create_acct,
                         argument26=>'',
                         argument27=>p_errors_only,
                         argument28=>p_report,
                         argument29=>p_transf_gl,
                         argument30=>p_post_to_gl,
                         argument31=>'No',
                         argument32=>p_val_meth,
                         argument33=>p_sec_id_int_1,
                         argument34=>p_sec_id_int_2,
                         argument35=>p_sec_id_int_3,
                         argument36=>p_sec_id_char_1,
                         argument37=>p_sec_id_char_2,
                         argument38=>p_sec_id_char_3,
                         argument39=>NULL,
                         argument40=>p_include_user_trx_id_flag,
                         argument41=>p_include_user_trx_identifiers,
                         argument42=>p_debug_flag );


  IF l_request_id <> 0 THEN
     outandlog('sla create accounting submitted with the request_id'||l_request_id);
     COMMIT;
  ELSE
     RAISE create_acct_sub_pb;
  END IF;
EXCEPTION
  WHEN accting_date_pb THEN
       g_xla_run     := 'N';
       IF c_valid_date%ISOPEN THEN
         CLOSE c_valid_date;
       END IF;
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data);
     out(message => x_msg_data);
     log(message => x_msg_data);
  WHEN create_acct_sub_pb THEN
     log(logerror(SQLERRM));
  WHEN OTHERS THEN
     log(logerror(SQLERRM));
END;

PROCEDURE wait_for_end_subreq(
 p_interval       IN  NUMBER   DEFAULT 60
,p_max_wait       IN  NUMBER   DEFAULT 180
,p_sub_name       IN  VARCHAR2)
IS
  CURSOR reqs IS
  SELECT request_id
    FROM ar_submission_ctrl_gt
   WHERE status      <> 'COMPLETE'
     AND script_name = p_sub_name;
  l_req_id      NUMBER;
  l_phase       VARCHAR2(50);
  l_status      VARCHAR2(50);
  l_dev_phase   VARCHAR2(50);
  l_dev_status  VARCHAR2(50);
  l_message     VARCHAR2(2000);
  l_complete    BOOLEAN;
  revrecdone    EXCEPTION;
BEGIN
  log('wait_for_end_subreq :'|| p_sub_name ||' to finish');
  LOOP
    OPEN reqs;
    LOOP
      FETCH reqs INTO l_req_id;
      EXIT WHEN reqs%NOTFOUND;
      l_complete := FND_CONCURRENT.WAIT_FOR_REQUEST(
		       request_id=>l_req_id,
		       interval=>p_interval,
		       max_wait=>p_max_wait,
		       phase=>l_phase,
		       status=>l_status,
		       dev_phase=>l_dev_phase,
		       dev_status=>l_dev_status,
		       message=>l_message);
       IF l_dev_phase = 'COMPLETE' THEN
        UPDATE ar_submission_ctrl_gt
           SET status = 'COMPLETE'
         WHERE request_id = l_req_id;
--{If required, we can control the error handling at concurrent process level
-- but as this is part of the accounting posting process if revrec or rev analyser fails
-- for now we allow the accouning for the cash receipts
--         IF l_dev_status IN ('TERMINATED', 'CANCELLED', 'ERROR') THEN
--           RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
--         END IF;
--}
       END IF;
    END LOOP;
    CLOSE reqs;

    OPEN reqs;
    FETCH reqs INTO l_req_id;
    IF reqs%NOTFOUND THEN
      RAISE revrecdone;
    END IF;
    CLOSE reqs;
  END LOOP;
EXCEPTION
  WHEN revrecdone THEN
    IF reqs%ISOPEN THEN
       CLOSE reqs;
    END IF;
  WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
    g_exec_status := fnd_api.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF reqs%ISOPEN THEN
       CLOSE reqs;
    END IF;
    RAISE;
END;

-- Public procedure
PROCEDURE submission (
 errbuf           OUT NOCOPY VARCHAR2
,retcode          OUT NOCOPY NUMBER
--
,p_report_mode    IN  VARCHAR2 DEFAULT 'S'
,p_max_workers    IN  NUMBER   DEFAULT 2
,p_interval       IN  NUMBER   DEFAULT 60
,p_max_wait       IN  NUMBER   DEFAULT 180
---
,p_request_id     IN  NUMBER   DEFAULT NULL
,p_entity_id      IN  NUMBER   DEFAULT NULL
,p_src_app        IN  NUMBER   DEFAULT NULL
,p_app            IN  NUMBER   DEFAULT NULL
,p_dummy_param0   IN  VARCHAR2 DEFAULT NULL
,p_ledger         IN  NUMBER
,p_proc_categ     IN  VARCHAR2 DEFAULT NULL
,p_end_date       IN  VARCHAR2
,p_create_acct    IN  VARCHAR2
,p_dummy_param1   IN  VARCHAR2 DEFAULT NULL
,p_acct_mode      IN  VARCHAR2
,p_dummy_param2   IN  VARCHAR2 DEFAULT NULL
,p_errors_only    IN  VARCHAR2
,p_report         IN  VARCHAR2
,p_transf_gl      IN  VARCHAR2
,p_dummy_param3   IN  VARCHAR2 DEFAULT NULL
,p_post_to_gl     IN  VARCHAR2
,p_gl_batch_name  IN  VARCHAR2 DEFAULT NULL
,p_mixed_currency IN  NUMBER   DEFAULT NULL
,p_val_meth       IN  VARCHAR2 DEFAULT NULL
,p_sec_id_int_1   IN  NUMBER   DEFAULT NULL
,p_sec_id_int_2   IN  NUMBER   DEFAULT NULL
,p_sec_id_int_3   IN  NUMBER   DEFAULT NULL
,p_sec_id_char_1  IN  VARCHAR2 DEFAULT NULL
,p_sec_id_char_2  IN  VARCHAR2 DEFAULT NULL
,p_sec_id_char_3  IN  VARCHAR2 DEFAULT NULL
--BUG#5391740
,p_include_user_trx_id_flag     IN VARCHAR2 DEFAULT 'N'
,p_include_user_trx_identifiers IN VARCHAR2 DEFAULT NULL
,p_debug_flag                   IN VARCHAR2 DEFAULT NULL
,p_user_id                      IN NUMBER   DEFAULT fnd_profile.value('USER_ID')
)
IS
  CURSOR ous(p_ledger_id IN NUMBER) IS
  SELECT DISTINCT arsys.org_id
    FROM ar_system_parameters_all arsys,
         mo_glob_org_access_tmp   mo
   WHERE arsys.set_of_books_id = p_ledger_id
     AND arsys.org_id          = mo.organization_id;

  l_org_id     NUMBER;
  l_request_id NUMBER;
  i            NUMBER;
  l_text       VARCHAR2(2000);
  NullLedger   EXCEPTION;
  xla_not_run  EXCEPTION;
BEGIN
outandlog('Submission parameters');
outandlog('p_report_mode :'||p_report_mode);
outandlog('p_max_workers :'||p_max_workers);
outandlog('p_interval    :'||p_interval);
outandlog('p_max_wait    :'||p_max_wait);
outandlog('p_request_id  :'||p_request_id);
outandlog('p_entity_id   :'||p_entity_id);
outandlog('p_src_app     :'||p_src_app);
outandlog('p_app         :'||p_app);
outandlog('p_dummy_param0:'||p_dummy_param0);
outandlog('p_ledger      :'||p_ledger);
outandlog('p_proc_categ  :'||p_proc_categ);
outandlog('p_end_date    :'||p_end_date);
outandlog('p_create_acct :'||p_create_acct);
outandlog('p_dummy_param1:'||p_dummy_param1);
outandlog('p_acct_mode   :'||p_acct_mode);
outandlog('p_dummy_param2:'||p_dummy_param2);
outandlog('p_errors_only :'||p_errors_only);
outandlog('p_report      :'||p_report);
outandlog('p_transf_gl   :'||p_transf_gl);
outandlog('p_dummy_param3:'||p_dummy_param3);
outandlog('p_post_to_gl  :'||p_post_to_gl);
outandlog('p_gl_batch_name:'||p_gl_batch_name);
outandlog('p_mixed_currency:'||p_mixed_currency);
outandlog('p_val_meth     :'||p_val_meth);
outandlog('p_sec_id_int_1 :'||p_sec_id_int_1);
outandlog('p_sec_id_int_2 :'||p_sec_id_int_2);
outandlog('p_sec_id_int_3 :'||p_sec_id_int_3);
outandlog('p_sec_id_char_1:'||p_sec_id_char_1);
outandlog('p_sec_id_char_2:'||p_sec_id_char_2);
outandlog('p_sec_id_char_3:'||p_sec_id_char_3);

IF p_ledger IS NULL THEN
  RAISE NullLedger;
END IF;

OPEN ous(p_ledger);
LOOP
  FETCH ous INTO l_org_id;
  EXIT WHEN ous%NOTFOUND;

  --submission of Rev Rec
  revrec_per_org
  (p_report_mode    => p_report_mode,
   p_max_workers    => p_max_workers,
   p_interval       => p_interval,
   p_max_wait       => p_max_wait,
   p_org_id         => l_org_id,
   x_out_request_id => l_request_id);

END LOOP;
CLOSE ous;

wait_for_end_subreq(
 p_interval       => p_interval
,p_max_wait       => p_max_wait
,p_sub_name       => 'ARTERRPM' );


OPEN ous(p_ledger);
LOOP
  FETCH ous INTO l_org_id;
  EXIT WHEN ous%NOTFOUND;
  --Run Revenue Contingency Analyzer
  rev_contigency_per_org
  (p_org_id         => l_org_id,
   x_out_request_id => l_request_id);
END LOOP;
CLOSE ous;

wait_for_end_subreq(
 p_interval       => p_interval
,p_max_wait       => p_max_wait
,p_sub_name       => 'ARREVSWP' );

--Submit SLA Create Accounting
sla_create_accounting
(p_request_id     => p_request_id
,p_entity_id      => p_entity_id
,p_src_app        => p_src_app
,p_app            => p_app
,p_dummy_param0   => p_dummy_param0
,p_ledger         => p_ledger
,p_proc_categ     => p_proc_categ
,p_end_date       => fnd_date.canonical_to_date(p_end_date)
--,p_end_date       => p_end_date
,p_create_acct    => p_create_acct
,p_dummy_param1   => p_dummy_param1
,p_acct_mode      => p_acct_mode
,p_dummy_param2   => p_dummy_param2
,p_errors_only    => p_errors_only
,p_report         => p_report
,p_transf_gl      => p_transf_gl
,p_dummy_param3   => p_dummy_param3
,p_post_to_gl     => p_post_to_gl
,p_gl_batch_name  => p_gl_batch_name
,p_mixed_currency => p_mixed_currency
,p_val_meth       => p_val_meth
,p_sec_id_int_1   => p_sec_id_int_1
,p_sec_id_int_2   => p_sec_id_int_2
,p_sec_id_int_3   => p_sec_id_int_3
,p_sec_id_char_1  => p_sec_id_char_1
,p_sec_id_char_2  => p_sec_id_char_2
,p_sec_id_char_3  => p_sec_id_char_3
,p_include_user_trx_id_flag     => p_include_user_trx_id_flag
,p_include_user_trx_identifiers => p_include_user_trx_identifiers
,p_debug_flag                   => p_debug_flag
);

IF g_xla_run = 'N' THEN
  RAISE xla_not_run;
END IF;

EXCEPTION
  WHEN NullLedger THEN
    retcode   := 2;
    log('Ledger can not be null');
    errbuf    := 'Ledger can not be null';

  WHEN xla_not_run THEN
    retcode   := 1;

  WHEN OTHERS THEN
    retcode   := 2;
    l_text    := logerror(SQLERRM);
    log(l_text);
    errbuf := l_text;
    IF ous%ISOPEN THEN CLOSE ous; END IF;
    RAISE;

END;

END;

/
