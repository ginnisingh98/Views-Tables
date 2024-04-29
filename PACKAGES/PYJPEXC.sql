--------------------------------------------------------
--  DDL for Package PYJPEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYJPEXC" AUTHID CURRENT_USER as
/* $Header: pyjpexc.pkh 120.1.12000000.2 2007/03/05 08:54:30 keyazawa noship $ */
--
-- Constants
--
c_asg_run	constant pay_balance_dimensions.dimension_name%type := '_ASG_RUN';
c_asg_ptd	constant pay_balance_dimensions.dimension_name%type := '_ASG_PTD';
c_asg_mtd	constant pay_balance_dimensions.dimension_name%type := '_ASG_MTD_RUN                  EFFECTIVE_DATE 01-01 RESET 12';
c_asg_ytd	constant pay_balance_dimensions.dimension_name%type := '_ASG_YTD_RUN                  EFFECTIVE_DATE 01-01 RESET 01';
c_asg_aprtd	constant pay_balance_dimensions.dimension_name%type := '_ASG_APRTD                    EFFECTIVE_DATE 01-04 RESET 01';
c_asg_jultd	constant pay_balance_dimensions.dimension_name%type := '_ASG_JULTD_RUN                EFFECTIVE_DATE 01-07 RESET 01';
c_asg_augtd	constant pay_balance_dimensions.dimension_name%type := '_ASG_AUGTD_RUN                EFFECTIVE_DATE 01-08 RESET 01';
c_asg_fytd	constant pay_balance_dimensions.dimension_name%type := '_ASG_BYTD_RUN';
c_asg_fytd_de	constant pay_balance_dimensions.dimension_name%type := '_ASG_FYTD_RUN                 DATE_EARNED          RESET 01';
c_asg_ltd	constant pay_balance_dimensions.dimension_name%type := '_ASG_HTD_RUN';
c_element_ptd	constant pay_balance_dimensions.dimension_name%type := '_ELM_PTD_RUN';
c_element_ltd	constant pay_balance_dimensions.dimension_name%type := '_ELM_LTD_RUN';
c_asg_retro	constant pay_balance_dimensions.dimension_name%type := '_ASG_RETRO_PAY';
c_payments	constant pay_balance_dimensions.dimension_name%type := '_PAYMENTS';
--
function asg_run return varchar2;
function asg_ptd return varchar2;
function asg_mtd return varchar2;
function asg_ytd return varchar2;
function asg_aprtd return varchar2;
function asg_jultd return varchar2;
function asg_fytd return varchar2;
function asg_ltd return varchar2;
function element_ptd return varchar2;
function element_ltd return varchar2;
function asg_retro return varchar2;
function payments return varchar2;
--
procedure ptd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure ptd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure mtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure mtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure qtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure qtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure ytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure ytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure aprtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure aprtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure aprtd_sd(
	p_effective_date		in date,
	p_start_date			out nocopy date,
	p_payroll_id			in number,
	p_bus_grp			in number,
	p_asg_action			in number);
--
procedure jultd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure jultd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure jultd_sd(
	p_effective_date		in date,
	p_start_date			out nocopy date,
	p_payroll_id			in number,
	p_bus_grp			in number,
	p_asg_action			in number);
--
procedure augtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure augtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure augtd_sd(
	p_effective_date		in date,
	p_start_date			out nocopy date,
	p_payroll_id			in number,
	p_bus_grp			in number,
	p_asg_action			in number);
--
function fy_start_date(p_business_group_id in number) return date;
--
procedure fqtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure fqtd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
procedure fytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy number);
--
procedure fytd_ec(
	p_owner_payroll_action_id	in number,
	p_user_payroll_action_id	in number,
	p_owner_assignment_action_id	in number,
	p_user_assignment_action_id	in number,
	p_owner_effective_date		in date,
	p_user_effective_date		in date,
	p_dimension_name		in varchar2,
	p_expiry_information		out nocopy date);
--
/*
procedure show_dim_periods(
	p_business_group_id		in number,
	p_dimension_name		in varchar2,
	p_start_date			in date,
	p_end_date			in date);
*/
--
end pyjpexc;

 

/
