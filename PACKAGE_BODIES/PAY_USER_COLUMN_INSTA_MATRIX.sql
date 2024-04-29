--------------------------------------------------------
--  DDL for Package Body PAY_USER_COLUMN_INSTA_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_COLUMN_INSTA_MATRIX" as
/* $Header: pydputil.pkb 120.2 2005/06/14 02:24 mkataria noship $ */

type ref_cursor_type is ref cursor;

--
-- To be used with WebADI only
--
procedure create_batch_header
(
   p_batch_name          in varchar2,
   p_business_group_name in varchar2  default null,
   p_reference           in varchar2  default null,
   p_batch_id            out nocopy number
) is
begin
    p_batch_id := hr_pump_utils.create_batch_header(p_batch_name,
                                                    p_business_group_name,
                                                    p_reference);
exception
    when others then
        hr_utility.set_message(801,'PAY_33283_INVALID_DP_HEAD');
        hr_utility.raise_error;
end create_batch_header;

--
--
--
function check_if_future_rows_exist
(
 p_user_column_instance_id number
,p_effective_date date
) return boolean
is

l_future_row_exists number;
cursor csr_check_future_rows (c_user_column_instance_id number, c_effective_date date)
is
select 1
 from pay_user_column_instances_f puci
 where user_column_instance_id = c_user_column_instance_id
 and c_effective_date between effective_start_date and effective_end_date
 and exists( select null
              from pay_user_column_instances_f pui
	      where pui.user_column_instance_id = puci.user_column_instance_id
	      and pui.effective_start_date > puci.effective_end_date
	      );

begin
  open csr_check_future_rows(p_user_column_instance_id,p_effective_date);
  fetch csr_check_future_rows into l_future_row_exists;
  if csr_check_future_rows%found then
     close csr_check_future_rows;
     return true;
  else
     close csr_check_future_rows;
     return false;
  end if;

end check_if_future_rows_exist;


--
--
--


function get_batch_line_id
( p_user_row_user_key varchar2
 ,p_user_column_user_key varchar2
 ,p_mode varchar2
) return number
is
l_batch_line_id number;
l_statement varchar2(2000);
ref_csr_get_batch_line_id ref_cursor_type;

begin
  if p_mode = 'CREATE' then
     l_statement := 'select batch_line_id from hrdpv_create_user_column_insta where
                     p_user_row_user_key = :1 and p_user_column_user_key = :2';
  else
     l_statement := 'select batch_line_id from hrdpv_update_user_column_insta where
                     p_user_row_user_key = :1 and p_user_column_user_key = :2';
  end if;

  open ref_csr_get_batch_line_id for l_statement using p_user_row_user_key,p_user_column_user_key;
  fetch ref_csr_get_batch_line_id into l_batch_line_id;
  close ref_csr_get_batch_line_id;

  return l_batch_line_id;
end get_batch_line_id;


--
--
--

function update_live_table_value
(
  p_user_row_name varchar2
 ,p_user_column_name varchar2
 ,p_user_table_name varchar2
 ,p_effective_date date
 ,p_business_group_id number
 ,p_value varchar2
 ,p_batch_id number
 ,p_link_value number
) return boolean
is

l_user_table_id number;
l_user_row_id number;
l_user_column_id number;
l_user_column_instance_id number;
l_update_mode varchar2(30);
l_record_start_date date;
l_record_business_group_id number;
l_record_legislation_code varchar2(10);
l_user_row_user_key varchar2(240);
l_user_column_user_key varchar2(240);
l_business_group_name varchar2(240);
l_batch_line_id number;
l_statement varchar2(32000);

cursor csr_get_user_column_insta_id(c_user_row_id number,c_user_column_id number,c_effective_date date)
is
 select user_column_instance_id,effective_start_date,business_group_id,legislation_code
  from  pay_user_column_instances_f
  where user_row_id = c_user_row_id
  and   user_column_id = c_user_column_id
  and   c_effective_date between effective_start_date and effective_end_date;

cursor csr_get_user_table_id( c_user_table_name varchar2,c_business_group_id number)
is
 select user_table_id
 from pay_user_tables
 where user_table_name = c_user_table_name
 and (business_group_id is null or business_group_id = c_business_group_id)
 and (legislation_code is null or legislation_code = hr_api.return_legislation_code(c_business_group_id));


cursor csr_get_user_column_id( c_user_column_name varchar2,c_user_table_id number)
is
 select user_column_id
 from pay_user_columns
 where user_table_id = c_user_table_id
 and user_column_name = c_user_column_name;

cursor csr_get_user_row_id( c_user_row_name varchar2,c_user_table_id number,c_effective_date date)
is
 select user_row_id
  from pay_user_rows_f
  where row_low_range_or_name = c_user_row_name
  and user_table_id = c_user_table_id
  and c_effective_date between effective_start_date and effective_end_date;

cursor csr_get_business_group_name (c_business_group_id number)
is
select name
 from per_business_groups
 where business_group_id = c_business_group_id;

begin
  open csr_get_user_table_id(p_user_table_name,p_business_group_id);
  fetch csr_get_user_table_id into l_user_table_id;
  close csr_get_user_table_id;

  open csr_get_user_row_id(p_user_row_name,l_user_table_id,p_effective_date);
  fetch csr_get_user_row_id into l_user_row_id;
  close csr_get_user_row_id;

  open csr_get_user_column_id(p_user_column_name,l_user_table_id);
  fetch csr_get_user_column_id into l_user_column_id;
  close csr_get_user_column_id;

  open csr_get_user_column_insta_id(l_user_row_id,l_user_column_id, p_effective_date);
  fetch csr_get_user_column_insta_id into l_user_column_instance_id,l_record_start_date,
  l_record_business_group_id,l_record_legislation_code;

  if (csr_get_user_column_insta_id%found) then
     close csr_get_user_column_insta_id;

     if (l_record_business_group_id is null and l_record_legislation_code is null ) then
         fnd_message.set_name('PER', 'PER_289140_STARTUP_GEN_MOD_ERR');
         fnd_message.raise_error;

     elsif( l_record_business_group_id is null and l_record_legislation_code is not null) then
         fnd_message.set_name('PER', 'PER_289142_STARTUP_ST_MODE_ERR');
         fnd_message.raise_error;
     end if;



     open csr_get_business_group_name(p_business_group_id);
     fetch csr_get_business_group_name into l_business_group_name;
     close csr_get_business_group_name;

     l_user_row_user_key := 'PAY_USER_ROW:' || p_user_table_name ||':'|| l_business_group_name || '#' ||p_user_row_name;
     l_user_column_user_key := 'PAY_USER_COLUMN:'||p_user_table_name ||':'|| l_business_group_name || '#' ||p_user_column_name;

     l_batch_line_id := get_batch_line_id(p_user_row_user_key =>l_user_row_user_key
                                         ,p_user_column_user_key => l_user_column_user_key
					 ,p_mode => 'UPDATE');

     if (check_if_future_rows_exist(l_user_column_instance_id,p_effective_date) ) then
        l_update_mode := 'UPDATE_CHANGE_INSERT';
     else
        if l_record_start_date = p_effective_date then
	   l_update_mode := 'CORRECTION';
	else
	   l_update_mode := 'UPDATE';
	end if;
     end if;

     l_statement := 'BEGIN '||
                    'hrdpp_update_user_column_insta.insert_batch_lines( ' ||
                    'p_batch_id => :1 ' ||
		    ',p_data_pump_batch_line_id => :2 '||
		    ',p_data_pump_business_grp_name => :3 '||
		    ',p_user_sequence => :4 '||
		    ',p_link_value => :5 '||
		    ',p_effective_date => :6 '||
		    ',P_DATETRACK_UPDATE_MODE => :7 '||
		    ',P_VALUE => :8 '||
		    ',P_USER_COLUMN_USER_KEY => :9 '||
		    ',P_USER_ROW_USER_KEY => :10 );' ||
		    'END;';

     execute immediate l_statement using p_batch_id,l_batch_line_id,l_business_group_name,40,p_link_value,p_effective_date,
                                         l_update_mode,p_value,l_user_column_user_key,l_user_row_user_key;


     return false;

  else
     close csr_get_user_column_insta_id;
     return true;
  end if;

end update_live_table_value;

--
--
--


procedure create_data_pump_batch_lines
(
 p_batch_id in number
,p_data_pump_batch_line_id      in number    default null
,p_data_pump_business_grp_name  in varchar2
,p_effective_date               in date
,p_row_low_range_or_name       in varchar2
,p_user_table_name             in varchar2
,p_row_high_range              in varchar2 default null
,p_value1                      in varchar2  default null
,p_value2                      in varchar2  default null
,p_value3                      in varchar2  default null
,p_value4                      in varchar2  default null
,p_value5                      in varchar2  default null
,p_value6                      in varchar2  default null
,p_value7                      in varchar2  default null
,p_value8                      in varchar2  default null
,p_value9                      in varchar2  default null
,p_value10                     in varchar2  default null
,p_value11                     in varchar2  default null
,p_value12                     in varchar2  default null
,p_value13                     in varchar2  default null
,p_value14                     in varchar2  default null
,p_value15                     in varchar2  default null
,p_value16                     in varchar2  default null
,p_value17                     in varchar2  default null
,p_value18                     in varchar2  default null
,p_value19                     in varchar2  default null
,p_value20                     in varchar2  default null
,p_value21                     in varchar2  default null
,p_value22                     in varchar2  default null
,p_value23                     in varchar2  default null
,p_value24                     in varchar2  default null
,p_value25                     in varchar2  default null
)
is


l_statement varchar2(32000);
l_user_column_user_keys userkeys;
l_user_row_user_key varchar2(240);
l_user_table_user_key varchar2(240);
l_user_column_user_key varchar2(240);
l_user_column_name varchar2(80);
l_old_value varchar2(80);
l_row_qualifier varchar2(30);
l_link_value number;
l_string_of_values varchar2(4000);
l_qualifier varchar2(30);
l_business_group_id number;
l_ret_status number;
l_batch_line_id number;
l_create_line boolean;

csr_ref_user_key ref_cursor_type;

counter number;
cur number;

cursor csr_get_business_group_id (c_business_group_name per_business_groups.name%type)
is
select business_group_id
from per_business_groups
where name = c_business_group_name;


begin
--
-- Form user keys from the supplied user name and row name.
--
l_user_table_user_key := 'PAY_USER_TABLE:' || p_data_pump_business_grp_name || '#' || p_user_table_name;
l_user_row_user_key := 'PAY_USER_ROW:' || p_user_table_name || ':' || p_data_pump_business_grp_name || '#' ||p_row_low_range_or_name;


open csr_get_business_group_id (p_data_pump_business_grp_name);
fetch csr_get_business_group_id into l_business_group_id;
close csr_get_business_group_id;


l_statement := 'select 1 from pay_user_rows_f pur,pay_user_tables put where row_low_range_or_name = :1 and
(put.business_group_id is null or put.business_group_id = :2)
and (put.legislation_code is null or put.legislation_code = hr_api.return_legislation_code(:3))
and put.user_table_id = pur.user_table_id and
put.user_table_name = :4';

open csr_ref_user_key for l_statement using p_row_low_range_or_name,l_business_group_id,l_business_group_id,p_user_table_name;
fetch csr_ref_user_key into l_ret_status;

if csr_ref_user_key%notfound then
   l_row_qualifier := 'TEMP';
else
   l_row_qualifier := 'LIVE';
end if;

close csr_ref_user_key;

--
-- Get the link value for the rows to be inserted.
--

l_link_value := get_link_value(null,p_data_pump_business_grp_name,l_user_row_user_key,null);

--
-- Get all the User Column User Keys corresponding to the passed table in
-- a pl/sql table.


l_statement :=
'select qualifier ,p_user_column_user_key
from (select ''LIVE'' qualifier,''PAY_USER_COLUMN:'' || :1 || '':'' || :2 || ''#'' ||user_column_name p_user_column_user_key
      from pay_user_columns puc,pay_user_tables put
      where put.user_table_name= :3
      and puc.user_table_id=put.user_table_id
      and (put.business_group_id is null or put.business_group_id = :4)
      and (put.legislation_code is null or put.legislation_code = hr_api.return_legislation_code(:5))
      Union
      select ''TEMP'' qualifier,p_user_column_user_key
      from hrdpv_create_user_column
      where p_user_table_user_key= ''PAY_USER_TABLE:'' || :6 ||''#'' || :7  and
      line_status <> ''C'')
      order by upper(substr(p_user_column_user_key,instr(p_user_column_user_key,''#'',1,1)+1))';

counter:= 0;
open csr_ref_user_key for l_statement using p_user_table_name,p_data_pump_business_grp_name,
p_user_table_name,l_business_group_id,l_business_group_id,p_data_pump_business_grp_name,p_user_table_name;

loop
fetch csr_ref_user_key into l_qualifier,l_user_column_user_key;
exit when csr_ref_user_key%notfound;
counter := counter+1;
l_user_column_user_keys(counter).user_column_key := l_user_column_user_key;
l_user_column_user_keys(counter).qualifier := l_qualifier;
end loop;

close csr_ref_user_key;


--
-- Get the values corresponding to the user columns.
--
l_user_column_user_keys(1).user_column_value   := p_value1;
l_user_column_user_keys(2).user_column_value   := p_value2;
l_user_column_user_keys(3).user_column_value   := p_value3;
l_user_column_user_keys(4).user_column_value   := p_value4;
l_user_column_user_keys(5).user_column_value   := p_value5;
l_user_column_user_keys(6).user_column_value   := p_value6;
l_user_column_user_keys(7).user_column_value   := p_value7;
l_user_column_user_keys(8).user_column_value   := p_value8;
l_user_column_user_keys(9).user_column_value   := p_value9;
l_user_column_user_keys(10).user_column_value  := p_value10;
l_user_column_user_keys(11).user_column_value  := p_value11;
l_user_column_user_keys(12).user_column_value  := p_value12;
l_user_column_user_keys(13).user_column_value  := p_value13;
l_user_column_user_keys(14).user_column_value  := p_value14;
l_user_column_user_keys(15).user_column_value  := p_value15;
l_user_column_user_keys(16).user_column_value  := p_value16;
l_user_column_user_keys(17).user_column_value  := p_value17;
l_user_column_user_keys(18).user_column_value  := p_value18;
l_user_column_user_keys(19).user_column_value  := p_value19;
l_user_column_user_keys(20).user_column_value  := p_value20;
l_user_column_user_keys(21).user_column_value  := p_value21;
l_user_column_user_keys(22).user_column_value  := p_value22;
l_user_column_user_keys(23).user_column_value  := p_value23;
l_user_column_user_keys(24).user_column_value  := p_value24;
l_user_column_user_keys(25).user_column_value  := p_value25;



l_string_of_values := get_matrix_row_values
                     (
                      p_batch_id => p_batch_id
		     ,p_user_table_name => p_user_table_name
		     ,p_row_low_range_or_name => p_row_low_range_or_name
		     ,p_business_group_id => l_business_group_id
                     );

--
-- Open the cursor before we enter the loop so that it doesn't get
-- opened multiple times.
--
cur:= dbms_sql.open_cursor;

--
-- Go through all the values and if any value has changed then only take some action
--

for i in 1..counter loop
l_old_value
:= substr(l_string_of_values,instr(l_string_of_values,'$',1,i)+1,instr(l_string_of_values,'$',1,i+1)-1 - instr(l_string_of_values,'$',1,i));

l_user_column_name := substr(l_user_column_user_keys(i).user_column_key,instr(l_user_column_user_keys(i).user_column_key,'#',1,1)+1);

if ( nvl(l_user_column_user_keys(i).user_column_value, '<NULL>') <> nvl(l_old_value,'<NULL>') ) then

    if ( l_user_column_user_keys(i).qualifier = 'LIVE' and l_row_qualifier ='LIVE') then
        l_create_line := update_live_table_value(p_row_low_range_or_name
	                                        ,l_user_column_name
						,p_user_table_name
						,p_effective_date
						,l_business_group_id
						,l_user_column_user_keys(i).user_column_value
						,p_batch_id
						,l_link_value
						 );
--	if l_create_line then
	   insert_user_key(p_business_group => p_data_pump_business_grp_name
	                   ,p_user_row_name => p_row_low_range_or_name
			   ,p_user_table_name => p_user_table_name
			   ,p_effective_date => p_effective_date);

           insert_user_key(p_business_group => p_data_pump_business_grp_name
	                   ,p_user_column_name => l_user_column_name
	                   ,p_user_table_name => p_user_table_name);
--      end if;

    else

	l_create_line := true;

        if ( l_user_column_user_keys(i).qualifier = 'TEMP' and l_row_qualifier = 'LIVE' ) then
            insert_user_key(p_business_group => p_data_pump_business_grp_name
	                   ,p_user_row_name => p_row_low_range_or_name
			   ,p_user_table_name => p_user_table_name
			   ,p_effective_date => p_effective_date);

	elsif (l_user_column_user_keys(i).qualifier = 'LIVE' and l_row_qualifier = 'TEMP') then
	    insert_user_key(p_business_group => p_data_pump_business_grp_name
	                   ,p_user_column_name => substr(l_user_column_user_keys(i).user_column_key,
			                          instr(l_user_column_user_keys(i).user_column_key,'#',1,1)+1)
	                   ,p_user_table_name => p_user_table_name);
        end if;
    end if;
        l_batch_line_id := get_batch_line_id
	                      (p_user_row_user_key => l_user_row_user_key
		              ,p_user_column_user_key => l_user_column_user_keys(i).user_column_key
			      ,p_mode => 'CREATE');
--
-- Call hrdpp_create_user_column_insta for each user column instance entered for a
-- column in batch lines table.
--
        if (l_create_line) then

            l_statement := 'BEGIN ' ||
            'hrdpp_create_user_column_insta.insert_batch_lines' ||
            '(p_batch_id => :batch_id ' ||
            ',p_data_pump_batch_line_id => :data_pump_batch_line_id ' ||
	    ',p_user_sequence => :user_sequence '||
            ',p_link_value => :link_value ' ||
            ',p_data_pump_business_grp_name => :data_pump_business_grp_name '||
            ',P_EFFECTIVE_DATE => :EFFECTIVE_DATE ' ||
            ',P_VALUE => :VALUE '||
            ',P_USER_ROW_USER_KEY => :USER_ROW_USER_KEY ' ||
            ',P_USER_COLUMN_USER_KEY => :USER_COLUMN_USER_KEY );' ||
            ' END;' ;

            dbms_sql.parse(cur, l_statement,DBMS_SQL.NATIVE);
            dbms_sql.bind_variable(cur,'batch_id',p_batch_id);
            dbms_sql.bind_variable(cur,'data_pump_batch_line_id',l_batch_line_id);
	    dbms_sql.bind_variable(cur,'user_sequence',40);
            dbms_sql.bind_variable(cur,'link_value',l_link_value);
            dbms_sql.bind_variable(cur,'data_pump_business_grp_name',p_data_pump_business_grp_name);
            dbms_sql.bind_variable(cur,'EFFECTIVE_DATE',P_EFFECTIVE_DATE);
            dbms_sql.bind_variable(cur,'VALUE',l_user_column_user_keys(i).user_column_value);
            dbms_sql.bind_variable(cur,'USER_ROW_USER_KEY',l_user_row_user_key);
            dbms_sql.bind_variable(cur,'USER_COLUMN_USER_KEY',l_user_column_user_keys(i).user_column_key);

            l_ret_status := dbms_sql.execute (cur);
        end if;
end if;
end loop;
dbms_sql.close_cursor (cur);
commit;
end create_data_pump_batch_lines;

--
--
--

function batch_overall_status (p_batch_id number) return varchar2 is
--
-- Derives the overall status of the batch header, control totals and lines
--
--
l_batch_status varchar2(2);
cursor csr_status is
	select	batch_status status
	from	hr_pump_batch_headers
	where	batch_id = p_batch_id;
        --
begin
--
open csr_status;
fetch csr_status into l_batch_status;
close csr_status;

if l_batch_status = 'C' then
  return 'T';
else
  return l_batch_status;
end if;

end batch_overall_status;



function get_link_value
(
   p_batch_line_id number
  ,p_business_group_name varchar2
  ,p_user_row_user_key varchar2
  ,p_user_table_user_key varchar2
) return number
is

l_link_value number;
l_user_table_user_key varchar2(240);
l_user_table_name varchar2(240);
l_statement varchar2(4000);
ref_link_value ref_cursor_type;


begin

If (p_batch_line_id is not null)
then

   select link_value into l_link_value
    from hr_pump_batch_lines
   where batch_line_id = p_batch_line_id;

else

   if (p_user_row_user_key is not null)
   then

      --Derive the user table user key using business group name and user row user key.

      l_user_table_user_key := 'PAY_USER_TABLE:' || p_business_group_name || '#' ||
      substr(p_user_row_user_key, instr(p_user_row_user_key,':',1,1)+1,instr(p_user_row_user_key,':',1,2) - instr(p_user_row_user_key,':',1,1)-1);

   else

      l_user_table_user_key := p_user_table_user_key;
   end if;

   l_user_table_name := substr(l_user_table_user_key,instr(l_user_table_user_key,'#',1)+1);

   l_statement :=
       'select link_value
        from hrdpv_create_user_table
       where p_user_table_user_key = :1
       and link_value is not null
   Union
       select link_value
        From hrdpv_create_user_row
       where p_user_table_user_key = :1
       and link_value is not null
   Union
       select link_value
        from hrdpv_create_user_column
       where p_user_table_user_key = :1
       and link_value is not null
   Union
       select link_value
        from hrdpv_create_user_column_insta
       where substr( p_user_row_user_key, (instr(p_user_row_user_key, '':'' , 1)+1),
       (instr(p_user_row_user_key, ''#'' ,1)) - (instr(p_user_row_user_key, '':'' , 1)+1) )
       = :2 || '':'' || :3
       and link_value is not null';

   open ref_link_value for l_statement
   using l_user_table_user_key,l_user_table_user_key,l_user_table_user_key,l_user_table_name,p_business_group_name;
   fetch ref_link_value into l_link_value;
   if ref_link_value%notfound
   then
      select nvl(max(link_value),0)+1  into l_link_value from hr_pump_batch_lines;
   end if;
   close ref_link_value;
end if;

return l_link_value;
end get_link_value;

--
--
--

procedure insert_user_key
(
  p_business_group     varchar2
 ,p_user_column_name  varchar2
 ,p_user_table_name   varchar2
)
is

l_user_key_value varchar2(240);
l_user_column_id  pay_user_columns.user_column_id%type;
l_user_key_id number;


cursor csr_get_user_column_id (c_business_group hr_organization_units.name%type
                              ,c_user_column_name pay_user_columns.user_column_name%type
			      ,c_user_key_value varchar2
			      ,c_user_table_name pay_user_tables.user_table_name%type)
is
select puc.user_column_id
 from  pay_user_columns puc,
       per_business_groups pbg,
       pay_user_tables put
where  (put.business_group_id is null or put.business_group_id = pbg.business_group_id)
and    (put.legislation_code is null or put.legislation_code= hr_api.return_legislation_code(pbg.business_group_id))
and    pbg.name = c_business_group
and    puc.user_column_name = c_user_column_name
and    puc.user_table_id = put.user_table_id
and    put.user_table_name = c_user_table_name
and    not exists(select null
                 from hr_pump_batch_line_user_keys
		 where user_key_value = c_user_key_value
		 and unique_key_id = puc.user_column_id);



cursor csr_check_user_key_exists(c_unique_key_id number)
is
 select user_key_id
  from hr_pump_batch_line_user_keys
  where user_key_value like 'PAY_USER_COLUMN%'
  and unique_key_id = c_unique_key_id;


begin
l_user_key_value := 'PAY_USER_COLUMN:'||p_user_table_name||':'||p_business_group||'#'||p_user_column_name;

open csr_get_user_column_id(p_business_group,p_user_column_name,l_user_key_value,p_user_table_name);
fetch csr_get_user_column_id into l_user_column_id;

if csr_get_user_column_id%found then

  close csr_get_user_column_id;
  open csr_check_user_key_exists(l_user_column_id);
  fetch csr_check_user_key_exists into l_user_key_id;

     if csr_check_user_key_exists%found then
        delete from hr_pump_batch_line_user_keys where user_key_id = l_user_key_id;
     end if;

     close csr_check_user_key_exists;
     hr_pump_utils.add_user_key
     (
      p_user_key_value  => l_user_key_value
     ,p_unique_key_id   => l_user_column_id
     );

else
  close csr_get_user_column_id;
end if;
end insert_user_key;

--
--
--

procedure insert_user_key
(
  p_business_group     varchar2
 ,p_user_row_name     varchar2
 ,p_user_table_name   varchar2
 ,p_effective_date    date
)
is

l_user_key_value varchar2(240);
l_user_row_id  pay_user_rows_f.user_row_id%type;
l_user_key_id number;

cursor csr_get_user_row_id(
                         c_business_group hr_organization_units.name%type
                        ,c_user_row_name pay_user_rows_f.row_low_range_or_name%type
                        ,c_effective_date date
			,c_user_key_value varchar2
			,c_user_table_name pay_user_tables.user_table_name%type)
is
select pur.user_row_id
 from  pay_user_rows_f pur,
       per_business_groups pbg,
       pay_user_tables put
where  (put.business_group_id is null or put.business_group_id= pbg.business_group_id)
and    (put.legislation_code is null or put.legislation_code = hr_api.return_legislation_code(pbg.business_group_id))
and    pbg.name = c_business_group
and    c_effective_date between pur.effective_start_date and pur.effective_end_date
and    pur.row_low_range_or_name = c_user_row_name
and    pur.user_table_id = put.user_table_id
and    put.user_table_name = c_user_table_name
and    not exists(select null
                 from hr_pump_batch_line_user_keys
		 where user_key_value = c_user_key_value
		 and unique_key_id = pur.user_row_id);


cursor csr_check_user_key_exists(c_unique_key_id number)
is
 select user_key_id
  from hr_pump_batch_line_user_keys
  where user_key_value like 'PAY_USER_ROW%'
  and unique_key_id = c_unique_key_id;



begin
l_user_key_value := 'PAY_USER_ROW:'||p_user_table_name||':'||p_business_group||'#'||p_user_row_name;

open csr_get_user_row_id(p_business_group,
                         p_user_row_name,
			 p_effective_date,
			 l_user_key_value,
			 p_user_table_name);
fetch csr_get_user_row_id into l_user_row_id;

if csr_get_user_row_id%found then

  close csr_get_user_row_id;
  open csr_check_user_key_exists(l_user_row_id);
  fetch csr_check_user_key_exists into l_user_key_id;

     if csr_check_user_key_exists%found then
        delete from hr_pump_batch_line_user_keys where user_key_id = l_user_key_id;
     end if;

     close csr_check_user_key_exists;
     hr_pump_utils.add_user_key
     (
      p_user_key_value  => l_user_key_value
     ,p_unique_key_id   => l_user_row_id
     );

else
  close csr_get_user_row_id;
end if;
end insert_user_key;


--
--
--


procedure insert_user_key
(
  p_business_group     varchar2
 ,p_user_table_name   varchar2
)
is

l_user_table_id pay_user_tables.user_table_id%type;
l_user_key_value varchar2(240);
l_user_key_id number;

cursor csr_get_user_table_id( c_user_key_value varchar2
                             ,c_business_group hr_organization_units.name%type
			     ,c_user_table_name pay_user_tables.user_table_name%type)
is
select put.user_table_id
 from  pay_user_tables put,per_business_groups pbg
 where user_table_name = c_user_table_name
 and   pbg.name = c_business_group
 and   (put.business_group_id is null or put.business_group_id = pbg.business_group_id)
 and   (put.legislation_code is null or put.legislation_code= hr_api.return_legislation_code(pbg.business_group_id));

cursor csr_check_user_key_exists(c_unique_key_id number)
is
 select user_key_id
  from hr_pump_batch_line_user_keys
  where user_key_value like 'PAY_USER_TABLE%'
  and unique_key_id = c_unique_key_id;
begin

l_user_key_value := 'PAY_USER_TABLE:'||p_business_group||'#'||p_user_table_name;

open csr_get_user_table_id(l_user_key_value,p_business_group,p_user_table_name);
fetch csr_get_user_table_id into l_user_table_id;


if csr_get_user_table_id%found then

  close csr_get_user_table_id;
  open csr_check_user_key_exists(l_user_table_id);
  fetch csr_check_user_key_exists into l_user_key_id;

     if csr_check_user_key_exists%found then
        delete from hr_pump_batch_line_user_keys where user_key_id = l_user_key_id;
     end if;

     close csr_check_user_key_exists;
     hr_pump_utils.add_user_key
     (
      p_user_key_value  => l_user_key_value
     ,p_unique_key_id   => l_user_table_id
     );

else
  close csr_get_user_table_id;
end if;

end insert_user_key;

--
--
--


function get_matrix_row_values
 (
  p_batch_id number
 ,p_user_table_name varchar2
 ,p_row_low_range_or_name varchar2
 ,p_business_group_id number
 )return varchar2
 is

 type values_type is varray(25) of varchar2(80);
 type ordered_columns_type is record(column_name varchar2(80), order_num number);
 type ordered_columns_table is table of ordered_columns_type index by binary_integer;

 l_user_table_id number;
 l_ordered_columns ordered_columns_table;
 l_values values_type;
 l_business_group_name varchar2(240);
 l_user_row_user_key varchar2(240);
 l_return_string varchar2(32000);
 l_counter number;
 l_qualified_value varchar2(160);
 l_extracted_value varchar2(80);
 l_statement varchar2(32000);
 l_column_name varchar2(80);
 l_column_order_num number;

 ref_csr_user_columns ref_cursor_type;
 ref_csr_user_row_values ref_cursor_type;



 cursor csr_get_user_table_id (c_business_group_id number, c_user_table_name varchar2)
 is
 select user_table_id
 from pay_user_tables
 where (business_group_id is null or business_group_id = c_business_group_id )
 and (legislation_code is null or legislation_code = hr_api.return_legislation_code(c_business_group_id))
 and user_table_name = c_user_table_name;

 cursor csr_get_business_group_name(c_business_group_id number)
 is
 select name
 from per_business_groups
 where business_group_id = c_business_group_id;



begin

  open csr_get_business_group_name(p_business_group_id);
  fetch csr_get_business_group_name into l_business_group_name;
  close csr_get_business_group_name;
--

  open csr_get_user_table_id(p_business_group_id,p_user_table_name);
  fetch csr_get_user_table_id into l_user_table_id ;
  close csr_get_user_table_id;

--
  l_values := values_type(null,null,null,null,null,null,null,null,null,null,null,null,null,null,
                          null,null,null,null,null,null,null,null,null,null,null);
  for i in 1..25 loop
  l_ordered_columns(i).column_name := null;
  l_ordered_columns(i).order_num := null;
  end loop;
--


  l_statement :='select user_column_name, rownum
   from (select * from
     (select user_column_name
      from pay_user_columns puc
      where puc.user_table_id = :1

      Union

      select p_user_column_name
      from hrdpv_create_user_column
      where p_user_table_user_key=''PAY_USER_TABLE:'' || :2 ||''#'' || :3 and line_status <> ''C'')
      order by upper(user_column_name))';
--
  l_counter := 0;
  open ref_csr_user_columns for l_statement using l_user_table_id,l_business_group_name, p_user_table_name;
  loop
  l_counter:=  l_counter + 1;
  fetch ref_csr_user_columns into l_column_name,l_column_order_num;
  exit when ref_csr_user_columns%notfound;

  l_ordered_columns(l_counter).column_name := l_column_name;
  l_ordered_columns(l_counter).order_num :=l_column_order_num;

  end loop;
  close ref_csr_user_columns;

--

  l_user_row_user_key := 'PAY_USER_ROW:'|| p_user_table_name || ':' || l_business_group_name || '#'
 || p_row_low_range_or_name;

 l_statement := '(select puc.user_column_name || '':'' || pui.value qualified_value
  from pay_user_column_instances_f pui,
       pay_user_columns puc,
       pay_user_rows_f pur
 where pur.row_low_range_or_name = :1
 and   pur.user_table_id = :2
 and   puc.user_table_id = pur.user_table_id
 and   pui.user_column_id = puc.user_column_id
 and   pui.user_row_id = pur.user_row_id
 and   sysdate between pui.effective_start_date and pui.effective_end_date
 Union
 select substr(p_user_column_user_key,instr(p_user_column_user_key,''#'',1,1)+1) || '':'' || p_value
  qualified_value
  from  hrdpv_create_user_column_insta
  where p_user_row_user_key = :3
  and line_status <>''C'')';


  open ref_csr_user_row_values for l_statement using p_row_low_range_or_name,l_user_table_id,
  l_user_row_user_key;

  loop
      fetch ref_csr_user_row_values into l_qualified_value;
      exit when ref_csr_user_row_values%notfound;
      l_extracted_value:= substr(l_qualified_value,1,instr(l_qualified_value,':',1,1)-1);
      for i in 1..l_ordered_columns.count loop
         if l_extracted_value = l_ordered_columns(i).column_name then
	    l_values(l_ordered_columns(i).order_num) :=
	    substr(l_qualified_value,instr(l_qualified_value,':',1,1)+1);
	 end if;
      end loop;
  end loop;

  close ref_csr_user_row_values;

  l_return_string := '$';

  for i in 1..25 loop
  l_return_string := l_return_string || l_values(i) || '$';
  end loop;

  return l_return_string;

end get_matrix_row_values;

--
--
--

end pay_user_column_insta_matrix;

/
