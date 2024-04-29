--------------------------------------------------------
--  DDL for Package Body HRSUMREP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRSUMREP" as
/* $Header: hrsumrep.pkb 115.14 2004/06/21 07:38:31 jheer noship $ */
--
procedure delete_process_data(p_process_run_id in number) is
--
begin
   --
   delete hr_summary_key_value
   where  item_value_id in (select item_value_id
                            from   hr_summary_item_value
                            where  process_run_id = p_process_run_id);
   --
   delete hr_summary_item_value
   where  process_run_id = p_process_run_id;
   --
   delete hr_summary_parameter
   where process_run_id = p_process_run_id;
   --
   delete hr_summary_process_run
   where process_run_id = p_process_run_id;
   --
end delete_process_data;
--
procedure write_error (p_error in varchar2) is
begin
   fnd_file.put_line(FND_FILE.LOG,substrb(p_error,1,1024));
exception when others then
   null;
end;
--
procedure write_stmt_log (p_stmt in varchar2) is
l_num number:= 1;
begin
   if lengthb(p_stmt) > 1024 then
      for i in 1..ceil(lengthb(p_stmt)/1024) loop
          write_error(substrb(p_stmt,l_num,1024));
          l_num := (i*1024)+1;
      end loop;
   else
      write_error(p_stmt);
   end if;
end;
--
procedure process_run(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
                     ,p_parameters hr_summary_util.prmTabType
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug  varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2
                     ,p_retcode   out NOCOPY number) is
--
cursor c_get_item_type_usage(p_template_id number) is
select it.DATATYPE
,      it.count_clause1
,      it.count_clause2
,      it.where_clause
,      it.name  it_name
,      itu.name itu_name
,      itu.ITEM_TYPE_USAGE_ID
,      itu.ITEM_TYPE_ID
from   hr_summary_item_type_usage itu
,      hr_summary_item_type it
where  itu.template_id = p_template_id
and    itu.ITEM_TYPE_ID = it.ITEM_TYPE_ID
and    nvl(p_item_type_usage_id,item_type_usage_id) = item_type_usage_id
order by itu.sequence_number;
--
cursor c_get_key_type_usage(p_item_type_usage_id number) is
select kty.name
,      kty.key_function
,      kty.key_type_id
from   hr_summary_key_type_usage ktu
,      hr_summary_valid_key_type vkt
,      hr_summary_key_type kty
where  kty.key_type_id = vkt.key_type_id
and    ktu.valid_key_type_id = vkt.valid_key_type_id
and    ktu.item_type_usage_id = p_item_type_usage_id;
--
cursor c_get_restriction_usage(p_item_type_usage_id number) is
select srt.data_type
,      srt.restriction_clause
,      vru.restriction_type
,      vru.restriction_usage_id
,      srt.name
from   hr_summary_valid_restriction vrt
,      hr_summary_restriction_usage vru
,      hr_summary_restriction_type  srt
where  vrt.valid_restriction_id = vru.valid_restriction_id
and    vru.item_type_usage_id = p_item_type_usage_id
and    vrt.restriction_type_id = srt.restriction_type_id
and    srt.name <> 'USER_PERSON_TYPE';
--
cursor c_get_restriction_value(p_restriction_usage_id number) is
select value
from   hr_summary_restriction_value
where  restriction_usage_id = p_restriction_usage_id;
--
l_object_version_number number;
l_datatype varchar2(1);
l_stmt varchar2(32000);
l_item_type_usage_id number;
l_count_clause1 varchar2(32000);
l_count_clause2 varchar2(32000);
l_key_col_clause varchar2(32000);
l_where_clause varchar2(32000);
l_restriction_clause  varchar2(32000);
l_restriction_clause2 varchar2(32000);
l_restriction_value varchar2(80);
l_error_mesg varchar2(100);
l_group_clause varchar2(32000);
l_key_clause varchar2(32000);
l_comma varchar2(1);
l_tab_num varchar2(2);
l_error boolean;
i number;
l_itu_error  number; /* variable to check if item type usage occurred */
--
p number;
y number;
--
l_pos1  number;
l_pos2  number;
l_pos3  number;

l_alias varchar2(30);
l_parameter_alias varchar2(32000); -- require this length for the substr,instr to work
l_character_after_brkt varchar2(50);
--
source_cursor integer;
ignore integer;
--
begin
   p_retcode :=0; /* Default retcode to zero, to indicate no error */

   -- Set STORE_DATA utility package global
   --
   hr_utility.set_location('Entering : hrumrep.process_run ', 5);
   hr_summary_util.store_data := p_store_data;
   --
   -- If the process needs to write data then initialize it by writing
   -- and process row and parameter rows, otherwise just setup business group
   -- for bsutil
   --
   hr_summary_util.initialize_run(p_store_data
                                 ,p_business_group_id
                                 ,p_template_id
                                 ,p_process_name
                                 ,p_process_type
                                 ,p_parameters);
   --
/* ------------------------------------------------------------------
   For each of the item types that are required for the selected template,
   retrieve the item type details
   ------------------------------------------------------------------ */
   i := 1;
   for itu in c_get_item_type_usage(p_template_id) loop
   --
   --
      ituTab(i).item_type_usage_id := itu.item_type_usage_id;
      ituTab(i).item_type_id := itu.item_type_id;
      ituTab(i).datatype := itu.datatype;
      ituTab(i).count_clause1 := itu.count_clause1;
      ituTab(i).count_clause2 := itu.count_clause2;
      ituTab(i).where_clause := itu.where_clause;
      ituTab(i).it_name := itu.it_name;
      ituTab(i).itu_name := itu.itu_name;
      --
      i := i + 1;
      --
   end loop;
--
/* ------------------------------------------------------------------
   Fo each item type usage retrieved
    a) delete any existing item values or key values for the item type usage
    b) build up the dynamic SQL statement and excute (if appropriate)
   ------------------------------------------------------------------ */
   if ituTab.count > 0 then
      <<itu_loop>>
      for x in 1..i-1 loop
          --
          -- Populate local and global variables
          --
          hr_summary_util.item_type_usage_id := ituTab(x).item_type_usage_id;
          l_item_type_usage_id := ituTab(x).item_type_usage_id;
          l_datatype := ituTab(x).datatype;
          --
          -- Delete existing results where appropriate
          --
/* ------------------------------------------------------------------
  Need to call Initialize procedure before evaluating the key functions because
  initialize_procedure populates the zero_item_value_id for the item_type being
  processed, the key functions subsequently reference it.
   ------------------------------------------------------------------   */
      hr_summary_util.initialize_procedure(p_business_group_id);
      --
      -- Initialize dynamic SQL components
      --
      l_stmt := null;
      l_count_clause1 := null;
      l_count_clause2 := null;
      l_key_col_clause := null;
      l_where_clause := null;
      l_restriction_clause := null;
      l_group_clause := null;
      --
      -- Begin determining the dynamic SQL components
      --
      hr_utility.trace('processing item ' || itutab(x).itu_name || ' ' || itutab(x).it_name);
      l_count_clause1 := ituTab(x).count_clause1 || ' col_value1 ';
      if ituTab(x).count_clause2 is not null then
         l_count_clause2 := ','||ituTab(x).count_clause2 || ' col_value2 ';
      end if;
      --
      -- Load the Key Types into a PLSQL table
      --
      i := 0;
      ktyTab := nullktyTab;
      for kty in c_get_key_type_usage(l_item_type_usage_id) loop
          ktyTab(i).key_type := kty.name;
          ktyTab(i).key_function := kty.key_function;
          ktyTab(i).key_type_id := kty.key_type_id;
          ktyTab(i).key_other := FALSE;
          i := i + 1;
      end loop;
      --
    /* -----------------------------------------------------------------
       If there are key types being used
       a) evaluate the function associated with the key type to return
          the group by clause
       b) build up the select clause
       c) build up the group by clause
      ----------------------------------------------------------------- */
    --
    hr_utility.trace('hrsumrep - keytab');
    if ktyTab.count > 0 then
      for i in ktyTab.first..ktyTab.last loop
        --
        --
        l_stmt := 'declare key_type_id number := '||ktyTab(i).key_type_id||';
                   begin :l_clause   := '||ktyTab(i).key_function||';
                   end;';
        source_cursor := dbms_sql.open_cursor;
        begin
             l_error_mesg := fnd_message.get_string('PER','PER_74874_PARSE_ERROR');
             dbms_sql.parse(source_cursor,l_stmt,dbms_sql.v7);
             dbms_sql.bind_variable(source_cursor,'l_clause',l_key_clause, 32000);
             l_error_mesg := fnd_message.get_string('PER','PER_74875_EXECUTE_ERROR');
             ignore := dbms_sql.execute(source_cursor);
             l_error_mesg := fnd_message.get_string('PER','PER_74876_ASSIGN_VARIABLE');
             dbms_sql.variable_value(source_cursor,'l_clause',l_key_clause);
             dbms_sql.close_cursor(source_cursor);
        exception when others then
             if p_store_data then
                p_retcode :=1; /* error occurred in key type. set status to warning */
                write_error(l_error_mesg);
                write_error(sqlerrm);
                --write_stmt_log (p_stmt => l_stmt);
                exit itu_loop;
             else
                null;
             end if;
        end;
          l_key_col_clause := l_key_col_clause || '
, '||                         l_key_clause || ' '||
                              'col_'||ktyTab(i).key_type ||' ';
          if l_group_clause is null then
             l_group_clause := ' group by ';
          else
             l_group_clause := l_group_clause ||'
,';
          end if;
          --
          l_group_clause := l_group_clause || l_key_clause;
      end loop;
    end if;

      --
      --
     hr_utility.trace('hrsumrep -  restrictions');
    /* -----------------------------------------------------------------
       If there are restrictions being used build up the restriction clause
      ----------------------------------------------------------------- */
      --
      l_where_clause := ituTab(x).where_clause;
      --
      for vrt in c_get_restriction_usage(l_item_type_usage_id) loop
          --
          l_pos1 := nvl(instr(l_where_clause,vrt.name||'['),0);

          if l_pos1 <> 0 then

          l_pos1 := l_pos1+length(vrt.name)+1;
          l_character_after_brkt := substr(l_where_clause,l_pos1,16);
          -- need to concatenate slash and asterisk otherwise check_sql will give error.
          If l_character_after_brkt = concat('/','*'|| 'parameteralias') then
             l_restriction_clause := ' and @'||vrt.restriction_clause || ' ' ||
                                  vrt.restriction_type || ' ';
             l_pos1 := l_pos1 + 17;
             l_pos2 := instr(l_where_clause,(concat('*','/]')),1);
             l_parameter_alias := substr(l_where_clause,l_pos1,(l_pos2-l_pos1));
          else
             l_restriction_clause := ' and @.'||vrt.restriction_clause || ' ' ||
                                  vrt.restriction_type || ' ';
          end if;
          --
          hr_utility.trace('hrsumrep -  restrictions1');
          l_comma := '(';
          for rvl in c_get_restriction_value(vrt.restriction_usage_id) loop
              if vrt.data_type = 'C' then
                 l_restriction_value := '''' || rvl.value || '''';
              elsif vrt.data_type = 'D' then
                 l_restriction_value := 'to_date('''|| rvl.value ||
                                                 ''',''YYYY/MM/DD HH24:MI:SS'')';
              elsif vrt.data_type = 'N' then
                 l_restriction_value := rvl.value;
              end if;
              --
              if vrt.restriction_type in ('=','<>','>','<') then
                 l_restriction_clause := l_restriction_clause ||
                                         l_restriction_value || ' ';
                 exit;
              else
                 l_restriction_clause := l_restriction_clause || l_comma ||
                                         l_restriction_value;
                 l_comma := ',';
              end if;
          end loop;
          --
          if vrt.restriction_type not in ('=','<>','>','<') then
             l_restriction_clause := l_restriction_clause || ')';
          end if;
          --
          -- Replace all occurences of RESTRICTION.<restriction_name>
          -- with the correct alias and restriction clause.
          loop


          l_pos3 := nvl(instr(l_where_clause,vrt.name||'['),0);
          l_pos3 := l_pos3+length(vrt.name)+1;
          l_character_after_brkt := substr(l_where_clause,l_pos3,16);
          If l_character_after_brkt = concat('/','*parameteralias') then
             l_pos3 := l_pos3 + 17;
             l_pos2 := instr(l_where_clause,concat('*','/]'),1);
             l_parameter_alias := substr(l_where_clause,l_pos3,(l_pos2-l_pos3));
          End if;

              l_pos1 := nvl(instr(l_where_clause,vrt.name||'['),0);
              exit when l_pos1 = 0;
              l_pos1 := l_pos1+length(vrt.name)+1;
              l_pos2 := instr(l_where_clause,']',l_pos1,1);
              hr_utility.trace('hrsumrep -  restrictions1b');
              hr_utility.trace('l_pos1 = ' || l_pos1 || ' ' || l_pos2);
              l_alias := substr(l_where_clause,l_pos1,l_pos2-l_pos1);
              hr_utility.trace('l_alias = ' || l_alias);
              if l_character_after_brkt = concat('/','*parameteralias') then
        --       l_alias := ' ';
                 hr_utility.trace('hrsumrep -  restrictions1c');
                 l_restriction_clause2 := REPLACE(l_restriction_clause,'aliasreplace',l_parameter_alias);
                 l_restriction_clause2 := REPLACE(l_restriction_clause2,'@',' ');
                 hr_utility.trace('hrsumrep -  restrictions1d');
                 -- write_stmt_log (p_stmt => 'l_restric2 = ' || l_restriction_clause2);
              else
                 hr_utility.trace('hrsumrep -  restrictions1e');
                 l_restriction_clause2 := REPLACE(l_restriction_clause,'@',l_alias);
              end if;

              hr_utility.trace('hrsumrep -  restrictions2');
              If l_character_after_brkt = concat('/','*parameteralias') then
                 l_where_clause := REPLACE(l_where_clause,'RESTRICTION.'||vrt.name||'['||l_alias||']',l_restriction_clause2);
                 --write_stmt_log (p_stmt => 'l_where_cla= ' || l_where_clause);
              else
                 l_where_clause := REPLACE(l_where_clause,'RESTRICTION.'||vrt.name||'['||l_alias||']',l_restriction_clause2);
              end if;

              l_restriction_clause2 := null;
          end loop;
          end if;
      end loop;
      -- Remove all references of RESTRICTION.<whatever> that are not valid
      -- for this item type.
      loop
          l_pos1 := nvl(instr(l_where_clause,'RESTRICTION.'),0);
          exit when l_pos1 = 0;
          l_pos2 := instr(l_where_clause,']',l_pos1,1)+1;
          l_where_clause := substr(l_where_clause,1,l_pos1-1)||substr(l_where_clause,l_pos2,length(l_where_clause));
      end loop;
      --
      hr_utility.trace('hrsumrep - complete restrictions');
      -- Concatenate the full dynamic statement
      --
      l_stmt := 'select '||
                 l_count_clause1 ||
                 l_count_clause2 ||
                 l_key_col_clause || '
'||
                 l_where_clause || '
'||
                 l_group_clause;
   --
   -- If the statement is going to be run any parameter values need to
   -- be substituted
   --
--   if p_store_data then
      if p_parameters.count > 0 then
         for i in p_parameters.first..p_parameters.last loop
             l_stmt := replace(l_stmt
                              ,p_parameters(i).name
                              ,p_parameters(i).value);
         end loop;
      end if;
--   end if;
--
   -- if we are running debug then we will need to substitute the parameters separately for
   -- the key col clause as we pass this as a separate parameter

     if p_debug = 'Y' and p_parameters.count > 0 then
        for i in p_parameters.first..p_parameters.last loop
            l_key_col_clause := replace(l_key_col_clause
                             ,p_parameters(i).name
                             ,p_parameters(i).value);
        end loop;
     end if;
   --

   p_statement := l_stmt;
--
   if p_store_data then
      hr_sum_store.store_data(p_business_group_id => p_business_group_id
                             ,p_item_name => ituTab(x).it_name
                             ,p_itu_name  => ituTab(x).itu_name
                             ,p_item_type_usage_id => l_item_type_usage_id
                             ,p_count_clause1 => l_count_clause1
                             ,p_count_clause2 => l_count_clause2
                             ,p_stmt => l_stmt
                             ,p_debug => p_debug
                             ,p_key_col_clause => l_key_col_clause
                             ,p_error => l_itu_error);
      if l_itu_error = 1 THEN
         p_retcode :=1; /* If item type fails then set status of process to warning */
      end if;

   end if; -- p_store_data
      end loop;
   end if;
   hr_utility.set_location('Leaving : hrumrep.process_run ', 10);
exception
when others then
  p_retcode :=2; /* unknown error, so set status to Error */
  write_error('Process Run error:');
  write_error(sqlcode);
  write_error(sqlerrm);
end process_run;
--
/* ------------------------------------------------------------------------
   Procedure BS_PROCESS
   Overloaded procedure designed to be used when called from the setup form
   ------------------------------------------------------------------------ */
procedure process_run(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug  varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2) is
l_retcode number;

begin
   process_run(p_business_group_id => p_business_group_id
              ,p_process_type => p_process_type
              ,p_template_id => p_template_id
              ,p_process_name => p_process_name
              ,p_parameters => hr_summary_util.nullprmTab
              ,p_item_type_usage_id => p_item_type_usage_id
              ,p_store_data => p_store_data
              ,p_statement => p_statement
              ,p_debug  => p_debug
              ,p_retcode => l_retcode);
end;
--
procedure process_run(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
   	             ,p_parameters hr_summary_util.prmTabType
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug  varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2) is

l_retcode number;

begin
   process_run(p_business_group_id => p_business_group_id
              ,p_process_type => p_process_type
              ,p_template_id => p_template_id
              ,p_process_name => p_process_name
              ,p_item_type_usage_id => p_item_type_usage_id
--bug 3008112 ,parameters => hr_summary_util.nullprmTab
              ,p_parameters => p_parameters
              ,p_store_data => p_store_data
              ,p_statement => p_statement
              ,p_debug  => p_debug
              ,p_retcode => l_retcode);
end;


procedure process_run_form(p_business_group_id number
                     ,p_process_type varchar2
                     ,p_template_id number
                     ,p_process_name varchar2
                     ,p_item_type_usage_id number default null
                     ,p_store_data boolean default FALSE
                     ,p_debug  varchar2 default 'N'
                     ,p_statement out NOCOPY varchar2) is
--
cursor c_get_item_type_usage(p_template_id number) is
select it.DATATYPE
,      it.count_clause1
,      it.count_clause2
,      it.where_clause
,      it.name  it_name
,      itu.name itu_name
,      itu.ITEM_TYPE_USAGE_ID
,      itu.ITEM_TYPE_ID
from   hr_summary_item_type_usage itu
,      hr_summary_item_type it
where  itu.template_id = p_template_id
and    itu.ITEM_TYPE_ID = it.ITEM_TYPE_ID
and    nvl(p_item_type_usage_id,item_type_usage_id) = item_type_usage_id
order by itu.sequence_number;
--
cursor c_get_key_type_usage(p_item_type_usage_id number) is
select kty.name
,      kty.key_function
,      kty.key_type_id
from   hr_summary_key_type_usage ktu
,      hr_summary_valid_key_type vkt
,      hr_summary_key_type kty
where  kty.key_type_id = vkt.key_type_id
and    ktu.valid_key_type_id = vkt.valid_key_type_id
and    ktu.item_type_usage_id = p_item_type_usage_id;
--
cursor c_get_restriction_usage(p_item_type_usage_id number) is
select srt.data_type
,      srt.restriction_clause
,      vru.restriction_type
,      vru.restriction_usage_id
,      srt.name
from   hr_summary_valid_restriction vrt
,      hr_summary_restriction_usage vru
,      hr_summary_restriction_type  srt
where  vrt.valid_restriction_id = vru.valid_restriction_id
and    vru.item_type_usage_id = p_item_type_usage_id
and    vrt.restriction_type_id = srt.restriction_type_id
and    srt.name <> 'USER_PERSON_TYPE';
--
cursor c_get_restriction_value(p_restriction_usage_id number) is
select value
from   hr_summary_restriction_value
where  restriction_usage_id = p_restriction_usage_id;
--
l_object_version_number number;
l_datatype varchar2(1);
l_stmt varchar2(32000);
l_item_type_usage_id number;
l_count_clause1 varchar2(32000);
l_count_clause2 varchar2(32000);
l_key_col_clause varchar2(32000);
l_where_clause varchar2(32000);
l_restriction_clause  varchar2(32000);
l_restriction_clause2 varchar2(32000);
l_restriction_value varchar2(80);
l_error_mesg varchar2(100);
l_group_clause varchar2(32000);
l_key_clause varchar2(32000);
l_comma varchar2(1);
l_tab_num varchar2(2);
l_error boolean;
i number;
l_itu_error  number; /* variable to check if item type usage occurred */
s1  number;
l_pos1  number;
l_pos2  number;
l_pos3  number;

l_alias varchar2(30);
l_parameter_alias varchar2(32000); -- require this length for the substr,instr to work
l_character_after_brkt varchar2(50);
--
source_cursor integer;
ignore integer;
--
begin
   -- Set STORE_DATA utility package global
   --
   hr_utility.set_location('Entering : hrumrep.process_run ', 5);
   hr_summary_util.store_data := p_store_data;
   --
   --
/* ------------------------------------------------------------------
   For each of the item types that are required for the selected template,
   retrieve the item type details
   ------------------------------------------------------------------ */
   i := 1;
   for itu in c_get_item_type_usage(p_template_id) loop
   --
   --
      ituTab(i).item_type_usage_id := itu.item_type_usage_id;
      ituTab(i).item_type_id := itu.item_type_id;
      ituTab(i).datatype := itu.datatype;
      ituTab(i).count_clause1 := itu.count_clause1;
      ituTab(i).count_clause2 := itu.count_clause2;
      ituTab(i).where_clause := itu.where_clause;
      ituTab(i).it_name := itu.it_name;
      ituTab(i).itu_name := itu.itu_name;
      --
      i := i + 1;
      --
   end loop;
--
/* ------------------------------------------------------------------
   Fo each item type usage retrieved
    a) delete any existing item values or key values for the item type usage
    b) build up the dynamic SQL statement and excute (if appropriate)
   ------------------------------------------------------------------ */
   if ituTab.count > 0 then
      <<itu_loop>>
      for x in 1..i-1 loop
          --
          -- Populate local and global variables
          --
          hr_summary_util.item_type_usage_id := ituTab(x).item_type_usage_id;
          l_item_type_usage_id := ituTab(x).item_type_usage_id;
          l_datatype := ituTab(x).datatype;
          --
          -- Delete existing results where appropriate
          --
/* ------------------------------------------------------------------
  Need to call Initialize procedure before evaluating the key functions because
  initialize_procedure populates the zero_item_value_id for the item_type being
  processed, the key functions subsequently reference it.
   ------------------------------------------------------------------   */
      hr_summary_util.initialize_procedure(p_business_group_id);
      --
      -- Initialize dynamic SQL components
       --
      l_stmt := null;
      l_count_clause1 := null;
      l_count_clause2 := null;
      l_key_col_clause := null;
      l_where_clause := null;
      l_restriction_clause := null;
      l_group_clause := null;
      --
      -- Begin determining the dynamic SQL components
      --
      hr_utility.trace('processing item ' || itutab(x).itu_name || ' ' || itutab(x).it_name);
      l_count_clause1 := ituTab(x).count_clause1 || ' col_value1 ';
      if ituTab(x).count_clause2 is not null then
         l_count_clause2 := ','||ituTab(x).count_clause2 || ' col_value2 ';
      end if;
      --
      -- Load the Key Types into a PLSQL table
      --
      i := 0;
      ktyTab := nullktyTab;
      for kty in c_get_key_type_usage(l_item_type_usage_id) loop
          ktyTab(i).key_type := kty.name;
          ktyTab(i).key_function := kty.key_function;
          ktyTab(i).key_type_id := kty.key_type_id;
          ktyTab(i).key_other := FALSE;
          i := i + 1;
      end loop;
      --
    /* -----------------------------------------------------------------
       If there are key types being used
       a) evaluate the function associated with the key type to return
          the group by clause
       b) build up the select clause
       c) build up the group by clause
      ----------------------------------------------------------------- */
    --
    hr_utility.trace('hrsumrep - keytab');
    if ktyTab.count > 0 then
      for i in ktyTab.first..ktyTab.last loop
        --
         l_stmt := 'declare key_type_id number := '||ktyTab(i).key_type_id||';
                   begin :l_clause   := '||ktyTab(i).key_function||';
                   end;';
        source_cursor := dbms_sql.open_cursor;
        begin
             l_error_mesg := fnd_message.get_string('PER','PER_74874_PARSE_ERROR');
             dbms_sql.parse(source_cursor,l_stmt,dbms_sql.v7);
             dbms_sql.bind_variable(source_cursor,'l_clause',l_key_clause, 32000);
             l_error_mesg := fnd_message.get_string('PER','PER_74875_EXECUTE_ERROR');
             ignore := dbms_sql.execute(source_cursor);
             l_error_mesg := fnd_message.get_string('PER','PER_74876_ASSIGN_VARIABLE');
             dbms_sql.variable_value(source_cursor,'l_clause',l_key_clause);
             dbms_sql.close_cursor(source_cursor);
        exception when others then
             if p_store_data then
                --p_retcode :=1; /* error occurred in key type. set status to warning */
                write_error(l_error_mesg);
                write_error(sqlerrm);
                --write_stmt_log (p_stmt => l_stmt);
                exit itu_loop;
             else
                null;
             end if;
        end;
          l_key_col_clause := l_key_col_clause || '
, '||                         l_key_clause || ' '||
                              'col_'||ktyTab(i).key_type ||' ';
          if l_group_clause is null then
             l_group_clause := ' group by ';
          else
             l_group_clause := l_group_clause ||'
,';
          end if;
          --
          l_group_clause := l_group_clause || l_key_clause;
      end loop;
    end if;

      --
      --
     hr_utility.trace('hrsumrep -  restrictions');
    /* -----------------------------------------------------------------
       If there are restrictions being used build up the restriction clause
      ----------------------------------------------------------------- */
      --
      l_where_clause := ituTab(x).where_clause;
      --
      for vrt in c_get_restriction_usage(l_item_type_usage_id) loop
          --
          l_pos1 := nvl(instr(l_where_clause,vrt.name||'['),0);

          if l_pos1 <> 0 then

          l_pos1 := l_pos1+length(vrt.name)+1;
          l_character_after_brkt := substr(l_where_clause,l_pos1,16);
          -- need to concatenate slash and asterisk otherwise check_sql will give error.
          If l_character_after_brkt = concat('/','*'|| 'parameteralias') then
             l_restriction_clause := ' and @'||vrt.restriction_clause || ' ' ||
                                  vrt.restriction_type || ' ';
             l_pos1 := l_pos1 + 17;
             l_pos2 := instr(l_where_clause,(concat('*','/]')),1);
             l_parameter_alias := substr(l_where_clause,l_pos1,(l_pos2-l_pos1));
          else
             l_restriction_clause := ' and @.'||vrt.restriction_clause || ' ' ||
                                  vrt.restriction_type || ' ';
          end if;
          --
          hr_utility.trace('hrsumrep -  restrictions1');
          l_comma := '(';
          for rvl in c_get_restriction_value(vrt.restriction_usage_id) loop
              if vrt.data_type = 'C' then
                 l_restriction_value := '''' || rvl.value || '''';
              elsif vrt.data_type = 'D' then
                 l_restriction_value := 'to_date('''|| rvl.value ||
                                                 ''',''YYYY/MM/DD HH24:MI:SS'')';
              elsif vrt.data_type = 'N' then
                 l_restriction_value := rvl.value;
              end if;
            --
              if vrt.restriction_type in ('=','<>','>','<') then
                 l_restriction_clause := l_restriction_clause ||
                                         l_restriction_value || ' ';
                 exit;
              else
                 l_restriction_clause := l_restriction_clause || l_comma ||
                                         l_restriction_value;
                 l_comma := ',';
              end if;
          end loop;
          --
          if vrt.restriction_type not in ('=','<>','>','<') then
             l_restriction_clause := l_restriction_clause || ')';
          end if;
          --
          -- Replace all occurences of RESTRICTION.<restriction_name>
          -- with the correct alias and restriction clause.
          loop


          l_pos3 := nvl(instr(l_where_clause,vrt.name||'['),0);
          l_pos3 := l_pos3+length(vrt.name)+1;
          l_character_after_brkt := substr(l_where_clause,l_pos3,16);
          If l_character_after_brkt = concat('/','*parameteralias') then
             l_pos3 := l_pos3 + 17;
             l_pos2 := instr(l_where_clause,concat('*','/]'),1);
             l_parameter_alias := substr(l_where_clause,l_pos3,(l_pos2-l_pos3));
          End if;

              l_pos1 := nvl(instr(l_where_clause,vrt.name||'['),0);
              exit when l_pos1 = 0;
              l_pos1 := l_pos1+length(vrt.name)+1;
              l_pos2 := instr(l_where_clause,']',l_pos1,1);
              hr_utility.trace('hrsumrep -  restrictions1b');
              hr_utility.trace('l_pos1 = ' || l_pos1 || ' ' || l_pos2);
              l_alias := substr(l_where_clause,l_pos1,l_pos2-l_pos1);
              hr_utility.trace('l_alias = ' || l_alias);
              if l_character_after_brkt = concat('/','*parameteralias') then
        --       l_alias := ' ';
                 hr_utility.trace('hrsumrep -  restrictions1c');
                l_restriction_clause2 := REPLACE(l_restriction_clause,'aliasreplace',l_parameter_alias);
                 l_restriction_clause2 := REPLACE(l_restriction_clause2,'@',' ');
                 hr_utility.trace('hrsumrep -  restrictions1d');
                 -- write_stmt_log (p_stmt => 'l_restric2 = ' || l_restriction_clause2);
              else
                 hr_utility.trace('hrsumrep -  restrictions1e');
                 l_restriction_clause2 := REPLACE(l_restriction_clause,'@',l_alias);
              end if;

              hr_utility.trace('hrsumrep -  restrictions2');
              If l_character_after_brkt = concat('/','*parameteralias') then
                 l_where_clause := REPLACE(l_where_clause,'RESTRICTION.'||vrt.name||'['||l_alias||']',l_restriction_clause2);                 --write_stmt_log (p_stmt => 'l_where_cla= ' || l_where_clause);
              else
                 l_where_clause := REPLACE(l_where_clause,'RESTRICTION.'||vrt.name||'['||l_alias||']',l_restriction_clause2);              end if;

              l_restriction_clause2 := null;
          end loop;
          end if;
      end loop;
      -- Remove all references of RESTRICTION.<whatever> that are not valid
      -- for this item type.
      loop
          l_pos1 := nvl(instr(l_where_clause,'RESTRICTION.'),0);
          exit when l_pos1 = 0;
          l_pos2 := instr(l_where_clause,']',l_pos1,1)+1;
          l_where_clause := substr(l_where_clause,1,l_pos1-1)||substr(l_where_clause,l_pos2,length(l_where_clause));
      end loop;
      --
      hr_utility.trace('hrsumrep - complete restrictions');
      -- Concatenate the full dynamic statement
      --
      l_stmt := 'select '||
                 l_count_clause1 ||
                 l_count_clause2 ||
                 l_key_col_clause || '
'||
                 l_where_clause || '
'||
                 l_group_clause;
       --
   p_statement := l_stmt;
--
      end loop;
   end if;
   hr_utility.set_location('Leaving : hrumrep.process_run ', 10);
exception
when others then
  write_error('Process Run error:');
  write_error(sqlcode);
  write_error(sqlerrm);
end process_run_form;
--

end hrsumrep;

/
