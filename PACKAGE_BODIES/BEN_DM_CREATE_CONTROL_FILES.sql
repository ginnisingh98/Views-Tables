--------------------------------------------------------
--  DDL for Package Body BEN_DM_CREATE_CONTROL_FILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_CREATE_CONTROL_FILES" AS
/* $Header: benfdmmctl.pkb 120.1 2006/05/04 07:02:53 nkkrishn noship $ */

procedure get_no_of_inp_files
(p_dir_name             in   varchar2,
 p_data_file            in   varchar2,
 p_no_of_files          out  nocopy number) is

l_file_exists    boolean;
l_dummy          number;
l_file_count     number := 0;

begin

--
-- assuming a max of 10 threads
--
for i in 1..10
loop
    l_file_exists := false;
    utl_file.fgetattr(p_dir_name,p_data_file||'.'||i,l_file_exists,l_dummy,l_dummy);
    if not l_file_exists then
       exit;
    elsif l_file_exists then
       l_file_count := l_file_count + 1;
    end if;
end loop;

p_no_of_files := l_file_count;

end get_no_of_inp_files;


procedure touch_files
(
 p_dir_name             in   varchar2,
 p_no_of_threads        in   number,
 p_data_file            in   varchar2,
 p_file_type            in   varchar2 default 'out')
is

l_file_exists    boolean;
l_dummy          number;
l_max_size    number := 32767;
l_file_handle utl_file.file_type;

begin

if p_file_type = 'in' then
   --assume a max of 10 threads
   for i in 1..10
   loop
       l_file_exists := false;
       utl_file.fgetattr(p_dir_name,p_data_file||'.'||i,l_file_exists,l_dummy,l_dummy);
       if not l_file_exists then
          null;
       elsif l_file_exists then
          l_file_handle := utl_file.fopen(p_dir_name,p_data_file||'.'||i,'w',l_max_size);
          utl_file.fclose(l_file_handle);
       end if;
   end loop;
else
  for i in 1..p_no_of_threads
  loop
      l_file_handle := utl_file.fopen(p_dir_name,p_data_file||'.out'||i,'w',l_max_size);
      utl_file.fclose(l_file_handle);
  end loop;
end if;

exception
   when others then
        if utl_file.is_open(l_file_handle) then
            utl_file.fclose(l_file_handle);
        end if;

end touch_files;

procedure main
(
 p_dir_name             in   varchar2,
 p_no_of_threads        in   number,
 p_transfer_file        in   varchar2 default null,
 p_data_file             in   varchar2 default null
) is

cursor c1 is
select tab.table_name,
       tab.column_name
  from sys.all_tab_columns tab
 where tab.table_name in ('BEN_DM_INPUT_FILE','BEN_DM_RESOLVE_MAPPINGS')
   and tab.column_name not in
      ('LAST_UPDATE_DATE',
       'LAST_UPDATED_BY',
       'LAST_UPDATE_LOGIN',
       'CREATED_BY',
       'CREATION_DATE')
order by tab.table_name,tab.column_id;
c1_rec c1%rowtype;

cursor c2 is
select tab.table_name,
       tab.column_name
  from sys.all_tab_columns tab
 where tab.table_name in ('BEN_DM_ENTITY_RESULTS')
   and tab.column_name not in
      ('LAST_UPDATE_DATE',
       'LAST_UPDATED_BY',
       'LAST_UPDATE_LOGIN',
       'CREATED_BY',
       'CREATION_DATE')
order by tab.column_id;
c2_rec c2%rowtype;

cursor c3 is
select tab.table_name,
       tab.column_name
  from ben_dm_tables bdt,
       ben_dm_column_mappings map,
       sys.all_tab_columns tab
 where tab.table_name in ('PER_ALL_PEOPLE_F')
   and bdt.table_name = tab.table_name
   and map.table_id = bdt.table_id
   and map.column_name = tab.column_name
order by tab.column_id;
c3_rec c3%rowtype;

cursor c4 is
select tab.table_name,
       tab.column_name
  from ben_dm_tables bdt,
       ben_dm_column_mappings map,
       sys.all_tab_columns tab
 where tab.table_name in
('PER_CONTACT_RELATIONSHIPS',
 'PER_ALL_ASSIGNMENTS_F',
 'BEN_PTNL_LER_FOR_PER',
 'BEN_PER_IN_LER',
 'BEN_PIL_ELCTBL_CHC_POPL')
   and bdt.table_name = tab.table_name
   and map.table_id = bdt.table_id
   and map.column_name = tab.column_name
order by tab.table_name,tab.column_id;
c4_rec c4%rowtype;

cursor c5 is
select tab.table_name,
       tab.column_name
  from ben_dm_tables bdt,
       ben_dm_column_mappings map,
       sys.all_tab_columns tab
 where tab.table_name in
('PER_ADDRESSES',
 'PER_PERIODS_OF_SERVICE',
 'PER_PERSON_TYPE_USAGES_F',
 'PER_ASSIGNMENT_EXTRA_INFO',
 'PAY_ELEMENT_ENTRIES_F',
 'PAY_ELEMENT_ENTRY_VALUES_F',
 'PAY_RUN_RESULTS',
 'PAY_RUN_RESULT_VALUES',
 'BEN_CBR_QUALD_BNF',
 'BEN_CBR_PER_IN_LER',
 'BEN_PER_CM_F',
 'BEN_PER_CM_PRVDD_F',
 'BEN_PER_CM_TRGR_F',
 'BEN_PER_CM_USG_F',
 'BEN_PER_BNFTS_BAL_F',
 'BEN_PRTT_ENRT_RSLT_F',
 'BEN_PRTT_PREM_F',
 'BEN_PRTT_PREM_BY_MO_F',
 'BEN_PRTT_RT_VAL',
 'BEN_ELIG_CVRD_DPNT_F',
 'BEN_ELIG_DPNT',
 'BEN_PRTT_ENRT_ACTN_F',
 'BEN_PRTT_ENRT_CTFN_PRVDD_F',
 'BEN_ENRT_BNFT',
 'BEN_ENRT_PREM',
 'BEN_ENRT_RT',
 'BEN_ELCTBL_CHC_CTFN',
 'BEN_LE_CLSN_N_RSTR',
 'BEN_PRMRY_CARE_PRVDR_F',
 'PER_ABSENCE_ATTENDANCES')
   and bdt.table_name = tab.table_name
   and map.table_id = bdt.table_id
   and map.column_name = tab.column_name
order by tab.table_name,tab.column_id;
c5_rec c5%rowtype;

cursor c6 is
select tab.table_name,
       tab.column_name
  from ben_dm_tables bdt,
       ben_dm_column_mappings map,
       sys.all_tab_columns tab
 where tab.table_name in
('BEN_ELIG_PER_F',
 'BEN_ELIG_PER_OPT_F')
   and bdt.table_name = tab.table_name
   and map.table_id = bdt.table_id
   and map.column_name = tab.column_name
order by tab.table_name,tab.column_id;
c6_rec c6%rowtype;

cursor c7 is
select tab.table_name,
       tab.column_name
  from ben_dm_tables bdt,
       ben_dm_column_mappings map,
       sys.all_tab_columns tab
 where tab.table_name in
('BEN_ELIG_PER_ELCTBL_CHC')
   and bdt.table_name = tab.table_name
   and map.table_id = bdt.table_id
   and map.column_name = tab.column_name
order by tab.table_name,tab.column_id;
c7_rec c7%rowtype;

type t_in_file     is table of varchar2(255) index by binary_integer;
l_in_file        t_in_file;
l_prev_tab_name  varchar2(30);
l_file_handle utl_file.file_type;
l_max_size    number := 32767;
l_file_exists boolean;
l_dummy       number;

begin

ben_dm_utility.message('ROUT','entry:ben_dm_create_control_files.main', 5);

  touch_files
  (p_dir_name             => p_dir_name,
   p_no_of_threads        => p_no_of_threads,
   p_data_file            => p_data_file);

l_file_handle := utl_file.fopen(p_dir_name,'pm00.ctl','w',l_max_size);

open c1;
loop
   fetch c1 into c1_rec;
   if c1%notfound then
      exit;
   end if;

   if c1%rowcount = 1 then
      utl_file.put_line(l_file_handle,'load data');
      utl_file.put_line(l_file_handle,'infile "'||p_dir_name||'/'||p_transfer_file||'"');
      utl_file.put_line(l_file_handle,'replace');
   end if;

   if c1_rec.table_name <> nvl(l_prev_tab_name,'-1') then
      if l_prev_tab_name is not null then
         utl_file.put_line(l_file_handle,')');
      end if;
      utl_file.put_line(l_file_handle,'into table '||c1_rec.table_name);
      utl_file.put_line(l_file_handle,'when fillertabname="'||c1_rec.table_name||'"');
      utl_file.put_line(l_file_handle,'fields terminated by '||''''||fnd_global.local_chr(01)||'''');
      utl_file.put_line(l_file_handle,'TRAILING NULLCOLS');
      utl_file.put_line(l_file_handle,'(fillertabname    FILLER POSITION(1) CHAR');
      l_prev_tab_name := c1_rec.table_name;
   end if;
   utl_file.put_line(l_file_handle,','||c1_rec.column_name);


end loop;
close c1;
utl_file.put_line(l_file_handle,')');
utl_file.fclose(l_file_handle);

l_file_handle := utl_file.fopen(p_dir_name,'pm01.ctl','w',l_max_size);

--
-- assuming a max of 10 threads
--
for i in 1..10
loop
    l_file_exists := false;
    utl_file.fgetattr(p_dir_name,p_data_file||'.'||i,l_file_exists,l_dummy,l_dummy);
    if not l_file_exists then
       exit;
    elsif l_file_exists then
       l_in_file(i) := 'infile "'||p_dir_name||'/'||p_data_file||'.'||i||'"';
    end if;
end loop;

if l_in_file.count = 0 then
   return;
end if;

open c2;
loop
   fetch c2 into c2_rec;
   if c2%notfound then
      exit;
   end if;

   if c2%rowcount = 1 then
      utl_file.put_line(l_file_handle,'unrecoverable');
      utl_file.put_line(l_file_handle,'load data');
      if l_in_file is null then
         exit;
      end if;

      for i in 1..l_in_file.count
      loop
         utl_file.put_line(l_file_handle,l_in_file(i));
      end loop;
      utl_file.put_line(l_file_handle,'replace');
      utl_file.put_line(l_file_handle,'into table '||c2_rec.table_name);
      utl_file.put_line(l_file_handle,'fields terminated by '||''''||fnd_global.local_chr(01)||'''');
      utl_file.put_line(l_file_handle,'TRAILING NULLCOLS');
      utl_file.put_line(l_file_handle,'('||c2_rec.column_name);
   else
      utl_file.put_line(l_file_handle,','||c2_rec.column_name);
   end if;


end loop;
close c2;
utl_file.put_line(l_file_handle,')');
utl_file.fclose(l_file_handle);

l_file_handle := utl_file.fopen(p_dir_name,'pm02.ctl','w',l_max_size);

l_in_file.delete;

for i in 1..p_no_of_threads
loop
    l_in_file(i) := 'infile "'||p_dir_name||'/'||p_data_file||'.out'||i||'"';
end loop;

if l_in_file.count = 0 then
   return;
end if;

open c3;
loop
   fetch c3 into c3_rec;
   if c3%notfound then
      exit;
   end if;

   if c3%rowcount = 1 then
      utl_file.put_line(l_file_handle,'load data');
      if l_in_file is null then
         exit;
      end if;

      for i in 1..l_in_file.count
      loop
         utl_file.put_line(l_file_handle,l_in_file(i));
      end loop;
      utl_file.put_line(l_file_handle,'append');
      utl_file.put_line(l_file_handle,'into table '||c3_rec.table_name);
      utl_file.put_line(l_file_handle,'when fillertabname="'||c3_rec.table_name||'"');
      utl_file.put_line(l_file_handle,'fields terminated by '||''''||fnd_global.local_chr(01)||'''');
      utl_file.put_line(l_file_handle,'TRAILING NULLCOLS');
      utl_file.put_line(l_file_handle,'(fillertabname    FILLER POSITION(1) CHAR');
      utl_file.put_line(l_file_handle,','||c3_rec.column_name||'      "ben_dm_create_control_files.set_dm_flag(:'||c3_rec.column_name||')"');
   else
      utl_file.put_line(l_file_handle,','||c3_rec.column_name);
   end if;


end loop;
close c3;
utl_file.put_line(l_file_handle,')');
utl_file.fclose(l_file_handle);

l_file_handle := utl_file.fopen(p_dir_name,'pm03.ctl','w',l_max_size);

open c4;
loop
   fetch c4 into c4_rec;
   if c4%notfound then
      exit;
   end if;

   if c4%rowcount = 1 then
      utl_file.put_line(l_file_handle,'unrecoverable');
      utl_file.put_line(l_file_handle,'load data');
      for i in 1..l_in_file.count
      loop
         utl_file.put_line(l_file_handle,l_in_file(i));
      end loop;
      utl_file.put_line(l_file_handle,'append');
      l_prev_tab_name := null;
   end if;

   if c4_rec.table_name <> nvl(l_prev_tab_name,'-1') then
      if l_prev_tab_name is not null then
         utl_file.put_line(l_file_handle,')');
      end if;
      utl_file.put_line(l_file_handle,'into table '||c4_rec.table_name);
      utl_file.put_line(l_file_handle,'reenable');
      utl_file.put_line(l_file_handle,'when fillertabname="'||c4_rec.table_name||'"');
      utl_file.put_line(l_file_handle,'fields terminated by '||''''||fnd_global.local_chr(01)||'''');
      utl_file.put_line(l_file_handle,'TRAILING NULLCOLS');
      utl_file.put_line(l_file_handle,'(fillertabname    FILLER POSITION(1) CHAR');
      l_prev_tab_name := c4_rec.table_name;
   end if;
   utl_file.put_line(l_file_handle,','||c4_rec.column_name);


end loop;
close c4;
utl_file.put_line(l_file_handle,')');
utl_file.fclose(l_file_handle);

l_file_handle := utl_file.fopen(p_dir_name,'pm04.ctl','w',l_max_size);

l_in_file.delete;
for i in 1..p_no_of_threads
loop
    l_in_file(i) := 'infile "'||p_dir_name||'/discardfile1'||i||'.dat"';
end loop;

if l_in_file.count = 0 then
   return;
end if;


open c5;
loop
   fetch c5 into c5_rec;
   if c5%notfound then
      exit;
   end if;

   if c5%rowcount = 1 then
      utl_file.put_line(l_file_handle,'unrecoverable');
      utl_file.put_line(l_file_handle,'load data');
      for i in 1..l_in_file.count
      loop
         utl_file.put_line(l_file_handle,l_in_file(i));
      end loop;
      utl_file.put_line(l_file_handle,'append');
      l_prev_tab_name := null;
   end if;

   if c5_rec.table_name <> nvl(l_prev_tab_name,'-1') then
      if l_prev_tab_name is not null then
         utl_file.put_line(l_file_handle,')');
         utl_file.put_line(l_file_handle,'');
      end if;
      utl_file.put_line(l_file_handle,'into table '||c5_rec.table_name);
      utl_file.put_line(l_file_handle,'reenable');
      utl_file.put_line(l_file_handle,'when fillertabname="'||c5_rec.table_name||'"');
      utl_file.put_line(l_file_handle,'fields terminated by '||''''||fnd_global.local_chr(01)||'''');
      utl_file.put_line(l_file_handle,'TRAILING NULLCOLS');
      utl_file.put_line(l_file_handle,'(fillertabname    FILLER POSITION(1) CHAR');
      l_prev_tab_name := c5_rec.table_name;
   end if;
   utl_file.put_line(l_file_handle,','||c5_rec.column_name);


end loop;
close c5;
utl_file.put_line(l_file_handle,')');
utl_file.fclose(l_file_handle);

l_file_handle := utl_file.fopen(p_dir_name,'pm05.ctl','w',l_max_size);

l_in_file.delete;

for i in 1..p_no_of_threads
loop
    l_in_file(i) := 'infile "'||p_dir_name||'/'||p_data_file||'.out'||i||'" discardfile "'||p_dir_name||'/discardfile0'||i||'.dat"';
end loop;

if l_in_file.count = 0 then
   return;
end if;

open c6;
loop
   fetch c6 into c6_rec;
   if c6%notfound then
      exit;
   end if;

   if c6%rowcount = 1 then
      utl_file.put_line(l_file_handle,'unrecoverable');
      utl_file.put_line(l_file_handle,'load data');
      for i in 1..l_in_file.count
      loop
         utl_file.put_line(l_file_handle,l_in_file(i));
      end loop;
      utl_file.put_line(l_file_handle,'append');
      l_prev_tab_name := null;
   end if;

   if c6_rec.table_name <> nvl(l_prev_tab_name,'-1') then
      if l_prev_tab_name is not null then
         utl_file.put_line(l_file_handle,')');
         utl_file.put_line(l_file_handle,'');
      end if;
      utl_file.put_line(l_file_handle,'into table '||c6_rec.table_name);
      utl_file.put_line(l_file_handle,'reenable');
      utl_file.put_line(l_file_handle,'when fillertabname="'||c6_rec.table_name||'"');
      utl_file.put_line(l_file_handle,'fields terminated by '||''''||fnd_global.local_chr(01)||'''');
      utl_file.put_line(l_file_handle,'TRAILING NULLCOLS');
      utl_file.put_line(l_file_handle,'(fillertabname    FILLER POSITION(1) CHAR');
      l_prev_tab_name := c6_rec.table_name;
   end if;
   utl_file.put_line(l_file_handle,','||c6_rec.column_name);


end loop;
close c6;
utl_file.put_line(l_file_handle,')');
utl_file.fclose(l_file_handle);

l_file_handle := utl_file.fopen(p_dir_name,'pm06.ctl','w',l_max_size);

l_in_file.delete;

for i in 1..p_no_of_threads
loop
    l_in_file(i) := 'infile "'||p_dir_name||'/'||'discardfile0'||i||'.dat" discardfile "'||p_dir_name||'/discardfile1'||i||'.dat"';
end loop;

if l_in_file.count = 0 then
   return;
end if;

open c7;
loop
   fetch c7 into c7_rec;
   if c7%notfound then
      exit;
   end if;

   if c7%rowcount = 1 then
      utl_file.put_line(l_file_handle,'unrecoverable');
      utl_file.put_line(l_file_handle,'load data');
      for i in 1..l_in_file.count
      loop
         utl_file.put_line(l_file_handle,l_in_file(i));
      end loop;
      utl_file.put_line(l_file_handle,'append');
      utl_file.put_line(l_file_handle,'into table '||c7_rec.table_name);
      utl_file.put_line(l_file_handle,'reenable');
      utl_file.put_line(l_file_handle,'when fillertabname="'||c7_rec.table_name||'"');
      utl_file.put_line(l_file_handle,'fields terminated by '||''''||fnd_global.local_chr(01)||'''');
      utl_file.put_line(l_file_handle,'TRAILING NULLCOLS');
      utl_file.put_line(l_file_handle,'(fillertabname    FILLER POSITION(1) CHAR');
   end if;
   utl_file.put_line(l_file_handle,','||c7_rec.column_name);


end loop;
close c7;
utl_file.put_line(l_file_handle,')');
utl_file.fclose(l_file_handle);

ben_dm_utility.message('ROUT','exit:ben_dm_create_control_files.main', 5);

end main;

procedure rebuild_indexes is

cursor c1 is
select index_name,
       owner
  from sys.all_indexes
 where (index_name like 'BEN%'
        or index_name like 'HR%'
        or index_name like 'PAY%'
        or index_name like 'PER%')
  and status = 'UNUSABLE';
c1_rec c1%rowtype;

begin

ben_dm_utility.message('ROUT','entry:ben_dm_create_control_files.rebuild_indexes', 5);
open c1;
loop
   fetch c1 into c1_rec;
   if c1%notfound then
      exit;
   end if;

   ben_dm_utility.message('INFO','rebuilding index '||c1_rec.index_name, 5);
   execute immediate 'alter index '||c1_rec.owner||'.'||c1_rec.index_name||' rebuild';

end loop;
close c1;

open c1;
fetch c1 into c1_rec;
if c1%found then
   ben_dm_utility.message('INFO','some indexes failed to rebuild',5);
end if;
close c1;

ben_dm_utility.message('ROUT','exit:ben_dm_create_control_files.rebuild_indexes', 5);
end rebuild_indexes;

function set_dm_flag(p_person_id number)
return number is
begin
   hr_general.g_data_migrator_mode := 'Y';
   return p_person_id;
end set_dm_flag;

end ben_dm_create_control_files;

/
