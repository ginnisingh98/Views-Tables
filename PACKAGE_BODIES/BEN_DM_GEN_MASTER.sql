--------------------------------------------------------
--  DDL for Package Body BEN_DM_GEN_MASTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DM_GEN_MASTER" AS
/* $Header: benfdmgenm.pkb 120.0 2006/05/04 04:48:29 nkkrishn noship $ */
g_package  varchar2(50) := 'ben_dm_gen_master.' ;
type numTab  is table of number index by binary_integer;
type charTab is table of varchar2(60) index by binary_integer;
t_tab_short_name         charTab;


procedure main_generator
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number ,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2 default fnd_global.local_chr(01),
 p_business_group_id    in   number default null
)
is

-- used for indexing of pl/sql table.
l_count      number;
l_generator_version       ben_dm_tables.generator_version%type;

l_phase_item_id           ben_dm_phase_items.phase_item_id%type;
l_phase_id                ben_dm_phases.phase_id%type;

l_current_phase_status    varchar2(30);
e_fatal_error             exception;
e_fatal_error2            exception;
l_fatal_error_message     varchar2(200);
l_missing_who_info        varchar2(1);
l_no_of_threads           number;
l_last_migration_date     date  ;

-- cursor to get table for which TUPS/TDS have to be genrated

cursor csr_get_table is
select tbl.table_id
      ,tbl.table_name
      ,tbl.table_alias
      ,phs.phase_id
      ,itm.phase_item_id
from ben_dm_tables tbl,
     ben_dm_phase_items itm,
     ben_dm_phases  phs
where phs.migration_id = p_migration_id
and   phs.phase_name   = 'G'
and   phs.phase_id     = itm.phase_id
and   mod(itm.phase_item_id,l_no_of_threads) + 1 = p_process_number
and   itm.status       = 'NS'
and   itm.table_name   = tbl.table_name
and   rownum < 2;


l_csr_get_table_rec        csr_get_table%rowtype;
l_proc   varchar2(75) ;



begin

  l_proc    :=   g_package  || 'main_generator' ;

  hr_utility.set_location('Entering:'||l_proc, 5);


  l_last_migration_date   := to_date(p_last_migration_date, 'YYYY/MM/DD HH24:MI:SS');
  -- initialize messaging
  if p_concurrent_process = 'Y' then
     ben_dm_utility.message_init;
  end if;

  ben_dm_utility.message('ROUT','entry:'||l_proc , 5);
  ben_dm_utility.message('PARA','(errbuf - ' || errbuf ||
                             ')(retcode - ' || retcode ||
                             ')(p_migration_id - ' || p_migration_id ||
                             ')(p_concurrent_process - ' || p_concurrent_process ||
                             ')(p_last_migration_date - '|| l_last_migration_date ||
                             ')', 10);

 l_no_of_threads := ben_dm_utility.number_of_threads(p_business_group_id);

 -- assign the default to 3
 if l_no_of_threads is null then
    l_no_of_threads := 3 ;
 end  if ;
 -- initialise the counter.
 l_count := 1;
 --
 -- Get the table for which TUPS/TDS has to be generated
 --
 loop
   l_phase_item_id := NULL;

   --
   -- get status of generate phase. If phase has error status set by other slave
   -- process then we need to stop the processing of this slave.
   -- if null returned, then assume it is not started.
   --
   l_current_phase_status := nvl(ben_dm_utility.get_phase_status('G',p_migration_id), 'NS');

   -- if status is error, then raise an exception
   if (l_current_phase_status = 'E') then
     l_fatal_error_message := 'Encountered error in generator phase caused by ' ||
                              'another process - slave exiting';
     raise e_fatal_error2;
   end if;

   open csr_get_table;
   fetch csr_get_table into l_csr_get_table_rec;
   if csr_get_table%notfound then
     close csr_get_table;
     exit;
   end if;
   close csr_get_table;

   -- update status to started
   ben_dm_utility.update_phase_items(p_new_status => 'S',
                                       p_id => l_csr_get_table_rec.phase_item_id);

   l_phase_item_id := l_csr_get_table_rec.phase_item_id;
   l_phase_id      := l_csr_get_table_rec.phase_id;


   ben_dm_utility.message('INFO','Started Generating TUPS/TDS for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,20);

   ben_dm_utility.message('SUMM','Started Generating TUPS/TDS for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,30);
   --
   -- Call TUPS genrator to create TUPS for the table
   --
   hr_utility.set_location('Calling Upload for :'||l_csr_get_table_rec.table_alias , 40);
   ben_dm_utility.message('INFO',' Started Generating TUPS  for ' ||
                                                   l_csr_get_table_rec.table_name,50);

   BEN_DM_GEN_UPLOAD.main (
                           p_table_alias            =>   l_csr_get_table_rec.table_alias ,
                           p_migration_id           =>   p_migration_id
                           );


   ben_dm_utility.message('INFO',' Successfully Generated TUPS  for ' ||
                                                   l_csr_get_table_rec.table_name,60);
   --
   --
   -- Call TDS generator to create TDS for the table
   --
   ben_dm_utility.message('INFO',' Started Generating TDS  for ' ||
                                                   l_csr_get_table_rec.table_name,70);

   hr_utility.set_location('Calling Download for :'||l_csr_get_table_rec.table_alias , 10);

   BEN_DM_GEN_DOWNLOAD.main (
                             p_table_alias            =>   l_csr_get_table_rec.table_alias,
                             p_migration_id           =>   p_migration_id
                             ) ;

   l_count := l_count + 1;

   -- get generator version used to generated this TUPS/TDS
   hr_dm_library.get_generator_version(l_generator_version);
   --
   -- update the last generated date for TUP/TDS for this table in hr_dm_tables
   --
   update ben_dm_tables
   set last_generated_date = sysdate,
       generator_version   = l_generator_version
   where table_id = l_csr_get_table_rec.table_id;

   -- update status to completed
   ben_dm_utility.update_phase_items(p_new_status => 'C',
                                    p_id => l_phase_item_id);

   ben_dm_utility.message('INFO','Generated TUPS/TDS succesfully  for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,110);

   ben_dm_utility.message('SUMM','Generated TUPS/TDS successfully for ' ||
                         l_csr_get_table_rec.table_name || ', Table Id - ' ||
                         l_csr_get_table_rec.table_id,120);

 end loop;
/*
 -- when the process number is one call for generating self reference
 -- package
 if p_process_number = 1 then

   ben_dm_utility.message('INFO',' Started Generating ben_dm_resolve_reference  '  ,130);
   BEN_DM_GEN_SELF_REF.main( p_business_group_id      =>   p_business_group_id ,
                             p_migration_id           =>   p_migration_id
                           )  ;
   ben_dm_utility.message('INFO',' Generated ben_dm_resolve_reference  '  ,140);
 end if ;
*/

 -- set up return values to concurrent manager
 retcode := 0;
 errbuf := 'No errors - examine logfiles for detailed reports.';

 ben_dm_utility.message('ROUT','exit:' || l_proc , 150);
 hr_utility.set_location('Leaving:'||l_proc, 10);
-- error handling
exception
when e_fatal_error then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
  ben_dm_utility.error(SQLCODE,l_proc , l_fatal_error_message,'R');

  -- if the error is caused because the other process has set the generator phase to 'Error'
  -- then the phase_item_id is 'NULL' , otherwise, the error is caused within this process
  -- while generating TUPS/TDS.

  if l_phase_item_id is not null then
     ben_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  else
     ben_dm_utility.update_phases(p_new_status => 'E',
                                 p_id => l_phase_id);
  end if;

  ben_dm_utility.error(SQLCODE,l_proc,'(none)','R');
when e_fatal_error2 then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
  retcode := 0;
  errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
  ben_dm_utility.error(SQLCODE,l_proc , l_fatal_error_message,'R');

  -- if the error is caused because the other process has set the generator phase to 'Error'
  -- then the phase_item_id is 'NULL' , otherwise, the error is caused within this process
  -- while generating TUPS/TDS.

  if l_phase_item_id is not null then
     ben_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  else
     ben_dm_utility.update_phases(p_new_status => 'E',
                                 p_id => l_phase_id);
  end if;

  ben_dm_utility.error(SQLCODE,l_proc,'(none)','R');
when others then
  if csr_get_table%isopen then
    close csr_get_table;
  end if;
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
-- update status to error
  ben_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  ben_dm_utility.error(SQLCODE,l_proc,'(none)','R');


end main_generator ;


Procedure   download
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2 default fnd_global.local_chr(01),
 p_business_group_id    in   number  default null
) is


l_proc  varchar2(75) ;
l_no_of_threads           number;

-- cursor to get table for which

cursor csr_get_table is
select tbl.short_name
from ben_dm_tables tbl,
     ben_dm_table_order  dto
where tbl.table_id     = dto.table_id
order by   dto.table_order ;


cursor c_input_file(p_input_file_id number) is
select dif.input_file_id
      ,dif.source_business_group_name
      ,dif.source_person_id
      ,dif.source_national_identifier
      ,dif.target_business_group_name
      ,dif.group_order
  from ben_dm_input_file dif
where  dif.input_file_id= p_input_file_id ;

cursor c_input_file2 is
select itm.phase_item_id
      ,itm.input_file_id
  from ben_dm_phase_items itm,
       ben_dm_phases  phs
where  phs.migration_id = p_migration_id
  and  phs.phase_name   = 'DP'
  and  phs.phase_id     = itm.phase_id
  and  mod(itm.phase_item_id,l_no_of_threads) + 1 = p_process_number
  and  itm.status       = 'NS' ;

cursor c_bg (l_name varchar2)  is
select business_group_id
from   per_business_groups
where name =  l_name ;

l_csr_get_table_rec      csr_get_table%rowtype;
t_phase_item_id          numTab;
t_input_file_id          numTab;
l_input_file_rec         c_input_file%rowtype;
l_last_migration_date    date  ;
l_fatal_error_message    varchar2(200);
l_max_ext                number := 32767;
l_pre_fix                varchar2(10) ;
l_short_name             ben_dm_tables.short_name%type ;
l_business_group_id      number ;
l_phase_item_id          number ;
l_phase_id               number ;
l_current_phase_status   varchar2(10) ;
lstring                  varchar2(4000) ;
l_rec_downloaded         number ;
e_fatal_error            exception;
e_fatal_error2           exception;

begin
 l_proc  := g_package || 'download' ;
 hr_utility.set_location('Entering:'||l_proc, 10);
 hr_general.g_data_migrator_mode := 'Y';
 l_pre_fix  := 'BEN_DMD' ;
 l_last_migration_date   := to_date(p_last_migration_date, 'YYYY/MM/DD HH24:MI:SS');
 -- initialize messaging
 if p_concurrent_process = 'Y' then
    ben_dm_utility.message_init;
 end if;

 --open file handler
 g_file_handle := utl_file.fopen(p_dir_name,p_file_name||'.'||p_process_number,'w',l_max_ext);

 ben_dm_utility.message('ROUT','entry:'||l_proc , 5);
 ben_dm_utility.message('PARA','(errbuf - ' || errbuf ||
                             ')(retcode - ' || retcode ||
                             ')(p_migration_id - ' || p_migration_id ||
                             ')(p_concurrent_process - ' || p_concurrent_process ||
                             ')(p_last_migration_date - '|| l_last_migration_date ||
                             ')(p_process_number - '     || p_process_number ||
                             ')(p_business_group_id - '|| p_business_group_id ||
                             ')', 10);

 l_no_of_threads := ben_dm_utility.number_of_threads(p_business_group_id);
 -- assign the default to 3
 if l_no_of_threads is null then
    l_no_of_threads := 3 ;
 end  if ;
 --
 open c_input_file2;
 fetch c_input_file2 bulk collect into t_phase_item_id,t_input_file_id;
 close c_input_file2;

 open csr_get_table;
 fetch csr_get_table bulk collect into t_tab_short_name;
 close csr_get_table;

 for i in 1..t_phase_item_id.count
 loop
    l_phase_item_id := t_phase_item_id(i);

    --
    -- get status of generate phase. If phase has error status set by other slave
    -- process then we need to stop the processing of this slave.
    -- if null returned, then assume it is not started.
    --
    l_current_phase_status := nvl(ben_dm_utility.get_phase_status('DP',p_migration_id), 'NS');

    -- if status is error, then raise an exception
    if (l_current_phase_status = 'E') then
      l_fatal_error_message := 'Encountered error in download  phase caused by ' ||
                               'another process - slave exiting';
      raise e_fatal_error2;
    end if;


    open c_input_file(t_input_file_id(i));
    fetch c_input_file into l_input_file_rec;
    close c_input_file;

    l_business_group_id :=  null;

    open c_bg(l_input_file_rec.source_business_group_name) ;
    fetch c_bg into l_business_group_id ;
    close c_bg ;

    ben_dm_utility.message('INFO','Source Business Group ID  :'||l_business_group_id , 30);

    if l_business_group_id is null then
       l_fatal_error_message := 'Encountered error in download  Source Business Group ' || l_input_file_rec.SOURCE_BUSINESS_GROUP_NAME || ' not found ! ';
            raise e_fatal_error2;
     end if ;

    -- update status to started
     ben_dm_utility.update_phase_items(p_new_status => 'S',
                                       p_id => l_phase_item_id);


    ben_dm_utility.message('INFO','Started download data for ' ||
                          l_input_file_rec.source_person_id || ', SSN  - ' ||
                          l_input_file_rec.SOURCE_NATIONAL_IDENTIFIER,40);

    ben_dm_utility.message('SUMM','Started download data for ' ||
                          l_input_file_rec.source_person_id || ', SSN  - ' ||
                          l_input_file_rec.SOURCE_NATIONAL_IDENTIFIER,50);


    -- for every person loop through   tables
    for i in  1..t_tab_short_name.count
    Loop

        lstring := 'Begin  ' ||  l_pre_fix||t_tab_short_name(i)||'.DOWNLOAD(' ;
        lstring := lstring  || 'p_migration_id         => :1 '   ;
        lstring := lstring  || ',p_business_group_id   => :2 '   ;
        lstring := lstring  || ',p_business_group_name => :3 '   ;
        lstring := lstring  || ',p_person_id           => :4 '   ;
        lstring := lstring  || ',p_group_order         => :5 '   ;
        lstring := lstring  || ',p_rec_downloaded      => :6  ) ;  END ; ' ;

        ben_dm_utility.message('INFO','calling download procedure   :'||l_pre_fix||t_tab_short_name(i)||'.DOWNALOAD' , 5);

        begin
             execute immediate lstring using
             p_migration_id,
             l_business_group_id ,
             l_input_file_rec.target_business_group_name,
             l_input_file_rec.source_person_id,
             l_input_file_rec.group_order ,
             OUT  l_rec_downloaded ;
        exception
          when others then
             ben_dm_utility.message('INFO','calling download procedure SQL error '   , 60);
             ben_dm_utility.message('INFO', substr(sqlerrm,1,150)   , 60);
           l_fatal_error_message := 'Encountered error in  download  phase caused by ' || t_tab_short_name(i) ;
             raise e_fatal_error2;

        end;
        ben_dm_utility.message('INFO','download completed for  :'||t_tab_short_name(i) , 70);

    end loop ;

    ben_dm_utility.update_phase_items(p_new_status => 'C',
                                     p_id => l_phase_item_id);

    ben_dm_utility.message('INFO','Downloaded  succesfully  for ' ||
                          l_input_file_rec.source_person_id || ', SSN  - ' ||
                          l_input_file_rec.SOURCE_NATIONAL_IDENTIFIER,80);


    ben_dm_utility.message('SUMM','Downloaded  succesfully  for ' ||
                          l_input_file_rec.source_person_id || ', SSN  - ' ||
                          l_input_file_rec.SOURCE_NATIONAL_IDENTIFIER,90);

 End Loop ;
 hr_general.g_data_migrator_mode := 'N';
 hr_utility.set_location('Leaving:'||l_proc, 10);
 ben_dm_utility.message('ROUT','EXIT   ' || l_proc ,100);
 Exception

   when e_fatal_error2 then
      hr_general.g_data_migrator_mode := 'N';
      retcode := 0;
      errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
      ben_dm_utility.error(SQLCODE,l_proc , l_fatal_error_message,'R');

      if l_phase_item_id is not null then
         ben_dm_utility.update_phase_items(p_new_status => 'E',
                                       p_id => l_phase_item_id);
      end if;

      ben_dm_utility.error(SQLCODE,l_proc,'(none)','R');
    when others then
      hr_general.g_data_migrator_mode := 'N';
      retcode := 2;
      errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
    -- update status to error
      ben_dm_utility.update_phase_items(p_new_status => 'E',
                                       p_id => l_phase_item_id);
      ben_dm_utility.error(SQLCODE,l_proc,'(none)','R');

end   download   ;

Procedure   upload
(
 errbuf                 out nocopy  varchar2,
 retcode                out nocopy  number ,
 p_migration_id         in   number ,
 p_concurrent_process   in   varchar2 default 'Y',
 p_last_migration_date  in   varchar2,
 p_process_number       in   number,
 p_dir_name             in   varchar2,
 p_file_name            in   varchar2,
 p_delimiter            in   varchar2 default fnd_global.local_chr(01),
 p_business_group_id    in   number  default null
) is


l_proc  varchar2(75) ;
l_no_of_threads           number;

-- cursor to get table for which

cursor csr_get_table is
select tbl.short_name
  from ben_dm_tables tbl,
       ben_dm_table_order  dto
where tbl.table_id     = dto.table_id
order by  dto.table_order ;

cursor c_phase is
select  itm.phase_item_id
       ,itm.phase_id
       ,itm.group_order
  from ben_dm_phase_items itm,
       ben_dm_phases  phs
 where phs.migration_id = p_migration_id
   and phs.phase_id     = itm.phase_id
   and phs.phase_name   = 'UP'
   and mod(itm.phase_item_id,l_no_of_threads) + 1 = p_process_number
   and itm.status       = 'NS';

cursor c_input_file (l_group_order number) is
select dif.target_business_group_name
      ,dif.group_order
  from ben_dm_input_file dif
where  dif.group_order  = l_group_order
  and  dif. status      = 'NS'
  order by dif.group_order;


cursor c_bg (l_name varchar2)  is
select business_group_id
  from per_business_groups
 where name =  l_name ;

l_csr_get_table_rec      csr_get_table%rowtype;
l_input_file_rec         c_input_file%rowtype ;
l_phase_rec              c_phase%rowtype;
l_last_migration_date    date  ;
l_fatal_error_message    varchar2(200);
l_pre_fix                varchar2(10) ;
l_short_name             ben_dm_tables.short_name%type ;
l_business_group_id      number ;
l_phase_item_id          number ;
l_phase_id               number ;
l_current_phase_status   varchar2(10) ;
lstring                  varchar2(4000) ;
l_Count                  number  ;
l_rec_downloaded         number ;
l_max_ext                number := 32767;
e_fatal_error            exception;
e_fatal_error2           exception;

begin
 l_proc  := g_package || 'upload' ;
 hr_utility.set_location('Entering:'||l_proc, 10);
 hr_general.g_data_migrator_mode := 'Y';
 l_pre_fix  := 'BEN_DMU' ;
 l_last_migration_date   := to_date(p_last_migration_date, 'YYYY/MM/DD HH24:MI:SS');
 -- initialize messaging
 if p_concurrent_process = 'Y' then
    ben_dm_utility.message_init;
 end if;

 ben_dm_utility.message('ROUT','entry:'||l_proc , 5);
 ben_dm_utility.message('PARA','(errbuf - ' || errbuf ||
                             ')(retcode - ' || retcode ||
                             ')(p_migration_id - ' || p_migration_id ||
                             ')(p_concurrent_process - ' || p_concurrent_process ||
                             ')(p_last_migration_date - '|| l_last_migration_date ||
                             ')', 10);

 l_no_of_threads := ben_dm_utility.number_of_threads(p_business_group_id);
 -- assign the default to 3
 if l_no_of_threads is null then
    l_no_of_threads := 3 ;
 end  if ;
 -- initialise the counter.
 l_count := 1;
 -- build the cache from  dm mapping table

 open csr_get_table;
 fetch csr_get_table bulk collect into t_tab_short_name;
 close csr_get_table;

 ben_dm_data_util.create_fk_cache ;

 ben_dm_utility.g_out_file_handle := utl_file.fopen(p_dir_name,p_file_name||'.out'||p_process_number,'w',l_max_ext);
 ---
 loop
    l_phase_item_id := NULL;

    --
    -- get status of generate phase. If phase has error status set by other slave
    -- process then we need to stop the processing of this slave.
    -- if null returned, then assume it is not started.
    --
    l_current_phase_status := nvl(ben_dm_utility.get_phase_status('UP',p_migration_id), 'NS');
    ben_dm_utility.message('INFO',' current phase status ' || l_current_phase_status,70);

    -- if status is error, then raise an exception
    if (l_current_phase_status = 'E') then
      l_fatal_error_message := 'Encountered error in download  phase caused by ' ||
                               'another process - slave exiting';
      raise e_fatal_error2;
    end if;

    open c_phase;
    fetch c_phase into l_phase_rec ;
    if c_phase%notfound then
      close c_phase;
      ben_dm_utility.message('INFO','exit without  phase data :'||l_proc , 20);
      exit;
    end if;
    close c_phase;


    ben_dm_utility.message('INFO',' group order  ' || l_phase_rec.group_order,70);

    -- update status to started
     ben_dm_utility.update_phase_items(p_new_status => 'S',
                                       p_id => l_phase_rec.phase_item_id);

    l_phase_item_id     := l_phase_rec.phase_item_id;
    l_phase_id          := l_phase_rec.phase_id;
    l_business_group_id := null ;
    l_input_file_rec    := null ;

    open c_input_file(l_phase_rec.group_order)  ;
    fetch c_input_file into l_input_file_rec ;
    close c_input_file ;
    --
    -- Assume different group order will be generated from different target BG
    -- if not use loop for distinct target  bg for same group order
    --
    if l_input_file_rec.group_order is not null   then
       --  group order for for every target bg is unique
       open c_bg(l_input_file_rec.target_business_group_name) ;
       fetch c_bg into l_business_group_id ;
       close c_bg ;
       ben_dm_utility.message('INFO','Business Group ID  :'||l_business_group_id , 30);
       if l_business_group_id is null then
          l_fatal_error_message := 'Encountered error in upload  target  Business Group '
                                   ||l_input_file_rec.TARGET_BUSINESS_GROUP_NAME || ' not found ! ';
          raise e_fatal_error2;
       end if ;


        hr_utility.set_location(' starting '  || l_input_file_rec.group_order , 99 ) ;

        ben_dm_utility.message('INFO','Started upload data for ' ||
                          l_input_file_rec.group_order || ', Group  - BG ' ||
                          l_input_file_rec.target_business_group_name,40);

        ben_dm_utility.message('SUMM','Started upload data for ' ||
                          l_input_file_rec.group_order || ', SSN  -  BG ' ||
                          l_input_file_rec.target_business_group_name,50);


        -- for every  table for the group order loop through   tables
        for i in 1..t_tab_short_name.count
        Loop

            hr_utility.set_location(' building sql for ' || t_tab_short_name(i), 99 ) ;
            ben_dm_utility.message('INFO',' Building SQL for   ' || t_tab_short_name(i),70);

            lstring := 'Begin ' ||  l_pre_fix||t_tab_short_name(i)||'.UPLOAD(' ;
            lstring := lstring  || 'p_migration_id         =>  :1 '  ;
            lstring := lstring  || ',p_business_group_id   =>  :2 '  ;
            lstring := lstring  || ',p_business_group_name  => :3 '  ;
            lstring := lstring  || ',p_group_order         =>  :4 '  ;
            lstring := lstring  || ',p_delimiter           =>  :5 '  ;
            lstring := lstring  || '  ) ;  END ; ' ;


            hr_utility.set_location(' executing  sql for ' || t_tab_short_name(i), 99 ) ;
            ben_dm_utility.message('INFO',' Executing    ' || t_tab_short_name(i),70);
            begin
                 execute immediate lstring  using
                 p_migration_id ,
                 l_business_group_id,
                 l_input_file_rec.target_business_group_name,
                 l_input_file_rec.group_order,
                 p_delimiter ;
            exception
              when others then
                ben_dm_utility.message('INFO','calling upload procedure SQL error '   , 60);
                ben_dm_utility.message('INFO', substr(sqlerrm,1,150)   , 60);
               l_fatal_error_message := 'Encountered error in  upload  phase caused by ' ||
                                   t_tab_short_name(i) ;
               raise e_fatal_error2;

            end;

            hr_utility.set_location(' upload completed   for ' || t_tab_short_name(i), 99 ) ;
            ben_dm_utility.message('INFO',' Upload Completed for     ' || t_tab_short_name(i),70);

        end loop ;


       /*

        -- call this for every order once , if the order changed to loop , move below the loop
        hr_utility.set_location(' upload completed   for ' || l_input_file_rec.group_order  , 99 ) ;
        ben_dm_utility.message('INFO','Call for Self reference  :'||l_phase_rec.group_order , 60);

        lstring := 'Begin  ben_dm_resolve_reference.main( ' ;
        lstring := lstring  || 'p_migration_id         =>  :1 '  ;
        lstring := lstring  || ',p_business_group_name  => :2 '  ;
        lstring := lstring  || ',p_group_order         =>  :3 '  ;
        lstring := lstring  || '  ) ;  END ; ' ;

         begin
                 execute immediate lstring  using   p_migration_id ,
                                                    l_business_group_id,
                                                    l_input_file_rec.group_order     ;
            exception
              when others then
                ben_dm_utility.message('INFO','calling  procedure ben_dm_resolve_reference error '   , 60);
                ben_dm_utility.message('INFO', substr(sqlerrm,1,150)   , 60);
               l_fatal_error_message := 'Encountered error  caused by ben_dm_resolve_reference error ' ;
               raise e_fatal_error2;

          end;
        */
    End if ;


    ben_dm_utility.update_phase_items(p_new_status => 'C',
                                     p_id => l_phase_item_id);

    -- clear the cache for every  group order
    ben_dm_data_util.g_pk_maping_tbl.delete ;


    hr_utility.set_location(' download completed   for ' || l_phase_rec.group_order , 99 ) ;

    ben_dm_utility.message('INFO','Uploded  succesfully  for ' || l_phase_rec.group_order,70);



    ben_dm_utility.message('SUMM','Uploded  succesfully  for ' ||
                          l_phase_rec.group_order,80);


 End Loop ;

  -- clear the fk cache
  ben_dm_data_util.g_fk_maping_tbl.delete ;

 ben_dm_utility.message('ROUT','EXIT   ' || l_proc,100);
 hr_general.g_data_migrator_mode := 'N';
 hr_utility.set_location('Leaving:'||l_proc, 10);
 Exception
   when e_fatal_error2 then
      hr_general.g_data_migrator_mode := 'N';
      retcode := 0;
      errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
      ben_dm_utility.error(SQLCODE,l_proc , l_fatal_error_message,'R');

      if l_phase_item_id is not null then
         ben_dm_utility.update_phase_items(p_new_status => 'E',
                                       p_id => l_phase_item_id);
      else
         ben_dm_utility.update_phases(p_new_status => 'E',
                                     p_id => l_phase_id);
      end if;

      ben_dm_utility.error(SQLCODE,l_proc,'(none)','R');
    when others then
      hr_general.g_data_migrator_mode := 'N';
      retcode := 2;
      errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
      -- update status to error
      ben_dm_utility.update_phase_items(p_new_status => 'E',
                                       p_id => l_phase_item_id);
      ben_dm_utility.error(SQLCODE,l_proc,'(none)','R');

end   upload   ;



end ben_dm_gen_master;

/
