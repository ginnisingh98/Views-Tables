--------------------------------------------------------
--  DDL for Package Body FND_CONC_QUEUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_QUEUES_PKG" as
/* $Header: AFCPFCQB.pls 115.1 99/07/16 23:10:49 porting sh $ */

function check_deletability (qid   in number,
			     appid in number,
			     qname in varchar2)
	    		     return boolean is

  dummy		number;
  icm_error	exception;
  crm_error	exception;
  in_use	exception;

begin
  if ((qid = 1) and (appid = 0)) then
    raise icm_error;
  end if;

  if ((qid = 4) and (appid = 0)) then
    raise crm_error;
  end if;

  select 1
    into dummy
    from fnd_concurrent_queues fcq,
         fnd_concurrent_processes fcp
   where ((fcq.application_id = appid and
	   fcq.concurrent_queue_id = qid and
	   fcq.max_processes > 0)
	  or
	  (fcp.queue_application_id = appid and
	   fcp.concurrent_queue_id  = qid and
	   fcp.process_status_code in ('A', 'R', 'T')))
     and rownum = 1;

  raise in_use;

  exception
    when no_data_found then
      return (TRUE);
    when icm_error then
      fnd_message.set_name ('FND', 'CONC-Cannot update ICM defn');
      return (FALSE);
    when crm_error then
      fnd_message.set_name ('FND', 'CONC-Cannot delete CRM');
      return (FALSE);
    when in_use then
      fnd_message.set_name ('FND', 'CONC-Delete Manager');
      fnd_message.set_token ('MANAGER', qname, FALSE);
      return (FALSE);
    when others then
      fnd_message.set_name ('FND', 'CP-Generic oracle error');
      fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
      fnd_message.set_token ('ROUTINE', 'check_deletability', FALSE);
      return (FALSE);
end check_deletability;


procedure check_unique_queue	(ro_id	in varchar2,
				 appid	in number,
				 qname	in varchar2,
                                 uqname in varchar2) is
  dummy number;
begin
  begin
    select 1
      into dummy
      from sys.dual
     where not exists (select 1
	  	       from fnd_concurrent_queues_vl
		        where application_id = appid
		          and concurrent_queue_name = qname
		          and (row_id <> chartorowid (ro_id)
			       or ro_id is null));

  exception
    when no_data_found then
      fnd_message.set_name ('FND', 'CONC-Duplicate Manager SN');
      app_exception.raise_exception;
    when others then
      fnd_message.set_name ('FND', 'CP-Generic oracle error');
      fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
      fnd_message.set_token ('ROUTINE', 'check_unique_queue', FALSE);
      app_exception.raise_exception;
  end;

  begin
    select 1
      into dummy
      from sys.dual
     where not exists (select 1
	  	       from fnd_concurrent_queues_vl
		        where application_id = appid
		          and user_concurrent_queue_name = uqname
		          and (row_id <> chartorowid (ro_id)
			       or ro_id is null));

    exception
      when no_data_found then
        fnd_message.set_name ('FND', 'CONC-Duplicate Manager');
        app_exception.raise_exception;
    when others then
      fnd_message.set_name ('FND', 'CP-Generic oracle error');
      fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
      fnd_message.set_token ('ROUTINE', 'check_unique_queue', FALSE);
      app_exception.raise_exception;
  end;

end check_unique_queue;


procedure check_unique_wkshift (appid	in number,
				qid	in number,
				ro_id	in varchar2,
				pappid	in number,
				tpid	in number) is
  dummy number;
begin
  select 1
    into dummy
    from sys.dual
   where not exists (select 1
		       from fnd_concurrent_queue_size
		      where queue_application_id = appid
			and concurrent_queue_id = qid
			and period_application_id = pappid
			and concurrent_time_period_id = tpid
			and (rowid <> chartorowid (ro_id)
			     or ro_id is null));

  exception
    when no_data_found then
      fnd_message.set_name ('FND', 'CONC-Duplicate period name');
      app_exception.raise_exception;
    when others then
      fnd_message.set_name ('FND', 'CP-Generic oracle error');
      fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
      fnd_message.set_token ('ROUTINE', 'check_unique_wkshift', FALSE);
      app_exception.raise_exception;
end check_unique_wkshift;


procedure check_conflicts (iflag  in varchar2,
			   qid    in number,
			   qappid in number,
			   tcode  in varchar2,
			   tid    in number,
			   tappid in number,
			   ro_id  in varchar2) is

  conflict_checker	char;
  duplicate_error	exception;
  conflict_error	exception;

begin
  select include_flag
    into conflict_checker
    from fnd_concurrent_queue_content
   where queue_application_id = qappid
     and concurrent_queue_id = qid
     and type_code = tcode
     and (type_application_id = tappid
          or (type_application_id is null
              and tappid is null))
     and (type_id = tid
          or (type_id is null
	      and tid is null))
     and (rowid <> chartorowid (ro_id)
          or ro_id is null);

  if (conflict_checker = iflag) then
    raise duplicate_error;
  else
    raise conflict_error;
  end if;

  exception
    when no_data_found then
      null;
    when duplicate_error then
      fnd_message.set_name ('FND', 'CONC-Duplicate specialization');
      app_exception.raise_exception;
    when conflict_error then
      fnd_message.set_name ('FND', 'CONC-Conflicting specializatin');
      app_exception.raise_exception;
    when others then
      fnd_message.set_name ('FND', 'CP-Generic oracle error');
      fnd_message.set_token ('ERROR', substr (sqlerrm, 1, 30), FALSE);
      fnd_message.set_token ('ROUTINE', 'check_deletability', FALSE);
      app_exception.raise_exception;
end check_conflicts;

end FND_CONC_QUEUES_PKG;

/
