--------------------------------------------------------
--  DDL for Package PER_ASSIGNMENTS_F3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASSIGNMENTS_F3_PKG" AUTHID CURRENT_USER AS
/* $Header: peasg01t.pkh 120.2.12010000.2 2009/10/09 13:18:44 brsinha ship $ */
-----------------------------------------------------------------------------
procedure process_end_status(
        p_ass_id        number,
        p_sess_date     date,
        p_eff_end_date  date,
        p_eot           date);
-----------------------------------------------------------------------------
procedure process_term_status(
        p_ass_id        number,
        p_sess_date     date);
-----------------------------------------------------------------------------
procedure validate_primary_flag(
        p_val_st_date   date,
        p_pd_os_id      number,
        p_ass_id        number);
-----------------------------------------------------------------------------
procedure test_for_cancel_term(
	p_ass_id		number,
	p_val_start_date	date,
	p_val_end_date		date,
	p_mode			varchar2,
	p_per_sys_st		varchar2,
	p_s_per_sys_st		varchar2,
	p_cancel_atd		IN OUT NOCOPY date,
	p_cancel_lspd		IN OUT NOCOPY date,
	p_reterm_atd		IN OUT NOCOPY date,
	p_reterm_lspd		IN OUT NOCOPY date);
-----------------------------------------------------------------------------
procedure check_future_primary(
	p_dt_mode		varchar2,
	p_val_start_date	date,
	p_prim_flag		varchar2,
	p_eff_start_date	date,
	p_s_prim_flag		varchar2,
	p_prim_change_flag	IN OUT NOCOPY varchar2,
	p_new_prim_flag		IN OUT NOCOPY varchar2,
	p_ass_id		number,
	p_eff_end_date		date,
	p_pd_os_id		number,
	p_show_cand_prim_assgts	IN OUT NOCOPY varchar2,
	p_prim_date_from	IN OUT NOCOPY date,
	p_new_prim_ass_id	IN OUT NOCOPY varchar2);
-----------------------------------------------------------------------------
procedure pre_update_bundle2(
        p_upd_mode		varchar2,
        p_del_mode		varchar2,
       	p_sess_date		date,
        p_per_sys_st		varchar2,
        p_val_st_date		date,
       	p_new_end_date		date,
        p_val_end_date		date,
        p_ass_id		number,
        p_pay_id		number,
	p_eot			date,
	p_eff_end_date		date,
	p_prim_flag		varchar2,
	p_new_prim_flag		IN OUT NOCOPY varchar2,
	p_pd_os_id		number,
	p_s_per_sys_st		varchar2,
	p_ass_number		varchar2,
	p_s_ass_number		varchar2,
	p_row_id		varchar2,
	p_s_prim_flag		varchar2,
	p_bg_id			number,
	p_eff_st_date		date,
	p_grd_id		number,
	p_sp_ceil_st_id		number,
        p_ceil_seq		number,
	p_re_entry_point	IN OUT NOCOPY number,
	p_returned_warning	IN OUT NOCOPY varchar2,
	p_prim_change_flag	IN OUT NOCOPY varchar2,
	p_prim_date_from	IN OUT NOCOPY date,
	p_new_prim_ass_id	IN OUT NOCOPY varchar2,
	p_cancel_atd		IN OUT NOCOPY date,
    	p_cancel_lspd		IN OUT NOCOPY date,
   	p_reterm_atd		IN OUT NOCOPY date,
     	p_reterm_lspd		IN OUT NOCOPY date,
	p_copy_y_to_prim_ch	IN OUT NOCOPY varchar2,
	p_pay_basis_id			      number,				--fix for bug 4764140
	p_ins_new_sal_flag		      VARCHAR2    DEFAULT 'N'		-- fix for bug 8439611
	);
-----------------------------------------------------------------------------
--
--  UPDATE_AND_DELETE_BUNDLE: procedure to bundle procedure calls which follow
--  each other at pre_update and pre_delete time (on PERWSEMA).
--
-- p_re_entry_point is used to re-enter code after warnings and prevent
-- code being re-run. A p_re_entry_point of 0 implies successful completion.
--
-- A null p_re_entry_point should be passed to run whole procedure.
-- p_only_one_entry_point is 'Y' if only the given entry point is to be
-- run through. eg If p_re_entry_point=2 and p_only_one_entry_point='Y' then
-- only the code relating to PAYROLL_CHANGE_VALIDATE will be run and then
-- the procedure will finish.
-- Normally the value of p_only_one_entry_point will be 'N' where the code
-- will run through until the end of the proc unless it hits a warning or
-- error.
--
procedure update_and_delete_bundle(
	p_dt_mode		varchar2,
	p_val_st_date		date,
	p_eff_st_date		date,
	p_eff_end_date		date,
	p_pd_os_id		number,
	p_per_sys_st		varchar2,
	p_ass_id		number,
	p_val_end_date		date,
	p_dt_upd_mode		varchar2,
	p_dt_del_mode		varchar2,
	p_sess_date		date,
	p_pay_id		number,
	p_grd_id		number,
	p_sp_ceil_st_id		number,
	p_ceil_seq		number,
	p_new_end_date		IN OUT NOCOPY date,
	p_returned_warning	IN OUT NOCOPY varchar2,
	p_re_entry_point	IN OUT NOCOPY number,
	p_only_one_entry_point	varchar2,
	p_pay_basis_id		number,				--fix for bug 4764140
        p_ins_new_sal_flag      VARCHAR2    DEFAULT 'N'		-- fix for bug 8439611
	 );
-----------------------------------------------------------------------------
END PER_ASSIGNMENTS_F3_PKG;

/
