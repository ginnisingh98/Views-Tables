--------------------------------------------------------
--  DDL for Package Body HR_MX_EXTRA_ASG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_EXTRA_ASG_RULES" AS
/* $Header: hrmxexas.pkb 120.4.12010000.1 2008/07/28 03:31:54 appldev ship $ */

-- Global variables
--
    g_debug    BOOLEAN;
    g_package  VARCHAR2(33);

--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_gre_loc                                         --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to save the location and GRE for the      --
--                  given assignment on the specified date in global    --
--                  variables.                                          --
-- Parameters     :                                                     --
--             IN : p_effective_date        DATE                        --
--                  p_assignment_id         NUMBER                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE get_gre_loc(p_effective_date IN        DATE,
                      p_assignment_id  IN        per_assignments_f.assignment_id%TYPE
                     ) AS
--
       l_proc        VARCHAR2(100);
       l_location_id hr_locations.location_id%TYPE;
       l_scl_gre     hr_soft_coding_keyflex.segment1%TYPE;

     CURSOR csr_get_gre_location IS
     SELECT paf.location_id,
            hsck.segment1
       FROM per_assignments_f      PAF,
            hr_soft_coding_keyflex HSCK
      WHERE paf.assignment_id = p_assignment_id
        AND paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
        AND trunc(p_effective_date) BETWEEN paf.effective_start_date
                                        AND paf.effective_end_date;

--
BEGIN
--
     g_debug := hr_utility.debug_enabled;

     l_proc := g_package||'get_gre_loc';

     IF g_debug THEN
        hr_utility.set_location('Entering:'|| l_proc, 10);
     END IF;

     OPEN csr_get_gre_location;
     FETCH csr_get_gre_location INTO l_location_id, l_scl_gre;
     CLOSE csr_get_gre_location;

     hr_mx_assignment_api.g_old_location := l_location_id;
     hr_mx_assignment_api.g_old_gre      := l_scl_gre;

     IF g_debug THEN
        hr_utility.set_location('Leaving: '||l_proc, 20);
     END IF;
--
END get_gre_loc;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_loc_gre_for_leav_reason                         --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to perform the Leaving Reason validations --
--                  in case of update of assignment's location or GRE.  --
-- Parameters     :                                                     --
--             IN : p_effective_date        DATE                        --
--                       p_datetrack_update_mode VARCHAR2                    --
--                  p_assignment_id         NUMBER                      --
--                  p_location_id           NUMBER                      --
--                  p_scl_segment1          VARCHAR2                    --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE chk_loc_gre_for_leav_reason(p_effective_date        IN DATE,
                                       p_datetrack_update_mode IN VARCHAR2,
                                      p_assignment_id         IN per_assignments_f.assignment_id%TYPE,
                                      p_location_id           IN hr_locations.location_id%TYPE,
                                      p_scl_segment1          IN hr_soft_coding_keyflex.segment1%TYPE
                                     ) AS
--
        l_gre_old       hr_soft_coding_keyflex.segment1%TYPE;
        l_gre_new       hr_soft_coding_keyflex.segment1%TYPE;
        l_location_old  hr_locations.location_id%TYPE;
        l_scl_gre       hr_soft_coding_keyflex.segment1%TYPE;
        l_dummy1        BOOLEAN;
        l_dummy2        BOOLEAN;
        l_dummy3        per_assignment_extra_info.assignment_extra_info_id%TYPE;
        l_dummy4        NUMBER;
        l_bg_id         per_assignments_f.business_group_id%TYPE;
        l_proc          VARCHAR2(100);
        l_segment1      hr_soft_coding_keyflex.segment1%TYPE;
        l_location_id   hr_locations.location_id%TYPE;


        CURSOR csr_fetch_bg IS
        SELECT business_group_id
          FROM per_assignments_f
         WHERE assignment_id = p_assignment_id
           AND rownum < 2;
--
BEGIN
--
        g_debug    := hr_utility.debug_enabled;

        l_proc := g_package||'chk_loc_gre_for_leav_reason';

        IF g_debug THEN
                hr_utility.set_location('Entering:'|| l_proc, 10);
        END IF;

        IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN

                IF g_debug THEN
                        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
                END IF;
                RETURN;
        END IF;

--------------------------------------------------------------------------
-- Get the OLD gre and location from the global variables that have been
-- set in the BP hook
--------------------------------------------------------------------------
        l_location_old := hr_mx_assignment_api.g_old_location;
        l_scl_gre      := hr_mx_assignment_api.g_old_gre;

--------------------------------------------------------------------------
-- Reset the global variables for Old Location and GRE to NULL.
--------------------------------------------------------------------------
        hr_mx_assignment_api.g_old_location := NULL;
        hr_mx_assignment_api.g_old_gre      := NULL;

        OPEN csr_fetch_bg;
        FETCH csr_fetch_bg INTO l_bg_id;
        CLOSE csr_fetch_bg;

        IF g_debug THEN
                hr_utility.set_location(l_proc, 20);
        END IF;

---------------------
-- Fetch the Old GRE.
---------------------
        l_gre_old := nvl(  to_number(l_scl_gre),

                           hr_mx_utility.get_gre_from_location(l_location_old,
                                                       l_bg_id, -- Bug 4129001
                                                       p_effective_date,
                                                       l_dummy1,
                                                       l_dummy2)
                        );

        IF g_debug THEN
                hr_utility.set_location(l_proc, 30);
        END IF;

--------------------------------------------------------------------------
-- Use the old location and old SCL GRE values, if the parameters are
-- system defaulted. (Bug 3777663)
--------------------------------------------------------------------------
        SELECT decode(p_scl_segment1, hr_api.g_varchar2, l_scl_gre, p_scl_segment1),
               decode(p_location_id, hr_api.g_number, l_location_old, p_location_id)
        INTO   l_segment1,
               l_location_id
        FROM DUAL;

        IF g_debug THEN
                hr_utility.set_location(l_proc, 35);
        END IF;

--------------------------------------------------------------------------
-- Determine the NEW gre for the given assignment_id.
--------------------------------------------------------------------------
        l_gre_new := nvl(  to_number(l_segment1),

                           hr_mx_utility.get_gre_from_location(l_location_id,
                                                       l_bg_id, -- Bug 4129001
                                                       p_effective_date,
                                                       l_dummy1,
                                                       l_dummy2)
                        );

        IF g_debug THEN
                hr_utility.set_location(l_proc, 40);
        END IF;

--------------------------------------------------------------------------
-- Check the new GRE and compare with old GRE and location to determine
-- if there is a change in GRE taking place with this Update operation.
--------------------------------------------------------------------------
        IF l_gre_new <> l_gre_old AND
           l_gre_new IS NOT NULL  AND
           l_gre_old IS NOT NULL  AND
           p_datetrack_update_mode IN ('UPDATE', 'UPDATE_CHANGE_INSERT', 'UPDATE_OVERRIDE') THEN

--------------------------------------------------------------------------
-- If YES, then check the leaving reason Global Variable. If it's null,
-- raise an error. Else, insert an Assignment EIT record using the API.
--------------------------------------------------------------------------
                IF hr_mx_assignment_api.g_leaving_reason IS NULL THEN

--                        hr_utility.set_message(800,'HR_MX_MISSING_LEAVING_REASON');
--                           hr_utility.raise_error;
                        null;

                ELSE

                        OPEN csr_fetch_bg;
                        FETCH csr_fetch_bg INTO l_bg_id;
                        CLOSE csr_fetch_bg;

                        IF g_debug THEN
                                hr_utility.set_location(l_proc, 50);
                        END IF;

                        fnd_profile.put('PER_BUSINESS_GROUP_ID', l_bg_id);

                        hr_assignment_extra_info_api.create_assignment_extra_info
                            (p_assignment_id    => p_assignment_id,
                             p_information_type => 'MX_SS_EMP_TRANS_REASON',
                             p_aei_information_category => 'MX_SS_EMP_TRANS_REASON',
                             p_aei_information1 => fnd_date.date_to_canonical(trunc(p_effective_date) - 1),
                             p_aei_information2 => l_gre_old,
                             p_aei_information3 => hr_mx_assignment_api.g_leaving_reason,
                             p_assignment_extra_info_id => l_dummy3,
                             p_object_version_number => l_dummy4
                            );

                        IF g_debug THEN
                                hr_utility.set_location(l_proc, 60);
                        END IF;

                        hr_mx_assignment_api.g_leaving_reason := null;

                END IF;

        END IF;

        IF g_debug THEN
                hr_utility.set_location('Leaving: '||l_proc, 70);
        END IF;

--
END chk_loc_gre_for_leav_reason;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_gre_for_leav_reason                             --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to perform the Leaving Reason validations --
--                  in case of update of assignment's GRE through SCL.  --
-- Parameters     :                                                     --
--             IN : p_effective_date        DATE                        --
--                       p_datetrack_update_mode VARCHAR2                    --
--                  p_assignment_id         NUMBER                      --
--                  p_segment1              VARCHAR2                    --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE chk_gre_for_leav_reason(p_effective_date        IN DATE,
                                  p_datetrack_update_mode IN VARCHAR2,
                                  p_assignment_id         IN per_assignments_f.assignment_id%TYPE,
                                  p_segment1              IN hr_soft_coding_keyflex.segment1%TYPE
                                 ) AS
--
        l_gre_old       hr_soft_coding_keyflex.segment1%TYPE;
        l_gre_new       hr_soft_coding_keyflex.segment1%TYPE;
        l_location_old  hr_locations.location_id%TYPE;
        l_scl_gre       hr_soft_coding_keyflex.segment1%TYPE;
        l_dummy1        BOOLEAN;
        l_dummy2        BOOLEAN;
        l_dummy3        per_assignment_extra_info.assignment_extra_info_id%TYPE;
        l_dummy4        NUMBER;
        l_bg_id         per_assignments_f.business_group_id%TYPE;
        l_proc          VARCHAR2(100);
        l_segment1      hr_soft_coding_keyflex.segment1%TYPE;

        CURSOR csr_fetch_bg IS
        SELECT business_group_id
          FROM per_assignments_f
         WHERE assignment_id = p_assignment_id
           AND rownum < 2;
--
BEGIN
--
        g_debug    := hr_utility.debug_enabled;

        l_proc := g_package||'chk_gre_for_leav_reason';

        IF g_debug THEN
                hr_utility.set_location('Entering:'|| l_proc, 10);
        END IF;

        IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN

                IF g_debug THEN
                        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
                END IF;
                RETURN;
        END IF;

--------------------------------------------------------------------------
-- Get the old gre and location for the given assignment_id as on the
-- effective_date.
--------------------------------------------------------------------------
        get_gre_loc(p_effective_date,
                    p_assignment_id
                   );

        l_location_old := hr_mx_assignment_api.g_old_location;
        l_scl_gre      := hr_mx_assignment_api.g_old_gre;

--------------------------------------------------------------------------
-- Reset the global variables for Old Location and GRE to NULL.
--------------------------------------------------------------------------
        hr_mx_assignment_api.g_old_location := NULL;
        hr_mx_assignment_api.g_old_gre      := NULL;

        OPEN csr_fetch_bg;
        FETCH csr_fetch_bg INTO l_bg_id;
        CLOSE csr_fetch_bg;

        IF g_debug THEN
                hr_utility.set_location(l_proc, 20);
        END IF;

        l_gre_old := nvl(  to_number(l_scl_gre),

                           hr_mx_utility.get_gre_from_location(l_location_old,
                                                       l_bg_id, -- Bug 4129001
                                                       p_effective_date,
                                                       l_dummy1,
                                                       l_dummy2)
                        );

        IF g_debug THEN
                hr_utility.set_location(l_proc, 30);
        END IF;

--------------------------------------------------------------------------
--  Use the old SCL GRE value, if the value of p_segment1 is system
--  defaulted. (Bug 3777663)
--------------------------------------------------------------------------
        SELECT decode(p_segment1, hr_api.g_varchar2, l_scl_gre, p_segment1)
        INTO   l_segment1
        FROM DUAL;

        IF g_debug THEN
                hr_utility.set_location(l_proc, 35);
        END IF;

--------------------------------------------------------------------------
-- Determine the NEW gre for the given assignment_id.
-- Bug 3785341 - The Old location is used to derive GRE, if the GRE passed
--               is null.
--------------------------------------------------------------------------
        l_gre_new := nvl(  to_number(l_segment1),
                           hr_mx_utility.get_gre_from_location(l_location_old,
                                                       l_bg_id, -- Bug 4129001
                                                       p_effective_date,
                                                       l_dummy1,
                                                       l_dummy2)
                        );

--------------------------------------------------------------------------
-- Check the new GRE and compare with old GRE and location to determine
-- if there is a change in GRE taking place with this Update operation.
--------------------------------------------------------------------------
        IF l_gre_new <> l_gre_old AND
           l_gre_new IS NOT NULL  AND
           l_gre_old IS NOT NULL  AND
           p_datetrack_update_mode IN ('UPDATE', 'UPDATE_CHANGE_INSERT', 'UPDATE_OVERRIDE') THEN

--------------------------------------------------------------------------
-- If YES, then check the leaving reason Global Variable. If it's null,
-- raise an error. Else, insert an Assignment EIT record using the API.
--------------------------------------------------------------------------
                IF hr_mx_assignment_api.g_leaving_reason IS NULL THEN

                        IF g_debug THEN
                                hr_utility.set_location(l_proc, 40);
                        END IF;

--                        hr_utility.set_message(800,'HR_MX_MISSING_LEAVING_REASON');
--                        hr_utility.raise_error;
                        null;

                ELSE

                        IF g_debug THEN
                                hr_utility.set_location(l_proc, 50);
                        END IF;

                        fnd_profile.put('PER_BUSINESS_GROUP_ID', l_bg_id);

                        hr_assignment_extra_info_api.create_assignment_extra_info
                            (p_assignment_id    => p_assignment_id,
                             p_information_type => 'MX_SS_EMP_TRANS_REASON',
                             p_aei_information_category => 'MX_SS_EMP_TRANS_REASON',
                             p_aei_information1 => fnd_date.date_to_canonical(trunc(p_effective_date) - 1),
                             p_aei_information2 => l_gre_old,
                             p_aei_information3 => hr_mx_assignment_api.g_leaving_reason,
                             p_assignment_extra_info_id => l_dummy3,
                             p_object_version_number => l_dummy4
                            );

                        hr_mx_assignment_api.g_leaving_reason := null;

                        IF g_debug THEN
                                hr_utility.set_location(l_proc, 60);
                        END IF;

                END IF;

        END IF;

        IF g_debug THEN
                hr_utility.set_location('Leaving: '||l_proc, 70);
        END IF;

END chk_gre_for_leav_reason;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_leav_reason_for_del_asg                         --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to capture the Leaving Reason in case of  --
--                  delete of assignment.                               --
-- Parameters     :                                                     --
--             IN : p_final_process_date    DATE                        --
--                  p_assignment_id         NUMBER                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE chk_leav_reason_for_del_asg

         (p_final_process_date    IN DATE,
          p_assignment_id         IN per_assignments_f.assignment_id%TYPE
         )
AS
--
        l_gre_old       hr_soft_coding_keyflex.segment1%TYPE;
        l_location_old  hr_locations.location_id%TYPE;
        l_scl_gre       hr_soft_coding_keyflex.segment1%TYPE;
        l_dummy1        BOOLEAN;
        l_dummy2        BOOLEAN;
        l_dummy3        per_assignment_extra_info.assignment_extra_info_id%TYPE;
        l_dummy4        NUMBER;
        l_proc          VARCHAR2(100);

        l_bg_id         per_assignments_f.business_group_id%TYPE;

        CURSOR csr_fetch_bg IS
        SELECT business_group_id
          FROM per_assignments_f
         WHERE assignment_id = p_assignment_id
           AND rownum < 2;
--
BEGIN
--
        g_debug    := hr_utility.debug_enabled;

        l_proc := g_package||'chk_leav_reason_for_del_asg';
        IF g_debug THEN
                hr_utility.set_location('Entering:'|| l_proc, 10);
        END IF;

        IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN

                IF g_debug THEN
                        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
                END IF;
                RETURN;
        END IF;

--------------------------------------------------------------------------
-- Get the old gre and location for the given assignment_id as on the
-- Final Process Date.
--------------------------------------------------------------------------
        get_gre_loc(p_final_process_date,
                    p_assignment_id
                   );

        l_location_old := hr_mx_assignment_api.g_old_location;
        l_scl_gre      := hr_mx_assignment_api.g_old_gre;

--------------------------------------------------------------------------
-- Reset the global variables for Old Location and GRE to NULL.
--------------------------------------------------------------------------
        hr_mx_assignment_api.g_old_location := NULL;
        hr_mx_assignment_api.g_old_gre      := NULL;

--------------------------------------------------------------------------
-- Fetch the BG for the assignment and set the corresponding system profile.
--------------------------------------------------------------------------
        OPEN csr_fetch_bg;
        FETCH csr_fetch_bg INTO l_bg_id;
        CLOSE csr_fetch_bg;

        fnd_profile.put('PER_BUSINESS_GROUP_ID', l_bg_id);


        IF g_debug THEN
                hr_utility.set_location(l_proc, 20);
        END IF;

--------------------------------------------------------------------------
-- Fetch the GRE for the assignment record being deleted.
--------------------------------------------------------------------------
        l_gre_old := nvl(  to_number(l_scl_gre),

                           hr_mx_utility.get_gre_from_location(l_location_old,
                                                       l_bg_id, -- Bug 4129001
                                                       p_final_process_date,
                                                       l_dummy1,
                                                       l_dummy2)
                        );

        IF g_debug THEN
                hr_utility.set_location(l_proc, 30);
        END IF;

--------------------------------------------------------------------------
-- Check the leaving reason Global Variable. If it's null,
-- raise an error. Else, insert an Assignment EIT record using the API.
--------------------------------------------------------------------------
        IF hr_mx_assignment_api.g_leaving_reason IS NULL THEN

                IF g_debug THEN
                        hr_utility.set_location(l_proc, 40);
                END IF;

--                hr_utility.set_message(800,'HR_MX_MISSING_LEAVING_REASON');
--                hr_utility.raise_error;
                null;

        ELSE

                IF g_debug THEN
                        hr_utility.set_location(l_proc, 50);
                END IF;

                hr_assignment_extra_info_api.create_assignment_extra_info
                            (p_assignment_id    => p_assignment_id,
                             p_information_type => 'MX_SS_EMP_TRANS_REASON',
                             p_aei_information_category => 'MX_SS_EMP_TRANS_REASON',
                             p_aei_information1 => fnd_date.date_to_canonical(trunc(p_final_process_date)),
                             p_aei_information2 => l_gre_old,
                             p_aei_information3 => hr_mx_assignment_api.g_leaving_reason,
                             p_assignment_extra_info_id => l_dummy3,
                             p_object_version_number => l_dummy4
                            );

                hr_mx_assignment_api.g_leaving_reason := null;

                IF g_debug THEN
                        hr_utility.set_location(l_proc, 60);
                END IF;

        END IF;

        IF g_debug THEN
                hr_utility.set_location('Leaving: '||l_proc, 70);
        END IF;

--
END chk_leav_reason_for_del_asg;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : chk_leav_reason_for_del_emp                         --
-- Type           : Procedure                                           --
-- Access         : Public                                              --
-- Description    : Procedure to capture the Leaving Reason in case of  --
--                  end of Employment.                                  --
-- Parameters     :                                                     --
--             IN : p_final_process_date    DATE                        --
--                  p_assignment_id         NUMBER                      --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
--------------------------------------------------------------------------
PROCEDURE chk_leav_reason_for_del_emp

(p_final_process_date    IN DATE,
 p_period_of_service_id  IN per_periods_of_service.period_of_service_id%TYPE,
 p_object_version_number IN NUMBER
) AS

l_dummy            NUMBER;
l_proc             VARCHAR2(100);
ld_effective_date  DATE;
--
BEGIN
--
        g_debug    := hr_utility.debug_enabled;
        l_dummy    := p_object_version_number;

        l_proc := g_package||'chk_leav_reason_for_del_emp';
        IF g_debug THEN
                hr_utility.set_location('Entering:'|| l_proc, 10);
        END IF;

        IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'MX') THEN

                IF g_debug THEN
                        hr_utility.trace('Mexico legislation not installed. Not performing validation checks.');
                END IF;
                RETURN;
        END IF;

--------------------------------------------------------------------------
-- Check the leaving reason Global Variable. If it's null, raise an error.
-- Else, save it in the Period of Service DDF using the API.
--------------------------------------------------------------------------
        IF hr_mx_assignment_api.g_leaving_reason IS NULL THEN

                IF g_debug THEN
                        hr_utility.set_location(l_proc, 20);
                END IF;

--                hr_utility.set_message(800,'HR_MX_MISSING_LEAVING_REASON');
--                hr_utility.raise_error;
                null;

        ELSE

                IF g_debug THEN
                        hr_utility.set_location(l_proc, 30);
                END IF;

                BEGIN

                  SELECT TRUNC(effective_date)
                    INTO ld_effective_date
                    FROM fnd_sessions
                   WHERE session_id = userenv('sessionid');

                  EXCEPTION
                  WHEN others THEN
                    ld_effective_date := TRUNC(sysdate);

                END;

                hr_periods_of_service_api.update_pds_details
                   (p_effective_date           => ld_effective_date
                   ,p_final_process_date       => trunc(p_final_process_date)
                   ,p_period_of_service_id     => p_period_of_service_id
                   ,p_pds_information_category => 'MX'
                   ,p_pds_information1         =>
                                         hr_mx_assignment_api.g_leaving_reason
                   ,p_object_version_number    => l_dummy
                      );

                hr_mx_assignment_api.g_leaving_reason := null;

                IF g_debug THEN
                        hr_utility.set_location(l_proc, 40);
                END IF;

        END IF;

        IF g_debug THEN
                hr_utility.set_location('Leaving: '||l_proc, 50);
        END IF;

--
END chk_leav_reason_for_del_emp;

BEGIN
--
    g_package  := 'hr_mx_extra_asg_rules.';

--
END hr_mx_extra_asg_rules;

/
