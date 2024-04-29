--------------------------------------------------------
--  DDL for Package PAY_JP_CREATE_CMA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_CREATE_CMA_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpcmap.pkh 120.0.12010000.1 2008/07/27 22:57:41 appldev ship $ */
-- ----------------------------------------------------------------------------
-- |---------------------< transfer_from_cma_info_to_bee >--------------------|
-- ----------------------------------------------------------------------------
procedure transfer_from_cma_info_to_bee(
	p_errbuf		 out nocopy varchar2,
	p_retcode		 out nocopy varchar2,
	p_business_group_id		in number,
	p_payroll_id			in number,
	p_time_period_id		in number,
	---- bug 4029525 ----
	-- changed parameter order
	p_payment_date			in varchar2,
	p_upload_date			in varchar2,
	p_effective_date		in varchar2,
	---------------------
	p_batch_name			in varchar2,
	p_action_if_exists		in varchar2,
	p_reject_if_future_changes	in varchar2,
	p_date_effective_changes	in varchar2,
	p_purge_after_transfer		in varchar2,
	p_assignment_set_id		in number,
	p_create_entry_if_not_exist	in varchar2,
	p_create_asg_set_for_errored	in varchar2);
--
end pay_jp_create_cma_pkg;

/
