--------------------------------------------------------
--  DDL for Package Body PER_GB_EXTRA_PERSON_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_EXTRA_PERSON_CHECKS" as
/* $Header: pegbpeiv.pkb 120.0.12010000.1 2009/12/07 10:16:02 parusia noship $ */

   procedure create_gb_person_extra_info (p_person_id in number
                               		 , p_pei_information_category in varchar2
	                                 , p_pei_information1 in varchar2
	                                 , p_pei_information2 in varchar2
	                                 , p_pei_information3 in varchar2
	                                 , p_pei_information4 in varchar2
	                                 , p_pei_information5 in varchar2
	                                 , p_pei_information6 in varchar2
	                                 , p_pei_information7 in varchar2
	                                 , p_pei_information8 in varchar2
	                                 , p_pei_information9 in varchar2
	                                 , p_pei_information10 in varchar2) as
   local_warning exception ;
   begin
       -- Checks for School Workforce Census
       if p_pei_information_category = 'PQP_SCHOOL_WORKFORCE_CENSUS' then

           -- 1) If Qualified Teacher Status = Yes,
           --    then Qualified Teacher Status Date must be provided
           if p_pei_information1 = 'Y' and p_pei_information2 is null then
               fnd_message.set_name('PQP', 'PQP_230250_QTS_YES_FIELD_MAND');
               fnd_message.set_token('FIELD', 'Qualified Teacher Status Date');
               fnd_message.raise_error;
           end if ;

           -- 2) If Qualified Teacher Status = Yes,
           --    then Teacher Number must be provided
           if p_pei_information1 = 'Y' and p_pei_information2 is null then
               fnd_message.set_name('PQP', 'PQP_230250_QTS_YES_FIELD_MAND');
               fnd_message.set_token('FIELD', 'Teacher Number');
               fnd_message.raise_error;
           end if ;

           -- 3) If Override Absent on Census Day Indicator is provided
           --    then Override Absent on Census Day Year and Term are mandatory
           if p_pei_information6 is not null  then
               if p_pei_information7 is null or p_pei_information8 is null then
                   fnd_message.set_name('PQP', 'PQP_230251_ENTER_ABS_YR_TERM');
                   fnd_message.raise_error;
               end if ;
           end if;

       end if ;
   end create_gb_person_extra_info;

   ---

   procedure update_gb_person_extra_info(P_PERSON_EXTRA_INFO_ID in NUMBER
                                       ,P_PEI_INFORMATION_CATEGORY in VARCHAR2
                                       ,P_PEI_INFORMATION1 in VARCHAR2
                                       ,P_PEI_INFORMATION2 in VARCHAR2
                                       ,P_PEI_INFORMATION3 in VARCHAR2
                                       ,P_PEI_INFORMATION4 in VARCHAR2
                                       ,P_PEI_INFORMATION5 in VARCHAR2
                                       ,P_PEI_INFORMATION6 in VARCHAR2
                                       ,P_PEI_INFORMATION7 in VARCHAR2
                                       ,P_PEI_INFORMATION8 in VARCHAR2
                                       ,P_PEI_INFORMATION9 in VARCHAR2
                                       ,P_PEI_INFORMATION10 in VARCHAR2) as
   begin
       -- Checks for School Workforce Census
       if p_pei_information_category = 'PQP_SCHOOL_WORKFORCE_CENSUS' then

           -- 1) If Qualified Teacher Status = Yes,
           --    then Qualified Teacher Status Date must be provided
           if p_pei_information1 = 'Y' and p_pei_information2 is null then
               fnd_message.set_name('PQP', 'PQP_230250_QTS_YES_FIELD_MAND');
               fnd_message.set_token('FIELD', 'Qualified Teacher Status Date');
               fnd_message.raise_error;
           end if ;

           -- 2) If Qualified Teacher Status = Yes,
           --    then Teacher Number must be provided
           if p_pei_information1 = 'Y' and p_pei_information4 is null then
               fnd_message.set_name('PQP', 'PQP_230250_QTS_YES_FIELD_MAND');
               fnd_message.set_token('FIELD', 'Teacher Number');
               fnd_message.raise_error;
           end if ;

           -- 3) If Override Absent on Census Day Indicator is provided
           --    then Override Absent on Census Day Year and Term are mandatory
           if p_pei_information6 is not null  then
               if p_pei_information7 is null or p_pei_information8 is null then
                   fnd_message.set_name('PQP', 'PQP_230251_ENTER_ABS_YR_TERM');
                   fnd_message.raise_error;
               end if ;
           end if;

       end if ;
   end update_gb_person_extra_info;
end per_gb_extra_person_checks ;



/
