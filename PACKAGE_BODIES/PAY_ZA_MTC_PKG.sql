--------------------------------------------------------
--  DDL for Package Body PAY_ZA_MTC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_MTC_PKG" as
/* $Header: pyzamtc.pkb 120.4.12010000.2 2009/11/19 06:47:54 rbabla ship $ */

------------------------------------------------------------------------------
-- NAME
--   update_certificate_number
-- PURPOSE
--   Issues manual Tax Certificate Numbers
-- ARGUMENTS
--   p_errmsg         - Returned error message
--   p_errcode        - Returned error code
--   p_bgid           - The Business Group ID
--   p_payroll_id     - The Payroll ID
--   p_tax_year       - The Tax Year
--   p_pay_action_id  - The Payroll Action ID of the Tax Certificate Preprocess
--   p_asg_id         - The Assignment ID to process
--   p_asg_action_id  - The Assignment Action ID to process
--   p_tax_cert_no    - The Tax Certificate Number
-- NOTES
--
------------------------------------------------------------------------------
procedure update_certificate_number
(
   p_errmsg        out nocopy varchar2,
   p_errcode       out nocopy varchar2,
   p_bgid          in  number,
   p_payroll_id    in  number,
   p_tax_year      in  varchar2,
   p_pay_action_id in  varchar2,
   p_asg_id        in  number,
   p_asg_action_id in  number,
   p_tax_cert_no   in  varchar2
)  is

-- Cursor used to update Tax Certificate Numbers
cursor c_tax_cert_no is
select serial_number
from   pay_assignment_actions
where  assignment_action_id = p_asg_action_id;

-- Cursor used to find all the other Main Certificate Assignment Actions,
-- for the current Assignment in the same Tax Year
cursor other_ass_main is
   select paa.serial_number, paa.assignment_action_id
   from   pay_assignment_actions paa,
          pay_payroll_actions    ppa
   where  ppa.business_group_id = p_bgid
   and    ppa.report_type = 'ZA_IRP5'
   and    ppa.action_type = 'X'
   and    substr(ppa.legislative_parameters, instr(ppa.legislative_parameters, 'TAX_YEAR') + 9, 4)
          = p_tax_year
   and    ppa.payroll_action_id <> substr(p_pay_action_id, 28, 9)
   and    paa.payroll_action_id = ppa.payroll_action_id
   and    paa.assignment_id = p_asg_id
   and    paa.action_sequence =
   (
      select max(paa2.action_sequence)
      from   pay_assignment_actions paa2
      where  paa2.payroll_action_id = ppa.payroll_action_id
      and    paa2.assignment_id = p_asg_id
   );

-- Cursor used to find all the other Lump Sum Certificate Assignment Actions for the
-- current Assignment in the same Tax Year, and for a specific Time Period ID
cursor other_ass_ls(p_period varchar2) is
   select paa.serial_number, paa.assignment_action_id
   from   pay_assignment_actions paa,
          pay_payroll_actions    ppa,
          ff_database_items      dbi,
          ff_archive_items       arc
   where  ppa.business_group_id = p_bgid
   and    ppa.report_type = 'ZA_IRP5'
   and    ppa.action_type = 'X'
   and    substr(ppa.legislative_parameters, instr(ppa.legislative_parameters, 'TAX_YEAR') + 9, 4)
          = p_tax_year
   and    ppa.payroll_action_id <> substr(p_pay_action_id, 28, 9)
   and    paa.payroll_action_id = ppa.payroll_action_id
   and    paa.assignment_id = p_asg_id
   and    dbi.user_name = 'A_PAY_PROC_PERIOD_ID'
   and    arc.user_entity_id = dbi.user_entity_id
   and    arc.context1 = to_char(paa.assignment_action_id)
   and    arc.value = p_period
   and    paa.action_sequence <>
   (
      select max(paa2.action_sequence)
      from   pay_assignment_actions paa2
      where  paa2.payroll_action_id = ppa.payroll_action_id
      and    paa2.assignment_id = p_asg_id
   );

-- Variables
l_old_cert_no  varchar2(30);
l_lump_sum_ind varchar2(1);
l_old_num      pay_assignment_actions.serial_number%type;
l_old_aa       pay_assignment_actions.assignment_action_id%type;
l_period       varchar2(240);

begin

   -- Fetch the Tax Certificate Number to be updated
   open  c_tax_cert_no;
   fetch c_tax_cert_no into l_old_cert_no;

   if c_tax_cert_no%notfound then

      -- No data found
      p_errmsg  := 'No Data found';
      p_errcode := 20001;

   else

      -- Check if Certificate Number is updateable
      if substr(l_old_cert_no, 1, 1) in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '&') then

         -- The Tax Certificate Number is not updateable
         p_errmsg  := 'A Electronically generated or Reissued Tax Certificate Number already exist';
         p_errcode := 20001;

      else

         -- Find out whether there are any old Certificate Numbers,
         -- that should be marked as reissued
         -- Is this a Main or a Lump Sum Certificate
-- added for 6266019

        Select decode(count(*), 0 ,'Y', 'N')
           into   l_lump_sum_ind
            From      pay_payroll_actions    ppa_arch,
              pay_assignment_actions paa_arch
        where paa_arch.assignment_action_id = p_asg_action_id
        and   ppa_arch.payroll_action_id    = paa_arch.payroll_action_id
        and   paa_arch.assignment_action_id =
        (
           select max(paa.assignment_action_id)
           from   pay_assignment_actions paa
           where  paa.payroll_action_id = ppa_arch.payroll_action_id
           and   paa.assignment_id = paa_arch.assignment_id
        ) ;
/* commented for 6266019
         pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID', to_char(p_asg_action_id));
         l_lump_sum_ind := nvl(pay_balance_pkg.run_db_item('ZA_LUMP_SUM_INDICATOR', null, 'ZA'), 'N');
*/
         -- Check whether this is a Main Certificate
         if l_lump_sum_ind = 'N' then

            -- Find out whether a previous Main Certificate exist
            open other_ass_main;
            loop

               fetch other_ass_main into l_old_num, l_old_aa;
               exit when other_ass_main%notfound;

               if l_old_num is not null then

                  if substr(l_old_num, 1, 1) in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0') then

                     -- The Tax Certificate Number is not updateable
                     p_errmsg  := 'A Electronically generated Tax Certificate Number already exist';
                     p_errcode := 20001;

                     -- Exit without writing the number
                     close other_ass_main;
                     close c_tax_cert_no;
                     return;

                  elsif ((substr(l_old_num, 1, 2) = '&&') and
                         (substr(l_old_num, 3, 1) in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0'))) then

                     -- The Tax Certificate Number is not updateable
                     p_errmsg  := 'A Electronically generated Tax Certificate Number already exist';
                     p_errcode := 20001;

                     -- Exit without writing the number
                     close other_ass_main;
                     close c_tax_cert_no;
                     return;

                  else

                     if substr(l_old_num, 1, 2) <> '&&' then

                        -- Update the Assignment Action to reflect that this is an old number
                        update pay_assignment_actions
                        set    serial_number = '&&' || l_old_num
                        where  assignment_action_id = l_old_aa;

                     end if;

                  end if;

               end if;

            end loop;

            close other_ass_main;

         else   -- This is a Lump Sum Certificate

            -- Get the current Assignment Action's Time Period ID
            select nvl(arc.value, '')
            into   l_period
            from   ff_database_items dbi,
                   ff_archive_items  arc
            where  dbi.user_name = 'A_PAY_PROC_PERIOD_ID'
            and    arc.user_entity_id = dbi.user_entity_id
            and    arc.context1 = p_asg_action_id;

            -- Find out whether a previous Lump Sum Certificate exist
            open other_ass_ls(l_period);
            loop

               fetch other_ass_ls into l_old_num, l_old_aa;
               exit when other_ass_ls%notfound;

               if l_old_num is not null then

                  if substr(l_old_num, 1, 1) in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0') then

                     -- The Tax Certificate Number is not updateable
                     p_errmsg  := 'A Electronically generated Tax Certificate Number already exist';
                     p_errcode := 20001;

                     -- Exit without writing the number
                     close other_ass_main;
                     close c_tax_cert_no;
                     return;

                  elsif ((substr(l_old_num, 1, 2) = '&&') and
                         (substr(l_old_num, 3, 1) in ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0'))) then

                     -- The Tax Certificate Number is not updateable
                     p_errmsg  := 'A Electronically generated Tax Certificate Number already exist';
                     p_errcode := 20001;

                     -- Exit without writing the number
                     close other_ass_main;
                     close c_tax_cert_no;
                     return;

                  else

                     if substr(l_old_num, 1, 2) <> '&&' then

                        -- Update the Assignment Action to reflect that this is an old number
                        update pay_assignment_actions
                        set    serial_number = '&&' || l_old_num
                        where  assignment_action_id = l_old_aa;

                     end if;

                  end if;

               end if;

            end loop;

            close other_ass_ls;

         end if;

         -- The Tax Certificate Number is updateable
         update pay_assignment_actions
         set    serial_number        = p_tax_cert_no
         where  assignment_action_id = p_asg_action_id;

         -- Commit the record
         commit;
         p_errmsg := 'Tax Certificate Number Issued';

      end if;

   end if;

   close c_tax_cert_no;
exception
   when others then
	p_errmsg := null;
	p_errcode := null;
end update_certificate_number;

Procedure upd_certificate_num_EOY2010
          (
           p_errmsg            out nocopy varchar2,
           p_errcode           out nocopy varchar2,
           p_bgid              in  number,
           p_legal_entity_id   in  number,
           p_tax_year          in  varchar2,
           p_payroll           in  number,
           p_pay_action_id     in  number,
           p_asg_id            in  number,
           p_temp_cert_no      in  varchar2,
           p_tax_cert_no       in  varchar2
          )
is

   --Cursor to get the assignment action id
   cursor csr_ass_act_id is
     select assignment_action_id
     from   pay_assignment_actions
     where  payroll_action_id = p_pay_action_id
     and    assignment_id = p_asg_id;

   --Cursor to get the certificate number
   cursor csr_cert_details (ass_act_id pay_assignment_actions.assignment_action_id%type
                           ,p_cert_num varchar2) IS
     select pai.action_information1   cert_num,       -- Certificate Number
            pai.action_information29  man_cert_num,   -- Manual Certificate Number
            pai.action_information28  cert_ind,       -- O for old electronic, M for manual, OM for old manual
            pai.action_information30  temp_cert_num,  -- Temporary Certificate Number
            pai.action_information_id act_inf_id,
            pai.action_information18  directive1,     -- Directive 1
            pai.action_information19  directive2,     -- Directive 2
            pai.action_information20  directive3,     -- Directive 3
            pai2.action_information26 cert_type      -- MAIN/LMPSM
     from  pay_action_information pai, -- For Employee info
           pay_action_information pai2 -- For Employee contact info
     where pai.action_context_id=ass_act_id
     and   pai.action_information30 = p_cert_num
     and   pai.action_information_category='ZATYE_EMPLOYEE_INFO'
     and   pai2.action_information_category='ZATYE_EMPLOYEE_CONTACT_INFO'
     and   pai2.action_context_id = pai.action_context_id
     and   pai2.action_information30 = pai.action_information30
     and   pai.action_context_type = 'AAP'
     and   pai.action_context_type = pai2.action_context_type;

   -- Cursor used to find all the other main certificate details
   -- for the current Assignment in the same Tax Year
   -- with certificate type not ITREG
   cursor csr_other_ass_actions(p_cert_type varchar2) is
     select paa.assignment_action_id ass_act_id,
            pai.action_information1 cert_num,         --Certificate Number
            pai.action_information29 man_cert_num,    --Manual Certificate Number
            pai.action_information28 cert_ind,        --O - old electronic, M - Manual, OM - Old Manual
            pai.action_information30 temp_cert_num,   --Temporary certificate Number
            pai.action_information18  directive1,     -- Directive 1
            pai.action_information19  directive2,     -- Directive 2
            pai.action_information20  directive3,     -- Directive 3
            pai2.action_information26 cert_type,       --MAIN/LMPSM
            pai.action_information_id act_inf_id,
            pai2.action_information_id act_inf_id2
     from   pay_assignment_actions paa,
            pay_payroll_actions    ppa,
            pay_action_information pai, --For Employee Info
            pay_action_information pai2 --For Employee contact info
     where  ppa.business_group_id = p_bgid
     and    ppa.report_type = 'ZA_TYE'
     and    ppa.action_type = 'X'
     and    substr(ppa.legislative_parameters, instr(ppa.legislative_parameters, 'TAX_YEAR') + 9, 4)
            = p_tax_year
     and    ppa.payroll_action_id <> p_pay_action_id
     and    paa.payroll_action_id = ppa.payroll_action_id
     and    paa.assignment_id = p_asg_id
     and    paa.assignment_id = pai.assignment_id
     and    paa.assignment_action_id = pai.action_context_id
     and    pai.action_information_category= 'ZATYE_EMPLOYEE_INFO'
     and    pai.action_context_id = pai2.action_context_id
     and    pai2.action_information_category='ZATYE_EMPLOYEE_CONTACT_INFO'
     and    pai2.action_information30 = pai.action_information30
     and    pai.action_context_type = 'AAP'
     and    pai.action_context_type = pai2.action_context_type
     and    pai.action_information2 not in ('ITREG','A')
     and    pai2.action_information26 = p_cert_type;

   l_proc    varchar2(100):='PAY_ZA_MTC_PKG.upd_certificate_num_EOY2010';
   rec_cert_details     csr_cert_details%rowtype;
   l_ass_act_id         pay_assignment_actions.assignment_action_id%type;
   rec_other_ass_actions csr_other_ass_actions%rowtype;
begin
    hr_utility.set_location('Entering '||l_proc,10);
    hr_utility.set_location('p_bgid             :'||p_bgid,10);
    hr_utility.set_location('p_tax_year         :'||p_tax_year,10);
    hr_utility.set_location('p_legal_entity_id  :'||p_legal_entity_id,10);
    hr_utility.set_location('p_pay_action_id    :'||p_pay_action_id,10);
    hr_utility.set_location('p_asg_id           :'||p_asg_id,10);
    hr_utility.set_location('p_temp_cert_no     :'||p_temp_cert_no,10);
    hr_utility.set_location('p_tax_cert_no      :'||p_tax_cert_no,10);

    -- Get the assignment action for particular preprocess
    open csr_ass_act_id;
    fetch csr_ass_act_id into l_ass_act_id;
    close csr_ass_act_id;

    -- Retrieve the archived certificate numbers/indicators for the selected assignment action
    hr_utility.set_location('Retrieving certificate details for this preprocess',12);
    open csr_cert_details(l_ass_act_id,p_temp_cert_no);
    fetch csr_cert_details into rec_cert_details;
    close csr_cert_details;

    -- Electronically generated certificate already exists
    if rec_cert_details.cert_num is not null then
          hr_utility.set_location('Selected preprocess has electronic certificate issued',14);
          p_errmsg  := 'A Electronically generated or Reissued Tax Certificate Number already exist.';
          p_errcode := 20001;
          return;
    else
          --The electronic certificate not generated for selected assignment action
          --Check whether the selected assignment action is MAIN or directive numbers.
          --If it is main then check whether any previous main certificate is
          --issued electronically. If not then check whether any directive present
          --in the selected MAIN has previous Lump sum certificate electronically issued.
          if rec_cert_details.cert_type = 'MAIN' then
               hr_utility.set_location('Directive Number selected is MAIN',16);
               -- Check the previous MAIN certificates if issued electronically
               open csr_other_ass_actions('MAIN');
               loop
                     hr_utility.set_location('Loop through the previous MAIN certificates',18);
                     fetch csr_other_ass_actions into rec_other_ass_actions;
                     exit when csr_other_ass_actions%notfound;

                     --Certificate number will be generated only when the IRP5/
                     --IT3A is run. If Certificate number is not null suggests
                     --electronic certificate is already issued.
                     if rec_other_ass_actions.cert_num is not null then
                          hr_utility.set_location('Previous preprocess has electronic certificate issued',22);
                          p_errmsg  := 'A Electronically generated or Reissued Tax Certificate Number already exist.';
                          p_errcode := 20001;
                          close csr_other_ass_actions;
                          return;
                     elsif rec_other_ass_actions.cert_ind='M' then
                          hr_utility.set_location('Previous preprocess has manual certificate issued',24);
                          update pay_action_information
                          set    action_information28 ='OM'
                          where  action_information_id=rec_other_ass_actions.act_inf_id;
                     end if;
               end loop;
               close csr_other_ass_actions;

              -- Previously issued electronic main certificate does not exist.
              -- check whether the lump sum directive in the main certificate have
              -- previously issued electronic lump sum certificate.
               if rec_cert_details.directive1 is not null OR rec_cert_details.directive2 is not null
                  OR rec_cert_details.directive3 is not null
               then
                  hr_utility.set_location('Check the previous Lump sums',30);
                  open csr_other_ass_actions('LMPSM');
                  loop
                     hr_utility.set_location('Loop through the previous LMPSM certificates',32);
                     fetch csr_other_ass_actions into rec_other_ass_actions;
                     exit when csr_other_ass_actions%notfound;

                     if ((rec_cert_details.directive1 = rec_other_ass_actions.directive1)
                          OR
                         (rec_cert_details.directive2 = rec_other_ass_actions.directive1)
                          OR
                         (rec_cert_details.directive3 = rec_other_ass_actions.directive1))
                        AND rec_other_ass_actions.cert_num is not null then
                              hr_utility.set_location('Previous preprocess has electronic certificate issued',36);
                              p_errmsg  := 'A Electronically generated or Reissued Tax Certificate Number already exist.';
                              p_errcode := 20001;
                              close csr_other_ass_actions;
                              return;
                     elsif ((rec_cert_details.directive1 = rec_other_ass_actions.directive1)
                            OR
                            (rec_cert_details.directive2 = rec_other_ass_actions.directive1)
                            OR
                            (rec_cert_details.directive3 = rec_other_ass_actions.directive1))
                        AND rec_other_ass_actions.cert_num is null
                        AND rec_other_ass_actions.cert_ind='M' then
                              hr_utility.set_location('Previous preprocess has manual certificate issued',40);
                              update pay_action_information
                              set    action_information28 ='OM'
                              where  action_information_id=rec_other_ass_actions.act_inf_id;
                     end if;
                  end loop;
                  close csr_other_ass_actions;
             end if;

          --Certificate is not main, hence manual issue requested for lump
          --sum certificate. For Lump Sum Certificates, first check whether any
          --previous lump sum certificate issued for same directive.
          --If not, then check the directives in the issued main certificates, if it
          --matches with the lump sum directive
          else
               hr_utility.set_location('Directive Number selected is LMPSM',42);
               open csr_other_ass_actions('LMPSM');
               loop
                     fetch csr_other_ass_actions into rec_other_ass_actions;
                     exit when csr_other_ass_actions%notfound;

                     --Certificate number will be generated only when the IRP5/
                     --IT3A is run. If Certificate number is not null suggests
                     --electronic certificate is already issued.
                     if rec_other_ass_actions.directive1 = rec_cert_details.directive1
                        AND rec_other_ass_actions.cert_num is not null then
                            hr_utility.set_location('Previous preprocess has electronic certificate issued.',44);
                            p_errmsg  := 'A Electronically generated or Reissued Tax Certificate Number already exist.';
                            p_errcode := 20001;
                            close csr_other_ass_actions;
                            return;
                     elsif rec_other_ass_actions.directive1 = rec_cert_details.directive1
                         AND rec_other_ass_actions.cert_ind='M' then
                            hr_utility.set_location('Previous preprocess has manual certificate issued.',46);
                            update pay_action_information
                            set    action_information28 ='OM'
                            where  action_information_id=rec_other_ass_actions.act_inf_id;
                     end if;
               end loop;
               close csr_other_ass_actions;

              -- Previously issued electronic lump sum certificate does not exist.
              -- check whether previously issued main certificate has
              -- this directive.
               open csr_other_ass_actions('MAIN');
               loop
                     fetch csr_other_ass_actions into rec_other_ass_actions;
                     exit when csr_other_ass_actions%notfound;

                     --Certificate number will be generated only when the IRP5/
                     --IT3A is run. If Certificate number is not null suggests
                     --electronic certificate is already issued.
                     if ((rec_other_ass_actions.directive1 = rec_cert_details.directive1)
                          OR
                         (rec_other_ass_actions.directive2 = rec_cert_details.directive1)
                          OR
                         (rec_other_ass_actions.directive3 = rec_cert_details.directive1))
                        AND rec_other_ass_actions.cert_num is not null then
                              hr_utility.set_location('Previous preprocess has electronic certificate issued',48);
                              p_errmsg  := 'A Electronically generated or Reissued Tax Certificate Number already exist.';
                              p_errcode := 20001;
                              close csr_other_ass_actions;
                              return;
                     end if;
                    --Did not place the else condition to update the main certificate
                    --manually issued earlier to OM, because in main certificate, there are normal
                    --incomes too which are not included in lump sum certificate. Hence manually
                    --issued main certificate will not be updated to OM in this case.
               end loop;
               close csr_other_ass_actions;
          end if;
    end if;  -- End rec_cert_details.cert_num is not null

    --Update the Certificate Indicator and manual certificate number
    hr_utility.set_location('Update with manual certificate details',60);
    update pay_action_information
    set    action_information28='M', action_information29=p_tax_cert_no
    where  action_information_id=rec_cert_details.act_inf_id;

    -- Commit the record
    hr_utility.set_location('Committing the record',70);
    commit;
    p_errmsg := 'Tax Certificate Number Issued.';

exception
   when others then
      p_errmsg := null;
      p_errcode := null;
end upd_certificate_num_EOY2010;

end pay_za_mtc_pkg;

/
