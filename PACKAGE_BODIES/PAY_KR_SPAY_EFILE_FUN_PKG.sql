--------------------------------------------------------
--  DDL for Package Body PAY_KR_SPAY_EFILE_FUN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_SPAY_EFILE_FUN_PKG" as
/*$Header: pykrspen.pkb 120.1.12010000.3 2010/02/26 03:43:37 pnethaga ship $ */

   FUNCTION get_prev_emp_count (p_assignment_action_id IN NUMBER) RETURN NUMBER
   IS
      l_prev_emp_count NUMBER(4);
      cursor csr_get_prev_emp_count is
         select
         nvl(count(fue.user_entity_id),0) prev_emp_count
          from  ff_Archive_items fai
               ,ff_user_entities fue
         where fue.user_entity_id               = fai.user_entity_id
         and fue.user_entity_name               = 'X_KR_PREV_BP_NUMBER'
         and fai.context1                       = p_assignment_action_id
         group by fai.context1;
   BEGIN
        open  csr_get_prev_emp_count;
        fetch csr_get_prev_emp_count into l_prev_emp_count;
        close csr_get_prev_emp_count;

        return l_prev_emp_count;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        l_prev_emp_count := 0;
        return l_prev_emp_count;
   END;
   --
   /***************************************************************************
    Function returns separation pay amount after considering separation pension.
    p_amount => Total Earning by working places.
    If "Amount Expected" is present, return "Receivable Separation Pay"
    Else directly return p_amount.
    ***************************************************************************/
    function get_sep_pay_amount (
        p_assact      in number,
        p_amount      in number
    ) return number
    is
        l_amount_expected     number;
        l_receivable_sep_pay  number;
	l_amount_expected_prev number; -- Bug 9247404
        l_return              number;

        cursor csr_sep_amounts is
        select fai1.value      nst_amount_expected,
               fai2.value     nst_receivable_sep_pay,
	       fai3.value      nst_amount_expected_prev
          from ff_Archive_items fai1,
               ff_user_entities fue1,
               ff_Archive_items fai2,
               ff_user_entities fue2,
	       ff_Archive_items fai3,
               ff_user_entities fue3
         where fue1.user_entity_name               = 'A_AMOUNT_EXPECTED_ASG_RUN'
           and fue1.user_entity_id                 = fai1.user_entity_id
           and fai1.context1                       = p_assact
           and fue2.user_entity_name               = 'A_RECEIVABLE_SEPARATION_PAY_ASG_RUN'
           and fue2.user_entity_id                 = fai2.user_entity_id
           and fai2.context1                       = fai1.context1
	   -- Bug 9247404
	   and fue3.user_entity_name               = 'A_PREV_SEP_PENS_DTLS_AMT_EXP_STAT_SEP_ENTRY_VALUE'
           and fue3.user_entity_id                 = fai3.user_entity_id
           and fai3.context1                       = fai1.context1;
    begin
        l_amount_expected    := 0;
        l_receivable_sep_pay := 0;
	l_amount_expected_prev := 0;

        open csr_sep_amounts;
        fetch csr_sep_amounts into l_amount_expected, l_receivable_sep_pay, l_amount_expected_prev;
        close csr_sep_amounts;

        if (nvl(l_amount_expected,0) + nvl(l_amount_expected_prev,0)) > 0 then
            l_return := l_receivable_sep_pay;
        else
            l_return := p_amount;
        end if;

        return l_return;

    end get_sep_pay_amount;

 -- Bug 9409509
    function get_nsep_pay_amount (
        p_assact      in number,
        p_amount      in number
    ) return number
    is
        l_nst_amount_expected     number;
        l_nst_receivable_sep_pay  number;
	l_nst_amount_expected_prev number; -- Bug 9247404
        l_return              number;

        cursor csr_nsep_amounts is
        select fai1.value      amount_expected,
               fai2.value      receivable_sep_pay,
	       fai3.value      amount_expected_prev
          from ff_Archive_items fai1,
               ff_user_entities fue1,
               ff_Archive_items fai2,
               ff_user_entities fue2,
	       ff_Archive_items fai3,
               ff_user_entities fue3
         where fue1.user_entity_name               = 'A_AMOUNT_EXPECTED_NONSTAT_ASG_RUN'
           and fue1.user_entity_id                 = fai1.user_entity_id
           and fai1.context1                       = p_assact
           and fue2.user_entity_name               = 'A_RECEIVABLE_NON_STAT_SEP_PAY_ASG_RUN'
           and fue2.user_entity_id                 = fai2.user_entity_id
           and fai2.context1                       = fai1.context1
	   -- Bug 9247404
	   and fue3.user_entity_name               = 'A_PREV_SEP_PENS_DTLS_AMT_EXP_NONSTAT_SEP_ENTRY_VALUE'
           and fue3.user_entity_id                 = fai3.user_entity_id
           and fai3.context1                       = fai1.context1;
    begin
        l_nst_amount_expected    := 0;
        l_nst_receivable_sep_pay := 0;
	l_nst_amount_expected_prev := 0;

        open csr_nsep_amounts;
        fetch csr_nsep_amounts into l_nst_amount_expected, l_nst_receivable_sep_pay, l_nst_amount_expected_prev;
        close csr_nsep_amounts;

        if (nvl(l_nst_amount_expected,0) + nvl(l_nst_amount_expected_prev,0)) > 0 then
            l_return := l_nst_receivable_sep_pay;
        else
            l_return := p_amount;
        end if;

        return l_return;

    end get_nsep_pay_amount;

 function get_archive_item( p_assact in number) return varchar2
    is
        l_nst_amount_expected     number;
        l_nst_amount_expected_prev number; -- Bug 9247404
        l_return              varchar2(255);

       cursor csr_nsep_amounts is
        select fai1.value      amount_expected,
               fai2.value      amount_expected_prev
          from ff_Archive_items fai1,
               ff_user_entities fue1,
               ff_Archive_items fai2,
               ff_user_entities fue2
         where fue1.user_entity_name               = 'A_AMOUNT_EXPECTED_NONSTAT_ASG_RUN'
           and fue1.user_entity_id                 = fai1.user_entity_id
           and fai1.context1                       = p_assact
	   -- Bug 9247404
	   and fue2.user_entity_name               = 'A_PREV_SEP_PENS_DTLS_AMT_EXP_NONSTAT_SEP_ENTRY_VALUE'
           and fue2.user_entity_id                 = fai2.user_entity_id
           and fai2.context1                       = fai1.context1;
      begin
        l_nst_amount_expected    := 0;
        l_nst_amount_expected_prev := 0;

        open csr_nsep_amounts;
        fetch csr_nsep_amounts into l_nst_amount_expected, l_nst_amount_expected_prev;
        close csr_nsep_amounts;
         if (nvl(l_nst_amount_expected,0) + nvl(l_nst_amount_expected_prev,0)) > 0 then
	  l_return := 'A_RECEIVABLE_NON_STAT_SEP_PAY_ASG_RUN';
        else
          l_return := 'A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN';
        end if;

        return l_return;

       end get_archive_item;
-- End of Bug 9409509
end pay_kr_spay_efile_fun_pkg;

/
