--------------------------------------------------------
--  DDL for Package PER_ASSIGNMENTS_F1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ASSIGNMENTS_F1_PKG" AUTHID CURRENT_USER AS
/* $Header: peasg01t.pkh 120.2.12010000.2 2009/10/09 13:18:44 brsinha ship $ */
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--
--  *****  Public procedures moved off client for performance. *****
--
-----------------------------------------------------------------------------
procedure post_update(
	p_upd_mode		varchar2,
        p_new_prim_flag		varchar2,
        p_val_st_date		date,
        p_new_end_date		date,
        p_eot			date,
        p_pd_os_id		number,
        p_ass_id		number,
        p_new_prim_ass_id	IN OUT NOCOPY number,
        p_prim_change_flag	IN OUT NOCOPY varchar2,
        p_old_pg_id     number,  -- Bug#3924690.
	p_new_pg_id			number,
	p_grd_id		number,
	p_sess_date		date,
	p_s_grd_id		number,
	p_eff_end_date		date,
	p_per_sys_st		varchar2,
        p_old_per_sys_st        varchar2,  --#2404335
	p_val_end_date		date,
	p_del_mode		varchar2,
	p_bg_id			number,
	p_old_pay_id		number,
	p_new_pay_id		number,
	p_group_name		varchar2,
	p_was_end_assign	varchar2,
	p_cancel_atd		date,
	p_cancel_lspd		date,
	p_reterm_atd		date,
	p_reterm_lspd		date,
	p_scl_id		number,
	p_scl_concat		varchar2,
        p_end_salary            varchar2 ,
	p_warning		IN OUT NOCOPY varchar2,
	p_re_entry_point	IN OUT NOCOPY number,
        p_future_spp_warning    OUT NOCOPY boolean);
-----------------------------------------------------------------------------
procedure post_insert(
	p_prim_change_flag	IN OUT NOCOPY varchar2,
	p_val_st_date		date,
	p_new_end_date		date,
	p_eot			date,
	p_pd_os_id		number,
	p_ass_id		number,
	p_new_prim_ass_id	IN OUT NOCOPY number,
	p_pg_id			number,
	p_group_name		varchar2,
	p_bg_id			number,
	p_dt_upd_mode		varchar2,
        p_dt_del_mode		varchar2,
        p_per_sys_st		varchar2,
        p_sess_date		date,
       	p_val_end_date		date,
	p_new_pay_id		number,
	p_old_pay_id		number,
	p_scl_id		number,
	p_scl_concat		varchar2,
	p_warning		IN OUT NOCOPY varchar2);
-----------------------------------------------------------------------------
procedure post_delete(
	p_ass_id		number,
	p_grd_id		number,
	p_sess_date		date,
	p_new_end_date		date,
	p_val_end_date		date,
	p_eff_end_date		date,
	p_del_mode		varchar2,
	p_val_st_date		date,
	p_new_prim_flag		varchar2,
	p_eot			date,
	p_pd_os_id		number,
	p_new_prim_ass_id	IN OUT NOCOPY number,
	p_prim_change_flag	IN OUT NOCOPY varchar2,
	p_per_sys_st		varchar2,
	p_bg_id			number,
	p_old_pay_id		number,
	p_new_pay_id		number,
	p_cancel_atd		date,
        p_cancel_lspd		date,
        p_reterm_atd		date,
        p_reterm_lspd		date,
	p_warning		IN OUT NOCOPY varchar2,
	p_future_spp_warning OUT NOCOPY boolean,
	p_cost_warning          OUT NOCOPY boolean);
-----------------------------------------------------------------------------
END PER_ASSIGNMENTS_F1_PKG;

/
