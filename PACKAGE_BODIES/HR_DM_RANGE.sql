--------------------------------------------------------
--  DDL for Package Body HR_DM_RANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DM_RANGE" AS
/* $Header: perdmrng.pkb 120.0 2005/05/31 17:13:08 appldev noship $ */


/*---------------------------- PUBLIC ROUTINES ---------------------------*/

-- ------------------------- main ------------------------
-- Description: This is the range phase slave. It reads an item from the
-- hr_dm_phase_items table for the range phase and calls the appropriate
-- TDS package to populate the table hr_dm_migration_ranges.
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
PROCEDURE main(errbuf OUT NOCOPY VARCHAR2,
               retcode OUT NOCOPY NUMBER,
               p_migration_id IN NUMBER,
               p_concurrent_process IN VARCHAR2 DEFAULT 'Y',
               p_last_migration_date IN DATE,
               p_process_number       IN   NUMBER
               ) IS
--

l_current_phase_status VARCHAR2(30);
l_phase_id NUMBER;
e_fatal_error EXCEPTION;
l_fatal_error_message VARCHAR2(200);
l_table_name VARCHAR2(30);
l_status VARCHAR2(30);
l_phase_item_id NUMBER;
l_business_group_id NUMBER;
l_migration_type VARCHAR2(30);
l_string VARCHAR2(500);
l_short_name VARCHAR2(30);
l_no_of_threads NUMBER;
l_cursor NUMBER;
l_return_value NUMBER;




CURSOR csr_get_pi IS
  SELECT pi.phase_item_id, pi.table_name, pi.status, tbl.short_name
    FROM hr_dm_phase_items pi,
         hr_dm_tables tbl
    WHERE  pi.status = 'NS'
      AND  mod(pi.phase_item_id,l_no_of_threads) + 1 = p_process_number
      AND  pi.phase_id = l_phase_id
      AND  pi.table_name = tbl.table_name;

CURSOR csr_migration_info IS
  SELECT business_group_id, migration_type
    FROM hr_dm_migrations
    WHERE migration_id = p_migration_id;


--
BEGIN
--

-- initialize messaging (only for concurrent processing)
IF (p_concurrent_process = 'Y') THEN
  hr_dm_utility.message_init;
END IF;

hr_dm_utility.message('ROUT','entry:hr_dm_range.main', 5);
hr_dm_utility.message('PARA','(p_migration_id - ' || p_migration_id ||
                             ')(p_last_migration_date - ' ||
                             p_last_migration_date || ')', 10);

-- get the current phase_id
l_phase_id := hr_dm_utility.get_phase_id('R', p_migration_id);

-- get the business_group_id and migration_type
OPEN csr_migration_info;
LOOP
  FETCH csr_migration_info INTO l_business_group_id, l_migration_type;
  EXIT WHEN csr_migration_info%NOTFOUND;
END LOOP;
CLOSE csr_migration_info;

-- find the number of threads to use
l_no_of_threads := hr_dm_utility.number_of_threads(l_business_group_id);

-- loop until either range phase is in error or all range phase items have
-- been processed

LOOP
-- get status of range phase, is phase completed?
-- if null returned, then assume it is NS.
  l_current_phase_status := NVL(hr_dm_utility.get_phase_status('R',
                                p_migration_id), 'NS');

-- if status is error, then raise an exception
  IF (l_current_phase_status = 'E') THEN
    l_fatal_error_message := 'Current phase in error - slave exiting';
    RAISE e_fatal_error;
  END IF;

-- fetch a row from the phase items table
  OPEN csr_get_pi;
  FETCH csr_get_pi INTO l_phase_item_id, l_table_name,
                        l_status, l_short_name;
  EXIT WHEN csr_get_pi%NOTFOUND;
  CLOSE csr_get_pi;
-- update status to started
  hr_dm_utility.update_phase_items(p_new_status => 'S',
                                   p_id => l_phase_item_id);

-- send info on current table to logfile
  hr_dm_utility.message('INFO','Processing - ' || l_table_name, 13);

-- call calculate ranges code in TDS package

-- build parameter string
  l_string := 'begin hrdmd_' || l_short_name || '.calculate_ranges( ' ||
              l_business_group_id || ', ''' ||
              p_last_migration_date || ''', ' ||
              l_phase_item_id || ', ' ||
              l_no_of_threads || '); end;';

  l_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_cursor, l_string, dbms_sql.native);
  l_return_value := dbms_sql.execute(l_cursor);
  dbms_sql.close_cursor(l_cursor);


-- update status to completed
  hr_dm_utility.update_phase_items(p_new_status => 'C',
                                   p_id => l_phase_item_id);

END LOOP;


-- set up return values to concurrent manager
retcode := 0;
errbuf := 'No errors - examine logfiles for detailed reports.';


hr_dm_utility.message('INFO','Range - main controller', 15);
hr_dm_utility.message('SUMM','Range - main controller', 20);
hr_dm_utility.message('ROUT','exit:hr_dm_range.main', 25);
hr_dm_utility.message('PARA','(retcode - ' || retcode ||
                             ')(errbuf - ' || errbuf || ')', 30);

-- error handling
EXCEPTION
WHEN e_fatal_error THEN
  retcode := 0;
  errbuf := 'An error occurred during the migration - examine logfiles ' ||
            'for detailed reports.';
  hr_dm_utility.error(SQLCODE,'hr_dm_range.main',l_fatal_error_message,'R');
WHEN OTHERS THEN
  retcode := 2;
  errbuf := 'An error occurred during the migration - examine logfiles for '
            || 'detailed reports.';
-- update status to error
  hr_dm_utility.update_phase_items(p_new_status => 'E',
                                   p_id => l_phase_item_id);
  hr_dm_utility.error(SQLCODE,'hr_dm_range.main','(none)','R');


--
END main;
--



END hr_dm_range;

/
