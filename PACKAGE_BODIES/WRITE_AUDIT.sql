--------------------------------------------------------
--  DDL for Package Body WRITE_AUDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WRITE_AUDIT" as
/* $Header: payustextio.pkb 120.0.12010000.2 2009/05/29 09:31:21 pannapur noship $ */

g_file_type    	utl_file.file_type;
g_IL_fein       varchar2(10);
g_file_name     varchar2(30);
TEMP_DIR	varchar2(255);
TEMP_UTL	varchar2(255);

procedure open(p_reportname in varchar2)  is
	l_applcsf	varchar2(2000);
	l_per_top	varchar2(2000);
	l_applout	varchar2(2000);
	l_path		varchar2(2000);
  l_file_name     varchar2(100);
  l_name	        varchar2(60) := 'utl_file.fopen';

	CURSOR c_concurrent_id is
        select max(fcr.request_id)
        from fnd_concurrent_requests fcr
             ,fnd_concurrent_programs fcp
        where fcp.application_id = 800
	and fcp.concurrent_program_name  = p_reportname
	and fcr.concurrent_program_id = fcp.concurrent_program_id
	and fcr.program_application_id = fcp.application_id;

        l_request_id number;

begin

  	 select translate(ltrim(value),',',' ')
        into TEMP_UTL
        from v$parameter
       where name = 'utl_file_dir';

      if (instr(TEMP_UTL,' ') > 0 and TEMP_UTL is not null) then
        select substrb(TEMP_UTL, 1, instr(TEMP_UTL,' ') - 1)
          into TEMP_DIR
          from dual ;
      elsif (TEMP_UTL is not null) then
        TEMP_DIR := TEMP_UTL;
      end if;

      if (TEMP_UTL is null or TEMP_DIR is null ) then
         raise no_data_found;
      end if;


      	open c_concurrent_id;
        fetch c_concurrent_id  into l_request_id;
        close c_concurrent_id;

        g_file_name := 'o' || to_char(l_request_id);
        l_file_name := g_file_name || '.a03';

	g_file_type := utl_file.fopen(TEMP_DIR,l_file_name,'w');

        hr_utility.trace('utl_file.fopen :' || l_path);
        exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
      		      fnd_message.raise_error;
end open;

procedure put(p_char in varchar2) is

 l_name	        varchar2(60) := 'utl_file.put';
begin

	--utl_file.put(g_file_type,convert(p_char,'US7ASCII',c_source_cset));

   utl_file.put(g_file_type,p_char);
   hr_utility.trace('utl_file.put :' || p_char);

   exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
                 fnd_message.raise_error;
end put;

procedure close is
 l_name	        varchar2(60) := ' utl_file.fclose';
begin

	-- Close file.


	 utl_file.fclose(g_file_type);

 hr_utility.trace('utl_file.fclose state mag file closed ');
 exception when others then
                hr_utility.set_location('Leaving....' || l_name,999);
                fnd_message.raise_error;
end close;

END write_audit;

/
