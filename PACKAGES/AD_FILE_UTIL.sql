--------------------------------------------------------
--  DDL for Package AD_FILE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_FILE_UTIL" AUTHID CURRENT_USER as
/* $Header: adfiluts.pls 120.1.12000000.1 2007/01/16 19:31:29 appldev ship $ */

error_buf varchar2(32760);

procedure lock_infrastructure;

procedure unlock_infrastructure;


--
-- Procedure
--   lock_and_empty_temp_table
--
-- Purpose
--   Serializes access to the AD_CHECK_FILE_TEMP table using a User Lock
--   (created using DBMS_LOCK mgmt services), and also empties the table.
--   This lock would be a session-level lock, and is intended to be released
--   when the calling script is totally done with its use of the temp table.
--
--   This is especially necessary when we have multiple scripts that use
--   the infrastructure built around AD_CHECK_FILE_TEMP, that perhaps could
--   be running in parallel. As of 2/25/02, we already a case for
--   this, viz. the snapshot preseeding scripts and the checkfile preseeding
--   scripts use the same temp table. In the absence of such a serializing
--   facility, they could end up stamping on each others feet (eg. creating
--   bugs as files and files as bugs!!)
--
-- Usage
--   Any script that uses the AD_CHECK_FILE_TEMP infrastructure must do the
--   following:
--   a) Call lock_and_empty_temp_table
--   b) Insert rows into AD_CHECK_FILE_TEMP
--   c) Gather statistics on AD_CHECK_FILE_TEMP
--   d) Call the relevant packaged-procedure that reads the temp table and
--      loads whatever is necessary.
--   e) Commit.
--
--   Then repeat steps (a) thru (e) for other rows. When all batches have
--   finished processing, then unlock_infrastructure() should be called to
--   release the User Lock at the very end.
--
-- Arguments
--   APPLSYS schema name
--
procedure lock_and_empty_temp_table
           (p_un_fnd varchar2);

--
-- Procedure
--   load_file_info
--
-- Purpose
--   Imports file information from ad_check_file_temp to ad_files
--
--   Only creates rows that don't already exist.
--
--   Processes all rows in ad_check_file_temp with active_flag='Y'.
--
--   To handle batch sizes:
--
--   1) - fill up whole table with null active_flag
--      - In a loop:
--        - update a batch to have active_flag='Y'
--        - process the batch
--        - delete the batch
--      - using 'where rownum < batch+1' is handy here
--
--   2) perform (truncate, load, process) cycles in an outer loop where
--      only <batch size> rows are loaded and processed at a time.
--
--   Updates the file_id column of ad_check_file_temp so that all
--   rows point to the file_id of the file referenced in the row.
--
-- Arguments
--   none
--
procedure load_file_info;

--
-- Procedure
--   load_file_version_info
--
-- Purpose
--   Imports file information from ad_check_file_temp to ad_files and
--   ad_file_versions.
--
--   Only creates rows that don't already exist.
--
--   Processes all rows in ad_check_file_temp with active_flag='Y'.
--
--   To handle batch sizes:
--
--   1) - fill up whole table with null active_flag
--      - In a loop:
--        - update a batch to have active_flag='Y'
--        - process the batch
--        - delete the batch
--      - using 'where rownum < batch+1' is handy here
--
--   2) perform (truncate, load, process) cycles in an outer loop where
--      only <batch size> rows are loaded and processed at a time.
--
--   Calls load_file_info
--
--   Updates the file_version_id column of ad_check_file_temp so that all
--   rows point to the file_version_id of the file version referenced
--   in the row.
--
-- Arguments
--   none
--
procedure load_file_version_info;

--
-- Procedure
--   load_checkfile_info
--
-- Purpose
--   Imports file information from ad_check_file_temp to ad_files,
--   ad_file_versions, and ad_check_files.
--
--   Only creates rows in ad_files and ad_file_versions that don't
--   already exist. In ad_check_files, it creates rows that don't already
--   exist and also updates existing rows if the version to load is higher
--   than the current version in ad_check_files.
--
--   Processes all rows in ad_check_file_temp with active_flag='Y'.
--
--   To handle batch sizes:
--
--   1) - fill up whole table with null active_flag
--      - In a loop:
--        - update a batch to have active_flag='Y'
--        - process the batch
--        - delete the batch
--      - using 'where rownum < batch+1' is handy here
--
--   2) perform (truncate, load, process) cycles in an outer loop where
--      only <batch size> rows are loaded and processed at a time.
--
--   Calls load_file_version_info
--
--   Updates the check_file_id column of ad_check_file_temp so that any
--   rows that were already in ad_check_files point to the check_file_id
--   of the (file, distinguisher) referenced in the row.  Rows in
--   ad_check_file_temp that did not already have corresponding rows in
--   ad_check_files still have null values for check_file_id
--   (assuming they started out as null)
--
-- Arguments
--   none
--
procedure load_checkfile_info;

--
-- Procedure
--   update_timestamp
--
-- Purpose
--   Inserts/updates a row in AD_TIMESTAMPS corresponding to the
--   specified row type and attribute.
--
-- Arguments
--   in_type         The row type
--   in_attribute    The row attribute
--   in_timestamp    A timestamp.  Defaults to sysdate.
--
-- Notes
--   This is essentially the same as ad_invoker.update_timestamp
--   Added it here to make it easier to call from APPS.
--
procedure update_timestamp
           (in_type      in varchar2,
            in_attribute in varchar2,
            in_timestamp in date);

procedure update_timestamp
           (in_type      in varchar2,
            in_attribute in varchar2);
--
--
--
-- Procedure
--   load_patch_onsite_vers_info
--
-- Purpose
--   Imports file information from ad_check_file_temp to ad_files and
--   ad_file_versions.
--
--   Only creates rows that don't already exist.
--
--   Processes all rows in ad_check_file_temp with active_flag='Y'.
--
--   To handle batch sizes:
--
--   1) - fill up whole table with null active_flag
--      - In a loop:
--        - update a batch to have active_flag='Y'
--        - process the batch
--        - delete the batch
--      - using 'where rownum < batch+1' is handy here
--
--   2) perform (truncate, load, process) cycles in an outer loop where
--      only <batch size> rows are loaded and processed at a time.
--
--   Calls load_file_info
--
--   Updates the file_version_id and file_version_id_2 columns of
--   ad_check_file_temp so that all rows point to the file_version_id
--   of the file versions referenced in the row.
--
--   Doesn't try to update ad_file_versions for rows in ad_check_file_temp
--   with manifest_vers='NA' or manifest_vers_2='NA'.  These values mean
--   "no version for this file", so no corresponding record should be
--   created in ad_file_versions.
--
-- Arguments
--   none
--
procedure load_patch_onsite_vers_info;
--
--
--
-- Procedure
--   load_snapshot_file_info
--
-- Purpose
--  Create Snapshot data by
--  1.Calls  ad_file_versions  and loads the file versions
--    into the ad_check_file_temp table .
--  2.Updates rows in AD_SNAPSHOT_FILES from  ad_check_file_temp
--    which have the same file_id, snapshot_id and containing_file_id
--  3.Inserts those  rows from ad_check_file_temp  into AD_SNAPSHOT_FILES
--    which exists in ad_check_file_temp but are not in AD_SNAPSHOT_FILES.
--    for the  given snapshot_id
--  4.Delete those rows from AD_SNAPSHOT_FILES which exists
--    in AD_SNAPSHOT_FILES  but do not exist in ad_check_file_temp
--    for the  given snapshot_id
--
-- Arguments
-- is_upload pass TRUE if it is an upload otherwise FALSE
--
--
procedure load_snapshot_file_info
           (snp_id number,
            preserve_irep_flag number);
--
--
--
-- Procedure
--   load_preseeded_bugfixes
--
-- Purpose
--   Gets the bug_id from AD_BUGS for the bugnumbers in
--   in ad_check_file_temp table .
--   Creates new rows in the AD_BUGS for the new bugnumbers
--   and gets the bug_id for those bugnumbers and stores them
--   ad_check_file_temp table .
--
--   Inserts those BUG_IDs into AD_SNAPSHOT_BUGFIXES
--
--
-- Arguments
-- None
--
procedure load_preseeded_bugfixes;
--
--
procedure load_patch_hist_action
           (bugs_processed    out NOCOPY number,
            actions_processed out NOCOPY number);

-- Procedure
--     create_global_view
-- Arguments
--     p_apps_system_name - Applications system name
-- Purpose
--     Procedure to create Global View snapshot using exisiting
--     current view snapshots for an applications system.
-- Notes

procedure create_global_view(p_apps_system_name varchar2);
--
--
-- Procedure
--     populate_snapshot_files_temp
-- Arguments
--     p_apps_system_name   - Applications System Name
--
--     p_min_file_id        - lower limit file_id in the range of file_ids
--
--     p_max_file_id        - upper limit file_id in the range of file_ids
--
--     p_global_snapshot_id - Global snapshot_id
--
--     p_un_fnd             - applsys username
--
--     p_iteration          - which iteration  (1,2,etc)
-- Purpose
--     This procedure populates temp table with a range of file_ids
--     processes the data and updates the ad_snapshot_files  with negative
--     global snapshot_id
-- Notes
--

procedure populate_snapshot_files_temp(p_applications_sys_name varchar2,p_min_file_id number,
                                       p_max_file_id number,p_global_snapshot_id number,
                                       p_un_fnd varchar2,p_iteration number);

--
--
-- Procedure
--     populate_snapshot_bugs_temp
-- Arguments
--     p_apps_system_name   - Applications System Name
--
--     p_min_bug_id        - lower limit bugfix_id in the range of bugfix_id
--
--     p_max_bug_id        - upper limit bugfix_id in the range of bugfix_id
--
--     p_global_snapshot_id - Global snapshot_id
--
--     p_un_fnd             - applsys username
--
--     p_iteration          - which iteration  (1,2,etc)
-- Purpose
--     This procedure populates temp table  with a range of file_ids
--     processes the data and updates the ad_snapshot_bugfixes  with negative
--     global snapshot_id
-- Notes
--
procedure populate_snapshot_bugs_temp(p_applications_sys_name varchar2,p_min_bug_id number,
                                      p_max_bug_id number,p_global_snapshot_id number,
                                      p_un_fnd varchar2,p_iteration number);


-- Procedure
--   load_prepmode_checkfile_info
--
-- Purpose
--   Imports file information from ad_check_file_temp to
--   ad_premode_check_files table, when applying a patch in "prepare" mode.
--
-- Arguments
--   none
--
procedure load_prepmode_checkfile_info;


--
-- Procedure
--   cleanup_prepmode_checkfile_info
--
-- Purpose
--   deletes rows from ad_premode_check_files (called after the merge)
--
-- Arguments
--   none
--
procedure cln_prepmode_checkfile_info;
--
--
procedure load_snpst_file_server_info
           (snp_id number);
--
--
end ad_file_util;

 

/
