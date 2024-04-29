--------------------------------------------------------
--  DDL for Package Body FND_DIAG_CM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DIAG_CM" as
/* $Header: AFCPDCMB.pls 120.3 2006/02/15 02:12:37 pbasha noship $ */

--
-- Procedure
--   DIAG_SQL_PROG
--
-- Purpose
--   Simple PL/SQL stored procedure concurrent program. Will sleep and exit.
--
-- Arguments:
--        IN:
--           SLEEPT  - number of seconds to sleep (default is 20)
--           PROGNM  - name of this program, written to logfile for tagging
--       OUT:
--           ERRBUF  - standard CP output
--           RETCODE - 0 if successful
--
procedure diag_sql_prog(ERRBUF OUT NOCOPY VARCHAR2,
		   RETCODE OUT NOCOPY NUMBER,
		   SLEEPT  IN NUMBER DEFAULT 20,
	           PROGNM  IN VARCHAR2 DEFAULT null)
is
begin
	fnd_file.put_line(fnd_file.log, PROGNM || ' test program:');
	fnd_file.put_line(fnd_file.log, 'Sleep for ' || SLEEPT || ' seconds.');
	DBMS_LOCK.SLEEP(SLEEPT);
	fnd_file.put_line(fnd_file.log, 'Awake and exiting.');
	retcode := 0;
exception
	when others then
	retcode := 2;
end diag_sql_prog;

--
-- Procedure
--   DIAG_CRM
--
-- Purpose
--   Test Conflict Resolution Manager. Will submit multiple incompatible
--   requests for various conflict domains to determine if any incompatible
--   programs are being incorrectly released to run.
--
-- Arguments:
--        IN:
--           VOLREQ  - number of requests to submit (default is 100)
--           NUMDOM  - number of different domains to use (default is 10)
--       OUT:
--           ERRBUF  - standard CP output
--           RETCODE - 0 if successful, 1 if CRM has been found to have error
--
procedure diag_crm(ERRBUF OUT NOCOPY VARCHAR2,
		   RETCODE OUT NOCOPY NUMBER,
		   VOLREQ  IN NUMBER DEFAULT 100,
	           NUMDOM  IN NUMBER DEFAULT 10)
is
CURSOR con_cursor(parrqid NUMBER, apid NUMBER, bpid NUMBER, cpid NUMBER) IS
    select a.request_id rqa, b.request_id rqb
	from fnd_concurrent_requests a, fnd_concurrent_requests b
	where a.PARENT_REQUEST_ID = parrqid
	  and b.PARENT_REQUEST_ID = parrqid
	  and (a.CRM_RELEASE_DATE < b.actual_COMPLETION_DATE and
		a.actual_completion_date > b.actual_start_date)
          and ((a.concurrent_PROGRAM_ID = apid
                and b.concurrent_PROGRAM_ID = cpid)
               or
	       (b.concurrent_PROGRAM_ID = apid
	        and a.concurrent_PROGRAM_ID = cpid)
               or
	       (a.cd_id = b.cd_id
	        and ((a.concurrent_PROGRAM_ID = apid
                      and b.concurrent_PROGRAM_ID = bpid)
                     or
	             (a.concurrent_PROGRAM_ID = bpid
	              and b.concurrent_PROGRAM_ID = apid))));

rdata varchar2(10);
rand number;
tdom number;
rqid number;
spid number;
apid number;
bpid number;
cpid number;
base number := 50;
i number := 1;
tot number := 0;
   begin

	rqid := FND_GLOBAL.CONC_REQUEST_ID;
	rdata := fnd_conc_global.request_data;

	if(rdata is null) then
	rdata := 'YOHO';

/* Submit Random requests */
	fnd_file.put_line(fnd_file.log, VOLREQ || ' requests.');
	fnd_file.put_line(fnd_file.log, NUMDOM || ' domains.');

	DBMS_RANDOM.INITIALIZE(rqid);

	base := base - (NUMDOM / 2);


	FOR i IN 1..VOLREQ
	LOOP
	rand := DBMS_RANDOM.VALUE(1,4);
	rand := TRUNC(rand);
	tdom := DBMS_RANDOM.VALUE(1,NUMDOM);
	tdom := ROUND(tdom);
	tdom := tdom + TRUNC(base);
	if (i < 4) then rand := i;
	end if;
	if (rand = 1) then
	spid := fnd_request.submit_request(application => 'FND',
					  program => 'FNDCRMTA',
					  sub_request => true,
					argument1 => to_char(tdom),
					argument2 => 'A');
	elsif (rand = 2) then
	spid := fnd_request.submit_request(application => 'FND',
					  program => 'FNDCRMTB',
					  sub_request => true,
					argument1 => to_char(tdom),
					argument2 => 'B');
	else
	spid := fnd_request.submit_request(application => 'FND',
					  program => 'FNDCRMTC',
					  sub_request => true,
					argument1 => to_char(tdom),
					argument2 => 'C');
	end if;
	if (spid = 0) then
	 fnd_file.put_line(fnd_file.log, 'Error in request submission');
	end if;
	END LOOP;

/* Wait for them to complete */

	fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
					request_data => rdata);
	errbuf := 'Sub Requests Submitted.';
	retcode := 0;

	else

/* Check for Conflicts */

select concurrent_program_id
  into apid
  from fnd_concurrent_programs p,fnd_application a
 where a.application_id = p.application_id and p.concurrent_program_name = 'FNDCRMTA' and a.application_short_name='FND';

select concurrent_program_id
  into bpid
  from fnd_concurrent_programs p,fnd_application a
 where a.application_id=p.application_id and p.concurrent_program_name = 'FNDCRMTB' and a.application_short_name='FND';

select concurrent_program_id
  into cpid
  from fnd_concurrent_programs p,fnd_application a
 where a.application_id = p.application_id and p.concurrent_program_name = 'FNDCRMTC' and a.application_short_name='FND';

	FOR con_rec in con_cursor(rqid, apid, bpid, cpid) LOOP
	  fnd_file.put_line(fnd_file.output,
	   'Collision between ' || con_rec.rqa || ' and ' || con_rec.rqb);
	  tot := tot+1;
	END LOOP;

	errbuf := tot || ' collisions detected.';
	if (tot = 0) then
	  retcode := 0;
	else
	  retcode := 1;
	end if;

	fnd_file.put_line(fnd_file.output, errbuf);
	end if;
end diag_crm;

end fnd_diag_cm;

/
