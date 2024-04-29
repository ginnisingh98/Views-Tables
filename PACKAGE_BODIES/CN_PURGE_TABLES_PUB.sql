--------------------------------------------------------
--  DDL for Package Body CN_PURGE_TABLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PURGE_TABLES_PUB" AS
  /* $Header: CNPTPRGB.pls 120.0.12010000.4 2010/06/17 05:03:18 sseshaiy noship $*/

  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CN_PURGE_TABLES_PUB';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'CNPTPRGB.pls';
  g_cn_debug  VARCHAR2(1)           := fnd_profile.value('CN_DEBUG');
  g_error_msg VARCHAR2(100)         := ' is a required field. Please enter proper value for it.';
  g_script_name CONSTANT VARCHAR2(30)  := 'CNPTPRGBT1.0';
  g_request_id           NUMBER        := fnd_global.conc_request_id;



PROCEDURE debugmsg
  (
    msg VARCHAR2
  )
IS
BEGIN
  --g_cn_debug   := 'Y';
  IF g_cn_debug = 'Y' THEN
    cn_message_pkg.debug
    (
      SUBSTR(msg,1,254)
    )
    ;
    fnd_file.put_line
    (
      fnd_file.Log, msg
    )
    ; -- Bug fix 5125980
  END IF;
  -- comment out dbms_output before checking in file
  -- dbms_output.put_line(substr(msg,1,254));
END debugmsg;

PROCEDURE parent_conc_wait(
         l_child_program_id_tbl IN  OUT NOCOPY    sub_program_id_type
       , retcode                OUT     NOCOPY    VARCHAR2
       , errbuf                 OUT     NOCOPY    VARCHAR2

                    )
IS

    call_status                  BOOLEAN;

    l_req_id                     NUMBER;

    l_phase                      VARCHAR2(100);
    l_status                     VARCHAR2(100);
    l_dev_phase                  VARCHAR2(100);
    l_dev_status                 VARCHAR2(100);
    l_message                    VARCHAR2(2000);

    child_proc_fail_exception    EXCEPTION;
BEGIN
     debugmsg('CN_PURGE_TABLES_PUB.Parent Process starts Waiting For Child
     Processes to complete');

     FOR l_child_program_id IN l_child_program_id_tbl.FIRST..l_child_program_id_tbl.LAST
     LOOP

            call_status :=
            FND_CONCURRENT.get_request_status(
            l_child_program_id_tbl(l_child_program_id), '', '',
 			    l_phase, l_status, l_dev_phase,
                            l_dev_status, l_message);

           debugmsg('CN_PURGE_TABLES_PUB. Request '||l_child_program_id_tbl(l_child_program_id)
           ||' l_dev_phase '||l_dev_phase||' l_dev_status ');

           WHILE l_dev_phase <> 'COMPLETE'
           LOOP

            call_status :=
            FND_CONCURRENT.get_request_status(
            l_child_program_id_tbl(l_child_program_id), '', '',
 			    l_phase, l_status, l_dev_phase,
                            l_dev_status, l_message);

           debugmsg('CN_PURGE_TABLES_PUB. Request '||l_child_program_id_tbl(l_child_program_id)
           ||' l_dev_phase '||l_dev_phase||' l_dev_status. Parent Process going to sleep for 10 seconds. ');

               dbms_lock.sleep(10);

           END LOOP;


            IF l_dev_status = 'ERROR'
            THEN
               retcode := 2;
               errbuf := l_message;
               raise child_proc_fail_exception;
            END IF;

     END LOOP;
EXCEPTION
WHEN child_proc_fail_exception
THEN
retcode := 2;
debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables.Child Proc Failed exception');
debugmsg('CN_PURGE_TABLES_PUB : SQLCODE : ' || SQLCODE);
debugmsg('CN_PURGE_TABLES_PUB : SQLERRM : ' || SQLERRM);
WHEN OTHERS THEN
debugmsg('CN_PURGE_TABLES_PUB : Unexpected exception in archive_purge_cn_tables');
debugmsg('CN_PURGE_TABLES_PUB : SQLCODE : ' || SQLCODE);
debugmsg('CN_PURGE_TABLES_PUB : SQLERRM : ' || SQLERRM);
retcode  := 2;
errbuf   := 'CN_PURGE_TABLES_PUB.archive_purge_cn_tables.exception.others';

END parent_conc_wait;


-- API name  : archive_purge_cn_tables
-- Type : public.
-- Pre-reqs :
PROCEDURE archive_purge_cn_tables
  (
    errbuf OUT NOCOPY  VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_run_mode          IN VARCHAR2,
    p_start_period_name IN VARCHAR2,
    p_end_period_name   IN VARCHAR2,
    p_org_id            IN NUMBER,
    p_table_space       IN VARCHAR2,
    p_no_of_workers     IN NUMBER,
    p_worker_id         IN NUMBER,
    p_batch_size        IN NUMBER
  )
IS

  CURSOR get_start_period_id
  IS
     SELECT period_id
       FROM cn_periods
      WHERE period_name = p_start_period_name
    AND org_id          = p_org_id AND closing_status in ('C', 'P') ;

  CURSOR get_end_period_id
  IS
     SELECT period_id
       FROM cn_periods
      WHERE period_name = p_end_period_name
    AND org_id          = p_org_id AND closing_status in ('C', 'P') ;

  l_api_name        CONSTANT VARCHAR2(30) := 'purge_cn_tables';
  l_api_version     CONSTANT NUMBER       :=1.0;
  l_init_msg_list   VARCHAR2(10)          := FND_API.G_FALSE;
  l_start_period_id NUMBER := -1;
  l_end_period_id   NUMBER := -1;
  l_error_msg       VARCHAR(240);
  l_time            VARCHAR2(20);
  l_table_space     VARCHAR2(30);
  x_msg_count       NUMBER;
  x_msg_data        VARCHAR2(2000);
  x_return_status   VARCHAR2(1);
  l_req_id                     NUMBER;
  l_child_program_id_tbl       sub_program_id_type;
  child_proc_fail_exception   EXCEPTION;

BEGIN
  retcode         := '0';
  errbuf          := 'S';
  x_msg_count     := 0;
  x_msg_data      := ':';
  x_return_status := 'S';
  l_error_msg     := '';

   SELECT TO_CHAR(sysdate,'dd-mm-rr:hh:mi:ss') INTO l_time FROM dual;

  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: START l_time    ' || l_time );
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: x_org_id: ' || p_org_id);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: x_start_period_name: ' || p_start_period_name);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: x_end_period_name: ' || p_end_period_name);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: p_run_mode: ' || p_run_mode);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: p_no_of_workers: ' || p_no_of_workers);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: p_worker_id: ' || p_worker_id);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: p_batch_size: ' || p_batch_size);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: p_table_space: ' || p_table_space);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: g_cn_debug: ' || g_cn_debug);

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version , l_api_version , l_api_name , G_PKG_NAME ) THEN
    debugmsg('CN_PURGE_TABLES_PUB.purge_cn_tables api: Not Compatible_API_Call ');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( l_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_org_id is null) THEN
    l_error_msg       := 'p_org_id' || g_error_msg;
    debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
    fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
    fnd_message.set_token('FIELD','p_org_id');
    fnd_msg_pub.add;
    RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
  END IF;

  mo_global.set_policy_context('S',p_org_id);

  IF(p_start_period_name is null) THEN
    l_error_msg       := 'p_start_period_name' || g_error_msg;
    debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
    fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
    fnd_message.set_token('FIELD','p_start_period_name');
    fnd_msg_pub.add;
    RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
  END IF;

  IF(p_end_period_name is null) THEN
    l_error_msg       := 'p_end_period_name' || g_error_msg;
    debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
    fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
    fnd_message.set_token('FIELD','p_end_period_name');
    fnd_msg_pub.add;
    RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
  END IF;

  OPEN get_start_period_id;                         -- open the cursor
  FETCH get_start_period_id INTO l_start_period_id; -- fetch data into local variables
  CLOSE get_start_period_id;

  OPEN get_end_period_id;                       -- open the cursor
  FETCH get_end_period_id INTO l_end_period_id; -- fetch data into local variables
  CLOSE get_end_period_id;

  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_start_period_id: ' || l_start_period_id);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_end_period_id: ' || l_end_period_id);

    --Mandatory fields validation starts here
  IF(l_start_period_id = -1) THEN
    l_error_msg       := 'Start Period Id calculation error: Please enter proper values for p_start_period_name and p_org_d';
    debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
    fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
    fnd_message.set_token('FIELD','p_start_period_name');
    fnd_msg_pub.add;
    RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
  END IF;

  IF(l_end_period_id = -1) THEN
    l_error_msg       := 'End Period Id calculation error: Please enter proper values for p_end_period_name and p_org_d';
    debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
    fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
    fnd_message.set_token('FIELD','p_end_period_name');
    fnd_msg_pub.add;
    RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
  END IF;

  IF(p_run_mode <> 'A' and p_run_mode <> 'P') THEN
    l_error_msg       := 'p_run_mode' || g_error_msg;
    debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
    fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
    fnd_message.set_token('FIELD','p_run_mode');
    fnd_msg_pub.add;
    RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
  END IF;

  IF(p_run_mode = 'P') THEN
    IF(p_no_of_workers is null or p_no_of_workers < 1) THEN
      l_error_msg       := 'p_no_of_workers' || g_error_msg;
      debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
      fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
      fnd_message.set_token('FIELD','p_no_of_workers (Expected value between 1 and 10)');
      fnd_msg_pub.add;
      RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
    END IF;

    IF(p_worker_id is null  or p_worker_id <= 0) THEN
      l_error_msg       := 'p_worker_id' || g_error_msg;
      debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
      fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
      fnd_message.set_token('FIELD','p_worker_id (Expected value > 0)');
      fnd_msg_pub.add;
      RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
    END IF;

    IF(p_batch_size is null  or p_batch_size <= 0) THEN
      l_error_msg       := 'p_batch_size' || g_error_msg;
      debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: l_error_msg: ' || l_error_msg);
      fnd_message.set_name('CN', 'CN_AP_REQ_FIELD_NOT_SET_ERROR');
      fnd_message.set_token('FIELD','p_batch_size (Expected value > 0)');
      fnd_msg_pub.add;
      RAISE CN_PURGE_REQ_FIELD_NOT_SET_ER;
    END IF;
  END IF;

  IF(p_run_mode = 'P' and p_no_of_workers > 1) THEN



    CN_PURGE_TABLES_PVT.audit_purge_cn_tables ( p_run_mode => p_run_mode,
                    p_start_period_id => l_start_period_id,
                    p_end_period_id => l_end_period_id,
                    p_org_id => p_org_id,
                    p_worker_id => p_worker_id,
                    p_no_of_workers => p_no_of_workers,
                    p_batch_size => p_batch_size,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data,
                    x_return_status => x_return_status );

    l_child_program_id_tbl := sub_program_id_type();

    FOR idx in 1 ..  p_no_of_workers LOOP


       debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: Submit Worker number : ' || idx);

       l_req_id := FND_REQUEST.SUBMIT_REQUEST('CN', -- Application
                                       'CN_PURGE_PARALLEL'	  , -- Concurrent Program
                                       '', -- description
                                       '', -- start time
                                       FALSE -- sub request flag
                                      ,p_run_mode
                                      ,l_start_period_id
                                      ,l_end_period_id
                                      ,p_no_of_workers
                                      ,p_org_id
                                      ,'NONE'
                                      ,idx
                                      ,p_batch_size
                                      ,g_request_id
                                        );
      commit;

    debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: Submit Worker number : ' || idx || ' l_req_id : '
    || l_req_id);


       IF  l_req_id = 0 THEN
          retcode := 2;
          errbuf := fnd_message.get;
          raise child_proc_fail_exception;
       ELSE
          -- storing the request ids in an array
          l_child_program_id_tbl.EXTEND;
          l_child_program_id_tbl(l_child_program_id_tbl.LAST):=l_req_id;
       END IF;
     END LOOP;

     debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables:Parent Process starts Waiting For Purge
     Child Processes to complete');

     parent_conc_wait(l_child_program_id_tbl,retcode,errbuf);

     COMMIT;

 /*CN_PURGE_TABLES_PVT.archive_purge_cn_tables
  (
    errbuf             => errbuf,
    retcode            => retcode,
    p_run_mode          => p_run_mode,
    p_start_period_id => l_start_period_id,
    p_end_period_id   => l_end_period_id,
    p_no_of_workers     => p_no_of_workers,
    p_org_id            => p_org_id,
    p_table_space       => p_table_space,
    p_worker_id         => p_worker_id,
    p_batch_size        => p_batch_size,
    p_request_id        => g_request_id,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    x_return_status     => x_return_status) ;*/



 ELSE
     CN_PURGE_TABLES_PVT.archive_purge_cn_tables
      (
        errbuf             => errbuf,
        retcode            => retcode,
        p_run_mode          => p_run_mode,
        p_start_period_id => l_start_period_id,
        p_end_period_id   => l_end_period_id,
        p_no_of_workers     => p_no_of_workers,
        p_org_id            => p_org_id,
        p_table_space       => p_table_space,
        p_worker_id         => p_worker_id,
        p_batch_size        => p_batch_size,
        p_request_id        => g_request_id) ;
 END IF;
  SELECT TO_CHAR(sysdate,'dd-mm-rr:hh:mi:ss') INTO l_time FROM dual;

  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: x_msg_count: ' || x_msg_count);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: x_msg_data: ' || x_msg_data);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: x_return_status: ' || x_return_status);
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables: END l_time    ' || l_time );

  IF(x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


EXCEPTION
WHEN CN_PURGE_REQ_FIELD_NOT_SET_ER THEN
  x_return_status := 'F';
  retcode         := '-1';
  --errbuf          := l_error_msg;
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables:exception: CN_AIA_REQ_FIELD_NOT_SET_ERROR: ');
  FND_MSG_PUB.Count_And_Get
    (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
     );
     debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables:exception: x_msg_count: ' || x_msg_count);
     debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables:exception: x_msg_data: ' || x_msg_data);
  errbuf          := x_msg_data;
  --raise_application_error (-20001,l_error_msg);
WHEN OTHERS THEN
  ROLLBACK;
  retcode         := '-2';
  x_return_status := 'F';
  errbuf          := x_msg_data || ' :  ' || SQLERRM(SQLCODE());
  debugmsg('CN_PURGE_TABLES_PUB.archive_purge_cn_tables:exception others: ' ||  errbuf);
  --RAISE	FND_API.G_EXC_ERROR;
  raise_application_error (-20002,errbuf);
END archive_purge_cn_tables;

END CN_PURGE_TABLES_PUB;

/
