--------------------------------------------------------
--  DDL for Package HXC_ARCHIVE_RESTORE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ARCHIVE_RESTORE_UTILS" AUTHID CURRENT_USER AS
  /* $Header: hxcarcresutl.pkh 120.4 2005/11/22 01:16:53 gkrishna noship $ */

g_error_count number;

TYPE t_tbb_id is TABLE of hxc_time_building_blocks.time_building_block_id%TYPE;


-------------------------------------------------------------------
-- for description about all the following functions and procedures
-- please refer the package body
-------------------------------------------------------------------

-- check_max_errors
FUNCTION check_max_errors(p_error_count IN NUMBER) RETURN BOOLEAN;

-- check_data_corruption
FUNCTION check_data_corruption(p_data_set_id IN NUMBER) RETURN BOOLEAN;

-- core_table_count_snapshot
PROCEDURE core_table_count_snapshot
				(p_tbb_count	OUT NOCOPY NUMBER,
				 p_tau_count	OUT NOCOPY NUMBER,
				 p_ta_count	OUT NOCOPY NUMBER,
				 p_td_count	OUT NOCOPY NUMBER,
				 p_trans_count	OUT NOCOPY NUMBER,
				 p_tal_count	OUT NOCOPY NUMBER,
				 p_aps_count	OUT NOCOPY NUMBER,
				 p_adl_count	OUT NOCOPY NUMBER,
				 p_ld_count	OUT NOCOPY NUMBER,
				 p_ts_count	OUT NOCOPY NUMBER);

-- bkup table_count_snapshot
PROCEDURE bkup_table_count_snapshot
				(p_tbb_ar_count	OUT NOCOPY NUMBER,
				 p_tau_ar_count	OUT NOCOPY NUMBER,
				 p_ta_ar_count	OUT NOCOPY NUMBER,
				 p_td_ar_count	OUT NOCOPY NUMBER,
				 p_trans_ar_count	OUT NOCOPY NUMBER,
				 p_tal_ar_count	OUT NOCOPY NUMBER,
				 p_adl_ar_count	OUT NOCOPY NUMBER,
				 p_aps_ar_count	OUT NOCOPY NUMBER);

-- chunk count
PROCEDURE count_chunk_check
                          (p_tc_ar_count		IN NUMBER,
			   p_day_ar_count		IN NUMBER,
			   p_detail_ar_count		IN NUMBER,
			   p_app_period_ar_count	IN NUMBER,
			   p_tau_ar_count		IN NUMBER,
			   p_td_ar_count		IN NUMBER,
			   p_trans_ar_count		IN NUMBER,
			   p_tal_ar_count		IN NUMBER,
			   p_adl_ar_count		IN NUMBER,
			   p_app_period_sum_ar_count	IN NUMBER,
			   p_tbb_count			IN NUMBER,
			   p_app_period_count		IN NUMBER,
			   p_tau_count			IN NUMBER,
			   p_td_count			IN NUMBER,
			   p_trans_count		IN NUMBER,
			   p_tal_count			IN NUMBER,
			   p_adl_count			IN NUMBER,
			   p_app_period_sum_count	IN NUMBER);

-- count check
PROCEDURE count_snapshot_check	(p_tbb_count_1		IN  NUMBER,
				 p_tau_count_1		IN NUMBER,
				 p_ta_count_1		IN NUMBER,
				 p_td_count_1		IN NUMBER,
				 p_trans_count_1	IN NUMBER,
				 p_tal_count_1		IN NUMBER,
				 p_aps_count_1		IN NUMBER,
				 p_adl_count_1		IN NUMBER,
				 p_ld_count_1		IN NUMBER,
				 p_ts_count_1		IN NUMBER,
				 p_tbb_ar_count_1	IN NUMBER,
				 p_tau_ar_count_1	IN NUMBER,
				 p_ta_ar_count_1	IN NUMBER,
				 p_td_ar_count_1	IN NUMBER,
				 p_trans_ar_count_1	IN NUMBER,
				 p_tal_ar_count_1	IN NUMBER,
				 p_adl_ar_count_1	IN NUMBER,
				 p_aps_ar_count_1	IN NUMBER,
				 p_tbb_count_2		IN NUMBER,
				 p_tau_count_2		IN NUMBER,
				 p_ta_count_2		IN NUMBER,
				 p_td_count_2		IN NUMBER,
				 p_trans_count_2	IN NUMBER,
				 p_tal_count_2		IN NUMBER,
				 p_aps_count_2		IN NUMBER,
				 p_adl_count_2		IN NUMBER,
				 p_ld_count_2		IN NUMBER,
				 p_ts_count_2		IN NUMBER,
				 p_tbb_ar_count_2	IN NUMBER,
				 p_tau_ar_count_2	IN NUMBER,
				 p_ta_ar_count_2	IN NUMBER,
				 p_td_ar_count_2	IN NUMBER,
				 p_trans_ar_count_2	IN NUMBER,
				 p_tal_ar_count_2	IN NUMBER,
				 p_adl_ar_count_2	IN NUMBER,
				 p_aps_ar_count_2	IN NUMBER,
				 retcode		OUT NOCOPY NUMBER);

-- incompatibility_pg_running
FUNCTION incompatibility_pg_running
RETURN BOOLEAN;

--updating the wf_notification_attributes with Archival=Yes URL param
--while cancelling the notification via archival.
PROCEDURE upd_wf_notif_attributes(p_item_type IN VARCHAR2,
				  p_item_key  in VARCHAR2);

END hxc_archive_restore_utils;

 

/
