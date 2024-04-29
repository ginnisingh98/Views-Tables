--------------------------------------------------------
--  DDL for Package Body WIP_INTERFACE_ERR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_INTERFACE_ERR_UTILS" as
/* $Header: wipieutb.pls 120.4 2006/09/04 06:39:09 panagara noship $ */

--- Added a new Autonomous procedure to insert errors into wip_interface_errors table.
--- This is added for bug 5124822

procedure     insert_error(p_interface_id        IN number,
                           p_error_type          IN Varchar2,
		           p_error               IN Varchar2,
		           p_last_update_date    IN Date,
                           p_creation_date       IN Date,
			   p_created_by          IN Number,
		           p_last_update_login   IN Number,
		           p_updated_by          IN Number);

-- End of bug fix 5124822


Procedure add_error(p_interface_id 	number,
		    p_text		varchar2,
		    p_error_type	number)  IS

  error_record request_error;
  error_type   number;

BEGIN

  error_record.interface_id := p_interface_id;
  error_record.error_type := p_error_type;
  error_record.error := substr(p_text,1,500);

  current_errors(current_errors.count+1) := error_record;

END add_error;

Procedure load_errors IS

  n_errors number;
  error_no number := 1;

  l_dummy2 VARCHAR2(1);
  l_logLevel number;
  l_last_update_login  number;
  l_last_updated_by    number;
  l_created_by         number;
  l_WJSI_error_exist   number;

BEGIN

  n_errors := current_errors.count;

  WHILE (error_no <= n_errors) LOOP
     l_logLevel := fnd_log.g_current_runtime_level;
     if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log('error:' || current_errors(error_no).error, l_dummy2);
     end if;
     -- Added the following stmt for bug fix 5124822
     -- selecting the audit column values from wip_job_schedule_interface
     -- and pass it to api that inserts into interface errors table.
     -- We cannot derive these values in insert_error api, as the insert_error api
     -- is autonomous transaction api.

    /* Fix for bug 5507379. Errors can be either in WJSI or in WJDI */
     l_WJSI_error_exist := WIP_CONSTANTS.YES;
     begin
       select last_update_login,
              last_updated_by,
	      created_by
       into   l_last_update_login,
              l_last_updated_by,
	      l_created_by
       from   wip_job_schedule_interface
       where  interface_id = current_errors(error_no).interface_id;
     exception
       when no_data_found then
           l_WJSI_error_exist := WIP_CONSTANTS.NO;
     end;

     if (l_WJSI_error_exist = WIP_CONSTANTS.NO) then
	select last_update_login,
              last_updated_by,
	      created_by
       into   l_last_update_login,
              l_last_updated_by,
	      l_created_by
       from   wip_job_dtls_interface
       where  interface_id = current_errors(error_no).interface_id;
     end if;


     -- Started calling a new autonomous transaction API to insert a record into
     -- interface error . This API will commit immediately after inserting into
     -- interface error table.

     insert_error(p_interface_id => current_errors(error_no).interface_id,
                  p_error_type   => current_errors(error_no).error_type,
	     	  p_error        => current_errors(error_no).error,
		  p_last_update_date => sysdate,
                  p_creation_date    => sysdate,
		  p_created_by       => l_created_by,
		  p_last_update_login => l_last_update_login,
		  p_updated_by        => l_last_updated_by);

     -- End of bug fix 5124822
     error_no := error_no + 1;

  END LOOP;

  /* bug 4650624, commit */
  --commit;

  current_errors.delete ;

  wip_logger.cleanup(l_dummy2);

 END load_errors;


 -- The following API is added for bug fix 5124822
 -- This API will insert a record into wip_interface_errors table
 -- and commit it immediately. But this is an autonomous transcation

 procedure     insert_error(p_interface_id        IN number,
                            p_error_type          IN Varchar2,
  		            p_error               IN Varchar2,
		            p_last_update_date    IN Date,
                            p_creation_date       IN Date,
			    p_created_by          IN Number,
		            p_last_update_login   IN Number,
		            p_updated_by          IN Number) is
 PRAGMA AUTONOMOUS_TRANSACTION;
 Begin
   insert into  wip_interface_errors
     (interface_id,
      error_type,
      error,
      last_update_date,
      creation_date,
      created_by,
      last_update_login,
      last_updated_by
    )
  Values
    (p_interface_id,
     p_error_type,
     p_error,
     p_last_update_date,
     p_creation_date,
     p_created_by,
     p_last_update_login,
     p_updated_by);


 commit;
 End insert_error;
END WIP_INTERFACE_ERR_Utils;

/
