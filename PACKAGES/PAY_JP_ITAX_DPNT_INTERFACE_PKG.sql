--------------------------------------------------------
--  DDL for Package PAY_JP_ITAX_DPNT_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ITAX_DPNT_INTERFACE_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpitdp.pkh 115.1 2002/12/06 12:10:03 ytohya noship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< transfer_from_cei_to_bee >-----------------------|
-- ----------------------------------------------------------------------------
procedure transfer_from_cei_to_bee(
	p_errbuf		 out nocopy varchar2,
	p_retcode		 out nocopy varchar2,
	p_business_group_id		in number,
	p_payroll_id			in number,
	p_time_period_id		in number,
	p_effective_date		in varchar2,
	p_upload_date			in varchar2,
	p_batch_name			in varchar2,
	p_action_if_exists		in varchar2,
	p_reject_if_future_changes	in varchar2,
	p_date_effective_changes	in varchar2,
	p_purge_after_transfer		in varchar2,
	p_assignment_set_id		in number,
	p_create_entry_if_not_exist	in varchar2,
	p_create_asg_set_for_errored	in varchar2,
	p_spouse_type_flag		in varchar2,
	p_dpnt_spouse_dsbl_type_flag	in varchar2,
	p_dpnts_flag			in varchar2,
	p_aged_dpnts_flag		in varchar2,
	p_aged_dpnt_parents_lt_flag	in varchar2,
	p_young_dpnts_flag		in varchar2,
	p_minor_dpnts_flag		in varchar2,
	p_dsbl_dpnts_flag		in varchar2,
	p_svr_dsbl_dpnts_flag		in varchar2,
	p_svr_dsbl_dpnts_lt_flag	in varchar2);
--
end pay_jp_itax_dpnt_interface_pkg;

 

/
