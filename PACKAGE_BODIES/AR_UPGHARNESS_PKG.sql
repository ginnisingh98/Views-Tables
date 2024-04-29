--------------------------------------------------------
--  DDL for Package Body AR_UPGHARNESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_UPGHARNESS_PKG" AS
/*$Header: ARXLAHNB.pls 120.10.12010000.4 2009/08/19 05:12:18 aghoraka ship $*/

PROCEDURE ins_120_ctl
(p_script_name   IN VARCHAR2,
 p_batch_id      IN NUMBER);

PROCEDURE verif_status
(p_batch_id      IN NUMBER);

PROCEDURE submission_main_routine
(p_workers       IN NUMBER,
 p_batch_id      IN NUMBER,
 p_batch_size    IN NUMBER);

PROCEDURE  update_process_status
(p_request_id    IN NUMBER
,p_status        IN VARCHAR2);

PROCEDURE insert_req_control
(p_ins_rec            IN         xla_upgrade_requests%ROWTYPE,
 x_request_control_id OUT NOCOPY NUMBER);

PROCEDURE update_req_control
(p_request_control_id    IN NUMBER,
 p_status                IN VARCHAR2);

--{FND loging
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
--}

PROCEDURE update_gl_period
IS
  CURSOR c IS
  SELECT 'Y'
    FROM ar_submission_ctrl_gt
   WHERE STATUS <> 'NORMAL';

  CURSOR update_gl_periods IS
  SELECT application_id,
         ledger_id,
         period_name,
         period_year
    FROM gl_period_statuses gps
   WHERE gps.migration_status_code = 'P'
     AND gps.application_id (+)    = 222;
  l_status                VARCHAR2(1);
  l_not_complete          VARCHAR2(1);
  update_gps_error        EXCEPTION;
BEGIN
  OPEN c;
  FETCH c INTO l_not_complete;
  IF c%NOTFOUND THEN
    -- All requests end NORMAL - Update GL period statuses
    FOR l_update_gl_periods IN update_gl_periods LOOP
       l_status := xla_upgrade_pub.set_migration_status_code
                   ( 222,
                     l_update_gl_periods.ledger_id,
                     l_update_gl_periods.period_name,
                     l_update_gl_periods.period_year);
       IF l_status = 'F' THEN
         RAISE update_gps_error;
       END IF;
       COMMIT;
    END LOOP;
  ELSE
    --Some requests ended with WARNING or ERROR - Do not update the GL period Statuses
    -- So that the next run processes them
    NULL;
  END IF;
  CLOSE c;
EXCEPTION
  WHEN UPDATE_GPS_ERROR THEN
     RAISE;
  WHEN NO_DATA_FOUND THEN
     NULL;
  WHEN OTHERS THEN
     RAISE;
END;


FUNCTION mrc_run_required RETURN VARCHAR2
IS
  CURSOR c IS
  SELECT 'Y'
    FROM gl_mc_reporting_options_11i
   WHERE application_id = 222;
  l_result   VARCHAR2(1);
BEGIN
  OPEN c;
  FETCH c INTO l_result;
  IF c%NOTFOUND THEN
    l_result := 'N';
  END IF;
  CLOSE c;
  RETURN l_result;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;


PROCEDURE ins_120_ctl
(p_script_name  IN VARCHAR2,
 p_batch_id     IN NUMBER)
IS
BEGIN
  outandlog('ins_120_ctl +');
  outandlog(' p_script_name:'||p_script_name);
  INSERT INTO ar_upg_120_control
  (script_name,
   processed_flag,
   action_flag,
   batch_id,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by) VALUES
     (p_script_name,
      'A',
      'R', --downtime
      p_batch_id,
      sysdate,
      -2005,
      sysdate,
      -2005);
  outandlog('ins_120_ctl -');
EXCEPTION
  WHEN OTHERS THEN
    log(' EXCPETION OTHERS in ins_120_ctl :'||SQLERRM);
    RAISE;
END;

PROCEDURE verif_status
(p_batch_id    IN NUMBER)
IS
  CURSOR c_req IS
  SELECT request_id
    FROM ar_submission_ctrl_gt
   WHERE batch_id   = p_batch_id
     AND status     = 'SUBMITTED';
  l_res         BOOLEAN;
  l_phase       VARCHAR2(30);
  l_status      VARCHAR2(30);
  l_dev_phase   VARCHAR2(30);
  l_dev_status  VARCHAR2(30);
  l_message     VARCHAR2(2000);
  l_request_id  NUMBER;
BEGIN
  OPEN c_req;
  LOOP
  FETCH c_req INTO l_request_id;
  EXIT WHEN c_req%NOTFOUND;

  l_res := FND_CONCURRENT.GET_REQUEST_STATUS
           (request_id     => l_request_id
           ,phase          => l_phase
           ,status         => l_status
           ,dev_phase      => l_dev_phase
           ,dev_status     => l_dev_status
           ,message        => l_message);

  IF l_dev_phase = 'COMPLETE' THEN

     IF     l_dev_status  = 'NORMAL' THEN
        outandlog('The process '||l_request_id||' completed successfully');
        outandlog(l_message);
     ELSIF  l_dev_status  = 'ERROR' THEN
        log('The process '||l_request_id||' completed with error');
        log(l_message);
     ELSIF  l_dev_status  = 'WARNING' THEN
        outandlog('The process '||l_request_id||' completed with warning');
        outandlog(l_message);
     ELSIF  l_dev_status  = 'CANCELLED' THEN
        log('User has aborted the process '||l_request_id);
        log(l_message);
     ELSIF  l_dev_status  = 'TERMINATED' THEN
        log('User has aborted the process '||l_request_id);
        log(l_message);
     END IF;

     update_process_status
	  (p_request_id => l_request_id
	  ,p_status     => l_dev_status);

     COMMIT;
 END IF;
 END LOOP;
 CLOSE c_req;
EXCEPTION
  WHEN OTHERS THEN
    log('EXCEPTION OTHERS in verif_status :'||SQLERRM);
END;



PROCEDURE submission_main_routine
(p_workers       IN NUMBER,
 p_batch_id      IN NUMBER,
 p_batch_size    IN NUMBER)
IS
  -- Get the job inserted not executed
  CURSOR c IS
  SELECT script_name     script_name,
         table_name      table_name,
         worker_id       worker_num,
         order_num       order_num,
         rowid
    FROM ar_submission_ctrl_gt
   WHERE status = 'INSERTED'
   AND batch_id = p_batch_id
   ORDER BY order_num ASC;

  -- Number of running workers
  CURSOR c_run_workers IS
  SELECT COUNT(*)
    FROM ar_submission_ctrl_gt
   WHERE status     = 'SUBMITTED'
     AND batch_id   = p_batch_id;

  l_num_running_workers   NUMBER;
  l_num_avail_workers     NUMBER;
  l_prv_script_name       VARCHAR2(30);
  l_prv_table_name        VARCHAR2(30);
  l_cpt                   NUMBER;
  l_run_worker            NUMBER;
  l_script_name           VARCHAR2(30);
  l_table_name            VARCHAR2(30);
  l_rowid                 VARCHAR2(2000);
  l_req_id                NUMBER;
  l_table_owner           VARCHAR2(30);
  l_worker_num            NUMBER;
  l_order_num             NUMBER;
  exception_in_submission EXCEPTION;
  FUNCTION max_running_worknum
  (p_table_name  IN  VARCHAR2,
   p_batch_id    IN  NUMBER) RETURN NUMBER
  IS
    -- Get the max worker number submitted for all script
    CURSOR c_max IS
    SELECT MAX(worker_id)   max_worker
      FROM ar_submission_ctrl_gt
     WHERE batch_id       = p_batch_id
       AND table_name     = p_table_name
       AND status         <> 'INSERTED';
    l_return   NUMBER;
  BEGIN
    OPEN c_max;
    FETCH c_max INTO l_return;
    IF c_max%NOTFOUND THEN
      l_return := 0;
    END IF;
    CLOSE c_max;
    RETURN l_return;
  END;
BEGIN

  OPEN c_run_workers;
  FETCH c_run_workers INTO l_num_running_workers;
  CLOSE c_run_workers;

  l_num_avail_workers := p_workers - l_num_running_workers;

  IF l_num_avail_workers > 0 THEN
    l_prv_script_name := 'INIT';
    l_prv_table_name  := 'INIT';
    l_cpt             := 0;
    OPEN c;
    LOOP
      FETCH c INTO l_script_name,
                   l_table_name,
                   l_worker_num,
                   l_order_num,
				   l_rowid;
      EXIT WHEN c%NOTFOUND;
      l_cpt := l_cpt + 1;
      IF l_table_name <> l_prv_table_name THEN
         l_run_worker := max_running_worknum
                       (p_table_name  => l_table_name,
                        p_batch_id => p_batch_id);
      END IF;
      l_run_worker  := l_run_worker + 1;
      l_req_id := FND_REQUEST.SUBMIT_REQUEST
	         (application => 'AR',
                  program     => 'ARXLAUPGCP',
--                  description => 'AR XLA Upgrade on demande',
                  start_time  => SYSDATE,
                  sub_request => FALSE,
                  argument1   => l_table_name,
                  argument2   => l_script_name,
                  argument3   => p_workers,
                  argument4   => l_worker_num,
                  argument5   => p_batch_size,
				  argument6   => l_order_num);
      IF l_req_id = 0 THEN
        log('Error submitting request');
        log(fnd_message.get);
        l_prv_script_name := l_script_name;
        l_prv_table_name  := l_table_name;
        UPDATE ar_submission_ctrl_gt
           SET request_id   = -9,
               status = 'ABORTED'
         WHERE rowid    = l_rowid;
         COMMIT;
      ELSE
        outandlog('Submitted request ID : ' || l_req_id );
        log('Request ID : ' || l_req_id);
        l_prv_script_name := l_script_name;
        l_prv_table_name  := l_table_name;
        UPDATE ar_submission_ctrl_gt
           SET request_id   = l_req_id,
               status       = 'SUBMITTED'
         WHERE rowid        = l_rowid;
        COMMIT;
      END IF;
      IF l_cpt = l_num_avail_workers THEN
        COMMIT;
        EXIT;
      END IF;
    END LOOP;
    CLOSE c;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    log('EXCEPTION OTHERS in submission_main_routine :'||SQLERRM);

END submission_main_routine;




PROCEDURE  update_process_status
(p_request_id   IN NUMBER
,p_status       IN VARCHAR2)
IS
BEGIN
  log('updating ar_submission_ctrl_gt the process status to '||p_status||' for request_id '||p_request_id);
  UPDATE ar_submission_ctrl_gt
     SET status = p_status
   WHERE request_id = p_request_id;
EXCEPTION
  WHEN OTHERS THEN
    log('EXCEPTION OTHERS in update_process_status :'||SQLERRM);
    RAISE;
END;

PROCEDURE record_ar_run
(p_table_name          IN         VARCHAR2,
 p_script_name         IN         VARCHAR2,
 p_num_workers         IN         NUMBER,
 p_worker_id           IN         NUMBER,
 p_batch_size          IN         VARCHAR2,
 p_status              IN         VARCHAR2,
 p_program_code        IN         VARCHAR2,
 p_phase               IN         NUMBER,
 p_order_num           IN         NUMBER,
 x_return_status       IN OUT NOCOPY VARCHAR2,
 x_return_msg          OUT    NOCOPY VARCHAR2,
 x_request_control_id  OUT    NOCOPY NUMBER)
IS
  CURSOR c_child_req IS
  SELECT request_control_id
    FROM xla_upgrade_requests
   WHERE table_name  = p_table_name
     AND script_name = p_script_name
     AND workers_num = p_num_workers
     AND worker_id   = p_worker_id
     AND batch_size  = p_batch_size
	 AND application_id = 222;
  l_request_control_id      NUMBER;

  CURSOR c_xla_request IS
  SELECT request_control_id
        ,ledger_id
        ,period_name
        ,worker_id
        ,workers_num
        ,batch_size
        ,batch_id
        ,start_date
        ,end_date
    FROM xla_upgrade_requests
   WHERE phase_num     = 0
     AND status_code    <> 'S'
     AND program_code = 'XLA_UPG'
	 AND application_id = 222;

  l_rec           xla_upgrade_requests%ROWTYPE;
  l_ins_rec       xla_upgrade_requests%ROWTYPE;

  CURSOR c_ord_num IS
  SELECT order_num
    FROM ar_submission_ctrl_gt
   WHERE table_name  = p_table_name
     AND script_name = p_script_name
     AND worker_id   = p_worker_id;
  l_ord_num       NUMBER;

  no_xla_request  EXCEPTION;
BEGIN
  log( message  =>'record_ar_run +' );
  log( message  =>'  table_name  :'||p_table_name );
  log( message  =>'  script_name :'||p_script_name);
  log( message  =>'  batch_size  :'||p_batch_size );
  log( message  =>'  workers_num :'||p_num_workers);
  log( message  =>'  worker_id   :'||p_worker_id  );
  log( message  =>'  status      :'||p_status     );
  log( message  =>'  p_order_num :'||p_order_num);

  OPEN c_child_req;
  FETCH c_child_req INTO l_request_control_id;
  IF c_child_req%NOTFOUND THEN
    OPEN c_xla_request;
    FETCH c_xla_request INTO l_rec.parent_request_control_id
        ,l_rec.ledger_id
        ,l_rec.period_name
        ,l_rec.worker_id
        ,l_rec.workers_num
        ,l_rec.batch_size
        ,l_rec.batch_id
        ,l_rec.start_date
        ,l_rec.end_date;

    IF c_xla_request%NOTFOUND THEN
       RAISE no_xla_request;
    END IF;

    OPEN c_ord_num;
    FETCH c_ord_num INTO l_ord_num;
    CLOSE c_ord_num;

    l_ins_rec              := l_rec;
    l_ins_rec.table_name   := p_table_name;
    l_ins_rec.script_name  := p_script_name;
    l_ins_rec.workers_num  := p_num_workers;
    l_ins_rec.worker_id    := p_worker_id;
    l_ins_rec.batch_size   := p_batch_size;
    l_ins_rec.order_num    := p_order_num;
    l_ins_rec.status_code  := p_status;
    l_ins_rec.program_code := p_program_code;
    l_ins_rec.phase_num        := p_phase;

    insert_req_control(l_ins_rec,x_request_control_id);
  ELSE
    x_return_msg    := 'The xla_upgrade_requests record exist-request_control_id:'||l_request_control_id;

    update_req_control(l_request_control_id,p_status);

    x_request_control_id := l_request_control_id;
    log( message  => x_return_msg);
  END IF;
  CLOSE c_child_req;
  log( message  => 'record_ar_run -');
EXCEPTION
  WHEN no_xla_request THEN
       x_return_status := 'E';
       x_return_msg    := 'Parent process from XLA has to exist';
       log( message  => 'EXCEPTION no_xla_request in record_ar_run');
       log( message  => 'Parent process from XLA has to exist');

  WHEN OTHERS THEN
       x_return_status := 'U';
       x_return_msg    := SQLERRM;
       log( message  => 'EXCEPTION OTHERS in record_ar_run');
       log( message  => x_return_msg);
END;


PROCEDURE insert_req_control
(p_ins_rec            IN         xla_upgrade_requests%ROWTYPE,
 x_request_control_id OUT NOCOPY NUMBER)
IS
 l_request_control_id    NUMBER;
BEGIN
  log( message  => 'Inserting a record in ar_reqrest_control');
  SELECT xla_upgrade_requests_s.NEXTVAL
    INTO l_request_control_id
    FROM DUAL;
log('request_control_id:'|| l_request_control_id);
log('parent_request_control_id:'||p_ins_rec.parent_request_control_id);
log('phase         :'||p_ins_rec.phase_num);
log('program_code  :'||p_ins_rec.program_code);
log('description   :'||p_ins_rec.description);
log('status        :'||p_ins_rec.status_code);
log('ledger_id     :'||p_ins_rec.ledger_id);
log('period_name   :'||p_ins_rec.period_name);
log('worker_id     :'||p_ins_rec.worker_id);
log('workers_num   :'||p_ins_rec.workers_num);
log('table_name    :'||p_ins_rec.table_name);
log('script_name   :'||p_ins_rec.script_name);
log('batch_size    :'||p_ins_rec.batch_size);
log('batch_id      :'||p_ins_rec.batch_id);
log('order_num     :'||p_ins_rec.order_num);
log('start_date    :'||p_ins_rec.start_date);
log('end_date      :'||p_ins_rec.end_date);

  INSERT INTO xla_upgrade_requests(
     request_control_id
    ,parent_request_control_id
    ,phase_num
    ,program_code
    ,description
    ,status_code
    ,ledger_id
    ,period_name
    ,worker_id
    ,workers_num
    ,table_name
    ,script_name
    ,batch_size
    ,batch_id
    ,order_num
    ,start_date
    ,end_date
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
	,application_id )
   VALUES (
     l_request_control_id
    ,p_ins_rec.parent_request_control_id
    ,p_ins_rec.phase_num
    ,p_ins_rec.program_code
    ,p_ins_rec.description
    ,p_ins_rec.status_code
    ,p_ins_rec.ledger_id
    ,p_ins_rec.period_name
    ,p_ins_rec.worker_id
    ,p_ins_rec.workers_num
    ,p_ins_rec.table_name
    ,p_ins_rec.script_name
    ,p_ins_rec.batch_size
    ,p_ins_rec.batch_id
    ,p_ins_rec.order_num
    ,p_ins_rec.start_date
    ,p_ins_rec.end_date
    ,SYSDATE
    ,nvl(FND_GLOBAL.user_id,-1)
    ,SYSDATE
    ,nvl(FND_GLOBAL.user_id,-1)
    ,nvl(FND_GLOBAL.conc_login_id,FND_GLOBAL.login_id)
	,222 );

    x_request_control_id := l_request_control_id;
  log( message  => 'new record request_control_id :'||l_request_control_id);
END;


PROCEDURE update_req_control
(p_request_control_id    IN NUMBER,
 p_status                IN VARCHAR2)
IS
BEGIN
  log( message  => 'Updating control record with request_control_id :'||p_request_control_id||'
 by setting the status to:'||p_status);
  UPDATE xla_upgrade_requests
     SET status_code         = p_status
        ,LAST_UPDATE_DATE    = SYSDATE
        ,LAST_UPDATED_BY     = nvl(FND_GLOBAL.user_id,-1)
        ,LAST_UPDATE_LOGIN   = nvl(FND_GLOBAL.conc_login_id,FND_GLOBAL.login_id)
   WHERE request_control_id  = p_request_control_id
     AND application_id      = 222;
END;

PROCEDURE upgrade_by_request (
        errbuf         OUT NOCOPY   VARCHAR2,
        retcode        OUT NOCOPY   VARCHAR2,
        l_table_name   IN           VARCHAR2,
        l_script_name  IN           VARCHAR2,
        l_num_workers  IN           NUMBER,
        l_worker_id    IN           NUMBER,
        l_batch_size   IN           VARCHAR2,
		p_order_num    IN           NUMBER)
IS
  l_batch_id            NUMBER;
  x_return_status       VARCHAR2(10);
  x_return_msg          VARCHAR2(2000);
  x_request_control_id  NUMBER;
  l_bool                BOOLEAN;
  l_status              VARCHAR2(30);
  l_industry            VARCHAR2(30);
  l_schema              VARCHAR2(30);
  l_table_owner         VARCHAR2(30);
  l_program_code        VARCHAR2(30);
  l_phase               NUMBER;
  maintenance_record    EXCEPTION;
BEGIN
  retcode := 0;
  outandlog( message  =>'upgrade_by_request for the table :'||l_table_name );
  outandlog( message  =>'  Starting at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  outandlog( message  =>'  l_script_name :'||l_script_name);
  outandlog( message  =>'  l_batch_size  :'||l_batch_size );
  outandlog( message  =>'  l_worker_id   :'||l_worker_id);
  outandlog( message  =>'  l_table_name  :'||l_table_name);

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF l_table_name IN ('JL_BR_AR_OCCURRENCE_DOCS_ALL','JL_BR_AR_MC_OCC_DOCS') THEN

    IF fnd_installation.get_app_info('JL',l_status,l_industry,l_schema) THEN
      l_table_owner := l_schema;
    ELSE
      l_table_owner := 'JL';
    END IF;
    l_phase         := 3;
    l_program_code  := 'JL_UPG';

--{GIR
  ELSIF l_table_name IN ('GL_IMPORT_REFERENCES') THEN

    IF fnd_installation.get_app_info('SQLGL',l_status,l_industry,l_schema) THEN
      l_table_owner := l_schema;
    ELSE
      l_table_owner := 'GL';
    END IF;
    l_phase         := 5;
    l_program_code  := 'GIR_UPG';

  ELSIF l_table_name = 'PSATRX' THEN

    IF fnd_installation.get_app_info('PSA',l_status,l_industry,l_schema) THEN
      l_table_owner := l_schema;
    ELSE
      l_table_owner := 'PSA';
    END IF;
    l_phase         := 4;
    l_program_code  := 'PSA_UPG';
--}
  ELSE

    IF fnd_installation.get_app_info('AR',l_status,l_industry,l_schema) THEN
      l_table_owner := l_schema;
    ELSE
      l_table_owner := 'AR';
    END IF;

    IF l_table_name IN ('RA_CUSTOMER_TRX_ALL','AR_CASH_RECEIPTS_ALL'
                        ,'AR_ADJUSTMENTS_ALL','AR_RECEIVABLE_APPLICATIONS_ALL') THEN
      l_phase         := 1;
      l_program_code  := 'AR_UPG';
    ELSE
      l_phase         := 2;
      l_program_code  := 'MRC_UPG';
    END IF;

  END IF;

  -- AR records the run as Active
  record_ar_run
   (p_table_name          => l_table_name,
    p_script_name         => l_script_name,
    p_num_workers         => l_num_workers,
    p_worker_id           => l_worker_id,
    p_batch_size          => l_batch_size,
    p_status              => 'A',
    p_program_code        => l_program_code,
    p_phase               => l_phase,
    p_order_num           => p_order_num,
    x_return_status       => x_return_status,
    x_return_msg          => x_return_msg,
    x_request_control_id  => x_request_control_id);

  IF x_return_status <> 'S' THEN
    FND_MESSAGE.SET_NAME( 'AR', 'AR_CUST_API_ERROR' );
    FND_MESSAGE.SET_TOKEN( 'TEXT', x_return_msg );
    FND_MSG_PUB.ADD;
    RAISE maintenance_record;
  END IF;

  SELECT batch_id
  INTO l_batch_id
  FROM xla_upgrade_requests
  WHERE worker_id = l_worker_id
  AND script_name = l_script_name
  AND table_name = l_table_name ;

  SAVEPOINT upgrade_by_request;
  --
  -- For AR upgrade package does not support the x_return_status
  --
  IF l_table_name = 'RA_CUSTOMER_TRX_ALL' THEN

     IF l_script_name = 'ar120trx_'||l_batch_id THEN

        outandlog( message  =>'  l_table_name  :'||l_table_name );
        outandlog( message  =>'  l_schema      :'||l_schema);
        ARP_XLA_UPGRADE.UPGRADE_TRANSACTIONS(l_table_owner  => l_table_owner,
                          l_table_name   => l_table_name,
                          l_script_name  => l_script_name,
                          l_worker_id    => l_worker_id,
                          l_num_workers  => l_num_workers,
                          l_batch_size   => l_batch_size,
                          l_batch_id     => l_batch_id,
                          l_action_flag  => 'P');

     ELSIF l_script_name = 'ar120br_'||l_batch_id THEN

        outandlog( message  =>'  l_table_name  :'||l_table_name );
        outandlog( message  =>'  l_schema      :'||l_schema);
        ARP_XLA_UPGRADE.UPGRADE_BILLS_RECEIVABLE(l_table_owner  => l_table_owner,
                          l_table_name   => l_table_name,
                          l_script_name  => l_script_name,
                          l_worker_id    => l_worker_id,
                          l_num_workers  => l_num_workers,
                          l_batch_size   => l_batch_size,
                          l_batch_id     => l_batch_id,
                          l_action_flag  => 'P');

     END IF;

  ELSIF l_table_name = 'AR_CASH_RECEIPTS_ALL' THEN
     outandlog( message  =>'  l_table_name  :'||l_table_name );
     outandlog( message  =>'  l_schema      :'||l_schema);

    ARP_XLA_UPGRADE.UPGRADE_RECEIPTS(l_table_owner  => l_table_owner,
                       l_table_name   => l_table_name,
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');

  ELSIF l_table_name = 'AR_RECEIVABLE_APPLICATIONS_ALL' THEN
     outandlog( message  =>'  l_table_name  :'||l_table_name );
     outandlog( message  =>'  l_schema      :'||l_schema);

    ARP_XLA_UPGRADE.UPGRADE_CASH_DIST(l_table_owner  => l_table_owner,
                       l_table_name   => l_table_name,
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');


  ELSIF l_table_name = 'AR_ADJUSTMENTS_ALL'  THEN
     outandlog( message  =>'  l_table_name  :'||l_table_name );
     outandlog( message  =>'  l_schema      :'||l_schema);

    ARP_XLA_UPGRADE.UPGRADE_ADJUSTMENTS(l_table_owner  => l_table_owner,
                       l_table_name   => l_table_name,
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');


  ELSIF l_table_name = 'MC_TRANSACTIONS' THEN
     outandlog( message  =>'  l_table_name  :RA_MC_CUSTOMER_TRX' );
     outandlog( message  =>'  l_schema      :'||l_schema);

    ARP_MRC_XLA_UPGRADE.UPGRADE_MC_TRANSACTIONS
	                  (l_table_owner  => l_table_owner,
                       l_table_name   => 'RA_MC_CUSTOMER_TRX',
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');

  ELSIF l_table_name =  'MC_RECEIPTS' THEN
     outandlog( message  =>'  l_table_name  :AR_MC_CASH_RECEIPTS' );
     outandlog( message  =>'  l_schema      :'||l_schema);

     ARP_MRC_XLA_UPGRADE.UPGRADE_MC_RECEIPTS
	                  (l_table_owner  => l_table_owner,
                       l_table_name   => 'AR_MC_CASH_RECEIPTS',
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');

  ELSIF l_table_name =  'MC_ADJUSTMENTS' THEN
     outandlog( message  =>'  l_table_name  :AR_MC_ADJUSTMENTS' );
     outandlog( message  =>'  l_schema      :'||l_schema);

    ARP_MRC_XLA_UPGRADE.UPGRADE_MC_ADJUSTMENTS
	                  (l_table_owner  => l_table_owner,
                       l_table_name   => 'AR_MC_ADJUSTMENTS',
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');

  --
  -- For JL the upgrade code does support the x_return_status
  --
  ELSIF l_table_name = 'JL_BR_AR_OCCURRENCE_DOCS_ALL' THEN

    outandlog( message  =>'  l_table_name  :JL_BR_AR_OCCURRENCE_DOCS_ALL' );
    outandlog( message  =>'  l_schema      :'||l_schema);
    JL_BR_AR_BANK_ACCT_PKG.UPGRADE_OCCURRENCES(
                       l_table_owner  => l_table_owner,
                       l_table_name   => l_table_name,
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'R',
                       x_return_status=> x_return_status);


  --{ BUG#4645903
  ELSIF l_table_name = 'JL_BR_AR_MC_OCC_DOCS'  THEN

    outandlog( message  =>'  l_table_name  :JL_BR_AR_OCCURRENCE_DOCS_ALL' );
    outandlog( message  =>'  l_schema      :'||l_schema);
    JL_BR_AR_BANK_ACCT_PKG.UPGRADE_MC_OCCURRENCES(
                       l_table_owner  => l_table_owner,
                       l_table_name   => 'JL_BR_AR_OCCURENCE_DOCS_ALL',
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'R',
                       x_return_status=> x_return_status);
  --}
  ELSIF l_table_name = 'PSATRX'  THEN

    --{PSATRX
    ar_upg_psa_dist_pkg.UPGRADE_TRANSACTIONS(
                       l_table_owner  => l_table_owner,
                       l_table_name   => 'PSA_MF_TRX_DIST_ALL',
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');

--{GL Links
  ELSIF l_table_name = 'GL_IMPORT_REFERENCES'  THEN
     outandlog( message  =>'  l_table_name  :'||l_table_name );
     outandlog( message  =>'  l_schema      :'||l_schema);

    ARP_XLA_UPGRADE.update_gl_sla_link(l_table_owner  => l_table_owner,
                       l_table_name   => l_table_name,
                       l_script_name  => l_script_name,
                       l_worker_id    => l_worker_id,
                       l_num_workers  => l_num_workers,
                       l_batch_size   => l_batch_size,
                       l_batch_id     => l_batch_id,
                       l_action_flag  => 'P');
--}

  END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


-- Updating record as successfull
  update_req_control
  (p_request_control_id   => x_request_control_id,
   p_status               => 'S');

  outandlog( message  =>' Ending at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  outandlog( message  =>'Worker has completed successfully');

EXCEPTION
  WHEN maintenance_record THEN
    outandlog('Error:  ' || FND_MESSAGE.GET);
    retcode := 1;
    errbuf := errbuf || logerror;
    outandlog('Aborting concurrent program execution');
--    FND_FILE.close;

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO upgrade_by_request;
    outandlog('Error:  ' || FND_MESSAGE.GET);
    retcode := 1;
    errbuf := errbuf || logerror;
    outandlog('Aborting concurrent program execution');
--    FND_FILE.close;


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --JL raises FND api error
    ROLLBACK TO upgrade_by_request;
    outandlog('Error:  ' || FND_MESSAGE.GET);
    retcode := 1;
    errbuf := errbuf || logerror;
    outandlog('Aborting concurrent program execution');
--    FND_FILE.close;

  WHEN OTHERS THEN
   --AR and MRC and PSA raises when others
    outandlog('Error:  ' || FND_MESSAGE.GET);
    log('SQL Error ' || SQLERRM);
    retcode := 1;
    errbuf := errbuf || logerror || SQLERRM;
    outandlog('Aborting concurrent program execution');
    ROLLBACK TO upgrade_by_request;
--    FND_FILE.close;

END;





PROCEDURE ins_exist_process_again
 (p_product_name           IN   VARCHAR2,
  p_batch_id               IN   NUMBER,
  p_parent_req_control_id  IN   NUMBER,
  x_nb_inserted      OUT NOCOPY NUMBER)
IS
  l_program_code     VARCHAR2(30);
  l_phase            NUMBER;
BEGIN
  IF     p_product_name = 'AR' THEN
     l_program_code := 'AR_UPG';
     l_phase        := 1;
  ELSIF  p_product_name = 'MRC' THEN
     l_program_code := 'MRC_UPG';
     l_phase        := 2;
  ELSIF  p_product_name = 'JL' THEN
     l_program_code := 'JL_UPG';
     l_phase        := 3;
  ELSIF  p_product_name = 'PSA' THEN
     l_program_code := 'PSA_UPG';
     l_phase        := 4;
--{GIR
  ELSIF  p_product_name = 'GL' THEN
     l_program_code := 'GIR_UPG';
     l_phase        := 5;
--}
  END IF;

   INSERT INTO ar_submission_ctrl_gt
   (worker_id         , --worker_number
    batch_id          , --batch_id
    script_name       , --script_name
    status            , --INSERTED, SUBMITTED, (NORMAL, ERROR, WARNING, CANCELLED, TERMINATED)
    order_num         , --order helper number
    request_id        , --request_id
    table_name        ) --table_name
     SELECT worker_id,
            batch_id,
            script_name,
            'INSERTED',
            order_num,
            request_control_id,
            table_name
       FROM xla_upgrade_requests
      WHERE batch_id                  = p_batch_id
        AND parent_request_control_id = p_parent_req_control_id
        AND phase_num                     = l_phase
        AND program_code              = l_program_code
        AND status_code              <> 'S'
		AND application_id            = 222;

    x_nb_inserted := SQL%ROWCOUNT;
END;



PROCEDURE ins_subs_for_one_script
(p_script_name     IN VARCHAR2,
 p_batch_id        IN NUMBER,
 p_order_num       IN VARCHAR2,
 p_table_name      IN VARCHAR2,
 p_workers_num     IN NUMBER)
IS
  i                     NUMBER;
  tab_worker_number     DBMS_SQL.NUMBER_TABLE;
  tab_batch_id          DBMS_SQL.NUMBER_TABLE;
  tab_script_name       DBMS_SQL.VARCHAR2_TABLE;
  tab_status            DBMS_SQL.VARCHAR2_TABLE;
  tab_order             DBMS_SQL.NUMBER_TABLE;
  tab_request_id        DBMS_SQL.NUMBER_TABLE;
  tab_table_name        DBMS_SQL.VARCHAR2_TABLE;
BEGIN
  ins_120_ctl(p_script_name  => p_script_name,
              p_batch_id     => p_batch_id);

  FOR i IN 1 .. p_workers_num LOOP
      tab_worker_number(i)     := i;
      tab_batch_id(i)          := p_batch_id;
      tab_script_name(i)       := p_script_name;
      tab_status(i)            := 'INSERTED';
      tab_order(i)             := p_order_num;
      tab_request_id(i)        := NULL;
      tab_table_name(i)        := p_table_name;
  END LOOP;

  FORALL i IN tab_worker_number.FIRST .. tab_worker_number.LAST
    INSERT INTO ar_submission_ctrl_gt
    (worker_id         , --worker_number
     batch_id          , --batch_id
     script_name       , --script_name
     status            , --INSERTED, SUBMITTED, (NORMAL, ERROR, WARNING, CANCELLED, TERMINATED)
     order_num         , --order helper number
     request_id        , --request_id
     table_name        ) --table_name
    VALUES
    (tab_worker_number(i),
     tab_batch_id(i),
     tab_script_name(i),
     tab_status(i),
     tab_order(i),
     tab_request_id(i),
     tab_table_name(i));
END;



PROCEDURE ins_new_process
(p_product_name           IN   VARCHAR2,
 p_batch_id               IN   NUMBER,
 p_parent_req_control_id  IN   NUMBER,
 p_workers_num            IN   NUMBER,
 x_nb_inserted      OUT NOCOPY NUMBER)
IS
  l_script_name      VARCHAR2(30);
BEGIN
  x_nb_inserted  := 0;

  IF     p_product_name = 'AR' THEN

    l_script_name := 'ar120trx_'||p_batch_id;

    ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 1,
        p_table_name      => 'RA_CUSTOMER_TRX_ALL',
        p_workers_num     => p_workers_num);

    l_script_name := 'ar120br_'||p_batch_id;

    ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 2,
        p_table_name      => 'RA_CUSTOMER_TRX_ALL',
        p_workers_num     => p_workers_num);

    l_script_name := 'ar120rcp_'||p_batch_id;

    ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 3,
        p_table_name      => 'AR_CASH_RECEIPTS_ALL',
        p_workers_num     => p_workers_num);

    l_script_name := 'ar120cash_'||p_batch_id;

    ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 4,
        p_table_name      => 'AR_RECEIVABLE_APPLICATIONS_ALL',
        p_workers_num     => p_workers_num);

    l_script_name := 'ar120adj_'||p_batch_id;

    ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 5,
        p_table_name      => 'AR_ADJUSTMENTS_ALL',
        p_workers_num     => p_workers_num);

    x_nb_inserted  := 5 * p_workers_num;

  ELSIF  p_product_name = 'MRC' THEN

    IF mrc_run_required = 'Y' THEN

      l_script_name := 'armc120trx_'||p_batch_id;

      ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 1,
        p_table_name      => 'MC_TRANSACTIONS',
        p_workers_num     => p_workers_num);

      l_script_name := 'armc120rcp_'||p_batch_id;

      ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 2,
        p_table_name      => 'MC_RECEIPTS',
        p_workers_num     => p_workers_num);

      l_script_name := 'armc120adj_'||p_batch_id;

      ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 3,
        p_table_name      => 'MC_ADJUSTMENTS',
        p_workers_num     => p_workers_num);

      x_nb_inserted  := 3 * p_workers_num;

    END IF;

   ELSIF  p_product_name = 'JL' THEN

     IF JL_BR_AR_BANK_ACCT_PKG.check_if_upgrade_occs THEN

      l_script_name := 'jl120occ_'||p_batch_id;

      ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 1,
        p_table_name      => 'JL_BR_AR_OCCURRENCE_DOCS_ALL',
        p_workers_num     => p_workers_num);

       x_nb_inserted  := p_workers_num;


     END IF;

     IF JL_BR_AR_BANK_ACCT_PKG.check_if_upgrade_occs AND
        mrc_run_required = 'Y'
     THEN

       l_script_name := 'jl120mcocc_'||p_batch_id;

      ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 2,
        p_table_name      => 'JL_BR_AR_MC_OCC_DOCS',
        p_workers_num     => p_workers_num);

       x_nb_inserted  := x_nb_inserted + p_workers_num;
     END IF;


   ELSIF  p_product_name = 'PSA' THEN

      l_script_name := 'psatrx_'||p_batch_id;

      ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 1,
        p_table_name      => 'PSATRX',
        p_workers_num     => p_workers_num);

       x_nb_inserted  := p_workers_num;

--{GIR
  ELSIF  p_product_name = 'GL' THEN
    l_script_name := 'ar120gir_'||p_batch_id;

    ins_subs_for_one_script
       (p_script_name     => l_script_name,
        p_batch_id        => p_batch_id,
        p_order_num       => 1,
        p_table_name      => 'GL_IMPORT_REFERENCES',
        p_workers_num     => p_workers_num);

    x_nb_inserted  := p_workers_num;
--}

   END IF;

END;





PROCEDURE check_run_data
(p_batch_id         IN NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_return_msg       OUT NOCOPY VARCHAR2)
IS
  CURSOR c_req(p_batch_id   IN NUMBER) IS
  SELECT status,
         request_id
    FROM ar_submission_ctrl_gt
   WHERE batch_id   = p_batch_id
     AND status <> 'NORMAL';
  l_status       VARCHAR2(30);
  l_request_id   NUMBER;
BEGIN
  x_return_status := 'S';
  OPEN c_req(p_batch_id);
  FETCH c_req INTO l_status, l_request_id;
  IF c_req%NOTFOUND THEN
    x_return_status := 'S';
  ELSE
    fnd_message.set_name('AR','AR_XLA_EXIST_REQ_ERROR');
    fnd_message.set_token('REQUEST_ID',l_request_id);
    x_return_msg    := fnd_message.get;
    outandlog(x_return_msg);
    x_return_status := 'E';
  END IF;
  CLOSE c_req;
END;




PROCEDURE ar_master_upg_product
 (p_parent_req_control_id   IN NUMBER,
  p_batch_id                IN NUMBER,
  p_reexecution             IN VARCHAR2  DEFAULT 'N',
  p_product_name            IN VARCHAR2,
  p_workers_num             IN NUMBER,
  p_batch_size              IN NUMBER,
  x_return_msg              OUT NOCOPY   VARCHAR2,
  x_return_status           OUT NOCOPY   VARCHAR2 )
IS
  l_result              VARCHAR2(1) := 'N';
  incremental_cnt       NUMBER := 0;
  x_nb_inserted         NUMBER := 0;
  execution_req         VARCHAR2(1);
  nothing_to_run        EXCEPTION;
  finish                EXCEPTION;

  CURSOR c(p_batch_id IN NUMBER)
  IS
  SELECT 'Y'
    FROM ar_submission_ctrl_gt
   WHERE status IN ('INSERTED','SUBMITTED')
     AND batch_id   = p_batch_id;



BEGIN
  log( message  =>'ar_master_upg_product + ' );
  log( message  =>'  Running for the product:'||p_product_name);
  log( message  =>'  Starting at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  log( message  =>'  p_workers_num          :'||p_workers_num);
  log( message  =>'  Is this reexecution    :'||p_reexecution);
  log( message  =>'  p_batch_size           :'||p_batch_size);
  log( message  =>'  p_workers_num          :'||p_workers_num);

  x_return_status  := 'S';

  IF p_workers_num < 1 THEN
    RAISE nothing_to_run;
  END IF;

  IF p_reexecution = 'Y' THEN

    IF p_product_name = 'AR' THEN

     ins_exist_process_again
      (p_product_name          => 'AR',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       x_nb_inserted           => x_nb_inserted);

    ELSIF p_product_name = 'MRC' THEN

     ins_exist_process_again
      (p_product_name          => 'MRC',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       x_nb_inserted           => x_nb_inserted);

    ELSIF p_product_name = 'JL' THEN

     ins_exist_process_again
      (p_product_name          => 'JL',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       x_nb_inserted           => x_nb_inserted);

    ELSIF p_product_name = 'PSA' THEN

     ins_exist_process_again
      (p_product_name          => 'PSA',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       x_nb_inserted           => x_nb_inserted);

--{GIR
    ELSIF p_product_name = 'GL' THEN

     ins_exist_process_again
      (p_product_name          => 'GL',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       x_nb_inserted           => x_nb_inserted);
--}

    END IF;


    IF x_nb_inserted > 0 THEN
      execution_req := 'Y';
    ELSE
      execution_req := 'N';
    END IF;

  ELSE

    IF p_product_name = 'AR' THEN

      ins_new_process
      (p_product_name          => 'AR',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       p_workers_num           => p_workers_num,
       x_nb_inserted           => x_nb_inserted);


    ELSIF p_product_name = 'MRC' THEN

      ins_new_process
      (p_product_name          => 'MRC',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       p_workers_num           => p_workers_num,
       x_nb_inserted           => x_nb_inserted);

    ELSIF p_product_name = 'JL' THEN

      ins_new_process
      (p_product_name          => 'JL',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       p_workers_num           => p_workers_num,
       x_nb_inserted           => x_nb_inserted);

    ELSIF p_product_name = 'PSA' THEN

      ins_new_process
      (p_product_name          => 'PSA',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       p_workers_num           => p_workers_num,
       x_nb_inserted           => x_nb_inserted);

--{GIR
    ELSIF p_product_name = 'GL' THEN

      ins_new_process
      (p_product_name          => 'GL',
       p_batch_id              => p_batch_id,
       p_parent_req_control_id => p_parent_req_control_id,
       p_workers_num           => p_workers_num,
       x_nb_inserted           => x_nb_inserted);

--}

    END IF;

    IF x_nb_inserted > 0 THEN
      execution_req := 'Y';
    ELSE
      execution_req := 'N';
    END IF;

  END IF;


  IF execution_req = 'Y' THEN

    log( message  =>'  In the child requests submission loop');

    LOOP

     OPEN c(p_batch_id);
     FETCH c INTO l_result;
     IF c%NOTFOUND THEN
       RAISE finish;
     END IF;
     CLOSE c;

    submission_main_routine
    (p_workers       => p_workers_num,
     p_batch_id      => p_batch_id,
     p_batch_size    => p_batch_size);

    verif_status
    (p_batch_id    => p_batch_id);

   END LOOP;

  END IF;
  log( message  =>'ar_master_upg_product -' );

EXCEPTION
  WHEN nothing_to_run THEN
    log('number of workers ='||p_workers_num);
    log('nothing to run');
    log( message  =>'  End at ' || to_char(SYSDATE, 'HH24:MI:SS') );
    log( message  =>'ar_master_upg_product - ' );
    x_return_msg := 'number of workers ='||p_workers_num||' nothing to run';
  WHEN finish THEN
   log('Raise Finish');
   IF c%ISOPEN THEN
     close c;
   END IF;
    -- Add XLA update status call
   check_run_data
    (p_batch_id      => p_batch_id,
     x_return_status => x_return_status,
     x_return_msg    => x_return_msg);
   log( message  =>'  End at ' || to_char(SYSDATE, 'HH24:MI:SS') );
   log( message  =>'ar_master_upg_product -' );


END;




PROCEDURE validate_xla_upg_data
(p_ledger_id       IN         NUMBER,
 x_start_date      OUT NOCOPY DATE,
 x_end_date        OUT NOCOPY DATE,
 x_return_status   OUT NOCOPY VARCHAR2,
 x_return_msg      OUT NOCOPY VARCHAR2)
IS
  CURSOR c_xla_dates IS
  SELECT start_date,
         end_date
    FROM xla_upgrade_dates
   WHERE ledger_id = p_ledger_id;


  CURSOR c_ar_xla_dates IS
   SELECT b.start_date,
          b.end_date
     FROM xla_upgrade_requests b
    WHERE b.ledger_id    = p_ledger_id
      AND b.program_code = 'XLA_UPG'
      AND b.status_code  = 'S'
      AND b.phase_num        = 0
      AND b.application_id = 222
      AND EXISTS (SELECT NULL
                   FROM xla_upgrade_dates a
                  WHERE (a.start_date BETWEEN b.start_date AND b.end_date OR
                         a.end_date   BETWEEN b.start_date AND b.end_date)
                    AND a.ledger_id = b.ledger_id);


  l_start_date          DATE;
  l_end_date            DATE;
  nb_of_xla_dates_row   NUMBER := 0;
  l_overlapp            VARCHAR2(1);
  nothing_to_run           EXCEPTION;
  more_than_one_xla_dates  EXCEPTION;
  start_greater_than_end   EXCEPTION;
  overlapp                 EXCEPTION;
BEGIN
  x_return_status := 'S';

  OPEN c_xla_dates;
  LOOP
    FETCH c_xla_dates INTO l_start_date, l_end_date;
    EXIT WHEN c_xla_dates%NOTFOUND;
    nb_of_xla_dates_row  := nb_of_xla_dates_row + 1;
  END LOOP;
  CLOSE c_xla_dates;

  IF     nb_of_xla_dates_row = 0 THEN
    RAISE nothing_to_run;
  ELSIF  nb_of_xla_dates_row > 1 THEN
    RAISE more_than_one_xla_dates;
  END IF;

  IF l_start_date > l_end_date THEN
     RAISE start_greater_than_end;
  END IF;

  OPEN c_ar_xla_dates;
  FETCH c_ar_xla_dates INTO
    l_start_date,
    l_end_date  ;
  IF c_ar_xla_dates%FOUND THEN
    l_overlapp := 'Y';
  END IF;
  CLOSE c_ar_xla_dates;

  IF l_overlapp = 'Y' THEN
    RAISE overlapp;
  END IF;

  x_start_date := l_start_date;
  x_end_date   := l_end_date;

EXCEPTION
  WHEN nothing_to_run THEN
    x_return_status := 'N';
    x_return_msg    := 'AR_XLA_UPGRADE_DATE_MISSING';
  WHEN more_than_one_xla_dates THEN
    x_return_status := 'E';
    x_return_msg    := 'MORE_THAN_ONE_XLA_UPG_DATE';
  WHEN start_greater_than_end THEN
    x_return_status := 'E';
    x_return_msg    := 'XLA_END_GREATER_THAN_START';
  WHEN overlapp THEN
    x_return_status := 'E';
    x_return_msg    := 'AR_XLA_UPGRADE_DATE_OVERLAP';
END;







PROCEDURE lauch_and_relaunch
(p_start_product           IN VARCHAR2,
 p_reexec                  IN VARCHAR2,
 p_parent_req_control_id   IN NUMBER,
 p_batch_id                IN NUMBER,
 p_workers_num             IN NUMBER,
 p_batch_size              IN NUMBER,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_return_msg              OUT NOCOPY VARCHAR2)
IS
  l_current_product     VARCHAR2(30);
  x_request_control_id  NUMBER;
  stop_at_product       EXCEPTION;

BEGIN
  l_current_product         := p_start_product;

  ar_master_upg_product
  (p_parent_req_control_id   => p_parent_req_control_id,
   p_batch_id                => p_batch_id,
   p_reexecution             => p_reexec,
   p_product_name            => p_start_product,
   p_workers_num             => p_workers_num,
   p_batch_size              => p_batch_size,
   x_return_msg              => x_return_msg,
   x_return_status           => x_return_status);


  IF x_return_status <> 'S' THEN
    RAISE stop_at_product;
  END IF;

  IF p_start_product = 'AR' THEN

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'MRC';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;


     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'JL';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'PSA';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'GL';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);

     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

/*  ELSIF p_start_product = 'GL' THEN

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'MRC';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;


     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'JL';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'PSA';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF; */


  ELSIF p_start_product = 'MRC' THEN


     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'JL';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'PSA';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);


     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'GL';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);

     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

  ELSIF p_start_product = 'JL' THEN

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'PSA';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);

     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'GL';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);

     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

  ELSIF p_start_product = 'PSA' THEN

     DELETE FROM ar_submission_ctrl_gt;

     l_current_product         := 'GL';

     ar_master_upg_product
     (p_parent_req_control_id   => x_request_control_id,
      p_batch_id                => p_batch_id,
      p_reexecution             => 'N',
      p_product_name            => l_current_product,
      p_workers_num             => p_workers_num,
      p_batch_size              => p_batch_size,
      x_return_msg              => x_return_msg,
      x_return_status           => x_return_status);

     IF x_return_status <> 'S' THEN
       RAISE stop_at_product;
     END IF;

  END IF;

EXCEPTION
 WHEN stop_at_product   THEN
   x_return_status := 'E';
   x_return_msg    := x_return_msg||'
 Child processes incomplete for '||l_current_product;
   log(x_return_msg);

END;


PROCEDURE ar_master_upg
 (errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_ledger_id    IN NUMBER,
  p_period_name  IN VARCHAR2,
  p_workers_num  IN NUMBER,
  p_batch_size   IN NUMBER)
IS
  CURSOR c_batch_id IS
  SELECT xla_upg_batches_s.NEXTVAL
    FROM dual;


  CURSOR exist_xla_active(p_ledger_id IN NUMBER)
  IS
  SELECT *
    FROM xla_upgrade_requests
   WHERE program_code = 'XLA_UPG'
     AND phase_num        = 0
     AND status_code  = 'A'
     AND ledger_id    = p_ledger_id
	 AND application_id = 222;

  l_xla_upg_rec         xla_upgrade_requests%ROWTYPE;

  CURSOR child_reexc_request(p_ledger_id IN NUMBER,
                             p_batch_id  IN NUMBER)
  IS
  SELECT DECODE(program_code,'AR_UPG' ,'AR' ,
                             'GIR_UPG' ,'GL' , --GIR
                             'MRC_UPG','MRC',
                             'JL_UPG' ,'JL',
							 'PSA_UPG','PSA')
    FROM xla_upgrade_requests
   WHERE program_code <> 'XLA_UPG'
     AND phase_num        <> 0
     AND status_code  =  'A'
     AND ledger_id    =  p_ledger_id
	 AND application_id = 222;


  CURSOR c_xla_upg_dates(p_ledger_id IN NUMBER)
  IS
  SELECT start_date,
         end_date
    FROM xla_upgrade_dates
   WHERE ledger_id    =  p_ledger_id;


  CURSOR c_ledger(p_ledger_id IN NUMBER) IS
  SELECT name
    FROM gl_ledgers
   WHERE ledger_id = p_ledger_id;

  l_ledger_name                 VARCHAR2(30);
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_reexec                      VARCHAR2(1);
  l_start_product               VARCHAR2(30);
  l_batch_id                    NUMBER;
  l_result                      VARCHAR2(1) := 'N';
  l_run_required                VARCHAR2(1);
  l_xla_dates_mismatch          VARCHAR2(1);
  l_dates_missing               VARCHAR2(1);
  x_start_date                  DATE;
  x_end_date                    DATE;
  x_return_status               VARCHAR2(10);
  x_return_msg                  VARCHAR2(2000);
  x_request_control_id          NUMBER;


  nothing_to_run                EXCEPTION;
  should_relaunch_existing_upg  EXCEPTION;
  no_date_in_xla_tab            EXCEPTION;
  previous_run_dates_mismatch   EXCEPTION;

BEGIN
  log( message  =>'ar_master_upg + ' );
  log( message  =>'  Starting at ' || to_char(SYSDATE, 'HH24:MI:SS') );
  log( message  =>'  p_workers_num :'||p_workers_num);

  IF p_workers_num < 1 THEN
    RAISE nothing_to_run;
  END IF;

  retcode := '0';

  OPEN  exist_xla_active(p_ledger_id => p_ledger_id);
  FETCH exist_xla_active INTO l_xla_upg_rec;
  IF exist_xla_active%FOUND THEN
    l_reexec      := 'Y';
  ELSE
    l_reexec      := 'N';
  END IF;
  CLOSE exist_xla_active;


  IF l_reexec = 'Y' THEN

  log('p_period_name:'||p_period_name);
  log('p_ledger_id:'||p_ledger_id);
  log('p_workers_num:'||p_workers_num);
  log('p_batch_size:'||p_batch_size);
    ------------------------------------------------------------
    -- Check the user parameters are the same as the current run
    ------------------------------------------------------------
    IF l_xla_upg_rec.period_name <> p_period_name OR
       l_xla_upg_rec.ledger_id   <> p_ledger_id   OR
       l_xla_upg_rec.workers_num <> p_workers_num OR
       l_xla_upg_rec.batch_size  <> p_batch_size
    THEN
      RAISE should_relaunch_existing_upg;
    ELSE

      OPEN c_xla_upg_dates(p_ledger_id => p_ledger_id);
      FETCH c_xla_upg_dates INTO
        l_start_date,
        l_end_date  ;
      IF c_xla_upg_dates%NOTFOUND THEN
        l_dates_missing := 'Y';
      ELSE
        IF l_xla_upg_rec.start_date <> l_start_date OR
           l_xla_upg_rec.end_date   <> l_end_date
        THEN
           l_xla_dates_mismatch := 'Y';
        END IF;
      END IF;
      CLOSE c_xla_upg_dates;

      IF l_dates_missing = 'Y' THEN
         RAISE no_date_in_xla_tab;
      END IF;

      IF l_xla_dates_mismatch = 'Y' THEN
         RAISE previous_run_dates_mismatch;
      END IF;

    END IF;
  END IF;




  IF l_reexec = 'N' THEN

     -----------------------
     -- 1 Verif XLA_UPG data
     -----------------------
      validate_xla_upg_data
       (p_ledger_id       => p_ledger_id,
        x_start_date      => x_start_date,
        x_end_date        => x_end_date,
        x_return_status   => x_return_status,
        x_return_msg      => x_return_msg);

     IF x_return_status = 'N' THEN
        RAISE nothing_to_run;
     ELSIF x_return_status = 'E' THEN
        RAISE fnd_api.G_EXC_ERROR;
     END IF;


     --------------------------
     --2 record the upgrade run
     --------------------------
     OPEN c_batch_id;
     FETCH  c_batch_id INTO l_batch_id;
     CLOSE c_batch_id;

     l_xla_upg_rec.phase_num        := 0;
     l_xla_upg_rec.PROGRAM_CODE := 'XLA_UPG';
     l_xla_upg_rec.DESCRIPTION  := 'ON DEMAND UPGRADE LEDGER:'||p_ledger_id||
	                               ' FROM '||x_start_date||' TO '|| x_end_date;
     l_xla_upg_rec.STATUS_CODE  := 'A';
     l_xla_upg_rec.LEDGER_ID    := p_ledger_id;
     l_xla_upg_rec.PERIOD_NAME  := p_period_name;
     l_xla_upg_rec.WORKER_ID    := NULL;
     l_xla_upg_rec.WORKERS_NUM  := p_workers_num;
     l_xla_upg_rec.TABLE_NAME   := NULL;
     l_xla_upg_rec.SCRIPT_NAME  := NULL;
     l_xla_upg_rec.BATCH_SIZE   := p_batch_size;
     l_xla_upg_rec.BATCH_ID     := l_batch_id;
     l_xla_upg_rec.ORDER_NUM    := 0;
     l_xla_upg_rec.START_DATE   := x_start_date;
     l_xla_upg_rec.END_DATE     := x_end_date;

     insert_req_control
      (p_ins_rec            => l_xla_upg_rec,
       x_request_control_id => x_request_control_id);

     --------------------------------
     -- Ensure the record is recorded
     --------------------------------
     COMMIT;

     l_xla_upg_rec.request_control_id := x_request_control_id;
     l_start_product           := 'AR';
     l_run_required            := 'Y';
     l_reexec                  := 'N';

  ELSE
    OPEN child_reexc_request(p_ledger_id => p_ledger_id,
                             p_batch_id  =>  l_xla_upg_rec.batch_id);
    FETCH child_reexc_request INTO l_start_product;
    IF child_reexc_request%NOTFOUND THEN
      l_run_required           := 'N';
    ELSE
      l_run_required           := 'Y';
      l_reexec                 := 'Y';
    END IF;
    CLOSE child_reexc_request;
  END IF;


  ---------------------------------
  --Submitting subrequest per product
  ---------------------------------
  IF l_run_required  = 'Y' THEN

     lauch_and_relaunch
     (p_start_product           => l_start_product,
      p_reexec                  => l_reexec,
      p_parent_req_control_id   => l_xla_upg_rec.request_control_id,
      p_batch_id                => l_xla_upg_rec.batch_id,
      p_workers_num             => l_xla_upg_rec.workers_num,
      p_batch_size              => l_xla_upg_rec.batch_size,
      x_return_status           => x_return_status,
      x_return_msg              => x_return_msg);


     IF x_return_status = 'S' THEN

         update_req_control
         (p_request_control_id    => l_xla_upg_rec.request_control_id,
          p_status                => 'S');

         --Update GL PERIOD STATUSES with XLA api
         update_gl_period;
    ELSE
        retcode := '-2';

    END IF;

  END IF;

    log( message  =>'ar_master_upg - ' );

EXCEPTION
  WHEN nothing_to_run THEN
    log('number of workers ='||p_workers_num);
    log('nothing to run');
    log( message  =>'  End at ' || to_char(SYSDATE, 'HH24:MI:SS') );
    log( message  =>'ar_master_upg - ' );
    retcode := 0;
    errbuf := 'number of workers ='||p_workers_num||' nothing to run';

  WHEN should_relaunch_existing_upg THEN
   retcode := -2;
   OPEN c_ledger(l_xla_upg_rec.ledger_id);
   FETCH c_ledger INTO l_ledger_name;
   CLOSE c_ledger;
   fnd_message.set_name('AR','AR_UNSUCCESSFUL_RUN_EXISTS');
   fnd_message.set_token('PERIOD' ,l_xla_upg_rec.period_name);
   fnd_message.set_token('LEDGER' ,l_ledger_name);
   fnd_message.set_token('WORKERS',l_xla_upg_rec.workers_num);
   fnd_message.set_token('SIZE'   ,l_xla_upg_rec.batch_size);
   errbuf := fnd_message.get;
   outandlog(errbuf);

  WHEN no_date_in_xla_tab THEN
   retcode := -2;
   fnd_message.set_name('AR','AR_XLA_UPGRADE_DATE_MISSING');
   errbuf := fnd_message.get;
   outandlog(errbuf);

  WHEN previous_run_dates_mismatch THEN
   retcode := -2;
   fnd_message.set_name('AR','AR_XLA_UPGRADE_DATE_OVERLAP');
   fnd_message.set_token('START_DATE' ,l_start_date);
   fnd_message.set_token('END_DATE'   ,l_end_date);
   fnd_message.set_token('EXIST_START_DATE',l_xla_upg_rec.start_date);
   fnd_message.set_token('EXIST_END_DATE'  ,l_xla_upg_rec.end_date);
   errbuf := fnd_message.get;
   outandlog(errbuf);

END;
















END;

/
