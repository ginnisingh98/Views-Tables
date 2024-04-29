--------------------------------------------------------
--  DDL for Package Body PER_PL_ORG_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PL_ORG_INFO" AS
/* $Header: peplorgp.pkb 120.1 2006/09/14 09:44:17 mseshadr noship $ */

PROCEDURE check_digit(p_org_information varchar2
                     ,account_type varchar2) is
p_check_digit varchar2(2);
p_bank_id varchar2(8);
p_account_number varchar2(16);

Begin

    p_check_digit       := substr(p_org_information,1,2);
    p_bank_id           := substr(p_org_information,3,8);
    p_account_number    := substr(p_org_information,11,16);

       if (hr_pl_utility.validate_bank_id(p_bank_id) = 0 or
           hr_pl_utility.validate_account_no(p_check_digit,p_bank_id,p_account_number) = 0) then
              fnd_message.set_name('PER','HR_PL_INVALID_BANK_NUMBER');
              fnd_message.set_token('ACCOUNT',hr_general.decode_lookup('PL_FORM_LABELS',account_type));
              fnd_message.raise_error;
      end if;

End check_digit;


PROCEDURE pl_to_add_info(p_org_information1     VARCHAR2
                        ,p_org_information2     VARCHAR2
                        ,p_org_information3     VARCHAR2
                        ,p_org_information4     VARCHAR2
                        ,p_org_information5     VARCHAR2
                        ,p_effective_date       DATE
                        ) is
account_name hr_lookups.lookup_code%TYPE;
 Begin

  account_name := NULL;

    if p_org_information1 is not null and p_org_information1 <> hr_api.g_varchar2 then
       account_name := 'CIT';
       check_digit(p_org_information1,account_name);
    end if;

    if p_org_information2 is not null and p_org_information2 <> hr_api.g_varchar2 then
       account_name := 'PIT';
       check_digit(p_org_information2,account_name);
    end if;

    if p_org_information3 is not null and p_org_information3 <> hr_api.g_varchar2 then
       account_name := 'VAT';
       check_digit(p_org_information3,account_name);
    end if;

    if p_org_information4 is not null and p_org_information4 <> hr_api.g_varchar2 then
       account_name := 'BUDGET_INCOME';
       check_digit(p_org_information4,account_name);
    end if;

    if p_org_information5 is not null and p_org_information5 <> hr_api.g_varchar2 then
       account_name := 'OTHER_INCOME';
       check_digit(p_org_information5,account_name);
    end if;

END pl_to_add_info;

------------------------------------------------------------------------------------------------------
--  PER_PL_VALIDATE_ORGNIP																			    --
------------------------------------------------------------------------------------------------------
PROCEDURE PER_PL_VALIDATE_ORGNIP(p_org_information_id VARCHAR2,
   					     p_org_information3 VARCHAR2
					    ) IS

    Cursor cur_nip is select org_information3 from hr_organization_information where org_information_context = 'PL_TAX_INFO'
                and org_information_id <> nvl(p_org_information_id,0) and org_information3 = p_org_information3;
   p_org_info hr_organization_information.org_information3%type;
   nip_sum number;
   TYPE v_nip is TABLE of number index by BINARY_INTEGER;
   nip_number v_nip;
--
BEGIN
--
  nip_sum := 0;

  nip_number(1) := 6*(to_number(substr(p_org_information3,1,1)));
  nip_number(2) := 5*(to_number(substr(p_org_information3,2,1)));
  nip_number(3) := 7 * (to_number(substr(p_org_information3,3,1)));
  nip_number(4) := 2 * (to_number(substr(p_org_information3,4,1)));
  nip_number(5) := 3 * (to_number(substr(p_org_information3,5,1)));
  nip_number(6) := 4 * (to_number(substr(p_org_information3,6,1)));
  nip_number(7) := 5 * (to_number(substr(p_org_information3,7,1)));
  nip_number(8) := 6 * (to_number(substr(p_org_information3,8,1)));
  nip_number(9) := 7 * (to_number(substr(p_org_information3,9,1)));
  nip_number(10) := to_number(substr(p_org_information3,10,1));

  nip_sum := mod((nip_number(1)+nip_number(2)+nip_number(3)+nip_number(4)+nip_number(5)+nip_number(6)+nip_number(7)+
                nip_number(8)+nip_number(9)),11);


  if nip_sum = 10 then
           if nip_number(10) <> 0 then
              hr_utility.set_message(800,'HR_NIP_INVALID_NUMBER_PL');
              hr_utility.raise_error;

          end if;
  elsif nip_sum <> nip_number(10) then
              hr_utility.set_message(800,'HR_NIP_INVALID_NUMBER_PL');
              hr_utility.raise_error;
  end if;
    OPEN cur_nip;
   FETCH cur_nip into p_org_info;

  If cur_nip%found then
     hr_utility.set_message(800,'HR_NIP_UNIQUE_NUMBER_PL');
     hr_utility.raise_error;
  end if;
  CLOSE cur_nip;


END PER_PL_VALIDATE_ORGNIP;
--PER_PL_VALIDATE_ORGNIP


------------------------------------------------------------------------------------------------------
--  CREATE_ORG_DETAILS																		        --
------------------------------------------------------------------------------------------------------

PROCEDURE CREATE_ORG_DETAILS(ORG_ID             NUMBER,
                             P_FLEX_START_DATE  VARCHAR2,
                             P_FLEX_END_DATE    VARCHAR2,
   		             ORG_INFO_TYPE_CODE VARCHAR2) IS

cursor csr_overlap_rec is
   select 1
          from hr_organization_information where
               organization_id = ORG_ID and
	       org_information_context = ORG_INFO_TYPE_CODE and
	       (fnd_date.canonical_to_date(P_FLEX_START_DATE) between fnd_date.canonical_to_date(ORG_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(ORG_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
	        nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
                    between fnd_date.canonical_to_date(ORG_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(ORG_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
                fnd_date.canonical_to_date(ORG_INFORMATION1) between fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                                nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) or
                nvl(fnd_date.canonical_to_date(ORG_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) between
                                 fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                               nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')));

cursor csr_org_dates is
   select date_from, nvl(date_to,to_date('31/12/4712','DD/MM/YYYY')) from
hr_organization_units where organization_id = ORG_ID;

overlap_found  number;
org_start_date date;
org_end_date   date;

BEGIN


if (fnd_date.canonical_to_date(P_FLEX_START_DATE) > fnd_date.canonical_to_date(P_FLEX_END_DATE)) then
         hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
         	     -- This message will be 'Please enter a Start date >= End date
         hr_utility.raise_error;
  end if;

-- Code to check with Org Start Date
   open csr_org_dates;
      fetch csr_org_dates into org_start_date,org_end_date;
   close csr_org_dates;

open csr_overlap_rec;
  fetch csr_overlap_rec into overlap_found;
   if csr_overlap_rec%found then
      hr_utility.set_message(800,'HR_ORG_OVERLAP_REC_PL');
      hr_utility.set_message_token('ORGFLEX',hr_general.decode_lookup('PL_FORM_LABELS',ORG_INFO_TYPE_CODE||'_FLEX'));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
   end if;
close csr_overlap_rec;

 if ((nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) > org_end_date)
           or (fnd_date.canonical_to_date(P_FLEX_START_DATE) < org_start_date))then
     hr_utility.set_message(800,'HR_ORG_DATE_RANGE_PL');
     hr_utility.set_message_token('ORGINFO',hr_general.decode_lookup('PL_FORM_LABELS',ORG_INFO_TYPE_CODE));
    -- This message will be 'Please enter date range so that it falls within org date range
     hr_utility.raise_error;
 end if;

END CREATE_ORG_DETAILS;
--  CREATE_ORG_DETAILS

------------------------------------------------------------------------------------------------------
--  UPDATE_ORG_DETAILS																		        --
------------------------------------------------------------------------------------------------------

PROCEDURE UPDATE_ORG_DETAILS(p_org_id             number,
                             P_ORG_INFORMATION_ID number,
                             P_FLEX_START_DATE    VARCHAR2,
                             P_FLEX_END_DATE      VARCHAR2,
                             P_ORG_INFO_TYPE_CODE VARCHAR2) IS


cursor csr_overlap_upd_rec is
   select 1
          from hr_organization_information where
               organization_id = p_org_id and
	       org_information_context = P_ORG_INFO_TYPE_CODE and
	       (fnd_date.canonical_to_date(P_FLEX_START_DATE) between fnd_date.canonical_to_date(ORG_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(ORG_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
	        nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY'))
                    between fnd_date.canonical_to_date(ORG_INFORMATION1)
                                 and  nvl(fnd_date.canonical_to_date(ORG_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) or
                fnd_date.canonical_to_date(ORG_INFORMATION1) between fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                                nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) or
                nvl(fnd_date.canonical_to_date(ORG_INFORMATION2),to_date('31/12/4712','DD/MM/YYYY')) between
                                 fnd_date.canonical_to_date(P_FLEX_START_DATE) and
                               nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')))
               and org_information_id <> P_ORG_INFORMATION_ID;

cursor csr_org_dates is
   select date_from, nvl(date_to,to_date('31/12/4712','DD/MM/YYYY')) from
   hr_organization_units where organization_id = p_org_id;

overlap_upd_found  number;
org_start_date date;
org_end_date   date;

BEGIN

if (fnd_date.canonical_to_date(P_FLEX_START_DATE) > fnd_date.canonical_to_date(P_FLEX_END_DATE)) then
         hr_utility.set_message(800,'HR_ORG_START_DATE_PL');
	     -- This message will be 'Please enter a Start date >= End date
         hr_utility.raise_error;
  end if;

-- Code to check with Org Start Date
   open csr_org_dates;
      fetch csr_org_dates into org_start_date,org_end_date;
   close csr_org_dates;

open csr_overlap_upd_rec;
  fetch csr_overlap_upd_rec into overlap_upd_found;
   if csr_overlap_upd_rec%found then
      hr_utility.set_message(800,'HR_ORG_OVERLAP_REC_PL');
      hr_utility.set_message_token('ORGFLEX',hr_general.decode_lookup('PL_FORM_LABELS',P_ORG_INFO_TYPE_CODE||'_FLEX'));
      hr_utility.set_message_token('STARTDATE',to_char(fnd_date.canonical_to_date(P_FLEX_START_DATE),'DD/MM/RRRR'));
      hr_utility.set_message_token('ENDDATE',nvl(to_char(fnd_date.canonical_to_date(P_FLEX_END_DATE),'DD/MM/RRRR'),'31/12/4712'));
      hr_utility.raise_error;
   end if;
close csr_overlap_upd_rec;

 if ((nvl(fnd_date.canonical_to_date(P_FLEX_END_DATE),to_date('31/12/4712','DD/MM/YYYY')) > org_end_date)
           or (fnd_date.canonical_to_date(P_FLEX_START_DATE) < org_start_date))then
     hr_utility.set_message(800,'HR_ORG_DATE_RANGE_PL');
     hr_utility.set_message_token('ORGINFO',hr_general.decode_lookup('PL_FORM_LABELS',P_ORG_INFO_TYPE_CODE));
    -- This message will be 'Please enter date range so that it falls within org date range
     hr_utility.raise_error;
 end if;


END UPDATE_ORG_DETAILS;
--  UPDATE_ORG_DETAILS

PROCEDURE CREATE_PL_ORG_INFO(P_EFFECTIVE_DATE  DATE
					,P_ORGANIZATION_ID NUMBER
					,P_ORG_INFO_TYPE_CODE VARCHAR2
					,P_ORG_INFORMATION1 VARCHAR2
					,P_ORG_INFORMATION2 VARCHAR2
					,P_ORG_INFORMATION3 VARCHAR2
					,P_ORG_INFORMATION4 VARCHAR2
					,P_ORG_INFORMATION5 VARCHAR2
					,P_ORG_INFORMATION6 VARCHAR2
					,P_ORG_INFORMATION7 VARCHAR2
					,P_ORG_INFORMATION8 VARCHAR2
					,P_ORG_INFORMATION9 VARCHAR2
					,P_ORG_INFORMATION10 VARCHAR2
					,P_ORG_INFORMATION11 VARCHAR2
					,P_ORG_INFORMATION12 VARCHAR2
					,P_ORG_INFORMATION13 VARCHAR2
					,P_ORG_INFORMATION14 VARCHAR2
					,P_ORG_INFORMATION15 VARCHAR2
					,P_ORG_INFORMATION16 VARCHAR2
					,P_ORG_INFORMATION17 VARCHAR2
					,P_ORG_INFORMATION18 VARCHAR2
					,P_ORG_INFORMATION19 VARCHAR2
					,P_ORG_INFORMATION20 VARCHAR2
                            ) is


BEGIN

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving CREATE_PL_ORG_INFO');
   return;
END IF;

 IF p_org_info_type_code='PL_TO_ADD_INFO' THEN

    pl_to_add_info(p_org_information1
                  ,p_org_information2
                  ,p_org_information3
                  ,p_org_information4
                  ,p_org_information5
                  ,p_effective_date);

elsif p_org_info_type_code = 'PL_SII_INFO' then
       CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                          P_ORG_INFORMATION1,
                          P_ORG_INFORMATION2,
		          p_org_info_type_code);


   elsif p_org_info_type_code = 'PL_CONTRACT_INFO' then
      CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
		         p_org_info_type_code);


elsif p_org_info_type_code = 'PL_ER_BASIC_INFO' then
      CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
		         p_org_info_type_code);


elsif p_org_info_type_code = 'PL_ER_OVERRIDE_INFO' then
      CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
		         p_org_info_type_code);


elsif p_org_info_type_code = 'PL_OTHER_ER_INFO' then
      CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
		         p_org_info_type_code);

elsif p_org_info_type_code = 'PL_PLATNIK_INFO' then
     CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                        P_ORG_INFORMATION1,
                        P_ORG_INFORMATION2,
		        p_org_info_type_code);

elsif p_org_info_type_code = 'PL_REGISTER_OFFICE_INFO' then
      CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
		         p_org_info_type_code);


elsif p_org_info_type_code = 'PL_STATISTIC_OFFICE_INFO' then
      CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
		         p_org_info_type_code);



 Elsif p_org_info_type_code='PL_TAX_INFO' THEN

      CREATE_ORG_DETAILS(P_ORGANIZATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
		         p_org_info_type_code);

      PER_PL_VALIDATE_ORGNIP(NULL,p_org_information3);


 END IF;

END CREATE_PL_ORG_INFO;
-------------------------
PROCEDURE UPDATE_PL_ORG_INFO(P_EFFECTIVE_DATE  DATE
					,P_ORG_INFO_TYPE_CODE VARCHAR2
					,P_ORG_INFORMATION1 VARCHAR2
					,P_ORG_INFORMATION2 VARCHAR2
					,P_ORG_INFORMATION3 VARCHAR2
					,P_ORG_INFORMATION4 VARCHAR2
					,P_ORG_INFORMATION5 VARCHAR2
					,P_ORG_INFORMATION6 VARCHAR2
					,P_ORG_INFORMATION7 VARCHAR2
					,P_ORG_INFORMATION8 VARCHAR2
					,P_ORG_INFORMATION9 VARCHAR2
					,P_ORG_INFORMATION10 VARCHAR2
					,P_ORG_INFORMATION11 VARCHAR2
					,P_ORG_INFORMATION12 VARCHAR2
					,P_ORG_INFORMATION13 VARCHAR2
					,P_ORG_INFORMATION14 VARCHAR2
					,P_ORG_INFORMATION15 VARCHAR2
					,P_ORG_INFORMATION16 VARCHAR2
					,P_ORG_INFORMATION17 VARCHAR2
					,P_ORG_INFORMATION18 VARCHAR2
					,P_ORG_INFORMATION19 VARCHAR2
					,P_ORG_INFORMATION20 VARCHAR2
					,P_ORG_INFORMATION_ID NUMBER
                            ) IS

cursor csr_org_id is
     select organization_id from hr_organization_information where
org_information_id = P_ORG_INFORMATION_ID;

p_org_id hr_organization_units.organization_id%TYPE;

BEGIN

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving UPDATE_PL_ORG_INFO');
   return;
END IF;

 open csr_org_id;
   fetch csr_org_id into p_org_id;
 close csr_org_id;

 IF p_org_info_type_code='PL_TO_ADD_INFO' THEN

    pl_to_add_info(p_org_information1
                  ,p_org_information2
                  ,p_org_information3
                  ,p_org_information4
                  ,p_org_information5
                  ,p_effective_date);


 elsif p_org_info_type_code = 'PL_SII_INFO' then
      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);

 elsif p_org_info_type_code = 'PL_CONTRACT_INFO' then
      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);

 elsif p_org_info_type_code = 'PL_ER_BASIC_INFO' then
      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);


 elsif p_org_info_type_code = 'PL_ER_OVERRIDE_INFO' then
      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);

 elsif p_org_info_type_code = 'PL_OTHER_ER_INFO' then
      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);


 elsif p_org_info_type_code = 'PL_PLATNIK_INFO' then

      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);


 elsif p_org_info_type_code = 'PL_REGISTER_OFFICE_INFO' then
      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);



 elsif p_org_info_type_code = 'PL_STATISTIC_OFFICE_INFO' then

      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);


 Elsif p_org_info_type_code='PL_TAX_INFO' THEN
      UPDATE_ORG_DETAILS(p_org_id,
                         P_ORG_INFORMATION_ID,
                         P_ORG_INFORMATION1,
                         P_ORG_INFORMATION2,
                         P_ORG_INFO_TYPE_CODE);

        PER_PL_VALIDATE_ORGNIP(p_org_information_id,p_org_information3);


 END IF;


END UPDATE_PL_ORG_INFO;
-------------------------


END PER_PL_ORG_INFO;

/
