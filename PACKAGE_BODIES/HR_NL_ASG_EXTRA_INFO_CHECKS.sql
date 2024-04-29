--------------------------------------------------------
--  DDL for Package Body HR_NL_ASG_EXTRA_INFO_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_ASG_EXTRA_INFO_CHECKS" AS
  /* $Header: penlaeiv.pkb 120.2.12010000.2 2009/03/18 08:39:29 knadhan ship $ */
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Sets the Profile PER_ASSIGNMENT_ID to the Current Assignment
  -- for Valueset to validate correctly.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE set_asg_id (p_assignment_id  in     number) IS
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'NL') THEN
    --
    --
    -- Set the Profile ID
    --
    FND_PROFILE.put('PER_ASSIGNMENT_ID',p_assignment_id);

  END IF;/* Added for GSI Bug 5472781 */

  END set_asg_id;

  PROCEDURE CHECK_NUMIV_OVERRIDE(P_ASSIGNMENT_EXTRA_INFO_ID in NUMBER
                                                 ,P_AEI_INFORMATION1 in VARCHAR2) IS

  CURSOR csr_assignments IS
  SELECT paaf1.assignment_id
  FROM per_all_assignments_f paaf1
      , per_assignment_extra_info paei
      , per_all_assignments_f paaf
  WHERE paei.assignment_extra_info_id=P_ASSIGNMENT_EXTRA_INFO_ID
    AND paei.information_type='NL_NUMIV_OVERRIDE'
    AND paaf.assignment_id=paei.assignment_id
    AND paaf.person_id=paaf1.person_id
    AND paaf1.assignment_id <>paaf.assignment_id;

  CURSOR csr_numiv_override (c_asg_id number)is
  SELECT aei_information1 NUMIV_OVERRIDE
       , paaf.assignment_sequence ASSIGNMENT_SEQUENCE
  FROM per_assignment_extra_info paei
     , per_all_assignments_f paaf
  WHERE paaf.assignment_id = c_asg_id
   AND  paei.aei_information_category(+) = 'NL_NUMIV_OVERRIDE'
   AND paei.assignment_id(+)= paaf.assignment_id;

  l_numiv_override NUMBER;
  l_assignment_sequence NUMBER;
  l_override_present BOOLEAN:= FALSE;


  BEGIN
  l_override_present:=false;
  FOR csr_assignments_rec IN csr_assignments
  LOOP

  OPEN csr_numiv_override(csr_assignments_rec.assignment_id);
  FETCH csr_numiv_override INTO l_numiv_override,l_assignment_sequence;
  CLOSE csr_numiv_override;

   IF (nvl(P_AEI_INFORMATION1,500) = nvl(l_numiv_override,501) AND l_numiv_override IS NOT NULL AND P_AEI_INFORMATION1 IS NOT NULL )
      OR (P_AEI_INFORMATION1 = l_assignment_sequence AND l_numiv_override is null)
   THEN
     l_override_present:= TRUE;

   END IF;

  END LOOP;

  IF l_override_present THEN
    hr_utility.set_message(800,'HR_373547_NUMIV_OVERRIDE');
    hr_utility.raise_error;
  END IF;

END;


FUNCTION  ASG_CHECK_NUMIV_OVERRIDE(
                                  P_ASSIGNMENT_ID in NUMBER
                                 ,P_AEI_INFORMATION1 in VARCHAR2
	                       ) return number  IS



  cursor csr_assignments is
  SELECT paaf1.assignment_id
  FROM per_all_assignments_f paaf1
     , per_all_assignments_f paaf
  WHERE paaf.assignment_id=P_ASSIGNMENT_ID
    AND paaf.person_id=paaf1.person_id
    AND paaf1.assignment_id <>paaf.assignment_id;

  CURSOR csr_numiv_override (c_asg_id number)is
  SELECT aei_information1 NUMIV_OVERRIDE
       , paaf.assignment_sequence ASSIGNMENT_SEQUENCE
  FROM per_assignment_extra_info paei, per_all_assignments_f paaf
  WHERE paaf.assignment_id = c_asg_id
   AND  paei.aei_information_category(+) = 'NL_NUMIV_OVERRIDE'
   AND  paei.assignment_id(+)= paaf.assignment_id;

  l_numiv_override NUMBER;
  l_assignment_sequence NUMBER;
  l_override_present BOOLEAN:= FALSE;


  BEGIN

  l_override_present:=false;
  FOR csr_assignments_rec in csr_assignments
  LOOP
     hr_utility.set_location('P_AEI_INFORMATION1'||P_AEI_INFORMATION1,10);
     OPEN csr_numiv_override(csr_assignments_rec.assignment_id);
     FETCH csr_numiv_override INTO l_numiv_override,l_assignment_sequence;
     CLOSE csr_numiv_override;

     IF (nvl(P_AEI_INFORMATION1,500) = nvl(l_numiv_override,501) and l_numiv_override is not null and P_AEI_INFORMATION1 is not null )
             OR (P_AEI_INFORMATION1 = l_assignment_sequence and l_numiv_override is null) THEN
          RETURN 1;
      END IF;
  END LOOP;
 RETURN 0;
 END ASG_CHECK_NUMIV_OVERRIDE;
END hr_nl_asg_extra_info_checks;

/
