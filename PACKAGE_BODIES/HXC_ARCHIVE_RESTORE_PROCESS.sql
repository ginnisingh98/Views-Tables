--------------------------------------------------------
--  DDL for Package Body HXC_ARCHIVE_RESTORE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ARCHIVE_RESTORE_PROCESS" as
/* $Header: hxcarcrespkg.pkb 120.8.12010000.4 2008/10/16 10:00:51 asrajago ship $ */



----------------------------------------------------------------------------
-- Procedure Name : define_data_set
-- Description : This is the starting point of the concurrent program
--               'Define Data Set'
----------------------------------------------------------------------------
PROCEDURE define_data_set(errbuf 		OUT NOCOPY VARCHAR2,
			  retcode 		OUT NOCOPY NUMBER,
			  p_data_set_name 	IN VARCHAR2,
			  p_description 	IN VARCHAR2,
		   	  p_start_date 		IN VARCHAR2,
			  p_stop_date 		IN VARCHAR2)
IS

l_data_set_id 	number;
l_start_date 	date;
l_stop_date 	date;
l_dummy 	number;

BEGIN


  -- set the canonical start data and stop date of the data seto
  l_start_date       := trunc(fnd_date.canonical_to_date(p_start_date));
  l_stop_date        := trunc(fnd_date.canonical_to_date(p_stop_date)) + 1 - (1 / (24 * 60 * 60));

  fnd_file.put_line(fnd_file.LOG,'--- >Parameters:');
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set Name :' || p_data_set_name);
  fnd_file.put_line(fnd_file.LOG,'--- >Description :' || p_description);
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set Start Date :' || l_start_date);
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set End Date :' || l_stop_date);

  -- check if the range of the data set does not overlap with an existing data set.
  -- if it does we stop the process
  fnd_file.put_line(fnd_file.LOG,'--- >Before validating Data Set range and unique name');

  IF NOT (hxc_data_set.validate_data_set_range(
                    p_data_set_name 	=> p_data_set_name,
  	 	    p_start_date 	=> l_start_date,
                    p_stop_date  	=> l_stop_date)) THEN
     retcode := 2;
     return;
  END IF;

  fnd_file.put_line(fnd_file.LOG,'--- >Before inserting the record into HXC_DATA_SETS table');
  --
  -- insert into the data set.
  --
  hxc_data_set.insert_into_data_set(l_data_set_id,
	 		            p_data_set_name,
  				    p_description,
 				    l_start_date,
  				    l_stop_date,
  				    'MARKING_IN_PROGRESS');

  fnd_file.put_line(fnd_file.LOG,'--- > New Data Set id is: '||l_data_set_id);

  hxc_data_set.show_data_set;

  fnd_file.put_line(fnd_file.LOG,'--- > Marking the tables with the data set');

  --
  -- Mark the tables with the data set
  --
  hxc_data_set.mark_tables_with_data_set
                       (p_data_set_id => l_data_set_id,
			p_start_date  => l_start_date,
                        p_stop_date   => l_stop_date);

  -- finally update the data set to be ON_LINE
  update hxc_data_sets
  set status = 'ON_LINE'
  where data_set_id = l_data_set_id;

  fnd_file.put_line(fnd_file.LOG,'--- > End process ');


EXCEPTION
  WHEN OTHERS THEN
    fnd_file.put_line(fnd_file.LOG,'Define Data Set process failed because of :'||sqlerrm);
fnd_file.put_line(fnd_file.LOG,'Define Data Set process failed because of :'||sqlerrm);

    ROLLBACK;
    retcode := 2;

end define_data_set;


----------------------------------------------------------------------------
-- Procedure Name : undo_define_data_set
-- Description : This is the starting point of the concurrent program
--               'Undo Define Data Set'
----------------------------------------------------------------------------
PROCEDURE undo_define_data_set
			(errbuf 	OUT NOCOPY VARCHAR2,
		 	 retcode 	OUT NOCOPY NUMBER,
		 	 p_data_set_id 	IN NUMBER)
IS

l_data_set_name 	hxc_data_sets.data_set_name%type;
l_description		hxc_data_sets.description%type;
l_start_date		hxc_data_sets.start_date%type;
l_stop_date		hxc_data_sets.end_date%type;
l_data_set_mode		hxc_data_sets.data_set_mode%type;
l_status		hxc_data_sets.status%type;
l_validation_status	hxc_data_sets.validation_status%type;
l_found_data_set	BOOLEAN := FALSE;


BEGIN

  --
  -- get the data set information
  --
  hxc_data_set.get_data_set_info
                           (p_data_set_id 	=> p_data_set_id,
			    p_data_set_name 	=> l_data_set_name,
			    p_description 	=> l_description,
                            p_start_date 	=> l_start_date,
                            p_stop_date 	=> l_stop_date,
                            p_data_set_mode	=> l_data_set_mode,
                            p_status		=> l_status,
                            p_validation_status	=> l_validation_status,
                            p_found_data_set    => l_found_data_set);

  --
  -- if the data set is not found
  -- we are erroring out the process
  --
  IF NOT(l_found_data_set) THEN
     --error
     retcode := 2;
     fnd_file.put_line
       (fnd_file.LOG,'--- >Data Set Not Found');
     RETURN;
  END IF;

  fnd_file.put_line(fnd_file.LOG,'--- >Parameters:');
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set Id :' || p_data_set_id);
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set Name :' || l_data_set_name);
  --fnd_file.put_line(fnd_file.LOG,'--- >Data Set Status :' || l_status);

  -- if the status is different of online I cannot undo the data set
  IF l_status not in ('ON_LINE','MARKING_IN_PROGRESS') THEN
     --error
     retcode := 2;
     fnd_file.put_line
       (fnd_file.LOG,'--- >Data Set needs to be in ON_LINE status for Undo Define Data Set process');
     RETURN;
  END IF;

  --
  -- Undo define data set
  --
  hxc_data_set.undo_define_data_set(p_data_set_id => p_data_set_id);


EXCEPTION
  WHEN others THEN
    fnd_file.put_line
        (fnd_file.LOG,'--- >Undo Define Data Set failed because of following error: '||sqlerrm);
    ROLLBACK;
    retcode := 2;
END undo_define_data_set;


----------------------------------------------------------------------------
-- Procedure Name : validate_data_set
-- Description : This is the starting point of the concurrent program
--               'Validate Data Set'
----------------------------------------------------------------------------
PROCEDURE validate_data_set(errbuf OUT NOCOPY varchar2,
			    retcode OUT NOCOPY number,
			    p_data_set_id in number)
IS

l_error_count number;

BEGIN

  --
  -- validate the data set
  --
  hxc_data_set.validate_data_set (p_data_set_id,
                                  l_error_count,
                                  false
                                  );

IF (l_error_count>1) THEN
  retcode:=1;
END IF;


Exception when others then

    --Set in error if it fails because of some process related problems.
    fnd_message.set_name('HXC', 'HXC_VALIDATE_PROCESS_FAIL');
    fnd_message.set_token('ERR',SQLERRM );
    fnd_file.put_line(fnd_file.LOG,fnd_message.get);
    rollback;
    retcode := 2;

END validate_data_set;

----------------------------------------------------------------------------
-- Procedure Name : archive_data_set
-- Description : This is the starting point of the concurrent program
--               'Archive Data Set'
----------------------------------------------------------------------------
PROCEDURE archive_data_set(errbuf 	 	OUT NOCOPY varchar2,
			   retcode 	 	OUT NOCOPY number,
			   p_data_set_id 	in number,
			   p_ignore_errors 	in varchar2)
IS

l_dummy varchar2(1);
l_errbuf varchar2(240);

l_iter BINARY_INTEGER;

l_retcode number;
l_rerun varchar2(1);

l_data_set_age number;
l_min_data_set_age number := 0;

-- all the counter
-- Core table first count before archiving
l_tbb_count_1	NUMBER;
l_tau_count_1	NUMBER;
l_ta_count_1	NUMBER;
l_td_count_1	NUMBER;
l_trans_count_1	NUMBER;
l_tal_count_1	NUMBER;
l_aps_count_1	NUMBER;
l_adl_count_1	NUMBER;
l_ld_count_1	NUMBER;
l_ts_count_1	NUMBER;

-- backup table first count before archiving
l_tbb_ar_count_1	NUMBER;
l_tau_ar_count_1	NUMBER;
l_ta_ar_count_1	NUMBER;
l_td_ar_count_1	NUMBER;
l_trans_ar_count_1	NUMBER;
l_tal_ar_count_1	NUMBER;
l_adl_ar_count_1	NUMBER;
l_aps_ar_count_1	NUMBER;

-- Core table first count after archiving
l_tbb_count_2	NUMBER;
l_tau_count_2	NUMBER;
l_ta_count_2	NUMBER;
l_td_count_2	NUMBER;
l_trans_count_2	NUMBER;
l_tal_count_2	NUMBER;
l_aps_count_2	NUMBER;
l_adl_count_2	NUMBER;
l_ld_count_2	NUMBER;
l_ts_count_2	NUMBER;

-- backup table first count  after archiving
l_tbb_ar_count_2	NUMBER;
l_tau_ar_count_2	NUMBER;
l_ta_ar_count_2	NUMBER;
l_td_ar_count_2	NUMBER;
l_trans_ar_count_2	NUMBER;
l_tal_ar_count_2	NUMBER;
l_adl_ar_count_2	NUMBER;
l_aps_ar_count_2	NUMBER;


l_data_set_start_date 	date;
l_data_set_end_date 	date;
l_data_set_name 	VARCHAR2(80);-- hxc_data_sets.data_set_name%type;
l_description		hxc_data_sets.description%type;
l_data_set_mode		hxc_data_sets.data_set_mode%type;
l_current_status	hxc_data_sets.status%type;
l_validation_status	hxc_data_sets.validation_status%type;
l_found_data_set	BOOLEAN := FALSE;

l_error_count		NUMBER;
l_data_set_lock		BOOLEAN;

BEGIN


  --
  -- get the data set information
  --
  hxc_data_set.get_data_set_info
                           (p_data_set_id 	=> p_data_set_id,
			    p_data_set_name 	=> l_data_set_name,
			    p_description 	=> l_description,
                            p_start_date 	=> l_data_set_start_date,
                            p_stop_date 	=> l_data_set_end_date,
                            p_data_set_mode	=> l_data_set_mode,
                            p_status		=> l_current_status,
                            p_validation_status	=> l_validation_status,
                            p_found_data_set    => l_found_data_set);

  --
  -- if the data set is not found
  -- we are erroring out the process
  --
  IF NOT(l_found_data_set) THEN
     --error
     retcode := 2;
     fnd_file.put_line(fnd_file.LOG,'--- >Data Set not found');
     RETURN;

  END IF;


  IF hxc_archive_restore_utils.incompatibility_pg_running
  THEN
    fnd_file.put_line(fnd_file.LOG,'Detected another Archive/Restore or Consolidation Attributes process(es) running.');
    retcode := 2;
    RETURN;
  END IF;


  fnd_file.put_line(fnd_file.LOG,'--- >Parameters:');
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set Id :' || p_data_set_id);
  fnd_file.put_line(fnd_file.LOG,'--- >Ignore Validation Errors Flag :' || p_ignore_errors);
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set Name :' || l_data_set_name);
  --fnd_file.put_line(fnd_file.LOG,'--- >Data Set Status :' || l_current_status);
  fnd_file.put_line(fnd_file.LOG,'--- >Data Set Validation Status :' || l_validation_status);

  ----------------------------------------------------------------------------
  -- Question : How do we determine if the archive process is being rerun ?
  -- Answer : If the data set status is BACKUP_IN_PROGRESS, then it means
  --          that Archive has been run previously on this data set and has
  --          failed due to some reason, which is why the status is still
  --          BACKUP_IN_PROGRESS. Thus we determine that rerun is happening
  --          for that data set
  ----------------------------------------------------------------------------

  -- Validate the data set for archiving
  IF l_current_status in ('OFF_LINE','RESTORE_IN_PROGRESS')
  THEN

    fnd_file.put_line(fnd_file.LOG,'--- >Data Set is currently in '||l_current_status||' status. Data Set can be'||
	             '    archived only if the data set status is ON_LINE or BACKUP_IN_PROGRESS ');
    retcode := 2;
    RETURN;

  ELSIF l_current_status = 'BACKUP_IN_PROGRESS' then
    l_rerun := 'Y';
  ELSE
    l_rerun := 'N';
  END IF;


  l_data_set_age := months_between(trunc(sysdate),trunc(l_data_set_end_date));
  l_min_data_set_age := nvl(fnd_profile.value('HXC_ARCHIVE_DATA_SET_MIN_AGE'),6);

  fnd_file.put_line(fnd_file.LOG,'--- >Profile Value for minimum age value is: '||l_min_data_set_age);

  IF (l_data_set_age < 0)
  THEN

    fnd_file.put_line(fnd_file.LOG,'--- >The Data Set '||l_data_set_name||' extends into the future.');
    fnd_file.put_line(fnd_file.LOG,'--- >Hence the Data Set cannot be archived.');
    retcode := 2;
    RETURN;

  ELSIF (l_data_set_age < 6 and l_min_data_set_age is null)
  THEN

    fnd_file.put_line(fnd_file.LOG,'--- >The age of the Data Set '||l_data_set_name||' is '||round(l_data_set_age,3)||' months, which is less than 6 months');
    fnd_file.put_line(fnd_file.LOG,'--- >Hence the Data Set cannot be archived.');
    retcode := 2;
    RETURN;

  ELSIF (l_min_data_set_age is not null and l_data_set_age < l_min_data_set_age)
  THEN

    fnd_file.put_line(fnd_file.LOG,'--- >The profile option OTL: Minimum age of Data Set for archiving has been set to the value '||l_min_data_set_age||'.');
    fnd_file.put_line(fnd_file.LOG,'--- >The age of the Data Set '||l_data_set_name||' is '||round(l_data_set_age,3)||' months, which is less than '|| l_min_data_set_age||' months.');
    fnd_file.put_line(fnd_file.LOG,'--- >Hence the Data Set cannot be archived.');
    retcode := 2;
   RETURN;

  END IF;

/********* THAT SHOULD BE DONE DURING THE DATA SET VALIDATION *********/
/*
  if hxc_archive_restore_utils.check_data_corruption(p_data_set_id) then

    fnd_file.put_line(fnd_file.LOG,'--- >Data Corruption observed before beginning to Archive the data set');
    retcode := 2;
    return;

  end if;
*/
  ----------------------------------------------------------------------------
  -- Question : What should we do in case of rerun ?
  -- Answer : We should not populate the hxc_data_set_details table because
  --          some records may have already been transferred during the previous
  --          runs. Also the first run of Archive has already populated the
  --          hxc_data_set_details with the correct number of records.
  ----------------------------------------------------------------------------

  IF l_rerun = 'N' THEN

    IF l_validation_status IS NULL
    THEN
      -- error...force user to run validation atleast once
      fnd_file.put_line(fnd_file.LOG,'--- >Please run the Validate Data Set Process at least once');
      retcode := 2;
      RETURN;

    ELSIF (l_validation_status = 'E' AND p_ignore_errors = 'N')
    THEN
      --error.....ask user to correct all errors and then run archive
      fnd_file.put_line(fnd_file.LOG,'--- >The Validate Data Set process has reported warnings.'
	              ||' Either correct those warnings or set the Ignore Validation  Warnings flag to Y.');
      retcode := 2;
      RETURN;

    END IF;

    --fnd_file.put_line(fnd_file.LOG,'--- >Before populating the hxc_data_set_details table with table counts');
    --hxc_archive_restore_utils.populate_hxc_data_set_details(p_data_set_id);
  END IF;



--  Bug No - 7358756

/* As part of re- architecture, removed the following.

   The re-written code takes care of all the below things from
   within the process.  Plus there is no need to validate the
   data set since it is validated once.

 -- Marking tables with Data set again
 -- Locking Data Sets
 -- Validating Data Set
 -- Core Table count snapshot
 -- Backup Table count snapshot
 -- Count Snapshot check.


  hxc_data_set.mark_tables_with_data_set
                       (p_data_set_id => p_data_set_id,
			p_start_date  => l_data_set_start_date,
                        p_stop_date   => l_data_set_end_date);


  l_data_set_lock  := FALSE;

  hxc_data_set.lock_data_set
  		       (p_data_set_id   => p_data_set_id,
			p_start_date    => l_data_set_start_date,
                        p_stop_date     => l_data_set_end_date,
                        p_data_set_lock	=> l_data_set_lock);

  IF not(l_data_set_lock)
  THEN
      retcode := 2;
      RETURN;
  END IF;

  hxc_data_set.validate_data_set (p_data_set_id	=> p_data_set_id,
  				  p_error_count => l_error_count,
  				  p_all_errors	=> true);

  hxc_archive_restore_utils.core_table_count_snapshot
				(p_tbb_count	=> l_tbb_count_1,
				 p_tau_count	=> l_tau_count_1,
				 p_ta_count	=> l_ta_count_1,
				 p_td_count	=> l_td_count_1,
				 p_trans_count	=> l_trans_count_1,
				 p_tal_count	=> l_tal_count_1,
				 p_aps_count	=> l_aps_count_1,
				 p_adl_count	=> l_adl_count_1,
				 p_ld_count	=> l_ld_count_1,
				 p_ts_count	=> l_ts_count_1);


  hxc_archive_restore_utils.bkup_table_count_snapshot
				(p_tbb_ar_count	=> l_tbb_ar_count_1,
				 p_tau_ar_count	=> l_tau_ar_count_1,
				 p_ta_ar_count	=> l_ta_ar_count_1,
				 p_td_ar_count	=> l_td_ar_count_1,
				 p_trans_ar_count	=> l_trans_ar_count_1,
				 p_tal_ar_count	=> l_tal_ar_count_1,
				 p_adl_ar_count	=> l_adl_ar_count_1,
				 p_aps_ar_count	=> l_aps_ar_count_1);

*/
  --
  -- call the archive process
  --
  hxc_archive.archive_process(p_data_set_id		=> p_data_set_id,
  			      p_data_set_start_date	=> l_data_set_start_date,
  			      p_data_set_end_date	=> l_data_set_end_date);


  IF check_data_mismatch
  THEN
     fnd_file.put_line(fnd_file.log,' ');
     fnd_file.put_line(fnd_file.log,' Data mismatch reported in the threads.  Correct the data ');
     fnd_file.put_line(fnd_file.log,' You wont be able to Restore this Data again until you Archive it completely.');
     fnd_file.put_line(fnd_file.log,' ');
     retcode := 2;
     RETURN;
  END IF;



 /*

  hxc_data_set.release_lock_data_set(p_data_set_id);

  hxc_archive_restore_utils.core_table_count_snapshot
				(p_tbb_count	=> l_tbb_count_2,
				 p_tau_count	=> l_tau_count_2,
				 p_ta_count	=> l_ta_count_2,
				 p_td_count	=> l_td_count_2,
				 p_trans_count	=> l_trans_count_2,
				 p_tal_count	=> l_tal_count_2,
				 p_aps_count	=> l_aps_count_2,
				 p_adl_count	=> l_adl_count_2,
				 p_ld_count	=> l_ld_count_2,
				 p_ts_count	=> l_ts_count_2);


  hxc_archive_restore_utils.bkup_table_count_snapshot
				(p_tbb_ar_count	=> l_tbb_ar_count_2,
				 p_tau_ar_count	=> l_tau_ar_count_2,
				 p_ta_ar_count	=> l_ta_ar_count_2,
				 p_td_ar_count	=> l_td_ar_count_2,
				 p_trans_ar_count	=> l_trans_ar_count_2,
				 p_tal_ar_count	=> l_tal_ar_count_2,
				 p_adl_ar_count	=> l_adl_ar_count_2,
				 p_aps_ar_count	=> l_aps_ar_count_2);

  hxc_archive_restore_utils.count_snapshot_check
  				(p_tbb_count_1		=> l_tbb_count_1,
				 p_tau_count_1		=> l_tau_count_1,
				 p_ta_count_1		=> l_ta_count_1,
				 p_td_count_1		=> l_td_count_1,
				 p_trans_count_1	=> l_trans_count_1,
				 p_tal_count_1		=> l_tal_count_1,
				 p_aps_count_1		=> l_aps_count_1,
				 p_adl_count_1		=> l_adl_count_1,
				 p_ld_count_1		=> l_ld_count_1,
				 p_ts_count_1		=> l_ts_count_1,
				 p_tbb_ar_count_1	=> l_tbb_ar_count_1,
				 p_tau_ar_count_1	=> l_tau_ar_count_1,
				 p_ta_ar_count_1	=> l_ta_ar_count_1,
				 p_td_ar_count_1	=> l_td_ar_count_1,
				 p_trans_ar_count_1	=> l_trans_ar_count_1,
				 p_tal_ar_count_1	=> l_tal_ar_count_1,
				 p_adl_ar_count_1	=> l_adl_ar_count_1,
				 p_aps_ar_count_1	=> l_aps_ar_count_1,
				 p_tbb_count_2		=> l_tbb_count_2,
				 p_tau_count_2		=> l_tau_count_2,
				 p_ta_count_2		=> l_ta_count_2,
				 p_td_count_2		=> l_td_count_2,
				 p_trans_count_2	=> l_trans_count_2,
				 p_tal_count_2		=> l_tal_count_2,
				 p_aps_count_2		=> l_aps_count_2,
				 p_adl_count_2		=> l_adl_count_2,
				 p_ld_count_2		=> l_ld_count_2,
				 p_ts_count_2		=> l_ts_count_2,
				 p_tbb_ar_count_2	=> l_tbb_ar_count_2,
				 p_tau_ar_count_2	=> l_tau_ar_count_2,
				 p_ta_ar_count_2	=> l_ta_ar_count_2,
				 p_td_ar_count_2	=> l_td_ar_count_2,
				 p_trans_ar_count_2	=> l_trans_ar_count_2,
				 p_tal_ar_count_2	=> l_tal_ar_count_2,
				 p_adl_ar_count_2	=> l_adl_ar_count_2,
				 p_aps_ar_count_2	=> l_aps_ar_count_2,
				 retcode		=> retcode);

IF retcode <> 2 THEN
*/
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'----------------------  ARCHIVE COMPLETE ---------------------');
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
/*
ELSE
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'--------------------  ARCHIVE INCOMPLETE ---------------------');
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
END IF;
*/
EXCEPTION

  WHEN e_chunk_count THEN
    fnd_file.put_line(fnd_file.LOG,'=== > WRONG COUNT IN THE CHUNK');
    hxc_data_set.release_lock_data_set(p_data_set_id);
    ROLLBACK;
    retcode := 2;


END archive_data_set;


----------------------------------------------------------------------------
-- Procedure Name : restore_data_set
-- Description : This is the starting point of the concurrent program
--               'Restore Data Set'. It calls restore_data_set_from_backup
--               if the mode is 'B' (backup mode).
----------------------------------------------------------------------------
PROCEDURE restore_data_set(errbuf 	 OUT NOCOPY VARCHAR2,
			   retcode 	 OUT NOCOPY NUMBER,
			   p_data_set_id IN NUMBER)
IS



-- all the counter
-- Core table first count before restore
l_tbb_count_1	NUMBER;
l_tau_count_1	NUMBER;
l_ta_count_1	NUMBER;
l_td_count_1	NUMBER;
l_trans_count_1	NUMBER;
l_tal_count_1	NUMBER;
l_aps_count_1	NUMBER;
l_adl_count_1	NUMBER;
l_ld_count_1	NUMBER;
l_ts_count_1	NUMBER;

-- backup table first count before restore
l_tbb_ar_count_1	NUMBER;
l_tau_ar_count_1	NUMBER;
l_ta_ar_count_1	NUMBER;
l_td_ar_count_1	NUMBER;
l_trans_ar_count_1	NUMBER;
l_tal_ar_count_1	NUMBER;
l_adl_ar_count_1	NUMBER;
l_aps_ar_count_1	NUMBER;

-- Core table first count after restore
l_tbb_count_2	NUMBER;
l_tau_count_2	NUMBER;
l_ta_count_2	NUMBER;
l_td_count_2	NUMBER;
l_trans_count_2	NUMBER;
l_tal_count_2	NUMBER;
l_aps_count_2	NUMBER;
l_adl_count_2	NUMBER;
l_ld_count_2	NUMBER;
l_ts_count_2	NUMBER;

-- backup table first count  after restore
l_tbb_ar_count_2	NUMBER;
l_tau_ar_count_2	NUMBER;
l_ta_ar_count_2	NUMBER;
l_td_ar_count_2	NUMBER;
l_trans_ar_count_2	NUMBER;
l_tal_ar_count_2	NUMBER;
l_adl_ar_count_2	NUMBER;
l_aps_ar_count_2	NUMBER;


l_data_set_start_date 	date;
l_data_set_end_date 	date;
l_data_set_name 	hxc_data_sets.data_set_name%type;
l_description		hxc_data_sets.description%type;
l_data_set_mode		hxc_data_sets.data_set_mode%type;
l_current_status	hxc_data_sets.status%type;
l_validation_status	hxc_data_sets.validation_status%type;
l_found_data_set	BOOLEAN := FALSE;


BEGIN


  --
  -- get the data set information
  --
  hxc_data_set.get_data_set_info
                           (p_data_set_id 	=> p_data_set_id,
			    p_data_set_name 	=> l_data_set_name,
			    p_description 	=> l_description,
                            p_start_date 	=> l_data_set_start_date,
                            p_stop_date 	=> l_data_set_end_date,
                            p_data_set_mode	=> l_data_set_mode,
                            p_status		=> l_current_status,
                            p_validation_status	=> l_validation_status,
                            p_found_data_set    => l_found_data_set);

fnd_file.put_line(fnd_file.LOG,'--- >Parameters:');
fnd_file.put_line(fnd_file.LOG,'--- >Data Set id :' || p_data_set_id);
fnd_file.put_line(fnd_file.LOG,'--- >Other Information:');
fnd_file.put_line(fnd_file.LOG,'--- >Data Set Name :' || l_data_set_name);
--fnd_file.put_line(fnd_file.LOG,'--- >Data Set Status :' || l_current_status);


  --
  -- if the data set is not found
  -- we are erroring out the process
  --
  IF NOT(l_found_data_set) THEN
     --error
     retcode := 2;
     fnd_file.put_line(fnd_file.LOG,'--- >Data Set not found');
     RETURN;

  END IF;


  IF l_current_status IN ('ON_LINE','BACKUP_IN_PROGRESS')
  THEN
    fnd_file.put_line(fnd_file.LOG,'--- >Data Set is currently in '||l_current_status||' status. Data Set can be'||
	             ' restored only if the data set status is OFF_LINE or RESTORE_IN_PROGRESS ');
    retcode := 2;
    RETURN;
  END IF;


  -- let's check if there are no program that are running
  -- and are incompatible with this one
  IF hxc_archive_restore_utils.incompatibility_pg_running
  THEN
    fnd_file.put_line(fnd_file.LOG,'Detected another Archive/Restore or Consolidation Attributes process(es) running.');
    retcode := 2;
    RETURN;
  END IF;


--  Bug No - 7358756

/* As part of re- architecture, removed the following.

   The re-written code takes care of all the below things from
   within the process.  Plus there is no need to validate the
   data set since it is validated once.

 -- Core Table count snapshot
 -- Backup Table count snapshot
 -- Count Snapshot check.

  hxc_archive_restore_utils.core_table_count_snapshot
				(p_tbb_count	=> l_tbb_count_1,
				 p_tau_count	=> l_tau_count_1,
				 p_ta_count	=> l_ta_count_1,
				 p_td_count	=> l_td_count_1,
				 p_trans_count	=> l_trans_count_1,
				 p_tal_count	=> l_tal_count_1,
				 p_aps_count	=> l_aps_count_1,
				 p_adl_count	=> l_adl_count_1,
				 p_ld_count	=> l_ld_count_1,
				 p_ts_count	=> l_ts_count_1);


  hxc_archive_restore_utils.bkup_table_count_snapshot
				(p_tbb_ar_count	=> l_tbb_ar_count_1,
				 p_tau_ar_count	=> l_tau_ar_count_1,
				 p_ta_ar_count	=> l_ta_ar_count_1,
				 p_td_ar_count	=> l_td_ar_count_1,
				 p_trans_ar_count	=> l_trans_ar_count_1,
				 p_tal_ar_count	=> l_tal_ar_count_1,
				 p_adl_ar_count	=> l_adl_ar_count_1,
				 p_aps_ar_count	=> l_aps_ar_count_1);

*/


  -- Before calling the restore process check if any corrupted data sets already exist.
  -- If yes, error out issuing the message.  It needs to be corrected first.

  IF check_null_data_set_id
  THEN
     fnd_file.put_line(fnd_file.log,' ');
     fnd_file.put_line(fnd_file.log,'There are some data sets Archived before the new Multi-threaded Archive Process ');
     fnd_file.put_line(fnd_file.log,'was implemented. Please follow the Metalink note available to update these data ');
     fnd_file.put_line(fnd_file.log,'sets as per the new Multi-threaded architecture. 				');
     fnd_file.put_line(fnd_file.log,' ');
     retcode := 2;
     RETURN;
  END IF;


  --
  -- calling the restore process
  --
  hxc_restore.restore_process(p_data_set_id		=> p_data_set_id,
                              p_data_set_start_date	=> l_data_set_start_date,
                              p_data_set_end_date	=> l_data_set_end_date);


  IF check_data_mismatch
  THEN
     fnd_file.put_line(fnd_file.log,' ');
     fnd_file.put_line(fnd_file.log,' Data mismatch reported in the threads.  Correct the data ');
     fnd_file.put_line(fnd_file.log,' You wont be able to Archive this Data again until you Restore it completely.');
     fnd_file.put_line(fnd_file.log,' ');
     retcode := 2;
     RETURN;
  END IF;


  /*
  hxc_archive_restore_utils.core_table_count_snapshot
				(p_tbb_count	=> l_tbb_count_2,
				 p_tau_count	=> l_tau_count_2,
				 p_ta_count	=> l_ta_count_2,
				 p_td_count	=> l_td_count_2,
				 p_trans_count	=> l_trans_count_2,
				 p_tal_count	=> l_tal_count_2,
				 p_aps_count	=> l_aps_count_2,
				 p_adl_count	=> l_adl_count_2,
				 p_ld_count	=> l_ld_count_2,
				 p_ts_count	=> l_ts_count_2);


  hxc_archive_restore_utils.bkup_table_count_snapshot
				(p_tbb_ar_count	=> l_tbb_ar_count_2,
				 p_tau_ar_count	=> l_tau_ar_count_2,
				 p_ta_ar_count	=> l_ta_ar_count_2,
				 p_td_ar_count	=> l_td_ar_count_2,
				 p_trans_ar_count	=> l_trans_ar_count_2,
				 p_tal_ar_count	=> l_tal_ar_count_2,
				 p_adl_ar_count	=> l_adl_ar_count_2,
				 p_aps_ar_count	=> l_aps_ar_count_2);

  hxc_archive_restore_utils.count_snapshot_check
  				(p_tbb_count_1		=> l_tbb_count_1,
				 p_tau_count_1		=> l_tau_count_1,
				 p_ta_count_1		=> l_ta_count_1,
				 p_td_count_1		=> l_td_count_1,
				 p_trans_count_1	=> l_trans_count_1,
				 p_tal_count_1		=> l_tal_count_1,
				 p_aps_count_1		=> l_aps_count_1,
				 p_adl_count_1		=> l_adl_count_1,
				 p_ld_count_1		=> l_ld_count_1,
				 p_ts_count_1		=> l_ts_count_1,
				 p_tbb_ar_count_1	=> l_tbb_ar_count_1,
				 p_tau_ar_count_1	=> l_tau_ar_count_1,
				 p_ta_ar_count_1	=> l_ta_ar_count_1,
				 p_td_ar_count_1	=> l_td_ar_count_1,
				 p_trans_ar_count_1	=> l_trans_ar_count_1,
				 p_tal_ar_count_1	=> l_tal_ar_count_1,
				 p_adl_ar_count_1	=> l_adl_ar_count_1,
				 p_aps_ar_count_1	=> l_aps_ar_count_1,
				 p_tbb_count_2		=> l_tbb_count_2,
				 p_tau_count_2		=> l_tau_count_2,
				 p_ta_count_2		=> l_ta_count_2,
				 p_td_count_2		=> l_td_count_2,
				 p_trans_count_2	=> l_trans_count_2,
				 p_tal_count_2		=> l_tal_count_2,
				 p_aps_count_2		=> l_aps_count_2,
				 p_adl_count_2		=> l_adl_count_2,
				 p_ld_count_2		=> l_ld_count_2,
				 p_ts_count_2		=> l_ts_count_2,
				 p_tbb_ar_count_2	=> l_tbb_ar_count_2,
				 p_tau_ar_count_2	=> l_tau_ar_count_2,
				 p_ta_ar_count_2	=> l_ta_ar_count_2,
				 p_td_ar_count_2	=> l_td_ar_count_2,
				 p_trans_ar_count_2	=> l_trans_ar_count_2,
				 p_tal_ar_count_2	=> l_tal_ar_count_2,
				 p_adl_ar_count_2	=> l_adl_ar_count_2,
				 p_aps_ar_count_2	=> l_aps_ar_count_2,
				 retcode		=> retcode);

IF retcode <> 2 THEN
*/
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'----------------------  RESTORE COMPLETE ---------------------');
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
/*
ELSE
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'--------------------  RESTORE INCOMPLETE ---------------------');
fnd_file.put_line(fnd_file.LOG,'--------------------------------------------------------------');
END IF;


  IF NOT (hxc_archive_restore_utils.check_if_copy_successful
		                         (p_data_set_id,'RESTORE'))
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'--- >Copy failed');
    retcode := 2;
    ROLLBACK;
    RETURN;
  END IF;
*/


EXCEPTION

  WHEN e_chunk_count THEN
    fnd_file.put_line(fnd_file.LOG,'=== > WRONG COUNT IN THE CHUNK');
    ROLLBACK;
    retcode := 2;


END restore_data_set;


-- Public Function check_null_data_set_id
-- Checks if any of the said tables have NULL data set id
--   columns.  If yes, sends a TRUE, and if no returns a
--   FALSE.

FUNCTION check_null_data_set_id
RETURN BOOLEAN
IS

l_count NUMBER := 0;

BEGIN

    -- In the below queries, added a ROWNUM condition
    -- so that the counts wont go on for ever.  We only need
    -- to find if there is atleast one records with NULL data
    -- set id;  the exact count is unncecessary.

    SELECT count(1)
      INTO l_count
      FROM hxc_time_building_blocks_ar
     WHERE data_set_id IS NULL
       AND ROWNUM < 2;

    IF l_count >= 1
    THEN
       RETURN TRUE;
    END IF;

    SELECT count(1)
      INTO l_count
      FROM hxc_time_attributes_ar
     WHERE data_set_id IS NULL
       AND ROWNUM < 2;

    IF l_count >= 1
    THEN
       RETURN TRUE;
    END IF;

    SELECT count(1)
      INTO l_count
      FROM hxc_transaction_details_ar
     WHERE data_set_id IS NULL
       AND ROWNUM < 2;

    IF l_count >= 1
    THEN
       RETURN TRUE;
    END IF;

    SELECT count(1)
      INTO l_count
      FROM hxc_transactions_ar
     WHERE data_set_id IS NULL
       AND ROWNUM < 2;

    IF l_count >= 1
    THEN
       RETURN TRUE;
    END IF;


    -- None of the above queries returned
    -- any thing, so send back FALSE;  there is
    -- no data corruption.

    RETURN FALSE;

END check_null_data_set_id;




-- Public function check_data_mismatch
-- To check if any data mismatch has been recorded earlier in the threads.
-- If yes, the process has to error out, hence return a TRUE.
-- Else return a FALSE.

FUNCTION check_data_mismatch
RETURN BOOLEAN
IS

l_count   NUMBER := 0;

BEGIN

    -- Again we want only a Yes or No answer for whether there are records;
    -- no need of the exact count, hence the rownum condition.

    SELECT count(1)
      INTO l_count
      FROM hxc_data_set_details
     WHERE ROWNUM < 2 ;

    IF l_count >= 1
    THEN
       RETURN TRUE;
    ELSE
       RETURN FALSE;
    END IF;

END check_data_mismatch;

----------------------------------------------------------------------------------------


End hxc_archive_restore_process;

/
