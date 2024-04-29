--------------------------------------------------------
--  DDL for Package Body PER_PL_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_ASSIGNMENT" as
/* $Header: peplasgp.pkb 120.10.12010000.5 2010/04/01 13:15:58 parusia ship $ */

g_package_name varchar2(18);

cursor csr_oldage_taxoffice_check(r_person_id in number,r_date date) is
       select per_information4,per_information6
        from  per_all_people_f
        where person_id=r_person_id
        and   r_date between effective_start_date and effective_end_date ;

cursor csr_check_sii_exists(r_join_variable in number,r_date date) is
        select '1'
        from   pay_pl_sii_details_f
        where  per_or_asg_id=r_join_variable
        and    r_date between effective_start_date and effective_end_date;

cursor csr_check_paye_exists(r_join_variable in number,r_date date)  is
        select '1'
        from  pay_pl_paye_details_f
        where per_or_asg_id=r_join_variable
        and   r_date between effective_start_date and effective_end_date;

cursor csr_assgt_type(r_assignment_id number,r_date date) is
    select per_system_status
    from   per_assignment_status_types paat , per_all_assignments_f paaf
    where  paat.assignment_status_type_id=paaf.assignment_status_type_id
    and    assignment_id=r_assignment_id
    and    r_date between effective_start_date and effective_end_date;
function get_person_id(l_assignment_id number,l_date date)  return number is
     cursor csr_person_id is
            select person_id
            from   per_all_assignments_f
            where  assignment_id=l_assignment_id
            and    l_date between effective_start_date and effective_end_date;
    l_personid number;
    begin
    --effective date reduces the number of rows returned by cursor..thats why it has been  put up.
     open csr_person_id;
     fetch csr_person_id into l_personid;
     close csr_person_id;

    return l_personid;
    Exception
    When others then
     hr_utility.set_location(g_package_name||'get_person_id',10);
     hr_utility.raise_error;
    end get_person_id;


PROCEDURE create_pl_secondary_emp_asg
                     ( p_person_id                  number
                      ,p_payroll_id                 number
                      ,p_effective_date             date
                      ,p_scl_segment3               varchar2
                      ,p_scl_segment4               varchar2
                      ,p_scl_segment5               varchar2
                      ,p_scl_segment6               varchar2
                      ,p_scl_segment7               varchar2
                      ,p_scl_segment8               varchar2
                      ,p_scl_segment9               varchar2
                      ,p_scl_segment11              varchar2
                      ,p_scl_segment12              varchar2
                      ,p_scl_segment13              varchar2
                      ,p_scl_segment14              varchar2
                      ,p_scl_segment15              varchar2
                      ,p_scl_segment16              varchar2
                      ,p_notice_period              number
                      ,P_NOTICE_PERIOD_UOM          VARCHAR2
                      ,p_employment_category        varchar2
                  ) is

l_proc                     varchar2(45);
l_oldage_pension_rights    per_all_people_f.per_information4%TYPE;
l_tax_office               per_all_people_f.per_information6%TYPE;
l_one                      number(1);
l_join_variable             number(10);

begin
/*
segment3 Contract Category
segment4 Contract Type
segment5 Contract Number
segment6 Change of contract Reason        --no check
segment7 Job                    --no check
segment8 Work in special Condition        --no check
segment9 End of Contract  Addl Details   --no check
segment11 Contract Start Date
segment12 Planned Valid To date
segment13 Contract Type Change Date
segment14 Date Contract Signed
segment15 Notice Period Date
segment16 Notice Period End Date
--1)Mandatory argument checks
--2)Conditionally mandatory arguments ...planned valid to date,notice_period,notice_period_date(scl_segment15),notice_period_end_date(scl_segment16),employment_category
--3)contract number cannot be longer than 30 characters
--4)Date checks
--5)payroll check ...check for oldage pension rights and nip.....if civil contract..error out if payroll is not null  ...if normal contract then chack for sii and paye details....
*/

g_package_name :='PER_PL_ASSIGNMENT.';
l_proc := g_package_name||'CREATE_PL_SECONDARY_EMP_ASG';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
hr_utility.set_location(l_proc,10);


hr_api.mandatory_arg_error  --Contract Category is mandatory
        (p_api_name         => l_proc,
         p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_CATEGORY'),
         p_argument_value   => p_scl_segment3
        );

hr_api.mandatory_arg_error  --Contract Type is Mandatory
        (p_api_name         => l_proc,
         p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE'),
         p_argument_value   => p_scl_segment4
         );


hr_api.mandatory_arg_error --Contract Number is Mandatory
        (p_api_name         => l_proc,
         p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_NUMBER'),
         p_argument_value   => p_scl_segment5
        );

hr_api.mandatory_arg_error --Contract Start Date is mandatory
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'),
            p_argument_value   => p_scl_segment11
            );

hr_api.mandatory_arg_error --Date Contract Signed is mandatory
            (p_api_name         => l_proc,
             p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','DATE_CONTRACT_SIGNED'),
             p_argument_value   => p_scl_segment14
             );

hr_utility.set_location(l_proc,20);
     ------Conditionally mandatory---------
     --------for a normal contract,the assignment category is mandatory...
     -------core store this in employment_category in per_all_assignments_f table..displays it as assignment_category on UI
       if p_scl_segment3='NORMAL'  then
         hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT_CATEGORY'),
            p_argument_value   => P_EMPLOYMENT_CATEGORY
           );
       end if;


       if p_scl_segment3='NORMAL' and p_scl_segment4<>'N01' then
          hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','PLANNED_VALID_TO_DATE'),
            p_argument_value   => P_SCL_SEGMENT12
           );
       elsif p_scl_segment12 is not null then
             hr_utility.set_message(800,'HR_375869_PLANNED_DATE_INVALID');
             hr_utility.raise_error;
       end if;

       -----if any of the following 3 has been entered then ..other two become mandatory
       -----Notice Period Date(p_scl_segment15),Notice Period End Date(p_scl_segment16),Notice Period(p_notice_period)
       if p_scl_segment16||p_scl_segment15||p_notice_period is not null then
             hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_END_DATE'),
              p_argument_value   => p_scl_segment16
             );
             hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_DATE'),
              p_argument_value   => p_scl_segment15
             );
             hr_api.mandatory_arg_error
             (p_api_name         => l_proc,
              p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD'),
              p_argument_value   => p_notice_period
             );
       if ( (p_NOTICE_PERIOD_UOM  like '_1' and  p_notice_period >1) or
            (p_NOTICE_PERIOD_UOM  like '_'  and  p_notice_period =1)) then
           hr_utility.set_message(800,'HR_375856_NOTICE_UNIT_MISMATCH');
           hr_utility.raise_error;
        end if;
       end if;
      -----if p_notice_period is entered and notice_period_uom is null??
      -----taken care by core per_asg_bus3.chk_notice_period_uom


     --Bug 4504375
     -- change of contract reason and contract type change date are mandatory
     -- if any one of them is not null
      if  p_scl_segment6 is not null and p_scl_segment13 is null then
          hr_utility.set_message(800,'HR_375835_ENTER_OTHER_VALUE');
          hr_utility.set_message_token(l_token_name=>'DETAIL1',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CHANGE_OF_CONTRACT_REASON')));
          hr_utility.set_message_token(l_token_name=>'DETAIL2',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE')));

          hr_utility.raise_error;
       elsif p_scl_segment6 is  null and p_scl_segment13 is not  null then
          hr_utility.set_message(800,'HR_375835_ENTER_OTHER_VALUE');
          hr_utility.set_message_token(l_token_name=>'DETAIL1',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE')));

          hr_utility.set_message_token(l_token_name=>'DETAIL2',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CHANGE_OF_CONTRACT_REASON')));
          hr_utility.raise_error;
       end if;

      -----other validations like value set comparison will be taken
      -----care by core when they validate the flexfields.
      -----what we need to check are the dates being entered.
    hr_utility.set_location(l_proc,30);
    if fnd_date.canonical_to_date(p_scl_segment11) < p_effective_date then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT_START_DATE'));
        hr_utility.raise_error;

    elsif fnd_date.canonical_to_date(p_scl_segment12) < fnd_date.canonical_to_date(p_scl_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PLANNED_VALID_TO_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;

    elsif fnd_date.canonical_to_date(p_scl_segment13) < fnd_date.canonical_to_date(p_scl_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;

          /* Bug4504375 :Contract type Change Date should not be before Date Contract Signed.*/
    elsif fnd_date.canonical_to_date(p_scl_segment13) < fnd_date.canonical_to_date(p_scl_segment14) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','DATE_CONTRACT_SIGNED'));
        hr_utility.raise_error;


   /*
      This check has been removed because of bug 4504312 DATE CONTRACT SIGNED1 ACCEPTS DATES EVEN AFTER THE CONTRACT START DATE
      Hence Date Contract Signed must be before or same as Contract Start Date. ie)(p_scl_segment14)<(p_scl_segment11)is the condition
      to be held correct.Otherwise a note message is to be thrown.Since note messages cannot be thrown from api's there wont be any check for
      Date contract Signed.
      elsif fnd_date.canonical_to_date(p_scl_segment14) < fnd_date.canonical_to_date(p_scl_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','DATE_CONTRACT_SIGNED'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;
   */

    elsif fnd_date.canonical_to_date(p_scl_segment15) < fnd_date.canonical_to_date(p_scl_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;
    elsif fnd_date.canonical_to_date(p_scl_segment16) < fnd_date.canonical_to_date(p_scl_segment15) then
         hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_END_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_DATE'));
        hr_utility.raise_error;
    elsif p_payroll_id is not null  then

         l_oldage_pension_rights:=null;

         open  csr_oldage_taxoffice_check(p_person_id,p_effective_date);
         fetch csr_oldage_taxoffice_check into l_oldage_pension_rights,l_tax_office ;
         close csr_oldage_taxoffice_check;

     /*  NIP is neccessary to attach a payroll only for Polish employees(Both Citizenship and nationality)
         But this is redundant as For Polish Employee these are mandatory
          if l_nip is null then
             hr_utility.set_message(800,'HR_NIP_REQUIRED_PL');
             hr_utility.raise_error;
         end if; */

         if l_oldage_pension_rights is null then
            hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
            hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','OLDAGE_PENSION_RIGHTS'));  --default translate false
            hr_utility.raise_error;
         end if;

         if l_tax_office is null then
            hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
            hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','TAX_OFFICE'));  --default translate false
            hr_utility.raise_error;
         end if;

         -- Bug 9534572
         -- As we do not deliver Oracle Payroll functionality specific to Polish legislation,
         -- hence SII and Tax Calculations do not come into picture for Polish customers.
         -- Hence removing any dependency on SII/Tax Card before attaching payroll
         -- to the assignment
         /*
         --l_one:=0;

         --if p_scl_segment3 in ('CIVIL','F_LUMP','LUMP')  then
            --we cannot have a civil contract with payroll id while creating...
            --this is bcoz .user in no way that we can have a tax or sii record ..as they need assignment id to have sii record...
         --   hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
         --   hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PL_SII_INFO_FLEX'));
         --   hr_utility.raise_error;
         --end if;


         --open csr_check_sii_exists(p_person_id,p_effective_date) ;
         --fetch csr_check_sii_exists into l_one;
         --close csr_check_sii_exists;

         --if l_one <> 1 then
         --   hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
         --   hr_utility.set_message_token(l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PL_SII_INFO_FLEX'));
         --   hr_utility.raise_error;
         --end if;

         --l_one:=0;

        --open csr_check_paye_exists(p_person_id,p_effective_date);
        --fetch csr_check_paye_exists into l_one;
        --close csr_check_paye_exists;

        --if  l_one<> 1 then
        --  hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
        --  hr_utility.set_message_token(l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PL_TAX_INFO_FLEX'));
        --  hr_utility.raise_error;
        --end if;
        */


    end if;    --date checks over

hr_utility.set_location(l_proc,40);
Exception
when others then
hr_utility.set_location(l_proc,50);
hr_utility.raise_error;
end     create_pl_secondary_emp_asg;


---------start of  update_pl_emp_asg-----------

 procedure update_pl_emp_asg
                     (P_EFFECTIVE_DATE               DATE
                     ,P_ASSIGNMENT_ID                NUMBER
                     ,P_ASSIGNMENT_STATUS_TYPE_ID    NUMBER
                     ,P_SEGMENT3                     VARCHAR2
                     ,P_SEGMENT4                     VARCHAR2
                     ,P_SEGMENT5                     VARCHAR2
                     ,P_SEGMENT6                     VARCHAR2
                     ,P_SEGMENT7                     VARCHAR2
                     ,P_SEGMENT8                     VARCHAR2
                     ,P_SEGMENT9                     VARCHAR2
                     ,P_SEGMENT11                    VARCHAR2
                     ,P_SEGMENT12                    VARCHAR2
                     ,P_SEGMENT13                    VARCHAR2
                     ,P_SEGMENT14                    VARCHAR2
                     ,P_SEGMENT15                    VARCHAR2
                     ,P_SEGMENT16                    VARCHAR2
                     ,P_NOTICE_PERIOD                NUMBER
                     ,P_NOTICE_PERIOD_UOM            VARCHAR2
                     )is

cursor csr_get_payroll_emp_cat is
select payroll_id,employment_category
from   per_all_assignments_f
where  assignment_id=P_ASSIGNMENT_ID
and    P_EFFECTIVE_DATE between effective_start_date and effective_end_date;

cursor csr_get_contract_details(r_date date) is
select kyflx.segment3,kyflx.segment4,kyflx.segment6,fnd_date.canonical_to_date(segment13)
from   hr_soft_coding_keyflex kyflx , per_all_assignments_f paaf
where  paaf.assignment_id          = P_ASSIGNMENT_ID
and    paaf.soft_coding_keyflex_id= kyflx.soft_coding_keyflex_id
and    r_date between effective_start_date and effective_end_date;

-- Bug 7041296
cursor csr_effective_start_date is
select min(effective_start_date)
from per_all_assignments_f
where assignment_id=P_ASSIGNMENT_ID;

-- Added for Bug 7510498
-- Modified for Bug 7554037
cursor csr_get_segment_details(r_date date) is
select kyflx.segment3,kyflx.segment4,kyflx.segment5,kyflx.segment11,kyflx.segment12,kyflx.segment13,
       kyflx.segment14,kyflx.segment15,kyflx.segment16
from   hr_soft_coding_keyflex kyflx , per_all_assignments_f paaf
where  paaf.assignment_id          = P_ASSIGNMENT_ID
and    paaf.soft_coding_keyflex_id= kyflx.soft_coding_keyflex_id
and    r_date between effective_start_date and effective_end_date;

-- Added for Bug 7554037
CURSOR csr_get_notice_details is
SELECT NOTICE_PERIOD, NOTICE_PERIOD_UOM
FROM  per_all_assignments_f
WHERE assignment_id=P_ASSIGNMENT_ID
and   P_EFFECTIVE_DATE between effective_start_date and effective_end_date;

l_employment_category    per_all_assignments_f.employment_category%type;
l_proc                   varchar2(35);
l_assgt_type             varchar2(30);
l_prev_assgt_type        varchar2(30);
l_oldage_pension_rights  per_all_people_f.per_information4%TYPE;
l_tax_office             per_all_people_f.per_information6%TYPE;
l_one                    number(1);
l_join_variable          number(10);
l_payroll_id             number(10);
l_contract_category      hr_soft_coding_keyflex.segment3%type;
l_contract_type          hr_soft_coding_keyflex.segment4%type;
l_contract_change_reason hr_soft_coding_keyflex.segment6%type;
l_contract_type_change_date date;
l_person_id              number(10) ;
l_asg_min_start_date     date ;
-- Added for Bug 7510498
l_segment3               hr_soft_coding_keyflex.segment3%type;
l_segment4               hr_soft_coding_keyflex.segment4%type;
l_segment5               hr_soft_coding_keyflex.segment5%type;
l_segment11              hr_soft_coding_keyflex.segment11%type;
l_segment12              hr_soft_coding_keyflex.segment12%type;
l_segment13              hr_soft_coding_keyflex.segment13%type;
l_segment14              hr_soft_coding_keyflex.segment14%type;
l_segment15              hr_soft_coding_keyflex.segment15%type;
l_segment16              hr_soft_coding_keyflex.segment16%type;
l_notice_concat          varchar2(180);
l_notice_period          per_all_assignments_f.notice_period%type;
l_notice_uom             per_all_assignments_f.notice_period_uom%type;
begin
--1)Mandatory argument checks
--2)Conditionally mandatory arguments ...planned valid to date,notice_period,notice_period_date(scl_segment15),notice_period_end_date(scl_segment16)
--3)you cannot correct or update segment3 once enetred
--4)in order to update the contract type(segment4),there must be value for change of contract Reason(segment6)
--  and Contract type change date must be equal to  p_effective_date -1
--5)contract number cannot be longer than 30 characters
--6)Date checks
--7)payroll check ..get it from the table and then do the validation
g_package_name :='PER_PL_ASSIGNMENT.';
l_proc:=g_package_name||'UPDATE_PL_EMP_ASG';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
hr_utility.set_location(l_proc,10);
l_person_id:= get_person_id(p_assignment_id,p_effective_date);

--Added for Bug 7510498
--Modified for Bug 7554037
open csr_get_segment_details(p_effective_date);
fetch csr_get_segment_details into
l_segment3,l_segment4,l_segment5,l_segment11,l_segment12,l_segment13,l_segment14,l_segment15,l_segment16;
close csr_get_segment_details;

/*If the mandatory arguments are not specified in the call, then it will be defaulted
to hr_api.g_varchar2. Added a check that when the mandatory arguments are not specified,
check whether these details are already present for the assignment. If not, raise
error --Added for Bug 7554037*/

IF (p_segment3 is null OR p_segment3 <> hr_api.g_varchar2) then
     l_segment3:=p_segment3;
END if;
IF (p_segment4 is null OR p_segment4 <> hr_api.g_varchar2) then
     l_segment4:=p_segment4;
END if;
IF (p_segment5 is null OR p_segment5 <> hr_api.g_varchar2) then
     l_segment5:=p_segment5;
END if;
IF (p_segment11 is null OR p_segment11 <> hr_api.g_varchar2) then
     l_segment11:=p_segment11;
END if;
if (p_segment12 is null OR p_segment12 <> hr_api.g_varchar2) then
   l_segment12:=p_segment12;
END if;
if (p_segment13 is null OR p_segment13 <> hr_api.g_varchar2) then
   l_segment13:=p_segment13;
END if;
IF (p_segment14 is null OR p_segment14 <> hr_api.g_varchar2) then
     l_segment14:=p_segment14;
END if;
IF (p_segment15 is null OR p_segment15 <> hr_api.g_varchar2) then
     l_segment15:=p_segment15;
END if;
IF (p_segment16 is null OR p_segment16 <> hr_api.g_varchar2) then
     l_segment16:=p_segment16;
END if;


hr_api.mandatory_arg_error  --Contract Category is mandatory
        (p_api_name         => l_proc,
         p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_CATEGORY'),
         p_argument_value   => l_segment3
        );

hr_api.mandatory_arg_error  --Contract Type is Mandatory
         (p_api_name         => l_proc,
          p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE'),
          p_argument_value   => l_segment4
         );

hr_api.mandatory_arg_error --Contract Number is Mandatory
         (p_api_name         => l_proc,
          p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_NUMBER'),
          p_argument_value   => l_segment5
         );

hr_api.mandatory_arg_error --Contract Start Date is mandatory
     (p_api_name         => l_proc,
      p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'),
      p_argument_value   => l_segment11
       );

hr_api.mandatory_arg_error --Date Contract Signed is mandatory
            (p_api_name         => l_proc,
             p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','DATE_CONTRACT_SIGNED'),
             p_argument_value   => l_segment14
             );


hr_utility.set_location(l_proc,20);

     ------Conditionally mandatory---------
    /*
      1)update_emp_asg_criteria will be called first..this is where the payroll id,employment_category will be set
      2)since these values are not available here...we have to query for the changes....
      3) do not use per_asg_shd.g_old_rec.employment_category or payroll_id
    */
     if p_segment3='NORMAL' then
       l_employment_category:=null;
       open  csr_get_payroll_emp_cat;
       fetch csr_get_payroll_emp_cat into l_payroll_id,l_employment_category;
       close csr_get_payroll_emp_cat;
       hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT_CATEGORY'),
            p_argument_value   => l_employment_category
           );
       end if;

       if l_segment3='NORMAL' and l_segment4<>'N01' then
          hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','PLANNED_VALID_TO_DATE'),
            p_argument_value   => l_SEGMENT12
           );
       elsif p_segment12<>hr_api.g_varchar2 then --replaced in 115.11
                                                 --Bug 5386451
             hr_utility.set_message(800,'HR_375869_PLANNED_DATE_INVALID');
             hr_utility.raise_error;
       end if;

       --Added for Bug 7554037
       OPEN csr_get_notice_details;
       FETCH csr_get_notice_details INTO l_notice_period,l_notice_uom;
       CLOSE csr_get_notice_details;

       SELECT decode(p_segment16,hr_api.g_varchar2,l_segment16,p_segment16)||
              decode(p_segment15,hr_api.g_varchar2,l_segment15,p_segment15)||
              decode(p_notice_period,hr_api.g_number,l_notice_period,p_notice_period)
       INTO l_notice_concat FROM dual;

       IF (p_notice_period is null OR p_notice_period <> hr_api.g_number) then
             l_notice_period:=p_notice_period;
       END if;
       IF (p_NOTICE_PERIOD_UOM is null OR p_NOTICE_PERIOD_UOM <> hr_api.g_varchar2) then
             l_notice_uom :=p_NOTICE_PERIOD_UOM;
       END if;

       -----if any of the following 3 has been entered then ..other two become mandatory
       -----Notice Period Date(p_scl_segment15),Notice Period End Date(p_scl_segment16),Notice Period(p_notice_period)
       if l_notice_concat is not null THEN  --Modified for Bug 7554037
              hr_api.mandatory_arg_error
              (p_api_name         => l_proc,
               p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_END_DATE'),
               p_argument_value   => l_segment16
              );

              hr_api.mandatory_arg_error
              (p_api_name         => l_proc,
               p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_DATE'),
               p_argument_value   => l_segment15
              );

              hr_api.mandatory_arg_error
              (p_api_name         => l_proc,
               p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD'),
               p_argument_value   => l_notice_period
              );

         --If notice_period is passed, p_NOTICE_PERIOD_UOM is mandatory
              hr_api.mandatory_arg_error
              (p_api_name         => l_proc,
               p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_UNIT'),
               p_argument_value   => l_notice_uom
              );

          if ( (l_notice_uom  like '_1' and  l_notice_period >1) or
              (l_notice_uom  like '_'  and  l_notice_period =1)) then
               hr_utility.set_message(800,'HR_375856_NOTICE_UNIT_MISMATCH');
               hr_utility.raise_error;
         end if;
       end if;
      -----if p_notice_period is entered and notice_period_uom is null??
      -----taken care by core per_asg_bus3.chk_notice_period_uom

     --Bug 4504375
     -- change of contract reason and contract type change date are mandatory
     -- if any one of them is not null
      if  p_segment6 is not null and p_segment13 is null then
          hr_utility.set_message(800,'HR_375835_ENTER_OTHER_VALUE');
          hr_utility.set_message_token(l_token_name=>'DETAIL1',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CHANGE_OF_CONTRACT_REASON')));
          hr_utility.set_message_token(l_token_name=>'DETAIL2',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE')));

          hr_utility.raise_error;
       elsif p_segment6 is  null and p_segment13 is not  null then
          hr_utility.set_message(800,'HR_375835_ENTER_OTHER_VALUE');
          hr_utility.set_message_token(l_token_name=>'DETAIL1',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE')));

          hr_utility.set_message_token(l_token_name=>'DETAIL2',
                                       l_token_value=>lower(hr_general.decode_lookup('PL_FORM_LABELS','CHANGE_OF_CONTRACT_REASON')));
          hr_utility.raise_error;
        end if;



      --what was the contract category yesterday?
open  csr_get_contract_details(p_effective_date); --Modified for bug 7554037 -No need of checking these details
                                                  --as of effective_date-1 as if it is the assignment_start_date, no rows will be returned and null value is placed in variables
fetch csr_get_contract_details into l_contract_category,l_contract_type,l_contract_change_reason,l_contract_type_change_date;
close csr_get_contract_details;
--no need to check for null ...

--contract category cannot be changed once created
if (l_contract_category <> p_segment3) AND (p_segment3 <> hr_api.g_varchar2) then  --changed for Bug 7510498
    hr_utility.set_message(800,'HR_375868_DONT_CHANGE_CATEGORY');
    hr_utility.raise_error;
end if;

--contract type change allowed only after reason and change date are provided
--p_contract_type cannot be null...no check if user is updating it from null to some contract type
if (l_contract_type <> p_segment4) AND (p_segment4 <> hr_api.g_varchar2) THEN  --changed for Bug 7510498
   if(l_contract_change_reason is null or (p_effective_date-1)<>nvl(l_contract_type_change_date,p_effective_date)) then
     hr_utility.set_message(800,'HR_375867_DISALLOW_TYPE_CHANGE');
     hr_utility.raise_error;
   end if;
end if;

--contract length to be within 30 characters
if length(p_segment5)>30  AND (p_segment5 <> hr_api.g_varchar2) THEN  --changed for Bug 7510498
    hr_utility.set_message(800,'HR_375863_CONTRACT_NUM_LENGTH');
    hr_utility.set_message_token(l_token_name=>'TYPE',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_NUMBER'));
    hr_utility.set_message_token(l_token_name=>'LENGTH',l_token_value=>'30');
    hr_utility.raise_error;
end if;

-----other validations like value set comparison will be taken
----care by core when they validate the flexfields.
-----what we need to check are the dates being entered.

hr_utility.set_location(l_proc,30);

-- Bug 7041296
-- pick minimum start date of assignment
-- and compare contract_start_date with minimum(assignment eff_start_date)
open csr_effective_start_date;
fetch csr_effective_start_date into l_asg_min_start_date;
close csr_effective_start_date;


--hr_utility.trace('Bug 7041296 : p_segment11 :'||p_segment11||'l_asg_min_start_date:'||l_asg_min_start_date);
--Changed for Bug 7510498
 if fnd_date.canonical_to_date(l_segment11) < l_asg_min_start_date THEN --Bug 7041296  p_effective_date then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT_START_DATE'));
        hr_utility.raise_error;

    elsif fnd_date.canonical_to_date(l_segment12) < fnd_date.canonical_to_date(l_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','PLANNED_VALID_TO_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;

    ELSIF fnd_date.canonical_to_date(l_segment13) < fnd_date.canonical_to_date(l_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;

          /* Bug4504375 :Contract type Change Date should not be before Date Contract Signed.*/
    elsif fnd_date.canonical_to_date(l_segment13) < fnd_date.canonical_to_date(l_segment14) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_TYPE_CHANGE_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','DATE_CONTRACT_SIGNED'));
        hr_utility.raise_error;

   /*
      This check has been removed because of bug 4504312 DATE CONTRACT SIGNE D ACCEPTS DATES EVEN AFTER THE CONTRACT START DATE
      Hence Date Contract Signed must be before or same as Contract Start Date. ie)(p_scl_segment14)<(p_scl_segment11)is the condition
      to be held correct.Otherwise a note message is to be thrown.Since note messages cannot be thrown from api's there wont be any check for
      Date contract Signed.
    elsif fnd_date.canonical_to_date(p_segment14) < fnd_date.canonical_to_date(p_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','DATE_CONTRACT_SIGNED'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;
  */

    elsif fnd_date.canonical_to_date(l_segment15) < fnd_date.canonical_to_date(l_segment11) then
        hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_START_DATE'));
        hr_utility.raise_error;
    elsif fnd_date.canonical_to_date(l_segment16) < fnd_date.canonical_to_date(l_segment15) then
         hr_utility.set_message(800,'HR_375853_DATE1_AFTER_DATE2');
        hr_utility.set_message_token(l_token_name=>'DATE1',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_END_DATE'));
        hr_utility.set_message_token(l_token_name=>'DATE2',l_token_value=> hr_general.decode_lookup('PL_FORM_LABELS','NOTICE_PERIOD_DATE'));
        hr_utility.raise_error;
 else

--if status has been changed ..then create sii/paye record from existing tax record if they already exist
    open  csr_assgt_type(p_assignment_id,p_effective_date-1);
    fetch csr_assgt_type into l_prev_assgt_type;
    close csr_assgt_type;

    open  csr_assgt_type(p_assignment_id,p_effective_date);
    fetch csr_assgt_type into l_assgt_type;
    close csr_assgt_type;

    if (p_segment3='NORMAL' and l_assgt_type='TERM_ASSIGN' and l_prev_assgt_type<>'TERM_ASSIGN') then
    --check if record already exists with contract category as term_normal?

        declare --declare 1
        l_sii_already                    char(1):='0';
        l_object_version_number         pay_pl_sii_details_f.object_version_number%type;
        l_sii_details_id                pay_pl_sii_details_f.sii_details_id%type;
        l_effective_start_date          pay_pl_sii_details_f.effective_start_date%type;
        l_effective_end_date            pay_pl_sii_details_f.effective_end_date%type;
        l_effective_date_warning        boolean;
        l_person_id                     number(10);
        l_business_group_id             number(10);

       cursor csr_get_person_bus_id is
        select person_id,business_group_id
         from  per_all_assignments_f
        where  assignment_id=p_assignment_id
        and    p_effective_date between effective_start_date and effective_end_date;

       cursor csr_sii_already_exists is
         select '1' from pay_pl_sii_details_f
         where contract_category='TERM_NORMAL'
          and  p_effective_date between effective_start_date and effective_end_date
          and  per_or_asg_id=p_assignment_id;

       cursor csr_sii_details(r_person_id number) is
         select emp_social_security_info,old_age_contribution,pension_contribution,sickness_contribution,
               work_injury_contribution,labor_contribution,health_contribution,unemployment_contribution,
                  old_age_cont_end_reason,pension_cont_end_reason,sickness_cont_end_reason,
               work_injury_cont_end_reason,labor_fund_cont_end_reason,health_cont_end_reason,unemployment_cont_end_reason
        from   pay_pl_sii_details_f
        where  per_or_asg_id=r_person_id
          and  contract_category='NORMAL'
          and  p_effective_date between effective_start_date and effective_end_date;
       l_csr_sii_details csr_sii_details%rowtype;

       begin

         open csr_sii_already_exists ;
         fetch csr_sii_already_exists into l_sii_already;
         close csr_sii_already_exists;
         if l_sii_already='1' then
          null;
         else
             open  csr_get_person_bus_id ;
             fetch csr_get_person_bus_id  into l_person_id,l_business_group_id;
             close csr_get_person_bus_id ;

             open csr_sii_details(l_person_id);
               fetch csr_sii_details into  l_csr_sii_details;
              if csr_sii_details%FOUND then
                   pay_pl_sii_api.create_pl_sii_details
                      (p_validate                      =>false
                      ,p_effective_date                =>p_effective_date
                      ,p_contract_category             =>'TERM_NORMAL'
                      ,p_per_or_asg_id                 =>p_assignment_id
                      ,p_business_group_id             =>l_business_group_id
                      ,p_emp_social_security_info      =>l_csr_sii_details.emp_social_security_info
                      ,p_old_age_contribution          =>l_csr_sii_details.old_age_contribution
                      ,p_pension_contribution          =>l_csr_sii_details.pension_contribution
                      ,p_sickness_contribution         =>l_csr_sii_details.sickness_contribution
                      ,p_work_injury_contribution      =>l_csr_sii_details.work_injury_contribution
                      ,p_labor_contribution            =>l_csr_sii_details.labor_contribution
                      ,p_health_contribution           =>l_csr_sii_details.health_contribution
                      ,p_unemployment_contribution     =>l_csr_sii_details.unemployment_contribution
                      ,p_old_age_cont_end_reason       =>l_csr_sii_details.old_age_cont_end_reason
                      ,p_pension_cont_end_reason       =>l_csr_sii_details.pension_cont_end_reason
                      ,p_sickness_cont_end_reason      =>l_csr_sii_details.sickness_cont_end_reason
                      ,p_work_injury_cont_end_reason   =>l_csr_sii_details.work_injury_cont_end_reason
                      ,p_labor_fund_cont_end_reason    =>l_csr_sii_details.labor_fund_cont_end_reason
                      ,p_health_cont_end_reason        =>l_csr_sii_details.health_cont_end_reason
                      ,p_unemployment_cont_end_reason  =>l_csr_sii_details.unemployment_cont_end_reason
                      ,p_sii_details_id                =>l_sii_details_id
                      ,p_object_version_number         =>l_object_version_number
                      ,p_effective_start_date          =>l_effective_start_date
                      ,p_effective_end_date            =>l_effective_end_date
                      ,p_effective_date_warning        =>l_effective_date_warning);
                end if;--csr_sii_details found
             close csr_sii_details;
           end if; --is sii_alreasdy=1?
           end ; --of declare1


        declare  --declare2
         l_paye_already                    char(1):='0';
         l_object_version_number         pay_pl_paye_details_f.object_version_number%type;
         l_paye_details_id               pay_pl_paye_details_f.paye_details_id%type;
         l_effective_start_date          pay_pl_paye_details_f.effective_start_date%type;
         l_effective_end_date            pay_pl_paye_details_f.effective_end_date%type;
         l_effective_date_warning        boolean;
         l_person_id                     number(10);
         l_business_group_id             number(10);


        cursor csr_get_person_bus_id is
          select person_id,business_group_id
          from   per_all_assignments_f
          where  assignment_id=p_assignment_id
           and   p_effective_date between effective_start_date and effective_end_date;

        cursor csr_paye_already_exists is
         select '1' from pay_pl_paye_details_f
         where contract_category='TERM_NORMAL'
          and  p_effective_date between effective_start_date and effective_end_date
          and  per_or_asg_id=p_assignment_id;

        cursor csr_paye_details(r_person_id number) is
          select  tax_reduction,tax_calc_with_spouse_child,income_reduction,income_reduction_amount,rate_of_tax
           from   pay_pl_paye_details_f
           where  per_or_asg_id=r_person_id
            and   contract_category='NORMAL'
            and   p_effective_date between effective_start_date and effective_end_date;
        l_csr_paye_details csr_paye_details%rowtype;

         begin

           open csr_paye_already_exists;
           fetch csr_paye_already_exists into l_paye_already;
           close csr_paye_already_exists;

         if l_paye_already='1' then
                null;
          else
               open  csr_get_person_bus_id ;
             fetch csr_get_person_bus_id  into l_person_id,l_business_group_id;
             close csr_get_person_bus_id ;

                open csr_paye_details(l_person_id);
                 fetch csr_paye_details into l_csr_paye_details;
            if csr_paye_details%FOUND then
              pay_pl_paye_api.create_pl_paye_details
             (p_validate                      =>     false
             ,p_effective_date                =>     p_effective_date
             ,p_contract_category             =>     'TERM_NORMAL'
             ,p_per_or_asg_id                 =>     p_assignment_id
             ,p_business_group_id             =>     l_business_group_id
             ,p_tax_reduction                 =>     l_csr_paye_details.tax_reduction
             ,p_tax_calc_with_spouse_child    =>     l_csr_paye_details.tax_calc_with_spouse_child
             ,p_income_reduction              =>     l_csr_paye_details.income_reduction
             ,p_income_reduction_amount       =>     l_csr_paye_details.income_reduction_amount
             ,p_rate_of_tax                   =>     l_csr_paye_details.rate_of_tax
             ,p_paye_details_id               =>     l_paye_details_id
             ,p_object_version_number         =>     l_object_version_number
             ,p_effective_start_date          =>     l_effective_start_date
             ,p_effective_end_date            =>     l_effective_end_date
             ,p_effective_date_warning        =>     l_effective_date_warning
            );
           end if;--csr_paye_details found
         close csr_paye_details;
       end if; --if l_paye_already=1?
      end ; --declare2

 end if;--(p_segment3='NORMAL' and l_assgt_type='TERM_ASSIGN' and l_prev_assgt_type<>'TERM_ASSIGN')

   if l_payroll_id is not null then
      open csr_oldage_taxoffice_check (l_person_id,p_effective_date);
      fetch csr_oldage_taxoffice_check into l_oldage_pension_rights,l_tax_office;
      close csr_oldage_taxoffice_check;

    /*   NIP is neccessary to attach a payroll only for Polish employees(Both Citizenship and nationality)
         But this is redundant as For Polish Employee these are mandatory
      if l_nip is null then
          hr_utility.set_message(800,'HR_NIP_REQUIRED_PL');
          hr_utility.raise_error;
       end if;
     */

      if l_oldage_pension_rights is null then
         hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
         hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','OLDAGE_PENSION_RIGHTS'));  --default translate false
         hr_utility.raise_error;
      end if;

      if l_tax_office is null then
            hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
            hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','TAX_OFFICE'));  --default translate false
            hr_utility.raise_error;
      end if;


      open  csr_assgt_type(p_assignment_id,p_effective_date) ;
      fetch csr_assgt_type into l_assgt_type;
      close csr_assgt_type ;


     -- Bug 9534572
     -- As we do not deliver Oracle Payroll functionality specific to Polish legislation,
     -- hence SII and Tax Calculations do not come into picture for Polish customers.
     -- Hence removing any dependency on SII/Tax Card before attaching payroll
     -- to the assignment
     /*
     --if p_segment3='NORMAL' then  --and l_assgt_type in ('ACTIVE_ASSIGN','SUSP_ASSIGN')) then
     --    l_join_variable:=get_person_id(p_assignment_id,p_effective_date);
     --else
     --    l_join_variable:=p_assignment_id;
     --end if;

     --l_one:=0;

     --open  csr_check_sii_exists(l_join_variable,p_effective_date);
     --fetch csr_check_sii_exists into l_one;
     --close csr_check_sii_exists;

     --if l_one <> 1 then
     --hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
     --hr_utility.set_message_token(l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PL_SII_INFO_FLEX'));
     --hr_utility.raise_error;
     --end if;

     --l_one:=0;
     --open csr_check_paye_exists(l_join_variable,p_effective_date);
     --fetch csr_check_paye_exists into l_one;
     --close csr_check_paye_exists;

     --if l_one <> 1 then
     --hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
     --hr_utility.set_message_token(l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PL_TAX_INFO_FLEX'));
     --hr_utility.raise_error;
     --end if;
     */

  end if;--is payroll id null?
end if;--end of date checks
hr_utility.set_location('Leaving '||l_proc,30);
exception
when others then
hr_utility.set_location(l_proc,99);
hr_utility.raise_error;
end    ;
----end of update_pl_emp_asg----

----Start of Update_pl_emp_asg_criteria----
procedure update_pl_emp_asg_criteria
(P_EFFECTIVE_DATE in DATE
,P_ASSIGNMENT_ID in NUMBER
,P_PAYROLL_ID in NUMBER
,P_EMPLOYMENT_CATEGORY in VARCHAR2) is

cursor  csr_get_contract_cat is
    select segment3
    from  hr_soft_coding_keyflex keyflx,per_all_assignments_f paaf
    where paaf.soft_coding_keyflex_id=keyflx.soft_coding_keyflex_id   --Changed the join condition for Bug 7425845
    and paaf.effective_start_date between effective_start_date and effective_end_date
    and assignment_id=p_assignment_id;

--Added for bug 7554037
cursor csr_get_payroll_emp_cat is
select employment_category
from   per_all_assignments_f
where  assignment_id=P_ASSIGNMENT_ID
and    P_EFFECTIVE_DATE between effective_start_date and effective_end_date;

l_contract_category hr_soft_coding_keyflex.segment3%type;
l_join_variable     number(10);
l_assgt_type        per_assignment_status_types.per_system_status%type;
l_oldage_pension_rights  per_all_people_f.per_information4%TYPE;
l_tax_office        per_all_people_f.per_information6%TYPE;
l_employment_category  per_all_assignments_f.employment_category%TYPE;
l_one               number(1);
l_person_id         number(10);
l_proc              varchar2(44);

Begin
g_package_name :='PER_PL_ASSIGNMENT.';
l_proc:=g_package_name||'UPDATE_PL_EMP_ASG_CRITERIA';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
hr_utility.set_location(l_proc,10);
l_person_id:=get_person_id(P_ASSIGNMENT_ID,p_effective_date);
    open  csr_get_contract_cat ;
    fetch csr_get_contract_cat into l_contract_category;
    close csr_get_contract_cat;

    OPEN csr_get_payroll_emp_cat;
    FETCH csr_get_payroll_emp_cat INTO l_employment_category;
    CLOSE csr_get_payroll_emp_cat;

   if l_contract_category='NORMAL' then
      hr_utility.set_location(l_proc,20);
      IF (p_employment_category IS NULL OR p_employment_category <> hr_api.g_varchar2)
      then
          hr_api.mandatory_arg_error
          (p_api_name         => l_proc,
          p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT_CATEGORY'),
          p_argument_value   => p_employment_category
          );
      else
          hr_api.mandatory_arg_error
          (p_api_name         => l_proc,
          p_argument         => hr_general.decode_lookup('PL_FORM_LABELS','ASSIGNMENT_CATEGORY'),
          p_argument_value   => l_employment_category
          );
      END if;
    end if;


--if p_payroll_id is not null then  Replace null with hr_api.g_number in 115.10
--Bug 5386451
if p_payroll_id <> hr_api.g_number then
hr_utility.set_location(l_proc,30);
     open  csr_oldage_taxoffice_check(l_person_id,p_effective_date);
     fetch csr_oldage_taxoffice_check into l_oldage_pension_rights,l_tax_office ;
     close csr_oldage_taxoffice_check;

        /*  NIP is neccessary to attach a payroll only for Polish employees(Both Citizenship and nationality)
         But this is redundant as For Polish Employee these are mandatory  if l_nip is null then
          hr_utility.set_message(800,'HR_NIP_REQUIRED_PL');
          hr_utility.raise_error;
     end if;*/

      if l_oldage_pension_rights is null then
         hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
         hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','OLDAGE_PENSION_RIGHTS'));  --default translate false
         hr_utility.raise_error;
      end if;

    if l_tax_office is null then
            hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
            hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','TAX_OFFICE'));  --default translate false
            hr_utility.raise_error;
      end if;


     -- Bug 9534572
     -- As we do not deliver Oracle Payroll functionality specific to Polish legislation,
     -- hence SII and Tax Calculations do not come into picture for Polish customers.
     -- Hence removing any dependency on SII/Tax Card before attaching payroll
     -- to the assignment
     /*
     -- open csr_assgt_type(p_assignment_id,p_effective_date);
     -- fetch csr_assgt_type into l_assgt_type;
     -- close csr_assgt_type;

     --check if there sii and tax record...if not error out
     --open  csr_get_contract_cat;
     --fetch csr_get_contract_cat into l_contract_category;
     --close csr_get_contract_cat;

     --if l_contract_category is null then
       --hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
       --hr_utility.set_message_token (l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','CONTRACT_CATEGORY'));  --Changed to CONTRACT_CATEGORY for bug 7425845
       --hr_utility.raise_error;
    --elsif l_contract_category ='NORMAL'  then -- and l_assgt_type in ('ACTIVE_ASSIGN' ,'SUSP_ASSIGN') then
      --l_join_variable:=l_person_id;
    --else
      --l_join_variable:=p_assignment_id;
    --end if;


    --l_one:=0;

    --open  csr_check_sii_exists(l_join_variable,p_effective_date);
    --fetch csr_check_sii_exists into l_one;
    --close csr_check_sii_exists;

    --if l_one <> 1 then
    --  hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
    --  hr_utility.set_message_token(l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PL_SII_INFO_FLEX'));
    --  hr_utility.raise_error;
    --end if;

    --l_one:=0;
    --open csr_check_paye_exists(l_join_variable,p_effective_date);
    --fetch csr_check_paye_exists into l_one;
    --close csr_check_paye_exists;

    --if l_one <> 1 then
    --  hr_utility.set_message(800,'HR_375855_DONOT_ATTACH_PAYROLL');
    --  hr_utility.set_message_token(l_token_name=>'TOKEN',l_token_value=>hr_general.decode_lookup('PL_FORM_LABELS','PL_TAX_INFO_FLEX'));
    --  hr_utility.raise_error;
    --end if;
    */

end if; --payroll id is null?
hr_utility.set_location(l_proc,40);
Exception
when others then
hr_utility.set_location(l_proc,50);
hr_utility.raise_error;
end;

PROCEDURE CREATE_PL_SECONDARY_EMP_ASG_A
            (P_ASSIGNMENT_ID     in number,
             P_EFFECTIVE_DATE    in date,
             P_SCL_SEGMENT3      in varchar2) is

cursor csr_business_group is
  select business_group_id
    from per_all_assignments_f
   where assignment_id = p_assignment_id;

l_business_group_id  per_all_assignments_f.business_group_id%TYPE;

l_object_version_number     pay_pl_paye_details_f.object_version_number%type;
l_paye_details_id                   pay_pl_paye_details_f.paye_details_id%type;
l_effective_start_date      pay_pl_paye_details_f.effective_start_date%type;
l_effective_end_date        pay_pl_paye_details_f.effective_end_date%type;
l_effective_date_warning        boolean;
l_proc                      varchar2(30);

BEGIN
l_proc:='CREATE_PL_SECONDARY_EMP_ASG_A';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;

 if p_scl_segment3 = 'LUMP' then

   open csr_business_group;
    fetch csr_business_group into l_business_group_id;
   close csr_business_group;

   pay_pl_paye_api.create_pl_paye_details
            (p_effective_date              => p_effective_date
            ,p_contract_category           => p_scl_segment3
            ,p_per_or_asg_id               => p_assignment_id
            ,p_business_group_id           => l_business_group_id
            ,p_tax_reduction               => null
            ,p_tax_calc_with_spouse_child  => null
            ,p_income_reduction            => null
            ,p_rate_of_tax                 => null
            ,p_paye_details_id             => l_paye_details_id
            ,p_object_version_number       => l_object_version_number
            ,p_effective_start_date        => l_effective_start_date
            ,p_effective_end_date          => l_effective_end_date
            ,p_effective_date_warning      => l_effective_date_warning);

 end if;

END CREATE_PL_SECONDARY_EMP_ASG_A;


PROCEDURE UPDATE_PL_EMP_ASG_A
           (P_EFFECTIVE_DATE     in date,
            P_SEGMENT3           in varchar2,
            P_ASSIGNMENT_ID      in number) is


cursor csr_business_group is
  select business_group_id
    from per_all_assignments_f
   where assignment_id = p_assignment_id;

cursor csr_segment3 is
  select soft.segment3
    from hr_soft_coding_keyflex soft, per_all_assignments_f paaf
   where paaf.soft_coding_keyflex_id = soft.soft_coding_keyflex_id
     and paaf.assignment_id = p_assignment_id
     and p_effective_date between paaf.effective_start_date and paaf.effective_end_date;

l_object_version_number     pay_pl_paye_details_f.object_version_number%type;
l_paye_details_id                   pay_pl_paye_details_f.paye_details_id%type;
l_effective_start_date      pay_pl_paye_details_f.effective_start_date%type;
l_effective_end_date        pay_pl_paye_details_f.effective_end_date%type;
l_effective_date_warning    boolean;
l_record_exists             varchar2(1);
l_business_group_id         pay_pl_paye_details_f.business_group_id%TYPE;
l_segment3                  hr_soft_coding_keyflex.segment3%TYPE;
l_proc                      varchar2(19);
cursor csr_paye_exists is
  select '1'
    from pay_pl_paye_details_f
   where per_or_asg_id = p_assignment_id
     and contract_category = l_segment3;

BEGIN
l_proc:='UPDATE_PL_EMP_ASG_A';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;

l_record_exists := '0';
l_segment3 := p_segment3;

  if p_segment3 = hr_api.g_varchar2 then
   open csr_segment3;
    fetch csr_segment3 into l_segment3;
   close csr_segment3;
  end if;

  if l_segment3 = 'LUMP' then

/* Check if a Tax record already exists for this assignment. If not we create one */
    open csr_paye_exists;
     fetch csr_paye_exists into l_record_exists;
    close csr_paye_exists;

    if l_record_exists <> '1' then

      open csr_business_group;
       fetch csr_business_group into l_business_group_id;
      close csr_business_group;

      pay_pl_paye_api.create_pl_paye_details
             (p_effective_date              => p_effective_date
             ,p_contract_category           => l_segment3
             ,p_per_or_asg_id               => p_assignment_id
             ,p_business_group_id           => l_business_group_id
             ,p_tax_reduction               => null
             ,p_tax_calc_with_spouse_child  => null
             ,p_income_reduction            => null
             ,p_rate_of_tax                 => null
             ,p_paye_details_id             => l_paye_details_id
             ,p_object_version_number       => l_object_version_number
             ,p_effective_start_date        => l_effective_start_date
             ,p_effective_end_date          => l_effective_end_date
             ,p_effective_date_warning      => l_effective_date_warning);

   end if;

  end if;

END UPDATE_PL_EMP_ASG_A;

end per_pl_assignment;

/
