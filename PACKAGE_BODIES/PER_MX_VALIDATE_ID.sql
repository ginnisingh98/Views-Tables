--------------------------------------------------------
--  DDL for Package Body PER_MX_VALIDATE_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_VALIDATE_ID" AS
/* $Header: pemxvlid.pkb 120.1.12010000.1 2008/07/28 05:01:16 appldev ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : PER_MX_VALIDATE_ID

    Description : This package is a hook call for following APIs :-
                    1. create_applicant
                    2. hire_applicant

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  ------------------------------------
    21-JUN-2004 sdahiya    115.0            Created.
    21-JUL-2004 sdahiya    115.1   3777663  Added code to avoid validation of
                                            various identifiers if they are
                                            equal to hr_api.g_varchar2.
    30-JUL-2004 ardsouza   115.2   3804076  Added procedure COMPARE_ID to
                                            handle cases where IDs are entered
                                            without format mask.
    02-AUG-2004 sdahiya    115.3   3804076  Procedure COMPARE_ID should not
                                            compare identifiers for
                                            format validations if both are null.
    16-MAR-2005 ardsouza   115.4   4147647  Commented out calls to
                                            hr_general2.init_fndload(800).
    10-MAY-2006 vpandya    115.5   5176823  Changed compare_id:
                                            Removed appl id from mesg token.
  *****************************************************************************/

/*******************************************************************************
    Name    : compare_id
    Purpose : This procedure compares the 2 ID values and raises an error if
              there's a mismatch
*******************************************************************************/

PROCEDURE compare_id(
            p_value1    per_all_people_f.per_information1%TYPE,
            p_value2    per_all_people_f.per_information1%TYPE,
            p_message   fnd_new_messages.message_name%TYPE) AS

BEGIN
--
    IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'NONE' AND
       fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') <> 'WARN' THEN

    	IF p_value1 = p_value2 OR NVL(p_value1, p_value2) IS NULL THEN
    		null;
    	ELSE
    		hr_utility.set_message(800, p_message);
    		hr_utility.set_message_token('ACTION',
                        hr_general.decode_lookup('MX_ACTION_TOKEN', 'ERROR'));
    		hr_utility.raise_error;
    	END IF;
    END IF;
--
END compare_id;


/*******************************************************************************
    Name    : validate_rfc_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_rfc.
*******************************************************************************/

PROCEDURE VALIDATE_RFC_ID(
            p_per_information2    per_all_people_f.per_information2%type,
            p_person_id           per_all_people_f.person_id%type) AS

    p_warning varchar2(1);
    p_valid_rfc_id per_all_people_f.per_information2%type;
    l_proc_name varchar2(100);

BEGIN
    l_proc_name := glb_proc_name ||'VALIDATE_RFC_ID';
    hr_utility.trace('Entering '||l_proc_name);
 --   hr_general2.init_fndload(800);  -- Bug 4147647
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN
        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
        RETURN;
    END IF;

    IF p_per_information2 = hr_api.g_varchar2 THEN  /* Bug 3777663 */
        hr_utility.trace('RFC ID not available for validation.');
        RETURN;
    END IF;

    per_mx_validations.check_rfc (p_per_information2,
                                  p_person_id,
                                  HR_MX_UTILITY.GET_BG_FROM_PERSON(p_person_id),
                                  p_warning,
                                  p_valid_rfc_id);

    compare_id(p_per_information2, p_valid_rfc_id, 'HR_MX_INVALID_RFC');

    hr_utility.trace('Leaving '||l_proc_name);
END VALIDATE_RFC_ID;

/*******************************************************************************
    Name    : validate_ss_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_ss
*******************************************************************************/

PROCEDURE VALIDATE_SS_ID(
            p_per_information3    per_all_people_f.per_information3%type,
            p_person_id           per_all_people_f.person_id%type) AS

    p_warning varchar2(1);
    p_valid_ss per_all_people_f.per_information3%type;
    l_proc_name varchar2(100);

BEGIN
    l_proc_name := glb_proc_name ||'VALIDATE_SS_ID';
    hr_utility.trace('Entering '||l_proc_name);
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN
        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
        RETURN;
    END IF;

    IF p_per_information3 = hr_api.g_varchar2 THEN  /* Bug 3777663 */
        hr_utility.trace('Social Security ID not available for validation.');
        RETURN;
    END IF;

 --   hr_general2.init_fndload(800);  -- Bug 4147647
 per_mx_validations.check_ss (p_per_information3,
                                 p_person_id,
                                 HR_MX_UTILITY.GET_BG_FROM_PERSON(p_person_id),
                                 p_warning,
                                 p_valid_ss);

    compare_id(p_per_information3, p_valid_ss, 'HR_MX_INVALID_SS');

    hr_utility.trace('Leaving '||l_proc_name);
END VALIDATE_SS_ID;


/*******************************************************************************
    Name    : validate_fga_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_fga
*******************************************************************************/

PROCEDURE VALIDATE_FGA_ID(
            p_per_information5    per_all_people_f.per_information5%type,
            p_person_id           per_all_people_f.person_id%type) AS

    p_warning varchar2(1);
    l_proc_name varchar2(100);

BEGIN
    l_proc_name := glb_proc_name ||'VALIDATE_FGA_ID';
    hr_utility.trace('Entering '||l_proc_name);
--   hr_general2.init_fndload(800);  -- Bug 4147647
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN
        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
        RETURN;
    END IF;

    IF p_per_information5 = hr_api.g_varchar2 THEN  /* Bug 3777663 */
        hr_utility.trace('Federal Government Affiliation ID not available for validation.');
        RETURN;
    END IF;

    per_mx_validations.check_fga (p_per_information5,
                                  p_person_id,
                                  HR_MX_UTILITY.GET_BG_FROM_PERSON(p_person_id),
                                  p_warning);
    hr_utility.trace('Leaving '||l_proc_name);
END VALIDATE_FGA_ID;


/*******************************************************************************
    Name    : validate_ms_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_ms
*******************************************************************************/

PROCEDURE VALIDATE_MS_ID(
            p_per_information6    per_all_people_f.per_information6%type,
            p_person_id           per_all_people_f.person_id%type) AS

    p_warning varchar2(1);
    l_proc_name varchar2(100);

BEGIN
    l_proc_name := glb_proc_name ||'VALIDATE_MS_ID';
    hr_utility.trace('Entering '||l_proc_name);
--   hr_general2.init_fndload(800);  -- Bug 4147647
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN
        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
        RETURN;
    END IF;

    IF p_per_information6 = hr_api.g_varchar2 THEN  /* Bug 3777663 */
        hr_utility.trace('Military Service ID not available for validation.');
        RETURN;
    END IF;

    per_mx_validations.check_ms (p_per_information6,
                                 p_person_id,
                                 HR_MX_UTILITY.GET_BG_FROM_PERSON(p_person_id),
                                 p_warning);
    hr_utility.trace('Leaving '||l_proc_name);
END VALIDATE_MS_ID;


/*******************************************************************************
    Name    : validate_imc_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_imc
*******************************************************************************/

PROCEDURE VALIDATE_IMC_ID(
            p_per_information4    per_all_people_f.per_information4%type) AS

    l_proc_name varchar2(100);
BEGIN
    l_proc_name := glb_proc_name ||'VALIDATE_IMC_ID';
    hr_utility.trace('Entering '||l_proc_name);
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN
        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
        RETURN;
    END IF;

    IF p_per_information4 = hr_api.g_varchar2 THEN  /* Bug 3777663 */
        hr_utility.trace('Social Security Medical Center ID not available for validation.');
        RETURN;
    END IF;

--   hr_general2.init_fndload(800);  -- Bug 4147647
    per_mx_validations.check_imc(p_per_information4);
    hr_utility.trace('Leaving '||l_proc_name);
END VALIDATE_IMC_ID;


/*******************************************************************************
    Name    : validate_regn_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_regstrn_id
*******************************************************************************/

PROCEDURE VALIDATE_REGN_ID(
            p_disability_id     number,
            p_registration_id   varchar2) AS

    l_proc_name varchar2(100);
BEGIN
    l_proc_name := glb_proc_name ||'VALIDATE_REGN_ID';
    hr_utility.trace('Entering '||l_proc_name);
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN
        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
        RETURN;
    END IF;

    IF p_registration_id = hr_api.g_varchar2 THEN   /* Bug 3777663 */
        hr_utility.trace('Registration ID not available for validation.');
        RETURN;
    END IF;

    per_mx_validations.check_regstrn_id(p_registration_id,
                                        p_disability_id);
    hr_utility.trace('Leaving '||l_proc_name);
END VALIDATE_REGN_ID;

BEGIN
    glb_proc_name := 'PER_MX_VALIDATE_ID.';
END PER_MX_VALIDATE_ID;


/
