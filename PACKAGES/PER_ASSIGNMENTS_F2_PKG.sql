--------------------------------------------------------
--  DDL for Package PER_ASSIGNMENTS_F2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASSIGNMENTS_F2_PKG" AUTHID CURRENT_USER AS
/* $Header: peasg01t.pkh 120.2.12010000.2 2009/10/09 13:18:44 brsinha ship $ */
-----------------------------------------------------------------------------
--
-- Global record required for Payroll Object Group (POG) functionality
--
g_old_asg_rec per_asg_shd.g_rec_type;
--
procedure iu_non_payroll_checks (
	p_per_id	number,
	p_sess_date	date,
	p_per_sys_st	varchar2,
	p_s_per_sys_st	varchar2,
	p_ass_st_type_id number,
	p_bg_id		number,
	p_leg_code	varchar2,
	p_ass_id	number,
        p_emp_num	varchar2,
       	p_ass_seq	number,
        p_ass_num	varchar2);
-----------------------------------------------------------------------------
--
-- Initiates assignment, used to initialize PERWSEMA.
--
procedure initiate_assignment(
	p_bus_grp_id			number,
	p_person_id			number,
	p_end_of_time			date,
	p_gl_set_of_books_id		IN OUT NOCOPY number,
	p_leg_code			varchar2,
	p_sess_date			date,
	p_period_of_service_id		IN OUT NOCOPY number,
	p_accounting_flexfield_ok_flag	IN OUT NOCOPY varchar2,
	p_no_scl			IN OUT NOCOPY varchar2,
	p_scl_id_flex_num		IN OUT NOCOPY number,
	p_def_user_st			IN OUT NOCOPY varchar2,
        p_def_st_id			IN OUT NOCOPY number,
	p_yes_meaning			IN OUT NOCOPY varchar2,
        p_no_meaning			IN OUT NOCOPY varchar2,
        p_pg_struct			IN OUT NOCOPY varchar2,
	p_valid_pos_flag		IN OUT NOCOPY varchar2,
	p_valid_job_flag		IN OUT NOCOPY varchar2,
 	p_gl_flex_structure		IN OUT NOCOPY number,
        p_set_of_books_name		IN OUT NOCOPY varchar2,
        p_fsp_table_name		IN OUT NOCOPY varchar2,
        p_payroll_installed             IN OUT NOCOPY varchar2,
        p_scl_title                     IN OUT NOCOPY varchar2,
        p_terms_required                   OUT NOCOPY varchar2,
        p_person_id2                    IN     number DEFAULT NULL,
        p_assignment_type        IN varchar2 default NULL); -- 3609019
-----------------------------------------------------------------------------
--
-- *** Bundled procedures from update/delete to save on network usage
--     for PERWSEMA. ***
--
-----------------------------------------------------------------------------
procedure pre_update_bundle (
	p_pos_id		number,
	p_org_id		number,
	p_ass_id		number,
	p_row_id		varchar2,
	p_eff_st_date		date,
	p_upd_mode		varchar2,
	p_per_sys_st		varchar2,
        p_s_pos_id              IN OUT NOCOPY number,
        p_s_ass_num             IN OUT NOCOPY varchar2,
        p_s_org_id              IN OUT NOCOPY number,
        p_s_pg_id               IN OUT NOCOPY number,
        p_s_job_id              IN OUT NOCOPY number,
        p_s_grd_id              IN OUT NOCOPY number,
        p_s_pay_id              IN OUT NOCOPY number,
        p_s_def_code_comb_id    IN OUT NOCOPY number,
        p_s_soft_code_kf_id     IN OUT NOCOPY number,
        p_s_per_sys_st          IN OUT NOCOPY varchar2,
        p_s_ass_st_type_id      IN OUT NOCOPY number,
        p_s_prim_flag           IN OUT NOCOPY varchar2,
        p_s_sp_ceil_step_id     IN OUT NOCOPY number,
        p_s_pay_bas             IN OUT NOCOPY varchar2,
	p_return_warning	IN OUT NOCOPY varchar2,
        p_sess_date             date default null);
-----------------------------------------------------------------------------
procedure key_delrec(
	p_del_mode		varchar2,
	p_val_st_date		date,
	p_eff_st_date		date,
	p_eff_end_date		date,
	p_pd_os_id		number,
	p_per_sys_st		varchar2,
	p_ass_id		number,
	p_grd_id		number,
	p_sp_ceil_st_id		number,
	p_ceil_seq		number,
	p_per_id		number,
	p_sess_date		date,
	p_new_end_date		IN OUT NOCOPY date,
	p_val_end_date		date,
	p_pay_id		number,
        p_pay_basis_id number  );--fix for bug 4764140
-----------------------------------------------------------------------------
procedure pre_delete(
	p_del_mode		varchar2,
	p_val_st_date		date,
	p_eff_st_date		date,
	p_eff_end_date		date,
	p_pd_os_id		number,
	p_per_sys_st		varchar2,
	p_ass_id		number,
	p_sess_date		date,
	p_new_end_date		IN OUT NOCOPY date,
	p_val_end_date		date,
	p_pay_id		number,
	p_grd_id		number,
	p_sp_ceil_st_id		number,
	p_ceil_seq		number,
	p_per_id		number,
	p_prim_flag		varchar2,
	p_prim_change_flag	IN OUT NOCOPY varchar2,
	p_new_prim_flag		IN OUT NOCOPY varchar2,
	p_re_entry_point	IN OUT NOCOPY number,
	p_returned_warning	IN OUT NOCOPY varchar2,
	p_cancel_atd		IN OUT NOCOPY date,
        p_cancel_lspd		IN OUT NOCOPY date,
        p_reterm_atd		IN OUT NOCOPY date,
        p_reterm_lspd		IN OUT NOCOPY date,
	p_prim_date_from	IN OUT NOCOPY date,
	p_new_prim_ass_id	IN OUT NOCOPY number,
        p_row_id                varchar2,
        p_s_pos_id              IN OUT NOCOPY number,
        p_s_ass_num             IN OUT NOCOPY varchar2,
        p_s_org_id              IN OUT NOCOPY number,
        p_s_pg_id               IN OUT NOCOPY number,
        p_s_job_id              IN OUT NOCOPY number,
        p_s_grd_id              IN OUT NOCOPY number,
        p_s_pay_id              IN OUT NOCOPY number,
        p_s_def_code_comb_id    IN OUT NOCOPY number,
        p_s_soft_code_kf_id     IN OUT NOCOPY number,
        p_s_per_sys_st          IN OUT NOCOPY varchar2,
        p_s_ass_st_type_id      IN OUT NOCOPY number,
        p_s_prim_flag           IN OUT NOCOPY varchar2,
        p_s_sp_ceil_step_id     IN OUT NOCOPY number,
        p_s_pay_bas             IN OUT NOCOPY varchar2,
        p_pay_basis_id number  );--fix for bug 4764140
-----------------------------------------------------------------------------
END PER_ASSIGNMENTS_F2_PKG;

/
