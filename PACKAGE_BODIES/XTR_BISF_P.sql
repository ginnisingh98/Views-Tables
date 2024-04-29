--------------------------------------------------------
--  DDL for Package Body XTR_BISF_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_BISF_P" as
/* $Header: xtrbisfb.pls 120.2.12010000.2 2008/08/06 10:42:12 srsampat ship $ */


Function Xtr_Reference_Spot(
p_deal_type in varchar2,
p_deal_number in varchar2
) return number is

l_base_rate number;

cursor get_base_rate is
select base_rate
 from xtr_deals
 where deal_no=to_number(p_deal_number);

Begin

if p_deal_type in('FX','FXO') then
 open get_base_rate;
 fetch get_base_rate into l_base_rate;
 close get_base_rate;
end if;
return (l_base_rate);

End Xtr_Reference_Spot;


Function Xtr_Reference_Internal(
p_deal_type in varchar2,
p_deal_number in varchar2,
p_transaction_number in number
) return varchar2 is

l_comments varchar2(255);

cursor d_ref_int is
select internal_ticket_no
 from xtr_deals
 where deal_no=to_number(p_deal_number);

cursor ro_ref_int is
select internal_ticket_no
 from xtr_rollover_transactions
 where deal_number=to_number(p_deal_number)
   and transaction_number=p_transaction_number;

Begin
if p_deal_type in('FX','FXO','BOND','BDO','STOCK','FRA','NI','IRO','IRS','SWPTN','TMM','RTMM') then
 open d_ref_int;
 fetch d_ref_int into l_comments;
 close d_ref_int;
elsif p_deal_type ='ONC' then
 open ro_ref_int;
 fetch ro_ref_int into l_comments;
 close ro_ref_int;
end if;
return (l_comments);

End Xtr_Reference_Internal;

Function Xtr_Ig_Onc_Sum_Intadj(
p_deal_type in varchar2,
p_deal_number in number,
p_transaction_number in number,
p_journal_date in date
) return number is

l_sum_intadj number;
l_prev_journal_date date;

cursor ig_get_prev_intset is
 select journal_date
 from xtr_journals
 where deal_type=p_deal_type and
       deal_number=p_deal_number and
       amount_type in ('INTSET','COMPOND') and
       journal_date < p_journal_date and
       accounted_dr <>0
 order by journal_date desc;

 cursor ig_sum_intadj(p_prev_journal_date date) is
 select sum(ACCOUNTED_DR)
 from xtr_journals
 where deal_type=p_deal_type and
       deal_number=p_deal_number and
       amount_type ='INTADJ' and
       journal_date > p_prev_journal_date and
       journal_date <= p_journal_date and
       accounted_dr <>0;

cursor onc_get_prev_intset is
 select journal_date
 from xtr_journals
 where deal_type=p_deal_type and
       deal_number=p_deal_number and
       amount_type ='INTSET' and
       accounted_dr <> 0 and
       journal_date < p_journal_date and
       transaction_number in (select a.transaction_number from xtr_rollover_transactions a
         where a.deal_number=p_deal_number
       start with a.cross_ref_to_trans = p_transaction_number
       connect by  (a.deal_number = PRIOR a.deal_number and a.cross_ref_to_trans = PRIOR a.transaction_number))
 order by journal_date desc;


 cursor onc_sum_intadj is
 select sum(ACCOUNTED_DR)
 from xtr_journals
 where deal_type=p_deal_type and
       deal_number=p_deal_number and
       amount_type ='INTADJ' and
       journal_date > l_prev_journal_date and
       journal_date <= p_journal_date and
       accounted_dr <> 0 and
       transaction_number in (select a.transaction_number from xtr_rollover_transactions a
         where a.deal_number=p_deal_number
       start with a.cross_ref_to_trans = p_transaction_number
       connect by  (a.deal_number = PRIOR a.deal_number and a.cross_ref_to_trans = PRIOR a.transaction_number));


Begin
l_sum_intadj :=0;
If p_deal_type ='IG' then
   open ig_get_prev_intset;
   fetch ig_get_prev_intset into l_prev_journal_date;
   if ig_get_prev_intset%NOTFOUND then
      l_prev_journal_date :=to_date('01/01/1900','DD/MM/YYYY');
   end if;
   close ig_get_prev_intset;

   open ig_sum_intadj(l_prev_journal_date);
   fetch ig_sum_intadj into l_sum_intadj;
   close ig_sum_intadj;
elsif p_deal_type ='ONC' then
   open onc_get_prev_intset;
   fetch onc_get_prev_intset into l_prev_journal_date;
   if onc_get_prev_intset%NOTFOUND then
        l_prev_journal_date :=to_date('01/01/1900','DD/MM/YYYY');
   end if;
   close onc_get_prev_intset;

   open onc_sum_intadj;
   fetch onc_sum_intadj into l_sum_intadj;
   close onc_sum_intadj;
end if;
return(l_sum_intadj);

End Xtr_Ig_Onc_Sum_Intadj;

End XTR_BISF_P;

/
