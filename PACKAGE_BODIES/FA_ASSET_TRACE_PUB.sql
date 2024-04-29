--------------------------------------------------------
--  DDL for Package Body FA_ASSET_TRACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_ASSET_TRACE_PUB" AS
/* $Header: faxtrcpb.pls 120.0.12010000.3 2009/07/19 08:21:10 glchen noship $
 * */

PROCEDURE hook_back;

g_options_tbl       t_options_tbl;
g_schema            VARCHAR2(50);
--
--
PROCEDURE run_trace (p_opt_tbl        IN     t_options_tbl,
                     p_exc_tbl        IN     t_excl_tbl,
                     p_tdyn_head      IN     VARCHAR2,
                     p_stmt           IN     VARCHAR2,
                     p_sys_opt_tbl    IN     VARCHAR2 DEFAULT NULL,
                     p_use_utl_file   IN     VARCHAR2 DEFAULT 'N',
                     p_debug_flag     IN     BOOLEAN,
                     p_calling_prog   IN     VARCHAR2,
                     p_retcode        OUT NOCOPY NUMBER,
                     p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

   l_calling_fn      varchar2(40) := 'fa_asset_trace_pub.run_trace';

   error_found1      EXCEPTION;
   error_found2      EXCEPTION;

BEGIN

   FA_ASSET_TRACE_PVT.initialize_globals (p_opt_tbl    => p_opt_tbl,
                                          p_exc_tbl    => p_exc_tbl,
					                                p_schema     => g_schema,
                                          p_debug_flag => p_debug_flag);
   if (p_stmt is not null) then
     do_top_section (p_tdyn_head => p_tdyn_head,
                     p_stmt      => p_stmt);
   end if;

   FA_ASSET_TRACE_PVT.do_primary;
   hook_back;

   if (p_sys_opt_tbl is not null) then
     FA_ASSET_TRACE_PVT.get_system_options (p_sys_opt_tbl);
   end if;

   FA_ASSET_TRACE_PVT.save_output (p_calling_prog, p_use_utl_file);

   p_retcode := 0;

EXCEPTION
   WHEN ERROR_FOUND1 THEN
        LOG(l_calling_fn, 'ERROR_FOUND1 Exception');
        p_retcode :=2;
   WHEN OTHERS THEN
        LOG(l_calling_fn, 'OTHERS Exception');
        p_retcode :=2;
		raise;

END run_trace;
--
PROCEDURE wait_for_req is

  l_phase           varchar2(2000);
  l_status          varchar2(2000);
  l_dev_phase       varchar2(2000);
  l_dev_status      varchar2(2000);
  l_message         varchar2(2000);
  l_request_id      number := 0;
  l_req_status      boolean;

  l_calling_fn      varchar2(40)  := 'fa_asset_trace_pub.wait_for_req';

BEGIN
  if g_req_tbl.count > 1 then
    FOR i IN g_req_tbl.first .. g_req_tbl.last LOOP
      l_request_id := g_req_tbl(i);
      if l_request_id not in (0,-1) then
        log(l_calling_fn,'Waiting for request '||to_char(l_request_id));
        while (FND_CONCURRENT.CHILDREN_DONE(Parent_Request_ID => l_request_id,
                                            Interval          => 20,
                                            Max_Wait          => 120) = FALSE) loop
           LOG(l_calling_fn, 'Waiting for all sub-requests to complete.');
        end loop; --children_done

        LOOP
          l_req_status := FND_CONCURRENT.wait_for_request(
                            request_id => l_request_id, interval  => 60,
                            max_wait   => 60,           phase     => l_phase,
                            status     => l_status,     dev_phase => l_dev_phase,
                            dev_status => l_dev_status, message   => l_message);
          IF (l_dev_phase = 'COMPLETE') THEN
            EXIT;
          END IF;
        END LOOP;
        log(l_calling_fn,'Done waiting.  finished with status '||l_status);
      else
        dbms_lock.sleep(90);
      end if; --l_request_id
      g_req_tbl.delete(i);
    END LOOP; --FOR i IN g_req_tbl.first...
  else
     g_req_tbl.delete(1);
     log(l_calling_fn, 'Not waiting.');
  end if;

EXCEPTION
   WHEN OTHERS THEN
        LOG(l_calling_fn, 'Error');
        raise;

END wait_for_req;
--
--Set banner area content
--
PROCEDURE set_temp_head (p_temp_head      IN  VARCHAR2,
                         p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

  l_calling_fn      varchar2(40)  := 'fa_asset_trace_pub.set_temp_head';

BEGIN

  FA_ASSET_TRACE_PVT.g_temp_head := p_temp_head;

EXCEPTION
   WHEN OTHERS THEN
       LOG(l_calling_fn, 'Error');
       raise;

END set_temp_head;
--
--Used to call any special case code from calling apps.
--
PROCEDURE hook_back IS

  l_calling_fn      varchar2(40)  := 'fa_asset_trace_pub.hook_back';

BEGIN

  --Add any hooks here
  null;

EXCEPTION
   WHEN OTHERS THEN
        LOG(l_calling_fn, 'Error');
        raise;

END hook_back;
--
PROCEDURE do_top_section (p_tdyn_head      IN VARCHAR2,
                          p_stmt           IN VARCHAR2,
                          p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

  l_calling_fn      varchar2(40)  := 'fa_asset_trace_pub.do_top_section';
BEGIN

  FA_ASSET_TRACE_PVT.g_dyn_head := p_tdyn_head;

  FA_ASSET_TRACE_PVT.exec_sql (p_table      => 'NO_ANCHOR',
                               p_sel_clause => NULL,
                               p_stmt       => p_stmt,
                               p_schema     => 'NONE');
EXCEPTION
   WHEN OTHERS THEN
        LOG(l_calling_fn, 'Error');
        raise;

END do_top_section;
--
FUNCTION start_queue (p_qtable         IN  varchar2,
                      p_qpayload_type  IN  varchar2,
                      p_qname          IN  varchar2) RETURN VARCHAR2 IS

  l_ret_val    varchar2(3);

  qtblexists   exception;
  pragma       exception_init(qtblexists, -24001);
  qexists      exception;
  pragma       exception_init(qexists, -24006);

BEGIN

   BEGIN
      DBMS_AQADM.CREATE_QUEUE_TABLE (queue_table        => p_qtable,
                                     multiple_consumers => TRUE,
        	                           queue_payload_type => p_qpayload_type,
        	                           compatible         => '8.1');
      DBMS_AQADM.CREATE_QUEUE (queue_name  => p_qname,
        	                     queue_table => p_qtable,
        	                     max_retries => 2);
      DBMS_AQADM.START_QUEUE (queue_name => p_qname);
   EXCEPTION
      WHEN qtblexists THEN
        l_ret_val := 'TE'; --Table Exists
      WHEN qexists THEN
        l_ret_val := 'QE'; --Queue Exists
      WHEN others THEN
        l_ret_val := 'F'; --Some other failure
   END; --Annonymous

   IF l_ret_val IS NULL THEN
     l_ret_val := 'S'; --Success
   END IF;
   RETURN l_ret_val;

EXCEPTION
  WHEN OTHERS THEN
    log('start_queue','Unspecified Error');

END start_queue;
--
FUNCTION add_subscriber (p_qname       IN  varchar2,
                         p_subscriber  IN  varchar2,
                         p_sub_rule    IN  varchar2) RETURN BOOLEAN IS

  l_subscriber sys.aq$_agent;
  sub_exists   exception;
  pragma       exception_init(sub_exists, -24034);

BEGIN
   l_subscriber := sys.aq$_agent(p_subscriber, p_qname, null);
   dbms_aqadm.add_subscriber (queue_name => p_qname,
                              subscriber => l_subscriber,
                              rule       => p_sub_rule);
   RETURN TRUE;

EXCEPTION
   WHEN sub_exists THEN
     RETURN TRUE;
   WHEN OTHERS THEN
     log('add_subscriber','Unspecified Error');
     raise;

END add_subscriber;
--
FUNCTION drop_queue (p_qtable IN varchar2) RETURN BOOLEAN IS

  qnotthere    exception;
  pragma       exception_init(qnotthere, -24010);

BEGIN
  DBMS_AQADM.DROP_QUEUE_TABLE(queue_table => p_qtable, force => TRUE);

EXCEPTION
   WHEN qnotthere THEN
     RETURN TRUE;
   WHEN OTHERS THEN
     log('drop_queue','Unspecified Error');
END drop_queue;
--
--Write to log
--
PROCEDURE log(p_calling_fn     IN  VARCHAR2,
              p_msg            IN  VARCHAR2 default null,
              p_log_level_rec  IN  FA_API_TYPES.log_level_rec_type default null) IS

BEGIN

  FA_ASSET_TRACE_PVT.LOG(p_calling_fn,p_msg);

EXCEPTION
  When Others Then Raise;

END log;

--
END FA_ASSET_TRACE_PUB;

/
