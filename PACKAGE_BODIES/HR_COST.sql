--------------------------------------------------------
--  DDL for Package Body HR_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_COST" as
/* $Header: pycostng.pkb 120.1.12010000.7 2009/04/02 07:23:35 priupadh ship $ */
--
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993, 1994 All rights reserved.
--
/*
   NAME
      pycostng.pkb
--
   DESCRIPTION
      Procedures used for the costing process.
      ie. called by file: pycos.lpc.
--
  MODIFIED (DD-MON-YYYY)
     priupadh   02-APR-2009 - Modified get_cost_date , to pick end_date if COST_DATE_PAID is 'N'(Bug 8393856)
     alogue     23-FEB-2007 - Added p_element_type_id to get_context_value.
     alogue     20-MAY-2005 - New get_rr_date function.
     alogue     07-DEC-2004 - New get_context_value function.
     alogue     22-MAR-2004 - New cost_bal_adj code and remove old obsolete
                              code.
     alogue     08-JUL-1997 - Enhanced code to deal with negative
                              adjustments.
     cadams     19-Mar-1996 - Fixed problem with distribute where if result_val
                              was < 0, the differance would be result_val*2 by
                              dropping the sign from result_val.
     mwcallag   20-MAR-1995 - Removed procedure get_suspense. Now
                              performed in the 'C' code.
     mwcallag   16-AUG-1994 - Major changes for new functionality.
                              See pycos.lpc for more information.
     M Kaddir   16-AUG-1993 - Replaced all references to pay_name_translations
                              with hr_lookups
     mwcallag   15-MAR-1993 - close cursor dist_rrv added
     mwcallag   03-MAR-1993 - created.
*/
-- Cache for get_rr_date
g_element_entry_id pay_element_entries_f.source_id%type := -1;
g_creator_type pay_element_entries_f.creator_type%type;
/*----------------------------- cost_bal_adj ---------------------------------*/
/*
   NAME
      cost_bal_adj   - return whether a balance adjustment result should be
                       costed
--
   DESCRIPTION
      The function returns 'Y' if a balance adjustement should be costed ie
      BALANCE_ADJ_COST_FLAG is = 'Y' for the element entry passed in
*/
function cost_bal_adj
(
    p_element_entry_id      in  number,
    p_baladj_date           in  date
) return varchar2 is
cost_ba  varchar2(1);
--
BEGIN

    select nvl(ee.balance_adj_cost_flag, 'N')
    into cost_ba
    from pay_element_entries_f ee
    where ee.element_entry_id = p_element_entry_id
    and   p_baladj_date between ee.effective_start_date
                            and ee.effective_end_date;

    return (cost_ba);

EXCEPTION
    when others then
      return('N');
END cost_bal_adj;
--
/*-------------------------- get_context_value ---------------------------------*/
/*
   NAME
      get_context_value - returns a value for a given context for a given
                          run result
--
   DESCRIPTION
      The function returns the value of a given context for a given run result
*/
function get_context_value
(
    p_inp_val_name      in  varchar2,
    p_run_result_id     in  number,
    p_element_type_id   in  number,
    p_eff_date          in  date
) return varchar2 is
cnt_value varchar2(60); --pay_run_result_values.result_value%type;
--
BEGIN

    select prrv.result_value
    into   cnt_value
    from pay_run_result_values  prrv,
         pay_input_values_f     piv
    where prrv.run_result_id = p_run_result_id
    and   piv.name = p_inp_val_name
    and   piv.input_value_id = prrv.input_value_id
    and   piv.element_type_id = p_element_type_id
    and   p_eff_date between piv.effective_start_date
                         and piv.effective_end_date;

    return (cnt_value);

EXCEPTION
    when others then
      return(null);
END get_context_value;
--
/*-------------------------- get_rr_date ---------------------------------*/
/*
   NAME
      get_rr_date - returns real date of run result with an end_date
--
   DESCRIPTION
      The function returns the read date of a run result with an end_date.
      Returns the end_date if it is a prorated run result
      Retunrs p_date_earned if the result is derived form a Retro Entry
*/
function get_rr_date
(
    p_source_id      in number,
    p_source_type    in varchar2,
    p_end_date       in date,
    p_date_earned    in date
) return date is
res_date date;
l_start_date date;
l_creator_type pay_element_entries_f.creator_type%type;
--
BEGIN

   res_date := p_end_date;

      if (p_source_type = 'E') then

      if (p_source_id = g_element_entry_id) then
        if (g_creator_type in ('RR', 'EE', 'NR', 'PR')) then
           res_date := p_date_earned;

        end if;
      else

         g_element_entry_id := p_source_id;
         g_creator_type := 'E';

         select creator_type
         into   l_creator_type
         from pay_element_entries_f
         where element_entry_id = p_source_id
         and  rownum = 1;

         if (l_creator_type in ('RR', 'EE', 'NR', 'PR')) then
            res_date := p_date_earned;
            g_creator_type := l_creator_type;

        end if;

      end if;
   end if;

   return(res_date);

EXCEPTION
    when others then
      return(res_date);
END get_rr_date;

--

/*-------------------------- get_cost_date ---------------------------------*/
/*
   NAME
      get_cost_date - returns date date_paid/date_earned for costing
      elements based on action parameter COST_DATE_PAID.
--
   DESCRIPTION
      The function returns date on which the retro element is to be
      costed based on action parameter COST_DATE_PAID. When set to N
      date earned for the retro element is returned. If this parameter
      is not set or set to Y, then this function behaves exactly as
      get_rr_date.
*/
function get_cost_date
(
    p_source_id      in number,
    p_source_type    in varchar2,
    p_end_date       in date,
    p_date_earned    in date
) return date is
res_date date;
l_end_date date;
l_creator_type pay_element_entries_f.creator_type%type;
--
BEGIN

   res_date := p_end_date;

      if (p_source_type = 'E') then

      if (p_source_id = g_element_entry_id) then
         if (g_creator_type in ('RR', 'EE', 'NR', 'PR')) then
            res_date := p_date_earned;

        /*
         * Bug 7279918: Retro elements to be costed
         * on start date so as to cost them against
         * the right organization in case of org change
         */
         DECLARE
            l_cost_date_paid pay_action_parameters.parameter_value%TYPE := 'Y';
         BEGIN
            select parameter_value
            into l_cost_date_paid
            from pay_action_parameters
            where parameter_name = 'COST_DATE_PAID';

            if l_cost_date_paid is not null and l_cost_date_paid = 'N'  then

              select end_date
              into l_end_date
              from pay_run_results
              where source_id = p_source_id;

              if l_end_date is not null then
                 res_date := l_end_date;
              end if;

            end if;

         EXCEPTION
            when others then
            hr_utility.trace ('Retro costing: Noraml Processing');
         END;

        end if;
      else

         g_element_entry_id := p_source_id;
         g_creator_type := 'E';

         select creator_type
         into   l_creator_type
         from pay_element_entries_f
         where element_entry_id = p_source_id
         and  rownum = 1;

         if (l_creator_type in ('RR', 'EE', 'NR', 'PR')) then
            res_date := p_date_earned;
            g_creator_type := l_creator_type;

       /*
        * Bug 7279918: Retro elements to be costed
        * on start date so as to cost them against
        * the right organization in case of org change
        */
         DECLARE
            l_cost_date_paid pay_action_parameters.parameter_value%TYPE := 'Y';
         BEGIN
            select parameter_value
            into l_cost_date_paid
            from pay_action_parameters
            where parameter_name = 'COST_DATE_PAID';

            if l_cost_date_paid is not null and l_cost_date_paid = 'N' then

              select end_date
              into l_end_date
              from pay_run_results
              where source_id = p_source_id;

              if l_end_date is not null then
                 res_date := l_end_date;
              end if;

            end if;

         EXCEPTION
            when others then
            hr_utility.trace ('Retro costing: Noraml Processing');
         END;

        end if;

      end if;
   end if;

   return(res_date);

EXCEPTION
    when others then
      return(res_date);
END get_cost_date;
--

END hr_cost;

/
