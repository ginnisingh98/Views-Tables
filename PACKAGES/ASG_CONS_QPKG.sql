--------------------------------------------------------
--  DDL for Package ASG_CONS_QPKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_CONS_QPKG" AUTHID DEFINER AS
/*$Header: asgconqs.pls 120.2.12010000.2 2009/08/03 07:44:01 ravir ship $*/

-- DESCRIPTION
--  This package contains callbacks registered with Oracle Lite
--
--
-- HISTORY
--   22-oct-2003 ssabesan   Merge 115.7.1158.12 into main line
--   12-jun-2003 rsripada   Added support to store device type
--   31-mar-2003 rsripada   Fix Online-query bug: 2878674
--   25-feb-2003 rsripada   Added validate_login method
--   19-feb-2003 pkanukol   Support for processing asg_purge_sdq at synch time
--   11-feb-2003 rsripada   Support for conflict detection
--   06-jan-2003 ssabesan   Added NOCOPY in function definition
--   11-nov-2002 ssabesan   added code for pub items upgrade
--   29-may-2002 rsripada   Removed temporary logging support
--   25-apr-2002 rsripada   Added final api for download_init
--   16-apr-2002 rsripada   Created


  -- Notifies that inq has a new transaction
  PROCEDURE upload_complete(p_clientid IN VARCHAR2,
     	                    p_tranid IN NUMBER);

  -- Initialize data for download
  -- Final API
  PROCEDURE download_init(p_clientid IN VARCHAR2,
                          p_last_tranid IN NUMBER,
                          p_curr_tranid IN NUMBER,
                          p_high_prty IN VARCHAR2);

  -- Notifies when all the client's data is sent
  PROCEDURE download_complete(p_clientid IN VARCHAR2);

  -- Populates the number of records for each publication item downloaded
  PROCEDURE populate_q_rec_count(p_clientid IN VARCHAR2);

  --routine that sets PI's in c$pub_list_q that have
  --synch_completed (in asg_complete_refresh) set to 'N' for complete refresh
  PROCEDURE set_complete_refresh;

  --sets synch_completed flag in asg_complete_refresh to 'Y' for
  --a particular pub_item and user_name
  PROCEDURE set_synch_completed(p_user_name IN VARCHAR2,
				p_pub_item IN VARCHAR2);

  --sets synch_completed flag in asg_complete_refresh to 'Y' for
  --pub_item for a given user_name
  PROCEDURE set_synch_completed(p_user_name IN VARCHAR2);

  --removes the row corresponding to a user_name and pub_item
  --from asg_complete_refresh
  PROCEDURE delete_row(p_user_name IN VARCHAR2,
		       p_pub_item IN VARCHAR2);

  --removes all rows for user_name from asg_complete_refresh
  --and for the current publication item with synch_completed='Y'.
  PROCEDURE delete_row(p_user_name IN VARCHAR2);


  --ROUTINE FOR REMOVING RECORDS FROM asg_complete_refresh
  -- if the previous synch was successful
  PROCEDURE process_compref_table(p_user_name IN VARCHAR2,
				  p_last_tranid IN NUMBER);

  -- Routine for removing records from c$pub_list_q
  -- If customization is disabled
  PROCEDURE process_custom_pub_items(p_user_name IN VARCHAR2);

  -- Routine for processing conflicts
  PROCEDURE process_conflicts(p_user_name IN VARCHAR2);

  -- Routine to determine if conflicts should be detected
  PROCEDURE is_conflict_detection_needed(
              p_user_name IN VARCHAR2,
              p_upload_tranid IN NUMBER,
              p_detect_conflict IN OUT NOCOPY VARCHAR2,
              p_pubitem_tbl IN OUT NOCOPY asg_base.pub_item_tbl_type);

  FUNCTION conflict_pub_items_exist(p_user_name IN VARCHAR2,
                                    p_upload_tran_id IN NUMBER)
  RETURN VARCHAR2;
  PROCEDURE get_conf_pub_items_list(
               p_user_name IN VARCHAR2,
               p_upload_tranid IN NUMBER,
               l_conf_pubs IN VARCHAR2,
               p_pubitem_tbl IN OUT NOCOPY asg_base.pub_item_tbl_type);

  -- Routine for processing conflicts
  PROCEDURE process_pubitem_conflicts(p_user_name IN VARCHAR2,
                                      p_upload_tranid IN NUMBER,
                                      p_pubitem IN VARCHAR2);

  FUNCTION get_pk_predicate(l_primary_key_columns IN VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE set_user_hwm_tranid(p_user_name IN VARCHAR2,
                                p_upload_tranid IN NUMBER);

  --procedure for processing asg_purge_sdq at synch time
  PROCEDURE process_purge_Sdq ( p_clientid IN VARCHAR2,
				p_last_tranid IN NUMBER,
				p_curr_tranid IN NUMBER);

  -- Wrapper procedure on fnd_user_pkg
  FUNCTION validate_login(p_user_name IN VARCHAR2,
                          p_password  IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION is_previous_synch_successful(p_user_name IN VARCHAR2,
                                        p_last_tranid IN NUMBER)
           RETURN VARCHAR2;

  FUNCTION find_last_synch_date(p_user_name IN VARCHAR2,
                                p_last_tranid IN NUMBER)
           RETURN DATE;

  FUNCTION find_device_type (p_user_name IN VARCHAR2)
           RETURN VARCHAR2;

END asg_cons_qpkg;

/
