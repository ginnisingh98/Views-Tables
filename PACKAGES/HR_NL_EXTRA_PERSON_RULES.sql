--------------------------------------------------------
--  DDL for Package HR_NL_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_EXTRA_PERSON_RULES" AUTHID CURRENT_USER AS
/* $Header: penlexpr.pkh 120.2 2006/05/19 10:53:07 niljain noship $ */
--
procedure extra_person_checks(
   p_first_name IN varchar2,
   p_national_identifier IN varchar2,
   p_honors              IN varchar2,
   p_per_information1    IN varchar2,
   p_per_information4    IN varchar2);

/* First Day Report */

procedure fdr_update_check
 ( P_PERSON_ID per_all_people_f.person_id%TYPE
 , P_DATE_OF_BIRTH date
 , P_PER_INFORMATION1 varchar2
 , P_PRE_NAME_ADJUNCT per_all_people_f.PRE_NAME_ADJUNCT%TYPE default ' '
 , P_LAST_NAME per_all_people_f.LAST_NAME%TYPE
 , P_EFFECTIVE_DATE date default to_date('01/01/4712','DD/MM/YYYY')
 , P_NATIONAL_IDENTIFIER per_all_people_f.NATIONAL_IDENTIFIER%TYPE
 , P_EMPLOYEE_NUMBER per_all_people_f.EMPLOYEE_NUMBER%TYPE);

 procedure fdr_rehire_check
 ( P_PERSON_ID per_all_people_f.person_id%TYPE);

--
END HR_NL_EXTRA_PERSON_RULES;


/
