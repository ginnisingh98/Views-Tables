--------------------------------------------------------
--  DDL for Package PAY_KR_PROCESS_NAV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_PROCESS_NAV_PKG" AUTHID CURRENT_USER AS
/* $Header: pykrpnav.pkh 120.0 2005/05/29 06:28:10 appldev noship $ */
	-- Starts the workflow. Called from the concurrent program.
	procedure submit_workflow (
		-- The usual, first two parameters
		p_errbuf			out nocopy	varchar2,
		p_retcode			out nocopy	number,
		--
		-- The parameters for actual workflow
		p_business_place_id_notifier	in		number,		-- the business place to be notified
		p_payroll_id			in		number,		-- the payroll id
		p_consolidation_set_id		in		number,		-- the consolidation set id
		--
		-- For BEE
		p_run_bee			in		varchar2,	-- To run BEE ('Y'), or not ('N)
		p_batch_id			in		number, 	-- the batch id
		--
		-- For Retro-Notifications
		p_run_retro_notf		in		varchar2,	-- To run Retro-Notifications ('Y'), or not ('N)
		p_effective_date_retro_notf	in		varchar2,	-- effective date for retro-notifications
		p_event_group			in		varchar2,	-- event group
		p_gen_assignment_set_name	in		varchar2,	-- the generated assignment set name
		--
		-- For RetroPay
		p_run_retro			in		varchar2,	-- To run RetroPay ('Y'), or not ('N')
		p_retro_assignment_set_id	in		number,		-- the assignment set id for retro pay
		p_retro_element_set_id		in		number, 	-- the element set id for retro pay
		p_retro_start_date		in		varchar2,	-- the start date for retro pay
		p_retro_effective_date		in		varchar2,	-- the end date for retro pay
		--
		-- For Monthly/Bonus Payroll
		p_run_monthly_bonus		in		varchar2,	-- To run Monthly Payroll/Bonus ('Y'), or not ('N')
		p_date_earned			in		varchar2,	-- the date earned
		p_date_paid			in		varchar2,	-- the paid date
		p_element_set_id		in		number,		-- the element set id
		p_assignment_set_id		in		number,		-- the assignment set id
		p_run_type_id			in		number,		-- the run type id
		p_bonus_start_date		in		varchar2,	-- the bonus period start date
		p_additional_tax_rate		in		number,		-- additional tax rate for bonus pay
		p_overriding_tax_rate		in		number,		-- overriding tax rate for bonus pay
		p_payout_date			in		varchar2,	-- the payout date
		--
		-- For Prepayments
		p_run_prepayment		in		varchar2,	-- To run prepayments ('Y'), or not ('N')
		p_prepayment_start_date		in		varchar2,	-- the start date for prepayment run
		p_prepayment_end_date		in		varchar2,	-- the end date for prepayment run
		p_payment_method_override	in		number,		-- the override payment method
		--
		-- For Bank Transfer
		p_run_bank_transfer		in		varchar2,	-- To run bank transfer ('Y'), or not ('N')
		p_direct_deposit_start_date	in		varchar2,	-- the start date for bank transfer
		p_direct_deposit_end_date	in		varchar2,	-- the end date for bank transfer
		p_direct_deposit_date		in		varchar2,	-- the date for direct deposit
		p_payment_method		in		number,		-- the payment method
		p_characterset			in		varchar2,	-- the characterset
		--
		-- For Payslip Archive
		p_run_payslip_archive		in		varchar2,	-- To run payslip archive ('Y'), or not ('N')
		p_archive_start_date		in		varchar2, 	-- the start date for payslip archive
		p_archive_end_date		in		varchar2,	-- the end date for payslip archive
		--
		-- For payslip report
		p_run_payslip_report		in		varchar2,	-- To run payslip report ('Y'), or not ('N')
		p_run_type_period		in		varchar2,	-- the run_type or period
		p_business_place_id		in		number,		-- the business place id
		p_sort_order1			in		varchar2,       -- Sort Order 1 for Payslip Report
		p_sort_order2			in		varchar2,	-- Sort Order 2 for Payslip Report
		-- For costing
		p_run_costing			in		varchar2,	-- To run payslip report ('Y'), or not ('N')
		p_costing_start_date		in		varchar2,	-- the start date for costing run
		p_costing_end_date		in		varchar2,	-- the end date for costing run
		--
		-- Parameters that are not displayed
		p_act_param_group_id		in		number		-- action parameter group id
	);
end pay_kr_process_nav_pkg ;

 

/
