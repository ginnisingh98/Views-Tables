--------------------------------------------------------
--  DDL for Package ASG_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_PERF" AUTHID CURRENT_USER AS
/*$Header: asgperfs.pls 120.1 2005/08/12 02:51:31 saradhak noship $*/

-- DESCRIPTION
--  Contains functions to report synch performance
--
--
-- HISTORY
--   07-Nov-2002 rsripada   Created

  g_num_rows                      NUMBER := 0;
  g_total_rows                    NUMBER := 0;
  g_elapsed_time_in_days          NUMBER := 0;
  g_elapsed_time                  PLS_INTEGER := 0;
  g_total_elapsed_query_time      PLS_INTEGER := 0;
  g_download_init_time            PLS_INTEGER := 0;
  g_total_elapsed_time            PLS_INTEGER :=0;

  -- Procedure to report the download init and query time statistics
  -- for the specified user's first synch
  PROCEDURE get_first_synch_report(p_user_name IN VARCHAR2);

  -- Procedure to report the download init and query time statistics
  -- for the specified user's incremental synch
  PROCEDURE get_incremental_synch_report(p_user_name IN VARCHAR2);

  -- Procedure to report the download init and query time statistics
  -- for the specified user and publication-item's first synch
  PROCEDURE get_first_synch_report(p_user_name IN VARCHAR2,
                                   p_pub_item  IN VARCHAR2);

  -- Procedure to report the download init and query time statistics
  -- for the specified user and publication item's incremental synch
  PROCEDURE get_incremental_synch_report(p_user_name IN VARCHAR2,
                                         p_pub_item  IN VARCHAR2);

  -- Use this procedure to setup the data for download
  -- Should call cleanup_setup afterwards to reset
  PROCEDURE setup_download(p_user_name  IN VARCHAR2,
                           p_first_synch IN VARCHAR2);


  -- Use this procedure to setup the data for download
  -- Should call cleanup_setup afterwards to reset
  PROCEDURE setup_pub_item_download(p_user_name  IN VARCHAR2,
                                    p_pub_item   IN VARCHAR2,
                                    p_first_synch IN VARCHAR2);

  -- This procedure reports the download time for specified pub item
  -- The specified pub item should have been setup for download
  -- using setup_pub_item_download
  PROCEDURE compute_pub_item_time(p_pub_item IN VARCHAR2);

  -- This procedure reports the download time for all publication items
  -- It should be called after call to setup_download
  PROCEDURE compute_download_time;

  -- This procedure is used to clean up the setup done for download.
  PROCEDURE  cleanup_setup;

  PROCEDURE log(p_mesg IN VARCHAR2);

end;

 

/
