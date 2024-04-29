--------------------------------------------------------
--  DDL for Package Body PER_HU_ASSIGN_EXTRA_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_ASSIGN_EXTRA_INFO" as
/* $Header: pehuaeip.pkb 120.1 2006/09/20 16:31:29 mgettins noship $ */

PROCEDURE chk_date(p_aei_information2   varchar2
                  ,p_aei_information3   varchar2
                   ) IS
BEGIN
    IF p_aei_information2 IS NOT NULL AND p_aei_information3 IS NOT NULL THEN
        IF fnd_date.canonical_to_date(p_aei_information2)> fnd_date.canonical_to_date(p_aei_information3) THEN
            hr_utility.set_message(800,'HR_HU_INVALID_ASG_CATG_DATE');
            hr_utility.raise_error;
        END IF;
    END IF;
END chk_date;


PROCEDURE CREATE_HU_ASSIGN_EXTRA_INFO
  (p_assignment_id                 number
  ,p_information_type              varchar2
  ,p_aei_information_category      varchar2
  ,p_aei_information2              varchar2
  ,p_aei_information3              varchar2
  ) IS
  CURSOR get_assignment_type is
  SELECT assignment_type
  FROM   per_all_assignments_f paaf,fnd_sessions fs
  WHERE  paaf.assignment_id=p_assignment_id
  AND    fs.session_id=userenv('sessionid')
  AND    fs.effective_date BETWEEN paaf.effective_start_date
         and paaf.effective_end_date;

l_assignment_type   per_all_assignments_f.assignment_type%TYPE;
 BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    IF p_information_type='HU_ASG_CATEGORY' THEN
     OPEN get_assignment_type;
     FETCH get_assignment_type INTO l_assignment_type;
     IF l_assignment_type ='C' THEN
        hr_utility.set_message(800,'HR_HU_INVALID_ASG_CATG');
        hr_utility.raise_error;
     END IF;
     CLOSE get_assignment_type;

     per_hu_assign_extra_info.chk_date(p_aei_information2 => p_aei_information2
            ,p_aei_information3 => p_aei_information3);

    END IF;
   END IF;
 END CREATE_HU_ASSIGN_EXTRA_INFO;

--
PROCEDURE UPDATE_HU_ASSIGN_EXTRA_INFO
  (p_assignment_extra_info_id      number
  ,p_aei_information_category      varchar2
  ,p_aei_information2              varchar2
  ,p_aei_information3              varchar2
  ) IS
CURSOR get_assignment_type is
  SELECT  assignment_type
  FROM    per_all_assignments_f paaf, fnd_sessions fs
  WHERE   paaf.assignment_id=(select assignment_id from per_assignment_extra_info
  where assignment_extra_info_id=p_assignment_extra_info_id)
  AND    fs.session_id = userenv('sessionid')
  AND    fs.effective_date BETWEEN paaf.effective_start_date
         and paaf.effective_end_date;


l_assignment_type   per_all_assignments_f.assignment_type%TYPE;
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    IF p_aei_information_category = 'HU_ASG_CATEGORY' THEN

    OPEN get_assignment_type;
     FETCH get_assignment_type INTO l_assignment_type;
     IF l_assignment_type ='C' THEN
        hr_utility.set_message(800,'HR_HU_INVALID_ASG_CATG');
        hr_utility.raise_error;
     END IF;
     CLOSE get_assignment_type;

     per_hu_assign_extra_info.chk_date(p_aei_information2 => p_aei_information2
              ,p_aei_information3 => p_aei_information3);
    END IF;
  END IF;
END UPDATE_HU_ASSIGN_EXTRA_INFO;
--
END PER_HU_ASSIGN_EXTRA_INFO;

/
