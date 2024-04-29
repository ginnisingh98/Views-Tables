--------------------------------------------------------
--  DDL for Package Body MSD_SRP_SSL_RS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_SRP_SSL_RS" as
/* $Header: msdsrprunrsb.pls 120.0 2007/11/07 10:24:40 vrepaka noship $ */

procedure run_rs(errbuf             out nocopy varchar2,
                 retcode             out nocopy number,
								 instance number,
								 file_seperator varchar,
								 control_path varchar2,
								 data_path varchar2,
								 file_name varchar2)

is

l_success boolean := false;
l_submit_failed exception;
l_req_id number;

begin

      l_success := fnd_submit.set_request_set('MSD','MSDSRPFFLD');
      if not l_success then
        raise l_submit_failed;
      end if;

   if instr(file_name,'InstallBaseHistory') > 0 then
      l_success := fnd_submit.submit_program('MSD','MSDSRPLD','STAGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                              null, null, null, null, null, null, null, null, null, null,null,1,file_name);
      if not l_success then
        raise l_submit_failed;
      end if;
      l_success := fnd_submit.submit_program('MSD','MSDSRPPP','STAGE20',instance,1);
      if not l_success then
        raise l_submit_failed;
      end if;
   end if;

    IF instr(file_name,'FldSerUsgHist')>0 THEN
      l_success := fnd_submit.submit_program('MSD','MSDSRPLD','STAGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                             null, null, null, null, null, null, null, null, null, null,null,1,null,file_name);
   	if not l_success then
          raise l_submit_failed;
        end if;
      l_success := fnd_submit.submit_program('MSD','MSDSRPPP','STAGE20',instance,2);
   	if not l_success then
          raise l_submit_failed;
        end if;
    end if;

    IF instr(file_name,'DptRepUsgHist')>0 THEN
      l_success := fnd_submit.submit_program('MSD','MSDSRPLD','STAGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                              null, null, null, null, null, null, null, null, null, null,null,1,null,null,file_name);
        if not l_success then
          raise l_submit_failed;
        end if;
      l_success := fnd_submit.submit_program('MSD','MSDSRPPP','STAGE20',instance,3);
        if not l_success then
          raise l_submit_failed;
        end if;
    end if;

    IF instr(file_name,'SerPartRetHist')>0 THEN
      l_success := fnd_submit.submit_program('MSD','MSDSRPLD','STAGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                              null, null, null, null, null, null, null, null, null, null,null,1,null,null,null,file_name);
   	if not l_success then
          raise l_submit_failed;
        end if;
      l_success := fnd_submit.submit_program('MSD','MSDSRPPP','STAGE20',instance,4);
   	if not l_success then
          raise l_submit_failed;
        end if;
    end if;

    IF instr(file_name,'FailureRates')>0 THEN
      l_success := fnd_submit.submit_program('MSD','MSDSRPLD','STAGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                              null, null, null, null, null, null, null, null, null, null,null,1,null,null,null,null,file_name);
   	if not l_success then
          raise l_submit_failed;
        end if;
      l_success := fnd_submit.submit_program('MSD','MSDSRPPP','STAGE20',instance,5);
      if not l_success then
          raise l_submit_failed;
       end if;
    end if;

    IF instr(file_name,'PrdRetHist')>0 THEN
      l_success := fnd_submit.submit_program('MSD','MSDSRPLD','STAGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                             null, null, null, null, null, null, null, null, null, null,null,1,null,null,null,null,null,file_name);
  	if not l_success then
          raise l_submit_failed;
        end if;
      l_success := fnd_submit.submit_program('MSD','MSDSRPPP','STAGE20',instance,6);
  	if not l_success then
          raise l_submit_failed;
        end if;
    end if;

    IF instr(file_name,'ForecastData')>0 THEN
      l_success := fnd_submit.submit_program('MSD','MSDSRPLD','STAGE10', instance, 1440, file_seperator, control_path, data_path, 3, null,null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
                                              null, null, null, null, null, null, null, null, null, null,null,1,null,null,null,null,null,null,file_name);
   	if not l_success then
          raise l_submit_failed;
        end if;
        l_success := fnd_submit.submit_program('MSD','MSDSRPPP','STAGE20',instance,7);
   	if not l_success then
          raise l_submit_failed;
        end if;

    end if;

    l_req_id := fnd_submit.submit_set(NULL,FALSE);
    commit;

    retcode := 0;
    exception
      	when l_submit_failed then
           errbuf  := 'Launching Request Set failed for SRP Streams';
           msd_dem_common_utilities.log_message(errbuf);
           msd_dem_common_utilities.log_debug(errbuf);
           retcode := -1;
         when others then
           errbuf  := substr(SQLERRM,1,150);
           msd_dem_common_utilities.log_message(errbuf);
           msd_dem_common_utilities.log_debug(errbuf);
           retcode := -1;

end;

end msd_srp_ssl_rs;



/
