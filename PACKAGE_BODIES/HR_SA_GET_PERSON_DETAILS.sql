--------------------------------------------------------
--  DDL for Package Body HR_SA_GET_PERSON_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SA_GET_PERSON_DETAILS" AS
/* $Header: pesagpdt.pkb 120.0 2005/05/31 20:38:27 appldev noship $ */

  Function ASG_NATIONALITY_GROUP (p_Assignment_Id Number,
                                 p_Effective_Date Date) return Varchar2
  IS
    l_Nationality_Group HR_LOOKUPS.MEANING%TYPE;

    CURSOR csr_Nationality_Group (l_Assignment_Id Number,
                                 l_Effective_Date Date) IS
     select a.meaning
     from   per_all_people_f       PEOPLE
            ,hr_lookups             a
            ,per_all_assignments_f  ASSIGN
            ,per_shared_types       SHTYPE
    where   l_effective_date between ASSIGN.effective_start_date
                             and ASSIGN.effective_end_date
    and     l_effective_date BETWEEN PEOPLE.effective_start_date
                             and PEOPLE.effective_end_date
    and     ASSIGN.assignment_id = l_assignment_id
    and     PEOPLE.person_id     = ASSIGN.person_id
    and     SHTYPE.LOOKUP_TYPE     (+)= 'NATIONALITY'
    and     PEOPLE.NATIONALITY     (+)= SHTYPE.SYSTEM_TYPE_CD
    and     a.lookup_code        (+)= SHTYPE.INFORMATION5
    and     a.lookup_type        (+)= 'NATIONALITY_GROUP'
    and     a.application_id  (+)= 800;

  BEGIN

    OPEN csr_NAtionality_Group (p_Assignment_Id, p_Effective_Date);
    FETCH csr_NAtionality_Group INTO l_Nationality_Group;
    CLOSE csr_NAtionality_Group;

    RETURN l_Nationality_Group;

  EXCEPTION
    WHEN OTHERS THEN
      IF csr_NAtionality_Group%ISOPEN THEN
        CLOSE csr_NAtionality_Group;
      END IF;
      RAISE;
  END ASG_NATIONALITY_GROUP;

  Function PER_NATIONALITY_GROUP (p_Person_Id Number,
                                 p_Effective_Date Date) return Varchar2
  IS
    l_Nationality_Group HR_LOOKUPS.MEANING%TYPE;

    CURSOR csr_Nationality_Group (l_Person_Id Number,
                                 l_Effective_Date Date) IS
     select a.meaning
     from   per_all_people_f       PEOPLE
            ,hr_lookups             a
            ,per_shared_types       SHTYPE
    where   PEOPLE.person_id     = l_person_id
    and     l_effective_date BETWEEN PEOPLE.effective_start_date
                             AND PEOPLE.effective_end_date
    and     SHTYPE.LOOKUP_TYPE     (+)= 'NATIONALITY'
    and     PEOPLE.NATIONALITY     (+)= SHTYPE.SYSTEM_TYPE_CD
    and     a.lookup_code        (+)= SHTYPE.INFORMATION5
    and     a.lookup_type        (+)= 'NATIONALITY_GROUP'
    and     a.application_id  (+)= 800;

  BEGIN

    OPEN csr_NAtionality_Group (p_Person_Id, p_Effective_Date);
    FETCH csr_NAtionality_Group INTO l_Nationality_Group;
    CLOSE csr_NAtionality_Group;

    RETURN l_Nationality_Group;

  EXCEPTION
    WHEN OTHERS THEN
      IF csr_NAtionality_Group%ISOPEN THEN
        CLOSE csr_NAtionality_Group;
      END IF;
      RAISE;
  END PER_NATIONALITY_GROUP;


END HR_SA_GET_PERSON_DETAILS;


/
