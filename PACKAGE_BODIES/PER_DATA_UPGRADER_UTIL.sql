--------------------------------------------------------
--  DDL for Package Body PER_DATA_UPGRADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DATA_UPGRADER_UTIL" AS
/* $Header: pedatupgutl.pkb 115.6 2003/09/26 03:32:53 mbocutt noship $ */

g_logging_level varchar2(80);
g_general_logging_level boolean;

-- ----------------------------------------------------------------------------
-- |----------------------------< getDebugState >-----------------------------|
-- ----------------------------------------------------------------------------
--
Function getLoggingState return varchar2 is

cursor c_get_debug is
       select parameter_value
         from pay_action_parameters
	where parameter_name = 'LOGGING';
l_logging_level varchar2(80);

BEGIN
  l_logging_level := g_logging_level;
  if l_logging_level is null then
    open c_get_debug;
    fetch c_get_debug into l_logging_level;
    if c_get_debug%NOTFOUND then
      g_logging_level := 'NONE';
      l_logging_level := g_logging_level;
      close c_get_debug;
    elsif    c_get_debug%FOUND
         and l_logging_level = 'G' then
      g_logging_level := l_logging_level;
      g_general_logging_level := TRUE;
      close c_get_debug;
    end if;
  end if;
  return l_logging_level;
END;

Procedure writeLog(p_text         in VARCHAR2
                  ,p_logging_type in VARCHAR2 default null
		  ,p_error        in BOOLEAN  default FALSE
		  ,p_location     in NUMBER   default 0) IS

l_logging_level varchar2(80);

BEGIN

  l_logging_level := getLoggingState();

  if p_error then
    fnd_file.put_line(FND_FILE.log, p_text);
    hr_utility.raise_error;
  end if;

  if     p_logging_type = 'G'
     and g_general_logging_level
  then
    fnd_file.put_line(FND_FILE.log, p_text);
--  else
--    fnd_file.put_line(FND_FILE.log, p_text);
  end if;


  hr_utility.set_location(p_text,10);
exception
  when others then
      if SQLCODE = -20100 then
        hr_utility.set_location(p_text,p_location);
      else
        raise;
      end if;
END;

-- ----------------------------------------------------------------------------
-- |----------------------------< upgradeChunk >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure upgradeChunk
   (p_this_worker_num   number
   ,p_total_num_workers number
   ,p_process_ctrl      varchar2
   ,p_table_owner       varchar2
   ,p_table_name        varchar2
   ,p_pkid_column       varchar2
   ,p_update_name       varchar2
   ,p_batch_size        number
   ,p_upg_proc          varchar2)
is

  l_start_pkid          number;
  l_end_pkid            number;
  l_rows_processed      number;
  l_any_rows_to_process boolean;
  l_restart             boolean;

  l_table_rowcount      number;
  l_min_id              number;
  l_max_id              number;

  l_plsql varchar2(1000);
begin

  l_plsql := 'select count(distinct '||p_pkid_column||'),
                     min('||p_pkid_column||'),
                     max('||p_pkid_column||')
                from '||p_table_name;


  execute immediate l_plsql into l_table_rowcount,
                                 l_min_id,
				 l_max_id;

  if l_table_rowcount > 2 * p_total_num_workers then
    /*
    ** Prepare the upgrade....
    */
    ad_parallel_updates_pkg.initialize_id_range(
         ad_parallel_updates_pkg.ID_RANGE,
         p_table_owner,
         p_table_name,
         p_update_name,
         p_pkid_column,
         p_this_worker_num,
         p_total_num_workers,
         p_batch_size,
         0 -- debug level
         );
    /*
    ** Get the initial range of IDs to process.
    */
    ad_parallel_updates_pkg.get_id_range(
         l_start_pkid,
         l_end_pkid,
         l_any_rows_to_process,
         p_batch_size,
         TRUE -- Restart flag
         );
    if l_any_rows_to_process then
      writeLog('Have got rows to process', 'G', FALSE, 10);
    else
      writeLog('Have got no rows to process', 'G', FALSE, 20);
    end if;
    /*
    ** Process the rows in the batch....
    */
    while (l_any_rows_to_process = TRUE)
    loop

      writeLog(p_this_worker_num||' processing range '||
                            l_start_pkid||'-'||l_end_pkid, 'G', FALSE, 30);
      /*
      ** Use dynamic SQL to process the batch of records.
      ** The procedure to call is identified in the parameter p_upg_proc.
      */
      l_plsql := 'begin '||p_upg_proc||'(:CTRL, :START, :END, :ROWCOUNT); end;';
      execute immediate l_plsql
              using p_process_ctrl,
  	            l_start_pkid,
		    l_end_pkid,
	        OUT l_rows_processed;
      /*
      ** Mark the batch of IDs as processed...
      */
      ad_parallel_updates_pkg.processed_id_range(
           l_rows_processed,
	   l_end_pkid);

      /*
      ** Commit the updates....
      */
      commit;

      /*
      ** Get the next range of IDs
      */
      ad_parallel_updates_pkg.get_id_range(
           l_start_pkid,
           l_end_pkid,
           l_any_rows_to_process,
           p_batch_size,
           FALSE -- Restart flag
	   );

    end loop;

  elsif l_min_id is not null and
        l_max_id is not null then
    /*
    ** The rowcount is less than twice the number of threads doing the
    ** work so don't use the AD large table update utilities instead
    ** do the call directly but only if this is the first worker.  This means
    ** the other threads should exit without doing anything.
    */
    if p_this_worker_num = 1 then
      l_plsql := 'begin '||p_upg_proc||'(:CTRL, :START, :END, :ROWCOUNT); end;';
      execute immediate l_plsql
              using p_process_ctrl,
  	            l_min_id,
		    l_max_id,
	        OUT l_rows_processed;
    end if;

  end if;

end upgradeChunk;

procedure submitUpgradeProcessControl(
                      errbuf    out nocopy varchar2,
                      retcode   out nocopy number,
		      p_process_to_call in varchar2,
		      p_upgrade_type    in varchar2,
		      p_action_parameter_group_id in varchar2,
		      p_process_ctrl    in varchar2,
		      p_param1          in varchar2,
		      p_param2          in varchar2,
		      p_param3          in varchar2,
		      p_param4          in varchar2,
		      p_param5          in varchar2,
		      p_param6          in varchar2,
		      p_param7          in varchar2,
		      p_param8          in varchar2,
		      p_param9          in varchar2,
		      p_param10         in varchar2
		      )

is

  l_action_parameter_group_id number := to_number(p_action_parameter_group_id);
  l_request_data      varchar2(100);
  l_number_of_threads number;
  l_request_id        number;
  user_exception      exception;

begin
--hr_utility.trace_on('F','LGEUPG');
  writeLog('Starting process', 'G', FALSE, 0);

--  raise user_exception;

  /*
  ** Get restart token....
  */
  writeLog('Step 1', 'G', FALSE, 0);
  l_request_data := fnd_conc_global.request_data;
  if l_request_data is not null then
    /*
    ** Performe restart processing.
    */
    writeLog('Performing Restart', 'G', FALSE, 0);
    return;
  end if;
  writeLog('Step 2', 'G', FALSE, 0);
  /*
  ** Obtain the number of THREADS to be used using the
  ** action group ID. If this is not set then use the default
  ** number of THREADS.
  */
  writeLog('Step 3', 'G', FALSE, 0);
  if l_action_parameter_group_Id is not null then
    writeLog('Step 4', 'G', FALSE, 0);
    pay_core_utils.set_pap_group_id(l_action_parameter_group_id);
  end if;
  writeLog('Step 5', 'G', FALSE, 0);

  begin
    select parameter_value
      into l_number_of_threads
      from pay_action_parameters
     where parameter_name = 'THREADS';
  exception
     when no_data_found then
        l_number_of_threads := 1;
     when others then
        raise;
  end;

  writeLog('Threads : '||to_char(l_number_of_threads), 'G', FALSE, 0);
  /*
  ** Submit 'l_number_of_threads' sub-requests to perform
  ** the process specified.
  */
  for counter in 1..l_number_of_threads loop
    writeLog('Submitting thread '||to_char(counter), 'G', FALSE, 0);
    l_request_id := fnd_request.submit_request(
                              application => 'PER',
			      program     => 'PERMTUPGWKR',
			      sub_request => TRUE,
			      argument1   => counter,
			      argument2   => l_number_of_threads,
			      argument3   => p_process_to_call,
			      argument4   => p_upgrade_type,
			      argument5   => p_process_ctrl,
			      argument6   => p_param1,
			      argument7   => p_param2,
			      argument8   => p_param3,
			      argument9   => p_param4,
			      argument10  => p_param5,
			      argument12  => p_param6,
			      argument13  => p_param7,
			      argument14  => p_param8,
			      argument15  => p_param9,
			      argument16  => p_param10,
			      argument17  => chr(0));
    writeLog('submitted request '||to_char(l_request_id), 'G', FALSE, 0);
  end loop;
  fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                  request_data => 'PERMTUPGCTL');
end;

procedure submitUpgradeProcessSingle(
                      errbuf    out nocopy varchar2,
                      retcode   out nocopy number,
		      p_process_number  in varchar2,
		      p_max_number_proc in varchar2,
		      p_process_to_call in varchar2,
		      p_upgrade_type    in varchar2,
		      p_process_ctrl    in varchar2,
		      p_param1          in varchar2,
		      p_param2          in varchar2,
		      p_param3          in varchar2,
		      p_param4          in varchar2,
		      p_param5          in varchar2,
		      p_param6          in varchar2,
		      p_param7          in varchar2,
		      p_param8          in varchar2,
		      p_param9          in varchar2,
		      p_param10         in varchar2
		      )

is
  l_plsql varchar2(1000);
begin

  writeLog('Starting process', 'G', FALSE, 10);
  /*
  ** Determine the type of upgrade script to call and call it.
  */
  if p_upgrade_type = 'AD_LGE_TBL_UPG' then
    /*
    ** Upgrade using the AD large table upgrade infrastructure.
    */
    writeLog('Doing large table update.', 'G', FALSE, 20);
    upgradeChunk(
       p_this_worker_num   => p_process_number,
       p_total_num_workers => p_max_number_proc,
       p_process_ctrl      => p_process_ctrl,
       p_table_owner       => p_param1,
       p_table_name        => p_param2,
       p_pkid_column       => p_param3,
       p_update_name       => p_param4,
       p_batch_size        => p_param5,
       p_upg_proc          => p_process_to_call);
  elsif p_upgrade_type = 'GEN_SCRIPT' then
    /*
    ** Upgrade using a generaic pacakge procedure call. Note called procedure
    ** must accept 12 varchar2 parameters as noted below in the call.
    */
    l_plsql := 'begin '||p_process_to_call||'(:proc_num, :max_num_proc,
               :param1, :param2, :param3, :param4, :param5, :param6,
	       :param7, :param8, :param9, :param10 ); end;';
    execute immediate l_plsql
            using p_process_number, p_max_number_proc,
	          p_param1, p_param2, p_param3, p_param4, p_param5,
		  p_param6, p_param7, p_param8, p_param9, p_param10;

  end if;
end;

end per_data_upgrader_util;

/
