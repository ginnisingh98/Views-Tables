--------------------------------------------------------
--  DDL for Package Body PAY_KR_NONSTAT_SPAY_EFILE_FUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_NONSTAT_SPAY_EFILE_FUN" as
/*$Header: pykrnspen.pkb 120.0.12010000.2 2009/01/16 13:06:36 vaisriva ship $ */

/*************************************************************************
 * Function that count the Previous Employers.
 *
 *************************************************************************/
	function get_prev_emp_count (p_assignment_action_id IN Number) return Number
	is
		l_prev_emp_count NUMBER(4);
		cursor csr_get_prev_emp_count
		is
		select
			nvl(count(fue.user_entity_id),0) prev_emp_count
		from ff_Archive_items fai
			,ff_user_entities fue
		where fue.user_entity_id                   = fai.user_entity_id
			and fue.user_entity_name               = 'X_KR_PREV_BP_NUMBER'
			and fai.context1                       = p_assignment_action_id
		group by fai.context1;
	begin
		open  csr_get_prev_emp_count;
		fetch csr_get_prev_emp_count into l_prev_emp_count;
		close csr_get_prev_emp_count;
		return nvl(l_prev_emp_count, 0);
	end get_prev_emp_count;

/*************************************************************************
 * Bug 7712932: Function to return the Statutory/Non-Statutory Separation
 * Pay Overseas Tax Break values.
 *************************************************************************/
 FUNCTION get_sep_pay_ovr_tax_brk(
		p_assignment_action_id 	in number,
		p_assignment_id		in number,
		p_type 			in varchar2) return number
 IS
 --
 l_stat_sp_ovr_tax_brk number:= 0;
 l_non_stat_sp_ovr_tax_brk number:= 0;
 --
 CURSOR csr_sep_pay_ovr_tax_brk is
 select nvl(sep_pay_overseas_tax_break,0),
        nvl(non_stat_sep_overseas_tax_brk,0)
 from   pay_kr_sep_tax_v
 where  xassignment_action_id = p_assignment_action_id
   and  assignment_id 	      = p_assignment_id;
 --
 BEGIN
 	open csr_sep_pay_ovr_tax_brk;
 	fetch csr_sep_pay_ovr_tax_brk into l_stat_sp_ovr_tax_brk,l_non_stat_sp_ovr_tax_brk;
	close csr_sep_pay_ovr_tax_brk;

     	if (p_type = 'SEP') then
   	   return nvl(l_stat_sp_ovr_tax_brk,0);
	elsif (p_type = 'NSEP') then
   	   return nvl(l_non_stat_sp_ovr_tax_brk,0);
  	end if;

 END get_sep_pay_ovr_tax_brk;


end pay_kr_nonstat_spay_efile_fun;

/
