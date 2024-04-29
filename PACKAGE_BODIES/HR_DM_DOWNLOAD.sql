--------------------------------------------------------
--  DDL for Package Body HR_DM_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_DOWNLOAD" as
/* $Header: perdmdn.pkb 120.0 2005/05/30 21:16:58 appldev noship $ */

/*---------------------------- PRIVATE ROUTINES ------------------------------*/



/*---------------------------- PUBLIC ROUTINES ------------------------------*/

-- ------------------------- main ------------------------
-- Description: This is the download phase slave. It reads an item from the
-- hr_dm_migration_ranges table  and calls the appropriate TDS package
-- download procedure to download the data into data pump interface table i.e.
-- hr_pump_batch_lines.
--
--
--  Input Parameters
--        p_migration_id        - of current migration
--
--        p_concurrent_process  - Y if program called from CM, otherwise
--                                N prevents message logging
--
--        p_last_migration_date - date of last sucessful migration
--
--        p_process_number      - process number given to slave process by
--                                master process. The first process gets
--                                number 1, second gets number 2 and so on
--                                the maximum nuber being equal to the
--                                number of threads.
--
--
--  Output Parameters
--        errbuf  - buffer for output message (for CM manager)
--
--        retcode - program return code (for CM manager)
--
--
-- ------------------------------------------------------------------------
--
procedure main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number       IN   NUMBER
               ) is
--

  l_current_phase_status   VARCHAR2(30);
  l_range_phase_id         NUMBER;
  l_download_phase_id      NUMBER;
  e_fatal_error            EXCEPTION;
  l_fatal_error_message    VARCHAR2(200);
  l_table_name             VARCHAR2(30);
  l_status                 VARCHAR2(30);
  l_phase_item_id          NUMBER;
  l_business_group_id      NUMBER;
  l_migration_type         VARCHAR2(30);
  l_string                 VARCHAR2(500);
  l_short_name             VARCHAR2(30);
  l_no_of_threads          NUMBER;
  l_cursor                 NUMBER;
  l_return_value           NUMBER;
  l_chunk_size             NUMBER;


  -- cursor to get the table and range to be processed
  cursor csr_table_range is
  select mr.phase_item_id,
         mr.range_id,
         mr.starting_process_sequence,
         mr.ending_process_sequence,
         mr.status,
         tbl.table_name,
         tbl.short_name,
         pi_dn.batch_id
    from hr_dm_phase_items pi_dn,
         hr_dm_tables tbl,
         hr_dm_migration_ranges mr,
         hr_dm_phase_items pi_rg
    where pi_rg.phase_id = l_range_phase_id
    and  pi_rg.phase_item_id = mr.phase_item_id
    and  mr.status = 'NS'
    and  mod(mr.range_id,l_no_of_threads) + 1 = p_process_number
    and  pi_rg.table_name = tbl.table_name
    and  pi_dn.phase_id = l_download_phase_id
    and  pi_dn.group_id = pi_rg.group_id
    and  pi_dn.status in ('NS','S', 'E');

  -- get the migration details
  cursor csr_migration_info is
  select business_group_id,
         migration_type
  from hr_dm_migrations
  where migration_id = p_migration_id;

  l_table_range_rec        csr_table_range%rowtype;
  l_no_of_rec_downloaded   number;
  l_range_id               number;
--
begin
--

  -- initialize messaging (only for concurrent processing)
  if (p_concurrent_process = 'Y') then
    hr_dm_utility.message_init;
  end if;

  hr_dm_utility.message('ROUT','entry:hr_dm_download.main', 5);
  hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                               ')(p_last_migration_date - ' || p_last_migration_date ||
                               ')', 10);
  -- get the download phase_id
  l_download_phase_id := hr_dm_utility.get_phase_id('DP', p_migration_id);

  -- get the range phase_id
  l_range_phase_id := hr_dm_utility.get_phase_id('R', p_migration_id);

  -- get the business_group_id and migration_type
  open csr_migration_info;
  fetch csr_migration_info into l_business_group_id, l_migration_type;
  if csr_migration_info%notfound then
    close csr_migration_info;
    l_fatal_error_message := 'hr_dm_download.main :- Migration Id ' ||
              to_char(p_migration_id) || ' not found.';
    raise e_fatal_error;
  end if;
  close csr_migration_info;

  -- find the chunk size
  l_chunk_size := hr_dm_utility.chunk_size(p_business_group_id => l_business_group_id);

  if l_chunk_size is null then
     l_fatal_error_message := 'hr_dm_download.main :- Chunk Size not ' ||
             'defined for business group ' || l_business_group_id;
     raise e_fatal_error;
  end if;

  -- find the number of threads to use
  l_no_of_threads := hr_dm_utility.number_of_threads(l_business_group_id);


  -- loop until either range phase is in error or all range phase items have
  -- been processed

  loop

    --
    -- get status of download phase. If phase has error status set by other slave
    -- process then we need to stop the processing of this slave.
    -- if null returned, then assume it is not started.
    --
    l_current_phase_status := nvl(hr_dm_utility.get_phase_status('DP',
                                                                p_migration_id),
                                'NS');

    -- if status is error, then raise an exception
    if (l_current_phase_status = 'E') then
      l_fatal_error_message := 'error in download phase - slave exiting';
      raise e_fatal_error;
    end if;

    l_no_of_rec_downloaded := 0;
    open csr_table_range;

    -- fetch a row from the phase items table
    fetch csr_table_range into l_table_range_rec;
    exit when csr_table_range%notfound;
    close csr_table_range;
    l_range_id := l_table_range_rec.range_id;

    -- update status to started
    hr_dm_utility.update_migration_ranges(p_new_status => 'S',
                                         p_id => l_table_range_rec.range_id);

   -- call download table range code in TDS package
   -- passing business_group_id, r_migration_data.last_migration_date,
   -- l_phase_item_id, l_number_of_threads


   -- build parameter string
   l_string := 'begin hrdmd_' || l_table_range_rec.short_name ||
              '.download( ''' ||
               l_migration_type || ''',' ||
              l_business_group_id || ', ''' ||
              p_last_migration_date || ''', ' ||
              l_table_range_rec.starting_process_sequence || ',' ||
              l_table_range_rec.ending_process_sequence || ',' ||
              l_table_range_rec.batch_id || ', ' ||
              l_chunk_size ||',' ||
              ':l_no_of_rec_downloaded); end;';

   hr_dm_utility.message('INFO','Call to TDS ' || l_string , 6);
    -- bind variables

    l_cursor := dbms_sql.open_cursor;
   hr_dm_utility.message('INFO','Open dynamic cursor ' , 7);

    dbms_sql.parse(l_cursor, l_string, dbms_sql.native);

   hr_dm_utility.message('INFO','Bind dynamic var ' , 8);
    -- bind the out variable of the download procedure.
    dbms_sql.bind_variable(l_cursor,':l_no_of_rec_downloaded',20);

   hr_dm_utility.message('INFO','Get return value  ' , 9);
    l_return_value := dbms_sql.execute(l_cursor);

   hr_dm_utility.message('INFO','Get variable value  ' , 10);
    -- get the value of the download procedure.
    dbms_sql.variable_value(l_cursor,
                            ':l_no_of_rec_downloaded',
                            l_no_of_rec_downloaded);

   hr_dm_utility.message('INFO','Close dynamic variable  ' , 10);
    -- close the cursor.
    dbms_sql.close_cursor(l_cursor);

    -- update the no of records downloaded for the range.
    update hr_dm_migration_ranges
    set row_count = l_no_of_rec_downloaded
    where range_id = l_table_range_rec.range_id;

    -- update status to completed
    hr_dm_utility.update_migration_ranges(p_new_status => 'C',
                                          p_id => l_table_range_rec.range_id);
    commit;
  end loop;
  if csr_table_range%isopen then
     close csr_table_range;
  end if;

  -- set up return values to concurrent manager
  retcode := 0;
  errbuf := 'No errors - examine logfiles for detailed reports.';


  hr_dm_utility.message('INFO','Download - main controller', 15);
  hr_dm_utility.message('SUMM','Download - main controller', 20);
  hr_dm_utility.message('ROUT','exit:hr_dm_download.main', 25);
  hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);

  -- error handling
exception
  when e_fatal_error then
    if csr_table_range%isopen then
      close csr_table_range;
    end if;
    retcode := 0;
    errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
    hr_dm_utility.error(SQLCODE,'hr_dm_download.main',l_fatal_error_message,'R');
    hr_dm_utility.error(SQLCODE,'hr_dm_download.main','(none)','R');
  when others then
    if csr_table_range%isopen then
      close csr_table_range;
    end if;
    retcode := 2;
    errbuf := 'An error occurred during the migration - examine logfiles for detailed reports.';
    -- update status to error
    hr_dm_utility.update_migration_ranges(p_new_status => 'E',
                                          p_id => l_range_id);
   hr_dm_utility.error(SQLCODE,'hr_dm_download.main','(none)','R');
--
end main;
--
end hr_dm_download;

/
