--------------------------------------------------------
--  DDL for Package Body PAY_AU_TERM_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_TERM_REP" As
/*  $Header: pyautrm.pkb 120.1.12010000.4 2010/01/29 05:50:49 pmatamsr ship $ */
/*
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in AU terminations reporting
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  ====================================================
**  05-NOV-2000 rayyadev 115.0     Created.
**  08-NOV-2000 rayyadev 115.1     changed the package name
**  08-NOV-2000 rayyadev 115.2     updated the sql for payment.
**  11-NOV-2000 rayyadev 115.3     added legislation code
**  07-JUL-2001 apunekar 115.4     added function to calculate invalidity balance.
**  03-OCT-2001 apunekar 115.5     Made Changes for Bug2021219
**  10-OCT-2001 ragovind 115.6     Added parameter p_invalidity_component to the**                                 ETP_Prepayment_information function
**  05-DEC-2001 nnaresh  115.9     Updated for GSCC Standards.
**  04-DEC-2002 Ragovind 115.10    Added NOCOPY for the functions etp_payment_information,etp_prepayment_information
**  15-May-2003 Ragovind 115.11    Bug#2819479 - ETP Pre/Post Enhancement.
**  23-JUL-2003 Nanuradh 115.12    Bug#2984390 - Added an extra parameter to the function call etp_prepost_ratios - ETP Pre/post Enhancement
**  22-Apr-2005 ksingla  115.13    Bug#4177679 -Added an extra parameter to the function call etp_prepost_ratios .
**  25-Apr-2005 abhargav 115.14    Bug#4322599 - For ETP Tax modified the package hr_aubal call,
**                                               now calling the package in action mode rather then date mode
**  21-Nov-2007 tbakashi 115.15    Bug#6470561 - STATUTORY UPDATE: MUTIPLE ETP IMPACT ON TERMINATION REPORT
**  ============== Formula Fuctions ====================
**  Package contains Reporting Details for the Termination
**  report in AU localisatons.
**  07-Sep-2009 pmatamsr 115.16    Bug#8769345 - Added a new function get_etp_pre_post_components
**                                               as part of Statutory changes to ETP Super rollover
**  07-Sep-2009 pmatamsr 115.17    Bug#8769345 - Added code in ETP_prepayment_information and ETP_payment_information functions for
**                                               fetching the taxable and tax free Super Rollover amounts.
**  28-Jan-2009 pmatamsr 115.18    Bug#9322314 - Added logic to support reporting of values in termination report
**                                               for the terminated employees processed before applying the patch 8769345.
*/
  --
  -------------------------------------------------------------------------------------------------
  --
  -- FUNCTION ETP_prepayment_information
  --
  -- Returns :
  --           1 if function runs successfully
  --           0 otherwise
  --
  -- Purpose : Return the Values of ETP Prepayment information
  --
  -- In :      p_assignment_id       - assignment which is terminated for
  --                                    which report is requiered
  --           p_Hire_date           - date Of commencement of the assignment
  --           p_Termination_date    - date Of Termination Date
  --
  -- Out :     p_pre_01Jul1983_days   - no Of Days in the Pre Jul 1983
  --           p_post_30jun1983_days  - no Of Days in the Post Jul 1983
  --           p_pre_01jul1983_ratio  -ratio Of Days in the Pre Jul 1983
  --           p_post_30jun1983_ratio -ratio Of Days in the Post Jul 1983
  --           P_Gross_ETP            -gross ETP With out super annuation
  --           P_Maximum_Rollover     -Maximum rollover amount
  --           p_Lump_sum_d           -Lump sum D Tax free amount

  --
  -- Uses :
  --           pay_au_terminations
  --           hr_utility
  --
  ------------------------------------------------------------------------------------------------
  function ETP_prepayment_information
  (p_assignment_id        in  number
  ,P_hire_date            in  Date
  ,p_Termination_date     in  date
  ,P_Assignment_action_id in  Number
  ,p_pre_01Jul1983_days   out NOCOPY number
  ,p_post_30jun1983_days  out NOCOPY number
  ,p_pre_01jul1983_ratio  out NOCOPY number
  ,p_post_30jun1983_ratio out NOCOPY number
  ,P_Gross_ETP            out NOCOPY number
  ,P_Maximum_Rollover     out NOCOPY number
  ,p_Lump_sum_d           out NOCOPY number
  ,p_invalidity_component out NOCOPY number
  ,p_etp_service_date     out NOCOPY date   /* Bug#2984390 */
  ,p_taxable_max_rollover out NOCOPY number /* Start 8769345 */
  ,p_tax_free_max_rollover out NOCOPY number /* End 8769345 */
  )
return number
is

    l_procedure     constant varchar2(100) := 'ETP_prepayment_information';
    Lv_Result number;
    Lv_Element_Name Varchar2(100);
    Lv_Input_Name Varchar2(30);
    l_le_etp_service_date date ;  /* Bug 4177679 */
    /* Start 8769345 */
    l_taxable_max_rollover_1  number;
    l_taxable_max_rollover_2  number;
    /* End 8769345 */

/* Bug 9322314 - Assignment_action_id join condition is removed from cursors Term and Term2 ,
                 so that ETP payments processsed in multiple runs are fetched correctly */

cursor Term(p_Assignment_id In Number,Lv_Element_Name In varchar2,Lv_Input_Name In varchar2) is
 select
    nvl(To_Number( prrv.result_value),0)
 from
         pay_run_result_values prrv,
         pay_input_values_f piv,
         pay_element_types_f pet,
         pay_run_results prr,
         pay_assignment_Actions  paa
 where
         prrv.input_value_id=piv.input_value_id
         and piv.element_type_id=pet.element_type_id
         and prr.element_type_id = pet.element_type_id
         and prr.run_result_id = prrv.run_result_id
         and prr.assignment_action_id = paa.assignment_Action_id
         and paa.assignment_id = P_assignment_id
         and pet.element_name=Lv_Element_Name
         and piv.name = Lv_Input_Name
         and piv.legislation_code = 'AU'
         and pet.legislation_code = piv.legislation_code
         and P_Termination_Date between piv.effective_start_date and piv.effective_end_date
         and P_Termination_Date between pet.effective_start_date and Pet.effective_end_date;    /* 6470561 */



/* 6470561 */
cursor Term2(p_Assignment_id In Number,Lv_Element_Name In varchar2,Lv_Input_Name In varchar2) is
 select
    sum(To_Number( prrv.result_value))
 from
         pay_run_result_values prrv,
         pay_input_values_f piv,
         pay_element_types_f pet,
         pay_run_results prr,
         pay_assignment_Actions  paa
 where
             prrv.input_value_id=piv.input_value_id
         and piv.element_type_id=pet.element_type_id
         and prr.element_type_id = pet.element_type_id
         and prr.run_result_id = prrv.run_result_id
         and prr.assignment_action_id = paa.assignment_Action_id
         and paa.assignment_id = p_assignment_id
         and pet.element_name= Lv_Element_Name
         and piv.name = Lv_Input_Name
         and piv.legislation_code ='AU'
         and piv.legislation_code = pet.legislation_code
         and p_termination_date between piv.effective_start_date and piv.effective_end_date
         and p_termination_date between pet.effective_start_date and Pet.effective_end_date
         and prr.run_result_id in (
         select unique(prr3.run_result_id)
                from pay_run_results prr2,
                     pay_input_values_f piv2,
                     pay_element_entries_f pee2,
                     pay_run_result_values prrv2,
                     pay_assignment_actions paa2,
                     pay_run_results prr3
                where
                    prr2.element_type_id = pee2.element_type_id and
                    piv2.element_type_id = pee2.element_type_id and
                    prr2.run_result_id = prrv2.run_result_id and
                    prrv2.input_value_id = piv2.input_value_id and
                    paa2.assignment_action_id = prr2.assignment_action_id and
                    piv2.name = 'Transitional ETP' and
                    prrv2.result_value = 'Y' and
                    paa2.assignment_id = p_assignment_id and
                    prr2.source_id = prr3.source_id ) ;

begin

Begin


        Lv_Element_Name := 'ETP Payment';
        Lv_Input_Name := 'Pay Value';


                open Term2(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                Fetch Term2 into P_Gross_ETP;
                If term2%notfound then
                        P_Gross_ETP := 0;
                close term2;
                end If;
                If term2%ISOPEN then
                close term2;
                End if;
Exception
When No_Data_Found then
P_Gross_ETP := 0;
When Others then
P_Gross_ETP := 0;
raise;
End;

/* 6470561 */
Begin

        Lv_Element_Name := 'Lump Sum D Payment';
        Lv_Input_Name := 'Pay Value';

                open Term2(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                Fetch Term2 into p_Lump_sum_d;
                If term2%notfound then
                        P_Lump_sum_D := 0;
                close term2;
                end If;
                If term2%ISOPEN then
                close term2;
                End if;

Exception
When No_Data_Found then
P_Lump_sum_D := 0;
When Others then
P_Lump_sum_D := 0;
raise;
End;

/* 6470561 */
Begin
        Lv_Element_Name := 'Superannuation Rollover on Termination';
        Lv_Input_Name := 'Pay Value';


                open Term(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                        Fetch Term into P_Maximum_Rollover;
                        If term%notfound then
                        P_Maximum_Rollover := 0;
                        close term;
                        end If;
                If term%ISOPEN then
                close term;
                End if;

    /* Start 8769345 - Added code for fetching the values of taxable and tax free super rollover amounts */

            Lv_Input_Name := 'Amount Part Prev ETP';

                open Term(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                Fetch Term into l_taxable_max_rollover_1;

                        If term%notfound then
                          l_taxable_max_rollover_1 := 0;
                          close term;
                        end If;

                If term%ISOPEN then
                   close term;
                End if;

            Lv_Input_Name := 'Amount Not Part Prev ETP';

                open Term(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                Fetch Term into l_taxable_max_rollover_2;

                        If term%notfound then
                          l_taxable_max_rollover_2 := 0;
                          close term;
                        end If;

                If term%ISOPEN then
                   close term;
                End if;

   p_taxable_max_rollover := l_taxable_max_rollover_1 + l_taxable_max_rollover_2;
   p_tax_free_max_rollover := P_Maximum_Rollover - p_taxable_max_rollover ;

/* End 8769345 */

Exception
When No_Data_Found then
P_Maximum_Rollover := 0;
p_tax_free_max_rollover := 0;
p_taxable_max_rollover := 0;
When Others then
P_Maximum_Rollover := 0;
p_tax_free_max_rollover := 0;
p_taxable_max_rollover := 0;
raise;
End;


/* 6470561 */



  begin
  hr_utility.trace('-----------------------------------------');
  hr_utility.set_location('Entering : '||l_procedure, 1);

Lv_result:=  pay_au_Terminations.etp_prepost_ratios
  (p_assignment_id
  ,p_hire_date
  ,p_termination_date
  ,'N'   -- Bug#2819479 Flag to check whether the function is called from Termination Form.
  ,p_pre_01Jul1983_days
  ,p_post_30jun1983_days
  ,p_pre_01jul1983_ratio
  ,p_post_30jun1983_ratio
  ,p_etp_service_date      /* Bug#2984390 */
  ,l_le_etp_service_date  /* Bug# 4177679 */
  );
  end;

/* 6470561 */
-- the element 'ETP Prepayment Information' is not getting populated for all the 4 etp elements processed,
-- its just getting populated for the first etp element processed

/* 6470561 */

hr_utility.set_location('Leaving : '||l_procedure, 1);
return(1);

Exception
when Others then
return(0);
end ETP_prepayment_information;

------------------------------------- ETP Payment Information --------------------------

  function ETP_payment_information
  (p_assignment_id        in  number
  ,P_hire_date            in  Date
  ,p_Termination_date      in  date
  ,P_Assignment_action_id in Number
  ,P_transitional in varchar2
  ,P_ETP_Payment            out NOCOPY number
  ,P_superAnnuation_rollover out NOCOPY number
  ,p_Lump_sum_d           out NOCOPY number
  ,P_ETP_TAX              out NOCOPY number
  ,p_invalidity_component out NOCOPY number
  ,p_taxable_rollover     out NOCOPY number  /* Start 8769345 */
  ,p_tax_free_rollover    out NOCOPY number  /* End 8769345 */
  )
return number
is

   l_procedure     constant varchar2(100) := 'ETP_payment_information';
   Lv_Result number;
   Lv_balance_type_id       number;
   Lv_balance_type_id_1       number;
   Lv_balance_type_id_2       number;
    Lv_Element_Name Varchar2(100);
    Lv_Input_Name Varchar2(30);
   l_end_date date;
   lv_transitional varchar2(1);
   /* Start 8769345 */
   l_taxable_rollover_1 number;
   l_taxable_rollover_2 number;
   /* End 8769345 */

/* Bug 9322314 - Assignment_action_id join condition is removed from cursors Term and Term2 ,
                 so that ETP payments processsed in multiple runs are fetched correctly */

cursor Term(p_Assignment_id In Number,Lv_Element_Name In varchar2,Lv_Input_Name In varchar2) is
 select
    nvl(sum(To_Number( prrv.result_value)),0)                    /* 6470561 */
 from
         pay_run_result_values prrv,
         pay_input_values_f piv,
         pay_element_types_f pet,
         pay_run_results prr,
         pay_assignment_Actions  paa
 where
             prrv.input_value_id=piv.input_value_id
         and piv.element_type_id=pet.element_type_id
         and prr.element_type_id = pet.element_type_id
         and prr.run_result_id = prrv.run_result_id
         and prr.assignment_action_id = paa.assignment_Action_id
         and paa.assignment_id = P_assignment_id
         and pet.element_name=Lv_Element_Name
         and piv.name = Lv_Input_Name
         and piv.legislation_code ='AU'
         and piv.legislation_code = pet.legislation_code
         and p_termination_date between piv.effective_start_date and piv.effective_end_date
         and p_termination_date between pet.effective_start_date and Pet.effective_end_date;

/* 6470561 */
cursor Term2(p_Assignment_id In Number,Lv_Element_Name In varchar2,Lv_Input_Name In varchar2,p_transitional in varchar2) is
 select
    sum(To_Number( prrv.result_value))
 from
         pay_run_result_values prrv,
         pay_input_values_f piv,
         pay_element_types_f pet,
         pay_run_results prr,
         pay_assignment_Actions  paa
 where
             prrv.input_value_id=piv.input_value_id
         and piv.element_type_id=pet.element_type_id
         and prr.element_type_id = pet.element_type_id
         and prr.run_result_id = prrv.run_result_id
         and prr.assignment_action_id = paa.assignment_Action_id
         and paa.assignment_id = p_assignment_id
         and pet.element_name= Lv_Element_Name
         and piv.name = Lv_Input_Name
         and piv.legislation_code ='AU'
         and piv.legislation_code = pet.legislation_code
         and p_termination_date between piv.effective_start_date and piv.effective_end_date
         and p_termination_date between pet.effective_start_date and Pet.effective_end_date
         and prr.run_result_id in (
         select unique(prr3.run_result_id)
                from pay_run_results prr2,
                     pay_input_values_f piv2,
                     pay_element_entries_f pee2,
                     pay_run_result_values prrv2,
                     pay_assignment_actions paa2,
                     pay_run_results prr3
                where
                    prr2.element_type_id = pee2.element_type_id and
                    piv2.element_type_id = pee2.element_type_id and
                    prr2.run_result_id = prrv2.run_result_id and
                    prrv2.input_value_id = piv2.input_value_id and
                    paa2.assignment_action_id = prr2.assignment_action_id and
                    piv2.name = 'Transitional ETP' and
                    prrv2.result_value = p_transitional and
                    paa2.assignment_id = p_assignment_id and
                    prr2.source_id = prr3.source_id ) ;





cursor get_date_earned is select date_earned
                           from  pay_payroll_actions ppa
                            ,pay_assignment_actions paa
                           where paa.assignment_action_id=p_assignment_action_id
                             and paa.payroll_action_id=ppa.payroll_action_id;
begin

begin
  hr_utility.trace('-----------------------------------------');
  hr_utility.set_location('Entering : '||l_procedure, 1);



        Lv_Element_Name := 'Superannuation Rollover on Termination';
        Lv_Input_Name := 'Pay Value';
        if P_transitional = 'N' then

                  P_superAnnuation_rollover := 0;
        else

                open Term(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                        Fetch Term into P_superAnnuation_rollover;
                        If term%notfound then
                        P_superAnnuation_rollover := 0;
                        close term;
                        end If;
                If term%ISOPEN then
                close term;
                End if;

       /* Start 8769345 - Added code for fetching the taxable and tax free Super rollover amounts */

        Lv_Input_Name := 'Amount Part Prev ETP';

                open Term(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                Fetch Term into l_taxable_rollover_1;
                        If term%notfound then
                           l_taxable_rollover_1 := 0;
                           close term;
                        end If;
                If term%ISOPEN then
                close term;
                End if;

        Lv_Input_Name := 'Amount Not Part Prev ETP';

                open Term(p_Assignment_id,Lv_Element_Name,Lv_Input_Name);
                Fetch Term into l_taxable_rollover_2;
                        If term%notfound then
                           l_taxable_rollover_2 := 0;
                           close term;
                        end If;
                If term%ISOPEN then
                close term;
                End if;

        p_taxable_rollover := l_taxable_rollover_1 + l_taxable_rollover_2;
        p_tax_free_rollover := P_superAnnuation_rollover - p_taxable_rollover;

      /*End 8769345*/
        End if;
End;


Begin

        /* 6470561 */
         -- there if no individual balance for the two ETP types so we would have to fetch he value from run results for lump sum D

        Lv_Element_Name := 'Lump Sum D Payment';                        /* 6470561 */
        Lv_Input_Name := 'Pay Value';


        open Term2(p_Assignment_id,Lv_Element_Name,Lv_Input_Name,p_transitional);
                Fetch Term2 into P_Lump_sum_D;

                If term2%notfound then

                        P_Lump_sum_D := 0;
        close term2;
                end If;

                If term2%ISOPEN then
                close term2;
                End if;



        Exception
When No_Data_Found then
P_Lump_sum_D := 0;
When Others then
P_Lump_sum_D := 0;
raise;
End;

/* 6470561 */
begin

        Begin
/*
                select Balance_Type_id Into Lv_Balance_Type_id
                from Pay_Balance_Types
                Where Balance_Name = 'Lump Sum C Deductions'
                and Legislation_code = 'AU';


*/

if p_transitional = 'Y'
then
                select Balance_Type_id Into Lv_Balance_Type_id_1
                from Pay_Balance_Types
                Where Balance_Name = 'ETP Deductions Transitional Not Part of Prev Term'
                and Legislation_code = 'AU';

                select Balance_Type_id Into Lv_Balance_Type_id_2
                from Pay_Balance_Types
                Where Balance_Name = 'ETP Deductions Transitional Part of Prev Term'
                and Legislation_code = 'AU';
else
                select Balance_Type_id Into Lv_Balance_Type_id_1
                from Pay_Balance_Types
                Where Balance_Name = 'ETP Deductions Life Benefit Not Part of Prev Term'
                and Legislation_code = 'AU';

                select Balance_Type_id Into Lv_Balance_Type_id_2
                from Pay_Balance_Types
                Where Balance_Name = 'ETP Deductions Life Benefit Part of Prev Term'
                and Legislation_code = 'AU';

end if;


        Exception
                When others then
                Null;
End;


Begin
/* Added code to get the period end date for terminated employee
  Bug#2042529 */

  open get_date_earned;
   fetch get_date_earned into l_end_date;
   close get_date_earned;

/*                P_ETP_TAX :=  hr_aubal.calc_asg_ptd_date
                  (P_Assignment_id
                  ,Lv_balance_type_id
                  ,l_end_date
                  ); */
/* Bug# 4322599
  Modified the call for hr_aubal package by calling it in action mode rather then date mode */
  /* 6470561 */      P_ETP_TAX :=  hr_aubal.calc_asg_ptd_action
                               (P_Assignment_Action_id
                                ,Lv_balance_type_id_1
                                ,l_end_date)
                                +
                                hr_aubal.calc_asg_ptd_action
                               (P_Assignment_Action_id
                                ,Lv_balance_type_id_2
                                ,l_end_date);
End;
end;


/* 6470561 */
begin

        Begin

if p_transitional = 'Y'
then
                select Balance_Type_id Into Lv_Balance_Type_id_1
                from Pay_Balance_Types
                Where Balance_Name = 'Invalidity Payments Transitional Not Part of Prev Term'
                and Legislation_code = 'AU';

                select Balance_Type_id Into Lv_Balance_Type_id_2
                from Pay_Balance_Types
                Where Balance_Name = 'Invalidity Payments Transitional Part of Prev Term'
                and Legislation_code = 'AU';
else
                select Balance_Type_id Into Lv_Balance_Type_id_1
                from Pay_Balance_Types
                Where Balance_Name = 'Invalidity Payments Life Benefit Not Part of Prev Term'
                and Legislation_code = 'AU';

                select Balance_Type_id Into Lv_Balance_Type_id_2
                from Pay_Balance_Types
                Where Balance_Name = 'Invalidity Payments Life Benefit Part of Prev Term'
                and Legislation_code = 'AU';

end if;


        Exception
                When others then
                Null;
End;


Begin

  open get_date_earned;
   fetch get_date_earned into l_end_date;
   close get_date_earned;

           p_invalidity_component :=  hr_aubal.calc_asg_ptd_action
                               (P_Assignment_Action_id
                                ,Lv_balance_type_id_1
                                ,l_end_date)
                                +
                                hr_aubal.calc_asg_ptd_action
                               (P_Assignment_Action_id
                                ,Lv_balance_type_id_2
                                ,l_end_date);
End;
end;

/* 6470561 */



Begin
        Lv_Element_Name := 'ETP Payment';
        Lv_Input_Name := 'Pay Value';


        open Term2(p_Assignment_id,Lv_Element_Name,Lv_Input_Name,p_transitional);
                Fetch Term2 into p_ETP_Payment;


                If term2%notfound then
                        p_ETP_Payment := 0;
                        close term2;
                end If;

                If term2%ISOPEN then
                close term2;
                End if;

exception
when No_DatA_Found Then
hr_utility.trace('is cursor not found tarun ');
p_ETP_Payment := 0;
end;
/* 6470561 */
hr_utility.set_location('Leaving : '||l_procedure, 1);

return(1);
Exception
When Others then
hr_utility.set_location('exception in Leaving : '||l_procedure, 1);
return(0);
end ETP_payment_information;

------------------------------Function to get Invalidity Balances----------------------------------------

function get_invalidity_pay_bal(p_assignment_action_id in number,
                                p_assignment_id in number
                                ) return number is
   Lv_balance_type_id_1       number;
   Lv_balance_type_id_2       number;
   lv_invalidity_component    number;
   l_end_date                 date;
/* 6470561 */

    cursor get_date_earned is select date_earned
                           from  pay_payroll_actions ppa
                            ,pay_assignment_actions paa
                           where paa.assignment_action_id=p_assignment_action_id
                             and paa.payroll_action_id=ppa.payroll_action_id;

begin
                select Balance_Type_id Into Lv_Balance_Type_id_1
                from Pay_Balance_Types
                Where Balance_Name = 'Invalidity Payments Transitional Not Part of Prev Term'
                and Legislation_code = 'AU';

                select Balance_Type_id Into Lv_Balance_Type_id_2
                from Pay_Balance_Types
                Where Balance_Name = 'Invalidity Payments Transitional Part of Prev Term'
                and Legislation_code = 'AU';


 open get_date_earned;
   fetch get_date_earned into l_end_date;
   close get_date_earned;



              lv_invalidity_component :=  hr_aubal.calc_asg_ptd_action
                               (P_Assignment_Action_id
                                ,Lv_balance_type_id_1
                                ,l_end_date)
                                +
                                hr_aubal.calc_asg_ptd_action
                               (P_Assignment_Action_id
                                ,Lv_balance_type_id_2
                                ,l_end_date);


return lv_invalidity_component;


Exception when others then
return(0);
raise_application_error(-20001,sqlerrm);


/* 6470561 */
end get_invalidity_pay_bal;

/* Start 8769345 - A new function is added in order to calculate ETP taxable and tax-free components
                   after super rollover for transitional ETP and return the values to termination report. */

/* Bug 9322314 - Added two input parameters to the function for passing the pre and post 83 ratios for
                 computing the taxable and tax free ETP components */

function get_etp_pre_post_components(p_assignment_action_id in    number,
                                       p_assignment_id        in    number,
                                       p_pre_jul83_ratio      in    number,
                                       p_post_jun83_ratio     in    number,
                                       p_etp_tax_free_amt    out nocopy number,
                                       p_etp_taxable_amt     out nocopy number
                                       ) return number
is
   Lv_balance_type_id_1       number;
   Lv_balance_type_id_2       number;
   Lv_balance_type_id_3       number;
   Lv_balance_type_id_4       number;
   Lv_balance_type_id_5       number;
   Lv_balance_type_id_6       number;

/* Start 9322314 - Added variables to store the etp payments */
   l_etp_trans_pp_amt         number;
   l_etp_trans_npp_amt        number;
   l_etp_trans_npp_tfree_amt  number;
   l_etp_trans_npp_taxable_amt  number;
   l_etp_trans_pp_tfree_amt     number;
   l_etp_trans_pp_taxable_amt   number;

   l_trans_npp_tfree_amt     number;
   l_trans_npp_taxable_amt   number;
   l_trans_pp_tfree_amt      number;
   l_trans_pp_taxable_amt    number;

/* End 9322314 */


   l_end_date                 date;

    cursor get_date_earned is
    select date_earned
    from  pay_payroll_actions ppa
          ,pay_assignment_actions paa
    where paa.assignment_action_id = p_assignment_action_id
    and   paa.payroll_action_id = ppa.payroll_action_id;


begin

        select Balance_Type_id Into Lv_Balance_Type_id_1
        from Pay_Balance_Types
        Where Balance_Name = 'ETP Tax Free Payments Transitional Not Part of Prev Term'
        and Legislation_code = 'AU';

        select Balance_Type_id Into Lv_Balance_Type_id_2
        from Pay_Balance_Types
        Where Balance_Name = 'ETP Tax Free Payments Transitional Part of Prev Term'
        and Legislation_code = 'AU';

        select Balance_Type_id Into Lv_Balance_Type_id_3
        from Pay_Balance_Types
        Where Balance_Name = 'ETP Taxable Payments Transitional Not Part of Prev Term'
        and Legislation_code = 'AU';

        select Balance_Type_id Into Lv_Balance_Type_id_4
        from Pay_Balance_Types
        Where Balance_Name = 'ETP Taxable Payments Transitional Part of Prev Term'
        and Legislation_code = 'AU';

/* Start 9322314 - Modified the logic in the function for calculating the taxable and tax free ETP components
                   for terminated employees processed before and after applying the patch 8769345, such that
		   the all values are reported correctly in the termination report */

        select Balance_Type_id Into Lv_Balance_Type_id_5
        from Pay_Balance_Types
        Where Balance_Name = 'ETP Payments Transitional Not Part of Prev Term'
        and Legislation_code = 'AU';

        select Balance_Type_id Into Lv_Balance_Type_id_6
        from Pay_Balance_Types
        Where Balance_Name = 'ETP Payments Transitional Part of Prev Term'
        and Legislation_code = 'AU';

   open get_date_earned;
   fetch get_date_earned into l_end_date;
   close get_date_earned;


	 l_etp_trans_npp_tfree_amt :=  nvl(hr_aubal.calc_asg_ptd_action
			             (P_Assignment_Action_id
			             ,Lv_balance_type_id_1
			             ,l_end_date),0);

	 l_etp_trans_pp_tfree_amt := nvl(hr_aubal.calc_asg_ptd_action
                                     (P_Assignment_Action_id
                                    ,Lv_balance_type_id_2
                                    ,l_end_date),0);


          l_etp_trans_npp_taxable_amt := nvl(hr_aubal.calc_asg_ptd_action
                                        (P_Assignment_Action_id
                                        ,Lv_balance_type_id_3
                                        ,l_end_date),0);

         l_etp_trans_pp_taxable_amt := nvl(hr_aubal.calc_asg_ptd_action
                                     (P_Assignment_Action_id
                                      ,Lv_balance_type_id_4
                                     ,l_end_date),0);


         l_etp_trans_npp_amt := nvl(hr_aubal.calc_asg_ptd_action
                               (P_Assignment_Action_id
                              ,Lv_balance_type_id_5
                              ,l_end_date),0);

        l_etp_trans_pp_amt := nvl(hr_aubal.calc_asg_ptd_action
                              (P_Assignment_Action_id
                             ,Lv_balance_type_id_6
                             ,l_end_date),0);

   if (l_etp_trans_npp_amt - (l_etp_trans_npp_tfree_amt + l_etp_trans_npp_taxable_amt ) > 0 ) then

       l_trans_npp_tfree_amt := (l_etp_trans_npp_amt - (l_etp_trans_npp_tfree_amt + l_etp_trans_npp_taxable_amt))* p_pre_jul83_ratio +
                                l_etp_trans_npp_tfree_amt;

       l_trans_npp_taxable_amt := (l_etp_trans_npp_amt - (l_etp_trans_npp_tfree_amt + l_etp_trans_npp_taxable_amt))* p_post_jun83_ratio +
                                  l_etp_trans_npp_taxable_amt ;

  elsif (l_etp_trans_npp_amt - (l_etp_trans_npp_tfree_amt + l_etp_trans_npp_taxable_amt ) = 0 ) then

      l_trans_npp_tfree_amt := l_etp_trans_npp_tfree_amt ;
      l_trans_npp_taxable_amt := l_etp_trans_npp_taxable_amt;

  end if;

  if (l_etp_trans_pp_amt - (l_etp_trans_pp_tfree_amt + l_etp_trans_pp_taxable_amt ) > 0 ) then

       l_trans_pp_tfree_amt := (l_etp_trans_pp_amt - (l_etp_trans_pp_tfree_amt + l_etp_trans_pp_taxable_amt))* p_pre_jul83_ratio +
                               l_etp_trans_pp_tfree_amt;

       l_trans_pp_taxable_amt := (l_etp_trans_pp_amt - (l_etp_trans_pp_tfree_amt + l_etp_trans_pp_taxable_amt))* p_post_jun83_ratio +
                                l_etp_trans_pp_taxable_amt ;

   elsif (l_etp_trans_pp_amt - (l_etp_trans_pp_tfree_amt + l_etp_trans_pp_taxable_amt ) = 0 ) then

       l_trans_pp_tfree_amt := l_etp_trans_pp_tfree_amt ;
       l_trans_pp_taxable_amt := l_etp_trans_pp_taxable_amt;

  end if;


   p_etp_tax_free_amt := l_trans_npp_tfree_amt + l_trans_pp_tfree_amt ;
   p_etp_taxable_amt := l_trans_npp_taxable_amt + l_trans_pp_taxable_amt;

/* End 9322314 */
return (1);

Exception when others then
 return(0);
 raise_application_error(-20001,sqlerrm);

end get_etp_pre_post_components;

/* End 8769345 */

end pay_au_term_rep;

/
