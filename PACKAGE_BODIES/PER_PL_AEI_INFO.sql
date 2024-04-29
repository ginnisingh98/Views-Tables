--------------------------------------------------------
--  DDL for Package Body PER_PL_AEI_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_AEI_INFO" AS
/* $Header: peplaeip.pkb 120.3 2006/09/13 10:19:05 mseshadr noship $ */


g_package varchar2(16):='PER_PL_AEI_INFO.';

cursor csr_assgt_start_date( R_ASSIGNMENT_ID in number)is
select min(effective_start_date),max(effective_end_date) from per_all_assignments_f where ASSIGNMENT_ID=R_ASSIGNMENT_ID;


-- private procedure to validate data
-- entered during creation of payment conditions.
PROCEDURE  CREATE_PL_PAYMENT_CONDITIONS(
            P_ASSIGNMENT_ID     in    NUMBER ,
            P_AEI_INFORMATION1  in  varchar2 ,
            P_AEI_INFORMATION2  in  varchar2 ,
            P_AEI_INFORMATION3  in  varchar2 ,
            P_AEI_INFORMATION4  in  varchar2 ,
            P_AEI_INFORMATION5  in  varchar2 ,
            P_AEI_INFORMATION6  in  varchar2 ,
            P_AEI_INFORMATION7  in  varchar2 )

      as

l_end_of_time               date;
l_proc                      varchar2(44);--16+28
l_date_from                 date;--p_aei_information1
l_date_to                   date;--p_aei_information2
l_assignment_start_date     date;
l_assignment_end_date       date;


cursor csr_payment_condition_ins is
   select AEI_INFORMATION1,AEI_INFORMATION2,AEI_INFORMATION3
    from   per_assignment_extra_info
    where  information_type='PL_PAYMENT_CONDITIONS'
    and    ASSIGNMENT_ID=p_assignment_id
    and    aei_information_category='PL_PAYMENT_CONDITIONS'
    and    AEI_INFORMATION3=p_AEI_INFORMATION3
    and   (
          l_date_from between fnd_date.canonical_to_date(aei_information1)
                      and nvl(fnd_date.canonical_to_date(aei_information2),l_end_of_time)
          or nvl(l_date_to,l_end_of_time) between fnd_date.canonical_to_date(aei_information1)
                                          and nvl(fnd_date.canonical_to_date(aei_information2),l_end_of_time)
          or fnd_date.canonical_to_date(aei_information1)
                                        between l_date_from
                              and nvl(l_date_to,l_end_of_time)
           );
l_payment_cond_row csr_payment_condition_ins%rowtype;

BEGIN
l_proc:=g_package||'CREATE_PL_PAYMENT_CONDITIONS';
hr_utility.set_location(l_proc,10);
l_date_from   :=fnd_date.canonical_to_date(p_AEI_INFORMATION1);
l_date_to     :=fnd_date.canonical_to_date(p_AEI_INFORMATION2);
l_end_of_time :=hr_general.end_of_time;

  if (l_date_from >l_date_to ) then
     hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
     hr_utility.raise_error;
   end if; --date check
    --Message: You entered a start date later than the end date.
    --         Please enter a start date earlier than or the same as the end date.

  --Make sure that start date is after Assignemnt start date
    open  csr_assgt_start_date(P_ASSIGNMENT_ID);
    fetch csr_assgt_start_date into l_assignment_start_date,l_assignment_end_date;
    close csr_assgt_start_date;

  if (l_date_from < l_assignment_start_date) or   nvl(l_date_to,l_end_of_time)>l_assignment_end_date then
        hr_utility.set_message(800,'HR_375886_PAYMENT_COND_DATES');
        hr_utility.raise_error;
  end if;

   --ensure that for this information_type(PL_PAYMENT_CONDITIONS),assignemnt_id and type of salary(p_aei_information3)
   --there isnt another record having same type of salary with overlapping dates

   open  csr_payment_condition_ins;
   fetch csr_payment_condition_ins into l_payment_cond_row;
         if csr_payment_condition_ins%found then
            close csr_payment_condition_ins;
            if l_payment_cond_row.aei_information2 is not null then
                --there exists an end date for the record...display both start and end dates
                hr_utility.set_message(800,'HR_375854_OTHER_EIT_OVERLAP');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_TYPE_OF_SALARY',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_payment_cond_row.aei_information1)));
                hr_utility.set_message_token('ENDDATE',fnd_date.date_to_displaydate(nvl(fnd_date.canonical_to_date(l_payment_cond_row.aei_information2),l_end_of_time)));
                hr_utility.raise_error;
            else
                --there doesnt exist a end date for this record...hence display only the start date
                --new message being used as we cannot display 31-dec-4712 to user---
                hr_utility.set_message(800,'HR_375870_OTHER_EIT_EXISTS');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_TYPE_OF_SALARY',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_payment_cond_row.aei_information1)));
                hr_utility.raise_error;
            end if; --aei information2 is not null
           end if; --csr_payment_condition_ins found
   close csr_payment_condition_ins;

   hr_utility.set_location('Leaving'||l_proc,20);
END;

procedure UPDATE_PL_PAYMENT_CONDITIONS(

 P_ASSIGNMENT_EXTRA_INFO_ID   in   NUMBER,
 P_AEI_INFORMATION1           in   varchar2 ,
 P_AEI_INFORMATION2           in   varchar2 ,
 P_AEI_INFORMATION3           in   varchar2 ,
 P_AEI_INFORMATION4           in   varchar2 ,
 P_AEI_INFORMATION5           in   varchar2 ,
 P_AEI_INFORMATION6           in   varchar2 ,
 P_AEI_INFORMATION7           in   varchar2
 )
 as

l_end_of_time               date;
l_proc                      varchar2(44);--16+28
l_date_from                 date;--p_aei_information1
l_date_to                   date;--p_aei_information2
l_assignment_start_date     date;
l_assignment_end_date       date;
l_assignment_id  number;

 cursor csr_assignment_id is
 select assignment_id
 from  per_assignment_extra_info
 where information_type='PL_PAYMENT_CONDITIONS'
 and   ASSIGNMENT_EXTRA_INFO_ID=P_ASSIGNMENT_EXTRA_INFO_ID;

 cursor csr_payment_condition_upd(r_assignment_id in number) is
 select AEI_INFORMATION1,AEI_INFORMATION2,AEI_INFORMATION3
 from   per_assignment_extra_info
 where  information_type='PL_PAYMENT_CONDITIONS'
 and    per_assignment_extra_info.ASSIGNMENT_ID=r_assignment_id
 and    aei_information_category='PL_PAYMENT_CONDITIONS'
 and    AEI_INFORMATION3=p_AEI_INFORMATION3
 and    ASSIGNMENT_EXTRA_INFO_ID<>P_ASSIGNMENT_EXTRA_INFO_ID
 and  (
      l_date_from                    between fnd_date.canonical_to_date(aei_information1)
                                         and nvl(fnd_date.canonical_to_date(aei_information2),l_end_of_time)
    or nvl(l_date_to ,l_end_of_time) between fnd_date.canonical_to_date(aei_information1)
                                         and nvl(fnd_date.canonical_to_date(aei_information2),l_end_of_time)
    or fnd_date.canonical_to_date(aei_information1)
                                     between l_date_from
                                         and nvl(l_date_to ,l_end_of_time)
       );
 l_payment_cond_row csr_payment_condition_upd%rowtype;

 Begin

  l_proc:= g_package||'UPDATE_PL_PAYMENT_CONITIONS';
  hr_utility.set_location('Entering '||l_proc,10);
  l_date_from   :=fnd_date.canonical_to_date(p_AEI_INFORMATION1);
  l_date_to     :=fnd_date.canonical_to_date(p_AEI_INFORMATION2);
  l_end_of_time :=hr_general.end_of_time;

  if (l_date_from >l_date_to ) then
     hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
     hr_utility.raise_error;
   end if; --date check
  --Message: You entered a start date later than the end date.
  --         Please enter a start date earlier than or the same as the end date.

    open csr_assignment_id;
    fetch csr_assignment_id into l_assignment_id;
    close  csr_assignment_id;

   --Make sure that start date is after Assignemnt start date
    open  csr_assgt_start_date(l_ASSIGNMENT_ID);
    fetch csr_assgt_start_date into l_assignment_start_date,l_assignment_end_date;
    close csr_assgt_start_date;

    if (l_date_from < l_assignment_start_date ) or nvl(l_date_to,l_end_of_time)>l_assignment_end_date then
        hr_utility.set_message(800,'HR_375886_PAYMENT_COND_DATES');
        hr_utility.raise_error;
    end if;


   open  csr_payment_condition_upd(l_assignment_id);
   fetch csr_payment_condition_upd into l_payment_cond_row;
         if csr_payment_condition_upd%found then
            close csr_payment_condition_upd;
            if l_payment_cond_row.aei_information2 is not null then
                --there exists an end date for the record...display both start and end dates
                hr_utility.set_message(800,'HR_375854_OTHER_EIT_OVERLAP');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_TYPE_OF_SALARY',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_payment_cond_row.aei_information1)));
                hr_utility.set_message_token('ENDDATE',fnd_date.date_to_displaydate(nvl(fnd_date.canonical_to_date(l_payment_cond_row.aei_information2),l_end_of_time)));
                hr_utility.raise_error;
            else
                --there doesnt exist a end date for this record...hence display only the start date
                --new message being used as we cannot display 31-dec-4712 to user---
                hr_utility.set_message(800,'HR_375870_OTHER_EIT_EXISTS');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_TYPE_OF_SALARY',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_payment_cond_row.aei_information1)));
                hr_utility.raise_error;
            end if; --aei information2 is not null
         end if;--csr_payment_condition_upd found
   close csr_payment_condition_upd;

hr_utility.set_location('Leaving'||l_proc,20);

Exception
When others then
hr_utility.raise_error;

END UPDATE_PL_PAYMENT_CONDITIONS; --end procedure




procedure CREATE_PL_ASSGT_EXTRA_INFO(
 P_ASSIGNMENT_ID            in  NUMBER  ,
 p_information_type         in  varchar2,
 p_aei_information_category in  varchar2,
 P_AEI_INFORMATION1         in  varchar2 ,
 P_AEI_INFORMATION2         in  varchar2 ,
 P_AEI_INFORMATION3         in  varchar2 ,
 P_AEI_INFORMATION4         in  varchar2 ,
 P_AEI_INFORMATION5         in  varchar2 ,
 P_AEI_INFORMATION6         in  varchar2 ,
 P_AEI_INFORMATION7         in  varchar2
                                     )  as


 cursor csr_work_condition_date_ins is
   select AEI_INFORMATION1,AEI_INFORMATION2,AEI_INFORMATION3
    from   per_assignment_extra_info
    where  information_type='PL_OTHER_WORK_CONDITIONS'
    and    ASSIGNMENT_ID=p_assignment_id
    and    aei_information_category=p_aei_information_category
    and    AEI_INFORMATION3=p_AEI_INFORMATION3
    and   (
          fnd_date.canonical_to_date(p_aei_information1)
                          between fnd_date.canonical_to_date(aei_information1)
                              and nvl(fnd_date.canonical_to_date(aei_information2),hr_general.end_of_time)
          or nvl(fnd_date.canonical_to_date(p_aei_information2),hr_general.end_of_time)
                          between fnd_date.canonical_to_date(aei_information1)
                              and nvl(fnd_date.canonical_to_date(aei_information2),hr_general.end_of_time)
          or fnd_date.canonical_to_date(  aei_information1)
                          between fnd_date.canonical_to_date(p_aei_information1)
                              and nvl(fnd_date.canonical_to_date(p_aei_information2),hr_general.end_of_time)
          or nvl(fnd_date.canonical_to_date(aei_information2),hr_general.end_of_time)
                          between fnd_date.canonical_to_date(p_aei_information1)
                              and fnd_date.canonical_to_date(p_aei_information2)
           );
 l_work_cond_row csr_work_condition_date_ins%rowtype;
 l_assignment_start_date date;
 l_assignment_end_date date;
 l_proc varchar2(26);

 Begin

/*Create new private procedure for each of the
  newly added Assignmenmt EIT,pass on the reqd
  parameters to the private procedure,and perform
  necessary validations there
*/

 l_proc:='CREATE_PL_ASSGT_EXTRA_INFO';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
 hr_utility.set_location('Entering '||g_package||l_proc,10);

  if p_information_type='PL_OTHER_WORK_CONDITIONS' then
  --ensure  start date is less than end date
  --HR_ORG_START_DATE_PL already contains an apt message.so using it.
   if (fnd_date.canonical_to_date(p_AEI_INFORMATION1)>fnd_date.canonical_to_date(p_AEI_INFORMATION2)) then
     hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
     hr_utility.raise_error;
   end if; --date check

 hr_utility.set_location(g_package||l_proc,20);
--Make sure that start date is after Assignemnt start date
  open  csr_assgt_start_date(P_ASSIGNMENT_ID);
  fetch csr_assgt_start_date into l_assignment_start_date,l_assignment_end_date;
  close csr_assgt_start_date;

 hr_utility.set_location(g_package||l_proc,30);

    if (fnd_date.canonical_to_date(p_aei_information1)<l_assignment_start_date) or
       nvl(fnd_date.canonical_to_date(p_aei_information2),hr_general.end_of_time)>l_assignment_end_date then
        hr_utility.set_message(800,'HR_375865_ASSGT_START_END_DATE');
        hr_utility.raise_error;
    end if;


 hr_utility.set_location(g_package||l_proc,40);

   --ensure that for this information_type,assignemnt_id and Kind of Work(p_aei_information3),
   --there isnt another record having same Kind of Work
   --with overlapping dates

   open  csr_work_condition_date_ins;
   fetch csr_work_condition_date_ins into l_work_cond_row;
         if csr_work_condition_date_ins%found then
            close csr_work_condition_date_ins;
            if l_work_cond_row.aei_information2 is not null then
                --there exists an end date for the record...display both start and end dates
                hr_utility.set_message(800,'HR_375854_OTHER_EIT_OVERLAP');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_OTHER_WORK_CONDS',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_work_cond_row.aei_information1)));
                hr_utility.set_message_token('ENDDATE',fnd_date.date_to_displaydate(nvl(fnd_date.canonical_to_date(l_work_cond_row.aei_information2),hr_general.end_of_time)));
                hr_utility.raise_error;
            else
                --there doesnt exist a end date for this record...hence display only the start date
                --new message being used as we cannot display 31-dec-4712 to user---
                hr_utility.set_message(800,'HR_375870_OTHER_EIT_EXISTS');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_OTHER_WORK_CONDS',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_work_cond_row.aei_information1)));
                hr_utility.raise_error;
            end if; --aei information2 is not null
           end if; --csr_work_condition_date_ins found
   close csr_work_condition_date_ins;

--better to have different internal procedures to check each of the Assignment EITS
--than to go abt checking here.

 elsif p_information_type='PL_PAYMENT_CONDITIONS' then

       CREATE_PL_PAYMENT_CONDITIONS(
                                    P_ASSIGNMENT_ID     => P_ASSIGNMENT_ID   ,
                                    P_AEI_INFORMATION1  => P_AEI_INFORMATION1,
                                    P_AEI_INFORMATION2  => P_AEI_INFORMATION2,
                                    P_AEI_INFORMATION3  => P_AEI_INFORMATION3,
                                    P_AEI_INFORMATION4  => P_AEI_INFORMATION4,
                                    P_AEI_INFORMATION5  => P_AEI_INFORMATION5,
                                    P_AEI_INFORMATION6  => P_AEI_INFORMATION6,
                                    P_AEI_INFORMATION7  => P_AEI_INFORMATION7);

  end if;

   hr_utility.set_location('Leaving'||g_package||l_proc,50);


 Exception
 When others then
  hr_utility.raise_error;
 end; --end procedure


 procedure UPDATE_PL_ASSGT_EXTRA_INFO(

 P_ASSIGNMENT_EXTRA_INFO_ID   in   NUMBER,
 p_aei_information_category   in   VARCHAR2,
 P_AEI_INFORMATION1           in   varchar2 ,
 P_AEI_INFORMATION2           in   varchar2 ,
 P_AEI_INFORMATION3           in   varchar2 ,
 P_AEI_INFORMATION4           in   varchar2 ,
 P_AEI_INFORMATION5           in   varchar2 ,
 P_AEI_INFORMATION6           in   varchar2 ,
 P_AEI_INFORMATION7           in   varchar2
 )
 as


 cursor csr_assignment_id is
 select assignment_id
 from  per_assignment_extra_info
 where information_type='PL_OTHER_WORK_CONDITIONS'
 and   ASSIGNMENT_EXTRA_INFO_ID=P_ASSIGNMENT_EXTRA_INFO_ID;

 cursor csr_work_condition_date_upd(r_assignment_id in number) is
 select AEI_INFORMATION1,AEI_INFORMATION2,AEI_INFORMATION3
 from   per_assignment_extra_info
 where  information_type='PL_OTHER_WORK_CONDITIONS'
 and    per_assignment_extra_info.ASSIGNMENT_ID=r_assignment_id
 and    aei_information_category=p_aei_information_category
 and    AEI_INFORMATION3=p_AEI_INFORMATION3
 and    ASSIGNMENT_EXTRA_INFO_ID<>P_ASSIGNMENT_EXTRA_INFO_ID
 and  (
      fnd_date.canonical_to_date(p_aei_information1)
                                 between fnd_date.canonical_to_date(aei_information1)
                                     and nvl(fnd_date.canonical_to_date(aei_information2),hr_general.end_of_time)
    or nvl(fnd_date.canonical_to_date(p_aei_information2),hr_general.end_of_time)
                                 between fnd_date.canonical_to_date(aei_information1)
                                     and nvl(fnd_date.canonical_to_date(aei_information2),hr_general.end_of_time)
    or fnd_date.canonical_to_date(aei_information1)
                                 between fnd_date.canonical_to_date(p_aei_information1)
                                     and nvl(fnd_date.canonical_to_date(p_aei_information2),hr_general.end_of_time)
    or nvl(fnd_date.canonical_to_date(aei_information2),hr_general.end_of_time)
                                 between fnd_date.canonical_to_date(p_aei_information1)
                                     and fnd_date.canonical_to_date(p_aei_information2)
       );
  l_assignment_id  number;
  l_assignment_start_date date;
  l_assignment_end_date date;
  l_work_cond_row csr_work_condition_date_upd%rowtype;
  l_proc varchar2(26);

  begin

/*Create new private procedure for each of the
  newly added Assignmenmt EIT,pass on the reqd
  parameters to the private procedure,and perform
  necessary validations there
*/

  l_proc:=  'UPDATE_PL_ASSGT_EXTRA_INFO';
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.set_location('Leaving : '||l_proc,10);
   return;
END IF;
   hr_utility.set_location('Entering '||g_package||l_proc,10);

  if p_aei_information_category = 'PL_OTHER_WORK_CONDITIONS' then
    if (fnd_date.canonical_to_date(p_AEI_INFORMATION1)>fnd_date.canonical_to_date(p_AEI_INFORMATION2)) then
      hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
      hr_utility.raise_error;
    end if;

    open csr_assignment_id;
    fetch csr_assignment_id into l_assignment_id;
    close  csr_assignment_id;

    hr_utility.set_location(g_package||l_proc,20);

   --Make sure that start date is after Assignemnt start date
    open  csr_assgt_start_date(l_ASSIGNMENT_ID);
    fetch csr_assgt_start_date into l_assignment_start_date,l_assignment_end_date;
    close csr_assgt_start_date;

   if (fnd_date.canonical_to_date(p_aei_information1)<l_assignment_start_date) or
       nvl(fnd_date.canonical_to_date(p_aei_information2),hr_general.end_of_time)>l_assignment_end_date then
        hr_utility.set_message(800,'HR_375865_ASSGT_START_END_DATE');
        hr_utility.raise_error;
    end if;

hr_utility.set_location(g_package||l_proc,30);

   open  csr_work_condition_date_upd(l_assignment_id);
   fetch csr_work_condition_date_upd into l_work_cond_row;
         if csr_work_condition_date_upd%found then
            close csr_work_condition_date_upd;
            if l_work_cond_row.aei_information2 is not null then
                --there exists an end date for the record...display both start and end dates
                hr_utility.set_message(800,'HR_375854_OTHER_EIT_OVERLAP');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_OTHER_WORK_CONDS',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_work_cond_row.aei_information1)));
                hr_utility.set_message_token('ENDDATE',fnd_date.date_to_displaydate(nvl(fnd_date.canonical_to_date(l_work_cond_row.aei_information2),hr_general.end_of_time)));
                hr_utility.raise_error;
            else
                --there doesnt exist a end date for this record...hence display only the start date
                --new message being used as we cannot display 31-dec-4712 to user---
                hr_utility.set_message(800,'HR_375870_OTHER_EIT_EXISTS');
                hr_utility.set_message_token('WORKCOND',hr_general.decode_lookup('PL_OTHER_WORK_CONDS',p_aei_information3));
                hr_utility.set_message_token('STARTDATE',fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_work_cond_row.aei_information1)));
                hr_utility.raise_error;
            end if; --aei information2 is not null
         end if;--csr_work_condition_date_upd found
   close csr_work_condition_date_upd;

elsif P_AEI_INFORMATION_CATEGORY='PL_PAYMENT_CONDITIONS' then

    UPDATE_PL_PAYMENT_CONDITIONS(   P_ASSIGNMENT_EXTRA_INFO_ID  => P_ASSIGNMENT_EXTRA_INFO_ID,
                                    P_AEI_INFORMATION1          => P_AEI_INFORMATION1,
                                    P_AEI_INFORMATION2          => P_AEI_INFORMATION2,
                                    P_AEI_INFORMATION3          => P_AEI_INFORMATION3,
                                    P_AEI_INFORMATION4          => P_AEI_INFORMATION4,
                                    P_AEI_INFORMATION5          => P_AEI_INFORMATION5,
                                    P_AEI_INFORMATION6          => P_AEI_INFORMATION6,
                                    P_AEI_INFORMATION7          => P_AEI_INFORMATION7);
end if;--p_aei_information_category='PL_PAYMENT_CONDITIONS'

hr_utility.set_location('Leaving'||g_package||l_proc,40);


Exception
When others then
hr_utility.raise_error;

END UPDATE_PL_ASSGT_EXTRA_INFO; --end procedure update

END PER_PL_AEI_INFO ;   --end package

/
