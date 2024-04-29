--------------------------------------------------------
--  DDL for Package Body CST_SLA_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_SLA_UPDATE_PKG" AS
/* $Header: CSTPUPGB.pls 120.28.12010000.2 2009/07/23 12:32:41 smsasidh ship $ */

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'CST_SLA_UPDATE_PKG';
G_LOG_LEVEL    CONSTANT NUMBER  := fnd_log.G_CURRENT_RUNTIME_LEVEL;
gUserId        NUMBER  := nvl(fnd_global.user_id, -888);
gLoginId       NUMBER  := nvl(fnd_global.login_id, -888);
gRequestId     NUMBER  := nvl(fnd_global.conc_request_id, -1);
gUpdateDate    DATE    := SYSDATE;
gLogError      BOOLEAN := FALSE;

g_mrc_enabled  boolean := TRUE;

------------------------------------------------------------------------------------
--  API name   : log_message
--  Type       : Private
--  Function   : Function to log messages into fnd_log_messages
--
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_fndlevel   IN NUMBER
--                     X_module     IN VARCHAR2
--                     X_message    IN VARCHAR2
--
--  OUT        :
--
--  Version    : Initial version       1.0
--  Notes      : The API is used for Error logging during Exception
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE log_message (
              X_fndlevel   IN NUMBER,
              X_module     IN VARCHAR2,
              X_message    IN VARCHAR2)
IS
BEGIN
  IF X_fndlevel >= G_LOG_LEVEL AND NOT gLogError THEN
    fnd_log.string( X_fndlevel, X_module, X_message);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     gLogError := TRUE;
     fnd_file.put_line(fnd_file.log, 'EXCEPTION: log_message: '||SQLERRM);
     fnd_file.put_line(fnd_file.log, 'Disabling FND Logging..');
END log_message;

------------------------------------------------------------------------------------
--  API name   : handle_error
--  Type       : Private
--  Function   : Function to Log Errors, Exceptions depending upon the whether
--               called from Concurrent Request or Hot Patch
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_module     IN VARCHAR2
--                     X_message    IN VARCHAR2
--                     X_reqerror   IN BOOLEAN
--
--  OUT        :       X_errbuf     OUT NOCOPY VARCHAR2
--
--  Version    : Initial version       1.0
--  Notes      : The API is used for Error logging during Exception
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE handle_error (
              X_module     IN VARCHAR2,
              X_message    IN VARCHAR2,
              X_reqerror   IN BOOLEAN DEFAULT FALSE,
              X_errbuf     OUT NOCOPY VARCHAR2)
IS
l_conc_status BOOLEAN;
l_stmt_num    NUMBER;
BEGIN

  /* Error Logging depending upon whether called from
    Concurrent Request or Hot Patch */

  IF gRequestId > 0 THEN --Concurrent Request

    l_stmt_num := 10;

    --Print the Error in Request Log File
    fnd_file.put_line(fnd_file.log, X_module||' => '||X_message);

    l_stmt_num := 20;

    --Set the Concurrent Request as Error, depending upon the parameter
    IF X_reqerror THEN
      l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', X_errbuf);
    END IF;

  ELSE  --Hot Patch

    l_stmt_num := 30;

    --Save the Error in FND Memory Variables
    fnd_msg_pub.add_exc_msg (
      p_pkg_name => 'CST_SLA_UPDATE_PKG',
      p_procedure_name => SUBSTR(X_module, 30),
      p_error_text => X_message
    );

  END IF;

  X_errbuf := X_message;

EXCEPTION
  WHEN OTHERS THEN
     X_errbuf := 'UNEXPECTED: handle_error.'||l_stmt_num||':'||SQLERRM;
END handle_error;

------------------------------------------------------------------------------------
--  API name   : CST_Upgrade_Wrapper
--  Type       : Public
--  Function   : Wrapper to support XLA Concurrent mode Upgrade
--
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Num_Workers    in  number default 16,
--                     X_ledger_id      in  number default null,
--                     X_Application_Id in  number default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Version    : Initial version       1.0
--  Notes      : Wrapper to support XLA Concurrent mode Upgrade
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE CST_Upgrade_Wrapper (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  number default null,
               X_Application_Id in  number default null)
IS

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.CST_Upgrade_Wrapper';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);

    l_api_version   NUMBER := 1.0;
    l_init_msg_list VARCHAR2(1) := 'T';

    l_stmt_num     number;

    l_inv_req_id   number;
    l_wip_req_id   number;
    l_rcv_req_id   number;

    l_sub_reqtab   fnd_concurrent.requests_tab_type;
    l_req_status   boolean := TRUE;
    l_subreq_wait  boolean := TRUE;

    l_reqid_count  number;

    l_ret_code     varchar2(10);

BEGIN

  IF l_Log THEN
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
  ELSE
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
  END IF;

  l_stmt_num :=0;
  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.begin',
      'Entering CST_SLA_UPDATE_PKG.CST_Upgrade_Wrapper with '||
      'X_batch_size     = '||X_batch_size||','||
      'X_Num_Workers    = '||X_Num_Workers||','||
      'X_ledger_id      = '||X_ledger_id||','||
      'X_Application_Id = '||X_Application_Id
      );
  END IF;

  /* can not run two costing upgrade requests at the same time */
  l_stmt_num :=5;
  l_reqid_count := 0;

  SELECT min(fcr.request_id)
  into l_reqid_count
  FROM   fnd_concurrent_requests fcr,
         fnd_concurrent_programs fcp
  WHERE  fcp.concurrent_program_name IN ('CSTSLAUM')
  AND    fcp.application_id = 702
  AND    fcr.concurrent_program_id = fcp.concurrent_program_id
  AND    fcr.program_application_id = fcp.application_id
  AND    fcr.phase_code IN ('I','P','R');

  if (l_reqid_count <> 0 ) then
    X_errbuf := 'Another Costing Upgrade Manager is running. Check Request: '||l_reqid_count;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  IF X_Application_Id NOT IN (201, 401) THEN
    X_errbuf := 'Incorrect Application ID. X_Application_Id = '||X_Application_Id;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_retcode := FND_API.G_RET_STS_SUCCESS;

  IF X_Application_Id = 401 THEN
    l_stmt_num :=10;
    l_inv_req_id := FND_REQUEST.submit_request(
                               application => 'BOM',
                               program     => 'CSTUINVM',
                               description => NULL,
                               start_time  => NULL,
                               --sub_request => TRUE,
                               argument1   => l_api_version,
                               argument2   => l_init_msg_list,
                               argument3   => X_batch_size,
                               argument4   => X_Num_Workers,
                               argument5   => X_Ledger_Id);

    fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  Upgrade Historical Inventory Transactions for Subledger Accounting       [CSTUINVM] -> Request: '||l_inv_req_id);

    l_stmt_num :=15;
    l_wip_req_id := FND_REQUEST.submit_request(
                               application => 'BOM',
                               program     => 'CSTUWIPM',
                               description => NULL,
                               start_time  => NULL,
                               --sub_request => TRUE,
                               argument1   => l_api_version,
                               argument2   => l_init_msg_list,
                               argument3   => X_batch_size,
                               argument4   => X_Num_Workers,
                               argument5   => X_Ledger_Id);

    fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  Upgrade Historical Work In Process Transactions for Subledger Accounting [CSTUWIPM] -> Request: '||l_wip_req_id );

    IF (l_inv_req_id = 0 AND l_wip_req_id = 0 ) THEN
        X_errbuf := 'Failure in Sub-Request Submission';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSIF X_Application_Id = 201 THEN

    l_stmt_num :=20;
    l_rcv_req_id := FND_REQUEST.submit_request(
                               application => 'BOM',
                               program     => 'CSTURCVM',
                               description => NULL,
                               start_time  => NULL,
                               --sub_request => TRUE,
                               argument1   => l_api_version,
                               argument2   => l_init_msg_list,
                               argument3   => X_batch_size,
                               argument4   => X_Num_Workers,
                               argument5   => X_Ledger_Id);

      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  Upgrade Historical Receiving Transactions for Subledger Accounting       [CSTURCVM] -> Request: '||l_rcv_req_id);

    IF (l_rcv_req_id = 0 ) THEN
        X_errbuf := 'Failure in Sub-Request Submission';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  commit;  --explicit important one

  l_stmt_num :=30;

  /* Wait for child requests to complete */
  WHILE l_subreq_wait LOOP

     dbms_lock.sleep(100); --Sleep for 100 seconds

     IF X_Application_Id = 401 THEN
        l_sub_reqtab(1).request_id := l_inv_req_id;
        l_req_status := fnd_concurrent.get_request_status(request_id => l_sub_reqtab(1).request_id,
                                                          phase => l_sub_reqtab(1).phase,
                                                          status => l_sub_reqtab(1).status,
                                                          dev_phase => l_sub_reqtab(1).dev_phase,
                                                          dev_status => l_sub_reqtab(1).dev_status,
                                                          message => l_sub_reqtab(1).message);
        l_sub_reqtab(2).request_id := l_wip_req_id;
        l_req_status := fnd_concurrent.get_request_status(request_id => l_sub_reqtab(2).request_id,
                                                          phase => l_sub_reqtab(2).phase,
                                                          status => l_sub_reqtab(2).status,
                                                          dev_phase => l_sub_reqtab(2).dev_phase,
                                                          dev_status => l_sub_reqtab(2).dev_status,
                                                          message => l_sub_reqtab(2).message);


     ELSIF X_Application_Id = 201 THEN
        l_sub_reqtab(1).request_id := l_rcv_req_id;
        l_req_status := fnd_concurrent.get_request_status(request_id => l_sub_reqtab(1).request_id,
                                                          phase => l_sub_reqtab(1).phase,
                                                          status => l_sub_reqtab(1).status,
                                                          dev_phase => l_sub_reqtab(1).dev_phase,
                                                          dev_status => l_sub_reqtab(1).dev_status,
                                                          message => l_sub_reqtab(1).message);
     END IF;

     l_subreq_wait := FALSE;

     for i IN 1..l_sub_reqtab.COUNT() loop
        if (l_sub_reqtab(i).dev_phase <> 'COMPLETE') then
           l_subreq_wait := TRUE;
           exit;
        end if;
     end loop;

  END LOOP;

  l_stmt_num :=40;

  /* Checking whether the child requests completed succesful */
  x_retcode := FND_API.G_RET_STS_SUCCESS;
  for i IN 1..l_sub_reqtab.COUNT() loop
     if (l_sub_reqtab(i).dev_status <> 'NORMAL') then
        fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Concurrent Request: '||l_sub_reqtab(i).request_id||' -> Status: '||l_sub_reqtab(i).dev_status);
        X_retcode := FND_API.g_ret_sts_unexp_error;
     end if;
  end loop;

  if (X_retcode = FND_API.G_RET_STS_SUCCESS) then
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>All Concurrent Sub-Requests Successfull');
     l_stmt_num :=50;
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Setting Migration Status Code in GPS as ''U'' for Application ID '||X_Application_Id);
     l_ret_code := XLA_UPGRADE_PUB.set_migration_status_code(
                                  p_application_id =>X_Application_Id,
                                  p_set_of_books_id=>null,
                                  p_period_name    =>null,
                                  p_period_year    =>null);
  else
     X_errbuf := 'One or More of Upgrade Sub-Managers completed in Error';
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  COMMIT;

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.end',
      'Exiting CST_SLA_UPDATE_PKG.CST_Upgrade_Wrapper with '||
      'X_errbuf = '||X_errbuf||','||
      'X_retcode = '||X_retcode
      );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

END CST_Upgrade_Wrapper;
------------------------------------------------------------------------------------
--  API name   : Update_Proc_MGR
--  Type       : Public
--  Function   : Manager process to launch three sub-managers that are
--       1.Upgrade Historical Inventory Transactions for Subledger Accounting
--       2.Upgrade Historical Work In Progress Transactions for Subledger Accounting
--       3.Upgrade Historical Receiving Transactions for Subledger Accounting
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Costing Subledgers to SLA"
--               manager Concurrent Executable and Concurrent Program.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER DEFAULT 1.0,
               X_init_msg_list  IN  VARCHAR2 DEFAULT 'T',
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Argument4      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default NULL)
IS

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Proc_MGR';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);

    l_stmt_num     number;
    l_api_name     CONSTANT VARCHAR2(30)   := 'Update_Proc_MGR';
    l_api_version  CONSTANT NUMBER           := 1.0;

    l_inv_req_id   number;
    l_wip_req_id   number;
    l_rcv_req_id   number;

    l_sub_reqtab   fnd_concurrent.requests_tab_type;
    req_data       varchar2(10);
    submit_req     boolean;

    l_prg_appid    number;
    l_program_name varchar2(15);
    l_reqid_count  number;

    l_ret_code     varchar2(10);

BEGIN

  IF l_Log THEN
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
  ELSE
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
  END IF;

  l_stmt_num :=0;
  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.begin',
      'Entering CST_SLA_UPDATE_PKG.Update_Proc_MGR with '||
      'X_batch_size = '||X_batch_size||','||
      'X_Num_Workers = '||X_Num_Workers||','||
      'X_Argument4 = '||X_Argument4||','||
      'X_Argument5 = '||X_Argument5||','||
      'X_Argument6 = '||X_Argument6||','||
      'X_Argument7 = '||X_Argument7||','||
      'X_Argument8 = '||X_Argument8||','||
      'X_Argument9 = '||X_Argument9||','||
      'X_Argument10 = '||X_Argument10
      );
  END IF;

  if gRequestId > 0 then
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Upgrade Costing Subledgers to SLA Request: '||gRequestId);
  else
     raise_application_error(-20001, 'SUBMIT_SUBREQUESTS() must be called from a concurrent request');
  end if;

  /* can not run two costing upgrade requests at the same time */
  l_stmt_num :=5;
  l_prg_appid := 702;
  l_program_name := 'CSTSLAUM';
  l_reqid_count := 0;

  SELECT min(fcr.request_id)
  into l_reqid_count
  FROM   fnd_concurrent_requests fcr,
         fnd_concurrent_programs fcp
  WHERE  fcp.concurrent_program_name = l_program_name
  AND    fcp.application_id = l_prg_appid
  AND    fcr.concurrent_program_id = fcp.concurrent_program_id
  AND    fcr.program_application_id = fcp.application_id
  AND    fcr.phase_code IN ('I','P','R');

  if (l_reqid_count <> gRequestId) then
    X_errbuf := 'Another Costing Upgrade Manager is running. Check Request: '||l_reqid_count;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call (
           l_api_version,
           X_api_version,
           l_api_name,
           G_PKG_NAME ) THEN
    X_errbuf := 'Incompatible API Call.';
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  req_data := fnd_conc_global.request_data;

  if (req_data is null) then
     submit_req := TRUE;
  else
     submit_req := FALSE;
  end if;

  if (submit_req = TRUE) then

      -- Initialize message list if X_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(X_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Submitting Concurrent Sub-Requests....');

      x_retcode := FND_API.G_RET_STS_SUCCESS;

      l_stmt_num :=10;
      l_inv_req_id := FND_REQUEST.submit_request(
                                 application => 'BOM',
                                 program     => 'CSTUINVM',
                                 description => NULL,
                                 start_time  => NULL,
                                 sub_request => TRUE,
                                 argument1   => X_api_version,
                                 argument2   => X_init_msg_list,
                                 argument3   => X_batch_size,
                                 argument4   => X_Num_Workers);

      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  Upgrade Historical Inventory Transactions for Subledger Accounting       [CSTUINVM] -> Request: '||l_inv_req_id);

      l_stmt_num :=20;
      l_wip_req_id := FND_REQUEST.submit_request(
                                 application => 'BOM',
                                 program     => 'CSTUWIPM',
                                 description => NULL,
                                 start_time  => NULL,
                                 sub_request => TRUE,
                                 argument1   => X_api_version,
                                 argument2   => X_init_msg_list,
                                 argument3   => X_batch_size,
                                 argument4   => X_Num_Workers);

      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  Upgrade Historical Work In Process Transactions for Subledger Accounting [CSTUWIPM] -> Request: '||l_wip_req_id );

      l_stmt_num :=30;
      l_rcv_req_id := FND_REQUEST.submit_request(
                                 application => 'BOM',
                                 program     => 'CSTURCVM',
                                 description => NULL,
                                 start_time  => NULL,
                                 sub_request => TRUE,
                                 argument1   => X_api_version,
                                 argument2   => X_init_msg_list,
                                 argument3   => X_batch_size,
                                 argument4   => X_Num_Workers);

      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  Upgrade Historical Receiving Transactions for Subledger Accounting       [CSTURCVM] -> Request: '||l_rcv_req_id);

      IF (l_inv_req_id = 0 AND l_wip_req_id = 0 AND l_rcv_req_id = 0) THEN
          X_errbuf := 'Failure in Sub-Request Submission';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_stmt_num :=40;
      fnd_conc_global.set_req_globals(conc_status=>'PAUSED',
                                      request_data=>3);

      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Waiting for Concurrent Sub-Requests to Complete....');

      X_errbuf    := 'Submitted Sub-Requests';

      return;

  else
     fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Checking Status Of Concurrent Sub-Requests....');
     --
     -- restart case
     --
     l_stmt_num :=50;
     l_sub_reqtab := fnd_concurrent.get_sub_requests(gRequestId);
     x_retcode := FND_API.G_RET_STS_SUCCESS;

     for i IN 1..l_sub_reqtab.COUNT()
     loop
        if (l_sub_reqtab(i).dev_status <> 'NORMAL') then
           fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Concurrent Request: '||l_sub_reqtab(i).request_id||' -> Status: '||l_sub_reqtab(i).dev_status);
           X_retcode := FND_API.g_ret_sts_unexp_error;
        end if;
     end loop;

     if (X_retcode = FND_API.G_RET_STS_SUCCESS) then
        fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>All Concurrent Sub-Requests Successfull');
     else
        X_errbuf := 'One or More of Upgrade Sub-Managers completed in Error';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

     commit;
  end if;

  <<out_arg_log>>

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.end',
      'Exiting CST_SLA_UPDATE_PKG.Update_Proc_MGR with '||
      'X_errbuf = '||X_errbuf||','||
      'X_retcode = '||X_retcode
      );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

END Update_Proc_MGR;

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_INV_MGR
--  Type       : Public
--  Function   : Manager process to update Inventory Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Historical Inventory
--               Transactions for Subledger Accounting"
--               manager Concurrent Executable and Concurrent Program.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_INV_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER,
               X_init_msg_list  IN  VARCHAR2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null)
IS
    l_argument4     number;
    l_argument5     number;
    l_product       varchar2(30);
    l_status        varchar2(30);
    l_industry      varchar2(30);
    l_retstatus     boolean;
    l_table_owner   varchar2(30);

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Proc_INV_MGR';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);

    l_sub_reqtab   fnd_concurrent.requests_tab_type;
    req_data       varchar2(10);
    submit_req     boolean;

    l_stmt_num     number;
    l_api_name     CONSTANT VARCHAR2(30)   := 'Update_Proc_INV_MGR';
    l_api_version  CONSTANT NUMBER           := 1.0;

BEGIN

    IF l_Log THEN
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
    ELSE
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
    END IF;

    l_stmt_num :=0;
    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.begin',
        'Entering CST_SLA_UPDATE_PKG.Update_Proc_INV_MGR with '||
        'X_batch_size = '||X_batch_size||','||
        'X_Num_Workers = '||X_Num_Workers||','||
        'X_Ledger_Id = '||X_Ledger_Id||','||
        'X_Argument5 = '||X_Argument5||','||
        'X_Argument6 = '||X_Argument6||','||
        'X_Argument7 = '||X_Argument7||','||
        'X_Argument8 = '||X_Argument8||','||
        'X_Argument9 = '||X_Argument9||','||
        'X_Argument10 = '||X_Argument10
        );
    END IF;

    if gRequestId > 0 then
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>INV Upgrade Manager Concurrent Request: '||gRequestId);
    else
       raise_application_error(-20001, 'SUBMIT_SUBREQUESTS() must be called from a concurrent request');
    end if;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
             l_api_version,
             X_api_version,
             l_api_name,
             G_PKG_NAME ) THEN
      X_errbuf := 'Incompatible API Call.';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    req_data := fnd_conc_global.request_data;

    if (req_data is null) then
       submit_req := TRUE;
    else
       submit_req := FALSE;
    end if;

    if (submit_req = TRUE) then

      -- Initialize message list if X_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(X_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      x_retcode := FND_API.G_RET_STS_SUCCESS;

      --
      -- get schema name of the table for ID range processing
      --
      l_product :='INV';

      l_stmt_num :=10;
      l_retstatus := fnd_installation.get_app_info(
                         l_product, l_status, l_industry, l_table_owner);

      if ((l_retstatus = TRUE) AND (l_table_owner is not null)) then

         Begin

            select TO_CHAR(MIN(xud.start_date), 'YYYYDDMM'), TO_CHAR(MAX(xud.end_date), 'YYYYDDMM')
            into l_argument4, l_argument5
            from xla_upgrade_dates xud
            where ledger_id = nvl(X_Ledger_Id,ledger_id);

            l_stmt_num :=20;
            if (l_argument4 is not null) then
                    fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Submitting Workers for INV Upgrade [CSTUINVW]');
                    AD_CONC_UTILS_PKG.submit_subrequests(
                           X_errbuf=>X_errbuf,
                           X_retcode=>X_retcode,
                           X_WorkerConc_app_shortname=>'BOM',
                           X_WorkerConc_progname=>'CSTUINVW',
                           X_Batch_size=>X_batch_size,
                           X_Num_Workers=>X_Num_Workers,
                           X_Argument4 => l_argument4,
                           X_Argument5 => l_argument5,
                           X_Argument6 => X_Ledger_Id,
                           X_Argument7 => null,
                           X_Argument8 => null,
                           X_Argument9 => null,
                           X_Argument10 => null);

               if (X_retcode <>AD_CONC_UTILS_PKG.CONC_SUCCESS) THEN
                  X_errbuf := 'Submission of INV Upgrade Workers failed -> X_retcode = '||X_retcode;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;

               l_stmt_num :=30;

               l_sub_reqtab := fnd_concurrent.get_sub_requests(gRequestId);

               for i IN 1..l_sub_reqtab.COUNT() loop
                 fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  INV Worker [CSTUINVW] '||RPAD(i,2)||' - '||l_sub_reqtab(i).request_id);
               end loop;

            end if;
            /* can not update migration_status_code until WIP upgrade is done, because they share the same period.*/
         exception
            when no_data_found then
              fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'No Data Found in XUD');
         end;
      else
         X_errbuf := 'Cannot get schema name for product : '||l_product;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      /* can not update migration_status_code until WIP upgrade is done, because they share the same period.*/

    else
      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Checking Status Of Child Workers....');
      --
      -- restart case
      --
      l_stmt_num :=40;
      l_sub_reqtab := fnd_concurrent.get_sub_requests(gRequestId);

      x_retcode := FND_API.G_RET_STS_SUCCESS;
      for i IN 1..l_sub_reqtab.COUNT()
      loop
         if (l_sub_reqtab(i).dev_status <> 'NORMAL') then
            fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Concurrent Request: '||l_sub_reqtab(i).request_id||' -> Status: '||l_sub_reqtab(i).dev_status);
            X_retcode := FND_API.g_ret_sts_unexp_error;
         end if;
      end loop;

      if (X_retcode = FND_API.G_RET_STS_SUCCESS) then
         fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>All Child Workers are Successfull');
      else
         X_errbuf := 'One or More of Child Workers completed in Error';
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      commit;
    end if;

    <<out_arg_log>>

    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.end',
        'Exiting CST_SLA_UPDATE_PKG.Update_Proc_INV_MGR with '||
        'X_errbuf = '||X_errbuf||','||
        'X_retcode = '||X_retcode
        );
    END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

END Update_Proc_INV_MGR;

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_WIP_MGR
--  Type       : Public
--  Function   : Manager process to update WIP Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Historical Work In Process
--               Transactions for Subledger Accounting"
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_WIP_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER,
               X_init_msg_list  IN  VARCHAR2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null)
IS
    l_argument4     number;
    l_argument5     number;
    l_product       varchar2(30);
    l_status        varchar2(30);
    l_industry      varchar2(30);
    l_retstatus     boolean;
    l_table_owner   varchar2(30);

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Proc_WIP_MGR';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);

    l_sub_reqtab   fnd_concurrent.requests_tab_type;
    req_data       varchar2(10);
    submit_req     boolean;

    l_stmt_num     number;
    l_api_name     CONSTANT VARCHAR2(30)   := 'Update_Proc_WIP_MGR';
    l_api_version  CONSTANT NUMBER           := 1.0;

BEGIN

    IF l_Log THEN
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
    ELSE
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
    END IF;

    l_stmt_num :=0;
    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.begin',
        'Entering CST_SLA_UPDATE_PKG.Update_Proc_WIP_MGR with '||
        'X_batch_size = '||X_batch_size||','||
        'X_Num_Workers = '||X_Num_Workers||','||
        'X_Ledger_Id = '||X_Ledger_Id||','||
        'X_Argument5 = '||X_Argument5||','||
        'X_Argument6 = '||X_Argument6||','||
        'X_Argument7 = '||X_Argument7||','||
        'X_Argument8 = '||X_Argument8||','||
        'X_Argument9 = '||X_Argument9||','||
        'X_Argument10 = '||X_Argument10
        );
    END IF;

    if gRequestId > 0 then
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>WIP Upgrade Manager Concurrent Request: '||gRequestId);
    else
       raise_application_error(-20001, 'SUBMIT_SUBREQUESTS() must be called from a concurrent request');
    end if;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
             l_api_version,
             X_api_version,
             l_api_name,
             G_PKG_NAME ) THEN
      X_errbuf := 'Incompatible API Call.';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    req_data := fnd_conc_global.request_data;

    if (req_data is null) then
       submit_req := TRUE;
    else
       submit_req := FALSE;
    end if;

    if (submit_req = TRUE) then

      -- Initialize message list if X_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(X_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      x_retcode := FND_API.G_RET_STS_SUCCESS;

      --
      -- get schema name of the table for ID range processing
      --
      l_product :='WIP';

      l_stmt_num :=10;
      l_retstatus := fnd_installation.get_app_info(
                         l_product, l_status, l_industry, l_table_owner);

      if ((l_retstatus = TRUE) AND (l_table_owner is not null)) then

         begin

            select TO_CHAR(MIN(xud.start_date), 'YYYYDDMM'), TO_CHAR(MAX(xud.end_date), 'YYYYDDMM')
            into l_argument4, l_argument5
            from xla_upgrade_dates xud
            where ledger_id = nvl(X_Ledger_Id,ledger_id);

            l_stmt_num :=20;
            if (l_argument4 is not null) then
                fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Submitting Workers for WIP Upgrade [CSTUWIPW]');
                AD_CONC_UTILS_PKG.submit_subrequests(
                       X_errbuf=>X_errbuf,
                       X_retcode=>X_retcode,
                       X_WorkerConc_app_shortname=>'BOM',
                       X_WorkerConc_progname=>'CSTUWIPW',
                       X_Batch_size=>X_batch_size,
                       X_Num_Workers=>X_Num_Workers,
                       X_Argument4 => l_argument4,
                       X_Argument5 => l_argument5,
                       X_Argument6 => X_Ledger_Id,
                       X_Argument7 => null,
                       X_Argument8 => null,
                       X_Argument9 => null,
                       X_Argument10 => null  );

               if (X_retcode <>AD_CONC_UTILS_PKG.CONC_SUCCESS) THEN
                  X_errbuf := 'Submission of WIP Upgrade Workers failed -> X_retcode = '||X_retcode;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;

               l_stmt_num :=30;

               l_sub_reqtab := fnd_concurrent.get_sub_requests(gRequestId);

               for i IN 1..l_sub_reqtab.COUNT() loop
                 fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  WIP Worker [CSTUWIPW] '||RPAD(i,2)||' - '||l_sub_reqtab(i).request_id);
               end loop;

            end if;
         exception
            when no_data_found then
              fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'No Data Found in XUD');
         end;
      else
         X_errbuf := 'Cannot get schema name for product : '||l_product;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      /* can not update migration_status_code until Inventory upgrade is done, because they share the same period.*/

    else
      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Checking Status Of Child Workers....');
      --
      -- restart case
      --
      l_stmt_num :=40;
      l_sub_reqtab := fnd_concurrent.get_sub_requests(gRequestId);

      x_retcode := FND_API.G_RET_STS_SUCCESS;
      for i IN 1..l_sub_reqtab.COUNT()
      loop
         if (l_sub_reqtab(i).dev_status <> 'NORMAL') then
            fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Concurrent Request: '||l_sub_reqtab(i).request_id||' -> Status: '||l_sub_reqtab(i).dev_status);
            X_retcode := FND_API.g_ret_sts_unexp_error;
         end if;
      end loop;

      if (X_retcode = FND_API.G_RET_STS_SUCCESS) then
         fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>All Child Workers are Successfull');
      else
         X_errbuf := 'One or More of Child Workers completed in Error';
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      commit;
    end if;

    <<out_arg_log>>

    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.end',
        'Exiting CST_SLA_UPDATE_PKG.Update_Proc_WIP_MGR with '||
        'X_errbuf = '||X_errbuf||','||
        'X_retcode = '||X_retcode
        );
    END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

END Update_Proc_WIP_MGR;

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_RCV_MGR
--  Type       : Public
--  Function   : Manager process to update Receiving Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_api_version    IN NUMBER,
--                     X_init_msg_list  IN VARCHAR2,
--                     X_batch_size     in  number default 10000,
--                     X_Num_Workers    in  number default 16,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Historical Receiving
--               Transactions for Subledger Accounting"
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_RCV_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               X_api_version    IN  NUMBER,
               X_init_msg_list  IN  VARCHAR2,
               X_batch_size     in  number default 10000,
               X_Num_Workers    in  number default 16,
               X_Ledger_Id      in  varchar2 default null,
               X_Argument5      in  varchar2 default null,
               X_Argument6      in  varchar2 default null,
               X_Argument7      in  varchar2 default null,
               X_Argument8      in  varchar2 default null,
               X_Argument9      in  varchar2 default null,
               X_Argument10     in  varchar2 default null)
IS
    l_argument4     number;
    l_argument5     number;
    l_product       varchar2(30);
    l_status        varchar2(30);
    l_industry      varchar2(30);
    l_retstatus     boolean;
    l_table_owner   varchar2(30);

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Proc_RCV_MGR';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module);

    l_sub_reqtab   fnd_concurrent.requests_tab_type;
    req_data       varchar2(10);
    submit_req     boolean;

    l_stmt_num     number;
    l_api_name     CONSTANT VARCHAR2(30)   := 'Update_Proc_RCV_MGR';
    l_api_version  CONSTANT NUMBER           := 1.0;

BEGIN

    IF l_Log THEN
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
    ELSE
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
    END IF;

    l_stmt_num :=0;
    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.begin',
        'Entering CST_SLA_UPDATE_PKG.Update_Proc_RCV_MGR with '||
        'X_batch_size = '||X_batch_size||','||
        'X_Num_Workers = '||X_Num_Workers||','||
        'X_Ledger_Id = '||X_Ledger_Id||','||
        'X_Argument5 = '||X_Argument5||','||
        'X_Argument6 = '||X_Argument6||','||
        'X_Argument7 = '||X_Argument7||','||
        'X_Argument8 = '||X_Argument8||','||
        'X_Argument9 = '||X_Argument9||','||
        'X_Argument10 = '||X_Argument10
        );
    END IF;

    if gRequestId > 0 then
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>RCV Upgrade Manager Concurrent Request: '||gRequestId);
    else
       raise_application_error(-20001, 'SUBMIT_SUBREQUESTS() must be called from a concurrent request');
    end if;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
             l_api_version,
             X_api_version,
             l_api_name,
             G_PKG_NAME ) THEN
      X_errbuf := 'Incompatible API Call.';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    req_data := fnd_conc_global.request_data;

    if (req_data is null) then
       submit_req := TRUE;
    else
       submit_req := FALSE;
    end if;

    if (submit_req = TRUE) then

      -- Initialize message list if X_init_msg_list is set to TRUE
      IF FND_API.to_Boolean(X_init_msg_list) THEN
        FND_MSG_PUB.initialize;
      END IF;

      x_retcode := FND_API.G_RET_STS_SUCCESS;

      --
      -- get schema name of the table for ID range processing
      --
      l_product :='PO';

      l_stmt_num :=10;
      l_retstatus := fnd_installation.get_app_info(
                         l_product, l_status, l_industry, l_table_owner);

      if ((l_retstatus = TRUE) AND (l_table_owner is not null)) then

         begin

            select TO_CHAR(MIN(xud.start_date), 'YYYYDDMM'), TO_CHAR(MAX(xud.end_date), 'YYYYDDMM')
            into l_argument4, l_argument5
            from xla_upgrade_dates xud
            where ledger_id = nvl(X_Ledger_Id,ledger_id);

            l_stmt_num :=20;
            if (l_argument4 is not null) then
               fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Submitting Workers for RCV Upgrade [CSTURCVW]');
               AD_CONC_UTILS_PKG.submit_subrequests(
                      X_errbuf=>X_errbuf,
                      X_retcode=>X_retcode,
                      X_WorkerConc_app_shortname=>'BOM',
                      X_WorkerConc_progname=>'CSTURCVW',
                      X_Batch_size=>X_batch_size,
                      X_Num_Workers=>X_Num_Workers,
                      X_Argument4 => l_argument4,
                      X_Argument5 => l_argument5,
                      X_Argument6 => X_Ledger_Id,
                      X_Argument7 => null,
                      X_Argument8 => null,
                      X_Argument9 => null,
                      X_Argument10 => null  );

               if (X_retcode <>AD_CONC_UTILS_PKG.CONC_SUCCESS) THEN
                  X_errbuf := 'Submission of RCV Upgrade Workers failed -> X_retcode = '||X_retcode;
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;

               l_stmt_num :=30;

               l_sub_reqtab := fnd_concurrent.get_sub_requests(gRequestId);

               for i IN 1..l_sub_reqtab.COUNT() loop
                 fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>  RCV Worker [CSTURCVW] '||RPAD(i,2)||' - '||l_sub_reqtab(i).request_id);
               end loop;

            end if;
         exception
            when no_data_found then
              fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'No Data Found in XUD');
         end;
      else
         X_errbuf := 'Cannot get schema name for product : '||l_product;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      --update migration_status_code and je_from_sla_flag

    else
      fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Checking Status Of Child Workers....');
      --
      -- restart case
      --
      l_stmt_num :=40;
      l_sub_reqtab := fnd_concurrent.get_sub_requests(gRequestId);

      x_retcode := FND_API.G_RET_STS_SUCCESS;
      for i IN 1..l_sub_reqtab.COUNT()
      loop
         if (l_sub_reqtab(i).dev_status <> 'NORMAL') then
            fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>Concurrent Request: '||l_sub_reqtab(i).request_id||' -> Status: '||l_sub_reqtab(i).dev_status);
            X_retcode := FND_API.g_ret_sts_unexp_error;
         end if;
      end loop;

      if (X_retcode = FND_API.G_RET_STS_SUCCESS) then
         fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>All Child Workers are Successfull');
      else
         X_errbuf := 'One or More of Child Workers completed in Error';
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      commit;
    end if;

    <<out_arg_log>>

    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.end',
        'Exiting CST_SLA_UPDATE_PKG.Update_Proc_RCV_MGR with '||
        'X_errbuf = '||X_errbuf||','||
        'X_retcode = '||X_retcode
        );
    END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

END Update_Proc_RCV_MGR;


-------------------------------------------------------------------------------------
--  API name   : Update_Proc_INV_WKR
--  Type       : Private
--  Function   : Worker process to update Inventory Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters : X_Argument4 is used to pass minimum ID;
--               X_Argument5 is used to pass maximum ID.
--  IN         :       X_batch_size     in  number,
--                     X_Worker_Id      in  number,
--                     X_Num_Workers    in  number,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Inventory Subledger to SLA"
--               worker Concurrent Executable and Concurrent Program.  It is called
--               from Update_Proc_INV_MGR by submitting multiple requests
--               via AD_CONC_UTILS_PKG.submit_subrequests. It is also used by the
--               downtime upgrade script cstmtaupg.sql.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_INV_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null)
IS

    l_table_name  varchar2(30) := 'MTL_MATERIAL_TRANSACTIONS';
    l_id_column   varchar2(30) := 'TRANSACTION_ID';

    l_update_name varchar2(30);

    l_table_owner varchar2(30);
    l_status      VARCHAR2(30);
    l_industry    VARCHAR2(30);
    l_retstatus   BOOLEAN;
    l_any_rows_to_process  boolean;

    l_start_id        number;
    l_end_id          number;
    l_rows_processed  number;

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Proc_INV_WKR';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND gRequestId > 0;

    l_stmt_num     number;

BEGIN

    IF l_Log THEN
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
    ELSE
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
    END IF;

  l_stmt_num :=0;

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.begin',
      'Entering CST_SLA_UPDATE_PKG.Update_Proc_INV_WKR with '||
      'X_batch_size = '||X_batch_size||','||
      'X_Worker_Id = '||X_Worker_Id||','||
      'X_Num_Workers = '||X_Num_Workers||','||
      'X_Argument4 = '||X_Argument4||','||
      'X_Argument5 = '||X_Argument5||','||
      'X_Argument6 = '||X_Argument6||','||
      'X_Argument7 = '||X_Argument7||','||
      'X_Argument8 = '||X_Argument8||','||
      'X_Argument9 = '||X_Argument9||','||
      'X_Argument10 = '||X_Argument10
      );
  END IF;

  --
  -- The following could be coded to use EXECUTE IMMEDIATE in order to remove build
  -- time
  -- dependencies as the processing could potentially reference some tables that
  -- could be obsoleted in the current release
  --
  BEGIN
       l_stmt_num :=10;

       l_update_name := X_Argument6 || 'I' || X_Argument4 || '-' ||  X_Argument5;

       l_retstatus := FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_table_owner);

        ad_parallel_updates_pkg.initialize_id_range(
                 X_update_type=>ad_parallel_updates_pkg.ID_RANGE,
                 X_owner=>l_table_owner,
                 X_table=>l_table_name,
                 X_script=>l_update_name,
                 X_ID_column=>l_id_column,
                 X_worker_id=>X_Worker_Id,
                 X_num_workers=>X_num_workers,
                 X_batch_size=>X_batch_size,
                 X_debug_level=>0);

        l_stmt_num :=20;
        ad_parallel_updates_pkg.get_id_range(
                 l_start_id,
                 l_end_id,
                 l_any_rows_to_process,
                 X_batch_size,
                 TRUE);

        IF NOT l_any_rows_to_process AND l_Log THEN
           log_message(
             fnd_log.level_procedure,
             l_module||'.'||l_stmt_num,
             'No Rows to Process in INV'
             );
        END IF;

        l_stmt_num :=25;
        while (l_any_rows_to_process = TRUE)
        loop
           --
           -- Code CST SLA update logic here
           --
           IF l_Log THEN
             log_message(
               fnd_log.level_procedure,
               l_module||'.'||l_stmt_num,
               'Processing INV Rows From '||l_start_id||' To '||l_end_id
               );
           END IF;

           l_stmt_num :=30;
           CST_SLA_UPDATE_PKG.Update_Inventory_Subledger(
                  X_errbuf=>X_errbuf,
                  X_retcode=>X_retcode,
                  X_min_id=>l_start_id,
                  X_max_id=>l_end_id);

           if (X_retcode <> FND_API.G_RET_STS_SUCCESS) then
                X_errbuf := 'Failure while updating INV Subledger';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

           /*l_rows_processed := SQL%ROWCOUNT;*/
           l_rows_processed := l_end_id - l_start_id + 1;

           l_stmt_num :=40;
           ad_parallel_updates_pkg.processed_id_range(
               l_rows_processed,
               l_end_id);

           COMMIT;

           l_stmt_num :=50;
           ad_parallel_updates_pkg.get_id_range(
              l_start_id,
              l_end_id,
              l_any_rows_to_process,
              X_batch_size,
              FALSE);

        end loop;

        X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

  EXCEPTION
       WHEN OTHERS THEN
         X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
         raise;
  END;

  <<out_arg_log>>

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.end',
      'Exiting CST_SLA_UPDATE_PKG.Update_Proc_INV_WKR with '||
      'X_errbuf = '||X_errbuf||','||
      'X_retcode = '||X_retcode
      );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

END Update_Proc_INV_WKR;

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_WIP_WKR
--  Type       : Private
--  Function   : Worker process to update WIP Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters : X_Argument4 is used to pass minimum ID;
--               X_Argument5 is used to pass maximum ID.
--  IN         :       X_batch_size     in  number,
--                     X_Worker_Id      in  number,
--                     X_Num_Workers    in  number,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade WIP Subledger to SLA"
--               worker Concurrent Executable and Concurrent Program.  It is called
--               from Update_Proc_WIP_MGR by submitting multiple requests
--               via AD_CONC_UTILS_PKG.submit_subrequests. It is also used by the
--               downtime upgrade script cstwtaupg.sql.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_WIP_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null)
IS

    l_product     varchar2(30);
    l_table_name  varchar2(30) := 'WIP_TRANSACTIONS';
    l_id_column   varchar2(30) := 'TRANSACTION_ID';

    l_update_name varchar2(30);

    l_table_owner varchar2(30);
    l_status      VARCHAR2(30);
    l_industry    VARCHAR2(30);
    l_retstatus   BOOLEAN;
    l_any_rows_to_process  boolean;

    l_start_id        number;
    l_end_id          number;
    l_rows_processed  number;

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Proc_WIP_WKR';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND gRequestId > 0;

    l_stmt_num     number;

BEGIN

    IF l_Log THEN
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
    ELSE
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
    END IF;

  l_stmt_num   :=0;

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.begin',
      'Entering CST_SLA_UPDATE_PKG.Update_Proc_WIP_WKR with '||
      'X_batch_size = '||X_batch_size||','||
      'X_Worker_Id = '||X_Worker_Id||','||
      'X_Num_Workers = '||X_Num_Workers||','||
      'X_Argument4 = '||X_Argument4||','||
      'X_Argument5 = '||X_Argument5||','||
      'X_Argument6 = '||X_Argument6||','||
      'X_Argument7 = '||X_Argument7||','||
      'X_Argument8 = '||X_Argument8||','||
      'X_Argument9 = '||X_Argument9||','||
      'X_Argument10 = '||X_Argument10
      );
  END IF;

  --
  -- The following could be coded to use EXECUTE IMMEDIATE in order to remove build
  -- time
  -- dependencies as the processing could potentially reference some tables that
  -- could be obsoleted in the current release
  --
  BEGIN
       l_stmt_num :=10;

       l_update_name := X_Argument6 || 'W' || X_Argument4 || '-' ||  X_Argument5;

       l_retstatus := FND_INSTALLATION.GET_APP_INFO('WIP', l_status, l_industry, l_table_owner);

       ad_parallel_updates_pkg.initialize_id_range(
                 X_update_type=>ad_parallel_updates_pkg.ID_RANGE,
                 X_owner=>l_table_owner,
                 X_table=>l_table_name,
                 X_script=>l_update_name,
                 X_ID_column=>l_id_column,
                 X_worker_id=>X_Worker_Id,
                 X_num_workers=>X_num_workers,
                 X_batch_size=>X_batch_size,
                 X_debug_level=>0);

        l_stmt_num :=20;
        ad_parallel_updates_pkg.get_id_range(
                 l_start_id,
                 l_end_id,
                 l_any_rows_to_process,
                 X_batch_size,
                 TRUE);

        l_stmt_num :=25;
        IF NOT l_any_rows_to_process AND l_Log THEN
           log_message(
             fnd_log.level_procedure,
             l_module||'.'||l_stmt_num,
             'No Rows to Process in WIP'
             );
        END IF;

        while (l_any_rows_to_process = TRUE)
        loop
           --
           -- Code CST SLA update logic here
           --
           IF l_Log THEN
             log_message(
               fnd_log.level_procedure,
               l_module||'.'||l_stmt_num,
               'Processing WIP Rows From '||l_start_id||' To '||l_end_id
               );
           END IF;

           l_stmt_num :=30;
           CST_SLA_UPDATE_PKG.Update_WIP_Subledger(
                  X_errbuf=>X_errbuf,
                  X_retcode=>X_retcode,
                  X_min_id=>l_start_id,
                  X_max_id=>l_end_id);

           if (X_retcode <>FND_API.G_RET_STS_SUCCESS) then
                X_errbuf := 'Failure while updating WIP Subledger';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
           end if;

           /*l_rows_processed := SQL%ROWCOUNT;*/
           l_rows_processed := l_end_id - l_start_id + 1;

           l_stmt_num :=40;
           ad_parallel_updates_pkg.processed_id_range(
               l_rows_processed,
               l_end_id);

           COMMIT;

           l_stmt_num :=50;
           ad_parallel_updates_pkg.get_id_range(
              l_start_id,
              l_end_id,
              l_any_rows_to_process,
              X_batch_size,
              FALSE);

        end loop;
        X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

  EXCEPTION
       WHEN OTHERS THEN
         X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
         raise;
  END;

  <<out_arg_log>>

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.end',
      'Exiting CST_SLA_UPDATE_PKG.Update_Proc_WIP_WKR with '||
      'X_errbuf = '||X_errbuf||','||
      'X_retcode = '||X_retcode
      );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

END Update_Proc_WIP_WKR;

-------------------------------------------------------------------------------------
--  API name   : Update_Proc_RCV_WKR
--  Type       : Private
--  Function   : Worker process to update RCV Sub Ledger to SLA data model
--  Pre-reqs   :
--  Parameters : X_Argument4 is used to pass minimum ID;
--               X_Argument5 is used to pass maximum ID.
--  IN         :       X_batch_size     in  number,
--                     X_Worker_Id      in  number,
--                     X_Num_Workers    in  number,
--                     X_Argument4      in  varchar2 default null,
--                     X_Argument5      in  varchar2 default null,
--                     X_Argument6      in  varchar2 default null,
--                     X_Argument7      in  varchar2 default null,
--                     X_Argument8      in  varchar2 default null,
--                     X_Argument9      in  varchar2 default null,
--                     X_Argument10     in  varchar2 default null
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--  Version    : Initial version       1.0
--  Notes      : The API is used for defining the "Upgrade Receiving Subledger to SLA"
--               worker Concurrent Executable and Concurrent Program.  It is called
--               from Update_Proc_RCV_MGR by submitting multiple requests
--               via AD_CONC_UTILS_PKG.submit_subrequests. It is also used by the
--               downtime upgrade script cstrrsupg.sql.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Proc_RCV_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null)
IS

    l_product     varchar2(30);
    l_table_name  varchar2(30) := 'RCV_TRANSACTIONS';
    l_id_column   varchar2(30) := 'TRANSACTION_ID';


    l_update_name varchar2(30);

    l_table_owner varchar2(30);
    l_status      VARCHAR2(30);
    l_industry    VARCHAR2(30);
    l_retstatus   BOOLEAN;
    l_any_rows_to_process  boolean;

    l_start_id        number;
    l_end_id          number;
    l_rows_processed  number;

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Proc_RCV_WKR';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND gRequestId > 0;

    l_stmt_num     number;
    l_mrc_temp     number;

BEGIN

    IF l_Log THEN
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled TRUE');
    ELSE
       fnd_file.put_line(fnd_file.log, TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')||'>FND Logging Enabled FALSE');
    END IF;

  l_stmt_num   :=0;

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.begin',
      'Entering CST_SLA_UPDATE_PKG.Update_Proc_RCV_WKR with '||
      'X_batch_size = '||X_batch_size||','||
      'X_Worker_Id = '||X_Worker_Id||','||
      'X_Num_Workers = '||X_Num_Workers||','||
      'X_Argument4 = '||X_Argument4||','||
      'X_Argument5 = '||X_Argument5||','||
      'X_Argument6 = '||X_Argument6||','||
      'X_Argument7 = '||X_Argument7||','||
      'X_Argument8 = '||X_Argument8||','||
      'X_Argument9 = '||X_Argument9||','||
      'X_Argument10 = '||X_Argument10
      );
  END IF;

  begin
    l_mrc_temp :=0;

    select count(*)
    into l_mrc_temp
    from gl_mc_reporting_options_11i
    where application_id = 201
    and enabled_flag = 'Y'
    and rownum=1;

    if (l_mrc_temp = 0) then
      g_mrc_enabled := FALSE;
    else
      g_mrc_enabled := TRUE;
    end if;

  exception
    when others then
      g_mrc_enabled := FALSE;
  end;

  --
  -- The following could be coded to use EXECUTE IMMEDIATE in order to remove build
  -- time
  -- dependencies as the processing could potentially reference some tables that
  -- could be obsoleted in the current release
  --
  BEGIN
       l_stmt_num :=10;

       l_update_name := X_Argument6 || 'R' || X_Argument4 || '-' ||  X_Argument5;

       l_retstatus := FND_INSTALLATION.GET_APP_INFO('PO', l_status, l_industry, l_table_owner);

       ad_parallel_updates_pkg.initialize_id_range(
                 X_update_type=>ad_parallel_updates_pkg.ID_RANGE,
                 X_owner=>l_table_owner,
                 X_table=>l_table_name,
                 X_script=>l_update_name,
                 X_ID_column=>l_id_column,
                 X_worker_id=>X_Worker_Id,
                 X_num_workers=>X_num_workers,
                 X_batch_size=>X_batch_size,
                 X_debug_level=>0);

        l_stmt_num :=20;
        ad_parallel_updates_pkg.get_id_range(
                 l_start_id,
                 l_end_id,
                 l_any_rows_to_process,
                 X_batch_size,
                 TRUE);

        l_stmt_num :=25;
        IF NOT l_any_rows_to_process AND l_Log THEN
           log_message(
             fnd_log.level_procedure,
             l_module||'.'||l_stmt_num,
             'No Rows to Process in RCV'
             );
        END IF;

        while (l_any_rows_to_process = TRUE)
        loop
           --
           -- Code CST SLA update logic here
           --
           IF l_Log THEN
             log_message(
               fnd_log.level_procedure,
               l_module||'.'||l_stmt_num,
               'Processing RCV Rows From '||l_start_id||' To '||l_end_id
               );
           END IF;

           l_stmt_num :=30;
           CST_SLA_UPDATE_PKG.Update_Receiving_Subledger(
                  X_errbuf=>X_errbuf,
                  X_retcode=>X_retcode,
                  X_min_id=>l_start_id,
                  X_max_id=>l_end_id);

           if (X_retcode <>FND_API.G_RET_STS_SUCCESS) then
                X_errbuf := 'Failure while updating RCV Subledger';
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

           /*l_rows_processed := SQL%ROWCOUNT;*/
           l_rows_processed := l_end_id - l_start_id + 1;

           l_stmt_num :=40;
           ad_parallel_updates_pkg.processed_id_range(
               l_rows_processed,
               l_end_id);

           COMMIT;

           l_stmt_num :=50;
           ad_parallel_updates_pkg.get_id_range(
              l_start_id,
              l_end_id,
              l_any_rows_to_process,
              X_batch_size,
              FALSE);

        end loop;
        X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

  EXCEPTION
       WHEN OTHERS THEN
         X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
         raise;
  END;

  <<out_arg_log>>

  IF l_Log THEN
    log_message(
      fnd_log.level_procedure,
      l_module||'.end',
      'Exiting CST_SLA_UPDATE_PKG.Update_Proc_RCV_WKR with '||
      'X_errbuf = '||X_errbuf||','||
      'X_retcode = '||X_retcode
      );
  END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => TRUE,
              X_errbuf   => X_errbuf );

END Update_Proc_RCV_WKR;

-------------------------------------------------------------------------------------
--  API name   : Update_Inventory_Subledger
--  Type       : Private
--  Function   : To update Inventory Sub Ledger to SLA data model from minimum
--               transaction ID to maximum transaction ID.
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_min_id     in  number,
--                     X_max_id     in  number
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from Update_Proc_INV_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Inventory_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_min_id  in number,
               X_max_id  in number)
IS
    l_upg_batch_id     number(15):=0;
    l_je_category_name varchar2(30);

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Inventory_Subledger';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND gRequestId > 0;

    l_stmt_num        number;
    l_rows_processed  number;

BEGIN

   l_stmt_num   :=0;

   IF l_Log THEN
     log_message(
       fnd_log.level_procedure,
       l_module||'.begin',
       'Entering CST_SLA_UPDATE_PKG.Update_Inventory_Subledger with '||
       'X_min_id = '||X_min_id||','||
       'X_max_id = '||X_max_id
     );
   END IF;

   select XLA_UPG_BATCHES_S.nextval into l_upg_batch_id from dual;

   IF l_Log THEN
     log_message(
       fnd_log.level_procedure,
       l_module||'.'||l_stmt_num,
       'Upgrade Batch ID = '||l_upg_batch_id
     );
   END IF;

   l_je_category_name := 'MTL';

   /*execute immediate 'CREATE GLOBAL TEMPORARY TABLE cst_xla_seq_gt(
                      source_id_int_1 NUMBER,
                      source_id_int_2 number,
                      source_id_int_3 number,
                      source_id_int_4 number,
                      source_id_int_5 number,
                      entity_id number,
                      event_id number,
                      header_id NUMBER,
                      legal_entity number,
                      org_id number) ON COMMIT DELETE ROWS';*/

   x_retcode := FND_API.G_RET_STS_SUCCESS;

   /* one (txn_id,org_id,txn_src_type_id) -> one entity_id -> one event_id -> one header_id */
   /* one mta line -> one xla_ae_line -> one xla_distribution_link */

   l_stmt_num   :=10;

   insert into cst_xla_seq_gt (
                  source_id_int_1,
                  source_id_int_2,
                  source_id_int_3,
                  entity_id,
                  event_id,
                  header_id)
   select transaction_id,
          organization_id,
          transaction_source_type_id,
          xla_transaction_entities_s.nextval,
          xla_events_s.nextval,
          xla_ae_headers_s.nextval
   from  (
          select /*+ leading(mmt,oap) use_hash(xud, oap) swap_join_inputs(oap) index(mmt, mtl_material_transactions_u1) */
                 distinct
                 mta.transaction_id, mta.organization_id, mta.transaction_source_type_id
            from mtl_transaction_accounts mta,
                 xla_upgrade_dates xud,
                 hr_organization_information hoi2,
                 org_acct_periods oap,
                 mtl_material_transactions mmt
           where mmt.transaction_id >= X_min_id
             and mmt.transaction_id <= X_max_id
             and mmt.acct_period_id = oap.acct_period_id
             and mmt.organization_id = oap.organization_id
             and oap.period_start_date >= xud.start_date
             and oap.schedule_close_date <= xud.end_date
             and hoi2.organization_id = oap.organization_id
             and hoi2.org_information_context = 'Accounting Information'
             and hoi2.org_information1 = to_char (xud.ledger_id)
             and mmt.transaction_action_id not in (15, 22, 36)
             and mta.transaction_id = mmt.transaction_id
             and mta.encumbrance_type_id is null
             and mta.inv_sub_ledger_id is null
             and (mta.gl_batch_id > 0
              or mta.gl_batch_id = -1
             and not exists (
                 select null
                   from pjm_org_parameters pop
                  where pop.organization_id = mta.organization_id
                    and pop.pa_posting_flag = 'Y'
                    and exists (
                        select 1
                         from mtl_material_transactions mmt1
                        where mmt1.transaction_id = mta.transaction_id
                          and (nvl(mmt1.logical_transaction, 2) = 2
                           or mmt1.logical_transaction = 1
                          and mmt1.transaction_type_id = 19
                          and mmt1.transaction_action_id = 26
                          and mmt1.transaction_source_type_id = 1
                          and mmt1.logical_trx_type_code = 2
                          and exists (
                              select 1
                                from rcv_transactions rt
                               where rt.transaction_id = mmt1.rcv_transaction_id
                                 and rt.organization_id = mta.organization_id))))));

   l_rows_processed := SQL%ROWCOUNT;
   IF (l_rows_processed = 0) THEN
      IF l_Log THEN
        log_message(
         fnd_log.level_procedure,
         l_module||'.'||l_stmt_num,
         'No rows to be upgraded. Exiting CST_SLA_UPDATE_PKG.Update_Inventory_Subledger with '||
         'X_errbuf = '||X_errbuf||','||
         'X_retcode = '||X_retcode
         );
      END IF;
      return;
   END IF;

   l_stmt_num   :=20;

   update mtl_transaction_accounts mta
   set inv_sub_ledger_id = cst_inv_sub_ledger_id_s.nextval,
       last_update_date = gUpdateDate,
       last_updated_by = gUserId,
       last_update_login = gLoginId
   where (mta.transaction_id, mta.organization_id, mta.transaction_source_type_id) in
         (select /*+ unnest */
                 source_id_int_1,
                 source_id_int_2,
                 source_id_int_3
          from cst_xla_seq_gt cxs)
          and mta.encumbrance_type_id is null;

   l_stmt_num   :=30;

   insert all
     when (line_id=1) then
     into xla_transaction_entities (
            upg_batch_id,
            entity_id,
            application_id,
            ledger_id,
            entity_code,
            source_id_int_1,
            source_id_int_2,
            source_id_int_3,
            security_id_int_1,
            transaction_number,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            source_application_id,
            upg_source_application_id)
     values (l_upg_batch_id,
            entity_id,
            707,
            ledger_id,
            'MTL_ACCOUNTING_EVENTS',
            transaction_id,
            organization_id,
            transaction_source_type_id,
            organization_id,
            transaction_id,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            401,
            401)
     into xla_events (
            upg_batch_id,
            application_id,
            entity_id,
            event_id,
            event_number,
            event_type_code,
            event_date,
            event_status_code,
            process_status_code,
            on_hold_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_application_id,
            program_id,
            request_id,
            transaction_date,
            upg_source_application_id)
     values (l_upg_batch_id,
            707,
            entity_id,
            event_id,
            1,
            event_type_code,
            transaction_date,
            'P',
            'P',
            'N',
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_application_id,
            program_id,
            request_id,
            transaction_date,
            401)
     into xla_ae_headers (
            upg_batch_id,
            application_id,
            amb_context_code,
            entity_id,
            event_id,
            event_type_code,
            ae_header_id,
            ledger_id,
            je_category_name,
            accounting_date,
            period_name,
            balance_type_code,
            gl_transfer_status_code,
            gl_transfer_date,
            accounting_entry_status_code,
            accounting_entry_type_code,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_application_id,
            program_id,
            request_id,
            zero_amount_flag,
            upg_source_application_id)
     values (l_upg_batch_id,
            707,
            'DEFAULT',
            entity_id,
            event_id,
            event_type_code,
            header_id,
            ledger_id,
            l_je_category_name,
            gl_date,
            period_name,
            'A',
            gl_transfer_status_code,
            gl_transfer_date,
            'F',
            'STANDARD',
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_application_id,
            program_id,
            request_id,
            zero_amount_flag,
            401)
    when (1=1) then
     into xla_ae_lines (
            upg_batch_id,
            application_id,
            ae_header_id,
            ae_line_num,
            code_combination_id,
            gl_transfer_mode_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            accounting_class_code,
            gl_sl_link_id,
            gl_sl_link_table,
            ussgl_transaction_code,
            control_balance_flag,
            gain_or_loss_flag,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_application_id,
            program_id,
            request_id,
            accounting_date,
            ledger_id)
     values (l_upg_batch_id,
            707,
            header_id,
            line_id,
            ref_account,
            gl_update_code,
            accounted_dr,
            accounted_cr,
            currency_code,
            currency_conversion_date,
            currency_conversion_rate,
            currency_conversion_type,
            entered_dr,
            entered_cr,
            accounting_class_code,
            link_id,
            'MTA',
            ussgl_transaction_code,
            control_balance_flag,
            'N',
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_update_date,
            program_application_id,
            program_id,
            request_id,
            gl_date,
            ledger_id)
     into xla_distribution_links (
            upg_batch_id,
            application_id,
            event_id,
            ae_header_id,
            ae_line_num,
            accounting_line_code,
            accounting_line_type_code,
            source_distribution_type,
            source_distribution_id_num_1,
            merge_duplicate_code,
            ref_ae_header_id,
            temp_line_num,
            event_class_code,
            event_type_code)
     values (l_upg_batch_id,
            707,
            event_id,
            header_id,
            line_id,
            accounting_class_code,
            'C',
            'MTL_TRANSACTION_ACCOUNTS',
            src_dist_id_num_1,
            'N',
            header_id,
            line_id,
            event_class_code,
            event_type_code)

   select /*+ leading(txn) use_hash(cem) swap_join_inputs(cem) */
          row_number () over (partition by txn.transaction_id, txn.organization_id, txn.transaction_source_type_id
                             order by txn.transaction_id) as line_id,
          txn.creation_date,
          txn.last_update_date,
          txn.created_by,
          txn.last_updated_by,
          txn.last_update_login,
          txn.program_update_date,
          txn.program_application_id,
          txn.program_id,
          txn.request_id,
          txn.entity_id,
          txn.event_id,
          txn.header_id,
          txn.transaction_id,
          txn.organization_id,
          txn.transaction_source_type_id,
          txn.transaction_date,
          txn.gl_date,
          txn.gl_transfer_date,
          txn.ledger_id,
          txn.period_name,
          txn.gl_transfer_status_code,
          txn.currency_code,
          txn.ref_account,
          txn.gl_update_code,
          txn.link_id,
          txn.src_dist_id_num_1,
          txn.accounted_dr,
          txn.accounted_cr,
          txn.currency_conversion_date,
          txn.currency_conversion_rate,
          txn.currency_conversion_type,
          txn.entered_dr,
          txn.entered_cr,
          txn.entered_amount,
          decode (txn.btvsign, 0, 'Y', 'N') zero_amount_flag,
          txn.ussgl_transaction_code,
          txn.control_balance_flag,
          cem.event_type_code,
          cem.event_class_code,
          decode(txn.accounting_line_type,
                 1, 'INVENTORY_VALUATION',
                 2, decode(cem.event_class_code,
                          'FOB_RCPT_SENDER_RCPT',      decode(txn.btvsign, 1, 'COST_OF_GOODS_SOLD', 'OFFSET'),
                          'FOB_SHIP_SENDER_SHIP',      decode(txn.btvsign, 1, 'COST_OF_GOODS_SOLD', 'OFFSET'),
                          'SALES_ORDER',               'COST_OF_GOODS_SOLD',
                          'MTL_COST_UPD',              'COST_UPDATE_ADJUSTMENT',
                          'WIP_COST_UPD',              'COST_UPDATE_ADJUSTMENT',
                          'LOG_INTERCOMPANY',          decode(txn.transaction_action_id,
                                                             9, decode(txn.btvsign, 1, 'INTERCOMPANY_COGS', 'OFFSET'),
                                                             decode(txn.btvsign, -1, 'INTERCOMPANY_COGS', 'OFFSET')),
                          'FOB_RCPT_RECIPIENT_RCPT',   decode(txn.btvsign, -1, 'INTERCOMPANY_ACCRUAL', 'OFFSET'),
                          'FOB_SHIP_RECIPIENT_SHIP',   decode(txn.btvsign, -1, 'INTERCOMPANY_ACCRUAL', 'OFFSET'),
                          'OFFSET'),
                 3, decode(cem.event_class_code,
                          'ABSORPTION',               'OVERHEAD_ABSORPTION',
                          'OSP',                      'OVERHEAD_ABSORPTION',
                          'MATERIAL_OVERHEAD_ABSORPTION'),
                 4, 'RESOURCE_ABSORPTION',
                 5, 'RECEIVING_INSPECTION',
                 6, decode(cem.event_class_code,
                          'ABSORPTION',               'RESOURCE_RATE_VARIANCE',
                          'PURCHASE_PRICE_VARIANCE'),
                 7, 'WIP_VALUATION',
                 8, 'WIP_VARIANCE',
                 9, 'INTERORG_PAYABLES',
                 10, 'INTERORG_RECEIVABLES',
                 11, 'INTERORG_TRANSFER_CREDIT',
                 12, 'INTERORG_FREIGHT_CHARGE',
                 13, 'COST_VARIANCE',
                 14, 'INTRANSIT_VALUATION',
                 15, 'ENCUMBRANCE_REVERSAL',
                 16, decode(cem.event_class_code,
                           'LOG_INTERCOMPANY',          'INTERCOMPANY_ACCRUAL',
                           'ACCRUAL'),
                 17, 'INVOICE_PRICE_VARIANCE',
                 18, 'EXCHANGE_RATE_VARIANCE',
                 19, 'SPECIAL_CHARGE_EXPENSE',
                 20, 'EXPENSE',
                 21, 'WIP_VALUATION',
                 22, 'WIP_VALUATION',
                 23, 'WIP_VALUATION',
                 24, 'WIP_VALUATION',
                 25, 'WIP_VALUATION',
                 26, 'WIP_VALUATION',
                 27, 'WIP_VALUATION',
                 28, 'WIP_VALUATION',
                 29, 'ESTIMATED_SCRAP_ABSORPTION',
                 30, 'PROFIT_IN_INVENTORY',
                 31, 'CLEARING',
                 32, 'RETROACTIVE_PRICE_ADJUSTMENT',
                 33, 'SHIKYU_VARIANCE',
                 34, 'INTERORG_PROFIT',
                 35, 'COST_OF_GOODS_SOLD',
                 36, 'DEFERRED_COGS',
                 37, 'COST_UPDATE_ADJUSTMENT',
                 'OFFSET') accounting_class_code
   from  cst_xla_inv_event_map cem,
        (select /*+ no_merge leading(cxs, mmt) use_hash(oap) swap_join_inputs(oap)
                use_nl_with_index(mmt) use_nl_with_index(mta) use_nl_with_index(hoi2) use_nl_with_index(gcc) */
                mta.creation_date,
                mta.last_update_date,
                mta.created_by,
                mta.last_updated_by,
                mta.last_update_login,
                mta.program_update_date,
                mta.program_application_id,
                mta.program_id,
                mta.request_id,
                cxs.entity_id,
                cxs.event_id,
                cxs.header_id,
                mta.transaction_id,
                mta.organization_id,
                mta.transaction_source_type_id,
                mmt.transaction_date,
                mmt.primary_quantity,
                nvl(ogb.gl_batch_date,
                    trunc(inv_le_timezone_pub.get_le_day_for_server(mmt.transaction_date, hoi2.org_information2))) gl_date,
                ogb.gl_batch_date gl_transfer_date,
                sob.ledger_id,
                period_name,
                decode(mta.gl_batch_id,
                      -1, decode (mp.general_ledger_update_code, 3, 'NT', 'N'),
                      decode (sign (mta.gl_batch_id), 1, 'Y', 'NT')) gl_transfer_status_code,
                decode(nvl(mta.encumbrance_type_id, -1),
                      -1, nvl(mta.currency_code, sob.currency_code),
                      sob.currency_code) currency_code,
                mta.reference_account ref_account,
                decode(mp.general_ledger_update_code,
                       1, 'D',
                       2, 'S',
                       'N') gl_update_code,
                mta.gl_sl_link_id link_id,
                mta.inv_sub_ledger_id src_dist_id_num_1,
                decode(sign(mta.base_transaction_value),
                       0, decode(sign(nvl(mta.transaction_value, mta.primary_quantity)),
                                0, 0,
                                1, 0,
                                null),
                       1, mta.base_transaction_value,
                       null) accounted_dr,
                decode(sign(mta.base_transaction_value),
                       0, decode(sign(nvl(mta.transaction_value, mta.primary_quantity)),
                                -1, 0,
                                null),
                       -1, (-1 * mta.base_transaction_value),
                       null) accounted_cr,
                mta.currency_conversion_date,
                mta.currency_conversion_rate,
                mta.currency_conversion_type,
                decode(nvl(mta.encumbrance_type_id, -1),
                       -1, decode(sign(mta.base_transaction_value),
                                  0, decode(sign(nvl(mta.transaction_value, mta.primary_quantity)),
                                            0, 0,
                                            1, nvl(mta.transaction_value, 0),
                                            null),
                                  1, nvl(mta.transaction_value, mta.base_transaction_value),
                                  null),
                        decode(sign(mta.base_transaction_value),
                               0, 0, 1, mta.base_transaction_value, null)) entered_dr,
                decode(nvl(mta.encumbrance_type_id, -1),
                       -1, decode(sign(mta.base_transaction_value),
                                  0, decode(sign(nvl(mta.transaction_value, mta.primary_quantity)),
                                            -1, -1 * nvl(mta.transaction_value, 0),
                                            null),
                                 -1, (-1 * nvl(mta.transaction_value, mta.base_transaction_value)),
                                 null),
                        decode(sign(mta.base_transaction_value),
                        -1, (-1 * mta.base_transaction_value), null)) entered_cr,
                nvl (mta.transaction_value, mta.base_transaction_value) entered_amount,
                mta.ussgl_transaction_code,
                decode (gcc.reference3, 'Y', 'P', null) control_balance_flag,
                mta.accounting_line_type,
                mmt.transaction_action_id,
                mmt.source_code,
                mmt.organization_id mmt_organization_id,
                mmt.transaction_source_type_id mmt_transaction_source_type_id,
                sign(mta.base_transaction_value) btvsign,
                case when mmt.transaction_action_id in (12, 21) then (
                        select  1
                        from    mtl_transaction_accounts mta1
                        where   mta1.accounting_line_type in (9,10)
                        and     mta1.transaction_id = mta.transaction_id
                        and     mta1.organization_id = mta.organization_id
                        and     mta1.transaction_source_type_id = mta.transaction_source_type_id
                        and     rownum = 1)
                else null
                end exists_9_10,
                case when mmt.transaction_action_id in (12, 21) then (
                        select  1
                        from    mtl_transaction_accounts mta1
                        where   mta1.accounting_line_type = 14
                        and     mta1.transaction_id = mta.transaction_id
                        and     mta1.organization_id = mta.organization_id
                        and     mta1.transaction_source_type_id = mta.transaction_source_type_id
                        and     rownum = 1)
                else null
                end exists_14
         from   mtl_transaction_accounts mta,
                mtl_material_transactions mmt,
                gl_code_combinations gcc,
                mtl_parameters mp,
                hr_organization_information hoi2,
                gl_ledgers sob,
                org_acct_periods oap,
                org_gl_batches ogb,
                cst_xla_seq_gt cxs
        where   mta.transaction_id = cxs.source_id_int_1
          and   mta.organization_id = cxs.source_id_int_2
          and   nvl(mta.transaction_source_type_id, -1) = nvl(cxs.source_id_int_3, -1)
          and   mta.encumbrance_type_id is null
          and   mp.organization_id = hoi2.organization_id
          and   mta.organization_id = mp.organization_id
          and   mta.organization_id = ogb.organization_id (+)
          and   mta.gl_batch_id = ogb.gl_batch_id (+)
          and   mmt.transaction_id = cxs.source_id_int_1
          and   gcc.code_combination_id = mta.reference_account
          and   oap.organization_id = mmt.organization_id
          and   mmt.acct_period_id = oap.acct_period_id
          and   hoi2.org_information_context = 'Accounting Information'
          and   sob.ledger_ID = TO_NUMBER(DECODE(RTRIM(TRANSLATE(HOI2.ORG_INFORMATION1,'0123456789',' ')),
                                               NULL, HOI2.ORG_INFORMATION1,
                                               -99999))
          and   sob.object_type_code = 'L')
         txn
   where txn.transaction_action_id = cem.transaction_action_id
    and  (cem.transaction_source_type_id = txn.transaction_source_type_id
            and (txn.transaction_action_id not in (1, 2, 3, 12, 21, 24, 17)
              or txn.transaction_action_id = 1
                    and (txn.transaction_source_type_id <> 13
                    or  cem.attribute = 'CITW' and txn.mmt_transaction_source_type_id = 5
                    or  cem.attribute is null  and txn.mmt_transaction_source_type_id = 13)
                    and (txn.transaction_source_type_id <> 8 or cem.tp = 'N')
              or txn.transaction_action_id = 2
                    and txn.transaction_source_type_id in (4, 8, 9, 10, 13)
              or txn.transaction_action_id = 3
                    and txn.transaction_source_type_id  = 8
                    and cem.organization = 'SAME'
                    and cem.tp = 'N'
                    and txn.organization_id = txn.mmt_organization_id
              or txn.transaction_action_id = 3
                    and txn.transaction_source_type_id  = 13
                    and cem.organization = 'SAME'
                    and cem.tp = 'N'
                    and txn.organization_id = txn.mmt_organization_id
                    and (txn.primary_quantity < 0 and cem.transfer_type = 'SHIP'
                        or
                        txn.primary_quantity > 0 and cem.transfer_type = 'RCPT')
              or txn.transaction_action_id = 3
                    and txn.transaction_source_type_id in (7, 13)
                    and cem.organization = 'TRANSFER'
                    and cem.tp = 'N'
                    and txn.organization_id <> txn.mmt_organization_id
              /* Added for Direct interorg int req receipt in avg/LIFO/FIFO */
              or txn.transaction_action_id = 3
                    and txn.transaction_source_type_id = 7
                    and cem.organization = 'SAME'
                    and cem.tp = 'N'
                    and txn.organization_id = txn.mmt_organization_id
              or txn.transaction_action_id = 24
                    and txn.transaction_source_type_id = 13
                    and cem.attribute = 'VARIANCE TRF'
                    and txn.source_code is not null
              or txn.transaction_action_id = 24
                    and txn.transaction_source_type_id = 13
                    and cem.attribute is null
                    and txn.source_code is null
              or txn.transaction_action_id = 24
                    and txn.transaction_source_type_id in (11, 15)
              /* FOB_SHIP_RECIPIENT_RCPT */
              or txn.transaction_action_id = 12
                    and txn.transaction_source_type_id in (7, 13)
                    and txn.organization_id = txn.mmt_organization_id
                    and cem.organization = 'SAME'
                    and cem.fob_point = 1
                    and cem.tp is null
                    and txn.exists_14 = 1
             /* FOB_RCPT_RECIPIENT_RCPT */
             or txn.transaction_action_id = 12
                    and txn.transaction_source_type_id in (7, 13)
                    and txn.organization_id = txn.mmt_organization_id
                    and cem.organization = 'SAME'
                    and cem.fob_point = 2
                    and txn.exists_14 is null
                    and (cem.tp = 'Y' and txn.exists_9_10 is null
                        or
                        cem.tp = 'N'  and txn.exists_9_10 = 1)
              /* FOB_RCPT_SENDER_RCPT */
              or txn.transaction_action_id = 12
                    and txn.transaction_source_type_id in (7, 13)
                    and txn.organization_id <> txn.mmt_organization_id
                    and cem.organization = 'TRANSFER'
                    and cem.fob_point = 2
                    and txn.exists_14 = 1
                    and (cem.tp = 'Y' and txn.exists_9_10 is null
                         or
                         cem.tp = 'N' and txn.exists_9_10 = 1)
              /* FOB_RCPT_SENDER_SHIP */
              or txn.transaction_action_id = 21
                    and txn.transaction_source_type_id in (8, 13)
                    and txn.organization_id = txn.mmt_organization_id
                    and cem.organization = 'SAME'
                    and cem.fob_point = 2
                    and cem.tp is null
                    and txn.exists_14 = 1
              /* FOB_SHIP_SENDER_SHIP */
              or txn.transaction_action_id = 21
                    and txn.transaction_source_type_id in (8, 13)
                    and txn.organization_id = txn.mmt_organization_id
                    and cem.organization = 'SAME'
                    and cem.fob_point = 1
                    and txn.exists_14 is null
                    and (cem.tp = 'Y' and txn.exists_9_10 is null
                         or
                         cem.tp = 'N' and txn.exists_9_10 = 1)
              /* FOB_SHIP_RECIPIENT_SHIP */
              or txn.transaction_action_id = 21
                    and txn.transaction_source_type_id in (8, 13)
                    and txn.organization_id <> txn.mmt_organization_id
                    and cem.organization = 'TRANSFER'
                    and cem.fob_point = 1
                    and txn.exists_14 = 1
                    and (cem.tp = 'Y' and txn.exists_9_10 is null
                        or
                        cem.tp = 'N'  and txn.exists_9_10 = 1)
              or txn.transaction_action_id = 17
                    and (txn.transaction_source_type_id <> 7
                        or cem.tp = 'N'))
         or cem.transaction_source_type_id is null
            and
            ( txn.transaction_action_id = 2
                    and txn.transaction_source_type_id not in (4, 8, 9, 10, 13)
              or txn.transaction_action_id = 3
                    and txn.transaction_source_type_id not in (7, 8, 13)
              or txn.transaction_action_id = 24
                    and txn.transaction_source_type_id not in (11, 13, 15)
              /* FOB_SHIP_SENDER_SHIP_ALL */
              or txn.transaction_action_id = 21
                    and txn.transaction_source_type_id not in (8, 13)
                    and txn.organization_id = txn.mmt_organization_id
                    and cem.organization = 'SAME'
                    and cem.fob_point = 1
                    and txn.exists_14 is null
              /* FOB_SHIP_RECIPIENT_SHIP_ALL */
              or txn.transaction_action_id = 21
                    and txn.transaction_source_type_id not in (8, 13)
                    and txn.organization_id <> txn.mmt_organization_id
                    and cem.organization = 'TRANSFER'
                    and cem.fob_point = 1
                    and txn.exists_14 = 1
              /* FOB_RCPT_SENDER_SHIP_ALL */
              or txn.transaction_action_id = 21
                    and txn.transaction_source_type_id not in (8, 13)
                    and txn.organization_id = txn.mmt_organization_id
                    and cem.organization = 'SAME'
                    and cem.fob_point = 2
                    and txn.exists_14 = 1)
                    /* For User Defined Transaction Types for action 1 and 27*/
          or cem.transaction_source_type_id = -999
             and( txn.transaction_action_id in (1,27)
                  and txn.transaction_source_type_id not in
                      ( 1,2,3,4,5,6,7,8,9,10,11,12,13,15,16 )
                 )
             and cem.attribute is null
          /* Added the condition for including transaction_source_type =7
             when creating the event for action =3 and source type = 8
             in the case of std to std. As only shipment transaction
             (action =3 and src_type =8) will be accounted but we need
             to raise event for the shipment transaction with event type
             of receipt( action = 3 and source type = 7) too.
           */
          or cem.transaction_source_type_id = 7
             and txn.transaction_action_id = 3
             and txn.transaction_source_type_id = 8
             and cem.organization = 'TRANSFER'
             and cem.tp = 'N'
             and txn.organization_id <> txn.mmt_organization_id
             );

    <<out_arg_log>>

    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.end',
        'Exiting CST_SLA_UPDATE_PKG.Update_Inventory_Subledger with '||
        'X_errbuf = '||X_errbuf||','||
        'X_retcode = '||X_retcode
      );
    END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

end Update_Inventory_Subledger;

-------------------------------------------------------------------------------------
--  API name   : Update_WIP_Subledger
--  Type       : Private
--  Function   : To update WIP Sub Ledger to SLA data model from minimum
--               transaction ID to maximum transaction ID.
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_min_id     in  number,
--                     X_max_id     in  number
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from Update_Proc_WIP_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Update_WIP_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_min_id  in number,
               X_max_id  in number)
IS
    l_upg_batch_id number(15):=0;
    l_je_category_name varchar2(30);

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_WIP_Subledger';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND gRequestId > 0;

    l_stmt_num      number;
    l_rows_processed number;
BEGIN

   l_stmt_num   :=0;

   IF l_Log THEN
     log_message(
       fnd_log.level_procedure,
       l_module||'.begin',
       'Entering CST_SLA_UPDATE_PKG.Update_WIP_Subledger with '||
       'X_min_id = '||X_min_id||','||
       'X_max_id = '||X_max_id
     );
   END IF;

   select XLA_UPG_BATCHES_S.nextval into l_upg_batch_id from dual;

   IF l_Log THEN
     log_message(
       fnd_log.level_procedure,
       l_module||'.'||l_stmt_num,
       'Upgrade Batch ID = '||l_upg_batch_id
     );
   END IF;

   l_je_category_name := 'WIP';

   x_retcode := FND_API.G_RET_STS_SUCCESS;

   /* one (txn_id,org_id,txn_src_type_id) -> one entity_id -> one event_id -> one header_id */
   /* one wta line -> one xla_ae_line -> one xla_distribution_link */

   l_stmt_num   :=10;

   insert into cst_xla_seq_gt(
          source_id_int_1,
          source_id_int_2,
          source_id_int_3,
          entity_id,
          event_id,
          header_id)
   select transaction_id,
          resource_id,
          basis_type,
          XLA_transaction_ENTITies_S.nextval,
          xla_events_s.nextval,
          xla_ae_headers_s.NEXTVAL
   from (select distinct wta.transaction_id, wta.resource_id, wta.basis_type
         from wip_transaction_accounts wta
         where wta.transaction_id >= X_min_id
               and wta.transaction_id <= X_max_id
               and exists (select null
                          from xla_upgrade_dates xud,
                               HR_ORGANIZATION_INFORMATION HOI2,
                               ORG_ACCT_PERIODS oap,
                               wip_transactions wt
                          where HOI2.organization_id = oap.organization_id
                                and HOI2.ORG_INFORMATION_CONTEXT ='Accounting Information'
                                AND HOI2.ORG_INFORMATION1 = TO_CHAR(xud.ledger_ID)
                                and wt.acct_period_id = oap.acct_period_id
                                and oap.ORGANIZATION_ID = wt.organization_id
                                and oap.period_start_date >= xud.start_date
                                and oap.schedule_close_date <= xud.end_date
                                and wta.transaction_id = wt.transaction_id)
               and (wta.gl_batch_id > 0
                    or wta.gl_batch_id = -1
                       and not exists
                          (select null
                           from  pjm_org_parameters pop
                           where pop.organization_id = wta.organization_id
                                 and pop.pa_posting_flag = 'Y')

                   )
              and wta.wip_sub_ledger_id is null);

   l_rows_processed := SQL%ROWCOUNT;
   IF (l_rows_processed = 0) THEN
      IF l_Log THEN
        log_message(
         fnd_log.level_procedure,
         l_module||'.'||l_stmt_num,
         'No rows to be upgraded. Exiting CST_SLA_UPDATE_PKG.Update_WIP_Subledger with '||
         'X_errbuf = '||X_errbuf||','||
         'X_retcode = '||X_retcode
         );
      END IF;
      return;
   END IF;

   l_stmt_num   :=20;

   update /*+ leading(cxs) use_nl(wta) index(wta) */
          wip_transaction_accounts wta
   set wip_sub_ledger_id = cst_wip_sub_ledger_id_s.nextval,
       last_update_date = gUpdateDate,
       last_updated_by = gUserId,
       last_update_login = gLoginId
   where (wta.transaction_id, nvl(wta.resource_id,-6661), nvl(wta.basis_type,-6661)) in
         (select source_id_int_1,
                 nvl(source_id_int_2,-6661),
                 nvl(source_id_int_3,-6661)
          from cst_xla_seq_gt cxs);


   l_stmt_num   :=30;

   insert all
     when (line_id=1) then
     INTO XLA_TRANSACTION_ENTITIES (
          upg_batch_id,
          entity_id,
          application_id,
          ledger_id,
          legal_entity_id,
          entity_code,
          source_id_int_1,
          SOURCE_ID_INT_2,
          SOURCE_ID_INT_3,
          security_id_int_1,
          TRANSACTION_NUMBER,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          source_application_id,
          UPG_SOURCE_APPLICATION_ID)
       values (l_upg_batch_id,
          entity_id,
          707,
          ledger_id,
          legal_entity_id,
          'WIP_ACCOUNTING_EVENTS',
          transaction_id,
          resource_id,
          basis_type,
          organization_id,
          transaction_id,
          creation_date,
          CREATED_BY,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          706,
          706)
    into xla_events (
          upg_batch_id,
          APPLICATION_ID,
          entity_id,
          event_id,
          event_number,
          event_type_code,
          event_date,
          event_status_code,
          PROCESS_STATUS_CODE,
          ON_HOLD_FLAG,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          TRANSACTION_DATE,
          UPG_SOURCE_APPLICATION_ID)
      values (l_upg_batch_id,
          707,
          entity_id,
          event_id,
          1,
          event_type_code,
          transaction_date,
          'P',
          'P',
          'N',
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          TRANSACTION_DATE,
          706)
    into xla_ae_headers (
          upg_batch_id,
          application_id,
          AMB_CONTEXT_CODE,
          entity_id,
          event_id,
          event_type_code,
          ae_header_id,
          ledger_id,
          je_category_name,
          ACCOUNTING_DATE,
          PERIOD_NAME,
          BALANCE_TYPE_CODE,
          GL_TRANSFER_STATUS_CODE,
          GL_TRANSFER_DATE,
          ACCOUNTING_ENTRY_STATUS_CODE,
          ACCOUNTING_ENTRY_TYPE_CODE,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          ZERO_AMOUNT_FLAG,
          UPG_SOURCE_APPLICATION_ID)
       values (l_upg_batch_id,
          707,
          'DEFAULT',
          entity_id,
          event_id,
          event_type_code,
          header_id,
          ledger_id,
          l_je_category_name,
          gl_date,
          PERIOD_NAME,
          'A',
          GL_TRANSFER_STATUS_CODE,
          gl_transfer_date,
          'F',
          'STANDARD',
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          ZERO_AMOUNT_FLAG,
          706)
     when (1=1) then
       into xla_ae_lines (
          upg_batch_id,
          application_id,
          ae_header_id,
          ae_line_num,
          code_combination_id,
          gl_transfer_mode_code,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          CURRENCY_CONVERSION_TYPE,
          ENTERED_DR,
          ENTERED_CR,
          accounting_class_code,
          gl_sl_link_id,
          gl_sl_link_table,
          CONTROL_BALANCE_FLAG,
          GAIN_OR_LOSS_FLAG,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          accounting_date,
          ledger_id)
       values (l_upg_batch_id,
          707,
          header_id,
          line_id,
          ref_account,
          GL_Update_code,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          CURRENCY_CONVERSION_TYPE,
          ENTERED_DR,
          ENTERED_CR,
          accounting_class_code,
          link_id,
          link_table,
          CONTROL_BALANCE_FLAG,
          'N',
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          gl_date,
          ledger_id)
       into xla_distribution_links (
          upg_batch_id,
          application_id,
          event_id,
          ae_header_id,
          ae_line_num,
          accounting_line_code,
          accounting_line_type_code,
          source_distribution_type,
          source_distribution_id_num_1,
          merge_duplicate_code,
          REF_AE_HEADER_ID,
          TEMP_LINE_NUM,
          event_class_code,
          event_type_code)
       values (l_upg_batch_id,
          707,
          event_id,
          header_id,
          line_id,
          accounting_class_code,
          line_type_code,
          src_dist_type,
          src_dist_id_num_1,
          merge_dup_code,
          header_id,
          line_id,
          event_class_code,
          event_type_code)

   select /*+ leading(cxs) use_nl(wta wt HOI2 oap mp gcc) index(wta) index(wt) index(mp) index(HOI2) index(oap) index(mp) index(gcc)*/
          row_number() over(partition by wta.transaction_id,wta.resource_id,wta.basis_type
                       order by wta.transaction_id) as line_id,
          wta.creation_date creation_date,
          wta.last_update_date last_update_date,
          wta.created_by created_by,
          wta.last_updated_by last_updated_by,
          wta.last_update_login LAST_UPDATE_LOGIN,
          wta.program_update_date PROGRAM_UPDATE_DATE,
          wta.program_application_id PROGRAM_APPLICATION_ID,
          wta.program_id PROGRAM_ID,
          wta.request_id REQUEST_ID,
          wta.transaction_id transaction_id,
          wta.resource_id resource_id,
          wta.basis_type basis_type,
          cxs.entity_id entity_id,
          cxs.event_id event_id,
          cxs.header_id header_id,
          wta.organization_id organization_id,
          wt.transaction_date transaction_date,
          NVL(ogb.gl_batch_date,
              trunc(INV_LE_TIMEZONE_PUB.Get_Le_Day_For_Server(wt.transaction_date, HOI2.ORG_INFORMATION2))) gl_date,
          ogb.gl_batch_date gl_transfer_date,
          sob.ledger_id ledger_id,
          /*DECODE(HOI2.ORG_INFORMATION_CONTEXT, 'Accounting Information', TO_NUMBER(HOI2.ORG_INFORMATION2), null)*/
          null legal_entity_id,
          event_type_code,
          PERIOD_NAME,
          DECODE(wta.GL_BATCH_ID, -1, decode(mp.GENERAL_LEDGER_UPDATE_CODE,3,'NT','N'),decode(sign(wta.gl_batch_id),1, 'Y', 'NT')) GL_TRANSFER_STATUS_CODE,
          nvl(wt.currency_code, nvl(wta.currency_code, sob.currency_code)) CURRENCY_CODE,
          wta.REFERENCE_ACCOUNT ref_account,
          decode(mp.GENERAL_LEDGER_UPDATE_CODE,1, 'D', 2, 'S', 'N') GL_Update_code,
          decode(wta.accounting_line_type,
                 1,'INVENTORY_VALUATION',
                 2,decode(cem.event_class_code,
                          'PURCHASE_ORDER'         ,'CLEARING',
                          'FOB_RCPT_SENDER_RCPT'   ,'COST_OF_GOODS_SOLD',
                          'FOB_SHIP_SENDER_SHIP'   ,'COST_OF_GOODS_SOLD',
                          'SALES_ORDER'            ,'COST_OF_GOODS_SOLD',
                          'MTL_COST_UPD'           ,'COST_UPDATE_ADJUSTMENT',
                          'WIP_COST_UPD'           ,'COST_UPDATE_ADJUSTMENT',
                          'LOG_INTERCOMPANY'       ,'INTERCOMPANY_COGS',
                          'FOB_RCPT_RECIPIENT_RCPT','INTERCOMPANY_ACCRUAL',
                          'FOB_SHIP_RECIPIENT_SHIP','INTERCOMPANY_ACCRUAL',
                          'OFFSET'),
                 3,decode(cem.event_class_code,
                          'ABSORPTION'             ,'OVERHEAD_ABSORPTION',
                          'OSP'                    ,'OVERHEAD_ABSORPTION',
                          'MATERIAL_OVERHEAD_ABSORPTION'),
                 4,'RESOURCE_ABSORPTION',
                 5,'RECEIVING_INSPECTION',
                 6,decode(cem.event_class_code,
                          'ABSORPTION','RESOURCE_RATE_VARIANCE',
                          'PURCHASE_PRICE_VARIANCE'),
                 7,'WIP_VALUATION',
                 8,'WIP_VARIANCE',
                 9,'INTERORG_PAYABLES',
                 10,'INTERORG_RECEIVABLES',
                 11,'INTERORG_TRANSFER_CREDIT',
                 12,'INTERORG_FREIGHT_CHARGE',
                 13,'COST_VARIANCE',
                 14,'INTRANSIT_VALUATION',
                 15,'ENCUMBRANCE_REVERSAL',
                 16,decode(cem.event_class_code,
                           'LOG_INTERCOMPANY','INTERCOMPANY_ACCRUAL',
                           'ACCRUAL'),
                 17,'INVOICE_PRICE_VARIANCE',
                 18,'EXCHANGE_RATE_VARIANCE',
                 19,'SPECIAL_CHARGE_EXPENSE',
                 20,'EXPENSE',
                 21,'WIP_VALUATION',
                 22,'WIP_VALUATION',
                 23,'WIP_VALUATION',
                 24,'WIP_VALUATION',
                 25,'WIP_VALUATION',
                 26,'WIP_VALUATION',
                 27,'WIP_VALUATION',
                 28,'WIP_VALUATION',
                 29,'ESTIMATED_SCRAP_ABSORPTION',
                 30,'PROFIT_IN_INVENTORY',
                 31,'CLEARING',
                 32,'RETROACTIVE_PRICE_ADJUSTMENT',
                 33,'SHIKYU_VARIANCE',
                 34,'INTERORG_PROFIT',
                 35,'COST_OF_GOODS_SOLD',
                 36,'DEFERRED_COGS',
                 37,'COST_UPDATE_ADJUSTMENT',
                 'UNKNOWN') accounting_class_code,
          wta.gl_sl_link_id link_id,
          'WTA' link_table,
          'C' line_type_code,
          'WIP_TRANSACTION_ACCOUNTS' src_dist_type,
          wta.wip_sub_ledger_id src_dist_id_num_1,
          'N' merge_dup_code,
          DECODE(sign(wta.base_transaction_value), 1, wta.base_transaction_value, 0, 0, NULL) ACCOUNTED_DR,
          DECODE(sign(wta.base_transaction_value), -1,(-1*wta.base_transaction_value), NULL) ACCOUNTED_CR,
          wta.CURRENCY_CONVERSION_DATE CURRENCY_CONVERSION_DATE,
          wta.CURRENCY_CONVERSION_RATE CURRENCY_CONVERSION_RATE,
          wta.CURRENCY_CONVERSION_TYPE CURRENCY_CONVERSION_TYPE,
          DECODE(sign(nvl(wta.transaction_value, wta.base_transaction_value)), 1, nvl(wta.transaction_value, wta.base_transaction_value), 0, 0, NULL) ENTERED_DR,
          DECODE(sign(nvl(wta.transaction_value, wta.base_transaction_value)), -1,(-1*nvl(wta.transaction_value, wta.base_transaction_value)), NULL) ENTERED_CR,
          NVL(wta.TRANSACTION_VALUE,wta.BASE_TRANSACTION_VALUE) entered_amount,
          decode(sign(wta.base_transaction_value),0,'Y', 'N') ZERO_AMOUNT_FLAG,
          decode(gcc.reference3,'Y', 'P', null) CONTROL_BALANCE_FLAG,
          cem.event_class_code event_class_code
   from   wip_transaction_accounts wta,
          cst_xla_wip_event_map cem,
          wip_transactions wt,
          GL_CODE_COMBINATIONS gcc,
          mtl_parameters mp,
          HR_ORGANIZATION_INFORMATION HOI2,
          gl_ledgers sob,
          ORG_ACCT_PERIODS oap,
          org_gl_batches ogb,
          cst_xla_seq_gt cxs
   where  wta.transaction_id=cxs.source_id_int_1
          and wt.transaction_id=cxs.source_id_int_1
          and nvl(wta.resource_id,-6661)=nvl(cxs.source_id_int_2,-6661)
          and nvl(wta.basis_type,-6661)=nvl(cxs.source_id_int_3,-6661)
          and mp.organization_id=HOI2.organization_id
          and wta.organization_id=mp.organization_id
          and ((wt.transaction_type=cem.transaction_type_id
                  and wt.transaction_type not in (1,2,3))
                or (wt.transaction_type in (1,2,3)
                    and DECODE( wta.COST_ELEMENT_ID,
                            3, 'RESOURCE_ABSORPTION',
                            4, DECODE (wt.source_code, 'IPV', 'IPV_TRANSFER_WO',
                                      DECODE (wt.autocharge_type, 3, 'OSP',
                                                                  4, 'OSP',
                                                                  'RESOURCE_ABSORPTION')),
                            5, 'OVERHEAD_ABSORPTION') = cem.event_type_code))
          and gcc.CODE_COMBINATION_ID=wta.REFERENCE_ACCOUNT
          AND wt.acct_period_id = oap.acct_period_id
          and oap.ORGANIZATION_ID = wt.organization_id
          AND wt.organization_id = HOI2.organization_id
          and wta.organization_id = ogb.organization_id (+)
          and wta.gl_batch_id = ogb.gl_batch_id (+)
          and HOI2.ORG_INFORMATION_CONTEXT ='Accounting Information'
          AND sob.ledger_ID = TO_NUMBER(DECODE(RTRIM(TRANSLATE(HOI2.ORG_INFORMATION1,'0123456789',' ')),
                                              NULL, HOI2.ORG_INFORMATION1,
                                              -99999))
          and sob.object_type_code = 'L';

    <<out_arg_log>>

    IF l_Log THEN
      log_message(
        fnd_log.level_procedure,
        l_module||'.end',
        'Exiting CST_SLA_UPDATE_PKG.Update_WIP_Subledger with '||
        'X_errbuf = '||X_errbuf||','||
        'X_retcode = '||X_retcode
      );
    END IF;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

end Update_WIP_Subledger;

-------------------------------------------------------------------------------------
--  API name   : Update_RCV_Subledger
--  Type       : Private
--  Function   : To update Receiving Sub Ledger to SLA data model from minimum
--               transaction ID to maximum transaction ID.
--  Pre-reqs   :
--  Parameters :
--  IN         :       X_min_id     in  number,
--                     X_max_id     in  number
--
--  OUT        :       X_errbuf         out NOCOPY varchar2,
--                     X_retcode        out NOCOPY varchar2
--
--  Notes      : The API is called from Update_Proc_RCV_WKR.
--
-- End of comments
-------------------------------------------------------------------------------------

PROCEDURE Update_Receiving_Subledger (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_min_id  in number,
               X_max_id  in number)
IS
    l_upg_batch_id number(15):=0;
    l_je_category_name varchar2(30);

    l_module       CONSTANT VARCHAR2(90) := 'cst.plsql.CST_SLA_UPDATE_PKG.Update_Receiving_Subledger';
    l_Log          CONSTANT BOOLEAN := fnd_log.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND gRequestId > 0;

    l_stmt_num      number;
    l_multi_org_flag varchar2(1);
    l_rows_processed number;
    CST_RCV_MRC_UPG_EXCEPTION exception;

BEGIN

   l_stmt_num   :=0;

   IF l_Log THEN
     log_message(
       fnd_log.level_procedure,
       l_module||'.'||l_stmt_num,
       'Entering CST_SLA_UPDATE_PKG.Update_Receiving_Subledger with '||
       'X_min_id = '||X_min_id||','||
       'X_max_id = '||X_max_id
     );
   END IF;

   select XLA_UPG_BATCHES_S.nextval into l_upg_batch_id from dual;

   IF l_Log THEN
     log_message(
       fnd_log.level_procedure,
       l_module,
       'Upgrade Batch ID = '||l_upg_batch_id
     );
   END IF;

   l_je_category_name :='Receiving';

   x_retcode := FND_API.G_RET_STS_SUCCESS;

   SELECT MULTI_ORG_FLAG
   INTO   l_multi_org_flag
   FROM   FND_PRODUCT_GROUPS;

   /* For one rt/rae combo, we are going to have one SLA.entity_id, one SLA.event_id, one SLA.header_id */
   /* one rrs line -> one xla_ae_line -> one xla_distribution_link */

   /* For 11.5.9 or before, we only had one org_id, one organization_id, and one ledger_id
      for the accounting lines corresponding to one RT.txn_id;
      But since 11.5.10 introducing global procurement, we have multiple org_id, multiple organization_id,
      and multiple ledger_id in RAE corresponding to one RT.txn_id. I.e, Customer(RT.txn_id)--OU3---OU2---OU1--S
    */

   l_stmt_num   :=10;

   insert into cst_xla_seq_gt(
              source_id_int_1,
              source_id_int_2,
              source_id_int_3,
              source_id_int_4,
              source_id_int_5,
              entity_id,
              event_id,
              header_id,
              legal_entity,
              org_id)
       select /*+ leading(rrs) */
              rt.transaction_id,
              rae.accounting_event_id,
              HOI2.organization_id,
              nvl(rae.EVENT_TYPE_ID,decode(rt.transaction_type, 'RECEIVE', 1, 'DELIVER', 2, 'CORRECT', 3,
                           'MATCH', 4, 'RETURN TO RECEIVING', 5, 'RETURN TO VENDOR', 6, -1)),
              rt.parent_transaction_id,
              XLA_transaction_ENTITies_S.nextval,
              xla_events_s.nextval,
              xla_ae_headers_s.NEXTVAL,
              null,
              nvl(rae.org_id,
                  DECODE(l_multi_org_flag,'Y',TO_NUMBER(HOI2.ORG_INFORMATION3),TO_NUMBER(NULL)))
       from rcv_transactions rt,
            rcv_accounting_events rae,
            hr_organization_information hoi2,
            gl_ledgers sob,
            (select /*+ no_merge leading(rrs) use_hash(xud) swap_join_inputs(xud) */
                    distinct rcv_transaction_id
              from  xla_upgrade_dates xud,
                    rcv_receiving_sub_ledger rrs
              where rrs.rcv_transaction_id between x_min_id and x_max_id
              and   xud.ledger_id = rrs.set_of_books_id
              and   rrs.accounting_date between xud.start_date and xud.end_date
              and   rrs.encumbrance_type_id is null
              and   rrs.reference10 is null
              and   rrs.je_batch_name is not null) rrs
       where rt.transaction_id = rrs.rcv_transaction_id
       and   rt.transaction_id = rae.rcv_transaction_id (+)
       and   hoi2.organization_id = nvl (rae.organization_id, rt.organization_id)
       and   hoi2.org_information_context = 'Accounting Information'
       and   sob.ledger_ID = TO_NUMBER(DECODE(RTRIM(TRANSLATE(HOI2.ORG_INFORMATION1,'0123456789',' ')),
                                       NULL, HOI2.ORG_INFORMATION1,
                                       -99999))
       and sob.object_type_code = 'L';

   l_rows_processed := SQL%ROWCOUNT;
   IF (l_rows_processed = 0) THEN
      IF l_Log THEN
        log_message(
         fnd_log.level_procedure,
         l_module||'.'||l_stmt_num,
         'No rows to be upgraded. Exiting CST_SLA_UPDATE_PKG.Update_Receiving_Subledger with '||
         'X_errbuf = '||X_errbuf||','||
         'X_retcode = '||X_retcode
         );
      END IF;
      return;
   END IF;

   l_stmt_num   :=20;
   /* Bug 6729184 Moved update of rcv_sub_ledger_id prior to XLA insert to avoid NULL into
       XDL.SOURCE_DISTRIBUTION_ID_NUM_1*/

   update /*+ leading(cxs) use_nl(rrs) index(rrs) */
       rcv_receiving_sub_ledger rrs
   set reference10 = 'Migrated to SLA',
       rcv_sub_ledger_id = nvl(rcv_sub_ledger_id, rcv_receiving_sub_ledger_s.nextval),
       last_update_date = gUpdateDate,
       last_updated_by = gUserId,
       last_update_login = gLoginId
   where rrs.rcv_transaction_id in (select source_id_int_1 from cst_xla_seq_gt cxs)
         and rrs.ENCUMBRANCE_TYPE_ID is null;


   l_stmt_num   :=30;

   insert all
     when (line_id=1) then
     INTO XLA_TRANSACTION_ENTITIES (
          upg_batch_id,
          entity_id,
          application_id,
          ledger_id,
          legal_entity_id,
          entity_code,
          source_id_int_1,
          SOURCE_ID_INT_2,
          SOURCE_ID_INT_3,
          security_id_int_1,
          SECURITY_ID_INT_2,
          TRANSACTION_NUMBER,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          source_application_id,
          UPG_SOURCE_APPLICATION_ID)
       values (l_upg_batch_id,
          entity_id,
          707,
          ledger_id,
          legal_entity_id,
          'RCV_ACCOUNTING_EVENTS',
          transaction_id,
          accounting_event_id,
          organization_id,
          organization_id,
          org_id,
          transaction_number,
          creation_date,
          CREATED_BY,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          201,
          201)
    into xla_events (
          upg_batch_id,
          APPLICATION_ID,
          entity_id,
          event_id,
          event_number,
          event_type_code,
          event_date,
          event_status_code,
          PROCESS_STATUS_CODE,
          ON_HOLD_FLAG,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          TRANSACTION_DATE,
          UPG_SOURCE_APPLICATION_ID)
      values (l_upg_batch_id,
          707,
          entity_id,
          event_id,
          1,
          event_type_code,
          transaction_date,
          'P',
          'P',
          'N',
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          TRANSACTION_DATE,
          201)
    into xla_ae_headers (
          upg_batch_id,
          application_id,
          AMB_CONTEXT_CODE,
          entity_id,
          event_id,
          event_type_code,
          ae_header_id,
          ledger_id,
          je_category_name,
          ACCOUNTING_DATE,
          PERIOD_NAME,
          BALANCE_TYPE_CODE,
          BUDGET_VERSION_ID,
          DOC_SEQUENCE_ID,
          DOC_SEQUENCE_VALUE,
          GL_TRANSFER_STATUS_CODE,
          GL_TRANSFER_DATE,
          ACCOUNTING_ENTRY_STATUS_CODE,
          ACCOUNTING_ENTRY_TYPE_CODE,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          UPG_SOURCE_APPLICATION_ID,
          description)
       values (l_upg_batch_id,
          707,
          'DEFAULT',
          entity_id,
          event_id,
          event_type_code,
          header_id,
          ledger_id,
          l_je_category_name,
          accounting_date,
          PERIOD_NAME,
          actual_flag,
          BUDGET_VERSION_ID,
          DOC_SEQUENCE_ID,
          DOC_SEQUENCE_VALUE,
          GL_TRANSFER_STATUS_CODE,
          DATE_CREATED_IN_GL,
          'F',
          'STANDARD',
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          201,
          je_header_name)
     when (1=1) then
       into xla_ae_lines (
          upg_batch_id,
          application_id,
          ae_header_id,
          ae_line_num,
          code_combination_id,
          gl_transfer_mode_code,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          CURRENCY_CONVERSION_TYPE,
          ENTERED_DR,
          ENTERED_CR,
          accounting_class_code,
          gl_sl_link_id,
          gl_sl_link_table,
          USSGL_TRANSACTION_CODE,
          CONTROL_BALANCE_FLAG,
          GAIN_OR_LOSS_FLAG,
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          description,
          accounting_date,
          ledger_id)
       values (l_upg_batch_id,
          707,
          header_id,
          line_id,
          ccid,
          GL_Update_code,
          ACCOUNTED_DR,
          ACCOUNTED_CR,
          CURRENCY_CODE,
          CURRENCY_CONVERSION_DATE,
          CURRENCY_CONVERSION_RATE,
          CURRENCY_CONVERSION_TYPE,
          ENTERED_DR,
          ENTERED_CR,
          accounting_class_code,
          link_id,
          link_table,
          USSGL_TRANSACTION_CODE,
          CONTROL_BALANCE_FLAG,
          'N',
          CREATION_DATE,
          created_by,
          last_update_date,
          last_updated_by,
          LAST_UPDATE_LOGIN,
          PROGRAM_UPDATE_DATE,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          REQUEST_ID,
          je_line_description,
          accounting_date,
          ledger_id)
       into xla_distribution_links (
          upg_batch_id,
          application_id,
          event_id,
          ae_header_id,
          ae_line_num,
          accounting_line_code,
          accounting_line_type_code,
          source_distribution_type,
          source_distribution_id_num_1,
          merge_duplicate_code,
          REF_AE_HEADER_ID,
          TEMP_LINE_NUM,
          event_class_code,
          event_type_code)
       values (l_upg_batch_id,
          707,
          event_id,
          header_id,
          line_id,
          accounting_class_code,
          line_type_code,
          src_dist_type,
          rcv_sub_ledger_id,
          merge_dup_code,
          header_id,
          line_id,
          event_class_code,
          event_type_code)

   select /*+ leading(cxs) use_nl(rrs) index(rrs) index(gcc)*/
          row_number() over(partition by cxs.source_id_int_1, cxs.source_id_int_2 ,cxs.source_id_int_3
                       order by cxs.source_id_int_1) as line_id,
          rrs.creation_date creation_date,
          rrs.last_update_date last_update_date,
          rrs.created_by created_by,
          rrs.last_updated_by last_updated_by,
          rrs.last_update_login LAST_UPDATE_LOGIN,
          rrs.program_update_date PROGRAM_UPDATE_DATE,
          rrs.program_application_id PROGRAM_APPLICATION_ID,
          rrs.program_id PROGRAM_ID,
          rrs.request_id REQUEST_ID,
          cxs.entity_id entity_id,
          cxs.event_id event_id,
          cxs.header_id header_id,
          rrs.rcv_transaction_id transaction_id,
          cxs.source_id_int_3 organization_id,
          cxs.source_id_int_2 accounting_event_id,
          cxs.org_id org_id,
          cxs.source_id_int_5 parent_transaction_id,
          cxs.source_id_int_1 transaction_number,
          rrs.transaction_date transaction_date,
          rrs.accounting_date accounting_date,
          rrs.set_of_books_id ledger_id,
          cxs.legal_entity legal_entity_id,
          event_type_code,
          rrs.PERIOD_NAME,
          rrs.actual_flag,
          'Y' GL_TRANSFER_STATUS_CODE,
          rrs.CURRENCY_CODE CURRENCY_CODE,
          rrs.budget_version_id BUDGET_VERSION_ID,
          rrs.SUBLEDGER_DOC_SEQUENCE_ID DOC_SEQUENCE_ID,
          rrs.SUBLEDGER_DOC_SEQUENCE_VALUE DOC_SEQUENCE_VALUE,
          nvl(rrs.DATE_CREATED_IN_GL,rrs.accounting_date) DATE_CREATED_IN_GL,
          rrs.je_header_name je_header_name,
          rrs.je_line_description je_line_description,
          rrs.CODE_COMBINATION_ID ccid,
          rrs.rcv_sub_ledger_id rcv_sub_ledger_id,
          'D' GL_Update_code,
          decode(nvl(rrs.accounting_line_type,'888'),
                 'Accrual','ACCRUAL',
                 'Charge','CHARGE',
                 'Clearing','CLEARING',
                 'IC Accrual','INTERCOMPANY_ACCRUAL',
                 'IC Cost of Sales','INTERCOMPANY_COGS',
                 'Receiving Inspection','RECEIVING_INSPECTION',
                 'Retroprice Adjustment','RETROACTIVE_PRICE_ADJUSTMENT',
                 '888',decode(cem.transaction_type_id,
                             1, decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                             2, decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','CHARGE'),
                             3, decode(cem.attribute,
                                       'RECEIVE', decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                                       'MATCH', decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                                       'DELIVER', decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','CHARGE'),
                                       'RETURN TO VENDOR',decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','ACCRUAL'),
                                       'RETURN TO RECEIVING', decode(sign(rrs.accounted_cr),1,'CHARGE','RECEIVING_INSPECTION'),
                                       ''),
                             4, decode(sign(rrs.accounted_cr),1,'ACCRUAL','RECEIVING_INSPECTION'),
                             5, decode(sign(rrs.accounted_cr),1,'CHARGE','RECEIVING_INSPECTION'),
                             6, decode(sign(rrs.accounted_cr),1,'RECEIVING_INSPECTION','ACCRUAL'),
                             ''),
                 'UNKNOWN') accounting_class_code,
          rrs.gl_sl_link_id link_id,
          'RSL' link_table,
          'C' line_type_code,
          'RCV_RECEIVING_SUB_LEDGER' src_dist_type,
          'N' merge_dup_code,
          rrs.accounted_dr ACCOUNTED_DR,
          rrs.accounted_cr ACCOUNTED_CR,
          rrs.CURRENCY_CONVERSION_DATE CURRENCY_CONVERSION_DATE,
          rrs.CURRENCY_CONVERSION_RATE CURRENCY_CONVERSION_RATE,
          rrs.USER_CURRENCY_CONVERSION_TYPE CURRENCY_CONVERSION_TYPE,
          rrs.entered_dr ENTERED_DR,
          rrs.entered_cr ENTERED_CR,
          rrs.USSGL_TRANSACTION_CODE USSGL_TRANSACTION_CODE,
          decode(gcc.reference3,'Y', 'P', null) CONTROL_BALANCE_FLAG,
          cem.event_class_code event_class_code
   from   rcv_receiving_sub_ledger rrs,
          cst_xla_rcv_event_map cem,
          GL_CODE_COMBINATIONS gcc,
          cst_xla_seq_gt cxs
   where  rrs.rcv_transaction_id = cxs.source_id_int_1
          and (rrs.accounting_event_id is null or rrs.accounting_event_id = cxs.source_id_int_2)
          and rrs.ENCUMBRANCE_TYPE_ID is null
          and cxs.source_id_int_4 = cem.transaction_type_id
          and (cem.transaction_type_id <> 3
               or
               (cem.transaction_type_id = 3
                and cxs.source_id_int_5 is not null
                and cem.attribute = (SELECT TRANSACTION_TYPE
                               FROM RCV_TRANSACTIONS rt1
                               WHERE  rt1.transaction_id =  cxs.source_id_int_5))
               )
          and gcc.CODE_COMBINATION_ID=rrs.CODE_COMBINATION_ID;

   l_stmt_num   :=40;

   if (g_mrc_enabled) then
       RCV_SLA_MRC_UPDATE_PKG.Update_Receiving_MRC_Subledger(X_errbuf => X_errbuf,
                                                             X_retcode => X_retcode,
                                                             X_upg_batch_id => l_upg_batch_id,
                                                             X_je_category_name => l_je_category_name);
       if (X_retcode <> FND_API.G_RET_STS_SUCCESS) then
           raise CST_RCV_MRC_UPG_EXCEPTION;
       end if;
   end if;

   <<out_arg_log>>

   IF l_Log THEN
     log_message(
       fnd_log.level_procedure,
       l_module||'.end',
       'Exiting CST_SLA_UPDATE_PKG.Update_Receiving_Subledger with '||
       'X_errbuf = '||X_errbuf||','||
       'X_retcode = '||X_retcode
     );
   END IF;

EXCEPTION

  WHEN CST_RCV_MRC_UPG_EXCEPTION THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: An exception has occurred in upgrade of receiving MRC table.',
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'ERROR: '||X_errbuf,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

  WHEN OTHERS THEN
    ROLLBACK;
    X_retcode := FND_API.g_ret_sts_unexp_error;
    handle_error ( X_module   => l_module||'.'||l_stmt_num,
              X_message  => 'EXCEPTION: '||SQLERRM,
              X_reqerror => FALSE,
              X_errbuf   => X_errbuf );

end Update_Receiving_Subledger;

END CST_SLA_UPDATE_PKG;

/
