--------------------------------------------------------
--  DDL for Package Body HR_NZ_ASSIGNMENT_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_ASSIGNMENT_LEG_HOOK" AS
/* $Header: hrnzlhas.pkb 120.0 2005/05/31 01:39:03 appldev noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1999 Oracle Corporation Australia Ltd.,         *
 *                     Brisbane, Australia.                       *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  the material is also     *
 *  protected by copyright law.  no part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation          *
 *  Australia Ltd,.                                               *
 *                                                                *
 ******************************************************************/

/*
	Filename: hrnzlhas.pkb (BODY)
    Author: Philip Macdonald
 	Description: Creates the user hook seed data for the HR_ASSIGNMENT_API package procedures.

 	File Information
 	================

	Note for Oracle HRMS Developers: The data defined in the
	create API calls cannot be changed once this script has
	been shipped to customers. Explicit update or delete API
	calls will need to be added to the end of the script.


 	Change List
 	-----------

 	Version Date      Author     ER/CR No. Description of Change
 	-------+---------+-----------+---------+--------------------------
 	110.0   25-Jun-99 P.Macdonald           Created

 ================================================================= */
  --
  -- Package Variables
  --
  g_package  VARCHAR2(33) := 'hr_nz_assignment_leg_hook.';

  PROCEDURE set_upd_bus_grp_id( p_assignment_id NUMBER, p_effective_date DATE ) IS

    CURSOR csr_get_business_group_id(c_assignment_id  per_assignments_f.assignment_id%TYPE
									,c_effective_date DATE) IS
     SELECT     paf.business_group_id
     FROM       per_assignments_f      paf
               ,per_business_groups    pbg
     WHERE      paf.assignment_id       = c_assignment_id
     AND        paf.business_group_id   = pbg.business_group_id
     AND   		c_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
     AND        pbg.legislation_code    = 'NZ';

    l_business_group_id     per_business_groups.business_group_id%TYPE;
    l_proc                  VARCHAR2(72) := g_package||'set_bus_grp_id';

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    OPEN    csr_get_business_group_id(p_assignment_id,p_effective_date);
    FETCH   csr_get_business_group_id INTO    l_business_group_id;
    IF (csr_get_business_group_id%NOTFOUND)
	THEN
      -- Assignment not valid for current legislation
      CLOSE csr_get_business_group_id;
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','NZ');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_get_business_group_id;
    fnd_profile.put('PER_BUSINESS_GROUP_ID',l_business_group_id);
    hr_utility.set_location(' Leaving:'||l_proc, 20);
  END set_upd_bus_grp_id;
--
PROCEDURE set_cre_bus_grp_id( p_person_id NUMBER, p_effective_date DATE ) IS
--
    CURSOR csr_get_business_group_id (c_person_id  per_people_f.person_id%TYPE
									 ,c_effective_date DATE) IS
     SELECT     ppf.business_group_id
     FROM       per_people_f       ppf
               ,per_business_groups    pbg
     WHERE      ppf.person_id           = c_person_id
     AND        ppf.business_group_id   = pbg.business_group_id
     AND   		c_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
     AND        pbg.legislation_code    = 'NZ';
--
    l_business_group_id     per_business_groups.business_group_id%TYPE;
    l_proc                  VARCHAR2(72) := g_package||'set_bus_grp_id';
--
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    OPEN    csr_get_business_group_id(p_person_id, p_effective_date);
    FETCH   csr_get_business_group_id INTO l_business_group_id;
    IF (csr_get_business_group_id%NOTFOUND)
	THEN
      -- Person not valid for current legislation
      CLOSE csr_get_business_group_id;
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','NZ');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_get_business_group_id;
    fnd_profile.put('PER_BUSINESS_GROUP_ID',l_business_group_id);
    hr_utility.set_location(' Leaving:'||l_proc, 20);
  END set_cre_bus_grp_id;
  --
END hr_nz_assignment_leg_hook;

/
