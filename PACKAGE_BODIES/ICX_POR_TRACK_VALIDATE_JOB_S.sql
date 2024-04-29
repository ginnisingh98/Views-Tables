--------------------------------------------------------
--  DDL for Package Body ICX_POR_TRACK_VALIDATE_JOB_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_POR_TRACK_VALIDATE_JOB_S" as
/* $Header: ICXVALJB.pls 115.33 2004/03/31 21:43:36 vkartik ship $ */

g_error_message varchar2(1000) := '';

procedure Debug(p_message in varchar2) is
begin
  g_error_message := substr(g_error_message || p_message, 1000);
end;

-- changed by sudsubra
-- added p_loaded_header and p_failed_header
procedure update_job_status(p_jobno in number,
                            p_new_status in varchar2,
                            p_loaded_items in number,
                            p_failed_items in number,
			    p_loaded_price in number,
			    p_failed_price in number,
          p_loaded_header in number,
          p_failed_header in number,
                            p_user_id IN NUMBER) is
l_progress varchar2(10) := '000';
begin
  l_progress := '001';
  update icx_por_batch_jobs
  set    job_status = p_new_status,
         start_datetime = decode(p_new_status, 'RUNNING', sysdate, start_datetime),
         items_loaded = p_loaded_items,
         items_failed = p_failed_items,
         prices_loaded= p_loaded_price,
         prices_failed= p_failed_price,
         headers_loaded = p_loaded_header,
         headers_failed = p_failed_header,
         last_updated_by = p_user_id,
         last_update_date = sysdate
  where  job_number = p_jobno;

  l_progress := '002';
exception
  when others then
      Debug('[update_job_status-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_track_validate_job_s.update_job_status(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
end;

FUNCTION create_job(p_supplier_id IN NUMBER,
                    p_supplier_file IN VARCHAR2,
                    p_exchange_file IN VARCHAR2,
                    p_host_ip_address IN VARCHAR2,
                    p_exchange_operator_id IN NUMBER,
                    p_job_type IN VARCHAR2,
                    p_max_failed_lines IN NUMBER,
                    p_user_id IN NUMBER,
                    p_timezone IN VARCHAR2) RETURN NUMBER IS
  l_progress varchar2(10) := '000';
  l_jobno number;
begin

  l_progress := '001';
  select icx_por_batch_jobs_s.nextval
  into   l_jobno
  from   sys.dual;

  l_progress := '002';
  insert into icx_por_batch_jobs (
    job_number,
    request_id,
    supplier_id,
    supplier_file_name,
    exchange_file_name,
    items_loaded,
    items_failed,
    job_status,
    submission_datetime,
    start_datetime,
    completion_datetime,
    failure_message,
    host_ip_address,
    exchange_operator_id,
    job_type,
    max_failed_lines,
    timezone,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date)
  values (
    l_jobno,
    l_jobno,
    p_supplier_id,
    p_supplier_file,
    p_exchange_file,
    0,
    0,
    'PENDING',
    sysdate,
    null,
    null,
    null,
    p_host_ip_address,
    p_exchange_operator_id,
    p_job_type,
    p_max_failed_lines,
    p_timezone,
    p_user_id,
    sysdate,
    p_user_id,
    sysdate
  );

  l_progress := '003';
  return l_jobno;

exception
  when others then
      Debug('[create_job-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_track_validate_job_s.create_job(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END create_job;

FUNCTION create_job(p_supplier_id IN NUMBER,
                    p_supplier_file IN VARCHAR2,
                    p_exchange_file IN VARCHAR2,
                    p_host_ip_address IN VARCHAR2,
                    p_exchange_operator_id IN NUMBER,
                    p_job_type IN VARCHAR2,
                    p_max_failed_lines IN NUMBER) RETURN NUMBER IS
  l_progress varchar2(10) := '000';
  l_jobno number;
begin

  l_progress := '001';
  select icx_por_batch_jobs_s.nextval
  into   l_jobno
  from   sys.dual;

  l_progress := '002';
  insert into icx_por_batch_jobs (
    job_number,
    request_id,
    supplier_id,
    supplier_file_name,
    exchange_file_name,
    items_loaded,
    items_failed,
    job_status,
    submission_datetime,
    start_datetime,
    completion_datetime,
    failure_message,
    host_ip_address,
    job_type
    )
  values (
    l_jobno,
    l_jobno,
    p_supplier_id,
    p_supplier_file,
    p_exchange_file,
    0,
    0,
    'PENDING',
    sysdate,
    null,
    null,
    null,
    p_host_ip_address,
    p_job_type
  );

  l_progress := '003';
  return l_jobno;

exception
  when others then
      Debug('[create_job-'||l_progress||'] '||SQLERRM);
      RAISE_APPLICATION_ERROR
            (-20000, 'Exception at icx_por_track_validate_job_s.create_job(ErrLoc = ' || l_progress ||') ' ||
             'SQL Error : ' || SQLERRM);
END create_job;

FUNCTION  delete_job(p_jobno in number) return varchar2 is
BEGIN
        DELETE FROM ICX_POR_BATCH_JOBS WHERE JOB_NUMBER = p_jobno;
        DELETE FROM ICX_POR_FAILED_LINES WHERE JOB_NUMBER = p_jobno;
        DELETE FROM ICX_POR_FAILED_LINE_MESSAGES WHERE JOB_NUMBER = p_jobno;
        COMMIT;
        return 'Y';

EXCEPTION
        when others then
          return 'N';


END delete_job;

/*
 * Procedure to insert the debug message into
 * FND_LOG_MESSAGES table using the AOL API.
 * @param p_debug_message debug message
 * @param p_log_type log types
                    LOADER: Logs into the loader log file using the fnd apis
                    CONCURRENT: Logs into the concurrent mgr log using the
                                ICX_POR_EXT_UTIL package
 */
PROCEDURE log(p_debug_message VARCHAR2,
              p_log_type VARCHAR2 DEFAULT 'LOADER' ) is

l_size     NUMBER := 2000;
l_debug_msg_length  NUMBER := LENGTH(p_debug_message);
l_debug_msg VARCHAR2(20000) := p_debug_message;
l_start NUMBER := 0;
xErrLoc PLS_INTEGER := 100;

BEGIN

 /*Insert the Debug string */
 IF p_log_type = 'LOADER' THEN
   WHILE l_start < l_debug_msg_length LOOP
      l_start := l_start + l_size;
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
        g_module_name,
        substrb(l_debug_msg,1,l_size));
      l_debug_msg := substrb(l_debug_msg,l_size+1);
   END LOOP;
 ELSE
   ICX_POR_EXT_UTL.debug(l_debug_msg);
 END IF;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;
      if p_log_type <> 'LOADER' THEN
        ICX_POR_EXT_UTL.closeLog;
      end if;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at icx_por_track_validate_job_s.log(' || xErrLoc || '): ' || SQLERRM);
END log;


/* Procedure to set the debug channel*/
PROCEDURE set_debug_channel(p_debug_channel number default 0) is
BEGIN
  IF p_debug_channel=1 THEN
    g_debug_channel := true;
  ELSE
    g_debug_channel :=false;
  END IF;
END set_debug_channel;

PROCEDURE init_fnd_debug(p_request_id number) is
xErrLoc PLS_INTEGER := 100;
BEGIN
  IF g_debug_channel THEN
    g_request_id :=  p_request_id;
    g_module_name:=
       'ICX.PLSQL.LOADER.'|| g_request_id;
    fnd_global.apps_initialize(1318, 10001, 178);
    fnd_profile.put('AFLOG_ENABLED', 'Y');
    fnd_profile.put('AFLOG_MODULE', g_module_name);
    fnd_profile.put('AFLOG_LEVEL', '1');
    fnd_profile.put('AFLOG_FILENAME', '');
    fnd_log_repository.init;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      ROLLBACK;

      RAISE_APPLICATION_ERROR(-20000,
        'Exception at icx_por_track_validate_job_s.init_fnd_debug('
        || xErrLoc || '): ' || SQLERRM);
END init_fnd_debug;

end icx_por_track_validate_job_s;

/
