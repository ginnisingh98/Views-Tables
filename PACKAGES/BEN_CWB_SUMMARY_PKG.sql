--------------------------------------------------------
--  DDL for Package BEN_CWB_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_SUMMARY_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbsm.pkh 120.1.12010000.1 2008/07/29 12:07:53 appldev ship $ */
-- --------------------------------------------------------------------------
-- |--------------------------< update_or_insert >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure tries the update the record in tst_cwb_summary for the
-- given combination. If the record is already locked, a new record will be
-- inserted with status "P". If there exists no records with the given
-- combination, a new record will be inserted with status null.
--
procedure update_or_insert (p_sum_rec in ben_cwb_summary%rowtype);
--
-- --------------------------------------------------------------------------
-- |----------------------< consolidate_summary_rec >------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure consolidates the summary records for a given person
--
procedure consolidate_summary_rec(p_person_id in number);
--
-- --------------------------------------------------------------------------
-- |--------------------< consolidate_summary_rec_all >----------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure consolidates the summary records for all persons having
-- split rows in ben_cwb_summary
procedure consolidate_summary_rec_all;
--
-- --------------------------------------------------------------------------
-- |----------------------< refresh_summary_group_pl >-----------------------|
-- --------------------------------------------------------------------------
-- Description
--	 This procedure calculates the summary for all the persons for a group
-- plan.
--
procedure refresh_summary_group_pl(p_group_pl_id    in number
  			          ,p_lf_evt_ocrd_dt in date);
--
-- --------------------------------------------------------------------------
-- |-----------------------< refresh_summary_persons >-----------------------|
-- --------------------------------------------------------------------------
-- Description
--	 This procedure calculates the summary for all persons with -1 as
-- person id in ben_cwb_person_info
--
procedure refresh_summary_persons(p_group_pl_id    in number
				 ,p_lf_evt_ocrd_dt in date);
--
-- --------------------------------------------------------------------------
-- |--------------------< update_or_insert_pl_sql_tab >----------------------|
-- --------------------------------------------------------------------------
--  Description
--	This procedure stores the given summary values in a pl/sql table.
--  save_pl_sql_tab needs to be called finally to save the values in the table
--  into ben_cwb_summary
procedure update_or_insert_pl_sql_tab
            (p_group_per_in_ler_id     in number
            ,p_group_pl_id             in number
            ,p_group_oipl_id           in number
            ,p_elig_count_direct       in number default null
            ,p_elig_count_all          in number default null
            ,p_emp_recv_count_direct   in number default null
            ,p_emp_recv_count_all      in number default null
            ,p_elig_sal_val_direct     in number default null
            ,p_elig_sal_val_all        in number default null
            ,p_ws_val_direct           in number default null
            ,p_ws_val_all              in number default null
            ,p_ws_bdgt_val_direct      in number default null
            ,p_ws_bdgt_val_all         in number default null
            ,p_ws_bdgt_iss_val_direct  in number default null
            ,p_ws_bdgt_iss_val_all     in number default null
            ,p_bdgt_val_direct         in number default null
            ,p_bdgt_iss_val_direct     in number default null
            ,p_stat_sal_val_direct     in number default null
            ,p_stat_sal_val_all        in number default null
            ,p_oth_comp_val_direct     in number default null
            ,p_oth_comp_val_all        in number default null
            ,p_tot_comp_val_direct     in number default null
            ,p_tot_comp_val_all        in number default null
            ,p_rec_val_direct          in number default null
            ,p_rec_val_all             in number default null
            ,p_rec_mn_val_direct       in number default null
            ,p_rec_mn_val_all          in number default null
            ,p_rec_mx_val_direct       in number default null
            ,p_rec_mx_val_all          in number default null
            ,p_misc1_val_direct        in number default null
            ,p_misc1_val_all           in number default null
            ,p_misc2_val_direct        in number default null
            ,p_misc2_val_all           in number default null
            ,p_misc3_val_direct        in number default null
            ,p_misc3_val_all           in number default null
            ,p_person_id               in number default null
            ,p_lf_evt_ocrd_dt          in date default null);
--
-- --------------------------------------------------------------------------
-- |---------------------------< save_pl_sql_tab >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedures updates the data in g_summary_tab to
-- ben_cwb_summary table.
--
procedure save_pl_sql_tab;
--
-- --------------------------------------------------------------------------
-- |--------------------------< delete_pl_sql_tab >--------------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedures deletes the data in g_summary_tab
--
procedure delete_pl_sql_tab;
--
-- --------------------------------------------------------------------------
-- |-------------------< update_summary_on_reassignment >--------------------|
-- --------------------------------------------------------------------------
-- Description
--	This procedure updates the summary values in the hierarchy when
-- employee is re-assigned.
procedure update_summary_on_reassignment(p_old_mgr_per_in_ler_id in number
                                        ,p_new_mgr_per_in_ler_id in number
                                        ,p_emp_per_in_ler_id     in number);
--
-- --------------------------------------------------------------------------
-- |----------------------< delete_summary_group_pl >------------------------|
-- --------------------------------------------------------------------------
--  Description
--	This procedure removes the summary records from the summary table for
-- a given group_pl_id and lf_evt_ocrd_dt. This will called from the backout
-- process.
procedure delete_summary_group_pl(p_group_pl_id number
                                 ,p_lf_evt_ocrd_dt date);
--
-- --------------------------------------------------------------------------
-- |----------------< upd_summary_on_elig_sal_change >--------------------|
-- --------------------------------------------------------------------------
procedure upd_summary_on_elig_sal_change(p_group_per_in_ler_id in number
                                        ,p_elig_sal_change in number);

--
-- --------------------------------------------------------------------------
-- |--------------------------< clean_budget_data >-------------------------|
-- --------------------------------------------------------------------------
procedure clean_budget_data(p_per_in_ler_id in number
                           ,p_lvl_up        in number default null);
--
--
-- --------------------------------------------------------------------------
-- |-------------------< refresh_summary_all_plans >-----------------------|
-- --------------------------------------------------------------------------
-- Description: This procedure refreshes all plans that have cpi records
-- with -1 person_ids.
--
procedure refresh_summary_all_plans;
--
end BEN_CWB_SUMMARY_PKG;


/
