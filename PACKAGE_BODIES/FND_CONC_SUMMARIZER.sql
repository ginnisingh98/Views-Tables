--------------------------------------------------------
--  DDL for Package Body FND_CONC_SUMMARIZER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_SUMMARIZER" as
/* $Header: AFCPSUMB.pls 120.2 2006/02/02 16:22:16 vvengala noship $ */

-- Declare a record type to contain name value pair
TYPE sum_record_type is RECORD
	(name varchar2(2000),
	value number);

-- Declare a PL SQL table type having rows of the record type
TYPE sum_table_type is TABLE of sum_record_type
	index by binary_integer;

-- P_SUMMARIZER is a PL SQL table
P_SUMMARIZERS sum_table_type;
P_COUNT number := 0;

--
-- Function
--   prepare_str
-- Purpose
--   Return varchar of name || '=' || value || ';'
-- Arguments
--   Name  varchar2 name of the string
--   value varchar2 value of the name
-- Returns
--   varchar2
--

function prepare_string(name in varchar2,
			value in varchar2) return varchar2
is
begin
	return name || '=' || value || ';';
end;

--
-- Function
--   execute_summarizer
-- Purpose
--   Executes the summarizer procedure provided as an argument
--   and return varchar of ';' separated name=value pairs
-- Arguments
--   sum_proc varchar2 Name of Summarizer Procedure
-- Notes
--   Return varchar2.
--

function execute_summarizer(sum_proc varchar2)
	return varchar2
is
	empty_sum_array sum_table_type;
	return_str varchar2(10000) := '';
	str        varchar2(100);
	name 	   varchar2(2000);
	value      number;
begin
	-- Initialize table count
	P_COUNT := 0;

	-- Initialize pl/sql table so that it will clear the previous table contents
	P_SUMMARIZERS := empty_sum_array;

	-- Create an anonymous pl/sql block to call the procedure sum_proc
	str := 'begin '|| UPPER(sum_proc) || '(); end;';

	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  fnd_message.set_name ('FND', 'CALLING_SUMMARIZER_PROC');
                  fnd_message.set_token ('PROCEDURE',sum_proc,  FALSE);
                  FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT, ' FND_CONC_SUMMARIZER.execute_summarizer',TRUE);
        end if;

	-- Use Dynamic sql to execute the procedure passed as an argument
	EXECUTE IMMEDIATE str;

	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                  fnd_message.set_name ('FND','RETURNING_SUMMARIZER_PROC');
                  fnd_message.set_token ('PROCEDURE',sum_proc,  FALSE);
                  FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT, ' FND_CONC_SUMMARIZER.execute_summarizer',TRUE);
	end if;

	-- Parse the pl/sql table to return name=value separated by ;
	for i in 1..P_COUNT loop
    		name  := P_SUMMARIZERS(i).name;
		value :=  P_SUMMARIZERS(i).value;

		-- Call prepare_string to make name=value; string
		return_str := return_str || prepare_string(name,to_char(value));
	end loop;

	-- remove last ';' character
	return_str := substr(return_str,1,length(return_str)-1);

	-- return parsed string
	return return_str;
exception

when others then
	if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
                fnd_message.set_name ('FND', 'SQL-Generic error');
                fnd_message.set_token ('ERRNO', sqlcode, FALSE);
                fnd_message.set_token ('REASON', sqlerrm, FALSE);
                fnd_message.set_token ( 'ROUTINE',' FND_CONC_SUMMARIZER.execute_summarizer', FALSE);
		FND_LOG.MESSAGE(FND_LOG.LEVEL_STATEMENT,' FND_CONC_SUMMARIZER.execute_summarizer',FALSE);
	end if;
	return return_str;
end;

--
-- Procedure
--   insert_row
-- Purpose
--   Insert a row in PL/SQL table P_SUMMARIZER
-- Arguments
--   Name  varchar2 name of the string
--   value varchar2 value of the name
--

procedure insert_row(name  in varchar2,
                     value in varchar2) as
begin
    P_COUNT := P_COUNT+1;
    P_SUMMARIZERS(P_COUNT).name :=  name;
    P_SUMMARIZERS(P_COUNT).value := value;
end;

--
-- Function
--   purge_program
-- Purpose
--   Sample Summarizer Procedure to insert a row in PL/SQL table P_SUMMARIZER
-- Arguments
--   None
--

PROCEDURE purge_program is
   cnt     number := 0;
   --temp_name varchar2(100);
begin

   --temp_name := fnd_message.get_string('FND', 'FND_CONC_REQUESTS');

   -- FND_CONCURRENT_REQUEST table count
   select count(*)
     into cnt
     from fnd_concurrent_requests
    where phase_code  = 'C';

   insert_row('Concurrent Requests', to_char(cnt));

   --temp_name := fnd_message.get_string('FND', 'FND_CONC_PROCESSES');

   -- FND_CONCURRENT_PROCESSES
   select count(*)
     into cnt
     from fnd_concurrent_processes
    where process_status_code not in ('A', 'C', 'T', 'M');

    insert_row('Concurrent Processes', to_char(cnt));

   --temp_name := fnd_message.get_string('FND', 'FND_CRM_HISTORY');

   -- FND_CRM_HISTORY
   select count(*)
     into cnt
     from fnd_crm_history
    where work_start < sysdate -1 ;

    insert_row('Conflict Resolution History', to_char(cnt));

   --temp_name := fnd_message.get_string('FND', 'FND_TM_EVENTS');

   -- FND_TM_EVENTS
   select count(*)
     into cnt
     from fnd_tm_events
    where event_type in (1,2,3,4) and timestamp < sysdate -1 ;

    insert_row('Transaction Management Events', to_char(cnt));

   --temp_name := fnd_message.get_string('FND', 'FND_TEMP_FILES');

   -- FND_TEMP_FILES
   select count(*)
     into cnt
     from fnd_temp_files
    WHERE TYPE <> 'R'
      AND session_id NOT in (SELECT SID FROM v$session);

    insert_row('Temporary Files', to_char(cnt));

end;

end  FND_CONC_SUMMARIZER;

/
