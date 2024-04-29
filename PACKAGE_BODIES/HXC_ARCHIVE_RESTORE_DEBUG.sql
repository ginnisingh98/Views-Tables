--------------------------------------------------------
--  DDL for Package Body HXC_ARCHIVE_RESTORE_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ARCHIVE_RESTORE_DEBUG" as
/* $Header: hxcarcresdbg.pkb 120.0 2005/09/10 03:43:53 psnellin noship $ */



--------------------------------------------------------------------------------------------------
--Procedure Name : print_timecard_id
--Description    : This procedure prints all the time building block id corresponding to the chunk
--                 Which has failed due to some reason.
--------------------------------------------------------------------------------------------------

procedure print_timecard_id(p_data_set_id number,
			    p_start_date date,
			    p_stop_date date) is

--Curosr which will fetch the time_building_block_id for logging purpose in case
--any chunk fails
cursor c_get_timecard_for_log(p_data_set_id number,
	                      p_start_date date,
	                      p_stop_date  date) is
select	tbb.time_building_block_id
from hxc_time_building_blocks tbb
	where scope ='TIMECARD'
	and data_set_id is null
	and stop_time between p_start_date and p_stop_date
	and not exists (
		 select 1 from hxc_tc_ap_links tap, hxc_app_period_summary apbb
		 where tap.timecard_id = tbb.time_building_block_id
		 and apbb.application_period_id = tap.application_period_id
		 and (apbb.start_time < p_start_date or
		      apbb.stop_time > p_stop_date)
		      )
and rownum <= nvl(fnd_profile.value('HXC_ARCHIVE_RESTORE_CHUNK_SIZE'),100);

l_dummy number;

begin


          open c_get_timecard_for_log(p_data_set_id,
	                              p_start_date ,
	                              p_stop_date) ;

	  fnd_file.put_line(fnd_file.LOG,'--- >Printing all the time building block id for timecard scope');


	    fetch c_get_timecard_for_log into l_dummy;
	    if c_get_timecard_for_log%found then
	        close c_get_timecard_for_log;
	        --print the id of the timecard
	  	For l_rec in c_get_timecard_for_log(p_data_set_id,p_start_date,p_stop_date) loop
	  	  fnd_file.put_line(fnd_file.log,'--- >Time Building Block Id :'||l_rec.time_building_block_id);
	  	End Loop;
	    else
	    close c_get_timecard_for_log;

	    end if;




exception
when others then
   fnd_file.put_line(fnd_file.LOG,'--- >Error during Printing timeacrd id: '||sqlerrm);
   NULL;

end print_timecard_id;


--------------------------------------------------------------------------------------------------
--Procedure Name : print_attributes_id
--Description    : This procedure prints all the time attribute id which are in consoliadted state
--                 corresponding to the chunk which has failed due to some reason.
--------------------------------------------------------------------------------------------------

Procedure print_attributes_id(p_data_set_id in number) is

cursor c_get_consolidated_attributes(p_data_set_id number) is
	select  distinct ta.TIME_ATTRIBUTE_ID
	from hxc_time_attributes ta, hxc_time_attribute_usages tau
	where ta.time_attribute_id = tau.time_attribute_id
	 and tau.data_set_id = p_data_set_id
	  and ta.consolidated_flag = 'Y'
	  and ta.data_set_id is null;

l_dummy number;


begin

	open c_get_consolidated_attributes(p_data_set_id) ;

	  fnd_file.put_line(fnd_file.LOG,'--- >Printing all the Consolidate Attribute id');


	    fetch c_get_consolidated_attributes into l_dummy;
	    if c_get_consolidated_attributes%found then
	        close c_get_consolidated_attributes;

	        --print the attribute id
	  	For l_rec in c_get_consolidated_attributes(p_data_set_id) loop
	  	  fnd_file.put_line(fnd_file.log,'--- >Time Attribute Id :'||l_rec.time_attribute_id);
	  	End Loop;
	    else
	    close c_get_consolidated_attributes;

	    end if;


exception
when others then
   fnd_file.put_line(fnd_file.LOG,'--- >Error during Printing all the consolidated attribute id: '||sqlerrm);
   NULL;

end print_attributes_id;



procedure print_table_record(p_table_name varchar2,
			     p_data_set_id number,
			     p_first_column varchar2,
			     p_second_column varchar2) is

type l_record is record(l_first number,l_second number);
type p_rec_tab is table of l_record index by binary_integer;
p_tab  p_rec_tab;

type c_table_records is REF CURSOR;
c_tab_record c_table_records;

l_sql varchar2(2000);
l_count number:=1;

begin

l_sql:= 'select '||p_first_column||','||p_second_column||
         ' from '||p_table_name||
         ' where data_set_id= '||p_data_set_id||
         ' and rownum<100 ';

fnd_file.put_line(fnd_file.LOG,'--- >Before fetching the records into PL/SQL table');
open c_tab_record for l_sql;
loop

	if(c_tab_record%notfound) then
	exit;
	end if;

fetch c_tab_record into p_tab(l_count);
l_count:=l_count+1;

end loop;

close c_tab_record;


fnd_file.put_line(fnd_file.LOG,'--- >Printing the record for the table: '||p_table_name);
fnd_file.put_line(fnd_file.LOG,'--- >Total count of records in PL/SQL Table: '||l_count);
fnd_file.put_line(fnd_file.LOG,'  '||p_table_name||'   '||p_first_column||'    '||p_second_column||' ');

l_count:=p_tab.first;

loop exit when not p_tab.exists(l_count);

   fnd_file.put_line(fnd_file.LOG,'  '||p_table_name||'   '||p_tab(l_count).l_first||'                                '||p_tab(l_count).l_second||' ');

   l_count:=p_tab.next(l_count);
 end loop;

 fnd_file.put_line(fnd_file.LOG,'-------------------------------------');

exception when others then
fnd_file.put_line(fnd_file.LOG,'--- >Error during coying the data in table: '||sqlerrm);
null;

END print_table_record;

END hxc_archive_restore_debug;

/
